%%This function is to detect and summarize artifact for epoched EEG.


% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Sep. 2023


function varargout = f_EEG_arf_sumop_GUI(varargin)

global observe_EEGDAT;
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);

%---------------------------Initialize parameters------------------------------------

Eegtab_EEG_art_sumop = struct();

%-----------------------------Name the title----------------------------------------------
% global Eegtab_box_art_sumop;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    Eegtab_box_art_sumop = uiextras.BoxPanel('Parent', fig, 'Title', 'Artifact Info & Tools (Epoched EEG)',...
        'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    Eegtab_box_art_sumop = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Artifact Info & Tools (Epoched EEG)',...
        'Padding', 5,'BackgroundColor',ColorB_def);
else
    Eegtab_box_art_sumop = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Artifact Info & Tools (Epoched EEG)',...
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
        set(Eegtab_EEG_art_sumop.clear_art_det_title, 'Sizes',[13 -1 13]);
        
        
        %%Sync artifact info in EEG and EVENTLIST
        Eegtab_EEG_art_sumop.syn_arfinfo_title = uiextras.HBox('Parent', Eegtab_EEG_art_sumop.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Eegtab_EEG_art_sumop.syn_arfinfo_title,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_sumop.syn_arfinfo = uicontrol('Style', 'pushbutton','Parent',Eegtab_EEG_art_sumop.syn_arfinfo_title,...
            'String','Sync artifact info in EEG and EVENTLIST','callback',@syn_arfinfo,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', Eegtab_EEG_art_sumop.syn_arfinfo_title,'BackgroundColor',ColorB_def);
        set(Eegtab_EEG_art_sumop.syn_arfinfo_title, 'Sizes',[13 -1 13]);
        
        
        %%Classic Artifact Summary
        Eegtab_EEG_art_sumop.Classic_ar_sum_title = uiextras.HBox('Parent', Eegtab_EEG_art_sumop.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Eegtab_EEG_art_sumop.Classic_ar_sum_title,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_sumop.Classic_ar_sum = uicontrol('Style', 'pushbutton','Parent',Eegtab_EEG_art_sumop.Classic_ar_sum_title,...
            'String','Classic Artifact Summary','callback',@Classic_ar_sum,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', Eegtab_EEG_art_sumop.Classic_ar_sum_title,'BackgroundColor',ColorB_def);
        set(Eegtab_EEG_art_sumop.Classic_ar_sum_title, 'Sizes',[13 -1 13]);
        
        %%Summarize EEG artifact in a table
        Eegtab_EEG_art_sumop.total_reject_ops_title = uiextras.HBox('Parent', Eegtab_EEG_art_sumop.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Eegtab_EEG_art_sumop.total_reject_ops_title,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_sumop.total_reject_ops = uicontrol('Style', 'pushbutton','Parent',Eegtab_EEG_art_sumop.total_reject_ops_title,...
            'String','Artifact Summary','callback',@total_reject_ops,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', Eegtab_EEG_art_sumop.total_reject_ops_title,'BackgroundColor',ColorB_def);
        set(Eegtab_EEG_art_sumop.total_reject_ops_title, 'Sizes',[13 -1 13]);
        
        set(Eegtab_EEG_art_sumop.DataSelBox,'Sizes',[30 30 30 30]);
    end



%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%----------------clear artifact detection marks---------------------------
    function clear_art_det(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable = 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('f_EEG_proces_messg','Artifact Info & Tools (Epoched EEG) >  Clear artifact detection marks on EEG');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG)) ||  any(EEGArray(:) <1)
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        inputoption = resetrejGUI; % open GUI
        if isempty(inputoption)
            observe_EEGDAT.eeg_panel_message =2;
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
        ALLEEG_out = [];
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Clear artifact detection marks on EEG*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n']);
            if EEG.trials==1
                erroMessage= 'Artifact Info & Tools (Epoched EEG) >  Clear artifact detection marks on EEG: cannot work on a continuous EEG';
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(erroMessage,titlNamerro);
                fprintf( [repmat('-',1,100) '\n']);
                observe_EEGDAT.eeg_panel_message =2;
                return;
            end
            [EEG, LASTCOM] = pop_resetrej(EEG, 'ResetArtifactFields', arjmstr, 'ArtifactFlag', arflag, 'UserFlag', usflag, 'History', 'implicit');
            if isempty(LASTCOM)
                fprintf( [repmat('-',1,100) '\n']);
                observe_EEGDAT.eeg_panel_message =2;
                return;
            end
            fprintf([LASTCOM,'\n']);
            EEG = eegh(LASTCOM, EEG);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            
            [ALLEEG_out,~,~,LASTCOM] = pop_newset(ALLEEG_out, EEG, length(ALLEEG_out), 'gui', 'off');
            fprintf( [repmat('-',1,100) '\n']);
            if Numofeeg==1
                eegh(LASTCOM);
            end
        end%%end for loop of subjects
        Answer = f_EEG_save_multi_file(ALLEEG_out,1:numel(EEGArray),'_resetrej');
        if isempty(Answer)
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        if ~isempty(Answer{1})
            ALLEEG_out = Answer{1};
            Save_file_label = Answer{2};
        end
        for Numofeeg =  1:numel(EEGArray)
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


%%------------Sync artifact info in EEG and EVENTLIST----------------------
    function syn_arfinfo(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable = 'off';
            return;
        end
        
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('f_EEG_proces_messg','Artifact Info & Tools (Epoched EEG) >  Sync artifact info in EEG and EVENTLIST');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG) ) ||  any(EEGArray(:) <1)
            EEGArray = observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',EEGArray);
        end
        direction = synchroartifactsGUI;
        if isempty(direction)
            observe_EEGDAT.eeg_panel_message =2;
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
        ALLEEG_out = [];
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Sync artifact info in EEG and EVENTLIST*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n']);
            if EEG.trials==1
                erroMessage= 'Artifact Info & Tools (Epoched EEG) >  Sync artifact info in EEG and EVENTLIST: cannot work on a continuous EEG';
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(erroMessage,titlNamerro);
                fprintf( [repmat('-',1,100) '\n']);
                observe_EEGDAT.eeg_panel_message =2;
                return;
            end
            [EEG, LASTCOM] = pop_syncroartifacts(EEG, 'Direction', dircom, 'History', 'implicit');
            if isempty(LASTCOM)
                fprintf( [repmat('-',1,100) '\n']);
                observe_EEGDAT.eeg_panel_message =2;
                return;
            end
            
            fprintf([LASTCOM,'\n']);
            EEG = eegh(LASTCOM, EEG);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            [ALLEEG_out,~,~,LASTCOM] = pop_newset(ALLEEG_out, EEG, length(ALLEEG_out), 'gui', 'off');
            fprintf( [repmat('-',1,100) '\n']);
            if Numofeeg==1
                eegh(LASTCOM);
            end
        end%%end for loop of subjects
        Answer = f_EEG_save_multi_file(ALLEEG_out,1:numel(EEGArray),'_synctrej');
        if isempty(Answer)
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        if ~isempty(Answer{1})
            ALLEEG_out = Answer{1};
            Save_file_label = Answer{2};
        end
        for Numofeeg =  1:numel(EEGArray)
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


%%-----------------Classic Artifact Summary---------------------
    function Classic_ar_sum(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable = 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        if ~isfield(observe_EEGDAT.EEG,'EVENTLIST') || isempty(observe_EEGDAT.EEG.EVENTLIST)
            msgboxText=['Artifact Info & Tools (Epoched EEG)>Classic Artifact Summary: Please check "EVENTLIST" for current EEG data and you may create it before further analysis.'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        
        estudioworkingmemory('f_EEG_proces_messg','Artifact Info & Tools (Epoched EEG) >  Classic Artifact Summary');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG)) ||  any(EEGArray(:) <1)
            EEGArray = observe_EEGDAT.CURRENTSET; estudioworkingmemory('EEGArray',EEGArray);
        end
        app = feval('estudio_classic_ar_summary_gui',[1 0 0]);
        waitfor(app,'Finishbutton',1);
        try
            New_pos1 = app.output; %NO you don't want to output EEG with edited channel locations, you want to output the parameters to run decoding
            app.delete; %delete app from view
            pause(0.01); %wait for app to leave
        catch
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        if isempty(New_pos1)
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        
        for Numofeeg = 1:numel(EEGArray)
            EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
            if ~isfield(EEG,'EVENTLIST') || isempty(EEG.EVENTLIST)
                msgboxText=['Artifact Info & Tools (Epoched EEG)>Classic Artifact Summary: Please check "EVENTLIST" for',32,EEG.setname, 32,'and you may create it before further analysis.'];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                observe_EEGDAT.eeg_panel_message =2;
                return;
            end
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            if New_pos1(1)==1
                fprintf(['*Classic Artifact Summary>Summarize EEG artifact in a graphic*',32,32,32,32,datestr(datetime('now')),'\n']);
            elseif New_pos1(2)==1
                fprintf(['*Classic Artifact Summary>Summarize EEG artifact in a table*',32,32,32,32,datestr(datetime('now')),'\n']);
            elseif New_pos1(3)==1
                fprintf(['*Classic Artifact Summary>Summarize EEG artifact in a graphic*',32,32,32,32,datestr(datetime('now')),'\n']);
            end
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            if EEG.trials==1
                erroMessage= 'Artifact Info & Tools (Epoched EEG) >  Classic Artifact Summary: cannot work on a continuous EEG';
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(erroMessage,titlNamerro);
                fprintf( [repmat('-',1,100) '\n']);
                observe_EEGDAT.eeg_panel_message =2;
                return;
            end
            if New_pos1(1)==1
                %%check if epochs were marked as artifacts
                histoflags = summary_rejectflags(EEG);
                %check currently activated flags
                flagcheck = sum(histoflags);
                active_flags = (flagcheck>1);
                if isempty(active_flags)
                    erroMessage= 'Artifact Info & Tools (Epoched EEG) >  Classic Artifact Summary: None of epochs was marked';
                    titlNamerro = 'Warning for EEG Tab';
                    estudio_warning(erroMessage,titlNamerro);
                    fprintf( [repmat('-',1,100) '\n']);
                    observe_EEGDAT.eeg_panel_message =2;
                    return;
                end
                [EEG, MPD, LASTCOM] = getardetection(EEG, 1);
            elseif New_pos1(2)==1
                %%check if epochs were marked as artifacts
                histoflags = summary_rejectflags(EEG);
                %check currently activated flags
                flagcheck = sum(histoflags);
                active_flags = (flagcheck>1);
                if isempty(active_flags)
                    erroMessage= 'Artifact Info & Tools (Epoched EEG) >  Summarize EEG artifact in a table: None of epochs was marked';
                    titlNamerro = 'Warning for EEG Tab';
                    estudio_warning(erroMessage,titlNamerro);
                    fprintf( [repmat('-',1,100) '\n']);
                    observe_EEGDAT.eeg_panel_message =2;
                    return;
                end
                [EEG, tprej, acce, rej, histoflags,LASTCOM ] = pop_summary_AR_eeg_detection(EEG);
                if isempty(LASTCOM)
                    fprintf( ['\n',repmat('-',1,100) '\n']);
                    observe_EEGDAT.eeg_panel_message =2;
                    return;
                end
            elseif New_pos1(3)==1
                %%check if epochs were marked as artifacts
                histoflags = summary_rejectflags(EEG);
                %check currently activated flags
                flagcheck = sum(histoflags);
                active_flags = (flagcheck>1);
                
                if isempty(active_flags)
                    erroMessage = 'Artifact Info & Tools (Epoched EEG) >  Summarize EEG artifact in a graphic: None of epochs was marked';
                    titlNamerro = 'Warning for EEG Tab';
                    estudio_warning(erroMessage,titlNamerro);
                    fprintf( [repmat('-',1,100) '\n']);
                    return;
                end
                [EEG, goodbad, histeEF, histoflags,  LASTCOM] = pop_summary_rejectfields(EEG);
            end
            if  New_pos1(2)~=1
                fprintf([LASTCOM,'\n']);
                fprintf( [repmat('-',1,100) '\n']);
            end
            observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = eegh(LASTCOM, EEG);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            
        end
        
        estudioworkingmemory('f_EEG_proces_messg','Artifact Info & Tools (Epoched EEG) >  Classic Artifact Summary');
        observe_EEGDAT.eeg_panel_message =2; %%Marking for the procedure has been started.
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
        observe_EEGDAT.count_current_eeg=26;
    end


%%----------------Rejection option----------------------------------------
    function total_reject_ops(~,~)
        if isempty(observe_EEGDAT.ALLEEG) || isempty(observe_EEGDAT.EEG)
            return;
        end
        %%--------Selected EEGsets-----------
        EEGArray= estudioworkingmemory('EEGArray');
        if isempty(EEGArray) || any(EEGArray(:) > length(observe_EEGDAT.ALLEEG))
            EEGArray = observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',EEGArray);
        end
        
        if ~isfield(observe_EEGDAT.EEG,'EVENTLIST') || isempty(observe_EEGDAT.EEG.EVENTLIST)
            msgboxText=['Artifact Info & Tools (Epoched EEG)>Artifact Summary: Please check "EVENTLIST" for current EEG data and you may create it before further analysis.'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        
        ALLEEG =  observe_EEGDAT.ALLEEG;
        LASTCOM = pop_eeg_ar_summary(ALLEEG,EEGArray);
        if isempty(LASTCOM)
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        fprintf( ['\n',repmat('-',1,100) '\n']);
        fprintf(['*Artifact Info & Tools (Epoched EEG)>Artifact Summary*',32,32,32,32,datestr(datetime('now')),'\n']);
        fprintf(LASTCOM);
        fprintf( ['\n',repmat('-',1,100) '\n']);
        for NumofEEG = 1:numel(EEGArray)
            observe_EEGDAT.ALLEEG(EEGArray(NumofEEG)) = eegh(LASTCOM,observe_EEGDAT.ALLEEG(EEGArray(NumofEEG)));
            if NumofEEG==1
                eegh(LASTCOM);
            end
        end
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
        observe_EEGDAT.count_current_eeg=26;%%to history panel
    end

%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=20
            return;
        end
        EEGUpdate = estudioworkingmemory('EEGUpdate');
        if isempty(EEGUpdate) || numel(EEGUpdate)~=1 || (EEGUpdate~=0 && EEGUpdate~=1)
            EEGUpdate = 0;  estudioworkingmemory('EEGUpdate',0);
        end
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1 || EEGUpdate==1
            Eegtab_EEG_art_sumop.clear_art_det.Enable = 'off';
            Eegtab_EEG_art_sumop.syn_arfinfo.Enable = 'off';
            Eegtab_EEG_art_sumop.art_interp.Enable = 'off';
            Eegtab_EEG_art_sumop.Classic_ar_sum.Enable = 'off';
            Eegtab_EEG_art_sumop.total_reject_ops.Enable = 'off';
            if ~isempty(observe_EEGDAT.EEG) && observe_EEGDAT.EEG.trials ==1
                Eegtab_box_art_sumop.TitleColor= [0.7500    0.7500    0.75000];
            else
                Eegtab_box_art_sumop.TitleColor= [0.0500    0.2500    0.5000];
            end
            observe_EEGDAT.count_current_eeg=21;
            return;
        end
        
        Eegtab_box_art_sumop.TitleColor= [0.0500    0.2500    0.5000];
        Eegtab_EEG_art_sumop.clear_art_det.Enable = 'on';
        Eegtab_EEG_art_sumop.syn_arfinfo.Enable = 'on';
        Eegtab_EEG_art_sumop.art_interp.Enable = 'on';
        Eegtab_EEG_art_sumop.Classic_ar_sum.Enable = 'on';
        Eegtab_EEG_art_sumop.total_reject_ops.Enable = 'on';
        observe_EEGDAT.count_current_eeg=21;
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