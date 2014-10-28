% PURPOSE  : 	Clears ERPset(s)
%
% FORMAT   :
%
% >> ALLERP = pop_deleterpset( ALLERP, index);
%
% EXAMPLE  :
%
% >> ALLERP = pop_deleterpset( ALLERP, [3 5]);
%
% INPUTS   :
%
% ALLERP    - Includes all ERPsets in workspace
% Index     - ERPset(s) that you want to clear from the workspace
%
% OUTPUTS  :
%
% - updated (output) ALLERP. Will include all ERPsets, minus that deleted
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

function [ALLERP, erpcom] = pop_deleterpset(ALLERP, varargin)
erpcom = '';
if nargin<1
        help pop_deleterpset
end
if nargin==1
        try
                CURRENTERP = evalin('base', 'CURRENTERP');
        catch
                CURRENTERP = 0;
        end
        if  CURRENTERP == 0
                msgboxText =  'ERPsets menu is already empty...';
                title      =  'ERPLAB: no erpset(s)';
                errorfound(msgboxText, title);
                return
        end
        
        prompt    = {'Erpset(s) to clear:'};
        dlg_title = 'Delete erpset(s)';
        num_lines = 1;
        def = {num2str(CURRENTERP)}; %01-13-2009
        
        %
        % open window
        %
        answer = inputvalue(prompt,dlg_title,num_lines,def);
        
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        
        erpindex =  str2num(answer{1});
        nerpset  = length(ALLERP);
        erpindex = unique_bc2(erpindex);
        
        if isempty(erpindex)
                msgboxText =  'Wrong erpset index(es)';
                title      =  'ERPLAB: unrecognizable erpset(s)';
                errorfound(msgboxText, title);
                return
        end
        if max(erpindex)>nerpset || min(erpindex)<1
                erpm     = findobj('tag', 'linerp');
                nerpmenu = length(erpm);
                if max(erpindex)<=nerpmenu && nerpmenu>=1 && max(erpindex)>=1
                        %...
                else
                        msgboxText = ['Wrong erpset index(es)\n'...
                                'Check your erpset menu or write length(ALLERP) at command window for comprobation'];
                        title        =  'ERPLAB: pop_deleterpset not existing erpset(s)';
                        errorfound(sprintf(msgboxText), title);
                        return
                end
        end
        
        %
        % Somersault
        %
        [ALLERP, erpcom] = pop_deleterpset(ALLERP, 'Erpsets', erpindex, 'Saveas', 'on','History', 'gui');
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLERP');
% option(s)
p.addParamValue('Erpsets', 1); % erpset index or input file
p.addParamValue('Warning', 'off', @ischar); % history from scripting
p.addParamValue('Saveas', 'off', @ischar); % 'on', 'off'
p.addParamValue('History', 'script', @ischar); % history from scripting
p.parse(ALLERP, varargin{:});


erpindex = p.Results.Erpsets;
if strcmpi(p.Results.Warning,'on')
        warnop = 1;
else
        warnop = 0;
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
nerpset = length(ALLERP);
erpindex   = unique_bc2(erpindex);

if isempty(erpindex)
        msgboxText =  'Wrong erpset index(es)';
        error(['ERPLAB says: ' msgboxText])
end
if max(erpindex)>nerpset || min(erpindex)<1
        msgboxText = 'Wrong erpset index(es)';
        error(['ERPLAB says: ' msgboxText])
end
detect   = ~ismember_bc2(1:nerpset,erpindex);
newindex = find(detect);
if isempty(newindex)
        ALLERP = [];
else
        ALLERP = ALLERP(newindex);
end
if issaveas
        updatemenuerp(ALLERP, -1)
        assignin('base','ALLERP',ALLERP);  % save to workspace. Dec 5, 2012
end
% erpcom = sprintf('ALLERP = pop_deleterpset( ALLERP, [%s]);', num2str(erpindex));
%
% History
%
skipfields = {'ALLERP', 'History'};
fn     = fieldnames(p.Results);
erpcom = sprintf( '%s = pop_deleterpset( %s ', inputname(1), inputname(1) );
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

% get history from script. ERP
switch shist
        case 1 % from GUI
                displayEquiComERP(erpcom); 
        case 2 % from script
                for i=1:length(ALLERP)
                        ALLERP(i) = erphistory(ALLERP(i), [], erpcom, 1);
                end
        case 3
                % implicit
                
                %for i=1:length(ALLERP)
                %        ALLERP(i) = erphistory(ALLERP(i), [], erpcom, 1);
                %end
                %fprintf('%%Equivalent command:\n%s\n\n', erpcom);
        otherwise %off or none
                erpcom = '';
end

%
% Completion statement
%
msg2end
eeglab redraw
return
