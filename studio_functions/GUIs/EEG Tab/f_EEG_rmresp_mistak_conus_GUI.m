%%This function is to remove response mistakes for continuous EEG.


% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Oct. 2023


function varargout = f_EEG_rmresp_mistak_conus_GUI(varargin)

global observe_EEGDAT;
% addlistener(observe_EEGDAT,'eeg_panel_change_message',@eeg_panel_change_message);
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);

%---------------------------Initialize parameters------------------------------------
EEG_rmresp_mistak_conus = struct();
%-----------------------------Name the title----------------------------------------------

% global Eegtab_box_rmresp_mistak_conus;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    Eegtab_box_rmresp_mistak_conus = uiextras.BoxPanel('Parent', fig, 'Title', 'Remove Response Mistakes for Continuous EEG', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    Eegtab_box_rmresp_mistak_conus = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Remove Response Mistakes for Continuous EEG', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    Eegtab_box_rmresp_mistak_conus = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Remove Response Mistakes for Continuous EEG', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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

drawui_shift_eventcode_conus_eeg(FonsizeDefault)
varargout{1} = Eegtab_box_rmresp_mistak_conus;

    function drawui_shift_eventcode_conus_eeg(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        EEG_rmresp_mistak_conus.DataSelBox = uiextras.VBox('Parent', Eegtab_box_rmresp_mistak_conus,'BackgroundColor',ColorB_def);
        FontSize_defualt = FonsizeDefault;
        if isempty(FontSize_defualt)
            FontSize_defualt = 12;
        end
        if isempty(observe_EEGDAT.EEG)
            EnableFlag = 'off';
        else
            EnableFlag = 'on';
        end
        
        EEG_rmresp_mistak_conus.stimulusall_title = uiextras.HBox('Parent', EEG_rmresp_mistak_conus.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_rmresp_mistak_conus.stimulusall = uitable(  ...
            'Parent'        , EEG_rmresp_mistak_conus.stimulusall_title,...
            'Data'          , '', ...
            'ColumnName'    , [], ...
            'RowName'       , []);
        set(EEG_rmresp_mistak_conus.stimulusall,'ColumnEditable',false(1,1000),'FontSize',FontSize_defualt,'Enable',EnableFlag);
        %%"Stimulus" event types
        EEG_rmresp_mistak_conus.chan_title = uiextras.HBox('Parent', EEG_rmresp_mistak_conus.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',EEG_rmresp_mistak_conus.chan_title,'HorizontalAlignment','left',...
            'String','"Stimulus" event types:','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        EEG_rmresp_mistak_conus.Stimulus_edit = uicontrol('Style','edit','Parent',EEG_rmresp_mistak_conus.chan_title,...
            'String','','FontSize',FontSize_defualt,'callback',@Stimulus_edit,'Enable',EnableFlag,'BackgroundColor',[1 1 1]); % 2F
        EEG_rmresp_mistak_conus.Stimulus_edit.KeyPressFcn=  @eeg_shiftcodes_presskey;
        
        set( EEG_rmresp_mistak_conus.chan_title,'Sizes',[140 -1]);
        
        
        %%"Response" event types
        EEG_rmresp_mistak_conus.voltage_title = uiextras.HBox('Parent', EEG_rmresp_mistak_conus.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_rmresp_mistak_conus.voltage_text = uicontrol('Style','text','Parent',EEG_rmresp_mistak_conus.voltage_title,'HorizontalAlignment','left',...
            'String',['"Response" event types:'],'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'BackgroundColor',ColorB_def); % 2F
        EEG_rmresp_mistak_conus.response_edit = uicontrol('Style','edit','Parent',EEG_rmresp_mistak_conus.voltage_title,...
            'callback',@response_edit,'String','','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag,'BackgroundColor',[1 1 1]); % 2F
        EEG_rmresp_mistak_conus.response_edit.KeyPressFcn=  @eeg_shiftcodes_presskey;
        
        set(EEG_rmresp_mistak_conus.voltage_title,'Sizes',[140,-1]);
        
        %%-----------------------Cancel and Run----------------------------
        EEG_rmresp_mistak_conus.detar_run_title = uiextras.HBox('Parent', EEG_rmresp_mistak_conus.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  EEG_rmresp_mistak_conus.detar_run_title,'BackgroundColor',ColorB_def);
        EEG_rmresp_mistak_conus.rmresp_mistake_cancel = uicontrol('Style', 'pushbutton','Parent',EEG_rmresp_mistak_conus.detar_run_title,...
            'String','Cancel','callback',@rmresp_mistake_cancel,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent',  EEG_rmresp_mistak_conus.detar_run_title,'BackgroundColor',ColorB_def);
        EEG_rmresp_mistak_conus.rmresp_mistake_run = uicontrol('Style','pushbutton','Parent',EEG_rmresp_mistak_conus.detar_run_title,...
            'String','Apply','callback',@rmresp_mistake_run,'FontSize',FontSize_defualt,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent',  EEG_rmresp_mistak_conus.detar_run_title,'BackgroundColor',ColorB_def);
        set(EEG_rmresp_mistak_conus.detar_run_title,'Sizes',[15 105  30 105 15]);
        
        set(EEG_rmresp_mistak_conus.DataSelBox,'Sizes',[70 30 30 30]);
        estudioworkingmemory('EEGTab_rmresposmistak_conus',0);
    end


%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%


%%----------------------edit chans-----------------------------------------
    function Stimulus_edit(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_rmresp_mistak_conus.TitleColor= [0.5137    0.7569    0.9176];
        EEG_rmresp_mistak_conus.rmresp_mistake_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_rmresp_mistak_conus.rmresp_mistake_cancel.ForegroundColor = [1 1 1];
        EEG_rmresp_mistak_conus.rmresp_mistake_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_rmresp_mistak_conus.rmresp_mistake_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_rmresposmistak_conus',1);
        
        stim_codes = Source.String;
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
            erpworkingmemory('f_EEG_proces_messg',['Remove Response Mistakes for Continuous EEG > Some of inputs for "Stimulus" event types are invalid']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String ='';
            return;
        end
        
        all_ev_unique= EEG_rmresp_mistak_conus.all_ev_unique;
        IA2 = 0;
        try
            IA2 = f_check_eventcodes(stim_codes,all_ev_unique);
        catch
            IA2 = 0;
        end
        
        if IA2==0
            erpworkingmemory('f_EEG_proces_messg',['Remove Response Mistakes for Continuous EEG > Some of inputs for "Stimulus" event types are invalid']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String ='';
        else
            %             Source.String =stim_codes;
        end
    end


%%-----------------------------volatge-------------------------------------
    function response_edit(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_rmresp_mistak_conus.TitleColor= [0.5137    0.7569    0.9176];
        EEG_rmresp_mistak_conus.rmresp_mistake_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_rmresp_mistak_conus.rmresp_mistake_cancel.ForegroundColor = [1 1 1];
        EEG_rmresp_mistak_conus.rmresp_mistake_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_rmresp_mistak_conus.rmresp_mistake_run.ForegroundColor = [1 1 1];
        
        estudioworkingmemory('EEGTab_rmresposmistak_conus',1);
        
        
        repsd_codes = Source.String;
        try
            repsd_codes = eval(num2str(repsd_codes)); %if numeric
        catch
            repsd_codes = regexp(repsd_codes,'(?<=\d)\s(?=\d)|,\s*','split'); %remove commas if exist
            repsd_codes = repsd_codes(~cellfun('isempty',repsd_codes));
        end
        need_to_flat = 0;
        for ec = 1:length(repsd_codes)
            try
                temp_nums = num2cell(eval(num2str(repsd_codes{ec}))); %evaluate & flatten any numeric expression
                repsd_codes{ec} = cellfun(@num2str,temp_nums,'UniformOutput',false); %change to string
                need_to_flat = 1;
            catch
            end
        end
        if need_to_flat == 1
            repsd_codes =[repsd_codes{:}];
            for ii = 1:length(repsd_codes)
                repsd_codes1(ii) = str2num(repsd_codes{ii});
            end
            repsd_codes = unique(repsd_codes1);
        end
        repsd_codes = (repsd_codes);
        if isempty(repsd_codes)
            erpworkingmemory('f_EEG_proces_messg',['Remove Response Mistakes for Continuous EEG > Some of inputs for "Response" event types are invalid']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String ='';
        end
        
        all_ev_unique= EEG_rmresp_mistak_conus.all_ev_unique;
        try
            IA2 = f_check_eventcodes(repsd_codes,all_ev_unique);
        catch
            IA2 = 0;
        end
        if IA2==0
            erpworkingmemory('f_EEG_proces_messg',['Remove Response Mistakes for Continuous EEG > Some of inputs for "Response" event types are invalid']);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String ='';
        else
            %             Source.String =repsd_codes;
        end
        
    end

%%%----------------------Preview-------------------------------------------
    function rmresp_mistake_cancel(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','Remove Response Mistakes for Continuous EEG > Cancel');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        Eegtab_box_rmresp_mistak_conus.TitleColor= [0.0500    0.2500    0.5000];
        EEG_rmresp_mistak_conus.rmresp_mistake_cancel.BackgroundColor =  [1 1 1];
        EEG_rmresp_mistak_conus.rmresp_mistake_cancel.ForegroundColor = [0 0 0];
        EEG_rmresp_mistak_conus.rmresp_mistake_run.BackgroundColor =  [ 1 1 1];
        EEG_rmresp_mistak_conus.rmresp_mistake_run.ForegroundColor = [0 0 0];
        
        estudioworkingmemory('EEGTab_rmresposmistak_conus',0);
        EEG_rmresp_mistak_conus.Stimulus_edit.String = '';
        EEG_rmresp_mistak_conus.response_edit.String = '';
        observe_EEGDAT.eeg_panel_message =2;
    end


%%-----------------------Shift events--------------------------------------
    function rmresp_mistake_run(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','Remove Response Mistakes for Continuous EEG > Apply');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        Eegtab_box_rmresp_mistak_conus.TitleColor= [0.0500    0.2500    0.5000];
        EEG_rmresp_mistak_conus.rmresp_mistake_cancel.BackgroundColor =  [1 1 1];
        EEG_rmresp_mistak_conus.rmresp_mistake_cancel.ForegroundColor = [0 0 0];
        EEG_rmresp_mistak_conus.rmresp_mistake_run.BackgroundColor =  [ 1 1 1];
        EEG_rmresp_mistak_conus.rmresp_mistake_run.ForegroundColor = [0 0 0];
        
        estudioworkingmemory('EEGTab_rmresposmistak_conus',0);
        %%--------Selected EEGsets-----------
        EEGArray= estudioworkingmemory('EEGArray');
        if isempty(EEGArray) || min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) || max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG)
            EEGArray = observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',EEGArray);
        end
        %%Stimulus event types
        stim_codes =  EEG_rmresp_mistak_conus.Stimulus_edit.String;
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
            erpworkingmemory('f_EEG_proces_messg','Remove Response Mistakes for Continuous EEG > Apply: Some of Stimulus event types are invalid');
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            return;
        end
        
        all_ev_unique= EEG_rmresp_mistak_conus.all_ev_unique;
        try
            [IA1,stim_codes] = f_check_eventcodes(stim_codes,all_ev_unique);
        catch
            IA1 = 0;
        end
        if IA1==0
            erpworkingmemory('f_EEG_proces_messg','Remove Response Mistakes for Continuous EEG > Apply: Some of Stimulus event types are invalid');
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            return;
        end
        
        %%Response event types
        resp_codes =  EEG_rmresp_mistak_conus.response_edit.String;
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
            erpworkingmemory('f_EEG_proces_messg','Remove Response Mistakes for Continuous EEG > Apply: Some of Response event types are invalid');
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            return;
        end
        try
            [IA2,resp_codes] = f_check_eventcodes(resp_codes,all_ev_unique);
        catch
            IA2 = 0;
        end
        
        if IA2==0
            erpworkingmemory('f_EEG_proces_messg','Remove Response Mistakes for Continuous EEG > Apply: Some of Response event types are invalid');
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            return;
        end
        
        
        try
            ALLEEG = observe_EEGDAT.ALLEEG;
            for Numofeeg = 1:numel(EEGArray)
                EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['*Remove Response Mistakes for Continuous EEG > Run*',32,32,32,32,datestr(datetime('now')),'\n']);
                
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
                    erpworkingmemory('f_EEG_proces_messg','Remove Response Mistakes for Continuous EEG > Apply: Some of Stimulus event types are invalid');
                    observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
                    fprintf( [repmat('-',1,100) '\n']);
                    return;
                end
                try
                    [IA2,resp_codes] = f_check_eventcodes(resp_codes,all_ev_unique);
                catch
                    IA2 = 0;
                end
                
                if IA2==0
                    erpworkingmemory('f_EEG_proces_messg','Remove Response Mistakes for Continuous EEG > Apply: Some of Response event types are invalid');
                    observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
                    fprintf( [repmat('-',1,100) '\n']);
                    return;
                end
                
                [~,EEG, LASTCOM] = pop_remove_response_mistakes(ALLEEG,EEG,EEGArray(Numofeeg),stim_codes,resp_codes);
                
                if isempty(LASTCOM)
                    disp('User selected cancel or errors occur.');
                    fprintf( [repmat('-',1,100) '\n']);
                    return;
                end
                
                fprintf([LASTCOM,'\n']);
                EEG = eegh(LASTCOM, EEG);
                
                Answer = f_EEG_save_single_file(char(strcat(EEG.setname,'_shift')),EEG.filename,EEGArray(Numofeeg));
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


%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            EEG_rmresp_mistak_conus.stimulusall.Enable= 'off';
            EEG_rmresp_mistak_conus.Stimulus_edit.Enable= 'off';
            EEG_rmresp_mistak_conus.response_edit.Enable= 'off';
            EEG_rmresp_mistak_conus.rmresp_mistake_run.Enable= 'off';
            EEG_rmresp_mistak_conus.rmresp_mistake_cancel.Enable= 'off';
            
            if observe_EEGDAT.count_current_eeg ~=18
                return;
            else
                if observe_EEGDAT.EEG.trials ~=1
                    observe_EEGDAT.count_current_eeg=19;
                end
            end
            return;
        end
        if observe_EEGDAT.count_current_eeg ~=18
            return;
        end
        
        EEG_rmresp_mistak_conus.Stimulus_edit.Enable= 'on';
        EEG_rmresp_mistak_conus.response_edit.Enable= 'on';
        EEG_rmresp_mistak_conus.rmresp_mistake_run.Enable= 'on';
        EEG_rmresp_mistak_conus.rmresp_mistake_cancel.Enable= 'on';
        EEG_rmresp_mistak_conus.rmresp_mistake_cancel.String = 'Cancel';
        EEG_rmresp_mistak_conus.stimulusall.Enable= 'on';
        EEG = observe_EEGDAT.EEG;
        
        % Check numeric or string type
        if ischar(EEG.event(1).type)
            ec_type_is_str = 0;
        else
            ec_type_is_str = 1;
        end
        evT = struct2table(EEG.event);
        %         if ec_type_is_str
        %             all_ev = str2double(evT.type);
        %         else
        all_ev = evT.type;
        %         end
        
        all_ev_unique = unique(all_ev);
        try
            all_ev_unique(isnan(all_ev_unique)) = [];
        catch
        end
        for ii = 1:length(all_ev_unique)
            ColumnNameStr{ii} = ['Ev.',32,num2str(ii)];
        end
        EEG_rmresp_mistak_conus.stimulusall.Data = all_ev_unique';
        EEG_rmresp_mistak_conus.stimulusall.ColumnName = ColumnNameStr;
        EEG_rmresp_mistak_conus.stimulusall.RowName = 'Ev. Names';
        EEG_rmresp_mistak_conus.all_ev_unique = all_ev_unique;
        observe_EEGDAT.count_current_eeg=19;
    end


%%--------------press return to execute "Apply"----------------------------
    function eeg_shiftcodes_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('EEGTab_rmresposmistak_conus');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress, 'enter')
            rmresp_mistake_run();
            estudioworkingmemory('EEGTab_rmresposmistak_conus',0);
            Eegtab_box_rmresp_mistak_conus.TitleColor= [0.0500    0.2500    0.5000];
            EEG_rmresp_mistak_conus.rmresp_mistake_cancel.BackgroundColor =  [1 1 1];
            EEG_rmresp_mistak_conus.rmresp_mistake_cancel.ForegroundColor = [0 0 0];
            EEG_rmresp_mistak_conus.rmresp_mistake_run.BackgroundColor =  [ 1 1 1];
            EEG_rmresp_mistak_conus.rmresp_mistake_run.ForegroundColor = [0 0 0];
        else
            return;
        end
    end


%%-------------------Auomatically execute "apply"--------------------------
    function eeg_two_panels_change(~,~)
        if  isempty(observe_EEGDAT.EEG)
            return;
        end
        ChangeFlag =  estudioworkingmemory('EEGTab_rmresposmistak_conus');
        if ChangeFlag~=1
            return;
        end
        rmresp_mistake_run();
        estudioworkingmemory('EEGTab_rmresposmistak_conus',0);
        Eegtab_box_rmresp_mistak_conus.TitleColor= [0.0500    0.2500    0.5000];
        EEG_rmresp_mistak_conus.rmresp_mistake_cancel.BackgroundColor =  [1 1 1];
        EEG_rmresp_mistak_conus.rmresp_mistake_cancel.ForegroundColor = [0 0 0];
        EEG_rmresp_mistak_conus.rmresp_mistake_run.BackgroundColor =  [ 1 1 1];
        EEG_rmresp_mistak_conus.rmresp_mistake_run.ForegroundColor = [0 0 0];
    end


%%--------------------------------check event codes------------------------
    function [IA,resp_codes]= f_check_eventcodes(resp_codes,all_ev_unique)
        IA = 0;
        for ii = 1:length(resp_codes)
            for kk = 1:length(all_ev_unique)
                if isnumeric(resp_codes(ii)) && isnumeric(all_ev_unique(kk))
                    if resp_codes(ii) == all_ev_unique(kk)
                        IA = IA +1;
                    end
                elseif (ischar(resp_codes(ii)) || iscell(resp_codes(ii)) )&& (ischar(all_ev_unique(kk)) || iscell(all_ev_unique(kk)) )
                    try
                        stim_codesstr=erase(resp_codes{ii}," ");
                        all_ev_uniquestr= erase(all_ev_unique{kk}, " ");
                    catch
                        stim_codesstr=resp_codes{ii};
                        all_ev_uniquestr= all_ev_unique{kk};
                    end
                    if strcmpi(stim_codesstr,all_ev_uniquestr)
                        resp_codes{ii} = all_ev_unique{kk};
                        IA = IA +1;
                    end
                end
            end
        end
    end

end