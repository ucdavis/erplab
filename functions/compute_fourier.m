% PURPOSE: return single-sided FFT amplitude and frequency bin labels
%          these can then optionally be plotted with the accompanying
%          plot_fourier function.
%
% FORMAT:
% [fft_out, freq_bin_labels] = compute_fourier(EEG)
%
% or:
% [fft_out, freq_bin_labels, n_freq_bins_out, freq_bin_width] =
%  compute_fourier(EEG, chans, smooth_factor, window_len, drop_boundaries, first_x_percent)
%
% INPUTS:  (* - required)
%      * EEG      - continuous or epoched dataset from EEGLAB
%        chans    - a vector of desired channels. By default, all
%                   channels. Channels averaged together for fft.
%        smooth_fac - Default: 0 - no smoothing.
%                   When above zero, this is the number of points either
%                   side of each sample point to average together,
%                   creating a downsampled / smoothed FFT.
%        window_len - a number setting the desired window length for the
%                   FFT, in seconds. Default of 5, indicating 5 seconds.
%        drop_boundaries - Binary flag, 1 means do not include data from
%                   windows that include boundary events. Default on.
%        first_x_percent - a number, 1-100, indicating what percentage of
%                   the input data timepoints to anaylze. Default is 100.
%
%
%  OUTPUT: (* - required)
%      * fft_out     - Single-sided absolute full-spectrum amplitude values
%                       outputted from FFT
%      * freq_bins   - The label vector of the frequency bins, in Hz.
%        n_freq_bins_out - The number of these frequeny bins.
%        freq_bin_width  - The width of each of these frequency bins, in Hz
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Andrew X Stewart & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2019
%
% ERPLAB Toolbox
% Copyright © 2019 The Regents of the University of California
% Created by Javier Lopez-Calderon and Steven Luck
% Center for Mind and Brain, University of California, Davis,
% javlopez@ucdavis.edu, sjluck@ucdavis.edu
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
function [fft_out, freq_bin_labels, n_freq_bins_out, freq_bin_width] = compute_fourier(EEG, chans, smooth_factor, window_len, drop_boundaries, first_x_percent)

try
    assert(isempty(EEG(1).data) == 0)
catch ME
    msgboxText =  'compute_fourier() error: cannot examine an empty dataset';
    title_msg  = 'ERPLAB: compute_fourier():';
    errorfound(msgboxText, title_msg);
    help compute_FFT_simple
    return
end

if isempty(EEG.epoch)
    cont_here = 1;  % continuous data
else
    cont_here = 0;  % non-continuous, epoched data
end

% set un-entered input args
if exist('chans','var') == 0
    chans = 1:EEG.nbchan;
elseif isempty(chans)
    chans = 1:EEG.nbchan;
end
if exist('bins','var') == 0
    if isfield(EEG,'EVENTLIST') == 0
        bins = 0;
    else
        if isempty(EEG.EVENTLIST) == 0
            bins = EEG.EVENTLIST.nbin;
        else
            bins = 0;
        end
        
    end
end
if exist('smooth_factor','var') == 0
    smooth_factor = 0;
elseif isempty(smooth_factor)
    smooth_factor = 0;
end
if exist('window_len','var') == 0
    window_len = 5; % 5 second default window length for fft
elseif isempty(window_len)
    window_len = 5;
end
if exist('drop_boundaries','var') == 0
    drop_boundaries = 1; % default 1 means do drop those windows that contain boundary codes
end
if exist('first_x_percent','var') == 0
    first_x_percent = 100;
elseif isempty(first_x_percent)
    first_x_percent = 100;
elseif first_x_percent > 100
    first_x_percent = 100;
    disp('first_x_percent should be within 1-100')
elseif first_x_percent < 1
    first_x_percent = 1;
    disp('first_x_percent should be within 1-100')
end
disp('Computing FFT...')

fs    = EEG.srate;
fnyq  = fs/2;
nchan = length(chans);

if cont_here  % continuous data
    sizeeg = EEG.pnts;
    
    
    % we examine the FFT in many windows-sized 'chunks' of data
    L = fs*window_len; % number of datapoints in 1 window-size strech of signal
    FFT_pts = 2^nextpow2(L);
    
    % determine the correct number of windows, and the idx of correct
    % window times
    
    max_nwindows = round(sizeeg/L) * 2; % maximum possible number of windows
    t_start = zeros(max_nwindows,1);
    t_end = zeros(max_nwindows,1);
    t_good = zeros(max_nwindows,1); % track if this time period is inside range
    t_bound = zeros(max_nwindows,1); % write 1s here to track boundaries in range
    Lm = round(L/2); % window move size, in dp. L/2 for 50% overlap of windows
    boundary_win_dropped = 0;
    
    % check that window times are valid, and don't contain a boundary
    bound_chk = 0;
    if drop_boundaries
        [boundary_times, num_boundaries] = find_boundary_times(EEG);
        if num_boundaries >= 1  % if no boundaries, don't bother checking
            bound_chk = 1;
        end
    end
    
    for win_times = 1:max_nwindows
        t_start(win_times) = 1 + (win_times-1)*Lm;
        t_end(win_times) = t_start(win_times) + L -1;
        
        if t_end(win_times) <= EEG.pnts
            t_good(win_times) = 1;
        end
        
        if bound_chk
            bounds_after_start = boundary_times >= t_start(win_times);
            bounds_before_end = boundary_times <= t_end(win_times);
            bound_here = bounds_after_start & bounds_before_end;
            
            if any(bound_here)
                t_bound(win_times) = 1;
                t_good(win_times) = 0;
                boundary_win_dropped = boundary_win_dropped + 1;
            end
        end
        
        
    end
    
    nwindows = sum(t_good);
    where_good = find(t_good);
    

    
    % If requested, run on a fraction of the valid windows
    if first_x_percent < 100
        new_nwindows = round(nwindows*first_x_percent/100);
        cut_text = ['Running FFT on first ' num2str(first_x_percent) '%, so ' num2str(new_nwindows) ' of ' num2str(nwindows) ' possible valid windows'];
        nwindows = new_nwindows;
    else
        cut_text = ['Running FFT on all ' num2str(nwindows) ' valid windows'];
    end
    
    disp(cut_text)
    
    if nwindows == 0    % if none were good by that count, just do all we can
        disp('No valid FFT windows of that size? Trying defaults')
        t_start(1) = 1;
        t_end(1) = sizeeg;
        nwindows = 1;
    end
    
    
    %
    
    % compute DFT / FFT
    f      = linspace(0,fs/2,floor(L/2)+1);
    freq_n = numel(f);
    ffterp = zeros(nwindows, freq_n, nchan);
    for k=1:nchan
        i = 1;
        while i<=nwindows
            % grab the right data, and detrend
            y = detrend(EEG.data(chans(k),t_start(where_good(i)):t_end(where_good(i))));
            % run FFT, giving complex value in Y
            Y = fft(y);
            % get the absolute single-sided amplitude from this complex value 
            single_sided = 2*abs(Y(1:freq_n))/L;
            
            ffterp(i,:,k) = single_sided;
            i = i+1;
        end
    end
    fft_report1 = ['Running FFT on continuous EEG on ' num2str(nwindows) ' window chunks, of ' num2str(window_len) ' seconds (' num2str(L) ' datapoints) each. Windows dropped due to boundary events: ' num2str(boundary_win_dropped)];
    disp(fft_report1)
    
else
    disp('Run FFT on epoched data?')
end


% Average the DFTs in the above matrix
% Averaging across the window dimension
avgfft = mean(ffterp,1);

avgdim3 = size(avgfft,3);  % if more than one chan / bins, avg
if avgdim3>1
    avgfft = mean(avgfft,3);
end

%
% Downsample
if smooth_factor >= 1
    
    n_pts_ds_avg = 1 + 2*round(smooth_factor); % downsample, averaging smooth_factor points above and below each point
    f_ds = downsample(f,n_pts_ds_avg);
    fft_ds = zeros(1,numel(f_ds));
    for i = 1:numel(f_ds)-smooth_factor
        fft_ds(1,i) = mean(avgfft(1,n_pts_ds_avg*i-smooth_factor:n_pts_ds_avg*i+smooth_factor));
    end
   
    avgfft = fft_ds;
    f = f_ds;
end


% Set up output
fft_out = avgfft;
freq_bin_labels = f;
n_freq_bins_out = freq_n;
freq_bin_width = f(2) - f(1);
