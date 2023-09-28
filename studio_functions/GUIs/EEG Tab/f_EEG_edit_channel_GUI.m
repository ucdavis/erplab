%%This function is to Edit channels

% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Sep.2023


function varargout = f_EEG_edit_channel_GUI(varargin)

global observe_EEGDAT;
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
% addlistener(observe_EEGDAT,'eeg_panel_change_message',@eeg_panel_change_message);
addlistener(observe_EEGDAT,'eeg_reset_def_paras_change',@eeg_reset_def_paras_change);
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
%---------------------------Initialize parameters------------------------------------

EStduio_eegtab_EEG_edit_chan = struct();

%-----------------------------Name the title----------------------------------------------
% global EStudio_eeg_box_edit_chan;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    EStudio_eeg_box_edit_chan = uiextras.BoxPanel('Parent', fig, 'Title', 'Edit Channels', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    EStudio_eeg_box_edit_chan = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Edit Channels', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    EStudio_eeg_box_edit_chan = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Edit Channels', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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
varargout{1} = EStudio_eeg_box_edit_chan;

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
        EStduio_eegtab_EEG_edit_chan.DataSelBox = uiextras.VBox('Parent', EStudio_eeg_box_edit_chan,'BackgroundColor',ColorB_def);
        
        %%%----------------Mode-----------------------------------
        EStduio_eegtab_EEG_edit_chan.mode_1 = uiextras.HBox('Parent', EStduio_eegtab_EEG_edit_chan.DataSelBox,'BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_edit_chan.mode_modify_title = uicontrol('Style','text','Parent',EStduio_eegtab_EEG_edit_chan.mode_1 ,...
            'String','Mode:','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        EStduio_eegtab_EEG_edit_chan.mode_modify = uicontrol('Style','radiobutton','Parent',EStduio_eegtab_EEG_edit_chan.mode_1 ,...
            'String','Modify Existing dataset','callback',@mode_modify,'Value',1,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',ColorB_def); % 2F
        EStduio_eegtab_EEG_edit_chan.mode_modify.String =  '<html>Modify Existing dataset<br />(recursive updating)</html>';
        set(EStduio_eegtab_EEG_edit_chan.mode_1,'Sizes',[55 -1]);
        %%--------------For create a new ERPset----------------------------
        EStduio_eegtab_EEG_edit_chan.mode_2 = uiextras.HBox('Parent', EStduio_eegtab_EEG_edit_chan.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  EStduio_eegtab_EEG_edit_chan.mode_2,'BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_edit_chan.mode_create = uicontrol('Style','radiobutton','Parent',EStduio_eegtab_EEG_edit_chan.mode_2 ,...
            'String',{'', ''},'callback',@mode_create,'Value',0,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',ColorB_def); % 2F
        EStduio_eegtab_EEG_edit_chan.mode_create.String =  '<html>Create New dataset<br />(independent transformations)</html>';
        set(EStduio_eegtab_EEG_edit_chan.mode_2,'Sizes',[55 -1]);
        
        
        %%Delete selected channels && Rename selected channels
        EStduio_eegtab_EEG_edit_chan.delete_rename = uiextras.HBox('Parent', EStduio_eegtab_EEG_edit_chan.DataSelBox,'BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_edit_chan.delete_chan = uicontrol('Style','pushbutton','Parent',EStduio_eegtab_EEG_edit_chan.delete_rename ,...
            'String','Delete selected chan','callback',@delete_chan,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        EStduio_eegtab_EEG_edit_chan.rename_chan = uicontrol('Style','pushbutton','Parent',EStduio_eegtab_EEG_edit_chan.delete_rename ,...
            'String','Rename selected chan','callback',@rename_chan,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        
        
        erplabInterpolateElectrodes=  erpworkingmemory('pop_erplabInterpolateElectrodes');
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
        
        %%Interpolate channels
        EStduio_eegtab_EEG_edit_chan.interpolate_chan_title = uiextras.HBox('Parent', EStduio_eegtab_EEG_edit_chan.DataSelBox,'BackgroundColor',ColorB_def);
        
        EStduio_eegtab_EEG_edit_chan.interpolate_chan = uicontrol('Style','pushbutton','Parent',EStduio_eegtab_EEG_edit_chan.interpolate_chan_title,...
            'String','Interpolate selected chan','callback',@interpolate_chan,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        uiextras.Empty('Parent', EStduio_eegtab_EEG_edit_chan.interpolate_chan_title);
        set( EStduio_eegtab_EEG_edit_chan.interpolate_chan_title,'Sizes',[-1 100]);
        
        EStduio_eegtab_EEG_edit_chan.interpolate_chan_title_add1 = uiextras.HBox('Parent', EStduio_eegtab_EEG_edit_chan.DataSelBox,'BackgroundColor',ColorB_def);
        
        EStduio_eegtab_EEG_edit_chan.interpolate_inverse = uicontrol('Style','radiobutton','Parent',EStduio_eegtab_EEG_edit_chan.interpolate_chan_title_add1 ,...
            'String','Inverse Distance','callback',@interpolate_inverse,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',ColorB_def,'Value',~InterpValue); % 2F
        
        EStduio_eegtab_EEG_edit_chan.ignore_chan = uicontrol('Style','checkbox','Parent',EStduio_eegtab_EEG_edit_chan.interpolate_chan_title_add1 ,...
            'String','Ignore those chan','callback',@ignore_chan,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',ColorB_def); % 2F
        if isempty(ignoreChannels)
            EStduio_eegtab_EEG_edit_chan.ignore_chan.Value = 0;
        else
            EStduio_eegtab_EEG_edit_chan.ignore_chan.Value = 1;
        end
        set(EStduio_eegtab_EEG_edit_chan.interpolate_chan_title_add1,'Sizes',[120 -1]);
        
        EStduio_eegtab_EEG_edit_chan.interpolate_chan_title_add2 = uiextras.HBox('Parent', EStduio_eegtab_EEG_edit_chan.DataSelBox,'BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_edit_chan.interpolate_spherical = uicontrol('Style','radiobutton','Parent',EStduio_eegtab_EEG_edit_chan.interpolate_chan_title_add2 ,...
            'String','Spherical ','callback',@interpolate_spherical,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',ColorB_def,'Value',InterpValue); % 2F
        
        EStduio_eegtab_EEG_edit_chan.ignore_chan_edit = uicontrol('Style','edit','Parent',EStduio_eegtab_EEG_edit_chan.interpolate_chan_title_add2 ,...
            'String',' ','callback',@ignore_chan_edit,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        try
            EStduio_eegtab_EEG_edit_chan.ignore_chan_edit.String = num2str(ignoreChannels);
        catch
            EStduio_eegtab_EEG_edit_chan.ignore_chan_edit.String = '';
        end
        EStduio_eegtab_EEG_edit_chan.ignore_chan_browse = uicontrol('Style','pushbutton','Parent',EStduio_eegtab_EEG_edit_chan.interpolate_chan_title_add2 ,...
            'String','Browse','callback',@ignore_chan_browse,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        set(EStduio_eegtab_EEG_edit_chan.interpolate_chan_title_add2,'Sizes',[120 -1 60]);
        
        %%interpoate marked epochs
        EStduio_eegtab_EEG_edit_chan.interpolate_epoch_title = uiextras.HBox('Parent', EStduio_eegtab_EEG_edit_chan.DataSelBox,'BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_edit_chan.interpolate_epoch = uicontrol('Style','pushbutton','Parent',EStduio_eegtab_EEG_edit_chan.interpolate_epoch_title,...
            'String','Interpolate marked epochs','callback',@interpolate_epoch,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        
        %%Add/edit chan locations
        %         EStduio_eegtab_EEG_edit_chan.edit_chanlocs_title = uiextras.HBox('Parent', EStduio_eegtab_EEG_edit_chan.DataSelBox,'BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_edit_chan.edit_chanlocs = uicontrol('Style','pushbutton','Parent',EStduio_eegtab_EEG_edit_chan.interpolate_epoch_title,...
            'String','Add/edit chanlocs','callback',@edit_chanlocs,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        set(EStduio_eegtab_EEG_edit_chan.interpolate_epoch_title,'Sizes',[160 -1]);
        
        set(EStduio_eegtab_EEG_edit_chan.DataSelBox,'sizes',[30 30 30 30 25 25 30])
        estudioworkingmemory('EEGTab_editchan',0);
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
        if ~isempty(messgStr) && eegpanelIndex~=7
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        EStudio_eeg_box_edit_chan.TitleColor= [0.5137    0.7569    0.9176];
        estudioworkingmemory('EEGTab_editchan',1);
        EStduio_eegtab_EEG_edit_chan.mode_modify.Value =1;
        EStduio_eegtab_EEG_edit_chan.mode_create.Value = 0;
    end


%%---------------------Create new dataset----------------------------------
    function mode_create(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=7
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        EStudio_eeg_box_edit_chan.TitleColor= [0.5137    0.7569    0.9176];
        estudioworkingmemory('EEGTab_editchan',1);
        EStduio_eegtab_EEG_edit_chan.mode_modify.Value =0;
        EStduio_eegtab_EEG_edit_chan.mode_create.Value = 1;
    end



%%---------------------Delete selected chan--------------------------------
    function delete_chan(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=7
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        EStudio_eeg_box_edit_chan.TitleColor= [0.0500    0.2500    0.5000];
        estudioworkingmemory('EEGTab_editchan',0);
        
        erpworkingmemory('f_EEG_proces_messg','Edit Channels >  Delete selected chan');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        
        ChanArray =  estudioworkingmemory('EEG_ChanArray');
        if isempty(ChanArray)
            erpworkingmemory('f_EEG_proces_messg','Edit Channels >  Delete selected chan > No chan was selected');
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            return;
        end
        CreateeegFlag = EStduio_eegtab_EEG_edit_chan.mode_create.Value; %%create new eeg dataset
        
        try
            for Numofeeg = 1:numel(EEGArray)
                EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
                
                %%check the selected chans
                if min(ChanArray(:)) > EEG.nbchan || max(ChanArray(:)) > EEG.nbchan
                    Erromesg = ['Edit Channels >  Delete selected chan > Selected channel should be between 1 and ',32, num2str(EEG.nbchan)];
                    erpworkingmemory('f_EEG_proces_messg',Erromesg);
                    observe_EEGDAT.eeg_panel_message =4;
                    fprintf( ['\n\n',repmat('-',1,100) '\n']);
                    return;
                end
                
                if numel(ChanArray) == EEG.nbchan
                    Erromesg = ['Edit Channels >  Delete selected chan > We strongly recommend you donot need to remove all channels'];
                    erpworkingmemory('f_EEG_proces_messg',Erromesg);
                    observe_EEGDAT.eeg_panel_message =4;
                    fprintf( ['\n',repmat('-',1,100) '\n']);
                    return;
                end
                
                [eloc, chanlabels, theta, radius, indices] = readlocs( EEG.chanlocs );
                
                [EEG, LASTCOM] = pop_select( EEG, 'rmchannel',{chanlabels{ChanArray}});
                fprintf([LASTCOM,'\n']);
                EEG = eegh(LASTCOM, EEG);
                if CreateeegFlag==0
                    observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = EEG;
                else
                    Answer = f_EEG_save_single_file(char(strcat(EEG.setname,'_delchan')),EEG.filename,EEGArray(Numofeeg));
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
                        [observe_EEGDAT.ALLEEG EEG CURRENTSET] = pop_newset(observe_EEGDAT.ALLEEG, EEG, length(observe_EEGDAT.ALLEEG), 'gui', 'off');
                    end
                end
                fprintf( [repmat('-',1,100) '\n']);
            end
            if CreateeegFlag==1
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
            end
            observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_panel_message =2;
        catch
            observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_panel_message =3;%%There is erros in processing procedure
            return;
        end
        
    end


%%-----------------------Rename selected chan------------------------------
    function rename_chan(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=7
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        EStudio_eeg_box_edit_chan.TitleColor= [0.0500    0.2500    0.5000];
        estudioworkingmemory('EEGTab_editchan',0);
        
        erpworkingmemory('f_EEG_proces_messg','Edit Channels >  Rename selected chan');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        ChanArray =  estudioworkingmemory('EEG_ChanArray');
        if isempty(ChanArray)
            ChanArray = [1:observe_EEGDAT.EEG.nbchan];
        end
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        
        CreateeegFlag = EStduio_eegtab_EEG_edit_chan.mode_create.Value; %%create new eeg dataset
        try
            for Numofeeg = 1:numel(EEGArray)
                EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['*Rename selected chan*',32,32,32,32,datestr(datetime('now')),'\n']);
                fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
                
                %%check the selected chans
                if min(ChanArray(:)) > EEG.nbchan || max(ChanArray(:)) > EEG.nbchan
                    fprintf( ['Edit Channels >  Rename selected chan: Some of chan indexes exceed',32,num2str(EEG.nbchan),32,'we therefore select all channels.\n']);
                end
                try
                    [eloc, Chanlabelsold, theta, radius, indices] = readlocs( EEG.chanlocs);
                    Chanlabelsold = Chanlabelsold(ChanArray);
                catch
                    disp('Please EEG.chanlocs');
                    fprintf( [repmat('-',1,100) '\n']);
                    return;
                end
                CURRENTSET = EEGArray(Numofeeg);
                def =  erpworkingmemory('pop_rename2chan');
                if isempty(def)
                    def = Chanlabelsold;
                end
                
                titleName= ['Dataset',32,num2str(CURRENTSET),': ERPLAB Change Channel Name'];
                Chanlabelsnew= f_change_chan_name_GUI(Chanlabelsold,def,titleName);
                
                if isempty(Chanlabelsnew)
                    disp('User selected Cancel');
                    fprintf( [repmat('-',1,100) '\n']);
                    return
                end
                erpworkingmemory('pop_rename2chan',Chanlabelsnew);
                
                [EEG, LASTCOM] = pop_rename2chan(observe_EEGDAT.ALLEEG,CURRENTSET,'ChanArray',ChanArray,'Chanlabels',Chanlabelsnew,'History', 'implicit');
                if isempty(LASTCOM)
                    disp('Please check the inputs');
                    fprintf( [repmat('-',1,100) '\n']);
                    return
                end
                fprintf([LASTCOM,'\n']);
                EEG = eegh(LASTCOM, EEG);
                if CreateeegFlag==0
                    observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = EEG;
                else
                    Answer = f_EEG_save_single_file(char(strcat(EEG.setname,'_rnchan')),EEG.filename,EEGArray(Numofeeg));
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
                        [observe_EEGDAT.ALLEEG EEG CURRENTSET] = pop_newset(observe_EEGDAT.ALLEEG, EEG, length(observe_EEGDAT.ALLEEG), 'gui', 'off');
                    end
                end
                fprintf( [repmat('-',1,100) '\n']);
            end
            if CreateeegFlag==1
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
            end
            observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_panel_message =2;
        catch
            observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_panel_message =3;%%There is erros in processing procedure
            return;
        end
    end


%%------------------Interpolate channel------------------------------------
    function interpolate_chan(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=7
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        EStudio_eeg_box_edit_chan.TitleColor= [0.0500    0.2500    0.5000];
        estudioworkingmemory('EEGTab_editchan',0);
        
        erpworkingmemory('f_EEG_proces_messg','Edit Channels >  Interpolate selected chan');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        ChanArray =  estudioworkingmemory('EEG_ChanArray');
        if isempty(ChanArray)
            ChanArray = [1:observe_EEGDAT.EEG.nbchan];
        end
        
        ChanArrayig =  str2num(EStduio_eegtab_EEG_edit_chan.ignore_chan_edit.String);
        if ~isempty(ChanArrayig)
            overlap_elec = intersect(ChanArray, ChanArrayig);
            if ~isempty(overlap_elec)
                ErroMesg = ['Edit Channels >  Interpolate selected chan: There is overlap in the replace electrodes and the ignore electrodes'];
                erpworkingmemory('f_EEG_proces_messg',ErroMesg);
                observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
                EStduio_eegtab_EEG_edit_chan.ignore_chan_edit.String = '';
                return;
            end
            
            if isempty(ChanArrayig) ||  min(ChanArrayig(:))<=0
                erpworkingmemory('f_EEG_proces_messg','Edit Channels >  Interpolate selected chan: Index(es) for ignored channels should be positive values');
                observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
                EStduio_eegtab_EEG_edit_chan.ignore_chan_edit.String = '';
                return;
            end
            
            if min(ChanArrayig(:)) > observe_EEGDAT.EEG.nbchan ||  max(ChanArrayig(:)) > observe_EEGDAT.EEG.nbchan
                erpworkingmemory('f_EEG_proces_messg','Edit Channels >  Interpolate selected chan: Any of Index(es) for ignored channels should be positive values');
                observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
                EStduio_eegtab_EEG_edit_chan.ignore_chan_edit.String = '';
                return;
            end
        end
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        if EStduio_eegtab_EEG_edit_chan.interpolate_spherical.Value==1
            interpolationMethod = 'spherical';
        else
            interpolationMethod =  'spacetime';
        end
        
        erpworkingmemory('pop_erplabInterpolateElectrodes', ...
            {ChanArray,    ...
            ChanArrayig,      ...
            interpolationMethod, ...
            0           });
        
        
        CreateeegFlag = EStduio_eegtab_EEG_edit_chan.mode_create.Value; %%create new eeg dataset
        try
            for Numofeeg = 1:numel(EEGArray)
                EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['*Interpolate selected chan*',32,32,32,32,datestr(datetime('now')),'\n']);
                fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
                
                %%check the selected chans
                if min(ChanArray(:)) > EEG.nbchan || max(ChanArray(:)) > EEG.nbchan
                    Erromesg = ['Edit Channels >  Interpolate selected chan: Selected channel should be between 1 and ',32, num2str(EEG.nbchan)];
                    erpworkingmemory('f_EEG_proces_messg',Erromesg);
                    observe_EEGDAT.eeg_panel_message =4;
                    fprintf( ['\n\n',repmat('-',1,100) '\n']);
                    return;
                end
                
                if numel(ChanArray) == EEG.nbchan
                    Erromesg = ['Edit Channels >  Interpolate selected chan: We strongly recommend you donot need to interpolate all channels'];
                    erpworkingmemory('f_EEG_proces_messg',Erromesg);
                    observe_EEGDAT.eeg_panel_message =4;
                    fprintf( ['\n\n',repmat('-',1,100) '\n']);
                    return;
                end
                
                [EEG,LASTCOM] = pop_erplabInterpolateElectrodes( EEG , 'displayEEG',  0, 'ignoreChannels', ChanArrayig,...
                    'interpolationMethod', interpolationMethod, 'replaceChannels',ChanArray,'history', 'implicit');
                fprintf([LASTCOM,'\n']);
                EEG = eegh(LASTCOM, EEG);
                if CreateeegFlag==0
                    observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = EEG;
                else
                    Answer = f_EEG_save_single_file(char(strcat(EEG.setname,'_interp')),EEG.filename,EEGArray(Numofeeg));
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
                        [observe_EEGDAT.ALLEEG EEG CURRENTSET] = pop_newset(observe_EEGDAT.ALLEEG, EEG, length(observe_EEGDAT.ALLEEG), 'gui', 'off');
                    end
                end
                fprintf( [repmat('-',1,100) '\n']);
            end
            if CreateeegFlag==1
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
            end
            observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_panel_message =2;
        catch
            observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_panel_message =3;%%There is erros in processing procedure
            return;
        end
        
    end


%%-----------------Interpolate channel method:inverse----------------------
    function interpolate_inverse(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=7
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        EStudio_eeg_box_edit_chan.TitleColor= [0.5137    0.7569    0.9176];
        estudioworkingmemory('EEGTab_editchan',1);
        EStduio_eegtab_EEG_edit_chan.interpolate_inverse.Value= 1;
        EStduio_eegtab_EEG_edit_chan.interpolate_spherical.Value=0;
    end


%%------------------ignore chan when interpolate chan----------------------
    function ignore_chan(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        ignoreValue = Source.Value;
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=7
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        EStudio_eeg_box_edit_chan.TitleColor= [0.5137    0.7569    0.9176];
        estudioworkingmemory('EEGTab_editchan',1);
        if ignoreValue==1
            EStduio_eegtab_EEG_edit_chan.ignore_chan_edit.Enable='on';
            EStduio_eegtab_EEG_edit_chan.ignore_chan_browse.Enable='on';
        else
            EStduio_eegtab_EEG_edit_chan.ignore_chan_edit.Enable='off';
            EStduio_eegtab_EEG_edit_chan.ignore_chan_browse.Enable='off';
        end
    end


%%-------------------methods for interpolate chan--------------------------
    function interpolate_spherical(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=7
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        EStudio_eeg_box_edit_chan.TitleColor= [0.5137    0.7569    0.9176];
        estudioworkingmemory('EEGTab_editchan',1);
        EStduio_eegtab_EEG_edit_chan.interpolate_inverse.Value= 0;
        EStduio_eegtab_EEG_edit_chan.interpolate_spherical.Value=1;
    end

%%-------------------edit ignore chan--------------------------------------
    function ignore_chan_edit(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=7
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        EStudio_eeg_box_edit_chan.TitleColor= [0.5137    0.7569    0.9176];
        estudioworkingmemory('EEGTab_editchan',1);
        
        ChanArray =  estudioworkingmemory('EEG_ChanArray');
        if isempty(ChanArray)
            ChanArray = [1:observe_EEGDAT.EEG.nbchan];
        end
        ChanArrayNew = str2num(Source.String);
        if isempty(ChanArrayNew) ||  min(ChanArrayNew(:))<=0
            erpworkingmemory('f_EEG_proces_messg','Edit Channels: Index(es) for ignored channels should be positive values');
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String = '';
            return;
        end
        
        if min(ChanArrayNew(:)) > observe_EEGDAT.EEG.nbchan ||  max(ChanArrayNew(:)) > observe_EEGDAT.EEG.nbchan
            erpworkingmemory('f_EEG_proces_messg','Edit Channels: Any of Index(es) for ignored channels should be positive values');
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String = '';
            return;
        end
        overlap_elec = intersect(ChanArray, ChanArrayNew);
        if ~isempty(overlap_elec)
            ErroMesg = ['Edit Channels: There is overlap in the replace electrodes and the ignore electrodes'];
            erpworkingmemory('f_EEG_proces_messg',ErroMesg);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String = '';
            return;
        end
        
    end

%%---------------------browse chan for ignore chan-------------------------
    function ignore_chan_browse(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=7
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        EStudio_eeg_box_edit_chan.TitleColor= [0.5137    0.7569    0.9176];
        estudioworkingmemory('EEGTab_editchan',1);
        
        ChanArray =  estudioworkingmemory('EEG_ChanArray');
        if isempty(ChanArray)
            ChanArray = [1:observe_EEGDAT.EEG.nbchan];
        end
        
        EEG = observe_EEGDAT.EEG;
        
        for Numofchan = 1:EEG.nbchan
            try
                listb{Numofchan}= strcat(num2str(Numofchan),'.',EEG.chanlocs(Numofchan).labels);
            catch
                listb{Numofchan}= strcat('Chan:',32,num2str(Numofchan));
            end
        end
        chanIgnore = str2num(EStduio_eegtab_EEG_edit_chan.ignore_chan_edit.String);
        if isempty(chanIgnore)
            indxlistb = EEG.nbchan;
        else
            if min(chanIgnore(:)) >0  && max(chanIgnore(:)) <= EEG.nbchan
                indxlistb = chanIgnore;
            else
                indxlistb = EEG.nbchan;
            end
        end
        titlename = 'Select Ignored Channel(s):';
        
        chan_label_select = browsechanbinGUI(listb, indxlistb, titlename);
        if ~isempty(chan_label_select)
            EStduio_eegtab_EEG_edit_chan.ignore_chan_edit.String  = num2str(chan_label_select);
        else
            beep;
            disp('User selected Cancel');
            return
        end
        
        ChanArrayNew =  str2num(EStduio_eegtab_EEG_edit_chan.ignore_chan_edit.String);
        overlap_elec = intersect(ChanArray, ChanArrayNew);
        if ~isempty(overlap_elec)
            ErroMesg = ['Edit Channels > There is overlap in the replace electrodes and the ignore electrodes'];
            erpworkingmemory('f_EEG_proces_messg',ErroMesg);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            EStduio_eegtab_EEG_edit_chan.ignore_chan_edit.String = '';
            return;
        end
    end


%%------------------Inerpolate the marked epochs---------------------------
    function interpolate_epoch(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=7
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        EStudio_eeg_box_edit_chan.TitleColor= [0.0500    0.2500    0.5000];
        estudioworkingmemory('EEGTab_editchan',0);
        
        erpworkingmemory('f_EEG_proces_messg','Edit Channels >  Interpolate marked epochs');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEG = observe_EEGDAT.EEG;
        ChanArray =  estudioworkingmemory('EEG_ChanArray');
        if isempty(ChanArray)
            ChanArray = [1:observe_EEGDAT.EEG.nbchan];
        end
        
        if numel(ChanArray)~=1 &&  numel(ChanArray)~= observe_EEGDAT.EEG.nbchan
            erpworkingmemory('f_EEG_proces_messg','Edit Channels >  Interpolate marked epochs: Select one or all channels');
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            return;
        end
        if observe_EEGDAT.EEG.trials==1
            erpworkingmemory('f_EEG_proces_messg','Edit Channels >  Interpolate marked epochs: Only works on epoched EEG');
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            return;
        end
        
        
        CreateeegFlag = EStduio_eegtab_EEG_edit_chan.mode_create.Value; %%create new eeg dataset
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        
        %%loop for the selected EEGsets
        try
            for Numofeeg = 1:numel(EEGArray)
                EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['*Interpolate marked epochs*',32,32,32,32,datestr(datetime('now')),'\n']);
                fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
                
                dlg_title = {['Dataset',32,num2str(EEGArray(Numofeeg)),32,': Interpolate Marked Epochs']};
                %defaults
                defx = {0, 'spherical',[],[],[],0,10};
                def = erpworkingmemory('pop_artinterp');
                
                if isempty(def)
                    def = defx;
                else
                    def{3} = def{3}(ismember_bc2(def{3},1:EEG(1).nbchan));
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
                
                if isempty(active_flags)
                    erpworkingmemory('f_EEG_proces_messg','Edit Channels >  Interpolate marked epochs:None of epochs was marked');
                    observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
                    return;
                end
                
                if ChanArray==1
                    def{3} = ChanArray;
                end
                if numel(ChanArray)== numel(EEG.nbchan)
                    def{6} = 1;
                end
                %
                % Call GUI
                %
                answer = artifactinterpGUI(dlg_title, def, defx, chanlabels, active_flags);
                
                if isempty(answer)
                    disp('User selected Cancel')
                    return
                end
                replaceFlag =  answer{1};
                interpolationMethod      =  answer{2};
                replaceChannelInd     =  answer{3};
                replaceChannelLabel     =  answer{4};
                ignoreChannels  =  unique_bc2(answer{5}); % avoids repeted channels
                many_electrodes = answer{6};
                threshold_perc = answer{7};
                
                viewer = 0; % no viewer
                viewstr = 'off';
                
                if ~isempty(find(replaceFlag<1 | replaceFlag>16, 1))
                    msgboxText  ='Edit Channels >  Interpolate marked epochs: flag cannot be greater than 16 nor lesser than 1';
                    erpworkingmemory('f_EEG_proces_messg',msgboxText);
                    observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
                    return;
                end
                erpworkingmemory('pop_artinterp', {answer{1} answer{2} answer{3} answer{4} answer{5} ...
                    answer{6}, answer{7}});
                
                
                if  replaceChannelInd > EEG.nbchan && many_electrodes==0
                    replaceChannelInd = [];
                    many_electrodes = 1;
                    fprintf(['\n **ChanToInterp exceeds the number of channels, we therefore change interpolate any channel.** \n']);
                end
                
                %%Run ICA
                [EEG, LASTCOM] = pop_artinterp(EEG, 'FlagToUse', replaceFlag, 'InterpMethod', interpolationMethod, ...
                    'ChanToInterp', replaceChannelInd, 'ChansToIgnore', ignoreChannels, ...
                    'InterpAnyChan', many_electrodes, 'Threshold',threshold_perc,...
                    'Review', viewstr, 'History', 'implicit');
                
                if isempty(LASTCOM)
                    erpworkingmemory('f_EEG_proces_messg','Edit Channels >  Interpolate marked epochs: Please check you data or you selected cancel');
                    observe_EEGDAT.eeg_panel_message =4;
                    return;
                end
                EEG = eegh(LASTCOM, EEG);
                fprintf(['\n',LASTCOM,'\n']);
                if CreateeegFlag==0
                    observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = EEG;
                else
                    Answer = f_EEG_save_single_file(char(strcat(EEG.setname,'_interp')),EEG.filename,EEGArray(Numofeeg));
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
                        [observe_EEGDAT.ALLEEG EEG CURRENTSET] = pop_newset(observe_EEGDAT.ALLEEG, EEG, length(observe_EEGDAT.ALLEEG), 'gui', 'off');
                    end
                end
                fprintf( ['\n',repmat('-',1,100) '\n']);
            end
            
            if CreateeegFlag==1
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
            end
            observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_panel_message =2;
        catch
            observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_panel_message =3;%%There is errros in processing procedure
            fprintf( ['\n',repmat('-',1,100) '\n']);
            return;
        end
    end


%%------------------edit channel locations---------------------------------
    function edit_chanlocs(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=7
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        EStudio_eeg_box_edit_chan.TitleColor= [0.0500    0.2500    0.5000];
        estudioworkingmemory('EEGTab_editchan',0);
        
        erpworkingmemory('f_EEG_proces_messg','Edit Channels >  Add/edit channel locations');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        CreateeegFlag = EStduio_eegtab_EEG_edit_chan.mode_create.Value; %%create new eeg dataset
        ChanArray =  estudioworkingmemory('EEG_ChanArray');
        
        %%loop for the selected EEGsets
        try
            for Numofeeg = 1:numel(EEGArray)
                EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['*Edit Selected  channel locations*',32,32,32,32,datestr(datetime('now')),'\n']);
                fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
                
                %%edit channel locations
                if isempty(ChanArray) || min(ChanArray(:)) > EEG.nbchan || max(ChanArray(:)) > EEG.nbchan
                    ChanArray = [1:EEG.nbchan];
                end
                
                
                titleName= ['Dataset',32,num2str(EEGArray(Numofeeg)),': Add/Edit Channel locations'];
                EEGInput = EEG;
                EEGInput.chanlocs = EEG.chanlocs(ChanArray);
                
                app = feval('f_editchan_gui',EEGInput,titleName);
                waitfor(app,'Finishbutton',1);
                try
                    EEGoutput = app.output; %NO you don't want to output EEG with edited channel locations, you want to output the parameters to run decoding
                    app.delete; %delete app from view
                    pause(0.5); %wait for app to leave
                catch
                    disp('User selected Cancel');
                    fprintf( ['\n',repmat('-',1,100) '\n']);
                    break;
                end
                
                if isempty(EEGoutput)
                    disp('User selected Cancel');
                    fprintf( ['\n',repmat('-',1,100) '\n']);
                    break;
                end
                Chanlocs = EEGoutput.chanlocs;
                
                [EEG, LASTCOM] = pop_editdatachanlocs(observe_EEGDAT.ALLEEG,EEGArray(Numofeeg),...
                    'ChanArray',ChanArray,'Chanlocs',Chanlocs,'History', 'implicit');
                
                if isempty(LASTCOM)
                    erpworkingmemory('f_EEG_proces_messg','Edit Channels >  Interpolate marked epochs: Please check you data or you selected cancel');
                    observe_EEGDAT.eeg_panel_message =4;
                    return;
                end
                EEG = eegh(LASTCOM, EEG);
                fprintf(['\n',LASTCOM,'\n']);
                
                
                if CreateeegFlag==0
                    observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = EEG;
                else
                    Answer = f_EEG_save_single_file(char(strcat(EEG.setname,'_editchan')),EEG.filename,EEGArray(Numofeeg));
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
                        [observe_EEGDAT.ALLEEG EEG CURRENTSET] = pop_newset(observe_EEGDAT.ALLEEG, EEG, length(observe_EEGDAT.ALLEEG), 'gui', 'off');
                    end
                end
                fprintf( ['\n',repmat('-',1,100) '\n']);
            end
            
            if CreateeegFlag==1
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
            end
            observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_panel_message =2;
        catch
            observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_panel_message =3;%%There is errros in processing procedure
            fprintf( ['\n',repmat('-',1,100) '\n']);
            return;
        end
    end


%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        
        if  isempty(observe_EEGDAT.EEG)
            EStduio_eegtab_EEG_edit_chan.mode_modify.Enable ='off';
            EStduio_eegtab_EEG_edit_chan.mode_create.Enable = 'off';
            EStduio_eegtab_EEG_edit_chan.delete_chan.Enable='off';
            EStduio_eegtab_EEG_edit_chan.rename_chan.Enable='off';
            EStduio_eegtab_EEG_edit_chan.interpolate_chan.Enable='off';
            EStduio_eegtab_EEG_edit_chan.interpolate_inverse.Enable= 'off';
            EStduio_eegtab_EEG_edit_chan.ignore_chan.Enable='off';
            EStduio_eegtab_EEG_edit_chan.interpolate_spherical.Enable='off';
            EStduio_eegtab_EEG_edit_chan.ignore_chan_edit.Enable='off';
            EStduio_eegtab_EEG_edit_chan.ignore_chan_browse.Enable='off';
            EStduio_eegtab_EEG_edit_chan.interpolate_epoch.Enable='off';
            EStduio_eegtab_EEG_edit_chan.edit_chanlocs.Enable='off';
            return;
        end
        
        if observe_EEGDAT.count_current_eeg ~=11
            return;
        end
        EStduio_eegtab_EEG_edit_chan.mode_modify.Enable ='on';
        EStduio_eegtab_EEG_edit_chan.mode_create.Enable = 'on';
        EStduio_eegtab_EEG_edit_chan.delete_chan.Enable='on';
        EStduio_eegtab_EEG_edit_chan.rename_chan.Enable='on';
        EStduio_eegtab_EEG_edit_chan.interpolate_chan.Enable='on';
        EStduio_eegtab_EEG_edit_chan.interpolate_inverse.Enable= 'on';
        EStduio_eegtab_EEG_edit_chan.ignore_chan.Enable='on';
        EStduio_eegtab_EEG_edit_chan.interpolate_spherical.Enable='on';
        EStduio_eegtab_EEG_edit_chan.ignore_chan_edit.Enable='on';
        EStduio_eegtab_EEG_edit_chan.ignore_chan_browse.Enable='on';
        EStduio_eegtab_EEG_edit_chan.interpolate_epoch.Enable='on';
        EStduio_eegtab_EEG_edit_chan.edit_chanlocs.Enable='on';
        if EStduio_eegtab_EEG_edit_chan.ignore_chan.Value==0
            EStduio_eegtab_EEG_edit_chan.ignore_chan_edit.Enable='off';
            EStduio_eegtab_EEG_edit_chan.ignore_chan_browse.Enable='off';
        end
        
        if observe_EEGDAT.EEG.trials ==1
            EStduio_eegtab_EEG_edit_chan.interpolate_epoch.Enable='off';
        else
            EStduio_eegtab_EEG_edit_chan.interpolate_epoch.Enable='on';
        end
        observe_EEGDAT.count_current_eeg=12;
    end

%%-------------------------------------------------------------------------
%%Automatically saving the changed parameters for the current panel if the
%%user change parameters for the other panels.
%%-------------------------------------------------------------------------
    function eeg_two_panels_change(~,~)
        if observe_EEGDAT.eeg_two_panels==0
            return;
        end
        ChangeFlag =  estudioworkingmemory('EEGTab_editchan');
        if ChangeFlag~=1
            return;
        end
        estudioworkingmemory('EEGTab_editchan',0);
        EStudio_eeg_box_edit_chan.TitleColor= [0.0500    0.2500    0.5000];
    end

end