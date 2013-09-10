% PURPOSE: gets indices of epochs marked with artifacts
%
% FORMAT
%
% indexmepoch = detmarkedepoch(EEG);
%
% INPUTS:
%
% EEG             - epoched dataset
%
% OUTPUT
%
% indexmepoch     - indices of epochs marked with artifacts
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2011

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
function indexmepoch = detmarkedepoch(EEG) 

F = fieldnames(EEG.reject);
sfields1 = regexpi(F, '\w*E$', 'match');
sfields2 = [sfields1{:}];
fields4reject  = regexprep(sfields2,'E','');
index = zeros(1,EEG.trials);
nf = length(fields4reject);
i=1;
while i<=nf
      if ~isempty(EEG.reject.(fields4reject{i}))
            index = EEG.reject.(fields4reject{i}) | index;
      end
      i=i+1;      
end

indexmepoch = find(index); % index of marked epochs