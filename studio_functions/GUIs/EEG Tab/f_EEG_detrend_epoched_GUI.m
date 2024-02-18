%Author: Guanghui ZHANG
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Oct. 2023

% ERPLAB Studio

function varargout = f_EEG_detrend_epoched_GUI(varargin)

global observe_EEGDAT;
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
addlistener(observe_EEGDAT,'Reset_eeg_panel_change',@Reset_eeg_panel_change);

%%---------------------------gui-------------------------------------------
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    EEG_epoch_detrend_box = uiextras.BoxPanel('Parent', fig, 'Title', 'Linear Detrend (Epoched EEG)',...
        'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    EEG_epoch_detrend_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Linear Detrend (Epoched EEG)',...
        'Padding', 5,'BackgroundColor',ColorB_def);
else
    EEG_epoch_detrend_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Linear Detrend (Epoched EEG)',...
        'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);%, 'HelpFcn', @detrend_help
end

gui_eeg_epoch_dt = struct();
try
    FonsizeDefault = varargin{2};
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
    FonsizeDefault = f_get_default_fontsize();
end
erp_blc_dt_gui(FonsizeDefault);
varargout{1} = EEG_epoch_detrend_box;
%%********************Draw the GUI for ERP measurement tool*****************
    function erp_blc_dt_gui(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        
        if isempty(observe_EEGDAT.EEG)
            Enable_label = 'off';
        else
            Enable_label = 'on';
        end
        gui_eeg_epoch_dt.blc_dt = uiextras.VBox('Parent',EEG_epoch_detrend_box,'Spacing',1,'BackgroundColor',ColorB_def);
        
        %%Baseline period: Pre, post whole custom
        gui_eeg_epoch_dt.blc_dt_bp_option = uiextras.HBox('Parent',  gui_eeg_epoch_dt.blc_dt,'Spacing',1,'BackgroundColor',ColorB_def);
        gui_eeg_epoch_dt.pre = uicontrol('Style', 'radiobutton','Parent', gui_eeg_epoch_dt.blc_dt_bp_option,...
            'String','Pre','callback',@pre_eeg,'Value',1,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_eeg_epoch_dt.post = uicontrol('Style', 'radiobutton','Parent', gui_eeg_epoch_dt.blc_dt_bp_option,...
            'String','Post','callback',@post_eeg,'Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_eeg_epoch_dt.whole = uicontrol('Style', 'radiobutton','Parent', gui_eeg_epoch_dt.blc_dt_bp_option,...
            'String','Whole','callback',@whole_eeg,'Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_eeg_epoch_dt.blc_dt_bp_option_cust = uiextras.HBox('Parent',  gui_eeg_epoch_dt.blc_dt,'Spacing',1,'BackgroundColor',ColorB_def);
        gui_eeg_epoch_dt.custom = uicontrol('Style', 'radiobutton','Parent', gui_eeg_epoch_dt.blc_dt_bp_option_cust,...
            'String','Custom (ms) [start stop]','callback',@custom_eeg,'Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_eeg_epoch_dt.custom_edit = uicontrol('Style', 'edit','Parent', gui_eeg_epoch_dt.blc_dt_bp_option_cust,...
            'String','','callback',@custom_edit,'Enable',Enable_label,'FontSize',FonsizeDefault);
        
        set(gui_eeg_epoch_dt.blc_dt_bp_option_cust, 'Sizes',[160  135]);
        detwindow=erpworkingmemory('pop_eeglindetrend');
        if isempty(detwindow)
            gui_eeg_epoch_dt.pre.Value=1;
            gui_eeg_epoch_dt.post.Value=0;
            gui_eeg_epoch_dt.whole.Value=0;
            gui_eeg_epoch_dt.custom.Value=0;
            gui_eeg_epoch_dt.custom_edit.Enable = 'off';
        else
            if isnumeric(detwindow) && numel(detwindow) ==2
                gui_eeg_epoch_dt.pre.Value=0;
                gui_eeg_epoch_dt.post.Value=0;
                gui_eeg_epoch_dt.whole.Value=0;
                gui_eeg_epoch_dt.custom.Value=1;
                gui_eeg_epoch_dt.custom_edit.Enable = 'on';
            else
                if strcmpi(detwindow,'post')
                    gui_eeg_epoch_dt.pre.Value=0;
                    gui_eeg_epoch_dt.post.Value=1;
                    gui_eeg_epoch_dt.whole.Value=0;
                elseif strcmpi(detwindow,'all')
                    gui_eeg_epoch_dt.pre.Value=0;
                    gui_eeg_epoch_dt.post.Value=0;
                    gui_eeg_epoch_dt.whole.Value=1;
                else
                    gui_eeg_epoch_dt.pre.Value=1;
                    gui_eeg_epoch_dt.post.Value=0;
                    gui_eeg_epoch_dt.whole.Value=0;
                end
                gui_eeg_epoch_dt.custom.Value=0;
                gui_eeg_epoch_dt.custom_edit.Enable = 'off';
            end
        end
        
        %%Cancel and advanced
        gui_eeg_epoch_dt.other_option = uiextras.HBox('Parent',gui_eeg_epoch_dt.blc_dt,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', gui_eeg_epoch_dt.other_option,'BackgroundColor',ColorB_def);
        gui_eeg_epoch_dt.reset = uicontrol('Parent',gui_eeg_epoch_dt.other_option,'Style','pushbutton',...
            'String','Cancel','callback',@blc_dt_cancel,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', gui_eeg_epoch_dt.other_option);
        gui_eeg_epoch_dt.apply = uicontrol('Style','pushbutton','Parent',gui_eeg_epoch_dt.other_option,...
            'String','Apply','callback',@apply_blc_dt,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', gui_eeg_epoch_dt.other_option);
        set(gui_eeg_epoch_dt.other_option, 'Sizes',[15 105  30 105 15]);
        set(gui_eeg_epoch_dt.blc_dt,'Sizes',[15 25 30]);
        
        estudioworkingmemory('EEGTab_detrend_epoch',0);
    end
%%*************************************************************************
%%*******************   Subfunctions   ************************************
%%*************************************************************************

%%----------------Setting for "pre"----------------------------------------
    function pre_eeg(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=15
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_detrend_epoch',1);
        EEG_epoch_detrend_box.TitleColor= [0.5137    0.7569    0.9176];
        gui_eeg_epoch_dt.reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_eeg_epoch_dt.reset.ForegroundColor = [1 1 1];
        gui_eeg_epoch_dt.apply .BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_eeg_epoch_dt.apply .ForegroundColor = [1 1 1];
        
        gui_eeg_epoch_dt.pre.Value=1;
        gui_eeg_epoch_dt.post.Value=0;
        gui_eeg_epoch_dt.whole.Value=0;
        gui_eeg_epoch_dt.custom.Value=0;
        gui_eeg_epoch_dt.custom_edit.Enable = 'off';
        if observe_EEGDAT.EEG.times(1)>=0
            CUstom_String = '';
        else
            CUstom_String = num2str([observe_EEGDAT.EEG.times(1),0]);
        end
        gui_eeg_epoch_dt.custom_edit.String = CUstom_String;
    end


%%----------------Setting for "post"---------------------------------------
    function post_eeg(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=15
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_detrend_epoch',1);
        EEG_epoch_detrend_box.TitleColor= [0.5137    0.7569    0.9176];
        gui_eeg_epoch_dt.reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_eeg_epoch_dt.reset.ForegroundColor = [1 1 1];
        gui_eeg_epoch_dt.apply .BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_eeg_epoch_dt.apply .ForegroundColor = [1 1 1];
        
        gui_eeg_epoch_dt.pre.Value=0;
        gui_eeg_epoch_dt.post.Value=1;
        gui_eeg_epoch_dt.whole.Value=0;
        gui_eeg_epoch_dt.custom.Value=0;
        gui_eeg_epoch_dt.custom_edit.Enable = 'off';
        
        if observe_EEGDAT.EEG.times(end)<=0
            CUstom_String = '';
        else
            CUstom_String = num2str([0 observe_EEGDAT.EEG.times(end)]);
        end
        gui_eeg_epoch_dt.custom_edit.String = CUstom_String;
    end

%%----------------Setting for "whole"--------------------------------------
    function whole_eeg(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=15
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_detrend_epoch',1);
        EEG_epoch_detrend_box.TitleColor= [0.5137    0.7569    0.9176];
        gui_eeg_epoch_dt.reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_eeg_epoch_dt.reset.ForegroundColor = [1 1 1];
        gui_eeg_epoch_dt.apply .BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_eeg_epoch_dt.apply .ForegroundColor = [1 1 1];
        
        gui_eeg_epoch_dt.pre.Value=0;
        gui_eeg_epoch_dt.post.Value=0;
        gui_eeg_epoch_dt.whole.Value=1;
        gui_eeg_epoch_dt.custom.Value=0;
        gui_eeg_epoch_dt.custom_edit.Enable = 'off';
        CUstom_String = num2str([observe_EEGDAT.EEG.times(1) observe_EEGDAT.EEG.times(end)]);
        gui_eeg_epoch_dt.custom_edit.String = CUstom_String;
    end

%%----------------Setting for "custom"-------------------------------------
    function custom_eeg(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=15
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_detrend_epoch',1);
        EEG_epoch_detrend_box.TitleColor= [0.5137    0.7569    0.9176];
        gui_eeg_epoch_dt.reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_eeg_epoch_dt.reset.ForegroundColor = [1 1 1];
        gui_eeg_epoch_dt.apply .BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_eeg_epoch_dt.apply .ForegroundColor = [1 1 1];
        
        
        gui_eeg_epoch_dt.pre.Value=0;
        gui_eeg_epoch_dt.post.Value=0;
        gui_eeg_epoch_dt.whole.Value=0;
        gui_eeg_epoch_dt.custom.Value=1;
        gui_eeg_epoch_dt.custom_edit.Enable = 'on';
    end

%%----------------input baseline period defined by user--------------------
    function custom_edit(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=15
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_detrend_epoch',1);
        EEG_epoch_detrend_box.TitleColor= [0.5137    0.7569    0.9176];
        gui_eeg_epoch_dt.reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_eeg_epoch_dt.reset.ForegroundColor = [1 1 1];
        gui_eeg_epoch_dt.apply .BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_eeg_epoch_dt.apply .ForegroundColor = [1 1 1];
        
        lat_osci = str2num(Source.String);
        if isempty(lat_osci)
            msgboxText =  ['Linear Detrend (Epoched EEG) - Invalid input'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            Source.String = '';
            return;
        end
        if numel(lat_osci) ==1
            msgboxText =  ['Linear Detrend (Epoched EEG) - Please, enter two values'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            Source.String = '';
            return;
        end
        
        if lat_osci(1)>= lat_osci(2)
            msgboxText =  ['Linear Detrend (Epoched EEG) - The first value must be smaller than the second one'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            Source.String = '';
            return;
        end
        
        if lat_osci(2) > observe_EEGDAT.EEG.times(end)
            msgboxText =  ['Linear Detrend (Epoched EEG) - Second value must be smaller than',32,num2str(observe_EEGDAT.EEG.times(end))];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            Source.String = '';
            return;
        end
        if lat_osci(1) < observe_EEGDAT.EEG.times(1)
            msgboxText =  ['Linear Detrend (Epoched EEG) - First value must be larger than',32,num2str(observe_EEGDAT.EEG.times(1))];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            Source.String = '';
            return;
        end
    end



%%--------------------------Setting for plot-------------------------------
    function apply_blc_dt(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=15
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        EEG_epoch_detrend_box.TitleColor= [0.0500    0.2500    0.5000];
        gui_eeg_epoch_dt.reset.BackgroundColor =  [ 1 1 1];
        gui_eeg_epoch_dt.reset.ForegroundColor = [0 0 0];
        gui_eeg_epoch_dt.apply .BackgroundColor =  [1 1 1];
        gui_eeg_epoch_dt.apply .ForegroundColor = [0 0 0];
        
        erpworkingmemory('f_EEG_proces_messg','Linear Detrend (Epoched EEG) > Apply');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        if gui_eeg_epoch_dt.pre.Value==1
            detwindow = 'pre';
        elseif gui_eeg_epoch_dt.post.Value==1
            detwindow = 'post';
        elseif gui_eeg_epoch_dt.whole.Value==1
            detwindow = 'all';
        elseif gui_eeg_epoch_dt.custom.Value==1
            detwindow =  gui_eeg_epoch_dt.custom_edit.String;
            msgboxText = '';
            if isempty(detwindow)
                msgboxText =  ['Linear Detrend (Epoched EEG) > Apply - Invalid input'];
            end
            if numel(detwindow) ==1
                msgboxText =  ['Linear Detrend (Epoched EEG) > Apply - Please, enter two values'];
            end
            
            if detwindow(1)>= detwindow(2)
                msgboxText =  ['Linear Detrend (Epoched EEG) > Apply - The first value must be smaller than the second one'];
            end
            
            if detwindow(2) > observe_EEGDAT.EEG.times(end)
                msgboxText =  ['Linear Detrend (Epoched EEG) > Apply - Second value must be smaller than',32,num2str(observe_EEGDAT.EEG.times(end))];
                
            end
            if detwindow(1) < observe_EEGDAT.EEG.times(1)
                msgboxText =  ['Linear Detrend (Epoched EEG) > Apply - First value must be larger than',32,num2str(observe_EEGDAT.EEG.times(1))];
            end
            if ~isempty(msgboxText)
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_EEGDAT.eeg_panel_message =4;
                return;
            end
        end
        estudioworkingmemory('EEGTab_detrend_epoch',0);
        erpworkingmemory('pop_eeglindetrend', detwindow);
        %%--------Selected EEGsets-----------
        EEGArray= estudioworkingmemory('EEGArray');
        if isempty(EEGArray) || min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) || max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG)
            EEGArray = observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',EEGArray);
        end
        ALLEEG =observe_EEGDAT.ALLEEG;
        Answer = f_EEG_save_multi_file(ALLEEG,EEGArray,'_ld');
        if isempty(Answer)
            return;
        end
        if ~isempty(Answer{1})
            ALLEEG = Answer{1};
            Save_file_label = Answer{2};
        end
        
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Linear Detrend (Epoched EEG) > Apply*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            wchmsgonstr ='off'; %temporary
            [EEG, LASTCOM] = pop_eeglindetrend( EEG, detwindow, 'Warning', wchmsgonstr, 'History', 'implicit');
            if isempty(LASTCOM)
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


%%-----------------Setting for save option---------------------------------
    function blc_dt_cancel(Source,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();%%execute the other panels if any parameter was changed
        if ~isempty(messgStr) && eegpanelIndex~=15
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        EEG_epoch_detrend_box.TitleColor= [0.0500    0.2500    0.5000];
        gui_eeg_epoch_dt.reset.BackgroundColor =  [ 1 1 1];
        gui_eeg_epoch_dt.reset.ForegroundColor = [0 0 0];
        gui_eeg_epoch_dt.apply .BackgroundColor =  [1 1 1];
        gui_eeg_epoch_dt.apply .ForegroundColor = [0 0 0];
        
        erpworkingmemory('f_EEG_proces_messg','Linear Detrend (Epoched EEG) > Cancel');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        estudioworkingmemory('EEGTab_detrend_epoch',0);
        detwindow=erpworkingmemory('pop_eeglindetrend');
        if isempty(detwindow)
            gui_eeg_epoch_dt.pre.Value=1;
            gui_eeg_epoch_dt.post.Value=0;
            gui_eeg_epoch_dt.whole.Value=0;
            gui_eeg_epoch_dt.custom.Value=0;
            gui_eeg_epoch_dt.custom_edit.Enable = 'off';
            gui_eeg_epoch_dt.custom_edit.String = '';
        else
            if isnumeric(detwindow) && numel(detwindow) ==2
                gui_eeg_epoch_dt.pre.Value=0;
                gui_eeg_epoch_dt.post.Value=0;
                gui_eeg_epoch_dt.whole.Value=0;
                gui_eeg_epoch_dt.custom.Value=1;
                gui_eeg_epoch_dt.custom_edit.Enable = 'on';
            else
                if strcmpi(detwindow,'post')
                    gui_eeg_epoch_dt.pre.Value=0;
                    gui_eeg_epoch_dt.post.Value=1;
                    gui_eeg_epoch_dt.whole.Value=0;
                elseif strcmpi(detwindow,'all')
                    gui_eeg_epoch_dt.pre.Value=0;
                    gui_eeg_epoch_dt.post.Value=0;
                    gui_eeg_epoch_dt.whole.Value=1;
                else
                    gui_eeg_epoch_dt.pre.Value=1;
                    gui_eeg_epoch_dt.post.Value=0;
                    gui_eeg_epoch_dt.whole.Value=0;
                end
                gui_eeg_epoch_dt.custom.Value=0;
                gui_eeg_epoch_dt.custom_edit.Enable = 'off';
                gui_eeg_epoch_dt.custom_edit.String = '';
            end
        end
        observe_EEGDAT.eeg_panel_message =2;
    end


%%-------------------Setting for the whole panel of fitering based on ALLERP and CURRENTERP--------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=21
            return;
        end
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials==1
            Enable_Label = 'off';
            if ~isempty(observe_EEGDAT.EEG) && observe_EEGDAT.EEG.trials==1
                EEG_epoch_detrend_box.TitleColor= [0.7500    0.7500    0.75000];
            else
                EEG_epoch_detrend_box.TitleColor= [0.0500    0.2500    0.5000];
            end
        else
            Enable_Label = 'on';
            EEG_epoch_detrend_box.TitleColor= [0.0500    0.2500    0.5000];
        end
        gui_eeg_epoch_dt.blc.Enable = Enable_Label;
        gui_eeg_epoch_dt.dt.Enable = Enable_Label;
        gui_eeg_epoch_dt.apply.Enable = Enable_Label;
        gui_eeg_epoch_dt.reset.Enable = Enable_Label;
        gui_eeg_epoch_dt.pre.Enable= Enable_Label;
        gui_eeg_epoch_dt.post.Enable= Enable_Label;
        gui_eeg_epoch_dt.whole.Enable= Enable_Label;
        gui_eeg_epoch_dt.custom.Enable= Enable_Label;
        gui_eeg_epoch_dt.custom_edit.Enable = Enable_Label;
        gui_eeg_epoch_dt.apply.Enable = Enable_Label;
        gui_eeg_epoch_dt.reset.Enable = Enable_Label;
        gui_eeg_epoch_dt.all_bin_chan.Enable = Enable_Label;
        gui_eeg_epoch_dt.Selected_bin_chan.Enable = Enable_Label;
        if ~isempty(observe_EEGDAT.EEG) && observe_EEGDAT.EEG.trials~=1
            if gui_eeg_epoch_dt.custom.Value==1
                gui_eeg_epoch_dt.custom_edit.Enable = 'on';
            else
                gui_eeg_epoch_dt.custom_edit.Enable = 'off';
            end
        end
        observe_EEGDAT.count_current_eeg=22;
    end

%%--------------Reset this panel with the default parameters---------------
    function Reset_eeg_panel_change(~,~)
        if observe_EEGDAT.Reset_eeg_paras_panel~=17
            return;
        end
        %         EEG_epoch_detrend_box.TitleColor= [0.0500    0.2500    0.5000];
        gui_eeg_epoch_dt.reset.BackgroundColor =  [ 1 1 1];
        gui_eeg_epoch_dt.reset.ForegroundColor = [0 0 0];
        gui_eeg_epoch_dt.apply .BackgroundColor =  [1 1 1];
        gui_eeg_epoch_dt.apply .ForegroundColor = [0 0 0];
        estudioworkingmemory('EEGTab_detrend_epoch',0);
        
        gui_eeg_epoch_dt.pre.Value=1;
        gui_eeg_epoch_dt.post.Value=0;
        gui_eeg_epoch_dt.whole.Value=0;
        gui_eeg_epoch_dt.custom.Value=0;
        gui_eeg_epoch_dt.custom_edit.Enable = 'off';
        gui_eeg_epoch_dt.custom_edit.String = '';
        observe_EEGDAT.Reset_eeg_paras_panel=18;
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
%Progem end: detrend