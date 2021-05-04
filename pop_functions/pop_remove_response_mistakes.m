% Pop function for Remove Reponse Mistakes
% This calls the GUI and then the underlying function for removing response
% mistakes
%
% axs Jan 2020
function [ALLEEG,EEG, hist_com] = pop_remove_response_mistakes(ALLEEG,EEG,CURRENTSET,stim_codes,resp_codes)

% check input, call GUI iff not specified
if exist('stim_codes','var') == 0 || isempty(stim_codes)
    disp('Starting Remove Response Mistakes GUI to get info')
    [stim_codes, resp_codes] = gui_remove_response_mistakes(EEG);
end

EEG = remove_response_mistakes(EEG,stim_codes,resp_codes,1);

[ALLEEG,EEG] = pop_newset(ALLEEG,EEG,CURRENTSET);

hist_com = ['[ALLEEG EEG] = pop_remove_response_mistakes(ALLEEG, EEG, CURRENTSET, ' num2str(stim_codes) ',' num2str(resp_codes) ];

