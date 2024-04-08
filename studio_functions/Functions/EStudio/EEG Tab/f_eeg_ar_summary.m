%%This function is to display the summary of trial information


% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Apr. 2024



function eegcom = f_eeg_ar_summary(ALLEEG,EEGArray)

eegcom = '';
if nargin < 1 || nargin >2
    help f_eeg_ar_summary
    return
end
if nargin < 2
    EEGArray = [1:length(ALLEEG)];
end
if isempty(EEGArray) || any(EEGArray(:)>length(ALLEEG)) || any(EEGArray(:)<1)
    EEGArray = [1:length(ALLEEG)];
end

for NumofEEG = 1:numel(EEGArray)
    EEG  = ALLEEG(EEGArray(NumofEEG));
    if EEG.trials==1
        return;
    end
    ERP    = buildERPstruct([]);
    [ERP, EVENTLISTi, countbiORI, countbinINV, countbinOK, countflags, workfname] = averager(EEG, 1, 1, 1, 1, [], [],1);
    ERP.erpname = EEG.setname;
    ERP.ntrials.accepted = countbinOK;
    ERP.ntrials.rejected = countbiORI-countbinINV-countbinOK;
    ERP.ntrials.invalid = countbinINV;
    
    if NumofEEG ==1
        ALLERP = ERP;
    else
        ALLERP(length(ALLERP)+1)   = ERP;
    end
end

if ~isempty(ALLERP)
    feval('EEG_trial_rejection_sumr',ALLERP,[],1);
end

eegcom = sprintf('eegcom = f_eeg_ar_summary(ALLEEG,%d);', EEGArray);

end