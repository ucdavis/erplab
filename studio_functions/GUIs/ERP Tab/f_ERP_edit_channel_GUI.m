%%This function is to Edit Channels

% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Jan. 2024


function varargout = f_ERP_edit_channel_GUI(varargin)

global observe_ERPDAT;
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);
addlistener(observe_ERPDAT,'erp_two_panels_change',@erp_two_panels_change);
addlistener(observe_ERPDAT,'Reset_erp_panel_change',@Reset_erp_panel_change);
%---------------------------Initialize parameters------------------------------------

ERP_tab_edit_chan = struct();

%-----------------------------Name the title----------------------------------------------
% global EStudio_erp_box_edit_chan;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    EStudio_erp_box_edit_chan = uiextras.BoxPanel('Parent', fig, 'Title', 'Edit Channels', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    EStudio_erp_box_edit_chan = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Edit Channels', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    EStudio_erp_box_edit_chan = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Edit Channels', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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

drawui_ic_chan_ERP(FonsizeDefault)
varargout{1} = EStudio_erp_box_edit_chan;

    function drawui_ic_chan_ERP(FonsizeDefault)
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
        ERP_tab_edit_chan.DataSelBox = uiextras.VBox('Parent', EStudio_erp_box_edit_chan,'BackgroundColor',ColorB_def);
        
        %%%----------------Mode-----------------------------------
        ERP_tab_edit_chan.mode_1 = uiextras.HBox('Parent', ERP_tab_edit_chan.DataSelBox,'BackgroundColor',ColorB_def);
        ERP_tab_edit_chan.mode_modify_title = uicontrol('Style','text','Parent',ERP_tab_edit_chan.mode_1 ,...
            'String','Mode:','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        ERP_tab_edit_chan.mode_modify = uicontrol('Style','radiobutton','Parent',ERP_tab_edit_chan.mode_1 ,...
            'String','Modify existing dataset','callback',@mode_modify,'Value',1,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',ColorB_def); % 2F
        %         ERP_tab_edit_chan.mode_modify.String =  '<html>Modify existing dataset<br />(recursive updating)</html>';
        set(ERP_tab_edit_chan.mode_1,'Sizes',[55 -1]);
        %%--------------For create a new ERPset----------------------------
        ERP_tab_edit_chan.mode_2 = uiextras.HBox('Parent', ERP_tab_edit_chan.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  ERP_tab_edit_chan.mode_2,'BackgroundColor',ColorB_def);
        ERP_tab_edit_chan.mode_create = uicontrol('Style','radiobutton','Parent',ERP_tab_edit_chan.mode_2 ,...
            'String','Create new dataset','callback',@mode_create,'Value',0,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',ColorB_def); % 2F
        %         ERP_tab_edit_chan.mode_create.String =  '<html>Create new dataset<br />(independent transformations)</html>';
        set(ERP_tab_edit_chan.mode_2,'Sizes',[55 -1]);
        
        
        %%Select channels that will be deleted and renamed
        ERP_tab_edit_chan.select_chan_title = uiextras.HBox('Parent', ERP_tab_edit_chan.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',ERP_tab_edit_chan.select_chan_title,...
            'String','Chan:','FontSize',FontSize_defualt,'Enable','on','BackgroundColor',ColorB_def);
        ERP_tab_edit_chan.select_edit_chan = uicontrol('Style','edit','Parent',ERP_tab_edit_chan.select_chan_title,...
            'String',' ','callback',@select_edit_chan,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        ERP_tab_edit_chan.browse_chan = uicontrol('Style','pushbutton','Parent',ERP_tab_edit_chan.select_chan_title,...
            'String','Browse','callback',@browse_chan,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        set(ERP_tab_edit_chan.select_chan_title,'sizes',[40 -1 60])
        
        
        %%Delete selected channels && Rename selected channels
        ERP_tab_edit_chan.delete_rename = uiextras.HBox('Parent', ERP_tab_edit_chan.DataSelBox,'BackgroundColor',ColorB_def);
        ERP_tab_edit_chan.delete_chan = uicontrol('Style','pushbutton','Parent',ERP_tab_edit_chan.delete_rename ,...
            'String','Delete chan','callback',@delete_chan,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        ERP_tab_edit_chan.rename_chan = uicontrol('Style','pushbutton','Parent',ERP_tab_edit_chan.delete_rename ,...
            'String','Rename chan','callback',@rename_chan,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        
        %%Add/edit chan locations
        ERP_tab_edit_chan.edit_chanlocs = uicontrol('Style','pushbutton','Parent',ERP_tab_edit_chan.delete_rename,...
            'String','Add/edit chanlocs','callback',@edit_chanlocs,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        %         set(ERP_tab_edit_chan.interpolate_epoch_title,'Sizes',[160 -1]);
        ERP_tab_edit_chan.edit_chanlocs.String = '<html>    Add or edit   <br />chan locations</html>';
        ERP_tab_edit_chan.edit_chanlocs.HorizontalAlignment='Center';
        set(ERP_tab_edit_chan.DataSelBox,'sizes',[30 30 30 40])
        estudioworkingmemory('ERPTab_editchan',0);
    end

%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%---------------------Modify Existing dataset-----------------------------
    function mode_modify(Source,~)
        if isempty(observe_ERPDAT.ERP)
            Source.Enable= 'off';
            return;
        end
        [messgStr,ERPpanelIndex] = f_check_erptab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && ERPpanelIndex~=15
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        EStudio_erp_box_edit_chan.TitleColor= [0.5137    0.7569    0.9176];
        estudioworkingmemory('ERPTab_editchan',1);
        ERP_tab_edit_chan.mode_modify.Value =1;
        ERP_tab_edit_chan.mode_create.Value = 0;
    end


%%---------------------Create new dataset----------------------------------
    function mode_create(Source,~)
        if isempty(observe_ERPDAT.ERP)
            Source.Enable= 'off';
            return;
        end
        [messgStr,ERPpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && ERPpanelIndex~=15
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        EStudio_erp_box_edit_chan.TitleColor= [0.5137    0.7569    0.9176];
        estudioworkingmemory('ERPTab_editchan',1);
        ERP_tab_edit_chan.mode_modify.Value =0;
        ERP_tab_edit_chan.mode_create.Value = 1;
    end

%%-----------------------input channels------------------------------------
    function select_edit_chan(Source,~)
        if isempty(observe_ERPDAT.ERP)
            Source.Enable= 'off';
            return;
        end
        [messgStr,ERPpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && ERPpanelIndex~=15
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        EStudio_erp_box_edit_chan.TitleColor= [0.5137    0.7569    0.9176];
        estudioworkingmemory('ERPTab_editchan',1);
        
        New_chans = str2num(Source.String);
        if isempty(New_chans) || min(New_chans(:))<=0 || max(New_chans(:))<=0
            erpworkingmemory('f_ERP_proces_messg','Edit Channels >  Index(es) of channels should be positive numbers');
            observe_ERPDAT.Process_messg =4; %%Marking for the procedure has been started.
            Source.String = '';
            return;
        end
        chanNum = observe_ERPDAT.ERP.nchan;
        if min(New_chans(:)) > chanNum || max(New_chans(:)) >chanNum
            erpworkingmemory('f_ERP_proces_messg',['Edit Channels >  Index(es) of channels should be smaller than',32,num2str(chanNum)]);
            observe_ERPDAT.Process_messg =4; %%Marking for the procedure has been started.
            Source.String = '';
            return;
        end
    end

%%-----------------------browse channels-----------------------------------
    function browse_chan(Source,~)
        if isempty(observe_ERPDAT.ERP)
            Source.Enable= 'off';
            return;
        end
        
        [messgStr,ERPpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && ERPpanelIndex~=15
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        EStudio_erp_box_edit_chan.TitleColor= [0.5137    0.7569    0.9176];
        estudioworkingmemory('ERPTab_editchan',1);
        
        
        ERP = observe_ERPDAT.ERP;
        for Numofchan = 1:ERP.nchan
            try
                listb{Numofchan}= strcat(num2str(Numofchan),'.',ERP.chanlocs(Numofchan).labels);
            catch
                listb{Numofchan}= strcat('Chan:',32,num2str(Numofchan));
            end
        end
        chanIgnore = str2num(ERP_tab_edit_chan.select_edit_chan.String);
        if isempty(chanIgnore)
            indxlistb = ERP.nchan;
        else
            if min(chanIgnore(:)) >0  && max(chanIgnore(:)) <= ERP.nchan
                indxlistb = chanIgnore;
            else
                indxlistb = ERP.nchan;
            end
        end
        titlename = 'Select Channel(s):';
        chan_label_select = browsechanbinGUI(listb, indxlistb, titlename);
        if ~isempty(chan_label_select)
            ERP_tab_edit_chan.select_edit_chan.String  = vect2colon(chan_label_select);
        else
            beep;
            %disp('User selected Cancel');
            return
        end
    end

%%---------------------Delete selected chan--------------------------------
    function delete_chan(Source,~)
        if isempty(observe_ERPDAT.ERP)
            Source.Enable= 'off';
            return;
        end
        [messgStr,ERPpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && ERPpanelIndex~=15
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        EStudio_erp_box_edit_chan.TitleColor= [0.0500    0.2500    0.5000];
        estudioworkingmemory('ERPTab_editchan',0);
        
        erpworkingmemory('f_ERP_proces_messg','Edit Channels >  Delete selected chan');
        observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
        
        ERPArray =  estudioworkingmemory('selectederpstudio');
        if isempty(ERPArray) ||  any(ERPArray(:) > length(observe_ERPDAT.ALLERP))  ||  any(ERPArray <1)
            ERPArray = observe_ERPDAT.CURRENTERP;
        end
        
        ChanArray =  str2num(ERP_tab_edit_chan.select_edit_chan.String);
        if isempty(ChanArray) || min(ChanArray(:))<=0 || max(ChanArray(:))<=0
            erpworkingmemory('f_ERP_proces_messg','Edit Channels >  Delete selected chan > Indexes of chans should be positive numbers');
            observe_ERPDAT.Process_messg =4; %%Marking for the procedure has been started.
            return;
        end
        CreateERPFlag = ERP_tab_edit_chan.mode_create.Value; %%create new ERP dataset
        ALLERP = observe_ERPDAT.ALLERP;
        if CreateERPFlag==1
            Answer = f_ERP_save_multi_file(ALLERP,ERPArray,'_delchan');
            if isempty(Answer)
                beep;
                %disp('User selected Cancel');
                return;
            end
            if ~isempty(Answer{1})
                ALLERP = Answer{1};
                Save_file_label = Answer{2};
            end
        end
        ALLERPCOM = evalin('base','ALLERPCOM');
        for NumofERP = 1:numel(ERPArray)
            ERP = ALLERP(ERPArray(NumofERP));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['Your current ERPset(No.',num2str(ERPArray(NumofERP)),'):',32,ERP.erpname,'\n\n']);
            
            %%check the selected chans
            if any(ChanArray(:) > ERP.nchan)
                Erromesg = ['Edit Channels >  Delete selected chan > Selected channel should be between 1 and ',32, num2str(ERP.nchan)];
                erpworkingmemory('f_ERP_proces_messg',Erromesg);
                observe_ERPDAT.Process_messg =4;
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                return;
            end
            
            if numel(ChanArray) == ERP.nchan
                Erromesg = ['Edit Channels >  Delete selected chan > Please clear this ERPset in "ERPsets" panel if you want to delete all channels'];
                erpworkingmemory('f_ERP_proces_messg',Erromesg);
                observe_ERPDAT.Process_messg =4;
                fprintf( ['\n',repmat('-',1,100) '\n']);
                return;
            end
            keeplocs=1;
            Formula_str = strcat(['delerpchan(', vect2colon(ChanArray),')']);
            
            [ERP, ERPCOM] = pop_erpchanoperator(ERP, {Formula_str}, 'Warning', 'off', 'Saveas', 'off','ErrorMsg', 'command','KeepLocations',keeplocs, 'History', 'gui');
            [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
            
            if CreateERPFlag==0
                observe_ERPDAT.ALLERP(ERPArray(NumofERP)) = ERP;
            else
                checkfileindex = checkfilexists([ERP.filepath,filesep,ERP.filename]);
                if Save_file_label && checkfileindex==1
                    [pathstr, file_name, ext] = fileparts(ERP.filename);
                    ERP.filename = [file_name,'.erp'];
                    [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', ERP.filename, 'filepath',ERP.filepath);
                    [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                else
                    ERP.filename = '';
                    ERP.saved = 'no';
                    ERP.filepath = '';
                end
                observe_ERPDAT.ALLERP(length(observe_ERPDAT.ALLERP)+1) = ERP;
            end
            fprintf( [repmat('-',1,100) '\n']);
        end
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        if CreateERPFlag==1
            try
                Selected_ERP_afd =  [length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1:length(observe_ERPDAT.ALLERP)];
                observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1;
            catch
                Selected_ERP_afd = length(observe_ERPDAT.ALLERP);
                observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
            end
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
            estudioworkingmemory('selectederpstudio',Selected_ERP_afd);
            assignin('base','ERP',observe_ERPDAT.ERP);
            assignin('base','CURRENTSET',observe_ERPDAT.CURRENTERP);
            assignin('base','ALLERP',observe_ERPDAT.ALLERP);
        end
        observe_ERPDAT.Count_currentERP=1;
        observe_ERPDAT.Process_messg =2;
    end


%%-----------------------Rename selected chan------------------------------
    function rename_chan(Source,~)
        if isempty(observe_ERPDAT.ERP)
            Source.Enable= 'off';
            return;
        end
        [messgStr,ERPpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && ERPpanelIndex~=15
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        EStudio_erp_box_edit_chan.TitleColor= [0.0500    0.2500    0.5000];
        estudioworkingmemory('ERPTab_editchan',0);
        
        erpworkingmemory('f_ERP_proces_messg','Edit Channels >  Rename selected chan');
        observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
        ChanArray =  str2num(ERP_tab_edit_chan.select_edit_chan.String);
        
        if isempty(ChanArray) || min(ChanArray(:))<=0 || max(ChanArray(:))<=0
            erpworkingmemory('f_ERP_proces_messg','Edit Channels >  Delete selected chan > Indexes of chans should be positive numbers');
            observe_ERPDAT.Process_messg =4; %%Marking for the procedure has been started.
            return;
        end
        
        ERPArray =  estudioworkingmemory('selectederpstudio');
        if isempty(ERPArray) ||  min(ERPArray(:)) > length(observe_ERPDAT.ALLERP) ||  max(ERPArray(:)) > length(observe_ERPDAT.ALLERP) ||  min(ERPArray(:)) <1
            ERPArray = observe_ERPDAT.CURRENTERP;
        end
        
        CreateERPFlag = ERP_tab_edit_chan.mode_create.Value; %%create new ERP dataset
        %         try
        ALLERP = observe_ERPDAT.ALLERP;
        Save_file_label=0;
        if CreateERPFlag==1
            Answer = f_ERP_save_multi_file(ALLERP,ERPArray,'_rnchan');
            if isempty(Answer)
                beep;
                %disp('User selected Cancel');
                return;
            end
            if ~isempty(Answer{1})
                ALLERP = Answer{1};
                Save_file_label = Answer{2};
            end
        end
        ALLERPCOM = evalin('base','ALLERPCOM');
        for NumofERP = 1:numel(ERPArray)
            ERP = ALLERP(ERPArray(NumofERP));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Rename selected chan*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current ERPset(No.',num2str(ERPArray(NumofERP)),'):',32,ERP.erpname,'\n\n']);
            
            %%check the selected chans
            if min(ChanArray(:)) > ERP.nchan || max(ChanArray(:)) > ERP.nchan
                fprintf( ['Edit Channels >  Rename selected chan: Some of chan indexes exceed',32,num2str(ERP.nchan),32,', we therefore select all channels.\n']);
                ChanArray = [1:ERP.nchan];
            end
            try
                [eloc, Chanlabelsold, theta, radius, indices] = readlocs( ERP.chanlocs);
                Chanlabelsold = Chanlabelsold(ChanArray);
            catch
                beep
                disp('Please check ERP.chanlocs');
                fprintf( [repmat('-',1,100) '\n']);
                observe_ERPDAT.Process_messg =3;
                return;
            end
            CURRENTSET = ERPArray(NumofERP);
            def =  erpworkingmemory('pop_rename2chan');
            if isempty(def)
                def = Chanlabelsold;
            end
            
            titleName= ['Dataset',32,num2str(CURRENTSET),': ERPLAB Change Channel Name'];
            Chanlabelsnew= f_change_chan_name_GUI(Chanlabelsold,def,titleName);
            
            if isempty(Chanlabelsnew)
                %disp('User selected Cancel');
                fprintf( [repmat('-',1,100) '\n']);
                observe_ERPDAT.Process_messg =2;
                return
            end
            erpworkingmemory('pop_rename2chan',Chanlabelsnew);
            
            [ERP, ERPCOM] = pop_rename2chan(ALLERP,CURRENTSET,'ChanArray',ChanArray,'Chanlabels',Chanlabelsnew,'History', 'gui');
            [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
            
            if CreateERPFlag==0
                observe_ERPDAT.ALLERP(ERPArray(NumofERP)) = ERP;
            else
                checkfileindex = checkfilexists([ERP.filepath,filesep,ERP.filename]);
                if Save_file_label && checkfileindex==1
                    [pathstr, file_name, ext] = fileparts(ERP.filename);
                    ERP.filename = [file_name,'.erp'];
                    [ERP, ~, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', ERP.filename, 'filepath',ERP.filepath);
                    [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                else
                    ERP.filename = '';
                    ERP.saved = 'no';
                    ERP.filepath = '';
                end
                observe_ERPDAT.ALLERP(length(observe_ERPDAT.ALLERP)+1) = ERP;
            end
            fprintf( [repmat('-',1,100) '\n']);
        end
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        if CreateERPFlag==1
            try
                Selected_ERP_afd =  [length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1:length(observe_ERPDAT.ALLERP)];
                observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1;
            catch
                Selected_ERP_afd = length(observe_ERPDAT.ALLERP);
                observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
            end
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
            estudioworkingmemory('selectederpstudio',Selected_ERP_afd);
            assignin('base','ERP',observe_ERPDAT.ERP);
            assignin('base','CURRENTSET',observe_ERPDAT.CURRENTERP);
            assignin('base','ALLERP',observe_ERPDAT.ALLERP);
        end
        observe_ERPDAT.Count_currentERP=1;
        erpworkingmemory('f_ERP_proces_messg','Edit Channels >  Rename selected chan');
        observe_ERPDAT.Process_messg =2;
    end


%%------------------edit channel locations---------------------------------
    function edit_chanlocs(Source,~)
        if isempty(observe_ERPDAT.ERP)
            Source.Enable= 'off';
            return;
        end
        [messgStr,ERPpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && ERPpanelIndex~=15
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        EStudio_erp_box_edit_chan.TitleColor= [0.0500    0.2500    0.5000];
        estudioworkingmemory('ERPTab_editchan',0);
        
        erpworkingmemory('f_ERP_proces_messg','Edit Channels >  Add or edit channel locations');
        observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
        
        ERPArray =  estudioworkingmemory('selectederpstudio');
        if isempty(ERPArray) ||  min(ERPArray(:)) > length(observe_ERPDAT.ALLERP) ||  max(ERPArray(:)) > length(observe_ERPDAT.ALLERP) ||  min(ERPArray(:)) <1
            ERPArray = observe_ERPDAT.CURRENTERP;
        end
        CreateERPFlag = ERP_tab_edit_chan.mode_create.Value; %%create new ERP dataset
        %%loop for the selected ERPsets
        Save_file_label=0;
        ALLERP = observe_ERPDAT.ALLERP;
        if CreateERPFlag==1
            Answer = f_ERP_save_multi_file(ALLERP,ERPArray,'_editchan');
            if isempty(Answer)
                beep;
                %disp('User selected Cancel');
                return;
            end
            if ~isempty(Answer{1})
                ALLERP = Answer{1};
                Save_file_label = Answer{2};
            end
        end
        ALLERPCOM = evalin('base','ALLERPCOM');
        
        for NumofERP = 1:numel(ERPArray)
            ERP = ALLERP(ERPArray(NumofERP));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Add or edit all  channel locations*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current ERPset(No.',num2str(ERPArray(NumofERP)),'):',32,ERP.erpname,'\n\n']);
            ChanArray = [1:ERP.nchan];
            titleName= ['Dataset',32,num2str(ERPArray(NumofERP)),': Add or edit channel locations'];
            
            app = feval('f_editchan_gui',ERP,titleName);
            waitfor(app,'Finishbutton',1);
            try
                ERPoutput = app.output; %NO you don't want to output ERP with edited channel locations, you want to output the parameters to run decoding
                app.delete; %delete app from view
                pause(0.1); %wait for app to leave
            catch
                %disp('User selected Cancel');
                fprintf( ['\n',repmat('-',1,100) '\n']);
                break;
            end
            
            if isempty(ERPoutput)
                %disp('User selected Cancel');
                fprintf( ['\n',repmat('-',1,100) '\n']);
                break;
            end
            Chanlocs = ERPoutput.chanlocs;
            
            [ERP, ERPCOM] = pop_editdatachanlocs(ALLERP,ERPArray(NumofERP),...
                'ChanArray',ChanArray,'Chanlocs',Chanlocs,'History', 'gui');
            [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
            
            if CreateERPFlag==0
                observe_ERPDAT.ALLERP(ERPArray(NumofERP)) = ERP;
            else
                checkfileindex = checkfilexists([ERP.filepath,filesep,ERP.filename]);
                if Save_file_label && checkfileindex==1
                    [pathstr, file_name, ext] = fileparts(ERP.filename);
                    ERP.filename = [file_name,'.erp'];
                    [ERP, ~, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', ERP.filename, 'filepath',ERP.filepath);
                    [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                else
                    ERP.filename = '';
                    ERP.saved = 'no';
                    ERP.filepath = '';
                end
                observe_ERPDAT.ALLERP(length(observe_ERPDAT.ALLERP)+1) = ERP;
            end
            fprintf( ['\n',repmat('-',1,100) '\n']);
        end
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        if CreateERPFlag==1
            try
                Selected_ERP_afd =  [length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1:length(observe_ERPDAT.ALLERP)];
                observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1;
            catch
                Selected_ERP_afd = length(observe_ERPDAT.ALLERP);
                observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
            end
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
            estudioworkingmemory('selectederpstudio',Selected_ERP_afd);
            assignin('base','ERP',observe_ERPDAT.ERP);
            assignin('base','CURRENTSET',observe_ERPDAT.CURRENTERP);
            assignin('base','ALLERP',observe_ERPDAT.ALLERP);
        end
        observe_ERPDAT.Count_currentERP=1;
        observe_ERPDAT.Process_messg =2;
    end


%%--------Settting will be modified if the selected was changed------------
    function Count_currentERPChanged(~,~)
        if observe_ERPDAT.Count_currentERP ~=7
            return;
        end
        ViewerFlag=erpworkingmemory('ViewerFlag');%%when open advanced wave viewer
        if isempty(ViewerFlag) || (ViewerFlag~=0 && ViewerFlag~=1)
            ViewerFlag=0;erpworkingmemory('ViewerFlag',0);
        end
        if  isempty(observe_ERPDAT.ERP) || ViewerFlag==1 || (~isempty(observe_ERPDAT.ERP) && isempty(observe_ERPDAT.ERP.chanlocs))
            ERP_tab_edit_chan.mode_modify.Enable ='off';
            ERP_tab_edit_chan.mode_create.Enable = 'off';
            ERP_tab_edit_chan.delete_chan.Enable='off';
            ERP_tab_edit_chan.rename_chan.Enable='off';
            ERP_tab_edit_chan.edit_chanlocs.Enable='off';
            ERP_tab_edit_chan.select_edit_chan.Enable='off';
            ERP_tab_edit_chan.browse_chan.Enable='off';
            observe_ERPDAT.Count_currentERP=8;
            return;
        end
        ERP_tab_edit_chan.mode_modify.Enable ='on';
        ERP_tab_edit_chan.mode_create.Enable = 'on';
        ERP_tab_edit_chan.delete_chan.Enable='on';
        ERP_tab_edit_chan.rename_chan.Enable='on';
        ERP_tab_edit_chan.edit_chanlocs.Enable='on';
        ERP_tab_edit_chan.select_edit_chan.Enable='on';
        ERP_tab_edit_chan.browse_chan.Enable='on';
        observe_ERPDAT.Count_currentERP=8;
    end

%%-------------------------------------------------------------------------
%%Automatically saving the changed parameters for the current panel if the
%%user change parameters for the other panels.
%%-------------------------------------------------------------------------
    function ERP_two_panels_change(~,~)
        if observe_ERPDAT.erp_two_panels==0
            return;
        end
        ChangeFlag =  estudioworkingmemory('ERPTab_editchan');
        if ChangeFlag~=1
            return;
        end
        estudioworkingmemory('ERPTab_editchan',0);
        EStudio_erp_box_edit_chan.TitleColor= [0.0500    0.2500    0.5000];
    end


%%--------------Reset this panel with the default parameters---------------
    function Reset_erp_panel_change(~,~)
        if observe_ERPDAT.Reset_erp_paras_panel~=5
            return;
        end
        estudioworkingmemory('ERPTab_editchan',0);
        ERP_tab_edit_chan.mode_modify.Value =1;
        ERP_tab_edit_chan.mode_create.Value = 0;
        ERP_tab_edit_chan.select_edit_chan.String = '';
        observe_ERPDAT.Reset_erp_paras_panel=6;
    end
end


%%----------------check if the file already exists-------------------------
function checkfileindex = checkfilexists(filenamex)%%Jan 10 2024
checkfileindex=0;
[pathstr, file_name, ext] = fileparts(filenamex);
filenamex = [pathstr, file_name,'.set'];
if exist(filenamex, 'file')~=0
    msgboxText =  ['This ERP Data already exist.\n'...;
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

