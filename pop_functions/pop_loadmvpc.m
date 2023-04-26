function [MVPC, ALLMVPC] = pop_loadmvpc(varargin)

try 
    ALLMVPC = evalin('base', 'ALLMVPC');
    preindex = length(ALLMVPC); 
    
catch 
    disp('WARNING: ALLMVPC structure was not found. ERPLAB will create an empty one.')
    ALLMVPC = [];
    %ALLERP   = buildERPstruct([]);
    preindex = 0;

end

if nargin <1 
    help pop_loadmvpc
    
    return
    
end

if nargin == 1
        filename = varargin{1};
        if strcmpi(filename,'workspace') || strcmpi(filename,'decodingtoolbox')
                filepath = '';
        else
                if isempty(filename)
                        [filename, filepath] = uigetfile({'*.mvpc','MVPC (*.mvpc)'},...
                                'Load MVPC','MultiSelect', 'on');
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
        
        [MVPC, ALLMVPC] = pop_loadmvpc('filename', filename, 'filepath', filepath, 'Warning', 'on', 'UpdateMainGui', 'on', 'multiload', 'off');
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
elseif strcmpi(filename,'decodingtoolbox')
        filepath = '';
        ALLMVPC2 = evalin('base', 'ALLMVPC2');
        nfile = length(ALLMVPC2);
        preindex = length(ALLMVPC2); 
        loadfrom = 2;  % load from workspace
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
    if strcmpi(filename,'workspace')
        inputfname = {'workspace'};
    else
        inputfname = {'workspace'};
    end
end

inputpath = filepath;
errorf    = 0; % no error found, by default
conti     = 1; % continue?  1=yes; 0=no

if loadfrom == 1 || loadfrom == 0
    for i=1:nfile
        if loadfrom==1
            fullname = fullfile(inputpath, inputfname{i});
            fprintf('Loading %s\n', fullname);
            L   = load(fullname, '-mat');
            MVPC = L.MVPC;
            %             if i == 1
            %                 BEST = L.BEST;
            %             else
            %                 BEST(i) = L.BEST;
            %             end
        else
            MVPC = evalin('base', 'MVPC');

        end


        if i == 1 && isempty(ALLMVPC)
            ALLMVPC = MVPC;

        else
            ALLMVPC(i+preindex) = MVPC;

        end

    end
elseif loadfrom == 2
    % if loaded from GUI decoding toolbox

    if isempty(ALLMVPC)
        ALLMVPC = ALLMVPC2;
    else

        for i=1:nfile
            ALLMVPC(preindex + 1 ) = ALLMVPC2(i);
        end

    end


end

if nargout==1 && multiload==1

        MVPC = ALLMVPC(end);
end

if nfile==1
        outv = 'MVPC';
else
        outv = '[MVPC ALLMVPC]';
end

if exist("ALLMVPC2")
    %clear from base 
    evalin('base', 'clear ALLMVPC2'); 
end



if updatemaingui % update erpset menu at main gui
    assignin('base','ALLMVPC',ALLMVPC);  % save to workspace
    updatemenumvpc(ALLMVPC); % add a new bestset to the bestset menu
end


prefunc = dbstack;
nf = length(unique_bc2({prefunc.name}));
if nf==1
        msg2end
end




return
