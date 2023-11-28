%%This function is used to setting the parameters for plotting the waveform for the selected ERPsets

% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022 & Nov 2023


function varargout = f_ERP_plot_setting_GUI(varargin)

global observe_ERPDAT;
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);
addlistener(observe_ERPDAT,'erp_two_panels_change',@erp_two_panels_change);


ERPTab_plotset = struct();
[version reldate,ColorB_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
%-----------------------------Name the title----------------------------------------------
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
        
        ERPTab_plotset.plotop = uiextras.VBox('Parent',ERP_plotset_box, 'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent', ERPTab_plotset.plotop,'String','Time Range:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def); % 1B
        ERPTab_plotset.ticks = uiextras.HBox('Parent',ERPTab_plotset.plotop,'Spacing',1,'BackgroundColor',ColorB_def);
        ERPTab_plotset.timet_auto = uicontrol('Style','checkbox','Parent', ERPTab_plotset.ticks,'String','Auto',...
            'callback',@timet_auto,'Value',1,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off'); % 2B
        ERPTab_plotset.timet_auto.KeyPressFcn=  @erp_plotsetting_presskey;
        uicontrol('Style','text','Parent', ERPTab_plotset.ticks,'String','Low','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        ERPTab_plotset.timet_low = uicontrol('Style', 'edit','Parent',ERPTab_plotset.ticks,'BackgroundColor',[1 1 1],...
            'String','','callback',@low_ticks_change,'Enable','off','FontSize',FonsizeDefault,'Enable','off');
        ERPTab_plotset.timet_low.KeyPressFcn=  @erp_plotsetting_presskey;
        uicontrol('Style','text','Parent', ERPTab_plotset.ticks,'String','High','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        ERPTab_plotset.timet_high = uicontrol('Style', 'edit','Parent',ERPTab_plotset.ticks,'String','',...
            'callback',@high_ticks_change,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
        ERPTab_plotset.timet_high.KeyPressFcn=  @erp_plotsetting_presskey;
        uicontrol('Style','text','Parent', ERPTab_plotset.ticks,'String','Step','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        ERPTab_plotset.timet_step = uicontrol('Style', 'edit','Parent',ERPTab_plotset.ticks,'String','',...
            'callback',@ticks_step_change,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
        ERPTab_plotset.timet_step.KeyPressFcn=  @erp_plotsetting_presskey;
        set(ERPTab_plotset.ticks, 'Sizes', [60 -1 -1 -1 -1 -1 -1]);
        
        uicontrol('Style','text','Parent', ERPTab_plotset.plotop,'String','Y Scale:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        ERPTab_plotset.yscale = uiextras.HBox('Parent',ERPTab_plotset.plotop,'Spacing',1,'BackgroundColor',ColorB_def);
        ERPTab_plotset.yscale_auto = uicontrol('Style','checkbox','Parent',ERPTab_plotset.yscale,'String','Auto',...
            'callback',@yscale_auto,'Value',1,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off');
        ERPTab_plotset.yscale_auto.KeyPressFcn=  @erp_plotsetting_presskey;
        
        tooltiptext = sprintf('Tick Length:\nSize of Y Ticks');
        uicontrol('Style','text','Parent',ERPTab_plotset.yscale,'String','Ticks','TooltipString',tooltiptext,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        ERPTab_plotset.yscale_change = uicontrol('Style','edit','Parent',ERPTab_plotset.yscale,'BackgroundColor',[1 1 1],...
            'String','','callback',@yscale_change,'Enable','off','FontSize',FonsizeDefault,'Enable','off');
        ERPTab_plotset.yscale_change.KeyPressFcn=  @erp_plotsetting_presskey;
        tooltiptext = sprintf('Minimum Vertical Spacing:\nSmallest possible distance in inches between zero lines before plots go off the page.');
        uicontrol('Style','text','Parent',ERPTab_plotset.yscale,'String','Spacing','TooltipString',tooltiptext,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        ERPTab_plotset.min_vspacing = uicontrol('Style','edit','Parent',ERPTab_plotset.yscale,'String','',...
            'callback',@min_vspacing,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
        ERPTab_plotset.min_vspacing.KeyPressFcn=  @erp_plotsetting_presskey;
        tooltiptext = sprintf('Fill Screen:\nDynamically expand plots to fill screen.');
        ERPTab_plotset.fill_screen = uicontrol('Style','checkbox','Parent',ERPTab_plotset.yscale,'String','Fill','callback',@fill_screen,...
            'TooltipString',tooltiptext,'Value',1,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off');
        ERPTab_plotset.fill_screen.KeyPressFcn=  @erp_plotsetting_presskey;
        set(ERPTab_plotset.yscale, 'Sizes', [50 45 35 50 35 60]);
        
        
        ERPTab_plotset.polarity_waveform = uiextras.HBox('Parent',ERPTab_plotset.plotop,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent', ERPTab_plotset.polarity_waveform,'String','Polarity:','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 1F
        
        %% polarity
        ERPTab_plotset.positive_up = uicontrol('Style','radiobutton','Parent',ERPTab_plotset.polarity_waveform,'String','Positive Up',...
            'callback',@polarity_up,'Value',1,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off'); % 2F
        ERPTab_plotset.positive_up.KeyPressFcn=  @erp_plotsetting_presskey;
        ERPTab_plotset.negative_up = uicontrol('Style','radiobutton','Parent', ERPTab_plotset.polarity_waveform,'String','Negative Up',...
            'callback',@polarity_down,'Value',0,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off'); % 2F
        ERPTab_plotset.negative_up.KeyPressFcn=  @erp_plotsetting_presskey;
        set(ERPTab_plotset.polarity_waveform, 'Sizes',[60  -1 -1]);
        
        ERPTab_plotset.bin_chan = uiextras.HBox('Parent',ERPTab_plotset.plotop,'Spacing',1,'BackgroundColor',ColorB_def);
        
        ERPTab_plotset.pagesel = uicontrol('Parent', ERPTab_plotset.bin_chan, 'Style', 'popupmenu','String',...
            {'CHANNELS with BINS overlay','BINS with CHANNELS overlay'},'callback',@pageviewchanged,'FontSize',FonsizeDefault,'Enable','off');
        ERPTab_plotset.pagesel.KeyPressFcn=  @erp_plotsetting_presskey;
        %%channel order
        ERPTab_plotset.chanorder_title = uiextras.HBox('Parent',ERPTab_plotset.plotop ,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',ERPTab_plotset.chanorder_title,'String','Channel Order (for plotting only):',...
            'FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        ERPTab_plotset.chanorder_no_title = uiextras.HBox('Parent',ERPTab_plotset.plotop ,'BackgroundColor',ColorB_def);
        ERPTab_plotset.chanorder_number = uicontrol('Parent',ERPTab_plotset.chanorder_no_title, 'Style', 'radiobutton', 'String', 'Default order',...
            'Callback', @chanorder_number,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off','Value',1);
        ERPTab_plotset.chanorder_number.KeyPressFcn=  @erp_plotsetting_presskey;
        ERPTab_plotset.chanorder_front = uicontrol('Parent',ERPTab_plotset.chanorder_no_title, 'Style', 'radiobutton', 'String', 'Front-back/left-right',...
            'Callback', @chanorder_front,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off','Value',0);
        ERPTab_plotset.chanorder_front.KeyPressFcn=  @erp_plotsetting_presskey;
        set(ERPTab_plotset.chanorder_no_title,'Sizes',[120 -1]);
        %%channel order-custom
        ERPTab_plotset.chanorder_custom_title = uiextras.HBox('Parent',ERPTab_plotset.plotop ,'BackgroundColor',ColorB_def);
        ERPTab_plotset.chanorder_custom = uicontrol('Parent',ERPTab_plotset.chanorder_custom_title, 'Style', 'radiobutton', 'String', 'Custom',...
            'Callback', @chanorder_custom,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off','Value',0);
        ERPTab_plotset.chanorder_custom_exp = uicontrol('Parent',ERPTab_plotset.chanorder_custom_title, 'Style', 'pushbutton', 'String', 'Export',...
            'Callback', @chanorder_custom_exp,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
        ERPTab_plotset.chanorder_custom_imp = uicontrol('Parent',ERPTab_plotset.chanorder_custom_title, 'Style', 'pushbutton', 'String', 'Import',...
            'Callback', @chanorder_custom_imp,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
        
        %%Grid layout
        ERPTab_plotset.gridlayout_title = uiextras.HBox('Parent',ERPTab_plotset.plotop,'Spacing',1,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent', ERPTab_plotset.gridlayout_title,'String','Grid Layout:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 1E
        
        ERPTab_plotset.gridlayout_title2 = uiextras.HBox('Parent',ERPTab_plotset.plotop,'Spacing',1,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def);
        ERPTab_plotset.gridlayoutdef = uicontrol('Style','radiobutton','Parent', ERPTab_plotset.gridlayout_title2,...
            'callback',@gridlayoutdef,'String','Default','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Value',1,'Enable','off'); % 1E
        ERPTab_plotset.gridlayoutdef.KeyPressFcn=  @erp_plotsetting_presskey;
        ERPTab_plotset.gridlayout_custom = uicontrol('Style','radiobutton','Parent', ERPTab_plotset.gridlayout_title2,...
            'callback',@gridlayout_custom,'String','Custom','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Value',0,'Enable','off'); % 1E
        ERPTab_plotset.gridlayout_custom.KeyPressFcn=  @erp_plotsetting_presskey;
        ERPTab_plotset.gridlayout_export = uicontrol('Style','pushbutton','Parent', ERPTab_plotset.gridlayout_title2,...
            'callback',@gridlayout_export,'String','Export','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off'); % 1E
        ERPTab_plotset.gridlayout_import = uicontrol('Style','pushbutton','Parent', ERPTab_plotset.gridlayout_title2,...
            'callback',@gridlayout_import,'String','Import','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off'); % 1E
        set(ERPTab_plotset.gridlayout_title2,'Sizes',[70 70 60 60]);
        
        ERPTab_plotset.row_colum_title = uiextras.HBox('Parent',ERPTab_plotset.plotop,'Spacing',1,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def);
        for ii = 1:256
            rowcolumnString{ii} = num2str(ii);
        end
        uicontrol('Style','text','Parent', ERPTab_plotset.row_colum_title,'String','Row(s):','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 1E
        ERPTab_plotset.rowNum_set = uicontrol('Style','popupmenu','Parent', ERPTab_plotset.row_colum_title,'Enable','off',...
            'String',rowcolumnString,'callback',@rowNum_set,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Value',1);
        ERPTab_plotset.rowNum_set.KeyPressFcn=  @erp_plotsetting_presskey;
        uicontrol('Style','text','Parent', ERPTab_plotset.row_colum_title,'String','Column(s):','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 1E
        ERPTab_plotset.columns = uicontrol('Style','popupmenu','Parent', ERPTab_plotset.row_colum_title,'Enable','off',...
            'String',rowcolumnString,'callback',@columNum_select,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Value',1); % 2E Plot_column
        ERPTab_plotset.columns.KeyPressFcn=  @erp_plotsetting_presskey;
        set(ERPTab_plotset.row_colum_title,'Sizes',[45 75 60 75]);
        
        %%cancel & apply
        ERPTab_plotset.reset_apply = uiextras.HBox('Parent',ERPTab_plotset.plotop,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', ERPTab_plotset.reset_apply); % 1A
        ERPTab_plotset.plot_reset = uicontrol('Style', 'pushbutton','Parent',ERPTab_plotset.reset_apply,'Enable','off',...
            'String','Cancel','callback',@plot_erp_reset,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', ERPTab_plotset.reset_apply); % 1A
        ERPTab_plotset.plot_apply = uicontrol('Style', 'pushbutton','Parent',ERPTab_plotset.reset_apply,'Enable','off',...
            'String','Apply','callback',@plot_setting_apply,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', ERPTab_plotset.reset_apply); % 1A
        set(ERPTab_plotset.reset_apply, 'Sizes',[10 -1  30 -1 10]);
        
        set(ERPTab_plotset.plotop, 'Sizes', [20 25 20 25 25 25 20 20 25 20 25 25 30]);
        ERPTab_plotset.chanorderIndex = 1;
        ERPTab_plotset.chanorder{1,1}=[];
        ERPTab_plotset.chanorder{1,2} = '';
        estudioworkingmemory('ERP_chanorders',{ERPTab_plotset.chanorderIndex,ERPTab_plotset.chanorder});
        estudioworkingmemory('ERPTab_plotset_pars',[]);
        estudioworkingmemory('ERPTab_plotset',0);
        ERPTab_plotset.timet_auto_reset = 1;
        ERPTab_plotset.timeticks_auto_reset = 1;
        ERPTab_plotset.gridlayputarray = [];
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
        ERPTab_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_reset.ForegroundColor = [1 1 1];
        
        if src.Value == 1
            ERPTab_plotset.timet_low.Enable = 'off';
            ERPTab_plotset.timet_high.Enable = 'off';
            ERPTab_plotset.timet_step.Enable = 'off';
            ERPTab_plotset.timet_low.String = num2str(observe_ERPDAT.ERP.times(1));
            ERPTab_plotset.timet_high.String = num2str(observe_ERPDAT.ERP.times(end));
            Min_time=floor(observe_ERPDAT.ERP.times(1)/5)*5;
            Max_time = ceil(observe_ERPDAT.ERP.times(end)/5)*5;
            [def xstep]= default_time_ticks_studio(observe_ERPDAT.ERP, [Min_time,Max_time]);
            ERPTab_plotset.timet_step.String = num2str(xstep);
        else
            ERPTab_plotset.timet_low.Enable = 'on';
            ERPTab_plotset.timet_high.Enable = 'on';
            ERPTab_plotset.timet_step.Enable = 'on';
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
        ERPTab_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_reset.ForegroundColor = [1 1 1];
        xtixlk_min = str2num(src.String);
        xtixlk_max = str2num(ERPTab_plotset.timet_high.String);
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
        ERPTab_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_reset.ForegroundColor = [1 1 1];
        
        xtixlk_min = str2num(ERPTab_plotset.timet_low.String);
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
        ERPTab_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_reset.ForegroundColor = [1 1 1];
        
        timeStart = str2num(ERPTab_plotset.timet_low.String);
        timEnd = str2num(ERPTab_plotset.timet_high.String);
        
        if ~isempty(timeStart) && ~isempty(timEnd) && numel(timEnd)==1 && numel(timeStart) ==1 && timeStart < timEnd
            [def xtickstepdef]= default_time_ticks_studio(observe_ERPDAT.ERP, [timEnd,timeStart]);
        else
            xtickstepdef = [];
        end
        tick_step = str2num(src.String);
        if isempty(tick_step) || numel(tick_step)~=1 || any(tick_step<=0)
            src.String = num2str(xtickstepdef);
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
        ERPTab_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_reset.ForegroundColor = [1 1 1];
        
        if ERPTab_plotset.positive_up.Value==1
            positive_up = 1;
        else
            positive_up = -1;
        end
        if src.Value == 1
            ERPTab_plotset.yscale_change.Enable = 'off';
            YScale =prctile(observe_ERPDAT.ERP.bindata(:)*positive_up,95)*2/3;
            
            if YScale>= 0&&YScale <=0.1
                YScale = 0.1;
            elseif YScale< 0&& YScale > -0.1
                YScale = -0.1;
            else
                YScale = round(YScale);
            end
            ERPTab_plotset.yscale_change.String = YScale;
            ERPTab_plotset.min_vspacing.Enable = 'off';
            ERPTab_plotset.min_vspacing.String = 1.5;
        else
            ERPTab_plotset.yscale_change.Enable = 'on';
            ERPTab_plotset.min_vspacing.Enable = 'on';
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
        ERPTab_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_reset.ForegroundColor = [1 1 1];
        val = str2num(src.String);
        if isempty(val)  || numel(val)~=1 || any(val(:)<=0)
            if ERPTab_plotset.positive_up.Value==1
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
        ERPTab_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_reset.ForegroundColor = [1 1 1];
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
        ERPTab_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_reset.ForegroundColor = [1 1 1];
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
        ERPTab_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_reset.ForegroundColor = [1 1 1];
        ERPTab_plotset.positive_up.Value =1;
        ERPTab_plotset.negative_up.Value = 0;
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
        ERPTab_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_reset.ForegroundColor = [1 1 1];
        ERPTab_plotset.positive_up.Value =0;
        ERPTab_plotset.negative_up.Value = 1;
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
        ERPTab_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_reset.ForegroundColor = [1 1 1];
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
        ERPTab_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_reset.ForegroundColor = [1 1 1];
        
        ERPTab_plotset.chanorder_number.Value=1;
        ERPTab_plotset.chanorder_front.Value=0;
        ERPTab_plotset.chanorder_custom.Value=0;
        ERPTab_plotset.chanorder_custom_exp.Enable = 'off';
        ERPTab_plotset.chanorder_custom_imp.Enable = 'off';
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
        ERPTab_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_reset.ForegroundColor = [1 1 1];
        
        
        ERPTab_plotset.chanorder_number.Value=0;
        ERPTab_plotset.chanorder_front.Value=1;
        ERPTab_plotset.chanorder_custom.Value=0;
        ERPTab_plotset.chanorder_custom_exp.Enable = 'off';
        ERPTab_plotset.chanorder_custom_imp.Enable = 'off';
        try
            chanlocs = observe_ERPDAT.ERP.chanlocs;
            if isempty(chanlocs(1).X) &&  isempty(chanlocs(1).Y)
                MessageViewer= char(strcat('Plot Setting > Channel order>Front-back/left-right:please do "chan locations" first in EEGLAB Tool panel.'));
                erpworkingmemory('f_ERP_proces_messg',MessageViewer);
                observe_ERPDAT.Process_messg=4;
                ERPTab_plotset.chanorder_number.Value=1;
                ERPTab_plotset.chanorder_front.Value=0;
                ERPTab_plotset.chanorder_custom.Value=0;
                ERPTab_plotset.chanorder_custom_exp.Enable = 'off';
                ERPTab_plotset.chanorder_custom_imp.Enable = 'off';
            end
        catch
            MessageViewer= char(strcat('Plot Setting > Channel order>Front-back/left-right: It seems that chanlocs for the current ERP is empty and please check it out'));
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
            ERPTab_plotset.chanorder_number.Value=1;
            ERPTab_plotset.chanorder_front.Value=0;
            ERPTab_plotset.chanorder_custom.Value=0;
            ERPTab_plotset.chanorder_custom_exp.Enable = 'off';
            ERPTab_plotset.chanorder_custom_imp.Enable = 'off';
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
        ERPTab_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_reset.ForegroundColor = [1 1 1];
        
        ERPTab_plotset.chanorder_number.Value=0;
        ERPTab_plotset.chanorder_front.Value=0;
        ERPTab_plotset.chanorder_custom.Value=1;
        ERPTab_plotset.chanorder_custom_exp.Enable = 'on';
        ERPTab_plotset.chanorder_custom_imp.Enable = 'on';
        if ~isfield(observe_ERPDAT.ERP,'chanlocs') || isempty(observe_ERPDAT.ERP.chanlocs)
            MessageViewer= char(strcat('Plot Setting > Channel order>Front-back/left-right: It seems that chanlocs for the current EEG is empty and please check it out'));
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
            ERPTab_plotset.chanorder_number.Value=1;
            ERPTab_plotset.chanorder_front.Value=0;
            ERPTab_plotset.chanorder_custom.Value=0;
            ERPTab_plotset.chanorder_custom_exp.Enable = 'off';
            ERPTab_plotset.chanorder_custom_imp.Enable = 'off';
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
            ERPTab_plotset.chanorder_number.Value=1;
            ERPTab_plotset.chanorder_front.Value=0;
            ERPTab_plotset.chanorder_custom.Value=0;
            ERPTab_plotset.chanorder_custom_exp.Enable = 'off';
            ERPTab_plotset.chanorder_custom_imp.Enable = 'off';
            return;
        end
        
        MessageViewer= char(strcat('Plot Setting > Channel order>Custom>Export'));
        erpworkingmemory('f_ERP_proces_messg',MessageViewer);
        observe_ERPDAT.Process_messg=1;
        
        if isempty(ERPTab_plotset.chanorder{1,1}) || isempty(ERPTab_plotset.chanorder{1,2})
            chanOrders = [1:observe_ERPDAT.ERP.nchan];
            [eloc, labels, theta, radius, indices] = readlocs(observe_ERPDAT.ERP.chanlocs);
        else
            chanOrders =  ERPTab_plotset.chanorder{1,1} ;
            labels=  ERPTab_plotset.chanorder{1,2};
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
        [erpfilename, erppathname, indxs] = uiputfile({'*.tsv'}, ...
            ['Export ERP channel order (for plotting only)'],...
            fullfile(pathstr,namedef));
        if isequal(erpfilename,0)
            disp('User selected Cancel')
            return
        end
        
        [pathstr, erpfilename, ext] = fileparts(erpfilename) ;
        ext = '.tsv';
        
        erpFilename = char(strcat(erppathname,erpfilename,ext));
        fileID = fopen(erpFilename,'w+');
        
        formatSpec =['%s\t',32];
        for jj = 1:2
            if jj==1
                formatSpec = strcat(formatSpec,'%d\t',32);
            else
                formatSpec = strcat(formatSpec,'%s\t',32);
            end
        end
        formatSpec = strcat(formatSpec,'\n');
        columName = {'','Column1','Column2'};
        
        fprintf(fileID,'%s\t %s\t %s\t\n',columName{1,:});
        for row = 1:numel(chanOrders)
            rowdata = cell(1,3);
            rowdata{1,1} = char(['Row',num2str(row)]);
            for jj = 1:2
                rowdata{1,jj+1} = Data{row,jj};
            end
            fprintf(fileID,formatSpec,rowdata{1,:});
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
        ERPTab_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_reset.ForegroundColor = [1 1 1];
        
        if ~isfield(observe_ERPDAT.ERP,'chanlocs') || isempty(observe_ERPDAT.ERP.chanlocs)
            MessageViewer= char(strcat('Plot Setting > Channel order>Custom>Import: It seems that chanlocs for the current ERP is empty and please check it out'));
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
            ERPTab_plotset.chanorder_number.Value=1;
            ERPTab_plotset.chanorder_front.Value=0;
            ERPTab_plotset.chanorder_custom.Value=0;
            ERPTab_plotset.chanorder_custom_exp.Enable = 'off';
            ERPTab_plotset.chanorder_custom_imp.Enable = 'off';
            return;
        end
        
        %%import data chan orders
        [eloc, labels, theta, radius, indices] = readlocs(observe_ERPDAT.ERP.chanlocs);
        
        [erpfilename, erppathname, indxs] = uigetfile({'*.tsv'}, ...
            ['Import ERP channel order (for plotting only)'],...
            'MultiSelect', 'off');
        if isequal(erpfilename,0) || indxs~=1
            disp('User selected Cancel')
            return
        end
        
        [pathstr, erpfilename, ext] = fileparts(erpfilename) ;
        ext = '.tsv';
        erpFilename = char(strcat(erppathname,erpfilename,ext));
        
        DataInput =  readtable(erpFilename, "FileType","text");
        if isempty(DataInput)
            ERPTab_plotset.chanorder{1,1}=[];
            ERPTab_plotset.chanorder{1,2} = '';
        end
        DataInput = table2cell(DataInput);
        chanorders = [];
        chanlabes = [];
        DataInput = DataInput(:,2:end);
        for ii = 1:size(DataInput,1)
            if isnumeric(DataInput{ii,1})
                chanorders(ii) = DataInput{ii,1};
            else
                chanorders(ii) =0;
                disp(['The values is not a number at Row:',32,num2str(ii),', Column 1\n']);
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
            ERPTab_plotset.chanorder_number.Value=1;
            ERPTab_plotset.chanorder_front.Value=0;
            ERPTab_plotset.chanorder_custom.Value=0;
            ERPTab_plotset.chanorder_custom_exp.Enable = 'off';
            ERPTab_plotset.chanorder_custom_imp.Enable = 'off';
            return;
        end
        if numel(chanorders1)~= observe_ERPDAT.ERP.nchan
            MessageViewer= strcat(['Plot Setting > Channel order>Custom>Import: The number of the defined chan orders must be',32,num2str(observe_ERPDAT.ERP.nchan)]);
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
            ERPTab_plotset.chanorder_number.Value=1;
            ERPTab_plotset.chanorder_front.Value=0;
            ERPTab_plotset.chanorder_custom.Value=0;
            ERPTab_plotset.chanorder_custom_exp.Enable = 'off';
            ERPTab_plotset.chanorder_custom_imp.Enable = 'off';
            return;
        end
        [C,IA]= ismember_bc2(chanlabes,labels);
        if any(IA==0)
            MessageViewer= strcat(['Plot Setting > Channel order>Custom>Import: The names of channels must be the same to the current ERP']);
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            [xpos,ypos] =find(IA==0);
            if ~isempty(ypos)
                labelsmatch = '';
                for ii = 1:numel(ypos)
                    if ii==1
                        labelsmatch = [labelsmatch,32,chanlabes{ypos(ii)}];
                    else
                        labelsmatch = [labelsmatch,',',32,chanlabes{ypos(ii)}];
                    end
                end
                disp(['The defined labels that didnot match: ',32,labelsmatch]);
            end
            ypos = setdiff([1:length(labels)],setdiff(IA,0));
            if ~isempty(ypos)
                labelsmatch = '';
                for ii = 1:numel(ypos)
                    if ii==1
                        labelsmatch = [labelsmatch,32,labels{ypos(ii)}];
                    else
                        labelsmatch = [labelsmatch,',',32,labels{ypos(ii)}];
                    end
                end
                disp(['The labels  that didnot match for the current data: ',32,labelsmatch]);
            end
            observe_ERPDAT.Process_messg=4;
            ERPTab_plotset.chanorder_number.Value=1;
            ERPTab_plotset.chanorder_front.Value=0;
            ERPTab_plotset.chanorder_custom.Value=0;
            ERPTab_plotset.chanorder_custom_exp.Enable = 'off';
            ERPTab_plotset.chanorder_custom_imp.Enable = 'off';
            return;
        end
        if ~isempty(IA)
            IA = unique(IA);
        end
        if numel(IA)~=observe_ERPDAT.ERP.nchan
            MessageViewer= strcat(['Plot Setting > Channel order>Custom>Import: There are some replicated channel labels']);
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
            ERPTab_plotset.chanorder_number.Value=1;
            ERPTab_plotset.chanorder_front.Value=0;
            ERPTab_plotset.chanorder_custom.Value=0;
            ERPTab_plotset.chanorder_custom_exp.Enable = 'off';
            ERPTab_plotset.chanorder_custom_imp.Enable = 'off';
            return;
        end
        ERPTab_plotset.chanorder{1,1}=chanorders;
        ERPTab_plotset.chanorder{1,2} = chanlabes;
    end

%%-------------------default layout----------------------------------------
    function gridlayoutdef(source,~)
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
        ERPTab_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_reset.ForegroundColor = [1 1 1];
        ERPTab_plotset.gridlayoutdef.Value = 1;
        ERPTab_plotset.gridlayout_custom.Value = 0;
        ERPTab_plotset.gridlayout_export.Enable ='off';
        ERPTab_plotset.gridlayout_import.Enable ='off';
        ERPTab_plotset.rowNum_set.Enable ='off';
        ERPTab_plotset.columns.Enable ='off';
        ERPTab_plotset.columns.Value=1;
        ChanArray=estudioworkingmemory('ERP_ChanArray');
        if isempty(ChanArray) || any(ChanArray<=0) || any(ChanArray>observe_ERPDAT.ERP.nchan)
            ChanArray = [1:observe_ERPDAT.ERP.nchan];
            estudioworkingmemory('ERP_ChanArray',ChanArray);
        end
        BinArray= estudioworkingmemory('ERP_BinArray');
        if isempty(BinArray) || any(BinArray<=0) || any(BinArray>observe_ERPDAT.ERP.nbin)
            BinArray = [1:observe_ERPDAT.ERP.nbin];
            estudioworkingmemory('ERP_BinArray',BinArray);
        end
        if ERPTab_plotset.pagesel.Value==1
            nplot = numel(ChanArray);
            [~, labelsdef, ~, ~, ~] = readlocs(observe_ERPDAT.ERP.chanlocs);
            plotarray = ChanArray;
        else
            nplot = numel(BinArray);
            labelsdef =observe_ERPDAT.ERP.bindescr;
            plotarray = BinArray;
        end
        
        rowNum = ceil(sqrt(nplot));
        ERPTab_plotset.rowNum_set.Value=rowNum;
        ERPTab_plotset.columns.Value =ceil(nplot/rowNum);
        gridlayputarray = cell(ERPTab_plotset.rowNum_set.Value,ERPTab_plotset.columns.Value);
        count = 0;
        for ii = 1:ERPTab_plotset.rowNum_set.Value
            for jj = 1:ERPTab_plotset.columns.Value
                count = count+1;
                if count>nplot
                    break;
                end
                gridlayputarray{ii,jj} = labelsdef{plotarray(count)};
            end
        end
        ERPTab_plotset.gridlayputarray = gridlayputarray;
    end

%%-------------------custom layout-----------------------------------------
    function gridlayout_custom(source,~)
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
        ERPTab_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_reset.ForegroundColor = [1 1 1];
        
        ERPTab_plotset.gridlayoutdef.Value = 0;
        ERPTab_plotset.gridlayout_custom.Value = 1;
        ERPTab_plotset.gridlayout_export.Enable ='on';
        ERPTab_plotset.gridlayout_import.Enable ='on';
        ERPTab_plotset.rowNum_set.Enable ='on';
        ERPTab_plotset.columns.Enable ='on';
    end

%%---------------------export layout---------------------------------------
    function gridlayout_export(Source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=2;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) %%&& eegpanelIndex~=2
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_ERP_proces_messg','Plot Setting > Grid Layout > Export');
        observe_ERPDAT.Process_messg =1;
        pathstr = pwd;
        namedef ='GridLocations';
        [erpfilename, erppathname, indxs] = uiputfile({'*.tsv'}, ...
            ['Save Grid Locations as'],...
            fullfile(pathstr,namedef));
        if isequal(erpfilename,0)
            disp('User selected Cancel')
            return
        end
        [pathstr, erpfilename, ext] = fileparts(erpfilename) ;
        ext = '.tsv';
        erpFilename = char(strcat(erppathname,erpfilename,ext));
        
        AllabelArray = ERPTab_plotset.gridlayputarray;
        
        rowNums = ERPTab_plotset.rowNum_set.Value;
        columNums = ERPTab_plotset.columns.Value;
        
        if isempty(AllabelArray) || rowNums~= size(AllabelArray,1) || columNums~= size(AllabelArray,2)
            AllabelArray = reshape(AllabelArray,numel(AllabelArray),1);
            AllabelArray_new  = cell(rowNums,columNums);
            count = 0;
            for ii = 1:rowNums
                for jj = 1:columNums
                    count=count+1;
                    if count<= numel(AllabelArray)
                        AllabelArray_new{ii,jj}  = AllabelArray{count};
                    end
                end
            end
            AllabelArray = AllabelArray_new;
        end
        
        fileID = fopen(erpFilename,'w');
        [nrows,ncols] = size(AllabelArray);
        formatSpec ='';
        for jj = 1:ncols+1
            formatSpec = strcat(formatSpec,'%s\t',32);
            if jj==1
                columName{1,jj} = '';
            else
                columName{1,jj} = ['Column',32,num2str(jj-1)];
            end
        end
        formatSpec = strcat(formatSpec,'\n');
        fprintf(fileID,formatSpec,columName{1,:});
        for row = 1:nrows
            rowdata = cell(1,ncols+1);
            rowdata{1,1} = char(['Row',num2str(row)]);
            for jj = 1:ncols
                rowdata{1,jj+1} = AllabelArray{row,jj};
            end
            fprintf(fileID,formatSpec,rowdata{1,:});
        end
        fclose(fileID);
        observe_ERPDAT.Process_messg =2;
    end

%%---------------------import layout---------------------------------------
    function gridlayout_import(source,~)
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
        ERPTab_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_reset.ForegroundColor = [1 1 1];
        
        [filename, filepath] = uigetfile('*.tsv', ...
            'Plot Setting > Grid Layout > Import', ...
            'MultiSelect', 'off');
        if isequal(filename,0)
            disp('User selected Cancel');
            return;
        end
        try
            DataInput =  readtable([filepath,filename], "FileType","text");
        catch
            DataInput =  readtable([filepath,filename], "FileType","text");
            erpworkingmemory('f_ERP_proces_messg',['Plot Setting > Grid Layout > Import:','Cannot import:',filepath,filename]);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        if isempty(DataInput)
            erpworkingmemory('f_ERP_proces_messg','Plot Setting > Grid Layout > Import is invalid');
            observe_ERPDAT.Process_messg =4;
            return;
        end
        overlapindex =1;% ERPTab_plotset.pagesel.Value;
        DataInput = table2cell(DataInput);
        
        [rows,columns] = size(DataInput);
        if columns<=2
            erpworkingmemory('f_ERP_proces_messg','Plot Setting > Grid Layout > Import is invalid and one column is designed besides the first column that is row title');
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
        DataInput = DataInput(:,2:end);
        [Griddata, checkflag ]= f_tranf_check_import_grid(DataInput,overlapindex);
        if checkflag==0
            erpworkingmemory('f_ERP_proces_messg','Plot Setting > Grid Layout > Import is invalid or didnot match with existing labels');
            observe_ERPDAT.Process_messg =4;
            return;
        end
        ERPTab_plotset.rowNum_set.Value =size(Griddata,1);
        ERPTab_plotset.columns.Value =size(Griddata,2);
        ERPTab_plotset.gridlayputarray = Griddata;%%save the grid layout
    end

%%--------------------row numbers------------------------------------------
    function rowNum_set(Source,~)
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
        ERPTab_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_reset.ForegroundColor = [1 1 1];
    end

%%------------------------column numbers-----------------------------------
    function columNum_select(Source,~)
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
        ERPTab_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_apply.ForegroundColor = [1 1 1];
        ERP_plotset_box.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_plotset.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_plotset.plot_reset.ForegroundColor = [1 1 1];
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
        ERPTab_plotset.plot_apply.BackgroundColor =  [ 1 1 1];
        ERPTab_plotset.plot_apply.ForegroundColor = [0 0 0];
        ERP_plotset_box.TitleColor= [0.0500    0.2500    0.5000];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_plotset.plot_reset.BackgroundColor =  [1 1 1];
        ERPTab_plotset.plot_reset.ForegroundColor = [0 0 0];
        
        erpworkingmemory('f_ERP_proces_messg','Plot Setting>Cancel');
        observe_ERPDAT.Process_messg =1;
        %
        %%------------------------------time range-------------------------
        ERPTab_plotset_pars =  estudioworkingmemory('ERPTab_plotset_pars');
        timelowdef = observe_ERPDAT.ERP.times(1);
        timehighdef= observe_ERPDAT.ERP.times(end);
        [def xtickstepdef]= default_time_ticks_studio(observe_ERPDAT.ERP, [timelowdef,timehighdef]);
        if ERPTab_plotset.timet_auto_reset==1
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
        ERPTab_plotset.timet_auto.Value = ERPTab_plotset.timet_auto_reset;
        
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
        ERPTab_plotset.timet_low.Enable = Enablerange;
        ERPTab_plotset.timet_high.Enable =  Enablerange;
        ERPTab_plotset.timet_step.Enable = Enablerange;
        ERPTab_plotset.timet_low.String = num2str(timelow);
        ERPTab_plotset.timet_high.String = num2str(timehigh);
        ERPTab_plotset.timet_step.String =  num2str(xtickstep);
        %
        %%------------------------y scale----------------------------------
        if ERPTab_plotset.positive_up.Value==1
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
        
        if ERPTab_plotset.timeticks_auto_reset==1
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
        ERPTab_plotset.yscale_auto.Value = ERPTab_plotset.timeticks_auto_reset;
        ERPTab_plotset.yscale_change.String = num2str(yscale);
        ERPTab_plotset.yscale_change.Enable = Enableflag;
        ERPTab_plotset.min_vspacing.String = num2str(min_vspacing);
        ERPTab_plotset.min_vspacing.Enable = Enableflag;
        
        %
        %%fill screeen?
        try
            fill_screen =  ERPTab_plotset_pars{5};
        catch
            fill_screen=1;
        end
        if isempty(fill_screen) || numel(fill_screen)~=1 || (fill_screen~=0 && fill_screen~=1)
            fill_screen=1;
            ERPTab_plotset_pars{5}=1;
        end
        ERPTab_plotset.fill_screen.Value = fill_screen;
        
        %
        %%Number of columns?
        ColumnNum= ERPTab_plotset_pars{6};
        if isempty(ColumnNum) || numel(ColumnNum)~=1 || any(ColumnNum<=0)
            ColumnNum =1;
            ERPTab_plotset_pars{6}=1;
        end
        ERPTab_plotset.columns.Value =ColumnNum; % 2E Plot_column
        ERPTab_plotset.columns.Enable = 'on';
        
        %
        %%polarity?
        positive_up =  ERPTab_plotset_pars{7};
        if isempty(positive_up) ||  numel(positive_up)~=1 || (positive_up~=0&&positive_up~=1)
            positive_up=1;
            ERPTab_plotset_pars{7}=1;
        end
        ERPTab_plotset.positive_up.Value =positive_up;
        ERPTab_plotset.negative_up.Value = ~positive_up;
        %
        %%overlay?
        Bin_chan_overlay=ERPTab_plotset_pars{8};
        if isempty(Bin_chan_overlay) || numel(Bin_chan_overlay)~=1 || (Bin_chan_overlay~=0 && Bin_chan_overlay~=1)
            Bin_chan_overlay=0;
            ERPTab_plotset_pars{8}=0;
        end
        set(ERPTab_plotset.pagesel,'Value',Bin_chan_overlay+1);
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
            ERPTab_plotset.chanorder_number.Value=1;
            ERPTab_plotset.chanorder_front.Value=0;
            ERPTab_plotset.chanorder_custom.Value=0;
            ERPTab_plotset.chanorder_custom_exp.Enable = 'off';
            ERPTab_plotset.chanorder_custom_imp.Enable = 'off';
        elseif chanordervalue==2
            ERPTab_plotset.chanorder_number.Value=0;
            ERPTab_plotset.chanorder_front.Value=1;
            ERPTab_plotset.chanorder_custom.Value=0;
            ERPTab_plotset.chanorder_custom_exp.Enable = 'off';
            ERPTab_plotset.chanorder_custom_imp.Enable = 'off';
        elseif chanordervalue==3
            ERPTab_plotset.chanorder_number.Value=0;
            ERPTab_plotset.chanorder_front.Value=0;
            ERPTab_plotset.chanorder_custom.Value=1;
            ERPTab_plotset.chanorder_custom_exp.Enable = 'on';
            ERPTab_plotset.chanorder_custom_imp.Enable = 'on';
        end
        try rowNum = ERPTab_plotset_pars{9};catch rowNum=1;ERPTab_plotset_pars{9}=1; end
        ERPTab_plotset.rowNum_set.Value=rowNum;
        
        
        try gridlayoutdef =  ERPTab_plotset_pars{10};catch gridlayoutdef =1; ERPTab_plotset_pars{10}=1;  end
        if isempty(gridlayoutdef) || numel(gridlayoutdef)~=1 || (gridlayoutdef~=0 && gridlayoutdef~=1)
            gridlayoutdef =1; ERPTab_plotset_pars{10}=1;
        end
        ERPTab_plotset.gridlayoutdef.Value=gridlayoutdef;%%default grid layout?
        ERPTab_plotset.gridlayout_custom.Value = ~gridlayoutdef;
        if gridlayoutdef==1
            EnableFlag= 'off';
        else
            EnableFlag= 'on';
        end
        ERPTab_plotset.gridlayout_export.Enable =EnableFlag;
        ERPTab_plotset.gridlayout_import.Enable =EnableFlag;
        ERPTab_plotset.rowNum_set.Enable =EnableFlag;
        ERPTab_plotset.columns.Enable =EnableFlag;
        
        ChanArray=estudioworkingmemory('ERP_ChanArray');
        if isempty(ChanArray) || any(ChanArray<=0) || any(ChanArray>observe_ERPDAT.ERP.nchan)
            ChanArray = [1:observe_ERPDAT.ERP.nchan];
            estudioworkingmemory('ERP_ChanArray',ChanArray);
        end
        BinArray= estudioworkingmemory('ERP_BinArray');
        if isempty(BinArray) || any(BinArray<=0) || any(BinArray>observe_ERPDAT.ERP.nbin)
            BinArray = [1:observe_ERPDAT.ERP.nbin];
            estudioworkingmemory('ERP_BinArray',BinArray);
        end
        if ERPTab_plotset.pagesel.Value==1
            nplot = numel(ChanArray);
            [~, labelsdef, ~, ~, ~] = readlocs(observe_ERPDAT.ERP.chanlocs);
            plotarray = ChanArray;
        else
            nplot = numel(BinArray);
            labelsdef =observe_ERPDAT.ERP.bindescr;
            plotarray = BinArray;
        end
        
        if gridlayoutdef==1
            ERPTab_plotset.rowNum_set.Value = ceil(sqrt(nplot));
            ERPTab_plotset.columns.Value = ceil(nplot/ceil(sqrt(nplot)));
        end
        
        
        gridlayputarraydef = cell(ERPTab_plotset.rowNum_set.Value,ERPTab_plotset.columns.Value);
        count = 0;
        for ii = 1:ERPTab_plotset.rowNum_set.Value
            for jj = 1:ERPTab_plotset.columns.Value
                count = count+1;
                if count>nplot
                    break;
                end
                gridlayputarraydef{ii,jj} = labelsdef{plotarray(count)};
            end
        end
        if gridlayoutdef==1
            ERPTab_plotset.gridlayputarray=gridlayputarraydef;
        end
        
        try gridlayputarray= ERPTab_plotset_pars{11};catch gridlayputarray= gridlayputarraydef ;ERPTab_plotset_pars{11}=gridlayputarraydef; end
        ERPTab_plotset.gridlayputarray=gridlayputarray;
        ERPTab_plotset_pars{11} = ERPTab_plotset.gridlayputarray;
        estudioworkingmemory('ERPTab_plotset_pars',ERPTab_plotset_pars);
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
        ERPTab_plotset.plot_apply.BackgroundColor =  [ 1 1 1];
        ERPTab_plotset.plot_apply.ForegroundColor = [0 0 0];
        ERP_plotset_box.TitleColor= [0.0500    0.2500    0.5000];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_plotset.plot_reset.BackgroundColor =  [1 1 1];
        ERPTab_plotset.plot_reset.ForegroundColor = [0 0 0];
        
        erpworkingmemory('f_ERP_proces_messg','Plot Setting>Apply');
        observe_ERPDAT.Process_messg =1;
        ERPTab_plotset.timet_auto_reset = ERPTab_plotset.timet_auto.Value;
        ERPTab_plotset.timeticks_auto_reset = ERPTab_plotset.yscale_auto.Value;
        %
        %%time range
        timeStartdef = observe_ERPDAT.ERP.times(1);
        timEnddef = observe_ERPDAT.ERP.times(end);
        [def xstepdef]= default_time_ticks_studio(observe_ERPDAT.ERP, [observe_ERPDAT.ERP.times(1),observe_ERPDAT.ERP.times(end)]);
        
        timeStart = str2num(ERPTab_plotset.timet_low.String);
        if isempty(timeStart) || numel(timeStart)~=1 ||  timeStart>=observe_ERPDAT.ERP.times(end)
            timeStart = timeStartdef;
            ERPTab_plotset.timet_low.String = num2str(observe_ERPDAT.ERP.times(1));
            MessageViewer= char(['Plot Setting > Apply: Low edge of the time range should be smaller',32,num2str(observe_ERPDAT.ERP.times(end)),32,...
                'we therefore set to be',32,num2str(timeStart)]);
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
        end
        
        timEnd = str2num(ERPTab_plotset.timet_high.String);
        if isempty(timEnd) || numel(timEnd)~=1 || timEnd<=observe_ERPDAT.ERP.times(1)
            timEnd = timEnddef;
            ERPTab_plotset.timet_high.String = num2str(timEnd);
            MessageViewer= char(['Plot Setting > Apply: High edge of the time range should be larger',32,num2str(timeStartdef),32,...
                'we therefore set to be',32,num2str(timEnddef)]);
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
        end
        
        if timeStart>= timEnd
            timEnd = timEnddef;
            timeStart = timeStartdef;
            ERPTab_plotset.timet_low.String = num2str(timeStart);
            ERPTab_plotset.timet_high.String = num2str(timEnd);
            MessageViewer= char(['Plot Setting > Apply: Low edge of the time range should be smaller than the high one and we therefore used the defaults']);
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
        end
        ERPTab_plotset_pars{1} = [timeStart,timEnd];
        
        xtickstep = str2num(ERPTab_plotset.timet_step.String);
        if isempty(xtickstep) || numel(xtickstep)~=1 || xtickstep> floor((timEnd-timeStart)/2) || any(xtickstep<=0)
            xtickstep = xstepdef;
            ERPTab_plotset.timet_step.String = num2str(xtickstep);
            MessageViewer= char(['Plot Setting > Apply: the step of the time range should be a positive number that belows',32,num2str(floor((timEnd-timeStart)/2))]);
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
        end
        ERPTab_plotset_pars{2} = xtickstep;
        
        %
        %%Y scale
        if ERPTab_plotset.positive_up.Value==1
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
        
        Yscales = str2num(ERPTab_plotset.yscale_change.String);
        if isempty(Yscales) || numel(Yscales)~=1 || any(Yscales(:)<=0.1)
            ERPTab_plotset.yscale_change.String = str2num(YScaledef);
            Yscales= YScaledef;
            MessageViewer= char(['Plot Setting > Apply: the tick of y scale should be lager than 0.1']);
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
        end
        ERPTab_plotset_pars{3} = Yscales;
        
        min_vspacing = str2num(ERPTab_plotset.min_vspacing.String);
        if isempty(min_vspacing) || numel(min_vspacing)~=1 || any(min_vspacing<=0)
            min_vspacing=1.5;
            ERPTab_plotset.min_vspacing.String = '1.5';
            MessageViewer= char(['Plot Setting > Apply: the spacing for y scale should be a positive value']);
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
        end
        ERPTab_plotset_pars{4} = min_vspacing;
        %
        %%fill screen?
        ERPTab_plotset_pars{5} = ERPTab_plotset.fill_screen.Value;
        %%Number of columns
        columNum = round(ERPTab_plotset.columns.Value);
        if isempty(columNum) || numel(columNum)~=1 || any(columNum<=0)
            columNum =1;
            ERPTab_plotset.columns.String = '1';
            MessageViewer= char(['Plot Setting > Apply: the number of columns should be a positive value']);
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
        end
        ERPTab_plotset_pars{6} =columNum;
        
        %
        %%polarity (positive up?)
        ERPTab_plotset_pars{7} =ERPTab_plotset.positive_up.Value;
        %
        %%overlay?
        if ERPTab_plotset.pagesel.Value==1
            ERPTab_plotset_pars{8} =0;
        else
            ERPTab_plotset_pars{8} =  1;
        end
        
        ERPTab_plotset_pars{9}  = ERPTab_plotset.rowNum_set.Value;%%number of rows
        ERPTab_plotset_pars{10} = ERPTab_plotset.gridlayoutdef.Value ;%%default grid layout?
        
        ChanArray=estudioworkingmemory('ERP_ChanArray');
        if isempty(ChanArray) || any(ChanArray<=0) || any(ChanArray>observe_ERPDAT.ERP.nchan)
            ChanArray = [1:observe_ERPDAT.ERP.nchan];
            estudioworkingmemory('ERP_ChanArray',ChanArray);
        end
        BinArray= estudioworkingmemory('ERP_BinArray');
        if isempty(BinArray) || any(BinArray<=0) || any(BinArray>observe_ERPDAT.ERP.nbin)
            BinArray = [1:observe_ERPDAT.ERP.nbin];
            estudioworkingmemory('ERP_BinArray',BinArray);
        end
        if ERPTab_plotset.pagesel.Value==1
            [~,plotArraystr] = readlocs(observe_ERPDAT.ERP.chanlocs(ChanArray));
        else
            plotArraystr= observe_ERPDAT.ERP.bindescr(BinArray);
        end
        rowNum = ERPTab_plotset_pars{9} ;
        gridlayputarraydef = cell(rowNum,columNum);
        count = 0;
        for ii = 1:rowNum
            for jj = 1:columNum
                count = count+1;
                if count<= length(plotArraystr)
                    gridlayputarraydef{ii,jj} = plotArraystr{count};
                end
            end
        end
        if ERPTab_plotset.gridlayoutdef.Value==1 || size(ERPTab_plotset.gridlayputarray,1)~=rowNum || size(ERPTab_plotset.gridlayputarray,2)~=columNum
            ERPTab_plotset.gridlayputarray = gridlayputarraydef;
        end
        [Griddata, checkflag,labelsIndex]= f_tranf_check_import_grid(ERPTab_plotset.gridlayputarray,ERPTab_plotset.pagesel.Value);
        
        if checkflag==1
            if ERPTab_plotset.pagesel.Value==1
                estudioworkingmemory('ERP_ChanArray',labelsIndex);
            else
                estudioworkingmemory('ERP_BinArray',labelsIndex);
            end
        else
            ERPTab_plotset.gridlayputarray = gridlayputarraydef;
        end
        ERPTab_plotset_pars{11} = ERPTab_plotset.gridlayputarray;
        estudioworkingmemory('ERPTab_plotset_pars',ERPTab_plotset_pars);
        %%channel orders
        [eloc, labels, theta, radius, indices] = readlocs(observe_ERPDAT.ERP.chanlocs);
        if  ERPTab_plotset.chanorder_number.Value==1
            ERPTab_plotset.chanorderIndex=1;
            ERPTab_plotset.chanorder{1,1} = 1:length(labels);
            ERPTab_plotset.chanorder{1,2} = labels;
        elseif ERPTab_plotset.chanorder_front.Value==1
            ERPTab_plotset.chanorderIndex = 2;
            chanindexnew = f_estudio_chan_frontback_left_right(observe_ERPDAT.ERP.chanlocs);
            if ~isempty(chanindexnew)
                ERPTab_plotset.chanorder{1,1} = 1:numel(chanindexnew);
                ERPTab_plotset.chanorder{1,2} = labels(chanindexnew);
            else
                ERPTab_plotset.chanorder{1,1} = 1:length(labels);
                ERPTab_plotset.chanorder{1,2} = labels;
            end
        elseif ERPTab_plotset.chanorder_custom.Value==1
            if isempty(ERPTab_plotset.chanorder{1,1})
                ERPTab_plotset.chanorderIndex = 3;
                MessageViewer= char(strcat('Plot Setting > Apply:There were no custom-defined chan orders and we therefore used the default orders'));
                erpworkingmemory('f_ERP_proces_messg',MessageViewer);
                observe_ERPDAT.Process_messg=4;
                ERPTab_plotset.chanorder_number.Value=1;
                ERPTab_plotset.chanorder_front.Value=0;
                ERPTab_plotset.chanorder_custom.Value=0;
                ERPTab_plotset.chanorder_custom_exp.Enable = 'off';
                ERPTab_plotset.chanorder_custom_imp.Enable = 'off';
                ERPTab_plotset.chanorderIndex=1;
                ERPTab_plotset.chanorder{1,1} = 1:length(labels);
                ERPTab_plotset.chanorder{1,2} = labels;
            end
        end
        estudioworkingmemory('ERP_chanorders',{ERPTab_plotset.chanorderIndex,ERPTab_plotset.chanorder});
        observe_ERPDAT.Count_currentERP=1;
    end



%%-------------------------------------------------------------------------
    function Count_currentERPChanged(~,~)
        if observe_ERPDAT.Count_currentERP~=3
            return;
        end
         ViewerFlag=erpworkingmemory('ViewerFlag');
        if isempty(observe_ERPDAT.ALLERP)|| isempty(observe_ERPDAT.ERP) || ViewerFlag==1
            enbaleflag = 'off';
        else
            enbaleflag = 'on';
        end
        ERPTab_plotset.timet_auto.Enable =enbaleflag;
        ERPTab_plotset.timet_low.Enable =enbaleflag;
        ERPTab_plotset.timet_high.Enable =enbaleflag;
        ERPTab_plotset.timet_step.Enable =enbaleflag;
        ERPTab_plotset.yscale_auto.Enable =enbaleflag;
        ERPTab_plotset.yscale_change.Enable =enbaleflag;
        ERPTab_plotset.min_vspacing.Enable =enbaleflag;
        ERPTab_plotset.fill_screen.Enable =enbaleflag;
        ERPTab_plotset.columns.Enable =enbaleflag;
        ERPTab_plotset.positive_up.Enable =enbaleflag;
        ERPTab_plotset.negative_up.Enable =enbaleflag;
        ERPTab_plotset.pagesel.Enable =enbaleflag;
        ERPTab_plotset.chanorder_number.Enable =enbaleflag;
        ERPTab_plotset.chanorder_front.Enable =enbaleflag;
        ERPTab_plotset.chanorder_custom.Enable =enbaleflag;
        ERPTab_plotset.chanorder_custom_exp.Enable =enbaleflag;
        ERPTab_plotset.chanorder_custom_imp.Enable =enbaleflag;
        ERPTab_plotset.plot_reset.Enable =enbaleflag;
        ERPTab_plotset.plot_apply.Enable =enbaleflag;
        ERPTab_plotset.gridlayoutdef.Enable =enbaleflag;
        ERPTab_plotset.gridlayout_custom.Enable =enbaleflag;
        ERPTab_plotset.gridlayout_export.Enable =enbaleflag;
        ERPTab_plotset.gridlayout_import.Enable =enbaleflag;
        ERPTab_plotset.rowNum_set.Enable =enbaleflag;
        ERPTab_plotset.columns.Enable =enbaleflag;
        if isempty(observe_ERPDAT.ALLERP)|| isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP =4;
            return;
        end
        if ERPTab_plotset.timet_auto.Value==1
            ERPTab_plotset.timet_low.Enable ='off';
            ERPTab_plotset.timet_high.Enable ='off';
            ERPTab_plotset.timet_step.Enable ='off';
        end
        if ERPTab_plotset.yscale_auto.Value ==1
            ERPTab_plotset.yscale_change.Enable ='off';
            ERPTab_plotset.min_vspacing.Enable ='off';
        end
        if ERPTab_plotset.chanorder_number.Value==1 ||  ERPTab_plotset.chanorder_front.Value==1
            ERPTab_plotset.chanorder_custom_exp.Enable ='off';
            ERPTab_plotset.chanorder_custom_imp.Enable ='off';
        end
        %
        %%time range
        if ERPTab_plotset.timet_auto.Value == 1
            ERPTab_plotset.timet_low.String = num2str(observe_ERPDAT.ERP.times(1));
            ERPTab_plotset.timet_low.Enable = 'off';
            ERPTab_plotset.timet_high.String = num2str(observe_ERPDAT.ERP.times(end));
            ERPTab_plotset.timet_high.Enable =  'off';
            [def xstep]= default_time_ticks_studio(observe_ERPDAT.ERP, [observe_ERPDAT.ERP.times(1),observe_ERPDAT.ERP.times(end)]);
            ERPTab_plotset.timet_step.String = num2str(xstep);
        end
        timeStart = str2num(ERPTab_plotset.timet_low.String);
        if isempty(timeStart) || numel(timeStart)~=1 || timeStart>observe_ERPDAT.ERP.times(end) %%|| timeStart<observe_ERPDAT.ERP.times(1)
            timeStart = observe_ERPDAT.ERP.times(1);
            ERPTab_plotset.timet_low.String = num2str(observe_ERPDAT.ERP.times(1));
        end
        timEnd = str2num(ERPTab_plotset.timet_high.String);
        
        if isempty(timEnd) || numel(timEnd)~=1 || timEnd<observe_ERPDAT.ERP.times(1) %%|| timEnd> observe_ERPDAT.ERP.times(end)
            timEnd = observe_ERPDAT.ERP.times(end);
            ERPTab_plotset.timet_high.String = num2str(observe_ERPDAT.ERP.times(end));
        end
        
        if timeStart>timEnd
            ERPTab_plotset.timet_low.String = num2str(observe_ERPDAT.ERP.times(1));
            ERPTab_plotset.timet_high.String = num2str(observe_ERPDAT.ERP.times(end));
            timeStart = observe_ERPDAT.ERP.times(1);
            timEnd = observe_ERPDAT.ERP.times(end);
        end
        ERPTab_plotset_pars{1} = [timeStart,timEnd];
        xtickstep = str2num(ERPTab_plotset.timet_step.String);
        if isempty(xtickstep) || numel(xtickstep)~=1 || xtickstep> floor((timEnd-timeStart)/2)
            [def xtickstep]= default_time_ticks_studio(observe_ERPDAT.ERP, [timEnd,timeStart]);
            ERPTab_plotset.timet_step.String = num2str(xtickstep);
        end
        ERPTab_plotset_pars{2} = xtickstep;
        %
        %%Y scale
        if ERPTab_plotset.positive_up.Value==1
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
        if ERPTab_plotset.yscale_auto.Value ==1
            ERPTab_plotset.yscale_change.String = num2str(YScaledef);
            ERPTab_plotset.min_vspacing.String = 1.5;
        end
        Yscales = str2num(ERPTab_plotset.yscale_change.String);
        if isempty(Yscales) || numel(Yscales)~=1 || any(Yscales(:)<=0.1)
            ERPTab_plotset.yscale_change.String = num2str(YScaledef);
            Yscales= YScaledef;
        end
        ERPTab_plotset_pars{3} = Yscales;
        
        min_vspvalue = str2num(ERPTab_plotset.min_vspacing.String);
        if isempty(min_vspvalue) || numel(min_vspvalue)~=1 || any(min_vspvalue(:)<=0)
            ERPTab_plotset.min_vspacing.String = '1.5';
            min_vspvalue = 1.5;
        end
        ERPTab_plotset_pars{4} = min_vspvalue;
        
        %%fill screen?
        ERPTab_plotset_pars{5} = ERPTab_plotset.fill_screen.Value;
        
        ChanArray=estudioworkingmemory('ERP_ChanArray');
        if isempty(ChanArray) || any(ChanArray<=0) || any(ChanArray>observe_ERPDAT.ERP.nchan)
            ChanArray = [1:observe_ERPDAT.ERP.nchan];
            estudioworkingmemory('ERP_ChanArray',ChanArray);
        end
        BinArray= estudioworkingmemory('ERP_BinArray');
        if isempty(BinArray) || any(BinArray<=0) || any(BinArray>observe_ERPDAT.ERP.nbin)
            BinArray = [1:observe_ERPDAT.ERP.nbin];
            estudioworkingmemory('ERP_BinArray',BinArray);
        end
        if ERPTab_plotset.pagesel.Value==1
            nplot = numel(ChanArray);
            plotarray = ChanArray;
            [~, labelsdef, ~, ~, ~] = readlocs(observe_ERPDAT.ERP.chanlocs);
        else
            nplot = numel(BinArray);
            plotarray = BinArray;
            labelsdef =observe_ERPDAT.ERP.bindescr;
        end
        gridlayputarraydef = cell(ERPTab_plotset.rowNum_set.Value,ERPTab_plotset.columns.Value);
        count = 0;
        for ii = 1:ERPTab_plotset.rowNum_set.Value
            for jj = 1:ERPTab_plotset.columns.Value
                count = count+1;
                if count>nplot
                    break;
                end
                gridlayputarraydef{ii,jj} = labelsdef{plotarray(count)};
            end
        end
        
        if ERPTab_plotset.gridlayoutdef.Value ==1
            EnableFlag = 'off';
            rowNum = ceil(sqrt(nplot));
            ERPTab_plotset.rowNum_set.Value=rowNum;
            ERPTab_plotset.columns.Value =ceil(nplot/rowNum);
            
            ERPTab_plotset.gridlayputarray = gridlayputarraydef;
        else
            EnableFlag = 'on';
        end
        ERPTab_plotset.gridlayout_export.Enable =EnableFlag;
        ERPTab_plotset.gridlayout_import.Enable =EnableFlag;
        ERPTab_plotset.rowNum_set.Enable =EnableFlag;
        ERPTab_plotset.columns.Enable =EnableFlag;
        
        %%Number of columns
        columNum = round(ERPTab_plotset.columns.Value);
        if isempty(columNum) || numel(columNum)~=1 || any(columNum<=0)
            columNum =1;
            ERPTab_plotset.columns.Value = 1;
        end
        ERPTab_plotset_pars{6} =columNum;
        %%polarity (positive up?)
        ERPTab_plotset_pars{7} =ERPTab_plotset.positive_up.Value;
        
        %%overlay?
        if ERPTab_plotset.pagesel.Value==1
            ERPTab_plotset_pars{8} =0;
        else
            ERPTab_plotset_pars{8} =  1;
        end
        ERPTab_plotset_pars{9}  = ERPTab_plotset.rowNum_set.Value;%%number of rows
        ERPTab_plotset_pars{10} = ERPTab_plotset.gridlayoutdef.Value ;%%default grid layout?
        ERPTab_plotset_pars{11} = ERPTab_plotset.gridlayputarray;
        estudioworkingmemory('ERPTab_plotset_pars',ERPTab_plotset_pars);
        observe_ERPDAT.Count_currentERP=4;
    end


    function erp_two_panels_change(~,~)
        if  isempty(observe_ERPDAT.ALLERP)|| isempty(observe_ERPDAT.ERP)
            return;
        end
        
        ChangeFlag =  estudioworkingmemory('ERPTab_plotset');
        if ChangeFlag~=1
            return;
        end
        plot_setting_apply();
        estudioworkingmemory('ERPTab_plotset',0);
        ERPTab_plotset.plot_apply.BackgroundColor =  [ 1 1 1];
        ERPTab_plotset.plot_apply.ForegroundColor = [0 0 0];
        ERP_plotset_box.TitleColor= [0.0500    0.2500    0.5000];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_plotset.plot_reset.BackgroundColor =  [1 1 1];
        ERPTab_plotset.plot_reset.ForegroundColor = [0 0 0];
    end


%%--------------press return to execute "Apply"----------------------------
    function erp_plotsetting_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('ERPTab_plotset');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            plot_setting_apply();
            estudioworkingmemory('ERPTab_plotset',0);
            ERPTab_plotset.plot_apply.BackgroundColor =  [ 1 1 1];
            ERPTab_plotset.plot_apply.ForegroundColor = [0 0 0];
            ERP_plotset_box.TitleColor= [0.0500    0.2500    0.5000];%% the default is [0.0500    0.2500    0.5000]
            ERPTab_plotset.plot_reset.BackgroundColor =  [1 1 1];
            ERPTab_plotset.plot_reset.ForegroundColor = [0 0 0];
        else
            return;
        end
    end


%%-----------------------check out the imported lay out--------------------
    function [Griddata, checkflag,labelsIndex]= f_tranf_check_import_grid(DataInput,overlapindex)
        checkflag = 0;
        Griddata = cell(size(DataInput));
        if overlapindex==1
            [~, labelsdef, ~, ~, ~] = readlocs(observe_ERPDAT.ERP.chanlocs);
        else
            labelsdef =observe_ERPDAT.ERP.bindescr;
        end
        count = 0;
        labelsIndex = [];
        for ii = 1:size(DataInput,1)
            for jj = 1:size(DataInput,2)
                if ~ischar(DataInput{ii,jj}) || strcmpi(DataInput{ii,jj},'none')  || isempty(DataInput{ii,jj})
                else
                    [C,IA] = ismember_bc2(DataInput{ii,jj},labelsdef);
                    if IA~=0
                        Griddata{ii,jj} =   labelsdef{IA};
                        checkflag =1;
                        count = count+1;
                        labelsIndex(count) = IA;
                    else
                        if overlapindex==1
                            disp([DataInput{ii,jj},32,'didnot match with any channel labels']);
                        else
                            disp([DataInput{ii,jj},32,'didnot match with any bin labels']);
                        end
                    end
                end
            end
        end
    end

end