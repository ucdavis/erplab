%%This function is to extract best file which is used to decode


% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Jun. 2024


function varargout = f_EEG_extr_best_GUI(varargin)

global observe_EEGDAT;
global EStudio_gui_erp_totl;
global observe_DECODE;
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
addlistener(observe_EEGDAT,'Reset_eeg_panel_change',@Reset_eeg_panel_change);
% addlistener(observe_DECODE,'Count_currentbest_change',@Count_currentbest_change);

%---------------------------Initialize parameters------------------------------------
EEG_extr_best = struct();
%-----------------------------Name the title----------------------------------------------

% global Eegtab_box_best;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    Eegtab_box_best = uiextras.BoxPanel('Parent', fig, 'Title', 'Extract Bin-Epoched Single Trials (BEST)',...
        'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    Eegtab_box_best = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Extract Bin-Epoched Single Trials (BEST)',...
        'Padding', 5,'BackgroundColor',ColorB_def);
else
    Eegtab_box_best = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Extract Bin-Epoched Single Trials (BEST)',...
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
varargout{1} = Eegtab_box_best;

    function drawui_dq_epoch_eeg(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        EEG_extr_best.DataSelBox = uiextras.VBox('Parent', Eegtab_box_best,'BackgroundColor',ColorB_def);
        FontSize_defualt = FonsizeDefault;
        if isempty(FontSize_defualt)
            FontSize_defualt = 12;
        end
        EnableFlag = 'off';
        
        def = {[],0,{'',''},1,1};
        estudioworkingmemory('pop_extractBEST',def);
        
        %%Round to arlier time sample (recommended)
        EEG_extr_best.movewindow_title1 = uiextras.HBox('Parent', EEG_extr_best.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',EEG_extr_best.movewindow_title1,'HorizontalAlignment','center','FontWeight','bold',...
            'String','Epochs to Include into BESTset:','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable','on','BackgroundColor',ColorB_def); % 2F
        
        %%all epochs
        EEG_extr_best.movewindow_title = uiextras.HBox('Parent', EEG_extr_best.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_extr_best.all_marks = uicontrol('Style','radiobutton','Parent',EEG_extr_best.movewindow_title,'HorizontalAlignment','left',...
            'callback',@all_marks,'String','Include all epochs (ignore artifact detections)','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def); % 2F
        EEG_extr_best.all_marks.KeyPressFcn=  @EEG_extr_best_presskey;
        uiextras.Empty('Parent', EEG_extr_best.movewindow_title ,'BackgroundColor',ColorB_def);
        set(EEG_extr_best.movewindow_title,'Sizes',[270,-1]);
        
        %%exclude marked epochs
        EEG_extr_best.windowstep_title = uiextras.HBox('Parent', EEG_extr_best.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_extr_best.excld_marks = uicontrol('Style','radiobutton','Parent',EEG_extr_best.windowstep_title,'HorizontalAlignment','left',...
            'callback',@excld_marks,'String','','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def); % 2F
        EEG_extr_best.excld_marks.String = '<html>Exclude epochs marked during artifact<br />detection (highly recommended)</html>';
        EEG_extr_best.excld_marks.KeyPressFcn=  @EEG_extr_best_presskey;
        uiextras.Empty('Parent',EEG_extr_best.windowstep_title ,'BackgroundColor',ColorB_def);
        set(EEG_extr_best.windowstep_title,'Sizes',[260,-1]);
        
        %%marked epochs
        EEG_extr_best.eventcode_title = uiextras.HBox('Parent', EEG_extr_best.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_extr_best.marked_epochs = uicontrol('Style','radiobutton','Parent',EEG_extr_best.eventcode_title,'HorizontalAlignment','left',...
            'callback',@marked_epochs,'String','','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def); % 2F
        EEG_extr_best.marked_epochs.String = '<html>Include ONLY epochs marked with artifact<br />detection (by cautious!)</html>';
        uiextras.Empty('Parent', EEG_extr_best.eventcode_title );
        set(EEG_extr_best.eventcode_title,'Sizes',[260,-1]);
        EEG_extr_best.all_marks.Value = 0;
        EEG_extr_best.excld_marks.Value = 1;
        EEG_extr_best.marked_epochs.Value = 0;
        
        
        %%selection for invalid epochs
        EEG_extr_best.invalidepoch_title = uiextras.HBox('Parent', EEG_extr_best.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_extr_best.invalidepoch = uicontrol('Style','checkbox','Parent',EEG_extr_best.invalidepoch_title ,'HorizontalAlignment','left',...
            'callback',@invalidepoch,'String','','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',ColorB_def); % 2F
        EEG_extr_best.invalidepoch.String = '<html>Exclude epochs with either "boundary"<br />or invalid events (highly recommended)</html>';
        EEG_extr_best.invalidepoch.KeyPressFcn=  @EEG_extr_best_presskey;
        excbound=1;
        EEG_extr_best.invalidepoch.Value = excbound;
        
        %%Table is to display the bin descriptions
        EEG_extr_best.bindecps_title2 = uiextras.HBox('Parent',EEG_extr_best.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        
        EEG_extr_best.table_bins = uitable(  ...
            'Parent'        , EEG_extr_best.bindecps_title2,...
            'Data'          , [], ...
            'ColumnName'    , {'Select','Bin Description'}, ...
            'RowName'    , [], ...
            'ColumnEditable',[true,false],...
            'CellEditCallback', @updatePlot);
        EEG_extr_best.table_bins.Enable = 'off';
        
        %Transform into phase-independent power
        EEG_extr_best.tranf_title = uiextras.HBox('Parent', EEG_extr_best.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_extr_best.tranf_checkbox = uicontrol('Style', 'checkbox','Parent',EEG_extr_best.tranf_title,...
            'String','Transform into phase-independent power','callback',@tranf_checkbox,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',ColorB_def);
        EEG_extr_best.tranf_title2 = uiextras.HBox('Parent', EEG_extr_best.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  EEG_extr_best.tranf_title2,'BackgroundColor',ColorB_def);
        
        EEG_extr_best.tranf_left = uicontrol('Style', 'edit','Parent',EEG_extr_best.tranf_title2,...
            'String',' ','callback',@tranf_left,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uicontrol('Style', 'text','Parent',EEG_extr_best.tranf_title2,...
            'String','to','FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',ColorB_def);
        EEG_extr_best.tranf_right = uicontrol('Style','edit','Parent',EEG_extr_best.tranf_title2,...
            'String',' ','callback',@tranf_right,'FontSize',FontSize_defualt,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uicontrol('Style', 'text','Parent',EEG_extr_best.tranf_title2,...
            'String','Hz','FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',ColorB_def);
        set(EEG_extr_best.tranf_title2,'Sizes',[15 105  30 100 20]);
        
        
        %%-----------------------Cancel and Run----------------------------
        EEG_extr_best.detar_run_title = uiextras.HBox('Parent', EEG_extr_best.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  EEG_extr_best.detar_run_title,'BackgroundColor',ColorB_def);
        EEG_extr_best.avg_cancel = uicontrol('Style', 'pushbutton','Parent',EEG_extr_best.detar_run_title,...
            'String','Cancel','callback',@avg_cancel,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent',  EEG_extr_best.detar_run_title,'BackgroundColor',ColorB_def);
        EEG_extr_best.avg_run = uicontrol('Style','pushbutton','Parent',EEG_extr_best.detar_run_title,...
            'String','Run','callback',@avg_run,'FontSize',FontSize_defualt,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent',  EEG_extr_best.detar_run_title,'BackgroundColor',ColorB_def);
        set(EEG_extr_best.detar_run_title,'Sizes',[15 105  30 105 15]);
        
        
        set(EEG_extr_best.DataSelBox,'Sizes',[20 25 30 30 30 100 30 25 30]);
        EEG_extr_best.binsel = [];
        EEG_extr_best.freqband = {'',''};
    end

%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%---------------------------all epochs------------------------------------
    function all_marks(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=20
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_best.TitleColor= [0.5137    0.7569    0.9176];
        EEG_extr_best.avg_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_extr_best.avg_cancel.ForegroundColor = [1 1 1];
        EEG_extr_best.avg_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_extr_best.avg_run.ForegroundColor = [1 1 1];
        
        estudioworkingmemory('EEG_extr_best',1);
        EEG_extr_best.all_marks.Value = 1;
        EEG_extr_best.excld_marks.Value = 0;
        EEG_extr_best.marked_epochs.Value = 0;
    end


%%-------------------------exclude marked epochs---------------------------
    function excld_marks(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=20
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_best.TitleColor= [0.5137    0.7569    0.9176];
        EEG_extr_best.avg_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_extr_best.avg_cancel.ForegroundColor = [1 1 1];
        EEG_extr_best.avg_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_extr_best.avg_run.ForegroundColor = [1 1 1];
        
        estudioworkingmemory('EEG_extr_best',1);
        
        EEG_extr_best.all_marks.Value = 0;
        EEG_extr_best.excld_marks.Value = 1;
        EEG_extr_best.marked_epochs.Value = 0;
    end


%%-------------------------Only marked epochs------------------------------
    function marked_epochs(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=20
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_best.TitleColor= [0.5137    0.7569    0.9176];
        EEG_extr_best.avg_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_extr_best.avg_cancel.ForegroundColor = [1 1 1];
        EEG_extr_best.avg_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_extr_best.avg_run.ForegroundColor = [1 1 1];
        
        estudioworkingmemory('EEG_extr_best',1);
        EEG_extr_best.all_marks.Value = 0;
        EEG_extr_best.excld_marks.Value = 0;
        EEG_extr_best.marked_epochs.Value = 1;
    end


%%-------------exclude invalide epochs or boundary-------------------------
    function invalidepoch(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=20
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_best.TitleColor= [0.5137    0.7569    0.9176];
        EEG_extr_best.avg_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_extr_best.avg_cancel.ForegroundColor = [1 1 1];
        EEG_extr_best.avg_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_extr_best.avg_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEG_extr_best',1);
    end


%%-----------------------------select bins---------------------------------
    function updatePlot(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            EEG_extr_best.table_bins.Data= [];
            EEG_extr_best.table_bins.ColumnName={'Select','Bin Description'};
            EEG_extr_best.table_bins.Enable = 'off';
            msgboxText=['Extract Bin-Epoched Single Trials (BEST): Current EEGset is empty or it is not epoched EEG.'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        Eegtab_box_best.TitleColor= [0.5137    0.7569    0.9176];
        EEG_extr_best.avg_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_extr_best.avg_cancel.ForegroundColor = [1 1 1];
        EEG_extr_best.avg_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_extr_best.avg_run.ForegroundColor = [1 1 1];
        
        estudioworkingmemory('EEG_extr_best',1);
    end

%%----------------------------Transform into phase-independent power-------
    function tranf_checkbox(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        Eegtab_box_best.TitleColor= [0.5137    0.7569    0.9176];
        EEG_extr_best.avg_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_extr_best.avg_cancel.ForegroundColor = [1 1 1];
        EEG_extr_best.avg_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_extr_best.avg_run.ForegroundColor = [1 1 1];
        
        if EEG_extr_best.tranf_checkbox.Value==1
            enableFlag = 'on';
            EEG_extr_best.freqband{1} = EEG_extr_best.tranf_left.String;
            EEG_extr_best.freqband{2} = EEG_extr_best.tranf_right.String;
        else
            enableFlag = 'off';
            EEG_extr_best.freqband = {'',''};
        end
        EEG_extr_best.tranf_left.Enable = enableFlag;
        EEG_extr_best.tranf_right.Enable = enableFlag;
    end

%%-------------------left edge of frequency band---------------------------
    function tranf_left(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        Eegtab_box_best.TitleColor= [0.5137    0.7569    0.9176];
        EEG_extr_best.avg_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_extr_best.avg_cancel.ForegroundColor = [1 1 1];
        EEG_extr_best.avg_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_extr_best.avg_run.ForegroundColor = [1 1 1];
        tranf_left = str2num(EEG_extr_best.tranf_left.String);
        if isempty(tranf_left) || numel(tranf_left)~=1 || any(tranf_left(:)<=0) || any(tranf_left(:)>observe_EEGDAT.EEG.srate)
            msgboxText=['Extract Bin-Epoched Single Trials (BEST) > Transform into phase-independent power: Left edge of frequency band should be a single positive value that is smaller than',32,num2str(floor(observe_EEGDAT.EEG.srate/2))];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            EEG_extr_best.tranf_left.String = '';
            return;
        end
        EEG_extr_best.freqband{1} = EEG_extr_best.tranf_left.String;
    end

%%-------------------left edge of frequency band---------------------------
    function tranf_right(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        Eegtab_box_best.TitleColor= [0.5137    0.7569    0.9176];
        EEG_extr_best.avg_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_extr_best.avg_cancel.ForegroundColor = [1 1 1];
        EEG_extr_best.avg_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_extr_best.avg_run.ForegroundColor = [1 1 1];
        tranf_right = str2num(EEG_extr_best.tranf_right.String);
        if isempty(tranf_right) || numel(tranf_right)~=1 || any(tranf_right(:)<=0) || any(tranf_right(:)>observe_EEGDAT.EEG.srate)
            msgboxText=['Extract Bin-Epoched Single Trials (BEST) > Transform into phase-independent power: Right edge of frequency band should be a single positive value that is smaller than',32,num2str(floor(observe_EEGDAT.EEG.srate/2))];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            EEG_extr_best.tranf_right.String = '';
            return;
        end
        EEG_extr_best.freqband{2} = EEG_extr_best.tranf_right.String;
    end



%%%----------------------Preview-------------------------------------------
    function avg_cancel(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=20
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('f_EEG_proces_messg','Extract Bin-Epoched Single Trials (BEST) > Cancel');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        Eegtab_box_best.TitleColor= [0.0500    0.2500    0.5000];
        EEG_extr_best.avg_cancel.BackgroundColor =  [1 1 1];
        EEG_extr_best.avg_cancel.ForegroundColor = [0 0 0];
        EEG_extr_best.avg_run.BackgroundColor =  [ 1 1 1];
        EEG_extr_best.avg_run.ForegroundColor = [0 0 0];
        
        estudioworkingmemory('EEG_extr_best',0);
        
        def  = estudioworkingmemory('pop_extractBEST');
        if isempty(def) || numel(def)~=12
            def = {[],0,{'',''},1,1};
        end
        
        %%setting for selection of epoch types
        try
            artcrite = def{4};
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
        EEG_extr_best.all_marks.Value = Valueround1;
        EEG_extr_best.excld_marks.Value = Valueround2;
        EEG_extr_best.marked_epochs.Value = Valueround3;
        
        try excbound = def{5};catch excbound=1;end
        if isempty(excbound) ||  numel(excbound)~=1 || (excbound~=0 && excbound~=1)
            excbound=1;
        end
        EEG_extr_best.invalidepoch.Value = excbound;
        binselec = EEG_extr_best.binsel;
        if isfield(observe_EEGDAT.EEG,'EVENTLIST') || ~isempty(observe_EEGDAT.EEG.EVENTLIST)
            if ~isempty(binselec) && ( any(binselec(:)<1) || any(binselec(:)>observe_EEGDAT.EEG.EVENTLIST.nbin))
                binselec = [1:observe_EEGDAT.EEG.EVENTLIST.nbin];
            end
            if ~isempty(binselec)
                binselec = reshape(binselec,numel(binselec),1);
            end
            bindata = EEG_extr_best.table_bins.Data;
            for ii = 1:size(bindata,1)
                xpos = find(binselec==ii);
                if ~isempty(xpos)
                    bindata{ii,1} = true;
                else
                    bindata{ii,1} = false;
                end
            end
            EEG_extr_best.table_bins.Data = bindata;
        end
        try
            EEG_extr_best.freqband = def{3};
        catch
            EEG_extr_best.freqband={'',''};
            def{3} = {'',''};
        end
        freqband = EEG_extr_best.freqband;
        if isempty(cell2mat(freqband)) || numel(cell2mat(freqband))~=2
            freqband = {'',''};
        end
        freqband = cell2mat(freqband);
        if isempty(freqband)
            EEG_extr_best.tranf_checkbox.Value =0;
            EEG_extr_best.tranf_left.Enable ='off';
            EEG_extr_best.tranf_right.Enable = 'off';
        else
            EEG_extr_best.tranf_checkbox.Value =1;
            EEG_extr_best.tranf_left.Enable ='on';
            EEG_extr_best.tranf_right.Enable = 'on';
            try
                left_freq =  freqband(1);
            catch
                left_freq = [];
            end
            EEG_extr_best.tranf_left.String = num2str(left_freq);
            try
                right_freq =  freqband(2);
            catch
                right_freq = [];
            end
            EEG_extr_best.tranf_right.String = num2str(right_freq);
        end
        
        EEG_extr_best.freqband{1} = EEG_extr_best.tranf_left.String;
        EEG_extr_best.freqband{2} = EEG_extr_best.tranf_right.String;
        def{3} = EEG_extr_best.freqband;
        
        def{1} = binselec;
        def{4} = artcrite; def{5} = excbound;
        estudioworkingmemory('pop_extractBEST',def);
        observe_EEGDAT.eeg_panel_message =2;
    end

%%----------------------------frequency band-------------------------------
    function avg_ops(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        
        app = feval('eeg2best_freqops', EEG_extr_best.freqband); %cludgy way
        waitfor(app, 'Finishbutton',1);
        
        %outputs & delete gui
        try
            freqband = app.output;
            app.delete;
        catch
            return
        end
        Eegtab_box_best.TitleColor= [0.5137    0.7569    0.9176];
        EEG_extr_best.avg_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_extr_best.avg_cancel.ForegroundColor = [1 1 1];
        EEG_extr_best.avg_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_extr_best.avg_run.ForegroundColor = [1 1 1];
        
        estudioworkingmemory('EEG_extr_best',1);
        if isempty(cell2mat(freqband)) || numel(cell2mat(freqband))~=2
            freqband = {'',''};
        end
        EEG_extr_best.freqband = freqband;
    end

%%----------------------------Run------------------------------------------
    function avg_run(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=20
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        if ~isfield(observe_EEGDAT.EEG,'EVENTLIST') || isempty(observe_EEGDAT.EEG.EVENTLIST)
            msgboxText=['Extract Bin-Epoched Single Trials (BEST) > Run: We cannot work for the EEGset without "EVENTLIST". Please check "EVENTLIST" for current EEG data and you may create it before further analysis.'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        
        estudioworkingmemory('f_EEG_proces_messg','Extract Bin-Epoched Single Trials (BEST) > Run');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        Eegtab_box_best.TitleColor= [0.0500    0.2500    0.5000];
        EEG_extr_best.avg_cancel.BackgroundColor =  [1 1 1];
        EEG_extr_best.avg_cancel.ForegroundColor = [0 0 0];
        EEG_extr_best.avg_run.BackgroundColor =  [ 1 1 1];
        EEG_extr_best.avg_run.ForegroundColor = [0 0 0];
        
        estudioworkingmemory('EEG_extr_best',0);
        %%--------Selected EEGsets-----------
        EEGArray= estudioworkingmemory('EEGArray');
        if isempty(EEGArray) || min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) || max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG)
            EEGArray = observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',EEGArray);
        end
        
        count = 0;
        binselec = [];
        for ii = 1:size(EEG_extr_best.table_bins.Data,1)
            if EEG_extr_best.table_bins.Data{ii,1}==1
                count = count +1;
                binselec(count) = ii;
            end
        end
        if isempty(binselec)
            msgboxText=['Extract Bin-Epoched Single Trials (BEST) > Run:  No bin was selected'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        if numel(binselec)<2
            msgboxText=['Extract Bin-Epoched Single Trials (BEST) > Run:  Must have at least two classes for decoding! '];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        EEG_extr_best.binsel = binselec;
        
        def =  estudioworkingmemory('pop_extractBEST');
        if isempty(def)
            def = {[],0,{'',''},1,1};
        end
        
        incALL=EEG_extr_best.all_marks.Value;
        excart=EEG_extr_best.excld_marks.Value;
        onlyart=EEG_extr_best.marked_epochs.Value;
        incart   = 0;
        incIndx  = 0;
        exclude_be = EEG_extr_best.invalidepoch.Value; % exclude epochs having boundary events
        if incALL
            artcrite = 0;
        elseif excart
            artcrite = 1;
        else
            artcrite = 2;
        end
        
        if artcrite==0
            artcritestr = 'all';
        elseif artcrite==1
            artcritestr = 'good';
        elseif artcrite==2
            artcritestr = 'bad';
        else
            artcritestr = 'good';
        end
        def{4} = artcrite;
        
        if exclude_be == 1
            excbound = 'on';
        else
            excbound = 'off';
        end
        def{5} = exclude_be;
        
        if EEG_extr_best.tranf_checkbox.Value ==0
            freqband = {'',''};
            EEG_extr_best.freqband = freqband;
        else
            tranf_left = str2num(EEG_extr_best.tranf_left.String);
            tranf_right = str2num(EEG_extr_best.tranf_right.String);
            if isempty(tranf_left) || numel(tranf_left)~=1 || any(tranf_left(:)<=0) || any(tranf_left(:)>observe_EEGDAT.EEG.srate)
                msgboxText=['Extract Bin-Epoched Single Trials (BEST) > Run: Left edge of frequency band should be a single positive value that is smaller than',32,num2str(floor(observe_EEGDAT.EEG.srate/2))];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                EEG_extr_best.tranf_left.String = '';
                return;
            end
            
            if isempty(tranf_right) || numel(tranf_right)~=1 || any(tranf_right(:)<=0) || any(tranf_right(:)>observe_EEGDAT.EEG.srate)
                msgboxText=['Extract Bin-Epoched Single Trials (BEST) > Run: Right edge of frequency band should be a single positive value that is smaller than',32,num2str(floor(observe_EEGDAT.EEG.srate/2))];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                EEG_extr_best.tranf_left.String = '';
                return;
            end
            
            if tranf_left>=tranf_right
                msgboxText=['Extract Bin-Epoched Single Trials (BEST) > Run: Left edge of frequency band should be smaller than right one'];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                EEG_extr_best.tranf_left.String = '';
                return;
            end
            EEG_extr_best.freqband{1} = tranf_left;
            EEG_extr_best.freqband{2} = tranf_right;
        end
        
        
        freqband = EEG_extr_best.freqband;
        if ~isempty(cell2mat(freqband)) && numel(cell2mat(freqband))==2
            def{2}=1; def{3} = freqband;
        else
            def{2}=0; def{3} =  {'',''};
            EEG_extr_best.freqband =  {'',''};
        end
        
        
        try
            cmk_bp=  def{2};
        catch
            cmk_bp = 0;
            def{2} = 0;
        end
        try bpfreq  = cell2mat(def{3}); catch bpfreq = [];def{2}  = {'',''}; end
        if cmk_bp == 0
            bpfreq = [];
        end
        
        ALLEEG1 = observe_EEGDAT.ALLEEG;
        
        Answer = f_EEG_saveas_multi_bestfile(ALLEEG1,EEGArray,'');
        if isempty(Answer)
            return;
        end
        if ~isempty(Answer{1})
            ALLEEG = Answer{1};
            Save_file_label = Answer{2};
        end
        
        for Numofeeg = 1:numel(EEGArray)
            setindex =EEGArray(Numofeeg);
            EEG = ALLEEG(setindex);
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Extract Bin-Epoched Single Trials (BEST) > Run*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            
            %% Run the pop_ command with the user input from the GUI
            [BEST,LASTCOM] = pop_extractbest( EEG , 'Bins', binselec, 'Criterion', artcritestr,'DSindex',1, ...
                'ExcludeBoundary',excbound, 'Bandpass', bpfreq,'Saveas', 'off','History','gui');
            if isempty(LASTCOM)
                observe_EEGDAT.eeg_panel_message =2;
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            
            if Numofeeg==1
                eegh(LASTCOM);
            end
            
            BEST.bestname = EEG.setname;
            [pathstr, file_name, ~] = fileparts(EEG.filename);
            if ~isempty(file_name)
                BEST.filename = [file_name,'.best'];
            else
                BEST.filename = '';
            end
            BEST.filepath=EEG.filepath;
            BEST.saved = 'no';
            if Save_file_label
                [pathstr, file_name, ext] = fileparts(BEST.filename);
                ext = '.best';
                pathstr= BEST.filepath;
                if strcmp(pathstr,'')
                    pathstr = cd;
                end
                BEST.filename = [file_name,ext];
                BEST.filepath = pathstr;
                %%----------save the current sdata as--------------------
                [BEST, issave, BESTCOM] = pop_savemybest(BEST, 'bestname', BEST.bestname, 'filename', ...
                    BEST.filename, 'filepath',BEST.filepath);
                if Numofeeg==1
                    eegh(BESTCOM);
                end
                BEST.saved = 'yes';
            end
            
            if isempty(observe_DECODE.ALLBEST)
                observe_DECODE.ALLBEST = BEST;
            else
                observe_DECODE.ALLBEST(length(observe_DECODE.ALLBEST)+1) =BEST;
            end
            fprintf( ['\n',repmat('-',1,100) '\n']);
        end%%end for loop of subjects
        observe_EEGDAT.eeg_panel_message =2;
        EStudio_gui_erp_totl.context_tabs.SelectedChild = 3;
        observe_DECODE.BEST = observe_DECODE.ALLBEST(end);
        observe_DECODE.CURRENTBEST = length(observe_DECODE.ALLBEST);
        estudioworkingmemory('BESTArray',observe_DECODE.CURRENTBEST);
        try observe_DECODE.Count_currentbest=1; catch  end
    end


%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=27
            return;
        end
        EEGUpdate = estudioworkingmemory('EEGUpdate');
        if isempty(EEGUpdate) || numel(EEGUpdate)~=1 || (EEGUpdate~=0 && EEGUpdate~=1)
            EEGUpdate = 0;  estudioworkingmemory('EEGUpdate',0);
        end
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1 || EEGUpdate==1
            EEG_extr_best.all_marks.Enable= 'off';
            EEG_extr_best.excld_marks.Enable= 'off';
            EEG_extr_best.marked_epochs.Enable= 'off';
            EEG_extr_best.invalidepoch.Enable= 'off';
            EEG_extr_best.avg_run.Enable= 'off';
            EEG_extr_best.avg_cancel.Enable= 'off';
            EEG_extr_best.tranf_checkbox.Enable= 'off';
            EEG_extr_best.tranf_left.Enable ='off';
            EEG_extr_best.tranf_right.Enable = 'off';
            EEG_extr_best.table_bins.Data = [];
            if ~isempty(observe_EEGDAT.EEG) && observe_EEGDAT.EEG.trials ==1
                Eegtab_box_best.TitleColor= [0.7500    0.7500    0.75000];
            else
                Eegtab_box_best.TitleColor= [0.0500    0.2500    0.5000];
            end
            return;
        end
        Eegtab_box_best.TitleColor= [0.0500    0.2500    0.5000];
        binsel = EEG_extr_best.binsel;
        if isfield(observe_EEGDAT.EEG,'EVENTLIST') || ~isempty(observe_EEGDAT.EEG.EVENTLIST)
            EEG_extr_best.table_bins.Data= [];
            try
                binlist = {observe_EEGDAT.EEG.EVENTLIST.bdf.description}';
                binind = {observe_EEGDAT.EEG.EVENTLIST.bdf.namebin}';
                combine_bins = strcat(binind,' ---  ',binlist);
                checked_bins = false(size(combine_bins,1),1);
                if isempty(binsel) || any(binsel(:)>length(binlist)) || any(binsel(:)>1)
                    binsel = [1:length(binlist)];
                end
                if length(binsel) > length(checked_bins) %In case working memory was different
                    checked_bins(binsel(1:length(checked_bins))) = true;
                else
                    checked_bins(binsel) = true; %selection based on working memory
                end
                for ii = 1:length(checked_bins)
                    bindata{ii,1} = checked_bins(ii);
                    bindata{ii,2} = combine_bins{ii};
                end
                EEG_extr_best.binsel = binsel;
            catch
                bindata =[];
            end
            EEG_extr_best.table_bins.Enable = 'on';
            EEG_extr_best.table_bins.ColumnWidth = {70 250};
        else
            bindata =[];
            EEG_extr_best.table_bins.Enable = 'off';
        end
        EEG_extr_best.table_bins.RowName=[];
        EEG_extr_best.table_bins.Data= bindata;
        EEG_extr_best.table_bins.ColumnName={'Select','Bin Description'};
        EEG_extr_best.all_marks.Enable= 'on';
        EEG_extr_best.excld_marks.Enable= 'on';
        EEG_extr_best.marked_epochs.Enable= 'on';
        EEG_extr_best.invalidepoch.Enable= 'on';
        EEG_extr_best.avg_run.Enable= 'on';
        EEG_extr_best.avg_cancel.Enable= 'on';
        EEG_extr_best.tranf_checkbox.Enable= 'on';
        if EEG_extr_best.tranf_checkbox.Value ==1
            EnableFlag = 'on';
        else
            EnableFlag = 'off';
        end
        EEG_extr_best.tranf_left.Enable =EnableFlag;
        EEG_extr_best.tranf_right.Enable = EnableFlag;
    end


%%--------------press return to execute "Apply"----------------------------
    function EEG_extr_best_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('EEG_extr_best');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            avg_run();
            estudioworkingmemory('EEG_extr_best',0);
            Eegtab_box_best.TitleColor= [0.0500    0.2500    0.5000];
            EEG_extr_best.avg_cancel.BackgroundColor =  [1 1 1];
            EEG_extr_best.avg_cancel.ForegroundColor = [0 0 0];
            EEG_extr_best.avg_run.BackgroundColor =  [ 1 1 1];
            EEG_extr_best.avg_run.ForegroundColor = [0 0 0];
        end
    end


%%--------------Reset this panel with the default parameters---------------
    function Reset_eeg_panel_change(~,~)
        if observe_EEGDAT.Reset_eeg_paras_panel~=23
            return;
        end
        estudioworkingmemory('EEG_extr_best',0);
        EEG_extr_best.avg_cancel.BackgroundColor =  [1 1 1];
        EEG_extr_best.avg_cancel.ForegroundColor = [0 0 0];
        EEG_extr_best.avg_run.BackgroundColor =  [ 1 1 1];
        EEG_extr_best.avg_run.ForegroundColor = [0 0 0];
        EEG_extr_best.all_marks.Value = 0;
        EEG_extr_best.excld_marks.Value = 1;
        EEG_extr_best.marked_epochs.Value = 0;
        EEG_extr_best.invalidepoch.Value = 0;
        
        if isfield(observe_EEGDAT.EEG,'EVENTLIST') || ~isempty(observe_EEGDAT.EEG.EVENTLIST)
            EEG_extr_best.table_bins.Data= [];
            try
                binlist = {observe_EEGDAT.EEG.EVENTLIST.bdf.description}';
                binind = {observe_EEGDAT.EEG.EVENTLIST.bdf.namebin}';
                combine_bins = strcat(binind,' ---  ',binlist);
                checked_bins = false(size(combine_bins,1),1);
                binsel = [1:length(binlist)];
                checked_bins(binsel) = true; %selection based on working memory
                for ii = 1:length(checked_bins)
                    bindata{ii,1} = checked_bins(ii);
                    bindata{ii,2} = combine_bins{ii};
                end
                EEG_extr_best.binsel = binsel;
            catch
                bindata = [];
            end
            EEG_extr_best.table_bins.Data= bindata;
            EEG_extr_best.table_bins.ColumnName={'Select','Bin Description'};
            EEG_extr_best.table_bins.Enable = 'on';
            EEG_extr_best.table_bins.RowName=[];
            EEG_extr_best.table_bins.ColumnWidth = {70 250};
        else
            EEG_extr_best.table_bins.Data= [];
            EEG_extr_best.table_bins.ColumnName={'Select','Bin Description'};
            EEG_extr_best.table_bins.Enable = 'off';
        end
        EEG_extr_best.freqband = {'',''};
        estudioworkingmemory('pop_extractBEST',{[],0,{'',''},1,1});
        EEG_extr_best.tranf_checkbox.Value =0;
        EEG_extr_best.tranf_left.Enable ='off';
        EEG_extr_best.tranf_right.Enable = 'off';
    end
end