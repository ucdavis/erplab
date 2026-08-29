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

porder = 3;   % polynomial order of the filter

if points<0
        disp('Error smootherp2(): span should be greater than zero')
        return
end
if mod(points,2)==0
        points = points+1;   % sgolayfilt needs an odd frame length
        fprintf('smootherp2(): span must be odd. Using %d points instead.\n', points);
end
if points<=porder
        fprintf('Error smootherp2(): span must be greater than %d for a %dth-order fit.\n', porder, porder);
        return
end
if points>ERP.pnts
        fprintf('Error smootherp2(): span (%d) cannot exceed the number of time points (%d).\n', points, ERP.pnts);
        return
end

nbin    = ERP.nbin;
dataaux = ERP.bindata.*0;

for j=1:nbin
        % sgolayfilt works down the columns, so transpose to put time in rows
        dataaux(:,:,j) = sgolayfilt(ERP.bindata(:,:,j)', porder, points)';
end
ERP.bindata = dataaux;
