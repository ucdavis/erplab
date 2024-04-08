%%This function is used to set the plotting wave for EEG


% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Agust 2023 && 2024


function varargout = f_EEG_Plot_setting_GUI(varargin)

global observe_EEGDAT;
global EStudio_gui_erp_totl;
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
addlistener(observe_EEGDAT,'Reset_eeg_panel_change',@Reset_eeg_panel_change);
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
        EStduio_gui_EEG_plotset.disp_orgdata = uicontrol('Parent',EStduio_gui_EEG_plotset.datatype_title, 'Style', 'checkbox', 'String', 'Display chans',...
            'Callback', @disp_orgdata,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off','Value',1);
        EStduio_gui_EEG_plotset.disp_orgdata.KeyPressFcn = @eeg_plotset_presskey;
        
        EStduio_gui_EEG_plotset.v_scale = uicontrol('Parent',EStduio_gui_EEG_plotset.datatype_title, 'Style', 'text', 'String', 'Vertical Scale:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_plotset.v_scale_edit = uicontrol('Parent',EStduio_gui_EEG_plotset.datatype_title , 'Style', 'edit', 'String', '50',...
            'Callback', @vscale_edit,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
        set(EStduio_gui_EEG_plotset.datatype_title,'Sizes',[120 80 -1]);
        EEG_plotset{1} = EStduio_gui_EEG_plotset.disp_orgdata.Value;
        
        EStduio_gui_EEG_plotset.datatype_title1 = uiextras.HBox('Parent', EStduio_gui_EEG_plotset.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_plotset.disp_IC = uicontrol('Parent',EStduio_gui_EEG_plotset.datatype_title1, 'Style', 'checkbox', 'String', 'Display ICs',...
            'Callback', @disp_IC,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off','Value',0);
        EStduio_gui_EEG_plotset.disp_IC.KeyPressFcn = @eeg_plotset_presskey;
        
        EStduio_gui_EEG_plotset.v_scale_ic = uicontrol('Parent',EStduio_gui_EEG_plotset.datatype_title1, 'Style', 'text', 'String', 'Vertical Scale:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_plotset.v_scale_edit_ic = uicontrol('Parent',EStduio_gui_EEG_plotset.datatype_title1 , 'Style', 'edit', 'String', '20',...
            'Callback', @vscale_edit_ic,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
        set(EStduio_gui_EEG_plotset.datatype_title1,'Sizes',[120 80 -1]);
        
        EEG_plotset{2} = EStduio_gui_EEG_plotset.disp_IC.Value;
        
        EStduio_gui_EEG_plotset.datatype_title2 = uiextras.HBox('Parent', EStduio_gui_EEG_plotset.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uicontrol('Parent',EStduio_gui_EEG_plotset.datatype_title2, 'Style', 'text', 'String', 'Buffer at top & bottom:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_plotset.buffer_top_bom = uicontrol('Parent',EStduio_gui_EEG_plotset.datatype_title2, 'Style', 'edit', 'String', '100',...
            'Callback', @buffer_top_bom,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
        EStduio_gui_EEG_plotset.buffer_top_bom.KeyPressFcn = @eeg_plotset_presskey;
        uicontrol('Parent',EStduio_gui_EEG_plotset.datatype_title2, 'Style', 'text', 'String', '%',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(EStduio_gui_EEG_plotset.datatype_title2, 'Sizes',[130 -1 20]);
        EEG_plotset{12} = str2num(EStduio_gui_EEG_plotset.buffer_top_bom.String);
        
        %%-----------------General settings--------------------------------
        %%time range
        EStduio_gui_EEG_plotset.time_scales_title = uiextras.HBox('Parent', EStduio_gui_EEG_plotset.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_plotset.timerange = uicontrol('Parent',EStduio_gui_EEG_plotset.time_scales_title , 'Style', 'text', 'String', 'Time Range:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_plotset.WinLength_edit = uicontrol('Parent',EStduio_gui_EEG_plotset.time_scales_title , 'Style', 'edit', 'String', '5',...
            'Callback', @WinLength_edit,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off');
        EStduio_gui_EEG_plotset.WinLength_edit.KeyPressFcn = @eeg_plotset_presskey;
        EEG_plotset{3} = str2num(EStduio_gui_EEG_plotset.timerange.String);
        
        uiextras.Empty('Parent',  EStduio_gui_EEG_plotset.time_scales_title,'BackgroundColor',ColorB_def);
        set(EStduio_gui_EEG_plotset.time_scales_title,'Sizes',[70 80 -1]);
        
        EStduio_gui_EEG_plotset.v_scale_edit.KeyPressFcn = @eeg_plotset_presskey;
        EEG_plotset{4} = str2num(EStduio_gui_EEG_plotset.v_scale_edit.String);
        
        EEG_plotset{5} = str2num(EStduio_gui_EEG_plotset.v_scale_edit_ic.String);
        
        
        %%Remove DC or display event?
        EStduio_gui_EEG_plotset.removedc_event_title = uiextras.HBox('Parent', EStduio_gui_EEG_plotset.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_plotset.rem_DC = uicontrol('Parent',EStduio_gui_EEG_plotset.removedc_event_title, 'Style', 'checkbox', 'String', 'Remove DC',...
            'Callback', @rm_DC,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off','Value',1);
        EStduio_gui_EEG_plotset.rem_DC.KeyPressFcn = @eeg_plotset_presskey;
        EStduio_gui_EEG_plotset.disp_event = uicontrol('Parent',EStduio_gui_EEG_plotset.removedc_event_title, 'Style', 'checkbox', 'String', 'Show events',...
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
        EStduio_gui_EEG_plotset.chanorder_number = uicontrol('Parent',EStduio_gui_EEG_plotset.chanorder_no_title, 'Style', 'radiobutton', 'String', 'Default',...
            'Callback', @chanorder_number,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off','Value',1);
        EStduio_gui_EEG_plotset.chanorder_number.KeyPressFcn=  @eeg_plotset_presskey;
        EStduio_gui_EEG_plotset.chanorder_front = uicontrol('Parent',EStduio_gui_EEG_plotset.chanorder_no_title, 'Style', 'radiobutton', 'String', 'Simple 10/20 system order',...
            'Callback', @chanorder_front,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off','Value',0);
        EStduio_gui_EEG_plotset.chanorder_front.KeyPressFcn=  @eeg_plotset_presskey;
        set(EStduio_gui_EEG_plotset.chanorder_no_title,'Sizes',[80 -1]);
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
        
        set(EStduio_gui_EEG_plotset.DataSelBox,'Sizes',[25 25 25 25 25 25 20 25 25 30]);
        erpworkingmemory('EEG_plotset',EEG_plotset);
        
        EStduio_gui_EEG_plotset.chanorder{1,1} = [];
        EStduio_gui_EEG_plotset.chanorder{1,2} = '';
        erpworkingmemory('EEGTab_plotset',0);
    end


%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%------------------------Display original data: on------------------------
    function disp_orgdata(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('EEGTab_plotset',1);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_plot_set.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [1 1 1];
        if EStduio_gui_EEG_plotset.disp_orgdata.Value==0
            EStduio_gui_EEG_plotset.v_scale_edit.Enable = 'off';
        else
            EStduio_gui_EEG_plotset.v_scale_edit.Enable = 'on';
        end
    end

%%------------------------Display original data: off-----------------------
    function disp_IC(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('EEGTab_plotset',1);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_plot_set.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [1 1 1];
        if EStduio_gui_EEG_plotset.disp_IC.Value==1
            EStduio_gui_EEG_plotset.v_scale_edit_ic.Enable = 'on';
        else
            EStduio_gui_EEG_plotset.v_scale_edit_ic.Enable = 'off';
        end
    end

%%--------------------Time range-------------------------------------------
    function WinLength_edit(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('EEGTab_plotset',1);
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
                %                 msgboxText= char(strcat('Plot Setting > Time range:The input is invalid which should be a positive value and we therfore use the default one'));
                %                 titlNamerro = 'Warning for EEG Tab';
                %                 estudio_warning(msgboxText,titlNamerro);
            end
        else
            if isempty(Winlength)|| Winlength<=0 || numel(Winlength)~=1
                Winlength = 5;
                %                 msgboxText= char(strcat('Plot Setting > Time range:The input is invalid which should be a positive value and we therfore use the default one'));
                %                 titlNamerro = 'Warning for EEG Tab';
                %                 estudio_warning(msgboxText,titlNamerro);
            end
        end
        Source.String = num2str(Winlength);
    end

%%-----------------------------Vertical Scale for original data------------
    function vscale_edit(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('EEGTab_plotset',1);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_plot_set.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [1 1 1];
        vscale_Value = str2num(Source.String);
        
        if isempty(vscale_Value) || numel(vscale_Value)~=1 || any(vscale_Value<=0)
            Source.String = '50';
            msgboxText= char(strcat('Plot Setting > Vertical scale for original data:The input is invalid which should be a positive value and we therfore use the default one'));
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
    end


%%-----------------------------Vertical Scale for ICs----------------------
    function vscale_edit_ic(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('EEGTab_plotset',1);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_plot_set.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [1 1 1];
        vscale_Value = str2num(Source.String);
        if isempty(vscale_Value) || numel(vscale_Value)~=1 || any(vscale_Value<=0)
            Source.String = '20';
            msgboxText= char(strcat('Plot Setting > Vertical scale for ICs:The input is invalid which should be a positive value and we therfore use the default one'));
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
    end


%%--------------------------Buffer at top and bottom-----------------------
    function buffer_top_bom(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('EEGTab_plotset',1);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_plot_set.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [1 1 1];
        
        buffer_top_bomValue = str2num(EStduio_gui_EEG_plotset.buffer_top_bom.String);
        if isempty(buffer_top_bomValue) || numel(buffer_top_bomValue)~=1 || any(buffer_top_bomValue(:)<=0)
            EStduio_gui_EEG_plotset.buffer_top_bom.String = '100';
            msgboxText= char(strcat('Plot Setting > Buffer at top & bottom:The input is invalid which should be a positive value and we therfore use the default one'));
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
    end


%%------------------------Remove DC on-------------------------------------
    function rm_DC(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('EEGTab_plotset',1);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_plot_set.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [1 1 1];
    end


%%---------------------------Events:on-------------------------------------
    function disp_event(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('EEGTab_plotset',1);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_plot_set.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [1 1 1];
    end


%%--------------------------Stack: on--------------------------------------
    function disp_stack(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('EEGTab_plotset',1);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_plot_set.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [1 1 1];
    end


%%--------------------------Stack: off-------------------------------------
    function disp_norm(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('EEGTab_plotset',1);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_plot_set.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [1 1 1];
        if Source.Value==1
            EStduio_gui_EEG_plotset.v_scale_edit.String = '5';
            EStduio_gui_EEG_plotset.v_scale_edit_ic.String = '5';
        else
            EStduio_gui_EEG_plotset.v_scale_edit.String = '50';
            EStduio_gui_EEG_plotset.v_scale_edit_ic.String = '20';
        end
    end

%%----------------------channel order-number-------------------------------
    function chanorder_number(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('EEGTab_plotset',1);
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

%%-----------------channel order-Simple 10/20 order---------------------
    function chanorder_front(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('EEGTab_plotset',1);
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
                msgboxText= char(strcat('Plot Setting > Channel order>Simple 10/20 system order:please do "chan locations" first in EEGLAB Tool panel.'));
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                observe_EEGDAT.eeg_panel_message=4;
                EStduio_gui_EEG_plotset.chanorder_number.Value=1;
                EStduio_gui_EEG_plotset.chanorder_front.Value=0;
                EStduio_gui_EEG_plotset.chanorder_custom.Value=0;
                EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'off';
                EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'off';
                msgboxText = ['Plot Setting > Channel order>Simple 10/20 system order: please do "chan locations" first in EEGLAB Tool panel.'];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                return
            end
        catch
            EStduio_gui_EEG_plotset.chanorder_number.Value=1;
            EStduio_gui_EEG_plotset.chanorder_front.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'off';
            EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'off';
            msgboxText = ['Plot Setting > Channel order>Simple 10/20 system order: It seems that chanloc for the current EEG is empty and please check it out'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return
        end
        
        %%check if the channels belong to 10/20 system
        [eloc, labels, theta, radius, indices] = readlocs( observe_EEGDAT.EEG.chanlocs);
        [Simplabels,simplabelIndex,SamAll] =  Simplelabels(labels);
        count = 0;
        for ii = 1:length(Simplabels)
            [xpos,ypos]= find(simplabelIndex==ii);
            if ~isempty(ypos)  && numel(ypos)>= floor(length(observe_EEGDAT.EEG.chanlocs)/2)
                count = count+1;
                if count==1
                    msgboxText= char(strcat('Plot Setting > Channel order>Simple 10/20 system order: We cannot use the "Simple 10/20 system order" with your data because your channel labels do not appear to be standard 10/20 names.'));
                    titlNamerro = 'Warning for EEG Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    EStduio_gui_EEG_plotset.chanorder_number.Value=1;
                    EStduio_gui_EEG_plotset.chanorder_front.Value=0;
                    EStduio_gui_EEG_plotset.chanorder_custom.Value=0;
                    EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'off';
                    EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'off';
                    break;
                end
            end
        end
        
    end

%%----------------------channel order-custom-------------------------------
    function chanorder_custom(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('EEGTab_plotset',1);
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
            msgboxText= char(strcat('Plot Setting > Channel order>Simple 10/20 order: It seems that chanlocs for the current EEG is empty and please check it out'));
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            EStduio_gui_EEG_plotset.chanorder_number.Value=1;
            EStduio_gui_EEG_plotset.chanorder_front.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'off';
            EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'off';
            return;
        end
        
    end

%%---------------------export channel orders-------------------------------
    function chanorder_custom_exp(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        if ~isfield(observe_EEGDAT.EEG,'chanlocs') || isempty(observe_EEGDAT.EEG.chanlocs)
            msgboxText= char(strcat('Plot Setting > Channel order>Custom>Export: It seems that chanlocs for the current EEG is empty and please check it out'));
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
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
        Data = cell(length(chanOrders),1);
        for ii =1:length(chanOrders)
            try
                Data{ii,1} = [num2str(chanOrders(ii)),'.',32,labels{ii}];
            catch
            end
        end
        pathstr =  erpworkingmemory('EEG_save_folder');
        if isempty(pathstr)
            pathstr =cd;
        end
        namedef ='Channel_order_eeg';
        [erpfilename, erppathname, indxs] = uiputfile({'*.tsv'}, ...
            ['Export EEG channel order (for plotting only)'],...
            fullfile(pathstr,namedef));
        if isequal(erpfilename,0)
            return
        end
        
        [pathstr, erpfilename, ext] = fileparts(erpfilename) ;
        ext = '.tsv';
        erpFilename = char(strcat(erppathname,erpfilename,ext));
        fileID = fopen(erpFilename,'w+');
        
        formatSpec =['%s\t',32,'%s\n'];
        columName = {'Row','Channel'};
        fprintf(fileID,'%s\t %s\n',columName{1,:});
        for row = 1:numel(chanOrders)
            rowdata = cell(1,2);
            rowdata{1,1} = char(num2str(row));
            rowdata{1,2} = Data{row,1};
            fprintf(fileID,formatSpec,rowdata{1,:});
        end
        fclose(fileID);
        disp(['A new EEG channel order file was created at <a href="matlab: open(''' erpFilename ''')">' erpFilename '</a>'])
        
        MessageViewer= char(strcat('Plot Setting > Channel order>Custom>Export'));
        erpworkingmemory('f_EEG_proces_messg',MessageViewer);
        observe_EEGDAT.eeg_panel_message=2;
    end

%%-------------------------import channel orders---------------------------
    function chanorder_custom_imp(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('EEGTab_plotset',1);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_plot_set.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [1 1 1];
        
        
        if ~isfield(observe_EEGDAT.EEG,'chanlocs') || isempty(observe_EEGDAT.EEG.chanlocs)
            msgboxText= char(strcat('Plot Setting > Channel order>Custom>Import: It seems that chanlocs for the current EEG is empty and please check it out'));
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            EStduio_gui_EEG_plotset.chanorder_number.Value=1;
            EStduio_gui_EEG_plotset.chanorder_front.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'off';
            EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'off';
            return;
        end
        
        %%import data chan orders
        [eloc, labels, theta, radius, indices] = readlocs(observe_EEGDAT.EEG.chanlocs);
        
        [erpfilename, erppathname, indxs] = uigetfile({'*.tsv;*.txt'}, ...
            ['Import EEG channel order (for plotting only)'], 'MultiSelect','off');
        if isequal(erpfilename,0) || indxs~=1
            disp('User selected Cancel')
            return
        end
        
        [pathstr, erpfilename, ext] = fileparts(erpfilename) ;
        if ~strcmpi(ext,'.tsv') && ~strcmpi(ext,'.txt')
            msgboxText = ['Estudio: Plot Settings > Channel Order > Custom > Import: Either ",tsv" or ".txt" is allowed'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return
        end
        erpFilename = char(strcat(erppathname,erpfilename,ext));
        
        DataInput =  readtable(erpFilename, "FileType","text",'Delimiter', '\t');
        if isempty(DataInput)
            EStduio_gui_EEG_plotset.chanorder{1,1}=[];
            EStduio_gui_EEG_plotset.chanorder{1,2} = '';
        end
        DataInput = table2cell(DataInput);
        chanorders = [];
        chanlabes = [];
        DataInput = DataInput(:,2:end);
        chan_check = ones(length(labels),1);
        
        for ii = 1:size(DataInput,1)
            if isnumeric(DataInput{ii,1})
                chanorders(ii) = DataInput{ii,1};
                if chanorders(ii)>length(labels)
                    msgboxText = ['Plot Settings > Channel Order > Custom > Import: The defined channel order should be not more than',32,num2str(length(labels)),32,'for row',32,num2str(ii)];
                    titlNamerro = 'Warning for EEG Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    return
                end
                chanlabes{ii} = labels{chanorders(ii)};
                chan_check(ii) = DataInput{ii,1};
            elseif ischar(DataInput{ii,1})
                newStr = split(DataInput{ii,1},["."]);
                if length(newStr)~=2 || ~isnumeric(str2num(newStr{1,1})) || ~ischar(newStr{2,1})
                    msgboxText = ['Plot Settings > Channel Order > Custom > Import: The defined channel format for row',32,num2str(ii),32, 'should be:\n Row  Channel\n  1    1. FP1\n ...   ...\n'];
                    titlNamerro = 'Warning for EEG Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    return
                end
                chanorders(ii) = str2num(newStr{1,1});
                chan_check(ii) = f_chanlabel_check(newStr{2,1},labels);
                if chan_check(ii)==0
                    msgboxText = ['Plot Settings > Channel Order > Custom > Import: The defined channel format for row',32,num2str(ii),32,'can not match any of channel labels'];
                    titlNamerro = 'Warning for EEG Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    return
                end
                chanlabes{ii} = labels{chan_check(ii)};
            else
                msgboxText = ['Plot Settings > Channel Order > Custom > Import: The defined channel format should be either numberic or char for row',32,num2str(ii)];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                return
            end
        end
        chanorders1 = unique(chanorders);
        if any(chanorders(:)>length(labels)) || any(chanorders(:)<=0)
            msgboxText = ['Plot Settings > Channel Order > Custom > Import: It seems that some of the defined chan orders are invalid or replicated, please check the file'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            EStduio_gui_EEG_plotset.chanorder_number.Value=1;
            EStduio_gui_EEG_plotset.chanorder_front.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'off';
            EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'off';
            return;
        end
        
        if numel(chanorders1)~= observe_EEGDAT.EEG.nbchan
            msgboxText = ['Plot Settings > Channel Order > Custom > Import: The number of the defined chan orders must be',32,num2str(observe_EEGDAT.EEG.nbchan)];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            EStduio_gui_EEG_plotset.chanorder_number.Value=1;
            EStduio_gui_EEG_plotset.chanorder_front.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'off';
            EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'off';
            return;
        end
        
        if any(chan_check==0)
            msgboxText = ['Plot Settings > Channel Order > Custom > Import: The channel labels are not the same to those for the current EEG'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            [xpos,ypos] =find(chan_check==0);
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
            ypos = setdiff([1:length(labels)],setdiff(chan_check,0));
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
            EStduio_gui_EEG_plotset.chanorder_number.Value=1;
            EStduio_gui_EEG_plotset.chanorder_front.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom.Value=0;
            EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'off';
            EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'off';
            return;
        end
        
        if ~isempty(chan_check)
            chan_check = unique(chan_check);
        end
        if numel(chan_check)~=observe_EEGDAT.EEG.nbchan
            msgboxText = ['Plot Settings > Channel Order > Custom > Import: There are some replicated channel labels'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
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
    function plot_eeg_cancel(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=2
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        ChangeFlag =  erpworkingmemory('EEGTab_plotset');
        if ChangeFlag~=1
            return;
        end
        
        EEG_plotset = erpworkingmemory('EEG_plotset');
        
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
        
        %%vertical scale for original data
        try VScale = EEG_plotset{4}; catch  VScale =50; end
        if isempty(VScale) || numel(VScale)~=1 || VScale<=0
            VScale=50;
            EEG_plotset{4} =50;
        end
        EStduio_gui_EEG_plotset.v_scale_edit.String = num2str(VScale);
        
        %%vertical scale for ICs
        try VScale_ic = EEG_plotset{5}; catch  VScale =10; end
        if isempty(VScale_ic) || numel(VScale_ic)~=1 || any(VScale_ic(:)<=0)
            VScale_ic=20;
            EEG_plotset{5} =20;
        end
        EStduio_gui_EEG_plotset.v_scale_edit_ic.String = num2str(VScale_ic);
        
        %%Buffer at top and bottom
        try buffer_top_bom =  EEG_plotset{12};catch buffer_top_bom =100; end
        if isempty(buffer_top_bom) || numel(buffer_top_bom)~=1 ||any(buffer_top_bom(:)<=0)
            buffer_top_bom=100;  EEG_plotset{12} =100;
        end
        EStduio_gui_EEG_plotset.buffer_top_bom.String = num2str(buffer_top_bom);
        
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
        
        if EStduio_gui_EEG_plotset.disp_orgdata.Value==0
            EStduio_gui_EEG_plotset.v_scale_edit.Enable = 'off';
        else
            EStduio_gui_EEG_plotset.v_scale_edit.Enable = 'on';
        end
        if EStduio_gui_EEG_plotset.disp_IC.Value==1
            EStduio_gui_EEG_plotset.v_scale_edit_ic.Enable = 'on';
        else
            EStduio_gui_EEG_plotset.v_scale_edit_ic.Enable = 'off';
        end
        
        erpworkingmemory('EEG_plotset',EEG_plotset);
        erpworkingmemory('EEGTab_plotset',0);
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
        
        EEG_plotset{12} = str2num(EStduio_gui_EEG_plotset.buffer_top_bom.String);
        
        
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
        if isempty(VScale) || numel(VScale)~=1 || any(VScale(:)<=0)
            VScale=50;
            EStduio_gui_EEG_plotset.v_scale_edit.String = num2str(VScale);
        end
        EEG_plotset{4} =VScale;
        %%Channel labels  name/number?
        VScale_IC=  str2num(EStduio_gui_EEG_plotset.v_scale_edit_ic.String);
        if isempty(VScale_IC) || numel(VScale_IC)~=1 || any(VScale_IC(:)<=0)
            VScale_IC=20;
            EStduio_gui_EEG_plotset.v_scale_edit_ic.String= num2str(VScale_IC);
        end
        EEG_plotset{5}=VScale_IC;
        
        %%Remove DC
        EEG_plotset{6}=EStduio_gui_EEG_plotset.rem_DC.Value;
        %%display event?
        EEG_plotset{7}= EStduio_gui_EEG_plotset.disp_event.Value;
        %%Stack?
        EEG_plotset{8}= EStduio_gui_EEG_plotset.disp_stack.Value;
        %%Norm?
        EEG_plotset{9}=EStduio_gui_EEG_plotset.disp_norm.Value;
        %%channel orders
        try
            [eloc, labels, theta, radius, indices] = readlocs(observe_EEGDAT.EEG.chanlocs);
        catch
            labels = [];
        end
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
                MessageViewer= char(strcat('There were no custom-defined chan orders and we therefore used the default orders.'));
                titlNamerro = 'Warning for EEG Tab - Plot Setting > Apply';
                estudio_warning(MessageViewer,titlNamerro);
                EStduio_gui_EEG_plotset.chanorder_number.Value=1;
                EStduio_gui_EEG_plotset.chanorder_front.Value=0;
                EStduio_gui_EEG_plotset.chanorder_custom.Value=0;
                EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'off';
                EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'off';
            else
                EEG_plotset{11} = EStduio_gui_EEG_plotset.chanorder;
            end
        end
        
        erpworkingmemory('EEG_plotset',EEG_plotset);
        
        erpworkingmemory('EEGTab_plotset',0);
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
        EEGUpdate = erpworkingmemory('EEGUpdate');
        if isempty(EEGUpdate) || numel(EEGUpdate)~=1 || (EEGUpdate~=0 && EEGUpdate~=1)
            EEGUpdate = 0;  erpworkingmemory('EEGUpdate',0);
        end
        if isempty(observe_EEGDAT.EEG) || EEGUpdate==1
            Enableflag = 'off';
        else
            Enableflag = 'on';
            if size(observe_EEGDAT.EEG.data,3)==1
                EStduio_gui_EEG_plotset.timerange.String = 'Time Range:';
            else
                EStduio_gui_EEG_plotset.timerange.String = '# of Epochs:';
            end
        end
        
        EStduio_gui_EEG_plotset.disp_orgdata.Enable = Enableflag;
        EStduio_gui_EEG_plotset.disp_IC.Enable = Enableflag;
        EStduio_gui_EEG_plotset.buffer_top_bom.Enable = Enableflag;
        EStduio_gui_EEG_plotset.WinLength_edit.Enable = Enableflag;
        EStduio_gui_EEG_plotset.v_scale_edit.Enable = Enableflag;
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
        EStduio_gui_EEG_plotset.v_scale_edit_ic.Enable = Enableflag;
        if isempty(observe_EEGDAT.EEG) || EEGUpdate==1
            observe_EEGDAT.count_current_eeg=4;
            return;
        end
        EEG_plotset=  erpworkingmemory('EEG_plotset');
        if ~isempty(observe_EEGDAT.EEG) && ~isempty(observe_EEGDAT.EEG.icachansind) && EEGUpdate==0
            EStduio_gui_EEG_plotset.disp_IC.Enable = 'on';
            EStduio_gui_EEG_plotset.v_scale_edit_ic.Enable = 'on';
        else
            EStduio_gui_EEG_plotset.disp_IC.Enable = 'off';
            EStduio_gui_EEG_plotset.disp_IC.Value = 0;
            EStduio_gui_EEG_plotset.v_scale_edit_ic.Enable = 'off';
        end
        if EStduio_gui_EEG_plotset.disp_IC.Value==0
            EEG_plotset{2}=0;
        end
        if strcmp(Enableflag,'on')
            if EStduio_gui_EEG_plotset.chanorder_custom.Value ==1
                Enableflag = 'on';
            else
                Enableflag = 'off';
            end
            EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = Enableflag;
            EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = Enableflag;
        end
        if ~isempty(observe_EEGDAT.EEG) || EEGUpdate==0
            if observe_EEGDAT.EEG.trials>1
                EStduio_gui_EEG_plotset.rem_DC.Enable = 'off';
                EStduio_gui_EEG_plotset.rem_DC.Value=0;
            else
                EStduio_gui_EEG_plotset.rem_DC.Enable = 'on';
                if    EStudio_gui_erp_totl.EEG_transf ==1%%indicate if the users transfer Continous (or epoched) EEG to epoched (or cont.)
                    EStduio_gui_EEG_plotset.rem_DC.Value=1;
                    EEG_plotset{6}=1;
                end
            end
        end
        %%
        if ~isempty(observe_EEGDAT.EEG) && EEGUpdate==0
            EEGArray= erpworkingmemory('EEGArray');
            if isempty(EEGArray) || any(EEGArray(:) > length(observe_EEGDAT.ALLEEG))
                EEGArray = observe_EEGDAT.CURRENTSET;
                erpworkingmemory('EEGArray',EEGArray);
            end
            SetFlags =  check_chanlocs(observe_EEGDAT.ALLEEG(EEGArray));
            if any(SetFlags(:)==0)
                if  EStduio_gui_EEG_plotset.chanorder_number.Value==0
                    EStduio_gui_EEG_plotset.chanorder_number.Value=1;
                    EStduio_gui_EEG_plotset.chanorder_front.Value=0;
                    EStduio_gui_EEG_plotset.chanorder_custom.Value=0;
                    EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'off';
                    EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'off';
                    try
                        [eloc, labels, theta, radius, indices] = readlocs(observe_EEGDAT.EEG.chanlocs);
                    catch
                        labels = [];
                    end
                    EEG_plotset{10} = 1;
                    EEG_plotset{11}= {1:length(labels),labels};
                    EStduio_gui_EEG_plotset.chanorder{1,1} = 1:length(labels);
                    EStduio_gui_EEG_plotset.chanorder{1,2} = labels;
                end
            end
            if EStduio_gui_EEG_plotset.disp_orgdata.Value==0
                EStduio_gui_EEG_plotset.v_scale_edit.Enable = 'off';
            else
                EStduio_gui_EEG_plotset.v_scale_edit.Enable = 'on';
            end
            if EStduio_gui_EEG_plotset.disp_IC.Value==1
                EStduio_gui_EEG_plotset.v_scale_edit_ic.Enable = 'on';
            else
                EStduio_gui_EEG_plotset.v_scale_edit_ic.Enable = 'off';
            end
        end
        %%
        erpworkingmemory('EEG_plotset',EEG_plotset);
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
        ChangeFlag =  erpworkingmemory('EEGTab_plotset');
        if ChangeFlag~=1
            return;
        end
        eeg_plotset_apply();
        erpworkingmemory('EEGTab_plotset',0);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [1 1 1];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [0 0 0];
        EStudio_box_EEG_plot_set.TitleColor= [0.0500    0.2500    0.5000];
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [1 1 1];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [0 0 0];
    end


%%--------------press return to execute "Apply"----------------------------
    function eeg_plotset_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  erpworkingmemory('EEGTab_plotset');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            eeg_plotset_apply();
            erpworkingmemory('EEGTab_plotset',0);
            EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [1 1 1];
            EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [0 0 0];
            EStudio_box_EEG_plot_set.TitleColor= [0.0500    0.2500    0.5000];
            EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [1 1 1];
            EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [0 0 0];
        else
            return;
        end
    end

%%--------------Reset this panel with the default parameters---------------
    function Reset_eeg_panel_change(~,~)
        if observe_EEGDAT.Reset_eeg_paras_panel~=3
            return;
        end
        erpworkingmemory('EEGTab_plotset',0);
        EStduio_gui_EEG_plotset.plot_apply.BackgroundColor =  [1 1 1];
        EStduio_gui_EEG_plotset.plot_apply.ForegroundColor = [0 0 0];
        %         EStudio_box_EEG_plot_set.TitleColor= [0.0500    0.2500    0.5000];
        EStduio_gui_EEG_plotset.plotset_cancel.BackgroundColor =  [1 1 1];
        EStduio_gui_EEG_plotset.plotset_cancel.ForegroundColor = [0 0 0];
        
        %%display original data?
        EStduio_gui_EEG_plotset.disp_orgdata.Value=1;
        EEG_plotset{1}=1;
        %%display IC?
        EEG_plotset{2}=0;
        EStduio_gui_EEG_plotset.disp_IC.Value = 0;
        if isempty(observe_EEGDAT.EEG) || isempty(observe_EEGDAT.EEG.icachansind)
            EStduio_gui_EEG_plotset.disp_IC.Enable = 'off';
        else
            EStduio_gui_EEG_plotset.disp_IC.Enable = 'on';
        end
        EStduio_gui_EEG_plotset.buffer_top_bom.String = '100';
        EEG_plotset{12}=100;
        %%Displayed Window length (the defalut is 5s/trials )?
        EEG_plotset{3} =5;
        if ~isempty(observe_EEGDAT.EEG)
            Winlength =5;
            [chaNum,sampleNum,trialNum]=size(observe_EEGDAT.EEG.data);
            Frames = sampleNum*trialNum;
            if observe_EEGDAT.EEG.trials>1 % time in second or in trials
                multiplier_winleg = size(observe_EEGDAT.EEG.data,2);
            else
                multiplier_winleg = observe_EEGDAT.EEG.srate;
            end
            if isempty(Winlength)|| Winlength<=0 ||  (Winlength>floor(Frames/multiplier_winleg)) || numel(Winlength)~=1
                EEG_plotset{3} = floor(Frames/multiplier_winleg);
            end
            if EStduio_gui_EEG_plotset.disp_orgdata.Value==0
                EStduio_gui_EEG_plotset.v_scale_edit.Enable = 'off';
            else
                EStduio_gui_EEG_plotset.v_scale_edit.Enable = 'on';
            end
            if EStduio_gui_EEG_plotset.disp_IC.Value==1
                EStduio_gui_EEG_plotset.v_scale_edit_ic.Enable = 'on';
            else
                EStduio_gui_EEG_plotset.v_scale_edit_ic.Enable = 'off';
            end
        else
            EEG_plotset{3} =5;
        end
        EStduio_gui_EEG_plotset.WinLength_edit.String = num2str(EEG_plotset{3});
        %%vertical scale
        EEG_plotset{4} =50;
        EStduio_gui_EEG_plotset.v_scale_edit.String = num2str(EEG_plotset{4});
        EStduio_gui_EEG_plotset.v_scale_edit_ic.String = '20';
        EEG_plotset{5} = str2num(EStduio_gui_EEG_plotset.v_scale_edit_ic.String);
        %%Remove DC
        if ~isempty(observe_EEGDAT.EEG)
            if observe_EEGDAT.EEG.trials>1
                EEG_plotset{6}=0;
                EStduio_gui_EEG_plotset.rem_DC.Enable='off';
            else
                EEG_plotset{6}=1;
                EStduio_gui_EEG_plotset.rem_DC.Enable='on';
            end
        else
            EEG_plotset{6}=1;
        end
        EStduio_gui_EEG_plotset.rem_DC.Value=EEG_plotset{6};
        %%display event?
        EEG_plotset{7} =1;
        EStduio_gui_EEG_plotset.disp_event.Value = 1;
        %%Stack?
        EEG_plotset{8}=0;
        EStduio_gui_EEG_plotset.disp_stack.Value = 0;
        %%Norm?
        EEG_plotset{9}=0;
        EStduio_gui_EEG_plotset.disp_norm.Value = 0;
        %%channel order
        EEG_plotset{10} =1;
        EStduio_gui_EEG_plotset.chanorder_number.Value=1;
        EStduio_gui_EEG_plotset.chanorder_front.Value=0;
        EStduio_gui_EEG_plotset.chanorder_custom.Value=0;
        EStduio_gui_EEG_plotset.chanorder_custom_exp.Enable = 'off';
        EStduio_gui_EEG_plotset.chanorder_custom_imp.Enable = 'off';
        EStduio_gui_EEG_plotset.chanorder{1,1} = [];
        EStduio_gui_EEG_plotset.chanorder{1,2} = '';
        erpworkingmemory('EEG_plotset',EEG_plotset);
        observe_EEGDAT.Reset_eeg_paras_panel=4;
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


%%-----------------check if the channel location is empty------------------
function SetFlags =  check_chanlocs(ALLEEG)
SetFlags = zeros(length(ALLEEG),1);

for Numofset = 1:length(ALLEEG)
    EEG = ALLEEG(Numofset);
    try
        if ~isempty(EEG.chanlocs)
            for Numofchan = 1:EEG.nbchan
                if ~isempty(EEG.chanlocs(Numofchan).X)
                    SetFlags(Numofset)=1;
                end
            end
        end
        %%10-10 system?
        [eloc, labels, theta, radius, indices] = readlocs(EEG.chanlocs);
        [Simplabels,simplabelIndex,SamAll] =  Simplelabels(labels);
        count = 0;
        for ii = 1:length(Simplabels)
            [xpos,ypos]= find(simplabelIndex==ii);
            if ~isempty(ypos)  && numel(ypos)>= floor(length(EEG.chanlocs)/2)
                count = count+1;
                if count==1
                    SetFlags(Numofset)=0;
                    break;
                end
            end
        end
    catch
    end
end
end