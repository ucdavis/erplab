%Ths is part of pop_plotERPwaviewer.m
% PURPOSE:  It use to update the parameters based on the all saved
% paramerters or

%



function [ERPwaviewerIN, ErroMessg] = f_erpwave_viewer_update_parameter(Parameterfile,parse_param)


ErroMessg = '';
ERPwaviewerIN = [];
if nargin < 1 || nargin>2
    ERPwaviewerIN = [];
    help f_erpwave_viewer_update_parameter
    return;
end

if nargin < 2
    ALLERPdef = [];
    PagesIndexdef = [];
    ERPsetArraydef = [];
    binArraydef = [];
    chanArraydef = [];
else
    ALLERPdef= parse_param.Results.ALLERP;
    PagesIndexdef = parse_param.Results.CURRENTPLOT;
    ERPsetArraydef = parse_param.Results.ERPsetArray;
    binArraydef = parse_param.Results.binArray;
    chanArraydef = parse_param.Results.chanArray;
end


try
    ERPwaviewerIN =importdata(Parameterfile);
catch
    ErroMessg = strcat('f_erpwave_viewer_update_parameter() error: Cannot import "Parameterfile".');
    beep;
    disp(ErroMessg);
    return;
end

ALLERPIN = ERPwaviewerIN.ALLERP;

if isempty(ALLERPIN)&& isempty(ALLERPdef)
    ErroMessg = strcat('f_erpwave_viewer_update_parameter() error: ALLERP is empty in both "Parameterfile" and "parse_param".');
    beep;
    disp(ErroMessg);
    return;
end

%
%%bin array and channel array
binArray = ERPwaviewerIN.bin;
chanArray = ERPwaviewerIN.chan;
ERPsetArray = ERPwaviewerIN.SelectERPIdx;

if ~isempty(ALLERPdef)
    ALLERPIN = ALLERPdef;
    if isempty(ERPsetArraydef) || min(ERPsetArraydef)<=0 || max(ERPsetArraydef)>length(ALLERPdef)
        if isempty(ERPsetArray) || min(ERPsetArray)<=0 || max(ERPsetArray)>length(ALLERPdef)
            ERPsetArray = length(ALLERPdef);
        end
    else
        ERPsetArray = ERPsetArraydef;
    end
    [chanStrdef,binStrdef,diff_mark] = f_geterpschanbin(ALLERPdef,ERPsetArray);
    if ~isempty(chanArraydef) && min(chanArraydef)>0 && max(chanArraydef)<= length(chanStrdef)
        chanArray = chanArraydef;
    else
        if isempty(chanArray) ||  min(chanArray)<=0 || max(chanArray) > length(chanStrdef)
            chanArray = [1:length(chanStrdef)];
        end
    end
    
    if ~isempty(binArraydef) && min(binArraydef)>0 && max(binArraydef)<= length(binStrdef)
        binArray = binArraydef;
    else
        if isempty(binArray) || min(binArray)<=0 || max(binArray)> length(binStrdef)
            binArray = [1:length(binStrdef)];
        end
    end
    
else
    ALLERPIN = ERPwaviewerIN.ALLERP;
    %%checking the indices of the selected ERPsets
    if isempty(ERPsetArraydef) || min(ERPsetArraydef)<=0 || max(ERPsetArraydef)>length(ALLERPIN)
        if isempty(ERPsetArray) || min(ERPsetArray)<=0 || max(ERPsetArray)>length(ALLERPIN)
            ERPsetArray = length(ALLERPIN);
        end
    else
        ERPsetArray = ERPsetArraydef;
    end
    [chanStrdef,binStrdef,diff_mark] = f_geterpschanbin(ALLERPIN,ERPsetArray);
    if ~isempty(chanArraydef) && min(chanArraydef)>0 && max(chanArraydef)<= length(chanStrdef)
        chanArray = chanArraydef;
    else
        if isempty(chanArray) ||  min(chanArray)<=0 || max(chanArray) > length(chanStrdef)
            chanArray = [1:length(chanStrdef)];
        end
    end
    
    if ~isempty(binArraydef) && min(binArraydef)>0 && max(binArraydef)<= length(binStrdef)
        binArray = binArraydef;
    else
        if isempty(binArray) || min(binArray)<=0 || max(binArray)> length(binStrdef)
            binArray = [1:length(binStrdef)];
        end
    end
end

ERPwaviewerIN.bin=binArray;
ERPwaviewerIN.chan = chanArray;
ERPwaviewerIN.SelectERPIdx = ERPsetArray;
ERPwaviewerIN.ALLERP=ALLERPIN;


ERPIN= ERPwaviewerIN.ERP;
CURRENTERPIN = ERPwaviewerIN.CURRENTERP;

if isempty(CURRENTERPIN) || CURRENTERPIN > length(ALLERPIN) %%checking index of current erpset
    CURRENTERPIN =length(ALLERPIN);
end

ParameterNames = {'ALLERP','CURRENTPLOT','ERPsetArray','binArray','chanArray','PLOTORG','GridposArray',...
    'LabelsName','Blc','Box','LineColor','LineStyle','LineMarker','LineWidth','LegendName','LegendFont',...
    'LegendFontsize','Labeloc','Labelfont','Labelfontsize','YDir','SEM','Transparency','GridSpace','TimeRange', ...
    'Xticks','Xticklabel','Xlabelfont','Xlabelfontsize','Xlabelcolor','Xunits','MinorTicksX','YScales','Yticks',...
    'Yticklabel','Ylabelfont','Ylabelfontsize','Ylabelcolor','Yunits','MinorTicksY','LegtextColor','Legcolumns',...
    'FigureName','FigbgColor','Labelcolor','Ytickdecimal','Xtickdecimal','XtickdisFlag','ErrorMsg','History'};


parse_Results = parse_param.Results;
parseuseDef =  parse_param.UsingDefaults;
parse_paramout= parse_Results;

diffStr = f_setdiffstr(ParameterNames,parseuseDef);
fonttype = {'Courier','Geneva','Helvetica','Monaco','Times'};

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


for ii = 1:length(diffStr)
    [C,IA] = ismember_bc2(diffStr{ii},ParameterNames);
    if C==1 &&  IA<=length(ParameterNames)
        %                 valuedef = getfield(parse_paraDef,parseuseDef{ii});
        %                 parse_paramout = setfield(parse_paramout,parseuseDef{ii},valuedef);
        switch IA
            case 6
                PLOTORG = getfield(parse_paramout,'PLOTORG');
                if numel(unique(PLOTORG))~=3
                    PLOTORG = [1 2 3];
                else
                    if PLOTORG(1)~=1 && PLOTORG(1)~=2 && PLOTORG(1)~=3
                        PLOTORG = [1 2 3];
                    elseif PLOTORG(2)~=1 && PLOTORG(2)~=2 && PLOTORG(2)~=3
                        PLOTORG = [1 2 3];
                    elseif PLOTORG(3)~=1 && PLOTORG(3)~=2 && PLOTORG(3)~=3
                        PLOTORG = [1 2 3];
                    end
                end
                ERPwaviewerIN.plot_org.Grid=PLOTORG(1);
                ERPwaviewerIN.plot_org.Overlay=PLOTORG(2);
                ERPwaviewerIN.plot_org.Pages=PLOTORG(3);
            case 7
                GridposArray = getfield(parse_paramout,'GridposArray');
                %%need to further edit this parameters.
                try
                    PLOTORG(1) = ERPwaviewerIN.plot_org.Grid ;
                    PLOTORG(2) = ERPwaviewerIN.plot_org.Overlay;
                    PLOTORG(3) = ERPwaviewerIN.plot_org.Pages;
                catch
                    PLOTORG = [1 2 3]; %%"Channels" is Grid; "Bins" is Overlay; "ERPsets" is Pages.
                end
                ALLERPIN = ERPwaviewerIN.ALLERP;
                binArray = ERPwaviewerIN.bin;
                chanArray = ERPwaviewerIN.chan;
                ERPsetArray = ERPwaviewerIN.SelectERPIdx;
                [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERPIN,ERPsetArray);
                if isempty(binArray)
                    binArray = [1:length(binStr)];
                end
                
                if isempty(chanArray)
                    chanArray = [1:length(chanStr)];
                end
                
                if isempty(ERPsetArray) || max(ERPsetArray) >length(ALLERPIN)
                    ERPsetArray =length(ALLERPIN);
                end
                if PLOTORG(1) ==1 %% if  the selected Channel is "Grid"
                    plotArray = chanArray;
                    for Numofchan = 1:numel(chanArray)
                        try
                            plotArrayStrdef{Numofchan} = chanStr{plotArray(Numofchan)};
                        catch
                        end
                    end
                elseif PLOTORG(1) == 2 %% if the selected Bin is "Grid"
                    plotArray = binArray;
                    for Numofchan = 1:numel(plotArray)
                        try
                            plotArrayStrdef{Numofchan} = binStr{plotArray(Numofchan)};
                        catch
                        end
                    end
                elseif PLOTORG(1) == 3%% if the selected ERPset is "Grid"
                    plotArray = ERPsetArray;
                    for Numofchan = 1:numel(plotArray)
                        try
                            plotArrayStrdef{Numofchan} = ALLERPIN(plotArray(Numofchan)).erpname;
                        catch
                            plotArrayStrdef{Numofchan} = 'none';
                        end
                    end
                    
                end
                for Numofrow = 1:size(GridposArray,1)
                    for Numofcolumn = 1:size(GridposArray,2)
                        [x_df,y_df] = find([1:numel(plotArray)]==GridposArray(Numofrow,Numofcolumn));
                        if ~isempty(y_df)
                            GridposArrayStr{Numofrow,Numofcolumn} =  char(plotArrayStrdef{y_df});
                        else
                            GridposArrayStr{Numofrow,Numofcolumn} =  'none';
                        end
                    end
                end
                ERPwaviewerIN.plot_org.gridlayout.data = GridposArrayStr;
            case 8
                LabelsNamedef   = getfield(parse_paramout,'LabelsName');
                if ~isempty(LabelsNamedef)
                    %
                    columFormatOld =  ERPwaviewerIN.plot_org.gridlayout.columFormat;
                    for ii = 1:length(columFormatOld)-1
                        try
                            LabelsName{ii} = LabelsNamedef{ii} ;
                        catch
                            LabelsName{ii}  = columFormatOld{ii};
                        end
                    end
                    LabelsName{length(LabelsName)+1} = 'None';
                    GridinforDataOld = ERPwaviewerIN.plot_org.gridlayout.data;
                    [Numrows,Numcolumns] = size(GridinforDataOld);
                    for Numofrow = 1:Numrows
                        for Numofcolumn = 1:Numcolumns
                            SingleStr =  char(GridinforDataOld{Numofrow,Numofcolumn});
                            [C,IA] = ismember_bc2(SingleStr,columFormatOld);
                            if C ==1
                                if IA < length(columFormatOld)
                                    try
                                        GridinforDataOld{Numofrow,Numofcolumn} = char(LabelsName{IA});
                                    catch
                                        GridinforDataOld{Numofrow,Numofcolumn} = char('');
                                    end
                                elseif IA == length(columFormatOld)
                                    GridinforDataOld{Numofrow,Numofcolumn}  = char('None');
                                end
                            else
                                GridinforDataOld{Numofrow,Numofcolumn}  = char('None');
                            end
                        end
                    end
                    ERPwaviewerIN.plot_org.gridlayout.data = GridinforDataOld;
                    ERPwaviewerIN.plot_org.gridlayout.columFormat = LabelsName;
                end
            case 9%%baseline correction
                Blc = getfield(parse_paramout,'Blc');
                if ~isempty(Blc)
                    if length(Blc) ==2
                        if isnumeric(qBlc) && unique(Blc)==2
                            ERPwaviewerIN.baselinecorr = sort(Blc);
                        end
                    else
                        if ischar(Blc)
                            if strcmpi(Blc,'no') || strcmpi(Blc,'none') || strcmpi(Blc,'pre')||strcmpi(Blc,'post')|| strcmpi(Blc,'all')
                                ERPwaviewerIN.baselinecorr = Blc;
                            end
                        end
                    end
                end
                
            case 10
                Box = getfield(parse_paramout,'Box');
                if ~isempty(Box) && numel(Box)==2
                    ERPwaviewerIN.plot_org.gridlayout.rows = Box(1);
                    ERPwaviewerIN.plot_org.gridlayout.columns = Box(2);
                end
            case 11
                LineColor = getfield(parse_paramout,'LineColor');
                %%need to further confirm this
                if ~isempty(LineColor)
                    for ii = 1:length(linecolorsrgb)
                        try
                            lineColor_One = LineColor(ii,:);
                        catch
                            lineColor_One  =str2num(linecolorsrgb{ii});
                        end
                        if ~isempty(lineColor_One)&& numel(lineColor_One)==3 && min(lineColor_One)>=0 && max(lineColor_One)<=1
                            try
                                ERPwaviewerIN.Lines.data{ii,2} = num2str(lineColor_One);
                            catch
                                ERPwaviewerIN.Lines.data{ii,2} = linecolorsrgb{ii};
                            end
                        end
                    end
                    ERPwaviewerIN.Lines.auto =0;
                end
            case 12
                LineStyle = getfield(parse_paramout,'LineStyle');
                if ~isempty(LineStyle)
                    for jj = 1:length(LineStyle)
                        LineStyle_one = LineStyle{jj};
                        if strcmpi(LineStyle_one,'-')
                            ERPwaviewerIN.Lines.data{jj,3} = 'solid';
                        elseif strcmpi(LineStyle_one,'--')
                            ERPwaviewerIN.Lines.data{jj,3} = 'dash';
                        elseif strcmpi(LineStyle_one,':')
                            ERPwaviewerIN.Lines.data{jj,3} = 'dot';
                        elseif strcmpi(LineStyle_one,'-.')
                            ERPwaviewerIN.Lines.data{jj,3} = 'dashdot';
                        else
                            ERPwaviewerIN.Lines.data{jj,3} = 'solid';
                        end
                    end
                end
            case 13
                LineMarker = getfield(parse_paramout,'LineMarker');
                if ~isempty(LineMarker)
                    for ii = 1:length(LineMarker)
                        LineMarker_one = LineMarker{ii};
                        if strcmpi(LineMarker_one,'+')
                            ERPwaviewerIN.Lines.data{jj,3} = 'plus';
                        elseif strcmpi(LineMarker_one,'o')
                            ERPwaviewerIN.Lines.data{jj,3} = 'circle';
                        elseif strcmpi(LineMarker_one,'*')
                            ERPwaviewerIN.Lines.data{jj,3} = 'asterisk';
                        end
                    end
                end
            case 14
                LineWidth = getfield(parse_paramout,'LineWidth');
                if ~isempty(LineWidth)
                    for jj = 1:numel(LineWidth)
                        LineWidth_one = LineWidth(jj);
                        if LineWidth_one<=0
                            LineWidth_one =1;
                        end
                        try
                            ERPwaviewerIN.Lines.data{jj,4}  = LineWidth_one;
                        catch
                            ERPwaviewerIN.Lines.data{jj,4}  = 1;
                        end
                    end
                end
            case 15
                LegendName1 =  getfield(parse_paramout,'LegendName');
                if ~isempty(LegendName1)
                    for ii = 1:100
                        try
                            LegendName{ii,1} = LegendName1{ii};
                        catch
                            LegendName{ii,1} = '';
                        end
                        LegendNamenum(ii,1) =ii;
                    end
                    legendset_str = table(LegendNamenum,LegendName);
                    legendset_str = table2cell(legendset_str);
                    ERPwaviewerIN.Legend.data = legendset_str;
                end
            case 16
                LegendFont = getfield(parse_paramout,'LegendFont');
                if ~isempty(LegendFont)
                    [C1,IA1] = ismember_bc2(LegendFont,fonttype);
                    if C1 ==1
                        ERPwaviewerIN.Legend.font = IA1;
                    else
                        ERPwaviewerIN.Legend.font = 1;
                    end
                end
            case 17
                LegendFontsize = getfield(parse_paramout,'LegendFontsize');
                if ~isempty(LegendFontsize) && numel(LegendFontsize)==1 && LegendFontsize>0
                    ERPwaviewerIN.Legend.fontsize = LegendFontsize;
                end
                
            case 18
                Labeloc = getfield(parse_paramout,'Labeloc');
                if ~isempty(Labeloc)
                    try
                        ERPwaviewerIN.chanbinsetlabel.location.xperc = Labeloc(1);
                    catch
                        ERPwaviewerIN.chanbinsetlabel.location.xperc = 0;
                    end
                    try
                        ERPwaviewerIN.chanbinsetlabel.location.yperc = Labeloc(2);
                    catch
                        ERPwaviewerIN.chanbinsetlabel.location.yperc = 70;
                    end
                    try
                        ERPwaviewerIN.chanbinsetlabel.location.center =   Labeloc(3);
                    catch
                        ERPwaviewerIN.chanbinsetlabel.location.center =   1;
                    end
                    if ERPwaviewerIN.chanbinsetlabel.location.center~=0 && ERPwaviewerIN.chanbinsetlabel.location.center~=1
                        ERPwaviewerIN.chanbinsetlabel.location.center=1;
                    end
                end
            case 19
                Labelfont = getfield(parse_paramout,'Labelfont');
                if ~isempty(Labelfont)
                    [C2,IA2] = ismember_bc2(Labelfont,fonttype);
                    if C2 ==1
                        ERPwaviewerIN.chanbinsetlabel.font = IA2;
                    else
                        ERPwaviewerIN.chanbinsetlabel.font = 1;
                    end
                end
                
            case 20
                Labelfontsize = getfield(parse_paramout,'Labelfontsize');
                if ~isempty(Labelfontsize) && numel(Labelfontsize)==1 && Labelfontsize>0
                    ERPwaviewerIN.chanbinsetlabel.fontsize = Labelfontsize;
                end
            case 21
                YDir = getfield(parse_paramout,'YDir');
                if ~isempty(YDir) && numel(YDir)==1
                    ERPwaviewerIN.polarity = YDir;
                end
            case 22
                SEM = getfield(parse_paramout,'SEM');
                if ~isempty(SEM) && SEM>=0
                    ERPwaviewerIN.SEM.error = SEM;
                end
            case 23
                Transparency = getfield(parse_paramout,'Transparency');
                if ~isempty(Transparency) && Transparency>=0
                    ERPwaviewerIN.SEM.trans = Transparency;
                end
            case 24
                Gridspace = getfield(parse_paramout,'GridSpace');
                Layoutop = ERPwaviewerIN.plot_org.gridlayout.op;
                if Layoutop==1
                    ERPwaviewerIN.plot_org.gridlayout.rowgap.GTPOP = 1;
                    ERPwaviewerIN.plot_org.gridlayout.rowgap.GTPValue =10;
                    ERPwaviewerIN.plot_org.gridlayout.rowgap.OverlayOP = 0;
                    ERPwaviewerIN.plot_org.gridlayout.rowgap.OverlayValue =40;
                    ERPwaviewerIN.plot_org.gridlayout.columngap.GTPOP =1;
                    ERPwaviewerIN.plot_org.gridlayout.columngap.GTPValue =10;
                    ERPwaviewerIN.plot_org.gridlayout.columngap.OverlayOP =0;
                    ERPwaviewerIN.plot_org.gridlayout.columngap.OverlayValue =40;
                else
                    try
                        rowgapop = Gridspace(1,1);
                    catch
                        rowgapop =1;
                    end
                    ERPwaviewerIN.plot_org.gridlayout.rowgap.GTPOP = rowgapop;
                    if rowgapop%%gap
                        try
                            rowgapValue =   Gridspace(1,2);
                        catch
                            rowgapValue=10;
                        end
                        if isempty(rowgapValue) || numel(rowgapValue)~=1 || rowgapValue<=0
                            rowgapValue = 10;
                        end
                        ERPwaviewerIN.plot_org.gridlayout.rowgap.GTPValue = rowgapValue;
                        
                    else%%overlay
                        Gridspace(1,1) = 2;
                        ERPwaviewerIN.plot_org.gridlayout.rowgap.GTPOP = 2;
                        try
                            rowoverlayValue = Gridspace(1,2);
                        catch
                            rowoverlayValue = 40;
                        end
                        if isempty(rowoverlayValue) || numel(rowoverlayValue)~=1 || rowoverlayValue<=0 ||  rowoverlayValue>100
                            rowoverlayValue = 40;
                        end
                        ERPwaviewerIN.plot_org.gridlayout.rowgap.OverlayValue= rowoverlayValue;
                    end
                    %%for columns
                    try
                        columngapop = Gridspace(2,1);
                    catch
                        Gridspace(2,1) = 1;
                    end
                    ERPwaviewerIN.plot_org.gridlayout.columngap.GTPOP=columngapop;
                    if columngapop%%gap
                        try
                            columngapValue =  Gridspace(2,2);
                        catch
                            columngapValue = 10;
                        end
                        if isempty(columngapValue) || numel(columngapValue)~=1 || columngapValue<=0
                            columngapValue = 10;
                        end
                        ERPwaviewerIN.plot_org.gridlayout.columngap.GTPValue= columngapValue;
                    else%% overlay
                        try
                            columnoverlayValue =  Gridspace(2,2);
                        catch
                            columnoverlayValue = 20;
                        end
                        if isempty(columnoverlayValue) || numel(columnoverlayValue)~=1 || columnoverlayValue<=0 ||  columnoverlayValue>100
                            columnoverlayValue = 20;
                        end
                        ERPwaviewerIN.plot_org.gridlayout.columngap.OverlayValue= columnoverlayValue;
                    end
                end
            case 25
                TimeRange = unique(getfield(parse_paramout,'TimeRange'));
                if ~isempty(TimeRange) && numel(TimeRange)==2
                    ERPwaviewerIN.xaxis.timerange=sort(TimeRange);
                end
                
            case 26
                Xticks = getfield(parse_paramout,'Xticks');
                if ~isempty(Xticks)
                    ERPwaviewerIN.xaxis.timeticks = sort(Xticks);
                end
            case 27
                Xticklabel = getfield(parse_paramout,'Xticklabel');
                if ~isempty(Xticklabel)
                    if strcmpi(Xticklabel,'off')
                        ERPwaviewerIN.xaxis.label = 0;
                    else
                        ERPwaviewerIN.xaxis.label = 1;
                    end
                end
            case 28
                Xlabelfont =  getfield(parse_paramout,'Xlabelfont');
                if ~isempty(Xlabelfont)
                    [C3,IA3] = ismember_bc2(Xlabelfont,fonttype);
                    if C3 ==1
                        ERPwaviewerIN.xaxis.font = IA3;
                    else
                        ERPwaviewerIN.xaxis.font = 1;
                    end
                end
            case 29
                Xlabelfontsize = getfield(parse_paramout,'Xlabelfontsize');
                if ~isempty(Xlabelfontsize) && Xlabelfontsize>0
                    ERPwaviewerIN.xaxis.fontsize = Xlabelfontsize;
                end
            case 30
                Xlabelcolor = getfield(parse_paramout,'Xlabelcolor');
                if numel(Xlabelcolor) ==3
                    if Xlabelcolor(1)==0 && Xlabelcolor(2)==0 && Xlabelcolor(3)==0
                        ERPwaviewerIN.xaxis.fontcolor =1;
                    elseif  Xlabelcolor(1)==1 && Xlabelcolor(2)==0 && Xlabelcolor(3)==0
                        ERPwaviewerIN.xaxis.fontcolor =2;
                    elseif Xlabelcolor(1)==0 && Xlabelcolor(2)==0 && Xlabelcolor(3)==1
                        ERPwaviewerIN.xaxis.fontcolor =3;
                    elseif Xlabelcolor(1)==0 && Xlabelcolor(2)==1 && Xlabelcolor(3)==0
                        ERPwaviewerIN.xaxis.fontcolor =4;
                    elseif roundn(Xlabelcolor(1),-2)==0.93 && roundn(Xlabelcolor(2),-2)==0.69 && roundn(Xlabelcolor(3),-2)==0.13
                        ERPwaviewerIN.xaxis.fontcolor =5;
                    elseif Xlabelcolor(1)==0 && Xlabelcolor(2)==1 && Xlabelcolor(3)==1
                        ERPwaviewerIN.xaxis.fontcolor =6;
                    elseif  Xlabelcolor(1)==1 && Xlabelcolor(2)==0 && Xlabelcolor(3)==1
                        ERPwaviewerIN.xaxis.fontcolor =7;
                    else
                        ERPwaviewerIN.xaxis.fontcolor =1;
                    end
                end
            case 31
                Xunits = getfield(parse_paramout,'Xunits');
                if ~isempty(Xunits)
                    if strcmpi(Xunits,'off')
                        ERPwaviewerIN.xaxis.units = 0;
                    else
                        ERPwaviewerIN.xaxis.units = 1;
                    end
                end
            case 32
                MinorTicksX = getfield(parse_paramout,'MinorTicksX');
                if ~isempty(MinorTicksX)
                    try
                        xminorValue =   MinorTicksX(1);
                    catch
                        xminorValue =0;
                    end
                    ERPwaviewerIN.xaxis.tminor.disp =xminorValue;
                    if xminorValue==0
                        ERPwaviewerIN.xaxis.tminor.step = 0;
                        ERPwaviewerIN.xaxis.tminor.auto = 0;
                    else
                        try
                            xminorstr =   MinorTicksX(2:end);
                        catch
                            xminorstr = [];
                        end
                        if isempty(xminorstr)
                            ERPwaviewerIN.xaxis.tminor.step = 0;
                            ERPwaviewerIN.xaxis.tminor.auto = 0;
                        else
                            ERPwaviewerIN.xaxis.tminor.step = xminorstr;
                        end
                    end
                end
            case 33
                YScales = unique(getfield(parse_paramout,'YScales'));
                if ~isempty(YScales) && numel(YScales)==2
                    ERPwaviewerIN.yaxis.scales = sort(YScales);
                end
            case 34
                Yticks = getfield(parse_paramout,'Yticks');
                if ~isempty(Yticks)
                    ERPwaviewerIN.yaxis.ticks = sort(Yticks);
                end
            case 35
                Yticklabel =getfield(parse_paramout,'Yticklabel');
                if ~isempty(Yticklabel)
                    if strcmpi(Yticklabel,'off')
                        ERPwaviewerIN.yaxis.label = 0;
                    else
                        ERPwaviewerIN.yaxis.label = 1;
                    end
                end
                
            case 36
                Ylabelfont = getfield(parse_paramout,'Ylabelfont');
                if ~isempty(Ylabelfont)
                    [C4,IA4] = ismember_bc2(Ylabelfont,fonttype);
                    if C4 ==1
                        ERPwaviewerIN.yaxis.font = IA4;
                    else
                        ERPwaviewerIN.yaxis.font = 1;
                    end
                end
            case 37
                Ylabelfontsize =  getfield(parse_paramout,'Ylabelfontsize');
                if ~isempty(Ylabelfontsize) &&  Ylabelfontsize>0
                    ERPwaviewerIN.yaxis.fontsize = Ylabelfontsize;
                end
            case 38
                Ylabelcolor = getfield(parse_paramout,'Ylabelcolor');
                if numel(Ylabelcolor) ==3
                    if Ylabelcolor(1)==0 && Ylabelcolor(2)==0 && Ylabelcolor(3)==0
                        ERPwaviewerIN.yaxis.fontcolor =1;
                    elseif  Ylabelcolor(1)==1 && Ylabelcolor(2)==0 && Ylabelcolor(3)==0
                        ERPwaviewerIN.yaxis.fontcolor =2;
                    elseif Ylabelcolor(1)==0 && Ylabelcolor(2)==0 && Ylabelcolor(3)==1
                        ERPwaviewerIN.yaxis.fontcolor =3;
                    elseif Ylabelcolor(1)==0 && Ylabelcolor(2)==1 && Ylabelcolor(3)==0
                        ERPwaviewerIN.yaxis.fontcolor =4;
                    elseif roundn(Ylabelcolor(1),-2)==0.93 && roundn(Ylabelcolor(2),-2)==0.69 && roundn(Ylabelcolor(3),-2)==0.13
                        ERPwaviewerIN.yaxis.fontcolor =5;
                    elseif Ylabelcolor(1)==0 && Ylabelcolor(2)==1 && Ylabelcolor(3)==1
                        ERPwaviewerIN.yaxis.fontcolor =6;
                    elseif  Ylabelcolor(1)==1 && Ylabelcolor(2)==0 && Ylabelcolor(3)==1
                        ERPwaviewerIN.yaxis.fontcolor=7;
                    else
                        ERPwaviewerIN.yaxis.fontcolor =1;
                    end
                end
            case 39
                Yunits = getfield(parse_paramout,'Yunits');
                if ~isempty(Yunits)
                    if strcmpi(Yunits,'off')
                        ERPwaviewerIN.yaxis.units = 0;
                    else
                        ERPwaviewerIN.yaxis.units = 1;
                    end
                end
            case 40
                MinorTicksY = getfield(parse_paramout,'MinorTicksY');
                if ~isempty(MinorTicksY)
                    try
                        yminorValue =   MinorTicksY(1);
                    catch
                        yminorValue =0;
                    end
                    ERPwaviewerIN.yaxis.yminor.disp =yminorValue;
                    if yminorValue==0
                        ERPwaviewerIN.yaxis.yminor.step = 0;
                        ERPwaviewerIN.yaxis.yminor.auto = 0;
                    else
                        try
                            yminorstr =   MinorTicksY(2:end);
                        catch
                            yminorstr = [];
                        end
                        if isempty(yminorstr)
                            ERPwaviewerIN.yaxis.yminor.step = 0;
                            ERPwaviewerIN.yaxis.yminor.auto = 0;
                        else
                            ERPwaviewerIN.yaxis.yminor.step = yminorstr;
                        end
                    end
                end
            case 41
                LegtextColor =  getfield(parse_paramout,'LegtextColor');
                if ~isempty(LegtextColor) && (LegtextColor==0 || LegtextColor==1)
                    ERPwaviewerIN.Legend.textcolor = LegtextColor;
                end
                
            case 42
                Legcolumns = getfield(parse_paramout,'Legcolumns');
                if ~isempty(Legcolumns) && numel(Legcolumns)==1 && Legcolumns>0
                    ERPwaviewerIN.Legend.columns = Legcolumns;
                end
            case 43
                FigureName = getfield(parse_paramout,'FigureName');
                if ~isempty(FigureName)
                    ERPwaviewerIN.figname  = FigureName;
                end
            case 44
                FigbgColor = getfield(parse_paramout,'FigbgColor');
                if ~isempty(FigbgColor) || min(FigbgColor)>=0 || max(FigbgColor)<=1
                    ERPwaviewerIN.figbackgdcolor = FigbgColor;
                end
                
            case 45
                Labelcolor = getfield(parse_paramout,'Labelcolor');
                if numel(Labelcolor) ==3
                    if Labelcolor(1)==0 && Labelcolor(2)==0 && Labelcolor(3)==0
                        ERPwaviewerIN.chanbinsetlabel.textcolor =1;
                    elseif  Labelcolor(1)==1 && Labelcolor(2)==0 && Labelcolor(3)==0
                        ERPwaviewerIN.chanbinsetlabel.textcolor =2;
                    elseif Labelcolor(1)==0 && Labelcolor(2)==0 && Labelcolor(3)==1
                        ERPwaviewerIN.chanbinsetlabel.textcolor =3;
                    elseif Labelcolor(1)==0 && Labelcolor(2)==1 && Labelcolor(3)==0
                        ERPwaviewerIN.chanbinsetlabel.textcolor =4;
                    elseif roundn(Labelcolor(1),-2)==0.93 && roundn(Labelcolor(2),-2)==0.69 && roundn(Labelcolor(3),-2)==0.13
                        ERPwaviewerIN.chanbinsetlabel.textcolor =5;
                    elseif Labelcolor(1)==0 && Labelcolor(2)==1 && Labelcolor(3)==1
                        ERPwaviewerIN.chanbinsetlabel.textcolor =6;
                    elseif  Labelcolor(1)==1 && Labelcolor(2)==0 && Labelcolor(3)==1
                        ERPwaviewerIN.chanbinsetlabel.textcolor=7;
                    else
                        ERPwaviewerIN.chanbinsetlabel.textcolor =1;
                    end
                end
            case 46
                Ytickdecimal = getfield(parse_paramout,'Ytickdecimal');
                if ~isempty(Ytickdecimal)&& numel(Ytickdecimal)==1 && Ytickdecimal>=0
                    ERPwaviewerIN.yaxis.tickdecimals=Ytickdecimal;
                end
            case 47
                Xtickdecimal = getfield(parse_paramout,'Xtickdecimal');
                if ~isempty(Xtickdecimal)&&numel(Xtickdecimal)==1 && Xtickdecimal>=0
                    ERPwaviewerIN.xaxis.tickdecimals=Xtickdecimal;
                end
            case 48
                XtickdisFlag =  getfield(parse_paramout,'XtickdisFlag');
                if ~isempty(XtickdisFlag) && numel(XtickdisFlag) ==1 && (XtickdisFlag==0 || XtickdisFlag==1)
                    ERPwaviewerIN.xaxis.tdis = XtickdisFlag;
                end
        end
    end
end

end