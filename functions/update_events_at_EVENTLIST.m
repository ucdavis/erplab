% UNDER CONSTRUCTION
%
%
%
% PURPOSE: updates EEG.event using EEG.EVENTLIST.eventinfo information
%
% FORMAT:
%
% EVENTLIST = update_events_at_EVENTLIST(EVENTLIST);
%
% INPUTS
%
% EEG        - event list structure
%
%
% *** This function is part of ERPLAB Toolbox ***
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

function EVENTLIST = update_events_at_EVENTLIST(EVENTLIST)

EVENTLIST.eventinfo = [];

if isfield(EEG.event,'type')
        code = {EEG.event.type};
else
        code   = num2cell(NaN(1,fin));
end
if isfield(EEG.event,'binlabel')
        binlabel = {EEG.event.binlabel};
else
        binlabel   = repmat({'""'},1,fin);
end
if isfield(EEG.event, 'codelabel')
        codelabel = {EEG.event.codelabel};
else
        codelabel = repmat({'""'},1,fin);
end
if isfield(EEG.event,'latency')
        spoint  = {EEG.event.latency};
        auxtime = single(([EEG.event.latency]-1)/EEG.srate); % samples points to seconds
        time    = num2cell(auxtime);
else
        spoint  = num2cell(zeros(1,fin));
        time    = num2cell(zeros(1,fin));
end
if isfield(EEG.event,'duration')
        dura  = num2cell((round(([EEG.event.duration]/EEG.srate)*1000))); %msec
else
        dura  = num2cell(zeros(1,fin));
end
if isfield(EEG.event,'flag')
        flag  = {EEG.event.flag};
else
        flag  = num2cell(zeros(1,fin));
end
if isfield(EEG.event,'enable')
        enable = {EEG.event.enable};
else
        enable = num2cell(ones(1,fin));
end
if isfield(EEG.event,'bini')
        bini  = {EEG.event.bini};
else
        bini  = num2cell(ones(1,fin)*(-1)); %8/19/2009
end

[EVENTLIST.eventinfo(1:fin).code]      = code{:};
[EVENTLIST.eventinfo(1:fin).binlabel]  = binlabel{:};
[EVENTLIST.eventinfo(1:fin).codelabel] = codelabel{:};
[EVENTLIST.eventinfo(1:fin).time]      = time{:};
[EVENTLIST.eventinfo(1:fin).spoint]    = spoint{:};
[EVENTLIST.eventinfo(1:fin).dura]      = dura{:};
[EVENTLIST.eventinfo(1:fin).flag]      = flag{:};
[EVENTLIST.eventinfo(1:fin).enable]    = enable{:};
[EVENTLIST.eventinfo(1:fin).bini]      = bini{:};
