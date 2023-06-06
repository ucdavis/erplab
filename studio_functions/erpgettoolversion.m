

function output = erpgettoolversion(field)
output = [];
if nargin<1
    help erpgettoolversion;
    return
end

if nargin==1 % read
    try
        p = which('o_ERPDAT');
        p = p(1:findstr(p,'o_ERPDAT.m')-1);
        v = load(fullfile(p,'erplab_running_version.erpm'), '-mat');
    catch
        
        msgboxText = ['EStudio (erpgettoolversion.m) could not find "erplab_running_version.erpm" or does not have permission for reading it.\n'...
            'Please, run EStudio once again.\n'];
        try
            cprintf([0.45 0.45 0.45], msgboxText');
        catch
            fprintf(msgboxText);
        end
        output = [];
        return
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