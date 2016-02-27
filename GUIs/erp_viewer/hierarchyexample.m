%% A Hierarchy of Layouts Example
% This example shows how to use layouts within other layouts to achieve
% more complex user interface designs with the right mix of variable and
% fixed sized components.
%
% Copyright 2009-2014 The MathWorks Ltd.

%% Open the window
% Open a new figure window and remove the toolbar and menus
window = figure( 'Name', 'A Layout Hierarchy Example', ...
    'MenuBar', 'none', ...
    'Toolbar', 'none', ...
    'NumberTitle', 'off', ...
    'Position', 200*ones(1,4) );

%% Create the first layout (vertical box)
% Inside this vertical box we place the axes
vbox = uix.VBox( 'Parent', window );
axes( 'Parent', vbox );

%% Create the second layout (horizontal box)
% Inside this horizontal box we place two buttons
hbox = uix.HButtonBox( 'Parent', vbox, 'Padding', 5 );
uicontrol( 'Parent', hbox, ...
    'String', 'Button 1' );
uicontrol( 'Parent', hbox, ...
    'String', 'Button 2' );

%% Set the sizes
% We want the axes to grow with the window so set the first size to be -1 
% (which means variable size with wieght 1) and the buttons to stay fixed 
% height so set the second size to 35 (fixed height of 35 pixels)
set( vbox, 'Heights', [-1 35] )
