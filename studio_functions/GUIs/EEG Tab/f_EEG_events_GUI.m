%%This function is operation for EventList

% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2023


function varargout = f_EEG_events_GUI(varargin)

global observe_EEGDAT;
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
% addlistener(observe_EEGDAT,'eeg_panel_change_message',@eeg_panel_change_message);
% addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
%---------------------------Initialize parameters------------------------------------

EStduio_eegtab_EEG_events = struct();

%-----------------------------Name the title----------------------------------------------
% global EStudio_eeg_events_box;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    EStudio_eeg_events_box = uiextras.BoxPanel('Parent', fig, 'Title', 'EventList', 'Padding', 5,...
        'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    EStudio_eeg_events_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'EventList', 'Padding', 5,...
        'BackgroundColor',ColorB_def);
else
    EStudio_eeg_events_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'EventList', 'Padding', 5,...
        'FontSize', varargin{2},'BackgroundColor',ColorB_def);%, 'HelpFcn', @event_help
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

drawui_eeg_events(FonsizeDefault)
varargout{1} = EStudio_eeg_events_box;

    function drawui_eeg_events(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        EStduio_eegtab_EEG_events.DataSelBox = uiextras.VBox('Parent', EStudio_eeg_events_box,'BackgroundColor',ColorB_def);
        if isempty(observe_EEGDAT.EEG)
            EnableFlag= 'off';
        else
            EnableFlag= 'on';
        end
        
        %%----------------title "EventList Operations"---------------------
        EStduio_eegtab_EEG_events.eventop_title = uiextras.HBox('Parent',EStduio_eegtab_EEG_events.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', EStduio_eegtab_EEG_events.eventop_title,'FontWeight','bold',...
            'String','EventList Operations:','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        %%Create Eventlist and Import
        EStduio_eegtab_EEG_events.create_rt_title = uiextras.HBox('Parent',EStduio_eegtab_EEG_events.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_events.create_eventlist = uicontrol('Style', 'pushbutton','Parent',   EStduio_eegtab_EEG_events.create_rt_title ,...
            'String','Create','callback',@create_eventlist,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        EStduio_eegtab_EEG_events.imp_eventlist = uicontrol('Style', 'pushbutton','Parent', EStduio_eegtab_EEG_events.create_rt_title ,...
            'String','Import','callback',@imp_eventlist,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        EStduio_eegtab_EEG_events.exp_eventlist = uicontrol('Style', 'pushbutton','Parent', EStduio_eegtab_EEG_events.create_rt_title,...
            'String','Export','callback',@exp_eventlist,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        
        %%export eventlist
        EStduio_eegtab_EEG_events.imp_exp_title = uiextras.HBox('Parent',EStduio_eegtab_EEG_events.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        
        EStduio_eegtab_EEG_events.vieweventlist = uicontrol('Style', 'pushbutton','Parent', EStduio_eegtab_EEG_events.imp_exp_title,...
            'String','View ','callback',@vieweventlist,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        %         EStduio_eegtab_EEG_events.transfer_event_title = uiextras.HBox('Parent',EStduio_eegtab_EEG_events.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_events.transfer_event = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_EEG_events.imp_exp_title ,...
            'String','Transfer event info to EEG.event','callback',@transfer_event,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        
        set(EStduio_eegtab_EEG_events.imp_exp_title,'Sizes',[-1 200]);
        
        %%------------title for "Other Operations"-------------------------
        EStduio_eegtab_EEG_events.eventotherop_title = uiextras.HBox('Parent',EStduio_eegtab_EEG_events.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', EStduio_eegtab_EEG_events.eventotherop_title,'FontWeight','bold',...
            'String','Other Operations:','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        %%Summarize EEG event codes
        EStduio_eegtab_EEG_events.summarize_code_title = uiextras.HBox('Parent',EStduio_eegtab_EEG_events.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_events.summarize_code = uicontrol('Style', 'pushbutton','Parent', EStduio_eegtab_EEG_events.summarize_code_title,...
            'String','Summarize event codes/bins in cmd window','callback',@summarize_code,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent',  EStduio_eegtab_EEG_events.summarize_code_title);
        set( EStduio_eegtab_EEG_events.summarize_code_title,'Sizes',[265 -1]);
        
        %%Shuffle events/bins/samples/
        EStduio_eegtab_EEG_events.shuffle_title = uiextras.HBox('Parent',EStduio_eegtab_EEG_events.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_events.eeg_shuffle = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_EEG_events.shuffle_title ,...
            'String','Shuffle events/bins/samples','callback',@eeg_shuffle,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        %%export reaction times
        EStduio_eegtab_EEG_events.exp_rt = uicontrol('Style', 'pushbutton','Parent',  EStduio_eegtab_EEG_events.shuffle_title ,...
            'String','Export RTs','callback',@exp_rt,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        set(EStduio_eegtab_EEG_events.shuffle_title,'Sizes',[170 -1]);
        
        EStduio_eegtab_EEG_events.sumevent_title = uiextras.HBox('Parent',EStduio_eegtab_EEG_events.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', EStduio_eegtab_EEG_events.sumevent_title,'FontWeight','bold',...
            'String','Event Code Summary for current EEGset:','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        %%---------------------Table---------------------------------------
        EStduio_eegtab_EEG_events.table_title = uiextras.HBox('Parent',EStduio_eegtab_EEG_events.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        for ii = 1:100
            dsnames{ii,1} = '';
            dsnames{ii,2} = '';
        end
        EStduio_eegtab_EEG_events.table_event = uitable(  ...
            'Parent'        , EStduio_eegtab_EEG_events.table_title,...
            'Data'          , dsnames, ...
            'ColumnWidth'   , {100,100}, ...
            'ColumnName'    , {'Event Code','#Occurrences'}, ...
            'RowName'       , [],...
            'ColumnEditable',[false, false]);
        set(EStduio_eegtab_EEG_events.DataSelBox,'Sizes',[20 30 30 20 30 30 20 100]);
    end

%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%----------Summarize the event codes for the selected EEG-----------------
    function summarize_code(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        if isempty(observe_EEGDAT.EEG.event)
            Source.Enable= 'off';
            msgboxText = ['EventList >  Summarize event code:EEG.event is empty for the current EEG'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_EEG_proces_messg','EventList >  Summarize event code');
        observe_EEGDAT.eeg_panel_message =1;
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG)) ||   any(EEGArray(:) <1)
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        for Numofeeg = 1:numel(EEGArray)
            EEG =   observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
            if isempty(EEG.event)
                CheckFlag = 0;
                msgboxText = ['EventList >  Summarize event code:EEG.event is empty for',32,EEG.setname];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
            elseif isempty([EEG(1).event.type])
                CheckFlag = 0;
                msgboxText = ['EventList >  Summarize event code:EEG.event.type is empty for',32,EEG.setname];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
            else
                CheckFlag=1;
            end
            if CheckFlag==1
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['Your EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n']);
                [EEG, LASTCOM] = pop_squeezevents(EEG,'History','gui');
                EEG = eegh(LASTCOM, EEG);
                if Numofeeg==1
                    eegh(LASTCOM);
                end
                observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = EEG;
            end
        end
        erpworkingmemory('f_EEG_proces_messg','EventList >  Summarize event code');
        observe_EEGDAT.eeg_panel_message =2;
    end

%%------------------------Create EEG eventlist-----------------------------
    function create_eventlist(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        if observe_EEGDAT.EEG.trials>1
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        if isempty(observe_EEGDAT.EEG.event)
            Source.Enable= 'off';
            msgboxText = ['EventList >  Create Eventlist: EEG.event is empty for the current EEG'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        erpworkingmemory('f_EEG_proces_messg','EventList >  Create Eventlist');
        observe_EEGDAT.eeg_panel_message =1;
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        ALLEEG = observe_EEGDAT.ALLEEG;
        ALLEEG_out = [];
        
        %% Get previous input parameters
        def  = erpworkingmemory('pop_creabasiceventlist');
        if isempty(def)
            def = {'' 'boundary' -99 1 1};
        end
        if numel(EEGArray)>1
            multieeg =1;
        else
            multieeg=0;
        end
        %% Call GUI
        inputstrMat = creabasiceventlistGUI(def, multieeg);  % GUI
        
        if isempty(inputstrMat) && ~strcmp(inputstrMat,'')
            return
        elseif strcmp(inputstrMat,'advanced')
            EEG = ALLEEG(EEGArray);
            [EEG, LASTCOM ] = pop_editeventlist(EEG);
            if isempty(LASTCOM)
                return;
            end
            EEG = eegh(LASTCOM, EEG);
            eegh(LASTCOM);
            [ALLEEG_out, EEG, ~,LASTCOM] = pop_newset(ALLEEG_out, EEG, length(ALLEEG_out), 'gui', 'off');
        end
        
        
        if ~strcmp(inputstrMat,'advanced')
            elname   = inputstrMat{1};
            boundarystrcode    = inputstrMat{2};
            newboundarynumcode = inputstrMat{3};
            rwwarn   = inputstrMat{4};
            alphanum = inputstrMat{5};
            
            erpworkingmemory('pop_creabasiceventlist', {elname, boundarystrcode, newboundarynumcode, rwwarn, alphanum});
            
            if rwwarn==1
                striswarning = 'on';
            else
                striswarning = 'off';
            end
            if alphanum==1
                stralphanum = 'on';
            else
                stralphanum = 'off';
            end
            
            [pathx, filename, ext] = fileparts(elname);
            for Numofeeg = 1:numel(EEGArray)
                EEG = ALLEEG(EEGArray(Numofeeg));
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
                
                filename1 = strcat(filename,'.txt');
                filename1 = fullfile(pathx, filename1);
                if multieeg==1
                    filename1 ='';
                end
                %% Run pop_ command again with the inputs from the GUI
                [EEG, LASTCOM] = pop_creabasiceventlist(EEG, 'Eventlist', filename1, 'BoundaryString', boundarystrcode,...
                    'BoundaryNumeric', newboundarynumcode,'Warning', striswarning, 'AlphanumericCleaning', stralphanum, 'History', 'gui');
                EEG = eegh(LASTCOM, EEG);
                if Numofeeg==1
                    eegh(LASTCOM);
                end
                
                [ALLEEG_out, EEG, ~,LASTCOM] = pop_newset(ALLEEG_out, EEG, length(ALLEEG_out), 'gui', 'off');
                if Numofeeg==1
                    eegh(LASTCOM);
                end
                fprintf( ['\n',repmat('-',1,100) '\n\n']);
            end
            
        end
        
        Save_file_label = 0;
        Answer = f_EEG_save_multi_file(ALLEEG_out,1:numel(EEGArray), '_elist');
        if isempty(Answer)
            return;
        end
        if ~isempty(Answer{1})
            ALLEEG_out = Answer{1};
            Save_file_label = Answer{2};
        end
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
            [ALLEEG, EEG, ~,LASTCOM] = pop_newset(ALLEEG, EEG, length(ALLEEG), 'gui', 'off');
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


%%----------------Export reaction times to text file-----------------------
    function exp_rt(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        if observe_EEGDAT.EEG.trials>1
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_EEG_proces_messg','EventList >  Export RTs');
        observe_EEGDAT.eeg_panel_message =1;
        
        if ~isfield(observe_EEGDAT.EEG,'EVENTLIST')
            msgboxText = ['EventList >  Export RTs: No EVETLIST, please create one first'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        def  = erpworkingmemory('pop_rt2text');
        
        if isempty(def)
            def = {'' 'basic' 'on' 'off' 1};
        end
        
        e2 = length(observe_EEGDAT.EEG.EVENTLIST);
        
        %
        % Call Gui
        %
        param  = saveRTGUI(def, e2);
        
        if isempty(param)
            disp('User selected Cancel')
            return
        end
        filenamei  = param{1};
        listformat = param{2};
        header     = param{3};  % 1 means include header (name of variables)
        arfilt     = param{4};  % 1 means filter out RTs with marked flags
        indexel    = param{5};  % index for eventlist
        [pathx, filename, ext] = fileparts(filenamei);
        if header==1
            headstr = 'on';
        else
            headstr = 'off';
        end
        if arfilt==1
            arfilter = 'on';
        else
            arfilter = 'off';
        end
        erpworkingmemory('pop_rt2text', {fullfile(pathx, filename), listformat, headstr, arfilter, indexel});
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        for Numofeeg = 1:numel(EEGArray)
            
            EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
            if ~isfield(EEG, 'EVENTLIST')
                erpworkingmemory('f_EEG_proces_messg','EventList >  Export RTs:EVENTLIST structure is empty');
                observe_EEGDAT.eeg_panel_message =4;
            else
                filenameeeg = EEG.filename;
                [pathxeeg, filenameeeg, ext] = fileparts(filenameeeg);
                if isempty(filenameeeg)
                    filename = [num2str(EEGArray(Numofeeg)),'_',filename,'.txt'];
                else
                    filename = strcat(filenameeeg,'_',filename,'.txt');
                end
                filename = fullfile(pathx, filename);
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
                fprintf(['The exported file name:',32,filename,'\n\n']);
                
                [EEG,values, LASTCOM] = pop_rt2text(EEG, 'filename', filename, 'listformat', listformat, 'header', headstr,...
                    'arfilter', arfilter, 'eventlist', indexel, 'History', 'gui');
                if ~isempty( values)
                    EEG = eegh(LASTCOM, EEG);
                    if Numofeeg==1
                        eegh(LASTCOM);
                    end
                    observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) =EEG;
                else
                    fprintf(2,['Cannot export reaction times for:',32,EEG.setname,'\n']);
                    fprintf( [repmat('-',1,100) '\n']);
                end
            end
        end
        erpworkingmemory('f_EEG_proces_messg','EventList >  Export RTs');
        observe_EEGDAT.eeg_panel_message =2;
        observe_EEGDAT.count_current_eeg=1;
    end


%%-------------------View eventlist----------------------------------------
    function vieweventlist(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG)) ||  any(EEGArray(:) <1)
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        erpworkingmemory('f_EEG_proces_messg','EventList >  View EventList');
        observe_EEGDAT.eeg_panel_message =1;
        feval('EEG_evenlist_gui',observe_EEGDAT.ALLEEG(EEGArray));
        observe_EEGDAT.eeg_panel_message =2;
    end


%%--------------------import EEG eventlist to text file--------------------
    function imp_eventlist(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        if observe_EEGDAT.EEG.trials>1
            msgboxText =  'Eventlist>Import:pop_importeegeventlist() has been tested for continuous data only';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        erpworkingmemory('f_EEG_proces_messg','EventList >  Import');
        observe_EEGDAT.eeg_panel_message =1;
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG)) ||  any(EEGArray(:) <1)
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        ALLEEG_out = [];
        ALLEEG = observe_EEGDAT.ALLEEG;
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            
            %% Run pop_ command again with the inputs from the GUI
            [filename,pathname] = uigetfile({'*.*';'*.txt'},['Select a EVENTLIST file for eegset:',32,num2str(EEGArray(Numofeeg))]);
            ELfullname = fullfile(pathname, filename);
            
            if isequal(filename,0)
                fprintf( ['\n',repmat('-',1,100) '\n']);
                return
            else
                disp(['For read an EVENTLIST, user selected ', ELfullname])
            end
            
            [EEG, LASTCOM] = pop_importeegeventlist( EEG, ELfullname , 'ReplaceEventList', 'on' );
            EEG = eegh(LASTCOM, EEG);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            [ALLEEG_out, ~,~,LASTCOM] = pop_newset(ALLEEG_out, EEG, length(ALLEEG_out), 'gui', 'off');
            if Numofeeg==1
                eegh(LASTCOM);
            end
            fprintf( ['\n',repmat('-',1,100) '\n\n']);
        end
        
        Save_file_label = 0;
        Answer = f_EEG_save_multi_file(ALLEEG_out,1:numel(EEGArray), '_impel');
        if isempty(Answer)
            return;
        end
        if ~isempty(Answer{1})
            ALLEEG_out = Answer{1};
            Save_file_label = Answer{2};
        end
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
            [ALLEEG, EEG, ~,LASTCOM] = pop_newset(ALLEEG, EEG, length(ALLEEG), 'gui', 'off');
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


%%--------------------export EEG eventlist to text file--------------------
    function exp_eventlist(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_EEG_proces_messg','EventList >  Export eventlist');
        observe_EEGDAT.eeg_panel_message =1;
        
        if ~isfield(observe_EEGDAT.EEG,'EVENTLIST') || isempty(observe_EEGDAT.EEG.EVENTLIST)
            msgboxText =  ['EventList >Export eventlist: Please check the current EEG.EVENTLIST'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        [fname, pathname] = uiputfile({'*.*'},'Save EVENTLIST file as (This will be suffix when using EStudio)');
        
        if isequal(fname,0)
            disp('User selected Cancel')
            return
        end
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG)) ||  any(EEGArray(:) <1)
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        [xpath, suffixstr, ext] = fileparts(fname);
        
        for Numofeeg = 1:numel(EEGArray)
            EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
            msgboxText = '';
            if isfield(EEG, 'EVENTLIST')
                if isempty(EEG.EVENTLIST)
                    msgboxText =  ['EEG.EVENTLIST structure is empty'];
                end
                if isfield(EEG.EVENTLIST, 'eventinfo')
                    if isempty(EEG.EVENTLIST.eventinfo)
                        msgboxText =  ['EEG.EVENTLIST.eventinfo structure is empty'];
                    end
                else
                    msgboxText =  ['EEG.EVENTLIST.eventinfo structure is empty'];
                end
            else
                msgboxText =  ['EEG.EVENTLIST structure is empty'];
            end
            
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            if isempty(msgboxText)
                filenameeg = EEG.filename;
                [xpatheeg, filenameeg, exteeg] = fileparts(filenameeg);
                if isempty(filenameeg)
                    filenameeg = strcat(num2str(EEGArray(Numofeeg)),'_',suffixstr,'.txt');
                else
                    filenameeg = strcat(filenameeg,'_',suffixstr,'.txt');
                end
                filenameeg = fullfile(pathname, filenameeg);
                
                disp(['For EVENTLIST output user selected ', filenameeg])
                [EEG, LASTCOM] = pop_exporteegeventlist( EEG , 'Filename', filenameeg,'History','gui');
                EEG = eegh(LASTCOM, EEG);
                if Numofeeg==1
                    eegh(LASTCOM);
                end
                observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) =EEG;
            else
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                fprintf(2,['Cannot export eventlist for:',32,EEG.setname,'\n']);
                fprintf( [repmat('-',1,100) '\n']);
            end
        end
        
        erpworkingmemory('f_EEG_proces_messg','EventList >  Export eventlist');
        observe_EEGDAT.eeg_panel_message =2;
        observe_EEGDAT.count_current_eeg=1;
    end


%%-----------------Shuffle events/bins/samples-----------------------------
    function eeg_shuffle(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        if observe_EEGDAT.EEG.trials>1
            Source.Enable= 'off';
            return;
        end
        
        erpworkingmemory('f_EEG_proces_messg','EventList >  Shuffle events/bins/samples');
        observe_EEGDAT.eeg_panel_message =1;
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG))||  any(EEGArray(:) <1)
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        
        %% Get previous input parameters
        def = erpworkingmemory('pop_eventshuffler');
        
        if isempty(def)
            def = {[] 0};
        end
        %% Call GUI
        answer = shuffleGUI(def);
        if isempty(answer)
            return
        end
        valueatfield = answer{1};
        specfield    = answer{2};
        
        if specfield==0
            specfieldstr = 'code';
        elseif specfield==1
            specfieldstr = 'bini';
        elseif specfield==2
            specfieldstr = 'data';
            valueatfield = 'off';
        else
            msgboxText = ['EventList >  Shuffle events/bins/samples: invalid field'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        if ~isnumeric(valueatfield) && ~strcmpi(valueatfield, 'all') && ~strcmpi(valueatfield, 'off')
            valueatfield = str2num(valueatfield);
            if isempty(valueatfield)
                msgboxText =  'EventList >  Shuffle events/bins/samples:Invalid value for "codes to shuffle"';
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
        end
        erpworkingmemory('pop_eventshuffler', {valueatfield specfield});
        ALLEEG_out = [];
        ALLEEG = observe_EEGDAT.ALLEEG;
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['Your current EEGset:',32,EEG.setname,'\n\n']);
            
            if ~isnumeric(valueatfield) && strcmpi(valueatfield, 'all')
                fprintf('User selected all %s\n', specfieldstr )
            elseif isnumeric(valueatfield)
                fprintf('User specified %s = %s \n', specfieldstr, vect2colon(valueatfield))
            end
            %%check current eeg data
            msgboxText ='';
            if ~isfield(EEG, 'event')
                msgboxText =  ['pop_eventshuffler did not find EEG.event field at dataset',32,num2str(EEGArray(Numofeeg))];
            end
            if ~isfield(EEG.event, 'type')
                msgboxText =  ['pop_eventshuffler did not find EEG.event.type field at dataset',32,num2str(EEGArray(Numofeeg))];
            end
            if ~isfield(EEG.event, 'latency')
                msgboxText =  ['pop_eventshuffler did not find EEG.event.latency field at dataset',32,num2str(EEGArray(Numofeeg))];
            end
            if ischar(EEG.event(1).type) && ~isfield(EEG, 'EVENTLIST')
                msgboxText =  ['pop_eventshuffler found alphanumeric codes at dataset',32,num2str(EEGArray(Numofeeg)),...
                    'We recommend to use Create EEG Eventlist to convert them into numeric ones.'];
            elseif ischar(EEG.event(1).type) && isfield(EEG, 'EVENTLIST')
                msgboxText =  ['pop_eventshuffler found alphanumeric codes at dataset',32,num2str(EEGArray(Numofeeg)),...
                    'We recommend to use Create EEG Eventlist Advance first.'];
            end
            if isempty(msgboxText)
                %% Run pop_ command again with the inputs from the GUI
                [EEG, LASTCOM] = pop_eventshuffler(EEG, 'Values', valueatfield, 'Field', specfieldstr, 'History', 'gui');
                EEG = eegh(LASTCOM, EEG);
                if Numofeeg==1
                    eegh(LASTCOM);
                end
            else
                msgboxText =  ['EventList >  Shuffle events/bins/samples:', msgboxText];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                fprintf( ['\n',repmat('-',1,100) '\n\n']);
                break;
            end
            if Numofeeg==1
                eegh(LASTCOM);
            end
            [ALLEEG_out,~,~,~] = pop_newset(ALLEEG_out, EEG, length(ALLEEG_out), 'gui', 'off');
            fprintf( ['\n',repmat('-',1,100) '\n\n']);
        end
        
        Save_file_label = 0;
        Answer = f_EEG_save_multi_file(ALLEEG_out,1:numel(EEGArray), '_shuffled');
        if isempty(Answer)
            return;
        end
        if ~isempty(Answer{1})
            ALLEEG_out = Answer{1};
            Save_file_label = Answer{2};
        end
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


%%--------------Transfer event info to EEG.event---------------------------
    function transfer_event(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        if isempty(observe_EEGDAT.EEG.event)
            Source.Enable= 'off';
            msgboxText = ['EventList >  Transfer event to EEG.event: EEG.event is empty for the current EEG'];
            Source.Enable= 'off';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        if observe_EEGDAT.EEG.trials>1
            Source.Enable= 'off';
            return;
        end
        erpworkingmemory('f_EEG_proces_messg','EventList >  Transfer event to EEG.event');
        observe_EEGDAT.eeg_panel_message =1;
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG)) ||  any(EEGArray(:) <1)
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        %% Call GUI
        answer = overwriteventGUI;
        
        if isempty(answer)
            return
        end
        mainfield    = answer{1};
        removenctype = answer{2}; % remove remaining event codes
        if removenctype==1
            rrcstr = 'on';
        else
            rrcstr = 'off';
        end
        iserrorf   = 0;
        
        ALLEEG_out = [];
        ALLEEG = observe_EEGDAT.ALLEEG;
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['Your current EEGset:',32,EEG.setname,'\n\n']);
            serror = erplab_eegscanner(EEG, 'pop_overwritevent', 0, 0, 0, 2, 1);
            msgboxText ='';
            if serror
                return;
            end
            %%check current eeg data
            if ~serror
                testfield1 = unique_bc2([EEG.EVENTLIST.eventinfo.(mainfield)]);
                if isempty(testfield1)
                    iserrorf = 1;
                end
                if isnumeric(testfield1)
                    testfield1 = num2str(testfield1);
                end
                if strcmp(testfield1,'"')
                    iserrorf = 1;
                end
                if iserrorf
                    msgboxText =  ['Sorry, EEG.EVENTLIST.eventinfo.'  mainfield ' field is empty!\n\n'...
                        'You should assign values to this field before overwriting EEG.event'];
                end
                
                if isempty(msgboxText)
                    [EEG, LASTCOM] = pop_overwritevent(EEG, mainfield, 'RemoveRemCodes', rrcstr,'History', 'gui');
                    if  isempty(LASTCOM)
                        fprintf( ['\n',repmat('-',1,100) '\n\n']);
                        break;
                    end
                    EEG = eegh(LASTCOM, EEG);
                    if Numofeeg==1
                        eegh(LASTCOM);
                    end
                else
                    msgboxText =  ['EventList >  Transfer event to EEG.event:', msgboxText];
                    titlNamerro = 'Warning for EEG Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    fprintf( ['\n',repmat('-',1,100) '\n\n']);
                    break;
                end
            end
            [ALLEEG_out,~,~,LASTCOM] = pop_newset(ALLEEG_out, EEG, length(ALLEEG_out), 'gui', 'off');
            if Numofeeg==1
                eegh(LASTCOM);
            end
            fprintf( ['\n',repmat('-',1,100) '\n\n']);
        end
        Save_file_label = 0;
        Answer = f_EEG_save_multi_file(ALLEEG_out,1:numel(EEGArray), '_transf');
        if isempty(Answer)
            return;
        end
        if ~isempty(Answer{1})
            ALLEEG_out = Answer{1};
            Save_file_label = Answer{2};
        end
        for Numofeeg = 1:numel(EEGArray)
            EEG =  ALLEEG_out(Numofeeg);
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


%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=11
            return;
        end
        if isempty(observe_EEGDAT.EEG) || isempty(observe_EEGDAT.EEG.event)
            EnableFlag = 'off';
            EStduio_eegtab_EEG_events.summarize_code.Enable=EnableFlag;
            %%Create and RTs
            EStduio_eegtab_EEG_events.create_eventlist.Enable=EnableFlag;
            %%export reaction times
            EStduio_eegtab_EEG_events.exp_rt.Enable=EnableFlag;
            %%Import and export eventlist
            EStduio_eegtab_EEG_events.imp_eventlist.Enable=EnableFlag;
            %%export evetnlist to text file
            EStduio_eegtab_EEG_events.exp_eventlist.Enable='off';
            EStduio_eegtab_EEG_events.eeg_shuffle.Enable=EnableFlag;
            EStduio_eegtab_EEG_events.transfer_event.Enable=EnableFlag;
            EStduio_eegtab_EEG_events.vieweventlist.Enable=EnableFlag;
            observe_EEGDAT.count_current_eeg=12;
            return;
        end
        
        EStudio_eeg_events_box.Title = 'EventList';
        EStudio_eeg_events_box.ForegroundColor= [1 1 1];
        for ii = 1:100
            dsnamesdef{ii,1} = '';
            dsnamesdef{ii,2} = '';
        end
        if ~isempty(observe_EEGDAT.EEG)
            if ndims(observe_EEGDAT.EEG.data) ==3%%Epoched EEG
                EnableFlag ='off';
            else %%Continuous EEG
                EnableFlag ='on';
            end
            eventArray = observe_EEGDAT.EEG.event;
            if ~isempty(eventArray)
                if ischar(eventArray(1).type)
                    allevents = { eventArray.type }';
                    formateve = 'STRINGS';
                else
                    allevents = cellstr(num2str([eventArray.type]'));
                    formateve = 'NUMERICS';
                end
                eventtypes = unique_bc2( allevents );
                % Summary
                sortevent = sort(allevents);
                [tf, indx] = ismember_bc2(eventtypes, sortevent);
                histo     = diff([0 indx'])';
                for ii = 1:length(histo)
                    dsnames{ii,1} = eventtypes{ii};
                    dsnames{ii,2} = num2str(histo(ii));
                end
            else
                dsnames = dsnamesdef;
            end
        else
            dsnames = dsnamesdef;
        end
        EStduio_eegtab_EEG_events.table_event.Data = dsnames;
        %%Summarize EEG event codes
        EStduio_eegtab_EEG_events.summarize_code.Enable=EnableFlag;
        %%Shift EEG event codes
        %%Create and RTs
        EStduio_eegtab_EEG_events.create_eventlist.Enable=EnableFlag;
        %%export reaction times
        EStduio_eegtab_EEG_events.exp_rt.Enable=EnableFlag;
        %%Import and export eventlist
        EStduio_eegtab_EEG_events.imp_eventlist.Enable=EnableFlag;
        %%export evetnlist to text file
        if ~isempty(observe_EEGDAT.EEG)
            EStduio_eegtab_EEG_events.exp_eventlist.Enable='on';
        else
            EStduio_eegtab_EEG_events.exp_eventlist.Enable='off';
        end
        EStduio_eegtab_EEG_events.eeg_shuffle.Enable=EnableFlag;
        EStduio_eegtab_EEG_events.transfer_event.Enable=EnableFlag;
        if isfield(observe_EEGDAT.EEG,'EVENTLIST') && ~isempty(observe_EEGDAT.EEG.EVENTLIST)
            EStduio_eegtab_EEG_events.vieweventlist.Enable='on';
        else
            EStduio_eegtab_EEG_events.vieweventlist.Enable='off';
        end
        observe_EEGDAT.count_current_eeg=12;
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
