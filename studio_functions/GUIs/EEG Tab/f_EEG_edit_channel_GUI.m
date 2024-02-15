%%This function is to Edit Channels

% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Sep.2023


function varargout = f_EEG_edit_channel_GUI(varargin)

global observe_EEGDAT;
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'Reset_eeg_panel_change',@Reset_eeg_panel_change);
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
            'String','Modify existing dataset','callback',@mode_modify,'Value',1,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',ColorB_def); % 2F
        %         EStduio_eegtab_EEG_edit_chan.mode_modify.String =  '<html>Modify existing dataset<br />(recursive updating)</html>';
        set(EStduio_eegtab_EEG_edit_chan.mode_1,'Sizes',[55 -1]);
        %%--------------For create a new ERPset----------------------------
        EStduio_eegtab_EEG_edit_chan.mode_2 = uiextras.HBox('Parent', EStduio_eegtab_EEG_edit_chan.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  EStduio_eegtab_EEG_edit_chan.mode_2,'BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_edit_chan.mode_create = uicontrol('Style','radiobutton','Parent',EStduio_eegtab_EEG_edit_chan.mode_2 ,...
            'String','Create new dataset','callback',@mode_create,'Value',0,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',ColorB_def); % 2F
        %         EStduio_eegtab_EEG_edit_chan.mode_create.String =  '<html>Create new dataset<br />(independent transformations)</html>';
        set(EStduio_eegtab_EEG_edit_chan.mode_2,'Sizes',[55 -1]);
        
        
        %%Select channels that will be deleted and renamed
        EStduio_eegtab_EEG_edit_chan.select_chan_title = uiextras.HBox('Parent', EStduio_eegtab_EEG_edit_chan.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',EStduio_eegtab_EEG_edit_chan.select_chan_title,...
            'String','Chan:','FontSize',FontSize_defualt,'Enable','on','BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_edit_chan.select_edit_chan = uicontrol('Style','edit','Parent',EStduio_eegtab_EEG_edit_chan.select_chan_title,...
            'String',' ','callback',@select_edit_chan,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        EStduio_eegtab_EEG_edit_chan.browse_chan = uicontrol('Style','pushbutton','Parent',EStduio_eegtab_EEG_edit_chan.select_chan_title,...
            'String','Browse','callback',@browse_chan,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        set(EStduio_eegtab_EEG_edit_chan.select_chan_title,'sizes',[40 -1 60])
        
        
        %%Delete selected channels && Rename selected channels
        EStduio_eegtab_EEG_edit_chan.delete_rename = uiextras.HBox('Parent', EStduio_eegtab_EEG_edit_chan.DataSelBox,'BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_edit_chan.delete_chan = uicontrol('Style','pushbutton','Parent',EStduio_eegtab_EEG_edit_chan.delete_rename ,...
            'String','Delete chan','callback',@delete_chan,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        EStduio_eegtab_EEG_edit_chan.rename_chan = uicontrol('Style','pushbutton','Parent',EStduio_eegtab_EEG_edit_chan.delete_rename ,...
            'String','Rename chan','callback',@rename_chan,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        
        %%Add/edit chan locations
        %         EStduio_eegtab_EEG_edit_chan.edit_chanlocs_title = uiextras.HBox('Parent', EStduio_eegtab_EEG_edit_chan.DataSelBox,'BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_edit_chan.edit_chanlocs = uicontrol('Style','pushbutton','Parent',EStduio_eegtab_EEG_edit_chan.delete_rename,...
            'String','Add/edit chanlocs','callback',@edit_chanlocs,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        %         set(EStduio_eegtab_EEG_edit_chan.interpolate_epoch_title,'Sizes',[160 -1]);
        EStduio_eegtab_EEG_edit_chan.edit_chanlocs.String = '<html>    Add or edit   <br />chan locations</html>';
        EStduio_eegtab_EEG_edit_chan.edit_chanlocs.HorizontalAlignment='Center';
        set(EStduio_eegtab_EEG_edit_chan.DataSelBox,'sizes',[30 30 30 40])
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

%%-----------------------input channels------------------------------------
    function select_edit_chan(Source,~)
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
        
        New_chans = str2num(Source.String);
        if isempty(New_chans) || min(New_chans(:))<=0 || max(New_chans(:))<=0
            erpworkingmemory('f_EEG_proces_messg','Edit Channels >  Index(es) of channels should be positive numbers');
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String = '';
            return;
        end
        chanNum = observe_EEGDAT.EEG.nbchan;
        if min(New_chans(:)) > chanNum || max(New_chans(:)) >chanNum
            erpworkingmemory('f_EEG_proces_messg',['Edit Channels >  Index(es) of channels should be smaller than',32,num2str(chanNum)]);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String = '';
            return;
        end
    end

%%-----------------------browse channels-----------------------------------
    function browse_chan(Source,~)
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
        
        
        EEG = observe_EEGDAT.EEG;
        for Numofchan = 1:EEG.nbchan
            try
                listb{Numofchan}= strcat(num2str(Numofchan),'.',EEG.chanlocs(Numofchan).labels);
            catch
                listb{Numofchan}= strcat('Chan:',32,num2str(Numofchan));
            end
        end
        chanIgnore = str2num(EStduio_eegtab_EEG_edit_chan.select_edit_chan.String);
        if isempty(chanIgnore)
            indxlistb = EEG.nbchan;
        else
            if min(chanIgnore(:)) >0  && max(chanIgnore(:)) <= EEG.nbchan
                indxlistb = chanIgnore;
            else
                indxlistb = EEG.nbchan;
            end
        end
        titlename = 'Select Channel(s):';
        
        chan_label_select = browsechanbinGUI(listb, indxlistb, titlename);
        if ~isempty(chan_label_select)
            EStduio_eegtab_EEG_edit_chan.select_edit_chan.String  = vect2colon(chan_label_select);
        else
            beep;
            %disp('User selected Cancel');
            return
        end
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
        
        ChanArray =  str2num(EStduio_eegtab_EEG_edit_chan.select_edit_chan.String);
        if isempty(ChanArray) || min(ChanArray(:))<=0 || max(ChanArray(:))<=0
            erpworkingmemory('f_EEG_proces_messg','Edit Channels >  Delete selected chan > Indexes of chans should be positive numbers');
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            return;
        end
        CreateeegFlag = EStduio_eegtab_EEG_edit_chan.mode_create.Value; %%create new eeg dataset
        
        %         try
        ALLEEG = observe_EEGDAT.ALLEEG;
        if CreateeegFlag==1
            Answer = f_EEG_save_multi_file(ALLEEG,EEGArray,'_delchan');
            if isempty(Answer)
                beep;
                %disp('User selected Cancel');
                return;
            end
            if ~isempty(Answer{1})
                ALLEEG = Answer{1};
                Save_file_label = Answer{2};
            end
        end
        
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG(EEGArray(Numofeeg));
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
                Erromesg = ['Edit Channels >  Delete selected chan > Please clear this EEGset in "EEGsets" panel if you want to delete all channels'];
                erpworkingmemory('f_EEG_proces_messg',Erromesg);
                observe_EEGDAT.eeg_panel_message =4;
                fprintf( ['\n',repmat('-',1,100) '\n']);
                return;
            end
            
            [eloc, chanlabels, theta, radius, indices] = readlocs( EEG.chanlocs );
            
            [EEG, LASTCOM] = pop_select( EEG, 'rmchannel',{chanlabels{ChanArray}});
            fprintf([LASTCOM,'\n']);
            EEG = eegh(LASTCOM, EEG);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            if CreateeegFlag==0
                ALLEEG(EEGArray(Numofeeg)) = EEG;
            else
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
            end
            fprintf( [repmat('-',1,100) '\n']);
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
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
            estudioworkingmemory('EEGArray',Selected_EEG_afd);
            assignin('base','EEG',observe_EEGDAT.EEG);
            assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
            assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        end
        observe_EEGDAT.count_current_eeg=1;
        observe_EEGDAT.eeg_panel_message =2;
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
        ChanArray =  str2num(EStduio_eegtab_EEG_edit_chan.select_edit_chan.String);
        
        if isempty(ChanArray) || min(ChanArray(:))<=0 || max(ChanArray(:))<=0
            erpworkingmemory('f_EEG_proces_messg','Edit Channels >  Delete selected chan > Indexes of chans should be positive numbers');
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            return;
        end
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        
        CreateeegFlag = EStduio_eegtab_EEG_edit_chan.mode_create.Value; %%create new eeg dataset
        %         try
        ALLEEG = observe_EEGDAT.ALLEEG;
        Save_file_label=0;
        if CreateeegFlag==1
            Answer = f_EEG_save_multi_file(ALLEEG,EEGArray,'_rnchan');
            if isempty(Answer)
                beep;
                %disp('User selected Cancel');
                return;
            end
            if ~isempty(Answer{1})
                ALLEEG = Answer{1};
                Save_file_label = Answer{2};
            end
        end
        
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Rename selected chan*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            
            %%check the selected chans
            if min(ChanArray(:)) > EEG.nbchan || max(ChanArray(:)) > EEG.nbchan
                fprintf( ['Edit Channels >  Rename selected chan: Some of chan indexes exceed',32,num2str(EEG.nbchan),32,', we therefore select all channels.\n']);
                ChanArray = [1:EEG.nbchan];
            end
            try
                [eloc, Chanlabelsold, theta, radius, indices] = readlocs( EEG.chanlocs);
                Chanlabelsold = Chanlabelsold(ChanArray);
            catch
                beep
                disp('Please check EEG.chanlocs');
                fprintf( [repmat('-',1,100) '\n']);
                observe_EEGDAT.eeg_panel_message =3;
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
                %disp('User selected Cancel');
                fprintf( [repmat('-',1,100) '\n']);
                observe_EEGDAT.eeg_panel_message =2;
                return
            end
            erpworkingmemory('pop_rename2chan',Chanlabelsnew);
            
            [EEG, LASTCOM] = pop_rename2chan(ALLEEG,CURRENTSET,'ChanArray',ChanArray,'Chanlabels',Chanlabelsnew,'History', 'implicit');
            if isempty(LASTCOM)
                disp('Please check the inputs');
                fprintf( [repmat('-',1,100) '\n']);
                observe_EEGDAT.eeg_panel_message =4;
                return
            end
            if Numofeeg==1
                eegh(LASTCOM);
            end
            
            fprintf([LASTCOM,'\n']);
            EEG = eegh(LASTCOM, EEG);
            if CreateeegFlag==0
                ALLEEG(EEGArray(Numofeeg)) = EEG;
            else
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
                
            end
            fprintf( [repmat('-',1,100) '\n']);
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
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
            estudioworkingmemory('EEGArray',Selected_EEG_afd);
            assignin('base','EEG',observe_EEGDAT.EEG);
            assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
            assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        end
        observe_EEGDAT.count_current_eeg=1;
        observe_EEGDAT.eeg_panel_message =2;
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
        
        erpworkingmemory('f_EEG_proces_messg','Edit Channels >  Add or edit channel locations');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        CreateeegFlag = EStduio_eegtab_EEG_edit_chan.mode_create.Value; %%create new eeg dataset
        %%loop for the selected EEGsets
        Save_file_label=0;
        ALLEEG = observe_EEGDAT.ALLEEG;
        if CreateeegFlag==1
            Answer = f_EEG_save_multi_file(ALLEEG,EEGArray,'_editchan');
            if isempty(Answer)
                beep;
                %disp('User selected Cancel');
                return;
            end
            if ~isempty(Answer{1})
                ALLEEG = Answer{1};
                Save_file_label = Answer{2};
            end
        end
        
        
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Add or edit all  channel locations*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            ChanArray = [1:EEG.nbchan];
            titleName= ['Dataset',32,num2str(EEGArray(Numofeeg)),': Add or edit channel locations'];
            
            app = feval('f_editchan_gui',EEG,titleName);
            waitfor(app,'Finishbutton',1);
            try
                EEGoutput = app.output; %NO you don't want to output EEG with edited channel locations, you want to output the parameters to run decoding
                app.delete; %delete app from view
                pause(0.5); %wait for app to leave
            catch
                %disp('User selected Cancel');
                fprintf( ['\n',repmat('-',1,100) '\n']);
                break;
            end
            
            if isempty(EEGoutput)
                %disp('User selected Cancel');
                fprintf( ['\n',repmat('-',1,100) '\n']);
                break;
            end
            Chanlocs = EEGoutput.chanlocs;
            
            [EEG, LASTCOM] = pop_editdatachanlocs(ALLEEG,EEGArray(Numofeeg),...
                'ChanArray',ChanArray,'Chanlocs',Chanlocs,'History', 'implicit');
            
            if isempty(LASTCOM)
                erpworkingmemory('f_EEG_proces_messg','Edit Channels >  Add or edit channel locations: Please check you data or you selected cancel');
                observe_EEGDAT.eeg_panel_message =4;
                return;
            end
            EEG = eegh(LASTCOM, EEG);
            fprintf(['\n',LASTCOM,'\n']);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            
            if CreateeegFlag==0
                ALLEEG(EEGArray(Numofeeg)) = EEG;
            else
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
            fprintf( ['\n',repmat('-',1,100) '\n']);
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
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
            estudioworkingmemory('EEGArray',Selected_EEG_afd);
            assignin('base','EEG',observe_EEGDAT.EEG);
            assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
            assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        end
        observe_EEGDAT.count_current_eeg=1;
        observe_EEGDAT.eeg_panel_message =2;
    end


%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=6
            return;
        end
        if  isempty(observe_EEGDAT.EEG) || (~isempty(observe_EEGDAT.EEG) && isempty(observe_EEGDAT.EEG.chanlocs))
            EStduio_eegtab_EEG_edit_chan.mode_modify.Enable ='off';
            EStduio_eegtab_EEG_edit_chan.mode_create.Enable = 'off';
            EStduio_eegtab_EEG_edit_chan.delete_chan.Enable='off';
            EStduio_eegtab_EEG_edit_chan.rename_chan.Enable='off';
            EStduio_eegtab_EEG_edit_chan.edit_chanlocs.Enable='off';
            EStduio_eegtab_EEG_edit_chan.select_edit_chan.Enable='off';
            EStduio_eegtab_EEG_edit_chan.browse_chan.Enable='off';
            observe_EEGDAT.count_current_eeg=7;
            return;
        end
        EStduio_eegtab_EEG_edit_chan.mode_modify.Enable ='on';
        EStduio_eegtab_EEG_edit_chan.mode_create.Enable = 'on';
        EStduio_eegtab_EEG_edit_chan.delete_chan.Enable='on';
        EStduio_eegtab_EEG_edit_chan.rename_chan.Enable='on';
        EStduio_eegtab_EEG_edit_chan.edit_chanlocs.Enable='on';
        EStduio_eegtab_EEG_edit_chan.select_edit_chan.Enable='on';
        EStduio_eegtab_EEG_edit_chan.browse_chan.Enable='on';
        observe_EEGDAT.count_current_eeg=7;
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


%%--------------Reset this panel with the default parameters---------------
    function Reset_eeg_panel_change(~,~)
        if observe_EEGDAT.Reset_eeg_paras_panel~=5
            return;
        end
        estudioworkingmemory('EEGTab_editchan',0);
        EStduio_eegtab_EEG_edit_chan.mode_modify.Value =1;
        EStduio_eegtab_EEG_edit_chan.mode_create.Value = 0;
        EStduio_eegtab_EEG_edit_chan.select_edit_chan.String = '';
        observe_EEGDAT.Reset_eeg_paras_panel=6;
    end
end


%%----------------check if the file already exists-------------------------
function checkfileindex = checkfilexists(filenamex)%%Jan 10 2024
checkfileindex=1;
[pathstr, file_name, ext] = fileparts(filenamex);
filenamex = [pathstr, file_name,'.set'];
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

