function [mvpa] = buildMVPAstruct(ALLBEST,relevantChans,nIter,nCrossBlocks,DataTimes,equalT,SVMcoding,method)

mvpa = []; %empty mvpa

if nargin < 1
    mvpa.header.subjectID = ''; 
    mvpa.header.mvpa_version = 1; 
    mvpa.header.electrodes = ALLBEST.chanlocs; 
    mvpa.header.nClasses = ALLBEST.nbin; % # of bins
    mvpa.header.nIter = 0;
    mvpa.header.nCrossfolds = 0; %[] if tw.
    mvpa.header.nChance = 1/mvpa.header.nClasses; %chance
    mvpa.header.nSampling = ALLBEST.srate; %updated fs
    mvpa.header.pnts = ALLBEST.pnts;
    mvpa.header.SVMcoding = [];
    mvpa.header.DecodingAccuracy = ''; 
    mvpa.header.DecodingMethod = '';
    mvpa.header.DecodingDistance = [];
    mvpa.header.grandaverage = 'no';
    mvpa.header.window = ''; %point or twindow
    mvpa.header.equalTrials = 1; %1: floor across files, %2 floor within files, %0 don't floor. 
    mvpa.header.n_trials_per_bin = ALLBEST.n_trials_per_bin;
    
    %mvpa fields
    mvpa.epoch.pre = ALLBEST.times(1); % Set epoch start in ms (from imported data)
    mvpa.epoch.post = ALLBEST.times(end); % Set epoch end in ms (from imported data)
    mvpa.times = ALLBEST.times; %timepoints actually decoded
    
else
    mvpa.header.subjectID = ALLBEST.bestname;
    mvpa.header.mvpa_version = 1; 
    mvpa.header.electrodes = relevantChans; 
    mvpa.header.nClasses = ALLBEST.nbin; % # of bins
    mvpa.header.nIter = nIter;
    mvpa.header.nCrossfolds = nCrossBlocks; %[] if tw. 
    mvpa.header.nChance = 1/mvpa.header.nClasses; %chance
    mvpa.header.nSampling = ALLBEST.srate; %updated fs
    mvpa.header.pnts = ALLBEST.pnts;
    if SVMcoding == 1
        mvpa.header.OneVsOne = 'yes';
        mvpa.header.OneVsAll ='no';
    elseif SVMcoding == 2
        mvpa.header.OneVsOne ='no';
        mvpa.header.OneVsAll='yes';
    elseif isempty(SVMcoding)
        mvpa.header.OneVsOne ='no';
        mvpa.header.OneVsAll = 'no'; 
    end
    mvpa.header.DecodingAccuracy = 'yes';
    if method == 1
        mvpa.header.DecodingMethod = 'SVM';
    elseif method == 2
        mvpa.header.DecodingMethod = 'Crossnobis';
    end
    mvpa.header.DecodingDistance = [];
    mvpa.header.grandaverage = 'no';
    mvpa.header.window = 'point'; %point or twindow
    mvpa.header.equalTrials = equalT; %1: floor across files, %2 floor within files, %0 don't floor. 
    mvpa.header.n_trials_per_bin = ALLBEST.n_trials_per_bin;
    
    %mvpa fields
    mvpa.epoch.pre = DataTimes(1); % Set epoch start (from imported data)
    mvpa.epoch.post = DataTimes(2); % Set epoch end (from imported data)
    mvpa.times = ALLBEST.times; %timepoints actually decoded
end