% PURPOSE: subroutine for pop_artflatline.m
%
% FORMAT
%
% captured = flatline(data, th, dur)
%
%   data       - row array data (1 epoch at 1 channel)
%   th         - threshold. 2 values (min max) or 1 value (So threshold will be  [-abs(th)  abs(th)]
%   dur        - flatline/blocking duration (in samples). dur <= data length
%
%
%   Outputs:
%
%   captured   - flag. 1 means data has a flatline or blocking behavior.
%
%
% See also pop_artflatline.m 
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Steven Luck
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

function captured = flatline(data, th, dur)

dy       = diff(data);
captured = 0;
n        = length(dy);
counter  = 0; % no capture

if numel(th)>2 || numel(th)==0
      error('ERPLAB says: You have to define 1 or 2 values for threshold.')
end
if numel(th)==1
      th(1) = -abs(th);
      th(2) = abs(th);
end
for i=1:n
      if dy(i)>=th(1) && dy(i)<=th(2) 
            counter = counter+1;
            if counter>= dur
                  captured = 1; % no capture
                  break
            end
      else
            counter = 0; % reset counter
      end
end