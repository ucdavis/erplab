function [] = axescenter(ax)
% AXESCENTER locates axes in the center instead of at the edges.
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
%   T = title('Call axescenter','fonts',14,'fontw','b');
%   axescenter,uiwait(msgbox(str,'DEMO','modal'));  % Call our function
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

if nargin<1
      ax = gca;
elseif ~ishandle(ax) || isempty(strmatch('axes',get(ax,'type')))
      error('Input argument must be the handle to an axes.  See help.')
end

if any(strmatch('log',get(gca,{'xsca','ysca'}))) || all(get(ax,'view'))
      error('AXESCENTER does not work for log scaled  or 3D axes.  See help')
end

D = get(ax,{'pos','xlim','ylim','units','parent','YDir'}); %Set these props first.

fc = get(gcf,'color'); % We are going to hide ax in the figure.
set(ax,'tickd','out',{'xcolor';'ycolor'},{fc,fc});
H = get(ax,{'xlabel','ylabel','title'}); % Don't want to hide these guys.
set([H{:}],{'color'},{'k'})

%
% Next create our fake axes that will act as the center axes.
%

% # start
% added by Javier Lopez-Calderon to draw non symetric axies
%

%
% X axis
%
nn = 1000;
ss = linspace(D{2}(1), D{2}(2), nn);
[aa bb] = min(abs(ss));
px0 = bb/nn;

S.a1 = axes('units',D{4},'posi',[D{1}(1)+D{1}(3)*px0 D{1}(2) .01 D{1}(4)],...
      'ylim',D{3},'xtick',[],'handlev','of','tag','XAXIS','color','none',...
      'hittest','off','parent',D{5},'YDir', D{6});  % Give this fake axis the props.

%
% Y axis
%
ss = linspace(D{3}(1), D{3}(2), nn);
[aa bb] = min(abs(ss));
py0 = bb/nn;

S.a2 = axes('units',D{4},'posi',[D{1}(1) D{1}(2)+D{1}(4)*py0 D{1}(3) .01],...
      'xlim',D{2},'ytick',[],'handlev','of','tag','YAXIS','color','none',...
      'hittest','off','parent',D{5});  % Give this fake axis the props.

%
% added by Javier Lopez-Calderon to draw non symetric axies
% # end

setappdata(ax,'CENTERAXES',S); % Store the handles in appdata of AX.
% ax = varargin{3};
% S = getappdata(ax);
% S = S.CENTERAXES;
% set(S.a1,'ylim',get(ax,'ylim'));
% set(S.a1,'YDir',get(ax,'YDir'));

% Use this function to set listeners for when certain of the axes
% properties change.  The properties of concern are self-explanatory.
% Follow this format to add properties.  The functions are defined below.
plistener(ax,'XLim',@xylim)
plistener(ax,'YLim',@xylim)
plistener(ax,'YDir',@xylim)
plistener(ax,'XTick',@xytick)
plistener(ax,'YTick',@xytick)
plistener(ax,'XTickLabel',@xytickl)
plistener(ax,'YTickLabel',@xytickl)
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


function [] = xylim(varargin)
% Adjusts the x and y limits.
ax = varargin{3};
S = getappdata(ax);
S = S.CENTERAXES;
set(S.a1,'ylim',get(ax,'ylim'));
set(S.a1,'YDir',get(ax,'YDir'));

set(S.a2,'xlim',get(ax,'xlim'));

function [] = xytick(varargin)
% Adjusts the x and y ticks.
ax = varargin{3};
S = getappdata(ax);
S = S.CENTERAXES;
set(S.a1,'ytick',get(ax,'ytick'));
set(S.a2,'xtick',get(ax,'xtick'));


function [] = xytickl(varargin)
% Adjusts the x and y tick labels.
ax = varargin{3};
S = getappdata(ax);
S = S.CENTERAXES;
set(S.a1,{'yticklabel','tickl'},get(ax,{'yticklabel','tickl'}));
set(S.a2,{'xticklabel','tickl'},get(ax,{'xticklabel','tickl'}));


function [] = xcol(varargin)
% Adjusts the x color.
ax = varargin{3};
S = getappdata(ax);
S = S.CENTERAXES;
set(S.a2,'xcolor',get(ax,'xcolor'));
fc = get(gcf,'color');
set(ax,{'xcolor';'ycolor'},{fc,fc})


function [] = ycol(varargin)
% Adjusts the y color.
ax = varargin{3};
S = getappdata(ax);
S = S.CENTERAXES;
set(S.a1,'ycolor',get(ax,'ycolor'));
fc = get(gcf,'color');
set(ax,{'xcolor';'ycolor'},{fc,fc})


function [] = fonta(varargin)
% Adjusts the fontangle, fontsize, fontweight, fontname.
ax = varargin{3};
S = getappdata(ax);
S = S.CENTERAXES;
set(S.a1,{'fonta','fontn','fonts','fontw'},...
      get(ax,{'fonta','fontn','fonts','fontw'}));
set(S.a2,{'fonta','fontn','fonts','fontw'},...
      get(ax,{'fonta','fontn','fonts','fontw'}));


function [] = pos(varargin)
% Adjusts the position.
ax = varargin{3};
p = get(ax,'position');
S = getappdata(ax);
S = S.CENTERAXES;
set(S.a1,'pos',[p(1)+p(3)/2 p(2) eps p(4)]);
set(S.a2,'pos',[p(1) p(2)+p(4)/2  p(3) eps]);


function [] = xytlmd(varargin)
% Adjusts the x and y tick labels.
ax = varargin{3};
S = getappdata(ax);
S = S.CENTERAXES;
set(S.a1,{'yticklabelm','tickl'},get(ax,{'yticklabelm','tickl'}));
set(S.a2,{'xticklabelm','tickl'},get(ax,{'xticklabelm','tickl'}));


function [] = xytmd(varargin)
% Adjusts the x and y tick labels.
ax = varargin{3};
S = getappdata(ax);
S = S.CENTERAXES;
set(S.a1,{'ytickm','tickl'},get(ax,{'ytickm','tickl'}));
set(S.a2,{'xtickm','tickl'},get(ax,{'xtickm','tickl'}));


function [] = xylnw(varargin)
% Adjusts the x and y tick labels.
ax = varargin{3};
S = getappdata(ax);
S = S.CENTERAXES;
lnw = get(ax,'linewidth');
set(S.a1,'linewidth',lnw);
set(S.a2,'linewidth',lnw);

