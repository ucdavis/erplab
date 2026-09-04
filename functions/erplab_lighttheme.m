% PURPOSE: pins figures to the light theme.
%
% FORMAT:
%
% erplab_lighttheme(fig)
%
% INPUT
%
% fig       - figure handle, or array of figure handles
%
%
% ERPLAB's windows are laid out for a light background and many of their
% colours are set explicitly, so a dark desktop leaves dark text on dark
% panels in some places and light text on hardcoded white in others. Pinning
% each ERPLAB figure to the light theme keeps its appearance the same whatever
% the desktop is set to.
%
% Two cases are deliberately left alone. Setting the theme on a figure that is
% already light changes nothing, so a light desktop is unaffected. Releases
% before R2025a carry a placeholder in the Theme property rather than a real
% theme, so testing the value rather than the property leaves them untouched.
%
% Applies to children created after the call as well as those already present.
%
% *** This function is part of ERPLAB Toolbox ***

function erplab_lighttheme(fig)

for k = 1:numel(fig)
        h = fig(k);
        if ~isgraphics(h) || ~isprop(h,'Theme')
                continue
        end
        if isa(h.Theme,'matlab.graphics.theme.GraphicsTheme')
                h.Theme = 'light';
        end
end
