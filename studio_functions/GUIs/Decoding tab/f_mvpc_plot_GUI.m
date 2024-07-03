%%This function is to plot the panel for "Viewer properties".

% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2024


function varargout = f_mvpc_plot_GUI(varargin)
global viewer_ERPDAT
global gui_mvpc_plot;
addlistener(viewer_ERPDAT,'v_currentERP_change',@v_currentERP_change);
addlistener(viewer_ERPDAT,'loadproper_change',@loadproper_change);
addlistener(viewer_ERPDAT,'count_twopanels_change',@count_twopanels_change);
addlistener(viewer_ERPDAT,'Reset_Waviewer_panel_change',@Reset_Waviewer_panel_change);

global observe_DECODE;
addlistener(observe_DECODE,'Count_currentMVPC_changed',@Count_currentMVPC_changed);
addlistener(observe_DECODE,'Reset_best_panel_change',@Reset_best_panel_change);



gui_mvpc_plot = struct();

%-----------------------------Name the title----------------------------------------------
% global box_erpxtaxes_viewer_property;
[version reldate,ColorB_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    box_erpxtaxes_viewer_property = uiextras.BoxPanel('Parent', fig, 'Title', 'Plotting MVPCsets', 'Padding', 5,...
        'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w','FontSize',12); % Create boxpanel
elseif nargin == 1
    box_erpxtaxes_viewer_property = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Plotting MVPCsets', 'Padding', 5,...
        'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w','FontSize',12);
else
    box_erpxtaxes_viewer_property = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Plotting MVPCsets', 'Padding', 5, ...
        'FontSize', varargin{2},'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w');
end
%-----------------------------Draw the panel-------------------------------------

try
    FonsizeDefault = varargin{2};
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
    FonsizeDefault = f_get_default_fontsize();
end


drawui_mvpc_plot(FonsizeDefault);
varargout{1} = box_erpxtaxes_viewer_property;

    function drawui_mvpc_plot(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
        
        gui_mvpc_plot.DataSelBox = uiextras.VBox('Parent', box_erpxtaxes_viewer_property,'BackgroundColor',ColorBviewer_def);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%Setting for X axis%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%-----------------Setting for time range-------
        gui_mvpc_plot.xaxis_title = uiextras.HBox('Parent', gui_mvpc_plot.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_mvpc_plot.xaxis_title,'String','X Axis:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','center','FontWeight','bold'); %
        
        %%-------Display with second or millisecond------------------------
        gui_mvpc_plot.display_title = uiextras.HBox('Parent', gui_mvpc_plot.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_mvpc_plot.display_title,...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Display in','HorizontalAlignment','left'); %
        gui_mvpc_plot.xmillisecond = uicontrol('Style','radiobutton','Parent',  gui_mvpc_plot.display_title,'Enable','off',...
            'callback',@xmilsecond,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Millisecond','Value',1); %
        gui_mvpc_plot.xmillisecond.KeyPressFcn = @xyaxis_presskey;
        gui_mvpc_plot.xsecond = uicontrol('Style','radiobutton','Parent',  gui_mvpc_plot.display_title,'Enable','off',...
            'callback',@xsecond,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Second','Value',0); %
        gui_mvpc_plot.xsecond.KeyPressFcn = @xyaxis_presskey;
        set(gui_mvpc_plot.display_title,'Sizes',[75 90 75]);
        
        %%------time range------
        gui_mvpc_plot.xtimerange_title = uiextras.HBox('Parent', gui_mvpc_plot.DataSelBox,'BackgroundColor',ColorBviewer_def);
        gui_mvpc_plot.timerange_label = uicontrol('Style','text','Parent', gui_mvpc_plot.xtimerange_title,...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Time Range','Max',10,'HorizontalAlignment','left'); %
        gui_mvpc_plot.timerange_edit = uicontrol('Style','edit','Parent', gui_mvpc_plot.xtimerange_title,'String','',...
            'callback',@timerangecustom,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off'); %
        gui_mvpc_plot.timerange_edit.KeyPressFcn = @xyaxis_presskey;
        gui_mvpc_plot.xtimerangeauto = uicontrol('Style','checkbox','Parent', gui_mvpc_plot.xtimerange_title,'String','Auto',...
            'callback',@xtimerangeauto,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',1,'Enable','off'); %
        gui_mvpc_plot.xtimerangeauto.KeyPressFcn = @xyaxis_presskey;
        set(gui_mvpc_plot.xtimerange_title,'Sizes',[80 100 60]);
        
        %%----------------------time ticks---------------------------------
        gui_mvpc_plot.xtimetick_title = uiextras.HBox('Parent', gui_mvpc_plot.DataSelBox,'BackgroundColor',ColorBviewer_def);
        gui_mvpc_plot.timeticks_label = uicontrol('Style','text','Parent',  gui_mvpc_plot.xtimetick_title ,...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Time Ticks','HorizontalAlignment','left'); %
        gui_mvpc_plot.timeticks_edit = uicontrol('Style','edit','Parent',  gui_mvpc_plot.xtimetick_title ,'String','',...
            'callback',@timetickscustom,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off'); %
        gui_mvpc_plot.timeticks_edit.KeyPressFcn = @xyaxis_presskey;
        gui_mvpc_plot.xtimetickauto = uicontrol('Style','checkbox','Parent',  gui_mvpc_plot.xtimetick_title ,'String','Auto',...
            'callback',@xtimetickauto,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',1,'Enable','off'); %
        gui_mvpc_plot.xtimetickauto.KeyPressFcn = @xyaxis_presskey;
        set(gui_mvpc_plot.xtimetick_title,'Sizes',[80 100 60]);
        
        %%--------x tick precision with decimals---------------------------
        gui_mvpc_plot.xtickprecision_title = uiextras.HBox('Parent', gui_mvpc_plot.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uiextras.Empty('Parent',  gui_mvpc_plot.xtickprecision_title);
        uicontrol('Style','text','Parent',gui_mvpc_plot.xtickprecision_title ,...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Precision','HorizontalAlignment','left'); %
        xprecisoonName = {'0','1','2','3','4','5','6'};
        gui_mvpc_plot.xticks_precision = uicontrol('Style','popupmenu','Parent',gui_mvpc_plot.xtickprecision_title,'String',xprecisoonName,...
            'callback',@xticksprecison,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Value',1,'Enable','off'); %
        gui_mvpc_plot.xticks_precision.KeyPressFcn = @xyaxis_presskey;
        uicontrol('Style','text','Parent',  gui_mvpc_plot.xtickprecision_title,'String','# decimals',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); %
        set(gui_mvpc_plot.xtickprecision_title,'Sizes',[30 65 60 80]);
        
        
        %%-----time minor ticks--------------------------------------------
        gui_mvpc_plot.xtimeminnortick_title = uiextras.HBox('Parent', gui_mvpc_plot.DataSelBox,'BackgroundColor',ColorBviewer_def);
        gui_mvpc_plot.xtimeminorauto = uicontrol('Style','checkbox','Parent',  gui_mvpc_plot.xtimeminnortick_title ,'Enable','off',...
            'callback',@timeminortickslabel,'String','Minor ticks','FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left','Value',0); %
        gui_mvpc_plot.xtimeminorauto.KeyPressFcn = @xyaxis_presskey;
        gui_mvpc_plot.timeminorticks_custom = uicontrol('Style','edit','Parent',  gui_mvpc_plot.xtimeminnortick_title ,...
            'callback',@timeminorticks_custom,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'String','','Enable','off'); %
        gui_mvpc_plot.timeminorticks_custom.KeyPressFcn = @xyaxis_presskey;
        gui_mvpc_plot.timeminorticks_auto = uicontrol('Style','checkbox','Parent',  gui_mvpc_plot.xtimeminnortick_title,...
            'callback',@timeminortickscustom_auto,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Auto','Value',1, 'Enable','off'); %
        gui_mvpc_plot.timeminorticks_auto.KeyPressFcn = @xyaxis_presskey;
        set(gui_mvpc_plot.xtimeminnortick_title,'Sizes',[90 90 50]);
        
        %%-----time ticks label--------------------------------------------
        gui_mvpc_plot.xtimelabel_title = uiextras.HBox('Parent', gui_mvpc_plot.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent',  gui_mvpc_plot.xtimelabel_title ,'String','Labels',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left'); %
        gui_mvpc_plot.xtimelabel_on = uicontrol('Style','radiobutton','Parent',  gui_mvpc_plot.xtimelabel_title,...
            'callback',@xtimelabelon,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','On','Value',1,'Enable','off'); %
        gui_mvpc_plot.xtimelabel_on.KeyPressFcn = @xyaxis_presskey;
        gui_mvpc_plot.xtimelabel_off = uicontrol('Style','radiobutton','Parent',  gui_mvpc_plot.xtimelabel_title,...
            'callback',@xtimelabeloff,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Off','Value',0,'Enable','off'); %
        gui_mvpc_plot.xtimelabel_off.KeyPressFcn = @xyaxis_presskey;
        uiextras.Empty('Parent',gui_mvpc_plot.xtimelabel_title);
        set(gui_mvpc_plot.xtimelabel_title,'Sizes',[50 50 50 80]);
        
        %%-----font, font size, and text color for time ticks--------------
        fontsizes  = {'4','6','8','10','12','14','16','18','20','24','28','32','36',...
            '40','50','60','70','80','90','100'};
        gui_mvpc_plot.xtimefont_title = uiextras.HBox('Parent', gui_mvpc_plot.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent',  gui_mvpc_plot.xtimefont_title,'String','Font',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left'); %
        fonttype = {'Courier','Geneva','Helvetica','Monaco','Times'};
        gui_mvpc_plot.xtimefont_custom = uicontrol('Style','popupmenu','Parent', gui_mvpc_plot.xtimefont_title ,'String',fonttype,...
            'callback',@xtimefont,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off','Value',1); %
        gui_mvpc_plot.xtimefont_custom.KeyPressFcn = @xyaxis_presskey;
        uicontrol('Style','text','Parent', gui_mvpc_plot.xtimefont_title ,'String','Size',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left'); %
        gui_mvpc_plot.font_custom_size = uicontrol('Style','popupmenu','Parent', gui_mvpc_plot.xtimefont_title ,'String',fontsizes,...
            'callback',@xtimefontsize,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off','Value',5); %
        gui_mvpc_plot.font_custom_size.KeyPressFcn = @xyaxis_presskey;
        set(gui_mvpc_plot.xtimefont_title,'Sizes',[30 100 30 80]);
        
        %%%---------------------color for x label text--------------
        gui_mvpc_plot.xtimelabelcolor_title = uiextras.HBox('Parent', gui_mvpc_plot.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent',  gui_mvpc_plot.xtimelabelcolor_title,'String','Color',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left'); %
        textColor = {'Black','Red','Blue','Green','Orange','Cyan','Magenla'};
        gui_mvpc_plot.xtimetextcolor = uicontrol('Style','popupmenu','Parent', gui_mvpc_plot.xtimelabelcolor_title ,'String',textColor,...
            'callback',@xtimecolor,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off','Value',1); %
        gui_mvpc_plot.xtimetextcolor.KeyPressFcn = @xyaxis_presskey;
        uiextras.Empty('Parent',  gui_mvpc_plot.xtimelabelcolor_title);
        set(gui_mvpc_plot.xtimelabelcolor_title,'Sizes',[40 100 -1]);
        
        %%%----Setting for the xunits display--------------------------
        gui_mvpc_plot.xtimeunits_title = uiextras.HBox('Parent', gui_mvpc_plot.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent',  gui_mvpc_plot.xtimeunits_title ,'String','Units',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left'); %
        gui_mvpc_plot.xtimeunits_on = uicontrol('Style','radiobutton','Parent',  gui_mvpc_plot.xtimeunits_title,...
            'callback',@xtimeunitson,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','On','Value',1,'Enable','off'); %
        gui_mvpc_plot.xtimeunits_on.KeyPressFcn = @xyaxis_presskey;
        gui_mvpc_plot.xtimeunits_off = uicontrol('Style','radiobutton','Parent',  gui_mvpc_plot.xtimeunits_title,...
            'callback',@xtimeunitsoff,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Off','Value',0,'Enable','off'); %
        gui_mvpc_plot.xtimeunits_off.KeyPressFcn = @xyaxis_presskey;
        uiextras.Empty('Parent',  gui_mvpc_plot.xtimeunits_title);
        set(gui_mvpc_plot.xtimeunits_title,'Sizes',[50 50 50 80]);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%Setting for Y axis%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%-----------Y scale---------
        gui_mvpc_plot.yaxis_title = uiextras.HBox('Parent', gui_mvpc_plot.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_mvpc_plot.yaxis_title,'String','Y Axis:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','center','FontWeight','bold'); %
        gui_mvpc_plot.yrange_title = uiextras.HBox('Parent', gui_mvpc_plot.DataSelBox,'BackgroundColor',ColorBviewer_def);
        gui_mvpc_plot.yrange_label = uicontrol('Style','text','Parent', gui_mvpc_plot.yrange_title,...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Y Scale','Max',10,'HorizontalAlignment','left'); %
        gui_mvpc_plot.yrange_edit = uicontrol('Style','edit','Parent', gui_mvpc_plot.yrange_title,'String','',...
            'callback',@yrangecustom,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off'); %
        gui_mvpc_plot.yrange_edit.KeyPressFcn = @xyaxis_presskey;
        gui_mvpc_plot.yrangeauto = uicontrol('Style','checkbox','Parent', gui_mvpc_plot.yrange_title,'String','Auto',...
            'callback',@yrangeauto,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',1,'Enable','off'); %
        gui_mvpc_plot.yrangeauto.KeyPressFcn = @xyaxis_presskey;
        set(gui_mvpc_plot.yrange_title ,'Sizes',[60 120 60]);
        
        %%--------Y ticks--------------------------------------------------
        gui_mvpc_plot.ytick_title = uiextras.HBox('Parent', gui_mvpc_plot.DataSelBox,'BackgroundColor',ColorBviewer_def);
        gui_mvpc_plot.yticks_label = uicontrol('Style','text','Parent',gui_mvpc_plot.ytick_title ,...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Y Ticks','HorizontalAlignment','left'); %
        gui_mvpc_plot.yticks_edit = uicontrol('Style','edit','Parent',gui_mvpc_plot.ytick_title,'String','',...
            'callback',@ytickscustom,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off'); %
        gui_mvpc_plot.yticks_edit.KeyPressFcn = @xyaxis_presskey;
        gui_mvpc_plot.ytickauto = uicontrol('Style','checkbox','Parent',  gui_mvpc_plot.ytick_title ,'String','Auto',...
            'callback',@ytickauto,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',1,'Enable','off'); %
        gui_mvpc_plot.ytickauto.KeyPressFcn = @xyaxis_presskey;
        set(gui_mvpc_plot.ytick_title,'Sizes',[60 120 60]);
        
        %%--------Y tick precision with decimals---------------------------
        gui_mvpc_plot.ytickprecision_title = uiextras.HBox('Parent', gui_mvpc_plot.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uiextras.Empty('Parent',  gui_mvpc_plot.ytickprecision_title);
        uicontrol('Style','text','Parent',gui_mvpc_plot.ytickprecision_title ,...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Precision','HorizontalAlignment','left'); %
        yprecisoonName = {'0','1','2','3','4','5','6'};
        gui_mvpc_plot.yticks_precision = uicontrol('Style','popupmenu','Parent',gui_mvpc_plot.ytickprecision_title,'String',yprecisoonName,...
            'callback',@yticksprecison,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Value',1,'Enable','off'); %
        gui_mvpc_plot.yticks_precision.KeyPressFcn = @xyaxis_presskey;
        uicontrol('Style','text','Parent',  gui_mvpc_plot.ytickprecision_title,'String','# decimals',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); %
        set(gui_mvpc_plot.ytickprecision_title,'Sizes',[30 65 60 80]);
        
        %%-----y minor ticks-----------------------------------------------
        gui_mvpc_plot.yminnortick_title = uiextras.HBox('Parent', gui_mvpc_plot.DataSelBox,'BackgroundColor',ColorBviewer_def);
        gui_mvpc_plot.yminortick = uicontrol('Style','checkbox','Parent',  gui_mvpc_plot.yminnortick_title ,'String','Minor Ticks',...
            'callback',@yminordisp,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left','Value',0,'Enable','off'); %
        gui_mvpc_plot.yminortick.KeyPressFcn = @xyaxis_presskey;
        gui_mvpc_plot.yminorstepedit = uicontrol('Style','edit','Parent',gui_mvpc_plot.yminnortick_title ,...
            'callback',@yminorstepedit,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'String','','Enable','off','Enable','off'); %
        gui_mvpc_plot.yminorstepedit.KeyPressFcn = @xyaxis_presskey;
        gui_mvpc_plot.yminorstep_auto = uicontrol('Style','checkbox','Parent',  gui_mvpc_plot.yminnortick_title,...
            'callback',@yminorstepauto,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Auto','Value',1,'Enable','off'); %
        gui_mvpc_plot.yminorstep_auto.KeyPressFcn = @xyaxis_presskey;
        set(gui_mvpc_plot.yminnortick_title,'Sizes',[90 90 50]);
        
        %%-----y ticks label-----------------------------------------------
        
        gui_mvpc_plot.ylabel_title = uiextras.HBox('Parent', gui_mvpc_plot.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_mvpc_plot.ylabel_title,'String','Labels',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left'); %
        gui_mvpc_plot.ylabel_on = uicontrol('Style','radiobutton','Parent',  gui_mvpc_plot.ylabel_title,...
            'callback',@ylabelon,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','On','Value',1,'Enable','off'); %
        gui_mvpc_plot.ylabel_on.KeyPressFcn = @xyaxis_presskey;
        gui_mvpc_plot.ylabel_off = uicontrol('Style','radiobutton','Parent',  gui_mvpc_plot.ylabel_title,...
            'callback',@ylabeloff,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Off','Value',0,'Enable','off'); %
        gui_mvpc_plot.ylabel_off.KeyPressFcn = @xyaxis_presskey;
        uiextras.Empty('Parent',  gui_mvpc_plot.ylabel_title);
        set(gui_mvpc_plot.ylabel_title,'Sizes',[50 50 50 80]);
        
        %%-----y ticklabel:font, font size, and text color for time ticks
        gui_mvpc_plot.yfont_title = uiextras.HBox('Parent', gui_mvpc_plot.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent',  gui_mvpc_plot.yfont_title,'String','Font',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); %
        fonttype = {'Courier','Geneva','Helvetica','Monaco','Times'};
        gui_mvpc_plot.yfont_custom = uicontrol('Style','popupmenu','Parent', gui_mvpc_plot.yfont_title,'String',fonttype,...
            'callback',@yaxisfont, 'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off','Value',1); %
        gui_mvpc_plot.yfont_custom.KeyPressFcn = @xyaxis_presskey;
        uicontrol('Style','text','Parent', gui_mvpc_plot.yfont_title ,'String','Size',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); %
        yfontsize={'4','6','8','10','12','14','16','18','20','24','28','32','36',...
            '40','50','60','70','80','90','100'};
        gui_mvpc_plot.yfont_custom_size = uicontrol('Style','popupmenu','Parent', gui_mvpc_plot.yfont_title ,'String',yfontsize,...
            'callback',@yaxisfontsize,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off','Value',5); %
        gui_mvpc_plot.yfont_custom_size.KeyPressFcn = @xyaxis_presskey;
        set(gui_mvpc_plot.yfont_title,'Sizes',[30 100 30 80]);
        
        %%% color for y ticklabel text
        gui_mvpc_plot.ylabelcolor_title = uiextras.HBox('Parent', gui_mvpc_plot.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent',  gui_mvpc_plot.ylabelcolor_title,'String','Color',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left'); %
        ytextColor = {'Black','Red','Blue','Green','Orange','Cyan','Magenla'};
        gui_mvpc_plot.ytextcolor = uicontrol('Style','popupmenu','Parent', gui_mvpc_plot.ylabelcolor_title ,'String',ytextColor,...
            'callback',@yaxisfontcolor,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off','Value',1); %
        gui_mvpc_plot.ytextcolor.KeyPressFcn = @xyaxis_presskey;
        uiextras.Empty('Parent',  gui_mvpc_plot.ylabelcolor_title);
        set(gui_mvpc_plot.ylabelcolor_title,'Sizes',[40 100 -1]);
        
        %%%-----------Setting for the units display of y axis---------------
        gui_mvpc_plot.yunits_title = uiextras.HBox('Parent', gui_mvpc_plot.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent',  gui_mvpc_plot.yunits_title ,'String','Units',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left'); %
        gui_mvpc_plot.yunits_on = uicontrol('Style','radiobutton','Parent',  gui_mvpc_plot.yunits_title,...
            'callback',@yunitson,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','On','Value',1,'Enable','off'); %
        gui_mvpc_plot.yunits_on.KeyPressFcn = @xyaxis_presskey;
        gui_mvpc_plot.yunits_off = uicontrol('Style','radiobutton','Parent',  gui_mvpc_plot.yunits_title,...
            'callback',@yunitsoff,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Off','Value',0,'Enable','off'); %
        gui_mvpc_plot.yunits_off.KeyPressFcn = @xyaxis_presskey;
        uiextras.Empty('Parent',  gui_mvpc_plot.yunits_title);
        set(gui_mvpc_plot.yunits_title,'Sizes',[50 50 50 -1]);
        
        %%Apply and save the changed parameters
        gui_mvpc_plot.help_run_title = uiextras.HBox('Parent', gui_mvpc_plot.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uiextras.Empty('Parent',gui_mvpc_plot.help_run_title);
        gui_mvpc_plot.cancel = uicontrol('Style','pushbutton','Parent', gui_mvpc_plot.help_run_title ,'String','Cancel',...
            'callback',@xyaxis_help,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off'); %,'FontWeight','bold','HorizontalAlignment','left'
        uiextras.Empty('Parent',gui_mvpc_plot.help_run_title );
        gui_mvpc_plot.apply = uicontrol('Style','pushbutton','Parent',gui_mvpc_plot.help_run_title ,'String','Apply',...
            'callback',@xyaxis_apply,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off'); %,'HorizontalAlignment','left'
        uiextras.Empty('Parent',gui_mvpc_plot.help_run_title );
        set(gui_mvpc_plot.help_run_title,'Sizes',[40 -1 20 -1 30]);
        %%save the parameters
    end

%%*********************************************************************************************************************************%%
%%----------------------------------------------Sub function-----------------------------------------------------------------------%%
%%*********************************************************************************************************************************%%

%%-------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%X axis%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%-------------------------------------------------------------------------

%%----------------------dispaly xtick labels with milliseocnd--------------
    function xmilsecond(~,~)
        %%check if the changed parameters was saved for the other panels
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        xSecondflag = estudioworkingmemory('MyViewer_xaxis_second');
        xmSecondflag =  estudioworkingmemory('MyViewer_xaxis_msecond');
        xtick_precision = gui_mvpc_plot.xticks_precision.Value;
        
        if xSecondflag==0 && xmSecondflag==1
            gui_mvpc_plot.xmillisecond.Value =1; %display with millisecond
            gui_mvpc_plot.xsecond.Value =0;
            return;
        else
            xprecisoonName = {'0','1','2','3','4','5','6'};
            if xtick_precision< 0 || xtick_precision>6
                xtick_precision =0;
            end
            gui_mvpc_plot.xticks_precision.String = xprecisoonName;
            gui_mvpc_plot.xticks_precision.Value =xtick_precision+1;
            
            estudioworkingmemory('MyViewer_xyaxis',1);
            
            track_changes_title_color();
            
            gui_mvpc_plot.xmillisecond.Value =1; %display with millisecond
            gui_mvpc_plot.xsecond.Value =0;%display with second
            
            if xSecondflag==1 && xmSecondflag==0
                %%transform the data with millisecond into second.
                timeArray = str2num(char(gui_mvpc_plot.timerange_edit.String));
                gui_mvpc_plot.timerange_edit.String = num2str(timeArray*1000);
            else
                try
                    if gui_mvpc_plot.ERPwaviewer.plot_org.Pages==3
                        ERPArray = gui_mvpc_plot.ERPwaviewer.SelectERPIdx;
                        ERPselectedIndex = gui_mvpc_plot.ERPwaviewer.PageIndex;
                        if ERPselectedIndex> length(ERPArray)
                            ERPselectedIndex= length(ERPArray);
                        end
                        ALLERPin = gui_mvpc_plot.ERPwaviewer.ALLERP;
                        try
                            TimesCurrent = ALLERPin(ERPArray(ERPselectedIndex)).times;
                        catch
                            TimesCurrent = ALLERPin(end).times;
                        end
                        timeArray(1) = TimesCurrent(1);
                        timeArray(2) = TimesCurrent(end);
                    else
                        timeArray(1) = ERPwaviewer.ERP.times(1);
                        timeArray(2) = ERPwaviewer.ERP.times(end);
                    end
                catch
                    timeArray = [];
                end
                gui_mvpc_plot.timerange_edit.String = num2str(timeArray);
            end
            %%change xtick labels based on the modified  x range
            xtick_precision = gui_mvpc_plot.xticks_precision.Value-1;
            if xtick_precision<0
                xtick_precision =0;
            end
            timeArray = str2num(gui_mvpc_plot.timerange_edit.String);% in millisecond
            timeticks = str2num(gui_mvpc_plot.timeticks_edit.String);
            if ~isempty(timeticks)
                timeticks = timeticks*1000;
                timeticks= f_decimal(char(num2str(timeticks)),xtick_precision);
                gui_mvpc_plot.timeticks_edit.String = timeticks;
            else
                if ~isempty(timeArray) && numel(timeArray)==2 %%&& gui_mvpc_plot.xtimetickauto.Value ==1
                    [timeticks stepX]= default_time_ticks_studio(observe_DECODE.MVPC, timeArray);
                    if xtick_precision<0
                        xtick_precision=0;
                        gui_mvpc_plot.xticks_precision.Value=1;
                    end
                    timeticks= f_decimal(char(timeticks),xtick_precision);
                    gui_mvpc_plot.timeticks_edit.String = timeticks;
                end
            end
            %%change minor xtick labels based on the modified  x range
            xticks = str2num(char(gui_mvpc_plot.timeticks_edit.String));%in millisecond
            stepX = str2num(gui_mvpc_plot.timeminorticks_custom.String);
            if ~isempty(stepX)
                stepX = stepX.*1000;
                %                 stepX= f_decimal(char(num2str(stepX)),xtick_precision);
                gui_mvpc_plot.timeminorticks_custom.String =num2str(stepX);
            else
                stepX = [];
                if ~isempty(xticks) && numel(xticks)>1
                    timeArray = str2num(char(gui_mvpc_plot.timerange_edit.String));
                    xticksStr = str2num(char(gui_mvpc_plot.timeticks_edit.String));
                    stepX = [];
                    if ~isempty(xticksStr) && numel(xticksStr)>1 && numel(timeArray) ==2 && (timeArray(1)< timeArray(2))
                        if numel(xticksStr)>=2
                            for Numofxticks = 1:numel(xticksStr)-1
                                stepX(1,Numofxticks) = xticksStr(Numofxticks)+(xticksStr(Numofxticks+1)-xticksStr(Numofxticks))/2;
                            end
                            %%adjust the left edge
                            stexleft =  (xticksStr(2)-xticksStr(1))/2;
                            for ii = 1:1000
                                if  (xticksStr(1)- stexleft*ii)>=timeArray(1)
                                    stepX   = [(xticksStr(1)- stexleft*ii),stepX];
                                else
                                    break;
                                end
                            end
                            %%adjust the right edge
                            stexright =  (xticksStr(end)-xticksStr(end-1))/2;
                            for ii = 1:1000
                                if  (xticksStr(end)+ stexright*ii)<=timeArray(end)
                                    stepX   = [stepX,(xticksStr(end)+ stexright*ii)];
                                else
                                    break;
                                end
                            end
                        end
                    end
                end
                if gui_mvpc_plot.xtimeminorauto.Value==1 && gui_mvpc_plot.timeminorticks_auto.Value==1
                    gui_mvpc_plot.timeminorticks_custom.String = num2str(stepX);
                end
            end
            estudioworkingmemory('MyViewer_xaxis_second',0);
            estudioworkingmemory('MyViewer_xaxis_msecond',1);
        end
    end

%%----------------------display wave with second---------------------------
    function xsecond(Source,~)
        %%check if the changed parameters was saved for the other panels
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        xSecondflag = estudioworkingmemory('MyViewer_xaxis_second');
        xmSecondflag =  estudioworkingmemory('MyViewer_xaxis_msecond');
        xtick_precision = gui_mvpc_plot.xticks_precision.Value-1;
        if xSecondflag==1 && xmSecondflag==0
            gui_mvpc_plot.xmillisecond.Value =0; %display with millisecond
            gui_mvpc_plot.xsecond.Value =1;
            return;
        else
            xprecisoonName = {'1','2','3','4','5','6'};
            gui_mvpc_plot.xticks_precision.String = xprecisoonName;
            if xtick_precision<=0
                xtick_precision=1;
            end
            gui_mvpc_plot.xticks_precision.Value=xtick_precision;
            estudioworkingmemory('MyViewer_xyaxis',1);
            track_changes_title_color();%%change title color and background color for "cancel" and "apply"
            gui_mvpc_plot.xmillisecond.Value =0; %display with millisecond
            gui_mvpc_plot.xsecond.Value =1;%display with second
            
            if xSecondflag==0 && xmSecondflag==1
                %%transform the data with millisecond into second.
                timeArray = str2num(char(gui_mvpc_plot.timerange_edit.String));
                gui_mvpc_plot.timerange_edit.String = num2str(timeArray/1000);
            else
                try
                    if gui_mvpc_plot.ERPwaviewer.plot_org.Pages==3
                        ERPArray = gui_mvpc_plot.ERPwaviewer.SelectERPIdx;
                        ERPselectedIndex = gui_mvpc_plot.ERPwaviewer.PageIndex;
                        if ERPselectedIndex> length(ERPArray)
                            ERPselectedIndex= length(ERPArray);
                        end
                        ALLERPin = gui_mvpc_plot.ERPwaviewer.ALLERP;
                        try
                            TimesCurrent = ALLERPin(ERPArray(ERPselectedIndex)).times;
                        catch
                            TimesCurrent = ALLERPin(end).times;
                        end
                        timeArray(1) = TimesCurrent(1)/1000;
                        timeArray(2) = TimesCurrent(end)/1000;
                    else
                        timeArray(1) = ERPwaviewer.ERP.times(1)/1000;
                        timeArray(2) = ERPwaviewer.ERP.times(end)/1000;
                    end
                catch
                    timeArray = [];
                end
                gui_mvpc_plot.timerange_edit.String = num2str(timeArray);
            end
            %%change xtick labels based on the modified  x range
            xtick_precision = gui_mvpc_plot.xticks_precision.Value;
            timeArray = str2num(gui_mvpc_plot.timerange_edit.String);%% in seocnd
            timeticks = str2num(char(gui_mvpc_plot.timeticks_edit.String));
            if ~isempty(timeticks)
                timeticks  = timeticks/1000;%% in second
                timeticks= f_decimal(num2str(timeticks),xtick_precision);
                gui_mvpc_plot.timeticks_edit.String = timeticks;%in second
            else
                if ~isempty(timeArray) && numel(timeArray)==2 %&& gui_mvpc_plot.xtimetickauto.Value ==1
                    [timeticks stepX]= default_time_ticks_studio(observe_DECODE.MVPC, timeArray*1000);%% in millisecond
                    
                    timeticks  = num2str(str2num(char(timeticks))/1000);%% in second
                    timeticks= f_decimal(timeticks,xtick_precision);
                    gui_mvpc_plot.timeticks_edit.String = timeticks;%in second
                end
            end
            
            %%change minor xtick labels based on the modified  x range
            xticks = str2num(char(gui_mvpc_plot.timeticks_edit.String));%%in second
            stepX = str2num(gui_mvpc_plot.timeminorticks_custom.String);
            
            if ~isempty(stepX)
                stepX = stepX/1000;
                %                 stepX= f_decimal(char(num2str(stepX)),xtick_precision);
                gui_mvpc_plot.timeminorticks_custom.String =num2str(stepX);
            else
                stepX = [];
                if ~isempty(xticks) && numel(xticks)>1
                    timeArray = str2num(char(gui_mvpc_plot.timerange_edit.String));%% in second
                    xticksStr = str2num(char(gui_mvpc_plot.timeticks_edit.String));
                    stepX = [];
                    if ~isempty(xticksStr) && numel(xticksStr)>1 && numel(timeArray) ==2 && (timeArray(1)< timeArray(2))
                        if numel(xticksStr)>=2
                            for Numofxticks = 1:numel(xticksStr)-1
                                stepX(1,Numofxticks) = xticksStr(Numofxticks)+(xticksStr(Numofxticks+1)-xticksStr(Numofxticks))/2;
                            end
                            %%adjust the left edge
                            stexleft =  (xticksStr(2)-xticksStr(1))/2;
                            for ii = 1:1000
                                if  (xticksStr(1)- stexleft*ii)>=timeArray(1)
                                    stepX   = [(xticksStr(1)- stexleft*ii),stepX];
                                else
                                    break;
                                end
                            end
                            %%adjust the right edge
                            stexright =  (xticksStr(end)-xticksStr(end-1))/2;
                            for ii = 1:1000
                                if  (xticksStr(end)+ stexright*ii)<=timeArray(end)
                                    stepX   = [stepX,(xticksStr(end)+ stexright*ii)];
                                else
                                    break;
                                end
                            end
                        end
                    end
                end
                if gui_mvpc_plot.xtimeminorauto.Value==1 && gui_mvpc_plot.timeminorticks_auto.Value==1
                    gui_mvpc_plot.timeminorticks_custom.String = num2str(stepX);
                end
            end
            
            estudioworkingmemory('MyViewer_xaxis_second',1);
            estudioworkingmemory('MyViewer_xaxis_msecond',0);
        end
    end


%%-------------------------time range auto---------------------------------
    function xtimerangeauto(strx_auto,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
        Value = strx_auto.Value;
        xdisSecondValue = gui_mvpc_plot.xmillisecond.Value;
        if Value==1
            gui_mvpc_plot.timerange_edit.Enable = 'off';
            try
                if gui_mvpc_plot.ERPwaviewer.plot_org.Pages==3
                    ERPArray = gui_mvpc_plot.ERPwaviewer.SelectERPIdx;
                    ERPselectedIndex = gui_mvpc_plot.ERPwaviewer.PageIndex;
                    if ERPselectedIndex> length(ERPArray)
                        ERPselectedIndex= length(ERPArray);
                    end
                    ALLERPin = gui_mvpc_plot.ERPwaviewer.ALLERP;
                    try
                        TimesCurrent = ALLERPin(ERPArray(ERPselectedIndex)).times;
                    catch
                        TimesCurrent = ALLERPin(end).times;
                    end
                    timeArray(1) = TimesCurrent(1);
                    timeArray(2) = TimesCurrent(end);
                else
                    timeArray(1) = observe_DECODE.MVPC.times(1);
                    timeArray(2) = observe_DECODE.MVPC.times(end);
                end
            catch
                timeArray = [];
            end
            if xdisSecondValue ==0%% in second
                timeArray = timeArray/1000;
            end
            gui_mvpc_plot.timerange_edit.String = num2str(timeArray);
            if numel(timeArray)==2 && gui_mvpc_plot.xtimetickauto.Value ==1
                if xdisSecondValue ==0%% in second
                    [timeticks stepX]= default_time_ticks_studio(observe_DECODE.MVPC, timeArray*1000);%% in millisecond
                    timeticks = num2str(str2num(char(timeticks))/1000);
                else
                    [timeticks stepX]= default_time_ticks_studio(observe_DECODE.MVPC, timeArray);%% in millisecond
                end
                xtick_precision = gui_mvpc_plot.xticks_precision.Value-1;
                timeticks= f_decimal(char(timeticks),xtick_precision);
                gui_mvpc_plot.timeticks_edit.String = char(timeticks);
            end
        else
            gui_mvpc_plot.timerange_edit.Enable = 'on';
        end
    end

%%-------------------------Custom setting for time range-------------------
    function timerangecustom(Strtimcustom,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
        xdisSecondValue = gui_mvpc_plot.xmillisecond.Value;
        
        
        timeArray(1) = observe_DECODE.MVPC.times(1);
        timeArray(2) = observe_DECODE.MVPC.times(end);
        
        timcustom = str2num(Strtimcustom.String);
        %%checking the inputs
        if xdisSecondValue==0
            timeArray = timeArray/1000;
        end
        if isempty(timcustom) || numel(timcustom)~=2
            messgStr =  strcat('Time range in "Plotting MVPCsets" - Inputs must be two numbers!');
            estudioworkingmemory('ERPViewer_proces_messg',messgStr);
            Strtimcustom.String = num2str(timeArray);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        if timcustom(1) >= timcustom(2)
            messgStr =  strcat('Time range in "Plotting MVPCsets" - The left edge should be smaller than the right one');
            estudioworkingmemory('ERPViewer_proces_messg',messgStr);
            Strtimcustom.String = num2str(timeArray);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        if numel(timcustom)==2 && gui_mvpc_plot.xtimetickauto.Value ==1
            if xdisSecondValue ==0%% in second
                [timeticks stepX]= default_time_ticks_studio(observe_DECODE.MVPC, timcustom*1000);%% in millisecond
                timeticks = num2str(str2num(char(timeticks))/1000);
            else
                [timeticks stepX]= default_time_ticks_studio(observe_DECODE.MVPC, timcustom);%% in millisecond
            end
            if gui_mvpc_plot.xmillisecond.Value==1
                xtick_precision = gui_mvpc_plot.xticks_precision.Value-1;
            else
                xtick_precision = gui_mvpc_plot.xticks_precision.Value;
            end
            timeticks= f_decimal(char(timeticks),xtick_precision);
            gui_mvpc_plot.timeticks_edit.String = char(timeticks);
        end
        
    end

%%----------------------x ticks custom-------------------------------------
    function timetickscustom(Str,~)
        
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
        xdisSecondValue = gui_mvpc_plot.xmillisecond.Value;
        timeArray =  str2num(gui_mvpc_plot.timerange_edit.String);
        timeticksdef = '';
        if ~isempty(timeArray)
            if xdisSecondValue ==0%% in second
                [timeticks stepX]= default_time_ticks_studio(observe_DECODE.MVPC, timeArray*1000);%% in millisecond
                timeticksdef = num2str(str2num(char(timeticks))/1000);
            else
                [timeticksdef stepX]= default_time_ticks_studio(observe_DECODE.MVPC, timeArray);%% in millisecond
            end
            if gui_mvpc_plot.xmillisecond.Value==1
                xtick_precision = gui_mvpc_plot.xticks_precision.Value-1;
            else
                xtick_precision = gui_mvpc_plot.xticks_precision.Value;
            end
            timeticksdef= f_decimal(char(timeticksdef),xtick_precision);
        end
        
        timtickcustom = str2num(char(Str.String));
        %%checking the inputs
        if isempty(timtickcustom)
            messgStr =  strcat('Time ticks in "Plotting MVPCsets" - We used the default values because input are not numeric values');
            estudioworkingmemory('ERPViewer_proces_messg',messgStr);
            viewer_ERPDAT.Process_messg =4;
            Str.String = timeticksdef;
            return;
        end
        
    end

%%-------------------------Setting for  xticks auto------------------------
    function xtimetickauto(Str,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
        
        Value = Str.Value;
        if Value ==1
            gui_mvpc_plot.timeticks_edit.Enable = 'off';
            gui_mvpc_plot.xtimetickauto.Value =1;
            
            xdisSecondValue = gui_mvpc_plot.xmillisecond.Value;
            timeArray =  str2num(gui_mvpc_plot.timerange_edit.String);
            if ~isempty(timeArray) && gui_mvpc_plot.xtimetickauto.Value ==1%%
                if xdisSecondValue ==0%% in second
                    [timeticks stepX]= default_time_ticks_studio(observe_DECODE.MVPC, timeArray*1000);%% in millisecond
                    timeticks = num2str(str2num(char(timeticks))/1000);
                else
                    [timeticks stepX]= default_time_ticks_studio(observe_DECODE.MVPC, timeArray);%% in millisecond
                end
                if xdisSecondValue==0
                    xtick_precision = gui_mvpc_plot.xticks_precision.Value;
                else
                    xtick_precision = gui_mvpc_plot.xticks_precision.Value-1;
                end
                timeticks= f_decimal(char(timeticks),xtick_precision);
                gui_mvpc_plot.timeticks_edit.String = timeticks;
            end
        else
            gui_mvpc_plot.timeticks_edit.Enable = 'on';
            gui_mvpc_plot.xtimetickauto.Value = 0;
        end
    end

%%--------------------change decimals of x tick labels---------------------
    function xticksprecison(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
        
        if gui_mvpc_plot.xmillisecond.Value==1
            xtick_precision = Source.Value-1;
            if xtick_precision<0
                xtick_precision=0;
                Source.Value=1;
            end
        else
            xtick_precision = Source.Value;
            if xtick_precision<=0
                xtick_precision=1;
                Source.Value=1;
            end
        end
        
        timeticks = str2num(char(gui_mvpc_plot.timeticks_edit.String));
        if ~isempty(timeticks)
            timeticks= f_decimal(char(num2str(timeticks)),xtick_precision);
            gui_mvpc_plot.timeticks_edit.String = timeticks;
        end
    end

%%---------------------display xtick minor or not--------------------------
    function timeminortickslabel(Str,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
        
        Value = Str.Value;
        if Value ==1
            gui_mvpc_plot.timeminorticks_auto.Enable = 'on';
            if gui_mvpc_plot.timeminorticks_auto.Value ==1
                gui_mvpc_plot.timeminorticks_custom.Enable = 'off';
            else
                gui_mvpc_plot.timeminorticks_custom.Enable = 'on';
            end
        else
            gui_mvpc_plot.timeminorticks_auto.Enable = 'off';
            gui_mvpc_plot.timeminorticks_custom.Enable = 'off';
        end
        
        Value = Str.Value;
        xticks = str2num(char(gui_mvpc_plot.timeticks_edit.String));
        stepX = [];
        if ~isempty(xticks) && numel(xticks)>1
            timeArray = str2num(char(gui_mvpc_plot.timerange_edit.String));
            xticksStr = str2num(char(gui_mvpc_plot.timeticks_edit.String));
            stepX = [];
            if ~isempty(xticksStr) && numel(xticksStr)>1 && numel(timeArray) ==2 && (timeArray(1)< timeArray(2))
                if numel(xticksStr)>=2
                    for Numofxticks = 1:numel(xticksStr)-1
                        stepX(1,Numofxticks) = xticksStr(Numofxticks)+(xticksStr(Numofxticks+1)-xticksStr(Numofxticks))/2;
                    end
                    %%adjust the left edge
                    stexleft =  (xticksStr(2)-xticksStr(1))/2;
                    for ii = 1:1000
                        if  (xticksStr(1)- stexleft*ii)>=timeArray(1)
                            stepX   = [(xticksStr(1)- stexleft*ii),stepX];
                        else
                            break;
                        end
                    end
                    %%adjust the right edge
                    stexright =  (xticksStr(end)-xticksStr(end-1))/2;
                    for ii = 1:1000
                        if  (xticksStr(end)+ stexright*ii)<=timeArray(end)
                            stepX   = [stepX,(xticksStr(end)+ stexright*ii)];
                        else
                            break;
                        end
                    end
                end
            end
        end
        if Value==1 && gui_mvpc_plot.timeminorticks_auto.Value==1
            gui_mvpc_plot.timeminorticks_custom.String = num2str(stepX);
        end
    end

%%--------------------------custom step for minor xtick--------------------
    function timeminorticks_custom(Str,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
        
        Str_xtick_minor = str2num(Str.String);
        if isempty(Str_xtick_minor)
            messgStr =  strcat('Minor ticks for "X Axs" in "Plotting MVPCsets" - Input must be numeric');
            estudioworkingmemory('ERPViewer_proces_messg',messgStr);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        
    end

%%--------------------------step for xtick automaticlly--------------------
    function timeminortickscustom_auto(Str,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
        
        Value = Str.Value;
        xticks = str2num(char(gui_mvpc_plot.timeticks_edit.String));
        stepX = [];
        if ~isempty(xticks) && numel(xticks)>1
            timeArray = str2num(char(gui_mvpc_plot.timerange_edit.String));
            xticksStr = xticks;
            stepX = [];
            if ~isempty(xticksStr) && numel(xticksStr)>1 && numel(timeArray) ==2 && (timeArray(1)< timeArray(2))
                if numel(xticksStr)>=2
                    for Numofxticks = 1:numel(xticksStr)-1
                        stepX(1,Numofxticks) = xticksStr(Numofxticks)+(xticksStr(Numofxticks+1)-xticksStr(Numofxticks))/2;
                    end
                    %%adjust the left edge
                    stexleft =  (xticksStr(2)-xticksStr(1))/2;
                    for ii = 1:1000
                        if  (xticksStr(1)- stexleft*ii)>=timeArray(1)
                            stepX   = [(xticksStr(1)- stexleft*ii),stepX];
                        else
                            break;
                        end
                    end
                    %%adjust the right edge
                    stexright =  (xticksStr(end)-xticksStr(end-1))/2;
                    for ii = 1:1000
                        if  (xticksStr(end)+ stexright*ii)<=timeArray(end)
                            stepX   = [stepX,(xticksStr(end)+ stexright*ii)];
                        else
                            break;
                        end
                    end
                end
            end
        end
        if Value==1
            gui_mvpc_plot.timeminorticks_custom.Enable = 'off';
            gui_mvpc_plot.timeminorticks_custom.String = num2str(stepX);
        else
            gui_mvpc_plot.timeminorticks_custom.Enable = 'on';
        end
    end


%%--------------------Setting for time tick label:on-----------------------
    function xtimelabelon(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
        
        gui_mvpc_plot.xtimelabel_on.Value = 1;
        gui_mvpc_plot.xtimelabel_off.Value = 0;
        gui_mvpc_plot.xtimefont_custom.Enable = 'on';
        gui_mvpc_plot.font_custom_size.Enable = 'on';
        gui_mvpc_plot.xtimetextcolor.Enable = 'on';
    end

%%--------------------Setting for time tick label:on-----------------------
    function xtimelabeloff(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
        
        gui_mvpc_plot.xtimelabel_on.Value = 0;
        gui_mvpc_plot.xtimelabel_off.Value = 1;
        gui_mvpc_plot.xtimefont_custom.Enable = 'off';
        gui_mvpc_plot.font_custom_size.Enable = 'off';
        gui_mvpc_plot.xtimetextcolor.Enable = 'off';
    end

%%----------------------font of x labelticks-------------------------------
    function xtimefont(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_mvpc_plot.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_mvpc_plot.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        gui_mvpc_plot.cancel.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_mvpc_plot.cancel.ForegroundColor = [1 1 1];
    end

%%---------------------fontsize of x labelticks----------------------------
    function xtimefontsize(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
    end
%%---------------------color of x labelticks-------------------------------
    function xtimecolor(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
    end

%%------------------Setting for units:on-----------------------------------
    function xtimeunitson(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
        gui_mvpc_plot.xtimeunits_on.Value = 1;
        gui_mvpc_plot.xtimeunits_off.Value = 0;
    end

%%------------------Setting for units:off----------------------------------
    function xtimeunitsoff(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
        gui_mvpc_plot.xtimeunits_on.Value = 0;
        gui_mvpc_plot.xtimeunits_off.Value = 1;
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Y axis%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%-------------------------Y scale-----------------------------------------
    function yrangecustom(yscalStr,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
        yscalecustom = str2num(char(yscalStr.String));
        %%checking the inputs
        if isempty(yscalecustom)|| numel(yscalecustom)~=2
            messgStr =  strcat('Y scale for "Y Axs" in "Plotting MVPCsets" - Inputs must be two numbers ');
            estudioworkingmemory('ERPViewer_proces_messg',messgStr);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        
        if yscalecustom(1) >= yscalecustom(2)
            messgStr =  strcat('Y scale for "Y Axs" in "Plotting MVPCsets" - The left edge should be smaller than the right one ');
            estudioworkingmemory('ERPViewer_proces_messg',messgStr);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        if ~isempty(yscalecustom) && numel(yscalecustom)==2 && yscalecustom(1) < yscalecustom(2) && gui_mvpc_plot.ytickauto.Value==1
            yticksLabel = default_amp_ticks_viewer(yscalecustom);
            ytick_precision = gui_mvpc_plot.yticks_precision.Value-1;
            if isempty(str2num(yticksLabel))
                yticksLabel = '';
            else
                if ~isempty(str2num(yticksLabel)) && numel((str2num(yticksLabel)))==1
                    yticksnumbel = str2num(yticksLabel);
                    yticksLabel = sprintf(['%.',num2str(ytick_precision),'f'],yticksnumbel(1));
                else
                    yticksnumbel = str2num(yticksLabel);
                    yticksLabel = sprintf(['%.',num2str(ytick_precision),'f'],yticksnumbel(1));
                    for Numofnum = 1:numel(yticksnumbel)-1
                        yticksLabel = [yticksLabel,32,sprintf(['%.',num2str(ytick_precision),'f'],yticksnumbel(Numofnum+1))];
                    end
                end
            end
            gui_mvpc_plot.yticks_edit.String = yticksLabel;
        end
        
    end

%%--------------------Y Scale Auto-----------------------------------------
    function yrangeauto(yscaleauto,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
        Value = yscaleauto.Value;
        if Value ==1
            ALLERPIN = gui_mvpc_plot.ERPwaviewer.ALLERP;
            ERPArrayin = gui_mvpc_plot.ERPwaviewer.SelectERPIdx;
            plotOrg = [1 2 3];
            
            
            ChanArrayIn = [1];
            
            BinArrayIN = [1];
            
            PageCurrent =  gui_mvpc_plot.ERPwaviewer.PageIndex;
            yylim_out = f_erpAutoYLim(ALLERPIN, ERPArrayin,plotOrg,BinArrayIN, ChanArrayIn);
            try
                yRangeLabel = num2str(yylim_out(PageCurrent,:));
            catch
                yRangeLabel = num2str(yylim_out(1,:));
            end
            gui_mvpc_plot.yrange_edit.String =yRangeLabel;
            gui_mvpc_plot.yrange_edit.Enable = 'off';
        else
            gui_mvpc_plot.yrange_edit.Enable = 'on';
        end
        
        yscalecustom = str2num(gui_mvpc_plot.yrange_edit.String);
        if ~isempty(yscalecustom) && numel(yscalecustom)==2 && yscalecustom(1) < yscalecustom(2)
            yticksLabel = default_amp_ticks_viewer(yscalecustom);
            ytick_precision = gui_mvpc_plot.yticks_precision.Value-1;
            if isempty(str2num(yticksLabel))
                yticksLabel = '';
            else
                if ~isempty(str2num(yticksLabel)) && numel((str2num(yticksLabel)))==1
                    yticksnumbel = str2num(yticksLabel);
                    yticksLabel = sprintf(['%.',num2str(ytick_precision),'f'],yticksnumbel(1));
                else
                    yticksnumbel = str2num(yticksLabel);
                    yticksLabel = sprintf(['%.',num2str(ytick_precision),'f'],yticksnumbel(1));
                    for Numofnum = 1:numel(yticksnumbel)-1
                        yticksLabel = [yticksLabel,32,sprintf(['%.',num2str(ytick_precision),'f'],yticksnumbel(Numofnum+1))];
                    end
                end
            end
            gui_mvpc_plot.yticks_edit.String = yticksLabel;
        end
    end

%%----------------------Y ticks--------------------------------------------
    function ytickscustom(Str,~)
        
        yticksLabel = gui_mvpc_plot.ERPwaviewer.yaxis.ticks;
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
        
        ytickcustom = str2num(char(Str.String));
        %%checking the inputs
        if isempty(ytickcustom)
            messgStr =  strcat('Y ticks on "Plotting MVPCsets": Input must be a number!');
            estudioworkingmemory('ERPViewer_proces_messg',messgStr);
            Str.String = '';
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        yRange = str2num(char(gui_mvpc_plot.yrange_edit.String));
        %%checking if the time sticks exceed the time range
        if ~isempty(yRange) && numel(yRange) ==2
            if min(ytickcustom(:))< yRange(1)%% compared with the left edge of time range
                messgStr =  strcat('Y ticks in "Plotting MVPCsets": Minimum of Y ticks should be larger than the left edge of y scale!');
                estudioworkingmemory('ERPViewer_proces_messg',messgStr);
                Str.String = '';
                viewer_ERPDAT.Process_messg =4;
                return;
            end
            if max(ytickcustom(:))>yRange(2)%% compared with the right edge of time range
                messgStr =  strcat('Y ticks in "Plotting MVPCsets": Maximum of Y ticks should be smaller than the right edge of y scale!');
                estudioworkingmemory('ERPViewer_proces_messg',messgStr);
                Str.String = '';
                viewer_ERPDAT.Process_messg =4;
                return;
            end
            yticksLabel = char(Str.String);
            ytick_precision = gui_mvpc_plot.yticks_precision.Value-1;
            if ytick_precision<0
                ytick_precision=1;
            end
            if isempty(str2num(yticksLabel))
                yticksLabel = '';
            else
                if ~isempty(str2num(yticksLabel)) && numel((str2num(yticksLabel)))==1
                    yticksnumbel = str2num(yticksLabel);
                    yticksLabel = sprintf(['%.',num2str(ytick_precision),'f'],yticksnumbel(1));
                else
                    yticksnumbel = str2num(yticksLabel);
                    yticksLabel = sprintf(['%.',num2str(ytick_precision),'f'],yticksnumbel(1));
                    for Numofnum = 1:numel(yticksnumbel)-1
                        yticksLabel = [yticksLabel,32,sprintf(['%.',num2str(ytick_precision),'f'],yticksnumbel(Numofnum+1))];
                    end
                end
            end
            gui_mvpc_plot.yticks_edit.String = yticksLabel;
        end
    end

%%----------------------------Y ticks auto---------------------------------
    function ytickauto(Str,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
        
        Value = Str.Value;
        if Value ==1
            yRangeLabel = str2num(char(gui_mvpc_plot.yrange_edit.String));
            if ~isempty(yRangeLabel) && numel(yRangeLabel) ==2 && (yRangeLabel(1)<yRangeLabel(2))
                yticksLabel = default_amp_ticks_viewer(yRangeLabel);
                ytick_precision = gui_mvpc_plot.yticks_precision.Value-1;
                if ytick_precision<0
                    ytick_precision=1;
                end
                if isempty(str2num(yticksLabel))
                    yticksLabel = '';
                else
                    if ~isempty(str2num(yticksLabel)) && numel((str2num(yticksLabel)))==1
                        yticksnumbel = str2num(yticksLabel);
                        yticksLabel = sprintf(['%.',num2str(ytick_precision),'f'],yticksnumbel(1));
                    else
                        yticksnumbel = str2num(yticksLabel);
                        yticksLabel = sprintf(['%.',num2str(ytick_precision),'f'],yticksnumbel(1));
                        for Numofnum = 1:numel(yticksnumbel)-1
                            yticksLabel = [yticksLabel,32,sprintf(['%.',num2str(ytick_precision),'f'],yticksnumbel(Numofnum+1))];
                        end
                    end
                end
                gui_mvpc_plot.yticks_edit.String = yticksLabel;
                
            end
            gui_mvpc_plot.yticks_edit.Enable = 'off';
        else
            gui_mvpc_plot.yticks_edit.Enable = 'on';
        end
    end


%%--------------------y scale decision-------------------------------------
    function yticksprecison(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
        
        yticksLabel =  gui_mvpc_plot.yticks_edit.String;
        ytick_precision = Source.Value-1;
        if ytick_precision<0
            ytick_precision=1;
            Source.Value = 2;
        end
        if isempty(str2num(yticksLabel))
            yticksLabel = '';
        else
            if ~isempty(str2num(yticksLabel)) && numel((str2num(yticksLabel)))==1
                yticksnumbel = str2num(yticksLabel);
                yticksLabel = sprintf(['%.',num2str(ytick_precision),'f'],yticksnumbel(1));
            else
                yticksnumbel = str2num(yticksLabel);
                yticksLabel = sprintf(['%.',num2str(ytick_precision),'f'],yticksnumbel(1));
                for Numofnum = 1:numel(yticksnumbel)-1
                    yticksLabel = [yticksLabel,32,sprintf(['%.',num2str(ytick_precision),'f'],yticksnumbel(Numofnum+1))];
                end
            end
        end
        gui_mvpc_plot.yticks_edit.String = yticksLabel;
    end

%%--------------------display ytick minor?---------------------------------
    function yminordisp(Str,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
        
        Value = Str.Value;
        if Value ==1
            gui_mvpc_plot.yminorstep_auto.Enable = 'on';
            if gui_mvpc_plot.yminorstep_auto.Value ==1
                gui_mvpc_plot.yminorstepedit.Enable = 'off';
            else
                gui_mvpc_plot.yminorstepedit.Enable = 'on';
            end
            
            if gui_mvpc_plot.yminorstep_auto.Value ==1
                yticksStr = str2num(char(gui_mvpc_plot.yticks_edit.String));
                stepY = [];
                yscaleRange =  str2num(char(gui_mvpc_plot.yrange_edit.String));
                if ~isempty(yticksStr) && numel(yticksStr)>1 && numel(yscaleRange) ==2 && (yscaleRange(1)<yscaleRange(2))
                    if numel(yticksStr)>=2
                        for Numofxticks = 1:numel(yticksStr)-1
                            stepY(1,Numofxticks) = yticksStr(Numofxticks)+(yticksStr(Numofxticks+1)-yticksStr(Numofxticks))/2;
                        end
                        %%adjust the left edge
                        steyleft =  (yticksStr(2)-yticksStr(1))/2;
                        for ii = 1:1000
                            if  (yticksStr(1)- steyleft*ii)>=yticksStr(1)
                                stepY   = [(yticksStr(1)- steyleft*ii),stepY];
                            else
                                break;
                            end
                        end
                        %%adjust the right edge
                        steyright =  (yticksStr(end)-yticksStr(end-1))/2;
                        for ii = 1:1000
                            if  (yticksStr(end)+ steyright*ii)<=yticksStr(end)
                                stepY   = [stepY,(yticksStr(end)+ steyright*ii)];
                            else
                                break;
                            end
                        end
                    end
                end
                gui_mvpc_plot.yminorstepedit.String = num2str(stepY);
            end
        else
            gui_mvpc_plot.yminorstepedit.Enable = 'off';
            gui_mvpc_plot.yminorstep_auto.Enable = 'off';
        end
    end

%%---------------------custom edit the step of minor yticks----------------
    function yminorstepedit(Str,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
        
        ytickmin_step = str2num(Str.String);
        if isempty(ytickmin_step)
            messgStr =  strcat('Minor ticks for "Y Axs" in "Plotting MVPCsets": Input must be one number or more numbers');
            estudioworkingmemory('ERPViewer_proces_messg',messgStr);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
    end

%%-------------------Auto step of minor yticks-----------------------------
    function yminorstepauto(Str,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
        
        Value = Str.Value;%%
        if Value ==1
            yticksStr = str2num(char(gui_mvpc_plot.yticks_edit.String));
            stepY = [];
            yscaleRange =  str2num(char(gui_mvpc_plot.yrange_edit.String));
            if ~isempty(yticksStr) && numel(yticksStr)>1 && numel(yscaleRange) ==2 && (yscaleRange(1)<yscaleRange(2))
                if numel(yticksStr)>=2
                    for Numofxticks = 1:numel(yticksStr)-1
                        stepY(1,Numofxticks) = yticksStr(Numofxticks)+(yticksStr(Numofxticks+1)-yticksStr(Numofxticks))/2;
                    end
                    %%adjust the left edge
                    steyleft =  (yticksStr(2)-yticksStr(1))/2;
                    for ii = 1:1000
                        if  (yticksStr(1)- steyleft*ii)>=yticksStr(1)
                            stepY   = [(yticksStr(1)- steyleft*ii),stepY];
                        else
                            break;
                        end
                    end
                    %%adjust the right edge
                    steyright =  (yticksStr(end)-yticksStr(end-1))/2;
                    for ii = 1:1000
                        if  (yticksStr(end)+ steyright*ii)<=yticksStr(end)
                            stepY   = [stepY,(yticksStr(end)+ steyright*ii)];
                        else
                            break;
                        end
                    end
                end
            end
            gui_mvpc_plot.yminorstepedit.String = num2str(stepY);
            gui_mvpc_plot.yminorstepedit.Enable = 'off';
        else
            gui_mvpc_plot.yminorstepedit.Enable = 'on';
        end
    end

%%------------------------------Y label:on---------------------------------
    function ylabelon(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
        
        gui_mvpc_plot.ylabel_on.Value = 1;
        gui_mvpc_plot.ylabel_off.Value = 0;
        gui_mvpc_plot.yfont_custom.Enable = 'on';
        gui_mvpc_plot.yfont_custom_size.Enable = 'on';
        gui_mvpc_plot.ytextcolor.Enable = 'on';
    end


%%------------------------font of y labelticks-----------------------------
    function yaxisfont(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
    end

%%------------------------fontsize of y label ticks------------------------
    function yaxisfontsize(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
    end

%%------------------------color of y label ticks---------------------------
    function yaxisfontcolor(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
    end


%%------------------------------Y label:off--------------------------------
    function ylabeloff(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
        gui_mvpc_plot.ylabel_on.Value = 0;
        gui_mvpc_plot.ylabel_off.Value = 1;
        gui_mvpc_plot.yfont_custom.Enable = 'off';
        gui_mvpc_plot.yfont_custom_size.Enable = 'off';
        gui_mvpc_plot.ytextcolor.Enable = 'off';
    end

%%---------------------------Y units:on------------------------------------
    function yunitson(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_mvpc_plot.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_mvpc_plot.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        gui_mvpc_plot.cancel.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_mvpc_plot.cancel.ForegroundColor = [1 1 1];
        gui_mvpc_plot.yunits_on.Value = 1;
        gui_mvpc_plot.yunits_off.Value = 0;
    end

%%---------------------------Y units:off-----------------------------------
    function yunitsoff(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        track_changes_title_color();%%change title color and background color for "cancel" and "apply"
        gui_mvpc_plot.yunits_on.Value = 0;
        gui_mvpc_plot.yunits_off.Value = 1;
    end


%%-----------------------help----------------------------------------------
    function xyaxis_help(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        
        MessageViewer= char(strcat('Plotting MVPCsets > Cancel'));
        estudioworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        
        changeFlag =  estudioworkingmemory('MyViewer_xyaxis');
        if changeFlag~=1%% Donot reset this panel if there is no change
            return;
        end
        
        xdispsecondValue =  gui_mvpc_plot.ERPwaviewer.xaxis.tdis;
        if xdispsecondValue==1%% with millisecond
            gui_mvpc_plot.xmillisecond.Value  =1;
            gui_mvpc_plot.xsecond.Value  = 0;
            xprecisoonName = {'0','1','2','3','4','5','6'};
            gui_mvpc_plot.xticks_precision.String = xprecisoonName;
        else%% with second
            gui_mvpc_plot.xmillisecond.Value  =0;
            gui_mvpc_plot.xsecond.Value  = 1;
            xprecisoonName = {'1','2','3','4','5','6'};
            gui_mvpc_plot.xticks_precision.String = xprecisoonName;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%-------------------------time range------------------------------
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if xdispsecondValue==1
            gui_mvpc_plot.timerange_edit.String = num2str(gui_mvpc_plot.ERPwaviewer.xaxis.timerange);
        else
            gui_mvpc_plot.timerange_edit.String = num2str(gui_mvpc_plot.ERPwaviewer.xaxis.timerange/1000);
        end
        TRFlag =  gui_mvpc_plot.ERPwaviewer.xaxis.trangeauto;
        if TRFlag==1
            gui_mvpc_plot.xtimerangeauto.Value = 1 ;
            gui_mvpc_plot.timerange_edit.Enable = 'off';
        else
            gui_mvpc_plot.xtimerangeauto.Value = 0 ;
            gui_mvpc_plot.timerange_edit.Enable = 'on';
        end
        xticks_precision = gui_mvpc_plot.ERPwaviewer.xaxis.tickdecimals;
        %%time ticks
        if xdispsecondValue==1
            timeticks= gui_mvpc_plot.ERPwaviewer.xaxis.timeticks;
            if ~isempty(timeticks)
                timeticks= f_decimal(char(num2str(timeticks)),xticks_precision);
            else
                timeticks = '';
            end
            gui_mvpc_plot.timeticks_edit.String  = timeticks;
            gui_mvpc_plot.xticks_precision.Value = xticks_precision+1;
        else
            timeticks= gui_mvpc_plot.ERPwaviewer.xaxis.timeticks/1000;%%Convert character array or string scalar to numeric array
            if ~isempty(timeticks)
                timeticks= f_decimal(char(num2str(timeticks)),xticks_precision);
            else
                timeticks = '';
            end
            gui_mvpc_plot.timeticks_edit.String  = timeticks;
            gui_mvpc_plot.xticks_precision.Value = xticks_precision;
        end
        xtickAuto = gui_mvpc_plot.ERPwaviewer.xaxis.ticksauto;
        gui_mvpc_plot.xtimetickauto.Value=xtickAuto;
        if xtickAuto==1
            gui_mvpc_plot.timeticks_edit.Enable = 'off';
        else
            gui_mvpc_plot.timeticks_edit.Enable = 'on';
        end
        %%minor for xticks
        XMinorDis = gui_mvpc_plot.ERPwaviewer.xaxis.tminor.disp;
        xMinorAuto = gui_mvpc_plot.ERPwaviewer.xaxis.tminor.auto;
        gui_mvpc_plot.xtimeminorauto.Value = XMinorDis;
        if xMinorAuto==1
            gui_mvpc_plot.timeminorticks_auto.Value =1;
            gui_mvpc_plot.timeminorticks_custom.Enable = 'off';
        else
            gui_mvpc_plot.timeminorticks_auto.Value =0;
            gui_mvpc_plot.timeminorticks_custom.Enable = 'on';
        end
        if XMinorDis==1
            if xMinorAuto==1
                gui_mvpc_plot.timeminorticks_custom.Enable = 'off';
            else
                gui_mvpc_plot.timeminorticks_custom.Enable = 'on';
            end
            gui_mvpc_plot.timeminorticks_auto.Enable = 'on';
        else
            gui_mvpc_plot.timeminorticks_custom.Enable = 'off';
            gui_mvpc_plot.timeminorticks_auto.Enable = 'off';
        end
        xtickMinorstep = gui_mvpc_plot.ERPwaviewer.xaxis.tminor.step;
        if xdispsecondValue==0
            xtickMinorstep= xtickMinorstep/1000;%%Convert character array or string scalar to numeric array
        end
        if ~isempty(xtickMinorstep)
            xtickMinorstep= f_decimal(char(num2str(xtickMinorstep)),xticks_precision);
        else
            xtickMinorstep = '';
        end
        gui_mvpc_plot.timeminorticks_custom.String = xtickMinorstep;
        %%x labels
        xlabelFlag = gui_mvpc_plot.ERPwaviewer.xaxis.label;
        gui_mvpc_plot.xtimelabel_on.Value = xlabelFlag;
        gui_mvpc_plot.xtimelabel_off.Value = ~xlabelFlag;
        gui_mvpc_plot.xtimefont_custom.Value = gui_mvpc_plot.ERPwaviewer.xaxis.font;
        fontsize  = {'4','6','8','10','12','14','16','18','20','24','28','32','36',...
            '40','50','60','70','80','90','100'};
        xfontsizeinum = str2num(char(fontsize));
        xlabelfontsize =  gui_mvpc_plot.ERPwaviewer.xaxis.fontsize;
        [x_label,~] = find(xfontsizeinum==xlabelfontsize);
        if isempty(x_label)
            x_label=5;
        end
        gui_mvpc_plot.font_custom_size.Value = x_label;
        gui_mvpc_plot.xtimetextcolor.Value = gui_mvpc_plot.ERPwaviewer.xaxis.fontcolor;
        if xlabelFlag==1
            xlabelFlagEnable = 'on';
        else
            xlabelFlagEnable = 'off';
        end
        gui_mvpc_plot.xtimefont_custom.Enable = xlabelFlagEnable;
        gui_mvpc_plot.font_custom_size.Enable = xlabelFlagEnable;
        gui_mvpc_plot.xtimetextcolor.Enable = xlabelFlagEnable;
        %%x units
        xaxisunits= gui_mvpc_plot.ERPwaviewer.xaxis.units;
        gui_mvpc_plot.xtimeunits_on.Value =xaxisunits;
        gui_mvpc_plot.xtimeunits_off.Value = ~xaxisunits;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%------------------------setting for y axes-----------------------
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        gui_mvpc_plot.yrange_edit.String = num2str(gui_mvpc_plot.ERPwaviewer.yaxis.scales);
        gui_mvpc_plot.yrangeauto.Value = gui_mvpc_plot.ERPwaviewer.yaxis.scalesauto;
        if gui_mvpc_plot.yrangeauto.Value==1
            gui_mvpc_plot.yrange_edit.Enable = 'off';
        else
            gui_mvpc_plot.yrange_edit.Enable = 'on';
        end
        ytickdecimals = gui_mvpc_plot.ERPwaviewer.yaxis.tickdecimals;
        gui_mvpc_plot.yticks_precision.Value = ytickdecimals+1;
        YTicks=gui_mvpc_plot.ERPwaviewer.yaxis.ticks;
        if ~isempty(YTicks)
            YTicks= f_decimal(char(num2str(YTicks)),ytickdecimals);
        else
            YTicks = '';
        end
        gui_mvpc_plot.yticks_edit.String = YTicks;
        
        gui_mvpc_plot.ytickauto.Value=gui_mvpc_plot.ERPwaviewer.yaxis.tickauto ;
        if gui_mvpc_plot.ytickauto.Value==1
            gui_mvpc_plot.yticks_edit.Enable = 'off';
        else
            gui_mvpc_plot.yticks_edit.Enable = 'on';
        end
        %%minor yticks
        yMinorDisp= gui_mvpc_plot.ERPwaviewer.yaxis.yminor.disp;
        yMinorAuto = gui_mvpc_plot.ERPwaviewer.yaxis.yminor.auto;
        if yMinorDisp==1
            gui_mvpc_plot.yminortick.Value=1;
            gui_mvpc_plot.yminorstep_auto.Enable = 'on';
            if yMinorAuto==1
                gui_mvpc_plot.yminorstepedit.Enable = 'off';
            else
                gui_mvpc_plot.yminorstepedit.Enable = 'on';
            end
        else
            gui_mvpc_plot.yminortick.Value=0;
            gui_mvpc_plot.yminorstep_auto.Enable = 'off';
            gui_mvpc_plot.yminorstepedit.Enable = 'off';
        end
        gui_mvpc_plot.yminorstep_auto.Value = yMinorAuto;
        gui_mvpc_plot.yminorstepedit.String = num2str(gui_mvpc_plot.ERPwaviewer.yaxis.yminor.step);
        
        gui_mvpc_plot.ylabel_on.Value = gui_mvpc_plot.ERPwaviewer.yaxis.label;
        gui_mvpc_plot.ylabel_off.Value = ~gui_mvpc_plot.ERPwaviewer.yaxis.label;
        gui_mvpc_plot.yfont_custom.Value =gui_mvpc_plot.ERPwaviewer.yaxis.font;
        ylabelFontsize =  gui_mvpc_plot.ERPwaviewer.yaxis.fontsize;
        [yx_label,~] = find(xfontsizeinum==ylabelFontsize);
        if isempty(yx_label)
            yx_label=5;
        end
        gui_mvpc_plot.yfont_custom_size.Value = yx_label;
        gui_mvpc_plot.ytextcolor.Value= gui_mvpc_plot.ERPwaviewer.yaxis.fontcolor;
        if gui_mvpc_plot.ylabel_on.Value==1
            ylabelFlagEnable = 'on';
        else
            ylabelFlagEnable = 'off';
        end
        gui_mvpc_plot.yfont_custom.Enable = ylabelFlagEnable;
        gui_mvpc_plot.yfont_custom_size.Enable = ylabelFlagEnable;
        gui_mvpc_plot.ytextcolor.Enable = ylabelFlagEnable;
        
        gui_mvpc_plot.yunits_on.Value = gui_mvpc_plot.ERPwaviewer.yaxis.units;
        gui_mvpc_plot.yunits_off.Value = ~gui_mvpc_plot.ERPwaviewer.yaxis.units;
        gui_mvpc_plot.apply.BackgroundColor =  [1 1 1];
        gui_mvpc_plot.apply.ForegroundColor = [0 0 0];
        box_erpxtaxes_viewer_property.TitleColor= [0.5 0.5 0.9];
        gui_mvpc_plot.cancel.BackgroundColor =  [1 1 1];
        gui_mvpc_plot.cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('MyViewer_xyaxis',0);
        MessageViewer= char(strcat('Plotting MVPCsets > Cancel'));
        estudioworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =2;
    end

%%-----------------------------Apply---------------------------------------
    function xyaxis_apply(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        
        estudioworkingmemory('MyViewer_xyaxis',0);
        gui_mvpc_plot.apply.BackgroundColor =  [1 1 1];
        gui_mvpc_plot.apply.ForegroundColor = [0 0 0];
        box_erpxtaxes_viewer_property.TitleColor= [0.5 0.5 0.9];
        gui_mvpc_plot.cancel.BackgroundColor =  [1 1 1];
        gui_mvpc_plot.cancel.ForegroundColor = [0 0 0];
        
        MessageViewer= char(strcat('Plotting MVPCsets > Apply'));
        estudioworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        
        %%time range
        xdispsecondValue = gui_mvpc_plot.xmillisecond.Value; %display with millisecond
        if xdispsecondValue==1
            timeRange = str2num(gui_mvpc_plot.timerange_edit.String);%get the time range for plotting and check it
        else
            timeRange = str2num(gui_mvpc_plot.timerange_edit.String)*1000;
        end
        gui_mvpc_plot.xaxispars{1} = xdispsecondValue;
        
        if isempty(timeRange) ||  numel(timeRange)~=2
            timeRange(1) = observe_DECODE.MVPC.times(1);
            timeRange(2) = observe_DECODE.MVPC.times(end);
            messgStr =  strcat('The default time range will be used because the inputs are not two numbers');
            estudioworkingmemory('ERPViewer_proces_messg',messgStr);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        if timeRange(1) >= timeRange(2)
            timeRange(1) = observe_DECODE.MVPC.times(1);
            timeRange(2) = observe_DECODE.MVPC.times(end);
            messgStr =  strcat('Plotting MVPCsets > Apply-Time rang: The left edge should not be smaller than the right one!');
            estudioworkingmemory('ERPViewer_proces_messg',messgStr);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        
        gui_mvpc_plot.xaxispars{3} = timeRange;
        gui_mvpc_plot.xaxispars{2} = gui_mvpc_plot.xtimerangeauto.Value;
        %%getting xticks
        if xdispsecondValue==1
            xticksArray = str2num(char(gui_mvpc_plot.timeticks_edit.String));
        else
            xticksArray = str2num(char(gui_mvpc_plot.timeticks_edit.String))*1000;%%transform into millisecond
        end
        count_xtks = 0;
        xticks_exm = [];
        if ~isempty(xticksArray) && numel(timeRange) ==2 %%check if xticks exceed the defined time range
            for Numofxticks = 1:numel(xticksArray)
                if xticksArray(Numofxticks)< timeRange(1) || xticksArray(Numofxticks)> timeRange(2)
                    count_xtks =count_xtks+1;
                    xticks_exm(count_xtks) = Numofxticks;
                end
            end
            xticksArray(xticks_exm) = [];
        end
        
        gui_mvpc_plot.xaxispars{4} =  gui_mvpc_plot.ERPwaviewer.xaxis.ticksauto;
        gui_mvpc_plot.xaxispars{5}  = xticksArray;
        
        gui_mvpc_plot.xaxispars{6} = gui_mvpc_plot.ERPwaviewer.xaxis.tickdecimals;
        %%minor for xticks
        xticckMinorstep = str2num(char(gui_mvpc_plot.timeminorticks_custom.String));
        
        gui_mvpc_plot.xaxispars{7} = gui_mvpc_plot.xtimeminorauto.Value;
        gui_mvpc_plot.xaxispars{8} = gui_mvpc_plot.ERPwaviewer.xaxis.tminor.step;
        gui_mvpc_plot.xaxispars{9} =gui_mvpc_plot.timeminorticks_auto.Value;
        %%xtick label on/off
        gui_mvpc_plot.ERPwaviewer.xaxis.label = gui_mvpc_plot.xtimelabel_on.Value;
        fontsize  = {'4','6','8','10','12','14','16','18','20','24','28','32','36',...
            '40','50','60','70','80','90','100'};
        xfontsizeinum = str2num(char(fontsize));
        gui_mvpc_plot.xaxispars{10}=gui_mvpc_plot.xtimelabel_on.Value;
        gui_mvpc_plot.xaxispars{11} = gui_mvpc_plot.xtimefont_custom.Value;
        gui_mvpc_plot.xaxispars{12} = gui_mvpc_plot.font_custom_size.Value;
        gui_mvpc_plot.xaxispars{13}= gui_mvpc_plot.xtimetextcolor.Value;
        gui_mvpc_plot.xaxispars{14}= gui_mvpc_plot.xtimeunits_on.Value;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%Setting for Y axis%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%y scales
        YScales = str2num(char(gui_mvpc_plot.yrange_edit.String));
        if isempty(YScales) || numel(YScales)~=2
            ALLERPIN = gui_mvpc_plot.ERPwaviewer.ALLERP;
            ERPArrayin = gui_mvpc_plot.ERPwaviewer.SelectERPIdx;
            BinArrayIN = [];
            ChanArrayIn = [];
            plotOrg = [1 2 3];
            try
                plotOrg(1) = gui_mvpc_plot.ERPwaviewer.plot_org.Grid;
                plotOrg(2) = gui_mvpc_plot.ERPwaviewer.plot_org.Overlay;
                plotOrg(3) = gui_mvpc_plot.ERPwaviewer.plot_org.Pages;
            catch
                plotOrg = [1 2 3];
            end
            try
                ChanArrayIn = gui_mvpc_plot.ERPwaviewer.chan;
            catch
                ChanArrayIn = [];
            end
            try
                BinArrayIN = gui_mvpc_plot.ERPwaviewer.bin;
            catch
                BinArrayIN = [];
            end
            PageCurrent =  gui_mvpc_plot.ERPwaviewer.PageIndex;
            yylim_out = f_erpAutoYLim(ALLERPIN, ERPArrayin,plotOrg,BinArrayIN, ChanArrayIn);
            YScales = [];
            try
                YScales = yylim_out(PageCurrent,:);
            catch
                YScales = yylim_out(1,:);
            end
            messgStr = '';
            if isempty(YScales)
                messgStr =  strcat('The default Y scales will be used because the inputs are empty');
            elseif numel(YScales)~=2
                messgStr =  strcat('The default Y scales will be used because the number of inputs is not 2');
            end
            if ~ismepty(messgStr)
                estudioworkingmemory('ERPViewer_proces_messg',messgStr);
                fprintf(2,['\n Warning: ',messgStr,'.\n']);
                viewer_ERPDAT.Process_messg =4;
            end
        end
        
        gui_mvpc_plot.yaxispars{1} = gui_mvpc_plot.ERPwaviewer.yaxis.scalesauto;
        gui_mvpc_plot.yaxispars{2} = YScales;
        %%yticks
        YTicks = str2num(char(gui_mvpc_plot.yticks_edit.String));
        count_xtks = 0;
        yticks_exm = [];
        if ~isempty(YTicks) && numel(YScales) ==2 %%check if xticks exceed the defined time range
            for Numofxticks = 1:numel(YTicks)
                if YTicks(Numofxticks)< YScales(1) || YTicks(Numofxticks)> YScales(2)
                    count_xtks =count_xtks+1;
                    yticks_exm(count_xtks) = Numofxticks;
                end
            end
            YTicks(yticks_exm) = [];
        end
        
        gui_mvpc_plot.yaxispars{3} = gui_mvpc_plot.ytickauto.Value;
        gui_mvpc_plot.yaxispars{4} = YTicks;
        gui_mvpc_plot.yaxispars{5} = gui_mvpc_plot.ERPwaviewer.yaxis.tickdecimals;
        %%minor yticks
        
        gui_mvpc_plot.yaxispars{6} = gui_mvpc_plot.ERPwaviewer.yaxis.yminor.disp ;
        gui_mvpc_plot.yaxispars{7} = gui_mvpc_plot.ERPwaviewer.yaxis.yminor.auto;
        gui_mvpc_plot.yaxispars{8} = gui_mvpc_plot.ERPwaviewer.yaxis.yminor.step;
        
        %%y labels: on/off
        gui_mvpc_plot.yaxispars{9} = gui_mvpc_plot.ylabel_on.Value;
        %%yticks: font and font size
        yfontsizeinum = str2num(char(fontsize));
        gui_mvpc_plot.yaxispars{10} =gui_mvpc_plot.ERPwaviewer.yaxis.font;
        gui_mvpc_plot.yaxispars{11}=gui_mvpc_plot.yfont_custom_size.Value;
        %%yticks color
        gui_mvpc_plot.yaxispars{12}=gui_mvpc_plot.ytextcolor.Value;
        %%y units
        gui_mvpc_plot.yaxispars{13}= gui_mvpc_plot.yunits_on.Value;
        
        %%save the parameters
        viewer_ERPDAT.Count_currentERP=1;
        viewer_ERPDAT.Process_messg =2;%% complete
    end

%%------------change this panel based on the changed ERPsets---------------
    function Count_currentMVPC_changed(~,~)
        if viewer_ERPDAT.Count_currentERP ~=3
            return;
        end
        if isempty(observe_DECODE.MVPC) || isempty(observe_DECODE.ALLMVPC)
            EnableFlag = 'off';
        else
            EnableFlag = 'on';
        end
        
        gui_mvpc_plot.xmillisecond.Enable = EnableFlag;
        gui_mvpc_plot.xsecond.Enable = EnableFlag;
        
        gui_mvpc_plot.timerange_edit.Enable = EnableFlag;
        gui_mvpc_plot.xtimerangeauto.Enable = EnableFlag;
        
        
        gui_mvpc_plot.timeticks_edit.Enable = EnableFlag;
        gui_mvpc_plot.xtimetickauto.Enable = EnableFlag;
        gui_mvpc_plot.xticks_precision.Enable = EnableFlag;
        xprecisoonName = {'0','1','2','3','4','5','6'};
        
        gui_mvpc_plot.xtimeminorauto.Enable = EnableFlag;
        gui_mvpc_plot.timeminorticks_custom.Enable = EnableFlag;
        gui_mvpc_plot.timeminorticks_auto.Enable = EnableFlag;
        
        
        gui_mvpc_plot.xtimelabel_on.Enable = EnableFlag;
        gui_mvpc_plot.xtimelabel_off.Enable = EnableFlag;
        
        
        gui_mvpc_plot.xtimefont_custom.Enable = EnableFlag;
        gui_mvpc_plot.font_custom_size.Enable = EnableFlag;
        gui_mvpc_plot.xtimetextcolor.Enable = EnableFlag;
        
        gui_mvpc_plot.xtimeunits_on.Enable = EnableFlag;
        gui_mvpc_plot.xtimeunits_off.Enable = EnableFlag;
        
        
        gui_mvpc_plot.yrange_edit.Enable = EnableFlag;
        gui_mvpc_plot.yrangeauto.Enable = EnableFlag;
        
        gui_mvpc_plot.yticks_edit.Enable = EnableFlag;
        gui_mvpc_plot.ytickauto.Enable = EnableFlag;
        
        gui_mvpc_plot.yticks_precision.Enable = EnableFlag;
        
        
        gui_mvpc_plot.yminortick.Enable = EnableFlag;
        gui_mvpc_plot.yminorstepedit.Enable = EnableFlag;
        gui_mvpc_plot.yminorstep_auto.Enable = EnableFlag;
        
        gui_mvpc_plot.ylabel_on.Enable = EnableFlag;
        gui_mvpc_plot.ylabel_off.Enable = EnableFlag;
        
        gui_mvpc_plot.yfont_custom.Enable = EnableFlag;
        gui_mvpc_plot.yfont_custom_size.Enable = EnableFlag;
        
        
        gui_mvpc_plot.ytextcolor.Enable = EnableFlag;
        
        gui_mvpc_plot.yunits_on.Enable = EnableFlag;
        gui_mvpc_plot.yunits_off.Enable = EnableFlag;
        
        
        
        try
            ERPIN = observe_DECODE.MVPC;
            timeArraydef(1) = observe_DECODE.MVPC.times(1);
            timeArraydef(2) = observe_DECODE.MVPC.times(end);
            [timeticksdef stepX]= default_time_ticks_studio(ERPIN, [timeArraydef(1),timeArraydef(2)]);
            if ~isempty(stepX) && numel(stepX) ==1
                stepX = floor(stepX/2);
            end
        catch
            timeticksdef = [];
            timeArraydef = [];
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%----------------------------Setting for X axis-------------------
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        xSecondflag = estudioworkingmemory('MyViewer_xaxis_second');
        xmSecondflag =  estudioworkingmemory('MyViewer_xaxis_msecond');
        xdispysecondValue =  gui_mvpc_plot.xmillisecond.Value;%%millisecond
        timerange =  str2num(gui_mvpc_plot.timerange_edit.String);
        if isempty(timerange) || numel(timerange)~=2 || timerange(1) >= timeArraydef(2) || timerange(2) <= timeArraydef(1)
            timerange =timeArraydef;
            if xdispysecondValue==1
                gui_mvpc_plot.timerange_edit.String = num2str(timerange);
            else
                gui_mvpc_plot.timerange_edit.String = num2str(timerange/1000);
            end
        end
        if gui_mvpc_plot.xtimerangeauto.Value==1
            if xdispysecondValue==1
                gui_mvpc_plot.timerange_edit.String = num2str(timeArraydef);
            else
                gui_mvpc_plot.timerange_edit.String = num2str(timeArraydef/1000);
            end
        end
        if xdispysecondValue==1
            gui_mvpc_plot.xticks_precision.String = {'0','1','2','3','4','5','6'};
        else
            gui_mvpc_plot.xticks_precision.String = {'1','2','3','4','5','6'};
        end
        
        
        if xdispysecondValue==1
            xtick_precision =gui_mvpc_plot.xticks_precision.Value-1;
            if xtick_precision<0
                xtick_precision =0;
                gui_mvpc_plot.xticks_precision.Value=1;
            end
        else
            xtick_precision =gui_mvpc_plot.xticks_precision.Value;
            if xtick_precision<=0
                xtick_precision =1;
                gui_mvpc_plot.xticks_precision.Value=1;
            end
        end
        if gui_mvpc_plot.xtimetickauto.Value ==1 && gui_mvpc_plot.xtimerangeauto.Value==1
            if xdispysecondValue==0
                timetickstrs = num2str(str2num(char(timeticksdef))/1000);
            else
                timetickstrs = timeticksdef;
            end
            timetickstrs= f_decimal(char(timetickstrs),xtick_precision);
            gui_mvpc_plot.timeticks_edit.String = char(timetickstrs);
        end
        gui_mvpc_plot.ERPwaviewer.xaxis.tickdecimals = xtick_precision;
        
        %%X minor ticks
        stepX = [];
        timeArray = str2num(char(gui_mvpc_plot.timerange_edit.String));
        xticksStr = str2num(char(gui_mvpc_plot.timeticks_edit.String));
        if xdispysecondValue~=1
            xticksStr = xticksStr*1000;
            timeArray = timeArray*1000;
        end
        
        if gui_mvpc_plot.timeminorticks_auto.Value ==1
            if ~isempty(xticksStr) && numel(xticksStr)>1
                stepX = [];
                if ~isempty(xticksStr) && numel(xticksStr)>1 && numel(timeArray) ==2 && (timeArray(1)< timeArray(2))
                    if numel(xticksStr)>=2
                        for Numofxticks = 1:numel(xticksStr)-1
                            stepX(1,Numofxticks) = xticksStr(Numofxticks)+(xticksStr(Numofxticks+1)-xticksStr(Numofxticks))/2;
                        end
                        %%adjust the left edge
                        stexleft =  (xticksStr(2)-xticksStr(1))/2;
                        for ii = 1:1000
                            if  (xticksStr(1)- stexleft*ii)>=timeArray(1)
                                stepX   = [(xticksStr(1)- stexleft*ii),stepX];
                            else
                                break;
                            end
                        end
                        %%adjust the right edge
                        stexright =  (xticksStr(end)-xticksStr(end-1))/2;
                        for ii = 1:1000
                            if  (xticksStr(end)+ stexright*ii)<=timeArray(end)
                                stepX   = [stepX,(xticksStr(end)+ stexright*ii)];
                            else
                                break;
                            end
                        end
                    end
                end
            end
            if xdispysecondValue==0
                stepX = stepX/1000;
            end
            gui_mvpc_plot.timeminorticks_custom.String = num2str(stepX);
        end
        
        if xdispysecondValue==1
            gui_mvpc_plot.ERPwaviewer.xaxis.timerange = str2num(gui_mvpc_plot.timerange_edit.String);
        else
            gui_mvpc_plot.ERPwaviewer.xaxis.timerange = str2num(gui_mvpc_plot.timerange_edit.String)*1000;
        end
        timeRange = gui_mvpc_plot.ERPwaviewer.xaxis.timerange ;
        %%getting xticks
        if xdispysecondValue==1
            xticksArray = str2num(char(gui_mvpc_plot.timeticks_edit.String));
        else
            xticksArray = str2num(char(gui_mvpc_plot.timeticks_edit.String))*1000;
        end
        count_xtks = 0;
        xticks_exm = [];
        if ~isempty(xticksArray) && numel(timeRange) ==2 %%check if xticks exceed the defined time range
            for Numofxticks = 1:numel(xticksArray)
                if xticksArray(Numofxticks)< timeRange(1) || xticksArray(Numofxticks)> timeRange(2)
                    count_xtks =count_xtks+1;
                    xticks_exm(count_xtks) = Numofxticks;
                end
            end
            xticksArray(xticks_exm) = [];
        end
        
        xticckMinorstep = str2num(char(gui_mvpc_plot.timeminorticks_custom.String));
        if xdispysecondValue==1
            gui_mvpc_plot.ERPwaviewer.xaxis.tminor.step = xticckMinorstep;
        else
            gui_mvpc_plot.ERPwaviewer.xaxis.tminor.step = xticckMinorstep*1000;
        end
        gui_mvpc_plot.ERPwaviewer.xaxis.timeticks = xticksArray;
        
        
        if xdispysecondValue==1
            gui_mvpc_plot.xaxispars{1}=1;
            gui_mvpc_plot.xaxispars{3} =  str2num(char(gui_mvpc_plot.timerange_edit.String));
            gui_mvpc_plot.xaxispars{5} = str2num(char(gui_mvpc_plot.timeticks_edit.String));
            gui_mvpc_plot.xaxispars{8} = str2num(char(gui_mvpc_plot.timeminorticks_custom.String));
        else
            gui_mvpc_plot.xaxispars{1}=0;
            gui_mvpc_plot.xaxispars{3} =  str2num(char(gui_mvpc_plot.timerange_edit.String));
            gui_mvpc_plot.xaxispars{5} = str2num(char(gui_mvpc_plot.timeticks_edit.String));
            gui_mvpc_plot.xaxispars{8} = str2num(char(gui_mvpc_plot.timeminorticks_custom.String));
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%----------------------------Setting for Y axis-------------------
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%y scale
        ALLERPIN = gui_mvpc_plot.ERPwaviewer.ALLERP;
        ERPArrayin = gui_mvpc_plot.ERPwaviewer.SelectERPIdx;
        plotOrg = [1 2 3];
        try
            plotOrg(1) = gui_mvpc_plot.ERPwaviewer.plot_org.Grid;
            plotOrg(2) = gui_mvpc_plot.ERPwaviewer.plot_org.Overlay;
            plotOrg(3) = gui_mvpc_plot.ERPwaviewer.plot_org.Pages;
        catch
            plotOrg = [1 2 3];
        end
        try
            ChanArrayIn = gui_mvpc_plot.ERPwaviewer.chan;
        catch
            ChanArrayIn = [];
        end
        try
            BinArrayIN = gui_mvpc_plot.ERPwaviewer.bin;
        catch
            BinArrayIN = [];
        end
        
        PageCurrent =  gui_mvpc_plot.ERPwaviewer.PageIndex;
        yylim_out = f_erpAutoYLim(ALLERPIN, ERPArrayin,plotOrg,BinArrayIN, ChanArrayIn);
        try
            yRangeLabel = num2str(yylim_out(PageCurrent,:));
        catch
            yRangeLabel = num2str(yylim_out(1,:));
        end
        yrange = str2num(gui_mvpc_plot.yrange_edit.String);
        if isempty(yrange) || numel(yrange)~=2
            yrange = str2num(yRangeLabel);
        end
        
        if gui_mvpc_plot.yrangeauto.Value ==1
            gui_mvpc_plot.yrange_edit.String = yRangeLabel;
        end
        %%y ticks
        yticksLabel = '';
        if ~isempty(str2num(yRangeLabel))
            yticksLabel = default_amp_ticks_viewer(str2num(yRangeLabel));
        end
        ytick_precision= gui_mvpc_plot.yticks_precision.Value-1;
        yticksLabel= f_decimal(char(yticksLabel),ytick_precision);
        if gui_mvpc_plot.ytickauto.Value ==1 && gui_mvpc_plot.yrangeauto.Value ==1
            gui_mvpc_plot.yticks_edit.String = yticksLabel;
        end
        
        %%y minor ticks
        if gui_mvpc_plot.yminorstep_auto.Value==1
            yticksStr = str2num(char(gui_mvpc_plot.yticks_edit.String));
            stepY = [];
            
            if ~isempty(yticksStr) && numel(yticksStr)>1
                if numel(yticksStr)>=2
                    for Numofxticks = 1:numel(yticksStr)-1
                        stepY(1,Numofxticks) = yticksStr(Numofxticks)+(yticksStr(Numofxticks+1)-yticksStr(Numofxticks))/2;
                    end
                    %%adjust the left edge
                    steyleft =  (yticksStr(2)-yticksStr(1))/2;
                    for ii = 1:1000
                        if  (yticksStr(1)- steyleft*ii)>=yrange(1)
                            stepY   = [(yticksStr(1)- steyleft*ii),stepY];
                        else
                            break;
                        end
                    end
                    %%adjust the right edge
                    steyright =  (yticksStr(end)-yticksStr(end-1))/2;
                    for ii = 1:1000
                        if  (yticksStr(end)+ steyright*ii)<=yrange(end)
                            stepY   = [stepY,(yticksStr(end)+ steyright*ii)];
                        else
                            break;
                        end
                    end
                end
            end
            gui_mvpc_plot.yminorstepedit.String=char(num2str(stepY));
        end
        
        %%y axis
        YScales = str2num(char(gui_mvpc_plot.yrange_edit.String));
        if isempty(YScales)
            PageCurrent =  gui_mvpc_plot.ERPwaviewer.PageIndex;
            yylim_out = f_erpAutoYLim(ALLERPIN, ERPArrayin,plotOrg,BinArrayIN, ChanArrayIn);
            YScales = [];
            try
                YScales = yylim_out(PageCurrent,:);
            catch
                YScales = yylim_out(1,:);
            end
        end
        gui_mvpc_plot.ERPwaviewer.yaxis.scales =YScales ;
        YTicks = str2num(char(gui_mvpc_plot.yticks_edit.String));
        count_xtks = 0;
        yticks_exm = [];
        if ~isempty(YTicks) && numel(YScales) ==2 %%check if xticks exceed the defined time range
            for Numofxticks = 1:numel(YTicks)
                if YTicks(Numofxticks)< YScales(1) || YTicks(Numofxticks)> YScales(2)
                    count_xtks =count_xtks+1;
                    yticks_exm(count_xtks) = Numofxticks;
                end
            end
            YTicks(yticks_exm) = [];
        end
        gui_mvpc_plot.ERPwaviewer.yaxis.ticks = YTicks;
        gui_mvpc_plot.ERPwaviewer.yaxis.yminor.step = str2num(char(gui_mvpc_plot.yminorstepedit.String));
        %%save the parameters
        
        gui_mvpc_plot.yaxispars{1} = gui_mvpc_plot.yrangeauto.Value;
        gui_mvpc_plot.yaxispars{2}=str2num(char(gui_mvpc_plot.yrange_edit.String));
        gui_mvpc_plot.yaxispars{4} =  str2num(char(gui_mvpc_plot.yticks_edit.String));
        gui_mvpc_plot.yaxispars{8} = str2num(char(gui_mvpc_plot.yminorstepedit.String));
        
        viewer_ERPDAT.Count_currentERP =4;
    end

%%-------------------------------------------------------------------------
%%Automatically saving the changed parameters for the current panel if the
%%user change parameters for the other panels.
%%-------------------------------------------------------------------------
    function count_twopanels_change(~,~)
        if viewer_ERPDAT.count_twopanels==0
            return;
        end
        changeFlag =  estudioworkingmemory('MyViewer_xyaxis');
        if changeFlag~=1
            return;
        end
        xyaxis_apply();
    end

%%-------------------------------------------------------------------------
%%-----------------Reset this panel with the default parameters------------
%%-------------------------------------------------------------------------
    function Reset_Waviewer_panel_change(~,~)
        if viewer_ERPDAT.Reset_Waviewer_panel~=3
            return;
        end
        try
            ERPIN = observe_DECODE.MVPC;
            timeArray(1) = observe_DECODE.MVPC.times(1);
            timeArray(2) = observe_DECODE.MVPC.times(end);
            [timeticks stepX]= default_time_ticks_studio(ERPIN, [timeArray(1),timeArray(2)]);
            if ~isempty(stepX) && numel(stepX) ==1
                stepX = floor(stepX/2);
            end
        catch
            timeticks = '';
            timeArray = [];
        end
        gui_mvpc_plot.xmillisecond.Value =1;
        gui_mvpc_plot.xsecond.Value =0;
        gui_mvpc_plot.ERPwaviewer.xaxis.tdis =1;
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%----------------------------Setting for X axis-------------------
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%time range
        gui_mvpc_plot.timerange_edit.String = num2str(timeArray);
        gui_mvpc_plot.ERPwaviewer.xaxis.timerange = timeArray;
        gui_mvpc_plot.timerange_edit.Enable = 'off';
        gui_mvpc_plot.xtimerangeauto.Value = 1;
        gui_mvpc_plot.ERPwaviewer.xaxis.trangeauto =1;
        
        gui_mvpc_plot.xaxispars{1}  =1;
        gui_mvpc_plot.xaxispars{2}  = 1;
        gui_mvpc_plot.xaxispars{3}  = timeArray;
        
        %%x ticklable
        gui_mvpc_plot.timeticks_edit.String = char(timeticks);%% xtick label
        gui_mvpc_plot.ERPwaviewer.xaxis.timeticks = str2num(char(timeticks));
        gui_mvpc_plot.timeticks_edit.Enable = 'off';
        gui_mvpc_plot.xtimetickauto.Value=1;
        gui_mvpc_plot.ERPwaviewer.xaxis.ticksauto = 1;
        gui_mvpc_plot.xaxispars{4}=1;
        gui_mvpc_plot.xaxispars{5} =str2num(char(timeticks));
        %%x precision for x ticklabel
        gui_mvpc_plot.xticks_precision.String = {'0','1','2','3','4','5','6'};
        gui_mvpc_plot.xticks_precision.Value = 1;
        gui_mvpc_plot.ERPwaviewer.xaxis.tickdecimals = 0;
        gui_mvpc_plot.xaxispars{6} = 0;
        %%x minor ticks
        gui_mvpc_plot.xtimeminorauto.Value =0;
        gui_mvpc_plot.ERPwaviewer.xaxis.tminor.disp = 0;
        stepX = [];
        timeArray = str2num(char(gui_mvpc_plot.timerange_edit.String));
        xticksStr = str2num(char(gui_mvpc_plot.timeticks_edit.String));
        gui_mvpc_plot.timeminorticks_custom.String = '';
        gui_mvpc_plot.timeminorticks_custom.Enable = 'off';
        gui_mvpc_plot.timeminorticks_auto.Value=1;
        gui_mvpc_plot.timeminorticks_auto.Enable = 'off';
        gui_mvpc_plot.ERPwaviewer.xaxis.tminor.step =[];
        gui_mvpc_plot.ERPwaviewer.xaxis.tminor.auto = 1;
        gui_mvpc_plot.xaxispars{7} = 0;
        gui_mvpc_plot.xaxispars{8} = xticksStr;
        gui_mvpc_plot.xaxispars{9} =1;
        %%x label on/off
        gui_mvpc_plot.xtimelabel_on.Value=1; %
        gui_mvpc_plot.xtimelabel_off.Value=0;
        gui_mvpc_plot.ERPwaviewer.xaxis.label =1;
        gui_mvpc_plot.xaxispars{10}=1;
        %%font and font size
        gui_mvpc_plot.ERPwaviewer.xaxis.font  =3;
        gui_mvpc_plot.xtimefont_custom.Value=3;
        gui_mvpc_plot.ERPwaviewer.xaxis.fontsize =10;
        gui_mvpc_plot.font_custom_size.Value=4;
        fonttype = {'Courier','Geneva','Helvetica','Monaco','Times'};
        gui_mvpc_plot.yfont_custom.String=fonttype; %
        yfontsize={'4','6','8','10','12','14','16','18','20','24','28','32','36',...
            '40','50','60','70','80','90','100'};
        gui_mvpc_plot.font_custom_size.String = yfontsize;
        gui_mvpc_plot.xaxispars{11}=3;
        gui_mvpc_plot.xaxispars{12}=4;
        gui_mvpc_plot.xaxispars{13} =1;
        
        
        %%color for x ticklabel
        xtextColor = {'Black','Red','Blue','Green','Orange','Cyan','Magenla'};
        gui_mvpc_plot.xtimetextcolor.String =xtextColor ;
        gui_mvpc_plot.ERPwaviewer.xaxis.fontcolor =1;
        %%x units
        gui_mvpc_plot.ERPwaviewer.xaxis.units =1;
        gui_mvpc_plot.xtimeunits_on.Value=1; %
        gui_mvpc_plot.xtimeunits_off.Value=0; %
        gui_mvpc_plot.xaxispars{14}=1;
        estudioworkingmemory('MyViewer_xaxis_second',0);
        estudioworkingmemory('MyViewer_xaxis_msecond',1);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%----------------------------Setting for Y axis---------------
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%y scale
        ALLERPIN = gui_mvpc_plot.ERPwaviewer.ALLERP;
        ERPArrayin = gui_mvpc_plot.ERPwaviewer.SelectERPIdx;
        plotOrg = [1 2 3];
        try
            ChanArrayIn = gui_mvpc_plot.ERPwaviewer.chan;
        catch
            ChanArrayIn = [];
        end
        try
            BinArrayIN = gui_mvpc_plot.ERPwaviewer.bin;
        catch
            BinArrayIN = [];
        end
        
        PageCurrent =  gui_mvpc_plot.ERPwaviewer.PageIndex;
        yylim_out = f_erpAutoYLim(ALLERPIN, ERPArrayin,plotOrg,BinArrayIN, ChanArrayIn);
        try
            yRangeLabel = num2str(yylim_out(PageCurrent,:));
        catch
            yRangeLabel = num2str(yylim_out(1,:));
        end
        %%Y range
        gui_mvpc_plot.yrange_edit.String = yRangeLabel;
        gui_mvpc_plot.yrange_edit.Enable = 'off';
        gui_mvpc_plot.yrangeauto.Value =1;
        gui_mvpc_plot.ERPwaviewer.yaxis.scales = str2num(yRangeLabel);
        gui_mvpc_plot.ERPwaviewer.yaxis.scalesauto = 1;
        gui_mvpc_plot.yaxispars{1}=1;
        gui_mvpc_plot.yaxispars{2} = yRangeLabel;
        %%Y tick label
        %%y ticks
        ytick_precision=1;
        yticksLabel = '';
        if ~isempty(str2num(yRangeLabel))
            yticksLabel = default_amp_ticks_viewer(str2num(yRangeLabel));
            yticksLabel= f_decimal(yticksLabel,ytick_precision);
        end
        gui_mvpc_plot.yticks_edit.String  = yticksLabel;
        gui_mvpc_plot.yticks_edit.Enable = 'off';
        gui_mvpc_plot.ytickauto.Value =1;
        gui_mvpc_plot.ERPwaviewer.yaxis.ticks = str2num(yticksLabel);
        gui_mvpc_plot.ERPwaviewer.yaxis.tickauto = 1;
        gui_mvpc_plot.yticks_precision.Value=2;
        gui_mvpc_plot.ERPwaviewer.yaxis.tickdecimals=1;
        gui_mvpc_plot.yaxispars{3}=1;
        gui_mvpc_plot.yaxispars{5}=1;
        gui_mvpc_plot.yaxispars{4}  = str2num(yticksLabel);
        %%Y minor
        gui_mvpc_plot.ERPwaviewer.yaxis.yminor.disp =0;
        gui_mvpc_plot.ERPwaviewer.yaxis.yminor.auto =1;
        gui_mvpc_plot.ERPwaviewer.yaxis.yminor.step = [];
        gui_mvpc_plot.yminortick.Value=0; %
        gui_mvpc_plot.yminorstepedit.String ='';
        gui_mvpc_plot.yminorstepedit.Enable = 'off'; %
        gui_mvpc_plot.yminorstep_auto.Value=1;
        gui_mvpc_plot.yminorstep_auto.Enable ='off'; %
        gui_mvpc_plot.yaxispars{6}=0;
        gui_mvpc_plot.yaxispars{7}=1;
        gui_mvpc_plot.yaxispars{8}=[];
        %%Y ticklabel on/off
        gui_mvpc_plot.ERPwaviewer.yaxis.label = 1;
        gui_mvpc_plot.ylabel_on.Value=1; %
        gui_mvpc_plot.ylabel_off.Value=0;
        %%font and fontsize
        gui_mvpc_plot.ERPwaviewer.yaxis.font=3;
        gui_mvpc_plot.ERPwaviewer.yaxis.fontsize=10;
        gui_mvpc_plot.yfont_custom.Value=3;
        gui_mvpc_plot.yfont_custom_size.Value=4;
        %%color for y ticklabels
        ytextColor = {'Black','Red','Blue','Green','Orange','Cyan','Magenla'};
        gui_mvpc_plot.ytextcolor.String = ytextColor;
        gui_mvpc_plot.ytextcolor.Value=1;
        gui_mvpc_plot.ERPwaviewer.yaxis.fontcolor =1;
        %%y units
        gui_mvpc_plot.yunits_on.Value=1; %
        gui_mvpc_plot.yunits_off.Value=0; %
        gui_mvpc_plot.ERPwaviewer.yaxis.units=1;
        gui_mvpc_plot.yaxispars{9}=1;
        gui_mvpc_plot.yaxispars{10} =3;
        gui_mvpc_plot.yaxispars{11}=4;
        gui_mvpc_plot.yaxispars{12}=1;
        gui_mvpc_plot.yaxispars{13}= 1;
        
        gui_mvpc_plot.apply.BackgroundColor =  [1 1 1];
        gui_mvpc_plot.apply.ForegroundColor = [0 0 0];
        box_erpxtaxes_viewer_property.TitleColor= [0.5 0.5 0.9];
        viewer_ERPDAT.Reset_Waviewer_panel=4;
    end%% end of reset for the current panel


%%----------------Press Return key to execute the function-----------------
    function xyaxis_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            xyaxis_apply();
            estudioworkingmemory('MyViewer_xyaxis',0);
            gui_mvpc_plot.apply.BackgroundColor =  [1 1 1];
            gui_mvpc_plot.apply.ForegroundColor = [0 0 0];
            box_erpxtaxes_viewer_property.TitleColor= [0.5 0.5 0.9];
        else
            return;
        end
    end

%%----------change the title color and backgroundcolor for "cancel" and----
%%--------------"Apply" if any of parameters was changed-------------------
    function track_changes_title_color(~,~)
        gui_mvpc_plot.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_mvpc_plot.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        gui_mvpc_plot.cancel.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_mvpc_plot.cancel.ForegroundColor = [1 1 1];
    end

end