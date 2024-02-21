%Author: Guanghui Zhang & Steven Luck
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Sep. 2023

% ERPLAB Studio

function varargout = f_EEG_binepoch_GUI(varargin)

global observe_EEGDAT;
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
addlistener(observe_EEGDAT,'Reset_eeg_panel_change',@Reset_eeg_panel_change);

%%---------------------------gui-------------------------------------------
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    EEG_binepoch_box = uiextras.BoxPanel('Parent', fig, 'Title', 'Extract Bin-Based Epochs (Continuous EEG)', 'Padding', 5,...
        'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    EEG_binepoch_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Extract Bin-Based Epochs (Continuous EEG)', 'Padding', 5,...
        'BackgroundColor',ColorB_def);
else
    EEG_binepoch_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Extract Bin-Based Epochs (Continuous EEG)', 'Padding', 5, ...
        'FontSize', varargin{2},'BackgroundColor',ColorB_def);%, 'HelpFcn', @epoch_help
end

gui_eegtab_binepoch = struct();
try
    FonsizeDefault = varargin{2};
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
    FonsizeDefault = f_get_default_fontsize();
end
erp_blc_dt_gui(FonsizeDefault);
varargout{1} = EEG_binepoch_box;
%%********************Draw the GUI for ERP measurement tool*****************
    function erp_blc_dt_gui(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        
        if isempty(observe_EEGDAT.EEG)
            Enable_label = 'off';
        else
            Enable_label = 'on';
        end
        gui_eegtab_binepoch.blc_dt = uiextras.VBox('Parent',EEG_binepoch_box,'Spacing',1,'BackgroundColor',ColorB_def);
        
        %%Time range for one epoch
        gui_eegtab_binepoch.timerange_title = uiextras.HBox('Parent',  gui_eegtab_binepoch.blc_dt,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent',  gui_eegtab_binepoch.timerange_title,...
            'String','Time Range:','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_eegtab_binepoch.timerange_edit = uicontrol('Style', 'edit','Parent', gui_eegtab_binepoch.timerange_title,...
            'String','','callback',@timerange_edit,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        gui_eegtab_binepoch.timerange_edit.KeyPressFcn=  @eeg_binepoch_presskey;
        set(gui_eegtab_binepoch.timerange_title, 'Sizes',[80  200]);
        def  = erpworkingmemory('pop_epochbin');
        if isempty(def)
            def = {[-200 800]  'pre'};
        end
        if isnumeric(def{1}) && numel(def{1})==2
            gui_eegtab_binepoch.timerange_edit.String = num2str(def{1});
        else
            gui_eegtab_binepoch.timerange_edit.String = '';
        end
        try
            BaelineMethod = def{2};
        catch
            BaelineMethod = 'pre';
        end
        if isempty(BaelineMethod)
            BaelineMethod = 'pre';
        end
        if numel(BaelineMethod)==2
            noneFlag = 0;
            preFlag = 0;
            postFlag = 0;
            wholeFlag = 0;
            customFlag = 1;
            if numel(BaelineMethod)~=2
                BaelineMethod = 'pre';
                noneFlag = 0;
                preFlag = 1;
                postFlag = 0;
                wholeFlag = 0;
                customFlag = 0;
            end
        else
            if strcmpi(BaelineMethod,'none')
                noneFlag = 1;
                preFlag = 0;
                postFlag = 0;
                wholeFlag = 0;
                customFlag = 0;
            elseif strcmpi(BaelineMethod,'pre')
                noneFlag = 0;
                preFlag = 1;
                postFlag = 0;
                wholeFlag = 0;
                customFlag = 0;
            elseif strcmpi(BaelineMethod,'post')
                noneFlag = 0;
                preFlag = 0;
                postFlag = 1;
                wholeFlag = 0;
                customFlag = 0;
                
            elseif  strcmpi(BaelineMethod,'whole') || strcmpi(BaelineMethod,'all')
                noneFlag = 0;
                preFlag = 0;
                postFlag = 0;
                wholeFlag = 1;
                customFlag = 0;
            else
                noneFlag = 0;
                preFlag = 1;
                postFlag = 0;
                wholeFlag = 0;
                customFlag = 0;
            end
        end
        
        %%Baseline period: Pre, post whole custom
        gui_eegtab_binepoch.blc_dt_baseline_period_title = uiextras.HBox('Parent',  gui_eegtab_binepoch.blc_dt,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', gui_eegtab_binepoch.blc_dt_baseline_period_title,...
            'String','Baseline Period:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        gui_eegtab_binepoch.blc_dt_bp_option = uiextras.HBox('Parent',  gui_eegtab_binepoch.blc_dt,'Spacing',1,'BackgroundColor',ColorB_def);
        gui_eegtab_binepoch.none = uicontrol('Style', 'radiobutton','Parent', gui_eegtab_binepoch.blc_dt_bp_option,'Value',noneFlag,...
            'String','None','callback',@none_eeg,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_eegtab_binepoch.none.KeyPressFcn=  @eeg_binepoch_presskey;
        gui_eegtab_binepoch.pre = uicontrol('Style', 'radiobutton','Parent', gui_eegtab_binepoch.blc_dt_bp_option,'Value',preFlag,...
            'String','Pre','callback',@pre_eeg,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_eegtab_binepoch.pre.KeyPressFcn=  @eeg_binepoch_presskey;
        gui_eegtab_binepoch.post = uicontrol('Style', 'radiobutton','Parent', gui_eegtab_binepoch.blc_dt_bp_option,'Value',postFlag,...
            'String','Post','callback',@post_eeg,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_eegtab_binepoch.post.KeyPressFcn=  @eeg_binepoch_presskey;
        gui_eegtab_binepoch.whole = uicontrol('Style', 'radiobutton','Parent', gui_eegtab_binepoch.blc_dt_bp_option,'Value',wholeFlag,...
            'String','Whole','callback',@whole_eeg,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_eegtab_binepoch.whole.KeyPressFcn=  @eeg_binepoch_presskey;
        
        gui_eegtab_binepoch.blc_dt_bp_option_cust = uiextras.HBox('Parent',  gui_eegtab_binepoch.blc_dt,'Spacing',1,'BackgroundColor',ColorB_def);
        gui_eegtab_binepoch.custom = uicontrol('Style', 'radiobutton','Parent', gui_eegtab_binepoch.blc_dt_bp_option_cust,...
            'String','Custom (ms) [start stop]','callback',@custom_eeg,'Value',customFlag,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_eegtab_binepoch.custom.KeyPressFcn=  @eeg_binepoch_presskey;
        gui_eegtab_binepoch.custom_edit = uicontrol('Style', 'edit','Parent', gui_eegtab_binepoch.blc_dt_bp_option_cust,...
            'String','','callback',@precustom_edit,'Enable',Enable_label,'FontSize',FonsizeDefault);
        gui_eegtab_binepoch.custom_edit.KeyPressFcn=  @eeg_binepoch_presskey;
        if customFlag==1
            gui_eegtab_binepoch.custom_edit.String = num2str(BaelineMethod);
        end
        set(gui_eegtab_binepoch.blc_dt_bp_option_cust, 'Sizes',[160  135]);
        
        %%Cancel and advanced
        gui_eegtab_binepoch.other_option = uiextras.HBox('Parent',gui_eegtab_binepoch.blc_dt,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', gui_eegtab_binepoch.other_option,'BackgroundColor',ColorB_def);
        gui_eegtab_binepoch.cancel = uicontrol('Parent',gui_eegtab_binepoch.other_option,'Style','pushbutton',...
            'String','Cancel','callback',@Cancel_binepoch,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', gui_eegtab_binepoch.other_option);
        gui_eegtab_binepoch.apply = uicontrol('Style','pushbutton','Parent',gui_eegtab_binepoch.other_option,...
            'String','Apply','callback',@apply_blc_dt,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        gui_eegtab_binepoch.apply.KeyPressFcn=  @eeg_binepoch_presskey;
        uiextras.Empty('Parent', gui_eegtab_binepoch.other_option);
        set(gui_eegtab_binepoch.other_option, 'Sizes',[15 105  30 105 15]);
        set(gui_eegtab_binepoch.blc_dt,'Sizes',[25 15 25 25 30]);
    end
%%****************************************************************************************************************************************
%%*******************   Subfunctions   ***************************************************************************************************
%%****************************************************************************************************************************************

%%----------------input baseline period defined by user----------------------
    function timerange_edit(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=6
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        %%change color for cancel and apply
        gui_eegtab_binepoch.apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_binepoch.apply.ForegroundColor = [1 1 1];
        EEG_binepoch_box.TitleColor= [0.5137    0.7569    0.9176];
        gui_eegtab_binepoch.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_binepoch.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_binepoch',1);
        
        lat_osci = str2num(Source.String);
        if isempty(lat_osci)
            beep;
            msgboxText =  ['Extract Bin-Based Epochs (Continuous EEG) - Invalid input for "Time range"'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            return;
        end
        if numel(lat_osci) ~=2
            beep;
            msgboxText =  ['Extract Bin-Based Epochs (Continuous EEG) - Wrong time range for the epoch. Please, enter two values'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            gui_eegtab_binepoch.timerange_edit.String = '';
            return;
        end
        if lat_osci(1)>= lat_osci(2)
            beep;
            msgboxText =  ['Extract Bin-Based Epochs (Continuous EEG) - The first value must be smaller than the second one for time range'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            gui_eegtab_binepoch.timerange_edit.String = '';
            return;
        end
        if lat_osci(2) > observe_EEGDAT.EEG.times(end)
            msgboxText =  ['Extract Bin-Based Epochs (Continuous EEG) - Second value must be smaller than',32,num2str(observe_EEGDAT.EEG.times(end)),32,'for time range'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            gui_eegtab_binepoch.timerange_edit.String = '';
            return;
        end
    end

%%----------------------None baseline correction---------------------------
    function none_eeg(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=6
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        %%change color for cancel and apply
        gui_eegtab_binepoch.apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_binepoch.apply.ForegroundColor = [1 1 1];
        EEG_binepoch_box.TitleColor= [0.5137    0.7569    0.9176];
        gui_eegtab_binepoch.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_binepoch.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_binepoch',1);
        
        gui_eegtab_binepoch.none.Value =1;
        gui_eegtab_binepoch.pre.Value=0;
        gui_eegtab_binepoch.post.Value=0;
        gui_eegtab_binepoch.whole.Value=0;
        gui_eegtab_binepoch.custom.Value=0;
        gui_eegtab_binepoch.custom_edit.Enable = 'off';
        gui_eegtab_binepoch.custom_edit.String = '';
    end

%%----------------Setting for "pre"-----------------------------------------
    function pre_eeg(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=6
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        %%change color for cancel and apply
        gui_eegtab_binepoch.apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_binepoch.apply.ForegroundColor = [1 1 1];
        EEG_binepoch_box.TitleColor= [0.5137    0.7569    0.9176];
        gui_eegtab_binepoch.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_binepoch.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_binepoch',1);
        gui_eegtab_binepoch.none.Value =0;
        gui_eegtab_binepoch.pre.Value=1;
        gui_eegtab_binepoch.post.Value=0;
        gui_eegtab_binepoch.whole.Value=0;
        gui_eegtab_binepoch.custom.Value=0;
        gui_eegtab_binepoch.custom_edit.Enable = 'off';
        gui_eegtab_binepoch.custom_edit.String = '';
    end


%%----------------Setting for "post"-----------------------------------------
    function post_eeg(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=6
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        %%change color for cancel and apply
        gui_eegtab_binepoch.apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_binepoch.apply.ForegroundColor = [1 1 1];
        EEG_binepoch_box.TitleColor= [0.5137    0.7569    0.9176];
        gui_eegtab_binepoch.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_binepoch.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_binepoch',1);
        
        gui_eegtab_binepoch.none.Value =0;
        gui_eegtab_binepoch.pre.Value=0;
        gui_eegtab_binepoch.post.Value=1;
        gui_eegtab_binepoch.whole.Value=0;
        gui_eegtab_binepoch.custom.Value=0;
        gui_eegtab_binepoch.custom_edit.Enable = 'off';
        gui_eegtab_binepoch.custom_edit.String = '';
    end

%%----------------Setting for "whole"-----------------------------------------
    function whole_eeg(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=6
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        %%change color for cancel and apply
        gui_eegtab_binepoch.apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_binepoch.apply.ForegroundColor = [1 1 1];
        EEG_binepoch_box.TitleColor= [0.5137    0.7569    0.9176];
        gui_eegtab_binepoch.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_binepoch.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_binepoch',1);
        gui_eegtab_binepoch.none.Value =0;
        gui_eegtab_binepoch.pre.Value=0;
        gui_eegtab_binepoch.post.Value=0;
        gui_eegtab_binepoch.whole.Value=1;
        gui_eegtab_binepoch.custom.Value=0;
        gui_eegtab_binepoch.custom_edit.Enable = 'off';
        gui_eegtab_binepoch.custom_edit.String = '';
    end

%%----------------Setting for "custom"-----------------------------------------
    function custom_eeg(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=6
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        %%change color for cancel and apply
        gui_eegtab_binepoch.apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_binepoch.apply.ForegroundColor = [1 1 1];
        EEG_binepoch_box.TitleColor= [0.5137    0.7569    0.9176];
        gui_eegtab_binepoch.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_binepoch.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_binepoch',1);
        gui_eegtab_binepoch.none.Value =0;
        gui_eegtab_binepoch.pre.Value=0;
        gui_eegtab_binepoch.post.Value=0;
        gui_eegtab_binepoch.whole.Value=0;
        gui_eegtab_binepoch.custom.Value=1;
        gui_eegtab_binepoch.custom_edit.Enable = 'on';
    end

%%-----------------------Custom baseline period----------------------------
    function precustom_edit(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=6
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        %%change color for cancel and apply
        gui_eegtab_binepoch.apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_binepoch.apply.ForegroundColor = [1 1 1];
        EEG_binepoch_box.TitleColor= [0.5137    0.7569    0.9176];
        gui_eegtab_binepoch.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_binepoch.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_binepoch',1);
        
        %%check the time period for the epoch
        EpochRange = str2num(gui_eegtab_binepoch.timerange_edit.String);
        if isempty(EpochRange)
            beep;
            msgboxText =  ['Extract Bin-Based Epochs (Continuous EEG) - Invalid input for "Time range"'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            gui_eegtab_binepoch.timerange_edit.String = '';
            return;
        end
        if numel(EpochRange) ~=2
            beep;
            msgboxText =  ['Extract Bin-Based Epochs (Continuous EEG) - Wrong time range for the epoch. Please, enter two values'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            gui_eegtab_binepoch.timerange_edit.String = '';
            return;
        end
        
        if EpochRange(1)>= EpochRange(2)
            beep;
            msgboxText =  ['Extract Bin-Based Epochs (Continuous EEG) - The first value must be smaller than the second one for time range'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            gui_eegtab_binepoch.timerange_edit.String = '';
            return;
        end
        
        if EpochRange(2) > observe_EEGDAT.EEG.times(end)
            msgboxText =  ['Extract Bin-Based Epochs (Continuous EEG) - Second value must be smaller than',32,num2str(observe_EEGDAT.EEG.times(end)),32,'for time range'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            gui_eegtab_binepoch.timerange_edit.String = '';
            return;
        end
        
        Baselineperiod = str2num(Source.String);
        %%check the defined baseline period
        if isempty(Baselineperiod)
            beep;
            msgboxText =  ['Extract Bin-Based Epochs (Continuous EEG) - Invalid input for "baseline period"'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            gui_eegtab_binepoch.custom_edit.String = '';
            return;
        end
        if numel(Baselineperiod) ~=2
            beep;
            msgboxText =  ['Extract Bin-Based Epochs (Continuous EEG) - Wrong baseline period for the epoch. Please, enter two values'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            gui_eegtab_binepoch.custom_edit.String = '';
            return;
        end
        
        if Baselineperiod(1)>= Baselineperiod(2)
            beep;
            msgboxText =  ['Extract Bin-Based Epochs (Continuous EEG) - The first value must be smaller than the second one for "baseline period"'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            gui_eegtab_binepoch.custom_edit.String = '';
            return;
        end
        
        if Baselineperiod(2) > EpochRange(2)
            msgboxText =  ['Extract Bin-Based Epochs (Continuous EEG) - Second value must be smaller than',32,num2str(EpochRange(2)),32,"baseline period"];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            gui_eegtab_binepoch.custom_edit.String = '';
            return;
        end
        if Baselineperiod(1) < EpochRange(1)
            msgboxText =  ['Extract Bin-Based Epochs (Continuous EEG) - First value must be larger than',32,num2str(EpochRange(1)),32,"baseline period"];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            gui_eegtab_binepoch.custom_edit.String = '';
            return;
        end
    end

%%--------------------------Setting for plot-------------------------------
    function apply_blc_dt(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=6
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        %%-------------loop start for filtering the selected ERPsets-----------------------------------
        erpworkingmemory('f_EEG_proces_messg','Extract Bin-Based Epochs (Continuous EEG) > Apply');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        gui_eegtab_binepoch.apply.BackgroundColor =  [1 1 1];
        gui_eegtab_binepoch.apply.ForegroundColor = [0 0 0];
        EEG_binepoch_box.TitleColor= [0.0500    0.2500    0.5000];
        gui_eegtab_binepoch.cancel.BackgroundColor =  [1 1 1];
        gui_eegtab_binepoch.cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('EEGTab_binepoch',0);
        
        %%check the time period for the epoch
        EpochRange = str2num(gui_eegtab_binepoch.timerange_edit.String);
        if isempty(EpochRange)
            beep;
            msgboxText =  ['Extract Bin-Based Epochs (Continuous EEG) > Apply - Invalid input for "Time range"'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            gui_eegtab_binepoch.timerange_edit.String = '';
            return;
        end
        if numel(EpochRange) ~=2
            beep;
            msgboxText =  ['Extract Bin-Based Epochs (Continuous EEG) >  Apply - Wrong time range for the epoch. Please, enter two values'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            gui_eegtab_binepoch.timerange_edit.String = '';
            return;
        end
        
        if EpochRange(1)>= EpochRange(2)
            beep;
            msgboxText =  ['Extract Bin-Based Epochs (Continuous EEG) > Apply - The first value must be smaller than the second one for time range'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            gui_eegtab_binepoch.timerange_edit.String = '';
            return;
        end
        
        if EpochRange(2) > observe_EEGDAT.EEG.times(end)
            msgboxText =  ['Extract Bin-Based Epochs (Continuous EEG) > Apply - Second value must be smaller than',32,num2str(observe_EEGDAT.EEG.times(end)),32,'for time range'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            gui_eegtab_binepoch.timerange_edit.String = '';
            return;
        end
        
        %%Check the baseline period defined by the custom.
        if gui_eegtab_binepoch.custom.Value ==1
            Baselineperiod = str2num(gui_eegtab_binepoch.custom_edit.String);
            %%check the defined baseline period
            if isempty(Baselineperiod)
                beep;
                msgboxText =  ['Extract Bin-Based Epochs (Continuous EEG) > Apply - Invalid input for "baseline period"'];
                erpworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.eeg_panel_message =4;
                gui_eegtab_binepoch.custom_edit.String = '';
                return;
            end
            if numel(Baselineperiod) ~=2
                beep;
                msgboxText =  ['Extract Bin-Based Epochs (Continuous EEG) > Apply - Wrong baseline period for the epoch. Please, enter two values'];
                erpworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.eeg_panel_message =4;
                gui_eegtab_binepoch.custom_edit.String = '';
                return;
            end
            if Baselineperiod(1)>= Baselineperiod(2)
                beep;
                msgboxText =  ['Extract Bin-Based Epochs (Continuous EEG) > Apply - The first value must be smaller than the second one for "baseline period"'];
                erpworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.eeg_panel_message =4;
                gui_eegtab_binepoch.custom_edit.String = '';
                return;
            end
            if Baselineperiod(2) > EpochRange(2)
                msgboxText =  ['Extract Bin-Based Epochs (Continuous EEG) > Apply - Second value must be smaller than',32,num2str(EpochRange(2)),32,"baseline period"];
                erpworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.eeg_panel_message =4;
                gui_eegtab_binepoch.custom_edit.String = '';
                return;
            end
            if Baselineperiod(1) < EpochRange(1)
                msgboxText =  ['Extract Bin-Based Epochs (Continuous EEG) Apply - First value must be larger than',32,num2str(EpochRange(1)),32,"baseline period"];
                erpworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.eeg_panel_message =4;
                gui_eegtab_binepoch.custom_edit.String = '';
                return;
            end
        end
        
        try
            if gui_eegtab_binepoch.none.Value==1
                BaselineMethod = 'none';
            elseif gui_eegtab_binepoch.pre.Value==1
                BaselineMethod = 'pre';
            elseif  gui_eegtab_binepoch.post.Value==1
                BaselineMethod = 'post';
            elseif  gui_eegtab_binepoch.whole.Value==1
                BaselineMethod = 'all';
            elseif  gui_eegtab_binepoch.custom.Value ==1
                BaselineMethod = str2num(gui_eegtab_binepoch.custom_edit.String);
            end
        catch
            BaselineMethod = 'pre';
        end
        %%save the changed parameters to memory file
        erpworkingmemory('pop_epochbin',{EpochRange,BaselineMethod});
        
        %%--------Selected EEGsets-----------
        EEGArray= estudioworkingmemory('EEGArray');
        if isempty(EEGArray) || min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) || max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG)
            EEGArray = observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',EEGArray);
        end
        ALLEEG = observe_EEGDAT.ALLEEG;
        
        Answer = f_EEG_save_multi_file(ALLEEG,EEGArray,'_be');
        if isempty(Answer)
            return;
        end
        if ~isempty(Answer{1})
            ALLEEG_advance = Answer{1};
            Save_file_label = Answer{2};
        end
        
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG_advance(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['**Your current EEGset(No.',num2str(EEGArray(Numofeeg)),')**\n',32,EEG.setname,'\n']);
            %%epoch EEG data
            [EEG, LASTCOM] = pop_epochbin( EEG , EpochRange, BaselineMethod, 'History', 'implicit');
            if isempty(LASTCOM)
                return;
            end
            fprintf([LASTCOM,'\n']);
            EEG = eegh(LASTCOM, EEG);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            erpworkingmemory('Change2epocheeg',1);%%force the option to be Epoched EEG in "EEGsets" panel
            
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
            if Numofeeg==1
                eegh(LASTCOM);
            end
            fprintf( [repmat('-',1,100) '\n']);
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


%%-----------------Setting for save option---------------------------------
    function Cancel_binepoch(~,~)
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=6
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_binepoch',0);
        gui_eegtab_binepoch.apply.BackgroundColor =  [1 1 1];
        gui_eegtab_binepoch.apply.ForegroundColor = [0 0 0];
        EEG_binepoch_box.TitleColor= [0.0500    0.2500    0.5000];
        gui_eegtab_binepoch.cancel.BackgroundColor =  [1 1 1];
        gui_eegtab_binepoch.cancel.ForegroundColor = [0 0 0];
        
        if  isempty(observe_EEGDAT.EEG)
            Enable_Label = 'off';
        else
            if isempty(observe_EEGDAT.EEG.data)|| ~isfield(observe_EEGDAT.EEG,'EVENTLIST') || ~isfield(observe_EEGDAT.EEG.EVENTLIST,'eventinfo') || ~isfield(observe_EEGDAT.EEG.EVENTLIST.eventinfo,'binlabel')
                Enable_Label = 'off';
            else
                Enable_Label = 'on';
            end
        end
        gui_eegtab_binepoch.timerange_edit.Enable = Enable_Label;
        gui_eegtab_binepoch.none.Enable= Enable_Label;
        gui_eegtab_binepoch.pre.Enable= Enable_Label;
        gui_eegtab_binepoch.post.Enable= Enable_Label;
        gui_eegtab_binepoch.whole.Enable= Enable_Label;
        gui_eegtab_binepoch.custom.Enable= Enable_Label;
        gui_eegtab_binepoch.custom_edit.Enable= Enable_Label;
        gui_eegtab_binepoch.cancel.Enable= Enable_Label;
        gui_eegtab_binepoch.apply.Enable= Enable_Label;
        if ~isempty(observe_EEGDAT.EEG) && strcmpi(Enable_Label,'on') && gui_eegtab_binepoch.custom.Value==1
            gui_eegtab_binepoch.custom_edit.Enable = 'on';
        else
            gui_eegtab_binepoch.custom_edit.Enable = 'off';
        end
        
        def  = erpworkingmemory('pop_epochbin');
        if isempty(def)
            def = {[-200 800]  'pre'};
        end
        if isnumeric(def{1}) && numel(def{1})==2
            gui_eegtab_binepoch.timerange_edit.String = num2str(def{1});
        else
            gui_eegtab_binepoch.timerange_edit.String = '';
        end
        try
            BaelineMethod = def{2};
        catch
            BaelineMethod = 'pre';
        end
        if isempty(BaelineMethod)
            BaelineMethod = 'pre';
        end
        if numel(BaelineMethod)==2
            noneFlag = 0;
            preFlag = 0;
            postFlag = 0;
            wholeFlag = 0;
            customFlag = 1;
            if numel(BaelineMethod)~=2
                BaelineMethod = 'pre';
                noneFlag = 0;
                preFlag = 1;
                postFlag = 0;
                wholeFlag = 0;
                customFlag = 0;
            end
        else
            if strcmpi(BaelineMethod,'none')
                noneFlag = 1;
                preFlag = 0;
                postFlag = 0;
                wholeFlag = 0;
                customFlag = 0;
            elseif strcmpi(BaelineMethod,'pre')
                noneFlag = 0;
                preFlag = 1;
                postFlag = 0;
                wholeFlag = 0;
                customFlag = 0;
            elseif strcmpi(BaelineMethod,'post')
                noneFlag = 0;
                preFlag = 0;
                postFlag = 1;
                wholeFlag = 0;
                customFlag = 0;
            elseif  strcmpi(BaelineMethod,'whole') || strcmpi(BaelineMethod,'all')
                noneFlag = 0;
                preFlag = 0;
                postFlag = 0;
                wholeFlag = 1;
                customFlag = 0;
            else
                noneFlag = 0;
                preFlag = 1;
                postFlag = 0;
                wholeFlag = 0;
                customFlag = 0;
            end
        end
        gui_eegtab_binepoch.none.Value =noneFlag;
        gui_eegtab_binepoch.pre.Value=preFlag;
        gui_eegtab_binepoch.post.Value=postFlag;
        gui_eegtab_binepoch.whole.Value=wholeFlag;
        gui_eegtab_binepoch.custom.Value=customFlag;
        gui_eegtab_binepoch.custom_edit.Enable = 'off';
        if customFlag==1
            gui_eegtab_binepoch.custom_edit.String = num2str(BaelineMethod);
        else
            gui_eegtab_binepoch.custom_edit.String ='';
        end
    end


%%-------------------Setting for the whole panel of fitering based on ALLERP and CURRENTERP--------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=18
            return;
        end
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials~=1
            if ~isempty(observe_EEGDAT.EEG) && observe_EEGDAT.EEG.trials~=1
                EEG_binepoch_box.TitleColor= [0.7500    0.7500    0.75000];
            else
                EEG_binepoch_box.TitleColor= [0.0500    0.2500    0.5000];
            end
            Enable_Label = 'off';
        else
            if isempty(observe_EEGDAT.EEG.data)|| ~isfield(observe_EEGDAT.EEG,'EVENTLIST') || ~isfield(observe_EEGDAT.EEG.EVENTLIST,'eventinfo') || ~isfield(observe_EEGDAT.EEG.EVENTLIST.eventinfo,'binlabel')
                Enable_Label = 'off';
            else
                Enable_Label = 'on';
            end
            EEG_binepoch_box.TitleColor= [0.0500    0.2500    0.5000];
        end
        gui_eegtab_binepoch.timerange_edit.Enable = Enable_Label;
        gui_eegtab_binepoch.none.Enable= Enable_Label;
        gui_eegtab_binepoch.pre.Enable= Enable_Label;
        gui_eegtab_binepoch.post.Enable= Enable_Label;
        gui_eegtab_binepoch.whole.Enable= Enable_Label;
        gui_eegtab_binepoch.custom.Enable= Enable_Label;
        gui_eegtab_binepoch.custom_edit.Enable= Enable_Label;
        gui_eegtab_binepoch.cancel.Enable= Enable_Label;
        gui_eegtab_binepoch.apply.Enable= Enable_Label;
        if ~isempty(observe_EEGDAT.EEG) && strcmpi(Enable_Label,'on') && gui_eegtab_binepoch.custom.Value==1
            gui_eegtab_binepoch.custom_edit.Enable = 'on';
        else
            gui_eegtab_binepoch.custom_edit.Enable = 'off';
        end
        observe_EEGDAT.count_current_eeg =19;
    end

%%--------------press return to execute "Apply"----------------------------
    function eeg_binepoch_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('EEGTab_binepoch');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            apply_blc_dt();
            estudioworkingmemory('EEGTab_binepoch',0);
            gui_eegtab_binepoch.apply.BackgroundColor =  [1 1 1];
            gui_eegtab_binepoch.apply.ForegroundColor = [0 0 0];
            EEG_binepoch_box.TitleColor= [0.0500    0.2500    0.5000];
            gui_eegtab_binepoch.cancel.BackgroundColor =  [1 1 1];
            gui_eegtab_binepoch.cancel.ForegroundColor = [0 0 0];
        else
            return;
        end
    end

%%-------------------Auomatically execute "apply"--------------------------
%     function eeg_two_panels_change(~,~)
%         if  isempty(observe_EEGDAT.EEG)
%             return;
%         end
%         ChangeFlag =  estudioworkingmemory('EEGTab_binepoch');
%         if ChangeFlag~=1
%             return;
%         end
%         apply_blc_dt();
%         estudioworkingmemory('EEGTab_binepoch',0);
%         gui_eegtab_binepoch.apply.BackgroundColor =  [1 1 1];
%         gui_eegtab_binepoch.apply.ForegroundColor = [0 0 0];
%         EEG_binepoch_box.TitleColor= [0.0500    0.2500    0.5000];
%         gui_eegtab_binepoch.cancel.BackgroundColor =  [1 1 1];
%         gui_eegtab_binepoch.cancel.ForegroundColor = [0 0 0];
%     end

%%--------------Reset this panel with the default parameters---------------
    function Reset_eeg_panel_change(~,~)
        if observe_EEGDAT.Reset_eeg_paras_panel~=15
            return;
        end
        estudioworkingmemory('EEGTab_binepoch',0);
        gui_eegtab_binepoch.apply.BackgroundColor =  [1 1 1];
        gui_eegtab_binepoch.apply.ForegroundColor = [0 0 0];
        gui_eegtab_binepoch.cancel.BackgroundColor =  [1 1 1];
        gui_eegtab_binepoch.cancel.ForegroundColor = [0 0 0];
        gui_eegtab_binepoch.timerange_edit.String = '-200 800';
        gui_eegtab_binepoch.none.Value =0;
        gui_eegtab_binepoch.pre.Value=1;
        gui_eegtab_binepoch.post.Value=0;
        gui_eegtab_binepoch.whole.Value=0;
        gui_eegtab_binepoch.custom.Value=0;
        gui_eegtab_binepoch.custom_edit.Enable = 'off';
        gui_eegtab_binepoch.custom_edit.String = '';
        erpworkingmemory('pop_epochbin',{[-200 800]  'pre'});
        observe_EEGDAT.Reset_eeg_paras_panel=16;
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
%Progem end: ERP Measurement tool