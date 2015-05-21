function [] = neoaxescenter(ax)
%AXESCENTER locates axes in the center instead of at the edges.
% AXESCENTER(AX) puts axes in the center of axes AX.  If AX is not
% supplied, the current axes is assumed.  Many of the standard properties
% manipulated through the command line will also work when the axes are in
% the center, such as grid, title, and x/ylabel.  This function works by
% placing two 'fake' axes in the center of the current axes and hiding the
% ticks and other signs of AX, while property listeners are attached to the
% relevant properties of AX.  An exception to this is the deletefcn
% property. Apparently no listener can be attached to this property so that
% calling 'delete(AX)' will leave the center axes intact.  In this case,
% the user can find the handles using:
% H = findall(gcf,'type','axes','handlev','off')
% then the center axes can be deleted manually.
% Another exception is the dataaspectratio property.  If the user sets the
% dataaspectratio property, the center axes will not line up correctly.
% Thus any function that changes this property, such as 'axis equal' will
% not yield the correct alignment for the center axes.  For now it is
% recommended to set the axes position property to get a similar effect.
%
% Notes:
% The goal of this work is that the user will not see any difference in
% functionality between having the axes at the center, and having them at
% the edges.  Obviously this goal has not been fully met: there are
% exceptions.  It is hoped that improvements will be continuously added
% through feedback from users and the authors own effort.  If you see a
% way around one of the exceptions, please contact the author!  I am
% particularly interested in finding ways to match the dataaspect/plotbox
% ratios so that functions like axis square can be used.  I have been using
% Matlab for years now, and I have NO CLUE how to do this after much
% wasted effort, though I am certain that it can be done.
% Using the zoom and pan tools from the figure menubar keeps the center
% axes correct.
% As of now, AXESCENTER does not work if either axis of AX is log scaled,
% or if the plot is 3D.
% The workings of the code are simple enough that modification/extension
% should be easy.
% Several solutions were sought to allow the user to use delete(AX) and
% have the center axes be deleted as well.  No method was found that
% worked for both this case and the case where the user closes the figure
% by clicking the x.  If you find a solution to this dilemma, please
% contact the author.
% I would like to acknowledge the work of Yair Altman. A piece of his
% proplistener code, available on the FEX, was incorporated into this
% work.  As with his work, this function relies on undocumented Matlab
% functions and properties, so it cannot be guaranteed to work on all
% versions of Matlab.
%
% Perhaps the best way to see this function in action is to copy the demo
% below into a script and run it.  The demo manipulates many of the axes
% properties using gca, as one would normally do.  The demo lasts about 24
% seconds.  When the demo is over, feel free to zoom in and out, and pan
% the plot using the figure's menubar.
%
% Demo: (Copy and paste into a script, or to the command line.)
%
%   f = figure('position',[100 100 700 680]);
%   str = 'Click to continue.';
%   x = -2*pi:.01:2*pi;
%   plot(x,sin(x),'r'),hold on
%   pos = get(gca,'position');
%   T = title('Call neoaxescenter','fonts',14,'fontw','b');
%   neoaxescenter,uiwait(msgbox(str,'DEMO','modal'));  % Call our function
%   set(T,'string','Change ylim')
%   set(gca,'ylim',[-10 10]),uiwait(msgbox(str,'DEMO','modal'));
%   set(T,'string','Add plot, reset ylim, change fontweight, and xlabels')
%   plot(x,cos(x))
%   set(gca,'ylim',[-2 2],'fontw','b')
%   set(gca,'xticklabel',['2' ;'3' ;'4' ;'5' ;'6'])
%   uiwait(msgbox(str,'DEMO','modal'));
%   set(T,'string','Change xtick')
%   set(gca,'xtick',[-4 0 4]),uiwait(msgbox(str,'DEMO','modal'));
%   set(T,'string','Change xtickmode and xticklabelmode to auto')
%   set(gca,'xtickmode','auto','xticklabelmode','auto'),
%   uiwait(msgbox(str,'DEMO','modal'));
%   set(T,'string','Turn on minor grids')
%   set(gca,'fontw','n')
%   set(gca,'xminorgrid','on','yminorgrid','on')
%   uiwait(msgbox(str,'DEMO','modal'));
%   set(T,'string','Change axes position')
%   set(gca,'pos',[.1 .05 .5 .8]),uiwait(msgbox(str,'DEMO','modal'));
%   set(T,'string','Move axes back, add x and y labels, change ticklength')
%   set(gca,'pos',pos)
%   xlabel('X','fonts',12,'fontw','b'),ylabel('Y','fonts',12,'fontw','b')
%   set(gca,'tickl',[.06 .025]),uiwait(msgbox(str,'DEMO','modal'));
%   set(T,'string','Change fontangle, fontsize axes linewidth')
%   set(gca,'fonta','i','linewidth',2)
%   set(gca,'fonts',6),uiwait(msgbox(str,'DEMO','modal'));
%   set(T,'string','Change fontsize back, change axes color')
%   set(gca,'fonta','n','fonts',10)
%   set(gca,{'xcolor','ycolor'},{[.1 .8 .1],[.2 .2 .6]},'tickl',[.02 .025])
%   pause(2)
%   set(T,'string','Demo over, try zoom and pan.  Thank you.')
%
%
% Author:  Matt Fig
% Contact: popkenai@yahoo.com
% Created: 1/9/2009
%
% Modified by Javier Lopez-Calderon to allow assymetric axis, moving and inversion of axis, 
% 09/22/2012

if nargin<1
      ax = gca;
elseif ~ishandle(ax) || isempty(strmatch('axes',get(ax,'type')))
      error('Input argument must be the handle to an axes.  See help.')
end
if any(strmatch('log',get(gca,{'xsca','ysca'}))) || all(get(ax,'view'))
      error('AXESCENTER does not work for log scaled  or 3D axes.  See help')
end

D = get(ax,{'Position','XLim','YLim','Units','Parent','XDir','YDir', 'XTick', 'YTick'}); %Set these props first.

fc = get(gcf,'Color'); % We are going to hide ax in the figure.
set(ax,'tickd','out',{'XColor';'YColor'},{fc,fc});
H = get(ax,{'XLabel','YLabel','Title'}); % Don't want to hide these guys.
set([H{:}],{'Color'},{'k'})

%
% Next create our fake axes that will act as the center axes.
%

%
% Y axis
%
nn = 1000;
ss = linspace(D{2}(1), D{2}(2), nn);
[aa bb] = min(abs(ss)); % finds x=0
px0 = (bb-1)/nn; % proportion of axis X when Y intersects X

S.a1 = axes('Units',D{4},'Position',[D{1}(1)+D{1}(3)*px0 D{1}(2) .01 D{1}(4)],...
      'YLim',D{3}, 'Xtick',[], 'HandleVisibility','off','Tag','YAXIS','Color','none',...
      'HitTest','off','Parent',D{5},'YDir', D{7}, 'YTick', D{9});  % Give this fake axis the props.

%
% X axis
%
ss = linspace(D{3}(1), D{3}(2), nn);
[aa bb] = min(abs(ss)); % finds y=0

if strcmpi(D{7}, 'reverse')
      py0 = 1-bb/nn; % proportion of axis Y when X intersects Y
else
      py0 = bb/nn; % proportion of axis Y when X intersects Y
end

S.a2 = axes('Units',D{4},'Position',[D{1}(1) D{1}(2)+D{1}(4)*py0 D{1}(3) .01],...
      'XLim',D{2}, 'Ytick',[], 'HandleVisibility','off','Tag','XAXIS','Color','none',...
      'HitTest','off','Parent',D{5},'XDir', D{6}, 'XTick', D{8});  % Give this fake axis the props.

setappdata(ax,'CENTERAXES',S); % Store the handles in appdata of AX.


% Use this function to set listeners for when certain of the axes
% properties change.  The properties of concern are self-explanatory.
% Follow this format to add properties.  The functions are defined below.
plistener(ax,'XLim',@xylim)
plistener(ax,'YLim',@xylim)
plistener(ax,'YDir',@xylim)
plistener(ax,'XTick',@xytick)
plistener(ax,'YTick',@xytick)
%plistener(ax,'XTickLabel',@xytickl)
%plistener(ax,'YTickLabel',@xytickl)
plistener(ax,'FontAngle',@fonta)
plistener(ax,'FontName',@fonta)
plistener(ax,'FontSize',@fonta)
plistener(ax,'FontWeight',@fonta)
plistener(ax,'Xcolor',@xcol)
plistener(ax,'YColor',@ycol)
plistener(ax,'Position',@pos)
plistener(ax,'XTickLabelMode',@xytlmd)
plistener(ax,'YTickLabelMode',@xytlmd)
plistener(ax,'YTickMode',@xytmd)
plistener(ax,'XTickMode',@xytmd)
plistener(ax,'LineWidth',@xylnw)

%-----------------------------------------------------------------
function [] = plistener(ax,prp,func)
% Sets the properties listeners.  From proplistener by Yair Altman.
psetact = 'PropertyPostSet';
hC = handle(ax);
hSrc = hC.findprop(prp);
hl = handle.listener(hC, hSrc, psetact, {func,ax});
p = findprop(hC, 'Listeners__');
if isempty(p)
      p = schema.prop(hC, 'Listeners__', 'handle vector');
      set(p,'AccessFlags.Serialize', 'off', ...
            'AccessFlags.Copy', 'off',...
            'FactoryValue', [], 'Visible', 'off');
end
hC.Listeners__ = hC.Listeners__(ishandle(hC.Listeners__));
hC.Listeners__ = [hC.Listeners__; hl];

%-----------------------------------------------------------------
function [] = xylim(varargin)
% Adjusts the x and y limits.
ax = varargin{3};
S = getappdata(ax);
S = S.CENTERAXES;
xlim = get(ax,'XLim');
ylim = get(ax,'YLim');
xdir = get(ax,'XDir');
ydir = get(ax,'YDir');
set(S.a1,'YLim', ylim);
set(S.a2,'XLim', xlim);
% Adjusts x and y directions
set(S.a1,'YDir', ydir);
set(S.a2,'XDir', xdir);
% Adjusts pos
adjpos(ax)
%disp('xylim was called')

%-----------------------------------------------------------------
function [] = xytick(varargin)
% Adjusts the x and y ticks.
ax = varargin{3};
S = getappdata(ax);
S = S.CENTERAXES;
xtick = get(ax,'XTick');
ytick = get(ax,'YTick');
% Adjusts x and y ticks
set(S.a1,'YTick', ytick);
set(S.a2,'XTick', xtick);
% Adjusts pos
adjpos(ax)
%disp('xytick was called')

%-----------------------------------------------------------------
function [] = xytickl(varargin)
% Adjusts the x and y tick labels.
ax = varargin{3};
S = getappdata(ax);
S = S.CENTERAXES;
xticklabel = get(ax,{'XTickLabel','tickl'});
yticklabel = get(ax,{'YTickLabel','tickl'});
set(S.a1,{'YTickLabel','tickl'}, yticklabel);
set(S.a2,{'XTickLabel','tickl'}, xticklabel);
% Adjusts pos
adjpos(ax)
%disp('xytickl was called')

%-----------------------------------------------------------------
function [] = xcol(varargin)
% Adjusts the x color.
ax = varargin{3};
S = getappdata(ax);
S = S.CENTERAXES;
set(S.a2,'XColor',get(ax,'YColor'));
fc = get(gcf,'Color');
set(ax,{'XColor';'YColor'},{fc,fc})
%disp('xcol was called')

%-----------------------------------------------------------------
function [] = ycol(varargin)
% Adjusts the y color.
ax = varargin{3};
S = getappdata(ax);
S = S.CENTERAXES;
set(S.a1,'YColor',get(ax,'YColor'));
fc = get(gcf,'Color');
set(ax,{'XColor';'YColor'},{fc,fc})
%disp('ycol was called')

%-----------------------------------------------------------------
function [] = fonta(varargin)
% Adjusts the fontangle, fontsize, fontweight, fontname.
ax = varargin{3};
S = getappdata(ax);
S = S.CENTERAXES;
set(S.a1,{'fonta','fontn','fonts','fontw'},...
      get(ax,{'fonta','fontn','fonts','fontw'}));
set(S.a2,{'fonta','fontn','fonts','fontw'},...
      get(ax,{'fonta','fontn','fonts','fontw'}));
%disp('fonta was called')

%-----------------------------------------------------------------
function [] = pos(varargin)
% Adjusts the position.
ax = varargin{3};
p = get(ax,'Position');
S = getappdata(ax);
S = S.CENTERAXES;
set(S.a1,'Position',[p(1)+p(3)/2 p(2) eps p(4)]);
set(S.a2,'Position',[p(1) p(2)+p(4)/2  p(3) eps]);
%disp('pos was called')

%-----------------------------------------------------------------
function [] = xytlmd(varargin)
% Adjusts the x and y tick labels.
ax = varargin{3};
S = getappdata(ax);
S = S.CENTERAXES;
set(S.a1,{'yticklabelm','tickl'},get(ax,{'yticklabelm','tickl'}));
set(S.a2,{'xticklabelm','tickl'},get(ax,{'xticklabelm','tickl'}));
%disp('xytlmd was called')

%-----------------------------------------------------------------
function [] = xytmd(varargin)
% Adjusts the x and y tick labels.
ax = varargin{3};
S = getappdata(ax);
S = S.CENTERAXES;
set(S.a1,{'ytickm','tickl'},get(ax,{'ytickm','tickl'}));
set(S.a2,{'xtickm','tickl'},get(ax,{'xtickm','tickl'}));
% disp('xyrmd was called')

%-----------------------------------------------------------------
function [] = xylnw(varargin)
% Adjusts the x and y tick labels.
ax = varargin{3};
S = getappdata(ax);
S = S.CENTERAXES;
lnw = get(ax,'LineWidth');
set(S.a1,'LineWidth',lnw);
set(S.a2,'LineWidth',lnw);
% disp('xylnw was called')

%-----------------------------------------------------------------
function [] = adjpos(ax)
S = getappdata(ax);
S = S.CENTERAXES;
xlim = get(ax,'XLim');
ylim = get(ax,'YLim');
% xdir = get(ax,'XDir');
ydir = get(ax,'YDir');
% Adjusts the position.
p = get(ax,'Position');
nn = 1000;
ss = linspace(xlim(1), xlim(2), nn);
[aa bb] = min(abs(ss));
px0 = bb/nn; % proportion of axis X when Y intersects X
set(S.a1,'Position',[p(1)+p(3)*px0 p(2) eps p(4)]);  % set Y axis new pos
ss = linspace(ylim(1), ylim(2), nn);
[aa bb] = min(abs(ss));
if strcmpi(ydir, 'reverse')
      py0 = 1-bb/nn; % proportion of axis Y when X intersects Y
else
      py0 = bb/nn; % proportion of axis Y when X intersects Y
end
set(S.a2,'Position',[p(1) p(2)+p(4)*py0  p(3) eps]); % set X axis new pos

