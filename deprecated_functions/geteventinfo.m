% DEPRECATED...
%
%
%
% Simple function to squeeze your EEG event codes.
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

function [eventtypes histo] = squeezevents(EEG)
% Checking event's format
if ischar(EEG.event(1).type)
        allevents  = { EEG.event.type }';
        formateve = 'STRINGS';
else
        allevents  = cellstr(num2str([EEG.event.type]'));
        formateve = 'NUMERICS';
end

% Extracting event types
eventtypes = unique_bc2( allevents );

% Summary
sortevent  = sort(allevents);
[tf, indx] = ismember_bc2(eventtypes, sortevent);
histo      = diff([0 indx']);
histstr    = cellstr(num2str(histo'));
outstr     = cellstr([char(eventtypes) repmat(' = ', length(eventtypes),1) char(hs)]);

% Print info
fprintf('\n\nSUMMARY:\n\n');
fprintf('Your events are %s \n\n', formateve);
fprintf('Type %s\n', outstr{:});
