%%This function is to create EEG Tab


% Author: Guanghui Zhang & Steve J. Luck
% Center for Mind and Brain
% University of California, Davis
% Davis, CA
% Aug. 2023



function EStudio_gui_erp_totl = EStudio_EEG_Tab(EStudio_gui_erp_totl,ColorB_def)
% global observe_ERPDAT;
% global viewer_ERPDAT;
% global EStudio_gui_erp_totl;

if isempty(ColorB_def)
    ColorB_def = [0.7020 0.77 0.85];
end
FonsizeDefault = f_get_default_fontsize();
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
EStudio_gui_erp_totl.eegpanelSizes(3) = 260;
EStudio_gui_erp_totl.eegpanel{4} = f_EEG_edit_channel_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(4) = 170;
EStudio_gui_erp_totl.eegpanel{5} = f_EEG_interpolate_chan_epoch_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(5) = 270;
EStudio_gui_erp_totl.eegpanel{6} = f_EEG_chanoperation_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(6) = 330;
EStudio_gui_erp_totl.eegpanel{7} = f_EEG_informtion_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(7) = 240;
EStudio_gui_erp_totl.eegpanel{8} = f_EEG_resample_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(8) = 190;
EStudio_gui_erp_totl.eegpanel{9} = f_EEG_events_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(9) = 350;
EStudio_gui_erp_totl.eegpanel{10} = f_EEG_filtering_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(10) = 245;
EStudio_gui_erp_totl.eegpanel{11} = f_EEG_eeglabtool_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(11) = 210;
EStudio_gui_erp_totl.eegpanel{12} = f_EEG_eeglabica_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(12) = 250;
EStudio_gui_erp_totl.eegpanel{13} = f_EEG_event2bin_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(13) = 200;
EStudio_gui_erp_totl.eegpanel{14} = f_EEG_binepoch_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(14) = 160;
EStudio_gui_erp_totl.eegpanel{15} = f_EEG_arf_det_segmt_conus_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(15) = 290;
EStudio_gui_erp_totl.eegpanel{16} = f_EEG_arf_det_conus_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(16) = 440;
EStudio_gui_erp_totl.eegpanel{17} = f_EEG_shift_eventcode_conus_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(17) = 200;
EStudio_gui_erp_totl.eegpanel{18} = f_EEG_rmresp_mistak_conus_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(18) = 130;
EStudio_gui_erp_totl.eegpanel{19} = f_EEG_dq_fre_conus_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(19) = 290;
EStudio_gui_erp_totl.eegpanel{20} = f_EEG_arf_det_epoch_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(20) = 330;
EStudio_gui_erp_totl.eegpanel{21} = f_EEG_arf_sumop_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(21) = 190;
EStudio_gui_erp_totl.eegpanel{22} = f_EEG_detrend_epoched_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(22) = 110;
EStudio_gui_erp_totl.eegpanel{23} = f_EEG_dq_epoch_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(23) = 240;
EStudio_gui_erp_totl.eegpanel{24} = f_EEG_avg_erp_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(24) = 300;
EStudio_gui_erp_totl.eegpanel{25} = f_EEG_history_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(25) = 300;
set(EStudio_gui_erp_totl.eegsettingLayout, 'Heights', EStudio_gui_erp_totl.eegpanelSizes);
EStudio_gui_erp_totl.eegpanelscroll.Heights = sum(EStudio_gui_erp_totl.eegpanelSizes);

%% Hook up the minimize callback and IsMinimized
set( EStudio_gui_erp_totl.eegpanel{1}, 'MinimizeFcn', {@nMinimize, 1} );
set( EStudio_gui_erp_totl.eegpanel{2}, 'MinimizeFcn', {@nMinimize, 2} );
set( EStudio_gui_erp_totl.eegpanel{3}, 'MinimizeFcn', {@nMinimize, 3} );
set( EStudio_gui_erp_totl.eegpanel{4}, 'MinimizeFcn', {@nMinimize, 4} );
set( EStudio_gui_erp_totl.eegpanel{5}, 'MinimizeFcn', {@nMinimize, 5} );
set( EStudio_gui_erp_totl.eegpanel{6}, 'MinimizeFcn', {@nMinimize, 6} );
set( EStudio_gui_erp_totl.eegpanel{7}, 'MinimizeFcn', {@nMinimize, 7} );
set( EStudio_gui_erp_totl.eegpanel{8}, 'MinimizeFcn', {@nMinimize, 8} );
set( EStudio_gui_erp_totl.eegpanel{9}, 'MinimizeFcn', {@nMinimize, 9} );
set( EStudio_gui_erp_totl.eegpanel{10}, 'MinimizeFcn', {@nMinimize, 10} );
set( EStudio_gui_erp_totl.eegpanel{11}, 'MinimizeFcn', {@nMinimize, 11} );
set( EStudio_gui_erp_totl.eegpanel{12}, 'MinimizeFcn', {@nMinimize, 12} );
set( EStudio_gui_erp_totl.eegpanel{13}, 'MinimizeFcn', {@nMinimize, 13} );
set( EStudio_gui_erp_totl.eegpanel{14}, 'MinimizeFcn', {@nMinimize, 14} );
set( EStudio_gui_erp_totl.eegpanel{15}, 'MinimizeFcn', {@nMinimize, 15} );
set( EStudio_gui_erp_totl.eegpanel{16}, 'MinimizeFcn', {@nMinimize, 16} );
set( EStudio_gui_erp_totl.eegpanel{17}, 'MinimizeFcn', {@nMinimize, 17} );
set( EStudio_gui_erp_totl.eegpanel{18}, 'MinimizeFcn', {@nMinimize, 18} );
set( EStudio_gui_erp_totl.eegpanel{19}, 'MinimizeFcn', {@nMinimize, 19} );
set( EStudio_gui_erp_totl.eegpanel{20}, 'MinimizeFcn', {@nMinimize, 20} );
set( EStudio_gui_erp_totl.eegpanel{21}, 'MinimizeFcn', {@nMinimize, 21} );
set( EStudio_gui_erp_totl.eegpanel{22}, 'MinimizeFcn', {@nMinimize, 22} );
set( EStudio_gui_erp_totl.eegpanel{23}, 'MinimizeFcn', {@nMinimize, 23} );
set( EStudio_gui_erp_totl.eegpanel{24}, 'MinimizeFcn', {@nMinimize, 24} );
set( EStudio_gui_erp_totl.eegpanel{25}, 'MinimizeFcn', {@nMinimize, 25} );
%%shrinking Panels 4-24 to just their title-bar
whichpanel = [4:25];
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
peeg = EStudio_gui_erp_totl.eegViewContainer;
EStudio_gui_erp_totl.eegViewAxes = uiextras.HBox( 'Parent', peeg,'BackgroundColor',ColorB_def);
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
