% PURPOSE: bring ERPLAB windows back to the front after an OS-level dialog
%
% FORMAT:
%
% erplab_restorefocus(h)
%
% h - a single figure handle, or a list of figure handles ordered front to back
%     as returned by allchild(groot). Anything that is not a live, visible figure
%     is ignored, so callers do not need to guard the call.
%
% uigetfile/uiputfile are operating-system dialogs with no parent figure. From
% MATLAB R2025a, opening one promotes the MATLAB desktop above the calling figure,
% so the windows the user was working in are left buried once the dialog closes.
% Neither MATLAB release restores that focus itself, so ERPLAB does it here.
%
% Raising the top two windows back to front, rather than just the caller, is what
% keeps a nested GUI stacked over its parent: a dialog opened from a GUI that was
% itself opened from Studio would otherwise leave the MATLAB desktop wedged between
% the two. The count is capped at two deliberately - restoring three or more is
% measurably unreliable in both R2023b and R2026a, and a raise costs about 100 ms on
% R2026a (5 ms on R2023b). Each raise is flushed with drawnow, without which R2026a
% applies them out of order.
%
% See also erplab_uigetfile, erplab_uiputfile
%
% *** This function is part of ERPLAB Toolbox ***

function erplab_restorefocus(h)

MAXRAISE = 2;

if nargin < 1 || isempty(h)
    return
end

h = h(:);
h = h(arrayfun(@(x) isgraphics(x, 'figure'), h));
if isempty(h)
    return
end

h = h(arrayfun(@(x) strcmpi(get(x, 'Visible'), 'on'), h));
if isempty(h)
    return
end

if numel(h) > MAXRAISE
    h = h(1:MAXRAISE);
end

try
    for k = numel(h):-1:1   % back to front, so h(1) ends up on top
        figure(h(k));
        drawnow;            % R2026a reorders asynchronously without this
    end
catch
    % raising is cosmetic; never let it break the calling operation
end

end
