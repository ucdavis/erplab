%
%
%
%
% Hi Eric. I modified/edited the coding of pop_EEGsimulate, eegsimulateGUI, and pop_fakeEEG.
% For instance. Inserting a "trend" is separated from inserting an "evoked" activity. Indeed you may be able now of inserting both a
% linear trend and then 100 square-like evoked waveforms. I also changed some Parameter-Value pairs and variable names, and added memory capability to the GUI.
% I added Randow walk now also! :)
% Finally, I've moved your EEG-simulator to Utility menu.
%
% Cheers,
% Javier
%

function [EEG, com] = pop_EEGsimulate(EEG, varargin)
com='';
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if length(EEG)>1
        msgboxText =  'Unfortunately, this function does not work with multiple datasets';
        title = 'ERPLAB: multiple inputs';
        errorfound(msgboxText, title);
        return
end
if nargin==1
        if ~isempty(EEG) && isfield(EEG, 'epoch') && ~isempty(EEG.epoch)
                isepoched = 1;
        else
                isepoched = 0;
        end
        def  = erpworkingmemory('pop_EEGsimulate');
        if isempty(def)
                def = {'none', 'none', [],[],[], [], [], [], [], [], [], [], [], [], [], [], [], 'simulatedeeg', 1000, 1000, 10, 100, [], []};
        end
        if isempty(EEG)
                eeginfo = {[], 1000, [], [], [], 1};
        else
                if isempty(EEG.data)
                        fsx = 1000;
                        isepoched = 1;
                else
                        fsx = EEG.srate;
                end
                eeginfo = {EEG.setname, fsx, EEG.nbchan, EEG.pnts, EEG.chanlocs, isepoched};
        end
        %
        % call GUI
        %
        answer = eegsimulateGUI(def,eeginfo);
        
        %if user clicked cancel or x
        if isempty(answer)
                disp('User Selected cancel');
                return
        end
        
        trendtype       = answer{1};      %type of trend that you want to do (sin, cos, linear, dcoffset, squarefit, perfsquare)
        evoketype       = answer{2};      %type of evoked activity to insert (squarefit, perfsquare, erplike)
        chanArray1      = answer{3};      %channel(s) to be trended
        chanArray2      = answer{4};      %channel(s) to be trended
        sinamp          = answer{5};      %amplitude of sin and cos wave created
        sinfreq         = answer{6};      %frequency multiplier of sin and cos wave
        rwpvalueArray   = answer{7};      % p-values for random walk
        dcoffset        = answer{8};      %amount of vertical shif
        linslope        = answer{9};      %slope for linear trend, small = gradual, large = steap
        onsetArray      = answer{10};      %time for square plot to start at in sec
        amplitudeArray  = answer{11};     %amplitude of square plot
        squaredur       = answer{12};      %duration in ms
        nprechebychev   = answer{13};     %ms of zeroes before chebychev window
        npostchebychev  = answer{14};     %ms of zeroes after chebychev window
        chebychevwin    = answer{15};     %length chebychev window in ms
        %onsetArray      = answer{15};
        %amplitudeArray        = answer{16};
        chebyfreq       = answer{16};
        chebyphase      = answer{17};
        eegtype         = answer{18};
        simduration     = answer{19};
        simsrate        = answer{20};
        simnchan        = answer{21};
        simeegamp       = answer{22};
        type2insert     = answer{23};
        onseterrorval   = answer{24};
        
        erpworkingmemory('pop_EEGsimulate', answer);
        
        pause(0.1)
        
        [EEG, com]  = pop_EEGsimulate(EEG, 'Trendtype', trendtype, 'Evokedtype', evoketype, 'SinAmplitude', sinamp,...
                'SinFrequency', sinfreq, 'Channel2Trend', chanArray1, 'Channel2Evoke', chanArray2, 'RWpvalue', rwpvalueArray,...
                'DCoffset', dcoffset, 'Linearslope', linslope, 'EvokedOnset', onsetArray, 'SquareDuration', squaredur,...
                'EvokedAmplitude', amplitudeArray, 'Chebychevpre', nprechebychev, 'Chebychevpost', npostchebychev,...
                'Chebychevwin', chebychevwin, 'Chebychevfreq', chebyfreq, 'Chebychevphase', chebyphase,'EEGtype', eegtype, 'SimDuration', simduration,...
                'SimSampleRate', simsrate,'SimNumChan', simnchan, 'SimAmplitude', simeegamp, 'EventCode', type2insert, 'OnsetErrorval', onseterrorval);   %%%%%
        pause(0.1)
        return
        
end

p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG', @isstruct);
% option(s)
p.addParamValue('Trendtype', 'none', @ischar);
p.addParamValue('Evokedtype', 'none', @ischar);
p.addParamValue('SinAmplitude', [], @isnumeric);
p.addParamValue('SinFrequency', [], @isnumeric);
p.addParamValue('RWpvalue', [], @isnumeric);
p.addParamValue('Channel2Trend', [], @isnumeric);
p.addParamValue('Channel2Evoke', [], @isnumeric);
p.addParamValue('DCoffset', 0, @isnumeric);
p.addParamValue('Linearslope', [], @isnumeric);
p.addParamValue('EvokedOnset', [], @isnumeric);
p.addParamValue('EvokedAmplitude', 1, @isnumeric);
p.addParamValue('SquareDuration', 200, @isnumeric);
%         p.addParamValue('SquareAmplitude', 40, @isnumeric);
p.addParamValue('Chebychevpre', [], @isnumeric);     %%%%%
p.addParamValue('Chebychevpost', [], @isnumeric);     %%%%%
p.addParamValue('Chebychevwin', [], @isnumeric);
%         p.addParamValue('Chebychevonset', 0, @isnumeric);
%         p.addParamValue('Chebychevamp', 0, @isnumeric);
p.addParamValue('Chebychevfreq', [], @isnumeric);
p.addParamValue('Chebychevphase', [], @isnumeric);
p.addParamValue('EEGtype', 'simulatedeeg', @ischar);
p.addParamValue('SimDuration', 500, @isnumeric);
p.addParamValue('SimSampleRate', 1000, @isnumeric);
p.addParamValue('SimNumChan', 16, @isnumeric);
p.addParamValue('SimAmplitude', 100, @isnumeric);
p.addParamValue('EventCode', []);
p.addParamValue('OnsetErrorVal', [], @isnumeric);

p.parse(EEG, varargin{:});

trendtype      = p.Results.Trendtype;
evoketype      = p.Results.Evokedtype;
sinamp         = p.Results.SinAmplitude;
sinfreq        = p.Results.SinFrequency;
rwpvalueArray  = p.Results.RWpvalue;
chanArray1     = p.Results.Channel2Trend;
chanArray2     = p.Results.Channel2Evoke;
dcoffset       = p.Results.DCoffset;
linslope       = p.Results.Linearslope;
onsetArray     = p.Results.EvokedOnset;
amplitudeArray = p.Results.EvokedAmplitude;
squaredur      = p.Results.SquareDuration;
nprechebychev  = p.Results.Chebychevpre;     %number of zeroes after chebychevwindow (ms)
npostchebychev = p.Results.Chebychevpost;    %number of zeros after chebychevwindow (ms)
chebychevwin   = p.Results.Chebychevwin;     %window for Guasian distribuation (ms)
%onsetArray = p.Results.Chebychevonset;   %time points (in sec) when waveform added
%amplitudeArray   = p.Results.Chebychevamp;     %amplitude
chebychevfreq  = p.Results.Chebychevfreq;
chebychevphase = p.Results.Chebychevphase;
eegtype        = p.Results.EEGtype;
simduration    = p.Results.SimDuration;
simsrate       = p.Results.SimSampleRate;
simnchan       = p.Results.SimNumChan;
simeegamp      = p.Results.SimAmplitude;
type2insert    = p.Results.EventCode;
onseterrorval  = p.Results.OnsetErrorVal;


if isempty(onseterrorval)
        onseterrorval=0;
end

%simulate the EEG, if user selects to simulate
if strcmpi(eegtype,'simulatedeeg')
        %EEG.setname = 'SimEEG'; % suggested
        EEG  = pop_fakeEEG('Setname', 'SimEEG', 'Numchannels', simnchan,'Duration', simduration, 'Samplerate', simsrate, 'Amplitude', simeegamp);
        %EEG  = pop_fakeEEG('Setname', 'test', 'Pathname', '/test',  'Numchannels', simnchan,'Times', simduration, 'Samplerate', simsrate);
end
if ~isempty(EEG) && isfield(EEG, 'epoch') && ~isempty(EEG.epoch)
        msgboxText =  'Unfortunately, this function only works with continuous datasets';
        title = 'ERPLAB: multiple inputs';
        errorfound(msgboxText, title);
        return
end

numdatapoint       = size(EEG.data(1,:));
numdatapoint       = numdatapoint(2);               %number of data points
time               = EEG.xmax;                      %total time in dataset

chanArray1 = chanArray1(chanArray1>0);
chanArray2 = chanArray2(chanArray2>0);
% trendtype

if isempty(chanArray1) && ~strcmpi(trendtype,'none')
        msgboxText =  'Please enter at least one channel to edit';
        title = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end
if isempty(chanArray2) && ~strcmpi(evoketype,'none')
        msgboxText =  'Please enter at least one channel to edit';
        title = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end
if length(nprechebychev)~=1  && strcmpi(evoketype,'erplike')
        msgboxText =  'Invalid input for Chebychev pre';
        title      = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end
if length(npostchebychev)~=1   && strcmpi(evoketype,'erplike')
        msgboxText =  'Invalid input for Chebychev post';
        title      = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end
if length(chebychevwin)~=1   && strcmpi(evoketype,'erplike')
        msgboxText =  'Invalid input for Chebychev window';
        title      = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end
if isempty(amplitudeArray)   && ~strcmpi(evoketype,'none')
        msgboxText =  'Invalid input for Amplitude';
        title      = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end
if isempty(onsetArray)  && ~strcmpi(evoketype,'none')
        msgboxText =  'Invalid input for onset time';
        title      = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end
if length(chebychevfreq)~=1   && strcmpi(evoketype,'erplike')
        msgboxText =  'Invalid input for Frequency';
        title      = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end
if length(chebychevphase)~=1   && strcmpi(evoketype,'erplike')
        msgboxText =  'Invalid input for phase';
        title      = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end
if length(amplitudeArray)==1 && length(onsetArray)>1 && ~strcmpi(evoketype,'none')
        amplitudeArray = repmat(amplitudeArray,1,length(onsetArray));
end
if length(amplitudeArray)~=length(onsetArray) && ~strcmpi(evoketype,'none')
        msgboxText =  'Amplitude array must have one value or as many as Onset array';
        title      = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end
if strcmpi(trendtype,'rwalk') && length(rwpvalueArray)==1 && length(chanArray1)>1
        rwpvalueArray = repmat(rwpvalueArray,1,length(chanArray1));
end
if strcmpi(trendtype,'rwalk') && length(rwpvalueArray)~=length(chanArray1)
        msgboxText =  'p-value array must have one value or as many as channels to trend';
        title      = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end

%
% Add trend
%
for i=1:length(chanArray1)
        currchan = chanArray1(i);
        switch trendtype
                case 'sin'   %Sin Trend
                        w = numdatapoint;
                        fs = EEG.srate; % sample rate in Hz
                        
                        secsignalpoints = w; % signal duration in points
                        secsignaltime   = secsignalpoints/fs;
                        a = 0:1/(fs):secsignaltime-1/(fs); % time vector
                        arti = sin(2*pi*sinfreq*a)*sinamp;
                        EEG.data(currchan,:) = EEG.data(currchan,:) + arti;
                        fprintf('Adding sinusoidal trend to channel #%g...Please wait...\n', currchan);
                case 'rwalk' % random walk.
                        yrwalk = randomwalk(0,rwpvalueArray(i),numdatapoint);
                        EEG.data(currchan,:) = EEG.data(currchan,:)+yrwalk;
                        fprintf('Adding random-walk trend to channel #%g (p-value = %.3f)...Please wait...\n', currchan, rwpvalueArray(i));
                case 'linear' %Linear Trend
                        a    = linspace(0, time, numdatapoint);
                        arti = linslope*a;
                        EEG.data(currchan,:) = EEG.data(currchan,:)+arti;
                        fprintf('Adding linear trend to channel #%g...Please wait...\n', currchan);
                case 'dcoffset' %Vertical Shift
                        a = linspace(0, time, numdatapoint);
                        EEG.data(currchan,:) = EEG.data(currchan,:)+dcoffset;
                        if i==1; fprintf('Adding dc offset to channel #%g...Please wait...\n', currchan);end
        end
end

%
% Insert evoke activity
%
% type2insert = 502;
fs  = EEG.srate;                                 %sample rate in Hz

for i=1:length(chanArray2)
        currchan = chanArray2(i);
        %
        % Insert evoked activity
        %
        if strcmpi(evoketype, 'squarefit') || strcmpi(evoketype, 'perfsquare')
                %Fit square plot
                numstarttime = length(onsetArray);
                k=1; gogo=1;
                while k<=numstarttime && gogo
                        starttime    = round(onsetArray(k)*EEG.srate);         %convert duration from s to datapoint number
                        dataduration = round(squaredur*EEG.srate/1000);         %convert duration from ms to number of datapoints
                        %endtime      = starttime+dataduration;
                        
                        if strcmpi(evoketype, 'squarefit')
                                if starttime<EEG.pnts && (starttime+dataduration-1)<=EEG.pnts
                                        EEG.data(currchan, starttime:starttime+dataduration-1) = EEG.data(currchan, starttime:starttime+dataduration-1) + repmat(amplitudeArray(k),1,dataduration);  %%%%%need to add the chebychev equations here
                                else
                                        gogo=0;
                                end
                                %for j=starttime:endtime                         %square plot added from 1 to size of latency
                                %        EEG.data(currchan, j) = EEG.data(currchan, j)+amplitudeArray(k);
                                %end
                                
                                if k==1; fprintf('Inserting square-waveforms (additive) in channel #%g...Please wait...\n', currchan);end
                        elseif strcmpi(evoketype, 'perfsquare')                  %Insert perfectly square plot
                                
                                if starttime<EEG.pnts && (starttime+dataduration-1)<=EEG.pnts
                                        EEG.data(currchan, starttime:starttime+dataduration-1) = repmat(amplitudeArray(k),1,dataduration);  %%%%%need to add the chebychev equations here
                                else
                                        gogo=0;
                                end
                                %for j=starttime:endtime                         %square plot added from start time to endtime (in datapoint)
                                %        base = EEG.data(currchan, starttime);
                                %        EEG.data(currchan, j) = base+amplitudeArray(k);
                                %end
                                if k==1; fprintf('Inserting square-waveforms (replacement) in channel #%g...Please wait...\n', currchan);end
                        end
                        if i==1 % insert event code once (1 channel)
                                numevent     = length(EEG.event);
                                EEG.event(1,numevent+1).type      = type2insert;
                                EEG.urevent(1,numevent+1).type    = type2insert;
                                EEG.event(1,numevent+1).latency   = starttime;
                                EEG.event(1,numevent+1).urevent   = numevent+1;
                                EEG.event(1,numevent+1).duration  = 0;
                                EEG.urevent(1,numevent+1).latency = starttime;
                        end
                        k=k+1;
                end
                EEG = eeg_checkset(EEG, 'eventconsistency');
        end
        if strcmpi(evoketype, 'erplike')
                numstarttime = length(onsetArray);
                for k=1:numstarttime
                        % I rewrote the code here. JLC
                        currerroradd = onseterrorval*2*(rand(1)-.5);                    %error value that you will add to npre
                        npre  = round(((nprechebychev+currerroradd)*EEG.srate/1000));    %num datapoints pre window of 0s
                        npost = round(npostchebychev*EEG.srate/1000);                  %num datapoints post window of 0s
                        chebylength = round(chebychevwin*EEG.srate/1000);              %in # of datapoints
                        w           = chebwin(chebylength)';
                        w           = [zeros(1, npre)  w  zeros(1, npost)];
                        durlength   = length(w);                                       %length npre chebywin and npost
                        secsignalpoints = length(w);                                   %signal duration in points
                        secsignaltime   = secsignalpoints/fs;
                        a = 0:1/(fs):secsignaltime-1/(fs);                             %time vector
                        sinadd     = sin(2*pi*chebychevfreq*a+(chebychevphase-(currerroradd*pi)/100));
                        winsine    = sinadd.*w;
                        factoramp  = amplitudeArray(k)/(max(winsine)-min(winsine));
                        winsine    = winsine*factoramp;
                        
                        %hk = figure; plot(winsine); hold on; plot(sinadd,'r');plot(w, 'k');hold off
                        %pause(0.5)
                        %close(hk)
                        
                        starttime = round(onsetArray(k)*fs) ;         %onset(s) in datapoints
                        %endtime   = starttime+durlength-1;
                        
                        if starttime<EEG.pnts && (starttime+durlength-1)<=EEG.pnts
                                EEG.data(currchan, starttime:starttime+durlength-1) = EEG.data(currchan, starttime:starttime+durlength-1) + winsine;  %%%%%need to add the chebychev equations here
                                if i==1 % insert event code once (1 channel)
                                        numevent = length(EEG.event);
                                        EEG.event(1,numevent+1).type      = type2insert;
                                        EEG.event(1,numevent+1).latency   = starttime;
                                        EEG.event(1,numevent+1).urevent   = numevent+1;
                                        EEG.event(1,numevent+1).duration  = 0;
                                        EEG.urevent(1,numevent+1).type    = type2insert;
                                        EEG.urevent(1,numevent+1).latency = starttime;
                                end
                        else
                                break
                        end
                        if k==1
                                fprintf('Inserting ERP-like-waveforms (additive) in channel #%g...Please wait...\n', currchan);
                        end
                end
                EEG = eeg_checkset(EEG, 'eventconsistency');
        end
end

com = 'EEG = pop_EEGsimulate(EEG);'; % temporary...It needs to be finished.

msg2end
return
