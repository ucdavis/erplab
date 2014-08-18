% PURPOSE  : Creates and modifies channels using any algebraic expression (MATLAB arithmetic operators)
%            running over the channels in the current EEG structure.
%
% FORMAT   :
%
% EEG = pop_eegchanoperator( EEG, formulas );
%
%
%
% INPUTS   :
%
% EEG           - input dataset
% Formulas      - expression for new channel(s) (cell string(s)).
%                 Or expresses single string with file name containing new
%                 channel expressions
%
% OUTPUTS  :
%
% EEG           - output dataset with new/modified channels
%
%
% EXAMPLE  :
%
% EEG = pop_eegchanoperator( EEG, {'ch71=ch66-ch65 label HEOG', 'ch72=ch68-ch67 label VEOG'} ); % using formulas in a cell array
%
% or
%
% EEG = pop_eegchanoperator( EEG, 'C:\Steve\Tutorial\testlistch.txt' ); % load text file containing formulas.
%
%
% See also eegchanoperator.m chanoperGUI.m
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

function [EEG, com] = pop_eegchanoperator(EEG, formulas, varargin)
global ALLEEG
global CURRENTSET
com = '';
if nargin < 1
        help(sprintf('%s', mfilename))
        return
end
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if nargin==1
        if length(EEG)>1
                msgboxText =  'Unfortunately, this function does not work with multiple datasets';
                title = 'ERPLAB: multiple inputs';
                errorfound(msgboxText, title);
                return
        end
        if isempty(EEG)
                msgboxText =  'cannot operate an empty ERP dataset';
                title = sprintf('ERPLAB: %s() error:', mfilename);
                errorfound(msgboxText, title);
                return
        end
        if isempty(EEG.data)
                msgboxText =  'cannot operate an empty ERP dataset';
                title = sprintf('ERPLAB: %s() error:', mfilename);
                errorfound(msgboxText, title);
                return
        end
        
        def  = erpworkingmemory('pop_eegchanoperator');
        if isempty(def)
                def = { [], 1};
        end
        
        %
        % Call Gui
        %
        answer   = chanoperGUI(EEG, def);
        
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        formulas = answer{1};
        if length(answer)==1
                dch = regexpi(formulas{:}, '\s*deletechan\((.*)?\)', 'tokens','ignorecase');
                dch = str2num(char(dch{:}));
                if ~isempty(dch)
                        EEG = pop_select( EEG,'nochannel',dch);
                        com1 = sprintf('%s = pop_select( %s,''nochannel'', %s);', inputname(1),inputname(1),vect2colon(dch));
                        [EEG, com2] = pop_eegchanoperator(EEG);
                        com = sprintf('%s\n%s', com1,com2);
                        return
                end
        end
        
        wchmsgon = answer{2};
        def      = {formulas, wchmsgon};
        erpworkingmemory('pop_eegchanoperator', def);
        
        if wchmsgon==1
                wchmsgonstr = 'on';
        else
                wchmsgonstr = 'off';
        end
        
        EEG.setname = [EEG.setname '_chop'];
        
        %
        % Somersault
        %
        [EEG, com] = pop_eegchanoperator(EEG, formulas, 'Warning', wchmsgonstr, 'Saveas', 'on','ErrorMsg', 'popup', 'History', 'gui');
        return
end
% else
%         %
%         % no warnings about existing chans
%         %
%         %erpworkingmemory('wchmsgon',0)
% end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG');
p.addRequired('formulas');
% option(s)
p.addParamValue('Warning', 'off', @ischar);
p.addParamValue('Saveas', 'off', @ischar); % 'on', 'off'
p.addParamValue('ErrorMsg', 'cw', @ischar); % cw = command window
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(EEG, formulas, varargin{:});

if strcmpi(p.Results.Warning,'on')
        wchmsgon = 1;
else
        wchmsgon = 0;
end
if ismember_bc2({p.Results.Saveas}, {'on','yes'})
        issaveas  = 1;
else
        issaveas  = 0;
end
if strcmpi(p.Results.History,'implicit')
        shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
        shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
        shist = 1; % gui
else
        shist = 0; % off
end
if strcmpi(p.Results.ErrorMsg,'popup')
        errormsgtype = 1; % open popup window
else
        errormsgtype = 0; % error in red at command window
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
[modeoption, recall, conti] = checkformulas(formulaArray, mfilename);
nformulas  = length(formulaArray);

%
% Store
%
EEG_tempo = EEG;
if modeoption==1 % non-recursive
        disp('User selected non-recursive mode (independent transformations) for channel operations')
        EEGin = EEG;
        % New EEG
        EEGout= EEG;
        EEGout.data     = [];
        EEGout.nbchan   = [];
        EEGout.chanlocs = [];
        EEGout.reject   = [];
elseif modeoption==0 % recursive
        disp('User selected recursive mode for channel operations')
        EEGin = EEG;
        EEGout= EEGin;
end
h=1;
while h<=nformulas && conti
        expr = formulaArray{h};
        tokcommentb  = regexpi(formulaArray{h}, '^#', 'match');  % comment symbol     
        if isempty(tokcommentb) % skip comment symbol 
                
                %
                % subroutine
                %  
                [EEGout conti] = eegchanoperator(EEGin, EEGout, expr, wchmsgon);
                if conti==0
                        recall = 1;
                        break
                end
                if isempty(EEGout)
                        error('ERPLAB says: Oops! something was wrong...')
                end
                if modeoption==0
                        EEGin = EEGout; % recursive
                end
        end
        h = h + 1;
end
if recall  && issaveas
        EEG       = EEG_tempo;
        [EEG com] = pop_eegchanoperator(EEG); % try again...
        return
elseif recall && ~issaveas
        msgboxText =  'Error: Error at formula(s).';
        title = sprintf('ERPLAB: %s() error:', mfilename);
        errorfound(msgboxText, title);
        return
end

EEG = EEGout;

%
% History
%
skipfields = {'EEG', 'formulas', 'Saveas','History'};
fn     = fieldnames(p.Results);
if opcom==1
        com = sprintf('%s = pop_eegchanoperator( %s, { ', inputname(1), inputname(1));
        for j=1:nformulas;
                com = sprintf('%s ''%s'', ', com, formulaArray{j} );
        end
        com = sprintf('%s } ', com);
        com = regexprep(com, ',\s*}','}');
else
        com = sprintf('%s = pop_eegchanoperator( %s, ''%s'' ', inputname(1), inputname(1),...
                formulas);
end
for q=1:length(fn)
        fn2com = fn{q};
        if ~ismember_bc2(fn2com, skipfields)
                fn2res = p.Results.(fn2com);
                if ~isempty(fn2res)
                        if ischar(fn2res)
                                if ~strcmpi(fn2res,'off')
                                        com = sprintf( '%s, ''%s'', ''%s''', com, fn2com, fn2res);
                                end
                        else
                                if iscell(fn2res)
                                        if ischar([fn2res{:}])
                                                fn2resstr = sprintf('''%s'' ', fn2res{:});
                                        else
                                                fn2resstr = vect2colon(cell2mat(fn2res), 'Sort','on');
                                        end
                                        fnformat = '{%s}';
                                else
                                        fn2resstr = vect2colon(fn2res, 'Sort','on');
                                        fnformat = '%s';
                                end
                                if strcmpi(fn2com,'Criterion')
                                        if p.Results.Criterion<100
                                                com = sprintf( ['%s, ''%s'', ' fnformat], com, fn2com, fn2resstr);
                                        end
                                else
                                        com = sprintf( ['%s, ''%s'', ' fnformat], com, fn2com, fn2resstr);
                                end
                        end
                end
        end
end
com = sprintf( '%s );', com);

% get history from script. EEG
switch shist
        case 1 % from GUI
                com = sprintf('%s %% GUI: %s', com, datestr(now));
                %fprintf('%%Equivalent command:\n%s\n\n', com);
                displayEquiComERP(com);
        case 2 % from script
                EEG = erphistory(EEG, [], com, 1);
        case 3
                % implicit
        otherwise %off or none
                com = '';
end
if modeoption==1 && issaveas
        [ALLEEG, EEG, CURRENTSET] = pop_newset( ALLEEG, EEG, CURRENTSET);
end
if issaveas==1
        eeglab  redraw % only when using GUI
end

%
% Completion statement
%
msg2end
return


