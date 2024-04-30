%%This function is to display the summary of trial information
%
% FORMAT   :
%
% pop_eeg_ar_summary(ALLEEG,EEGArray);
%
% ALLEEG        - structure array of EEG structures
% EEGArray      -index of eegsets




% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Apr. 2024



function eegcom = pop_eeg_ar_summary(ALLEEG,EEGArray)

eegcom = '';
if nargin < 1 || nargin >2
    help pop_eeg_ar_summary
    return
end
if nargin < 2
    EEGArray = [1:length(ALLEEG)];
end
if isempty(EEGArray) || any(EEGArray(:)>length(ALLEEG)) || any(EEGArray(:)<1)
    EEGArray = [1:length(ALLEEG)];
end
if isempty(ALLEEG)
    msgboxText = ['ALLEEG is empty.'];
    title = 'ERPLAB Studio: pop_eeg_ar_summary() inputs';
    errorfound(sprintf(msgboxText), title);
    return
end

if ~isempty(EEGArray)
    app = feval('EEG_trial_rejection_sumr',ALLEEG(EEGArray),1);
    waitfor(app,'Finishbutton',1);
end
EEGArraystr= vect2colon(EEGArray);
eegcom = sprintf('eegcom = pop_eeg_ar_summary(ALLEEG,%s);',EEGArraystr);
end