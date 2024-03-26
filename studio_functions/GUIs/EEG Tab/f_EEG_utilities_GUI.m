%%This function is for Utilities.


% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Mar. 2024


function varargout = f_EEG_utilities_GUI(varargin)

global observe_EEGDAT;
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);

%---------------------------Initialize parameters------------------------------------

Eegtab_utilities = struct();

%-----------------------------Name the title----------------------------------------------
% global Eegtab_box_art_sumop;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    Eegtab_box_art_sumop = uiextras.BoxPanel('Parent', fig, 'Title', 'EEG Utilities',...
        'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    Eegtab_box_art_sumop = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'EEG Utilities',...
        'Padding', 5,'BackgroundColor',ColorB_def);
else
    Eegtab_box_art_sumop = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'EEG Utilities',...
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
        Eegtab_utilities.DataSelBox = uiextras.VBox('Parent', Eegtab_box_art_sumop,'BackgroundColor',ColorB_def);
        
        if isempty(observe_EEGDAT.EEG)
            EnableFlag = 'off';
        else
            EnableFlag = 'on';
        end
        
        %%Convert to Continuous EEG
        Eegtab_utilities.epoch2continuous_title = uiextras.HBox('Parent', Eegtab_utilities.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Eegtab_utilities.epoch2continuous_title,'BackgroundColor',ColorB_def);
        Eegtab_utilities.epoch2continuous = uicontrol('Style', 'pushbutton','Parent',Eegtab_utilities.epoch2continuous_title,...
            'String','Convert to Continuous EEG','callback',@epoch2continuous,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', Eegtab_utilities.epoch2continuous_title,'BackgroundColor',ColorB_def);
        set(Eegtab_utilities.epoch2continuous_title, 'Sizes',[15 -1 15]);
        
        
        %%Erase undesired event codes
        Eegtab_utilities.rm_eventcodes_title = uiextras.HBox('Parent', Eegtab_utilities.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Eegtab_utilities.rm_eventcodes_title,'BackgroundColor',ColorB_def);
        Eegtab_utilities.rm_eventcodes = uicontrol('Style', 'pushbutton','Parent',Eegtab_utilities.rm_eventcodes_title,...
            'String','Erase Undesired Event Codes','callback',@rm_eventcodes,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', Eegtab_utilities.rm_eventcodes_title,'BackgroundColor',ColorB_def);
        set(Eegtab_utilities.rm_eventcodes_title, 'Sizes',[15 -1 15]);
        
        %%Recover bin descriptor file from EEG
        Eegtab_utilities.rc_bdf_title = uiextras.HBox('Parent', Eegtab_utilities.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Eegtab_utilities.rc_bdf_title,'BackgroundColor',ColorB_def);
        Eegtab_utilities.rc_bdf = uicontrol('Style', 'pushbutton','Parent',Eegtab_utilities.rc_bdf_title,...
            'String','Recover Bin Descriptor File from EEG','callback',@rc_bdf,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', Eegtab_utilities.rc_bdf_title,'BackgroundColor',ColorB_def);
        set(Eegtab_utilities.rc_bdf_title, 'Sizes',[15 -1 15]);
        
        %%Reset Event Code Bytes
        Eegtab_utilities.event_byte_title = uiextras.HBox('Parent', Eegtab_utilities.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Eegtab_utilities.event_byte_title,'BackgroundColor',ColorB_def);
        Eegtab_utilities.event_byte = uicontrol('Style', 'pushbutton','Parent',Eegtab_utilities.event_byte_title,...
            'String','Reset Event Code Bytes','callback',@event_byte,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', Eegtab_utilities.event_byte_title,'BackgroundColor',ColorB_def);
        set(Eegtab_utilities.event_byte_title, 'Sizes',[15 -1 15]);
        
        %%Delete Spurious Additional Responses
        Eegtab_utilities.rmerrors_title = uiextras.HBox('Parent', Eegtab_utilities.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Eegtab_utilities.rmerrors_title,'BackgroundColor',ColorB_def);
        Eegtab_utilities.rmerrors = uicontrol('Style', 'pushbutton','Parent',Eegtab_utilities.rmerrors_title,...
            'String','Delete Spurious Additional Responses','callback',@rmerrors,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', Eegtab_utilities.rmerrors_title,'BackgroundColor',ColorB_def);
        set(Eegtab_utilities.rmerrors_title, 'Sizes',[15 -1 15]);
        
        
        set(Eegtab_utilities.DataSelBox,'Sizes',[30 30 30 30 30]);
    end



%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%


%%------------Convert to Continuous EEG----------------------
    function epoch2continuous(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable = 'off';
            return;
        end
        
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_EEG_proces_messg','EEG Utilities >  Convert to Continuous EEG');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG) ) ||  any(EEGArray(:) <1)
            EEGArray = observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',EEGArray);
        end
        
        app = feval('estudio_epoch2contn_gui',[1]);
        waitfor(app,'Finishbutton',1);
        try
            RestoreEvent = app.output; %NO you don't want to output EEG with edited channel locations, you want to output the parameters to run decoding
            app.delete; %delete app from view
            pause(0.1); %wait for app to leave
        catch
            return;
        end
        if isempty(RestoreEvent)
            return;
        end
        
        if isempty(RestoreEvent) || numel(RestoreEvent)~=1 || (RestoreEvent~=0 && RestoreEvent~=1)
            RestoreEvent=1;
        end
        if RestoreEvent==1
            RestoreEventStr = 'on';
        else
            RestoreEventStr = 'off';
        end
        
        
        ALLEEG = observe_EEGDAT.ALLEEG;
        ALLEEG_out = [];
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Convert to Continuous EEG*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            if EEG.trials==1
                erroMessage= 'EEG Utilities >  Convert to Continuous EEG: cannot work on a continuous EEG';
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(erroMessage,titlNamerro);
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            setname = EEG.setname;
            [EEG, LASTCOM] = pop_epoch2continuous(EEG, 'RestoreEvent',RestoreEventStr, 'History', 'implicit');
            if isempty(LASTCOM)
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            EEG.setname = setname;
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
        Answer = f_EEG_save_multi_file(ALLEEG_out,1:numel(EEGArray),'_ep2con');
        if isempty(Answer)
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
        erpworkingmemory('Change2epocheeg',2);
        observe_EEGDAT.count_current_eeg=1;
        observe_EEGDAT.eeg_panel_message =2;
    end


%%-----------------Erase undesired event codes---------------------
    function rm_eventcodes(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable = 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_EEG_proces_messg','EEG Utilities >  Erase undesired event codes');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG)) ||  any(EEGArray(:) <1)
            EEGArray = observe_EEGDAT.CURRENTSET; estudioworkingmemory('EEGArray',EEGArray);
        end
        
        prompt    = {'expression (>, < ==, ~=):'};
        dlg_title = 'Input event-code condition to delete';
        num_lines = 1;
        def  = erpworkingmemory('pop_eraseventcodes');
        if isempty(def)
            def = {'>255'};
        end
        answer = inputvalue(prompt,dlg_title,num_lines,def);
        if isempty(answer)
            return
        end
        expression = answer{1};
        erpworkingmemory('pop_eraseventcodes', {expression});
        
        
        ALLEEG = observe_EEGDAT.ALLEEG;
        ALLEEG_out = [];
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Erase undesired event codes*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            if EEG.trials>1
                erroMessage= 'EEG Utilities >  Erase undesired event codes: cannot work on an epoched EEG';
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(erroMessage,titlNamerro);
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            
            if ~isfield(EEG(1), 'event')
                erroMessage= 'EEG Utilities >  Erase undesired event codes: did not find EEG.event field';
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(erroMessage,titlNamerro);
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            
            if ~isfield(EEG(1).event, 'type')
                erroMessage= 'EEG Utilities >  Erase undesired event codes: did not find EEG.event.type field';
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(erroMessage,titlNamerro);
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            
            if~isfield(EEG(1).event, 'latency')
                erroMessage= 'EEG Utilities >  Erase undesired event codes: did not find EEG.event.latency field';
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(erroMessage,titlNamerro);
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            
            if ischar(EEG(1).event(1).type)
                erroMessage= 'EEG Utilities >  Erase undesired event codes: only works with numeric event codes. We recommend to use Create EEG Eventlist - Basic first';
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(erroMessage,titlNamerro);
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            
            [EEG, LASTCOM] = pop_eraseventcodes( EEG, expression, 'History', 'implicit');
            
            fprintf([LASTCOM,'\n']);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            [ALLEEG_out,~,~,LASTCOM] = pop_newset(ALLEEG_out, EEG, length(ALLEEG_out), 'gui', 'off');
            if Numofeeg==1
                eegh(LASTCOM);
            end
            fprintf( [repmat('-',1,100) '\n']);
        end
        
        Answer = f_EEG_save_multi_file(ALLEEG_out,1:numel(EEGArray),'_delevents');
        if isempty(Answer)
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
        
        erpworkingmemory('f_EEG_proces_messg','EEG Utilities >  Erase undesired event codes');
        observe_EEGDAT.eeg_panel_message =2; %%Marking for the procedure has been started.
    end

%%-------------------Recover bin descriptor file from EEG---------------------
    function rc_bdf(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable = 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_EEG_proces_messg','EEG Utilities >  Recover bin descriptor file from EEG');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG)) ||  any(EEGArray(:) <1)
            EEGArray = observe_EEGDAT.CURRENTSET;estudioworkingmemory('EEGArray',EEGArray);
        end
        
        for Numofeeg = 1:numel(EEGArray)
            EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Recover bin descriptor file from EEG*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            
            [EEG, LASTCOM] = pop_bdfrecovery(EEG);
            
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
        
        erpworkingmemory('f_EEG_proces_messg','EEG Utilities >  Recover bin descriptor file from EEG');
        observe_EEGDAT.eeg_panel_message =2; %%Marking for the procedure has been started.
    end

%%-------------------Reset Event Code Bytes-------------------
    function event_byte(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable = 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_EEG_proces_messg','EEG Utilities >  Reset Event Code Bytes');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG)) ||  any(EEGArray(:) <1)
            EEGArray = observe_EEGDAT.CURRENTSET;estudioworkingmemory('EEGArray',EEGArray);
        end
        %%call GUI to set parameters
        answer = setcodebitGUI;
        if isempty(answer)
            return
        end
        newvalue2 = 0;
        todo =  answer{1};
        if strcmpi(todo, 'all')
            bitindex = 1:16;
            newvalue = 0;
        elseif strcmpi(todo, 'lower')
            bitindex = 1:8;
            newvalue = 0;
        elseif strcmpi(todo, 'upper')
            bitindex = 9:16;
            newvalue = 0;
        else
            if ~isempty(answer{2})
                bitindex = answer{2};
                newvalue = 0;
            end
            if ~isempty(answer{3})
                bitindex1 = answer{3};
                newvalue2 = 1;
            end
        end
        
        ALLEEG_out = [];
        ALLEEG = observe_EEGDAT.ALLEEG;
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Reset Event Code Bytes*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            if EEG.trials==1
                erroMessage= 'EEG Utilities >  Reset Event Code Bytes: cannot work on a continuous EEG';
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(erroMessage,titlNamerro);
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            
            [EEG, LASTCOM ] = pop_setcodebit(EEG, bitindex, newvalue, 'History', 'off');
            if newvalue2==1
                [EEG, LASTCOM ] = pop_setcodebit(EEG, bitindex1, newvalue1, 'History', 'off');
            end
            fprintf([LASTCOM,'\n']);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            [ALLEEG_out,~,~,LASTCOM] = pop_newset(ALLEEG_out, EEG, length(ALLEEG_out), 'gui', 'off');
            fprintf( [repmat('-',1,100) '\n']);
        end
        
        Answer = f_EEG_save_multi_file(ALLEEG_out,1:numel(EEGArray),'_resetbyte');
        if isempty(Answer)
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
        
        erpworkingmemory('f_EEG_proces_messg','EEG Utilities >  Reset Event Code Bytes');
        observe_EEGDAT.eeg_panel_message =2; %%Marking for the procedure has been started.
    end

%%------------------Delete Spurious Additional Responses-------------------
    function rmerrors(Source,~)
        if  isempty(observe_EEGDAT.EEG)
            Source.Enable = 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_EEG_proces_messg','EEG Utilities > Delete Spurious Additional Responses');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG)) ||  any(EEGArray(:) <1)
            EEGArray = observe_EEGDAT.CURRENTSET;estudioworkingmemory('EEGArray',EEGArray);
        end
        [stim_codes, stim_codes] = gui_remove_response_mistakes(observe_EEGDAT.EEG);
        if isempty(stim_codes) && isempty(stim_codes)
            observe_EEGDAT.eeg_panel_message =2; %%Marking for the procedure has been started.
            return;
        end
        
        try
            stim_codes = eval(num2str(stim_codes)); %if numeric
        catch
            stim_codes = regexp(stim_codes,'(?<=\d)\s(?=\d)|,\s*','split'); %remove commas if exist
            stim_codes = stim_codes(~cellfun('isempty',stim_codes));
        end
        need_to_flat = 0;
        for ec = 1:length(stim_codes)
            try
                temp_nums = num2cell(eval(num2str(stim_codes{ec}))); %evaluate & flatten any numeric expression
                stim_codes{ec} = cellfun(@num2str,temp_nums,'UniformOutput',false); %change to string
                need_to_flat = 1;
            catch
            end
        end
        if need_to_flat == 1
            stim_codes =[stim_codes{:}];
            for ii = 1:length(stim_codes)
                stim_codes1(ii) = str2num(stim_codes{ii});
            end
            stim_codes = unique(stim_codes1);
        end
        stim_codes = (stim_codes);
        
        
        if isempty(stim_codes)
            msgboxText = ['EEG Utilities > Delete Spurious Additional Responses: Some of Stimulus event types are invalid'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        evT = struct2table(observe_EEGDAT.EEG.event);
        all_ev = evT.type;
        all_ev_unique = unique(all_ev);
        try
            all_ev_unique(isnan(all_ev_unique)) = [];
        catch
        end
        
        try
            [IA1,stim_codes] = f_check_eventcodes(stim_codes,all_ev_unique);
        catch
            IA1 = 0;
        end
        if IA1==0
            msgboxText = ['EEG Utilities > Delete Spurious Additional Responses: Some of Stimulus event types are invalid'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        %%Response event types
        try
            resp_codes = eval(num2str(resp_codes)); %if numeric
        catch
            resp_codes = regexp(resp_codes,'(?<=\d)\s(?=\d)|,\s*','split'); %remove commas if exist
            resp_codes = resp_codes(~cellfun('isempty',resp_codes));
        end
        need_to_flat = 0;
        for ec = 1:length(resp_codes)
            try
                temp_nums = num2cell(eval(num2str(resp_codes{ec}))); %evaluate & flatten any numeric expression
                resp_codes{ec} = cellfun(@num2str,temp_nums,'UniformOutput',false); %change to string
                need_to_flat = 1;
            catch
            end
        end
        if need_to_flat == 1
            resp_codes =[resp_codes{:}];
            for ii = 1:length(resp_codes)
                resp_codes1(ii) = str2num(resp_codes{ii});
            end
            resp_codes = unique(resp_codes1);
        end
        resp_codes = (resp_codes);
        
        if isempty(resp_codes)
            msgboxText = ['EEG Utilities > Delete Spurious Additional Responses: Some of Response event types are invalid'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        try
            [IA2,resp_codes] = f_check_eventcodes(resp_codes,all_ev_unique);
        catch
            IA2 = 0;
        end
        
        if IA2==0
            msgboxText = ['EEG Utilities > Delete Spurious Additional Responses: Some of Response event types are invalid'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        ALLEEG = observe_EEGDAT.ALLEEG;
        ALLEEG_out = [];
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Delete Spurious Additional Responses (Continuous EEG) > Run*',32,32,32,32,datestr(datetime('now')),'\n']);
            
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            if ischar(EEG.event(1).type)
                ec_type_is_str = 0;
            else
                ec_type_is_str = 1;
            end
            evT = struct2table(EEG.event);
            
            all_ev = evT.type;
            all_ev_unique = unique(all_ev);
            try
                all_ev_unique(isnan(all_ev_unique)) = [];
            catch
            end
            try
                [IA1,stim_codes] = f_check_eventcodes(stim_codes,all_ev_unique);
            catch
                IA1 = 0;
            end
            if IA1==0
                msgboxText = ['EEG Utilities > Delete Spurious Additional Responses: Some of Stimulus event types are invalid'];
                erpworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            try
                [IA2,resp_codes] = f_check_eventcodes(resp_codes,all_ev_unique);
            catch
                IA2 = 0;
            end
            
            if IA2==0
                msgboxText = ['EEG Utilities > Delete Spurious Additional Responses: Some of Response event types are invalid'];
                fprintf( [repmat('-',1,100) '\n']);
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            
            [~,EEG, LASTCOM] = pop_remove_response_mistakes(ALLEEG,EEG,EEGArray(Numofeeg),stim_codes,resp_codes);
            if isempty(LASTCOM)
                return;
            end
            if Numofeeg==1
                eegh(LASTCOM);
            end
            fprintf([LASTCOM,'\n']);
            EEG = eegh(LASTCOM, EEG);
            
            [ALLEEG_out,~,~,LASTCOM] = pop_newset(ALLEEG_out, EEG, length(ALLEEG_out), 'gui', 'off');
            fprintf( [repmat('-',1,100) '\n']);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            
        end%%end for loop of subjects
        Save_file_label = 0;
        Answer = f_EEG_save_multi_file(ALLEEG_out,1:numel(EEGArray),'_rmerr');
        if isempty(Answer)
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




%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=25
            return;
        end
        EEGUpdate = erpworkingmemory('EEGUpdate');
        if isempty(EEGUpdate) || numel(EEGUpdate)~=1 || (EEGUpdate~=0 && EEGUpdate~=1)
            EEGUpdate = 0;  erpworkingmemory('EEGUpdate',0);
        end
        if  isempty(observe_EEGDAT.EEG) || EEGUpdate==1
            Eegtab_utilities.epoch2continuous.Enable = 'off';
            Eegtab_utilities.event_byte.Enable = 'off';
            Eegtab_utilities.rm_eventcodes.Enable = 'off';
            Eegtab_utilities.rc_bdf.Enable = 'off';
            Eegtab_utilities.rmerrors.Enable = 'off';
            observe_EEGDAT.count_current_eeg=26;
            return;
        end
        if observe_EEGDAT.EEG.trials>1
            Eegtab_utilities.epoch2continuous.Enable = 'on';
            Eegtab_utilities.rmerrors.Enable = 'off';
        else
            Eegtab_utilities.epoch2continuous.Enable = 'off';
            Eegtab_utilities.rmerrors.Enable = 'on';
        end
        
        if observe_EEGDAT.EEG.trials==1
            Eegtab_utilities.rm_eventcodes.Enable = 'on';
            Eegtab_utilities.event_byte.Enable = 'on';
        else
            Eegtab_utilities.rm_eventcodes.Enable = 'off';
            Eegtab_utilities.event_byte.Enable = 'off';
        end
        Eegtab_utilities.rc_bdf.Enable = 'on';
        observe_EEGDAT.count_current_eeg=26;
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