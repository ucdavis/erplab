%%This function is used to setting the parameters for plotting the waveform for the selected ERPsets




function varargout = f_ERP_plot_setting_GUI(varargin)

global observe_ERPDAT;

addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);


%---------------------------Initialize parameters------------------------------------

S_erpplot =struct();


gui_erp_plot = struct();

%-----------------------------Name the title----------------------------------------------
% global ERP_plotset_box;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;

if nargin == 0
    fig = figure(); % Parent figure
    ERP_plotset_box = uiextras.BoxPanel('Parent', fig, 'Title', 'Plot Setting', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    ERP_plotset_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Plot Setting', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    ERP_plotset_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Plot Setting', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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
drawui_erpplot(FonsizeDefault);
varargout{1} = ERP_plotset_box;

    function drawui_erpplot(FonsizeDefault)
        
        estudioworkingmemory('erp_plot_set',0);
        estudioworkingmemory('erp_xtickstep',0);
        %%--------------------x and y axes setting-------------------------
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        
        gui_erp_plot.plotop = uiextras.VBox('Parent',ERP_plotset_box, 'Spacing',1,'BackgroundColor',ColorB_def);
        
        uicontrol('Style','text','Parent', gui_erp_plot.plotop,'String','Time Range:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def); % 1B
        gui_erp_plot.ticks = uiextras.HBox('Parent',gui_erp_plot.plotop,'Spacing',1,'BackgroundColor',ColorB_def);
        gui_erp_plot.timet_auto = uicontrol('Style','checkbox','Parent', gui_erp_plot.ticks,'String','Auto',...
            'callback',@timet_auto,'Value',1,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 2B
        gui_erp_plot.timet_auto.KeyPressFcn=  @erp_plotsetting_presskey;
        uicontrol('Style','text','Parent', gui_erp_plot.ticks,'String','Low','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_plot.timet_low = uicontrol('Style', 'edit','Parent',gui_erp_plot.ticks,'BackgroundColor',[1 1 1],...
            'String','','callback',@low_ticks_change,'Enable','off','FontSize',FonsizeDefault);
        gui_erp_plot.timet_low.KeyPressFcn=  @erp_plotsetting_presskey;
        uicontrol('Style','text','Parent', gui_erp_plot.ticks,'String','High','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_plot.timet_high = uicontrol('Style', 'edit','Parent',gui_erp_plot.ticks,'String','',...
            'callback',@high_ticks_change,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        gui_erp_plot.timet_high.KeyPressFcn=  @erp_plotsetting_presskey;
        uicontrol('Style','text','Parent', gui_erp_plot.ticks,'String','Step','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_plot.timet_step = uicontrol('Style', 'edit','Parent',gui_erp_plot.ticks,'String','',...
            'callback',@ticks_step_change,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        gui_erp_plot.timet_step.KeyPressFcn=  @erp_plotsetting_presskey;
        set(gui_erp_plot.ticks, 'Sizes', [60 -1 -1 -1 -1 -1 -1]);
        
        uicontrol('Style','text','Parent', gui_erp_plot.plotop,'String','Y Scale:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        gui_erp_plot.yscale = uiextras.HBox('Parent',gui_erp_plot.plotop,'Spacing',1,'BackgroundColor',ColorB_def);
        gui_erp_plot.yscale_auto = uicontrol('Style','checkbox','Parent',gui_erp_plot.yscale,'String','Auto',...
            'callback',@yscale_auto,'Value',1,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_plot.yscale_auto.KeyPressFcn=  @erp_plotsetting_presskey;
        
        tooltiptext = sprintf('Tick Length:\nSize of Y Ticks');
        uicontrol('Style','text','Parent',gui_erp_plot.yscale,'String','Ticks','TooltipString',tooltiptext,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_plot.yscale_change = uicontrol('Style','edit','Parent',gui_erp_plot.yscale,'BackgroundColor',[1 1 1],...
            'String','','callback',@yscale_change,'Enable','off','FontSize',FonsizeDefault);
        gui_erp_plot.yscale_change.KeyPressFcn=  @erp_plotsetting_presskey;
        tooltiptext = sprintf('Minimum Vertical Spacing:\nSmallest possible distance in inches between zero lines before plots go off the page.');
        uicontrol('Style','text','Parent',gui_erp_plot.yscale,'String','Spacing','TooltipString',tooltiptext,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_plot.min_vspacing = uicontrol('Style','edit','Parent',gui_erp_plot.yscale,'String','',...
            'callback',@min_vspacing,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        gui_erp_plot.min_vspacing.KeyPressFcn=  @erp_plotsetting_presskey;
        tooltiptext = sprintf('Fill Screen:\nDynamically expand plots to fill screen.');
        gui_erp_plot.fill_screen = uicontrol('Style','checkbox','Parent',gui_erp_plot.yscale,'String','Fill','callback',@fill_screen,...
            'TooltipString',tooltiptext,'Value',1,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_plot.fill_screen.KeyPressFcn=  @erp_plotsetting_presskey;
        set(gui_erp_plot.yscale, 'Sizes', [50 45 35 50 35 60]);
        
        
        gui_erp_plot.plot_column = uiextras.HBox('Parent',gui_erp_plot.plotop,'Spacing',1,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def);
        
        uicontrol('Style','text','Parent', gui_erp_plot.plot_column,'String','Number of columns:','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 1E
        
        ColumnNum =  estudioworkingmemory('EStudioColumnNum');
        if isempty(ColumnNum) || numel(ColumnNum)~=1
            ColumnNum =1;
        end
        gui_erp_plot.columns = uicontrol('Style','edit','Parent', gui_erp_plot.plot_column,...
            'String',num2str(ColumnNum),'callback',@onElecNbox,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); % 2E Plot_column
        set(gui_erp_plot.plot_column, 'Sizes', [150 -1]);
        gui_erp_plot.columns.KeyPressFcn=  @erp_plotsetting_presskey;
        
        gui_erp_plot.polarity_waveform = uiextras.HBox('Parent',gui_erp_plot.plotop,'Spacing',1,'BackgroundColor',ColorB_def);
        
        uicontrol('Style','text','Parent', gui_erp_plot.polarity_waveform,'String','Polarity:','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 1F
        
        %% second column:
        gui_erp_plot.positive_up = uicontrol('Style','radiobutton','Parent',gui_erp_plot.polarity_waveform,'String','Positive Up',...
            'callback',@polarity_up,'Value',1,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 2F
        gui_erp_plot.positive_up.KeyPressFcn=  @erp_plotsetting_presskey;
        gui_erp_plot.negative_up = uicontrol('Style','radiobutton','Parent', gui_erp_plot.polarity_waveform,'String','Negative Up',...
            'callback',@polarity_down,'Value',0,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 2F
        gui_erp_plot.negative_up.KeyPressFcn=  @erp_plotsetting_presskey;
        set(gui_erp_plot.polarity_waveform, 'Sizes',[60  -1 -1]);
        
        gui_erp_plot.bin_chan = uiextras.HBox('Parent',gui_erp_plot.plotop,'Spacing',1,'BackgroundColor',ColorB_def);
        
        gui_erp_plot.pagesel = uicontrol('Parent', gui_erp_plot.bin_chan, 'Style', 'popupmenu','String',...
            {'CHANNELS with BINS overlay','BINS with CHANNELS overlay'},'callback',@pageviewchanged,'FontSize',FonsizeDefault);
        gui_erp_plot.pagesel.KeyPressFcn=  @erp_plotsetting_presskey;
        %%channel order
        gui_erp_plot.chanorder_title = uiextras.HBox('Parent',gui_erp_plot.plotop ,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',gui_erp_plot.chanorder_title,'String','Channel Order (for plotting only):',...
            'FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        gui_erp_plot.chanorder_no_title = uiextras.HBox('Parent',gui_erp_plot.plotop ,'BackgroundColor',ColorB_def);
        gui_erp_plot.chanorder_number = uicontrol('Parent',gui_erp_plot.chanorder_no_title, 'Style', 'radiobutton', 'String', 'Default order',...
            'Callback', @chanorder_number,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','on','Value',1);
        gui_erp_plot.chanorder_number.KeyPressFcn=  @erp_plotsetting_presskey;
        gui_erp_plot.chanorder_front = uicontrol('Parent',gui_erp_plot.chanorder_no_title, 'Style', 'radiobutton', 'String', 'Front-back/left-right',...
            'Callback', @chanorder_front,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','on','Value',0);
        gui_erp_plot.chanorder_front.KeyPressFcn=  @erp_plotsetting_presskey;
        set(gui_erp_plot.chanorder_no_title,'Sizes',[120 -1]);
        %%channel order-custom
        gui_erp_plot.chanorder_custom_title = uiextras.HBox('Parent',gui_erp_plot.plotop ,'BackgroundColor',ColorB_def);
        gui_erp_plot.chanorder_custom = uicontrol('Parent',gui_erp_plot.chanorder_custom_title, 'Style', 'radiobutton', 'String', 'Custom',...
            'Callback', @chanorder_custom,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','on','Value',0);
        gui_erp_plot.chanorder_custom_exp = uicontrol('Parent',gui_erp_plot.chanorder_custom_title, 'Style', 'pushbutton', 'String', 'Export',...
            'Callback', @chanorder_custom_exp,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
        gui_erp_plot.chanorder_custom_imp = uicontrol('Parent',gui_erp_plot.chanorder_custom_title, 'Style', 'pushbutton', 'String', 'Import',...
            'Callback', @chanorder_custom_imp,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
        
        
        gui_erp_plot.reset_apply = uiextras.HBox('Parent',gui_erp_plot.plotop,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', gui_erp_plot.reset_apply); % 1A
        gui_erp_plot.plot_reset = uicontrol('Style', 'pushbutton','Parent',gui_erp_plot.reset_apply,...
            'String','Cancel','callback',@plot_erp_reset,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', gui_erp_plot.reset_apply); % 1A
        gui_erp_plot.plot_apply = uicontrol('Style', 'pushbutton','Parent',gui_erp_plot.reset_apply,...
            'String','Apply','callback',@plot_setting_apply,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', gui_erp_plot.reset_apply); % 1A
        set(gui_erp_plot.reset_apply, 'Sizes',[10 -1  30 -1 10]);
        
        set(gui_erp_plot.plotop, 'Sizes', [20 25 20 25 25 25 20 20 25 25 30]);
        gui_erp_plot.chanorderIndex = 1;
        gui_erp_plot.chanorder{1,1}=[];
        gui_erp_plot.chanorder{1,2} = '';
        estudioworkingmemory('ERP_chanorders',{gui_erp_plot.chanorderIndex,gui_erp_plot.chanorder});
        estudioworkingmemory('ERPTab_plotset_pars',[]);
        estudioworkingmemory('ERPTab_plotset',0);
        gui_erp_plot.timet_auto_reset = 1;
        gui_erp_plot.timeticks_auto_reset = 1;
    end



%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%---------------------------------Auto time ticks-------------------------------*
    function timet_auto( src, ~ )
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=2;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('ERPTab_plotset',1);
        gui_erp_plot.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_plot.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_reset.ForegroundColor = [1 1 1];
        
        if src.Value == 1
            gui_erp_plot.timet_low.Enable = 'off';
            gui_erp_plot.timet_high.Enable = 'off';
            gui_erp_plot.timet_step.Enable = 'off';
            gui_erp_plot.timet_low.String = num2str(observe_ERPDAT.ERP.times(1));
            gui_erp_plot.timet_high.String = num2str(observe_ERPDAT.ERP.times(end));
            Min_time=floor(observe_ERPDAT.ERP.times(1)/5)*5;
            Max_time = ceil(observe_ERPDAT.ERP.times(end)/5)*5;
            [def xstep]= default_time_ticks_studio(observe_ERPDAT.ERP, [Min_time,Max_time]);
            gui_erp_plot.timet_step.String = num2str(xstep);
        else
            gui_erp_plot.timet_low.Enable = 'on';
            gui_erp_plot.timet_high.Enable = 'on';
            gui_erp_plot.timet_step.Enable = 'on';
        end
    end


%%--------------------------Min. interval of time ticks---------------------
    function low_ticks_change( src, ~ )
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=2;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('ERPTab_plotset',1);
        gui_erp_plot.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_plot.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_reset.ForegroundColor = [1 1 1];
        
        xtixlk_min = str2num(src.String);
        xtixlk_max = str2num(gui_erp_plot.timet_high.String);
        if isempty(xtixlk_min)|| numel(xtixlk_min)~=1
            src.String = num2str(observe_ERPDAT.ERP.times(1));
            msgboxText =  ['Plot Setting> Time range- Input of low edge must be a single numeric'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
        if any(xtixlk_max<=xtixlk_min)
            src.String = num2str(observe_ERPDAT.ERP.times(1));
            msgboxText =  ['Plot Setting> Time range- Low edge must be  smaller than',32,num2str(xtixlk_max(1))];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
    end

%%----------------------high interval of time ticks--------------------------------*
    function high_ticks_change( src, ~ )
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=2;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('ERPTab_plotset',1);
        gui_erp_plot.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_plot.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_reset.ForegroundColor = [1 1 1];
        
        xtixlk_min = str2num(gui_erp_plot.timet_low.String);
        xtixlk_max = str2num(src.String);
        
        if isempty(xtixlk_max) || numel(xtixlk_max)~=1
            src.String = num2str(observe_ERPDAT.ERP.times(end));
            beep;
            msgboxText =  ['Plot Setting> Y Scale- Input of ticks edge must be a single numeric'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        if any(xtixlk_max < xtixlk_min)
            src.String =  num2str(observe_ERPDAT.ERP.times(end));
            msgboxText =  ['Plot Setting> Time range- high edge must be higher than',32,num2str(xtixlk_min),'ms'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
    end


%%----------------------Step of time ticks--------------------------------*
    function ticks_step_change( src, ~ )
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=2;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('ERPTab_plotset',1);
        gui_erp_plot.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_plot.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_reset.ForegroundColor = [1 1 1];
        
        timeStart = str2num(gui_erp_plot.timet_low.String);
        timEnd = str2num(gui_erp_plot.timet_high.String);
        
        if ~isempty(timeStart) && ~isempty(timEnd) && numel(timEnd)==1 && numel(timeStart) ==1 && timeStart < timEnd
            [def xtickstepdef]= default_time_ticks_studio(observe_ERPDAT.ERP, [timEnd,timeStart]);
        else
            xtickstepdef = [];
        end
        
        tick_step = str2num(src.String);
        if isempty(tick_step) || numel(tick_step)~=1 || any(tick_step<=0)
            src.String = num2str(xtickstepdef);
            beep;
            msgboxText =  ['Plot Setting> Time range- The input of Step must be a single positive value'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
    end

%%---------------------------------Auto y scale---------------------------------*
    function yscale_auto( src, ~ )
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=2;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('ERPTab_plotset',1);
        gui_erp_plot.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_plot.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_reset.ForegroundColor = [1 1 1];
        
        if gui_erp_plot.positive_up.Value==1
            positive_up = 1;
        else
            positive_up = -1;
        end
        if src.Value == 1
            gui_erp_plot.yscale_change.Enable = 'off';
            YScale =prctile(observe_ERPDAT.ERP.bindata(:)*positive_up,95)*2/3;
            
            if YScale>= 0&&YScale <=0.1
                YScale = 0.1;
            elseif YScale< 0&& YScale > -0.1
                YScale = -0.1;
            else
                YScale = round(YScale);
            end
            gui_erp_plot.yscale_change.String = YScale;
            gui_erp_plot.min_vspacing.Enable = 'off';
            gui_erp_plot.min_vspacing.String = 1.5;
        else
            gui_erp_plot.yscale_change.Enable = 'on';
            gui_erp_plot.min_vspacing.Enable = 'on';
        end
    end


%%---------------------------------y scale change---------------------------------*
    function yscale_change(src, ~ )
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=2;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('ERPTab_plotset',1);
        gui_erp_plot.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_plot.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_reset.ForegroundColor = [1 1 1];
        
        val = str2num(src.String);
        if isempty(val)  || numel(val)~=1 || any(val(:)<=0)
            if gui_erp_plot.positive_up.Value==1
                positive_up = 1;
            else
                positive_up = -1;
            end
            YScaledef =prctile(observe_ERPDAT.ERP.bindata(:)*positive_up,95)*2/3;
            if YScaledef>= 0&&YScaledef <=0.1
                YScaledef = 0.1;
            elseif YScaledef< 0&& YScaledef > -0.1
                YScaledef = -0.1;
            else
                YScaledef = round(YScaledef);
            end
            src.String = num2str(YScaledef);
            msgboxText =  ['Plot Setting> y scale - Input must be a positive value'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
        end
    end


%%-------------------------- Y scale spacing-------------------------------
    function min_vspacing( src, ~ )
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=2;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('ERPTab_plotset',1);
        gui_erp_plot.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_plot.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_reset.ForegroundColor = [1 1 1];
        
        val = str2num(src.String);
        if isempty(val) || numel(val)~=1 || any(val(:)<0)
            msgboxText =  ['Plot Setting> y scale > spacing - Input of spacing must be a positive value'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            src.String = '1.5';
        end
        
    end

%%-----------------fill screen---------------------------------------------*
    function fill_screen( src, ~ )
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=2;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('ERPTab_plotset',1);
        gui_erp_plot.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_plot.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_reset.ForegroundColor = [1 1 1];
    end

%%-----------Determing the numbrt of columns------------------------------
    function onElecNbox(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=2;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('ERPTab_plotset',1);
        gui_erp_plot.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_plot.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_reset.ForegroundColor = [1 1 1];
        Values = str2num(source.String);
        if isempty(Values) || numel(Values)~=1 || any(Values(:)<=0)
            source.String = '1';
            msgboxText =  ['Plot Setting> Number of columns - Input for the number of columns must be a positive value'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
    end

%------------------Set the polarity of waveform is up or not-------------------
    function polarity_up(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=2;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('ERPTab_plotset',1);
        gui_erp_plot.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_plot.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_reset.ForegroundColor = [1 1 1];
        
        gui_erp_plot.positive_up.Value =1;
        gui_erp_plot.negative_up.Value = 0;
    end


%------------------Set the polarity of waveform is up or not-------------------
    function polarity_down( source, ~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=2;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('ERPTab_plotset',1);
        gui_erp_plot.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_plot.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_reset.ForegroundColor = [1 1 1];
        
        gui_erp_plot.positive_up.Value =0;
        gui_erp_plot.negative_up.Value = 1;
    end

%%----------------------Setting for bin overlay chan---------------------
    function pageviewchanged(src,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=2;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('ERPTab_plotset',1);
        gui_erp_plot.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_plot.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_reset.ForegroundColor = [1 1 1];
    end

%%----------------------channel order-number-------------------------------
    function chanorder_number(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=2;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('ERPTab_plotset',1);
        gui_erp_plot.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_plot.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_reset.ForegroundColor = [1 1 1];
        
        gui_erp_plot.chanorder_number.Value=1;
        gui_erp_plot.chanorder_front.Value=0;
        gui_erp_plot.chanorder_custom.Value=0;
        gui_erp_plot.chanorder_custom_exp.Enable = 'off';
        gui_erp_plot.chanorder_custom_imp.Enable = 'off';
    end

%%-----------------channel order-front-back/left-right---------------------
    function chanorder_front(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=2;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('ERPTab_plotset',1);
        gui_erp_plot.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_plot.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_reset.ForegroundColor = [1 1 1];
        
        
        gui_erp_plot.chanorder_number.Value=0;
        gui_erp_plot.chanorder_front.Value=1;
        gui_erp_plot.chanorder_custom.Value=0;
        gui_erp_plot.chanorder_custom_exp.Enable = 'off';
        gui_erp_plot.chanorder_custom_imp.Enable = 'off';
        try
            chanlocs = observe_ERPDAT.ERP.chanlocs;
            if isempty(chanlocs(1).X) &&  isempty(chanlocs(1).Y)
                MessageViewer= char(strcat('Plot Setting > Channel order>Front-back/left-right:please do "chan locations" first in EEGLAB Tool panel.'));
                erpworkingmemory('f_ERP_proces_messg',MessageViewer);
                observe_ERPDAT.Process_messg=4;
                gui_erp_plot.chanorder_number.Value=1;
                gui_erp_plot.chanorder_front.Value=0;
                gui_erp_plot.chanorder_custom.Value=0;
                gui_erp_plot.chanorder_custom_exp.Enable = 'off';
                gui_erp_plot.chanorder_custom_imp.Enable = 'off';
            end
        catch
            MessageViewer= char(strcat('Plot Setting > Channel order>Front-back/left-right: It seems that chanlocs for the current ERP is empty and please check it out'));
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
            gui_erp_plot.chanorder_number.Value=1;
            gui_erp_plot.chanorder_front.Value=0;
            gui_erp_plot.chanorder_custom.Value=0;
            gui_erp_plot.chanorder_custom_exp.Enable = 'off';
            gui_erp_plot.chanorder_custom_imp.Enable = 'off';
        end
    end

%%----------------------channel order-custom-------------------------------
    function chanorder_custom(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=2;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('ERPTab_plotset',1);
        gui_erp_plot.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_plot.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_reset.ForegroundColor = [1 1 1];
        
        
        gui_erp_plot.chanorder_number.Value=0;
        gui_erp_plot.chanorder_front.Value=0;
        gui_erp_plot.chanorder_custom.Value=1;
        gui_erp_plot.chanorder_custom_exp.Enable = 'on';
        gui_erp_plot.chanorder_custom_imp.Enable = 'on';
        
        if ~isfield(observe_ERPDAT.ERP,'chanlocs') || isempty(observe_ERPDAT.ERP.chanlocs)
            MessageViewer= char(strcat('Plot Setting > Channel order>Front-back/left-right: It seems that chanlocs for the current EEG is empty and please check it out'));
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
            gui_erp_plot.chanorder_number.Value=1;
            gui_erp_plot.chanorder_front.Value=0;
            gui_erp_plot.chanorder_custom.Value=0;
            gui_erp_plot.chanorder_custom_exp.Enable = 'off';
            gui_erp_plot.chanorder_custom_imp.Enable = 'off';
            return;
        end
        
    end

%%---------------------export channel orders-------------------------------
    function chanorder_custom_exp(~,~)
        if strcmpi(observe_ERPDAT.ERP.erpname,'No ERPset loaded')
            MessageViewer= char(strcat('Plot Setting > Channel order>Custom>Export: Current ERP is empty'));
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
            return;
        end
        if ~isfield(observe_ERPDAT.ERP,'chanlocs') || isempty(observe_ERPDAT.ERP.chanlocs)
            MessageViewer= char(strcat('Plot Setting > Channel order>Custom>Export: It seems that chanlocs for the current EEG is empty and please check it out'));
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
            gui_erp_plot.chanorder_number.Value=1;
            gui_erp_plot.chanorder_front.Value=0;
            gui_erp_plot.chanorder_custom.Value=0;
            gui_erp_plot.chanorder_custom_exp.Enable = 'off';
            gui_erp_plot.chanorder_custom_imp.Enable = 'off';
            return;
        end
        
        MessageViewer= char(strcat('Plot Setting > Channel order>Custom>Export'));
        erpworkingmemory('f_ERP_proces_messg',MessageViewer);
        observe_ERPDAT.Process_messg=1;
        
        if isempty(gui_erp_plot.chanorder{1,1}) || isempty(gui_erp_plot.chanorder{1,2})
            chanOrders = [1:observe_ERPDAT.ERP.nbchan];
            [eloc, labels, theta, radius, indices] = readlocs(observe_ERPDAT.ERP.chanlocs);
        else
            chanOrders =  gui_erp_plot.chanorder{1,1} ;
            labels=  gui_erp_plot.chanorder{1,2};
        end
        Data = cell(length(chanOrders),2);
        for ii =1:length(chanOrders)
            try
                Data{ii,1} = chanOrders(ii);
                Data{ii,2} = labels{ii};
            catch
            end
        end
        
        pathstr = pwd;
        namedef ='Channel_order';
        [erpfilename, erppathname, indxs] = uiputfile({'*.txt';'*.xlsx;*.xls'}, ...
            ['Export ERP channel order (for plotting only)'],...
            fullfile(pathstr,namedef));
        if isequal(erpfilename,0)
            disp('User selected Cancel')
            return
        end
        
        [pathstr, erpfilename, ext] = fileparts(erpfilename) ;
        if indxs==2
            ext = '.xls';
        else
            ext = '.txt';
        end
        erpFilename = char(strcat(erppathname,erpfilename,ext));
        fileID = fopen(erpFilename,'w+');
        
        formatSpec ='';
        for jj = 1:2
            if jj==1
                formatSpec = strcat(formatSpec,'%d\t',32);
            else
                formatSpec = strcat(formatSpec,'%s\t',32);
            end
        end
        formatSpec = strcat(formatSpec,'\n');
        
        for row = 1:numel(chanOrders)
            if indxs==1
                fprintf(fileID,formatSpec,Data{row,:});
            else
                fprintf(fileID,formatSpec,Data{row,1},Data{row,2});
            end
        end
        fclose(fileID);
        disp(['A new ERP channel order file was created at <a href="matlab: open(''' erpFilename ''')">' erpFilename '</a>'])
        
        MessageViewer= char(strcat('Plot Setting > Channel order>Custom>Export'));
        erpworkingmemory('f_ERP_proces_messg',MessageViewer);
        observe_ERPDAT.Process_messg=2;
    end

%%-------------------------import channel orders---------------------------
    function chanorder_custom_imp(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=2;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('ERPTab_plotset',1);
        gui_erp_plot.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_plot.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_plot.plot_reset.ForegroundColor = [1 1 1];
        
        
        if ~isfield(observe_ERPDAT.ERP,'chanlocs') || isempty(observe_ERPDAT.ERP.chanlocs)
            MessageViewer= char(strcat('Plot Setting > Channel order>Custom>Import: It seems that chanlocs for the current ERP is empty and please check it out'));
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
            gui_erp_plot.chanorder_number.Value=1;
            gui_erp_plot.chanorder_front.Value=0;
            gui_erp_plot.chanorder_custom.Value=0;
            gui_erp_plot.chanorder_custom_exp.Enable = 'off';
            gui_erp_plot.chanorder_custom_imp.Enable = 'off';
            return;
        end
        
        %%import data chan orders
        [eloc, labels, theta, radius, indices] = readlocs(observe_ERPDAT.ERP.chanlocs);
        
        [erpfilename, erppathname, indxs] = uigetfile({'*.txt'}, ...
            ['Import ERP channel order (for plotting only)'],...
            'MultiSelect', 'off');
        if isequal(erpfilename,0) || indxs~=1
            disp('User selected Cancel')
            return
        end
        
        [pathstr, erpfilename, ext] = fileparts(erpfilename) ;
        ext = '.txt';
        erpFilename = char(strcat(erppathname,erpfilename,ext));
        
        DataInput =  readcell(erpFilename);
        if isempty(DataInput)
            gui_erp_plot.chanorder{1,1}=[];
            gui_erp_plot.chanorder{1,2} = '';
        end
        chanorders = [];
        chanlabes = [];
        for ii = 1:size(DataInput,1)
            if isnumeric(DataInput{ii,1})
                chanorders(ii) = DataInput{ii,1};
            end
            if ischar(DataInput{ii,2})
                chanlabes{ii} = DataInput{ii,2};
            end
        end
        chanorders1 = unique(chanorders);
        if any(chanorders(:)>length(labels)) || any(chanorders(:)<=0)
            MessageViewer= char(strcat('Plot Setting > Channel order>Custom>Import: It seems that some of the defined chan orders are invalid or replicated, please check the file'));
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
            gui_erp_plot.chanorder_number.Value=1;
            gui_erp_plot.chanorder_front.Value=0;
            gui_erp_plot.chanorder_custom.Value=0;
            gui_erp_plot.chanorder_custom_exp.Enable = 'off';
            gui_erp_plot.chanorder_custom_imp.Enable = 'off';
            return;
        end
        
        if numel(chanorders1)~= observe_ERPDAT.ERP.nbchan
            MessageViewer= strcat(['Plot Setting > Channel order>Custom>Import: The number of the defined chan orders must be',32,num2str(observe_ERPDAT.ERP.nchan)]);
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
            gui_erp_plot.chanorder_number.Value=1;
            gui_erp_plot.chanorder_front.Value=0;
            gui_erp_plot.chanorder_custom.Value=0;
            gui_erp_plot.chanorder_custom_exp.Enable = 'off';
            gui_erp_plot.chanorder_custom_imp.Enable = 'off';
            return;
        end
        
        [C,IA]= ismember_bc2(chanlabes,labels);
        if any(IA==0)
            MessageViewer= strcat(['Plot Setting > Channel order>Custom>Import: The names of channels must be the same to the current ERP']);
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
            gui_erp_plot.chanorder_number.Value=1;
            gui_erp_plot.chanorder_front.Value=0;
            gui_erp_plot.chanorder_custom.Value=0;
            gui_erp_plot.chanorder_custom_exp.Enable = 'off';
            gui_erp_plot.chanorder_custom_imp.Enable = 'off';
            return;
        end
        
        gui_erp_plot.chanorder{1,1}=chanorders;
        gui_erp_plot.chanorder{1,2} = chanlabes;
    end


%%--------------Reset the parameters for plotting panel--------------------
    function plot_erp_reset(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=2;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('ERPTab_plotset',0);
        gui_erp_plot.plot_apply.BackgroundColor =  [ 1 1 1];
        gui_erp_plot.plot_apply.ForegroundColor = [0 0 0];
        ERP_plotset_box.TitleColor= [0.0500    0.2500    0.5000];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_plot.plot_reset.BackgroundColor =  [1 1 1];
        gui_erp_plot.plot_reset.ForegroundColor = [0 0 0];
        
        erpworkingmemory('f_ERP_proces_messg','Plot Setting>Cancel');
        observe_ERPDAT.Process_messg =1;
        
        %
        %%------------------------------time range-------------------------
        ERPTab_plotset_pars =  estudioworkingmemory('ERPTab_plotset_pars');
        timelowdef = observe_ERPDAT.ERP.times(1);
        timehighdef= observe_ERPDAT.ERP.times(end);
        [def xtickstepdef]= default_time_ticks_studio(observe_ERPDAT.ERP, [timelowdef,timehighdef]);
        if gui_erp_plot.timet_auto_reset==1
            Enablerange = 'off';
            timelow = timelowdef;
            timehigh = timehighdef;
            xtickstep = xtickstepdef;
        else
            Enablerange = 'on';
            try
                timerange = ERPTab_plotset_pars{1};
                timelow = timerange(1);
                timehigh = timerange(2);
            catch
                timelow = timelowdef;
                timehigh = timehighdef;
            end
            try
                xtickstep = ERPTab_plotset_pars{2};
            catch
                xtickstep = xtickstepdef;
            end
        end
        gui_erp_plot.timet_auto.Value = gui_erp_plot.timet_auto_reset;
        
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
        gui_erp_plot.timet_low.Enable = Enablerange;
        gui_erp_plot.timet_high.Enable =  Enablerange;
        gui_erp_plot.timet_step.Enable = Enablerange;
        gui_erp_plot.timet_low.String = num2str(timelow);
        gui_erp_plot.timet_high.String = num2str(timehigh);
        gui_erp_plot.timet_step.String =  num2str(xtickstep);
        %
        %%------------------------y scale----------------------------------
        if gui_erp_plot.positive_up.Value==1
            positive_up = 1;
        else
            positive_up = -1;
        end
        YScaledef =prctile(observe_ERPDAT.ERP.bindata(:)*positive_up,95)*2/3;
        if YScaledef>= 0&&YScaledef <=0.1
            YScaledef = 0.1;
        elseif YScaledef< 0&& YScaledef > -0.1
            YScaledef = -0.1;
        else
            YScaledef = round(YScaledef);
        end
        
        if gui_erp_plot.timeticks_auto_reset==1
            Enableflag = 'off';
            yscale = YScaledef;
            min_vspacing = 1.5;
        else
            Enableflag = 'on';
            yscale= ERPTab_plotset_pars{3};
            min_vspacing = ERPTab_plotset_pars{4};
        end
        if isempty(yscale) || numel(yscale)~=1 ||  any(yscale(:)<=0)
            yscale = YScaledef;
            ERPTab_plotset_pars{3} = yscale;
        end
        if isempty(min_vspacing) || numel(min_vspacing)~=1 || any(min_vspacing(:)<0)
            min_vspacing =1.5;
            ERPTab_plotset_pars{4}=1.5;
        end
        gui_erp_plot.yscale_auto.Value = gui_erp_plot.timeticks_auto_reset;
        gui_erp_plot.yscale_change.String = num2str(yscale);
        gui_erp_plot.yscale_change.Enable = Enableflag;
        gui_erp_plot.min_vspacing.String = num2str(min_vspacing);
        gui_erp_plot.min_vspacing.Enable = Enableflag;
        
        %
        %%fill screeen?
        fill_screen =  ERPTab_plotset_pars{5};
        if isempty(fill_screen) || numel(fill_screen)~=1 || (fill_screen~=0 && fill_screen~=1)
            fill_screen=1;
            ERPTab_plotset_pars{5}=1;
        end
        gui_erp_plot.fill_screen.Value = fill_screen;
        
        %
        %%Number of columns?
        ColumnNum= ERPTab_plotset_pars{6};
        if isempty(ColumnNum) || numel(ColumnNum)~=1 || any(ColumnNum<=0)
            ColumnNum =1;
            ERPTab_plotset_pars{6}=1;
        end
        gui_erp_plot.columns.String = num2str(ColumnNum); % 2E Plot_column
        gui_erp_plot.columns.Enable = 'on';
        
        %
        %%polarity?
        positive_up =  ERPTab_plotset_pars{7};
        if isempty(positive_up) ||  numel(positive_up)~=1 || (positive_up~=0&&positive_up~=1)
            positive_up=1;
            ERPTab_plotset_pars{7}=1;
        end
        gui_erp_plot.positive_up.Value =positive_up;
        gui_erp_plot.negative_up.Value = ~positive_up;
        %
        %%overlay?
        Bin_chan_overlay=ERPTab_plotset_pars{8};
        if isempty(Bin_chan_overlay) || numel(Bin_chan_overlay)~=1 || (Bin_chan_overlay~=0 && Bin_chan_overlay~=1)
            Bin_chan_overlay=0;
            ERPTab_plotset_pars{8}=0;
        end
        set(gui_erp_plot.pagesel,'Value',Bin_chan_overlay+1);
        estudioworkingmemory('ERPTab_plotset_pars',ERPTab_plotset_pars);
        
        %
        %%channel order
        ERP_chanorders=  estudioworkingmemory('ERP_chanorders');
        try
            chanordervalue = ERP_chanorders{1};
        catch
            chanordervalue=1;
        end
        if isempty(chanordervalue) || numel(chanordervalue)~=1 || (chanordervalue~=1 && chanordervalue~=2 && chanordervalue~=3)
            chanordervalue=1;
        end
        if chanordervalue==1
            gui_erp_plot.chanorder_number.Value=1;
            gui_erp_plot.chanorder_front.Value=0;
            gui_erp_plot.chanorder_custom.Value=0;
            gui_erp_plot.chanorder_custom_exp.Enable = 'off';
            gui_erp_plot.chanorder_custom_imp.Enable = 'off';
        elseif chanordervalue==2
            gui_erp_plot.chanorder_number.Value=0;
            gui_erp_plot.chanorder_front.Value=1;
            gui_erp_plot.chanorder_custom.Value=0;
            gui_erp_plot.chanorder_custom_exp.Enable = 'off';
            gui_erp_plot.chanorder_custom_imp.Enable = 'off';
        elseif chanordervalue==3
            gui_erp_plot.chanorder_number.Value=0;
            gui_erp_plot.chanorder_front.Value=0;
            gui_erp_plot.chanorder_custom.Value=1;
            gui_erp_plot.chanorder_custom_exp.Enable = 'on';
            gui_erp_plot.chanorder_custom_imp.Enable = 'on';
        end
        observe_ERPDAT.Process_messg =2;
    end


%------------Apply current parameters in plotting panel to the selected ERPset---------
    function plot_setting_apply(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=2;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('ERPTab_plotset',0);
        gui_erp_plot.plot_apply.BackgroundColor =  [ 1 1 1];
        gui_erp_plot.plot_apply.ForegroundColor = [0 0 0];
        ERP_plotset_box.TitleColor= [0.0500    0.2500    0.5000];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_plot.plot_reset.BackgroundColor =  [1 1 1];
        gui_erp_plot.plot_reset.ForegroundColor = [0 0 0];
        
        
        erpworkingmemory('f_ERP_proces_messg','Plot Setting>Apply');
        observe_ERPDAT.Process_messg =1;
        
        gui_erp_plot.timet_auto_reset = gui_erp_plot.timet_auto.Value;
        gui_erp_plot.timeticks_auto_reset = gui_erp_plot.yscale_auto.Value;
        
        %
        %%time range
        timeStartdef = observe_ERPDAT.ERP.times(1);
        timEnddef = observe_ERPDAT.ERP.times(end);
        [def xstepdef]= default_time_ticks_studio(observe_ERPDAT.ERP, [observe_ERPDAT.ERP.times(1),observe_ERPDAT.ERP.times(end)]);
        
        timeStart = str2num(gui_erp_plot.timet_low.String);
        if isempty(timeStart) || numel(timeStart)~=1 ||  timeStart>=observe_ERPDAT.ERP.times(end)
            timeStart = timeStartdef;
            gui_erp_plot.timet_low.String = num2str(observe_ERPDAT.ERP.times(1));
            MessageViewer= char(['Plot Setting > Apply: Low edge of the time range should be smaller',32,num2str(observe_ERPDAT.ERP.times(end)),32,...
                'we therefore set to be',32,num2str(timeStart)]);
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
        end
        
        timEnd = str2num(gui_erp_plot.timet_high.String);
        if isempty(timEnd) || numel(timEnd)~=1 || timEnd<=observe_ERPDAT.ERP.times(1)
            timEnd = timEnddef;
            gui_erp_plot.timet_high.String = num2str(timEnd);
            MessageViewer= char(['Plot Setting > Apply: High edge of the time range should be larger',32,num2str(timeStartdef),32,...
                'we therefore set to be',32,num2str(timEnddef)]);
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
        end
        
        if timeStart>= timEnd
            timEnd = timEnddef;
            timeStart = timeStartdef;
            gui_erp_plot.timet_low.String = num2str(timeStart);
            gui_erp_plot.timet_high.String = num2str(timEnd);
            MessageViewer= char(['Plot Setting > Apply: Low edge of the time range should be smaller than the high one and we therefore used the defaults']);
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
        end
        ERPTab_plotset_pars{1} = [timeStart,timEnd];
        
        xtickstep = str2num(gui_erp_plot.timet_step.String);
        if isempty(xtickstep) || numel(xtickstep)~=1 || xtickstep> floor((timEnd-timeStart)/2) || any(xtickstep<=0)
            xtickstep = xstepdef;
            gui_erp_plot.timet_step.String = num2str(xtickstep);
            MessageViewer= char(['Plot Setting > Apply: the step of the time range should be a positive number that belows',32,num2str(floor((timEnd-timeStart)/2))]);
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
        end
        ERPTab_plotset_pars{2} = xtickstep;
        
        %
        %%Y scale
        if gui_erp_plot.positive_up.Value==1
            positive_up = 1;
        else
            positive_up = -1;
        end
        YScaledef =prctile(observe_ERPDAT.ERP.bindata(:)*positive_up,95)*2/3;
        if YScaledef>= 0&&YScaledef <=0.1
            YScaledef = 0.1;
        elseif YScaledef< 0&& YScaledef > -0.1
            YScaledef = 0.1;
        else
            YScaledef = round(YScaledef);
        end
        
        Yscales = str2num(gui_erp_plot.yscale_change.String);
        if isempty(Yscales) || numel(Yscales)~=1 || any(Yscales(:)<=0.1)
            gui_erp_plot.yscale_change.String = str2num(YScaledef);
            Yscales= YScaledef;
            MessageViewer= char(['Plot Setting > Apply: the tick of y scale should be lager than 0.1']);
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
        end
        ERPTab_plotset_pars{3} = Yscales;
        
        min_vspacing = str2num(gui_erp_plot.min_vspacing.String);
        if isempty(min_vspacing) || numel(min_vspacing)~=1 || any(min_vspacing<=0)
            min_vspacing=1.5;
            gui_erp_plot.min_vspacing.String = '1.5';
            MessageViewer= char(['Plot Setting > Apply: the spacing for y scale should be a positive value']);
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
        end
        ERPTab_plotset_pars{4} = min_vspacing;
        %
        %%fill screen?
        ERPTab_plotset_pars{5} = gui_erp_plot.fill_screen.Value;
        %%Number of columns
        columNum = round(str2num(gui_erp_plot.columns.String));
        if isempty(columNum) || numel(columNum)~=1 || any(columNum<=0)
            columNum =1;
            gui_erp_plot.columns.String = '1';
            MessageViewer= char(['Plot Setting > Apply: the number of columns should be a positive value']);
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
        end
        ERPTab_plotset_pars{6} =columNum;
        
        %
        %%polarity (positive up?)
        ERPTab_plotset_pars{7} =gui_erp_plot.positive_up.Value;
        %
        %%overlay?
        if gui_erp_plot.pagesel.Value==1
            ERPTab_plotset_pars{8} =0;
        else
            ERPTab_plotset_pars{8} =  1;
        end
        estudioworkingmemory('ERPTab_plotset_pars',ERPTab_plotset_pars);
        
        %%channel orders
        [eloc, labels, theta, radius, indices] = readlocs(observe_ERPDAT.ERP.chanlocs);
        if  gui_erp_plot.chanorder_number.Value==1
            gui_erp_plot.chanorderIndex=1;
            gui_erp_plot.chanorder{1,1} = 1:length(labels);
            gui_erp_plot.chanorder{1,2} = labels;
        elseif gui_erp_plot.chanorder_front.Value==1
            gui_erp_plot.chanorderIndex = 2;
            chanindexnew = f_estudio_chan_frontback_left_right(observe_ERPDAT.ERP.chanlocs);
            if ~isempty(chanindexnew)
                gui_erp_plot.chanorder{1,1} = 1:numel(chanindexnew);
                gui_erp_plot.chanorder{1,2} = labels(chanindexnew);
            else
                gui_erp_plot.chanorder{1,1} = 1:length(labels);
                gui_erp_plot.chanorder{1,2} = labels;
            end
        elseif gui_erp_plot.chanorder_custom.Value==1
            if isempty(gui_erp_plot.chanorder{1,1})
                gui_erp_plot.chanorderIndex = 3;
                MessageViewer= char(strcat('Plot Setting > Apply:There were no custom-defined chan orders and we therefore used the default orders'));
                erpworkingmemory('f_ERP_proces_messg',MessageViewer);
                observe_ERPDAT.Process_messg=4;
                gui_erp_plot.chanorder_number.Value=1;
                gui_erp_plot.chanorder_front.Value=0;
                gui_erp_plot.chanorder_custom.Value=0;
                gui_erp_plot.chanorder_custom_exp.Enable = 'off';
                gui_erp_plot.chanorder_custom_imp.Enable = 'off';
                gui_erp_plot.chanorderIndex=1;
                gui_erp_plot.chanorder{1,1} = 1:length(labels);
                gui_erp_plot.chanorder{1,2} = labels;
            end
        end
        estudioworkingmemory('ERP_chanorders',{gui_erp_plot.chanorderIndex,gui_erp_plot.chanorder});
    end



%%-------------------------------------------------------------------------
    function Count_currentERPChanged(~,~)
        if observe_ERPDAT.Count_currentERP~=3
            return;
        end
        if isempty(observe_ERPDAT.ALLERP)|| isempty(observe_ERPDAT.ERP)
            enbaleflag = 'off';
        else
            enbaleflag = 'on';
        end
        gui_erp_plot.timet_auto.Enable =enbaleflag;
        gui_erp_plot.timet_low.Enable =enbaleflag;
        gui_erp_plot.timet_high.Enable =enbaleflag;
        gui_erp_plot.timet_step.Enable =enbaleflag;
        gui_erp_plot.yscale_auto.Enable =enbaleflag;
        gui_erp_plot.yscale_change.Enable =enbaleflag;
        gui_erp_plot.min_vspacing.Enable =enbaleflag;
        gui_erp_plot.fill_screen.Enable =enbaleflag;
        gui_erp_plot.columns.Enable =enbaleflag;
        gui_erp_plot.positive_up.Enable =enbaleflag;
        gui_erp_plot.negative_up.Enable =enbaleflag;
        gui_erp_plot.pagesel.Enable =enbaleflag;
        gui_erp_plot.chanorder_number.Enable =enbaleflag;
        gui_erp_plot.chanorder_front.Enable =enbaleflag;
        gui_erp_plot.chanorder_custom.Enable =enbaleflag;
        gui_erp_plot.chanorder_custom_exp.Enable =enbaleflag;
        gui_erp_plot.chanorder_custom_imp.Enable =enbaleflag;
        gui_erp_plot.plot_reset.Enable =enbaleflag;
        gui_erp_plot.plot_apply.Enable =enbaleflag;
        if isempty(observe_ERPDAT.ALLERP)|| isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP =4;
            return;
        end
        if gui_erp_plot.timet_auto.Value==1
            gui_erp_plot.timet_low.Enable ='off';
            gui_erp_plot.timet_high.Enable ='off';
            gui_erp_plot.timet_step.Enable ='off';
        end
        if gui_erp_plot.yscale_auto.Value ==1
            gui_erp_plot.yscale_change.Enable ='off';
            gui_erp_plot.min_vspacing.Enable ='off';
        end
        if gui_erp_plot.chanorder_number.Value==1 ||  gui_erp_plot.chanorder_front.Value==1
            gui_erp_plot.chanorder_custom_exp.Enable ='off';
            gui_erp_plot.chanorder_custom_imp.Enable ='off';
        end
        
        %
        %%time range
        if gui_erp_plot.timet_auto.Value == 1
            gui_erp_plot.timet_low.String = num2str(observe_ERPDAT.ERP.times(1));
            gui_erp_plot.timet_low.Enable = 'off';
            gui_erp_plot.timet_high.String = num2str(observe_ERPDAT.ERP.times(end));
            gui_erp_plot.timet_high.Enable =  'off';
            [def xstep]= default_time_ticks_studio(observe_ERPDAT.ERP, [observe_ERPDAT.ERP.times(1),observe_ERPDAT.ERP.times(end)]);
            gui_erp_plot.timet_step.String = num2str(xstep);
        end
        
        timeStart = str2num(gui_erp_plot.timet_low.String);
        if isempty(timeStart) || numel(timeStart)~=1 || timeStart>observe_ERPDAT.ERP.times(end) || timeStart<observe_ERPDAT.ERP.times(1)
            timeStart = observe_ERPDAT.ERP.times(1);
            gui_erp_plot.timet_low.String = num2str(observe_ERPDAT.ERP.times(1));
        end
        timEnd = str2num(gui_erp_plot.timet_high.String);
        
        if isempty(timEnd) || numel(timEnd)~=1 || timEnd<observe_ERPDAT.ERP.times(1) || timEnd> observe_ERPDAT.ERP.times(end)
            timEnd = observe_ERPDAT.ERP.times(end);
            gui_erp_plot.timet_high.String = num2str(observe_ERPDAT.ERP.times(end));
        end
        
        if timeStart>timEnd
            gui_erp_plot.timet_low.String = num2str(observe_ERPDAT.ERP.times(1));
            gui_erp_plot.timet_high.String = num2str(observe_ERPDAT.ERP.times(end));
            timeStart = observe_ERPDAT.ERP.times(1);
            timEnd = observe_ERPDAT.ERP.times(end);
        end
        ERPTab_plotset_pars{1} = [timeStart,timEnd];
        xtickstep = str2num(gui_erp_plot.timet_step.String);
        if isempty(xtickstep) || numel(xtickstep)~=1 || xtickstep> floor((timEnd-timeStart)/2)
            [def xtickstep]= default_time_ticks_studio(observe_ERPDAT.ERP, [timEnd,timeStart]);
            gui_erp_plot.timet_step.String = num2str(xtickstep);
        end
        ERPTab_plotset_pars{2} = xtickstep;
        
        %
        %%Y scale
        if gui_erp_plot.positive_up.Value==1
            positive_up = 1;
        else
            positive_up = -1;
        end
        YScaledef =prctile(observe_ERPDAT.ERP.bindata(:)*positive_up,95)*2/3;
        if YScaledef>= 0&&YScaledef <=0.1
            YScaledef = 0.1;
        elseif YScaledef< 0&& YScaledef > -0.1
            YScaledef = -0.1;
        else
            YScaledef = round(YScaledef);
        end
        if gui_erp_plot.yscale_auto.Value ==1
            gui_erp_plot.yscale_change.String = str2num(YScaledef);
            gui_erp_plot.min_vspacing.String = 1.5;
        end
        Yscales = str2num(gui_erp_plot.yscale_change.String);
        if isempty(Yscales) || numel(Yscales)~=1 || any(Yscales(:)<=0.1)
            gui_erp_plot.yscale_change.String = str2num(YScaledef);
            Yscales= YScaledef;
        end
        ERPTab_plotset_pars{3} = Yscales;
        
        min_vspacing = str2num(gui_erp_plot.min_vspacing.String);
        if isempty(min_vspacing) || nueml(min_vspacing)~=1 || any(min_vspacing(:)<=0)
            gui_erp_plot.min_vspacing.String ='1.5';
            min_vspacing = 1.5;
        end
        ERPTab_plotset_pars{4} = min_vspacing;
        
        %%fill screen?
        ERPTab_plotset_pars{5} = gui_erp_plot.fill_screen.Value;
        
        %%Number of columns
        columNum = round(str2num(gui_erp_plot.columns.String));
        if isempty(columNum) || numel(columNum)~=1 || any(columNum<=0)
            columNum =1;
            gui_erp_plot.columns.String = '1';
        end
        ERPTab_plotset_pars{6} =columNum;
        disp('Need to gray out the number of columns if viewer the ERP measurements at plot setting');
        
        %%polarity (positive up?)
        ERPTab_plotset_pars{7} =gui_erp_plot.positive_up.Value;
        
        %%overlay?
        if gui_erp_plot.pagesel.Value==1
            ERPTab_plotset_pars{8} =0;
        else
            ERPTab_plotset_pars{8} =  1;
        end
        estudioworkingmemory('ERPTab_plotset_pars',ERPTab_plotset_pars);
        observe_ERPDAT.Count_currentERP=4;
    end


%%--------------press return to execute "Apply"----------------------------
    function erp_plotsetting_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('ERPTab_chanbin');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            plot_setting_apply();
            estudioworkingmemory('ERPTab_plotset',0);
            gui_erp_plot.plot_apply.BackgroundColor =  [ 1 1 1];
            gui_erp_plot.plot_apply.ForegroundColor = [0 0 0];
            ERP_plotset_box.TitleColor= [0.0500    0.2500    0.5000];%% the default is [0.0500    0.2500    0.5000]
            gui_erp_plot.plot_reset.BackgroundColor =  [1 1 1];
            gui_erp_plot.plot_reset.ForegroundColor = [0 0 0];
        else
            return;
        end
    end

end