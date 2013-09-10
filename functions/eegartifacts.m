% PURPOSE: subroutine for averager.m
%          Explore artifact detection fields in EEGLAB.reject (epoch by epoch)
%          
%
% FORMAT
%
% observa = eegartifacts(reject, fields4reject, j)
%
% INPUTS
%
% reject            - EEG.reject structure
% fields4reject     - EEG.reject's fields to be explore. e.g. {'rejmanual','rejjp','rejkurt', 'rejthresh'}
% j                 - current epoch index (coming out from an external for loop)
%
% OUTPUT
%
% observa           - 1 means current epoch (j) got an artifact; 0 means good epoch.
%
%
% See also averager.m 
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
function observa = eegartifacts(reject, fields4reject, j)

% fields4reject = {'rejmanual','rejjp','rejkurt', 'rejthresh', 'rejconst',...
%         'rejfreq', 'icarejjp', 'icarejkurt', 'icarejmanual',...
%         'icarejthresh', 'icarejconst', 'icarejfreq', 'rejglobal'};

nf = length(fields4reject);
i=1;
observa = 1;

while i<=nf && observa==1
      if ~isempty(reject.(fields4reject{i}))
            observa = ~reject.(fields4reject{i})(j);
      end
      i=i+1;      
end