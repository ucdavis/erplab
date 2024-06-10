%%This function is to create ERP Tab


% Author: Guanghui Zhang & Steve J. Luck
% Center for Mind and Brain
% University of California, Davis
% Davis, CA
% 2022 & 2023



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
set( EStudio_gui_erp_totl.tabERP, 'Widths', [-4, 300]); % Viewpanel and settings panel


EStudio_gui_erp_totl.panel_fonts  = f_get_default_fontsize();
EStudio_gui_erp_totl.settingLayout = uiextras.VBox('Parent', EStudio_gui_erp_totl.panelscroll,'BackgroundColor',ColorB_def);

% + Create the settings window panels for ERP panel
EStudio_gui_erp_totl.panel{1} = f_ERP_erpsetsGUI(EStudio_gui_erp_totl.settingLayout,EStudio_gui_erp_totl.panel_fonts);
EStudio_gui_erp_totl.panelSizes(1) = 290;
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
set( EStudio_gui_erp_totl.panel{1}, 'MinimizeFcn', {@nMinimize, 1} );
set( EStudio_gui_erp_totl.panel{2}, 'MinimizeFcn', {@nMinimize, 2} );
set( EStudio_gui_erp_totl.panel{3}, 'MinimizeFcn', {@nMinimize, 3} );
set( EStudio_gui_erp_totl.panel{4}, 'MinimizeFcn', {@nMinimize, 4} );
set( EStudio_gui_erp_totl.panel{5}, 'MinimizeFcn', {@nMinimize, 5} );
set( EStudio_gui_erp_totl.panel{6}, 'MinimizeFcn', {@nMinimize, 6} );
set( EStudio_gui_erp_totl.panel{7}, 'MinimizeFcn', {@nMinimize, 7} );
set( EStudio_gui_erp_totl.panel{8}, 'MinimizeFcn', {@nMinimize, 8} );
set( EStudio_gui_erp_totl.panel{9}, 'MinimizeFcn', {@nMinimize, 9} );
set( EStudio_gui_erp_totl.panel{10}, 'MinimizeFcn', {@nMinimize, 10} );
set( EStudio_gui_erp_totl.panel{11}, 'MinimizeFcn', {@nMinimize, 11} );
set( EStudio_gui_erp_totl.panel{12}, 'MinimizeFcn', {@nMinimize, 12} );
set( EStudio_gui_erp_totl.panel{13}, 'MinimizeFcn', {@nMinimize, 13} );
set( EStudio_gui_erp_totl.panel{14}, 'MinimizeFcn', {@nMinimize, 14} );
set( EStudio_gui_erp_totl.panel{15}, 'MinimizeFcn', {@nMinimize, 15} );
set( EStudio_gui_erp_totl.panel{16}, 'MinimizeFcn', {@nMinimize, 16} );
set( EStudio_gui_erp_totl.panel{17}, 'MinimizeFcn', {@nMinimize, 17} );
set( EStudio_gui_erp_totl.panel{18}, 'MinimizeFcn', {@nMinimize, 18} );
set( EStudio_gui_erp_totl.panel{19}, 'MinimizeFcn', {@nMinimize, 19} );
set( EStudio_gui_erp_totl.panel{20}, 'MinimizeFcn', {@nMinimize, 20} );
%%shrinking Panels 4-17 to just their title-bar
whichpanel = [3:20];
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
p = EStudio_gui_erp_totl.ViewContainer;
EStudio_gui_erp_totl.ViewAxes = uiextras.HBox( 'Parent', p,'BackgroundColor',ColorB_def);
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
