% PURPOSE  : 	Clears BESTset(s) for BESTset menu
%
% FORMAT   :
%
% >> ALLBEST = pop_deletebestset( ALLBEST, index);
%
% EXAMPLE  :
%
% >> ALLBEST = pop_deletbestset( ALLBEST, [3 5]);
%
% INPUTS   :
%
% ALLERP    - Includes all BESTsets in workspace
% Index     - BESTset(s) that you want to clear from the workspace
%
% OUTPUTS  :
%
% - updated (output) ALLBEST. Will include all BESTsets, minus that deleted
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Aaron Matthew Simmons
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2023

function [ALLBEST,bestcom] = pop_deletebestset(ALLBEST, varargin)

bestcom = '';
if nargin<1
    help pop_deletebestset
end
if nargin==1
    try
        CURRENTBEST = evalin('base', 'CURRENTBEST');
    catch
        CURRENTBEST = 0;
    end
    if  CURRENTBEST == 0
        msgboxText =  'BESTsets menu is already empty...';
        title      =  'ERPLAB: no BESTset(s)';
        errorfound(msgboxText, title);
        return
    end
    
    prompt    = {'BESTset(s) to clear:'};
    dlg_title = 'Delete BESTset(s)';
    num_lines = 1;
    def = {num2str(CURRENTBEST)}; %01-13-2009
    
    %
    % open window
    %
    answer = inputvalue(prompt,dlg_title,num_lines,def);
    
    if isempty(answer)
        disp('User selected Cancel')
        return
    end
    
    bestindex =  str2num(answer{1});
    nerpset  = length(ALLBEST);
    bestindex = unique_bc2(bestindex);
    
    if isempty(bestindex)
        msgboxText =  'Wrong bestset index(es)';
        title      =  'ERPLAB: unrecognizable bestset(s)';
        errorfound(msgboxText, title);
        return
    end
    if max(bestindex)>nerpset || min(bestindex)<1
        bestm     = findobj('tag', 'linbest');
        bestmenu = length(bestm);
        if max(bestindex)<=bestmenu && bestmenu>=1 && max(bestindex)>=1
            %...
        else
            msgboxText = ['Wrong BESTset index(es)\n'...
                'Check your BESTset menu or write length(ALLBEST) at command window for comprobation'];
            title        =  'ERPLAB: pop_deletebestset not existing BESTset(s)';
            errorfound(sprintf(msgboxText), title);
            return
        end
    end
    
    %
    % Somersault
    %
    [ALLBEST] = pop_deletebestset(ALLBEST, 'BESTsets', bestindex, 'Saveas', 'on','History', 'gui');
    return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLBEST');
% option(s)
p.addParamValue('BESTsets', 1); % bestset index or input file
p.addParamValue('Warning', 'off', @ischar); % history from scripting
p.addParamValue('Saveas', 'off', @ischar); % 'on', 'off'
p.addParamValue('History', 'script', @ischar); % history from scripting
p.parse(ALLBEST, varargin{:});


bestindex = p.Results.BESTsets;
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
nerpset = length(ALLBEST);
bestindex   = unique_bc2(bestindex);

if isempty(bestindex)
    msgboxText =  'Wrong BESTset index(es)';
    error(['ERPLAB says: ' msgboxText])
end
if max(bestindex)>nerpset || min(bestindex)<1
    msgboxText = 'Wrong BESTset index(es)';
    error(['ERPLAB says: ' msgboxText])
end
detect   = ~ismember_bc2(1:nerpset,bestindex);
newindex = find(detect);
if isempty(newindex)
    ALLBEST = [];
else
    ALLBEST = ALLBEST(newindex);
end
if issaveas
    updatemenubest(ALLBEST, -1);
    assignin('base','ALLBEST',ALLBEST);  % save to workspace. Dec 5, 2012
end
% bestcom = sprintf('ALLBEST = pop_deletebestset( ALLBEST, [%s]);', num2str(erpindex));
%
% History
%
skipfields = {'ALLBEST', 'History'};
fn     = fieldnames(p.Results);
bestcom = sprintf( '%s = pop_deletebestset( %s ', inputname(1), inputname(1) );
for q=1:length(fn)
    fn2com = fn{q};
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com);
        if ~isempty(fn2res)
            if ischar(fn2res)
                if ~strcmpi(fn2res,'off')
                    bestcom = sprintf( '%s, ''%s'', ''%s''', bestcom, fn2com, fn2res);
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
                        bestcom = sprintf( ['%s, ''%s'', ' fnformat], bestcom, fn2com, fn2resstr);
                    end
                else
                    bestcom = sprintf( ['%s, ''%s'', ' fnformat], bestcom, fn2com, fn2resstr);
                end
            end
        end
    end
end
bestcom = sprintf( '%s );', bestcom);
%
% % get history from script. ERP
switch shist
    case 1 % from GUI
        displayEquiComERP(bestcom);
    case 2 % from script
        
    case 3
        fprintf('%%Equivalent command:\n%s\n\n', bestcom);
    otherwise %off or none
        bestcom = '';
end

%
% Completion statement
%
msg2end
%eeglab redraw
return
