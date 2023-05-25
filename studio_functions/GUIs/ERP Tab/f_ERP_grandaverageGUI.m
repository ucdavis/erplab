%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 2022

% ERPLAB Studio

function varargout = f_ERP_grandaverageGUI(varargin)
global observe_ERPDAT;
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);


gui_erp_grdavg = struct();

%-----------------------------Name the title----------------------------------------------
% global ERP_grdavg_gui;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    ERP_grdavg_gui = uiextras.BoxPanel('Parent', fig, 'Title', 'Average across ERPsets ', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    ERP_grdavg_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Average across ERPsets ', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    ERP_grdavg_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Average across ERPsets ', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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
drawui_erp_bin_operation(FonsizeDefault)
varargout{1} = ERP_grdavg_gui;

    function drawui_erp_bin_operation(FonsizeDefault)
        FontSize_defualt = FonsizeDefault;
        
        if strcmp(observe_ERPDAT.ALLERP(1).erpname,'No ERPset loaded')
            Enable_label = 'off';
        else
            Enable_label = 'on';
        end
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        gui_erp_grdavg.DataSelBox = uiextras.VBox('Parent', ERP_grdavg_gui,'BackgroundColor',ColorB_def);
        
        %%Parameters
        gui_erp_grdavg.weigavg_title = uiextras.HBox('Parent', gui_erp_grdavg.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_grdavg.weigavg = uicontrol('Style','checkbox','Parent', gui_erp_grdavg.weigavg_title,...
            'String','Use weighted average based on trial numbers','Value',0,...
            'callback',@checkbox_weigavg,'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        
        gui_erp_grdavg.excldnullbin_title = uiextras.HBox('Parent', gui_erp_grdavg.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_grdavg.excldnullbin = uicontrol('Style','checkbox','Parent', gui_erp_grdavg.excldnullbin_title,...
            'String','','Value',0,'Enable','off','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        gui_erp_grdavg.excldnullbin.String =  '<html>Exclude any null bin from non-weighted <br />averaing (recommended)</html>';
        
        
        gui_erp_grdavg.jacknife_title = uiextras.HBox('Parent', gui_erp_grdavg.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_grdavg.jacknife = uicontrol('Style','checkbox','Parent', gui_erp_grdavg.jacknife_title,...
            'String','','Value',0,'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        gui_erp_grdavg.jacknife.String =  '<html>Include Jackknife subaverages (creates<br />  multiple ERPsets)</html>';
        
        
        gui_erp_grdavg.warn_title = uiextras.HBox('Parent', gui_erp_grdavg.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_grdavg.warn = uicontrol('Style','checkbox','Parent', gui_erp_grdavg.warn_title,...
            'String','','Value',0,'callback',@checkbox_warn,'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        gui_erp_grdavg.warn.String =  '<html>Warning if any subjects who exceed<br /> the epoch rejection threshold (%) </html>';
        gui_erp_grdavg.warn_edit = uicontrol('Style','edit','Parent', gui_erp_grdavg.warn_title,...
            'String','','callback',@warn_edit,'FontSize',FontSize_defualt,'Enable',Enable_label); % 2F
        %         set(gui_erp_grdavg.hr_title,'Sizes',[210,50]);
        set(gui_erp_grdavg.warn_title,'Sizes',[220,70]);
        
        
        gui_erp_grdavg.cmpsd_title = uiextras.HBox('Parent', gui_erp_grdavg.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_grdavg.cmpsd = uicontrol('Style','checkbox','Parent', gui_erp_grdavg.cmpsd_title,...
            'String','Compute point-by-point SEM','Value',1,'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        
        
        gui_erp_grdavg.cbdatq_title = uiextras.HBox('Parent', gui_erp_grdavg.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_grdavg.cbdatq = uicontrol('Style','checkbox','Parent', gui_erp_grdavg.cbdatq_title,...
            'String','','Value',1,'callback',@checkbox_cbdatq,'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        gui_erp_grdavg.cbdatq.String =  '<html>Combine data <br /> quality measures </html>';
        
        gui_erp_grdavg.cbdatq_def = uicontrol('Style','radiobutton','Parent', gui_erp_grdavg.cbdatq_title,...
            'String','defaults','Value',1,'callback',@cbdatq_def,'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        
        gui_erp_grdavg.cbdatq_custom = uicontrol('Style','radiobutton','Parent', gui_erp_grdavg.cbdatq_title,...
            'String','custom combo','Value',0,'callback',@cbdatq_custom,'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        gui_erp_grdavg.cbdatq_custom.String =  '<html>custom<br /> combo </html>';
        set(gui_erp_grdavg.cbdatq_title,'Sizes',[120 70 70]);
        
        gui_erp_grdavg.cbdatq_custom_option_title = uiextras.HBox('Parent', gui_erp_grdavg.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  gui_erp_grdavg.cbdatq_custom_option_title);
        gui_erp_grdavg.cbdatq_custom_op = uicontrol('Style','pushbutton','Parent', gui_erp_grdavg.cbdatq_custom_option_title,...
            'String','set custom DQ combo','callback',@cbdatq_custom_op,'Enable','off','FontSize',FontSize_defualt,'BackgroundColor',[1 1 1]); % 2F
        
        gui_erp_grdavg.location_title = uiextras.HBox('Parent', gui_erp_grdavg.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',gui_erp_grdavg.location_title);
        uicontrol('Style','pushbutton','Parent',gui_erp_grdavg.location_title,...
            'String','?','callback',@tool_link,'FontSize',16,'BackgroundColor',[1 1 1],'Max',10); % 2F
        uiextras.Empty('Parent',gui_erp_grdavg.location_title);
        gui_erp_grdavg.run = uicontrol('Style','pushbutton','Parent',gui_erp_grdavg.location_title,...
            'String','Run','callback',@apply_run,'FontSize',FontSize_defualt,'Enable',Enable_label);
        uiextras.Empty('Parent',gui_erp_grdavg.location_title);
        set(gui_erp_grdavg.location_title,'Sizes',[20 95 30 95 20]);
        
        set(gui_erp_grdavg.DataSelBox,'Sizes',[25,30,30,30,25,30,25,30]);
    end



%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%



%%---------------checkbox for weighted average-----------------------------
    function checkbox_weigavg(source,~)
        if ~source.Value
            set(gui_erp_grdavg.excldnullbin,'Enable','on','Value',0);
        else
            set(gui_erp_grdavg.excldnullbin,'Enable','off','Value',0);
        end
    end

%%-------------------checkbox for warning----------------------------------
    function checkbox_warn(source,~)
        if ~source.Value
            gui_erp_grdavg.warn_edit.Enable = 'off';
        else
            gui_erp_grdavg.warn_edit.Enable = 'on';
        end
    end


%%%%----------------checkbox for combining data quality measures-----------
    function checkbox_cbdatq(source,~)
        checkad = source.Value;
        if checkad
            gui_erp_grdavg.cbdatq_custom.Value = 0;
            gui_erp_grdavg.cbdatq_def.Value = 1;
            gui_erp_grdavg.cbdatq_custom_op.Enable = 'off';
            gui_erp_grdavg.cbdatq_def.Enable = 'on';
            gui_erp_grdavg.cbdatq_custom.Enable = 'on';
        else
            gui_erp_grdavg.cbdatq_custom.Enable = 'off';
            gui_erp_grdavg.cbdatq_def.Enable = 'off';
            gui_erp_grdavg.cbdatq_custom_op.Enable = 'off';
        end
    end
%%%%----------------default setting for combining data quality measures----
    function cbdatq_def(~,~)
        gui_erp_grdavg.cbdatq_custom.Value = 0;
        gui_erp_grdavg.cbdatq_def.Value = 1;
        gui_erp_grdavg.cbdatq_custom_op.Enable = 'off';
    end

%%%%----------------Custom setting for combining data quality measures----
    function cbdatq_custom(~,~)
        gui_erp_grdavg.cbdatq_custom.Value = 1;
        gui_erp_grdavg.cbdatq_def.Value = 0;
        gui_erp_grdavg.cbdatq_custom_op.Enable = 'on';
    end

%%-----------------define the epoch rejection threshold (%) ----------------------------
    function warn_edit(source,~)
        rejection_peft = str2num(source.String);
        if isempty(rejection_peft)
            gui_erp_grdavg.warn_edit.String = '';
            beep;
            msgboxText =  ['Average across ERPsets - Invalid artifact detection proportion.\n'...
                'Please, enter a number between 0 and 100.'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        if rejection_peft<0 || rejection_peft>100
            gui_erp_grdavg.warn_edit.String = '';
            beep;
            msgboxText =  ['Average across ERPsets - Invalid artifact detection proportion.\n'...
                'Please, enter a number between 0 and 100.'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
    end

%%-----------Setting for custom DQ combo----------------------------------
    function cbdatq_custom_op(~,~)
        
        GAv_combo_defaults.measures = [1, 2, 3]; % Use first 3 DQ measures
        GAv_combo_defaults.methods = [2, 2, 2]; % Use the 2nd combo method, Root-Mean Square, for each
        GAv_combo_defaults.measure_names = {'Baseline Measure - SD';'Point-wise SEM'; 'aSME'};
        GAv_combo_defaults.method_names = {'Pool ERPSETs, GrandAvg mean','Pool ERPSETs, GrandAvg RMS'};
        GAv_combo_defaults.str = {'Baseline Measure - SD, GrandAvg RMS';'Point-wise SEM, GrandAvg RMS'; 'aSME GrandAvg RMS'};
        custom_spec  = grandaverager_DQ(GAv_combo_defaults);
        estudioworkingmemory('grandavg_custom_DQ',custom_spec);
    end
%%---------------------CSD tool link-------------------------------------
    function tool_link(~,~)
        web('https://github.com/lucklab/erplab/wiki/Averaging-Across-ERPSETS-_-Creating-Grand-Averages','-browser');
    end


%%---------------------Run-------------------------------------------------
    function apply_run(~,~)
        pathName_def =  erpworkingmemory('ERP_save_folder');
        if isempty(pathName_def)
            pathName_def =cd;
        end
        
        Selectederp_Index= estudioworkingmemory('selectederpstudio');
        if isempty(Selectederp_Index)
            Selectederp_Index = observe_ERPDAT.CURRENTERP;
            if isempty(Selectederp_Index)
                beep;
                msgboxText =  ['Average across ERPsets - No ERPset was selected'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,Selectederp_Index);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        
        
        if numel(Selectederp_Index)<2
            beep;
            msgboxText =  ['Average across ERPsets - Two ERPsets,at least,were selected'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        optioni    = 0; %1 means from a filelist, 0 means from erpsets menu
        
        erpset     = Selectederp_Index;
        if gui_erp_grdavg.warn.Value
            artcrite = str2num(gui_erp_grdavg.warn_edit.String);
        else
            artcrite = 100;
        end
        
        if isempty(artcrite) || artcrite<0 || artcrite>100
            beep;
            msgboxText =  ['Average across ERPsets - Invalid artifact detection proportion.\n'...
                'Please, enter a number between 0 and 100.'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
        %%Send message to Message panel
        erpworkingmemory('f_ERP_proces_messg','Average across ERPsets');
        observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
        
        Weightedg =  gui_erp_grdavg.weigavg.Value;
        wavg       = gui_erp_grdavg.warn.Value; % 0;1
        excnullbin = gui_erp_grdavg.excldnullbin.Value; % 0;1
        stderror   = gui_erp_grdavg.cmpsd.Value; % 0;1
        jk         = gui_erp_grdavg.jacknife.Value; % 0;1
        if jk
            Answer = f_ERP_save_single_file(strcat('_jackknife'),'',length(observe_ERPDAT.ALLERP)+1);
        else
            Answer = f_ERP_save_single_file(strcat('grand'),'',length(observe_ERPDAT.ALLERP)+1);
        end
        if isempty(Answer)
            beep;
            disp('User selectd cancal');
            return;
        end
        erpName_new = '';
        fileName_new = '';
        pathName_new = pathName_def;
        Save_file_label =0;
        if ~isempty(Answer)
            ERPName = Answer{1};
            if ~isempty(ERPName)
                erpName_new = ERPName;
            end
            fileName_full = Answer{2};
            if isempty(fileName_full)
                fileName_new = '';
                Save_file_label =0;
            elseif ~isempty(fileName_full)
                
                [pathstr, file_name, ext] = fileparts(fileName_full);
                ext = '.erp';
                if strcmp(pathstr,'')
                    pathstr = pathName_def;
                end
                fileName_new = [file_name,ext];
                pathName_new = pathstr;
                Save_file_label =1;
            end
        end
        
        if jk
            jkerpname = erpName_new;
            jkfilename =fileName_new ;
        else
            jkerpname  = ''; % erpname for JK grand averages
            jkfilename = ''; % filename for JK grand averages
        end
        
        
        GAv_combo_defaults.measures = [1, 2, 3]; % Use first 3 DQ measures
        GAv_combo_defaults.methods = [2, 2, 2]; % Use the 2nd combo method, Root-Mean Square, for each
        GAv_combo_defaults.measure_names = {'Baseline Measure - SD';'Point-wise SEM'; 'aSME'};
        GAv_combo_defaults.method_names = {'Pool ERPSETs, GrandAvg mean','Pool ERPSETs, GrandAvg RMS'};
        GAv_combo_defaults.str = {'Baseline Measure - SD, GrandAvg RMS';'Point-wise SEM, GrandAvg RMS'; 'aSME GrandAvg RMS'};
        if  ~gui_erp_grdavg.cbdatq.Value
            dq_option  = 0; % data quality combine option. 0 - off, 1 - on/default, 2 - on/custom
        elseif gui_erp_grdavg.cbdatq.Value && gui_erp_grdavg.cbdatq_def.Value
            dq_option  = 1;
            
            dq_spec = GAv_combo_defaults;
        elseif gui_erp_grdavg.cbdatq.Value && gui_erp_grdavg.cbdatq_custom.Value
            dq_option  = 2;
            dq_spec = estudioworkingmemory('grandavg_custom_DQ');
            if isempty(dq_spec)
                dq_spec = GAv_combo_defaults;
            end
        end
        
        if stderror==1
            stdsstr = 'on';
        else
            stdsstr = 'off';
        end
        if excnullbin==1
            excnullbinstr = 'on'; % exclude null bins.
        else
            excnullbinstr = 'off';
        end
        if wavg==1
            wavgstr = 'on';
        else
            wavgstr = 'off';
        end
        if Weightedg
            Weightedstr = 'on';
        else
            Weightedstr = 'off';
        end
        
        ALLERPCOM = evalin('base','ALLERPCOM');
        try
            ALLERP = observe_ERPDAT.ALLERP;
            if jk==1 % Jackknife
                
                [ALLERP, ERPCOM]  = pop_jkgaverager(ALLERP, 'Erpsets', erpset, 'Criterion', artcrite,...
                    'SEM', stdsstr, 'Weighted', Weightedstr, 'Erpname', jkerpname, 'Filename', jkfilename,...
                    'DQ_flag',dq_option,'DQ_spec',dq_spec,'Warning', wavgstr);
                Selected_ERP_afd = setdiff([1:length(ALLERP)],[1:length(observe_ERPDAT.ALLERP)]);
                observe_ERPDAT.ALLERP = ALLERP;
                observe_ERPDAT.CURRENTERP = Selected_ERP_afd(1);
                observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
                estudioworkingmemory('selectederpstudio',Selected_ERP_afd);
                
                if Save_file_label==1
                    for Numofselectederp =1:numel(Selected_ERP_afd)
                        ERP_save = observe_ERPDAT.ALLERP(Selected_ERP_afd(Numofselectederp));
                        ERP_save.filepath = pathName_new;
                        [ERP, issave, ERPCOM] = pop_savemyerp(ERP_save, 'erpname', ERP_save.erpname, 'filename', ERP_save.erpname, 'filepath',ERP_save.filepath);
                    end
                    [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                end
                
            else
                [ERP, ERPCOM]  = pop_gaverager(ALLERP, 'Erpsets', erpset,'Criterion', artcrite, 'SEM', stdsstr,...
                    'ExcludeNullBin', excnullbinstr,'Weighted', Weightedstr, 'Saveas', 'off',...
                    'DQ_flag',dq_option,'DQ_spec',dq_spec,'Warning', wavgstr, 'History', 'gui');
                ERP.erpname = erpName_new;
                ERP.filename = fileName_new;
                ERP.filepath = pathName_new;
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);
                %                 [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                observe_ERPDAT.ALLERP(length(observe_ERPDAT.ALLERP)+1) = ERP;
                Selected_ERP_afd = length(observe_ERPDAT.ALLERP);
                observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
                observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
                estudioworkingmemory('selectederpstudio',Selected_ERP_afd);
                if Save_file_label==1
                    [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', ERP.filename, 'filepath',ERP.filepath);
                    [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                end
            end
            
            assignin('base','ALLERPCOM',ALLERPCOM);
            assignin('base','ERPCOM',ERPCOM);
            erpworkingmemory('f_ERP_bin_opt',1);
            observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
            observe_ERPDAT.Process_messg =2;
        catch
            msgboxText =  ['Please check all the parameters are correct!!!'];
            title = 'EStudio: "Average across ERPsets" panel.';
            errorfound(sprintf(msgboxText), title);
            observe_ERPDAT.Process_messg =3;
            return;
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
                msgboxText =  ['Average across ERPsets - No ERPset was selected'];
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
        gui_erp_grdavg.weigavg.Enable = Enable_label;
        if gui_erp_grdavg.weigavg.Value
            gui_erp_grdavg.excldnullbin.Enable = 'off';
        end
        gui_erp_grdavg.excldnullbin.Enable = Enable_label;
        gui_erp_grdavg.jacknife.Enable = Enable_label;
        gui_erp_grdavg.warn.Enable = Enable_label;
        gui_erp_grdavg.warn_edit.Enable = Enable_label;
        if gui_erp_grdavg.warn.Value
            gui_erp_grdavg.warn_edit.Enable ='on';
        else
            gui_erp_grdavg.warn_edit.Enable ='off';
        end
        gui_erp_grdavg.cbdatq.Enable = Enable_label;
        gui_erp_grdavg.cbdatq_def.Enable = Enable_label;
        gui_erp_grdavg.cbdatq_custom.Enable = Enable_label;
        if  gui_erp_grdavg.cbdatq.Value && gui_erp_grdavg.cbdatq_custom.Value
            gui_erp_grdavg.cbdatq_custom_op.Enable = 'on';
        elseif  gui_erp_grdavg.cbdatq.Value==0
            gui_erp_grdavg.cbdatq_custom_op.Enable = 'off';
            gui_erp_grdavg.cbdatq_custom.Enable = 'off';
            gui_erp_grdavg.cbdatq_def.Enable = 'off';
        end
        
        gui_erp_grdavg.advanced.Enable = Enable_label;
        gui_erp_grdavg.run.Enable = Enable_label;
    end
end