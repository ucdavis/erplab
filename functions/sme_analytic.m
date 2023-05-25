% Analytic SME meanamp calc snippet
% axs Dec 2018
% ams Jan 2023, includes corrected SME
function [outdata] = sme_analytic(EEG, epoch_list, dq_window_times)

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

SME_out = zeros(n_elec,n_windows,n_bins);
SME_unbias_out = zeros(n_elec,n_windows,n_bins); 


for b = 1:n_bins        % for each bin
    for t = 1:n_windows % and each SME time window
    
    data_here = EEG.data(1:n_elec,win_dps_starts(t):win_dps_ends(t),epoch_list(b).good_bep_indx);
    window_mean = squeeze(mean(data_here,2));
    
    %SD (N-1)
    SME_sd = std(window_mean,0,2); 
    %SME_bias = std(window_mean,0,2) / sqrt(n_beps_per_bin(b));
    SME_bias = SME_sd / sqrt(n_beps_per_bin(b)); 
    SME_out(1:n_elec,t,b) = SME_bias;
    
    %Unbiased SD (Gurland & Tripathi)
    nTimes = size(window_mean,2); 
    SME_unbias = (((SME_sd * sqrt((nTimes-1)))/ sqrt((nTimes-(3/2)+(1/(8*(nTimes-1)))))) / sqrt(n_beps_per_bin(b)));
    SME_unbias_out(1:n_elec,t,b) = SME_unbias; 
    
    
    end
end
%combine SME structs
outdata = struct();
outdata.SME = SME_out;
outdata.SME_corr = SME_unbias_out;

