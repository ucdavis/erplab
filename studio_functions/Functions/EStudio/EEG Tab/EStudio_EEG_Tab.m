%%This function is to create EEG Tab


% Author: Guanghui Zhang & Steve J. Luck
% Center for Mind and Brain
% University of California, Davis
% Davis, CA
% Aug. 2023



function EStudio_gui_erp_totl = EStudio_EEG_Tab(EStudio_gui_erp_totl,ColorB_def)

if isempty(ColorB_def)
    ColorB_def = [0.7020 0.77 0.85];
end

%% Arrange the main interface for ERP panel (Tab3)
EStudio_gui_erp_totl.eegViewBox = uix.VBox('Parent', EStudio_gui_erp_totl.tabEEG,'BackgroundColor',ColorB_def);
EStudio_gui_erp_totl.eegViewPanel = uix.BoxPanel('Parent', EStudio_gui_erp_totl.eegViewBox,'TitleColor',ColorB_def,'ForegroundColor','k');%
EStudio_gui_erp_totl.eegViewContainer = uicontainer('Parent', EStudio_gui_erp_totl.eegViewPanel);

EStudio_gui_erp_totl.eegpanelscroll = uix.ScrollingPanel('Parent', EStudio_gui_erp_totl.tabEEG);
set(EStudio_gui_erp_totl.eegpanelscroll,'BackgroundColor',ColorB_def);
% + Adjust the main layout
set( EStudio_gui_erp_totl.tabEEG, 'Widths', [-4, 300]); % Viewpanel and settings panel

%%-------------------------function panels---------------------------------
EStudio_gui_erp_totl.eegpanel_fonts  = f_get_default_fontsize();

EStudio_gui_erp_totl.eegsettingLayout = uiextras.VBox('Parent', EStudio_gui_erp_totl.eegpanelscroll,'BackgroundColor',ColorB_def);

% + Create the settings window panels for ERP panel
EStudio_gui_erp_totl.eegpanel{1} = f_EEG_eeg_sets_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(1) = 300;
EStudio_gui_erp_totl.eegpanel{2} = f_EEG_IC_channel_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(2) = 320;
EStudio_gui_erp_totl.eegpanel{3} = f_EEG_Plot_setting_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(3) = 290;
EStudio_gui_erp_totl.eegpanel{4} = f_EEG_edit_channel_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(4) = 170;
disp('EEG Tab: Launching EEGsets, Channel and IC Selection, Plot Settings, Edit/Delete Channels & Locations,...');
EStudio_gui_erp_totl.eegpanel{5} = f_EEG_interpolate_chan_epoch_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(5) = 290;
EStudio_gui_erp_totl.eegpanel{6} = f_EEG_chanoperation_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(6) = 330;
EStudio_gui_erp_totl.eegpanel{7} = f_EEG_informtion_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(7) = 410;
EStudio_gui_erp_totl.eegpanel{8} = f_EEG_resample_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(8) = 215;
disp([32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,...
    'Interpolate Channels, Channel Operations, EEG & Bin Information, Sampling Rate & Epoch,...']);
EStudio_gui_erp_totl.eegpanel{9} = f_EEG_events_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(9) = 430;
EStudio_gui_erp_totl.eegpanel{10} = f_EEG_filtering_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(10) = 245;
EStudio_gui_erp_totl.eegpanel{11} = f_EEG_eeglabtool_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(11) = 210;
EStudio_gui_erp_totl.eegpanel{12} = f_EEG_eeglabica_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(12) = 250;
disp([32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,...
    'EventList, Filtering, EEGLAB Tools (only for one selected dataset), EEGLAB ICA (only for one selected dataset),...']);
EStudio_gui_erp_totl.eegpanel{13} = f_EEG_event2bin_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(13) = 200;
EStudio_gui_erp_totl.eegpanel{14} = f_EEG_binepoch_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(14) = 160;
EStudio_gui_erp_totl.eegpanel{15} = f_EEG_arf_det_segmt_conus_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(15) = 290;
EStudio_gui_erp_totl.eegpanel{16} = f_EEG_arf_det_conus_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(16) = 470;
disp([32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,...
    'Assign Events to Bins (BINLISTER), Extract Bin-Based Epochs (Continuous EEG), Delete Time Segments (Continuous EEG), Reject Artifactual Time Segments (Continuous EEG),...']);
EStudio_gui_erp_totl.eegpanel{17} = f_EEG_shift_eventcode_conus_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(17) = 200;
EStudio_gui_erp_totl.eegpanel{18} = f_EEG_dq_fre_conus_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(18) = 290;
EStudio_gui_erp_totl.eegpanel{19} = f_EEG_arf_det_epoch_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(19) = 380;
EStudio_gui_erp_totl.eegpanel{20} = f_EEG_arf_sumop_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(20) = 160;
disp([32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,...
    'Shift Event Codes (Continuous EEG), Spectral Data Quality (Continuous EEG), Artifact Detection (Epoched EEG), Artifact Info & Tools (Epoched EEG),...']);
EStudio_gui_erp_totl.eegpanel{21} = f_EEG_baselinecorr_detrend_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(21) = 220;
EStudio_gui_erp_totl.eegpanel{22} = f_EEG_dq_epoch_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(22) = 240;
EStudio_gui_erp_totl.eegpanel{23} = f_EEG_avg_erp_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(23) = 300;
disp([32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,...
    'Baseline Correction & Linear Detrend (Epoched EEG), Compute Data Quality Metrics (Epoched EEG), Compute Averaged ERPs (Epoched EEG),...']);
EStudio_gui_erp_totl.eegpanel{24} = f_EEG_extr_best_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(24) = 360;
EStudio_gui_erp_totl.eegpanel{25} = f_EEG_CSD_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(25) = 190;
EStudio_gui_erp_totl.eegpanel{26} = f_EEG_utilities_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(26) = 190;
EStudio_gui_erp_totl.eegpanel{27} = f_EEG_history_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(27) = 300;
disp([32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,...
    'Extract Bin-Epoched Single Trials (BEST), Convert Voltage to CSD, EEG Utilities, and History panels.']);
set(EStudio_gui_erp_totl.eegsettingLayout, 'Heights', EStudio_gui_erp_totl.eegpanelSizes);
EStudio_gui_erp_totl.eegpanelscroll.Heights = sum(EStudio_gui_erp_totl.eegpanelSizes);

%% Hook up the minimize callback and IsMinimized
for Numofpanel = 1:length(EStudio_gui_erp_totl.eegpanel)
    set( EStudio_gui_erp_totl.eegpanel{Numofpanel}, 'MinimizeFcn', {@nMinimize, Numofpanel} );
end

%%shrinking Panels 4-27 to just their title-bar
whichpanel = [4:length(EStudio_gui_erp_totl.eegpanel)];
for Numofpanel = 1:length(whichpanel)
    minned = EStudio_gui_erp_totl.eegpanel{whichpanel(Numofpanel)}.IsMinimized;
    szs = get( EStudio_gui_erp_totl.eegsettingLayout, 'Sizes' );
    if minned
        set( EStudio_gui_erp_totl.eegpanel{whichpanel(Numofpanel)}, 'IsMinimized', false);
        szs(whichpanel(Numofpanel)) = EStudio_gui_erp_totl.eegpanelSizes(whichpanel(Numofpanel));
    else
        set( EStudio_gui_erp_totl.eegpanel{whichpanel(Numofpanel)}, 'IsMinimized', true);
        szs(whichpanel(Numofpanel)) = 25;
    end
    set( EStudio_gui_erp_totl.eegsettingLayout, 'Sizes', szs );
    EStudio_gui_erp_totl.eegpanelscroll.Heights = sum(szs);
end %% End for shrinking panels 4-23

%% + Create the view
FonsizeDefault = f_get_default_fontsize();figbgdColor = [1 1 1];
EStudio_gui_erp_totl.eegplotgrid = uix.VBox('Parent',EStudio_gui_erp_totl.eegViewContainer,'Padding',0,'Spacing',0,'BackgroundColor',ColorB_def);
%%title 
EStudio_gui_erp_totl.eegpageinfo_box = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.eegplotgrid,'BackgroundColor',ColorB_def);
EStudio_gui_erp_totl.eegpageinfo_text = uicontrol('Parent',EStudio_gui_erp_totl.eegpageinfo_box,'Style','text','String','','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
EStudio_gui_erp_totl.eegpageinfo_minus = uicontrol('Parent',EStudio_gui_erp_totl.eegpageinfo_box,'Style', 'pushbutton', 'String', 'Prev.','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
EStudio_gui_erp_totl.eegpageinfo_edit = uicontrol('Parent',EStudio_gui_erp_totl.eegpageinfo_box,'Style', 'edit', 'String', '','FontSize',FonsizeDefault+2,'BackgroundColor',[1 1 1],'Enable','off');
EStudio_gui_erp_totl.eegpageinfo_plus = uicontrol('Parent',EStudio_gui_erp_totl.eegpageinfo_box,'Style', 'pushbutton', 'String', 'Next','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
%%plot panel
EStudio_gui_erp_totl.eeg_plot_title = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.eegplotgrid,'BackgroundColor',ColorB_def);
EStudio_gui_erp_totl.eegViewAxes = uix.ScrollingPanel( 'Parent', EStudio_gui_erp_totl.eeg_plot_title,'BackgroundColor',figbgdColor);
%%empty panel
EStudio_gui_erp_totl.eegxaxis_panel1 = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.eegplotgrid,'BackgroundColor',ColorB_def);
uiextras.Empty('Parent',  EStudio_gui_erp_totl.eegxaxis_panel1,'BackgroundColor',ColorB_def);
%%plot ops
EStudio_gui_erp_totl.eeg_plot_button_title = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.eegplotgrid,'BackgroundColor',ColorB_def);%%%Message
uiextras.Empty('Parent', EStudio_gui_erp_totl.eeg_plot_button_title);
EStudio_gui_erp_totl.eeg_zoom_in_large = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','pushbutton','String','|<',...
    'FontSize',FonsizeDefault+1,'BackgroundColor',[1 1 1],'Enable','off');
EStudio_gui_erp_totl.eeg_zoom_in_fivesmall = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','pushbutton','String','-5X',...
    'FontSize',FonsizeDefault+1,'BackgroundColor',[1 1 1],'Enable','off');
EStudio_gui_erp_totl.eeg_zoom_in_small = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','pushbutton','String','-X',...
    'FontSize',FonsizeDefault+1,'BackgroundColor',[1 1 1],'Enable','off');
EStudio_gui_erp_totl.eeg_zoom_edit = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','edit','String','',...
    'FontSize',FonsizeDefault+1,'BackgroundColor',[1 1 1],'Enable','off');
EStudio_gui_erp_totl.eeg_zoom_out_small = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','pushbutton','String','+X',...
    'FontSize',FonsizeDefault+1,'BackgroundColor',[1 1 1],'Enable','off');
EStudio_gui_erp_totl.eeg_zoom_out_fivelarge = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','pushbutton','String','+5X',...
    'FontSize',FonsizeDefault+1,'BackgroundColor',[1 1 1],'Enable','off');
EStudio_gui_erp_totl.eeg_zoom_out_large = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','pushbutton','String','>|',...
    'FontSize',FonsizeDefault+1,'BackgroundColor',[1 1 1],'Enable','off');
uiextras.Empty('Parent', EStudio_gui_erp_totl.eeg_plot_button_title);
EStudio_gui_erp_totl.popmemu_eeg = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','popupmenu','String','Window Size',...
    'FontSize',FonsizeDefault,'Enable','on','BackgroundColor',ColorB_def);
EStudio_gui_erp_totl.eeg_reset = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','pushbutton','String','Reset',...
    'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
uiextras.Empty('Parent', EStudio_gui_erp_totl.eeg_plot_button_title);
set(EStudio_gui_erp_totl.eeg_plot_button_title, 'Sizes', [10 40 40 40 40 40 40 40 -1 150 50 5]);
%%message
EStudio_gui_erp_totl.eegxaxis_panel = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.eegplotgrid,'BackgroundColor',ColorB_def);%%%Message
EStudio_gui_erp_totl.eegProcess_messg = uicontrol('Parent',EStudio_gui_erp_totl.eegxaxis_panel,'Style','text','String','','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
Startimes = 0;
pageNum=1;
pagecurrentNum=1;
PageStr = 'No EEG was loaded';
EStudio_gui_erp_totl.eegpageinfo_str = ['Page',32,num2str(pagecurrentNum),'/',num2str(pageNum),':',PageStr];
EStudio_gui_erp_totl.eegpageinfo_text.String=EStudio_gui_erp_totl.eegpageinfo_str;
EStudio_gui_erp_totl.eegpageinfo_edit.String=num2str(pagecurrentNum);
Enable_minus = 'off';
Enable_plus = 'off';
Enable_plus_BackgroundColor = [1 1 1];
Enable_minus_BackgroundColor = [0 0 0];
EStudio_gui_erp_totl.eegpageinfo_minus.Enable = Enable_minus;
EStudio_gui_erp_totl.eegpageinfo_plus.Enable = Enable_plus;
EStudio_gui_erp_totl.eegpageinfo_plus.ForegroundColor = Enable_plus_BackgroundColor;
EStudio_gui_erp_totl.eegpageinfo_minus.ForegroundColor = Enable_minus_BackgroundColor;
set(EStudio_gui_erp_totl.eegpageinfo_box, 'Sizes', [-1 70 50 70] );
EStudio_gui_erp_totl.eeg_zoom_edit.String=num2str(Startimes);

EStudio_gui_erp_totl.myeegviewer = axes('Parent', EStudio_gui_erp_totl.eegViewAxes,'Color','none','Box','off',...
    'FontWeight','normal', 'XTick', [], 'YTick', [], 'Color','none','xcolor','none','ycolor','none');
EStudio_gui_erp_totl.eegplotgrid.Heights(1) = 30; % set the first element (pageinfo) to 30px high
EStudio_gui_erp_totl.eegplotgrid.Heights(3) = 5;
EStudio_gui_erp_totl.eegplotgrid.Heights(4) = 30; % set the second element (x axis) to 30px high
EStudio_gui_erp_totl.eegplotgrid.Heights(5) = 30; % set the second element (x axis) to 30px high
end


function nMinimize( eventSource, eventData, whichpanel ) %#ok<INUSL>
global EStudio_gui_erp_totl;

try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.7020 0.77 0.85];
end
minned = EStudio_gui_erp_totl.eegpanel{whichpanel}.IsMinimized;
szs = get( EStudio_gui_erp_totl.eegsettingLayout, 'Sizes' );
if minned
    set( EStudio_gui_erp_totl.eegpanel{whichpanel}, 'IsMinimized', false);
    szs(whichpanel) = EStudio_gui_erp_totl.eegpanelSizes(whichpanel);
else
    set( EStudio_gui_erp_totl.eegpanel{whichpanel}, 'IsMinimized', true);
    szs(whichpanel) = 25;
end
set( EStudio_gui_erp_totl.eegsettingLayout, 'Sizes', szs ,'BackgroundColor',ColorB_def);
EStudio_gui_erp_totl.eegpanelscroll.Heights = sum(szs);
set(EStudio_gui_erp_totl.eegpanelscroll,'BackgroundColor',ColorB_def);
end % nMinimize
