function [messgStr,bestpanelIndex]= f_check_decodetab_panelchanges()

messgStr = '';
bestpanelIndex = 0;



MyViewer_chanbin = estudioworkingmemory('ERPTab_plotset');
if ~isempty(MyViewer_chanbin) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Plot Setting" have not been applied');
    bestpanelIndex =1;
    return;
end


return;
