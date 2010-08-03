% Usage
%
% >> EEG = update_EEG_event_field(EEG, mainfield)
%
%  mainfield   -  string 'code', 'codelabel', or 'binlabel'
%
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

function EEG = update_EEG_event_field(EEG, mainfield)

%
% Replaces EEG.event.type field by EEG.EVENTLIST.eventinfo.binlabel
%
lenevent1 = length(EEG.EVENTLIST.eventinfo);
lenevent2 = length(EEG.event);

if (lenevent1 ~= lenevent2)
        EEG = rmfield(EEG,'event');
        fprintf('\nWARNING: Lengths of EEG.event and EEG.EVENTLIST.eveninfo are different.\n')
        fprintf('Therefore, EEG.event was deleted, and then rebuilt with the EEG.EVENTLIST.eveninfo values.\n')
end

[EEG.event(1:lenevent1).type] = EEG.EVENTLIST.eventinfo.(mainfield);

%
% In case there is not full replacement (fills up empty "event codes")
%
if ischar(EEG.event(1).type)
        [tf pos] = ismember({EEG.event.type},'""');
        posquo   = find(pos);
        [EEG.event(posquo).type]  = EEG.EVENTLIST.eventinfo(posquo).code;
else
        posquo = find(isnan([EEG.event.type]));
        [EEG.event(posquo).type]  = EEG.EVENTLIST.eventinfo(posquo).codelabel;
end

[EEG.event(1:lenevent1).codelabel] = EEG.EVENTLIST.eventinfo.codelabel;

if ~isfield(EEG.event,'latency')
        [EEG.event(1:lenevent1).latency] = EEG.EVENTLIST.eventinfo.spoint;
end

if ~isfield(EEG.event,'duration')
        [EEG.event(1:lenevent1).duration] = EEG.EVENTLIST.eventinfo.dura;
end

[EEG.event(1:lenevent1).flag]     = EEG.EVENTLIST.eventinfo.flag;
[EEG.event(1:lenevent1).bini]     = EEG.EVENTLIST.eventinfo.bini;
[EEG.event(1:lenevent1).binlabel] = EEG.EVENTLIST.eventinfo.binlabel;
[EEG.event(1:lenevent1).enable]   = EEG.EVENTLIST.eventinfo.enable;

%
% Any other custom EEG.EVENTLIST.eventinfo field
%
names  = fieldnames(EEG.EVENTLIST.eventinfo);
lename = length(names);

for i=1:lename
        if ~ismember(names{i}, {'code','codelabel', 'time', 'dura', 'binlabel','spoint', ...
                        'flag','enable','bini'})
                
                [EEG.event.(names{i})] = EEG.EVENTLIST.eventinfo(1:lenevent1).(names{i});
        end
end

[EEG serror] = sorteegeventfields(EEG);
EEG = eeg_checkset( EEG, 'eventconsistency' );
disp('EEG.event was updated.')