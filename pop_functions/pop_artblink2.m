% >> EEG = pop_artblink2(EEG, twin, bwidth, ccovth, chan, flag);
%
% Inputs
%
% EEG       - input dataset
% twin      - time period in ms to apply this tool (start end). Example [-200 800]
% bwidth    - Width of the simulated blink (Chebyshev window) in ms.
% ccovth    - normalized cros-covarianze (ccov). Value between 0 to 1. Higer ccov means higer similarity
% chan      - channel(s) to search artifacts.
% flag      - flag value between 1 to 8 to be marked when an artifact is found. (1 value)
%
% Output
%
% EEG       - output dataset
%
%  TEMPORARY VERSION. ONLY FOR TESTING
%  Calculates the cross-covarianze between each epoch, at the specified channel(s), with this waveform:
%         _
%        / \
%    ___/   \___  w = chebwin(blinkpnts)';
%
% See also pop_artbarb pop_artblink pop_artderiv pop_artdiff pop_artflatline pop_artmwppth pop_artstep artifactmenuGUI.m markartifacts.m
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Steven Luck
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

function [EEG, com] = pop_artblink2(EEG, evcode, testwindow, bwidth, ccovth, chanArray, varargin)
com = '';
if nargin<1
        help pop_artblink2
        return
end
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if nargin==1
        if length(EEG)>1
                msgboxText =  'Unfortunately, this function does not work with multiple datasets';
                title = 'ERPLAB: multiple inputs';
                errorfound(msgboxText, title);
                return
        end
        if isempty(EEG.data)
                msgboxText = 'ERROR: pop_artblink2() cannot read an empty dataset!';
                title = 'ERPLAB: pop_artblink2';
                errorfound(msgboxText, title);
                return
        end
        if ~isempty(EEG.epoch)
                if isfield(EEG, 'EVENTLIST')
                        if isfield(EEG.EVENTLIST, 'eventinfo')
                                if isempty(EEG.EVENTLIST.eventinfo)
                                        msgboxText = ['EVENTLIST.eventinfo structure is empty!\n'...
                                                'You will not be able to perform ERPLAB''s\n'...
                                                'artifact detection tools.'];
                                        title = 'ERPLAB: Error';
                                        errorfound(sprintf(msgboxText), title);
                                        return
                                end
                        else
                                msgboxText =  ['EVENTLIST.eventinfo structure was not found!\n'...
                                        'You will not be able to perform ERPLAB''s\n'...
                                        'artifact detection tools.'];
                                title = 'ERPLAB: Error';
                                errorfound(sprintf(msgboxText), title);
                                return
                        end
                else
                        msgboxText =  ['EVENTLIST structure was not found!\n'...
                                'You will not be able to perform ERPLAB''s\n'...
                                'artifact detection tools.'];
                        title = 'ERPLAB: Error';
                        errorfound(sprintf(msgboxText), title);
                        return
                end
        else
                % continuous
                
        end
        prompt = {'Test period (start end) [ms]', 'Blink Width [ms]', 'Normalized Cross-Covariance Threshold:', 'Channel(s)'};
        dlg_title = 'Blink Detection';
        defx   = {[EEG.xmin*1000 EEG.xmax*1000] 400 0.7 EEG.nbchan 0};
        def    = erpworkingmemory('pop_artblink2');
        
        if isempty(def)
                def = defx;
        else
                if def{1}(1)<EEG.xmin*1000
                        def{1}(1) = single(EEG.xmin*1000);
                end
                if def{1}(2)>EEG.xmax*1000
                        def{1}(2) = single(EEG.xmax*1000);
                end
                
                def{4} = def{4}(ismember_bc2(def{4},1:EEG.nbchan));
        end
        try
                chanlabels = {EEG.chanlocs.labels};
        catch
                chanlabels = [];
        end
        
        %
        % Call GUI
        %
        answer = artifactmenuGUI(prompt, dlg_title, def, defx, chanlabels);
        
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        
        testwindow =  answer{1};
        blinkwidth =  answer{2}; % in msec
        ccovth     =  answer{3};
        chanArray  =  unique_bc2(answer{4}); % avoids repeated channels
        flag       =  answer{5};
        viewer     =  answer{end};
        
        if viewer
                viewstr = 'on';
        else
                viewstr = 'off';
        end
        if ~isempty(find(flag<1 | flag>16, 1))
                msgboxText{1} =  'ERROR, flag cannot be greater than 16 nor lesser than 1';
                title = 'ERPLAB: Flag input';
                errorfound(msgboxText, title);
                return
        end
        erpworkingmemory('pop_artblink2', {answer{1} answer{2} answer{3} answer{4} answer{5}});
        EEG.setname = [EEG.setname '_ar']; %suggest a new name
        
        %
        % Somersault
        %
        [EEG, com] = pop_artblink2(EEG, 'Twindow', testwindow, 'Blinkwidth', blinkwidth,...
                'Crosscov', ccovth, 'Channel', chanArray, 'Flag', flag, 'Review', viewstr, 'History', 'gui');
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG', @isstruct);
p.addRequired('evcode');
p.addRequired('testwindow', @isnumeric);
p.addRequired('bwidth', @isnumeric);
p.addRequired('ccovth', @isnumeric);
p.addRequired('chanArray', @isnumeric);
% option(s)
p.addParamValue('flag', 1);
p.addParamValue('duration', []);
p.addParamValue('enable', []);
p.addParamValue('recode', [], @isnumeric);
p.addParamValue('Review', 'off', @ischar); % to open a window with the marked epochs
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(EEG, evcode, testwindow, bwidth, ccovth, chanArray, varargin{:});

xflag     = p.Results.flag;
xduration = p.Results.duration;
xenable   = p.Results.enable;
xrecode   = p.Results.recode;

blinkwidth = bwidth;  % in msec
chanArray  = unique_bc2(chanArray); % avoids repeated channels

if strcmpi(p.Results.Review, 'on')% to open a window with the marked epochs
        eprev = 1;
else
        eprev = 0;
end
if ~isempty(find(xflag<1 | xflag>16, 1))
        error('ERPLAB says: error at pop_artblink2(). Flag cannot be greater than 16 or lesser than 1')
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

fs       = EEG.srate;
nch      = length(chanArray);
ntrial   = EEG.trials;
% if isempty(evcode)
%       if ischar(EEG.event(1).type)
%             evcode = unique_bc2({EEG.event.type});
%       else
%             evcode = unique_bc2([EEG.event.type]);
%       end
% end
if ~isempty(EEG.epoch)
        eindex = epoch4bin( EEG, evcode);
        
        [p1, p2, checkw] = window2sample(EEG, testwindow, fs);
        if checkw==1
                error('pop_artblink2() error: time window cannot be larger than epoch.')
        elseif checkw==2
                error('pop_artblink2() error: too narrow time window')
        end
        if isempty(EEG.reject.rejmanual)
                EEG.reject.rejmanual  = zeros(1,ntrial);
                EEG.reject.rejmanualE = zeros(EEG.nbchan, ntrial);
        end
        ntrial   = EEG.trials;
        epochwidth = p2-p1+1; % choosen epoch width in number of samples
else
        % Continuous
        mwindowsam  = round((testwindow*fs)/1000);  % mwindowms in samples
        indxevcode = geteventcontlat(EEG, evcode);
        
        if isempty(indxevcode)
                fprintf('\nWARNING: Event codes %s were not found. pop_artblink2() was not performed.\n\n', vect2colon(evcode))
                return
        end
        
        neegevent = length(EEG.event);
        if isfield(EEG.event,'enable')
                % In case there are empty values at EEG.enable
                enable  = {EEG.event.enable};
                empindx = find(cellfun(@isempty, enable));
                [enable{empindx}] = deal(1);% default value if it is empty
        else
                % if EEG.enable does not existe it will be full filled with 1s
                enable = num2cell(ones(1,neegevent));
        end
        [EEG.event(1:neegevent).enable] = enable{:};
        if isfield(EEG.event,'duration')
                % In case there are empty values at EEG.enable
                duration  = {EEG.event.duration};
                empindx = find(cellfun(@isempty, duration));
                [duration{empindx}] = deal(0);% default value if it is empty
                durationbckup = duration;
        else
                % if EEG.enable does not existe it will be full filled with 1s
                duration = num2cell(zeros(1,neegevent));
                durationbckup = duration;
        end
        if isfield(EEG.event,'flag')
                % In case there are empty values at EEG.enable
                flag  = {EEG.event.flag};
                empindx = find(cellfun(@isempty, flag));
                [flag{empindx}] = deal(0);% default value if it is empty
                %durationbckup = duration;
        else
                % if EEG.enable does not existe it will be full filled with 1s
                flag = num2cell(ones(1,neegevent));
                %durationbckup = duration;
        end
        
        [EEG.event(1:neegevent).duration] = duration{:};
        [EEG.event(1:neegevent).durationbckup] = duration{:};
        [EEG.event(1:neegevent).flag] = flag{:};
        ntrial   = length(indxevcode);
        epochwidth = diff(mwindowsam)+1; % choosen epoch width in number of samples
end

bwidthpntsmax = unique_bc2(round(max(blinkwidth*fs/1000)));
bwidthpntsmin = unique_bc2(round(min(blinkwidth*fs/1000)));

if nch>EEG.nbchan
        error('Error: pop_artblink2() number of tested channels cannot be greater than total.')
end
if bwidthpntsmax>epochwidth
        error('pop_artblink2() error: time window cannot be larger than epoch')
elseif bwidthpntsmin<15
        error('pop_artblink2() error: too narrow time window')
end

% if ~isempty(EEG.epoch)
%       if isempty(EEG.reject.rejmanual)
%             EEG.reject.rejmanual  = zeros(1,ntrial);
%             EEG.reject.rejmanualE = zeros(EEG.nbchan, ntrial);
%       end
% else
%       %continuous
% end

interARcounter = zeros(1,ntrial); % internal counter, for statistics
fprintf('channel #\n ');
fprintf('%s \n',num2str(chanArray));
%nbw = length(blinkwidth); % allows more than 1 testing (fake) blink

%
% Tests RT info
%
isRT = 1; % there is RT info by default

if isfield(EEG, 'EVENTLIST')
        if ~isfield(EEG.EVENTLIST.bdf, 'rt')
                isRT = 0;
        else
                valid_rt = nnz(~cellfun(@isempty,{EEG.EVENTLIST.bdf.rt}));
                if valid_rt==0
                        isRT = 0;
                end
        end
else
        isRT = 0;
end

%for s =1:nbw
%fprintf('Sweep %g: looking for %g msec blinks :\n ', s, blinkwidth(s));
fprintf('Looking for %g msec blinks :\n ', blinkwidth);

%blinkpnts  = round(blinkwidth(s)*fs/1000); % msec to samples
blinkpnts  = round(blinkwidth*fs/1000); % msec to samples
if blinkpnts<=epochwidth
        w0 = chebwin(round(blinkpnts/2))';
        y0 = [w0 zeros(1,epochwidth-length(w0))];
        %fp = find(y0==max(y0)); % find y0 peak
        [xxx, fp] = max(y0); % find y0 peak
        offsetw = round(epochwidth/2)-fp;
        y0 = circshift(y0',offsetw)';
        
        w1 = 0.6*chebwin(blinkpnts)';
        y1 = [w1 zeros(1,epochwidth-length(w1))];
        %fp = find(y0==max(y0)); % find y0 peak
        [xxx, fp] = max(y1); % find y0 peak
        offsetw = round(epochwidth/2)-fp;
        y1 = circshift(y1',offsetw)';
        y1 = circshift(y1',round(blinkpnts/16))';
        y0 = y0+y1;
        pky0 = max(y0);
        rateblk = 50/pky0;
        y0 = y0*rateblk; % 50uv fake blink
        
        midp = round((2*epochwidth-1)/2) ;  % 2N-1  length of xcov
        latp = round(blinkpnts/4);
else
        error('blink width is greater than epoch.')
end

% [b, a] = filter_tf(0, 2, 0.2, 20, EEG.srate);

for i=1:ntrial
        for ch=1:nch
                %fprintf('%g \n',chanArray(ch));
                if ~isempty(EEG.epoch) % for epoched dataset
                        datax  = EEG.data(chanArray(ch),p1:p2,i);
                        if isdoublep(datax)
                                datax = sgolayfilt(datax,3,11);
                        else
                                datax = single(sgolayfilt(double(datax),3,31));
                        end
                        [cov_trial] = xcov(datax,y0,'coeff');
                        xvm = max(abs(cov_trial)); % around zero lag
                        
                        if xvm>ccovth
                                interARcounter(i) = 1  ;   % internal counter, for statistics
                                %hk = figure;plot(datax); hold on ; plot(dataxxx,'r');hold off
                                %hk2 = figure;plot(cov_trial);
                                %                   close(hk)
                                
                                % flaf 1 is obligatory
                                [EEG, errorm]= markartifacts(EEG, xflag, chanArray, ch, i, isRT);
                                if errorm==1
                                        error(['ERPLAB: There was not latency at the epoch ' num2str(i)])
                                elseif errorm==2
                                        error('ERPLAB: invalid flag (0<=flag<=16)')
                                end
                        end
                else % for continuous dataset
                        samtest = round(EEG.event(indxevcode(i)).latency + mwindowsam); % samples for [start end] related to the continuous data
                        p1 = samtest(1);p2 = samtest(2);
                        if p1>=1 && p2<=EEG.pnts
                                datax = EEG.data(chanArray(ch), p1:p2);
                                %t1=
                                %t2=
                                %x  = EEG.data(chanArray(ch),t1:t2);
                                %end
                                %dataxxx = datax;
                        else
                                datax = [];
                        end
                        if ~isempty(datax)
                                if isdoublep(datax)
                                        datax = sgolayfilt(datax,3,11);
                                else
                                        datax = single(sgolayfilt(double(datax),3,31));
                                end
                                [cov_trial] = xcov(datax,y0,'coeff');
                                
                                aa = cov_trial(midp-latp:midp+latp); % ~around zero lag
                                bb = cov_trial(1:midp-latp);         % left
                                cc = cov_trial(midp+latp:end);       % right
                                
                                xvm = norm(aa)/sqrt(length(aa)); %rms ~ zero lag
                                xvL = norm(bb)/sqrt(length(bb)); %rms at left
                                xvR = norm(cc)/sqrt(length(cc)); %rms at righ
                                
                                if xvm>ccovth && xvL<xvm && xvR<xvm
                                        %ccovth
                                        %xvm
                                        %xvL
                                        %xvR
                                        interARcounter(i) = 1  ;   % internal counter, for statistics
                                        
                                        %hk = figure;plot(datax); hold on ; plot(dataxxx,'r');hold off
                                        %hk2 = figure;plot(cov_trial);
                                        %                   close(hk)
                                        
                                        % continuos
                                        if ~isempty(xenable)
                                                EEG.event(indxevcode(i)).enable = xenable;
                                        end
                                        if ~isempty(xduration)
                                                EEG.event(indxevcode(i)).duration = xduration;
                                        end
                                        if ~isempty(xflag)
                                                EEG.event(indxevcode(i)).flag = xflag;
                                        end
                                        if ~isempty(xrecode)
                                                EEG.event(indxevcode(i)).type = xrecode;
                                        end
                                        break
                                end
                        end
                end
        end
end
%end

% Update EEG.EVENTLIST.bdf structure (for RTs)
% EEG = updatebdfstruct(EEG);

fprintf('\n');

%
% performance
%
if ~isempty(EEG.epoch)
        perreject = nnz(interARcounter)/ntrial*100;
        fprintf('pop_artblink2() rejected a %.1f %% of total trials.\n', perreject);
        EEG.setname = [EEG.setname '_ar'];
else
        % continuous
        perreject = nnz(interARcounter);
        fprintf('pop_artblink2() disabled %g out of %g eventcodes.\n', perreject, ntrial);
        EEG.setname = [EEG.setname '_car'];
end

EEG = eeg_checkset( EEG , 'eventconsistency');

skipfields = {'EEG', 'Review', 'History'};
fn  = fieldnames(p.Results);
com = sprintf( '%s  = pop_artblink2( %s ', inputname(1), inputname(1));
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
                                        fn2resstr = vect2colon(cell2mat(fn2res), 'Sort','on');
                                        fnformat = '{%s}';
                                else
                                        fn2resstr = vect2colon(fn2res, 'Sort','on');
                                        fnformat = '%s';
                                end
                                com = sprintf( ['%s, ''%s'', ' fnformat], com, fn2com, fn2resstr);
                        end
                end
        end
end
com = sprintf( '%s );', com);

% get history from script
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