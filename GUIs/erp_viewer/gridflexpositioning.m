% Copyright 2009-2013 The MathWorks Ltd.

f = figure(); 

% Box Panel 
p = uix.BoxPanel( 'Parent', f, 'Title', 'A BoxPanel', 'Padding', 5 ); 

% HBox 
b = uix.HBox( 'Parent', p, 'Spacing', 5, 'Padding', 5 ); 

% uicontrol 
uicontrol( 'Style', 'listbox', 'Parent', b, 'String', {'Item 1','Item 2'} ); 

% Grid Flex 
g = uix.GridFlex( 'Parent', b, 'Spacing', 5 ); 
uicontrol( 'Parent', g, 'Background', 'r' );
uicontrol( 'Parent', g, 'Background', 'b' );
uicontrol( 'Parent', g, 'Background', 'g' );
uix.Empty( 'Parent', g );
uicontrol( 'Parent', g, 'Background', 'c' );
uicontrol( 'Parent', g, 'Background', 'y' );
set( g, 'Widths', [-1 100 -2], 'Heights', [-1 -2] ); 

% set HBox elements sizes 
set( b, 'Widths', [100 -1] ); 
