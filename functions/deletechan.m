% PURPOSE: to be used in channel operation only (ALPHA VERSION)
%
% FORMAT (in channel operation)
%
% deletechan(ch)
%
% INPUT
%
% ch    - channel index(ices) to be deleted
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

function  [ERPLAB cherror] = deletechan(ERPLAB, chin)

cherror = 0;

if nargin<1
        help avgchan
        return
end
if ischar(chin)
        chin = str2num(char(regexp(chin,'\d+','match')'))';
end
if size(chin,1)>1
        error('ERPLAB says: error, deletechan works with row-array inputs')
end

chanarray = unique_bc2(chin);

if length(chanarray)~=length(chin)
        fprintf('\n*** WARNING: Repeated channels were ignored.\n\n')
end

nchan2avg  = length(chanarray);

if iserpstruct(ERPLAB)
        nchan = ERPLAB.nchan;
else
        nchan = ERPLAB.nbchan;
end
if max(nchan2avg)>nchan
        error('ERPLAB says: Some specified channels do not exist!')
end
if iserpstruct(ERPLAB)
        datach = ERPLAB.bindata(chanarray,:,:);
else
        datach = ERPLAB.data(chanarray,:,:);
end

d = mean(datach, 1);