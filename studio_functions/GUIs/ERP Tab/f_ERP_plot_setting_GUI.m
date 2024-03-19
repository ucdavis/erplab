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
addlistener(observe_ERPDAT,'Reset_erp_panel_change',@Reset_erp_panel_change);

ERPTab_plotset = struct();
[version reldate,ColorB_def,ColorF_def,errorColorF_def,~] = geterplabstudiodef;
%-----------------------------Name the title----------------------------------------------
if nargin == 0
    fig = figure(); % Parent figure
    ERP_plotset_box = uiextras.BoxPanel('Parent', fig, 'Title', 'Plot Settings', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    ERP_plotset_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Plot Settings', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    ERP_plotset_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Plot Settings', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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
        uicontrol('Style','text','Parent', ERPTab_plotset.plotop,'String','Time Axis:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def); % 1B
        %%time range
        ERPTab_plotset.timerange = uiextras.HBox('Parent',ERPTab_plotset.plotop,'Spacing',1,'BackgroundColor',ColorB_def);
        ERPTab_plotset.timet_auto = uicontrol('Style','checkbox','Parent', ERPTab_plotset.timerange,'String','Auto',...
            'callback',@timet_auto,'Value',1,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off'); % 2B
        ERPTab_plotset.timet_auto.KeyPressFcn=  @erp_plotsetting_presskey;
        uicontrol('Style','text','Parent', ERPTab_plotset.timerange,'String','Range','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        ERPTab_plotset.timet_low = uicontrol('Style', 'edit','Parent',ERPTab_plotset.timerange,'BackgroundColor',[1 1 1],...
            'String','','callback',@low_ticks_change,'Enable','off','FontSize',FonsizeDefault,'Enable','off');
        ERPTab_plotset.timet_low.KeyPressFcn=  @erp_plotsetting_presskey;
        uicontrol('Style','text','Parent', ERPTab_plotset.timerange,'String','to','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        ERPTab_plotset.timet_high = uicontrol('Style', 'edit','Parent',ERPTab_plotset.timerange,'String','',...
            'callback',@high_ticks_change,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
        ERPTab_plotset.timet_high.KeyPressFcn=  @erp_plotsetting_presskey;
        uicontrol('Style','text','Parent', ERPTab_plotset.timerange,'String','ms','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(ERPTab_plotset.timerange, 'Sizes', [50 50 50 30 50 20]);
        %%time ticks
        ERPTab_plotset.timeticks = uiextras.HBox('Parent',ERPTab_plotset.plotop,'Spacing',1,'BackgroundColor',ColorB_def);
        ERPTab_plotset.timetick_auto = uicontrol('Style','checkbox','Parent', ERPTab_plotset.timeticks,'String','Auto',...
            'callback',@timetick_auto,'Value',1,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off'); % 2B
        ERPTab_plotset.timetick_auto.KeyPressFcn=  @erp_plotsetting_presskey;
        uicontrol('Style','text','Parent', ERPTab_plotset.timeticks,'String','Time ticks, every','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        ERPTab_plotset.timet_step = uicontrol('Style', 'edit','Parent',ERPTab_plotset.timeticks,'String','',...
            'callback',@ticks_step_change,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
        ERPTab_plotset.timet_step.KeyPressFcn=  @erp_plotsetting_presskey;
        uicontrol('Style','text','Parent', ERPTab_plotset.timeticks,'String','ms','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(ERPTab_plotset.timeticks, 'Sizes', [50 100 80 20]);
        
        %%amplitude scale
        uicontrol('Style','text','Parent', ERPTab_plotset.plotop,'String','Amplitude Axis:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        ERPTab_plotset.yscale = uiextras.HBox('Parent',ERPTab_plotset.plotop,'Spacing',1,'BackgroundColor',ColorB_def);
        ERPTab_plotset.yscale_auto = uicontrol('Style','checkbox','Parent',ERPTab_plotset.yscale,'String','Auto',...
            'callback',@yscale_auto,'Value',1,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off');
        ERPTab_plotset.yscale_auto.KeyPressFcn=  @erp_plotsetting_presskey;
        uicontrol('Style','text','Parent',ERPTab_plotset.yscale,'String','Scale','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        ERPTab_plotset.yscale_low = uicontrol('Style', 'edit','Parent',ERPTab_plotset.yscale,'BackgroundColor',[1 1 1],...
            'String','','callback',@yscale_low,'Enable','off','FontSize',FonsizeDefault,'Enable','off');
        ERPTab_plotset.yscale_low.KeyPressFcn=  @erp_plotsetting_presskey;
        uicontrol('Style','text','Parent', ERPTab_plotset.yscale,'String','to','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        ERPTab_plotset.yscale_high = uicontrol('Style', 'edit','Parent',ERPTab_plotset.yscale,'String','',...
            'callback',@yscale_high,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
        ERPTab_plotset.yscale_high.KeyPressFcn=  @erp_plotsetting_presskey;
        uicontrol('Style','text','Parent', ERPTab_plotset.yscale,'String','uv','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(ERPTab_plotset.yscale, 'Sizes', [50 50 50 30 50 20]);
        
        %%y ticks
        ERPTab_plotset.yscaleticks = uiextras.HBox('Parent',ERPTab_plotset.plotop,'Spacing',1,'BackgroundColor',ColorB_def);
        ERPTab_plotset.ytick_auto = uicontrol('Style','checkbox','Parent', ERPTab_plotset.yscaleticks,'String','Auto',...
            'callback',@ytick_auto,'Value',1,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off'); % 2B
        ERPTab_plotset.ytick_auto.KeyPressFcn=  @erp_plotsetting_presskey;
        uicontrol('Style','text','Parent', ERPTab_plotset.yscaleticks,'String','Amp. ticks, every','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        ERPTab_plotset.yscale_step = uicontrol('Style', 'edit','Parent',ERPTab_plotset.yscaleticks,'String','',...
            'callback',@yscale_step,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
        ERPTab_plotset.yscale_step.KeyPressFcn=  @erp_plotsetting_presskey;
        uicontrol('Style','text','Parent', ERPTab_plotset.yscaleticks,'String','uv','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(ERPTab_plotset.yscaleticks, 'Sizes', [50 100 80 20]);
        
        
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
        
        
        %%standard error for each ERP wave
        ERPTab_plotset.SEM_title = uiextras.HBox('Parent', ERPTab_plotset.plotop,'BackgroundColor',ColorB_def);
        ERPTab_plotset.show_SEM = uicontrol('Style','checkbox','Parent', ERPTab_plotset.SEM_title ,'String','Show standard error',...
            'callback',@showSEM,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Value',0,'Enable','off'); %
        ERPTab_plotset.show_SEM.KeyPressFcn = @erp_plotsetting_presskey;
        SMEString = {'0','1','2','3','4','5','6','7','8','9','10'};
        ERPTab_plotset.SEM_custom = uicontrol('Style','popupmenu','Parent', ERPTab_plotset.SEM_title ,'String',SMEString,...
            'callback',@SEMerror,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Value',2); %
        ERPTab_plotset.SEM_custom.KeyPressFcn = @erp_plotsetting_presskey;
        set(ERPTab_plotset.SEM_title,'Sizes',[160 80]);
        
        ERPTab_plotset.SEMtrans_title = uiextras.HBox('Parent', ERPTab_plotset.plotop,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent', ERPTab_plotset.SEMtrans_title ,'String','transparency',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'HorizontalAlignment','right'); %
        SMEtransString = {'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1'};
        ERPTab_plotset.SEMtrans_custom = uicontrol('Style','popupmenu','Parent', ERPTab_plotset.SEMtrans_title ,'String',SMEtransString,...
            'callback',@SEMtrans,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Value',3); %
        ERPTab_plotset.SEMtrans_custom.KeyPressFcn = @erp_plotsetting_presskey;
        set(ERPTab_plotset.SEMtrans_title,'Sizes',[160 80]);
        ERPTab_plotset.SEM_custom.Enable = 'off';
        ERPTab_plotset.SEMtrans_custom.Enable = 'off';
        ERPTab_plotset.show_SEM.Enable = 'off';
        
        %%Grid layout
        ERPTab_plotset.gridlayout_title = uiextras.HBox('Parent',ERPTab_plotset.plotop,'Spacing',1,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent', ERPTab_plotset.gridlayout_title,'String','Grid Layout:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 1E
        
        ERPTab_plotset.gridlayout_title2 = uiextras.HBox('Parent',ERPTab_plotset.plotop,'Spacing',1,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def);
        ERPTab_plotset.gridlayoutdef = uicontrol('Style','radiobutton','Parent', ERPTab_plotset.gridlayout_title2,...
            'callback',@gridlayoutdef,'String','Default','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Value',1,'Enable','off'); % 1E
        ERPTab_plotset.gridlayoutdef.KeyPressFcn=  @erp_plotsetting_presskey;
        ERPTab_plotset.chanorder_front = uicontrol('Parent',ERPTab_plotset.gridlayout_title2, 'Style', 'radiobutton', 'String', 'Simple 10/20 system order',...
            'Callback', @chanorder_front,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off','Value',0);
        ERPTab_plotset.chanorder_front.KeyPressFcn=  @erp_plotsetting_presskey;
        set(ERPTab_plotset.gridlayout_title2,'Sizes',[70 -1]);
        
        ERPTab_plotset.gridlayout_title3 = uiextras.HBox('Parent',ERPTab_plotset.plotop,'Spacing',1,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def);
        ERPTab_plotset.gridlayout_custom = uicontrol('Style','radiobutton','Parent', ERPTab_plotset.gridlayout_title3,...
            'callback',@gridlayout_custom,'String','Custom','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Value',0,'Enable','off'); % 1E
        ERPTab_plotset.gridlayout_custom.KeyPressFcn=  @erp_plotsetting_presskey;
        ERPTab_plotset.gridlayout_export = uicontrol('Style','pushbutton','Parent', ERPTab_plotset.gridlayout_title3,...
            'callback',@gridlayout_export,'String','Export','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off'); % 1E
        ERPTab_plotset.gridlayout_import = uicontrol('Style','pushbutton','Parent', ERPTab_plotset.gridlayout_title3,...
            'callback',@gridlayout_import,'String','Import','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off'); % 1E
        set(ERPTab_plotset.gridlayout_title3,'Sizes',[70 60 60]);
        
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
        
        set(ERPTab_plotset.plotop, 'Sizes', [20 20 20 20 20 20 25 25 20 20 25 20 25 25 30]);
        ERPTab_plotset.chanorderIndex = 1;
        ERPTab_plotset.chanorder{1,1}=[];
        ERPTab_plotset.chanorder{1,2} = '';
        estudioworkingmemory('ERP_chanorders',{ERPTab_plotset.chanorderIndex,ERPTab_plotset.chanorder});
        estudioworkingmemory('ERPTab_plotset_pars',[]);
        estudioworkingmemory('ERPTab_plotset',0);
        ERPTab_plotset.timet_auto_reset = 1;
        ERPTab_plotset.timeticks_auto_reset = 1;
        ERPTab_plotset.gridlayputarray = [];
        ERPTab_plotset.paras{1} = ERPTab_plotset.timet_auto.Value;
        ERPTab_plotset.paras{2} = ERPTab_plotset.timetick_auto.Value;
        ERPTab_plotset.paras{3} = ERPTab_plotset.yscale_auto.Value;
        ERPTab_plotset.paras{4} = ERPTab_plotset.ytick_auto.Value;
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
            ERPTab_plotset.timet_low.String = num2str(observe_ERPDAT.ERP.times(1));
            ERPTab_plotset.timet_high.String = num2str(observe_ERPDAT.ERP.times(end));
        else
            ERPTab_plotset.timet_low.Enable = 'on';
            ERPTab_plotset.timet_high.Enable = 'on';
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
            msgboxText =  ['Plot Settings> Time Axis- Input of low edge must be a single numeric'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
        if any(xtixlk_max<=xtixlk_min)
            src.String = num2str(observe_ERPDAT.ERP.times(1));
            msgboxText =  ['Plot Settings> Time Axis- Low edge must be  smaller than',32,num2str(xtixlk_max(1))];
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
            msgboxText =  ['Plot Settings> Amplitude Axis- Input of ticks edge must be a single numeric'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        if any(xtixlk_max < xtixlk_min)
            src.String =  num2str(observe_ERPDAT.ERP.times(end));
            msgboxText =  ['Plot Settings> Time Axis- high edge must be higher than',32,num2str(xtixlk_min),'ms'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
    end


%%---------------------------time ticks automatically----------------------
    function timetick_auto(Source,~)
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
        if ERPTab_plotset.timetick_auto.Value==1
            timeStart = str2num(ERPTab_plotset.timet_low.String);
            if isempty(timeStart) || numel(timeStart)~=1 || timeStart>=observe_ERPDAT.ERP.times(end) %%|| timeStart<observe_ERPDAT.ERP.times(1)
                timeStart = observe_ERPDAT.ERP.times(1);
                ERPTab_plotset.timet_low.String = num2str(observe_ERPDAT.ERP.times(1));
                msgboxText =  ['Plot Settings> Time Axis- Time ticks>Auto: left edge of time range must be a single number and smaller than ',32,num2str(observe_ERPDAT.ERP.times(end)),'ms'];
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
            end
            timEnd = str2num(ERPTab_plotset.timet_high.String);
            if isempty(timEnd) || numel(timEnd)~=1 || timEnd<observe_ERPDAT.ERP.times(1) %%|| timEnd> observe_ERPDAT.ERP.times(end)
                timEnd = observe_ERPDAT.ERP.times(end);
                ERPTab_plotset.timet_high.String = num2str(observe_ERPDAT.ERP.times(end));
                msgboxText =  ['Plot Settings> Time Axis- Time ticks>Auto: right edge of time range must be a single number and larger than ',32,num2str(observe_ERPDAT.ERP.times(1)),'ms'];
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
            end
            if timeStart>timEnd
                ERPTab_plotset.timet_low.String = num2str(observe_ERPDAT.ERP.times(1));
                ERPTab_plotset.timet_high.String = num2str(observe_ERPDAT.ERP.times(end));
                timeStart = observe_ERPDAT.ERP.times(1);
                timEnd = observe_ERPDAT.ERP.times(end);
                ERPTab_plotset.timet_high.String = num2str(observe_ERPDAT.ERP.times(end));
                msgboxText =  ['Plot Settings> Time Axis- Time ticks>Auto: left edge of time range must be smaller than right one'];
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
            end
            [def xstep]= default_time_ticks_studio(observe_ERPDAT.ERP, [timeStart,timEnd]);
            ERPTab_plotset.timet_step.String = num2str(xstep);
            ERPTab_plotset.timet_step.Enable = 'off';
        else
            ERPTab_plotset.timet_step.Enable = 'on';
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
            msgboxText =  ['Plot Settings> Time Axis - The input of Step for time ticks must be a single positive value'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
    end

%%---------------------------------Auto Amplitude Axis---------------------------------*
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
        if ERPTab_plotset.yscale_auto.Value ==1
            BinArray= estudioworkingmemory('ERP_BinArray');
            BinNum = observe_ERPDAT.ERP.nbin;
            if isempty(BinArray) || any(BinArray(:)<=0) || any(BinArray(:)>BinNum)
                BinArray = [1:BinNum];
            end
            ChanArray=estudioworkingmemory('ERP_ChanArray');
            if isempty(ChanArray) || any(ChanArray<=0) || any(ChanArray>observe_ERPDAT.ERP.nchan)
                ChanArray = [1:observe_ERPDAT.ERP.nchan];
                estudioworkingmemory('ERP_ChanArray',ChanArray);
            end
            ERP1 = observe_ERPDAT.ERP;
            ERP1.bindata = ERP1.bindata(ChanArray,:,:);
            [def, minydef, maxydef] = default_amp_ticks(ERP1, BinArray);
            minydef = floor(minydef);
            maxydef = ceil(maxydef);
            ERPTab_plotset.yscale_low.Enable = 'off';
            ERPTab_plotset.yscale_high.Enable = 'off';
            ERPTab_plotset.yscale_low.String = num2str(minydef);
            ERPTab_plotset.yscale_high.String = num2str(maxydef);
        else
            ERPTab_plotset.yscale_low.Enable = 'on';
            ERPTab_plotset.yscale_high.Enable = 'on';
        end
    end


%%------------------------left edge of y scale-----------------------------
    function yscale_low(~,~)
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
        BinArray= estudioworkingmemory('ERP_BinArray');
        BinNum = observe_ERPDAT.ERP.nbin;
        if isempty(BinArray) || any(BinArray(:)<=0) || any(BinArray(:)>BinNum)
            BinArray = [1:BinNum];
        end
        ChanArray=estudioworkingmemory('ERP_ChanArray');
        if isempty(ChanArray) || any(ChanArray<=0) || any(ChanArray>observe_ERPDAT.ERP.nchan)
            ChanArray = [1:observe_ERPDAT.ERP.nchan];
            estudioworkingmemory('ERP_ChanArray',ChanArray);
        end
        ERP1 = observe_ERPDAT.ERP;
        ERP1.bindata = ERP1.bindata(ChanArray,:,:);
        
        [def, minydef, maxydef] = default_amp_ticks(ERP1, BinArray);
        minydef = floor(minydef);
        maxydef = ceil(maxydef);
        Yscales_low = str2num(ERPTab_plotset.yscale_low.String);
        Yscales_high = str2num(ERPTab_plotset.yscale_high.String);
        
        if isempty(Yscales_low) || numel(Yscales_low)~=1
            ERPTab_plotset.yscale_low.String = num2str(minydef);
            Yscales_low= minydef;
            erpworkingmemory('f_ERP_proces_messg','Plot Settings> Amplitude Axis: You did set left edge of amplitude scale to be a single number and we used the default one ');
            observe_ERPDAT.Process_messg =4;
        end
        if any(Yscales_high<=Yscales_low)
            ERPTab_plotset.yscale_low.String = num2str(minydef);
            ERPTab_plotset.yscale_high.String = num2str(maxydef);
            erpworkingmemory('f_ERP_proces_messg','Plot Settings> Amplitude Axis: Left edge of amplitude scale should be smaller than the right one and we used the default ones ');
            observe_ERPDAT.Process_messg =4;
        end
        
    end


%%-------------------right edge of y scale---------------------------------
    function yscale_high(~,~)
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
        BinArray= estudioworkingmemory('ERP_BinArray');
        BinNum = observe_ERPDAT.ERP.nbin;
        if isempty(BinArray) || any(BinArray(:)<=0) || any(BinArray(:)>BinNum)
            BinArray = [1:BinNum];
        end
        ChanArray=estudioworkingmemory('ERP_ChanArray');
        if isempty(ChanArray) || any(ChanArray<=0) || any(ChanArray>observe_ERPDAT.ERP.nchan)
            ChanArray = [1:observe_ERPDAT.ERP.nchan];
            estudioworkingmemory('ERP_ChanArray',ChanArray);
        end
        ERP1 = observe_ERPDAT.ERP;
        ERP1.bindata = ERP1.bindata(ChanArray,:,:);
        
        [def, minydef, maxydef] = default_amp_ticks(ERP1, BinArray);
        minydef = floor(minydef);
        maxydef = ceil(maxydef);
        Yscales_low = str2num(ERPTab_plotset.yscale_low.String);
        Yscales_high = str2num(ERPTab_plotset.yscale_high.String);
        
        if isempty(Yscales_high) || numel(Yscales_high)~=1
            ERPTab_plotset.yscale_high.String = num2str(maxydef);
            Yscales_high= maxydef;
            erpworkingmemory('f_ERP_proces_messg','Plot Settings> Amplitude Axis: You did set right edge of amplitude scale to be a single number and we used the default one ');
            observe_ERPDAT.Process_messg =4;
        end
        if any(Yscales_high<=Yscales_low)
            ERPTab_plotset.yscale_low.String = num2str(minydef);
            ERPTab_plotset.yscale_high.String = num2str(maxydef);
            erpworkingmemory('f_ERP_proces_messg','Plot Settings> Amplitude Axis: Left edge of amplitude scale should be smaller than the right one and we used the default ones ');
            observe_ERPDAT.Process_messg =4;
        end
    end

%%------------------y ticks automatically----------------------------------
    function ytick_auto(Source,~)
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
        BinArray= estudioworkingmemory('ERP_BinArray');
        BinNum = observe_ERPDAT.ERP.nbin;
        if isempty(BinArray) || any(BinArray(:)<=0) || any(BinArray(:)>BinNum)
            BinArray = [1:BinNum];
        end
        ChanArray=estudioworkingmemory('ERP_ChanArray');
        if isempty(ChanArray) || any(ChanArray<=0) || any(ChanArray>observe_ERPDAT.ERP.nchan)
            ChanArray = [1:observe_ERPDAT.ERP.nchan];
            estudioworkingmemory('ERP_ChanArray',ChanArray);
        end
        ERP1 = observe_ERPDAT.ERP;
        ERP1.bindata = ERP1.bindata(ChanArray,:,:);
        [def, minydef, maxydef] = default_amp_ticks(ERP1, BinArray);
        minydef = floor(minydef);
        maxydef = ceil(maxydef);
        
        Yscales_low = str2num(ERPTab_plotset.yscale_low.String);
        Yscales_high = str2num(ERPTab_plotset.yscale_high.String);
        if isempty(Yscales_low) || numel(Yscales_low)~=1
            ERPTab_plotset.yscale_low.String = num2str(minydef);
            Yscales_low= minydef;
        end
        if isempty(Yscales_high) || numel(Yscales_high)~=1
            Yscales_high= maxydef;
            ERPTab_plotset.yscale_high.String = num2str(maxydef);
        end
        if any(Yscales_high<=Yscales_low)
            Yscales_high= maxydef;
            Yscales_low= minydef;
            ERPTab_plotset.yscale_low.String = num2str(minydef);
            ERPTab_plotset.yscale_high.String = num2str(maxydef);
        end
        if ERPTab_plotset.ytick_auto.Value==1
            defyticks = default_amp_ticks_viewer([Yscales_low,Yscales_high]);
            defyticks = str2num(defyticks);
            if ~isempty(defyticks) && numel(defyticks)>=2
                ERPTab_plotset.yscale_step.String = num2str(min(diff(defyticks)));
            else
                ERPTab_plotset.yscale_step.String = num2str(floor((Yscales_high-Yscales_low)/2));
            end
            ERPTab_plotset.yscale_step.Enable = 'off';
        else
            ERPTab_plotset.yscale_step.Enable = 'on';
        end
        
    end


%%---------------------------------Amplitude Axis change---------------------------------*
    function yscale_step(src, ~ )
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
            src.String = '';
            msgboxText =  ['Plot Settings> Amplitude Axis - Input must be a positive value'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
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
        
        BinArray= estudioworkingmemory('ERP_BinArray');
        BinNum = observe_ERPDAT.ERP.nbin;
        if isempty(BinArray) || any(BinArray(:)<=0) || any(BinArray(:)>BinNum)
            BinArray = [1:BinNum];
        end
        ChanArray=estudioworkingmemory('ERP_ChanArray');
        if isempty(ChanArray) || any(ChanArray<=0) || any(ChanArray>observe_ERPDAT.ERP.nchan)
            ChanArray = [1:observe_ERPDAT.ERP.nchan];
            estudioworkingmemory('ERP_ChanArray',ChanArray);
        end
        
        if ERPTab_plotset.pagesel.Value==1
            nplot = numel(ChanArray);
            if ERPTab_plotset.chanorder_front.Value ==1
                try
                    chanindexnew = f_estudio_chan_frontback_left_right(observe_ERPDAT.ERP.chanlocs(sort(ChanArray)));
                    if ~isempty(chanindexnew)
                        ChanArray1 = sort(ChanArray);
                        ChanArray = ChanArray1(chanindexnew);
                    end
                catch
                end
            end
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
        if ERPTab_plotset.gridlayoutdef.Value ==1  || ERPTab_plotset.chanorder_front.Value ==1
            rowNum = ceil(sqrt(nplot));
            ERPTab_plotset.rowNum_set.Value=rowNum;
            ERPTab_plotset.columns.Value =ceil(nplot/rowNum);
            ERPTab_plotset.gridlayputarray = gridlayputarraydef;
        end
        
    end

    function showSEM(Source,~)
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
        
        if Source.Value ==1
            ERPTab_plotset.SEM_custom.Enable = 'on';
            ERPTab_plotset.SEMtrans_custom.Enable = 'on';
        else
            ERPTab_plotset.SEM_custom.Enable = 'off';
            ERPTab_plotset.SEMtrans_custom.Enable = 'off';
        end
    end


    function SEMerror(~,~)
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


    function SEMtrans(~,~)
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
        
        
        ERPTab_plotset.gridlayoutdef.Value = 0;
        ERPTab_plotset.gridlayout_custom.Value = 0;
        ERPTab_plotset.chanorder_front.Value = 1;
        ERPTab_plotset.gridlayout_export.Enable ='off';
        ERPTab_plotset.gridlayout_import.Enable ='off';
        ERPTab_plotset.rowNum_set.Enable ='off';
        ERPTab_plotset.columns.Enable ='off';
        
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
            labelsdef = labelsdef(ChanArray);
        else
            nplot = numel(BinArray);
            labelsdef =observe_ERPDAT.ERP.bindescr(BinArray);
            plotarray = BinArray;
        end
        rowNum = ceil(sqrt(nplot));
        ERPTab_plotset.rowNum_set.Value=rowNum;
        ERPTab_plotset.columns.Value =ceil(nplot/rowNum);
        gridlayputarray = cell(ERPTab_plotset.rowNum_set.Value,ERPTab_plotset.columns.Value);
        
        if ERPTab_plotset.pagesel.Value==1
            try
                chanlocs = observe_ERPDAT.ERP.chanlocs;
                if isempty(chanlocs(1).X) &&  isempty(chanlocs(1).Y)
                    MessageViewer= char(strcat('Plot Settings > Simple 10/20 system order:please do "chan locations" first in EEGLAB Tool panel.'));
                    erpworkingmemory('f_ERP_proces_messg',MessageViewer);
                    observe_ERPDAT.Process_messg=4;
                end
            catch
                ERPTab_plotset.gridlayoutdef.Value = 1;
                ERPTab_plotset.gridlayout_custom.Value = 0;
                ERPTab_plotset.chanorder_front.Value = 0;
                ERPTab_plotset.gridlayout_export.Enable ='off';
                ERPTab_plotset.gridlayout_import.Enable ='off';
                ERPTab_plotset.rowNum_set.Enable ='off';
                ERPTab_plotset.columns.Enable ='off';
            end
            if ERPTab_plotset.chanorder_front.Value==1
                %%check if the channels belong to 10/20 system
                [eloc, labels, theta, radius, indices] = readlocs( observe_ERPDAT.ERP.chanlocs);
                [Simplabels,simplabelIndex,SamAll] =  Simplelabels(labels);
                count = 0;
                for ii = 1:length(Simplabels)
                    [xpos,ypos]= find(simplabelIndex==ii);
                    if ~isempty(ypos)  && numel(ypos)>= floor(length(observe_ERPDAT.ERP.chanlocs)/2)
                        count = count+1;
                        if count==1
                            msgboxText= char(strcat('We cannot use the "Simple 10/20 system order" with your data because your channel labels do not appear to be standard 10/20 names.'));
                            title      =  'Estudio: Plot Settings > Channel order>Simple 10/20 system order:';
                            errorfound(msgboxText, title);
                            break;
                        end
                    end
                end
                if count==1
                    ERPTab_plotset.gridlayoutdef.Value = 1;
                    ERPTab_plotset.gridlayout_custom.Value = 0;
                    ERPTab_plotset.chanorder_front.Value = 0;
                    ERPTab_plotset.gridlayout_export.Enable ='off';
                    ERPTab_plotset.gridlayout_import.Enable ='off';
                    ERPTab_plotset.rowNum_set.Enable ='off';
                    ERPTab_plotset.columns.Enable ='off';
                else
                    [eloc, labels11, theta, radius, indices] = readlocs(observe_ERPDAT.ERP.chanlocs);
                    ERPTab_plotset.chanorderIndex = 2;
                    chanindexnew = f_estudio_chan_frontback_left_right(observe_ERPDAT.ERP.chanlocs(plotarray));
                    if ~isempty(chanindexnew)
                        labelsdef = labels11(chanindexnew);
                    else
                        labelsdef =  labels11(plotarray);
                    end
                end
            end
        end
        count = 0;
        for ii = 1:ERPTab_plotset.rowNum_set.Value
            for jj = 1:ERPTab_plotset.columns.Value
                count = count+1;
                if count>nplot
                    break;
                end
                gridlayputarray{ii,jj} = labelsdef{count};
            end
        end
        ERPTab_plotset.gridlayputarray = gridlayputarray;
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
        ERPTab_plotset.chanorder_front.Value = 0;
        ERPTab_plotset.gridlayout_export.Enable ='off';
        ERPTab_plotset.gridlayout_import.Enable ='off';
        ERPTab_plotset.rowNum_set.Enable ='off';
        ERPTab_plotset.columns.Enable ='off';
        
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
        ERPTab_plotset.chanorder_front.Value = 0;
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
            if jj==ncols+1
                formatSpec = strcat(formatSpec,'%s');
            else
                formatSpec = strcat(formatSpec,'%s\t',32);
            end
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
            erpworkingmemory('f_ERP_proces_messg',['Plot Settings > Grid Layout > Import:','Cannot import:',filepath,filename]);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        if isempty(DataInput)
            erpworkingmemory('f_ERP_proces_messg','Plot Settings > Grid Layout > Import is invalid');
            observe_ERPDAT.Process_messg =4;
            return;
        end
        overlapindex =1;% ERPTab_plotset.pagesel.Value;
        DataInput = table2cell(DataInput);
        
        [rows,columns] = size(DataInput);
        if columns<=2
            erpworkingmemory('f_ERP_proces_messg','Plot Settings > Grid Layout > Import is invalid and one column is designed besides the first column that is row title');
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
        DataInput = DataInput(:,2:end);
        [Griddata, checkflag ]= f_tranf_check_import_grid(DataInput,overlapindex);
        if checkflag==0
            erpworkingmemory('f_ERP_proces_messg','Plot Settings > Grid Layout > Import is invalid or didnot match with existing labels');
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
        
        erpworkingmemory('f_ERP_proces_messg','Plot Settings>Cancel');
        observe_ERPDAT.Process_messg =1;
        %
        %%------------------------------time range-------------------------
        ERPTab_plotset.timet_auto.Value=ERPTab_plotset.paras{1};
        ERPTab_plotset.timetick_auto.Value=ERPTab_plotset.paras{2};
        
        ERPTab_plotset_pars =  estudioworkingmemory('ERPTab_plotset_pars');
        timelowdef = observe_ERPDAT.ERP.times(1);
        timehighdef= observe_ERPDAT.ERP.times(end);
        [def xtickstepdef]= default_time_ticks_studio(observe_ERPDAT.ERP, [timelowdef,timehighdef]);
        if ERPTab_plotset.timet_auto_reset==1
            Enablerange = 'off';
            timelow = timelowdef;
            timehigh = timehighdef;
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
        end
        if ERPTab_plotset.timetick_auto.Value==1
            xtickstep = xtickstepdef;
            Enablerange1 = 'off';
        else
            try
                xtickstep = ERPTab_plotset_pars{2};
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
        ERPTab_plotset.timet_low.Enable = Enablerange;
        ERPTab_plotset.timet_high.Enable =  Enablerange;
        ERPTab_plotset.timet_step.Enable = Enablerange1;
        ERPTab_plotset.timet_low.String = num2str(timelow);
        ERPTab_plotset.timet_high.String = num2str(timehigh);
        ERPTab_plotset.timet_step.String =  num2str(xtickstep);
        ERPTab_plotset_pars{1} = [timelow,timehigh];
        ERPTab_plotset_pars{2}= xtickstep;
        %
        %%------------------------Amplitude Axis----------------------------------
        
        ERPTab_plotset.yscale_auto.Value = ERPTab_plotset.paras{3};
        ERPTab_plotset.ytick_auto.Value = ERPTab_plotset.paras{4};
        BinArray= estudioworkingmemory('ERP_BinArray');
        if isempty(BinArray) || any(BinArray<=0) || any(BinArray>observe_ERPDAT.ERP.nbin)
            BinArray = [1:observe_ERPDAT.ERP.nbin];
            estudioworkingmemory('ERP_BinArray',BinArray);
        end
        ChanArray=estudioworkingmemory('ERP_ChanArray');
        if isempty(ChanArray) || any(ChanArray<=0) || any(ChanArray>observe_ERPDAT.ERP.nchan)
            ChanArray = [1:observe_ERPDAT.ERP.nchan];
            estudioworkingmemory('ERP_ChanArray',ChanArray);
        end
        ERP1 = observe_ERPDAT.ERP;
        ERP1.bindata = ERP1.bindata(ChanArray,:,:);
        [def, minydef, maxydef] = default_amp_ticks(ERP1, BinArray);
        minydef = floor(minydef);
        maxydef = ceil(maxydef);
        
        try Yscale = ERPTab_plotset_pars{3}; catch Yscale=[]; end
        try Yscales_low = Yscale(1);catch Yscales_low=[];end
        try Yscales_high = Yscale(2);catch Yscales_high=[];end
        if isempty(Yscales_low) || numel(Yscales_low)~=1
            ERPTab_plotset.yscale_low.String = str2num(minydef);
            Yscales_low= minydef;
            erpworkingmemory('f_ERP_proces_messg','Plot Settings> Amplitude Axis: You did set left edge of amplitude scale to be a single number and we used the default one ');
            observe_ERPDAT.Process_messg =4;
        end
        if isempty(Yscales_high) || numel(Yscales_high)~=1
            ERPTab_plotset.yscale_high.String = str2num(maxydef);
            Yscales_high= maxydef;
            
        end
        if any(Yscales_high<=Yscales_low)
            ERPTab_plotset.yscale_low.String = str2num(minydef);
            ERPTab_plotset.yscale_high.String = str2num(maxydef);
            Yscales_high= maxydef;
            Yscales_low= minydef;
        end
        
        if  ERPTab_plotset.yscale_auto.Value==0
            ERPTab_plotset.yscale_low.Enable = 'on';
            ERPTab_plotset.yscale_high.Enable = 'on';
        else
            Yscales_high= maxydef;
            Yscales_low= minydef;
            ERPTab_plotset.yscale_low.Enable = 'off';
            ERPTab_plotset.yscale_high.Enable = 'off';
        end
        ERPTab_plotset.yscale_low.String = num2str(Yscales_low);
        ERPTab_plotset.yscale_high.String = num2str(Yscales_high);
        ERPTab_plotset_pars{3} = [Yscales_low,Yscales_high];
        
        
        if ERPTab_plotset.ytick_auto.Value==1
            Enableflag = 'off';
            defyticks = default_amp_ticks_viewer([Yscales_low,Yscales_high]);
            defyticks = str2num(defyticks);
            if ~isempty(defyticks) && numel(defyticks)>=2
                ERPTab_plotset.yscale_step.String = num2str(min(diff(defyticks)));
            else
                ERPTab_plotset.yscale_step.String = num2str(floor((Yscales_high-Yscales_low)/2));
            end
        else
            Enableflag = 'on';
            yscale= ERPTab_plotset_pars{4};
            ERPTab_plotset.yscale_step.String = num2str(yscale);
        end
        ERPTab_plotset.yscale_step.Enable = Enableflag;
        
        
        %
        %%Number of columns?
        ColumnNum= ERPTab_plotset_pars{5};
        if isempty(ColumnNum) || numel(ColumnNum)~=1 || any(ColumnNum<=0)
            ColumnNum =1;
            ERPTab_plotset_pars{5}=1;
        end
        ERPTab_plotset.columns.Value =ColumnNum; % 2E Plot_column
        ERPTab_plotset.columns.Enable = 'on';
        
        %
        %%polarity?
        positive_up =  ERPTab_plotset_pars{6};
        if isempty(positive_up) ||  numel(positive_up)~=1 || (positive_up~=0&&positive_up~=1)
            positive_up=1;
            ERPTab_plotset_pars{6}=1;
        end
        ERPTab_plotset.positive_up.Value =positive_up;
        ERPTab_plotset.negative_up.Value = ~positive_up;
        %
        %%overlay?
        Bin_chan_overlay=ERPTab_plotset_pars{7};
        if isempty(Bin_chan_overlay) || numel(Bin_chan_overlay)~=1 || (Bin_chan_overlay~=0 && Bin_chan_overlay~=1)
            Bin_chan_overlay=0;
            ERPTab_plotset_pars{7}=0;
        end
        set(ERPTab_plotset.pagesel,'Value',Bin_chan_overlay+1);
        
        %
        %%channel order
        ERP_chanorders=  estudioworkingmemory('ERP_chanorders');
        try
            chanordervalue = ERP_chanorders{1};
        catch
            chanordervalue=1;
        end
        
        try rowNum = ERPTab_plotset_pars{8};catch rowNum=1;ERPTab_plotset_pars{8}=1; end
        ERPTab_plotset.rowNum_set.Value=rowNum;
        
        
        try gridlayoutdef =  ERPTab_plotset_pars{9};catch gridlayoutdef =1; ERPTab_plotset_pars{9}=1;  end
        if isempty(gridlayoutdef) || numel(gridlayoutdef)~=1 || (gridlayoutdef~=0 && gridlayoutdef~=1)
            gridlayoutdef =1; ERPTab_plotset_pars{9}=1;
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
        
        if ERPTab_plotset.pagesel.Value==1
            nplot = numel(ChanArray);
            [~, labelsdef, ~, ~, ~] = readlocs(observe_ERPDAT.ERP.chanlocs);
            plotarray = sort(ChanArray);
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
        
        try gridlayputarray= ERPTab_plotset_pars{10};catch gridlayputarray= gridlayputarraydef ;ERPTab_plotset_pars{10}=gridlayputarraydef; end
        ERPTab_plotset.gridlayputarray=gridlayputarray;
        ERPTab_plotset_pars{10} = ERPTab_plotset.gridlayputarray;
        
        %%-------SEM----------
        try SMEFlag = ERPTab_plotset_pars{11};catch SMEFlag = [0 1 0.2];end
        try show_SEM = SMEFlag(1);catch show_SEM=0; end
        if isempty(show_SEM) || numel(show_SEM)~=1 ||(show_SEM~=0&& show_SEM~=1)
            show_SEM=0;
        end
        ERPTab_plotset.show_SEM.Value = show_SEM;
        if  ERPTab_plotset.show_SEM.Value == 1
            ERPTab_plotset.SEM_custom.Enable = 'on';
            ERPTab_plotset.SEMtrans_custom.Enable = 'on';
        else
            ERPTab_plotset.SEM_custom.Enable = 'off';
            ERPTab_plotset.SEMtrans_custom.Enable = 'off';
        end
        
        try SEM_custom = SMEFlag(2);catch SEM_custom = SMEFlag(2); end
        if isempty(SEM_custom)|| numel(SEM_custom)~=1 || any(SEM_custom<0) || any(SEM_custom>10)
            SEM_custom=1;
        end
        ERPTab_plotset.SEM_custom.Value = SEM_custom+1;
        
        try SEMtrans_custom = SMEFlag(3);catch SEMtrans_custom = SMEFlag(3); end
        if isempty(SEMtrans_custom)|| numel(SEMtrans_custom)~=1 || any(SEMtrans_custom<0) || any(SEMtrans_custom>1)
            SEMtrans_custom=0.2;
        end
        ERPTab_plotset.SEMtrans_custom.Value = SEMtrans_custom*10+1;
        if ERPTab_plotset.show_SEM.Value == 1
            SEM_custom = ERPTab_plotset.SEM_custom.Value-1;
            SEMtrans_custom = (ERPTab_plotset.SEMtrans_custom.Value-1)/10;
            ERPTab_plotset_pars{11} = [1,SEM_custom,SEMtrans_custom];
        else
            ERPTab_plotset_pars{11} = [0,ERPTab_plotset.SEM_custom.Value-1,(ERPTab_plotset.SEMtrans_custom.Value-1)/10];
        end
        
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
        
        erpworkingmemory('f_ERP_proces_messg','Plot Settings>Apply');
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
            MessageViewer= char(['Plot Settings > Apply: Low edge of the time range should be smaller',32,num2str(observe_ERPDAT.ERP.times(end)),32,...
                'we therefore set to be',32,num2str(timeStart)]);
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
        end
        
        timEnd = str2num(ERPTab_plotset.timet_high.String);
        if isempty(timEnd) || numel(timEnd)~=1 || timEnd<=observe_ERPDAT.ERP.times(1)
            timEnd = timEnddef;
            ERPTab_plotset.timet_high.String = num2str(timEnd);
            MessageViewer= char(['Plot Settings > Apply: High edge of the time range should be larger',32,num2str(timeStartdef),32,...
                'we therefore set to be',32,num2str(timEnddef)]);
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
        end
        
        if timeStart>= timEnd
            timEnd = timEnddef;
            timeStart = timeStartdef;
            ERPTab_plotset.timet_low.String = num2str(timeStart);
            ERPTab_plotset.timet_high.String = num2str(timEnd);
            MessageViewer= char(['Plot Settings > Apply: Low edge of the time range should be smaller than the high one and we therefore used the defaults']);
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
        end
        ERPTab_plotset_pars{1} = [timeStart,timEnd];
        
        xtickstep = str2num(ERPTab_plotset.timet_step.String);
        if isempty(xtickstep) || numel(xtickstep)~=1 ||  any(xtickstep<=0)
            xtickstep = xstepdef;
            ERPTab_plotset.timet_step.String = num2str(xtickstep);
            MessageViewer= char(['Plot Settings > Apply: the step of the time ticks should be a positive number that belows',32,num2str(floor((timEnd-timeStart)/2))]);
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
        end
        ERPTab_plotset_pars{2} = xtickstep;
        
        %
        %%Amplitude Axis
        BinArray= estudioworkingmemory('ERP_BinArray');
        if isempty(BinArray) || any(BinArray<=0) || any(BinArray>observe_ERPDAT.ERP.nbin)
            BinArray = [1:observe_ERPDAT.ERP.nbin];
            estudioworkingmemory('ERP_BinArray',BinArray);
        end
        ChanArray=estudioworkingmemory('ERP_ChanArray');
        if isempty(ChanArray) || any(ChanArray<=0) || any(ChanArray>observe_ERPDAT.ERP.nchan)
            ChanArray = [1:observe_ERPDAT.ERP.nchan];
            estudioworkingmemory('ERP_ChanArray',ChanArray);
        end
        ERP1 = observe_ERPDAT.ERP;
        ERP1.bindata = ERP1.bindata(ChanArray,:,:);
        [def, minydef, maxydef] = default_amp_ticks(ERP1, BinArray);
        minydef = floor(minydef);
        maxydef = ceil(maxydef);
        
        Yscales_low = str2num(ERPTab_plotset.yscale_low.String);
        Yscales_high = str2num(ERPTab_plotset.yscale_high.String);
        if isempty(Yscales_low) || numel(Yscales_low)~=1
            ERPTab_plotset.yscale_low.String = str2num(minydef);
            Yscales_low= minydef;
            erpworkingmemory('f_ERP_proces_messg','Plot Settings> Amplitude Axis: You did set left edge of amplitude scale to be a single number and we used the default one ');
            observe_ERPDAT.Process_messg =4;
        end
        if isempty(Yscales_high) || numel(Yscales_high)~=1
            ERPTab_plotset.yscale_high.String = str2num(maxydef);
            Yscales_high= maxydef;
            erpworkingmemory('f_ERP_proces_messg','Plot Settings> Amplitude Axis: You did set right edge of amplitude scale to be a single number and we used the default one ');
            observe_ERPDAT.Process_messg =4;
        end
        if any(Yscales_high<=Yscales_low)
            ERPTab_plotset.yscale_low.String = str2num(minydef);
            ERPTab_plotset.yscale_high.String = str2num(maxydef);
            Yscales_high= maxydef;
            Yscales_low= minydef;
            erpworkingmemory('f_ERP_proces_messg','Plot Settings> Amplitude Axis: Left edge of amplitude scale should be smaller than the right one and we used the default ones ');
            observe_ERPDAT.Process_messg =4;
        end
        ERPTab_plotset_pars{3} = [Yscales_low,Yscales_high];
        ERPTab_plotset_pars{4} = str2num(ERPTab_plotset.yscale_step.String);
        
        %%Number of columns
        columNum = round(ERPTab_plotset.columns.Value);
        if isempty(columNum) || numel(columNum)~=1 || any(columNum<=0)
            columNum =1;
            ERPTab_plotset.columns.String = '1';
            MessageViewer= char(['Plot Settings > Apply: the number of columns should be a positive value']);
            erpworkingmemory('f_ERP_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=4;
        end
        ERPTab_plotset_pars{5} =columNum;
        
        %
        %%polarity (positive up?)
        ERPTab_plotset_pars{6} =ERPTab_plotset.positive_up.Value;
        %
        %%overlay?
        if ERPTab_plotset.pagesel.Value==1
            ERPTab_plotset_pars{7} =0;
        else
            ERPTab_plotset_pars{7} =  1;
        end
        
        ERPTab_plotset_pars{8}  = ERPTab_plotset.rowNum_set.Value;%%number of rows
        if ERPTab_plotset.gridlayoutdef.Value==1
            gridlayoutdef=1;
        elseif ERPTab_plotset.chanorder_front.Value==1
            gridlayoutdef=2;
        else
            gridlayoutdef=3;
        end
        
        ERPTab_plotset_pars{9} = gridlayoutdef;%%default grid layout?
        if ERPTab_plotset.pagesel.Value==1
            [~,plotArraystr] = readlocs(observe_ERPDAT.ERP.chanlocs(ChanArray));
        else
            plotArraystr= observe_ERPDAT.ERP.bindescr{BinArray};
        end
        rowNum = ERPTab_plotset_pars{8} ;
        gridlayputarraydef = cell(rowNum,columNum);
        count = 0;
        for ii = 1:rowNum
            for jj = 1:columNum
                count = count+1;
                if count<= length(plotArraystr)
                    try gridlayputarraydef{ii,jj} = plotArraystr{count};catch end;
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
        
        try
            [eloc, labels, theta, radius, indices] = readlocs(observe_ERPDAT.ERP.chanlocs);
            ERPTab_plotset.chanorderIndex = 2;
            chanindexnew = f_estudio_chan_frontback_left_right(observe_ERPDAT.ERP.chanlocs(sort(ChanArray)));
            if isempty(chanindexnew)
                chanindexnew =   ChanArray;
            else
                ChanArray =  sort(ChanArray);
                chanindexnew = ChanArray(chanindexnew);
            end
        catch
            chanindexnew = ChanArray;
        end
        if ERPTab_plotset.chanorder_front.Value==1
            gridlayputarraydef = cell(rowNum,columNum);
            count = 0;
            for ii = 1:rowNum
                for jj = 1:columNum
                    count = count+1;
                    if count<= length(plotArraystr)
                        if ERPTab_plotset.pagesel.Value==1
                            try
                                gridlayputarraydef{ii,jj} = observe_ERPDAT.ERP.chanlocs(chanindexnew(count)).labels;
                            catch
                                gridlayputarraydef{ii,jj} = ['Chan',32,num2str(chanindexnew(count))];
                            end
                        else
                            try gridlayputarraydef{ii,jj} = observe_ERPDAT.ERP.bindescr{BinArray(count)};catch end;
                        end
                    end
                end
            end
            estudioworkingmemory('ERP_ChanArray',chanindexnew);
            ERPTab_plotset.gridlayputarray=gridlayputarraydef;
        end
        
        ERPTab_plotset_pars{10} = ERPTab_plotset.gridlayputarray;
        SEM_custom = ERPTab_plotset.SEM_custom.Value-1;
        SEMtrans_custom = (ERPTab_plotset.SEMtrans_custom.Value-1)/10;
        if ERPTab_plotset.show_SEM.Value == 1
            ERPTab_plotset.SEM_custom.Enable = 'on';
            ERPTab_plotset.SEMtrans_custom.Enable = 'on';
            SEM_custom = ERPTab_plotset.SEM_custom.Value-1;
            SEMtrans_custom = (ERPTab_plotset.SEMtrans_custom.Value-1)/10;
            ERPTab_plotset_pars{11} = [1,SEM_custom,SEMtrans_custom];
        else
            ERPTab_plotset_pars{11} = [0,SEM_custom,SEMtrans_custom];
        end
        
        estudioworkingmemory('ERPTab_plotset_pars',ERPTab_plotset_pars);%%save the changed paras to memory file
        %%channel orders
        
        ERPTab_plotset.paras{1} = ERPTab_plotset.timet_auto.Value;
        ERPTab_plotset.paras{2} = ERPTab_plotset.timetick_auto.Value;
        ERPTab_plotset.paras{3} = ERPTab_plotset.yscale_auto.Value;
        ERPTab_plotset.paras{4} = ERPTab_plotset.ytick_auto.Value;
        observe_ERPDAT.Count_currentERP=1;
    end



%%-------------------------------------------------------------------------
    function Count_currentERPChanged(~,~)
        if observe_ERPDAT.Count_currentERP~=3
            return;
        end
        ViewerFlag=erpworkingmemory('ViewerFlag');%%when open advanced wave viewer
        if isempty(ViewerFlag) || (ViewerFlag~=0 && ViewerFlag~=1)
            ViewerFlag=0;erpworkingmemory('ViewerFlag',0);
        end
        if isempty(observe_ERPDAT.ALLERP)|| isempty(observe_ERPDAT.ERP) || ViewerFlag==1
            enbaleflag = 'off';
        else
            enbaleflag = 'on';
        end
        ERPTab_plotset.timet_auto.Enable =enbaleflag;
        ERPTab_plotset.timet_low.Enable =enbaleflag;
        ERPTab_plotset.timet_high.Enable =enbaleflag;
        ERPTab_plotset.timetick_auto.Enable =enbaleflag;
        ERPTab_plotset.timet_step.Enable =enbaleflag;
        ERPTab_plotset.yscale_auto.Enable =enbaleflag;
        ERPTab_plotset.yscale_low.Enable =enbaleflag;
        ERPTab_plotset.yscale_high.Enable =enbaleflag;
        ERPTab_plotset.ytick_auto.Enable =enbaleflag;
        ERPTab_plotset.yscale_step.Enable =enbaleflag;
        ERPTab_plotset.columns.Enable =enbaleflag;
        ERPTab_plotset.positive_up.Enable =enbaleflag;
        ERPTab_plotset.negative_up.Enable =enbaleflag;
        ERPTab_plotset.pagesel.Enable =enbaleflag;
        ERPTab_plotset.SEM_custom.Enable = enbaleflag;
        ERPTab_plotset.SEMtrans_custom.Enable = enbaleflag;
        ERPTab_plotset.show_SEM.Enable = enbaleflag;
        ERPTab_plotset.plot_reset.Enable =enbaleflag;
        ERPTab_plotset.plot_apply.Enable =enbaleflag;
        ERPTab_plotset.gridlayoutdef.Enable =enbaleflag;
        ERPTab_plotset.chanorder_front.Enable =enbaleflag;
        ERPTab_plotset.gridlayout_custom.Enable =enbaleflag;
        ERPTab_plotset.gridlayout_export.Enable =enbaleflag;
        ERPTab_plotset.gridlayout_import.Enable =enbaleflag;
        ERPTab_plotset.rowNum_set.Enable =enbaleflag;
        ERPTab_plotset.columns.Enable =enbaleflag;
        if isempty(observe_ERPDAT.ALLERP)|| isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP =4;
            return;
        end
        
        %
        %%time range
        if ERPTab_plotset.timet_auto.Value == 1
            ERPTab_plotset.timet_low.String = num2str(observe_ERPDAT.ERP.times(1));
            ERPTab_plotset.timet_low.Enable = 'off';
            ERPTab_plotset.timet_high.String = num2str(observe_ERPDAT.ERP.times(end));
            ERPTab_plotset.timet_high.Enable =  'off';
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
        [def xstep]= default_time_ticks_studio(observe_ERPDAT.ERP, [timeStart,timEnd]);
        if ERPTab_plotset.timetick_auto.Value==1
            ERPTab_plotset.timet_step.String = num2str(xstep);
            ERPTab_plotset.timet_step.Enable = 'off';
        end
        xtickstep = str2num(ERPTab_plotset.timet_step.String);
        if isempty(xtickstep) || numel(xtickstep)~=1 || xtickstep> floor((timEnd-timeStart)/2)
            xtickstep= xstep;
            ERPTab_plotset.timet_step.String = num2str(xstep);
        end
        ERPTab_plotset_pars{2} = xtickstep;
        %
        %%Amplitude Axis
        %%Yscale
        BinArray= estudioworkingmemory('ERP_BinArray');
        if isempty(BinArray) || any(BinArray<=0) || any(BinArray>observe_ERPDAT.ERP.nbin)
            BinArray = [1:observe_ERPDAT.ERP.nbin];
            estudioworkingmemory('ERP_BinArray',BinArray);
        end
        ChanArray=estudioworkingmemory('ERP_ChanArray');
        if isempty(ChanArray) || any(ChanArray<=0) || any(ChanArray>observe_ERPDAT.ERP.nchan)
            ChanArray = [1:observe_ERPDAT.ERP.nchan];
            estudioworkingmemory('ERP_ChanArray',ChanArray);
        end
        if ERPTab_plotset.gridlayoutdef.Value==1
           ChanArray = sort(ChanArray); 
        end
        ERP1 = observe_ERPDAT.ERP;
        ERP1.bindata = ERP1.bindata(ChanArray,:,:);
        [def, minydef, maxydef] = default_amp_ticks(ERP1, BinArray);
        minydef = floor(minydef);
        maxydef = ceil(maxydef);
        if ERPTab_plotset.yscale_auto.Value ==1
            ERPTab_plotset.yscale_low.Enable = 'off';
            ERPTab_plotset.yscale_high.Enable = 'off';
            ERPTab_plotset.yscale_low.String = num2str(minydef);
            ERPTab_plotset.yscale_high.String = num2str(maxydef);
        end
        Yscales_low = str2num(ERPTab_plotset.yscale_low.String);
        Yscales_high = str2num(ERPTab_plotset.yscale_high.String);
        if isempty(Yscales_low) || numel(Yscales_low)~=1
            ERPTab_plotset.yscale_low.String = num2str(minydef);
            Yscales_low= minydef;
        end
        if isempty(Yscales_high) || numel(Yscales_high)~=1
            ERPTab_plotset.yscale_high.String = num2str(maxydef);
            Yscales_high= maxydef;
        end
        
        if any(Yscales_high<=Yscales_low)
            ERPTab_plotset.yscale_low.String = num2str(minydef);
            Yscales_low= minydef;
            ERPTab_plotset.yscale_high.String = num2str(maxydef);
            Yscales_high= maxydef;
        end
        ERPTab_plotset_pars{3} = [Yscales_low,Yscales_high];
        
        if ERPTab_plotset.ytick_auto.Value==1
            defyticks = default_amp_ticks_viewer([Yscales_low,Yscales_high]);
            defyticks = str2num(defyticks);
            if ~isempty(defyticks) && numel(defyticks)>=2
                ERPTab_plotset.yscale_step.String = num2str(min(diff(defyticks)));
            else
                ERPTab_plotset.yscale_step.String = num2str(floor((Yscales_high-Yscales_low)/2));
            end
            ERPTab_plotset.yscale_step.Enable = 'off';
        end
        
        ERPTab_plotset_pars{4} = str2num(ERPTab_plotset.yscale_step.String);
        
        if ERPTab_plotset.pagesel.Value==1
            nplot = numel(ChanArray);
            plotarray = ChanArray;
            [~, labelsdef, ~, ~, ~] = readlocs(observe_ERPDAT.ERP.chanlocs);
        else
            nplot = numel(BinArray);
            plotarray = BinArray;
            labelsdef =observe_ERPDAT.ERP.bindescr;
        end
        if ERPTab_plotset.gridlayoutdef.Value ==1 || ERPTab_plotset.chanorder_front.Value==1
            EnableFlag = 'off';
            rowNum = ceil(sqrt(nplot));
            ERPTab_plotset.rowNum_set.Value=rowNum;
            ERPTab_plotset.columns.Value =ceil(nplot/rowNum);
        else
            EnableFlag = 'on';
        end
        rowNum = ERPTab_plotset.rowNum_set.Value;
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
        ERPTab_plotset_pars{5} =columNum;
        %%polarity (positive up?)
        ERPTab_plotset_pars{6} =ERPTab_plotset.positive_up.Value;
        
        %%overlay?
        if ERPTab_plotset.pagesel.Value==1
            ERPTab_plotset_pars{7} =0;
        else
            ERPTab_plotset_pars{7} =  1;
        end
        ERPTab_plotset_pars{8}  = ERPTab_plotset.rowNum_set.Value;%%number of rows
        if ERPTab_plotset.gridlayoutdef.Value==1
            gridlayoutdef=1;
        elseif ERPTab_plotset.chanorder_front.Value==1
            gridlayoutdef=2;
        else
            gridlayoutdef=3;
        end
        
        ERPTab_plotset_pars{9} = gridlayoutdef;%%default grid layout?
        
        try
            [eloc, labels, theta, radius, indices] = readlocs(observe_ERPDAT.ERP.chanlocs);
            ERPTab_plotset.chanorderIndex = 2;
            chanindexnew = f_estudio_chan_frontback_left_right(observe_ERPDAT.ERP.chanlocs(sort(ChanArray)));
            if ~isempty(chanindexnew)
                ChanArray = sort(ChanArray);
                chanindexnew =   ChanArray(chanindexnew);
            else
                chanindexnew = ChanArray;
            end
        catch
            chanindexnew = ChanArray;
        end
        if ERPTab_plotset.chanorder_front.Value==1
            gridlayputarraydef = cell(rowNum,columNum);
            count = 0;
            for ii = 1:rowNum
                for jj = 1:columNum
                    count = count+1;
                    if count<= length(plotarray)
                        if ERPTab_plotset.pagesel.Value==1
                            try
                                gridlayputarraydef{ii,jj} = observe_ERPDAT.ERP.chanlocs(chanindexnew(count)).labels;
                            catch
                                gridlayputarraydef{ii,jj} = ['Chan',32,num2str(chanindexnew(count))];
                            end
                        else
                            gridlayputarraydef{ii,jj} = observe_ERPDAT.ERP.bindescr{BinArray(count)};
                        end
                    end
                end
                
            end
            estudioworkingmemory('ERP_ChanArray',chanindexnew);
            ERPTab_plotset.gridlayputarray=gridlayputarraydef;
        elseif ERPTab_plotset.gridlayoutdef.Value ==1
            ERPTab_plotset.gridlayputarray=  gridlayputarraydef;
        end
        
        ERPTab_plotset_pars{10} = ERPTab_plotset.gridlayputarray;
        if isempty(observe_ERPDAT.ERP.binerror)
            ERPTab_plotset.show_SEM.Value=0;
            ERPTab_plotset.show_SEM.Enable = 'off';
        else
            ERPTab_plotset.show_SEM.Enable = 'on';
        end
        %%standard error
        SEM_custom = ERPTab_plotset.SEM_custom.Value-1;
        SEMtrans_custom = (ERPTab_plotset.SEMtrans_custom.Value-1)/10;
        if ERPTab_plotset.show_SEM.Value == 1
            ERPTab_plotset.SEM_custom.Enable = 'on';
            ERPTab_plotset.SEMtrans_custom.Enable = 'on';
            SEM_custom = ERPTab_plotset.SEM_custom.Value-1;
            SEMtrans_custom = (ERPTab_plotset.SEMtrans_custom.Value-1)/10;
            ERPTab_plotset_pars{11} = [1,SEM_custom,SEMtrans_custom];
        else
            ERPTab_plotset_pars{11} = [0,SEM_custom,SEMtrans_custom];
            ERPTab_plotset.SEM_custom.Enable = 'off';
            ERPTab_plotset.SEMtrans_custom.Enable = 'off';
        end
        estudioworkingmemory('ERPTab_plotset_pars',ERPTab_plotset_pars);
        ERPTab_plotset.paras{1} = ERPTab_plotset.timet_auto.Value;
        ERPTab_plotset.paras{2} = ERPTab_plotset.timetick_auto.Value;
        ERPTab_plotset.paras{3} = ERPTab_plotset.yscale_auto.Value;
        ERPTab_plotset.paras{4} = ERPTab_plotset.ytick_auto.Value;
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


%%---------------reset the parameters for all panels-----------------------
    function Reset_erp_panel_change(~,~)
        if observe_ERPDAT.Reset_erp_paras_panel~=3
            return;
        end
        estudioworkingmemory('ERPTab_plotset',0);
        ERPTab_plotset.plot_apply.BackgroundColor =  [ 1 1 1];
        ERPTab_plotset.plot_apply.ForegroundColor = [0 0 0];
        ERP_plotset_box.TitleColor= [0.0500    0.2500    0.5000];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_plotset.plot_reset.BackgroundColor =  [1 1 1];
        ERPTab_plotset.plot_reset.ForegroundColor = [0 0 0];
        ERPTab_plotset.timet_auto.Value=1;
        ERPTab_plotset.timet_low.Enable = 'off';
        ERPTab_plotset.timet_high.Enable = 'off';
        try
            ERPTab_plotset.timet_low.String = num2str(observe_ERPDAT.ERP.times(1));
            ERPTab_plotset.timet_high.String = num2str(observe_ERPDAT.ERP.times(end));
        catch
            ERPTab_plotset.timet_low.String = '';
            ERPTab_plotset.timet_high.String = '';
        end
        ERPTab_plotset.timetick_auto.Value=1;
        ERPTab_plotset.ytick_auto.Value=1;
        ERPTab_plotset.yscale_auto.Value=1;
        if ~isempty(observe_ERPDAT.ERP)
            [def xstep]= default_time_ticks_studio(observe_ERPDAT.ERP, [observe_ERPDAT.ERP.times(1),observe_ERPDAT.ERP.times(end)]);
            ERPTab_plotset.timet_step.String = num2str(xstep);
            [def, minydef, maxydef] = default_amp_ticks(observe_ERPDAT.ERP, [1:observe_ERPDAT.ERP.nbin]);
            minydef = floor(minydef);
            maxydef = ceil(maxydef);
            ERPTab_plotset.yscale_low.String = num2str(minydef);
            ERPTab_plotset.yscale_high.String = num2str(maxydef);
            defyticks = default_amp_ticks_viewer([minydef,maxydef]);
            defyticks = str2num(defyticks);
            if ~isempty(defyticks) && numel(defyticks)>=2
                ERPTab_plotset.yscale_step.String = num2str(min(diff(defyticks)));
            else
                ERPTab_plotset.yscale_step.String = num2str(floor((Yscales_high-Yscales_low)/2));
            end
        else
            xstep = [];
            ERPTab_plotset.timet_step.String = '';
            ERPTab_plotset.yscale_low.String = '';
            ERPTab_plotset.yscale_high.String = '';
            ERPTab_plotset.yscale_step.String  = '';
            minydef = [];
            maxydef = [];
        end
        ERPTab_plotset.yscale_low.Enable = 'off';
        ERPTab_plotset.yscale_high.Enable = 'off';
        ERPTab_plotset.yscale_step.Enable = 'off';
        ERPTab_plotset.positive_up.Value =1;
        ERPTab_plotset.negative_up.Value = 0;
        ERPTab_plotset.pagesel.Value = 1;
        
        
        ERPTab_plotset.gridlayoutdef.Value = 1;
        ERPTab_plotset.chanorder_front.Value=0;
        ERPTab_plotset.gridlayout_custom.Value = 0;
        ERPTab_plotset.gridlayout_export.Enable ='off';
        ERPTab_plotset.gridlayout_import.Enable ='off';
        ERPTab_plotset.rowNum_set.Enable ='off';
        ERPTab_plotset.columns.Enable ='off';
        try
            ERPTab_plotset_pars{1} = [observe_ERPDAT.ERP.times(1),observe_ERPDAT.ERP.times(end)];
        catch
            ERPTab_plotset_pars{1} = [];
        end
        ERPTab_plotset_pars{2} = xstep;
        ERPTab_plotset_pars{3} = [minydef,maxydef];
        ERPTab_plotset_pars{4} = str2num(ERPTab_plotset.yscale_step.String);
        ERPTab_plotset_pars{6} =ERPTab_plotset.positive_up.Value;
        ERPTab_plotset_pars{7} =0;
        try
            ChanArray = [1:observe_ERPDAT.ERP.nchan];
        catch
            ChanArray = 1;
        end
        rowNum = ceil(sqrt(numel(ChanArray)));
        ERPTab_plotset.rowNum_set.Value=rowNum;
        ERPTab_plotset.columns.Value =ceil(numel(ChanArray)/rowNum);
        gridlayputarraydef = cell(ERPTab_plotset.rowNum_set.Value,ERPTab_plotset.columns.Value);
        if ~isempty(observe_ERPDAT.ERP)
            [~, labelsdef, ~, ~, ~] = readlocs(observe_ERPDAT.ERP.chanlocs);
            count = 0;
            for ii = 1:ERPTab_plotset.rowNum_set.Value
                for jj = 1:ERPTab_plotset.columns.Value
                    count = count+1;
                    if count>numel(ChanArray)
                        break;
                    end
                    gridlayputarraydef{ii,jj} = labelsdef{count};
                end
            end
        else
            gridlayputarraydef = [];
            labelsdef = [];
        end
        ERPTab_plotset.gridlayputarray = gridlayputarraydef;
        ERPTab_plotset_pars{5} =ERPTab_plotset.columns.Value;
        ERPTab_plotset_pars{8}  = ERPTab_plotset.rowNum_set.Value;%%number of rows
        ERPTab_plotset_pars{9} = ERPTab_plotset.gridlayoutdef.Value ;%%default grid layout?
        ERPTab_plotset_pars{10} = gridlayputarraydef;
        try show_SEM = ERPTab_plotset_pars{11};catch  show_SEM=[0,1,0.2];end;
        try  ERPTab_plotset.show_SEM.Value =show_SEM(1); catch  ERPTab_plotset.show_SEM.Value=0; end;
        
        try SEM_custom = show_SEM(2); catch SEM_custom=1;  end
        if isempty(SEM_custom) || numel(SEM_custom)~=1 || any(SEM_custom<0) || any(SEM_custom>10)
            SEM_custom=1;
        end
        ERPTab_plotset.SEM_custom.Value = SEM_custom+1;
        
        try SEMtrans_custom = show_SEM(3); catch SEMtrans_custom = 0.2; end
        if isempty(SEMtrans_custom) || numel(SEMtrans_custom)~=1 || any(SEMtrans_custom<0) || any(SEMtrans_custom>1)
            SEMtrans_custom=0.2;
        end
        ERPTab_plotset.SEMtrans_custom.Value = SEMtrans_custom*10+1;
        SEM_custom = ERPTab_plotset.SEM_custom.Value-1;
        SEMtrans_custom = (ERPTab_plotset.SEMtrans_custom.Value-1)/10;
        if ERPTab_plotset.show_SEM.Value == 1
            SEM_custom = ERPTab_plotset.SEM_custom.Value-1;
            SEMtrans_custom = (ERPTab_plotset.SEMtrans_custom.Value-1)/10;
            ERPTab_plotset_pars{11} = [1,SEM_custom,SEMtrans_custom];
            ERPTab_plotset.SEM_custom.Enable = 'on';
            ERPTab_plotset.SEMtrans_custom.Enable = 'on';
        else
            ERPTab_plotset_pars{11} = [0,SEM_custom,SEMtrans_custom];
            ERPTab_plotset.SEM_custom.Enable = 'off';
            ERPTab_plotset.SEMtrans_custom.Enable = 'off';
        end
        
        ERPTab_plotset.paras{1} = ERPTab_plotset.timet_auto.Value;
        ERPTab_plotset.paras{2} = ERPTab_plotset.timetick_auto.Value;
        ERPTab_plotset.paras{3} = ERPTab_plotset.yscale_auto.Value;
        ERPTab_plotset.paras{4} = ERPTab_plotset.ytick_auto.Value;
        estudioworkingmemory('ERPTab_plotset_pars',ERPTab_plotset_pars);
        observe_ERPDAT.Reset_erp_paras_panel=4;
    end
end



function IA = f_chanlabel_check(Checklabel,allabels)
IA = 0;
for ii = 1:length(allabels)
    if strcmpi(strtrim(Checklabel),strtrim(allabels{ii}))
        IA = ii;
        break;
    end
end
end


%%--------------------------check the labels-------------------------------
function [Simplabels,simplabelIndex,SamAll] = Simplelabels(labels)
labelsrm = ['['];
for ii=1:1000
    labelsrm = char([labelsrm,',',num2str(ii)]);
end
labelsrm = char([labelsrm,',z,Z]']);

SamAll = 0;
for ii = 1:length(labels)
    labelcell = labels{ii};
    labelcell(regexp(labelcell,labelsrm))=[];
    labelsNew{ii} = labelcell;
end

%%get the simple
[~,X,Z] = unique(labelsNew,'stable');
Simplabels = labelsNew(X);
if length(Simplabels)==1
    SamAll = 1;
end

simplabelIndex = zeros(1,length(labels));
count = 0;
for jj = 1:length(Simplabels)
    for kk = 1:length(labelsNew)
        if strcmp(Simplabels{jj},labelsNew{kk})
            count = count+1;
            simplabelIndex(kk) =   jj;
        end
    end
end
end

