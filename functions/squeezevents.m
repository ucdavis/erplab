% PURPOSE: Simple function to squeeze your EEG event codes.
%          The number of apparition of each code (eventtypes) is accumulated into a counter (histo).
%          Useful for counting a histogram of your event codes (you have to work with EEGLAB/ERPLAB of course).
%
% FORMAT:
%
% [eventtypes histo] = squeezevents(eventArray)
%
%
% Example:
%
% [eventtypes histo] = squeezevents(EEG.event)
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

function [eventtypes histo] = squeezevents(eventArray)

% Checking event's format
if ischar(eventArray(1).type)
        allevents = { eventArray.type }';
        formateve = 'STRINGS';
else
        allevents = cellstr(num2str([eventArray.type]'));
        formateve = 'NUMERICS';
end

% Extracting event types
eventtypes = unique_bc2( allevents );

% Summary
sortevent = sort(allevents);
[tf, indx] = ismember_bc2(eventtypes, sortevent);
histo     = diff([0 indx'])';
histstr   = cellstr(num2str(histo));
outstr    = cellstr([char(eventtypes) repmat(' appears ', length(eventtypes),1) char(histstr) repmat(' times ', length(eventtypes),1)]);

% Print info
fprintf('\n\nSUMMARY:\n\n');
fprintf('Your events are %s \n\n', formateve);
if strcmpi(formateve, 'strings')
      msgtxt= ['Please note: Many ERPLAB functions require numeric event codes,\n'...
            'so you should use the Advanced version of Create EventList to map each string to a numeric code.\n'];
      fprintf('%s\n', sprintf(msgtxt));
end
fprintf('Below is the number of each event types:\n\n')
fprintf('Type %s\n', outstr{:});
