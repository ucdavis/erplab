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
EStudio_gui_erp_totl.decode_panel{4} = f_mvpc_grandaverageGUI(EStudio_gui_erp_totl.decode_settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.decode_panelSizes(4) = 160;
EStudio_gui_erp_totl.decode_panel{5} = f_MVPCset_plot_setting_GUI(EStudio_gui_erp_totl.decode_settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.decode_panelSizes(5) = 390;

EStudio_gui_erp_totl.panel_decode_scroll.Heights = sum(EStudio_gui_erp_totl.decode_panelSizes);

%% Hook up the minimize callback and IsMinimized
for Numofpanel = 1:length(EStudio_gui_erp_totl.decode_panel)
    set( EStudio_gui_erp_totl.decode_panel{Numofpanel}, 'MinimizeFcn', {@nMinimize, Numofpanel} );
end

%%shrinking Panels 4-17 to just their title-bar
whichpanel = [1:length(EStudio_gui_erp_totl.decode_panel)];
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

estudioworkingmemory('MVPCArray',1);
EStudio_gui_erp_totl.plot_decode_grid = uix.VBox('Parent',EStudio_gui_erp_totl.decode_ViewContainer,'Padding',0,'Spacing',0,'BackgroundColor',ColorB_def);
%%legends
ViewAxes_legend_title = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plot_decode_grid,'BackgroundColor',[1 1 1]);
EStudio_gui_erp_totl.View_decode_Axes_legend = uix.ScrollingPanel( 'Parent', ViewAxes_legend_title,'BackgroundColor',[1 1 1]);
%%waves
EStudio_gui_erp_totl.plot_decode_legend = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plot_decode_grid,'BackgroundColor',[1 1 1]);
EStudio_gui_erp_totl.View_decode_Axes = uix.ScrollingPanel( 'Parent', EStudio_gui_erp_totl.plot_decode_legend,'BackgroundColor',[1 1 1]);

EStudio_gui_erp_totl.decode_blank = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plot_decode_grid,'BackgroundColor',ColorB_def);%%%Message
uiextras.Empty('Parent', EStudio_gui_erp_totl.decode_blank,'BackgroundColor',ColorB_def); % 1A


commandfig_panel = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plot_decode_grid,'BackgroundColor',ColorB_def);%%%Message
EStudio_gui_erp_totl.decode_zoom_in = uicontrol('Parent',commandfig_panel,'Style','pushbutton','String','Zoom In',...
    'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
EStudio_gui_erp_totl.decode_zoom_edit = uicontrol('Parent',commandfig_panel,'Style','edit','String','100',...
    'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
EStudio_gui_erp_totl.decode_zoom_out = uicontrol('Parent',commandfig_panel,'Style','pushbutton','String','Zoom Out',...
    'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
uiextras.Empty('Parent', commandfig_panel); % 1A

EStudio_gui_erp_totl.decode_popmemu = uicontrol('Parent',commandfig_panel,'Style','popupmenu','String',{'Plotting Options','Automatic Plotting:On','Window Size'},...
    'Callback',@popmemu_decode,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','on');
EStudio_gui_erp_totl.decode_reset = uicontrol('Parent',commandfig_panel,'Style','pushbutton','String','Reset',...
    'Callback', @decode_reset,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','on');
uiextras.Empty('Parent', commandfig_panel); % 1A
set(commandfig_panel, 'Sizes', [70 50 70 -1 150 50 5]);
%%message
xaxis_panel = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plot_decode_grid,'BackgroundColor',ColorB_def);%%%Message
EStudio_gui_erp_totl.Process_decode_messg = uicontrol('Parent',xaxis_panel,'Style','text','String','','FontSize',FonsizeDefault,'FontWeight','bold','BackgroundColor',ColorB_def);


EStudio_gui_erp_totl.advanced_viewer.Enable = 'off';
EStudio_gui_erp_totl.plot_decode_grid.Heights(1) = 70;% set the first element (pageinfo) to 30px high
EStudio_gui_erp_totl.plot_decode_grid.Heights(3) = 5;
EStudio_gui_erp_totl.plot_decode_grid.Heights(4) = 30;
EStudio_gui_erp_totl.plot_decode_grid.Heights(5) = 30;

end
%%-------------------------------------------------------------------------
%%-----------------------------Subfunctions--------------------------------
%%-------------------------------------------------------------------------

function popmemu_decode(Source,~)
global EStudio_gui_erp_totl;
global observe_DECODE;
if ~isempty(observe_DECODE.MVPC)
    return;
end
Value = Source.Value;
if Value==2
    app = feval('EStudio_plot_set_waves',EStudio_gui_erp_totl.ERP_autoplot,3);
    waitfor(app,'Finishbutton',1);
    try
        plotSet = app.output; %NO you don't want to output EEG with edited channel locations, you want to output the parameters to run decoding
        app.delete; %delete app from view
        pause(0.01); %wait for app to leave
    catch
        return;
    end
    if isempty(plotSet)||numel(plotSet)~=1 || (plotSet~=0&&plotSet~=1)
        plotSet=1;
    end
    popmemu_eegString = EStudio_gui_erp_totl.decode_popmemu.String;
    if plotSet==1
        popmemu_eegString{2} = 'Automatic Plotting: On';
    else
        popmemu_eegString{2} = 'Automatic Plotting: Off';
    end
    EStudio_gui_erp_totl.decode_popmemu.String=popmemu_eegString;
    EStudio_gui_erp_totl.Decode_autoplot = plotSet;
  
elseif Value==3
    EStudiowinsize();
end
Source.Value=1;
end

%%--------------------Setting for EStudio window size----------------------
function EStudiowinsize(~,~)
global EStudio_gui_erp_totl;
global observe_DECODE;
if ~isempty(observe_DECODE.MVPC)
    return;
end
try
    ScreenPos= EStudio_gui_erp_totl.ScreenPos;
catch
    ScreenPos =  get( 0, 'Screensize' );
end
try
    New_pos = EStudio_gui_erp_totl.Window.Position;
catch
    return;
end
try
    New_posin = estudioworkingmemory('EStudioScreenPos');
catch
    New_posin = [75,75];
end
if isempty(New_posin) ||numel(New_posin)~=2
    New_posin = [75,75];
end
New_posin(2) = abs(New_posin(2));

app = feval('EStudio_pos_gui',New_posin);
waitfor(app,'Finishbutton',1);
try
    New_pos1 = app.output; %NO you don't want to output EEG with edited channel locations, you want to output the parameters to run decoding
    app.delete; %delete app from view
    pause(0.5); %wait for app to leave
catch
    disp('User selected Cancel');
    return;
end
try New_pos1(2) = abs(New_pos1(2));catch; end;

if isempty(New_pos1) || numel(New_pos1)~=2
    estudioworkingmemory('f_ERP_proces_messg',['The defined Window Size for EStudio is invalid and it must be two numbers']);
    observe_DECODE.Process_messg =4;
    return;
end
estudioworkingmemory('EStudioScreenPos',New_pos1);
try
    POS4 = (New_pos1(2)-New_posin(2))/100;
    new_pos =[New_pos(1),New_pos(2)-ScreenPos(4)*POS4,ScreenPos(3)*New_pos1(1)/100,ScreenPos(4)*New_pos1(2)/100];
    if new_pos(2) <  -abs(new_pos(4))%%if
        
    end
    set(EStudio_gui_erp_totl.Window, 'Position', new_pos);
catch
    estudioworkingmemory('f_ERP_proces_messg',['The defined Window Size for EStudio is invalid and it must be two numbers']);
    observe_DECODE.Process_messg =4;
    set(EStudio_gui_erp_totl.Window, 'Position', [0 0 0.75*ScreenPos(3) 0.75*ScreenPos(4)]);
    estudioworkingmemory('EStudioScreenPos',[75 75]);
end
f_redrawEEG_Wave_Viewer();
f_redrawERP();
EStudio_gui_erp_totl.context_tabs.TabSize = (new_pos(3)-20)/length(EStudio_gui_erp_totl.context_tabs.TabNames);

end



%%---------------------reset parameters for decode Tab---------------------
function decode_reset(~,~)
global observe_DECODE;
if ~isempty(observe_DECODE.MVPC)
    return;
end
observe_DECODE.Reset_Best_paras_panel =1;
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
