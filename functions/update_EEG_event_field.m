% PURPOSE: updates EEG.event using EEG.EVENTLIST.eventinfo information
%
% FORMAT:
%
% EEG = update_EEG_event_field(EEG, ELfield)
%
% INPUTS
%
% EEG                - dataset
% ELfield            - string 'code', 'codelabel', or 'binlabel'
% EEGfield           - string 'type' (recommended)
% removenctype       - 1 means remove remaining codes; 0 means keep them
%
%
% *** This function is part of ERPLAB Toolbox ***
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

function EEG = update_EEG_event_field(EEG, ELfield, EEGfield, removenctype)
if nargin<4
        % removenctype means "remove non-captured event codes"
        removenctype = 0; % 1 means "yes"; 0 means "no" {default}
end
if nargin<3
        % ELfield means subfield at EEG.EVENTLIST.eventinfo
        EEGfield = 'type'; % EEG.event's subfield, by default
end
%
% Replaces EEG.event.type field by EEG.EVENTLIST.eventinfo.binlabel
%
lenevent1    = length(EEG.EVENTLIST.eventinfo);
% lenevent2    = length(EEG.event);
indxeventin  = 1:lenevent1;
indxeventout = indxeventin;

%if (lenevent1 ~= lenevent2)
%        fprintf('WARNING: Lengths of EEG.event and EEG.EVENTLIST.eveninfo are different.\n')
%        fprintf('Therefore, EEG.event will be deleted, and then rebuilt with the EEG.EVENTLIST.eveninfo values.\n')
        EEG = rmfield(EEG,'event');
%end
if strcmpi(ELfield, 'bini')
        auxbini = cell(1);
        for k=indxeventin
                auxbini{k} = EEG.EVENTLIST.eventinfo(k).bini(1); % only takes the first bin in bini
        end
        
        %
        % Replace bini into EEG.event.(EEGfield)
        % (in this version it takes the first assigned, so no multiple bin assignment is allowed, and moves into EEG.event.type)
        %
        if removenctype               
                %actualbin   = cell2mat(cellfun(@(x) x(x>0), auxbini, 'UniformOutput', false));
                ab = cellfun(@(x) x(x>0), auxbini, 'UniformOutput', false);
                actualbin   = find(~cellfun(@isempty, ab));
                indxeventin = 1:length(actualbin);
                [EEG.event(indxeventin).(EEGfield)] = auxbini{actualbin};
                indxeventout = actualbin;
        else
                [EEG.event(indxeventin).(EEGfield)] = auxbini{:};
                maskpbin =  [EEG.event(indxeventin).(EEGfield)]==-1;
                [EEG.event(maskpbin).(EEGfield)] = EEG.EVENTLIST.eventinfo(maskpbin).code;
        end
else
        %
        % Replace bini into EEG.event.(EEGfield)
        %
        [EEG.event(indxeventin).(EEGfield)] = EEG.EVENTLIST.eventinfo.(ELfield);
        
        %
        % In case there is not full replacement (fills up empty "event codes")
        %
        if ischar(EEG.event(1).(EEGfield))
                if removenctype                       
                        posquo = find(~ismember_bc2({EEG.event.(EEGfield)},'""'));
                        indxeventin = 1:length(posquo);
                        EEG.event   = rmfield(EEG.event, EEGfield);
                        [EEG.event(indxeventin).(EEGfield)] = EEG.EVENTLIST.eventinfo(posquo).(ELfield);
                        indxeventout = posquo;
                else
                        posquo = find(ismember_bc2({EEG.event.(EEGfield)},'""'));
                        [EEG.event(posquo).(EEGfield)] = EEG.EVENTLIST.eventinfo(posquo).code;
                end
        else
                if removenctype                       
                        posquo = find(~isnan([EEG.event.(EEGfield)]));
                        indxeventin = 1:length(posquo);
                        EEG.event   = rmfield(EEG.event, EEGfield);
                        [EEG.event(indxeventin).(EEGfield)] = EEG.EVENTLIST.eventinfo(posquo).(ELfield);
                        indxeventout = posquo;
                else
                        posquo = find(isnan([EEG.event.(EEGfield)]));
                        [EEG.event(posquo).(EEGfield)] = EEG.EVENTLIST.eventinfo(posquo).codelabel;
                end
        end
end

%
% complete remaining fields
%
[EEG.event(indxeventin).codelabel] = EEG.EVENTLIST.eventinfo(indxeventout).codelabel;
% updating latency is mandatory!
[EEG.event(indxeventin).latency]  = EEG.EVENTLIST.eventinfo(indxeventout).spoint;
[EEG.event(indxeventin).duration] = EEG.EVENTLIST.eventinfo(indxeventout).dura;
[EEG.event(indxeventin).flag]     = EEG.EVENTLIST.eventinfo(indxeventout).flag;
[EEG.event(indxeventin).bini]     = EEG.EVENTLIST.eventinfo(indxeventout).bini;
[EEG.event(indxeventin).binlabel] = EEG.EVENTLIST.eventinfo(indxeventout).binlabel;
[EEG.event(indxeventin).enable]   = EEG.EVENTLIST.eventinfo(indxeventout).enable;

%
% Any other custom EEG.EVENTLIST.eventinfo field
%
names  = fieldnames(EEG.EVENTLIST.eventinfo);
lename = length(names);

for k=1:lename
        if ~ismember_bc2(names{k}, {'code','codelabel', 'time', 'dura', 'binlabel','spoint', ...
                        'flag','enable','bini'})
                [EEG.event(indxeventin).(names{k})] = EEG.EVENTLIST.eventinfo(indxeventout).(names{k});
        end
end

EEG = sorteegeventfields(EEG);
EEG = eeg_checkset( EEG, 'eventconsistency' );
disp('EEG.event was updated.')