%%This function is to compute Spectral Data Quality for Continuous EEG.


% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Oct. 2023


function varargout = f_EEG_dq_fre_conus_GUI(varargin)

global observe_EEGDAT;
% addlistener(observe_EEGDAT,'eeg_panel_change_message',@eeg_panel_change_message);
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);

%---------------------------Initialize parameters------------------------------------
EEG_dq_fre_conus = struct();
%-----------------------------Name the title----------------------------------------------

% global Eegtab_box_dq_fre_conus;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    Eegtab_box_dq_fre_conus = uiextras.BoxPanel('Parent', fig, 'Title', 'Spectral Data Quality for Continuous EEG', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    Eegtab_box_dq_fre_conus = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Spectral Data Quality for Continuous EEG', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    Eegtab_box_dq_fre_conus = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Spectral Data Quality for Continuous EEG', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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

drawui_dq_fre_conus_eeg(FonsizeDefault)
varargout{1} = Eegtab_box_dq_fre_conus;

    function drawui_dq_fre_conus_eeg(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        EEG_dq_fre_conus.DataSelBox = uiextras.VBox('Parent', Eegtab_box_dq_fre_conus,'BackgroundColor',ColorB_def);
        FontSize_defualt = FonsizeDefault;
        if isempty(FontSize_defualt)
            FontSize_defualt = 12;
        end
        if isempty(observe_EEGDAT.EEG)
            EnableFlag = 'off';
        else
            EnableFlag = 'on';
        end
        
        def_labels = {'delta','theta','alpha','beta','gamma','50hz-noise','60hz-noise','broadband'}; %defaults
        def_bands = [0 3;3 8;8 12;8 30;30 48;49 51;59 61;0 256]; %default bands
        
        defx = {[] def_bands def_labels'};
        def  = erpworkingmemory('pop_continuousFFT');
        
        if isempty(def)
            def = defx;
        end
        try
            fqband      = def{2};
            fqlabels    = def{3};
        catch
            fqband     =  [0 3;3 8;8 12;8 30;30 48;49 51;59 61; 0 fqnyq]; %defaults
            fqlabels = {'delta','theta','alpha','beta','gamma','50hz-noise','60hz-noise','broadband'};
        end
        data_tab = [fqlabels num2cell(fqband)];
        
        %%Event codes
        EEG_dq_fre_conus.chan_title = uiextras.HBox('Parent', EEG_dq_fre_conus.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',EEG_dq_fre_conus.chan_title,'HorizontalAlignment','left',...
            'String','Chans:','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        EEG_dq_fre_conus.chans_edit = uicontrol('Style','edit','Parent',EEG_dq_fre_conus.chan_title,...
            'String','','FontSize',FontSize_defualt,'callback',@chans_edit,'Enable',EnableFlag,'BackgroundColor',[1 1 1]); % 2F
        EEG_dq_fre_conus.chans_edit.KeyPressFcn=  @eeg_shiftcodes_presskey;
        EEG_dq_fre_conus.chans_browse = uicontrol('Style','pushbutton','Parent',EEG_dq_fre_conus.chan_title,...
            'String','Browse','FontSize',FontSize_defualt,'callback',@chans_browse,'Enable',EnableFlag,'BackgroundColor',[1 1 1]); % 2F
        set( EEG_dq_fre_conus.chan_title,'Sizes',[60 -1,60]);
        
        EEG_dq_fre_conus.bandtable_title = uiextras.HBox('Parent', EEG_dq_fre_conus.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_dq_fre_conus.bandtable = uitable(  ...
            'Parent'        , EEG_dq_fre_conus.bandtable_title,...
            'Data'          , data_tab, ...
            'ColumnName'    , {'Lable','Low Hz','High Hz'});
        EEG_dq_fre_conus.bandtable.CellSelectionCallback = @selectedrow;
        EEG_dq_fre_conus.sel_row = size(EEG_dq_fre_conus.bandtable.Data,1); % set to max on load
        EEG_dq_fre_conus.bandtable.ColumnEditable = [true,true,true];
        EEG_dq_fre_conus.bandtable.CellEditCallback = @checkcellchanged;
        EEG_dq_fre_conus.bandtable.Enable = 'off';
        %%Round to later time sample
        EEG_dq_fre_conus.eventcode_title = uiextras.HBox('Parent', EEG_dq_fre_conus.DataSelBox,'BackgroundColor',ColorB_def);
        EEG_dq_fre_conus.add_rows = uicontrol('Style','pushbutton','Parent',EEG_dq_fre_conus.eventcode_title,'HorizontalAlignment','left',...
            'callback',@add_rows,'String','+Add a row ','FontSize',FontSize_defualt,'BackgroundColor',[1 1 1],'Enable',EnableFlag); % 2F
        EEG_dq_fre_conus.remove_rows = uicontrol('Style','pushbutton','Parent',EEG_dq_fre_conus.eventcode_title,'HorizontalAlignment','left',...
            'callback',@remove_rows,'String','-Remove selected rows','FontSize',FontSize_defualt,'BackgroundColor',[1 1 1],'Enable',EnableFlag); % 2F
        EEG_dq_fre_conus.resetable = uicontrol('Style','pushbutton','Parent',EEG_dq_fre_conus.eventcode_title,'HorizontalAlignment','left',...
            'callback',@resetable,'String','Reset','FontSize',FontSize_defualt,'BackgroundColor',[1 1 1],'Enable',EnableFlag); % 2F
        set(EEG_dq_fre_conus.eventcode_title,'Sizes',[70,140,-1]);
        
        %%-----------------------Cancel and Run----------------------------
        EEG_dq_fre_conus.detar_run_title = uiextras.HBox('Parent', EEG_dq_fre_conus.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  EEG_dq_fre_conus.detar_run_title,'BackgroundColor',ColorB_def);
        EEG_dq_fre_conus.dq_fre_cancel = uicontrol('Style', 'pushbutton','Parent',EEG_dq_fre_conus.detar_run_title,...
            'String','Cancel','callback',@dq_fre_cancel,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent',  EEG_dq_fre_conus.detar_run_title,'BackgroundColor',ColorB_def);
        EEG_dq_fre_conus.dq_fre_run = uicontrol('Style','pushbutton','Parent',EEG_dq_fre_conus.detar_run_title,...
            'String','Run','callback',@dq_fre_run,'FontSize',FontSize_defualt,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent',  EEG_dq_fre_conus.detar_run_title,'BackgroundColor',ColorB_def);
        set(EEG_dq_fre_conus.detar_run_title,'Sizes',[15 105  30 105 15]);
        
        set(EEG_dq_fre_conus.DataSelBox,'Sizes',[30 160 30 30]);
        estudioworkingmemory('EEGTab_dq_fre_conus',0);
    end


%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%----------------------check changed cell(s)------------------------------
    function checkcellchanged(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=14
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_dq_fre_conus.TitleColor= [0.5137    0.7569    0.9176];
        EEG_dq_fre_conus.dq_fre_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_dq_fre_conus.dq_fre_cancel.ForegroundColor = [1 1 1];
        EEG_dq_fre_conus.dq_fre_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_dq_fre_conus.dq_fre_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_dq_fre_conus',1);
        
        Data = EEG_dq_fre_conus.bandtable.Data;
        [rowNum,columNum] = size(Data);
        for Numofrow = 1:rowNum
            for Numofcolumn = 2:columNum
                datacell = Data{Numofrow,Numofcolumn};
                if ~isnumeric(datacell)
                    Data{Numofrow,Numofcolumn} = str2num(char(datacell));
                end
            end
        end
        EEG_dq_fre_conus.bandtable.Data = Data;
    end


%%----------------------edit chans-----------------------------------------
    function chans_edit(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=14
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_dq_fre_conus.TitleColor= [0.5137    0.7569    0.9176];
        EEG_dq_fre_conus.dq_fre_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_dq_fre_conus.dq_fre_cancel.ForegroundColor = [1 1 1];
        EEG_dq_fre_conus.dq_fre_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_dq_fre_conus.dq_fre_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_dq_fre_conus',1);
        
        ChaNum = observe_EEGDAT.EEG.nbchan;
        ChanArray = str2num(Source.String);
        if isempty(ChanArray) || any(ChanArray(:)<=0)
            erpworkingmemory('f_EEG_proces_messg','Spectral Data Quality for Continuous EEG >  Index(es) of chans should be positive number(s)');
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String= vect2colon([1:ChaNum]);
            return;
        end
        if any(ChanArray(:)> ChaNum)
            erpworkingmemory('f_EEG_proces_messg',['Spectral Data Quality for Continuous EEG >  Index(es) of chans should be between 1 and ',32,num2str(ChaNum)]);
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.String= vect2colon([1:ChaNum]);
            return;
        end
    end



%%--------------------------Browse event codes-----------------------------
    function chans_browse(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=14
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_dq_fre_conus.TitleColor= [0.5137    0.7569    0.9176];
        EEG_dq_fre_conus.dq_fre_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_dq_fre_conus.dq_fre_cancel.ForegroundColor = [1 1 1];
        EEG_dq_fre_conus.dq_fre_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_dq_fre_conus.dq_fre_run.ForegroundColor = [1 1 1];
        
        %%-------Browse and select chans---------
        EEG = observe_EEGDAT.EEG;
        for Numofchan = 1:EEG.nbchan
            try
                listb{Numofchan}= strcat(num2str(Numofchan),'.',EEG.chanlocs(Numofchan).labels);
            catch
                listb{Numofchan}= strcat('Chan:',32,num2str(Numofchan));
            end
        end
        ChanArray = str2num(EEG_dq_fre_conus.chans_edit.String);
        if isempty(ChanArray)
            indxlistb = EEG.nbchan;
        else
            if min(ChanArray(:)) >0  && max(ChanArray(:)) <= EEG.nbchan
                indxlistb = ChanArray;
            else
                indxlistb = 1:EEG.nbchan;
            end
        end
        titlename = 'Select Channel(s):';
        chan_label_select = browsechanbinGUI(listb, indxlistb, titlename);
        if ~isempty(chan_label_select)
            EEG_dq_fre_conus.chans_edit.String  = vect2colon(chan_label_select);
        else
            beep;
            disp('User selected Cancel');
            return
        end
    end

%%------------------Ignore/use---------------------------------------------
    function add_rows(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=14
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_dq_fre_conus.TitleColor= [0.5137    0.7569    0.9176];
        EEG_dq_fre_conus.dq_fre_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_dq_fre_conus.dq_fre_cancel.ForegroundColor = [1 1 1];
        EEG_dq_fre_conus.dq_fre_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_dq_fre_conus.dq_fre_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_dq_fre_conus',1);
        EEG_dq_fre_conus.add_rows.Value = 1;
        
        curr_rows = size(EEG_dq_fre_conus.bandtable.Data,1);
        new_rows = curr_rows + 1;
        old_fqout = EEG_dq_fre_conus.bandtable.Data;
        new_row_str = ['Custom Band' num2str(new_rows)];
        new_row_cell = {new_row_str,[],[]};
        new_fqout = [old_fqout;new_row_cell];
        set(EEG_dq_fre_conus.bandtable,'Data',new_fqout);
    end


%%----------------------------Remove selected row--------------------------
    function remove_rows(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=14
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        Eegtab_box_dq_fre_conus.TitleColor= [0.5137    0.7569    0.9176];
        EEG_dq_fre_conus.dq_fre_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_dq_fre_conus.dq_fre_cancel.ForegroundColor = [1 1 1];
        EEG_dq_fre_conus.dq_fre_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_dq_fre_conus.dq_fre_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_dq_fre_conus',1);
        
        curr_rows = size(EEG_dq_fre_conus.bandtable.Data,1);
        row_del = EEG_dq_fre_conus.sel_row;
        if curr_rows <= 1
            beep
            erpworkingmemory('f_EEG_proces_messg','Spectral Data Quality for Continuous EEG > Remove selected rows: Already at 1 rows');
            observe_EEGDAT.eeg_panel_message =4;
        else
            new_rows = curr_rows - 1;
            new_Tout = EEG_dq_fre_conus.bandtable.Data;
            new_Tout(row_del,:) = []; % pop the selected row out
            set(EEG_dq_fre_conus.bandtable,'Data',new_Tout)
            pause(0.3);
            EEG_dq_fre_conus.sel_row = new_rows;
        end
    end


%%---------------------Reset table-----------------------------------------
    function resetable(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=14
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        Eegtab_box_dq_fre_conus.TitleColor= [0.5137    0.7569    0.9176];
        EEG_dq_fre_conus.dq_fre_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_dq_fre_conus.dq_fre_cancel.ForegroundColor = [1 1 1];
        EEG_dq_fre_conus.dq_fre_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EEG_dq_fre_conus.dq_fre_run.ForegroundColor = [1 1 1];
        estudioworkingmemory('EEGTab_dq_fre_conus',1);
        
        fqnyq = observe_EEGDAT.EEG.srate/2;
        def_labels = {'delta','theta','alpha','beta','gamma','50hz-noise','60hz-noise','broadband'}; %defaults
        def_bands = [0 3;3 8;8 12;8 30;30 48;49 51;59 61; 0 fqnyq];
        %make table
        data_tab = [def_labels' num2cell(def_bands)];
        EEG_dq_fre_conus.bandtable.Data = data_tab;
    end


%%-------------------------capture the selected row------------------------
    function selectedrow(Source,eventdata)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=14
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        if numel(eventdata.Indices)
            row_here = eventdata.Indices(1);
            EEG_dq_fre_conus.sel_row = row_here;
        end
        EEG_dq_fre_conus.bandtable.ColumnEditable = [true,true,true];
    end



%%%----------------------Preview-------------------------------------------
    function dq_fre_cancel(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=14
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','Spectral Data Quality for Continuous EEG > Cancel');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        Eegtab_box_dq_fre_conus.TitleColor= [0.0500    0.2500    0.5000];
        EEG_dq_fre_conus.dq_fre_cancel.BackgroundColor =  [1 1 1];
        EEG_dq_fre_conus.dq_fre_cancel.ForegroundColor = [0 0 0];
        EEG_dq_fre_conus.dq_fre_run.BackgroundColor =  [ 1 1 1];
        EEG_dq_fre_conus.dq_fre_run.ForegroundColor = [0 0 0];
        estudioworkingmemory('EEGTab_dq_fre_conus',0);
        
        chan_label_select = [1:observe_EEGDAT.EEG.nbchan];
        EEG_dq_fre_conus.chans_edit.String  = vect2colon(chan_label_select);
        fqnyq = observe_EEGDAT.EEG.srate/2;
        def_labels = {'delta','theta','alpha','beta','gamma','50hz-noise','60hz-noise','broadband'}; %defaults
        def_bands = [0 3;3 8;8 12;8 30;30 48;49 51;59 61; 0 fqnyq];
        %make table
        data_tab = [def_labels' num2cell(def_bands)];
        EEG_dq_fre_conus.bandtable.Data = data_tab;
        observe_EEGDAT.eeg_panel_message =2;
    end


%%-----------------------Shift events--------------------------------------
    function dq_fre_run(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=14
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','Spectral Data Quality for Continuous EEG > Run');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        Eegtab_box_dq_fre_conus.TitleColor= [0.0500    0.2500    0.5000];
        EEG_dq_fre_conus.dq_fre_cancel.BackgroundColor =  [1 1 1];
        EEG_dq_fre_conus.dq_fre_cancel.ForegroundColor = [0 0 0];
        EEG_dq_fre_conus.dq_fre_run.BackgroundColor =  [ 1 1 1];
        EEG_dq_fre_conus.dq_fre_run.ForegroundColor = [0 0 0];
        
        estudioworkingmemory('EEGTab_dq_fre_conus',0);
        %%--------Selected EEGsets-----------
        EEGArray= estudioworkingmemory('EEGArray');
        if isempty(EEGArray) || min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) || max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG)
            EEGArray = observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',EEGArray);
        end
        chanArray =  str2num(EEG_dq_fre_conus.chans_edit.String);
        bnchan = observe_EEGDAT.EEG.nbchan;
        if isempty(chanArray) || any(chanArray(:)<=0) || any(chanArray(:)>bnchan)
            erpworkingmemory('f_EEG_proces_messg',['Spectral Data Quality for Continuous EEG > Run: Index(es) of the chans must be between 1 and ',32,num2str(bnchan)]);
            observe_EEGDAT.eeg_panel_message =4;
            return;
        end
        
        fqbands = [EEG_dq_fre_conus.bandtable.Data{:,2}; EEG_dq_fre_conus.bandtable.Data{:,3}]';
        fqlabels = {EEG_dq_fre_conus.bandtable.Data{:,1}}' ;
        for ii = 1:size(fqbands,1)
            fqlabelsNew{ii,1} = fqlabels{ii};
        end
        fqlabels = fqlabelsNew;
        erpworkingmemory('pop_continuousFFT',{chanArray,fqbands,fqlabels});
        
        %         try
        for Numofeeg = 1:numel(EEGArray)
            EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Spectral Data Quality for Continuous EEG > Run*',32,32,32,32,datestr(datetime('now')),'\n']);
            
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            
            if isempty(chanArray) || any(chanArray(:)>EEG.nbchan)
                chanArray = [1:EEG.nbchan];
                fprintf(['We have changed chans as below:\n']);
                fprintf(['Chans:',num2str(chanArray),'\n']);
            end
            
            [EEG, ~, LASTCOM] = pop_continuousFFT(EEG, 'ChannelIndex',chanArray,'Frequencies',fqbands,'FrequencyLabel', ...
                fqlabels, 'viewGUI','true','History', 'implicit');
            
            if isempty(LASTCOM)
                disp('User selected cancel or errors occur.');
                fprintf( [repmat('-',1,100) '\n']);
                return;
            end
            if Numofeeg==1
                eegh(LASTCOM);
            end
            fprintf([LASTCOM,'\n']);
            observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = eegh(LASTCOM, EEG);
            fprintf( [repmat('-',1,100) '\n']);
        end%%end for loop of subjects
        
        observe_EEGDAT.eeg_panel_message =2;
        %         catch
        %             observe_EEGDAT.eeg_panel_message =3;%%There is errros in processing procedure
        %             fprintf( [repmat('-',1,100) '\n']);
        %             return;
        %         end
    end


%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=16
            return;
        end
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ~=1
            EEG_dq_fre_conus.chans_edit.Enable= 'off';
            EEG_dq_fre_conus.chans_browse.Enable= 'off';
            EEG_dq_fre_conus.bandtable.Enable = 'off';
            EEG_dq_fre_conus.add_rows.Enable= 'off';
            EEG_dq_fre_conus.remove_rows.Enable= 'off';
            EEG_dq_fre_conus.resetable.Enable= 'off';
            EEG_dq_fre_conus.dq_fre_run.Enable= 'off';
            EEG_dq_fre_conus.dq_fre_cancel.Enable= 'off';
            if ~isempty(observe_EEGDAT.EEG) &&  observe_EEGDAT.EEG.trials ~=1
                Eegtab_box_dq_fre_conus.TitleColor= [0.7500    0.7500    0.750];
            else
                Eegtab_box_dq_fre_conus.TitleColor= [0.0500    0.2500    0.5000];
            end
            observe_EEGDAT.count_current_eeg=17;
            return;
        end
        
        chanOld = str2num(EEG_dq_fre_conus.chans_edit.String);
        if isempty(chanOld)
            EEG_dq_fre_conus.chans_edit.String= vect2colon(1:observe_EEGDAT.EEG.nbchan);
        end
        Eegtab_box_dq_fre_conus.TitleColor= [0.0500    0.2500    0.5000];
        EEG_dq_fre_conus.chans_edit.Enable= 'on';
        EEG_dq_fre_conus.chans_browse.Enable= 'on';
        EEG_dq_fre_conus.bandtable.Enable = 'on';
        EEG_dq_fre_conus.add_rows.Enable= 'on';
        EEG_dq_fre_conus.remove_rows.Enable= 'on';
        EEG_dq_fre_conus.resetable.Enable= 'on';
        EEG_dq_fre_conus.dq_fre_run.Enable= 'on';
        EEG_dq_fre_conus.dq_fre_cancel.Enable= 'on';
        observe_EEGDAT.count_current_eeg=17;
    end


%%--------------press return to execute "Apply"----------------------------
    function eeg_shiftcodes_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('EEGTab_dq_fre_conus');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            dq_fre_run();
            estudioworkingmemory('EEGTab_dq_fre_conus',0);
            Eegtab_box_dq_fre_conus.TitleColor= [0.0500    0.2500    0.5000];
            EEG_dq_fre_conus.dq_fre_cancel.BackgroundColor =  [1 1 1];
            EEG_dq_fre_conus.dq_fre_cancel.ForegroundColor = [0 0 0];
            EEG_dq_fre_conus.dq_fre_run.BackgroundColor =  [ 1 1 1];
            EEG_dq_fre_conus.dq_fre_run.ForegroundColor = [0 0 0];
        else
            return;
        end
    end

%%-------------------Auomatically execute "apply"--------------------------
    function eeg_two_panels_change(~,~)
        if  isempty(observe_EEGDAT.EEG)
            return;
        end
        ChangeFlag =  estudioworkingmemory('EEGTab_dq_fre_conus');
        if ChangeFlag~=1
            return;
        end
        dq_fre_run();
        estudioworkingmemory('EEGTab_dq_fre_conus',0);
        Eegtab_box_dq_fre_conus.TitleColor= [0.0500    0.2500    0.5000];
        EEG_dq_fre_conus.dq_fre_cancel.BackgroundColor =  [1 1 1];
        EEG_dq_fre_conus.dq_fre_cancel.ForegroundColor = [0 0 0];
        EEG_dq_fre_conus.dq_fre_run.BackgroundColor =  [ 1 1 1];
        EEG_dq_fre_conus.dq_fre_run.ForegroundColor = [0 0 0];
    end

end