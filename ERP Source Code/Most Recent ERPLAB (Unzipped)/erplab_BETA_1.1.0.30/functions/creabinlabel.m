% function EEG = code2bin(EEG, keeptype)
%
% Converts captured numeric event codes into BinLabel
%
%  Note: very preliminary alfa version. Only for testing purpose. May  2008
%
%  HELP PENDING for this function
%  Write erplab at workspace for help
%
% Inputs:
%
%   EEG       - input dataset
% keeptype    - 1 = keeps unmatched event codes in EEG.event.type after code2bin
%               convertion.
%             - 0 = delete unmatched event codes.
%
%
% Outputs:
%
%   EEG       - output dataset
%
% See bin2code
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

function EEG = creabinlabel(EEG)

fprintf('creabinlabel.m : START\n');

if ~isfield(EEG,'EVENTLIST')
        disp('Error creabinlabel.m : You should create an EventList before perform numcode2binlabel')
        fprintf('creabinlabel.m : CANCELLED\n');
        return
end
if isempty(EEG.EVENTLIST)
        disp('Error creabinlabel.m : You should create an EventList before perform numcode2binlabel')
        fprintf('creabinlabel.m : CANCELLED\n');
        return
end

if ischar(EEG.EVENTLIST.eventinfo(1).code) %|| ischar(EEG.event(1).type)
        error('ERPLAB ERROR: EEG.EVENTLIST.eventinfo.code must to be NUMERIC!')
end

levent = length(EEG.EVENTLIST.eventinfo);

if ~isfield(EEG.EVENTLIST.eventinfo,'dura')
        dura  = num2cell(zeros(1,levent));
        [EEG.EVENTLIST.eventinfo(1:levent).dura] = dura{:};
end

if ~isfield(EEG.EVENTLIST.eventinfo,'binlabel')
        binlabel   = repmat({'""'},1,levent);
        [EEG.EVENTLIST.eventinfo(1:levent).binlabel] = binlabel{:};
end

%
% write bins instead types
%
for i=1:levent
        if ~ismember(-1,EEG.EVENTLIST.eventinfo(i).bini) && ~isempty(EEG.EVENTLIST.eventinfo(i).bini)
                
                auxname = num2str(EEG.EVENTLIST.eventinfo(i).bini);
                bname   = regexprep(auxname, '\s+', ',', 'ignorecase'); % insterts a comma instead blank space
                
                if strcmp(EEG.EVENTLIST.eventinfo(i).codelabel,'""')
                        binName = ['B' bname '(' num2str(EEG.EVENTLIST.eventinfo(i).code) ')']; %B#(code)
                else
                        binName = ['B' bname '(' EEG.EVENTLIST.eventinfo(i).codelabel ')']; %B#(codelabel)
                end
                EEG.EVENTLIST.eventinfo(i).binlabel    = binName;
        end
end

fprintf('creabinlabel.m : END\n');