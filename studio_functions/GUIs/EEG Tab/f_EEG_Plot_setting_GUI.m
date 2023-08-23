%%This function is used to set the plotting wave for EEG


% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Agust 2023


function varargout = f_EEG_Plot_setting_GUI(varargin)

global observe_EEGDAT;
addlistener(observe_EEGDAT,'EEG_Process_messg_change',@EEG_Process_messg_change);
addlistener(observe_EEGDAT,'eeg_twopanels_change',@eeg_twopanels_change);
addlistener(observe_EEGDAT,'Count_currentEEG_change',@Count_currentEEG_change);

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
            'Callback', @disp_orgdata,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','on','Value',1);
        EStduio_gui_EEG_plotset.disp_orgdata.KeyPressFcn = @eeg_plotset_presskey;
        EStduio_gui_EEG_plotset.disp_IC = uicontrol('Parent',EStduio_gui_EEG_plotset.datatype_title, 'Style', 'checkbox', 'String', 'Display ICs',...
            'Callback', @disp_IC,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','on','Value',0);
        EStduio_gui_EEG_plotset.disp_IC.KeyPressFcn = @eeg_plotset_presskey;
        EEG_plotset{1} = EStduio_gui_EEG_plotset.disp_orgdata.Value;
        EEG_plotset{2} = EStduio_gui_EEG_plotset.disp_IC.Value;
        %%-----------------General settings--------------------------------
        %%time range
        EStduio_gui_EEG_plotset.time_scales_title = uiextras.HBox('Parent', EStduio_gui_EEG_plotset.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_plotset.timerange = uicontrol('Parent',EStduio_gui_EEG_plotset.time_scales_title , 'Style', 'text', 'String', 'Time Rnage:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_plotset.WinLength_edit = uicontrol('Parent',EStduio_gui_EEG_plotset.time_scales_title , 'Style', 'edit', 'String', '5',...
            'Callback', @WinLength_edit,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        EStduio_gui_EEG_plotset.WinLength_edit.KeyPressFcn = @eeg_plotset_presskey;
        EEG_plotset{3} = str2num(EStduio_gui_EEG_plotset.timerange.String);
        %%vertical scale
        EStduio_gui_EEG_plotset.v_scale = uicontrol('Parent',EStduio_gui_EEG_plotset.time_scales_title, 'Style', 'text', 'String', 'Vertical Scale:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_plotset.v_scale_edit = uicontrol('Parent',EStduio_gui_EEG_plotset.time_scales_title , 'Style', 'edit', 'String', '50',...
            'Callback', @vscale_edit,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        set(EStduio_gui_EEG_plotset.time_scales_title,'Sizes',[70 50 80 50]);
        EStduio_gui_EEG_plotset.v_scale_edit.KeyPressFcn = @eeg_plotset_presskey;
        EEG_plotset{4} = str2num(EStduio_gui_EEG_plotset.v_scale_edit.String);
        %%Channel labels  name/number?
        EStduio_gui_EEG_plotset.chanlab_title = uiextras.HBox('Parent', EStduio_gui_EEG_plotset.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_plotset.chanlab_text = uicontrol('Parent',EStduio_gui_EEG_plotset.chanlab_title, 'Style', 'text', 'String', 'Channel Labels:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_plotset.chanlab_name = uicontrol('Parent',EStduio_gui_EEG_plotset.chanlab_title, 'Style', 'radiobutton', 'String', 'Name',...
            'Callback', @chanlab_name,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','on','Value',1);
        EStduio_gui_EEG_plotset.chanlab_name.KeyPressFcn = @eeg_plotset_presskey;
        EStduio_gui_EEG_plotset.chanlab_numb = uicontrol('Parent',EStduio_gui_EEG_plotset.chanlab_title, 'Style', 'radiobutton', 'String', 'Number',...
            'Callback', @chanlab_numb,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','on','Value',0);
        EStduio_gui_EEG_plotset.chanlab_numb.KeyPressFcn = @eeg_plotset_presskey;
        EEG_plotset{5} = EStduio_gui_EEG_plotset.chanlab_name.Value;
        set(EStduio_gui_EEG_plotset.chanlab_title,'Sizes',[100 60 70]);
        
        
        %%Remove DC or display event?
        EStduio_gui_EEG_plotset.removedc_event_title = uiextras.HBox('Parent', EStduio_gui_EEG_plotset.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_plotset.rem_DC = uicontrol('Parent',EStduio_gui_EEG_plotset.removedc_event_title, 'Style', 'checkbox', 'String', 'Remove DC',...
            'Callback', @rm_DC,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','on','Value',0);
        EStduio_gui_EEG_plotset.rem_DC.KeyPressFcn = @eeg_plotset_presskey;
        EStduio_gui_EEG_plotset.disp_event = uicontrol('Parent',EStduio_gui_EEG_plotset.removedc_event_title, 'Style', 'checkbox', 'String', 'Events',...
            'Callback', @disp_event,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','on','Value',1);
        EStduio_gui_EEG_plotset.disp_event.KeyPressFcn = @eeg_plotset_presskey;
        EEG_plotset{6} = EStduio_gui_EEG_plotset.rem_DC.Value;
        EEG_plotset{7} = EStduio_gui_EEG_plotset.disp_event.Value;
        
        %%stack or norm?
        EStduio_gui_EEG_plotset.stack_norm_title = uiextras.HBox('Parent', EStduio_gui_EEG_plotset.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_plotset.disp_stack = uicontrol('Parent',EStduio_gui_EEG_plotset.stack_norm_title, 'Style', 'checkbox', 'String', 'Stack',...
            'Callback', @disp_stack,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','on','Value',0);
        EStduio_gui_EEG_plotset.disp_stack.KeyPressFcn = @eeg_plotset_presskey;
        EStduio_gui_EEG_plotset.disp_norm = uicontrol('Parent',EStduio_gui_EEG_plotset.stack_norm_title, 'Style', 'checkbox', 'String', 'Norm',...
            'Callback', @disp_norm,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','on','Value',0);
        EStduio_gui_EEG_plotset.disp_norm.KeyPressFcn = @eeg_plotset_presskey;
        EEG_plotset{8} = EStduio_gui_EEG_plotset.disp_stack.Value;
        EEG_plotset{9} = EStduio_gui_EEG_plotset.disp_norm.Value;
        
        %%----------------cancel and apply---------------------------------
        EStduio_gui_EEG_plotset.reset_apply = uiextras.HBox('Parent',EStduio_gui_EEG_plotset.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', EStduio_gui_EEG_plotset.reset_apply); % 1A
        EStduio_gui_EEG_plotset.plotset_cancel = uicontrol('Style', 'pushbutton','Parent',EStduio_gui_EEG_plotset.reset_apply,...
            'String','Cancel','callback',@plot_eeg_cancel,'FontSize',FonsizeDefault);
        
        uiextras.Empty('Parent', EStduio_gui_EEG_plotset.reset_apply); % 1A
        EStduio_gui_EEG_plotset.plot_apply = uicontrol('Style', 'pushbutton','Parent',EStduio_gui_EEG_plotset.reset_apply,...
            'String','Apply','callback',@eeg_plotset_apply,'FontSize',FonsizeDefault);
        EStduio_gui_EEG_plotset.plot_apply.KeyPressFcn=  @eeg_plotset_presskey;
        uiextras.Empty('Parent', EStduio_gui_EEG_plotset.reset_apply); % 1A
        set(EStduio_gui_EEG_plotset.reset_apply, 'Sizes',[10,-1,30,-1,10]);
        
        set(EStduio_gui_EEG_plotset.DataSelBox,'Sizes',[25 25 25 25 25 25]);
        estudioworkingmemory('EEG_plotset',EEG_plotset);
    end



%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%


%%------------------------Display original data: on------------------------
    function disp_orgdata(Source,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_twopanels = observe_EEGDAT.eeg_twopanels+1;%%call the functions from the other panel
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
            observe_EEGDAT.eeg_twopanels = observe_EEGDAT.eeg_twopanels+1;%%call the functions from the other panel
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
            observe_EEGDAT.eeg_twopanels = observe_EEGDAT.eeg_twopanels+1;%%call the functions from the other panel
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
            observe_EEGDAT.eeg_twopanels = observe_EEGDAT.eeg_twopanels+1;%%call the functions from the other panel
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
            observe_EEGDAT.eeg_twopanels = observe_EEGDAT.eeg_twopanels+1;%%call the functions from the other panel
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
            observe_EEGDAT.eeg_twopanels = observe_EEGDAT.eeg_twopanels+1;%%call the functions from the other panel
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
            observe_EEGDAT.eeg_twopanels = observe_EEGDAT.eeg_twopanels+1;%%call the functions from the other panel
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
            observe_EEGDAT.eeg_twopanels = observe_EEGDAT.eeg_twopanels+1;%%call the functions from the other panel
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
            observe_EEGDAT.eeg_twopanels = observe_EEGDAT.eeg_twopanels+1;%%call the functions from the other panel
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
            observe_EEGDAT.eeg_twopanels = observe_EEGDAT.eeg_twopanels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_plotset',1);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_plot_set.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [1 1 1];
    end

%%-------------------Cancel------------------------------------------------
    function plot_eeg_cancel(~,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_twopanels = observe_EEGDAT.eeg_twopanels+1;%%call the functions from the other panel
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
        try ICFlag = EEG_plotset{2};catch ICFlag= 1; end
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
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_twopanels = observe_EEGDAT.eeg_twopanels+1;%%call the functions from the other panel
        end
        ChangeFlag =  estudioworkingmemory('EEGTab_plotset');
        if ChangeFlag~=1
            return;
        end
        
        MessageViewer= char(strcat('Plot Setting > Apply'));
        erpworkingmemory('f_EEG_proces_messg',MessageViewer);
        observe_EEGDAT.EEG_messg=1;
        
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
        estudioworkingmemory('EEG_plotset',EEG_plotset);
        
        estudioworkingmemory('EEGTab_plotset',0);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [1 1 1];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [0 0 0];
        EStudio_box_EEG_plot_set.TitleColor= [0.0500    0.2500    0.5000];
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [1 1 1];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [0 0 0];
        
        
        f_redrawEEG_Wave_Viewer();
        observe_EEGDAT.EEG_messg=2;
    end




%%--------Settting will be modified if the selected was changed------------
    function Count_currentEEG_change(~,~)
        if observe_EEGDAT.Count_currentEEG ~=3
            return;
        end
        EEGIN = observe_EEGDAT.EEG;
        if isempty(EEGIN.icachansind)
            EStduio_gui_EEG_plotset.disp_ic_on.Value=0;
            EStduio_gui_EEG_plotset.disp_ic_off.Value=1;
            EStduio_gui_EEG_plotset.disp_ic_on.Enable = 'off';
            EStduio_gui_EEG_plotset.disp_ic_off.Enable = 'off';
            %%<Insert warning message here>
        else
            EStduio_gui_EEG_plotset.disp_ic_on.Enable = 'on';
            EStduio_gui_EEG_plotset.disp_ic_off.Enable = 'on';
            
        end
    end



%%-------------------------------------------------------------------------
%%Automatically saving the changed parameters for the current panel if the
%%user change parameters for the other panels.
%%-------------------------------------------------------------------------
    function eeg_twopanels_change(~,~)
        if observe_EEGDAT.eeg_twopanels==0
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