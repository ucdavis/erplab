
%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 2022




function varargout = f_erp_dataquality_SME_GUI(varargin)

global observe_ERPDAT;
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);


if nargin < 1
    beep;
    help f_erp_dataquality_SME_GUI;
    return;
end


try
    ERP = evalin('base','ERP');
catch
    beep;
    disp('f_erp_dataquality_SME_GUI: No ERP was found in workspace');
    return;
end

if isempty(ERP)
    msgboxText =  'No ERPset was found!';
    title_msg  = 'ERPLAB: f_erp_dataquality_SME_GUI() error:';
    errorfound(msgboxText, title_msg);
    return
end
if ~isfield(ERP, 'bindata')
    msgboxText =  'f_erp_dataquality_SME_GUI cannot handle an empty ERP dataset';
    title = 'ERPLAB: f_erp_dataquality_SME_GUI() error:';
    errorfound(msgboxText, title);
    return
end
if isempty(ERP.bindata)
    msgboxText =  'f_erp_dataquality_SME_GUI cannot handle an empty ERP dataset';
    title = 'ERPLAB: f_erp_dataquality_SME_GUI() error:';
    errorfound(msgboxText, title);
    return
end

try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.95 0.95 0.95];
end

if nargin == 0
    fig = figure(); % Parent figure
    Erp_information = uiextras.BoxPanel('Parent', fig, 'Title', 'Data Quality (aSME)', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    Erp_information = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Data Quality (aSME)', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    Erp_information = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Data Quality (aSME)', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
end

varargout{1} = Erp_information;
gui_erp_DQSME = struct;
try
    FonsizeDefault = varargin{2};
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
   FonsizeDefault = f_get_default_fontsize();
end
drawui_erp_information(FonsizeDefault);


    function drawui_erp_information(FonsizeDefault)
        
        
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.95 0.95 0.95];
        end
        SelectedERP= estudioworkingmemory('selectederpstudio');
        if isempty(SelectedERP)
            SelectedERP = observe_ERPDAT.CURRENTERP;
            
            if isempty(SelectedERP)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: ERPsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,SelectedERP);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        
        S_binchan =  estudioworkingmemory('geterpbinchan');
        SelectedERP_current_index = S_binchan.Select_index;
        
        
        
        if ~isempty(SelectedERP)&& SelectedERP_current_index> numel(SelectedERP)
            SelectedERP(1) = observe_ERPDAT.CURRENTERP;
            SelectedERP_current_index = 1;
        end
        
        if strcmp(observe_ERPDAT.ALLERP(SelectedERP(SelectedERP_current_index)).erpname,'No ERPset loaded')
            Enable_label = 'off';
        else
            Enable_label = 'on';
        end
        
        ERP_SME_summary = f_dq_summary(observe_ERPDAT.ALLERP(SelectedERP(SelectedERP_current_index)));
        
        gui_erp_DQSME.DataSelBox = uiextras.VBox('Parent', Erp_information, 'Spacing',1,'BackgroundColor',ColorB_def);
        
        %%----------------------------Setting midian SME---------------------
        gui_erp_DQSME.Median_sme = uiextras.HBox('Parent',gui_erp_DQSME.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_DQSME.Median_sme_title = uicontrol('Style','text','Parent', gui_erp_DQSME.Median_sme,'String','Median:','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(gui_erp_DQSME.Median_sme_title,'HorizontalAlignment','left');
        Median_tw =ERP_SME_summary{3,1};
        Median_name = strcat(num2str(roundn(ERP_SME_summary{1,1},-2)),', chan.',num2str(ERP_SME_summary{2,1}),',',32,num2str(Median_tw(1)),'-',num2str(Median_tw(2)),'ms, bin:',32,num2str(ERP_SME_summary{4,1}));
        gui_erp_DQSME.Median_sme_name = uicontrol('Style','text','Parent', gui_erp_DQSME.Median_sme,'String',Median_name,'FontSize',FonsizeDefault);
        set(gui_erp_DQSME.Median_sme_name,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        set(gui_erp_DQSME.Median_sme,'Sizes',[60 400]);
        
        %%----------------------------Setting min. SME---------------------
        gui_erp_DQSME.min_sme = uiextras.HBox('Parent',gui_erp_DQSME.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_DQSME.min_sme_title = uicontrol('Style','text','Parent', gui_erp_DQSME.min_sme,'String','Min:','FontSize',FonsizeDefault);
        set(gui_erp_DQSME.min_sme_title,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        Min_tw =ERP_SME_summary{3,2};
        Min_name = strcat(num2str(roundn(ERP_SME_summary{1,2},-2)),', chan.',num2str(ERP_SME_summary{2,2}),',',32,num2str(Min_tw(1)),'-',num2str(Min_tw(2)),'ms, bin:',32,num2str(ERP_SME_summary{4,2}));
        gui_erp_DQSME.min_sme_name = uicontrol('Style','text','Parent', gui_erp_DQSME.min_sme,'String',Min_name,'FontSize',FonsizeDefault);
        set(gui_erp_DQSME.min_sme_name,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        set(gui_erp_DQSME.min_sme,'Sizes',[40 400]);
        
        %%----------------------------Setting max. SME---------------------
        gui_erp_DQSME.max_sme = uiextras.HBox('Parent',gui_erp_DQSME.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_DQSME.max_sme_title = uicontrol('Style','text','Parent', gui_erp_DQSME.max_sme,'String','Max:','FontSize',FonsizeDefault);
        set(gui_erp_DQSME.max_sme_title,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        Max_tw =ERP_SME_summary{3,3};
        Max_name = strcat(num2str(roundn(ERP_SME_summary{1,3},-2)),', chan.',num2str(ERP_SME_summary{2,3}),',',32,num2str(Max_tw(1)),'-',num2str(Max_tw(2)),'ms, bin:',32,num2str(ERP_SME_summary{4,3}));
        gui_erp_DQSME.max_sme_name = uicontrol('Style','text','Parent', gui_erp_DQSME.max_sme,'String',Max_name,'FontSize',FonsizeDefault);
        set(gui_erp_DQSME.max_sme_name,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        set(gui_erp_DQSME.max_sme,'Sizes',[40 400]);
        
        gui_erp_DQSME.DQSME_option = uiextras.HBox('Parent',gui_erp_DQSME.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_DQSME.DQSME_option_table  = uicontrol('Style','pushbutton','Parent', gui_erp_DQSME.DQSME_option,'String','Show in a table',...
            'callback',@DQSME_table,'Enable',Enable_label,'FontSize',FonsizeDefault);
        
        gui_erp_DQSME.DQSME_option_file  = uicontrol('Style','pushbutton','Parent', gui_erp_DQSME.DQSME_option,'String','Save to file',...
            'callback',@DQSME_file,'Enable',Enable_label,'FontSize',FonsizeDefault);
        set(gui_erp_DQSME.DQSME_option,'Sizes',[120 120]);
        try
            ERP_data_quality = observe_ERPDAT.ALLERP(SelectedERP(SelectedERP_current_index)).dataquality.data;
        catch
            ERP_data_quality =[];
        end
        if isempty(ERP_data_quality)
            set(gui_erp_DQSME.DQSME_option_table,'Enable','off');
            set(gui_erp_DQSME.DQSME_option_file,'Enable','off');
        end
        gui_erp_DQSME.DQSME_option1 = uiextras.HBox('Parent',gui_erp_DQSME.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_DQSME.DQSME_option_measure  = uicontrol('Style','pushbutton','Parent', gui_erp_DQSME.DQSME_option1,'String','Show measures on Command Window',...
            'callback',@DQSME_measures,'Enable',Enable_label,'FontSize',FonsizeDefault);
        uiextras.Empty('Parent', gui_erp_DQSME.DQSME_option1);
        set(gui_erp_DQSME.DQSME_option1,'Sizes',[240 10]);
        set(gui_erp_DQSME.DataSelBox,'Sizes',[20 20 20 30 30]);
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------Subfunction----------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%--------Settting will be modified if the selected was changed------------
    function Count_currentERPChanged(~,~)
        SelectedERP= estudioworkingmemory('selectederpstudio');
        if isempty(SelectedERP)
            SelectedERP = observe_ERPDAT.CURRENTERP;
            if isempty(SelectedERP)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: ERPsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,SelectedERP);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        S_binchan =  estudioworkingmemory('geterpbinchan');
        SelectedERP_current_index = S_binchan.Select_index;
        if ~isempty(SelectedERP)&& SelectedERP_current_index> numel(SelectedERP)
            SelectedERP(1) = observe_ERPDAT.CURRENTERP;
            SelectedERP_current_index = 1;
        end
        
        if strcmp(observe_ERPDAT.ALLERP(SelectedERP(SelectedERP_current_index)).erpname,'No ERPset loaded')
            Enable_label = 'off';
        else
            Enable_label = 'on';
        end
        
        ERP_SME_summary = f_dq_summary(observe_ERPDAT.ALLERP(SelectedERP(SelectedERP_current_index)));
        Median_tw =ERP_SME_summary{3,1};
        Median_name = strcat(num2str(roundn(ERP_SME_summary{1,1},-2)),', chan.',num2str(ERP_SME_summary{2,1}),',',32,num2str(Median_tw(1)),'-',num2str(Median_tw(2)),'ms, bin',32,num2str(ERP_SME_summary{4,1}));
        gui_erp_DQSME.Median_sme_name.String = Median_name;
        Min_tw =ERP_SME_summary{3,2};
        Min_name = strcat(num2str(roundn(ERP_SME_summary{1,2},-2)),', chan.',num2str(ERP_SME_summary{2,2}),',',32,num2str(Min_tw(1)),'-',num2str(Min_tw(2)),'ms, bin',32,num2str(ERP_SME_summary{4,2}));
        gui_erp_DQSME.min_sme_name.String = Min_name;
        Max_tw =ERP_SME_summary{3,3};
        Max_name = strcat(num2str(roundn(ERP_SME_summary{1,3},-2)),', chan.',num2str(ERP_SME_summary{2,3}),',',32,num2str(Max_tw(1)),'-',num2str(Max_tw(2)),'ms, bin',32,num2str(ERP_SME_summary{4,3}));
        gui_erp_DQSME.max_sme_name.String=Max_name;
        gui_erp_DQSME.DQSME_option_measure.Enable = Enable_label;
        
        try% check if the data for SMEs exsists or not
            data_quality = observe_ERPDAT.ERP.dataquality.data;
            if isempty(data_quality)
                Enable_label = 'off';
            end
        catch
            Enable_label = 'off';
            beep;
            disp('There no SME exist in current ERPset');
        end
        gui_erp_DQSME.DQSME_option_table.Enable = Enable_label;
        gui_erp_DQSME.DQSME_option_file.Enable = Enable_label;
        
        
    end



%%---------------------Save SME to a table---------------------------------
    function DQSME_table(~,~)
        
        SelectedERP= estudioworkingmemory('selectederpstudio');
        if isempty(SelectedERP)
            SelectedERP = observe_ERPDAT.CURRENTERP;
            
            if isempty(SelectedERP)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: ERPsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,SelectedERP);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        
        S_binchan =  estudioworkingmemory('geterpbinchan');
        SelectedERP_current_index = S_binchan.Select_index;
        
        if ~isempty(SelectedERP)&& SelectedERP_current_index> numel(SelectedERP)
            SelectedERP_current_index = 1;
        end
        DQ_Table_GUI(observe_ERPDAT.ALLERP(SelectedERP(SelectedERP_current_index)),observe_ERPDAT.ALLERP,SelectedERP(SelectedERP_current_index),1);
    end



%-----------------Save the SME to a file-----------------------------------
    function DQSME_file(~,~)
        
        SelectedERP= estudioworkingmemory('selectederpstudio');
        if isempty(SelectedERP)
            SelectedERP = observe_ERPDAT.CURRENTERP;
            
            if isempty(SelectedERP)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: ERPsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,SelectedERP);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        
        S_binchan =  estudioworkingmemory('geterpbinchan');
        SelectedERP_current_index = S_binchan.Select_index;
        
        
        if ~isempty(SelectedERP)&& SelectedERP_current_index> numel(SelectedERP)
            SelectedERP_current_index = 1;
        end
        
        %-----------Setting for import-------------------------------------
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.7020 0.77 0.85];
        end
        
        oldcolor = get(0,'DefaultUicontrolBackgroundColor');
        set(0,'DefaultUicontrolBackgroundColor',ColorB_def);
        
        for Numoferp = 1:numel(SelectedERP)
            ERP =observe_ERPDAT.ALLERP(SelectedERP(Numoferp));
            try
                Datquality = ERP.dataquality;
                if isempty(Datquality(1).data)&& isempty(Datquality(2).data) && isempty(Datquality(3).data)
                    msgboxText =  ['No information for data quality is found!'];
                    question = [  'No information for data quality is found!'];
                    title       = 'ERPLAB Studio: ERPsets';
                    button      = questdlg(sprintf(question, msgboxText), title,'OK','OK');
                else
                    save_data_quality(observe_ERPDAT.ALLERP(SelectedERP(Numoferp)));
                end
            catch
                msgboxText =  ['No information for data quality is found!'];
                question = [  'No information for data quality is found!'];
                title       = 'ERPLAB Studio: "Save to file" on "Data quality (aSME)".';
                button      = questdlg(sprintf(question, msgboxText), title,'OK','OK');
            end
            
        end
        set(0,'DefaultUicontrolBackgroundColor',[1 1 1]);
    end



%-------------------Show which Data Quality measures are in each loaded ERPSET---------------------------
    function DQSME_measures(~,~)
        if isempty(observe_ERPDAT.ALLERP)
            beep;
            disp('f_erp_dataquality_SME_GUI: No ERP was found!!!');
            return;
        end
        erpset_summary(observe_ERPDAT.ALLERP);
        
    end

end