% Savitzky-Golay smoothing filters
% (also called digital smoothing polynomial filters or least-squares smoothing filters)
% are typically used to "smooth out" a noisy signal whose frequency span (without noise) is large.
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
function ERP = smootherp2(ERP, points)

% fprintf('smootherp.m : START\n');

if spanvalue<0
        disp('Error smootherp(): span should be greater than zero')
        return
end
nbin    = ERP.nbin;
dataaux = ERP.bindata.*0;

for j=1:nbin
        
        dataaux(:,:,j) = sgolayfilt(ERP.times, ERP.bindata(:,:,j)',3,points)';   % Apply 3rd-order filter
end
ERP.bindata = dataaux;  % for now
