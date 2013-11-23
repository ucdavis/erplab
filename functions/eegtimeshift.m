% PURPOSE: allows to adjust the EEG's time values in a safe way. For instance, taking care that
%          the zero value latency was moved without changing its "zeroness"
%
% FORMAT
%
% EEG = eegtimeshift(EEG, movetime)
%
% INPUT:
%
% EEG         - dataset
% movetime    - time in msec. If movetime is positive, the EEG's time values are shifted to the right (e.g. increasing delay).
%               If movetime is negative, the EEG's time values are shifted to the left (e.g decreasing delay).
%               If movetime is 0, the EEG's time values are not shifted.
% 
% 
% OUTPUT:
%
% EEG         - dataset with latency shift.
%
%
% See also erptimeshift.m
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Johanna Kreither
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

function EEG = eegtimeshift(EEG, movetime)

fulltime = (EEG.xmax-EEG.xmin)*1000;

if movetime>fulltime
      error(['ERPLAB says: errot at eegtimeshift(). You cannot shift time values more than ' num2str(fulltime) ' ms!'])
end

A = EEG.times';
deltatime   = mean(unique_bc2(diff(A)));

if movetime>0      
      Bpre  = min(A)-length(A)*deltatime:deltatime:min(A)-deltatime;
      B     = cat(1,Bpre', A);
      shiftmove = round(movetime/deltatime);
      C     = circshift(B, shiftmove)';
      times = C(end-length(A)+1:end);      
elseif movetime<0
      Bpost  = max(A)+deltatime:deltatime:max(A)+length(A)*deltatime;
      B     = cat(1, A, Bpost');
      shiftmove = round(movetime/deltatime);
      C     = circshift(B, shiftmove)';
      times = C(1:length(A));
else
      return
end

zerocatch = find(times==0, 1);

if isempty(zerocatch)
      error('ERPLAB says: errot at eegtimeshift(). You threw away the zero latency!!!')
end

EEG.times = times;
EEG.xmax  = max(times)/1000;
EEG.xmin  = min(times)/1000;




