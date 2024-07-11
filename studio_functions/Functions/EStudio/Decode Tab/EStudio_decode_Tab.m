%%This function is to create ERP Tab


% Author: Guanghui Zhang & Steve J. Luck
% Center for Mind and Brain
% University of California, Davis
% Davis, CA
% 2024



function EStudio_gui_erp_totl = EStudio_decode_Tab(EStudio_gui_erp_totl,ColorB_def)
global observe_DECODE;
addlistener(observe_DECODE,'Reset_best_panel_change',@Reset_best_panel_change);

if isempty(ColorB_def)
    ColorB_def = [0.7020 0.77 0.85];
end

%% Arrange the main interface for ERP panel (Tab3)
EStudio_gui_erp_totl.decode_ViewBox = uix.VBox('Parent', EStudio_gui_erp_totl.tabdecode,'BackgroundColor',ColorB_def);
EStudio_gui_erp_totl.decode_ViewPanel = uix.BoxPanel('Parent', EStudio_gui_erp_totl.decode_ViewBox,'TitleColor',ColorB_def,'ForegroundColor','k');%
EStudio_gui_erp_totl.decode_ViewContainer = uicontainer('Parent', EStudio_gui_erp_totl.decode_ViewPanel);

EStudio_gui_erp_totl.panel_decode_scroll = uix.ScrollingPanel('Parent', EStudio_gui_erp_totl.tabdecode);
set(EStudio_gui_erp_totl.panel_decode_scroll,'BackgroundColor',ColorB_def);
set( EStudio_gui_erp_totl.tabdecode, 'Widths', [-4, 300]); % Viewpanel and settings panel
EStudio_gui_erp_totl.panel_fonts  = f_get_default_fontsize();
EStudio_gui_erp_totl.decode_settingLayout = uiextras.VBox('Parent', EStudio_gui_erp_totl.panel_decode_scroll,'BackgroundColor',ColorB_def);
% + Create the settings window panels for ERP panel
EStudio_gui_erp_totl.decode_panel{1} = f_decode_bestsetsGUI(EStudio_gui_erp_totl.decode_settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.decode_panelSizes(1) = 290;
EStudio_gui_erp_totl.decode_panel{2} = f_decode_MVPA_GUI(EStudio_gui_erp_totl.decode_settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.decode_panelSizes(2) = 530;
EStudio_gui_erp_totl.decode_panel{3} = f_decode_mvpcsetsGUI(EStudio_gui_erp_totl.decode_settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.decode_panelSizes(3) = 290;
EStudio_gui_erp_totl.decode_panel{4} = f_MVPCset_plot_setting_GUI(EStudio_gui_erp_totl.decode_settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.decode_panelSizes(4) = 390;
disp('Pattern Classification: Launching BESTsets, Multivariate Pattern Classification, MVPCsets, Plotting MVPCsets,...');
EStudio_gui_erp_totl.decode_panel{5} = f_mvpc_grandaverageGUI(EStudio_gui_erp_totl.decode_settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.decode_panelSizes(5) = 160;
EStudio_gui_erp_totl.decode_panel{6} = f_mvpc_plotconfusionGUI(EStudio_gui_erp_totl.decode_settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.decode_panelSizes(6) = 190;
EStudio_gui_erp_totl.decode_panel{7} = f_decode_mvpclass_GUI(EStudio_gui_erp_totl.decode_settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.decode_panelSizes(7) = 190;
EStudio_gui_erp_totl.decode_panel{8} = f_decode_history_GUI(EStudio_gui_erp_totl.decode_settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.decode_panelSizes(8) = 190;
disp([32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,...
    'Average Across MVPCsets (Grand Average), Plot Confusion Matrices, MVPCset Classes, and History panels.']);
set(EStudio_gui_erp_totl.decode_settingLayout, 'Heights', EStudio_gui_erp_totl.decode_panelSizes);
EStudio_gui_erp_totl.panel_decode_scroll.Heights = sum(EStudio_gui_erp_totl.decode_panelSizes);

%% Hook up the minimize callback and IsMinimized
for Numofpanel = 1:length(EStudio_gui_erp_totl.decode_panel)
    set( EStudio_gui_erp_totl.decode_panel{Numofpanel}, 'MinimizeFcn', {@nMinimize, Numofpanel} );
end

%%shrinking Panels 4-17 to just their title-bar
whichpanel = setdiff([1:length(EStudio_gui_erp_totl.decode_panel)],[1,3]);
for Numofpanel = 1:length(whichpanel)
    minned = EStudio_gui_erp_totl.decode_panel{whichpanel(Numofpanel)}.IsMinimized;
    szs = get( EStudio_gui_erp_totl.decode_settingLayout, 'Sizes' );
    if minned
        set( EStudio_gui_erp_totl.decode_panel{whichpanel(Numofpanel)}, 'IsMinimized', false);
        szs(whichpanel(Numofpanel)) = EStudio_gui_erp_totl.decode_panelSizes(whichpanel(Numofpanel));
    else
        set( EStudio_gui_erp_totl.decode_panel{whichpanel(Numofpanel)}, 'IsMinimized', true);
        szs(whichpanel(Numofpanel)) = 25;
    end
    set( EStudio_gui_erp_totl.decode_settingLayout, 'Sizes', szs );
    EStudio_gui_erp_totl.panel_decode_scroll.Heights = sum(szs);
end %% End for shrinking panels 4-10

%% + Create the view
FonsizeDefault = f_get_default_fontsize();
estudioworkingmemory('MVPCArray',1);
EStudio_gui_erp_totl.plot_decode_grid = uix.VBox('Parent',EStudio_gui_erp_totl.decode_ViewContainer,'Padding',0,'Spacing',0,'BackgroundColor',ColorB_def);
%%legends
EStudio_gui_erp_totl.ViewAxes_legend_title = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plot_decode_grid,'BackgroundColor',[1 1 1]);
EStudio_gui_erp_totl.View_decode_Axes_legend = uix.ScrollingPanel( 'Parent', EStudio_gui_erp_totl.ViewAxes_legend_title,'BackgroundColor',[1 1 1]);
%%waves
EStudio_gui_erp_totl.plot_decode_legend = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plot_decode_grid,'BackgroundColor',[1 1 1]);
EStudio_gui_erp_totl.View_decode_Axes = uix.ScrollingPanel( 'Parent', EStudio_gui_erp_totl.plot_decode_legend,'BackgroundColor',[1 1 1]);
%%empty panel
EStudio_gui_erp_totl.decode_blank = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plot_decode_grid,'BackgroundColor',ColorB_def);%%%Message
uiextras.Empty('Parent', EStudio_gui_erp_totl.decode_blank,'BackgroundColor',ColorB_def); % 1A

EStudio_gui_erp_totl.commdecode_panel_title = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plot_decode_grid,'BackgroundColor',ColorB_def);%%%Message
EStudio_gui_erp_totl.decode_zoom_in = uicontrol('Parent',EStudio_gui_erp_totl.commdecode_panel_title,'Style','pushbutton','String','Zoom In',...
    'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
EStudio_gui_erp_totl.decode_zoom_edit = uicontrol('Parent',EStudio_gui_erp_totl.commdecode_panel_title,'Style','edit','String','100',...
    'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
EStudio_gui_erp_totl.decode_zoom_out = uicontrol('Parent',EStudio_gui_erp_totl.commdecode_panel_title,'Style','pushbutton','String','Zoom Out',...
    'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
uicontrol('Parent',EStudio_gui_erp_totl.commdecode_panel_title,'Style','text','String','',...
  'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','on');
EStudio_gui_erp_totl.decode_popmemu = uicontrol('Parent',EStudio_gui_erp_totl.commdecode_panel_title,'Style','popupmenu','String',{'Plotting Options','Automatic Plotting:On','Window Size'},...
   'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','on');
EStudio_gui_erp_totl.decode_reset = uicontrol('Parent',EStudio_gui_erp_totl.commdecode_panel_title,'Style','pushbutton','String','Reset',...
  'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','on');
uicontrol('Parent',EStudio_gui_erp_totl.commdecode_panel_title,'Style','text','String','',...
  'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','on');
set(EStudio_gui_erp_totl.commdecode_panel_title, 'Sizes', [70 50 70 -1 150 50 5]);
%%message
xaxis_panel = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plot_decode_grid,'BackgroundColor',ColorB_def);%%%Message
EStudio_gui_erp_totl.Process_decode_messg = uicontrol('Parent',xaxis_panel,'Style','text','String','','FontSize',FonsizeDefault,'FontWeight','bold','BackgroundColor',ColorB_def);

EStudio_gui_erp_totl.plot_decode_grid.Heights(1) = 70;% set the first element (pageinfo) to 30px high
EStudio_gui_erp_totl.plot_decode_grid.Heights(3) = 5;
EStudio_gui_erp_totl.plot_decode_grid.Heights(4) = 30;
EStudio_gui_erp_totl.plot_decode_grid.Heights(5) = 30;

end
%%-------------------------------------------------------------------------
%%-----------------------------Subfunctions--------------------------------
%%-------------------------------------------------------------------------

% 
function nMinimize( eventSource, eventData, whichpanel ) %#ok<INUSL>
global EStudio_gui_erp_totl;

try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.7020 0.77 0.85];
end
minned = EStudio_gui_erp_totl.decode_panel{whichpanel}.IsMinimized;
szs = get( EStudio_gui_erp_totl.decode_settingLayout, 'Sizes' );
if minned
    set( EStudio_gui_erp_totl.decode_panel{whichpanel}, 'IsMinimized', false);
    szs(whichpanel) = EStudio_gui_erp_totl.decode_panelSizes(whichpanel);
else
    set( EStudio_gui_erp_totl.decode_panel{whichpanel}, 'IsMinimized', true);
    szs(whichpanel) = 25;
end
set( EStudio_gui_erp_totl.decode_settingLayout, 'Sizes', szs ,'BackgroundColor',ColorB_def);
EStudio_gui_erp_totl.panel_decode_scroll.Heights = sum(szs);
set(EStudio_gui_erp_totl.panel_decode_scroll,'BackgroundColor',ColorB_def);
end % nMinimize
