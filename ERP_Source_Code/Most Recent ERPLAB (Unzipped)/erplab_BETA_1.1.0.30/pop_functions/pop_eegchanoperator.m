%   >> EEG = pop_eegchanoperator(EEG, formulas)
%
%  Note: very preliminary alfa version. Only for testing purpose. May  2008
%
%  HELP PENDING for this function...
%
% Inputs:
%
%   EEG      - input dataset
%  formulas  - expression for new channel(s).
%
%  Example:
%
% >> EEG = pop_eegchanoperator(EEG, {'ch71=ch66-ch65 label HEOG', 'ch72=ch68-ch67 label VEOG'})
%
% Note: To open a GUI just write EEG = pop_eegchanoperator(EEG);
%
%
% Outputs:
%
%   EEG       - output dataset with new channels
%
% OBS: Using the GUI, you can write directly the formulas, without apostrophe, and as many as you need.
%
% ch71 = ch66 - ch65 label HEOG
% ch72 = ch68 - ch67 label=VEOG
% ch73 = 0.5*ch70 + 0.5*ch69 label LINKM
%
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

function [EEG com] = pop_eegchanoperator(EEG, formulas)
global ALLEEG
global CURRENTSET

com = '';

if nargin < 1
      help(sprintf('%s', mfilename))
      return
end

if nargin > 2
      error('ERPLAB says: pop_eegchanoperator(), too many inputs.')
end

if isempty(EEG)
      msgboxText{1} =  'cannot operate an empty ERP dataset';
      title = sprintf('ERPLAB: %s() error:', mfilename);
      errorfound(msgboxText, title)
      return
end

if isempty(EEG.data)
      msgboxText{1} =  'cannot operate an empty ERP dataset';
      title = sprintf('ERPLAB: %s() error:', mfilename);
      errorfound(msgboxText, title)
      return
end

if nargin==1
      
      answer   = chanoperGUI(EEG); %open a GUI
      
      if isempty(answer)
            disp('User selected Cancel')
            return
      end
      
      formulas = answer{1};
else
      %
      % no warnings about existing bins
      %
      erpworkingmemory('wchmsgon',0)
end

if iscell(formulas)
      formulaArray = formulas';
      opcom = 1;  % save extended command history (cell string with all equations )
else
      if isnumeric(formulas)
            error('ERPLAB says:  Error, formulas must be a cell string or a filename')
      end
      
      if strcmp(formulas,'')
            error('ERPLAB says:  Error, formulas were not found.')
      end
      
      disp(['For list of formulas, user selected  <a href="matlab: open(''' formulas ''')">' formulas '</a>'])
      
      fid_formulas = fopen( formulas );
      formulaArray = textscan(fid_formulas, '%[^\n]', 'CommentStyle','#', 'whitespace', '');
      formulaArray = strtrim(cellstr(formulaArray{:})');
      fclose(fid_formulas);
      
      if isempty(formulaArray)
            error('ERPLAB says:  Error, file was empty. No formulas were found.')
      end
      opcom = 2; % save short command history (string with the name of the file containing all equations )
end

%
% Check formulas
%
[modeoption recall conti] = checkformulas(formulaArray, mfilename);
nformulas  = length(formulaArray);

%
% Store
%
EEG_tempo = EEG;

if modeoption==1
      EEGin = EEG;
      % New EEG
      EEGout= EEG;
      EEGout.data     = [];
      EEGout.nbchan   = [];
      EEGout.chanlocs = [];
      EEGout.reject   = [];
elseif modeoption==0
      EEGin = EEG;
      EEGout= EEGin;
end

h=1;

while h<=nformulas && conti
      
      expr = formulaArray{h};
      tokcommentb  = regexpi(formulaArray{h}, '^#', 'match');  % comment
      
      if isempty(tokcommentb)
            
            [EEGout conti] = eegchanoperator(EEGin, EEGout, expr);
            
            if conti==0
                  recall = 1;
                  break
            end
            
            if isempty(EEGout)
                  error('ERPLAB says: Oops! something is wrong...')
            end
            
            if modeoption==0
                  EEGin = EEGout; % recursive
            end
      end
      
      h = h + 1;
end

if recall  && nargin==1
      EEG       = EEG_tempo;
      [EEG com] = pop_eegchanoperator(EEG); % try again...
      return
      
elseif recall && nargin==2
      msgboxText{1} =  'Error: Error at formula(s).';
      title = sprintf('ERPLAB: %s() error:', mfilename);
      errorfound(msgboxText, title);
      return
end

EEG = EEGout;

% Creates com history
if opcom==1
      com = sprintf('%s = pop_eegchanoperator( %s, { ', inputname(1), inputname(1));
      for j=1:nformulas;
            com = sprintf('%s '' %s''  ', com, formulaArray{j} );
      end;
      com = sprintf('%s });', com);
else
      com = sprintf('%s = pop_eegchanoperator( %s, ''%s'' );', inputname(1), inputname(1),...
            formulas);
end

if modeoption==1 && nargin==1
      [ALLEEG EEG CURRENTSET] = pop_newset( ALLEEG, EEG, CURRENTSET);
end

eeglab  redraw
try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
return


