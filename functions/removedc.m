% PURPOSE: subroutine for basicfilter.m
%          removes data's mean value (DC offset)
%
% FORMAT:
%
% data = removedc(data, windowsam);
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

function data = removedc(data, windowsam, chanArray)
if nargin<3
    chanArray = 1:size(data,1);
end
if nargin<2
    windowsam = [1 size(data,2)];
end
if isempty(windowsam)
         error('ERPLAB says: range of value for getting the mean is empty.')
end
if isempty(chanArray)
         error('ERPLAB says: channel indices were not specified.')
end
if length(windowsam)~=2
         windowsam = [1 windowsam(1)];
end
if diff(windowsam)>size(data,2) % fixed: May 2014
    windowsam = [1 size(data,2)];
end

meanvalue = mean(data(chanArray,windowsam(1):windowsam(2)),2);
for chr=1:length(chanArray)
    data(chanArray(chr),:) = data(chanArray(chr),:) - meanvalue(chr);
end
fprintf('Channel(s) %s got removed their DC value (mean value)\n', vect2colon(chanArray))