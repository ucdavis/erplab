% PURPOSE: plot the entered simple amplitude spectra of a dataset
%
% FORMAT:
%  plot_fourier(fft_in, freq_labels)
%
% or:
%  plot_fourier(fft_in, freq_labels, bottom_freq, top_freq, logplot, title_str, units_str)
%
% INPUTS:  (* - required)
%      * fft_in      - FFT amplitudes, expected as sigle-sided frequency
%                     amplitudes
%      * freq_labels - The labels of the frequency bins, in Hz.
%                   Numeric. 
%        bottom_freq - Exclude frequencies below this from the plot
%        top_freq    - Exlude frequencies above this from the plot
%        logplot     - A flag specifying log-plot settings.
%                       0 - no log, 1 - log-x
%        title_str   - A string with a custom title
%        units_str   - A string with a custom unit specification

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
function plot_fourier(fft_in, freq_labels, bottom_freq, top_freq, logplot, title_str, units_str)

% check essential input
try
    assert(isempty(fft_in) == 0)
    assert(isempty(freq_labels) == 0)
catch ME
    msgboxText =  'plot_fourier() error: please enter both fft spectra and freq_labels vectors';
    title_msg  = 'ERPLAB: plot_fourier():';
    errorfound(msgboxText, title_msg);
    help plot_fourier
    return
end

n_labels = numel(freq_labels);
[n_chans, n_fft_pts] = size(fft_in);

% check other input, populate
if exist('logplot','var') == 0
    logplot = 1;
elseif isempty(logplot)
    logplot = 1;
end
if exist('title_str','var') == 0
    title_str = 'Single-sided Amplitute FFT';
elseif isempty(title_str)
    title_str = 'Single-sided Amplitute FFT';
end
if exist('units_str','var') == 0
    units_str = 'Amplitude (original units)';
elseif isempty(units_str)
    units_str = 'Amplitude (original units)';
end
if exist('bottom_freq','var') == 0
    bottom_freq = 0;
elseif isempty(bottom_freq)
    bottom_freq = 0;
end
if exist('top_freq','var') == 0
    top_freq = freq_labels(end);
end

% clip to desired frequency range
needs_clipped = 0;
if any(freq_labels<bottom_freq) || any(freq_labels>top_freq)
    needs_clipped = 1;
end

if needs_clipped
    [above_bottom_m, above_bottom_idx] = find(freq_labels>=bottom_freq);
    [below_top_m, below_top_idx] = find(freq_labels<=top_freq);
    good_idx = intersect(above_bottom_idx,below_top_idx);
    
    freq_labels = freq_labels(good_idx);
    fft_in = fft_in(:,good_idx);
end


n_labels = numel(freq_labels);

% plot figure
figure
% clip the data to go up to the max number of labels
plot(freq_labels,fft_in(1:n_labels))

if logplot == 1
    set(gca,'XScale','log')
    set(gca,'XTick',[1 10 60 100])
end

title(title_str)
xlabel('Frequencies')
ylabel(units_str)

