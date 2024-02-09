%%This function is to compute Data Quality Metrics from Epoched EEG.


% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Oct. 2023


function varargout = f_EEG_dq_epoch_GUI(varargin)

global observe_EEGDAT;
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
addlistener(observe_EEGDAT,'Reset_eeg_panel_change',@Reset_eeg_panel_change);

%---------------------------Initialize parameters------------------------------------
EEG_dq_epoch = struct();
%-----------------------------Name the title----------------------------------------------

% global Eegtab_box_dq_epoch;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    Eegtab_box_dq_epoch = uiextras.BoxPanel('Parent', fig, 'Title', 'Data Quality Metrics from Epoched EEG',...
        'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    Eegtab_box_dq_epoch = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Data Quality Metrics from Epoched EEG', ...
        'Padding', 5,'BackgroundColor',ColorB_def);
else
    Eegtab_box_dq_epoch = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Data Quality Metrics from Epoched EEG',...
        'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);%, 'HelpFcn', @dq_help
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

drawui_dq_epoch_eeg(FonsizeDefault)
varargout{1} = Eegtab_box_dq_epoch;

    function drawui_dq_epoch_eeg(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        EEG_dq_epoch.DataSelBox = uiextras.VBox('Parent', Eegtab_box_dq_epoch,'BackgroundColor',ColorB_def);
        FontSize_defualt = FonsizeDefault;
        if isempty(FontSize_defualt)
            FontSize_defualt = 12;
        end
        if isempty(observe_EEGDAT.EEG)
            EnableFlag = 'off';
        else
            EnableFlag = 'on';
        end
        def  = erpworkingmemory('pop_DQ_preavg');
        if isempty(def) || numel(def)~=12
            % Should not be empty, and have exactly 12 elements. Else, fallback to:
            def = {1 1 1 1 1 0 0 [] 1 [] 1 0};
        end
        try
            DQcustom_wins = def{12};
        catch
            DQcustom_wins = 0;
        end
        oldDQ =  def{10};
        EEG_dq_epoch.DQ_spec = [];
        if isempty(oldDQ)
            dq_times_def = [1:6;-100:100:400;0:100:500]';
            EEG_dq_epoch.dq_times = dq_times_def;
            EEG_dq_epoch.DQ_spec = [];
        else
            try
                dq_times_def = oldDQ(3).times;
                EEG_dq_epoch.dq_times = dq_times_def;
                EEG_dq_epoch.DQ_spec = oldDQ;
            catch
                dq_times_def = [1:6;-100:100:400;0:100:500]';
                EEG_dq_epoch.dq_times = dq_times_def;
                EEG_dq_epoch.DQ_spec = oldDQ;
            end
        end
        try
            EEG_dq_epoch.DQpreavg_txt =def{11};
        catch
            EEG_dq_epoch.DQpreavg_txt =1;
        end
        
        EEG_dq_epoch.para_title1 = uiextras.HBox('Parent', EEG_dq_epoch.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',EEG_dq_epoch.para_title1,'HorizontalAlignment','center','FontWeight','bold',...
            'String','Data Quality Quatification:','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable','on','BackgroundColor',ColorB_def); % 2F
        %%Default Parameters
        EEG_dq_epoch.para_title2 = uiextras.HBox('Parent', EEG_dq_epoch.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_dq_epoch.def_para = uicontrol('Style','radiobutton','Parent',EEG_dq_epoch.para_title2,'HorizontalAlignment','left',...
            'callback',@def_para,'String','Default parameters','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def); % 2F
        EEG_dq_epoch.def_para.KeyPressFcn=  @eeg_shiftcodes_presskey;
        
        uiextras.Empty('Parent', EEG_dq_epoch.para_title2 ,'BackgroundColor',ColorB_def);
        set(EEG_dq_epoch.para_title2,'Sizes',[150,-1]);
        
        
        %%Custom Parameters
        EEG_dq_epoch.para_title3 = uiextras.HBox('Parent', EEG_dq_epoch.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_dq_epoch.custom_para = uicontrol('Style','radiobutton','Parent',EEG_dq_epoch.para_title3,'HorizontalAlignment','left',...
            'callback',@custom_para,'String','Custom parameters','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def); % 2F
        EEG_dq_epoch.def_para.KeyPressFcn=  @eeg_shiftcodes_presskey;
        
        if DQcustom_wins==0
            EEG_dq_epoch.def_para.Value = 1;
            EEG_dq_epoch.custom_para.Value=0;
        else
            EEG_dq_epoch.def_para.Value = 0;
            EEG_dq_epoch.custom_para.Value=1;
        end
        EEG_dq_epoch.custom_para_op = uicontrol('Style','pushbutton','Parent',EEG_dq_epoch.para_title3,'HorizontalAlignment','left',...
            'callback',@custom_para_op,'String','Options','FontSize',FontSize_defualt,'BackgroundColor',[1 1 1],'Enable',EnableFlag); % 2F
        uiextras.Empty('Parent', EEG_dq_epoch.para_title3 ,'BackgroundColor',ColorB_def);
        set(EEG_dq_epoch.para_title3,'Sizes',[150,60 -1]);
        
        
        try
            artcrite = def{2};
        catch
            artcrite=1;
        end
        if artcrite==0
            Valueround1 = 1;
            Valueround2 =0;
            Valueround3 = 0;
        elseif artcrite==2
            Valueround1 = 0;
            Valueround2 =0;
            Valueround3 = 1;
        else
            Valueround1 = 0;
            Valueround2 = 1;
            Valueround3 = 0;
        end
        %%Round to arlier time sample (recommended)
        EEG_dq_epoch.movewindow_title1 = uiextras.HBox('Parent', EEG_dq_epoch.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',EEG_dq_epoch.movewindow_title1,'HorizontalAlignment','center','FontWeight','bold',...
            'String','Epochs to Include DQ metrics:','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable','on','BackgroundColor',ColorB_def); % 2F
        
        %%all epochs
        EEG_dq_epoch.movewindow_title = uiextras.HBox('Parent', EEG_dq_epoch.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_dq_epoch.all_marks = uicontrol('Style','radiobutton','Parent',EEG_dq_epoch.movewindow_title,'HorizontalAlignment','left',...
            'callback',@all_marks,'String','Include All epochs (ignore artifact detections)','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def); % 2F
        EEG_dq_epoch.all_marks.KeyPressFcn=  @eeg_shiftcodes_presskey;
        uiextras.Empty('Parent', EEG_dq_epoch.movewindow_title ,'BackgroundColor',ColorB_def);
        set(EEG_dq_epoch.movewindow_title,'Sizes',[270,-1]);
        
        %%exclude marked epochs
        EEG_dq_epoch.windowstep_title = uiextras.HBox('Parent', EEG_dq_epoch.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_dq_epoch.excld_marks = uicontrol('Style','radiobutton','Parent',EEG_dq_epoch.windowstep_title,'HorizontalAlignment','left',...
            'callback',@excld_marks,'String','','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def); % 2F
        EEG_dq_epoch.excld_marks.String = '<html>Exclude epochs marked during artifact<br />detection (highly recommended)</html>';
        EEG_dq_epoch.excld_marks.KeyPressFcn=  @eeg_shiftcodes_presskey;
        uiextras.Empty('Parent',EEG_dq_epoch.windowstep_title ,'BackgroundColor',ColorB_def);
        set(EEG_dq_epoch.windowstep_title,'Sizes',[260,-1]);
        
        %%marked epochs
        EEG_dq_epoch.eventcode_title = uiextras.HBox('Parent', EEG_dq_epoch.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_dq_epoch.marked_epochs = uicontrol('Style','radiobutton','Parent',EEG_dq_epoch.eventcode_title,'HorizontalAlignment','left',...
            'callback',@marked_epochs,'String','','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def); % 2F
        EEG_dq_epoch.marked_epochs.String = '<html>Include ONLY epochs marked with artifact<br />detection (by cautious!)</html>';
        uiextras.Empty('Parent', EEG_dq_epoch.eventcode_title );
        set(EEG_dq_epoch.eventcode_title,'Sizes',[260,-1]);
        EEG_dq_epoch.all_marks.Value = Valueround1;
        EEG_dq_epoch.excld_marks.Value = Valueround2;
        EEG_dq_epoch.marked_epochs.Value = Valueround3;
        
        %%-----------------------Cancel and Run----------------------------
        EEG_dq_epoch.detar_run_title = uiextras.HBox('Parent', EEG_dq_epoch.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  EEG_dq_epoch.detar_run_title,'BackgroundColor',ColorB_def);
        EEG_dq_epoch.dq_cancel = uicontrol('Style', 'pushbutton','Parent',EEG_dq_epoch.detar_run_title,...
            'String','Cancel','callback',@dq_cancel,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent',  EEG_dq_epoch.detar_run_title,'BackgroundColor',ColorB_def);
        EEG_dq_epoch.dq_run = uicontrol('Style','pushbutton','Parent',EEG_dq_epoch.detar_run_title,...
            'String','Run','callback',@dq_run,'FontSize',FontSize_defualt,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent',  EEG_dq_epoch.detar_run_title,'BackgroundColor',ColorB_def);
        set(EEG_dq_epoch.detar_run_title,'Sizes',[15 105  30 105 15]);
        
        set(EEG_dq_epoch.DataSelBox,'Sizes',[20 25 25 20 25 30 30 30]);
        estudioworkingmemory('EEGTab_dq_epoch',0);
    end


%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%------------------------------help---------------------------------------
%     function dq_help(~,~)
%         web('https://github.com/ucdavis/erplab/wiki/ERPLAB-Data-Quality-Metrics/','-browser');
%     end


%%--------------------------------default parameters-----------------------
    function def_para(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=16
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_dq_epoch.TitleColor= [0.5137    0.7569    0.9176];
        EEG_dq_epoch.dq_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_dq_epoch.dq_cancel.ForegroundColor = [1 1 1];
        EEG_dq_epoch.dq_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_dq_epoch.dq_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_dq_epoch',1);
        EEG_dq_epoch.def_para.Value=1;
        EEG_dq_epoch.custom_para.Value=0;
        EEG_dq_epoch.custom_para_op.Enable = 'off';
    end

%%-------------------------custom parameters-------------------------------
    function custom_para(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=16
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_dq_epoch.TitleColor= [0.5137    0.7569    0.9176];
        EEG_dq_epoch.dq_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_dq_epoch.dq_cancel.ForegroundColor = [1 1 1];
        EEG_dq_epoch.dq_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_dq_epoch.dq_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_dq_epoch',1);
        EEG_dq_epoch.def_para.Value=0;
        EEG_dq_epoch.custom_para.Value=1;
        EEG_dq_epoch.custom_para_op.Enable = 'on';
    end

%%------------------------Custom define------------------------------------
    function custom_para_op(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=16
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_dq_epoch.TitleColor= [0.5137    0.7569    0.9176];
        EEG_dq_epoch.dq_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_dq_epoch.dq_cancel.ForegroundColor = [1 1 1];
        EEG_dq_epoch.dq_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_dq_epoch.dq_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_dq_epoch',1);
        
        timelimits = 1000 * [observe_EEGDAT.EEG.xmin observe_EEGDAT.EEG.xmax];
        old_DQ_spec = EEG_dq_epoch.DQ_spec;
        custom_DQ_spec = avg_data_quality(old_DQ_spec,timelimits);
        EEG_dq_epoch.timelimits = timelimits;
        if isempty(custom_DQ_spec)
            disp('User cancelled custom DQ window')
            %handles.DQ_spec = [];
        else
            % The DQ Custom window ran successfully, so write the new DQ spec
            EEG_dq_epoch.DQ_spec = custom_DQ_spec;
        end
        
    end

%%---------------------------all epochs------------------------------------
    function all_marks(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=16
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_dq_epoch.TitleColor= [0.5137    0.7569    0.9176];
        EEG_dq_epoch.dq_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_dq_epoch.dq_cancel.ForegroundColor = [1 1 1];
        EEG_dq_epoch.dq_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_dq_epoch.dq_run.ForegroundColor = [1 1 1];
        
        estudioworkingmemory('EEGTab_dq_epoch',1);
        EEG_dq_epoch.all_marks.Value = 1;
        EEG_dq_epoch.excld_marks.Value = 0;
        EEG_dq_epoch.marked_epochs.Value = 0;
    end


%%-------------------------exclude marked epochs---------------------------
    function excld_marks(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=16
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_dq_epoch.TitleColor= [0.5137    0.7569    0.9176];
        EEG_dq_epoch.dq_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_dq_epoch.dq_cancel.ForegroundColor = [1 1 1];
        EEG_dq_epoch.dq_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_dq_epoch.dq_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_dq_epoch',1);
        
        EEG_dq_epoch.all_marks.Value = 0;
        EEG_dq_epoch.excld_marks.Value = 1;
        EEG_dq_epoch.marked_epochs.Value = 0;
    end


%%-------------------------Only marked epochs------------------------------
    function marked_epochs(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=16
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_dq_epoch.TitleColor= [0.5137    0.7569    0.9176];
        EEG_dq_epoch.dq_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_dq_epoch.dq_cancel.ForegroundColor = [1 1 1];
        EEG_dq_epoch.dq_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_dq_epoch.dq_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_dq_epoch',1);
        EEG_dq_epoch.all_marks.Value = 0;
        EEG_dq_epoch.excld_marks.Value = 0;
        EEG_dq_epoch.marked_epochs.Value = 1;
    end


%%%----------------------Preview-------------------------------------------
    function dq_cancel(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=16
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','Data Quality Metrics from Epoched EEG > Cancel');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        Eegtab_box_dq_epoch.TitleColor= [0.0500    0.2500    0.5000];
        EEG_dq_epoch.dq_cancel.BackgroundColor =  [1 1 1];
        EEG_dq_epoch.dq_cancel.ForegroundColor = [0 0 0];
        EEG_dq_epoch.dq_run.BackgroundColor =  [ 1 1 1];
        EEG_dq_epoch.dq_run.ForegroundColor = [0 0 0];
        
        estudioworkingmemory('EEGTab_dq_epoch',0);
        
        def  = erpworkingmemory('pop_DQ_preavg');
        if isempty(def) || numel(def)~=12
            % Should not be empty, and have exactly 12 elements. Else, fallback to:
            def = {1 1 1 1 1 0 0 [] 1 [] 1 0};
        end
        try
            DQcustom_wins = def{12};
        catch
            DQcustom_wins = 0;
        end
        
        if DQcustom_wins==0
            EEG_dq_epoch.def_para.Value = 1;
            EEG_dq_epoch.custom_para.Value=0;
            EEG_dq_epoch.custom_para_op.Enable = 'off';
            EEG_dq_epoch.timelimits = [observe_EEGDAT.EEG.times(1),observe_EEGDAT.EEG.times(end)];
            DQ_defaults = make_DQ_spec([observe_EEGDAT.EEG.times(1),observe_EEGDAT.EEG.times(end)]);
            EEG_dq_epoch.DQ_spec=DQ_defaults;
        else
            EEG_dq_epoch.def_para.Value = 0;
            EEG_dq_epoch.custom_para.Value=1;
            EEG_dq_epoch.custom_para_op.Enable = 'on';
        end
        %%setting for selection of epoch types
        try
            artcrite = def{2};
        catch
            artcrite=1;
        end
        if artcrite==0
            Valueround1 = 1;
            Valueround2 =0;
            Valueround3 = 0;
        elseif artcrite==2
            Valueround1 = 0;
            Valueround2 =0;
            Valueround3 = 1;
        else
            Valueround1 = 0;
            Valueround2 = 1;
            Valueround3 = 0;
        end
        EEG_dq_epoch.all_marks.Value = Valueround1;
        EEG_dq_epoch.excld_marks.Value = Valueround2;
        EEG_dq_epoch.marked_epochs.Value = Valueround3;
        
        observe_EEGDAT.eeg_panel_message =2;
    end


%%-----------------------Shift events--------------------------------------
    function dq_run(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=16
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','Data Quality Metrics from Epoched EEG > Shift events');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        Eegtab_box_dq_epoch.TitleColor= [0.0500    0.2500    0.5000];
        EEG_dq_epoch.dq_cancel.BackgroundColor =  [1 1 1];
        EEG_dq_epoch.dq_cancel.ForegroundColor = [0 0 0];
        EEG_dq_epoch.dq_run.BackgroundColor =  [ 1 1 1];
        EEG_dq_epoch.dq_run.ForegroundColor = [0 0 0];
        
        estudioworkingmemory('EEGTab_dq_epoch',0);
        %%--------Selected EEGsets-----------
        EEGArray= estudioworkingmemory('EEGArray');
        if isempty(EEGArray) || min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) || max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG)
            EEGArray = observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',EEGArray);
        end
        
        
        incALL=EEG_dq_epoch.all_marks.Value;
        excart=EEG_dq_epoch.excld_marks.Value;
        onlyart=EEG_dq_epoch.marked_epochs.Value;
        incart   = 0;
        incIndx  = 0;
        excbound = 1; % exclude epochs having boundary events
        Tspectrum  = 0;   % total power spectrum
        Espectrum  = 0;  % evoked power spectrum
        iswindowed = 0;
        winparam = '';
        compu2do = 0; %do ERP only
        
        if incALL
            artcrite = 0;
            
        elseif excart
            artcrite = 1;
        else
            artcrite = 2;
        end
        try
            DQ_defaults = make_DQ_spec(EEG_dq_epoch.timelimits);
        catch
            EEG_dq_epoch.timelimits = [observe_EEGDAT.EEG.times(1),observe_EEGDAT.EEG.times(end)];
            DQ_defaults = make_DQ_spec([observe_EEGDAT.EEG.times(1),observe_EEGDAT.EEG.times(end)]);
        end
        DQ_defaults(1).comments{1} = 'Defaults';
        
        
        DQ_flag   = max(EEG_dq_epoch.def_para.Value,EEG_dq_epoch.custom_para.Value);
        
        use_defaults = EEG_dq_epoch.def_para.Value;
        if DQ_flag
            stderror = 1;
            if use_defaults || isempty(EEG_dq_epoch.DQ_spec)
                DQ_spec = DQ_defaults;
            else
                DQ_spec = EEG_dq_epoch.DQ_spec;
            end
        else
            stderror = 0;
            DQ_spec = [];
        end
        
        if EEG_dq_epoch.def_para.Value==1
            DQ_customWins = 0;
        else
            DQ_customWins = 1;
        end
        try
            DQ_preavg_txt = EEG_dq_epoch.DQpreavg_txt;
        catch
            DQ_preavg_txt=1;
        end
        wavg = 1;
        
        answer = {EEGArray(1), artcrite, wavg, stderror, excbound, compu2do, iswindowed, winparam,DQ_flag,DQ_spec,DQ_preavg_txt,DQ_customWins};
        
        
        artcrite  = answer{2};
        if ~iscell(artcrite)
            if artcrite==0
                artcritestr = 'all';
            elseif artcrite==1
                artcritestr = 'good';
            elseif artcrite==2
                artcritestr = 'bad';
            else
                artcritestr = artcrite;
            end
        else
            artcritestr = artcrite; % fixed bug. May 1, 2012
        end
        
        stderror    = answer{4};
        
        % exclude epochs having boundary events
        excbound = answer{5};
        
        % Compute ERP, evoked power spectrum (EPS), and total power
        % spectrum (TPS).
        compu2do = answer{6}; % 0:ERP; 1:ERP+TPS; 2:ERP+EPS; 3:ERP+BOTH
        wintype  = answer{7}; % taper data with window: 0:no; 1:yes
        wintfunc = answer{8}; % taper function and (sub)window
        
        % Write the analytic Standardized Measurment Error info
        DQ_flag = answer{9};
        DQ_spec = answer{10};
        DQ_preavg_txt = answer{11};
        DQcustom_wins = answer{12};
        
        answer(1:12)    = {EEGArray(1), artcrite, 1, stderror, excbound, compu2do, wintype, wintfunc,DQ_flag,DQ_spec,DQ_preavg_txt,DQcustom_wins};
        erpworkingmemory('pop_DQ_preavg', answer);
        
        if stderror==1
            stdsstr = 'on';
        else
            stdsstr = 'off';
        end
        if excbound==1
            excboundstr = 'on';
        else
            excboundstr = 'off';
        end
        
        ALLEEG = observe_EEGDAT.ALLEEG;
        try
            for Numofeeg = 1:numel(EEGArray)
                setindex =EEGArray(Numofeeg);
                EEG = ALLEEG(setindex);
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['*Data Quality Metrics from Epoched EEG > Apply*',32,32,32,32,datestr(datetime('now')),'\n']);
                fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
                
                %% Run the pop_ command with the user input from the GUI
                [ERPpreavg, erpcom] = pop_averager(ALLEEG, 'DSindex', setindex, 'Criterion', artcritestr,...
                    'SEM', stdsstr, 'Saveas', 'off', 'Warning', 'off', 'ExcludeBoundary', excboundstr,...
                    'DQ_flag',DQ_flag,'DQ_spec',DQ_spec, 'DQ_preavg_txt', DQ_preavg_txt,'DQ_custom_wins', DQcustom_wins, 'History', '');
                ALLERP = [];
                CURRENTPREAVG = 1;
                ERPpreavg.erpname = ALLEEG(setindex).setname; %setname instead of erpname in DQ Table
                DQ_Table_GUI(ERPpreavg,ALLERP,CURRENTPREAVG,1);
                
                fprintf( ['\n',repmat('-',1,100) '\n']);
            end%%end for loop of subjects
            observe_EEGDAT.eeg_panel_message =2;
        catch
            observe_EEGDAT.eeg_panel_message =3;%%There is errros in processing procedure
            fprintf( [repmat('-',1,100) '\n']);
            return;
        end
    end


%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=21
            return;
        end
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            EEG_dq_epoch.def_para.Enable= 'off';
            EEG_dq_epoch.custom_para.Enable= 'off';
            EEG_dq_epoch.custom_para_op.Enable = 'off';
            EEG_dq_epoch.all_marks.Enable= 'off';
            EEG_dq_epoch.excld_marks.Enable= 'off';
            EEG_dq_epoch.marked_epochs.Enable= 'off';
            EEG_dq_epoch.dq_run.Enable= 'off';
            EEG_dq_epoch.dq_cancel.Enable= 'off';
            
            if ~isempty(observe_EEGDAT.EEG) && observe_EEGDAT.EEG.trials ==1
                Eegtab_box_dq_epoch.TitleColor= [0.7500    0.7500    0.75000];
            else
                Eegtab_box_dq_epoch.TitleColor= [0.0500    0.2500    0.5000];
            end
            observe_EEGDAT.count_current_eeg=22;
            return;
        end
        Eegtab_box_dq_epoch.TitleColor= [0.0500    0.2500    0.5000];
        EEG_dq_epoch.timelimits = [observe_EEGDAT.EEG.times(1),observe_EEGDAT.EEG.times(end)];
        if EEG_dq_epoch.def_para.Value==1
            DQ_defaults = make_DQ_spec([observe_EEGDAT.EEG.times(1),observe_EEGDAT.EEG.times(end)]);
            EEG_dq_epoch.DQ_spec=DQ_defaults;
        end
        EEG_dq_epoch.def_para.Enable= 'on';
        EEG_dq_epoch.custom_para.Enable= 'on';
        EEG_dq_epoch.custom_para_op.Enable = 'on';
        EEG_dq_epoch.all_marks.Enable= 'on';
        EEG_dq_epoch.excld_marks.Enable= 'on';
        EEG_dq_epoch.marked_epochs.Enable= 'on';
        EEG_dq_epoch.dq_run.Enable= 'on';
        EEG_dq_epoch.dq_cancel.Enable= 'on';
        if EEG_dq_epoch.def_para.Value==1
            EEG_dq_epoch.custom_para_op.Enable = 'off';
        end
        observe_EEGDAT.count_current_eeg=22;
    end


%%--------------press return to execute "Apply"----------------------------
    function eeg_shiftcodes_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('EEGTab_dq_epoch');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            dq_run();
            estudioworkingmemory('EEGTab_dq_epoch',0);
            Eegtab_box_dq_epoch.TitleColor= [0.0500    0.2500    0.5000];
            EEG_dq_epoch.dq_cancel.BackgroundColor =  [1 1 1];
            EEG_dq_epoch.dq_cancel.ForegroundColor = [0 0 0];
            EEG_dq_epoch.dq_run.BackgroundColor =  [ 1 1 1];
            EEG_dq_epoch.dq_run.ForegroundColor = [0 0 0];
        else
            return;
        end
    end

%%-------------------Auomatically execute "apply"--------------------------
    function eeg_two_panels_change(~,~)
        if  isempty(observe_EEGDAT.EEG)
            return;
        end
        ChangeFlag =  estudioworkingmemory('EEGTab_dq_epoch');
        if ChangeFlag~=1
            return;
        end
        dq_run();
        estudioworkingmemory('EEGTab_dq_epoch',0);
        Eegtab_box_dq_epoch.TitleColor= [0.0500    0.2500    0.5000];
        EEG_dq_epoch.dq_cancel.BackgroundColor =  [1 1 1];
        EEG_dq_epoch.dq_cancel.ForegroundColor = [0 0 0];
        EEG_dq_epoch.dq_run.BackgroundColor =  [ 1 1 1];
        EEG_dq_epoch.dq_run.ForegroundColor = [0 0 0];
    end


%%--------------Reset this panel with the default parameters---------------
    function Reset_eeg_panel_change(~,~)
        if observe_EEGDAT.Reset_eeg_paras_panel~=18
            return;
        end
        estudioworkingmemory('EEGTab_dq_epoch',0);
%         Eegtab_box_dq_epoch.TitleColor= [0.0500    0.2500    0.5000];
        EEG_dq_epoch.dq_cancel.BackgroundColor =  [1 1 1];
        EEG_dq_epoch.dq_cancel.ForegroundColor = [0 0 0];
        EEG_dq_epoch.dq_run.BackgroundColor =  [ 1 1 1];
        EEG_dq_epoch.dq_run.ForegroundColor = [0 0 0];
        
        EEG_dq_epoch.def_para.Value=1;
        EEG_dq_epoch.custom_para.Value=0;
        EEG_dq_epoch.custom_para_op.Enable = 'off';
        EEG_dq_epoch.all_marks.Value = 1;
        EEG_dq_epoch.excld_marks.Value = 0;
        EEG_dq_epoch.marked_epochs.Value = 0;
        observe_EEGDAT.Reset_eeg_paras_panel=19;
    end

end