%
% interface for acceding eeg_interp from channel operation.
% Javier
function EEG = chinterpol(EEG, ch)
fprintf('Working...please wait...\n')
EEG = eeg_interp(EEG, ch);
fprintf('Channel %g was interpolated using "spherical" method\n\n', ch)