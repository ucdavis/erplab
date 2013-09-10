% PURPOSE: gets the mean proportion of artifact detection
%
% FORMAT
%
% MPD = getardetection(ERPLAB, cw)
%
% INPUTS
%
%   ERPLAB       - epoched dataset or ERPset
%   cw           - comment on command window; 1 yes; no
%
%
% OUTPUT:
%
%   MPD          - mean proportion of artifact detection (mean of artifact detection per bin)
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

function [ERPLAB, MPD, com] = getardetection(ERPLAB, cw)
com = '';
if nargin<2
      cw = 0; % do not comment on command window
end
try
      if iseegstruct(ERPLAB)
            [xxx, MPD]  = pop_summary_AR_eeg_detection(ERPLAB, 'none'); %#ok<ASGLU>
      elseif iserpstruct(ERPLAB)
            MPD = []; % pending
      else
            MPD = [];
      end
catch
      MPD = [];
end
if cw==1
      if isempty(MPD)
            fprintf('\nCannot get the information you requested. Sorry\n\n');
      else
            fprintf('\nMean artifact detection ratio : %.1f\n\n', MPD);
      end
end
if iserpstruct(ERPLAB)
        inpnm = 'ERP';
else
        inpnm = 'EEG';
end
com = sprintf('%s, MPD = getardetection(%s, %g);', inpnm, inpnm, cw);
return
