% This function is a combination of the zeroaxes.m from Andrew Knight and axescenter.m from Matt Fig.
% I just took the best of them to allow the axes look nice (crossing at the origin) and being able to be interactive.
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2012
%
% Apr-2015: updated/fixed to deal with Matlab's HG2 update (Matlab 2014b and later). JLC

function neozeroaxes(type, fontsizeticks, mcolor)
if nargin<3
        mcolor = []; %[.7 .9 .7];
end
if nargin<2
        fontsizeticks = 8;
end
if isempty(fontsizeticks)
        fontsizeticks = 8;
end
if isempty(mcolor)
        mcolor = get(gcf,'Color');
end
linew     = 1; % axes line width
holdwason = ishold;
axesin    = get(gcf,'CurrentAxes');   % get current axes (old axes)
bdownf    = get(gcf,'ButtonDownFcn'); % JLC, May 12th 2008
posi      = get(axesin,'position');   % get axes position

% create new axes (ax)
ax         = axis;
xscale     = get(axesin,'XScale');     % get XScale from the old X axis
yscale     = get(axesin,'YScale');     % get YScale from the old Y axis
ticklength = get(axesin,'TickLength'); % get TickLength from the old axis
sentido    = get(axesin,'YDir');       % get Ydir from the old Y axis

if type==0 % matlab
        set(axesin,'Visible','on'); % make old axes visible
        Xaxcolor   = [.7 .9 .7]; % Original   
        Yaxcolor   = [.7 .9 .7]; % Original
        xxticks    = [];
        yyticks    = [];
        xmt        = 'off';
        ymt        = 'off';
        set(axesin,'FontSize', fontsizeticks);
else % zero crossing axes
        set(axesin,'Visible','off');% make old axes invisible
        Xaxcolor = 1 - mcolor;
        Yaxcolor = 1 - mcolor;
        xxticks    = get(axesin,'XTick');      % get XTick from the old X axis
        yyticks    = get(axesin,'YTick');      % get YTick from the old Y axis
        xmt        = get(axesin,'XMinorTick'); % get XMinorTick from the old X axis
        ymt        = get(axesin,'YMinorTick'); % get YMinorTick from the old Y axis
end

% get values from the recently created axes
xmin = ax(1);
xmax = ax(2);
ymin = ax(3);
ymax = ax(4);

% prepare values for new axes
XAxisHeight  = ticklength(1);
YAxisWidth   = ticklength(1);
f   = polyfit([ax(1) ax(2)],[posi(1) posi(1)+posi(3)],1);
XAxisXLimits = polyval(f,[xmin xmax]);
YAxisXLimits = polyval(f,[0 YAxisWidth*abs(xmax - xmin)]);
f   = polyfit([ax(3) ax(4)],[posi(2) posi(2)+posi(4)],1);
YAxisYLimits = polyval(f,[ymin ymax]);
XAxisYLimits = polyval(f,[0 XAxisHeight*abs(ymax - ymin)]);
bgcolour     = get(gcf,'color'); % gets background color

% right (new) XY axes intersection in case Y is inversed.
if strcmp(sentido, 'reverse')
        Xaxis_y = 2*posi(2)+posi(4)-XAxisYLimits(1);
else
        Xaxis_y = XAxisYLimits(1);
end
XAxisPosition = [XAxisXLimits(1) Xaxis_y XAxisXLimits(2) - XAxisXLimits(1) XAxisYLimits(2) - XAxisYLimits(1)];

% create new X axis
AX.hX = axes('position',XAxisPosition,...
        'XLim',[xmin xmax],...
        'box','off',...
        'YTick',[],...
        'TickDir','out',...
        'XScale',xscale,...
        'YColor',bgcolour,...
        'XColor', Xaxcolor,...
        'LineWidth', linew,...
        'FontSize', fontsizeticks,...
        'color','none');

% new Y axis position
YAxisPosition = [YAxisXLimits(1) YAxisYLimits(1) YAxisXLimits(2) - YAxisXLimits(1) YAxisYLimits(2) - YAxisYLimits(1)];

% create new Y axis
AX.hY = axes('position',YAxisPosition,...
        'YLim',[ymin ymax],...
        'box','off',...
        'Xtick',[],...
        'TickDir','out',...
        'YScale',yscale,...
        'YColor', Yaxcolor,...
        'XColor',bgcolour,...
        'LineWidth', linew,...
        'FontSize', fontsizeticks,...
        'color','none',...
        'YDir', sentido); % JLC, May 12th 2008
%
% Set new axes
%
set(AX.hX,'XTick',xxticks)
set(AX.hY,'YTick',yyticks)
set(AX.hX,'XMinorTick',xmt)
set(AX.hY,'YMinorTick',ymt)

if type==1
        % Get rid of the zero ticks (if necessary)
        if ymin<0 && ~strcmp(xscale,'log')
                xticks = get(AX.hX,'XTick');
                xticks(xticks==0) = [];
                set(AX.hX,'XTick',xticks)
        end
        if xmin<0 && ~strcmp(yscale,'log')
                yticks = get(AX.hY,'YTick');
                yticks(yticks==0) = [];
                set(AX.hY,'YTick',yticks)
        end
end

set(gcf,'CurrentAxes',axesin)
set(gcf,'ButtonDownFcn',bdownf)

if ~holdwason
        set(AX.hX,'NextPlot','Replace')
        set(AX.hY,'NextPlot','Replace')
end

% Store the handles in appdata of AX.
setappdata(axesin,'CENTERAXES', AX);

% when any property of the old axes changes these functions will keep the new ones updated
% JLC, April 2015
addlistener(axesin,'XLim', 'PostSet', @(varargin) xylim(varargin{:}, axesin));
addlistener(axesin,'YLim', 'PostSet', @(varargin) xylim(varargin{:}, axesin));
addlistener(axesin,'Position', 'PostSet', @(varargin) xylim(varargin{:}, axesin));

%-----------------------------------------------------------------
function [] = xylim(varargin)
% Adjusts the x and y limits.
axesin = varargin{3};
AX = getappdata(axesin);
AX = AX.CENTERAXES;
xlim = get(axesin,'XLim');
ylim = get(axesin,'YLim');
xdir = get(axesin,'XDir');
ydir = get(axesin,'YDir');
set(AX.hY,'YLim', ylim);
set(AX.hX,'XLim', xlim);
% Adjusts x and y directions
set(AX.hY,'YDir', ydir);
set(AX.hX,'XDir', xdir);
% Adjusts pos
adjpos(axesin)

%-----------------------------------------------------------------
function [] = adjpos(axesin)
AX = getappdata(axesin);
AX = AX.CENTERAXES;
xlim = get(axesin,'XLim');
ylim = get(axesin,'YLim');
% xdir = get(ax,'XDir');
ydir = get(axesin,'YDir');
% Adjusts the position.
p = get(axesin,'Position');
nn = 1000;
ss = linspace(xlim(1), xlim(2), nn);
[aa, bb] = min(abs(ss));
px0 = bb/nn; % proportion of axis X when Y intersects X
set(AX.hY,'Position',[p(1)+p(3)*px0 p(2) eps p(4)]);  % set Y axis new pos
ss = linspace(ylim(1), ylim(2), nn);
[aa, bb] = min(abs(ss));
if strcmpi(ydir, 'reverse')
        py0 = 1-bb/nn; % proportion of axis Y when X intersects Y
else
        py0 = bb/nn; % proportion of axis Y when X intersects Y
end
set(AX.hX,'Position',[p(1) p(2)+p(4)*py0  p(3) eps]); % set X axis new pos