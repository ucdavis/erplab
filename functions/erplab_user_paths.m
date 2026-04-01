% PURPOSE: resolve user-writable and legacy ERPLAB storage paths
%
% FORMAT:
%
% paths = erplab_user_paths

function paths = erplab_user_paths

paths = struct();

pref_root = prefdir;
if isempty(pref_root)
    pref_root = tempdir;
end

paths.root = fullfile(pref_root, 'ERPLAB');
if exist(paths.root, 'dir') ~= 7
    try
        mkdir(paths.root);
    catch
        paths.root = fullfile(tempdir, 'ERPLAB');
        if exist(paths.root, 'dir') ~= 7
            mkdir(paths.root);
        end
    end
end

paths.pluginRoot = local_plugin_root();
paths.studioRoot = local_studio_root(paths.pluginRoot);

paths.classicMemory = fullfile(paths.root, 'memoryerp.erpm');
paths.studioMemory = fullfile(paths.root, 'memoryerpstudio.erpm');
paths.msg2endUser = fullfile(paths.root, 'msg2end.txt');

if isempty(paths.pluginRoot)
    paths.msg2endShipped = '';
    paths.legacyClassicMemory = '';
else
    paths.msg2endShipped = fullfile(paths.pluginRoot, 'functions', 'msg2end.txt');
    paths.legacyClassicMemory = fullfile(paths.pluginRoot, 'memoryerp.erpm');
end

if isempty(paths.studioRoot)
    paths.legacyStudioMemory = '';
    paths.legacyRunningVersion = '';
else
    paths.legacyStudioMemory = fullfile(paths.studioRoot, 'memoryerpstudio.erpm');
    paths.legacyRunningVersion = fullfile(paths.studioRoot, 'erplab_running_version.erpm');
end

end

function plugin_root = local_plugin_root

plugin_root = '';
plugin_file = which('eegplugin_erplab');
if iscell(plugin_file)
    plugin_file = plugin_file{1};
end

if isempty(plugin_file)
    return
end

idx = strfind(plugin_file, 'eegplugin_erplab.m');
if isempty(idx)
    return
end

plugin_root = plugin_file(1:idx(1)-1);

end

function studio_root = local_studio_root(plugin_root)

studio_root = '';
studio_file = which('o_ERPDAT');
if iscell(studio_file)
    studio_file = studio_file{1};
end

if ~isempty(studio_file)
    idx = strfind(studio_file, 'o_ERPDAT.m');
    if ~isempty(idx)
        studio_root = studio_file(1:idx(1)-1);
        return
    end
end

if isempty(plugin_root)
    return
end

candidate = fullfile(plugin_root, 'studio_functions');
if exist(candidate, 'dir') == 7
    studio_root = [candidate filesep];
end

end
