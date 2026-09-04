% PURPOSE: sets, or restores, the uicontrol defaults that MATLAB's dialogs use.
%
% FORMAT:
%
% erplab_dialogcolors(bgcolor)           % set, before calling questdlg/msgbox
% erplab_dialogcolors(bgcolor, fgcolor)  % set, with a specific text colour
% erplab_dialogcolors()                  % restore, immediately after
%
% INPUT
%
% bgcolor   - background colour for the dialog's buttons
% fgcolor   - text colour; black if not given
%
%
% MATLAB's dialogs take their colours from the root defaults, so the only way to
% colour one is to set those defaults around the call. ERPLAB has always set the
% background this way; the foreground has to be set too, because otherwise the
% button text keeps following the desktop theme and a dark desktop leaves pale
% text on ERPLAB's light button colour.
%
% Restoring with 'remove' returns the defaults to tracking the theme. Writing
% back a previously read value would not: a value read while the desktop is dark
% becomes an explicit dark default that then overrides the light theme pinned on
% ERPLAB's own windows, which is what used to leave buttons dark on dark.
%
% The dialog's own background still follows the desktop, since MATLAB re-derives
% a dialog's theme after building it. Only its text and buttons are ours to set.
%
% *** This function is part of ERPLAB Toolbox ***

function erplab_dialogcolors(bgcolor, fgcolor)

if nargin < 1 || isempty(bgcolor)
        set(0, 'DefaultUicontrolBackgroundColor', 'remove');
        set(0, 'DefaultUicontrolForegroundColor', 'remove');
        return
end
if nargin < 2 || isempty(fgcolor)
        fgcolor = [0 0 0];
end
set(0, 'DefaultUicontrolBackgroundColor', bgcolor);
set(0, 'DefaultUicontrolForegroundColor', fgcolor);
