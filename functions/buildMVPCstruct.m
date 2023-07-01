function [mvpc] = buildMVPCstruct(ALLBEST,relevantChans,nIter,nCrossBlocks,DataTimes,equalT,classcoding,method)

mvpc = []; %empty mvpa

if nargin < 1
    mvpc.mvpcname = '';
    mvpc.filename = '';
    mvpc.filepath = ''; 
    mvpc.electrodes = 1:length(ALLBEST.chanlocs);
    mvpc.chanlocs = ALLBEST.chanlocs;     
    mvpc.nClasses = ALLBEST.nbin; % # of bins
    mvpc.chance = 1/mvpc.header.nClasses; %chance
    mvpc.classlabels = ALLBEST.bindesc; 
    mvpc.nIter = 0;
    mvpc.nCrossfolds = 0; %[] if tw.
    mvpc.srate = ALLBEST.srate; %updated fs
    mvpc.pnts = ALLBEST.pnts;
    mvpc.classcoding = 0;
    mvpc.DecodingUnit = 'None'; %Accuracy vs Distance vs None
    mvpc.DecodingMethod = '';
    mvpc.average_status = 'single_subject';
    mvpc.equalTrials = equalT; %str
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
    mvpc.chanlocs = ALLBEST.chanlocs(relevantChans); 
    mvpc.nClasses = ALLBEST.nbin; % # of bins
    if method == 1
        mvpc.chance = 1/mvpc.nClasses; %chance
    elseif method == 2
        mvpc.chance = 0; %0 uV for crossnobis
    end  
    mvpc.classlabels = ALLBEST.bindesc; 
    mvpc.nIter = nIter;
    mvpc.nCrossfolds = nCrossBlocks; %[] if tw. 
    mvpc.srate = ALLBEST.srate; %updated fs
    mvpc.pnts = ALLBEST.pnts;
    if classcoding == 1
        mvpc.classcoding.OneVsOne = 'yes';
        mvpc.classcoding.OneVsAll ='no';
    elseif classcoding == 2
        mvpc.classcoding.OneVsOne ='no';
        mvpc.classcoding.OneVsAll='yes';
    else
        mvpc.classcoding.OneVsOne ='no';
        mvpc.classcoding.OneVsAll = 'no'; 
    end
    if method == 1
        mvpc.DecodingUnit= 'proportion correct'; % if svm='%correct', crossnobis: "uV" for crossnobis
        mvpc.DecodingMethod = 'SVM';
    elseif method == 2
        mvpc.DecodingUnit = 'uV'; 
        mvpc.DecodingMethod = 'Crossnobis';
    end
    mvpc.average_status = 'single_subject';
    mvpc.equalTrials = equalT; %str
    mvpc.n_trials_per_class = ALLBEST.n_trials_per_bin;
    mvpc.saved = 'no';
    mvpc.epoch.pre = DataTimes(1); % Set epoch start (from imported data)
    mvpc.epoch.post = DataTimes(2); % Set epoch end (from imported data)
    mvpc.times = ALLBEST.times; %timepoints actually decoded
    mvpc.mvpc_version = 1; 
  
    
    
end