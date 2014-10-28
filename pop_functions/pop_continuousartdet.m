% pop_continuousartdet.m (alpha version). Reject commonly recorded artifactual potentials (c.r.a.p.)
%
% There are a number of common artifacts that you will see in nearly every EEG data file. These
% include eyeblinks, slow voltage changes (caused mostly by skin potentials), muscle activity
% (from moving the head or tensing up the muscles in the face or neck), horizontal eye movements,
% and various types of C.R.A.P. (Commonly Recorded Artifactual Potentials).
%
% Although we usually perform artifact rejection on the segmented data, it's a good idea to
% examine the raw unsegmented EEG data first. You can usually identify patterns of artifacts,
% make sure there were no errors in the file, etc., more easily with the raw data [1].
%
% crap.m allows you to automatically identify large peak-to-peak differences or extreme amplitude
% values, within a moving window, across your continuous EEG dataset. After performing crap.m,
% artifactual segments will be rejected and replaced by a 'boundary' event code.
%
% USAGE
%
% EEG = pop_continuousartdet(EEG, parameters);
%
% Input:
%
% EEG         - continuous EEG dataset (EEGLAB's EEG structure)
%
% The available parameters are as follows:
%
%         'ampth'     - Thresolds (2 values). E.g. [-100 200]. In case one value is specified it will be taken as
%                       symmetric thresholds. E.g 150 means [-150 150]
%         'winms'     - moving window width in msec (default 2000 ms)
%         'stepms'    - moving window step (default 1000 ms)
%         'chanArray' - channel index(ices) to look for c.r.a.p.  (default all channels)
%         'firstdet'  - {'on'/'off'} mark only first artifactual channel per window
%         'fcutoff'   - frequency cutoff for pre-filtering the data (see below)
%         'forder'    - filter order. 1 value indicting the order (number of points) of the FIR filter to be used.
%                       default value is 26.
%         'shortisi'  - marked segment(s) closer than this value will be joined together.
%         'shortseg'  - remaining crap-free segment(s) shorter than this value will be rejected as well
%         'winoffset' - change the onset/offset of the marked segment (ms). Positive value will move the segment to the
%                       right; negative, to the left.
%         'colorseg'  - color for marking artifactual segments.
%
%
% 'fcutoff' accepts the following values:
%              - 2 integer values indicting the frequency cutoff.
%               For instance, for band-pass filter between 8 and 12 Hz write [8 12];
%               For low-pass filter under 30 Hz write [0 30];
%               For high-pass filter above 3 Hz write [3 0];
%
%              - A string (that will call a pre-defined cutoff value).
%               For instance: 'rdc','rdelta','rtheta','ralpha','rbeta','rgamma' or
%               'dc','delta','theta','alpha','beta','gamma'
%
%              'rdc'     -  removes the DC offset. Equivalent to [0 0] (remove the mean value). Default.
%              'rdelta'  -  removes delta band. Equivalent to [4 0.1]
%              'rtheta'  -  removes theta band. Equivalent to [8 4]
%              'ralpha'  -  removes alpha band. Equivalent to [13 8]
%              'rbeta'   -  removes beta band. Equivalent to [30 13]
%              'rgamma'  -  removes gamma band. Equivalent to [80 30]
%
%              'dc'     -  removes everything but the DC offset. Equivalent to [Inf Inf] (only keep the mean value).
%              'delta'  -  removes everything but  delta band. Equivalent to [0.1 4]
%              'theta'  -  removes everything but  theta band. Equivalent to [4 8]
%              'alpha'  -  removes everything but  alpha band. Equivalent to [8 13]
%              'beta'   -  removes everything but  beta band.  Equivalent to [13 30]
%              'gamma'  -  removes everything but  gamma band. Equivalent to [30 80]
%
%              'off' or 'no' -   disables any filter process.
%
%
% Output:
%
% EEG         - continuous crap-free EEG dataset
%
%
% Example 1:
% Reject segment of data where the amplitude (mean value removed) is >= than 200 uV or <= than -300 uV.
% Use a moving window of 2000 ms, 1000 ms step, exploring channels 1 to 12.
%
%
% Example 2:
% Reject segment of data where the instantaneous amplitude is >= than 120 uV or <= than -120 uV.
% Use a moving window of 2000 ms, 1000 ms step, exploring channels 1 to 12.
%
%
% Example 3:
% Reject segment of data where the peak-to-peak amplitude is >= 240 uV. Note that mean values does not matter in this case.
% Use a moving window of 2000 ms, 1000 ms step, exploring channels 1 to 12.
%
%
% Example 4:
% Reject segment of data where beta peak-to-peak amplitude is higher than 10 uV.
% Use a moving window of 1000 ms, 500 ms step, exploring channels 40 and 42.
%
% >> EEG = crap(EEG, 10, 1000, 500, [40 42], 'filter',[13 30]);
%    or
% >> EEG = crap(EEG, 10, 1000, 500, [40 42], 'filter','beta');
%
% Example 5:
% Reject segment of data where beta peak-to-peak amplitude is higher than 10 uV.
% Use a moving window of 1000 ms, 500 ms step, exploring channels 40 and 42.
%
% >> EEG = crap(EEG, 10, 1000, 500, [40 42], 'filter',[13 30]);
%    or
% >> EEG = crap(EEG, 10, 1000, 500, [40 42], 'filter','beta');
%
% Example 6:
% Reject segment of data where any peak-to-peak activity, but alpha, is higher than 80 uV.
% Use a moving window of 3000 ms, 1000 ms step, exploring channels all 60 channels.
% Use a 60th order filter.
%
% >> EEG = crap(EEG, 80, 3000, 100, 1:60, 'filter',[13 8], 'forder', 60);
%    or
% >> EEG = crap(EEG, 80, 3000, 100, 1:60, 'filter','ralpha', 'forder', 60);
%
% Example 7 (rare):
% Reject segment of data where the DC offset is >= than 15000 or <= than -15000 uV.
% Use a moving window of 2000 ms, 1000 ms step, exploring channels 1 to 10 and 16 to 32.
%
% >> EEG = crap(EEG, [-15000 15000], 2000, 1000, [1:10 16:32], 'filter','dc');
%
%
%
% Reference:
% [1] ERP Boot Camp: Data Analysis Tutorials. Emily S. Kappenman, Marissa L. Gamble, and Steven J. Luck. UC Davis
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

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
%
% Acknowledgment:
% Thanks to Paul Kieffaber for his advice on improving this function.
%

function [EEG, com] = pop_continuousartdet(EEG, varargin)% ampth, winms, stepms, chanArray, varargin)
com='';
if nargin<1
    help pop_continuousartdet
    return
end
if isobject(EEG) % eegobj
    whenEEGisanObject % calls a script for showing an error window
    return
end
if nargin==1
    
    serror = erplab_eegscanner(EEG, 'pop_continuousartdet', 0, 0, 0, 2, 0);
    if serror
        return
    end
    
    
    %         if length(EEG)>1
    %                 msgboxText =  'Unfortunately, this function does not work with multiple datasets';
    %                 title = 'ERPLAB: pop_continuousartdet';
    %                 errorfound(msgboxText, title);
    %                 return
    %         end
    %         if ~isempty(EEG.epoch)
    %                 msgboxText =  'pop_continuousartdet() only works on continuous datasets.';
    %                 title = 'ERPLAB: pop_continuousartdet';
    %                 errorfound(msgboxText, title);
    %                 return
    %         end
    %         if isempty(EEG.data)
    %                 msgboxText =  'pop_continuousartdet() cannot work on an empty dataset!';
    %                 title = 'ERPLAB: pop_continuousartdet';
    %                 errorfound(msgboxText, title);
    %                 return
    %         end
    if isica(EEG)
        msgboxText = ['This tool is thought to improve ICA performance by removing c.r.a.p. '...
            '(commonly recorded artifact potentials) in an early stage\n\n'...
            'However, your dataset is already ICA-ed\n\n'...
            'Applying this tool will wipe out all ICA information\n\n'...
            'Do you want to continue anyway?'];
        
        title = 'ERPLAB: pop_continuousartdet() WARNING';
        button = askquest(sprintf(msgboxText), title);
        
        if ~strcmpi(button,'yes')
            disp('User selected Cancel')
            return
        end
    end
    
    %
    % Call GUI
    %
    answer    = continuousartifactGUI(EEG.srate, EEG.nbchan, EEG.chanlocs);
    if isempty(answer)
        disp('User selected Cancel')
        return
    end
    ampth     = answer{1};
    winms     = answer{2};
    stepms    = answer{3};
    chanArray = answer{4};
    fcutoff   = [answer{5} answer{6}];
    includef  = answer{7};
    
    if ~isempty(includef)
        if includef==0 && fcutoff(1)~=fcutoff(2)% when it means "excluded" frequency cuttof is inverse to make a notch filter
            fcutoff = circshift(fcutoff',1)';
        elseif includef==1 && fcutoff(1)==0 && fcutoff(2)==0
            fcutoff = [inf inf]; % [inf inf] to include the mean of data; fcutoff = [0 0] means exclude the mean
        else
            %...
        end
    end
    
    forder    = 100; % fixed order when GUI is used
    firstdet  = answer{8};
    if firstdet==1
        fdet = 'on';
    else
        fdet = 'off';
    end
    shortisi  = answer{9};
    shortseg  = answer{10};
    winoffset = answer{11};
    memoryCARTGUI = erpworkingmemory('continuousartifactGUI');
    colorseg  = memoryCARTGUI.colorseg;
    %colorseg  = answer{12};
    EEG.setname = [EEG.setname '_car'];
    
    %
    % Somersault
    %
    [EEG, com] = pop_continuousartdet(EEG, 'chanArray', chanArray, 'ampth', ampth,...
        'winms', winms, 'stepms', stepms, 'firstdet', fdet, 'fcutoff', fcutoff,...
        'forder', forder, 'shortisi', shortisi, 'shortseg', shortseg,...
        'winoffset', winoffset, 'colorseg', colorseg, 'History', 'gui');
    pause(0.1)
    return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG');
% option(s)
p.addParamValue('ampth', [-150 150],@isnumeric);
p.addParamValue('winms', 1000, @isnumeric);
p.addParamValue('stepms', 500, @isnumeric);
p.addParamValue('chanArray', 1:EEG.nbchan, @isnumeric);
p.addParamValue('firstdet', 'on', @ischar); % 'on' means mark only first artifactual channel per window
p.addParamValue('fcutoff', []);
p.addParamValue('forder', [], @isnumeric);
p.addParamValue('shortisi', [], @isnumeric);
p.addParamValue('shortseg', [], @isnumeric);
p.addParamValue('winoffset', [], @isnumeric);
p.addParamValue('colorseg', [1.0000    0.9765    0.5294], @isnumeric);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(EEG, varargin{:});

if length(EEG)>1
    msgboxText =  'Unfortunately, this function does not work with multiple datasets';
    error(msgboxText)
end
if ~isempty(EEG.epoch)
    msgboxText =  'pop_continuousartdet() only works on continuous datasets.';
    error(msgboxText)
end
if isempty(EEG.data)
    msgboxText =  'pop_continuousartdet() cannot work on an empty dataset!';
    error(msgboxText);
end

ampth     = p.Results.ampth;
winms     = p.Results.winms;
stepms    = p.Results.stepms;
chanArray = p.Results.chanArray;

if strcmpi(p.Results.firstdet, 'on') || strcmpi(p.Results.firstdet, 'yes')
    firstdet = 1;
else
    firstdet = 0;
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
fcutoff   = p.Results.fcutoff;
forder    = p.Results.forder;
shortisi  = p.Results.shortisi; % shortest isi in ms
shortseg  = p.Results.shortseg; % shortest segment in ms
winoffset = p.Results.winoffset; % shortest segment in ms
colorseg  = p.Results.colorseg;

if numel(ampth)~=1 && numel(ampth)~=2
    error('ERPLAB says: for threshold amplitude you must specify 1 or 2 values only.')
end
if ~isempty(forder)
    if mod(forder,2)~=0
        forder = forder+1;
        fprintf('filter order was changed to an even number (%g) because of the forward-reverse filtering.\n', forder)
    end
end
if ischar(fcutoff)
    %
    % Pre-defined bands
    %
    % Removing
    if strcmpi(fcutoff,'rdc') || strcmpi(fcutoff,'rmean')
        fcutoff = [0 0];           % remove mean
    elseif strcmpi(fcutoff,'rdelta') % remove delta
        fcutoff = [4 0.1];
    elseif strcmpi(fcutoff,'rtheta') % remove theta
        fcutoff = [8 4];
    elseif strcmpi(fcutoff,'ralpha') % remove alpha
        fcutoff = [13 8];
    elseif strcmpi(fcutoff,'rbeta')  % remove beta
        fcutoff = [30 13];
    elseif strcmpi(fcutoff,'rgamma') % remove gamma
        fcutoff = [80 30];
        % keeping
    elseif strcmpi(fcutoff,'dc') || strcmpi(fcutoff,'mean') % keep only the mean
        fcutoff = [inf inf];
    elseif strcmpi(fcutoff,'delta') % keep only delta
        fcutoff = [0.1 4];
    elseif strcmpi(fcutoff,'theta') % keep only theta
        fcutoff = [4 8];
    elseif strcmpi(fcutoff,'alpha') % keep only alpha
        fcutoff = [8 13];
    elseif strcmpi(fcutoff,'beta')  % keep only beta
        fcutoff = [13 30];
    elseif strcmpi(fcutoff,'gamma') % keep only gamma
        fcutoff = [30 80];
    elseif strcmpi(fcutoff,'off') || strcmpi(fcutoff,'no') % turn off filtering
        fcutoff = [];
    else
        error('error: unknown pre-defined band. Try with a numeric range of frequencies.')
    end
else
    if ~isempty(fcutoff)
        if numel(fcutoff)~=2
            error('error: 2 values are needed for cutoff.')
        end
        if ~isinf(fcutoff(1)) && ~isinf(fcutoff(2)) && ~isnan(fcutoff(1)) && ~isnan(fcutoff(2))
            if fcutoff(1)~=0 && fcutoff(1)==fcutoff(2)
                error('error: cutoff must have 2 different values. Except for [0 0] or [Inf Inf]. See help pop_continuousartdet')
            end
            if fcutoff(1)<0 || fcutoff(2)<0
                error('error: Cutoff values must be >= 0, or Inf')
            end
            if fcutoff(1)>EEG.srate/2 || fcutoff(2)>EEG.srate/2
                error('error: frequency cutoff is higher than nyquist frequency (EEG.srate/2)')
            end
        else
            if (isinf(fcutoff(1)) && ~isinf(fcutoff(2))) || (~isinf(fcutoff(1)) && isinf(fcutoff(2))) ||...
                    (isnan(fcutoff(1)) || isnan(fcutoff(2)))
                error('error: cutoff can not have NaN or Inf number. Only [Inf Inf] is allowed for evaluating the mean value.')
            end
        end
    end
end

%
% subroutine
%
[WinRej, chanrej] = basicrap(EEG, chanArray, ampth, winms, stepms, firstdet, fcutoff, forder); %, filter, forder)
shortisisam  = floor(shortisi*EEG.srate/1000);  % to samples
shortsegsam  = floor(shortseg*EEG.srate/1000);  % to samples
winoffsetsam = floor(winoffset*EEG.srate/1000); % to samples

if isempty(WinRej)
    fprintf('\nCriterion was not found. No rejection was performed.\n');
else
    %colorseg = [1.0000    0.9765    0.5294];
    if ~isempty(shortisisam)
        [WinRej, chanrej ] = joinclosesegments(WinRej, chanrej, shortisisam);
    end
    if ~isempty(shortsegsam)
        [WinRej, chanrej ] = discardshortsegments(WinRej, chanrej, shortsegsam);
    end
    if ~isempty(winoffsetsam)
        [WinRej, chanrej ] = movesegments(WinRej, chanrej, winoffsetsam, EEG.pnts);
    end
    
    colormatrej = repmat(colorseg, size(WinRej,1),1);
    matrixrej = [WinRej colormatrej chanrej];
    assignin('base', 'WinRej', WinRej)
    fprintf('\n %g segments were marked.\n\n', size(WinRej,1));
    
    commrej = sprintf('%s = eeg_eegrej( %s, WinRej);', inputname(1), inputname(1));
    % call figure
    eegplot(EEG.data, 'winrej', matrixrej, 'srate', EEG.srate,'butlabel','REJECT','command', commrej,'events', EEG.event,'winlength', 50);
    
    EEG = eeg_checkset( EEG );
    if length(EEG.event)>=1
        if EEG.event(end).latency>EEG.pnts
            EEG = pop_editeventvals(EEG,'delete',length(EEG.event));
            EEG = eeg_checkset( EEG );
        end
    end
    if length(EEG.event)>=1
        if EEG.event(1).latency<1
            EEG = pop_editeventvals(EEG,'delete',1);
            EEG = eeg_checkset( EEG );
        end
    end
    EEG = eeg_checkset( EEG );
end

skipfields = {'EEG', 'History'};
fn  = fieldnames(p.Results);
com = sprintf( '%s = pop_continuousartdet( %s ',  inputname(1), inputname(1));
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
                com = sprintf( '%s, ''%s'', %s', com, fn2com, vect2colon(fn2res,'Repeat','on'));
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
end

%
% Completion statement
%
msg2end
return


