


function [EEG, eegcom] = f_ploteeg(EEG)
eegcom = '';
if nargin < 1
    help f_ploteeg
    return
end
if isempty(EEG)
    msgboxText =  'Cannot handle an empty EEGset';
    title = 'ERPLAB: f_ploteeg() error';
    errorfound(msgboxText, title);
    return
end
if isempty(EEG(1).data)
    msgboxText =  'Cannot handle an empty EEGset';
    title = 'ERPLAB: f_ploteeg() error';
    errorfound(msgboxText, title);
    return
end

if length(EEG)>1
    msgboxText =  'Cannot handle multiple eegsets!';
    title = 'ERPLAB: f_ploteeg() error';
    errorfound(msgboxText, title);
    return
end

app = feval('EEG_select_segement_artifact_GUI',EEG,1);
waitfor(app,'Finishbutton',1);
try
    EEG = app.Output; %NO you don't want to output EEG with edited channel locations, you want to output the parameters to run decoding
    app.delete; %delete app from view
    pause(0.1); %wait for app to leave
catch
    EEG = [];
    return;
end


eegcom = '[EEG, eegcom] = f_ploteeg(EEG);';
end