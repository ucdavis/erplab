% PURPOSE: store ERPLAB session-only state in root appdata
%
% FORMAT:
%
% value = erplab_session_state(action, field, value)

function output = erplab_session_state(action, field, value)

output = [];
state_key = 'ERPLAB_SessionState';

if nargin < 1
    help erplab_session_state
    return
end

action = lower(action);

switch action
    case 'get'
        state = local_get_state(state_key);
        if nargin < 2 || isempty(field)
            output = state;
        elseif isfield(state, field)
            output = state.(field);
        else
            output = [];
        end

    case 'set'
        if nargin < 3
            help erplab_session_state
            return
        end
        state = local_get_state(state_key);
        state.(field) = value;
        setappdata(0, state_key, state);
        output = value;

    case 'clear'
        if isappdata(0, state_key)
            rmappdata(0, state_key);
        end

    otherwise
        help erplab_session_state
end

end

function state = local_get_state(state_key)

if isappdata(0, state_key)
    state = getappdata(0, state_key);
else
    state = struct();
end

end
