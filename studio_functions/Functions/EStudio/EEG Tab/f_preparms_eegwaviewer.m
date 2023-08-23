%%this function is used to call back the parameters for plotting EEG wave

% *** This function is part of EStudio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% August 2023

function OutputViewerpareeg = f_preparms_eegwaviewer(EEG,FigureName)


OutputViewerpareeg = '';
if nargin<1
    help f_preparms_eegwaviewer();
    return
end
if nargin<2
    FigureName = '';
end
if isempty(EEG)
    disp('f_preparms_eegwaviewer(): EEG is empty');
    return;
end



%%channel array and IC array
%channels
ChanArray = estudioworkingmemory('EEG_ChanArray');
nbchan = EEG.nbchan;
if isempty(ChanArray) || min(ChanArray(:)) >nbchan || max(ChanArray(:))> nbchan||  min(ChanArray(:))<=0
    ChanArray = 1:nbchan;
    estudioworkingmemory('EEG_ChanArray',ChanArray);
end

%%ICs
ICArray = estudioworkingmemory('EEG_ICArray');
if isempty(EEG.icachansind)
    ICArray = [];
    estudioworkingmemory('EEG_ICArray',[]);
else
    nIC = numel(EEG.icachansind);
    if isempty(ICArray) || min(ICArray(:))>nIC || max(ICArray(:)) >  nIC ||  min(ICArray(:))<=0
        ICArray = 1:nIC;
        estudioworkingmemory('EEG_ICArray',ICArray);
    end
end



%%Plot setting
EEG_plotset = estudioworkingmemory('EEG_plotset');
if isempty(EEG_plotset)
    EEGdisp = 1;
    ICdisp = 0;
    TimeRange = 5;%%in second
    ScaleV = 50;
    channeLabel = 1;
    RemoveDC=0;
    EventFlag = 1;
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
        TimeRange = EEG_plotset{3};
    catch
        TimeRange = 5;
    end
    if isempty(TimeRange) || numel(TimeRange)~=1 || min(TimeRange(:))<=0
        TimeRange=5;
    end
    
    
    %%Vertical scale?
    try
        ScaleV = EEG_plotset{4};
    catch
        ScaleV = 50;
    end
    if isempty(ScaleV) || numel(ScaleV)~=1 || ScaleV==0
        ScaleV = 50;
    end
    
    %%Channel labels? (1 is name, 0 is number)
    try
        channeLabel = EEG_plotset{5};
    catch
        channeLabel = 1;
    end
    if isempty(channeLabel) || numel(channeLabel)~=1 || (channeLabel~=0 && channeLabel~=1)
        channeLabel = 1;
    end
    
    %%Remove DC? (1 is "Yes", 0 is "no")
    try
        RemoveDC = EEG_plotset{6};
    catch
        RemoveDC = 0;
    end
    if isempty(RemoveDC) || numel(RemoveDC)~=1 || (RemoveDC~=0 && RemoveDC~=1)
        RemoveDC = 0;
    end
    
    %%Display events?
    try
        EventFlag = EEG_plotset{7};
    catch
        EventFlag = 1;
    end
    if isempty(EventFlag) ||  numel(EventFlag)~=1 || (EventFlag~=0 && EventFlag~=1)
        EventFlag = 1;
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
EEG_startime = estudioworkingmemory('EEG_startime');
if isempty(EEG_startime) || numel(EEG_startime)~=1 || EEG_startime<0 ||EEG_startime>EEG.xmax
    EEG_startime=0;
    estudioworkingmemory('EEG_startime',EEG_startime);
end



if ~isempty(FigureName)
    
    
else
    OutputViewerpareeg{1} = ChanArray;
    OutputViewerpareeg{2} = ICArray;
    OutputViewerpareeg{3} =EEGdisp;
    OutputViewerpareeg{4} =ICdisp;
    OutputViewerpareeg{5} =TimeRange;
    OutputViewerpareeg{6} =ScaleV;
    OutputViewerpareeg{7} =channeLabel;
    OutputViewerpareeg{8} =RemoveDC;
    OutputViewerpareeg{9} = EventFlag;
    OutputViewerpareeg{10} =StackFlag;
    OutputViewerpareeg{11} =NormFlag;
    OutputViewerpareeg{12} =EEG_startime;
    %  OutputViewerpareeg{12} =
    %  OutputViewerpareeg{12} =
    %  OutputViewerpareeg{12} =
    %  OutputViewerpareeg{12} =
    %  OutputViewerpareeg{12} =
    %  OutputViewerpareeg{12} =
    %  OutputViewerpareeg{12} =
    %  OutputViewerpareeg{12} =
    %  OutputViewerpareeg{12} =
    
    
end

end