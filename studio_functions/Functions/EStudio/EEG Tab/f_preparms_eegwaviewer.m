%%this function is used to call back the parameters for plotting EEG wave

% *** This function is part of EStudio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2023 && 2024

function OutputViewerpareeg = f_preparms_eegwaviewer(EEG,matlabfig,History,figureName)

OutputViewerpareeg = '';
if nargin<1
    help f_preparms_eegwaviewer();
    return
end
if isempty(EEG)
    disp('f_preparms_eegwaviewer(): EEG is empty');
    return;
end

if nargin<3
    History = 'gui';
end

if nargin <2
    matlabfig=1;
end
if nargin <4
    figureName = '';
end

%%channel array and IC array
%channels
ChanArray = estudioworkingmemory('EEG_ChanArray');
nbchan = EEG.nbchan;
if isempty(ChanArray) || any(ChanArray(:)>nbchan) ||  any(ChanArray(:)<=0)
    ChanArray = 1:nbchan;
    estudioworkingmemory('EEG_ChanArray',ChanArray);
end

EEG_plotset = estudioworkingmemory('EEG_plotset');
ChanArray = reshape(ChanArray,1,[]);
try
    chanOrder = EEG_plotset{10};
    if chanOrder==2
        if isfield(EEG,'chanlocs') && ~isempty(EEG.chanlocs)
            chanindexnew = f_estudio_chan_frontback_left_right(EEG.chanlocs(ChanArray));
            if ~isempty(chanindexnew)
                ChanArray = ChanArray(chanindexnew);
            end
        end
    elseif chanOrder==3
        [eloc, labels, theta, radius, indices] = readlocs(EEG.chanlocs);
        chanorders =   EEG_plotset{11};
        chanorderindex = chanorders{1};
        chanorderindex1 = unique(chanorderindex,'stable');
        chanorderlabels = chanorders{2};
        [C,IA]= ismember_bc2(chanorderlabels,labels);
        Chanlanelsinst = labels(ChanArray);
        if ~any(IA==0) && numel(chanorderindex1) == length(labels)
            [C,IA1]= ismember_bc2(Chanlanelsinst,chanorderlabels);
            [C,IA2]= ismember_bc2(Chanlanelsinst,labels);
            ChanArray = IA1(IA2);
        end
    end
catch
end


%%ICs
ICArray = estudioworkingmemory('EEG_ICArray');
if isempty(EEG.icachansind)
    ICArray = [];
    estudioworkingmemory('EEG_ICArray',[]);
else
    nIC = numel(EEG.icachansind);
    if isempty(ICArray) || min(ICArray(:))>nIC || max(ICArray(:)) >  nIC ||  min(ICArray(:))<=0
        ICArray = [];
        estudioworkingmemory('EEG_ICArray',ICArray);
    end
end

%%Plot setting
EEG_plotset = estudioworkingmemory('EEG_plotset');
if isempty(EEG_plotset)
    EEGdisp = 1;
    ICdisp = 0;
    Winlength = 5;%%in second
    AmpScale = 50;
    ChanLabel = 1;
    Submean=0;
    EventOnset = 1;
    StackFlag = 0;
    NormFlag = 0;
else
    %%diaply original data?
    try
        EEGdisp = EEG_plotset{1};
    catch
        EEGdisp = 1;
    end
    if isempty(EEGdisp) || (EEGdisp~=0 && EEGdisp~=1)
        EEGdisp = 1;
    end
    
    %%display ICs?
    try
        ICdisp = EEG_plotset{2};
    catch
        ICdisp = 0;
    end
    if isempty(ICdisp) || (ICdisp~=0 && ICdisp~=1)
        ICdisp = 0;
    end
    
    %%Time range?
    try
        Winlength = EEG_plotset{3};
    catch
        Winlength = 5;
    end
    if isempty(Winlength) || numel(Winlength)~=1 || min(Winlength(:))<=0
        Winlength=5;
    end
    
    
    %%Vertical scale for original data?
    try
        AmpScale = EEG_plotset{4};
    catch
        AmpScale = 50;
    end
    if isempty(AmpScale) || numel(AmpScale)~=1 || AmpScale<=0
        AmpScale = 50;
    end
    
    %%Vertical scale for IC data?
    try
        AmpScale_ic = EEG_plotset{5};
    catch
        AmpScale_ic = 10;
    end
    if isempty(AmpScale_ic) || numel(AmpScale_ic)~=1 || AmpScale_ic<=0
        AmpScale_ic = 10;
    end
    
    %%Channel labels? (1 is name, 0 is number)
    try
        ChanLabel = EEG_plotset{5};
    catch
        ChanLabel = 1;
    end
    if isempty(ChanLabel) || numel(ChanLabel)~=1 || (ChanLabel~=0 && ChanLabel~=1)
        ChanLabel = 1;
    end
    
    %%Remove DC? (1 is "Yes", 0 is "no")
    try
        Submean = EEG_plotset{6};
    catch
        Submean = 0;
    end
    if isempty(Submean) || numel(Submean)~=1 || (Submean~=0 && Submean~=1)
        Submean = 0;
    end
    
    %%Display events?
    try
        EventOnset = EEG_plotset{7};
    catch
        EventOnset = 1;
    end
    if isempty(EventOnset) ||  numel(EventOnset)~=1 || (EventOnset~=0 && EventOnset~=1)
        EventOnset = 1;
    end
    
    
    %%Stack?
    try
        StackFlag = EEG_plotset{8};
    catch
        StackFlag = 0;
    end
    if isempty(StackFlag) || numel(StackFlag)~=1 || (StackFlag~=0&&StackFlag~=1)
        StackFlag = 0;
    end
    
    %%Norm?
    try
        NormFlag = EEG_plotset{9};
    catch
        NormFlag = 0;
    end
    if isempty(NormFlag) ||numel(NormFlag)~=1 || (NormFlag~=0 && NormFlag~=1)
        NormFlag = 0;
    end
end


%%Start time to display
Startimes = estudioworkingmemory('Startimes');
[chaNum,sampleNum,trialNum]=size(EEG.data);
Frames = sampleNum*trialNum;
if EEG.trials>1 % time in second or in trials
    multiplier = size(EEG.data,2);
else
    multiplier = EEG.srate;
end

StartimesMax = max(0,ceil((Frames-1)/multiplier)-Winlength);
if ndims(EEG.data)==3
    Startimes=Startimes-1;
end
if isempty(Startimes) || numel(Startimes)~=1 || Startimes<0 ||Startimes>StartimesMax
    Startimes=0;
    estudioworkingmemory('Startimes',Startimes);
end

figSize = estudioworkingmemory('egfigsize');
if isempty(figSize)
    figSize = [];
end
if ICdisp==0
    ICArray = [];
end
if isempty(ICArray)
    ICdisp=0;
end


if matlabfig==1
    if EEGdisp==0
        ChanArray = [];
    end
    [EEG, eegcom] = pop_ploteegset(EEG,'ChanArray',ChanArray,'ICArray',ICArray,'Winlength',Winlength,...
        'Ampchan',AmpScale,'ChanLabel',ChanLabel,'Submean',Submean,'EventOnset',EventOnset,'Ampic',AmpScale_ic,...
        'StackFlag',StackFlag,'NormFlag',NormFlag,'Startimes',Startimes,'figureName',figureName,'figSize',figSize,'History',History);
else
    OutputViewerpareeg{1} = ChanArray;
    OutputViewerpareeg{2} = ICArray;
    OutputViewerpareeg{3} =EEGdisp;
    OutputViewerpareeg{4} =ICdisp;
    OutputViewerpareeg{5} =Winlength;
    OutputViewerpareeg{6} =AmpScale;
    OutputViewerpareeg{7} =ChanLabel;
    OutputViewerpareeg{8} =Submean;
    OutputViewerpareeg{9} = EventOnset;
    OutputViewerpareeg{10} =StackFlag;
    OutputViewerpareeg{11} =NormFlag;
    OutputViewerpareeg{12} =Startimes;
    OutputViewerpareeg{13} = AmpScale_ic;
end

end