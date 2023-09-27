% PURPOSE:  pop_ploteegset.m
%           plot EEG waves
%


%%Insert usage here




% *** This function is part of ERPLAB Studio ***
% Author: Guanghui Zhang & Steven Luck
% ghzhang@ucdavis.edu, sjluck@ucdavis.edu
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% August 2023




function [EEG,eegcom] = pop_ploteegset(EEG,varargin)

eegcom = '';
if nargin < 1
    help pop_ploteegset
    return;
end

if isempty(EEG)%%
    beep;
    disp('EEG is empty');
    return;
end

if nargin==1
    %%Do we need to create a GUI that the user can use it to define the
    %%desired parameters?
    
    %%channels that will be plotted
    nbchan = EEG.nbchan;
    ChanArray = 1:nbchan;
    
    %%display ICs
    ICArray = [];
    
    %%window length for displayed EEG
    Winlength=5;
    
    %%vertical voltage
    AmpScale = 50;
    
    %%channel name (1) or number (0)
    ChanLabel = 1;
    
    %%remove DC for the displayed EEG?
    Submean = 0;
    
    %%Display events if any?
    EventOnset = 1;
    
    %%Stack on/off?
    StackFlag = 0;
    
    %%Norm on/off?
    NormFlag = 0;
    
    %%start time for displayed EEG data
    if ndims(EEG.data) ==3
        Startimes=1;
    else
        Startimes=0;
    end
    
    [ChanNum,Allsamples,tmpnb] = size(EEG.data);
    Allsamples = Allsamples*tmpnb;
    if ndims(EEG.data) > 2
        multiplier = size(EEG.data,2);
    else
        multiplier = EEG.srate;
    end
    
    if isempty(Startimes) || Startimes<0 ||  Startimes>(ceil((Allsamples-1)/multiplier)-Winlength)
        if ndims(EEG.data) ==3
            Startimes=1;
        else
            Startimes=0;
        end
    end
    
    %%figure name if any
    figureName = EEG.setname;
    
    %%Figure position
    figSize = [];
    
    [EEG, eegcom] = pop_ploteegset(EEG,'ChanArray',ChanArray,'ICArray',ICArray,'Winlength',Winlength,...
        'AmpScale',AmpScale,'ChanLabel',ChanLabel,'Submean',Submean,'EventOnset',EventOnset,...
        'StackFlag',StackFlag,'NormFlag',NormFlag,'Startimes',Startimes,'figureName',figureName,'figSize',figSize,'History', 'gui');
    pause(0.1);
    return;
end


%
% Parsing inputs
%
% colordef = getcolorcellerps; %{'k' 'r' 'b' 'g' 'c' 'm' 'y' 'w'};% default colors
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG');

%Option(s)
p.addParamValue('ChanArray',[],@isnumeric);
p.addParamValue('ICArray',[], @isnumeric);
p.addParamValue('Winlength',[], @isnumeric);
p.addParamValue('AmpScale',[], @isnumeric);
p.addParamValue('ChanLabel',[], @isnumeric);
p.addParamValue('Submean',[], @isnumeric);
p.addParamValue('EventOnset',[], @isnumeric);
p.addParamValue('StackFlag',[], @isnumeric);
p.addParamValue('NormFlag',[], @isnumeric);
p.addParamValue('Startimes',[], @isnumeric);
p.addParamValue('figureName','', @ischar);
p.addParamValue('figSize',[], @isnumeric);

p.addParamValue('ErrorMsg', '', @ischar);
p.addParamValue('History', '', @ischar); % history from scripting


p.parse(EEG,varargin{:});

p_Results = p.Results;

if strcmpi(p_Results.History,'command')
    shist = 4;%%Show  Maltab command only and donot plot the wave
elseif strcmpi(p_Results.History,'implicit')
    shist = 3; % implicit
elseif strcmpi(p_Results.History,'script')
    shist = 2; % script
elseif strcmpi(p_Results.History,'gui')
    shist = 1; % gui
else
    shist = 0; % off
end

if strcmpi(p_Results.ErrorMsg,'popup')
    errormsgtype = 1; % open popup window
else
    errormsgtype = 0; % error in red at command window
end

if isempty(EEG)%%
    beep;
    disp('EEG is empty');
    return;
end


%%channel array
qchanArray = p_Results.ChanArray;
nbchan = EEG.nbchan;
if isempty(qchanArray) ||  min(qchanArray(:))>nbchan ||  max(qchanArray(:))>nbchan  ||  min(qchanArray(:))<=0
    qchanArray = [1:nbchan];
end

%%IC array (the default is empty, that is, donot display ICs)
qICArray = p_Results.ICArray;
if isempty(EEG.icachansind)
    qICArray = [];
else
    if ~isempty(qICArray) && (min(qICArray(:))> numel(EEG.icachansind)  || max(qICArray(:))> numel(EEG.icachansind) || min(qICArray(:))<=0)
        qICArray = [];
    end
end


%%the window length
qWinlength = p_Results.Winlength;
if ~isempty(qWinlength) && numel(qWinlength)~=1
    qWinlength = qWinlength(1);
end
if isempty(qWinlength) || numel(qWinlength)~=1 || min(qWinlength(:))<=0
    qWinlength=5;
end

%%vertical amplitude scale
qAmpScale = p_Results.AmpScale;
if ~isempty(qAmpScale) && numel(qAmpScale)~=1
    qAmpScale = qAmpScale(1);
end
if isempty(qAmpScale)|| qAmpScale==0
    qAmpScale = 50;
end


%%channel with names (1) or numbers(0)
qChanLabel = p_Results.ChanLabel;
if ~isempty(qChanLabel) && numel(qChanLabel)~=1
    qChanLabel = qChanLabel(1);
end
if isempty(qChanLabel) || (qChanLabel~=0 && qChanLabel~=1)
    qChanLabel =1;
end


%%remove DCs from the displayed EEG data?
qSubmean = p_Results.Submean;
if ~isempty(qSubmean) && numel(qSubmean)~=1
    qSubmean = qSubmean(1);
end
if isempty(qSubmean) || (qSubmean~=0 && qSubmean~=1)
    qSubmean=0;
end


%%event onset or offset if any?
qEventOnset = p_Results.EventOnset;
if ~isempty(qEventOnset) && numel(qEventOnset)~=1
    qEventOnset = qEventOnset(1);
end
if isempty(qEventOnset) || (qEventOnset~=0 && qEventOnset~=1)
    qEventOnset =1;
end

%%stack on/off?
qStackFlag = p_Results.StackFlag;
if ~isempty(qStackFlag) && numel(qStackFlag)~=1
    qStackFlag = qStackFlag(1);
end
if isempty(qStackFlag) || (qStackFlag~=0 && qStackFlag~=1)
    qStackFlag =1;
end

%%normalization?
qNormFlag = p_Results.NormFlag;
if ~isempty(qNormFlag) && numel(qNormFlag)~=1
    qNormFlag = qNormFlag(1);
end
if isempty(qNormFlag) || (qNormFlag~=0 && qNormFlag~=1)
    qNormFlag =1;
end


%%start time of the displayed EEG
qStartimes = p_Results.Startimes;
if ~isempty(qStartimes) && numel(qStartimes)~=1
    qStartimes = qStartimes(1);
end
[ChanNum,Allsamples,tmpnb] = size(EEG.data);
Allsamples = Allsamples*tmpnb;
if ndims(EEG.data) > 2
    multiplier = size(EEG.data,2);
else
    multiplier = EEG.srate;
end

if isempty(qStartimes) || qStartimes<0 ||  qStartimes>(ceil((Allsamples-1)/multiplier)-qWinlength)
    if ndims(EEG.data) ==3
        qStartimes=1;
    else
        qStartimes=0;
    end
end


%%figure name
qfigureName = p_Results.figureName;
if isempty(qfigureName)
    qfigureName  =EEG.setname;
end

%%figure position
qfigSize = p_Results.figSize;
if ~isempty(qfigSize) && numel(qfigSize)~=2
    qfigSize = [];
end

%%%%%%%%%%%%%%%
% insert the function that is to plot the EEG
if ~isempty(qfigureName) && shist~=4
    f_ploteegwave(EEG,qchanArray,qICArray,qWinlength,...
        qAmpScale,qChanLabel,qSubmean,qEventOnset,qStackFlag,qNormFlag,qStartimes,...
        qfigSize,qfigureName) ;
    
end

%%history
fn = fieldnames(p.Results);
skipfields = {'EEG'};
eegcom     = sprintf( 'EEG = pop_ploteegset( %s', 'EEG');

for q=1:length(fn)
    fn2com = fn{q}; % inputname
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com); %  input value
        if ~isempty(fn2res)
            if ischar(fn2res)
                if ~strcmpi(fn2res,'off')
                    eegcom = sprintf( '%s, ''%s'', ''%s''', eegcom, fn2com, fn2res);
                end
            elseif iscell(fn2res)
                nn = length(fn2res);
                eegcom = sprintf( '%s, ''%s'', {''%s'' ', eegcom, fn2com, fn2res{1});
                for ff=2:nn
                    eegcom = sprintf( '%s, ''%s'' ', eegcom, fn2res{ff});
                end
                eegcom = sprintf( '%s}', eegcom);
            elseif isnumeric(fn2res)
                if ~ismember_bc2(fn2com,{'LineColor','GridSpace','GridposArray'})
                    eegcom = sprintf( '%s, ''%s'', %s', eegcom, fn2com, vect2colon(fn2res,'Repeat','on'));
                else
                    if size(fn2res,1)==1
                        fn2res_trans = char(num2str(fn2res));
                    else
                        fn2res_trans = char(num2str(fn2res(1,:)));
                        for ii = 2:size(fn2res,1)
                            fn2res_trans  =  char(strcat(fn2res_trans,';',num2str(fn2res(ii,:))));
                        end
                    end
                    fn2res = fn2res_trans;
                    eegcom = sprintf( '%s, ''%s'', [%s', eegcom,fn2com,fn2res);
                    eegcom = sprintf( '%s]', eegcom);
                end
                
            else
                %                 if ~ismember_bc2(fn2com,{'xscale','yscale'})
                %                     eegcom = sprintf( '%s, ''%s'', %s', eegcom, fn2com, vect2colon(fn2res,'Repeat','on'));
                %                 else
                %                     xyscalestr = sprintf('[ %.1f %.1f  %s ]', fn2res(1), fn2res(2), vect2colon(fn2res(3:end),'Delimiter','off'));
                %                     eegcom = sprintf( '%s, ''%s'', %s', eegcom, fn2com, xyscalestr);
                %                 end
            end
        end
    end
end


eegcom = sprintf( '%s );', eegcom);
% get history from script. ERP
% shist = 1;
switch shist
    case 1 % from GUI
        displayEquiComERP(eegcom);
    case 2 % from script
        for i=1:length(EEG)
            ALLERP(i) = erphistory(ALLERP(i), [], eegcom, 1);
        end
    case 3
        % implicit
    case 4
        displayEquiComERP(eegcom);
        
    otherwise %off or none
        eegcom = '';
        return
end



return;