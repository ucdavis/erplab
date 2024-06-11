%%This function is to Compute Averaged ERPs (Epoched EEG).


% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Oct. 2023


function varargout = f_EEG_avg_erp_GUI(varargin)

global observe_EEGDAT;
global EStudio_gui_erp_totl;
global observe_ERPDAT;
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
addlistener(observe_EEGDAT,'Reset_eeg_panel_change',@Reset_eeg_panel_change);


%---------------------------Initialize parameters------------------------------------
EEG_avg_erp = struct();
%-----------------------------Name the title----------------------------------------------

% global Eegtab_box_avg_erp;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    Eegtab_box_avg_erp = uiextras.BoxPanel('Parent', fig, 'Title', 'Compute Averaged ERPs (Epoched EEG)',...
        'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    Eegtab_box_avg_erp = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Compute Averaged ERPs (Epoched EEG)',...
        'Padding', 5,'BackgroundColor',ColorB_def);
else
    Eegtab_box_avg_erp = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Compute Averaged ERPs (Epoched EEG)',...
        'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);%, 'HelpFcn', @avg_help
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
varargout{1} = Eegtab_box_avg_erp;

    function drawui_dq_epoch_eeg(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        EEG_avg_erp.DataSelBox = uiextras.VBox('Parent', Eegtab_box_avg_erp,'BackgroundColor',ColorB_def);
        FontSize_defualt = FonsizeDefault;
        if isempty(FontSize_defualt)
            FontSize_defualt = 12;
        end
        if isempty(observe_EEGDAT.EEG)
            EnableFlag = 'off';
        else
            EnableFlag = 'on';
        end
        
        def  = estudioworkingmemory('pop_averager');
        if isempty(def) || numel(def)~=12
            % Should not be empty, and have exactly 12 elements. Else, fallback to:
            def = {1 1 1 1 1 0 0 [] 1 [] 0 0};
        end
        
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
        EEG_avg_erp.movewindow_title1 = uiextras.HBox('Parent', EEG_avg_erp.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',EEG_avg_erp.movewindow_title1,'HorizontalAlignment','center','FontWeight','bold',...
            'String','Epochs to Include in ERP Average:','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable','on','BackgroundColor',ColorB_def); % 2F
        
        %%all epochs
        EEG_avg_erp.movewindow_title = uiextras.HBox('Parent', EEG_avg_erp.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_avg_erp.all_marks = uicontrol('Style','radiobutton','Parent',EEG_avg_erp.movewindow_title,'HorizontalAlignment','left',...
            'callback',@all_marks,'String','Include All epochs (ignore artifact detections)','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def); % 2F
        EEG_avg_erp.all_marks.KeyPressFcn=  @eeg_avg_erp_presskey;
        uiextras.Empty('Parent', EEG_avg_erp.movewindow_title ,'BackgroundColor',ColorB_def);
        set(EEG_avg_erp.movewindow_title,'Sizes',[270,-1]);
        
        %%exclude marked epochs
        EEG_avg_erp.windowstep_title = uiextras.HBox('Parent', EEG_avg_erp.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_avg_erp.excld_marks = uicontrol('Style','radiobutton','Parent',EEG_avg_erp.windowstep_title,'HorizontalAlignment','left',...
            'callback',@excld_marks,'String','','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def); % 2F
        EEG_avg_erp.excld_marks.String = '<html>Exclude epochs marked during artifact<br />detection (highly recommended)</html>';
        EEG_avg_erp.excld_marks.KeyPressFcn=  @eeg_avg_erp_presskey;
        uiextras.Empty('Parent',EEG_avg_erp.windowstep_title ,'BackgroundColor',ColorB_def);
        set(EEG_avg_erp.windowstep_title,'Sizes',[260,-1]);
        
        %%marked epochs
        EEG_avg_erp.eventcode_title = uiextras.HBox('Parent', EEG_avg_erp.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_avg_erp.marked_epochs = uicontrol('Style','radiobutton','Parent',EEG_avg_erp.eventcode_title,'HorizontalAlignment','left',...
            'callback',@marked_epochs,'String','','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def); % 2F
        EEG_avg_erp.marked_epochs.String = '<html>Include ONLY epochs marked with artifact<br />detection (by cautious!)</html>';
        uiextras.Empty('Parent', EEG_avg_erp.eventcode_title );
        set(EEG_avg_erp.eventcode_title,'Sizes',[260,-1]);
        EEG_avg_erp.all_marks.Value = Valueround1;
        EEG_avg_erp.excld_marks.Value = Valueround2;
        EEG_avg_erp.marked_epochs.Value = Valueround3;
        
        
        %%selection for invalid epochs
        EEG_avg_erp.invalidepoch_title = uiextras.HBox('Parent', EEG_avg_erp.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_avg_erp.invalidepoch = uicontrol('Style','checkbox','Parent',EEG_avg_erp.invalidepoch_title ,'HorizontalAlignment','left',...
            'callback',@invalidepoch,'String','','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def); % 2F
        EEG_avg_erp.invalidepoch.String = '<html>Exclude epochs with either "boundary"<br />or invalid events (highly recommended)</html>';
        EEG_avg_erp.invalidepoch.KeyPressFcn=  @eeg_avg_erp_presskey;
        excbound=1;
        EEG_avg_erp.invalidepoch.Value = excbound;
        
        try
            DQcustom_wins = def{12};
        catch
            DQcustom_wins = 0;
        end
        oldDQ =  def{10};
        EEG_avg_erp.DQ_spec = [];
        if isempty(oldDQ)
            dq_times_def = [1:6;-100:100:400;0:100:500]';
            EEG_avg_erp.dq_times = dq_times_def;
            EEG_avg_erp.DQ_spec = [];
        else
            try
                dq_times_def = oldDQ(3).times;
                EEG_avg_erp.dq_times = dq_times_def;
                EEG_avg_erp.DQ_spec = oldDQ;
            catch
                dq_times_def = [1:6;-100:100:400;0:100:500]';
                EEG_avg_erp.dq_times = dq_times_def;
                EEG_avg_erp.DQ_spec = oldDQ;
            end
        end
        try
            EEG_avg_erp.DQpreavg_txt =def{11};
        catch
            EEG_avg_erp.DQpreavg_txt =1;
        end
        
        EEG_avg_erp.para_title1 = uiextras.HBox('Parent', EEG_avg_erp.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',EEG_avg_erp.para_title1,'HorizontalAlignment','center','FontWeight','bold',...
            'String','Data Quality Quantification:','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable','on','BackgroundColor',ColorB_def); % 2F
        %%Default Parameters
        EEG_avg_erp.para_title2 = uiextras.HBox('Parent', EEG_avg_erp.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_avg_erp.def_para = uicontrol('Style','radiobutton','Parent',EEG_avg_erp.para_title2,'HorizontalAlignment','left',...
            'callback',@def_para,'String','On - default parameters','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def); % 2F
        EEG_avg_erp.def_para.KeyPressFcn=  @eeg_avg_erp_presskey;
        
        uiextras.Empty('Parent', EEG_avg_erp.para_title2 ,'BackgroundColor',ColorB_def);
        set(EEG_avg_erp.para_title2,'Sizes',[160,-1]);
        
        %%Custom Parameters
        EEG_avg_erp.para_title3 = uiextras.HBox('Parent', EEG_avg_erp.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_avg_erp.custom_para = uicontrol('Style','radiobutton','Parent',EEG_avg_erp.para_title3,'HorizontalAlignment','left',...
            'callback',@custom_para,'String','On - custom parameters','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def); % 2F
        EEG_avg_erp.def_para.KeyPressFcn=  @eeg_avg_erp_presskey;
        
        EEG_avg_erp.custom_para_op = uicontrol('Style','pushbutton','Parent',EEG_avg_erp.para_title3,'HorizontalAlignment','left',...
            'callback',@custom_para_op,'String','Options','FontSize',FontSize_defualt,'BackgroundColor',[1 1 1],'Enable',EnableFlag); % 2F
        uiextras.Empty('Parent', EEG_avg_erp.para_title3 ,'BackgroundColor',ColorB_def);
        set(EEG_avg_erp.para_title3,'Sizes',[160,60 -1]);
        
        
        %%no dq
        EEG_avg_erp.para_title4 = uiextras.HBox('Parent', EEG_avg_erp.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_avg_erp.no_dq = uicontrol('Style','radiobutton','Parent',EEG_avg_erp.para_title4,'HorizontalAlignment','left',...
            'callback',@no_dq,'String','No data quality measures','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def); % 2F
        EEG_avg_erp.no_dq.KeyPressFcn=  @eeg_avg_erp_presskey;
        uiextras.Empty('Parent', EEG_avg_erp.para_title4 ,'BackgroundColor',ColorB_def);
        set(EEG_avg_erp.para_title4,'Sizes',[160 -1]);
        if DQcustom_wins==0
            EEG_avg_erp.def_para.Value = 1;
            EEG_avg_erp.custom_para.Value=0;
            EEG_avg_erp.no_dq.Value=0;
        elseif DQcustom_wins==1
            EEG_avg_erp.def_para.Value = 0;
            EEG_avg_erp.custom_para.Value=1;
            EEG_avg_erp.no_dq.Value=0;
        else
            EEG_avg_erp.def_para.Value = 0;
            EEG_avg_erp.custom_para.Value=0;
            EEG_avg_erp.no_dq.Value=1;
        end
        
        %%-----------------------Cancel and Run----------------------------
        EEG_avg_erp.detar_run_title = uiextras.HBox('Parent', EEG_avg_erp.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  EEG_avg_erp.detar_run_title,'BackgroundColor',ColorB_def);
        EEG_avg_erp.avg_cancel = uicontrol('Style', 'pushbutton','Parent',EEG_avg_erp.detar_run_title,...
            'String','Cancel','callback',@avg_cancel,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent',  EEG_avg_erp.detar_run_title,'BackgroundColor',ColorB_def);
        EEG_avg_erp.avg_run = uicontrol('Style','pushbutton','Parent',EEG_avg_erp.detar_run_title,...
            'String','Run','callback',@avg_run,'FontSize',FontSize_defualt,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent',  EEG_avg_erp.detar_run_title,'BackgroundColor',ColorB_def);
        set(EEG_avg_erp.detar_run_title,'Sizes',[15 105  30 105 15]);
        
        set(EEG_avg_erp.DataSelBox,'Sizes',[20 25 30 30 30 20 25 25 25 30]);
        estudioworkingmemory('EEGTab_avg_erp',0);
        estudioworkingmemory('EEGTab_eeg2erp',0);
    end


%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%--------------------------------default parameters-----------------------
    function def_para(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=17
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_avg_erp.TitleColor= [0.5137    0.7569    0.9176];
        EEG_avg_erp.avg_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_avg_erp.avg_cancel.ForegroundColor = [1 1 1];
        EEG_avg_erp.avg_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_avg_erp.avg_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_avg_erp',1);
        EEG_avg_erp.def_para.Value=1;
        EEG_avg_erp.custom_para.Value=0;
        EEG_avg_erp.no_dq.Value=0;
        EEG_avg_erp.custom_para_op.Enable = 'off';
    end

%%-------------------------custom parameters-------------------------------
    function custom_para(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=17
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_avg_erp.TitleColor= [0.5137    0.7569    0.9176];
        EEG_avg_erp.avg_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_avg_erp.avg_cancel.ForegroundColor = [1 1 1];
        EEG_avg_erp.avg_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_avg_erp.avg_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_avg_erp',1);
        EEG_avg_erp.def_para.Value=0;
        EEG_avg_erp.custom_para.Value=1;
        EEG_avg_erp.custom_para_op.Enable = 'on';
        EEG_avg_erp.no_dq.Value=0;
    end

%%------------------------Custom define------------------------------------
    function custom_para_op(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=17
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_avg_erp.TitleColor= [0.5137    0.7569    0.9176];
        EEG_avg_erp.avg_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_avg_erp.avg_cancel.ForegroundColor = [1 1 1];
        EEG_avg_erp.avg_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_avg_erp.avg_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_avg_erp',1);
        
        timelimits = 1000 * [observe_EEGDAT.EEG.xmin observe_EEGDAT.EEG.xmax];
        old_DQ_spec = EEG_avg_erp.DQ_spec;
        custom_DQ_spec = avg_data_quality(old_DQ_spec,timelimits);
        EEG_avg_erp.timelimits = timelimits;
        if ~isempty(custom_DQ_spec)
            EEG_avg_erp.DQ_spec = custom_DQ_spec;
        end
    end

%%---------------------------------No data quality-------------------------
    function no_dq(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=17
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_avg_erp.TitleColor= [0.5137    0.7569    0.9176];
        EEG_avg_erp.avg_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_avg_erp.avg_cancel.ForegroundColor = [1 1 1];
        EEG_avg_erp.avg_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_avg_erp.avg_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_avg_erp',1);
        EEG_avg_erp.def_para.Value=0;
        EEG_avg_erp.custom_para.Value=0;
        EEG_avg_erp.custom_para_op.Enable = 'off';
        EEG_avg_erp.no_dq.Value=1;
    end


%%---------------------------all epochs------------------------------------
    function all_marks(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=17
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_avg_erp.TitleColor= [0.5137    0.7569    0.9176];
        EEG_avg_erp.avg_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_avg_erp.avg_cancel.ForegroundColor = [1 1 1];
        EEG_avg_erp.avg_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_avg_erp.avg_run.ForegroundColor = [1 1 1];
        
        estudioworkingmemory('EEGTab_avg_erp',1);
        EEG_avg_erp.all_marks.Value = 1;
        EEG_avg_erp.excld_marks.Value = 0;
        EEG_avg_erp.marked_epochs.Value = 0;
    end


%%-------------------------exclude marked epochs---------------------------
    function excld_marks(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=17
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_avg_erp.TitleColor= [0.5137    0.7569    0.9176];
        EEG_avg_erp.avg_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_avg_erp.avg_cancel.ForegroundColor = [1 1 1];
        EEG_avg_erp.avg_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_avg_erp.avg_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_avg_erp',1);
        
        EEG_avg_erp.all_marks.Value = 0;
        EEG_avg_erp.excld_marks.Value = 1;
        EEG_avg_erp.marked_epochs.Value = 0;
    end


%%-------------------------Only marked epochs------------------------------
    function marked_epochs(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=17
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_avg_erp.TitleColor= [0.5137    0.7569    0.9176];
        EEG_avg_erp.avg_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_avg_erp.avg_cancel.ForegroundColor = [1 1 1];
        EEG_avg_erp.avg_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_avg_erp.avg_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_avg_erp',1);
        EEG_avg_erp.all_marks.Value = 0;
        EEG_avg_erp.excld_marks.Value = 0;
        EEG_avg_erp.marked_epochs.Value = 1;
    end


%%-------------exclude invalide epochs or boundary-------------------------
    function invalidepoch(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=17
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_avg_erp.TitleColor= [0.5137    0.7569    0.9176];
        EEG_avg_erp.avg_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_avg_erp.avg_cancel.ForegroundColor = [1 1 1];
        EEG_avg_erp.avg_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_avg_erp.avg_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_avg_erp',1);
    end


%%%----------------------Preview-------------------------------------------
    function avg_cancel(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=17
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('f_EEG_proces_messg','Compute Averaged ERPs (Epoched EEG) > Cancel');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        Eegtab_box_avg_erp.TitleColor= [0.0500    0.2500    0.5000];
        EEG_avg_erp.avg_cancel.BackgroundColor =  [1 1 1];
        EEG_avg_erp.avg_cancel.ForegroundColor = [0 0 0];
        EEG_avg_erp.avg_run.BackgroundColor =  [ 1 1 1];
        EEG_avg_erp.avg_run.ForegroundColor = [0 0 0];
        
        estudioworkingmemory('EEGTab_avg_erp',0);
        
        def  = estudioworkingmemory('pop_averager');
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
            EEG_avg_erp.def_para.Value = 1;
            EEG_avg_erp.custom_para.Value=0;
            EEG_avg_erp.custom_para_op.Enable = 'off';
            EEG_avg_erp.timelimits = [observe_EEGDAT.EEG.times(1),observe_EEGDAT.EEG.times(end)];
            DQ_defaults = make_DQ_spec([observe_EEGDAT.EEG.times(1),observe_EEGDAT.EEG.times(end)]);
            EEG_avg_erp.DQ_spec=DQ_defaults;
            EEG_avg_erp.no_dq.Value =0;
        elseif DQcustom_wins==1
            EEG_avg_erp.def_para.Value = 0;
            EEG_avg_erp.custom_para.Value=1;
            EEG_avg_erp.custom_para_op.Enable = 'on';
            EEG_avg_erp.no_dq.Value =0;
        else
            EEG_avg_erp.def_para.Value = 0;
            EEG_avg_erp.custom_para.Value=0;
            EEG_avg_erp.custom_para_op.Enable = 'off';
            EEG_avg_erp.no_dq.Value =1;
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
        EEG_avg_erp.all_marks.Value = Valueround1;
        EEG_avg_erp.excld_marks.Value = Valueround2;
        EEG_avg_erp.marked_epochs.Value = Valueround3;
        
        excbound = def{5};
        if isempty(excbound) ||  numel(excbound)~=1 || (excbound~=0 && excbound~=1)
            excbound=1;
        end
        EEG_avg_erp.invalidepoch.Value = excbound;
        
        observe_EEGDAT.eeg_panel_message =2;
    end


%%-----------------------Run--------------------------------------
    function avg_run(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=17
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        if ~isfield(observe_EEGDAT.EEG,'EVENTLIST') || isempty(observe_EEGDAT.EEG.EVENTLIST)
            msgboxText=['Compute Averaged ERPs (Epoched EEG) > Run: We cannot work for the EEGset without "EVENTLIST". Please check "EVENTLIST" for current EEG data and you may create it before further analysis.'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        
        estudioworkingmemory('f_EEG_proces_messg','Compute Averaged ERPs (Epoched EEG) > Run');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        Eegtab_box_avg_erp.TitleColor= [0.0500    0.2500    0.5000];
        EEG_avg_erp.avg_cancel.BackgroundColor =  [1 1 1];
        EEG_avg_erp.avg_cancel.ForegroundColor = [0 0 0];
        EEG_avg_erp.avg_run.BackgroundColor =  [ 1 1 1];
        EEG_avg_erp.avg_run.ForegroundColor = [0 0 0];
        
        estudioworkingmemory('EEGTab_avg_erp',0);
        %%--------Selected EEGsets-----------
        EEGArray= estudioworkingmemory('EEGArray');
        if isempty(EEGArray) || min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) || max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG)
            EEGArray = observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',EEGArray);
        end
        incALL=EEG_avg_erp.all_marks.Value;
        excart=EEG_avg_erp.excld_marks.Value;
        onlyart=EEG_avg_erp.marked_epochs.Value;
        incart   = 0;
        incIndx  = 0;
        excbound = EEG_avg_erp.invalidepoch.Value; % exclude epochs having boundary events
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
            DQ_defaults = make_DQ_spec(EEG_avg_erp.timelimits);
        catch
            EEG_avg_erp.timelimits = [observe_EEGDAT.EEG.times(1),observe_EEGDAT.EEG.times(end)];
            DQ_defaults = make_DQ_spec([observe_EEGDAT.EEG.times(1),observe_EEGDAT.EEG.times(end)]);
        end
        DQ_defaults(1).comments{1} = 'Defaults';
        
        
        DQ_flag   = max(EEG_avg_erp.def_para.Value,EEG_avg_erp.custom_para.Value);
        
        use_defaults = EEG_avg_erp.def_para.Value;
        if DQ_flag
            stderror = 1;
            if use_defaults || isempty(EEG_avg_erp.DQ_spec)
                DQ_spec = DQ_defaults;
            else
                DQ_spec = EEG_avg_erp.DQ_spec;
            end
        else
            stderror = 0;
            DQ_spec = [];
        end
        
        if EEG_avg_erp.def_para.Value==1
            DQ_customWins = 0;
        else
            DQ_customWins = 1;
        end
        try
            DQ_preavg_txt = EEG_avg_erp.DQpreavg_txt;
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
        estudioworkingmemory('pop_averager', answer);
        
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
        
        ALLEEG1 = observe_EEGDAT.ALLEEG;
        try
            ALLERPCOM = evalin('base','ALLERPCOM');
        catch
            ALLERPCOM = [];
            assignin('base','ALLERPCOM',ALLERPCOM);
        end
        
        try
            ERPCOM = evalin('base','ERPCOM');
        catch
            ERPCOM = [];
            assignin('base','ALLERPCOM',ERPCOM);
        end
        
        Answer = f_ERP_save_multi_file(ALLEEG1,EEGArray,'',0);
        if isempty(Answer)
            return;
        end
        if ~isempty(Answer{1})
            ALLEEG = Answer{1};
            Save_file_label = Answer{2};
        end
        ALLERP = [];
        for Numofeeg = 1:numel(EEGArray)
            setindex =EEGArray(Numofeeg);
            EEG = ALLEEG(setindex);
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Compute Averaged ERPs (Epoched EEG) > Apply*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            
            %% Run the pop_ command with the user input from the GUI
            
            [ERP, ERPCOM]  = pop_averager(ALLEEG, 'DSindex', setindex, 'Criterion', artcritestr,...
                'SEM', stdsstr, 'Warning', 'on', 'ExcludeBoundary', excboundstr,...
                'DQ_flag',DQ_flag,'DQ_spec',DQ_spec, 'DQ_preavg_txt', DQ_preavg_txt, 'DQ_custom_wins', DQcustom_wins, ...
                'History', 'implicit','Saveas','off');
            if isempty(ERPCOM)
                observe_EEGDAT.eeg_panel_message =2;
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            if Numofeeg==1
                eegh(ERPCOM);
            end
            fprintf([ERPCOM,'\n']);
            if Numofeeg ==numel(EEGArray)
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
            else
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
            end
            ERP.erpname = EEG.setname;
            [pathstr, file_name, ~] = fileparts(EEG.filename);
            ERP.filename = [file_name,'.erp'];
            ERP.filepath=EEG.filepath;
            if Save_file_label
                [pathstr, file_name, ext] = fileparts(ERP.filename);
                ext = '.erp';
                pathstr= ERP.filepath;
                if strcmp(pathstr,'')
                    pathstr = cd;
                end
                ERP.filename = [file_name,ext];
                ERP.filepath = pathstr;
                %%----------save the current sdata as--------------------
                [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', ERP.filename, 'filepath',ERP.filepath);
                if Numofeeg ==numel(EEGArray)
                    [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
                else
                    [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                end
                if Numofeeg==1
                    eegh(ERPCOM);
                end
            end
            
            if isempty(observe_ERPDAT.ALLERP)
                observe_ERPDAT.ALLERP = ERP;
            else
                observe_ERPDAT.ALLERP(length(observe_ERPDAT.ALLERP)+1) =ERP;
            end
            fprintf( ['\n',repmat('-',1,100) '\n']);
            estudioworkingmemory('EEGTab_eeg2erp',1);
        end%%end for loop of subjects
        ALLERP =  observe_ERPDAT.ALLERP;
        for numofeeg = 1:numel(EEGArray)
            EEGNames{numofeeg} = ALLEEG1(EEGArray(numofeeg)).setname;
        end
        ERPArray = [length(ALLERP)-numel(EEGArray)+1:length(ALLERP)];
        ERPCOM = pop_erp_ar_summary(ALLERP,ERPArray,EEGNames);
        
        observe_EEGDAT.eeg_panel_message =2;
        EStudio_gui_erp_totl.context_tabs.SelectedChild = 2;
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
        [observe_ERPDAT.ERP,ALLERPCOM] = erphistory( observe_ERPDAT.ERP, ALLERPCOM, ERPCOM,2);
        observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
        estudioworkingmemory('selectederpstudio',observe_ERPDAT.CURRENTERP);
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        observe_ERPDAT.Count_currentERP=1;
    end


%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=23
            return;
        end
        EEGUpdate = estudioworkingmemory('EEGUpdate');
        if isempty(EEGUpdate) || numel(EEGUpdate)~=1 || (EEGUpdate~=0 && EEGUpdate~=1)
            EEGUpdate = 0;  estudioworkingmemory('EEGUpdate',0);
        end
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1 || EEGUpdate==1
            EEG_avg_erp.def_para.Enable= 'off';
            EEG_avg_erp.custom_para.Enable= 'off';
            EEG_avg_erp.custom_para_op.Enable = 'off';
            EEG_avg_erp.no_dq.Enable = 'off';
            EEG_avg_erp.all_marks.Enable= 'off';
            EEG_avg_erp.excld_marks.Enable= 'off';
            EEG_avg_erp.marked_epochs.Enable= 'off';
            EEG_avg_erp.invalidepoch.Enable= 'off';
            EEG_avg_erp.avg_run.Enable= 'off';
            EEG_avg_erp.avg_cancel.Enable= 'off';
            if ~isempty(observe_EEGDAT.EEG) && observe_EEGDAT.EEG.trials ==1
                Eegtab_box_avg_erp.TitleColor= [0.7500    0.7500    0.75000];
            else
                Eegtab_box_avg_erp.TitleColor= [0.0500    0.2500    0.5000];
            end
            observe_EEGDAT.count_current_eeg=24;
            return;
        end
        
        EEG_avg_erp.timelimits = [observe_EEGDAT.EEG.times(1),observe_EEGDAT.EEG.times(end)];
        if EEG_avg_erp.def_para.Value==1
            DQ_defaults = make_DQ_spec([observe_EEGDAT.EEG.times(1),observe_EEGDAT.EEG.times(end)]);
            EEG_avg_erp.DQ_spec=DQ_defaults;
        end
        Eegtab_box_avg_erp.TitleColor= [0.0500    0.2500    0.5000];
        EEG_avg_erp.def_para.Enable= 'on';
        EEG_avg_erp.custom_para.Enable= 'on';
        EEG_avg_erp.custom_para_op.Enable = 'on';
        EEG_avg_erp.no_dq.Enable = 'on';
        EEG_avg_erp.all_marks.Enable= 'on';
        EEG_avg_erp.excld_marks.Enable= 'on';
        EEG_avg_erp.marked_epochs.Enable= 'on';
        EEG_avg_erp.invalidepoch.Enable= 'on';
        EEG_avg_erp.avg_run.Enable= 'on';
        EEG_avg_erp.avg_cancel.Enable= 'on';
        if EEG_avg_erp.def_para.Value==1
            EEG_avg_erp.custom_para_op.Enable = 'off';
        end
        observe_EEGDAT.count_current_eeg=24;
    end


%%--------------press return to execute "Apply"----------------------------
    function eeg_avg_erp_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('EEGTab_avg_erp');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            avg_run();
            estudioworkingmemory('EEGTab_avg_erp',0);
            Eegtab_box_avg_erp.TitleColor= [0.0500    0.2500    0.5000];
            EEG_avg_erp.avg_cancel.BackgroundColor =  [1 1 1];
            EEG_avg_erp.avg_cancel.ForegroundColor = [0 0 0];
            EEG_avg_erp.avg_run.BackgroundColor =  [ 1 1 1];
            EEG_avg_erp.avg_run.ForegroundColor = [0 0 0];
        end
    end



%%--------------Reset this panel with the default parameters---------------
    function Reset_eeg_panel_change(~,~)
        if observe_EEGDAT.Reset_eeg_paras_panel~=19
            return;
        end
        estudioworkingmemory('EEGTab_avg_erp',0);
        EEG_avg_erp.avg_cancel.BackgroundColor =  [1 1 1];
        EEG_avg_erp.avg_cancel.ForegroundColor = [0 0 0];
        EEG_avg_erp.avg_run.BackgroundColor =  [ 1 1 1];
        EEG_avg_erp.avg_run.ForegroundColor = [0 0 0];
        EEG_avg_erp.all_marks.Value = 0;
        EEG_avg_erp.excld_marks.Value = 1;
        EEG_avg_erp.marked_epochs.Value = 0;
        EEG_avg_erp.def_para.Value=1;
        EEG_avg_erp.custom_para.Value=0;
        EEG_avg_erp.no_dq.Value=0;
        EEG_avg_erp.custom_para_op.Enable = 'off';
        EEG_avg_erp.invalidepoch.Value = 0;
        observe_EEGDAT.Reset_eeg_paras_panel=20;
    end
end