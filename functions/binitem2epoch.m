% PURPOSE: search for epoch indices containing a specific event item
%
% FORMAT:
%
%  iepoch = binitem2epoch(EEG, item)
%
% Inputs:
%
%   EEG      - input dataset
%   item     - event item (according to EVENTLIST order of appearence)
%
% Output
% 
%   iepoch   - epoch index(ices) 
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2010

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

function iepoch = binitem2epoch(EEG, item)

iepoch = [];

if nargin<2
        return
end
if item<1
        return
end
if isempty(EEG)
        return
end
if isempty(EEG.epoch)
        return
end
if ~isfield(EEG, 'EVENTLIST')
        return
end
if isempty(EEG.EVENTLIST)
        return
end

nepoch = EEG.trials;

if nepoch~=length(EEG.epoch)
        error('ERPLAB says: EEG.trials & number of epochs (EEG.epoch) are not equal.')
end
for i=1:nepoch
        itemy = EEG.epoch(i).eventitem;
        if iscell(itemy)
                itemy = cell2mat(itemy);
        end
        if ~isempty(itemy)
                [tf, loc]  = ismember_bc2(item, itemy);
                if tf
                        binstored = EEG.epoch(i).eventbini{loc};
                        if sum(binstored)>0
                                iepoch = [iepoch i];
                        end
                end
        end
end