%%This function is to interpolate channels for epoched EEG

% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Oct.2023


function varargout = f_EEG_interpolate_chan_epoch_GUI(varargin)

global observe_EEGDAT;
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'Reset_eeg_panel_change',@Reset_eeg_panel_change);
%---------------------------Initialize parameters------------------------------------

Eegtab_EEG_interpolate_chan_epoch = struct();

%-----------------------------Name the title----------------------------------------------

[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    box_interpolate_chan_epoch = uiextras.BoxPanel('Parent', fig, 'Title', 'Interpolate Channels',...
        'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    box_interpolate_chan_epoch = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Interpolate Channels',...
        'Padding', 5,'BackgroundColor',ColorB_def);
else
    box_interpolate_chan_epoch = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Interpolate Channels',...
        'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);%, 'HelpFcn', @intpchan_help
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

drawui_ic_chan_eeg(FonsizeDefault)
varargout{1} = box_interpolate_chan_epoch;

    function drawui_ic_chan_eeg(FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.95 0.95 0.95];
        end
        FontSize_defualt = FonsizeDefault;
        if isempty(FontSize_defualt)
            FontSize_defualt = 12;
        end
        Enable_label = 'off';
        %%--------------------channel and bin setting----------------------
        Eegtab_EEG_interpolate_chan_epoch.DataSelBox = uiextras.VBox('Parent', box_interpolate_chan_epoch,'BackgroundColor',ColorB_def);
        
        %%%----------------Mode-----------------------------------
        Eegtab_EEG_interpolate_chan_epoch.mode_1 = uiextras.HBox('Parent', Eegtab_EEG_interpolate_chan_epoch.DataSelBox,'BackgroundColor',ColorB_def);
        Eegtab_EEG_interpolate_chan_epoch.mode_modify_title = uicontrol('Style','text','Parent',Eegtab_EEG_interpolate_chan_epoch.mode_1 ,...
            'String','Mode:','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        Eegtab_EEG_interpolate_chan_epoch.mode_modify = uicontrol('Style','radiobutton','Parent',Eegtab_EEG_interpolate_chan_epoch.mode_1 ,...
            'String','Modify existing dataset','callback',@mode_modify,'Value',1,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',ColorB_def); % 2F
        Eegtab_EEG_interpolate_chan_epoch.mode_modify.KeyPressFcn = @eeg_interpolatechan_presskey;
        set(Eegtab_EEG_interpolate_chan_epoch.mode_1,'Sizes',[55 -1]);
        %%--------------For create a new ERPset----------------------------
        Eegtab_EEG_interpolate_chan_epoch.mode_2 = uiextras.HBox('Parent', Eegtab_EEG_interpolate_chan_epoch.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  Eegtab_EEG_interpolate_chan_epoch.mode_2,'BackgroundColor',ColorB_def);
        Eegtab_EEG_interpolate_chan_epoch.mode_create = uicontrol('Style','radiobutton','Parent',Eegtab_EEG_interpolate_chan_epoch.mode_2 ,...
            'String','Create new dataset','callback',@mode_create,'Value',0,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',ColorB_def); % 2F
        Eegtab_EEG_interpolate_chan_epoch.mode_create.KeyPressFcn = @eeg_interpolatechan_presskey;
        set(Eegtab_EEG_interpolate_chan_epoch.mode_2,'Sizes',[55 -1]);
        Eegtab_EEG_interpolate_chan_epoch.Parameters{1} = Eegtab_EEG_interpolate_chan_epoch.mode_modify.Value;
        
        erplabInterpolateElectrodes=  estudioworkingmemory('pop_erplabInterpolateElectrodes');
        try
            ignoreChannels           = erplabInterpolateElectrodes{2};
            interpolationMethod      = erplabInterpolateElectrodes{3};
        catch
            ignoreChannels           = [];
            interpolationMethod      = [];
        end
        if strcmpi(interpolationMethod,'spherical')
            InterpValue = 1;
        else
            InterpValue = 0;
        end
        
        %%Interpolate Channelsnels
        Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_title = uiextras.HBox('Parent', Eegtab_EEG_interpolate_chan_epoch.DataSelBox,'BackgroundColor',ColorB_def);
        
        uicontrol('Style','text','Parent',Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_title,...
            'String','Interpolated chan','FontSize',FontSize_defualt,'Enable','on','BackgroundColor',ColorB_def); % 2F
        
        Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_edit = uicontrol('Style','edit','Parent',Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_title,...
            'String','','FontSize',FontSize_defualt,'callback',@interpolate_chan_edit,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_edit.KeyPressFcn = @eeg_interpolatechan_presskey;
        Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_browse = uicontrol('Style','pushbutton','Parent',Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_title,...
            'String','Browse','FontSize',FontSize_defualt,'callback',@interpolate_chan_browse,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        set( Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_title,'Sizes',[100 -1 60]);
        Eegtab_EEG_interpolate_chan_epoch.Parameters{2} = str2num(Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_edit.String);
        
        
        Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_title_add1 = uiextras.HBox('Parent', Eegtab_EEG_interpolate_chan_epoch.DataSelBox,'BackgroundColor',ColorB_def);
        Eegtab_EEG_interpolate_chan_epoch.interpolate_methods= uicontrol('Style','text','Parent',Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_title_add1,...
            'String','Interpolation methods:','FontSize',FontSize_defualt,'Enable','on','BackgroundColor',ColorB_def); % 2F
        Eegtab_EEG_interpolate_chan_epoch.interpolate_inverse = uicontrol('Style','radiobutton','Parent',Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_title_add1 ,...
            'String','Inverse distance','callback',@interpolate_inverse,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',ColorB_def,'Value',~InterpValue); % 2F
        Eegtab_EEG_interpolate_chan_epoch.interpolate_inverse.String =  '<html> Inverse <br />distances</html>';
        Eegtab_EEG_interpolate_chan_epoch.interpolate_inverse.KeyPressFcn = @eeg_interpolatechan_presskey;
        Eegtab_EEG_interpolate_chan_epoch.interpolate_spherical = uicontrol('Style','radiobutton','Parent',Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_title_add1,...
            'String','Spherical ','callback',@interpolate_spherical,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',ColorB_def,'Value',InterpValue); % 2F
        Eegtab_EEG_interpolate_chan_epoch.interpolate_spherical.KeyPressFcn = @eeg_interpolatechan_presskey;
        set(Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_title_add1,'Sizes',[100 80 -1]);
        Eegtab_EEG_interpolate_chan_epoch.Parameters{3} = Eegtab_EEG_interpolate_chan_epoch.interpolate_inverse.Value;
        
        Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_title_add2 = uiextras.HBox('Parent', Eegtab_EEG_interpolate_chan_epoch.DataSelBox,'BackgroundColor',ColorB_def);
        
        Eegtab_EEG_interpolate_chan_epoch.ignore_chan = uicontrol('Style','checkbox','Parent',Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_title_add2,...
            'String','Ignored chans','callback',@ignore_chan,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',ColorB_def); % 2F
        Eegtab_EEG_interpolate_chan_epoch.ignore_chan.KeyPressFcn = @eeg_interpolatechan_presskey;
        Eegtab_EEG_interpolate_chan_epoch.Parameters{4}  = Eegtab_EEG_interpolate_chan_epoch.ignore_chan.Value;
        if isempty(ignoreChannels)
            Eegtab_EEG_interpolate_chan_epoch.ignore_chan.Value = 0;
        else
            Eegtab_EEG_interpolate_chan_epoch.ignore_chan.Value = 1;
        end
        Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit = uicontrol('Style','edit','Parent',Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_title_add2 ,...
            'String',' ','callback',@ignore_chan_edit,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.KeyPressFcn = @eeg_interpolatechan_presskey;
        try
            Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.String = num2str(ignoreChannels);
        catch
            Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.String = '';
        end
        Eegtab_EEG_interpolate_chan_epoch.ignore_chan_browse = uicontrol('Style','pushbutton','Parent',Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_title_add2 ,...
            'String','Browse','callback',@ignore_chan_browse,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        set(Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_title_add2,'Sizes',[110 -1 60]);
        Eegtab_EEG_interpolate_chan_epoch.Parameters{5} = str2num(Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.String);
        
        
        %%interpoate all time points
        Eegtab_EEG_interpolate_chan_epoch.interpolate_op_all_epoch_title = uiextras.HBox('Parent', Eegtab_EEG_interpolate_chan_epoch.DataSelBox,'BackgroundColor',ColorB_def);
        Eegtab_EEG_interpolate_chan_epoch.interpolate_op_all_epoch = uicontrol('Style','radiobutton','Parent',Eegtab_EEG_interpolate_chan_epoch.interpolate_op_all_epoch_title,...
            'String','Interpolate all time points','callback',@interpolate_op_all_epoch,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',ColorB_def,'Value',0); % 2F
        Eegtab_EEG_interpolate_chan_epoch.interpolate_op_all_epoch.KeyPressFcn = @eeg_interpolatechan_presskey;
        uiextras.Empty('Parent', Eegtab_EEG_interpolate_chan_epoch.interpolate_op_all_epoch_title);
        set(Eegtab_EEG_interpolate_chan_epoch.interpolate_op_all_epoch_title,'Sizes',[160 -1]);
        Eegtab_EEG_interpolate_chan_epoch.Parameters{6} =Eegtab_EEG_interpolate_chan_epoch.interpolate_op_all_epoch.Value;
        
        
        %%interpoate marked epochs  and its advanced options
        Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_title = uiextras.HBox('Parent', Eegtab_EEG_interpolate_chan_epoch.DataSelBox,'BackgroundColor',ColorB_def);
        Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_op = uicontrol('Style','radiobutton','Parent',Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_title,...
            'String','Interpolate marked epochs','callback',@interpolate_marked_epoch_op,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',ColorB_def,'Value',1); % 2F
        Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_op.KeyPressFcn = @eeg_interpolatechan_presskey;
        Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_op_advanced = uicontrol('Style','pushbutton','Parent',Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_title,...
            'String','Settings','callback',@interpolate_marked_epoch_op_advanced,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        uiextras.Empty('Parent', Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_title);
        set(Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_title,'Sizes',[180 70 -1]);
        
        
        %%-----------------------Cancel and Run----------------------------
        Eegtab_EEG_interpolate_chan_epoch.advanced_run_title = uiextras.HBox('Parent', Eegtab_EEG_interpolate_chan_epoch.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Eegtab_EEG_interpolate_chan_epoch.advanced_run_title);
        Eegtab_EEG_interpolate_chan_epoch.cancel = uicontrol('Style', 'pushbutton','Parent',Eegtab_EEG_interpolate_chan_epoch.advanced_run_title,...
            'String','Cancel','callback',@interpolated_chan_cancel,'FontSize',FonsizeDefault,'Enable',Enable_label,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', Eegtab_EEG_interpolate_chan_epoch.advanced_run_title);
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run = uicontrol('Style','pushbutton','Parent',Eegtab_EEG_interpolate_chan_epoch.advanced_run_title,...
            'String','Run','callback',@interpolate_run,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', Eegtab_EEG_interpolate_chan_epoch.advanced_run_title);
        set(Eegtab_EEG_interpolate_chan_epoch.advanced_run_title,'Sizes',[10,-1,30,-1,10]);
        
        %%resize each row
        set(Eegtab_EEG_interpolate_chan_epoch.DataSelBox,'sizes',[30 30 25 30 25 30 30 30])
        estudioworkingmemory('EEGTab_interpolated_chan_epoch',0);
    end
%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%---------------------Modify Existing dataset-----------------------------
    function mode_modify(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=8
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        box_interpolate_chan_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_interpolated_chan_epoch',1);
        Eegtab_EEG_interpolate_chan_epoch.mode_modify.Value =1;
        Eegtab_EEG_interpolate_chan_epoch.mode_create.Value = 0;
    end


%%---------------------Create new dataset----------------------------------
    function mode_create(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=8
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        box_interpolate_chan_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_interpolated_chan_epoch',1);
        Eegtab_EEG_interpolate_chan_epoch.mode_modify.Value =0;
        Eegtab_EEG_interpolate_chan_epoch.mode_create.Value = 1;
    end


%%---------------Edit channels that will be interpolated-------------------
    function interpolate_chan_edit(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=8
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        box_interpolate_chan_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_interpolated_chan_epoch',1);
        
        Newchan = round(str2num(Source.String));
        if isempty(Newchan) || any(Newchan(:) <=0)
            msgboxText = ['Interpolate Channels > Indexes of interpolated chans should be positive values'];
            Source.String = '';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        ChanNum = observe_EEGDAT.EEG.nbchan;
        if any(Newchan(:) > ChanNum)
            msgboxText =['Interpolate Channels > Any indexes of interpolated chans should be between 1 and ',32,num2str(ChanNum)];
            Source.String = '';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        ChanignoreArray = str2num(Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.String);
        overlap_elec = intersect(Newchan,ChanignoreArray);
        if ~isempty(overlap_elec)
            msgboxText = ['Interpolate Channels: There is overlap between the interpolated chans and the ignore chans'];
            Source.String = '';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        Newchan =  vect2colon(Newchan);
        Newchan = erase(Newchan,{'[',']'});
        Source.String= Newchan;
    end


%%------------Browse channels that will be interpolated--------------------
    function interpolate_chan_browse(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=8
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        box_interpolate_chan_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_interpolated_chan_epoch',1);
        
        %%-------Browse and select chans that will be interpolated---------
        EEG = observe_EEGDAT.EEG;
        for Numofchan = 1:EEG.nbchan
            try
                listb{Numofchan}= strcat(num2str(Numofchan),'.',EEG.chanlocs(Numofchan).labels);
            catch
                listb{Numofchan}= strcat('Chan:',32,num2str(Numofchan));
            end
        end
        chaninterpolated = str2num(Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_edit.String);
        if isempty(chaninterpolated)
            indxlistb = EEG.nbchan;
        else
            if min(chaninterpolated(:)) >0  && max(chaninterpolated(:)) <= EEG.nbchan
                indxlistb = chaninterpolated;
            else
                indxlistb = EEG.nbchan;
            end
        end
        titlename = 'Select interpolated Channel(s):';
        
        chan_label_select = browsechanbinGUI(listb, indxlistb, titlename);
        if ~isempty(chan_label_select)
            chan_label_select =  vect2colon(chan_label_select);
            chan_label_select = erase(chan_label_select,{'[',']'});
            Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_edit.String  = chan_label_select;
        else
            return
        end
    end

%%-----------------Interpolate channel method:inverse----------------------
    function interpolate_inverse(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=8
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        box_interpolate_chan_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_interpolated_chan_epoch',1);
        Eegtab_EEG_interpolate_chan_epoch.interpolate_inverse.Value= 1;
        Eegtab_EEG_interpolate_chan_epoch.interpolate_spherical.Value=0;
    end

%%------------------ignore chan when interpolate chan----------------------
    function ignore_chan(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        ignoreValue = Source.Value;
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=8
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        box_interpolate_chan_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_interpolated_chan_epoch',1);
        if ignoreValue==1
            Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.Enable='on';
            Eegtab_EEG_interpolate_chan_epoch.ignore_chan_browse.Enable='on';
        else
            Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.Enable='off';
            Eegtab_EEG_interpolate_chan_epoch.ignore_chan_browse.Enable='off';
        end
    end


%%-------------------methods for interpolate chan--------------------------
    function interpolate_spherical(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=8
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        box_interpolate_chan_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_interpolated_chan_epoch',1);
        Eegtab_EEG_interpolate_chan_epoch.interpolate_inverse.Value= 0;
        Eegtab_EEG_interpolate_chan_epoch.interpolate_spherical.Value=1;
    end

%%-------------------edit ignore chan--------------------------------------
    function ignore_chan_edit(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=8
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        box_interpolate_chan_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_interpolated_chan_epoch',1);
        ChanArray =  str2num(Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_edit.String);
        
        ChanArrayNew = str2num(Source.String);
        if isempty(ChanArrayNew) || any(ChanArrayNew(:)<=0)
            msgboxText = ['Interpolate Channels: Any index(es) of the ignored channels should be positive value'];
            Source.String = '';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        if any(ChanArrayNew(:) > observe_EEGDAT.EEG.nbchan)
            msgboxText = ['Interpolate Channels: Any index(es) of the ignored channels should be below ',32,num2str(observe_EEGDAT.EEG.nbchan)];
            Source.String = '';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        overlap_elec = intersect(ChanArray, ChanArrayNew);
        if ~isempty(overlap_elec)
            msgboxText = ['Interpolate Channels: There is overlap in the replace electrodes and the ignore electrodes'];
            Source.String = '';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        Source.String= vect2colon(ChanArrayNew);
        
    end

%%---------------------browse chan for ignore chan-------------------------
    function ignore_chan_browse(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=8
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        box_interpolate_chan_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_interpolated_chan_epoch',1);
        ChanArray =  str2num(Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_edit.String);
        EEG = observe_EEGDAT.EEG;
        for Numofchan = 1:EEG.nbchan
            try
                listb{Numofchan}= strcat(num2str(Numofchan),'.',EEG.chanlocs(Numofchan).labels);
            catch
                listb{Numofchan}= strcat('Chan:',32,num2str(Numofchan));
            end
        end
        chanIgnore = str2num(Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.String);
        if isempty(chanIgnore)
            indxlistb = EEG.nbchan;
        else
            if any(chanIgnore(:) >0)  && any(chanIgnore(:) <= EEG.nbchan)
                indxlistb = chanIgnore;
            else
                indxlistb = EEG.nbchan;
            end
        end
        titlename = 'Select Ignored Channel(s):';
        chan_label_select = browsechanbinGUI(listb, indxlistb, titlename);
        if ~isempty(chan_label_select)
            Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.String  = vect2colon(chan_label_select);
        else
            return
        end
        
        ChanArrayNew =  str2num(Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.String);
        overlap_elec = intersect(ChanArray, ChanArrayNew);
        if ~isempty(overlap_elec)
            msgboxText = ['Interpolate Channels > There is overlap in the replace electrodes and the ignore electrodes'];
            Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.String = '';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
    end


%%------------------interpolate all epochs option -------------------------
    function interpolate_op_all_epoch(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=8
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        box_interpolate_chan_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_interpolated_chan_epoch',1);
        Eegtab_EEG_interpolate_chan_epoch.interpolate_op_all_epoch.Value=1;
        Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_op.Value=0;
    end


%%----------------------Interpolate marked epochs option-------------------
    function interpolate_marked_epoch_op(Source,~)
        if isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=8
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        box_interpolate_chan_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_interpolated_chan_epoch',1);
        Eegtab_EEG_interpolate_chan_epoch.interpolate_op_all_epoch.Value=0;
        Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_op.Value=1;
    end


%%------------------Inerpolate the marked epochs of advanced---------------
    function interpolate_marked_epoch_op_advanced(Source,~)
        if isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials==1
            Source.Enable= 'off';
            return;
        end
        
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=8
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        box_interpolate_chan_epoch.TitleColor= [0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.cancel.ForegroundColor = [1 1 1];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_interpolated_chan_epoch',1);
        
        
        if Eegtab_EEG_interpolate_chan_epoch.interpolate_spherical.Value==1
            interpolationMethod = 'spherical';
        else
            interpolationMethod =  'inverse_distance';
        end
        
        
        if Eegtab_EEG_interpolate_chan_epoch.ignore_chan.Value==0
            ChanArrayig = [];
        else
            ChanArrayig =  str2num(Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.String);
        end
        
        %%loop for the selected EEGsets
        
        EEG = observe_EEGDAT.EEG;
        
        %%%%---------------Call GUI--------------------------
        dlg_title = {['Dataset',32,num2str(observe_EEGDAT.CURRENTSET),': Interpolate Marked Artifact Epochs']};
        %defaults
        defx = {0, 'spherical',[],[],[],0,10};
        def = estudioworkingmemory('pop_artinterp');
        def{2} = interpolationMethod;
        
        if ~isempty(ChanArrayig) && max(ChanArrayig(:)) <= EEG.nbchan
            def{5} = ChanArrayig;
        else
            def{5} = [];
        end
        
        if isempty(def)
            def = defx;
        else
            try
                def{3} = def{3}(ismember_bc2(def{3},1:EEG(1).nbchan));
            catch
                def{3} = 1:EEG(1).nbchan;
            end
        end
        try
            aa = def{4};
        catch
            def{4} = [];
        end
        
        try
            aa = def{6};
        catch
            def{6} = [];
        end
        
        try
            aa = def{7};
        catch
            def{7} = 10;
        end
        
        try
            chanlabels = {EEG(1).chanlocs.labels}; %only works on single datasets
        catch
            chanlabels = [];
        end
        histoflags = summary_rejectflags(EEG);
        
        %check currently activated flags
        flagcheck = sum(histoflags);
        active_flags = (flagcheck>1);
        
        answer = artifactinterpGUI(dlg_title, def, defx, chanlabels, active_flags);
        
        if isempty(answer)
            observe_EEGDAT.eeg_panel_message =2;
            fprintf( ['\n',repmat('-',1,100) '\n']);
            return
        end
        
        replaceFlag =  answer{1};
        interpolationMethod      =  answer{2};
        replaceChannelInd     =  answer{3};
        replaceChannelLabel     =  answer{4};
        ignoreChannels  =  unique_bc2(answer{5}); % avoids repeted channels
        many_electrodes = answer{6};
        threshold_perc = answer{7};
        viewstr = 'off';
        
        estudioworkingmemory('pop_artinterp', {answer{1} answer{2} answer{3} answer{4} answer{5} ...
            answer{6}, answer{7}});
        if ~isempty(ignoreChannels)
            Eegtab_EEG_interpolate_chan_epoch.ignore_chan.Value=1;
            Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.Enable = 'on';
            Eegtab_EEG_interpolate_chan_epoch.ignore_chan_browse.Enable = 'on';
        else
            Eegtab_EEG_interpolate_chan_epoch.ignore_chan.Value=0;
            Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.Enable = 'off';
            Eegtab_EEG_interpolate_chan_epoch.ignore_chan_browse.Enable = 'off';
        end
        ignoreChannels =  vect2colon(ignoreChannels);
        ignoreChannels = erase(ignoreChannels,{'[',']'});
        Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.String= ignoreChannels;
        
        if strcmpi(interpolationMethod,'spherical')
            Eegtab_EEG_interpolate_chan_epoch.interpolate_spherical.Value=1 ;
            Eegtab_EEG_interpolate_chan_epoch.interpolate_inverse.Value=0;
        else
            Eegtab_EEG_interpolate_chan_epoch.interpolate_spherical.Value=0;
            Eegtab_EEG_interpolate_chan_epoch.interpolate_inverse.Value=1;
        end
        
        if many_electrodes==1
            chanArray = 1:EEG.nbchan;
        else
            chanArray =  replaceChannelInd;
        end
        chanArray =  vect2colon(chanArray);
        chanArray = erase(chanArray,{'[',']'});
        Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_edit.String = chanArray;
    end


%%------------------run for interpolation----------------------------------
    function interpolate_run(Source,~)
        if isempty(observe_EEGDAT.EEG) %%|| observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        
        if   Eegtab_EEG_interpolate_chan_epoch.interpolate_op_all_epoch.Value==1
            interpolate_allchan();%%for all epochs
        else
            interpolate_marked_epoch() ; %% for marked epochs
        end
        Eegtab_EEG_interpolate_chan_epoch.cancel.BackgroundColor =  [ 1 1 1];
        Eegtab_EEG_interpolate_chan_epoch.cancel.ForegroundColor = [0 0 0];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.BackgroundColor =  [1 1 1];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.ForegroundColor = [0 0 0];
        Eegtab_EEG_interpolate_chan_epoch.Parameters{1} = Eegtab_EEG_interpolate_chan_epoch.mode_modify.Value;
        Eegtab_EEG_interpolate_chan_epoch.Parameters{2} = str2num(Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_edit.String);
        Eegtab_EEG_interpolate_chan_epoch.Parameters{3} = Eegtab_EEG_interpolate_chan_epoch.interpolate_inverse.Value;
        Eegtab_EEG_interpolate_chan_epoch.Parameters{4}  = Eegtab_EEG_interpolate_chan_epoch.ignore_chan.Value;
        Eegtab_EEG_interpolate_chan_epoch.Parameters{5} = str2num(Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.String);
        Eegtab_EEG_interpolate_chan_epoch.Parameters{6} =Eegtab_EEG_interpolate_chan_epoch.interpolate_op_all_epoch.Value;
    end

%%------------------Interpolate all time points----------------------------
    function interpolate_allchan(~,~)
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=8
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        box_interpolate_chan_epoch.TitleColor= [0.0500    0.2500    0.5000];
        estudioworkingmemory('EEGTab_interpolated_chan_epoch',0);
        
        estudioworkingmemory('f_EEG_proces_messg','Interpolate Channels >  Run');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG)) ||  any(EEGArray(:) <1)
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        if Eegtab_EEG_interpolate_chan_epoch.interpolate_spherical.Value==1
            interpolationMethod = 'spherical';
        else
            interpolationMethod =  'invdist';
        end
        
        ChanArray =  str2num(Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_edit.String);
        if isempty(ChanArray) || any(ChanArray(:)<=0)
            msgboxText = ['Interpolate Channels >  Run: The index(es) of the interpolated chans should be positive numbers'];
            Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_edit.String = '';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        if Eegtab_EEG_interpolate_chan_epoch.ignore_chan.Value==0
            ChanArrayig = [];
        else
            ChanArrayig =  str2num(Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.String);
        end
        if ~isempty(ChanArrayig)
            overlap_elec = intersect(ChanArray, ChanArrayig);
            if ~isempty(overlap_elec)
                msgboxText = ['Interpolate Channels >  Run: There is overlap in the replace electrodes and the ignore electrodes'];
                Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.String = '';
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            
            if  any(ChanArrayig(:)<=0)
                msgboxText = ['Interpolate Channels > Run: Index(es) of the ignored channels should be positive values'];
                Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.String = '';
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            
            if any(ChanArrayig(:) > observe_EEGDAT.EEG.nbchan)
                msgboxText = ['Interpolate Channels >  Run: Index(es) of the ignored channels should be smaller than',32,num2str(observe_EEGDAT.EEG.nbchan)];
                Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.String = '';
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
        end
        if numel(ChanArrayig) + numel(ChanArray) ==observe_EEGDAT.EEG.nbchan
            msgboxText = ['Interpolate Channels >  Run: Too many channels will be interpolated or ignored, please left enough channels that are to interpolate others'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        CreateeegFlag = Eegtab_EEG_interpolate_chan_epoch.mode_create.Value; %%create new eeg dataset
        ALLEEG = observe_EEGDAT.ALLEEG;
        ALLEEG_out = [];
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Interpolate selected chan*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            
            %%check the selected chans
            if any(ChanArray(:) > EEG.nbchan)
                msgboxText = ['Interpolate Channels >  Run: Selected channel should be between 1 and ',32, num2str(EEG.nbchan)];
                fprintf( ['\n',repmat('-',1,100) '\n']);
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            
            if numel(ChanArray) == EEG.nbchan
                msgboxText = ['Interpolate Channels >  Run: We strongly recommend you donot need to interpolate all channels'];
                fprintf( ['\n',repmat('-',1,100) '\n']);
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            [EEG,LASTCOM] = pop_erplabInterpolateElectrodes( EEG , 'displayEEG',  0, 'ignoreChannels', ChanArrayig,...
                'interpolationMethod', interpolationMethod, 'replaceChannels',ChanArray,'history', 'implicit');
            fprintf([LASTCOM,'\n']);
            EEG = eegh(LASTCOM, EEG);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            [ALLEEG_out,~, ~,LASTCOM] = pop_newset(ALLEEG_out, EEG, length(ALLEEG_out), 'gui', 'off');
            fprintf( [repmat('-',1,100) '\n']);
        end
        Save_file_label=0;
        if CreateeegFlag==1
            Answer = f_EEG_save_multi_file(ALLEEG_out,1:numel(EEGArray),'_interp');
            if isempty(Answer)
                return;
            end
            if ~isempty(Answer{1})
                ALLEEG_out = Answer{1};
                Save_file_label = Answer{2};
            end
        end
        
        if CreateeegFlag==0
            ALLEEG(EEGArray) = ALLEEG_out;
        else
            for Numofeeg = 1:numel(EEGArray)
                EEG = ALLEEG_out(Numofeeg);
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
                [ALLEEG,~, ~,LASTCOM] = pop_newset(ALLEEG, EEG, length(ALLEEG), 'gui', 'off');
                if Numofeeg==1
                    eegh(LASTCOM);
                end
            end
        end
        
        observe_EEGDAT.ALLEEG = ALLEEG;
        if CreateeegFlag==1
            try
                Selected_EEG_afd =  [length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1:length(observe_EEGDAT.ALLEEG)];
                observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1;
            catch
                Selected_EEG_afd = length(observe_EEGDAT.ALLEEG);
                observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG);
            end
            
            estudioworkingmemory('EEGArray',Selected_EEG_afd);
            assignin('base','EEG',observe_EEGDAT.EEG);
            assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
            assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        end
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
        observe_EEGDAT.count_current_eeg=1;
        observe_EEGDAT.eeg_panel_message =2;
    end

%%------------------Inerpolate the marked epochs---------------------------
    function interpolate_marked_epoch(~,~)
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=8
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        box_interpolate_chan_epoch.TitleColor= [0.0500    0.2500    0.5000];
        estudioworkingmemory('EEGTab_interpolated_chan_epoch',0);
        
        estudioworkingmemory('f_EEG_proces_messg','Interpolate Channels >  Run');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        replaceChannelIndes =  str2num(Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_edit.String);
        if isempty(replaceChannelIndes) || min(replaceChannelIndes(:))<=0
            msgboxText = ['Interpolate Channels >  Run: Index(es) of interpolated chans should be positive numbers'];
            Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_edit.String = '';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
         def =  estudioworkingmemory('pop_artinterp');
        defx = {0, 'spherical',[],[],[],0,10};
        if isempty(def)
            def = defx;
        end
        try threshold_perc = def{7}; catch  threshold_perc = 10;end
        if isempty(threshold_perc) || numel(threshold_perc)~=1 || any(threshold_perc(:)<0) || any(threshold_perc(:)>100)
            threshold_perc = 10;
        end
        def{7} = 10;
        try  many_electrodes = def{6}; catch  many_electrodes = 0;end
        if isempty(many_electrodes) || numel(many_electrodes)~=1 || (many_electrodes~=0 && many_electrodes~=1)
            many_electrodes=0;
        end
        def{6}=0;
        
        try replaceFlag  = def{1}; catch replaceFlag =[]; end
        
        
        if Eegtab_EEG_interpolate_chan_epoch.ignore_chan.Value==0
            ignoreChannels = [];
        else
            ignoreChannels =  str2num(Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.String);
        end
        if ~isempty(ignoreChannels)
            overlap_elec = intersect(replaceChannelIndes, ignoreChannels);
            if ~isempty(overlap_elec)
                msgboxText = ['Interpolate Channels >  Run: There is overlap in the replace electrodes and the ignore electrodes'];
                Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.String = '';
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                observe_EEGDAT.eeg_panel_message =2;
                return;
            end
            
            if  any(ignoreChannels(:)<=0)
                msgboxText = ['Interpolate Channels > Run: Index(es) of the ignored channels should be positive values'];
                Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.String = '';
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                observe_EEGDAT.eeg_panel_message =2;
                return;
            end
            
            if any(ignoreChannels(:) > observe_EEGDAT.EEG.nbchan)
                msgboxText = ['Interpolate Channels >  Run: Index(es) of the ignored channels should be smaller than',32,num2str(observe_EEGDAT.EEG.nbchan)];
                Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.String = '';
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                observe_EEGDAT.eeg_panel_message =2;
                return;
            end
        end
        
        if Eegtab_EEG_interpolate_chan_epoch.interpolate_spherical.Value==1
            interpolationMethod = 'spherical';
        else
            interpolationMethod =  'invdist';
        end
        
        CreateeegFlag = Eegtab_EEG_interpolate_chan_epoch.mode_create.Value; %%create new eeg dataset
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG)) ||  any(EEGArray(:) <1)
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
%         if numel(ignoreChannels) + numel(replaceChannelIndes) ==observe_EEGDAT.EEG.nbchan
%             msgboxText = ['Interpolate Channels >  Run: Too many channels will be interpolated or ignored, please left enough channels that are to interpolate others'];
%             titlNamerro = 'Warning for EEG Tab';
%             estudio_warning(msgboxText,titlNamerro);
%             observe_EEGDAT.eeg_panel_message =2;
%             return;
%         end
        
        %%loop for the selected EEGsets
        ALLEEG = observe_EEGDAT.ALLEEG;
        ALLEEG_out = [];
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Interpolate marked epochs*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            
            %%check interpolated chans and ignored chans
            if any(replaceChannelIndes(:) > EEG.nbchan )
                msgboxText = ['Interpolate Channels >  Run: Interpolated chans should be smaller than',32,num2str( EEG.nbchan)];
                estudioworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
                fprintf( ['\n',repmat('-',1,100) '\n']);
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                observe_EEGDAT.eeg_panel_message =2;
                return;
            end
            
            if any(ignoreChannels(:) > EEG.nbchan)
                msgboxText = ['Interpolate Channels >  Run: Ignored chans should be smaller than',32,num2str( EEG.nbchan)];
                fprintf( ['\n',repmat('-',1,100) '\n']);
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                
                return;
            end
            if isempty(replaceFlag)
                histoflags = summary_rejectflags(EEG);
                %check currently activated flags
                flagcheck = sum(histoflags);
                flagcheck(1) = 0;
                [~, active_flags] = find(flagcheck>1);
                
                if isempty(active_flags)
                    msgboxText = ['Interpolate Channels >  Run: None of epochs was marked'];
                    fprintf( ['\n',repmat('-',1,100) '\n']);
                    titlNamerro = 'Warning for EEG Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    return;
                end
                
                
                if ~isempty(find(active_flags<1 | active_flags>16, 1))
                    msgboxText  ='Interpolate Channels >  Run: flag cannot be greater than 16 nor lesser than 1';
                    fprintf( ['\n',repmat('-',1,100) '\n']);
                    titlNamerro = 'Warning for EEG Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    return;
                end
            else
                active_flags=  replaceFlag;
            end
            
            for Numofchan = 1:numel(replaceChannelIndes)%%loop for each chan
                replaceChannelInd = replaceChannelIndes(Numofchan);
                
                fprintf( ['\n Interpolating chan',32, num2str(replaceChannelInd),'...\n']);
                %%Run ICA
                [EEG, LASTCOM] = pop_artinterp(EEG, 'FlagToUse', active_flags, 'InterpMethod', interpolationMethod, ...
                    'ChanToInterp', replaceChannelInd, 'ChansToIgnore', ignoreChannels, ...
                    'InterpAnyChan', many_electrodes, 'Threshold',threshold_perc,...
                    'Review', 'off', 'History', 'implicit');
                if isempty(LASTCOM)
                    estudioworkingmemory('f_EEG_proces_messg','Interpolate Channels >  Run: Please check you data or you selected cancel');
                    observe_EEGDAT.eeg_panel_message =4;
                    return;
                end
                EEG = eegh(LASTCOM, EEG);
                fprintf(['\n',LASTCOM,'\n']);
            end
            if Numofeeg==1
                eegh(LASTCOM);
            end
            [ALLEEG_out,~,~,LASTCOM] = pop_newset(ALLEEG_out, EEG, length(ALLEEG_out), 'gui', 'off');
            fprintf( ['\n',repmat('-',1,100) '\n']);
        end
        Save_file_label=0;
        if CreateeegFlag==1
            Answer = f_EEG_save_multi_file(ALLEEG_out,1:numel(EEGArray),'_ar');
            if isempty(Answer)
                return;
            end
            if ~isempty(Answer{1})
                ALLEEG_out = Answer{1};
                Save_file_label = Answer{2};
            end
        end
        
        if CreateeegFlag==0
            ALLEEG(EEGArray) = ALLEEG_out;
        else
            for Numofeeg = 1:numel(EEGArray)
                EEG = ALLEEG_out(Numofeeg);
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
            end
        end
        
        observe_EEGDAT.ALLEEG = ALLEEG;
        if CreateeegFlag==1
            try
                Selected_EEG_afd =  [length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1:length(observe_EEGDAT.ALLEEG)];
                observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1;
            catch
                Selected_EEG_afd = length(observe_EEGDAT.ALLEEG);
                observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG);
            end
            
            estudioworkingmemory('EEGArray',Selected_EEG_afd);
            assignin('base','EEG',observe_EEGDAT.EEG);
            assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
            assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        end
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
        observe_EEGDAT.count_current_eeg=1;
        observe_EEGDAT.eeg_panel_message =2;
    end


%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=5
            return;
        end
        EEGUpdate = estudioworkingmemory('EEGUpdate');
        if isempty(EEGUpdate) || numel(EEGUpdate)~=1 || (EEGUpdate~=0 && EEGUpdate~=1)
            EEGUpdate = 0;  estudioworkingmemory('EEGUpdate',0);
        end
        if  isempty(observe_EEGDAT.EEG) || EEGUpdate==1
            Eegtab_EEG_interpolate_chan_epoch.mode_modify.Enable ='off';
            Eegtab_EEG_interpolate_chan_epoch.mode_create.Enable = 'off';
            Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_edit.Enable= 'off';
            Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_browse.Enable= 'off';
            Eegtab_EEG_interpolate_chan_epoch.interpolate_inverse.Enable= 'off';
            Eegtab_EEG_interpolate_chan_epoch.ignore_chan.Enable='off';
            Eegtab_EEG_interpolate_chan_epoch.interpolate_spherical.Enable='off';
            Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.Enable='off';
            Eegtab_EEG_interpolate_chan_epoch.ignore_chan_browse.Enable='off';
            Eegtab_EEG_interpolate_chan_epoch.interpolate_op_all_epoch.Enable='off';
            Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_op.Enable='off';
            Eegtab_EEG_interpolate_chan_epoch.interpolate_run.Enable='off';
            Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_op_advanced.Enable='off';
            Eegtab_EEG_interpolate_chan_epoch.cancel.Enable='off';
            observe_EEGDAT.count_current_eeg=6;
            return;
        end
        Eegtab_EEG_interpolate_chan_epoch.mode_modify.Enable ='on';
        Eegtab_EEG_interpolate_chan_epoch.mode_create.Enable = 'on';
        Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_edit.Enable= 'on';
        Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_browse.Enable= 'on';
        Eegtab_EEG_interpolate_chan_epoch.interpolate_inverse.Enable= 'on';
        Eegtab_EEG_interpolate_chan_epoch.ignore_chan.Enable='on';
        Eegtab_EEG_interpolate_chan_epoch.interpolate_spherical.Enable='on';
        Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.Enable='on';
        Eegtab_EEG_interpolate_chan_epoch.ignore_chan_browse.Enable='on';
        Eegtab_EEG_interpolate_chan_epoch.interpolate_op_all_epoch.Enable='on';
        Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_op.Enable='on';
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.Enable='on';
        Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_op_advanced.Enable='on';
        Eegtab_EEG_interpolate_chan_epoch.cancel.Enable='on';
        if Eegtab_EEG_interpolate_chan_epoch.ignore_chan.Value==0
            Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.Enable='off';
            Eegtab_EEG_interpolate_chan_epoch.ignore_chan_browse.Enable='off';
        end
        if observe_EEGDAT.EEG.trials ==1
            Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_op_advanced.Enable='off';
            Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_op.Enable='off';
            Eegtab_EEG_interpolate_chan_epoch.interpolate_op_all_epoch.Value = 1;
            Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_op.Value = 0;
            Eegtab_EEG_interpolate_chan_epoch.Parameters{6} =  Eegtab_EEG_interpolate_chan_epoch.interpolate_op_all_epoch.Value ;
        end
        observe_EEGDAT.count_current_eeg=6;
    end

%%-----------------------------cancel--------------------------------------
    function interpolated_chan_cancel(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable = 'off';
            return;
        end
        
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=8
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_interpolated_chan_epoch',0);
        box_interpolate_chan_epoch.TitleColor= [0.0500    0.2500    0.5000];
        Eegtab_EEG_interpolate_chan_epoch.cancel.BackgroundColor =  [ 1 1 1];
        Eegtab_EEG_interpolate_chan_epoch.cancel.ForegroundColor = [0 0 0];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.BackgroundColor =  [1 1 1];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.ForegroundColor = [0 0 0];
        try
            Eegtab_EEG_interpolate_chan_epoch.mode_modify.Value=Eegtab_EEG_interpolate_chan_epoch.Parameters{1};
            Eegtab_EEG_interpolate_chan_epoch.mode_create.Value=~Eegtab_EEG_interpolate_chan_epoch.Parameters{1};
            Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_edit.String = num2str( Eegtab_EEG_interpolate_chan_epoch.Parameters{2});
            Eegtab_EEG_interpolate_chan_epoch.interpolate_inverse.Value = Eegtab_EEG_interpolate_chan_epoch.Parameters{3} ;
            Eegtab_EEG_interpolate_chan_epoch.interpolate_spherical.Value = ~Eegtab_EEG_interpolate_chan_epoch.Parameters{3} ;
            Eegtab_EEG_interpolate_chan_epoch.ignore_chan.Value=Eegtab_EEG_interpolate_chan_epoch.Parameters{4};
            Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.String = num2str(Eegtab_EEG_interpolate_chan_epoch.Parameters{5});
            Eegtab_EEG_interpolate_chan_epoch.interpolate_op_all_epoch.Value = Eegtab_EEG_interpolate_chan_epoch.Parameters{6};
            Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_op.Value = ~Eegtab_EEG_interpolate_chan_epoch.Parameters{6};
            if Eegtab_EEG_interpolate_chan_epoch.ignore_chan.Value==0%%if inactive ignored chans
                Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.Enable='off';
                Eegtab_EEG_interpolate_chan_epoch.ignore_chan_browse.Enable='off';
            end
            if observe_EEGDAT.EEG.trials ==1%%Force the "interpolate marked epochs" to be grayed out.
                Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_op_advanced.Enable='off';
                Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_op.Enable='off';
                Eegtab_EEG_interpolate_chan_epoch.interpolate_op_all_epoch.Value = 1;
                Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_op.Value = 0;
                Eegtab_EEG_interpolate_chan_epoch.Parameters{6} =  Eegtab_EEG_interpolate_chan_epoch.interpolate_op_all_epoch.Value ;
            end
        catch
        end
    end


%%--------------press return to execute "Apply"----------------------------
    function eeg_interpolatechan_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('EEGTab_plotset');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            interpolate_run();
            estudioworkingmemory('EEGTab_interpolated_chan_epoch',0);
            box_interpolate_chan_epoch.TitleColor= [0.0500    0.2500    0.5000];
            Eegtab_EEG_interpolate_chan_epoch.cancel.BackgroundColor =  [ 1 1 1];
            Eegtab_EEG_interpolate_chan_epoch.cancel.ForegroundColor = [0 0 0];
            Eegtab_EEG_interpolate_chan_epoch.interpolate_run.BackgroundColor =  [1 1 1];
            Eegtab_EEG_interpolate_chan_epoch.interpolate_run.ForegroundColor = [0 0 0];
        else
            return;
        end
    end

%%--------------Reset this panel with the default parameters---------------
    function Reset_eeg_panel_change(~,~)
        if observe_EEGDAT.Reset_eeg_paras_panel~=5
            return;
        end
        estudioworkingmemory('EEGTab_interpolated_chan_epoch',0);
        Eegtab_EEG_interpolate_chan_epoch.cancel.BackgroundColor =  [ 1 1 1];
        Eegtab_EEG_interpolate_chan_epoch.cancel.ForegroundColor = [0 0 0];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.BackgroundColor =  [1 1 1];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_run.ForegroundColor = [0 0 0];
        Eegtab_EEG_interpolate_chan_epoch.interpolate_inverse.Value= 1;
        Eegtab_EEG_interpolate_chan_epoch.interpolate_spherical.Value=0;
        Eegtab_EEG_interpolate_chan_epoch.interpolate_chan_edit.String = '';
        Eegtab_EEG_interpolate_chan_epoch.interpolate_inverse.Value= 1;
        Eegtab_EEG_interpolate_chan_epoch.interpolate_spherical.Value=0;
        Eegtab_EEG_interpolate_chan_epoch.ignore_chan.Value=0;
        Eegtab_EEG_interpolate_chan_epoch.ignore_chan_edit.String = '';
        Eegtab_EEG_interpolate_chan_epoch.interpolate_op_all_epoch.Value= 1;
        Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_op.Value=0;
        if ~isempty(observe_EEGDAT.EEG)
            if observe_EEGDAT.EEG.trials ==1%%Force the "interpolate marked epochs" to be grayed out.
                Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_op_advanced.Enable='off';
                Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_op.Enable='off';
            else
                Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_op_advanced.Enable='off';
                Eegtab_EEG_interpolate_chan_epoch.interpolate_marked_epoch_op.Enable='on';
            end
        end
        observe_EEGDAT.Reset_eeg_paras_panel=6;
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