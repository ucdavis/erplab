%%This function is to detect and summarize artifact for epoched EEG.


% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Sep. 2023


function varargout = f_EEG_arf_det_sum_GUI(varargin)

global observe_EEGDAT;
% addlistener(observe_EEGDAT,'eeg_panel_change_message',@eeg_panel_change_message);
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);

%---------------------------Initialize parameters------------------------------------

Eegtab_EEG_art_det_sum = struct();

%-----------------------------Name the title----------------------------------------------
% global Eegtab_box_art_det_sum;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    Eegtab_box_art_det_sum = uiextras.BoxPanel('Parent', fig, 'Title', 'Artifact Detection & Summarization', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    Eegtab_box_art_det_sum = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Artifact Detection & Summarization', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    Eegtab_box_art_det_sum = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Artifact Detection & Summarization', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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

drawui_art_det_sum_eeg(FonsizeDefault)
varargout{1} = Eegtab_box_art_det_sum;

    function drawui_art_det_sum_eeg(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        Eegtab_EEG_art_det_sum.DataSelBox = uiextras.VBox('Parent', Eegtab_box_art_det_sum,'BackgroundColor',ColorB_def);
        
        if isempty(observe_EEGDAT.EEG)
            EnableFlag = 'off';
        else
            EnableFlag = 'on';
        end
        %%display original data?
        Eegtab_EEG_art_det_sum.art_det_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_sum.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent',Eegtab_EEG_art_det_sum.art_det_title,...
            'String','Dete. Algorithms','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_sum.det_algo = uicontrol('Style', 'popupmenu','Parent',Eegtab_EEG_art_det_sum.art_det_title,...
            'String','','callback',@det_algo,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        Det_algostr = {'Simple voltage threshold','Moving window peak-to-peak threshold',...
            'Blink rejection (alpha version)','Step-like artifacts',...
            'Sample to sample voltage threshold','Rate of change-time derivative (alpha version)',...
            'Blocking & flat line'};
        Eegtab_EEG_art_det_sum.det_algo.String = Det_algostr;
        Eegtab_EEG_art_det_sum.det_algo.Value =1;
        set(Eegtab_EEG_art_det_sum.art_det_title, 'Sizes',[100 -1]);
        
        %%clear marks for artifact detection
        Eegtab_EEG_art_det_sum.clear_art_det_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_sum.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  Eegtab_EEG_art_det_sum.clear_art_det_title,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_sum.clear_art_det = uicontrol('Style', 'pushbutton','Parent',Eegtab_EEG_art_det_sum.clear_art_det_title,...
            'String','Clear artifact detection marks on EEG','callback',@clear_art_det,'FontSize',FonsizeDefault,'Enable',EnableFlag);
        uiextras.Empty('Parent',  Eegtab_EEG_art_det_sum.clear_art_det_title,'BackgroundColor',ColorB_def);
        set(Eegtab_EEG_art_det_sum.clear_art_det_title, 'Sizes',[15 -1 15]);
        
        
        %%Syn. artifact info in EEG and EVENTLIST
        Eegtab_EEG_art_det_sum.syn_arfinfo_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_sum.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Eegtab_EEG_art_det_sum.syn_arfinfo_title,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_sum.syn_arfinfo = uicontrol('Style', 'pushbutton','Parent',Eegtab_EEG_art_det_sum.syn_arfinfo_title,...
            'String','Syn. artifact info in EEG and EVENTLIST','callback',@syn_arfinfo,'FontSize',FonsizeDefault,'Enable',EnableFlag);
        uiextras.Empty('Parent', Eegtab_EEG_art_det_sum.syn_arfinfo_title,'BackgroundColor',ColorB_def);
        set(Eegtab_EEG_art_det_sum.syn_arfinfo_title, 'Sizes',[15 -1 15]);
        
        %%Post Artifact Dection Epoch Interpolation
        Eegtab_EEG_art_det_sum.art_interp_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_sum.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Eegtab_EEG_art_det_sum.art_interp_title,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_sum.art_interp = uicontrol('Style', 'pushbutton','Parent',Eegtab_EEG_art_det_sum.art_interp_title,...
            'String','Post artifact dection epoch interpolation','callback',@art_interp,'FontSize',FonsizeDefault,'Enable',EnableFlag);
        uiextras.Empty('Parent', Eegtab_EEG_art_det_sum.art_interp_title,'BackgroundColor',ColorB_def);
        set(Eegtab_EEG_art_det_sum.art_interp_title, 'Sizes',[15 -1 15]);
        
        
        %%Summarize EEG artifact in one value
        Eegtab_EEG_art_det_sum.art_onevalue_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_sum.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Eegtab_EEG_art_det_sum.art_onevalue_title,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_sum.art_onevalue = uicontrol('Style', 'pushbutton','Parent',Eegtab_EEG_art_det_sum.art_onevalue_title,...
            'String','Summarize EEG artifact in one value','callback',@art_onevalue,'FontSize',FonsizeDefault,'Enable',EnableFlag);
        uiextras.Empty('Parent', Eegtab_EEG_art_det_sum.art_onevalue_title,'BackgroundColor',ColorB_def);
        set(Eegtab_EEG_art_det_sum.art_onevalue_title, 'Sizes',[15 -1 15]);
        
        %%Summarize EEG artifact in a table
        Eegtab_EEG_art_det_sum.art_table_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_sum.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Eegtab_EEG_art_det_sum.art_table_title,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_sum.art_table = uicontrol('Style', 'pushbutton','Parent',Eegtab_EEG_art_det_sum.art_table_title,...
            'String','Summarize EEG artifact in a table','callback',@art_table,'FontSize',FonsizeDefault,'Enable',EnableFlag);
        uiextras.Empty('Parent', Eegtab_EEG_art_det_sum.art_table_title,'BackgroundColor',ColorB_def);
        set(Eegtab_EEG_art_det_sum.art_table_title, 'Sizes',[15 -1 15]);
        
        %%Summarize EEG artifact in a graphic
        Eegtab_EEG_art_det_sum.art_graphic_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_sum.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Eegtab_EEG_art_det_sum.art_graphic_title,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_sum.art_graphic = uicontrol('Style', 'pushbutton','Parent',Eegtab_EEG_art_det_sum.art_graphic_title,...
            'String','Summarize EEG artifact in a graphic','callback',@art_graphic,'FontSize',FonsizeDefault,'Enable',EnableFlag);
        uiextras.Empty('Parent', Eegtab_EEG_art_det_sum.art_graphic_title,'BackgroundColor',ColorB_def);
        set(Eegtab_EEG_art_det_sum.art_graphic_title, 'Sizes',[15 -1 15]);
        
        set(Eegtab_EEG_art_det_sum.DataSelBox,'Sizes',[25 30 30 30 30 30 30]);
    end



%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%


%%-------------------Artifact detection algorithms-------------------------
    function det_algo(Source,~)
        
        
        
        
    end

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
        
        erpworkingmemory('f_EEG_proces_messg','Artifact detection & summarizartion >  Clear artifact detection marks on EEG');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        try
            inputoption = resetrejGUI; % open GUI
            
            if isempty(inputoption)
                disp('User selected Cancel')
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
            
            for Numofeeg = 1:numel(EEGArray)
                EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['*Clear artifact detection marks on EEG*',32,32,32,32,datestr(datetime('now')),'\n']);
                fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
                if EEG.trials==1
                    erpworkingmemory('f_EEG_proces_messg','Artifact detection & summarizartion >  Clear artifact detection marks on EEG: cannot work on a continuous EEG');
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
                
                Answer = f_EEG_save_single_file(char(strcat(EEG.setname,'_resetrej')),EEG.filename,EEGArray(Numofeeg));
                if isempty(Answer)
                    disp('User selected cancel.');
                    fprintf( [repmat('-',1,100) '\n']);
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
                [observe_EEGDAT.ALLEEG EEG CURRENTSET] = pop_newset(observe_EEGDAT.ALLEEG, EEG, length(observe_EEGDAT.ALLEEG), 'gui', 'off');
                fprintf( [repmat('-',1,100) '\n']);
                
            end%%end for loop of subjects
            
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
        catch
            observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_panel_message =3;%%There is errros in processing procedure
            fprintf( [repmat('-',1,100) '\n']);
            return;
        end
        
        
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
        
        erpworkingmemory('f_EEG_proces_messg','Artifact detection & summarizartion >  Syn. artifact info in EEG and EVENTLIST');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        try
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
            for Numofeeg = 1:numel(EEGArray)
                EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['*Syn. artifact info in EEG and EVENTLIST*',32,32,32,32,datestr(datetime('now')),'\n']);
                fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
                if EEG.trials==1
                    erpworkingmemory('f_EEG_proces_messg','Artifact detection & summarizartion >  Syn. artifact info in EEG and EVENTLIST: cannot work on a continuous EEG');
                    observe_EEGDAT.eeg_panel_message =4;
                    fprintf( [repmat('-',1,100) '\n']);
                    return;
                end
                [EEG, LASTCOM] = pop_syncroartifacts(EEG, 'Direction', dircom, 'History', 'implicit');
                if isempty(LASTCOM)
                    disp('User selected cancel or errors occur.');
                    fprintf( [repmat('-',1,100) '\n']);
                    return;
                end
                
                fprintf([LASTCOM,'\n']);
                EEG = eegh(LASTCOM, EEG);
                
                Answer = f_EEG_save_single_file(char(strcat(EEG.setname,'_synctrej')),EEG.filename,EEGArray(Numofeeg));
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
                [observe_EEGDAT.ALLEEG EEG CURRENTSET] = pop_newset(observe_EEGDAT.ALLEEG, EEG, length(observe_EEGDAT.ALLEEG), 'gui', 'off');
                fprintf( [repmat('-',1,100) '\n']);
                
            end%%end for loop of subjects
            
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
        catch
            observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_panel_message =3;%%There is errros in processing procedure
            fprintf( [repmat('-',1,100) '\n']);
            return;
        end
        
    end

%%----------------Post Artifact Dection Epoch Interpolation----------------
    function art_interp(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable = 'off';
            disp('Current dataset is empty or continuous EEG.');
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_EEG_proces_messg','Artifact detection & summarizartion >  Post artifact dection epoch interpolation');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        %         try
        
        for Numofeeg = 1:numel(EEGArray)
            EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Post artifact dection epoch interpolation*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            if EEG.trials==1
                erpworkingmemory('f_EEG_proces_messg','Artifact detection & summarizartion >  Post artifact dection epoch interpolation: cannot work on a continuous EEG');
                observe_EEGDAT.eeg_panel_message =4;
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            
            histoflags = summary_rejectflags(EEG);
            %check currently activated flags
            flagcheck = sum(histoflags);
            active_flags = (flagcheck>1);
            
            if isempty(active_flags)
                erpworkingmemory('f_EEG_proces_messg','Artifact detection & summarizartion >  Post artifact dection epoch interpolation: None of epochs was marked');
                observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            
            
            %%---------Call GUI for setting parameters-----------------
            dlg_title = {['Dataset',32,num2str(EEGArray(Numofeeg)),32,': Interpolate Flagged Artifact Epochs']};
            
            %defaults
            defx = {0, 'spherical',[],[],[],0,10};
            
            def = erpworkingmemory('pop_artinterp');
            
            if isempty(def)
                def = defx;
            else
                %make sure that electrode number exists in current list of
                %available channels
                %def{1} = def{1}(ismember_bc2(def{1},1:EEG(1).nbchan));
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
            answer = artifactinterpGUI(dlg_title, def, defx, chanlabels, active_flags);
            
            if isempty(answer)
                disp('User selected cancel.');
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            
            replaceFlag =  answer{1};
            interpolationMethod      =  answer{2};
            replaceChannelInd     =  answer{3};
            replaceChannelLabel     =  answer{4};
            ignoreChannels  =  unique_bc2(answer{5}); % avoids repeted channels
            many_electrodes = answer{6};
            threshold_perc = answer{7};
            
            viewstr = 'off';
            if ~isempty(find(replaceFlag<1 | replaceFlag>16, 1))
                disp( 'ERROR, flag cannot be greater than 16 nor lesser than 1');
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            erpworkingmemory('pop_artinterp', {answer{1} answer{2} answer{3} answer{4} answer{5} ...
                answer{6}, answer{7}});
            
            % Somersault
            %
            [EEG, LASTCOM] = pop_artinterp(EEG, 'FlagToUse', replaceFlag, 'InterpMethod', interpolationMethod, ...
                'ChanToInterp', replaceChannelInd, 'ChansToIgnore', ignoreChannels, ...
                'InterpAnyChan', many_electrodes, 'Threshold',threshold_perc,...
                'Review', viewstr, 'History', 'implicit');
            
            
            if isempty(LASTCOM)
                disp('User selected cancel or errors occur.');
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            
            fprintf([LASTCOM,'\n']);
            EEG = eegh(LASTCOM, EEG);
            
            Answer = f_EEG_save_single_file(char(strcat(EEG.setname,'_arInterp')),EEG.filename,EEGArray(Numofeeg));
            if isempty(Answer)
                disp('User selected cancel.');
                fprintf( [repmat('-',1,100) '\n']);
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
            [observe_EEGDAT.ALLEEG EEG CURRENTSET] = pop_newset(observe_EEGDAT.ALLEEG, EEG, length(observe_EEGDAT.ALLEEG), 'gui', 'off');
            fprintf( [repmat('-',1,100) '\n']);
            
        end%%end for loop of subjects
        
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
        %         catch
        %             observe_EEGDAT.count_current_eeg=1;
        %             observe_EEGDAT.eeg_panel_message =3;%%There is errros in processing procedure
        %             fprintf( [repmat('-',1,100) '\n']);
        %             return;
        %         end
        
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
        
        erpworkingmemory('f_EEG_proces_messg','Artifact detection & summarizartion >  Summarize EEG artifact in one value');
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
                erpworkingmemory('f_EEG_proces_messg','Artifact detection & summarizartion >  Summarize EEG artifact in one value: cannot work on a continuous EEG');
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
                erpworkingmemory('f_EEG_proces_messg','Artifact detection & summarizartion >  Summarize EEG artifact in one value: None of epochs was marked');
                observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            
            
            [EEG, MPD, LASTCOM] = getardetection(EEG, 1);
            fprintf([LASTCOM,'\n']);
            observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = eegh(LASTCOM, EEG);
            fprintf( [repmat('-',1,100) '\n']);
        end
        
        erpworkingmemory('f_EEG_proces_messg','Artifact detection & summarizartion >  Summarize EEG artifact in one value');
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
        
        erpworkingmemory('f_EEG_proces_messg','Artifact detection & summarizartion >  Summarize EEG artifact in a table');
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
                erpworkingmemory('f_EEG_proces_messg','Artifact detection & summarizartion >  Summarize EEG artifact in a table: cannot work on a continuous EEG');
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
                erpworkingmemory('f_EEG_proces_messg','Artifact detection & summarizartion >  Summarize EEG artifact in a table: None of epochs was marked');
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
            fprintf( [repmat('-',1,100) '\n']);
        end
        
        erpworkingmemory('f_EEG_proces_messg','Artifact detection & summarizartion >  Summarize EEG artifact in a table');
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
        
        erpworkingmemory('f_EEG_proces_messg','Artifact detection & summarizartion >  Summarize EEG artifact in a graphic');
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
                erpworkingmemory('f_EEG_proces_messg','Artifact detection & summarizartion >  Summarize EEG artifact in a graphic: cannot work on a continuous EEG');
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
                erpworkingmemory('f_EEG_proces_messg','Artifact detection & summarizartion >  Summarize EEG artifact in a graphic: None of epochs was marked');
                observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            
            
            [EEG, goodbad, histeEF, histoflags,  LASTCOM] = pop_summary_rejectfields(EEG);
            fprintf([LASTCOM,'\n']);
            observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = eegh(LASTCOM, EEG);
            fprintf( [repmat('-',1,100) '\n']);
        end
        erpworkingmemory('f_EEG_proces_messg','Artifact detection & summarizartion >  Summarize EEG artifact in a graphic');
        observe_EEGDAT.eeg_panel_message =2; %%Marking for the procedure has been started.
    end


%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Eegtab_EEG_art_det_sum.det_algo.Enable= 'off';
            Eegtab_EEG_art_det_sum.clear_art_det.Enable = 'off';
            Eegtab_EEG_art_det_sum.syn_arfinfo.Enable = 'off';
            Eegtab_EEG_art_det_sum.art_interp.Enable = 'off';
            Eegtab_EEG_art_det_sum.art_onevalue.Enable = 'off';
            Eegtab_EEG_art_det_sum.art_table.Enable = 'off';
            Eegtab_EEG_art_det_sum.art_graphic.Enable= 'off';
            return;
        end
        
        if observe_EEGDAT.count_current_eeg ~=12
            return;
        end
        Eegtab_EEG_art_det_sum.det_algo.Enable= 'on';
        Eegtab_EEG_art_det_sum.clear_art_det.Enable = 'on';
        Eegtab_EEG_art_det_sum.syn_arfinfo.Enable = 'on';
        Eegtab_EEG_art_det_sum.art_interp.Enable = 'on';
        Eegtab_EEG_art_det_sum.art_onevalue.Enable = 'on';
        Eegtab_EEG_art_det_sum.art_table.Enable = 'on';
        Eegtab_EEG_art_det_sum.art_graphic.Enable= 'on';
        observe_EEGDAT.count_current_eeg=13;
    end

%%-------------------------------------------------------------------------
%%Automatically saving the changed parameters for the current panel if the
%%user change parameters for the other panels.
%%-------------------------------------------------------------------------
%     function eeg_two_panels_change(~,~)
%         if observe_EEGDAT.eeg_two_panels==0
%             return;
%         end
%         ChangeFlag =  estudioworkingmemory('EEGTab_event2bin');
%         if ChangeFlag~=1
%             return;
%         end
%         eeg_bdf_apply();
%         estudioworkingmemory('EEGTab_event2bin',0);
%         Eegtab_EEG_art_det_sum.bdf_apply.BackgroundColor =  [1 1 1];
%         Eegtab_EEG_art_det_sum.bdf_apply.ForegroundColor = [0 0 0];
%         Eegtab_box_art_det_sum.TitleColor= [0.0500    0.2500    0.5000];
%         Eegtab_EEG_art_det_sum.bdf_cancel.BackgroundColor =  [1 1 1];
%         Eegtab_EEG_art_det_sum.bdf_cancel.ForegroundColor = [0 0 0];
%     end


end