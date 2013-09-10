% DEPRECATED...
%
%
% Modify EVENTLIST only
%
% Author: Javier Lopez-Calderon
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

function EEG = onlybinlabel(EEG)

%
% captures event owning a bin
%
levent      = length(EEG.EVENTLIST.eventinfo);
successindx = [];

for i=1:levent
        if ~isempty(EEG.EVENTLIST.eventinfo(i).bini) && (EEG.EVENTLIST.eventinfo(i).bini~=-1)
                successindx = [successindx i];
        end
end

%
% ALL EEG.EVENTLIST.eventinfo fields
%
nsuccess = length(successindx);
names    = fieldnames(EEG.EVENTLIST.eventinfo); % get all the currents fields at eventinfo
lename   = length(names);

for i=1:lename
        [AUX_FIELDS{i}{1:nsuccess}] = deal(EEG.EVENTLIST.eventinfo(successindx).(names{i}));
end

%
% Erase all the eventinfo's subfields
%
EEG.EVENTLIST = rmfield(EEG.EVENTLIST, 'eventinfo');

%
% Rebuilds the eventinfo structure with events which have bin(s) assigned
%
for i=1:lename        
        if strcmp(names{i},'time')
                [EEG.EVENTLIST.eventinfo(1:nsuccess).(names{i})]  = AUX_FIELDS{i}{:};
                
                auxdiffe = num2cell([0 diff([AUX_FIELDS{i}{:}])]);
                [EEG.EVENTLIST.eventinfo(1:nsuccess).diffe]       = auxdiffe{:};
        end        
        if ~strcmp(names{i},'diffe') && ~strcmp(names{i},'time')
                [EEG.EVENTLIST.eventinfo(1:nsuccess).(names{i})]  = AUX_FIELDS{i}{:};
        end
end