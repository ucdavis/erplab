 % This is beta version for Decoding Toolbox
% pipeline that utilizes a nested bin-epoched data structure.
% Refer to OSF: https://osf.io/29wre/

% NOTE: low-pass filtering to 6hz was applied to continuous EEG (prior to
% binning). % Code to be used on a bin-epoched dataset for one
% class only (e.g. Orientation)

% NOTE: This script requires the 'fitcecoc' Matlab function. This function is a
% part of the Matlab Statistics and Machine Learning toolbox.

%Edited by Aaron Simmons (UC Davis)
%Original Author: Gi-Yeul Bae (Arizona State University)

function [MVPC, ALLMVPC] = erp_decoding(ALLBEST, nIter, nCrossBlocks, DataTimes,relevantChans,SVMcoding,equalT,ParCompute,method)

% Parallelization: This script utilizes Matlab parallelization ...
% if cannot parallelize, ParWorkers = 0, or ParWorkers set to 0 by users. 

if ParCompute == 1
    delete(gcp)
    par_profile = parpool;
    ParWorkers = par_profile.NumWorkers; 
else
    ParWorkers = 0; %makes parfor run without workers, even if pool is open. 
end

%% Check presence of Matlab Statistics and Machine Learning Toolbox
% This toolbox is required for the SVM classification
V = ver; 
Vname = {V.Name}; 
if ~(any(strcmp(Vname, 'Statistics and Machine Learning Toolbox')))
    error('Error. Statistics and Machine Learning toolbox not found.');
end


%% Subject List: 
nSubs = length(ALLBEST); % # files = # subjects

%% Step 9: Loop through participants
for s = 1:nSubs %decoding is performed within each subject independently
    
    %% Parameters to set per subject 
    % Main structure is mvpa.
    
    %load subject BESTset & build mvpa dataset
    BEST = ALLBEST(s);   
    mvpc = buildMVPCstruct(BEST,relevantChans, nIter, nCrossBlocks, DataTimes,equalT,SVMcoding,method); 
    
    % The electrode channel list is mapped 1:1 with respect to your
    % electrode channel configuration (e.g., channel 1 is FP1 in our EEG cap)
    % Check if the label for each electrode corresponds to the electrode
    % labeling of your own EEG system
    ReleventChan = relevantChans; %electrodes
    
    
    % for brevity in analysis
    nBins =         mvpc.nClasses;
    nIter =         mvpc.nIter;
    nBlocks =       mvpc.nCrossfolds;
    nElectrodes =   length(mvpc.electrodes); 
    nSamps =        length(mvpc.times);
    sn =            BEST.mvpcname;
    
    
    %progress output to command window
    fprintf('*** Currently Decoding Subject:\t%s ***\n ',sn);
    
    %% Data Loading/preallocation per subject 

    % grab EEG data from bin-list organized data 
    eegs = BEST.binwise_data;
    nPerBin = BEST.n_trials_per_bin;
    
    % Preallocate Matrices
    svm_predict = nan(nIter,nBlocks, nSamps,nBins); % a matrix to save prediction from SVM
    tst_target = nan(nIter,nBlocks,nSamps,nBins);  % a matrix to save true target values
    
    % create svmECOC.block structure to save block assignments
   % mvpa.blocks=struct();
    
    if nBins ~= max(size(eegs))
        error('Error. nBins dne # of bins in dataset!');
        % Code to be used on a bin-epoched dataset for one
        % class only (e.g. Orientation). Users may
        % try to bin multiple classes in one BDF.
        % This is not currently allowed.
    end
    
    
    %% Step 8: Loop through each iteration with random shuffling
    tic % start timing iteration loop
    
    % progress checker 

    
    for iter = 1:nIter
        
        
        %update waitbar & message
        fprintf('Subject: %s, Iteration: %i / %i \n', sn, iter, nIter); 
        
        %% Obtaining AVG. EEG (ERP spatial dist) 
        % within each block at each time point 
        % stored in blockDat_filtData
        
        %preallocate & rewrite per each iteration      
        blockDat_filtData = nan(nBins*nBlocks,nElectrodes,nSamps);   
        labels = nan(nBins*nBlocks,1);     % bin labels for averaged & filtered EEG data
        blockNum = nan(nBins*nBlocks,1);   % block numbers for averaged & filtered EEG data
        bCnt = 1; %initialize binblock counter 
        
        % this code operates and creates ERPs at each bin 
        % and organizes that into approprate block 
        
        %% shuffling, binning, & averaging
        for bin = 1:nBins 
            

            % We will use as many possible trials per
            % bin having accounted already for artifacts
            % Controlled by specifying equalize_trials in pop_decoding
            
            %Drop excess trials
            nPerBinBlock = floor(nPerBin/nBlocks); %array for nPerBin
            
            %Obtain index within each shuffled bin
            shuffBin = randperm((nPerBinBlock(bin))*nBlocks)';
            
            %Preallocate arrays
            
            blocks = nan(size(shuffBin));
            shuffBlocks = nan(size(shuffBin));
            
            %arrage block order within bins
            x = repmat((1:nBlocks)',nPerBinBlock(bin),1);
            shuffBlocks(shuffBin) = x;

            
            %unshuffled block assignment
            blocks(shuffBin) = shuffBlocks;
            
            % save block assignment
            blockID = ['iter' num2str(iter) 'bin' num2str(bin)];
           
            mvpc.SVMinfo.blockassignment.(blockID) = blocks; % block assignment
            mvpc.SVMinfo.n_trials_per_erp(bin) = nPerBinBlock(bin); 
            
            
            %create ERP average and place into blockDat_filtData struct          
            %grab current bin with correct # of electrodes & samps
            eeg_now = eegs(bin).data(ReleventChan,:,:);
            
            %here, we create blockDat_filtData. 
            %this results in nBins*nBlocks amount of ERP spatial
            %distributions (across nChans) at each sample/timepoint
            
            %% Step 1: computing ERPs based on random subset of trials for each block 
            for bl = 1:nBlocks
                
                blockDat_filtData(bCnt,:,:) = squeeze(mean(eeg_now(:,:,blocks==bl),3));
                
                labels(bCnt) = bin; %used for arranging classification obj.
                
                blockNum(bCnt) = bl;
                
                bCnt = bCnt+1;
                
            end
            
        end
        

        %% Step 7: Loop through each timepoint 
        % Do SVM_ECOC at each time point
        parfor (t = 1:nSamps,ParWorkers)
            mdl = []; 
            % grab data for timepoint t
            %toi = ismember(times,times(t)-svmECOC.window/2:times(t)+svmECOC.window/2);
            
            % average across time window of interest
            % here, you can parse nBin*nBlock across all channels (ERP spatial dist) 
            dataAtTimeT = squeeze(mean(blockDat_filtData(:,:,t),3));
            
            %% Step 6: Cross-validation for-loop 
            for i=1:nBlocks % loop through blocks, holding each out as the test set
                
                
                %% Step 2 & Step 4: Assigning training and testing data sets
                trnl = labels(blockNum~=i); % training labels
                
                tstl = labels(blockNum==i); % test labels
                
                trnD = dataAtTimeT(blockNum~=i,:);    % training data
                
                tstD = dataAtTimeT(blockNum==i,:);    % test data
                
                %% Step 3: Training
                if SVMcoding == 2
                    mdl = fitcecoc(trnD,trnl, 'Coding','onevsall','Learners','SVM' );   %train support vector mahcine
                elseif SVMcoding == 1
                    mdl = fitcecoc(trnD,trnl, 'Coding','onevsone','Learners','SVM' );   %train support vector mahcine
                end
                
                %% Step 5: Testing
                LabelPredicted = predict(mdl, tstD);       % predict classes for new data
                
                svm_predict(iter,i,t,:) = LabelPredicted;  % save predicted labels
                
                tst_target(iter,i,t,:) = tstl;             % save true target labels
                
                
            end % end of block: Step 6: cross-validation
            
        end % end of time points: Step 7: Decoding each time point
        
    end % end of iteration: Step 8: iteration with random shuffling
 
    
    toc % stop timing the iteration loop
    
    mvpc = rawscoreSVM(mvpc, tst_target, svm_predict, SVMcoding); %compute raw method/decoder scores
    mvpc = averageSVM(mvpc, SVMcoding,1); %average accuracy across runs
    %mvpa = avgconfusionSVM(mvpa,tst_target_svm_predict,SVMcoding); 
    
    
    %create the MVPA output 
    %output decoding results in main svmECOC structure
    

    
    
%     mvpa.targets = tst_target;
%     mvpa.modelPredict = svm_predict;    
   % mvpa.nBlocks = nBlocks;
   
    
 
    
    %probably a better way
    if nSubs == 1
        
        %function outputs single/all MVPA
        %save(filepath,'mvpa','-v7.3');
        
        MVPC = mvpc;
        ALLMVPC = mvpc;
    else
        %function outputs single/all MVPA
       % save(filepath{s},'mvpa','-v7.3');
        
        MVPC = mvpc; 
        ALLMVPC(s) = mvpc; 
    end
    
    
    
end % end of subject loop: Step 9: Decoding for each participant 