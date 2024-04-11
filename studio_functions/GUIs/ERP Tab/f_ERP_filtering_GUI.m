%Author: Guanghui ZHANG
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 2022

% ERPLAB Studio

function varargout = f_ERP_filtering_GUI(varargin)

global observe_ERPDAT;
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);
addlistener(observe_ERPDAT,'erp_two_panels_change',@erp_two_panels_change);
addlistener(observe_ERPDAT,'Reset_erp_panel_change',@Reset_erp_panel_change);
%%---------------------------gui-------------------------------------------
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.702,0.77,0.85];
end
if nargin == 0
    fig = figure(); % Parent figure
    ERP_filtering_box = uiextras.BoxPanel('Parent', fig, 'Title', 'Filtering', 'Padding', 5,...
        'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    ERP_filtering_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Filtering', 'Padding', 5,...
        'BackgroundColor',ColorB_def);
else
    ERP_filtering_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Filtering', 'Padding', 5,...
        'FontSize', varargin{2},'BackgroundColor',ColorB_def);%, 'HelpFcn', @filter_help
end

gui_erp_filtering = struct();

try
    FonsizeDefault = varargin{2};
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
    FonsizeDefault = f_get_default_fontsize();
end
erp_filtering_gui(FonsizeDefault);

varargout{1} = ERP_filtering_box;
%%********************Draw the GUI for ERP measurement tool*****************
    function erp_filtering_gui(FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.702,0.77,0.85];
        end
        
        Enable_label = 'off';
        
        nchan =1;
        fs = 256;
        defx = {0 30 2 1:nchan 1 'butter' 0 []};
        def  = estudioworkingmemory('pop_filterp');
        if isempty(def)
            def = defx;
        end
        if fs <=0
            fs =256;
        end
        locutoff    = def{1}; % for high pass filter
        hicutoff    = def{2}; % for low pass filter
        filterorder = def{3};
        chanArray   = def{4};
        filterallch = def{5};
        fdesign     = def{6};
        remove_dc   = def{7};
        
        typef = 0;
        filterorder=2;
        
        if locutoff >= fs/2 || locutoff<=0
            locutoff  = floor(fs/2)-1;
        end
        
        
        if hicutoff>=fs/2 || hicutoff<=0
            hicutoff = floor(fs/2)-1;
        end
        
        if isempty(locutoff)
            locutoff = 0;
        end
        
        if isempty(hicutoff)
            hicutoff = 0;
        end
        
        locutoff = 0;
        hicutoff = 20;
        highpass_toggle_value = 1;
        lowpass_toggle_value =1;
        hp_halfamp_enable = 'on';
        lp_halfamp_Enable = 'on';
        hp_halfpow_string = '---';
        lp_halfpow_string = '---';
        Apply_ERP_filter_enable = 'on';
        Advance_ERP_filter_enable = 'on';
        hp_tog_enable = 'on';
        lp_tog_enable = 'on';
        
        hp_halfamp_enable = 'off';
        lp_halfamp_Enable = 'off';
        Apply_ERP_filter_enable = 'off';
        Advance_ERP_filter_enable = 'off';
        
        lp_tog_enable = 'off';
        hp_tog_enable = 'off';
        hp_halfpow_string ='--';
        lp_halfpow_string ='---';
        
        gui_erp_filtering.filtering = uiextras.VBox('Parent',ERP_filtering_box,'BackgroundColor',ColorB_def);
        
        %%-----------------------------Setting for bin and chan--------------------
        gui_erp_filtering.bin_chan_title = uiextras.HBox('Parent',gui_erp_filtering.filtering,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',gui_erp_filtering.bin_chan_title,'String','Bin and Chan Selection:','FontWeight','bold',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_filtering.filter_bin_chan_option = uiextras.HBox('Parent',  gui_erp_filtering.filtering,'Spacing',1,'BackgroundColor',ColorB_def);
        gui_erp_filtering.all_bin_chan = uicontrol('Style', 'radiobutton','Parent', gui_erp_filtering.filter_bin_chan_option,...
            'String','All (Recommended)','callback',@All_bin_chan,'Value',1,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_filtering.all_bin_chan.KeyPressFcn= @erp_filter_presskey;
        gui_erp_filtering.Selected_bin_chan = uicontrol('Style', 'radiobutton','Parent', gui_erp_filtering.filter_bin_chan_option,...
            'String','Selected bin & chan','callback',@Selected_bin_chan,'Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_filtering.Selected_bin_chan.KeyPressFcn= @erp_filter_presskey;
        set(gui_erp_filtering.filter_bin_chan_option, 'Sizes',[130  170]);
        gui_erp_filtering.params{1} = gui_erp_filtering.all_bin_chan.Value;
        
        %%--------------------------Setting for IIR filter------------------------------
        gui_erp_filtering.IIR_title = uiextras.HBox('Parent',gui_erp_filtering.filtering,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',gui_erp_filtering.IIR_title,'String','Setting for IIR Butterworth:',...
            'FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        gui_erp_filtering.filt_grid = uiextras.Grid('Parent',gui_erp_filtering.filtering,'BackgroundColor',ColorB_def);
        % first column
        uiextras.Empty('Parent',gui_erp_filtering.filt_grid); % 1A
        gui_erp_filtering.hp_tog = uicontrol('Style','checkbox','Parent',gui_erp_filtering.filt_grid,'String','High Pass',...
            'callback',@highpass_toggle,'Value',0,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 1B
        gui_erp_filtering.hp_tog.KeyPressFcn= @erp_filter_presskey;
        gui_erp_filtering.params{2} = gui_erp_filtering.hp_tog.Value;
        gui_erp_filtering.lp_tog = uicontrol('Style','checkbox','Parent',gui_erp_filtering.filt_grid,'String','Low Pass',...
            'callback',@lowpass_toggle,'Value',1,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 1C
        gui_erp_filtering.lp_tog.KeyPressFcn= @erp_filter_presskey;
        gui_erp_filtering.params{5} = gui_erp_filtering.lp_tog.Value;
        % second column
        uicontrol('Style','text','Parent',gui_erp_filtering.filt_grid,'String','Half Amp.','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 2A
        gui_erp_filtering.hp_halfamp = uicontrol('Style','edit','Parent',gui_erp_filtering.filt_grid,...
            'callback',@hp_halfamp,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); % 2B
        gui_erp_filtering.hp_halfamp.KeyPressFcn= @erp_filter_presskey;
        gui_erp_filtering.params{3} = str2num(gui_erp_filtering.hp_halfamp.String);
        if strcmp(hp_halfamp_enable,'off')
            if typef<2
                gui_erp_filtering.hp_halfamp.String = '0';
            else
                gui_erp_filtering.hp_halfamp.String = '60';
            end
            
        else
            gui_erp_filtering.hp_halfamp.String =  num2str(locutoff);
        end
        gui_erp_filtering.lp_halfamp = uicontrol('Style','edit','Parent',gui_erp_filtering.filt_grid,...
            'callback',@lp_halfamp,'Enable',lp_halfamp_Enable,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); % 2C
        gui_erp_filtering.lp_halfamp.KeyPressFcn= @erp_filter_presskey;
        gui_erp_filtering.params{6} = str2num(gui_erp_filtering.lp_halfamp.String);
        if strcmp(lp_halfamp_Enable,'off')
            gui_erp_filtering.lp_halfamp.String = '20';
        else
            gui_erp_filtering.lp_halfamp.String =  num2str(hicutoff);
        end
        % third column
        uicontrol('Style','text','Parent',gui_erp_filtering.filt_grid,'String','Half Power','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 3A
        gui_erp_filtering.hp_halfpow = uicontrol('Style','text','Parent',gui_erp_filtering.filt_grid,...
            'String',hp_halfpow_string,'Enable','off','BackgroundColor','y','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); % 3B
        gui_erp_filtering.params{4} = str2num(gui_erp_filtering.hp_halfpow.String);
        gui_erp_filtering.lp_halfpow = uicontrol('Style','text','Parent',gui_erp_filtering.filt_grid,...
            'String',lp_halfpow_string,'Enable','off','BackgroundColor','y','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); % 3C
        gui_erp_filtering.params{7} = str2num(gui_erp_filtering.lp_halfpow.String);
        % fourth column
        uiextras.Empty('Parent',gui_erp_filtering.filt_grid); % 4A
        uicontrol('Style','text','Parent',gui_erp_filtering.filt_grid,'String','Hz','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 4B
        uicontrol('Style','text','Parent',gui_erp_filtering.filt_grid,'String','Hz','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 4C
        set(gui_erp_filtering.filt_grid, 'ColumnSizes',[90 70 70 40],'RowSizes',[20 -1 -1]);
        
        
        gui_erp_filtering.rolloff_row = uiextras.HBox('Parent', gui_erp_filtering.filtering,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',gui_erp_filtering.rolloff_row,'String','Roll-Off','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 1D
        Roll_off = {'12','24','36','48'};
        gui_erp_filtering.roll_off = uicontrol('Style','popupmenu','Parent',gui_erp_filtering.rolloff_row,'String',Roll_off,...
            'callback',@ERP_filtering_rolloff,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); % 2D
        gui_erp_filtering.roll_off.KeyPressFcn= @erp_filter_presskey;
        gui_erp_filtering.params{8} =gui_erp_filtering.roll_off.Value;
        if filterorder ==2
            gui_erp_filtering.roll_off.Value = 1;
        elseif filterorder ==4
            gui_erp_filtering.roll_off.Value = 2;
            
        elseif filterorder ==6
            gui_erp_filtering.roll_off.Value = 3;
            
        elseif filterorder ==8
            gui_erp_filtering.roll_off.Value = 4;
        end
        uicontrol('Style','text','Parent',gui_erp_filtering.rolloff_row,'String','dB/Octave','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 3D
        
        
        gui_erp_filtering.params{9} = 0;
        %         uiextras.Empty('Parent',gui_erp_filtering.REMOVE_DC);
        gui_erp_filtering.filt_buttons = uiextras.HBox('Parent', gui_erp_filtering.filtering,'BackgroundColor',ColorB_def);
        %         uiextras.Empty('Parent',  gui_erp_filtering.filt_buttons);
        gui_erp_filtering.cancel=uicontrol('Style','pushbutton','Parent',gui_erp_filtering.filt_buttons,'String','Cancel',...
            'callback',@ERP_filter_cancel,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        gui_erp_filtering.advanced = uicontrol('Style','pushbutton','Parent',gui_erp_filtering.filt_buttons,'String','Advanced',...
            'callback',@advanced_ERP_filter,'Enable',Advance_ERP_filter_enable,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        gui_erp_filtering.apply = uicontrol('Style','pushbutton','Parent',gui_erp_filtering.filt_buttons,'String','Run',...
            'callback',@ERP_filter_apply,'Enable',Apply_ERP_filter_enable,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        set( gui_erp_filtering.filtering,'Sizes',[20 20 20 80 20 30]);
        
        estudioworkingmemory('ERPTab_filter',0);
    end

%%****************************************************************************************************************************************
%%*******************   Subfunctions   ***************************************************************************************************
%%****************************************************************************************************************************************

%%----------------------all bin and all chan-------------------------------
    function All_bin_chan(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=5
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_filtering.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_filtering.apply.ForegroundColor = [1 1 1];
        ERP_filtering_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_filtering.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_filtering.cancel.ForegroundColor = [1 1 1];
        gui_erp_filtering.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_filtering.advanced.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_filter',1);
        gui_erp_filtering.all_bin_chan.Value = 1;
        gui_erp_filtering.Selected_bin_chan.Value = 0;
    end

%%----------------------selected bin and all chan-------------------------------
    function Selected_bin_chan(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=5
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_filtering.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_filtering.apply.ForegroundColor = [1 1 1];
        ERP_filtering_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_filtering.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_filtering.cancel.ForegroundColor = [1 1 1];
        gui_erp_filtering.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_filtering.advanced.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_filter',1);
        gui_erp_filtering.all_bin_chan.Value = 0;
        gui_erp_filtering.Selected_bin_chan.Value = 1;
    end

%%--------------------------------High-pass filtering toggle------------------
    function  highpass_toggle(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=5
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_filtering.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_filtering.apply.ForegroundColor = [1 1 1];
        ERP_filtering_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_filtering.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_filtering.cancel.ForegroundColor = [1 1 1];
        gui_erp_filtering.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_filtering.advanced.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_filter',1);
        
        fs = observe_ERPDAT.ERP.srate;
        locutoff = 0.1;
        try
            filterorder = 2*gui_erp_filtering.roll_off.Value;
        catch
            filterorder =2;
            gui_erp_filtering.roll_off.Value=1;
        end
        typef = 0;
        
        if source.Value == 0
            gui_erp_filtering.hp_halfamp.Enable ='off';
            gui_erp_filtering.hp_halfpow.Enable ='off';
            gui_erp_filtering.hp_halfamp.String = '0';
            gui_erp_filtering.hp_halfpow.String = '---';
            if gui_erp_filtering.lp_tog.Value ==0
                gui_erp_filtering.roll_off.Enable = 'off';
            end
        else
            [bt, at, labelf, v, frec3dB, xdB_at_fx, orderx] = filter_tf(typef, filterorder,0,locutoff,fs);
            gui_erp_filtering.hp_tog.Value =1;
            gui_erp_filtering.hp_halfamp.Enable ='on';
            gui_erp_filtering.hp_halfamp.String = num2str(locutoff);
            gui_erp_filtering.hp_halfpow.String = num2str(frec3dB(1));
            gui_erp_filtering.hp_halfpow.Enable ='off';
            gui_erp_filtering.hp_halfpow.String = num2str(frec3dB);
            gui_erp_filtering.roll_off.Enable = 'on';
        end
        
    end


%%--------------------------------Low-pass filtering toggle------------------
    function  lowpass_toggle(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=5
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_filtering.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_filtering.apply.ForegroundColor = [1 1 1];
        ERP_filtering_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_filtering.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_filtering.cancel.ForegroundColor = [1 1 1];
        gui_erp_filtering.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_filtering.advanced.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_filter',1);
        
        try
            fs = observe_ERPDAT.ERP.srate;
        catch
            return;
        end
        
        typef = 0;
        try
            filterorder = 2*gui_erp_filtering.roll_off.Value;
        catch
            filterorder =2;
            gui_erp_filtering.roll_off.Value=1;
        end
        
        hicutoff = floor((fs/2-1)*5/10);
        if source.Value == 0
            gui_erp_filtering.lp_halfamp.Enable ='off';
            gui_erp_filtering.lp_halfpow.Enable ='off';
            gui_erp_filtering.lp_halfamp.String = '0';
            gui_erp_filtering.lp_halfpow.String = '---';
            if gui_erp_filtering.hp_tog.Value ==0
                gui_erp_filtering.roll_off.Enable = 'off';
            end
        else
            [bt, at, labelf, v, frec3dB, xdB_at_fx, orderx] = filter_tf(typef, filterorder, hicutoff,0, fs);
            gui_erp_filtering.lp_tog.Value =1;
            gui_erp_filtering.lp_halfamp.Enable ='on';
            gui_erp_filtering.lp_halfamp.String = num2str(hicutoff);
            gui_erp_filtering.lp_halfpow.String = num2str(frec3dB);
            gui_erp_filtering.lp_halfpow.Enable ='off';
            gui_erp_filtering.roll_off.Enable = 'on';
        end
    end



%%---------------------Half amplitude for high pass filtering--------------
    function hp_halfamp(Source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=5
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_filtering.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_filtering.apply.ForegroundColor = [1 1 1];
        ERP_filtering_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_filtering.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_filtering.cancel.ForegroundColor = [1 1 1];
        gui_erp_filtering.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_filtering.advanced.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_filter',1);
        
        try
            fs = observe_ERPDAT.ERP.srate;
        catch
            return;
        end
        
        typef = 0;
        try
            filterorder = 2*gui_erp_filtering.roll_off.Value;
        catch
            filterorder =2;
            gui_erp_filtering.roll_off.Value=1;
        end
        
        valueh = str2num(Source.String);
        if length(valueh)~=1
            msgboxText =  ['Filtering - Invalid input for high-pass filter cutoff'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        if valueh>=fs/2
            msgboxText =  ['Filtering - The high-pass filter cutoff should be smaller than',32,num2str(fs/2),'Hz'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        if valueh<0.001
            msgboxText =  ['Filtering - We strongly recommend the high-pass filter cutoff is larger than 0.001Hz'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        valuel = 0;
        [bt, at, labelf, v, frec3dB, xdB_at_fx, orderx] = filter_tf(typef, filterorder, valuel, valueh, fs);
        gui_erp_filtering.hp_halfamp.Enable ='on';
        gui_erp_filtering.hp_halfamp.String = num2str(valueh);
        gui_erp_filtering.hp_halfpow.String = num2str(frec3dB);
        gui_erp_filtering.hp_halfpow.Enable ='off';
    end



%%---------------------Half amplitude for low pass filtering---------------
    function lp_halfamp(Source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=5
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_filtering.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_filtering.apply.ForegroundColor = [1 1 1];
        ERP_filtering_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_filtering.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_filtering.cancel.ForegroundColor = [1 1 1];
        gui_erp_filtering.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_filtering.advanced.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_filter',1);
        
        try
            fs = observe_ERPDAT.ERP.srate;
        catch
            return;
        end
        try
            filterorder = 2*gui_erp_filtering.roll_off.Value;
        catch
            filterorder =2;
            gui_erp_filtering.roll_off.Value=1;
        end
        valuel = str2num(Source.String);
        if length(valuel)~=1 || isempty(valuel)
            msgboxText =  ['Filtering - Invalid input for low-pass filter cutoff'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        if valuel>=fs/2
            msgboxText =  ['Filtering - The low-pass filter cutoff should be smaller than',32,num2str(fs/2),'Hz'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        if valuel<0.001
            msgboxText =  ['Filtering - We strongly recommend the low-pass filter cutoff is larger than 0.001Hz'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        %if the valueh is between 0.1 and fs/2 Hz
        typef = 0;
        valueh = 0;
        [bt, at, labelf, v, frec3dB, xdB_at_fx, orderx] = filter_tf(typef, filterorder, valuel, valueh, fs);
        gui_erp_filtering.lp_halfamp.Enable ='on';
        gui_erp_filtering.lp_halfamp.String = num2str(valuel);
        gui_erp_filtering.lp_halfpow.String = num2str(frec3dB(1));
        gui_erp_filtering.lp_halfpow.Enable ='off';
    end


%%----------------------------Setting for roll-off-------------------------
    function ERP_filtering_rolloff(Source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=5
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_filtering.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_filtering.apply.ForegroundColor = [1 1 1];
        ERP_filtering_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_filtering.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_filtering.cancel.ForegroundColor = [1 1 1];
        gui_erp_filtering.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_filtering.advanced.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_filter',1);
        
        
        Source_value = Source.Value;
        try
            nchan = observe_ERPDAT.ERP.nchan;
            fs = observe_ERPDAT.ERP.srate;
        catch
            return;
        end
        filterorder = 2*Source_value;
        typef = 0;
        valuel  = str2num(gui_erp_filtering.lp_halfamp.String);%% for low-pass filter
        valueh  = str2num(gui_erp_filtering.hp_halfamp.String);%%for high-pass filter
        
        if gui_erp_filtering.lp_tog.Value ==1
            
            if length(valuel)~=1 || isempty(valuel)
                msgboxText =  ['Filtering - Invalid input for low-pass filter cutoff'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            if valuel>=fs/2
                msgboxText =  ['Filtering - The low-pass filter cutoff should be smaller than',32,num2str(fs/2),'Hz'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            
            if gui_erp_filtering.hp_tog.Value ==0
                if valuel<0.001
                    msgboxText =  ['Filtering - We strongly recommend the low-pass filter cutoff is larger than 0.001Hz'];
                    titlNamerro = 'Warning for ERP Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    return;
                end
            end
            
        end
        
        if gui_erp_filtering.hp_tog.Value ==1
            if length(valueh)~=1
                msgboxText =  ['Filtering - Invalid input for high-pass filter cutoff'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            
            if valueh>=fs/2
                msgboxText =  ['Filtering - The high-pass filter cutoff should be smaller than',32,num2str(fs/2),'Hz'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            
            if gui_erp_filtering.lp_tog.Value ==0
                if valueh<0.001
                    msgboxText =  ['Filtering - We strongly recommend the high-pass filter cutoff is larger than 0.001Hz'];
                    titlNamerro = 'Warning for ERP Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    return;
                end
            end
            
        end
        if gui_erp_filtering.hp_tog.Value ==1 && gui_erp_filtering.lp_tog.Value ==1
            if valueh >0 && valueh >0 && valueh >=valuel
                msgboxText =  ['Filtering - The lowest bandpass cuttoff is the highest bandpass cuttoff'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            if valueh==0 && valuel==0
                msgboxText =  ['Filtering - Either Lowest bandpass cuttoff or  the highest bandpass cuttoff or both is larger than 0.01Hz'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
        end
        
        if valuel> 0 && valueh ==0
            [bt, at, labelf, v, frec3dB, xdB_at_fx, orderx] = filter_tf(typef, filterorder, valuel, 0, fs);
            gui_erp_filtering.lp_halfpow.String = num2str(frec3dB);
        elseif valuel== 0 && valueh > 0
            [bt, at, labelf, v, frec3dB, xdB_at_fx, orderx] = filter_tf(typef, filterorder,0, valueh,fs);
            gui_erp_filtering.hp_halfpow.String = num2str(frec3dB);
        elseif valuel> 0 && valueh > 0
            [bt, at, labelf, v, frec3dB, xdB_at_fx, orderx] = filter_tf(typef, filterorder,valuel, valueh,fs);
            gui_erp_filtering.lp_halfpow.String = num2str(frec3dB(1));
            gui_erp_filtering.hp_halfpow.String = num2str(frec3dB(2));
        end
        
    end


%%------------------Setting for apply option--------------------------------
    function ERP_filter_apply(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        nchan = observe_ERPDAT.ERP.nchan;
        fs = observe_ERPDAT.ERP.srate;
        defx = {0 30 2 1:nchan 1 'butter' 0 []};
        def  = estudioworkingmemory('pop_filterp');
        if isempty(def)
            def = defx;
        end
        
        remove_dc =  0;
        filterorder = 2*gui_erp_filtering.roll_off.Value;
        locutoff = str2num(gui_erp_filtering.hp_halfamp.String);%%
        hicutoff = str2num(gui_erp_filtering.lp_halfamp.String);
        if isempty(locutoff)
            locutoff =0;
        end
        if isempty(hicutoff)
            hicutoff =0;
        end
        if gui_erp_filtering.lp_tog.Value ==1
            if length(hicutoff)~=1 || isempty(hicutoff)
                msgboxText =  ['Filtering - Invalid input for low-pass filter cutoff'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            if hicutoff>=fs/2
                msgboxText =  ['Filtering - The low-pass filter cutoff should be smaller than',32,num2str(fs/2),'Hz'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            if gui_erp_filtering.hp_tog.Value ==0
                if hicutoff<0.001
                    msgboxText =  ['Filtering - We strongly recommend the low-pass filter cutoff is larger than 0.001Hz'];
                    titlNamerro = 'Warning for ERP Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    return;
                end
            end
        end
        
        if gui_erp_filtering.hp_tog.Value ==1
            if length(locutoff)~=1
                msgboxText =  ['Filtering - Invalid input for high-pass filter cutoff'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            if locutoff>=fs/2
                msgboxText =  ['Filtering - The high-pass filter cutoff should be smaller than',32,num2str(fs/2),'Hz'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            if gui_erp_filtering.lp_tog.Value ==0
                if locutoff<0.001
                    msgboxText =  ['Filtering - We strongly recommend the high-pass filter cutoff is larger than 0.001Hz'];
                    titlNamerro = 'Warning for ERP Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    return;
                end
            end
        end
        if gui_erp_filtering.hp_tog.Value ==1 && gui_erp_filtering.lp_tog.Value ==1
            if locutoff==0 && hicutoff==0
                msgboxText =  ['Filtering - Either Lowest bandpass cuttoff or  the highest bandpass cuttoff or both is larger than 0.01Hz'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
        end
        if remove_dc==1
            rdc = 'on';
        else
            rdc = 'off';
        end
        filterallch = def{5};
        if filterallch
            chanArray = 1:nchan;
        end
        fdesign = 'butter';
        if ~strcmpi(fdesign, 'notch') && locutoff==0 && hicutoff>0  % Butter (IIR) and FIR%% low-pass filter
            ftype = 'lowpass';
            cutoff = hicutoff;
        elseif ~strcmpi(fdesign, 'notch') && locutoff>0 && hicutoff==0 % Butter (IIR) and FIR
            ftype = 'highpass';
            cutoff = locutoff;
        elseif ~strcmpi(fdesign, 'notch') && locutoff>0 && hicutoff>0 && locutoff<hicutoff% Butter (IIR) and FIR
            ftype = 'bandpass';
            cutoff = [locutoff hicutoff];
        elseif ~strcmpi(fdesign, 'notch') && locutoff>0 && hicutoff>0 && locutoff>hicutoff% Butter (IIR) and FIR
            ftype = 'simplenotch';
            cutoff = [locutoff hicutoff];
        elseif ~strcmpi(fdesign, 'notch') && locutoff==0 && hicutoff==0 % Butter (IIR) and FIR
            msgboxText =  'I beg your pardon?';
            title = 'EStudio: f_ERP_filtering_GUI() !';
            errorfound(msgboxText, title);
            return;
        else
            msgboxText =  ['Filtering - Invalid type of filter'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        estudioworkingmemory('pop_filterp', {locutoff,hicutoff,filterorder,chanArray,filterallch,fdesign,remove_dc});
        
        ERPArray =  estudioworkingmemory('selectederpstudio');
        if isempty(ERPArray) || any(ERPArray> length(observe_ERPDAT.ALLERP))
            ERPArray =  length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = ERPArray;
            estudioworkingmemory('selectederpstudio',ERPArray);
        end
        
        
        %%-------------loop start for filtering the selected ERPsets-----------------------------------
        estudioworkingmemory('f_ERP_proces_messg','Filtering');
        observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
        try ALLERPCOM = evalin('base','ALLERPCOM');catch ALLERPCOM = []; end
        
        estudioworkingmemory('ERPTab_filter',0);
        gui_erp_filtering.apply.BackgroundColor =  [1 1 1];
        gui_erp_filtering.apply.ForegroundColor = [0 0 0];
        ERP_filtering_box.TitleColor= [ 0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_filtering.cancel.BackgroundColor =  [1 1 1];
        gui_erp_filtering.cancel.ForegroundColor = [0 0 0];
        gui_erp_filtering.advanced.BackgroundColor =  [1 1 1];
        gui_erp_filtering.advanced.ForegroundColor = [0 0 0];
        
        gui_erp_filtering.params{1} = gui_erp_filtering.all_bin_chan.Value;
        gui_erp_filtering.params{2} = gui_erp_filtering.hp_tog.Value;
        gui_erp_filtering.params{5} = gui_erp_filtering.lp_tog.Value;
        gui_erp_filtering.params{3} = str2num(gui_erp_filtering.hp_halfamp.String);
        gui_erp_filtering.params{6} = str2num(gui_erp_filtering.lp_halfamp.String);
        gui_erp_filtering.params{4} = str2num(gui_erp_filtering.hp_halfpow.String);
        gui_erp_filtering.params{7} = str2num(gui_erp_filtering.lp_halfpow.String);
        gui_erp_filtering.params{8} =gui_erp_filtering.roll_off.Value;
        gui_erp_filtering.params{9} = 0;
        
        BinArray = [];
        ChanArray = [];
        ALLERP = observe_ERPDAT.ALLERP;
        ALLERP_out = [];
        if gui_erp_filtering.all_bin_chan.Value == 1
            BinArray = [1:observe_ERPDAT.ERP.nbin];
            ChanArray = [1:observe_ERPDAT.ERP.nchan];
        else
            BinArray = estudioworkingmemory('ERP_BinArray');
            ChanArray = estudioworkingmemory('ERP_ChanArray');
        end
        for Numoferp = 1:numel(ERPArray)
            ERP = ALLERP(ERPArray(Numoferp));
            if isempty(ChanArray) || any(ChanArray(:)>ERP.nchan) || any(ChanArray(:)<1)
                ChanArray = [1:ERP.nchan];
            end
            
            if isempty(BinArray) || any(BinArray(:)>ERP.nbin) || any(BinArray(:)<1)
                BinArray = [1:ERP.nbin];
            end
            
            %%Only the slected bin and chan were selected to remove baseline and detrending and others are remiained.
            [ERP, ERPCOM] = pop_filterp(ERP, ChanArray,'binArray',BinArray, 'Filter',ftype, 'Design',  fdesign, 'Cutoff', cutoff, 'Order', filterorder, 'RemoveDC', rdc,...
                'Saveas', 'off', 'History', 'gui');
            if isempty(ERPCOM)
                observe_ERPDAT.Process_messg =2;
                return;
            end
            if Numoferp ==numel(ERPArray)
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
            else
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
            end
            
            if isempty(ALLERP_out)
                ALLERP_out = ERP;
            else
                ALLERP_out(length(ALLERP_out)+1)=ERP;
            end
        end
        
        Answer = f_ERP_save_multi_file(ALLERP_out,1:numel(ERPArray),'_filt');
        if isempty(Answer)
            observe_ERPDAT.Process_messg =2;
            return;
        end
        if ~isempty(Answer{1})
            ALLERP_out = Answer{1};
            Save_file_label = Answer{2};
        end
        for Numoferp =  1:length(ALLERP_out)
            ERP = ALLERP_out(Numoferp);
            if Save_file_label==1
                [pathstr, file_name, ext] = fileparts(ERP.filename);
                ERP.filename = [file_name,'.erp'];
                [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', ERP.filename, 'filepath',ERP.filepath);
                ERPCOM = f_erp_save_history(ERP.erpname,ERP.filename,ERP.filepath);
                if Numoferp ==length(ALLERP_out)
                    [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
                else
                    [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                end
            else
                ERP.filename = '';
                ERP.saved = 'no';
                ERP.filepath = '';
            end
            ALLERP(length(ALLERP)+1) = ERP;
        end
        observe_ERPDAT.ALLERP = ALLERP;
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        estudioworkingmemory('ERPfilter',1);
        try
            Selected_ERP_afd =  [length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1:length(observe_ERPDAT.ALLERP)];
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1;
        catch
            Selected_ERP_afd = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
        end
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
        
        estudioworkingmemory('selectederpstudio',Selected_ERP_afd);
        observe_ERPDAT.Count_currentERP = 1;
        observe_ERPDAT.Process_messg =2;
    end

%%-------------------Setting for advance  option---------------------------
    function advanced_ERP_filter(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        nchan = observe_ERPDAT.ERP.nchan;
        fs = observe_ERPDAT.ERP.srate;
        
        defx = {0 30 2 1:nchan 1 'butter' 0 []};
        def  = estudioworkingmemory('pop_filterp');
        
        if isempty(def)
            def = defx;
        else
            def{4} = def{4}(ismember_bc2(def{4},1:nchan));
        end
        
        def{1} = str2num(gui_erp_filtering.hp_halfamp.String);
        def{2} = str2num(gui_erp_filtering.lp_halfamp.String);
        if gui_erp_filtering.hp_tog.Value ==1
            if isempty(def{1}) || def{1} ==0
                def{1} = 0.01;
            end
        end
        if gui_erp_filtering.lp_tog.Value ==1
            if isempty(def{2}) || def{2} ==0
                def{2} = floor((fs/2-1)*5/10);
            end
        end
        
        def{7} =  0;
        def{8} = [];
        fdesign = 'butter';
        def{3} = 2*gui_erp_filtering.roll_off.Value;
        def{6} = fdesign;
        
        ERPArray =  estudioworkingmemory('selectederpstudio');
        if isempty(ERPArray)
            ERPArray =  length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = ERPArray;
            observe_ERPDAT.Count_currentERP=1;
        end
        
        if gui_erp_filtering.all_bin_chan.Value==0
            BinArray = estudioworkingmemory('ERP_BinArray');
            ChanArray =  estudioworkingmemory('ERP_ChanArray');
        else
            BinArray = 1:observe_ERPDAT.ERP.nchan;
            ChanArray =  1:observe_ERPDAT.ERP.nbin;
        end
        def{5} =0;
        
        def{9} = BinArray;
        def{4} = ChanArray;
        %%call the GUI for advance option
        answer = f_basicfilterGUI2(observe_ERPDAT.ERP, def);
        if isempty(answer)
            return;
        end
        
        defx = {answer{1},answer{2},answer{3},answer{4},answer{5},answer{6},answer{7},answer{8}};
        estudioworkingmemory('pop_filterp',defx);
        
        
        locutoff    = answer{1}; % for high pass filter
        hicutoff    = answer{2}; % for low pass filter
        filterorder = answer{3};
        ChanArray   = answer{4};
        filterallch = answer{5};
        fdesign     = answer{6};
        remove_dc   = answer{7};
        BinArray =  answer{9};
        
        if locutoff >= fs/2 || locutoff< 0
            locutoff  = floor(fs/2)-1;
        end
        if hicutoff>=fs/2 || hicutoff< 0
            hicutoff = floor(fs/2)-1;
        end
        
        if isempty(locutoff)
            locutoff = 0;
        end
        
        if isempty(hicutoff)
            hicutoff = 0;
        end
        %%-----------setting for IIR butter----------------------
        if strcmpi(fdesign,'butter')
            typef = 0;
            gui_erp_filtering.roll_off.Value =  filterorder/2;
            gui_erp_filtering.roll_off.String = {'12','24','36','48'}';
            gui_erp_filtering.roll_off.Enable = 'on';
            %             gui_erp_filtering.DC_remove.Value =  remove_dc;
            %%High-pass filtering
            [bt, at, labelf, v, frec3dB, xdB_at_fx, orderx] = filter_tf(typef, filterorder, hicutoff,locutoff,fs);
            if locutoff > 0 && (isempty(hicutoff) || hicutoff ==0 )
                gui_erp_filtering.hp_tog.Value = 1;
                gui_erp_filtering.hp_tog.Enable ='on';
                gui_erp_filtering.lp_tog.Value = 0;
                gui_erp_filtering.lp_tog.Enable ='on';
                
                gui_erp_filtering.hp_halfamp.String = num2str(locutoff);
                gui_erp_filtering.hp_halfamp.Enable = 'on';
                
                gui_erp_filtering.lp_halfamp.String = num2str(hicutoff);
                gui_erp_filtering.lp_halfamp.Enable = 'off';
                gui_erp_filtering.hp_halfpow.String = num2str(roundn(frec3dB(1),-2));
                gui_erp_filtering.lp_halfpow.String = '---';
            end
            %%Low pass filtering
            if hicutoff > 0 && (isempty(locutoff) || locutoff ==0)
                gui_erp_filtering.lp_tog.Value = 1;
                gui_erp_filtering.lp_tog.Enable ='on';
                gui_erp_filtering.hp_tog.Value = 0;
                gui_erp_filtering.hp_tog.Enable ='on';
                gui_erp_filtering.lp_halfamp.String = num2str(hicutoff);
                gui_erp_filtering.lp_halfamp.Enable = 'on';
                gui_erp_filtering.hp_halfamp.String = num2str(locutoff);
                gui_erp_filtering.hp_halfamp.Enable = 'off';
                gui_erp_filtering.lp_halfpow.String = num2str(roundn(frec3dB(1),-2));
                gui_erp_filtering.hp_halfpow.String = '---';
                
            end
            %%Band pass filtering or notch filtering
            if locutoff >0 && hicutoff>0
                gui_erp_filtering.hp_tog.Value = 1;
                gui_erp_filtering.hp_tog.Enable ='on';
                gui_erp_filtering.lp_tog.Value = 1;
                gui_erp_filtering.lp_tog.Enable ='on';
                gui_erp_filtering.hp_halfamp.String = num2str(locutoff);
                gui_erp_filtering.hp_halfamp.Enable = 'on';
                gui_erp_filtering.lp_halfamp.String = num2str(hicutoff);
                gui_erp_filtering.lp_halfamp.Enable = 'on';
                gui_erp_filtering.hp_halfpow.String = num2str(roundn(frec3dB(2),-2));
                gui_erp_filtering.lp_halfpow.String = num2str(roundn(frec3dB(1),-2));
            end
        end%%setting end for IIR butter filter
        %%*************Filter the selected ERPsets***************************
        if remove_dc==1
            rdc = 'on';
        else
            rdc = 'off';
        end
        filterallch = def{5};
        if ~strcmpi(fdesign, 'notch') && locutoff==0 && hicutoff>0  % Butter (IIR) and FIR%% low-pass filter
            ftype = 'lowpass';
            cutoff = hicutoff;
        elseif ~strcmpi(fdesign, 'notch') && locutoff>0 && hicutoff==0 % Butter (IIR) and FIR
            ftype = 'highpass';
            cutoff = locutoff;
        elseif ~strcmpi(fdesign, 'notch') && locutoff>0 && hicutoff>0 && locutoff<hicutoff% Butter (IIR) and FIR
            ftype = 'bandpass';
            cutoff = [locutoff hicutoff];
        elseif ~strcmpi(fdesign, 'notch') && locutoff>0 && hicutoff>0 && locutoff>hicutoff% Butter (IIR) and FIR
            ftype = 'simplenotch';
            cutoff = [locutoff hicutoff];
        elseif strcmpi(fdesign, 'notch') && locutoff==hicutoff % Parks-McClellan Notch
            ftype = 'PMnotch';
            cutoff = hicutoff;
            
        elseif ~strcmpi(fdesign, 'notch') && locutoff==0 && hicutoff==0 % Butter (IIR) and FIR
            msgboxText =  'Filtering - I beg your pardon?';
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        else
            msgboxText =  ['Filtering - Invalid type of filter'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        
        if strcmpi(fdesign, 'notch') && locutoff==hicutoff
            if 3*filterorder>=length(observe_ERPDAT.ERP.times)
                msgboxText =  ['Filtering -The length of the data must be more than three times the filter order'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
        end
        gui_erp_filtering.params{1} = gui_erp_filtering.all_bin_chan.Value;
        gui_erp_filtering.params{2} = gui_erp_filtering.hp_tog.Value;
        gui_erp_filtering.params{5} = gui_erp_filtering.lp_tog.Value;
        gui_erp_filtering.params{3} = str2num(gui_erp_filtering.hp_halfamp.String);
        gui_erp_filtering.params{6} = str2num(gui_erp_filtering.lp_halfamp.String);
        gui_erp_filtering.params{4} = str2num(gui_erp_filtering.hp_halfpow.String);
        gui_erp_filtering.params{7} = str2num(gui_erp_filtering.lp_halfpow.String);
        gui_erp_filtering.params{8} =gui_erp_filtering.roll_off.Value;
        gui_erp_filtering.params{9} = 0;
        %%-------------loop start for filtering the selected ERPsets-----------------------------------
        estudioworkingmemory('f_ERP_proces_messg','Filtering (Advanced)');
        observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
        try ALLERPCOM = evalin('base','ALLERPCOM');catch ALLERPCOM = []; end
        ALLERP_out = [];
        ALLERP = observe_ERPDAT.ALLERP;
        for Numoferp = 1:numel(ERPArray)
            ERP = ALLERP(ERPArray(Numoferp));
            if isempty(ChanArray) || any(ChanArray(:)>ERP.nchan) || any(ChanArray(:)<1)
                ChanArray = [1:ERP.nchan];
            end
            if isempty(BinArray) || any(BinArray(:)>ERP.nbin) || any(BinArray(:)<1)
                BinArray = [1:ERP.nbin];
            end
            
            [ERP, ERPCOM] = pop_filterp(ERP, ChanArray,'binArray',BinArray, 'Filter',ftype, 'Design',  fdesign, 'Cutoff', cutoff, 'Order', filterorder, 'RemoveDC', rdc,...
                'Saveas', 'off', 'History', 'gui');
            if isempty(ERPCOM)
                observe_ERPDAT.Process_messg =2;
                return;
            end
            if Numoferp ==numel(ERPArray)
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
            else
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
            end
            
            if isempty(ALLERP_out)
                ALLERP_out = ERP;
            else
                ALLERP_out(length(ALLERP_out)+1) = ERP;
            end
        end
        Answer = f_ERP_save_multi_file(ALLERP_out,1:numel(ERPArray),'_filt');
        if isempty(Answer)
            observe_ERPDAT.Process_messg =2;
            return;
        end
        if ~isempty(Answer{1})
            ALLERP_out = Answer{1};
            Save_file_label = Answer{2};
        end
        for Numoferp =  1:length(ALLERP_out)
            ERP = ALLERP_out(Numoferp);
            if Save_file_label==1
                [pathstr, file_name, ext] = fileparts(ERP.filename);
                ERP.filename = [file_name,'.erp'];
                [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', ERP.filename, 'filepath',ERP.filepath);
                ERPCOM = f_erp_save_history(ERP.erpname,ERP.filename,ERP.filepath);
                if Numoferp ==numel(ERPArray)
                    [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
                else
                    [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                end
            else
                ERP.filename = '';
                ERP.saved = 'no';
                ERP.filepath = '';
            end
            ALLERP(length(ALLERP)+1) = ERP;
        end
        observe_ERPDAT.ALLERP = ALLERP;
        
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        estudioworkingmemory('ERPfilter',1);
        try
            Selected_ERP_afd =  [length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1:length(observe_ERPDAT.ALLERP)];
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1;
        catch
            Selected_ERP_afd = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
        end
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
        estudioworkingmemory('selectederpstudio',Selected_ERP_afd);
        observe_ERPDAT.Count_currentERP = 1;
        observe_ERPDAT.Process_messg =2;
    end


%%-------------------------------cancel------------------------------------
    function ERP_filter_cancel(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=5
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_filter',0);
        gui_erp_filtering.apply.BackgroundColor =  [1 1 1];
        gui_erp_filtering.apply.ForegroundColor = [0 0 0];
        ERP_filtering_box.TitleColor= [ 0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_filtering.cancel.BackgroundColor =  [1 1 1];
        gui_erp_filtering.cancel.ForegroundColor = [0 0 0];
        gui_erp_filtering.advanced.BackgroundColor =  [1 1 1];
        gui_erp_filtering.advanced.ForegroundColor = [0 0 0];
        
        try allbin_chan =  gui_erp_filtering.params{1}; catch allbin_chan=1; gui_erp_filtering.params{1}=1; end;
        if isempty(allbin_chan) || numel(allbin_chan)~=1 || (allbin_chan~=0 && allbin_chan~=1)
            allbin_chan=1; gui_erp_filtering.params{1}=1;
        end
        %
        %%chans and bins
        gui_erp_filtering.all_bin_chan.Value = allbin_chan;
        gui_erp_filtering.Selected_bin_chan.Value = ~allbin_chan;
        %
        %%high-pass filter
        try  hp_tog= gui_erp_filtering.params{2};catch hp_tog=0; gui_erp_filtering.params{2}=1; end
        if isempty(hp_tog) || numel(hp_tog)~=1 || (hp_tog~=0 && hp_tog~=1)
            hp_tog=0; gui_erp_filtering.params{2}=1;
        end
        gui_erp_filtering.hp_tog.Value = hp_tog;
        if hp_tog==0
            enableflag = 'off';
        else
            enableflag = 'on';
        end
        gui_erp_filtering.hp_halfamp.Enable = enableflag;
        gui_erp_filtering.hp_halfpow.Enable = 'off';
        %
        %%low pass filter
        try  lp_tog= gui_erp_filtering.params{5}; catch lp_tog=0; gui_erp_filtering.params{5}=0; end
        if isempty(lp_tog) || numel(lp_tog)~=1 || (lp_tog~=0 && lp_tog~=1)
            lp_tog=0; gui_erp_filtering.params{5}=0;
        end
        gui_erp_filtering.lp_tog.Value = lp_tog;
        if lp_tog==0
            enableflag = 'off';
        else
            enableflag = 'on';
        end
        gui_erp_filtering.lp_halfpow.Enable = 'off';
        gui_erp_filtering.lp_halfamp.Enable = enableflag;
        
        try hp_halfamp = gui_erp_filtering.params{3}; catch hp_halfamp=[]; gui_erp_filtering.params{3}=[];end
        if ~isnumeric(hp_halfamp) || isempty(hp_halfamp) || numel(hp_halfamp)~=1
            hp_halfamp=[];gui_erp_filtering.params{3}=[];
        end
        gui_erp_filtering.hp_halfamp.String = num2str(hp_halfamp);
        
        try lp_halfamp= gui_erp_filtering.params{6}; catch lp_halfamp=[];gui_erp_filtering.params{6}=[]; end
        if ~isnumeric(lp_halfamp) || isempty(lp_halfamp) || numel(lp_halfamp)~=1
            lp_halfamp=[];gui_erp_filtering.params{6}=[];
        end
        gui_erp_filtering.lp_halfamp.String = num2str(lp_halfamp);
        
        try hp_halfpow = gui_erp_filtering.params{4}; catch hp_halfpow=[];gui_erp_filtering.params{4}=[]; end
        if ~isnumeric(hp_halfpow) || isempty(hp_halfpow) || numel(hp_halfpow)~=1
            hp_halfpow=[];gui_erp_filtering.params{4}=[];
        end
        gui_erp_filtering.hp_halfpow.String = num2str(hp_halfpow);
        
        try lp_halfpow = gui_erp_filtering.params{4}; catch lp_halfpow=[];gui_erp_filtering.params{7}=[]; end
        if ~isnumeric(lp_halfpow) || isempty(lp_halfpow) || numel(lp_halfpow)~=1
            lp_halfpow=[];gui_erp_filtering.params{7}=[];
        end
        gui_erp_filtering.lp_halfpow.String = num2str(lp_halfpow);
        %
        %%roll off?
        try roll_off = gui_erp_filtering.params{8}; catch roll_off=1;gui_erp_filtering.params{8}=1; end
        if isempty(roll_off) || numel(roll_off)~=1 || any(roll_off<1) || any(roll_off>4)
            roll_off=1;gui_erp_filtering.params{8}=1;
        end
        gui_erp_filtering.roll_off.Value=roll_off;
        %
        %%remove DC?
        try DC_remove =  gui_erp_filtering.params{9}; catch DC_remove =1; gui_erp_filtering.params{9}=1; end
        if isempty(DC_remove) || numel(DC_remove)~=1  || (DC_remove~=0 && DC_remove~=1)
            DC_remove =1; gui_erp_filtering.params{9}=1;
        end
        
    end


%%-------------------Setting for the whole panel of fitering based on ALLERP and CURRENTERP--------------
    function Count_currentERPChanged(~,~)
        if observe_ERPDAT.Count_currentERP~=10
            return;
        end
        ViewerFlag=estudioworkingmemory('ViewerFlag');
        if isempty(ViewerFlag) || (ViewerFlag~=0 && ViewerFlag~=1)
            ViewerFlag=0;estudioworkingmemory('ViewerFlag',0);
        end
        if isempty(observe_ERPDAT.ALLERP)  || isempty(observe_ERPDAT.ERP) || strcmp(observe_ERPDAT.ERP.datatype,'EFFT') || ViewerFlag==1
            gui_erp_filtering.apply.Enable = 'off';
            gui_erp_filtering.advanced.Enable = 'off';
            gui_erp_filtering.roll_off.Enable = 'off';
            gui_erp_filtering.hp_halfamp.Enable = 'off';
            gui_erp_filtering.lp_halfamp.Enable = 'off';
            gui_erp_filtering.hp_tog.Enable = 'off';
            gui_erp_filtering.lp_tog.Enable = 'off';
            gui_erp_filtering.all_bin_chan.Enable = 'off';
            gui_erp_filtering.Selected_bin_chan.Enable = 'off';
            gui_erp_filtering.cancel.Enable = 'off';
            observe_ERPDAT.Count_currentERP=11;
            return;
        else
            %             gui_erp_filtering.DC_remove.Enable = 'on';
            gui_erp_filtering.cancel.Enable = 'on';
            gui_erp_filtering.all_bin_chan.Enable = 'on';
            gui_erp_filtering.Selected_bin_chan.Enable = 'on';
            locutoff = str2num(gui_erp_filtering.hp_halfamp.String);%%for high pass filter
            hicutoff = str2num(gui_erp_filtering.lp_halfamp.String);%% for low pass filter
            
            if isempty(locutoff)
                locutoff =0;
                gui_erp_filtering.hp_halfamp.String = '0';
            end
            if isempty(hicutoff)
                hicutoff = 0;
                gui_erp_filtering.lp_halfamp.String = '0';
            end
            fs = observe_ERPDAT.ERP.srate;
            if fs <=0
                fs = 256;
            end
            typef = 0;
            filterorder = 2*gui_erp_filtering.roll_off.Value;
            [bt, at, labelf, v, frec3dB, xdB_at_fx, orderx] = filter_tf(typef, filterorder, hicutoff,locutoff,fs);
            if locutoff > 0 && hicutoff ==0
                highpass_toggle_value = 1;
                hp_halfamp_enable = 'on';
                lowpass_toggle_value = 0;
                lp_halfamp_Enable = 'off';
                hp_halfpow_string =num2str(roundn(frec3dB(1),-2));
                lp_halfpow_string ='---';
            end
            %%Low pass filtering
            if hicutoff > 0 && locutoff ==0
                highpass_toggle_value = 0;
                hp_halfamp_enable = 'off';
                lowpass_toggle_value = 1;
                lp_halfamp_Enable = 'on';
                lp_halfpow_string =num2str(roundn(frec3dB,-2));
                hp_halfpow_string ='---';
            end
            %%Band pass filtering or notch filtering
            if locutoff >0 && hicutoff>0
                highpass_toggle_value = 1;
                hp_halfamp_enable = 'on';
                hp_halfpow_string =num2str(roundn(frec3dB(2),-2));
                lowpass_toggle_value = 1;
                lp_halfamp_Enable = 'on';
                lp_halfpow_string =num2str(roundn(frec3dB(1),-2));
            end
            
            if locutoff==0 && hicutoff==0
                highpass_toggle_value = 0;
                hp_halfamp_enable = 'off';
                hp_halfpow_string ='0';
                lowpass_toggle_value = 0;
                lp_halfamp_Enable = 'off';
                lp_halfpow_string ='0';
            end
            gui_erp_filtering.apply.Enable = 'on';
            gui_erp_filtering.advanced.Enable = 'on';
            gui_erp_filtering.roll_off.Enable = 'on';
            gui_erp_filtering.hp_halfpow.String = hp_halfpow_string;
            gui_erp_filtering.lp_halfpow.String = lp_halfpow_string;
            gui_erp_filtering.hp_halfamp.Enable = hp_halfamp_enable;
            gui_erp_filtering.lp_halfamp.Enable = lp_halfamp_Enable;
            gui_erp_filtering.hp_tog.Value = highpass_toggle_value;
            gui_erp_filtering.lp_tog.Value = lowpass_toggle_value;
            gui_erp_filtering.hp_tog.Enable = 'on';
            gui_erp_filtering.lp_tog.Enable = 'on';
            
            ERPArray = observe_ERPDAT.CURRENTERP;
            Check_Selected_erpset = [0 0 0 0 0 0 0];
            if numel(ERPArray)>1
                Check_Selected_erpset = f_checkerpsets(observe_ERPDAT.ALLERP,ERPArray);
            end
            if Check_Selected_erpset(1) ==1 || Check_Selected_erpset(2) == 2
                gui_erp_filtering.Selected_bin_chan.Value =0;
                gui_erp_filtering.Selected_bin_chan.Enable = 'off';
                gui_erp_filtering.all_bin_chan.Value = 1;
                gui_erp_filtering.all_bin_chan.Enable = 'on';
            end
            observe_ERPDAT.Count_currentERP=11;
        end
    end

%%--------------press return to execute "Apply"----------------------------
    function erp_filter_presskey(~,eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('ERPTab_filter');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            ERP_filter_apply();
            estudioworkingmemory('ERPTab_filter',0);
            gui_erp_filtering.apply.BackgroundColor =  [1 1 1];
            gui_erp_filtering.apply.ForegroundColor = [0 0 0];
            ERP_filtering_box.TitleColor= [ 0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
            gui_erp_filtering.cancel.BackgroundColor =  [1 1 1];
            gui_erp_filtering.cancel.ForegroundColor = [0 0 0];
            gui_erp_filtering.advanced.BackgroundColor =  [1 1 1];
            gui_erp_filtering.advanced.ForegroundColor = [0 0 0];
        else
            return;
        end
    end

    function Reset_erp_panel_change(~,~)
        if observe_ERPDAT.Reset_erp_paras_panel~=7
            return;
        end
        estudioworkingmemory('ERPTab_filter',0);
        gui_erp_filtering.apply.BackgroundColor =  [1 1 1];
        gui_erp_filtering.apply.ForegroundColor = [0 0 0];
        ERP_filtering_box.TitleColor= [ 0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_filtering.cancel.BackgroundColor =  [1 1 1];
        gui_erp_filtering.cancel.ForegroundColor = [0 0 0];
        gui_erp_filtering.advanced.BackgroundColor =  [1 1 1];
        gui_erp_filtering.advanced.ForegroundColor = [0 0 0];
        gui_erp_filtering.all_bin_chan.Value = 1;
        gui_erp_filtering.Selected_bin_chan.Value = 0;
        gui_erp_filtering.roll_off.Value=1;
        try
            fs = observe_ERPDAT.ERP.srate;
        catch
            fs = 256;
        end
        if fs <=0
            fs = 256;
        end
        
        typef = 0;
        hicutoff = 30;
        locutoff = 0;
        filterorder = 2*gui_erp_filtering.roll_off.Value;
        [bt, at, labelf, v, frec3dB, xdB_at_fx, orderx] = filter_tf(typef, filterorder, hicutoff,locutoff,fs);
        gui_erp_filtering.hp_halfpow.String = '---';
        gui_erp_filtering.lp_halfpow.String = num2str(roundn(frec3dB,-2));
        gui_erp_filtering.hp_halfamp.Enable = 'off';
        gui_erp_filtering.lp_halfamp.Enable = 'on';
        gui_erp_filtering.hp_halfamp.String = '0';
        gui_erp_filtering.lp_halfamp.String = '30';
        gui_erp_filtering.hp_tog.Value = 0;
        gui_erp_filtering.lp_tog.Value = 1;
        observe_ERPDAT.Reset_erp_paras_panel=8;
    end
end
%Progem end: