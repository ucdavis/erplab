%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 2022 && Nov. 2023

% ERPLAB Studio

function varargout = f_ERP_CSD_GUI(varargin)
global observe_ERPDAT;
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);
addlistener(observe_ERPDAT,'erp_between_panels_change',@erp_between_panels_change);
addlistener(observe_ERPDAT,'Reset_erp_panel_change',@Reset_erp_panel_change);


gui_erp_CSD = struct();

%-----------------------------Name the title----------------------------------------------
% global ERP_CSD_gui;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    ERP_CSD_gui = uiextras.BoxPanel('Parent', fig, 'Title', 'Convert Voltage to CSD', 'Padding', 5,...
        'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    ERP_CSD_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Convert Voltage to CSD', 'Padding', 5,...
        'BackgroundColor',ColorB_def);
else
    ERP_CSD_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Convert Voltage to CSD', 'Padding', 5,...
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
varargout{1} = ERP_CSD_gui;

    function drawui_erp_bin_operation(FonsizeDefault)
        FontSize_defualt = FonsizeDefault;
        Enable_label = 'off';
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        gui_erp_CSD.DataSelBox = uiextras.VBox('Parent', ERP_CSD_gui,'BackgroundColor',ColorB_def);
        
        %%Parameters
        gui_erp_CSD.sif_title = uiextras.HBox('Parent', gui_erp_CSD.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_CSD.sif_text = uicontrol('Style','text','Parent', gui_erp_CSD.sif_title,...
            'String','Spline interpolation flexibility m-constant value (4 is recommended)','FontSize',FontSize_defualt,'Max',10,'BackgroundColor',ColorB_def); % 2F
        
        gui_erp_CSD.sif_num = uicontrol('Style','edit','Parent', gui_erp_CSD.sif_title,...
            'String','4','FontSize',FontSize_defualt,'Enable',Enable_label,'callback',@csd_sif,'BackgroundColor',[1 1 1]); % 2F
        set(gui_erp_CSD.sif_title,'Sizes',[210,50]);
        gui_erp_CSD.sif_num.KeyPressFcn = @erp_csd_presskey;
        gui_erp_CSD.Para{1} = str2num(gui_erp_CSD.sif_num.String);
        gui_erp_CSD.scl_title = uiextras.HBox('Parent', gui_erp_CSD.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_CSD.scl_text = uicontrol('Style','text','Parent', gui_erp_CSD.scl_title,...
            'String','Smoothing constant lambda (0.00001 is recommended)','FontSize',FontSize_defualt,'Max',10,'BackgroundColor',ColorB_def); % 2F
        
        gui_erp_CSD.scl_num = uicontrol('Style','edit','Parent', gui_erp_CSD.scl_title,...
            'String','0.00001','FontSize',FontSize_defualt,'Enable',Enable_label,'callback',@csd_scl,'BackgroundColor',[1 1 1]); % 2F
        set(gui_erp_CSD.scl_title,'Sizes',[210,50]);
        gui_erp_CSD.scl_num.KeyPressFcn = @erp_csd_presskey;
        gui_erp_CSD.Para{2} = str2num(gui_erp_CSD.scl_num.String);
        gui_erp_CSD.hr_title = uiextras.HBox('Parent', gui_erp_CSD.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_CSD.hr_text = uicontrol('Style','text','Parent', gui_erp_CSD.hr_title,...
            'String','Head radius CSD rescaling values (10cm is recommended)','FontSize',FontSize_defualt,'Max',10,'BackgroundColor',ColorB_def); % 2F
        
        gui_erp_CSD.hr_num = uicontrol('Style','edit','Parent', gui_erp_CSD.hr_title,...
            'String','10','FontSize',FontSize_defualt,'Enable',Enable_label,'callback',@csd_hr,'BackgroundColor',[1 1 1]); % 2F
        set(gui_erp_CSD.hr_title,'Sizes',[210,50]);
        gui_erp_CSD.hr_num.KeyPressFcn = @erp_csd_presskey;
        gui_erp_CSD.Para{3} = str2num(gui_erp_CSD.hr_num.String);
        
        %%-----------------Run---------------------------------------------
        gui_erp_CSD.run_title = uiextras.HBox('Parent', gui_erp_CSD.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  gui_erp_CSD.run_title);
        gui_erp_CSD.cancel= uicontrol('Style','pushbutton','Parent', gui_erp_CSD.run_title ,'Enable',Enable_label,...
            'String','Cancel','callback',@tool_cancel,'FontSize',FontSize_defualt,'BackgroundColor',[1 1 1],'Max',10); % 2F
        uiextras.Empty('Parent',  gui_erp_CSD.run_title);
        gui_erp_CSD.run = uicontrol('Style','pushbutton','Parent',gui_erp_CSD.run_title,...
            'String','Run','callback',@apply_run,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        uiextras.Empty('Parent',  gui_erp_CSD.run_title);
        set(gui_erp_CSD.run_title,'Sizes',[15 105  30 105 15]);
        set(gui_erp_CSD.DataSelBox,'Sizes',[40,40,40,30]);
        estudioworkingmemory('ERPTab_csd',0);
    end

%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%-------------------Setting value for Spline interpolation flexibility m-constant value----------------
    function csd_sif(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=8
             observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        gui_erp_CSD.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_CSD.run.ForegroundColor = [1 1 1];
        ERP_CSD_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_CSD.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_CSD.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_csd',1);
        
        mcont = str2num(source.String);
        if isempty(mcont) || numel(mcont)~=1
            gui_erp_CSD.sif_num.String='4';
            msgboxText =  ['Convert voltage to CSD - Please ensure that the input was a single value'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
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
             observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        gui_erp_CSD.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_CSD.run.ForegroundColor = [1 1 1];
        ERP_CSD_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_CSD.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_CSD.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_csd',1);
        
        mcont = str2num(source.String);
        if isempty(mcont) || numel(mcont)~=1
            gui_erp_CSD.scl_num.String='0.0001';
            msgboxText =  ['Convert voltage to CSD - Please ensure that the input was a single value'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
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
             observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        gui_erp_CSD.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_CSD.run.ForegroundColor = [1 1 1];
        ERP_CSD_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_CSD.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_CSD.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_csd',1);
        mcont = str2num(source.String);
        if isempty(mcont) || numel(mcont)~=1
            gui_erp_CSD.hr_num.String='10';
            msgboxText =  ['Convert voltage to CSD - Please ensure that the input was a single value'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
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
             observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        csd_param(1) = str2double(gui_erp_CSD.sif_num.String);
        csd_param(2) = str2double(gui_erp_CSD.scl_num.String);
        csd_param(3) = str2double(gui_erp_CSD.hr_num.String);
        csd_param(4) = 1;
        estudioworkingmemory('csd_param',csd_param);
        ERPArray= estudioworkingmemory('selectederpstudio');
        if isempty(ERPArray)
            ERPArray = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = ERPArray;
            estudioworkingmemory('selectederpstudio',ERPArray);
        end
        gui_erp_CSD.run.BackgroundColor =  [1 1 1];
        gui_erp_CSD.run.ForegroundColor = [0 0 0];
        ERP_CSD_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_CSD.cancel.BackgroundColor =  [1 1 1];
        gui_erp_CSD.cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_csd',0);
        
        %%---------------------Compute CSD for each ERPset----------------
        estudioworkingmemory('f_ERP_proces_messg','Convert Voltage to CSD');
        observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
        try  ALLERPCOM = evalin('base','ALLERPCOM'); catch ALLERPCOM = [];  end
        %   Set names of slected ERPsets
        
        gui_erp_CSD.Para{1} = str2num(gui_erp_CSD.sif_num.String);
        gui_erp_CSD.Para{2} = str2num(gui_erp_CSD.scl_num.String);
        gui_erp_CSD.Para{3} = str2num(gui_erp_CSD.hr_num.String);
        ALLERP = observe_ERPDAT.ALLERP;
        ALLERP_out = [];
        %%Loop for the selcted ERPsets
        for  Numoferp = 1:numel(ERPArray)
            ERP = ALLERP(ERPArray(Numoferp));
            [eloc, labels, theta, radius, indices] = readlocs(ERP.chanlocs);
            thetacheck= isnan(theta);
            radiuscheck= isnan(radius);
            [~,ypostheta] = find(thetacheck(:)==1);
            [~,yposradius] = find(radiuscheck(:)==1);
            if ~isempty(ypostheta) && ~isempty(yposradius)
                msgboxText =  ['Current Source Density: Some electrodes for ERPset ',num2str(ERPArray(Numoferp)),32,'are missing electrode channel locations. Please check channel locations and try again.'];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
                observe_ERPDAT.Process_messg =2;
                return;
            end
            
            ERP = pop_currentsourcedensity(ERP,'EStudio');
            ERPCOM =  sprintf('%s=pop_currentsourcedensity(%s, %s);', 'ERP','ERP', '"EStudio"');
            if Numoferp == numel(ERPArray)
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
            else
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
            end
            if Numoferp==1
                ALLERP_out = ERP;
            else
                ALLERP_out(length(ALLERP_out)+1) = ERP;
            end
        end%%Loop for ERPsets end
        
        Save_file_label = 0;
        Answer = f_ERP_save_multi_file(ALLERP_out,1:numel(ERPArray),'_CSD');
        if isempty(Answer)
            return;
        end
        if ~isempty(Answer{1})
            ALLERP_out = Answer{1};
            Save_file_label = Answer{2};
        end
        for Numoferp = 1:numel(ERPArray)
            ERP = ALLERP_out(Numoferp);
            if Save_file_label==1
                [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', ERP.filename, 'filepath',ERP.filepath);
                if Numoferp ==numel(ERPArray)
                    [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
                else
                    [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                end
            else
                ERP.filename = '';
                ERP.saved = 'no';
                ERP.filepath = '';
            end
            ALLERP(length(ALLERP)+1) = ERP;
        end
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        
        observe_ERPDAT.ALLERP = ALLERP;
        estudioworkingmemory('f_ERP_bin_opt',1);
        try
            Selected_ERP_afd =  [length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1:length(observe_ERPDAT.ALLERP)];
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1;
        catch
            Selected_ERP_afd = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
        end
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
        estudioworkingmemory('selectederpstudio',Selected_ERP_afd);
        observe_ERPDAT.Count_currentERP = 1;
        observe_ERPDAT.Process_messg =2;
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
             observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        gui_erp_CSD.sif_num.String = num2str( gui_erp_CSD.Para{1});
        gui_erp_CSD.scl_num.String= num2str( gui_erp_CSD.Para{2});
        gui_erp_CSD.hr_num.String =  num2str( gui_erp_CSD.Para{3});
        
        gui_erp_CSD.run.BackgroundColor =  [1 1 1];
        gui_erp_CSD.run.ForegroundColor = [0 0 0];
        ERP_CSD_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_CSD.cancel.BackgroundColor =  [1 1 1];
        gui_erp_CSD.cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_csd',0);
    end

%%--------Setting current ERPset/session history based on the current updated ERPset------------
    function Count_currentERPChanged(~,~)
        if observe_ERPDAT.Count_currentERP~=17
            return;
        end
        ViewerFlag=estudioworkingmemory('ViewerFlag');%%when open advanced wave viewer
        if isempty(ViewerFlag) || (ViewerFlag~=0 && ViewerFlag~=1)
            ViewerFlag=0;estudioworkingmemory('ViewerFlag',0);
        end
        if  isempty(observe_ERPDAT.ERP) || isempty(observe_ERPDAT.ALLERP) || ViewerFlag==1
            Enable_label = 'off';
        else
            Enable_label = 'on';
        end
        gui_erp_CSD.run.Enable = Enable_label;
        gui_erp_CSD.sif_num.Enable = Enable_label;
        gui_erp_CSD.scl_num.Enable = Enable_label;
        gui_erp_CSD.hr_num.Enable = Enable_label;
        gui_erp_CSD.cancel.Enable = Enable_label;
        observe_ERPDAT.Count_currentERP=18;
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
            estudioworkingmemory('ERPTab_csd',0);
        else
            return;
        end
    end


    function Reset_erp_panel_change(~,~)
        if observe_ERPDAT.Reset_erp_paras_panel~=14
            return;
        end
        gui_erp_CSD.run.BackgroundColor =  [1 1 1];
        gui_erp_CSD.run.ForegroundColor = [0 0 0];
        ERP_CSD_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_CSD.cancel.BackgroundColor =  [1 1 1];
        gui_erp_CSD.cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_csd',0);
        gui_erp_CSD.sif_num.String = '4';
        gui_erp_CSD.scl_num.String = '0.00001';
        gui_erp_CSD.hr_num.String = '10';
        observe_ERPDAT.Reset_erp_paras_panel=15;
    end
end