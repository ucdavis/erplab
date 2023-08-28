function [BEST] = buildBESTstruct(EEG)

BEST = []; %empty BEST

if nargin <1
    BEST = []; 
end

if isempty(EEG)
    EEG.epoch =[]; 
end
if ~isempty(EEG.epoch) %epoched
    nbin = EEG.EVENTLIST.nbin;
    BEST.version = 1.0; %ERPLAB version
    %MVPA.subj = [];
    BEST.bestname = EEG.setname;
    BEST.filename = EEG.setname;
    BEST.filepath = EEG.filepath;
    BEST.nbin = nbin;
    BEST.pnts = EEG.pnts; %same across all bins
    BEST.srate = EEG.srate;
    BEST.xmin = EEG.xmin;
    BEST.xmax = EEG.xmax; 
    BEST.times = EEG.times; 
    BEST.nbchan = EEG.nbchan;
    BEST.chanlocs = EEG.chanlocs;
    BEST.bindesc = {EEG.EVENTLIST.bdf.description}; 
    BEST.original_bin = {EEG.EVENTLIST.bdf.namebin};
    BEST.EEGhistory = EEG.history; 
end