%%This function is to shift event codes for continuous EEG.


% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Oct. 2023


function varargout = f_EEG_shift_eventcode_conus_GUI(varargin)

global observe_EEGDAT;
% addlistener(observe_EEGDAT,'eeg_panel_change_message',@eeg_panel_change_message);
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);

%---------------------------Initialize parameters------------------------------------
EEG_shift_eventcode_conus = struct();
%-----------------------------Name the title----------------------------------------------

% global Eegtab_box_shift_eventcodes_conus;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    Eegtab_box_shift_eventcodes_conus = uiextras.BoxPanel('Parent', fig, 'Title', 'Shift Event Codes for Continuous EEG', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    Eegtab_box_shift_eventcodes_conus = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Shift Event Codes for Continuous EEG', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    Eegtab_box_shift_eventcodes_conus = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Shift Event Codes for Continuous EEG', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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

drawui_shift_eventcode_conus_eeg(FonsizeDefault)
varargout{1} = Eegtab_box_shift_eventcodes_conus;

    function drawui_shift_eventcode_conus_eeg(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        EEG_shift_eventcode_conus.DataSelBox = uiextras.VBox('Parent', Eegtab_box_shift_eventcodes_conus,'BackgroundColor',ColorB_def);
        FontSize_defualt = FonsizeDefault;
        if isempty(FontSize_defualt)
            FontSize_defualt = 12;
        end
        if isempty(observe_EEGDAT.EEG)
            EnableFlag = 'off';
        else
            EnableFlag = 'on';
        end
        
        def  = erpworkingmemory('pop_erplabShiftEventCodes');
        if isempty(def)
            def = {};
        end
        try
            eventcodes = def{1};
        catch
            eventcodes = '';
        end
        %%Event codes
        EEG_shift_eventcode_conus.chan_title = uiextras.HBox('Parent', EEG_shift_eventcode_conus.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',EEG_shift_eventcode_conus.chan_title,'HorizontalAlignment','left',...
            'String','Event codes:','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        EEG_shift_eventcode_conus.event_codes_edit = uicontrol('Style','edit','Parent',EEG_shift_eventcode_conus.chan_title,...
            'String','','FontSize',FontSize_defualt,'callback',@event_codes_edit,'Enable',EnableFlag,'BackgroundColor',[1 1 1]); % 2F
        EEG_shift_eventcode_conus.event_codes_edit.KeyPressFcn=  @eeg_shiftcodes_presskey;
        EEG_shift_eventcode_conus.event_codes_browse = uicontrol('Style','pushbutton','Parent',EEG_shift_eventcode_conus.chan_title,...
            'String','Browse','FontSize',FontSize_defualt,'callback',@event_codes_browse,'Enable',EnableFlag,'BackgroundColor',[1 1 1]); % 2F
        set( EEG_shift_eventcode_conus.chan_title,'Sizes',[90 -1,60]);
        if iscell(eventcodes)
            EEG_shift_eventcode_conus.event_codes_edit.String = num2str(strjoin(eventcodes, ','));
        else
            EEG_shift_eventcode_conus.event_codes_edit.String = num2str(eventcodes);
        end
        
        %%buffer before eventcode in ms
        try
            timeshift= def{2};
        catch
            timeshift = [];
        end
        EEG_shift_eventcode_conus.voltage_title = uiextras.HBox('Parent', EEG_shift_eventcode_conus.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_shift_eventcode_conus.voltage_text = uicontrol('Style','text','Parent',EEG_shift_eventcode_conus.voltage_title,'HorizontalAlignment','left',...
            'String',['Timeshift (ms):'],'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def); % 2F
        EEG_shift_eventcode_conus.timeshift_edit = uicontrol('Style','edit','Parent',EEG_shift_eventcode_conus.voltage_title,...
            'callback',@timeshift_edit,'String',num2str(timeshift),'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',[1 1 1]); % 2F
        EEG_shift_eventcode_conus.timeshift_edit.KeyPressFcn=  @eeg_shiftcodes_presskey;
        EEG_shift_eventcode_conus.timeshift_qestion = uicontrol('Style','pushbutton','Parent',EEG_shift_eventcode_conus.voltage_title,...
            'callback',@timeshift_question,'String','?','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable','on','BackgroundColor',[1 1 1]); % 2F
        set(EEG_shift_eventcode_conus.voltage_title,'Sizes',[90,-1,60]);
        try
            sample_rounding= def{3};
        catch
            sample_rounding = 'earlier';
        end
        if strcmp(sample_rounding,'earlier')
            Valueround1 = 1;
            Valueround2 = 0;
            Valueround3 = 0;
        elseif strcmp(sample_rounding,'nearest')
            Valueround1 = 0;
            Valueround2 = 1;
            Valueround3 = 0;
        elseif strcmp(sample_rounding,'later')
            Valueround1 = 0;
            Valueround2 = 0;
            Valueround3 = 1;
        else
            Valueround1 = 1;
            Valueround2 = 0;
            Valueround3 = 0;
        end
        %%Round to arlier time sample (recommended)
        EEG_shift_eventcode_conus.movewindow_title = uiextras.HBox('Parent', EEG_shift_eventcode_conus.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_shift_eventcode_conus.roundearlier = uicontrol('Style','radiobutton','Parent',EEG_shift_eventcode_conus.movewindow_title,'HorizontalAlignment','left',...
            'callback',@roundearlier,'String','Round to earlier time sample (recommended)','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def); % 2F
        EEG_shift_eventcode_conus.roundearlier.KeyPressFcn=  @eeg_shiftcodes_presskey;
        uiextras.Empty('Parent', EEG_shift_eventcode_conus.movewindow_title ,'BackgroundColor',ColorB_def);
        set(EEG_shift_eventcode_conus.movewindow_title,'Sizes',[270,-1]);
        
        %%Round to nearest time sample
        EEG_shift_eventcode_conus.windowstep_title = uiextras.HBox('Parent', EEG_shift_eventcode_conus.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_shift_eventcode_conus.roundnearest = uicontrol('Style','radiobutton','Parent',EEG_shift_eventcode_conus.windowstep_title,'HorizontalAlignment','left',...
            'callback',@roundnearest,'String','Round to nearest time sample','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def); % 2F
        EEG_shift_eventcode_conus.roundnearest.KeyPressFcn=  @eeg_shiftcodes_presskey;
        uiextras.Empty('Parent',EEG_shift_eventcode_conus.windowstep_title ,'BackgroundColor',ColorB_def);
        set(EEG_shift_eventcode_conus.windowstep_title,'Sizes',[260,-1]);
        
        %%Round to later time sample
        EEG_shift_eventcode_conus.eventcode_title = uiextras.HBox('Parent', EEG_shift_eventcode_conus.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_shift_eventcode_conus.roundlater = uicontrol('Style','radiobutton','Parent',EEG_shift_eventcode_conus.eventcode_title,'HorizontalAlignment','left',...
            'callback',@roundlater,'String','Round to later time sample','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def); % 2F
        uiextras.Empty('Parent', EEG_shift_eventcode_conus.eventcode_title );
        set(EEG_shift_eventcode_conus.eventcode_title,'Sizes',[260,-1]);
        EEG_shift_eventcode_conus.roundearlier.Value = Valueround1;
        EEG_shift_eventcode_conus.roundnearest.Value = Valueround2;
        EEG_shift_eventcode_conus.roundlater.Value = Valueround3;
        
        %%-----------------------Cancel and Run----------------------------
        EEG_shift_eventcode_conus.detar_run_title = uiextras.HBox('Parent', EEG_shift_eventcode_conus.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  EEG_shift_eventcode_conus.detar_run_title,'BackgroundColor',ColorB_def);
        EEG_shift_eventcode_conus.shiftcodes_cancel = uicontrol('Style', 'pushbutton','Parent',EEG_shift_eventcode_conus.detar_run_title,...
            'String','Cancel','callback',@shiftcodes_cancel,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent',  EEG_shift_eventcode_conus.detar_run_title,'BackgroundColor',ColorB_def);
        EEG_shift_eventcode_conus.shiftcodes_run = uicontrol('Style','pushbutton','Parent',EEG_shift_eventcode_conus.detar_run_title,...
            'String','Shift Events','callback',@shiftcodes_run,'FontSize',FontSize_defualt,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent',  EEG_shift_eventcode_conus.detar_run_title,'BackgroundColor',ColorB_def);
        set(EEG_shift_eventcode_conus.detar_run_title,'Sizes',[15 105  30 105 15]);
        
        set(EEG_shift_eventcode_conus.DataSelBox,'Sizes',[30 30 25 25 25 30]);
        estudioworkingmemory('EEGTab_shiftcodes_conus',0);
    end


%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%


%%----------------------edit chans-----------------------------------------
    function event_codes_edit(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=12
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_shift_eventcodes_conus.TitleColor= [0.5137    0.7569    0.9176];
        EEG_shift_eventcode_conus.shiftcodes_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_shift_eventcode_conus.shiftcodes_cancel.ForegroundColor = [1 1 1];
        EEG_shift_eventcode_conus.shiftcodes_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_shift_eventcode_conus.shiftcodes_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_shiftcodes_conus',1);
    end



%%--------------------------Browse event codes-----------------------------
    function event_codes_browse(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=12
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_shift_eventcodes_conus.TitleColor= [0.5137    0.7569    0.9176];
        EEG_shift_eventcode_conus.shiftcodes_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_shift_eventcode_conus.shiftcodes_cancel.ForegroundColor = [1 1 1];
        EEG_shift_eventcode_conus.shiftcodes_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_shift_eventcode_conus.shiftcodes_run.ForegroundColor = [1 1 1];
        EEG = observe_EEGDAT.EEG;
        msgboxText = '';
        if isempty(EEG(1).event)
            msgboxText =  'Event for current EEG is empty';
        end
        if isempty([EEG(1).event.type])
            msgboxText =  'Event for current EEG is empty';
        end
        if ~isempty(msgboxText)
            erpworkingmemory('f_EEG_proces_messg',['Shift Event Codes for Continuous EEG > Browse event codes:',32,msgboxText]);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            return;
        end
        [eventtypes histo] = squeezevents(EEG.event);
        titlename = 'Select event codes:';
        
        Eventcodeold =  EEG_shift_eventcode_conus.event_codes_edit.String;
        try
            Eventcodeold = eval(num2str(Eventcodeold)); %if numeric
        catch
            Eventcodeold = regexp(Eventcodeold,'(?<=\d)\s(?=\d)|,\s*','split'); %remove commas if exist
            Eventcodeold = Eventcodeold(~cellfun('isempty',Eventcodeold));
        end
        
        
        try
            [C,IA] = ismember_bc2(Eventcodeold,eventtypes);
            indxlistb = IA;
            if any(IA==0)
                indxlistb=1;
            else
                indxlistb=IA;
            end
        catch
            indxlistb=1;
        end
        evnetcodes_select = browsechanbinGUI(eventtypes, indxlistb, titlename);
        if ~isempty(evnetcodes_select)
            if numel(evnetcodes_select)==1
                EventcodeNew  = eventtypes{evnetcodes_select};
            else
                for ii = 1:numel(evnetcodes_select)
                    EventcodeNew{ii} = eventtypes{evnetcodes_select(ii)};
                end
            end
            try
                EEG_shift_eventcode_conus.event_codes_edit.String  =strjoin(EventcodeNew,',');
            catch
                EEG_shift_eventcode_conus.event_codes_edit.String = num2str(EventcodeNew);
            end
        else
            beep;
            disp('User selected Cancel');
            return
        end
    end

%%-----------------------------volatge-------------------------------------
    function timeshift_edit(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=12
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_shift_eventcodes_conus.TitleColor= [0.5137    0.7569    0.9176];
        EEG_shift_eventcode_conus.shiftcodes_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_shift_eventcode_conus.shiftcodes_cancel.ForegroundColor = [1 1 1];
        EEG_shift_eventcode_conus.shiftcodes_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_shift_eventcode_conus.shiftcodes_run.ForegroundColor = [1 1 1];
        
        estudioworkingmemory('EEGTab_shiftcodes_conus',1);
        timeshiftnew= str2num(Source.String);
        if isempty(timeshiftnew) || numel(timeshiftnew)~=1
            erpworkingmemory('f_EEG_proces_messg',['Shift Event Codes for Continuous EEG > Time shift meust be one number']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String = '';
            return;
        end
    end

%%----------------------Qestion for time shift-----------------------------
    function timeshift_question(~,~)
        BackERPLABcolor = [1 0.9 0.3];    % yellow
        question = ['Positive timeshift shifts right/forward in time\nNegative timeshift shifts left/backward in time'];
        title = 'Shift event codes for continuous EEG';
        oldcolor = get(0,'DefaultUicontrolBackgroundColor');
        set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
        button = questdlg(sprintf(question), title,'Yes','Yes');
        set(0,'DefaultUicontrolBackgroundColor',oldcolor);
    end




%%------------------------moving window------------------------------------
    function roundearlier(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=12
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_shift_eventcodes_conus.TitleColor= [0.5137    0.7569    0.9176];
        EEG_shift_eventcode_conus.shiftcodes_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_shift_eventcode_conus.shiftcodes_cancel.ForegroundColor = [1 1 1];
        EEG_shift_eventcode_conus.shiftcodes_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_shift_eventcode_conus.shiftcodes_run.ForegroundColor = [1 1 1];
        
        estudioworkingmemory('EEGTab_shiftcodes_conus',1);
        EEG_shift_eventcode_conus.roundearlier.Value = 1;
        EEG_shift_eventcode_conus.roundnearest.Value = 0;
        EEG_shift_eventcode_conus.roundlater.Value = 0;
    end


%%-------------------------moving step-------------------------------------
    function roundnearest(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=12
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_shift_eventcodes_conus.TitleColor= [0.5137    0.7569    0.9176];
        EEG_shift_eventcode_conus.shiftcodes_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_shift_eventcode_conus.shiftcodes_cancel.ForegroundColor = [1 1 1];
        EEG_shift_eventcode_conus.shiftcodes_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_shift_eventcode_conus.shiftcodes_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_shiftcodes_conus',1);
        
        EEG_shift_eventcode_conus.roundearlier.Value = 0;
        EEG_shift_eventcode_conus.roundnearest.Value = 1;
        EEG_shift_eventcode_conus.roundlater.Value = 0;
    end


%%------------------Ignore/use---------------------------------------------
    function roundlater(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=12
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_shift_eventcodes_conus.TitleColor= [0.5137    0.7569    0.9176];
        EEG_shift_eventcode_conus.shiftcodes_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_shift_eventcode_conus.shiftcodes_cancel.ForegroundColor = [1 1 1];
        EEG_shift_eventcode_conus.shiftcodes_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_shift_eventcode_conus.shiftcodes_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_shiftcodes_conus',1);
        EEG_shift_eventcode_conus.roundearlier.Value = 0;
        EEG_shift_eventcode_conus.roundnearest.Value = 0;
        EEG_shift_eventcode_conus.roundlater.Value = 1;
    end


%%%----------------------Preview-------------------------------------------
    function shiftcodes_cancel(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=12
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','Shift Event Codes for Continuous EEG > Cancel');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        Eegtab_box_shift_eventcodes_conus.TitleColor= [0.0500    0.2500    0.5000];
        EEG_shift_eventcode_conus.shiftcodes_cancel.BackgroundColor =  [1 1 1];
        EEG_shift_eventcode_conus.shiftcodes_cancel.ForegroundColor = [0 0 0];
        EEG_shift_eventcode_conus.shiftcodes_run.BackgroundColor =  [ 1 1 1];
        EEG_shift_eventcode_conus.shiftcodes_run.ForegroundColor = [0 0 0];
        
        estudioworkingmemory('EEGTab_shiftcodes_conus',0);
        def  = erpworkingmemory('pop_erplabShiftEventCodes');
        if isempty(def)
            def = {};
        end
        try
            eventcodes = def{1};
        catch
            eventcodes = '';
        end
        
        if iscell(eventcodes)
            EEG_shift_eventcode_conus.event_codes_edit.String = num2str(strjoin(eventcodes, ','));
        else
            EEG_shift_eventcode_conus.event_codes_edit.String = num2str(eventcodes);
        end
        try
            timeshift= def{2};
        catch
            timeshift = [];
        end
        EEG_shift_eventcode_conus.timeshift_edit.String = num2str(timeshift);
        try
            sample_rounding= def{3};
        catch
            sample_rounding = 'earlier';
        end
        if strcmp(sample_rounding,'earlier')
            Valueround1 = 1;
            Valueround2 = 0;
            Valueround3 = 0;
        elseif strcmp(sample_rounding,'nearest')
            Valueround1 = 0;
            Valueround2 = 1;
            Valueround3 = 0;
        elseif strcmp(sample_rounding,'later')
            Valueround1 = 0;
            Valueround2 = 0;
            Valueround3 = 1;
        else
            Valueround1 = 1;
            Valueround2 = 0;
            Valueround3 = 0;
        end
        EEG_shift_eventcode_conus.roundearlier.Value = Valueround1;
        EEG_shift_eventcode_conus.roundnearest.Value = Valueround2;
        EEG_shift_eventcode_conus.roundlater.Value = Valueround3;
        observe_EEGDAT.eeg_panel_message =2;
    end


%%-----------------------Shift events--------------------------------------
    function shiftcodes_run(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=12
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','Shift Event Codes for Continuous EEG > Shift events');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        Eegtab_box_shift_eventcodes_conus.TitleColor= [0.0500    0.2500    0.5000];
        EEG_shift_eventcode_conus.shiftcodes_cancel.BackgroundColor =  [1 1 1];
        EEG_shift_eventcode_conus.shiftcodes_cancel.ForegroundColor = [0 0 0];
        EEG_shift_eventcode_conus.shiftcodes_run.BackgroundColor =  [ 1 1 1];
        EEG_shift_eventcode_conus.shiftcodes_run.ForegroundColor = [0 0 0];
        
        estudioworkingmemory('EEGTab_shiftcodes_conus',0);
        %%--------Selected EEGsets-----------
        EEGArray= estudioworkingmemory('EEGArray');
        if isempty(EEGArray) || min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) || max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG)
            EEGArray = observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',EEGArray);
        end
        Eventcodes =  EEG_shift_eventcode_conus.event_codes_edit.String;
        try
            Eventcodes = eval(num2str(Eventcodes)); %if numeric
        catch
            Eventcodes = regexp(Eventcodes,'(?<=\d)\s(?=\d)|,\s*','split'); %remove commas if exist
            Eventcodes = Eventcodes(~cellfun('isempty',Eventcodes));
        end
        need_to_flat = 0;
        for ec = 1:length(Eventcodes)
            try
                temp_nums = num2cell(eval(num2str(Eventcodes{ec}))); %evaluate & flatten any numeric expression
                Eventcodes{ec} = cellfun(@num2str,temp_nums,'UniformOutput',false); %change to string
                need_to_flat = 1;
            catch
            end
        end
        if need_to_flat == 1
            Eventcodes =[Eventcodes{:}];
        end
        Eventcodes = (Eventcodes);
        if isempty(Eventcodes)
            erpworkingmemory('f_EEG_proces_messg','Shift Event Codes for Continuous EEG > Shift events: Please define one or more event codes');
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            return;
        end
        
        %%timeshift
        timeshift  = str2num(EEG_shift_eventcode_conus.timeshift_edit.String);
        if isempty(timeshift) || numel(timeshift)~=1
            erpworkingmemory('f_EEG_proces_messg','Shift Event Codes for Continuous EEG > Shift events: Timeshift must be one number');
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            return;
        end
        
        %%
        if EEG_shift_eventcode_conus.roundearlier.Value==1
            rounding = 'earlier';
        elseif EEG_shift_eventcode_conus.roundnearest.Value==1
            rounding = 'nearest';
        elseif  EEG_shift_eventcode_conus.roundlater.Value ==1
            rounding = 'later';
        else
            rounding = 'earlier';
        end
        displayFeedback     = 'both';
        displayEEG = 0;
        
        erpworkingmemory('pop_erplabShiftEventCodes', ...
            {Eventcodes, timeshift, rounding, displayEEG, displayFeedback});
        %         try
        ALLEEG = observe_EEGDAT.ALLEEG;
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Shift Event Codes for Continuous EEG > Shift events*',32,32,32,32,datestr(datetime('now')),'\n']);
            
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            
            
            %% Run the pop_ command with the user input from the GUI
            [EEG, LASTCOM] = pop_erplabShiftEventCodes(EEG, ...
                'Eventcodes'     , Eventcodes,      ...
                'Timeshift'      , timeshift,       ...
                'Rounding'       , rounding,        ...
                'DisplayEEG'     , displayEEG,      ...
                'DisplayFeedback', displayFeedback, ...
                'History'        , 'implicit');
            
            if isempty(LASTCOM)
                disp('User selected cancel or errors occur.');
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            
            fprintf([LASTCOM,'\n']);
            EEG = eegh(LASTCOM, EEG);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            Answer = f_EEG_save_single_file(char(strcat(EEG.setname,'_shift')),EEG.filename,EEGArray(Numofeeg));
            if isempty(Answer)
                disp('User selected cancel.');
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            
            if ~isempty(Answer)
                EEGName = Answer{1};
                if ~isempty(EEGName)
                    EEG.setname = EEGName;
                end
                fileName_full = Answer{2};
                if isempty(fileName_full)
                    EEG.filename = '';
                    EEG.saved = 'no';
                elseif ~isempty(fileName_full)
                    [pathstr, file_name, ext] = fileparts(fileName_full);
                    if strcmp(pathstr,'')
                        pathstr = cd;
                    end
                    EEG.filename = [file_name,ext];
                    EEG.filepath = pathstr;
                    EEG.saved = 'yes';
                    %%----------save the current sdata as--------------------
                    [EEG, LASTCOM] = pop_saveset(EEG,'filename', EEG.filename, 'filepath',EEG.filepath,'check','on');
                    EEG = eegh(LASTCOM, EEG);
                    if Numofeeg==1
                        eegh(LASTCOM);
                    end
                end
            end
            [ALLEEG,~,~,LASTCOM] = pop_newset(ALLEEG, EEG, length(ALLEEG), 'gui', 'off');
            fprintf( [repmat('-',1,100) '\n']);
            if Numofeeg==1
                eegh(LASTCOM);
            end
        end%%end for loop of subjects
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
        %         catch
        %             observe_EEGDAT.count_current_eeg=1;
        %             observe_EEGDAT.eeg_panel_message =3;%%There is errros in processing procedure
        %             fprintf( [repmat('-',1,100) '\n']);
        %             return;
        %         end
    end


%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1 || isempty(observe_EEGDAT.EEG.event)
            EEG_shift_eventcode_conus.event_codes_edit.Enable= 'off';
            EEG_shift_eventcode_conus.event_codes_browse.Enable= 'off';
            EEG_shift_eventcode_conus.timeshift_edit.Enable= 'off';
            EEG_shift_eventcode_conus.roundearlier.Enable= 'off';
            EEG_shift_eventcode_conus.roundnearest.Enable= 'off';
            EEG_shift_eventcode_conus.roundlater.Enable= 'off';
            EEG_shift_eventcode_conus.shiftcodes_run.Enable= 'off';
            EEG_shift_eventcode_conus.shiftcodes_cancel.Enable= 'off';
            if  ~isempty(observe_EEGDAT.EEG) && isempty(observe_EEGDAT.EEG.event)
                Eegtab_box_shift_eventcodes_conus.Title = 'No events were found for the current EEG';
                Eegtab_box_shift_eventcodes_conus.ForegroundColor= [1 0 0];
            end
            
            if observe_EEGDAT.count_current_eeg ~=17
                return;
            else
                if observe_EEGDAT.EEG.trials ~=1
                    observe_EEGDAT.count_current_eeg=18;
                end
            end
            return;
        end
        if observe_EEGDAT.count_current_eeg ~=17
            return;
        end
        Eegtab_box_shift_eventcodes_conus.Title = 'Shift Event Codes for Continuous EEG';
        Eegtab_box_shift_eventcodes_conus.ForegroundColor= [1 1 1];
        
        EEG_shift_eventcode_conus.event_codes_edit.Enable= 'on';
        EEG_shift_eventcode_conus.event_codes_browse.Enable= 'on';
        EEG_shift_eventcode_conus.timeshift_edit.Enable= 'on';
        EEG_shift_eventcode_conus.roundearlier.Enable= 'on';
        EEG_shift_eventcode_conus.roundnearest.Enable= 'on';
        EEG_shift_eventcode_conus.roundlater.Enable= 'on';
        EEG_shift_eventcode_conus.shiftcodes_run.Enable= 'on';
        EEG_shift_eventcode_conus.shiftcodes_cancel.Enable= 'on';
        EEG_shift_eventcode_conus.shiftcodes_cancel.String = 'Cancel';
        EEG = observe_EEGDAT.EEG;
        
        if   ~isempty(EEG(1).event) && ~isempty([EEG(1).event.type])
            %             [eventtypes histo] = squeezevents(EEG.event);
            % Check numeric or string type
            if ischar(EEG.event(1).type)
                ec_type_is_str = 0;
            else
                ec_type_is_str = 1;
            end
            evT = struct2table(EEG.event);
            if ec_type_is_str
                all_ev = str2double(evT.type);
            else
                all_ev = evT.type;
            end
            
            %         eventtypes = unique(all_ev);
            % %         eventtypes(isnan(eventtypes)) = [];
            %             Eventcodeold =  EEG_shift_eventcode_conus.event_codes_edit.String;
            %             try
            %                 Eventcodeold = eval(num2str(Eventcodeold)); %if numeric
            %             catch
            %                 Eventcodeold = regexp(Eventcodeold,'(?<=\d)\s(?=\d)|,\s*','split'); %remove commas if exist
            %                 Eventcodeold = Eventcodeold(~cellfun('isempty',Eventcodeold));
            %             end
            %
            %             [C,IA] = ismember_bc2(Eventcodeold,eventtypes,'legacy');
            %             if min(IA(:)) ==0
            %                 EEG_shift_eventcode_conus.event_codes_edit.String = '';
            %             end
        else
            fprintf(['Shift Event Codes for Continuous EEG > Event for current EEG is empty',32,32,32,32,datestr(datetime('now')),'\n']);
            EEG_shift_eventcode_conus.event_codes_edit.Enable= 'off';
            EEG_shift_eventcode_conus.event_codes_browse.Enable= 'off';
            EEG_shift_eventcode_conus.event_codes_edit.String = '';
            EEG_shift_eventcode_conus.shiftcodes_run.Enable= 'off';
            EEG_shift_eventcode_conus.shiftcodes_cancel.Enable= 'off';
        end
        observe_EEGDAT.count_current_eeg=18;
    end


%%--------------press return to execute "Apply"----------------------------
    function eeg_shiftcodes_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('EEGTab_shiftcodes_conus');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            shiftcodes_run();
            estudioworkingmemory('EEGTab_shiftcodes_conus',0);
            Eegtab_box_shift_eventcodes_conus.TitleColor= [0.0500    0.2500    0.5000];
            EEG_shift_eventcode_conus.shiftcodes_cancel.BackgroundColor =  [1 1 1];
            EEG_shift_eventcode_conus.shiftcodes_cancel.ForegroundColor = [0 0 0];
            EEG_shift_eventcode_conus.shiftcodes_run.BackgroundColor =  [ 1 1 1];
            EEG_shift_eventcode_conus.shiftcodes_run.ForegroundColor = [0 0 0];
        else
            return;
        end
    end

%%-------------------Auomatically execute "apply"--------------------------
    function eeg_two_panels_change(~,~)
        if  isempty(observe_EEGDAT.EEG)
            return;
        end
        ChangeFlag =  estudioworkingmemory('EEGTab_shiftcodes_conus');
        if ChangeFlag~=1
            return;
        end
        shiftcodes_run();
        estudioworkingmemory('EEGTab_shiftcodes_conus',0);
        Eegtab_box_shift_eventcodes_conus.TitleColor= [0.0500    0.2500    0.5000];
        EEG_shift_eventcode_conus.shiftcodes_cancel.BackgroundColor =  [1 1 1];
        EEG_shift_eventcode_conus.shiftcodes_cancel.ForegroundColor = [0 0 0];
        EEG_shift_eventcode_conus.shiftcodes_run.BackgroundColor =  [ 1 1 1];
        EEG_shift_eventcode_conus.shiftcodes_run.ForegroundColor = [0 0 0];
    end

end