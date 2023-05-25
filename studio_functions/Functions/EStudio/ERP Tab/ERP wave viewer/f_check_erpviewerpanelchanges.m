function [messgStr,viewerpanelIndex ]= f_check_erpviewerpanelchanges()

messgStr = '';
viewerpanelIndex = 0;


MyViewer_ERPset = estudioworkingmemory('MyViewer_ERPsetpanel');
if ~isempty(MyViewer_ERPset) && MyViewer_ERPset==1
    messgStr  = char( 'Changes on "ERPsets" have not been applied');
    viewerpanelIndex =1;
end


MyViewer_chanbin = estudioworkingmemory('MyViewer_chanbin');
if ~isempty(MyViewer_ERPset) && MyViewer_chanbin==1
    messgStr  = char( 'Changes on "Channels and Bins" have not been applied');
    viewerpanelIndex =2;
end


MyViewer_xyaxis = estudioworkingmemory('MyViewer_xyaxis');
if ~isempty(MyViewer_ERPset) && MyViewer_xyaxis==1
    messgStr  = char( 'Changes on "Time and Amplitude Scales" have not been applied');
    viewerpanelIndex =3;
end


MyViewer_plotorg = estudioworkingmemory('MyViewer_plotorg');
if ~isempty(MyViewer_ERPset) && MyViewer_plotorg==1
    messgStr  = char( 'Changes on "Plot Organization" have not been applied');
    viewerpanelIndex =4;
end

MyViewer_labels = estudioworkingmemory('MyViewer_labels');
if ~isempty(MyViewer_ERPset) && MyViewer_labels==1
    messgStr  = char( 'Changes on "Chan/Bin/ERPset Labels" have not been applied');
    viewerpanelIndex =5;
end

MyViewer_linelegend = estudioworkingmemory('MyViewer_linelegend');
if ~isempty(MyViewer_ERPset) && MyViewer_linelegend==1
    messgStr  = char( 'Changes on "Lines & legends" have not been applied');
    viewerpanelIndex =6;
end


MyViewer_other = estudioworkingmemory('MyViewer_other');
if ~isempty(MyViewer_ERPset) && MyViewer_other==1
    messgStr  = char( 'Changes on "Other" have not been applied');
    viewerpanelIndex =7;
end

return;
