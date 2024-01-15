%%this function is used to call back the parameters for plotting ERP wave

% *** This function is part of EStudio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Oct 2023


function OutputViewerparerp = f_preparms_erptab(ERP,matlabfig,History,FigureName)

OutputViewerparerp = '';
if nargin<1
    help f_preparms_erptab();
    return
end
if isempty(ERP)
    disp('f_preparms_erptab(): ERP is empty');
    return;
end

if nargin<3
    History = 'gui';
end

if nargin <2
    matlabfig=1;
end
if nargin <4
    FigureName = '';
end

%%channel array and bin array
%
%%channels
ChanArray=estudioworkingmemory('ERP_ChanArray');
nbchan = ERP.nchan;
if isempty(ChanArray) || any(ChanArray(:)>nbchan) ||  any(ChanArray(:)<=0)
    ChanArray = 1:nbchan;
    estudioworkingmemory('ERP_ChanArray',ChanArray);
end

ERP_chanorders = estudioworkingmemory('ERP_chanorders');
ChanArray = reshape(ChanArray,1,[]);
chanOrder = ERP_chanorders{1};
if isempty(chanOrder) || any(chanOrder<=0) || numel(chanOrder)~=1 || (chanOrder~=1 && chanOrder~=2 && chanOrder~=3)
    chanOrder=1;
end
try
    if chanOrder==2
        if isfield(ERP,'chanlocs') && ~isempty(ERP.chanlocs)
            chanindexnew = f_estudio_chan_frontback_left_right(ERP.chanlocs(ChanArray));
            if ~isempty(chanindexnew)
                ChanArray = ChanArray(chanindexnew);
            end
        end
    elseif chanOrder==3
        [eloc, labels, theta, radius, indices] = readlocs(ERP.chanlocs);
        chanorders =   ERP_chanorders{2};
        chanorderindex = chanorders{1};
        chanorderindex1 = unique(chanorderindex);
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

%
%%bins
BinArray=estudioworkingmemory('ERP_BinArray');
if isempty(BinArray) || any(BinArray(:)>ERP.nbin) || any(BinArray(:)<=0)
    BinArray  = [1:ERP.nbin];
    estudioworkingmemory('ERP_BinArray',BinArray);
end


%
%%Plot setting
ERPTab_plotset_pars = estudioworkingmemory('ERPTab_plotset_pars');

%
%%time range
timeStartdef = ERP.times(1);
timEnddef = ERP.times(end);
[def xstepdef]= default_time_ticks_studio(ERP, [ERP.times(1),ERP.times(end)]);

try timerange = ERPTab_plotset_pars{1}; catch timerange =[timeStartdef,timEnddef]; end
try
    timeStart = timerange(1);
catch
    timeStart = timeStartdef;
end
if isempty(timeStart) || numel(timeStart)~=1 || any(timeStart>timEnddef)
    timeStart = timeStartdef;
end

try
    timEnd = timerange(2);
catch
    timEnd = timEnddef;
end
if isempty(timEnd) || numel(timEnd)~=1 || any(timEnd<timeStart)
    timEnd = timEnddef;
end

if timeStart> timEnd
    timEnd = timEnddef;
    timeStart = timeStartdef;
end

try xtickstep = ERPTab_plotset_pars{2}; catch xtickstep = xstepdef; end
if isempty(xtickstep) || numel(xtickstep)~=1 || any(xtickstep<=0) || xtickstep > (timEnd-timeStart)
    xtickstep = xstepdef;
end

%%y scale
try PolarityValue=ERPTab_plotset_pars{7};catch PolarityValue=1; end
if isempty(PolarityValue) || numel(PolarityValue)~=1 || (PolarityValue~=1&&PolarityValue~=0)
    PolarityValue=1;
end
if PolarityValue==1
    positive_up = 1;
    PolarityWave=1;
else
    positive_up = -1;
    PolarityWave=0;
end

YScaledef =prctile(ERP.bindata(:)*positive_up,95)*2/3;
if YScaledef>= 0&&YScaledef <=0.1
    YScaledef = 0.1;
elseif YScaledef< 0&& YScaledef > -0.1
    YScaledef = 0.1;
else
    YScaledef = round(YScaledef);
end
try YtickInterval = ERPTab_plotset_pars{3};catch YtickInterval= YScaledef; end
if isempty(YtickInterval) || numel(YtickInterval)~=1 || any(YtickInterval<0.1)
    YtickInterval= YScaledef;
end

try YtickSpace  =ERPTab_plotset_pars{4};catch YtickSpace=1.5; end
if isempty(YtickSpace) || numel(YtickSpace)~=1 || any(YtickSpace<=0)
    YtickSpace=1.5;
end

try Fillscreen = ERPTab_plotset_pars{5};catch Fillscreen=1; end
if isempty(Fillscreen) || numel(Fillscreen)~=1 || (Fillscreen~=0 && Fillscreen~=1)
    Fillscreen=1;
end

try columNum =ERPTab_plotset_pars{6}; catch columNum=1; end

if isempty(columNum) || numel(columNum)~=1 || any(columNum<=0)
    columNum=1;
end


try Binchan_Overlay = ERPTab_plotset_pars{8}; catch Binchan_Overlay=0; end
if isempty(Binchan_Overlay) || numel(Binchan_Overlay)~=1 || (Binchan_Overlay~=0 && Binchan_Overlay~=1)
    Binchan_Overlay=0;
end

if Binchan_Overlay==0
    rowNumdef = numel(ChanArray);
    plotArray = ChanArray;
    [~, labelsdef, ~, ~, ~] = readlocs(ERP.chanlocs(ChanArray));
    PLOTORG = [1 2 3];
    nplot = numel(BinArray);
    LegendName = ERP.bindescr(BinArray);
    
else
    rowNumdef = numel(BinArray);
    plotArray = BinArray;
    labelsdef =ERP.bindescr(BinArray);
    PLOTORG = [2 1 3];
    nplot = numel(ChanArray);
    [~, chanlabels, ~, ~, ~] = readlocs(ERP.chanlocs(ChanArray));
    LegendName = chanlabels(ChanArray);
end
try rowNum = ERPTab_plotset_pars{9};catch rowNum=rowNumdef; end


try layoutDef = ERPTab_plotset_pars{10};catch layoutDef=1;end
% if layoutDef==1
%     rowNum=rowNumdef;
% end
plotBox = [rowNum,columNum];


GridposArraydef = zeros(rowNum,columNum);
count = 0;
for Numofrow = 1:rowNum
    for Numofcolumn = 1:columNum
        count = count +1;
        if count<= numel(plotArray)
            GridposArraydef(Numofrow,Numofcolumn)=  plotArray(count);
        else
            break;
        end
    end
end
GridposArray =zeros(rowNum,columNum);
try DataDf = ERPTab_plotset_pars{11};catch DataDf = [];end
if layoutDef==1
    GridposArray = GridposArraydef;
else
    if isempty(DataDf) || size(DataDf,1)~=rowNum || size(DataDf,2)~=columNum
        GridposArray = GridposArraydef;
    else
        
        for Numofrow = 1:rowNum
            for Numofcolumn = 1:columNum
                SingleStr =  char(DataDf{Numofrow,Numofcolumn});%%find the index for each cell
                if ~isempty(SingleStr)
                    [C,IA] = ismember_bc2(SingleStr,labelsdef);
                    if C==1
                        try GridposArray(Numofrow,Numofcolumn)=  plotArray(IA);catch GridposArray(Numofrow,Numofcolumn)= 0; end
                    end
                end
            end
        end
    end
end


figSize = estudioworkingmemory('egfigsize');
if isempty(figSize)
    figSize = [];
end



LineColorspec = get_colors(nplot);
LineWidthspec= ones(nplot,1);
for ii = 1:nplot
    LineMarkerspec{ii} = 'none';
    LineStylespec{ii} = '-';
end

FonsizeDefault = f_get_default_fontsize();
FontSizeLeg = FonsizeDefault;
CBEFontsize = FonsizeDefault;
LabelsName = labelsdef;
Standerr = 0;
Transparency = 0;
Gridspace = [1 20;1 20];
timeRange = [timeStart,timEnd];
[timeticksdef stepX]= default_time_ticks_studio(ERP, timeRange);
timeticksdef = str2num(char(timeticksdef));
qtimeRangdef = round(timeRange/100)*100;
qXticks = xtickstep+qtimeRangdef(1);
for ii=1:1000
    xtickcheck = qXticks(end)+xtickstep;
    if xtickcheck>qtimeRangdef(2)
        break;
    else
        qXticks(numel(qXticks)+1) =xtickcheck;
    end
end
if isempty(qXticks)|| stepX==xtickstep
    qXticks =  timeticksdef;
end
timeticks = qXticks;
xticklabel = 'on';
xlabelFontsize = FonsizeDefault;
xlabelFontcolor = [0 0 0];
Xunits = 'off';
MinorticksX = [0];
Yscales = [-YtickInterval YtickInterval];
Yticks = [-YtickInterval,0,YtickInterval];
yticklabel = 'on';
yunits = 'off';
MinorticksY = 0;
YlabelFontsize = FonsizeDefault;
ylabelFontcolor = [0 0 0];
TextcolorLeg = 1;
CBELabels = [50 100 1];
Legcolumns = ceil(sqrt(length(LegendName)));
CBETcolor = [0 0 0];
XdispFlag = 1;

new_pos = erpworkingmemory('EStudioScreenPos');
if isempty(new_pos) || numel(new_pos)~=2
    new_pos = [75,75];
    erpworkingmemory('EStudioScreenPos',new_pos);
end
try
    ScreenPos =  get( groot, 'Screensize' );
catch
    ScreenPos =  get( 0, 'Screensize' );
end

FigOutpos = [ScreenPos(3)*new_pos(1)/100,ScreenPos(4)*new_pos(2)/100]*8/9;
if isempty(FigureName)
FigureName = ERP.erpname;
end

if matlabfig==1
    [ERP, erpcom] = pop_plotERPwaviewer(ERP,1,1, BinArray, ChanArray,...
        'PLOTORG',PLOTORG,'GridposArray',GridposArray,'LabelsName',LabelsName, 'Blc', 'none','Box',plotBox,'LineColor',LineColorspec,'LineStyle',LineStylespec,...
        'LineMarker',LineMarkerspec,'LineWidth',LineWidthspec,'LegendName',LegendName,'LegendFontsize',FontSizeLeg,...
        'Labeloc',CBELabels,'Labelfontsize',CBEFontsize,'YDir',PolarityWave,'SEM',Standerr,'Transparency', Transparency,...
        'GridSpace',Gridspace,'TimeRange',timeRange,'Xticks',timeticks,'Xticklabel',xticklabel,'Xlabelfontsize',xlabelFontsize,...
        'Xlabelcolor',xlabelFontcolor,'Xunits',Xunits,'MinorTicksX',MinorticksX,...
        'YScales',Yscales,'Yticks',Yticks,'Yticklabel',yticklabel,'Ylabelfontsize',YlabelFontsize,...
        'Ylabelcolor',ylabelFontcolor,'Yunits',yunits,'MinorTicksY',MinorticksY,'LegtextColor',TextcolorLeg,'Legcolumns',Legcolumns,...
        'FigureName',FigureName,'FigbgColor',[1 1 1],'Labelcolor',CBETcolor,'Ytickdecimal',1,'Xtickdecimal',0,'XtickdisFlag',XdispFlag,...
        'FigOutpos',FigOutpos,'History', History);%
else
    OutputViewerparerp{1} = ChanArray;
    OutputViewerparerp{2} = BinArray;
    OutputViewerparerp{3} =timeStart;
    OutputViewerparerp{4} =timEnd;
    OutputViewerparerp{5} =xtickstep;
    OutputViewerparerp{6} =YtickInterval;
    OutputViewerparerp{7} =YtickSpace;
    OutputViewerparerp{8} =Fillscreen;
    OutputViewerparerp{9} = columNum;
    OutputViewerparerp{10} =positive_up;
    OutputViewerparerp{11} =Binchan_Overlay;
    OutputViewerparerp{12} = rowNum;
    OutputViewerparerp{13} = GridposArray;
end


    function colors = get_colors(ncolors)
        % Each color gets 1 point divided into up to 2 of 3 groups (RGB).
        degree_step = 6/ncolors;
        angles = (0:ncolors-1)*degree_step;
        colors = nan(numel(angles),3);
        for i = 1:numel(angles)
            if angles(i) < 1
                colors(i,:) = [1 (angles(i)-floor(angles(i))) 0]*0.75;
            elseif angles(i) < 2
                colors(i,:) = [(1-(angles(i)-floor(angles(i)))) 1 0]*0.75;
            elseif angles(i) < 3
                colors(i,:) = [0 1 (angles(i)-floor(angles(i)))]*0.75;
            elseif angles(i) < 4
                colors(i,:) = [0 (1-(angles(i)-floor(angles(i)))) 1]*0.75;
            elseif angles(i) < 5
                colors(i,:) = [(angles(i)-floor(angles(i))) 0 1]*0.75;
            else
                colors(i,:) = [1 0 (1-(angles(i)-floor(angles(i))))]*0.75;
            end
        end
    end
end
