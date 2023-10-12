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


%%Bin-based epoch
MyViewer_binepoch = estudioworkingmemory('EEGTab_binepoch');
if ~isempty(MyViewer_binepoch) && MyViewer_binepoch==1
    messgStr  = char( 'Changes on "Extract Bin-based Epochs" have not been applied');
    eegpanelIndex =6;
end


%%edit chan
%%Bin-based epoch
MyViewer_editchan = estudioworkingmemory('EEGTab_editchan');
if ~isempty(MyViewer_editchan) && MyViewer_editchan==1
    messgStr  = char( 'Changes on "Edit Channels" have not been applied');
    eegpanelIndex =7;
end



%%interpolate
MyViewer_interpolatechan = estudioworkingmemory('EEGTab_interpolated_chan_epoch');
if ~isempty(MyViewer_interpolatechan) && MyViewer_interpolatechan==1
    messgStr  = char( 'Changes on "Interpolate chan for epoched EEG" have not been applied');
    eegpanelIndex =8;
end

%%detect artifact for epoched EEG
MyViewer_detectartepoch = estudioworkingmemory('EEGTab_detect_arts_epoch');
if ~isempty(MyViewer_detectartepoch) && MyViewer_detectartepoch==1
    messgStr  = char( 'Changes on "Artifact Detection for Epoched EEG" have not been applied');
    eegpanelIndex =9;
end



%%detect artifact for continuous EEG
MyViewer_detectartepoch = estudioworkingmemory('EEGTab_detect_arts_conus');
if ~isempty(MyViewer_detectartepoch) && MyViewer_detectartepoch==1
    messgStr  = char( 'Changes on "Artifact Detection for Continuous EEG" have not been applied');
    eegpanelIndex =10;
end


%%delete time segements
MyViewer_detectartepoch = estudioworkingmemory('EEGTab_detect_segmt_conus');
if ~isempty(MyViewer_detectartepoch) && MyViewer_detectartepoch==1
    messgStr  = char( 'Changes on "Delete Time Segments for Continuous EEG" have not been applied');
    eegpanelIndex =11;
end



%%Shift Event Codes for Continuous EEG
MyViewer_detectartepoch = estudioworkingmemory('EEGTab_shiftcodes_conus');
if ~isempty(MyViewer_detectartepoch) && MyViewer_detectartepoch==1
    messgStr  = char( 'Changes on "Shift Event Codes for Continuous EEG" have not been applied');
    eegpanelIndex =12;
end



%%Remove response mistakes for Continuous EEG
MyViewer_detectartepoch = estudioworkingmemory('EEGTab_rmresposmistak_conus');
if ~isempty(MyViewer_detectartepoch) && MyViewer_detectartepoch==1
    messgStr  = char( 'Changes on "Remove Response Mistakes for Continuous EEG" have not been applied');
    eegpanelIndex =13;
end



return;
