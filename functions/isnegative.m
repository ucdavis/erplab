% PURPOSE:
% tf = isnegative(A) returns an array the same size as A, containing logical 1 (true)
% where the elements of A are lesser than zero, and logical 0 (false) elsewhere. 
% In set theory terms, k is 1 where A<0. Inputs A must be numerics or cell arrays of numbers.
% 
% tf = isnegative(A, 'first'), returns only the first index corresponding to the negative entries of A.
% tf = isnegative(A, 'last'), returns only the last index corresponding to the negative entries of A.
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

function [tf indx val] = isnegative(x, option)

if nargin<2
        option='all'; % 'first', 'last'
end
if nargin<1
        error('isnegative rquieres a numeric input at least. See help isnegative.')
end
if size(x,1)>1
        error('Sorry, isnegative() only work for unidimensional (row) arrays at this version.')
end
if iscell(x)
        x = cell2mat(x);
end
indx = find(x<0);
if isempty(indx)
        tf = 0;
        val = [];
        return
else
        if strcmpi(option,'all')
                tf = x*0;
                tf(indx)=1;
        elseif strcmpi(option,'first')                
                tf=1;
                indx=indx(1);
        elseif strcmpi(option,'last')                
                tf=1;
                indx=indx(end);
        end
        val = x(indx);
end


