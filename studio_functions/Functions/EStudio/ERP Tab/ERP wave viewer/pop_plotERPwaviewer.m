% PURPOSE:  pop_plotERPwaviewer.m
%           plot ERP waveforms
%

% FORMAT:
%
% [ALLERP, erpcom] = pop_plotERPwaviewer(ALLERP,CURRENTPLOT,ERPsetArray,binArray, chanArray,'PLOTORG',PLOTORG,'GridposArray',GridposArray,'LabelsName',LabelsName, 'Blc', Blc,'Box',plotBox,'LineColor',LineColorspec,'LineStyle',LineStylespec,...
%         'LineMarker',LineMarkerspec,'LineWidth',LineWidthspec,'LegendName',LegendName,'LegendFont',FontLeg,'LegendFontsize',FontSizeLeg,...
%         'Labeloc',CBELabels,'Labelfont',CBEFont,'Labelfontsize',CBEFontsize,'YDir',PolarityWave,'SEM',Standerr,'Transparency', Transparency,...
%         'GridSpace',GridSpace,'TimeRange',timeRange,'Xticks',timeticks,'Xticklabel',xticklabel,'Xlabelfont',xlabelFont,'Xlabelfontsize',xlabelFontsize,...
%         'Xlabelcolor',xlabelFontcolor,'Xunits',Xunits,'MinorTicksX',MinorticksX,...
%         'YScales',Yscales,'Yticks',Yticks,'Yticklabel',yticklabel,'Ylabelfont',YlabelFont,'Ylabelfontsize',YlabelFontsize,...
%         'Ylabelcolor',ylabelFontcolor,'Yunits',yunits,'MinorTicksY',MinorticksY,'LegtextColor',TextcolorLeg,'Legcolumns',Legcolumns,'FigureName',FigureName,...
%         'FigbgColor',figbgdColor,'Labelcolor',Labelcolor,'Ytickdecimal',Ytickprecision,'Xtickdecimal',Xtickprecision,'XtickdisFlag',XdisFlag,'Parameterfile',Parameterfile,'History', 'gui');

% Inputs:
%
%ALLERP           -ALLERPset
%CURRENTPLOT      -index of current ERPset/bin/channel(e.g., 1)
%PLOTORG          -plot organization including three elements (the default is [1 2 3])
%                 First element is for Grid (1 is channel; 2 is bin; 3 is ERPset)
%                 Second element is for Overlay (1 is channel; 2 is bin; 3 is ERPset)
%                 Third element is for Page (1 is channel; 2 is bin; 3 is ERPset)
%binArray         -index(es) of bin(s) to plot  ( 1 2 3 ...)
%chanArray        -index(es) of channel(s) to plot ( 5 10 11 ...)
%GridposArray     -location and correponding index of each subplot. E.g.,
%                  plot three channels with 2 (rows) x 2 (columns), the default qGridposArray is
%                  [5,10;11,0]. The each element of GridposArray is the
%                  index of selected Channel/bin/ERPset. 0 repsents no
%                  channel/bin/ERP will be dispalyed
%LabelsName     -Channel/Bin/ERPset labels e.g., {'Fz','F3','F4'}
%plotBox          -ditribution of plotting boxes in rows x columns.
%Blc              -string or numeric interval for baseline correction
%                 reference window: 'no','pre','post','all', or[-100 0]
%LineColor        -line color with RGB,e.g., [0 0 0;1 0 0]
%LineStyle        -line style e.g., {'-','-'}
%LineMarker       -line marker e.g., {'o','*','none'}
%LineWidth        -line width e.g., [1 1 1]
%LegendName       -legend name e.g., {'Rare','Frequent'}
%LegendFont       -font for legend name e.g., 'Courier' or 'Times'
%LegendFontsize   -fontsize for legend name (one value) e.g., 12 or 16
%Labeloc          -location for channel/bin/erpset label including three
%                  elements e.g., [100 100 1]; first and second represent
%                  the percentage of time range or y scales; the last
%                  element determine whether display the label (1 or 0)
%Labelfont        -label font
%Labelfontsize    -label fontsize
%YDir             -"Y" axis is inverted (-UP)?:  'yes', 'no'. 1 is positive up and 0
%                  is negative up
%'SEM'              - plot standard error of the mean (if available). 0 is
%                  off and other is on.
%Transparency     -  the default is 0
%GridSpace        - Grid spacing includes two dimensions (2 X 2). The first
%                   column is Gap (1) or Overlap (2); The second column
%                   represents the specific values for Gap/Overlap.
%TimeRange        -time window is used to display the wave e.g., [-200 800]
%Xticks           - ticks for x axes e.g., [-200 0 200 400 600 800]
%Xticklabel       -display xticklabels? 1 is on and 0 is off.
%Xlabelfont       -font for xtick and xticklabel e.g., 'Courier'
%Xlabelfontsize   -fontsize for xticklabel e.g., 12
%Xlabelcolor      -color (RGB) for xticklabels e.g., [0 0 0]
%MinorTicksX      - Minor Ticks for x axes
%Xunits           -display units for x axes. "on" or "off"
%YScales          - y scales e.g., [-6 10]
%Yticks           - y ticks e.g., [-6 -3 0 5 10]
%Yticklabel       -display yticklabels? 1 is on and 0 is off.
%Ylabelfont       -font for yticklabels e.g., 'Courier'
%Ylabelfontsize   -fontsize for yticklabels
%Ylabelcolor      -color (RGB) for yticks and yticklabels e.g., [0 0 0]
%Yunits           -display units for x axes. "on" or "off"
%MinorTicksY      -
%LegtextColor     -Text color of legend names. 1 is black (default); 0 is
%                  the same as the color of lines
%Legcolumns       -Number of columns for legend names. e.g., 1 or 2,....
%FigureName       -Figure name, e.g., "My Viewer"
%FigbgColor       -Background color of figure. The default is [1 1 1]
%Labelcolor       -Channel/Bin/ERPset label color in RGB, e.g., [0 0 0]
%Ytickdecimal     -determine the number of  decimals of y tick labels
%                  - e.g., -6.0 -3.0 0.0 3.0 6.0 if Ytickdecimal is 1
%Xtickdecimal     -determine the nunmber of decimals of x tick labels
%                 -e.g., -0.2 0.0 0.2 0.4 0.6 0.8 if Xtickdecimal is 1
%XtickdisFlag     -the way is to display xticks: 1 is in millisecond, 0 is in second
%FigOutpos        - The width and height for the figure. The default one is
%                   the same to the monitor.


% *** This function is part of ERPLAB Studio ***
% Author: Guanghui Zhang & Steven Luck
% ghzhang@ucdavis.edu, sjluck@ucdavis.edu
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022 & 2023


function [ALLERP, erpcom] = pop_plotERPwaviewer(ALLERP,CURRENTPLOT,ERPsetArray,binArray,chanArray,varargin)
%
erpcom = '';
if nargin < 1
    help pop_plotERPwaviewer
    return;
end

if nargin==1  %with GUI to get other parameters
    if isempty(ALLERP)
        msgboxText =  'No ALLERP was found!';
        title_msg  = 'EStudio: pop_plotERPwaviewer() error:';
        errorfound(msgboxText, title_msg);
        return;
    end
    
    CURRENTPLOT = length(ALLERP);
    ERP  = ALLERP(CURRENTPLOT);
    PLOTORG = [1 2 3]; %% "Channels" will be Grid; "Bins" will be Overlay; "ERPsets" will be
    if ~iserpstruct(ERP)
        msgboxText =  'Invalid ERP structure!';
        title_msg  = 'EStudio: pop_plotERPwaviewer() error:';
        errorfound(msgboxText, title_msg);
        return
    end
    if isempty(ERP.bindata) %(ERP.bindata)
        msgboxText =  'Cannot plot an empty ERP dataset';
        title_msg  = 'EStudio: pop_plotERPwaviewer() error:';
        errorfound(msgboxText, title_msg);
        return
    end
    binArray = 1:ERP.nbin;
    chanArray = 1:ERP.nchan;%%Index of channels which will plot
    ERPsetArray = [1:length(ALLERP)];
    [chanStr,binStr] = f_geterpschanbin(ALLERP,ERPsetArray);
    
    if PLOTORG(1) ==1 %% if  the selected Channel is "Grid"
        plotArray = chanArray;
        for Numofchan = 1:numel(chanArray)
            try
                LabelsName{Numofchan} = chanStr{plotArray(Numofchan)};
            catch
            end
        end
    elseif PLOTORG(1) == 2 %% if the selected Bin is "Grid"
        plotArray = binArray;
        for Numofbin = 1:numel(plotArray)
            try
                LabelsName{Numofbin} = binStr{plotArray(Numofbin)};
            catch
            end
        end
    elseif PLOTORG(1) == 3%% if the selected ERPset is "Grid"
        plotArray = ERPsetArray;
        for Numoferp = 1:numel(plotArray)
            try
                LabelsName{Numoferp} = ALLERP(plotArray(Numoferp)).erpname;
            catch
                LabelsName{Numoferp} = 'no';
            end
        end
    end
    plotBox = f_getrow_columnautowaveplot(plotArray);
    
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
    if PLOTORG(2) ==1 %% if  the selected Channel is "Grid"
        OverlayArray = chanArray;
        for Numofchan = 1:numel(chanArray)
            LegendName{NUmofchan,1} =char(chanStr(chanArray(Numofchan)));
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
    [lineNameStr,linecolors,linetypes,linewidths] = f_get_lineset_ERPviewer(numel(OverlayArray));
    lineset_str  =table(lineNameStr,linecolors,linetypes,linewidths);
    LineData = table2cell(lineset_str);
    lineStylrstr = {'solid','dash','dot','dashdot','plus','circle','asterisk'};
    linecolorsstr = {'black','red','blue','green','orange','cyan','magenla'};
    LineColorspec = zeros(numel(OverlayArray),3); %%
    LineStylespec = cell(1,numel(OverlayArray));
    LineMarkerspec = cell(1,numel(OverlayArray));
    LineWidthspec = ones(1,numel(OverlayArray));
    
    for Numofplot = 1: numel(OverlayArray)  %%using RGB or r,g,b,o?
        %%determine the specific RGB value for the defined color
        CellColor = LineData{Numofplot,2};
        [C_color,IA_color] = ismember_bc2(CellColor,linecolorsstr);
        if C_color==1
            switch IA_color%% {'black','red','blue','green','orange','cyan','magenla'};
                case 1
                    LineColorspec(Numofplot,:)  = [0 0 0];%% black
                case 2
                    LineColorspec(Numofplot,:)  = [1 0 0];%% red
                case 3
                    LineColorspec(Numofplot,:)  = [0 0 1];%% blue
                case 4
                    LineColorspec(Numofplot,:)  = [0 1 0];%%green
                case 5
                    LineColorspec(Numofplot,:)  = [0.9290 0.6940 0.1250];%%orange
                case 6
                    LineColorspec(Numofplot,:)  = [0 1 1];%%cyan
                case 7
                    LineColorspec(Numofplot,:)  = [1 0 1];%%magenla
                otherwise
                    LineColorspec(Numofplot,:)  = [0 0 0];%%black
            end
        else
            LineColorspec{Numofplot,1}  = [0 0 0];
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
    
    %%Font and fontsize for legend
    FontLeg = 'Helvetica';
    FontSizeLeg =  10;
    
    %%Setting for Channel/Bin/ERP label
    CBELabels = [];%location 0 70 1
    CBEFont = 'Helvetica';%%font
    CBEFontsize=10;%% fontsize
    
    %%Polarity of wave
    PolarityWave =1;%%1.positive up; 0. negative up
    
    %%standard error
    Standerr = 0;%%
    
    %%Transparency
    Transparency = 0;%1. show Transparency; 0. donot show Transparency
    
    %%Grid space for rows and columns
    GridSpace = [1 20;1 20];
    
    %%Baseline correction
    Blc = 'none';
    
    %%---------------------X axis------------------------------------------
    timeRange(1) = ERP.times(1);
    timeRange(2) = ERP.times(end);
    timeticks = str2num(char(default_time_ticks_studio(ERP, timeRange)));
    xticklabel = 'on';
    xlabelFont = 'Helvetica';
    xlabelFontsize = 10;
    xlabelFontcolor = [0 0 0];
    Xunits = 'on';
    MinorticksX = [0];%% off
    
    %%---------------------Y axis------------------------------------------
    [Yscales, serror] = erpAutoYLim(ERP);
    try
        Yticks = str2num(char(default_amp_ticks_viewer(Yscales)));
    catch
        Yticks = [];
    end
    yticklabel = 'on';
    YlabelFont = 'Helvetica';
    YlabelFontsize = 10;
    ylabelFontcolor = [0 0 0];
    yunits = 'on';
    MinorticksY = [0];
    FigureName = 'My Viewer';
    
    TextcolorLeg = 1;%% 1. using black color for legend text color; 0. use the same color as lines for legend text
    Legcolumns = 1;%%Number of columns for legend name
    
    figbgdColor = [1 1 1];
    
    Labelcolor = [0 0 0];
    
    Ytickprecision = 1;
    Xtickprecision = 1;
    XdisFlag = 1;
    Parameterfile = '';
    FigOutpos = [];
    [ALLERP, erpcom] = pop_plotERPwaviewer(ALLERP,CURRENTPLOT,ERPsetArray,binArray, chanArray,'PLOTORG',PLOTORG,'GridposArray',GridposArray,'LabelsName',LabelsName, 'Blc', Blc,'Box',plotBox,'LineColor',LineColorspec,'LineStyle',LineStylespec,...
        'LineMarker',LineMarkerspec,'LineWidth',LineWidthspec,'LegendName',LegendName,'LegendFont',FontLeg,'LegendFontsize',FontSizeLeg,...
        'Labeloc',CBELabels,'Labelfont',CBEFont,'Labelfontsize',CBEFontsize,'YDir',PolarityWave,'SEM',Standerr,'Transparency', Transparency,...
        'GridSpace',GridSpace,'TimeRange',timeRange,'Xticks',timeticks,'Xticklabel',xticklabel,'Xlabelfont',xlabelFont,'Xlabelfontsize',xlabelFontsize,...
        'Xlabelcolor',xlabelFontcolor,'Xunits',Xunits,'MinorTicksX',MinorticksX,...
        'YScales',Yscales,'Yticks',Yticks,'Yticklabel',yticklabel,'Ylabelfont',YlabelFont,'Ylabelfontsize',YlabelFontsize,...
        'Ylabelcolor',ylabelFontcolor,'Yunits',yunits,'MinorTicksY',MinorticksY,'LegtextColor',TextcolorLeg,'Legcolumns',Legcolumns,'FigureName',FigureName,...
        'FigbgColor',figbgdColor,'Labelcolor',Labelcolor,'Ytickdecimal',Ytickprecision,'Xtickdecimal',Xtickprecision,'XtickdisFlag',XdisFlag,'FigOutpos',FigOutpos,'Parameterfile',Parameterfile,'History', 'gui');
    
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
p.addRequired('ALLERP');
p.addRequired('CURRENTPLOT', @isnumeric);
p.addRequired('ERPsetArray', @isnumeric);%%Indices of the selected channels
p.addRequired('binArray', @isnumeric);%%Indices of the selected channels
p.addRequired('chanArray', @isnumeric);%%Indices of the selected bins




%Option(s)
p.addParamValue('PLOTORG',[],@isnumeric);%%contains three elements: the first one is "Grid", the second one is "Overlay", and the last one is "Pages"
p.addParamValue('GridposArray',[], @isnumeric);%%Vector or matrix contains the indices of the selected channels/bins/erpsets for each subplot
p.addParamValue('LabelsName','', @iscell);

p.addParamValue('Blc', '');
p.addParamValue('Box', [], @isnumeric);
p.addParamValue('LineColor', [], @isnumeric);
p.addParamValue('LineStyle', '', @iscell);
p.addParamValue('LineMarker', '',@iscell);
p.addParamValue('LineWidth', [], @isnumeric);
p.addParamValue('LegendName', '', @iscell);
p.addParamValue('LegendFont', '', @ischar);
p.addParamValue('LegendFontsize', [], @isnumeric);
p.addParamValue('Labeloc', [], @isnumeric);
p.addParamValue('Labelfont', '', @ischar);
p.addParamValue('Labelfontsize', [],@isnumeric);
p.addParamValue('YDir', [], @isnumeric);%% wave polarity
p.addParamValue('SEM', [], @isnumeric);%% standard error of mean
p.addParamValue('Transparency',[], @isnumeric);
p.addParamValue('GridSpace', [], @isnumeric);
%%----------X axis------------------------
p.addParamValue('TimeRange', [], @isnumeric); %% time window for x axis
p.addParamValue('Xticks', '', @isnumeric);
p.addParamValue('Xticklabel', '', @ischar);
p.addParamValue('Xlabelfont','',@ischar);
p.addParamValue('Xlabelfontsize', [], @isnumeric);%%
p.addParamValue('Xlabelcolor', [], @isnumeric);%%
p.addParamValue('Xunits', '', @ischar);
p.addParamValue('MinorTicksX', [], @isnumeric);%% donot display minor xticks
%%-------setting for Y axis---------------
p.addParamValue('YScales', [], @isnumeric); %% y scales for y axis
p.addParamValue('Yticks', '', @isnumeric);
p.addParamValue('Yticklabel', '', @ischar);
p.addParamValue('Ylabelfont','',@ischar);
p.addParamValue('Ylabelfontsize', [], @isnumeric);%%
p.addParamValue('Ylabelcolor', [], @isnumeric);%%
p.addParamValue('Yunits', '', @ischar);
p.addParamValue('MinorTicksY', [], @isnumeric);%%
p.addParamValue('LegtextColor', [], @isnumeric);%%
p.addParamValue('Legcolumns', [], @isnumeric);%%
p.addParamValue('FigureName', '', @ischar);%%

p.addParamValue('FigbgColor', [], @isnumeric);%%
p.addParamValue('Labelcolor', [], @isnumeric);%%
p.addParamValue('Ytickdecimal', [], @isnumeric);
p.addParamValue('Xtickdecimal', [], @isnumeric);
p.addParamValue('XtickdisFlag', [], @isnumeric);
p.addParamValue('FigOutpos', [], @isnumeric);
p.addParamValue('Parameterfile', '', @ischar);

p.addParamValue('ErrorMsg', '', @ischar);
p.addParamValue('History', '', @ischar); % history from scripting



p.parse(ALLERP,CURRENTPLOT,ERPsetArray,binArray,chanArray,varargin{:});

qParameterfile = p.Results.Parameterfile;
p_Results = p.Results;

parse_paramout = '';
if ~isempty(qParameterfile)
    
    if isempty(p_Results.ALLERP) && isempty(qParameterfile.ALLERP)
        beep;
        fprintf(2,'pop_plotERPwaviewer:No ALLERP is in Parameterfile and imported ALLERP is empty');
        return;
    end
    
    if ~isempty(p_Results.ALLERP) && isempty(qParameterfile.ALLERP)
        qParameterfile.ALLERP = p_Results.ALLERP;
        CURRENTERP = qParameterfile.CURRENTERP;
        if isempty(CURRENTERP)|| CURRENTERP<=0 || CURRENTERP>length(p_Results.ALLERP)
            CURRENTERP = length(p_Results.ALLERP);
        end
        qParameterfile.CURRENTERP = CURRENTERP;
        qParameterfile.ERP  = qParameterfile.ALLERP(CURRENTERP);
    end
    
    if ~isempty(p_Results.ALLERP) && ~isempty(qParameterfile.ALLERP)
        BackERPLABcolor = [1 0.9 0.3];    % yellow
        question = ['Select one of them?\n 1. Use imported ALLERP. \n 2. Use ALLERP in Parameterfile.'];
        title = 'pop_plotERPwaviewer';
        oldcolor = get(0,'DefaultUicontrolBackgroundColor');
        set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
        button = questdlg(sprintf(question), title,'Cancel','1', '2','Yes');
        set(0,'DefaultUicontrolBackgroundColor',oldcolor);
        
        if strcmpi(button,'1') || strcmpi(button,'2')
            if strcmpi(button,'1')
                qParameterfile.ALLERP = p_Results.ALLERP;
                CURRENTERP = qParameterfile.CURRENTERP;
                if isempty(CURRENTERP)|| CURRENTERP<=0 || CURRENTERP>length(p_Results.ALLERP)
                    CURRENTERP = length(p_Results.ALLERP);
                end
                qParameterfile.CURRENTERP = CURRENTERP;
                qParameterfile.ERP  = qParameterfile.ALLERP(CURRENTERP);
            end
        else
            beep;
            fprintf(2,'pop_plotERPwaviewer: User selected cancel.');
            return;
        end
    end
    [parse_paramout, ErroMessg] = f_erpwave_viewer_update_parameter(qParameterfile,p);
    if ~isempty(parse_paramout)
        ERPLAB_ERP_Viewer(parse_paramout.ALLERP,parse_paramout.SelectERPIdx,parse_paramout.bin,parse_paramout.chan,parse_paramout)
    end
    return;
end

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

%
%%check ALLERP
if isempty(ALLERP)
    msgboxText =  'No ALLERP was found!';
    title_msg  = 'EStudio: pop_plotERPwaviewer() error:';
    errorfound(msgboxText, title_msg);
    return;
end


qPLOTORG = p_Results.PLOTORG;%%Plot organization
if isempty(qPLOTORG) || numel(qPLOTORG)~=3 ||  numel(unique(qPLOTORG)) ~=3 || min(qPLOTORG)<0 || max(qPLOTORG)>3
    qPLOTORG = [1 2 3];
end


qERPsetArray = p_Results.ERPsetArray;
if isempty(qERPsetArray)
    qERPsetArray = [1:length(ALLERP)];
end

if (qPLOTORG(1)==1 && qPLOTORG(2)==2) || (qPLOTORG(1)==2 && qPLOTORG(2)==1)
else
    chkerp = f_checkerpsets(ALLERP,qERPsetArray);
    if chkerp(3) ==3
        msgboxText =  'Type of data across ERPsets is different!';
        title_msg  = 'EStudio: pop_plotERPwaviewer() error:';
        errorfound(msgboxText, title_msg);
        return;
    end
    if chkerp(7) ==7
        msgboxText =  'Sampling rate varies across ERPsets!';
        title_msg  = 'EStudio: pop_plotERPwaviewer() error:';
        errorfound(msgboxText, title_msg);
        return;
    end
end


qbinArray = p_Results.binArray;
qchanArray = p_Results.chanArray;
qCURRENTPLOT = p_Results.CURRENTPLOT;
qGridposArray =  p_Results.GridposArray;
qLabelsName = p_Results.LabelsName;
if numel(qCURRENTPLOT)~=1 || isempty(qCURRENTPLOT)
    qCURRENTPLOT = length(ALLERP);
end

% qERPArray = [1:length(ALLERP)];
[chanStrdef,binStrdef] = f_geterpschanbin(ALLERP,qERPsetArray);%%get the bin strings and channel strings across the selected ERPsets
[ERPdatadef,legendNamedef,ERPerrordatadef,timeRangedef] = f_geterpdata(ALLERP,qERPsetArray,qPLOTORG,CURRENTPLOT);

if min(qbinArray)<0 || min(qbinArray)==0
    msgboxText =  ['Invalid bin indexing.\n'...
        'Bin index(ices) must be positive integer(s).'];
    if errormsgtype
        title_msg = 'EStudio: pop_plotERPwaviewer() invalid bin index';
        errorfound(sprintf(msgboxText), title_msg);
        return
    else
        beep;
        error('prog:input', ['EStudio says: ' msgboxText]);
    end
end

if min(qchanArray)<0 || min(qchanArray)==0
    msgboxText =  ['Invalid channel indexing.\n'...
        'Channel index(ices) must be positive integer(s).'];
    if errormsgtype
        title_msg = 'EStudio: pop_plotERPwaviewer() invalid channel index';
        errorfound(sprintf(msgboxText), title_msg);
        return
    else
        beep;
        error('prog:input', ['EStudio says: ' msgboxText]);
    end
end


Existbin = f_existvector([1:length(binStrdef)],qbinArray);
if isempty(qbinArray) || Existbin==1
    qbinArray = [1:length(binStrdef)];
    Existbin = 1;
end

Existchan = f_existvector([1:length(chanStrdef)],qchanArray);
if isempty(qchanArray) || Existchan==1
    qchanArray = [1:length(chanStrdef)];
    Existchan =1;
end

%%check the numbers of rows and columns
if qPLOTORG(1) ==1 %% if  the selected Channel is "Grid"
    plotArray = qchanArray;
    for Numofchan = 1:numel(chanArray)
        try
            LabelsNamedef{Numofchan} = chanStrdef{plotArray(Numofchan)};
        catch
            LabelsNamedef{Numofchan} = 'none';
        end
    end
elseif qPLOTORG(1) == 2 %% if the selected Bin is "Grid"
    plotArray = qbinArray;
    for Numofbin = 1:numel(plotArray)
        try
            LabelsNamedef{Numofbin} = binStrdef{plotArray(Numofbin)};
        catch
            LabelsNamedef{Numofbin} = 'none';
        end
    end
elseif qPLOTORG(1) == 3%% if the selected ERPset is "Grid"
    plotArray = qERPsetArray;
    for Numoferp = 1:numel(plotArray)
        try
            LabelsNamedef{Numoferp} = ALLERP(plotArray(Numoferp)).erpname;
        catch
            LabelsNamedef{Numoferp} = 'none';
        end
    end
else
    plotArray = qchanArray;
    for Numofchan = 1:numel(chanArray)
        try
            LabelsNamedef{Numofchan} = chanStrdef{plotArray(Numofchan)};
        catch
            LabelsNamedef{Numofchan} = 'none';
        end
    end
end

if isempty(qLabelsName)
    qLabelsName  =LabelsNamedef;
end

plotBoxdef = f_getrow_columnautowaveplot(plotArray);
qplotBox = p_Results.Box;

if isempty(qplotBox) || numel(unique(qplotBox))>2 || min(qplotBox) <1 ||  numel(qplotBox)~=2
    qplotBox = plotBoxdef;
end


NumRows = ceil(qplotBox(1));
NumColumns = ceil(qplotBox(2));
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
if isempty(qGridposArray)
    qGridposArray = GridposArraydef;
end

%%check elements in qGridposArray
for Numofrows = 1:size(qGridposArray,1)
    for Numofcolumns = 1:size(qGridposArray,2)
        SingleGridpos = qGridposArray(Numofrows,Numofcolumns);
        if SingleGridpos~=0
            ExistGridops = f_existvector(plotArray,SingleGridpos);
            if ExistGridops==1
                qGridposArray(Numofrows,Numofcolumns) =0;
            end
        end
    end
end

%%-------Baseline correction-----------
qBlc = p_Results.Blc;
if isempty(qBlc)
    qBlc = 'none';
end
if length(qBlc) ==2
    if ~isnumeric(qBlc) %% if the input of baseline correction is string;
        qBlc = 'none';
    end
end
if length(qBlc) ==2 && isnumeric(qBlc)
    if min(timeRangedef)> min(qBlc) || max(timeRangedef)< max(qBlc) || qBlc(1) == qBlc(2)
        qBlc = 'none';
    end
    if qBlc(1)> qBlc(2)
        qBlc = fliplr(qBlc);
    end
end

%%check the line color
qLineColorspec = p_Results.LineColor;
if qPLOTORG(2) ==1 %% if  the selected Channel is "Grid"
    OverlayArray = qchanArray;
    for Numofchan = 1:numel(qchanArray)
        LegendNamedef{Numofchan,1} =char(chanStrdef(qchanArray(Numofchan)));
    end
elseif qPLOTORG(2) == 2 %% if the selected Bin is "Grid"
    OverlayArray = qbinArray;
    for Numofbin = 1:numel(qbinArray)
        LegendNamedef{Numofbin,1} = char(binStrdef(qbinArray(Numofbin)));
    end
elseif qPLOTORG(2) == 3%% if the selected ERPset is "Grid"
    OverlayArray = qERPsetArray;
    for Numoferpset = 1:numel(qERPsetArray)
        try
            LegendNamedef{Numoferpset} = ALLERPIN(qERPsetArray(Numoferpset)).erpname;
        catch
            LegendNamedef{Numoferpset} = '';
        end
    end
else
    OverlayArray = qbinArray;
    for Numofbin = 1:numel(qbinArray)
        LegendNamedef{Numofbin,1} = char(binStr(qbinArray(Numofbin)));
    end
end

LineColordef = [0 0 0;1 0 0;0 0 1;0 1 0;0.9290 0.6940 0.1250;0 1 1;1 0 1];
LineMarkerdef = {'none','none','none','none','+','o','*'};
LineStyledef = {'-','--',':','-.','-','-','-',};
if isempty(qLineColorspec)
    for Numofcolor = 1:numel(OverlayArray)
        Numindex = 7*floor(Numofcolor/7);
        if Numindex==0
            try
                qLineColorspec(Numofcolor,:) = LineColordef(Numofcolor,:);
            catch
                qLineColorspec(Numofcolor,:) = [0 0 0];
            end
        elseif Numindex~=0
            try
                qLineColorspec(Numofcolor,:) = LineColordef(Numofcolor-Numindex,:);
            catch
                qLineColorspec(Numofcolor,:) = [0 0 0];
            end
        else
            try
                qLineColorspec(Numofcolor,:) = LineColordef(Numofcolor,:);
            catch
                qLineColorspec(Numofcolor,:) = [0 0 0];
            end
        end
    end
end

%%check line styles
qLineStylespec = p_Results.LineStyle;
if isempty(qLineStylespec)
    for Numofcolor = 1:numel(OverlayArray)
        NumIndex = ceil(Numofcolor/7);
        try
            qLineStylespec{1,Numofcolor} =  LineStyledef{NumIndex};
        catch
            qLineStylespec{1,Numofcolor} = '-';
        end
    end
end
%%check line marker
qLineMarkerspec = p_Results.LineMarker;
if isempty(qLineMarkerspec)
    for Numofcolor = 1:numel(OverlayArray)
        NumIndex = ceil(Numofcolor/7);
        try
            qLineMarkerspec{1,Numofcolor} =  LineMarkerdef{NumIndex};
        catch
            qLineMarkerspec{1,Numofcolor} = 'none';
        end
    end
end

%%check line width
qLineWidthspec = p_Results.LineWidth;
if isempty(qLineWidthspec)
    for Numofcolor = 1:numel(OverlayArray)
        qLineWidthspec(1,Numofcolor) =1;
    end
end

%%legend name
qLegendName = p_Results.LegendName;
if isempty(qLegendName)
    qLegendName = LegendNamedef;
end

%%Legend font
qFontLeg = p_Results.LegendFont;
if isempty(qFontLeg)
    qFontLeg = 'Helvetica';
end

%%legend fontsize
qFontSizeLeg = p_Results.LegendFontsize;
if isempty(qFontSizeLeg)
    qFontSizeLeg = 10;
end

%%Channel/bin/ERPset Label
qCBELabels  = p_Results.Labeloc;
if ~isempty(qCBELabels)
    if numel(qCBELabels)~=3
        qCBELabels = [0 70 1];
    end
    if qCBELabels(1) >100 ||  qCBELabels(1)<-100
        qCBELabels(1) = 0;
    end
    if qCBELabels(3) ~=1 && qCBELabels(3)~=0
        qCBELabels(3) = 1;
    end
end

qCBEFont = p_Results.Labelfont;
if isempty(qCBEFont)
    qCBEFont ='Helvetica';
end

qCBEFontsize = p_Results.Labelfontsize;
if isempty(qCBEFontsize)
    qCBEFontsize =10;
end

qPolarityWave = p_Results.YDir;
if isempty(qPolarityWave) || numel(qPolarityWave)~=1 || (qPolarityWave~=1 && qPolarityWave~=0)
    qPolarityWave = 1;
end

%%-----------------------standard error of mean----------------------------
if isempty(p_Results.SEM)
    qStanderr = 0;
end
if numel(p_Results.SEM)~=1
    qStanderr = 0;
elseif p_Results.SEM<0
    qStanderr = 0;
else
    qStanderr = ceil(p_Results.SEM);
end

%%Transparency
TransparencyLabel = p_Results.Transparency;
if isempty(TransparencyLabel)
    qTransparency = 0;
else
    qTransparency = TransparencyLabel;
end

%%grid space between rows/or columns
qGridspace = p_Results.GridSpace;
if isempty(qGridspace) || numel(qGridspace)~=4 || (size(qGridspace,1)~=2 || size(qGridspace,2)~=2)
    qGridspace =[1 100; 1 20];
else
    [rowgs,columgs] = size(qGridspace);
    if rowgs~=2 || columgs~=2
        qGridspace =[1 100; 1 20];
    else
        if qGridspace(1,1)~=1 && qGridspace(1,1)~=2
            qGridspace(1,1) =1;
        end
        if (qGridspace(1,1)==1 && qGridspace(1,2)<=0)
            qGridspace(1,2) =100;
        elseif (qGridspace(1,1)==2 && (qGridspace(1,2)<=0|| qGridspace(1,2)>100))
            qGridspace(1,2) =100;
        end
        if qGridspace(2,1)~=1 && qGridspace(2,1)~=2
            qGridspace(2,1) =1;
        end
        if (qGridspace(2,1)==1 && qGridspace(2,2)<=0)
            qGridspace(2,2) =20;
        elseif (qGridspace(2,1)==2 && (qGridspace(2,2)<=0|| qGridspace(2,2)>=100))
            qGridspace(2,2) =20;
        end
    end
end

%%--------X axis--------------------
try
    ERPIN = ALLERP(CURRENTPLOT);
catch
    ERPIN = ALLERP(end);
end
qtimeRange =unique(p_Results.TimeRange);
if isempty(qtimeRange) || numel(qtimeRange)==1
    qtimeRange(1) =  timeRangedef(1);
    qtimeRange(2) =  timeRangedef(end);
end
if qtimeRange(1)> qtimeRange(2)
    qtimeRange = fliplr(qtimeRange);
end

%%xticks
try
    [timeticksdef stepX]= default_time_ticks_studio(ERPIN, qtimeRange);
    timeticksdef = str2num(char(timeticksdef));
catch
    timeticksdef = [];
end
qXticks = unique(p_Results.Xticks);
if isempty(qXticks)
    qXticks =timeticksdef;
end
%%check if each element of xticks exceeds the time range. If so, the
%%corresponding element will be empty
if ~isempty(qtimeRange) && ~isempty(qXticks) %%check xticks
    try
        count =0;
        XtickDis =[];
        for Numofxtick = 1:numel(qXticks)
            if qXticks(Numofxtick) < qtimeRange(1) || qXticks(Numofxtick) > qtimeRange(end)
                count = count+1;
                XtickDis(count) =  Numofxtick;
            end
        end
        qXticks(XtickDis) = [];
    catch
    end
end

qxticklabel = p_Results.Xticklabel;
if isempty(qxticklabel)
    qxticklabel = 'on';
end

qXlabelfont = p_Results.Xlabelfont;
if isempty(qXlabelfont)
    qXlabelfont = 'Helvetica';
end
qXlabelfontsize = p_Results.Xlabelfontsize;
if isempty(qXlabelfontsize)
    qXlabelfontsize =10;
end

qXlabelcolor = p_Results.Xlabelcolor;
if isempty(qXlabelcolor)
    qXlabelcolor = [0 0 0];
end
if isempty(qXlabelcolor)
    qXlabelcolor = [0 0 0];
end


qXunits  =  p_Results.Xunits;
if isempty(qXunits)
    qXunits = 'on';
end

qMinorticksX = p_Results.MinorTicksX;
if isempty(qMinorticksX)
    qMinorticksX = 0;
end


qxtickprecision = p_Results.Xtickdecimal;
if isempty(qxtickprecision)|| qxtickprecision<0
    qxtickprecision =0;
end
qxtickprecision = ceil(qxtickprecision);

qxdisFlag= p_Results.XtickdisFlag;
if isempty(qxdisFlag)|| (qxdisFlag~=1 && qxdisFlag~=0)
    qxdisFlag =1;
end


%%----------------------Y axis---------------------------------------------
datresh = squeeze(ERPdatadef(qchanArray,:,qbinArray,:));
yymax   = max(datresh(:));
yymin   = min(datresh(:));
if abs(yymax)<1 && abs(yymin)<1
    scalesdef(1:2) = [yymin*1.2 yymax*1.1]; % JLC. Mar 11, 2015
else
    scalesdef(1:2) = [floor(yymin*1.2) ceil(yymax*1.1)]; % JLC. Sept 26, 2012
end


yylim_out = f_erpAutoYLim(ALLERP, qERPsetArray,qPLOTORG,qbinArray, qchanArray);
try
    Yscalesdef = yylim_out(qCURRENTPLOT,:);
catch
    Yscalesdef = scalesdef;
end
qYscales = p_Results.YScales;
if isempty(qYscales)
    qYscales = Yscalesdef;
end
qYticks=p_Results.Yticks;
if isempty(qYticks) && ~isempty(qYticks) %%check Yticks
    qYticks = default_amp_ticks_viewer(qYscales);
end
if ~isempty(qYscales) && ~isempty(qYticks) %%check Yticks
    try
        count =0;
        ytickDis =[];
        for Numofytick = 1:numel(qYticks)
            if qYticks(Numofytick) < qYscales(1) || qYticks(Numofytick) > qYscales(end)
                count = count+1;
                ytickDis(count) =  Numofytick;
            end
        end
        qYticks(ytickDis) = [];
    catch
    end
end

qYticklabel = p_Results.Yticklabel;
if isempty(qYticklabel)
    qYticklabel = 'on';
end

qYlabelfont = p_Results.Ylabelfont;

if isempty(qYlabelfont)
    qYlabelfont = 'Helvetica';
end

qYlabelfontsize = p_Results.Ylabelfontsize;
if isempty(qYlabelfontsize)
    qYlabelfontsize=10;
end


qYlabelcolor = p_Results.Ylabelcolor;
if isempty(qYlabelcolor)
    qYlabelcolor = [0 0 0];
end
if isempty(qYlabelcolor)
    qYlabelcolor = [0 0 0];
end

qYunits = p_Results.Yunits;
if isempty(qYunits)
    qYunits = 'on';
end


qMinorTicksY = p_Results.MinorTicksY;
if isempty(qMinorTicksY)
    qMinorTicksY = 0;
end

qlegcolor = p_Results.LegtextColor;%%
if isempty(qlegcolor) || qlegcolor<0 || numel(qlegcolor)~=1 || (qlegcolor~=0 && qlegcolor~=1)
    qlegcolor = 1;
end

qlegcolumns= p_Results.Legcolumns;%%
if isempty(qlegcolumns) || qlegcolumns<0 || numel(qlegcolumns)~=1
    qlegcolumns =1;
end


try
    qFigureName = p_Results.FigureName;%%
catch
    qFigureName = '';
end


qFigbgColor = p_Results.FigbgColor;%% Figure background color
if isempty(qFigbgColor) || numel(qFigbgColor)~=3 || max(qFigbgColor)>1 ||  min(qFigbgColor)<0
    qFigbgColor = [1 1 1];
end

qLabelcolor = p_Results.Labelcolor;%%label text color
if isempty(qLabelcolor) || size(qLabelcolor,2)~=3 || max(qLabelcolor)>1 ||  min(qLabelcolor)<0
    qLabelcolor = [0 0 0];
end

qYtickdecimal = p_Results.Ytickdecimal;
if isempty(qYtickdecimal) || numel(qYtickdecimal)~=1 || qYtickdecimal<0
    qYtickdecimal =1;
end
if isempty(qFigureName)
    qFigureName = 'My Viewer';
end
if isempty(qLabelsName)
    qCBELabels = [];
end

qFigOutpos = p_Results.FigOutpos;
%
%%-------------Plot the ERP wave based on the above parameters-------------
if ~isempty(qFigureName) && shist~=4
    f_ploterpserpviewer(ALLERP,qCURRENTPLOT, qPLOTORG,qbinArray,qchanArray,qGridposArray,qplotBox,qBlc,qLineColorspec,qLineStylespec,qLineMarkerspec,qLineWidthspec,...
        qLegendName,qFontLeg,qFontSizeLeg,qCBELabels,qCBEFont,qCBEFontsize,qPolarityWave,qStanderr,qTransparency,qGridspace,qtimeRange,qXticks,qxticklabel,...
        qXlabelfont,qXlabelfontsize,qXlabelcolor,qMinorticksX,qXunits,qYscales,qYticks,qYticklabel,qYlabelfont,qYlabelfontsize,qYlabelcolor,qYunits,qMinorTicksY,...
        qLabelsName,qERPsetArray,qlegcolor,qlegcolumns,qFigureName,qFigbgColor,qLabelcolor,qYtickdecimal,qxtickprecision,qxdisFlag,qFigOutpos);
end




% History command
%

fn = fieldnames(p.Results);
skipfields = {'ALLERP','CURRENTPLOT','ERPsetArray', 'binArray', 'chanArray'};

if qMinorticksX(1) ==0
    skipfields{length(skipfields)+1} = 'MinorTicksX';
end

if qMinorTicksY(1) ==0
    skipfields{length(skipfields)+1} = 'MinorTicksY';
end
if isempty(qCBELabels)
    skipfields{length(skipfields)+1} = 'Labeloc';
    skipfields{length(skipfields)+1} = 'Labelcolor';
    skipfields{length(skipfields)+1} = 'Labelfontsize';
    skipfields{length(skipfields)+1} = 'Labelfont';
    skipfields{length(skipfields)+1} = 'LabelsName';
end


BinArraystr  = vect2colon(qbinArray, 'Sort','yes');
chanArraystr = vect2colon(qchanArray);
CURRENTPLOTStr = num2str(CURRENTPLOT);
qERPsetArraystr = vect2colon(qERPsetArray);
% PLOTORGstr = vect2colon(qPLOTORG);
erpcom     = sprintf( 'ALLERP = pop_plotERPwaviewer( %s, %s, %s,%s, %s', 'ALLERP',CURRENTPLOTStr, qERPsetArraystr, BinArraystr, chanArraystr);

for q=1:length(fn)
    fn2com = fn{q}; % inputname
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com); %  input value
        if ~isempty(fn2res)
            if ischar(fn2res)
                if ~strcmpi(fn2res,'off')
                    erpcom = sprintf( '%s, ''%s'', ''%s''', erpcom, fn2com, fn2res);
                end
            elseif iscell(fn2res)
                nn = length(fn2res);
                erpcom = sprintf( '%s, ''%s'', {''%s'' ', erpcom, fn2com, fn2res{1});
                for ff=2:nn
                    erpcom = sprintf( '%s, ''%s'' ', erpcom, fn2res{ff});
                end
                erpcom = sprintf( '%s}', erpcom);
            elseif isnumeric(fn2res)
                if ~ismember_bc2(fn2com,{'LineColor','GridSpace','GridposArray'})
                    erpcom = sprintf( '%s, ''%s'', %s', erpcom, fn2com, vect2colon(fn2res,'Repeat','on'));
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
                    erpcom = sprintf( '%s, ''%s'', [%s', erpcom,fn2com,fn2res);
                    erpcom = sprintf( '%s]', erpcom);
                end
                
            else
                %                 if ~ismember_bc2(fn2com,{'xscale','yscale'})
                %                     erpcom = sprintf( '%s, ''%s'', %s', erpcom, fn2com, vect2colon(fn2res,'Repeat','on'));
                %                 else
                %                     xyscalestr = sprintf('[ %.1f %.1f  %s ]', fn2res(1), fn2res(2), vect2colon(fn2res(3:end),'Delimiter','off'));
                %                     erpcom = sprintf( '%s, ''%s'', %s', erpcom, fn2com, xyscalestr);
                %                 end
            end
        end
    end
end
erpcom = sprintf( '%s );', erpcom);
% get history from script. ERP
% shist = 1;
switch shist
    case 1 % from GUI
        displayEquiComERP(erpcom);
    case 2 % from script
        for i=1:length(ALLERP)
            ALLERP(i) = erphistory(ALLERP(i), [], erpcom, 1);
        end
    case 3
         % implicit 
    case 4
        displayEquiComERP(erpcom);
       
    otherwise %off or none
        erpcom = '';
        return
end
return;