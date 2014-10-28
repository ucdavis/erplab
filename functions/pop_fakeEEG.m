function [EEG, com] = pop_fakeEEG(varargin)

if nargin==1
        
        %%%%Open GUI%%%%%% for now we return
        return
        
        if isempty(answer)
                disp('User Selected cancel');
                return
        end
        
        %     setname= answer{1};
        %     path= answer{2};
        %     numchan= answer{3};
        %     duration= answer{4};
        %     srate= answer{5};
        %    amp = answer{6};
        
        [EEG, com]  = pop_fakeEEG('Setname', setname, 'Pathname', datapath, 'Numchannels', numchan,...
                'Duration', duration, 'Samplerate', srate, 'Amplitude', amp );
        pause(0.1)
        return
        
else
        
        p = inputParser;
        p.FunctionName  = mfilename;
        p.CaseSensitive = false;
        p.addParamValue('Setname', 'SimEEG',@ischar);
        p.addParamValue('Pathname', '', @ischar);
        p.addParamValue('Numchannels', 16, @isnumeric);        % total num of channels
        p.addParamValue('Duration', 500, @isnumeric);          % total time
        p.addParamValue('Samplerate', 1000, @isnumeric);       % fs
        p.addParamValue('Amplitude', 100, @isnumeric);         % uV
        
        p.parse(varargin{:});
        
        setname   = p.Results.Setname;
        datapath  = p.Results.Pathname;
        numchan   = p.Results.Numchannels;
        duration  = p.Results.Duration;
        srate     = p.Results.Samplerate;
        amplitude = p.Results.Amplitude;
end

numdatapoints=duration*srate;   %number of actual datapoints in dataset

EEG = eeg_emptyset;
EEG.setname = setname;
%EEG.filename=[setname '.set'];
%EEG.filepath=datapath;
EEG.xmax   = duration;
EEG.nbchan = numchan;
EEG.srate  = srate;
EEG.times  = 1:numdatapoints;
EEG.pnts   = numdatapoints;

for i=1:numchan
        EEG.chanlocs(i).labels=['Ch_' num2str(i)];
end

%EEG  = pop_chanedit(EEG, 'lookup','/Users/ericfoo/Dropbox/erplab_depot/eeglab12_0_1_0b/plugins/dipfit2.2/standard_BESA/standard-10-5-cap385.elp');
%EEG.event(1).type=22;

%
% use the system clock to initialize the random number generator.
%
matlabrel = version('-date');
d1 = datenum(matlabrel);
d2 = datenum('9-Oct-2008');
if d1>d2
        %In versions of MATLAB beginning with R2008b, the simplest way to do this is to execute the following command at the beginning of each MATLAB session:
        %reset(RandStream.getDefaultStream,sum(100*clock))
        rng shuffle
else
        %For versions of MATLAB prior to R2008b you can execute the following commands:
        rand('twister',sum(100*clock))
end

fprintf('Generating simulated EEG data...Please wait...\n')

for ich=1:numchan
        %y(1)=3+5i;
        gogo = 1;
        while gogo %~isreal(y)
                %x    = zeros(1,numdatapoints);
                x    = rand(1,numdatapoints);
                avgx = mean(x);
                x    = 60*(x-avgx);
                %EEG.data(ich,:) = x*60;
                %x = EEG.data(ich,:);
                
                if ich==1
                        tdata = x; % in case y is undetermined...
                end
                
                ffterp    = fft(x);
                ffterpmag = abs(ffterp);
                k = linspace(1, 250, numdatapoints);
                %j = 1./k;
                
                for i=2:length(ffterp)
                        l = k(i);
                        ffterpmag(i) = ffterpmag(i)*(1/l);
                        ffterpmag(numdatapoints-i+2) = ffterpmag(numdatapoints-i+2)*(1/l);
                end
                
                fferpphase = angle(ffterp);
                
                z = ffterpmag.*exp(1i.*(fferpphase));
                y = ifft(z);
                
                if isreal(y)
                        gogo=0;
                        tdata = y;
                end
                %EEG.data(ich,:) = y*3000;
        end
        %EEG.data(ich,:) = tdata*3000;            
        factoramp       = amplitude/(max(tdata)-min(tdata));
        EEG.data(ich,:) = tdata*factoramp;       
%         amplitude
end

%  EEG  = pop_basicfilter( EEG,  1, 'Boundary', 'boundary', 'Cutoff', [ 0.1 30], 'Design', 'butter', 'Filter', 'bandpass', 'Order',  2 );

% if EEG.nbchan~=1
%         for i=2:EEG.nbchan
%                 EEG.data(i,:) = EEG.data(1,:);
%         end
% end

%eeglab redraw
