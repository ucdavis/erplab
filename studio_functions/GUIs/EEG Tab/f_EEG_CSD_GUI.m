%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Mar. 2024

% ERPLAB Studio

function varargout = f_EEG_CSD_GUI(varargin)

global observe_EEGDAT;
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
addlistener(observe_EEGDAT,'Reset_eeg_panel_change',@Reset_eeg_panel_change);


gui_eeg_CSD = struct();

%-----------------------------Name the title----------------------------------------------
% global EEG_CSD_gui;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    EEG_CSD_gui = uiextras.BoxPanel('Parent', fig, 'Title', 'Convert Voltage to CSD', 'Padding', 5,...
        'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    EEG_CSD_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Convert Voltage to CSD', 'Padding', 5,...
        'BackgroundColor',ColorB_def);
else
    EEG_CSD_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Convert Voltage to CSD', 'Padding', 5,...
        'FontSize', varargin{2},'BackgroundColor',ColorB_def);%, 'HelpFcn', @tool_link
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
drawui_erp_bin_operation(FonsizeDefault);
varargout{1} = EEG_CSD_gui;

    function drawui_erp_bin_operation(FontSize_defualt)
        Enable_label = 'off';
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        gui_eeg_CSD.DataSelBox = uiextras.VBox('Parent', EEG_CSD_gui,'BackgroundColor',ColorB_def);
        
        %%Parameters
        gui_eeg_CSD.sif_title = uiextras.HBox('Parent', gui_eeg_CSD.DataSelBox,'BackgroundColor',ColorB_def);
        gui_eeg_CSD.sif_text = uicontrol('Style','text','Parent', gui_eeg_CSD.sif_title,...
            'String','Spline interpolation flexibility m-constant value (4 is recommended)','FontSize',FontSize_defualt,'Max',10,'BackgroundColor',ColorB_def); % 2F
        
        gui_eeg_CSD.sif_num = uicontrol('Style','edit','Parent', gui_eeg_CSD.sif_title,...
            'String','4','FontSize',FontSize_defualt,'Enable',Enable_label,'callback',@csd_sif,'BackgroundColor',[1 1 1]); % 2F
        set(gui_eeg_CSD.sif_title,'Sizes',[210,50]);
        gui_eeg_CSD.sif_num.KeyPressFcn = @eeg_csd_presskey;
        gui_eeg_CSD.Para{1} = str2num(gui_eeg_CSD.sif_num.String);
        gui_eeg_CSD.scl_title = uiextras.HBox('Parent', gui_eeg_CSD.DataSelBox,'BackgroundColor',ColorB_def);
        gui_eeg_CSD.scl_text = uicontrol('Style','text','Parent', gui_eeg_CSD.scl_title,...
            'String','Smoothing constant lambda (0.00001 is recommended)','FontSize',FontSize_defualt,'Max',10,'BackgroundColor',ColorB_def); % 2F
        
        gui_eeg_CSD.scl_num = uicontrol('Style','edit','Parent', gui_eeg_CSD.scl_title,...
            'String','0.00001','FontSize',FontSize_defualt,'Enable',Enable_label,'callback',@csd_scl,'BackgroundColor',[1 1 1]); % 2F
        set(gui_eeg_CSD.scl_title,'Sizes',[210,50]);
        gui_eeg_CSD.scl_num.KeyPressFcn = @eeg_csd_presskey;
        gui_eeg_CSD.Para{2} = str2num(gui_eeg_CSD.scl_num.String);
        gui_eeg_CSD.hr_title = uiextras.HBox('Parent', gui_eeg_CSD.DataSelBox,'BackgroundColor',ColorB_def);
        gui_eeg_CSD.hr_text = uicontrol('Style','text','Parent', gui_eeg_CSD.hr_title,...
            'String','Head radius CSD rescaling values (10cm is recommended)','FontSize',FontSize_defualt,'Max',10,'BackgroundColor',ColorB_def); % 2F
        
        gui_eeg_CSD.hr_num = uicontrol('Style','edit','Parent', gui_eeg_CSD.hr_title,...
            'String','10','FontSize',FontSize_defualt,'Enable',Enable_label,'callback',@csd_hr,'BackgroundColor',[1 1 1]); % 2F
        set(gui_eeg_CSD.hr_title,'Sizes',[210,50]);
        gui_eeg_CSD.hr_num.KeyPressFcn = @eeg_csd_presskey;
        gui_eeg_CSD.Para{3} = str2num(gui_eeg_CSD.hr_num.String);
        
        %%-----------------Run---------------------------------------------
        gui_eeg_CSD.run_title = uiextras.HBox('Parent', gui_eeg_CSD.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  gui_eeg_CSD.run_title);
        gui_eeg_CSD.cancel= uicontrol('Style','pushbutton','Parent', gui_eeg_CSD.run_title ,'Enable',Enable_label,...
            'String','Cancel','callback',@tool_cancel,'FontSize',FontSize_defualt,'BackgroundColor',[1 1 1],'Max',10); % 2F
        uiextras.Empty('Parent',  gui_eeg_CSD.run_title);
        gui_eeg_CSD.run = uicontrol('Style','pushbutton','Parent',gui_eeg_CSD.run_title,...
            'String','Run','callback',@apply_run,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        uiextras.Empty('Parent',  gui_eeg_CSD.run_title);
        set(gui_eeg_CSD.run_title,'Sizes',[15 105  30 105 15]);
        set(gui_eeg_CSD.DataSelBox,'Sizes',[40,40,40,30]);
        erpworkingmemory('EEGTab_csd',0);
    end

%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%-------------------Setting value for Spline interpolation flexibility m-constant value----------------
    function csd_sif(source,~)
        if isempty(observe_EEGDAT.EEG)
            observe_EEGDAT.count_current_eeg=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=19
            observe_EEGDAT.EEG_two_panels = observe_EEGDAT.EEG_two_panels+1;%%call the functions from the other panel
        end
        gui_eeg_CSD.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_eeg_CSD.run.ForegroundColor = [1 1 1];
        EEG_CSD_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_eeg_CSD.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eeg_CSD.cancel.ForegroundColor = [1 1 1];
        erpworkingmemory('EEGTab_csd',1);
        
        mcont = str2num(source.String);
        if isempty(mcont) || numel(mcont)~=1
            gui_eeg_CSD.sif_num.String='4';
            msgboxText =  ['Convert voltage to CSD - Please ensure that the input was a single value'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
    end

%%-------------------Setting value for Smoothing constant lambda---------------------------------------
    function csd_scl(source,~)
        if isempty(observe_EEGDAT.EEG)
            observe_EEGDAT.count_current_eeg=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=19
            observe_EEGDAT.EEG_two_panels = observe_EEGDAT.EEG_two_panels+1;%%call the functions from the other panel
        end
        gui_eeg_CSD.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_eeg_CSD.run.ForegroundColor = [1 1 1];
        EEG_CSD_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_eeg_CSD.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eeg_CSD.cancel.ForegroundColor = [1 1 1];
        erpworkingmemory('EEGTab_csd',1);
        
        mcont = str2num(source.String);
        if isempty(mcont) || numel(mcont)~=1
            gui_eeg_CSD.scl_num.String='0.0001';
            msgboxText =  ['Convert voltage to CSD - Please ensure that the input was a single value'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
    end

%%-------------------setting Head radius CSD rescaling values---------------------------------------
    function csd_hr(source,~)
        if isempty(observe_EEGDAT.EEG)
            observe_EEGDAT.count_current_eeg=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=19
            observe_EEGDAT.EEG_two_panels = observe_EEGDAT.EEG_two_panels+1;%%call the functions from the other panel
        end
        gui_eeg_CSD.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_eeg_CSD.run.ForegroundColor = [1 1 1];
        EEG_CSD_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_eeg_CSD.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eeg_CSD.cancel.ForegroundColor = [1 1 1];
        erpworkingmemory('EEGTab_csd',1);
        mcont = str2num(source.String);
        if isempty(mcont) || numel(mcont)~=1
            gui_eeg_CSD.hr_num.String='10';
            msgboxText =  ['Convert voltage to CSD - Please ensure that the input was a single value'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
    end


%%---------------------Run-------------------------------------------------
    function apply_run(~,~)
        if isempty(observe_EEGDAT.EEG)
            observe_EEGDAT.count_current_eeg=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=19
            observe_EEGDAT.EEG_two_panels = observe_EEGDAT.EEG_two_panels+1;%%call the functions from the other panel
        end
        
        csd_param(1) = str2double(gui_eeg_CSD.sif_num.String);
        csd_param(2) = str2double(gui_eeg_CSD.scl_num.String);
        csd_param(3) = str2double(gui_eeg_CSD.hr_num.String);
        csd_param(4) = 1;
        erpworkingmemory('csd_param',csd_param);
        EEGArray= erpworkingmemory('EEGArray');
        if isempty(EEGArray) || any(EEGArray(:)>length(observe_EEGDAT.ALLEEG))
            EEGArray = length(observe_EEGDAT.ALLEEG);
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(end);
            observe_EEGDAT.CURRENTSET = EEGArray;
            erpworkingmemory('EEGArray',EEGArray);
        end
        gui_eeg_CSD.run.BackgroundColor =  [1 1 1];
        gui_eeg_CSD.run.ForegroundColor = [0 0 0];
        EEG_CSD_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_eeg_CSD.cancel.BackgroundColor =  [1 1 1];
        gui_eeg_CSD.cancel.ForegroundColor = [0 0 0];
        erpworkingmemory('EEGTab_csd',0);
        
        %%---------------------Compute CSD for each ERPset----------------
        erpworkingmemory('f_EEG_proces_messg','Convert Voltage to CSD');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        gui_eeg_CSD.Para{1} = str2num(gui_eeg_CSD.sif_num.String);
        gui_eeg_CSD.Para{2} = str2num(gui_eeg_CSD.scl_num.String);
        gui_eeg_CSD.Para{3} = str2num(gui_eeg_CSD.hr_num.String);
        ALLEEG = observe_EEGDAT.ALLEEG;
        ALLEEG_out = [];
        %%Loop for the selcted ERPsets
        for  Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG(EEGArray(Numofeeg));
            [eloc, labels, theta, radius, indices] = readlocs(EEG.chanlocs);
            thetacheck= isnan(theta);
            radiuscheck= isnan(radius);
            [~,ypostheta] = find(thetacheck(:)==1);
            [~,yposradius] = find(radiuscheck(:)==1);
            if ~isempty(ypostheta) && ~isempty(yposradius)
                msgboxText =  ['Current Source Density: Some electrodes for EEGset:',num2str(EEGArray(Numofeeg)),32,'are missing electrode channel locations. Please check channel locations and try again.'];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            
            [EEG, LASTCOM] = pop_currentsourcedensity(EEG,'EStudio');
            EEG = eegh(LASTCOM, EEG);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            [ALLEEG_out,~,~] = pop_newset(ALLEEG_out, EEG, length(ALLEEG_out), 'gui', 'off');
        end%%Loop for eegset end
        
        Save_file_label = 0;
        Answer = f_EEG_save_multi_file(ALLEEG_out,1:numel(EEGArray),'_CSD');
        if isempty(Answer)
            return;
        end
        if ~isempty(Answer{1})
            ALLEEG_out = Answer{1};
            Save_file_label = Answer{2};
        end
        
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG_out(Numofeeg);
            if Save_file_label
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
            [ALLEEG,~,~] = pop_newset(ALLEEG, EEG, length(ALLEEG), 'gui', 'off');
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
        erpworkingmemory('EEGArray',Selected_EEG_afd);
        assignin('base','EEG',observe_EEGDAT.EEG);
        assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
        assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        
        observe_EEGDAT.count_current_eeg=1;
        observe_EEGDAT.eeg_panel_message =2;
    end

%%----------------------function cancel------------------------------------
    function tool_cancel(~,~)
        if isempty(observe_EEGDAT.EEG)
            observe_EEGDAT.count_current_eeg=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=19
            observe_EEGDAT.EEG_two_panels = observe_EEGDAT.EEG_two_panels+1;%%call the functions from the other panel
        end
        gui_eeg_CSD.sif_num.String = num2str( gui_eeg_CSD.Para{1});
        gui_eeg_CSD.scl_num.String= num2str( gui_eeg_CSD.Para{2});
        gui_eeg_CSD.hr_num.String =  num2str( gui_eeg_CSD.Para{3});
        
        gui_eeg_CSD.run.BackgroundColor =  [1 1 1];
        gui_eeg_CSD.run.ForegroundColor = [0 0 0];
        EEG_CSD_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_eeg_CSD.cancel.BackgroundColor =  [1 1 1];
        gui_eeg_CSD.cancel.ForegroundColor = [0 0 0];
        erpworkingmemory('EEGTab_csd',0);
    end

%%--------Setting current ERPset/session history based on the current updated ERPset------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg~=24
            return;
        end
        EEGUpdate = erpworkingmemory('EEGUpdate');
        if isempty(EEGUpdate) || numel(EEGUpdate)~=1 || (EEGUpdate~=0 && EEGUpdate~=1)
            EEGUpdate = 0;  erpworkingmemory('EEGUpdate',0);
        end
        if  isempty(observe_EEGDAT.EEG) || isempty(observe_EEGDAT.ALLEEG) || EEGUpdate==1
            Enable_label = 'off';
        else
            Enable_label = 'on';
        end
        gui_eeg_CSD.run.Enable = Enable_label;
        gui_eeg_CSD.sif_num.Enable = Enable_label;
        gui_eeg_CSD.scl_num.Enable = Enable_label;
        gui_eeg_CSD.hr_num.Enable = Enable_label;
        gui_eeg_CSD.cancel.Enable = Enable_label;
        observe_EEGDAT.count_current_eeg=25;
    end

%%--------------press return to execute "Apply"----------------------------
    function eeg_csd_presskey(~,eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  erpworkingmemory('EEGTab_csd');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            apply_run();
            gui_eeg_CSD.run.BackgroundColor =  [1 1 1];
            gui_eeg_CSD.run.ForegroundColor = [0 0 0];
            EEG_CSD_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
            gui_eeg_CSD.cancel.BackgroundColor =  [1 1 1];
            gui_eeg_CSD.cancel.ForegroundColor = [0 0 0];
            erpworkingmemory('EEGTab_csd',0);
        else
            return;
        end
    end


    function Reset_eeg_panel_change(~,~)
        if observe_EEGDAT.Reset_EEG_paras_panel~=20
            return;
        end
        gui_eeg_CSD.run.BackgroundColor =  [1 1 1];
        gui_eeg_CSD.run.ForegroundColor = [0 0 0];
        EEG_CSD_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_eeg_CSD.cancel.BackgroundColor =  [1 1 1];
        gui_eeg_CSD.cancel.ForegroundColor = [0 0 0];
        erpworkingmemory('EEGTab_csd',0);
        gui_eeg_CSD.sif_num.String = '4';
        gui_eeg_CSD.scl_num.String = '0.00001';
        gui_eeg_CSD.hr_num.String = '10';
        observe_EEGDAT.Reset_EEG_paras_panel=21;
    end
end