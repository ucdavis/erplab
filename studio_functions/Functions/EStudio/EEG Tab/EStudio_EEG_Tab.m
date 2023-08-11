%%This function is to create ERP Tab


% Author: Guanghui Zhang & Steve J. Luck
% Center for Mind and Brain
% University of California, Davis
% Davis, CA
% 2023



function EStudio_gui_erp_totl = EStudio_EEG_Tab(EStudio_gui_erp_totl,ColorB_def)
% global observe_ERPDAT;
% global viewer_ERPDAT;
% global EStudio_gui_erp_totl;

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


EStudio_gui_erp_totl.eegpanel_fonts  = f_get_default_fontsize();

EStudio_gui_erp_totl.eegsettingLayout = uiextras.VBox('Parent', EStudio_gui_erp_totl.eegpanelscroll,'BackgroundColor',ColorB_def);

% + Create the settings window panels for ERP panel
EStudio_gui_erp_totl.eegpanel{1} = f_EEG_eeg_sets_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(1) = 320;
EStudio_gui_erp_totl.eegpanel{2} = f_EEG_IC_channel_GUI(EStudio_gui_erp_totl.eegsettingLayout,EStudio_gui_erp_totl.eegpanel_fonts);
EStudio_gui_erp_totl.eegpanelSizes(2) = 250;
% EStudio_gui_erp_totl.panel{3} = f_ERP_plot_setting_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
% EStudio_gui_erp_totl.panelSizes(3) = 230;
% 
% EStudio_gui_erp_totl.panel{4} = f_ERP_plot_scalp_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
% EStudio_gui_erp_totl.panelSizes(4) = 365;
% 
% EStudio_gui_erp_totl.panel{5} =  f_ERP_baselinecorr_detrend_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
% EStudio_gui_erp_totl.panelSizes(5) = 220;
% EStudio_gui_erp_totl.panel{6} = f_ERP_filtering_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
% EStudio_gui_erp_totl.panelSizes(6) = 245;
% 
% EStudio_gui_erp_totl.panel{7} = f_ERP_chanoperation_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
% EStudio_gui_erp_totl.panelSizes(7) = 350;
% 
% EStudio_gui_erp_totl.panel{8} = f_ERP_binoperation_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
% EStudio_gui_erp_totl.panelSizes(8) = 310;
% 
% EStudio_gui_erp_totl.panel{9} = f_ERP_CSD_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
% EStudio_gui_erp_totl.panelSizes(9) = 450;
% 
% EStudio_gui_erp_totl.panel{10} = f_ERP_spectral_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
% EStudio_gui_erp_totl.panelSizes(10) = 125;
% EStudio_gui_erp_totl.panel{11} = f_ERP_measurement_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
% EStudio_gui_erp_totl.panelSizes(11) = 240;
% EStudio_gui_erp_totl.panel{12} = f_ERP_grandaverageGUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
% EStudio_gui_erp_totl.panelSizes(12) = 260;
% 
% EStudio_gui_erp_totl.panel{13} = f_ERP_append_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
% EStudio_gui_erp_totl.panelSizes(13) = 120;
% 
% EStudio_gui_erp_totl.panel{14} =  f_ERP_history_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
% EStudio_gui_erp_totl.panelSizes(14) = 250;
% EStudio_gui_erp_totl.panel{15} = f_erp_informtion_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
% EStudio_gui_erp_totl.panelSizes(15) = 170;
% EStudio_gui_erp_totl.panel{16} = f_erp_dataquality_SME_GUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
% EStudio_gui_erp_totl.panelSizes(16) = 160;
% 
% EStudio_gui_erp_totl.panel{17} = f_ERP_simulation_panel(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
% EStudio_gui_erp_totl.panelSizes(17) = 820;

set(EStudio_gui_erp_totl.eegsettingLayout, 'Heights', EStudio_gui_erp_totl.eegpanelSizes);
EStudio_gui_erp_totl.eegpanelscroll.Heights = sum(EStudio_gui_erp_totl.eegpanelSizes);

%% Hook up the minimize callback and IsMinimized
set( EStudio_gui_erp_totl.eegpanel{1}, 'MinimizeFcn', {@nMinimize, 1} );
set( EStudio_gui_erp_totl.eegpanel{2}, 'MinimizeFcn', {@nMinimize, 2} );
% set( EStudio_gui_erp_totl.panel{3}, 'MinimizeFcn', {@nMinimize, 3} );
% set( EStudio_gui_erp_totl.panel{4}, 'MinimizeFcn', {@nMinimize, 4} );
% set( EStudio_gui_erp_totl.panel{5}, 'MinimizeFcn', {@nMinimize, 5} );
% set( EStudio_gui_erp_totl.panel{6}, 'MinimizeFcn', {@nMinimize, 6} );
% set( EStudio_gui_erp_totl.panel{7}, 'MinimizeFcn', {@nMinimize, 7} );
% set( EStudio_gui_erp_totl.panel{8}, 'MinimizeFcn', {@nMinimize, 8} );
% set( EStudio_gui_erp_totl.panel{9}, 'MinimizeFcn', {@nMinimize, 9} );
% set( EStudio_gui_erp_totl.panel{10}, 'MinimizeFcn', {@nMinimize, 10} );
% set( EStudio_gui_erp_totl.panel{11}, 'MinimizeFcn', {@nMinimize, 11} );
% set( EStudio_gui_erp_totl.panel{12}, 'MinimizeFcn', {@nMinimize, 12} );
% set( EStudio_gui_erp_totl.panel{13}, 'MinimizeFcn', {@nMinimize, 13} );
% set( EStudio_gui_erp_totl.panel{14}, 'MinimizeFcn', {@nMinimize, 14} );
% set( EStudio_gui_erp_totl.panel{15}, 'MinimizeFcn', {@nMinimize, 15} );
% set( EStudio_gui_erp_totl.panel{16}, 'MinimizeFcn', {@nMinimize, 16} );
% set( EStudio_gui_erp_totl.panel{17}, 'MinimizeFcn', {@nMinimize, 17} );
%%shrinking Panels 4-17 to just their title-bar
whichpanel = [2:2];
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
end %% End for shrinking panels 4-10

%% + Create the view
p = EStudio_gui_erp_totl.eegViewContainer;
EStudio_gui_erp_totl.eegViewAxes = uiextras.HBox( 'Parent', p,'BackgroundColor',ColorB_def);

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
