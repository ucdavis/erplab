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


% MyViewer_xyaxis = estudioworkingmemory('MyViewer_xyaxis');
% if ~isempty(MyViewer_ERPset) && MyViewer_xyaxis==1
%     messgStr  = char( 'Changes on "Time and Amplitude Scales" have not been applied');
%     eegpanelIndex =3;
% end
% 
% 
% MyViewer_plotorg = estudioworkingmemory('MyViewer_plotorg');
% if ~isempty(MyViewer_ERPset) && MyViewer_plotorg==1
%     messgStr  = char( 'Changes on "Plot Organization" have not been applied');
%     eegpanelIndex =4;
% end
% 
% MyViewer_labels = estudioworkingmemory('MyViewer_labels');
% if ~isempty(MyViewer_ERPset) && MyViewer_labels==1
%     messgStr  = char( 'Changes on "Chan/Bin/ERPset Labels" have not been applied');
%     eegpanelIndex =5;
% end
% 
% MyViewer_linelegend = estudioworkingmemory('MyViewer_linelegend');
% if ~isempty(MyViewer_ERPset) && MyViewer_linelegend==1
%     messgStr  = char( 'Changes on "Lines & legends" have not been applied');
%     eegpanelIndex =6;
% end
% 
% 
% MyViewer_other = estudioworkingmemory('MyViewer_other');
% if ~isempty(MyViewer_ERPset) && MyViewer_other==1
%     messgStr  = char( 'Changes on "Other" have not been applied');
%     eegpanelIndex =7;
% end

return;
