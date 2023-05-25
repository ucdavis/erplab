%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 2022

% ERPLAB Studio

function varargout = f_ERP_CSD_GUI(varargin)
global observe_ERPDAT;
% addlistener(observe_ERPDAT,'ALLERP_change',@allErpChanged);
% addlistener(observe_ERPDAT,'ERP_change',@onErpChanged);
% addlistener(observe_ERPDAT,'CURRENTERP_change',@cerpchange);
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);


gui_erp_CSD = struct();

%-----------------------------Name the title----------------------------------------------
% global ERP_CSD_gui;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    ERP_CSD_gui = uiextras.BoxPanel('Parent', fig, 'Title', 'Convert Voltage to CSD', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    ERP_CSD_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Convert Voltage to CSD', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    ERP_CSD_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Convert Voltage to CSD', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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
        
        if strcmp(observe_ERPDAT.ALLERP(1).erpname,'No ERPset loaded')
            Enable_label = 'off';
        else
            Enable_label = 'on';
        end
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
        
        gui_erp_CSD.scl_title = uiextras.HBox('Parent', gui_erp_CSD.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_CSD.scl_text = uicontrol('Style','text','Parent', gui_erp_CSD.scl_title,...
            'String','Smoothing constant lambda (0.00001 is recommended)','FontSize',FontSize_defualt,'Max',10,'BackgroundColor',ColorB_def); % 2F
        
        gui_erp_CSD.scl_num = uicontrol('Style','edit','Parent', gui_erp_CSD.scl_title,...
            'String','0.00001','FontSize',FontSize_defualt,'Enable',Enable_label,'callback',@csd_scl); % 2F
        set(gui_erp_CSD.scl_title,'Sizes',[210,50]);
        
        gui_erp_CSD.hr_title = uiextras.HBox('Parent', gui_erp_CSD.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_CSD.hr_text = uicontrol('Style','text','Parent', gui_erp_CSD.hr_title,...
            'String','Head radius CSD rescaling values (10cm is recommended)','FontSize',FontSize_defualt,'Max',10,'BackgroundColor',ColorB_def); % 2F
        
        gui_erp_CSD.hr_num = uicontrol('Style','edit','Parent', gui_erp_CSD.hr_title,...
            'String','10','FontSize',FontSize_defualt,'Enable',Enable_label,'callback',@csd_hr); % 2F
        set(gui_erp_CSD.hr_title,'Sizes',[210,50]);
        
        
        %%-----------------Run---------------------------------------------
        gui_erp_CSD.run_title = uiextras.HBox('Parent', gui_erp_CSD.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  gui_erp_CSD.run_title);
        gui_erp_CSD.run = uicontrol('Style','pushbutton','Parent',gui_erp_CSD.run_title,...
            'String','Run','callback',@apply_run,'FontSize',FontSize_defualt,'Enable',Enable_label); % 2F
        uiextras.Empty('Parent',  gui_erp_CSD.run_title);
        set(gui_erp_CSD.run_title,'Sizes',[85 90 85]);
        
        gui_erp_CSD.location_title = uiextras.HBox('Parent', gui_erp_CSD.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','pushbutton','Parent',gui_erp_CSD.location_title,...
            'String','?','callback',@tool_link,'FontSize',16,'BackgroundColor',[1 1 1],'Max',10); % 2F
        gui_erp_CSD.location = uicontrol('Style','pushbutton','Parent',gui_erp_CSD.location_title,...
            'String','Expand Locations','callback',@CSD_undock_loct,'FontSize',FontSize_defualt,'BackgroundColor',[1 1 1],'Enable',Enable_label); % 2F
        set(gui_erp_CSD.DataSelBox,'Sizes',[230,40,40,40,30,30]);
    end



%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

    function CSD_undock_loct(~,~)
        %%https://github.com/lucklab/erplab/wiki/Current-Source-Density-(CSD)-tool -browser
        csd_chan_locations;
    end
%%-------------------Setting value for Spline interpolation flexibility m-constant value----------------
    function csd_sif(source,~)
        mcont = str2double(source.String);
        if isnan(mcont)
            gui_erp_CSD.sif_num.String=4;
            beep;
            msgboxText =  ['Convert voltage to CSD - Please ensure that the input was a numeric'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        else
            % input seems valid
            % Save the new  value
            gui_erp_CSD.sif_num.String = mcont;
        end
    end

%%-------------------Setting value for Smoothing constant lambda---------------------------------------
    function csd_scl(source,~)
        mcont = str2double(source.String);
        if isnan(mcont)
            gui_erp_CSD.scl_num.String=4;
            beep;
            msgboxText =  ['Convert voltage to CSD - Please ensure that the input was a numeric'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        else
            % input seems valid
            % Save the new  value
            gui_erp_CSD.scl_num.String = mcont;
        end
    end

%%-------------------setting Head radius CSD rescaling values---------------------------------------
    function csd_hr(source,~)
        mcont = str2double(source.String);
        
        if isnan(mcont)
            gui_erp_CSD.hr_num.String=4;
            beep;
            msgboxText =  ['Convert voltage to CSD - Please ensure that the input was a numeric'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        else
            % input seems valid
            % Save the new  value
            gui_erp_CSD.hr_num.String = mcont;
        end
    end

%%---------------------CSD tool link-------------------------------------
    function tool_link(~,~)
        web('https://github.com/lucklab/erplab/wiki/Current-Source-Density-(CSD)-tool','-browser');
    end
%%---------------------Run-------------------------------------------------
    function apply_run(~,~)
        
        csd_param(1) = str2double(gui_erp_CSD.sif_num.String);
        csd_param(2) = str2double(gui_erp_CSD.scl_num.String);
        csd_param(3) = str2double(gui_erp_CSD.hr_num.String);
        csd_param(4) = 1;
        erpworkingmemory('csd_param',csd_param);
        Selectederp_Index= estudioworkingmemory('selectederpstudio');
        if isempty(Selectederp_Index)
            Selectederp_Index = observe_ERPDAT.CURRENTERP;
            if isempty(Selectederp_Index)
                beep;
                msgboxText =  ['Convert voltage to CSD - No ERPset was selected'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,Selectederp_Index);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
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
            observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
            observe_ERPDAT.Process_messg =2;
            return;
        catch
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
            Selected_ERP_afd =observe_ERPDAT.CURRENTERP;
            estudioworkingmemory('selectederpstudio',Selected_ERP_afd);
            erpworkingmemory('f_ERP_bin_opt',1);
            observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
            observe_ERPDAT.Process_messg =3;%%
        end
        observe_ERPDAT.Two_GUI = observe_ERPDAT.Two_GUI+1;
    end


%%--------Setting current ERPset/session history based on the current updated ERPset------------
    function Count_currentERPChanged(~,~)
        Selectederp_Index= estudioworkingmemory('selectederpstudio');
        if isempty(Selectederp_Index)
            Selectederp_Index = observe_ERPDAT.CURRENTERP;
            
            if isempty(Selectederp_Index)
                beep;
                msgboxText =  ['Convert voltage to CSD - No ERPset was selected'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,Selectederp_Index);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        S_binchan =  estudioworkingmemory('geterpbinchan');
        checked_ERPset_Index = S_binchan.checked_ERPset_Index;
        
        if strcmp(observe_ERPDAT.ALLERP(1).erpname,'No ERPset loaded')
            checked_curr_index = 1;
        else
            checked_curr_index = 0;
        end
        if isempty(checked_ERPset_Index)
            checked_ERPset_Index = f_checkerpsets(observe_ERPDAT.ALLERP,Selectederp_Index);
        end
        if checked_curr_index || any(checked_ERPset_Index(:))
            Enable_label = 'off';
            
        else
            Enable_label = 'on';
            
        end
        gui_erp_CSD.run.Enable = Enable_label;
        gui_erp_CSD.sif_num.Enable = Enable_label;
        gui_erp_CSD.scl_num.Enable = Enable_label;
        gui_erp_CSD.hr_num.Enable = Enable_label;
        gui_erp_CSD.location.Enable = Enable_label;
    end
end