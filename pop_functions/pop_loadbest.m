% PURPOSE  : 	Loads BESTset(s)
%
% FORMAT   :
%
% ERP = pop_loadbest(parameters);
%
% PARAMETERS     :
%
% 'filename'        - BESTset filename
% 'filepath'        - BESTset's filepath
% 'overwrite'       - overwrite current erpset. 'on'/'off' *Not working
% 'Warning'         - 'on'/'off'
% 'multiload'       - load multiple BESTset using a single output variable (see example 2). 'on'/'off'
% 'UpdateMainGui'   - 'on'/'off'
%
%
% OUTPUTS  :
%
% BEST	- output BESTset

function [BEST, ALLBEST] = pop_loadbest(varargin)
BEST = preloadBEST; 
try 
    ALLBEST = evalin('base', 'ALLBEST');
    preindex = length(ALLBEST); 
    
catch 
    disp('WARNING: ALLBEST structure was not found. ERPLAB will create an empty one.')
    ALLBEST = [];
    %ALLERP   = buildERPstruct([]);
    preindex = 0;

end

if nargin <1 
    help pop_loadbest
    
    return
    
end


if nargin == 1
        filename = varargin{1};
        if strcmpi(filename,'workspace')
                filepath = '';
        else
                if isempty(filename)
                        [filename, filepath] = uigetfile({'*.best','BEST (*.best)'},...
                                'Load BEST','MultiSelect', 'on');
                        if isequal(filename,0)
                                disp('User selected Cancel')
                                return
                        end
                        
                        %
                        % test current directory
                        %
                        %changecd(filepath) % Steve does not like this...
                else
                        filepath = cd;
                end
        end
        
        %
        % Somersault
        %
        
        [BEST, ALLBEST] = pop_loadbest('filename', filename, 'filepath', filepath, 'Warning', 'on', 'UpdateMainGui', 'on', 'multiload', 'off');
        return
    
    
    
end


% parsing inputs
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
% option(s)
p.addParamValue('filename', '');
p.addParamValue('filepath', '', @ischar);
p.addParamValue('overwrite', 'off', @ischar);
p.addParamValue('Warning', 'off', @ischar);
p.addParamValue('multiload', 'off', @ischar); % ERP stores ALLERP's contain (ERP = ...), otherwise [ERP ALLERP] = ... must to be specified.
p.addParamValue('UpdateMainGui', 'off', @ischar);
%p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(varargin{:});

filename = strtrim(p.Results.filename);
filepath = strtrim(p.Results.filepath);

if strcmpi(filename,'workspace')
        filepath = '';
        nfile = 1;
        loadfrom = 0;  % load from workspace
else
        loadfrom = 1; % load from: 1=hard drive; 0=workspace
end

if strcmpi(p.Results.Warning,'on')
        popupwin = 1;
else
        popupwin = 0;
end
if strcmpi(p.Results.UpdateMainGui,'on')
        updatemaingui = 1;
else
        updatemaingui = 0;
end
if strcmpi(p.Results.multiload,'on')
        multiload = 1;
else
        multiload = 0;
end

if loadfrom==1
        if iscell(filename)
                nfile      = length(filename);
                inputfname = filename;
        else
                nfile = 1;
                inputfname = {filename};
        end
else
        inputfname = {'workspace'};
end


inputpath = filepath;
errorf    = 0; % no error found, by default
conti     = 1; % continue?  1=yes; 0=no
% if strcmpi(p.Results.overwrite,'on')||strcmpi(p.Results.overwrite,'yes')
%     ovatmenu = 1;
% else
%     ovatmenu = 0;
% end


for i=1:nfile
        if loadfrom==1
            fullname = fullfile(inputpath, inputfname{i});
            fprintf('Loading %s\n', fullname);
            L   = load(fullname, '-mat');
            BEST = L.BEST; 
%             if i == 1
%                 BEST = L.BEST;
%             else
%                 BEST(i) = L.BEST;
%             end
        else
            BEST = evalin('base', 'BEST');
        end
        
        %
        % Skipping all "checking" features for now
        % - see pop_loaderp() for "checking ERP" routine
        %
        
        if i == 1 && isempty(ALLBEST) 
           ALLBEST = BEST;  
           
        else
           ALLBEST(i+preindex) = BEST; 
            
            
        end
        
        
end

if conti==0
        return
end

if nargout==1 && multiload==1
        BEST = ALLBEST;
end

if nfile==1
        outv = 'BEST';
else
        outv = '[BEST ALLBEST]';
end





%% see line 280 in pop_loaderp
if updatemaingui % update erpset menu at main gui
    assignin('base','ALLBEST',ALLBEST);  % save to workspace
    updatemenubest(ALLBEST); % add a new bestset to the bestset menu
end
% fn         = fieldnames(p.Results);
% erpcom     = sprintf( '%s = pop_loaderp(', outv);
% skipfields = {'UpdateMainGui', 'Warning','History'};

% for q=1:length(fn)
%     fn2com = fn{q};
%     if ~ismember_bc2(fn2com, skipfields)
%         fn2res = p.Results.(fn2com);
%         if iscell(fn2res) % 10-21-11
%             nc = length(fn2res);
%             xfn2res = sprintf('{''%s''', fn2res{1} );
%             for f=2:nc
%                 xfn2res = sprintf('%s, ''%s''', xfn2res, fn2res{f} );
%             end
%             fn2res = sprintf('%s}', xfn2res);
%         else
%             if ~strcmpi(fn2res,'off') %&& ~strcmpi(fn2res,'on')
%                 fn2res = ['''' fn2res ''''];
%             end
%         end
%         if ~isempty(fn2res)
%             if ischar(fn2res)
%                 if ~strcmpi(fn2res,'off')
%                     if q==1
%                         erpcom = sprintf( '%s ''%s'', %s', erpcom, fn2com, fn2res);
%                     else
%                         erpcom = sprintf( '%s, ''%s'', %s', erpcom, fn2com, fn2res);
%                     end
%                 end
%             else
%                 erpcom = sprintf( '%s, ''%s'', %s', erpcom, fn2com, vect2colon(fn2res,'Repeat','on'));
%             end
%         end
%     end
% end

prefunc = dbstack;
nf = length(unique_bc2({prefunc.name}));
if nf==1
        msg2end
end


return