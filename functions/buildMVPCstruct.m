function [mvpc] = buildMVPCstruct(ALLBEST,relevantChans,nIter,nCrossBlocks,DataTimes,equalT,SVMcoding,method)

mvpc = []; %empty mvpa

if nargin < 1
    mvpc.mvpcname = '';
    mvpc.filename = '';
    mvpc.filepath = ''; 
    mvpc.electrodes = ALLBEST.chanlocs; 
    mvpc.nClasses = ALLBEST.nbin; % # of bins
    mvpc.nChance = 1/mvpc.header.nClasses; %chance
    mvpc.nIter = 0;
    mvpc.nCrossfolds = 0; %[] if tw.
    mvpc.nSampling = ALLBEST.srate; %updated fs
    mvpc.pnts = ALLBEST.pnts;
    mvpc.SVMcoding = [];
    mvpc.DecodingUnit = 'None'; %Accuracy vs Distance vs None
    mvpc.DecodingMethod = '';
    mvpc.average_status = 'single_subject';
    mvpc.equalTrials = 1; %1: floor across files, %2 floor within files, %0 don't floor. 
    mvpc.n_trials_per_class = ALLBEST.n_trials_per_bin;
    mvpc.saved = 'no';
    mvpc.epoch.pre = ALLBEST.times(1); % Set epoch start in ms (from imported data)
    mvpc.epoch.post = ALLBEST.times(end); % Set epoch end in ms (from imported data)
    mvpc.times = ALLBEST.times; %timepoints actually decoded
    mvpc.mvpc_version = 1; 
    
else
    try 
        mvpc.mvpcname = ALLBEST.mvpcname;% if data went through decoding GUI 
    catch
        mvpc.mvpcname = ALLBEST.bestname; 
    end
    mvpc.filename = ALLBEST.filename;
    mvpc.filepath = ALLBEST.filepath;  
    mvpc.electrodes = relevantChans; 
    mvpc.nClasses = ALLBEST.nbin; % # of bins
    mvpc.nChance = 1/mvpc.nClasses; %chance
    mvpc.nIter = nIter;
    mvpc.nCrossfolds = nCrossBlocks; %[] if tw. 
    mvpc.nSampling = ALLBEST.srate; %updated fs
    mvpc.pnts = ALLBEST.pnts;
    if SVMcoding == 1
        mvpc.SVM.OneVsOne = 'yes';
        mvpc.SVM.OneVsAll ='no';
    elseif SVMcoding == 2
        mvpc.SVM.OneVsOne ='no';
        mvpc.SVM.OneVsAll='yes';
    elseif isempty(SVMcoding)
        mvpc.SVM.OneVsOne ='no';
        mvpc.SVM.OneVsAll = 'no'; 
    end
    mvpc.DecodingUnit= 'Accuracy'; %or "Distance" for crossnobis
    if method == 1
        mvpc.DecodingMethod = 'SVM';
    elseif method == 2
        mvpc.DecodingMethod = 'Crossnobis';
    end
    mvpc.average_status = 'single_subject';
    mvpc.equalTrials = equalT; %1: floor across files, %2 floor within files, %0 don't floor %3 common floor. 
    mvpc.n_trials_per_class = ALLBEST.n_trials_per_bin;
    mvpc.saved = 'no';
    mvpc.epoch.pre = DataTimes(1); % Set epoch start (from imported data)
    mvpc.epoch.post = DataTimes(2); % Set epoch end (from imported data)
    mvpc.times = ALLBEST.times; %timepoints actually decoded
    mvpc.mvpc_version = 1; 
  
    
    
end