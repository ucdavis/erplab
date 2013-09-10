% PURPOSE: interface for interpolating channels using channel operations syntax
%          This function relies on EEGLAB's eeg_interp function
%
% FORMAT:
%
% EEG = chinterpol(EEG, ch);
% However syntax is chinterpol(ch) in channel operations
%
%
% INPUT:
%
% EEG/ERP          - dataset/erpset
% ch               - channel(s) to interpolate (remaining channels are used for interpolating)
%
% OUTPUT:
%
% EEG/ERP          - dataset/erpset with interpolated channel(s)
%
%
% EXAMPLE (in channel operations) interpolate channels 32 and 33
%
% EEG = pop_eegchanoperator( EEG, {'chinterpol(32 33)')'});
% ERP = pop_erpchanoperator( ERP, {'chinterpol(32 33)')'});
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
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

function EEG = chinterpol(EEG, ch)
fprintf('Working...please wait...\n')
EEG = eeg_interp(EEG, ch);
fprintf('Channel %g was interpolated using "spherical" method\n\n', ch)