% DEPRECATED...
%
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

function EEG = checkzerolat(EEG)
nepoch = EEG.trials;
if isempty(EEG.epoch)
      fprintf('\nWARNING: checkzerolat() only works for epoched datasets. This call was ignored.\n')
      return
end
for i=1:nepoch
      latcell  =  cell2mat(EEG.epoch(i).eventlatency);
      [v, indx] = min(abs(latcell));
      EEG.epoch(i).eventlatency = num2cell(latcell - latcell(indx));
end

auxtimes  = EEG.times;
[v, indx]  = min(abs(auxtimes));
EEG.times = auxtimes - auxtimes(indx);
EEG.xmin  = min(EEG.times)/1000;
EEG.xmax  = max(EEG.times)/1000;
EEG.srate = round(EEG.srate);
EEG = eeg_checkset( EEG );

if EEG.times(1)~=auxtimes(1)
      msg = ['\nWarning: zero time-locked stimulus latency values were not found.\n'...
      'Therefore, ERPLAB adjusted latency values at EEG.epoch.eventlatency, EEG.times, EEG.xmin,and EEG.xmax.\n\n'];
      fprintf(msg);
      fprintf('Time range is now [%.3f  %.3f] sec.\n', EEG.min, EEG.max )
else
      fprintf('Zero latencies OK.\n')
end