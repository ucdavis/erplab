% PURPOSE: compare number of channels and channel labels between 2 ERPsets.
%
% FORMAT:
%
% test = checkchannel(ERPold, ERPnew)
%
% INPUT:
%
% ERPold        - ERPset 1
% ERPnew        - ERPset 2
%
% OUTPUT:
%
% test        -  0: ok
%                1: number of channels do not match
%                2: labels of channels do not match
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

function test = checkchannel(ERPold, ERPnew)
test = 0; %ok by default
if ERPold.nchan~=ERPnew.nchan
        test = 1;
        return
end
for i=1:ERPnew.nchan
        if ~strcmp(ERPold.chanlocs(i).labels, ERPnew.chanlocs(i).labels)
                test = 2;
                return
        end
end




