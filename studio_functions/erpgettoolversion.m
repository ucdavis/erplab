

function output = erpgettoolversion(field)
output = [];
if nargin<1
    help erpgettoolversion;
    return
end

if nargin==1 % read
    try
        output = erplab_session_state('get', field);
        if ~isempty(output)
            return
        end
        paths = erplab_user_paths;
        if ~isempty(paths.legacyRunningVersion) && exist(paths.legacyRunningVersion, 'file') == 2
            v = load(paths.legacyRunningVersion, '-mat');
        else
            v = struct();
        end
    catch
        v = struct();
    end
    if isfield(v, field)
        output = v.(field);
    else
        output = [];
    end
    return
    
else % invalid inputs
    msgboxText = 'Wrong number of inputs for erpworkingmemory.m\n';
    try
        cprintf([0.45 0.45 0.45], msgboxText');
    catch
        fprintf(msgboxText);
    end
    output = [];
    return
end
