classdef jfa_erp_viewer < handle
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
    
    
    properties
        %% Setup Data
        pheightmin = 20;   % Height for minimized control panels
        pheightmax = 200;  % Height for maximized control panels
        
        Data
        Gui
        
    end
    
    
    methods
        
        %% Constructor function
        function app = jfa_erp_viewer()
            
            % Create ERP data            
            ALLERP(1) = pop_loaderp(            ...
                'filename', 'S1_ERPs.erp'       , ...
                'filepath', './sample_data/'   );
            ALLERP(2) = pop_loaderp(            ...
                'filename', 'S2_ERPs.erp'       , ...
                'filepath', './sample_data/'   );
            
            
            app.Data = struct( ...
                'ALLERP'            , ALLERP                , ...
                'SelectedPoints'    , ALLERP(1).pnts        , ...
                'SelectedBins'      , [1]                   , ...
                'SelectedChannels'  , [1]                   , ...
                'SelectedERPs'      , [1]                   ); %#ok<NBRAK>
            
            
            % Setup GUI
            app.createInterface();
            
            % Update the GUI with the current data
            %             updateInterface();
            %             redrawDemo();
            
        end % jfa_erp_viewer()
        
        
        
        
        
        
        %% Helper Functions ------------------------------------------------------%

        
        %-------------------------------------------------------------------------%
        function createInterface(app, ~, ~)
            % Create the user interface for the application and return a
            % structure of handles for global use.
            app.Gui = struct();
            % Open a window and add some menus
            app.Gui.Window = figure( ...
                'Name'              , 'New ERP Viewer'  , ...
                'NumberTitle'       , 'off'             , ...
                'MenuBar'           , 'none'            , ...
                'Toolbar'           , 'none'            , ...
                'HandleVisibility'  , 'off'             );
            
            
            %% Create Menu Bar Items
            % + File menu
            app.Gui.FileMenu = uimenu( app.Gui.Window, 'Label', 'File' );
            uimenu( app.Gui.FileMenu, 'Label', 'Exit', 'Callback', @onExit );
            
            
            %% Arrange the main interface
            mainLayout = uix.HBoxFlex( 'Parent', app.Gui.Window, 'Spacing', 3 );
            
            
            %% + Create the ERP view panel
            app.Gui.controlPanel = uix.BoxPanel( ...
                'Parent'    , mainLayout );
            app.Gui.ViewPanel = uix.BoxPanel( ...
                'Parent'    , mainLayout, ...
                'Title'     , 'Viewing: ???', ...
                'HelpFcn'   , @onDemoHelp );
            app.Gui.ViewContainer = uicontainer( ...
                'Parent'    , app.Gui.ViewPanel );
            
            
            %% + Create the Control Panels
            controlLayout = uix.VBox( ...
                'Parent'    , app.Gui.controlPanel, ...
                'Padding'   , 3 , ...
                'Spacing'   , 3 );
            

            
            
            measurementPanel  = uix.BoxPanel( ...
                'Title' , 'measurement'     , ...
                'Parent', controlLayout     );
            
            uicontrol(...
                'Style', 'popupmenu'  , ...
                'Parent', measurementPanel , ...
                'String', {
                'Instantaneous' , ...
                'Mean amplitude', ...
                'Peak amplitude', ...
                'etc...'        } );
            
            
            scalesPanel       = uix.BoxPanel( ...
                'Title' , 'scales'          , ...
                'Parent', controlLayout     ); %#ok<NASGU>
            
            uicontrol( ...
                'Parent' , scalesPanel , ...
                'Style'  , 'edit'    , ...
                'Max'    , 0           , ...
                'Min'    , 1000        );
            uicontrol(...
                'style'     ,'edit'              , ...
                'parent'    , scalesPanel       , ...
                'unit'      ,'pix'                , ...
                'position'  ,[10 60 180 30]   , ...
                'fontsize'  ,14, ...
                'string'    ,'New String')
            
            
            
            valuesPanel       = uix.BoxPanel(  ...
                'Title' , 'plot values'     , ...
                'Parent', controlLayout     ); %#ok<NASGU>
            colorPanel        = uix.BoxPanel( ...
                'Title', 'color'            , ...
                'Parent', controlLayout     ); %#ok<NASGU>
            
            
            
            
            
            
            
            
            
            % + Adjust the main layout
            set( mainLayout, 'Widths', [-1,-2]  );
            
            % Resize the window
            %         pos = get( app.Gui.Window, 'Position' );
            %         set( fig, 'Position', [pos(1,1:2),width,sum(controlLayout.Heights)] );
            
            
            
            %% Add 2 Horizontal Button Boxes
            %         hbox = uix.HButtonBox( ...
            %             'Parent', controlLayout, ...
            %             'Spacing', 10, ...
            %             'Padding', 1 );
            %         app.Gui.CancelButton = uicontrol( ...
            %             'Style', 'PushButton', ...
            %             'Parent', hbox, ...
            %             'String', 'Cancel' );
            %         app.Gui.MeasurementToolButton = uicontrol( ...
            %             'Style', 'PushButton', ...
            %             'Parent', hbox, ...
            %             'String', 'Measurement Tool' );
            
            
            
            
            
            
            
            % Make the Panel list fill the space
            panelHeights = zeros([1 length(controlLayout.Contents)])+app.pheightmax;
            set( controlLayout, 'Heights', panelHeights );
            
            % + Create the view
            p = app.Gui.ViewContainer;
            app.Gui.ViewAxes = axes( 'Parent', p );
            
            
            
            %% Hook up the minimize callback function: `MinimizeFcn`
            for panelIndex = 1:length(controlLayout.Children)
                if(strcmpi(controlLayout.Children(panelIndex).Type, 'uipanel'))
                    set( controlLayout.Children(panelIndex), 'MinimizeFcn', ...
                        {@app.nMinimizeCallback, panelIndex} );
                end
            end
            
            
        end % createInterface
        
        %-------------------------------------------------------------------------%
        function updateInterface(~,~,~)
            % Update various parts of the interface in response to the GUI
            % being changed.
            
            % Update the list and menu to show the current demo
            %         set( app.Gui.ListBox, 'Value', Data.SelectedDemo );
            % Update the help button label
            %         demoName = Data.DemoNames{ Data.SelectedDemo };
            %         set( app.Gui.HelpButton, 'String', ['Help for ',demoName] );
            % Update the view panel title
            %         set( app.Gui.ViewPanel, 'Title', sprintf( 'Viewing: %s', demoName ) );
            % Untick all menus
            %         menus = get( app.Gui.ViewMenu, 'Children' );
            %         set( menus, 'Checked', 'off' );
            % Use the name to work out which menu item should be ticked
            %         whichMenu = strcmpi( demoName, get( menus, 'Label' ) );
            %         set( menus(whichMenu), 'Checked', 'on' );
            
            
        end % updateInterface
        
        %-------------------------------------------------------------------------%
        function redrawDemo(~,~,~)
            % Draw a demo into the axes provided
            
            % We first clear the existing axes ready to build a new one
            %         if ishandle( app.Gui.ViewAxes )
            %             delete( app.Gui.ViewAxes );
            %         end
            
            % Now copy the axes from the demo into our window and restore its
            % state.
            
            % Get rid of the demo figure
            %         close( fig );
        end % redrawDemo
        
        
        
        %-------------------------------------------------------------------------%
        function onExit(app,~,~)
            % User wants to quit out of the application
            delete( app.Gui.Window );
        end % onExit
        
        
        %% JFA Adds
        
        function nMinimizeCallback(app, ~, ~, whichpanel )
            %             originalWindowPosition = app.Gui.Window.Position;
            
            % A panel has been maximized/minimized
            allGUIControlPanels = app.Gui.controlPanel.Children;
            currGUIControlPanel = app.Gui.controlPanel.Children.Children(whichpanel);
            panelHeights   = get( allGUIControlPanels, 'Heights' );
            panelHeights   = flipud(panelHeights);
            %         pos = get( app.Gui.Window, 'Position' );
            currGUIControlPanel.Minimized = ~currGUIControlPanel.Minimized;
            if currGUIControlPanel.Minimized
                panelHeights(whichpanel) = app.pheightmin;
            else
                panelHeights(whichpanel) = app.pheightmax;
            end
            panelHeights    = flipud(panelHeights);
            set( allGUIControlPanels, 'Heights', panelHeights );
            
            % Resize the figure, keeping the top stationary
            %         delta_height = originalWindowPosition(1,4) ...
            %             - sum( app.Gui.controlPanel.Children.Heights );
            %         set( app.Gui.Window, 'Position', ...
            %             originalWindowPosition(1,:) + [0 delta_height 0 -delta_height]);
        end % nMinimize
    end % methods
    
end % EOF