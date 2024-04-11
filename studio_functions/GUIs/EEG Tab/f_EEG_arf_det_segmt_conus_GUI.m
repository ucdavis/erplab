%%This function is to detect time segements for continuous EEG.


% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Oct. 2023


function varargout = f_EEG_arf_det_segmt_conus_GUI(varargin)

global observe_EEGDAT;
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
addlistener(observe_EEGDAT,'Reset_eeg_panel_change',@Reset_eeg_panel_change);

%---------------------------Initialize parameters------------------------------------
EEG_art_det_segmt_conus = struct();
%-----------------------------Name the title----------------------------------------------

% global Eegtab_box_art_det_segmt_conus;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    Eegtab_box_art_det_segmt_conus = uiextras.BoxPanel('Parent', fig, 'Title', 'Delete Time Segments (Continuous EEG)',...
        'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    Eegtab_box_art_det_segmt_conus = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Delete Time Segments (Continuous EEG)', ...
        'Padding', 5,'BackgroundColor',ColorB_def);
else
    Eegtab_box_art_det_segmt_conus = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Delete Time Segments (Continuous EEG)',...
        'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);%, 'HelpFcn', @segment_help
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

drawui_art_det_segmt_conus_eeg(FonsizeDefault)
varargout{1} = Eegtab_box_art_det_segmt_conus;

    function drawui_art_det_segmt_conus_eeg(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        EEG_art_det_segmt_conus.DataSelBox = uiextras.VBox('Parent', Eegtab_box_art_det_segmt_conus,'BackgroundColor',ColorB_def);
        FontSize_defualt = FonsizeDefault;
        if isempty(FontSize_defualt)
            FontSize_defualt = 12;
        end
        if isempty(observe_EEGDAT.EEG)
            EnableFlag = 'off';
        else
            EnableFlag = 'on';
        end
        
        def  = estudioworkingmemory('pop_erplabDeleteTimeSegments');
        if isempty(def)
            def = {[1500], [500], [1500], [], ['ignore'], 0, 0};
        end
        
        try
            timethreshold = def{1};
        catch
            timethreshold = 1500;
        end
        if isnan(timethreshold) || isempty(timethreshold) || numel(timethreshold)~=1 || min(timethreshold(:)) <=0
            timethreshold = 1500;
        end
        %%channels that detect artifact
        EEG_art_det_segmt_conus.chan_title = uiextras.HBox('Parent', EEG_art_det_segmt_conus.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',EEG_art_det_segmt_conus.chan_title,...
            'String','Time Threshold:','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        EEG_art_det_segmt_conus.time_threshold_edit = uicontrol('Style','edit','Parent',EEG_art_det_segmt_conus.chan_title,...
            'String',num2str(timethreshold),'FontSize',FontSize_defualt,'callback',@time_threshold_edit,'Enable',EnableFlag,'BackgroundColor',[1 1 1]); % 2F
        EEG_art_det_segmt_conus.time_threshold_edit.KeyPressFcn=  @eeg_artdetect_presskey;
        set( EEG_art_det_segmt_conus.chan_title,'Sizes',[120 -1]);
        
        
        %%buffer before eventcode in ms
        try
            bufferbefore = def{2};
        catch
            bufferbefore = 500;
        end
        if isnan(bufferbefore) || isempty(bufferbefore) || numel(bufferbefore)~=1 || min(bufferbefore(:)) <=0
            bufferbefore = 500;
        end
        EEG_art_det_segmt_conus.voltage_title = uiextras.HBox('Parent', EEG_art_det_segmt_conus.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_art_det_segmt_conus.voltage_text = uicontrol('Style','text','Parent',EEG_art_det_segmt_conus.voltage_title,...
            'String',['Buffer before eventcode (ms)'],'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def); % 2F
        EEG_art_det_segmt_conus.buffer_before_edit = uicontrol('Style','edit','Parent',EEG_art_det_segmt_conus.voltage_title,...
            'callback',@buffer_before_edit,'String',num2str(bufferbefore),'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',[1 1 1]); % 2F
        EEG_art_det_segmt_conus.buffer_before_edit.KeyPressFcn=  @eeg_artdetect_presskey;
        set(EEG_art_det_segmt_conus.voltage_title,'Sizes',[120,-1]);
        
        
        %%buffer after eventcode in ms
        try
            bufferafter = def{3};
        catch
            bufferafter = 1500;
        end
        if isnan(bufferafter) || isempty(bufferafter) || numel(bufferafter)~=1 || min(bufferafter(:)) <=0
            bufferafter = 1500;
        end
        EEG_art_det_segmt_conus.movewindow_title = uiextras.HBox('Parent', EEG_art_det_segmt_conus.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_art_det_segmt_conus.movewindow_text = uicontrol('Style','text','Parent',EEG_art_det_segmt_conus.movewindow_title,...
            'String',[32,'Buffer after eventcode (ms)'],'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def); % 2F
        EEG_art_det_segmt_conus.buffer_after_edit = uicontrol('Style','edit','Parent',EEG_art_det_segmt_conus.movewindow_title,...
            'callback',@buffer_after_edit,'String',num2str(bufferafter),'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',[1 1 1]); % 2F
        EEG_art_det_segmt_conus.buffer_after_edit.KeyPressFcn=  @eeg_artdetect_presskey;
        set(EEG_art_det_segmt_conus.movewindow_title,'Sizes',[120,-1]);
        
        %%eventcode exceptions
        EEG_art_det_segmt_conus.windowstep_title = uiextras.HBox('Parent', EEG_art_det_segmt_conus.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_art_det_segmt_conus.windowstep_text = uicontrol('Style','text','Parent',EEG_art_det_segmt_conus.windowstep_title,...
            'String','Eventcode exceptions (optional)','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def); % 2F
        EEG_art_det_segmt_conus.event_exp_edit = uicontrol('Style','edit','Parent',EEG_art_det_segmt_conus.windowstep_title,...
            'callback',@event_exp_edit,'String','','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',[1 1 1]); % 2F
        EEG_art_det_segmt_conus.event_exp_edit.KeyPressFcn=  @eeg_artdetect_presskey;
        set(EEG_art_det_segmt_conus.windowstep_title,'Sizes',[120,-1]);
        
        
        %%Ignore or use these exceptions
        try
            ignoreUseType = def{5};
        catch
            ignoreUseType = 'ignore';
        end
        if  isempty(ignoreUseType) || numel(ignoreUseType)~=1 || min(ignoreUseType(:)) <=0
            ignoreUseType = 'ignore';
        end
        
        EEG_art_det_segmt_conus.eventcode_title = uiextras.HBox('Parent', EEG_art_det_segmt_conus.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', EEG_art_det_segmt_conus.eventcode_title );
        EEG_art_det_segmt_conus.event_exp_select = uicontrol('Style','popupmenu','Parent',EEG_art_det_segmt_conus.eventcode_title,...
            'callback',@event_exp_select,'String',{'Ignore','Use'},'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',[1 1 1]); % 2F
        if strcmp(ignoreUseType,'ignore')
            EEG_art_det_segmt_conus.event_exp_select.Value = 1;
        else
            EEG_art_det_segmt_conus.event_exp_select.Value = 2;
        end
        uicontrol('Style','text','Parent',EEG_art_det_segmt_conus.eventcode_title,...
            'String','these exceptions','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def); % 2F
        EEG_art_det_segmt_conus.event_exp_select.KeyPressFcn=  @eeg_artdetect_presskey;
        set(EEG_art_det_segmt_conus.eventcode_title,'Sizes',[80,90,-1]);
        
        
        %%Ignore boundary events
        try
            ignoreBoundary = def{7};
        catch
            ignoreBoundary = 0;
        end
        if  isempty(ignoreBoundary) || numel(ignoreBoundary)~=1 || min(ignoreBoundary(:)) <=0 || (ignoreBoundary ~=0 && ignoreBoundary~=1)
            ignoreBoundary = 0;
        end
        EEG_art_det_segmt_conus.boundaryevent_title = uiextras.HBox('Parent', EEG_art_det_segmt_conus.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', EEG_art_det_segmt_conus.boundaryevent_title );
        EEG_art_det_segmt_conus.boundaryevent = uicontrol('Style','checkbox','Parent',EEG_art_det_segmt_conus.boundaryevent_title,...
            'callback',@boundaryevent,'String','Ignore boundary events','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,...
            'Enable',EnableFlag,'BackgroundColor',ColorB_def,'Value',ignoreBoundary); % 2F
        EEG_art_det_segmt_conus.boundaryevent.KeyPressFcn=  @eeg_artdetect_presskey;
        uiextras.Empty('Parent', EEG_art_det_segmt_conus.boundaryevent_title );
        set(EEG_art_det_segmt_conus.boundaryevent_title,'Sizes',[80,150,-1]);
        
        
        %%-----------------------Cancel and Run----------------------------
        EEG_art_det_segmt_conus.detar_run_title = uiextras.HBox('Parent', EEG_art_det_segmt_conus.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  EEG_art_det_segmt_conus.detar_run_title,'BackgroundColor',ColorB_def);
        EEG_art_det_segmt_conus.detectsegmt_preview = uicontrol('Style', 'pushbutton','Parent',EEG_art_det_segmt_conus.detar_run_title,...
            'String','Preview','callback',@detectsegmt_preview,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent',  EEG_art_det_segmt_conus.detar_run_title,'BackgroundColor',ColorB_def);
        EEG_art_det_segmt_conus.detectsegmt_run = uicontrol('Style','pushbutton','Parent',EEG_art_det_segmt_conus.detar_run_title,...
            'String','Finalize','callback',@detectsegmt_run,'FontSize',FontSize_defualt,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent',  EEG_art_det_segmt_conus.detar_run_title,'BackgroundColor',ColorB_def);
        set(EEG_art_det_segmt_conus.detar_run_title,'Sizes',[15 105  30 105 15]);
        
        %%note/warning
        EEG_art_det_segmt_conus.note_title = uiextras.HBox('Parent', EEG_art_det_segmt_conus.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',EEG_art_det_segmt_conus.note_title,...
            'String','Warning: Any previously created Eventlist will be deleted','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        
        set(EEG_art_det_segmt_conus.DataSelBox,'Sizes',[30 35 35 35 25 30 30 30]);
        estudioworkingmemory('EEGTab_detect_segmt_conus',0);
    end


%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%----------------------edit chans-----------------------------------------
    function time_threshold_edit(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=11
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_art_det_segmt_conus.TitleColor= [0.5137    0.7569    0.9176];
        EEG_art_det_segmt_conus.detectsegmt_preview.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_art_det_segmt_conus.detectsegmt_preview.ForegroundColor = [1 1 1];
        EEG_art_det_segmt_conus.detectsegmt_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_art_det_segmt_conus.detectsegmt_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_segmt_conus',1);
        timeThresholdMS = str2num(Source.String);
        
        if isempty(timeThresholdMS) || numel(timeThresholdMS)~=1||  any(timeThresholdMS(:)<=0)
            msgboxText = 'Delete Time Segments (Continuous EEG) >  The value of "Time Threshold" should be a positive number';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            Source.String= '1500';
            return;
        end
    end

%%-----------------------------volatge-------------------------------------
    function buffer_before_edit(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=11
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_art_det_segmt_conus.TitleColor= [0.5137    0.7569    0.9176];
        EEG_art_det_segmt_conus.detectsegmt_preview.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_art_det_segmt_conus.detectsegmt_preview.ForegroundColor = [1 1 1];
        EEG_art_det_segmt_conus.detectsegmt_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_art_det_segmt_conus.detectsegmt_run.ForegroundColor = [1 1 1];
        
        estudioworkingmemory('EEGTab_detect_segmt_conus',1);
        beforeEventcodeBufferMS= str2num(Source.String);
        if isempty(beforeEventcodeBufferMS) || numel(beforeEventcodeBufferMS)~=1
            msgboxText = ['Delete Time Segments (Continuous EEG) > Buffer before eventcode should have one number'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            Source.String = '500';
            return;
        end
    end

%%------------------------moving window------------------------------------
    function buffer_after_edit(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=11
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_art_det_segmt_conus.TitleColor= [0.5137    0.7569    0.9176];
        EEG_art_det_segmt_conus.detectsegmt_preview.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_art_det_segmt_conus.detectsegmt_preview.ForegroundColor = [1 1 1];
        EEG_art_det_segmt_conus.detectsegmt_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_art_det_segmt_conus.detectsegmt_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_segmt_conus',1);
        afterEventcodeBufferMS= str2num(Source.String);
        if isempty(afterEventcodeBufferMS) || numel(afterEventcodeBufferMS) ~=1
            msgboxText = ['Delete Time Segments (Continuous EEG) > Buffer after eventcode should have one number'];
            Source.String = '1500';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
    end


%%-------------------------moving step-------------------------------------
    function event_exp_edit(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=11
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_art_det_segmt_conus.TitleColor= [0.5137    0.7569    0.9176];
        EEG_art_det_segmt_conus.detectsegmt_preview.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_art_det_segmt_conus.detectsegmt_preview.ForegroundColor = [1 1 1];
        EEG_art_det_segmt_conus.detectsegmt_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_art_det_segmt_conus.detectsegmt_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_segmt_conus',1);
        evntcodes = Source.String;
        evntcodes = colonrange2num(evntcodes);
        editString               = regexprep(evntcodes, '[\D]', ' ');
        Source.String = editString;
    end


%%------------------Ignore/use---------------------------------------------
    function event_exp_select(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=11
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_art_det_segmt_conus.TitleColor= [0.5137    0.7569    0.9176];
        EEG_art_det_segmt_conus.detectsegmt_preview.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_art_det_segmt_conus.detectsegmt_preview.ForegroundColor = [1 1 1];
        EEG_art_det_segmt_conus.detectsegmt_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_art_det_segmt_conus.detectsegmt_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_segmt_conus',1);
    end


%%%------------------------Ignore boundary evnets--------------------------
    function boundaryevent(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=11
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_art_det_segmt_conus.TitleColor= [0.5137    0.7569    0.9176];
        EEG_art_det_segmt_conus.detectsegmt_preview.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_art_det_segmt_conus.detectsegmt_preview.ForegroundColor = [1 1 1];
        EEG_art_det_segmt_conus.detectsegmt_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_art_det_segmt_conus.detectsegmt_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_segmt_conus',1);
    end


%%%----------------------Preview-------------------------------------------
    function detectsegmt_preview(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=11
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('f_EEG_proces_messg','Delete Time Segments (Continuous EEG) > Preview');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        %%--------Selected EEGsets-----------
        EEGArray= estudioworkingmemory('EEGArray');
        
        Eegtab_box_art_det_segmt_conus.TitleColor= [0.0500    0.2500    0.5000];
        EEG_art_det_segmt_conus.detectsegmt_preview.BackgroundColor =  [1 1 1];
        EEG_art_det_segmt_conus.detectsegmt_preview.ForegroundColor = [0 0 0];
        EEG_art_det_segmt_conus.detectsegmt_run.BackgroundColor =  [ 1 1 1];
        EEG_art_det_segmt_conus.detectsegmt_run.ForegroundColor = [0 0 0];
        
        estudioworkingmemory('EEGTab_detect_segmt_conus',0);
        
        timeThresholdMS = str2double(EEG_art_det_segmt_conus.time_threshold_edit.String);
        if isempty(timeThresholdMS) || numel(timeThresholdMS)~=1||  any(timeThresholdMS(:)<=0)
            msgboxText = ['Delete Time Segments (Continuous EEG) > Preview: The value of "Time Threshold" should be a positive value'];
            EEG_art_det_segmt_conus.time_threshold_edit.String= '7000';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        beforeEventcodeBufferMS = str2double(EEG_art_det_segmt_conus.buffer_before_edit.String);
        if isempty(beforeEventcodeBufferMS) || numel(beforeEventcodeBufferMS)~=1
            msgboxText = ['Delete Time Segments (Continuous EEG) > Preview: Buffer before eventcode should have one number'];
            EEG_art_det_segmt_conus.buffer_before_edit.String = '3000';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        afterEventcodeBufferMS = str2double(EEG_art_det_segmt_conus.buffer_after_edit.String);
        if isempty(afterEventcodeBufferMS) || numel(afterEventcodeBufferMS) ~=1
            msgboxText = ['Delete Time Segments (Continuous EEG) > Buffer after eventcode should have one number'];
            EEG_art_det_segmt_conus.buffer_after_edit.String = '3000';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        ignoreUseEventcodes = str2num(EEG_art_det_segmt_conus.event_exp_edit.String);
        ignoreUseTypeValue = EEG_art_det_segmt_conus.event_exp_select.Value;
        if ignoreUseTypeValue==1
            ignoreUseType = 'ignore';
        else
            ignoreUseType = 'use';
        end
        if isempty(ignoreUseEventcodes)
            ignoreUseType = 'ignore';
            EEG_art_det_segmt_conus.event_exp_select.Value=1;
            disp("We force 'these exceptions' to be ignored because there is no input for Eventcode exceptions.");
        end
        ignoreBoundary = EEG_art_det_segmt_conus.boundaryevent.Value;
        displayEEG = 1;
        % Save the GUI inputs to memory
        estudioworkingmemory('pop_erplabDeleteTimeSegments',    ...
            { timeThresholdMS,                              ...
            beforeEventcodeBufferMS,                       ...
            afterEventcodeBufferMS,                         ...
            ignoreUseEventcodes,                          ...
            ignoreUseType,                                ...
            displayEEG,                                   ...
            ignoreBoundary});
        
        for Numofeeg = 1:numel(EEGArray)
            try
                EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
            catch
                EEG = observe_EEGDAT.EEG;
            end
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Delete Time Segments (Continuous EEG) > Preview*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            
            %% Run the pop_ command with the user input from the GUI
            [EEG, LASTCOM] = pop_erplabDeleteTimeSegments(EEG, ...
                'timeThresholdMS'           , timeThresholdMS,              ...
                'beforeEventcodeBufferMS'   , beforeEventcodeBufferMS,       ...
                'afterEventcodeBufferMS'    , afterEventcodeBufferMS,         ...
                'ignoreUseEventcodes'       , ignoreUseEventcodes,          ...
                'ignoreUseType'             , ignoreUseType,                ...
                'displayEEG'                , displayEEG,                   ...
                'ignoreBoundary'            , ignoreBoundary,               ...
                'History'                   , 'implicit');
            if isempty(LASTCOM)
                disp('User selected cancel or errors occur.');
                fprintf( [repmat('-',1,100) '\n']);
                return;
            else
                fprintf([LASTCOM,'\n']);
            end
            fprintf( [repmat('-',1,100) '\n']);
            if Numofeeg==1
                eegh(LASTCOM);
            end
        end
        estudioworkingmemory('f_EEG_proces_messg','Delete Time Segments (Continuous EEG) > Preview');
        observe_EEGDAT.eeg_panel_message =2; %%Marking for the procedure has been started.
    end


%%-----------------------Finalize------------------------------------------
    function detectsegmt_run(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=11
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('f_EEG_proces_messg','Delete Time Segments (Continuous EEG) > Finalize');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        Eegtab_box_art_det_segmt_conus.TitleColor= [0.0500    0.2500    0.5000];
        EEG_art_det_segmt_conus.detectsegmt_preview.BackgroundColor =  [1 1 1];
        EEG_art_det_segmt_conus.detectsegmt_preview.ForegroundColor = [0 0 0];
        EEG_art_det_segmt_conus.detectsegmt_run.BackgroundColor =  [ 1 1 1];
        EEG_art_det_segmt_conus.detectsegmt_run.ForegroundColor = [0 0 0];
        
        estudioworkingmemory('EEGTab_detect_segmt_conus',0);
        %%--------Selected EEGsets-----------
        EEGArray= estudioworkingmemory('EEGArray');
        if isempty(EEGArray) || any(EEGArray(:) > length(observe_EEGDAT.ALLEEG))
            EEGArray = observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',EEGArray);
        end
        
        timeThresholdMS = str2double(EEG_art_det_segmt_conus.time_threshold_edit.String);
        if isempty(timeThresholdMS) || numel(timeThresholdMS)~=1||  any(timeThresholdMS(:)<=0)
            msgboxText = ['Delete Time Segments (Continuous EEG) > Finalize: The value of "Time Threshold" should be a positive value'];
            EEG_art_det_segmt_conus.time_threshold_edit.String= '7000';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        
        beforeEventcodeBufferMS = str2double(EEG_art_det_segmt_conus.buffer_before_edit.String);
        if isempty(beforeEventcodeBufferMS) || numel(beforeEventcodeBufferMS)~=1
            msgboxText = ['Delete Time Segments (Continuous EEG) > Finalize: Buffer before eventcode should be a single value'];
            EEG_art_det_segmt_conus.buffer_before_edit.String = '3000';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        
        afterEventcodeBufferMS = str2double(EEG_art_det_segmt_conus.buffer_after_edit.String);
        if isempty(afterEventcodeBufferMS) || numel(afterEventcodeBufferMS) ~=1
            msgboxText = ['Delete Time Segments (Continuous EEG) >Finalize: Buffer after eventcode should be a single value'];
            EEG_art_det_segmt_conus.buffer_after_edit.String = '3000';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        
        ignoreUseEventcodes = str2num(EEG_art_det_segmt_conus.event_exp_edit.String);
        ignoreUseTypeValue = EEG_art_det_segmt_conus.event_exp_select.Value;
        if ignoreUseTypeValue==1
            ignoreUseType = 'ignore';
        else
            ignoreUseType = 'use';
        end
        ignoreBoundary = EEG_art_det_segmt_conus.boundaryevent.Value;
        displayEEG = 0;
        if isempty(ignoreUseEventcodes)
            ignoreUseType = 'ignore';
            EEG_art_det_segmt_conus.event_exp_select.Value=1;
            disp("We force 'these exceptions' to be ignored because there is no input for Eventcode exceptions.");
        end
        % Save the GUI inputs to memory
        estudioworkingmemory('pop_erplabDeleteTimeSegments',    ...
            { timeThresholdMS,                              ...
            beforeEventcodeBufferMS,                       ...
            afterEventcodeBufferMS,                         ...
            ignoreUseEventcodes,                          ...
            ignoreUseType,                                ...
            displayEEG,                                   ...
            ignoreBoundary});
        ALLEEG = observe_EEGDAT.ALLEEG;
        ALLEEG_out = [];
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Delete Time Segments (Continuous EEG) > Finalize*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            %% Run the pop_ command with the user input from the GUI
            [EEG, LASTCOM] = pop_erplabDeleteTimeSegments(EEG, ...
                'timeThresholdMS'           , timeThresholdMS,              ...
                'beforeEventcodeBufferMS'   , beforeEventcodeBufferMS,       ...
                'afterEventcodeBufferMS'    , afterEventcodeBufferMS,         ...
                'ignoreUseEventcodes'       , ignoreUseEventcodes,          ...
                'ignoreUseType'             , ignoreUseType,                ...
                'displayEEG'                , displayEEG,                   ...
                'ignoreBoundary'            , ignoreBoundary,               ...
                'History'                   , 'implicit');
            if isempty(LASTCOM)
                fprintf( [repmat('-',1,100) '\n']);
                observe_EEGDAT.eeg_panel_message =2;
                return;
            end
            fprintf([LASTCOM,'\n']);
            EEG = eegh(LASTCOM, EEG);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            [ALLEEG_out,~,~,LASTCOM] = pop_newset(ALLEEG_out, EEG, length(ALLEEG_out), 'gui', 'off');
            fprintf( [repmat('-',1,100) '\n']);
            if Numofeeg==1
                eegh(LASTCOM);
            end
        end%%end for loop of subjects
        Save_file_label = 0;
        Answer = f_EEG_save_multi_file(ALLEEG_out,1:numel(EEGArray),'_del');
        if isempty(Answer)
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        if ~isempty(Answer{1})
            ALLEEG_out = Answer{1};
            Save_file_label = Answer{2};
        end
        for Numofeeg = 1:numel(EEGArray)
            EEG =    ALLEEG_out(Numofeeg);
            checkfileindex = checkfilexists([EEG.filepath,filesep,EEG.filename]);
            if Save_file_label && checkfileindex==1
                [pathstr, file_name, ext] = fileparts(EEG.filename);
                EEG.filename = [file_name,'.set'];
                [EEG, LASTCOM] = pop_saveset(EEG,'filename', EEG.filename, 'filepath',EEG.filepath,'check','on');
                EEG = eegh(LASTCOM, EEG);
                if Numofeeg==1
                    eegh(LASTCOM);
                end
            else
                EEG.filename = '';
                EEG.saved = 'no';
                EEG.filepath = '';
            end
            [ALLEEG,~,~,LASTCOM] = pop_newset(ALLEEG, EEG, length(ALLEEG), 'gui', 'off');
        end
        
        observe_EEGDAT.ALLEEG = ALLEEG;
        try
            Selected_EEG_afd =  [length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1:length(observe_EEGDAT.ALLEEG)];
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1;
        catch
            Selected_EEG_afd = length(observe_EEGDAT.ALLEEG);
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG);
        end
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
        estudioworkingmemory('EEGArray',Selected_EEG_afd);
        assignin('base','EEG',observe_EEGDAT.EEG);
        assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
        assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        observe_EEGDAT.count_current_eeg=1;
        observe_EEGDAT.eeg_panel_message =2;
    end


%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=15
            return;
        end
        EEGUpdate = estudioworkingmemory('EEGUpdate');
        if isempty(EEGUpdate) || numel(EEGUpdate)~=1 || (EEGUpdate~=0 && EEGUpdate~=1)
            EEGUpdate = 0;  estudioworkingmemory('EEGUpdate',0);
        end
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1 || EEGUpdate==1
            EEG_art_det_segmt_conus.time_threshold_edit.Enable= 'off';
            EEG_art_det_segmt_conus.chan_browse.Enable= 'off';
            EEG_art_det_segmt_conus.buffer_before_edit.Enable= 'off';
            EEG_art_det_segmt_conus.buffer_after_edit.Enable= 'off';
            EEG_art_det_segmt_conus.event_exp_edit.Enable= 'off';
            EEG_art_det_segmt_conus.event_exp_select.Enable= 'off';
            EEG_art_det_segmt_conus.boundaryevent.Enable= 'off';
            EEG_art_det_segmt_conus.detectsegmt_preview.Enable= 'off';
            EEG_art_det_segmt_conus.detectsegmt_run.Enable= 'off';
            if ~isempty(observe_EEGDAT.EEG) &&  observe_EEGDAT.EEG.trials ~=1
                Eegtab_box_art_det_segmt_conus.TitleColor= [0.7500    0.7500    0.750];
            else
                Eegtab_box_art_det_segmt_conus.TitleColor= [0.0500    0.2500    0.5000];
            end
            observe_EEGDAT.count_current_eeg=16;
            return;
        end
        
        Eegtab_box_art_det_segmt_conus.TitleColor= [0.0500    0.2500    0.5000];
        EEG_art_det_segmt_conus.time_threshold_edit.Enable= 'on';
        EEG_art_det_segmt_conus.chan_browse.Enable= 'on';
        EEG_art_det_segmt_conus.periods_edit.Enable= 'on';
        EEG_art_det_segmt_conus.buffer_before_edit.Enable= 'on';
        EEG_art_det_segmt_conus.buffer_after_edit.Enable= 'on';
        EEG_art_det_segmt_conus.event_exp_edit.Enable= 'on';
        EEG_art_det_segmt_conus.event_exp_select.Enable= 'on';
        EEG_art_det_segmt_conus.boundaryevent.Enable= 'on';
        EEG_art_det_segmt_conus.detectsegmt_preview.Enable= 'on';
        EEG_art_det_segmt_conus.detectsegmt_run.Enable= 'on';
        
        EEG_art_det_segmt_conus.detectsegmt_preview.String = 'Preview';
        time_threshold_edit = str2num(EEG_art_det_segmt_conus.time_threshold_edit.String);
        if isempty(time_threshold_edit)
            EEG_art_det_segmt_conus.time_threshold_edit.String = '1500';
        end
        %%set default parameters
        if isempty(str2num(EEG_art_det_segmt_conus.buffer_before_edit.String))
            EEG_art_det_segmt_conus.buffer_before_edit.String = '500';
        end
        if isempty(str2num(EEG_art_det_segmt_conus.buffer_after_edit.String))
            EEG_art_det_segmt_conus.buffer_after_edit.String = '1500';
        end
        if isempty(str2num(EEG_art_det_segmt_conus.event_exp_edit.String))
            EEG_art_det_segmt_conus.event_exp_edit.String = '';
        end
        observe_EEGDAT.count_current_eeg=16;
    end



%%--------------press return to execute "Apply"----------------------------
    function eeg_artdetect_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('EEGTab_detect_segmt_conus');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            detectsegmt_run();
            estudioworkingmemory('EEGTab_detect_segmt_conus',0);
            Eegtab_box_art_det_segmt_conus.TitleColor= [0.0500    0.2500    0.5000];
            EEG_art_det_segmt_conus.detectsegmt_preview.BackgroundColor =  [1 1 1];
            EEG_art_det_segmt_conus.detectsegmt_preview.ForegroundColor = [0 0 0];
            EEG_art_det_segmt_conus.detectsegmt_run.BackgroundColor =  [ 1 1 1];
            EEG_art_det_segmt_conus.detectsegmt_run.ForegroundColor = [0 0 0];
        else
            return;
        end
    end


%%--------------Reset this panel with the default parameters---------------
    function Reset_eeg_panel_change(~,~)
        if observe_EEGDAT.Reset_eeg_paras_panel~=12
            return;
        end
        estudioworkingmemory('EEGTab_detect_segmt_conus',0);
        EEG_art_det_segmt_conus.detectsegmt_preview.BackgroundColor =  [1 1 1];
        EEG_art_det_segmt_conus.detectsegmt_preview.ForegroundColor = [0 0 0];
        EEG_art_det_segmt_conus.detectsegmt_run.BackgroundColor =  [ 1 1 1];
        EEG_art_det_segmt_conus.detectsegmt_run.ForegroundColor = [0 0 0];
        EEG_art_det_segmt_conus.time_threshold_edit.String = '1500';
        EEG_art_det_segmt_conus.buffer_before_edit.String = '500';
        EEG_art_det_segmt_conus.buffer_after_edit.String = '1500';
        EEG_art_det_segmt_conus.event_exp_edit.String = '';
        EEG_art_det_segmt_conus.event_exp_select.Value = 1;
        EEG_art_det_segmt_conus.boundaryevent.Value = 0;
        observe_EEGDAT.Reset_eeg_paras_panel=13;
    end
end


%%----------------check if the file already exists-------------------------
function checkfileindex = checkfilexists(filenamex)%%Jan 10 2024
checkfileindex=1;
[pathstr, file_name, ext] = fileparts(filenamex);
filenamex = [pathstr,filesep, file_name,'.set'];
if exist(filenamex, 'file')~=0
    msgboxText =  ['This EEG Data already exist.\n'...;
        'Would you like to overwrite it?'];
    title  = 'Estudio: WARNING!';
    button = askquest(sprintf(msgboxText), title);
    if strcmpi(button,'no')
        checkfileindex=0;
    else
        checkfileindex=1;
    end
end
end

