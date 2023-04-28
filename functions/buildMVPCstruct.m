function [mvpc] = buildMVPCstruct(ALLBEST,relevantChans,nIter,nCrossBlocks,DataTimes,equalT,SVMcoding,method)

mvpc = []; %empty mvpa

if nargin < 1
    mvpc.mvpcname = '';
    mvpc.filename = '';
    mvpc.filepath = ''; 
    mvpc.mvpc_version = 1; 
    mvpc.electrodes = ALLBEST.chanlocs; 
    mvpc.nClasses = ALLBEST.nbin; % # of bins
    mvpc.nIter = 0;
    mvpc.nCrossfolds = 0; %[] if tw.
    mvpc.nChance = 1/mvpc.header.nClasses; %chance
    mvpc.nSampling = ALLBEST.srate; %updated fs
    mvpc.pnts = ALLBEST.pnts;
    mvpc.SVMcoding = [];
    mvpc.DecodingAccuracy = ''; 
    mvpc.DecodingMethod = '';
    mvpc.DecodingDistance = [];
    mvpc.grandaverage = 'no';
    mvpc.window = ''; %point or twindow
    mvpc.equalTrials = 1; %1: floor across files, %2 floor within files, %0 don't floor. 
    mvpc.n_trials_per_bin = ALLBEST.n_trials_per_bin;
    mvpc.saved = 'no';
    
    %mvpa fields
    mvpc.epoch.pre = ALLBEST.times(1); % Set epoch start in ms (from imported data)
    mvpc.epoch.post = ALLBEST.times(end); % Set epoch end in ms (from imported data)
    mvpc.times = ALLBEST.times; %timepoints actually decoded
    
else
    mvpc.mvpcname = ALLBEST.mvpcname;
    mvpc.filename = ALLBEST.filename;
    mvpc.filepath = ALLBEST.filepath; 
    mvpc.mvpc_version = 1; 
    mvpc.electrodes = relevantChans; 
    mvpc.nClasses = ALLBEST.nbin; % # of bins
    mvpc.nIter = nIter;
    mvpc.nCrossfolds = nCrossBlocks; %[] if tw. 
    mvpc.nChance = 1/mvpc.nClasses; %chance
    mvpc.nSampling = ALLBEST.srate; %updated fs
    mvpc.pnts = ALLBEST.pnts;
    if SVMcoding == 1
        mvpc.OneVsOne = 'yes';
        mvpc.OneVsAll ='no';
    elseif SVMcoding == 2
        mvpc.OneVsOne ='no';
        mvpc.OneVsAll='yes';
    elseif isempty(SVMcoding)
        mvpc.OneVsOne ='no';
        mvpc.OneVsAll = 'no'; 
    end
    mvpc.DecodingAccuracy = 'yes';
    if method == 1
        mvpc.DecodingMethod = 'SVM';
    elseif method == 2
        mvpc.DecodingMethod = 'Crossnobis';
    end
    mvpc.DecodingDistance = [];
    mvpc.grandaverage = 'no';
    mvpc.window = 'point'; %point or twindow
    mvpc.equalTrials = equalT; %1: floor across files, %2 floor within files, %0 don't floor. 
    mvpc.n_trials_per_bin = ALLBEST.n_trials_per_bin;
    
    
    %mvpa fields
    mvpc.epoch.pre = DataTimes(1); % Set epoch start (from imported data)
    mvpc.epoch.post = DataTimes(2); % Set epoch end (from imported data)
    mvpc.times = ALLBEST.times; %timepoints actually decoded
    mvpc.saved = 'no';
    
end