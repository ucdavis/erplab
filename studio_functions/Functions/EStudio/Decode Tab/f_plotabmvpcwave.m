


% Inputs:
%
%ALLMVPC                 -ALLMVPCSET
%MVPCArray           -index(es) of selected MVPCsets
%qtimeRange           - time range e.g, [-200 800]
%qXticks              - x tick labels e.g., [-200 0 200 400 600 800]
%qXtickdecimal        - xtick precision e.g., 0
%qXlabelfont          - font name for xticklabels e.g., 'Helvetica'
%qXlabelfontsize      -font size for xticklabels  e.g., 12
%qXlabelcolor         -color [r g b] for xticklabels e.g., [0 0 0]
%qYScales             -amplitude scale e.g., [0 1]
%qYticks              -yticks e.g., [0 0.2 0.4 0.6 0.8 1]
%qYtickdecimal        -precision for yticklabels e.g., 1
%qYlabelfont          -font name for yticklabels e.g., 'Helvetica'
%qYlabelfontsize      -fontsize for yticklabels e.g., 12
%qYlabelcolor         -color [r g b]  for yticklabels e.g., [0 0 0]
%Standerr            -standard error of mean e.g., 1
%Transparency        -Transparency for SEM e.g., 0.2
%qLineColorspec       -line color e.g., [0,0,0;1,0,0] for two lines
%qLineStylespec       -line styles e.g., {'-','-'} for two lines
%qLineMarkerspec      -line marker e.g., {'o','o'} for two lines
%qLineWidthspec       -line width e.g., [1 1] for two lines
%qFontLeg             -font name for legend  e.g., 'Helvetica'
%qTextcolorLeg        -color for legend text 1 is the black; 0 is same to lines
%qLegcolumns          -columns for legend  e.g., 2
%qFontSizeLeg         -fontsize for legend e.g., 12
%chanLevel           -display chance level? 1 is yes; 0 is no
%qFigureName          - figure name e.g., 'decoding_accuracy'
%qFigOutpos             -width and height for the figure  e.g., [1800 900]


function f_plotabmvpcwave(ALLMVPC,MVPCArray,qtimeRange,qXticks,qXtickdecimal,qXlabelfont,qXlabelfontsize,qXlabelcolor,...
    qYScales,qYticks,qYtickdecimal,qYlabelfont,qYlabelfontsize,qYlabelcolor,Standerr,Transparency,...
    qLineColorspec,qLineStylespec,qLineMarkerspec,qLineWidthspec,qFontLeg,qTextcolorLeg,qLegcolumns,qFontSizeLeg,chanLevel,...
    qFigOutpos,qFigureName)

%%------------Get the data and SEM (standard error of the mean)------------
if isempty(MVPCArray) || any(MVPCArray(:)<1) || any(MVPCArray(:)>length(ALLMVPC))
    MVPCArray  = length(ALLMVPC);
end
[serror, msgwrng] = f_checkmvpc(ALLMVPC,MVPCArray);
if serror==1
    MVPCArray  = MVPCArray(1);
end
MVPC = ALLMVPC(MVPCArray(1));


[bindata,bindataerror,timesnew] = f_getmvpcdata(ALLMVPC,MVPCArray,qtimeRange);

%%xticks
[timeticksdef stepX]= default_time_ticks_decode(MVPC, qtimeRange);
if isempty(qXticks) || numel(qXticks)<=1
    qXticks =  str2num(timeticksdef);
end
%%precision
if isempty(qXtickdecimal) || ~isnumeric(qXtickdecimal) || numel(qXtickdecimal)~=1 || any(qXtickdecimal(:)<1)
    qXtickdecimal=0;
end


%%font for x axis
if isempty(qXlabelfont) || ~ischar(qXlabelfont)
    qXlabelfont = 'Helvetica';
end
%%font size for x axis

if isempty(qXlabelfontsize) || ~isnumeric(qXlabelfontsize) || numel(qXlabelfontsize)~=1 || any(qXlabelfontsize(:)<1)
    qXlabelfontsize = 12;
end
%%text color for x axis
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
if isempty(qYScales) || numel(qYScales)~=2
    qYScales = y_scale_def;
end
%%y ticks
defyticks = default_amp_ticks_viewer(qYScales);
qYticksdef = str2num(defyticks);
if isempty(qYticks) || numel(qYticks)<2
    qYticks = qYticksdef;
end
%%precision
if isempty(qYtickdecimal) || ~isnumeric(qYtickdecimal) || numel(qYtickdecimal)~=1 || any(qYtickdecimal(:)<1)
    qYtickdecimal=1;
end
%%font for y axis
if isempty(qYlabelfont) %%|| ~char(qYlabelfont)
    qYlabelfont = 'Helvetica';
end
%%font size for y axis
if isempty(qYlabelfontsize) || numel(qYlabelfontsize)~=1 || any(qYlabelfontsize(:)<1)
    qYlabelfontsize = 12;
end
%%text color for y axis
if isempty(qYlabelcolor) || ~isnumeric(qYlabelcolor) || numel(qYlabelcolor)~=3 || any(qYlabelcolor(:)<0) || any(qYlabelcolor(:)>1)
    qYlabelcolor = [0 0 0];
end

%%standard error of mean
if isempty(Standerr) || numel(Standerr)~=1 || any(Standerr<0) || any(Standerr>10)
    Standerr=1;
end
if isempty(Transparency) || numel(Transparency)~=1 || any(Transparency<0)|| any(Transparency>1)
    Transparency=0.2;
end


%%line color
for Numofmvpc = 1:numel(MVPCArray)
    try
        colornames =  qLineColorspec(Numofmvpc,:);
        if isempty(colornames) || numel(colornames)~=3 || any(colornames(:)<0)|| any(colornames(:)>1)
            colornames = [0 0 0];
        end
        qLineColorspec(Numofmvpc,:) = colornames;
    catch
        qLineColorspec(Numofmvpc,:)  = [0 0 0];
    end
end


%%line styles
for Numofmvpc = 1:numel(MVPCArray)
    try
        colornames =  qLineStylespec{Numofmvpc};
        if isempty(colornames) || ~ischar(colornames) || ~ismember_bc2(colornames,{'-','--',':','-.','none'})
            colornames = 'none';
        end
        qLineStylespec{Numofmvpc} = colornames;
    catch
        qLineStylespec{Numofmvpc}  = '-';
    end
end
%%line marks
for Numofmvpc = 1:numel(MVPCArray)
    try
        colornames =  qLineMarkerspec{Numofmvpc};
        if isempty(colornames) || ~ischar(colornames)
            colornames = 'none';
        end
        qLineMarkerspec{Numofmvpc} = colornames;
    catch
        qLineMarkerspec{Numofmvpc}  = 'none';
    end
end
%%line width
for Numofmvpc = 1:numel(MVPCArray)
    try
        linewidthone =  qLineWidthspec(Numofmvpc);
        if isempty(linewidthone) || ~isnumeric(linewidthone) || any(linewidthone(:)<1)
            linewidthone =1;
        end
        qLineWidthspec(Numofmvpc) = linewidthone;
    catch
        qLineWidthspec(Numofmvpc)  = 1;
    end
end

if isempty(chanLevel) || numel(chanLevel)~=1 || (chanLevel~=0 && chanLevel~=1)
    chanLevel=1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%------------------------------setting for legend-------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(qFontLeg) || ~ischar(qFontLeg)
    qFontLeg ='Helvetica';
end

if isempty(qTextcolorLeg) || ~isnumeric(qTextcolorLeg) || numel(qTextcolorLeg)~=1 || (qTextcolorLeg~=0 && qTextcolorLeg~=1)
    qTextcolorLeg=1;
end
if isempty(qLegcolumns) || ~isnumeric(qLegcolumns) || numel(qLegcolumns)~=1|| any(qLegcolumns(:)<1)
    qLegcolumns = ceil(sqrt(numel(MVPCArray)));
end

if isempty(qFontSizeLeg) || ~isnumeric(qFontSizeLeg) || numel(qFontSizeLeg)~=1 || any(qFontSizeLeg(:)<1)
    qFontSizeLeg = 12;
end
extfig ='';
[pathstrfig, qFigureName, extfig] = fileparts(qFigureName) ;
if isempty(qFigureName)
    fig_gui= figure('Name',['<<Decoding accuracy>> '],...
        'NumberTitle','on','color',[1 1 1]);
end

if ~isempty(qFigureName)
    fig_gui= figure('Name',['<< ' qFigureName ' >> '],...
        'NumberTitle','on','color',[1 1 1]);
end
waveview = subplot(6, 1, [2:6],'align');
hold on;
try
    outerpos = fig_gui.OuterPosition;
    set(fig_gui,'outerposition',[1,1,qFigOutpos(1) 1.05*qFigOutpos(2)])
catch
    set(fig_gui,'outerposition',get(0,'screensize'));%%Maximum figure
end
if ~isempty(qFigureName)
    set(fig_gui,'visible','off');
end
set(fig_gui, 'Renderer', 'painters');%%vector figure
%%remove the margins of a plot

legendview = subplot(6, 1,1,'align');

ax = waveview;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
% ax.Position = [left bottom ax_width ax_height];
% ax.Position(3:4) = [ax_width ax_height];

%%check elements in qGridposArray

if chanLevel==1
    yline(waveview,ALLMVPC(MVPCArray(1)).chance,'--','Color' ,[0 0 0],'LineWidth',1);
end
timerangold = [ALLMVPC(MVPCArray(1)).times(1),ALLMVPC(MVPCArray(1)).times(end)];
[xxx, latsamp1, latdiffms] = closest(timesnew, timerangold);
if ~isempty(latsamp1)
    for Numofoverlay = 1:numel(MVPCArray)
        bindatatrs = bindata(latsamp1(1):latsamp1(2),Numofoverlay);
        bindataerrtrs = bindataerror(latsamp1(1):latsamp1(2),Numofoverlay);
        if  Standerr>=1 &&Transparency>0 %SEM
            yt1 = bindatatrs - bindataerrtrs.*Standerr;
            yt2 = bindatatrs + bindataerrtrs.*Standerr;
            fill(waveview,[timesnew(latsamp1(1):latsamp1(2)) fliplr(timesnew(latsamp1(1):latsamp1(2)))],[yt2' fliplr(yt1')], qLineColorspec(Numofoverlay,:), 'FaceAlpha', Transparency, 'EdgeColor', 'none');
        end
        try
            hplot11(Numofoverlay) = plot(waveview,timesnew(latsamp1(1):latsamp1(2)), bindatatrs,'LineWidth',qLineWidthspec(Numofoverlay),...
                'Color', qLineColorspec(Numofoverlay,:),'Marker',char(qLineMarkerspec{Numofoverlay}),...
                'LineStyle',char(qLineStylespec{Numofoverlay}));
        catch
            hplot11(Numofoverlay) = plot(waveview,timesnew(latsamp1(1):latsamp1(2)), bindatatrs,'LineWidth',1,...
                'Color', [0 0 0]);
        end
    end
end
set(waveview,'box','off');
xlim(waveview,[timesnew(1),timesnew(end)]);
ylim(waveview,qYScales)
%%x axis
if ~isempty(qXticks)
    waveview.XAxis.TickValues = qXticks;
    for Numofytick = 1:numel(qXticks)
        xtick_label= sprintf(['%.',num2str(qXtickdecimal),'f'],qXticks(Numofytick));
        waveview.XAxis.TickLabels{Numofytick,1} = xtick_label;
    end
end
waveview.XAxis.FontSize = qXlabelfontsize;
waveview.XAxis.FontName = qXlabelfont;
waveview.XAxis.Color = qXlabelcolor;
xlabel(waveview,'Time (ms)','FontSize',qXlabelfontsize,'FontWeight',...
    'normal','Color',qXlabelcolor,'FontName',qXlabelfont);
waveview.TickDir = 'out';
waveview.XAxis.LineWidth=1;

%%Y axis
if ~isempty(qYticks)
    waveview.YAxis.TickValues = qYticks;
    for Numofytick = 1:numel(qYticks)
        xtick_label= sprintf(['%.',num2str(qYtickdecimal),'f'],qYticks(Numofytick));
        waveview.YAxis.TickLabels{Numofytick,1} = xtick_label;
    end
end
waveview.YAxis.FontSize = qYlabelfontsize;
waveview.YAxis.FontName = qYlabelfont;
waveview.YAxis.Color = qYlabelcolor;
ylabel(waveview,'Decoding Accuracy','FontSize',qYlabelfontsize,'FontWeight',...
    'normal','Color',qYlabelcolor,'FontName',qYlabelfont);
waveview.YAxis.LineWidth=1;
if ~isempty(hplot11)
    for Numofoverlay = 1:numel(hplot11)
        qLegendName{Numofoverlay} = strrep(ALLMVPC(MVPCArray(Numofoverlay)).mvpcname,'_','\_');
        if qTextcolorLeg==1
            legdcolor = [0 0 0];
        else
            legdcolor = qLineColorspec(Numofoverlay,:);
        end
        LegendName{Numofoverlay} = char(strcat('\color[rgb]{',num2str(legdcolor),'}',32,qLegendName{Numofoverlay}));
    end
    p  = get(legendview,'position');
    h_legend = legend(legendview,hplot11,LegendName);
    legend(legendview,'boxoff');
    set(legendview,'XTick', [], 'YTick', [],'Box','off', 'Color','none','xcolor','none','ycolor','none');
    set(h_legend,'NumColumns',qLegcolumns,'FontName', qFontLeg, 'Color', [1 1 1], 'position', p,'FontSize',qFontSizeLeg );
end


set(gcf,'color',[1 1 1]);
% prePaperType = get(fig_gui,'PaperType');
% prePaperUnits = get(fig_gui,'PaperUnits');
% preUnits = get(fig_gui,'Units');
% prePaperPosition = get(fig_gui,'PaperPosition');
% prePaperSize = get(fig_gui,'PaperSize');
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
if ~isempty(qFigureName)
    figformats = {'.pdf','.svg','.jpg','.png','.tif','.bmp','.eps'};
    [C_style,IA_style] = ismember_bc2(extfig,figformats);
    figFileName = fullfile(pathstrfig,qFigureName);
    if isempty(IA_style) || IA_style==0
        suffix = '.pdf';
    else
        suffix = figformats{IA_style};
    end
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
    fprintf(['\n User selected the path to save waves for decoding accuracy:',figFileName,suffix,'\n']);
end

end