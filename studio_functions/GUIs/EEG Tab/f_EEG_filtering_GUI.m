%Author: Guanghui ZHANG & Steve LUCK
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Sep. 2023

% ERPLAB Studio

function varargout = f_EEG_filtering_GUI(varargin)

global observe_EEGDAT;
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
addlistener(observe_EEGDAT,'eeg_message_panel_change',@eeg_message_panel_change);
addlistener(observe_EEGDAT,'eeg_reset_def_paras_change',@eeg_reset_def_paras_change);
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
gui_eeg_filtering = struct();
%%---------------------------gui-------------------------------------------
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.95 0.95 0.95];
end
if nargin == 0
    fig = figure(); % Parent figure
    EEG_filtering_box = uiextras.BoxPanel('Parent', fig, 'Title', 'Filtering', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    EEG_filtering_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Filtering', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    EEG_filtering_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Filtering', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
end



try
    FonsizeDefault = varargin{2};
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
    FonsizeDefault = f_get_default_fontsize();
end
eeg_filtering_gui(FonsizeDefault);

varargout{1} = EEG_filtering_box;
%%********************Draw the GUI for ERP measurement tool*****************
    function eeg_filtering_gui(FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.95 0.95 0.95];
        end
        if isempty(observe_EEGDAT.EEG)
            Enable_label = 'off';
            fs = 256;
            nchan=1;
        else
            Enable_label = 'on';
            
            try
                nchan = observe_EEGDAT.EEG.nbchan;
                fs = observe_EEGDAT.EEG.srate;
            catch
                nchan =1;
            end
        end
        
        defx = {0 30 2 1:nchan 1 'butter' 0 []};
        def  = erpworkingmemory('pop_basicfilter');
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
        if strcmpi(fdesign,'butter') % 0 means Butterworth
            if filterorder> 8
                filterorder =2;
            end
        else
            filterorder = 2;
        end
        
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
        
        if ~isempty(observe_EEGDAT.EEG)
            %%High-pass filtering
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
        else
            hp_halfamp_enable = 'off';
            lp_halfamp_Enable = 'off';
            Apply_ERP_filter_enable = 'off';
            Advance_ERP_filter_enable = 'off';
            
            lp_tog_enable = 'off';
            hp_tog_enable = 'off';
            hp_halfpow_string ='--';
            lp_halfpow_string ='---';
        end
        gui_eeg_filtering.filtering = uiextras.VBox('Parent',EEG_filtering_box,'BackgroundColor',ColorB_def);
        
        %%-----------------------------Setting for bin and chan--------------------
        gui_eeg_filtering.bin_chan_title = uiextras.HBox('Parent',gui_eeg_filtering.filtering,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',gui_eeg_filtering.bin_chan_title,'String','Channel Selection:','FontWeight','bold',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        gui_eeg_filtering.filter_bin_chan_option = uiextras.HBox('Parent',  gui_eeg_filtering.filtering,'Spacing',1,'BackgroundColor',ColorB_def);
        
        gui_eeg_filtering.all_chan = uicontrol('Style', 'radiobutton','Parent', gui_eeg_filtering.filter_bin_chan_option,...
            'String','All (Recommended)','callback',@All_chan,'Value',1,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_eeg_filtering.all_chan.KeyPressFcn =@eeg_filter_presskey;
        gui_eeg_filtering.Selected_chan = uicontrol('Style', 'radiobutton','Parent', gui_eeg_filtering.filter_bin_chan_option,...
            'String','Selected channels','callback',@Selected_chan,'Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_eeg_filtering.all_chan.KeyPressFcn =@eeg_filter_presskey;
        set(gui_eeg_filtering.filter_bin_chan_option, 'Sizes',[130  170]);
        
        
        %%--------------------------Setting for IIR filter------------------------------
        gui_eeg_filtering.IIR_title = uiextras.HBox('Parent',gui_eeg_filtering.filtering,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',gui_eeg_filtering.IIR_title,'String','Setting for IIR Butterworth:',...
            'FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        
        gui_eeg_filtering.filt_grid = uiextras.Grid('Parent',gui_eeg_filtering.filtering,'BackgroundColor',ColorB_def);
        % first column
        uiextras.Empty('Parent',gui_eeg_filtering.filt_grid); % 1A
        gui_eeg_filtering.hp_tog = uicontrol('Style','checkbox','Parent',gui_eeg_filtering.filt_grid,'String','High Pass',...
            'callback',@highpass_toggle,'Value',0,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 1B
        gui_eeg_filtering.hp_tog.KeyPressFcn =@eeg_filter_presskey;
        gui_eeg_filtering.lp_tog = uicontrol('Style','checkbox','Parent',gui_eeg_filtering.filt_grid,'String','Low Pass',...
            'callback',@lowpass_toggle,'Value',1,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 1C
        gui_eeg_filtering.lp_tog.KeyPressFcn =@eeg_filter_presskey;
        
        % second column
        uicontrol('Style','text','Parent',gui_eeg_filtering.filt_grid,'String','Half Amp.','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 2A
        gui_eeg_filtering.hp_halfamp = uicontrol('Style','edit','Parent',gui_eeg_filtering.filt_grid,...
            'callback',@hp_halfamp,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); % 2B
        gui_eeg_filtering.hp_halfamp.KeyPressFcn =@eeg_filter_presskey;
        if strcmp(hp_halfamp_enable,'off');
            if typef<2
                gui_eeg_filtering.hp_halfamp.String = '0';
            else
                gui_eeg_filtering.hp_halfamp.String = '60';
            end
            
        else
            gui_eeg_filtering.hp_halfamp.String =  num2str(locutoff);
        end
        gui_eeg_filtering.lp_halfamp = uicontrol('Style','edit','Parent',gui_eeg_filtering.filt_grid,...
            'callback',@lp_halfamp,'Enable',lp_halfamp_Enable,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); % 2C
        gui_eeg_filtering.lp_halfamp.KeyPressFcn =@eeg_filter_presskey;
        if strcmp(lp_halfamp_Enable,'off')
            gui_eeg_filtering.lp_halfamp.String = '20';
        else
            gui_eeg_filtering.lp_halfamp.String =  num2str(hicutoff);
        end
        % third column
        uicontrol('Style','text','Parent',gui_eeg_filtering.filt_grid,'String','Half Power','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 3A
        gui_eeg_filtering.hp_halfpow = uicontrol('Style','text','Parent',gui_eeg_filtering.filt_grid,...
            'String',hp_halfpow_string,'Enable','off','BackgroundColor','y','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); % 3B
        
        gui_eeg_filtering.lp_halfpow = uicontrol('Style','text','Parent',gui_eeg_filtering.filt_grid,...
            'String',lp_halfpow_string,'Enable','off','BackgroundColor','y','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); % 3C
        
        % fourth column
        uiextras.Empty('Parent',gui_eeg_filtering.filt_grid); % 4A
        uicontrol('Style','text','Parent',gui_eeg_filtering.filt_grid,'String','Hz','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 4B
        uicontrol('Style','text','Parent',gui_eeg_filtering.filt_grid,'String','Hz','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 4C
        set(gui_eeg_filtering.filt_grid, 'ColumnSizes',[90 70 70 40],'RowSizes',[20 -1 -1]);
        
        
        gui_eeg_filtering.rolloff_row = uiextras.HBox('Parent', gui_eeg_filtering.filtering,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',gui_eeg_filtering.rolloff_row,'String','Roll-Off','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 1D
        Roll_off = {'12','24','36','48'};
        gui_eeg_filtering.roll_off = uicontrol('Style','popupmenu','Parent',gui_eeg_filtering.rolloff_row,'String',Roll_off,...
            'callback',@EEG_filtering_rolloff,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); % 2D
        gui_eeg_filtering.roll_off.KeyPressFcn =@eeg_filter_presskey;
        if filterorder ==2
            gui_eeg_filtering.roll_off.Value = 1;
        elseif filterorder ==4
            gui_eeg_filtering.roll_off.Value = 2;
            
        elseif filterorder ==6
            gui_eeg_filtering.roll_off.Value = 3;
            
        elseif filterorder ==8
            gui_eeg_filtering.roll_off.Value = 4;
        end
        uicontrol('Style','text','Parent',gui_eeg_filtering.rolloff_row,'String','dB/Octave','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 3D
        
        
        gui_eeg_filtering.REMOVE_DC = uiextras.HBox('Parent', gui_eeg_filtering.filtering,'BackgroundColor',ColorB_def);
        gui_eeg_filtering.DC_remove = uicontrol('Style','checkbox','Parent', gui_eeg_filtering.REMOVE_DC,...
            'String','Remove DC Offset (Strongly recommended)','Value',0,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);%,'callback',@remove_dc
        gui_eeg_filtering.DC_remove.KeyPressFcn =@eeg_filter_presskey;
        
        gui_eeg_filtering.filt_buttons = uiextras.HBox('Parent', gui_eeg_filtering.filtering,'BackgroundColor',ColorB_def);
        
        gui_eeg_filtering.cancel = uicontrol('Style','pushbutton','Parent',gui_eeg_filtering.filt_buttons,'String','Cancel',...
            'callback',@EEG_filter_Cancel,'Enable',Apply_ERP_filter_enable,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        gui_eeg_filtering.advanced = uicontrol('Style','pushbutton','Parent',gui_eeg_filtering.filt_buttons,'String','Advanced',...
            'callback',@advanced_EEG_filter,'Enable',Advance_ERP_filter_enable,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        
        gui_eeg_filtering.apply = uicontrol('Style','pushbutton','Parent',gui_eeg_filtering.filt_buttons,'String','Run',...
            'callback',@EEG_filter_apply,'Enable',Apply_ERP_filter_enable,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        set( gui_eeg_filtering.filtering,'Sizes',[20 20 20 80 20 20 30]);
        
        
        defx = {0 30 2 1:nchan 1 'butter' 0 []};
        def  = erpworkingmemory('pop_basicfilter');
        if isempty(def)
            def = defx;
        end
        if gui_eeg_filtering.all_chan.Value ==1
            def{5} =   1;
        else
            def{5} =   0;
        end
        remove_dc =  gui_eeg_filtering.DC_remove.Value;
        def{7} = remove_dc;
        
        filterorder = 2*gui_eeg_filtering.roll_off.Value;
        def{3} = filterorder;
        locutoff = str2num(gui_eeg_filtering.hp_halfamp.String);%%
        hicutoff = str2num(gui_eeg_filtering.lp_halfamp.String);
        
        if isempty(locutoff)
            locutoff =0;
        end
        if isempty(hicutoff)
            hicutoff =0;
        end
        def{1} = locutoff;
        def{2} = hicutoff;
        erpworkingmemory('pop_basicfilter',def);
    end



%%****************************************************************************************************************************************
%%*******************   Subfunctions   ***************************************************************************************************
%%****************************************************************************************************************************************

%%----------------------all bin and all chan-------------------------------
    function All_chan(~,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        gui_eeg_filtering.apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eeg_filtering.apply.ForegroundColor = [1 1 1];
        EEG_filtering_box.TitleColor= [0.5137    0.7569    0.9176];
        gui_eeg_filtering.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eeg_filtering.cancel.ForegroundColor = [1 1 1];
        
        gui_eeg_filtering.all_chan.Value = 1;
        gui_eeg_filtering.Selected_chan.Value = 0;
        estudioworkingmemory('EEGTab_filter',1);
    end

%%----------------------selected bin and all chan-------------------------------
    function Selected_chan(~,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        gui_eeg_filtering.apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eeg_filtering.apply.ForegroundColor = [1 1 1];
        EEG_filtering_box.TitleColor= [0.5137    0.7569    0.9176];
        gui_eeg_filtering.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eeg_filtering.cancel.ForegroundColor = [1 1 1];
        
        gui_eeg_filtering.all_chan.Value = 0;
        gui_eeg_filtering.Selected_chan.Value = 1;
        estudioworkingmemory('EEGTab_filter',1);
    end



%%--------------------------------High-pass filtering toggle------------------
    function  highpass_toggle(source,~)
        if isempty(observe_EEGDAT.EEG)
            source.Enable = 'off';
            gui_eeg_filtering.hp_halfamp.Enable ='off';
            gui_eeg_filtering.hp_halfpow.Enable ='off';
            return;
        end
        
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        gui_eeg_filtering.apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eeg_filtering.apply.ForegroundColor = [1 1 1];
        EEG_filtering_box.TitleColor= [0.5137    0.7569    0.9176];
        gui_eeg_filtering.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eeg_filtering.cancel.ForegroundColor = [1 1 1];
        
        
        try
            fs = observe_EEGDAT.EEG.srate;
        catch
            return;
        end
        locutoff = 0.1;
        try
            filterorder = 2*gui_eeg_filtering.roll_off.Value;
        catch
            filterorder =2;
            gui_eeg_filtering.roll_off.Value=1;
        end
        typef = 0;
        
        if source.Value == 0
            gui_eeg_filtering.hp_halfamp.Enable ='off';
            gui_eeg_filtering.hp_halfpow.Enable ='off';
            gui_eeg_filtering.hp_halfamp.String = '0';
            gui_eeg_filtering.hp_halfpow.String = '---';
            if gui_eeg_filtering.lp_tog.Value ==0
                gui_eeg_filtering.roll_off.Enable = 'off';
            end
        else
            [bt, at, labelf, v, frec3dB, xdB_at_fx, orderx] = filter_tf(typef, filterorder,0,locutoff,fs);
            gui_eeg_filtering.hp_tog.Value =1;
            gui_eeg_filtering.hp_halfamp.Enable ='on';
            gui_eeg_filtering.hp_halfamp.String = num2str(locutoff);
            gui_eeg_filtering.hp_halfpow.String = num2str(frec3dB(1));
            gui_eeg_filtering.hp_halfpow.Enable ='off';
            gui_eeg_filtering.hp_halfpow.String = num2str(frec3dB);
            gui_eeg_filtering.roll_off.Enable = 'on';
        end
        estudioworkingmemory('EEGTab_filter',1);
    end


%%--------------------------------Low-pass filtering toggle------------------
    function  lowpass_toggle(source,~)
        if isempty(observe_EEGDAT.EEG)
            source.Enable = 'off';
            gui_eeg_filtering.lp_halfamp.Enable ='off';
            gui_eeg_filtering.lp_halfpow.Enable ='off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        gui_eeg_filtering.apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eeg_filtering.apply.ForegroundColor = [1 1 1];
        EEG_filtering_box.TitleColor= [0.5137    0.7569    0.9176];
        gui_eeg_filtering.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eeg_filtering.cancel.ForegroundColor = [1 1 1];
        
        try
            fs = observe_EEGDAT.EEG.srate;
        catch
            return;
        end
        typef = 0;
        try
            filterorder = 2*gui_eeg_filtering.roll_off.Value;
        catch
            filterorder =2;
            gui_eeg_filtering.roll_off.Value=1;
        end
        hicutoff = floor((fs/2-1)*5/10);
        if source.Value == 0
            gui_eeg_filtering.lp_halfamp.Enable ='off';
            gui_eeg_filtering.lp_halfpow.Enable ='off';
            gui_eeg_filtering.lp_halfamp.String = '0';
            gui_eeg_filtering.lp_halfpow.String = '---';
            if gui_eeg_filtering.hp_tog.Value ==0
                gui_eeg_filtering.roll_off.Enable = 'off';
            end
        else
            [bt, at, labelf, v, frec3dB, xdB_at_fx, orderx] = filter_tf(typef, filterorder, hicutoff,0, fs);
            gui_eeg_filtering.lp_tog.Value =1;
            gui_eeg_filtering.lp_halfamp.Enable ='on';
            gui_eeg_filtering.lp_halfamp.String = num2str(hicutoff);
            gui_eeg_filtering.lp_halfpow.String = num2str(frec3dB);
            gui_eeg_filtering.lp_halfpow.Enable ='off';
            gui_eeg_filtering.roll_off.Enable = 'on';
        end
        estudioworkingmemory('EEGTab_filter',1);
    end



%%---------------------Half amplitude for high pass filtering--------------
    function hp_halfamp(Source,~)
        if isempty(observe_EEGDAT.EEG)
            gui_eeg_filtering.hp_tog.Enable = 'off';
            gui_eeg_filtering.hp_halfamp.Enable ='off';
            gui_eeg_filtering.hp_halfpow.Enable ='off';
            return;
        end
        
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        gui_eeg_filtering.apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eeg_filtering.apply.ForegroundColor = [1 1 1];
        EEG_filtering_box.TitleColor= [0.5137    0.7569    0.9176];
        gui_eeg_filtering.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eeg_filtering.cancel.ForegroundColor = [1 1 1];
        
        try
            fs = observe_EEGDAT.EEG.srate;
        catch
            return;
        end
        
        typef = 0;
        try
            filterorder = 2*gui_eeg_filtering.roll_off.Value;
        catch
            filterorder =2;
            gui_eeg_filtering.roll_off.Value=1;
        end
        
        valueh = str2num(Source.String);
        if length(valueh)~=1
            MessageViewer =  ['Filtering - Invalid input for high-pass filter cutoff'];
            erpworkingmemory('f_EEG_proces_messg',MessageViewer);
            observe_EEGDAT.eeg_message_panel =4;
            return;
        end
        if valueh>=fs/2
            MessageViewer =  ['Filtering - The high-pass filter cutoff should be smaller than',32,num2str(fs/2),'Hz'];
            erpworkingmemory('f_EEG_proces_messg',MessageViewer);
            observe_EEGDAT.eeg_message_panel =4;
            return;
        end
        if valueh<0.001
            msgboxText =  ['Filtering - We strongly recommend the high-pass filter cutoff is larger than 0.001Hz'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_message_panel =4;
            return;
        end
        
        valuel = 0;
        [bt, at, labelf, v, frec3dB, xdB_at_fx, orderx] = filter_tf(typef, filterorder, valuel, valueh, fs);
        gui_eeg_filtering.hp_halfamp.Enable ='on';
        gui_eeg_filtering.hp_halfamp.String = num2str(valueh);
        gui_eeg_filtering.hp_halfpow.String = num2str(frec3dB);
        gui_eeg_filtering.hp_halfpow.Enable ='off';
        estudioworkingmemory('EEGTab_filter',1);
    end



%%---------------------Half amplitude for low pass filtering---------------
    function lp_halfamp(Source,~)
        if isempty(observe_EEGDAT.EEG)
            gui_eeg_filtering.lp_tog.Enable = 'off';
            gui_eeg_filtering.lp_halfamp.Enable ='off';
            gui_eeg_filtering.lp_halfpow.Enable ='off';
            return;
        end
        
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        gui_eeg_filtering.apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eeg_filtering.apply.ForegroundColor = [1 1 1];
        EEG_filtering_box.TitleColor= [0.5137    0.7569    0.9176];
        gui_eeg_filtering.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eeg_filtering.cancel.ForegroundColor = [1 1 1];
        
        try
            fs = observe_EEGDAT.EEG.srate;
        catch
            return;
        end
        try
            filterorder = 2*gui_eeg_filtering.roll_off.Value;
        catch
            filterorder =2;
            gui_eeg_filtering.roll_off.Value=1;
        end
        valuel = str2num(Source.String);
        if length(valuel)~=1 || isempty(valuel)
            msgboxText =  ['Filtering - Invalid input for low-pass filter cutoff'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_message_panel =4;
            return;
        end
        if valuel>=fs/2
            msgboxText =  ['Filtering - The low-pass filter cutoff should be smaller than',32,num2str(fs/2),'Hz'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_message_panel =4;
            return;
        end
        
        if valuel<0.001
            msgboxText =  ['Filtering - We strongly recommend the low-pass filter cutoff is larger than 0.001Hz'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_message_panel =4;
            return;
        end
        %if the valueh is between 0.1 and fs/2 Hz
        typef = 0;
        valueh = 0;
        [bt, at, labelf, v, frec3dB, xdB_at_fx, orderx] = filter_tf(typef, filterorder, valuel, valueh, fs);
        gui_eeg_filtering.lp_halfamp.Enable ='on';
        gui_eeg_filtering.lp_halfamp.String = num2str(valuel);
        gui_eeg_filtering.lp_halfpow.String = num2str(frec3dB(1));
        gui_eeg_filtering.lp_halfpow.Enable ='off';
        estudioworkingmemory('EEGTab_filter',1);
    end


%%----------------------------Setting for roll-off-------------------------
    function EEG_filtering_rolloff(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable = 'off';
            return;
        end
        
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        gui_eeg_filtering.apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eeg_filtering.apply.ForegroundColor = [1 1 1];
        EEG_filtering_box.TitleColor= [0.5137    0.7569    0.9176];
        gui_eeg_filtering.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eeg_filtering.cancel.ForegroundColor = [1 1 1];
        
        Source_value = Source.Value;
        filterorder = 2*Source_value;
        typef = 0;
        fs = observe_EEGDAT.EEG.srate;
        valuel  = str2num(gui_eeg_filtering.lp_halfamp.String);%% for low-pass filter
        valueh  = str2num(gui_eeg_filtering.hp_halfamp.String);%%for high-pass filter
        if gui_eeg_filtering.lp_tog.Value ==1
            if isempty(valuel)|| length(valuel)~=1
                msgboxText =  ['Filtering - Invalid input for low-pass filter cutoff'];
                erpworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.eeg_message_panel =4;
                return;
            end
            if valuel>=fs/2
                msgboxText =  ['Filtering - The low-pass filter cutoff should be smaller than',32,num2str(fs/2),'Hz'];
                erpworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.eeg_message_panel =4;
                return;
            end
            
            if gui_eeg_filtering.hp_tog.Value ==0
                if valuel<0.001
                    msgboxText =  ['Filtering - We strongly recommend the low-pass filter cutoff is larger than 0.001Hz'];
                    erpworkingmemory('f_EEG_proces_messg',msgboxText);
                    observe_EEGDAT.eeg_message_panel =4;
                    return;
                end
            end
        end
        
        if gui_eeg_filtering.hp_tog.Value ==1
            if length(valueh)~=1
                msgboxText =  ['Filtering - Invalid input for high-pass filter cutoff'];
                erpworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.eeg_message_panel =4;
                return;
            end
            if valueh>=fs/2
                beep;
                msgboxText =  ['Filtering - The high-pass filter cutoff should be smaller than',32,num2str(fs/2),'Hz'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.eeg_message_panel =4;
                return;
            end
            if gui_eeg_filtering.lp_tog.Value ==0
                if valueh<0.001
                    msgboxText =  ['Filtering - We strongly recommend the high-pass filter cutoff is larger than 0.001Hz'];
                    erpworkingmemory('f_EEG_proces_messg',msgboxText);
                    observe_EEGDAT.eeg_message_panel =4;
                    return;
                end
            end
        end
        
        if gui_eeg_filtering.hp_tog.Value ==1 && gui_eeg_filtering.lp_tog.Value ==1
            if valueh >0 && valueh >0 && valueh >=valuel
                msgboxText =  ['Filtering - The lowest bandpass cuttoff is the highest bandpass cuttoff'];
                erpworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.eeg_message_panel =4;
                return;
            end
            if valueh==0 && valuel==0
                msgboxText =  ['Filtering - Either Lowest bandpass cuttoff or  the highest bandpass cuttoff or both is larger than 0.01Hz'];
                erpworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.eeg_message_panel =4;
                return;
            end
        end
        
        if valuel> 0 && valueh ==0
            [bt, at, labelf, v, frec3dB, xdB_at_fx, orderx] = filter_tf(typef, filterorder, valuel, 0, fs);
            gui_eeg_filtering.lp_halfpow.String = num2str(frec3dB);
        elseif valuel== 0 && valueh > 0
            [bt, at, labelf, v, frec3dB, xdB_at_fx, orderx] = filter_tf(typef, filterorder,0, valueh,fs);
            gui_eeg_filtering.hp_halfpow.String = num2str(frec3dB);
        elseif valuel> 0 && valueh > 0
            [bt, at, labelf, v, frec3dB, xdB_at_fx, orderx] = filter_tf(typef, filterorder,valuel, valueh,fs);
            gui_eeg_filtering.lp_halfpow.String = num2str(frec3dB(1));
            gui_eeg_filtering.hp_halfpow.String = num2str(frec3dB(2));
        end
        estudioworkingmemory('EEGTab_filter',1);
    end


%%------------------Setting for apply option--------------------------------
    function EEG_filter_apply(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable = 'off';
            return;
        end
        
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        gui_eeg_filtering.apply.BackgroundColor =  [1 1 1];
        gui_eeg_filtering.apply.ForegroundColor = [0 0 0];
        EEG_filtering_box.TitleColor= [0.0500    0.2500    0.5000];
        gui_eeg_filtering.cancel.BackgroundColor =  [1 1 1];
        gui_eeg_filtering.cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('EEGTab_filter',0);
        
        try
            nchan = observe_EEGDAT.EEG.nbchan;
            fs = observe_EEGDAT.EEG.srate;
        catch
            return;
        end
        
        defx = {0 30 2 1:nchan 1 'butter' 0 []};
        def  = erpworkingmemory('pop_basicfilter');
        if isempty(def)
            def = defx;
        end
        if gui_eeg_filtering.all_chan.Value ==1
            def{5} =   1;
        else
            def{5} =   0;
        end
        
        remove_dc =  gui_eeg_filtering.DC_remove.Value;
        def{7} = remove_dc;
        
        filterorder = 2*gui_eeg_filtering.roll_off.Value;
        def{3} = filterorder;
        locutoff = str2num(gui_eeg_filtering.hp_halfamp.String);%%
        hicutoff = str2num(gui_eeg_filtering.lp_halfamp.String);
        
        if isempty(locutoff)
            locutoff =0;
        end
        if isempty(hicutoff)
            hicutoff =0;
        end
        def{1} = locutoff;
        def{2} = hicutoff;
        erpworkingmemory('pop_basicfilter',def);
        
        if gui_eeg_filtering.lp_tog.Value ==1
            if length(hicutoff)~=1 || isempty(hicutoff)
                beep;
                msgboxText =  ['Filtering - Invalid input for low-pass filter cutoff'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.eeg_message_panel =4;
                return;
            end
            if hicutoff>=fs/2
                beep;
                msgboxText =  ['Filtering - The low-pass filter cutoff should be smaller than',32,num2str(fs/2),'Hz'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.eeg_message_panel =4;
                return;
            end
            if gui_eeg_filtering.hp_tog.Value ==0
                if hicutoff<0.001
                    beep;
                    msgboxText =  ['Filtering - We strongly recommend the low-pass filter cutoff is larger than 0.001Hz'];
                    fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                    erpworkingmemory('f_EEG_proces_messg',msgboxText);
                    observe_EEGDAT.eeg_message_panel =4;
                    return;
                end
            end
        end
        
        if gui_eeg_filtering.hp_tog.Value ==1
            if length(locutoff)~=1
                msgboxText =  ['Filtering - Invalid input for high-pass filter cutoff'];
                erpworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.eeg_message_panel =4;
                return;
            end
            if locutoff>=fs/2
                msgboxText =  ['Filtering - The high-pass filter cutoff should be smaller than',32,num2str(fs/2),'Hz'];
                erpworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.eeg_message_panel =4;
                return;
            end
            
            if gui_eeg_filtering.lp_tog.Value ==0
                if locutoff<0.001
                    msgboxText =  ['Filtering - We strongly recommend the high-pass filter cutoff is larger than 0.001Hz'];
                    erpworkingmemory('f_EEG_proces_messg',msgboxText);
                    observe_EEGDAT.eeg_message_panel =4;
                    return;
                end
            end
        end
        
        if gui_eeg_filtering.hp_tog.Value ==1 && gui_eeg_filtering.lp_tog.Value ==1
            if locutoff==0 && hicutoff==0
                msgboxText =  ['Filtering - Either Lowest bandpass cuttoff or  the highest bandpass cuttoff or both is larger than 0.01Hz'];
                erpworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.eeg_message_panel =4;
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
        else
            chanArray= estudioworkingmemory('EEG_ChanArray');
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
            title = 'EStudio: f_eeg_filtering_gui() !';
            errorfound(msgboxText, title);
            return;
        else
            msgboxText =  ['Filtering - Invalid type of filter'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_message_panel =4;
            return;
        end
        %%save changed parameters to the memory file
        erpworkingmemory('pop_basicfilter', {locutoff,hicutoff,filterorder,chanArray,filterallch,fdesign,remove_dc,[]});
        
        %%-------------loop start for filtering the selected ERPsets-----------------------------------
        erpworkingmemory('f_EEG_proces_messg','Filtering>Apply');
        observe_EEGDAT.eeg_message_panel =1; %%Marking for the procedure has been started.
        
        %%--------Selected EEGsets-----------
        EEGArray= estudioworkingmemory('EEGArray');
        if isempty(EEGArray) || min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) || max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG)
            EEGArray = observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',EEGArray);
        end
        
        try
            FilterMethod = '_filtered';
            if numel(EEGArray)>1
                Answer = f_EEG_save_multi_file(observe_EEGDAT.ALLEEG,EEGArray,FilterMethod);
                if isempty(Answer)
                    beep;
                    disp('User selected Cancel');
                    return;
                end
                if ~isempty(Answer{1})
                    ALLEEG_advance = Answer{1};
                    Save_file_label = Answer{2};
                end
            elseif numel(EEGArray)==1
                Save_file_label =0;
                ALLEEG_advance = observe_EEGDAT.ALLEEG;
            end
            
            for Numofeeg = 1:numel(EEGArray)
                if EEGArray(Numofeeg)> length(observe_EEGDAT.ALLEEG)
                    msgboxText =  ['Filtering - No corresponding EEG exists in ALLEEG'];
                    erpworkingmemory('f_EEG_proces_messg',msgboxText);
                    observe_EEGDAT.eeg_message_panel =4;
                    break;
                end
                
                
                EEG = ALLEEG_advance(EEGArray(Numofeeg));
                if gui_eeg_filtering.all_chan.Value == 1
                    chanArray = [1:EEG.nbchan];
                else
                    if isempty(chanArray) ||  min(chanArray(:)) > EEG.nbchan || max(chanArray(:)) > EEG.nbchan || min(chanArray(:)) <=0
                        chanArray = [1:EEG.nbchan];
                    end
                end
                
                %%Only the slected bin and chan were selected to remove baseline and detrending and others are remiained.
                [EEG, LASTCOM] = pop_basicfilter(EEG, chanArray, 'Filter',ftype, 'Design',  fdesign, 'Cutoff', cutoff, 'Order', filterorder, 'RemoveDC', rdc,...
                    'History', 'gui');
                EEG = eegh(LASTCOM, EEG);
                if numel(EEGArray) ==1
                    Answer = f_EEG_save_single_file(char(strcat(EEG.setname,'_',FilterMethod)),EEG.filename,EEGArray(Numofeeg));
                    if isempty(Answer)
                        disp('User selected cancel.');
                        return;
                    end
                    if ~isempty(Answer)
                        EEGName = Answer{1};
                        if ~isempty(EEGName)
                            EEG.setname = EEGName;
                        end
                        fileName_full = Answer{2};
                        if isempty(fileName_full)
                            EEG.filename = '';
                            EEG.saved = 'no';
                        elseif ~isempty(fileName_full)
                            [pathstr, file_name, ext] = fileparts(fileName_full);
                            if strcmp(pathstr,'')
                                pathstr = cd;
                            end
                            EEG.filename = [file_name,ext];
                            EEG.filepath = pathstr;
                            EEG.saved = 'yes';
                            %%----------save the current sdata as--------------------
                            [EEG, LASTCOM] = pop_saveset(EEG,'filename', EEG.filename, 'filepath',EEG.filepath,'check','on');
                            EEG = eegh(LASTCOM, EEG);
                        end
                    end
                end
                
                if Save_file_label
                    [pathstr, file_name, ext] = fileparts(EEG.filename);
                    EEG.filename = [file_name,'.set'];
                    [EEG, LASTCOM] = pop_saveset(EEG,'filename', EEG.filename, 'filepath',EEG.filepath,'check','on');
                    EEG = eegh(LASTCOM, EEG);
                else
                    EEG.filename = '';
                    EEG.saved = 'no';
                    EEG.filepath = '';
                end
                observe_EEGDAT.ALLEEG(length(observe_EEGDAT.ALLEEG)+1) = EEG;
            end
            
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
            observe_EEGDAT.eeg_message_panel =2;
        catch
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG);
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
            Selected_EEG_afd =observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',Selected_EEG_afd);
            assignin('base','EEG',observe_EEGDAT.EEG);
            assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
            assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
            
            observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_message_panel =3;%%There is erros in processing procedure
            return;
        end
        
    end

%%-------------------Setting for advance  option---------------------------
    function advanced_EEG_filter(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable = 'off';
            return;
        end
        
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) %%&& eegpanelIndex~=3
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        gui_eeg_filtering.apply.BackgroundColor =  [1 1 1];
        gui_eeg_filtering.apply.ForegroundColor = [0 0 0];
        EEG_filtering_box.TitleColor= [0.0500    0.2500    0.5000];
        gui_eeg_filtering.cancel.BackgroundColor =  [1 1 1];
        gui_eeg_filtering.cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('EEGTab_filter',0);
        
        try
            nchan = observe_EEGDAT.EEG.nbchan;
            fs = observe_EEGDAT.EEG.srate;
        catch
            fs = 256;
            nchan = 30;
        end
        defx = {0 30 2 1:nchan 1 'butter' 0 []};
        def  = erpworkingmemory('pop_basicfilter');
        
        if isempty(def)
            def = defx;
        else
            def{4} = def{4}(ismember_bc2(def{4},1:nchan));
        end
        
        def{1} = str2num(gui_eeg_filtering.hp_halfamp.String);
        def{2} = str2num(gui_eeg_filtering.lp_halfamp.String);
        if gui_eeg_filtering.hp_tog.Value ==1
            if isempty(def{1}) || def{1} ==0
                def{1} = 0.01;
            end
        end
        if gui_eeg_filtering.lp_tog.Value ==1
            if isempty(def{2}) || def{2} ==0
                def{2} = floor((fs/2-1)*5/10);
            end
        end
        
        def{7} =  gui_eeg_filtering.DC_remove.Value;
        def{8} = [];
        fdesign = 'butter';
        def{3} = 2*gui_eeg_filtering.roll_off.Value;
        def{6} = fdesign;
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if gui_eeg_filtering.all_chan.Value == 1
            chanArray = 1:nchan;
            def{5} =1;
        else
            chanArray= estudioworkingmemory('EEG_ChanArray');
            def{5} =0;
        end
        def{4} = chanArray;
        
        %%call the GUI for advance option
        answer = basicfilterGUI2(observe_EEGDAT.EEG, def);
        if isempty(answer)
            beep;
            disp('User selected Cancel')
            return;
        end
        
        defx = {answer{1},answer{2},answer{3},answer{4},answer{5},answer{6},answer{7},answer{8}};
        erpworkingmemory('pop_basicfilter',defx);
        
        locutoff    = answer{1}; % for high pass filter
        hicutoff    = answer{2}; % for low pass filter
        filterorder = answer{3};
        chanArray   = answer{4};
        filterallch = answer{5};
        fdesign     = answer{6};
        remove_dc   = answer{7};
        Boundaryflag = answer{8};
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
            gui_eeg_filtering.roll_off.Value =  filterorder/2;
            gui_eeg_filtering.roll_off.String = {'12','24','36','48'}';
            gui_eeg_filtering.roll_off.Enable = 'on';
            gui_eeg_filtering.DC_remove.Value =  remove_dc;
            %%High-pass filtering
            [bt, at, labelf, v, frec3dB, xdB_at_fx, orderx] = filter_tf(typef, filterorder, hicutoff,locutoff,fs);
            if locutoff > 0 && (isempty(hicutoff) || hicutoff ==0 )
                gui_eeg_filtering.hp_tog.Value = 1;
                gui_eeg_filtering.hp_tog.Enable ='on';
                gui_eeg_filtering.lp_tog.Value = 0;
                gui_eeg_filtering.lp_tog.Enable ='on';
                gui_eeg_filtering.hp_halfamp.String = num2str(locutoff);
                gui_eeg_filtering.hp_halfamp.Enable = 'on';
                gui_eeg_filtering.lp_halfamp.String = num2str(hicutoff);
                gui_eeg_filtering.lp_halfamp.Enable = 'off';
                gui_eeg_filtering.hp_halfpow.String = num2str(roundn(frec3dB(1),-2));
                gui_eeg_filtering.lp_halfpow.String = '---';
            end
            %%Low pass filtering
            if hicutoff > 0 && (isempty(locutoff) || locutoff ==0)
                gui_eeg_filtering.lp_tog.Value = 1;
                gui_eeg_filtering.lp_tog.Enable ='on';
                gui_eeg_filtering.hp_tog.Value = 0;
                gui_eeg_filtering.hp_tog.Enable ='on';
                gui_eeg_filtering.lp_halfamp.String = num2str(hicutoff);
                gui_eeg_filtering.lp_halfamp.Enable = 'on';
                gui_eeg_filtering.hp_halfamp.String = num2str(locutoff);
                gui_eeg_filtering.hp_halfamp.Enable = 'off';
                gui_eeg_filtering.lp_halfpow.String = num2str(roundn(frec3dB(1),-2));
                gui_eeg_filtering.hp_halfpow.String = '---';
            end
            %%Band pass filtering or notch filtering
            if locutoff >0 && hicutoff>0
                gui_eeg_filtering.hp_tog.Value = 1;
                gui_eeg_filtering.hp_tog.Enable ='on';
                gui_eeg_filtering.lp_tog.Value = 1;
                gui_eeg_filtering.lp_tog.Enable ='on';
                gui_eeg_filtering.hp_halfamp.String = num2str(locutoff);
                gui_eeg_filtering.hp_halfamp.Enable = 'on';
                gui_eeg_filtering.lp_halfamp.String = num2str(hicutoff);
                gui_eeg_filtering.lp_halfamp.Enable = 'on';
                gui_eeg_filtering.hp_halfpow.String = num2str(roundn(frec3dB(2),-2));
                gui_eeg_filtering.lp_halfpow.String = num2str(roundn(frec3dB(1),-2));
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
            msgboxText =  'I beg your pardon?';
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_message_panel =4;
            return;
        else
            msgboxText =  ['Filtering - Invalid type of filter'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_message_panel =4;
            return;
        end
        
        if strcmpi(fdesign, 'notch') && locutoff==hicutoff
            if 3*filterorder>=length(observe_EEGDAT.EEG.times)
                msgboxText =  ['Filtering -The length of the data must be more than three times the filter order'];
                erpworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.eeg_message_panel =4;
                return;
            end
        end
        
        %%-------------loop start for filtering the selected ERPsets-----------------------------------
        erpworkingmemory('f_EEG_proces_messg','Filtering>Advanced');
        observe_EEGDAT.eeg_message_panel =1; %%Marking for the procedure has been started.
        try
            Suffix_label = 1;
            FilterMethod = 'filtered';
            if numel(EEGArray)>1
                Answer = f_EEG_save_multi_file(observe_EEGDAT.ALLEEG,EEGArray,FilterMethod);
                if isempty(Answer)
                    beep;
                    disp('User selected Cancel');
                    return;
                end
                if ~isempty(Answer{1})
                    ALLEEG_advance = Answer{1};
                    Save_file_label = Answer{2};
                end
            elseif numel(EEGArray)==1
                Save_file_label =0;
                ALLEEG_advance = observe_EEGDAT.ALLEEG;
            end
            
            for Numofeeg = 1:numel(EEGArray)
                if EEGArray(Numofeeg)> length(observe_EEGDAT.ALLEEG)
                    msgboxText =  ['Filtering - No corresponding ERP exists in ALLEERP'];
                    erpworkingmemory('f_EEG_proces_messg',msgboxText);
                    observe_EEGDAT.eeg_message_panel =4;
                    break;
                end
                EEG = ALLEEG_advance(EEGArray(Numofeeg));
                %%Only the slected bin and chan were selected to remove baseline and detrending and others are remiained.
                [EEG, LASTCOM] = pop_basicfilter(EEG, chanArray, 'Filter',ftype, 'Design',  fdesign, 'Cutoff', cutoff, 'Order', filterorder, 'RemoveDC', rdc,...
                    'History', 'gui','Boundary', Boundaryflag);
                EEG = eegh(LASTCOM, EEG);
                
                
                %%Rename single file------------------------------------
                if numel(EEGArray) ==1
                    Answer = f_EEG_save_single_file(char(strcat(EEG.setname,'_',FilterMethod)),EEG.filename,EEGArray(Numofeeg));
                    if isempty(Answer)
                        disp('User selected Cancel');
                        return;
                    end
                    
                    if ~isempty(Answer)
                        EEGName = Answer{1};
                        if ~isempty(EEGName)
                            EEG.setname = EEGName;
                        end
                        fileName_full = Answer{2};
                        if isempty(fileName_full)
                            EEG.filename = '';
                            EEG.saved = 'no';
                        elseif ~isempty(fileName_full)
                            [pathstr, file_name, ext] = fileparts(fileName_full);
                            if strcmp(pathstr,'')
                                pathstr = cd;
                            end
                            EEG.filename = [file_name,ext];
                            EEG.filepath = pathstr;
                            EEG.saved = 'yes';
                            %%----------save the current sdata as--------------------
                            [EEG, LASTCOM] = pop_saveset(EEG,'filename', EEG.filename, 'filepath',EEG.filepath,'check','on');
                            EEG = eegh(LASTCOM, EEG);
                        end
                    end
                end
                
                if Save_file_label
                    [pathstr, file_name, ext] = fileparts(EEG.filename);
                    EEG.filename = [file_name,'.set'];
                    EEG.saved = 'yes';
                    [EEG, LASTCOM] = pop_saveset(EEG,'filename', EEG.filename, 'filepath',EEG.filepath,'check','on');
                    EEG = eegh(LASTCOM, EEG);
                else
                    EEG.filename = '';
                    EEG.saved = 'no';
                    EEG.filepath = '';
                end
                observe_EEGDAT.ALLEEG(length(observe_EEGDAT.ALLEEG)+1) = EEG;
            end
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
            observe_EEGDAT.eeg_message_panel =2;
        catch
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG);
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
            Selected_EEG_afd =observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',Selected_EEG_afd);
            
            assignin('base','EEG',observe_EEGDAT.EEG);
            assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
            assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
            
            observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_message_panel =3;%%There is erros in processing procedure
            return;
        end
    end



%%-------------------Setting for the whole panel of fitering based on ALLERP and CURRENTERP--------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=4
            return;
        end
        
        if  isempty(observe_EEGDAT.EEG)
            gui_eeg_filtering.apply.Enable = 'off';
            gui_eeg_filtering.advanced.Enable = 'off';
            gui_eeg_filtering.roll_off.Enable = 'off';
            gui_eeg_filtering.hp_halfamp.Enable = 'off';
            gui_eeg_filtering.lp_halfamp.Enable = 'off';
            gui_eeg_filtering.hp_tog.Enable = 'off';
            gui_eeg_filtering.lp_tog.Enable = 'off';
            gui_eeg_filtering.all_chan.Enable = 'off';
            gui_eeg_filtering.Selected_chan.Enable = 'off';
            gui_eeg_filtering.cancel.Enable = 'off';
            return;
        else
            gui_eeg_filtering.all_chan.Enable = 'on';
            gui_eeg_filtering.Selected_chan.Enable = 'on';
            locutoff = str2num(gui_eeg_filtering.hp_halfamp.String);%%for high pass filter
            hicutoff = str2num(gui_eeg_filtering.lp_halfamp.String);%% for low pass filter
            if isempty(locutoff)
                locutoff =0;
                gui_eeg_filtering.hp_halfamp.String = '0';
            end
            if isempty(hicutoff)
                hicutoff = 0;
                gui_eeg_filtering.lp_halfamp.String = '0';
            end
            fs = observe_EEGDAT.EEG.srate;
            if fs <=0
                fs = 256;
            end
            typef = 0;
            filterorder = 2*gui_eeg_filtering.roll_off.Value;
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
            gui_eeg_filtering.apply.Enable = 'on';
            gui_eeg_filtering.advanced.Enable = 'on';
            gui_eeg_filtering.roll_off.Enable = 'on';
            gui_eeg_filtering.hp_halfpow.String = hp_halfpow_string;
            gui_eeg_filtering.lp_halfpow.String = lp_halfpow_string;
            gui_eeg_filtering.hp_halfamp.Enable = hp_halfamp_enable;
            gui_eeg_filtering.lp_halfamp.Enable = lp_halfamp_Enable;
            gui_eeg_filtering.hp_tog.Value = highpass_toggle_value;
            gui_eeg_filtering.lp_tog.Value = lowpass_toggle_value;
            gui_eeg_filtering.hp_tog.Enable = 'on';
            gui_eeg_filtering.lp_tog.Enable = 'on';
            gui_eeg_filtering.cancel.Enable = 'on';
            if ndims(observe_EEGDAT.EEG.data)==3
                gui_eeg_filtering.DC_remove.Enable = 'off';
                gui_eeg_filtering.DC_remove.Value = 0;
            else
                gui_eeg_filtering.DC_remove.Enable = 'on';
            end
        end
        
        observe_EEGDAT.count_current_eeg=5;
    end


%%--------------------------------------Cancel-----------------------------
%%this function is to cancel the changed parameters
    function EEG_filter_Cancel(~,~)
        if isempty(observe_EEGDAT.EEG)
            gui_eeg_filtering.cancel.Enable = 'off';
            gui_eeg_filtering.apply.Enable = 'off';
            gui_eeg_filtering.advanced.Enable = 'off';
            gui_eeg_filtering.roll_off.Enable = 'off';
            gui_eeg_filtering.hp_halfamp.Enable = 'off';
            gui_eeg_filtering.lp_halfamp.Enable = 'off';
            gui_eeg_filtering.hp_tog.Enable = 'off';
            gui_eeg_filtering.lp_tog.Enable = 'off';
            gui_eeg_filtering.all_chan.Enable = 'off';
            gui_eeg_filtering.Selected_chan.Enable = 'off';
            return;
        end
        
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        nchan=observe_EEGDAT.EEG.nbchan;
        defx= erpworkingmemory('pop_basicfilter');
        if isempty(defx)
            defx = {0 30 2 1:nchan 1 'butter' 0 []};
        end
        locutoff    = defx{1}; % for high pass filter
        hicutoff    = defx{2}; % for low pass filter
        filterorder = defx{3};
        filterallch = defx{5};
        remove_dc   = defx{7};
        fs = observe_EEGDAT.EEG.srate;
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
        if filterallch==1
            gui_eeg_filtering.all_chan.Value = 1;
            gui_eeg_filtering.Selected_chan.Value = 0;
        else
            gui_eeg_filtering.all_chan.Value = 0;
            gui_eeg_filtering.Selected_chan.Value = 1;
        end
        typef = 0;
        gui_eeg_filtering.roll_off.Value =  filterorder/2;
        gui_eeg_filtering.roll_off.String = {'12','24','36','48'}';
        gui_eeg_filtering.roll_off.Enable = 'on';
        gui_eeg_filtering.DC_remove.Value =  remove_dc;
        %%High-pass filtering
        [bt, at, labelf, v, frec3dB, xdB_at_fx, orderx] = filter_tf(typef, filterorder, hicutoff,locutoff,fs);
        if locutoff > 0 && (isempty(hicutoff) || hicutoff ==0 )
            gui_eeg_filtering.hp_tog.Value = 1;
            gui_eeg_filtering.hp_tog.Enable ='on';
            gui_eeg_filtering.lp_tog.Value = 0;
            gui_eeg_filtering.lp_tog.Enable ='on';
            gui_eeg_filtering.hp_halfamp.String = num2str(locutoff);
            gui_eeg_filtering.hp_halfamp.Enable = 'on';
            gui_eeg_filtering.lp_halfamp.String = num2str(hicutoff);
            gui_eeg_filtering.lp_halfamp.Enable = 'off';
            gui_eeg_filtering.hp_halfpow.String = num2str(roundn(frec3dB(1),-2));
            gui_eeg_filtering.lp_halfpow.String = '---';
        end
        %%Low pass filtering
        if hicutoff > 0 && (isempty(locutoff) || locutoff ==0)
            gui_eeg_filtering.lp_tog.Value = 1;
            gui_eeg_filtering.lp_tog.Enable ='on';
            gui_eeg_filtering.hp_tog.Value = 0;
            gui_eeg_filtering.hp_tog.Enable ='on';
            gui_eeg_filtering.lp_halfamp.String = num2str(hicutoff);
            gui_eeg_filtering.lp_halfamp.Enable = 'on';
            gui_eeg_filtering.hp_halfamp.String = num2str(locutoff);
            gui_eeg_filtering.hp_halfamp.Enable = 'off';
            gui_eeg_filtering.lp_halfpow.String = num2str(roundn(frec3dB(1),-2));
            gui_eeg_filtering.hp_halfpow.String = '---';
        end
        %%Band pass filtering or notch filtering
        if locutoff >0 && hicutoff>0
            gui_eeg_filtering.hp_tog.Value = 1;
            gui_eeg_filtering.hp_tog.Enable ='on';
            gui_eeg_filtering.lp_tog.Value = 1;
            gui_eeg_filtering.lp_tog.Enable ='on';
            gui_eeg_filtering.hp_halfamp.String = num2str(locutoff);
            gui_eeg_filtering.hp_halfamp.Enable = 'on';
            gui_eeg_filtering.lp_halfamp.String = num2str(hicutoff);
            gui_eeg_filtering.lp_halfamp.Enable = 'on';
            gui_eeg_filtering.hp_halfpow.String = num2str(roundn(frec3dB(2),-2));
            gui_eeg_filtering.lp_halfpow.String = num2str(roundn(frec3dB(1),-2));
        end
        gui_eeg_filtering.apply.BackgroundColor =  [1 1 1];
        gui_eeg_filtering.apply.ForegroundColor = [0 0 0];
        EEG_filtering_box.TitleColor= [0.0500    0.2500    0.5000];
        gui_eeg_filtering.cancel.BackgroundColor =  [1 1 1];
        gui_eeg_filtering.cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('EEGTab_filter',0);
        
        if ndims(observe_EEGDAT.EEG.data)==3
            gui_eeg_filtering.DC_remove.Enable = 'off';
            gui_eeg_filtering.DC_remove.Value = 0;
        else
            gui_eeg_filtering.DC_remove.Enable = 'on';
        end
        
        defx = {0 30 2 1:nchan 1 'butter' 0 []};
        def  = erpworkingmemory('pop_basicfilter');
        if isempty(def)
            def = defx;
        end
        if gui_eeg_filtering.all_chan.Value ==1
            def{5} =   1;
        else
            def{5} =   0;
        end
        remove_dc =  gui_eeg_filtering.DC_remove.Value;
        def{7} = remove_dc;
        
        filterorder = 2*gui_eeg_filtering.roll_off.Value;
        def{3} = filterorder;
        locutoff = str2num(gui_eeg_filtering.hp_halfamp.String);%%
        hicutoff = str2num(gui_eeg_filtering.lp_halfamp.String);
        
        if isempty(locutoff)
            locutoff =0;
        end
        if isempty(hicutoff)
            hicutoff =0;
        end
        def{1} = locutoff;
        def{2} = hicutoff;
        erpworkingmemory('pop_basicfilter',def);
        
    end


%%-------------------------------------------------------------------------
%%Automatically saving the changed parameters for the current panel if the
%%user change parameters for the other panels.
%%-------------------------------------------------------------------------
    function eeg_two_panels_change(~,~)
        if observe_EEGDAT.eeg_two_panels==0
            return;
        end
        ChangeFlag =  estudioworkingmemory('EEGTab_filter');
        if ChangeFlag~=1
            return;
        end
        EEG_filter_apply();
        gui_eeg_filtering.apply.BackgroundColor =  [1 1 1];
        gui_eeg_filtering.apply.ForegroundColor = [0 0 0];
        EEG_filtering_box.TitleColor= [0.0500    0.2500    0.5000];
        gui_eeg_filtering.cancel.BackgroundColor =  [1 1 1];
        gui_eeg_filtering.cancel.ForegroundColor = [0 0 0];
    end



%%--------------press return to execute "Apply"----------------------------
    function eeg_filter_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('EEGTab_filter');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            EEG_filter_apply();
            estudioworkingmemory('EEGTab_filter',0);
            gui_eeg_filtering.apply.BackgroundColor =  [1 1 1];
            gui_eeg_filtering.apply.ForegroundColor = [0 0 0];
            EEG_filtering_box.TitleColor= [0.0500    0.2500    0.5000];
            gui_eeg_filtering.cancel.BackgroundColor =  [1 1 1];
            gui_eeg_filtering.cancel.ForegroundColor = [0 0 0];
        else
            return;
        end
    end

end
%Progem end: ERP Measurement tool