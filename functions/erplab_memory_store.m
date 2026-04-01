% PURPOSE: centralize ERPLAB working-memory storage and migration
%
% FORMAT:
%
% value = erplab_memory_store(kind, action, varargin)

function output = erplab_memory_store(kind, action, varargin)

output = [];

if nargin < 2
    help erplab_memory_store
    return
end

kind = lower(kind);
action = lower(action);
paths = erplab_user_paths;
[store_file, legacy_file, wrapper_field] = local_store_paths(kind, paths);

switch action
    case 'path'
        output = store_file;

    case 'default'
        output = local_default_struct(kind, local_get_mshock(varargin));

    case 'normalize'
        if isempty(varargin)
            output = local_default_struct(kind, 0);
        else
            output = local_normalize_struct(kind, varargin{1});
        end

    case 'load'
        output = local_load_struct(kind, store_file, legacy_file);

    case 'save'
        if isempty(varargin) || ~isstruct(varargin{1})
            return
        end
        output = local_normalize_struct(kind, varargin{1});
        local_save_struct(store_file, output);

    case 'savefield'
        if numel(varargin) < 2
            return
        end
        field = varargin{1};
        field_value = varargin{2};
        local_save_field(kind, store_file, legacy_file, field, field_value, wrapper_field);

    case 'reset'
        mshock = local_existing_mshock(kind, store_file, legacy_file);
        output = local_default_struct(kind, mshock + 1);
        local_save_struct(store_file, output);

    otherwise
        help erplab_memory_store
end

end

function [store_file, legacy_file, wrapper_field] = local_store_paths(kind, paths)

switch kind
    case 'classic'
        store_file = paths.classicMemory;
        legacy_file = paths.legacyClassicMemory;
        wrapper_field = 'vmemoryerp';
    case 'studio'
        store_file = paths.studioMemory;
        legacy_file = paths.legacyStudioMemory;
        wrapper_field = 'vmemoryestudio';
    otherwise
        error('erplab_memory_store:UnknownKind', 'Unknown ERPLAB memory kind: %s', kind);
end

end

function s = local_default_struct(kind, mshock)

switch kind
    case 'classic'
        s = erplab_default_memory_struct(mshock);
    case 'studio'
        s = estudio_default_memory_struct(mshock);
    otherwise
        error('erplab_memory_store:UnknownKind', 'Unknown ERPLAB memory kind: %s', kind);
end

end

function s = local_load_struct(kind, store_file, legacy_file)

did_normalize = 0;

if exist(store_file, 'file') == 2
    try
        loaded = load(store_file, '-mat');
        [s, did_normalize] = local_normalize_struct(kind, loaded);
        if did_normalize
            local_save_struct(store_file, s);
        end
        return
    catch
    end
end

if ~isempty(legacy_file) && exist(legacy_file, 'file') == 2
    try
        loaded = load(legacy_file, '-mat');
        [s, ~] = local_normalize_struct(kind, loaded);
        local_save_struct(store_file, s);
        return
    catch
    end
end

s = local_default_struct(kind, 0);
local_save_struct(store_file, s);

end

function local_save_struct(store_file, s)

save(store_file, '-struct', 's');

end

function local_save_field(kind, store_file, legacy_file, field, field_value, wrapper_field)

if exist(store_file, 'file') ~= 2
    local_load_struct(kind, store_file, legacy_file);
end

try
    eval([field ' = field_value;']);
    save(store_file, field, '-append');
catch
    current = local_load_struct(kind, store_file, legacy_file);
    if isfield(current, wrapper_field) && isstruct(current.(wrapper_field))
        current = current.(wrapper_field);
    end
    current.(field) = field_value;
    current = local_normalize_struct(kind, current);
    local_save_struct(store_file, current);
end

end

function mshock = local_existing_mshock(kind, store_file, legacy_file)

mshock = 0;

try
    if exist(store_file, 'file') == 2
        loaded = load(store_file, '-mat');
        normalized = local_normalize_struct(kind, loaded);
        if isfield(normalized, 'mshock')
            mshock = normalized.mshock;
            return
        end
    end
catch
end

try
    if ~isempty(legacy_file) && exist(legacy_file, 'file') == 2
        loaded = load(legacy_file, '-mat');
        normalized = local_normalize_struct(kind, loaded);
        if isfield(normalized, 'mshock')
            mshock = normalized.mshock;
        end
    end
catch
end

end

function mshock = local_get_mshock(args)

mshock = 0;
if ~isempty(args) && ~isempty(args{1}) && isnumeric(args{1})
    mshock = args{1};
end

end

function [s, changed] = local_normalize_struct(kind, loaded)

changed = 0;

if ~isstruct(loaded)
    s = local_default_struct(kind, 0);
    changed = 1;
    return
end

wrapper_field = local_wrapper_field(kind);
if isfield(loaded, wrapper_field) && isstruct(loaded.(wrapper_field))
    loaded = loaded.(wrapper_field);
    changed = 1;
end

mshock = 0;
if isfield(loaded, 'mshock') && isnumeric(loaded.mshock) && ~isempty(loaded.mshock)
    mshock = loaded.mshock;
end

defaults = local_default_struct(kind, mshock);
default_fields = fieldnames(defaults);

s = loaded;

for iField = 1:numel(default_fields)
    field = default_fields{iField};
    if ~isfield(s, field)
        s.(field) = defaults.(field);
        changed = 1;
    end
end

if ~isfield(s, 'erplabver') || ~strcmp(s.erplabver, defaults.erplabver)
    s.erplabver = defaults.erplabver;
    changed = 1;
end

if ~isfield(s, 'erplabrel') || ~strcmp(s.erplabrel, defaults.erplabrel)
    s.erplabrel = defaults.erplabrel;
    changed = 1;
end

end

function wrapper_field = local_wrapper_field(kind)

switch kind
    case 'classic'
        wrapper_field = 'vmemoryerp';
    case 'studio'
        wrapper_field = 'vmemoryestudio';
    otherwise
        wrapper_field = '';
end

end
