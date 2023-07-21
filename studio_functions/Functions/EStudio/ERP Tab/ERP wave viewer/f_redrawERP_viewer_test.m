%PURPOSE  : Plot EPR waves within one axes



% Author: Guanghui Zhang & Steve J. Luck
% Center for Mind and Brain
% University of California, Davis
% Davis, CA
% 2022 & 2023



function f_redrawERP_viewer_test()

global viewer_ERPDAT;
global gui_erp_waviewer;
addlistener(viewer_ERPDAT,'v_messg_change',@V_messg_change);
FonsizeDefault = f_get_default_fontsize();

if nargin>1
    help f_redrawERP_viewer;
    return;
end

try
    ALLERPwaviewer = evalin('base','ALLERPwaviewer');
    ERPwaviewer = ALLERPwaviewer;
catch
    beep;
    disp('Please re-run ERP wave viewer.');
    return;
end

%%save figure size:width and height
try
    ScreenPos =  get( groot, 'Screensize' );
catch
    ScreenPos =  get( 0, 'Screensize' );
end
FigOutposition = gui_erp_waviewer.ViewBox.OuterPosition(3:4);
FigOutposition(1) = 100*FigOutposition(1)/ScreenPos(3);
FigOutposition(2) = 100*FigOutposition(2)/ScreenPos(4);
ERPwaviewer.FigOutpos=FigOutposition;
assignin('base','ALLERPwaviewer',ERPwaviewer);
try
    gui_erp_waviewer.ScrollVerticalOffsets = gui_erp_waviewer.ViewAxes.VerticalOffsets/gui_erp_waviewer.ViewAxes.Heights;
    gui_erp_waviewer.ScrollHorizontalOffsets = gui_erp_waviewer.ViewAxes.HorizontalOffsets/gui_erp_waviewer.ViewAxes.Widths;
catch
    gui_erp_waviewer.ScrollVerticalOffsets=0;
    gui_erp_waviewer.ScrollHorizontalOffsets=0;
end

% We first clear the existing axes ready to build a new one
if ishandle( gui_erp_waviewer.ViewAxes )
    delete( gui_erp_waviewer.ViewAxes );
end

%Sets the units of your root object (screen) to pixels
set(0,'units','pixels')
%Obtains this pixel information
Pix_SS = get(0,'screensize');
%Sets the units of your root object (screen) to inches
set(0,'units','inches')
%Obtains this inch information
Inch_SS = get(0,'screensize');
%Calculates the resolution (pixels per inch)
Res = Pix_SS./Inch_SS;

%%background color of figure
figbgdColor = ERPwaviewer.figbackgdcolor;
if ~isnumeric(figbgdColor) || isempty(figbgdColor) || numel(figbgdColor)~=3 || max(figbgdColor)>1 ||  min(figbgdColor)<0
    figbgdColor =[1 1 1];
end
zoomSpace = estudioworkingmemory('zoomSpace');
if isempty(zoomSpace)
    zoomSpace = 0;
else
    if zoomSpace<0
        zoomSpace =0;
    end
end
if zoomSpace ==0
    gui_erp_waviewer.ScrollVerticalOffsets=0;
    gui_erp_waviewer.ScrollHorizontalOffsets=0;
end
pb_height = 1*Res(4);
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;%%Get background color
catch
    ColorBviewer_def = [0.7765,0.7294,0.8627];
end
if isempty(ColorBviewer_def) || numel(ColorBviewer_def)~=3
    ColorBviewer_def = [0.7765,0.7294,0.8627];
end


%%determine the page number
pagecurrentNum = ERPwaviewer.PageIndex;
pagesValue =  ERPwaviewer.plot_org.Pages;
ERPArray = ERPwaviewer.SelectERPIdx;
chanArray =ERPwaviewer.chan;
binArray = ERPwaviewer.bin;
ALLERPIN = ERPwaviewer.ALLERP;
[chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERPIN,ERPArray);
if pagesValue==1
    pageNum = numel(chanArray);
    PageStr = chanStr(chanArray);
elseif pagesValue==2
    pageNum = numel(binArray);
    PageStr = binStr(binArray);
else
    pageNum = numel(ERPArray);
    PageStr = cell(numel(ERPArray),1);
    for Numoferpset = 1:numel(ERPArray)
        PageStr(Numoferpset,1) = {char(ALLERPIN(ERPArray(Numoferpset)).erpname)};
    end
end

if pagecurrentNum>pageNum
    pagecurrentNum =1;
    ERPwaviewer.PageIndex =1;
    assignin('base','ALLERPwaviewer',ERPwaviewer);
end

gui_erp_waviewer.plotgrid = uix.VBox('Parent',gui_erp_waviewer.ViewContainer,'Padding',0,'Spacing',0,'BackgroundColor',ColorBviewer_def);

gui_erp_waviewer.pageinfo_box = uiextras.HBox( 'Parent', gui_erp_waviewer.plotgrid,'BackgroundColor',ColorBviewer_def);

gui_erp_waviewer.erpwaviewer_legend_title = uiextras.HBox( 'Parent', gui_erp_waviewer.plotgrid,'BackgroundColor',ColorBviewer_def);
uicontrol('Parent',gui_erp_waviewer.erpwaviewer_legend_title,'Style','text','String','','FontSize',FonsizeDefault,'FontWeight','bold','BackgroundColor',ColorBviewer_def);

gui_erp_waviewer.erpwaviewer_legend = uix.ScrollingPanel( 'Parent', gui_erp_waviewer.erpwaviewer_legend_title,'BackgroundColor',figbgdColor);


gui_erp_waviewer.plot_wav_legend = uiextras.HBox( 'Parent', gui_erp_waviewer.plotgrid,'BackgroundColor',ColorBviewer_def);
% gui_erp_waviewer.ViewAxes_legend = uix.ScrollingPanel( 'Parent', gui_erp_waviewer.plot_wav_legend,'BackgroundColor',ColorBviewer_def);

uicontrol('Parent',gui_erp_waviewer.plot_wav_legend,'Style','text','String','','FontSize',FonsizeDefault,'FontWeight','bold','BackgroundColor',ColorBviewer_def);
% gui_erp_waviewer.Resize = 0;


% gui_erp_waviewer.ViewAxes = uix.ScrollingPanel( 'Parent', gui_erp_waviewer.plot_wav_legend,'BackgroundColor',figbgdColor,'SizeChangedFcn',@WAviewerResize);%
gui_erp_waviewer.ViewAxes = uix.ScrollingPanel( 'Parent', gui_erp_waviewer.plot_wav_legend,'BackgroundColor',figbgdColor);


%%Changed by Guanghui Zhang Dec. 2022-------panel for display the processing procedure for some functions, e.g., filtering
gui_erp_waviewer.zoomin_out_title = uiextras.HBox( 'Parent', gui_erp_waviewer.plotgrid,'BackgroundColor',ColorBviewer_def);%%%Message
uicontrol('Parent',gui_erp_waviewer.zoomin_out_title,'Style','text','String','','FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def);
gui_erp_waviewer.zoom_in = uicontrol('Parent',gui_erp_waviewer.zoomin_out_title,'Style','pushbutton','String','Zoom In',...
    'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Callback',@zoomin);

gui_erp_waviewer.zoom_edit = uicontrol('Parent',gui_erp_waviewer.zoomin_out_title,'Style','edit','String',num2str(zoomSpace),...
    'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Callback',@zoomedit);

gui_erp_waviewer.zoom_out = uicontrol('Parent',gui_erp_waviewer.zoomin_out_title,'Style','pushbutton','String','Zoom Out',...
    'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Callback',@zoomout);
uicontrol('Parent',gui_erp_waviewer.zoomin_out_title,'Style','text','String','','FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def);

gui_erp_waviewer.figuresaveas = uicontrol('Parent',gui_erp_waviewer.zoomin_out_title,'Style','pushbutton','String','Show Command',...
    'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Callback',@Show_command);


gui_erp_waviewer.figuresaveas = uicontrol('Parent',gui_erp_waviewer.zoomin_out_title,'Style','pushbutton','String','Save Figure as',...
    'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Callback',@figure_saveas);

gui_erp_waviewer.figureout = uicontrol('Parent',gui_erp_waviewer.zoomin_out_title,'Style','pushbutton','String','Create Static /Exportable Plot',...
    'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Callback',@figure_out);

gui_erp_waviewer.Reset = uicontrol('Parent',gui_erp_waviewer.zoomin_out_title,'Style','pushbutton','String','Reset',...
    'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Callback',@Panel_Reset);


uicontrol('Parent',gui_erp_waviewer.zoomin_out_title,'Style','text','String','','FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def);
set(gui_erp_waviewer.zoomin_out_title, 'Sizes', [10 70 50 70 -1 100 100 170 70 5]);


%%Changed by Guanghui Zhang Dec. 2022-------panel for display the processing procedure for some functions, e.g., filtering
gui_erp_waviewer.xaxis_panel = uiextras.HBox( 'Parent', gui_erp_waviewer.plotgrid,'BackgroundColor',ColorBviewer_def);%%%Message
gui_erp_waviewer.Process_messg = uicontrol('Parent',gui_erp_waviewer.xaxis_panel,'Style','text','String','','FontSize',FonsizeDefault+2,'FontWeight','bold','BackgroundColor',ColorBviewer_def);

%%Setting title
gui_erp_waviewer.pageinfo_str = ['Page',32,num2str(pagecurrentNum),'/',num2str(pageNum),':',PageStr{pagecurrentNum}];

gui_erp_waviewer.pageinfo_text = uicontrol('Parent',gui_erp_waviewer.pageinfo_box,'Style','text','String',gui_erp_waviewer.pageinfo_str,'FontSize',FonsizeDefault,'FontWeight','bold','BackgroundColor',ColorBviewer_def);


gui_erp_waviewer.pageinfo_minus = uicontrol('Parent',gui_erp_waviewer.pageinfo_box,'Style', 'pushbutton', 'String', '<','Callback',@page_minus,'FontSize',FonsizeDefault+5,'BackgroundColor',[1 1 1],'FontWeight','bold');
% if S_ws_getbinchan.Select_index ==1
gui_erp_waviewer.pageinfo_minus.Enable = 'off';
% end
gui_erp_waviewer.pageinfo_edit = uicontrol('Parent',gui_erp_waviewer.pageinfo_box,'Style', 'edit', 'String', num2str(pagecurrentNum),'Callback',@page_edit,'FontSize',FonsizeDefault+2,'BackgroundColor',[1 1 1]);


gui_erp_waviewer.pageinfo_plus = uicontrol('Parent',gui_erp_waviewer.pageinfo_box,'Style', 'pushbutton', 'String', '>','Callback',@page_plus,'FontSize',FonsizeDefault+5,'BackgroundColor',[1 1 1],'FontWeight','bold');
% if S_ws_getbinchan.Select_index == numel(S_ws_geterpset)
gui_erp_waviewer.pageinfo_plus.Enable = 'off';
% end


if pageNum ==1
    Enable_minus = 'off';
    Enable_plus = 'off';
    Enable_plus_BackgroundColor = [1 1 1];
    Enable_minus_BackgroundColor = [0 0 0];
else
    if pagecurrentNum ==1
        Enable_minus = 'off';
        Enable_plus = 'on';
        Enable_plus_BackgroundColor = [0 1 0];
        Enable_minus_BackgroundColor = [0 0 0];
    elseif  pagecurrentNum == pageNum
        Enable_minus = 'on';
        Enable_plus = 'off';
        Enable_plus_BackgroundColor = [0 0 0];
        Enable_minus_BackgroundColor = [0 1 0];
    else
        Enable_minus = 'on';
        Enable_plus = 'on';
        Enable_plus_BackgroundColor = [0 1 0];
        Enable_minus_BackgroundColor = [0 1 0];
    end
end
gui_erp_waviewer.pageinfo_minus.Enable = Enable_minus;
gui_erp_waviewer.pageinfo_plus.Enable = Enable_plus;
gui_erp_waviewer.pageinfo_plus.ForegroundColor = Enable_plus_BackgroundColor;
gui_erp_waviewer.pageinfo_minus.ForegroundColor = Enable_minus_BackgroundColor;
set(gui_erp_waviewer.plot_wav_legend, 'Sizes', [10 -1]);
set(gui_erp_waviewer.erpwaviewer_legend_title, 'Sizes', [10 -1]);
set(gui_erp_waviewer.pageinfo_box, 'Sizes', [-1 50 50 50] );

gui_erp_waviewer.myerpviewer = axes('Parent', gui_erp_waviewer.ViewAxes,'Color','none','Box','on','FontWeight','bold');
hold(gui_erp_waviewer.myerpviewer,'on');
myerpviewer = gui_erp_waviewer.myerpviewer;

gui_erp_waviewer.myerpviewer_legend = axes('Parent', gui_erp_waviewer.erpwaviewer_legend ,'Color',figbgdColor,'Box','off');
hold(gui_erp_waviewer.myerpviewer_legend,'on');
myerpviewerlegend = gui_erp_waviewer.myerpviewer_legend;

OutputViewerpar = f_preparms_erpwaviewer('');

gui_erp_waviewer.plotgrid.Heights(1) = 30; % set the first element (pageinfo) to 30px high
gui_erp_waviewer.plotgrid.Heights(2) = 50; % set the first element (pageinfo) to 30px high
gui_erp_waviewer.plotgrid.Heights(4) = 30; % set the second element (x axis) to 30px high
gui_erp_waviewer.plotgrid.Heights(5) = 30; % set the second element (x axis) to 30px high
gui_erp_waviewer.plotgrid.Units = 'pixels';
if isempty(OutputViewerpar)
    disp('Please restart EStudio Wave Viewer');
    return;
end


%%Plot the waves
f_plotviewerwave(OutputViewerpar{1},OutputViewerpar{2}, OutputViewerpar{3},OutputViewerpar{4},OutputViewerpar{5},OutputViewerpar{6},OutputViewerpar{9},OutputViewerpar{8},OutputViewerpar{10},OutputViewerpar{11},...
    OutputViewerpar{12},OutputViewerpar{13},OutputViewerpar{14},OutputViewerpar{15},OutputViewerpar{16},OutputViewerpar{17},OutputViewerpar{18},OutputViewerpar{19},OutputViewerpar{20},OutputViewerpar{21},OutputViewerpar{22},...
    OutputViewerpar{23},OutputViewerpar{24},OutputViewerpar{25},OutputViewerpar{26},OutputViewerpar{27},OutputViewerpar{28},OutputViewerpar{29},OutputViewerpar{31},OutputViewerpar{30},OutputViewerpar{32},OutputViewerpar{33},...
    OutputViewerpar{34},OutputViewerpar{35},OutputViewerpar{36},OutputViewerpar{37},OutputViewerpar{38},OutputViewerpar{39},OutputViewerpar{7},OutputViewerpar{43}, OutputViewerpar{40},OutputViewerpar{41},OutputViewerpar{44},...
    OutputViewerpar{45},OutputViewerpar{46},OutputViewerpar{47},myerpviewer,myerpviewerlegend);

%%
set(gui_erp_waviewer.myerpviewer, 'XTick', [], 'XTickLabel', []);
set(gui_erp_waviewer.myerpviewer_legend, 'XTick', [], 'YTick', [],'Box','off', 'Color','none','xcolor','none','ycolor','none');
%%resize the heights based on the number of rows
Fill = 1;
splot_n = size(OutputViewerpar{6},1);
if splot_n*pb_height<(gui_erp_waviewer.plotgrid.Position(4)-gui_erp_waviewer.plotgrid.Heights(1))&&Fill
    pb_height = 0.9*(gui_erp_waviewer.plotgrid.Position(4)-gui_erp_waviewer.plotgrid.Heights(1)-gui_erp_waviewer.plotgrid.Heights(2))/splot_n;
else
    pb_height = 0.9*pb_height;
end
if zoomSpace <0
    gui_erp_waviewer.ViewAxes.Heights = splot_n*pb_height;
else
    gui_erp_waviewer.ViewAxes.Heights = splot_n*pb_height*(1+zoomSpace/100);
end

widthViewer = gui_erp_waviewer.ViewAxes.Position(3)-gui_erp_waviewer.ViewAxes.Position(2);
if zoomSpace <0
    gui_erp_waviewer.ViewAxes.Widths = widthViewer;
else
    gui_erp_waviewer.ViewAxes.Widths = widthViewer*(1+zoomSpace/100);
    
end
gui_erp_waviewer.plotgrid.Units = 'normalized';



%%Keep the same positions for Vertical and Horizontal scrolling bars asbefore
if zoomSpace~=0 && zoomSpace>0
    if gui_erp_waviewer.ScrollVerticalOffsets<=1
        try
            gui_erp_waviewer.ViewAxes.VerticalOffsets= gui_erp_waviewer.ScrollVerticalOffsets*gui_erp_waviewer.ViewAxes.Heights;
        catch
        end
    end
    if gui_erp_waviewer.ScrollHorizontalOffsets<=1
        try
            gui_erp_waviewer.ViewAxes.HorizontalOffsets =gui_erp_waviewer.ScrollHorizontalOffsets*gui_erp_waviewer.ViewAxes.Widths;
        catch
        end
    end
end
% gui_erp_waviewer.ViewAxes.BackgroundColor = 'b';
end % redrawDemo






%%Resize the GUI automatically as the user changes the size of the window at run-time.
% function WAviewerResize(~,~)
% global gui_erp_waviewer;
% if gui_erp_waviewer.Resize ~= 0
%     set( gui_erp_waviewer.tabERP, 'Widths', [-4, 270]);
%     f_redrawERP_viewer_test();
% end
% end


%%-------------------------------Page Editor-------------------------------
function page_edit(Source,~)
global viewer_ERPDAT
% addlistener(viewer_ERPDAT,'page_xyaxis',@count_page_xyaxis_change);

try
    ERPwaviewer = evalin('base','ALLERPwaviewer');
catch
    beep;
    disp('Error > f_redrawERP_viewer_test() > page_edit().');
    return;
end
pagesValue =  ERPwaviewer.plot_org.Pages;

[messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
if ~isempty(messgStr)
    viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
end

Pagecurrent = str2num(Source.String);

if ~isempty(Pagecurrent) && Pagecurrent>0
    
    ERPArray = ERPwaviewer.SelectERPIdx;
    chanArray =ERPwaviewer.chan;
    binArray = ERPwaviewer.bin;
    if pagesValue==1
        pageNum = numel(chanArray);
    elseif pagesValue==2
        pageNum = numel(binArray);
    else
        pageNum = numel(ERPArray);
    end
    
    if  Pagecurrent<=pageNum
        ERPwaviewer.PageIndex = Pagecurrent;
        if pagesValue==3
            ERPwaviewer.ERP   = ERPwaviewer.ALLERP(ERPArray(Pagecurrent));
            ERPwaviewer.CURRENTERP  =ERPArray(Pagecurrent);
        end
        assignin('base','ALLERPwaviewer',ERPwaviewer);
        viewer_ERPDAT.page_xyaxis = viewer_ERPDAT.page_xyaxis+1;
        f_redrawERP_viewer_test();%%replot the waves
    end
end

end

%------------------Display the waveform for proir ERPset--------------------
function page_minus(~,~)
global viewer_ERPDAT

[messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
if ~isempty(messgStr)
    viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
end

try
    ERPwaviewer_CHANGE = evalin('base','ALLERPwaviewer');
catch
    beep;
    disp('Please re-run ERP wave viewer.');
    return;
end
ERPwaviewer_CHANGE.PageIndex = ERPwaviewer_CHANGE.PageIndex-1;
pagesValue =  ERPwaviewer_CHANGE.plot_org.Pages;
ERPArray = ERPwaviewer_CHANGE.SelectERPIdx;
chanArray =ERPwaviewer_CHANGE.chan;
binArray = ERPwaviewer_CHANGE.bin;
if pagesValue==1
    pageNum = numel(chanArray);
elseif pagesValue==2
    pageNum = numel(binArray);
else
    pageNum = numel(ERPArray);
end
Pagecurrent = ERPwaviewer_CHANGE.PageIndex;
if  ERPwaviewer_CHANGE.PageIndex<= pageNum &&  ERPwaviewer_CHANGE.PageIndex>0
    if pagesValue==3
        ERPwaviewer_CHANGE.ERP   = ERPwaviewer_CHANGE.ALLERP(ERPArray(Pagecurrent));
        ERPwaviewer_CHANGE.CURRENTERP  =ERPArray(Pagecurrent);
    end
    
    assignin('base','ALLERPwaviewer',ERPwaviewer_CHANGE);
    MessageViewer= char(strcat('Plot prior page (<)'));
    erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
    viewer_ERPDAT.page_xyaxis = viewer_ERPDAT.page_xyaxis+1;%%change X/Y axis based on the changed pages
    viewer_ERPDAT.Process_messg =1;
    f_redrawERP_viewer_test();
    viewer_ERPDAT.Process_messg =2;
else
    return;
end
end


%------------------Display the waveform for next ERPset--------------------
function  page_plus(~,~)
global viewer_ERPDAT
[messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
if ~isempty(messgStr)
    viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
end

try
    ERPwaviewer_CHANGE = evalin('base','ALLERPwaviewer');
catch
    beep;
    disp('Please re-run ERP wave viewer.');
    return;
end
ERPwaviewer_CHANGE.PageIndex = ERPwaviewer_CHANGE.PageIndex+1;
pagesValue =  ERPwaviewer_CHANGE.plot_org.Pages;
ERPArray = ERPwaviewer_CHANGE.SelectERPIdx;
chanArray =ERPwaviewer_CHANGE.chan;
binArray = ERPwaviewer_CHANGE.bin;
if pagesValue==1
    pageNum = numel(chanArray);
elseif pagesValue==2
    pageNum = numel(binArray);
else
    pageNum = numel(ERPArray);
end
Pagecurrent = ERPwaviewer_CHANGE.PageIndex;
if  ERPwaviewer_CHANGE.PageIndex<= pageNum &&  ERPwaviewer_CHANGE.PageIndex>0%% within the page range
    if pagesValue==3
        ERPwaviewer_CHANGE.ERP   = ERPwaviewer_CHANGE.ALLERP(ERPArray(Pagecurrent));
        ERPwaviewer_CHANGE.CURRENTERP  =ERPArray(Pagecurrent);
    end
    assignin('base','ALLERPwaviewer',ERPwaviewer_CHANGE);
    viewer_ERPDAT.page_xyaxis = viewer_ERPDAT.page_xyaxis+1;%%change X/Y axis based on the changed pages
    MessageViewer= char(strcat('Plot next page (>)'));
    erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
    viewer_ERPDAT.Process_messg =1;
    f_redrawERP_viewer_test();
    viewer_ERPDAT.Process_messg =2;
else
    return;
end

end

function Show_command(~,~)
global viewer_ERPDAT;
[messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
if ~isempty(messgStr)
    viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
end

ViewerName = estudioworkingmemory('viewername');
if isempty(ViewerName)
    ViewerName = char('My Viewer');
end
MessageViewer= char(strcat('Show Command'));
erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
try
    viewer_ERPDAT.Process_messg =1;
    OutputViewerpar = f_preparms_erpwaviewer(ViewerName,'command');
    viewer_ERPDAT.Process_messg =2;
catch
    viewer_ERPDAT.Process_messg =3;
end
end



%%-------------------------Save figure as----------------------------------
function figure_saveas(~,~)
global viewer_ERPDAT;
% addlistener(viewer_ERPDAT,'V_messg_change',@V_messg_change);

[messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
if ~isempty(messgStr)
    viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
end


MessageViewer= char(strcat('Save Figure As'));
erpworkingmemory('ERPViewer_proces_messg',MessageViewer);

pathstr = pwd;
namedef ='Myviewer.pdf';
[erpfilename, erppathname, indxs] = uiputfile({'*.pdf';'*.svg';'*.jpg';'*.png';'*.tif';'*.bmp';'*.eps'},...
    'Save as',[fullfile(pathstr,namedef)]);


if isequal(erpfilename,0)
    beep;
    viewer_ERPDAT.Process_messg =3;
    disp('User selected Cancel')
    return
end

History = 'off';
[pathstr, erpfilename1, ext] = fileparts(erpfilename) ;

if isempty(ext)
    erpfilename = fullfile(erppathname,char(strcat(erpfilename,'.pdf')));
else
    erpfilename = fullfile(erppathname,erpfilename);
end

try
    viewer_ERPDAT.Process_messg =1;
    OutputViewerpar = f_preparms_erpwaviewer(erpfilename,History);
    viewer_ERPDAT.Process_messg =2;
catch
    viewer_ERPDAT.Process_messg =3;
end

end


%%-----------------Pop figure---------------------------------------------
function figure_out(~,~)
global viewer_ERPDAT;
[messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
if ~isempty(messgStr)
    viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
end

ViewerName = estudioworkingmemory('viewername');
if isempty(ViewerName)
    ViewerName = char('My Viewer');
end
MessageViewer= char(strcat('Create Static/Exportable Plot'));
erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
try
    viewer_ERPDAT.Process_messg =1;
    OutputViewerpar = f_preparms_erpwaviewer(ViewerName,'script');
    viewer_ERPDAT.Process_messg =2;
catch
    viewer_ERPDAT.Process_messg =3;
end
end



%%----------------Zoom in-------------------------------------------------
function zoomin(~,~)
global viewer_ERPDAT;

[messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
if ~isempty(messgStr)
    viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
end
zoomSpace = estudioworkingmemory('zoomSpace');
if isempty(zoomSpace)
    estudioworkingmemory('zoomSpace',0)
else
    if zoomSpace<0
        zoomSpace = 0;
    end
    zoomSpace =zoomSpace+10;
    estudioworkingmemory('zoomSpace',zoomSpace) ;
end
MessageViewer= char(strcat('Zoom In'));
erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
try
    viewer_ERPDAT.Process_messg =1;
    f_redrawERP_viewer_test();
    viewer_ERPDAT.Process_messg =2;
catch
    viewer_ERPDAT.Process_messg =3;
end
end


%%Reset each panel that using the default parameters
function Panel_Reset(~,~)
global viewer_ERPDAT;
global gui_erp_waviewer

estudioworkingmemory('MERPWaveViewer_label',[]);
estudioworkingmemory('MERPWaveViewer_others',[]);

MessageViewer= char(strcat('Reset'));
erpworkingmemory('ERPViewer_proces_messg',MessageViewer);

try
    viewer_ERPDAT.Process_messg =1;
    viewer_ERPDAT.Reset_Waviewer_panel=1;
    estudioworkingmemory('zoomSpace',0);
    f_redrawERP_viewer_test();
    viewer_ERPDAT.Process_messg =2;
catch
    viewer_ERPDAT.Process_messg =3;
end

%%Reset the window size and position
new_pos = [0.01,0.01,75,75];
erpworkingmemory('ERPWaveScreenPos',new_pos);
try
    ScreenPos =  get( groot, 'Screensize' );
catch
    ScreenPos =  get( 0, 'Screensize' );
end
gui_erp_waviewer.screen_pos = new_pos;
new_pos =[ScreenPos(3)*new_pos(1)/100,ScreenPos(4)*new_pos(2)/100,ScreenPos(3)*new_pos(3)/100,ScreenPos(4)*new_pos(4)/100];
set(gui_erp_waviewer.Window, 'Position', new_pos);

end




function zoomedit(Source,~)
global viewer_ERPDAT;

[messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
if ~isempty(messgStr)
    viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
end

zoomspaceEdit = str2num(Source.String);
MessageViewer= char(strcat('Zoom Editor'));
erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
if ~isempty(zoomspaceEdit) && numel(zoomspaceEdit)==1 && zoomspaceEdit>=0
    estudioworkingmemory('zoomSpace',zoomspaceEdit);
    try
        viewer_ERPDAT.Process_messg =1;
        f_redrawERP_viewer_test();
        viewer_ERPDAT.Process_messg =2;
        return;
    catch
        viewer_ERPDAT.Process_messg =3;
        return;
    end
else
    if isempty(zoomspaceEdit)
        fprintf(2,['\n Zoom Editor:The input must be a number','.\n']);
        viewer_ERPDAT.Process_messg =3;
        return;
    end
    if numel(zoomspaceEdit)>1
        fprintf(2,['\n Zoom Editor:The input must be a single number','.\n']);
        viewer_ERPDAT.Process_messg =3;
        return;
    end
    if zoomspaceEdit<0
        fprintf(2,['\n Zoom Editor:The input must be a positive number','.\n']);
        viewer_ERPDAT.Process_messg =3;
        return;
    end
end

end

%%----------------Zoom out-------------------------------------------------
function zoomout(~,~)
global viewer_ERPDAT;

[messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
if ~isempty(messgStr)
    viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
end

zoomSpace = estudioworkingmemory('zoomSpace');
if isempty(zoomSpace)
    estudioworkingmemory('zoomSpace',0)
else
    zoomSpace =zoomSpace-10;
    if zoomSpace <0
        zoomSpace =0;
    end
    estudioworkingmemory('zoomSpace',zoomSpace) ;
end
MessageViewer= char(strcat('Zoom Out'));
erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
try
    viewer_ERPDAT.Process_messg =1;
    f_redrawERP_viewer_test();
    viewer_ERPDAT.Process_messg =2;
catch
    viewer_ERPDAT.Process_messg =3;
end
end


function V_messg_change(~,~)
global viewer_ERPDAT;
global gui_erp_waviewer;
FonsizeDefault = f_get_default_fontsize();
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;%%Get background color
catch
    ColorBviewer_def = [0.7765,0.7294,0.8627];
end
if isempty(ColorBviewer_def)
    ColorBviewer_def = [0.7765,0.7294,0.8627];
end
gui_erp_waviewer.Process_messg.BackgroundColor = [0.95 0.95 0.95];
gui_erp_waviewer.Process_messg.FontSize = FonsizeDefault;
Processed_Method=erpworkingmemory('ERPViewer_proces_messg');
if viewer_ERPDAT.Process_messg ==1
    gui_erp_waviewer.Process_messg.String =  strcat('1- ',Processed_Method,': Running....');
    gui_erp_waviewer.Process_messg.ForegroundColor = [0 0 0];
elseif viewer_ERPDAT.Process_messg ==2
    gui_erp_waviewer.Process_messg.String =  strcat('2- ',Processed_Method,': Complete');
    gui_erp_waviewer.Process_messg.ForegroundColor = [0 0.5 0];
    
elseif viewer_ERPDAT.Process_messg ==3
    if ~strcmp(gui_erp_waviewer.Process_messg.String,strcat('3- ',Processed_Method,': Error (see Command Window)'))
    fprintf([Processed_Method,32,32,32,datestr(datetime('now')),'\n.']);
    end
    gui_erp_waviewer.Process_messg.String =  strcat('3- ',Processed_Method,': Error (see Command Window)');
    gui_erp_waviewer.Process_messg.ForegroundColor = [1 0 0];
else
    if ~strcmpi(gui_erp_waviewer.Process_messg.String,strcat('Warning:',32,Processed_Method,32,'(see Command Window).'))
        fprintf([Processed_Method,32,32,32,datestr(datetime('now')),'\n.']);
    end
    gui_erp_waviewer.Process_messg.String =  strcat('Warning:',32,Processed_Method,32,'(see Command Window).');
    
    pause(0.5);
    gui_erp_waviewer.Process_messg.ForegroundColor = [1 0.65 0];
end
if viewer_ERPDAT.Process_messg ==1 || viewer_ERPDAT.Process_messg==2 || viewer_ERPDAT.Process_messg==3
    pause(0.01);
    gui_erp_waviewer.Process_messg.String = '';
    gui_erp_waviewer.Process_messg.BackgroundColor = ColorBviewer_def;%[0.95 0.95 0.95];
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%-------------------------------Plot waves------------------------------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f_plotviewerwave(ALLERP,qCURRENTPLOT, qPLOTORG,qbinArray,qchanArray,qGridposArray,plotBox,qBlc,qLineColorspec,qLineStylespec,qLineMarkerspec,qLineWidthspec,...
    qLegendName,qLegendFont,qLegendFontsize,qCBELabels,qLabelfont,qLabelfontsize,qPolarityWave,qSEM,qTransparency,qGridspace,qtimeRange,qXticks,qXticklabel,...
    qXlabelfont,qXlabelfontsize,qXlabelcolor,qMinorTicksX,qXunits,qYScales,qYticks,qYticklabel,qYlabelfont,qYlabelfontsize,qYlabelcolor,qYunits,qMinorTicksY,qplotArrayStr,...
    ERPsetArray,qlegcolor,qlegcolumns,qlabelcolor,qytickprecision,qxtickprecision,qxdisFlag,myerpviewer,myerpviewerlegend)

hbig = myerpviewer;
if nargin<1
    help f_ploterpserpviewer;
    return
end

if isempty(ALLERP)
    msgboxText =  'No ALLERP was found!';
    title_msg  = 'EStudio: f_plotviewerwave() error:';
    errorfound(msgboxText, title_msg);
    return;
end

if max(ERPsetArray)>length(ALLERP)
    ERPsetArray=length(ALLERP);
end

[chanStrdef,binStrdef] = f_geterpschanbin(ALLERP,[1:length(ALLERP)]);
qERPArray = ERPsetArray;


if nargin<5
    qchanArray = 1:length(chanStrdef);
end

Existchan = f_existvector([1:length(chanStrdef)],qchanArray);
if  Existchan==1
    qchanArray = [1:length(chanStrdef)];
    Existchan =1;
end


if nargin<4
    qbinArray = 1:length(binStrdef);
end
Existbin = f_existvector([1:length(binStrdef)],qbinArray);
if Existbin==1
    qbinArray = 1:length(binStrdef);
    Existbin = 1;
end

if nargin<3
    qPLOTORG = [1 2 3];%%Channel is "Grid"; Bin is "Overlay"; ERPst is page
end

%%check ALLERP and adjust "qPLOTORG"
for Numofselectederp = 1:numel(ERPsetArray)
    SrateNum_mp(Numofselectederp,1)   =  ALLERP(ERPsetArray(Numofselectederp)).srate;
    Datype{Numofselectederp} =   ALLERP(ERPsetArray(Numofselectederp)).datatype;
end
if (qPLOTORG(1)==1 && qPLOTORG(2)==2) || (qPLOTORG(1)==2 && qPLOTORG(2)==1)
    
else
    if length(unique(Datype))~=1
        msgboxText =  'Type of data across ERPsets is different!';
        title_msg  = 'EStudio: f_plotviewerwave() error:';
        errorfound(msgboxText, title_msg);
        return;
    end
    if length(unique(SrateNum_mp))~=1
        msgboxText =  'Sampling rate varies across ERPsets!';
        title_msg  = 'EStudio: f_plotviewerwave() error:';
        errorfound(msgboxText, title_msg);
        return;
    end
end

if  nargin<2|| isempty(qCURRENTPLOT)
    qCURRENTPLOT = 1;
end
if  ~isnumeric(qCURRENTPLOT)
    msgboxText =  'qCURRENTPLOT must be a numeric!';
    title_msg  = 'EStudio: f_plotviewerwave() error:';
    errorfound(msgboxText, title_msg);
    return;
end
if qCURRENTPLOT <=0
    msgboxText =  'qCURRENTPLOT must be a positive numeric!';
    title_msg  = 'EStudio: f_plotviewerwave() error:';
    errorfound(msgboxText, title_msg);
    return;
end

if qPLOTORG(1) ==1
    plotArray = qchanArray;
elseif qPLOTORG(1) ==2
    plotArray =   qbinArray;
elseif qPLOTORG(1) ==3
    plotArray =   qERPArray;
else
    plotArray = qchanArray;
end
plotBoxdef = f_getrow_columnautowaveplot(plotArray);
if isempty(qPLOTORG) || numel(qPLOTORG)~=3 ||  numel(unique(qPLOTORG)) ~=3 || min(qPLOTORG)<0 || max(qPLOTORG)>3
    qPLOTORG = [1 2 3];
end

if qPLOTORG(2) ==1 %% if  the selected Channel is "Grid"
    OverlayArraydef = qchanArray;
    for Numofchan = 1:numel(qchanArray)
        LegendNamedef{Numofchan,1} =char(chanStrdef(qchanArray(Numofchan)));
    end
elseif qPLOTORG(2) == 2 %% if the selected Bin is "Grid"
    OverlayArraydef = qbinArray;
    for Numofbin = 1:numel(qbinArray)
        LegendNamedef{Numofbin,1} = char(binStrdef(qbinArray(Numofbin)));
    end
elseif qPLOTORG(2) == 3%% if the selected ERPset is "Grid"
    OverlayArraydef = qERPArray;
    for Numoferpset = 1:numel(qERPArray)
        try
            LegendNamedef{Numoferpset} = ALLERPIN(qERPArray(Numoferpset)).erpname;
        catch
            LegendNamedef{Numoferpset} = '';
        end
    end
else
    OverlayArraydef = qbinArray;
    for Numofbin = 1:numel(qbinArray)
        LegendNamedef{Numofbin,1} = char(binStr(qbinArray(Numofbin)));
    end
end

LineColordef = [0 0 0;1 0 0;0 0 1;0 1 0;1,0.65 0;0 1 1;1 0 1;0.5 0.5 0.5;0.94 0.50 0.50;0 0.75 1;0.57 0.93 0.57;1 0.55 0;1 0.75 0.80;1 0.84 0];%% get from:https://htmlcolorcodes.com/color-names/

LineMarkerdef = {'none','none','none','none','+','o','*'};
LineStyledef = {'-','--',':','-.','-','-','-',};
[ERPdatadef,legendNamedef,ERPerrordatadef,timeRangedef] = f_geterpdata(ALLERP,[1:length(ALLERP)],qPLOTORG);
%%%%%%%%%%%%%%%%%%%%--------------------------------------------------------
plotArrayStrdef ='';
if qPLOTORG(1) ==1 %% if  the selected Channel is "Grid"
    plotArray = qchanArray;
    for Numofchan = 1:numel(plotArray)
        try
            plotArrayStrdef{Numofchan} = chanStrdef{plotArray(Numofchan)};
        catch
            plotArrayStrdef{Numofchan} = 'no';
        end
    end
elseif qPLOTORG(1) == 2 %% if the selected Bin is "Grid"
    plotArray = qbinArray;
    for Numofbin = 1:numel(plotArray)
        try
            plotArrayStrdef{Numofbin} = binStrdef{plotArray(Numofbin)};
        catch
            plotArrayStrdef{Numofbin} = 'no';
        end
    end
elseif qPLOTORG(1) == 3%% if the selected ERPset is "Grid"
    plotArray = qERPArray;
    for Numoferp = 1:numel(plotArray)
        try
            plotArrayStrdef{Numoferp} = ALLERP(plotArray(Numoferp)).erpname;
        catch
            plotArrayStrdef{Numoferp} = 'no';
        end
    end
else
    plotArray = qchanArray;
    for Numofchan = 1:numel(chanArray)
        try
            plotArrayStrdef{Numofchan} = chanStrdef{plotArray(Numofchan)};
        catch
            plotArrayStrdef{Numofchan} = 'no';
        end
    end
end


if nargin<46 || (qxdisFlag~=1 && qxdisFlag~=0)
    qxdisFlag =1;
end
% if qxdisFlag==0
%  timeRangedef = timeRangedef/1000;
% end

if nargin<45 || qxtickprecision<0
    qxtickprecision =0;
else
    qxtickprecision =ceil(qxtickprecision);
end

if nargin<44 || qytickprecision<0
    qytickprecision =1;
end
qytickprecision = ceil(qytickprecision);

if nargin<43
    qlabelcolor = [0 0 0];
end


if nargin <42
    qlegcolumns=1;
end

if qlegcolumns<0 || isempty(qlegcolumns)
    qlegcolumns =1;
end

if nargin <41
    qlegcolor=1;
end

if isempty(qlegcolor) || (qlegcolor~=1 && qlegcolor~=0)
    qlegcolor=1;
end

if nargin <39 || isempty(qplotArrayStr)
    qplotArrayStr  = plotArrayStrdef;
end


%%
if nargin <38
    qMinorTicksY  = 0;
end

%%display y units?
if nargin<37
    qYunits  = 'on';
end

%%ylable color
if nargin <36
    qYlabelcolor = [0 0 0];
end

%%ylabel fontsize
if nargin<35
    qYlabelfontsize =10;
end

%%ylable font
if nargin <34
    qYlabelfont = 'Helvetica';
end

%%display ylabels?
if nargin<33
    qYticklabel = 'on';
end

%%yticks
datresh = squeeze(ERPdatadef(qchanArray,:,qbinArray,qERPArray));
yymax   = max(datresh(:));
yymin   = min(datresh(:));
if ~isempty(yymax) && isempty(yymin)
    if abs(yymax)<1 && abs(yymin)<1
        try
            scalesdef(1:2) = [yymin*1.2 yymax*1.1]; % JLC. Mar 11, 2015
        catch
            scalesdef(1:2) = [-1 1];
        end
    else
        scalesdef(1:2) = [floor(yymin*1.2) ceil(yymax*1.1)]; % JLC. Sept 26, 2012
    end
else
    scalesdef(1:2) = [-1 1];
end
yylim_out = f_erpAutoYLim(ALLERP, qERPArray,qPLOTORG,qbinArray, qchanArray,qCURRENTPLOT);
try
    Yscalesdef = yylim_out(qCURRENTPLOT,:);
catch
    Yscalesdef = scalesdef;
end
if nargin <32
    if isempty(qYScales)
        qYticks = default_amp_ticks_viewer(Yscalesdef);
    else
        qYticks = default_amp_ticks_viewer(qYScales);
    end
end

%%y scale
if nargin <31
    qYScales = Yscalesdef;
end

%%display x units?
if nargin <30
    qXunits = 'on';
end
%%minor of xlabel
if nargin <29
    qMinorTicksX = 0;
end

%%xlabel color
if nargin <28
    qXlabelcolor = [0 0 0];
end

%%xlabel fontsize
if nargin <27
    qXlabelfontsize = 10;
end


%%xlabel font
if nargin <26
    qXlabelfont= 'Helvetica';
end

%%disply xtick labels ?
if nargin<25
    qXticklabel = 'on';
end

%%xticks
try
    ERPIN = ALLERP(qCURRENTPLOT);
catch
    ERPIN = ALLERP(end);
end
if isempty(qtimeRange)
    qtimeRange(1) = timeRangedef(1);
    qtimeRange(2) = timeRangedef(end);
end
try
    [timeticksdef stepX]= default_time_ticks_studio(ERPIN, qtimeRange);
    timeticksdef = str2num(char(timeticksdef));
catch
    timeticksdef = [];
end
if nargin<24
    qXticks = timeticksdef;
end

%%time range of plot wave
if nargin<23
    qtimeRange(1) = timeRangedef(1);
    qtimeRange(2) = timeRangedef(end);
end


%%Grid space
if nargin<22
    qGridspace =[1 10; 1 10];
end
if isempty(qGridspace) || numel(qGridspace)~=4 || (size(qGridspace,1)~=2 || size(qGridspace,2)~=2)
    qGridspace =[1 10; 1 10];
else
    [rowgs,columgs] = size(qGridspace);
    if rowgs~=2 || columgs~=2
        qGridspace =[1 10; 1 10];
    else
        if qGridspace(1,1)~=1 && qGridspace(1,1)~=2
            qGridspace(1,1) =1;
        end
        if (qGridspace(1,1)==1 && qGridspace(1,2)<=0)
            qGridspace(1,2) =10;
        elseif (qGridspace(1,1)==2 && (qGridspace(1,2)<=0|| qGridspace(1,2)>100))
            qGridspace(1,2) =10;
        end
        if qGridspace(2,1)~=1 && qGridspace(2,1)~=2
            qGridspace(2,1) =1;
        end
        if (qGridspace(2,1)==1 && qGridspace(2,2)<=0)
            qGridspace(2,2) =10;
        elseif (qGridspace(2,1)==2 && (qGridspace(2,2)<=0|| qGridspace(2,2)>=100))
            qGridspace(2,2) =10;
        end
    end
end



%%Transparency
if nargin <21
    qTransparency = 0;
end

%%standard error of mean
if nargin <20
    qSME = 0;
end


%%polarity of wave; the default is positive up
if nargin <19
    qPolarityWave = 1;
end

%%fontsize of channel/bin/erpset label
if nargin <18
    qLabelfontsize = 10;
end

%%font of channel/bin/erpset label
if nargin <17
    qLabelfont= 'Helvetica';
end

%%location of channel/bin/erpset label
if nargin<16
    qCBELabels =[ ];
end

%%fontsize of legend name
if nargin <15
    qLegendFontsize  = 10;
end

%%font of legend name
if nargin <14
    qLegendFont  = 'Helvetica';
end

%%legend name
if nargin < 13
    qLegendName=LegendNamedef;
end

%%line width
for Numofcolor = 1:numel(OverlayArraydef)
    qLineWidthspecdef(1,Numofcolor) =1;
end
if nargin < 12
    qLineWidthspec = qLineWidthspecdef;
end


%%line marker
for Numofcolor = 1:numel(OverlayArraydef)
    NumIndex = ceil(Numofcolor/7);
    try
        qLineMarkerspecdef{1,Numofcolor} =  LineMarkerdef{NumIndex};
    catch
        qLineMarkerspecdef{1,Numofcolor} = 'none';
    end
end
if  nargin< 11
    qLineMarkerspec = qLineMarkerspecdef;
end


%%line style
for Numofcolor = 1:numel(OverlayArraydef)
    NumIndex = ceil(Numofcolor/7);
    try
        qLineStylespecdef{1,Numofcolor} =  LineStyledef{NumIndex};
    catch
        qLineStylespecdef{1,Numofcolor} = '-';
    end
end
if nargin< 10
    qLineStylespec = qLineStylespecdef;
end


%%line color
for Numofcolor = 1:numel(OverlayArraydef)
    Numindex = floor(Numofcolor/14);
    if Numindex==0
        try
            qLineColorspecdef(Numofcolor,:) = LineColordef(Numofcolor,:);
        catch
            qLineColorspecdef(Numofcolor,:) = [0 0 0];
        end
    elseif Numindex~=0
        if  floor(Numofcolor/14) ==ceil(Numofcolor/14)
            qLineColorspecdef(Numofcolor,:) = LineColordef(14,:);
        else
            try
                qLineColorspecdef(Numofcolor,:) = LineColordef(Numofcolor-14*Numindex,:);
            catch
                qLineColorspecdef(Numofcolor,:) = [0 0 0];
            end
        end
    else
        try
            qLineColorspecdef(Numofcolor,:) = LineColordef(14,:);
        catch
            qLineColorspecdef(Numofcolor,:) = [0 0 0];
        end
    end
end
if nargin< 9
    qLineColorspec = qLineColorspecdef;
end

if isempty(qLineColorspec)
    qLineColorspec = qLineColorspecdef;
end

if nargin<8
    qBlc  = 'none';
end

if nargin<7 ||  isempty(plotBoxdef) ||  numel(plotBoxdef)~=2
    plotBox =plotBoxdef;
end


NumRows = ceil(plotBox(1));
NumColumns = ceil(plotBox(2));
if nargin<6 || isempty(qGridposArray)
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
    qGridposArray = GridposArraydef;
end
%%check elements in qGridposArray
plotArray = reshape(plotArray,1,[]);
for Numofrows = 1:size(qGridposArray,1)
    for Numofcolumns = 1:size(qGridposArray,2)
        SingleGridpos = qGridposArray(Numofrows,Numofcolumns);
        if SingleGridpos~=0
            ExistGridops = f_existvector(plotArray,SingleGridpos);
            if ExistGridops==1
                qGridposArray(Numofrows,Numofcolumns) =0;
            else
                [xpos,ypos]=  find(plotArray==SingleGridpos);
                qGridposArray(Numofrows,Numofcolumns) =ypos;
            end
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%-------------------------------Plot wave--------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for Numoferpset = 1:length(ALLERP)
    DataType{Numoferpset} = ALLERP(Numoferpset).datatype;
end
DataType = unique(DataType);

ALLERPBls = ALLERP;
%
%%baseline correction
if length(DataType)==1 && strcmpi(char(DataType), 'ERP')
    if (qPLOTORG(1)==1 && qPLOTORG(2)==2) || (qPLOTORG(1)==2 && qPLOTORG(2)==1)
        try
            ERPArraybls = qERPArray(qCURRENTPLOT);
        catch
            ERPArraybls = qERPArray(end);
        end
    else
        ERPArraybls = qERPArray;
    end
    for Numoferpset = ERPArraybls
        ERP = ALLERP(Numoferpset);
        if ~strcmpi(qBlc,'no') && ~strcmpi(qBlc,'none')%% when the baseline correction is "pre","post","whole"
            
            if strcmpi(qBlc,'pre')
                indxtimelock = find(ERP.times==0) ;   % zero-time locked
                aa = 1;
            elseif strcmpi(qBlc,'post')
                indxtimelock = length(ERP.times);
                aa = find(ERP.times==0);
            elseif strcmpi(qBlc,'all') || strcmpi(qBlc,'whole')
                indxtimelock = length(ERP.times);
                aa = 1;
            else
                fs = ERP.srate;
                kktime =1000;
                toffsa = abs(round(ERP.xmin*fs))+1;   % +1 October 2nd 2008
                blcnum = qBlc/kktime;               % from msec to secs  03-28-2009
                %
                % Check & fix baseline range
                %
                if blcnum(1)<ERP.xmin
                    blcnum(1) = ERP.xmin;
                end
                if blcnum(2)>ERP.xmax
                    blcnum(2) = ERP.xmax;
                end
                aa     = round(blcnum(1)*fs)+ toffsa; % in samples 12-16-2008
                indxtimelock = round(blcnum(2)*fs) + toffsa;    % in samples
            end
            
            for Numofchan = qchanArray
                for Numofbin = qbinArray
                    if Numofchan<= ERP.nchan && Numofbin<= ERP.nbin
                        baselineV = mean(ERP.bindata(Numofchan,aa:indxtimelock,Numofbin),2);
                        ERP.bindata(Numofchan,:,Numofbin) =  ERP.bindata(Numofchan,:,Numofbin)-baselineV;
                    end
                end
            end
        end
        ALLERPBls(Numoferpset) = ERP;
    end
    
else
    qBlc = 'no';
end

datatype ='';
% [ERPdatadef,legendNamedef,ERPerrordatadef,timeRangedef]
[ERPdatadef,legendNamedef,ERPerrordatadef,timeRangedef] = f_geterpdata(ALLERPBls,qERPArray,qPLOTORG,qCURRENTPLOT);

if qPLOTORG(1)==1 && qPLOTORG(2)==2 %% Array is plotnum by samples by datanum
    if qCURRENTPLOT> numel(qERPArray)
        qCURRENTPLOT= length(qERPArray);
    end
    bindata = ERPdatadef(qchanArray,:,qbinArray,qCURRENTPLOT);
    bindataerror = ERPerrordatadef(qchanArray,:,qbinArray,qCURRENTPLOT);
    %     if isempty(timeRangedef)
    timeRangedef = ALLERPBls(qERPArray(qCURRENTPLOT)).times;
    %     end
    try
        fs= ALLERPBls(qERPArray(qCURRENTPLOT)).srate;
        datatype = ALLERPBls(qERPArray(qCURRENTPLOT)).datatype;
    catch
        fs= ALLERPBls(end).srate;
        datatype = ALLERPBls(end).datatype;
    end
elseif  qPLOTORG(1)==2 && qPLOTORG(2)==1
    if qCURRENTPLOT> length(qERPArray)
        qCURRENTPLOT= length(qERPArray);
    end
    bindata = ERPdatadef(qchanArray,:,qbinArray,qCURRENTPLOT);
    bindata = permute(bindata,[3 2 1 4]);
    bindataerror = ERPerrordatadef(qchanArray,:,qbinArray,qCURRENTPLOT);
    bindataerror = permute(bindataerror,[3 2 1 4]);
    if isempty(timeRangedef)
        timeRangedef = ALLERPBls(qERPArray(qCURRENTPLOT)).times;
    end
    try
        fs= ALLERPBls(qERPArray(qCURRENTPLOT)).srate;
        datatype = ALLERPBls(qERPArray(qCURRENTPLOT)).datatype;
    catch
        fs= ALLERPBls(end).srate;
        datatype = ALLERPBls(end).datatype;
    end
elseif qPLOTORG(1)==1 && qPLOTORG(2)==3 %%Grid is channel; Overlay is ERPsets; Page is bin
    if qCURRENTPLOT> numel(qbinArray)
        qCURRENTPLOT = numel(qbinArray);
    end
    bindata = ERPdatadef(qchanArray,:,qbinArray(qCURRENTPLOT),:);
    bindata = permute(bindata,[1 2 4 3]);
    bindataerror = ERPerrordatadef(qchanArray,:,qbinArray(qCURRENTPLOT),:);
    bindataerror = permute(bindataerror,[1 2 4 3]);
    try
        fs= ALLERPBls(qERPArray(end)).srate;
        datatype = ALLERPBls(qERPArray(end)).datatype;
    catch
        fs= ALLERPBls(end).srate;
        datatype = ALLERPBls(end).datatype;
    end
elseif qPLOTORG(1)==3 && qPLOTORG(2)==1%%Grid is ERPsets; Overlay is channel
    if qCURRENTPLOT> numel(qbinArray)
        qCURRENTPLOT = numel(qbinArray);
    end
    bindata = ERPdatadef(qchanArray,:,qbinArray(qCURRENTPLOT),:);
    bindata = permute(bindata,[4 2 1 3]);
    bindataerror = ERPerrordatadef(qchanArray,:,qbinArray(qCURRENTPLOT),:);
    bindataerror = permute(bindataerror,[4 2 1 3]);
    try
        fs= ALLERPBls(qERPArray(end)).srate;
        datatype = ALLERPBls(qERPArray(end)).datatype;
    catch
        fs= ALLERPBls(end).srate;
        datatype = ALLERPBls(end).datatype;
    end
elseif qPLOTORG(1)==2 && qPLOTORG(2)==3%%Grid is bin; Overlay is ERPset; Page is channel
    if qCURRENTPLOT> numel(qchanArray)
        qCURRENTPLOT = numel(qchanArray);
    end
    bindata = ERPdatadef(qchanArray(qCURRENTPLOT),:,qbinArray,:);
    bindata = permute(bindata,[3 2 4 1]);
    bindataerror = ERPerrordatadef(qchanArray(qCURRENTPLOT),:,qbinArray,:);
    bindataerror = permute(bindataerror,[3 2 4 1]);
    try
        fs= ALLERPBls(qERPArray(end)).srate;
        datatype = ALLERPBls(qERPArray(end)).datatype;
    catch
        fs= ALLERPBls(end).srate;
        datatype = ALLERPBls(end).datatype;
    end
elseif qPLOTORG(1)==3 && qPLOTORG(2)==2%%Grid is ERPset; Overlay is bin; Page is channel
    if qCURRENTPLOT> numel(qchanArray)
        qCURRENTPLOT = numel(qchanArray);
    end
    bindata = ERPdatadef(qchanArray(qCURRENTPLOT),:,qbinArray,:);
    bindata = permute(bindata,[4 2 3 1]);
    bindataerror = ERPerrordatadef(qchanArray(qCURRENTPLOT),:,qbinArray,:);
    bindataerror = permute(bindataerror,[4 2 3 1]);
    try
        fs= ALLERPBls(qERPArray(end)).srate;
        datatype = ALLERPBls(qERPArray(end)).datatype;
    catch
        fs= ALLERPBls(end).srate;
        datatype = ALLERPBls(end).datatype;
    end
else
    if qCURRENTPLOT> length(qERPArray)
        qCURRENTPLOT= length(qERPArray);
    end
    bindata = ERPdatadef(qchanArray,:,qbinArray,qCURRENTPLOT);
    bindataerror = ERPerrordatadef(qchanArray,:,qbinArray,qCURRENTPLOT);
    if isempty(timeRangedef)
        timeRangedef = ALLERPBls(qERPArray(qCURRENTPLOT)).times;
    end
    try
        fs= ALLERPBls(qERPArray(end)).srate;
        datatype = ALLERPBls(qERPArray(end)).datatype;
    catch
        fs= ALLERPBls(end).srate;
        datatype = ALLERPBls(end).datatype;
    end
end
%
if isempty(qtimeRange)
    qtimeRange = [timeRangedef(1) timeRangedef(end)];
end

Numrows = size(qGridposArray,1);
Numcolumns = size(qGridposArray,2);

pboxTotal = 1:Numrows*Numcolumns;
corners = linspace(Numrows*Numcolumns-Numcolumns+1,Numrows*Numcolumns,Numcolumns);
pboxplot  = setxor(pboxTotal, corners);
if isempty(pboxplot)
    pboxplot = 1;
end

NumOverlay = size(bindata,3);


%%get y axis
y_scale_def = [1.1*min(bindata(:)),1.1*max(bindata(:))];
yMaxdef = ceil(max(bindata(:)))-floor(min(bindata(:)));
try
    isyaxislabel = qGridspace(1,1);
    Ypert = qGridspace(1,2);
catch
    isyaxislabel = 1;
    Ypert = 100;
end
if isempty( qYScales)
    qYScales = [floor(min(bindata(:))),ceil(max(bindata(:)))];
end
if isempty(y_scale_def)
    y_scale_def = qYScales;
end
if isyaxislabel==1 %% y axis GAP
    if  Ypert<0
        Ypert = 100;
    end
    if ~isempty(qYScales)
        if numel(qYScales)==2
            yscaleall = qYScales(end)-qYScales(1);
        else
            yscaleall = 2*max(abs(qYScales));
            qYScales = [-max(abs(qYScales)),max(abs(qYScales))];
        end
        if yscaleall < y_scale_def(2)-y_scale_def(2)
            yscaleall = y_scale_def(2)-y_scale_def(2);
        end
        
        for Numofrows = 1:Numrows
            OffSetY(Numofrows) = yscaleall*(Numrows-Numofrows)*(Ypert/100+1);
        end
    else
        for Numofrows = 1:Numrows
            OffSetY(Numofrows) = yMaxdef*(Numrows-Numofrows)*(Ypert/100+1);
        end
    end
else%% y axis Overlay
    if Ypert>=100 || Ypert<=0
        Ypert = 40;
    end
    if ~isempty(qYScales)
        if numel(qYScales)==2
            yscaleall = qYScales(end)-qYScales(1);
        else
            yscaleall = 2*max(abs(qYScales));
            qYScales = [-max(abs(qYScales)),max(abs(qYScales))];
        end
        
        if yscaleall < y_scale_def(2)-y_scale_def(2)
            yscaleall = y_scale_def(2)-y_scale_def(2);
        end
        
        if Numrows ==1
            OffSetY = 0;
        else
            for Numofrows = 1:Numrows-1
                OffSetY(Numofrows) = yscaleall*(Numrows-Numofrows)*(1-(Ypert/100));
            end
            OffSetY(Numrows)=0;
        end
    else
        qYScales = [floor(min(bindata(:))),ceil(max(bindata(:)))];
        if Numrows ==1
            OffSetY = 0;
        else
            for Numofrows = 1:Numrows-1
                OffSetY(Numofrows) = yMaxdef*(Numrows-Numofrows)*(1-(Ypert/100));
            end
            OffSetY(Numrows)=0;
        end
    end
end


%%X axis gap
try
    isxaxislabel = qGridspace(2,1);
    Xpert = qGridspace(2,2);
catch
    isxaxislabel = 1;
    Xpert = 10;
end
if isxaxislabel ~=1 && isxaxislabel~=2
    isxaxislabel = 1;
end


if isxaxislabel==1 && Xpert<=0
    Xpert =10;
elseif isxaxislabel==2 && (Xpert<=0 || Xpert >=100)
    Xpert =40;
end
try
    StepX = (timeRangedef(end)-timeRangedef(1))*(Xpert/100);
catch
    beep;
    disp('ERP.times only has one element.');
    return;
end
StepXP = ceil(StepX/(1000/fs));


%%check yticks
try
    count =0;
    ytickDis =[];
    for Numofytick = 1:numel(qYticks)
        if qYticks(Numofytick) < qYScales(1) || qYticks(Numofytick) > qYScales(end)
            count = count+1;
            ytickDis(count) =  Numofytick;
        end
    end
    qYticks(ytickDis) = [];
catch
end
if isempty(qYticks)
    qYticks = str2num(char(default_amp_ticks_viewer(qYScales)));
end

%%Get the figure name which is to be plotted
if (qPLOTORG(1)==1 && qPLOTORG(2)==2) || (qPLOTORG(1)==1 && qPLOTORG(2)==2) %% Page is ERPset
    ERP = ALLERPBls(qCURRENTPLOT);
    if isempty(ERP.filename) || strcmp(ERP.filename,'')
        ERP.filename = 'still_not_saved!';
    end
    if isempty(ERP.erpname)
        fname = 'none';
    else
        [pathstr, fname, ext] = fileparts(ERP.erpname);
    end
elseif  (qPLOTORG(1)==1 && qPLOTORG(2)==3) || (qPLOTORG(1)==3 && qPLOTORG(2)==1) %% Page is bin
    fname = char(binStrdef{qbinArray(qCURRENTPLOT)});
    
elseif (qPLOTORG(1)==2 && qPLOTORG(2)==3) || (qPLOTORG(1)==3 && qPLOTORG(2)==2)
    fname = char(chanStrdef{qchanArray(qCURRENTPLOT)});
else
    ERP = ALLERPBls(qCURRENTPLOT);
    if isempty(ERP.filename) || strcmp(ERP.filename,'')
        ERP.filename = 'still_not_saved!';
    end
    if isempty(ERP.erpname)
        fname = 'none';
    else
        [pathstr, fname, ext] = fileparts(ERP.erpname);
    end
end

try
    y_scale_def(1) = min([1.1*y_scale_def(1),1.1*qYScales(1)]);
    y_scale_def(2) = max([1.1*y_scale_def(2),1.1*qYScales(2)]);
catch
end



%%remove the margins of a plot
ax = hbig;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];



%%--------------Plot ERPwave-----------------
stdalpha = qTransparency;
countPlot = 0;
for Numofrows = 1:Numrows
    for Numofcolumns = 1:Numcolumns
        plotdatalabel = qGridposArray(Numofrows,Numofcolumns);
        
        try
            labelcbe = qplotArrayStr{plotdatalabel};
        catch
            labelcbe = 'no';
        end
        try
            plotbindata =  bindata(plotdatalabel,:,:,:);
        catch
            plotbindata = [];
        end
        
        if plotdatalabel ~=0 && plotdatalabel<= numel(plotArray) && ~isempty(plotbindata)
            
            countPlot =countPlot +1;
            
            if qPolarityWave
                data4plot = squeeze(bindata(plotdatalabel,:,:,1));
            else
                data4plot = squeeze(bindata(plotdatalabel,:,:,1))*(-1);
            end
            data4plot = reshape(data4plot,numel(timeRangedef),NumOverlay);
            for Numofoverlay = 1:NumOverlay
                [Xtimerange, bindatatrs] = f_adjustbindtabasedtimedefd(squeeze(data4plot(:,Numofoverlay)), timeRangedef,qtimeRange,fs);
                PosIndexsALL = [Numofrows,Numcolumns];
                if isxaxislabel==2
                    [~,XtimerangetrasfALL,~,~,~] = f_adjustdata_xyrange_xyticks_overlay(bindatatrs,Xtimerange,qXticks,OffSetY,Numcolumns,PosIndexsALL,StepXP);
                else
                    [~,XtimerangetrasfALL,~] = f_adjustdata_xyrange_xyticks(bindatatrs,Xtimerange,qXticks,OffSetY,Numcolumns,PosIndexsALL,StepX,fs);
                end
                
                aerror = isnan(squeeze(bindataerror(plotdatalabel,:,Numofoverlay,1)));
                [Xerror,yerro] = find(aerror==0);
                
                PosIndexs = [Numofrows,Numofcolumns];
                if ~isempty(yerro) && qSEM>=1 &&stdalpha>0 %SEM
                    [Xtimerange, bindataerrtrs] = f_adjustbindtabasedtimedefd(squeeze(bindataerror(plotdatalabel,:,Numofoverlay,1)), timeRangedef,qtimeRange,fs);
                    if isxaxislabel==2
                        [bindatatrs1,Xtimerangetrasf,qXtickstransf,TimeAdjustOut,XtimerangeadjustALL] = f_adjustdata_xyrange_xyticks_overlay(bindatatrs,Xtimerange,qXticks,OffSetY,Numcolumns,PosIndexs,StepXP);
                    else
                        [bindatatrs1,Xtimerangetrasf,qXtickstransf] = f_adjustdata_xyrange_xyticks(bindatatrs,Xtimerange,qXticks,OffSetY,Numcolumns,PosIndexs,StepX,fs);
                    end
                    yt1 = bindatatrs1 - bindataerrtrs.*qSEM;
                    yt2 = bindatatrs1 + bindataerrtrs.*qSEM;
                    %                     ciplot(yt1,yt2, Xtimerangetrasf, qLineColorspec(Numofoverlay,:), stdalpha);
                    fill(hbig,[Xtimerangetrasf fliplr(Xtimerangetrasf)],[yt2 fliplr(yt1)], qLineColorspec(Numofoverlay,:), 'FaceAlpha', stdalpha, 'EdgeColor', 'none');
                    %                     set(hbig, 'InvertHardcopy', 'off', 'PaperPositionMode', 'auto', 'PaperOrientation', 'portrait');
                end
                if isxaxislabel==2
                    [bindatatrs,Xtimerangetrasf,qXtickstransf,TimeAdjustOut,XtimerangeadjustALL] = f_adjustdata_xyrange_xyticks_overlay(bindatatrs,Xtimerange,qXticks,OffSetY,Numcolumns,PosIndexs,StepXP);
                else
                    [bindatatrs,Xtimerangetrasf,qXtickstransf] = f_adjustdata_xyrange_xyticks(bindatatrs,Xtimerange,qXticks,OffSetY,Numcolumns,PosIndexs,StepX,fs);
                end
                hplot(Numofoverlay) = plot(hbig,Xtimerangetrasf, bindatatrs,'LineWidth',qLineWidthspec(Numofoverlay),...
                    'Color', qLineColorspec(Numofoverlay,:), 'LineStyle',qLineStylespec{Numofoverlay},'Marker',qLineMarkerspec{Numofoverlay});
            end
            
            if numel(OffSetY)==1 && OffSetY==0
                if ~qPolarityWave
                    YscalesNew =  sort(y_scale_def*(-1));
                else
                    YscalesNew =  y_scale_def;
                end
                set(hbig,'ylim',YscalesNew);
            else
                if qPolarityWave
                    ylimleftedge = floor(y_scale_def(1));
                    ylimrightedge = ceil(y_scale_def(end))+OffSetY(1);
                else
                    ylimleftedge = -abs(ceil(1.05*y_scale_def(end)));
                    ylimrightedge = ceil(1.05*abs(y_scale_def(1)))+OffSetY(1);
                end
                set(hbig,'ylim',[ylimleftedge,ylimrightedge]);
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%----------------------Adjust y axis------------------------%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            props = get(hbig);
            if qPolarityWave
                props.YTick = qYticks+OffSetY(Numofrows);
            else
                props.YTick =  fliplr (-1*qYticks)+OffSetY(Numofrows);
            end
            props.YTickLabel = cell(numel(props.YTick),1);
            
            
            for Numofytick = 1:numel(props.YTick)
                props.YTickLabel(Numofytick) = {num2str(props.YTick(Numofytick))};
            end
            
            [x,y_0] = find(Xtimerange==0);
            if isempty(y_0)
                y_0 = 1;
            end
            myY_Crossing = Xtimerangetrasf(y_0);
            tick_top = 0;
            if countPlot ==1
                ytick_bottom = -props.TickLength(1)*diff(props.XLim);
                ytick_bottomratio = abs(ytick_bottom)/diff(props.XLim);
            else
                try
                    ytick_bottom = ytick_bottom;
                    ytick_bottomratio = ytick_bottomratio;
                catch
                    ytick_bottom = -props.TickLength(1)*diff(props.XLim);
                    ytick_bottomratio = abs(ytick_bottom)/diff(props.XLim);
                end
            end
            %%add  yunits
            if  qPolarityWave%%Positive up
                yunitsypos = 0.98*qYScales(end);
            else
                yunitsypos = 0.95*abs(qYScales(1));
            end
            if strcmpi( datatype,'ERP')
                yunitstr =  '\muV';
            elseif strcmpi( datatype,'CSD')
                yunitstr =  '\muV/m^2';
            else
                yunitstr = '';
            end
            if strcmpi(qYunits,'on')
                text(hbig,myY_Crossing+abs(ytick_bottom),yunitsypos+OffSetY(Numofrows),yunitstr, 'FontName',qYlabelfont,'FontSize',qYlabelfontsize,'HorizontalAlignment', 'left', 'Color', qYlabelcolor);
            end
            if ~isempty(props.YTick)
                ytick_y = repmat(props.YTick, 2, 1);
                ytick_x = repmat([tick_top;ytick_bottom] +myY_Crossing, 1, length(props.YTick));
                line(hbig,ytick_x(:,:), ytick_y(:,:), 'color', 'k','LineWidth',1);
                try
                    [~,y_below0] =find(qYticks<0);
                    if isempty(y_below0) && qYScales(1)<0
                        line(hbig,ytick_x(:,:), ones(2,1)*(qYScales(1)+OffSetY(Numofrows)), 'color', 'k','LineWidth',1);
                    end
                    [~,y_over0] =find(qYticks>0);
                    if isempty(y_over0) && qYScales(2)>0
                        line(hbig,ytick_x(:,:), ones(2,1)*(qYScales(2)+OffSetY(Numofrows)), 'color', 'k','LineWidth',1);
                    end
                catch
                end
            end
            
            if ~isempty(qYScales)  && numel(qYScales)==2 %qYScales(end))+OffSetY(1)
                if  qPolarityWave==0
                    qYScalestras =   fliplr (-1*qYScales);
                else
                    qYScalestras = qYScales;
                end
                plot(hbig,ones(numel(qYScalestras),1)*myY_Crossing, qYScalestras+OffSetY(Numofrows),'k','LineWidth',1);
            else
                if ~isempty(y_scale_def) && numel(unique(y_scale_def))==2
                    if  qPolarityWave==0
                        qYScalestras =   fliplr (-1*y_scale_def);
                    else
                        qYScalestras = y_scale_def;
                    end
                    
                    plot(hbig,ones(numel(qYScales),1)*myY_Crossing, qYScalestras+OffSetY(Numofrows),'k','LineWidth',1);
                else
                    
                end
            end
            nYTicks = length(props.YTick);
            for iCount = 1:nYTicks
                if qPolarityWave
                    ytick_label= sprintf(['%.',num2str(qytickprecision),'f'],str2num(char(props.YTickLabel(iCount, :)))-OffSetY(Numofrows));
                else
                    qyticktras =   fliplr (-1*qYticks);
                    ytick_label= sprintf(['%.',num2str(qytickprecision),'f'],-qyticktras(iCount));
                end
                if str2num(char(ytick_label)) ==0 || (str2num(char(ytick_label))<0.0001 && str2num(char(ytick_label))>0) || (str2num(char(ytick_label))>-0.0001 && str2num(char(ytick_label))<0)
                    ytick_label = '';
                end
                if ~strcmpi(qYticklabel,'on')
                    ytick_label = '';
                end
                text(hbig,myY_Crossing-2*abs(ytick_bottom),props.YTick(iCount),  ...
                    ytick_label, ...
                    'HorizontalAlignment', 'right', ...
                    'VerticalAlignment', 'middle', ...
                    'FontSize', qYlabelfontsize, ...
                    'FontName', qYlabelfont, ...
                    'FontAngle', props.FontAngle, ...
                    'FontUnits', props.FontUnits,...
                    'Color',qYlabelcolor);
            end
            
            %%Minor Y
            if qMinorTicksY(1)
                set(hbig,'YMinorTick','on')
                try
                    MinorTicksYValue = qMinorTicksY(2:end);
                catch
                    MinorTicksYValue = [];
                end
                if ~isempty(MinorTicksYValue)
                    MinorTicksYValue(find(MinorTicksYValue<qYScales(1))) = [];%% check the minorticks based on the left edge of yticks
                    MinorTicksYValue(find(MinorTicksYValue>qYScales(end))) = [];%% check the minorticks based on the right edge of yticks
                    props.YAxis.TickValues = MinorTicksYValue;
                    if ~isempty( props.YAxis.TickValues)
                        ytick_y = repmat( props.YAxis.TickValues+OffSetY(Numofrows), 2, 1);
                        ytick_x = repmat([tick_top;2*ytick_bottom/3] +myY_Crossing, 1, length( props.YAxis.TickValues));
                        line(hbig,ytick_x(:,:), ytick_y(:,:), 'color', 'k','LineWidth',1);
                    end
                end
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%----------------------Adjust x axis------------------------%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            props.XTick = qXtickstransf;
            props.XTickLabel = cell(numel(qXticks),1);
            for Numofytick = 1:numel(props.XTick)
                props.XTickLabel(Numofytick) = {num2str(qXticks(Numofytick))};
            end
            myX_Crossing = OffSetY(Numofrows);
            if countPlot ==1
                xtick_bottom = -props.TickLength(2)*max(props.YLim);
                if abs(xtick_bottom)/max(props.YLim) > ytick_bottomratio
                    xtick_bottom = -ytick_bottomratio*max(props.YLim);
                end
            else
                try
                    xtick_bottom = xtick_bottom;
                catch
                    xtick_bottom = -props.TickLength(2)*max(props.YLim);
                    if abs(xtick_bottom)/max(props.YLim) > ytick_bottomratio
                        xtick_bottom = -ytick_bottomratio*max(props.YLim);
                    end
                end
            end
            if ~isempty(props.XTick)
                xtick_x = repmat(props.XTick, 2, 1);
                xtick_y = repmat([xtick_bottom; tick_top] + myX_Crossing, 1, length(props.XTick));
                line(hbig,xtick_x, xtick_y, 'color', 'k','LineWidth',1);
            end
            [x_xtick,y_xtick] = find(props.XTick==0);
            if ~isempty(y_xtick)
                props.XTick(y_xtick) = 2*xtick_bottom;
            end
            plot(hbig,Xtimerangetrasf, myX_Crossing.*ones(numel(Xtimerangetrasf),1),'k','LineWidth',1);
            nxTicks = length(props.XTick);
            
            for iCount = 1:nxTicks
                xtick_label = (props.XTickLabel(iCount, :));
                if strcmpi(qXticklabel,'on')
                    if strcmpi(xtick_label,'0')
                        xtick_label = '';
                    end
                else
                    xtick_label = '';
                end
                if qxdisFlag ==1%%in millisecond
                    xtick_label= sprintf(['%.',num2str(qxtickprecision),'f'],str2num(char(xtick_label)));
                else%% in second
                    xtick_label= sprintf(['%.',num2str(qxtickprecision),'f'],str2num(char(xtick_label))/1000);
                end
                
                if strcmpi(qXunits,'on') && (iCount== nxTicks) && qxdisFlag ==1
                    xtick_label = strcat(char(xtick_label),32,'ms');
                elseif strcmpi(qXunits,'on') && (iCount== nxTicks) && qxdisFlag ==0
                    xtick_label = strcat(char(xtick_label),32,'s');
                end
                text(hbig,props.XTick(iCount), xtick_bottom + myX_Crossing, ...
                    xtick_label, ...
                    'HorizontalAlignment', 'Center', ...
                    'VerticalAlignment', 'Top', ...
                    'FontSize', qXlabelfontsize, ...
                    'FontName', qXlabelfont, ...
                    'FontAngle', props.FontAngle, ...
                    'FontUnits', props.FontUnits,...
                    'Color',qXlabelcolor);
            end
            %%-----------------minor X---------------
            if  Xtimerange(1)< Xtimerangetrasf(end)
                set(hbig,'xlim',[Xtimerange(1),Xtimerangetrasf(end)]);
            end
            if qMinorTicksX(1)
                set(hbig,'XMinorTick','on');
                if isxaxislabel==2
                    xlimrightedgemin = TimeAdjustOut;
                else
                    timewindow_bin = Xtimerange(2)-Xtimerange(1);
                    xlimrightedgemin = timewindow_bin*(numel(Xtimerange)*(Numofcolumns-1)+StepXP*(Numofcolumns-1));
                end
                try
                    MinorTicksXValue = qMinorTicksX(2:end);
                catch
                    MinorTicksXValue = [];
                end
                if ~isempty(MinorTicksXValue)
                    MinorTicksXValue(find(MinorTicksXValue<Xtimerange(1))) = [];%% check the xminorticks based on the left edge of xticks
                    MinorTicksXValue(find(MinorTicksXValue>Xtimerange(end))) = [];%% check the xminorticks based on the right edge of xticks
                    props.XAxis.TickValues = unique(MinorTicksXValue+xlimrightedgemin);
                    if ~isempty(props.XAxis.TickValues)
                        xtick_x = repmat(props.XAxis.TickValues, 2, 1);
                        xtick_y = repmat([2*xtick_bottom/3; tick_top] + myX_Crossing, 1, length(props.XAxis.TickValues));
                        line(hbig,xtick_x, xtick_y, 'color', 'k','LineWidth',1);
                    end
                end
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%------------------channel/bin/erpset label-----------------%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if ~isempty(qCBELabels)
                try
                    iscenter = qCBELabels(3);
                catch
                    iscenter =1;
                end
                try
                    ypercentage=qCBELabels(2);
                catch
                    ypercentage =100;
                end
                ypos_LABEL = ((qYScalestras(end)-qYScalestras(1))*(ypercentage)/100+qYScalestras(1));
                try
                    xpercentage=qCBELabels(1);
                catch
                    xpercentage = 50;
                end
                xpos_LABEL = (Xtimerangetrasf(end)-Xtimerangetrasf(1))*xpercentage/100 + Xtimerangetrasf(1);
                labelcbe =  strrep(char(labelcbe),'_','\_');
                try
                    labelcbe = regexp(labelcbe, '\;', 'split');
                catch
                end
                if ~iscenter
                    text(hbig,xpos_LABEL,ypos_LABEL+OffSetY(Numofrows), char(labelcbe), 'FontName',qLabelfont,'FontSize',qLabelfontsize,'HorizontalAlignment', 'center',  'Color', qlabelcolor);%'FontWeight', 'bold',
                else
                    text(hbig,xpos_LABEL,ypos_LABEL+OffSetY(Numofrows), char(labelcbe), 'FontName',qLabelfont,'FontSize',qLabelfontsize,'HorizontalAlignment', 'left',  'Color', qlabelcolor);%'FontWeight', 'bold',
                end
            end
            
        else
            %             disp(['Data at',32,'R',num2str(Numofrows),',','C',num2str(Numofcolumns), 32,'is not defined!']);
        end
        try
            if 2<Numcolumns && Numcolumns<5
                set(hbig,'xlim',[Xtimerange(1)-(Xtimerange(end)-Xtimerange(1))/20,XtimerangetrasfALL(end)+(Xtimerange(end)-Xtimerange(1))/20]);
            elseif Numcolumns==1
                set(hbig,'xlim',[Xtimerange(1)-(Xtimerange(end)-Xtimerange(1))/40,XtimerangetrasfALL(end)+(Xtimerange(end)-Xtimerange(1))/40]);
            elseif Numcolumns==2
                set(hbig,'xlim',[Xtimerange(1)-(Xtimerange(end)-Xtimerange(1))/30,XtimerangetrasfALL(end)+(Xtimerange(end)-Xtimerange(1))/30]);
            else
                set(hbig,'xlim',[Xtimerange(1)-(Xtimerange(end)-Xtimerange(1))/10,XtimerangetrasfALL(end)+(Xtimerange(end)-Xtimerange(1))/10]);
            end
        catch
            
        end
    end%% end of columns
    
end%% end of rows
set(hbig, 'XTick', [], 'YTick', [],'Box','off', 'Color','none','xcolor','none','ycolor','none');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%------------------------------legend name------------------------------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    for Numofoverlay = 1:numel(hplot)
        qLegendName1 = strrep(qLegendName{Numofoverlay},'_','\_');
        %         qLegendName1 = qLegendName{Numofoverlay};
        LegendName{Numofoverlay} = char(strcat('\color[rgb]{',num2str(qLineColorspec(Numofoverlay,:)),'}',qLegendName1));
    end
    p  = get(myerpviewerlegend,'position');
    if qlegcolor ~=1
        try
            h_legend = legend(myerpviewerlegend, hplot,LegendName);%,'interpreter','none'
        catch
            h_legend = legend(myerpviewerlegend, hplot,qLegendName,'interpreter','none');
        end
    else
        h_legend = legend(myerpviewerlegend, hplot,qLegendName,'interpreter','none');
    end
    set(h_legend,'FontSize',qLegendFontsize);%% legend name fontsize
    set(h_legend, 'position', p);
    set(h_legend,'FontName',qLegendFont);%%legend name font
    set(h_legend,'NumColumns',qlegcolumns);
    
    legend(myerpviewerlegend,'boxoff');
    set(myerpviewerlegend, 'XTick', [], 'YTick', [],'Box','off', 'Color','none','xcolor','none','ycolor','none');
catch
end

end