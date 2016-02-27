%% Axes with colorbars inside layouts
% This example demonstrates how to correctly layout axes that have
% associated legends or colorbars by grouping them together using a
% uicontainer.
%
% Copyright 2014 The MathWorks, Inc.

%% Open the window
% Open a new figure window and remove the toolbar and menus
window = figure( 'Name', 'Axes legend and colorbars', ...
    'MenuBar', 'none', ...
    'Toolbar', 'none', ...
    'NumberTitle', 'off' );

%% Create the layout
% The layout involves two axes side by side. Each axes is placed into a
% uicontainer so that the legend and colorbar are "grouped" with the axes.
hbox = uix.VBoxFlex('Parent', window, 'Spacing', 3);
axes1 = axes( 'Parent', uicontainer('Parent', hbox) );
axes2 = axes( 'Parent', uicontainer('Parent', hbox) );

%% Add decorations
% Give the first axes a colorbar and the second axes a legend.
surf( axes1, membrane( 1, 15 ) );
colorbar( axes1 );

theta = 0:360;
plot( axes2, theta, sind(theta), theta, cosd(theta) );
legend( axes2, 'sin', 'cos', 'Location', 'NorthWestOutside' );