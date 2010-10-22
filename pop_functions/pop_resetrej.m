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

function [EEG com]= pop_resetrej(EEG, arjm, bflag)

com ='';

if nargin<1
      help pop_resetrej
      return
end

if nargin>3
      error('ERPLAB ERROR: pop_resetrej only works with 3 inputs: EEG, arjm, flag')
end

if isempty(EEG.data)
      msgboxText{1} =  'Permission denied:';
      msgboxText{2} =  'ERROR: pop_resetrej() cannot read an empty dataset!';
      title = 'ERPLAB: pop_resetrej';
      errorfound(msgboxText, title);
      return
end

if nargin==1
      inputoption = resetrejGUI; % open GUI
      
      if isempty(inputoption)
            disp('User selected Cancel')
            return
      end
      arjm  = inputoption{1};
      bflag = inputoption{2};
else
      if nargin<3
            bflag = 0;
      end
      if nargin<2
            arjm = 1;
      end
end

if arjm
    
    %
    % resets EEGLAB's artifact rejection fields used by ERPLAB
    %
    F = fieldnames(EEG.reject);
    sfields1 = regexpi(F, '\w*E$', 'match');
    sfields2 = [sfields1{:}];
    sfields3  = regexprep(sfields2,'E','');
    arfields = [sfields2 sfields3];
    
    for j=1:length(arfields)
        EEG.reject.(arfields{j}) = [];
    end
end

if bflag>0
      
      % reset flag
      EEG = resetflag(EEG, bflag);      
end

com = sprintf('%s = pop_resetrej(%s, %s, %s);', inputname(1), inputname(1), num2str(arjm), num2str(bflag));
drawnow

try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
return
