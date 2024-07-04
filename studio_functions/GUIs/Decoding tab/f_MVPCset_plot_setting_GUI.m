%%This function is used to setting the parameters for plotting the waveform for the selected MVPCsets

% *** This function is part of MVPCLAB Studio Toolbox ***
% Author: Guanghui Zhang
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2024


function varargout = f_MVPCset_plot_setting_GUI(varargin)
global observe_DECODE;
addlistener(observe_DECODE,'Count_currentMVPC_changed',@Count_currentMVPC_changed);
addlistener(observe_DECODE,'Reset_best_panel_change',@Reset_best_panel_change);


MVPC_plotset = struct();
[version reldate,ColorB_def,ColorF_def,errorColorF_def,~] = geterplabstudiodef;
%-----------------------------Name the title----------------------------------------------
if nargin == 0
    fig = figure(); % Parent figure
    MVPC_plotset_box = uiextras.BoxPanel('Parent', fig, 'Title', 'Plotting MVPCsets', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    MVPC_plotset_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Plotting MVPCsets', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    MVPC_plotset_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Plotting MVPCsets', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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
drawui_mvpcplot(FonsizeDefault);
varargout{1} = MVPC_plotset_box;
    function drawui_mvpcplot(FonsizeDefault)
        %%--------------------x and y axes setting-------------------------
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        
        MVPC_plotset.plotop = uiextras.VBox('Parent',MVPC_plotset_box, 'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent', MVPC_plotset.plotop,'String','Time Axis:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def); % 1B
        %%time range
        MVPC_plotset.timerange = uiextras.HBox('Parent',MVPC_plotset.plotop,'Spacing',1,'BackgroundColor',ColorB_def);
        MVPC_plotset.timet_auto = uicontrol('Style','checkbox','Parent', MVPC_plotset.timerange,'String','Auto',...
            'callback',@timet_auto,'Value',1,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off'); % 2B
        MVPC_plotset.timet_auto.KeyPressFcn=  @mvpc_plotsetting_presskey;
        uicontrol('Style','text','Parent', MVPC_plotset.timerange,'String','Range','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        MVPC_plotset.timet_low = uicontrol('Style', 'edit','Parent',MVPC_plotset.timerange,'BackgroundColor',[1 1 1],...
            'String','','callback',@low_ticks_change,'Enable','off','FontSize',FonsizeDefault,'Enable','off');
        MVPC_plotset.timet_low.KeyPressFcn=  @mvpc_plotsetting_presskey;
        uicontrol('Style','text','Parent', MVPC_plotset.timerange,'String','to','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        MVPC_plotset.timet_high = uicontrol('Style', 'edit','Parent',MVPC_plotset.timerange,'String','',...
            'callback',@high_ticks_change,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
        MVPC_plotset.timet_high.KeyPressFcn=  @mvpc_plotsetting_presskey;
        uicontrol('Style','text','Parent', MVPC_plotset.timerange,'String','ms','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(MVPC_plotset.timerange, 'Sizes', [50 50 50 30 50 20]);
        %%time ticks
        MVPC_plotset.timeticks = uiextras.HBox('Parent',MVPC_plotset.plotop,'Spacing',1,'BackgroundColor',ColorB_def);
        MVPC_plotset.timetick_auto = uicontrol('Style','checkbox','Parent', MVPC_plotset.timeticks,'String','Auto',...
            'callback',@timetick_auto,'Value',1,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off'); % 2B
        MVPC_plotset.timetick_auto.KeyPressFcn=  @mvpc_plotsetting_presskey;
        uicontrol('Style','text','Parent', MVPC_plotset.timeticks,'String','Time ticks, every','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        MVPC_plotset.timet_step = uicontrol('Style', 'edit','Parent',MVPC_plotset.timeticks,'String','',...
            'callback',@ticks_step_change,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
        MVPC_plotset.timet_step.KeyPressFcn=  @mvpc_plotsetting_presskey;
        uicontrol('Style','text','Parent', MVPC_plotset.timeticks,'String','ms','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(MVPC_plotset.timeticks, 'Sizes', [50 100 80 20]);
        
        %%--------x tick precision with decimals---------------------------
        MVPC_plotset.xtickprecision_title = uiextras.HBox('Parent', MVPC_plotset.plotop,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  MVPC_plotset.xtickprecision_title);
        uicontrol('Style','text','Parent',MVPC_plotset.xtickprecision_title ,...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'String','Precision','HorizontalAlignment','left'); %
        xprecisoonName = {'0','1','2','3','4','5','6'};
        MVPC_plotset.xticks_precision = uicontrol('Style','popupmenu','Parent',MVPC_plotset.xtickprecision_title,'String',xprecisoonName,...
            'callback',@xticksprecison,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Value',1,'Enable','off'); %
        MVPC_plotset.xticks_precision.KeyPressFcn = @mvpc_plotsetting_presskey;
        uicontrol('Style','text','Parent',  MVPC_plotset.xtickprecision_title,'String','# decimals',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); %
        set(MVPC_plotset.xtickprecision_title,'Sizes',[30 65 60 80]);
        
        %%-----font, font size, and text color for time ticks--------------
        fontsizes  = {'4','6','8','10','12','14','16','18','20','24','28','32','36',...
            '40','50','60','70','80','90','100'};
        MVPC_plotset.xtimefont_title = uiextras.HBox('Parent', MVPC_plotset.plotop,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',  MVPC_plotset.xtimefont_title,'String','Font',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'HorizontalAlignment','left'); %
        fonttype = {'Courier','Geneva','Helvetica','Monaco','Times'};
        MVPC_plotset.xtimefont_custom = uicontrol('Style','popupmenu','Parent', MVPC_plotset.xtimefont_title ,'String',fonttype,...
            'callback',@xtimefont,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off','Value',1); %
        MVPC_plotset.xtimefont_custom.KeyPressFcn = @mvpc_plotsetting_presskey;
        uicontrol('Style','text','Parent', MVPC_plotset.xtimefont_title ,'String','Size',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'HorizontalAlignment','left'); %
        MVPC_plotset.xtimefontsize = uicontrol('Style','popupmenu','Parent', MVPC_plotset.xtimefont_title ,'String',fontsizes,...
            'callback',@xtimefontsize,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off','Value',5); %
        MVPC_plotset.xtimefontsize.KeyPressFcn = @mvpc_plotsetting_presskey;
        set(MVPC_plotset.xtimefont_title,'Sizes',[30 100 30 80]);
        
        %%%---------------------color for x label text--------------
        MVPC_plotset.xtimelabelcolor_title = uiextras.HBox('Parent', MVPC_plotset.plotop,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',  MVPC_plotset.xtimelabelcolor_title,'String','Color',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'HorizontalAlignment','left'); %
        textColor = {'Black','Red','Blue','Green','Orange','Cyan','Magenla'};
        MVPC_plotset.xtimetextcolor = uicontrol('Style','popupmenu','Parent', MVPC_plotset.xtimelabelcolor_title ,'String',textColor,...
            'callback',@xtimecolor,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off','Value',1); %
        MVPC_plotset.xtimetextcolor.KeyPressFcn = @mvpc_plotsetting_presskey;
        uiextras.Empty('Parent',  MVPC_plotset.xtimelabelcolor_title);
        set(MVPC_plotset.xtimelabelcolor_title,'Sizes',[40 100 -1]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%------------------------------Amplitude axis---------------------
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%amplitude scale
        uicontrol('Style','text','Parent', MVPC_plotset.plotop,'String','Amplitude Axis:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        MVPC_plotset.yscale = uiextras.HBox('Parent',MVPC_plotset.plotop,'Spacing',1,'BackgroundColor',ColorB_def);
        MVPC_plotset.yscale_auto = uicontrol('Style','checkbox','Parent',MVPC_plotset.yscale,'String','Auto',...
            'callback',@yscale_auto,'Value',1,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off');
        MVPC_plotset.yscale_auto.KeyPressFcn=  @mvpc_plotsetting_presskey;
        uicontrol('Style','text','Parent',MVPC_plotset.yscale,'String','Scale','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        MVPC_plotset.yscale_low = uicontrol('Style', 'edit','Parent',MVPC_plotset.yscale,'BackgroundColor',[1 1 1],...
            'String','','callback',@yscale_low,'Enable','off','FontSize',FonsizeDefault,'Enable','off');
        MVPC_plotset.yscale_low.KeyPressFcn=  @mvpc_plotsetting_presskey;
        uicontrol('Style','text','Parent', MVPC_plotset.yscale,'String','to','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        MVPC_plotset.yscale_high = uicontrol('Style', 'edit','Parent',MVPC_plotset.yscale,'String','',...
            'callback',@yscale_high,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
        MVPC_plotset.yscale_high.KeyPressFcn=  @mvpc_plotsetting_presskey;
        uicontrol('Style','text','Parent', MVPC_plotset.yscale,'String',' ','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(MVPC_plotset.yscale, 'Sizes', [50 50 50 30 50 -1]);
        
        %%y ticks
        MVPC_plotset.yscaleticks = uiextras.HBox('Parent',MVPC_plotset.plotop,'Spacing',1,'BackgroundColor',ColorB_def);
        MVPC_plotset.ytick_auto = uicontrol('Style','checkbox','Parent', MVPC_plotset.yscaleticks,'String','Auto',...
            'callback',@ytick_auto,'Value',1,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off'); % 2B
        MVPC_plotset.ytick_auto.KeyPressFcn=  @mvpc_plotsetting_presskey;
        uicontrol('Style','text','Parent', MVPC_plotset.yscaleticks,'String','Amp. ticks, every','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        MVPC_plotset.yscale_step = uicontrol('Style', 'edit','Parent',MVPC_plotset.yscaleticks,'String','',...
            'callback',@yscale_step,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
        MVPC_plotset.yscale_step.KeyPressFcn=  @mvpc_plotsetting_presskey;
        uicontrol('Style','text','Parent', MVPC_plotset.yscaleticks,'String','','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(MVPC_plotset.yscaleticks, 'Sizes', [50 100 80 -1]);
        
        %%--------Y tick precision with decimals---------------------------
        MVPC_plotset.ytickprecision_title = uiextras.HBox('Parent', MVPC_plotset.plotop,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  MVPC_plotset.ytickprecision_title);
        uicontrol('Style','text','Parent',MVPC_plotset.ytickprecision_title ,...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'String','Precision','HorizontalAlignment','left'); %
        yprecisoonName = {'1','2','3','4','5','6'};
        MVPC_plotset.yticks_precision = uicontrol('Style','popupmenu','Parent',MVPC_plotset.ytickprecision_title,'String',yprecisoonName,...
            'callback',@yticksprecison,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Value',1,'Enable','off'); %
        MVPC_plotset.yticks_precision.KeyPressFcn = @mvpc_plotsetting_presskey;
        uicontrol('Style','text','Parent',  MVPC_plotset.ytickprecision_title,'String','# decimals',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); %
        set(MVPC_plotset.ytickprecision_title,'Sizes',[30 65 60 80]);
        
        %%-----y ticklabel:font, font size, and text color for time ticks
        MVPC_plotset.yfont_title = uiextras.HBox('Parent', MVPC_plotset.plotop,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',  MVPC_plotset.yfont_title,'String','Font',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); %
        fonttype = {'Courier','Geneva','Helvetica','Monaco','Times'};
        MVPC_plotset.yfont_custom = uicontrol('Style','popupmenu','Parent', MVPC_plotset.yfont_title,'String',fonttype,...
            'callback',@yaxisfont, 'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off','Value',1); %
        MVPC_plotset.yfont_custom.KeyPressFcn = @mvpc_plotsetting_presskey;
        uicontrol('Style','text','Parent', MVPC_plotset.yfont_title ,'String','Size',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); %
        yfontsize={'4','6','8','10','12','14','16','18','20','24','28','32','36',...
            '40','50','60','70','80','90','100'};
        MVPC_plotset.yfont_custom_size = uicontrol('Style','popupmenu','Parent', MVPC_plotset.yfont_title ,'String',yfontsize,...
            'callback',@yaxisfontsize,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off','Value',5); %
        MVPC_plotset.yfont_custom_size.KeyPressFcn = @mvpc_plotsetting_presskey;
        set(MVPC_plotset.yfont_title,'Sizes',[30 100 30 80]);
        
        %%% color for y ticklabel text
        MVPC_plotset.ylabelcolor_title = uiextras.HBox('Parent', MVPC_plotset.plotop,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',  MVPC_plotset.ylabelcolor_title,'String','Color',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'HorizontalAlignment','left'); %
        ytextColor = {'Black','Red','Blue','Green','Orange','Cyan','Magenla'};
        MVPC_plotset.ytextcolor = uicontrol('Style','popupmenu','Parent', MVPC_plotset.ylabelcolor_title ,'String',ytextColor,...
            'callback',@yaxisfontcolor,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off','Value',1); %
        MVPC_plotset.ytextcolor.KeyPressFcn = @mvpc_plotsetting_presskey;
        uiextras.Empty('Parent',  MVPC_plotset.ylabelcolor_title);
        set(MVPC_plotset.ylabelcolor_title,'Sizes',[40 100 -1]);
        
        %%standard error of the mean
        MVPC_plotset.SEM_title = uiextras.HBox('Parent', MVPC_plotset.plotop,'BackgroundColor',ColorB_def);
        MVPC_plotset.show_SEM = uicontrol('Style','checkbox','Parent', MVPC_plotset.SEM_title ,'String','Show standard error',...
            'callback',@showSEM,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Value',0,'Enable','off'); %
        MVPC_plotset.show_SEM.KeyPressFcn = @mvpc_plotsetting_presskey;
        SMEString = {'0','1','2','3','4','5','6','7','8','9','10'};
        MVPC_plotset.SEM_custom = uicontrol('Style','popupmenu','Parent', MVPC_plotset.SEM_title ,'String',SMEString,...
            'callback',@SEMerror,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Value',2,'Enable','off'); %
        MVPC_plotset.SEM_custom.KeyPressFcn = @mvpc_plotsetting_presskey;
        set(MVPC_plotset.SEM_title,'Sizes',[160 80]);
        
        MVPC_plotset.SEMtrans_title = uiextras.HBox('Parent', MVPC_plotset.plotop,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent', MVPC_plotset.SEMtrans_title ,'String','transparency',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'HorizontalAlignment','right'); %
        SMEtransString = {'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1'};
        MVPC_plotset.SEMtrans_custom = uicontrol('Style','popupmenu','Parent', MVPC_plotset.SEMtrans_title ,'String',SMEtransString,...
            'callback',@SEMtrans,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Value',3,'Enable','off'); %
        MVPC_plotset.SEMtrans_custom.KeyPressFcn = @mvpc_plotsetting_presskey;
        set(MVPC_plotset.SEMtrans_title,'Sizes',[160 80]);
        %%chance line
        MVPC_plotset.chanceline_title = uiextras.HBox('Parent', MVPC_plotset.plotop,'BackgroundColor',ColorB_def);
        MVPC_plotset.chanceline = uicontrol('Style','checkbox','Parent', MVPC_plotset.chanceline_title ,'String','Chance line',...
            'callback',@chanceline,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Value',0,'Enable','off'); %
        MVPC_plotset.chanceline.KeyPressFcn = @mvpc_plotsetting_presskey;
        uiextras.Empty('Parent', MVPC_plotset.chanceline_title); % 1A
        set(MVPC_plotset.chanceline_title, 'Sizes',[160 -1]);
        
        %%cancel & apply
        MVPC_plotset.reset_apply = uiextras.HBox('Parent',MVPC_plotset.plotop,'Spacing',1,'BackgroundColor',ColorB_def);
        %         uiextras.Empty('Parent', MVPC_plotset.reset_apply); % 1A
        MVPC_plotset.plot_reset = uicontrol('Style', 'pushbutton','Parent',MVPC_plotset.reset_apply,'Enable','off',...
            'String','Cancel','callback',@plot_cancel,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        MVPC_plotset.plot_ops = uicontrol('Style', 'pushbutton','Parent',MVPC_plotset.reset_apply,'Enable','off',...
            'String','Option','callback',@plot_ops,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        
        %         uiextras.Empty('Parent', MVPC_plotset.reset_apply); % 1A
        MVPC_plotset.plot_apply = uicontrol('Style', 'pushbutton','Parent',MVPC_plotset.reset_apply,'Enable','off',...
            'String','Apply','callback',@plot_setting_apply,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        %         uiextras.Empty('Parent', MVPC_plotset.reset_apply); % 1A
        %         set(MVPC_plotset.reset_apply, 'Sizes',[10 -1  30 -1 10]);
        
        set(MVPC_plotset.plotop, 'Sizes', [20 20 20 20 20 20 20 25 25 20 20 20 20 20 20 30]);
        
        estudioworkingmemory('MVPC_plotset',0);
    end

%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%---------------------------------Auto time ticks-------------------------------*
    function timet_auto( src, ~ )
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        estudioworkingmemory('MVPC_plotset',1);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_apply.ForegroundColor = [1 1 1];
        MVPC_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_reset.ForegroundColor = [1 1 1];
        MVPC_plotset.plot_ops.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_ops.ForegroundColor = [1 1 1];
        if src.Value == 1
            MVPC_plotset.timet_low.Enable = 'off';
            MVPC_plotset.timet_high.Enable = 'off';
            MVPC_plotset.timet_low.String = num2str(observe_DECODE.MVPC.times(1));
            MVPC_plotset.timet_high.String = num2str(observe_DECODE.MVPC.times(end));
        else
            MVPC_plotset.timet_low.Enable = 'on';
            MVPC_plotset.timet_high.Enable = 'on';
        end
    end

%%--------------------------Min. interval of time ticks---------------------
    function low_ticks_change( src, ~ )
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        estudioworkingmemory('MVPC_plotset',1);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_apply.ForegroundColor = [1 1 1];
        MVPC_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_reset.ForegroundColor = [1 1 1];
        MVPC_plotset.plot_ops.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_ops.ForegroundColor = [1 1 1];
        xtixlk_min = str2num(src.String);
        xtixlk_max = str2num(MVPC_plotset.timet_high.String);
        if isempty(xtixlk_min)|| numel(xtixlk_min)~=1
            src.String = num2str(observe_DECODE.MVPC.times(1));
            msgboxText =  ['Plotting MVPCsets> Time Axis- Input of low edge must be a single numeric.'];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        if any(xtixlk_max<=xtixlk_min)
            src.String = num2str(observe_DECODE.MVPC.times(1));
            msgboxText =  ['Plotting MVPCsets> Time Axis- Low edge must be  smaller than',32,num2str(xtixlk_max(1))];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
    end

%%----------------------high interval of time ticks--------------------------------*
    function high_ticks_change( src, ~ )
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        estudioworkingmemory('MVPC_plotset',1);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_apply.ForegroundColor = [1 1 1];
        MVPC_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_reset.ForegroundColor = [1 1 1];
        MVPC_plotset.plot_ops.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_ops.ForegroundColor = [1 1 1];
        xtixlk_min = str2num(MVPC_plotset.timet_low.String);
        xtixlk_max = str2num(src.String);
        if isempty(xtixlk_max) || numel(xtixlk_max)~=1
            src.String = num2str(observe_DECODE.MVPC.times(end));
            msgboxText =  ['Plotting MVPCsets> Amplitude Axis- Input of ticks edge must be a single numeric'];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        if any(xtixlk_max < xtixlk_min)
            src.String =  num2str(observe_DECODE.MVPC.times(end));
            msgboxText =  ['Plotting MVPCsets> Time Axis- high edge must be higher than',32,num2str(xtixlk_min),'ms'];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
    end


%%---------------------------time ticks automatically----------------------
    function timetick_auto(Source,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        estudioworkingmemory('MVPC_plotset',1);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_apply.ForegroundColor = [1 1 1];
        MVPC_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_reset.ForegroundColor = [1 1 1];
        MVPC_plotset.plot_ops.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_ops.ForegroundColor = [1 1 1];
        if MVPC_plotset.timetick_auto.Value==1
            timeStart = str2num(MVPC_plotset.timet_low.String);
            if isempty(timeStart) || numel(timeStart)~=1 || timeStart>=observe_DECODE.MVPC.times(end) %%|| timeStart<observe_DECODE.MVPC.times(1)
                timeStart = observe_DECODE.MVPC.times(1);
                MVPC_plotset.timet_low.String = num2str(observe_DECODE.MVPC.times(1));
                msgboxText =  ['Plotting MVPCsets> Time Axis- Time ticks>Auto: left edge of time range must be a single number and smaller than ',32,num2str(observe_DECODE.MVPC.times(end)),'ms'];
                titlNamerro = 'Warning for Pattern Classification Tab';
                estudio_warning(msgboxText,titlNamerro);
            end
            timEnd = str2num(MVPC_plotset.timet_high.String);
            if isempty(timEnd) || numel(timEnd)~=1 || timEnd<observe_DECODE.MVPC.times(1) %%|| timEnd> observe_DECODE.MVPC.times(end)
                timEnd = observe_DECODE.MVPC.times(end);
                MVPC_plotset.timet_high.String = num2str(observe_DECODE.MVPC.times(end));
                msgboxText =  ['Plotting MVPCsets> Time Axis- Time ticks>Auto: right edge of time range must be a single number and larger than ',32,num2str(observe_DECODE.MVPC.times(1)),'ms'];
                titlNamerro = 'Warning for Pattern Classification Tab';
                estudio_warning(msgboxText,titlNamerro);
            end
            if timeStart>timEnd
                MVPC_plotset.timet_low.String = num2str(observe_DECODE.MVPC.times(1));
                MVPC_plotset.timet_high.String = num2str(observe_DECODE.MVPC.times(end));
                timeStart = observe_DECODE.MVPC.times(1);
                timEnd = observe_DECODE.MVPC.times(end);
                MVPC_plotset.timet_high.String = num2str(observe_DECODE.MVPC.times(end));
                msgboxText =  ['Plotting MVPCsets> Time Axis- Time ticks>Auto: left edge of time range must be smaller than right one'];
                titlNamerro = 'Warning for Pattern Classification Tab';
                estudio_warning(msgboxText,titlNamerro);
            end
            [def xstep]= default_time_ticks_decode(observe_DECODE.MVPC, [timeStart,timEnd]);
            MVPC_plotset.timet_step.String = num2str(xstep);
            MVPC_plotset.timet_step.Enable = 'off';
        else
            MVPC_plotset.timet_step.Enable = 'on';
        end
        
    end

%%----------------------Step of time ticks--------------------------------*
    function ticks_step_change( src, ~ )
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        estudioworkingmemory('MVPC_plotset',1);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_apply.ForegroundColor = [1 1 1];
        MVPC_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_reset.ForegroundColor = [1 1 1];
        MVPC_plotset.plot_ops.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_ops.ForegroundColor = [1 1 1];
        timeStart = str2num(MVPC_plotset.timet_low.String);
        timEnd = str2num(MVPC_plotset.timet_high.String);
        if ~isempty(timeStart) && ~isempty(timEnd) && numel(timEnd)==1 && numel(timeStart) ==1 && timeStart < timEnd
            [def xtickstepdef]= default_time_ticks_decode(observe_DECODE.MVPC, [timEnd,timeStart]);
        else
            xtickstepdef = [];
        end
        tick_step = str2num(src.String);
        if isempty(tick_step) || numel(tick_step)~=1 || any(tick_step<=0)
            src.String = num2str(xtickstepdef);
            msgboxText =  ['Plotting MVPCsets> Time Axis - The input of Step for time ticks must be a single positive value'];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
    end
%%----------------------------precision for x axis-------------------------
    function xticksprecison(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        estudioworkingmemory('MVPC_plotset',1);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_apply.ForegroundColor = [1 1 1];
        MVPC_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_reset.ForegroundColor = [1 1 1];
        MVPC_plotset.plot_ops.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_ops.ForegroundColor = [1 1 1];
    end

%%-------------------------font for x axis---------------------------------
    function xtimefont(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        estudioworkingmemory('MVPC_plotset',1);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_apply.ForegroundColor = [1 1 1];
        MVPC_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_reset.ForegroundColor = [1 1 1];
        MVPC_plotset.plot_ops.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_ops.ForegroundColor = [1 1 1];
    end

%%-------------------------fontsize for x axis-----------------------------
    function xtimefontsize(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        estudioworkingmemory('MVPC_plotset',1);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_apply.ForegroundColor = [1 1 1];
        MVPC_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_reset.ForegroundColor = [1 1 1];
        MVPC_plotset.plot_ops.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_ops.ForegroundColor = [1 1 1];
    end

%%--------------------------text color for x axis--------------------------
    function xtimecolor(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        estudioworkingmemory('MVPC_plotset',1);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_apply.ForegroundColor = [1 1 1];
        MVPC_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_reset.ForegroundColor = [1 1 1];
        MVPC_plotset.plot_ops.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_ops.ForegroundColor = [1 1 1];
    end


%%---------------------------------Auto Amplitude Axis---------------------------------*
    function yscale_auto( src, ~ )
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        estudioworkingmemory('MVPC_plotset',1);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_apply.ForegroundColor = [1 1 1];
        MVPC_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_reset.ForegroundColor = [1 1 1];
        MVPC_plotset.plot_ops.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_ops.ForegroundColor = [1 1 1];
        if MVPC_plotset.yscale_auto.Value ==1
            MVPCArray= estudioworkingmemory('MVPCArray');
            if isempty(MVPCArray) || (~isempty(MVPCArray) && any(MVPCArray(:)>length(observe_DECODE.ALLMVPC)))
                MVPCArray = length(observe_DECODE.ALLMVPC);
                observe_DECODE.MVPC = observe_DECODE.ALLMVPC(end);
                observe_DECODE.CURRENTMVPC = MVPCArray;
                estudioworkingmemory('MVPCArray',MVPCArray);
            end
            [def, minydef, maxydef] = default_amp_ticks_decode(observe_DECODE.ALLMVPC(MVPCArray));
            if ~isempty(minydef) && ~isempty(maxydef)
                if minydef==maxydef
                    minydef=0;
                    maxydef=1;
                end
            elseif isempty(minydef) || isempty(maxydef)
                minydef=0;
                maxydef=1;
            end
            MVPC_plotset.yscale_low.Enable = 'off';
            MVPC_plotset.yscale_high.Enable = 'off';
            MVPC_plotset.yscale_low.String = num2str(minydef);
            MVPC_plotset.yscale_high.String = num2str(maxydef);
        else
            MVPC_plotset.yscale_low.Enable = 'on';
            MVPC_plotset.yscale_high.Enable = 'on';
        end
    end


%%------------------------left edge of y scale-----------------------------
    function yscale_low(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        estudioworkingmemory('MVPC_plotset',1);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_apply.ForegroundColor = [1 1 1];
        MVPC_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_reset.ForegroundColor = [1 1 1];
        MVPC_plotset.plot_ops.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_ops.ForegroundColor = [1 1 1];
        MVPCArray= estudioworkingmemory('MVPCArray');
        if isempty(MVPCArray) || (~isempty(MVPCArray) && any(MVPCArray(:)>length(observe_DECODE.ALLMVPC)))
            MVPCArray = length(observe_DECODE.ALLMVPC);
            observe_DECODE.MVPC = observe_DECODE.ALLMVPC(end);
            observe_DECODE.CURRENTMVPC = MVPCArray;
            estudioworkingmemory('MVPCArray',MVPCArray);
        end
        [def, minydef, maxydef] = default_amp_ticks_decode(observe_DECODE.ALLMVPC(MVPCArray));
        if ~isempty(minydef) && ~isempty(maxydef)
            if minydef==maxydef
                minydef=0;
                maxydef=1;
            end
        elseif isempty(minydef) || isempty(maxydef)
            minydef=0;
            maxydef=1;
        end
        Yscales_low = str2num(MVPC_plotset.yscale_low.String);
        Yscales_high = str2num(MVPC_plotset.yscale_high.String);
        
        if isempty(Yscales_low) || numel(Yscales_low)~=1
            MVPC_plotset.yscale_low.String = num2str(minydef);
            Yscales_low= minydef;
            msgboxText= ['Plotting MVPCsets> Amplitude Axis: You did set left edge of amplitude scale to be a single number and we used the default one '];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
        if any(Yscales_high<=Yscales_low)
            MVPC_plotset.yscale_low.String = num2str(minydef);
            MVPC_plotset.yscale_high.String = num2str(maxydef);
            msgboxText = ['Plotting MVPCsets> Amplitude Axis: Left edge of amplitude scale should be smaller than the right one and we used the default ones '];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
    end

%%-------------------right edge of y scale---------------------------------
    function yscale_high(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        estudioworkingmemory('MVPC_plotset',1);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_apply.ForegroundColor = [1 1 1];
        MVPC_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_reset.ForegroundColor = [1 1 1];
        MVPC_plotset.plot_ops.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_ops.ForegroundColor = [1 1 1];
        MVPCArray= estudioworkingmemory('MVPCArray');
        if isempty(MVPCArray) || (~isempty(MVPCArray) && any(MVPCArray(:)>length(observe_DECODE.ALLMVPC)))
            MVPCArray = length(observe_DECODE.ALLMVPC);
            observe_DECODE.MVPC = observe_DECODE.ALLMVPC(end);
            observe_DECODE.CURRENTMVPC = MVPCArray;
            estudioworkingmemory('MVPCArray',MVPCArray);
        end
        
        [def, minydef, maxydef] = default_amp_ticks_decode(observe_DECODE.ALLMVPC(MVPCArray));
        if ~isempty(minydef) && ~isempty(maxydef)
            if minydef==maxydef
                minydef=0;
                maxydef=1;
            end
        elseif isempty(minydef) || isempty(maxydef)
            minydef=0;
            maxydef=1;
        end
        Yscales_low = str2num(MVPC_plotset.yscale_low.String);
        Yscales_high = str2num(MVPC_plotset.yscale_high.String);
        
        if isempty(Yscales_high) || numel(Yscales_high)~=1
            MVPC_plotset.yscale_high.String = num2str(maxydef);
            Yscales_high= maxydef;
            msgboxText = ['Plotting MVPCsets> Amplitude Axis: You did set right edge of amplitude scale to be a single number and we used the default one '];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
        if any(Yscales_high<=Yscales_low)
            MVPC_plotset.yscale_low.String = num2str(minydef);
            MVPC_plotset.yscale_high.String = num2str(maxydef);
            msgboxText=['Plotting MVPCsets> Amplitude Axis: Left edge of amplitude scale should be smaller than the right one and we used the default ones '];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
    end

%%------------------y ticks automatically----------------------------------
    function ytick_auto(Source,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex==1
            observe_DECODE.Count_currentMVPC=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('MVPC_plotset',1);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_apply.ForegroundColor = [1 1 1];
        MVPC_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_reset.ForegroundColor = [1 1 1];
        MVPC_plotset.plot_ops.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_ops.ForegroundColor = [1 1 1];
        MVPCArray= estudioworkingmemory('MVPCArray');
        if isempty(MVPCArray) || (~isempty(MVPCArray) && any(MVPCArray(:)>length(observe_DECODE.ALLMVPC)))
            MVPCArray = length(observe_DECODE.ALLMVPC);
            observe_DECODE.MVPC = observe_DECODE.ALLMVPC(end);
            observe_DECODE.CURRENTMVPC = MVPCArray;
            estudioworkingmemory('MVPCArray',MVPCArray);
        end
        [def, minydef, maxydef] = default_amp_ticks_decode(observe_DECODE.ALLMVPC(MVPCArray));
        if ~isempty(minydef) && ~isempty(maxydef)
            if minydef==maxydef
                minydef=0;
                maxydef=1;
            end
        elseif isempty(minydef) || isempty(maxydef)
            minydef=0;
            maxydef=1;
        end
        Yscales_low = str2num(MVPC_plotset.yscale_low.String);
        Yscales_high = str2num(MVPC_plotset.yscale_high.String);
        if isempty(Yscales_low) || numel(Yscales_low)~=1
            MVPC_plotset.yscale_low.String = num2str(minydef);
            Yscales_low= minydef;
        end
        if isempty(Yscales_high) || numel(Yscales_high)~=1
            Yscales_high= maxydef;
            MVPC_plotset.yscale_high.String = num2str(maxydef);
        end
        if any(Yscales_high<=Yscales_low)
            Yscales_high= maxydef;
            Yscales_low= minydef;
            MVPC_plotset.yscale_low.String = num2str(minydef);
            MVPC_plotset.yscale_high.String = num2str(maxydef);
        end
        if MVPC_plotset.ytick_auto.Value==1
            defyticks = default_amp_ticks_viewer([Yscales_low,Yscales_high]);
            defyticks = str2num(defyticks);
            if ~isempty(defyticks) && numel(defyticks)>=2
                MVPC_plotset.yscale_step.String = num2str(min(diff(defyticks)));
            else
                MVPC_plotset.yscale_step.String = num2str(floor((Yscales_high-Yscales_low)/2));
            end
            MVPC_plotset.yscale_step.Enable = 'off';
        else
            MVPC_plotset.yscale_step.Enable = 'on';
        end
    end

%%---------------------------------Amplitude Axis change---------------------------------*
    function yscale_step(src, ~ )
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        estudioworkingmemory('MVPC_plotset',1);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_apply.ForegroundColor = [1 1 1];
        MVPC_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_reset.ForegroundColor = [1 1 1];
        MVPC_plotset.plot_ops.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_ops.ForegroundColor = [1 1 1];
        val = str2num(src.String);
        if isempty(val)  || numel(val)~=1 || any(val(:)<=0)
            src.String = '';
            msgboxText =  ['Plotting MVPCsets> Amplitude Axis - Input must be a positive value'];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
    end

%%------------------------precision for y axis-----------------------------
    function yticksprecison(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        estudioworkingmemory('MVPC_plotset',1);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_apply.ForegroundColor = [1 1 1];
        MVPC_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_reset.ForegroundColor = [1 1 1];
        MVPC_plotset.plot_ops.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_ops.ForegroundColor = [1 1 1];
    end
%%----------------------------font for y axis------------------------------
    function yaxisfont(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        estudioworkingmemory('MVPC_plotset',1);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_apply.ForegroundColor = [1 1 1];
        MVPC_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_reset.ForegroundColor = [1 1 1];
        MVPC_plotset.plot_ops.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_ops.ForegroundColor = [1 1 1];
    end

%%------------------------font size fort  y axis---------------------------
    function yaxisfontsize(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        estudioworkingmemory('MVPC_plotset',1);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_apply.ForegroundColor = [1 1 1];
        MVPC_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_reset.ForegroundColor = [1 1 1];
        MVPC_plotset.plot_ops.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_ops.ForegroundColor = [1 1 1];
    end

%%-----------------------text color for y axis-----------------------------
    function yaxisfontcolor(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        estudioworkingmemory('MVPC_plotset',1);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_apply.ForegroundColor = [1 1 1];
        MVPC_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_reset.ForegroundColor = [1 1 1];
        MVPC_plotset.plot_ops.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_ops.ForegroundColor = [1 1 1];
    end

%%---------------------standard error of mean------------------------------
    function showSEM(Source,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex==1
            observe_DECODE.Count_currentMVPC=eegpanelIndex+1;%%call the functions from the other panel
        end
        estudioworkingmemory('MVPC_plotset',1);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_apply.ForegroundColor = [1 1 1];
        MVPC_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_reset.ForegroundColor = [1 1 1];
        MVPC_plotset.plot_ops.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_ops.ForegroundColor = [1 1 1];
        if Source.Value ==1
            MVPC_plotset.SEM_custom.Enable = 'on';
            MVPC_plotset.SEMtrans_custom.Enable = 'on';
        else
            MVPC_plotset.SEM_custom.Enable = 'off';
            MVPC_plotset.SEMtrans_custom.Enable = 'off';
        end
    end

%%-------------------------number of SD------------------------------------
    function SEMerror(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex==1
            observe_DECODE.Count_currentMVPC=eegpanelIndex+1;%%call the functions from the other panel
        end
        estudioworkingmemory('MVPC_plotset',1);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_apply.ForegroundColor = [1 1 1];
        MVPC_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_reset.ForegroundColor = [1 1 1];
        MVPC_plotset.plot_ops.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_ops.ForegroundColor = [1 1 1];
    end


    function SEMtrans(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        estudioworkingmemory('MVPC_plotset',1);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_apply.ForegroundColor = [1 1 1];
        MVPC_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_reset.ForegroundColor = [1 1 1];
        MVPC_plotset.plot_ops.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_ops.ForegroundColor = [1 1 1];
    end

%%---------------------------chance line-----------------------------------
    function chanceline(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        estudioworkingmemory('MVPC_plotset',1);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_apply.ForegroundColor = [1 1 1];
        MVPC_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_reset.ForegroundColor = [1 1 1];
        MVPC_plotset.plot_ops.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_ops.ForegroundColor = [1 1 1];
    end

%%--------------Reset the parameters for plotting panel--------------------
    function plot_cancel(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        estudioworkingmemory('MVPC_plotset',0);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 1 1 1];
        MVPC_plotset.plot_apply.ForegroundColor = [0 0 0];
        MVPC_plotset_box.TitleColor= [0.0500    0.2500    0.5000];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [1 1 1];
        MVPC_plotset.plot_reset.ForegroundColor = [0 0 0];
        MVPC_plotset.plot_ops.BackgroundColor =  [ 1 1 1];
        MVPC_plotset.plot_ops.ForegroundColor = [0 0 0];
        estudioworkingmemory('f_decode_proces_messg','Plotting MVPCsets>Cancel');
        observe_DECODE.Process_messg =1;
        %
        %%------------------------------time range-------------------------
        MVPC_plotset.timet_auto.Value=MVPC_plotset.paras{1};
        MVPC_plotset.timetick_auto.Value=MVPC_plotset.paras{3};
        timelowdef = observe_DECODE.MVPC.times(1);
        timehighdef= observe_DECODE.MVPC.times(end);
        [def xtickstepdef]= default_time_ticks_decode(observe_DECODE.MVPC, [timelowdef,timehighdef]);
        if MVPC_plotset.timet_auto.Value==1
            Enablerange = 'off';
            timelow = timelowdef;
            timehigh = timehighdef;
        else
            Enablerange = 'on';
            try
                timerange = MVPC_plotset.paras{2};
                timelow = timerange(1);
                timehigh = timerange(2);
            catch
                timelow = timelowdef;
                timehigh = timehighdef;
            end
        end
        if MVPC_plotset.timetick_auto.Value==1
            xtickstep = xtickstepdef;
            Enablerange1 = 'off';
        else
            try
                xtickstep = MVPC_plotset.paras{4};
            catch
                xtickstep = xtickstepdef;
            end
            Enablerange1 = 'on';
        end
        
        if isempty(timelow) || numel(timelow)~=1 || timelow>=timehighdef
            timelow = timelowdef;
        end
        if isempty(timehigh) || numel(timehigh)~=1 || timehigh<=timelowdef
            timehigh = timehighdef;
        end
        if timelow>timehigh
            timelow = timelowdef;
            timehigh = timehighdef;
        end
        if isempty(xtickstep) || numel(xtickstep)~=1 || any(xtickstep(:)<=0) || xtickstep>=(timehigh-timelow)
            xtickstep = xtickstepdef;
        end
        MVPC_plotset.timet_low.Enable = Enablerange;
        MVPC_plotset.timet_high.Enable =  Enablerange;
        MVPC_plotset.timet_step.Enable = Enablerange1;
        MVPC_plotset.timet_low.String = num2str(timelow);
        MVPC_plotset.timet_high.String = num2str(timehigh);
        MVPC_plotset.timet_step.String =  num2str(xtickstep);
        %%precision for x axis
        try xticks_precision = MVPC_plotset.paras{5}; catch xticks_precision=1; end
        if isempty(xticks_precision) || numel(xticks_precision)~=1 || any(xticks_precision(:)<1) || any(xticks_precision(:)>7)
            xticks_precision=1;
        end
        MVPC_plotset.xticks_precision.Value = xticks_precision;
        %%font for x axis
        try xtimefont_custom=MVPC_plotset.paras{6}; catch  xtimefont_custom=1;end
        if isempty(xtimefont_custom) || numel(xtimefont_custom)~=1 || any(xtimefont_custom(:)<1) || any(xtimefont_custom(:)>5)
            xtimefont_custom=1;
        end
        MVPC_plotset.xtimefont_custom.Value=xtimefont_custom;
        %%font size for x axis
        try xtimefontsize=MVPC_plotset.paras{7}; catch  xtimefontsize=5;end
        if isempty(xtimefontsize) || numel(xtimefontsize)~=1 || any(xtimefontsize(:)<1) || any(xtimefontsize(:)>20)
            xtimefontsize=5;
        end
        MVPC_plotset.xtimefontsize.Value = xtimefontsize;
        %%text color for x axis
        try xtimetextcolor=MVPC_plotset.paras{8}; catch  xtimetextcolor=1;end
        if isempty(xtimetextcolor) || numel(xtimetextcolor)~=1 || any(xtimetextcolor(:)<1) || any(xtimetextcolor(:)>7)
            xtimetextcolor=5;
        end
        MVPC_plotset.xtimetextcolor.Value = xtimetextcolor;
        %
        %%------------------------Amplitude Axis----------------------------------
        MVPC_plotset.yscale_auto.Value = MVPC_plotset.paras{9};
        MVPC_plotset.ytick_auto.Value = MVPC_plotset.paras{11};
        
        MVPCArray= estudioworkingmemory('MVPCArray');
        if isempty(MVPCArray) || (~isempty(MVPCArray) && any(MVPCArray(:)>length(observe_DECODE.ALLMVPC)))
            MVPCArray = length(observe_DECODE.ALLMVPC);
            observe_DECODE.MVPC = observe_DECODE.ALLMVPC(end);
            observe_DECODE.CURRENTMVPC = MVPCArray;
            estudioworkingmemory('MVPCArray',MVPCArray);
        end
        
        [def, minydef, maxydef] = default_amp_ticks_decode(observe_DECODE.ALLMVPC(MVPCArray));
        if ~isempty(minydef) && ~isempty(maxydef)
            if minydef==maxydef
                minydef=0;
                maxydef=1;
            end
        elseif isempty(minydef) || isempty(maxydef)
            minydef=0;
            maxydef=1;
        end
        
        try Yscale = MVPC_plotset.paras{10}; catch Yscale=[]; end
        try Yscales_low = Yscale(1);catch Yscales_low=[];end
        try Yscales_high = Yscale(2);catch Yscales_high=[];end
        if isempty(Yscales_low) || numel(Yscales_low)~=1
            MVPC_plotset.yscale_low.String = str2num(minydef);
            Yscales_low= minydef;
        end
        if isempty(Yscales_high) || numel(Yscales_high)~=1
            MVPC_plotset.yscale_high.String = str2num(maxydef);
        end
        if any(Yscales_high<=Yscales_low)
            MVPC_plotset.yscale_low.String = str2num(minydef);
            MVPC_plotset.yscale_high.String = str2num(maxydef);
            Yscales_high= maxydef;
            Yscales_low= minydef;
        end
        
        if  MVPC_plotset.yscale_auto.Value==0
            MVPC_plotset.yscale_low.Enable = 'on';
            MVPC_plotset.yscale_high.Enable = 'on';
        else
            Yscales_high= maxydef;
            Yscales_low= minydef;
            MVPC_plotset.yscale_low.Enable = 'off';
            MVPC_plotset.yscale_high.Enable = 'off';
        end
        MVPC_plotset.yscale_low.String = num2str(Yscales_low);
        MVPC_plotset.yscale_high.String = num2str(Yscales_high);
        
        if MVPC_plotset.ytick_auto.Value==1
            MVPC_plotset.yscale_step.Enable = 'off';
            defyticks = default_amp_ticks_viewer([Yscales_low,Yscales_high]);
            defyticks = str2num(defyticks);
            if ~isempty(defyticks) && numel(defyticks)>=2
                MVPC_plotset.yscale_step.String = num2str(min(diff(defyticks)));
            else
                MVPC_plotset.yscale_step.String = num2str(floor((Yscales_high-Yscales_low)/2));
            end
        else
            MVPC_plotset.yscale_step.Enable= 'on';
            yscale= MVPC_plotset.paras{12};
            MVPC_plotset.yscale_step.String = num2str(yscale);
        end
        %%precision for y axis
        try yticks_precision = MVPC_plotset.paras{13}; catch yticks_precision=1; end
        if isempty(yticks_precision) || numel(yticks_precision)~=1 || any(yticks_precision(:)<1) || any(yticks_precision(:)>7)
            yticks_precision=1;
        end
        MVPC_plotset.yticks_precision.Value=yticks_precision;
        
        
        %%font for y axis
        try yfont_custom=MVPC_plotset.paras{14}; catch  yfont_custom=1;end
        if isempty(yfont_custom) || numel(yfont_custom)~=1 || any(yfont_custom(:)<1) || any(yfont_custom(:)>5)
            yfont_custom=1;
        end
        MVPC_plotset.yfont_custom.Value=yfont_custom;
        %%font size for y axis
        try yfont_custom_size=MVPC_plotset.paras{15}; catch  yfont_custom_size=5;end
        if isempty(yfont_custom_size) || numel(yfont_custom_size)~=1 || any(yfont_custom_size(:)<1) || any(yfont_custom_size(:)>20)
            yfont_custom_size=5;
        end
        MVPC_plotset.yfont_custom_size.Value = yfont_custom_size;
        %%text color for y axis
        try ytextcolor=MVPC_plotset.paras{16}; catch  ytextcolor=1;end
        if isempty(ytextcolor) || numel(ytextcolor)~=1 || any(ytextcolor(:)<1) || any(ytextcolor(:)>7)
            ytextcolor=5;
        end
        MVPC_plotset.ytextcolor.Value = ytextcolor;
        
        %%-------SEM----------
        try SMEFlag = MVPC_plotset.paras{17};catch SMEFlag = [0 2 3];end
        try show_SEM = SMEFlag(1);catch show_SEM=0; end
        if isempty(show_SEM) || numel(show_SEM)~=1 ||(show_SEM~=0&& show_SEM~=1)
            show_SEM=0;
        end
        MVPC_plotset.show_SEM.Value = show_SEM;
        if  MVPC_plotset.show_SEM.Value == 1
            MVPC_plotset.SEM_custom.Enable = 'on';
            MVPC_plotset.SEMtrans_custom.Enable = 'on';
        else
            MVPC_plotset.SEM_custom.Enable = 'off';
            MVPC_plotset.SEMtrans_custom.Enable = 'off';
        end
        
        try SEM_custom = SMEFlag(2);catch SEM_custom = 2; end
        if isempty(SEM_custom)|| numel(SEM_custom)~=1 || any(SEM_custom<0) || any(SEM_custom>11)
            SEM_custom=2;
        end
        MVPC_plotset.SEM_custom.Value = SEM_custom;
        
        try SEMtrans_custom = SMEFlag(3);catch SEMtrans_custom = 3; end
        if isempty(SEMtrans_custom)|| numel(SEMtrans_custom)~=1 || any(SEMtrans_custom<0) || any(SEMtrans_custom>11)
            SEMtrans_custom=3;
        end
        MVPC_plotset.SEMtrans_custom.Value = SEMtrans_custom;
        
        try chanceline = MVPC_plotset.paras{18}; catch  chanceline=0; end
        if isempty(chanceline) || numel(chanceline)~=1 || (chanceline~=0 && chanceline~=1)
            chanceline=0;
        end
        MVPC_plotset.chanceline.Value = chanceline;
        
        MVPC_plotset.paras{1} = MVPC_plotset.timet_auto.Value;
        MVPC_plotset.paras{2} = [str2num(MVPC_plotset.timet_low.String),str2num(MVPC_plotset.timet_high.String)];
        MVPC_plotset.paras{3} = MVPC_plotset.ytick_auto.Value;
        MVPC_plotset.paras{4} = str2num(MVPC_plotset.timet_step.String);
        MVPC_plotset.paras{5} = MVPC_plotset.xticks_precision.Value; %%precision for x axis
        MVPC_plotset.paras{6} = MVPC_plotset.xtimefont_custom.Value; %%font for x axis
        MVPC_plotset.paras{7} = MVPC_plotset.xtimefontsize.Value; %%fontsize for x axis
        MVPC_plotset.paras{8} = MVPC_plotset.xtimetextcolor.Value;%%text color for x axis
        MVPC_plotset.paras{9} =MVPC_plotset.yscale_auto.Value;
        MVPC_plotset.paras{10} = [str2num(MVPC_plotset.yscale_low.String),str2num(MVPC_plotset.yscale_high.String)];
        MVPC_plotset.paras{11} =MVPC_plotset.ytick_auto.Value;
        MVPC_plotset.paras{12} =str2num(MVPC_plotset.yscale_step.String);
        MVPC_plotset.paras{13} =MVPC_plotset.yticks_precision.Value;
        MVPC_plotset.paras{14} =MVPC_plotset.yfont_custom.Value;
        MVPC_plotset.paras{15} =MVPC_plotset.yfont_custom_size.Value;
        MVPC_plotset.paras{16} =MVPC_plotset.ytextcolor.Value;
        MVPC_plotset.paras{17} = [MVPC_plotset.show_SEM.Value MVPC_plotset.SEM_custom.Value MVPC_plotset.SEMtrans_custom.Value];
        MVPC_plotset.paras{18}=MVPC_plotset.chanceline.Value;
        estudioworkingmemory('MVPC_plotset_pars',MVPC_plotset.paras);
        observe_DECODE.Process_messg =2;
    end

%%----------------------------------option---------------------------------
    function plot_ops(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        estudioworkingmemory('MVPC_plotset',1);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_apply.ForegroundColor = [1 1 1];
        MVPC_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_reset.ForegroundColor = [1 1 1];
        MVPC_plotset.plot_ops.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        MVPC_plotset.plot_ops.ForegroundColor = [1 1 1];
        
        MVPC_lineslegendops= estudioworkingmemory('MVPC_lineslegendops');
        try Lineparas =  MVPC_lineslegendops{1}; catch  Lineparas = [];end
        try legendparas=  MVPC_lineslegendops{2}; catch  legendparas = [];end
        
        MVPCArray= estudioworkingmemory('MVPCArray');
        if isempty(MVPCArray) || (~isempty(MVPCArray) && any(MVPCArray(:)>length(observe_DECODE.ALLMVPC)))
            MVPCArray = length(observe_DECODE.ALLMVPC);
            observe_DECODE.MVPC = observe_DECODE.ALLMVPC(end);
            observe_DECODE.CURRENTMVPC = MVPCArray;
            estudioworkingmemory('MVPCArray',MVPCArray);
        end
        [serror, msgwrng] = f_checkmvpc( observe_DECODE.ALLMVPC,MVPCArray);
        if serror==1 && ~isempty(msgwrng)
            try legendparas{4} = '1'; catch   end
        else
            try legendparas{4} = num2str(ceil(sqrt(MVPCArray))); catch   end
        end
        
        
        app = feval('Decode_mvpc_line_legend_ops',Lineparas,legendparas);
        waitfor(app,'Finishbutton',1);
        try
            MVPC_lineslegendops = app.Output; %NO you don't want to output EEG with edited channel locations, you want to output the parameters to run decoding
            app.delete; %delete app from view
            pause(0.1); %wait for app to leave
        catch
            return;
        end
        if isempty(MVPC_lineslegendops)
            return;
        end
        
        estudioworkingmemory('MVPC_lineslegendops',MVPC_lineslegendops);
        
    end

%------------Apply current parameters in plotting panel to the selected ERPset---------
    function plot_setting_apply(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        
        estudioworkingmemory('MVPC_plotset',0);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 1 1 1];
        MVPC_plotset.plot_apply.ForegroundColor = [0 0 0];
        MVPC_plotset_box.TitleColor= [0.0500    0.2500    0.5000];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [1 1 1];
        MVPC_plotset.plot_reset.ForegroundColor = [0 0 0];
        MVPC_plotset.plot_ops.BackgroundColor =  [1 1 1];
        MVPC_plotset.plot_ops.ForegroundColor = [0 0 0];
        estudioworkingmemory('f_decode_proces_messg','Plotting MVPCsets>Apply');
        observe_DECODE.Process_messg =1;
        %
        %%time range
        timeStartdef = observe_DECODE.MVPC.times(1);
        timEnddef = observe_DECODE.MVPC.times(end);
        [def xstepdef]= default_time_ticks_decode(observe_DECODE.MVPC, [observe_DECODE.MVPC.times(1),observe_DECODE.MVPC.times(end)]);
        timeStart = str2num(MVPC_plotset.timet_low.String);
        if isempty(timeStart) || numel(timeStart)~=1 ||  timeStart>=observe_DECODE.MVPC.times(end)
            timeStart = timeStartdef;
            MVPC_plotset.timet_low.String = num2str(observe_DECODE.MVPC.times(1));
            msgboxText= char(['Plotting MVPCsets > Apply: Low edge of the time range should be smaller',32,num2str(observe_DECODE.MVPC.times(end)),32,...
                'we therefore set to be',32,num2str(timeStart)]);
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
        
        timEnd = str2num(MVPC_plotset.timet_high.String);
        if isempty(timEnd) || numel(timEnd)~=1 || timEnd<=observe_DECODE.MVPC.times(1)
            timEnd = timEnddef;
            MVPC_plotset.timet_high.String = num2str(timEnd);
            msgboxText= char(['Plotting MVPCsets > Apply: High edge of the time range should be larger',32,num2str(timeStartdef),32,...
                'we therefore set to be',32,num2str(timEnddef)]);
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
        
        if timeStart>= timEnd
            timEnd = timEnddef;
            timeStart = timeStartdef;
            MVPC_plotset.timet_low.String = num2str(timeStart);
            MVPC_plotset.timet_high.String = num2str(timEnd);
            msgboxText= char(['Plotting MVPCsets > Apply: Low edge of the time range should be smaller than the high one and we therefore used the defaults']);
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
        
        xtickstep = str2num(MVPC_plotset.timet_step.String);
        if isempty(xtickstep) || numel(xtickstep)~=1 ||  any(xtickstep<=0)
            xtickstep = xstepdef;
            MVPC_plotset.timet_step.String = num2str(xtickstep);
            msgboxText= char(['Plotting MVPCsets > Apply: the step of the time ticks should be a positive number that belows',32,num2str(floor((timEnd-timeStart)/2))]);
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
        %
        %%Amplitude Axis
        MVPCArray= estudioworkingmemory('MVPCArray');
        if isempty(MVPCArray) || (~isempty(MVPCArray) && any(MVPCArray(:)>length(observe_DECODE.ALLMVPC)))
            MVPCArray = length(observe_DECODE.ALLMVPC);
            observe_DECODE.MVPC = observe_DECODE.ALLMVPC(end);
            observe_DECODE.CURRENTMVPC = MVPCArray;
            estudioworkingmemory('MVPCArray',MVPCArray);
        end
        
        [def, minydef, maxydef] = default_amp_ticks_decode(observe_DECODE.ALLMVPC(MVPCArray));
        if ~isempty(minydef) && ~isempty(maxydef)
            if minydef==maxydef
                minydef=0;
                maxydef=1;
            end
        elseif isempty(minydef) || isempty(maxydef)
            minydef=0;
            maxydef=1;
        end
        Yscales_low = str2num(MVPC_plotset.yscale_low.String);
        Yscales_high = str2num(MVPC_plotset.yscale_high.String);
        if isempty(Yscales_low) || numel(Yscales_low)~=1
            MVPC_plotset.yscale_low.String = num2str(minydef);
            Yscales_low= minydef;
            msgboxText = ['Plotting MVPCsets> Amplitude Axis: You did set left edge of amplitude scale to be a single number and we used the default one '];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
        if isempty(Yscales_high) || numel(Yscales_high)~=1
            MVPC_plotset.yscale_high.String = num2str(maxydef);
            Yscales_high= maxydef;
            msgboxText = ['Plotting MVPCsets> Amplitude Axis: You did set right edge of amplitude scale to be a single number and we used the default one '];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
        if any(Yscales_high<=Yscales_low)
            MVPC_plotset.yscale_low.String = num2str(minydef);
            MVPC_plotset.yscale_high.String = num2str(maxydef);
            Yscales_high= maxydef;
            Yscales_low= minydef;
            msgboxText=['Plotting MVPCsets> Amplitude Axis: Left edge of amplitude scale should be smaller than the right one and we used the default ones '];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
        if MVPC_plotset.show_SEM.Value == 1
            MVPC_plotset.SEM_custom.Enable = 'on';
            MVPC_plotset.SEMtrans_custom.Enable = 'on';
        else
        end
        MVPC_plotset.paras{1} = MVPC_plotset.timet_auto.Value;
        MVPC_plotset.paras{2} = [str2num(MVPC_plotset.timet_low.String),str2num(MVPC_plotset.timet_high.String)];
        MVPC_plotset.paras{3} = MVPC_plotset.ytick_auto.Value;
        MVPC_plotset.paras{4} = str2num(MVPC_plotset.timet_step.String);
        MVPC_plotset.paras{5} = MVPC_plotset.xticks_precision.Value; %%precision for x axis
        MVPC_plotset.paras{6} = MVPC_plotset.xtimefont_custom.Value; %%font for x axis
        MVPC_plotset.paras{7} = MVPC_plotset.xtimefontsize.Value; %%fontsize for x axis
        MVPC_plotset.paras{8} = MVPC_plotset.xtimetextcolor.Value;%%text color for x axis
        MVPC_plotset.paras{9} =MVPC_plotset.yscale_auto.Value;
        MVPC_plotset.paras{10} = [str2num(MVPC_plotset.yscale_low.String),str2num(MVPC_plotset.yscale_high.String)];
        MVPC_plotset.paras{11} =MVPC_plotset.ytick_auto.Value;
        MVPC_plotset.paras{12} =str2num(MVPC_plotset.yscale_step.String);
        MVPC_plotset.paras{13} =MVPC_plotset.yticks_precision.Value;
        MVPC_plotset.paras{14} =MVPC_plotset.yfont_custom.Value;
        MVPC_plotset.paras{15} =MVPC_plotset.yfont_custom_size.Value;
        MVPC_plotset.paras{16} =MVPC_plotset.ytextcolor.Value;
        MVPC_plotset.paras{17} = [MVPC_plotset.show_SEM.Value MVPC_plotset.SEM_custom.Value MVPC_plotset.SEMtrans_custom.Value];
        MVPC_plotset.paras{18}=MVPC_plotset.chanceline.Value;
        estudioworkingmemory('MVPC_plotset_pars',MVPC_plotset.paras);
        
        observe_DECODE.Count_currentMVPC=1;
    end

%%-------------------------------------------------------------------------
    function Count_currentMVPC_changed(~,~)
        if observe_DECODE.Count_currentMVPC~=3
            return;
        end
        ViewerFlag=estudioworkingmemory('ViewerFlag');%%when open advanced wave viewer
        if isempty(ViewerFlag) || (ViewerFlag~=0 && ViewerFlag~=1)
            ViewerFlag=0;estudioworkingmemory('ViewerFlag',0);
        end
        if isempty(observe_DECODE.ALLMVPC)|| isempty(observe_DECODE.MVPC) || ViewerFlag==1
            enbaleflag = 'off';
        else
            enbaleflag = 'on';
        end
        MVPC_plotset.timet_auto.Enable =enbaleflag;
        MVPC_plotset.timet_low.Enable =enbaleflag;
        MVPC_plotset.timet_high.Enable =enbaleflag;
        MVPC_plotset.timetick_auto.Enable =enbaleflag;
        MVPC_plotset.timet_step.Enable =enbaleflag;
        MVPC_plotset.yscale_auto.Enable =enbaleflag;
        MVPC_plotset.yscale_low.Enable =enbaleflag;
        MVPC_plotset.yscale_high.Enable =enbaleflag;
        MVPC_plotset.ytick_auto.Enable =enbaleflag;
        MVPC_plotset.yscale_step.Enable =enbaleflag;
        MVPC_plotset.xticks_precision.Enable =enbaleflag;
        MVPC_plotset.xtimefont_custom.Enable =enbaleflag;
        MVPC_plotset.xtimefontsize.Enable =enbaleflag;
        MVPC_plotset.xtimetextcolor.Enable =enbaleflag;
        MVPC_plotset.yticks_precision.Enable =enbaleflag;
        MVPC_plotset.yfont_custom.Enable =enbaleflag;
        MVPC_plotset.yfont_custom_size.Enable =enbaleflag;
        MVPC_plotset.ytextcolor.Enable =enbaleflag;
        MVPC_plotset.SEM_custom.Enable = enbaleflag;
        MVPC_plotset.SEMtrans_custom.Enable = enbaleflag;
        MVPC_plotset.show_SEM.Enable = enbaleflag;
        MVPC_plotset.chanceline.Enable = enbaleflag;
        MVPC_plotset.plot_reset.Enable =enbaleflag;
        MVPC_plotset.plot_apply.Enable =enbaleflag;
        MVPC_plotset.plot_ops.Enable =enbaleflag;
        if isempty(observe_DECODE.ALLMVPC)|| isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC =4;
            return;
        end
        %%time range
        if MVPC_plotset.timet_auto.Value == 1
            MVPC_plotset.timet_low.String = num2str(observe_DECODE.MVPC.times(1));
            MVPC_plotset.timet_low.Enable = 'off';
            MVPC_plotset.timet_high.String = num2str(observe_DECODE.MVPC.times(end));
            MVPC_plotset.timet_high.Enable =  'off';
        end
        timeStart = str2num(MVPC_plotset.timet_low.String);
        if isempty(timeStart) || numel(timeStart)~=1 || timeStart>observe_DECODE.MVPC.times(end) %%|| timeStart<observe_DECODE.MVPC.times(1)
            timeStart = observe_DECODE.MVPC.times(1);
            MVPC_plotset.timet_low.String = num2str(observe_DECODE.MVPC.times(1));
        end
        timEnd = str2num(MVPC_plotset.timet_high.String);
        if isempty(timEnd) || numel(timEnd)~=1 || timEnd<observe_DECODE.MVPC.times(1) %%|| timEnd> observe_DECODE.MVPC.times(end)
            timEnd = observe_DECODE.MVPC.times(end);
            MVPC_plotset.timet_high.String = num2str(observe_DECODE.MVPC.times(end));
        end
        if timeStart>timEnd
            MVPC_plotset.timet_low.String = num2str(observe_DECODE.MVPC.times(1));
            MVPC_plotset.timet_high.String = num2str(observe_DECODE.MVPC.times(end));
            timeStart = observe_DECODE.MVPC.times(1);
            timEnd = observe_DECODE.MVPC.times(end);
        end
        [def xstep]= default_time_ticks_decode(observe_DECODE.MVPC, [timeStart,timEnd]);
        if MVPC_plotset.timetick_auto.Value==1
            MVPC_plotset.timet_step.String = num2str(xstep);
            MVPC_plotset.timet_step.Enable = 'off';
        end
        xtickstep = str2num(MVPC_plotset.timet_step.String);
        if isempty(xtickstep) || numel(xtickstep)~=1 || xtickstep> floor((timEnd-timeStart)/2)
            xtickstep= xstep;
            MVPC_plotset.timet_step.String = num2str(xstep);
        end
        %
        %%Amplitude Axis
        %%Yscale
        MVPCArray= estudioworkingmemory('MVPCArray');
        if isempty(MVPCArray) || (~isempty(MVPCArray) && any(MVPCArray(:)>length(observe_DECODE.ALLMVPC)))
            MVPCArray = length(observe_DECODE.ALLMVPC);
            observe_DECODE.MVPC = observe_DECODE.ALLMVPC(end);
            observe_DECODE.CURRENTMVPC = MVPCArray;
            estudioworkingmemory('MVPCArray',MVPCArray);
        end
        
        [def, minydef, maxydef] = default_amp_ticks_decode(observe_DECODE.ALLMVPC(MVPCArray));
        if ~isempty(minydef) && ~isempty(maxydef)
            if minydef==maxydef
                minydef=0;
                maxydef=1;
            end
        elseif isempty(minydef) || isempty(maxydef)
            minydef=0;
            maxydef=1;
        end
        if MVPC_plotset.yscale_auto.Value ==1
            MVPC_plotset.yscale_low.Enable = 'off';
            MVPC_plotset.yscale_high.Enable = 'off';
            MVPC_plotset.yscale_low.String = num2str(minydef);
            MVPC_plotset.yscale_high.String = num2str(maxydef);
        end
        Yscales_low = str2num(MVPC_plotset.yscale_low.String);
        Yscales_high = str2num(MVPC_plotset.yscale_high.String);
        if isempty(Yscales_low) || numel(Yscales_low)~=1
            MVPC_plotset.yscale_low.String = num2str(minydef);
            Yscales_low= minydef;
        end
        if isempty(Yscales_high) || numel(Yscales_high)~=1
            MVPC_plotset.yscale_high.String = num2str(maxydef);
            Yscales_high= maxydef;
        end
        if any(Yscales_high<=Yscales_low)
            MVPC_plotset.yscale_low.String = num2str(minydef);
            Yscales_low= minydef;
            MVPC_plotset.yscale_high.String = num2str(maxydef);
            Yscales_high= maxydef;
        end
        
        if MVPC_plotset.ytick_auto.Value==1
            defyticks = default_amp_ticks_viewer([Yscales_low,Yscales_high]);
            defyticks = str2num(defyticks);
            if ~isempty(defyticks) && numel(defyticks)>=2
                MVPC_plotset.yscale_step.String = num2str(min(diff(defyticks)));
            else
                MVPC_plotset.yscale_step.String = num2str(floor((Yscales_high-Yscales_low)/2));
            end
            MVPC_plotset.yscale_step.Enable = 'off';
        end
        if isempty(observe_DECODE.MVPC.stderror)
            MVPC_plotset.show_SEM.Value=0;
            MVPC_plotset.show_SEM.Enable = 'off';
        else
            MVPC_plotset.show_SEM.Enable = 'on';
        end
        %%standard error
        if MVPC_plotset.show_SEM.Value == 1
            MVPC_plotset.SEM_custom.Enable = 'on';
            MVPC_plotset.SEMtrans_custom.Enable = 'on';
        else
            MVPC_plotset.SEM_custom.Enable = 'off';
            MVPC_plotset.SEMtrans_custom.Enable = 'off';
        end
        MVPC_plotset.paras{1} = MVPC_plotset.timet_auto.Value;
        MVPC_plotset.paras{2} = [str2num(MVPC_plotset.timet_low.String),str2num(MVPC_plotset.timet_high.String)];
        MVPC_plotset.paras{3} = MVPC_plotset.ytick_auto.Value;
        MVPC_plotset.paras{4} = str2num(MVPC_plotset.timet_step.String);
        MVPC_plotset.paras{5} = MVPC_plotset.xticks_precision.Value; %%precision for x axis
        MVPC_plotset.paras{6} = MVPC_plotset.xtimefont_custom.Value; %%font for x axis
        MVPC_plotset.paras{7} = MVPC_plotset.xtimefontsize.Value; %%fontsize for x axis
        MVPC_plotset.paras{8} = MVPC_plotset.xtimetextcolor.Value;%%text color for x axis
        MVPC_plotset.paras{9} =MVPC_plotset.yscale_auto.Value;
        MVPC_plotset.paras{10} = [str2num(MVPC_plotset.yscale_low.String),str2num(MVPC_plotset.yscale_high.String)];
        MVPC_plotset.paras{11} =MVPC_plotset.ytick_auto.Value;
        MVPC_plotset.paras{12} =str2num(MVPC_plotset.yscale_step.String);
        MVPC_plotset.paras{13} =MVPC_plotset.yticks_precision.Value;
        MVPC_plotset.paras{14} =MVPC_plotset.yfont_custom.Value;
        MVPC_plotset.paras{15} =MVPC_plotset.yfont_custom_size.Value;
        MVPC_plotset.paras{16} =MVPC_plotset.ytextcolor.Value;
        MVPC_plotset.paras{17} = [MVPC_plotset.show_SEM.Value MVPC_plotset.SEM_custom.Value MVPC_plotset.SEMtrans_custom.Value];
        MVPC_plotset.paras{18}=MVPC_plotset.chanceline.Value;MVPC_plotset_pars = MVPC_plotset.paras;
        estudioworkingmemory('MVPC_plotset_pars',MVPC_plotset_pars);
        observe_DECODE.Count_currentMVPC=4;
    end

%%--------------press return to execute "Apply"----------------------------
    function mvpc_plotsetting_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('MVPC_plotset');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            plot_setting_apply();
            estudioworkingmemory('MVPC_plotset',0);
            MVPC_plotset.plot_apply.BackgroundColor =  [ 1 1 1];
            MVPC_plotset.plot_apply.ForegroundColor = [0 0 0];
            MVPC_plotset_box.TitleColor= [0.0500    0.2500    0.5000];%% the default is [0.0500    0.2500    0.5000]
            MVPC_plotset.plot_reset.BackgroundColor =  [1 1 1];
            MVPC_plotset.plot_reset.ForegroundColor = [0 0 0];
            MVPC_plotset.plot_ops.BackgroundColor =  [1 1 1];
            MVPC_plotset.plot_ops.ForegroundColor = [0 0 0];
        else
            return;
        end
    end


%%---------------reset the parameters for all panels-----------------------
    function Reset_best_panel_change(~,~)
        if observe_DECODE.Reset_MVPC_paras_panel~=3
            return;
        end
        estudioworkingmemory('MVPC_plotset',0);
        MVPC_plotset.plot_apply.BackgroundColor =  [ 1 1 1];
        MVPC_plotset.plot_apply.ForegroundColor = [0 0 0];
        MVPC_plotset_box.TitleColor= [0.0500    0.2500    0.5000];%% the default is [0.0500    0.2500    0.5000]
        MVPC_plotset.plot_reset.BackgroundColor =  [1 1 1];
        MVPC_plotset.plot_reset.ForegroundColor = [0 0 0];
        MVPC_plotset.plot_ops.BackgroundColor =  [1 1 1];
        MVPC_plotset.plot_ops.ForegroundColor = [0 0 0];
        MVPC_plotset.timet_auto.Value=1;
        MVPC_plotset.timet_low.Enable = 'off';
        MVPC_plotset.timet_high.Enable = 'off';
        try
            MVPC_plotset.timet_low.String = num2str(observe_DECODE.MVPC.times(1));
            MVPC_plotset.timet_high.String = num2str(observe_DECODE.MVPC.times(end));
        catch
            MVPC_plotset.timet_low.String = '';
            MVPC_plotset.timet_high.String = '';
        end
        MVPC_plotset.timetick_auto.Value=1;
        
        MVPC_plotset.ytick_auto.Value=1;
        MVPC_plotset.yscale_auto.Value=1;
        if ~isempty(observe_DECODE.MVPC)
            [def xstep]= default_time_ticks_decode(observe_DECODE.MVPC, [observe_DECODE.MVPC.times(1),observe_DECODE.MVPC.times(end)]);
            MVPC_plotset.timet_step.String = num2str(xstep);
            MVPCArray= estudioworkingmemory('MVPCArray');
            if isempty(MVPCArray) || (~isempty(MVPCArray) && any(MVPCArray(:)>length(observe_DECODE.ALLMVPC)))
                MVPCArray = length(observe_DECODE.ALLMVPC);
                observe_DECODE.MVPC = observe_DECODE.ALLMVPC(end);
                observe_DECODE.CURRENTMVPC = MVPCArray;
                estudioworkingmemory('MVPCArray',MVPCArray);
            end
            [def, minydef, maxydef] = default_amp_ticks_decode(observe_DECODE.ALLMVPC(MVPCArray));
            if ~isempty(minydef) && ~isempty(maxydef)
                if minydef==maxydef
                    minydef=0;
                    maxydef=1;
                end
            elseif isempty(minydef) || isempty(maxydef)
                minydef=0;
                maxydef=1;
            end
            MVPC_plotset.yscale_low.String = num2str(minydef);
            MVPC_plotset.yscale_high.String = num2str(maxydef);
            
            defyticks = str2num(def);
            if ~isempty(defyticks) && numel(defyticks)>=2
                MVPC_plotset.yscale_step.String = num2str(min(diff(defyticks)));
            else
                MVPC_plotset.yscale_step.String = num2str(floor((Yscales_high-Yscales_low)/2));
            end
        else
            MVPC_plotset.timet_step.String = '';
            MVPC_plotset.yscale_low.String = '';
            MVPC_plotset.yscale_high.String = '';
            MVPC_plotset.yscale_step.String  = '';
        end
        MVPC_plotset.yscale_low.Enable = 'off';
        MVPC_plotset.yscale_high.Enable = 'off';
        MVPC_plotset.yscale_step.Enable = 'off';
        MVPC_plotset.xticks_precision.Value=1;
        MVPC_plotset.xtimefont_custom.Value =1;
        MVPC_plotset.xtimefontsize.Value =5;
        MVPC_plotset.xtimetextcolor.Value =1;
        %%-------x axis---------
        MVPC_plotset.paras{1} = MVPC_plotset.timet_auto.Value;
        MVPC_plotset.paras{2} = [str2num(MVPC_plotset.timet_low.String),str2num(MVPC_plotset.timet_high.String)];
        MVPC_plotset.paras{3} = MVPC_plotset.ytick_auto.Value;
        MVPC_plotset.paras{4} = str2num(MVPC_plotset.timet_step.String);
        MVPC_plotset.paras{5} = MVPC_plotset.xticks_precision.Value; %%precision for x axis
        MVPC_plotset.paras{6} = MVPC_plotset.xtimefont_custom.Value; %%font for x axis
        MVPC_plotset.paras{7} = MVPC_plotset.xtimefontsize.Value; %%fontsize for x axis
        MVPC_plotset.paras{8} = MVPC_plotset.xtimetextcolor.Value;%%text color for x axis
        %%--------y axis--------
        MVPC_plotset.paras{9} =MVPC_plotset.yscale_auto.Value;
        MVPC_plotset.paras{10} = [str2num(MVPC_plotset.yscale_low.String),str2num(MVPC_plotset.yscale_high.String)];
        MVPC_plotset.paras{11} =MVPC_plotset.ytick_auto.Value;
        MVPC_plotset.paras{12} =str2num(MVPC_plotset.yscale_step.String);
        MVPC_plotset.yticks_precision.Value =1;
        MVPC_plotset.yfont_custom.Value =1;
        MVPC_plotset.yfont_custom_size.Value =5;
        MVPC_plotset.ytextcolor.Value =1;
        MVPC_plotset.paras{13} =MVPC_plotset.yticks_precision.Value;
        MVPC_plotset.paras{14} =MVPC_plotset.yfont_custom.Value;
        MVPC_plotset.paras{15} =MVPC_plotset.yfont_custom_size.Value;
        MVPC_plotset.paras{16} =MVPC_plotset.ytextcolor.Value;
        %%standard error of mean
        MVPC_plotset.show_SEM.Value =0;
        MVPC_plotset.SEM_custom.Value = 2;
        MVPC_plotset.SEMtrans_custom.Value = 3;
        MVPC_plotset.SEM_custom.Enable = 'off';
        MVPC_plotset.SEMtrans_custom.Enable = 'off';
        MVPC_plotset.paras{17} = [MVPC_plotset.show_SEM.Value MVPC_plotset.SEM_custom.Value MVPC_plotset.SEMtrans_custom.Value];
        MVPC_plotset.chanceline.Value=0;
        MVPC_plotset.paras{18}=MVPC_plotset.chanceline.Value;
        MVPC_plotset_pars = MVPC_plotset.paras;
        estudioworkingmemory('MVPC_plotset_pars',MVPC_plotset_pars);
        observe_DECODE.Reset_MVPC_paras_panel=4;
    end
end