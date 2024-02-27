%%This function is to detect artifacts for continuous EEG.


% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Oct. 2023


function varargout = f_EEG_arf_det_conus_GUI(varargin)

global observe_EEGDAT;
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
addlistener(observe_EEGDAT,'Reset_eeg_panel_change',@Reset_eeg_panel_change);


%---------------------------Initialize parameters------------------------------------
Eegtab_EEG_art_det_conus = struct();
%-----------------------------Name the title----------------------------------------------

% global Eegtab_box_art_det_conus;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    Eegtab_box_art_det_conus = uiextras.BoxPanel('Parent', fig, 'Title', 'Reject Artifactual Time Segments (Continuous EEG)',...
        'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    Eegtab_box_art_det_conus = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Reject Artifactual Time Segments (Continuous EEG)',...
        'Padding', 5,'BackgroundColor',ColorB_def);
else
    Eegtab_box_art_det_conus = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Reject Artifactual Time Segments (Continuous EEG)',...
        'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);%, 'HelpFcn', @art_help
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

drawui_art_det_conus_eeg(FonsizeDefault)
varargout{1} = Eegtab_box_art_det_conus;

    function drawui_art_det_conus_eeg(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        Eegtab_EEG_art_det_conus.DataSelBox = uiextras.VBox('Parent', Eegtab_box_art_det_conus,'BackgroundColor',ColorB_def);
        FontSize_defualt = FonsizeDefault;
        if isempty(FontSize_defualt)
            FontSize_defualt = 12;
        end
        if isempty(observe_EEGDAT.EEG)
            EnableFlag = 'off';
        else
            EnableFlag = 'on';
        end
        
        %%channels that detect artifact
        Eegtab_EEG_art_det_conus.chan_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_conus.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',Eegtab_EEG_art_det_conus.chan_title,...
            'String','Chans:','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        Eegtab_EEG_art_det_conus.chan_edit = uicontrol('Style','edit','Parent',Eegtab_EEG_art_det_conus.chan_title,...
            'String','','FontSize',FontSize_defualt,'callback',@chan_edit,'Enable',EnableFlag,'BackgroundColor',[1 1 1]); % 2F
        Eegtab_EEG_art_det_conus.chan_edit.KeyPressFcn=  @eeg_artdetect_presskey;
        Eegtab_EEG_art_det_conus.chan_browse = uicontrol('Style','pushbutton','Parent',Eegtab_EEG_art_det_conus.chan_title,...
            'String','Browse','FontSize',FontSize_defualt,'callback',@chan_browse,'Enable',EnableFlag,'BackgroundColor',[1 1 1]); % 2F
        set( Eegtab_EEG_art_det_conus.chan_title,'Sizes',[60 -1 80]);
        
        
        %%Voltage limits
        Eegtab_EEG_art_det_conus.voltage_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_conus.DataSelBox,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_conus.voltage_text = uicontrol('Style','text','Parent',Eegtab_EEG_art_det_conus.voltage_title,...
            'String',[32,'Voltage threshold',32,32,32,32,'(1 or 2 values)'],'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def); % 2F
        Eegtab_EEG_art_det_conus.voltage_edit = uicontrol('Style','edit','Parent',Eegtab_EEG_art_det_conus.voltage_title,...
            'callback',@voltage_edit,'String','','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',[1 1 1]); % 2F
        Eegtab_EEG_art_det_conus.voltage_edit.KeyPressFcn=  @eeg_artdetect_presskey;
        set(Eegtab_EEG_art_det_conus.voltage_title,'Sizes',[120,-1]);
        
        
        %%moving window full width
        Eegtab_EEG_art_det_conus.movewindow_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_conus.DataSelBox,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_conus.movewindow_text = uicontrol('Style','text','Parent',Eegtab_EEG_art_det_conus.movewindow_title,...
            'String','Move window width [ms] (e.g., 500)','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def); % 2F
        Eegtab_EEG_art_det_conus.movewindow_edit = uicontrol('Style','edit','Parent',Eegtab_EEG_art_det_conus.movewindow_title,...
            'callback',@movewindow_edit,'String','','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',[1 1 1]); % 2F
        Eegtab_EEG_art_det_conus.movewindow_edit.KeyPressFcn=  @eeg_artdetect_presskey;
        set(Eegtab_EEG_art_det_conus.movewindow_title,'Sizes',[120,-1]);
        
        %%Window steps
        Eegtab_EEG_art_det_conus.windowstep_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_conus.DataSelBox,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_conus.windowstep_text = uicontrol('Style','text','Parent',Eegtab_EEG_art_det_conus.windowstep_title,...
            'String','Window step [ms] (e.g., 250)','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def); % 2F
        Eegtab_EEG_art_det_conus.windowstep_edit = uicontrol('Style','edit','Parent',Eegtab_EEG_art_det_conus.windowstep_title,...
            'callback',@windowstep_edit,'String','','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',[1 1 1]); % 2F
        Eegtab_EEG_art_det_conus.windowstep_edit.KeyPressFcn=  @eeg_artdetect_presskey;
        set(Eegtab_EEG_art_det_conus.windowstep_title,'Sizes',[120,-1]);
        
        
        %%-----------------------Cancel and Run----------------------------
        Eegtab_EEG_art_det_conus.detar_run_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_conus.DataSelBox,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_conus.detectar_advanced = uicontrol('Style', 'pushbutton','Parent',Eegtab_EEG_art_det_conus.detar_run_title,...
            'String','Advanced','callback',@detectar_advanced,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        Eegtab_EEG_art_det_conus.detectar_preview = uicontrol('Style', 'pushbutton','Parent',Eegtab_EEG_art_det_conus.detar_run_title,...
            'String','Preview','callback',@detectar_preview,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        Eegtab_EEG_art_det_conus.detectar_run = uicontrol('Style','pushbutton','Parent',Eegtab_EEG_art_det_conus.detar_run_title,...
            'String','Finalize','callback',@detectar_run,'FontSize',FontSize_defualt,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        set(Eegtab_EEG_art_det_conus.DataSelBox,'Sizes',[30 35 35 35 30]);
        estudioworkingmemory('EEGTab_detect_arts_conus',0);
    end


%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%-----------------------artifact detection help---------------------------
%     function art_help(~,~)
%         web(' https://github.com/ucdavis/erplab/wiki/Artifact-Rejection-in-Continuous-Data/','-browser');
%     end

%%----------------------edit chans-----------------------------------------
    function chan_edit(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=10
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_art_det_conus.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_preview.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_preview.ForegroundColor = [1 1 1];
        Eegtab_EEG_art_det_conus.detectar_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_run.ForegroundColor = [1 1 1];
        Eegtab_EEG_art_det_conus.detectar_advanced.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_advanced.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_conus',1);
        ChaNum = observe_EEGDAT.EEG.nbchan;
        ChanArray = str2num(Source.String);
        if isempty(ChanArray) || min(ChanArray(:))<=0 || max(ChanArray(:))<=0
            erpworkingmemory('f_EEG_proces_messg','Reject Artifactual Time Segments (Continuous EEG) >  Index(es) of chans should be positive number(s)');
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String= vect2colon([1:ChaNum]);
            return;
        end
        
        if min(ChanArray(:))> ChaNum || max(ChanArray(:)) > ChaNum
            erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) >  Index(es) of chans should be between 1 and ',32,num2str(ChaNum)]);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String= vect2colon([1:ChaNum]);
            return;
        end
    end

%%----------------------------Browse chans---------------------------------
    function chan_browse(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=10
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        Eegtab_box_art_det_conus.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_preview.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_preview.ForegroundColor = [1 1 1];
        Eegtab_EEG_art_det_conus.detectar_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_run.ForegroundColor = [1 1 1];
        Eegtab_EEG_art_det_conus.detectar_advanced.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_advanced.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_conus',1);
        
        %%-------Browse and select chans that will be interpolated---------
        EEG = observe_EEGDAT.EEG;
        for Numofchan = 1:EEG.nbchan
            try
                listb{Numofchan}= strcat(num2str(Numofchan),'.',EEG.chanlocs(Numofchan).labels);
            catch
                listb{Numofchan}= strcat('Chan:',32,num2str(Numofchan));
            end
        end
        ChanArray = str2num(Eegtab_EEG_art_det_conus.chan_edit.String);
        if isempty(ChanArray)
            indxlistb = EEG.nbchan;
        else
            if min(ChanArray(:)) >0  && max(ChanArray(:)) <= EEG.nbchan
                indxlistb = ChanArray;
            else
                indxlistb = 1:EEG.nbchan;
            end
        end
        titlename = 'Select Channel(s):';
        
        chan_label_select = browsechanbinGUI(listb, indxlistb, titlename);
        if ~isempty(chan_label_select)
            Eegtab_EEG_art_det_conus.chan_edit.String  = vect2colon(chan_label_select);
        else
            beep;
            %disp('User selected Cancel');
            return
        end
        
    end


%%-----------------------------volatge-------------------------------------
    function voltage_edit(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=10
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_art_det_conus.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_preview.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_preview.ForegroundColor = [1 1 1];
        Eegtab_EEG_art_det_conus.detectar_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_run.ForegroundColor = [1 1 1];
        Eegtab_EEG_art_det_conus.detectar_advanced.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_advanced.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_conus',1);
        Voltagevalue= str2num(Source.String);
        if isempty(Voltagevalue) || (numel(Voltagevalue)~=1 && numel(Voltagevalue)~=2)
            erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Voltage threshold must have one or two values']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String = '500';
            return;
        end
        if numel(Voltagevalue)==2
            if Voltagevalue(2) >= Voltagevalue(1)
                erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Voltage threshold: When 2 thresholds are specified, the first one must be lesser than the second one']);
                observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
                Source.String = '500';
                return;
            end
        end
        
    end


%%------------------------moving window------------------------------------
    function movewindow_edit(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=10
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_art_det_conus.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_preview.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_preview.ForegroundColor = [1 1 1];
        Eegtab_EEG_art_det_conus.detectar_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_run.ForegroundColor = [1 1 1];
        Eegtab_EEG_art_det_conus.detectar_advanced.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_advanced.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_conus',1);
        windowlength= str2num(Source.String);
        if isempty(windowlength) || numel(windowlength) ~=1 ||  min(windowlength(:))<=0
            erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Move window width must be a positive number']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String = '500';
            return;
        end
        
        windowStep = str2num(Eegtab_EEG_art_det_conus.windowstep_edit.String);
        if windowlength <= max(windowStep(:))
            erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Step width cannot be larger than the window width']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            %             Source.String = '';
            return;
        end
    end


%%-------------------------moving step-------------------------------------
    function windowstep_edit(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=10
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_art_det_conus.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_preview.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_preview.ForegroundColor = [1 1 1];
        Eegtab_EEG_art_det_conus.detectar_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_run.ForegroundColor = [1 1 1];
        Eegtab_EEG_art_det_conus.detectar_advanced.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_advanced.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_conus',1);
        windowstep= str2num(Source.String);
        if isempty(windowstep) || numel(windowstep) ~=1 ||  min(windowstep(:))<=0
            erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Window step width must be a positive number']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String = '';
            return;
        end
        
        windowStep = str2num(Eegtab_EEG_art_det_conus.windowstep_edit.String);
        windowlength = str2num(Eegtab_EEG_art_det_conus.movewindow_edit.String);
        if windowlength <= max(windowStep(:))
            erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Step width must be smaller than the window width']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            %             Source.String = '';
            return;
        end
    end


%%--------------------------advanced options-------------------------------
    function detectar_advanced(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=10
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','Reject Artifactual Time Segments (Continuous EEG) > Advanced');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        Eegtab_box_art_det_conus.TitleColor= [0.0500    0.2500    0.5000];
        Eegtab_EEG_art_det_conus.detectar_preview.BackgroundColor =  [1 1 1];
        Eegtab_EEG_art_det_conus.detectar_preview.ForegroundColor = [0 0 0];
        Eegtab_EEG_art_det_conus.detectar_run.BackgroundColor =  [ 1 1 1];
        Eegtab_EEG_art_det_conus.detectar_run.ForegroundColor = [0 0 0];
        Eegtab_EEG_art_det_conus.detectar_advanced.BackgroundColor =  [ 1 1 1];
        Eegtab_EEG_art_det_conus.detectar_advanced.ForegroundColor = [0 0 0];
        estudioworkingmemory('EEGTab_detect_arts_conus',0);
        %%--------Selected EEGsets-----------
        EEGArray= estudioworkingmemory('EEGArray');
        if isempty(EEGArray) || min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) || max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG)
            EEGArray = observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',EEGArray);
        end
        
        %%chans
        ChanArray = str2num(Eegtab_EEG_art_det_conus.chan_edit.String);
        nbchan = observe_EEGDAT.EEG.nbchan;
        if isempty(ChanArray) || min(ChanArray(:)) <=0 || max(ChanArray(:)) <=0 || min(ChanArray(:)) > nbchan || max(ChanArray(:)) > nbchan
            erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Advanced: Chans are empty or index(es) are not between 1 and',32,num2str(nbchan)]);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            return;
        end
        
        %%----------if simple voltage threshold------------
        Volthreshold = sort(str2num(Eegtab_EEG_art_det_conus.voltage_edit.String));
        if isempty(Volthreshold) || (numel(Volthreshold)~=1 && numel(Volthreshold)~=2)
            erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Advanced: Voltage threshold must have one or two values']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            return;
        end
        
        if numel(Volthreshold)==2
            if Volthreshold(2) >= Volthreshold(1)
                erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Advanced: When 2 thresholds are specified, the first one must be lesser than the second one']);
                observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
                return;
            end
        end
        
        %
        %%Moving window full width
        WindowLength = str2num(Eegtab_EEG_art_det_conus.movewindow_edit.String);
        if isempty(WindowLength) || numel(WindowLength) ~=1 ||  min(WindowLength(:))<=0
            erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Advanced: Move window width must be a positive number']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String = '500';
            return;
        end
        
        windowStep = str2num(Eegtab_EEG_art_det_conus.windowstep_edit.String);
        if WindowLength <= max(windowStep(:))
            erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Advanced: Step width cannot be larger than the window width']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String = '';
            return;
        end
        
        if isempty(windowStep) || numel(windowStep) ~=1 ||  min(windowStep(:))<=0
            erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Advanced: Window step width must be a positive number']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String = '';
            return;
        end
        %%WindowStep
        if WindowLength <= max(windowStep(:))
            erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Advanced: Step width must be smaller than the window width']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String = '';
            return;
        end
        EEG = observe_EEGDAT.EEG;
        memoryCARTGUI   = erpworkingmemory('continuousartifactGUI');
        if isempty(memoryCARTGUI)
            memoryCARTGUI.prompt     = {'Threshold (1 or 2 values)', 'Moving Windows Width (ms)',...
                'Window Step (ms)','Channel(s)', 'Frequency cutoffs (Hz)', 'lowest freq', 'highest freq'};
            memoryCARTGUI.dlg_title  =  'Input threshold';
            memoryCARTGUI.def        = {500 500 250 [1:EEG.nbchan] [] [] [] 0 0 0 0};
            memoryCARTGUI.defx       = memoryCARTGUI.def  ;
            memoryCARTGUI.colorseg   = [1.0000    0.9765    0.5294]; % default
            memoryCARTGUI.def{1}   = Volthreshold;
            memoryCARTGUI.def{2}   =WindowLength;
            memoryCARTGUI.def{3}   =windowStep;
            memoryCARTGUI.def{4}   =ChanArray;
        else
            try
                memoryCARTGUI.def{1}   = Volthreshold;
                memoryCARTGUI.def{2}   =WindowLength;
                memoryCARTGUI.def{3}   =windowStep;
                memoryCARTGUI.def{4}   =ChanArray;
            catch
                memoryCARTGUI.def   = {Volthreshold WindowLength windowStep ChanArray [] [] [] 0 0 0 0};
            end
        end
        erpworkingmemory('continuousartifactGUI',memoryCARTGUI);
        
        %
        % Call GUI
        %
        
        answer    = continuousartifactGUI(EEG.srate, EEG.nbchan, EEG.chanlocs);
        if isempty(answer)
            %             disp('User selected Cancel')
            observe_EEGDAT.eeg_panel_message =2;
            return
        end
        
        ampth     = answer{1};
        winms     = answer{2};
        stepms    = answer{3};
        chanArray = answer{4};
        fcutoff   = [answer{5} answer{6}];
        includef  = answer{7};
        
        if ~isempty(includef)
            if includef==0 && fcutoff(1)~=fcutoff(2)% when it means "excluded" frequency cuttof is inverse to make a notch filter
                fcutoff = circshift(fcutoff',1)';
            elseif includef==1 && fcutoff(1)==0 && fcutoff(2)==0
                fcutoff = [inf inf]; % [inf inf] to include the mean of data; fcutoff = [0 0] means exclude the mean
            else
                %...
            end
        end
        
        forder          = 100; % fixed order when GUI is used
        firstdet        = answer{8};
        if firstdet==1
            fdet = 'on';
        else
            fdet = 'off';
        end
        shortisi        = answer{9};
        shortseg        = answer{10};
        winoffset       = answer{11};
        memoryCARTGUI   = erpworkingmemory('continuousartifactGUI');
        try
            colorseg        = memoryCARTGUI.colorseg;
        catch
            colorseg = [ 0.83 0.82 0.79];
        end
        if isempty(colorseg) || numel(colorseg)~=3 || max(colorseg(:))>1 || min(colorseg(:))<0
            colorseg = [ 0.83 0.82 0.79];
        end
        try
            def   = memoryCARTGUI.def;
        catch
            def = [];
        end
        
        %%update parameters for current panel
        if ~isempty(def)
            Volthreshold = def{1};
            WindowLength = def{2};
            windowStep = def{3};
            ChanArray = def{4};
            Eegtab_EEG_art_det_conus.chan_edit.String = vect2colon(ChanArray);
            Eegtab_EEG_art_det_conus.voltage_edit.String = num2str(Volthreshold);
            Eegtab_EEG_art_det_conus.movewindow_edit.String = num2str(WindowLength);
            Eegtab_EEG_art_det_conus.windowstep_edit.String = num2str(windowStep);
        end
        
        ALLEEG = observe_EEGDAT.ALLEEG;
        ALLEEG_out = [];
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Reject Artifactual Time Segments (Continuous EEG) > Advanced*',32,32,32,32,datestr(datetime('now')),'\n']);
            
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            if max(chanArray(:)) > EEG.nbchan
                chanArray = [1:EEG.nbchan];
                fprintf(['We used all chans for the EEGset because the defined ones were invalid']);
            end
            [EEG,LASTCOM]= pop_continuousartdet(EEG, 'chanArray'   , chanArray    ...
                , 'ampth'       , ampth        ...
                , 'winms'       , winms        ...
                , 'stepms'      , stepms       ...
                , 'firstdet'    , fdet         ...
                , 'fcutoff'     , fcutoff      ...
                , 'forder'      , forder       ...
                , 'shortisi'    , shortisi     ...
                , 'shortseg'    , shortseg     ...
                , 'winoffset'   , winoffset    ...
                , 'colorseg'    , colorseg     ...
                ,'review','on','History','implicit');
            
            if isempty(LASTCOM)
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            if Numofeeg==1
                eegh(LASTCOM);
            end
            fprintf([LASTCOM,'\n']);
            EEG = eegh(LASTCOM, EEG);
            
            [ALLEEG_out,~,~,LASTCOM] = pop_newset(ALLEEG_out, EEG, length(ALLEEG_out), 'gui', 'off');
            fprintf( [repmat('-',1,100) '\n']);
            if Numofeeg==1
                eegh(LASTCOM);
            end
        end%%end for loop of subjects
        Save_file_label = 0;
        Answer = f_EEG_save_multi_file(ALLEEG_out,1:numel(EEGArray),'_rmar');
        if isempty(Answer)
            return;
        end
        if ~isempty(Answer{1})
            ALLEEG_out = Answer{1};
            Save_file_label = Answer{2};
        end
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG_out(Numofeeg);
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

%%%----------------------Preview------------------------------------
    function detectar_preview(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=10
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','Reject Artifactual Time Segments (Continuous EEG) > Preview');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        %%--------Selected EEGsets-----------
        EEGArray= estudioworkingmemory('EEGArray');
        if numel(EEGArray)~=1
            erpworkingmemory('f_EEG_proces_messg','Reject Artifactual Time Segments (Continuous EEG) > Preview: Only work for single EEG');
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String = 'Only for single EEG';
            Source.Enable = 'off';
            return;
        end
        
        Eegtab_box_art_det_conus.TitleColor= [0.0500    0.2500    0.5000];
        Eegtab_EEG_art_det_conus.detectar_preview.BackgroundColor =  [1 1 1];
        Eegtab_EEG_art_det_conus.detectar_preview.ForegroundColor = [0 0 0];
        Eegtab_EEG_art_det_conus.detectar_run.BackgroundColor =  [ 1 1 1];
        Eegtab_EEG_art_det_conus.detectar_run.ForegroundColor = [0 0 0];
        Eegtab_EEG_art_det_conus.detectar_advanced.BackgroundColor =  [ 1 1 1];
        Eegtab_EEG_art_det_conus.detectar_advanced.ForegroundColor = [0 0 0];
        estudioworkingmemory('EEGTab_detect_arts_conus',0);
        
        %%chans
        ChanArray = str2num(Eegtab_EEG_art_det_conus.chan_edit.String);
        nbchan = observe_EEGDAT.EEG.nbchan;
        if isempty(ChanArray) || min(ChanArray(:)) <=0 || max(ChanArray(:)) <=0 || min(ChanArray(:)) > nbchan || max(ChanArray(:)) > nbchan
            erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Preview: Chans are empty or index(es) are not between 1 and',32,num2str(nbchan)]);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            return;
        end
        %%----------if simple voltage threshold------------
        Volthreshold = sort(str2num(Eegtab_EEG_art_det_conus.voltage_edit.String));
        if isempty(Volthreshold) || (numel(Volthreshold)~=1 && numel(Volthreshold)~=2)
            erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Preview: Voltage threshold must have one or two values']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            
            return;
        end
        
        if numel(Volthreshold)==2
            if Volthreshold(2) >= Volthreshold(1)
                erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Preview: When 2 thresholds are specified, the first one must be lesser than the second one']);
                observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
                return;
            end
        end
        
        %
        %%Moving window full width
        WindowLength = str2num(Eegtab_EEG_art_det_conus.movewindow_edit.String);
        if isempty(WindowLength) || numel(WindowLength) ~=1 ||  min(WindowLength(:))<=0
            erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Preview: Move window width must be a positive number']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String = '500';
            return;
        end
        
        windowStep = str2num(Eegtab_EEG_art_det_conus.windowstep_edit.String);
        if WindowLength <= max(windowStep(:))
            erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Preview: Step width cannot be larger than the window width']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String = '';
            return;
        end
        
        if isempty(windowStep) || numel(windowStep) ~=1 ||  min(windowStep(:))<=0
            erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Preview: Window step width must be a positive number']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String = '';
            return;
        end
        %%WindowStep
        if WindowLength <= max(windowStep(:))
            erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Preview: Step width must be smaller than the window width']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String = '';
            return;
        end
        memoryCARTGUI   = erpworkingmemory('continuousartifactGUI');
        try
            colorseg        = memoryCARTGUI.colorseg;
        catch
            colorseg = [ 0.83 0.82 0.79];
        end
        if isempty(colorseg) || numel(colorseg)~=3 || max(colorseg(:))>1 || min(colorseg(:))<0
            colorseg = [ 0.83 0.82 0.79];
        end
        
        try
            EEG = observe_EEGDAT.ALLEEG(EEGArray);
        catch
            EEG = observe_EEGDAT.EEG;
        end
        fprintf( ['\n\n',repmat('-',1,100) '\n']);
        fprintf(['*Reject Artifactual Time Segments (Continuous EEG) > Preview*',32,32,32,32,datestr(datetime('now')),'\n']);
        fprintf(['Your current EEGset(No.',num2str(EEGArray),'):',32,EEG.setname,'\n\n']);
        
        [EEG,LASTCOM]= pop_continuousartdet( EEG , 'ampth',  Volthreshold, 'chanArray',  ChanArray, 'colorseg', colorseg,...
            'firstdet', 'on', 'forder',  100,'numChanThreshold',  1, 'stepms',  windowStep, 'threshType', 'peak-to-peak',...
            'winms',  WindowLength,'review','on','History','implicit' );
        if isempty(LASTCOM)
        else
            fprintf([LASTCOM,'\n']);
        end
        eegh(LASTCOM);
        fprintf( [repmat('-',1,100) '\n']);
        erpworkingmemory('f_EEG_proces_messg','Reject Artifactual Time Segments (Continuous EEG) > Preview');
        observe_EEGDAT.eeg_panel_message =2; %%Marking for the procedure has been started.
    end


%%-----------------------Finalize------------------------------------------
    function detectar_run(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=10
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','Reject Artifactual Time Segments (Continuous EEG) > Finalize');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        Eegtab_box_art_det_conus.TitleColor= [0.0500    0.2500    0.5000];
        Eegtab_EEG_art_det_conus.detectar_preview.BackgroundColor =  [1 1 1];
        Eegtab_EEG_art_det_conus.detectar_preview.ForegroundColor = [0 0 0];
        Eegtab_EEG_art_det_conus.detectar_run.BackgroundColor =  [ 1 1 1];
        Eegtab_EEG_art_det_conus.detectar_run.ForegroundColor = [0 0 0];
        Eegtab_EEG_art_det_conus.detectar_advanced.BackgroundColor =  [ 1 1 1];
        Eegtab_EEG_art_det_conus.detectar_advanced.ForegroundColor = [0 0 0];
        estudioworkingmemory('EEGTab_detect_arts_conus',0);
        %%--------Selected EEGsets-----------
        EEGArray= estudioworkingmemory('EEGArray');
        if isempty(EEGArray) || min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) || max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG)
            EEGArray = observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',EEGArray);
        end
        
        %%chans
        ChanArray = str2num(Eegtab_EEG_art_det_conus.chan_edit.String);
        nbchan = observe_EEGDAT.EEG.nbchan;
        if isempty(ChanArray) || min(ChanArray(:)) <=0 || max(ChanArray(:)) <=0 || min(ChanArray(:)) > nbchan || max(ChanArray(:)) > nbchan
            erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Finalize: Chans are empty or index(es) are not between 1 and',32,num2str(nbchan)]);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            return;
        end
        
        %%----------if simple voltage threshold------------
        Volthreshold = sort(str2num(Eegtab_EEG_art_det_conus.voltage_edit.String));
        if isempty(Volthreshold) || (numel(Volthreshold)~=1 && numel(Volthreshold)~=2)
            erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Finalize: Voltage threshold must have one or two values']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            return;
        end
        
        if numel(Volthreshold)==2
            if Volthreshold(2) >= Volthreshold(1)
                erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Finalize: When 2 thresholds are specified, the first one must be lesser than the second one']);
                observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
                return;
            end
        end
        
        %
        %%Moving window full width
        WindowLength = str2num(Eegtab_EEG_art_det_conus.movewindow_edit.String);
        if isempty(WindowLength) || numel(WindowLength) ~=1 ||  min(WindowLength(:))<=0
            erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Finalize: Move window width must be a positive number']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String = '500';
            return;
        end
        
        windowStep = str2num(Eegtab_EEG_art_det_conus.windowstep_edit.String);
        if WindowLength <= max(windowStep(:))
            erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Finalize: Step width cannot be larger than the window width']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String = '';
            return;
        end
        
        if isempty(windowStep) || numel(windowStep) ~=1 ||  min(windowStep(:))<=0
            erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Finalize: Window step width must be a positive number']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String = '';
            return;
        end
        %%WindowStep
        if WindowLength <= max(windowStep(:))
            erpworkingmemory('f_EEG_proces_messg',['Reject Artifactual Time Segments (Continuous EEG) > Finalize: Step width must be smaller than the window width']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String = '';
            return;
        end
        
        memoryCARTGUI   = erpworkingmemory('continuousartifactGUI');
        try
            colorseg        = memoryCARTGUI.colorseg;
        catch
            colorseg = [ 0.83 0.82 0.79];
        end
        if isempty(colorseg) || numel(colorseg)~=3 || max(colorseg(:))>1 || min(colorseg(:))<0
            colorseg = [ 0.83 0.82 0.79];
        end
        ALLEEG = observe_EEGDAT.ALLEEG;
        ALLEEG_out = [];
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Reject Artifactual Time Segments (Continuous EEG) > Finalize*',32,32,32,32,datestr(datetime('now')),'\n']);
            
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            if any(ChanArray(:) > EEG.nbchan)
                ChanArray = [1:EEG.nbchan];
                fprintf(['We used all chans for the EEGset because the defined ones were invalid']);
            end
            [EEG,LASTCOM]= pop_continuousartdet( EEG , 'ampth',  Volthreshold, 'chanArray',  ChanArray, 'colorseg', colorseg,...
                'firstdet', 'off', 'forder',  100,'numChanThreshold',  1, 'stepms',  windowStep, 'threshType', 'peak-to-peak',...
                'winms',  WindowLength,'review','off','History','script' );
            
            if isempty(LASTCOM)
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            
            fprintf([LASTCOM,'\n']);
            EEG = eegh(LASTCOM, EEG);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            [ALLEEG_out,~,~] = pop_newset(ALLEEG_out, EEG, length(ALLEEG_out), 'gui', 'off');
            fprintf( [repmat('-',1,100) '\n']);
            if Numofeeg==1
                eegh(LASTCOM);
            end
        end%%end for loop of subjects
        Answer = f_EEG_save_multi_file(ALLEEG_out,1:numel(EEGArray),'_rmar');
        if isempty(Answer)
            return;
        end
        if ~isempty(Answer{1})
            ALLEEG_out = Answer{1};
            Save_file_label = Answer{2};
        end
        for Numofeeg =  1:numel(EEGArray)
            EEG = ALLEEG_out(Numofeeg);
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
            [ALLEEG,~,~] = pop_newset(ALLEEG, EEG, length(ALLEEG), 'gui', 'off');
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
        if observe_EEGDAT.count_current_eeg ~=14
            return;
        end
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Eegtab_EEG_art_det_conus.chan_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.chan_browse.Enable= 'off';
            Eegtab_EEG_art_det_conus.voltage_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.movewindow_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.windowstep_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.detectar_advanced.Enable= 'off';
            Eegtab_EEG_art_det_conus.detectar_preview.Enable= 'off';
            Eegtab_EEG_art_det_conus.detectar_run.Enable= 'off';
            if ~isempty(observe_EEGDAT.EEG) && observe_EEGDAT.EEG.trials ~=1
                Eegtab_box_art_det_conus.TitleColor= [0.75 0.75 0.75];
            else
                Eegtab_box_art_det_conus.TitleColor= [0.0500    0.2500    0.5000];
            end
            observe_EEGDAT.count_current_eeg=15;
            return;
        end
        
        Eegtab_box_art_det_conus.TitleColor= [0.0500    0.2500    0.5000];
        Eegtab_EEG_art_det_conus.chan_edit.Enable= 'on';
        Eegtab_EEG_art_det_conus.chan_browse.Enable= 'on';
        Eegtab_EEG_art_det_conus.periods_edit.Enable= 'on';
        Eegtab_EEG_art_det_conus.voltage_edit.Enable= 'on';
        Eegtab_EEG_art_det_conus.movewindow_edit.Enable= 'on';
        Eegtab_EEG_art_det_conus.windowstep_edit.Enable= 'on';
        Eegtab_EEG_art_det_conus.detectar_advanced.Enable= 'on';
        Eegtab_EEG_art_det_conus.detectar_preview.Enable= 'on';
        Eegtab_EEG_art_det_conus.detectar_run.Enable= 'on';
        
        EEGArray= estudioworkingmemory('EEGArray');
        if numel(EEGArray)~=1
            Eegtab_EEG_art_det_conus.detectar_preview.String = 'Only for single EEG';
            Eegtab_EEG_art_det_conus.detectar_preview.Enable = 'off';
        else
            Eegtab_EEG_art_det_conus.detectar_preview.String = 'Preview';
            Eegtab_EEG_art_det_conus.detectar_preview.Enable = 'on';
        end
        chanArray = str2num(Eegtab_EEG_art_det_conus.chan_edit.String);
        if isempty(chanArray) || min(chanArray(:)) > observe_EEGDAT.EEG.nbchan || max(chanArray(:)) > observe_EEGDAT.EEG.nbchan
            Eegtab_EEG_art_det_conus.chan_edit.String = vect2colon([1:observe_EEGDAT.EEG.nbchan]);
        end
        %%set default parameters
        if isempty(str2num(Eegtab_EEG_art_det_conus.voltage_edit.String))
            Eegtab_EEG_art_det_conus.voltage_edit.String = '500';
        end
        if isempty(str2num(Eegtab_EEG_art_det_conus.movewindow_edit.String))
            Eegtab_EEG_art_det_conus.movewindow_edit.String = '500';
        end
        if isempty(str2num(Eegtab_EEG_art_det_conus.windowstep_edit.String))
            Eegtab_EEG_art_det_conus.windowstep_edit.String = '250';
        end
        observe_EEGDAT.count_current_eeg=15;
    end



%%--------------press return to execute "Apply"----------------------------
    function eeg_artdetect_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('EEGTab_detect_arts_conus');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            detectar_run();
            estudioworkingmemory('EEGTab_detect_arts_conus',0);
            Eegtab_box_art_det_conus.TitleColor= [0.0500    0.2500    0.5000];
            Eegtab_EEG_art_det_conus.detectar_preview.BackgroundColor =  [1 1 1];
            Eegtab_EEG_art_det_conus.detectar_preview.ForegroundColor = [0 0 0];
            Eegtab_EEG_art_det_conus.detectar_run.BackgroundColor =  [ 1 1 1];
            Eegtab_EEG_art_det_conus.detectar_run.ForegroundColor = [0 0 0];
            Eegtab_EEG_art_det_conus.detectar_advanced.BackgroundColor =  [ 1 1 1];
            Eegtab_EEG_art_det_conus.detectar_advanced.ForegroundColor = [0 0 0];
        else
            return;
        end
    end

%%-------------------Auomatically execute "apply"--------------------------
%     function eeg_two_panels_change(~,~)
%         if  isempty(observe_EEGDAT.EEG)
%             return;
%         end
%         ChangeFlag =  estudioworkingmemory('EEGTab_detect_arts_conus');
%         if ChangeFlag~=1
%             return;
%         end
%         detectar_run();
%         estudioworkingmemory('EEGTab_detect_arts_conus',0);
%         Eegtab_box_art_det_conus.TitleColor= [0.0500    0.2500    0.5000];
%         Eegtab_EEG_art_det_conus.detectar_preview.BackgroundColor =  [1 1 1];
%         Eegtab_EEG_art_det_conus.detectar_preview.ForegroundColor = [0 0 0];
%         Eegtab_EEG_art_det_conus.detectar_run.BackgroundColor =  [ 1 1 1];
%         Eegtab_EEG_art_det_conus.detectar_run.ForegroundColor = [0 0 0];
%         Eegtab_EEG_art_det_conus.detectar_advanced.BackgroundColor =  [1 1 1];
%         Eegtab_EEG_art_det_conus.detectar_advanced.ForegroundColor = [0 0 0];
%     end


%%--------------Reset this panel with the default parameters---------------
    function Reset_eeg_panel_change(~,~)
        if observe_EEGDAT.Reset_eeg_paras_panel~=11
            return;
        end
        estudioworkingmemory('EEGTab_detect_arts_conus',0);
        Eegtab_EEG_art_det_conus.detectar_preview.BackgroundColor =  [1 1 1];
        Eegtab_EEG_art_det_conus.detectar_preview.ForegroundColor = [0 0 0];
        Eegtab_EEG_art_det_conus.detectar_run.BackgroundColor =  [ 1 1 1];
        Eegtab_EEG_art_det_conus.detectar_run.ForegroundColor = [0 0 0];
        Eegtab_EEG_art_det_conus.detectar_advanced.BackgroundColor =  [1 1 1];
        Eegtab_EEG_art_det_conus.detectar_advanced.ForegroundColor = [0 0 0];
        if isempty(observe_EEGDAT.EEG)
            Eegtab_EEG_art_det_conus.chan_edit.String = '';
        else
            Eegtab_EEG_art_det_conus.chan_edit.String = vect2colon([1:observe_EEGDAT.EEG.nbchan]);
        end
        Eegtab_EEG_art_det_conus.voltage_edit.String = '500';
        Eegtab_EEG_art_det_conus.movewindow_edit.String = '500';
        Eegtab_EEG_art_det_conus.windowstep_edit.String = '250';
        observe_EEGDAT.Reset_eeg_paras_panel=12;
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