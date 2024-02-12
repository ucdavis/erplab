%%This function is to detect and summarize artifact for epoched EEG.


% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Sep. 2023


function varargout = f_EEG_arf_sumop_GUI(varargin)

global observe_EEGDAT;
% addlistener(observe_EEGDAT,'eeg_panel_change_message',@eeg_panel_change_message);
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);

%---------------------------Initialize parameters------------------------------------

Eegtab_EEG_art_sumop = struct();

%-----------------------------Name the title----------------------------------------------
% global Eegtab_box_art_sumop;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    Eegtab_box_art_sumop = uiextras.BoxPanel('Parent', fig, 'Title', 'Artifact Info & Tools (Epoched EEG Only)',...
        'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    Eegtab_box_art_sumop = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Artifact Info & Tools (Epoched EEG Only)',...
        'Padding', 5,'BackgroundColor',ColorB_def);
else
    Eegtab_box_art_sumop = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Artifact Info & Tools (Epoched EEG Only)',...
        'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);%, 'HelpFcn', @sumart_help
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

drawui_art_sumop_eeg(FonsizeDefault)
varargout{1} = Eegtab_box_art_sumop;

    function drawui_art_sumop_eeg(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        Eegtab_EEG_art_sumop.DataSelBox = uiextras.VBox('Parent', Eegtab_box_art_sumop,'BackgroundColor',ColorB_def);
        
        if isempty(observe_EEGDAT.EEG)
            EnableFlag = 'off';
        else
            EnableFlag = 'on';
        end
        %%clear marks for artifact detection
        Eegtab_EEG_art_sumop.clear_art_det_title = uiextras.HBox('Parent', Eegtab_EEG_art_sumop.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  Eegtab_EEG_art_sumop.clear_art_det_title,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_sumop.clear_art_det = uicontrol('Style', 'pushbutton','Parent',Eegtab_EEG_art_sumop.clear_art_det_title,...
            'String','Clear artifact detection marks on EEG','callback',@clear_art_det,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent',  Eegtab_EEG_art_sumop.clear_art_det_title,'BackgroundColor',ColorB_def);
        set(Eegtab_EEG_art_sumop.clear_art_det_title, 'Sizes',[15 -1 15]);
        
        
        %%Syn. artifact info in EEG and EVENTLIST
        Eegtab_EEG_art_sumop.syn_arfinfo_title = uiextras.HBox('Parent', Eegtab_EEG_art_sumop.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Eegtab_EEG_art_sumop.syn_arfinfo_title,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_sumop.syn_arfinfo = uicontrol('Style', 'pushbutton','Parent',Eegtab_EEG_art_sumop.syn_arfinfo_title,...
            'String','Syn. artifact info in EEG and EVENTLIST','callback',@syn_arfinfo,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', Eegtab_EEG_art_sumop.syn_arfinfo_title,'BackgroundColor',ColorB_def);
        set(Eegtab_EEG_art_sumop.syn_arfinfo_title, 'Sizes',[15 -1 15]);
        
        
        %%Summarize EEG artifact in one value
        Eegtab_EEG_art_sumop.art_onevalue_title = uiextras.HBox('Parent', Eegtab_EEG_art_sumop.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Eegtab_EEG_art_sumop.art_onevalue_title,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_sumop.art_onevalue = uicontrol('Style', 'pushbutton','Parent',Eegtab_EEG_art_sumop.art_onevalue_title,...
            'String','Summarize EEG artifact in one value','callback',@art_onevalue,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', Eegtab_EEG_art_sumop.art_onevalue_title,'BackgroundColor',ColorB_def);
        set(Eegtab_EEG_art_sumop.art_onevalue_title, 'Sizes',[15 -1 15]);
        
        %%Summarize EEG artifact in a table
        Eegtab_EEG_art_sumop.art_table_title = uiextras.HBox('Parent', Eegtab_EEG_art_sumop.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Eegtab_EEG_art_sumop.art_table_title,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_sumop.art_table = uicontrol('Style', 'pushbutton','Parent',Eegtab_EEG_art_sumop.art_table_title,...
            'String','Summarize EEG artifact in a table','callback',@art_table,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', Eegtab_EEG_art_sumop.art_table_title,'BackgroundColor',ColorB_def);
        set(Eegtab_EEG_art_sumop.art_table_title, 'Sizes',[15 -1 15]);
        
        %%Summarize EEG artifact in a graphic
        Eegtab_EEG_art_sumop.art_graphic_title = uiextras.HBox('Parent', Eegtab_EEG_art_sumop.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Eegtab_EEG_art_sumop.art_graphic_title,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_sumop.art_graphic = uicontrol('Style', 'pushbutton','Parent',Eegtab_EEG_art_sumop.art_graphic_title,...
            'String','Summarize EEG artifact in a graphic','callback',@art_graphic,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', Eegtab_EEG_art_sumop.art_graphic_title,'BackgroundColor',ColorB_def);
        set(Eegtab_EEG_art_sumop.art_graphic_title, 'Sizes',[15 -1 15]);
        set(Eegtab_EEG_art_sumop.DataSelBox,'Sizes',[30 30 30 30 30]);
    end



%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%---------------------------help------------------------------------------
%     function sumart_help(~,~)
%         web('https://github.com/ucdavis/erplab/wiki/Manual/','-browser');
%     end

%%----------------clear artifact detection marks---------------------------
    function clear_art_det(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable = 'off';
            disp('Current dataset is empty or continuous EEG.');
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_EEG_proces_messg','Artifact Info & Tools (Epoched EEG Only) >  Clear artifact detection marks on EEG');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        %         try
        inputoption = resetrejGUI; % open GUI
        
        if isempty(inputoption)
%             disp('User selected Cancel')
            return
        end
        arjm  = inputoption{1};
        bflag = inputoption{2};
        
        if arjm==1
            arjmstr = 'on';
        else
            arjmstr = 'off';
        end
        
        [arflag usflag] = dec2flag(bflag);
        ALLEEG = observe_EEGDAT.ALLEEG;
        Answer = f_EEG_save_multi_file(ALLEEG,EEGArray,'_resetrej');
        if isempty(Answer)
            beep;
            %disp('User selected Cancel');
            return;
        end
        if ~isempty(Answer{1})
            ALLEEG_advance = Answer{1};
            Save_file_label = Answer{2};
        end
        
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG_advance(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Clear artifact detection marks on EEG*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            if EEG.trials==1
                erpworkingmemory('f_EEG_proces_messg','Artifact Info & Tools (Epoched EEG Only) >  Clear artifact detection marks on EEG: cannot work on a continuous EEG');
                observe_EEGDAT.eeg_panel_message =4;
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            [EEG, LASTCOM] = pop_resetrej(EEG, 'ResetArtifactFields', arjmstr, 'ArtifactFlag', arflag, 'UserFlag', usflag, 'History', 'implicit');
            if isempty(LASTCOM)
                disp('User selected cancel or errors occur.');
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            
            fprintf([LASTCOM,'\n']);
            EEG = eegh(LASTCOM, EEG);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            
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
            fprintf( [repmat('-',1,100) '\n']);
            if Numofeeg==1
                eegh(LASTCOM);
            end
        end%%end for loop of subjects
        observe_EEGDAT.ALLEEG =ALLEEG;
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


%%------------Syn. artifact info in EEG and EVENTLIST----------------------
    function syn_arfinfo(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable = 'off';
            disp('Current dataset is empty or continuous EEG.');
            return;
        end
        
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_EEG_proces_messg','Artifact Info & Tools (Epoched EEG Only) >  Syn. artifact info in EEG and EVENTLIST');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        %         try
        direction = synchroartifactsGUI;
        %     direction = 1; % erplab to eeglab synchro
        %     direction = 2; % eeglab to erplab synchro
        %     direction = 3; % both
        %     direction = 0; % none
        if isempty(direction)
            disp('User selected Cancel')
            return
        end
        if direction==1      % erplab to eeglab synchro
            dircom = 'erplab2eeglab';
        elseif direction==2  %eeglab to erplab synchro
            dircom = 'eeglab2erplab';
        elseif direction==3 % both
            dircom = 'bidirectional';
        else
            dircom = 'none';
        end
        ALLEEG = observe_EEGDAT.ALLEEG;
            Answer = f_EEG_save_multi_file(ALLEEG,EEGArray,'_synctrej');
        if isempty(Answer)
            beep;
            %disp('User selected Cancel');
            return;
        end
        if ~isempty(Answer{1})
            ALLEEG_advance = Answer{1};
            Save_file_label = Answer{2};
        end
        
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG_advance(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Syn. artifact info in EEG and EVENTLIST*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            if EEG.trials==1
                erpworkingmemory('f_EEG_proces_messg','Artifact Info & Tools (Epoched EEG Only) >  Syn. artifact info in EEG and EVENTLIST: cannot work on a continuous EEG');
                observe_EEGDAT.eeg_panel_message =4;
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            [EEG, LASTCOM] = pop_syncroartifacts(EEG, 'Direction', dircom, 'History', 'implicit');
            if isempty(LASTCOM)
%                 disp('User selected cancel');
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            
            fprintf([LASTCOM,'\n']);
            EEG = eegh(LASTCOM, EEG);
            if Numofeeg==1
                eegh(LASTCOM);
            end
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
            fprintf( [repmat('-',1,100) '\n']);
            if Numofeeg==1
                eegh(LASTCOM);
            end
        end%%end for loop of subjects
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


%%-----------------Summarize EEG artifact in one value---------------------
    function art_onevalue(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable = 'off';
            disp('Current dataset is empty or continuous EEG.');
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_EEG_proces_messg','Artifact Info & Tools (Epoched EEG Only) >  Summarize EEG artifact in one value');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        
        for Numofeeg = 1:numel(EEGArray)
            EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Summarize EEG artifact in one value*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            if EEG.trials==1
                erpworkingmemory('f_EEG_proces_messg','Artifact Info & Tools (Epoched EEG Only) >  Summarize EEG artifact in one value: cannot work on a continuous EEG');
                observe_EEGDAT.eeg_panel_message =4;
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            
            %%check if epochs were marked as artifacts
            histoflags = summary_rejectflags(EEG);
            %check currently activated flags
            flagcheck = sum(histoflags);
            active_flags = (flagcheck>1);
            
            if isempty(active_flags)
                erpworkingmemory('f_EEG_proces_messg','Artifact Info & Tools (Epoched EEG Only) >  Summarize EEG artifact in one value: None of epochs was marked');
                observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            
            [EEG, MPD, LASTCOM] = getardetection(EEG, 1);
            fprintf([LASTCOM,'\n']);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = eegh(LASTCOM, EEG);
            fprintf( [repmat('-',1,100) '\n']);
        end
        
        erpworkingmemory('f_EEG_proces_messg','Artifact Info & Tools (Epoched EEG Only) >  Summarize EEG artifact in one value');
        observe_EEGDAT.eeg_panel_message =2; %%Marking for the procedure has been started.
    end

%%-------------------Summarize EEG artifact in a table---------------------
    function art_table(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable = 'off';
            disp('Current dataset is empty or continuous EEG.');
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_EEG_proces_messg','Artifact Info & Tools (Epoched EEG Only) >  Summarize EEG artifact in a table');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        
        for Numofeeg = 1:numel(EEGArray)
            EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Summarize EEG artifact in a table*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            if EEG.trials==1
                erpworkingmemory('f_EEG_proces_messg','Artifact Info & Tools (Epoched EEG Only) >  Summarize EEG artifact in a table: cannot work on a continuous EEG');
                observe_EEGDAT.eeg_panel_message =4;
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            
            %%check if epochs were marked as artifacts
            histoflags = summary_rejectflags(EEG);
            %check currently activated flags
            flagcheck = sum(histoflags);
            active_flags = (flagcheck>1);
            
            if isempty(active_flags)
                erpworkingmemory('f_EEG_proces_messg','Artifact Info & Tools (Epoched EEG Only) >  Summarize EEG artifact in a table: None of epochs was marked');
                observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            
            [EEG, tprej, acce, rej, histoflags,LASTCOM ] = pop_summary_AR_eeg_detection(EEG);
            if isempty(LASTCOM)
                fprintf( [repmat('-',1,100) '\n']);
                observe_EEGDAT.eeg_panel_message =2;
                return;
            end
            observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = eegh(LASTCOM, EEG);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            fprintf( [repmat('-',1,100) '\n']);
        end
        
        erpworkingmemory('f_EEG_proces_messg','Artifact Info & Tools (Epoched EEG Only) >  Summarize EEG artifact in a table');
        observe_EEGDAT.eeg_panel_message =2; %%Marking for the procedure has been started.
    end

%%-------------------Summarize EEG artifact in a graphic-------------------
    function art_graphic(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable = 'off';
            disp('Current dataset is empty or continuous EEG.');
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_EEG_proces_messg','Artifact Info & Tools (Epoched EEG Only) >  Summarize EEG artifact in a graphic');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        
        for Numofeeg = 1:numel(EEGArray)
            EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Summarize EEG artifact in a graphic*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            if EEG.trials==1
                erpworkingmemory('f_EEG_proces_messg','Artifact Info & Tools (Epoched EEG Only) >  Summarize EEG artifact in a graphic: cannot work on a continuous EEG');
                observe_EEGDAT.eeg_panel_message =4;
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            
            %%check if epochs were marked as artifacts
            histoflags = summary_rejectflags(EEG);
            %check currently activated flags
            flagcheck = sum(histoflags);
            active_flags = (flagcheck>1);
            
            if isempty(active_flags)
                erpworkingmemory('f_EEG_proces_messg','Artifact Info & Tools (Epoched EEG Only) >  Summarize EEG artifact in a graphic: None of epochs was marked');
                observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            
            [EEG, goodbad, histeEF, histoflags,  LASTCOM] = pop_summary_rejectfields(EEG);
            fprintf([LASTCOM,'\n']);
            observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = eegh(LASTCOM, EEG);
            fprintf( [repmat('-',1,100) '\n']);
            if Numofeeg==1
                eegh(LASTCOM);
            end
        end
        erpworkingmemory('f_EEG_proces_messg','Artifact Info & Tools (Epoched EEG Only) >  Summarize EEG artifact in a graphic');
        observe_EEGDAT.eeg_panel_message =2; %%Marking for the procedure has been started.
    end


%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=19
            return;
        end
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Eegtab_EEG_art_sumop.clear_art_det.Enable = 'off';
            Eegtab_EEG_art_sumop.syn_arfinfo.Enable = 'off';
            Eegtab_EEG_art_sumop.art_interp.Enable = 'off';
            Eegtab_EEG_art_sumop.art_onevalue.Enable = 'off';
            Eegtab_EEG_art_sumop.art_table.Enable = 'off';
            Eegtab_EEG_art_sumop.art_graphic.Enable= 'off';
            if ~isempty(observe_EEGDAT.EEG) && observe_EEGDAT.EEG.trials ==1
                Eegtab_box_art_sumop.TitleColor= [0.7500    0.7500    0.75000];
            else
                Eegtab_box_art_sumop.TitleColor= [0.0500    0.2500    0.5000];
            end
            observe_EEGDAT.count_current_eeg=20;
            return;
        end
        
        Eegtab_box_art_sumop.TitleColor= [0.0500    0.2500    0.5000];
        Eegtab_EEG_art_sumop.clear_art_det.Enable = 'on';
        Eegtab_EEG_art_sumop.syn_arfinfo.Enable = 'on';
        Eegtab_EEG_art_sumop.art_interp.Enable = 'on';
        Eegtab_EEG_art_sumop.art_onevalue.Enable = 'on';
        Eegtab_EEG_art_sumop.art_table.Enable = 'on';
        Eegtab_EEG_art_sumop.art_graphic.Enable= 'on';
        observe_EEGDAT.count_current_eeg=20;
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