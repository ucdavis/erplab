% PURPOSE: builds an empty ERP structure or borrowing values from the EEG structure
%
% FORMAT:
%
% ERP = buildERPstruct(EEG)
%
% INPUT:
%
% EEG        - EEG dataset or empty ([]) or none.
%
%
% OUTPUT:
%
% ERP        - initialized ERPset
%
%
% EXAMPLE: 
%
% ERP = buildERPstruct(EEG); % builds an ERP structure taking some values from the EEG structure
% ERP = buildERPstruct([]);  % builds an empty ERP structure 
% ERP = buildERPstruct;      % builds an empty ERP structure 
%
%
% See also sorterpstruct.m geterplabversion.m
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

function ERP = buildERPstruct(EEG)
if nargin<1
        EEG = [];
end
if isempty(EEG)
        EEG.epoch = [];
end
if ~isempty(EEG.epoch) % epoched
        nbin             = EEG.EVENTLIST.nbin;    % total number of specified bins (at bin descriptor file)
        ERP.erpname      = [];
        ERP.filename     = [];
        ERP.filepath     = [];
        ERP.workfiles    = EEG.filename;
        ERP.subject      = EEG.subject;
        ERP.nchan        = EEG.nbchan;
        ERP.nbin         = nbin;
        ERP.pnts         = EEG.pnts;
        ERP.srate        = EEG.srate;
        ERP.xmin         = EEG.xmin;
        ERP.xmax         = EEG.xmax;
        ERP.times        = EEG.times;
        ERP.bindata      = zeros(EEG.nbchan, EEG.pnts, nbin); % data field
        ERP.binerror     = [];                                % error field
        ERP.datatype     = 'ERP';
        ERP.chanlocs     = EEG.chanlocs;
        ERP.ref          = EEG.ref;
        ERP.bindescr     = {EEG.EVENTLIST.bdf(1:nbin).description};
        ERP.ntrials.accepted  = zeros(1,nbin);  % num of accepted trial per bin for averaging
        ERP.ntrials.rejected  = zeros(1,nbin);  % num of rejected trial per bin for averaging
        ERP.ntrials.invalid   = zeros(1,nbin);  % num of invalid trial per bin for averaging
        ERP.pexcluded    = [];                  % proportion of excluded trials (total)
        ERP.history      = EEG.history;
        ERP.saved        = 'no';
        ERP.isfilt       = 0;                   % 1= avg was filtered or smoothed
        ERP.EVENTLIST    = EEG.EVENTLIST;
        ERP.version      = geterplabversion;
        ERP.splinefile   = EEG.splinefile;
        [ERP, serror]    = sorterpstruct(ERP);
else  % continuous
        ERP.erpname      = [];
        ERP.filename     = [];
        ERP.filepath     = [];
        ERP.workfiles    = [];
        ERP.subject      = [];
        ERP.nchan        = [];
        ERP.nbin         = 0;
        ERP.pnts         = 0;
        ERP.srate        = [];
        ERP.xmin         = [];
        ERP.xmax         = [];
        ERP.times        = [];
        ERP.bindata      = [];
        ERP.binerror     = []; % error field
        ERP.datatype     = 'ERP';
        ERP.chanlocs     = [];
        ERP.ref          = [];
        ERP.bindescr     = [];
        ERP.ntrials.accepted  = [];
        ERP.ntrials.rejected  = [];
        ERP.ntrials.invalid   = [];
        ERP.pexcluded    = [];
        ERP.history      = [];
        ERP.saved        = 'no';
        ERP.isfilt       = [];
        ERP.EVENTLIST    = [];
        ERP.version      = geterplabversion;
        ERP.splinefile   = '';
        [ERP, serror]    = sorterpstruct(ERP);
end

