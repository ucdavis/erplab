%%This function is used to setting the parameters for plotting the waveform for the selected ERPsets




function varargout = f_ERP_plot_setting_GUI(varargin)

global observe_ERPDAT;
% addlistener(observe_ERPDAT,'ALLERP_change',@erpschange);
% addlistener(observe_ERPDAT,'ERP_change',@drawui_CB);
% addlistener(observe_ERPDAT,'CURRENTERP_change',@cerpchange);

addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);


%---------------------------Initialize parameters------------------------------------
% global S_erpplot;
% global plotops_erp;
% global gui_erp_plot;
S_IN =estudioworkingmemory('geterpplot');

if isempty(S_IN)
    try
        SelectedIndex = observe_ERPDAT.CURRENTERP;
    catch
        disp('f_ERP_plot_setting_GUI error: No CURRENTERP is on Matlab Workspace');
        return;
    end
    if SelectedIndex ==0
        
        disp('f_ERP_plot_setting_GUI error: No ERPset is imported');
        return;
    end
    
    if SelectedIndex>length(observe_ERPDAT.ALLERP)
        SelectedIndex =1;
    end
    
    S_erpbinchan = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,SelectedIndex);
    estudioworkingmemory('geterpplot',S_erpbinchan.geterpplot);
    estudioworkingmemory('geterpbinchan',S_erpbinchan.geterpbinchan);
    S_IN = S_erpbinchan.geterpplot;
    
    
end

S_erpplot = S_IN;

plotops_erp = struct();
gui_erp_plot = struct;

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
        
        S_binchan =  estudioworkingmemory('geterpbinchan');
        Select_index = S_binchan.Select_index;
        gui_erp_plot.plotop = uiextras.VBox('Parent',ERP_plotset_box, 'Spacing',1,'BackgroundColor',ColorB_def);
        
        %         set(gui_erp_plot.time_sel, 'Sizes', [-1 -1 -1 -1 -1]);
        uicontrol('Style','text','Parent', gui_erp_plot.plotop,'String','Time Range:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def); % 1B
        
        gui_erp_plot.ticks = uiextras.HBox('Parent',gui_erp_plot.plotop,'Spacing',1,'BackgroundColor',ColorB_def);
        plotops_erp.timet_auto = uicontrol('Style','checkbox','Parent', gui_erp_plot.ticks,'String','Auto','callback',@timet_auto,'Value',1,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 2B
        uicontrol('Style','text','Parent', gui_erp_plot.ticks,'String','Low','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        plotops_erp.timet_low = uicontrol('Style', 'edit','Parent',gui_erp_plot.ticks,...
            'String',num2str(S_erpplot.timet_low(Select_index)),'callback',@low_ticks_change,'Enable','off','FontSize',FonsizeDefault);
        uicontrol('Style','text','Parent', gui_erp_plot.ticks,'String','High','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        plotops_erp.timet_high = uicontrol('Style', 'edit','Parent',gui_erp_plot.ticks,'String',num2str(S_erpplot.timet_high(Select_index)),...
            'callback',@high_ticks_change,'Enable','off','FontSize',FonsizeDefault);
        uicontrol('Style','text','Parent', gui_erp_plot.ticks,'String','Step','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        plotops_erp.timet_step = uicontrol('Style', 'edit','Parent',gui_erp_plot.ticks,'String',num2str(S_erpplot.timet_step(Select_index)),...
            'callback',@ticks_step_change,'Enable','off','FontSize',FonsizeDefault);
        
        set(gui_erp_plot.ticks, 'Sizes', [60 -1 -1 -1 -1 -1 -1]);
        
        uicontrol('Style','text','Parent', gui_erp_plot.plotop,'String','Y Scale:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        gui_erp_plot.yscale = uiextras.HBox('Parent',gui_erp_plot.plotop,'Spacing',1,'BackgroundColor',ColorB_def);
        plotops_erp.yscale_auto = uicontrol('Style','checkbox','Parent',gui_erp_plot.yscale,'String','Auto',...
            'callback',@yscale_auto,'Value',1,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        tooltiptext = sprintf('Tick Length:\nSize of Y Ticks');
        uicontrol('Style','text','Parent',gui_erp_plot.yscale,'String','Ticks','TooltipString',tooltiptext,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        plotops_erp.yscale_change = uicontrol('Style','edit','Parent',gui_erp_plot.yscale,...
            'String',S_erpplot.yscale(Select_index),'callback',@yscale_change,'Enable','off','FontSize',FonsizeDefault);
        tooltiptext = sprintf('Minimum Vertical Spacing:\nSmallest possible distance in inches between zero lines before plots go off the page.');
        uicontrol('Style','text','Parent',gui_erp_plot.yscale,'String','Spacing','TooltipString',tooltiptext,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        plotops_erp.min_vspacing = uicontrol('Style','edit','Parent',gui_erp_plot.yscale,'String',S_erpplot.min_vspacing(Select_index),'callback',@min_vspacing,'Enable','off','FontSize',FonsizeDefault);
        tooltiptext = sprintf('Fill Screen:\nDynamically expand plots to fill screen.');
        plotops_erp.fill_screen = uicontrol('Style','checkbox','Parent',gui_erp_plot.yscale,'String','Fill','callback',@fill_screen,...
            'TooltipString',tooltiptext,'Value',S_erpplot.fill(Select_index),'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        set(gui_erp_plot.yscale, 'Sizes', [50 45 35 50 35 60]);
        
        
        gui_erp_plot.plot_column = uiextras.HBox('Parent',gui_erp_plot.plotop,'Spacing',1,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def);
        
        uicontrol('Style','text','Parent', gui_erp_plot.plot_column,'String','Number of columns:','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 1E
        
        ColumnNum =  estudioworkingmemory('EStudioColumnNum');
        if isempty(ColumnNum) || numel(ColumnNum)~=1
            ColumnNum =1;
        end
        plotops_erp.columns = uicontrol('Style','edit','Parent', gui_erp_plot.plot_column,...
            'String',num2str(ColumnNum),'callback',@onElecNbox,'FontSize',FonsizeDefault); % 2E Plot_column
        set(gui_erp_plot.plot_column, 'Sizes', [150 -1]);
        
        
        gui_erp_plot.polarity_waveform = uiextras.HBox('Parent',gui_erp_plot.plotop,'Spacing',1,'BackgroundColor',ColorB_def);
        
        uicontrol('Style','text','Parent', gui_erp_plot.polarity_waveform,'String','Polarity:','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 1F
        
        %% second column:
        plotops_erp.positive_up = uicontrol('Style','radiobutton','Parent',gui_erp_plot.polarity_waveform,'String','Positive Up','callback',@polarity_up,'Value',1,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 2F
        plotops_erp.negative_up = uicontrol('Style','radiobutton','Parent', gui_erp_plot.polarity_waveform,'String','Negative Up','callback',@polarity_down,'Value',0,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 2F
        
        set(gui_erp_plot.polarity_waveform, 'Sizes',[60  -1 -1]);
        
        gui_erp_plot.bin_chan = uiextras.HBox('Parent',gui_erp_plot.plotop,'Spacing',1,'BackgroundColor',ColorB_def);
        
        gui_erp_plot.pagesel = uicontrol('Parent', gui_erp_plot.bin_chan, 'Style', 'popupmenu','String',...
            {'CHANNELS with BINS overlay','BINS with CHANNELS overlay'},'callback',@pageviewchanged,'FontSize',FonsizeDefault);
        
        
        gui_erp_plot.reset_apply = uiextras.HBox('Parent',gui_erp_plot.plotop,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', gui_erp_plot.reset_apply); % 1A
        plotops_erp.plot_reset = uicontrol('Style', 'pushbutton','Parent',gui_erp_plot.reset_apply,...
            'String','Reset','callback',@plot_erp_reset,'FontSize',FonsizeDefault);
        uiextras.Empty('Parent', gui_erp_plot.reset_apply); % 1A
        plotops_erp.plot_apply = uicontrol('Style', 'pushbutton','Parent',gui_erp_plot.reset_apply,...
            'String','Apply','callback',@plot_erp_apply,'FontSize',FonsizeDefault);
        uiextras.Empty('Parent', gui_erp_plot.reset_apply); % 1A
        set(gui_erp_plot.reset_apply, 'Sizes',[10 -1  30 -1 10]);
        
        set(gui_erp_plot.plotop, 'Sizes', [20 25 20 25 25 25 20 30]);
        
    end



%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%---------------------------------Auto time ticks-------------------------------*
    function timet_auto( src, ~ )
        estudioworkingmemory('erp_xtickstep',0);
        S_selectedERP =  estudioworkingmemory('selectederpstudio');
        if isempty(S_selectedERP)
            S_selectedERP =  observe_ERPDAT.CURRENTERP;
            S_erpbinchan = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,S_selectedERP);
            estudioworkingmemory('geterpbinchan',S_erpbinchan.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpbinchan.geterpplot);
        end
        
        S_binchan =  estudioworkingmemory('geterpbinchan');
        Select_index = S_binchan.Select_index;
        
        if src.Value == 1
            plotops_erp.timet_low.Enable = 'off';
            plotops_erp.timet_high.Enable = 'off';
            plotops_erp.timet_step.Enable = 'off';
        else
            plotops_erp.timet_low.Enable = 'on';
            plotops_erp.timet_high.Enable = 'on';
            plotops_erp.timet_step.Enable = 'on';
        end
        plotops_erp.timet_low.String = num2str(floor(observe_ERPDAT.ALLERP(S_selectedERP(Select_index)).times(1)/5)*5);
        plotops_erp.timet_high.String = num2str(ceil(observe_ERPDAT.ALLERP(S_selectedERP(Select_index)).times(end)/5)*5);
        
        
        Min_time=floor(observe_ERPDAT.ALLERP(S_selectedERP(Select_index)).times(1)/5)*5;
        Max_time = ceil(observe_ERPDAT.ALLERP(S_selectedERP(Select_index)).times(end)/5)*5;
        
        [def xstep]= default_time_ticks_studio(observe_ERPDAT.ERP, [Min_time,Max_time]);
        plotops_erp.timet_step.String = num2str(xstep);
        
        checked_ERPset_Index = S_binchan.checked_ERPset_Index;
        
        
        if any(checked_ERPset_Index(5))
            S_erpplot.timet_low(Select_index) = floor(observe_ERPDAT.ALLERP(S_selectedERP(Select_index)).times(1)/5)*5;
        else
            S_erpplot.timet_low(1:end) = floor(observe_ERPDAT.ALLERP(S_selectedERP(Select_index)).times(1)/5)*5;
        end
        
        if any(checked_ERPset_Index(6))
            S_erpplot.timet_high(Select_index) = ceil(observe_ERPDAT.ALLERP(S_selectedERP(Select_index)).times(end)/5)*5;
        else
            S_erpplot.timet_high(1:end) = ceil(observe_ERPDAT.ALLERP(S_selectedERP(Select_index)).times(end)/5)*5;
        end
        
        if any(checked_ERPset_Index(6)) || any(checked_ERPset_Index(5))
            S_erpplot.timet_step(Select_index) = xstep;
        else
            S_erpplot.timet_step(1:end) = xstep;
        end
    end


%%--------------------------Min. interval of time ticks---------------------
    function low_ticks_change( src, ~ )
        
        S_selectedERP =  estudioworkingmemory('selectederpstudio');
        if isempty(S_selectedERP)
            S_selectedERP =  observe_ERPDAT.CURRENTERP;
            S_erpbinchan = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,S_selectedERP);
            estudioworkingmemory('geterpbinchan',S_erpbinchan.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpbinchan.geterpplot);
        end
        
        S_binchan =  estudioworkingmemory('geterpbinchan');
        Select_index = S_binchan.Select_index;
        
        xtixlk_min = str2num(src.String);
        xtixlk_max = str2num(plotops_erp.timet_high.String);
        if isempty(xtixlk_min)
            src.String = num2str(S_erpplot.timet_low(Select_index));
            beep;
            msgboxText =  ['Plot Setting> Time range- Input of left edge must be a numeric'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
        
        if numel(xtixlk_min)>1
            src.String = num2str(S_erpplot.timet_low(Select_index));
            msgboxText =  ['Plot Setting> Time range- nput of left edge must be a single numeric'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            
            return;
        end
        
        
        checked_ERPset_Index = S_binchan.checked_ERPset_Index;
        
        if xtixlk_min < S_erpplot.timet_high(Select_index)
            S_erpplot.timet_low(Select_index)=xtixlk_min;
            if any(checked_ERPset_Index(5))
                S_erpplot.timet_low(Select_index)=xtixlk_min;
            else
                S_erpplot.timet_low(1:end)=xtixlk_min;
            end
            
            [def xstep]= default_time_ticks_studio(observe_ERPDAT.ERP, [xtixlk_min,xtixlk_max]);
            plotops_erp.timet_step.String = num2str(xstep);
            S_erpplot.timet_step(1:end) = xstep;
        else
            src.String = S_erpplot.min(Select_index);
            
            msgboxText =  ['Plot Setting> Time range- left range  must be lower than high tick'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
        if S_erpplot.timet_step(Select_index) >  S_erpplot.timet_high(Select_index)- S_erpplot.timet_low(Select_index)
            plotops_erp.timet_step.String = num2str(S_erpplot.timet_step(Select_index));
            
            msgboxText =  ['Plot Setting> Time range- Step must be within the time range'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
    end



%%----------------------high interval of time ticks--------------------------------*
    function high_ticks_change( src, ~ )
        S_selectedERP =  estudioworkingmemory('selectederpstudio');
        if isempty(S_selectedERP)
            S_selectedERP =  observe_ERPDAT.CURRENTERP;
            S_erpbinchan = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,S_selectedERP);
            estudioworkingmemory('geterpbinchan',S_erpbinchan.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpbinchan.geterpplot);
        end
        
        S_binchan =  estudioworkingmemory('geterpbinchan');
        Select_index = S_binchan.Select_index;
        xtixlk_min = str2num(plotops_erp.timet_low.String);
        xtixlk_max = str2num(src.String);
        
        if isempty(xtixlk_max)
            src.String = num2str(S_erpplot.timet_high(Select_index));
            beep;
            msgboxText =  ['Plot Setting> Y Scale- Input of ticks edge must be a numeric'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            
            return;
        end
        
        if numel(xtixlk_max)>1
            src.String = num2str(S_erpplot.timet_high(Select_index));
            beep;
            msgboxText =  ['Plot Setting> Y Scale- Input of ticks edge must be a numeric'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            
            return;
        end
        
        
        checked_ERPset_Index = S_binchan.checked_ERPset_Index;
        
        if xtixlk_max > xtixlk_min
            
            if  any(checked_ERPset_Index(6))
                S_erpplot.timet_high(Select_index) = xtixlk_max;
            else
                S_erpplot.timet_high(1:end) = xtixlk_max;
            end
            [def xstep]= default_time_ticks_studio(observe_ERPDAT.ERP, [xtixlk_min,xtixlk_max]);
            plotops_erp.timet_step.String = num2str(xstep);
            S_erpplot.timet_step(1:end) = xstep;
            
        else
            src.String =  num2str(S_erpplot.timet_high(Select_index));
            beep;
            msgboxText =  ['Plot Setting> Time range- right edge must be higher than',32,num2str(xtixlk_min),'ms'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
        if S_erpplot.timet_step(Select_index) > S_erpplot.timet_high(Select_index) -S_erpplot.timet_low(Select_index)
            beep;
            plotops_erp.timet_step.String = num2str(S_erpplot.timet_step(Select_index));
            msgboxText =  ['Plot Setting> Time range- Step must be within the time range'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
    end


%%----------------------Step of time ticks--------------------------------*
    function ticks_step_change( src, ~ )
        
        tick_step = str2num(src.String);
        S_selectedERP =  estudioworkingmemory('selectederpstudio');
        if isempty(S_selectedERP)
            S_selectedERP =  observe_ERPDAT.CURRENTERP;
            S_erpbinchan = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,S_selectedERP);
            estudioworkingmemory('geterpbinchan',S_erpbinchan.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpbinchan.geterpplot);
        end
        
        S_binchan =  estudioworkingmemory('geterpbinchan');
        Select_index = S_binchan.Select_index;
        
        if isempty(tick_step)
            src.String = num2str(S_erpplot.timet_step(Select_index));
            beep;
            msgboxText =  ['Plot Setting> Time range- The input of Step must be a numeric'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
        if numel(tick_step)>1
            src.String = num2str(S_erpplot.timet_step(Select_index));
            beep;
            msgboxText =  ['Plot Setting> Time range- The input of Step must be one numeric'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
        if tick_step<=0 %% otherwise, a bug will be displayed
            src.String = num2str(S_erpplot.timet_step(Select_index));
            beep;
            msgboxText =  ['Plot Setting> Time range- Step must be a positive value'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
        checked_ERPset_Index = S_binchan.checked_ERPset_Index;
        
        if tick_step < S_erpplot.timet_high(Select_index) -S_erpplot.timet_low(Select_index)
            
            if any(checked_ERPset_Index(5)) && any(checked_ERPset_Index(6))
                S_erpplot.timet_step(Select_index) = tick_step;
            else
                S_erpplot.timet_step(1:end) = tick_step;
            end
            estudioworkingmemory('erp_xtickstep',1);
            
            
        else
            src.String = num2str(S_erpplot.timet_step(Select_index));
            beep;
            msgboxText =  ['Plot Setting> Time range- Step must be within the time range'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
    end

%%---------------------------------Auto y scale---------------------------------*
    function yscale_auto( src, ~ )
        S_selectedERP =  estudioworkingmemory('selectederpstudio');
        if isempty(S_selectedERP)
            S_selectedERP =  observe_ERPDAT.CURRENTERP;
            S_erpbinchan = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,S_selectedERP);
            estudioworkingmemory('geterpbinchan',S_erpbinchan.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpbinchan.geterpplot);
        end
        S_binchan =  estudioworkingmemory('geterpbinchan');
        Select_index = S_binchan.Select_index;
        
        if src.Value == 1
            plotops_erp.yscale_change.Enable = 'off';
            YScale =prctile((observe_ERPDAT.ALLERP(S_selectedERP(Select_index)).bindata(:)*S_erpplot.Positive_up(Select_index)),95)*2/3;
            if YScale>= 0&&YScale <=0.1
                YScale = 0.1;
            elseif YScale< 0&& YScale > -0.1
                YScale = -0.1;
            else
                YScale = round(YScale);
            end
            plotops_erp.yscale_change.String = YScale;
            S_erpplot.yscale(1:end) = YScale;
            
            plotops_erp.min_vspacing.Enable = 'off';
            plotops_erp.min_vspacing.String = 1.5;
            S_erpplot.min_vspacing(1:end) =1.5;
        else
            plotops_erp.yscale_change.Enable = 'on';
            plotops_erp.min_vspacing.Enable = 'on';
        end
        
    end


%%---------------------------------y scale change---------------------------------*
    function yscale_change(src, ~ )
        
        clear i
        val = 1i;
        try
            val = str2double(src.String);
        catch
            beep;
            msgboxText =  ['Plot Setting> y scale - Input of y scale must be a numeric'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        if val ~= 1i
            if val <= 0
                beep;
                msgboxText =  ['Plot Setting> y scale - Input must be greater than zero'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
            else
                S_erpplot.yscale(1:end) = val;
            end
        end
        
    end


%%-------------------------- Y scale spacing-------------------------------
    function min_vspacing( src, ~ )
        clear i
        val = 1i;
        try
            val = str2double(src.String);
        catch
            beep;
            msgboxText =  ['Plot Setting> y scale > spacing - Input of spacing must be a numeric'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            src.String = 1.5;
        end
        if val ~= 1i
            if val <= 0
                beep;
                msgboxText =  ['Plot Setting> y scale > spacing - Input of spacing must be greater than zero'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                src.String = 1.5;
            else
                S_erpplot.min_vspacing(1:end) = val;
            end
        end
    end

%%-----------------fill screen---------------------------------------------*
    function fill_screen( src, ~ )
        S_erpplot.fill(1:end)= src.Value;
    end

%%-----------Determing the numbrt of columns------------------------------
    function onElecNbox(source,~)
        Values = str2num(source.String);
        if isempty(Values) || Values <=0
            source.String = num2str( S_erpplot.Plot_column(1));
            msgboxText =  ['Plot Setting> Number of columns - Input for the number of columns must be greater than zero'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        S_erpplot.Plot_column(1:end) = Values;
    end

%------------------Set the polarity of waveform is up or not-------------------
    function polarity_up(~,~)
        source_value_up = 1;
        plotops_erp.positive_up.Value =source_value_up;
        plotops_erp.negative_up.Value = 0;
        S_erpplot.Positive_up(1:end) = source_value_up;
    end


%------------------Set the polarity of waveform is up or not-------------------
    function polarity_down( source, ~)
        source_value_down = 1;
        plotops_erp.positive_up.Value =0;
        plotops_erp.negative_up.Value = source_value_down;
        S_erpplot.Positive_up(1:end) = -source_value_down;
    end

%%-------------------------------------------------------------------------
    function Count_currentERPChanged(~,~)
        erp_plot_set_label =  estudioworkingmemory('erp_plot_set');
        if isempty(erp_plot_set_label)
            erp_plot_set_label =1;
        end
        if ~erp_plot_set_label
            S_selectedERP =  estudioworkingmemory('selectederpstudio');
            if isempty(S_selectedERP)
                S_selectedERP =  observe_ERPDAT.CURRENTERP;
                S_erpbinchan = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,S_selectedERP);
                estudioworkingmemory('geterpbinchan',S_erpbinchan.geterpbinchan);
                estudioworkingmemory('geterpplot',S_erpbinchan.geterpplot);
            end
            
            S_binchan =  estudioworkingmemory('geterpbinchan');
            Select_index = S_binchan.Select_index;
            S_erpplot = estudioworkingmemory('geterpplot');
            plotops_erp.timet_auto.Value = 1; % 2B
            plotops_erp.timet_low.String = num2str(S_erpplot.timet_low(Select_index));
            plotops_erp.timet_low.Enable = 'off';
            plotops_erp.timet_high.String = num2str(S_erpplot.timet_high(Select_index));
            plotops_erp.timet_high.Enable =  'off';
            try
                plotops_erp.timet_step.String =  num2str(S_erpplot.timet_step(Select_index));
            catch
                plotops_erp.timet_step.String = num2str(floor((S_erpplot.max(Select_index)-S_erpplot.min(Select_index))/5));
            end
            plotops_erp.timet_step.Enable = 'off';
            
            
            plotops_erp.yscale_auto.Value = 1;
            
            plotops_erp.yscale_change.String = num2str(S_erpplot.yscale(Select_index));
            plotops_erp.yscale_change.Enable = 'off';
            plotops_erp.min_vspacing.String = num2str(S_erpplot.min_vspacing(Select_index));
            plotops_erp.min_vspacing.Enable = 'off';
            plotops_erp.fill_screen.Value = S_erpplot.fill(Select_index);
            ColumnNum =  estudioworkingmemory('EStudioColumnNum');
            if isempty(ColumnNum) || numel(ColumnNum)~=1
                ColumnNum =1;
            end
            
            plotops_erp.columns.String = num2str(ColumnNum); % 2E Plot_column
            plotops_erp.columns.Enable = 'on';
            
            if  S_erpplot.Positive_up(Select_index) == -1
                plotops_erp.positive_up.Value =0;
                plotops_erp.negative_up.Value = 1;
            else
                plotops_erp.positive_up.Value = 1;
                plotops_erp.negative_up.Value = 0;
            end
            
            try
                Bin_chan_overlay =  S_binchan.bins_chans(1);
            catch
                Bin_chan_overlay = 0;
            end
            
            set(gui_erp_plot.pagesel,'Value',Bin_chan_overlay+1);
        end
        estudioworkingmemory('erp_plot_set',0);
        
        %%---------------Deative the setting for the number of columns when activing ERP viewer
        try
            S_ws_geterpvalues =  estudioworkingmemory('geterpvalues');
            S_ws_viewer = S_ws_geterpvalues.Viewer;
        catch
            S_ws_viewer = 'off';
        end
        if strcmp(S_ws_viewer,'on')
            plotops_erp.columns.Enable = 'off';
        end
        
    end


%%----------------------Setting for bin overlay chan---------------------
    function pageviewchanged(src,~)
        S_selectedERP =  estudioworkingmemory('selectederpstudio');
        if isempty(S_selectedERP)
            S_selectedERP =  observe_ERPDAT.CURRENTERP;
            S_erpbinchan = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,S_selectedERP);
            estudioworkingmemory('geterpbinchan',S_erpbinchan.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpbinchan.geterpplot);
            estudioworkingmemory('selectederpstudio',S_selectedERP);
        end
        
        S_binchan =  estudioworkingmemory('geterpbinchan');
        Select_index = S_binchan.Select_index;
        
        if src.Value == 1
            if S_binchan.checked_ERPset_Index(1) ==1 || S_binchan.checked_ERPset_Index(2) ==2
                S_binchan.bins_chans(Select_index) = 0;
            else
                S_binchan.bins_chans(1:end) = 0;
            end
        else
            if S_binchan.checked_ERPset_Index(1) ==1 || S_binchan.checked_ERPset_Index(2) ==2
                S_binchan.bins_chans(Select_index) = 1;
            else
                S_binchan.bins_chans(1:end) = 1;
            end
        end
        
        estudioworkingmemory('geterpbinchan',S_binchan);
    end




%%--------------Reset the parameters for plotting panel--------------------
    function plot_erp_reset(~,~)
        erpworkingmemory('f_ERP_proces_messg','Plot Setting>Reset');
        observe_ERPDAT.Process_messg =1;
        
        S_selectedERP =  estudioworkingmemory('selectederpstudio');
        if isempty(S_selectedERP)
            try
                S_selectedERP =  observe_ERPDAT.CURRENTERP;
                S_erpbinchan = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,S_selectedERP);
                estudioworkingmemory('selectederpstudio',S_selectedERP);
                estudioworkingmemory('geterpbinchan',S_erpbinchan.geterpbinchan);
                estudioworkingmemory('geterpplot',S_erpbinchan.geterpplot);
            catch
                return;
            end
        else
            S_erpbinchan = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,S_selectedERP);
            estudioworkingmemory('geterpbinchan',S_erpbinchan.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpbinchan.geterpplot);
        end
        gui_erp_plot.pagesel.Value = 1;
        
        
        erp_plot_set_label =  estudioworkingmemory('erp_plot_set');
        if isempty(erp_plot_set_label)
            erp_plot_set_label =1;
        end
        if ~erp_plot_set_label
            S_selectedERP =  estudioworkingmemory('selectederpstudio');
            if isempty(S_selectedERP)
                S_selectedERP =  observe_ERPDAT.CURRENTERP;
                S_erpbinchan = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,S_selectedERP);
                estudioworkingmemory('geterpbinchan',S_erpbinchan.geterpbinchan);
                estudioworkingmemory('geterpplot',S_erpbinchan.geterpplot);
            end
            
            S_binchan =  estudioworkingmemory('geterpbinchan');
            Select_index = S_binchan.Select_index;
            S_erpplot = estudioworkingmemory('geterpplot');
            plotops_erp.timet_auto.Value = 1; % 2B
            plotops_erp.timet_low.String = num2str(S_erpplot.timet_low(Select_index));
            plotops_erp.timet_low.Enable = 'off';
            plotops_erp.timet_high.String = num2str(S_erpplot.timet_high(Select_index));
            plotops_erp.timet_high.Enable =  'off';
            try
                plotops_erp.timet_step.String =  num2str(S_erpplot.timet_step(Select_index));
            catch
                plotops_erp.timet_step.String = num2str(floor((S_erpplot.max(Select_index)-S_erpplot.min(Select_index))/5));
            end
            plotops_erp.timet_step.Enable = 'off';
            plotops_erp.yscale_auto.Value = 1;
            plotops_erp.yscale_change.String = num2str(S_erpplot.yscale(Select_index));
            plotops_erp.yscale_change.Enable = 'off';
            plotops_erp.min_vspacing.String = num2str(S_erpplot.min_vspacing(Select_index));
            plotops_erp.min_vspacing.Enable = 'off';
            plotops_erp.fill_screen.Value = S_erpplot.fill(Select_index);
            ColumnNum =  estudioworkingmemory('EStudioColumnNum');
            if isempty(ColumnNum) || numel(ColumnNum)~=1
                ColumnNum =1;
            end
            
            plotops_erp.columns.String = num2str(ColumnNum); % 2E Plot_column
            plotops_erp.columns.Enable = 'on';
            
            if  S_erpplot.Positive_up(Select_index) == -1
                plotops_erp.positive_up.Value =0;
                plotops_erp.negative_up.Value = 1;
            else
                plotops_erp.positive_up.Value = 1;
                plotops_erp.negative_up.Value = 0;
            end
            
            try
                Bin_chan_overlay =  S_binchan.bins_chans(1);
            catch
                Bin_chan_overlay = 0;
            end
            
            set(gui_erp_plot.pagesel,'Value',Bin_chan_overlay+1);
        end
        estudioworkingmemory('erp_plot_set',0);
        
        %%---------------Deative the setting for the number of columns when activing ERP viewer
        try
            S_ws_geterpvalues =  estudioworkingmemory('geterpvalues');
            S_ws_viewer = S_ws_geterpvalues.Viewer;
        catch
            S_ws_viewer = 'off';
        end
        if strcmp(S_ws_viewer,'on')
            plotops_erp.columns.Enable = 'off';
        end
        
        observe_ERPDAT.Process_messg =2;
        
        %%plot the waveforms
        try
            S_ws_geterpvalues =  estudioworkingmemory('geterpvalues');
            S_ws_viewer = S_ws_geterpvalues.Viewer;
            
            moption = S_ws_geterpvalues.Measure;
            latency = S_ws_geterpvalues.latency;
            if strcmp(S_ws_viewer,'on')
                if isempty(moption)
                    msgboxText = ['EStudio says: User must specify a type of measurement.'];
                    title = 'EStudio: ERP measurement tool- "Measurement type".';
                    errorfound(msgboxText, title);
                    return;
                end
                if ismember_bc2({moption}, {'instabl', 'areazt','areazp','areazn', 'nintegz'})
                    if length(latency)~=1
                        msgboxText = ['ERPLAB says: ' moption ' only needs 1 latency value.'];
                        title = 'EStudio: ERP measurement tool- "Measurement type".';
                        errorfound(msgboxText, title);
                        return;
                    end
                else
                    if length(latency)~=2
                        msgboxText = ['EStudio says: ' moption ' needs 2 latency values.'];
                        title = 'EStudio: ERP measurement tool- "Measurement type".';
                        errorfound(msgboxText, title);
                        return;
                    else
                        if latency(1)>=latency(2)
                            msgboxText = ['For latency range, lower time limit must be on the left.\n'...
                                'Additionally, lower time limit must be at least 1/samplerate seconds lesser than the higher one.'];
                            title = 'EStudio: ERP measurement tool-Measurement window';
                            errorfound(sprintf(msgboxText), title);
                            return
                        end
                    end
                end
                f_redrawERP_mt_viewer();
            else
                f_redrawERP();
            end
        catch
            f_redrawERP();
        end
        
    end


%------------Apply current parameters in plotting panel to the selected ERPset---------
    function plot_erp_apply(~,~)
        erpworkingmemory('f_ERP_proces_messg','Plot Setting>Apply');
        observe_ERPDAT.Process_messg =1;
        
        estudioworkingmemory('geterpplot',S_erpplot);
        estudioworkingmemory('erp_plot_set',1);
        ColumnNum = str2num(plotops_erp.columns.String);
        if isempty(ColumnNum) && numel(ColumnNum)~=1
            ColumnNum = 1;
        end
        estudioworkingmemory('EStudioColumnNum',ColumnNum);
        %         observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
        observe_ERPDAT.Process_messg =2;
        
        %%plot the waveforms
        try
            S_ws_geterpvalues =  estudioworkingmemory('geterpvalues');
            S_ws_viewer = S_ws_geterpvalues.Viewer;
            
            moption = S_ws_geterpvalues.Measure;
            latency = S_ws_geterpvalues.latency;
            if strcmp(S_ws_viewer,'on')
                if isempty(moption)
                    msgboxText = ['EStudio says: User must specify a type of measurement.'];
                    title = 'EStudio: ERP measurement tool- "Measurement type".';
                    errorfound(msgboxText, title);
                    return;
                end
                if ismember_bc2({moption}, {'instabl', 'areazt','areazp','areazn', 'nintegz'})
                    if length(latency)~=1
                        msgboxText = ['ERPLAB says: ' moption ' only needs 1 latency value.'];
                        title = 'EStudio: ERP measurement tool- "Measurement type".';
                        errorfound(msgboxText, title);
                        return;
                    end
                else
                    if length(latency)~=2
                        msgboxText = ['EStudio says: ' moption ' needs 2 latency values.'];
                        title = 'EStudio: ERP measurement tool- "Measurement type".';
                        errorfound(msgboxText, title);
                        return;
                    else
                        if latency(1)>=latency(2)
                            msgboxText = ['For latency range, lower time limit must be on the left.\n'...
                                'Additionally, lower time limit must be at least 1/samplerate seconds lesser than the higher one.'];
                            title = 'EStudio: ERP measurement tool-Measurement window';
                            errorfound(sprintf(msgboxText), title);
                            return
                        end
                    end
                end
                f_redrawERP_mt_viewer();
            else
                f_redrawERP();
            end
        catch
            f_redrawERP();
        end
    end

end