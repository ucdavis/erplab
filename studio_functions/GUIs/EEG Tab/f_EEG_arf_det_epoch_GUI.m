%%This function is to detect artifacts for epoched EEG.


% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Oct. 2023 && Jan. 2024


function varargout = f_EEG_arf_det_epoch_GUI(varargin)

global observe_EEGDAT;
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
addlistener(observe_EEGDAT,'Reset_eeg_panel_change',@Reset_eeg_panel_change);
%---------------------------Initialize parameters------------------------------------

Eegtab_EEG_art_det_epoch = struct();

%-----------------------------Name the title----------------------------------------------
% global Eegtab_box_art_det_epoch;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    Eegtab_box_art_det_epoch = uiextras.BoxPanel('Parent', fig, 'Title', 'Artifact Detection for Epoched EEG',...
        'Padding', 5,'BackgroundColor',ColorB_def, 'HelpFcn', @artepo_help); % Create boxpanel
elseif nargin == 1
    Eegtab_box_art_det_epoch = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Artifact Detection for Epoched EEG',...
        'Padding', 5,'BackgroundColor',ColorB_def, 'HelpFcn', @artepo_help);
else
    Eegtab_box_art_det_epoch = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Artifact Detection for Epoched EEG',...
        'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def, 'HelpFcn', @artepo_help);
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

drawui_art_det_epoch_eeg(FonsizeDefault)
varargout{1} = Eegtab_box_art_det_epoch;

    function drawui_art_det_epoch_eeg(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        Eegtab_EEG_art_det_epoch.DataSelBox = uiextras.VBox('Parent', Eegtab_box_art_det_epoch,'BackgroundColor',ColorB_def);
        FontSize_defualt = FonsizeDefault;
        if isempty(FontSize_defualt)
            FontSize_defualt = 12;
        end
        if isempty(observe_EEGDAT.EEG)
            EnableFlag = 'off';
        else
            EnableFlag = 'on';
        end
        %%display original data?
        Eegtab_EEG_art_det_epoch.art_det_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_epoch.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent',Eegtab_EEG_art_det_epoch.art_det_title,...
            'String','Algorithms:','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_epoch.det_algo = uicontrol('Style', 'popupmenu','Parent',Eegtab_EEG_art_det_epoch.art_det_title,...
            'String','','callback',@det_algo,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        Eegtab_EEG_art_det_epoch.det_algo.KeyPressFcn=  @eeg_artdetect_presskey;
        
        Det_algostr = {'Simple voltage threshold','Moving window peak-to-peak',...
            'Step-like artifacts','Sample to sample voltage',...
            'Blocking & flat line'};
        Eegtab_EEG_art_det_epoch.det_algo.String = Det_algostr;
        Eegtab_EEG_art_det_epoch.det_algo.Value =1;
        set(Eegtab_EEG_art_det_epoch.art_det_title, 'Sizes',[70 -1]);
        Eegtab_EEG_art_det_epoch.Paras{1} = Eegtab_EEG_art_det_epoch.det_algo.Value;
        %%channels that detect artifact
        Eegtab_EEG_art_det_epoch.chan_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_epoch.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',Eegtab_EEG_art_det_epoch.chan_title,...
            'String','Chans:','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        Eegtab_EEG_art_det_epoch.chan_edit = uicontrol('Style','edit','Parent',Eegtab_EEG_art_det_epoch.chan_title,...
            'String','','FontSize',FontSize_defualt,'callback',@chan_edit,'Enable',EnableFlag,'BackgroundColor',[1 1 1]); % 2F
        Eegtab_EEG_art_det_epoch.chan_edit.KeyPressFcn=  @eeg_artdetect_presskey;
        Eegtab_EEG_art_det_epoch.chan_browse = uicontrol('Style','pushbutton','Parent',Eegtab_EEG_art_det_epoch.chan_title,...
            'String','Browse','FontSize',FontSize_defualt,'callback',@chan_browse,'Enable',EnableFlag,'BackgroundColor',[1 1 1]); % 2F
        set( Eegtab_EEG_art_det_epoch.chan_title,'Sizes',[60 -1 80]);
        Eegtab_EEG_art_det_epoch.Paras{2} = str2num(Eegtab_EEG_art_det_epoch.chan_edit.String);
        
        %%Flags
        Eegtab_EEG_art_det_epoch.markflgas_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_epoch.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',Eegtab_EEG_art_det_epoch.markflgas_title,'FontWeight','bold',...
            'String','Mark Flag (flag 1 is reserved):','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        
        
        Eegtab_EEG_art_det_epoch.markflgas_title1 = uiextras.HBox('Parent', Eegtab_EEG_art_det_epoch.DataSelBox,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_epoch.mflag1 = uicontrol('Style','checkbox','Parent',Eegtab_EEG_art_det_epoch.markflgas_title1,...
            'callback',@mflag1,'String','1','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable','off','BackgroundColor',ColorB_def,'Value',1); % 2F
        Eegtab_EEG_art_det_epoch.mflag2 = uicontrol('Style','checkbox','Parent',Eegtab_EEG_art_det_epoch.markflgas_title1,...
            'callback',@mflag2,'String','2','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def,'Value',0); % 2F
        Eegtab_EEG_art_det_epoch.mflag3 = uicontrol('Style','checkbox','Parent',Eegtab_EEG_art_det_epoch.markflgas_title1,...
            'callback',@mflag3,'String','3','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def,'Value',0); % 2F
        Eegtab_EEG_art_det_epoch.mflag4 = uicontrol('Style','checkbox','Parent',Eegtab_EEG_art_det_epoch.markflgas_title1,...
            'callback',@mflag4,'String','4','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def,'Value',0); % 2F
        
        
        
        %         Eegtab_EEG_art_det_epoch.markflgas_title2 = uiextras.HBox('Parent', Eegtab_EEG_art_det_epoch.DataSelBox,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_epoch.mflag5 = uicontrol('Style','checkbox','Parent',Eegtab_EEG_art_det_epoch.markflgas_title1,...
            'callback',@mflag5,'String','5','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def,'Value',0); % 2F
        Eegtab_EEG_art_det_epoch.mflag6 = uicontrol('Style','checkbox','Parent',Eegtab_EEG_art_det_epoch.markflgas_title1,...
            'callback',@mflag6,'String','6','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def,'Value',0); % 2F
        Eegtab_EEG_art_det_epoch.mflag7 = uicontrol('Style','checkbox','Parent',Eegtab_EEG_art_det_epoch.markflgas_title1,...
            'callback',@mflag7,'String','7','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def,'Value',0); % 2F
        Eegtab_EEG_art_det_epoch.mflag8 = uicontrol('Style','checkbox','Parent',Eegtab_EEG_art_det_epoch.markflgas_title1,...
            'callback',@mflag8,'String','8','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def,'Value',0); % 2F
        Eegtab_EEG_art_det_epoch.mflag = [1,0,0,0,0,0,0,0];
        Eegtab_EEG_art_det_epoch.Paras{3} = Eegtab_EEG_art_det_epoch.mflag;
        set( Eegtab_EEG_art_det_epoch.markflgas_title1,'Sizes',[33 33 33 33 33 33 33 33]);
        %%test period
        Eegtab_EEG_art_det_epoch.periods_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_epoch.DataSelBox,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_epoch.periods_editext=uicontrol('Style','text','Parent',Eegtab_EEG_art_det_epoch.periods_title,...
            'String','Test period [ms] (start end)','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def); % 2F
        Eegtab_EEG_art_det_epoch.periods_edit = uicontrol('Style','edit','Parent',Eegtab_EEG_art_det_epoch.periods_title,...
            'callback',@periods_edit,'String','','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',[1 1 1]); % 2F
        Eegtab_EEG_art_det_epoch.periods_edit.KeyPressFcn=  @eeg_artdetect_presskey;
        set(Eegtab_EEG_art_det_epoch.periods_title,'Sizes',[90,-1]);
        Eegtab_EEG_art_det_epoch.Paras{4} = str2num(Eegtab_EEG_art_det_epoch.periods_edit.String);
        
        %%Voltage limits
        Eegtab_EEG_art_det_epoch.voltage_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_epoch.DataSelBox,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_epoch.voltage_text = uicontrol('Style','text','Parent',Eegtab_EEG_art_det_epoch.voltage_title,...
            'String','Voltage limits [uV] (e.g., -100 100)','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def); % 2F
        Eegtab_EEG_art_det_epoch.voltage_edit = uicontrol('Style','edit','Parent',Eegtab_EEG_art_det_epoch.voltage_title,...
            'callback',@voltage_edit,'String','','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',[1 1 1]); % 2F
        Eegtab_EEG_art_det_epoch.voltage_edit.KeyPressFcn=  @eeg_artdetect_presskey;
        set(Eegtab_EEG_art_det_epoch.voltage_title,'Sizes',[100,-1]);
        Eegtab_EEG_art_det_epoch.Paras{5} = str2num(Eegtab_EEG_art_det_epoch.voltage_edit.String);
        
        %%moving window full width
        Eegtab_EEG_art_det_epoch.movewindow_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_epoch.DataSelBox,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_epoch.movewindow_text = uicontrol('Style','text','Parent',Eegtab_EEG_art_det_epoch.movewindow_title,...
            'String','','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def); % 2F
        Eegtab_EEG_art_det_epoch.movewindow_edit = uicontrol('Style','edit','Parent',Eegtab_EEG_art_det_epoch.movewindow_title,...
            'callback',@movewindow_edit,'String','','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',[1 1 1]); % 2F
        Eegtab_EEG_art_det_epoch.movewindow_edit.KeyPressFcn=  @eeg_artdetect_presskey;
        set(Eegtab_EEG_art_det_epoch.movewindow_title,'Sizes',[100,-1]);
        Eegtab_EEG_art_det_epoch.Paras{6} = str2num(Eegtab_EEG_art_det_epoch.movewindow_edit.String);
        
        %%Window steps
        Eegtab_EEG_art_det_epoch.windowstep_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_epoch.DataSelBox,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_epoch.windowstep_text = uicontrol('Style','text','Parent',Eegtab_EEG_art_det_epoch.windowstep_title,...
            'String','','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def); % 2F
        Eegtab_EEG_art_det_epoch.windowstep_edit = uicontrol('Style','edit','Parent',Eegtab_EEG_art_det_epoch.windowstep_title,...
            'callback',@windowstep_edit,'String','','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',[1 1 1]); % 2F
        Eegtab_EEG_art_det_epoch.windowstep_edit.KeyPressFcn=  @eeg_artdetect_presskey;
        set(Eegtab_EEG_art_det_epoch.windowstep_title,'Sizes',[100,-1]);
        Eegtab_EEG_art_det_epoch.Paras{7} = str2num(Eegtab_EEG_art_det_epoch.windowstep_edit.String);
        
        %%-----------------------Cancel and Run----------------------------
        Eegtab_EEG_art_det_epoch.detar_run_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_epoch.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Eegtab_EEG_art_det_epoch.detar_run_title);
        Eegtab_EEG_art_det_epoch.detectar_cancel = uicontrol('Style', 'pushbutton','Parent',Eegtab_EEG_art_det_epoch.detar_run_title,...
            'String','Cancel','callback',@detectar_cancel,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', Eegtab_EEG_art_det_epoch.detar_run_title);
        Eegtab_EEG_art_det_epoch.detectar_run = uicontrol('Style','pushbutton','Parent',Eegtab_EEG_art_det_epoch.detar_run_title,...
            'String','Finalize','callback',@detectar_run,'FontSize',FontSize_defualt,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', Eegtab_EEG_art_det_epoch.detar_run_title);
        set(Eegtab_EEG_art_det_epoch.detar_run_title,'Sizes',[10,-1,30,-1,10]);
        
        set(Eegtab_EEG_art_det_epoch.DataSelBox,'Sizes',[30 30 25 25 35 35 35 30 30]);
        estudioworkingmemory('EEGTab_detect_arts_epoch',0);
        
    end


%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%--------------------------help-------------------------------------------
    function artepo_help(~,~)
        web('https://github.com/ucdavis/erplab/wiki/Artifact-Detection-in-Epoched-Data/','-browser');
    end

%%-------------------Artifact detection algorithms-------------------------
    function det_algo(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_art_det_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_art_det_epoch.detectar_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_epoch',1);
        chanArray = str2num(Eegtab_EEG_art_det_epoch.chan_edit.String);
        if isempty(chanArray) || min(chanArray(:)) > observe_EEGDAT.EEG.nbchan || max(chanArray(:)) > observe_EEGDAT.EEG.nbchan
            Eegtab_EEG_art_det_epoch.chan_edit.String = vect2colon([1:observe_EEGDAT.EEG.nbchan]);
        end
        temperiod = str2num(Eegtab_EEG_art_det_epoch.periods_edit.String);
        if isempty(temperiod) || numel(temperiod)~=2
            temperiod = [roundn(observe_EEGDAT.EEG.times(1),-1),roundn(observe_EEGDAT.EEG.times(end),-1)];
            Eegtab_EEG_art_det_epoch.periods_edit.String = num2str(temperiod);
        end
        if Source.Value==1
            Eegtab_EEG_art_det_epoch.periods_editext.String='Test period [ms] (start end)';
            Eegtab_EEG_art_det_epoch.voltage_text.String = 'Voltage limits[uV] (e.g., -100 100)';
            set(Eegtab_EEG_art_det_epoch.voltage_title,'Sizes',[100,-1]);
            VoltageValue = str2num(Eegtab_EEG_art_det_epoch.voltage_edit.String);
            if isempty(VoltageValue) || numel(VoltageValue)~=2
                Eegtab_EEG_art_det_epoch.voltage_edit.String = '-100 100';
            end
            Eegtab_EEG_art_det_epoch.movewindow_edit.Enable ='off';
            Eegtab_EEG_art_det_epoch.windowstep_edit.Enable ='off';
            Eegtab_EEG_art_det_epoch.movewindow_text.String='';
            Eegtab_EEG_art_det_epoch.windowstep_text.String='';
            Eegtab_EEG_art_det_epoch.movewindow_edit.String = '';
            Eegtab_EEG_art_det_epoch.windowstep_edit.String = '';
        elseif Source.Value==2%%peak-to-peak
            Eegtab_EEG_art_det_epoch.voltage_text.String = 'Threshold [uV] (e.g., 100)';
            set(Eegtab_EEG_art_det_epoch.voltage_title,'Sizes',[100,-1]);
            Eegtab_EEG_art_det_epoch.movewindow_edit.Enable ='on';
            Eegtab_EEG_art_det_epoch.windowstep_edit.Enable ='on';
            Eegtab_EEG_art_det_epoch.movewindow_text.String='Move window width [ms]';
            VoltageValue = str2num(Eegtab_EEG_art_det_epoch.voltage_edit.String);
            if isempty(VoltageValue) || numel(VoltageValue)~=1
                Eegtab_EEG_art_det_epoch.voltage_edit.String = '100';
            end
            windowlength = str2num(Eegtab_EEG_art_det_epoch.movewindow_edit.String);%%moving window
            if isempty(windowlength) || numel(windowlength)~=1
                Eegtab_EEG_art_det_epoch.movewindow_edit.String = '200';
            end
            windwostep = str2num(Eegtab_EEG_art_det_epoch.windowstep_edit.String);
            Eegtab_EEG_art_det_epoch.windowstep_text.String='Window step [ms]';
            if isempty(windwostep) || numel(windwostep)~=1
                Eegtab_EEG_art_det_epoch.windowstep_edit.String = '100';
            end
        elseif Source.Value==3
            Eegtab_EEG_art_det_epoch.voltage_text.String = 'Threshold [uV] (e.g., 100)';
            set(Eegtab_EEG_art_det_epoch.voltage_title,'Sizes',[100,-1]);
            Eegtab_EEG_art_det_epoch.movewindow_edit.Enable ='on';
            Eegtab_EEG_art_det_epoch.windowstep_edit.Enable ='on';
            Eegtab_EEG_art_det_epoch.movewindow_text.String='Move window width [ms]';
            VoltageValue = str2num(Eegtab_EEG_art_det_epoch.voltage_edit.String);
            if isempty(VoltageValue) || numel(VoltageValue)~=1
                Eegtab_EEG_art_det_epoch.voltage_edit.String = '100';
            end
            windowlength = str2num(Eegtab_EEG_art_det_epoch.movewindow_edit.String);%%moving window
            if isempty(windowlength) || numel(windowlength)~=1
                Eegtab_EEG_art_det_epoch.movewindow_edit.String = '200';
            end
            windwostep = str2num(Eegtab_EEG_art_det_epoch.windowstep_edit.String);
            if isempty(windwostep) || numel(windwostep)~=1
                Eegtab_EEG_art_det_epoch.windowstep_edit.String = '50';
            end
            Eegtab_EEG_art_det_epoch.windowstep_text.String='Window step [ms]';
        elseif Source.Value==4
            
            Eegtab_EEG_art_det_epoch.voltage_text.String = 'Threshold [uV] (e.g., 100)';
            set(Eegtab_EEG_art_det_epoch.voltage_title,'Sizes',[100,-1]);
            Eegtab_EEG_art_det_epoch.movewindow_edit.Enable ='off';
            Eegtab_EEG_art_det_epoch.windowstep_edit.Enable ='off';
            VoltageValue = str2num(Eegtab_EEG_art_det_epoch.voltage_edit.String);
            if isempty(VoltageValue) || numel(VoltageValue)~=1
                Eegtab_EEG_art_det_epoch.voltage_edit.String = '30';
            end
            Eegtab_EEG_art_det_epoch.movewindow_text.String='';
            Eegtab_EEG_art_det_epoch.windowstep_text.String='';
            Eegtab_EEG_art_det_epoch.movewindow_edit.String = '';
            Eegtab_EEG_art_det_epoch.windowstep_edit.String = '';
        elseif Source.Value==5
            Eegtab_EEG_art_det_epoch.voltage_text.String = 'Amp. tolerance [uV] (e.g., 2)';
            set(Eegtab_EEG_art_det_epoch.voltage_title,'Sizes',[100,-1]);
            Eegtab_EEG_art_det_epoch.movewindow_edit.Enable ='on';
            Eegtab_EEG_art_det_epoch.windowstep_edit.Enable ='off';
            Eegtab_EEG_art_det_epoch.windowstep_edit.String = '';
            Eegtab_EEG_art_det_epoch.movewindow_text.String = 'Flat line    duration [ms]   ';
            VoltageValue = str2num(Eegtab_EEG_art_det_epoch.voltage_edit.String);
            if isempty(VoltageValue) || numel(VoltageValue)~=1
                Eegtab_EEG_art_det_epoch.voltage_edit.String = '1';
            end
            windowlength = str2num(Eegtab_EEG_art_det_epoch.movewindow_edit.String);%%moving window
            if isempty(windowlength) || numel(windowlength)~=1
                Eegtab_EEG_art_det_epoch.movewindow_edit.String = num2str(floor((observe_EEGDAT.EEG.times(end)-observe_EEGDAT.EEG.times(1))/2));
            end
        end
    end

%%----------------------edit chans-----------------------------------------
    function chan_edit(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_art_det_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_art_det_epoch.detectar_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_epoch',1);
        ChaNum = observe_EEGDAT.EEG.nbchan;
        ChanArray = str2num(Source.String);
        if isempty(ChanArray) || min(ChanArray(:))<=0 || max(ChanArray(:))<=0
            erpworkingmemory('f_EEG_proces_messg','Artifact Detection for Epoched EEG >  Index(es) of chans should be positive number(s)');
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String= vect2colon([1:ChaNum]);
            return;
        end
        
        if min(ChanArray(:))> ChaNum || max(ChanArray(:)) > ChaNum
            erpworkingmemory('f_EEG_proces_messg',['Artifact Detection for Epoched EEG >  Index(es) of chans should be between 1 and ',32,num2str(ChaNum)]);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String= vect2colon([1:ChaNum]);
            return;
        end
    end

%%----------------------------Browse chans---------------------------------
    function chan_browse(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        Eegtab_box_art_det_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_art_det_epoch.detectar_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_epoch',1);
        
        %%-------Browse and select chans that will be interpolated---------
        EEG = observe_EEGDAT.EEG;
        for Numofchan = 1:EEG.nbchan
            try
                listb{Numofchan}= strcat(num2str(Numofchan),'.',EEG.chanlocs(Numofchan).labels);
            catch
                listb{Numofchan}= strcat('Chan:',32,num2str(Numofchan));
            end
        end
        ChanArray = str2num(Eegtab_EEG_art_det_epoch.chan_edit.String);
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
            Eegtab_EEG_art_det_epoch.chan_edit.String  = vect2colon(chan_label_select);
        else
            beep;
            disp('User selected Cancel');
            return
        end
    end

%%------------------Mark flag1---------------------------------------------
    function mflag1(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Value=1;
            Source.Enable= 'off';
            return;
        end
        Source.Value=1;
        Source.Enable= 'off';
    end

%%------------------------Mark flag2---------------------------------------
    function mflag2(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Value=0;
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_art_det_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_art_det_epoch.detectar_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_epoch',1);
        if Source.Value ==1
            Eegtab_EEG_art_det_epoch.mflag(2) = 1;
            Eegtab_EEG_art_det_epoch.mflag2.Value=1;
            Eegtab_EEG_art_det_epoch.mflag3.Value=0;
            Eegtab_EEG_art_det_epoch.mflag4.Value=0;
            Eegtab_EEG_art_det_epoch.mflag5.Value=0;
            Eegtab_EEG_art_det_epoch.mflag6.Value=0;
            Eegtab_EEG_art_det_epoch.mflag7.Value=0;
            Eegtab_EEG_art_det_epoch.mflag8.Value=0;
        else
            Eegtab_EEG_art_det_epoch.mflag(2) = 0;
        end
    end


%%------------------------Mark flag3---------------------------------------
    function mflag3(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Value=0;
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_art_det_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_art_det_epoch.detectar_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_epoch',1);
        if Source.Value ==1
            Eegtab_EEG_art_det_epoch.mflag(3) = 1;
            Eegtab_EEG_art_det_epoch.mflag2.Value=0;
            Eegtab_EEG_art_det_epoch.mflag3.Value=1;
            Eegtab_EEG_art_det_epoch.mflag4.Value=0;
            Eegtab_EEG_art_det_epoch.mflag5.Value=0;
            Eegtab_EEG_art_det_epoch.mflag6.Value=0;
            Eegtab_EEG_art_det_epoch.mflag7.Value=0;
            Eegtab_EEG_art_det_epoch.mflag8.Value=0;
        else
            Eegtab_EEG_art_det_epoch.mflag(3) = 0;
        end
    end


%%------------------------Mark flag4---------------------------------------
    function mflag4(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Value=0;
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_art_det_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_art_det_epoch.detectar_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_epoch',1);
        if Source.Value ==1
            Eegtab_EEG_art_det_epoch.mflag(4) = 1;
            Eegtab_EEG_art_det_epoch.mflag2.Value=0;
            Eegtab_EEG_art_det_epoch.mflag3.Value=0;
            Eegtab_EEG_art_det_epoch.mflag4.Value=1;
            Eegtab_EEG_art_det_epoch.mflag5.Value=0;
            Eegtab_EEG_art_det_epoch.mflag6.Value=0;
            Eegtab_EEG_art_det_epoch.mflag7.Value=0;
            Eegtab_EEG_art_det_epoch.mflag8.Value=0;
        else
            Eegtab_EEG_art_det_epoch.mflag(4) = 0;
        end
    end


%%------------------------Mark flag5---------------------------------------
    function mflag5(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Value=0;
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_art_det_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_art_det_epoch.detectar_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_epoch',1);
        if Source.Value ==1
            Eegtab_EEG_art_det_epoch.mflag(5) = 1;
            Eegtab_EEG_art_det_epoch.mflag2.Value=0;
            Eegtab_EEG_art_det_epoch.mflag3.Value=0;
            Eegtab_EEG_art_det_epoch.mflag4.Value=0;
            Eegtab_EEG_art_det_epoch.mflag5.Value=1;
            Eegtab_EEG_art_det_epoch.mflag6.Value=0;
            Eegtab_EEG_art_det_epoch.mflag7.Value=0;
            Eegtab_EEG_art_det_epoch.mflag8.Value=0;
        else
            Eegtab_EEG_art_det_epoch.mflag(5) = 0;
        end
    end


%%------------------------Mark flag6---------------------------------------
    function mflag6(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Value=0;
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_art_det_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_art_det_epoch.detectar_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_epoch',1);
        if Source.Value ==1
            Eegtab_EEG_art_det_epoch.mflag(6) = 1;
            Eegtab_EEG_art_det_epoch.mflag2.Value=0;
            Eegtab_EEG_art_det_epoch.mflag3.Value=0;
            Eegtab_EEG_art_det_epoch.mflag4.Value=0;
            Eegtab_EEG_art_det_epoch.mflag5.Value=0;
            Eegtab_EEG_art_det_epoch.mflag6.Value=1;
            Eegtab_EEG_art_det_epoch.mflag7.Value=0;
            Eegtab_EEG_art_det_epoch.mflag8.Value=0;
        else
            Eegtab_EEG_art_det_epoch.mflag(6) = 0;
        end
    end


%%------------------------Mark flag7---------------------------------------
    function mflag7(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Value=0;
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_art_det_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_art_det_epoch.detectar_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_epoch',1);
        if Source.Value ==1
            Eegtab_EEG_art_det_epoch.mflag(7) = 1;
            Eegtab_EEG_art_det_epoch.mflag2.Value=0;
            Eegtab_EEG_art_det_epoch.mflag3.Value=0;
            Eegtab_EEG_art_det_epoch.mflag4.Value=0;
            Eegtab_EEG_art_det_epoch.mflag5.Value=0;
            Eegtab_EEG_art_det_epoch.mflag6.Value=0;
            Eegtab_EEG_art_det_epoch.mflag7.Value=1;
            Eegtab_EEG_art_det_epoch.mflag8.Value=0;
        else
            Eegtab_EEG_art_det_epoch.mflag(7) = 0;
        end
    end

%%------------------------Mark flag8---------------------------------------
    function mflag8(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Value=0;
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_art_det_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_art_det_epoch.detectar_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_epoch',1);
        if Source.Value ==1
            Eegtab_EEG_art_det_epoch.mflag(8) = 1;
            Eegtab_EEG_art_det_epoch.mflag2.Value=0;
            Eegtab_EEG_art_det_epoch.mflag3.Value=0;
            Eegtab_EEG_art_det_epoch.mflag4.Value=0;
            Eegtab_EEG_art_det_epoch.mflag5.Value=0;
            Eegtab_EEG_art_det_epoch.mflag6.Value=0;
            Eegtab_EEG_art_det_epoch.mflag7.Value=0;
            Eegtab_EEG_art_det_epoch.mflag8.Value=1;
        else
            Eegtab_EEG_art_det_epoch.mflag(8) = 0;
        end
    end


%%-------------------------test period-------------------------------------
    function periods_edit(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_art_det_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_art_det_epoch.detectar_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_epoch',1);
        TimeRangedef = [observe_EEGDAT.EEG.times(1),observe_EEGDAT.EEG.times(end)];
        TimeRange = str2num(Source.String);
        if isempty(TimeRange) || numel(TimeRange)~=2
            erpworkingmemory('f_EEG_proces_messg',['Artifact Detection for Epoched EEG >  Test period should be two numbers']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String= num2str(TimeRangedef);
            return;
        end
        if TimeRange(1)<TimeRangedef(1) || TimeRange(2)>TimeRangedef(2) || TimeRange(2)<TimeRangedef(1) || TimeRange(1)>TimeRangedef(2)
            erpworkingmemory('f_EEG_proces_messg',['Artifact Detection for Epoched EEG >  Test period should be between',32,num2str(TimeRangedef(1)),32,'and',32,num2str(TimeRangedef(2))]);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String= num2str(TimeRangedef);
            return;
        end
        if TimeRange(2) < TimeRange(1)
            Source.String = num2str(sort(TimeRange));
        end
    end

%%-----------------------------volatge-------------------------------------
    function voltage_edit(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_art_det_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_art_det_epoch.detectar_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_epoch',1);
        Voltagevalue= str2num(Source.String);
        AlgorithmFlag=  Eegtab_EEG_art_det_epoch.det_algo.Value;
        errorMessage = '';
        if AlgorithmFlag==1
            if isempty(Voltagevalue) || numel(Voltagevalue)~=2
                errorMessage= ['Artifact Detection for Epoched EEG >  Voltage limits should have two numbers'];
                Source.String = '-100 100';
            else
                Source.String = num2str(sort(Voltagevalue));
            end
        else
            if isempty(Voltagevalue) || numel(Voltagevalue)~=1
                if AlgorithmFlag==2 || AlgorithmFlag==3
                    errorMessage= ['Artifact Detection for Epoched EEG >  Voltage threshold should have one number'];
                    Source.String = '100';
                elseif AlgorithmFlag==4
                    errorMessage= ['Artifact Detection for Epoched EEG >  Voltage threshold should have one number'];
                    Source.String = '30';
                elseif AlgorithmFlag==5
                    errorMessage= ['Artifact Detection for Epoched EEG >  Amplitude tolerance should have one number'];
                    Source.String = '2';
                end
            end
        end
        if ~isempty(errorMessage)
            erpworkingmemory('f_EEG_proces_messg',errorMessage);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            return;
        end
    end


%%------------------------moving window------------------------------------
    function movewindow_edit(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_art_det_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_art_det_epoch.detectar_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_epoch',1);
        windowlength= str2num(Source.String);
        AlgorithmFlag=  Eegtab_EEG_art_det_epoch.det_algo.Value;
        errorMessage = '';
        if isempty(windowlength) || numel(windowlength)~=1
            if AlgorithmFlag==2 || AlgorithmFlag==3
                errorMessage= ['Artifact Detection for Epoched EEG >  Moving window full width should have one number'];
                Source.String = '200';
            elseif AlgorithmFlag==5
                errorMessage= ['Artifact Detection for Epoched EEG >  Duration should have one number'];
                Source.String = num2str(floor((observe_EEGDAT.EEG.times(end)-observe_EEGDAT.EEG.times(1))/2));
            end
        end
        if AlgorithmFlag==5 && min(windowlength(:))<=0
            errorMessage= ['Artifact Detection for Epoched EEG >  Duration should be a positive number'];
            Source.String = num2str(floor((observe_EEGDAT.EEG.times(end)-observe_EEGDAT.EEG.times(1))/2));
        elseif min(windowlength(:))<=0
            errorMessage= ['Artifact Detection for Epoched EEG >  Moving window full width should be a positive number'];
            Source.String = '200';
        end
        if ~isempty(errorMessage)
            erpworkingmemory('f_EEG_proces_messg',errorMessage);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            return;
        end
    end


%%-------------------------moving step-------------------------------------
    function windowstep_edit(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_art_det_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_art_det_epoch.detectar_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_art_det_epoch.detectar_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_detect_arts_epoch',1);
        windowstep= str2num(Source.String);
        AlgorithmFlag=  Eegtab_EEG_art_det_epoch.det_algo.Value;
        
        errorMessage = '';
        if isempty(windowstep) || numel(windowstep)~=1
            if AlgorithmFlag==2 || AlgorithmFlag==3
                errorMessage= ['Artifact Detection for Epoched EEG >  Moving step should have one number'];
                Source.String = '100';
            end
        end
        if min(windowstep(:))< 1/observe_EEGDAT.EEG.srate
            errorMessage= ['Artifact Detection for Epoched EEG >  Moving step should be equal to the sampling period (1/fs msec)'];
            if AlgorithmFlag==2
                Source.String = '100';
            else
                Source.String = '50';
            end
        end
        if ~isempty(errorMessage)
            erpworkingmemory('f_EEG_proces_messg',errorMessage);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            return;
        end
    end


%%%----------------------Cancel------------------------------------
    function detectar_cancel(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','Artifact Detection for Epoched EEG > Cancel');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        %%--------Selected EEGsets-----------
        EEGArray= estudioworkingmemory('EEGArray');
        if numel(EEGArray)~=1
            erpworkingmemory('f_EEG_proces_messg','Artifact Detection for Epoched EEG > Cancel: Only work for single EEG');
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String = 'Only for single EEG';
            Source.Enable = 'off';
            return;
        end
        Eegtab_box_art_det_epoch.TitleColor= [0.0500    0.2500    0.5000];
        Eegtab_EEG_art_det_epoch.detectar_cancel.BackgroundColor =  [1 1 1];
        Eegtab_EEG_art_det_epoch.detectar_cancel.ForegroundColor = [0 0 0];
        Eegtab_EEG_art_det_epoch.detectar_run.BackgroundColor =  [ 1 1 1];
        Eegtab_EEG_art_det_epoch.detectar_run.ForegroundColor = [0 0 0];
        estudioworkingmemory('EEGTab_detect_arts_epoch',0);
        Eegtab_EEG_art_det_epoch.det_algo.Value = Eegtab_EEG_art_det_epoch.Paras{1};
        Eegtab_EEG_art_det_epoch.chan_edit.String = vect2colon(Eegtab_EEG_art_det_epoch.Paras{2});
        Eegtab_EEG_art_det_epoch.mflag=Eegtab_EEG_art_det_epoch.Paras{3};
        Eegtab_EEG_art_det_epoch.mflag1.Value=1;
        Eegtab_EEG_art_det_epoch.mflag2.Value=0;
        Eegtab_EEG_art_det_epoch.mflag3.Value=0;
        Eegtab_EEG_art_det_epoch.mflag4.Value=0;
        Eegtab_EEG_art_det_epoch.mflag5.Value=0;
        Eegtab_EEG_art_det_epoch.mflag6.Value=0;
        Eegtab_EEG_art_det_epoch.mflag7.Value=0;
        Eegtab_EEG_art_det_epoch.mflag8.Value=0;
        if Eegtab_EEG_art_det_epoch.mflag(2)==1
            Eegtab_EEG_art_det_epoch.mflag2.Value=1;
        elseif Eegtab_EEG_art_det_epoch.mflag(3)==1
            Eegtab_EEG_art_det_epoch.mflag3.Value=1;
        elseif Eegtab_EEG_art_det_epoch.mflag(4)==1
            Eegtab_EEG_art_det_epoch.mflag4.Value=1;
        elseif Eegtab_EEG_art_det_epoch.mflag(5)==1
            Eegtab_EEG_art_det_epoch.mflag5.Value=1;
        elseif Eegtab_EEG_art_det_epoch.mflag(6)==1
            Eegtab_EEG_art_det_epoch.mflag6.Value=1;
        elseif Eegtab_EEG_art_det_epoch.mflag(7)==1
            Eegtab_EEG_art_det_epoch.mflag7.Value=1;
        elseif Eegtab_EEG_art_det_epoch.mflag(8)==1
            Eegtab_EEG_art_det_epoch.mflag8.Value=1;
        end
        Eegtab_EEG_art_det_epoch.periods_edit.String = num2str(Eegtab_EEG_art_det_epoch.Paras{4});
        Eegtab_EEG_art_det_epoch.voltage_edit.String = num2str(Eegtab_EEG_art_det_epoch.Paras{5});
        Eegtab_EEG_art_det_epoch.movewindow_edit.String = num2str(Eegtab_EEG_art_det_epoch.Paras{6});
        Eegtab_EEG_art_det_epoch.windowstep_edit.String = num2str(Eegtab_EEG_art_det_epoch.Paras{7});
        
        if Eegtab_EEG_art_det_epoch.det_algo.Value==1
            Eegtab_EEG_art_det_epoch.periods_editext.String='Test period [ms] (start end)';
            Eegtab_EEG_art_det_epoch.voltage_text.String = 'Voltage limits[uV] (e.g., -100 100)';
            set(Eegtab_EEG_art_det_epoch.voltage_title,'Sizes',[100,-1]);
            VoltageValue = str2num(Eegtab_EEG_art_det_epoch.voltage_edit.String);
            if isempty(VoltageValue) || numel(VoltageValue)~=2
                Eegtab_EEG_art_det_epoch.voltage_edit.String = '-100 100';
            end
            Eegtab_EEG_art_det_epoch.movewindow_edit.Enable ='off';
            Eegtab_EEG_art_det_epoch.windowstep_edit.Enable ='off';
            Eegtab_EEG_art_det_epoch.movewindow_text.String='';
            Eegtab_EEG_art_det_epoch.windowstep_text.String='';
            Eegtab_EEG_art_det_epoch.movewindow_edit.String = '';
            Eegtab_EEG_art_det_epoch.windowstep_edit.String = '';
        elseif Eegtab_EEG_art_det_epoch.det_algo.Value==2%%peak-to-peak
            Eegtab_EEG_art_det_epoch.voltage_text.String = 'Threshold [uV] (e.g., 100)';
            set(Eegtab_EEG_art_det_epoch.voltage_title,'Sizes',[100,-1]);
            Eegtab_EEG_art_det_epoch.movewindow_edit.Enable ='on';
            Eegtab_EEG_art_det_epoch.windowstep_edit.Enable ='on';
            Eegtab_EEG_art_det_epoch.movewindow_text.String='Move window width [ms]';
            VoltageValue = str2num(Eegtab_EEG_art_det_epoch.voltage_edit.String);
            if isempty(VoltageValue) || numel(VoltageValue)~=1
                Eegtab_EEG_art_det_epoch.voltage_edit.String = '100';
            end
            windowlength = str2num(Eegtab_EEG_art_det_epoch.movewindow_edit.String);%%moving window
            if isempty(windowlength) || numel(windowlength)~=1
                Eegtab_EEG_art_det_epoch.movewindow_edit.String = '200';
            end
            windwostep = str2num(Eegtab_EEG_art_det_epoch.windowstep_edit.String);
            Eegtab_EEG_art_det_epoch.windowstep_text.String='Window step [ms]';
            if isempty(windwostep) || numel(windwostep)~=1
                Eegtab_EEG_art_det_epoch.windowstep_edit.String = '100';
            end
        elseif Eegtab_EEG_art_det_epoch.det_algo.Value==3
            Eegtab_EEG_art_det_epoch.voltage_text.String = 'Threshold [uV] (e.g., 100)';
            set(Eegtab_EEG_art_det_epoch.voltage_title,'Sizes',[100,-1]);
            Eegtab_EEG_art_det_epoch.movewindow_edit.Enable ='on';
            Eegtab_EEG_art_det_epoch.windowstep_edit.Enable ='on';
            Eegtab_EEG_art_det_epoch.movewindow_text.String='Move window width [ms]';
            VoltageValue = str2num(Eegtab_EEG_art_det_epoch.voltage_edit.String);
            if isempty(VoltageValue) || numel(VoltageValue)~=1
                Eegtab_EEG_art_det_epoch.voltage_edit.String = '100';
            end
            windowlength = str2num(Eegtab_EEG_art_det_epoch.movewindow_edit.String);%%moving window
            if isempty(windowlength) || numel(windowlength)~=1
                Eegtab_EEG_art_det_epoch.movewindow_edit.String = '200';
            end
            windwostep = str2num(Eegtab_EEG_art_det_epoch.windowstep_edit.String);
            if isempty(windwostep) || numel(windwostep)~=1
                Eegtab_EEG_art_det_epoch.windowstep_edit.String = '50';
            end
            Eegtab_EEG_art_det_epoch.windowstep_text.String='Window step [ms]';
        elseif Eegtab_EEG_art_det_epoch.det_algo.Value==4
            
            Eegtab_EEG_art_det_epoch.voltage_text.String = 'Threshold [uV] (e.g., 100)';
            set(Eegtab_EEG_art_det_epoch.voltage_title,'Sizes',[100,-1]);
            Eegtab_EEG_art_det_epoch.movewindow_edit.Enable ='off';
            Eegtab_EEG_art_det_epoch.windowstep_edit.Enable ='off';
            VoltageValue = str2num(Eegtab_EEG_art_det_epoch.voltage_edit.String);
            if isempty(VoltageValue) || numel(VoltageValue)~=1
                Eegtab_EEG_art_det_epoch.voltage_edit.String = '30';
            end
            Eegtab_EEG_art_det_epoch.movewindow_text.String='';
            Eegtab_EEG_art_det_epoch.windowstep_text.String='';
            Eegtab_EEG_art_det_epoch.movewindow_edit.String = '';
            Eegtab_EEG_art_det_epoch.windowstep_edit.String = '';
        elseif Eegtab_EEG_art_det_epoch.det_algo.Value==5
            Eegtab_EEG_art_det_epoch.voltage_text.String = 'Amp. tolerance [uV] (e.g., 2)';
            set(Eegtab_EEG_art_det_epoch.voltage_title,'Sizes',[100,-1]);
            Eegtab_EEG_art_det_epoch.movewindow_edit.Enable ='on';
            Eegtab_EEG_art_det_epoch.windowstep_edit.Enable ='off';
            Eegtab_EEG_art_det_epoch.windowstep_edit.String = '';
            Eegtab_EEG_art_det_epoch.movewindow_text.String = 'Flat line    duration [ms]   ';
            VoltageValue = str2num(Eegtab_EEG_art_det_epoch.voltage_edit.String);
            if isempty(VoltageValue) || numel(VoltageValue)~=1
                Eegtab_EEG_art_det_epoch.voltage_edit.String = '1';
            end
            windowlength = str2num(Eegtab_EEG_art_det_epoch.movewindow_edit.String);%%moving window
            if isempty(windowlength) || numel(windowlength)~=1
                Eegtab_EEG_art_det_epoch.movewindow_edit.String = num2str(floor((observe_EEGDAT.EEG.times(end)-observe_EEGDAT.EEG.times(1))/2));
            end
        end
        Eegtab_EEG_art_det_epoch.Paras{1} = Eegtab_EEG_art_det_epoch.det_algo.Value;
        Eegtab_EEG_art_det_epoch.Paras{2} = str2num(Eegtab_EEG_art_det_epoch.chan_edit.String);
        %         Eegtab_EEG_art_det_epoch.Paras{3} = Eegtab_EEG_art_det_epoch.mflag;
        Eegtab_EEG_art_det_epoch.Paras{4} = str2num(Eegtab_EEG_art_det_epoch.periods_edit.String);
        Eegtab_EEG_art_det_epoch.Paras{5} = str2num(Eegtab_EEG_art_det_epoch.voltage_edit.String);
        Eegtab_EEG_art_det_epoch.Paras{6} = str2num(Eegtab_EEG_art_det_epoch.movewindow_edit.String);
        Eegtab_EEG_art_det_epoch.Paras{7} = str2num(Eegtab_EEG_art_det_epoch.windowstep_edit.String);
        observe_EEGDAT.eeg_panel_message =2; %%Marking for the procedure has been started.
    end


%%-----------------------Finalize------------------------------------------
    function detectar_run(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','Artifact Detection for Epoched EEG > Finalize');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        Eegtab_box_art_det_epoch.TitleColor= [0.0500    0.2500    0.5000];
        Eegtab_EEG_art_det_epoch.detectar_cancel.BackgroundColor =  [1 1 1];
        Eegtab_EEG_art_det_epoch.detectar_cancel.ForegroundColor = [0 0 0];
        Eegtab_EEG_art_det_epoch.detectar_run.BackgroundColor =  [ 1 1 1];
        Eegtab_EEG_art_det_epoch.detectar_run.ForegroundColor = [0 0 0];
        estudioworkingmemory('EEGTab_detect_arts_epoch',0);
        %%--------Selected EEGsets-----------
        EEGArray= estudioworkingmemory('EEGArray');
        if isempty(EEGArray) || min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) || max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG)
            EEGArray = observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',EEGArray);
        end
        
        %%Algorithm that uses to detect artifacts
        try
            AlgFlag = Eegtab_EEG_art_det_epoch.det_algo.Value;
        catch
            AlgFlag = 1;
        end
        
        %%chans
        ChanArray = str2num(Eegtab_EEG_art_det_epoch.chan_edit.String);
        nbchan = observe_EEGDAT.EEG.nbchan;
        if isempty(ChanArray) || min(ChanArray(:)) <=0 || max(ChanArray(:)) <=0 || min(ChanArray(:)) > nbchan || max(ChanArray(:)) > nbchan
            erpworkingmemory('f_EEG_proces_messg',['Artifact Detection for Epoched EEG > Finalize: Chans are empty or index(es) are not between 1 and',32,num2str(nbchan)]);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            return;
        end
        %%flags for marking artifacts
        [~,Flagmarks] = find(Eegtab_EEG_art_det_epoch.mflag==1);
        
        epochStart = roundn(observe_EEGDAT.EEG.times(1),-1); epochEnd = roundn(observe_EEGDAT.EEG.times(end),-1);
        %%test time period
        Testperiod = str2num(Eegtab_EEG_art_det_epoch.periods_edit.String);
        if isempty(Testperiod) || numel(Testperiod)~=2
            erpworkingmemory('f_EEG_proces_messg',['Artifact Detection for Epoched EEG > Finalize: Time perid should have two numbers']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            return;
        end
        
        if Testperiod(1) < epochStart || Testperiod(2) > epochEnd || Testperiod(1) > epochEnd || Testperiod(2) < epochStart
            erpworkingmemory('f_EEG_proces_messg',['Artifact Detection for Epoched EEG > Finalize: Time perid should should be between',32,num2str(epochStart),32,'and',32,numstr(epochEnd)]);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            return;
        end
        Det_algostr = {'Simple voltage threshold','Moving window peak-to-peak threshold',...
            'Step-like artifacts','Sample to sample voltage threshold',...
            'Blocking & flat line'};
        %%----------if simple voltage threshold------------
        Volthreshold = sort(str2num(Eegtab_EEG_art_det_epoch.voltage_edit.String));
        if AlgFlag==1
            if isempty(Volthreshold) ||  numel(Volthreshold)~=2
                erpworkingmemory('f_EEG_proces_messg',['Artifact Detection for Epoched EEG > Finalize: Voltage limits should have two numbers for "simple voltage threshold"']);
                observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
                return;
            end
        else
            erroMessage = '';
            if AlgFlag==5
                if isempty(Volthreshold) ||  numel(Volthreshold)~=1
                    erroMessage=  ['Artifact Detection for Epoched EEG > Finalize: Amplitude tolerance only has one number for "Blocking & flat line"'];
                end
            else
                if isempty(Volthreshold) ||  numel(Volthreshold)~=1
                    erroMessage=  ['Artifact Detection for Epoched EEG > Finalize: Voltage threshold only has one number for "',Det_algostr{AlgFlag},'"'];
                end
            end
            if ~isempty(erroMessage)
                erpworkingmemory('f_EEG_proces_messg',erroMessage);
                observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
                return;
            end
        end
        
        %
        %%Moving window full width
        WindowLength = str2num(Eegtab_EEG_art_det_epoch.movewindow_edit.String);
        erroMessage= '';
        if AlgFlag==5
            if isempty(WindowLength)|| min(WindowLength(:))<=0
                erroMessage=['Artifact Detection for Epoched EEG > Finalize: Duration should be a positive number for "Blocking & flat line"'];
            end
            if max(WindowLength(:)) > epochEnd-epochStart
                erroMessage=['Artifact Detection for Epoched EEG > Finalize: Duration cannot be greater than epoch size for "Blocking & flat line"'];
            end
        elseif AlgFlag==2 || AlgFlag==3
            erroMessage= '';
            if isempty(WindowLength)|| min(WindowLength(:))<2
                erroMessage=['Artifact Detection for Epoched EEG > Finalize: Moving window should be greater than 2 for "',Det_algostr{AlgFlag},'"'];
            end
            if max(WindowLength(:)) > epochEnd-epochStart
                erroMessage=['Artifact Detection for Epoched EEG > Finalize: Moving window should be greater than 2 for "',Det_algostr{AlgFlag},'"'];
            end
        end
        if ~isempty(erroMessage)
            erpworkingmemory('f_EEG_proces_messg',erroMessage);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            return;
        end
        
        %%WindowStep
        WindowStep = str2num(Eegtab_EEG_art_det_epoch.windowstep_edit.String);
        stepnts  = floor(WindowStep*observe_EEGDAT.EEG.srate/1000);
        if AlgFlag==2 || AlgFlag==3
            if isempty(stepnts) ||  stepnts<1
                erroMessage= ['Artifact Detection for Epoched EEG > Finalize: The minimun window step value should be equal to the sampling period (1/fs msec) for "',Det_algostr{AlgFlag},'"'];
                erpworkingmemory('f_EEG_proces_messg',erroMessage);
                observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
                return;
            end
        end
        
        %         try
        ALLEEG = observe_EEGDAT.ALLEEG;
        Answer = f_EEG_save_multi_file(ALLEEG,EEGArray,'_ar');
        if isempty(Answer)
            beep;
            disp('User selected Cancel');
            return;
        end
        if ~isempty(Answer{1})
            ALLEEG_advance = Answer{1};
            Save_file_label = Answer{2};
        end
        
        
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG_advance(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Artifact Detection for Epoched EEG > Finalize*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Artifact detection algorithm:',32,Det_algostr{AlgFlag},'\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            
            if AlgFlag==1
                [EEG, LASTCOM]  = pop_artextval( EEG , 'Channel',  ChanArray, 'Flag', Flagmarks,...
                    'LowPass',  -1, 'Threshold', Volthreshold, 'Twindow',Testperiod ,'Review', 'off', 'History', 'implicit');
            elseif  AlgFlag==2
                [EEG, LASTCOM]  = pop_artmwppth( EEG , 'Channel',  ChanArray, 'Flag', Flagmarks,...
                    'LowPass',  -1, 'Threshold',  Volthreshold, 'Twindow', Testperiod, 'Windowsize',  WindowLength,...
                    'Windowstep',  WindowStep,'Review', 'off', 'History', 'implicit');
            elseif AlgFlag==3
                [EEG, LASTCOM]  = pop_artstep(  EEG  , 'Channel',  ChanArray, 'Flag',  Flagmarks, 'LowPass',  -1,...
                    'Threshold',  Volthreshold,'Twindow', Testperiod, 'Windowsize',  WindowLength,...
                    'Windowstep', WindowStep ,'Review', 'off', 'History', 'implicit');
            elseif AlgFlag==4
                [EEG, LASTCOM]  = pop_artdiff(  EEG , 'Channel', ChanArray, 'Flag', Flagmarks, 'LowPass',  -1,...
                    'Threshold',  Volthreshold, 'Twindow',Testperiod,'Review', 'off', 'History', 'implicit' );
            elseif AlgFlag==5
                [EEG, LASTCOM]  = pop_artflatline( EEG  , 'Channel',  ChanArray, 'Duration', WindowLength, 'Flag', Flagmarks,...
                    'LowPass',  -1, 'Threshold', Volthreshold, 'Twindow',Testperiod ,'Review', 'off', 'History', 'implicit');
            end
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
        
        if Eegtab_EEG_art_det_epoch.mflag2.Value==2
            Eegtab_EEG_art_det_epoch.mflag= [1,1,0,0,0,0,0,0];
        elseif Eegtab_EEG_art_det_epoch.mflag3.Value==1
            Eegtab_EEG_art_det_epoch.mflag= [1,0,1,0,0,0,0,0];
        elseif Eegtab_EEG_art_det_epoch.mflag4.Value==1
            Eegtab_EEG_art_det_epoch.mflag= [1,0,0,1,0,0,0,0];
        elseif Eegtab_EEG_art_det_epoch.mflag5.Value==1
            Eegtab_EEG_art_det_epoch.mflag= [1,0,0,0,1,0,0,0];
        elseif Eegtab_EEG_art_det_epoch.mflag6.Value==1
            Eegtab_EEG_art_det_epoch.mflag= [1,0,0,0,0,1,0,0];
        elseif Eegtab_EEG_art_det_epoch.mflag7.Value==1
            Eegtab_EEG_art_det_epoch.mflag= [1,0,0,0,0,0,1,0];
        elseif Eegtab_EEG_art_det_epoch.mflag8.Value==1
            Eegtab_EEG_art_det_epoch.mflag= [1,0,0,0,0,0,0,1];
        else
            Eegtab_EEG_art_det_epoch.mflag= [1,0,0,0,0,0,0,0];
        end
        Eegtab_EEG_art_det_epoch.Paras{1} = Eegtab_EEG_art_det_epoch.det_algo.Value;
        Eegtab_EEG_art_det_epoch.Paras{2} = str2num(Eegtab_EEG_art_det_epoch.chan_edit.String);
        Eegtab_EEG_art_det_epoch.Paras{3} = Eegtab_EEG_art_det_epoch.mflag;
        Eegtab_EEG_art_det_epoch.Paras{4} = str2num(Eegtab_EEG_art_det_epoch.periods_edit.String);
        Eegtab_EEG_art_det_epoch.Paras{5} = str2num(Eegtab_EEG_art_det_epoch.voltage_edit.String);
        Eegtab_EEG_art_det_epoch.Paras{6} = str2num(Eegtab_EEG_art_det_epoch.movewindow_edit.String);
        Eegtab_EEG_art_det_epoch.Paras{7} = str2num(Eegtab_EEG_art_det_epoch.windowstep_edit.String);
        observe_EEGDAT.count_current_eeg=1;
        observe_EEGDAT.eeg_panel_message =2;
    end


%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=18
            return;
        end
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Eegtab_EEG_art_det_epoch.det_algo.Enable= 'off';
            Eegtab_EEG_art_det_epoch.chan_edit.Enable= 'off';
            Eegtab_EEG_art_det_epoch.chan_browse.Enable= 'off';
            Eegtab_EEG_art_det_epoch.mflag1.Enable= 'off';
            Eegtab_EEG_art_det_epoch.mflag2.Enable= 'off';
            Eegtab_EEG_art_det_epoch.mflag3.Enable= 'off';
            Eegtab_EEG_art_det_epoch.mflag4.Enable= 'off';
            Eegtab_EEG_art_det_epoch.mflag5.Enable= 'off';
            Eegtab_EEG_art_det_epoch.mflag6.Enable= 'off';
            Eegtab_EEG_art_det_epoch.mflag7.Enable= 'off';
            Eegtab_EEG_art_det_epoch.mflag8.Enable= 'off';
            Eegtab_EEG_art_det_epoch.periods_edit.Enable= 'off';
            Eegtab_EEG_art_det_epoch.voltage_edit.Enable= 'off';
            Eegtab_EEG_art_det_epoch.movewindow_edit.Enable= 'off';
            Eegtab_EEG_art_det_epoch.windowstep_text.Enable= 'off';
            Eegtab_EEG_art_det_epoch.detectar_cancel.Enable= 'off';
            Eegtab_EEG_art_det_epoch.detectar_run.Enable= 'off';
            if ~isempty(observe_EEGDAT.EEG) && observe_EEGDAT.EEG.trials ==1
                Eegtab_box_art_det_epoch.TitleColor= [0.7500    0.7500    0.75000];
            else
                Eegtab_box_art_det_epoch.TitleColor= [0.0500    0.2500    0.5000];
            end
            observe_EEGDAT.count_current_eeg=19;
            return;
        end
        
        Eegtab_box_art_det_epoch.TitleColor= [0.0500    0.2500    0.5000];
        Eegtab_EEG_art_det_epoch.det_algo.Enable= 'on';
        Eegtab_EEG_art_det_epoch.chan_edit.Enable= 'on';
        Eegtab_EEG_art_det_epoch.chan_browse.Enable= 'on';
        Eegtab_EEG_art_det_epoch.mflag1.Enable= 'on';
        Eegtab_EEG_art_det_epoch.mflag2.Enable= 'on';
        Eegtab_EEG_art_det_epoch.mflag3.Enable= 'on';
        Eegtab_EEG_art_det_epoch.mflag4.Enable= 'on';
        Eegtab_EEG_art_det_epoch.mflag5.Enable= 'on';
        Eegtab_EEG_art_det_epoch.mflag6.Enable= 'on';
        Eegtab_EEG_art_det_epoch.mflag7.Enable= 'on';
        Eegtab_EEG_art_det_epoch.mflag8.Enable= 'on';
        Eegtab_EEG_art_det_epoch.periods_edit.Enable= 'on';
        Eegtab_EEG_art_det_epoch.voltage_edit.Enable= 'on';
        Eegtab_EEG_art_det_epoch.movewindow_edit.Enable= 'on';
        Eegtab_EEG_art_det_epoch.windowstep_text.Enable= 'on';
        Eegtab_EEG_art_det_epoch.detectar_cancel.Enable= 'on';
        Eegtab_EEG_art_det_epoch.detectar_run.Enable= 'on';
        
        EEGArray= estudioworkingmemory('EEGArray');
        if numel(EEGArray)~=1
            erpworkingmemory('f_EEG_proces_messg','Artifact Detection for Epoched EEG > Cancel: Only work for single EEG, and we threfore gray it out');
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Eegtab_EEG_art_det_epoch.detectar_cancel.String = 'Only for single EEG';
            Eegtab_EEG_art_det_epoch.detectar_cancel.Enable = 'off';
        else
            Eegtab_EEG_art_det_epoch.detectar_cancel.String = 'Cancel';
            Eegtab_EEG_art_det_epoch.detectar_cancel.Enable = 'on';
        end
        
        chanArray = str2num(Eegtab_EEG_art_det_epoch.chan_edit.String);
        if isempty(chanArray) || min(chanArray(:)) > observe_EEGDAT.EEG.nbchan || max(chanArray(:)) > observe_EEGDAT.EEG.nbchan
            Eegtab_EEG_art_det_epoch.chan_edit.String = vect2colon([1:observe_EEGDAT.EEG.nbchan]);
        end
        
        temperiod = str2num(Eegtab_EEG_art_det_epoch.periods_edit.String);
        if isempty(temperiod) || numel(temperiod)~=2
            temperiod = [roundn(observe_EEGDAT.EEG.times(1),-1),roundn(observe_EEGDAT.EEG.times(end),-1)];
            Eegtab_EEG_art_det_epoch.periods_edit.String = num2str(temperiod);
        end
        algValue =Eegtab_EEG_art_det_epoch.det_algo.Value;
        
        if algValue==1
            Eegtab_EEG_art_det_epoch.periods_editext.String='Test period [ms] (start end)';
            Eegtab_EEG_art_det_epoch.voltage_text.String = 'Voltage limits[uV] (e.g., -100 100)';
            set(Eegtab_EEG_art_det_epoch.voltage_title,'Sizes',[100,-1]);
            VoltageValue = str2num(Eegtab_EEG_art_det_epoch.voltage_edit.String);
            if isempty(VoltageValue) || numel(VoltageValue)~=2
                Eegtab_EEG_art_det_epoch.voltage_edit.String = '-100 100';
            end
            Eegtab_EEG_art_det_epoch.movewindow_edit.Enable ='off';
            Eegtab_EEG_art_det_epoch.windowstep_edit.Enable ='off';
            Eegtab_EEG_art_det_epoch.movewindow_text.String='';
            Eegtab_EEG_art_det_epoch.windowstep_text.String='';
            Eegtab_EEG_art_det_epoch.movewindow_edit.String = '';
            Eegtab_EEG_art_det_epoch.windowstep_edit.String = '';
            Eegtab_EEG_art_det_epoch.movewindow_edit.String = '';
            Eegtab_EEG_art_det_epoch.windowstep_edit.String = '';
        elseif algValue==2%%peak-to-peak
            Eegtab_EEG_art_det_epoch.voltage_text.String = 'Threshold [uV] (e.g., 100)';
            set(Eegtab_EEG_art_det_epoch.voltage_title,'Sizes',[100,-1]);
            Eegtab_EEG_art_det_epoch.movewindow_edit.Enable ='on';
            Eegtab_EEG_art_det_epoch.windowstep_edit.Enable ='on';
            Eegtab_EEG_art_det_epoch.movewindow_text.String='Move window width [ms]';
            VoltageValue = str2num(Eegtab_EEG_art_det_epoch.voltage_edit.String);
            if isempty(VoltageValue) || numel(VoltageValue)~=1
                Eegtab_EEG_art_det_epoch.voltage_edit.String = '100';
            end
            windowlength = str2num(Eegtab_EEG_art_det_epoch.movewindow_edit.String);%%moving window
            if isempty(windowlength) || numel(windowlength)~=1
                Eegtab_EEG_art_det_epoch.movewindow_edit.String = '200';
            end
            windwostep = str2num(Eegtab_EEG_art_det_epoch.windowstep_edit.String);
            Eegtab_EEG_art_det_epoch.windowstep_text.String='Window step [ms]';
            if isempty(windwostep) || numel(windwostep)~=1
                Eegtab_EEG_art_det_epoch.windowstep_edit.String = '100';
            end
        elseif algValue==3
            Eegtab_EEG_art_det_epoch.voltage_text.String = 'Threshold [uV] (e.g., 100)';
            set(Eegtab_EEG_art_det_epoch.voltage_title,'Sizes',[100,-1]);
            Eegtab_EEG_art_det_epoch.movewindow_edit.Enable ='on';
            Eegtab_EEG_art_det_epoch.windowstep_edit.Enable ='on';
            Eegtab_EEG_art_det_epoch.movewindow_text.String='Move window width [ms]';
            VoltageValue = str2num(Eegtab_EEG_art_det_epoch.voltage_edit.String);
            if isempty(VoltageValue) || numel(VoltageValue)~=1
                Eegtab_EEG_art_det_epoch.voltage_edit.String = '100';
            end
            windowlength = str2num(Eegtab_EEG_art_det_epoch.movewindow_edit.String);%%moving window
            if isempty(windowlength) || numel(windowlength)~=1
                Eegtab_EEG_art_det_epoch.movewindow_edit.String = '200';
            end
            windwostep = str2num(Eegtab_EEG_art_det_epoch.windowstep_edit.String);
            if isempty(windwostep) || numel(windwostep)~=1
                Eegtab_EEG_art_det_epoch.windowstep_edit.String = '50';
            end
            Eegtab_EEG_art_det_epoch.windowstep_text.String='Window step [ms]';
        elseif algValue==4
            Eegtab_EEG_art_det_epoch.voltage_text.String = 'Threshold [uV] (e.g., 100)';
            set(Eegtab_EEG_art_det_epoch.voltage_title,'Sizes',[100,-1]);
            Eegtab_EEG_art_det_epoch.movewindow_edit.Enable ='off';
            Eegtab_EEG_art_det_epoch.windowstep_edit.Enable ='off';
            VoltageValue = str2num(Eegtab_EEG_art_det_epoch.voltage_edit.String);
            if isempty(VoltageValue) || numel(VoltageValue)~=1
                Eegtab_EEG_art_det_epoch.voltage_edit.String = '30';
            end
            Eegtab_EEG_art_det_epoch.movewindow_text.String='';
            Eegtab_EEG_art_det_epoch.windowstep_text.String='';
            Eegtab_EEG_art_det_epoch.movewindow_edit.String = '';
            Eegtab_EEG_art_det_epoch.windowstep_edit.String = '';
        elseif algValue==5
            Eegtab_EEG_art_det_epoch.voltage_text.String = 'Amp. tolerance [uV] (e.g., 2)';
            set(Eegtab_EEG_art_det_epoch.voltage_title,'Sizes',[100,-1]);
            Eegtab_EEG_art_det_epoch.movewindow_edit.Enable ='on';
            Eegtab_EEG_art_det_epoch.windowstep_edit.Enable ='off';
            Eegtab_EEG_art_det_epoch.windowstep_edit.String = '';
            Eegtab_EEG_art_det_epoch.movewindow_text.String = 'Flat line    duration [ms]   ';
            VoltageValue = str2num(Eegtab_EEG_art_det_epoch.voltage_edit.String);
            if isempty(VoltageValue) || numel(VoltageValue)~=1
                Eegtab_EEG_art_det_epoch.voltage_edit.String = '1';
            end
            windowlength = str2num(Eegtab_EEG_art_det_epoch.movewindow_edit.String);%%moving window
            if isempty(windowlength) || numel(windowlength)~=1
                Eegtab_EEG_art_det_epoch.movewindow_edit.String = num2str(floor((observe_EEGDAT.EEG.times(end)-observe_EEGDAT.EEG.times(1))/2));
            end
        end
        if Eegtab_EEG_art_det_epoch.mflag2.Value==2
            Eegtab_EEG_art_det_epoch.mflag= [1,1,0,0,0,0,0,0];
        elseif Eegtab_EEG_art_det_epoch.mflag3.Value==1
            Eegtab_EEG_art_det_epoch.mflag= [1,0,1,0,0,0,0,0];
        elseif Eegtab_EEG_art_det_epoch.mflag4.Value==1
            Eegtab_EEG_art_det_epoch.mflag= [1,0,0,1,0,0,0,0];
        elseif Eegtab_EEG_art_det_epoch.mflag5.Value==1
            Eegtab_EEG_art_det_epoch.mflag= [1,0,0,0,1,0,0,0];
        elseif Eegtab_EEG_art_det_epoch.mflag6.Value==1
            Eegtab_EEG_art_det_epoch.mflag= [1,0,0,0,0,1,0,0];
        elseif Eegtab_EEG_art_det_epoch.mflag7.Value==1
            Eegtab_EEG_art_det_epoch.mflag= [1,0,0,0,0,0,1,0];
        elseif Eegtab_EEG_art_det_epoch.mflag8.Value==1
            Eegtab_EEG_art_det_epoch.mflag= [1,0,0,0,0,0,0,1];
        else
            Eegtab_EEG_art_det_epoch.mflag= [1,0,0,0,0,0,0,0];
        end
        
        Eegtab_EEG_art_det_epoch.Paras{1} = Eegtab_EEG_art_det_epoch.det_algo.Value;
        Eegtab_EEG_art_det_epoch.Paras{2} = str2num(Eegtab_EEG_art_det_epoch.chan_edit.String);
        Eegtab_EEG_art_det_epoch.Paras{3} = Eegtab_EEG_art_det_epoch.mflag;
        Eegtab_EEG_art_det_epoch.Paras{4} = str2num(Eegtab_EEG_art_det_epoch.periods_edit.String);
        Eegtab_EEG_art_det_epoch.Paras{5} = str2num(Eegtab_EEG_art_det_epoch.voltage_edit.String);
        Eegtab_EEG_art_det_epoch.Paras{6} = str2num(Eegtab_EEG_art_det_epoch.movewindow_edit.String);
        Eegtab_EEG_art_det_epoch.Paras{7} = str2num(Eegtab_EEG_art_det_epoch.windowstep_edit.String);
        
        Eegtab_EEG_art_det_epoch.mflag1.Enable = 'off';
        observe_EEGDAT.count_current_eeg=19;
    end


%%--------------press return to execute "Apply"----------------------------
    function eeg_artdetect_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('EEGTab_detect_arts_epoch');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            detectar_run();
            estudioworkingmemory('EEGTab_detect_arts_epoch',0);
            Eegtab_box_art_det_epoch.TitleColor= [0.0500    0.2500    0.5000];
            Eegtab_EEG_art_det_epoch.detectar_cancel.BackgroundColor =  [1 1 1];
            Eegtab_EEG_art_det_epoch.detectar_cancel.ForegroundColor = [0 0 0];
            Eegtab_EEG_art_det_epoch.detectar_run.BackgroundColor =  [ 1 1 1];
            Eegtab_EEG_art_det_epoch.detectar_run.ForegroundColor = [0 0 0];
        else
            return;
        end
    end

%%-------------------Auomatically execute "apply"--------------------------
    function eeg_two_panels_change(~,~)
        if  isempty(observe_EEGDAT.EEG)
            return;
        end
        ChangeFlag =  estudioworkingmemory('EEGTab_detect_arts_epoch');
        if ChangeFlag~=1
            return;
        end
        detectar_run();
        estudioworkingmemory('EEGTab_detect_arts_epoch',0);
        Eegtab_box_art_det_epoch.TitleColor= [0.0500    0.2500    0.5000];
        Eegtab_EEG_art_det_epoch.detectar_cancel.BackgroundColor =  [1 1 1];
        Eegtab_EEG_art_det_epoch.detectar_cancel.ForegroundColor = [0 0 0];
        Eegtab_EEG_art_det_epoch.detectar_run.BackgroundColor =  [ 1 1 1];
        Eegtab_EEG_art_det_epoch.detectar_run.ForegroundColor = [0 0 0];
    end

%%--------------Reset this panel with the default parameters---------------
    function Reset_eeg_panel_change(~,~)
        if observe_EEGDAT.Reset_eeg_paras_panel~=16
            return;
        end
        estudioworkingmemory('EEGTab_detect_arts_epoch',0);
%         Eegtab_box_art_det_epoch.TitleColor= [0.0500    0.2500    0.5000];
        Eegtab_EEG_art_det_epoch.detectar_cancel.BackgroundColor =  [1 1 1];
        Eegtab_EEG_art_det_epoch.detectar_cancel.ForegroundColor = [0 0 0];
        Eegtab_EEG_art_det_epoch.detectar_run.BackgroundColor =  [ 1 1 1];
        Eegtab_EEG_art_det_epoch.detectar_run.ForegroundColor = [0 0 0];
        Eegtab_EEG_art_det_epoch.det_algo.Value=1;
        Eegtab_EEG_art_det_epoch.periods_editext.String='Test period [ms] (start end)';
        Eegtab_EEG_art_det_epoch.voltage_text.String = 'Voltage limits[uV] (e.g., -100 100)';
        Eegtab_EEG_art_det_epoch.voltage_edit.String = '-100 100';
        
        Eegtab_EEG_art_det_epoch.movewindow_edit.Enable ='off';
        Eegtab_EEG_art_det_epoch.windowstep_edit.Enable ='off';
        Eegtab_EEG_art_det_epoch.movewindow_text.String='';
        Eegtab_EEG_art_det_epoch.windowstep_text.String='';
        Eegtab_EEG_art_det_epoch.movewindow_edit.String = '';
        Eegtab_EEG_art_det_epoch.windowstep_edit.String = '';
        Eegtab_EEG_art_det_epoch.movewindow_edit.String = '';
        Eegtab_EEG_art_det_epoch.windowstep_edit.String = '';
        Eegtab_EEG_art_det_epoch.mflag2.Value=0;
        Eegtab_EEG_art_det_epoch.mflag3.Value=0;
        Eegtab_EEG_art_det_epoch.mflag4.Value=0;
        Eegtab_EEG_art_det_epoch.mflag5.Value=0;
        Eegtab_EEG_art_det_epoch.mflag6.Value=0;
        Eegtab_EEG_art_det_epoch.mflag7.Value=0;
        Eegtab_EEG_art_det_epoch.mflag8.Value=0;
        Eegtab_EEG_art_det_epoch.mflag= [1,0,0,0,0,0,0,0];
        if isempty(observe_EEGDAT.EEG)
            Eegtab_EEG_art_det_epoch.chan_edit.String = '';
            Eegtab_EEG_art_det_epoch.periods_edit.String = '';
        else
            Eegtab_EEG_art_det_epoch.periods_edit.String = num2str([observe_EEGDAT.EEG.times(1),observe_EEGDAT.EEG.times(end)]);
            Eegtab_EEG_art_det_epoch.chan_edit.String=vect2colon([1:observe_EEGDAT.EEG.nbchan]);
        end
        Eegtab_EEG_art_det_epoch.Paras{1} = Eegtab_EEG_art_det_epoch.det_algo.Value;
        Eegtab_EEG_art_det_epoch.Paras{2} = str2num(Eegtab_EEG_art_det_epoch.chan_edit.String);
        Eegtab_EEG_art_det_epoch.Paras{3} = Eegtab_EEG_art_det_epoch.mflag;
        Eegtab_EEG_art_det_epoch.Paras{4} = str2num(Eegtab_EEG_art_det_epoch.periods_edit.String);
        Eegtab_EEG_art_det_epoch.Paras{5} = str2num(Eegtab_EEG_art_det_epoch.voltage_edit.String);
        Eegtab_EEG_art_det_epoch.Paras{6} = str2num(Eegtab_EEG_art_det_epoch.movewindow_edit.String);
        Eegtab_EEG_art_det_epoch.Paras{7} = str2num(Eegtab_EEG_art_det_epoch.windowstep_edit.String);
        observe_EEGDAT.Reset_eeg_paras_panel=17;
    end
end


%%----------------check if the file already exists-------------------------
function checkfileindex = checkfilexists(filenamex)%%Jan 10 2024
checkfileindex=0;
[pathstr, file_name, ext] = fileparts(filenamex);
filenamex = [pathstr, file_name,'.set'];
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
