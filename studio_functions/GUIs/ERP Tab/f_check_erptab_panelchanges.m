function [messgStr,erpanelIndex]= f_check_erptab_panelchanges()

messgStr = '';
erpanelIndex = 0;



MyViewer_chanbin = erpworkingmemory('ERPTab_chanbin');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Bin and Channel Selection" have not been applied');
    erpanelIndex =1;
end


MyViewer_chanbin = erpworkingmemory('ERPTab_plotset');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Plot Setting" have not been applied');
    erpanelIndex =2;
end



%%topos
MyViewer_chanbin = erpworkingmemory('ERPTab_topos');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Plot Scalp Maps" have not been applied');
    erpanelIndex =3;
end

%%baseline correction & detrend
MyViewer_chanbin = erpworkingmemory('ERPTab_baseline_detrend');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Baseline Correction & Linear Detrend" have not been applied');
    erpanelIndex =4;
end



%%filter
MyViewer_chanbin = erpworkingmemory('ERPTab_filter');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Filtering" have not been applied');
    erpanelIndex =5;
end



MyViewer_chanbin = erpworkingmemory('ERPTab_chanop');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "ERP Channel Operations" have not been applied');
    erpanelIndex =6;
end


MyViewer_chanbin = erpworkingmemory('ERPTab_binop');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "ERP Bin Operations" have not been applied');
    erpanelIndex =7;
end


MyViewer_chanbin = erpworkingmemory('ERPTab_csd');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Convert Voltage to CSD" have not been applied');
    erpanelIndex =8;
end


MyViewer_chanbin = erpworkingmemory('ERPTab_spectral');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Spectral Analysis" have not been applied');
    erpanelIndex =9;
end


MyViewer_chanbin = erpworkingmemory('ERPTab_mesuretool');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "ERP Measurement Tool" have not been applied');
    erpanelIndex =10;
end


MyViewer_chanbin = erpworkingmemory('ERPTab_gravg');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Average across ERPsets" have not been applied');
    erpanelIndex =11;
end


MyViewer_chanbin = erpworkingmemory('ERPTab_append');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Append ERPsets" have not been applied');
    erpanelIndex =12;
end



MyViewer_chanbin = erpworkingmemory('ERPTab_stimulation');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Create Artificial ERP Waveform" have not been applied');
    erpanelIndex =13;
end


MyViewer_chanbin = erpworkingmemory('ERPTab_resample');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Resample ERPsets" have not been applied');
    erpanelIndex =14;
end



MyViewer_chanbin = erpworkingmemory('ERPTab_editchan');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Edit Channel Info" have not been applied');
    erpanelIndex =15;
end



return;
