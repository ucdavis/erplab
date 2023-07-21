% ERP decoding algorithm for Decoding Toolbox

%Function written by Aaron Simmons (UC Davis)
%Original Algorithm Author: Gi-Yeul Bae (Arizona State University)


function [MVPC, ALLMVPC] = erp_decoding(ALLBEST, nIter, nCrossBlocks, DataTimes,relevantChans,classcoding,equalT,ParWorkers,method)

% Parallelization: This script utilizes Matlab parallelization ...
% if cannot parallelize, ParWorkers = 0, or ParWorkers set to 0 by users. 


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
    mvpc = buildMVPCstruct(BEST,relevantChans, nIter, nCrossBlocks, DataTimes,equalT,classcoding,method); 
    
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
    try
        sn =            BEST.mvpcname; %if data went through decoding GUI
    catch
        sn =            BEST.bestname;
    end
    
    
    %progress output to command window
    fprintf('*** Currently Decoding (SVM) Subject:\t%s ***\n ',sn);
    
    %% Data Loading/preallocation per subject 

    % grab EEG data from bin-list organized data 
    eegs = BEST.binwise_data;
    nPerBin = BEST.n_trials_per_bin;
    
    % Preallocate Matrices
    svm_predict = nan(nIter,nBlocks, nSamps,nBins); % a matrix to save prediction from SVM
    tst_target = nan(nIter,nBlocks,nSamps,nBins);  % a matrix to save true target values
    if nBins > 2    
        if classcoding == 1
            nDecoders = nchoosek(nBins,2); %onevsone (SVM only)
        elseif classcoding == 2
            nDecoders = nchoosek(nBins,1); %onevsall (SVM only)
        end
    else
        %binary decoder 
        nDecoders = 1; 
    end
    BetaWeights_Raw = nan(nIter,nSamps,nBlocks,nDecoders,nElectrodes);
    %BetaWeights_Corr = BetaWeights_Raw;
    
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
            % bin having accounted already for artifacts (required, not
            % changable by subject yet).
            % Following logic controlled by specifying equalize_trials in pop_decoding
            
            %Drop excess trials
            nPerBinBlock = floor(nPerBin/nBlocks); %array for nPerBin
            
            if ~any(nPerBinBlock)
                %for single trial decoding or trials less than nBlocks
                
                nPerBinBlock = nPerBin; 
            end
                  
            
             %grab current bin with correct # of electrodes & samps
             eeg_now = eegs(bin).data(ReleventChan,:,:);
            
             true_ntrials = size(eeg_now,3);
             min_trial_sparsity = floor(true_ntrials/nBlocks); % max 
                   
            %Obtain index within each shuffled bin
            %shuffBin = randperm((nPerBinBlock(bin))*nBlocks)';
            shuffBin = randperm(min_trial_sparsity*nBlocks)'; 
            
            %Preallocate arrays
            
%             blocks = nan(size(shuffBin));
%             shuffBlocks = nan(size(shuffBin));

            x = repmat((1:nBlocks)',nPerBinBlock(bin),1); %blockindex
            x2 = shuffBin(1:length(x)); %trial index within bin
            
            blocks = nan(size(x));
            %shuffBlocks = nan(size(x));
            
            %arrage block order within bins
%             x = repmat((1:nBlocks)',nPerBinBlock(bin),1);
%             x2 = shuffBin(1:length(x)); 
            %due to common floor option, x and x2 may different sizes 
            %shuffBlocks(shuffBin) = x;
           % [~,blocks] = ismember(shuffBin, x); 
            %shuffBlocks(shuffBin) = x2;
           

            
            %unshuffled block assignment
            %blocks(shuffBin) = shuffBlocks;
            blocks(:,1) = x; %block assignment
            blocks(:,2) = x2; %trial number
            
            % save block assignment
            blockID = ['iter' num2str(iter) 'bin' num2str(bin)];
           
            mvpc.details.info.blockassignment.(blockID) = blocks; % block assignment
            mvpc.details.n_trials_per_erp(bin) = nPerBinBlock(bin); 
            


            %create ERP average and place into blockDat_filtData struct         
            %this results in nBins*nBlocks amount of ERP spatial
            %distributions (across nChans) at each sample/timepoint
            
            %% Step 1: computing ERPs based on random subset of trials for each block 
            for bl = 1:nBlocks
                
                %unmask trial within block 
                unMasktrial = x2(x == bl); 
                
                %blockDat_filtData(bCnt,:,:) = squeeze(mean(eeg_now(:,:,blocks==bl),3));
                if nPerBinBlock(bin) == 1
                    blockDat_filtData(bCnt,:,:) = eeg_now(:,:,(unMasktrial)); %single trial
                else
                    blockDat_filtData(bCnt,:,:) = squeeze(mean(eeg_now(:,:,(unMasktrial)),3));
                end
                
                labels(bCnt) = bin; %used for arranging classification obj.
                
                blockNum(bCnt) = bl;
                
                bCnt = bCnt+1;
                
            end
            
        end
        

        %% Step 7: Loop through each timepoint 
        % Do SVM_ECOC at each time point
        parfor (t = 1:nSamps,ParWorkers)
        %for t = 1:nSamps
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
                if classcoding == 2 %onevsall
                    if nBins == 2
                        mdl = fitcsvm(trnD,trnl);   %binary decoder
                    else
                        mdl = fitcecoc(trnD,trnl, 'Coding','onevsall','Learners','SVM' ); %train support vector mahcine
                    end
                    
                elseif classcoding == 1 %onevsone
                    mdl = fitcecoc(trnD,trnl, 'Coding','onevsone','Learners','SVM' );   %train support vector mahcine
                else
                    error('Decoding Toolbox has unspecified SVMcoding'); 
                end
                
                %% Step 5: Testing
                LabelPredicted = predict(mdl, tstD);       % predict classes for new data
                
                svm_predict(iter,i,t,:) = LabelPredicted;  % save predicted labels
                
                tst_target(iter,i,t,:) = tstl;             % save true target labels
                
                if nBins > 2      
                    for d = 1:nDecoders
                        BetaWeights_Raw(iter,t,i,d,:) = mdl.BinaryLearners{d}.Beta;% SVM weights uncorrected
                    end  
                else
                    %binary decoder
                    for d = 1:nDecoders
                        BetaWeights_Raw(iter,t,i,d,:) = mdl.Beta;% SVM weights uncorrected
                    end
                end
                %BetaWeights_Corr(iter,t,i,:) = double(cov(trnD))*mdl.Beta;% SVM weights after correction
                
                
                
            end % end of block: Step 6: cross-validation
            
        end % end of time points: Step 7: Decoding each time point
        
    end % end of iteration: Step 8: iteration with random shuffling
 
    
    toc % stop timing the iteration loop
    
   % mvpc.details.CodingMatrix = mdl.CodingMatrix; 
    mvpc.details.BetaWeightsRaw =  BetaWeights_Raw;    
    mvpc = rawscoreSVM(mvpc, tst_target, svm_predict); %compute raw method/decoder scores
    mvpc = averageSVM(mvpc,0); %average accuracy across runs, %no smoothing
    mvpc = avgconfusionSVM(mvpc,tst_target, svm_predict); 

   % mvpc.BetaWeights_Raw = BetaWeights_Raw; 
   % mvpc.BetaWeights_Corr = BetaWeights_Corr; 
     
    %create the MVPA output 
    %output decoding results in main svmECOC structure
    

    
    
%     mvpa.targets = tst_target;
%     mvpa.modelPredict = svm_predict;    
   % mvpa.nBlocks = nBlocks;
   
    
 
    
    %probably a better way
    if nSubs == 1
        
        MVPC = mvpc;
        ALLMVPC = mvpc;
    else

        MVPC = mvpc; 
        ALLMVPC(s) = mvpc; 
    end
    
    
    
end % end of subject loop: Step 9: Decoding for each participant 