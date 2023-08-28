
function [MVPC, ALLMVPC] = crossnobis(ALLBEST, nIter, nCrossBlocks, DataTimes,relevantChans,classcoding,equalT,ParWorkers,method)

%% Subject List: 
nSubs = length(ALLBEST); % # files = # subjects

%% Step 9: Loop through participants
for s = 1:nSubs %crossnobis is performed within each subject independently
    
    %% Parameters to set per subject 
    BEST = ALLBEST(s);   
    mvpc = buildMVPCstruct(BEST,relevantChans, nIter, nCrossBlocks, DataTimes,equalT,classcoding,method); 
    
    % for brevity in analysis
    nBins =         mvpc.nClasses;
    nIter =         mvpc.nIter;
    nPerms =        nchoosek(nBins,2); %total # pairwise comparisions
    dataTime = BEST.times; %times of imported data
    %nBlocks =       mvpc.nCrossfolds;
   % nElectrodes =   length(mvpc.electrodes); 
    nSamps =        length(mvpc.times);
    try
        sn =            BEST.mvpcname; %if data went through decoding GUI
    catch
        sn =            BEST.bestname;
    end
    
    %progress output to command window
    fprintf('*** Currently Decoding (Crossnobis) Subject:\t%s ***\n ',sn); %is Decoding the word to use for crossnobis? 
    
     % grab EEG data from bin-list organized data 
    eegs = BEST.binwise_data;
    nPerBin = BEST.n_trials_per_bin;
    % we create index of timpoint of interests from original data
    tois = ismember(dataTime,dataTime);

    
%     % Preallocate Matrices
     final_xDist = nan(nSamps,nIter,nPerms);
%     %BetaWeights_Raw = nan(nIter,nSamps,nBlocks,nElectrodes);
%     %BetaWeights_Corr = BetaWeights_Raw;
    
    
    if nBins ~= max(size(eegs))
        error('Error. nBins dne # of bins in dataset!');
        % Code to be used on a bin-epoched dataset for one
        % class only (e.g. Orientation). Users may
        % try to bin multiple classes in one BDF.
        % This is not currently allowed.
    end
    
    %% Create labels/data object for each subject
    %probably slow if not preallocating memory...
    %but generalizable to all bin-epoched datasets
    xlabels = []; %pronounced "cross-labels"
    
    for binN = 1:numel(eegs)
        
        xlabels_temp = repmat(binN, [nPerBin(binN) 1]);
        
        xlabels = [xlabels; xlabels_temp];
    end
    
    % create new crossnobis data array &
    % obtain timepoints of interest (resample)
    % (NChan x nTP x nTrials(ideally randomized) x Nlabels)
    
    for b = 1:numel(nPerBin)
        ntrial = size(eegs(b).data,3); 
        shuff_list = randperm(ntrial); 
        
        %so we always allow the specified number of trials per bin
        %(nPerBin) by choosing from a (potentially) larger set of trials
        %within the bin
        
        idx_list = shuff_list(1:nPerBin(b)); 
        
        indexed_data = eegs(b).data(:,:,idx_list);
        eegs(b).data = indexed_data; 
    
    end
    
    
    
    xdata = cat(3, eegs.data); %pronounced "cross-data"
    xdata = xdata(:,tois,:); %resampled data
    
    
      %% Step 8: Loop through each iteration with random shuffling
    tic % start timing iteration loop
    
    %% Perform Cross-Nobis analysis at each requested time-point
    for iter = 1:nIter
        fprintf('Subject: %s, Iteration: %i / %i \n', sn, iter, nIter);
        parfor (nTp = 1:nSamps,ParWorkers)
           
            % structs to hold shuffled data
            a_full_bin_label= struct();
            b_full_bin_label= struct();
            
            a_full_bin_data = struct();
            b_full_bin_data = struct();
            
            
            for bin = 1:nBins
                binT = nPerBin(bin); %number of trials in bin
                halfT = floor(binT/2); %number of half of trials in bin floored
                
                %obtain index of trials of current bin
                binIndex = (xlabels==bin);
                
                
                %trial equalization here
                %create logical indexs for labels and data
                %length(shuffInd) should always equal the total number of
                %trials in a bin after flooring (ie truncated to allow for even split)
                
                shuffInd = [repmat(1,[halfT,1]); repmat(0,[halfT,1])];
                
                %RANDOMIZING HERE
                %creates shuffled logical index
                %so from the current bin, we are always
                %indexing a different mix of trials every iteration
                shuffInd_a = logical(shuffle(shuffInd));
                shuffInd_b = ~shuffInd_a;
                
                % subset the xdata for current bin
                full_labels = xlabels(binIndex);
                full_data = xdata(:,:,binIndex);
                
                %from full_data, subset into two sets (a and b).
                %On each interation, trials in both sets will be a different
                % subset of equally mixed and indexed trials from current
                % bin. Bins do not have to be equal to other bins
                % but the sets a and b are equal.
                adata = full_data(:,:,shuffInd_a);
                bdata = full_data(:,:,shuffInd_b);
                adata_tp = squeeze(adata(relevantChans,nTp,:));
                adata_tp = permute(adata_tp, [2 1]);
                bdata_tp = squeeze(bdata(relevantChans,nTp,:));
                bdata_tp = permute(bdata_tp, [2 1]);
                
                a_full_bin_label(bin).labels = full_labels(1:halfT);
                b_full_bin_label(bin).labels = full_labels(1:halfT);
                a_full_bin_data(bin).data = adata_tp;
                b_full_bin_data(bin).data = bdata_tp;
                
            end
            
            %create arrays for input into function
            a_complete_labels = cat(1, a_full_bin_label.labels);
            b_complete_labels = cat(1, b_full_bin_label.labels);
            
            a_complete_data_tp = cat(1, a_full_bin_data.data);
            b_complete_data_tp = cat(1, b_full_bin_data.data);
            
            
            
            xDist = SqrtCrossNobis_Distance(a_complete_data_tp, ...
                a_complete_labels,b_complete_data_tp, b_complete_labels);
            
            final_xDist(nTp,iter,:) = xDist;
        end
    end

    toc % stop timing the iteration loop
    
    mvpc.details = []; 
    mvpc.raw_predictions = final_xDist; 
    
    avg_distance_iter = squeeze(mean(final_xDist,2))'; 
    avg_distance_scores =  squeeze(mean(avg_distance_iter,1)); 
    
    mvpc.average_score = avg_distance_scores;
    mvpc = avgconfusionCM(mvpc, final_xDist);  
    mvpc.stderror = std(avg_distance_iter)/sqrt(size(final_xDist,1)); 
    
    
     %probably a better way
    if nSubs == 1

        MVPC = mvpc;
        ALLMVPC = mvpc;
    else
 
        MVPC = mvpc; 
        ALLMVPC(s) = mvpc; 
    end
    
    
    
end
