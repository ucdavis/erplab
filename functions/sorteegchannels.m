% PURPOSE:  re-sorts channels according to specified indices
%
% FORMAT
% 
% ERP = sorteegchannels(ERP, newindexes)
% 
% Inputs
% 
% ERP         - Averaged data structure
% newindexes  - new desired sequential order of your channels. Constraint: length(newindexes) = ERP.nchan
% 
% Outputs
% 
% ERP         - Averaged data structure, with re-sorted channels and channel info
% 
% Example 1 : Your erpset has 16 channels. You want to swap channel 7 and channel 10
% 
% ERP = sorteegchannels(ERP, [1  2  3  4  5  6  10  8  9  7  11  12  13  14  15  16])
% 
% 
% Example 2 : Totally flip your ERP channels. Your erpset has 40 channels.
% 
% ERP = sorteegchannels(ERP, 40:-1:1)
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Johanna Kreither
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2012

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

function ERP = sorteegchannels(ERP, newindexes)

nchan  = ERP.nchan;
nindex = length(newindexes);

if nchan~=nindex
        msgboxText{1} =  ['You specified ' num2str(nindex) ' channels, but your erpset has ' num2str(nchan)];
        tittle = 'ERPLAB: sorteegchannels() error:';
        errorfound(msgboxText, tittle)
        return
end

auxd = ERP.bindata(newindexes,:,:);
ERP.bindata = [];
ERP.bindata(1:nchan,:,:) = auxd;
namefields  = fieldnames(ERP.chanlocs);
nfn = length(namefields);

for ff=1:nfn
        auxfield{ff} = {ERP.chanlocs(newindexes).(namefields{ff})};
end

ERP.chanlocs=[];

for ff=1:nfn
        [ERP.chanlocs(1:nchan).(namefields{ff})] = auxfield{ff}{:};
end
disp('Your channels, and channels info were re-sorted.  ;)')
disp(';)')