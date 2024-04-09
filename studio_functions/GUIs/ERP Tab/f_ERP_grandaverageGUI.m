%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 2022 && Nov. 2023

% ERPLAB Studio

function varargout = f_ERP_grandaverageGUI(varargin)
global observe_ERPDAT;
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);
addlistener(observe_ERPDAT,'erp_two_panels_change',@erp_two_panels_change);
addlistener(observe_ERPDAT,'Reset_erp_panel_change',@Reset_erp_panel_change);

gui_erp_grdavg = struct();
%-----------------------------Name the title----------------------------------------------
% global ERP_grdavg_box_gui;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    ERP_grdavg_box_gui = uiextras.BoxPanel('Parent', fig, 'Title', 'Average Across ERPsets (Grand Average)  ', 'Padding', 5,...
        'BackgroundColor',ColorB_def); % Create boxpanel  tool_link
elseif nargin == 1
    ERP_grdavg_box_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Average Across ERPsets (Grand Average)  ',...
        'Padding', 5,'BackgroundColor',ColorB_def);
else
    ERP_grdavg_box_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Average Across ERPsets (Grand Average)  ',...
        'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);%, 'HelpFcn', @tool_link
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
varargout{1} = ERP_grdavg_box_gui;

    function drawui_erp_bin_operation(FonsizeDefault)
        FontSize_defualt = FonsizeDefault;
        Enable_label = 'off';
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        gui_erp_grdavg.DataSelBox = uiextras.VBox('Parent', ERP_grdavg_box_gui,'BackgroundColor',ColorB_def);
        
        %%Parameters
        gui_erp_grdavg.weigavg_title = uiextras.HBox('Parent', gui_erp_grdavg.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_grdavg.weigavg = uicontrol('Style','checkbox','Parent', gui_erp_grdavg.weigavg_title,...
            'String','Use weighted average based on trial numbers','Value',0,'Enable','off',...
            'callback',@checkbox_weigavg,'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        gui_erp_grdavg.weigavg.KeyPressFcn = @erp_graverage_presskey;
        gui_erp_grdavg.paras{1} = gui_erp_grdavg.weigavg.Value;
        
        gui_erp_grdavg.excldnullbin_title = uiextras.HBox('Parent', gui_erp_grdavg.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_grdavg.excldnullbin = uicontrol('Style','checkbox','Parent', gui_erp_grdavg.excldnullbin_title,...
            'callback',@excldnullbin,'String','','Value',1,'Enable','off','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        gui_erp_grdavg.excldnullbin.String =  '<html>Exclude any null bin from non-weighted <br />averaing (recommended)</html>';
        gui_erp_grdavg.excldnullbin.KeyPressFcn = @erp_graverage_presskey;
        gui_erp_grdavg.paras{2} = gui_erp_grdavg.excldnullbin.Value;
        
        gui_erp_grdavg.jacknife_title = uiextras.HBox('Parent', gui_erp_grdavg.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_grdavg.jacknife = uicontrol('Style','checkbox','Parent', gui_erp_grdavg.jacknife_title,...
            'String','','callback',@jacknife,'Value',0,'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable','off'); % 2F
        gui_erp_grdavg.jacknife.String =  '<html>Include Jackknife subaverages (creates<br />  multiple ERPsets)</html>';
        gui_erp_grdavg.jacknife.KeyPressFcn = @erp_graverage_presskey;
        gui_erp_grdavg.paras{3} = gui_erp_grdavg.jacknife.Value;
        
        gui_erp_grdavg.warn_title = uiextras.HBox('Parent', gui_erp_grdavg.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_grdavg.warn = uicontrol('Style','checkbox','Parent', gui_erp_grdavg.warn_title,'Enable','off',...
            'String','','Value',0,'callback',@checkbox_warn,'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        gui_erp_grdavg.warn.KeyPressFcn = @erp_graverage_presskey;
        gui_erp_grdavg.paras{4} = gui_erp_grdavg.warn.Value;
        gui_erp_grdavg.warn.String =  '<html>Warning if any subjects who exceed<br /> the epoch rejection threshold (%) </html>';
        gui_erp_grdavg.warn_edit = uicontrol('Style','edit','Parent', gui_erp_grdavg.warn_title,'Enable','off',...
            'String','','callback',@warn_edit,'FontSize',FontSize_defualt,'Enable',Enable_label); % 2F
        gui_erp_grdavg.warn_edit.KeyPressFcn = @erp_graverage_presskey;
        gui_erp_grdavg.paras{5} = str2num(gui_erp_grdavg.warn_edit.String);
        set(gui_erp_grdavg.warn_title,'Sizes',[220,70]);
        
        
        gui_erp_grdavg.cmpsd_title = uiextras.HBox('Parent', gui_erp_grdavg.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_grdavg.cmpsd = uicontrol('Style','checkbox','Parent', gui_erp_grdavg.cmpsd_title,'Enable','off',...
            'String','Compute point-by-point SEM','Value',1,'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        gui_erp_grdavg.cmpsd.KeyPressFcn = @erp_graverage_presskey;
        gui_erp_grdavg.paras{6} = gui_erp_grdavg.cmpsd.Value;
        gui_erp_grdavg.cbdatq_title = uiextras.HBox('Parent', gui_erp_grdavg.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_grdavg.cbdatq = uicontrol('Style','checkbox','Parent', gui_erp_grdavg.cbdatq_title,'Enable','off',...
            'String','','Value',1,'callback',@checkbox_cbdatq,'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        gui_erp_grdavg.cbdatq.String =  '<html>Combine data <br /> quality measures </html>';
        gui_erp_grdavg.cbdatq.KeyPressFcn = @erp_graverage_presskey;
        gui_erp_grdavg.paras{7} = gui_erp_grdavg.cbdatq.Value;
        
        gui_erp_grdavg.cbdatq_def = uicontrol('Style','radiobutton','Parent', gui_erp_grdavg.cbdatq_title,'Enable','off',...
            'String','defaults','Value',1,'callback',@cbdatq_def,'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        gui_erp_grdavg.cbdatq_def.KeyPressFcn = @erp_graverage_presskey;
        gui_erp_grdavg.paras{8} = gui_erp_grdavg.cbdatq_def.Value;
        
        gui_erp_grdavg.cbdatq_custom = uicontrol('Style','radiobutton','Parent', gui_erp_grdavg.cbdatq_title,'Enable','off',...
            'String','custom combo','Value',0,'callback',@cbdatq_custom,'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        gui_erp_grdavg.cbdatq_custom.String =  '<html>custom<br /> combo </html>';
        set(gui_erp_grdavg.cbdatq_title,'Sizes',[120 70 70]);
        gui_erp_grdavg.cbdatq_custom.KeyPressFcn = @erp_graverage_presskey;
        
        gui_erp_grdavg.cbdatq_custom_option_title = uiextras.HBox('Parent', gui_erp_grdavg.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  gui_erp_grdavg.cbdatq_custom_option_title);
        gui_erp_grdavg.cbdatq_custom_op = uicontrol('Style','pushbutton','Parent', gui_erp_grdavg.cbdatq_custom_option_title,...
            'String','set custom DQ combo','callback',@cbdatq_custom_op,'Enable','off','FontSize',FontSize_defualt,'BackgroundColor',[1 1 1]); % 2F
        
        gui_erp_grdavg.location_title = uiextras.HBox('Parent', gui_erp_grdavg.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',gui_erp_grdavg.location_title);
        gui_erp_grdavg.cancel  = uicontrol('Style','pushbutton','Parent',gui_erp_grdavg.location_title,'Enable','off',...
            'String','Cancel','callback',@average_cancel,'FontSize',FontSize_defualt,'BackgroundColor',[1 1 1],'Max',10); % 2F
        uiextras.Empty('Parent',gui_erp_grdavg.location_title);
        gui_erp_grdavg.run = uicontrol('Style','pushbutton','Parent',gui_erp_grdavg.location_title,'Enable','off',...
            'String','Run','callback',@apply_run,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent',gui_erp_grdavg.location_title);
        set(gui_erp_grdavg.location_title,'Sizes',[20 95 30 95 20]);
        
        set(gui_erp_grdavg.DataSelBox,'Sizes',[25,30,30,30,25,30,25,30]);
        estudioworkingmemory('ERPTab_gravg',0);
        
    end

%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%---------------checkbox for weighted average-----------------------------
    function checkbox_weigavg(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=11
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_gravg',1);
        gui_erp_grdavg.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_grdavg.run.ForegroundColor = [1 1 1];
        ERP_grdavg_box_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_grdavg.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_grdavg.cancel.ForegroundColor = [1 1 1];
        if ~source.Value
            set(gui_erp_grdavg.excldnullbin,'Enable','on','Value',0);
        else
            set(gui_erp_grdavg.excldnullbin,'Enable','off','Value',0);
        end
    end

    function jacknife(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=11
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_gravg',1);
        gui_erp_grdavg.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_grdavg.run.ForegroundColor = [1 1 1];
        ERP_grdavg_box_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_grdavg.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_grdavg.cancel.ForegroundColor = [1 1 1];
    end

%%-------------------------------------------------------------------------
    function excldnullbin(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=11
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_gravg',1);
        gui_erp_grdavg.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_grdavg.run.ForegroundColor = [1 1 1];
        ERP_grdavg_box_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_grdavg.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_grdavg.cancel.ForegroundColor = [1 1 1];
    end
%%-------------------checkbox for warning----------------------------------
    function checkbox_warn(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=11
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_gravg',1);
        gui_erp_grdavg.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_grdavg.run.ForegroundColor = [1 1 1];
        ERP_grdavg_box_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_grdavg.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_grdavg.cancel.ForegroundColor = [1 1 1];
        if ~source.Value
            gui_erp_grdavg.warn_edit.Enable = 'off';
        else
            gui_erp_grdavg.warn_edit.Enable = 'on';
        end
    end


%%%%----------------checkbox for combining data quality measures-----------
    function checkbox_cbdatq(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=11
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_gravg',1);
        gui_erp_grdavg.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_grdavg.run.ForegroundColor = [1 1 1];
        ERP_grdavg_box_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_grdavg.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_grdavg.cancel.ForegroundColor = [1 1 1];
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
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=11
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_gravg',1);
        gui_erp_grdavg.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_grdavg.run.ForegroundColor = [1 1 1];
        ERP_grdavg_box_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_grdavg.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_grdavg.cancel.ForegroundColor = [1 1 1];
        gui_erp_grdavg.cbdatq_custom.Value = 0;
        gui_erp_grdavg.cbdatq_def.Value = 1;
        gui_erp_grdavg.cbdatq_custom_op.Enable = 'off';
    end

%%%%----------------Custom setting for combining data quality measures----
    function cbdatq_custom(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=11
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_gravg',1);
        gui_erp_grdavg.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_grdavg.run.ForegroundColor = [1 1 1];
        ERP_grdavg_box_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_grdavg.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_grdavg.cancel.ForegroundColor = [1 1 1];
        gui_erp_grdavg.cbdatq_custom.Value = 1;
        gui_erp_grdavg.cbdatq_def.Value = 0;
        gui_erp_grdavg.cbdatq_custom_op.Enable = 'on';
    end

%%-----------------define the epoch rejection threshold (%) ----------------------------
    function warn_edit(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=11
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_gravg',1);
        gui_erp_grdavg.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_grdavg.run.ForegroundColor = [1 1 1];
        ERP_grdavg_box_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_grdavg.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_grdavg.cancel.ForegroundColor = [1 1 1];
        rejection_peft = str2num(source.String);
        if isempty(rejection_peft)
            gui_erp_grdavg.warn_edit.String = '';
            msgboxText =  ['Average Across ERPsets (Grand Average)  - Invalid artifact detection proportion.',32,...
                'Please, enter a number between 0 and 100.'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        if rejection_peft<0 || rejection_peft>100
            gui_erp_grdavg.warn_edit.String = '';
            msgboxText =  ['Average Across ERPsets (Grand Average)  - Invalid artifact detection proportion.',32,...
                'Please, enter a number between 0 and 100.'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
    end

%%-----------Setting for custom DQ combo----------------------------------
    function cbdatq_custom_op(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=11
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_gravg',1);
        gui_erp_grdavg.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_grdavg.run.ForegroundColor = [1 1 1];
        ERP_grdavg_box_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_grdavg.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_grdavg.cancel.ForegroundColor = [1 1 1];
        
        ERPArray= estudioworkingmemory('selectederpstudio');
        if isempty(ERPArray) || any(ERPArray>length(observe_ERPDAT.ALLERP))
            ERPArray = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            estudioworkingmemory('selectederpstudio',ERPArray);
        end
        
        custom_spec  = grandaverager_DQ(observe_ERPDAT.ALLERP(ERPArray));
        estudioworkingmemory('grandavg_custom_DQ',custom_spec);
    end

%%--------------------------------cancel-----------------------------------
    function average_cancel(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=11
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_gravg',0);
        gui_erp_grdavg.run.BackgroundColor =  [1 1 1];
        gui_erp_grdavg.run.ForegroundColor = [0 0 0];
        ERP_grdavg_box_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_grdavg.cancel.BackgroundColor =  [1 1 1];
        gui_erp_grdavg.cancel.ForegroundColor = [0 0 0];
        try weigavg = gui_erp_grdavg.paras{1}; catch weigavg=0; gui_erp_grdavg.paras{1}=0; end
        if isempty(weigavg) || numel(weigavg)~=1 || (weigavg~=0 && weigavg~=1)
            gui_erp_grdavg.paras{1}=0;weigavg=0;
        end
        gui_erp_grdavg.weigavg.Value=weigavg;
        if ~weigavg
            set(gui_erp_grdavg.excldnullbin,'Enable','on','Value',0);
        else
            set(gui_erp_grdavg.excldnullbin,'Enable','off','Value',0);
        end
        try excldnullbin = gui_erp_grdavg.paras{2}; catch excldnullbin=0; gui_erp_grdavg.paras{2}=0; end
        if isempty(excldnullbin) || numel(excldnullbin)~=1 || (excldnullbin~=0 && excldnullbin~=1)
            gui_erp_grdavg.paras{2}=0;excldnullbin=0;
        end
        gui_erp_grdavg.excldnullbin.Value=excldnullbin;
        
        try jacknife = gui_erp_grdavg.paras{3}; catch jacknife=0; gui_erp_grdavg.paras{3}=0; end
        if isempty(jacknife) || numel(jacknife)~=1 || (jacknife~=0 && jacknife~=1)
            gui_erp_grdavg.paras{3}=0;jacknife=0;
        end
        gui_erp_grdavg.jacknife.Value =jacknife;
        
        try warnValue = gui_erp_grdavg.paras{4}; catch warnValue=0; gui_erp_grdavg.paras{4}=0; end
        if isempty(warnValue) || numel(warnValue)~=1 || (warnValue~=0 && warnValue~=1)
            gui_erp_grdavg.paras{4}=0;warnValue=0;
        end
        gui_erp_grdavg.warn.Value=warnValue;
        if warnValue==1
            gui_erp_grdavg.warn_edit.Enable = 'on';
        else
            gui_erp_grdavg.warn_edit.Enable = 'off';
        end
        try warn_edit = gui_erp_grdavg.paras{5}; catch warn_edit=[]; gui_erp_grdavg.paras{5}=[]; end
        if numel(warn_edit)~=1 || any(warn_edit>100) || any(warn_edit<0)
            warn_edit=[]; gui_erp_grdavg.paras{5}=[];
        end
        gui_erp_grdavg.warn_edit.String = num2str(warn_edit);
        
        try cmpsd = gui_erp_grdavg.paras{6}; catch cmpsd=1; gui_erp_grdavg.paras{6}=1; end
        if isempty(cmpsd) || numel(cmpsd)~=1 || (cmpsd~=0 && cmpsd~=1)
            gui_erp_grdavg.paras{6}=1;cmpsd=1;
        end
        gui_erp_grdavg.cmpsd.Value =cmpsd;
        
        try cbdatq = gui_erp_grdavg.paras{7}; catch cbdatq=1; gui_erp_grdavg.paras{7}=1; end
        if isempty(cbdatq) || numel(cbdatq)~=1 || (cbdatq~=0 && cbdatq~=1)
            gui_erp_grdavg.paras{7}=1;cbdatq=1;
        end
        gui_erp_grdavg.cbdatq.Value=cbdatq;
        
        try cbdatq_def = gui_erp_grdavg.paras{8}; catch cbdatq_def=1; gui_erp_grdavg.paras{8}=1; end
        if isempty(cbdatq_def) || numel(cbdatq_def)~=1 || (cbdatq_def~=0 && cbdatq_def~=1)
            gui_erp_grdavg.paras{8}=0;cbdatq_def=1;
        end
        gui_erp_grdavg.cbdatq_def.Value=cbdatq_def;
        gui_erp_grdavg.cbdatq_custom.Value= ~cbdatq_def;
        if cbdatq_def==1
            gui_erp_grdavg.cbdatq_custom_op.Enable = 'off';
        else
            gui_erp_grdavg.cbdatq_custom_op.Enable = 'on';
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
        if ~isempty(messgStr) && eegpanelIndex~=11
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        pathName_def =  estudioworkingmemory('ERP_save_folder');
        if isempty(pathName_def)
            pathName_def =cd;
        end
        ERPArray= estudioworkingmemory('selectederpstudio');
        if isempty(ERPArray) || any(ERPArray>length(observe_ERPDAT.ALLERP))
            ERPArray = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            estudioworkingmemory('selectederpstudio',ERPArray);
        end
        
        if numel(ERPArray)<2
            msgboxText =  ['Average Across ERPsets (Grand Average)  - Two ERPsets,at least,were selected'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        optioni    = 0; %1 means from a filelist, 0 means from erpsets menu
        erpset     = ERPArray;
        if gui_erp_grdavg.warn.Value
            artcrite = str2num(gui_erp_grdavg.warn_edit.String);
        else
            artcrite = 100;
        end
        if isempty(artcrite) || artcrite<0 || artcrite>100
            msgboxText =  ['Average Across ERPsets (Grand Average)  - Invalid artifact detection proportion.',32,...
                'Please, enter a number between 0 and 100.'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        estudioworkingmemory('ERPTab_gravg',0);
        gui_erp_grdavg.run.BackgroundColor =  [1 1 1];
        gui_erp_grdavg.run.ForegroundColor = [0 0 0];
        ERP_grdavg_box_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_grdavg.cancel.BackgroundColor =  [1 1 1];
        gui_erp_grdavg.cancel.ForegroundColor = [0 0 0];
        
        %%Send message to Message panel
        estudioworkingmemory('f_ERP_proces_messg','Average Across ERPsets (Grand Average) ');
        observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
        
        Weightedg =  gui_erp_grdavg.weigavg.Value;
        wavg       = gui_erp_grdavg.warn.Value; % 0;1
        excnullbin = gui_erp_grdavg.excldnullbin.Value; % 0;1
        stderror   = gui_erp_grdavg.cmpsd.Value; % 0;1
        jk         = gui_erp_grdavg.jacknife.Value; % 0;1
        if jk
            Answer = f_ERP_save_single_file(strcat('jackknife'),'',length(observe_ERPDAT.ALLERP)+1);
        else
            Answer = f_ERP_save_single_file(strcat('grand'),'',length(observe_ERPDAT.ALLERP)+1);
        end
        if isempty(Answer)
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
            dq_spec = GAv_combo_defaults;
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
        
        try ALLERPCOM = evalin('base','ALLERPCOM');catch ALLERPCOM = []; end;
        ALLERP = observe_ERPDAT.ALLERP;
        if jk==1 % Jackknife
            [ALLERP, ERPCOM]  = pop_jkgaverager(ALLERP, 'Erpsets', erpset, 'Criterion', artcrite,...
                'SEM', stdsstr, 'Weighted', Weightedstr, 'Erpname', jkerpname, 'Filename', jkfilename,...
                'DQ_flag',dq_option,'DQ_spec',dq_spec,'Warning', wavgstr);
            if isempty(ERPCOM)
                return;
            end
            
            Selected_ERP_afd = setdiff([1:length(ALLERP)],[1:length(observe_ERPDAT.ALLERP)]);
            
            for Numoferp = 1:numel(Selected_ERP_afd)
                if Numoferp ==numel(Selected_ERP_afd)
                    [ALLERP(Selected_ERP_afd(Numoferp)), ALLERPCOM] = erphistory(ALLERP(Selected_ERP_afd(Numoferp)), ALLERPCOM, ERPCOM,2);
                else
                    [ALLERP(Selected_ERP_afd(Numoferp)), ALLERPCOM] = erphistory(ALLERP(Selected_ERP_afd(Numoferp)), ALLERPCOM, ERPCOM,1);
                end
            end
            
            if Save_file_label==1
                for Numofselectederp =1:numel(Selected_ERP_afd)
                    ERP_save = observe_ERPDAT.ALLERP(Selected_ERP_afd(Numofselectederp));
                    ERP_save.filepath = pathName_new;
                    [observe_ERPDAT.ALLERP(Selected_ERP_afd(Numofselectederp)), issave, ERPCOM] = pop_savemyerp(ERP_save, 'erpname', ERP_save.erpname, 'filename', ERP_save.erpname, 'filepath',ERP_save.filepath);
                end
                [observe_ERPDAT.ALLERP(Selected_ERP_afd(Numofselectederp)), ALLERPCOM] = erphistory(observe_ERPDAT.ALLERP(Selected_ERP_afd(Numofselectederp)), ALLERPCOM, ERPCOM,2);
            end
            observe_ERPDAT.ALLERP = ALLERP;
            observe_ERPDAT.CURRENTERP = Selected_ERP_afd(1);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
            estudioworkingmemory('selectederpstudio',Selected_ERP_afd);
        else
            [ERP, ERPCOM]  = pop_gaverager(ALLERP, 'Erpsets', erpset,'Criterion', artcrite, 'SEM', stdsstr,...
                'ExcludeNullBin', excnullbinstr,'Weighted', Weightedstr, 'Saveas', 'off',...
                'DQ_flag',dq_option,'DQ_spec',dq_spec,'Warning', wavgstr, 'History', 'gui');
            if isempty(ERPCOM)
                return;
            end
            ERP.erpname = erpName_new;
            ERP.filename = fileName_new;
            ERP.filepath = pathName_new;
            [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
            
            if Save_file_label==1
                [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', ERP.filename, 'filepath',ERP.filepath,'History','implicit');
                ERPCOM = f_erp_save_history(ERP.erpname,ERP.filename,ERP.filepath);
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
            end
            observe_ERPDAT.ALLERP(length(observe_ERPDAT.ALLERP)+1) = ERP;
            Selected_ERP_afd = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
            estudioworkingmemory('selectederpstudio',Selected_ERP_afd);
        end
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        estudioworkingmemory('f_ERP_bin_opt',1);
        observe_ERPDAT.Count_currentERP = 1;
        observe_ERPDAT.Process_messg =2;
    end


%%--------Setting current ERPset/session history based on the current updated ERPset------------
    function Count_currentERPChanged(~,~)
        if observe_ERPDAT.Count_currentERP~=12
            return;
        end
        ViewerFlag=estudioworkingmemory('ViewerFlag');
        if isempty(ViewerFlag) || (ViewerFlag~=0 && ViewerFlag~=1)
            ViewerFlag=0;estudioworkingmemory('ViewerFlag',0);
        end
        if  isempty(observe_ERPDAT.ERP) || isempty(observe_ERPDAT.ALLERP) || strcmp(observe_ERPDAT.ERP.datatype,'EFFT') || ViewerFlag==1
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
        gui_erp_grdavg.cancel.Enable = Enable_label;
        gui_erp_grdavg.cmpsd.Enable = Enable_label;
        observe_ERPDAT.Count_currentERP=13;
    end

%%--------------press return to execute "Apply"----------------------------
    function erp_graverage_presskey(~,eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('ERPTab_mesuretool');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            apply_run();
            estudioworkingmemory('ERPTab_gravg',0);
            gui_erp_grdavg.run.BackgroundColor =  [1 1 1];
            gui_erp_grdavg.run.ForegroundColor = [0 0 0];
            ERP_grdavg_box_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
            gui_erp_grdavg.cancel.BackgroundColor =  [1 1 1];
            gui_erp_grdavg.cancel.ForegroundColor = [0 0 0];
        else
            return;
        end
    end


    function Reset_erp_panel_change(~,~)
        if observe_ERPDAT.Reset_erp_paras_panel~=11
            return;
        end
        estudioworkingmemory('ERPTab_gravg',0);
        gui_erp_grdavg.run.BackgroundColor =  [1 1 1];
        gui_erp_grdavg.run.ForegroundColor = [0 0 0];
        ERP_grdavg_box_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_grdavg.cancel.BackgroundColor =  [1 1 1];
        gui_erp_grdavg.cancel.ForegroundColor = [0 0 0];
        gui_erp_grdavg.weigavg.Value = 0;
        gui_erp_grdavg.excldnullbin.Value = 1;
        gui_erp_grdavg.jacknife.Value = 0;
        gui_erp_grdavg.warn.Value = 0;
        gui_erp_grdavg.cmpsd.Value = 1;
        gui_erp_grdavg.cbdatq.Value = 1;
        gui_erp_grdavg.cbdatq_custom.Value = 0;
        gui_erp_grdavg.cbdatq_def.Value = 1;
        gui_erp_grdavg.cbdatq_custom_op.Enable = 'off';
        gui_erp_grdavg.cbdatq_def.Enable = 'on';
        gui_erp_grdavg.cbdatq_custom.Enable = 'on';
        observe_ERPDAT.Reset_erp_paras_panel=12;
    end

end