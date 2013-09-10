% ALPHA VERSION. ONLY FOR TESTING
%
% Usage:
%
% >> ERP = smootherp(ERP, spanvalue);
%
%
% Inputs:
%
% ERP          - input average (ERPLAB's) erpset
% spanvalue    - number of points used to compute each new (smoothed) sample. It must be odd
%
% Outputs:
%
% ERP          - (smoothed) erpset
%
%
% Also see: smooth.m
%
%
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

function ERP = smootherp(ERP, spanvalue)

if nargin<1
        help smootherp
        return
end
if spanvalue<0
        disp('Error smootherp(): span should be greater than zero')
        return
end

nch     = ERP.nchan;
nbin    = ERP.nbin;
dataaux = ERP.bindata.*0;

for i=1:nch
        for j=1:nbin
                %Smooth the data using the rloess methods with a span of 'spanvalue'
                %dataaux(i,:,j) = smooth(ERP.times, ERP.binavg(i,:,j),spanvalue,'rloess');
                
                %Smooth the data using a moving average filter methods
                dataaux(i,:,j) = smooth(ERP.times, ERP.bindata(i,:,j),spanvalue);
        end
end
ERP.bindata = dataaux;
