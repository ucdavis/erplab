%%This function is to plot the panel for "Viewer properties".

% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022


function varargout = f_ERP_timeampscal_waveviewer_GUI(varargin)
global viewer_ERPDAT

addlistener(viewer_ERPDAT,'v_currentERP_change',@v_currentERP_change);
addlistener(viewer_ERPDAT,'page_xyaxis_change',@page_xyaxis_change);
addlistener(viewer_ERPDAT,'count_loadproper_change',@count_loadproper_change);
addlistener(viewer_ERPDAT,'count_twopanels_change',@count_twopanels_change);
addlistener(viewer_ERPDAT,'Reset_Waviewer_panel_change',@Reset_Waviewer_panel_change);

gui_erpxyaxeset_waveviewer = struct();

%-----------------------------Name the title----------------------------------------------
% global box_erpxtaxes_viewer_property;
[version reldate,ColorB_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    box_erpxtaxes_viewer_property = uiextras.BoxPanel('Parent', fig, 'Title', 'Time and Amplitude Scales', 'Padding', 5,...
        'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w','FontSize',12); % Create boxpanel
elseif nargin == 1
    box_erpxtaxes_viewer_property = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Time and Amplitude Scales', 'Padding', 5,...
        'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w','FontSize',12);
else
    box_erpxtaxes_viewer_property = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Time and Amplitude Scales', 'Padding', 5, ...
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


drawui_plot_xyaxis_viewer(FonsizeDefault);
varargout{1} = box_erpxtaxes_viewer_property;

    function drawui_plot_xyaxis_viewer(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
        try
            ALLERPwaviewer = evalin('base','ALLERPwaviewer');
            ERPwaviewer = ALLERPwaviewer;
        catch
            beep;
            disp('f_ERP_timeampscal_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        try
            timeArray(1) = ERPwaviewer.ERP.times(1);
            timeArray(2) = ERPwaviewer.ERP.times(end);
        catch
            timeArray = [];
        end
        try
            timerangeAuto = ERPwaviewer.xaxis.trangeauto;
        catch
            timerangeAuto =1;
        end
        gui_erpxyaxeset_waveviewer.DataSelBox = uiextras.VBox('Parent', box_erpxtaxes_viewer_property,'BackgroundColor',ColorBviewer_def);
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%Setting for X axis%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        try
            ERPIN = ERPwaviewer.ERP;
            timeArray(1) = ERPwaviewer.ERP.times(1);
            timeArray(2) = ERPwaviewer.ERP.times(end);
            [timeticks stepX]= default_time_ticks_studio(ERPIN, [timeArray(1),timeArray(2)]);
            if ~isempty(stepX) && numel(stepX) ==1
                stepX = floor(stepX/2);
            end
        catch
            timeticks = [];
            timeArray =[];
        end
        %%-----------------Setting for time range-------
        gui_erpxyaxeset_waveviewer.xaxis_title = uiextras.HBox('Parent', gui_erpxyaxeset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_erpxyaxeset_waveviewer.xaxis_title,'String','X Axis:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','center','FontWeight','bold'); %
        
        %%-------Display with second or millisecond------------------------
        gui_erpxyaxeset_waveviewer.display_title = uiextras.HBox('Parent', gui_erpxyaxeset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_erpxyaxeset_waveviewer.display_title,...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Display in','HorizontalAlignment','left'); %
        xdispysecondValue = 1;
        gui_erpxyaxeset_waveviewer.xmillisecond = uicontrol('Style','radiobutton','Parent',  gui_erpxyaxeset_waveviewer.display_title,...
            'callback',@xmilsecond,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Millisecond','Value',xdispysecondValue); %
        gui_erpxyaxeset_waveviewer.xsecond = uicontrol('Style','radiobutton','Parent',  gui_erpxyaxeset_waveviewer.display_title,...
            'callback',@xsecond,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Second','Value',~xdispysecondValue); %
        set(gui_erpxyaxeset_waveviewer.display_title,'Sizes',[75 90 75]);
        ERPwaviewer.xaxis.tdis = 1;
        erpworkingmemory('MyViewer_xaxis_second',0);
        erpworkingmemory('MyViewer_xaxis_msecond',1);
        %%------time range------
        gui_erpxyaxeset_waveviewer.xtimerange_title = uiextras.HBox('Parent', gui_erpxyaxeset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        gui_erpxyaxeset_waveviewer.timerange_label = uicontrol('Style','text','Parent', gui_erpxyaxeset_waveviewer.xtimerange_title,...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Time Range','Max',10,'HorizontalAlignment','left'); %
        gui_erpxyaxeset_waveviewer.timerange_edit = uicontrol('Style','edit','Parent', gui_erpxyaxeset_waveviewer.xtimerange_title,'String',num2str(timeArray),...
            'callback',@timerangecustom,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %
        
        gui_erpxyaxeset_waveviewer.xtimerangeauto = uicontrol('Style','checkbox','Parent', gui_erpxyaxeset_waveviewer.xtimerange_title,'String','Auto',...
            'callback',@xtimerangeauto,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',timerangeAuto); %
        if gui_erpxyaxeset_waveviewer.xtimerangeauto.Value ==1
            enableName = 'off';
        else
            enableName = 'on';
        end
        gui_erpxyaxeset_waveviewer.timerange_edit.Enable = enableName;
        set(gui_erpxyaxeset_waveviewer.xtimerange_title,'Sizes',[80 100 60]);
        ERPwaviewer.xaxis.timerange = str2num(char(gui_erpxyaxeset_waveviewer.timerange_edit.String));
        ERPwaviewer.xaxis.trangeauto = gui_erpxyaxeset_waveviewer.xtimerangeauto.Value;
        
        %%----------------------time ticks---------------------------------
        stepX = [];
        timeticksAuto = 1;
        xtick_precision =0;
        
        gui_erpxyaxeset_waveviewer.xtimetick_title = uiextras.HBox('Parent', gui_erpxyaxeset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        gui_erpxyaxeset_waveviewer.timeticks_label = uicontrol('Style','text','Parent',  gui_erpxyaxeset_waveviewer.xtimetick_title ,...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Time Ticks','HorizontalAlignment','left'); %
        gui_erpxyaxeset_waveviewer.timeticks_edit = uicontrol('Style','edit','Parent',  gui_erpxyaxeset_waveviewer.xtimetick_title ,'String',timeticks,...
            'callback',@timetickscustom,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %
        gui_erpxyaxeset_waveviewer.xtimetickauto = uicontrol('Style','checkbox','Parent',  gui_erpxyaxeset_waveviewer.xtimetick_title ,'String','Auto',...
            'callback',@xtimetickauto,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',timeticksAuto); %
        if gui_erpxyaxeset_waveviewer.xtimetickauto.Value ==1
            enableName_tick = 'off';
        else
            enableName_tick = 'on';
        end
        %         gui_erpxyaxeset_waveviewer.timeticks_label.Enable = enableName_tick;
        gui_erpxyaxeset_waveviewer.timeticks_edit.Enable = enableName_tick;
        set(gui_erpxyaxeset_waveviewer.xtimetick_title,'Sizes',[80 100 60]);
        ERPwaviewer.xaxis.timeticks = str2num(char(gui_erpxyaxeset_waveviewer.timeticks_edit.String));
        ERPwaviewer.xaxis.ticksauto = gui_erpxyaxeset_waveviewer.xtimetickauto.Value;
        
        
        %%--------x tick precision with decimals---------------------------
        gui_erpxyaxeset_waveviewer.xtickprecision_title = uiextras.HBox('Parent', gui_erpxyaxeset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uiextras.Empty('Parent',  gui_erpxyaxeset_waveviewer.xtickprecision_title);
        uicontrol('Style','text','Parent',gui_erpxyaxeset_waveviewer.xtickprecision_title ,...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Precision','HorizontalAlignment','left'); %
        xprecisoonName = {'0','1','2','3','4','5','6'};
        gui_erpxyaxeset_waveviewer.xticks_precision = uicontrol('Style','popupmenu','Parent',gui_erpxyaxeset_waveviewer.xtickprecision_title,'String',xprecisoonName,...
            'callback',@xticksprecison,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Value',xtick_precision+1); %
        uicontrol('Style','text','Parent',  gui_erpxyaxeset_waveviewer.xtickprecision_title,'String','# decimals',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); %
        set(gui_erpxyaxeset_waveviewer.xtickprecision_title,'Sizes',[30 65 60 80]);
        ERPwaviewer.xaxis.tickdecimals = gui_erpxyaxeset_waveviewer.xticks_precision.Value-1;
        
        
        
        %%-----time minor ticks--------------------------------------------
        xticksStr = str2num(char(gui_erpxyaxeset_waveviewer.timeticks_edit.String));
        stepX = [];
        if ~isempty(xticksStr) && numel(xticksStr)>1
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
        timeminorLabel = 0;
        if timeminorLabel==1
            xminorEnable_auto = 'on';
        else
            xminorEnable_auto = 'off';
        end
        timeminorstep = 1;
        if timeminorstep ==1
            xminorEnable_custom = 'off';
        else
            xminorEnable_custom = 'on';
        end
        gui_erpxyaxeset_waveviewer.xtimeminnortick_title = uiextras.HBox('Parent', gui_erpxyaxeset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        gui_erpxyaxeset_waveviewer.xtimeminorauto = uicontrol('Style','checkbox','Parent',  gui_erpxyaxeset_waveviewer.xtimeminnortick_title ,...
            'callback',@timeminortickslabel,'String','Minor ticks','FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left','Value',timeminorLabel); %
        gui_erpxyaxeset_waveviewer.timeminorticks_custom = uicontrol('Style','edit','Parent',  gui_erpxyaxeset_waveviewer.xtimeminnortick_title ,...
            'callback',@timeminorticks_custom,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'String',num2str(stepX),'Enable',xminorEnable_custom); %
        gui_erpxyaxeset_waveviewer.timeminorticks_auto = uicontrol('Style','checkbox','Parent',  gui_erpxyaxeset_waveviewer.xtimeminnortick_title,...
            'callback',@timeminortickscustom_auto,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Auto','Value',timeminorstep, 'Enable',xminorEnable_auto); %
        set(gui_erpxyaxeset_waveviewer.xtimeminnortick_title,'Sizes',[90 90 50]);
        ERPwaviewer.xaxis.tminor.disp = gui_erpxyaxeset_waveviewer.xtimeminorauto.Value;
        ERPwaviewer.xaxis.tminor.step = str2num(char(gui_erpxyaxeset_waveviewer.timeminorticks_custom.String));
        ERPwaviewer.xaxis.tminor.auto = gui_erpxyaxeset_waveviewer.timeminorticks_auto.Value;
        
        %%-----time ticks label--------------------------------------------
        timetickLabel = 1;
        gui_erpxyaxeset_waveviewer.xtimelabel_title = uiextras.HBox('Parent', gui_erpxyaxeset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent',  gui_erpxyaxeset_waveviewer.xtimelabel_title ,'String','Labels',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left'); %
        gui_erpxyaxeset_waveviewer.xtimelabel_on = uicontrol('Style','radiobutton','Parent',  gui_erpxyaxeset_waveviewer.xtimelabel_title,...
            'callback',@xtimelabelon,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','On','Value',timetickLabel); %
        gui_erpxyaxeset_waveviewer.xtimelabel_off = uicontrol('Style','radiobutton','Parent',  gui_erpxyaxeset_waveviewer.xtimelabel_title,...
            'callback',@xtimelabeloff,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Off','Value',~timetickLabel); %
        uiextras.Empty('Parent',gui_erpxyaxeset_waveviewer.xtimelabel_title);
        set(gui_erpxyaxeset_waveviewer.xtimelabel_title,'Sizes',[50 50 50 80]);
        if gui_erpxyaxeset_waveviewer.xtimelabel_on.Value ==1
            fontenable = 'on';
        else
            fontenable = 'off';
        end
        ERPwaviewer.xaxis.label = gui_erpxyaxeset_waveviewer.xtimelabel_on.Value;
        
        
        %%-----font, font size, and text color for time ticks--------------
        ttickLabelfont = 2;
        fontsize  = {'4','6','8','10','12','14','16','18','20','24','28','32','36',...
            '40','50','60','70','80','90','100'};
        xfontsizeinum = str2num(char(fontsize));
        ttickLabelfontsizeV = 4;
        ttickLabelfontcolor = 1;
        gui_erpxyaxeset_waveviewer.xtimefont_title = uiextras.HBox('Parent', gui_erpxyaxeset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent',  gui_erpxyaxeset_waveviewer.xtimefont_title,'String','Font',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left'); %
        fonttype = {'Courier','Geneva','Helvetica','Monaco','Times'};
        gui_erpxyaxeset_waveviewer.xtimefont_custom = uicontrol('Style','popupmenu','Parent', gui_erpxyaxeset_waveviewer.xtimefont_title ,'String',fonttype,...
            'callback',@xtimefont,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable',fontenable,'Value',ttickLabelfont); %
        uicontrol('Style','text','Parent', gui_erpxyaxeset_waveviewer.xtimefont_title ,'String','Size',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left'); %
        gui_erpxyaxeset_waveviewer.font_custom_size = uicontrol('Style','popupmenu','Parent', gui_erpxyaxeset_waveviewer.xtimefont_title ,'String',fontsize,...
            'callback',@xtimefontsize,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable',fontenable,'Value',ttickLabelfontsizeV); %
        set(gui_erpxyaxeset_waveviewer.xtimefont_title,'Sizes',[30 100 30 80]);
        ERPwaviewer.xaxis.font = gui_erpxyaxeset_waveviewer.xtimefont_custom.Value;
        ERPwaviewer.xaxis.fontsize = xfontsizeinum(gui_erpxyaxeset_waveviewer.font_custom_size.Value);
        
        %%%---------------------color for x label text--------------
        gui_erpxyaxeset_waveviewer.xtimelabelcolor_title = uiextras.HBox('Parent', gui_erpxyaxeset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent',  gui_erpxyaxeset_waveviewer.xtimelabelcolor_title,'String','Color',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left'); %
        textColor = {'Black','Red','Blue','Green','Orange','Cyan','Magenla'};
        gui_erpxyaxeset_waveviewer.xtimetextcolor = uicontrol('Style','popupmenu','Parent', gui_erpxyaxeset_waveviewer.xtimelabelcolor_title ,'String',textColor,...
            'callback',@xtimecolor,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable',fontenable,'Value',ttickLabelfontcolor); %
        uiextras.Empty('Parent',  gui_erpxyaxeset_waveviewer.xtimelabelcolor_title);
        uiextras.Empty('Parent',  gui_erpxyaxeset_waveviewer.xtimelabelcolor_title);
        set(gui_erpxyaxeset_waveviewer.xtimelabelcolor_title,'Sizes',[40 100 30 70]);
        ERPwaviewer.xaxis.fontcolor = gui_erpxyaxeset_waveviewer.xtimetextcolor.Value;
        
        %%%----Setting for the xunits display--------------------------
        timeunits = 1;
        gui_erpxyaxeset_waveviewer.xtimeunits_title = uiextras.HBox('Parent', gui_erpxyaxeset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent',  gui_erpxyaxeset_waveviewer.xtimeunits_title ,'String','Units',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left'); %
        gui_erpxyaxeset_waveviewer.xtimeunits_on = uicontrol('Style','radiobutton','Parent',  gui_erpxyaxeset_waveviewer.xtimeunits_title,...
            'callback',@xtimeunitson,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','On','Value',timeunits); %
        gui_erpxyaxeset_waveviewer.xtimeunits_off = uicontrol('Style','radiobutton','Parent',  gui_erpxyaxeset_waveviewer.xtimeunits_title,...
            'callback',@xtimeunitsoff,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Off','Value',~timeunits); %
        uiextras.Empty('Parent',  gui_erpxyaxeset_waveviewer.xtimeunits_title);
        set(gui_erpxyaxeset_waveviewer.xtimeunits_title,'Sizes',[50 50 50 80]);
        ERPwaviewer.xaxis.units = gui_erpxyaxeset_waveviewer.xtimeunits_on.Value;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%Setting for Y axis%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%-----------Y scale---------
        ALLERPIN = ERPwaviewer.ALLERP;
        ERPArrayin = ERPwaviewer.SelectERPIdx;
        BinArrayIN = [];
        ChanArrayIn = [];
        plotOrg = [1 2 3];
        try
            plotOrg(1) = ERPwaviewer.plot_org.Grid;
            plotOrg(2) = ERPwaviewer.plot_org.Overlay;
            plotOrg(3) = ERPwaviewer.plot_org.Pages;
        catch
            plotOrg = [1 2 3];
        end
        try
            ChanArrayIn = ERPwaviewer.chan;
        catch
            ChanArrayIn = [];
        end
        try
            BinArrayIN = ERPwaviewer.bin;
        catch
            BinArrayIN = [];
        end
        CURRENTERPIN =  ERPwaviewer.CURRENTERP;
        yylim_out = f_erpAutoYLim(ALLERPIN, ERPArrayin,plotOrg,BinArrayIN, ChanArrayIn);
        [x,yscales_v] = find(ERPArrayin ==CURRENTERPIN);
        yRangeLabel = '';
        if isempty(yscales_v)
            yRangeLabel = '';
        else
            yRangeLabel = num2str(yylim_out(yscales_v,:));
        end
        yRangeauto = 1;
        gui_erpxyaxeset_waveviewer.yaxis_title = uiextras.HBox('Parent', gui_erpxyaxeset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_erpxyaxeset_waveviewer.yaxis_title,'String','Y Axis:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',1,'HorizontalAlignment','center','FontWeight','bold'); %
        gui_erpxyaxeset_waveviewer.yrange_title = uiextras.HBox('Parent', gui_erpxyaxeset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        gui_erpxyaxeset_waveviewer.yrange_label = uicontrol('Style','text','Parent', gui_erpxyaxeset_waveviewer.yrange_title,...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Y Scale','Max',10,'HorizontalAlignment','left'); %
        gui_erpxyaxeset_waveviewer.yrange_edit = uicontrol('Style','edit','Parent', gui_erpxyaxeset_waveviewer.yrange_title,'String',yRangeLabel,...
            'callback',@yrangecustom,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %
        gui_erpxyaxeset_waveviewer.yrangeauto = uicontrol('Style','checkbox','Parent', gui_erpxyaxeset_waveviewer.yrange_title,'String','Auto',...
            'callback',@yrangeauto,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',yRangeauto); %
        if gui_erpxyaxeset_waveviewer.yrangeauto.Value ==1
            yenableName = 'off';
        else
            yenableName = 'on';
        end
        gui_erpxyaxeset_waveviewer.yrange_edit.Enable = yenableName;
        set(gui_erpxyaxeset_waveviewer.yrange_title ,'Sizes',[60 120 60]);
        ERPwaviewer.yaxis.scales = str2num(char(gui_erpxyaxeset_waveviewer.yrange_edit.String));
        ERPwaviewer.yaxis.scalesauto = gui_erpxyaxeset_waveviewer.yrangeauto.Value;
        
        %%--------Y ticks--------------------------------------------------
        ytick_precision = 1;
        yticksLabel = '';
        if ~isempty(str2num(yRangeLabel))
            yticksLabel = default_amp_ticks_viewer(str2num(yRangeLabel));
        end
        yTickauto = 1;
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
        gui_erpxyaxeset_waveviewer.ytick_title = uiextras.HBox('Parent', gui_erpxyaxeset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        gui_erpxyaxeset_waveviewer.yticks_label = uicontrol('Style','text','Parent',gui_erpxyaxeset_waveviewer.ytick_title ,...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Y Ticks','HorizontalAlignment','left'); %
        gui_erpxyaxeset_waveviewer.yticks_edit = uicontrol('Style','edit','Parent',gui_erpxyaxeset_waveviewer.ytick_title,'String',yticksLabel,...
            'callback',@ytickscustom,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %
        gui_erpxyaxeset_waveviewer.ytickauto = uicontrol('Style','checkbox','Parent',  gui_erpxyaxeset_waveviewer.ytick_title ,'String','Auto',...
            'callback',@ytickauto,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',yTickauto); %
        if gui_erpxyaxeset_waveviewer.ytickauto.Value ==1
            yenableName_tick = 'off';
        else
            yenableName_tick = 'on';
        end
        gui_erpxyaxeset_waveviewer.yticks_edit.Enable = yenableName_tick;
        set(gui_erpxyaxeset_waveviewer.ytick_title,'Sizes',[60 120 60]);
        ERPwaviewer.yaxis.ticks = str2num(char(gui_erpxyaxeset_waveviewer.yticks_edit.String));
        ERPwaviewer.yaxis.tickauto = gui_erpxyaxeset_waveviewer.ytickauto.Value;
        
        %%--------Y tick precision with decimals---------------------------
        gui_erpxyaxeset_waveviewer.ytickprecision_title = uiextras.HBox('Parent', gui_erpxyaxeset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uiextras.Empty('Parent',  gui_erpxyaxeset_waveviewer.ytickprecision_title);
        uicontrol('Style','text','Parent',gui_erpxyaxeset_waveviewer.ytickprecision_title ,...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Precision','HorizontalAlignment','left'); %
        yprecisoonName = {'0','1','2','3','4','5','6'};
        gui_erpxyaxeset_waveviewer.yticks_precision = uicontrol('Style','popupmenu','Parent',gui_erpxyaxeset_waveviewer.ytickprecision_title,'String',yprecisoonName,...
            'callback',@yticksprecison,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Value',ytick_precision+1); %
        uicontrol('Style','text','Parent',  gui_erpxyaxeset_waveviewer.ytickprecision_title,'String','# decimals',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); %
        set(gui_erpxyaxeset_waveviewer.ytickprecision_title,'Sizes',[30 65 60 80]);
        ERPwaviewer.yaxis.tickdecimals = gui_erpxyaxeset_waveviewer.yticks_precision.Value-1;
        
        %%-----y minor ticks-----------------------------------------------
        yminorLabel = 0;
        
        if yminorLabel ==1
            yminorautoLabel = 'on';
        else
            yminorautoLabel ='off';
        end
        yminorautoValue = 1;
        if yminorautoValue ==1
            yminoreditEnable = 'off';
        else
            yminoreditEnable = 'on';
        end
        yticksStr = str2num(char(gui_erpxyaxeset_waveviewer.yticks_edit.String));
        stepY = [];
        yscaleRange =  (str2num(yRangeLabel));
        if ~isempty(yticksStr) && numel(yticksStr)>1
            if numel(yticksStr)>=2
                for Numofxticks = 1:numel(yticksStr)-1
                    stepY(1,Numofxticks) = yticksStr(Numofxticks)+(yticksStr(Numofxticks+1)-yticksStr(Numofxticks))/2;
                end
                %%adjust the left edge
                steyleft =  (yticksStr(2)-yticksStr(1))/2;
                for ii = 1:1000
                    if  (yticksStr(1)- steyleft*ii)>=yscaleRange(1)
                        stepY   = [(yticksStr(1)- steyleft*ii),stepY];
                    else
                        break;
                    end
                end
                %%adjust the right edge
                steyright =  (yticksStr(end)-yticksStr(end-1))/2;
                for ii = 1:1000
                    if  (yticksStr(end)+ steyright*ii)<=yscaleRange(end)
                        stepY   = [stepY,(yticksStr(end)+ steyright*ii)];
                    else
                        break;
                    end
                end
            end
        end
        gui_erpxyaxeset_waveviewer.yminnortick_title = uiextras.HBox('Parent', gui_erpxyaxeset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        gui_erpxyaxeset_waveviewer.yminortick = uicontrol('Style','checkbox','Parent',  gui_erpxyaxeset_waveviewer.yminnortick_title ,'String','Minor Ticks',...
            'callback',@yminordisp,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left','Value',yminorLabel); %
        gui_erpxyaxeset_waveviewer.yminorstepedit = uicontrol('Style','edit','Parent',gui_erpxyaxeset_waveviewer.yminnortick_title ,...
            'callback',@yminorstepedit,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'String',char(num2str(stepY)),'Enable',yminoreditEnable); %
        gui_erpxyaxeset_waveviewer.yminorstep_auto = uicontrol('Style','checkbox','Parent',  gui_erpxyaxeset_waveviewer.yminnortick_title,...
            'callback',@yminorstepauto,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Auto','Value',yminorautoValue,'Enable',yminorautoLabel); %
        ERPwaviewer.yaxis.yminor.disp = gui_erpxyaxeset_waveviewer.yminortick.Value;
        ERPwaviewer.yaxis.yminor.step = str2num(char(gui_erpxyaxeset_waveviewer.yminorstepedit.String));
        ERPwaviewer.yaxis.yminor.auto = gui_erpxyaxeset_waveviewer.yminorstep_auto.Value;
        set(gui_erpxyaxeset_waveviewer.yminnortick_title,'Sizes',[90 90 50]);
        
        %%-----y ticks label-----------------------------------------------
        ytickLabel = 1;
        gui_erpxyaxeset_waveviewer.ylabel_title = uiextras.HBox('Parent', gui_erpxyaxeset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_erpxyaxeset_waveviewer.ylabel_title,'String','Labels',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left'); %
        gui_erpxyaxeset_waveviewer.ylabel_on = uicontrol('Style','radiobutton','Parent',  gui_erpxyaxeset_waveviewer.ylabel_title,...
            'callback',@ylabelon,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','On','Value',ytickLabel); %
        gui_erpxyaxeset_waveviewer.ylabel_off = uicontrol('Style','radiobutton','Parent',  gui_erpxyaxeset_waveviewer.ylabel_title,...
            'callback',@ylabeloff,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Off','Value',~ytickLabel); %
        if gui_erpxyaxeset_waveviewer.ylabel_on.Value ==1
            yfontenable = 'on';
        else
            yfontenable = 'off';
        end
        uiextras.Empty('Parent',  gui_erpxyaxeset_waveviewer.ylabel_title);
        set(gui_erpxyaxeset_waveviewer.ylabel_title,'Sizes',[50 50 50 80]);
        ERPwaviewer.yaxis.label = gui_erpxyaxeset_waveviewer.ylabel_on.Value;
        
        %%-----y ticklabel:font, font size, and text color for time ticks
        ytickLabelfont = 2;
        ytickLabelfontsize = 4;
        ytickLabelfontcolor = 1;
        gui_erpxyaxeset_waveviewer.yfont_title = uiextras.HBox('Parent', gui_erpxyaxeset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent',  gui_erpxyaxeset_waveviewer.yfont_title,'String','Font',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); %
        fonttype = {'Courier','Geneva','Helvetica','Monaco','Times'};
        gui_erpxyaxeset_waveviewer.yfont_custom = uicontrol('Style','popupmenu','Parent', gui_erpxyaxeset_waveviewer.yfont_title,'String',fonttype,...
            'callback',@yaxisfont, 'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable',yfontenable,'Value',ytickLabelfont); %
        uicontrol('Style','text','Parent', gui_erpxyaxeset_waveviewer.yfont_title ,'String','Size',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); %
        yfontsize={'4','6','8','10','12','14','16','18','20','24','28','32','36',...
            '40','50','60','70','80','90','100'};
        gui_erpxyaxeset_waveviewer.yfont_custom_size = uicontrol('Style','popupmenu','Parent', gui_erpxyaxeset_waveviewer.yfont_title ,'String',yfontsize,...
            'callback',@yaxisfontsize,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable',yfontenable,'Value',ytickLabelfontsize); %
        set(gui_erpxyaxeset_waveviewer.yfont_title,'Sizes',[30 100 30 80]);
        ERPwaviewer.yaxis.font = gui_erpxyaxeset_waveviewer.yfont_custom.Value;
        ERPwaviewer.yaxis.fontsize = xfontsizeinum(gui_erpxyaxeset_waveviewer.yfont_custom_size.Value);
        
        %%% color for y ticklabel text
        gui_erpxyaxeset_waveviewer.ylabelcolor_title = uiextras.HBox('Parent', gui_erpxyaxeset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent',  gui_erpxyaxeset_waveviewer.ylabelcolor_title,'String','Color',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left'); %
        ytextColor = {'Black','Red','Blue','Green','Orange','Cyan','Magenla'};
        gui_erpxyaxeset_waveviewer.ytextcolor = uicontrol('Style','popupmenu','Parent', gui_erpxyaxeset_waveviewer.ylabelcolor_title ,'String',ytextColor,...
            'callback',@yaxisfontcolor,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable',yfontenable,'Value',ytickLabelfontcolor); %
        uiextras.Empty('Parent',  gui_erpxyaxeset_waveviewer.ylabelcolor_title);
        uiextras.Empty('Parent',  gui_erpxyaxeset_waveviewer.ylabelcolor_title);
        set(gui_erpxyaxeset_waveviewer.ylabelcolor_title,'Sizes',[40 100 30 70]);
        ERPwaviewer.yaxis.fontcolor = gui_erpxyaxeset_waveviewer.ytextcolor.Value;
        
        %%%-----------Setting for the units display of y axis---------------
        yunits = 1;
        gui_erpxyaxeset_waveviewer.yunits_title = uiextras.HBox('Parent', gui_erpxyaxeset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent',  gui_erpxyaxeset_waveviewer.yunits_title ,'String','Units',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left'); %
        gui_erpxyaxeset_waveviewer.yunits_on = uicontrol('Style','radiobutton','Parent',  gui_erpxyaxeset_waveviewer.yunits_title,...
            'callback',@yunitson,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','On','Value',yunits); %
        gui_erpxyaxeset_waveviewer.yunits_off = uicontrol('Style','radiobutton','Parent',  gui_erpxyaxeset_waveviewer.yunits_title,...
            'callback',@yunitsoff,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'String','Off','Value',~yunits); %
        uiextras.Empty('Parent',  gui_erpxyaxeset_waveviewer.yunits_title);
        set(gui_erpxyaxeset_waveviewer.yunits_title,'Sizes',[50 50 50 80]);
        ERPwaviewer.yaxis.units = gui_erpxyaxeset_waveviewer.yunits_on.Value;
        
        %%Apply and save the changed parameters
        gui_erpxyaxeset_waveviewer.help_run_title = uiextras.HBox('Parent', gui_erpxyaxeset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uiextras.Empty('Parent',gui_erpxyaxeset_waveviewer.help_run_title);
        uicontrol('Style','pushbutton','Parent', gui_erpxyaxeset_waveviewer.help_run_title ,'String','Cancel',...
            'callback',@xyaxis_help,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %,'FontWeight','bold','HorizontalAlignment','left'
        uiextras.Empty('Parent',gui_erpxyaxeset_waveviewer.help_run_title );
        gui_erpxyaxeset_waveviewer.apply = uicontrol('Style','pushbutton','Parent',gui_erpxyaxeset_waveviewer.help_run_title ,'String','Apply',...
            'callback',@xyaxis_apply,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %,'HorizontalAlignment','left'
        uiextras.Empty('Parent',gui_erpxyaxeset_waveviewer.help_run_title );
        set(gui_erpxyaxeset_waveviewer.help_run_title,'Sizes',[40 70 20 70 30]);
        
        %%save the parameters
        ALLERPwaviewer=ERPwaviewer;
        assignin('base','ALLERPwaviewer',ALLERPwaviewer);
    end

%%*********************************************************************************************************************************%%
%%----------------------------------------------Sub function-----------------------------------------------------------------------%%
%%*********************************************************************************************************************************%%

%%-------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%X axis%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%-------------------------------------------------------------------------

%%----------------------dispaly xtick labels with milliseocnd--------------
    function xmilsecond(Source,~)
        %%check if the changed parameters was saved for the other panels
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        xSecondflag = erpworkingmemory('MyViewer_xaxis_second');
        xmSecondflag =  erpworkingmemory('MyViewer_xaxis_msecond');
        xtick_precision = gui_erpxyaxeset_waveviewer.xticks_precision.Value;
        
        if xSecondflag==0 && xmSecondflag==1
            gui_erpxyaxeset_waveviewer.xmillisecond.Value =1; %display with millisecond
            gui_erpxyaxeset_waveviewer.xsecond.Value =0;
            return;
        else
            xprecisoonName = {'0','1','2','3','4','5','6'};
            if xtick_precision< 0 || xtick_precision>6
                xtick_precision =0;
            end
            gui_erpxyaxeset_waveviewer.xticks_precision.String = xprecisoonName;
            gui_erpxyaxeset_waveviewer.xticks_precision.Value =xtick_precision+1;
            
            estudioworkingmemory('MyViewer_xyaxis',1);
            gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
            gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
            box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
            
            gui_erpxyaxeset_waveviewer.xmillisecond.Value =1; %display with millisecond
            gui_erpxyaxeset_waveviewer.xsecond.Value =0;%display with second
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            if xSecondflag==1 && xmSecondflag==0
                %%transform the data with millisecond into second.
                timeArray = str2num(char(gui_erpxyaxeset_waveviewer.timerange_edit.String));
                gui_erpxyaxeset_waveviewer.timerange_edit.String = num2str(timeArray*1000);
            else
                try
                    if ERPwaviewerIN.plot_org.Pages==3
                        ERPArray = ERPwaviewerIN.SelectERPIdx;
                        ERPselectedIndex = ERPwaviewerIN.PageIndex;
                        if ERPselectedIndex> length(ERPArray)
                            ERPselectedIndex= length(ERPArray);
                        end
                        ALLERPin = ERPwaviewerIN.ALLERP;
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
                gui_erpxyaxeset_waveviewer.timerange_edit.String = num2str(timeArray);
            end
            %%change xtick labels based on the modified  x range
            xtick_precision = gui_erpxyaxeset_waveviewer.xticks_precision.Value-1;
            if xtick_precision<0
                xtick_precision =0;
            end
            timeArray = str2num(gui_erpxyaxeset_waveviewer.timerange_edit.String);% in millisecond
            timeticks = str2num(gui_erpxyaxeset_waveviewer.timeticks_edit.String);
            if ~isempty(timeticks)
                timeticks = timeticks*1000;
                timeticks= f_decimal(char(num2str(timeticks)),xtick_precision);
                gui_erpxyaxeset_waveviewer.timeticks_edit.String = timeticks;
            else
                if ~isempty(timeArray) && numel(timeArray)==2 %%&& gui_erpxyaxeset_waveviewer.xtimetickauto.Value ==1
                    [timeticks stepX]= default_time_ticks_studio(ERPwaviewerIN.ERP, timeArray);
                    if xtick_precision<0
                        xtick_precision=0;
                        gui_erpxyaxeset_waveviewer.xticks_precision.Value=1;
                    end
                    timeticks= f_decimal(char(timeticks),xtick_precision);
                    gui_erpxyaxeset_waveviewer.timeticks_edit.String = timeticks;
                end
            end
            %%change minor xtick labels based on the modified  x range
            xticks = str2num(char(gui_erpxyaxeset_waveviewer.timeticks_edit.String));%in millisecond
            stepX = str2num(gui_erpxyaxeset_waveviewer.timeminorticks_custom.String);
            if ~isempty(stepX)
                stepX = stepX.*1000;
                %                 stepX= f_decimal(char(num2str(stepX)),xtick_precision);
                gui_erpxyaxeset_waveviewer.timeminorticks_custom.String =num2str(stepX);
            else
                stepX = [];
                if ~isempty(xticks) && numel(xticks)>1
                    timeArray = str2num(char(gui_erpxyaxeset_waveviewer.timerange_edit.String));
                    xticksStr = str2num(char(gui_erpxyaxeset_waveviewer.timeticks_edit.String));
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
                if gui_erpxyaxeset_waveviewer.xtimeminorauto.Value==1 && gui_erpxyaxeset_waveviewer.timeminorticks_auto.Value==1
                    gui_erpxyaxeset_waveviewer.timeminorticks_custom.String = num2str(stepX);
                end
            end
            
            erpworkingmemory('MyViewer_xaxis_second',0);
            erpworkingmemory('MyViewer_xaxis_msecond',1);
        end
    end

%%----------------------display wave with second---------------------------
    function xsecond(Source,~)
        %%check if the changed parameters was saved for the other panels
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        xSecondflag = erpworkingmemory('MyViewer_xaxis_second');
        xmSecondflag =  erpworkingmemory('MyViewer_xaxis_msecond');
        xtick_precision = gui_erpxyaxeset_waveviewer.xticks_precision.Value-1;
        if xSecondflag==1 && xmSecondflag==0
            gui_erpxyaxeset_waveviewer.xmillisecond.Value =0; %display with millisecond
            gui_erpxyaxeset_waveviewer.xsecond.Value =1;
            return;
        else
            xprecisoonName = {'1','2','3','4','5','6'};
            gui_erpxyaxeset_waveviewer.xticks_precision.String = xprecisoonName;
            if xtick_precision<=0
                xtick_precision=1;
            end
            gui_erpxyaxeset_waveviewer.xticks_precision.Value=xtick_precision;
            estudioworkingmemory('MyViewer_xyaxis',1);
            gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
            gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
            box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
            
            gui_erpxyaxeset_waveviewer.xmillisecond.Value =0; %display with millisecond
            gui_erpxyaxeset_waveviewer.xsecond.Value =1;%display with second
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            if xSecondflag==0 && xmSecondflag==1
                %%transform the data with millisecond into second.
                timeArray = str2num(char(gui_erpxyaxeset_waveviewer.timerange_edit.String));
                gui_erpxyaxeset_waveviewer.timerange_edit.String = num2str(timeArray/1000);
            else
                try
                    
                    if ERPwaviewerIN.plot_org.Pages==3
                        ERPArray = ERPwaviewerIN.SelectERPIdx;
                        ERPselectedIndex = ERPwaviewerIN.PageIndex;
                        if ERPselectedIndex> length(ERPArray)
                            ERPselectedIndex= length(ERPArray);
                        end
                        ALLERPin = ERPwaviewerIN.ALLERP;
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
                gui_erpxyaxeset_waveviewer.timerange_edit.String = num2str(timeArray);
            end
            %%change xtick labels based on the modified  x range
            xtick_precision = gui_erpxyaxeset_waveviewer.xticks_precision.Value;
            timeArray = str2num(gui_erpxyaxeset_waveviewer.timerange_edit.String);%% in seocnd
            timeticks = str2num(char(gui_erpxyaxeset_waveviewer.timeticks_edit.String));
            if ~isempty(timeticks)
                timeticks  = timeticks/1000;%% in second
                timeticks= f_decimal(num2str(timeticks),xtick_precision);
                gui_erpxyaxeset_waveviewer.timeticks_edit.String = timeticks;%in second
            else
                if ~isempty(timeArray) && numel(timeArray)==2 %&& gui_erpxyaxeset_waveviewer.xtimetickauto.Value ==1
                    [timeticks stepX]= default_time_ticks_studio(ERPwaviewerIN.ERP, timeArray*1000);%% in millisecond
                    
                    timeticks  = num2str(str2num(char(timeticks))/1000);%% in second
                    timeticks= f_decimal(timeticks,xtick_precision);
                    gui_erpxyaxeset_waveviewer.timeticks_edit.String = timeticks;%in second
                end
            end
            
            %%change minor xtick labels based on the modified  x range
            xticks = str2num(char(gui_erpxyaxeset_waveviewer.timeticks_edit.String));%%in second
            stepX = str2num(gui_erpxyaxeset_waveviewer.timeminorticks_custom.String);
            
            if ~isempty(stepX)
                stepX = stepX/1000;
                %                 stepX= f_decimal(char(num2str(stepX)),xtick_precision);
                gui_erpxyaxeset_waveviewer.timeminorticks_custom.String =num2str(stepX);
            else
                stepX = [];
                if ~isempty(xticks) && numel(xticks)>1
                    timeArray = str2num(char(gui_erpxyaxeset_waveviewer.timerange_edit.String));%% in second
                    xticksStr = str2num(char(gui_erpxyaxeset_waveviewer.timeticks_edit.String));
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
                if gui_erpxyaxeset_waveviewer.xtimeminorauto.Value==1 && gui_erpxyaxeset_waveviewer.timeminorticks_auto.Value==1
                    gui_erpxyaxeset_waveviewer.timeminorticks_custom.String = num2str(stepX);
                end
            end
            
            erpworkingmemory('MyViewer_xaxis_second',1);
            erpworkingmemory('MyViewer_xaxis_msecond',0);
        end
    end


%%-------------------------time range auto---------------------------------
    function xtimerangeauto(strx_auto,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        Value = strx_auto.Value;
        xdisSecondValue = gui_erpxyaxeset_waveviewer.xmillisecond.Value;
        if Value==1
            try
                ALLERPwaviewer = evalin('base','ALLERPwaviewer');
                ERPwaviewer = ALLERPwaviewer;
            catch
                beep;
                disp('f_ERP_timeampscal_waveviewer_GUI() error: Please run the ERP wave viewer again.');
                return;
            end
            gui_erpxyaxeset_waveviewer.timerange_edit.Enable = 'off';
            
            try
                if ALLERPwaviewer.plot_org.Pages==3
                    ERPArray = ALLERPwaviewer.SelectERPIdx;
                    ERPselectedIndex = ALLERPwaviewer.PageIndex;
                    if ERPselectedIndex> length(ERPArray)
                        ERPselectedIndex= length(ERPArray);
                    end
                    ALLERPin = ALLERPwaviewer.ALLERP;
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
            if xdisSecondValue ==0%% in second
                timeArray = timeArray/1000;
            end
            gui_erpxyaxeset_waveviewer.timerange_edit.String = num2str(timeArray);
            if numel(timeArray)==2 && gui_erpxyaxeset_waveviewer.xtimetickauto.Value ==1
                if xdisSecondValue ==0%% in second
                    [timeticks stepX]= default_time_ticks_studio(ERPwaviewer.ERP, timeArray*1000);%% in millisecond
                    timeticks = num2str(str2num(char(timeticks))/1000);
                else
                    [timeticks stepX]= default_time_ticks_studio(ERPwaviewer.ERP, timeArray);%% in millisecond
                end
                xtick_precision = gui_erpxyaxeset_waveviewer.xticks_precision.Value-1;
                timeticks= f_decimal(char(timeticks),xtick_precision);
                gui_erpxyaxeset_waveviewer.timeticks_edit.String = char(timeticks);
            end
        else
            gui_erpxyaxeset_waveviewer.timerange_edit.Enable = 'on';
        end
    end

%%-------------------------Custom setting for time range-------------------
    function timerangecustom(Strtimcustom,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        xdisSecondValue = gui_erpxyaxeset_waveviewer.xmillisecond.Value;
        try
            ERPwaviewer = evalin('base','ALLERPwaviewer');
            ERPIN = ERPwaviewer.ERP;
            timeArray(1) = ERPwaviewer.ERP.times(1);
            timeArray(2) = ERPwaviewer.ERP.times(end);
        catch
            beep;
            disp('f_ERP_timeampscal_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        timcustom = str2num(Strtimcustom.String);
        %%checking the inputs
        if xdisSecondValue==0
            timeArray = timeArray/1000;
        end
        if numel(timcustom)==1 || isempty(timcustom)
            messgStr =  strcat('Time range in "Time and Amplitude Scales" - Inputs must be two numbers!');
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            Strtimcustom.String = num2str(timeArray);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        if timcustom(1) >= timcustom(2)
            messgStr =  strcat('Time range in "Time and Amplitude Scales" - The left edge should be smaller than the right one');
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            Strtimcustom.String = num2str(timeArray);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        if numel(timcustom)==2 && gui_erpxyaxeset_waveviewer.xtimetickauto.Value ==1
            if xdisSecondValue ==0%% in second
                [timeticks stepX]= default_time_ticks_studio(ERPwaviewer.ERP, timcustom*1000);%% in millisecond
                timeticks = num2str(str2num(char(timeticks))/1000);
            else
                [timeticks stepX]= default_time_ticks_studio(ERPwaviewer.ERP, timcustom);%% in millisecond
            end
            if gui_erpxyaxeset_waveviewer.xmillisecond.Value==1
                xtick_precision = gui_erpxyaxeset_waveviewer.xticks_precision.Value-1;
            else
                xtick_precision = gui_erpxyaxeset_waveviewer.xticks_precision.Value;
            end
            timeticks= f_decimal(char(timeticks),xtick_precision);
            gui_erpxyaxeset_waveviewer.timeticks_edit.String = char(timeticks);
        end
        
    end

%%----------------------x ticks custom-------------------------------------
    function timetickscustom(Str,~)
        ERPwaviewerIN = evalin('base','ALLERPwaviewer');
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        xdisSecondValue = gui_erpxyaxeset_waveviewer.xmillisecond.Value;
        timeArray =  str2num(gui_erpxyaxeset_waveviewer.timerange_edit.String);
        timeticksdef = '';
        if ~isempty(timeArray)
            if xdisSecondValue ==0%% in second
                [timeticks stepX]= default_time_ticks_studio(ERPwaviewerIN.ERP, timeArray*1000);%% in millisecond
                timeticksdef = num2str(str2num(char(timeticks))/1000);
            else
                [timeticksdef stepX]= default_time_ticks_studio(ERPwaviewerIN.ERP, timeArray);%% in millisecond
            end
            if gui_erpxyaxeset_waveviewer.xmillisecond.Value==1
                xtick_precision = gui_erpxyaxeset_waveviewer.xticks_precision.Value-1;
            else
                xtick_precision = gui_erpxyaxeset_waveviewer.xticks_precision.Value;
            end
            timeticksdef= f_decimal(char(timeticksdef),xtick_precision);
        end
        
        timtickcustom = str2num(char(Str.String));
        %%checking the inputs
        if isempty(timtickcustom)
            messgStr =  strcat('Time ticks in "Time and Amplitude Scales" - We used the default values because input are not numeric values');
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
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
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        Value = Str.Value;
        if Value ==1
            gui_erpxyaxeset_waveviewer.timeticks_edit.Enable = 'off';
            gui_erpxyaxeset_waveviewer.xtimetickauto.Value =1;
            
            try
                ERPwaviewer  = evalin('base','ALLERPwaviewer');
            catch
                beep;
                disp('f_ERP_timeampscal_waveviewer_GUI() error: Please run the ERP wave viewer again.');
                return;
            end
            xdisSecondValue = gui_erpxyaxeset_waveviewer.xmillisecond.Value;
            timeArray =  str2num(gui_erpxyaxeset_waveviewer.timerange_edit.String);
            if ~isempty(timeArray) && gui_erpxyaxeset_waveviewer.xtimetickauto.Value ==1%%
                if xdisSecondValue ==0%% in second
                    [timeticks stepX]= default_time_ticks_studio(ERPwaviewer.ERP, timeArray*1000);%% in millisecond
                    timeticks = num2str(str2num(char(timeticks))/1000);
                else
                    [timeticks stepX]= default_time_ticks_studio(ERPwaviewer.ERP, timeArray);%% in millisecond
                end
                if xdisSecondValue==0
                    xtick_precision = gui_erpxyaxeset_waveviewer.xticks_precision.Value;
                else
                    xtick_precision = gui_erpxyaxeset_waveviewer.xticks_precision.Value-1;
                end
                timeticks= f_decimal(char(timeticks),xtick_precision);
                gui_erpxyaxeset_waveviewer.timeticks_edit.String = timeticks;
            end
        else
            gui_erpxyaxeset_waveviewer.timeticks_edit.Enable = 'on';
            gui_erpxyaxeset_waveviewer.xtimetickauto.Value = 0;
        end
    end

%%--------------------change decimals of x tick labels---------------------
    function xticksprecison(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        
        if gui_erpxyaxeset_waveviewer.xmillisecond.Value==1
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
        
        timeticks = str2num(char(gui_erpxyaxeset_waveviewer.timeticks_edit.String));
        if ~isempty(timeticks)
            timeticks= f_decimal(char(num2str(timeticks)),xtick_precision);
            gui_erpxyaxeset_waveviewer.timeticks_edit.String = timeticks;
        end
        
    end

%%---------------------display xtick minor or not--------------------------
    function timeminortickslabel(Str,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        Value = Str.Value;
        if Value ==1
            gui_erpxyaxeset_waveviewer.timeminorticks_auto.Enable = 'on';
            if gui_erpxyaxeset_waveviewer.timeminorticks_auto.Value ==1
                gui_erpxyaxeset_waveviewer.timeminorticks_custom.Enable = 'off';
            else
                gui_erpxyaxeset_waveviewer.timeminorticks_custom.Enable = 'on';
            end
        else
            gui_erpxyaxeset_waveviewer.timeminorticks_auto.Enable = 'off';
            gui_erpxyaxeset_waveviewer.timeminorticks_custom.Enable = 'off';
        end
        
        Value = Str.Value;
        xticks = str2num(char(gui_erpxyaxeset_waveviewer.timeticks_edit.String));
        stepX = [];
        if ~isempty(xticks) && numel(xticks)>1
            timeArray = str2num(char(gui_erpxyaxeset_waveviewer.timerange_edit.String));
            xticksStr = str2num(char(gui_erpxyaxeset_waveviewer.timeticks_edit.String));
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
        if Value==1 && gui_erpxyaxeset_waveviewer.timeminorticks_auto.Value==1
            gui_erpxyaxeset_waveviewer.timeminorticks_custom.String = num2str(stepX);
        end
        
    end

%%--------------------------custom step for minor xtick--------------------
    function timeminorticks_custom(Str,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        Str_xtick_minor = str2num(Str.String);
        if isempty(Str_xtick_minor)
            messgStr =  strcat('Minor ticks for "X Axs" in "Time and Amplitude Scales" - Input must be numeric ');
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
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
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        Value = Str.Value;
        xticks = str2num(char(gui_erpxyaxeset_waveviewer.timeticks_edit.String));
        stepX = [];
        if ~isempty(xticks) && numel(xticks)>1
            timeArray = str2num(char(gui_erpxyaxeset_waveviewer.timerange_edit.String));
            xticksStr = str2num(char(gui_erpxyaxeset_waveviewer.timeticks_edit.String));
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
            gui_erpxyaxeset_waveviewer.timeminorticks_custom.Enable = 'off';
            gui_erpxyaxeset_waveviewer.timeminorticks_custom.String = num2str(stepX);
        else
            gui_erpxyaxeset_waveviewer.timeminorticks_custom.Enable = 'on';
        end
    end


%%--------------------Setting for time tick label:on-----------------------
    function xtimelabelon(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_erpxyaxeset_waveviewer.xtimelabel_on.Value = 1;
        gui_erpxyaxeset_waveviewer.xtimelabel_off.Value = 0;
        gui_erpxyaxeset_waveviewer.xtimefont_custom.Enable = 'on';
        gui_erpxyaxeset_waveviewer.font_custom_size.Enable = 'on';
        gui_erpxyaxeset_waveviewer.xtimetextcolor.Enable = 'on';
    end

%%--------------------Setting for time tick label:on-----------------------
    function xtimelabeloff(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_erpxyaxeset_waveviewer.xtimelabel_on.Value = 0;
        gui_erpxyaxeset_waveviewer.xtimelabel_off.Value = 1;
        gui_erpxyaxeset_waveviewer.xtimefont_custom.Enable = 'off';
        gui_erpxyaxeset_waveviewer.font_custom_size.Enable = 'off';
        gui_erpxyaxeset_waveviewer.xtimetextcolor.Enable = 'off';
    end

%%----------------------font of x labelticks-------------------------------
    function xtimefont(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
    end

%%---------------------fontsize of x labelticks----------------------------
    function xtimefontsize(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
    end
%%---------------------color of x labelticks-------------------------------
    function xtimecolor(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
    end

%%------------------Setting for units:on-----------------------------------
    function xtimeunitson(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_erpxyaxeset_waveviewer.xtimeunits_on.Value = 1;
        gui_erpxyaxeset_waveviewer.xtimeunits_off.Value = 0;
    end

%%------------------Setting for units:off----------------------------------
    function xtimeunitsoff(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_erpxyaxeset_waveviewer.xtimeunits_on.Value = 0;
        gui_erpxyaxeset_waveviewer.xtimeunits_off.Value = 1;
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
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        yscalecustom = str2num(char(yscalStr.String));
        %%checking the inputs
        if isempty(yscalecustom)|| numel(yscalecustom)==1
            messgStr =  strcat('Y scale for "Y Axs" in "Time and Amplitude Scales" - Inputs must be two numbers ');
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        
        if yscalecustom(1) >= yscalecustom(2)
            messgStr =  strcat('Y scale for "Y Axs" in "Time and Amplitude Scales" - The left edge should be smaller than the right one ');
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        if ~isempty(yscalecustom) && numel(yscalecustom)==2 && yscalecustom(1) < yscalecustom(2) && gui_erpxyaxeset_waveviewer.ytickauto.Value==1
            yticksLabel = default_amp_ticks_viewer(yscalecustom);
            ytick_precision = gui_erpxyaxeset_waveviewer.yticks_precision.Value-1;
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
            gui_erpxyaxeset_waveviewer.yticks_edit.String = yticksLabel;
        end
        
    end

%%--------------------Y Scale Auto-----------------------------------------
    function yrangeauto(yscaleauto,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        Value = yscaleauto.Value;
        if Value ==1
            try
                ALLERPwaviewer = evalin('base','ALLERPwaviewer');
                ERPwaviewer = ALLERPwaviewer;
            catch
                beep;
                disp('f_ERP_timeampscal_waveviewer_GUI() error: Please run the ERP wave viewer again.');
                return;
            end
            ALLERPIN = ERPwaviewer.ALLERP;
            ERPArrayin = ERPwaviewer.SelectERPIdx;
            BinArrayIN = [];
            ChanArrayIn = [];
            plotOrg = [1 2 3];
            try
                plotOrg(1) = ERPwaviewer.plot_org.Grid;
                plotOrg(2) = ERPwaviewer.plot_org.Overlay;
                plotOrg(3) = ERPwaviewer.plot_org.Pages;
            catch
                plotOrg = [1 2 3];
            end
            try
                ChanArrayIn = ERPwaviewer.chan;
            catch
                ChanArrayIn = [];
            end
            try
                BinArrayIN = ERPwaviewer.bin;
            catch
                BinArrayIN = [];
            end
            PageCurrent =  ERPwaviewer.PageIndex;
            yylim_out = f_erpAutoYLim(ALLERPIN, ERPArrayin,plotOrg,BinArrayIN, ChanArrayIn);
            try
                yRangeLabel = num2str(yylim_out(PageCurrent,:));
            catch
                yRangeLabel = num2str(yylim_out(1,:));
            end
            gui_erpxyaxeset_waveviewer.yrange_edit.String =yRangeLabel;
            gui_erpxyaxeset_waveviewer.yrange_edit.Enable = 'off';
        else
            gui_erpxyaxeset_waveviewer.yrange_edit.Enable = 'on';
        end
        
        yscalecustom = str2num(gui_erpxyaxeset_waveviewer.yrange_edit.String);
        if ~isempty(yscalecustom) && numel(yscalecustom)==2 && yscalecustom(1) < yscalecustom(2)
            yticksLabel = default_amp_ticks_viewer(yscalecustom);
            ytick_precision = gui_erpxyaxeset_waveviewer.yticks_precision.Value-1;
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
            gui_erpxyaxeset_waveviewer.yticks_edit.String = yticksLabel;
        end
        
        
    end

%%----------------------Y ticks--------------------------------------------
    function ytickscustom(Str,~)
        ERPwaviewerIN = evalin('base','ALLERPwaviewer');
        yticksLabel = ERPwaviewerIN.yaxis.ticks;
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        ytickcustom = str2num(char(Str.String));
        %%checking the inputs
        if isempty(ytickcustom)
            messgStr =  strcat('Y ticks on "Time and Amplitude Scales": Input must be a number!');
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            Str.String = '';
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        yRange = str2num(char(gui_erpxyaxeset_waveviewer.yrange_edit.String));
        %%checking if the time sticks exceed the time range
        if ~isempty(yRange) && numel(yRange) ==2
            if min(ytickcustom(:))< yRange(1)%% compared with the left edge of time range
                messgStr =  strcat('Y ticks in "Time and Amplitude Scales": Minimum of Y ticks should be larger than the left edge of y scale!');
                erpworkingmemory('ERPViewer_proces_messg',messgStr);
                fprintf(2,['\n Warning: ',messgStr,'.\n']);
                Str.String = '';
                viewer_ERPDAT.Process_messg =4;
                return;
            end
            if max(ytickcustom(:))>yRange(2)%% compared with the right edge of time range
                messgStr =  strcat('Y ticks in "Time and Amplitude Scales": Maximum of Y ticks should be smaller than the right edge of y scale!');
                erpworkingmemory('ERPViewer_proces_messg',messgStr);
                fprintf(2,['\n Warning: ',messgStr,'.\n']);
                Str.String = '';
                viewer_ERPDAT.Process_messg =4;
                return;
            end
            yticksLabel = char(Str.String);
            ytick_precision = gui_erpxyaxeset_waveviewer.yticks_precision.Value-1;
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
            gui_erpxyaxeset_waveviewer.yticks_edit.String = yticksLabel;
        end
    end

%%----------------------------Y ticks auto---------------------------------
    function ytickauto(Str,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        Value = Str.Value;
        if Value ==1
            yRangeLabel = str2num(char(gui_erpxyaxeset_waveviewer.yrange_edit.String));
            if ~isempty(yRangeLabel) && numel(yRangeLabel) ==2 && (yRangeLabel(1)<yRangeLabel(2))
                yticksLabel = default_amp_ticks_viewer(yRangeLabel);
                ytick_precision = gui_erpxyaxeset_waveviewer.yticks_precision.Value-1;
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
                gui_erpxyaxeset_waveviewer.yticks_edit.String = yticksLabel;
                
            end
            gui_erpxyaxeset_waveviewer.yticks_edit.Enable = 'off';
        else
            gui_erpxyaxeset_waveviewer.yticks_edit.Enable = 'on';
        end
    end


%%--------------------y scale decision-------------------------------------
    function yticksprecison(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        yticksLabel =  gui_erpxyaxeset_waveviewer.yticks_edit.String;
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
        gui_erpxyaxeset_waveviewer.yticks_edit.String = yticksLabel;
        
    end

%%--------------------display ytick minor?---------------------------------
    function yminordisp(Str,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        Value = Str.Value;
        if Value ==1
            gui_erpxyaxeset_waveviewer.yminorstep_auto.Enable = 'on';
            if gui_erpxyaxeset_waveviewer.yminorstep_auto.Value ==1
                gui_erpxyaxeset_waveviewer.yminorstepedit.Enable = 'off';
            else
                gui_erpxyaxeset_waveviewer.yminorstepedit.Enable = 'on';
            end
            
            if gui_erpxyaxeset_waveviewer.yminorstep_auto.Value ==1
                yticksStr = str2num(char(gui_erpxyaxeset_waveviewer.yticks_edit.String));
                stepY = [];
                yscaleRange =  str2num(char(gui_erpxyaxeset_waveviewer.yrange_edit.String));
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
                gui_erpxyaxeset_waveviewer.yminorstepedit.String = num2str(stepY);
            end
        else
            gui_erpxyaxeset_waveviewer.yminorstepedit.Enable = 'off';
            gui_erpxyaxeset_waveviewer.yminorstep_auto.Enable = 'off';
        end
    end

%%---------------------custom edit the step of minor yticks----------------
    function yminorstepedit(Str,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        ytickmin_step = str2num(Str.String);
        if isempty(ytickmin_step)
            messgStr =  strcat('Minor ticks for "Y Axs" in "Time and Amplitude Scales": Input must be one number or more numbers');
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
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
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        Value = Str.Value;%%
        if Value ==1
            yticksStr = str2num(char(gui_erpxyaxeset_waveviewer.yticks_edit.String));
            stepY = [];
            yscaleRange =  str2num(char(gui_erpxyaxeset_waveviewer.yrange_edit.String));
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
            gui_erpxyaxeset_waveviewer.yminorstepedit.String = num2str(stepY);
            gui_erpxyaxeset_waveviewer.yminorstepedit.Enable = 'off';
        else
            gui_erpxyaxeset_waveviewer.yminorstepedit.Enable = 'on';
        end
    end

%%------------------------------Y label:on---------------------------------
    function ylabelon(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_erpxyaxeset_waveviewer.ylabel_on.Value = 1;
        gui_erpxyaxeset_waveviewer.ylabel_off.Value = 0;
        gui_erpxyaxeset_waveviewer.yfont_custom.Enable = 'on';
        gui_erpxyaxeset_waveviewer.yfont_custom_size.Enable = 'on';
        gui_erpxyaxeset_waveviewer.ytextcolor.Enable = 'on';
    end


%%------------------------font of y labelticks-----------------------------
    function yaxisfont(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
    end

%%------------------------fontsize of y label ticks------------------------
    function yaxisfontsize(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
    end

%%------------------------color of y label ticks---------------------------
    function yaxisfontcolor(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
    end


%%------------------------------Y label:off--------------------------------
    function ylabeloff(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_erpxyaxeset_waveviewer.ylabel_on.Value = 0;
        gui_erpxyaxeset_waveviewer.ylabel_off.Value = 1;
        gui_erpxyaxeset_waveviewer.yfont_custom.Enable = 'off';
        gui_erpxyaxeset_waveviewer.yfont_custom_size.Enable = 'off';
        gui_erpxyaxeset_waveviewer.ytextcolor.Enable = 'off';
    end

%%---------------------------Y units:on------------------------------------
    function yunitson(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_erpxyaxeset_waveviewer.yunits_on.Value = 1;
        gui_erpxyaxeset_waveviewer.yunits_off.Value = 0;
    end

%%---------------------------Y units:off-----------------------------------
    function yunitsoff(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_xyaxis',1);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpxtaxes_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_erpxyaxeset_waveviewer.yunits_on.Value = 0;
        gui_erpxyaxeset_waveviewer.yunits_off.Value = 1;
    end


%%-----------------------help----------------------------------------------
    function xyaxis_help(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        
        changeFlag =  estudioworkingmemory('MyViewer_xyaxis');
        if changeFlag~=1%% Donot reset this panel if there is no change
            return;
        end
        try
            ERPwaviewer_apply = evalin('base','ALLERPwaviewer');
        catch
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n Time and Amplitude Scales > Cancel-f_ERP_timeampscal_waveviewer_GUI() error: Cannot get parameters for whole panel.\n Please run My viewer again.\n\n');
            return;
        end
        xdispsecondValue =  ERPwaviewer_apply.xaxis.tdis;
        if xdispsecondValue==1%% with millisecond
            gui_erpxyaxeset_waveviewer.xmillisecond.Value  =1;
            gui_erpxyaxeset_waveviewer.xsecond.Value  = 0;
            xprecisoonName = {'0','1','2','3','4','5','6'};
            gui_erpxyaxeset_waveviewer.xticks_precision.String = xprecisoonName;
        else%% with second
            gui_erpxyaxeset_waveviewer.xmillisecond.Value  =0;
            gui_erpxyaxeset_waveviewer.xsecond.Value  = 1;
            xprecisoonName = {'1','2','3','4','5','6'};
            gui_erpxyaxeset_waveviewer.xticks_precision.String = xprecisoonName;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%-------------------------time range------------------------------
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if xdispsecondValue==1
            gui_erpxyaxeset_waveviewer.timerange_edit.String = num2str(ERPwaviewer_apply.xaxis.timerange);
        else
            gui_erpxyaxeset_waveviewer.timerange_edit.String = num2str(ERPwaviewer_apply.xaxis.timerange/1000);
        end
        TRFlag =  ERPwaviewer_apply.xaxis.trangeauto;
        if TRFlag==1
            gui_erpxyaxeset_waveviewer.xtimerangeauto.Value = 1 ;
            gui_erpxyaxeset_waveviewer.timerange_edit.Enable = 'off';
        else
            gui_erpxyaxeset_waveviewer.xtimerangeauto.Value = 0 ;
            gui_erpxyaxeset_waveviewer.timerange_edit.Enable = 'on';
        end
        xticks_precision = ERPwaviewer_apply.xaxis.tickdecimals;
        %%time ticks
        if xdispsecondValue==1
            timeticks= ERPwaviewer_apply.xaxis.timeticks;
            if ~isempty(timeticks)
                timeticks= f_decimal(char(num2str(timeticks)),xticks_precision);
            else
                timeticks = '';
            end
            gui_erpxyaxeset_waveviewer.timeticks_edit.String  = timeticks;
            gui_erpxyaxeset_waveviewer.xticks_precision.Value = xticks_precision+1;
        else
            timeticks= ERPwaviewer_apply.xaxis.timeticks/1000;%%Convert character array or string scalar to numeric array
            if ~isempty(timeticks)
                timeticks= f_decimal(char(num2str(timeticks)),xticks_precision);
            else
                timeticks = '';
            end
            gui_erpxyaxeset_waveviewer.timeticks_edit.String  = timeticks;
            gui_erpxyaxeset_waveviewer.xticks_precision.Value = xticks_precision;
        end
        xtickAuto = ERPwaviewer_apply.xaxis.ticksauto;
        gui_erpxyaxeset_waveviewer.xtimetickauto.Value=xtickAuto;
        if xtickAuto==1
            gui_erpxyaxeset_waveviewer.timeticks_edit.Enable = 'off';
        else
            gui_erpxyaxeset_waveviewer.timeticks_edit.Enable = 'on';
        end
        %%minor for xticks
        XMinorDis = ERPwaviewer_apply.xaxis.tminor.disp;
        xMinorAuto = ERPwaviewer_apply.xaxis.tminor.auto;
        gui_erpxyaxeset_waveviewer.xtimeminorauto.Value = XMinorDis;
        if xMinorAuto==1
            gui_erpxyaxeset_waveviewer.timeminorticks_auto.Value =1;
            gui_erpxyaxeset_waveviewer.timeminorticks_custom.Enable = 'off';
        else
            gui_erpxyaxeset_waveviewer.timeminorticks_auto.Value =0;
            gui_erpxyaxeset_waveviewer.timeminorticks_custom.Enable = 'on';
        end
        if XMinorDis==1
            if xMinorAuto==1
                gui_erpxyaxeset_waveviewer.timeminorticks_custom.Enable = 'off';
            else
                gui_erpxyaxeset_waveviewer.timeminorticks_custom.Enable = 'on';
            end
            gui_erpxyaxeset_waveviewer.timeminorticks_auto.Enable = 'on';
        else
            gui_erpxyaxeset_waveviewer.timeminorticks_custom.Enable = 'off';
            gui_erpxyaxeset_waveviewer.timeminorticks_auto.Enable = 'off';
        end
        xtickMinorstep = ERPwaviewer_apply.xaxis.tminor.step;
        if xdispsecondValue==0
            xtickMinorstep= xtickMinorstep/1000;%%Convert character array or string scalar to numeric array
        end
        if ~isempty(xtickMinorstep)
            xtickMinorstep= f_decimal(char(num2str(xtickMinorstep)),xticks_precision);
        else
            xtickMinorstep = '';
        end
        gui_erpxyaxeset_waveviewer.timeminorticks_custom.String = xtickMinorstep;
        %%x labels
        xlabelFlag = ERPwaviewer_apply.xaxis.label;
        gui_erpxyaxeset_waveviewer.xtimelabel_on.Value = xlabelFlag;
        gui_erpxyaxeset_waveviewer.xtimelabel_off.Value = ~xlabelFlag;
        gui_erpxyaxeset_waveviewer.xtimefont_custom.Value = ERPwaviewer_apply.xaxis.font;
        fontsize  = {'4','6','8','10','12','14','16','18','20','24','28','32','36',...
            '40','50','60','70','80','90','100'};
        xfontsizeinum = str2num(char(fontsize));
        xlabelfontsize =  ERPwaviewer_apply.xaxis.fontsize;
        [x_label,~] = find(xfontsizeinum==xlabelfontsize);
        if isempty(x_label)
            x_label=5;
        end
        gui_erpxyaxeset_waveviewer.font_custom_size.Value = x_label;
        gui_erpxyaxeset_waveviewer.xtimetextcolor.Value = ERPwaviewer_apply.xaxis.fontcolor;
        if xlabelFlag==1
            xlabelFlagEnable = 'on';
        else
            xlabelFlagEnable = 'off';
        end
        gui_erpxyaxeset_waveviewer.xtimefont_custom.Enable = xlabelFlagEnable;
        gui_erpxyaxeset_waveviewer.font_custom_size.Enable = xlabelFlagEnable;
        gui_erpxyaxeset_waveviewer.xtimetextcolor.Enable = xlabelFlagEnable;
        %%x units
        xaxisunits= ERPwaviewer_apply.xaxis.units;
        gui_erpxyaxeset_waveviewer.xtimeunits_on.Value =xaxisunits;
        gui_erpxyaxeset_waveviewer.xtimeunits_off.Value = ~xaxisunits;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%------------------------setting for y axes-----------------------
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        gui_erpxyaxeset_waveviewer.yrange_edit.String = num2str(ERPwaviewer_apply.yaxis.scales);
        gui_erpxyaxeset_waveviewer.yrangeauto.Value = ERPwaviewer_apply.yaxis.scalesauto;
        if gui_erpxyaxeset_waveviewer.yrangeauto.Value==1
            gui_erpxyaxeset_waveviewer.yrange_edit.Enable = 'off';
        else
            gui_erpxyaxeset_waveviewer.yrange_edit.Enable = 'on';
        end
        ytickdecimals = ERPwaviewer_apply.yaxis.tickdecimals;
        gui_erpxyaxeset_waveviewer.yticks_precision.Value = ytickdecimals+1;
        YTicks=ERPwaviewer_apply.yaxis.ticks;
        if ~isempty(YTicks)
            YTicks= f_decimal(char(num2str(YTicks)),ytickdecimals);
        else
            YTicks = '';
        end
        gui_erpxyaxeset_waveviewer.yticks_edit.String = YTicks;
        
        gui_erpxyaxeset_waveviewer.ytickauto.Value=ERPwaviewer_apply.yaxis.tickauto ;
        if gui_erpxyaxeset_waveviewer.ytickauto.Value==1
            gui_erpxyaxeset_waveviewer.yticks_edit.Enable = 'off';
        else
            gui_erpxyaxeset_waveviewer.yticks_edit.Enable = 'on';
        end
        %%minor yticks
        yMinorDisp= ERPwaviewer_apply.yaxis.yminor.disp;
        yMinorAuto = ERPwaviewer_apply.yaxis.yminor.auto;
        if yMinorDisp==1
            gui_erpxyaxeset_waveviewer.yminortick.Value=1;
            gui_erpxyaxeset_waveviewer.yminorstep_auto.Enable = 'on';
            if yMinorAuto==1
                gui_erpxyaxeset_waveviewer.yminorstepedit.Enable = 'off';
            else
                gui_erpxyaxeset_waveviewer.yminorstepedit.Enable = 'on';
            end
        else
            gui_erpxyaxeset_waveviewer.yminortick.Value=0;
            gui_erpxyaxeset_waveviewer.yminorstep_auto.Enable = 'off';
            gui_erpxyaxeset_waveviewer.yminorstepedit.Enable = 'off';
        end
        gui_erpxyaxeset_waveviewer.yminorstep_auto.Value = yMinorAuto;
        gui_erpxyaxeset_waveviewer.yminorstepedit.String = num2str(ERPwaviewer_apply.yaxis.yminor.step);
        
        gui_erpxyaxeset_waveviewer.ylabel_on.Value = ERPwaviewer_apply.yaxis.label;
        gui_erpxyaxeset_waveviewer.ylabel_off.Value = ~ERPwaviewer_apply.yaxis.label;
        gui_erpxyaxeset_waveviewer.yfont_custom.Value =ERPwaviewer_apply.yaxis.font;
        ylabelFontsize =  ERPwaviewer_apply.yaxis.fontsize;
        [yx_label,~] = find(xfontsizeinum==ylabelFontsize);
        if isempty(yx_label)
            yx_label=5;
        end
        gui_erpxyaxeset_waveviewer.yfont_custom_size.Value = yx_label;
        gui_erpxyaxeset_waveviewer.ytextcolor.Value= ERPwaviewer_apply.yaxis.fontcolor;
        if gui_erpxyaxeset_waveviewer.ylabel_on.Value==1
            ylabelFlagEnable = 'on';
        else
            ylabelFlagEnable = 'off';
        end
        gui_erpxyaxeset_waveviewer.yfont_custom.Enable = ylabelFlagEnable;
        gui_erpxyaxeset_waveviewer.yfont_custom_size.Enable = ylabelFlagEnable;
        gui_erpxyaxeset_waveviewer.ytextcolor.Enable = ylabelFlagEnable;
        
        gui_erpxyaxeset_waveviewer.yunits_on.Value = ERPwaviewer_apply.yaxis.units;
        gui_erpxyaxeset_waveviewer.yunits_off.Value = ~ERPwaviewer_apply.yaxis.units;
        estudioworkingmemory('MyViewer_xyaxis',0);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [1 1 1];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [0 0 0];
        box_erpxtaxes_viewer_property.TitleColor= [0.5 0.5 0.9];
    end

%%-----------------------------Apply---------------------------------------
    function xyaxis_apply(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=3
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        
        estudioworkingmemory('MyViewer_xyaxis',0);
        gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [1 1 1];
        gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [0 0 0];
        box_erpxtaxes_viewer_property.TitleColor= [0.5 0.5 0.9];
        
        MessageViewer= char(strcat('Time and Amplitude Scales > Apply'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        try
            ERPwaviewer_apply = evalin('base','ALLERPwaviewer');
        catch
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n Time and Amplitude Scales > Apply-f_ERP_timeampscal_waveviewer_GUI() error: Cannot get parameters for whole panel.\n Please run My viewer again.\n\n');
            return;
        end
        %%time range
        xdispsecondValue = gui_erpxyaxeset_waveviewer.xmillisecond.Value; %display with millisecond
        if xdispsecondValue==1
            timeRange = str2num(gui_erpxyaxeset_waveviewer.timerange_edit.String);%get the time range for plotting and check it
        else
            timeRange = str2num(gui_erpxyaxeset_waveviewer.timerange_edit.String)*1000;
        end
        
        if numel(timeRange)==1 || isempty(timeRange)
            timeRange(1) = ERPwaviewer_apply.ERP.times(1);
            timeRange(2) = ERPwaviewer_apply.ERP.times(end);
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n Time and Amplitude Scales > Apply-Time range() error.\n Inputs must be two numbers! Please change it, otherwise, the default values will be used.\n\n');
            %             return;
        end
        if timeRange(1) >= timeRange(2)
            timeRange(1) = ERPwaviewer_apply.ERP.times(1);
            timeRange(2) = ERPwaviewer_apply.ERP.times(end);
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n Time and Amplitude Scales > Apply-Time range() error.\n The left edge should not be smaller than the right one!\n Please change current values, otherwise, the default ones will be used!\n\n');
            %             return;
        end
        ERPwaviewer_apply.xaxis.timerange = timeRange;
        ERPwaviewer_apply.xaxis.trangeauto = gui_erpxyaxeset_waveviewer.xtimerangeauto.Value;
        ERPwaviewer_apply.xaxis.tdis = xdispsecondValue;
        %%getting xticks
        if xdispsecondValue==1
            xticksArray = str2num(char(gui_erpxyaxeset_waveviewer.timeticks_edit.String));
        else
            xticksArray = str2num(char(gui_erpxyaxeset_waveviewer.timeticks_edit.String))*1000;%%transform into millisecond
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
        ERPwaviewer_apply.xaxis.timeticks = xticksArray;
        ERPwaviewer_apply.xaxis.ticksauto = gui_erpxyaxeset_waveviewer.xtimetickauto.Value;
        if gui_erpxyaxeset_waveviewer.xmillisecond.Value==1
            ERPwaviewer_apply.xaxis.tickdecimals = gui_erpxyaxeset_waveviewer.xticks_precision.Value-1;
        else
            ERPwaviewer_apply.xaxis.tickdecimals = gui_erpxyaxeset_waveviewer.xticks_precision.Value;
        end
        
        %%minor for xticks
        ERPwaviewer_apply.xaxis.tminor.disp = gui_erpxyaxeset_waveviewer.xtimeminorauto.Value;
        xticckMinorstep = str2num(char(gui_erpxyaxeset_waveviewer.timeminorticks_custom.String));
        if xdispsecondValue==1
            ERPwaviewer_apply.xaxis.tminor.step = xticckMinorstep;
        else
            ERPwaviewer_apply.xaxis.tminor.step = xticckMinorstep*1000;
        end
        ERPwaviewer_apply.xaxis.tminor.auto = gui_erpxyaxeset_waveviewer.timeminorticks_auto.Value;
        %%xtick label on/off
        ERPwaviewer_apply.xaxis.label = gui_erpxyaxeset_waveviewer.xtimelabel_on.Value;
        fontsize  = {'4','6','8','10','12','14','16','18','20','24','28','32','36',...
            '40','50','60','70','80','90','100'};
        xfontsizeinum = str2num(char(fontsize));
        ERPwaviewer_apply.xaxis.font = gui_erpxyaxeset_waveviewer.xtimefont_custom.Value;
        ERPwaviewer_apply.xaxis.fontsize = xfontsizeinum(gui_erpxyaxeset_waveviewer.font_custom_size.Value);
        ERPwaviewer_apply.xaxis.fontcolor = gui_erpxyaxeset_waveviewer.xtimetextcolor.Value;
        ERPwaviewer_apply.xaxis.units = gui_erpxyaxeset_waveviewer.xtimeunits_on.Value;
        %%y scales
        YScales = str2num(char(gui_erpxyaxeset_waveviewer.yrange_edit.String));
        if isempty(YScales)
            ALLERPIN = ERPwaviewer_apply.ALLERP;
            ERPArrayin = ERPwaviewer_apply.SelectERPIdx;
            BinArrayIN = [];
            ChanArrayIn = [];
            plotOrg = [1 2 3];
            try
                plotOrg(1) = ERPwaviewer_apply.plot_org.Grid;
                plotOrg(2) = ERPwaviewer_apply.plot_org.Overlay;
                plotOrg(3) = ERPwaviewer_apply.plot_org.Pages;
            catch
                plotOrg = [1 2 3];
            end
            try
                ChanArrayIn = ERPwaviewer_apply.chan;
            catch
                ChanArrayIn = [];
            end
            try
                BinArrayIN = ERPwaviewer_apply.bin;
            catch
                BinArrayIN = [];
            end
            PageCurrent =  ERPwaviewer_apply.PageIndex;
            yylim_out = f_erpAutoYLim(ALLERPIN, ERPArrayin,plotOrg,BinArrayIN, ChanArrayIn);
            YScales = [];
            try
                YScales = yylim_out(PageCurrent,:);
            catch
                YScales = yylim_out(1,:);
            end
        end
        ERPwaviewer_apply.yaxis.scales =YScales ;
        ERPwaviewer_apply.yaxis.scalesauto = gui_erpxyaxeset_waveviewer.yrangeauto.Value;
        %%yticks
        YTicks = str2num(char(gui_erpxyaxeset_waveviewer.yticks_edit.String));
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
        ERPwaviewer_apply.yaxis.tickdecimals = gui_erpxyaxeset_waveviewer.yticks_precision.Value-1;
        ERPwaviewer_apply.yaxis.ticks = YTicks;
        ERPwaviewer_apply.yaxis.tickauto = gui_erpxyaxeset_waveviewer.ytickauto.Value;
        %%minor yticks
        ERPwaviewer_apply.yaxis.yminor.disp = gui_erpxyaxeset_waveviewer.yminortick.Value;
        ERPwaviewer_apply.yaxis.yminor.step = str2num(char(gui_erpxyaxeset_waveviewer.yminorstepedit.String));
        ERPwaviewer_apply.yaxis.yminor.auto = gui_erpxyaxeset_waveviewer.yminorstep_auto.Value;
        %%y labels: on/off
        ERPwaviewer_apply.yaxis.label = gui_erpxyaxeset_waveviewer.ylabel_on.Value;
        %%yticks: font and font size
        ERPwaviewer_apply.yaxis.font = gui_erpxyaxeset_waveviewer.yfont_custom.Value;
        yfontsizeinum = str2num(char(fontsize));
        ERPwaviewer_apply.yaxis.fontsize = yfontsizeinum(gui_erpxyaxeset_waveviewer.yfont_custom_size.Value);
        %%yticks color
        ERPwaviewer_apply.yaxis.fontcolor = gui_erpxyaxeset_waveviewer.ytextcolor.Value;
        %%y units
        ERPwaviewer_apply.yaxis.units = gui_erpxyaxeset_waveviewer.yunits_on.Value;
        %%save the parameters
        ALLERPwaviewer=ERPwaviewer_apply;
        assignin('base','ALLERPwaviewer',ALLERPwaviewer);
        f_redrawERP_viewer_test();
        viewer_ERPDAT.Process_messg =2;%% complete
    end


%%------------change this panel based on the changed ERPsets---------------
    function v_currentERP_change(~,~)
        if viewer_ERPDAT.Count_currentERP == 0
            return;
        end
        try
            ERPwaviewer_apply = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp('f_ERP_timeampscal_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        
        try
            ERPIN = ERPwaviewer_apply.ERP;
            timeArray(1) = ERPwaviewer_apply.ERP.times(1);
            timeArray(2) = ERPwaviewer_apply.ERP.times(end);
            [timeticks stepX]= default_time_ticks_studio(ERPIN, [timeArray(1),timeArray(2)]);
            if ~isempty(stepX) && numel(stepX) ==1
                stepX = floor(stepX/2);
            end
        catch
            timeticks = [];
            timeArray = [];
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%----------------------------Setting for X axis-------------------
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        xSecondflag = erpworkingmemory('MyViewer_xaxis_second');
        xmSecondflag =  erpworkingmemory('MyViewer_xaxis_msecond');
        if isempty(xSecondflag) && isempty(xmSecondflag)
            xdispysecondValue =  gui_erpxyaxeset_waveviewer.xmillisecond.Value;%%millisecond
        end
        if xSecondflag ==0 && xmSecondflag==1
            xdispysecondValue =1;
            if gui_erpxyaxeset_waveviewer.xtimerangeauto.Value==1
                if xdispysecondValue==1
                    gui_erpxyaxeset_waveviewer.timerange_edit.String = num2str(timeArray);
                    gui_erpxyaxeset_waveviewer.xticks_precision.String = {'0','1','2','3','4','5','6'};
                else
                    gui_erpxyaxeset_waveviewer.timerange_edit.String = num2str(timeArray/1000);
                    gui_erpxyaxeset_waveviewer.xticks_precision.String = {'1','2','3','4','5','6'};
                end
            end
        else
            xdispysecondValue =0;
        end
        if xdispysecondValue==1
            xtick_precision =gui_erpxyaxeset_waveviewer.xticks_precision.Value-1;
            if xtick_precision<0
                xtick_precision =0;
                gui_erpxyaxeset_waveviewer.xticks_precision.Value=1;
            end
        else
            xtick_precision =gui_erpxyaxeset_waveviewer.xticks_precision.Value;
            if xtick_precision<=0
                xtick_precision =1;
                gui_erpxyaxeset_waveviewer.xticks_precision.Value=1;
            end
        end
        if gui_erpxyaxeset_waveviewer.xtimetickauto.Value ==1
            if xdispysecondValue==0
                timetickstrs = num2str(str2num(char(timeticks))/1000);
            else
                timetickstrs = timeticks;
            end
            timetickstrs= f_decimal(char(timetickstrs),xtick_precision);
            gui_erpxyaxeset_waveviewer.timeticks_edit.String = char(timetickstrs);
        end
        ERPwaviewer_apply.xaxis.tickdecimals = xtick_precision;
        
        %%X minor ticks
        stepX = [];
        timeArray = str2num(char(gui_erpxyaxeset_waveviewer.timerange_edit.String));
        xticksStr = str2num(char(gui_erpxyaxeset_waveviewer.timeticks_edit.String));
        if xdispysecondValue~=1
            xticksStr = xticksStr*1000;
            timeArray = timeArray*1000;
        end
        
        if gui_erpxyaxeset_waveviewer.timeminorticks_auto.Value ==1
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
            gui_erpxyaxeset_waveviewer.timeminorticks_custom.String = num2str(stepX);
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%----------------------------Setting for Y axis-------------------
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%y scale
        ALLERPIN = ERPwaviewer_apply.ALLERP;
        ERPArrayin = ERPwaviewer_apply.SelectERPIdx;
        BinArrayIN = [];
        ChanArrayIn = [];
        plotOrg = [1 2 3];
        try
            plotOrg(1) = ERPwaviewer_apply.plot_org.Grid;
            plotOrg(2) = ERPwaviewer_apply.plot_org.Overlay;
            plotOrg(3) = ERPwaviewer_apply.plot_org.Pages;
        catch
            plotOrg = [1 2 3];
        end
        try
            ChanArrayIn = ERPwaviewer_apply.chan;
        catch
            ChanArrayIn = [];
        end
        try
            BinArrayIN = ERPwaviewer_apply.bin;
        catch
            BinArrayIN = [];
        end
        
        PageCurrent =  ERPwaviewer_apply.PageIndex;
        yylim_out = f_erpAutoYLim(ALLERPIN, ERPArrayin,plotOrg,BinArrayIN, ChanArrayIn);
        try
            yRangeLabel = num2str(yylim_out(PageCurrent,:));
        catch
            yRangeLabel = num2str(yylim_out(1,:));
        end
        
        if gui_erpxyaxeset_waveviewer.yrangeauto.Value ==1
            gui_erpxyaxeset_waveviewer.yrange_edit.String = yRangeLabel;
        end
        %%y ticks
        yticksLabel = '';
        if ~isempty(str2num(yRangeLabel))
            yticksLabel = default_amp_ticks_viewer(str2num(yRangeLabel));
        end
        ytick_precision= gui_erpxyaxeset_waveviewer.yticks_precision.Value-1;
        yticksLabel= f_decimal(char(yticksLabel),ytick_precision);
        if gui_erpxyaxeset_waveviewer.ytickauto.Value ==1
            gui_erpxyaxeset_waveviewer.yticks_edit.String = yticksLabel;
        end
        
        %%y minor ticks
        if gui_erpxyaxeset_waveviewer.yminorstep_auto.Value==1
            yticksStr = str2num(char(gui_erpxyaxeset_waveviewer.yticks_edit.String));
            stepY = [];
            yscaleRange =  (str2num(yRangeLabel));
            if ~isempty(yticksStr) && numel(yticksStr)>1
                if numel(yticksStr)>=2
                    for Numofxticks = 1:numel(yticksStr)-1
                        stepY(1,Numofxticks) = yticksStr(Numofxticks)+(yticksStr(Numofxticks+1)-yticksStr(Numofxticks))/2;
                    end
                    %%adjust the left edge
                    steyleft =  (yticksStr(2)-yticksStr(1))/2;
                    for ii = 1:1000
                        if  (yticksStr(1)- steyleft*ii)>=yscaleRange(1)
                            stepY   = [(yticksStr(1)- steyleft*ii),stepY];
                        else
                            break;
                        end
                    end
                    %%adjust the right edge
                    steyright =  (yticksStr(end)-yticksStr(end-1))/2;
                    for ii = 1:1000
                        if  (yticksStr(end)+ steyright*ii)<=yscaleRange(end)
                            stepY   = [stepY,(yticksStr(end)+ steyright*ii)];
                        else
                            break;
                        end
                    end
                end
            end
            gui_erpxyaxeset_waveviewer.yminorstepedit.String=char(num2str(stepY));
        end
        
        if xdispysecondValue==1
            ERPwaviewer_apply.xaxis.timerange = str2num(gui_erpxyaxeset_waveviewer.timerange_edit.String);
        else
            ERPwaviewer_apply.xaxis.timerange = str2num(gui_erpxyaxeset_waveviewer.timerange_edit.String)*1000;
        end
        timeRange = ERPwaviewer_apply.xaxis.timerange ;
        %%getting xticks
        if xdispysecondValue==1
            xticksArray = str2num(char(gui_erpxyaxeset_waveviewer.timeticks_edit.String));
        else
            xticksArray = str2num(char(gui_erpxyaxeset_waveviewer.timeticks_edit.String))*1000;
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
        
        xticckMinorstep = str2num(char(gui_erpxyaxeset_waveviewer.timeminorticks_custom.String));
        if xdispysecondValue==1
            ERPwaviewer_apply.xaxis.tminor.step = xticckMinorstep;
        else
            ERPwaviewer_apply.xaxis.tminor.step = xticckMinorstep*1000;
        end
        ERPwaviewer_apply.xaxis.timeticks = xticksArray;
        
        %%y axis
        YScales = str2num(char(gui_erpxyaxeset_waveviewer.yrange_edit.String));
        if isempty(YScales)
            PageCurrent =  ERPwaviewer_apply.PageIndex;
            yylim_out = f_erpAutoYLim(ALLERPIN, ERPArrayin,plotOrg,BinArrayIN, ChanArrayIn);
            YScales = [];
            try
                YScales = yylim_out(PageCurrent,:);
            catch
                YScales = yylim_out(1,:);
            end
        end
        ERPwaviewer_apply.yaxis.scales =YScales ;
        YTicks = str2num(char(gui_erpxyaxeset_waveviewer.yticks_edit.String));
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
        ERPwaviewer_apply.yaxis.ticks = YTicks;
        ERPwaviewer_apply.yaxis.yminor.step = str2num(char(gui_erpxyaxeset_waveviewer.yminorstepedit.String));
        %%save the parameters
        assignin('base','ALLERPwaviewer',ERPwaviewer_apply);
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%---------------change  X/Y axis based on the current Page----------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function page_xyaxis_change(~,~)
        if viewer_ERPDAT.page_xyaxis==0
            return;
        end
        try
            ERPwaviewer_apply  = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp('f_ERP_timeampscal_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        
        try
            ERPIN = ERPwaviewer_apply.ERP;
            timeArray(1) = ERPwaviewer_apply.ERP.times(1);
            timeArray(2) = ERPwaviewer_apply.ERP.times(end);
            [timeticks stepX]= default_time_ticks_studio(ERPIN, [timeArray(1),timeArray(2)]);
            if ~isempty(stepX) && numel(stepX) ==1
                stepX = floor(stepX/2);
            end
        catch
            timeticks = '';
            timeArray = [];
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%----------------------------Setting for X axis-------------------
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        xSecondflag = erpworkingmemory('MyViewer_xaxis_second');
        xmSecondflag =  erpworkingmemory('MyViewer_xaxis_msecond');
        if isempty(xSecondflag) && isempty(xmSecondflag)
            xdispysecondValue =  gui_erpxyaxeset_waveviewer.xmillisecond.Value;%%millisecond
        end
        if xSecondflag ==0 && xmSecondflag==1
            xdispysecondValue =1;
            if gui_erpxyaxeset_waveviewer.xtimerangeauto.Value==1
                if xdispysecondValue==1
                    gui_erpxyaxeset_waveviewer.timerange_edit.String = num2str(timeArray);
                    gui_erpxyaxeset_waveviewer.xticks_precision.String = {'0','1','2','3','4','5','6'};
                else
                    gui_erpxyaxeset_waveviewer.timerange_edit.String = num2str(timeArray/1000);
                    gui_erpxyaxeset_waveviewer.xticks_precision.String = {'1','2','3','4','5','6'};
                end
            end
        else
            xdispysecondValue =0;
        end
        
        if xdispysecondValue==1
            xtick_precision =gui_erpxyaxeset_waveviewer.xticks_precision.Value-1;
            if xtick_precision<0
                xtick_precision =0;
                gui_erpxyaxeset_waveviewer.xticks_precision.Value=1;
            end
        else
            xtick_precision =gui_erpxyaxeset_waveviewer.xticks_precision.Value;
            if xtick_precision<=0
                xtick_precision =1;
                gui_erpxyaxeset_waveviewer.xticks_precision.Value=1;
            end
        end
        ERPwaviewer_apply.xaxis.tickdecimals = xtick_precision;
        
        if gui_erpxyaxeset_waveviewer.xtimetickauto.Value ==1
            if xdispysecondValue==0
                timeticks = num2str(str2num(char(timeticks))/1000);
            end
            timeticks= f_decimal(char(timeticks),xtick_precision);
            gui_erpxyaxeset_waveviewer.timeticks_edit.String = char(timeticks);
        end
        %%X minor ticks
        stepX = [];
        timeArray = str2num(char(gui_erpxyaxeset_waveviewer.timerange_edit.String));
        xticksStr = str2num(char(gui_erpxyaxeset_waveviewer.timeticks_edit.String));
        if xdispysecondValue~=1
            xticksStr = xticksStr*1000;
            timeArray = timeArray*1000;
        end
        if gui_erpxyaxeset_waveviewer.timeminorticks_auto.Value ==1
            if ~isempty(xticksStr) && numel(xticksStr)>1
                
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
                stepX =stepX/1000;
            end
            gui_erpxyaxeset_waveviewer.timeminorticks_custom.String = num2str(stepX);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%----------------------------Setting for Y axis-------------------
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%y scale
        ALLERPIN = ERPwaviewer_apply.ALLERP;
        ERPArrayin = ERPwaviewer_apply.SelectERPIdx;
        BinArrayIN = [];
        ChanArrayIn = [];
        plotOrg = [1 2 3];
        try
            plotOrg(1) = ERPwaviewer_apply.plot_org.Grid;
            plotOrg(2) = ERPwaviewer_apply.plot_org.Overlay;
            plotOrg(3) = ERPwaviewer_apply.plot_org.Pages;
        catch
            plotOrg = [1 2 3];
        end
        try
            ChanArrayIn = ERPwaviewer_apply.chan;
        catch
            ChanArrayIn = [];
        end
        try
            BinArrayIN = ERPwaviewer_apply.bin;
        catch
            BinArrayIN = [];
        end
        
        PageCurrent =  ERPwaviewer_apply.PageIndex;
        yylim_out = f_erpAutoYLim(ALLERPIN, ERPArrayin,plotOrg,BinArrayIN, ChanArrayIn);
        try
            yRangeLabel = num2str(yylim_out(PageCurrent,:));
        catch
            yRangeLabel = num2str(yylim_out(1,:));
        end
        
        if gui_erpxyaxeset_waveviewer.yrangeauto.Value ==1
            gui_erpxyaxeset_waveviewer.yrange_edit.String = yRangeLabel;
        end
        %%y ticks
        yticksLabel = '';
        if ~isempty(str2num(yRangeLabel))
            yticksLabel = default_amp_ticks_viewer(str2num(yRangeLabel));
        end
        
        ytick_precision= gui_erpxyaxeset_waveviewer.yticks_precision.Value-1;
        yticksLabel= f_decimal(char(yticksLabel),ytick_precision);
        
        if gui_erpxyaxeset_waveviewer.ytickauto.Value ==1
            gui_erpxyaxeset_waveviewer.yticks_edit.String = yticksLabel;
        end
        
        %%y minor ticks
        if gui_erpxyaxeset_waveviewer.yminorstep_auto.Value==1
            yticksStr = str2num(char(gui_erpxyaxeset_waveviewer.yticks_edit.String));
            stepY = [];
            yscaleRange =  (str2num(yRangeLabel));
            if ~isempty(yticksStr) && numel(yticksStr)>1
                if numel(yticksStr)>=2
                    for Numofxticks = 1:numel(yticksStr)-1
                        stepY(1,Numofxticks) = yticksStr(Numofxticks)+(yticksStr(Numofxticks+1)-yticksStr(Numofxticks))/2;
                    end
                    %%adjust the left edge
                    steyleft =  (yticksStr(2)-yticksStr(1))/2;
                    for ii = 1:1000
                        if  (yticksStr(1)- steyleft*ii)>=yscaleRange(1)
                            stepY   = [(yticksStr(1)- steyleft*ii),stepY];
                        else
                            break;
                        end
                    end
                    %%adjust the right edge
                    steyright =  (yticksStr(end)-yticksStr(end-1))/2;
                    for ii = 1:1000
                        if  (yticksStr(end)+ steyright*ii)<=yscaleRange(end)
                            stepY   = [stepY,(yticksStr(end)+ steyright*ii)];
                        else
                            break;
                        end
                    end
                end
            end
            gui_erpxyaxeset_waveviewer.yminorstepedit.String=char(num2str(stepY));
        end
        
        if xdispysecondValue==1
            ERPwaviewer_apply.xaxis.timerange = str2num(gui_erpxyaxeset_waveviewer.timerange_edit.String);
        else
            ERPwaviewer_apply.xaxis.timerange = str2num(gui_erpxyaxeset_waveviewer.timerange_edit.String)*1000;
        end
        timeRange = ERPwaviewer_apply.xaxis.timerange;
        
        %%getting xticks
        if xdispysecondValue==1
            xticksArray = str2num(char(gui_erpxyaxeset_waveviewer.timeticks_edit.String));
        else
            xticksArray = str2num(char(gui_erpxyaxeset_waveviewer.timeticks_edit.String))*1000;
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
        
        xticckMinorstep = str2num(char(gui_erpxyaxeset_waveviewer.timeminorticks_custom.String));
        if xdispysecondValue==1
            ERPwaviewer_apply.xaxis.tminor.step = xticckMinorstep;
        else
            ERPwaviewer_apply.xaxis.tminor.step = xticckMinorstep*1000;
        end
        ERPwaviewer_apply.xaxis.timeticks = xticksArray;
        
        %%y axis
        YScales = str2num(char(gui_erpxyaxeset_waveviewer.yrange_edit.String));
        if isempty(YScales)
            PageCurrent =  ERPwaviewer_apply.PageIndex;
            yylim_out = f_erpAutoYLim(ALLERPIN, ERPArrayin,plotOrg,BinArrayIN, ChanArrayIn);
            YScales = [];
            try
                YScales = yylim_out(PageCurrent,:);
            catch
                YScales = yylim_out(1,:);
            end
        end
        ERPwaviewer_apply.yaxis.scales =YScales ;
        YTicks = str2num(char(gui_erpxyaxeset_waveviewer.yticks_edit.String));
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
        ERPwaviewer_apply.yaxis.ticks = YTicks;
        ERPwaviewer_apply.yaxis.yminor.step = str2num(char(gui_erpxyaxeset_waveviewer.yminorstepedit.String));
        %%save the parameters
        assignin('base','ALLERPwaviewer',ERPwaviewer_apply);
    end

%%-------------modify this panel based on the updated parameters-----------
    function count_loadproper_change(~,~)
        if viewer_ERPDAT.count_loadproper ==0
            return;
        end
        try
            ERPwaviewer_apply  = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp('f_ERP_timeampscal_waveviewer_GUI()> count_loadproper_change() error: Please run the ERP wave viewer again.');
            return;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%------------------------------X axis---------------------------%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%display xtick with milliseocnd or second
        xdispysecondValue = ERPwaviewer_apply.xaxis.tdis;
        gui_erpxyaxeset_waveviewer.xmillisecond.Value = xdispysecondValue;
        gui_erpxyaxeset_waveviewer.xsecond.Value = ~xdispysecondValue;
        
        %%x range
        timeRange = ERPwaviewer_apply.xaxis.timerange;
        timeRangeAuto = ERPwaviewer_apply.xaxis.trangeauto;
        if timeRangeAuto~=0 && timeRangeAuto~=1
            timeRangeAuto =1;
        end
        if xdispysecondValue ==1
            gui_erpxyaxeset_waveviewer.timerange_edit.String = num2str(timeRange);
        else
            gui_erpxyaxeset_waveviewer.timerange_edit.String = num2str(timeRange/1000);
        end
        
        gui_erpxyaxeset_waveviewer.xtimerangeauto.Value = timeRangeAuto;
        if timeRangeAuto==1
            gui_erpxyaxeset_waveviewer.timerange_edit.Enable = 'off';
        else
            gui_erpxyaxeset_waveviewer.timerange_edit.Enable = 'on';
        end
        timeTick = ERPwaviewer_apply.xaxis.timeticks;
        timetickAuto = ERPwaviewer_apply.xaxis.ticksauto;
        
        if xdispysecondValue ==0%% in second
            timeTick = timeTick/1000;
        end
        xtick_precision = ERPwaviewer_apply.xaxis.tickdecimals;
        if xdispysecondValue==1
            if xtick_precision<0
                xtick_precision=1;
            end
            gui_erpxyaxeset_waveviewer.xticks_precision.Value = xtick_precision+1;
            gui_erpxyaxeset_waveviewer.xticks_precision.String = {'0','1','2','3','4','5','6'};
        else
            if xtick_precision<=0
                xtick_precision=1;
            end
            gui_erpxyaxeset_waveviewer.xticks_precision.Value = xtick_precision;
            gui_erpxyaxeset_waveviewer.xticks_precision.String = {'1','2','3','4','5','6'};
        end
        
        timeTick= f_decimal(char(num2str(timeTick)),xtick_precision);
        gui_erpxyaxeset_waveviewer.timeticks_edit.String = timeTick;
        gui_erpxyaxeset_waveviewer.xtimetickauto.Value = timetickAuto;
        if timetickAuto==1
            gui_erpxyaxeset_waveviewer.timeticks_edit.Enable = 'off';
        else
            gui_erpxyaxeset_waveviewer.timeticks_edit.Enable = 'on';
        end
        
        timetixkMinordip = ERPwaviewer_apply.xaxis.tminor.disp;
        timetixkMinorstep = ERPwaviewer_apply.xaxis.tminor.step;
        timetixkMinorauto = ERPwaviewer_apply.xaxis.tminor.auto;
        gui_erpxyaxeset_waveviewer.xtimeminorauto.Value = timetixkMinordip;
        if xdispysecondValue ==0%% in second
            timetixkMinorstep = timetixkMinorstep/1000;
        end
        timetixkMinorstep= f_decimal(char(num2str(timetixkMinorstep)),xtick_precision);
        gui_erpxyaxeset_waveviewer.timeminorticks_custom.String = char(timetixkMinorstep);
        gui_erpxyaxeset_waveviewer.timeminorticks_auto.Value = timetixkMinorauto;
        if timetixkMinordip ==0
            gui_erpxyaxeset_waveviewer.timeminorticks_custom.Enable = 'off';
            gui_erpxyaxeset_waveviewer.timeminorticks_auto.Enable = 'off';
        else
            gui_erpxyaxeset_waveviewer.timeminorticks_auto.Enable = 'on';
            if timetixkMinorauto==1
                gui_erpxyaxeset_waveviewer.timeminorticks_custom.Enable = 'off';
            else
                gui_erpxyaxeset_waveviewer.timeminorticks_custom.Enable = 'on';
            end
        end
        %%xticklabels
        xticklabelValue = ERPwaviewer_apply.xaxis.label;
        gui_erpxyaxeset_waveviewer.xtimelabel_on.Value = xticklabelValue;
        gui_erpxyaxeset_waveviewer.xtimelabel_off.Value = ~xticklabelValue;
        xticklabelfont = ERPwaviewer_apply.xaxis.font;
        gui_erpxyaxeset_waveviewer.xtimefont_custom.Value = xticklabelfont;
        xticklabelfontsize = ERPwaviewer_apply.xaxis.fontsize;
        fontsize  = {'4','6','8','10','12','14','16','18','20','24','28','32','36',...
            '40','50','60','70','80','90','100'};
        fontsize = str2num(char(fontsize));
        [xsize,y] = find(fontsize ==xticklabelfontsize);
        gui_erpxyaxeset_waveviewer.font_custom_size.Value = xsize;
        xticklabelcolor = ERPwaviewer_apply.xaxis.fontcolor;
        gui_erpxyaxeset_waveviewer.xtimetextcolor.Value =xticklabelcolor;
        xaxisunits = ERPwaviewer_apply.xaxis.units;
        gui_erpxyaxeset_waveviewer.xtimeunits_on.Value =xaxisunits;
        gui_erpxyaxeset_waveviewer.xtimeunits_off.Value = ~xaxisunits;
        if xticklabelValue ==1
            XticklabelEnable = 'on';
        else
            XticklabelEnable = 'off';
        end
        gui_erpxyaxeset_waveviewer.xtimefont_custom.Enable = XticklabelEnable;
        gui_erpxyaxeset_waveviewer.font_custom_size.Enable = XticklabelEnable;
        gui_erpxyaxeset_waveviewer.xtimetextcolor.Enable = XticklabelEnable;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%------------------------------Y axis---------------------------%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        YScales = ERPwaviewer_apply.yaxis.scales;
        YScalesAuto = ERPwaviewer_apply.yaxis.scalesauto;
        gui_erpxyaxeset_waveviewer.yrange_edit.String = num2str(YScales);
        gui_erpxyaxeset_waveviewer.yrangeauto.Value = YScalesAuto;
        if YScalesAuto==1
            gui_erpxyaxeset_waveviewer.yrange_edit.Enable = 'off';
        else
            gui_erpxyaxeset_waveviewer.yrange_edit.Enable = 'on';
        end
        %%y ticks
        try
            gui_erpxyaxeset_waveviewer.yticks_precision.Value =ERPwaviewer_apply.yaxis.tickdecimals;
        catch
            gui_erpxyaxeset_waveviewer.yticks_precision.Value =1;
        end
        
        yticks =  ERPwaviewer_apply.yaxis.ticks;
        yticksauto = ERPwaviewer_apply.yaxis.tickauto;
        ytick_precision = ERPwaviewer_apply.yaxis.tickdecimals;
        gui_erpxyaxeset_waveviewer.yticks_precision.Value = ytick_precision+1;
        yticks= f_decimal(char(num2str(yticks)),ytick_precision);
        gui_erpxyaxeset_waveviewer.yticks_edit.String = yticks;
        gui_erpxyaxeset_waveviewer.ytickauto.Value = yticksauto;
        if yticksauto==1
            gui_erpxyaxeset_waveviewer.yticks_edit.Enable = 'off';
        else
            gui_erpxyaxeset_waveviewer.yticks_edit.Enable = 'on';
        end
        
        ytickminordisp = ERPwaviewer_apply.yaxis.yminor.disp;
        ytickminorstep = ERPwaviewer_apply.yaxis.yminor.step;
        ytickminorauto = ERPwaviewer_apply.yaxis.yminor.auto;
        gui_erpxyaxeset_waveviewer.yminortick.Value = ytickminordisp;
        gui_erpxyaxeset_waveviewer.yminorstepedit.String = num2str(ytickminorstep);
        gui_erpxyaxeset_waveviewer.yminorstep_auto.Value = ytickminorauto;
        if ytickminordisp==0
            gui_erpxyaxeset_waveviewer.yminorstepedit.Enable = 'off';
            gui_erpxyaxeset_waveviewer.yminorstep_auto.Enable = 'off';
        else
            gui_erpxyaxeset_waveviewer.yminorstep_auto.Enable = 'on';
            if ytickminorauto==1
                gui_erpxyaxeset_waveviewer.yminorstepedit.Enable = 'off';
            else
                gui_erpxyaxeset_waveviewer.yminorstepedit.Enable = 'on';
            end
        end
        yticklabel = ERPwaviewer_apply.yaxis.label;
        gui_erpxyaxeset_waveviewer.ylabel_on.Value = yticklabel;
        gui_erpxyaxeset_waveviewer.ylabel_off.Value = ~yticklabel;
        yticklabelfont = ERPwaviewer_apply.yaxis.font;
        yticklabelfontsize = ERPwaviewer_apply.yaxis.fontsize;
        yticklabelcolor = ERPwaviewer_apply.yaxis.fontcolor;
        gui_erpxyaxeset_waveviewer.yfont_custom.Value = yticklabelfont;
        [ysize,~] = find(fontsize ==yticklabelfontsize);
        gui_erpxyaxeset_waveviewer.yfont_custom_size.Value = ysize;
        gui_erpxyaxeset_waveviewer.ytextcolor.Value = yticklabelcolor;
        if yticklabel==1
            yticksEnable  = 'on';
        else
            yticksEnable  = 'off';
        end
        gui_erpxyaxeset_waveviewer.yfont_custom.Enable = yticksEnable;
        gui_erpxyaxeset_waveviewer.yfont_custom_size.Enable = yticksEnable;
        gui_erpxyaxeset_waveviewer.ytextcolor.Enable = yticksEnable;
        yunits = ERPwaviewer_apply.yaxis.units;
        gui_erpxyaxeset_waveviewer.yunits_on.Value = yunits;
        gui_erpxyaxeset_waveviewer.yunits_off.Value = ~yunits;
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
        if viewer_ERPDAT.Reset_Waviewer_panel==3
            try
                ERPwaviewer_apply = evalin('base','ALLERPwaviewer');
                
            catch
                beep;
                disp('f_ERP_Binchan_waviewer_GUI error: Restart ERPwave Viewer');
                return;
            end
            
            ALLERPIN = ERPwaviewer_apply.ALLERP;
            try
                ERPIN = ERPwaviewer_apply.ERP;
                timeArray(1) = ERPwaviewer_apply.ERP.times(1);
                timeArray(2) = ERPwaviewer_apply.ERP.times(end);
                [timeticks stepX]= default_time_ticks_studio(ERPIN, [timeArray(1),timeArray(2)]);
                if ~isempty(stepX) && numel(stepX) ==1
                    stepX = floor(stepX/2);
                end
            catch
                timeticks = '';
                timeArray = [];
            end
            gui_erpxyaxeset_waveviewer.xmillisecond.Value =1;
            gui_erpxyaxeset_waveviewer.xsecond.Value =0;
            ERPwaviewer_apply.xaxis.tdis =1;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%----------------------------Setting for X axis---------------
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%time range
            gui_erpxyaxeset_waveviewer.timerange_edit.String = num2str(timeArray);
            ERPwaviewer_apply.xaxis.timerange = timeArray;
            gui_erpxyaxeset_waveviewer.timerange_edit.Enable = 'off';
            gui_erpxyaxeset_waveviewer.xtimerangeauto.Value = 1;
            ERPwaviewer_apply.xaxis.trangeauto =1;
            %%x ticklable
            gui_erpxyaxeset_waveviewer.timeticks_edit.String = char(timeticks);%% xtick label
            ERPwaviewer_apply.xaxis.timeticks = str2num(char(timeticks));
            gui_erpxyaxeset_waveviewer.timeticks_edit.Enable = 'off';
            gui_erpxyaxeset_waveviewer.xtimetickauto.Value=1;
            ERPwaviewer_apply.xaxis.ticksauto = 1;
            %%x precision for x ticklabel
            gui_erpxyaxeset_waveviewer.xticks_precision.String = {'0','1','2','3','4','5','6'};
            gui_erpxyaxeset_waveviewer.xticks_precision.Value = 1;
            ERPwaviewer_apply.xaxis.tickdecimals = 0;
            %%x minor ticks
            gui_erpxyaxeset_waveviewer.xtimeminorauto.Value =0;
            ERPwaviewer_apply.xaxis.tminor.disp = 0;
            stepX = [];
            timeArray = str2num(char(gui_erpxyaxeset_waveviewer.timerange_edit.String));
            xticksStr = str2num(char(gui_erpxyaxeset_waveviewer.timeticks_edit.String));
            gui_erpxyaxeset_waveviewer.timeminorticks_custom.String = '';
            gui_erpxyaxeset_waveviewer.timeminorticks_custom.Enable = 'off';
            gui_erpxyaxeset_waveviewer.timeminorticks_auto.Value=1;
            gui_erpxyaxeset_waveviewer.timeminorticks_auto.Enable = 'off';
            ERPwaviewer_apply.xaxis.tminor.step =[];
            ERPwaviewer_apply.xaxis.tminor.auto = 1;
            %%x label on/off
            gui_erpxyaxeset_waveviewer.xtimelabel_on.Value=1; %
            gui_erpxyaxeset_waveviewer.xtimelabel_off.Value=0;
            ERPwaviewer_apply.xaxis.label =1;
            
            %%font and font size
            ERPwaviewer_apply.xaxis.font  =2;
            gui_erpxyaxeset_waveviewer.xtimefont_custom.Value=2;
            ERPwaviewer_apply.xaxis.fontsize =10;
            gui_erpxyaxeset_waveviewer.font_custom_size.Value=4;
            fonttype = {'Courier','Geneva','Helvetica','Monaco','Times'};
            gui_erpxyaxeset_waveviewer.yfont_custom.String=fonttype; %
            yfontsize={'4','6','8','10','12','14','16','18','20','24','28','32','36',...
                '40','50','60','70','80','90','100'};
            gui_erpxyaxeset_waveviewer.font_custom_size.String = yfontsize;
            
            %%color for x ticklabel
            xtextColor = {'Black','Red','Blue','Green','Orange','Cyan','Magenla'};
            gui_erpxyaxeset_waveviewer.xtimetextcolor.String =xtextColor ;
            ERPwaviewer_apply.xaxis.fontcolor =1;
            %%x units
            ERPwaviewer_apply.xaxis.units =1;
            gui_erpxyaxeset_waveviewer.xtimeunits_on.Value=1; %
            gui_erpxyaxeset_waveviewer.xtimeunits_off.Value=0; %
            erpworkingmemory('MyViewer_xaxis_second',0);
            erpworkingmemory('MyViewer_xaxis_msecond',1);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%----------------------------Setting for Y axis---------------
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%y scale
            ALLERPIN = ERPwaviewer_apply.ALLERP;
            ERPArrayin = ERPwaviewer_apply.SelectERPIdx;
            BinArrayIN = [];
            ChanArrayIn = [];
            plotOrg = [1 2 3];
            try
                ChanArrayIn = ERPwaviewer_apply.chan;
            catch
                ChanArrayIn = [];
            end
            try
                BinArrayIN = ERPwaviewer_apply.bin;
            catch
                BinArrayIN = [];
            end
            
            PageCurrent =  ERPwaviewer_apply.PageIndex;
            yylim_out = f_erpAutoYLim(ALLERPIN, ERPArrayin,plotOrg,BinArrayIN, ChanArrayIn);
            try
                yRangeLabel = num2str(yylim_out(PageCurrent,:));
            catch
                yRangeLabel = num2str(yylim_out(1,:));
            end
            %%Y range
            gui_erpxyaxeset_waveviewer.yrange_edit.String = yRangeLabel;
            gui_erpxyaxeset_waveviewer.yrange_edit.Enable = 'off';
            gui_erpxyaxeset_waveviewer.yrangeauto.Value =1;
            ERPwaviewer_apply.yaxis.scales = str2num(yRangeLabel);
            ERPwaviewer_apply.yaxis.scalesauto = 1;
            %%Y tick label
            %%y ticks
            ytick_precision=1;
            yticksLabel = '';
            if ~isempty(str2num(yRangeLabel))
                yticksLabel = default_amp_ticks_viewer(str2num(yRangeLabel));
                yticksLabel= f_decimal(yticksLabel,ytick_precision);
            end
            gui_erpxyaxeset_waveviewer.yticks_edit.String  = yticksLabel;
            gui_erpxyaxeset_waveviewer.yticks_edit.Enable = 'off';
            gui_erpxyaxeset_waveviewer.ytickauto.Value =1;
            ERPwaviewer_apply.yaxis.ticks = str2num(yticksLabel);
            ERPwaviewer_apply.yaxis.tickauto = 1;
            gui_erpxyaxeset_waveviewer.yticks_precision.Value=2;
            ERPwaviewer_apply.yaxis.tickdecimals=1;
            %%Y minor
            ERPwaviewer_apply.yaxis.yminor.disp =0;
            ERPwaviewer_apply.yaxis.yminor.auto =1;
            ERPwaviewer_apply.yaxis.yminor.step = [];
            gui_erpxyaxeset_waveviewer.yminortick.Value=0; %
            gui_erpxyaxeset_waveviewer.yminorstepedit.String ='';
            gui_erpxyaxeset_waveviewer.yminorstepedit.Enable = 'off'; %
            gui_erpxyaxeset_waveviewer.yminorstep_auto.Value=1;
            gui_erpxyaxeset_waveviewer.yminorstep_auto.Enable ='off'; %
            %%Y ticklabel on/off
            ERPwaviewer_apply.yaxis.label = 1;
            gui_erpxyaxeset_waveviewer.ylabel_on.Value=1; %
            gui_erpxyaxeset_waveviewer.ylabel_off.Value=0;
            %%font and fontsize
            ERPwaviewer_apply.yaxis.font=2;
            ERPwaviewer_apply.yaxis.fontsize=10;
            gui_erpxyaxeset_waveviewer.yfont_custom.Value=2;
            gui_erpxyaxeset_waveviewer.yfont_custom_size.Value=4;
            %%color for y ticklabels
            ytextColor = {'Black','Red','Blue','Green','Orange','Cyan','Magenla'};
            gui_erpxyaxeset_waveviewer.ytextcolor.String = ytextColor;
            gui_erpxyaxeset_waveviewer.ytextcolor.Value=1;
            ERPwaviewer_apply.yaxis.fontcolor =1;
            %%y units
            gui_erpxyaxeset_waveviewer.yunits_on.Value=1; %
            gui_erpxyaxeset_waveviewer.yunits_off.Value=0; %
            ERPwaviewer_apply.yaxis.units=1;
            assignin('base','ALLERPwaviewer',ERPwaviewer_apply);
            gui_erpxyaxeset_waveviewer.apply.BackgroundColor =  [1 1 1];
            gui_erpxyaxeset_waveviewer.apply.ForegroundColor = [0 0 0];
            box_erpxtaxes_viewer_property.TitleColor= [0.5 0.5 0.9];
            viewer_ERPDAT.Reset_Waviewer_panel=4;
        end
    end%% end of reset for the current panel

end