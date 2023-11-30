%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 2022 && Nov. 2023

% ERPLAB Studio

function varargout = f_ERP_baselinecorr_detrend_GUI(varargin)

global observe_ERPDAT;
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);
addlistener(observe_ERPDAT,'erp_two_panels_change',@erp_two_panels_change);


%%---------------------------gui-------------------------------------------
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    ERP_basecorr_detrend_box = uiextras.BoxPanel('Parent', fig, 'Title', 'Baseline Correction & Linear Detrend', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    ERP_basecorr_detrend_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Baseline Correction & Linear Detrend', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    ERP_basecorr_detrend_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Baseline Correction & Linear Detrend', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
end

gui_erp_blc_dt = struct();
try
    FonsizeDefault = varargin{2};
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
    FonsizeDefault = f_get_default_fontsize();
end
erp_blc_dt_gui(FonsizeDefault);
varargout{1} = ERP_basecorr_detrend_box;
%%********************Draw the GUI for ERP measurement tool*****************
    function erp_blc_dt_gui(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        
        Enable_label = 'off';
        gui_erp_blc_dt.blc_dt = uiextras.VBox('Parent',ERP_basecorr_detrend_box,'Spacing',1,'BackgroundColor',ColorB_def);
        
        %%Measurement type
        gui_erp_blc_dt.blc_dt_type_title = uiextras.HBox('Parent',  gui_erp_blc_dt.blc_dt,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', gui_erp_blc_dt.blc_dt_type_title,...
            'String','Type:','FontWeight','bold','FontSize',FonsizeDefault ,'BackgroundColor',ColorB_def);
        gui_erp_blc_dt.blc_dt_option = uiextras.HBox('Parent',  gui_erp_blc_dt.blc_dt,'Spacing',1,'BackgroundColor',ColorB_def);
        gui_erp_blc_dt.blc = uicontrol('Style', 'radiobutton','Parent', gui_erp_blc_dt.blc_dt_option,...
            'String','Baseline Correction','callback',@baseline_correction_erp,'Value',1,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_blc_dt.blcp.KeyPressFcn= @erp_blcorrdetrend_presskey;
        gui_erp_blc_dt.dt = uicontrol('Style', 'radiobutton','Parent', gui_erp_blc_dt.blc_dt_option,...
            'String','Linear detrend','callback',@detrend_erp,'Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_blc_dt.dt.KeyPressFcn= @erp_blcorrdetrend_presskey;
        gui_erp_blc_dt.ERPTab_baseline_detrend{1} = gui_erp_blc_dt.blc.Value;
        
        %%Baseline period: Pre, post whole custom
        gui_erp_blc_dt.blc_dt_baseline_period_title = uiextras.HBox('Parent',  gui_erp_blc_dt.blc_dt,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', gui_erp_blc_dt.blc_dt_baseline_period_title,...
            'String','Baseline Period:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        gui_erp_blc_dt.blc_dt_bp_option = uiextras.HBox('Parent',  gui_erp_blc_dt.blc_dt,'Spacing',1,'BackgroundColor',ColorB_def);
        gui_erp_blc_dt.pre = uicontrol('Style', 'radiobutton','Parent', gui_erp_blc_dt.blc_dt_bp_option,...
            'String','Pre','callback',@pre_erp,'Value',1,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_blc_dt.pre.KeyPressFcn= @erp_blcorrdetrend_presskey;
        gui_erp_blc_dt.post = uicontrol('Style', 'radiobutton','Parent', gui_erp_blc_dt.blc_dt_bp_option,...
            'String','Post','callback',@post_erp,'Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_blc_dt.post.KeyPressFcn= @erp_blcorrdetrend_presskey;
        gui_erp_blc_dt.whole = uicontrol('Style', 'radiobutton','Parent', gui_erp_blc_dt.blc_dt_bp_option,...
            'String','Whole','callback',@whole_erp,'Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_blc_dt.whole.KeyPressFcn= @erp_blcorrdetrend_presskey;
        gui_erp_blc_dt.blc_dt_bp_option_cust = uiextras.HBox('Parent',  gui_erp_blc_dt.blc_dt,'Spacing',1,'BackgroundColor',ColorB_def);
        gui_erp_blc_dt.custom = uicontrol('Style', 'radiobutton','Parent', gui_erp_blc_dt.blc_dt_bp_option_cust,...
            'String','Custom (ms) [start stop]','callback',@custom_erp,'Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_blc_dt.custom.KeyPressFcn= @erp_blcorrdetrend_presskey;
        gui_erp_blc_dt.custom_edit = uicontrol('Style', 'edit','Parent', gui_erp_blc_dt.blc_dt_bp_option_cust,...
            'String','','callback',@custom_edit,'Enable',Enable_label,'FontSize',FonsizeDefault);
        gui_erp_blc_dt.custom_edit.KeyPressFcn= @erp_blcorrdetrend_presskey;
        set(gui_erp_blc_dt.blc_dt_bp_option_cust, 'Sizes',[160  135]);
        if gui_erp_blc_dt.pre.Value==1
            gui_erp_blc_dt.ERPTab_baseline_detrend{2} = 1;
        elseif gui_erp_blc_dt.post.Value==1
            gui_erp_blc_dt.ERPTab_baseline_detrend{2} = 2;
        elseif gui_erp_blc_dt.whole.Value==1
            gui_erp_blc_dt.ERPTab_baseline_detrend{2} = 3;
        elseif gui_erp_blc_dt.custom.Value==1
            gui_erp_blc_dt.ERPTab_baseline_detrend{2} = str2num(gui_erp_blc_dt.custom_edit.String);
        else
            gui_erp_blc_dt.ERPTab_baseline_detrend{2} =1;
        end
        %%Bin and channels selection
        gui_erp_blc_dt.blc_dt_bin_chan_title = uiextras.HBox('Parent',  gui_erp_blc_dt.blc_dt,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', gui_erp_blc_dt.blc_dt_bin_chan_title,...
            'String','Bin and Chan Selection:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_blc_dt.blc_bin_chan_option = uiextras.HBox('Parent',  gui_erp_blc_dt.blc_dt,'Spacing',1,'BackgroundColor',ColorB_def);
        gui_erp_blc_dt.all_bin_chan = uicontrol('Style', 'radiobutton','Parent', gui_erp_blc_dt.blc_bin_chan_option,...
            'String','All(Recommended)','callback',@All_bin_chan,'Value',1,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_blc_dt.all_bin_chan.KeyPressFcn= @erp_blcorrdetrend_presskey;
        gui_erp_blc_dt.Selected_bin_chan = uicontrol('Style', 'radiobutton','Parent', gui_erp_blc_dt.blc_bin_chan_option,...
            'String','Selected bin & chan','callback',@Selected_bin_chan,'Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_blc_dt.Selected_bin_chan.KeyPressFcn= @erp_blcorrdetrend_presskey;
        set(gui_erp_blc_dt.blc_bin_chan_option, 'Sizes',[125  175]);
        gui_erp_blc_dt.ERPTab_baseline_detrend{3} = gui_erp_blc_dt.all_bin_chan.Value;
        %%Cancel and advanced
        gui_erp_blc_dt.other_option = uiextras.HBox('Parent',gui_erp_blc_dt.blc_dt,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', gui_erp_blc_dt.other_option,'BackgroundColor',ColorB_def);
        gui_erp_blc_dt.Cancel = uicontrol('Parent',gui_erp_blc_dt.other_option,'Style','pushbutton',...
            'String','Cancel','callback',@Cancel_blc_dt,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', gui_erp_blc_dt.other_option);
        gui_erp_blc_dt.apply = uicontrol('Style','pushbutton','Parent',gui_erp_blc_dt.other_option,...
            'String','Apply','callback',@apply_blc_dt,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', gui_erp_blc_dt.other_option);
        set(gui_erp_blc_dt.other_option, 'Sizes',[15 105  30 105 15]);
        
        set(gui_erp_blc_dt.blc_dt,'Sizes',[18 25 15 25 25 15 25 30]);
        
        estudioworkingmemory('ERPTab_baseline_detrend',0);
    end
%%*************************************************************************
%%*******************   Subfunctions   ************************************
%%*************************************************************************

%%--------------------------------setting for amplitude--------------------
    function  baseline_correction_erp(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=4
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_blc_dt.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_blc_dt.apply.ForegroundColor = [1 1 1];
        ERP_basecorr_detrend_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_blc_dt.Cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_blc_dt.Cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_baseline_detrend',1);
        gui_erp_blc_dt.blc.Value =1;
        gui_erp_blc_dt.dt.Value = 0;
    end

%%--------------------------Setting for phase------------------------------
    function detrend_erp(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=4
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_blc_dt.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_blc_dt.apply.ForegroundColor = [1 1 1];
        ERP_basecorr_detrend_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_blc_dt.Cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_blc_dt.Cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_baseline_detrend',1);
        gui_erp_blc_dt.dt.Value = 1;
        gui_erp_blc_dt.blc.Value =0;
    end

%%----------------Setting for "pre"----------------------------------------
    function pre_erp(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=4
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_blc_dt.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_blc_dt.apply.ForegroundColor = [1 1 1];
        ERP_basecorr_detrend_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_blc_dt.Cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_blc_dt.Cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_baseline_detrend',1);
        gui_erp_blc_dt.pre.Value=1;
        gui_erp_blc_dt.post.Value=0;
        gui_erp_blc_dt.whole.Value=0;
        gui_erp_blc_dt.custom.Value=0;
        gui_erp_blc_dt.custom_edit.Enable = 'off';
        if observe_ERPDAT.ERP.times(1)>=0
            CUstom_String = '';
        else
            CUstom_String = num2str([observe_ERPDAT.ERP.times(1),0]);
        end
        gui_erp_blc_dt.custom_edit.String = CUstom_String;
    end


%%----------------Setting for "post"---------------------------------------
    function post_erp(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=4
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_blc_dt.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_blc_dt.apply.ForegroundColor = [1 1 1];
        ERP_basecorr_detrend_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_blc_dt.Cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_blc_dt.Cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_baseline_detrend',1);
        gui_erp_blc_dt.pre.Value=0;
        gui_erp_blc_dt.post.Value=1;
        gui_erp_blc_dt.whole.Value=0;
        gui_erp_blc_dt.custom.Value=0;
        gui_erp_blc_dt.custom_edit.Enable = 'off';
        if observe_ERPDAT.ERP.times(end)<=0
            CUstom_String = '';
        else
            CUstom_String = num2str([0 observe_ERPDAT.ERP.times(end)]);
        end
        gui_erp_blc_dt.custom_edit.String = CUstom_String;
    end

%%----------------Setting for "whole"--------------------------------------
    function whole_erp(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=4
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_blc_dt.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_blc_dt.apply.ForegroundColor = [1 1 1];
        ERP_basecorr_detrend_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_blc_dt.Cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_blc_dt.Cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_baseline_detrend',1);
        gui_erp_blc_dt.pre.Value=0;
        gui_erp_blc_dt.post.Value=0;
        gui_erp_blc_dt.whole.Value=1;
        gui_erp_blc_dt.custom.Value=0;
        gui_erp_blc_dt.custom_edit.Enable = 'off';
        CUstom_String = num2str([observe_ERPDAT.ERP.times(1) observe_ERPDAT.ERP.times(end)]);
        gui_erp_blc_dt.custom_edit.String = CUstom_String;
    end

%%----------------Setting for "custom"-------------------------------------
    function custom_erp(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=4
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_blc_dt.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_blc_dt.apply.ForegroundColor = [1 1 1];
        ERP_basecorr_detrend_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_blc_dt.Cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_blc_dt.Cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_baseline_detrend',1);
        gui_erp_blc_dt.pre.Value=0;
        gui_erp_blc_dt.post.Value=0;
        gui_erp_blc_dt.whole.Value=0;
        gui_erp_blc_dt.custom.Value=1;
        gui_erp_blc_dt.custom_edit.Enable = 'on';
    end

%%----------------input baseline period defined by user--------------------
    function custom_edit(Source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=4
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_blc_dt.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_blc_dt.apply.ForegroundColor = [1 1 1];
        ERP_basecorr_detrend_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_blc_dt.Cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_blc_dt.Cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_baseline_detrend',1);
        
        lat_osci = str2num(Source.String);
        if isempty(lat_osci)
            msgboxText =  ['Baseline Correction & Linear Detrend - Invalid input for "baseline range"'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        if numel(lat_osci) ==1
            msgboxText =  ['Baseline Correction & Linear Detrend - Wrong baseline range. Please, enter two values'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        if lat_osci(1)>= lat_osci(2)
            msgboxText =  ['Baseline Correction & Linear Detrend - The first value must be smaller than the second one'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        if lat_osci(2) > observe_ERPDAT.ERP.times(end)
            msgboxText =  ['Baseline Correction & Linear Detrend - Second value must be smaller than',32,num2str(observe_ERPDAT.ERP.times(end))];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        if lat_osci(1) < observe_ERPDAT.ERP.times(1)
            msgboxText =  ['Baseline Correction & Linear Detrend - First value must be larger than',32,num2str(observe_ERPDAT.ERP.times(1))];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
    end

%%---------------------Setting for all chan and bin------------------------
    function All_bin_chan(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=4
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_blc_dt.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_blc_dt.apply.ForegroundColor = [1 1 1];
        ERP_basecorr_detrend_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_blc_dt.Cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_blc_dt.Cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_baseline_detrend',1);
        gui_erp_blc_dt.all_bin_chan.Value = 1;
        gui_erp_blc_dt.Selected_bin_chan.Value = 0;
    end

%%----------------Setting for selected bin and chan------------------------
    function Selected_bin_chan(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=4
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_blc_dt.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_blc_dt.apply.ForegroundColor = [1 1 1];
        ERP_basecorr_detrend_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_blc_dt.Cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_blc_dt.Cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_baseline_detrend',1);
        gui_erp_blc_dt.all_bin_chan.Value = 0;
        gui_erp_blc_dt.Selected_bin_chan.Value = 1;
    end
%%--------------------------Setting for plot-------------------------------
    function apply_blc_dt(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=4
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        Selected_erpset =  estudioworkingmemory('selectederpstudio');
        if isempty(Selected_erpset)
            Selected_erpset =  length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = Selected_erpset;
            estudioworkingmemory('selectederpstudio',Selected_erpset);
        end
        try
            if gui_erp_blc_dt.pre.Value==1
                BaselineMethod = 'pre';
            elseif  gui_erp_blc_dt.post.Value==1
                BaselineMethod = 'post';
            elseif  gui_erp_blc_dt.whole.Value==1
                BaselineMethod = 'all';
            elseif  gui_erp_blc_dt.custom.Value ==1
                BaselineMethod = str2num(gui_erp_blc_dt.custom_edit.String);
            end
        catch
            BaselineMethod = 'pre';
        end
        %%Check the baseline period defined by the custom.
        if gui_erp_blc_dt.custom.Value ==1
            if isempty(BaselineMethod)
                msgboxText =  ['Baseline Correction & Linear Detrend - Invalid input for baseline range; Please Cancel two values'];
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            if numel(BaselineMethod) ==1
                msgboxText =  ['Baseline Correction & Linear Detrend - Wrong baseline range. Please, enter two values'];
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            if BaselineMethod(1)>= BaselineMethod(2)
                msgboxText =  ['Baseline Correction & Linear Detrend - The first value must be smaller than the second one'];
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            if roundn(BaselineMethod(2),-3) > roundn(observe_ERPDAT.ERP.times(end),-3)
                msgboxText =  ['Baseline Correction & Linear Detrend - Second value must be smaller than',32,num2str(observe_ERPDAT.ERP.times(end))];
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            if roundn(BaselineMethod(1),-3) < roundn(observe_ERPDAT.ERP.times(1),-3)
                msgboxText =  ['Baseline Correction & Linear Detrend - First value must be larger than',32,num2str(observe_ERPDAT.ERP.times(1))];
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
        end
        %%Run the function based on the defined parameters
        Check_Selected_erpset = [0 0 0 0 0 0 0];
        if numel(Selected_erpset)>1
            Check_Selected_erpset = f_checkerpsets(observe_ERPDAT.ALLERP,Selected_erpset);
        end
        %%--------------Loop start for removeing baseline for the selected ERPsets------------
        if gui_erp_blc_dt.dt.Value ==1
            Suffix_str = char(strcat('detrend'));
        else
            Suffix_str = char(strcat('baselinecorr'));
        end
        if numel(Selected_erpset)>1
            if gui_erp_blc_dt.dt.Value ==1
                Suffix_str = char(strcat('detrend'));
            else
                Suffix_str = char(strcat('baselinecorr'));
            end
            Answer = f_ERP_save_multi_file(observe_ERPDAT.ALLERP,Selected_erpset,Suffix_str);
            if isempty(Answer)
                beep;
                disp('User selected Cancel');
                return;
            end
            if ~isempty(Answer{1})
                ALLERP_advance = Answer{1};
                Save_file_label = Answer{2};
            end
            
        elseif numel(Selected_erpset)==1
            Save_file_label = 0;
            ALLERP_advance = observe_ERPDAT.ALLERP;
        end
        
        %%%%-------------------Loop fpor baseline correction---------------
        erpworkingmemory('f_ERP_proces_messg','Baseline correction & Linear detrend');
        observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
        
        ALLERPCOM = evalin('base','ALLERPCOM');
        gui_erp_blc_dt.apply.BackgroundColor =  [ 1 1 1];
        gui_erp_blc_dt.apply.ForegroundColor = [0 0 0];
        ERP_basecorr_detrend_box.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_blc_dt.Cancel.BackgroundColor =  [1 1 1];
        gui_erp_blc_dt.Cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_baseline_detrend',0);
        
        gui_erp_blc_dt.ERPTab_baseline_detrend{1} = gui_erp_blc_dt.blc.Value;
        if gui_erp_blc_dt.pre.Value==1
            gui_erp_blc_dt.ERPTab_baseline_detrend{2} = 1;
        elseif gui_erp_blc_dt.post.Value==1
            gui_erp_blc_dt.ERPTab_baseline_detrend{2} = 2;
        elseif gui_erp_blc_dt.whole.Value==1
            gui_erp_blc_dt.ERPTab_baseline_detrend{2} = 3;
        elseif gui_erp_blc_dt.custom.Value==1
            gui_erp_blc_dt.ERPTab_baseline_detrend{2} = str2num(gui_erp_blc_dt.custom_edit.String);
        else
            gui_erp_blc_dt.ERPTab_baseline_detrend{2} =1;
        end
        gui_erp_blc_dt.ERPTab_baseline_detrend{3} = gui_erp_blc_dt.all_bin_chan.Value;
        
        
        BinArray = [];
        ChanArray = [];
        for Numoferp = 1:numel(Selected_erpset)
            ERP = observe_ERPDAT.ALLERP(Selected_erpset(Numoferp));
            if (Check_Selected_erpset(1)==1 || Check_Selected_erpset(2)==2) && gui_erp_blc_dt.Selected_bin_chan.Value ==1
                if Check_Selected_erpset(1) ==1
                    msgboxText =  ['Number of bins across the selected ERPsets is different!'];
                elseif Check_Selected_erpset(2)==2
                    msgboxText =  ['Number of channels across the selected ERPsets is different!'];
                elseif Check_Selected_erpset(1)==1 && Check_Selected_erpset(2)==2
                    msgboxText =  ['Number of channels and bins vary across the selected ERPsets'];
                end
                question = [  '%s\n\n "All" will be active instead of "Selected bin and chan".'];
                title       = 'EStudio: Baseline correction & linear detrend';
                button      = questdlg(sprintf(question, msgboxText), title,'OK','OK');
                BinArray = [];
                ChanArray = [];
            end
            
            if (Check_Selected_erpset(1)==0 && Check_Selected_erpset(2)==0) && gui_erp_blc_dt.Selected_bin_chan.Value ==1
                try
                    BinArray =  estudioworkingmemory('ERP_BinArray');
                    ChanArray = estudioworkingmemory('ERP_ChanArray');
                    [chk, msgboxText] = f_ERP_chckbinandchan(ERP, BinArray, [],1);
                    if chk(1)==1
                        BinArray =  [1:ERP.nbin];
                    end
                    [chk, msgboxText] = f_ERP_chckbinandchan(ERP,[], ChanArray,2);
                    if chk(2)==1
                        ChanArray =  [1:ERP.nchan];
                    end
                catch
                    BinArray = [1:ERP.nbin];
                    ChanArray = [1:ERP.nchan];
                end
            end
            
            if gui_erp_blc_dt.all_bin_chan.Value == 1
                BinArray = [1:ERP.nbin];
                ChanArray = [1:ERP.nchan];
            end
            
            
            if gui_erp_blc_dt.dt.Value ==1
                [ERP ERPCOM] = pop_erplindetrend( ERP, BaselineMethod , 'Saveas', 'off','History','gui');
            else
                [ERP ERPCOM]= pop_blcerp( ERP , 'Baseline', BaselineMethod, 'Saveas', 'off','History','gui');
            end
            [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
            if Numoferp ==1
                [~, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);
            end
            
            %%Only the slected bin and chan were selected to remove baseline and detrending and others are remiained.
            if ~isempty(BinArray)
                ERP_before_bl = ALLERP_advance(Selected_erpset(Numoferp));
                ERP_before_bl.bindata(ChanArray,:,BinArray) = ERP.bindata(ChanArray,:,BinArray);
                ERP_before_bl.history = ERP.history;
                ERP = ERP_before_bl;
            end
            
            if numel(Selected_erpset) ==1
                Answer = f_ERP_save_single_file(strcat(ERP.erpname,'_',Suffix_str),ERP.filename,Selected_erpset(Numoferp));
                if isempty(Answer)
                    beep;
                    disp('User selectd cancal');
                    return;
                end
                
                if ~isempty(Answer)
                    ERPName = Answer{1};
                    if ~isempty(ERPName)
                        ERP.erpname = ERPName;
                    end
                    fileName_full = Answer{2};
                    if isempty(fileName_full)
                        ERP.filename = ERP.erpname;
                    elseif ~isempty(fileName_full)
                        
                        [pathstr, file_name, ext] = fileparts(fileName_full);
                        ext = '.erp';
                        if strcmp(pathstr,'')
                            pathstr = cd;
                        end
                        ERP.filename = [file_name,ext];
                        ERP.filepath = pathstr;
                        %%----------save the current sdata as--------------------
                        [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', ERP.filename, 'filepath',ERP.filepath);
                        [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                    end
                end
            end
            
            if Save_file_label
                [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', ERP.filename, 'filepath',ERP.filepath);
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
            end
            observe_ERPDAT.ALLERP(length(observe_ERPDAT.ALLERP)+1) = ERP;
        end%%Loop end for the selected ERset
        
        erpworkingmemory('f_ERP_BLS_Detrend',{BaselineMethod,0,1});
        %%
        %             [~, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        try
            Selected_ERP_afd =  [length(observe_ERPDAT.ALLERP)-numel(Selected_erpset)+1:length(observe_ERPDAT.ALLERP)];
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP)-numel(Selected_erpset)+1;
        catch
            Selected_ERP_afd = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
        end
        
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
        estudioworkingmemory('selectederpstudio',Selected_ERP_afd);
        observe_ERPDAT.Count_currentERP = 1;
        observe_ERPDAT.Process_messg =2;
        observe_ERPDAT.Two_GUI = observe_ERPDAT.Two_GUI+1;
    end


%%-----------------Setting for save option---------------------------------
    function Cancel_blc_dt(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=4
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        try
            methodtype =   gui_erp_blc_dt.ERPTab_baseline_detrend{1};
        catch
            methodtype=1;
            gui_erp_blc_dt.ERPTab_baseline_detrend{1}=1;
        end
        if isempty(methodtype) || numel(methodtype)~=1 || (methodtype~=0 && methodtype~=1)
            methodtype=1;
            gui_erp_blc_dt.ERPTab_baseline_detrend{1}=1;
        end
        gui_erp_blc_dt.blc.Value =methodtype;
        gui_erp_blc_dt.dt.Value = ~methodtype;
        
        %%baseline period
        try
            bsperiod =   gui_erp_blc_dt.ERPTab_baseline_detrend{2};
        catch
            bsperiod=1;
            gui_erp_blc_dt.ERPTab_baseline_detrend{2}=1;
        end
        if isempty(bsperiod) || (numel(bsperiod)~=1 && numel(bsperiod)~=2)
            bsperiod=1;
            gui_erp_blc_dt.ERPTab_baseline_detrend{2}=1;
        end
        
        if numel(bsperiod)==1
            if bsperiod~=1 && bsperiod~=2 && bsperiod~=3
                bsperiod=1;
                gui_erp_blc_dt.ERPTab_baseline_detrend{2}=1;
            end
            if bsperiod==2
                gui_erp_blc_dt.pre.Value=0;
                gui_erp_blc_dt.post.Value=1;
                gui_erp_blc_dt.whole.Value=0;
            elseif   bsperiod==3
                gui_erp_blc_dt.pre.Value=0;
                gui_erp_blc_dt.post.Value=0;
                gui_erp_blc_dt.whole.Value=1;
            else
                gui_erp_blc_dt.pre.Value=1;
                gui_erp_blc_dt.post.Value=0;
                gui_erp_blc_dt.whole.Value=0;
            end
            gui_erp_blc_dt.custom.Value=0;
            gui_erp_blc_dt.custom_edit.Enable = 'off';
            gui_erp_blc_dt.custom_edit.String = '';
        elseif numel(bsperiod)==2
            gui_erp_blc_dt.pre.Value=0;
            gui_erp_blc_dt.post.Value=0;
            gui_erp_blc_dt.whole.Value=0;
            gui_erp_blc_dt.custom.Value=1;
            gui_erp_blc_dt.custom_edit.Enable = 'on';
            if any(bsperiod> observe_ERPDAT.ERP.times(end)) || any(bsperiod< observe_ERPDAT.ERP.times(1))
                bsperiod = [];
                gui_erp_blc_dt.ERPTab_baseline_detrend{2}=[];
            end
            gui_erp_blc_dt.custom_edit.String = num2str(bsperiod);
        end
        
        %%bin & chan selection
        try
            all_bin_chan = gui_erp_blc_dt.ERPTab_baseline_detrend{3};
        catch
            all_bin_chan=1;
        end
        if isempty(all_bin_chan) || numel(all_bin_chan)~=1 || (all_bin_chan~=0&& all_bin_chan~=1)
            gui_erp_blc_dt.ERPTab_baseline_detrend{3}=1;
            all_bin_chan=1;
        end
        gui_erp_blc_dt.all_bin_chan.Value = all_bin_chan;
        gui_erp_blc_dt.Selected_bin_chan.Value = ~all_bin_chan;
        
        
        estudioworkingmemory('ERPTab_baseline_detrend',0);
        gui_erp_blc_dt.apply.BackgroundColor =  [ 1 1 1];
        gui_erp_blc_dt.apply.ForegroundColor = [0 0 0];
        ERP_basecorr_detrend_box.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_blc_dt.Cancel.BackgroundColor =  [1 1 1];
        gui_erp_blc_dt.Cancel.ForegroundColor = [0 0 0];
    end


%%-------------------Setting for the whole panel of fitering based on ALLERP and CURRENTERP--------------
    function Count_currentERPChanged(~,~)
        if observe_ERPDAT.Count_currentERP~=5
            return;
        end
        ViewerFlag=erpworkingmemory('ViewerFlag');
        if  isempty(observe_ERPDAT.ERP) || ~strcmp(observe_ERPDAT.ERP.datatype,'ERP') || ViewerFlag==1
            Enable_Label = 'off';
        else
            Enable_Label = 'on';
        end
        gui_erp_blc_dt.blc.Enable = Enable_Label;
        gui_erp_blc_dt.dt.Enable = Enable_Label;
        gui_erp_blc_dt.apply.Enable = Enable_Label;
        gui_erp_blc_dt.Cancel.Enable = Enable_Label;
        gui_erp_blc_dt.pre.Enable= Enable_Label;
        gui_erp_blc_dt.post.Enable= Enable_Label;
        gui_erp_blc_dt.whole.Enable= Enable_Label;
        gui_erp_blc_dt.custom.Enable= Enable_Label;
        gui_erp_blc_dt.custom_edit.Enable = Enable_Label;
        gui_erp_blc_dt.apply.Enable = Enable_Label;
        gui_erp_blc_dt.Cancel.Enable = Enable_Label;
        gui_erp_blc_dt.all_bin_chan.Enable = Enable_Label;
        gui_erp_blc_dt.Selected_bin_chan.Enable = Enable_Label;
        if gui_erp_blc_dt.custom.Value==1
            gui_erp_blc_dt.custom_edit.Enable = 'on';
        else
            gui_erp_blc_dt.custom_edit.Enable = 'off';
        end
        if  isempty(observe_ERPDAT.ERP) || ~strcmp(observe_ERPDAT.ERP.datatype,'ERP')
            observe_ERPDAT.Count_currentERP=6;
            return;
        end
        Selected_erpset =  estudioworkingmemory('selectederpstudio');
        if isempty(Selected_erpset) || any(Selected_erpset> length(observe_ERPDAT.ALLERP))
            Selected_erpset =  length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            estudioworkingmemory('selectederpstudio',Selected_erpset);
            observe_ERPDAT.CURRENTERP = Selected_erpset;
        end
        Check_Selected_erpset = [0 0 0 0 0 0 0];
        if numel(Selected_erpset)>2
            Check_Selected_erpset = f_checkerpsets(observe_ERPDAT.ALLERP,Selected_erpset);
        end
        if Check_Selected_erpset(1) ==1 || Check_Selected_erpset(2) == 2
            gui_erp_blc_dt.all_bin_chan.Enable = 'on';
            gui_erp_blc_dt.Selected_bin_chan.Enable = 'off';
            gui_erp_blc_dt.all_bin_chan.Value = 1;
            gui_erp_blc_dt.Selected_bin_chan.Value = 0;
        end
        if gui_erp_blc_dt.custom.Value==1
            baseline = str2num(gui_erp_blc_dt.custom_edit.String);
            if ~isempty(baseline)
                if any(baseline>observe_ERPDAT.ERP.times(end)) || any(baseline<observe_ERPDAT.ERP.times(1))
                    gui_erp_blc_dt.custom_edit.String = '';
                end
            end
        end
        observe_ERPDAT.Count_currentERP=6;
    end


%%-------execute "apply" before doing any cnages for other panels----------
    function erp_two_panels_change(~,~)
        if  isempty(observe_ERPDAT.ALLERP)|| isempty(observe_ERPDAT.ERP)
            return;
        end
        ChangeFlag =  estudioworkingmemory('ERPTab_baseline_detrend');
        if ChangeFlag~=1
            return;
        end
        apply_blc_dt();
        estudioworkingmemory('ERPTab_baseline_detrend',0);
        gui_erp_blc_dt.apply.BackgroundColor =  [ 1 1 1];
        gui_erp_blc_dt.apply.ForegroundColor = [0 0 0];
        ERP_basecorr_detrend_box.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_blc_dt.Cancel.BackgroundColor =  [1 1 1];
        gui_erp_blc_dt.Cancel.ForegroundColor = [0 0 0];
    end


%%--------------press return to execute "Apply"----------------------------
    function erp_blcorrdetrend_presskey(~,eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('ERPTab_baseline_detrend');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            apply_blc_dt();
            estudioworkingmemory('ERPTab_baseline_detrend',0);
            gui_erp_blc_dt.apply.BackgroundColor =  [ 1 1 1];
            gui_erp_blc_dt.apply.ForegroundColor = [0 0 0];
            ERP_basecorr_detrend_box.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
            gui_erp_blc_dt.Cancel.BackgroundColor =  [1 1 1];
            gui_erp_blc_dt.Cancel.ForegroundColor = [0 0 0];
        else
            return;
        end
    end

end
%Progem end: ERP Measurement tool