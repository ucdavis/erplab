%%This function is to create ERP Tab


% Author: Guanghui Zhang, David Garrett & Steve J. Luck
% Center for Mind and Brain
% University of California, Davis
% Davis, CA
% 2022-2025



function EStudio_gui_erp_totl = EStudio_ERP_Tab(EStudio_gui_erp_totl,ColorB_def)

if isempty(ColorB_def)
    ColorB_def = [0.7020 0.77 0.85];
end

%% Arrange the main interface for ERP panel (Tab3)
EStudio_gui_erp_totl.ViewBox = uix.VBox('Parent', EStudio_gui_erp_totl.tabERP,'BackgroundColor',ColorB_def);
EStudio_gui_erp_totl.ViewPanel = uix.BoxPanel('Parent', EStudio_gui_erp_totl.ViewBox,'TitleColor',ColorB_def,'ForegroundColor','k');%
EStudio_gui_erp_totl.ViewContainer = uicontainer('Parent', EStudio_gui_erp_totl.ViewPanel);

EStudio_gui_erp_totl.panelscroll = uix.ScrollingPanel('Parent', EStudio_gui_erp_totl.tabERP);
set(EStudio_gui_erp_totl.panelscroll,'BackgroundColor',ColorB_def);
set(EStudio_gui_erp_totl.tabERP, 'Widths', [-4, 300]); % Viewpanel and settings panel


EStudio_gui_erp_totl.panel_fonts  = f_get_default_fontsize();
EStudio_gui_erp_totl.settingLayout = uiextras.VBox('Parent', EStudio_gui_erp_totl.panelscroll,'BackgroundColor',ColorB_def);

% + Create the settings window panels for ERP panel
EStudio_gui_erp_totl.panel{1} = f_ERP_erpsetsGUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.panelSizes(1) = 330;
EStudio_gui_erp_totl.panel{2} = f_ERP_bin_channel_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.panelSizes(2) = 320;
EStudio_gui_erp_totl.panel{3} = f_ERP_plot_setting_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.panelSizes(3) = 390;
EStudio_gui_erp_totl.panel{4} = f_ERP_plot_scalp_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.panelSizes(4) = 390;
disp('ERP Tab: Launching ERPsets, Bin & Channel Selection, Plot Settings, Plot Scalp Maps,...');
EStudio_gui_erp_totl.panel{5} = f_ERP_edit_channel_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.panelSizes(5) = 170;
EStudio_gui_erp_totl.panel{6} = f_ERP_chanoperation_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.panelSizes(6) = 330;
EStudio_gui_erp_totl.panel{7} = f_erp_informtion_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.panelSizes(7) = 410;
EStudio_gui_erp_totl.panel{8} = f_ERP_resample_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.panelSizes(8) = 190;
disp([32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,...
    'Edit/Delete Channels & Locations, Channel Operation, ERP & Bin Information, Sampling Rate & Epoch,...']);
EStudio_gui_erp_totl.panel{9} = f_ERP_binoperation_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.panelSizes(9) = 310;
EStudio_gui_erp_totl.panel{10} = f_ERP_filtering_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.panelSizes(10) = 230;
EStudio_gui_erp_totl.panel{11} =  f_ERP_baselinecorr_detrend_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.panelSizes(11) = 220;
EStudio_gui_erp_totl.panel{12} = f_ERP_grandaverageGUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.panelSizes(12) = 260;
disp([32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,...
    'Bin Operations, Filtering, Baseline Correction & Linear Detrend, Average Across ERPsets (Grand Average),...']);
EStudio_gui_erp_totl.panel{13} = f_ERP_append_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.panelSizes(13) = 120;
EStudio_gui_erp_totl.panel{14} = f_ERP_measurement_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.panelSizes(14) = 230;
EStudio_gui_erp_totl.panel{15} = f_ERP_events_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.panelSizes(15) = 100;
EStudio_gui_erp_totl.panel{16} = f_erp_dataquality_SME_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.panelSizes(16) = 220;
disp([32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,...
    'Append ERPsets, Measurement Tool, EventList, View Data Quality Metrics,...']);
EStudio_gui_erp_totl.panel{17} = f_ERP_CSD_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.panelSizes(17) = 190;
EStudio_gui_erp_totl.panel{18} = f_ERP_spectral_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.panelSizes(18) = 160;
EStudio_gui_erp_totl.panel{19} = f_ERP_simulation_panel(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.panelSizes(19) = 820;
EStudio_gui_erp_totl.panel{20} =  f_ERP_history_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.panelSizes(20) = 280;
disp([32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,...
    'Convert Voltage to CSD, Spectral Analysis, Create Artificial ERP Waveform, and History panels']);
set(EStudio_gui_erp_totl.settingLayout, 'Heights', EStudio_gui_erp_totl.panelSizes);
EStudio_gui_erp_totl.panelscroll.Heights = sum(EStudio_gui_erp_totl.panelSizes);

%% Hook up the minimize callback and IsMinimized
for Numofpanel = 1:length(EStudio_gui_erp_totl.panel)
    set( EStudio_gui_erp_totl.panel{Numofpanel}, 'MinimizeFcn', {@nMinimize, Numofpanel} );
end

%%shrinking Panels 4-17 to just their title-bar
whichpanel = [3:length(EStudio_gui_erp_totl.panel)];
for Numofpanel = 1:length(whichpanel)
    minned = EStudio_gui_erp_totl.panel{whichpanel(Numofpanel)}.IsMinimized;
    szs = get( EStudio_gui_erp_totl.settingLayout, 'Sizes' );
    if minned
        set( EStudio_gui_erp_totl.panel{whichpanel(Numofpanel)}, 'IsMinimized', false);
        szs(whichpanel(Numofpanel)) = EStudio_gui_erp_totl.panelSizes(whichpanel(Numofpanel));
    else
        set( EStudio_gui_erp_totl.panel{whichpanel(Numofpanel)}, 'IsMinimized', true);
        szs(whichpanel(Numofpanel)) = 25;
    end
    set( EStudio_gui_erp_totl.settingLayout, 'Sizes', szs );
    EStudio_gui_erp_totl.panelscroll.Heights = sum(szs);
end %% End for shrinking panels 4-10

%% + Create the view
FonsizeDefault = f_get_default_fontsize();
p = EStudio_gui_erp_totl.ViewContainer;
EStudio_gui_erp_totl.ViewAxes = uiextras.HBox( 'Parent', p,'BackgroundColor',ColorB_def);
pageNum=1;
pagecurrentNum=1;
PageStr = 'No ERPset was loaded';
estudioworkingmemory('selectederpstudio',1);
EStudio_gui_erp_totl.plotgrid = uix.VBox('Parent',EStudio_gui_erp_totl.ViewContainer,'Padding',0,'Spacing',0,'BackgroundColor',ColorB_def);
pageinfo_box = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plotgrid,'BackgroundColor',ColorB_def);
%%legends
ViewAxes_legend_title = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plotgrid,'BackgroundColor',[1 1 1]);
EStudio_gui_erp_totl.ViewAxes_legend = uix.ScrollingPanel( 'Parent', ViewAxes_legend_title,'BackgroundColor',[1 1 1]);
%%waves
EStudio_gui_erp_totl.plot_wav_legend = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plotgrid,'BackgroundColor',[1 1 1]);
EStudio_gui_erp_totl.ViewAxes = uix.ScrollingPanel( 'Parent', EStudio_gui_erp_totl.plot_wav_legend,'BackgroundColor',[1 1 1]);

EStudio_gui_erp_totl.blank = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plotgrid,'BackgroundColor',ColorB_def);%%%Message
uiextras.Empty('Parent', EStudio_gui_erp_totl.blank,'BackgroundColor',ColorB_def); % 1A

%%Setting title
pageinfo_str = ['Page',32,num2str(pagecurrentNum),'/',num2str(pageNum),':',32,PageStr];
EStudio_gui_erp_totl.pageinfo_text = uicontrol('Parent',pageinfo_box,'Style','text','String',pageinfo_str,'FontSize',FonsizeDefault);
EStudio_gui_erp_totl.pageinfo_minus = uicontrol('Parent',pageinfo_box,'Style', 'pushbutton', 'String', 'Prev.','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
EStudio_gui_erp_totl.pageinfo_edit = uicontrol('Parent',pageinfo_box,'Style', 'edit', 'String', num2str(pagecurrentNum),'FontSize',FonsizeDefault+2,'BackgroundColor',[1 1 1],'Enable','off');
EStudio_gui_erp_totl.pageinfo_plus = uicontrol('Parent',pageinfo_box,'Style', 'pushbutton', 'String', 'Next','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
Enable_plus_BackgroundColor = [1 1 1];
Enable_minus_BackgroundColor = [0 0 0];
EStudio_gui_erp_totl.pageinfo_plus.ForegroundColor = Enable_plus_BackgroundColor;
EStudio_gui_erp_totl.pageinfo_minus.ForegroundColor = Enable_minus_BackgroundColor;
set(pageinfo_box, 'Sizes', [-1 70 50 70] );
set(pageinfo_box,'BackgroundColor',ColorB_def);
set(EStudio_gui_erp_totl.pageinfo_text,'BackgroundColor',ColorB_def);

EStudio_gui_erp_totl.eegtab_command = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plotgrid,'BackgroundColor',ColorB_def);%%%Message
uiextras.Empty('Parent', EStudio_gui_erp_totl.eegtab_command); % 1A
EStudio_gui_erp_totl.erp_reset = uicontrol('Parent',EStudio_gui_erp_totl.eegtab_command,'Style','pushbutton','String','Reset',...
    'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
EStudio_gui_erp_totl.erp_popmenu = uicontrol('Parent',EStudio_gui_erp_totl.eegtab_command,'Style','pushbutton','String','Reset',...
    'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','on');
uiextras.Empty('Parent', EStudio_gui_erp_totl.eegtab_command); % 1A
set(EStudio_gui_erp_totl.eegtab_command, 'Sizes', [-1 150 50 5]);
%%message
xaxis_panel = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plotgrid,'BackgroundColor',ColorB_def);%%%Message
EStudio_gui_erp_totl.Process_messg = uicontrol('Parent',xaxis_panel,'Style','text','String','','FontSize',FonsizeDefault,'FontWeight','bold','BackgroundColor',ColorB_def);
EStudio_gui_erp_totl.advanced_viewer.Enable = 'off';
EStudio_gui_erp_totl.plotgrid.Heights(1) = 30;
EStudio_gui_erp_totl.plotgrid.Heights(2) = 70;% set the first element (pageinfo) to 30px high
EStudio_gui_erp_totl.plotgrid.Heights(4) = 5;
EStudio_gui_erp_totl.plotgrid.Heights(5) = 30;
EStudio_gui_erp_totl.plotgrid.Heights(6) = 30;
end


function nMinimize( eventSource, eventData, whichpanel ) %#ok<INUSL>
global EStudio_gui_erp_totl;

try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.7020 0.77 0.85];
end
minned = EStudio_gui_erp_totl.panel{whichpanel}.IsMinimized;
szs = get( EStudio_gui_erp_totl.settingLayout, 'Sizes' );
if minned
    set( EStudio_gui_erp_totl.panel{whichpanel}, 'IsMinimized', false);
    szs(whichpanel) = EStudio_gui_erp_totl.panelSizes(whichpanel);
else
    set( EStudio_gui_erp_totl.panel{whichpanel}, 'IsMinimized', true);
    szs(whichpanel) = 25;
end
set( EStudio_gui_erp_totl.settingLayout, 'Sizes', szs ,'BackgroundColor',ColorB_def);
EStudio_gui_erp_totl.panelscroll.Heights = sum(szs);
set(EStudio_gui_erp_totl.panelscroll,'BackgroundColor',ColorB_def);
end % nMinimize
