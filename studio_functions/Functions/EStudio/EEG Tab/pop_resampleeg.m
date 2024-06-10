% PURPOSE:  pop_resampleeg.m
%           resample ERPsets
%

% FORMAT:
% [EEG, LASTCOM] = pop_resamplerp( EEG, 'Freq2resamp',Freq2resamp, 'TimeRange',TimeRange,...
%         'Saveas', 'off', 'History', 'gui');

% Inputs:
%
%EEG           -EEG structure
%Freq2resamp   -new sampling rate e.g., 200 Hz
%TimeRange     -new time range e.g., [-300 900]ms


%%We used some functions from EEGlab in this routine


% *** This function is part of ERPLAB Studio ***
% Author: Guanghui Zhang & Steven Luck
% ghzhang@ucdavis.edu, sjluck@ucdavis.edu
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Mar. 2024

function [EEG, LASTCOM] = pop_resampleeg(EEG, varargin)
LASTCOM = '';

if nargin < 1
    help pop_resampleeg
    return
end
if isempty(EEG)
    msgboxText =  'Cannot resample an empty eegset';
    title = 'ERPLAB: pop_resampleeg() error';
    errorfound(msgboxText, title);
    return
end
if isempty(EEG(1).data)
    msgboxText =  'Cannot resample an empty EEGset';
    title = 'ERPLAB: pop_resampleeg() error';
    errorfound(msgboxText, title);
    return
end

if EEG(1).trials==1
    msgboxText =  'Cannot resample continous EEGset';
    title = 'ERPLAB: pop_resampleeg() error';
    errorfound(msgboxText, title);
    return
end

if nargin==1
    
    Freq2resamp = EEG.srate;
    TimeRange = [EEG.times(1),EEG.times(end)];
    %
    % Somersault
    %
    [EEG, LASTCOM] = pop_resampleeg( EEG, 'Freq2resamp',Freq2resamp, 'TimeRange',TimeRange,...
        'Saveas', 'off', 'History', 'gui');
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
p.addParamValue('Freq2resamp', [],@isnumeric);
p.addParamValue('TimeRange', [], @isnumeric);
p.addParamValue('Saveas', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(EEG, varargin{:});

Freq2resamp = p.Results.Freq2resamp;
if isempty(Freq2resamp) || numel(Freq2resamp)~=1 || any(Freq2resamp<=0)
    Freq2resamp = EEG.srate;
end

TimeRange= p.Results.TimeRange;
TimeRange = unique(TimeRange);
if isempty(TimeRange) || numel(TimeRange)~=2 || TimeRange(1)>=EEG.times(end) || TimeRange(2)<=EEG.times(1)
    TimeRange = [EEG.times(1),EEG.times(end)];
end
if TimeRange(1)>=0
    msgboxText = ['The left number of the new time range should be smaller than 0'];
    title = 'ERPLAB: pop_resampleeg() inputs';
    errorfound(sprintf(msgboxText), title);
    return
end

if TimeRange(2)<=0
    msgboxText = ['The right number of the new time range should be larger than 0'];
    title = 'ERPLAB: pop_resampleeg() inputs';
    errorfound(sprintf(msgboxText), title);
    return
end


latency0_old = 1-(EEG.xmin*EEG.srate); % time 0 point
alllatencies_old = linspace( latency0_old, EEG.pnts*(EEG.trials-1)+latency0_old, EEG.trials);


%%-------------------------adjust the left edge----------------------------
if roundn(TimeRange(1),-2)>= roundn(EEG.times(1),-2)
    [xxx, latsamp, latdiffms] = closest(EEG.times, TimeRange(1));
    EEG.times = EEG.times(latsamp:end);
    EEG.xmin = EEG.times(1)/1000;
    EEG.data = EEG.data(:,latsamp:end,:);
else
    TimesNew = EEG.times;
    timeint = 1000/EEG.srate;
    count=0;
    for ii=1:10000
        timeStart = TimesNew(1)-timeint;
        if timeStart>=TimeRange(1)
            count = count+1;
            TimesNew = [timeStart,TimesNew];
        else
            break;
        end
    end
    if count~=0
        EEG.times = TimesNew;
        EEG.xmin = EEG.times(1)/1000;
        datadd= zeros(size(EEG.data,1),count);
        for ii = 1:size(EEG.data,3)
            newdata(:,:,ii)  = [datadd,squeeze(EEG.data(:,:,ii))];
        end
        EEG.data = newdata;
    end
end
%%-------------------------adjust the right edge---------------------------
if roundn(TimeRange(2),-2)<= roundn(EEG.times(end),-2)
    [xxx, latsamp, latdiffms] = closest(EEG.times, TimeRange(2));
    EEG.times = EEG.times(1:latsamp);
    EEG.xmax = EEG.times(end)/1000;
    EEG.data = EEG.data(:,1:latsamp,:);
else
    TimesNew = EEG.times;
    timeint = 1000/EEG.srate;
    count=0;
    for ii=1:10000
        timend = TimesNew(end)+timeint;
        if timend<=TimeRange(2)
            count = count+1;
            TimesNew = [TimesNew,timend];
        else
            break;
        end
    end
    if count~=0
        newdata = [];
        EEG.times = TimesNew;
        EEG.xmax = EEG.times(end)/1000;
        datadd= zeros(size(EEG.data,1),count);
        for ii = 1:size(EEG.data,3)
            newdata(:,:,ii)  = [squeeze(EEG.data(:,:,ii)),datadd];
        end
        EEG.data = newdata;
    end
end

count = 0;
check_left = [];
for ii = 1:numel(EEG.times)
    if roundn(EEG.times(ii),-2)< roundn(TimeRange(1),-2) || roundn(EEG.times(ii),-2)> roundn(TimeRange(2),-2)
        count = count+1;
        check_left(count) = ii;
    end
end
EEG.data(:,check_left,:) =[];
EEG.times(check_left) = [];
EEG.pnts = size(EEG.data,2);
EEG.xmax = EEG.times(end)/1000;
EEG.xmin = EEG.times(1)/1000;


%%Adjust events
latency0_new = 1-(EEG.xmin*EEG.srate); % time 0 point
alllatencies_new = linspace( latency0_new, EEG.pnts*(EEG.trials-1)+latency0_new, EEG.trials);
Latency_all = [];
for Numofevent = 1:length( EEG.event)
    epochindex(Numofevent,1) =  EEG.event(Numofevent).epoch;
    Latency_all(Numofevent,1) =  EEG.event(Numofevent).latency;
end
%%adjust event latency
count = 0;
eventrm = [];
for Numoftrial = 1:EEG.trials
    [xpos,ypos]= find(epochindex==Numoftrial);
    count1= 0;
    eventrm_epoch = [];
    Latency_single= Latency_all(xpos);
    Latency_single = Latency_single-alllatencies_old(Numoftrial);
    for ii = 1:numel(xpos)
        EEG.event(xpos(ii)).latency = Latency_single(ii)+alllatencies_new(Numoftrial);%%update latency for each epoch
        if  (EEG.event(xpos(ii)).latency-alllatencies_new(Numoftrial))<(1-latency0_new) ||  (EEG.event(xpos(ii)).latency-alllatencies_new(Numoftrial))>(numel(EEG.times)-latency0_new)
            count = count+1;
            eventrm(count) = xpos(ii);%%remove event exceeds the epoch
        end
    end
end
EEG.event(eventrm) = [];
EEG.urevent = [];
EEG = eeg_checkset(EEG, 'eventconsistency');
% EEG = eeg_checkset(EEG,'epochconsist');
%%resampling data based on eeglab routine
if EEG.srate~=Freq2resamp
    setnameold = EEG.setname;
    EEG = pop_resample( EEG, Freq2resamp);
    EEG.setname = setnameold;
end
EEG = eeg_checkset(EEG);

if strcmpi(p.Results.Saveas,'on')
    issaveas = 1;
else
    issaveas = 0;
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
EEG.saved  = 'no';
EEG = eeg_checkset(EEG);
%
% History
%
%
% Completion statement
%
% msg2end

%
% History
%

skipfields = {'EEG', 'Saveas','History'};
fn     = fieldnames(p.Results);
LASTCOM = sprintf( '%s = pop_resampleeg( %s ', inputname(1), inputname(1) );
for q=1:length(fn)
    fn2com = fn{q};
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com);
        if ~isempty(fn2res)
            if ischar(fn2res)
                if ~strcmpi(fn2res,'off')
                    LASTCOM = sprintf( '%s, ''%s'', ''%s''', LASTCOM, fn2com, fn2res);
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
                    fn2resstr = vect2colon(fn2res, 'Sort','on');
                    fnformat = '%s';
                end
                if strcmpi(fn2com,'Criterion')
                    if p.Results.Criterion<100
                        LASTCOM = sprintf( ['%s, ''%s'', ' fnformat], LASTCOM, fn2com, fn2resstr);
                    end
                else
                    LASTCOM = sprintf( ['%s, ''%s'', ' fnformat], LASTCOM, fn2com, fn2resstr);
                end
            end
        end
    end
end
LASTCOM = sprintf( '%s );', LASTCOM);

% Save ERPset from GUI
%
if issaveas
    [EEG, LASTCOM1] = pop_saveset(EEG,'filename', EEG.filename, 'filepath',EEG.filepath,'check','on');
    EEG = eegh(LASTCOM1, EEG);
end

% get history from script. ERP
switch shist
    case 1 % from GUI
        displayEquiComERP(LASTCOM);
    case 2 % from script
        EEG = eegh(LASTCOM, EEG);
    case 3
        % implicit
    otherwise %off or none
        LASTCOM = '';
        return
end
return