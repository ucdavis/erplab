%%this function is used to call back the parameters for plotting mvpc wave

% *** This function is part of EStudio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2024


function OutputViewerparerp = f_preparms_decodetab(MVPC,matlabfig,History,FigureName)
global observe_DECODE;
global EStudio_gui_erp_totl;

OutputViewerparerp = '';
if nargin<1
    help f_preparms_decodetab();
    return
end
if isempty(MVPC)
    disp('f_preparms_decodetab(): MVPC is empty');
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

%%---------------Selected MVPC sets------------------
MVPCArray = estudioworkingmemory('MVPCArray');
if isempty(MVPCArray) || (~isempty(MVPCArray) && any(MVPCArray(:)>length(observe_DECODE.ALLMVPC)))
    MVPCArray = length(observe_DECODE.ALLMVPC);
    observe_DECODE.MVPC = observe_DECODE.ALLMVPC(end);
    observe_DECODE.CURRENTMVPC = MVPCArray;
    estudioworkingmemory('MVPCArray',MVPCArray);
end
ALLMVPC = observe_DECODE.ALLMVPC;
%
%%Plot setting
MVPC_plotset_pars = estudioworkingmemory('MVPC_plotset_pars');

%
%%time range
timeStartdef = MVPC.times(1);
timEnddef = MVPC.times(end);
[def xstepdef]= default_time_ticks_decode(MVPC, [MVPC.times(1),MVPC.times(end)]);

try timerange = MVPC_plotset_pars{2}; catch timerange =[timeStartdef,timEnddef]; end
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

try timet_auto = MVPC_plotset_pars{1}; catch timet_auto=1; end
if isempty(timet_auto) || numel(timet_auto)~=1 || (timet_auto~=0 && timet_auto~=1)
    timet_auto=1;
end
if timeStart> timEnd || timet_auto==1
    timEnd = timEnddef;
    timeStart = timeStartdef;
end


%%----------xtick step--------
try timetick_auto =  MVPC_plotset_pars{3}; catch timetick_auto=1;end
if isempty(timetick_auto) || numel(timetick_auto)~=1 || (timetick_auto~=0 && timetick_auto~=1)
    timetick_auto=1;
end

try xtickstep = MVPC_plotset_pars{4}; catch xtickstep = xstepdef; end
if isempty(xtickstep) || numel(xtickstep)~=1 || any(xtickstep<=0) || xtickstep > (timEnd-timeStart) 
    xtickstep = xstepdef;
end

timeRange = [timeStart,timEnd];
[timeticksdef stepX]= default_time_ticks_decode(MVPC, timeRange);
timeticksdef = str2num(char(timeticksdef));
qtimeRangdef = round(timeRange/100)*100;
qXticks = xtickstep+qtimeRangdef(1);
for ii=1:10000
    xtickcheck = qXticks(end)+xtickstep;
    if xtickcheck>timeRange(2)
        break;
    else
        qXticks(numel(qXticks)+1) =xtickcheck;
    end
end
if isempty(qXticks)%%|| stepX==xtickstep
    qXticks =  timeticksdef;
end


%%Precision
try Xtickdecimal=MVPC_plotset_pars{5};catch Xtickdecimal=1; end
Xtickdecimal =Xtickdecimal-1;
if isempty(Xtickdecimal) || numel(Xtickdecimal)~=1 || any(Xtickdecimal(:)<0)
    Xtickdecimal=0;
end

%%
try Xlabelfontflg = MVPC_plotset_pars{6} ; catch Xlabelfontflg=1; end
if isempty(Xlabelfontflg) || numel(Xlabelfontflg)~=1 || any(Xlabelfontflg(:)>5)
    Xlabelfontflg=1;
end
fonttype = {'Courier','Geneva','Helvetica','Monaco','Times'};

fontsizes  = str2double({'4','6','8','10','12','14','16','18','20','24','28','32','36',...
    '40','50','60','70','80','90','100'});

Xlabelfont = fonttype{Xlabelfontflg};
%%font size
try Xlabelfontsize = MVPC_plotset_pars{7};  catch Xlabelfontsize=5;  end
if isempty(Xlabelfontsize) || numel(Xlabelfontsize)~=1 || any(Xlabelfontsize(:)>20)
    Xlabelfontsize=5;
end
Xlabelfontsize = fontsizes(Xlabelfontsize);

%%text color for x axis
try XlabelcolorFlag = MVPC_plotset_pars{8}; catch  XlabelcolorFlag=1; end
if isempty(XlabelcolorFlag) || numel(XlabelcolorFlag)~=1 || any(XlabelcolorFlag(:)>7)
    XlabelcolorFlag=1;
end
switch XlabelcolorFlag
    case 2
        Xlabelcolor  = [1 0 0];%% red
    case 3
        Xlabelcolor = [0 0 1];%% blue
    case 4
        Xlabelcolor = [0 1 0];%%green
    case 5
        Xlabelcolor  = [0.9290 0.6940 0.1250];%%orange
    case 6
        Xlabelcolor  = [0 1 1];%%cyan
    case 7
        Xlabelcolor = [1 0 1];%%magenl
    otherwise
        Xlabelcolor = [0 0 0];%%black
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%-----------------------y axis--------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[def, minydef, maxydef] = default_amp_ticks_decode(observe_DECODE.ALLMVPC(MVPCArray));
if ~isempty(minydef) && ~isempty(maxydef)
    if minydef==maxydef
        minydef=0;
        maxydef=1;
    end
elseif isempty(minydef) || isempty(maxydef)
    minydef=0;
    maxydef=1;
end
%%y scale
try yscale_auto= MVPC_plotset_pars{9}; catch yscale_auto=1; end
if isempty(yscale_auto) || numel(yscale_auto)~=1 || (yscale_auto~=0 && yscale_auto~=1)
    yscale_auto=1;
end

try yscale = MVPC_plotset_pars{10};catch yscale= [minydef,maxydef]; end
if isempty(yscale) || numel(yscale)~=2 || yscale_auto==1
    yscale= [minydef,maxydef];
end


defyticks = default_amp_ticks_viewer(yscale);
if ~isempty(defyticks)
    defyticks = str2num(defyticks);
else
    defyticks = [];
end
if ~isempty(defyticks) && numel(defyticks)>=2
    ytickstepdef = min(diff(defyticks));
else
    ytickstepdef = floor((yscale(2)-yscale(1))/2);
end
try yscale_step = MVPC_plotset_pars{12};catch yscale_step=ytickstepdef;  end
try ytick_auto = MVPC_plotset_pars{11}; catch   ytick_auto=1;end
if isempty(yscale_step) || numel(yscale_step)~=1 || any(yscale_step<=0) || ytick_auto==1
    yscale_step = ytickstepdef;
end

Yticks = [];
if yscale(2)<=0 || yscale(1)>=0
    Yticks = yscale(1);
    for ii=1:10000
        ytickcheck = Yticks(end)+yscale_step;
        if ytickcheck>yscale(2)
            break;
        else
            Yticks(numel(Yticks)+1) =ytickcheck;
        end
    end
elseif yscale(1)<0  && yscale(2)>0
    Yticks = 0;
    for ii=1:10000
        ytickcheck = Yticks(1)-yscale_step;
        if ytickcheck<yscale(1)
            break;
        else
            Yticks = [ytickcheck,Yticks];
        end
    end
    for ii=1:10000
        ytickcheck = Yticks(end)+yscale_step;
        if ytickcheck>yscale(2)
            break;
        else
            Yticks = [Yticks,ytickcheck];
        end
    end
else
    Yticks = yscale;
end
if isempty(Yticks) || numel(Yticks)==1
    Yticks = yscale;
end

%%precision for y axis
try Ytickdecimal = MVPC_plotset_pars{13};catch Ytickdecimal=1; end
if isempty(Ytickdecimal) || numel(Ytickdecimal)~=1 || any(Ytickdecimal(:)<0)
    Ytickdecimal=1;
end

%%font for y axis
try YlabelfontFlag = MVPC_plotset_pars{14}; catch YlabelfontFlag=1; end
if isempty(YlabelfontFlag) || numel(YlabelfontFlag)~=1 || any(YlabelfontFlag(:)>5)
    YlabelfontFlag=1;
end
Ylabelfont = fonttype{YlabelfontFlag};

%%font size for y axis
try  Ylabelfontsize = MVPC_plotset_pars{15};  catch Ylabelfontsize=5;  end;
if isempty(Ylabelfontsize) || numel(Ylabelfontsize)~=1 || any(Ylabelfontsize(:)>20)
    Ylabelfontsize=5;
end
Ylabelfontsize = fontsizes(Ylabelfontsize);
%%text color for  y axis
try  YlabelcolorFlag = MVPC_plotset_pars{16};  catch YlabelcolorFlag=1;  end

if isempty(YlabelcolorFlag) || numel(YlabelcolorFlag)~=1 || any(YlabelcolorFlag(:)>7)
    YlabelcolorFlag=1;
end
switch YlabelcolorFlag
    case 1
        Ylabelcolor  = [0 0 0];%% black
    case 2
        Ylabelcolor  = [1 0 0];%% red
    case 3
        Ylabelcolor = [0 0 1];%% blue
    case 4
        Ylabelcolor = [0 1 0];%%green
    case 5
        Ylabelcolor  = [0.9290 0.6940 0.1250];%%orange
    case 6
        Ylabelcolor  = [0 1 1];%%cyan
    case 7
        Ylabelcolor = [1 0 1];%%magenl
    otherwise
        Ylabelcolor = [0 0 0];%%black
end

%%-----------------------standard error of mean----------------------------
try SEMValue = MVPC_plotset_pars{17};catch  SEMValue = [0 0 0];end
try SEMFlag =SEMValue(1); catch SEMFlag=0; end
if isempty(SEMFlag) || (SEMFlag~=0 && SEMFlag~=1)
    SEMFlag=0;
end
if SEMFlag==1
    try Standerr = SEMValue(2)-1; catch Standerr=0; end
    if isempty(Standerr) || numel(Standerr)~=1 || any(Standerr<0) || any(Standerr>10)
        Standerr=0;
    end
    try Transparency = SEMValue(3); catch Transparency=0.2; end
    if isempty(Transparency) || numel(Transparency)~=1 || any(Transparency<0) || any(Transparency>1)
        Transparency=0.2;
    end
else
    Standerr=0;
    Transparency=0;
end

try ChanceLevel = MVPC_plotset_pars{18};catch  ChanceLevel=1;end
if isempty(ChanceLevel) || numel(ChanceLevel)~=1 || (ChanceLevel~=0 && ChanceLevel~=1)
    ChanceLevel=1;
end

%%--------------Settings for lines-------------------
MVPC_lineslegendops = estudioworkingmemory('MVPC_lineslegendops');
[serror, msgwrng] = f_checkmvpc( observe_DECODE.ALLMVPC,MVPCArray);
if serror==1
    OverlayArray=1;
else
    OverlayArray= MVPCArray;
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
try Lineparas = MVPC_lineslegendops{1};catch Lineparas = []; end
try lineauto = Lineparas{1}; catch lineauto=1;end
if isempty(lineauto) || numel(lineauto)~=1 || (lineauto~=0&& lineauto~=1)
    lineauto=1;
end
try
    LineData = Lineparas{2};
    if lineauto
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
    [lineNameStr,linecolors,linetypes,linewidths,~,~,~,linecolorsrgb] = f_get_lineset_ERPviewer();
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

%%setting for legends
try legendparas = MVPC_lineslegendops{2};catch legendparas = []; end

try legauto =legendparas{1};catch  legauto=1;end
if isempty(legauto) ||  numel(legauto)~=1 || (legauto~=0 && legauto~=1)
    legauto =1;
end
if legauto==1
    FontLeg = 'Helvetica';
    TextcolorLeg=1;
    Legcolumns = ceil(sqrt(OverlayArray));
    FontSizeLeg = 12;
else
    try fontnames = legendparas{2};catch fontnames = 'Helvetica';end
    [~,IA] =ismember_bc2(fontnames,fonttype);
    if IA==0
        FontLeg = 'Helvetica';
    else
        FontLeg=fonttype{IA};
    end
    
    try fontsizenames = legendparas{3};catch fontsizenames = '12';end
    fontsizenames = str2num(fontsizenames);
    if isempty(fontsizenames) || numel(fontsizenames)~=1 || any(fontsizenames(:)<1)
        fontsizenames=12;
    end
    [~,IA1] =ismember_bc2(fontsizenames,fontsizes);
    if IA1==0
        FontSizeLeg = 12;
    else
        FontSizeLeg = fontsizes(IA1);
    end
    for Numoflegend = 1:100
        columnStr(Numoflegend) = Numoflegend;
    end
    try columnsnum = legendparas{4};catch columnsnum = '2';end
    columnsnum = str2num(columnsnum);
    if isempty(columnsnum) || numel(columnsnum)~=1 || any(columnsnum(:)<1)
        columnsnum=2;
    end
    [~,IA2] =ismember_bc2(columnsnum,columnStr);
    if IA1==0
        Legcolumns = ceil(sqrt(OverlayArray));
    else
        Legcolumns = columnStr(IA2);
    end
    try TextcolorLeg= double(legendparas{5});catch TextcolorLeg = 1;end
    if isempty(TextcolorLeg) || numel(TextcolorLeg)~=1 || (TextcolorLeg~=0 && TextcolorLeg~=1)
        TextcolorLeg = 1;
    end
end


figSize = estudioworkingmemory('egfigsize');
if isempty(figSize)
    figSize = [];
end





% CBELabels = [0 100 1];
% Legcolumns = ceil(sqrt(length(LegendName)));


new_pos = estudioworkingmemory('EStudioScreenPos');
if isempty(new_pos) || numel(new_pos)~=2
    new_pos = [75,75];
    estudioworkingmemory('EStudioScreenPos',new_pos);
end
try
    ScreenPos =  get( groot, 'Screensize' );
catch
    ScreenPos =  get( 0, 'Screensize' );
end
 ScreenPos = EStudio_gui_erp_totl.ScreenPos;
 
 
FigOutpos = [ScreenPos(3)*new_pos(1)/100,ScreenPos(4)*new_pos(2)/100]*8/9;
% if isempty(FigureName)
%     FigureName = MVPC.mvpcname;
% end


if matlabfig==1
    [ALLMVPC, mvpcom] = pop_plotmvpcset(ALLMVPC,'MVPCArray',MVPCArray,'timeRange',timeRange,'Xticks',qXticks,'Xtickdecimal',Xtickdecimal,...
        'Xlabelfont',Xlabelfont,'Xlabelfontsize',Xlabelfontsize,'Xlabelcolor',Xlabelcolor,'YScales',yscale,'Yticks',Yticks,...
        'Ytickdecimal',Ytickdecimal,'Ylabelfont',Ylabelfont,'Ylabelfontsize',Ylabelfontsize,'Ylabelcolor',Ylabelcolor,'Standerr',Standerr,...
        'Transparency',Transparency,'LineColorspec',LineColorspec,'LineStylespec',LineStylespec,'LineMarkerspec',LineMarkerspec,...
        'LineWidthspec',LineWidthspec,'FontLeg',FontLeg,'TextcolorLeg',TextcolorLeg,'Legcolumns',Legcolumns,'FontSizeLeg',FontSizeLeg,...
        'chanLevel',ChanceLevel,'figureName',FigureName,'FigOutpos',FigOutpos,'History', History);
else
    OutputViewerparerp{1} =  MVPCArray;
    OutputViewerparerp{2} =timeRange;
    OutputViewerparerp{3} =qXticks;
    OutputViewerparerp{4} =Xtickdecimal;
    OutputViewerparerp{5} =Xlabelfont;
    OutputViewerparerp{6} =Xlabelfontsize;
    OutputViewerparerp{7} =Xlabelcolor;
    OutputViewerparerp{8} =yscale;
    OutputViewerparerp{9} =Yticks;
    OutputViewerparerp{10} =Ytickdecimal;
    OutputViewerparerp{11} =Ylabelfont;
    OutputViewerparerp{12} =Ylabelfontsize;
    OutputViewerparerp{13} =Ylabelcolor;
    OutputViewerparerp{14} =Standerr;
    OutputViewerparerp{15} =Transparency;
    OutputViewerparerp{16} =LineColorspec;
    OutputViewerparerp{17} =LineStylespec;
    OutputViewerparerp{18} =LineMarkerspec;
    OutputViewerparerp{19} =LineWidthspec;
    OutputViewerparerp{20} =FontLeg;
    OutputViewerparerp{21} =TextcolorLeg;
    OutputViewerparerp{22} =Legcolumns;
    OutputViewerparerp{23} =FontSizeLeg;
    OutputViewerparerp{24} =ChanceLevel;
end

end
