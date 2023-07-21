% PURPOSE:  subroutine for pop_plotERPwaveiwer.m
%           plot ERP waveforms
%

% FORMAT:
%

% f_ploterpserpviewer(ALLERP,qCURRENTPLOT, qPLOTORG,qbinArray,qchanArray,qGridposArray,plotBox,qBlc,qLineColorspec,qLineStylespec,qLineMarkerspec,qLineWidthspec,...
%     qLegendName,qLegendFont,qLegendFontsize,qCBELabels,qLabelfont,qLabelfontsize,qPolarityWave,qSEM,qTransparency,qGridspace,qtimeRange,qXticks,qXticklabel,...
%     qXlabelfont,qXlabelfontsize,qXlabelcolor,qMinorTicksX,qXunits,qYScales,qYticks,qYticklabel,qYlabelfont,qYlabelfontsize,qYlabelcolor,qYunits,qMinorTicksY,...
%     qplotArrayStr,qERPArray,qlegcolor,qlegcolumns,qFigureName,qFigbgColor,qLabelcolor)

% Inputs:
%
%ALLERP           -ALLERPset
%qCURRENTPLOT     -index of current ERPset/bin/channel(e.g., 1)
%qPLOTORG         -plot organization including three elements (the default is [1 2 3])
%                 First element is for Grid (1 is channel; 2 is bin; 3 is ERPset)
%                 Second element is for Overlay (1 is channel; 2 is bin; 3 is ERPset)
%                 Third element is for Page (1 is channel; 2 is bin; 3 is ERPset)
%qbinArray        -index(es) of bin(s) to plot  ( 1 2 3 ...)
%qchanArray       -index(es) of channel(s) to plot ( 5 10 11 ...)
%qGridposArray    -location and correponding index of each subplot. E.g.,
%                  plot three channels with 2 x 2, the default qGridposArray is
%                  [5,10;11,0].The each element of GridposArray is the
%                  index of selected Channel/bin/ERPset.
%plotBox          -ditribution of plotting boxes in rows x columns.
%qBlc             -string or numeric interval for baseline correction
%                 reference window: 'no','pre','post','all', or [-100 0]
%qLineColorspec   -line color with RGB,e.g., [0 0 0;1 0 0]
%qLineStylespec   -line style e.g., {'-','-'}
%qLineMarkerspec  -line marker e.g., {'o','*','none'}
%qLineWidthspec   -line width e.g., [1 1 1]
%qLegendName      -legend name e.g., {'Rare','Frequent'}
%qLegendFont      -font for legend name e.g., 'Courier' or 'Times'
%qLegendFontsize  -fontsize for legend name (one value) e.g., 12 or 16
%qCBELabels       -location for channel/bin/erpset label including three
%                  elements e.g., [100 100 1]; first and second represent
%                  the percentage of time range or y scales; the last
%                  element determine whether display the label (1 or 0)
%qLabelfont       -label font
%qLabelfontsize   -label fontsize
%qPolarityWave    -"Y" axis is inverted (-UP)?:  'yes', 'no'. 1 is positive up and 0
%                  is negative up
%'SEM'              - plot standard error of the mean (if available). 0 is
%                  off and other is on.
%qTransparency     -
%qGridspace        -Setting Grid space between rows or columns
%qtimeRange        -time window is used to display the wave e.g., [-200 800]
%qXticks           - ticks for x axes e.g., [-200 0 200 400 600 800]
%qXticklabel       -display xticklabels? 1 is on and 0 is off.
%qXlabelfont       -font for xtick and xticklabel e.g., 'Courier'
%qXlabelfontsize   -fontsize for xticklabel e.g., 12
%qXlabelcolor      -color (RGB) for xticklabels e.g., [0 0 0]
%qMinorTicksX      -
%qXunits           -display units for x axes. "on" or "off"
%qYScales          - y scales e.g., [-6 10]
%qYticks           - y ticks e.g., [-6 -3 0 5 10]
%qYticklabel       -display yticklabels? 1 is on and 0 is off.
%qYlabelfont       -font for yticklabels e.g., 'Courier'
%qYlabelfontsize   -fontsize for yticklabels
%qYlabelcolor      -color (RGB) for yticks and yticklabels e.g., [0 0 0]
%qYunits           -display units for x axes. "on" or "off"
%qMinorTicksY      -
%qplotArrayStr     -names for plotting bins/channels/erpsets e.g., {'FCz','FC1','FC2'}
%qERPArray         -index(es) of the selected erpsets from ALLERP e.g., [1 2 3]
%qlegcolor         - legand text color. 1: using black color; 0 same as the
%                    line colors
%qlegcolumns       -Number of columns for legend names. e.g., 1 or 2,....
%qFigbgColor       -Background color of figure. The default is [1 1 1]
%qLabelcolor       -Channel/Bin/ERPset label color in RGB, e.g., [0 0 0]
%qYtickdecimal     -determine the number of  decimals of y tick labels
%                  - e.g., -6.0 -3.0 0.0 3.0 6.0 if qYtickdecimal is 1
%qXtickdecimal     -determine the nunmber of decimals of x tick labels
%                  -e.g., -0.2 0.0 0.2 0.4 0.6 0.8 if qXtickdecimal is 1
%qXdisFlag         -the way is to display xticks: 1 is in millisecond, 0 is in second
%qFigOutpos        - The width and height for the figure. The default one is
%                   the same to the monitor.


% *** This function is part of EStudio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022 & 2023


function f_ploterpserpviewer(ALLERP,qCURRENTPLOT, qPLOTORG,qbinArray,qchanArray,qGridposArray,plotBox,qBlc,qLineColorspec,qLineStylespec,qLineMarkerspec,qLineWidthspec,...
    qLegendName,qLegendFont,qLegendFontsize,qCBELabels,qLabelfont,qLabelfontsize,qPolarityWave,qSEM,qTransparency,qGridspace,qtimeRange,qXticks,qXticklabel,...
    qXlabelfont,qXlabelfontsize,qXlabelcolor,qMinorTicksX,qXunits,qYScales,qYticks,qYticklabel,qYlabelfont,qYlabelfontsize,qYlabelcolor,qYunits,qMinorTicksY,...
    qplotArrayStr,qERPArray,qlegcolor,qlegcolumns,qFigureName,qFigbgColor,qLabelcolor,qYtickdecimal,qXtickdecimal,qXdisFlag,qFigOutpos)

if nargin<1
    help f_ploterpserpviewer;
    return
end

if isempty(ALLERP)
    msgboxText =  'No ALLERP was found!';
    title_msg  = 'EStudio: f_ploterpserpviewer() error:';
    errorfound(msgboxText, title_msg);
    return;
end


if nargin<40 || isempty(qERPArray)
    qERPArray = [1:length(ALLERP)];
end

if max(qERPArray)>length(ALLERP)
    qERPArray=length(ALLERP);
end

[chanStrdef,binStrdef] = f_geterpschanbin(ALLERP,[1:length(ALLERP)]);

if nargin<5
    qchanArray = 1:length(chanStrdef);
end
Existchan = f_existvector([1:length(chanStrdef)],qchanArray);
if  Existchan==1
    qchanArray = [1:length(chanStrdef)];
    Existchan =1;
end


if nargin<4
    qbinArray = 1:length(binStrdef);
end
Existbin = f_existvector([1:length(binStrdef)],qbinArray);
if Existbin==1
    qbinArray = 1:length(binStrdef);
    Existbin = 1;
end

if nargin<3
    qPLOTORG = [1 2 3];%%Channel is "Grid"; Bin is "Overlay"; ERPst is page
end
%%check ALLERP and adjust "qPLOTORG"
for Numofselectederp = 1:numel(qERPArray)
    SrateNum_mp(Numofselectederp,1)   =  ALLERP(qERPArray(Numofselectederp)).srate;
    Datype{Numofselectederp} =   ALLERP(qERPArray(Numofselectederp)).datatype;
end
if (qPLOTORG(1)==1 && qPLOTORG(2)==2) || (qPLOTORG(1)==2 && qPLOTORG(2)==1)
    
else
    if length(unique(Datype))~=1
        msgboxText =  'Type of data across ERPsets is different!';
        title_msg  = 'EStudio: f_ploterpserpviewer() error:';
        errorfound(msgboxText, title_msg);
        return;
    end
    if length(unique(SrateNum_mp))~=1
        msgboxText =  'Sampling rate varies across ERPsets!';
        title_msg  = 'EStudio: f_ploterpserpviewer() error:';
        errorfound(msgboxText, title_msg);
        return;
    end
end

if  nargin<2|| isempty(qCURRENTPLOT)
    qCURRENTPLOT = 1;
end
if  ~isnumeric(qCURRENTPLOT)
    msgboxText =  'qCURRENTPLOT must be a numeric!';
    title_msg  = 'EStudio: f_ploterpserpviewer() error:';
    errorfound(msgboxText, title_msg);
    return;
end
if  qCURRENTPLOT <=0
    msgboxText =  'qCURRENTPLOT must be a positive numeric!';
    title_msg  = 'EStudio: f_ploterpserpviewer() error:';
    errorfound(msgboxText, title_msg);
    return;
end

if qPLOTORG(1) ==1
    plotArray = qchanArray;
elseif qPLOTORG(1) ==2
    plotArray =   qbinArray;
elseif qPLOTORG(1) ==3
    plotArray =   qERPArray;
else
    plotArray = qchanArray;
end
plotBoxdef = f_getrow_columnautowaveplot(plotArray);
if isempty(qPLOTORG) || numel(qPLOTORG)~=3 ||  numel(unique(qPLOTORG)) ~=3 || min(qPLOTORG)<0 || max(qPLOTORG)>3
    qPLOTORG = [1 2 3];
end

if qPLOTORG(2) ==1 %% if  the selected Channel is "Grid"
    OverlayArraydef = qchanArray;
    for Numofchan = 1:numel(qchanArray)
        LegendNamedef{Numofchan,1} =char(chanStrdef(qchanArray(Numofchan)));
    end
elseif qPLOTORG(2) == 2 %% if the selected Bin is "Grid"
    OverlayArraydef = qbinArray;
    for Numofbin = 1:numel(qbinArray)
        LegendNamedef{Numofbin,1} = char(binStrdef(qbinArray(Numofbin)));
    end
elseif qPLOTORG(2) == 3%% if the selected ERPset is "Grid"
    OverlayArraydef = qERPArray;
    for Numoferpset = 1:numel(qERPArray)
        try
            LegendNamedef{Numoferpset} = ALLERPIN(qERPArray(Numoferpset)).erpname;
        catch
            LegendNamedef{Numoferpset} = '';
        end
    end
else
    OverlayArraydef = qbinArray;
    for Numofbin = 1:numel(qbinArray)
        LegendNamedef{Numofbin,1} = char(binStr(qbinArray(Numofbin)));
    end
end

LineColordef = [0 0 0;1 0 0;0 0 1;0 1 0;1,0.65 0;0 1 1;1 0 1;0.5 0.5 0.5;0.94 0.50 0.50;0 0.75 1;0.57 0.93 0.57;1 0.55 0;1 0.75 0.80;1 0.84 0];%% get from:https://htmlcolorcodes.com/color-names/
LineMarkerdef = {'none','none','none','none','+','o','*'};
LineStyledef = {'-','--',':','-.','-','-','-',};
[ERPdatadef,legendNamedef,ERPerrordatadef,timeRangedef] = f_geterpdata(ALLERP,[1:length(ALLERP)],qPLOTORG);
%%%%%%%%%%%%%%%%%%%%--------------------------------------------------------

if qPLOTORG(1) ==1 %% if  the selected Channel is "Grid"
    plotArray = qchanArray;
    for Numofchan = 1:numel(plotArray)
        try
            plotArrayStrdef{Numofchan} = chanStrdef{plotArray(Numofchan)};
        catch
            plotArrayStrdef{Numofchan} = 'no';
        end
    end
elseif qPLOTORG(1) == 2 %% if the selected Bin is "Grid"
    plotArray = qbinArray;
    for Numofbin = 1:numel(plotArray)
        try
            plotArrayStrdef{Numofbin} = binStrdef{plotArray(Numofbin)};
        catch
            plotArrayStrdef{Numofbin} = 'no';
        end
    end
elseif qPLOTORG(1) == 3%% if the selected ERPset is "Grid"
    plotArray = qERPArray;
    for Numoferp = 1:numel(plotArray)
        try
            plotArrayStrdef{Numoferp} = ALLERP(plotArray(Numoferp)).erpname;
        catch
            plotArrayStrdef{Numoferp} = 'no';
        end
    end
else
    plotArray = qchanArray;
    for Numofchan = 1:numel(chanArray)
        try
            plotArrayStrdef{Numofchan} = chanStrdef{plotArray(Numofchan)};
        catch
            plotArrayStrdef{Numofchan} = 'no';
        end
    end
end

if nargin<49
    qFigOutpos =[];
end
if nargin<48 || (qXdisFlag~=1 && qXdisFlag~=0)
    qXdisFlag =1;
end


if nargin<47 || qXtickdecimal<0
    qXtickdecimal =0;
else
    qXtickdecimal =ceil(qXtickdecimal);
end



if nargin<46 || numel(qYtickdecimal)~=1 || qYtickdecimal<0
    qYtickdecimal =1;
end



if nargin<45 %%label text color
    qLabelcolor = [0 0 0 ];
end
if isempty(qLabelcolor) || numel(qLabelcolor)~=3 || max(qLabelcolor)>1 ||  min(qLabelcolor)<0
    qLabelcolor = [0 0 0];
end

if nargin <44%% Figure background color
    qFigbgColor = [1 1 1];
end
if isempty(qFigbgColor) || numel(qFigbgColor)~=3 || max(qFigbgColor)>1 ||  min(qFigbgColor)<0
    qFigbgColor = [1 1 1];
end


if nargin< 43
    qFigureName= '';
end


if nargin <42
    qlegcolumns=1;
end

if qlegcolumns<0 || isempty(qlegcolumns)
    qlegcolumns =1;
end

if nargin <41
    qlegcolor=1;
end

if isempty(qlegcolor) || (qlegcolor~=1 && qlegcolor~=0)
    qlegcolor=1;
end

if nargin <39 || isempty(qplotArrayStr)
    qplotArrayStr  = plotArrayStrdef;
end


%%
if nargin <38
    qMinorTicksY  = 0;
end

%%display y units?
if nargin<37
    qYunits  = 'on';
end

%%ylable color
if nargin <36
    qYlabelcolor = [0 0 0];
end

%%ylabel fontsize
if nargin<35
    qYlabelfontsize =12;
end

%%ylable font
if nargin <34
    qYlabelfont = 'Geneva';
end

%%display ylabels?
if nargin<33
    qYticklabel = 'on';
end

%%yticks
datresh = squeeze(ERPdatadef(qchanArray,:,qbinArray,qERPArray));
yymax   = max(datresh(:));
yymin   = min(datresh(:));
if abs(yymax)<1 && abs(yymin)<1
    scalesdef(1:2) = [yymin*1.2 yymax*1.1]; % JLC. Mar 11, 2015
else
    scalesdef(1:2) = [floor(yymin*1.2) ceil(yymax*1.1)]; % JLC. Sept 26, 2012
end
yylim_out = f_erpAutoYLim(ALLERP, qERPArray,qPLOTORG,qbinArray, qchanArray,qCURRENTPLOT);
try
    Yscalesdef = yylim_out(qCURRENTPLOT,:);
catch
    Yscalesdef = scalesdef;
end
if nargin <32
    if isempty(qYScales)
        qYticks = default_amp_ticks_viewer(Yscalesdef);
    else
        qYticks = default_amp_ticks_viewer(qYScales);
    end
end

%%y scale
if nargin <31
    qYScales = Yscalesdef;
end

%%display x units?
if nargin <30
    qXunits = 'on';
end
%%minor of xlabel
if nargin <29
    qMinorTicksX = 0;
end

%%xlabel color
if nargin <28
    qXlabelcolor = [0 0 0];
end

%%xlabel fontsize
if nargin <27
    qXlabelfontsize = 12;
end


%%xlabel font
if nargin <26
    qXlabelfont= 'Geneva';
end

%%disply xtick labels ?
if nargin<25
    qXticklabel = 'on';
end

%%xticks
try
    ERPIN = ALLERP(qCURRENTPLOT);
catch
    ERPIN = ALLERP(end);
end

try
    [timeticksdef stepX]= default_time_ticks_studio(ERPIN, qtimeRange);
    timeticksdef = str2num(char(timeticksdef));
catch
    timeticksdef = [];
end
if nargin<24
    qXticks = timeticksdef;
end

%%------------------------time range of plot wave--------------------------
if nargin<23
    qtimeRange(1) = timeRangedef(1);
    qtimeRange(2) = timeRangedef(end);
end

if isempty(qtimeRange)
    qtimeRange(1) = timeRangedef(1);
    qtimeRange(2) = timeRangedef(end);
end

%%------------------------------------Grid space---------------------------
if nargin<22
    qGridspace =[1 10; 1 10];
end
if isempty(qGridspace) || numel(qGridspace)~=4 || (size(qGridspace,1)~=2 || size(qGridspace,2)~=2)
    qGridspace =[1 10; 1 10];
else
    [rowgs,columgs] = size(qGridspace);
    if rowgs~=2 || columgs~=2
        qGridspace =[1 10; 1 10];
    else
        if qGridspace(1,1)~=1 && qGridspace(1,1)~=2
            qGridspace(1,1) =1;
        end
        if (qGridspace(1,1)==1 && qGridspace(1,2)<=0)
            qGridspace(1,2) =10;
        elseif (qGridspace(1,1)==2 && (qGridspace(1,2)<=0|| qGridspace(1,2)>100))
            qGridspace(1,2) =10;
        end
        if qGridspace(2,1)~=1 && qGridspace(2,1)~=2
            qGridspace(2,1) =1;
        end
        if (qGridspace(2,1)==1 && qGridspace(2,2)<=0)
            qGridspace(2,2) =10;
        elseif (qGridspace(2,1)==2 && (qGridspace(2,2)<=0|| qGridspace(2,2)>=100))
            qGridspace(2,2) =10;
            
        end
    end
end


%%---------------------------------Transparency----------------------------
if nargin <21
    qTransparency = 0;
end

%%standard error of mean
if nargin <20
    qSME = 0;
end


%%polarity of wave; the default is positive up
if nargin <19
    qPolarityWave = 1;
end

%%fontsize of channel/bin/erpset label
if nargin <18
    qLabelfontsize = 12;
end

%%font of channel/bin/erpset label
if nargin <17
    qLabelfont= 'Geneva';
end

%%location of channel/bin/erpset label
if nargin<16
    qCBELabels =[50 100 1];
end

%%fontsize of legend name
if nargin <15
    qLegendFontsize  = 12;
end

%%font of legend name
if nargin <14
    qLegendFont  = 'Geneva';
end

%%legend name
if nargin < 13
    qLegendName=LegendNamedef;
end

%%line width
for Numofcolor = 1:numel(OverlayArraydef)
    qLineWidthspecdef(1,Numofcolor) =1;
end
if nargin < 12
    qLineWidthspec = qLineWidthspecdef;
end


%%line marker
for Numofcolor = 1:numel(OverlayArraydef)
    NumIndex = ceil(Numofcolor/7);
    try
        qLineMarkerspecdef{1,Numofcolor} =  LineMarkerdef{NumIndex};
    catch
        qLineMarkerspecdef{1,Numofcolor} = 'none';
    end
end
if  nargin< 11
    qLineMarkerspec = qLineMarkerspecdef;
end


%%line style
for Numofcolor = 1:numel(OverlayArraydef)
    NumIndex = ceil(Numofcolor/7);
    try
        qLineStylespecdef{1,Numofcolor} =  LineStyledef{NumIndex};
    catch
        qLineStylespecdef{1,Numofcolor} = '-';
    end
end
if nargin< 10
    qLineStylespec = qLineStylespecdef;
end


%%line color
for Numofcolor = 1:numel(OverlayArraydef)
    Numindex = floor(Numofcolor/14);
    if Numindex==0
        try
            qLineColorspecdef(Numofcolor,:) = LineColordef(Numofcolor,:);
        catch
            qLineColorspecdef(Numofcolor,:) = [0 0 0];
        end
    elseif Numindex~=0
        if  floor(Numofcolor/14) ==ceil(Numofcolor/14)
            qLineColorspecdef(Numofcolor,:) = LineColordef(14,:);
        else
            try
                qLineColorspecdef(Numofcolor,:) = LineColordef(Numofcolor-14*Numindex,:);
            catch
                qLineColorspecdef(Numofcolor,:) = [0 0 0];
            end
        end
    else
        try
            qLineColorspecdef(Numofcolor,:) = LineColordef(14,:);
        catch
            qLineColorspecdef(Numofcolor,:) = [0 0 0];
        end
    end
end
if nargin< 9
    qLineColorspec = qLineColorspecdef;
end



if nargin<8
    qBlc  = 'none';
end

if nargin<7 ||  isempty(plotBox) ||  numel(plotBox)~=2
    plotBox =plotBoxdef;
end


NumRows = ceil(plotBox(1));
NumColumns = ceil(plotBox(2));
if nargin<6 || isempty(qGridposArray)
    count = 0;
    for Numofrow = 1:NumRows %%organization of Grid
        for Numofcolumn = 1:NumColumns
            count = count +1;
            if count> numel(plotArray)
                GridposArraydef(Numofrow,Numofcolumn)  =0;
            else
                GridposArraydef(Numofrow,Numofcolumn)  =  plotArray(count);
            end
        end
    end
    qGridposArray = GridposArraydef;
end
%%check elements in qGridposArray
plotArray = reshape(plotArray,1,[]);
for Numofrows = 1:size(qGridposArray,1)
    for Numofcolumns = 1:size(qGridposArray,2)
        SingleGridpos = qGridposArray(Numofrows,Numofcolumns);
        if SingleGridpos~=0
            ExistGridops = f_existvector(plotArray,SingleGridpos);
            if ExistGridops==1
                qGridposArray(Numofrows,Numofcolumns) =0;
            else
                [xpos,ypos]=  find(plotArray==SingleGridpos);
                qGridposArray(Numofrows,Numofcolumns) =ypos;
            end
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%-------------------------------Plot wave--------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for Numoferpset = 1:length(ALLERP)
    DataType{Numoferpset} = ALLERP(Numoferpset).datatype;
end
DataType = unique(DataType);

ALLERPBls = ALLERP;
%
%%baseline correction
if length(DataType)==1 && strcmpi(char(DataType), 'ERP')
    if (qPLOTORG(1)==1 && qPLOTORG(2)==2) || (qPLOTORG(1)==2 && qPLOTORG(2)==1)
        ERPArraybls = qERPArray(qCURRENTPLOT);
    else
        ERPArraybls = qERPArray;
    end
    for Numoferpset = ERPArraybls
        ERP = ALLERP(Numoferpset);
        if ~strcmpi(qBlc,'no') && ~strcmpi(qBlc,'none')%% when the baseline correction is "pre","post","whole"
            
            if strcmpi(qBlc,'pre')
                indxtimelock = find(ERP.times==0) ;   % zero-time locked
                aa = 1;
            elseif strcmpi(qBlc,'post')
                indxtimelock = length(ERP.times);
                aa = find(ERP.times==0);
            elseif strcmpi(qBlc,'all') || strcmpi(qBlc,'whole')
                indxtimelock = length(ERP.times);
                aa = 1;
            else
                fs = ERP.srate;
                kktime =1000;
                toffsa = abs(round(ERP.xmin*fs))+1;   % +1 October 2nd 2008
                blcnum = qBlc/kktime;               % from msec to secs  03-28-2009
                %
                % Check & fix baseline range
                %
                if blcnum(1)<ERP.xmin
                    blcnum(1) = ERP.xmin;
                end
                if blcnum(2)>ERP.xmax
                    blcnum(2) = ERP.xmax;
                end
                aa     = round(blcnum(1)*fs)+ toffsa; % in samples 12-16-2008
                indxtimelock = round(blcnum(2)*fs) + toffsa;    % in samples
            end
            
            for Numofchan = qchanArray
                for Numofbin = qbinArray
                    if Numofchan<= ERP.nchan && Numofbin<= ERP.nbin
                        baselineV = mean(ERP.bindata(Numofchan,aa:indxtimelock,Numofbin));
                        ERP.bindata(Numofchan,:,Numofbin) =  ERP.bindata(Numofchan,:,Numofbin)-baselineV;
                    end
                end
            end
        end
        ALLERPBls(Numoferpset) = ERP;
    end
    
else
    qBlc = 'no';
end


% [ERPdatadef,legendNamedef,ERPerrordatadef,timeRangedef]
[ERPdatadef,legendNamedef,ERPerrordatadef,timeRangedef] = f_geterpdata(ALLERPBls,qERPArray,qPLOTORG,qCURRENTPLOT);
datatype = '';
if qPLOTORG(1)==1 && qPLOTORG(2)==2 %% Array is plotnum by samples by datanum
    if qCURRENTPLOT> numel(qERPArray)
        qCURRENTPLOT= length(qERPArray);
    end
    bindata = ERPdatadef(qchanArray,:,qbinArray,qCURRENTPLOT);
    bindataerror = ERPerrordatadef(qchanArray,:,qbinArray,qCURRENTPLOT);
    %     if isempty(timeRangedef)
    timeRangedef = ALLERPBls(qERPArray(qCURRENTPLOT)).times;
    %     end
    try
        fs= ALLERPBls(qERPArray(qCURRENTPLOT)).srate;
        datatype = ALLERPBls(qERPArray(qCURRENTPLOT)).datatype;
    catch
        fs= ALLERPBls(end).srate;
        datatype = ALLERPBls(end).datatype;
    end
elseif  qPLOTORG(1)==2 && qPLOTORG(2)==1
    if qCURRENTPLOT> length(qERPArray)
        qCURRENTPLOT= length(qERPArray);
    end
    bindata = ERPdatadef(qchanArray,:,qbinArray,qCURRENTPLOT);
    bindata = permute(bindata,[3 2 1 4]);
    bindataerror = ERPerrordatadef(qchanArray,:,qbinArray,qCURRENTPLOT);
    bindataerror = permute(bindataerror,[3 2 1 4]);
    if isempty(timeRangedef)
        timeRangedef = ALLERPBls(qERPArray(qCURRENTPLOT)).times;
    end
    try
        fs= ALLERPBls(qERPArray(qCURRENTPLOT)).srate;
        datatype = ALLERPBls(qERPArray(qCURRENTPLOT)).datatype;
    catch
        fs= ALLERPBls(end).srate;
        datatype = ALLERPBls(end).datatype;
    end
elseif qPLOTORG(1)==1 && qPLOTORG(2)==3 %%Grid is channel; Overlay is ERPsets; Page is bin
    if qCURRENTPLOT> numel(qbinArray)
        qCURRENTPLOT = numel(qbinArray);
    end
    bindata = ERPdatadef(qchanArray,:,qbinArray(qCURRENTPLOT),:);
    bindata = permute(bindata,[1 2 4 3]);
    bindataerror = ERPerrordatadef(qchanArray,:,qbinArray(qCURRENTPLOT),:);
    bindataerror = permute(bindataerror,[1 2 4 3]);
    try
        fs= ALLERPBls(qERPArray(end)).srate;
        datatype = ALLERPBls(qERPArray(end)).datatype;
    catch
        fs= ALLERPBls(end).srate;
        datatype = ALLERPBls(end).datatype;
    end
elseif qPLOTORG(1)==3 && qPLOTORG(2)==1%%Grid is ERPsets; Overlay is channel
    if qCURRENTPLOT> numel(qbinArray)
        qCURRENTPLOT = numel(qbinArray);
    end
    bindata = ERPdatadef(qchanArray,:,qbinArray(qCURRENTPLOT),:);
    bindata = permute(bindata,[4 2 1 3]);
    bindataerror = ERPerrordatadef(qchanArray,:,qbinArray(qCURRENTPLOT),:);
    bindataerror = permute(bindataerror,[4 2 1 3]);
    try
        fs= ALLERPBls(qERPArray(end)).srate;
        datatype = ALLERPBls(qERPArray(end)).datatype;
    catch
        fs= ALLERPBls(end).srate;
        datatype = ALLERPBls(end).datatype;
    end
elseif qPLOTORG(1)==2 && qPLOTORG(2)==3%%Grid is bin; Overlay is ERPset; Page is channel
    if qCURRENTPLOT> numel(qchanArray)
        qCURRENTPLOT = numel(qchanArray);
    end
    bindata = ERPdatadef(qchanArray(qCURRENTPLOT),:,qbinArray,:);
    bindata = permute(bindata,[3 2 4 1]);
    bindataerror = ERPerrordatadef(qchanArray(qCURRENTPLOT),:,qbinArray,:);
    bindataerror = permute(bindataerror,[3 2 4 1]);
    try
        fs= ALLERPBls(qERPArray(end)).srate;
        datatype = ALLERPBls(qERPArray(end)).datatype;
    catch
        fs= ALLERPBls(end).srate;
        datatype = ALLERPBls(end).datatype;
    end
elseif qPLOTORG(1)==3 && qPLOTORG(2)==2%%Grid is ERPset; Overlay is bin; Page is channel
    if qCURRENTPLOT> numel(qchanArray)
        qCURRENTPLOT = numel(qchanArray);
    end
    bindata = ERPdatadef(qchanArray(qCURRENTPLOT),:,qbinArray,:);
    bindata = permute(bindata,[4 2 3 1]);
    bindataerror = ERPerrordatadef(qchanArray(qCURRENTPLOT),:,qbinArray,:);
    bindataerror = permute(bindataerror,[4 2 3 1]);
    try
        fs= ALLERPBls(qERPArray(end)).srate;
        datatype = ALLERPBls(qERPArray(end)).datatype;
    catch
        fs= ALLERPBls(end).srate;
        datatype = ALLERPBls(end).datatype;
    end
else
    if qCURRENTPLOT> length(qERPArray)
        qCURRENTPLOT= length(qERPArray);
    end
    bindata = ERPdatadef(qchanArray,:,qbinArray,qCURRENTPLOT);
    bindataerror = ERPerrordatadef(qchanArray,:,qbinArray,qCURRENTPLOT);
    if isempty(timeRangedef)
        timeRangedef = ALLERPBls(qERPArray(qCURRENTPLOT)).times;
    end
    try
        fs= ALLERPBls(qERPArray(end)).srate;
        datatype = ALLERPBls(qERPArray(end)).datatype;
    catch
        fs= ALLERPBls(end).srate;
        datatype = ALLERPBls(end).datatype;
    end
end

if isempty(qtimeRange)
    qtimeRange = [timeRangedef(1) timeRangedef(end)];
end


Numrows = plotBox(1);
Numcolumns = plotBox(2);


pboxTotal = 1:Numrows*Numcolumns;
corners = linspace(Numrows*Numcolumns-Numcolumns+1,Numrows*Numcolumns,Numcolumns);
pboxplot  = setxor(pboxTotal, corners);
if isempty(pboxplot)
    pboxplot = 1;
end

NumOverlay = size(bindata,3);


%%get y axis
y_scale_def = [1.1*min(bindata(:)),1.1*max(bindata(:))];
yMaxdef = ceil(max(bindata(:)))-floor(min(bindata(:)));
try
    isyaxislabel = qGridspace(1,1);
    Ypert = qGridspace(1,2);
catch
    isyaxislabel = 1;
    Ypert = 10;
end

if isempty( qYScales)
    qYScales = [floor(min(bindata(:))),ceil(max(bindata(:)))];
end

if isyaxislabel==1 %% y axis GAP
    if  Ypert<0
        Ypert = 10;
    end
    if ~isempty(qYScales)
        if numel(qYScales)==2
            yscaleall = qYScales(end)-qYScales(1);
        else
            yscaleall = 2*max(abs(qYScales));
            qYScales = [-max(abs(qYScales)),max(abs(qYScales))];
        end
        if yscaleall < y_scale_def(2)-y_scale_def(2)
            yscaleall = y_scale_def(2)-y_scale_def(2);
        end
        
        for Numofrows = 1:Numrows
            OffSetY(Numofrows) = yscaleall*(Numrows-Numofrows)*(Ypert/100+1);
        end
    else
        for Numofrows = 1:Numrows
            OffSetY(Numofrows) = yMaxdef*(Numrows-Numofrows)*(Ypert/100+1);
        end
    end
else%% y axis Overlay
    if Ypert>=100 || Ypert<=0
        Ypert = 40;
    end
    if ~isempty(qYScales)
        if numel(qYScales)==2
            yscaleall = qYScales(end)-qYScales(1);
        else
            yscaleall = 2*max(abs(qYScales));
            qYScales = [-max(abs(qYScales)),max(abs(qYScales))];
        end
        
        if yscaleall < y_scale_def(2)-y_scale_def(2)
            yscaleall = y_scale_def(2)-y_scale_def(2);
        end
        
        if Numrows ==1
            OffSetY = 0;
        else
            for Numofrows = 1:Numrows-1
                OffSetY(Numofrows) = yscaleall*(Numrows-Numofrows)*(1-(Ypert/100));
            end
            OffSetY(Numrows)=0;
        end
    else
        qYScales = [ceil(max(bindata(:))), floor(min(bindata(:)))];
        if Numrows ==1
            OffSetY = 0;
        else
            for Numofrows = 1:Numrows-1
                OffSetY(Numofrows) = yMaxdef*(Numrows-Numofrows)*(1-(Ypert/100));
            end
            OffSetY(Numrows)=0;
        end
    end
end



%%X axis gap
try
    isxaxislabel = qGridspace(2,1);
    Xpert = qGridspace(2,2);
catch
    isxaxislabel = 1;
    Xpert = 10;
end
if isxaxislabel ~=1 && isxaxislabel~=2
    isxaxislabel = 1;
end


if isxaxislabel==1 && Xpert<=0
    Xpert =10;
elseif isxaxislabel==2 && (Xpert<=0 || Xpert >=100)
    Xpert =40;
end
try
    StepX = (timeRangedef(end)-timeRangedef(1))*(Xpert/100);
catch
    beep;
    disp('ERP.times only has one element.');
    return;
end
StepXP = ceil(StepX/(1000/fs));



%%check yticks
try
    count =0;
    ytickDis =[];
    for Numofytick = 1:numel(qYticks)
        if qYticks(Numofytick) < qYScales(1) || qYticks(Numofytick) > qYScales(end)
            count = count+1;
            ytickDis(count) =  Numofytick;
        end
    end
    qYticks(ytickDis) = [];
catch
end
if isempty(qYticks)
    qYticks = str2num(char(default_amp_ticks_viewer(qYScales)));
end



%%Get the figure name which is to be plotted
if (qPLOTORG(1)==1 && qPLOTORG(2)==2) || (qPLOTORG(1)==1 && qPLOTORG(2)==2) %% Page is ERPset
    ERP = ALLERPBls(qCURRENTPLOT);
    if isempty(ERP.filename) || strcmp(ERP.filename,'')
        ERP.filename = 'still_not_saved!';
    end
    if isempty(ERP.erpname)
        fname = 'none';
    else
        [pathstr, fname, ext] = fileparts(ERP.erpname);
    end
elseif  (qPLOTORG(1)==1 && qPLOTORG(2)==3) || (qPLOTORG(1)==3 && qPLOTORG(2)==1) %% Page is bin
    fname = char(binStrdef{qbinArray(qCURRENTPLOT)});
    
elseif (qPLOTORG(1)==2 && qPLOTORG(2)==3) || (qPLOTORG(1)==3 && qPLOTORG(2)==2)
    fname = char(chanStrdef{qchanArray(qCURRENTPLOT)});
else
    ERP = ALLERPBls(qCURRENTPLOT);
    if isempty(ERP.filename) || strcmp(ERP.filename,'')
        ERP.filename = 'still_not_saved!';
    end
    if isempty(ERP.erpname)
        fname = 'none';
    else
        [pathstr, fname, ext] = fileparts(ERP.erpname);
    end
end
extfig ='';
[pathstrfig, qFigureName, extfig] = fileparts(qFigureName) ;


if isempty(qFigureName)
    fig_gui= figure('Name',['<< ' fname ' >> '],...
        'NumberTitle','on','color',qFigbgColor);
    %     fig_gui_wave = subplot(Numrows+1,1,[2:Numrows+1]);
    hbig = subplot(Numrows+1,1,[2:Numrows+1]);
    hold on;
end

if ~isempty(qFigureName)
    fig_gui= figure('Name',['<< ' qFigureName ' >> '],...
        'NumberTitle','on','color',qFigbgColor);
    hbig = subplot(ceil(Numrows*5)+1,1,[2:ceil(Numrows*5)+1]);
    hold on;
    %     hbig= axes('Parent',fig_gui_wave);
end
try
    outerpos = fig_gui.OuterPosition;
    set(fig_gui,'outerposition',[outerpos(1),(2),qFigOutpos(1) 1.05*qFigOutpos(2)])
catch
    set(fig_gui,'outerposition',get(0,'screensize'));%%Maximum figure
end
if ~isempty(extfig)
    set(fig_gui,'visible','off');
end
set(fig_gui, 'Renderer', 'painters');%%vector figure
try
    y_scale_def(1) = min([1.1*y_scale_def(1),1.1*qYScales(1)]);
    y_scale_def(2) = max([1.1*y_scale_def(2),1.1*qYScales(2)]);
catch
end

%%remove the margins of a plot
ax = hbig;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];



%%--------------Plot ERPwave-----------------
stdalpha = qTransparency;
countPlot = 0;
for Numofrows = 1:Numrows
    for Numofcolumns = 1:Numcolumns
        try
            plotdatalabel = qGridposArray(Numofrows,Numofcolumns);
        catch
            plotdatalabel = 0;
        end
        
        try
            labelcbe = qplotArrayStr{plotdatalabel};
        catch
            labelcbe = 'no';
        end
        try
            plotbindata =  bindata(plotdatalabel,:,:,:);
        catch
            plotbindata = [];
        end
        
        if plotdatalabel ~=0 && plotdatalabel<= numel(plotArray) && ~isempty(plotbindata)
            countPlot =countPlot +1;
            if qPolarityWave
                data4plot = squeeze(bindata(plotdatalabel,:,:,1));
            else
                data4plot = squeeze(bindata(plotdatalabel,:,:,1))*(-1);
            end
            
            data4plot = reshape(data4plot,numel(timeRangedef),NumOverlay);
            for Numofoverlay = 1:NumOverlay
                [Xtimerange, bindatatrs] = f_adjustbindtabasedtimedefd(squeeze(data4plot(:,Numofoverlay)), timeRangedef,qtimeRange,fs);
                PosIndexsALL = [Numofrows,Numcolumns];
                if isxaxislabel==2
                    [~,XtimerangetrasfALL,~,~,~] = f_adjustdata_xyrange_xyticks_overlay(bindatatrs,Xtimerange,qXticks,OffSetY,Numcolumns,PosIndexsALL,StepXP);
                else
                    [~,XtimerangetrasfALL,~] = f_adjustdata_xyrange_xyticks(bindatatrs,Xtimerange,qXticks,OffSetY,Numcolumns,PosIndexsALL,StepX,fs);
                end
                aerror = isnan(squeeze(bindataerror(plotdatalabel,:,Numofoverlay,1)));
                [Xerror,yerro] = find(aerror==0);
                PosIndexs = [Numofrows,Numofcolumns];
                if ~isempty(yerro) && qSEM>=1 &&stdalpha>0 %SEM
                    [Xtimerange, bindataerrtrs] = f_adjustbindtabasedtimedefd(squeeze(bindataerror(plotdatalabel,:,Numofoverlay,1)), timeRangedef,qtimeRange,fs);
                    if isxaxislabel==2
                        [bindatatrs1,Xtimerangetrasf,qXtickstransf,TimeAdjustOut,XtimerangeadjustALL] = f_adjustdata_xyrange_xyticks_overlay(bindatatrs,Xtimerange,qXticks,OffSetY,Numcolumns,PosIndexs,StepXP);
                    else
                        [bindatatrs1,Xtimerangetrasf,qXtickstransf] = f_adjustdata_xyrange_xyticks(bindatatrs,Xtimerange,qXticks,OffSetY,Numcolumns,PosIndexs,StepX,fs);
                    end
                    yt1 = bindatatrs1 - bindataerrtrs.*qSEM;
                    yt2 = bindatatrs1 + bindataerrtrs.*qSEM;
                    %                     ciplot(yt1,yt2, Xtimerangetrasf, qLineColorspec(Numofoverlay,:), stdalpha);
                    fill(hbig,[Xtimerangetrasf fliplr(Xtimerangetrasf)],[yt2 fliplr(yt1)], qLineColorspec(Numofoverlay,:), 'FaceAlpha', stdalpha, 'EdgeColor', 'none');
                    %                     set(hbig, 'InvertHardcopy', 'off', 'PaperPositionMode', 'auto', 'PaperOrientation', 'portrait');
                end
                if isxaxislabel==2
                    [bindatatrs,Xtimerangetrasf,qXtickstransf,TimeAdjustOut,XtimerangeadjustALL] = f_adjustdata_xyrange_xyticks_overlay(bindatatrs,Xtimerange,qXticks,OffSetY,Numcolumns,PosIndexs,StepXP);
                else
                    [bindatatrs,Xtimerangetrasf,qXtickstransf] = f_adjustdata_xyrange_xyticks(bindatatrs,Xtimerange,qXticks,OffSetY,Numcolumns,PosIndexs,StepX,fs);
                end
                hplot(Numofoverlay) = plot(hbig,Xtimerangetrasf, bindatatrs,'LineWidth',qLineWidthspec(Numofoverlay),...
                    'Color', qLineColorspec(Numofoverlay,:), 'LineStyle',qLineStylespec{Numofoverlay},'Marker',qLineMarkerspec{Numofoverlay});
                %                 qLegendName{Numofoverlay} = strrep(qLegendName{Numofoverlay},'_','\_'); % trick for dealing with '_'. JLC
                %                 set(hplot(Numofoverlay),'DisplayName', qLegendName{Numofoverlay});
            end
            
            if numel(OffSetY)==1 && OffSetY==0
                if ~qPolarityWave
                    YscalesNew =  sort(y_scale_def*(-1));
                else
                    YscalesNew =  y_scale_def;
                end
                set(hbig,'ylim',YscalesNew);
            else
                if qPolarityWave
                    ylimleftedge = floor(y_scale_def(1));
                    ylimrightedge = ceil(y_scale_def(end))+OffSetY(1);
                else
                    ylimleftedge = -abs(ceil(y_scale_def(end)));
                    ylimrightedge = ceil(abs(y_scale_def(1)))+OffSetY(1);
                end
                set(hbig,'ylim',[ylimleftedge,ylimrightedge]);
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%----------------------Adjust y axis------------------------%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            props = get(hbig);
            if qPolarityWave
                props.YTick = qYticks+OffSetY(Numofrows);
            else
                props.YTick =  fliplr (-1*qYticks)+OffSetY(Numofrows);
            end
            props.YTickLabel = cell(numel(props.YTick),1);
            
            
            for Numofytick = 1:numel(props.YTick)
                props.YTickLabel(Numofytick) = {num2str(props.YTick(Numofytick))};
            end
            
            [x,y_0] = find(Xtimerange==0);
            if isempty(y_0)
                y_0 = 1;
            end
            myY_Crossing = Xtimerangetrasf(y_0);
            tick_top = 0;
            
            if countPlot ==1
                ytick_bottom = -props.TickLength(1)*diff(props.XLim);
                ytick_bottomratio = abs(ytick_bottom)/diff(props.XLim);
            else
                try
                    ytick_bottom = ytick_bottom;
                    ytick_bottomratio = ytick_bottomratio;
                catch
                    ytick_bottom = -props.TickLength(1)*diff(props.XLim);
                    ytick_bottomratio = abs(ytick_bottom)/diff(props.XLim);
                end
            end
            %%add  yunits
            if  qPolarityWave%%Positive up
                yunitsypos = 0.98*qYScales(end);
            else
                yunitsypos = 0.95*abs(qYScales(1));
            end
            if strcmpi( datatype,'ERP')
                yunitstr =  '\muV';
            elseif strcmpi( datatype,'CSD')
                yunitstr =  '\muV/m^2';
            else
                yunitstr = '';
            end
            if strcmpi(qYunits,'on')
                text(hbig,myY_Crossing+abs(ytick_bottom),yunitsypos+OffSetY(Numofrows),yunitstr, 'FontName',qYlabelfont,'FontSize',qYlabelfontsize,'HorizontalAlignment', 'left', 'Color', qYlabelcolor);
            end
            
            if ~isempty(props.YTick)
                ytick_y = repmat(props.YTick, 2, 1);
                ytick_x = repmat([tick_top;ytick_bottom] +myY_Crossing, 1, length(props.YTick));
                line(hbig,ytick_x(:,:), ytick_y(:,:), 'color', 'k','LineWidth',1);
                try
                    [~,y_below0] =find(qYticks<0);
                    if isempty(y_below0) && qYScales(1)<0
                        line(hbig,ytick_x(:,:), ones(2,1)*(qYScales(1)+OffSetY(Numofrows)), 'color', 'k','LineWidth',1);
                    end
                    [~,y_over0] =find(qYticks>0);
                    if isempty(y_over0) && qYScales(2)>0
                        line(hbig,ytick_x(:,:), ones(2,1)*(qYScales(2)+OffSetY(Numofrows)), 'color', 'k','LineWidth',1);
                    end
                catch
                end
            end
            
            if ~isempty(qYScales)  && numel(qYScales)==2 %qYScales(end))+OffSetY(1)
                if  qPolarityWave==0
                    qYScalestras =   fliplr (-1*qYScales);
                else
                    qYScalestras = qYScales;
                end
                plot(hbig,ones(numel(qYScalestras),1)*myY_Crossing, qYScalestras+OffSetY(Numofrows),'k','LineWidth',1);
            else
                if ~isempty(y_scale_def) && numel(unique(y_scale_def))==2
                    if  qPolarityWave==0
                        qYScalestras =   fliplr (-1*y_scale_def);
                    else
                        qYScalestras = y_scale_def;
                    end
                    
                    plot(hbig,ones(numel(qYScales),1)*myY_Crossing, qYScalestras+OffSetY(Numofrows),'k','LineWidth',1);
                else
                    
                end
            end
            
            
            nYTicks = length(props.YTick);
            for iCount = 1:nYTicks
                if qPolarityWave
                    ytick_label= sprintf(['%.',num2str(qYtickdecimal),'f'],str2num(char(props.YTickLabel(iCount, :)))-OffSetY(Numofrows));
                else
                    qyticktras =   fliplr(-1*qYticks);
                    ytick_label= sprintf(['%.',num2str(qYtickdecimal),'f'],-qyticktras(iCount));
                end
                %                 end
                if str2num(char(ytick_label)) ==0 || (str2num(char(ytick_label))<0.0001 && str2num(char(ytick_label))>0) || (str2num(char(ytick_label))>-0.0001 && str2num(char(ytick_label))<0)
                    ytick_label = '';
                end
                if ~strcmpi(qYticklabel,'on')
                    ytick_label = '';
                end
                text(hbig,myY_Crossing-2*abs(ytick_bottom),props.YTick(iCount),  ...
                    ytick_label, ...
                    'HorizontalAlignment', 'right', ...
                    'VerticalAlignment', 'middle', ...
                    'FontSize', qYlabelfontsize, ...
                    'FontName', qYlabelfont, ...
                    'FontAngle', props.FontAngle, ...
                    'FontUnits', props.FontUnits,...
                    'Color',qYlabelcolor);
            end
            
            %%Minor Y
            if qMinorTicksY(1)
                set(hbig,'YMinorTick','on')
                try
                    MinorTicksYValue = qMinorTicksY(2:end);
                catch
                    MinorTicksYValue = [];
                end
                if ~isempty(MinorTicksYValue)
                    MinorTicksYValue(find(MinorTicksYValue<qYScales(1))) = [];%% check the minorticks based on the left edge of yticks
                    MinorTicksYValue(find(MinorTicksYValue>qYScales(end))) = [];%% check the minorticks based on the right edge of yticks
                    props.YAxis.TickValues = MinorTicksYValue;
                    if ~isempty( props.YAxis.TickValues)
                        ytick_y = repmat( props.YAxis.TickValues+OffSetY(Numofrows), 2, 1);
                        ytick_x = repmat([tick_top;2*ytick_bottom/3] +myY_Crossing, 1, length( props.YAxis.TickValues));
                        line(hbig,ytick_x(:,:), ytick_y(:,:), 'color', 'k','LineWidth',1);
                    end
                end
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%----------------------Adjust x axis------------------------%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            props.XTick = qXtickstransf;
            props.XTickLabel = cell(numel(qXticks),1);
            for Numofytick = 1:numel(props.XTick)
                props.XTickLabel(Numofytick) = {num2str(qXticks(Numofytick))};
            end
            myX_Crossing = OffSetY(Numofrows);
            if countPlot ==1
                xtick_bottom = -props.TickLength(2)*max(props.YLim);
                if abs(xtick_bottom)/max(props.YLim) > ytick_bottomratio
                    xtick_bottom = -ytick_bottomratio*max(props.YLim);
                end
            else
                try
                    xtick_bottom = xtick_bottom;
                catch
                    xtick_bottom = -props.TickLength(2)*max(props.YLim);
                    if abs(xtick_bottom)/max(props.YLim) > ytick_bottomratio
                        xtick_bottom = -ytick_bottomratio*max(props.YLim);
                    end
                end
            end
            if ~isempty(props.XTick)
                xtick_x = repmat(props.XTick, 2, 1);
                xtick_y = repmat([xtick_bottom; tick_top] + myX_Crossing, 1, length(props.XTick));
                line(hbig,xtick_x, xtick_y, 'color', 'k','LineWidth',1);
            end
            [x_xtick,y_xtick] = find(props.XTick==0);
            if ~isempty(y_xtick)
                props.XTick(y_xtick) = 2*xtick_bottom;
            end
            plot(hbig,Xtimerangetrasf, myX_Crossing.*ones(numel(Xtimerangetrasf),1),'k','LineWidth',1);
            nxTicks = length(props.XTick);
            
            for iCount = 1:nxTicks
                xtick_label = (props.XTickLabel(iCount, :));
                if strcmpi(qXticklabel,'on')
                    if strcmpi(xtick_label,'0')
                        xtick_label = '';
                    end
                else
                    xtick_label = '';
                end
                if qXdisFlag ==1%%in millisecond
                    xtick_label= sprintf(['%.',num2str(qXtickdecimal),'f'],str2num(char(xtick_label)));
                else%% in second
                    xtick_label= sprintf(['%.',num2str(qXtickdecimal),'f'],str2num(char(xtick_label))/1000);
                end
                
                if strcmpi(qXunits,'on') && (iCount== nxTicks) && qXdisFlag ==1
                    xtick_label = strcat(char(xtick_label),32,'ms');
                elseif strcmpi(qXunits,'on') && (iCount== nxTicks) && qXdisFlag ==0
                    xtick_label = strcat(char(xtick_label),32,'s');
                end
                
                text(hbig,props.XTick(iCount), xtick_bottom + myX_Crossing, ...
                    xtick_label, ...
                    'HorizontalAlignment', 'Center', ...
                    'VerticalAlignment', 'Top', ...
                    'FontSize', qXlabelfontsize, ...
                    'FontName', qXlabelfont, ...
                    'FontAngle', props.FontAngle, ...
                    'FontUnits', props.FontUnits,...
                    'Color',qXlabelcolor);
            end
            %%-----------------minor X---------------
            %             timewindow_bin = Xtimerange(2)-Xtimerange(1);
            %             xlimrightedge = timewindow_bin*(numel(Xtimerange)*Numcolumns+StepXP*(Numcolumns-1)-1);
            set(hbig,'xlim',[Xtimerange(1),Xtimerangetrasf(end)]);
            if qMinorTicksX(1)
                set(hbig,'XMinorTick','on');
                if isxaxislabel==2
                    xlimrightedgemin = TimeAdjustOut;
                else
                    timewindow_bin = Xtimerange(2)-Xtimerange(1);
                    xlimrightedgemin = timewindow_bin*(numel(Xtimerange)*(Numofcolumns-1)+StepXP*(Numofcolumns-1));
                end
                try
                    MinorTicksXValue = qMinorTicksX(2:end);
                catch
                    MinorTicksXValue = [];
                end
                if ~isempty(MinorTicksXValue)
                    MinorTicksXValue(find(MinorTicksXValue<Xtimerange(1))) = [];%% check the xminorticks based on the left edge of xticks
                    MinorTicksXValue(find(MinorTicksXValue>Xtimerange(end))) = [];%% check the xminorticks based on the right edge of xticks
                    props.XAxis.TickValues = unique(MinorTicksXValue+xlimrightedgemin);
                    if ~isempty(props.XAxis.TickValues)
                        xtick_x = repmat(props.XAxis.TickValues, 2, 1);
                        xtick_y = repmat([2*xtick_bottom/3; tick_top] + myX_Crossing, 1, length(props.XAxis.TickValues));
                        line(hbig,xtick_x, xtick_y, 'color', 'k','LineWidth',1);
                    end
                end
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%------------------channel/bin/erpset label-----------------%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if ~isempty(qCBELabels)
                try
                    ypercentage=qCBELabels(2);
                catch
                    ypercentage =100;
                end
                try
                    iscenter = qCBELabels(3);
                catch
                    iscenter =1;
                end
                
                %                 if qPolarityWave  %%polarity up
                ypos_LABEL = (qYScalestras(end)-qYScalestras(1))*(ypercentage)/100+qYScalestras(1);
                %                 else %% negative up
                %                     ypos_LABEL = ((qYScalestras(end)-qYScalestras(1))*(ypercentage)/100+qYScalestras(1));
                %                 end
                try
                    xpercentage=qCBELabels(1);
                catch
                    xpercentage = 50;
                end
                xpos_LABEL = (Xtimerangetrasf(end)-Xtimerangetrasf(1))*xpercentage/100 + Xtimerangetrasf(1);
                labelcbe =  strrep(char(labelcbe),'_','\_');
                try
                    labelcbe = regexp(labelcbe, '\;', 'split');
                catch
                end
                if ~iscenter
                    text(hbig,xpos_LABEL,ypos_LABEL+OffSetY(Numofrows), char(labelcbe), 'FontName',qLabelfont,'FontSize',qLabelfontsize,'HorizontalAlignment', 'center',  'Color', qLabelcolor);%'FontWeight', 'bold',
                else
                    text(hbig,xpos_LABEL,ypos_LABEL+OffSetY(Numofrows), char(labelcbe), 'FontName',qLabelfont,'FontSize',qLabelfontsize,'HorizontalAlignment', 'left', 'Color', qLabelcolor);%'FontWeight', 'bold',
                end
            end
        else
            %             disp(['Data at',32,'R',num2str(Numofrows),',','C',num2str(Numofcolumns), 32,'is empty!']);
        end
        try
            if 2<Numcolumns && Numcolumns<5
                set(hbig,'xlim',[Xtimerange(1)-(Xtimerange(end)-Xtimerange(1))/20,XtimerangetrasfALL(end)+(Xtimerange(end)-Xtimerange(1))/20]);
            elseif Numcolumns==1
                set(hbig,'xlim',[Xtimerange(1)-(Xtimerange(end)-Xtimerange(1))/40,XtimerangetrasfALL(end)+(Xtimerange(end)-Xtimerange(1))/40]);
            elseif Numcolumns==2
                set(hbig,'xlim',[Xtimerange(1)-(Xtimerange(end)-Xtimerange(1))/30,XtimerangetrasfALL(end)+(Xtimerange(end)-Xtimerange(1))/30]);
            else
                set(hbig,'xlim',[Xtimerange(1)-(Xtimerange(end)-Xtimerange(1))/10,XtimerangetrasfALL(end)+(Xtimerange(end)-Xtimerange(1))/10]);
            end
        catch
            
        end
    end%% end of columns
    %     ylim([(min(OffSetY(:))+qYScales(1)),1.1*(max(OffSetY(:))+qYScales(end))]);
end%% end of rows
set(hbig, 'XTick', [], 'YTick', [],'Box','off', 'Color','none','xcolor','none','ycolor','none');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%------------------------------legend name------------------------------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    for Numofoverlay = 1:numel(hplot)
        qLegendName{Numofoverlay} = strrep(qLegendName{Numofoverlay},'_','\_');
        LegendName{Numofoverlay} = char(strcat('\color[rgb]{',num2str(qLineColorspec(Numofoverlay,:)),'}',32,qLegendName{Numofoverlay}));
    end
    sh = subplot(ceil(Numrows*5)+1, 1, 1,'align');
    p  = get(sh,'position');
    if qlegcolor ~=1
        try
            h_legend = legend(sh,hplot,LegendName);%%,'Interpreter','none'
        catch
            h_legend = legend(sh,hplot,qLegendName);
        end
    else
        h_legend = legend(sh,hplot,qLegendName);
    end
    set(h_legend,'FontSize',qLegendFontsize);%% legend name fontsize
    set(h_legend,'FontName',qLegendFont);%%legend name font
    set(h_legend, 'position', p);
    set(h_legend,'NumColumns',qlegcolumns);
    
    %%increase height of the legend
    HeightScaleFactor = 1;
    NewHeight = h_legend.Position(4) * HeightScaleFactor;
    h_legend.Position(2) = h_legend.Position(2) - (NewHeight - h_legend.Position(4));
    h_legend.Position(4) = NewHeight;
    
    
    legend(sh,'boxoff');
    axis(sh,'off');
catch
    beep;
    disp('Cannot display the legend names, please check "qGridposArray" or other parameters!');
end
set(gcf,'color',qFigbgColor);
prePaperType = get(fig_gui,'PaperType');
prePaperUnits = get(fig_gui,'PaperUnits');
preUnits = get(fig_gui,'Units');
prePaperPosition = get(fig_gui,'PaperPosition');
prePaperSize = get(fig_gui,'PaperSize');
% Make changing paper type possible
set(fig_gui,'PaperType','<custom>');

% Set units to all be the same
set(fig_gui,'PaperUnits','inches');
set(fig_gui,'Units','inches');
% Set the page size and position to match the figure's dimensions
paperPosition = get(fig_gui,'PaperPosition');
position = get(fig_gui,'Position');
set(fig_gui,'PaperPosition',[0,0,position(3:4)]);
set(fig_gui,'PaperSize',position(3:4));

%%save figure  with different formats
if ~isempty(extfig)
    [C_style,IA_style] = ismember_bc2(extfig,{'.pdf','.svg','.jpg','.png','.tif','.bmp','.eps'});
    figFileName = fullfile(pathstrfig,qFigureName);
    try
        switch IA_style
            case 1
                print(fig_gui,'-dpdf',figFileName);
            case 2
                print(fig_gui,'-dsvg',figFileName);
            case 3
                print(fig_gui,'-djpeg',figFileName);
            case 4
                print(fig_gui,'-dpng',figFileName);
                
            case 5
                print(fig_gui,'-dtiff',figFileName);
            case 6
                print(fig_gui,'-dbmp',figFileName);
            case 7
                print(fig_gui,'-depsc',figFileName);
            otherwise
                print(fig_gui,'-dpdf',figFileName);
        end
    catch
        print(fig_gui,'-dpdf',figFileName);
    end
end

return;