function minimizeexample()
%MINIMIZEEXAMPLE: An example of using the panelbox minimize/maximize

%   Copyright 2010-2013 The MathWorks Ltd.

width = 200;
pheightmin = 20;
pheightmax = 100;

% Create the window and main layout
fig = figure( 'Name', 'Collapsable GUI', ...'
    'NumberTitle', 'off', ...
    'Toolbar', 'none', ...
    'MenuBar', 'none' );
box = uix.VBox( 'Parent', fig );

panel{1} = uix.BoxPanel( 'Title', 'Panel 1', 'Parent', box );
panel{2} = uix.BoxPanel( 'Title', 'Panel 2', 'Parent', box );
panel{3} = uix.BoxPanel( 'Title', 'Panel 3', 'Parent', box );
set( box, 'Heights', pheightmax*ones(1,3) );

% Add some contents
uicontrol( 'Style', 'PushButton', 'String', 'Button 1', 'Parent', panel{1} );
uicontrol( 'Style', 'PushButton', 'String', 'Button 2', 'Parent', panel{2} );
uicontrol( 'Style', 'PushButton', 'String', 'Button 3', 'Parent', panel{3} );

% Resize the window
pos = get( fig, 'Position' );
set( fig, 'Position', [pos(1,1:2),width,sum(box.Heights)] );

% Hook up the minimize callback
set( panel{1}, 'MinimizeFcn', {@nMinimize, 1} );
set( panel{2}, 'MinimizeFcn', {@nMinimize, 2} );
set( panel{3}, 'MinimizeFcn', {@nMinimize, 3} );

%-------------------------------------------------------------------------%
    function nMinimize( eventSource, eventData, whichpanel ) %#ok<INUSL>
        % A panel has been maximized/minimized
        s = get( box, 'Heights' );
        pos = get( fig, 'Position' );
        panel{whichpanel}.Minimized = ~panel{whichpanel}.Minimized;
        if panel{whichpanel}.Minimized
            s(whichpanel) = pheightmin;
        else
            s(whichpanel) = pheightmax;
        end
        set( box, 'Heights', s );
        
        % Resize the figure, keeping the top stationary
        delta_height = pos(1,4) - sum( box.Heights );
        set( fig, 'Position', pos(1,:) + [0 delta_height 0 -delta_height] );
    end % nMinimize

end % EOF
