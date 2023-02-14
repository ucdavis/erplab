% PURPOSE: Calculates the average amplitude/power spectra across given frequencies using Fourier Transform on continuous EEG. 
%
%
% FORMAT :
%
% [EEG,fft_out, COM] = pop_continuousFFT(EEG, 'ChannelIndex', [1:nchans], 'Frequencies', [0 3;3 8]); 
%
% INPUTS :
%
% EEG				- Currently loaded EEG structure array
% ChannelIndex		- Array of channel indexs, e.g. [1:32]
% Frequencies       - Array of frequency bands, e.g. [0 3;3 8]
%						where each row is [start,end] frequency. 
%
% The available optional parameters are as follows
%
% 'FrequencyLabel'  	- Cell Array of labels for each Frequency.
% 							MUST match the length of Frequencies array. 
% 'NumberOfPointsFFT'	- Number of Points of FFT window (default: 2^nextpow2(fs*window_length)) ...
%							where window size is 5s. 
% 'PercentRandom'		- Percent of Valid FFT windows to use (default: 20%)
% 'viewGUI'				- {'true'/'false'} View DataQuality Spectra Table
% 'SeedNum'				- RNG Seed (integer) for choosing FFT windows (default: 1000)
%
%
%
% OUTPUTS:
%
% EEG 				- Currently loaded EEG structure array
% fft_out			- Average ampltiude across frequency band [Channels X frequency band] 
% com 				- ERPLAB com output
%
% EXAMPLES:
%
% [EEG] = pop_continuousFFT( EEG, 'ChannelIndex',  1:64, 'Frequencies', [ 0 3; 3 8; 8 12; 8 30; 30 48; 59 61; 69 71], 'FrequencyLabel',...
% {'delta' 'theta' 'alpha' 'beta' 'gamma' '60hz-noise' '70hz-noise' }, 'PercentRandom',  30, 'viewGUI',...
% 'true' ); 
%
% See also continuousDFT.m DQ_Spectra_GUI.m save_spectral_dq.m
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Aaron Matthew Simmons & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2023
%
% b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
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


function [EEG, fft_out, com] = pop_continuousFFT(EEG, varargin)

com = ''; 

if nargin < 1
    help pop_continuousFFT
    return
end

if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end

if ~isempty(EEG.epoch)
    cont_here = 0;  % non-continuous, epoched data
    msgboxText =  'ERPLAB says: The selected dataset contains epoched EEG data, and this function works only with continuous EEG data.';    
    title_header = 'ERPLAB: pop_continuousFFT() error';
    errorfound(msgboxText, title_header);
    fft_out = []; 
    return 
    
else
    cont_here = 1; 
end


if nargin == 1 %GUI
    
    if iseegstruct(EEG)
        if length(EEG)>1
            msgboxText =  'ERPLAB says: Unfortunately, this function does not work with multiple datasets';
            error(msgboxText);
        end
    end
    
    if isempty(EEG.data)
                msgboxText =  'cannot work with an empty EEG dataset';
                title      = 'ERPLAB: pop_continuousFFT() error:';
                errorfound(msgboxText, title);
                return
    end
    
    %find nyquest frequency
    fqnyq = EEG.srate/2; 
    
    %working memory
    %{1} chanArray
    %{2} frequency bands
    %{3} frequency labels
    %{4} % of valid FFT windows to use 
    def_labels = {'delta','theta','alpha','beta','gamma','50hz-noise','60hz-noise','broadband'}; %defaults
    def_bands = [0 3;3 8;8 12;8 30;30 48;49 51;59 61;0 fqnyq]; %default bands
    

    
    defx = {1:EEG.nbchan def_bands def_labels'};
    def  = erpworkingmemory('pop_continuousFFT');
    
    if isempty(def)
        def = defx;
    end
    
    
    
    %
    % Call GUI
    % 
    
    answer = continuousFFT(EEG,def);
    
    if isempty(answer)
        disp('User selected Cancel')
        fft_out = [];
        return
    end
    
    chans = answer{1};
    fqband = answer{2};
    fqlabels = answer{3};
    
    erpworkingmemory('pop_continuousFFT',answer(:)'); 
    
    %
    % Somersault
    %
    
    [EEG, fft_out, com] = pop_continuousFFT(EEG, 'ChannelIndex',chans,'Frequencies',fqband,'FrequencyLabel', ...
        fqlabels, 'viewGUI','true','History', 'gui'); 
    
    return
    
end

%
% Parsing Inputs
% 

p = inputParser;
p.FunctionName = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG');
% p.addRequired('chanArray', @isnumeric);
% p.addRequired('frequencyBand', @isnumeric); 
%options
p.addParamValue('ChannelIndex',[], @isnumeric); 
p.addParamValue('Frequencies', [], @isnumeric);
p.addParamValue('FrequencyLabel', [], @iscell); 
p.addParamValue('NumberOfPointsFFT',[],@isnumeric);
p.addParamValue('PercentRandom', 20, @isnumeric); 
p.addParamValue('viewGUI', 'false', @ischar);
p.addParamValue('SeedNum', 1000, @isnumeric); 
p.addParamValue('History','script', @ischar); 

p.parse(EEG, varargin{:}); 

if iseegstruct(EEG)
    if length(EEG)>1
        msgboxText =  'ERPLAB says: Unfortunately, this function does not work with multiple datasets';
        disp(msgboxText);
        return
    end
    
end

if strcmpi(p.Results.History,'implicit')
        shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
        shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
        shist = 1; % gui
else
        shist = 0; % off
end




% variables
fqlabels = p.Results.FrequencyLabel;
np = p.Results.NumberOfPointsFFT;
chanArray = p.Results.ChannelIndex;
frequencyBand = p.Results.Frequencies;
percent_random = p.Results.PercentRandom;
viewGUIoption = p.Results.viewGUI; 
SeedToUse = p.Results.SeedNum; 

% specify random stream (for randperm -- not a global stream!) 
% Steve wants every randomperm of windows to be the same so users can
% expect the same magnitude/amplitudes 

s_stream = RandStream('mt19937ar','Seed',SeedToUse); %seed = 1000

window_len = 5; %seconds 
fs    = EEG.srate;
fnyq  = fs/2;
nchan = length(chanArray);
drop_boundaries = 1; 


% set un-entered input args
if isempty(chanArray)
    chanArray = 1:EEG.nbchan;
end

% test nyquest frequency rule on end band-edge

nyq_test = fnyq < frequencyBand(:,2);
bad_bands = find(nyq_test); 

if any(bad_bands)
    
    for b = 1:length(bad_bands)
        bad_freq = frequencyBand(bad_bands(b),:); 
        disp(['Warning: Band ' num2str(fqlabels{b}) ' ' num2str(bad_freq(1)) '-' num2str(bad_freq(2)) ' does not meet frequency transform criteria due to low ' num2str(fs) ' hz sampling rate. Results will show NaNs']); 
        
    end
    
end



disp('Computing FFT...')




%obtain the start and end frequencies 
%match with labels

if isempty(fqlabels)
    
    numBands = size(frequencyBand,1); 
    
    for l = 1:numBands
        
        fqlabels{l} = ['Custom Frequencies ' num2str(l)];
    end
    
    f1 = frequencyBand(:,1);
    f2 = frequencyBand(:,2);
    fqlabels = fqlabels'; 
    
elseif numel(fqlabels) ~= size(frequencyBand,1) 
    
    fqlabels_new = {}; 
    
    for l = 1:size(frequencyBand,1)
        
        try 
            fqlabels_new{l} = fqlabels{l}; 
        
        catch
            fqlabels_new{l} = ['Custom Fruquencies' num2str(l)];
        end
        
        
    end
    fqlabels = fqlabels_new'; 
    
    f1 = frequencyBand(:,1);
    f2 = frequencyBand(:,2);
    
else
    
    f1 = frequencyBand(:,1);
    f2 = frequencyBand(:,2);
    
end


if cont_here  % continuous data
    sizeeg = EEG.pnts;
    
    
    % we examine the FFT in many windows-sized 'chunks' of data
    if isempty(np) %GUI
        FFT_pts = fs*window_len; % number of datapoints in 1 window-size strech of signal
        L = 2^nextpow2(FFT_pts); %adjust fft points to power 2
    else
       % FFT_pts = np; (if user input np)
        L = 2^nextpow2(np);
        window_len = (1/fs)*L;
    end
    
    % determine the correct number of windows, and the idx of correct
    % window times
    
    %max_nwindows = round(sizeeg/L) * 2; % maximum possible number of windows
    max_nwindows = round(sizeeg/L); % maximum possible number of windows (no overlap)
    t_start = zeros(max_nwindows,1);
    t_end = zeros(max_nwindows,1);
    t_good = zeros(max_nwindows,1); % track if this time period is inside range
    t_bound = zeros(max_nwindows,1); % write 1s here to track boundaries in range
    %Lm = round(L/2); % window move size, in dp. L/2 for 50% overlap of windows
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
        %t_start(win_times) = 1 + (win_times-1)*Lm; 
        t_start(win_times) = 1 + (win_times-1)*L; % no overlap
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
    
    % Run on a fraction of valid, randomized windows (default: 20%)
    randomized_good = where_good(randperm(s_stream,length(where_good)));
    if percent_random == 100
        % Run on all valid windows
        new_nwindows = round(nwindows*percent_random/100);
        cut_text = ['Running FFT on all ' num2str(percent_random) '%, so ' num2str(new_nwindows) ' of ' num2str(nwindows) ' possible valid windows'];
        nwindows = new_nwindows;
        
    else  
        % default is 20% 
        new_nwindows = round(nwindows*percent_random/100);
        cut_text = ['Running FFT on random ' num2str(percent_random) '%, so ' num2str(new_nwindows) ' of ' num2str(nwindows) ' possible valid windows'];
        nwindows = new_nwindows;
        
    end
    

    
    % Run on all valid windows
    %cut_text = ['Running FFT on all ' num2str(nwindows) ' valid windows'];
    disp(cut_text)
    
    if nwindows == 0    % if none were good by that count, just do all we can
        disp('No valid FFT windows of that size? Trying defaults')
        t_start(1) = 1;
        t_end(1) = sizeeg;
        nwindows = 1;
    end
    
%     if isempty(np)
%         NFFT   = 2^nextpow2(L);
%     else
%         NFFT = 2*np;
%     end
%     
    %
    
    % compute DFT / FFT
    f      = linspace(0,fs/2,floor(L/2)+1);
    freq_n = numel(f);
    ffterp = zeros(nwindows, freq_n, nchan);
    for k=1:nchan
        i = 1;
        while i<=nwindows
            % grab the right data, and detrend
            %y = detrend(EEG.data(chanArray(k),t_start(where_good(i)):t_end(where_good(i))));
            y = detrend(EEG.data(chanArray(k),t_start(randomized_good(i)):t_end(randomized_good(i))));
            %y = EEG.data(chanArray(k),t_start(randomized_good(i)):t_end(randomized_good(i)));
            % run FFT, giving complex value in Y
            %Y = fft(y);
            Y = fft(y);
            % get the absolute single-sided amplitude from this complex value
            single_sided = 2*abs(Y(1:freq_n))/L;
%             P2 = abs(Y/L); 
%             P1 = P2(1:L/2+1); 
%             P1(2:end-1) = 2*P1(2:end-1);
%             single_sided = P1; 
            
            ffterp(i,:,k) = single_sided;
            i = i+1;
        end
    end
    fft_report1 = ['Running FFT on continuous EEG on ' num2str(nwindows) ' window chunks, of ' num2str(window_len) ' seconds (' num2str(L) ' datapoints) each (Power-of-2 FFT). Windows dropped due to boundary events: ' num2str(boundary_win_dropped)];
    disp(fft_report1)
    
else
    disp('Run FFT on epoched data?')
end

% Average the DFTs in the above matrix

avgfft = squeeze(mean(ffterp,1)); 

%WinxFreqxChan -> FreqxChan (if multiple Chan)
%WinXFreq -> ChanXFreq (if 1 chan, become vector of freq)

%find indexes per band
% f1sam  = round((f1*L/2)/fnyq);
% f2sam  = round((f2*L/2)/fnyq);

f1sam  = round((f1*L/2)/fnyq);
f2sam  = round((f2*L/2)/fnyq);
if any(f1sam<1)
    f1sam(f1sam<1)=1;
end
if any(f2sam>L/2)
    f2sam(f2sam>L/2) = L/2;
end


%fout = f(f1sam:f2sam); 
%obtain the avg values within bands 
fftout = nan([nchan length(f1sam)]);  %channelsxband 
yout = {}; %discrete frequency values cell array

for b = 1:length(f1sam)
    
    if nchan <= 1
        
        if ismember(b,bad_bands)
            yout{b} = NaN;
            fftout(b) = NaN;
        else
            
            avg_fft_win = avgfft(f1sam(b):f2sam(b)); %vector of freqs
            yout{b} = avg_fft_win; %cell array of bands, each elem = mat(freqXchan)
            label_yout{b} = f(f1sam(b):f2sam(b));
            
            fftout(b) = mean(avg_fft_win); %band
            
        end
        
    else
        if ismember(b,bad_bands)
            yout{b} = NaN;
            fftout(:,b) = NaN;
        else
            
            avg_fft_win = avgfft(f1sam(b):f2sam(b),:); %freqXchan
            
            yout{b} = avg_fft_win; %cell array of bands, each elem = mat(freqXchan)
            label_yout{b} = f(f1sam(b):f2sam(b));
            
            fftout(:,b) = mean(avg_fft_win,1); %channelsxband
        end
    end
end




% Set up output
fft_out = fftout; %average  amplidate across frequency band
%fqlabels = labels of each frquency band
fft_yout = yout; % amplitude at each discrete frequency (for plotting)
freq_bin_labels = label_yout; %labels for discrete frequency (for plotting) 

% open DQ spectra gui option
if strcmpi(viewGUIoption, 'true') 
    DQ_Spectra_GUI(EEG, fft_out, fqlabels, fft_yout, freq_bin_labels, chanArray);
end


%
% History
%
skipfields = {'EEG', 'Saveas', 'SeedNum','History'};
fn     = fieldnames(p.Results);
com = sprintf('%s = pop_continuousFFT( %s', inputname(1), inputname(1));

for q=1:length(fn)
        fn2com = fn{q};
        if ~ismember_bc2(fn2com, skipfields)
                fn2res = p.Results.(fn2com);
                if ~isempty(fn2res)
                        if ischar(fn2res)
                                if ~strcmpi(fn2res,'off')
                                        com = sprintf( '%s, ''%s'', ''%s''', com, fn2com, fn2res);
                                end
                        else
                                if iscell(fn2res)
                                        if ischar([fn2res{:}])
                                                fn2resstr = sprintf('''%s'' ', fn2res{:});
                                        else
                                                fn2resstr = vect2colon(cell2mat(fn2res), 'Sort','on');
                                        end
                                        fnformat = '{%s}';
                                else
                                    try
                                        fn2resstr = vect2colon(fn2res, 'Sort','on');
                                        fnformat = '%s';
                                        
                                    catch
                                        fn2resstr = mat2colon(fn2res); 
                                        fnformat = '%s'; 
                                    end
                                end
                                if strcmpi(fn2com,'Criterion')
                                        if p.Results.Criterion<100
                                                com = sprintf( ['%s, ''%s'', ' fnformat], com, fn2com, fn2resstr);
                                        end
                                else
                                        com = sprintf( ['%s, ''%s'', ' fnformat], com, fn2com, fn2resstr);
                                end
                        end
                end
        end
end
com = sprintf( '%s );', com);

% get history from script. EEG
switch shist
        case 1 % from GUI
                com = sprintf('%s %% GUI: %s', com, datestr(now));
                %fprintf('%%Equivalent command:\n%s\n\n', com);
                displayEquiComERP(com);
        case 2 % from script
                EEG = erphistory(EEG, [], com, 1);
        case 3
                % implicit
        otherwise %off or none
                com = '';
                return
end

msg2end
return