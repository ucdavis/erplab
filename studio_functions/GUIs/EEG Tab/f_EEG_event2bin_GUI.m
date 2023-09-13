%%This function is to assin eventlist to one specific bin


% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Sep. 2023


function varargout = f_EEG_event2bin_GUI(varargin)

global observe_EEGDAT;
addlistener(observe_EEGDAT,'eeg_message_panel_change',@eeg_message_panel_change);
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);

%---------------------------Initialize parameters------------------------------------

EStduio_gui_EEG_event2bin = struct();

%-----------------------------Name the title----------------------------------------------
% global EStudio_box_EEG_event2bin;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    EStudio_box_EEG_event2bin = uiextras.BoxPanel('Parent', fig, 'Title', 'Assign Events to Bins', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    EStudio_box_EEG_event2bin = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Assign Events to Bins', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    EStudio_box_EEG_event2bin = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Assign Events to Bins', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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

drawui_event2bin_eeg(FonsizeDefault)
varargout{1} = EStudio_box_EEG_event2bin;

    function drawui_event2bin_eeg(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        EStduio_gui_EEG_event2bin.DataSelBox = uiextras.VBox('Parent', EStudio_box_EEG_event2bin,'BackgroundColor',ColorB_def);
        
        
        %%display original data?
        EStduio_gui_EEG_event2bin.datatype_title = uiextras.HBox('Parent', EStduio_gui_EEG_event2bin.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_event2bin.disp_orgdata = uicontrol('Parent',EStduio_gui_EEG_event2bin.datatype_title, 'Style', 'checkbox', 'String', 'Display original data',...
            'Callback', @disp_orgdata,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','on','Value',1);
        EStduio_gui_EEG_event2bin.disp_orgdata.KeyPressFcn = @eeg_plotset_presskey;
        EStduio_gui_EEG_event2bin.disp_IC = uicontrol('Parent',EStduio_gui_EEG_event2bin.datatype_title, 'Style', 'checkbox', 'String', 'Display ICs',...
            'Callback', @disp_IC,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','on','Value',0);
        EStduio_gui_EEG_event2bin.disp_IC.KeyPressFcn = @eeg_plotset_presskey;
        set(EStduio_gui_EEG_event2bin.datatype_title,'Sizes',[150 90]);
        
        EEG_plotset{1} = EStduio_gui_EEG_event2bin.disp_orgdata.Value;
        EEG_plotset{2} = EStduio_gui_EEG_event2bin.disp_IC.Value;
        %%-----------------General settings--------------------------------
        %%time range
        EStduio_gui_EEG_event2bin.time_scales_title = uiextras.HBox('Parent', EStduio_gui_EEG_event2bin.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_event2bin.timerange = uicontrol('Parent',EStduio_gui_EEG_event2bin.time_scales_title , 'Style', 'text', 'String', 'Time Range:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_event2bin.WinLength_edit = uicontrol('Parent',EStduio_gui_EEG_event2bin.time_scales_title , 'Style', 'edit', 'String', '5',...
            'Callback', @WinLength_edit,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        EStduio_gui_EEG_event2bin.WinLength_edit.KeyPressFcn = @eeg_plotset_presskey;
        EEG_plotset{3} = str2num(EStduio_gui_EEG_event2bin.timerange.String);
        %%vertical scale
        EStduio_gui_EEG_event2bin.v_scale = uicontrol('Parent',EStduio_gui_EEG_event2bin.time_scales_title, 'Style', 'text', 'String', 'Vertical Scale:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_event2bin.v_scale_edit = uicontrol('Parent',EStduio_gui_EEG_event2bin.time_scales_title , 'Style', 'edit', 'String', '50',...
            'Callback', @vscale_edit,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        set(EStduio_gui_EEG_event2bin.time_scales_title,'Sizes',[70 50 80 50]);
        EStduio_gui_EEG_event2bin.v_scale_edit.KeyPressFcn = @eeg_plotset_presskey;
        EEG_plotset{4} = str2num(EStduio_gui_EEG_event2bin.v_scale_edit.String);
        %%Channel labels  name/number?
        EStduio_gui_EEG_event2bin.chanlab_title = uiextras.HBox('Parent', EStduio_gui_EEG_event2bin.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_event2bin.chanlab_text = uicontrol('Parent',EStduio_gui_EEG_event2bin.chanlab_title, 'Style', 'text', 'String', 'Channel Labels:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_event2bin.chanlab_name = uicontrol('Parent',EStduio_gui_EEG_event2bin.chanlab_title, 'Style', 'radiobutton', 'String', 'Name',...
            'Callback', @chanlab_name,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','on','Value',1);
        EStduio_gui_EEG_event2bin.chanlab_name.KeyPressFcn = @eeg_plotset_presskey;
        EStduio_gui_EEG_event2bin.chanlab_numb = uicontrol('Parent',EStduio_gui_EEG_event2bin.chanlab_title, 'Style', 'radiobutton', 'String', 'Number',...
            'Callback', @chanlab_numb,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','on','Value',0);
        EStduio_gui_EEG_event2bin.chanlab_numb.KeyPressFcn = @eeg_plotset_presskey;
        EEG_plotset{5} = EStduio_gui_EEG_event2bin.chanlab_name.Value;
        set(EStduio_gui_EEG_event2bin.chanlab_title,'Sizes',[100 60 70]);
        
        
        %%Remove DC or display event?
        EStduio_gui_EEG_event2bin.removedc_event_title = uiextras.HBox('Parent', EStduio_gui_EEG_event2bin.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_event2bin.rem_DC = uicontrol('Parent',EStduio_gui_EEG_event2bin.removedc_event_title, 'Style', 'checkbox', 'String', 'Remove DC',...
            'Callback', @rm_DC,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','on','Value',0);
        EStduio_gui_EEG_event2bin.rem_DC.KeyPressFcn = @eeg_plotset_presskey;
        EStduio_gui_EEG_event2bin.disp_event = uicontrol('Parent',EStduio_gui_EEG_event2bin.removedc_event_title, 'Style', 'checkbox', 'String', 'Events',...
            'Callback', @disp_event,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','on','Value',1);
        EStduio_gui_EEG_event2bin.disp_event.KeyPressFcn = @eeg_plotset_presskey;
        EEG_plotset{6} = EStduio_gui_EEG_event2bin.rem_DC.Value;
        EEG_plotset{7} = EStduio_gui_EEG_event2bin.disp_event.Value;
        
        %%stack or norm?
        EStduio_gui_EEG_event2bin.stack_norm_title = uiextras.HBox('Parent', EStduio_gui_EEG_event2bin.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_event2bin.disp_stack = uicontrol('Parent',EStduio_gui_EEG_event2bin.stack_norm_title, 'Style', 'checkbox', 'String', 'Stack',...
            'Callback', @disp_stack,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','on','Value',0);
        EStduio_gui_EEG_event2bin.disp_stack.KeyPressFcn = @eeg_plotset_presskey;
        EStduio_gui_EEG_event2bin.disp_norm = uicontrol('Parent',EStduio_gui_EEG_event2bin.stack_norm_title, 'Style', 'checkbox', 'String', 'Norm',...
            'Callback', @disp_norm,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','on','Value',0);
        EStduio_gui_EEG_event2bin.disp_norm.KeyPressFcn = @eeg_plotset_presskey;
        EEG_plotset{8} = EStduio_gui_EEG_event2bin.disp_stack.Value;
        EEG_plotset{9} = EStduio_gui_EEG_event2bin.disp_norm.Value;
        
        %%----------------cancel and apply---------------------------------
        EStduio_gui_EEG_event2bin.reset_apply = uiextras.HBox('Parent',EStduio_gui_EEG_event2bin.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', EStduio_gui_EEG_event2bin.reset_apply); % 1A
        EStduio_gui_EEG_event2bin.plotset_cancel = uicontrol('Style', 'pushbutton','Parent',EStduio_gui_EEG_event2bin.reset_apply,...
            'String','Cancel','callback',@plot_eeg_cancel,'FontSize',FonsizeDefault);
        
        uiextras.Empty('Parent', EStduio_gui_EEG_event2bin.reset_apply); % 1A
        EStduio_gui_EEG_event2bin.plot_apply = uicontrol('Style', 'pushbutton','Parent',EStduio_gui_EEG_event2bin.reset_apply,...
            'String','Apply','callback',@eeg_plotset_apply,'FontSize',FonsizeDefault);
        EStduio_gui_EEG_event2bin.plot_apply.KeyPressFcn=  @eeg_plotset_presskey;
        uiextras.Empty('Parent', EStduio_gui_EEG_event2bin.reset_apply); % 1A
        set(EStduio_gui_EEG_event2bin.reset_apply, 'Sizes',[10,-1,30,-1,10]);
        
        set(EStduio_gui_EEG_event2bin.DataSelBox,'Sizes',[25 25 25 25 25 25]);
        estudioworkingmemory('EEG_plotset',EEG_plotset);
    end



%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%



%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=3 || isempty(observe_EEGDAT.EEG)
            return;
        end
        EEGIN = observe_EEGDAT.EEG;
        if isempty(EEGIN.icachansind)
            EStduio_gui_EEG_event2bin.disp_IC.Value=0;
            EStduio_gui_EEG_event2bin.disp_IC.Enable = 'off';
            %%<Insert warning message here>
        else
            EStduio_gui_EEG_event2bin.disp_IC.Enable = 'on';
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
        EStduio_gui_EEG_event2bin.plot_apply.BackgroundColor =  [1 1 1];
        EStduio_gui_EEG_event2bin.plot_apply.ForegroundColor = [0 0 0];
        EStudio_box_EEG_event2bin.TitleColor= [0.0500    0.2500    0.5000];
        EStduio_gui_EEG_event2bin.plotset_cancel.BackgroundColor =  [1 1 1];
        EStduio_gui_EEG_event2bin.plotset_cancel.ForegroundColor = [0 0 0];
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
            EStduio_gui_EEG_event2bin.plot_apply.BackgroundColor =  [1 1 1];
            EStduio_gui_EEG_event2bin.plot_apply.ForegroundColor = [0 0 0];
            EStudio_box_EEG_event2bin.TitleColor= [0.0500    0.2500    0.5000];
            EStduio_gui_EEG_event2bin.plotset_cancel.BackgroundColor =  [1 1 1];
            EStduio_gui_EEG_event2bin.plotset_cancel.ForegroundColor = [0 0 0];
        else
            return;
        end
    end


end