% PURPOSE:  pop_resamplerp.m
%           resample ERPsets
%

% FORMAT:
% [ERP, erpcom] = pop_resamplerp( ERP, 'Freq2resamp',Freq2resamp, 'TimeRange',TimeRange,...
%         'Saveas', 'off', 'History', 'gui');

% Inputs:
%
%ERP           -ERP structure
%Freq2resamp   -new sampling rate e.g., 200 Hz
%TimeRange     -new time range e.g., [-300 900]ms



% *** This function is part of ERPLAB Studio ***
% Author: Guanghui Zhang & Steven Luck
% ghzhang@ucdavis.edu, sjluck@ucdavis.edu
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Dec. 2023

function [ERP, erpcom] = pop_resamplerp(ERP, varargin)
erpcom = '';

if nargin < 1
    help pop_resamplerp
    return
end
if isempty(ERP)
    msgboxText =  'Cannot resample an empty erpset';
    title = 'ERPLAB: pop_resamplerp() error';
    errorfound(msgboxText, title);
    return
end
if isempty(ERP(1).bindata)
    msgboxText =  'Cannot resample an empty erpset';
    title = 'ERPLAB: pop_resamplerp() error';
    errorfound(msgboxText, title);
    return
end

datatype = checkdatatype(ERP(1));
if ~strcmpi(datatype, 'ERP')
    msgboxText =  'Cannot resample Power Spectrum waveforms!';
    title = 'ERPLAB: pop_resamplerp() error';
    errorfound(msgboxText, title);
    return
end

if nargin==1
    
    Freq2resamp = ERP.srate;
    TimeRange = [ERP.times(1),ERP.times(end)];
    %
    % Somersault
    %
    [ERP, erpcom] = pop_resamplerp( ERP, 'Freq2resamp',Freq2resamp, 'TimeRange',TimeRange,...
        'Saveas', 'off', 'History', 'gui');
    return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ERP');
% option(s)
p.addParamValue('Freq2resamp', [],@isnumeric);
p.addParamValue('TimeRange', [], @isnumeric);
p.addParamValue('Saveas', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ERP, varargin{:});

Freq2resamp = p.Results.Freq2resamp;
if isempty(Freq2resamp) || numel(Freq2resamp)~=1 || any(Freq2resamp<=0)
    Freq2resamp = ERP.srate;
end

TimeRange= p.Results.TimeRange;
TimeRange = unique(TimeRange);
if isempty(TimeRange) || numel(TimeRange)~=2 || TimeRange(1)>=ERP.times(end) || TimeRange(2)<=ERP.times(1)
    TimeRange = [ERP.times(1),ERP.times(end)];
end

%%-------------------------adjust the left edge----------------------------
if TimeRange(1)>= ERP.times(1)
    [xxx, latsamp, latdiffms] = closest(ERP.times, TimeRange(1));
    ERP.times = ERP.times(latsamp:end);
    ERP.xmin = ERP.times(1)/1000;
    ERP.bindata = ERP.bindata(:,latsamp:end,:);
else
    TimesNew = ERP.times;
    timeint = 1000/ERP.srate;
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
        ERP.times = TimesNew;
        ERP.xmin = ERP.times(1)/1000;
        datadd= zeros(size(ERP.bindata,1),count);
        for ii = 1:size(ERP.bindata,3)
            newdata(:,:,ii)  = [datadd,squeeze(ERP.bindata(:,:,ii))];
        end
        ERP.bindata = newdata;
    end
end
%%-------------------------adjust the right edge---------------------------
if TimeRange(2)<= ERP.times(end)
    [xxx, latsamp, latdiffms] = closest(ERP.times, TimeRange(2));
    ERP.times = ERP.times(1:latsamp);
    ERP.xmax = ERP.times(end)/1000;
    ERP.bindata = ERP.bindata(:,1:latsamp,:);
else
    TimesNew = ERP.times;
    timeint = 1000/ERP.srate;
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
        ERP.times = TimesNew;
        ERP.xmax = ERP.times(end)/1000;
        datadd= zeros(size(ERP.bindata,1),count);
        for ii = 1:size(ERP.bindata,3)
            newdata(:,:,ii)  = [squeeze(ERP.bindata(:,:,ii)),datadd];
        end
        
        ERP.bindata = newdata;
    end
end

count = 0;
check_left = [];
for ii = 1:numel(ERP.times)
    if ERP.times(ii)< TimeRange(1) || ERP.times(ii)> TimeRange(2)
        count = count+1;
        check_left(count) = ii;
    end
end
ERP.bindata(:,check_left,:) =[];
ERP.times(check_left) = [];
ERP.pnts = size(ERP.bindata,2);
ERP.xmax = ERP.times(end)/1000;
ERP.xmin = ERP.times(1)/1000;


EEG = eeg_emptyset();
EEG.nbchan = ERP.nchan;
EEG.pnts = ERP.pnts;
EEG.trials = size(ERP.bindata,3);
EEG.srate = ERP.srate;
EEG.xmin = ERP.xmin;
EEG.xmax = ERP.xmax;
EEG.data = ERP.bindata;
EEG.times = ERP.times;
%%resampling data based on eeglab routine
EEG = pop_resample( EEG, Freq2resamp);

ERP.srate= EEG.srate;
ERP.xmin= EEG.xmin;
ERP.xmax = EEG.xmax;
ERP.bindata = EEG.data;
ERP.times = EEG.times;
ERP.pnts= EEG.pnts;
ERP.EVENTLIST.eventinfo = [];
ERP.binerror = [];

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



ERP.saved  = 'no';
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

skipfields = {'ERP', 'Saveas','History'};
fn     = fieldnames(p.Results);
erpcom = sprintf( '%s = pop_resamplerp( %s ', inputname(1), inputname(1) );
for q=1:length(fn)
    fn2com = fn{q};
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com);
        if ~isempty(fn2res)
            if ischar(fn2res)
                if ~strcmpi(fn2res,'off')
                    erpcom = sprintf( '%s, ''%s'', ''%s''', erpcom, fn2com, fn2res);
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
                        erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
                    end
                else
                    erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
                end
            end
        end
    end
end
erpcom = sprintf( '%s );', erpcom);

%
% Save ERPset from GUI
%
if issaveas
    [ERP, issave, erpcom_save] = pop_savemyerp(ERP,'gui','erplab', 'History', 'off');
    if issave>0
        %                 erpcom = sprintf( '%s = pop_filterp( %s, %s, %s, %s, %s, ''%s'', %s);', inputname(1), inputname(1),...
        %                         chanArraystr, num2str(locutoff), num2str(hicutoff),...
        %                         num2str(filterorder), lower(fdesign), num2str(remove_dc));
        %                 erpcom = sprintf('%s\n%s', erpcom, erpcom_save);
        if issave==2
            erpcom = sprintf('%s\n%s', erpcom, erpcom_save);
            msgwrng = '*** Your ERPset was saved on your hard drive.***';
            %mcolor = [0 0 1];
        else
            msgwrng = '*** Warning: Your ERPset was only saved on the workspace.***';
            %mcolor = [1 0.52 0.2];
        end
    else
        ERP = ERPaux;
        msgwrng = 'ERPLAB Warning: Your changes were not saved';
        %mcolor = [1 0.22 0.2];
    end
    try cprintf([1 0.52 0.2], '%s\n\n', msgwrng); catch,fprintf('%s\n\n', msgwrng);end ;
end
% get history from script. ERP
switch shist
    case 1 % from GUI
        displayEquiComERP(erpcom);
    case 2 % from script
        ERP = erphistory(ERP, [], erpcom, 1);
    case 3
        % implicit
    otherwise %off or none
        erpcom = '';
        return
end
return