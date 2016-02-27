function demoBrowser()
%demoBrowser: an example of using layouts to build a user interface
%
%   demoBrowser() opens a simple GUI that allows several of MATLAB's
%   built-in demos to be viewed. It aims to demonstrate how multiple
%   layouts can be used to create a good-looking user interface that
%   retains the correct proportions when resized. It also shows how to
%   hook-up callbacks to interpret user interaction.
%
%   See also: <a href="matlab:doc Layouts">Layouts</a>

%   Copyright 2010-2013 The MathWorks, Inc.

% Data is shared between all child functions by declaring the variables
% here (they become global to the function). We keep things tidy by putting
% all GUI stuff in one structure and all data stuff in another. As the app
% grows, we might consider making these objects rather than structures.
data = createData();
gui = createInterface( data.DemoNames );

% Now update the GUI with the current data
updateInterface();
redrawDemo();

% Explicitly call the demo display so that it gets included if we deploy
displayEndOfDemoMessage('')

%-------------------------------------------------------------------------%
    function data = createData()
        % Create the shared data-structure for this application
        demoList = {
            'Complex surface'            'cplxdemo'
            'Cruller'                    'cruller'
            'Earth'                      'earthmap'
            'Four linked tori'           'tori4'
            'Klein bottle'               'xpklein'
            'Klein bottle (1)'           'klein1'
            'Knot'                       'knot'
            'Logo'                       'logo'
            'Spherical Surface Harmonic' 'spharm2'
            'Werner Boy''s Surface'      'wernerboy'
            };
        selectedDemo = 8;
        data = struct( ...
            'DemoNames', {demoList(:,1)'}, ...
            'DemoFunctions', {demoList(:,2)'}, ...
            'SelectedDemo', selectedDemo );
    end % createData

%-------------------------------------------------------------------------%
    function gui = createInterface( demoList )
        % Create the user interface for the application and return a
        % structure of handles for global use.
        gui = struct();
        % Open a window and add some menus
        gui.Window = figure( ...
            'Name', 'Gallery browser', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'HandleVisibility', 'off' );
        
        % + File menu
        gui.FileMenu = uimenu( gui.Window, 'Label', 'File' );
        uimenu( gui.FileMenu, 'Label', 'Exit', 'Callback', @onExit );
        
        % + View menu
        gui.ViewMenu = uimenu( gui.Window, 'Label', 'View' );
        for ii=1:numel( demoList )
            uimenu( gui.ViewMenu, 'Label', demoList{ii}, 'Callback', @onMenuSelection );
        end
        
        % + Help menu
        helpMenu = uimenu( gui.Window, 'Label', 'Help' );
        uimenu( helpMenu, 'Label', 'Documentation', 'Callback', @onHelp );
        
        
        % Arrange the main interface
        mainLayout = uix.HBoxFlex( 'Parent', gui.Window, 'Spacing', 3 );
        
        % + Create the panels
        controlPanel = uix.BoxPanel( ...
            'Parent', mainLayout, ...
            'Title', 'Select a demo:' );
        gui.ViewPanel = uix.BoxPanel( ...
            'Parent', mainLayout, ...
            'Title', 'Viewing: ???', ...
            'HelpFcn', @onDemoHelp );
        gui.ViewContainer = uicontainer( ...
            'Parent', gui.ViewPanel );        

        % + Adjust the main layout
        set( mainLayout, 'Widths', [-1,-2]  );
        
        
        % + Create the controls
        controlLayout = uix.VBox( 'Parent', controlPanel, ...
            'Padding', 3, 'Spacing', 3 );
        gui.ListBox = uicontrol( 'Style', 'list', ...
            'BackgroundColor', 'w', ...
            'Parent', controlLayout, ...
            'String', demoList(:), ...
            'Value', 1, ...
            'Callback', @onListSelection);
        gui.HelpButton = uicontrol( 'Style', 'PushButton', ...
            'Parent', controlLayout, ...
            'String', 'Help for <demo>', ...
            'Callback', @onDemoHelp );
        set( controlLayout, 'Heights', [-1 28] ); % Make the list fill the space
        
        % + Create the view
        p = gui.ViewContainer;
        gui.ViewAxes = axes( 'Parent', p );
        
        
    end % createInterface

%-------------------------------------------------------------------------%
    function updateInterface()
        % Update various parts of the interface in response to the demo
        % being changed.
        
        % Update the list and menu to show the current demo
        set( gui.ListBox, 'Value', data.SelectedDemo );
        % Update the help button label
        demoName = data.DemoNames{ data.SelectedDemo };
        set( gui.HelpButton, 'String', ['Help for ',demoName] );
        % Update the view panel title
        set( gui.ViewPanel, 'Title', sprintf( 'Viewing: %s', demoName ) );
        % Untick all menus
        menus = get( gui.ViewMenu, 'Children' );
        set( menus, 'Checked', 'off' );
        % Use the name to work out which menu item should be ticked
        whichMenu = strcmpi( demoName, get( menus, 'Label' ) );
        set( menus(whichMenu), 'Checked', 'on' );
    end % updateInterface

%-------------------------------------------------------------------------%
    function redrawDemo()
        % Draw a demo into the axes provided
        
        % We first clear the existing axes ready to build a new one
        if ishandle( gui.ViewAxes )
            delete( gui.ViewAxes );
        end
        
        % Some demos create their own figure. Others don't.
        fcnName = data.DemoFunctions{data.SelectedDemo};
        switch upper( fcnName )
            case 'LOGO'
                % These demos open their own windows
                evalin( 'base', fcnName );
                gui.ViewAxes = gca();
                fig = gcf();
                set( fig, 'Visible', 'off' );
                
            otherwise
                % These demos need a window opening
                fig = figure( 'Visible', 'off' );
                evalin( 'base', fcnName );
                gui.ViewAxes = gca();
        end
        % Now copy the axes from the demo into our window and restore its
        % state.
        cmap = colormap( gui.ViewAxes );
        set( gui.ViewAxes, 'Parent', gui.ViewContainer );
        colormap( gui.ViewAxes, cmap );
        rotate3d( gui.ViewAxes, 'on' );
        % Get rid of the demo figure
        close( fig );
    end % redrawDemo

%-------------------------------------------------------------------------%
    function onListSelection( src, ~ )
        % User selected a demo from the list - update "data" and refresh
        data.SelectedDemo = get( src, 'Value' );
        updateInterface();
        redrawDemo();
    end % onListSelection

%-------------------------------------------------------------------------%
    function onMenuSelection( src, ~ )
        % User selected a demo from the menu - work out which one
        demoName = get( src, 'Label' );
        data.SelectedDemo = find( strcmpi( demoName, data.DemoNames ), 1, 'first' );
        updateInterface();
        redrawDemo();
    end % onMenuSelection


%-------------------------------------------------------------------------%
    function onHelp( ~, ~ )
        % User has asked for the documentation
        doc layout
    end % onHelp

%-------------------------------------------------------------------------%
    function onDemoHelp( ~, ~ )
        % User wnats documentation for the current demo
        showdemo( data.DemoFunctions{data.SelectedDemo} );
    end % onDemoHelp

%-------------------------------------------------------------------------%
    function onExit( ~, ~ )
        % User wants to quit out of the application
        delete( gui.Window );
    end % onExit

end % EOF