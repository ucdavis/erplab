%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 2022 & Nov. 2023

% ERPLAB Studio

function varargout = f_ERP_spectral_GUI(varargin)

global observe_ERPDAT;
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);
addlistener(observe_ERPDAT,'erp_between_panels_change',@erp_between_panels_change);
addlistener(observe_ERPDAT,'Reset_erp_panel_change',@Reset_erp_panel_change);


defaulpar =  estudioworkingmemory('f_ERP_spectral');
defaulpar{1} = 0;defaulpar{2} = [];defaulpar{3} = [];defaulpar{4} = [];defaulpar{5} = [];
defaulpar{6} = [];defaulpar{7} = [];
estudioworkingmemory('f_ERP_spectral',defaulpar);
%%---------------------------gui-------------------------------------------
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.95 0.95 0.95];
end
if nargin == 0
    fig_title = figure(); % Parent figure
    ERP_filtering_box = uiextras.BoxPanel('Parent', fig_title, 'Title', 'Spectral Analysis', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    ERP_filtering_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Spectral Analysis', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    ERP_filtering_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Spectral Analysis', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
end


gui_erp_spectral = struct();

try
    FonsizeDefault = varargin{2};
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
    FonsizeDefault = f_get_default_fontsize();
end
erp_spectral_gui(FonsizeDefault);

varargout{1} = ERP_filtering_box;
%%********************Draw the GUI for ERP measurement tool*****************
    function erp_spectral_gui(FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.95 0.95 0.95];
        end
        Enable_label = 'off';
        
        gui_erp_spectral.spectral = uiextras.VBox('Parent',ERP_filtering_box,'Spacing',1,'BackgroundColor',ColorB_def);
        
        gui_erp_spectral.amplitude_option = uiextras.HBox('Parent', gui_erp_spectral.spectral,'Spacing',1,'BackgroundColor',ColorB_def);
        
        %%amplitude and phase
        gui_erp_spectral.dispaly_title = uicontrol('Style','text','Parent',  gui_erp_spectral.amplitude_option,...
            'String','Display in:','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(gui_erp_spectral.dispaly_title,'HorizontalAlignment','left');
        gui_erp_spectral.amplitude = uicontrol('Style', 'radiobutton','Parent', gui_erp_spectral.amplitude_option,'String','Amplitude',...
            'callback',@spectral_amplitude,'Value',1,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_spectral.amplitude.KeyPressFcn= @erp_spectral_presskey;
        gui_erp_spectral.phase = uicontrol('Style', 'radiobutton','Parent', gui_erp_spectral.amplitude_option,...
            'String','Phase','callback',@spectral_phase,'Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_spectral.phase.KeyPressFcn= @erp_spectral_presskey;
        set( gui_erp_spectral.amplitude_option, 'Sizes', [80 100 100]);
        %%%power and dB
        gui_erp_spectral.pow_db = uiextras.HBox('Parent', gui_erp_spectral.spectral,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  gui_erp_spectral.pow_db);
        gui_erp_spectral.power = uicontrol('Style', 'radiobutton','Parent', gui_erp_spectral.pow_db ,...
            'String','Power','callback',@spectral_power,'Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_spectral.power.KeyPressFcn= @erp_spectral_presskey;
        gui_erp_spectral.db = uicontrol('Style', 'radiobutton','Parent', gui_erp_spectral.pow_db ,...
            'String','dB','callback',@spectral_db,'Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_spectral.db.KeyPressFcn= @erp_spectral_presskey;
        set( gui_erp_spectral.pow_db , 'Sizes', [80 100 100]);
        %%%
        if gui_erp_spectral.phase.Value==1
            gui_erp_spectral.Paras{1}=2;
        elseif gui_erp_spectral.power.Value==1
            gui_erp_spectral.Paras{1}=3;
        elseif gui_erp_spectral.db.Value==1
            gui_erp_spectral.Paras{1}=4;
        else
            gui_erp_spectral.Paras{1}=1;
        end
        
        gui_erp_spectral.hamwin_title_option = uiextras.HBox('Parent', gui_erp_spectral.spectral,'Spacing',1,'BackgroundColor',ColorB_def);
        gui_erp_spectral.hamwin_title = uicontrol('Style','text','Parent',  gui_erp_spectral.hamwin_title_option,'String','Hamming window:','FontSize',FonsizeDefault);
        set( gui_erp_spectral.hamwin_title,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        gui_erp_spectral.hamwin_on = uicontrol('Style', 'radiobutton','Parent',  gui_erp_spectral.hamwin_title_option,...
            'String','On','callback',@spectral_hamwin_on,'Value',1,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_spectral.hamwin_on.KeyPressFcn= @erp_spectral_presskey;
        gui_erp_spectral.hamwin_off = uicontrol('Style', 'radiobutton','Parent', gui_erp_spectral.hamwin_title_option,...
            'String','Off','callback',@spectral_hamwin_off,'Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_spectral.hamwin_off.KeyPressFcn= @erp_spectral_presskey;
        uiextras.Empty('Parent',  gui_erp_spectral.hamwin_title_option,'BackgroundColor',ColorB_def);
        set( gui_erp_spectral.hamwin_title_option, 'Sizes', [120 60 60 40]);
        gui_erp_spectral.Paras{2}=gui_erp_spectral.hamwin_on.Value;
        
        %%frequency range
        gui_erp_spectral.frerange_title = uiextras.HBox('Parent',gui_erp_spectral.spectral,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',gui_erp_spectral.frerange_title,...
            'String','Freq. range [min max]:','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_spectral.frerange = uicontrol('Style','edit','Parent',gui_erp_spectral.frerange_title,...
            'String',' ','callback',@frerange,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        gui_erp_spectral.Paras{3} = [];
        gui_erp_spectral.frerange.KeyPressFcn= @erp_spectral_presskey;
        set(gui_erp_spectral.frerange_title,'Sizes',[120 -1]);
        
        %%
        gui_erp_spectral.other_option = uiextras.HBox('Parent',gui_erp_spectral.spectral,'Spacing',1,'BackgroundColor',ColorB_def);
        gui_erp_spectral.cancel = uicontrol('Style','pushbutton','Parent',gui_erp_spectral.other_option,...
            'String','Cancel','callback',@spectral_cancel,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        gui_erp_spectral.plot = uicontrol('Style','pushbutton','Parent',gui_erp_spectral.other_option,...
            'String','Plot','callback',@spectral_plot,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        gui_erp_spectral.save = uicontrol('Style','pushbutton','Parent',gui_erp_spectral.other_option,...
            'String','Save','callback',@spectral_save,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        
        set(gui_erp_spectral.spectral, 'Sizes', [20 20 20 25 30]);
        estudioworkingmemory('ERPTab_spectral',0);
    end
%%*************************************************************************
%%*******************   Subfunctions   ************************************
%%*************************************************************************

%%--------------------------------setting for amplitude------------------
    function  spectral_amplitude(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        gui_erp_spectral.plot.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_spectral.plot.ForegroundColor = [1 1 1];
        ERP_filtering_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_spectral.save.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.save.ForegroundColor = [1 1 1];
        
        gui_erp_spectral.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.cancel.ForegroundColor = [1 1 1];
        
        estudioworkingmemory('ERPTab_spectral',1);
        
        gui_erp_spectral.amplitude.Value =1;
        gui_erp_spectral.phase.Value = 0;
        gui_erp_spectral.power.Value = 0;
        gui_erp_spectral.db.Value =0;
    end

%%--------------------------Setting for phase-----------------------------
    function spectral_phase(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        gui_erp_spectral.plot.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_spectral.plot.ForegroundColor = [1 1 1];
        ERP_filtering_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_spectral.save.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.save.ForegroundColor = [1 1 1];
        
        gui_erp_spectral.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_spectral',1);
        
        gui_erp_spectral.phase.Value = 1;
        gui_erp_spectral.amplitude.Value =0;
        gui_erp_spectral.power.Value = 0;
        gui_erp_spectral.db.Value =0;
    end

%%--------------------Setting for power------------------------------------
    function spectral_power(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        gui_erp_spectral.plot.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_spectral.plot.ForegroundColor = [1 1 1];
        ERP_filtering_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_spectral.save.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.save.ForegroundColor = [1 1 1];
        
        gui_erp_spectral.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_spectral',1);
        
        gui_erp_spectral.phase.Value = 0;
        gui_erp_spectral.amplitude.Value =0;
        gui_erp_spectral.power.Value =1;
        gui_erp_spectral.db.Value =0;
    end

%%--------------------Setting for dB------------------------------------
    function spectral_db(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        gui_erp_spectral.plot.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_spectral.plot.ForegroundColor = [1 1 1];
        ERP_filtering_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_spectral.save.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.save.ForegroundColor = [1 1 1];
        
        gui_erp_spectral.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_spectral',1);
        
        gui_erp_spectral.phase.Value = 0;
        gui_erp_spectral.amplitude.Value =0;
        gui_erp_spectral.power.Value =0;
        gui_erp_spectral.db.Value =1;
    end


%%-------------------------Setting for hamming window:on-------------------
    function spectral_hamwin_on(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        gui_erp_spectral.plot.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_spectral.plot.ForegroundColor = [1 1 1];
        ERP_filtering_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_spectral.save.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.save.ForegroundColor = [1 1 1];
        
        gui_erp_spectral.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_spectral',1);
        
        gui_erp_spectral.hamwin_on.Value = 1;
        gui_erp_spectral.hamwin_off.Value = 0;
    end

%%-------------------------Setting for hamming window:off-------------------
    function spectral_hamwin_off(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        gui_erp_spectral.plot.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_spectral.plot.ForegroundColor = [1 1 1];
        ERP_filtering_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_spectral.save.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.save.ForegroundColor = [1 1 1];
        
        gui_erp_spectral.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_spectral',1);
        gui_erp_spectral.hamwin_on.Value = 0;
        gui_erp_spectral.hamwin_off.Value = 1;
    end

%%----------------------frequency range------------------------------------
    function frerange(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        gui_erp_spectral.plot.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_spectral.plot.ForegroundColor = [1 1 1];
        ERP_filtering_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_spectral.save.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.save.ForegroundColor = [1 1 1];
        
        gui_erp_spectral.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_spectral',1);
        
        FreqRange = str2num(gui_erp_spectral.frerange.String);
        if isempty(FreqRange) || numel(FreqRange)~=2 || any(FreqRange(:)>floor(observe_ERPDAT.ERP.srate/2)) || any(FreqRange(:)<0)
            FreqRange = [0 floor(observe_ERPDAT.ERP.srate/2)];
            gui_erp_spectral.frerange.String = num2str(FreqRange);
            msgboxText =  ['Spectral Analysis>Freq. range [min max]: it should have two values and between 0 and',32,num2str(floor(observe_ERPDAT.ERP.srate/2))];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
    end


%%-----------------------------cancel--------------------------------------
    function spectral_cancel(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        gui_erp_spectral.plot.BackgroundColor =  [1 1 1];
        gui_erp_spectral.plot.ForegroundColor = [0 0 0];
        ERP_filtering_box.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_spectral.save.BackgroundColor =  [1 1 1];
        gui_erp_spectral.save.ForegroundColor = [0 0 0];
        
        gui_erp_spectral.cancel.BackgroundColor =  [1 1 1];
        gui_erp_spectral.cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_spectral',0);
        amplitude = gui_erp_spectral.Paras{1};
        if isempty(amplitude) || numel(amplitude)~=1 || (amplitude~=1 && amplitude~=2 && amplitude~=3 && amplitude~=4)
            amplitude = 1;
            gui_erp_spectral.Paras{1}=1;
        end
        if amplitude==2
            gui_erp_spectral.amplitude.Value = 0;
            gui_erp_spectral.phase.Value=1;
            gui_erp_spectral.power.Value=0;
            gui_erp_spectral.db.Value=0;
        elseif  amplitude==3
            gui_erp_spectral.amplitude.Value = 0;
            gui_erp_spectral.phase.Value=0;
            gui_erp_spectral.power.Value=1;
            gui_erp_spectral.db.Value=0;
        elseif amplitude==4
            gui_erp_spectral.amplitude.Value = 0;
            gui_erp_spectral.phase.Value=0;
            gui_erp_spectral.power.Value=0;
            gui_erp_spectral.db.Value=1;
        else
            gui_erp_spectral.amplitude.Value = 1;
            gui_erp_spectral.phase.Value=0;
            gui_erp_spectral.power.Value=0;
            gui_erp_spectral.db.Value=0;
        end
        
        
        hamwin_on = gui_erp_spectral.Paras{2};
        if isempty(hamwin_on) ||numel(hamwin_on)~=1 || (hamwin_on~=0 && hamwin_on~=1)
            hamwin_on =1;
            gui_erp_spectral.Paras{2}=1;
        end
        if gui_erp_spectral.phase.Value==1
            gui_erp_spectral.Paras{1}=2;
        elseif gui_erp_spectral.power.Value==1
            gui_erp_spectral.Paras{1}=3;
        elseif gui_erp_spectral.db.Value==1
            gui_erp_spectral.Paras{1}=4;
        else
            gui_erp_spectral.Paras{1}=1;
        end
        gui_erp_spectral.Paras{2}=gui_erp_spectral.hamwin_on.Value;
        gui_erp_spectral.hamwin_on.Value=hamwin_on;
        gui_erp_spectral.hamwin_off.Value=~hamwin_on;
        try frerange = gui_erp_spectral.Paras{3} ;catch frerange = []; end;
        if isempty(frerange) || numel(frerange)~=2 || any(frerange(:)>floor(observe_ERPDAT.ERP.srate/2))
            frerange = [0 floor(observe_ERPDAT.ERP.srate/2)];
            gui_erp_spectral.Paras{3} = [0 floor(observe_ERPDAT.ERP.srate/2)];
        end
        gui_erp_spectral.frerange.String = num2str(frerange);
        
    end

%%--------------------------Setting for plot-------------------------------
    function spectral_plot(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        gui_erp_spectral.plot.BackgroundColor =  [1 1 1];
        gui_erp_spectral.plot.ForegroundColor = [0 0 0];
        ERP_filtering_box.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_spectral.save.BackgroundColor =  [1 1 1];
        gui_erp_spectral.save.ForegroundColor = [0 0 0];
        
        gui_erp_spectral.cancel.BackgroundColor =  [1 1 1];
        gui_erp_spectral.cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_spectral',0);
        
        if gui_erp_spectral.hamwin_on.Value
            iswindowed =1;
        else
            iswindowed = 0;
        end
        ERPArray =  estudioworkingmemory('selectederpstudio');
        if isempty(ERPArray)
            ERPArray =  length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = ERPArray;
        end
        
        if gui_erp_spectral.phase.Value==1
            gui_erp_spectral.Paras{1}=2;
        elseif gui_erp_spectral.power.Value==1
            gui_erp_spectral.Paras{1}=3;
        elseif gui_erp_spectral.db.Value==1
            gui_erp_spectral.Paras{1}=4;
        else
            gui_erp_spectral.Paras{1}=1;
        end
        Amptypev = gui_erp_spectral.Paras{1};
        if Amptypev==2
            Amptype = 'phase';
        elseif Amptypev==3
            Amptype = 'power';
        elseif Amptypev==4
            Amptype = 'db';
        else
            Amptype = 'amp';
        end
        
        freqrange = str2num(gui_erp_spectral.frerange.String);
        if isempty(freqrange) || numel(freqrange)~=2 || any(freqrange(:)>floor(observe_ERPDAT.ERP.srate/2)) || any(freqrange(:)<0)
            freqrange = [0 floor(observe_ERPDAT.ERP.srate/2)];
            gui_erp_spectral.frerange.String = num2str(freqrange);
        end
        gui_erp_spectral.Paras{3} =freqrange;
        
        if iswindowed==1
            TaperWindow = 'on';
        else
            TaperWindow = 'off';
        end
        
        ChanArray =  estudioworkingmemory('ERP_ChanArray');
        BinArray =  estudioworkingmemory('ERP_BinArray');
        
        try ALLERPCOM = evalin('base','ALLERPCOM'); catch ALLERPCOM = []; end
        for Numoferpset = 1:numel(ERPArray)
            %%%
            ERP = observe_ERPDAT.ALLERP(ERPArray(Numoferpset));
            if isempty(freqrange) || numel(freqrange)~=2 || any(freqrange(:)>floor(ERP.srate/2)) || any(freqrange(:)<0)
                freqrange = [0 floor(ERP.srate/2)];
            end
            
            if isempty(ChanArray) || any(ChanArray(:)>ERP.nchan) || any(ChanArray(:)<1)
                ChanArray = [1:ERP.nchan];
            end
            if isempty(BinArray) || any(BinArray(:)>ERP.nbin) || any(BinArray(:)<1)
                BinArray = 1:ERP.nbin;
            end
            [~, ERPCOM] = pop_ERP_spectralanalysis(ERP, 'Amptype',Amptype,'TaperWindow',TaperWindow,...
                'freqrange',freqrange,'BinArray',BinArray,'ChanArray',ChanArray,'Plotwave','on','Saveas', 'off','History','gui');
            if  Numoferpset == numel(ERPArray)
                [observe_ERPDAT.ALLERP(ERPArray(Numoferpset)), ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
            else
                [observe_ERPDAT.ALLERP(ERPArray(Numoferpset)), ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
            end
        end%%end loop for ERPSET
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
        observe_ERPDAT.Count_currentERP=20;
        gui_erp_spectral.Paras{2}=gui_erp_spectral.hamwin_on.Value;
    end


%%-----------------Setting for save option---------------------------------
    function spectral_save(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        gui_erp_spectral.plot.BackgroundColor =  [1 1 1];
        gui_erp_spectral.plot.ForegroundColor = [0 0 0];
        ERP_filtering_box.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_spectral.save.BackgroundColor =  [1 1 1];
        gui_erp_spectral.save.ForegroundColor = [0 0 0];
        
        gui_erp_spectral.cancel.BackgroundColor =  [1 1 1];
        gui_erp_spectral.cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_spectral',0);
        
        estudioworkingmemory('f_ERP_proces_messg','Spectral Analysis - Save');
        observe_ERPDAT.Process_messg =1;
        
        
        if gui_erp_spectral.hamwin_on.Value
            iswindowed =1;
        else
            iswindowed = 0;
        end
        ERPArray =  estudioworkingmemory('selectederpstudio');
        if isempty(ERPArray)
            ERPArray =  observe_ERPDAT.CURRENTERP;
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = ERPArray;
        end
        
        if gui_erp_spectral.phase.Value==1
            gui_erp_spectral.Paras{1}=2;
        elseif gui_erp_spectral.power.Value==1
            gui_erp_spectral.Paras{1}=3;
        elseif gui_erp_spectral.db.Value==1
            gui_erp_spectral.Paras{1}=4;
        else
            gui_erp_spectral.Paras{1}=1;
        end
        Amptypev = gui_erp_spectral.Paras{1};
        if Amptypev==2
            Amptype = 'phase';
        elseif Amptypev==3
            Amptype = 'power';
        elseif Amptypev==4
            Amptype = 'db';
        else
            Amptype = 'amp';
        end
        
        freqrange = str2num(gui_erp_spectral.frerange.String);
        if isempty(freqrange) || numel(freqrange)~=2 || any(freqrange(:)>floor(observe_ERPDAT.ERP.srate/2)) || any(freqrange(:)<0)
            freqrange = [0 floor(observe_ERPDAT.ERP.srate/2)];
            gui_erp_spectral.frerange.String = num2str(freqrange);
        end
        gui_erp_spectral.Paras{3} =freqrange;
        
        if iswindowed==1
            TaperWindow = 'on';
        else
            TaperWindow = 'off';
        end
        
        ChanArray =  estudioworkingmemory('ERP_ChanArray');
        BinArray =  estudioworkingmemory('ERP_BinArray');
        
        try ALLERPCOM = evalin('base','ALLERPCOM'); catch ALLERPCOM = []; end
        for Numoferpset = 1:numel(ERPArray)
            %%%
            ERP = observe_ERPDAT.ALLERP(ERPArray(Numoferpset));
            if isempty(freqrange) || numel(freqrange)~=2 || any(freqrange(:)>floor(ERP.srate/2)) || any(freqrange(:)<0)
                freqrange = [0 floor(ERP.srate/2)];
            end
            
            if isempty(ChanArray) || any(ChanArray(:)>ERP.nchan) || any(ChanArray(:)<1)
                ChanArray = [1:ERP.nchan];
            end
            if isempty(BinArray) || any(BinArray(:)>ERP.nbin) || any(BinArray(:)<1)
                BinArray = 1:ERP.nbin;
            end
            [~, ERPCOM] = pop_ERP_spectralanalysis(ERP, 'Amptype',Amptype,'TaperWindow',TaperWindow,...
                'freqrange',freqrange,'BinArray',BinArray,'ChanArray',ChanArray,'Plotwave','off',...
                'Saveas', 'csv','History','gui');
            if  Numoferpset == numel(ERPArray)
                [observe_ERPDAT.ALLERP(ERPArray(Numoferpset)), ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
            else
                [observe_ERPDAT.ALLERP(ERPArray(Numoferpset)), ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
            end
        end%%end loop for ERPSET
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
        observe_ERPDAT.Count_currentERP=20;
        gui_erp_spectral.Paras{2}=gui_erp_spectral.hamwin_on.Value;
        
    end

%%-------------------Setting for the whole panel of fitering based on ALLERP and CURRENTERP--------------
    function Count_currentERPChanged(~,~)
        if observe_ERPDAT.Count_currentERP~=18
            return;
        end
        ViewerFlag=estudioworkingmemory('ViewerFlag');
        if isempty(ViewerFlag) || (ViewerFlag~=0 && ViewerFlag~=1)
            ViewerFlag=0;estudioworkingmemory('ViewerFlag',0);
        end
        if  isempty(observe_ERPDAT.ERP) || isempty(observe_ERPDAT.ALLERP) || strcmp(observe_ERPDAT.ERP.datatype,'EFFT') || ViewerFlag==1
            Enable_label = 'off';
        else
            Enable_label = 'on';
        end
        
        gui_erp_spectral.save.Enable = Enable_label;
        gui_erp_spectral.plot.Enable = Enable_label;
        gui_erp_spectral.phase.Enable = Enable_label;
        gui_erp_spectral.amplitude.Enable =Enable_label;
        gui_erp_spectral.power.Enable = Enable_label;
        gui_erp_spectral.db.Enable = Enable_label;
        gui_erp_spectral.hamwin_on.Enable =Enable_label;
        gui_erp_spectral.hamwin_off.Enable = Enable_label;
        gui_erp_spectral.cancel.Enable = Enable_label;
        gui_erp_spectral.frerange.Enable = Enable_label;
        if ~isempty(observe_ERPDAT.ERP) && ~isempty(observe_ERPDAT.ALLERP) && ~strcmp(observe_ERPDAT.ERP.datatype,'EFFT')
            frerange = str2num(gui_erp_spectral.frerange.String);
            if isempty(frerange) ||  any(frerange(:)>floor(observe_ERPDAT.ERP.srate/2)) || any(frerange(:)<0)
                gui_erp_spectral.frerange.String = num2str([0 floor(observe_ERPDAT.ERP.srate/2)]);
                gui_erp_spectral.Paras{3} = [0 floor(observe_ERPDAT.ERP.srate/2)];
            end
        end
        
        observe_ERPDAT.Count_currentERP=19;
    end

%%----Get the color for lines--------------------------------------
    function colors = get_colors(ncolors)
        % Each color gets 1 point divided into up to 2 of 3 groups (RGB).
        degree_step = 6/ncolors;
        angles = (0:ncolors-1)*degree_step;
        colors = nan(numel(angles),3);
        for i = 1:numel(angles)
            if angles(i) < 1
                colors(i,:) = [1 (angles(i)-floor(angles(i))) 0]*0.75;
            elseif angles(i) < 2
                colors(i,:) = [(1-(angles(i)-floor(angles(i)))) 1 0]*0.75;
            elseif angles(i) < 3
                colors(i,:) = [0 1 (angles(i)-floor(angles(i)))]*0.75;
            elseif angles(i) < 4
                colors(i,:) = [0 (1-(angles(i)-floor(angles(i)))) 1]*0.75;
            elseif angles(i) < 5
                colors(i,:) = [(angles(i)-floor(angles(i))) 0 1]*0.75;
            else
                colors(i,:) = [1 0 (1-(angles(i)-floor(angles(i))))]*0.75;
            end
        end
    end


%%--------------press return to execute "Apply"----------------------------
    function erp_spectral_presskey(~,eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('ERPTab_spectral');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            spectral_plot();
            gui_erp_spectral.plot.BackgroundColor =  [1 1 1];
            gui_erp_spectral.plot.ForegroundColor = [0 0 0];
            ERP_filtering_box.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
            gui_erp_spectral.save.BackgroundColor =  [1 1 1];
            gui_erp_spectral.save.ForegroundColor = [0 0 0];
            
            gui_erp_spectral.cancel.BackgroundColor =  [1 1 1];
            gui_erp_spectral.cancel.ForegroundColor = [0 0 0];
            estudioworkingmemory('ERPTab_spectral',0);
        else
            return;
        end
    end

    function Reset_erp_panel_change(~,~)
        if observe_ERPDAT.Reset_erp_paras_panel~=15
            return;
        end
        gui_erp_spectral.plot.BackgroundColor =  [1 1 1];
        gui_erp_spectral.plot.ForegroundColor = [0 0 0];
        ERP_filtering_box.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_spectral.save.BackgroundColor =  [1 1 1];
        gui_erp_spectral.save.ForegroundColor = [0 0 0];
        gui_erp_spectral.cancel.BackgroundColor =  [1 1 1];
        gui_erp_spectral.cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_spectral',0);
        gui_erp_spectral.hamwin_on.Value = 1;
        gui_erp_spectral.hamwin_off.Value = 0;
        gui_erp_spectral.phase.Value = 0;
        gui_erp_spectral.amplitude.Value =1;
        gui_erp_spectral.power.Value =0;
        gui_erp_spectral.db.Value =0;
        if ~isempty(observe_ERPDAT.ERP)
            gui_erp_spectral.frerange.String = num2str([0 floor(observe_ERPDAT.ERP.srate/2)]);
        end
        
        if gui_erp_spectral.phase.Value==1
            gui_erp_spectral.Paras{1}=2;
        elseif gui_erp_spectral.power.Value==1
            gui_erp_spectral.Paras{1}=3;
        elseif gui_erp_spectral.db.Value==1
            gui_erp_spectral.Paras{1}=4;
        else
            gui_erp_spectral.Paras{1}=1;
        end
        gui_erp_spectral.Paras{2}=gui_erp_spectral.hamwin_on.Value;
        gui_erp_spectral.Paras{3} = [0 floor(observe_ERPDAT.ERP.srate/2)];
        observe_ERPDAT.Reset_erp_paras_panel=16;
    end
end
%Progem end: