%%This function is to create ERP Tab


% Author: Guanghui Zhang & Steve J. Luck
% Center for Mind and Brain
% University of California, Davis
% Davis, CA
% 2024



function EStudio_gui_erp_totl = EStudio_decode_Tab(EStudio_gui_erp_totl,ColorB_def)

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


EStudio_gui_erp_totl.panel_decode_scroll.Heights = sum(EStudio_gui_erp_totl.decode_panelSizes);

%% Hook up the minimize callback and IsMinimized
for Numofpanel = 1:length(EStudio_gui_erp_totl.decode_panel)
    set( EStudio_gui_erp_totl.decode_panel{Numofpanel}, 'MinimizeFcn', {@nMinimize, Numofpanel} );
end

%%shrinking Panels 4-17 to just their title-bar
whichpanel = [3:length(EStudio_gui_erp_totl.decode_panel)];
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
p = EStudio_gui_erp_totl.decode_ViewContainer;
EStudio_gui_erp_totl.View_decode_Axes = uiextras.HBox( 'Parent', p,'BackgroundColor',ColorB_def);
pageNum=1;
pagecurrentNum=1;
PageStr = 'No MVPCset was loaded';
estudioworkingmemory('MVPCArray',1);
EStudio_gui_erp_totl.plot_decode_grid = uix.VBox('Parent',EStudio_gui_erp_totl.decode_ViewContainer,'Padding',0,'Spacing',0,'BackgroundColor',ColorB_def);
pageinfo_box = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plot_decode_grid,'BackgroundColor',ColorB_def);
%%legends
ViewAxes_legend_title = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plot_decode_grid,'BackgroundColor',[1 1 1]);
EStudio_gui_erp_totl.View_decode_Axes_legend = uix.ScrollingPanel( 'Parent', ViewAxes_legend_title,'BackgroundColor',[1 1 1]);
%%waves
EStudio_gui_erp_totl.plot_decode_legend = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plot_decode_grid,'BackgroundColor',[1 1 1]);
EStudio_gui_erp_totl.View_decode_Axes = uix.ScrollingPanel( 'Parent', EStudio_gui_erp_totl.plot_decode_legend,'BackgroundColor',[1 1 1]);

EStudio_gui_erp_totl.decode_blank = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plot_decode_grid,'BackgroundColor',ColorB_def);%%%Message
uiextras.Empty('Parent', EStudio_gui_erp_totl.decode_blank,'BackgroundColor',ColorB_def); % 1A

%%Setting title
pageinfo_str = ['Page',32,num2str(pagecurrentNum),'/',num2str(pageNum),':',32,PageStr];
EStudio_gui_erp_totl.decode_pageinfo_text = uicontrol('Parent',pageinfo_box,'Style','text','String',pageinfo_str,'FontSize',FonsizeDefault);
EStudio_gui_erp_totl.decode_pageinfo_minus = uicontrol('Parent',pageinfo_box,'Style', 'pushbutton', 'String', 'Prev.','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
EStudio_gui_erp_totl.decode_pageinfo_edit = uicontrol('Parent',pageinfo_box,'Style', 'edit', 'String', num2str(pagecurrentNum),'FontSize',FonsizeDefault+2,'BackgroundColor',[1 1 1],'Enable','off');
EStudio_gui_erp_totl.decode_pageinfo_plus = uicontrol('Parent',pageinfo_box,'Style', 'pushbutton', 'String', 'Next','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
Enable_plus_BackgroundColor = [1 1 1];
Enable_minus_BackgroundColor = [0 0 0];
EStudio_gui_erp_totl.decode_pageinfo_plus.ForegroundColor = Enable_plus_BackgroundColor;
EStudio_gui_erp_totl.decode_pageinfo_minus.ForegroundColor = Enable_minus_BackgroundColor;
set(pageinfo_box, 'Sizes', [-1 70 50 70] );
set(pageinfo_box,'BackgroundColor',ColorB_def);
set(EStudio_gui_erp_totl.decode_pageinfo_text,'BackgroundColor',ColorB_def);

commandfig_panel = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plot_decode_grid,'BackgroundColor',ColorB_def);%%%Message
uiextras.Empty('Parent', commandfig_panel); % 1A
EStudio_gui_erp_totl.decode_reset = uicontrol('Parent',commandfig_panel,'Style','pushbutton','String','Reset',...
    'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
EStudio_gui_erp_totl.decode_popmenu = uicontrol('Parent',commandfig_panel,'Style','pushbutton','String','Reset',...
    'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','on');
uiextras.Empty('Parent', commandfig_panel); % 1A
set(commandfig_panel, 'Sizes', [-1 150 50 5]);
%%message
xaxis_panel = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plot_decode_grid,'BackgroundColor',ColorB_def);%%%Message
EStudio_gui_erp_totl.Process_decode_messg = uicontrol('Parent',xaxis_panel,'Style','text','String','','FontSize',FonsizeDefault,'FontWeight','bold','BackgroundColor',ColorB_def);
EStudio_gui_erp_totl.advanced_viewer.Enable = 'off';
EStudio_gui_erp_totl.plot_decode_grid.Heights(1) = 30;
EStudio_gui_erp_totl.plot_decode_grid.Heights(2) = 70;% set the first element (pageinfo) to 30px high

EStudio_gui_erp_totl.plot_decode_grid.Heights(4) = 5;
EStudio_gui_erp_totl.plot_decode_grid.Heights(5) = 30;
EStudio_gui_erp_totl.plot_decode_grid.Heights(6) = 30;
end


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
