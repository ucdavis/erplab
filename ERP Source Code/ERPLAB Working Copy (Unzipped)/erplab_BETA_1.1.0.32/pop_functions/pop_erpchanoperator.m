%   >> ERP = pop_erpchanoperator(ERP, formulas)
%
%  Note: very preliminary alfa version. Only for testing purpose. May  2008
%
%  HELP PENDING for this function...
%
% Inputs:
%
%   ERP      - input dataset
%  formulas  - expression for new channel(s).
%
%  Example:
%
% >> ERP = pop_erpchanoperator(ERP, {'ch71=ch66-ch65 label HEOG', 'ch72=ch68-ch67 label VEOG'})
%
% Note: To open a GUI just write ERP = pop_erpchanoperator(ERP);
%
%
% Outputs:
%
%   ERP       - output dataset with new channels
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

function [ERP erpcom] = pop_erpchanoperator(ERP, formulas)

erpcom = '';

if nargin < 1
      help pop_erpchanoperator
      return
end

if isempty(ERP)
      msgboxText{1} =  'cannot operate an empty ERP dataset';
      title = 'ERPLAB: pop_erpchanoperator() error:';
      errorfound(msgboxText, title);
      return
end
if isempty(ERP.bindata)
      msgboxText{1} =  'cannot operate an empty ERP dataset';
      title = 'ERPLAB: pop_erpchanoperator() error:';
      errorfound(msgboxText, title);
      return
end

if nargin==1
      
      answer = chanoperGUI(ERP) ; %open a GUI
      
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
ERP_tempo = ERP;

if modeoption==1  % new ERP
      ERPin = ERP;
      % New ERP
      ERPout = ERP;
      ERPout.bindata  = [];
      ERPout.binerror = [];
      ERPout.nchan    = [];
      ERPout.chanlocs = [];
elseif modeoption==0 % append ERP
      ERPin = ERP;
      ERPout= ERPin;
end

h=1;

while h<=nformulas && conti
      
      expr = formulaArray{h};
      tokcommentb  = regexpi(formulaArray{h}, '^#', 'match');  % comment
      
      if isempty(tokcommentb)
            
            [ERPout conti] = erpchanoperator(ERPin, ERPout, expr);
            
            if conti==0
                  recall = 1;
                  break
            end
            
            if isempty(ERPout)
                  error('Something happens...')
            end
            
            if modeoption==0
                  ERPin = ERPout; % recursive
            end
      end
      
      h = h + 1;
end

if ~isfield(ERPout, 'binerror')
      ERPout.binerror = [];
end

if recall  && nargin==1
      ERP   = ERP_tempo;
      [ERP erpcom] = pop_erpchanoperator(ERP); % try again...
      return
      
elseif recall && nargin==2
      msgboxText{1} =  'Error at formula(s).';
      title = sprintf('ERPLAB: %s() error:', mfilename);
      errorfound(msgboxText, title);
      return
end

ERP = ERPout;

if nargin<2 && modeoption==1  % only for GUI and nchan
      [ERP issave]= pop_savemyerp(ERP,'gui','erplab');
elseif nargin<2 && modeoption==0  % only for GUI and chan ---> overwrite
      [ERP issave]= pop_savemyerp(ERP, 'gui', 'erplab', 'overwriteatmenu', 'yes');
else
      issave =1;
end

if ~issave
      disp('Warning: Your ERP structure has not yet been saved')
      disp('user canceled')
end

% Creates com history
if opcom==1
      erpcom = sprintf('%s = pop_erpchanoperator( %s, { ', inputname(1), inputname(1));
      for j=1:nformulas;
            erpcom = sprintf('%s '' %s'' ', erpcom, formulaArray{j} );
      end;
      erpcom = sprintf('%s });', erpcom);
else
      erpcom = sprintf('%s = pop_erpchanoperator( %s, ''%s'' );', inputname(1), inputname(1),...
            formulas);
end

try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
return


