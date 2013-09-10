% PURPOSE: subroutine for pop_eraseventcodes.m
%          Deletes all event codes that meet a logical operation (expression)
%          For instance, to deal with some spurious (and large) event codes.
%
% FORMAT:
%
% EEG = eraseventcodes(EEG, expression);
%
%
% Inputs:
%
%   ERP            - ERPset
%   expression     - logical expression (string). e.g. '==1'  or '>255' or '~41'
%
%
% Output
% 
% text file
%
%
% EXAMPLES:
%
% EEG = eraseventcodes(EEG, '==0')   % erase all 0 event codes
% EEG = eraseventcodes(EEG, '>255')  % erase all event codes greater than 255 
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

function EEG = eraseventcodes(EEG, expression)
if nargin < 1
        help eraseventcodes
        return
end

if isempty(EEG.data)
        error('ERPLAB says: errot at eraseventcodes(). Cannot work with an empty dataset')
end

if ~isempty(EEG.epoch)
        error('ERPLAB says: errot at eraseventcodes(). Only for continuous data!')
end

currcode = cell2mat({EEG.event.type});
currlate = cell2mat({EEG.event.latency});
[logic,loc]   = eval(['find(currcode' expression ')']);

currcode(loc) = [];
currlate(loc) = [];

levent = length(currcode);

if isfield(EEG.event, 'duration')
        currdura      = cell2mat({EEG.event.duration});
        currdura(loc) = [];
else
        currdura      = ones(1,levent);
end
levent = length(currcode);
EEG.event = [];

for i=1:levent
        EEG.event(i).type     = currcode(i);
        EEG.event(i).latency  = currlate(i);
        EEG.event(i).duration = currdura(i);
end

