%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 2022 & Nov. 2023

% ERPLAB Studio

function varargout = f_ERP_spectral_GUI(varargin)

global observe_ERPDAT;
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);
addlistener(observe_ERPDAT,'erp_two_panels_change',@erp_two_panels_change);


defaulpar =  erpworkingmemory('f_ERP_spectral');
defaulpar{1} = 0;defaulpar{2} = [];defaulpar{3} = [];defaulpar{4} = [];defaulpar{5} = [];
defaulpar{6} = [];defaulpar{7} = [];
erpworkingmemory('f_ERP_spectral',defaulpar);
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
        
        gui_erp_spectral.other_option = uiextras.HBox('Parent',gui_erp_spectral.spectral,'Spacing',1,'BackgroundColor',ColorB_def);
        gui_erp_spectral.cancel = uicontrol('Style','pushbutton','Parent',gui_erp_spectral.other_option,...
            'String','Cancel','callback',@spectral_cancel,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        gui_erp_spectral.plot = uicontrol('Style','pushbutton','Parent',gui_erp_spectral.other_option,...
            'String','Plot','callback',@spectral_plot,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        gui_erp_spectral.save = uicontrol('Style','pushbutton','Parent',gui_erp_spectral.other_option,...
            'String','Save','callback',@spectral_save,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        gui_erp_spectral.advanced = uicontrol('Parent',gui_erp_spectral.other_option,'Style','pushbutton',...
            'String','Advanced','callback',@spectral_advanced,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        
        set(gui_erp_spectral.spectral, 'Sizes', [20 20 20 30]);
        estudioworkingmemory('ERPTab_spectral',0);
    end
%%****************************************************************************************************************************************
%%*******************   Subfunctions   ***************************************************************************************************
%%****************************************************************************************************************************************

%%--------------------------------setting for amplitude------------------
    function  spectral_amplitude(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_spectral.plot.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_spectral.plot.ForegroundColor = [1 1 1];
        ERP_filtering_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_spectral.save.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.save.ForegroundColor = [1 1 1];
        gui_erp_spectral.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.advanced.ForegroundColor = [1 1 1];
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
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_spectral.plot.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_spectral.plot.ForegroundColor = [1 1 1];
        ERP_filtering_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_spectral.save.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.save.ForegroundColor = [1 1 1];
        gui_erp_spectral.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.advanced.ForegroundColor = [1 1 1];
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
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_spectral.plot.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_spectral.plot.ForegroundColor = [1 1 1];
        ERP_filtering_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_spectral.save.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.save.ForegroundColor = [1 1 1];
        gui_erp_spectral.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.advanced.ForegroundColor = [1 1 1];
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
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_spectral.plot.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_spectral.plot.ForegroundColor = [1 1 1];
        ERP_filtering_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_spectral.save.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.save.ForegroundColor = [1 1 1];
        gui_erp_spectral.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.advanced.ForegroundColor = [1 1 1];
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
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_spectral.plot.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_spectral.plot.ForegroundColor = [1 1 1];
        ERP_filtering_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_spectral.save.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.save.ForegroundColor = [1 1 1];
        gui_erp_spectral.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.advanced.ForegroundColor = [1 1 1];
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
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_spectral.plot.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_spectral.plot.ForegroundColor = [1 1 1];
        ERP_filtering_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_spectral.save.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.save.ForegroundColor = [1 1 1];
        gui_erp_spectral.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.advanced.ForegroundColor = [1 1 1];
        gui_erp_spectral.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_spectral.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_spectral',1);
        gui_erp_spectral.hamwin_on.Value = 0;
        gui_erp_spectral.hamwin_off.Value = 1;
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
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_spectral.plot.BackgroundColor =  [1 1 1];
        gui_erp_spectral.plot.ForegroundColor = [0 0 0];
        ERP_filtering_box.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_spectral.save.BackgroundColor =  [1 1 1];
        gui_erp_spectral.save.ForegroundColor = [0 0 0];
        gui_erp_spectral.advanced.BackgroundColor =  [1 1 1];
        gui_erp_spectral.advanced.ForegroundColor = [0 0 0];
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
        gui_erp_spectral.hamwin_on.Value=hamwin_on;
        gui_erp_spectral.hamwin_off.Value=~hamwin_on;
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
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_spectral.plot.BackgroundColor =  [1 1 1];
        gui_erp_spectral.plot.ForegroundColor = [0 0 0];
        ERP_filtering_box.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_spectral.save.BackgroundColor =  [1 1 1];
        gui_erp_spectral.save.ForegroundColor = [0 0 0];
        gui_erp_spectral.advanced.BackgroundColor =  [1 1 1];
        gui_erp_spectral.advanced.ForegroundColor = [0 0 0];
        gui_erp_spectral.cancel.BackgroundColor =  [1 1 1];
        gui_erp_spectral.cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_spectral',0);
        
        if gui_erp_spectral.hamwin_on.Value
            iswindowed =1;
        else
            iswindowed = 0;
        end
        Selected_erpset =  estudioworkingmemory('selectederpstudio');
        if isempty(Selected_erpset)
            Selected_erpset =  length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = Selected_erpset;
        end
        
        defaulpar1 =  erpworkingmemory('f_ERP_spectral');
        FreqRange = [];
        BinArray = estudioworkingmemory('ERP_BinArray');
        ChanArray =  estudioworkingmemory('ERP_ChanArray');
        [chk, msgboxText] = f_ERP_chckbinandchan(observe_ERPDAT.ERP, BinArray, [],1);
        if chk(1)==1
            BinArray =  [1:observe_ERPDAT.ERP.nbin];
        end
        [chk, msgboxText] = f_ERP_chckbinandchan(observe_ERPDAT.ERP,[], ChanArray,2);
        if chk(2)==1
            ChanArray =  [1:observe_ERPDAT.ERP.nchan];
        end
        
        %%Plot the spectrum for the selected ERPset
        %                 try
        for Numoferpset = 1:numel(Selected_erpset)
            %%%
            ERP_curret_s = observe_ERPDAT.ALLERP(Selected_erpset(Numoferpset));
            if strcmp(ERP_curret_s.datatype,'ERP')
                ERP_FFT = f_getFFTfromERP(ERP_curret_s,iswindowed);
            elseif strcmp(ERP_curret_s.datatype,'EFFT')
                ERP_FFT = ERP_curret_s;
            end
            
            ColumnNum = 1;
            if isempty(BinArray)
                BinArray = [1:ERP_curret_s.nbin];
            end
            
            if isempty(ChanArray)
                ChanArray =  [1:ERP_curret_s.nchan];
            end
            
            if max(BinArray(:))> ERP_FFT.nbin
                BinArray = [1:ERP_FFT.nbin];
            end
            
            if max(ChanArray(:))> ERP_FFT.nchan
                ChanArray = [1:ERP_FFT.nchan];
            end
            RowNum = ceil(numel(ChanArray)/ColumnNum);
            
            if gui_erp_spectral.amplitude.Value
                ERP_FFT.bindata  = abs(ERP_FFT.bindata);
                figure_name = ['Spectral analysis: Amplitude for ',32,ERP_FFT.erpname];
            elseif gui_erp_spectral.phase.Value
                ERP_FFT.bindata  = angle(ERP_FFT.bindata);
                figure_name = ['Spectral analysis: Phase for ',32,ERP_FFT.erpname];
            elseif  gui_erp_spectral.power.Value
                ERP_FFT.bindata  = abs(ERP_FFT.bindata).^2;
                figure_name = ['Spectral analysis: Power for ',32,ERP_FFT.erpname];
            elseif gui_erp_spectral.db.Value
                ERP_FFT.bindata  = 20*log10(abs(ERP_FFT.bindata));
                figure_name = ['Spectral analysis: dB for ',32,ERP_FFT.erpname];
            end
            
            fig = figure('Name',figure_name);
            set(fig,'outerposition',get(0,'screensize'));
            
            line_colors = erpworkingmemory('PWColor');
            if size(line_colors,1)~= ERP_FFT.nbin
                if ERP_FFT.nbin> size(line_colors,1)
                    line_colors = get_colors(ERP_FFT.nbin);
                else
                    line_colors = line_colors(1:ERP_FFT.nbin,:,:);
                end
            end
            
            if isempty(line_colors)
                line_colors = get_colors(ERP_FFT.nbin);
            end
            FreqRange=[ERP_FFT.times(1), ERP_FFT.times(end)];
            FreqTick = default_time_ticks(ERP_FFT, FreqRange);
            FreqTick = str2num(FreqTick{1});
            ERP_FFT.bindata = ERP_FFT.bindata(ChanArray,:,BinArray);
            ERP_FFT.nbin = numel(BinArray);
            ERP_FFT.nchan = numel(ChanArray);
            ERP_FFT.chanlocs =  ERP_FFT.chanlocs(ChanArray);
            ERP_FFT.bindescr =  ERP_FFT.bindescr(BinArray);
            
            pbox = f_getrow_columnautowaveplot(ChanArray);
            try
                RowNum = pbox(1);
                ColumnNum = pbox(2);
            catch
                RowNum = numel(ChanArray);
                ColumnNum = 1;
            end
            
            count = 0;
            for Numofcolumn = 1:ColumnNum
                for Numofrow = 1: RowNum
                    count = count+1;
                    if ColumnNum*RowNum<5
                        pause(1);
                    end
                    if count>ERP_FFT.nchan
                        break;
                    end
                    p_ax = subplot(RowNum,ColumnNum,count);
                    set(gca,'fontsize',14);
                    hold on;
                    temp = squeeze(ERP_FFT.bindata);
                    for Numofplot  = 1:ERP_FFT.nbin
                        h_p(Numofplot) =  plot(p_ax,ERP_FFT.times,squeeze(ERP_FFT.bindata(count,:,Numofplot)),'LineWidth',1,'Color',line_colors(Numofplot,:,:));
                    end
                    axis(p_ax,[floor(ERP_FFT.times(1)),ceil(ERP_FFT.times(end)), 1.1*min(temp(:)) 1.1*max(temp(:))]);
                    xticks(p_ax,FreqTick);
                    if count == 1
                        title(p_ax,[ERP_FFT.chanlocs(count).labels],'FontSize',14); %#ok<*NODEF>
                        legend(p_ax,ERP_FFT.bindescr,'FontSize',14);
                        legend(p_ax,'boxoff');
                    else
                        title(p_ax,ERP_FFT.chanlocs(count).labels,'FontSize',14);
                    end
                    xlabel(p_ax,'Frequency/Hz','FontSize',14);
                    if gui_erp_spectral.phase.Value
                        ylabel(p_ax,'Angle/degree','FontSize',14);
                    elseif gui_erp_spectral.amplitude.Value
                        ylabel(p_ax,'Amplitude/\muV','FontSize',14);
                    elseif gui_erp_spectral.power.Value
                        ylabel(p_ax,'Power/\muV^2','FontSize',14);
                    elseif gui_erp_spectral.db.Value
                        ylabel(p_ax,'Decibels/dB','FontSize',14);
                    end
                    for NUmoflabel = 1:length(ERP_FFT.times)
                        X_label{NUmoflabel} = [];
                    end
                    set(gca,'TickDir','out');
                    set(gca,'LineWidth',2);
                end
            end
        end%%end loop for ERPSET
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
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_spectral.plot.BackgroundColor =  [1 1 1];
        gui_erp_spectral.plot.ForegroundColor = [0 0 0];
        ERP_filtering_box.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_spectral.save.BackgroundColor =  [1 1 1];
        gui_erp_spectral.save.ForegroundColor = [0 0 0];
        gui_erp_spectral.advanced.BackgroundColor =  [1 1 1];
        gui_erp_spectral.advanced.ForegroundColor = [0 0 0];
        gui_erp_spectral.cancel.BackgroundColor =  [1 1 1];
        gui_erp_spectral.cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_spectral',0);
        
        erpworkingmemory('f_ERP_proces_messg','Spectral Analysis - Save');
        observe_ERPDAT.Process_messg =1;
        
        pathName =  erpworkingmemory('ERP_save_folder');
        if isempty(pathName)
            pathName =  cd;
        end
        if gui_erp_spectral.hamwin_on.Value
            iswindowed =1;
        else
            iswindowed = 0;
        end
        Selected_erpset =  estudioworkingmemory('selectederpstudio');
        if isempty(Selected_erpset)
            Selected_erpset =  observe_ERPDAT.CURRENTERP;
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = Selected_erpset;
        end
        FreqRange = [];
        BinArray = estudioworkingmemory('ERP_BinArray');
        ChanArray =  estudioworkingmemory('ERP_ChanArray');
        [chk, msgboxText] = f_ERP_chckbinandchan(observe_ERPDAT.ERP, BinArray, [],1);
        if chk(1)==1
            BinArray =  [1:observe_ERPDAT.ERP.nbin];
        end
        [chk, msgboxText] = f_ERP_chckbinandchan(observe_ERPDAT.ERP,[], ChanArray,2);
        if chk(2)==1
            ChanArray =  [1:observe_ERPDAT.ERP.nchan];
        end
        try
            ALLERPCOM = evalin('base','ALLERPCOM');
        catch
            ALLERPCOM = [];
            assignin('base','ALLERPCOM',ALLERPCOM);
        end
        %%Plot the spectrum for the selected ERPset
        %-----------Setting for import-------------------------------------
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.7020 0.77 0.85];
        end
        oldcolor = get(0,'DefaultUicontrolBackgroundColor');
        set(0,'DefaultUicontrolBackgroundColor',ColorB_def);
        [ind,tf] = listdlg('ListString',{'".mat"','".csv"'},'SelectionMode','single','PromptString','Please select a type to export to...','Name','Export Spectrum for Selected ERPset to','OKString','Ok');
        set(0,'DefaultUicontrolBackgroundColor',[1 1 1]);
        if isempty(ind)
            beep;
            disp(['User selected cancel']);
            return;
        end
        for Numoferpset = 1:numel(Selected_erpset)
            %%%
            ERP_curret_s = observe_ERPDAT.ALLERP(Selected_erpset(Numoferpset));
            if  strcmp(ERP_curret_s.datatype,'ERP')
                ERP_FFT = f_getFFTfromERP(ERP_curret_s,iswindowed);
            else
                ERP_FFT = ERP_curret_s;
            end
            if isempty(BinArray)
                BinArray = [1:ERP_curret_s.nbin];
            end
            if isempty(ChanArray)
                ChanArray =  [1:ERP_curret_s.nchan];
            end
            
            if any(BinArray(:)> ERP_FFT.nbin)
                BinArray = [1:ERP_FFT.nbin];
            end
            if any(ChanArray(:)> ERP_FFT.nchan)
                ChanArray = [1:ERP_FFT.nchan];
            end
            
            if isempty(FreqRange) || FreqRange(2)>ERP_FFT.times(end)
                FreqRange=[ERP_FFT.times(1), ERP_FFT.times(end)];
            end
            [xxx, latsamp, latdiffms] = closest(ERP_FFT.times, FreqRange);
            tmin = latsamp(1);
            tmax = latsamp(2);
            ERP_FFT.bindata = ERP_FFT.bindata(ChanArray,tmin:tmax,BinArray);
            ERP_FFT.nbin = numel(BinArray);
            ERP_FFT.nchan = numel(ChanArray);
            ERP_FFT.chanlocs =  ERP_FFT.chanlocs(ChanArray);
            ERP_FFT.bindescr =  ERP_FFT.bindescr(BinArray);
            ERP_FFT.times = ERP_FFT.times(tmin:tmax);
            
            if  strcmp(ERP_curret_s.datatype,'ERP')
                if gui_erp_spectral.amplitude.Value
                    ERP_FFT.bindata  = abs(ERP_FFT.bindata);
                    figure_name = [ERP_FFT.erpname,'_Spectrum_Amplitude'];
                elseif gui_erp_spectral.phase.Value
                    ERP_FFT.bindata  = angle(ERP_FFT.bindata);
                    figure_name = [ERP_FFT.erpname,'_Spectrum_Phase'];
                elseif  gui_erp_spectral.power.Value
                    ERP_FFT.bindata  = abs(ERP_FFT.bindata).^2;
                    figure_name = [ERP_FFT.erpname,'_Spectrum_Power'];
                elseif gui_erp_spectral.db.Value
                    ERP_FFT.bindata  = 20*log10(abs(ERP_FFT.bindata));
                    figure_name = [ERP_FFT.erpname,'_Spectrum_ dB'];
                end
            else
                if gui_erp_spectral.amplitude.Value
                    figure_name = [ERP_FFT.erpname,'_Spectrum_amplitude'];
                elseif gui_erp_spectral.phase.Value
                    figure_name = [ERP_FFT.erpname,'_Spectrum_phase'];
                elseif gui_erp_spectral.power.Value
                    figure_name = strcat(ERP_FFT.erpname,'Spectrum_Power');
                    
                elseif gui_erp_spectral.db.Value
                    figure_name = strcat(ERP_FFT.erpname,'_Spectrum_dB');
                end
            end
            if ind==1
                [filenamei, pathname] = uiputfile({'*.mat';'*.*'},['Save',32,'"',ERP_FFT.erpname,'"', 32,'as'],fullfile(pathName,figure_name));
                if isequal(filenamei,0)
                    disp('User selected Cancel')
                    return
                else
                    [pathx, filename, ext] = fileparts(filenamei);
                    ext = '.mat';
                    filename = [filename ext];
                end
                
                if strcmpi(ext,'.mat')
                    [ERP_FFT, issave, ERPCOM] = pop_savemyerp(ERP_FFT, 'erpname', ERP_FFT.erpname, 'filename', filename, 'filepath',pathname);
                    [~, ALLERPCOM] = erphistory(ERP_FFT, ALLERPCOM, ERPCOM);
                end
                
                %%save as '.csv'
            elseif ind==2
                def  = erpworkingmemory('f_export2csvGUI');
                if isempty(def)
                    def = {1, 1, 1, 3, ''};
                end
                def{5} = fullfile(pathName,ERP_FFT.filename);
                answer_export = f_export2csvGUI(ERP_FFT,def);
                erpworkingmemory('f_export2csvGUI',answer_export);
                if isempty(answer_export)
                    beep;
                    disp('User selected cancel!!!');
                    return;
                end
                binArray = [1:ERP_FFT.nbin];
                decimal_num = answer_export{4};
                istime =answer_export{1} ;
                electrodes=answer_export{2} ;
                transpose=answer_export{3};
                filenamei = answer_export{5};
                [pathx, filename, ext] = fileparts(filenamei);
                ext = '.csv';
                if isempty(pathx)
                    pathx =cd;
                end
                filename = [filename ext];
                mkdir([pathx,filesep]);
                try
                    export2csv_spectranl_analysis(ERP_FFT,fullfile(pathx,filename), binArray,istime, electrodes,transpose,  decimal_num);
                catch
                    beep;
                    observe_ERPDAT.Process_messg =3;
                    disp('Fail to save selected ERPset as ".csv"!!!');
                    return;
                end
            end
        end
        erpworkingmemory('f_ERP_proces_messg','Spectral Analysis - Save');
        observe_ERPDAT.Process_messg =2;
    end


%%-------------------Setting for advance option---------------------------
    function  spectral_advanced(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=9
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        pathName_folder =  erpworkingmemory('ERP_save_folder');
        if isempty(pathName_folder)
            pathName_folder =  cd;
        end
        if gui_erp_spectral.hamwin_on.Value
            iswindowed =1;
        else
            iswindowed = 0;
        end
        try
            def =  erpworkingmemory('f_spectral_analysis_adavance');
        catch
            def = {1,[], [], [1 16], 1, 1,1,0};
        end
        if isempty(def)
            def = {1,[], [], [1 16], 1, 1,1,0};
        end
        try
            ALLERPCOM = evalin('base','ALLERPCOM');
        catch
            ALLERPCOM = [];
            assignin('base','ALLERPCOM',ALLERPCOM);
        end
        Selected_erpset =  estudioworkingmemory('selectederpstudio');
        if isempty(Selected_erpset)
            Selected_erpset =  length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = Selected_erpset;
            estudioworkingmemory('selectederpstudio',Selected_erpset);
        end
        
        BinArray = estudioworkingmemory('ERP_BinArray');
        ChanArray =  estudioworkingmemory('ERP_ChanArray');
        [chk, msgboxText] = f_ERP_chckbinandchan(observe_ERPDAT.ERP, BinArray, [],1);
        if chk(1)==1
            BinArray =  [1:observe_ERPDAT.ERP.nbin];
        end
        [chk, msgboxText] = f_ERP_chckbinandchan(observe_ERPDAT.ERP,[], ChanArray,2);
        if chk(2)==1
            ChanArray =  [1:observe_ERPDAT.ERP.nchan];
        end
        def{2} = BinArray;
        def{3} = ChanArray;
        
        ERP_d =f_getFFTfromERP(observe_ERPDAT.ERP,iswindowed);
        
        
        defaulpar1 = f_spectral_analysis_advance(ERP_d,def);
        if isempty(defaulpar1)
            beep;
            disp('User selected cancel!!!');
            return;
        end
        erpworkingmemory('f_spectral_analysis_adavance',defaulpar1);
        
        BinArray = defaulpar1{2};
        ChanArray = defaulpar1{3};
        
        FreqRange = defaulpar1{4};
        FreqTick = defaulpar1{5};
        RowNum = defaulpar1{6};
        ColumnNum = defaulpar1{7};
        Save_label =   defaulpar1{8};
        if Save_label
            try
                [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
            catch
                ColorB_def = [0.7020 0.77 0.85];
            end
            oldcolor = get(0,'DefaultUicontrolBackgroundColor');
            set(0,'DefaultUicontrolBackgroundColor',ColorB_def);
            [ind,tf] = listdlg('ListString',{'".mat"','".csv"'},'SelectionMode','single','PromptString','Please select a type to export to...','Name','Export Spctrum for Selected ERPset to','OKString','Ok');
            set(0,'DefaultUicontrolBackgroundColor',[1 1 1]);
            
            if isempty(ind)
                beep;
                disp(['User selected cancel']);
                return;
            end
        end
        
        %%Plot the spectrum for the selected ERPset
        % Loop start for the selected ERPsets        try
        for Numoferpset = 1:numel(Selected_erpset)
            %%%
            ERP_curret_s = observe_ERPDAT.ALLERP(Selected_erpset(Numoferpset));
            if strcmp(ERP_curret_s.datatype,'ERP')
                ERP_FFT = f_getFFTfromERP(ERP_curret_s,iswindowed);
            elseif strcmp(ERP_curret_s.datatype,'EFFT')
                ERP_FFT = ERP_curret_s;
            else
                disp(['Please selected ERPsets']);
                return;
            end
            if isempty(ColumnNum)
                ColumnNum = 1;
            end
            
            if isempty(ChanArray)
                ChanArray =  [1:ERP_curret_s.nchan];
            end
            
            if isempty(RowNum)
                RowNum = ceil(numel(ChanArray)/ColumnNum);
            end
            if isempty(BinArray)
                BinArray = [1:ERP_curret_s.nbin];
            end
            
            if any(BinArray(:)> ERP_FFT.nbin)
                BinArray = [1:ERP_FFT.nbin];
            end
            
            if any(ChanArray(:)> ERP_FFT.nchan)
                ChanArray = [1:ERP_FFT.nchan];
            end
            if isempty(FreqRange) || FreqRange(2)>ERP_FFT.times(end)
                FreqRange=[ERP_FFT.times(1), ERP_FFT.times(end)];
                FreqTick = default_time_ticks(ERP_FFT, FreqRange);
                FreqTick = str2num(FreqTick{1});
            end
            if isempty(FreqTick)
                FreqTick = default_time_ticks(ERP_FFT, FreqRange);
                FreqTick = str2num(FreqTick{1});
            end
            [xxx, latsamp, latdiffms] = closest(ERP_FFT.times, FreqRange);
            tmin = latsamp(1);
            tmax = latsamp(2);
            ERP_FFT.bindata = ERP_FFT.bindata(ChanArray,tmin:tmax,BinArray);
            ERP_FFT.nbin = numel(BinArray);
            ERP_FFT.nchan = numel(ChanArray);
            ERP_FFT.chanlocs =  ERP_FFT.chanlocs(ChanArray);
            ERP_FFT.bindescr =  ERP_FFT.bindescr(BinArray);
            ERP_FFT.times = ERP_FFT.times(tmin:tmax);
            ERP_FFT.xmin = ERP_FFT.times(1);
            ERP_FFT.xmax = ERP_FFT.times(end);
            ERP_FFT.pnts = numel(ERP_FFT.times);
            if  strcmp(ERP_curret_s.datatype,'ERP')
                if gui_erp_spectral.amplitude.Value
                    ERP_FFT.bindata  = abs(ERP_FFT.bindata);
                    figure_name = ['Spectral analysis: Amplitude for ',32,ERP_FFT.erpname];
                elseif gui_erp_spectral.phase.Value
                    ERP_FFT.bindata  = angle(ERP_FFT.bindata);
                    figure_name = ['Spectral analysis: Phase for ',32,ERP_FFT.erpname];
                elseif  gui_erp_spectral.power.Value
                    ERP_FFT.bindata  = abs(ERP_FFT.bindata).^2;
                    figure_name = ['Spectral analysis: Power for ',32,ERP_FFT.erpname];
                elseif gui_erp_spectral.db.Value
                    ERP_FFT.bindata  = 20*log10(abs(ERP_FFT.bindata));
                    figure_name = ['Spectral analysis: dB for ',32,ERP_FFT.erpname];
                end
            else
                if gui_erp_spectral.amplitude.Value
                    figure_name = [ERP_FFT.erpname,'_Spectrum_amplitude'];
                elseif gui_erp_spectral.phase.Value
                    figure_name = [ERP_FFT.erpname,'_Spectrum_phase'];
                elseif gui_erp_spectral.power.Value
                    figure_name = ['Spectral analysis: Power for ',32,ERP_FFT.erpname];
                    
                elseif gui_erp_spectral.db.Value
                    figure_name = ['Spectral analysis: dB for ',32,ERP_FFT.erpname];
                end
            end
            
            if ~Save_label
                fig = figure('Name',figure_name);
                set(fig,'outerposition',get(0,'screensize'));
                
                line_colors = erpworkingmemory('PWColor');
                if size(line_colors,1)~= ERP_FFT.nbin
                    if ERP_FFT.nbin> size(line_colors,1)
                        line_colors = get_colors(ERP_FFT.nbin);
                    else
                        line_colors = line_colors(1:ERP_FFT.nbin,:,:);
                    end
                end
                if isempty(line_colors)
                    line_colors = get_colors(ERP_FFT.nbin);
                end
                
                count = 0;
                for Numofcolumn = 1:ColumnNum
                    for Numofrow = 1: RowNum
                        count = count+1;
                        %                         waitbar(count/(ColumnNum*RowNum),Hw);
                        if ColumnNum*RowNum<5
                            pause(1);
                        end
                        if count>ERP_FFT.nchan
                            break;
                        end
                        p_ax = subplot(RowNum,ColumnNum,count);
                        set(gca,'fontsize',14);
                        hold on;
                        temp = squeeze(ERP_FFT.bindata(:,:,:));
                        for Numofplot  = 1:ERP_FFT.nbin
                            h_p(Numofplot) =  plot(p_ax,ERP_FFT.times,squeeze(ERP_FFT.bindata(count,:,Numofplot)),'LineWidth',1.5,'Color',line_colors(Numofplot,:,:));
                        end
                        axis(p_ax,[floor(ERP_FFT.times(1)),ceil(ERP_FFT.times(end)), 1.1*min(temp(:)) 1.1*max(temp(:))]);
                        xticks(p_ax,FreqTick);
                        xlim([floor(ERP_FFT.times(1)),ceil(ERP_FFT.times(end))]);
                        if count == 1
                            title(p_ax,[ERP_FFT.chanlocs(count).labels],'FontSize',14);
                            legend(p_ax,ERP_FFT.bindescr,'FontSize',14);
                            legend(p_ax,'boxoff');
                        else
                            title(p_ax,ERP_FFT.chanlocs(count).labels,'FontSize',14);
                        end
                        xlabel(p_ax,'Frequency/Hz','FontSize',14);
                        if gui_erp_spectral.phase.Value
                            ylabel(p_ax,'Angle/degree','FontSize',14);
                        elseif gui_erp_spectral.amplitude.Value
                            ylabel(p_ax,'Amplitude/\muV','FontSize',14);
                        elseif gui_erp_spectral.power.Value
                            ylabel(p_ax,'Power/\muV^2','FontSize',14);
                        elseif gui_erp_spectral.db.Value
                            ylabel(p_ax,'Decibels/dB','FontSize',14);
                        end
                        for Numoflabel = 1:length(ERP_FFT.times)
                            X_label{Numoflabel} = [];
                        end
                        set(gca,'TickDir','out');
                        set(gca,'LineWidth',1);
                        set(gca,'Color','w',...
                            'XColor','k',...
                            'YColor','k',...
                            'ZColor','k');
                    end
                end
                hold off;
                clear h_p
            end
            %%Save the transformed data for the selected ERPsets as
            if Save_label
                if  strcmp(ERP_FFT.datatype,'EFFT')
                    if gui_erp_spectral.amplitude.Value
                        figure_name = [ERP_FFT.erpname,'_Spectrum_Amplitude'];
                    elseif gui_erp_spectral.phase.Value
                        figure_name = [ERP_FFT.erpname,'_Spectrum_Phase'];
                    elseif  gui_erp_spectral.power.Value
                        figure_name = [ERP_FFT.erpname,'_Spectrum_Power'];
                    elseif gui_erp_spectral.db.Value
                        figure_name = [ERP_FFT.erpname,'_Spectrum_ dB'];
                    end
                end
                
                if ind==1
                    [filenamei, pathname] = uiputfile({'*.mat';'*.*'},['Save',32,'"',ERP_FFT.erpname,'"', 32,'as'],fullfile(pathName_folder,figure_name));
                    
                    if isequal(filenamei,0)
                        disp('User selected Cancel')
                        return
                    else
                        [pathx, filename, ext] = fileparts(filenamei);
                        if ~strcmpi(ext,'.mat')
                            ext = '.mat';
                        end
                        filename = [filename ext];
                    end
                    if strcmpi(ext,'.mat')
                        [ERP_FFT, issave, ERPCOM] = pop_savemyerp(ERP_FFT, 'erpname', ERP_FFT.erpname, 'filename', filename, 'filepath',pathname);
                        [~, ALLERPCOM] = erphistory(ERP_FFT, ALLERPCOM, ERPCOM);
                    end
                    
                    %%save as '.csv'
                elseif ind==2
                    def  = erpworkingmemory('f_export2csvGUI');
                    if isempty(def)
                        def = {1, 1, 1, 3, ''};
                    end
                    
                    def{5} = fullfile(pathName_folder,ERP_FFT.filename);
                    answer_export = f_export2csvGUI(ERP_FFT,def);
                    erpworkingmemory('f_export2csvGUI',answer_export);
                    if isempty(answer_export)
                        beep;
                        disp('User selected cancel!!!');
                        return;
                    end
                    binArray = [1:ERP_FFT.nbin];
                    decimal_num = answer_export{4};
                    istime =answer_export{1} ;
                    electrodes=answer_export{2} ;
                    transpose=answer_export{3};
                    filenamei = answer_export{5};
                    [pathx, filename, ext] = fileparts(filenamei);
                    if ~strcmpi(ext,'.csv')
                        ext = '.csv';
                    end
                    if isempty(pathx)
                        pathx =cd;
                    end
                    filename = [filename ext];
                    mkdir([pathx,filesep]);
                    try
                        export2csv_spectranl_analysis(ERP_FFT,fullfile(pathx,filename), binArray,istime, electrodes,transpose,  decimal_num);
                    catch
                        beep;
                        disp('Fail to save selected ERPset as ".csv"!!!');
                        return;
                    end
                end
            end
        end%%end loop for ERPSET
    end


%%-------------------Setting for the whole panel of fitering based on ALLERP and CURRENTERP--------------
    function Count_currentERPChanged(~,~)
        if observe_ERPDAT.Count_currentERP~=10
            return;
        end
        if  isempty(observe_ERPDAT.ERP) || isempty(observe_ERPDAT.ALLERP) || strcmp(observe_ERPDAT.ERP.datatype,'EFFT')
            Enable_label = 'off';
        else
            Enable_label = 'on';
        end
        gui_erp_spectral.advanced.Enable = Enable_label;
        gui_erp_spectral.save.Enable = Enable_label;
        gui_erp_spectral.plot.Enable = Enable_label;
        gui_erp_spectral.phase.Enable = Enable_label;
        gui_erp_spectral.amplitude.Enable =Enable_label;
        gui_erp_spectral.power.Enable = Enable_label;
        gui_erp_spectral.db.Enable = Enable_label;
        gui_erp_spectral.hamwin_on.Enable =Enable_label;
        gui_erp_spectral.hamwin_off.Enable = Enable_label;
        gui_erp_spectral.cancel.Enable = Enable_label;
        observe_ERPDAT.Count_currentERP=11;
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

%%-------execute "apply" before doing any change for other panels----------
    function erp_two_panels_change(~,~)
        if  isempty(observe_ERPDAT.ALLERP)|| isempty(observe_ERPDAT.ERP)
            return;
        end
        ChangeFlag =  estudioworkingmemory('ERPTab_spectral');
        if ChangeFlag~=1
            return;
        end
        spectral_plot();
        gui_erp_spectral.plot.BackgroundColor =  [1 1 1];
        gui_erp_spectral.plot.ForegroundColor = [0 0 0];
        ERP_filtering_box.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_spectral.save.BackgroundColor =  [1 1 1];
        gui_erp_spectral.save.ForegroundColor = [0 0 0];
        gui_erp_spectral.advanced.BackgroundColor =  [1 1 1];
        gui_erp_spectral.advanced.ForegroundColor = [0 0 0];
        gui_erp_spectral.cancel.BackgroundColor =  [1 1 1];
        gui_erp_spectral.cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_spectral',0);
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
            gui_erp_spectral.advanced.BackgroundColor =  [1 1 1];
            gui_erp_spectral.advanced.ForegroundColor = [0 0 0];
            gui_erp_spectral.cancel.BackgroundColor =  [1 1 1];
            gui_erp_spectral.cancel.ForegroundColor = [0 0 0];
            estudioworkingmemory('ERPTab_spectral',0);
        else
            return;
        end
    end
end
%Progem end: ERP Measurement tool