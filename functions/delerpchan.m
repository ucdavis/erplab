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

function  [ERP cherror] = delerpchan(ERP, chin)

cherror = 0;

if nargin<1
        help avgchan
        return
end
if ~iserpstruct(ERP)
        error('ERPLAB says: delerpchan() only works with ERP structure.')
end
if ischar(chin)
        chin = str2num(char(regexp(chin,'\d+','match')'))';
end
if size(chin,1)>1
        error('ERPLAB says: error, delerpchan works with row-array inputs')
end
chanarray = unique_bc2(chin);

if length(chanarray)~=length(chin)
        fprintf('\n*** WARNING: Repeated channels were ignored.\n\n')
end
nchan = ERP.nchan;
if max(chanarray)>nchan
        error('ERPLAB says: error at delerpchan. Some specified channels do not exist!')
end
ERP.bindata(chanarray,:,:)=[];
ERP.nchan = size(ERP.bindata, 1);
if isfield(ERP.chanlocs, 'labels')
        if ~isempty([ERP.chanlocs.labels])
                labaux = {ERP.chanlocs.labels};
                [labaux{chanarray}] = deal([]);
                indxl    = ~cellfun(@isempty, labaux);
                labelout = labaux(indxl);
                ERP.chanlocs = [];
                [ERP.chanlocs(1:ERP.nchan).labels] = labelout{:};
        end
end
