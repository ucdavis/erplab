% PURPOSE: resolve the read/write path for ERPLAB's editable completion message
%
% FORMAT:
%
% filename = erplab_msg2end_file(action)

function filename = erplab_msg2end_file(action)

if nargin < 1 || isempty(action)
    action = 'read';
end

paths = erplab_user_paths;
action = lower(action);

switch action
    case 'read'
        if exist(paths.msg2endUser, 'file') == 2
            filename = paths.msg2endUser;
        else
            filename = paths.msg2endShipped;
        end

    case 'write'
        filename = local_ensure_user_file(paths);

    otherwise
        help erplab_msg2end_file
        filename = '';
end

end

function filename = local_ensure_user_file(paths)

filename = paths.msg2endUser;

if exist(filename, 'file') == 2
    return
end

if ~isempty(paths.msg2endShipped) && exist(paths.msg2endShipped, 'file') == 2
    try
        copyfile(paths.msg2endShipped, filename);
        return
    catch
    end
end

fid = fopen(filename, 'w');
if fid == -1
    error('erplab_msg2end_file:CreateFailed', 'Could not create msg2end.txt at %s', filename);
end
fclose(fid);

end
