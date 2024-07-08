% PURPOSE:  pop_plotmvpcset.m
%           plot ALLMVPC waves
%


%%FORMAT:
% [ALLMVPC, mvpcom] = pop_plotmvpcset(ALLMVPC,'MVPCArray',MVPCArray,'timeRange',qtimeRange,'Xticks',qXticks,'Xtickdecimal',qXtickdecimal,...
%         'Xlabelfont',qXlabelfont,'Xlabelfontsize',qXlabelfontsize,'Xlabelcolor',qXlabelcolor,'YScales',qYScales,'Yticks',qYticks,...
%         'Ytickdecimal',qYtickdecimal,'Ylabelfont',qYlabelfont,'Ylabelfontsize',qYlabelfontsize,'Ylabelcolor',qYlabelcolor,'Standerr',qStanderr,...
%         'Transparency',qTransparency,'LineColorspec',qLineColorspec,'LineStylespec',qLineStylespec,'LineMarkerspec',qLineMarkerspec,...
%         'LineWidthspec',qLineWidthspec,'FontLeg',qFontLeg,'TextcolorLeg',qTextcolorLeg,'Legcolumns',qLegcolumns,'FontSizeLeg',qFontSizeLeg,...
%         'chanLevel',qchanLevel,'figureName',figureName,'FigOutpos',figSize,'History', 'gui');


% Inputs:
%
%ALLMVPC                 -ALLMVPCSET
%MVPCArray           -index(es) of selected MVPCsets
%timeRange           - time range e.g, [-200 800]
%Xticks              - x tick labels e.g., [-200 0 200 400 600 800]
%Xtickdecimal        - xtick precision e.g., 0
%Xlabelfont          - font name for xticklabels e.g., 'Helvetica'
%Xlabelfontsize      -font size for xticklabels  e.g., 12
%Xlabelcolor         -color [r g b] for xticklabels e.g., [0 0 0]
%YScales             -amplitude scale e.g., [0 1]
%Yticks              -yticks e.g., [0 0.2 0.4 0.6 0.8 1]
%Ytickdecimal        -precision for yticklabels e.g., 1
%Ylabelfont          -font name for yticklabels e.g., 'Helvetica'
%Ylabelfontsize      -fontsize for yticklabels e.g., 12
%Ylabelcolor         -color [r g b]  for yticklabels e.g., [0 0 0]
%Standerr            -standard error of mean e.g., 1
%Transparency        -Transparency for SEM e.g., 0.2
%LineColorspec       -line color e.g., [0,0,0;1,0,0] for two lines
%LineStylespec       -line styles e.g., {'-','-'} for two lines
%LineMarkerspec      -line marker e.g., {'o','o'} for two lines
%LineWidthspec       -line width e.g., [1 1] for two lines
%FontLeg             -font name for legend  e.g., 'Helvetica'
%TextcolorLeg        -color for legend text 1 is the black; 0 is same to lines
%Legcolumns          -columns for legend  e.g., 2
%FontSizeLeg         -fontsize for legend e.g., 12
%chanLevel           -display chance level? 1 is yes; 0 is no
%figureName          - figure name e.g., 'decoding_accuracy'
%figSize             -width and height for the figure  e.g., [1800 900]



% *** This function is part of ERPLAB Studio ***
% Author: Guanghui Zhang & Steven Luck
% ghzhang@ucdavis.edu, sjluck@ucdavis.edu
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2024



function [ALLMVPC,mvpcom] = pop_plotmvpcset(ALLMVPC,varargin)

mvpcom = '';
if nargin < 1
    help pop_plotmvpcset
    return;
end

if isempty(ALLMVPC)%%
    beep;
    disp('ALLMVPC is empty');
    return;
end

if nargin==1
    
    
    MVPCArray=1:length(ALLMVPC);
    [serror, msgwrng] = f_checkmvpc(ALLMVPC,MVPCArray);
    if serror==1
        MVPCArray  = length(ALLMVPC);
    end
    MVPC = ALLMVPC(MVPCArray(1));
    
    qtimeRange = [MVPC.times(1),MVPC.times(end)];
    [qXticks stepX]= default_time_ticks_decode(MVPC, qtimeRange);
    qXtickdecimal = 0;
    qXlabelfont='Helvetica';
    qXlabelfontsize=12;
    qXlabelcolor = [0 0 0];%%black
    [def, minydef, maxydef] = default_amp_ticks_decode(ALLMVPC(MVPCArray));
    qYScales = [minydef,maxydef];
    qYticks = str2num(def);
    qYtickdecimal = 1;
    qYlabelfont = 'Helvetica';
    qYlabelfontsize = 12;
    qYlabelcolor = [0 0 0];
    qStanderr=1;
    qTransparency=0.2;
    
    %%line color
    [lineNameStr,linecolors,linetypes,linewidths,~,~,~,linecolorsrgb] = f_get_lineset_ERPviewer();
    lineset_str  =table(lineNameStr,linecolors,linetypes,linewidths);
    LineData = table2cell(lineset_str);
    LineDataColor = linecolorsrgb;
    for Numofplot = 1: numel(MVPCArray)  %%using RGB or r,g,b,o?
        %%determine the specific RGB value for the defined color
        if Numofplot <= length(LineDataColor)
            cellColor = str2num(LineDataColor{Numofplot});
            if numel(cellColor)~=3 || min(cellColor)<0 || max(cellColor)>1
                qLineColorspec(Numofplot,:)  = [0 0 0];%% black
            else
                qLineColorspec(Numofplot,:)  = cellColor;%% black
            end
        else
            qLineColorspec(Numofplot,1)  = [0 0 0];
        end
        %%Line style
        CellStyle = LineData{Numofplot,3};
        [C_style,IA_style] = ismember_bc2(CellStyle,lineStylrstr);
        if C_style==1
            switch IA_style %{'solid','dash','dot','dashdot','plus','circle','asterisk'};
                case 1
                    qLineMarkerspec{1,Numofplot} = 'none';
                    qLineStylespec{1,Numofplot}   = '-';
                case 2
                    qLineMarkerspec{1,Numofplot} = 'none';
                    qLineStylespec{1,Numofplot}   = '--';
                case 3
                    qLineMarkerspec{1,Numofplot} = 'none';
                    qLineStylespec{1,Numofplot}   = ':';
                case 4
                    qLineMarkerspec{1,Numofplot} = 'none';
                    qLineStylespec{1,Numofplot}   = '-.';
                case 5
                    qLineStylespec{1,Numofplot}   = '-';
                    qLineMarkerspec{1,Numofplot} = '+';
                case 6
                    qLineStylespec{1,Numofplot}   = '-';
                    qLineMarkerspec{1,Numofplot} = 'o';
                case 7
                    qLineStylespec{1,Numofplot}   = '-';
                    qLineMarkerspec{1,Numofplot} = '*';
                otherwise
                    qLineStylespec{1,Numofplot}   = '-';
                    qLineMarkerspec{1,Numofplot} = 'none';
            end
        else
            LineStylespec{1,Numofplot}   = '-';
            LineMarkerspec{1,Numofplot} = 'none';
        end%% end of line style
        
        %%line width
        try
            qLineWidthspec(1,Numofplot) = LineData{Numofplot,4};
        catch
            qLineWidthspec(1,Numofplot) =1;
        end%% end for setting of line width
    end%% end of loop for number of line
    
    qFontLeg= 'Helvetica';
    qTextcolorLeg = 1;
    qLegcolumns =  ceil(sqrt(numel(MVPCArray)));
    qFontSizeLeg = 12;
    qchanLevel=1;
    
    
    %%figure name if any
    figureName = '';
    %%Figure position
    figSize = [];
    [ALLMVPC, mvpcom] = pop_plotmvpcset(ALLMVPC,'MVPCArray',MVPCArray,'timeRange',qtimeRange,'Xticks',qXticks,'Xtickdecimal',qXtickdecimal,...
        'Xlabelfont',qXlabelfont,'Xlabelfontsize',qXlabelfontsize,'Xlabelcolor',qXlabelcolor,'YScales',qYScales,'Yticks',qYticks,...
        'Ytickdecimal',qYtickdecimal,'Ylabelfont',qYlabelfont,'Ylabelfontsize',qYlabelfontsize,'Ylabelcolor',qYlabelcolor,'Standerr',qStanderr,...
        'Transparency',qTransparency,'LineColorspec',qLineColorspec,'LineStylespec',qLineStylespec,'LineMarkerspec',qLineMarkerspec,...
        'LineWidthspec',qLineWidthspec,'FontLeg',qFontLeg,'TextcolorLeg',qTextcolorLeg,'Legcolumns',qLegcolumns,'FontSizeLeg',qFontSizeLeg,...
        'chanLevel',qchanLevel,'figureName',figureName,'FigOutpos',figSize,'History', 'gui');
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
p.addRequired('ALLMVPC');

%Option(s)
p.addParamValue('MVPCArray',[],@isnumeric);
p.addParamValue('timeRange',[],@isnumeric);
p.addParamValue('Xticks',[],@isnumeric);
p.addParamValue('Xtickdecimal',0, @isnumeric);
p.addParamValue('Xlabelfont','Helvetica', @ischar);
p.addParamValue('Xlabelfontsize',12, @isnumeric);
p.addParamValue('Xlabelcolor',[0 0 0], @isnumeric);
p.addParamValue('YScales',[], @isnumeric);
p.addParamValue('Yticks',[], @isnumeric);
p.addParamValue('Ytickdecimal',1, @isnumeric);
p.addParamValue('Ylabelfont','Helvetica', @ischar);
p.addParamValue('Ylabelfontsize',12, @isnumeric);
p.addParamValue('Ylabelcolor',[0 0 0], @isnumeric);
p.addParamValue('Standerr',1, @isnumeric);
p.addParamValue('Transparency',0.2, @isnumeric);
p.addParamValue('LineColorspec',[], @isnumeric);
p.addParamValue('LineStylespec',[], @iscell);
p.addParamValue('LineMarkerspec',[], @iscell);
p.addParamValue('LineWidthspec',[], @isnumeric);
p.addParamValue('FontLeg','Helvetica', @ischar);
p.addParamValue('TextcolorLeg',1, @isnumeric);
p.addParamValue('Legcolumns',[], @isnumeric);
p.addParamValue('FontSizeLeg',12, @isnumeric);
p.addParamValue('chanLevel',1, @isnumeric);
p.addParamValue('figureName','', @ischar);
p.addParamValue('FigOutpos', [], @isnumeric);
p.addParamValue('ErrorMsg', '', @ischar);
p.addParamValue('History', '', @ischar); % history from scripting

p.parse(ALLMVPC,varargin{:});

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

MVPCArray = p_Results.MVPCArray;
if isempty(MVPCArray) || any(MVPCArray(:)<1) || any(MVPCArray(:)>length(ALLMVPC))
    MVPCArray  = length(ALLMVPC);
end
[serror, msgwrng] = f_checkmvpc(ALLMVPC,MVPCArray);
if serror==1
    MVPCArray  = length(ALLMVPC);
end
MVPC = ALLMVPC(MVPCArray(1));

%%time range
qtimeRange = p_Results.timeRange;
if isempty(qtimeRange) || numel(qtimeRange)~=2 || qtimeRange(1)>MVPC.times(end) || qtimeRange(2)<MVPC.times(1)
    qtimeRange = [MVPC.times(1),MVPC.times(end)];
end

%%xticks
qXticks = p_Results.Xticks;
[timeticksdef stepX]= default_time_ticks_decode(MVPC, qtimeRange);
if isempty(qXticks) || numel(qXticks)<=1
    qXticks =  str2num(timeticksdef);
end
%%x tick precision
qXtickdecimal =  p_Results.Xtickdecimal;
if isempty(qXtickdecimal) || ~isnumeric(qXtickdecimal) || numel(qXtickdecimal)~=1 || any(qXtickdecimal(:)<1)
    qXtickdecimal =0;
end
%%font for x axis
qXlabelfont = p_Results.Xlabelfont;
if isempty(qXlabelfont) ||~ischar(qXlabelfont)
    Xlabelfont = 'Helvetica';
end
%%fontsize for x axis
qXlabelfontsize = p_Results.Xlabelfontsize;
if isempty(qXlabelfontsize) || ~isnumeric(qXlabelfontsize) || numel(qXlabelfontsize)~=1 || any(qXlabelfontsize(:)<1)
    qXlabelfontsize = 12;
end
%%text color for x axis
qXlabelcolor = p_Results.Xlabelcolor;
if isempty(qXlabelcolor) || ~isnumeric(qXlabelcolor) || any(qXlabelcolor(:)<0) || any(qXlabelcolor(:)>1) || numel(qXlabelcolor)~=3
    qXlabelcolor = [0 0 0];
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%------------------------settings for y axis------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[def, minydef, maxydef] = default_amp_ticks_decode(ALLMVPC(MVPCArray));
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
y_scale_def = [minydef,maxydef];
qYScales = p_Results.YScales;
if isempty(qYScales) || numel(qYScales)~=2
    qYScales = y_scale_def;
end
defyticks = default_amp_ticks_viewer(qYScales);
qYticksdef = str2num(defyticks);
qYticks = p_Results.Yticks;
if isempty(qYticks) || numel(qYticks)<2
    qYticks = qYticksdef;
end

%%precision for y axis
qYtickdecimal = p_Results.Ytickdecimal;
if isempty(qYtickdecimal) || ~isnumeric(qYtickdecimal) || numel(qYtickdecimal)~=1 || any(qYtickdecimal(:)<1)
    qYtickdecimal=1;
end
%%font for y axis
qYlabelfont = p_Results.Ylabelfont;
if isempty(qYlabelfont) %%|| ~char(qYlabelfont)
    qYlabelfont = 'Helvetica';
end

%%font size for y axis
qYlabelfontsize=p_Results.Ylabelfontsize;
if isempty(qYlabelfontsize) || numel(qYlabelfontsize)~=1 || any(qYlabelfontsize(:)<1)
    qYlabelfontsize = 12;
end

%%text color for y axis
qYlabelcolor = p_Results.Ylabelcolor;
if isempty(qYlabelcolor) || ~isnumeric(qYlabelcolor) || numel(qYlabelcolor)~=3 || any(qYlabelcolor(:)<0) || any(qYlabelcolor(:)>1)
    qYlabelcolor = [0 0 0];
end

%%standard error of mean
qStanderr = p_Results.Standerr;
if isempty(qStanderr) || numel(qStanderr)~=1 || any(qStanderr<0) || any(qStanderr>10)
    qStanderr=1;
end
qTransparency = p_Results.Transparency;
if isempty(qTransparency) || numel(qTransparency)~=1 || any(qTransparency<0)|| any(qTransparency>1)
    qTransparency=0.2;
end

%%settings for lines
%%line color
[lineNameStr,linecolors,linetypes,linewidths,~,~,~,linecolorsrgb] = f_get_lineset_ERPviewer();
lineset_str  =table(lineNameStr,linecolors,linetypes,linewidths);
LineData = table2cell(lineset_str);
LineDataColor = linecolorsrgb;
lineStylrstr = {'solid','dash','dot','dashdot','plus','circle','asterisk'};
for Numofplot = 1: numel(MVPCArray)  %%using RGB or r,g,b,o?
    %%determine the specific RGB value for the defined color
    if Numofplot <= length(LineDataColor)
        cellColor = str2num(LineDataColor{Numofplot});
        if numel(cellColor)~=3 || min(cellColor)<0 || max(cellColor)>1
            LineColorspecdef(Numofplot,:)  = [0 0 0];%% black
        else
            LineColorspecdef(Numofplot,:)  = cellColor;%% black
        end
    else
        LineColorspecdef(Numofplot,1)  = [0 0 0];
    end
    %%Line style
    CellStyle = LineData{Numofplot,3};
    [C_style,IA_style] = ismember_bc2(CellStyle,lineStylrstr);
    if C_style==1
        switch IA_style %{'solid','dash','dot','dashdot','plus','circle','asterisk'};
            case 1
                LineMarkerspecdef{1,Numofplot} = 'none';
                LineStylespecdef{1,Numofplot}   = '-';
            case 2
                LineMarkerspecdef{1,Numofplot} = 'none';
                LineStylespecdef{1,Numofplot}   = '--';
            case 3
                LineMarkerspecdef{1,Numofplot} = 'none';
                LineStylespecdef{1,Numofplot}   = ':';
            case 4
                LineMarkerspecdef{1,Numofplot} = 'none';
                LineStylespecdef{1,Numofplot}   = '-.';
            case 5
                LineStylespecdef{1,Numofplot}   = '-';
                LineMarkerspecdef{1,Numofplot} = '+';
            case 6
                LineStylespecdef{1,Numofplot}   = '-';
                LineMarkerspecdef{1,Numofplot} = 'o';
            case 7
                LineStylespecdef{1,Numofplot}   = '-';
                LineMarkerspecdef{1,Numofplot} = '*';
            otherwise
                LineStylespecdef{1,Numofplot}   = '-';
                LineMarkerspecdef{1,Numofplot} = 'none';
        end
    else
        LineStylespecdef{1,Numofplot}   = '-';
        LineMarkerspecdef{1,Numofplot} = 'none';
    end%% end of line style
    
    %%line width
    try
        LineWidthspecdef(1,Numofplot) = LineData{Numofplot,4};
    catch
        LineWidthspecdef(1,Numofplot) =1;
    end%% end for setting of line width
end%% end of loop for number of line

qLineColorspec = p_Results.LineColorspec;
if isempty(qLineColorspec) || ~isnumeric(qLineColorspec)
    qLineColorspec = LineColorspecdef;
end

%%line color
for Numofmvpc = 1:numel(MVPCArray)
    try
        colornames =  qLineColorspec(Numofmvpc,:);
        if isempty(colornames) || numel(colornames)~=3 || any(colornames(:)<0)|| any(colornames(:)>1)
            colornames = LineColorspecdef(Numofmvpc,:);
        end
        qLineColorspec(Numofmvpc,:) = colornames;
    catch
        qLineColorspec(Numofmvpc,:)  = LineColorspecdef(Numofmvpc,:);
    end
end

%%line styles
qLineStylespec = p_Results.LineStylespec;
if isempty(qLineStylespec)
    qLineStylespec = LineStylespecdef;
end
for Numofmvpc = 1:numel(MVPCArray)
    try
        colornames =  qLineStylespec{Numofmvpc};
        if isempty(colornames) || ~ischar(colornames) || ~ismember_bc2(colornames,{'-','--',':','-.','none'})
            colornames = LineStylespecdef{Numofmvpc};
        end
        qLineStylespec{Numofmvpc} = colornames;
    catch
        qLineStylespec{Numofmvpc}  = LineStylespecdef{Numofmvpc};
    end
end

%%line marks
qLineMarkerspec = p_Results.LineMarkerspec;
if isempty(qLineMarkerspec)
    qLineMarkerspec = LineMarkerspecdef;
end
for Numofmvpc = 1:numel(MVPCArray)
    try
        colornames =  qLineMarkerspec{Numofmvpc};
        if isempty(colornames) || ~ischar(colornames)
            colornames = LineMarkerspecdef{Numofmvpc};
        end
        qLineMarkerspec{Numofmvpc} = colornames;
    catch
        qLineMarkerspec{Numofmvpc}  =  LineMarkerspecdef{Numofmvpc};
    end
end
%%line width
qLineWidthspec = p_Results.LineWidthspec;
if isempty(qLineWidthspec) || ~isnumeric(LineWidthspecdef)
    qLineWidthspec = LineWidthspecdef;
end
for Numofmvpc = 1:numel(MVPCArray)
    try
        linewidthone =  qLineWidthspec(Numofmvpc);
        if isempty(linewidthone) || ~isnumeric(linewidthone) || any(linewidthone(:)<1)
            linewidthone =LineWidthspecdef(Numofmvpc);
        end
        qLineWidthspec(Numofmvpc) = linewidthone;
    catch
        qLineWidthspec(Numofmvpc)  = LineWidthspecdef(Numofmvpc);
    end
end

qchanLevel= p_Results.chanLevel;
if isempty(qchanLevel) || numel(qchanLevel)~=1 || (qchanLevel~=0 && qchanLevel~=1)
    qchanLevel=1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%------------------------------setting for legend-------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
qFontLeg = p_Results.FontLeg;
if isempty(qFontLeg) || ~ischar(qFontLeg)
    qFontLeg ='Helvetica';
end
qTextcolorLeg = p_Results.TextcolorLeg;
if isempty(qTextcolorLeg) || ~isnumeric(qTextcolorLeg) || numel(qTextcolorLeg)~=1 || (qTextcolorLeg~=0 && qTextcolorLeg~=1)
    qTextcolorLeg=1;
end
qLegcolumns = p_Results.Legcolumns;
if isempty(qLegcolumns) || ~isnumeric(qLegcolumns) || numel(qLegcolumns)~=1|| any(qLegcolumns(:)<1)
    qLegcolumns = ceil(sqrt(numel(MVPCArray)));
end
qFontSizeLeg = p_Results.FontSizeLeg;
if isempty(qFontSizeLeg) || ~isnumeric(qFontSizeLeg) || numel(qFontSizeLeg)~=1 || any(qFontSizeLeg(:)<1)
    qFontSizeLeg = 12;
end

qFigOutpos = p_Results.FigOutpos;
qFigureName = p_Results.figureName;
%%%%%%%%%%%%%%%
% insert the function that is to plot the ALLMVPC
if  shist~=4 %%~isempty(qFigureName) &&
    f_plotabmvpcwave(ALLMVPC,MVPCArray,qtimeRange,qXticks,qXtickdecimal,qXlabelfont,qXlabelfontsize,qXlabelcolor,...
        qYScales,qYticks,qYtickdecimal,qYlabelfont,qYlabelfontsize,qYlabelcolor,qStanderr,qTransparency,...
        qLineColorspec,qLineStylespec,qLineMarkerspec,qLineWidthspec,qFontLeg,qTextcolorLeg,qLegcolumns,qFontSizeLeg,qchanLevel,...
        qFigOutpos,qFigureName)
end

%%history
fn = fieldnames(p.Results);
skipfields = {'ALLMVPC'};
mvpcom     = sprintf( 'ALLMVPC = pop_plotmvpcset( %s', 'ALLMVPC');

for q=1:length(fn)
    fn2com = fn{q}; % inputname
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com); %  input value
        if ~isempty(fn2res)
            if ischar(fn2res)
                if strcmpi(fn2com,'History') && strcmpi(fn2res,'command')
                    fn2res = 'gui';
                end
                if ~strcmpi(fn2res,'off')
                    mvpcom = sprintf( '%s, ''%s'', ''%s''', mvpcom, fn2com, fn2res);
                end
            elseif iscell(fn2res)
                nn = length(fn2res);
                mvpcom = sprintf( '%s, ''%s'', {''%s'' ', mvpcom, fn2com, fn2res{1});
                for ff=2:nn
                    mvpcom = sprintf( '%s, ''%s'' ', mvpcom, fn2res{ff});
                end
                mvpcom = sprintf( '%s}', mvpcom);
            elseif isnumeric(fn2res)
                if ~ismember_bc2(fn2com,{'LineColorspec'})
                    mvpcom = sprintf( '%s, ''%s'', %s', mvpcom, fn2com, vect2colon(fn2res,'Repeat','on'));
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
                    mvpcom = sprintf( '%s, ''%s'', [%s', mvpcom,fn2com,fn2res);
                    mvpcom = sprintf( '%s]', mvpcom);
                end
                
            else
                %                 if ~ismember_bc2(fn2com,{'xscale','yscale'})
                %                     mvpcom = sprintf( '%s, ''%s'', %s', mvpcom, fn2com, vect2colon(fn2res,'Repeat','on'));
                %                 else
                %                     xyscalestr = sprintf('[ %.1f %.1f  %s ]', fn2res(1), fn2res(2), vect2colon(fn2res(3:end),'Delimiter','off'));
                %                     mvpcom = sprintf( '%s, ''%s'', %s', mvpcom, fn2com, xyscalestr);
                %                 end
            end
        end
    end
end


mvpcom = sprintf( '%s );', mvpcom);
% get history from script. ERP
% shist = 1;
switch shist
    case 1 % from GUI
        displayEquiComERP(mvpcom);
    case 2 % from script
    case 3
        % implicit
    case 4
        displayEquiComERP(mvpcom);
    otherwise %off or none
        mvpcom = '';
        return
end



return;