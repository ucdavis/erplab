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
        
        %%Manua rejection
        Eegtab_EEG_art_det_conus.manuar_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_conus.DataSelBox,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_conus.manuar_checkbox = uicontrol('Style','checkbox','Parent', Eegtab_EEG_art_det_conus.manuar_title,'Value',0,...
            'String','Manual rejection','callback',@manuar_checkbox,'FontSize',FontSize_defualt,'Enable',EnableFlag,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_conus.manuar_button = uicontrol('Style','pushbutton','Parent', Eegtab_EEG_art_det_conus.manuar_title,...
            'String','View & Reject','callback',@manuar_button,'FontSize',FontSize_defualt,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        set( Eegtab_EEG_art_det_conus.manuar_title ,'Sizes',[120 -1]);
        Eegtab_EEG_art_det_conus.manuar_checkbox_Value = 0;
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
            'String','Moving window width [ms]','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def); % 2F
        Eegtab_EEG_art_det_conus.movewindow_edit = uicontrol('Style','edit','Parent',Eegtab_EEG_art_det_conus.movewindow_title,...
            'callback',@movewindow_edit,'String','','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',[1 1 1]); % 2F
        Eegtab_EEG_art_det_conus.movewindow_edit.KeyPressFcn=  @eeg_artdetect_presskey;
        set(Eegtab_EEG_art_det_conus.movewindow_title,'Sizes',[120,-1]);
        
        %%Window steps
        Eegtab_EEG_art_det_conus.windowstep_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_conus.DataSelBox,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_conus.windowstep_text = uicontrol('Style','text','Parent',Eegtab_EEG_art_det_conus.windowstep_title,...
            'String','Window step [ms]','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def); % 2F
        Eegtab_EEG_art_det_conus.windowstep_edit = uicontrol('Style','edit','Parent',Eegtab_EEG_art_det_conus.windowstep_title,...
            'callback',@windowstep_edit,'String','','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',[1 1 1]); % 2F
        Eegtab_EEG_art_det_conus.windowstep_edit.KeyPressFcn=  @eeg_artdetect_presskey;
        set(Eegtab_EEG_art_det_conus.windowstep_title,'Sizes',[120,-1]);
        
        %%optional
        Eegtab_EEG_art_det_conus.option_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_conus.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',Eegtab_EEG_art_det_conus.option_title ,'FontWeight','bold',...
            'String','Optional:','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        %%prefilter
        Eegtab_EEG_art_det_conus.filter_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_conus.DataSelBox,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_conus.filter_checkbox = uicontrol('Style','checkbox','Parent', Eegtab_EEG_art_det_conus.filter_title,'Value',0,'Enable','off',...
            'callback',@filter_checkbox,'String','Pre-filtering (only for identifying artifacts)','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def); % 2F
        Eegtab_EEG_art_det_conus.filter_title2 = uiextras.HBox('Parent', Eegtab_EEG_art_det_conus.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent', Eegtab_EEG_art_det_conus.filter_title2,...
            'String','Fre. cutoff (Hz): Low','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def); % 2F
        Eegtab_EEG_art_det_conus.lowfre_edit = uicontrol('Style','edit','Parent', Eegtab_EEG_art_det_conus.filter_title2,'Enable','off',...
            'callback',@lowfre_edit,'String','','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'BackgroundColor',[1 1 1]); % 2F
        uicontrol('Style','text','Parent', Eegtab_EEG_art_det_conus.filter_title2,...
            'String',', High','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_conus.highfre_edit = uicontrol('Style','edit','Parent', Eegtab_EEG_art_det_conus.filter_title2,'Enable','off',...
            'callback',@highfre_edit,'String','','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'BackgroundColor',[1 1 1]); % 2F
        set(Eegtab_EEG_art_det_conus.filter_title2,'Sizes',[120,60,40,60]);
        %%include or exclude
        Eegtab_EEG_art_det_conus.filter_title3 = uiextras.HBox('Parent', Eegtab_EEG_art_det_conus.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Eegtab_EEG_art_det_conus.filter_title3);
        Eegtab_EEG_art_det_conus.include_fre = uicontrol('Style','radiobutton','Parent', Eegtab_EEG_art_det_conus.filter_title3,'Value',1,'Enable','off',...
            'callback',@include_fre,'String','Include this band','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def); % 2F
        Eegtab_EEG_art_det_conus.exclude_fre = uicontrol('Style','radiobutton','Parent', Eegtab_EEG_art_det_conus.filter_title3,'Value',0,'Enable','off',...
            'callback',@exclude_fre,'String','Exclude this band','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def); % 2F
        set( Eegtab_EEG_art_det_conus.filter_title3 ,'Sizes',[20,-1,-1]);
        
        %%join artifactual segments separated by less than
        Eegtab_EEG_art_det_conus.joinarseg_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_conus.DataSelBox,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_conus.joinarseg_checkbox = uicontrol('Style','checkbox','Parent',Eegtab_EEG_art_det_conus.joinarseg_title,'Value',0,'Enable','off',...
            'callback',@joinarseg_checkbox,'String','Join artifactual segments separated by less than','FontSize',FontSize_defualt-1,'BackgroundColor',ColorB_def); % 2F
        
        Eegtab_EEG_art_det_conus.joinarseg_title1 = uiextras.HBox('Parent', Eegtab_EEG_art_det_conus.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Eegtab_EEG_art_det_conus.joinarseg_title1 );
        Eegtab_EEG_art_det_conus.joinarseg_edit = uicontrol('Style','edit','Parent',Eegtab_EEG_art_det_conus.joinarseg_title1,'Enable','off',...
            'callback',@joinarseg_edit,'String','','FontSize',FontSize_defualt,'BackgroundColor',[1 1 1]); % 2F
        uicontrol('Style','text','Parent',Eegtab_EEG_art_det_conus.joinarseg_title1 ,...
            'String','ms','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def);
        set( Eegtab_EEG_art_det_conus.joinarseg_title1,'Sizes',[20,-1,40]);
        
        %%Unmark artifactual segments shorter than
        Eegtab_EEG_art_det_conus.unmarkarseg_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_conus.DataSelBox,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_conus.unmarkarseg_checkbox = uicontrol('Style','checkbox','Parent', Eegtab_EEG_art_det_conus.unmarkarseg_title,'Value',0,'Enable','off' ,...
            'callback',@unmarkarseg_checkbox,'String','Unmark artifactual segments shorter than','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        
        Eegtab_EEG_art_det_conus.unmarkarseg_title1 = uiextras.HBox('Parent', Eegtab_EEG_art_det_conus.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Eegtab_EEG_art_det_conus.unmarkarseg_title1 );
        Eegtab_EEG_art_det_conus.unmarkarseg_edit = uicontrol('Style','edit','Parent',Eegtab_EEG_art_det_conus.unmarkarseg_title1,'Enable','off' ,...
            'callback',@unmarkarseg_edit,'String','','FontSize',FontSize_defualt,'BackgroundColor',[1 1 1]); % 2F
        uicontrol('Style','text','Parent',Eegtab_EEG_art_det_conus.unmarkarseg_title1 ,...
            'String','ms','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def);
        set(Eegtab_EEG_art_det_conus.unmarkarseg_title1,'Sizes',[20,-1,40]);
        
        
        %%Add extra time to negining and end of regions
        Eegtab_EEG_art_det_conus.addtime_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_conus.DataSelBox,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_conus.addtime_checkbox = uicontrol('Style','checkbox','Parent', Eegtab_EEG_art_det_conus.addtime_title,'Value',0,'Enable','off' ,...
            'callback',@addtime_checkbox,'String','Add extra time to start and end of regions','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        
        Eegtab_EEG_art_det_conus.addtime_title1 = uiextras.HBox('Parent', Eegtab_EEG_art_det_conus.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Eegtab_EEG_art_det_conus.addtime_title1 );
        Eegtab_EEG_art_det_conus.addtime_edit = uicontrol('Style','edit','Parent',Eegtab_EEG_art_det_conus.addtime_title1,'Enable','off',...
            'callback',@addtime_edit,'String','','FontSize',FontSize_defualt,'BackgroundColor',[1 1 1]); % 2F
        uicontrol('Style','text','Parent',Eegtab_EEG_art_det_conus.addtime_title1 ,...
            'String','ms','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def);
        set(Eegtab_EEG_art_det_conus.addtime_title1,'Sizes',[20,-1,40]);
        
        
        %%-----------------------Cancel and Run----------------------------
        Eegtab_EEG_art_det_conus.detar_run_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_conus.DataSelBox,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_conus.detectar_cancel = uicontrol('Style', 'pushbutton','Parent',Eegtab_EEG_art_det_conus.detar_run_title,...
            'String','Cancel','callback',@detectar_cancel,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        Eegtab_EEG_art_det_conus.detectar_preview = uicontrol('Style', 'pushbutton','Parent',Eegtab_EEG_art_det_conus.detar_run_title,...
            'String','Preview','callback',@detectar_preview,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        Eegtab_EEG_art_det_conus.detectar_run = uicontrol('Style','pushbutton','Parent',Eegtab_EEG_art_det_conus.detar_run_title,...
            'String','Finalize','callback',@detectar_run,'FontSize',FontSize_defualt,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        set(Eegtab_EEG_art_det_conus.DataSelBox,'Sizes',[30 30 35 35 35 20 20 30 20 20 30 20 30 20 30 30]);
        estudioworkingmemory('EEGTab_detect_arts_conus',0);
        
        
        %%set the default parameters
        prompt     = {'Threshold (1 or 2 values)', 'Moving Windows Width (ms)',...
            'Window Step (ms)','Channel(s)', 'Frequency cutoffs (Hz)', 'lowest freq', 'highest freq'};
        dlg_title  =  'Input threshold';
        def        = {500 500 250 [] [] [] [] 0 0 0 0};
        
        colorseg   = [1.0000    0.9765    0.5294]; % default
        memoryCARTGUI.prompt = prompt;
        memoryCARTGUI.dlg_title = dlg_title;
        memoryCARTGUI.def=def;
        memoryCARTGUI.defx=[];
        memoryCARTGUI.colorseg=colorseg;
        estudioworkingmemory('continuousartifactGUI',memoryCARTGUI);
    end


%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%----------------------checkbox for manual rejection----------------------
    function manuar_checkbox(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials >1
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
        Eegtab_EEG_art_det_conus.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_conus',1);
        
        
        if Eegtab_EEG_art_det_conus.manuar_checkbox.Value==0
            Eegtab_EEG_art_det_conus.manuar_button.Enable = 'off';
            Eegtab_EEG_art_det_conus.chan_edit.Enable= 'on';
            Eegtab_EEG_art_det_conus.chan_browse.Enable= 'on';
            Eegtab_EEG_art_det_conus.voltage_edit.Enable= 'on';
            Eegtab_EEG_art_det_conus.movewindow_edit.Enable= 'on';
            Eegtab_EEG_art_det_conus.windowstep_edit.Enable= 'on';
            Eegtab_EEG_art_det_conus.detectar_cancel.Enable= 'on';
            Eegtab_EEG_art_det_conus.detectar_preview.Enable= 'on';
            Eegtab_EEG_art_det_conus.detectar_run.Enable= 'on';
            Eegtab_EEG_art_det_conus.filter_checkbox.Enable= 'on';
            if  Eegtab_EEG_art_det_conus.filter_checkbox.Value==1
                Eegtab_EEG_art_det_conus.lowfre_edit.Enable= 'on';
                Eegtab_EEG_art_det_conus.highfre_edit.Enable= 'on';
                Eegtab_EEG_art_det_conus.include_fre.Enable= 'on';
                Eegtab_EEG_art_det_conus.exclude_fre.Enable= 'on';
            else
                Eegtab_EEG_art_det_conus.lowfre_edit.Enable= 'off';
                Eegtab_EEG_art_det_conus.highfre_edit.Enable= 'off';
                Eegtab_EEG_art_det_conus.include_fre.Enable= 'off';
                Eegtab_EEG_art_det_conus.exclude_fre.Enable= 'off';
            end
            
            Eegtab_EEG_art_det_conus.joinarseg_checkbox.Enable= 'on';
            if Eegtab_EEG_art_det_conus.joinarseg_checkbox.Value==1
                Eegtab_EEG_art_det_conus.joinarseg_edit.Enable= 'on';
            else
                Eegtab_EEG_art_det_conus.joinarseg_edit.Enable= 'off';
            end
            
            Eegtab_EEG_art_det_conus.unmarkarseg_checkbox.Enable= 'on';
            if Eegtab_EEG_art_det_conus.unmarkarseg_checkbox.Value==1
                Eegtab_EEG_art_det_conus.joinarseg_edit.Enable= 'on';
            else
                Eegtab_EEG_art_det_conus.joinarseg_edit.Enable= 'off';
            end
            Eegtab_EEG_art_det_conus.addtime_checkbox.Enable= 'on';
            if Eegtab_EEG_art_det_conus.addtime_checkbox.Value==1
                Eegtab_EEG_art_det_conus.addtime_edit.Enable= 'on';
            else
                Eegtab_EEG_art_det_conus.addtime_edit.Enable= 'off';
            end
            
        else
            Eegtab_EEG_art_det_conus.chan_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.chan_browse.Enable= 'off';
            Eegtab_EEG_art_det_conus.voltage_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.movewindow_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.windowstep_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.detectar_cancel.Enable= 'on';
            Eegtab_EEG_art_det_conus.detectar_preview.Enable= 'off';
            Eegtab_EEG_art_det_conus.detectar_run.Enable= 'off';
            Eegtab_EEG_art_det_conus.filter_checkbox.Enable= 'off';
            Eegtab_EEG_art_det_conus.lowfre_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.highfre_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.include_fre.Enable= 'off';
            Eegtab_EEG_art_det_conus.exclude_fre.Enable= 'off';
            Eegtab_EEG_art_det_conus.joinarseg_checkbox.Enable= 'off';
            Eegtab_EEG_art_det_conus.joinarseg_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.unmarkarseg_checkbox.Enable= 'off';
            Eegtab_EEG_art_det_conus.joinarseg_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.addtime_checkbox.Enable= 'off';
            Eegtab_EEG_art_det_conus.addtime_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.manuar_button.Enable = 'on';
        end
    end

%%----------------------botton for manual rejection------------------------
    function manuar_button(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials >1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=10
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('f_EEG_proces_messg','Reject Artifactual Time Segments (Continuous EEG) > View & reject');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        estudioworkingmemory('f_EEG_proces_messg','The main ERPLAB Studio window will be fronzen when you are using "Reject Artifactual Time Segments (Continuous EEG) > View & reject" tool. Please click "Reject"');
        observe_EEGDAT.eeg_panel_message =1;
        
        Eegtab_box_art_det_conus.TitleColor= [0.0500    0.2500    0.5000];
        Eegtab_EEG_art_det_conus.detectar_preview.BackgroundColor =  [1 1 1];
        Eegtab_EEG_art_det_conus.detectar_preview.ForegroundColor = [0 0 0];
        Eegtab_EEG_art_det_conus.detectar_run.BackgroundColor =  [ 1 1 1];
        Eegtab_EEG_art_det_conus.detectar_run.ForegroundColor = [0 0 0];
        Eegtab_EEG_art_det_conus.detectar_cancel.BackgroundColor =  [ 1 1 1];
        Eegtab_EEG_art_det_conus.detectar_cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('EEGTab_detect_arts_conus',0);
        
        OutputViewereegpar = f_preparms_eegwaviewer(observe_EEGDAT.EEG,0);
        try EEGdisp = OutputViewereegpar{3}; catch EEGdisp=1; end
        if EEGdisp==0
            msgboxText=['Reject Artifactual Time Segments (Continuous EEG) > View & reject: "Display chans" should be active in the "Plot Settings panel" '];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        
        %%--------Selected EEGsets-----------
        EEGArray= estudioworkingmemory('EEGArray');
        if isempty(EEGArray) || any(EEGArray(:) > length(observe_EEGDAT.ALLEEG))
            EEGArray = observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',EEGArray);
        end
        
        estudioworkingmemory('EEGUpdate',1);
        observe_EEGDAT.count_current_eeg=1;
        ALLEEG = observe_EEGDAT.ALLEEG;
        ALLEEG_out = [];
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Artifact Detection (Continuous EEG) > View & reject*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            [EEG, LASTCOM] = f_ploteeg(EEG);
            if  isempty(LASTCOM)
                observe_EEGDAT.eeg_panel_message =2;
                fprintf( [repmat('-',1,100) '\n']);
                estudioworkingmemory('EEGUpdate',0);
                observe_EEGDAT.count_current_eeg=1;
                return;
            end
            EEG = eegh(LASTCOM, EEG);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            fprintf([LASTCOM,'\n']);
            [ALLEEG_out,~,~,LASTCOM] = pop_newset(ALLEEG_out, EEG, length(ALLEEG_out), 'gui', 'off');
            fprintf( [repmat('-',1,100) '\n']);
            if Numofeeg==1
                eegh(LASTCOM);
            end
        end%%end for loop of subjects
        Answer = f_EEG_save_multi_file(ALLEEG_out,1:numel(EEGArray),'_manreject');
        if isempty(Answer)
            estudioworkingmemory('EEGUpdate',0);
            observe_EEGDAT.eeg_panel_message =2;
            observe_EEGDAT.count_current_eeg=1;
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
            EEGArray =  [length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1:length(observe_EEGDAT.ALLEEG)];
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1;
        catch
            EEGArray = length(observe_EEGDAT.ALLEEG);
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG);
        end
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
        estudioworkingmemory('EEGArray',EEGArray);
        assignin('base','EEG',observe_EEGDAT.EEG);
        assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
        assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        
        estudioworkingmemory('EEGUpdate',0);
        observe_EEGDAT.count_current_eeg=1;
        observe_EEGDAT.eeg_panel_message =2;
    end





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
        Eegtab_EEG_art_det_conus.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_conus',1);
        ChaNum = observe_EEGDAT.EEG.nbchan;
        ChanArray = str2num(Source.String);
        if isempty(ChanArray) || any(ChanArray(:)<=0)
            msgboxText = 'Reject Artifactual Time Segments (Continuous EEG) >  Index(es) of chans should be positive number(s)';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            ChanArray = vect2colon(ChanArray,'Sort','on');
            ChanArray = erase(ChanArray,{'[',']'});
            Source.String= ChanArray;
            return;
        end
        
        if any(ChanArray(:)> ChaNum)
            msgboxText=['Reject Artifactual Time Segments (Continuous EEG) >  Index(es) of chans should be between 1 and ',32,num2str(ChaNum)];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            ChanArray = vect2colon(ChanArray,'Sort','on');
            ChanArray = erase(ChanArray,{'[',']'});
            Source.String= ChanArray;
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
        Eegtab_EEG_art_det_conus.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_cancel.ForegroundColor = [1 1 1];
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
            chan_label_select = vect2colon(chan_label_select,'Sort','on');
            chan_label_select = erase(chan_label_select,{'[',']'});
            Eegtab_EEG_art_det_conus.chan_edit.String  = chan_label_select;
        else
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
        Eegtab_EEG_art_det_conus.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_conus',1);
        Voltagevalue= str2num(Source.String);
        if isempty(Voltagevalue) || (numel(Voltagevalue)~=1 && numel(Voltagevalue)~=2)
            msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Voltage threshold must have one or two values'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            Source.String = '500';
            return;
        end
        if numel(Voltagevalue)==2
            if Voltagevalue(2) >= Voltagevalue(1)
                msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Voltage threshold: When 2 thresholds are specified, the first one must be lesser than the second one'];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
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
        Eegtab_EEG_art_det_conus.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_conus',1);
        windowlength= str2num(Source.String);
        if isempty(windowlength) || numel(windowlength) ~=1 ||  any(windowlength(:)<=0)
            msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Move window width must be a positive number'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            Source.String = '500';
            return;
        end
        
        windowStep = str2num(Eegtab_EEG_art_det_conus.windowstep_edit.String);
        if any(windowStep(:)>=windowlength )
            msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Step width cannot be larger than the window width'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
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
        Eegtab_EEG_art_det_conus.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_conus',1);
        windowstep= str2num(Source.String);
        if isempty(windowstep) || numel(windowstep) ~=1 ||  any(windowstep(:)<=0)
            msgboxText= ['Reject Artifactual Time Segments (Continuous EEG) > Window step width must be a positive number'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            Source.String = '';
            return;
        end
        
        windowStep = str2num(Eegtab_EEG_art_det_conus.windowstep_edit.String);
        windowlength = str2num(Eegtab_EEG_art_det_conus.movewindow_edit.String);
        if  any(windowStep(:)>=windowlength)
            msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Step width must be smaller than the window width'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
    end

%%----------------------prefilter checkbox--------------------------------
    function filter_checkbox(~,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
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
        Eegtab_EEG_art_det_conus.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_conus',1);
        
        if Eegtab_EEG_art_det_conus.filter_checkbox.Value==1
            enableflag = 'on';
        else
            enableflag = 'off';
        end
        Eegtab_EEG_art_det_conus.lowfre_edit.Enable = enableflag;
        Eegtab_EEG_art_det_conus.highfre_edit.Enable = enableflag;
        Eegtab_EEG_art_det_conus.include_fre.Enable = enableflag;
        Eegtab_EEG_art_det_conus.exclude_fre.Enable = enableflag;
    end

%%--------------------------------lowest filter----------------------------
    function lowfre_edit(~,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
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
        Eegtab_EEG_art_det_conus.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_conus',1);
        
        lowfre_edit = str2num(Eegtab_EEG_art_det_conus.lowfre_edit.String);
        if isempty(lowfre_edit) || numel(lowfre_edit)~=1 || any(lowfre_edit(:)<0)
            Eegtab_EEG_art_det_conus.lowfre_edit.String = '';
            msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Optional: The lowest frequency should be a positive value'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        highfre_edit = str2num(Eegtab_EEG_art_det_conus.highfre_edit.String);
        
        if any(lowfre_edit(:)>=highfre_edit(:))
            Eegtab_EEG_art_det_conus.lowfre_edit.String = '';
            msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Optional: The lowest frequency should be smaller than the highest one'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        if any(lowfre_edit(:)>=observe_EEGDAT.EEG.srate/2)
            Eegtab_EEG_art_det_conus.lowfre_edit.String = '';
            msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Optional: The lowest frequency should be smaller than',32,num2str(roundn(observe_EEGDAT.EEG.srate/2,-2))];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
    end

%%---------------------------Highest frequency-----------------------------
    function highfre_edit(~,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
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
        Eegtab_EEG_art_det_conus.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_conus',1);
        
        highfre_edit = str2num(Eegtab_EEG_art_det_conus.highfre_edit.String);
        
        lowfre_edit = str2num(Eegtab_EEG_art_det_conus.lowfre_edit.String);
        if isempty(highfre_edit) || numel(highfre_edit)~=1 || any(highfre_edit(:)<0)
            Eegtab_EEG_art_det_conus.highfre_edit.String = '';
            msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Optional: The highest frequency should be a positive value'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        if any(lowfre_edit(:)>=highfre_edit(:))
            Eegtab_EEG_art_det_conus.highfre_edit.String = '';
            msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Optional: The highest frequency should be larger than the lowest one'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        if any(highfre_edit(:)>=observe_EEGDAT.EEG.srate/2)
            Eegtab_EEG_art_det_conus.highfre_edit.String = '';
            msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Optional: The highest frequency should be smaller than',32,num2str(roundn(observe_EEGDAT.EEG.srate/2,-2))];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
    end

%%------------------------include this frequency band----------------------
    function include_fre(~,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
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
        Eegtab_EEG_art_det_conus.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_conus',1);
        Eegtab_EEG_art_det_conus.include_fre.Value=1;
        Eegtab_EEG_art_det_conus.exclude_fre.Value=0;
    end

%%-----------------exclude this frequency----------------------------------
    function exclude_fre(~,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
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
        Eegtab_EEG_art_det_conus.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_conus',1);
        Eegtab_EEG_art_det_conus.include_fre.Value=0;
        Eegtab_EEG_art_det_conus.exclude_fre.Value=1;
    end

%%-------------Join artifactual segments separated by less than------------
    function joinarseg_checkbox(~,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
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
        Eegtab_EEG_art_det_conus.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_conus',1);
        if Eegtab_EEG_art_det_conus.joinarseg_checkbox.Value ==1
            Eegtab_EEG_art_det_conus.joinarseg_edit.Enable = 'on';
        else
            Eegtab_EEG_art_det_conus.joinarseg_edit.Enable = 'off';
        end
    end

%%------------------edit join-------------------
    function joinarseg_edit(~,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
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
        Eegtab_EEG_art_det_conus.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_conus',1);
        joinarseg_edit = str2num(Eegtab_EEG_art_det_conus.joinarseg_edit.String);
        if isempty(joinarseg_edit) || numel(joinarseg_edit)~=1 || any(joinarseg_edit(:)<=0)
            Eegtab_EEG_art_det_conus.joinarseg_edit.String = '';
            msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Optional: Invalid input for segements separation and it should be a positive value'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
    end

%%----------------unmark artifactual segments shorter than-----------------
    function unmarkarseg_checkbox(~,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
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
        Eegtab_EEG_art_det_conus.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_conus',1);
        if  Eegtab_EEG_art_det_conus.unmarkarseg_checkbox.Value==1
            Eegtab_EEG_art_det_conus.unmarkarseg_edit.Enable = 'on';
        else
            Eegtab_EEG_art_det_conus.unmarkarseg_edit.Enable = 'off';
        end
    end
%%----------------edit for unmark artifactual segments shorter than--------
    function unmarkarseg_edit(~,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
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
        Eegtab_EEG_art_det_conus.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_conus',1);
        unmarkarseg_edit = str2num(Eegtab_EEG_art_det_conus.unmarkarseg_edit.String);
        if isempty(unmarkarseg_edit) || numel(unmarkarseg_edit)~=1 || any(unmarkarseg_edit(:)<=0)
            Eegtab_EEG_art_det_conus.unmarkarseg_edit.String = '';
            msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Optional: Invalid input for unmark artifactual segments and it should be a positive value'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
    end

%%-----------------------------add extra time------------------------------
    function addtime_checkbox(~,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
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
        Eegtab_EEG_art_det_conus.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_conus',1);
        if Eegtab_EEG_art_det_conus.addtime_checkbox.Value==1
            Eegtab_EEG_art_det_conus.addtime_edit.Enable = 'on';
        else
            Eegtab_EEG_art_det_conus.addtime_edit.Enable = 'off';
        end
    end

%%------------edit for adding extra time-----------------------------------
    function addtime_edit(~,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
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
        Eegtab_EEG_art_det_conus.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_conus.detectar_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_conus',1);
        addtime_edit = str2num( Eegtab_EEG_art_det_conus.addtime_edit.String);
        if isempty(addtime_edit) || numel(addtime_edit)~=1 || any(addtime_edit(:)<=0)
            Eegtab_EEG_art_det_conus.addtime_edit.String = '';
            msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Optional: Invalid input for "add extra time" and it should be a positive value'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
    end

%%--------------------------advanced options-------------------------------
    function detectar_cancel(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=10
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
            return;
        end
        estudioworkingmemory('f_EEG_proces_messg','Reject Artifactual Time Segments (Continuous EEG) > Cancel');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        Eegtab_box_art_det_conus.TitleColor= [0.0500    0.2500    0.5000];
        Eegtab_EEG_art_det_conus.detectar_preview.BackgroundColor =  [1 1 1];
        Eegtab_EEG_art_det_conus.detectar_preview.ForegroundColor = [0 0 0];
        Eegtab_EEG_art_det_conus.detectar_run.BackgroundColor =  [ 1 1 1];
        Eegtab_EEG_art_det_conus.detectar_run.ForegroundColor = [0 0 0];
        Eegtab_EEG_art_det_conus.detectar_cancel.BackgroundColor =  [ 1 1 1];
        Eegtab_EEG_art_det_conus.detectar_cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('EEGTab_detect_arts_conus',0);
        memoryCARTGUI   = estudioworkingmemory('continuousartifactGUI');
        
        try  Volthreshold = memoryCARTGUI.def{1};catch Volthreshold = 500;end
        Eegtab_EEG_art_det_conus.voltage_edit.String = num2str(Volthreshold);
        
        try WindowLength = memoryCARTGUI.def{2};catch  WindowLength=500;end
        Eegtab_EEG_art_det_conus.movewindow_edit.String = num2str(WindowLength);
        try windowStep = memoryCARTGUI.def{3};catch windowStep = 250;  end
        Eegtab_EEG_art_det_conus.windowstep_edit.String = num2str(windowStep);
        try ChanArray = memoryCARTGUI.def{4};catch ChanArray=  [1:observe_EEGDAT.EEG.nbchan];end
        if isempty(ChanArray) || any(ChanArray(:)<=0) || any(ChanArray(:)>observe_EEGDAT.EEG.nbchan)
            ChanArray=  [1:observe_EEGDAT.EEG.nbchan];
        end
        ChanArraystr = vect2colon(ChanArray,'Sort','on');
        ChanArraystr = erase(ChanArraystr,{'[',']'});
        Eegtab_EEG_art_det_conus.chan_edit.String = ChanArraystr;
        
        try includef = memoryCARTGUI.def{7};catch includef=[];end
        
        if isempty(includef)
            Eegtab_EEG_art_det_conus.filter_checkbox.Value =0;
            Eegtab_EEG_art_det_conus.lowfre_edit.Enable = 'off';
            Eegtab_EEG_art_det_conus.highfre_edit.Enable = 'off';
            Eegtab_EEG_art_det_conus.include_fre.Enable = 'off';
            Eegtab_EEG_art_det_conus.exclude_fre.Enable = 'off';
            Eegtab_EEG_art_det_conus.include_fre.Value = 1;
            Eegtab_EEG_art_det_conus.exclude_fre.Enable = 'off';
        else
            if numel(includef)~=1 || (includef~=0 && includef~=1)
                includef = 1;
            end
            Eegtab_EEG_art_det_conus.include_fre.Value = includef;
            Eegtab_EEG_art_det_conus.exclude_fre.Value = ~includef;
            Eegtab_EEG_art_det_conus.filter_checkbox.Value =1;
            Eegtab_EEG_art_det_conus.lowfre_edit.Enable = 'on';
            Eegtab_EEG_art_det_conus.highfre_edit.Enable = 'on';
            Eegtab_EEG_art_det_conus.include_fre.Enable = 'on';
            Eegtab_EEG_art_det_conus.exclude_fre.Enable = 'on';
        end
        try   lowfre_edit= memoryCARTGUI.def{5} ; catch lowfre_edit =[]; end
        try   highfre_edit= memoryCARTGUI.def{6} ; catch highfre_edit =[]; end
        
        if numel(lowfre_edit)~=1 || any(lowfre_edit<=0) || any(lowfre_edit>=highfre_edit) || any(lowfre_edit(:)>observe_EEGDAT.EEG.srate/2)
            lowfre_edit =[];
        end
        Eegtab_EEG_art_det_conus.lowfre_edit.String = num2str(lowfre_edit);
        
        if numel(highfre_edit)~=1|| any(highfre_edit<=0) || any(lowfre_edit>=highfre_edit) || any(highfre_edit(:)>observe_EEGDAT.EEG.srate/2)
            highfre_edit =[];
        end
        Eegtab_EEG_art_det_conus.highfre_edit.String = num2str(highfre_edit);
        
        try shortisi = memoryCARTGUI.def{9} ;catch shortisi = [];end
        
        if numel(shortisi)~=1 || any(shortisi(:)<=0)
            shortisi = [];
        end
        if ~isempty(shortisi)
            Eegtab_EEG_art_det_conus.joinarseg_checkbox.Value = 1;
            Eegtab_EEG_art_det_conus.joinarseg_edit.Enable = 'on';
        else
            Eegtab_EEG_art_det_conus.joinarseg_checkbox.Value = 0;
            Eegtab_EEG_art_det_conus.joinarseg_edit.Enable = 'off';
        end
        Eegtab_EEG_art_det_conus.joinarseg_edit.String = num2str(shortisi);
        
        try shortseg = memoryCARTGUI.def{10};catch shortseg = [];end
        
        if numel(shortseg)~=1 || any(shortseg(:)<=0)
            shortseg = [];
        end
        if isempty(shortseg)
            Eegtab_EEG_art_det_conus.unmarkarseg_checkbox.Value = 0;
            Eegtab_EEG_art_det_conus.unmarkarseg_edit.Enable = 'off';
        else
            Eegtab_EEG_art_det_conus.unmarkarseg_checkbox.Value = 1;
            Eegtab_EEG_art_det_conus.unmarkarseg_edit.Enable = 'on';
        end
        Eegtab_EEG_art_det_conus.unmarkarseg_edit.String = num2str(shortseg);
        
        try winoffset = memoryCARTGUI.def{11} ; catch winoffset = []; end
        if numel(winoffset)~=1 || any(winoffset(:)<=0)
            winoffset = [];
        end
        
        if isempty(winoffset);
            Eegtab_EEG_art_det_conus.addtime_checkbox.Value = 0;
            Eegtab_EEG_art_det_conus.addtime_edit.Enable = 'off';
        else
            Eegtab_EEG_art_det_conus.addtime_checkbox.Value = 1;
            Eegtab_EEG_art_det_conus.addtime_edit.Enable = 'on';
        end
        Eegtab_EEG_art_det_conus.addtime_edit.String = num2str(winoffset);
        memoryCARTGUI.def{1} = Volthreshold;
        memoryCARTGUI.def{2} = WindowLength;
        memoryCARTGUI.def{3} = windowStep;
        memoryCARTGUI.def{4} = ChanArray;
        memoryCARTGUI.def{5} = lowfre_edit;
        memoryCARTGUI.def{6} = highfre_edit;
        memoryCARTGUI.def{7} = includef;
        memoryCARTGUI.def{9} = shortisi;
        memoryCARTGUI.def{10} = shortseg;
        memoryCARTGUI.def{11} = winoffset;
        estudioworkingmemory('continuousartifactGUI',memoryCARTGUI);
        
        try Eegtab_EEG_art_det_conus.manuar_checkbox.Value= Eegtab_EEG_art_det_conus.manuar_checkbox_Value;catch Eegtab_EEG_art_det_conus.manuar_checkbox.Value=0;end
        if Eegtab_EEG_art_det_conus.manuar_checkbox.Value==0
            Eegtab_EEG_art_det_conus.manuar_button.Enable = 'off';
            Eegtab_EEG_art_det_conus.chan_edit.Enable= 'on';
            Eegtab_EEG_art_det_conus.chan_browse.Enable= 'on';
            Eegtab_EEG_art_det_conus.voltage_edit.Enable= 'on';
            Eegtab_EEG_art_det_conus.movewindow_edit.Enable= 'on';
            Eegtab_EEG_art_det_conus.windowstep_edit.Enable= 'on';
            Eegtab_EEG_art_det_conus.detectar_cancel.Enable= 'on';
            Eegtab_EEG_art_det_conus.detectar_preview.Enable= 'on';
            Eegtab_EEG_art_det_conus.detectar_run.Enable= 'on';
            Eegtab_EEG_art_det_conus.filter_checkbox.Enable= 'on';
            if  Eegtab_EEG_art_det_conus.filter_checkbox.Value==1
                Eegtab_EEG_art_det_conus.lowfre_edit.Enable= 'on';
                Eegtab_EEG_art_det_conus.highfre_edit.Enable= 'on';
                Eegtab_EEG_art_det_conus.include_fre.Enable= 'on';
                Eegtab_EEG_art_det_conus.exclude_fre.Enable= 'on';
            else
                Eegtab_EEG_art_det_conus.lowfre_edit.Enable= 'off';
                Eegtab_EEG_art_det_conus.highfre_edit.Enable= 'off';
                Eegtab_EEG_art_det_conus.include_fre.Enable= 'off';
                Eegtab_EEG_art_det_conus.exclude_fre.Enable= 'off';
            end
            
            Eegtab_EEG_art_det_conus.joinarseg_checkbox.Enable= 'on';
            if Eegtab_EEG_art_det_conus.joinarseg_checkbox.Value==1
                Eegtab_EEG_art_det_conus.joinarseg_edit.Enable= 'on';
            else
                Eegtab_EEG_art_det_conus.joinarseg_edit.Enable= 'off';
            end
            
            Eegtab_EEG_art_det_conus.unmarkarseg_checkbox.Enable= 'on';
            if Eegtab_EEG_art_det_conus.unmarkarseg_checkbox.Value==1
                Eegtab_EEG_art_det_conus.joinarseg_edit.Enable= 'on';
            else
                Eegtab_EEG_art_det_conus.joinarseg_edit.Enable= 'off';
            end
            Eegtab_EEG_art_det_conus.addtime_checkbox.Enable= 'on';
            if Eegtab_EEG_art_det_conus.addtime_checkbox.Value==1
                Eegtab_EEG_art_det_conus.addtime_edit.Enable= 'on';
            else
                Eegtab_EEG_art_det_conus.addtime_edit.Enable= 'off';
            end
        else
            Eegtab_EEG_art_det_conus.chan_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.chan_browse.Enable= 'off';
            Eegtab_EEG_art_det_conus.voltage_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.movewindow_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.windowstep_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.detectar_cancel.Enable= 'on';
            Eegtab_EEG_art_det_conus.detectar_preview.Enable= 'off';
            Eegtab_EEG_art_det_conus.detectar_run.Enable= 'off';
            Eegtab_EEG_art_det_conus.filter_checkbox.Enable= 'off';
            Eegtab_EEG_art_det_conus.lowfre_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.highfre_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.include_fre.Enable= 'off';
            Eegtab_EEG_art_det_conus.exclude_fre.Enable= 'off';
            Eegtab_EEG_art_det_conus.joinarseg_checkbox.Enable= 'off';
            Eegtab_EEG_art_det_conus.joinarseg_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.unmarkarseg_checkbox.Enable= 'off';
            Eegtab_EEG_art_det_conus.joinarseg_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.addtime_checkbox.Enable= 'off';
            Eegtab_EEG_art_det_conus.addtime_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.manuar_button.Enable = 'on';
        end
        
        
        estudioworkingmemory('f_EEG_proces_messg','Reject Artifactual Time Segments (Continuous EEG) > Cancel');
        observe_EEGDAT.eeg_panel_message =2; %%Marking for the procedure has been started.
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
        estudioworkingmemory('f_EEG_proces_messg','Reject Artifactual Time Segments (Continuous EEG) > Preview');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        %%--------Selected EEGsets-----------
        EEGArray= estudioworkingmemory('EEGArray');
        if numel(EEGArray)~=1
            msgboxText= 'Reject Artifactual Time Segments (Continuous EEG) > Preview: Only work for single EEG';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            Source.String = 'Only for single EEG';
            Source.Enable = 'off';
            return;
        end
        
        Eegtab_box_art_det_conus.TitleColor= [0.0500    0.2500    0.5000];
        Eegtab_EEG_art_det_conus.detectar_preview.BackgroundColor =  [1 1 1];
        Eegtab_EEG_art_det_conus.detectar_preview.ForegroundColor = [0 0 0];
        Eegtab_EEG_art_det_conus.detectar_run.BackgroundColor =  [ 1 1 1];
        Eegtab_EEG_art_det_conus.detectar_run.ForegroundColor = [0 0 0];
        Eegtab_EEG_art_det_conus.detectar_cancel.BackgroundColor =  [ 1 1 1];
        Eegtab_EEG_art_det_conus.detectar_cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('EEGTab_detect_arts_conus',0);
        
        %%chans
        ChanArray = str2num(Eegtab_EEG_art_det_conus.chan_edit.String);
        nbchan = observe_EEGDAT.EEG.nbchan;
        if isempty(ChanArray) || any(ChanArray(:) <=0) ||  any(ChanArray(:) > nbchan)
            msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Preview: Chans are empty or index(es) are not between 1 and',32,num2str(nbchan)];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        %%----------if simple voltage threshold------------
        Volthreshold = sort(str2num(Eegtab_EEG_art_det_conus.voltage_edit.String));
        if isempty(Volthreshold) || (numel(Volthreshold)~=1 && numel(Volthreshold)~=2)
            msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Preview: Voltage threshold must have one or two values'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        if numel(Volthreshold)==2
            if Volthreshold(2) >= Volthreshold(1)
                msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Preview: When 2 thresholds are specified, the first one must be lesser than the second one'];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
        end
        
        %
        %%Moving window full width
        WindowLength = str2num(Eegtab_EEG_art_det_conus.movewindow_edit.String);
        if isempty(WindowLength) || numel(WindowLength) ~=1 ||  any(WindowLength(:)<=0)
            msgboxText= ['Reject Artifactual Time Segments (Continuous EEG) > Preview: Move window width must be a positive number'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            Eegtab_EEG_art_det_conus.movewindow_edit.String = '500';
            return;
        end
        
        windowStep = str2num(Eegtab_EEG_art_det_conus.windowstep_edit.String);
        if  any(windowStep(:)>=WindowLength)
            msgboxText= ['Reject Artifactual Time Segments (Continuous EEG) > Preview: Step width cannot be larger than the window width'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            Eegtab_EEG_art_det_conus.windowstep_edit.String = '';
            return;
        end
        
        if isempty(windowStep) || numel(windowStep) ~=1 ||  any(windowStep(:)<=0)
            msgboxText=['Reject Artifactual Time Segments (Continuous EEG) > Preview: Window step width must be a positive number'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            Eegtab_EEG_art_det_conus.windowstep_edit.String = '';
            return;
        end
        %%WindowStep
        if  any(windowStep(:)>=WindowLength)
            msgboxText= ['Reject Artifactual Time Segments (Continuous EEG) > Preview: Step width must be smaller than the window width'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            Eegtab_EEG_art_det_conus.windowstep_edit.String = '';
            return;
        end
        
        
        if Eegtab_EEG_art_det_conus.filter_checkbox.Value==0
            fcutoff = [];
            includef =[];
            lowfre_edit = [];
            highfre_edit = [];
        end
        
        if Eegtab_EEG_art_det_conus.filter_checkbox.Value==1
            lowfre_edit = str2num(Eegtab_EEG_art_det_conus.lowfre_edit.String);
            if isempty(lowfre_edit) || numel(lowfre_edit)~=1 || any(lowfre_edit(:)<0)
                Eegtab_EEG_art_det_conus.lowfre_edit.String = '';
                msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Preview >Optional: The lowest frequency should be a positive value'];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            
            highfre_edit = str2num(Eegtab_EEG_art_det_conus.highfre_edit.String);
            
            if any(lowfre_edit(:)>=observe_EEGDAT.EEG.srate/2)
                Eegtab_EEG_art_det_conus.lowfre_edit.String = '';
                msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Preview > Optional: The lowest frequency should be smaller than',32,num2str(roundn(observe_EEGDAT.EEG.srate/2,-2))];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            
            if isempty(highfre_edit) || numel(highfre_edit)~=1 || any(highfre_edit(:)<0)
                Eegtab_EEG_art_det_conus.highfre_edit.String = '';
                msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Preview > Optional: The highest frequency should be a positive value'];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            if any(lowfre_edit(:)>=highfre_edit(:))
                Eegtab_EEG_art_det_conus.highfre_edit.String = '';
                msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Preview > Optional: The highest frequency should be larger than the lowest one'];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            if any(highfre_edit(:)>=observe_EEGDAT.EEG.srate/2)
                Eegtab_EEG_art_det_conus.highfre_edit.String = '';
                msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Preview > Optional: The highest frequency should be smaller than',32,num2str(roundn(observe_EEGDAT.EEG.srate/2,-2))];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            includef=Eegtab_EEG_art_det_conus.include_fre.Value;
            fcutoff = [lowfre_edit,highfre_edit];
            if includef==0 && fcutoff(1)~=fcutoff(2)% when it means "excluded" frequency cuttof is inverse to make a notch filter
                fcutoff = circshift(fcutoff',1)';
            elseif includef==1 && fcutoff(1)==0 && fcutoff(2)==0
                fcutoff = [inf inf]; % [inf inf] to include the mean of data; fcutoff = [0 0] means exclude the mean
            else
                %                 fcutoff = [];
            end
        end
        
        %%Joint artifactual segments separated by less than
        if Eegtab_EEG_art_det_conus.joinarseg_checkbox.Value==0
            shortisi = [];
        end
        if Eegtab_EEG_art_det_conus.joinarseg_checkbox.Value==1
            shortisi = str2num(Eegtab_EEG_art_det_conus.joinarseg_edit.String);
            if isempty(shortisi) || numel(shortisi)~=1 || any(shortisi(:)<=0)
                Eegtab_EEG_art_det_conus.joinarseg_edit.String = '';
                msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Preview > Optional: Invalid input for segements separation and it should be a positive value'];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
            end
        end
        %%unmark
        if Eegtab_EEG_art_det_conus.unmarkarseg_checkbox.Value==0
            shortseg = [];
        end
        if Eegtab_EEG_art_det_conus.unmarkarseg_checkbox.Value==1
            shortseg = str2num(Eegtab_EEG_art_det_conus.unmarkarseg_edit.String);
            if isempty(shortseg) || numel(shortseg)~=1 || any(shortseg(:)<=0)
                Eegtab_EEG_art_det_conus.unmarkarseg_edit.String = '';
                msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Preview > Optional: Invalid input for unmark artifactual segments and it should be a positive value'];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
            end
        end
        
        %%add extra time
        if Eegtab_EEG_art_det_conus.addtime_checkbox.Value==0
            winoffset=[];
        end
        if Eegtab_EEG_art_det_conus.addtime_checkbox.Value==1
            winoffset = str2num( Eegtab_EEG_art_det_conus.addtime_edit.String);
            if isempty(winoffset) || numel(winoffset)~=1 || any(winoffset(:)<=0)
                Eegtab_EEG_art_det_conus.addtime_edit.String = '';
                msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Preview > Optional: Invalid input for "add extra time" and it should be a positive value'];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
            end
        end
        
        memoryCARTGUI   = estudioworkingmemory('continuousartifactGUI');
        colorseg = [ 0.83 0.82 0.79];
        memoryCARTGUI.def{1} = Volthreshold;
        memoryCARTGUI.def{2} = WindowLength;
        memoryCARTGUI.def{3} = windowStep;
        memoryCARTGUI.def{4} = ChanArray;
        memoryCARTGUI.def{5} = lowfre_edit;
        memoryCARTGUI.def{6} = highfre_edit;
        memoryCARTGUI.def{7} = includef;
        memoryCARTGUI.def{9} = shortisi;
        memoryCARTGUI.def{10} = shortseg;
        memoryCARTGUI.def{11} = winoffset;
        estudioworkingmemory('continuousartifactGUI',memoryCARTGUI);
        fdet = 'off';
        forder =100;
        try
            EEG = observe_EEGDAT.ALLEEG(EEGArray);
        catch
            EEG = observe_EEGDAT.EEG;
        end
        fprintf( ['\n\n',repmat('-',1,100) '\n']);
        fprintf(['*Reject Artifactual Time Segments (Continuous EEG) > Preview*',32,32,32,32,datestr(datetime('now')),'\n']);
        fprintf(['Your current EEGset(No.',num2str(EEGArray),'):',32,EEG.setname,'\n\n']);
        
        
        [EEG,LASTCOM]= pop_continuousartdet(EEG, 'chanArray'   , ChanArray    ...
            , 'ampth'       , Volthreshold        ...
            , 'winms'       , WindowLength        ...
            , 'stepms'      , windowStep       ...
            , 'firstdet'    , fdet         ...
            , 'fcutoff'     , fcutoff      ...%%
            , 'forder'      , forder       ...%%fixed
            , 'shortisi'    , shortisi     ...%%join
            , 'shortseg'    , shortseg     ...%%unmark
            , 'winoffset'   , winoffset    ...%%add extra
            , 'colorseg'    , colorseg     ...
            ,'review','on','History','implicit');
        
        if isempty(LASTCOM)
        else
            fprintf([LASTCOM,'\n']);
        end
        eegh(LASTCOM);
        fprintf( [repmat('-',1,100) '\n']);
        estudioworkingmemory('f_EEG_proces_messg','Reject Artifactual Time Segments (Continuous EEG) > Preview');
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
        estudioworkingmemory('f_EEG_proces_messg','Reject Artifactual Time Segments (Continuous EEG) > Finalize');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        Eegtab_box_art_det_conus.TitleColor= [0.0500    0.2500    0.5000];
        Eegtab_EEG_art_det_conus.detectar_preview.BackgroundColor =  [1 1 1];
        Eegtab_EEG_art_det_conus.detectar_preview.ForegroundColor = [0 0 0];
        Eegtab_EEG_art_det_conus.detectar_run.BackgroundColor =  [ 1 1 1];
        Eegtab_EEG_art_det_conus.detectar_run.ForegroundColor = [0 0 0];
        Eegtab_EEG_art_det_conus.detectar_cancel.BackgroundColor =  [ 1 1 1];
        Eegtab_EEG_art_det_conus.detectar_cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('EEGTab_detect_arts_conus',0);
        %%--------Selected EEGsets-----------
        EEGArray= estudioworkingmemory('EEGArray');
        if isempty(EEGArray) || any(EEGArray(:) > length(observe_EEGDAT.ALLEEG))
            EEGArray = observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',EEGArray);
        end
        
        %%chans
        ChanArray = str2num(Eegtab_EEG_art_det_conus.chan_edit.String);
        nbchan = observe_EEGDAT.EEG.nbchan;
        if isempty(ChanArray) || any(ChanArray(:) <=0) ||  any(ChanArray(:) > nbchan)
            msgboxText=['Reject Artifactual Time Segments (Continuous EEG) > Finalize: Chans are empty or index(es) are not between 1 and',32,num2str(nbchan)];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        
        %%----------if simple voltage threshold------------
        Volthreshold = sort(str2num(Eegtab_EEG_art_det_conus.voltage_edit.String));
        if isempty(Volthreshold) || (numel(Volthreshold)~=1 && numel(Volthreshold)~=2)
            msgboxText= ['Reject Artifactual Time Segments (Continuous EEG) > Finalize: Voltage threshold must have one or two values'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        
        if numel(Volthreshold)==2
            if Volthreshold(2) >= Volthreshold(1)
                msgboxText=['Reject Artifactual Time Segments (Continuous EEG) > Finalize: When 2 thresholds are specified, the first one must be lesser than the second one'];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                observe_EEGDAT.eeg_panel_message =2;
                return;
            end
        end
        
        %
        %%Moving window full width
        WindowLength = str2num(Eegtab_EEG_art_det_conus.movewindow_edit.String);
        if isempty(WindowLength) || numel(WindowLength) ~=1 ||  any(WindowLength(:)<=0)
            msgboxText=['Reject Artifactual Time Segments (Continuous EEG) > Finalize: Move window width must be a positive number'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            Eegtab_EEG_art_det_conus.movewindow_edit.String = '500';
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        
        windowStep = str2num(Eegtab_EEG_art_det_conus.windowstep_edit.String);
        if  any(windowStep(:)>=WindowLength)
            msgboxText=['Reject Artifactual Time Segments (Continuous EEG) > Finalize: Step width cannot be larger than the window width'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            Eegtab_EEG_art_det_conus.windowstep_edit.String = '';
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        
        if isempty(windowStep) || numel(windowStep) ~=1 ||  any(windowStep(:)<=0)
            msgboxText=['Reject Artifactual Time Segments (Continuous EEG) > Finalize: Window step width must be a positive number'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            Eegtab_EEG_art_det_conus.windowstep_edit.String = '';
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        %%WindowStep
        if  any(windowStep(:)>=WindowLength)
            msgboxText=['Reject Artifactual Time Segments (Continuous EEG) > Finalize: Step width must be smaller than the window width'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            Eegtab_EEG_art_det_conus.windowstep_edit.String = '';
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        
        if Eegtab_EEG_art_det_conus.filter_checkbox.Value==0
            fcutoff = [];
            lowfre_edit = [];
            highfre_edit = [];
            includef = [];
        end
        
        if Eegtab_EEG_art_det_conus.filter_checkbox.Value==1
            lowfre_edit = str2num(Eegtab_EEG_art_det_conus.lowfre_edit.String);
            if isempty(lowfre_edit) || numel(lowfre_edit)~=1 || any(lowfre_edit(:)<0)
                Eegtab_EEG_art_det_conus.lowfre_edit.String = '';
                msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Finalize >Optional: The lowest frequency should be a positive value'];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                observe_EEGDAT.eeg_panel_message =2;
                return;
            end
            
            highfre_edit = str2num(Eegtab_EEG_art_det_conus.highfre_edit.String);
            if any(lowfre_edit(:)>=highfre_edit(:))
                Eegtab_EEG_art_det_conus.lowfre_edit.String = '';
                msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Finalize> Optional: The lowest frequency should be smaller than the highest one'];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                observe_EEGDAT.eeg_panel_message =2;
                return;
            end
            
            if any(lowfre_edit(:)>=observe_EEGDAT.EEG.srate/2)
                Eegtab_EEG_art_det_conus.lowfre_edit.String = '';
                msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Finalize > Optional: The lowest frequency should be smaller than',32,num2str(roundn(observe_EEGDAT.EEG.srate/2,-2))];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                observe_EEGDAT.eeg_panel_message =2;
                return;
            end
            
            if isempty(highfre_edit) || numel(highfre_edit)~=1 || any(highfre_edit(:)<0)
                Eegtab_EEG_art_det_conus.highfre_edit.String = '';
                msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Finalize > Optional: The highest frequency should be a positive value'];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                observe_EEGDAT.eeg_panel_message =2;
                return;
            end
            
            if any(highfre_edit(:)>=observe_EEGDAT.EEG.srate/2)
                Eegtab_EEG_art_det_conus.highfre_edit.String = '';
                msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Finalize > Optional: The highest frequency should be smaller than',32,num2str(roundn(observe_EEGDAT.EEG.srate/2,-2))];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                observe_EEGDAT.eeg_panel_message =2;
                return;
            end
            includef=Eegtab_EEG_art_det_conus.include_fre.Value;
            fcutoff = [lowfre_edit,highfre_edit];
            if includef==0 && fcutoff(1)~=fcutoff(2)% when it means "excluded" frequency cuttof is inverse to make a notch filter
                fcutoff = circshift(fcutoff',1)';
            elseif includef==1 && fcutoff(1)==0 && fcutoff(2)==0
                fcutoff = [inf inf]; % [inf inf] to include the mean of data; fcutoff = [0 0] means exclude the mean
            else
                %                 fcutoff = [];
            end
        end
        
        %%Joint artifactual segments separated by less than
        if Eegtab_EEG_art_det_conus.joinarseg_checkbox.Value==0
            shortisi = [];
        end
        if Eegtab_EEG_art_det_conus.joinarseg_checkbox.Value==1
            shortisi = str2num(Eegtab_EEG_art_det_conus.joinarseg_edit.String);
            if isempty(shortisi) || numel(shortisi)~=1 || any(shortisi(:)<=0)
                Eegtab_EEG_art_det_conus.joinarseg_edit.String = '';
                msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Finalize > Optional: Invalid input for segements separation and it should be a positive value'];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
            end
        end
        %%unmark
        if Eegtab_EEG_art_det_conus.unmarkarseg_checkbox.Value==0
            shortseg = [];
        end
        if Eegtab_EEG_art_det_conus.unmarkarseg_checkbox.Value==1
            shortseg = str2num(Eegtab_EEG_art_det_conus.unmarkarseg_edit.String);
            if isempty(shortseg) || numel(shortseg)~=1 || any(shortseg(:)<=0)
                Eegtab_EEG_art_det_conus.unmarkarseg_edit.String = '';
                msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Finalize > Optional: Invalid input for unmark artifactual segments and it should be a positive value'];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
            end
        end
        
        %%add extra time
        if Eegtab_EEG_art_det_conus.addtime_checkbox.Value==0
            winoffset=[];
        end
        if Eegtab_EEG_art_det_conus.addtime_checkbox.Value==1
            winoffset = str2num( Eegtab_EEG_art_det_conus.addtime_edit.String);
            if isempty(winoffset) || numel(winoffset)~=1 || any(winoffset(:)<=0)
                Eegtab_EEG_art_det_conus.addtime_edit.String = '';
                msgboxText = ['Reject Artifactual Time Segments (Continuous EEG) > Finalize > Optional: Invalid input for "add extra time" and it should be a positive value'];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
            end
        end
        Eegtab_EEG_art_det_conus.manuar_checkbox_Value = Eegtab_EEG_art_det_conus.manuar_checkbox.Value;
        
        fdet = 'off';
        forder =100;
        
        memoryCARTGUI   = estudioworkingmemory('continuousartifactGUI');
        colorseg = [ 0.83 0.82 0.79];
        memoryCARTGUI.def{1} = Volthreshold;
        memoryCARTGUI.def{2} = WindowLength;
        memoryCARTGUI.def{3} = windowStep;
        memoryCARTGUI.def{4} = ChanArray;
        memoryCARTGUI.def{5} = lowfre_edit;
        memoryCARTGUI.def{6} = highfre_edit;
        memoryCARTGUI.def{7} = includef;
        memoryCARTGUI.def{9} = shortisi;
        memoryCARTGUI.def{10} = shortseg;
        memoryCARTGUI.def{11} = winoffset;
        estudioworkingmemory('continuousartifactGUI',memoryCARTGUI);
        
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
            
            [EEG,LASTCOM]= pop_continuousartdet(EEG, 'chanArray'   , ChanArray    ...
                , 'ampth'       , Volthreshold        ...
                , 'winms'       , WindowLength        ...
                , 'stepms'      , windowStep       ...
                , 'firstdet'    , fdet         ...
                , 'fcutoff'     , fcutoff      ...%%
                , 'forder'      , forder       ...%%fixed
                , 'shortisi'    , shortisi     ...%%join
                , 'shortseg'    , shortseg     ...%%unmark
                , 'winoffset'   , winoffset    ...%%add extra
                , 'colorseg'    , colorseg     ...
                ,'review','off','History','implicit');
            
            
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
            [ALLEEG_out,~,~] = pop_newset(ALLEEG_out, EEG, length(ALLEEG_out), 'gui', 'off');
            fprintf( [repmat('-',1,100) '\n']);
            if Numofeeg==1
                eegh(LASTCOM);
            end
        end%%end for loop of subjects
        Answer = f_EEG_save_multi_file(ALLEEG_out,1:numel(EEGArray),'');
        if isempty(Answer)
            observe_EEGDAT.eeg_panel_message =2;
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
        if observe_EEGDAT.count_current_eeg ~=16
            return;
        end
        EEGUpdate = estudioworkingmemory('EEGUpdate');
        if isempty(EEGUpdate) || numel(EEGUpdate)~=1 || (EEGUpdate~=0 && EEGUpdate~=1)
            EEGUpdate = 0;  estudioworkingmemory('EEGUpdate',0);
        end
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1 || EEGUpdate==1
            Eegtab_EEG_art_det_conus.chan_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.chan_browse.Enable= 'off';
            Eegtab_EEG_art_det_conus.voltage_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.movewindow_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.windowstep_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.detectar_cancel.Enable= 'off';
            Eegtab_EEG_art_det_conus.detectar_preview.Enable= 'off';
            Eegtab_EEG_art_det_conus.detectar_run.Enable= 'off';
            Eegtab_EEG_art_det_conus.filter_checkbox.Enable= 'off';
            Eegtab_EEG_art_det_conus.lowfre_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.highfre_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.include_fre.Enable= 'off';
            Eegtab_EEG_art_det_conus.exclude_fre.Enable= 'off';
            Eegtab_EEG_art_det_conus.joinarseg_checkbox.Enable= 'off';
            Eegtab_EEG_art_det_conus.joinarseg_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.unmarkarseg_checkbox.Enable= 'off';
            Eegtab_EEG_art_det_conus.joinarseg_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.addtime_checkbox.Enable= 'off';
            Eegtab_EEG_art_det_conus.addtime_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.manuar_checkbox.Enable = 'off';
            Eegtab_EEG_art_det_conus.manuar_button.Enable = 'off';
            if ~isempty(observe_EEGDAT.EEG) && observe_EEGDAT.EEG.trials ~=1
                Eegtab_box_art_det_conus.TitleColor= [0.75 0.75 0.75];
            else
                Eegtab_box_art_det_conus.TitleColor= [0.0500    0.2500    0.5000];
            end
            observe_EEGDAT.count_current_eeg=17;
            return;
        end
        Eegtab_EEG_art_det_conus.manuar_checkbox.Enable = 'on';
        Eegtab_EEG_art_det_conus.manuar_button.Enable = 'on';
        Eegtab_box_art_det_conus.TitleColor= [0.0500    0.2500    0.5000];
        Eegtab_EEG_art_det_conus.chan_edit.Enable= 'on';
        Eegtab_EEG_art_det_conus.chan_browse.Enable= 'on';
        Eegtab_EEG_art_det_conus.periods_edit.Enable= 'on';
        Eegtab_EEG_art_det_conus.voltage_edit.Enable= 'on';
        Eegtab_EEG_art_det_conus.movewindow_edit.Enable= 'on';
        Eegtab_EEG_art_det_conus.windowstep_edit.Enable= 'on';
        Eegtab_EEG_art_det_conus.detectar_cancel.Enable= 'on';
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
        
        %%optionals
        Eegtab_EEG_art_det_conus.filter_checkbox.Enable= 'on';
        if Eegtab_EEG_art_det_conus.filter_checkbox.Value==1
            enableflag = 'on';
        else
            enableflag = 'off';
        end
        Eegtab_EEG_art_det_conus.lowfre_edit.Enable= enableflag;
        Eegtab_EEG_art_det_conus.highfre_edit.Enable= enableflag;
        Eegtab_EEG_art_det_conus.include_fre.Enable= enableflag;
        Eegtab_EEG_art_det_conus.exclude_fre.Enable= enableflag;
        Eegtab_EEG_art_det_conus.joinarseg_checkbox.Enable= 'on';
        if Eegtab_EEG_art_det_conus.joinarseg_checkbox.Value==1
            Eegtab_EEG_art_det_conus.joinarseg_edit.Enable= 'on';
        else
            Eegtab_EEG_art_det_conus.joinarseg_edit.Enable= 'off';
        end
        Eegtab_EEG_art_det_conus.unmarkarseg_checkbox.Enable= 'on';
        if Eegtab_EEG_art_det_conus.unmarkarseg_checkbox.Value==1
            Eegtab_EEG_art_det_conus.unmarkarseg_edit.Enable= 'on';
        else
            Eegtab_EEG_art_det_conus.unmarkarseg_edit.Enable= 'off';
        end
        Eegtab_EEG_art_det_conus.addtime_checkbox.Enable= 'on';
        if Eegtab_EEG_art_det_conus.addtime_checkbox.Value==1
            Eegtab_EEG_art_det_conus.addtime_edit.Enable= 'on';
        else
            Eegtab_EEG_art_det_conus.addtime_edit.Enable= 'off';
        end
        
        if Eegtab_EEG_art_det_conus.manuar_checkbox.Value==0
            Eegtab_EEG_art_det_conus.manuar_button.Enable = 'off';
            Eegtab_EEG_art_det_conus.chan_edit.Enable= 'on';
            Eegtab_EEG_art_det_conus.chan_browse.Enable= 'on';
            Eegtab_EEG_art_det_conus.voltage_edit.Enable= 'on';
            Eegtab_EEG_art_det_conus.movewindow_edit.Enable= 'on';
            Eegtab_EEG_art_det_conus.windowstep_edit.Enable= 'on';
            Eegtab_EEG_art_det_conus.detectar_cancel.Enable= 'on';
            Eegtab_EEG_art_det_conus.detectar_preview.Enable= 'on';
            Eegtab_EEG_art_det_conus.detectar_run.Enable= 'on';
            Eegtab_EEG_art_det_conus.filter_checkbox.Enable= 'on';
            if  Eegtab_EEG_art_det_conus.filter_checkbox.Value==1
                Eegtab_EEG_art_det_conus.lowfre_edit.Enable= 'on';
                Eegtab_EEG_art_det_conus.highfre_edit.Enable= 'on';
                Eegtab_EEG_art_det_conus.include_fre.Enable= 'on';
                Eegtab_EEG_art_det_conus.exclude_fre.Enable= 'on';
            else
                Eegtab_EEG_art_det_conus.lowfre_edit.Enable= 'off';
                Eegtab_EEG_art_det_conus.highfre_edit.Enable= 'off';
                Eegtab_EEG_art_det_conus.include_fre.Enable= 'off';
                Eegtab_EEG_art_det_conus.exclude_fre.Enable= 'off';
            end
            
            Eegtab_EEG_art_det_conus.joinarseg_checkbox.Enable= 'on';
            if Eegtab_EEG_art_det_conus.joinarseg_checkbox.Value==1
                Eegtab_EEG_art_det_conus.joinarseg_edit.Enable= 'on';
            else
                Eegtab_EEG_art_det_conus.joinarseg_edit.Enable= 'off';
            end
            
            Eegtab_EEG_art_det_conus.unmarkarseg_checkbox.Enable= 'on';
            if Eegtab_EEG_art_det_conus.unmarkarseg_checkbox.Value==1
                Eegtab_EEG_art_det_conus.joinarseg_edit.Enable= 'on';
            else
                Eegtab_EEG_art_det_conus.joinarseg_edit.Enable= 'off';
            end
            Eegtab_EEG_art_det_conus.addtime_checkbox.Enable= 'on';
            if Eegtab_EEG_art_det_conus.addtime_checkbox.Value==1
                Eegtab_EEG_art_det_conus.addtime_edit.Enable= 'on';
            else
                Eegtab_EEG_art_det_conus.addtime_edit.Enable= 'off';
            end
        else
            Eegtab_EEG_art_det_conus.chan_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.chan_browse.Enable= 'off';
            Eegtab_EEG_art_det_conus.voltage_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.movewindow_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.windowstep_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.detectar_cancel.Enable= 'on';
            Eegtab_EEG_art_det_conus.detectar_preview.Enable= 'off';
            Eegtab_EEG_art_det_conus.detectar_run.Enable= 'off';
            Eegtab_EEG_art_det_conus.filter_checkbox.Enable= 'off';
            Eegtab_EEG_art_det_conus.lowfre_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.highfre_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.include_fre.Enable= 'off';
            Eegtab_EEG_art_det_conus.exclude_fre.Enable= 'off';
            Eegtab_EEG_art_det_conus.joinarseg_checkbox.Enable= 'off';
            Eegtab_EEG_art_det_conus.joinarseg_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.unmarkarseg_checkbox.Enable= 'off';
            Eegtab_EEG_art_det_conus.joinarseg_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.addtime_checkbox.Enable= 'off';
            Eegtab_EEG_art_det_conus.addtime_edit.Enable= 'off';
            Eegtab_EEG_art_det_conus.manuar_button.Enable = 'on';
        end
        Eegtab_EEG_art_det_conus.manuar_checkbox_Value = Eegtab_EEG_art_det_conus.manuar_checkbox.Value;
        observe_EEGDAT.count_current_eeg=17;
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
            Eegtab_EEG_art_det_conus.detectar_cancel.BackgroundColor =  [ 1 1 1];
            Eegtab_EEG_art_det_conus.detectar_cancel.ForegroundColor = [0 0 0];
        else
            return;
        end
    end

%%--------------Reset this panel with the default parameters---------------
    function Reset_eeg_panel_change(~,~)
        if observe_EEGDAT.Reset_eeg_paras_panel~=13
            return;
        end
        estudioworkingmemory('EEGTab_detect_arts_conus',0);
        Eegtab_EEG_art_det_conus.detectar_preview.BackgroundColor =  [1 1 1];
        Eegtab_EEG_art_det_conus.detectar_preview.ForegroundColor = [0 0 0];
        Eegtab_EEG_art_det_conus.detectar_run.BackgroundColor =  [ 1 1 1];
        Eegtab_EEG_art_det_conus.detectar_run.ForegroundColor = [0 0 0];
        Eegtab_EEG_art_det_conus.detectar_cancel.BackgroundColor =  [1 1 1];
        Eegtab_EEG_art_det_conus.detectar_cancel.ForegroundColor = [0 0 0];
        if isempty(observe_EEGDAT.EEG)
            Eegtab_EEG_art_det_conus.chan_edit.String = '';
        else
            Eegtab_EEG_art_det_conus.chan_edit.String = vect2colon([1:observe_EEGDAT.EEG.nbchan]);
        end
        Eegtab_EEG_art_det_conus.voltage_edit.String = '500';
        Eegtab_EEG_art_det_conus.movewindow_edit.String = '500';
        Eegtab_EEG_art_det_conus.windowstep_edit.String = '250';
        
        Eegtab_EEG_art_det_conus.manuar_checkbox.Value=0;
        Eegtab_EEG_art_det_conus.manuar_checkbox.Enable = 'off';
        Eegtab_EEG_art_det_conus.manuar_button.Enable = 'off';
        Eegtab_EEG_art_det_conus.filter_checkbox.Value=0;
        Eegtab_EEG_art_det_conus.lowfre_edit.Enable = 'off';
        Eegtab_EEG_art_det_conus.lowfre_edit.String = '';
        Eegtab_EEG_art_det_conus.highfre_edit.Enable = 'off';
        Eegtab_EEG_art_det_conus.highfre_edit.String = '';
        Eegtab_EEG_art_det_conus.include_fre.Enable = 'off';
        Eegtab_EEG_art_det_conus.exclude_fre.Enable = 'off';
        Eegtab_EEG_art_det_conus.joinarseg_checkbox.Value = 0;
        Eegtab_EEG_art_det_conus.joinarseg_edit.Enable = 'off';
        Eegtab_EEG_art_det_conus.joinarseg_edit.String = '';
        Eegtab_EEG_art_det_conus.unmarkarseg_checkbox.Value = 0;
        Eegtab_EEG_art_det_conus.unmarkarseg_edit.Enable = 'off';
        Eegtab_EEG_art_det_conus.unmarkarseg_edit.String = '';
        Eegtab_EEG_art_det_conus.addtime_checkbox.Value = 0;
        Eegtab_EEG_art_det_conus.addtime_edit.Enable = 'off';
        Eegtab_EEG_art_det_conus.addtime_edit.String = '';
        Eegtab_EEG_art_det_conus.manuar_checkbox_Value = 0;
        observe_EEGDAT.Reset_eeg_paras_panel=14;
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