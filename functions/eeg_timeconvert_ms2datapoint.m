% Convert desired time-point to the corresponding sample index
%
% Required input:
%  EEG (or ERP) -  A EEG datastructure, or ERP datastructure, from EEGLAB
%                  or ERPLAB
%  time_in_ms   -  A number that specifies the desired time units of
%                  milliseconds
%
% Output:
%  datapoint_idx - The index within EEG.data that points to the specified
%                  time.
%
% Example Usage:
% datapoint_idx = eeg_timeconvert_ms2datapoint(EEG, 300)
%   returns: datapoint_idx = 251
%   indicating that EEG.data(:,251) is the datapoint closest to 300 ms
%
% Compatible with https://github.com/lucklab/erplab/wiki/Timing-Details
% axs Mar 2020
function [datapoint_idx, time_in_ms_there] = eeg_timeconvert_ms2datapoint(EEG, time_in_ms)

% Check correspondance
tmin = EEG.times(1); tmax = EEG.times(end);
tstep = EEG.times(2) - EEG.times(1);

if time_in_ms < tmin - tstep || time_in_ms > tmax + tstep
    error('Desired time is outside the limits of the times in this dataset');
end

% Find nearest time point
diff_vector = abs(EEG.times - time_in_ms);
closest_value = min(diff_vector);
closest_idx = find(diff_vector==closest_value,1);

datapoint_idx = closest_idx;
time_in_ms_there = EEG.times(datapoint_idx);
