%%This function is used to set the plotting wave for EEG


% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Agust 2023


function varargout = f_EEG_Plot_setting_GUI(varargin)

global observe_EEGDAT;
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);

%---------------------------Initialize parameters------------------------------------

EStduio_gui_EEG_plotset = struct();

%-----------------------------Name the title----------------------------------------------
% global EStudio_box_EEG_plot_set;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    EStudio_box_EEG_plot_set = uiextras.BoxPanel('Parent', fig, 'Title', ' Plot Settings', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    EStudio_box_EEG_plot_set = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Plot Settings', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    EStudio_box_EEG_plot_set = uiextras.BoxPanel('Parent', varargin{1}, 'Title', ' Plot Settings', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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

drawui_plot_set_eeg(FonsizeDefault)
varargout{1} = EStudio_box_EEG_plot_set;

    function drawui_plot_set_eeg(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        EStduio_gui_EEG_plotset.DataSelBox = uiextras.VBox('Parent', EStudio_box_EEG_plot_set,'BackgroundColor',ColorB_def);
        
        %%display original data?
        EStduio_gui_EEG_plotset.datatype_title = uiextras.HBox('Parent', EStduio_gui_EEG_plotset.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_plotset.disp_orgdata = uicontrol('Parent',EStduio_gui_EEG_plotset.datatype_title, 'Style', 'checkbox', 'String', 'Display original data',...
            'Callback', @disp_orgdata,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off','Value',1);
        EStduio_gui_EEG_plotset.disp_orgdata.KeyPressFcn = @eeg_plotset_presskey;
        EStduio_gui_EEG_plotset.disp_IC = uicontrol('Parent',EStduio_gui_EEG_plotset.datatype_title, 'Style', 'checkbox', 'String', 'Display ICs',...
            'Callback', @disp_IC,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off','Value',0);
        EStduio_gui_EEG_plotset.disp_IC.KeyPressFcn = @eeg_plotset_presskey;
        set(EStduio_gui_EEG_plotset.datatype_title,'Sizes',[150 90]);
        
        EEG_plotset{1} = EStduio_gui_EEG_plotset.disp_orgdata.Value;
        EEG_plotset{2} = EStduio_gui_EEG_plotset.disp_IC.Value;
        %%-----------------General settings--------------------------------
        %%time range
        EStduio_gui_EEG_plotset.time_scales_title = uiextras.HBox('Parent', EStduio_gui_EEG_plotset.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_plotset.timerange = uicontrol('Parent',EStduio_gui_EEG_plotset.time_scales_title , 'Style', 'text', 'String', 'Time Range:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_plotset.WinLength_edit = uicontrol('Parent',EStduio_gui_EEG_plotset.time_scales_title , 'Style', 'edit', 'String', '5',...
            'Callback', @WinLength_edit,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
        EStduio_gui_EEG_plotset.WinLength_edit.KeyPressFcn = @eeg_plotset_presskey;
        EEG_plotset{3} = str2num(EStduio_gui_EEG_plotset.timerange.String);
        %%vertical scale
        EStduio_gui_EEG_plotset.v_scale = uicontrol('Parent',EStduio_gui_EEG_plotset.time_scales_title, 'Style', 'text', 'String', 'Vertical Scale:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_plotset.v_scale_edit = uicontrol('Parent',EStduio_gui_EEG_plotset.time_scales_title , 'Style', 'edit', 'String', '50',...
            'Callback', @vscale_edit,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
        set(EStduio_gui_EEG_plotset.time_scales_title,'Sizes',[70 50 80 50]);
        EStduio_gui_EEG_plotset.v_scale_edit.KeyPressFcn = @eeg_plotset_presskey;
        EEG_plotset{4} = str2num(EStduio_gui_EEG_plotset.v_scale_edit.String);
        %%Channel labels  name/number?
        EStduio_gui_EEG_plotset.chanlab_title = uiextras.HBox('Parent', EStduio_gui_EEG_plotset.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_plotset.chanlab_text = uicontrol('Parent',EStduio_gui_EEG_plotset.chanlab_title, 'Style', 'text', 'String', 'Channel Labels:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_plotset.chanlab_name = uicontrol('Parent',EStduio_gui_EEG_plotset.chanlab_title, 'Style', 'radiobutton', 'String', 'Name',...
            'Callback', @chanlab_name,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off','Value',1);
        EStduio_gui_EEG_plotset.chanlab_name.KeyPressFcn = @eeg_plotset_presskey;
        EStduio_gui_EEG_plotset.chanlab_numb = uicontrol('Parent',EStduio_gui_EEG_plotset.chanlab_title, 'Style', 'radiobutton', 'String', 'Number',...
            'Callback', @chanlab_numb,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off','Value',0);
        EStduio_gui_EEG_plotset.chanlab_numb.KeyPressFcn = @eeg_plotset_presskey;
        EEG_plotset{5} = EStduio_gui_EEG_plotset.chanlab_name.Value;
        set(EStduio_gui_EEG_plotset.chanlab_title,'Sizes',[100 60 70]);
        
        
        %%Remove DC or display event?
        EStduio_gui_EEG_plotset.removedc_event_title = uiextras.HBox('Parent', EStduio_gui_EEG_plotset.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_plotset.rem_DC = uicontrol('Parent',EStduio_gui_EEG_plotset.removedc_event_title, 'Style', 'checkbox', 'String', 'Remove DC',...
            'Callback', @rm_DC,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off','Value',0);
        EStduio_gui_EEG_plotset.rem_DC.KeyPressFcn = @eeg_plotset_presskey;
        EStduio_gui_EEG_plotset.disp_event = uicontrol('Parent',EStduio_gui_EEG_plotset.removedc_event_title, 'Style', 'checkbox', 'String', 'Events',...
            'Callback', @disp_event,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off','Value',1);
        EStduio_gui_EEG_plotset.disp_event.KeyPressFcn = @eeg_plotset_presskey;
        EEG_plotset{6} = EStduio_gui_EEG_plotset.rem_DC.Value;
        EEG_plotset{7} = EStduio_gui_EEG_plotset.disp_event.Value;
        
        %%stack or norm?
        EStduio_gui_EEG_plotset.stack_norm_title = uiextras.HBox('Parent', EStduio_gui_EEG_plotset.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_plotset.disp_stack = uicontrol('Parent',EStduio_gui_EEG_plotset.stack_norm_title, 'Style', 'checkbox', 'String', 'Stack',...
            'Callback', @disp_stack,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off','Value',0);
        EStduio_gui_EEG_plotset.disp_stack.KeyPressFcn = @eeg_plotset_presskey;
        EStduio_gui_EEG_plotset.disp_norm = uicontrol('Parent',EStduio_gui_EEG_plotset.stack_norm_title, 'Style', 'checkbox', 'String', 'Norm',...
            'Callback', @disp_norm,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off','Value',0);
        EStduio_gui_EEG_plotset.disp_norm.KeyPressFcn = @eeg_plotset_presskey;
        EEG_plotset{8} = EStduio_gui_EEG_plotset.disp_stack.Value;
        EEG_plotset{9} = EStduio_gui_EEG_plotset.disp_norm.Value;
        
        
        %%channel order
        EStduio_gui_EEG_plotset.chanorder_title = uiextras.HBox('Parent',EStduio_gui_EEG_plotset.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',EStduio_gui_EEG_plotset.chanorder_title,'String','Channel Order (for plotting only):',...
            'FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        EStduio_gui_EEG_plotset.chanorder_no_title = uiextras.HBox('Parent',EStduio_gui_EEG_plotset.DataSelBox,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_plotset.chanorder_number = uicontrol('Parent',EStduio_gui_EEG_plotset.chanorder_no_title, 'Style', 'radiobutton', 'String', 'Default order',...
            'Callback', @chanorder_number,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off','Value',1);
        EStduio_gui_EEG_plotset.chanorder_number.KeyPressFcn=  @eeg_plotset_presskey;
        EStduio_gui_EEG_plotset.chanorder_front = uicontrol('Parent',EStduio_gui_EEG_plotset.chanorder_no_title, 'Style', 'radiobutton', 'String', 'Front-back/left-right',...
            'Callback', @chanorder_front,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off','Value',0);
        EStduio_gui_EEG_plotset.chanorder_front.KeyPressFcn=  @eeg_plotset_presskey;
        set(EStduio_gui_EEG_plotset.chanorder_no_title,'Sizes',[120 -1]);
        %%channel order-custom
        EStduio_gui_EEG_plotset.chanorder_custom_title = uiextras.HBox('Parent',EStduio_gui_EEG_plotset.DataSelBox,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_plotset.chanorder_custom = uicontrol('Parent',EStduio_gui_EEG_plotset.chanorder_custom_title, 'Style', 'radiobutton', 'String', 'Custom',...
            'Callback', @chanorder_custom,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off','Value',0);
        EStduio_gui_EEG_plotset.chanorder_custom.KeyPressFcn=  @eeg_plotset_presskey;
        EStduio_gui_EEG_plotset.chanorder_custom_exp = uicontrol('Parent',EStduio_gui_EEG_plotset.chanorder_custom_title, 'Style', 'pushbutton', 'String', 'Export',...
            'Callback', @chanorder_custom_exp,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
        EStduio_gui_EEG_plotset.chanorder_custom_imp = uicontrol('Parent',EStduio_gui_EEG_plotset.chanorder_custom_title, 'Style', 'pushbutton', 'String', 'Import',...
            'Callback', @chanorder_custom_imp,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
        
        EEG_plotset{10} = 1;
        EEG_plotset{11} = [];
        
        %%----------------cancel and apply---------------------------------
        EStduio_gui_EEG_plotset.reset_apply = uiextras.HBox('Parent',EStduio_gui_EEG_plotset.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', EStduio_gui_EEG_plotset.reset_apply); % 1A
        EStduio_gui_EEG_plotset.plotset_cancel = uicontrol('Style', 'pushbutton','Parent',EStduio_gui_EEG_plotset.reset_apply,...
            'String','Cancel','callback',@plot_eeg_cancel,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
        
        uiextras.Empty('Parent', EStduio_gui_EEG_plotset.reset_apply); % 1A
        EStduio_gui_EEG_plotset.plot_apply = uicontrol('Style', 'pushbutton','Parent',EStduio_gui_EEG_plotset.reset_apply,...
            'String','Apply','callback',@eeg_plotset_apply,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
        EStduio_gui_EEG_plotset.plot_apply.KeyPressFcn=  @eeg_plotset_presskey;
        uiextras.Empty('Parent', EStduio_gui_EEG_plotset.reset_apply); % 1A
        set(EStduio_gui_EEG_plotset.reset_apply, 'Sizes',[10,-1,30,-1,10]);
        
        set(EStduio_gui_EEG_plotset.DataSelBox,'Sizes',[25 25 25 25 25 20 25 25 30]);
        estudioworkingmemory('EEG_plotset',EEG_plotset);
        
        EStduio_gui_EEG_plotset.chanorder{1,1} = [];
        EStduio_gui_EEG_plotset.chanorder{1,2} = '';
        estudioworkingmemory('EEGTab_plotset',0);
    end



%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%------------------------Display original data: on------------------------
    function disp_orgdata(Source,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_plotset',1);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_plot_set.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [1 1 1];
    end


%%------------------------Display original data: off-----------------------
    function disp_IC(Source,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_plotset',1);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_plot_set.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [1 1 1];
    end


%%--------------------Time range-------------------------------------------
    function WinLength_edit(Source,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_plotset',1);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_plot_set.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [1 1 1];
        
        Winlength = str2num(Source.String);
        if ~isempty(observe_EEGDAT.EEG)
            [chaNum,sampleNum,trialNum]=size(observe_EEGDAT.EEG.data);
            Frames = sampleNum*trialNum;
            if observe_EEGDAT.EEG.trials>1 % time in second or in trials
                multiplier_winleg = size(observe_EEGDAT.EEG.data,2);
            else
                multiplier_winleg = observe_EEGDAT.EEG.srate;
            end
            if isempty(Winlength)|| Winlength<=0 ||  (Winlength>floor(Frames/multiplier_winleg))
                Winlength = floor(Frames/multiplier_winleg);
                %%<insert warnign message here>
            end
        else
            if isempty(Winlength)|| Winlength<=0 || numel(Winlength)~=1
                Winlength = 5;
                %%<insert warnign message here>
            end
        end
        Source.String = num2str(Winlength);
    end

%%-----------------------------Vertical Scale------------------------------
    function vscale_edit(Source,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('EEGTab_plotset',1);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_plot_set.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [1 1 1];
        vscale_Value = str2num(Source.String);
        
        if isempty(vscale_Value) || numel(vscale_Value)~=1 || vscale_Value<=0
            Source.String = '50';
            %%insert warning message here if needed.
        end
    end

%%------------------------Remove DC on-------------------------------------
    function rm_DC(Source,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_plotset',1);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_plot_set.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [1 1 1];
    end



%%-------------------------channel label: name-----------------------------
    function chanlab_name(~,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_plotset',1);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_plot_set.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [1 1 1];
        
        EStduio_gui_EEG_plotset.chanlab_name.Value=1;
        EStduio_gui_EEG_plotset.chanlab_numb.Value =0;
    end


%%-------------------------channel label: number---------------------------
    function chanlab_numb(~,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_plotset',1);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_plot_set.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [1 1 1];
        
        EStduio_gui_EEG_plotset.chanlab_name.Value=0;
        EStduio_gui_EEG_plotset.chanlab_numb.Value =1;
    end



%%---------------------------Events:on-------------------------------------
    function disp_event(Source,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_plotset',1);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_plot_set.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [1 1 1];
    end


%%--------------------------Stack: on--------------------------------------
    function disp_stack(Source,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('EEGTab_plotset',1);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_plot_set.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [1 1 1];
    end


%%--------------------------Stack: off-------------------------------------
    function disp_norm(Source,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_plotset',1);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_plot_set.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [1 1 1];
    end

%%----------------------channel order-number-------------------------------
    function chanorder_number(~,~)
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_plotset',1);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_plot_set.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [1 1 1];
        EStduio_gui_EEG_plotset.chanorder_number.Value=1;
        EStduio_gui_EEG_plotset.chanorder_front.Value=0;
        EStduio_gui_EEG_plotset.chanorder_custom.Value=0;
        EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'off';
        EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'off';
    end

%%-----------------channel order-front-back/left-right---------------------
    function chanorder_front(~,~)
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_plotset',1);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_plot_set.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [1 1 1];
        EStduio_gui_EEG_plotset.chanorder_number.Value=0;
        EStduio_gui_EEG_plotset.chanorder_front.Value=1;
        EStduio_gui_EEG_plotset.chanorder_custom.Value=0;
        EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'off';
        EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'off';
        try
            chanlocs = observe_EEGDAT.EEG.chanlocs;
            if isempty(chanlocs(1).X) &&  isempty(chanlocs(1).Y)
                MessageViewer= char(strcat('Plot Setting > Channel order>Front-back/left-right:please do "chan locations" first in EEGLAB Tool panel.'));
                erpworkingmemory('f_EEG_proces_messg',MessageViewer);
                observe_EEGDAT.eeg_panel_message=4;
                EStduio_gui_EEG_plotset.chanorder_number.Value=1;
                EStduio_gui_EEG_plotset.chanorder_front.Value=0;
                EStduio_gui_EEG_plotset.chanorder_custom.Value=0;
                EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'off';
                EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'off';
            end
        catch
            MessageViewer= char(strcat('Plot Setting > Channel order>Front-back/left-right: It seems that chanlocs for the current EEG is empty and please check it out'));
            erpworkingmemory('f_EEG_proces_messg',MessageViewer);
            observe_EEGDAT.eeg_panel_message=4;
            EStduio_gui_EEG_plotset.chanorder_number.Value=1;
            EStduio_gui_EEG_plotset.chanorder_front.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'off';
            EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'off';
        end
    end

%%----------------------channel order-custom-------------------------------
    function chanorder_custom(~,~)
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_plotset',1);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_plot_set.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [1 1 1];
        EStduio_gui_EEG_plotset.chanorder_number.Value=0;
        EStduio_gui_EEG_plotset.chanorder_front.Value=0;
        EStduio_gui_EEG_plotset.chanorder_custom.Value=1;
        EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'on';
        EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'on';
        
        if ~isfield(observe_EEGDAT.EEG,'chanlocs') || isempty(observe_EEGDAT.EEG.chanlocs)
            MessageViewer= char(strcat('Plot Setting > Channel order>Front-back/left-right: It seems that chanlocs for the current EEG is empty and please check it out'));
            erpworkingmemory('f_EEG_proces_messg',MessageViewer);
            observe_EEGDAT.eeg_panel_message=4;
            EStduio_gui_EEG_plotset.chanorder_number.Value=1;
            EStduio_gui_EEG_plotset.chanorder_front.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'off';
            EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'off';
            return;
        end
        
    end

%%---------------------export channel orders-------------------------------
    function chanorder_custom_exp(~,~)
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        
        if ~isempty(messgStr) %%&& eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        if ~isfield(observe_EEGDAT.EEG,'chanlocs') || isempty(observe_EEGDAT.EEG.chanlocs)
            MessageViewer= char(strcat('Plot Setting > Channel order>Custom>Export: It seems that chanlocs for the current EEG is empty and please check it out'));
            erpworkingmemory('f_EEG_proces_messg',MessageViewer);
            observe_EEGDAT.eeg_panel_message=4;
            EStduio_gui_EEG_plotset.chanorder_number.Value=1;
            EStduio_gui_EEG_plotset.chanorder_front.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'off';
            EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'off';
            return;
        end
        
        MessageViewer= char(strcat('Plot Setting > Channel order>Custom>Export'));
        erpworkingmemory('f_EEG_proces_messg',MessageViewer);
        observe_EEGDAT.eeg_panel_message=1;
        
        if isempty(EStduio_gui_EEG_plotset.chanorder{1,1}) || isempty(EStduio_gui_EEG_plotset.chanorder{1,2})
            chanOrders = [1:observe_EEGDAT.EEG.nbchan];
            [eloc, labels, theta, radius, indices] = readlocs(observe_EEGDAT.EEG.chanlocs);
        else
            chanOrders =  EStduio_gui_EEG_plotset.chanorder{1,1} ;
            labels=  EStduio_gui_EEG_plotset.chanorder{1,2};
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
        namedef ='Channel_order_eeg';
        [erpfilename, erppathname, indxs] = uiputfile({'*.tsv'}, ...
            ['Export EEG channel order (for plotting only)'],...
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
                formatSpec = strcat(formatSpec,'%s',32);
            end
        end
        formatSpec = strcat(formatSpec,'\n');
        columName = {'','Column1','Column2'};
        fprintf(fileID,'%s\t %s\t %s\n',columName{1,:});
        for row = 1:numel(chanOrders)
            rowdata = cell(1,3);
            rowdata{1,1} = char(['Row',num2str(row)]);
            for jj = 1:2
                rowdata{1,jj+1} = Data{row,jj};
            end
            fprintf(fileID,formatSpec,rowdata{1,:});
        end
        fclose(fileID);
        disp(['A new EEG channel order file was created at <a href="matlab: open(''' erpFilename ''')">' erpFilename '</a>'])
        
        MessageViewer= char(strcat('Plot Setting > Channel order>Custom>Export'));
        erpworkingmemory('f_EEG_proces_messg',MessageViewer);
        observe_EEGDAT.eeg_panel_message=2;
    end

%%-------------------------import channel orders---------------------------
    function chanorder_custom_imp(~,~)
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_plotset',1);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_plot_set.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [1 1 1];
        
        
        if ~isfield(observe_EEGDAT.EEG,'chanlocs') || isempty(observe_EEGDAT.EEG.chanlocs)
            MessageViewer= char(strcat('Plot Setting > Channel order>Custom>Import: It seems that chanlocs for the current EEG is empty and please check it out'));
            erpworkingmemory('f_EEG_proces_messg',MessageViewer);
            observe_EEGDAT.eeg_panel_message=4;
            EStduio_gui_EEG_plotset.chanorder_number.Value=1;
            EStduio_gui_EEG_plotset.chanorder_front.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'off';
            EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'off';
            return;
        end
        
        %%import data chan orders
        [eloc, labels, theta, radius, indices] = readlocs(observe_EEGDAT.EEG.chanlocs);
        
        [erpfilename, erppathname, indxs] = uigetfile({'*.tsv'}, ...
            ['Import EEG channel order (for plotting only)'],...
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
            EStduio_gui_EEG_plotset.chanorder{1,1}=[];
            EStduio_gui_EEG_plotset.chanorder{1,2} = '';
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
            erpworkingmemory('f_EEG_proces_messg',MessageViewer);
            observe_EEGDAT.eeg_panel_message=4;
            EStduio_gui_EEG_plotset.chanorder_number.Value=1;
            EStduio_gui_EEG_plotset.chanorder_front.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'off';
            EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'off';
            return;
        end
        
        if numel(chanorders1)~= observe_EEGDAT.EEG.nbchan
            MessageViewer= strcat(['Plot Setting > Channel order>Custom>Import: The number of the defined chan orders must be',32,num2str(observe_EEGDAT.EEG.nbchan)]);
            erpworkingmemory('f_EEG_proces_messg',MessageViewer);
            observe_EEGDAT.eeg_panel_message=4;
            EStduio_gui_EEG_plotset.chanorder_number.Value=1;
            EStduio_gui_EEG_plotset.chanorder_front.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'off';
            EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'off';
            return;
        end
        
        [C,IA]= ismember_bc2(chanlabes,labels);
        if any(IA==0)
            MessageViewer= strcat(['Plot Setting > Channel order>Custom>Import: The channel labels must be the same to the current EEG']);
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
            erpworkingmemory('f_EEG_proces_messg',MessageViewer);
            observe_EEGDAT.eeg_panel_message=4;
            EStduio_gui_EEG_plotset.chanorder_number.Value=1;
            EStduio_gui_EEG_plotset.chanorder_front.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'off';
            EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'off';
            return;
        end
        
        if ~isempty(IA)
            IA = unique(IA);
        end
        if numel(IA)~=observe_EEGDAT.EEG.nbchan
            MessageViewer= strcat(['Plot Setting > Channel order>Custom>Import: There are some replicated channel labels']);
            erpworkingmemory('f_EEG_proces_messg',MessageViewer);
            observe_EEGDAT.eeg_panel_message=4;
            EStduio_gui_EEG_plotset.chanorder_number.Value=1;
            EStduio_gui_EEG_plotset.chanorder_front.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'off';
            EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'off';
            return;
        end
        EStduio_gui_EEG_plotset.chanorder{1,1}=chanorders;
        EStduio_gui_EEG_plotset.chanorder{1,2} = chanlabes;
        
    end



%%-------------------Cancel------------------------------------------------
    function plot_eeg_cancel(~,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        ChangeFlag =  estudioworkingmemory('EEGTab_plotset');
        if ChangeFlag~=1
            return;
        end
        
        EEG_plotset = estudioworkingmemory('EEG_plotset');
        
        %%display original data?
        try OrigFlag = EEG_plotset{1};catch OrigFlag= 1; end
        if isempty(OrigFlag) || numel(OrigFlag)~=1 || (OrigFlag~=0 && OrigFlag~=1)
            OrigFlag=1;
        end
        EStduio_gui_EEG_plotset.disp_orgdata.Value = OrigFlag;
        
        %%display IC?
        try ICFlag = EEG_plotset{2};catch ICFlag= 0; end
        if isempty(ICFlag) || numel(ICFlag)~=1 || (ICFlag~=0 && ICFlag~=1)
            ICFlag=0;
        end
        EStduio_gui_EEG_plotset.disp_IC.Value = ICFlag;
        if isempty(observe_EEGDAT.EEG) || isempty(observe_EEGDAT.EEG.icachansind)
            EStduio_gui_EEG_plotset.disp_IC.Value = 0;
            EStduio_gui_EEG_plotset.disp_IC.Enable = 'off';
        else
            EStduio_gui_EEG_plotset.disp_IC.Enable = 'on';
        end
        
        %%Displayed Window length (the defalut is 5s/trials )?
        try Winlength = EEG_plotset{3}; catch  Winlength =5; end
        if isempty(Winlength) || Winlength<=0
            Winlength=5;
            EEG_plotset{3}=5;
        end
        if ~isempty(observe_EEGDAT.EEG)
            [chaNum,sampleNum,trialNum]=size(observe_EEGDAT.EEG.data);
            Frames = sampleNum*trialNum;
            if observe_EEGDAT.EEG.trials>1 % time in second or in trials
                multiplier_winleg = size(observe_EEGDAT.EEG.data,2);
            else
                multiplier_winleg = observe_EEGDAT.EEG.srate;
            end
            if isempty(Winlength)|| Winlength<=0 ||  (Winlength>floor(Frames/multiplier_winleg)) || numel(Winlength)~=1
                Winlength = floor(Frames/multiplier_winleg);
                EEG_plotset{3} = floor(Frames/multiplier_winleg);
            end
        end
        EStduio_gui_EEG_plotset.WinLength_edit.String = num2str(Winlength);
        
        %%vertical scale
        try VScale = EEG_plotset{4}; catch  VScale =50; end
        if isempty(VScale) || numel(VScale)~=1 || VScale<=0
            VScale=50;
            EEG_plotset{4} =50;
        end
        EStduio_gui_EEG_plotset.v_scale_edit.String = num2str(VScale);
        
        %%Channel labels  name/number?
        try ChandispFlag = EEG_plotset{5}; catch  ChandispFlag =1; end
        if isempty(ChandispFlag) || numel(ChandispFlag)~=1 || (ChandispFlag~=0 && ChandispFlag~=1)
            ChandispFlag = 1;
            EEG_plotset{5}=1;
        end
        EStduio_gui_EEG_plotset.chanlab_name.Value =ChandispFlag;
        EStduio_gui_EEG_plotset.chanlab_numb.Value =~ChandispFlag;
        
        %%Remove DC
        try RMean = EEG_plotset{6}; catch  RMean =0; end
        if isempty(RMean) || numel(RMean)~=1 || (RMean~=0 && RMean~=1)
            RMean=0;
            EEG_plotset{6}=0;
        end
        EStduio_gui_EEG_plotset.rem_DC.Value=RMean;
        
        %%display event?
        try EventFlag = EEG_plotset{7}; catch  EventFlag =1; end
        if isempty(EventFlag) || numel(EventFlag)~=1 || (EventFlag~=0 && EventFlag~=1)
            EventFlag=1;
            EEG_plotset{7}=1;
        end
        EStduio_gui_EEG_plotset.disp_event.Value = EventFlag;
        
        %%Stack?
        try StackFlag = EEG_plotset{8}; catch  StackFlag =0; end
        if isempty(StackFlag) || numel(StackFlag)~=1 || (StackFlag~=0 && StackFlag~=1)
            StackFlag=0;
            EEG_plotset{8}=0;
        end
        EStduio_gui_EEG_plotset.disp_stack.Value = StackFlag;
        
        %%Norm?
        try NormFlag = EEG_plotset{9}; catch  NormFlag =0; end
        if isempty(NormFlag) || numel(NormFlag)~=1 || (NormFlag~=0 && NormFlag~=1)
            NormFlag=0;
            EEG_plotset{9}=0;
        end
        EStduio_gui_EEG_plotset.disp_norm.Value = NormFlag;
        
        try chanOrder = EEG_plotset{10}; catch  chanOrder =1; end
        if chanOrder==2
            EStduio_gui_EEG_plotset.chanorder_number.Value=0;
            EStduio_gui_EEG_plotset.chanorder_front.Value=1;
            EStduio_gui_EEG_plotset.chanorder_custom.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'off';
            EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'off';
            EEG_plotset{10}=2;
            EStduio_gui_EEG_plotset.chanorder{1,1} = [];
            EStduio_gui_EEG_plotset.chanorder{1,2} = '';
        elseif chanOrder==3
            EStduio_gui_EEG_plotset.chanorder_number.Value=0;
            EStduio_gui_EEG_plotset.chanorder_front.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom.Value=1;
            EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'on';
            EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'on';
            EEG_plotset{10}=3;
        else
            EStduio_gui_EEG_plotset.chanorder_number.Value=1;
            EStduio_gui_EEG_plotset.chanorder_front.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'off';
            EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'off';
            EEG_plotset{10}=1;
            EStduio_gui_EEG_plotset.chanorder{1,1} = [];
            EStduio_gui_EEG_plotset.chanorder{1,2} = '';
        end
        
        
        estudioworkingmemory('EEG_plotset',EEG_plotset);
        estudioworkingmemory('EEGTab_plotset',0);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [1 1 1];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [0 0 0];
        EStudio_box_EEG_plot_set.TitleColor= [0.0500    0.2500    0.5000];
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [1 1 1];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [0 0 0];
    end

%%-------------------------------Apply-------------------------------------
    function eeg_plotset_apply(~,~)
        if isempty(observe_EEGDAT.EEG) %%if current eeg is empty
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        ChangeFlag =  estudioworkingmemory('EEGTab_plotset');
        if ChangeFlag~=1
            return;
        end
        
        MessageViewer= char(strcat('Plot Setting > Apply'));
        erpworkingmemory('f_EEG_proces_messg',MessageViewer);
        observe_EEGDAT.eeg_panel_message=1;
        
        %%display original data?
        EEG_plotset{1}= EStduio_gui_EEG_plotset.disp_orgdata.Value;
        %%display IC?
        if isempty(observe_EEGDAT.EEG) || isempty(observe_EEGDAT.EEG.icachansind)
            EEG_plotset{2}=0;
        else
            EEG_plotset{2}= EStduio_gui_EEG_plotset.disp_IC.Value;
        end
        %%Displayed Window length (the defalut is 5s/trials )?
        Winlength = str2num(EStduio_gui_EEG_plotset.WinLength_edit.String);
        if isempty(Winlength) || Winlength<=0
            Winlength=5;
        end
        if ~isempty(observe_EEGDAT.EEG)
            [chaNum,sampleNum,trialNum]=size(observe_EEGDAT.EEG.data);
            Frames = sampleNum*trialNum;
            if observe_EEGDAT.EEG.trials>1 % time in second or in trials
                multiplier_winleg = size(observe_EEGDAT.EEG.data,2);
            else
                multiplier_winleg = observe_EEGDAT.EEG.srate;
            end
            if isempty(Winlength)|| Winlength<=0 ||  (Winlength>floor(Frames/multiplier_winleg)) || numel(Winlength)~=1
                Winlength = floor(Frames/multiplier_winleg);
                EStduio_gui_EEG_plotset.WinLength_edit.String = num2str(Winlength);
            end
        end
        EEG_plotset{3}=Winlength;
        %%vertical scale
        VScale= str2num(EStduio_gui_EEG_plotset.v_scale_edit.String);
        if isempty(VScale) || numel(VScale)~=1 || VScale<=0
            VScale=50;
            EStduio_gui_EEG_plotset.v_scale_edit.String = num2str(VScale);
        end
        EEG_plotset{4} =VScale;
        %%Channel labels  name/number?
        EEG_plotset{5}= EStduio_gui_EEG_plotset.chanlab_name.Value;
        %%Remove DC
        EEG_plotset{6}=EStduio_gui_EEG_plotset.rem_DC.Value;
        %%display event?
        EEG_plotset{7}= EStduio_gui_EEG_plotset.disp_event.Value;
        %%Stack?
        EEG_plotset{8}= EStduio_gui_EEG_plotset.disp_stack.Value;
        %%Norm?
        EEG_plotset{9}=EStduio_gui_EEG_plotset.disp_norm.Value;
        %%channel orders
        [eloc, labels, theta, radius, indices] = readlocs(observe_EEGDAT.EEG.chanlocs);
        if  EStduio_gui_EEG_plotset.chanorder_number.Value==1
            EEG_plotset{10} = 1;
            EEG_plotset{11}= {1:length(labels),labels};
            EStduio_gui_EEG_plotset.chanorder{1,1} = 1:length(labels);
            EStduio_gui_EEG_plotset.chanorder{1,2} = labels;
        elseif EStduio_gui_EEG_plotset.chanorder_front.Value==1
            EEG_plotset{10} = 2;
            chanindexnew = f_estudio_chan_frontback_left_right(observe_EEGDAT.EEG.chanlocs);
            if ~isempty(chanindexnew)
                EEG_plotset{11} = {1:numel(chanindexnew),labels(chanindexnew)};
                EStduio_gui_EEG_plotset.chanorder{1,1} = 1:numel(chanindexnew);
                EStduio_gui_EEG_plotset.chanorder{1,2} = labels(chanindexnew);
            else
                EEG_plotset{11}= {1:length(labels),labels};
                EStduio_gui_EEG_plotset.chanorder{1,1} = 1:length(labels);
                EStduio_gui_EEG_plotset.chanorder{1,2} = labels;
            end
        elseif EStduio_gui_EEG_plotset.chanorder_custom.Value==1
            EEG_plotset{10} = 3;
            if isempty(EStduio_gui_EEG_plotset.chanorder{1,1})
                EEG_plotset{11}= {1:length(labels),labels};
                MessageViewer= char(strcat('Plot Setting > Apply:There were no custom-defined chan orders and we therefore used the default orders'));
                erpworkingmemory('f_EEG_proces_messg',MessageViewer);
                observe_EEGDAT.eeg_panel_message=4;
                EStduio_gui_EEG_plotset.chanorder_number.Value=1;
                EStduio_gui_EEG_plotset.chanorder_front.Value=0;
                EStduio_gui_EEG_plotset.chanorder_custom.Value=0;
                EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'off';
                EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'off';
            else
                EEG_plotset{11} = EStduio_gui_EEG_plotset.chanorder;
            end
        end
        
        estudioworkingmemory('EEG_plotset',EEG_plotset);
        
        estudioworkingmemory('EEGTab_plotset',0);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [1 1 1];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [0 0 0];
        EStudio_box_EEG_plot_set.TitleColor= [0.0500    0.2500    0.5000];
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [1 1 1];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [0 0 0];
        MessageViewer= char(strcat('Plot Setting > Apply'));
        erpworkingmemory('f_EEG_proces_messg',MessageViewer);
        f_redrawEEG_Wave_Viewer();
        observe_EEGDAT.eeg_panel_message=2;
    end

%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=3
            return;
        end
        if isempty(observe_EEGDAT.EEG)
            Enableflag = 'off';
        else
            Enableflag = 'on';
        end
        
        EStduio_gui_EEG_plotset.disp_orgdata.Enable = Enableflag;
        EStduio_gui_EEG_plotset.disp_IC.Enable = Enableflag;
        EStduio_gui_EEG_plotset.WinLength_edit.Enable = Enableflag;
        EStduio_gui_EEG_plotset.v_scale_edit.Enable = Enableflag;
        EStduio_gui_EEG_plotset.chanlab_name.Enable = Enableflag;
        EStduio_gui_EEG_plotset.chanlab_numb.Enable = Enableflag;
        EStduio_gui_EEG_plotset.rem_DC.Enable = Enableflag;
        EStduio_gui_EEG_plotset.disp_event.Enable = Enableflag;
        EStduio_gui_EEG_plotset.disp_stack.Enable = Enableflag;
        EStduio_gui_EEG_plotset.disp_norm.Enable = Enableflag;
        EStduio_gui_EEG_plotset.chanorder_number.Enable = Enableflag;
        EStduio_gui_EEG_plotset.chanorder_front.Enable = Enableflag;
        EStduio_gui_EEG_plotset.chanorder_custom.Enable = Enableflag;
        EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = Enableflag;
        EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = Enableflag;
        EStduio_gui_EEG_plotset.plotset_cancel.Enable = Enableflag;
        EStduio_gui_EEG_plotset.plot_apply.Enable = Enableflag;
        if strcmp(Enableflag,'on')
            if EStduio_gui_EEG_plotset.chanorder_custom.Value ==1
                Enableflag = 'on';
            else
                Enableflag = 'off';
            end
            EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = Enableflag;
            EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = Enableflag;
        end
        observe_EEGDAT.count_current_eeg=4;
    end

%%-------------------------------------------------------------------------
%%Automatically saving the changed parameters for the current panel if the
%%user change parameters for the other panels.
%%-------------------------------------------------------------------------
    function eeg_two_panels_change(~,~)
        if observe_EEGDAT.eeg_two_panels==0
            return;
        end
        ChangeFlag =  estudioworkingmemory('EEGTab_plotset');
        if ChangeFlag~=1
            return;
        end
        eeg_plotset_apply();
        estudioworkingmemory('EEGTab_plotset',0);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [1 1 1];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [0 0 0];
        EStudio_box_EEG_plot_set.TitleColor= [0.0500    0.2500    0.5000];
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [1 1 1];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [0 0 0];
    end


%%--------------press return to execute "Apply"----------------------------
    function eeg_plotset_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('EEGTab_plotset');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            eeg_plotset_apply();
            estudioworkingmemory('EEGTab_plotset',0);
            EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [1 1 1];
            EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [0 0 0];
            EStudio_box_EEG_plot_set.TitleColor= [0.0500    0.2500    0.5000];
            EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [1 1 1];
            EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [0 0 0];
        else
            return;
        end
    end
end