
%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 2022  && Nov. 2023




function varargout = f_erp_dataquality_SME_GUI(varargin)

global observe_ERPDAT;
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);

try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.95 0.95 0.95];
end

if nargin == 0
    fig = figure(); % Parent figure
    Erp_information = uiextras.BoxPanel('Parent', fig, 'Title', 'View Data Quality Metrics', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    Erp_information = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'View Data Quality Metrics', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    Erp_information = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'View Data Quality Metrics', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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
        Enable_label = 'off';
        
        gui_erp_DQSME.DataSelBox = uiextras.VBox('Parent', Erp_information, 'Spacing',1,'BackgroundColor',ColorB_def);
        
        
        %%ERP setname and file name
        gui_erp_DQSME.setfilename_title = uiextras.HBox('Parent',gui_erp_DQSME.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent', gui_erp_DQSME.setfilename_title,'String','Current ERP setname & file name',...
            'FontSize',FonsizeDefault,'FontWeight','bold','BackgroundColor',ColorB_def);
        
        
        gui_erp_DQSME.setfilename_title2 = uiextras.HBox('Parent',gui_erp_DQSME.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        for ii = 1:100
            dsnames{ii,1} = '';
            dsnames{ii,2} = '';
        end
        gui_erp_DQSME.table_setfilenames = uitable(  ...
            'Parent'        , gui_erp_DQSME.setfilename_title2,...
            'Data'          , dsnames, ...
            'ColumnWidth'   , {500}, ...
            'ColumnName'    , {''}, ...
            'RowName'       , {'ERP name','File name'},...
            'ColumnEditable',[false]);
        
        
        %%----------------------------Setting midian SME---------------------
        gui_erp_DQSME.Median_sme = uiextras.HBox('Parent',gui_erp_DQSME.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_DQSME.Median_sme_title = uicontrol('Style','text','Parent', gui_erp_DQSME.Median_sme,'String','Median aSME:','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(gui_erp_DQSME.Median_sme_title,'HorizontalAlignment','left');
        
        gui_erp_DQSME.Median_sme_name = uicontrol('Style','text','Parent', gui_erp_DQSME.Median_sme,'String','','FontSize',FonsizeDefault);
        set(gui_erp_DQSME.Median_sme_name,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        set(gui_erp_DQSME.Median_sme,'Sizes',[100 400]);
        
        %%----------------------------Setting min. SME---------------------
        gui_erp_DQSME.min_sme = uiextras.HBox('Parent',gui_erp_DQSME.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_DQSME.min_sme_title = uicontrol('Style','text','Parent', gui_erp_DQSME.min_sme,'String','Min aSME:','FontSize',FonsizeDefault);
        set(gui_erp_DQSME.min_sme_title,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        
        gui_erp_DQSME.min_sme_name = uicontrol('Style','text','Parent', gui_erp_DQSME.min_sme,'String','','FontSize',FonsizeDefault);
        set(gui_erp_DQSME.min_sme_name,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        set(gui_erp_DQSME.min_sme,'Sizes',[80 400]);
        
        %%----------------------------Setting max. SME---------------------
        gui_erp_DQSME.max_sme = uiextras.HBox('Parent',gui_erp_DQSME.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_DQSME.max_sme_title = uicontrol('Style','text','Parent', gui_erp_DQSME.max_sme,'String','Max aSME:','FontSize',FonsizeDefault);
        set(gui_erp_DQSME.max_sme_title,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        
        gui_erp_DQSME.max_sme_name = uicontrol('Style','text','Parent', gui_erp_DQSME.max_sme,'String','','FontSize',FonsizeDefault);
        set(gui_erp_DQSME.max_sme_name,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        set(gui_erp_DQSME.max_sme,'Sizes',[80 400]);
        
        gui_erp_DQSME.DQSME_option = uiextras.HBox('Parent',gui_erp_DQSME.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_DQSME.DQSME_option_table  = uicontrol('Style','pushbutton','Parent', gui_erp_DQSME.DQSME_option,'String','Show in a table',...
            'callback',@DQSME_table,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        
        gui_erp_DQSME.DQSME_option_file  = uicontrol('Style','pushbutton','Parent', gui_erp_DQSME.DQSME_option,'String','Save to file',...
            'callback',@DQSME_file,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        set(gui_erp_DQSME.DQSME_option,'Sizes',[120 120]);
        
        set(gui_erp_DQSME.DQSME_option_table,'Enable','off');
        set(gui_erp_DQSME.DQSME_option_file,'Enable','off');
        set(gui_erp_DQSME.DataSelBox,'Sizes',[20 70 20 20 20 30]);
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------Subfunction----------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%--------Settting will be modified if the selected was changed------------
    function Count_currentERPChanged(~,~)
        if observe_ERPDAT.Count_currentERP~=16
            return;
        end
        if  isempty(observe_ERPDAT.ERP) || isempty(observe_ERPDAT.ALLERP) || strcmp(observe_ERPDAT.ERP.datatype,'EFFT')
            Enableflag = 'off';
            gui_erp_DQSME.Median_sme_name.String ='';
            gui_erp_DQSME.min_sme_name.String ='';
            gui_erp_DQSME.max_sme_name.String='';
            gui_erp_DQSME.DQSME_option_table.Enable = Enableflag;
            gui_erp_DQSME.DQSME_option_file.Enable = Enableflag;
            
            observe_ERPDAT.Count_currentERP=17;
            return;
        else
            Enableflag = 'on';
        end
        ViewerFlag=estudioworkingmemory('ViewerFlag');
        if isempty(ViewerFlag) || (ViewerFlag~=0 && ViewerFlag~=1)
            ViewerFlag=0;estudioworkingmemory('ViewerFlag',0);
        end
        if ViewerFlag==1
            Enableflag = 'off';
        end
        try
            ERP_SME_summary = f_dq_summary(observe_ERPDAT.ERP);
        catch
            ERP_SME_summary = cell(3,3);
        end
        Median_tw =ERP_SME_summary{3,1};
        try
            Median_name = strcat(num2str(roundn(ERP_SME_summary{1,1},-2)),', chan.',num2str(ERP_SME_summary{2,1}),',',32,num2str(Median_tw(1)),'-',num2str(Median_tw(2)),'ms, bin',32,num2str(ERP_SME_summary{4,1}));
        catch
            Median_name = '';
        end
        gui_erp_DQSME.Median_sme_name.String = Median_name;
        Min_tw =ERP_SME_summary{3,2};
        try
            Min_name = strcat(num2str(roundn(ERP_SME_summary{1,2},-2)),', chan.',num2str(ERP_SME_summary{2,2}),',',32,num2str(Min_tw(1)),'-',num2str(Min_tw(2)),'ms, bin',32,num2str(ERP_SME_summary{4,2}));
        catch
            Min_name = '';
        end
        gui_erp_DQSME.min_sme_name.String = Min_name;
        Max_tw =ERP_SME_summary{3,3};
        try
            Max_name = strcat(num2str(roundn(ERP_SME_summary{1,3},-2)),', chan.',num2str(ERP_SME_summary{2,3}),',',32,num2str(Max_tw(1)),'-',num2str(Max_tw(2)),'ms, bin',32,num2str(ERP_SME_summary{4,3}));
        catch
            Max_name = '';
        end
        gui_erp_DQSME.max_sme_name.String=Max_name;
        
        
        try% check if the data for SMEs exsists or not
            data_quality = observe_ERPDAT.ERP.dataquality.data;
            if isempty(data_quality)
                Enableflag = 'off';
            end
        catch
            Enableflag = 'off';
        end
        gui_erp_DQSME.DQSME_option_table.Enable = Enableflag;
        gui_erp_DQSME.DQSME_option_file.Enable = Enableflag;
        
        try
            filesetname{1,1} = observe_ERPDAT.ERP.erpname;
            filesetname{2,1} = observe_ERPDAT.ERP.filename;
        catch
            filesetname{1,1} = '';
            filesetname{2,1} = '';
        end
        gui_erp_DQSME.table_setfilenames.Data= filesetname;
        
        
        observe_ERPDAT.Count_currentERP=17;
    end

%%---------------------Save SME to a table---------------------------------
    function DQSME_table(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        SelectedERP= estudioworkingmemory('selectederpstudio');
        if isempty(SelectedERP) || any(SelectedERP> length(observe_ERPDAT.ALLERP))
            SelectedERP =  length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = SelectedERP;
            estudioworkingmemory('selectederpstudio',SelectedERP);
        end
        estudioworkingmemory('f_ERP_proces_messg','View Data Quality Metrics > Show in a table');
        observe_ERPDAT.Process_messg =1;
        try ALLERPCOM = evalin('base','ALLERPCOM'); catch ALLERPCOM=[];  end
        DQ_Table_GUI(observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP),observe_ERPDAT.ALLERP,observe_ERPDAT.CURRENTERP,1);
        for Numoferp = 1:numel(SelectedERP)
            ERPCOM = [' DQ_Table_GUI(ERP,ALLERP,',num2str(Numoferp),',1);'];
            [ERP, ALLERPCOM] = erphistory(observe_ERPDAT.ALLERP(SelectedERP(Numoferp)), ALLERPCOM, ERPCOM,2);
            observe_ERPDAT.ALLERP(SelectedERP(Numoferp)) = ERP;
        end
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
        observe_ERPDAT.Count_currentERP = 20;
        observe_ERPDAT.Process_messg =2;
    end

%-----------------Save the SME to a file-----------------------------------
    function DQSME_file(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        SelectedERP= estudioworkingmemory('selectederpstudio');
        if isempty(SelectedERP) || any(SelectedERP> length(observe_ERPDAT.ALLERP))
            SelectedERP =  length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = SelectedERP;
            estudioworkingmemory('selectederpstudio',SelectedERP);
        end
        estudioworkingmemory('f_ERP_proces_messg','View Data Quality Metrics > Save to file');
        observe_ERPDAT.Process_messg =1;
        try ALLERPCOM = evalin('base','ALLERPCOM'); catch ALLERPCOM=[];  end
        countr= 0;
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
                    ERPCOM = ['save_data_quality(ERP);'];
                    [ERP, ALLERPCOM] = erphistory(observe_ERPDAT.ALLERP(SelectedERP(Numoferp)), ALLERPCOM, ERPCOM,2);
                    observe_ERPDAT.ALLERP(SelectedERP(Numoferp)) = ERP;
                    countr=1;
                end
            catch
                msgboxText =  ['No information for data quality is found!'];
                question = [  'No information for data quality is found!'];
                title       = 'ERPLAB Studio: "Save to file" on "View Data Quality Metrics".';
                button      = questdlg(sprintf(question, msgboxText), title,'OK','OK');
            end
        end
        set(0,'DefaultUicontrolBackgroundColor',[1 1 1]);
        if countr==1
            assignin('base','ALLERPCOM',ALLERPCOM);
            assignin('base','ERPCOM',ERPCOM);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
            observe_ERPDAT.Count_currentERP = 20;
        end
        observe_ERPDAT.Process_messg =2;
    end

end