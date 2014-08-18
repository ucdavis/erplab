% PURPOSE: Tests congruency among ERP structure's fields.
%          For instance, third dimension's size of ERP.bindata must be equal to ERP.nbin.
%          ERP.nbin must be equal to the length of ERP.bindescr... and so on
%
%
% FORMAT:
%
% checking = checkERP(ERP)
%
% INPUT:
%
% ERP        - ERPset (ERPLAB's ERP structure)
%
%
% OUTPUT:
%
% checking   - 0 means error found; 1 means everything is ok
%
%
% See also sorterpstruct.m
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

function checking = checkERP(ERP)

try        
        a = size(ERP.bindata,3);
        b = ERP.nbin;
        c = length(ERP.bindescr);
        d = size(ERP.bindata,2);
        e = length(ERP.times);        
        if a==b && b==c && d==e                
                [ERP, serror] = sorterpstruct(ERP);                
                if serror
                        checking = 0; % error at ordering
                else
                        ERP.nchan = size(ERP.bindata,1);                           
                        
                        %
                        % save to workspace
                        %
                        assignin('base','ERP',ERP);
                        checking = 1;
                end                
        else
                checking = 0;
                disp('Error upgrading ERP structure. It contains errors!')
                return
        end        
catch
        checking = 0;
        disp('Error upgrading ERP structure. It contains errors!')
        return
end