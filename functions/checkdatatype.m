% PURPOSE   :   Datatype check
% Checking the datatype in a consistent function makes later changes easier
% axs 19-Sep-2016
%
% FORMAT:
% datatype_string = checkdatatype(ERP)
%
% INPUT:
% ERP structure
%
% OUTPUT:
% datatype      -  A string specifying the datatype
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Andrew X Stewart
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

function datatype = checkdatatype(ERP)



if isfield(ERP,'datatype')
    if strcmpi(ERP.datatype(end-2:end),'FFT')     % power-like FFT, EFFT or TFFT
        datatype = ERP.datatype;  %
        
    elseif strcmpi(ERP.datatype, 'ERP') || strcmpi(ERP.datatype, 'CSD')
        datatype = 'ERP';                % ERP-like ERP or CSD
        
    else
        datatype = 'ERP';                 % if unknown, try treating like ERP for now
    end
else
    datatype = 'ERP';                 % if unstated, try treating like ERP for now
end
end