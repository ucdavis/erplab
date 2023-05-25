% PURPOSE: subroutine for pop_fourierp.m pop_fourieeg.m
%          calculates Single-Sided Power Spectrum of a dataset
%
% FORMAT
%
% varargout = fourieeg(EEG, chanArray, f1, f2, n_freq_bins, latwindow)
%
% INPUTS
%
%   EEG          - continuous or epoched dataset
%   chanArray    - channel to be processed
%   f1           - lower frequency limit (Hz)
%   f2           - upper frequency limit (Hz)
%   n_freq_bins  - the desired number of frequency bins in the computed FFT
%                      This is in the computed FFT, then clipped down to
%                      desired range.
%   latwindow    - time window of interest, in msec, for epoched data.
%   includelege  - 1 to include a legend in the figure. Default on.
%  drop_near_boundaries - Option flag to not include data near boundaries.
%                   Default on.
%  cont_window_size_s - Desired size of window to examine window in seconds
%           for continuous FFT. Default 5 seconds.
%   plot_type    -  Set as 0 for no figure plotted, 1 for log-plot, and
%                   2 for non-log
%   
%
%
% OUTPUT:
%
%   fft_out     - Squared module of computed FFT
%   freq_bins   - The labels of the frequency bins, in Hz.
%   n_freq_bins_out - The number of these frequeny bins.
%   freq_bin_width  - The width of each of these frequency bins, in Hz.
%
%
% EXAMPLE
%
% [fft_out freq_bins] = fourieeg(EEG,chanArray,f1,f2) returns the squared module, fft_out, of the FFT output
% of your dataset, evaluated at channel chanArray, between the frequencies f1 and f2 (in Hz).
% freq_bins contains the labels of the frequency bins, in Hz.
%
% [fft_out freq_bins] = fourieeg(EEG,chanArray,f1) returns the squared module of the FFT output
% of your dataset, evaluated at channel chanArray, between the frequencies f1 (in
% Hz) and fs/2 (fnyquist). freq_bins contains the labels of the frequency bins, in Hz.
%
% [fft_out freq_bins] = fourieeg(EEG,chanArray) returns the squared module of the FFT output
% of your dataset, evaluated at channel chanArray, between ~0 hz and fs/2
% (fnyquist). freq_bins contains the labels of the frequency bins, in Hz.
%
% [fft_out freq_bins n_freq_bins_out] = fourieeg(EEG) returns the squared module of the FFT output
% of your dataset, evaluated at channel 1, between the frequencies f1 (in
% Hz) and fs/2 (fnyquist). freq_bins contains the labels of the frequency
% bins, in Hz. n_freq_bins_out contains the number of these bins.
%
% fft_out = fourieeg(EEG...) returns only the squared module of the FFT output
% of your dataset.
%
% ... = fourieeg(EEG,chanArray,f1,f2,np, latwindow).
%
% fourieeg(EEG...) plots the Single-Sided Power Spectrum of your
% dataset.
%
%
% See also fft.
%
%
% *** This function is part of ERPLAB Toolbox ***
% Modified: axs, Sept 2019
% Author: Javier Lopez-Calderon & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009
%
%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% ERPLAB Toolbox
% Copyright © 2007 The Regents of the University of California
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

function varargout = fourieeg(EEG, chanArray, binArray, f1, f2, n_freq_bins, latwindow, includelege, drop_near_boundaries,cont_window_size_s, plot_type)
if nargin < 1
    help fourieeg
    if nargout == 1
        varargout{1} = [];
    elseif nargout == 2
        varargout{1} = [];
        varargout{2} = [];
    else
        return
    end
    return
end
if nargin<9
    drop_near_boundaries = 1; % 1 means do not include windows with boundaries in FFT
end
if nargin<8
    includelege = 1; % 1 means include leyend, 0 means do not...
end
if nargin<7
    latwindow = [EEG.xmin EEG.xmax]*1000; % msec
end
if nargin<6
    n_freq_bins = [];
end
if nargin<5
    f2 = EEG.srate/2;
end
if nargin<4
    f1 = 0;
end
if nargin<3
    binArray = [];
end
if nargin<2
    chanArray = 1;
end
if isempty(EEG(1).data)
    msgboxText =  'fourieeg() error: cannot examine an empty dataset';
    title_msg  = 'ERPLAB: fourieeg():';
    errorfound(msgboxText, title_msg);
    return
end
if exist('log_plot','var') == 0
plot_type = 1;
end
disp('Working...')
fs    = EEG.srate;
fnyq  = fs/2;
nchan = length(chanArray);
if isempty(EEG.epoch)  % continuous data
    sizeeg = EEG.pnts;
    if exist('cont_window_size_s','var') == 0
        default_window_size = 5; % seconds
    else
        default_window_size = cont_window_size_s;
    end
    
    L      = fs*default_window_size ;  %number of datapoints in 1 window-size stretch of signal
    
    % Determine correct number of windows and window times (in datapoint idx)
    max_nwindows = round(sizeeg/L) * 2; % maximum possible number of windows
    t_start = zeros(max_nwindows,1);
    t_end = zeros(max_nwindows,1);
    t_good = zeros(max_nwindows,1); % track if this time period is inside range
    t_bound = zeros(max_nwindows,1); % write 1s here to track boundaries in range
    Lm = round(L/2); % window move size, in dp. L/2 for 50% overlap of windows
    boundary_win_dropped = 0;
    
    % check that window times are valid, and don't contain a boundary
    bound_chk = 0;
    if drop_near_boundaries
        [boundary_times, num_boundaries] = find_boundary_times(EEG);
        if num_boundaries >= 1  % if no boundaries, don't bother checking
            bound_chk = 1;
        end
    end
    
    for win_times = 1:max_nwindows
        t_start(win_times) = 1 + (win_times-1)*Lm;
        t_end(win_times) = t_start(win_times) + L;
        
        if t_end(win_times) <= EEG.pnts
            t_good(win_times) = 1;
        end
        
        if bound_chk
            bounds_after_start = boundary_times >= t_start(win_times);
            bounds_befow_end = boundary_times <= t_end(win_times);
            bound_here = bounds_after_start & bounds_befow_end;
            
            if any(bound_here)
                t_bound(win_times) = 1;
                t_good(win_times) = 0;
                boundary_win_dropped = boundary_win_dropped + 1;
            end
        end
        
        
    end
    
    nwindows = sum(t_good);
    where_good = find(t_good);
    
    if nwindows == 0    % if none were good by that count, just do all we can
        disp('No valid FFT windows of that size? Trying defaults')
        t_start(1) = 1;
        t_end(1) = sizeeg;
        nwindows = 1;
    end
    
    
    
    if isempty(n_freq_bins)
        NFFT   = 2^nextpow2(L);
    else
        NFFT = 2*n_freq_bins;
    end
    f      = fnyq*linspace(0,1,NFFT/2);
    ffterp = zeros(nwindows, NFFT/2, nchan);
    for k=1:nchan
        a = 1; b = L; i = 1;
        while i<=nwindows && b<=sizeeg
            y = detrend(EEG.data(chanArray(k),t_start(where_good(i)):t_end(where_good(i))));
            Y = fft(y,NFFT)/L;
            ffterp(i,:,k) = 2*abs(Y(1:NFFT/2));
            i = i+1;
        end
    end
    fft_report1 = ['Running FFT on continuous EEG on ' num2str(nwindows) ' window chunks, of ' num2str(default_window_size) ' seconds (' num2str(L) ' datapoints) each. Windows dropped due to boundary events: ' num2str(boundary_win_dropped)];
    disp(fft_report1)
    msgn = 'whole';
else   % epoched data
    indxtimewin = ismember_bc2(EEG.times, EEG.times(EEG.times>=latwindow(1) & EEG.times<=latwindow(2)));
    datax  = EEG.data(:,indxtimewin,:);
    L      = length(datax); %EEG.pnts;
    ntrial = EEG.trials;
    if isempty(n_freq_bins)
        NFFT   = 2^nextpow2(L);
    else
        NFFT = 2*n_freq_bins;
    end
    f = fnyq*linspace(0,1,NFFT/2);
    ffterp = zeros(ntrial, NFFT/2, nchan);
    for k=1:nchan
        for i=1:ntrial
            if ~isempty(binArray) && isfield(EEG.epoch,'eventbini')
                if length(EEG.epoch(i).eventlatency) == 1
                    numbin = EEG.epoch(i).eventbini; % index of bin(s) that own this epoch (can be more than one)
                elseif length(EEG.epoch(i).eventlatency) > 1
                    indxtimelock = find(cell2mat(EEG.epoch(i).eventlatency) == 0); % catch zero-time locked event (type),
                    [numbin]  = [EEG.epoch(i).eventbini{indxtimelock}]; % index of bin(s) that own this epoch (can be more than one) at time-locked event.
                    numbin    = unique_bc2(numbin(numbin>0));
                else
                    numbin =[];
                end
                if iscell(numbin)
                    numbin = numbin{:}; % allows multiples bins assigning
                end
            elseif ~isempty(binArray) && ~isfield(EEG.epoch,'eventbini')
                numbin =[];
            else
                numbin =[];
            end
            if isempty(binArray) || (~isempty(binArray) && ~isempty(numbin) && ismember_bc2(numbin, binArray))
                y = detrend(datax(chanArray(k),:,i));
                Y = fft(y,NFFT)/L;
                ffterp(i,:,k) = abs(Y(1:NFFT/2)).^2; % power
                if rem(NFFT, 2) % odd NFFT excludes Nyquist point
                    ffterp(i,2:end,k) = ffterp(i,2:end,k)*2;
                else
                    ffterp(i,2:end-1,k) = ffterp(i,2:end-1,k)*2;
                end
            end
        end
    end
    msgn = 'all epochs';
end
avgfft = mean(ffterp,1);
avgdim3 = size(avgfft,3);
if avgdim3>1
    avgfft = mean(avgfft,3);
end
f1sam  = round((f1*NFFT/2)/fnyq);
f2sam  = round((f2*NFFT/2)/fnyq);
if f1sam<1
    f1sam=1;
end
if f2sam>NFFT/2
    f2sam=NFFT/2;
end
fout = f(f1sam:f2sam);
yout = avgfft(1,f1sam:f2sam);


if nargout ==1
    varargout{1} = yout;
elseif nargout == 2
    varargout{1} = yout;
    varargout{2} = fout;
elseif nargout == 3
    varargout{1} = yout;
    varargout{2} = fout;
    varargout{3} = numel(fout);
elseif nargout == 4
    varargout{1} = yout;
    varargout{2} = fout;
    varargout{3} = numel(fout);
    varargout{4} = fout(2)-fout(1);
    
end

if plot_type % if non-zero, run
    fname = EEG.setname;
    h = figure('Name',['<< ' fname ' >>  ERPLAB Amplitude Spectrum'],...
        'NumberTitle','on', 'Tag','Plotting Spectrum',...
        'Color',[1 1 1]);
    plot(fout,yout)
    axis([min(fout)  max(fout)  min(yout)*0.9 max(yout)*1.1])  
    
    if includelege
        if isfield(EEG.chanlocs,'labels')
            lege = sprintf('EEG Channel: ');
            for i=1:length(chanArray)
                lege =   sprintf('%s %s', lege, EEG.chanlocs(chanArray(i)).labels);
            end
            lege = sprintf('%s *%s', lege, msgn);
            legend(lege)
        else
            legend(['EEG Channel: ' vect2colon(chanArray,'Delimiter', 'off') '  *' msgn])
        end
    end
    title('Single-Sided Amplitude Spectrum of y(t)')
    xlabel('Frequency (Hz)')
    ylabel('Amplitude - absolute single-sided (original units)')
    
    if plot_type == 1
        set(gca,'XScale','log')
        set(gca,'XTick',[1 10 60 100])
        if f1 == 0
            xstart = 0.1;
        else
            xstart = f1;
        end
        xlim = [xstart f2];
        xlabel('Frequency (Hz) - log scale')
        
    end
        
end
