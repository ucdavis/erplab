%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 2022 && Nov. 2023

% ERPLAB Studio

function varargout = f_ERP_CSD_GUI(varargin)
global observe_ERPDAT;
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);
addlistener(observe_ERPDAT,'erp_two_panels_change',@erp_two_panels_change);
addlistener(observe_ERPDAT,'Reset_erp_panel_change',@Reset_erp_panel_change);


gui_erp_CSD = struct();

%-----------------------------Name the title----------------------------------------------
% global ERP_CSD_gui;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    ERP_CSD_gui = uiextras.BoxPanel('Parent', fig, 'Title', 'Convert Voltage to CSD', 'Padding', 5,...
        'BackgroundColor',ColorB_def, 'HelpFcn', @tool_link); % Create boxpanel
elseif nargin == 1
    ERP_CSD_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Convert Voltage to CSD', 'Padding', 5,...
        'BackgroundColor',ColorB_def, 'HelpFcn', @tool_link);
else
    ERP_CSD_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Convert Voltage to CSD', 'Padding', 5,...
        'FontSize', varargin{2},'BackgroundColor',ColorB_def, 'HelpFcn', @tool_link);
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
varargout{1} = ERP_CSD_gui;

    function drawui_erp_bin_operation(FonsizeDefault)
        FontSize_defualt = FonsizeDefault;
        Enable_label = 'off';
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        gui_erp_CSD.DataSelBox = uiextras.VBox('Parent', ERP_CSD_gui,'BackgroundColor',ColorB_def);
        
        %%Display the lacations of electrodes: may use other function to
        %%replace current one.
        %       gui_erp_CSD.erp_h_erp = uicontrol('Style','radiobutton','Parent', gui_erp_CSD.erp_history_title,'String','ERP','callback',@ERP_H_ERP,'Value',0); % 2F
        gui_erp_CSD.erp_history_table = uiextras.HBox('Parent', gui_erp_CSD.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_CSD.erp_h_erp    =  axes( 'Parent', gui_erp_CSD.erp_history_table, 'ActivePositionProperty', 'Position');
        set( gui_erp_CSD.erp_h_erp,'xticklabel', [], 'yticklabel', []);
        
        %%Parameters
        gui_erp_CSD.sif_title = uiextras.HBox('Parent', gui_erp_CSD.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_CSD.sif_text = uicontrol('Style','text','Parent', gui_erp_CSD.sif_title,...
            'String','Spline interpolation flexibility m-constant value (4 is recommended)','FontSize',FontSize_defualt,'Max',10,'BackgroundColor',ColorB_def); % 2F
        
        gui_erp_CSD.sif_num = uicontrol('Style','edit','Parent', gui_erp_CSD.sif_title,...
            'String','4','FontSize',FontSize_defualt,'Enable',Enable_label,'callback',@csd_sif); % 2F
        set(gui_erp_CSD.sif_title,'Sizes',[210,50]);
        gui_erp_CSD.sif_num.KeyPressFcn = @erp_csd_presskey;
        gui_erp_CSD.Para{1} = str2num(gui_erp_CSD.sif_num.String);
        gui_erp_CSD.scl_title = uiextras.HBox('Parent', gui_erp_CSD.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_CSD.scl_text = uicontrol('Style','text','Parent', gui_erp_CSD.scl_title,...
            'String','Smoothing constant lambda (0.00001 is recommended)','FontSize',FontSize_defualt,'Max',10,'BackgroundColor',ColorB_def); % 2F
        
        gui_erp_CSD.scl_num = uicontrol('Style','edit','Parent', gui_erp_CSD.scl_title,...
            'String','0.00001','FontSize',FontSize_defualt,'Enable',Enable_label,'callback',@csd_scl); % 2F
        set(gui_erp_CSD.scl_title,'Sizes',[210,50]);
        gui_erp_CSD.scl_num.KeyPressFcn = @erp_csd_presskey;
        gui_erp_CSD.Para{2} = str2num(gui_erp_CSD.scl_num.String);
        gui_erp_CSD.hr_title = uiextras.HBox('Parent', gui_erp_CSD.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_CSD.hr_text = uicontrol('Style','text','Parent', gui_erp_CSD.hr_title,...
            'String','Head radius CSD rescaling values (10cm is recommended)','FontSize',FontSize_defualt,'Max',10,'BackgroundColor',ColorB_def); % 2F
        
        gui_erp_CSD.hr_num = uicontrol('Style','edit','Parent', gui_erp_CSD.hr_title,...
            'String','10','FontSize',FontSize_defualt,'Enable',Enable_label,'callback',@csd_hr); % 2F
        set(gui_erp_CSD.hr_title,'Sizes',[210,50]);
        gui_erp_CSD.hr_num.KeyPressFcn = @erp_csd_presskey;
        gui_erp_CSD.Para{3} = str2num(gui_erp_CSD.hr_num.String);
        
        %%-----------------Run---------------------------------------------
        gui_erp_CSD.run_title = uiextras.HBox('Parent', gui_erp_CSD.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  gui_erp_CSD.run_title);
        gui_erp_CSD.run = uicontrol('Style','pushbutton','Parent',gui_erp_CSD.run_title,...
            'String','Run','callback',@apply_run,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        uiextras.Empty('Parent',  gui_erp_CSD.run_title);
        set(gui_erp_CSD.run_title,'Sizes',[85 90 85]);
        
        gui_erp_CSD.location_title = uiextras.HBox('Parent', gui_erp_CSD.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_CSD.cancel= uicontrol('Style','pushbutton','Parent',gui_erp_CSD.location_title,'Enable',Enable_label,...
            'String','Cancel','callback',@tool_cancel,'FontSize',FontSize_defualt,'BackgroundColor',[1 1 1],'Max',10); % 2F
        gui_erp_CSD.location = uicontrol('Style','pushbutton','Parent',gui_erp_CSD.location_title,...
            'String','Expand Locations','callback',@CSD_undock_loct,'FontSize',FontSize_defualt,'BackgroundColor',[1 1 1],'Enable',Enable_label); % 2F
        set(gui_erp_CSD.DataSelBox,'Sizes',[230,40,40,40,30,30]);
        
        estudioworkingmemory('ERPTab_csd',0);
    end



%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

    function CSD_undock_loct(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=8
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        csd_chan_locations;
        gui_erp_CSD.Para{1} = str2num(gui_erp_CSD.sif_num.String);
        gui_erp_CSD.Para{2} = str2num(gui_erp_CSD.scl_num.String);
        gui_erp_CSD.Para{3} = str2num(gui_erp_CSD.hr_num.String);
        
        gui_erp_CSD.run.BackgroundColor =  [1 1 1];
        gui_erp_CSD.run.ForegroundColor = [0 0 0];
        ERP_CSD_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_CSD.cancel.BackgroundColor =  [1 1 1];
        gui_erp_CSD.cancel.ForegroundColor = [0 0 0];
        gui_erp_CSD.location.BackgroundColor =  [1 1 1];
        gui_erp_CSD.location.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_csd',0);
    end
%%-------------------Setting value for Spline interpolation flexibility m-constant value----------------
    function csd_sif(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=8
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_CSD.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_CSD.run.ForegroundColor = [1 1 1];
        ERP_CSD_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_CSD.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_CSD.cancel.ForegroundColor = [1 1 1];
        gui_erp_CSD.location.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_CSD.location.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_csd',1);
        
        mcont = str2num(source.String);
        if isempty(mcont) || numel(mcont)~=1
            gui_erp_CSD.sif_num.String='4';
            msgboxText =  ['Convert voltage to CSD - Please ensure that the input was a single value'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
        end
    end

%%-------------------Setting value for Smoothing constant lambda---------------------------------------
    function csd_scl(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=8
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_CSD.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_CSD.run.ForegroundColor = [1 1 1];
        ERP_CSD_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_CSD.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_CSD.cancel.ForegroundColor = [1 1 1];
        gui_erp_CSD.location.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_CSD.location.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_csd',1);
        
        mcont = str2num(source.String);
        if isempty(mcont) || numel(mcont)~=1
            gui_erp_CSD.scl_num.String='0.0001';
            msgboxText =  ['Convert voltage to CSD - Please ensure that the input was a single value'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
        end
    end

%%-------------------setting Head radius CSD rescaling values---------------------------------------
    function csd_hr(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=8
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_CSD.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_CSD.run.ForegroundColor = [1 1 1];
        ERP_CSD_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_CSD.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_CSD.cancel.ForegroundColor = [1 1 1];
        gui_erp_CSD.location.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_CSD.location.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_csd',1);
        
        mcont = str2num(source.String);
        if isempty(mcont) || numel(mcont)~=1
            gui_erp_CSD.hr_num.String='10';
            msgboxText =  ['Convert voltage to CSD - Please ensure that the input was a single value'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
        end
    end

%%---------------------CSD tool link-------------------------------------
    function tool_link(~,~)
        web('https://github.com/lucklab/erplab/wiki/Current-Source-Density-(CSD)-tool','-browser');
    end
%%---------------------Run-------------------------------------------------
    function apply_run(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=8
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        csd_param(1) = str2double(gui_erp_CSD.sif_num.String);
        csd_param(2) = str2double(gui_erp_CSD.scl_num.String);
        csd_param(3) = str2double(gui_erp_CSD.hr_num.String);
        csd_param(4) = 1;
        erpworkingmemory('csd_param',csd_param);
        Selectederp_Index= estudioworkingmemory('selectederpstudio');
        if isempty(Selectederp_Index)
            Selectederp_Index = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = Selectederp_Index;
            estudioworkingmemory('selectederpstudio',Selectederp_Index);
        end
        gui_erp_CSD.run.BackgroundColor =  [1 1 1];
        gui_erp_CSD.run.ForegroundColor = [0 0 0];
        ERP_CSD_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_CSD.cancel.BackgroundColor =  [1 1 1];
        gui_erp_CSD.cancel.ForegroundColor = [0 0 0];
        gui_erp_CSD.location.BackgroundColor =  [1 1 1];
        gui_erp_CSD.location.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_csd',0);
        
        
        %%---------------------Compute CSD for each ERPset----------------
        try
            erpworkingmemory('f_ERP_proces_messg','Convert Voltage to CSD');
            observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
            ALLERPCOM = evalin('base','ALLERPCOM');
            %   Set names of slected ERPsets
            Save_file_label = 0;
            Answer = f_ERP_save_multi_file(observe_ERPDAT.ALLERP,Selectederp_Index,'_CSD');
            if isempty(Answer)
                beep;
                disp('User selected Cancel');
                return;
            end
            
            if ~isempty(Answer{1})
                ALLERP_out = Answer{1};
                Save_file_label = Answer{2};
            end
            gui_erp_CSD.Para{1} = str2num(gui_erp_CSD.sif_num.String);
            gui_erp_CSD.Para{2} = str2num(gui_erp_CSD.scl_num.String);
            gui_erp_CSD.Para{3} = str2num(gui_erp_CSD.hr_num.String);
            
            
            %%Loop for the selcted ERPsets
            for  Numofselectederp = 1:numel(Selectederp_Index)
                ERP = ALLERP_out(Selectederp_Index(Numofselectederp));
                [ERP, ERPCOM] = pop_currentsourcedensity(ERP);
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                %%display the loctions of electrodes for each selected ERPsets.
                path_to_pic = which('CSD_elec_plot.png');
                if numel(path_to_pic) ~= 0     % iff a path to the pic exists, show it
                    myImage = imread('CSD_elec_plot.png');
                    imshow(myImage,'Parent',gui_erp_CSD.erp_h_erp);
                end
                
                observe_ERPDAT.ALLERP(length(observe_ERPDAT.ALLERP)+1) = ERP;%%Save the transformed ERPset
                if Save_file_label==1
                    [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', ERP.filename, 'filepath',ERP.filepath);
                    [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                end
            end%%Loop for ERPsets end
            [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);
            assignin('base','ALLERPCOM',ALLERPCOM);
            assignin('base','ERPCOM',ERPCOM);
            erpworkingmemory('f_ERP_bin_opt',1);
            try
                Selected_ERP_afd =  [length(observe_ERPDAT.ALLERP)-numel(Selectederp_Index)+1:length(observe_ERPDAT.ALLERP)];
                observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP)-numel(Selectederp_Index)+1;
            catch
                Selected_ERP_afd = length(observe_ERPDAT.ALLERP);
                observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
            end
            
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
            estudioworkingmemory('selectederpstudio',Selected_ERP_afd);
            observe_ERPDAT.Count_currentERP = 1;
            observe_ERPDAT.Process_messg =2;
            return;
        catch
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
            Selected_ERP_afd =observe_ERPDAT.CURRENTERP;
            estudioworkingmemory('selectederpstudio',Selected_ERP_afd);
            erpworkingmemory('f_ERP_bin_opt',1);
            observe_ERPDAT.Count_currentERP = 1;
            observe_ERPDAT.Process_messg =3;%%
        end
        observe_ERPDAT.Two_GUI = observe_ERPDAT.Two_GUI+1;
    end

%%----------------------function cancel------------------------------------
    function tool_cancel(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=8
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_CSD.sif_num.String = num2str( gui_erp_CSD.Para{1});
        gui_erp_CSD.scl_num.String= num2str( gui_erp_CSD.Para{2});
        gui_erp_CSD.hr_num.String =  num2str( gui_erp_CSD.Para{3});
        
        gui_erp_CSD.run.BackgroundColor =  [1 1 1];
        gui_erp_CSD.run.ForegroundColor = [0 0 0];
        ERP_CSD_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_CSD.cancel.BackgroundColor =  [1 1 1];
        gui_erp_CSD.cancel.ForegroundColor = [0 0 0];
        gui_erp_CSD.location.BackgroundColor =  [1 1 1];
        gui_erp_CSD.location.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_csd',0);
    end

%%--------Setting current ERPset/session history based on the current updated ERPset------------
    function Count_currentERPChanged(~,~)
        if observe_ERPDAT.Count_currentERP~=9
            return;
        end
        ViewerFlag=erpworkingmemory('ViewerFlag');
        if  isempty(observe_ERPDAT.ERP) || isempty(observe_ERPDAT.ALLERP) || ViewerFlag==1
            Enable_label = 'off';
        else
            Enable_label = 'on';
        end
        gui_erp_CSD.run.Enable = Enable_label;
        gui_erp_CSD.sif_num.Enable = Enable_label;
        gui_erp_CSD.scl_num.Enable = Enable_label;
        gui_erp_CSD.hr_num.Enable = Enable_label;
        gui_erp_CSD.location.Enable = Enable_label;
        gui_erp_CSD.cancel.Enable = Enable_label;
        observe_ERPDAT.Count_currentERP=10;
    end



%%-------execute "apply" before doing any change for other panels----------
    function erp_two_panels_change(~,~)
        if  isempty(observe_ERPDAT.ALLERP)|| isempty(observe_ERPDAT.ERP)
            return;
        end
        ChangeFlag =  estudioworkingmemory('ERPTab_csd');
        if ChangeFlag~=1
            return;
        end
        apply_run();
        gui_erp_CSD.run.BackgroundColor =  [1 1 1];
        gui_erp_CSD.run.ForegroundColor = [0 0 0];
        ERP_CSD_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_CSD.cancel.BackgroundColor =  [1 1 1];
        gui_erp_CSD.cancel.ForegroundColor = [0 0 0];
        gui_erp_CSD.location.BackgroundColor =  [1 1 1];
        gui_erp_CSD.location.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_csd',0);
    end

%%--------------press return to execute "Apply"----------------------------
    function erp_csd_presskey(~,eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('ERPTab_csd');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            apply_run();
            gui_erp_CSD.run.BackgroundColor =  [1 1 1];
            gui_erp_CSD.run.ForegroundColor = [0 0 0];
            ERP_CSD_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
            gui_erp_CSD.cancel.BackgroundColor =  [1 1 1];
            gui_erp_CSD.cancel.ForegroundColor = [0 0 0];
            gui_erp_CSD.location.BackgroundColor =  [1 1 1];
            gui_erp_CSD.location.ForegroundColor = [0 0 0];
            estudioworkingmemory('ERPTab_csd',0);
        else
            return;
        end
    end


    function Reset_erp_panel_change(~,~)
        if observe_ERPDAT.Reset_erp_paras_panel~=9
            return;
        end
        gui_erp_CSD.run.BackgroundColor =  [1 1 1];
        gui_erp_CSD.run.ForegroundColor = [0 0 0];
        ERP_CSD_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_CSD.cancel.BackgroundColor =  [1 1 1];
        gui_erp_CSD.cancel.ForegroundColor = [0 0 0];
        gui_erp_CSD.location.BackgroundColor =  [1 1 1];
        gui_erp_CSD.location.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_csd',0);
        gui_erp_CSD.erp_h_erp    =  axes( 'Parent', gui_erp_CSD.erp_history_table, 'ActivePositionProperty', 'Position');
        set( gui_erp_CSD.erp_h_erp,'xticklabel', [], 'yticklabel', []);
        gui_erp_CSD.sif_num.String = '4';
        gui_erp_CSD.scl_num.String = '0.00001';
        gui_erp_CSD.hr_num.String = '10';
        observe_ERPDAT.Reset_erp_paras_panel=10;
    end
end