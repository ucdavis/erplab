% PURPOSE  : 	Clears MVPCset(s) from MVPC menu
%
% FORMAT   :
%
% >> ALLMVPC = pop_deletemvpc( ALLMVPC, index);
%
% EXAMPLE  :
%
% >> ALLMVPC = pop_deletbestset( ALLMVPC, [3 5]);
%
% INPUTS   :
%
% ALLERP    - Includes all MVPCsets in workspace
% Index     - MVPCset(s) that you want to clear from the workspace
%
% OUTPUTS  :
%
% - updated (output) ALLMVPC. Will include all MVPCsets, minus that deleted
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Aaron Matthew Simmons
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2023

function [ALLMVPC] = pop_deletemvpcset(ALLMVPC, varargin)

%erpcom = '';
if nargin<1
        help pop_deletemvpcset
end
if nargin==1
        try
                CURRENTMVPC = evalin('base', 'CURRENTMVPC');
        catch
                CURRENTMVPC = 0;
        end
        if  CURRENTMVPC == 0
                msgboxText =  'MVPCsets menu is already empty...';
                title      =  'ERPLAB: no MVPCset(s)';
                errorfound(msgboxText, title);
                return
        end
        
        prompt    = {'MVPCset(s) to clear:'};
        dlg_title = 'Delete MVPCset(s)';
        num_lines = 1;
        def = {num2str(CURRENTMVPC)}; %01-13-2009
        
        %
        % open window
        %
        answer = inputvalue(prompt,dlg_title,num_lines,def);
        
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        
        mvpcindex = str2num(answer{1});
        nmvpcset  = length(ALLMVPC);
        mvpcindex = unique_bc2(mvpcindex);
        
        if isempty(mvpcindex)
                msgboxText =  'Wrong MVPCset index(es)';
                title      =  'ERPLAB: unrecognizable MVPCset(s)';
                errorfound(msgboxText, title);
                return
        end
        if max(mvpcindex)>nmvpcset || min(mvpcindex)<1
                mvpcm     = findobj('tag', 'linmvpc');
                mvpcmenu = length(mvpcm);
                if max(mvpcindex)<=mvpcmenu && mvpcmenu>=1 && max(mvpcindex)>=1
                        %...
                else
                        msgboxText = ['Wrong MVPCset index(es)\n'...
                                'Check your MVPCset menu or write length(ALLMVPC) at command window for comprobation'];
                        title        =  'ERPLAB: pop_deletemvpcset not existing MVPCset(s)';
                        errorfound(sprintf(msgboxText), title);
                        return
                end
        end
        
        %
        % Somersault
        %
        [ALLMVPC] = pop_deletemvpcset(ALLMVPC, 'MVPCsets', mvpcindex, 'Saveas', 'on','History', 'gui');
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLMVPC');
% option(s)
p.addParamValue('MVPCsets', 1); % bestset index or input file
p.addParamValue('Warning', 'off', @ischar); % history from scripting
p.addParamValue('Saveas', 'off', @ischar); % 'on', 'off'
p.addParamValue('History', 'script', @ischar); % history from scripting
p.parse(ALLMVPC, varargin{:});


mvpcindex = p.Results.MVPCsets;
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
nmvpcset = length(ALLMVPC);
mvpcindex   = unique_bc2(mvpcindex);

if isempty(mvpcindex)
        msgboxText =  'Wrong MVPCset index(es)';
        error(['ERPLAB says: ' msgboxText])
end
if max(mvpcindex)>nmvpcset || min(mvpcindex)<1
        msgboxText = 'Wrong MVPCset index(es)';
        error(['ERPLAB says: ' msgboxText])
end
detect   = ~ismember_bc2(1:nmvpcset,mvpcindex);
newindex = find(detect);
if isempty(newindex)
        ALLMVPC = [];
else
        ALLMVPC = ALLMVPC(newindex);
end
if issaveas
        updatemenumvpc(ALLMVPC, -1);
        assignin('base','ALLMVPC',ALLMVPC);  % save to workspace. Dec 5, 2012
end
% erpcom = sprintf('ALLERP = pop_deleterpset( ALLERP, [%s]);', num2str(erpindex));
%
% History
%
% skipfields = {'ALLERP', 'History'};
% fn     = fieldnames(p.Results);
% erpcom = sprintf( '%s = pop_deleterpset( %s ', inputname(1), inputname(1) );
% for q=1:length(fn)
%         fn2com = fn{q};
%         if ~ismember_bc2(fn2com, skipfields)
%                 fn2res = p.Results.(fn2com);
%                 if ~isempty(fn2res)
%                         if ischar(fn2res)
%                                 if ~strcmpi(fn2res,'off')
%                                         erpcom = sprintf( '%s, ''%s'', ''%s''', erpcom, fn2com, fn2res);
%                                 end
%                         else
%                                 if iscell(fn2res)
%                                         if ischar([fn2res{:}])
%                                                 fn2resstr = sprintf('''%s'' ', fn2res{:});
%                                         else
%                                                 fn2resstr = vect2colon(cell2mat(fn2res), 'Sort','on');
%                                         end
%                                         fnformat = '{%s}';
%                                 else
%                                         fn2resstr = vect2colon(fn2res, 'Sort','on');
%                                         fnformat = '%s';
%                                 end
%                                 if strcmpi(fn2com,'Criterion')
%                                         if p.Results.Criterion<100
%                                                 erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
%                                         end
%                                 else
%                                         erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
%                                 end
%                         end
%                 end
%         end
% end
% erpcom = sprintf( '%s );', erpcom);
% 
% % get history from script. ERP
% switch shist
%         case 1 % from GUI
%                 displayEquiComERP(erpcom); 
%         case 2 % from script
%                 for i=1:length(ALLBEST)
%                         ALLBEST(i) = erphistory(ALLBEST(i), [], erpcom, 1);
%                 end
%         case 3
%                 % implicit
%                 
%                 %for i=1:length(ALLERP)
%                 %        ALLERP(i) = erphistory(ALLERP(i), [], erpcom, 1);
%                 %end
%                 %fprintf('%%Equivalent command:\n%s\n\n', erpcom);
%         otherwise %off or none
%                 erpcom = '';
% end

%
% Completion statement
%
msg2end
%eeglab redraw
return
