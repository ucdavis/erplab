function [messgStr,eegpanelIndex]= f_check_eegtab_panelchanges()

messgStr = '';
eegpanelIndex = 0;

MyViewer_eegset = estudioworkingmemory('EEGTab_eegset');
if ~isempty(MyViewer_eegset) && MyViewer_eegset==1
    messgStr  = char( 'Changes on "EEGsets" have not been applied');
    eegpanelIndex =100;
end


MyViewer_chanic = estudioworkingmemory('EEGTab_chanic');
if ~isempty(MyViewer_chanic) && MyViewer_chanic==1
    messgStr  = char( 'Changes on "Channel and IC Selection" have not been applied');
    eegpanelIndex =1;
end


MyViewer_plotset = estudioworkingmemory('EEGTab_plotset');
if ~isempty(MyViewer_plotset) && MyViewer_plotset==1
    messgStr  = char( 'Changes on "Plot Settings" have not been applied');
    eegpanelIndex =2;
end

%%filtering
MyViewer_filter = estudioworkingmemory('EEGTab_filter');
if ~isempty(MyViewer_filter) && MyViewer_filter==1
    messgStr  = char( 'Changes on "Filtering" have not been applied');
    eegpanelIndex =3;
end

%%Channel operations
MyViewer_chanop = estudioworkingmemory('EEGTab_chanop');
if ~isempty(MyViewer_chanop) && MyViewer_chanop==1
    messgStr  = char( 'Changes on "EEG Channel Operations" have not been applied');
    eegpanelIndex =4;
end

%%Assign events to bins
MyViewer_event2bin = estudioworkingmemory('EEGTab_event2bin');
if ~isempty(MyViewer_event2bin) && MyViewer_event2bin==1
    messgStr  = char( 'Changes on "Assign Events to Bins" have not been applied');
    eegpanelIndex =5;
end


return;
