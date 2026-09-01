% PURPOSE: creates a figure for an ERPLAB Studio window or dialog.
%
% FORMAT:
%
% h = f_estudio_figure(...)
%
% Takes and returns exactly what figure() does. The only difference is that the
% figure carries pixel font units as a default, so every component built inside
% it reads its FontSize in pixels rather than points.
%
% Studio positions its panels in pixels while MATLAB sizes fonts in points, and
% the points-per-pixel ratio varies by platform and release. Matching the two
% units keeps text and layout in step. The defaults below are inherited through
% uipanel and through the uix layout containers, so a whole panel tree is
% covered by setting them once here.
%
% Only UI component defaults are set. Axes and text are left in points so that
% data plots drawn inside a Studio window are unaffected; plot text that should
% follow the GUI font passes 'FontUnits','pixels' at its own call site.
%
% NOTE: the units must be in place before a component is created. Changing
% FontUnits afterwards makes MATLAB rewrite FontSize to preserve the rendered
% size, which leaves the appearance unchanged.
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Kurt Winsler
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2026

function h = f_estudio_figure(varargin)

h = figure(varargin{:}, ...
    'defaultUicontrolFontUnits',    'pixels', ...
    'defaultUipanelFontUnits',      'pixels', ...
    'defaultUibuttongroupFontUnits','pixels', ...
    'defaultUitableFontUnits',      'pixels');

end
