% PURPOSE: updates marks for artifactual channels (EEG.reject)
%
% Format
%
% EEG = update_rejEfields(EEG)
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

function EEGout = update_rejEfields(EEGin,EEGout,realchanpos)
if length(realchanpos)<=1
        disp('update_rejEfields could not work')
        return
end

fprintf('Updating artifact rejection fields...')

lsch = realchanpos(1); %left side channel
rsch = realchanpos(2:end); %right side channel(s)

% create empty reject fields from the original dataset
F = fieldnames(EEGin.reject);
nF = length(F);
% for k=1:nF
%         EEGout.reject.(char(F{k})) = [];
% end

% identify reject fields for marking channels (fields ending in "E")
sfields1 = regexpi(F, '\w*E$', 'match');
sfields2 = [sfields1{:}];
% nfield = length(sfields2);

for pp =1:nF
        fieldname = char(F{pp});
        %sch = size(EEGin.reject.(fieldname),1);   % get row length
        
        if ismember_bc2({fieldname}, sfields2)      % it's an "E" field
                sch = size(EEGin.reject.(fieldname),1);   % get row length
                if sch~=0
                        % the artifact detection info for the channel at the left side of the equation is equal to a "bit-wise OR"
                        % of the artifact detection info from the channels at the right side of the equation.
                        EEGout.reject.(fieldname)(lsch,:) = ~ismember_bc2(sum(EEGin.reject.(fieldname)(rsch, :),1), 0);
                        %fprintf('EEG.reject.%s was updated.\n', fieldname)
                end
                
        else
                if ~isempty(EEGin.reject.(fieldname))
                        EEGout.reject.(fieldname) = EEGin.reject.(fieldname);
                        %fprintf('non E EEG.reject.%s was updated.\n', fieldname);
                end
        end
end
EEGout = eeg_checkset( EEGout );



% F = fieldnames(EEG.reject);
% sfields1 = regexpi(F, '\w*E$', 'match');
% sfields2 = [sfields1{:}];
% nfield = length(sfields2);
%
% for i=1:nfield
%         fieldname = char(sfields2{i});
%         sch = size(EEG.reject.(fieldname),1);   % get row length
%         if ~isempty(EEG.reject.(fieldname))
%                 if sch<EEG.nbchan
%                         nzrow = zeros(1,size(EEG.reject.(fieldname),2));
%                         EEG.reject.(fieldname) = cat(1, EEG.reject.(fieldname), nzrow);
%                 end
%         end
% end
% EEG = eeg_checkset( EEG );
% disp('EEG.reject''s fields were updated.')