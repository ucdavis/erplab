% PURPOSE  : open a popup window for scrolling marked epochs after artifact detection.
%            For using with ERPLAB artifact detection GUIs only.
%
% FORMAT   :
%
% pop_plotepoch4erp(EEG, namefig)
%
% INPUT
%
% EEG         - continuous dataset having a EVENTLIST structure
% namefig     - figure's name
%
% OUTPUTS  :
%
% popup window for scrolling marked epochs after artifact detection.
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009
%

function pop_plotepoch4erp(EEG, namefig)
try
      pop_eegplot( EEG, 1, 1, 0);
      ctag         = max(findobj('tag','EEGPLOT')); % last image
      set(ctag, 'name',namefig)
      zoom(ctag,'on')
      buttonaccept = findobj(ctag,'tag','Accept');
      set(buttonaccept,'Visible', 'off')
      displaymenu  = findobj('tag','displaymenu','parent',ctag);
      set(displaymenu,'Visible', 'off')
      settingmenu  = findobj(ctag, 'Label','Settings');
      set(settingmenu,'Visible', 'off')
catch
      return
end