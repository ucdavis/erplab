% PURPOSE: modifies bin label. 
%          To be used in binoperator as changebinlabel(bin, label)
%
% FORMAT:
%
% [ERP conti] = changebinlabel(ERP, b1, label)
% However syntax is changebinlabel(bin, label) in binoperator.
%
%
% INPUT:
%
% ERP        - ERPset
% bl         - bin index
% label      - new label
%
% EXAMPLE (in binoperator): change label of bin 6 for 'averaged contra'
%
% ERP = pop_binoperator( ERP, {'changebinlabel(6, 'averaged contra')'});
%
% 
% See also pop_binoperator
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

function [ERP conti] = changebinlabel(ERP, b1, label)
conti = 1;
try
        ERP.bindescr{b1} = label;
catch
        conti = 0;
end
