%
% For using with ERPLAB artifact detection GUIs only
% Usage (auxiliar function)
%>> pop_plotepoch4erp(EEG, namefig)
% Javier Lopez Calderon
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