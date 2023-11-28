
% *** This function is part of EStudio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022




function OutputViewerpar = f_preparms_erpwaviewer(FigureName,History)
OutputViewerpar = '';
if nargin<1
    help f_preparms_erpwaviewer();
    return
end

if nargin<2
    History = 'gui';
end
global gui_erp_waviewer;


ALLERPIN = gui_erp_waviewer.ERPwaviewer.ALLERP;
ERPIN= gui_erp_waviewer.ERPwaviewer.ERP;
CURRENTERPIN = gui_erp_waviewer.ERPwaviewer.CURRENTERP;

if isempty(CURRENTERPIN) || CURRENTERPIN > length(ALLERPIN) %%checking index of current erpset
    CURRENTERPIN =length(ALLERPIN);
end

%%checking the indices of the selected ERPsets
ERPsetArray = gui_erp_waviewer.ERPwaviewer.SelectERPIdx;
if max(ERPsetArray) >length(ALLERPIN)
    ERPsetArray =length(ALLERPIN);
end

%
%%bin array and channel array
binArray = gui_erp_waviewer.ERPwaviewer.bin;
chanArray = gui_erp_waviewer.ERPwaviewer.chan;
PLOTORG =[1 2 3];%%The default parameters for plotting organization
%%The first element is for  Grid; the second one is for Overlay; The last one is for Pages.
try
    PLOTORG(1) = gui_erp_waviewer.ERPwaviewer.plot_org.Grid ;
    PLOTORG(2) = gui_erp_waviewer.ERPwaviewer.plot_org.Overlay;
    PLOTORG(3) = gui_erp_waviewer.ERPwaviewer.plot_org.Pages;
catch
    PLOTORG = [1 2 3]; %%"Channels" is Grid; "Bins" is Overlay; "ERPsets" is Pages.
end


[chanStr,binStr,diff_mark,chanStremp,binStremp] = f_geterpschanbin(ALLERPIN,ERPsetArray);


plotArrayStrdef ='';
plotArray = [];
if PLOTORG(1) ==1 %% if  the selected Channel is "Grid"
    plotArray = chanArray;
    for Numofchan = 1:numel(chanArray)
        try
            plotArrayStrdef{Numofchan} = chanStremp{plotArray(Numofchan)};
        catch
            plotArrayStrdef{Numofchan} = '';
        end
    end
elseif PLOTORG(1) == 2 %% if the selected Bin is "Grid"
    plotArray = binArray;
    for Numofchan = 1:numel(plotArray)
        try
            plotArrayStrdef{Numofchan} = binStremp{plotArray(Numofchan)};
        catch
            plotArrayStrdef{Numofchan} = ' ';
        end
    end
elseif PLOTORG(1) == 3%% if the selected ERPset is "Grid"
    plotArray = ERPsetArray;
    for Numofchan = 1:numel(plotArray)
        try
            plotArrayStrdef{Numofchan} = ALLERPIN(plotArray(Numofchan)).erpname;
        catch
            plotArrayStrdef{Numofchan} = '';
        end
    end
end
GridLayoutop=0;
LabelsName =  plotArrayStrdef;

%
%%Getting the specific setting of each position for Grid
plotBox = f_getrow_columnautowaveplot(plotArray);%% the first element is number of rows and the second element is the number of columns
GridposArray = [];
LabelsdiffFlag = 0;
if GridLayoutop==1
    count = 0;
    for Numofrow = 1:plotBox(1) %%organization of Grid
        for Numofcolumn = 1:plotBox(2)
            count = count +1;
            if count> numel(plotArray)
                GridposArray(Numofrow,Numofcolumn)  =0;
            else
                GridposArray(Numofrow,Numofcolumn)  =  plotArray(count);
            end
        end
    end
elseif  GridLayoutop==0
    try %%try to use the user defined parameters for "Grid"
        plotBox(1) = gui_erp_waviewer.ERPwaviewer.plot_org.gridlayout.rows;
        plotBox(2) = gui_erp_waviewer.ERPwaviewer.plot_org.gridlayout.columns;
        columFormat =  gui_erp_waviewer.ERPwaviewer.plot_org.gridlayout.columFormat;
        DataDf = gui_erp_waviewer.ERPwaviewer.plot_org.gridlayout.data;
        for Numofrows = 1:plotBox(1)
            for Numofcolumns = 1:plotBox(2)
                SingleStr =  char(DataDf{Numofrows,Numofcolumns});
                [C,IA] = ismember_bc2(SingleStr,columFormat);
                if C ==1
                    if IA <= length(columFormat)
                        try
                            GridposArray(Numofrows,Numofcolumns)   = plotArray(IA);
                            try
                                if isempty(plotArrayStrdef{IA})
                                    LabelsdiffFlag =1;
                                end
                            catch
                            end
                            
                        catch
                            GridposArray(Numofrows,Numofcolumns) =0;
                        end
                    end
                else
                    GridposArray(Numofrows,Numofcolumns)   = 0;
                end
            end
        end
    catch %%using the default parameters if there are some plorblems when using the defined parameters
        count = 0;
        for Numofrow = 1:plotBox(1) %%organization of Grid
            for Numofcolumn = 1:plotBox(2)
                count = count +1;
                if count> numel(plotArray)
                    GridposArray(Numofrow,Numofcolumn)  =0;
                else
                    GridposArray(Numofrow,Numofcolumn)  =  plotArray(count);
                end
            end
        end
    end%%End of Try
end

%
%%---------------line color, line style, line marker,linewidth-------------
LegendName = {''};
if PLOTORG(2) ==1 %% if  the selected Channel is "Grid"
    OverlayArray = chanArray;
    for Numofchan = 1:numel(chanArray)
        LegendName{Numofchan,1} =char(chanStr(chanArray(Numofchan)));
    end
elseif PLOTORG(2) == 2 %% if the selected Bin is "Grid"
    OverlayArray = binArray;
    for Numofbin = 1:numel(binArray)
        LegendName{Numofbin,1} = char(binStr(binArray(Numofbin)));
    end
elseif PLOTORG(2) == 3%% if the selected ERPset is "Grid"
    OverlayArray = ERPsetArray;
    for Numoferpset = 1:numel(ERPsetArray)
        try
            LegendName{Numoferpset} = ALLERPIN(ERPsetArray(Numoferpset)).erpname;
        catch
            LegendName{Numoferpset} = '';
        end
    end
else
    OverlayArray = binArray;
    for Numofbin = 1:numel(binArray)
        LegendName{Numofbin,1} = char(binStr(binArray(Numofbin)));
    end
end
lineStylrstr = {'solid','dash','dot','dashdot','plus','circle','asterisk'};
linecolorsrgb = {'[0 0 0]','[1 0 0]','[0 0 1]','[0 1 0]','[1,0.65 0]','[0 1 1]','[1 0 1]',...
    '[0.5 0.5 0.5]','[0.94 0.50 0.50]','[0 0.75 1]','[0.57 0.93 0.57]','[1 0.55 0]','[1 0.75 0.80]','[1 0.84 0]',...
    '[0 0 0]','[1 0 0]','[0 0 1]','[0 1 0]','[1,0.65 0]','[0 1 1]','[1 0 1]',...
    '[0.5 0.5 0.5]','[0.94 0.50 0.50]','[0 0.75 1]','[0.57 0.93 0.57]','[1 0.55 0]','[1 0.75 0.80]','[1 0.84 0]',...
    '[0 0 0]','[1 0 0]','[0 0 1]','[0 1 0]','[1,0.65 0]','[0 1 1]','[1 0 1]',...
    '[0.5 0.5 0.5]','[0.94 0.50 0.50]','[0 0.75 1]','[0.57 0.93 0.57]','[1 0.55 0]','[1 0.75 0.80]','[1 0.84 0]',...
    '[0 0 0]','[1 0 0]','[0 0 1]','[0 1 0]','[1,0.65 0]','[0 1 1]','[1 0 1]',...
    '[0.5 0.5 0.5]','[0.94 0.50 0.50]','[0 0.75 1]','[0.57 0.93 0.57]','[1 0.55 0]','[1 0.75 0.80]','[1 0.84 0]',...
    '[0 0 0]','[1 0 0]','[0 0 1]','[0 1 0]','[1,0.65 0]','[0 1 1]','[1 0 1]',...
    '[0.5 0.5 0.5]','[0.94 0.50 0.50]','[0 0.75 1]','[0.57 0.93 0.57]','[1 0.55 0]','[1 0.75 0.80]','[1 0.84 0]',...
    '[0 0 0]','[1 0 0]','[0 0 1]','[0 1 0]','[1,0.65 0]','[0 1 1]','[1 0 1]',...
    '[0.5 0.5 0.5]','[0.94 0.50 0.50]','[0 0.75 1]','[0.57 0.93 0.57]','[1 0.55 0]','[1 0.75 0.80]','[1 0.84 0]',...
    '[0 0 0]','[1 0 0]','[0 0 1]','[0 1 0]','[1,0.65 0]','[0 1 1]','[1 0 1]',...
    '[0.5 0.5 0.5]','[0.94 0.50 0.50]','[0 0.75 1]','[0.57 0.93 0.57]','[1 0.55 0]','[1 0.75 0.80]','[1 0.84 0]',...
    '[0 0 0]','[1 0 0]','[0 0 1]','[0 1 0]','[1,0.65 0]','[0 1 1]','[1 0 1]'}';
LineColorspec = zeros(numel(OverlayArray),3); %%
LineStylespec = cell(1,numel(OverlayArray));
LineMarkerspec = cell(1,numel(OverlayArray));
LineWidthspec = ones(1,numel(OverlayArray));
try
    LineData = gui_erp_waviewer.ERPwaviewer.Lines.data;
    if gui_erp_waviewer.ERPwaviewer.Lines.auto
        LineDataColor = linecolorsrgb;
    else
        for ii = 1:size(LineData,1)
            try
                LineDataColor{ii} = LineData{ii,2};
            catch
                LineDataColor{ii} = linecolorsrgb{ii};
            end
        end
    end
catch
    [lineNameStr,linecolors,linetypes,linewidths] = f_get_lineset_ERPviewer(numel(OverlayArray));
    lineset_str  =table(lineNameStr,linecolors,linetypes,linewidths);
    LineData = table2cell(lineset_str);
    LineDataColor = linecolorsrgb;
end

for Numofplot = 1: numel(OverlayArray)  %%using RGB or r,g,b,o?
    %%determine the specific RGB value for the defined color
    if Numofplot <= length(LineDataColor)
        cellColor = str2num(LineDataColor{Numofplot});
        if numel(cellColor)~=3 || min(cellColor)<0 || max(cellColor)>1
            LineColorspec(Numofplot,:)  = [0 0 0];%% black
        else
            LineColorspec(Numofplot,:)  = cellColor;%% black
        end
    else
        LineColorspec(Numofplot,1)  = [0 0 0];
    end
    %%Line style
    CellStyle = LineData{Numofplot,3};
    [C_style,IA_style] = ismember_bc2(CellStyle,lineStylrstr);
    if C_style==1
        switch IA_style %{'solid','dash','dot','dashdot','plus','circle','asterisk'};
            case 1
                LineMarkerspec{1,Numofplot} = 'none';
                LineStylespec{1,Numofplot}   = '-';
            case 2
                LineMarkerspec{1,Numofplot} = 'none';
                LineStylespec{1,Numofplot}   = '--';
            case 3
                LineMarkerspec{1,Numofplot} = 'none';
                LineStylespec{1,Numofplot}   = ':';
            case 4
                LineMarkerspec{1,Numofplot} = 'none';
                LineStylespec{1,Numofplot}   = '-.';
            case 5
                LineStylespec{1,Numofplot}   = '-';
                LineMarkerspec{1,Numofplot} = '+';
            case 6
                LineStylespec{1,Numofplot}   = '-';
                LineMarkerspec{1,Numofplot} = 'o';
            case 7
                LineStylespec{1,Numofplot}   = '-';
                LineMarkerspec{1,Numofplot} = '*';
            otherwise
                LineStylespec{1,Numofplot}   = '-';
                LineMarkerspec{1,Numofplot} = 'none';
        end
    else
        LineStylespec{1,Numofplot}   = '-';
        LineMarkerspec{1,Numofplot} = 'none';
    end%% end of line style
    
    %%line width
    try
        LineWidthspec(1,Numofplot) = LineData{Numofplot,4};
    catch
        LineWidthspec(1,Numofplot) =1;
    end%% end for setting of line width
end%% end of loop for number of line

%
%%-----------------------------Setting for legend--------------------------
FontSizeLeg=  10;
FontLeg=  'Helvetica';
fonttype = {'Courier','Geneva','Helvetica','Monaco','Times'};
TextcolorLeg = 1;
Legcolumns = 1;
try
    for NumofOverlay =1:numel(OverlayArray)
        LegendName{NumofOverlay} = char(gui_erp_waviewer.ERPwaviewer.Legend.data{NumofOverlay,2});
    end
    FontLegValue =  gui_erp_waviewer.ERPwaviewer.Legend.font;
    FontLeg = fonttype{FontLegValue};
    FontSizeLeg =  gui_erp_waviewer.ERPwaviewer.Legend.fontsize;
    TextcolorLeg = gui_erp_waviewer.ERPwaviewer.Legend.textcolor;
    Legcolumns = gui_erp_waviewer.ERPwaviewer.Legend.columns;
catch
end

%
%%--------------Chan/Bin/ERPset Labels, font, and fontsize-----------------
CBELabels = [50 100 1];
CBEFont = 'Helvetica';
CBEFontsize=10;
try
    if gui_erp_waviewer.ERPwaviewer.chanbinsetlabel.location.no ==1
        CBELabels = [];
        CBEFont = '';
        CBEFontsize=[];
    elseif gui_erp_waviewer.ERPwaviewer.chanbinsetlabel.location.custom==1
        CBELabels(1) = gui_erp_waviewer.ERPwaviewer.chanbinsetlabel.location.xperc;
        CBELabels(2) = gui_erp_waviewer.ERPwaviewer.chanbinsetlabel.location.yperc;
        CBELabels(3) = gui_erp_waviewer.ERPwaviewer.chanbinsetlabel.location.center;
        FontlabelValue =  gui_erp_waviewer.ERPwaviewer.chanbinsetlabel.font;
        CBEFont = fonttype{FontlabelValue};
        CBEFontsize=gui_erp_waviewer.ERPwaviewer.chanbinsetlabel.fontsize;
    end
catch
    
end

%%label textcolor
CBETcolor = [0 0 0];
try
    xlabelFontcolorValue =gui_erp_waviewer.ERPwaviewer.chanbinsetlabel.textcolor;
    switch xlabelFontcolorValue
        case 1
            CBETcolor  = [0 0 0];%% black
        case 2
            CBETcolor  = [1 0 0];%% red
        case 3
            CBETcolor = [0 0 1];%% blue
        case 4
            CBETcolor = [0 1 0];%%green
        case 5
            CBETcolor  = [0.9290 0.6940 0.1250];%%orange
        case 6
            CBETcolor  = [0 1 1];%%cyan
        case 7
            CBETcolor = [1 0 1];%%magenla
        otherwise
            CBETcolor = [0 0 0];%%black
    end
catch
end

%
%%-----------------------------Polarity------------------------------------
PolarityWave = 1;
try
    PolarityWave = gui_erp_waviewer.ERPwaviewer.polarity;
catch
end

%
%%-----------------------------standard error------------------------------
Standerr = 0;
try
    StanderrValue = gui_erp_waviewer.ERPwaviewer.SEM.error;
    if ~isnumeric(StanderrValue) || isempty(StanderrValue)
        Standerr = 0;
    else
        Standerr = StanderrValue;
    end
catch
end
if gui_erp_waviewer.ERPwaviewer.SEM.active==0
    Standerr = 0;
else
    if Standerr<=0
        Standerr=1;
    end
end
%
%%-------------------------------Transparency------------------------------
Transparency = 0;
try
    TransparencyValue = gui_erp_waviewer.ERPwaviewer.SEM.trans;
    if ~isnumeric(TransparencyValue) || isempty(TransparencyValue)
        Transparency = 0;
    else
        Transparency = TransparencyValue;
    end
catch
end

if gui_erp_waviewer.ERPwaviewer.SEM.active==0
    Transparency = 0;
    
else
    if Transparency<=0
        Transparency=0.2;
    end
end

%
%%------------------------------Grid space---------------------------------
Gridspace = [1 10;1 10];
try
    Layoutop = gui_erp_waviewer.ERPwaviewer.plot_org.gridlayout.op;
    if Layoutop~=1
        %%for rows
        rowgapop = gui_erp_waviewer.ERPwaviewer.plot_org.gridlayout.rowgap.GTPOP;
        if rowgapop%%gap
            Gridspace(1,1) = 1;
            rowgapValue =  gui_erp_waviewer.ERPwaviewer.plot_org.gridlayout.rowgap.GTPValue;
            if isempty(rowgapValue) || numel(rowgapValue)~=1 || rowgapValue<=0
                rowgapValue = 10;
            end
            Gridspace(1,2) = rowgapValue;
        else%%overlay
            Gridspace(1,1) = 2;
            rowoverlayValue =  gui_erp_waviewer.ERPwaviewer.plot_org.gridlayout.rowgap.OverlayValue;
            if isempty(rowoverlayValue) || numel(rowoverlayValue)~=1 || rowoverlayValue<=0 ||  rowoverlayValue>100
                rowoverlayValue = 40;
            end
            Gridspace(1,2) = rowoverlayValue;
        end
        %%for columns
        columngapop = gui_erp_waviewer.ERPwaviewer.plot_org.gridlayout.columngap.GTPOP;
        if columngapop%%gap
            Gridspace(2,1) = 1;
            columngapValue =  gui_erp_waviewer.ERPwaviewer.plot_org.gridlayout.columngap.GTPValue;
            if isempty(columngapValue) || numel(columngapValue)~=1 || columngapValue<=0
                columngapValue = 10;
            end
            Gridspace(2,2) = columngapValue;
        else%% overlay
            Gridspace(2,1) = 2;
            columnoverlayValue =  gui_erp_waviewer.ERPwaviewer.plot_org.gridlayout.columngap.OverlayValue;
            if isempty(columnoverlayValue) || numel(columnoverlayValue)~=1 || columnoverlayValue<=0 ||  columnoverlayValue>100
                columnoverlayValue = 20;
            end
            Gridspace(2,2) = columnoverlayValue;
        end
    end
catch
end


%
%%-----------------------------Baseline correction-------------------------
Blc = 'none';
try
    Blc = gui_erp_waviewer.ERPwaviewer.baselinecorr;
catch
end

%
%%---------------------------------x axis----------------------------------
timeRange = [];%%time range is used to plot the wave(s)
try
    timeRange = gui_erp_waviewer.ERPwaviewer.xaxis.timerange;
catch
end
timeticks = [];
try
    timeticks = gui_erp_waviewer.ERPwaviewer.xaxis.timeticks;
catch
end
if ~isempty(timeRange) && ~isempty(timeticks) %%check xticks
    try
        count =0;
        XtickDis =[];
        for Numofxtick = 1:numel(timeticks)
            if timeticks(Numofxtick) < timeRange(1) || timeticks(Numofxtick) > timeRange(end)
                count = count+1;
                XtickDis(count) =  Numofxtick;
            end
        end
        timeticks(XtickDis) = [];
    catch
    end
end
xticklabel = 'on';
try
    xticklabelValue = gui_erp_waviewer.ERPwaviewer.xaxis.label;
    if xticklabelValue==0
        xticklabel = 'off';
    else
        xticklabel = 'on';
    end
catch
end

xlabelFont = 'Helvetica';
try
    xFontlabelValue =  gui_erp_waviewer.ERPwaviewer.xaxis.font;
    xlabelFont = fonttype{xFontlabelValue};
catch
end


xlabelFontsize = 10;
try
    xlabelFontsize =gui_erp_waviewer.ERPwaviewer.xaxis.fontsize;
catch
end

xlabelFontcolor = [0 0 0];
try
    xlabelFontcolorValue =gui_erp_waviewer.ERPwaviewer.xaxis.fontcolor;
    switch xlabelFontcolorValue
        case 1
            xlabelFontcolor  = [0 0 0];%% black
        case 2
            xlabelFontcolor  = [1 0 0];%% red
        case 3
            xlabelFontcolor = [0 0 1];%% blue
        case 4
            xlabelFontcolor = [0 1 0];%%green
        case 5
            xlabelFontcolor  = [0.9290 0.6940 0.1250];%%orange
        case 6
            xlabelFontcolor  = [0 1 1];%%cyan
        case 7
            xlabelFontcolor = [1 0 1];%%magenla
        otherwise
            xlabelFontcolor = [0 0 0];%%black
    end
catch
end
Xunits = 'on';
try
    XunitsValue =  gui_erp_waviewer.ERPwaviewer.xaxis.units;
    if XunitsValue==1
        Xunits = 'on';
    else
        Xunits = 'off';
    end
catch
    
end

%%Minorticks for x axis
try
    MinorticksX(1) =  gui_erp_waviewer.ERPwaviewer.xaxis.tminor.disp;
    MinorticksX(2:numel(gui_erp_waviewer.ERPwaviewer.xaxis.tminor.step)+1) = gui_erp_waviewer.ERPwaviewer.xaxis.tminor.step;
catch
    MinorticksX = [0];%% off
end

%%Decimals for x ticklabels
Xtickprecision = 0;
try
    Xtickprecision= gui_erp_waviewer.ERPwaviewer.xaxis.tickdecimals;
catch
    Xtickprecision = 0;
end

if Xtickprecision<0 || Xtickprecision>6
    Xtickprecision = 0;
end

%%display x ticks with millisecond or second?
XdispFlag = 1;%% in millisecond
try
    XdispFlag = gui_erp_waviewer.ERPwaviewer.xaxis.tdis;
catch
end

%%%--------------------------------y axis----------------------------------
Yscales = [];
try
    Yscales = gui_erp_waviewer.ERPwaviewer.yaxis.scales ;
catch
end
Yticks = [];
try
    Yticks = gui_erp_waviewer.ERPwaviewer.yaxis.ticks;
catch
end
if ~isempty(Yscales) && ~isempty(Yticks) %%check Yticks
    try
        count =0;
        ytickDis =[];
        for Numofytick = 1:numel(Yticks)
            if Yticks(Numofytick) < Yscales(1) || Yticks(Numofytick) > Yscales(end)
                count = count+1;
                ytickDis(count) =  Numofytick;
            end
        end
        Yticks(ytickDis) = [];
    catch
    end
end

yticklabel = 'on';
try
    yticklabelValue = gui_erp_waviewer.ERPwaviewer.yaxis.label;
    if yticklabelValue==0
        yticklabel = 'off';
    else
        yticklabel = 'on';
    end
catch
end

YlabelFont = 'Helvetica';
try
    YFontlabelValue =  gui_erp_waviewer.ERPwaviewer.yaxis.font;
    YlabelFont = fonttype{YFontlabelValue};
catch
end

YlabelFontsize = 12;
try
    YlabelFontsize =gui_erp_waviewer.ERPwaviewer.yaxis.fontsize;
catch
end

ylabelFontcolor = [0 0 0];
try
    ylabelFontcolorValue =gui_erp_waviewer.ERPwaviewer.yaxis.fontcolor;
    switch ylabelFontcolorValue
        case 1
            ylabelFontcolor  = [0 0 0];%% black
        case 2
            ylabelFontcolor  = [1 0 0];%% red
        case 3
            ylabelFontcolor = [0 0 1];%% blue
        case 4
            ylabelFontcolor = [0 1 0];%%green
        case 5
            ylabelFontcolor  = [0.9290 0.6940 0.1250];%%orange
        case 6
            ylabelFontcolor  = [0 1 1];%%cyan
        case 7
            ylabelFontcolor = [1 0 1];%%magenla
        otherwise
            ylabelFontcolor = [0 0 0];%%black
    end
catch
end

yunits = 'on';
try
    yunitsValue =  gui_erp_waviewer.ERPwaviewer.yaxis.units;
    if yunitsValue==1
        yunits = 'on';
    else
        yunits = 'off';
    end
catch
    
end

Ytickprecision = 1;
try
    Ytickprecision =  gui_erp_waviewer.ERPwaviewer.yaxis.tickdecimals;
catch
    Ytickprecision = 1;
end


%%Minorticks for y axis
try
    MinorticksY(1) =  gui_erp_waviewer.ERPwaviewer.yaxis.yminor.disp;
    MinorticksY(2:numel(gui_erp_waviewer.ERPwaviewer.yaxis.yminor.step)+1) = gui_erp_waviewer.ERPwaviewer.yaxis.yminor.step;
catch
    MinorticksY = [0];%% off
end



%%Background color of figure
figbgdColor = [1 1 1];
try
    figbgdColor =  gui_erp_waviewer.ERPwaviewer.figbackgdcolor;
catch
    figbgdColor = [1 1 1];
end

if ~isnumeric(figbgdColor) || isempty(figbgdColor) || numel(figbgdColor)~=3 || max(figbgdColor)>1 ||  min(figbgdColor)<0
    figbgdColor =[1 1 1];
end


PagesIndex = gui_erp_waviewer.ERPwaviewer.PageIndex;
if isempty(PagesIndex)
    PagesIndex=1;
end

try
    ScreenPos =  get( groot, 'Screensize' );
catch
    ScreenPos =  get( 0, 'Screensize' );
end
FigOutpos = [];
try
    FigOutpos=gui_erp_waviewer.ERPwaviewer.FigOutpos;
    FigOutpos = [ScreenPos(3)*FigOutpos(1)/100,ScreenPos(4)*FigOutpos(2)/100];
catch
    FigOutpos = ScreenPos(3:4)*3/4;
end


%%Main function
if ~isempty(FigureName)
    [ALLERP, erpcom] = pop_plotERPwaviewer(ALLERPIN,PagesIndex,ERPsetArray, binArray, chanArray,...
        'PLOTORG',PLOTORG,'GridposArray',GridposArray,'LabelsName',LabelsName, 'Blc', Blc,'Box',plotBox,'LineColor',LineColorspec,'LineStyle',LineStylespec,...
        'LineMarker',LineMarkerspec,'LineWidth',LineWidthspec,'LegendName',LegendName,'LegendFont',FontLeg,'LegendFontsize',FontSizeLeg,...
        'Labeloc',CBELabels,'Labelfont',CBEFont,'Labelfontsize',CBEFontsize,'YDir',PolarityWave,'SEM',Standerr,'Transparency', Transparency,...
        'GridSpace',Gridspace,'TimeRange',timeRange,'Xticks',timeticks,'Xticklabel',xticklabel,'Xlabelfont',xlabelFont,'Xlabelfontsize',xlabelFontsize,...
        'Xlabelcolor',xlabelFontcolor,'Xunits',Xunits,'MinorTicksX',MinorticksX,...
        'YScales',Yscales,'Yticks',Yticks,'Yticklabel',yticklabel,'Ylabelfont',YlabelFont,'Ylabelfontsize',YlabelFontsize,...
        'Ylabelcolor',ylabelFontcolor,'Yunits',yunits,'MinorTicksY',MinorticksY,'LegtextColor',TextcolorLeg,'Legcolumns',Legcolumns,...
        'FigureName',FigureName,'FigbgColor',figbgdColor,'Labelcolor',CBETcolor,'Ytickdecimal',Ytickprecision,'Xtickdecimal',Xtickprecision,'XtickdisFlag',XdispFlag,...
        'FigOutpos',FigOutpos,'History', History);%
else
    OutputViewerpar{1} =  ALLERPIN;
    OutputViewerpar{2} =  PagesIndex;
    OutputViewerpar{3} =  PLOTORG;
    OutputViewerpar{4} =  binArray;
    OutputViewerpar{5} =  chanArray;
    OutputViewerpar{6} =  GridposArray;
    OutputViewerpar{7} =  LabelsName;
    OutputViewerpar{8} =  Blc;
    OutputViewerpar{9} =  plotBox;
    OutputViewerpar{10} =  LineColorspec;
    OutputViewerpar{11} =  LineStylespec;
    OutputViewerpar{12} =  LineMarkerspec;
    OutputViewerpar{13} =  LineWidthspec;
    OutputViewerpar{14} =  LegendName;
    OutputViewerpar{15} =  FontLeg;
    OutputViewerpar{16} =  FontSizeLeg;
    OutputViewerpar{17} =  CBELabels;
    OutputViewerpar{18} =  CBEFont;
    OutputViewerpar{19} =  CBEFontsize;
    OutputViewerpar{20} =  PolarityWave;
    OutputViewerpar{21} =  Standerr;
    OutputViewerpar{22} =  Transparency;
    OutputViewerpar{23} =  Gridspace;
    OutputViewerpar{24} =  timeRange;
    OutputViewerpar{25} =  timeticks;
    OutputViewerpar{26} =  xticklabel;
    OutputViewerpar{27} =  xlabelFont;
    OutputViewerpar{28} =  xlabelFontsize;
    OutputViewerpar{29} =  xlabelFontcolor;
    OutputViewerpar{30} =  Xunits;
    OutputViewerpar{31} =  MinorticksX;
    OutputViewerpar{32} =  Yscales;
    OutputViewerpar{33} =  Yticks;
    OutputViewerpar{34} =  yticklabel;
    OutputViewerpar{35} =  YlabelFont;
    OutputViewerpar{36} =  YlabelFontsize;
    OutputViewerpar{37} =  ylabelFontcolor;
    OutputViewerpar{38} =  yunits;
    OutputViewerpar{39} =  MinorticksY;
    OutputViewerpar{40} =  TextcolorLeg;
    OutputViewerpar{41} = Legcolumns;
    OutputViewerpar{42} =  FigureName;
    OutputViewerpar{43} =ERPsetArray;
    OutputViewerpar{44} =CBETcolor;
    OutputViewerpar{45} = Ytickprecision;
    OutputViewerpar{46} = Xtickprecision;
    OutputViewerpar{47} = XdispFlag;
    OutputViewerpar{48} =LabelsdiffFlag;
end

end