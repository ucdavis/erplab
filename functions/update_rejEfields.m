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

function EEG = update_rejEfields(EEG)

F = fieldnames(EEG.reject);
sfields1 = regexpi(F, '\w*E$', 'match');
sfields2 = [sfields1{:}];
nfield = length(sfields2);

for i=1:nfield
        
        fieldname = char(sfields2{i});
        sch = size(EEG.reject.(fieldname),1);
        
        if ~isempty(EEG.reject.(fieldname))
                
                if sch<EEG.nbchan
                        nzrow = zeros(1,size(EEG.reject.(fieldname),2));
                        EEG.reject.(fieldname) = cat(1, EEG.reject.(fieldname), nzrow);
                end
        end
end
EEG = eeg_checkset( EEG );
disp('EEG.reject''s fields were updated.')