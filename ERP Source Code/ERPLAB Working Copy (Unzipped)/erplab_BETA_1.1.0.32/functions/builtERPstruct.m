%  Write erplab at command window for help
%
% Author: Javier Lopez-Calderon & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% ERPLAB Toolbox
% Copyright © 2007 The Regents of the University of California
% Created by Javier Lopez-Calderon and Steven Luck
% Center for Mind and Brain, University of California, Davis,
% javlopez@ucdavis.edu, sjluck@ucdavis.edu
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

function ERP = builtERPstruct(EEG)

if nargin<1
        help builtERPstruct
        return
end

if isempty(EEG)
        EEG.epoch = [];
end

if ~isempty(EEG.epoch) % epoched

        nbin   = EEG.EVENTLIST.nbin;    % total number of specified bins (at bin descriptor file)

        ERP.erpname    = [];
        ERP.filename   = [];
        ERP.filepath   = [];
        ERP.workfiles  = EEG.filename;
        ERP.subject    = EEG.subject;
        ERP.nchan      = EEG.nbchan;
        ERP.nbin       = nbin;
        ERP.pnts       = EEG.pnts;
        ERP.srate      = EEG.srate;
        ERP.xmin       = EEG.xmin;
        ERP.xmax       = EEG.xmax;
        ERP.times      = EEG.times;
        ERP.bindata    = zeros(EEG.nbchan, EEG.pnts, nbin); % data field
        ERP.binerror   = []; % error field
        ERP.chanlocs   = EEG.chanlocs;
        ERP.ref        = EEG.ref;
        ERP.bindescr   = {EEG.EVENTLIST.bdf(1:nbin).description};
        ERP.ntrials.accepted  = zeros(1,nbin);  % num of accepted trial per bin for averaging
        ERP.ntrials.rejected  = zeros(1,nbin);  % num of rejected trial per bin for averaging
        ERP.ntrials.invalid   = zeros(1,nbin);  % num of invalid trial per bin for averaging
        ERP.history    = EEG.history;
        ERP.saved      = 'no';
        ERP.isfilt     = 0;   % 1= avg was filtered or smoothed
        ERP.EVENTLIST  = EEG.EVENTLIST;

        ERP.version = geterplabversion;

        [ERP serror] = sorterpstruct(ERP);
else  % continuous
        ERP.erpname    = [];
        ERP.filename   = [];
        ERP.filepath   = [];
        ERP.workfiles  = [];
        ERP.subject    = [];
        ERP.nchan      = [];
        ERP.nbin       = 0;
        ERP.pnts       = 0;
        ERP.srate      = [];
        ERP.xmin       = [];
        ERP.xmax       = [];
        ERP.times      = [];
        ERP.bindata    = [];
        ERP.binerror   = []; % error field
        ERP.chanlocs   = [];
        ERP.ref        = [];
        ERP.bindescr   = [];
        ERP.ntrials.accepted  = [];
        ERP.ntrials.rejected  = [];
        ERP.ntrials.invalid   = [];
        ERP.history    = [];
        ERP.saved      = 'no';
        ERP.isfilt     = [];
        ERP.EVENTLIST  = [];

        ERP.version = geterplabversion;

        [ERP serror] = sorterpstruct(ERP);

end

