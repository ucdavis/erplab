classdef jfa_testgui
    %JFA_GUIOBJECT Object-oriented version of an example/test GUI
    %
    %   This classdef exists to test and play around with UI functions
    %
    
    properties
        Figure
        Panel
        
        Gui
        Data

        
        
    end
    
    properties (Constant = true, Hidden = true)
        
        WINDOW_TITLE = 'JFA Test GUI Object';

        
    end
    
    
    
    methods
        
        %% Constructor Function
        function app = jfa_testgui()
            % Constructor function for JFA_GUIOBJECT class
            % This runs when an object of this class is create
            
            app.Figure = figure( ...
                'Name'       , app.WINDOW_TITLE, ...
                'MenuBar'    , 'none', ...
                'Toolbar'    , 'none', ...
                'NumberTitle', 'off' );
            
            app.Panel = uix.VBox( ...
                'Parent'    , app.Figure    );
            
           
            
            uicontrol(...
                'Style', 'PopupMenu'  , ...
                'Parent', app.Panel , ...
                'Position', [0 0 200 100] , ...
                'String', {'bin 1', 'bin 2', 'bin 3'} );
            
            
            
            
        end % instantion function
        
        %% Callbacks
        
        
    end
    
end

