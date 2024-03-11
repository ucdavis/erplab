%Author: Guanghui ZHANG
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
% Mar. 2024

% EEGLAB Studio

function varargout = f_EEG_resample_GUI(varargin)
global observe_EEGDAT;

addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
addlistener(observe_EEGDAT,'Reset_eeg_panel_change',@Reset_eeg_panel_change);

gui_eeg_resample = struct();

%-----------------------------Name the title----------------------------------------------
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.95 0.95 0.95];
end

if nargin == 0
    fig = figure(); % Parent figure
    box_eeg_resample = uiextras.BoxPanel('Parent', fig, 'Title', 'Sampling Rate & Epoch', 'Padding', 5,...
        'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    box_eeg_resample = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Sampling Rate & Epoch', 'Padding', 5,...
        'BackgroundColor',ColorB_def);
else
    box_eeg_resample = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Sampling Rate & Epoch', 'Padding', 5,...
        'FontSize', varargin{2},'BackgroundColor',ColorB_def);%, 'HelpFcn', @resample_help
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
drawui_eeg_resample(FonsizeDefault);
varargout{1} = box_eeg_resample;

    function drawui_eeg_resample(FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.95 0.95 0.95];
        end
        
        gui_eeg_resample.DataSelBox = uiextras.VBox('Parent', box_eeg_resample,'BackgroundColor',ColorB_def);
        
        %%------------------current sampling rate--------------------------
        gui_eeg_resample.csrate_title = uiextras.HBox('Parent', gui_eeg_resample.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent', gui_eeg_resample.csrate_title,'String','Current sampling rate:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_eeg_resample.csrate_edit = uicontrol('Style','edit','Parent', gui_eeg_resample.csrate_title,'String','',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off'); % 2F
        uicontrol('Style','text','Parent', gui_eeg_resample.csrate_title,'String','Hz',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(gui_eeg_resample.csrate_title,'Sizes',[130 110 30]);
        
        %%---------------------new sampling rate---------------------------
        gui_eeg_resample.nwsrate_title = uiextras.HBox('Parent', gui_eeg_resample.DataSelBox,'BackgroundColor',ColorB_def);
        gui_eeg_resample.nwsrate_checkbox = uicontrol('Style','checkbox','Parent', gui_eeg_resample.nwsrate_title,'String','New sampling rate:',...
            'callback',@nwsrate_checkbox,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Value',0,'Enable','off');
        gui_eeg_resample.nwsrate_checkbox.KeyPressFcn = @EEG_resample_presskey;
        gui_eeg_resample.Paras{1} = gui_eeg_resample.nwsrate_checkbox.Value;
        gui_eeg_resample.nwsrate_edit = uicontrol('Style','edit','Parent', gui_eeg_resample.nwsrate_title,'String','',...
            'callback',@nwsrate_edit,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off'); % 2F
        gui_eeg_resample.Paras{2} = str2num(gui_eeg_resample.nwsrate_edit.String);
        gui_eeg_resample.nwsrate_edit.KeyPressFcn = @EEG_resample_presskey;
        uicontrol('Style','text','Parent', gui_eeg_resample.nwsrate_title,'String','Hz',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(gui_eeg_resample.nwsrate_title,'Sizes',[130 110 30]);
        
        %%----------------current time-window------------------------------
        gui_eeg_resample.ctimewindow_title = uiextras.HBox('Parent', gui_eeg_resample.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent',gui_eeg_resample.ctimewindow_title,...
            'String','Current epoch','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_eeg_resample.ctimewindow_editleft = uicontrol('Style','edit','Parent', gui_eeg_resample.ctimewindow_title,'String','',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off'); % 2F
        uicontrol('Style', 'text','Parent',gui_eeg_resample.ctimewindow_title,...
            'String','ms, to','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_eeg_resample.ctimewindow_editright = uicontrol('Style','edit','Parent', gui_eeg_resample.ctimewindow_title,'String','',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off'); % 2F
        uicontrol('Style', 'text','Parent',gui_eeg_resample.ctimewindow_title,...
            'String','ms','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(gui_eeg_resample.ctimewindow_title,'Sizes',[90 55  40 55 25]);
        
        %%--------------------new time window--------------------------------
        gui_eeg_resample.nwtimewindow_title = uiextras.HBox('Parent', gui_eeg_resample.DataSelBox,'BackgroundColor',ColorB_def);
        gui_eeg_resample.nwtimewindow_checkbox= uicontrol('Style', 'checkbox','Parent',gui_eeg_resample.nwtimewindow_title,...
            'callback',@nwtimewindow_checkbox,'String','New epoch','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Value',0,'Enable','off');
        gui_eeg_resample.Paras{3} = gui_eeg_resample.nwtimewindow_checkbox.Value;
        gui_eeg_resample.nwtimewindow_checkbox.KeyPressFcn = @EEG_resample_presskey;
        gui_eeg_resample.nwtimewindow_editleft = uicontrol('Style','edit','Parent', gui_eeg_resample.nwtimewindow_title,'String','',...
            'callback',@nwtimewindow_editleft,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off'); % 2F
        gui_eeg_resample.Paras{4} = str2num(gui_eeg_resample.nwtimewindow_editleft.String);
        gui_eeg_resample.nwtimewindow_editleft.KeyPressFcn = @EEG_resample_presskey;
        uicontrol('Style', 'text','Parent',gui_eeg_resample.nwtimewindow_title,...
            'String','ms, to','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_eeg_resample.nwtimewindow_editright = uicontrol('Style','edit','Parent', gui_eeg_resample.nwtimewindow_title,'String','',...
            'callback',@nwtimewindow_editright,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off'); % 2F
        gui_eeg_resample.Paras{5} = str2num(gui_eeg_resample.nwtimewindow_editright.String);
        gui_eeg_resample.nwtimewindow_editright.KeyPressFcn = @EEG_resample_presskey;
        uicontrol('Style', 'text','Parent',gui_eeg_resample.nwtimewindow_title,...
            'String','ms','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(gui_eeg_resample.nwtimewindow_title,'Sizes',[90 55  40 55 25]);
        
        %%------------------------cancel & apply-----------------------------
        gui_eeg_resample.advance_help_title = uiextras.HBox('Parent',gui_eeg_resample.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', gui_eeg_resample.advance_help_title);
        gui_eeg_resample.resample_cancel= uicontrol('Style', 'pushbutton','Parent',gui_eeg_resample.advance_help_title,...
            'String','Cancel','callback',@resample_cancel,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', gui_eeg_resample.advance_help_title);
        
        gui_eeg_resample.resample_run = uicontrol('Style', 'pushbutton','Parent',gui_eeg_resample.advance_help_title,'String','Apply',...
            'callback',@resample_run,'FontSize',FonsizeDefault,'Enable','off','BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', gui_eeg_resample.advance_help_title);
        set(gui_eeg_resample.advance_help_title,'Sizes',[15 105  30 105 15]);
        set(gui_eeg_resample.DataSelBox,'Sizes',[30 30 30 30 30]);
        
        estudioworkingmemory('EEGTab_resample',0);
    end


%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%


%%-------------------checkbox for new sampling rate------------------------
    function nwsrate_checkbox(Source,~)
        if isempty(observe_EEGDAT.EEG)
            observe_EEGDAT.count_current_eeg=1;
            return;
        end
        gui_eeg_resample.nwsrate_edit.BackgroundColor = [1 1 1];
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=18
            observe_EEGDAT.eeg_two_panels  = observe_EEGDAT.eeg_two_panels +1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_resample',1);
        gui_eeg_resample.resample_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_eeg_resample.resample_run.ForegroundColor = [1 1 1];
        box_eeg_resample.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_eeg_resample.resample_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_eeg_resample.resample_cancel.ForegroundColor = [1 1 1];
        
        if Source.Value==1
            gui_eeg_resample.nwsrate_edit.Enable = 'on';
            Newsrate = str2num(gui_eeg_resample.nwsrate_edit.String);
            if isempty(Newsrate) || numel(Newsrate)~=1 || any(Newsrate<=0)
                try gui_eeg_resample.nwsrate_edit.String = str2num(observe_EEGDAT.EEG.srate); catch end
            end
        else
            gui_eeg_resample.nwsrate_edit.Enable = 'off';
        end
    end


%%-------------------------edit new sampling rate--------------------------
    function nwsrate_edit(Source,~)
        if isempty(observe_EEGDAT.EEG)
            observe_EEGDAT.count_current_eeg=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=18
            observe_EEGDAT.eeg_two_panels  = observe_EEGDAT.eeg_two_panels +1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_resample',1);
        gui_eeg_resample.resample_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_eeg_resample.resample_run.ForegroundColor = [1 1 1];
        box_eeg_resample.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_eeg_resample.resample_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_eeg_resample.resample_cancel.ForegroundColor = [1 1 1];
        
        Newsrate = str2num(gui_eeg_resample.nwsrate_edit.String);
        if isempty(Newsrate) || numel(Newsrate)~=1 ||any(Newsrate<=0)
            msgboxText='Sampling Rate & Epoch: New sampling rate must be a positive value';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            Source.String = '';
        end
    end

%%-------------------checkbox for new time window--------------------------
    function nwtimewindow_checkbox(Source,~)
        if isempty(observe_EEGDAT.EEG)
            observe_EEGDAT.count_current_eeg=1;
            return;
        end
        gui_eeg_resample.nwtimewindow_editleft.BackgroundColor = [1 1 1];
        gui_eeg_resample.nwtimewindow_editright.BackgroundColor = [1 1 1];
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=18
            observe_EEGDAT.eeg_two_panels  = observe_EEGDAT.eeg_two_panels +1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_resample',1);
        gui_eeg_resample.resample_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_eeg_resample.resample_run.ForegroundColor = [1 1 1];
        box_eeg_resample.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_eeg_resample.resample_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_eeg_resample.resample_cancel.ForegroundColor = [1 1 1];
        if Source.Value==1
            gui_eeg_resample.nwtimewindow_editleft.Enable ='on';
            gui_eeg_resample.nwtimewindow_editright.Enable = 'on';
            NewStart = str2num(gui_eeg_resample.nwtimewindow_editleft.String);
            if isempty(NewStart) || numel(NewStart)~=1 || any(NewStart>=observe_EEGDAT.EEG.times(end))
                gui_eeg_resample.nwtimewindow_editleft.String = num2str(observe_EEGDAT.EEG.times(1));
            end
            Newend = str2num(gui_eeg_resample.nwtimewindow_editright.String);
            if isempty(Newend) || numel(Newend)~=1 || any(Newend<=observe_EEGDAT.EEG.times(1))
                gui_eeg_resample.nwtimewindow_editright.String = num2str(observe_EEGDAT.EEG.times(end));
            end
        else
            gui_eeg_resample.nwtimewindow_editleft.Enable ='off';
            gui_eeg_resample.nwtimewindow_editright.Enable = 'off';
        end
    end

%%--------------------------new epoch start--------------------------------
    function nwtimewindow_editleft(Source,~)
        if isempty(observe_EEGDAT.EEG)
            observe_EEGDAT.count_current_eeg=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=18
            observe_EEGDAT.eeg_two_panels  = observe_EEGDAT.eeg_two_panels +1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_resample',1);
        gui_eeg_resample.resample_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_eeg_resample.resample_run.ForegroundColor = [1 1 1];
        box_eeg_resample.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_eeg_resample.resample_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_eeg_resample.resample_cancel.ForegroundColor = [1 1 1];
        NewStart = str2num(gui_eeg_resample.nwtimewindow_editleft.String);
        if isempty(NewStart) || numel(NewStart)~=1
            msgboxText='Sampling Rate & Epoch: the left edge for the new time window must be a single value';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            Source.String = '';
            return;
        end
        if NewStart>= observe_EEGDAT.EEG.times(end)
            msgboxText=['Sampling Rate & Epoch: the left edge for the new time window should be smaller than',32,num2str(observe_EEGDAT.EEG.times(end)),'ms'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            Source.String = '';
            return;
        end
        if NewStart< observe_EEGDAT.EEG.times(1)
            msgboxText=['Sampling Rate & Epoch: we will set 0 for the additional time range because the left edge for the new time window is smaller than',32,num2str(observe_EEGDAT.EEG.times(1)),'ms'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
        if NewStart>= 0
            msgboxText=['Sampling Rate & Epoch: the left edge for the new time window should be smaller than 0 ms'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            Source.String = '';
            return;
        end
        
    end


%%---------------------------new epoch stop--------------------------------
    function nwtimewindow_editright(Source,~)
        if isempty(observe_EEGDAT.EEG)
            observe_EEGDAT.count_current_eeg=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=18
            observe_EEGDAT.eeg_two_panels  = observe_EEGDAT.eeg_two_panels +1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_resample',1);
        gui_eeg_resample.resample_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_eeg_resample.resample_run.ForegroundColor = [1 1 1];
        box_eeg_resample.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_eeg_resample.resample_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_eeg_resample.resample_cancel.ForegroundColor = [1 1 1];
        Newend = str2num(gui_eeg_resample.nwtimewindow_editright.String);
        if isempty(Newend) || numel(Newend)~=1
            msgboxText='Sampling Rate & Epoch: the right edge for the new time window must be a single value';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            Source.String = '';
            return;
        end
        if Newend<= observe_EEGDAT.EEG.times(1)
            msgboxText=['Sampling Rate & Epoch: the right edge for the new time window should be larger than',32,num2str(observe_EEGDAT.EEG.times(1)),'ms'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            Source.String = '';
            return;
        end
        if Newend< observe_EEGDAT.EEG.times(end)
            msgboxText=['Sampling Rate & Epoch: we will set 0 for the additional time range because the right edge for the new time window is larger than',32,num2str(observe_EEGDAT.EEG.times(end)),'ms'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
        
        if Newend<=0
            msgboxText=['Sampling Rate & Epoch: the right edge for the new time window should be larger than 0 ms'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            Source.String = '';
            return;
        end
    end

%%--------------------------cancel-----------------------------------------
    function resample_cancel(~,~)
        if isempty(observe_EEGDAT.EEG)
            observe_EEGDAT.count_current_eeg=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=18
            observe_EEGDAT.eeg_two_panels  = observe_EEGDAT.eeg_two_panels +1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_resample',0);
        gui_eeg_resample.resample_run.BackgroundColor =  [1 1 1];
        gui_eeg_resample.resample_run.ForegroundColor = [0 0 0];
        box_eeg_resample.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_eeg_resample.resample_cancel.BackgroundColor =  [1 1 1];
        gui_eeg_resample.resample_cancel.ForegroundColor = [0 0 0];
        
        gui_eeg_resample.csrate_edit.String = num2str(observe_EEGDAT.EEG.srate);
        gui_eeg_resample.ctimewindow_editleft.String = num2str(observe_EEGDAT.EEG.times(1));
        gui_eeg_resample.ctimewindow_editright.String = num2str(observe_EEGDAT.EEG.times(end));
        %%------------------new sampling rate--------------------------
        nwsrate_checkboxValue = gui_eeg_resample.Paras{1};
        if isempty(nwsrate_checkboxValue) || numel(nwsrate_checkboxValue)~=1 || (nwsrate_checkboxValue~=0 && nwsrate_checkboxValue~=1)
            gui_eeg_resample.Paras{1}=0;
            nwsrate_checkboxValue=0;
        end
        gui_eeg_resample.nwsrate_checkbox.Value=nwsrate_checkboxValue;
        if nwsrate_checkboxValue==1
            gui_eeg_resample.nwsrate_edit.Enable = 'on';
        else
            gui_eeg_resample.nwsrate_edit.Enable = 'off';
        end
        gui_eeg_resample.nwsrate_edit.String = num2str(gui_eeg_resample.Paras{2});
        %%------------------------new-time window-------------------------
        newtwcheckboxValue =   gui_eeg_resample.Paras{3};
        if isempty(newtwcheckboxValue) || numel(newtwcheckboxValue)~=1 || (newtwcheckboxValue~=0 && newtwcheckboxValue~=1)
            gui_eeg_resample.Paras{3}=0;
            newtwcheckboxValue=0;
        end
        gui_eeg_resample.nwtimewindow_checkbox.Value=newtwcheckboxValue;
        if newtwcheckboxValue==1
            gui_eeg_resample.nwtimewindow_editleft.Enable ='on';
            gui_eeg_resample.nwtimewindow_editright.Enable = 'on';
        else
            gui_eeg_resample.nwtimewindow_editleft.Enable ='off';
            gui_eeg_resample.nwtimewindow_editright.Enable = 'off';
        end
        gui_eeg_resample.nwtimewindow_editleft.String = num2str(gui_eeg_resample.Paras{4});
        gui_eeg_resample.nwtimewindow_editright.String = num2str(gui_eeg_resample.Paras{5});
    end

%%--------------------------Run--------------------------------------------
    function resample_run(~,~)
        if isempty(observe_EEGDAT.EEG)
            observe_EEGDAT.count_current_eeg=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=18
            observe_EEGDAT.eeg_two_panels  = observe_EEGDAT.eeg_two_panels +1;%%call the functions from the other panel
        end
        if gui_eeg_resample.nwsrate_checkbox.Value==0 && gui_eeg_resample.nwtimewindow_checkbox.Value==0
            msgboxText='Sampling Rate & Epoch: Please select "New sampling rate" or "New epoch"';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        %%Send message to Message panel
        erpworkingmemory('f_EEG_proces_messg','Sampling Rate & Epoch');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        %%--------------------check new sampling rate----------------------
        Freq2resamp = str2num(gui_eeg_resample.nwsrate_edit.String);
        if gui_eeg_resample.nwsrate_checkbox.Value==1
            if isempty(Freq2resamp) || numel(Freq2resamp)~=1 ||any(Freq2resamp<=0)
                msgboxText='Sampling Rate & Epoch: New sampling rate must be a positive value';
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
        else
            Freq2resamp = [];
        end
        
        %%----------------------------check new time window----------------
        if gui_eeg_resample.nwtimewindow_checkbox.Value==1
            NewStart = str2num(gui_eeg_resample.nwtimewindow_editleft.String);
            if isempty(NewStart) || numel(NewStart)~=1
                msgboxText='Sampling Rate & Epoch: the left edge for the new time window must be a single value';
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            if NewStart>= observe_EEGDAT.EEG.times(end)
                msgboxText=['Sampling Rate & Epoch: the left edge for the new time window should be smaller than',32,num2str(observe_EEGDAT.times(end)),'ms'];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            
            if NewStart>=0
                msgboxText=['Sampling Rate & Epoch: the left edge for the new time window should be smaller than 0 ms'];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            
            Newend = str2num(gui_eeg_resample.nwtimewindow_editright.String);
            if isempty(Newend) || numel(Newend)~=1
                msgboxText='Sampling Rate & Epoch: the right edge for the new time window must be a single value';
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            if Newend<= observe_EEGDAT.EEG.times(1)
                msgboxText=['Sampling Rate & Epoch: the right edge for the new time window should be larger than',32,num2str(observe_EEGDAT.times(1)),'ms'];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            
            if Newend<= 0
                msgboxText=['Sampling Rate & Epoch: the right edge for the new time window should be larger than 0 ms'];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
        else
            NewStart = [];
            Newend = [];
        end
        
        estudioworkingmemory('EEGTab_resample',0);
        gui_eeg_resample.resample_run.BackgroundColor =  [1 1 1];
        gui_eeg_resample.resample_run.ForegroundColor = [0 0 0];
        box_eeg_resample.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_eeg_resample.resample_cancel.BackgroundColor =  [1 1 1];
        gui_eeg_resample.resample_cancel.ForegroundColor = [0 0 0];
        gui_eeg_resample.Paras{1} = gui_eeg_resample.nwsrate_checkbox.Value;
        gui_eeg_resample.Paras{2} = str2num(gui_eeg_resample.nwsrate_edit.String);
        gui_eeg_resample.Paras{3} = gui_eeg_resample.nwtimewindow_checkbox.Value;
        gui_eeg_resample.Paras{4} = str2num(gui_eeg_resample.nwtimewindow_editleft.String);
        gui_eeg_resample.Paras{5} = str2num(gui_eeg_resample.nwtimewindow_editright.String);
        
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray)
            EEGArray =  length(observe_EEGDAT.ALLEEG);
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(end);
            observe_EEGDAT.CURRENTSET = EEGArray;
            estudioworkingmemory('EEGArray',EEGArray);
        end
        
        erpworkingmemory('f_EEG_proces_messg','Sampling Rate & Epoch');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        ALLEEG = observe_EEGDAT.ALLEEG;
        ALLEEG_out = [];
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG(EEGArray(Numofeeg));
            if gui_eeg_resample.nwsrate_checkbox.Value==0
                Freq2resamp =  EEG.srate;
            end
            if gui_eeg_resample.nwtimewindow_checkbox.Value==0
                TimeRange = [EEG.times(1),EEG.times(end)];
            else
                TimeRange = [NewStart,Newend];
            end
            if EEG.trials>1
                [EEG, LASTCOM] = pop_resampleeg(EEG, 'Freq2resamp',Freq2resamp, 'TimeRange',TimeRange,...
                    'Saveas', 'off', 'History', 'gui');
            else
                [EEG, LASTCOM]= pop_resample( EEG, Freq2resamp);
                EEG = eeg_checkset(EEG);
            end
            EEG = eegh(LASTCOM, EEG);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            [ALLEEG_out,~,~] = pop_newset(ALLEEG_out, EEG, length(ALLEEG_out), 'gui', 'off');
        end
        if EEG.trials>1
            suffixname = 'resampeled';
        else
            suffixname = '';
        end
        
        Answer = f_EEG_save_multi_file(ALLEEG_out,1:numel(EEGArray),suffixname);
        if isempty(Answer)
            return;
        end
        if ~isempty(Answer{1})
            ALLEEG_out = Answer{1};
            Save_file_label = Answer{2};
        end
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG_out(Numofeeg);
            if Save_file_label
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
            [ALLEEG,~,~] = pop_newset(ALLEEG, EEG, length(ALLEEG), 'gui', 'off');
        end
        observe_EEGDAT.ALLEEG = ALLEEG;
        
        try
            EEGArray =  [length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1:length(observe_EEGDAT.ALLEEG)];
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1;
        catch
            EEGArray = length(observe_EEGDAT.ALLEEG);
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG);
        end
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
        estudioworkingmemory('EEGArray',EEGArray);
        
        observe_EEGDAT.eeg_panel_message =2;
        observe_EEGDAT.count_current_eeg = 1;
    end


%%--------Setting current EEGset/session history based on the current updated EEGset------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg~=8
            return;
        end
        
        if  isempty(observe_EEGDAT.EEG) || isempty(observe_EEGDAT.ALLEEG)
            Enableflag = 'off';
        else
            Enableflag = 'on';
        end
        if ~isempty(observe_EEGDAT.EEG)
            gui_eeg_resample.csrate_edit.String = num2str(observe_EEGDAT.EEG.srate);
            gui_eeg_resample.ctimewindow_editleft.String = num2str(observe_EEGDAT.EEG.times(1));
            gui_eeg_resample.ctimewindow_editright.String = num2str(observe_EEGDAT.EEG.times(end));
        else
            gui_eeg_resample.csrate_edit.String = '';
            gui_eeg_resample.ctimewindow_editleft.String = '';
            gui_eeg_resample.ctimewindow_editright.String = '';
        end
        %%----------------------new sampling rate--------------------------
        gui_eeg_resample.nwsrate_checkbox.Enable = Enableflag;
        gui_eeg_resample.nwsrate_edit.Enable = Enableflag;
        if strcmp(Enableflag,'on') && gui_eeg_resample.nwsrate_checkbox.Value==1
            gui_eeg_resample.nwsrate_edit.Enable = 'on';
            Newsrate = str2num(gui_eeg_resample.nwsrate_edit.String);
            if isempty(Newsrate) || numel(Newsrate)~=1 || any(Newsrate<=0)
                try gui_eeg_resample.nwsrate_edit.String = str2num(observe_EEGDAT.EEG.srate); catch end
            end
        else
            gui_eeg_resample.nwsrate_edit.Enable = 'off';
        end
        
        %%--------------------new tiem window------------------------------
        gui_eeg_resample.nwtimewindow_checkbox.Enable = Enableflag;
        gui_eeg_resample.nwtimewindow_editleft.Enable = Enableflag;
        gui_eeg_resample.nwtimewindow_editright.Enable = Enableflag;
        gui_eeg_resample.resample_run.Enable = Enableflag;
        gui_eeg_resample.resample_cancel.Enable = Enableflag;
        if strcmp(Enableflag,'on') && gui_eeg_resample.nwtimewindow_checkbox.Value==1
            gui_eeg_resample.nwtimewindow_editleft.Enable ='on';
            gui_eeg_resample.nwtimewindow_editright.Enable = 'on';
            NewStart = str2num(gui_eeg_resample.nwtimewindow_editleft.String);
            if isempty(NewStart) || numel(NewStart)~=1 || any(NewStart>=observe_EEGDAT.EEG.times(end))
                gui_eeg_resample.nwtimewindow_editleft.String = num2str(observe_EEGDAT.EEG.times(1));
            end
            Newend = str2num(gui_eeg_resample.nwtimewindow_editright.String);
            if isempty(Newend) || numel(Newend)~=1 || any(Newend<=observe_EEGDAT.EEG.times(1))
                gui_eeg_resample.nwtimewindow_editright.String = num2str(observe_EEGDAT.EEG.times(end));
            end
        else
            gui_eeg_resample.nwtimewindow_editleft.Enable ='off';
            gui_eeg_resample.nwtimewindow_editright.Enable = 'off';
        end
        
        if ~isempty(observe_EEGDAT.EEG)
            if observe_EEGDAT.EEG.trials==1
                enableflag = 'off';
                gui_eeg_resample.nwtimewindow_checkbox.Value=0;
            else
                enableflag = 'on';
            end
            gui_eeg_resample.nwtimewindow_checkbox.Enable=enableflag;
            gui_eeg_resample.nwtimewindow_editleft.Enable=enableflag;
            gui_eeg_resample.nwtimewindow_editright.Enable=enableflag;
        end
        
        gui_eeg_resample.Paras{1} = gui_eeg_resample.nwsrate_checkbox.Value;
        gui_eeg_resample.Paras{2} = str2num(gui_eeg_resample.nwsrate_edit.String);
        gui_eeg_resample.Paras{3} = gui_eeg_resample.nwtimewindow_checkbox.Value;
        gui_eeg_resample.Paras{4} = str2num(gui_eeg_resample.nwtimewindow_editleft.String);
        gui_eeg_resample.Paras{5} = str2num(gui_eeg_resample.nwtimewindow_editright.String);
        
        observe_EEGDAT.count_current_eeg=9;
    end


%%-------execute "apply" before doing any change for other panels----------
%     function EEG_two_panels_change(~,~)
%         if  isempty(observe_EEGDAT.ALLEEG)|| isempty(observe_EEGDAT.EEG)
%             return;
%         end
%         ChangeFlag =  estudioworkingmemory('EEGTab_resample');
%         if ChangeFlag~=1
%             return;
%         end
%         resample_run();
%         estudioworkingmemory('EEGTab_resample',0);
%         gui_eeg_resample.resample_run.BackgroundColor =  [1 1 1];
%         gui_eeg_resample.resample_run.ForegroundColor = [0 0 0];
%         box_eeg_resample.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
%         gui_eeg_resample.resample_cancel.BackgroundColor =  [1 1 1];
%         gui_eeg_resample.resample_cancel.ForegroundColor = [0 0 0];
%     end

%%--------------press return to execute "Apply"----------------------------
    function EEG_resample_presskey(~,eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('EEGTab_resample');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            resample_run();
            estudioworkingmemory('EEGTab_resample',0);
            gui_eeg_resample.resample_run.BackgroundColor =  [1 1 1];
            gui_eeg_resample.resample_run.ForegroundColor = [0 0 0];
            box_eeg_resample.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
            gui_eeg_resample.resample_cancel.BackgroundColor =  [1 1 1];
            gui_eeg_resample.resample_cancel.ForegroundColor = [0 0 0];
        else
            return;
        end
    end

%%--------------reset this panel with the default parameters---------------
    function Reset_eeg_panel_change(~,~)
        if observe_EEGDAT.Reset_EEG_paras_panel~=7
            return;
        end
        estudioworkingmemory('EEGTab_resample',0);
        gui_eeg_resample.resample_run.BackgroundColor =  [1 1 1];
        gui_eeg_resample.resample_run.ForegroundColor = [0 0 0];
        box_eeg_resample.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_eeg_resample.resample_cancel.BackgroundColor =  [1 1 1];
        gui_eeg_resample.resample_cancel.ForegroundColor = [0 0 0];
        if ~isempty(observe_EEGDAT.EEG)
            gui_eeg_resample.csrate_edit.String = num2str(observe_EEGDAT.EEG.srate);
            gui_eeg_resample.ctimewindow_editleft.String = num2str(observe_EEGDAT.EEG.times(1));
            gui_eeg_resample.ctimewindow_editright.String = num2str(observe_EEGDAT.EEG.times(end));
        else
            gui_eeg_resample.csrate_edit.String = '';
            gui_eeg_resample.ctimewindow_editleft.String = '';
            gui_eeg_resample.ctimewindow_editright.String = '';
        end
        gui_eeg_resample.nwsrate_checkbox.Value=0;
        gui_eeg_resample.nwsrate_edit.Enable = 'off';
        gui_eeg_resample.nwsrate_edit.String='';
        gui_eeg_resample.nwtimewindow_editleft.Enable ='off';
        gui_eeg_resample.nwtimewindow_editright.Enable = 'off';
        gui_eeg_resample.nwtimewindow_checkbox.Value=0;
        gui_eeg_resample.nwtimewindow_editleft.String ='';
        gui_eeg_resample.nwtimewindow_editright.String = '';
        if ~isempty(observe_EEGDAT.EEG)
            if observe_EEGDAT.EEG.trials==1
                enableflag = 'off';
            else
                enableflag = 'on';
            end
            gui_eeg_resample.nwtimewindow_checkbox.Enable=enableflag;
            gui_eeg_resample.nwtimewindow_editleft.Enable=enableflag;
            gui_eeg_resample.nwtimewindow_editright.Enable=enableflag;
        end
        observe_EEGDAT.Reset_EEG_paras_panel=8;
    end
end