function [messgStr,erpanelIndex]= f_check_erptab_panelchanges()

messgStr = '';
erpanelIndex = 0;



MyViewer_chanbin = estudioworkingmemory('ERPTab_chanbin');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Bin and Channel Selection" have not been applied');
    erpanelIndex =1;
    return;
end


MyViewer_chanbin = estudioworkingmemory('ERPTab_plotset');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Plot Setting" have not been applied');
    erpanelIndex =2;
    return;
end



%%topos
MyViewer_chanbin = estudioworkingmemory('ERPTab_topos');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Plot Scalp Maps" have not been applied');
    erpanelIndex =3;
    return;
end

%%baseline correction & detrend
MyViewer_chanbin = estudioworkingmemory('ERPTab_baseline_detrend');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Baseline Correction & Linear Detrend" have not been applied');
    erpanelIndex =4;
    return;
end



%%filter
MyViewer_chanbin = estudioworkingmemory('ERPTab_filter');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Filtering" have not been applied');
    erpanelIndex =5;
    return;
end



MyViewer_chanbin = estudioworkingmemory('ERPTab_chanop');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "ERP Channel Operations" have not been applied');
    erpanelIndex =6;
    return;
end


MyViewer_chanbin = estudioworkingmemory('ERPTab_binop');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "ERP Bin Operations" have not been applied');
    erpanelIndex =7;
    return;
end


MyViewer_chanbin = estudioworkingmemory('ERPTab_csd');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Convert Voltage to CSD" have not been applied');
    erpanelIndex =8;
end


MyViewer_chanbin = estudioworkingmemory('ERPTab_spectral');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Spectral Analysis" have not been applied');
    erpanelIndex =9;
    return;
end


MyViewer_chanbin = estudioworkingmemory('ERPTab_mesuretool');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "ERP Measurement Tool" have not been applied');
    erpanelIndex =10;
    return;
end


MyViewer_chanbin = estudioworkingmemory('ERPTab_gravg');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Average across ERPsets" have not been applied');
    erpanelIndex =11;
    return;
end


MyViewer_chanbin = estudioworkingmemory('ERPTab_append');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Append ERPsets" have not been applied');
    erpanelIndex =12;
    return;
end



MyViewer_chanbin = estudioworkingmemory('ERPTab_stimulation');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Create Artificial ERP Waveform" have not been applied');
    erpanelIndex =13;
    return;
end


MyViewer_chanbin = estudioworkingmemory('ERPTab_resample');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Resample ERPsets" have not been applied');
    erpanelIndex =14;
    return;
end



MyViewer_chanbin = estudioworkingmemory('ERPTab_editchan');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Edit Channel Info" have not been applied');
    erpanelIndex =15;
    return;
end



return;
