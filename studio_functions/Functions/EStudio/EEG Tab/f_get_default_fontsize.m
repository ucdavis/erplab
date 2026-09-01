%%This function is to set the default fontsize for ERPLAB Studio GUIs

%Author: Guanghui ZHANG && Steve Luck
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
% 2023


function FontSizeDefault = f_get_default_fontsize()

% The value is in PIXELS, not points. Studio positions its panels in pixels, so
% sizing fonts in the same unit keeps text and layout locked together whatever
% points-per-pixel ratio MATLAB reports on a given platform or release.
% Components created inside a figure from f_estudio_figure pick the unit up
% automatically; anything drawn into an axes must pass 'FontUnits','pixels'
% ahead of 'FontSize' in the same call.
%
% One value covers every platform: 12 px is what the earlier per-platform point
% sizes each rendered as (Mac 12 pt at 72 dpi, Windows 9 pt at 96 dpi). Linux
% sat slightly lower at 8.5 pt (11.33 px), which looked incidental rather than a
% measured platform difference.
FontSizeDefault = 12;

end
