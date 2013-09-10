% ZEROAXES Redraws the axes at the zero values.
% See also: CENTAXES
% Author: Andrew Knight

% Modified February 1994 to omit the zero label if necessary.
% Modified May 12th 2008 to allow  Y axis invertion, by Javier Lopez-Calderon (JLC)
%
% 03-31-2009 : Bug1: incorrect position of x-axis when y-axis is inverted (abs(ymin) ~= abs(ymax)).
% Thanks to Marcus Heldmann.
%
% 04-01-2009 : Bug1 fixed. JLC

function zeroaxes

holdwason = ishold;
axesin    = get(gcf,'CurrentAxes');
bdownf    = get(gcf,'ButtonDownFcn'); % JLC, May 12th 2008
pos       = get(axesin,'position');
ax        = axis;
xscale    = get(axesin,'XScale');
yscale    = get(axesin,'YScale');
xxticks   = get(axesin,'XTick');       %JLC, March 10, 2011
yyticks   = get(axesin,'YTick');       %JLC, March 10, 2011
xmt       = get(axesin,'XMinorTick');  %JLC, March 10, 2011
ymt       = get(axesin,'YMinorTick');  %JLC, March 10, 2011

sentido   = get(axesin,'YDir');       % JLC, May 12th 2008
set(axesin,'visible','off');
xmin = ax(1);
xmax = ax(2);
ymin = ax(3);
ymax = ax(4);
ticklength  = get(axesin,'TickLength');
XAxisHeight = ticklength(1);
YAxisWidth  = ticklength(1);
f   = polyfit([ax(1) ax(2)],[pos(1) pos(1)+pos(3)],1);
XAxisXLimits = polyval(f,[xmin xmax]);
YAxisXLimits = polyval(f,[0 YAxisWidth*abs(xmax - xmin)]);
f   = polyfit([ax(3) ax(4)],[pos(2) pos(2)+pos(4)],1);
YAxisYLimits = polyval(f,[ymin ymax]);
XAxisYLimits = polyval(f,[0 XAxisHeight*abs(ymax - ymin)]);

%
% right position of the x-axis in case of inverted y-axis
% 04-01-2009  JLC
if strcmp(sentido, 'reverse')
      Xaxis_y = 2*pos(2)+pos(4)-XAxisYLimits(1);
else
      Xaxis_y = XAxisYLimits(1);
end

XAxisPosition = [XAxisXLimits(1)
      Xaxis_y
      XAxisXLimits(2) - XAxisXLimits(1)
      XAxisYLimits(2) - XAxisYLimits(1)];

bgcolour = get(gcf,'color');

hX = axes('position',XAxisPosition,...
      'XLim',[xmin xmax],...
      'box','off',...
      'YTick',[],...
      'TickDir','out',...
      'XScale',xscale,...
      'YColor',bgcolour,...
      'color','none');

YAxisPosition = [YAxisXLimits(1)
      YAxisYLimits(1)
      YAxisXLimits(2) - YAxisXLimits(1)
      YAxisYLimits(2) - YAxisYLimits(1)];

hY = axes('position',YAxisPosition,...
      'YLim',[ymin ymax],...
      'box','off',...
      'Xtick',[],...
      'TickDir','out',...
      'YScale',yscale,...
      'XColor',bgcolour,...
      'color','none',...
      'YDir', sentido); % JLC, May 12th 2008

%
% Ticks  JLC, March 10, 2011
%
set(hX,'XTick',xxticks)
set(hY,'YTick',yyticks)
set(hX,'XMinorTick',xmt)
set(hY,'YMinorTick',ymt)


% Get rid of the zero ticks if necessary:
if ymin<0 && ~strcmp(xscale,'log')
      xticks = get(hX,'XTick');
      xticks(xticks==0) = [];
      set(hX,'XTick',xticks)
end

if xmin<0 && ~strcmp(yscale,'log')
      yticks = get(hY,'YTick');
      yticks(yticks==0) = [];
      set(hY,'YTick',yticks)
end

set(gcf,'CurrentAxes',axesin)
set(gcf,'ButtonDownFcn',bdownf)

if ~holdwason
      set(hX,'NextPlot','Replace')
      set(hY,'NextPlot','Replace')
end
