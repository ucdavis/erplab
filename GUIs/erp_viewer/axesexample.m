%% Axes inside layouts
% This example demonstrates how axes are affected by being placed into
% layouts. The layouts take into account the "ActivePositionProperty" in
% order to determine whether to set the "Position" or "OuterPosition"
% (default) property of the axes.
%
% Copyright 2009-2013 The MathWorks, Inc.

%% Open the window
% Open a new figure window and remove the toolbar and menus
window = figure( 'Name', 'Axes inside layouts', ...
    'MenuBar', 'none', ...
    'Toolbar', 'none', ...
    'NumberTitle', 'off' );

%% Create the layout
% The layout involves two axes side by side. This is done using a
% flexible horizontal box. The left-hand axes is left with the
% ActivePositionProperty set to "outerposition", but the right-hand axes is
% switched to use "Position"
hbox = uix.HBoxFlex('Parent', window, 'Spacing', 3);
axes1 = axes( 'Parent', hbox, ...
    'ActivePositionProperty', 'outerposition' );
axes2 = axes( 'Parent', hbox, ...
    'ActivePositionProperty', 'Position' );
set( hbox, 'Widths', [-2 -1] );

%% Fill the axes
% Using "OuterPosition" (left-hand axes) is the normal mode and looks good
% for virtually any plot type. Using "Position" is only really useful for
% 2D plots with the axes turned off, such as images
x = membrane( 1, 15 );
surf( axes1, x );
lighting( axes1, 'gouraud' );
shading( axes1, 'interp' );
l = light( 'Parent', axes1 );
camlight( l, 'head' );
axis( axes1, 'tight' );

imagesc( x, 'Parent', axes2 );
set( axes2, 'xticklabel', [], 'yticklabel', [] );