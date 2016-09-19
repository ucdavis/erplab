% PURPOSE  : Creates and modifies bins using any algebraic expression (MATLAB arithmetic operators)
%            running over the bins in the current ERP structure.
%
% FORMAT   :
%
% ERP = pop_binoperator(ERP, formulas);
%
% EXAMPLE  :
%
% ERP = pop_binoperator( ERP, {'b38 = b7-b8 label hot 5'});
%
%
% INPUTS   :
%
% ERP           - input ERPset
% Formulas      - expression(s) for new bin(s) (cell string(s)).
%
% OUTPUTS  :
%
% ERP           - (updated) output ERPset
%
%
% See also binoperGUI.m binoperator.m
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

function [ERP, erpcom] = pop_binoperator(ERP, formulas, varargin)
erpcom = '';
if nargin < 1
        help(sprintf('%s', mfilename))
        return
end
if nargin==1
        if isempty(ERP)
                ERP = preloadERP;
                if isempty(ERP)
                        msgboxText =  'No ERPset was found!';
                        title_msg  = 'ERPLAB: pop_binoperator() error:';
                        errorfound(msgboxText, title_msg);
                        return
                end
        end
        if ~iserpstruct(ERP)
                msgboxText =  'Invalid ERP structure!';
                title_msg  = 'ERPLAB: pop_binoperator() error:';
                errorfound(msgboxText, title_msg);
                return
        end
        if ~isfield(ERP,'bindata') %(ERP.bindata)
                msgboxText =  'Cannot work on an empty ERPset!';
                title_msg  = 'ERPLAB: pop_binoperator() error:';
                errorfound(msgboxText, title_msg);
                return
        end
        if isempty(ERP.bindata) %(ERP.bindata)
                msgboxText =  'Cannot work on an empty ERPset!';
                title_msg  = 'ERPLAB: pop_binoperator() error:';
                errorfound(msgboxText, title_msg);
                return
        end
        
        def  = erpworkingmemory('pop_binoperator');
        if isempty(def)
                def = { [], 1};
        end
        
        %
        % call GUI
        %
        answer = binoperGUI(ERP, def);
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        formulas = answer{1};
        wbmsgon  = answer{2};
        
        def = {formulas, wbmsgon};
        erpworkingmemory('pop_binoperator', def);
        
        if wbmsgon==1
                wbmsgonstr = 'on';
        else
                wbmsgonstr = 'off';
        end
        
        %
        % Somersault
        %
        [ERP, erpcom] = pop_binoperator(ERP, formulas, 'Warning', wbmsgonstr, 'ErrorMsg', 'popup', 'Saveas', 'on', 'History', 'gui');
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ERP', @isstruct);
p.addRequired('formulas');
% option(s)
p.addParamValue('Saveas', 'off', @ischar); % 'on', 'off'
p.addParamValue('Warning', 'off', @ischar);
p.addParamValue('ErrorMsg', 'cw', @ischar); % cw = command window
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ERP, formulas, varargin{:});


datatype = checkdatatype(ERP);
if ismember_bc2({p.Results.Saveas}, {'on','yes'})
        issaveas  = 1;
else
        issaveas  = 0;
end
if strcmpi(p.Results.Warning,'on')
        wbmsgon = 1;
else
        wbmsgon = 0;
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
if isempty(ERP)
        msgboxText =  'No ERPset was found!';
        if errormsgtype
                tittle = 'ERPLAB: pop_binoperator() Error';
                errorfound(msgboxText, tittle);
                return
        else
                error('prog:input', ['ERPLAB says: ' msgboxText])
        end
end
if ~iserpstruct(ERP)
        msgboxText =  'Invalid ERP structure!';
        if errormsgtype
                tittle = 'ERPLAB: pop_binoperator() Error';
                errorfound(msgboxText, tittle);
                return
        else
                error('prog:input', ['ERPLAB says: ' msgboxText])
        end
end
if ~isfield(ERP,'bindata') %(ERP.bindata)
        msgboxText =  'Cannot work on an empty ERPset!';
        if errormsgtype
                tittle = 'ERPLAB: pop_binoperator() Error';
                errorfound(msgboxText, tittle);
                return
        else
                error('prog:input', ['ERPLAB says: ' msgboxText])
        end
end
if isempty(ERP.bindata) %(ERP.bindata)
        msgboxText =  'Cannot work on an empty ERPset!';
        if errormsgtype
                tittle = 'ERPLAB: pop_binoperator() Error';
                errorfound(msgboxText, tittle);
                return
        else
                error('prog:input', ['ERPLAB says: ' msgboxText])
        end
end
if iscell(formulas)
        formulaArray = formulas';
        opcom = 1; % ---> cell array with formulas
else
        if isnumeric(formulas)
                msgboxText = 'ERPLAB says:  Error, formulas must be a cell string or a filename';
                if errormsgtype
                        tittle = 'ERPLAB: pop_binoperator() Error';
                        errorfound(msgboxText, tittle);
                        return
                else
                        error('prog:input', ['ERPLAB says: ' msgboxText])
                end
        end
        if strcmp(formulas,'')
                msgboxText = 'ERPLAB says:  Error, formulas were not found.';
                if errormsgtype
                        tittle = 'ERPLAB: pop_binoperator() Error';
                        errorfound(msgboxText, tittle);
                        return
                else
                        error('prog:input', ['ERPLAB says: ' msgboxText])
                end
        end
        
        disp(['For list of formulas, user selected  <a href="matlab: open(''' formulas ''')">' formulas '</a>'])
        fid_formulas = fopen( formulas );
        formulaArray = textscan(fid_formulas, '%[^\n]', 'CommentStyle','#', 'whitespace', '');
        formulaArray = strtrim(cellstr(formulaArray{:})');
        fclose(fid_formulas);
        
        if isempty(formulaArray)
                error('prog:input','ERPLAB says:  Error, file was empty. No formulas were found.')
        end
        opcom = 2; % ---> filename where formulas are described.
end

ERP_tempo = ERP;

%
% Check formulas
%
[option, recall, goeson] = checkformulas(formulaArray, mfilename);
nformulas  = length(formulaArray);

if recall  && issaveas
        [ERP, erpcom] = pop_binoperator(ERP); % try again...
        return
end
if option==1  % Create new ERPset (independent transformations)
        ERPin = ERP;
        % New empty ERP
        ERPout= buildERPstruct([]);
        ERPout.erpname = ERP.erpname;
        ERPout.history = ERPin.history;
else  % Modify existing ERPset (recursive updating)
        ERPin = ERP;
        ERPout= ERPin;
end

h=1;
cimode = 0; % contra ipsi mode disabled, by default
orichanlocs = [];
while h<=nformulas && goeson
        expr = formulaArray{h};
        tokcommentb  = regexpi(formulaArray{h}, '^#', 'match');  % comment
        tokprepcoip  = regexpi(formulaArray{h}, '^prepareContraIpsi', 'match');  % prepare contra ipsi command detection
        if isempty(tokcommentb) && isempty(tokprepcoip)
                
                %
                % subroutine
                %
                [ERPout, conti, cancelop] = binoperator(ERPin, ERPout, expr, wbmsgon, errormsgtype);
                
                if cancelop && issaveas
                        recall = 1;
                        break
                end
                if conti==1
                        if isempty(ERPout)
                                error('prog:input',' ERPLAB says: something is wrong...binoperator''s output is empty...')
                        end
                        if ~option  % work over the current ERP struct
                                test = checkchannel(ERPout, ERPin);
                                
                                if test==0
                                        ERPin = ERPout; % recursive
                                else
                                        if test==1
                                                bann = 'Number';
                                        else
                                                bann = 'Label';
                                        end
                                        title = 'ERPLAB: Create a new ERP';
                                        question = ['%s of channels are different for this bin!\n'...
                                                'You must save it as a new ERP.\n Please, use "nbin" sintax instead.\n\n'...
                                                ' Would you like to try again?'];
                                        button = askquest(sprintf(question, bann), title);
                                        if strcmpi(button,'yes')
                                                disp('User selected Cancel')
                                                recall = 1;
                                                break
                                        else
                                                goeson = 0;
                                        end
                                end
                        end
                end
        elseif isempty(tokcommentb) && ~isempty(tokprepcoip)
                cimode = 1; % contra ipsi mode activated
        end
        h = h + 1;
end
if ~isfield(ERPout, 'binerror')
        ERPout.binerror = [];
end
if ~goeson
        ERP = ERP_tempo; % recover unmodified ERP
        disp('Warning: Your ERP structure has not yet been saved')
        disp('user canceled')
        return
end
if recall  && issaveas
        ERP = ERP_tempo;
        [ERP, erpcom] = pop_binoperator(ERP); % try again...
        return
end
if option==1 % create new ERP
        ERPout.workfiles = ERPin.workfiles;
        ERPout.xmin      = ERPin.xmin;
        ERPout.xmax      = ERPin.xmax;
        ERPout.times     = ERPin.times;
        ERPout.pnts      = ERPin.pnts;
        ERPout.srate     = ERPin.srate;
        ERPout.isfilt    = ERPin.isfilt;
        ERPout.ref       = ERPin.ref;
        ERPout.EVENTLIST = ERPin.EVENTLIST;
end

%
% Contra ipsi reorganization of channels and data (called by 'prepareContraIpsi' at the beginning of the list of formulas)
%
if cimode
        ERPout = erp2contraipsi(ERPout, ERP);
end

%
% Completion statement
%
msg2end
ERP = ERPout;
ERP.datatype = datatype; 

%
% History
%
if opcom==1
        erpcom = sprintf('%s = pop_binoperator( %s, { ', inputname(1), inputname(1));
        for j=1:nformulas;
                erpcom = sprintf('%s ''%s'', ', erpcom, formulaArray{j} );
        end;
        erpcom = sprintf('%s });', erpcom);
        erpcom = regexprep(erpcom, ',\s*}','}');
else
        erpcom = sprintf('%s = pop_binoperator( %s, ''%s'');', inputname(1), inputname(1),...
                formulas);
end
if issaveas && option==1  % only for GUI and nbins (new ERP)
        [ERP, issave, erpcom_save] = pop_savemyerp(ERP,'gui','erplab', 'History', 'implicit');
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
elseif issaveas && option==0  % overwrite current ERPset at erpset menu (no GUI)
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
return

