% PURPOSE: installs a listener that pins ERPLAB's figures to the light theme.
%
% FORMAT:
%
% erplab_lighttheme_listener(erplabpath)
%
% INPUT
%
% erplabpath  - full path to the ERPLAB folder, used to tell ERPLAB's figures
%               apart from everyone else's
%
%
% ERPLAB creates figures from well over a hundred places, including GUIDE
% windows that MATLAB builds from a .fig file, so there is no single call to
% attach the theme to. Listening for new figures on the graphics root catches
% all of them from one place.
%
% The call stack at the moment a figure is created says which file made it, so
% only figures originating inside the ERPLAB folder are pinned. EEGLAB's
% windows and anything the user plots are left alone.
%
% Installing is idempotent, and does nothing on releases that have no themes to
% override. The callback is wrapped so that a failure can never interfere with
% creating a figure.
%
% The listener handle is kept on the graphics root rather than in a persistent
% variable, which would be the only reference to it and would be dropped by a
% clear, silently switching the whole thing off.
%
% *** This function is part of ERPLAB Toolbox ***

function erplab_lighttheme_listener(erplabpath)

APPKEY = 'ERPLAB_LightThemeListener';

hListener = getappdata(groot, APPKEY);
if ~isempty(hListener) && isvalid(hListener)
        return % already installed
end
if nargin < 1 || isempty(erplabpath)
        return
end
try
        predatesThemes = isMATLABReleaseOlderThan('R2025a');
catch
        predatesThemes = true; % older than the function itself, so older than themes
end
if predatesThemes
        return
end

setappdata(groot, APPKEY, addlistener(groot, 'ObjectChildAdded', ...
        @(~,evt) pinIfERPLAB(evt, erplabpath)));

% -------------------------------------------------------------------------
function pinIfERPLAB(evt, erplabroot)

try
        h = evt.Child;
        if ~isa(h, 'matlab.ui.Figure')
                return
        end
        st = dbstack('-completenames');
        callers = {st.file};
        % this file sits inside the ERPLAB folder and is always on the stack
        % here, so drop it before asking who created the figure
        callers = callers(~strcmp(callers, [mfilename('fullpath') '.m']));
        if any(startsWith(callers, erplabroot))
                erplab_lighttheme(h)
        end
catch
        % a listener must never stop a figure from being created
end
