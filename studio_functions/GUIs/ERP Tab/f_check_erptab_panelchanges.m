function [messgStr,erpanelIndex]= f_check_erptab_panelchanges()

messgStr = '';
erpanelIndex = 0;



MyViewer_chanbin = estudioworkingmemory('ERPTab_chanbin');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Bin and Channel Selection" have not been applied');
    erpanelIndex =1;
end


MyViewer_chanbin = estudioworkingmemory('ERPTab_plotset');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Plot Setting" have not been applied');
    erpanelIndex =2;
end



%%topos
MyViewer_chanbin = estudioworkingmemory('ERPTab_topos');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Plot Scalp Maps" have not been applied');
    erpanelIndex =3;
end

%%baseline correction & detrend
MyViewer_chanbin = estudioworkingmemory('ERPTab_baseline_detrend');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Baseline Correction & Linear Detrend" have not been applied');
    erpanelIndex =4;
end



return;
