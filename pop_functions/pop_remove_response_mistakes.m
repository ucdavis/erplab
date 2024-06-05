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
ERPtooltype = erpgettoolversion('tooltype');
if ~strcmpi(ERPtooltype,'estudio')
    [ALLEEG,EEG] = pop_newset(ALLEEG,EEG,CURRENTSET);
end
stim_codesstr = vect2colon(stim_codes);resp_codesstr = vect2colon(resp_codes);
hist_com = ['[ALLEEG EEG] = pop_remove_response_mistakes(ALLEEG, EEG, CURRENTSET,', stim_codesstr, ',',resp_codesstr,');' ];

