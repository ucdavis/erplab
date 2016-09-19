% PURPOSE  : Creates and modifies channels using any algebraic expression (MATLAB arithmetic operators)
%            running over the channels in the current ERP structure.
%
% FORMAT   :
%
% ERP = pop_erpchanoperator( ERP, formulas )
%
% INPUTS   :
%
% ERP           - input ERPset
% formulas      - expression for new channel(s) (cell string(s)).
%                 Or expresses single string with file name containing new
%                 channel expressions
%
%
% OUTPUTS
%
% ERP           - output ERPset with new/modified channels
%
%
% EXAMPLE  :
%
% ERP = pop_erpchanoperator( ERP, {'ch71=ch66-ch65 label HEOG', 'ch72=ch68-ch67 label VEOG'} )
% ERP = pop_erpchanoperator( ERP, 'C:\Steve\Tutorial\testlistch.txt' ); % load text file
%
%
% See also erpchanoperator.m chanoperGUI.m
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

function [ERP, erpcom] = pop_erpchanoperator(ERP, formulas, varargin)
erpcom = '';
if nargin < 1
        help pop_erpchanoperator
        return
end
if nargin==1
        if isempty(ERP)
                ERP = preloadERP;
                if isempty(ERP)
                        msgboxText =  'No ERPset was found!';
                        title_msg  = 'ERPLAB: pop_erpchanoperator() error:';
                        errorfound(msgboxText, title_msg);
                        return
                end
        end
        if ~iserpstruct(ERP)
                msgboxText =  'Invalid ERP structure!';
                title_msg  = 'ERPLAB: pop_erpchanoperator() error:';
                errorfound(msgboxText, title_msg);
                return
        end
        if ~isfield(ERP,'bindata') %(ERP.bindata)
                msgboxText =  'Cannot work on an empty ERPset!';
                title_msg  = 'ERPLAB: pop_erpchanoperator() error:';
                errorfound(msgboxText, title_msg);
                return
        end
        if isempty(ERP.bindata) %(ERP.bindata)
                msgboxText =  'Cannot work on an empty ERPset!';
                title_msg  = 'ERPLAB: pop_erpchanoperator() error:';
                errorfound(msgboxText, title_msg);
                return
        end
        
        def  = erpworkingmemory('pop_erpchanoperator');
        if isempty(def)
                def = { [], 1};
        end
        
        %
        % Call GUI
        %
        answer = chanoperGUI(ERP, def);
        
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        formulas = answer{1};        
        wchmsgon = answer{2};
        def      = {formulas, wchmsgon};
        erpworkingmemory('pop_erpchanoperator', def);
        
        if wchmsgon==1
                wchmsgonstr = 'on';
        else
                wchmsgonstr = 'off';
        end
        
        ERP.erpname = [ERP.erpname '_chop'];
        
        %
        % Somersault
        %
        [ERP, erpcom] = pop_erpchanoperator(ERP, formulas, 'Warning', wchmsgonstr, 'Saveas', 'on','ErrorMsg', 'popup', 'History', 'gui');
        return        
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ERP');
p.addRequired('formulas');
% option(s)
p.addParamValue('Warning', 'off', @ischar);
p.addParamValue('Saveas', 'off', @ischar); % 'on', 'off'
p.addParamValue('ErrorMsg', 'cw', @ischar); % cw = command window
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ERP, formulas, varargin{:});

datatype = checkdatatype(ERP);

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
                
                %
                % subroutine
                %
                [ERPout, conti] = erpchanoperator(ERPin, ERPout, expr, wchmsgon);
                
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
if recall  && issaveas
        ERP   = ERP_tempo;
        [ERP, erpcom] = pop_erpchanoperator(ERP); % try again...
        return
elseif recall && ~issaveas
        msgboxText =  'Error at formula(s).';
        title = sprintf('ERPLAB: %s() error:', mfilename);
        errorfound(msgboxText, title);
        return
end

ERP = ERPout;
ERP.datatype = datatype; 

% % % Creates com history
% % if opcom==1
% %         erpcom = sprintf('%s = pop_erpchanoperator( %s, { ', inputname(1), inputname(1));
% %         for j=1:nformulas;
% %                 erpcom = sprintf('%s '' %s'' ', erpcom, formulaArray{j} );
% %         end;
% %         erpcom = sprintf('%s });', erpcom);
% % else
% %         erpcom = sprintf('%s = pop_erpchanoperator( %s, ''%s'' );', inputname(1), inputname(1),...
% %                 formulas);
% % end
%
% History
%
skipfields = {'ERP', 'formulas', 'Saveas', 'History'};
fn     = fieldnames(p.Results);
if opcom==1
        erpcom = sprintf('%s = pop_erpchanoperator( %s, { ', inputname(1), inputname(1));
        for j=1:nformulas;
                erpcom = sprintf('%s ''%s'', ', erpcom, formulaArray{j} );
        end
        erpcom = sprintf('%s } ', erpcom);
        erpcom = regexprep(erpcom, ',\s*}','}');
else
        erpcom = sprintf('%s = pop_erpchanoperator( %s, ''%s'' ', inputname(1), inputname(1),...
                formulas);
end
for q=1:length(fn)
        fn2com = fn{q};
        if ~ismember_bc2(fn2com, skipfields)
                fn2res = p.Results.(fn2com);
                if ~isempty(fn2res)
                        if ischar(fn2res)
                                if ~strcmpi(fn2res,'off')
                                        erpcom = sprintf( '%s, ''%s'', ''%s''', erpcom, fn2com, fn2res);
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
                                                erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
                                        end
                                else
                                        erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
                                end
                        end
                end
        end
end
erpcom = sprintf( '%s );', erpcom);
if issaveas && modeoption==1  % only for GUI and nchan (new ERP)
        [ERP, issave, erpcom_save] = pop_savemyerp(ERP,'gui','erplab', 'History', 'off');
        if issave>0
                if issave==2
                        erpcom = sprintf('%s\n%s', erpcom, erpcom_save);
                        msgwrng = '*** Your ERPset was saved on your hard drive.***';
                        mcolor = [0 0 1];
                else
                        msgwrng = '*** Warning: Your ERPset was only saved on the workspace.***';
                        mcolor = [1 0.52 0.2];
                end
        else
                ERP = ERP_tempo; % recover unmodified ERP
                msgwrng = 'ERPLAB Warning: Your changes were not saved';
                mcolor = [1 0.22 0.2];
        end
        try cprintf(mcolor, '%s\n\n', msgwrng);catch,fprintf('%s\n\n', msgwrng);end ;
elseif issaveas && modeoption==0  % overwrite current ERPset at erpset menu (no GUI)
        ERP = pop_savemyerp(ERP, 'gui', 'erplab', 'overwriteatmenu', 'yes', 'History', 'off');
        msgwrng = '*** Warning: Your ERPset was only saved on the workspace.***';
        mcolor = [1 0.52 0.2];
        try cprintf(mcolor, '%s\n\n', msgwrng);catch,fprintf('%s\n\n', msgwrng);end ;
end
% get history from script. ERP
switch shist
        case 1 % from GUI
                displayEquiComERP(erpcom);
        case 2 % from script
                ERP = erphistory(ERP, [], erpcom, 1);
        case 3
                % implicit
        otherwise %off or none
                erpcom = '';
end
%
% Completion statement
%
msg2end
return


