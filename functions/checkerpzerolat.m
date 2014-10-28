% PURPOSE: Tests whether an actual 0 (zero) latency value is part of ERP.times or not.
%         
% FORMAT:
%
% ERP = checkerpzerolat(ERP)
%
% INPUT:
%
% ERP        - ERPset
%
%
% OUTPUT:
%
% ERP        - ERPset
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

function ERP = checkerpzerolat(ERP)
if ~iserpstruct(ERP)
      fprintf('\nWARNING: checkeegzerolat() only works with ERP structure. This call was ignored.\n')
      return
end
if isfield(ERP, 'datatype')
    datatype = ERP.datatype;
else % FFT
    datatype = 'ERP';
end
if strcmpi(datatype, 'ERP')
    kktime = 1000;
else
    kktime = 1;
end
auxtimes  = ERP.times;
[v, indx] = min(abs(auxtimes));
ERP.times = auxtimes - auxtimes(indx);
ERP.xmin  = min(ERP.times)/kktime;
ERP.xmax  = max(ERP.times)/kktime;
ERP.srate = round(ERP.srate);
if ERP.times(1)~=auxtimes(1)
      msg = ['\nWarning: zero time-locked stimulus latency values were not found.\n'...
      'Therefore, ERPLAB adjusted latency values at ERP.times, ERP.xmin,and ERP.xmax.\n\n'];
      fprintf(msg);
      fprintf('Time range is now [%.3f  %.3f] sec.\n', ERP.xmin, ERP.xmax )
else
      %fprintf('Zero latencies OK.\n')
end