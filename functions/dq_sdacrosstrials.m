% Analytic SME meanamp calc snippet
% ams Jan 2023
function [outdata] = dq_sdacrosstrials(EEG, epoch_list, dq_window_times)

sizes = size(EEG.data);

assert(numel(sizes)==3, 'sme_analytic needs bin-epoched EEG data');

if exist('dq_window_times','var') == 0
    dq_window_times = [];
end

% if there are 3 cols to win_times, use last 2
if size(dq_window_times,2) == 3
    dq_window_times = dq_window_times(:,2:3);
end

n_bins = length(epoch_list);
n_elec = sizes(1);
n_times = sizes(2);
n_beps_total = sizes(3);

if isempty(dq_window_times)
    n_windows = 1;
    win_times_starts = 1;
    win_times_ends = EEG.times(end);
else
    n_windows = size(dq_window_times,1);
    win_times_starts = dq_window_times(:,1);
    win_times_ends = dq_window_times(:,2);
end

% Convert times from ms to datapoint idx
win_dps_starts = zeros(1,n_windows);
win_dps_ends = zeros(1,n_windows);
for t = 1:n_windows
    win_dps_starts(t) = find(abs(EEG.times-win_times_starts(t))==min(abs(EEG.times-win_times_starts(t))),1);
    win_dps_ends(t) = find(abs(EEG.times-win_times_ends(t))==min(abs(EEG.times-win_times_ends(t))),1);
end

for b = 1:n_bins
    n_beps_per_bin(b) = numel(epoch_list(b).good_bep_indx);
end

SD_out = zeros(n_elec,n_windows,n_bins);
SD_unbias_out = zeros(n_elec,n_windows,n_bins); 


for b = 1:n_bins        % for each bin
    for t = 1:n_windows % and each SD time window
    
    data_here = EEG.data(1:n_elec,win_dps_starts(t):win_dps_ends(t),epoch_list(b).good_bep_indx);
    window_mean = squeeze(mean(data_here,2));
    
    %N-1 SD
    SD_bias = std(window_mean,0,2);
    SD_out(1:n_elec,t,b) = SD_bias;
    
    %Unbiased SD
    nTimes = size(window_mean,2); 
    SD_unbias = ((SD_bias * sqrt((nTimes-1)))/ sqrt((nTimes-(3/2)+(1/(8*(nTimes-1))))));
    SD_unbias_out(1:n_elec,t,b) = SD_unbias; 
    
    end
end

%combine SD structs
outdata = struct();
outdata.SD_bias = SD_out;
outdata.SD_unbias = SD_unbias_out;
