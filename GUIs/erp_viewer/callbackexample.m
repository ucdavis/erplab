function callbackexample()

% Copyright 2009-2013 The MathWorks, Inc.

% Create application data
colorNames = {
    'Red'
    'Orange'
    'Yellow'
    'Green'
    'Blue'
    'Indigo'
    'Violet'
    };
colorValues = [
    1.0 0.2 0.2
    1.0 0.6 0.2
    1.0 1.0 0.4
    0.6 1.0 0.6
    0.2 0.4 1.0
    0.4 0.1 0.6
    0.7 0.5 1.0
    ];

% Layout the interface
f = figure();
p = uix.Panel( 'Parent', f, 'Title', 'A Panel', 'TitlePosition', 'CenterTop');
b = uix.HBoxFlex( 'Parent', p, 'Spacing', 5, 'Padding', 5  );
hList = uicontrol( 'Style', 'listbox', 'Parent', b, ...
    'String', colorNames, ...
    'Back', 'w' );
hButton = uicontrol( 'Parent', b, ...
    'Background', colorValues(1,:), ...
    'String', colorNames{1} );
set( b, 'Widths', [-1 -3] );

% Add user interactions
set( hList, 'Callback', @onChangeColor );


    function onChangeColor( source, ~ )
        idx = get( source, 'Value' );
        set( hButton, 'Background', colorValues(idx,:), 'String', colorNames{idx} )
    end % onChangeColor


end % main