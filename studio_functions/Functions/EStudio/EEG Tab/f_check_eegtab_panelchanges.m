function [messgStr,eegpanelIndex]= f_check_eegtab_panelchanges()

messgStr = '';
eegpanelIndex = 0;

MyViewer_eegset = estudioworkingmemory('EEGTab_eegset');
if ~isempty(MyViewer_eegset) && MyViewer_eegset==1
    messgStr  = char( 'Changes on "EEGsets" have not been applied');
    eegpanelIndex =100;
    return;
end


MyViewer_chanic = estudioworkingmemory('EEGTab_chanic');
if ~isempty(MyViewer_chanic) && MyViewer_chanic==1
    messgStr  = char( 'Changes on "Channel and IC Selection" have not been applied');
    eegpanelIndex =1;
    return;
end


MyViewer_plotset = estudioworkingmemory('EEGTab_plotset');
if ~isempty(MyViewer_plotset) && MyViewer_plotset==1
    messgStr  = char( 'Changes on "Plot Settings" have not been applied');
    eegpanelIndex =2;
    return;
end

%%filtering
MyViewer_filter = estudioworkingmemory('EEGTab_filter');
if ~isempty(MyViewer_filter) && MyViewer_filter==1
    messgStr  = char( 'Changes on "Filtering" have not been applied');
    eegpanelIndex =3;
    return;
end

%%Channel operations
MyViewer_chanop = estudioworkingmemory('EEGTab_chanop');
if ~isempty(MyViewer_chanop) && MyViewer_chanop==1
    messgStr  = char( 'Changes on "Channel Operations" have not been applied');
    eegpanelIndex =4;
    return;
end

%%Assign events to bins
MyViewer_event2bin = estudioworkingmemory('EEGTab_event2bin');
if ~isempty(MyViewer_event2bin) && MyViewer_event2bin==1
    messgStr  = char( 'Changes on "Assign Events to Bins (BINLISTER)" have not been applied');
    eegpanelIndex =5;
    return;
end


%%Bin-based epoch
MyViewer_binepoch = estudioworkingmemory('EEGTab_binepoch');
if ~isempty(MyViewer_binepoch) && MyViewer_binepoch==1
    messgStr  = char( 'Changes on "Extract Bin-Based Epochs (Continuous EEG)" have not been applied');
    eegpanelIndex =6;
    return;
end


%%edit chan
%%Bin-based epoch
MyViewer_editchan = estudioworkingmemory('EEGTab_editchan');
if ~isempty(MyViewer_editchan) && MyViewer_editchan==1
    messgStr  = char( 'Changes on "Edit Channel Info" have not been applied');
    eegpanelIndex =7;
    return;
end



%%interpolate
MyViewer_interpolatechan = estudioworkingmemory('EEGTab_interpolated_chan_epoch');
if ~isempty(MyViewer_interpolatechan) && MyViewer_interpolatechan==1
    messgStr  = char( 'Changes on "Interpolate Channels" have not been applied');
    eegpanelIndex =8;
    return;
end

%%detect artifact for epoched EEG
MyViewer_detectartepoch = estudioworkingmemory('EEGTab_detect_arts_epoch');
if ~isempty(MyViewer_detectartepoch) && MyViewer_detectartepoch==1
    messgStr  = char( 'Changes on "Artifact Detection (Epoched EEG)" have not been applied');
    eegpanelIndex =9;
    return;
end



%%detect artifact for continuous EEG
MyViewer_detectartepoch = estudioworkingmemory('EEGTab_detect_arts_conus');
if ~isempty(MyViewer_detectartepoch) && MyViewer_detectartepoch==1
    messgStr  = char( 'Changes on "Delete Time Segments (Continuous EEG)" have not been applied');
    eegpanelIndex =10;
    return;
end


%%delete time segements
MyViewer_detectartepoch = estudioworkingmemory('EEGTab_detect_segmt_conus');
if ~isempty(MyViewer_detectartepoch) && MyViewer_detectartepoch==1
    messgStr  = char( 'Changes on "Reject Artifactual Time Segments (Continuous EEG)" have not been applied');
    eegpanelIndex =11;
    return;
end



%%Shift Event Codes for Continuous EEG
MyViewer_detectartepoch = estudioworkingmemory('EEGTab_shiftcodes_conus');
if ~isempty(MyViewer_detectartepoch) && MyViewer_detectartepoch==1
    messgStr  = char( 'Changes on "Shift Event Codes (Continuous EEG)" have not been applied');
    eegpanelIndex =12;
    return;
end



%%Remove response mistakes for Continuous EEG
MyViewer_detectartepoch = estudioworkingmemory('EEGTab_rmresposmistak_conus');
if ~isempty(MyViewer_detectartepoch) && MyViewer_detectartepoch==1
    messgStr  = char( 'Changes on "Remove Response Errors (Continuous EEG)" have not been applied');
    eegpanelIndex =13;
    return;
end


%%spectral data quality
MyViewer_detectartepoch = estudioworkingmemory('EEGTab_dq_fre_conus');
if ~isempty(MyViewer_detectartepoch) && MyViewer_detectartepoch==1
    messgStr  = char( 'Changes on "Spectral Data Quality (Continuous EEG)" have not been applied');
    eegpanelIndex =14;
    return;
end


%%linear detrend
MyViewer_detectartepoch = estudioworkingmemory('EEGTab_baseline_detrend');
if ~isempty(MyViewer_detectartepoch) && MyViewer_detectartepoch==1
    messgStr  = char( 'Changes on "Baseline Correction & Linear Detrend (Epoched EEG)" have not been applied');
    eegpanelIndex =15;
    return;
end

%%data quality for epoched eeg
MyViewer_detectartepoch = estudioworkingmemory('EEGTab_dq_epoch');
if ~isempty(MyViewer_detectartepoch) && MyViewer_detectartepoch==1
    messgStr  = char( 'Changes on "Data Quality Metrics (Epoched EEG)" have not been applied');
    eegpanelIndex =16;
    return;
end

%%compute averaged ERP
MyViewer_detectartepoch = estudioworkingmemory('EEGTab_avg_erp');
if ~isempty(MyViewer_detectartepoch) && MyViewer_detectartepoch==1
    messgStr  = char( 'Changes on "Compute Averaged ERPs (Epoched EEG)" have not been applied');
    eegpanelIndex =17;
    return;
end

%%compute averaged ERP
MyViewer_detectartepoch = estudioworkingmemory('EEGTab_resample');
if ~isempty(MyViewer_detectartepoch) && MyViewer_detectartepoch==1
    messgStr  = char( 'Changes on "Sampling Rate & Epoch" have not been applied');
    eegpanelIndex =18;
    return;
end



MyViewer_detectartepoch = estudioworkingmemory('EEGTab_csd');
if ~isempty(MyViewer_detectartepoch) && MyViewer_detectartepoch==1
    messgStr  = char( 'Changes on "Convert voltage to CSD" have not been applied');
    eegpanelIndex =19;
    return;
end

MyViewer_detectartepoch = estudioworkingmemory('EEG_extr_best');
if ~isempty(MyViewer_detectartepoch) && MyViewer_detectartepoch==1
    messgStr  = char( 'Changes on "Extract Bin-epoched Single Trial EEG" have not been applied');
    eegpanelIndex =20;
    return;
end




return;
