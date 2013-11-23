% ALPHA VERSION
% PURPOSE: get mean global field power from an ERP
%
% FORMAT
%
% MGFP = mgfperp(ERP, selch)
%
% inputs:
%
% ERP           - ERP structure
% selch         - array containing included channels
%
% output:
%
% MGFP  = row array containing MGFP
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

function MGFP = mgfperp(ERP, selch)

if nargin<1
        help mgfperp
        return
end
if ~iserpstruct(ERP)
        error('ERPLAB says: Your data structure is not an ERP structure!')
end
if nargin<2
        selch = 1:ERP.nchan;
end

nchan = ERP.nchan;
nbin  = ERP.nbin;

if ischar(selch)
        selch = str2num(char(regexp(selch,'\d+','match')'))';
end
if max(selch)>nchan
        error('ERPLAB says: Some specified channels do not exist!')
end

selchannels = unique_bc2(selch);

if length(selchannels)~=length(selch)
        fprintf('\n*** WARNING: Repeated channels were ignored.\n\n')
end

nsch = length(selchannels);
bindata(1:nsch,:,:) = ERP.bindata(selchannels,:,:);

for j=1:nbin
        MGFP_data   = std(bindata(:,:,j));
        MGFP(1,:,j) = MGFP_data;
end

fprintf('Mean Global Field Power (MGFP) was assessed using channels: \n');

for j=1:nsch
        fprintf('%s - ', char(ERP.chanlocs(selchannels(j)).labels));
end
fprintf('\n');