%%This function is to plot the panel for "plot organization".

% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022


function varargout = f_ERP_plotorg_waveviewer_GUI(varargin)

global viewer_ERPDAT

addlistener(viewer_ERPDAT,'v_currentERP_change',@v_currentERP_change);
% addlistener(viewer_ERPDAT,'legend_change',@legend_change);
addlistener(viewer_ERPDAT,'count_loadproper_change',@count_loadproper_change);
% addlistener(viewer_ERPDAT,'Process_messg_change',@Process_messg_change);

gui_plotorg_waveviewer = struct();

%-----------------------------Name the title----------------------------------------------
% global box_erpwave_viewer_plotorg;
[version reldate,ColorBdef,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    box_erpwave_viewer_plotorg = uiextras.BoxPanel('Parent', fig, 'Title', 'Plot Organization', 'Padding', 5,...
        'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w','FontSize', 12); % Create boxpanel
elseif nargin == 1
    box_erpwave_viewer_plotorg = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Plot Organization', 'Padding', 5,...
        'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w','FontSize', 12);
else
    box_erpwave_viewer_plotorg = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Plot Organization', 'Padding', 5,...
        'FontSize', varargin{2},'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w');
end

estudioworkingmemory('OverlayIndex',0);

%-----------------------------Draw the panel-------------------------------------
drawui_plot_org()
varargout{1} = box_erpwave_viewer_plotorg;

    function drawui_plot_org()
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        try
            ALLERPwaviewer = evalin('base','ALLERPwaviewer');
            ERPwaviewerin = ALLERPwaviewer;
        catch
            beep;
            disp('f_ERP_plotorg_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        
        gui_plotorg_waveviewer.DataSelBox = uiextras.VBox('Parent', box_erpwave_viewer_plotorg,'BackgroundColor',ColorBviewer_def);
        %%--------------------grind overlay and pages----------------------
        gui_plotorg_waveviewer.DataSelGrid = uiextras.Grid('Parent', gui_plotorg_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        % First column:
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','Grid',...
            'FontSize',12,'BackgroundColor',ColorBviewer_def); % 1B
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','Overlay',...
            'FontSize',12,'BackgroundColor',ColorBviewer_def); % 1B
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','Pages',...
            'FontSize',12,'BackgroundColor',ColorBviewer_def); % 1B
        GridValue = 1;
        OverlayValue =2;
        pagesValue = 3;
        plotorg_grid_String = {'Channels','Bins','ERPsets','None'};
        gui_plotorg_waveviewer.grid =  uicontrol('Style','popupmenu','Parent', gui_plotorg_waveviewer.DataSelGrid,'String',plotorg_grid_String,...
            'callback',@plotorg_grid,'FontSize',12,'BackgroundColor',[1 1 1],'Value',GridValue); % 1B
        
        plotorg_overlay_String = {'Channels','Bins','ERPsets','None'};
        gui_plotorg_waveviewer.overlay = uicontrol('Style','popupmenu','Parent', gui_plotorg_waveviewer.DataSelGrid,'String',plotorg_overlay_String,...
            'callback',@plotorg_overlay,'FontSize',12,'BackgroundColor',[1 1 1],'Value',OverlayValue); % 1B
        
        plotorg_pages_String = {'Channels','Bins','ERPsets','None'};
        gui_plotorg_waveviewer.pages = uicontrol('Style','popupmenu','Parent', gui_plotorg_waveviewer.DataSelGrid,'String',plotorg_pages_String,...
            'callback',@plotorg_pages,'FontSize',12,'BackgroundColor',[1 1 1],'Value',pagesValue); % 1B
        set(gui_plotorg_waveviewer.DataSelGrid, 'ColumnSizes',[ -1.2 -2],'RowSizes',[30 30 30]);
        ERPwaviewerin.plot_org.Grid = gui_plotorg_waveviewer.grid.Value;
        ERPwaviewerin.plot_org.Overlay = gui_plotorg_waveviewer.overlay.Value;
        ERPwaviewerin.plot_org.Pages = gui_plotorg_waveviewer.pages.Value;
        
        %%----------------------Setting for grid layout--------------------
        gui_plotorg_waveviewer.layout_title = uiextras.HBox('Parent', gui_plotorg_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        gridlayoutValue = 1;
        % First column:
        gui_plotorg_waveviewer.layout=  uicontrol('Style','text','Parent', gui_plotorg_waveviewer.layout_title,'String','Grid Layout:',...
            'FontSize',12,'BackgroundColor',ColorBviewer_def); %
        set(gui_plotorg_waveviewer.layout,'HorizontalAlignment','left');
        gui_plotorg_waveviewer.layout_auto = uicontrol('Style','radiobutton','Parent', gui_plotorg_waveviewer.layout_title,'String','Auto',...
            'callback',@layout_auto,'FontSize',12,'BackgroundColor',ColorBviewer_def,'Value',gridlayoutValue); %
        gui_plotorg_waveviewer.layout_custom = uicontrol('Style','radiobutton','Parent', gui_plotorg_waveviewer.layout_title,'String','Custom',...
            'callback',@layout_custom,'FontSize',12,'BackgroundColor',ColorBviewer_def,'Value',~gridlayoutValue); %
        set(gui_plotorg_waveviewer.layout_title, 'Sizes',[80 70 70]);
        ERPwaviewerin.plot_org.gridlayout.op = gui_plotorg_waveviewer.layout_auto.Value;
        
        %%NUmber of rows and columns
        binArray = ERPwaviewerin.bin;
        chanArray = ERPwaviewerin.chan;
        ERPsetArray = ERPwaviewerin.SelectERPIdx;
        ALLERPIN = ERPwaviewerin.ALLERP;
        if max(ERPsetArray) >length(ALLERPIN)
            ERPsetArray =length(ALLERPIN);
        end
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERPIN,ERPsetArray);
        if GridValue ==1 %% if  the selected Channel is "Grid"
            plotArray = chanArray;
            plotArrayStr = chanStr(chanArray);
            plotArrayFormt = plotArrayStr;
            plotArrayFormt(numel(chanArray)+1) = {'None'};
        elseif GridValue == 2 %% if the selected Bin is "Grid"
            plotArray = binArray;
            plotArrayStr = binStr(binArray);
            plotArrayFormt = plotArrayStr;
            plotArrayFormt(numel(binArray)+1) = {'None'};
        elseif GridValue == 3%% if the selected ERPset is "Grid"
            plotArray = ERPsetArray;
            plotArrayStr = cell(numel(ERPsetArray),1);
            for Numoferpset = 1:numel(ERPsetArray)
                plotArrayStr(Numoferpset,1) = {char(ALLERPIN(ERPsetArray(Numoferpset)).erpname)};
            end
            plotArrayFormt = plotArrayStr;
            plotArrayFormt(numel(ERPsetArray)+1) = {'None'};
        else
            plotArray = chanArray;
            plotArrayStr = chanStr(chanArray);
            plotArrayFormt = plotArrayStr;
            plotArrayFormt(numel(chanArray)+1) = {'None'};
        end
        plotBox = f_getrow_columnautowaveplot(plotArray);%% the first element is number of rows and the second element is the number of columns
        try
            Numrows = plotBox(1);
            Numcolumns = plotBox(2);
        catch
            Numrows = 1;
            Numcolumns = 1;
        end
        if gridlayoutValue==1
            rowcolumnEnable = 'off';
        else
            rowcolumnEnable = 'on';
        end
        gui_plotorg_waveviewer.row_column_title = uiextras.HBox('Parent', gui_plotorg_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        for ii = 1:256
            rowcolumnString{ii} = num2str(ii);
        end
        uiextras.Empty('Parent', gui_plotorg_waveviewer.row_column_title);
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.row_column_title,'String','Row(s)',...
            'FontSize',10,'BackgroundColor',ColorBviewer_def); % 1B
        gui_plotorg_waveviewer.rownum = uicontrol('Style','popupmenu','Parent', gui_plotorg_waveviewer.row_column_title,'String',rowcolumnString,...
            'callback',@plotorg_rownum,'FontSize',12,'BackgroundColor',[1 1 1],'Value',Numrows,'Enable',rowcolumnEnable); % 1B
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.row_column_title,'String','Column(s)',...
            'FontSize',10,'BackgroundColor',ColorBviewer_def); % 1B
        gui_plotorg_waveviewer.columnnum = uicontrol('Style','popupmenu','Parent', gui_plotorg_waveviewer.row_column_title,'String',rowcolumnString,...
            'callback',@plotorg_columnnum,'FontSize',12,'BackgroundColor',[1 1 1],'Value',Numcolumns,'Enable',rowcolumnEnable); % 1B
        set(gui_plotorg_waveviewer.row_column_title, 'Sizes',[20 35 65 55 65]);
        ERPwaviewerin.plot_org.gridlayout.rows = gui_plotorg_waveviewer.rownum.Value;
        ERPwaviewerin.plot_org.gridlayout.columns =gui_plotorg_waveviewer.columnnum.Value;
        
        %%-------------------------Grid information------------------------
        count = 0;
        for Numofrows = 1:Numrows
            for Numofcolumns = 1:Numcolumns
                count = count +1;
                if count> numel(plotArray)
                    GridinforData{Numofrows,Numofcolumns} = char('None');
                else
                    GridinforData{Numofrows,Numofcolumns} = char(plotArrayStr(count));
                end
            end
        end
        ERPwaviewerin.plot_org.gridlayout.data =GridinforData;
        columFormat = plotArrayFormt';
        ERPwaviewerin.plot_org.gridlayout.columFormat = columFormat;
        ERPwaviewerin.plot_org.gridlayout.columFormatOrig = columFormat;
        
        
        %%---------------------Gap between rows----------------------------
        gui_plotorg_waveviewer.gridspace_title = uiextras.HBox('Parent', gui_plotorg_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.gridspace_title ,'String','Grid Spacing',...
            'FontSize',12,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','center','FontWeight','bold'); %
        rowgapgtpValue = 1;
        RowGTPStr = '10';
        RowgapgtpEnable = 'off';
        if rowgapgtpValue==1 && ~gui_plotorg_waveviewer.layout_auto.Value
            RowgapgtpEnable = 'on';
        end
        gui_plotorg_waveviewer.rowgap_title = uiextras.HBox('Parent', gui_plotorg_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        gui_plotorg_waveviewer.rowgap = uicontrol('Style','text','Parent', gui_plotorg_waveviewer.rowgap_title,'String','Row:',...
            'FontSize',12,'BackgroundColor',ColorBviewer_def); %
        set(gui_plotorg_waveviewer.rowgap,'HorizontalAlignment','left');
        gui_plotorg_waveviewer.rowgap_auto = uicontrol('Style','radiobutton','Parent', gui_plotorg_waveviewer.rowgap_title,'String','Gap (%)',...
            'callback',@rowgapgtpauto,'FontSize',12,'BackgroundColor',ColorBviewer_def,'Value',rowgapgtpValue,'Enable',rowcolumnEnable); %
        gui_plotorg_waveviewer.rowgapGTPcustom = uicontrol('Style','edit','Parent', gui_plotorg_waveviewer.rowgap_title,'String',RowGTPStr,...
            'callback',@rowgapgtpcustom,'FontSize',12,'BackgroundColor',[1 1 1],'Enable',RowgapgtpEnable); %
        if gui_plotorg_waveviewer.layout_auto.Value ==1
            gui_plotorg_waveviewer.rowgapGTPcustom.String = '10';
        end
        set(gui_plotorg_waveviewer.rowgap_title, 'Sizes',[60 90 85]);
        ERPwaviewerin.plot_org.gridlayout.rowgap.GTPOP = gui_plotorg_waveviewer.rowgap_auto.Value;
        ERPwaviewerin.plot_org.gridlayout.rowgap.GTPValue = str2num(gui_plotorg_waveviewer.rowgapGTPcustom.String);
        
        RowgapOVERLAPEnable = 'off';
        if rowgapgtpValue==0 && ~gui_plotorg_waveviewer.layout_auto.Value
            RowgapOVERLAPEnable = 'on';
        end
        RowoverlayStr = '40';
        gui_plotorg_waveviewer.rowgapcustom_title = uiextras.HBox('Parent', gui_plotorg_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uiextras.Empty('Parent',gui_plotorg_waveviewer.rowgapcustom_title);
        gui_plotorg_waveviewer.rowoverlap = uicontrol('Style','radiobutton','Parent', gui_plotorg_waveviewer.rowgapcustom_title,'String','Overlap (%)',...
            'callback',@rowoverlap, 'FontSize',12,'BackgroundColor',ColorBviewer_def,'Enable',rowcolumnEnable,'Value',~rowgapgtpValue); %
        gui_plotorg_waveviewer.rowgapoverlayedit = uicontrol('Style','edit','Parent', gui_plotorg_waveviewer.rowgapcustom_title,'String',RowoverlayStr,...
            'callback',@rowoverlapcustom,'FontSize',12,'BackgroundColor',[1 1 1],'Enable',RowgapOVERLAPEnable); %
        set(gui_plotorg_waveviewer.rowgapcustom_title, 'Sizes',[60 90  85]);
        ERPwaviewerin.plot_org.gridlayout.rowgap.OverlayOP = gui_plotorg_waveviewer.rowoverlap.Value;
        ERPwaviewerin.plot_org.gridlayout.rowgap.OverlayValue = str2num(gui_plotorg_waveviewer.rowgapoverlayedit.String);
        
        %%---------------------Gap between columns------------------------
        columngapgtpValue = 1;
        columnGTPStr = '';
        columngapgtpEnable = 'off';
        gui_plotorg_waveviewer.columngap_title = uiextras.HBox('Parent', gui_plotorg_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        gui_plotorg_waveviewer.columngap = uicontrol('Style','text','Parent', gui_plotorg_waveviewer.columngap_title,'String','Column:',...
            'FontSize',12,'BackgroundColor',ColorBviewer_def); %
        set(gui_plotorg_waveviewer.columngap,'HorizontalAlignment','left');
        gui_plotorg_waveviewer.columngapgtpop = uicontrol('Style','radiobutton','Parent', gui_plotorg_waveviewer.columngap_title,'String','Gap (%)',...
            'callback',@columngapgtpop,'FontSize',12,'BackgroundColor',ColorBviewer_def,'Value',columngapgtpValue,'Enable',rowcolumnEnable); %
        gui_plotorg_waveviewer.columngapgtpcustom = uicontrol('Style','edit','Parent', gui_plotorg_waveviewer.columngap_title,'String',columnGTPStr,...
            'callback',@columngapGTPcustom,'FontSize',12,'BackgroundColor',[1 1 1],'Enable',columngapgtpEnable); %
        if gui_plotorg_waveviewer.layout_auto.Value ==1
            gui_plotorg_waveviewer.columngapgtpcustom.String = '10';
        end
        set(gui_plotorg_waveviewer.columngap_title, 'Sizes',[60 90  85]);
        ERPwaviewerin.plot_org.gridlayout.columngap.GTPOP = gui_plotorg_waveviewer.columngapgtpop.Value;
        ERPwaviewerin.plot_org.gridlayout.columngap.GTPValue = str2num(gui_plotorg_waveviewer.columngapgtpcustom.String);
        
        columngapOVERLAPEnable = 'off';
        if columngapgtpValue==0 && ~gui_plotorg_waveviewer.layout_auto.Value
            columngapOVERLAPEnable = 'on';
        end
        columnoverlayStr = '';
        gui_plotorg_waveviewer.columngapcustom_title = uiextras.HBox('Parent', gui_plotorg_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uiextras.Empty('Parent',gui_plotorg_waveviewer.columngapcustom_title);
        gui_plotorg_waveviewer.columnoverlay = uicontrol('Style','radiobutton','Parent', gui_plotorg_waveviewer.columngapcustom_title,'String','Overlap (%)',...
            'callback',@columnoverlap, 'FontSize',12,'BackgroundColor',ColorBviewer_def,'Enable',rowcolumnEnable,'Value',~columngapgtpValue); %
        gui_plotorg_waveviewer.columngapoverlapedit = uicontrol('Style','edit','Parent', gui_plotorg_waveviewer.columngapcustom_title,'String',columnoverlayStr,...
            'callback',@columnoverlaycustom,'FontSize',12,'BackgroundColor',[1 1 1],'Enable',columngapOVERLAPEnable); %
        set(gui_plotorg_waveviewer.columngapcustom_title, 'Sizes',[60 90  85]);
        ERPwaviewerin.plot_org.gridlayout.columngap.OverlayOP = gui_plotorg_waveviewer.columnoverlay.Value;
        ERPwaviewerin.plot_org.gridlayout.columngap.OverlayValue = str2num(gui_plotorg_waveviewer.columngapoverlapedit.String);
        
        %%---------------help and apply the changed parameters-------------
        gui_plotorg_waveviewer.save_load_title = uiextras.HBox('Parent', gui_plotorg_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        gui_plotorg_waveviewer.layout_custom_edit = uicontrol('Style','pushbutton','Parent',  gui_plotorg_waveviewer.save_load_title ,'String','Edit',...
            'callback',@plotorg_edit,'FontSize',12,'BackgroundColor',[1 1 1],'Enable',rowcolumnEnable); %,'HorizontalAlignment','left'
%         uiextras.Empty('Parent',   gui_plotorg_waveviewer.save_load_title );
        gui_plotorg_waveviewer.layout_custom_load = uicontrol('Style','pushbutton','Parent', gui_plotorg_waveviewer.save_load_title,'String','Load',...
            'callback',@layout_custom_load,'FontSize',12,'BackgroundColor',[1 1 1]); %
%         uiextras.Empty('Parent',   gui_plotorg_waveviewer.save_load_title );
        gui_plotorg_waveviewer.layout_custom_save = uicontrol('Style','pushbutton','Parent', gui_plotorg_waveviewer.save_load_title,'String','Save',...
            'callback',@layout_custom_save,'FontSize',12,'BackgroundColor',[1 1 1]); %
%         uiextras.Empty('Parent',   gui_plotorg_waveviewer.save_load_title );
%         set(gui_plotorg_waveviewer.save_load_title,'Sizes',[40 70 20 70 30]);
        
        gui_plotorg_waveviewer.help_run_title = uiextras.HBox('Parent', gui_plotorg_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
                uiextras.Empty('Parent',   gui_plotorg_waveviewer.help_run_title );
        gui_plotorg_waveviewer.cancel = uicontrol('Style','pushbutton','Parent',  gui_plotorg_waveviewer.help_run_title,'String','Cancel',...
            'callback',@plotorg_cancel,'FontSize',12,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', gui_plotorg_waveviewer.help_run_title);
        gui_plotorg_waveviewer.apply = uicontrol('Style','pushbutton','Parent',  gui_plotorg_waveviewer.help_run_title,'String','Apply',...
            'callback',@plotorg_apply,'FontSize',12,'BackgroundColor',[1 1 1]); %,'HorizontalAlignment','left'
                uiextras.Empty('Parent', gui_plotorg_waveviewer.help_run_title);
                set(gui_plotorg_waveviewer.help_run_title,'Sizes',[40 70 20 70 30]);
        set(gui_plotorg_waveviewer.DataSelBox,'Sizes',[80 25 25 20 25 25 25 25 25 25]);
        
        assignin('base','ALLERPwaviewer',ERPwaviewerin);
    end


%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%-------------------------Setting for Grid--------------------------------
    function plotorg_grid(source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            GridValue=  ERPwaviewerIN.plot_org.Grid;
            source.Value = GridValue;
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902];
        
        
        Value = source.Value;
        try
            ERPwaviewer_apply = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp('f_ERP_plotorg_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        
        indexerp =  ERPwaviewer_apply.SelectERPIdx;
        if numel(indexerp)>1 && Value == 3
            ALLERP = ERPwaviewer_apply.ALLERP;
            chkerp = f_checkerpsets(ALLERP,indexerp);
            if chkerp(3) ==3
                beep;
                source.Value =4;
                MessageViewer= char(strcat('Warning: Type of data varies across ERPsets. "ERPsets" cannot be "Grid" (see Command Window).'));
                erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
                viewer_ERPDAT.Process_messg =4;
                return;
            end
            if chkerp(7) ==7
                source.Value =4;
                beep;
                MessageViewer= char(strcat('Warning: Sampling rate varies across ERPsets. "ERPsets" cannot be "Grid" (see Command Window).'));
                erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
                viewer_ERPDAT.Process_messg =4;
                return;
            end
        end
        if Value ==4
            gui_plotorg_waveviewer.layout_custom_edit.Enable = 'off';
            gui_plotorg_waveviewer.rownum.Enable = 'off';
            gui_plotorg_waveviewer.columnnum.Enable = 'off';
            gui_plotorg_waveviewer.layout_auto.Enable = 'off';
            gui_plotorg_waveviewer.layout_custom.Enable = 'off';
            return;
        end
        if Value ~=4
            if  gui_plotorg_waveviewer.layout_custom.Value ==1
                gui_plotorg_waveviewer.layout_custom_edit.Enable = 'on';
                gui_plotorg_waveviewer.rownum.Enable = 'on';
                gui_plotorg_waveviewer.columnnum.Enable = 'on';
            else
                gui_plotorg_waveviewer.layout_custom_edit.Enable = 'off';
                gui_plotorg_waveviewer.rownum.Enable = 'off';
                gui_plotorg_waveviewer.columnnum.Enable = 'off';
            end
            gui_plotorg_waveviewer.layout_auto.Enable = 'on';
            gui_plotorg_waveviewer.layout_custom.Enable = 'on';
            plotorg_label = [gui_plotorg_waveviewer.overlay.Value,gui_plotorg_waveviewer.pages.Value];
            [~,y] = find(plotorg_label==Value);
            
            if ~isempty(y)
                if y ==1
                    gui_plotorg_waveviewer.overlay.Value = 4;
                elseif y ==2
                    gui_plotorg_waveviewer.pages.Value =  4;
                end
            end
        end
        try
            ERPwaviewerin  = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp('f_ERP_plotorg_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        binArray = ERPwaviewerin.bin;
        chanArray = ERPwaviewerin.chan;
        ERPsetArray = ERPwaviewerin.SelectERPIdx;
        ALLERPIN = ERPwaviewerin.ALLERP;
        if max(ERPsetArray) >length(ALLERPIN)
            ERPsetArray =length(ALLERPIN);
        end
        GridValue = gui_plotorg_waveviewer.grid.Value;
        if GridValue ==1 || GridValue==2 || GridValue ==3
            
            [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERPIN,ERPsetArray);
            if GridValue ==1 %% if  the selected Channel is "Grid"
                plotArray = chanArray;
                plotArrayStr = chanStr(chanArray);
                plotArrayFormt = plotArrayStr;
                plotArrayFormt(numel(plotArray)+1) = {'None'};
            elseif GridValue == 2 %% if the selected Bin is "Grid"
                plotArray = binArray;
                plotArrayStr = binStr(binArray);
                plotArrayFormt = plotArrayStr;
                plotArrayFormt(numel(plotArray)+1) = {'None'};
            elseif GridValue == 3%% if the selected ERPset is "Grid"
                plotArray = ERPsetArray;
                for Numoferpset = 1:numel(ERPsetArray)
                    plotArrayStr(Numoferpset,1) = {char(ALLERPIN(ERPsetArray(Numoferpset)).erpname)};
                end
                plotArrayFormt = plotArrayStr;
                plotArrayFormt(numel(plotArray)+1) = {'None'};
            else
                plotArray = chanArray;
                plotArrayStr = chanStr(chanArray);
                plotArrayFormt = plotArrayStr;
                plotArrayFormt(numel(chanArray)+1) = {'None'};
            end
            plotBox = f_getrow_columnautowaveplot(plotArray);%% the first element is number of rows and the second element is the number of columns
            Numrows = plotBox(1);
            Numcolumns=plotBox(2);
            try
                gui_plotorg_waveviewer.rownum.Value = plotBox(1);
                gui_plotorg_waveviewer.columnnum.Value = plotBox(2);
            catch
                return;
            end
            count = 0;
            for Numofrows = 1:Numrows
                for Numofcolumns = 1:Numcolumns
                    count = count +1;
                    if count> numel(plotArray)
                        GridinforData{Numofrows,Numofcolumns} = char('None');
                    else
                        GridinforData{Numofrows,Numofcolumns} = char(plotArrayStr(count));
                    end
                end
            end
            
            ERPwaviewerin.plot_org.gridlayout.data =GridinforData;
            ERPwaviewerin.plot_org.gridlayout.columFormat = plotArrayFormt';
            ERPwaviewerin.plot_org.gridlayout.columFormatOrig = plotArrayFormt';
            assignin('base','ALLERPwaviewer',ERPwaviewerin);
            if  gui_plotorg_waveviewer.layout_auto.Value==0
                gui_plotorg_waveviewer.layout_custom_edit.Enable = 'on';
            end
        elseif GridValue==4
            gui_plotorg_waveviewer.layout_custom_edit.Enable = 'off';
        end
    end

%%-------------------------Setting for Overlay--------------------------------
    function plotorg_overlay(source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            OverlayValue=  ERPwaviewerIN.plot_org.Overlay;
            source.Value = OverlayValue;
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902];
        
        
        
        Value = source.Value;
        try
            ERPwaviewer_apply = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp('f_ERP_plotorg_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        
        indexerp =  ERPwaviewer_apply.SelectERPIdx;
        if numel(indexerp)>1 && Value == 3
            ALLERP = ERPwaviewer_apply.ALLERP;
            chkerp = f_checkerpsets(ALLERP,indexerp);
            if chkerp(3) ==3
                beep;
                source.Value =4;
                MessageViewer= char(strcat('Warning: Type of data varies across ERPsets. "ERPsets" cannot be "Overlay". (see Command Window)'));
                erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
                viewer_ERPDAT.Process_messg =4;
                return;
            end
            
            if chkerp(7) ==7
                beep;
                source.Value =4;
                MessageViewer= char(strcat('Warning: Sampling rate varies across ERPsets. "ERPsets" cannot be "Overlay". (see Command Window)'));
                erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
                viewer_ERPDAT.Process_messg =4;
                return;
            end
        end
        
        if Value ==4
            return;
        end
        
        if Value ~=4
            plotorg_label = [gui_plotorg_waveviewer.grid.Value,gui_plotorg_waveviewer.pages.Value];
            [~,y] = find(plotorg_label==Value);
            if ~isempty(y)
                if y ==1
                    gui_plotorg_waveviewer.grid.Value = 4;
                elseif y ==2
                    gui_plotorg_waveviewer.pages.Value =  4;
                end
            end
            try
                ALLERPwaviewer = evalin('base','ALLERPwaviewer');
                ERPwaviewerin = ALLERPwaviewer;
            catch
                beep;
                disp('f_ERP_plotorg_waveviewer_GUI() error: Please run the ERP wave viewer again.');
                return;
            end
            binArray = ERPwaviewerin.bin;
            chanArray = ERPwaviewerin.chan;
            ERPsetArray = ERPwaviewerin.SelectERPIdx;
            ALLERPIN = ERPwaviewerin.ALLERP;
            if max(ERPsetArray) >length(ALLERPIN)
                ERPsetArray =length(ALLERPIN);
            end
            GridValue = gui_plotorg_waveviewer.grid.Value;
            [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERPIN,ERPsetArray);
            if GridValue ==1 %% if  the selected Channel is "Grid"
                plotArray = chanArray;
                plotArrayStr = chanStr(chanArray);
                plotArrayFormt = plotArrayStr;
                plotArrayFormt(numel(plotArray)+1) = {'None'};
            elseif GridValue == 2 %% if the selected Bin is "Grid"
                plotArray = binArray;
                plotArrayStr = binStr(binArray);
                plotArrayFormt = plotArrayStr;
                plotArrayFormt(numel(plotArray)+1) = {'None'};
            elseif GridValue == 3%% if the selected ERPset is "Grid"
                plotArray = ERPsetArray;
                for Numoferpset = 1:numel(ERPsetArray)
                    plotArrayStr(Numoferpset,1) = {char(ALLERPIN(ERPsetArray(Numoferpset)).erpname)};
                end
                plotArrayFormt = plotArrayStr;
                plotArrayFormt(numel(plotArray)+1) = {'None'};
            else
                plotArray = chanArray;
                plotArrayStr = chanStr(chanArray);
                plotArrayFormt = plotArrayStr;
                plotArrayFormt(numel(plotArray)+1) = {'None'};
            end
            plotBox = f_getrow_columnautowaveplot(plotArray);%% the first element is number of rows and the second element is the number of columns
            Numrows = plotBox(1);
            Numcolumns=plotBox(2);
            try
                gui_plotorg_waveviewer.rownum.Value = plotBox(1);
                gui_plotorg_waveviewer.columnnum.Value = plotBox(2);
            catch
                return;
            end
            GridinforData = '';
            count = 0;
            for Numofrows = 1:Numrows
                for Numofcolumns = 1:Numcolumns
                    count = count +1;
                    if count> numel(plotArray)
                        GridinforData{Numofrows,Numofcolumns} = char('None');
                    else
                        GridinforData{Numofrows,Numofcolumns} = char(plotArrayStr(count));
                    end
                end
            end
            ERPwaviewerin.plot_org.gridlayout.data =GridinforData;
            ERPwaviewerin.plot_org.gridlayout.columFormat = plotArrayFormt';
            ERPwaviewerin.plot_org.gridlayout.columFormatOrig = plotArrayFormt';
            assignin('base','ALLERPwaviewer',ERPwaviewerin);
            estudioworkingmemory('OverlayIndex',1);
            if GridValue==4
                gui_plotorg_waveviewer.layout_custom_edit.Enable = 'off';
            elseif (GridValue==1|| GridValue==2 ||GridValue==3) && gui_plotorg_waveviewer.layout_auto.Value==0
                gui_plotorg_waveviewer.layout_custom_edit.Enable = 'on';
            end
        end
        
    end

%%-------------------------Setting for Pages--------------------------------
    function plotorg_pages(source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            pagesValue=  ERPwaviewerIN.plot_org.Pages;
            source.Value = pagesValue;
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902];
        
        Value = source.Value;
        if Value ==4
            return;
        end
        if Value ~=4
            %%checking sampling rate of all selected ERPsets
            try
                ERPwaviewerin  = evalin('base','ALLERPwaviewer');
            catch
                beep;
                disp('f_ERP_plotorg_waveviewer_GUI() error: Please run the ERP wave viewer again.');
                return;
            end
            binArray = ERPwaviewerin.bin;
            chanArray = ERPwaviewerin.chan;
            ERPsetArray = ERPwaviewerin.SelectERPIdx;
            ALLERPIN = ERPwaviewerin.ALLERP;
            if max(ERPsetArray) >length(ALLERPIN)
                ERPsetArray =length(ALLERPIN);
            end
            
            for Numoferpset = 1:numel(ERPsetArray)
                Srate(Numoferpset) = ALLERPIN(ERPsetArray(Numoferpset)).srate;
            end
            
            if numel(unique(Srate))>1
                Value =3;
                source.Value =3;
                beep;
                fprintf(2,'\n\n My viewer > Plot Organization > Pages: \n "Pages" must be "ERPsets" because sampling rate varies across the selected ERPsets.\n\n');
            end
            plotorg_label = [gui_plotorg_waveviewer.grid.Value,gui_plotorg_waveviewer.overlay.Value];
            [~,y] = find(plotorg_label==Value);
            if ~isempty(y)
                if y ==1
                    gui_plotorg_waveviewer.grid.Value = 4;
                elseif y ==2
                    gui_plotorg_waveviewer.overlay.Value =  4;
                end
            end
            GridValue =gui_plotorg_waveviewer.grid.Value;
            if GridValue==4
                gui_plotorg_waveviewer.layout_custom_edit.Enable = 'off';
            elseif (GridValue==1|| GridValue==2 ||GridValue==3) && gui_plotorg_waveviewer.layout_auto.Value==0
                gui_plotorg_waveviewer.layout_custom_edit.Enable = 'on';
            end
        end
    end

%%----------------Setting for gridlayout auto-----------------------------
    function layout_auto(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            Layoutvalue=  ERPwaviewerIN.plot_org.gridlayout.op;
            gui_plotorg_waveviewer.layout_auto.Value =Layoutvalue;
            gui_plotorg_waveviewer.layout_custom.Value = ~Layoutvalue;
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902];
        
        
        gui_plotorg_waveviewer.layout_auto.Value =1;
        gui_plotorg_waveviewer.layout_custom.Value = 0;
        gui_plotorg_waveviewer.layout_custom_edit.Enable = 'off';
        gui_plotorg_waveviewer.rownum.Enable = 'off';
        gui_plotorg_waveviewer.columnnum.Enable = 'off';
        
        gui_plotorg_waveviewer.rowgap_auto.Value = 1;
        gui_plotorg_waveviewer.rowgap_auto.Enable = 'off';
        gui_plotorg_waveviewer.rowgapGTPcustom.String = '10';
        gui_plotorg_waveviewer.rowgapGTPcustom.Enable = 'off';
        gui_plotorg_waveviewer.rowoverlap.Value = 0;
        gui_plotorg_waveviewer.rowoverlap.Enable = 'off';
        gui_plotorg_waveviewer.rowgapoverlayedit.Enable = 'off';
        gui_plotorg_waveviewer.columngapgtpop.Value = 1;
        gui_plotorg_waveviewer.columngapgtpop.Enable = 'off';
        gui_plotorg_waveviewer.columngapgtpcustom.String = '10';
        gui_plotorg_waveviewer.columngapgtpcustom.Enable = 'off';
        gui_plotorg_waveviewer.columnoverlay.Value = 0;
        gui_plotorg_waveviewer.columnoverlay.Enable = 'off';
        gui_plotorg_waveviewer.columngapoverlapedit.Enable = 'off';
        try
            ALLERPwaviewer = evalin('base','ALLERPwaviewer');
            ERPwaviewerin = ALLERPwaviewer;
        catch
            beep;
            disp('f_ERP_plotorg_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        binArray = ERPwaviewerin.bin;
        chanArray = ERPwaviewerin.chan;
        ERPsetArray = ERPwaviewerin.SelectERPIdx;
        ALLERPIN = ERPwaviewerin.ALLERP;
        if max(ERPsetArray) >length(ALLERPIN)
            ERPsetArray =length(ALLERPIN);
        end
        GridValue = gui_plotorg_waveviewer.grid.Value;
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERPIN,ERPsetArray);
        if GridValue ==1 %% if  the selected Channel is "Grid"
            plotArray = chanArray;
            plotArrayStr = chanStr(chanArray);
            plotArrayFormt = plotArrayStr;
            plotArrayFormt(numel(plotArray)+1) = {'None'};
        elseif GridValue == 2 %% if the selected Bin is "Grid"
            plotArray = binArray;
            plotArrayStr = binStr(binArray);
            plotArrayFormt = plotArrayStr;
            plotArrayFormt(numel(plotArray)+1) = {'None'};
        elseif GridValue == 3%% if the selected ERPset is "Grid"
            plotArray = ERPsetArray;
            for Numoferpset = 1:numel(ERPsetArray)
                plotArrayStr(Numoferpset,1) = {char(ALLERPIN(ERPsetArray(Numoferpset)).erpname)};
            end
            plotArrayFormt = plotArrayStr;
            plotArrayFormt(numel(plotArray)+1) = {'None'};
        else
            plotArray = chanArray;
            plotArrayStr = chanStr(chanArray);
            plotArrayFormt = plotArrayStr;
            plotArrayFormt(numel(plotArray)+1) = {'None'};
        end
        plotBox = f_getrow_columnautowaveplot(plotArray);%% the first element is number of rows and the second element is the number of columns
        Numrows = plotBox(1);
        Numcolumns=plotBox(2);
        try
            gui_plotorg_waveviewer.rownum.Value = plotBox(1);
            gui_plotorg_waveviewer.columnnum.Value = plotBox(2);
        catch
            return;
        end
        GridinforData = '';
        count = 0;
        for Numofrows = 1:Numrows
            for Numofcolumns = 1:Numcolumns
                count = count +1;
                if count> numel(plotArray)
                    GridinforData{Numofrows,Numofcolumns} = char('None');
                else
                    GridinforData{Numofrows,Numofcolumns} = char(plotArrayStr(count));
                end
            end
        end
        
        ERPwaviewerin.plot_org.gridlayout.data =GridinforData;
        ERPwaviewerin.plot_org.gridlayout.columFormat = plotArrayFormt';
        ERPwaviewerin.plot_org.gridlayout.columFormatOrig = plotArrayFormt';
        ALLERPwaviewer=ERPwaviewerin;
        assignin('base','ALLERPwaviewer',ALLERPwaviewer);
    end


%%--------------Setting for layout custom----------------------------------
    function layout_custom(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            Layoutvalue=  ERPwaviewerIN.plot_org.gridlayout.op;
            gui_plotorg_waveviewer.layout_auto.Value =Layoutvalue;
            gui_plotorg_waveviewer.layout_custom.Value = ~Layoutvalue;
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902];
        
        gui_plotorg_waveviewer.layout_auto.Value =0;
        gui_plotorg_waveviewer.layout_custom.Value = 1;
        gui_plotorg_waveviewer.rownum.Enable = 'on';
        gui_plotorg_waveviewer.columnnum.Enable = 'on';
        gui_plotorg_waveviewer.layout_custom_edit.Enable = 'on';
        
        gui_plotorg_waveviewer.rowgap_auto.Enable = 'on';
        gui_plotorg_waveviewer.rowgapGTPcustom.Enable = 'on';
        gui_plotorg_waveviewer.rowoverlap.Enable = 'on';
        gui_plotorg_waveviewer.rowgapoverlayedit.Enable = 'on';
        rowGTPop = gui_plotorg_waveviewer.rowgap_auto.Value;
        rowoverlayop = gui_plotorg_waveviewer.rowoverlap.Value;
        if rowGTPop && ~rowoverlayop
            gui_plotorg_waveviewer.rowoverlap.Value =0;
            gui_plotorg_waveviewer.rowgapoverlayedit.Enable = 'off';
        end
        if rowGTPop && rowoverlayop
            gui_plotorg_waveviewer.rowoverlap.Value =0;
            gui_plotorg_waveviewer.rowgapoverlayedit.Enable = 'off';
            rowoverlayop =0;
        end
        if rowoverlayop && ~rowGTPop
            gui_plotorg_waveviewer.rowgap_auto.Enable = 'off';
            gui_plotorg_waveviewer.rowgap_auto.Value = 0;
        end
        
        gui_plotorg_waveviewer.columngapgtpop.Enable = 'on';
        gui_plotorg_waveviewer.columngapgtpcustom.Enable = 'on';
        gui_plotorg_waveviewer.columnoverlay.Enable = 'on';
        gui_plotorg_waveviewer.columngapoverlapedit.Enable = 'on';
        columnGTPop = gui_plotorg_waveviewer.columngapgtpop.Value;
        columnoverlayop = gui_plotorg_waveviewer.columnoverlay.Value;
        if columnGTPop && ~columnoverlayop
            gui_plotorg_waveviewer.columnoverlay.Value =0;
            gui_plotorg_waveviewer.columngapoverlapedit.Enable = 'off';
        end
        if columnGTPop && columnoverlayop
            gui_plotorg_waveviewer.columnoverlay.Value =0;
            gui_plotorg_waveviewer.columngapoverlapedit.Enable = 'off';
            columnoverlayop = 0;
        end
        
        if columnoverlayop && ~columnGTPop
            gui_plotorg_waveviewer.columngapgtpcustom.Enable = 'off';
            gui_plotorg_waveviewer.columngapgtpop.Value = 0;
        end
    end

%%------------------number of rows-----------------------------------------
    function plotorg_rownum(Str,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            rowNum=  ERPwaviewerIN.plot_org.gridlayout.rows;
            Str.Value = rowNum;
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902];
    end


%%------------------------------Number of columns--------------------------
    function plotorg_columnnum(Str,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            columNum=  ERPwaviewerIN.plot_org.gridlayout.columns;
            Str.Value = columNum;
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902];
    end



%%-------------------row GTP option----------------------------------------
    function rowgapgtpauto(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            rowGap=  ERPwaviewerIN.plot_org.gridlayout.rowgap.GTPOP;
            gui_plotorg_waveviewer.rowgap_auto.Value = rowGap;
            gui_plotorg_waveviewer.rowoverlap.Value =~rowGap;
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902];
        
        gui_plotorg_waveviewer.rowgap_auto.Value = 1;
        gui_plotorg_waveviewer.rowgapGTPcustom.Enable = 'on';
        gui_plotorg_waveviewer.rowoverlap.Value =0;
        gui_plotorg_waveviewer.rowgapoverlayedit.Enable = 'off';
    end

%%----------------------row GTP custom-------------------------------------
    function rowgapgtpcustom(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            rowGapcustom=  ERPwaviewerIN.plot_org.gridlayout.rowgap.GTPValue;
            Source.String = num2str(rowGapcustom);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902];
        
        rowgap = str2num(Source.String);
        if isempty(rowgap) || numel(rowgap)~=1 || rowgap<=0
            Source.String = '10';
            return;
        end
    end


%%----------------row gap overlay option-----------------------------------
    function rowoverlap(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            rowGap=  ERPwaviewerIN.plot_org.gridlayout.rowgap.GTPOP;
            gui_plotorg_waveviewer.rowgap_auto.Value = rowGap;
            gui_plotorg_waveviewer.rowoverlap.Value =~rowGap;
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902];
        
        gui_plotorg_waveviewer.rowgap_auto.Value = 0;
        gui_plotorg_waveviewer.rowgapGTPcustom.Enable = 'off';
        gui_plotorg_waveviewer.rowoverlap.Value =1;
        gui_plotorg_waveviewer.rowgapoverlayedit.Enable = 'on';
    end

%%-------------------row gap overlay custom--------------------------------
    function rowoverlapcustom(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            rowoverlaycustom=  ERPwaviewerIN.plot_org.gridlayout.rowgap.OverlayValue;
            Source.String = num2str(rowoverlaycustom);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902];
        
        rowoverlay = str2num(Source.String);
        if isempty(rowoverlay) || numel(rowoverlay)~=1 || rowoverlay<=0 || rowoverlay>=100
            Source.String = '40';
            return;
        end
    end


%%----------------column GTP option----------------------------------------
    function columngapgtpop(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            columnGap=  ERPwaviewerIN.plot_org.gridlayout.columngap.GTPOP;
            gui_plotorg_waveviewer.columngapgtpop.Value =columnGap;
            gui_plotorg_waveviewer.columnoverlay.Value=~columnGap;
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902];
        
        gui_plotorg_waveviewer.columngapgtpop.Value =1;
        gui_plotorg_waveviewer.columngapgtpcustom.Enable = 'on';
        gui_plotorg_waveviewer.columnoverlay.Value=0;
        gui_plotorg_waveviewer.columngapoverlapedit.Enable = 'off';
    end
%%-----------------column GTP custom---------------------------------------
    function columngapGTPcustom(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            columnGapcustom=  ERPwaviewerIN.plot_org.gridlayout.columngap.GTPValue;
            Source.String = num2str(columnGapcustom);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902];
        
        columngap = str2num(Source.String);
        if isempty(columngap) || numel(columngap)~=1 || columngap<=0
            Source.String = '10';
            return;
        end
    end



%%----------------column overlay option------------------------------------
    function columnoverlap(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            columnGap=  ERPwaviewerIN.plot_org.gridlayout.columngap.GTPOP;
            gui_plotorg_waveviewer.columngapgtpop.Value =columnGap;
            gui_plotorg_waveviewer.columnoverlay.Value=~columnGap;
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902];
        
        
        colnOverlay = str2num(char( gui_plotorg_waveviewer.columngapoverlapedit.String));
        gui_plotorg_waveviewer.columngapgtpop.Value =0;
        gui_plotorg_waveviewer.columngapgtpcustom.Enable = 'off';
        gui_plotorg_waveviewer.columnoverlay.Value=1;
        gui_plotorg_waveviewer.columngapoverlapedit.Enable = 'on';
        %         Source.String = '40';
        if isempty(colnOverlay)
            gui_plotorg_waveviewer.columngapoverlapedit.String = '40';
        end
    end



%%-----------------column overlay custom-----------------------------------
    function columnoverlaycustom(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            columnOverlaycustom=  ERPwaviewerIN.plot_org.gridlayout.columngap.OverlayValue;
            Source.String = num2str(columnOverlaycustom);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902];
        
        
        columnoverlay = str2num(Source.String);
        if isempty(columnoverlay) || numel(columnoverlay)~=1 || columnoverlay<=0 || columnoverlay>=100
            Source.String = '40';
            return;
        end
    end



%%-----------------Edit the layout-----------------------------------------
    function plotorg_edit(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902];
        
        
        MessageViewer= char(strcat('Plot Organization > Edit'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        try
            ERPwaviewerin = evalin('base','ALLERPwaviewer');
        catch
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n f_ERP_plotorg_waveviewer_GUI()> plotorg_edit() error: Cannot get parameters for whole panel.\n Please run My viewer again.\n\n');
            return;
        end
        ERPwaviewerin.plot_org.gridlayout.rows = gui_plotorg_waveviewer.rownum.Value;
        ERPwaviewerin.plot_org.gridlayout.columns = gui_plotorg_waveviewer.columnnum.Value;
        assignin('base','ALLERPwaviewer',ERPwaviewerin);
        
        
        columFormat =  ERPwaviewerin.plot_org.gridlayout.columFormat;
        for ii = 1:length(columFormat)-1
            columFormatin{ii,1}  = columFormat{ii};
        end
        plotArrayFormtOlder = ERPwaviewerin.plot_org.gridlayout.columFormatOrig;
        plotBox(1) = ERPwaviewerin.plot_org.gridlayout.rows;
        plotBox(2) = ERPwaviewerin.plot_org.gridlayout.columns;
        try
            GridinforData = ERPwaviewerin.plot_org.gridlayout.data;
        catch
            GridinforData = [];
        end
        def =  ERP_layoutstringGUI(columFormatin,plotArrayFormtOlder,plotBox,GridinforData);
        if isempty(def)
            disp('User selected cancel');
            return;
        end
        TableDataDf  = def{1};
        columFormat = def{2};
        [NumRows,NumColumns] = size(TableDataDf);
        GridposArray = zeros(NumRows,NumColumns);
        for Numofrows = 1:NumRows
            for Numofcolumns = 1:NumColumns
                SingleStr =  char(TableDataDf{Numofrows,Numofcolumns});
                [C,IA] = ismember_bc2(SingleStr,columFormat);
                if C ==1
                    if IA < length(columFormat)
                        GridposArray(Numofrows,Numofcolumns)   = IA;
                    elseif IA == length(columFormat) %%%If the element is 'None'
                        GridposArray(Numofrows,Numofcolumns)   = 0;
                    end
                else
                    GridposArray(Numofrows,Numofcolumns)   = 0;
                end
            end
        end
        GridposArrayMarker = cell(NumRows,NumColumns);
        for Numofrows = 1:NumRows
            for Numofcolumns = 1:NumColumns
                CellNum =  GridposArray(Numofrows,Numofcolumns);
                [xRow,yColumn] = find(GridposArray==CellNum);
                if CellNum > 0 && ~isempty(xRow) && numel(yColumn)>1
                    GridposArrayMarker{Numofrows,Numofcolumns} =  [xRow,yColumn];
                end
            end
        end
        try %% try to display the reminder for the repeated items if they exist
            msgboxTextAll = '';
            for Numofrows = 1:NumRows
                for Numofcolumns = 1:NumColumns
                    CellNum =  GridposArray(Numofrows,Numofcolumns);
                    SingleCellMarker =  GridposArrayMarker{Numofrows,Numofcolumns};
                    if ~isempty(SingleCellMarker)
                        xRow = SingleCellMarker(:,1);
                        yColumn = SingleCellMarker(:,2);
                        msgboxText =  [num2str(numel(yColumn)),32,'"',columFormat{CellNum},'"',32, 'are defined and they are at',32,];
                        Location = char(strcat('(R',num2str(xRow(1)),',','C',num2str(yColumn(1)),')'));
                        for Numofreapt = 2:numel(yColumn)
                            if Numofreapt==numel(yColumn)
                                Location = char(strcat(Location,', and',32,'(R',num2str(xRow(Numofreapt)),',','C',num2str(yColumn(Numofreapt)),').'));
                            else
                                Location = char(strcat(Location,',',32,'(R',num2str(xRow(Numofreapt)),',','C',num2str(yColumn(Numofreapt)),')'));
                            end
                        end
                        for Numofmarker = 2:numel(xRow)
                            GridposArrayMarker{xRow(Numofmarker),yColumn(Numofmarker)} = '';
                        end
                        if isempty(msgboxTextAll)
                            msgboxTextAll = strcat('%s\n',msgboxText,32,Location);
                        else
                            msgboxTextAll = strcat(msgboxTextAll,'\n',msgboxText,32,Location);
                        end
                    end
                end
            end
        catch
            
        end
        
        button = 'Apply';
        if ~isempty(msgboxTextAll)
            question = ['Do you want to use these repeated items?'];
            BackERPLABcolor = [1 0.9 0.3];    % yellow
            title = 'EStudio Reminder: My Viewer > Plot organization > Edit';
            oldcolor = get(0,'DefaultUicontrolBackgroundColor');
            set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
            button = questdlg(sprintf([msgboxTextAll],question), title,'No', 'Yes','Yes');
            set(0,'DefaultUicontrolBackgroundColor',oldcolor)
        end
        
        if isempty(button) || strcmpi(button,'No')
            return;
        end
        
        try
            ERPwaviewerin = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp('f_ERP_plotorglayout_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        ERPwaviewerin.plot_org.gridlayout.columFormat = columFormat;
        ERPwaviewerin.plot_org.gridlayout.data =TableDataDf;
        assignin('base','ALLERPwaviewer',ERPwaviewerin);
        %         f_ERP_plotorglayout_waveviewer_GUI();
        f_redrawERP_viewer_test();
        estudioworkingmemory('MyViewer_plotorg',0);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [1,1,1];
    end


%%-------load the saved parameters for plotting organization---------------
    function layout_custom_load(~,~)
        [filename, filepath] = uigetfile('*.mat', ...
            'Load parametrs for "Plot Organization"', ...
            'MultiSelect', 'off');
        if isequal(filename,0)
            disp('User selected Cancel');
            return;
        end
        Plot_orgpar = importdata([filepath,filename]);
        try
            ALLERPwaviewer = evalin('base','ALLERPwaviewer');
            ERPwaviewerin = ALLERPwaviewer;
        catch
            beep;
            disp('f_ERP_plotorg_waveviewer_GUI() > layout_custom_load() error: Please run the ERP wave viewer again.');
            return;
        end
        
        try
            gui_plotorg_waveviewer.grid.Value = Plot_orgpar.Grid;
            gui_plotorg_waveviewer.overlay.Value = Plot_orgpar.Overlay;
            gui_plotorg_waveviewer.pages.Value=Plot_orgpar.Pages;
            gui_plotorg_waveviewer.layout_auto.Value=Plot_orgpar.gridlayout.op;
            gui_plotorg_waveviewer.layout_custom.Value = ~Plot_orgpar.gridlayout.op;
            ERPwaviewerin.plot_org.Grid= gui_plotorg_waveviewer.grid.Value;
            ERPwaviewerin.plot_org.Overlay =gui_plotorg_waveviewer.overlay.Value;
            ERPwaviewerin.plot_org.Pages=gui_plotorg_waveviewer.pages.Value;
        catch
            beep;
            disp('The imported parameters were invalid.')
            return;
        end
        
        %%------------------default labels---------------------------------
        binArray = ERPwaviewerin.bin;
        chanArray = ERPwaviewerin.chan;
        ERPsetArray = ERPwaviewerin.SelectERPIdx;
        ALLERPIN = ERPwaviewerin.ALLERP;
        if max(ERPsetArray) >length(ALLERPIN)
            ERPsetArray =length(ALLERPIN);
        end
        GridValue = gui_plotorg_waveviewer.grid.Value;
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERPIN,ERPsetArray);
        if GridValue ==1 %% if  the selected Channel is "Grid"
            plotArray = chanArray;
            plotArrayStr = chanStr(chanArray);
            plotArrayFormtdef = plotArrayStr;
            plotArrayFormtdef(numel(plotArray)+1) = {'None'};
        elseif GridValue == 2 %% if the selected Bin is "Grid"
            plotArray = binArray;
            plotArrayStr = binStr(binArray);
            plotArrayFormtdef = plotArrayStr;
            plotArrayFormtdef(numel(plotArray)+1) = {'None'};
        elseif GridValue == 3%% if the selected ERPset is "Grid"
            plotArray = ERPsetArray;
            for Numoferpset = 1:numel(ERPsetArray)
                plotArrayStr(Numoferpset,1) = {char(ALLERPIN(ERPsetArray(Numoferpset)).erpname)};
            end
            plotArrayFormtdef = plotArrayStr;
            plotArrayFormtdef(numel(plotArray)+1) = {'None'};
        else
            plotArray = chanArray;
            plotArrayStr = chanStr(chanArray);
            plotArrayFormtdef = plotArrayStr;
            plotArrayFormtdef(numel(plotArray)+1) = {'None'};
        end
        plotBox = f_getrow_columnautowaveplot(plotArray);%% the first element is number of rows and the second element is the number of columns
        
        gui_plotorg_waveviewer.rownum.Value=Plot_orgpar.gridlayout.rows;
        gui_plotorg_waveviewer.columnnum.Value=Plot_orgpar.gridlayout.columns;
        try
            RowNum = Plot_orgpar.gridlayout.rows;
        catch
            RowNum = plotBox(1);
            Plot_orgpar.gridlayout.rows = plotBox(1);
        end
        try
            ColumNum = Plot_orgpar.gridlayout.columns;
        catch
            ColumNum = plotBox(2);
            Plot_orgpar.gridlayout.columns= plotBox(2);
        end
        plotArrayFormtimp =  Plot_orgpar.gridlayout.columFormatOrig;
        
        plotArrayFormtimpChag = Plot_orgpar.gridlayout.columFormat;
        button='';
        if numel(plotArrayFormtimp) ~= numel(plotArrayFormtdef)
            button='OK';
            plotArrayFormtimp = plotArrayFormtdef;
            plotArrayFormtimpChag =plotArrayFormtdef;
        else
            code  =0;
            for Numoflabel = 1:numel(plotArrayFormtimpChag)-1
                if ~strcmpi(plotArrayFormtimp{Numoflabel},plotArrayFormtdef{Numoflabel})
                    code = code+1;
                end
                if code~=0
                    plotArrayFormtimp = plotArrayFormtdef;
                    plotArrayFormtimpChag =plotArrayFormtdef;
                    button='OK';
                end
            end
        end
        GridinforData = Plot_orgpar.gridlayout.data;
        if ~isempty(button)
            BackERPLABcolor = [1 0.9 0.3];    % yellow
            question = ['Warning: Bin/Channel/ERPset labels in saved parameter file donot match with the default ones.\n\n See Command Window for details'];
            title = 'Plot Organization > Load > layout_custom_load()';
            oldcolor = get(0,'DefaultUicontrolBackgroundColor');
            set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
            button = questdlg(sprintf(question), title,'OK','OK');
            set(0,'DefaultUicontrolBackgroundColor',oldcolor);
            
            fileCheck{1,1} = 'Default labels';
            fileCheck{1,2} = 'Imported labels';
            plotArrayFormtimp1 = Plot_orgpar.gridlayout.columFormatOrig;
            for Numoflist = 1:max([numel(plotArrayFormtimp1), numel(plotArrayFormtdef)])-1
                if Numoflist < numel(plotArrayFormtdef)
                    fileCheck{Numoflist+1,1} = plotArrayFormtdef{Numoflist};
                else
                    fileCheck{Numoflist+1,1} =  'none';
                end
                
                if Numoflist < numel(plotArrayFormtimp1)
                    fileCheck{1+Numoflist,2} = plotArrayFormtimp1{Numoflist};
                else
                    fileCheck{1+Numoflist,2} ='none';
                end
            end
            
            fprintf( [repmat('_',1,40) '\n']);
            
            for Numoflist = 1:size(fileCheck,1)
                hdr{1} = fileCheck{Numoflist,1};
                hdr{2} = fileCheck{Numoflist,2};
                fprintf( '\n%5s %24s %20s\n\n', hdr{:});
            end
            fprintf( ['\n',repmat('_',1,40) '\n']);
            
            GridinforData = '';
            count = 0;
            for Numofrows = 1:RowNum
                for Numofcolumns = 1:ColumNum
                    count = count +1;
                    if count> numel(plotArrayFormtimp)-1
                        GridinforData{Numofrows,Numofcolumns} = char('None');
                    else
                        GridinforData{Numofrows,Numofcolumns} = char(plotArrayFormtimp(count));
                    end
                end
            end
        end
        
        if gui_plotorg_waveviewer.layout_auto.Value==1
            LayOutauto = 'off';
        else
            LayOutauto = 'on';
        end
        try
            ERPwaviewerin.plot_org.gridlayout.data= GridinforData;
            gui_plotorg_waveviewer.layoutinfor_table.Enable =LayOutauto;
            gui_plotorg_waveviewer.rownum.Enable=LayOutauto;
            gui_plotorg_waveviewer.columnnum.Enable=LayOutauto;
            ERPwaviewerin.plot_org.gridlayout.rows = Plot_orgpar.gridlayout.rows;
            ERPwaviewerin.plot_org.gridlayout.columns =Plot_orgpar.gridlayout.columns;
            ERPwaviewerin.plot_org.gridlayout.columFormat = plotArrayFormtimpChag;
            ERPwaviewerin.plot_org.gridlayout.columFormatOrig = plotArrayFormtimp;
        catch
            beep;
            disp('The imported parameters didnot match with those of "Plot Organization".')
            return;
        end
        
        %%row gap
        try
            rowgapAutoValue = Plot_orgpar.gridlayout.rowgap.GTPOP;
            gui_plotorg_waveviewer.rowgap_auto.Value = rowgapAutoValue;
            gui_plotorg_waveviewer.rowgapGTPcustom.String = num2str( Plot_orgpar.gridlayout.rowgap.GTPValue);
            gui_plotorg_waveviewer.rowoverlap.Value = ~rowgapAutoValue;
            gui_plotorg_waveviewer.rowgapoverlayedit.String = num2str(Plot_orgpar.gridlayout.rowgap.OverlayValue);
            
            gui_plotorg_waveviewer.rowgap_auto.Enable = LayOutauto;
            gui_plotorg_waveviewer.rowgapGTPcustom.Enable = LayOutauto;
            gui_plotorg_waveviewer.rowoverlap.Enable = LayOutauto;
            gui_plotorg_waveviewer.rowgapoverlayedit.Enable = LayOutauto;
            if gui_plotorg_waveviewer.layout_auto.Value ==0
                if  rowgapAutoValue ==1
                    gui_plotorg_waveviewer.rowgapGTPcustom.Enable = 'on';
                    gui_plotorg_waveviewer.rowgapoverlayedit.Enable = 'off';
                else
                    gui_plotorg_waveviewer.rowgapGTPcustom.Enable = 'off';
                    gui_plotorg_waveviewer.rowgapoverlayedit.Enable = 'on';
                end
            end
        catch
            beep;
            disp('The imported parameters for rows at "Grid Spacing" didnot match with those of "Plot Organization".')
            return;
        end
        %%column gap
        try
            columngapAutoValue= Plot_orgpar.gridlayout.columngap.GTPOP ;
            gui_plotorg_waveviewer.columngapgtpop.Value= columngapAutoValue;
            gui_plotorg_waveviewer.columngapgtpcustom.String = num2str(Plot_orgpar.gridlayout.columngap.GTPValue);
            gui_plotorg_waveviewer.columnoverlay.Value = ~columngapAutoValue;
            gui_plotorg_waveviewer.columngapoverlapedit.String = num2str(Plot_orgpar.gridlayout.columngap.OverlayValue);
            gui_plotorg_waveviewer.columngapgtpop.Enable = LayOutauto;
            gui_plotorg_waveviewer.columngapgtpcustom.Enable = LayOutauto;
            gui_plotorg_waveviewer.columnoverlay.Enable = LayOutauto;
            gui_plotorg_waveviewer.columngapoverlapedit.Enable = LayOutauto;
            if gui_plotorg_waveviewer.layout_auto.Value ==0
                if columngapAutoValue ==1
                    gui_plotorg_waveviewer.columngapgtpcustom.Enable = 'on';
                    gui_plotorg_waveviewer.columngapoverlapedit.Enable = 'off';
                else
                    gui_plotorg_waveviewer.columngapgtpcustom.Enable = 'off';
                    gui_plotorg_waveviewer.columngapoverlapedit.Enable = 'on';
                end
            end
        catch
            beep;
            disp('The imported parameters for columns at "Grid Spacing" didnot match with those of "Plot Organization".')
            return;
        end
        assignin('base','ALLERPwaviewer',ERPwaviewerin);
        
        viewer_ERPDAT.page_xyaxis = viewer_ERPDAT.page_xyaxis+1;
        %%change the legend names based on the imported parameters
        viewer_ERPDAT.count_legend  = viewer_ERPDAT.count_legend+1;
        f_redrawERP_viewer_test();
    end


%%-----------------Save parameters as .mat format--------------------------
    function layout_custom_save(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex==4
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        %         estudioworkingmemory('MyViewer_plotorg',1);
        %         gui_plotorg_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902];
        
        
        try
            ERPwaviewerin  = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp('f_ERP_plotorg_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        Plot_orgpar.Grid = gui_plotorg_waveviewer.grid.Value;
        Plot_orgpar.Overlay = gui_plotorg_waveviewer.overlay.Value;
        Plot_orgpar.Pages = gui_plotorg_waveviewer.pages.Value;
        Plot_orgpar.gridlayout.op =gui_plotorg_waveviewer.layout_auto.Value;
        Plot_orgpar.gridlayout.data =ERPwaviewerin.plot_org.gridlayout.data;
        Plot_orgpar.gridlayout.rows = gui_plotorg_waveviewer.rownum.Value;
        Plot_orgpar.gridlayout.columns = gui_plotorg_waveviewer.columnnum.Value;
        Plot_orgpar.gridlayout.columFormat = ERPwaviewerin.plot_org.gridlayout.columFormat;
        Plot_orgpar.gridlayout.columFormatOrig = ERPwaviewerin.plot_org.gridlayout.columFormatOrig;
        Plot_orgpar.gridlayout.rowgap.GTPOP = ERPwaviewerin.plot_org.gridlayout.rowgap.GTPOP;
        Plot_orgpar.gridlayout.rowgap.GTPValue = ERPwaviewerin.plot_org.gridlayout.rowgap.GTPValue;
        Plot_orgpar.gridlayout.rowgap.OverlayOP = ERPwaviewerin.plot_org.gridlayout.rowgap.OverlayOP;
        Plot_orgpar.gridlayout.rowgap.OverlayValue = ERPwaviewerin.plot_org.gridlayout.rowgap.OverlayValue;
        
        Plot_orgpar.gridlayout.columngap.GTPOP = ERPwaviewerin.plot_org.gridlayout.columngap.GTPOP;
        Plot_orgpar.gridlayout.columngap.GTPValue = ERPwaviewerin.plot_org.gridlayout.columngap.GTPValue;
        Plot_orgpar.gridlayout.columngap.OverlayOP = ERPwaviewerin.plot_org.gridlayout.columngap.OverlayOP;
        Plot_orgpar.gridlayout.columngap.OverlayValue = ERPwaviewerin.plot_org.gridlayout.columngap.OverlayValue;
        
        pathstr = pwd;
        namedef ='LayoutInfor';
        [erpfilename, erppathname, indxs] = uiputfile({'*.mat'}, ...
            ['Save "','Information of Plot Organization', '" as'],...
            fullfile(pathstr,namedef));
        if isequal(erpfilename,0)
            disp('User selected Cancel')
            return
        end
        [pathx, filename, ext] = fileparts(erpfilename);
        [pathstr, erpfilename, ext] = fileparts(erpfilename) ;
        if indxs==1
            ext = '.mat';
        elseif indxs==2
            ext = '.mat';
        else
            ext = '.mat';
        end
        erpFilename = char(strcat(erpfilename,ext));
        try
            save([erppathname,erpFilename],'Plot_orgpar','-v7.3');
        catch
            beep;
            disp('Cannot save the parameters for "Plot Organization", please try again');
            return;
        end
    end


%%--------------Canel changed parameters-----------------------------------
    function plotorg_cancel(~,~)
        changeFlag =  estudioworkingmemory('MyViewer_plotorg');
        if changeFlag~=1
            return;
        end
        try
            ERPwaviewer_apply = evalin('base','ALLERPwaviewer');
        catch
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n Plot Organization > Cancel error: Cannot get parameters for whole panel.\n Please run My viewer again.\n\n');
            return;
        end
        gui_plotorg_waveviewer.grid.Value=ERPwaviewer_apply.plot_org.Grid ;
        gui_plotorg_waveviewer.overlay.Value=ERPwaviewer_apply.plot_org.Overlay;
        gui_plotorg_waveviewer.pages.Value=ERPwaviewer_apply.plot_org.Pages;
        gui_plotorg_waveviewer.layout_auto.Value = ERPwaviewer_apply.plot_org.gridlayout.op;
        gui_plotorg_waveviewer.layout_custom.Value = ~ERPwaviewer_apply.plot_org.gridlayout.op;
        gui_plotorg_waveviewer.layout_auto.Enable = 'on';
        gui_plotorg_waveviewer.layout_custom.Enable = 'on';
        if gui_plotorg_waveviewer.layout_auto.Value==1
            EnableFlag = 'off';
            gui_plotorg_waveviewer.layout_custom_edit.Enable = 'off';
        else
            EnableFlag = 'on';
            gui_plotorg_waveviewer.layout_custom_edit.Enable = 'on';
        end
        gui_plotorg_waveviewer.rownum.Value= ERPwaviewer_apply.plot_org.gridlayout.rows;
        gui_plotorg_waveviewer.columnnum.Value=ERPwaviewer_apply.plot_org.gridlayout.columns;
        rowGapValue =  ERPwaviewer_apply.plot_org.gridlayout.rowgap.GTPOP;
        gui_plotorg_waveviewer.rowgap_auto.Value=rowGapValue;
        gui_plotorg_waveviewer.rowoverlap.Value=~rowGapValue;
        gui_plotorg_waveviewer.rowgapGTPcustom.String = num2str(ERPwaviewer_apply.plot_org.gridlayout.rowgap.GTPValue);
        gui_plotorg_waveviewer.rowgapoverlayedit.String=num2str(ERPwaviewer_apply.plot_org.gridlayout.rowgap.OverlayValue);
        columnGapValue =ERPwaviewer_apply.plot_org.gridlayout.columngap.GTPOP;
        gui_plotorg_waveviewer.columngapgtpop.Value= columnGapValue;
        gui_plotorg_waveviewer.columnoverlay.Value = ~columnGapValue;
        gui_plotorg_waveviewer.columngapgtpcustom.String = num2str(ERPwaviewer_apply.plot_org.gridlayout.columngap.GTPValue);
        gui_plotorg_waveviewer.columngapoverlapedit.String=num2str(ERPwaviewer_apply.plot_org.gridlayout.columngap.OverlayValue);
%         gui_plotorg_waveviewer.layout_custom_edit.Enable = EnableFlag;
        gui_plotorg_waveviewer.rownum.Enable = EnableFlag;
        gui_plotorg_waveviewer.columnnum.Enable = EnableFlag;
        gui_plotorg_waveviewer.rowgap_auto.Enable = EnableFlag;
        gui_plotorg_waveviewer.rowgapGTPcustom.Enable = EnableFlag;
        gui_plotorg_waveviewer.rowoverlap.Enable = EnableFlag;
        gui_plotorg_waveviewer.rowgapoverlayedit.Enable = EnableFlag;
        gui_plotorg_waveviewer.columngapgtpop.Enable = EnableFlag;
        gui_plotorg_waveviewer.columngapgtpcustom.Enable = EnableFlag;
        gui_plotorg_waveviewer.columnoverlay.Enable = EnableFlag;
        gui_plotorg_waveviewer.columngapoverlapedit.Enable = EnableFlag;
        if strcmpi(EnableFlag,'on')
            gui_plotorg_waveviewer.rowgap_auto.Enable = 'on';
            gui_plotorg_waveviewer.rowoverlap.Enable = 'on';
            if rowGapValue==1
                gui_plotorg_waveviewer.rowgapGTPcustom.Enable = 'on';
                gui_plotorg_waveviewer.rowgapoverlayedit.Enable = 'off';
            else
                gui_plotorg_waveviewer.rowgapGTPcustom.Enable = 'off';
                gui_plotorg_waveviewer.rowgapoverlayedit.Enable = 'on';
            end
            gui_plotorg_waveviewer.columngapgtpop.Enable = 'on';
            gui_plotorg_waveviewer.columnoverlay.Enable = 'on';
            if columnGapValue==1
                gui_plotorg_waveviewer.columngapgtpcustom.Enable = 'on';
                gui_plotorg_waveviewer.columngapoverlapedit.Enable = 'off';
            else
                gui_plotorg_waveviewer.columngapgtpcustom.Enable = 'off';
                gui_plotorg_waveviewer.columngapoverlapedit.Enable = 'on';
            end
        end
        
        estudioworkingmemory('MyViewer_plotorg',0);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [1 1 1];
    end



%%----------------------Apply the changed parameters-----------------------
    function plotorg_apply(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_plotorg',0);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [1 1 1];
        
        MessageViewer= char(strcat('Plot Organization > Apply'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        
        plotorg_label = [gui_plotorg_waveviewer.grid.Value,gui_plotorg_waveviewer.overlay.Value,gui_plotorg_waveviewer.pages.Value];
        [~,y] = find(plotorg_label==4);
        if ~isempty(y)
            if numel(y) ==1
                switch  y
                    case 1
                        fprintf(2,'\n Plot Organization > Apply-error:\n Please define "Grid".\n\n');
                    case 2
                        fprintf(2,'\n Plot Organization > Apply-error:\n Please define "Overlay".\n\n');
                    case 3
                        fprintf(2,'\n Plot Organization > Apply-error:\n Please define "Pages".\n\n');
                end
            end
            if numel(y) ==2
                if y(1) ==1 && y(2) ==2
                    fprintf(2,'\n Plot Organization > Apply-error:\n Please define "Grid" and "Overlay".\n\n');
                elseif y(1) ==1 && y(2) ==3
                    fprintf(2,'\n Plot Organization > Apply-error:\n Please define "Grid" and "Pages".\n\n');
                elseif y(1) ==2 && y(2) ==3
                    fprintf(2,'\n Plot Organization > Apply-error:\n Please define "Overlay" and "Pages".\n\n');
                end
            end
            if numel(y) ==3
                fprintf(2,'\n Plot Organization > Apply-error:\n Please define "Grid", "Overlay" and "Pages".\n\n');
            end
            viewer_ERPDAT.Process_messg =3;
            return;
        end
        
        %%checking the numbers of rows and columns
        try
            ERPwaviewerin = evalin('base','ALLERPwaviewer');
        catch
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n Plot Organization > Apply-f_ERP_plotorg_waveviewer_GUI() error: Cannot get parameters for whole panel.\n Please run My viewer again.\n\n');
            return;
        end
        binArray = ERPwaviewerin.bin;
        chanArray = ERPwaviewerin.chan;
        ERPsetArray = ERPwaviewerin.SelectERPIdx;
        ALLERPIN = ERPwaviewerin.ALLERP;
        if max(ERPsetArray) >length(ALLERPIN)
            ERPsetArray =length(ALLERPIN);
        end
        
        GridValue = gui_plotorg_waveviewer.grid.Value;
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERPIN,ERPsetArray);
        if GridValue ==1 %% if  the selected Channel is "Grid"
            plotArray = chanArray;
            plotArrayStr = chanStr(chanArray);
        elseif GridValue == 2 %% if the selected Bin is "Grid"
            plotArray = binArray;
            plotArrayStr = binStr(binArray);
        elseif GridValue == 3%% if the selected ERPset is "Grid"
            plotArray = ERPsetArray;
            for Numoferpset = 1:numel(ERPsetArray)
                plotArrayStr(Numoferpset,1) = {char(ALLERPIN(ERPsetArray(Numoferpset)).erpname)};
            end
        else
            plotArray = chanArray;
            plotArrayStr = chanStr(chanArray);
        end
        plotBox = f_getrow_columnautowaveplot(plotArray);%% the first element is number of rows and the second element is the number of columns
        try
            NumrowsDef = plotBox(1);
            NumcolumnsDef = plotBox(2);
        catch
            NumrowsDef = 1;
            NumcolumnsDef = 1;
        end
        NumcolumnsChanged = gui_plotorg_waveviewer.rownum.Value;
        NumrowsChanged = gui_plotorg_waveviewer.columnnum.Value;
        allNum = NumcolumnsChanged*NumrowsChanged;
        button = 'none';
        if NumcolumnsChanged*NumrowsChanged< NumrowsDef* NumcolumnsDef
            question = ['Are you sure to set row and column numbers to be',32,num2str(NumrowsChanged),32,'and',32,num2str(NumcolumnsChanged),'?\n\n',...
                'If so, only the first',32,num2str(allNum),32,'items will be plotted.\n',...
                'If not, the default numbers of rows and columns will be used.\n'];
            BackERPLABcolor = [1 0.9 0.3];    % yellow
            title = 'My Viewer > Plot Organization > Column(s)';
            oldcolor = get(0,'DefaultUicontrolBackgroundColor');
            set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
            button = questdlg(sprintf(question), title,'Cancel','No', 'Yes','Yes');
            set(0,'DefaultUicontrolBackgroundColor',oldcolor)
        end
        if isempty(button) || strcmpi(button,'Cancel')
            return;
        end
        if strcmpi(button,'No')
            count = 0;
            for Numofrows = 1:NumrowsDef
                for Numofcolumns = 1:NumcolumnsDef
                    count = count +1;
                    if count> numel(plotArray)
                        GridinforData{Numofrows,Numofcolumns} = char('None');
                    else
                        GridinforData{Numofrows,Numofcolumns} = char(plotArrayStr(count));
                    end
                end
            end
            ERPwaviewerin.plot_org.gridlayout.data =GridinforData;
            gui_plotorg_waveviewer.rownum.Value=NumrowsDef;
            gui_plotorg_waveviewer.columnnum.Value=NumcolumnsDef;
        end
        ERPwaviewerin.plot_org.Grid = gui_plotorg_waveviewer.grid.Value;
        ERPwaviewerin.plot_org.Overlay = gui_plotorg_waveviewer.overlay.Value;
        ERPwaviewerin.plot_org.Pages = gui_plotorg_waveviewer.pages.Value;
        ERPwaviewerin.plot_org.gridlayout.op =gui_plotorg_waveviewer.layout_auto.Value;
        ERPwaviewerin.plot_org.gridlayout.rows = gui_plotorg_waveviewer.rownum.Value;
        ERPwaviewerin.plot_org.gridlayout.columns = gui_plotorg_waveviewer.columnnum.Value;
        ERPwaviewerin.plot_org.gridlayout.rowgap.GTPOP = gui_plotorg_waveviewer.rowgap_auto.Value;
        ERPwaviewerin.plot_org.gridlayout.rowgap.GTPValue = str2num(gui_plotorg_waveviewer.rowgapGTPcustom.String);
        ERPwaviewerin.plot_org.gridlayout.rowgap.OverlayOP = gui_plotorg_waveviewer.rowoverlap.Value;
        ERPwaviewerin.plot_org.gridlayout.rowgap.OverlayValue = str2num(gui_plotorg_waveviewer.rowgapoverlayedit.String);
        ERPwaviewerin.plot_org.gridlayout.columngap.GTPOP = gui_plotorg_waveviewer.columngapgtpop.Value;
        ERPwaviewerin.plot_org.gridlayout.columngap.GTPValue = str2num(gui_plotorg_waveviewer.columngapgtpcustom.String);
        ERPwaviewerin.plot_org.gridlayout.columngap.OverlayOP = gui_plotorg_waveviewer.columnoverlay.Value;
        ERPwaviewerin.plot_org.gridlayout.columngap.OverlayValue = str2num(gui_plotorg_waveviewer.columngapoverlapedit.String);
        
        assignin('base','ALLERPwaviewer',ERPwaviewerin);
        overlayIndex = estudioworkingmemory('OverlayIndex');
        if ~isempty(overlayIndex) && overlayIndex==1
            viewer_ERPDAT.count_legend  = viewer_ERPDAT.count_legend+1;
        end
        f_redrawERP_viewer_test();%%plot ERP waves
        viewer_ERPDAT.Process_messg =2;
    end

%%----------------change ORG based on the selected ERPsets-----------------
    function v_currentERP_change(~,~)
        if viewer_ERPDAT.Count_currentERP == 0
            return;
        end
        try
            ERPwaviewer_apply = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp('f_ERP_plotorg_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        
        %%Force Grid, Overlay, and Pages to be 1,2,3, respectively if "Same as ERPLAB"
        PlotOrg_ERPLAB= estudioworkingmemory('PlotOrg_ERPLAB');%% "Same as ERPLAB"? See  "ERPsets" panel of ERP Wave Viewer
        if PlotOrg_ERPLAB==1
            gui_plotorg_waveviewer.grid.Value=1;
            gui_plotorg_waveviewer.overlay.Value =2;
            gui_plotorg_waveviewer.pages.Value =3;
        end
        estudioworkingmemory('PlotOrg_ERPLAB',0);
        
        indexerp =  ERPwaviewer_apply.SelectERPIdx;
        ALLERP = ERPwaviewer_apply.ALLERP;
        for Numofselectederp = 1:numel(indexerp)
            SrateNum_mp(Numofselectederp,1)   =  ALLERP(indexerp(Numofselectederp)).srate;
        end
        if numel(unique(SrateNum_mp))>1
            gui_plotorg_waveviewer.grid.Value=1;
            gui_plotorg_waveviewer.overlay.Value =2;
            gui_plotorg_waveviewer.pages.Value =3;
            ERPwaviewer_apply.plot_org.Grid = gui_plotorg_waveviewer.grid.Value;
            ERPwaviewer_apply.plot_org.Overlay = gui_plotorg_waveviewer.overlay.Value;
            ERPwaviewer_apply.plot_org.Pages = gui_plotorg_waveviewer.pages.Value;
        end
        binArray = ERPwaviewer_apply.bin;
        chanArray = ERPwaviewer_apply.chan;
        ERPsetArray = ERPwaviewer_apply.SelectERPIdx;
        ALLERPIN = ERPwaviewer_apply.ALLERP;
        if max(ERPsetArray) >length(ALLERPIN)
            ERPsetArray =length(ALLERPIN);
            ERPwaviewer_apply.SelectERPIdx = ERPsetArray;
        end
        GridValue = gui_plotorg_waveviewer.grid.Value;
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERPIN,ERPsetArray);
        if numel(binArray)> length(binStr)
            binArray = [1:length(binStr)];
            ERPwaviewer_apply.bin = binArray;
        end
        if numel(chanArray)> length(chanStr)
           chanArray = [1:length(chanStr)]; 
           ERPwaviewer_apply.chan = chanArray;
        end
            
        if GridValue ==1 || GridValue==2 || GridValue ==3
            if GridValue ==1 %% if  the selected Channel is "Grid"
                plotArray = chanArray;
                plotArrayStr = chanStr(chanArray);
                plotArrayFormt = plotArrayStr;
                plotArrayFormt(numel(plotArray)+1) = {'None'};
            elseif GridValue == 2 %% if the selected Bin is "Grid"
                plotArray = binArray;
                plotArrayStr = binStr(binArray);
                plotArrayFormt = plotArrayStr;
                plotArrayFormt(numel(plotArray)+1) = {'None'};
            elseif GridValue == 3%% if the selected ERPset is "Grid"
                plotArray = ERPsetArray;
                for Numoferpset = 1:numel(ERPsetArray)
                    plotArrayStr(Numoferpset,1) = {char(ALLERPIN(ERPsetArray(Numoferpset)).erpname)};
                end
                plotArrayFormt = plotArrayStr;
                plotArrayFormt(numel(plotArray)+1) = {'None'};
            else
                plotArray = chanArray;
                plotArrayStr = chanStr(chanArray);
                plotArrayFormt = plotArrayStr;
                plotArrayFormt(numel(chanArray)+1) = {'None'};
            end
            plotBox = f_getrow_columnautowaveplot(plotArray);%% the first element is number of rows and the second element is the number of columns
            if gui_plotorg_waveviewer.layout_auto.Value
                try
                    gui_plotorg_waveviewer.rownum.Value = plotBox(1);
                    gui_plotorg_waveviewer.columnnum.Value = plotBox(2);
                catch
                    return;
                end
            end
            Numrows = gui_plotorg_waveviewer.rownum.Value;
            Numcolumns=gui_plotorg_waveviewer.columnnum.Value;
            count = 0;
            for Numofrows = 1:Numrows
                for Numofcolumns = 1:Numcolumns
                    count = count +1;
                    if count> numel(plotArray)
                        GridinforData{Numofrows,Numofcolumns} = char('None');
                    else
                        GridinforData{Numofrows,Numofcolumns} = char(plotArrayStr(count));
                    end
                end
            end
            if gui_plotorg_waveviewer.layout_auto.Value
                ERPwaviewer_apply.plot_org.Grid = gui_plotorg_waveviewer.grid.Value;
                ERPwaviewer_apply.plot_org.gridlayout.data =GridinforData;
                ERPwaviewer_apply.plot_org.gridlayout.rows = gui_plotorg_waveviewer.rownum.Value;
                ERPwaviewer_apply.plot_org.gridlayout.columns =gui_plotorg_waveviewer.columnnum.Value;
                ERPwaviewer_apply.plot_org.gridlayout.columFormat = plotArrayFormt';
                ERPwaviewer_apply.plot_org.gridlayout.columFormatOrig = plotArrayFormt';
            else
                ERPwaviewer_apply.plot_org.gridlayout.columFormatOrig = plotArrayFormt;
                plotArrayFormtOld =  ERPwaviewer_apply.plot_org.gridlayout.columFormat;
                for ii = 1:length(plotArrayFormt)-1
                    if ii< length(plotArrayFormtOld)
                        try
                            plotArrayFormtNew{ii}  = char(plotArrayFormtOld{ii});
                        catch
                            plotArrayFormtNew{ii}  = char(plotArrayFormt{ii});
                        end
                    else
                        plotArrayFormtNew{ii}  = char(plotArrayFormt{ii});
                    end
                end
                plotArrayFormtNew{length(plotArrayFormt)} = {'None'};
                ERPwaviewer_apply.plot_org.gridlayout.columFormat = plotArrayFormtNew';
            end
            assignin('base','ALLERPwaviewer',ERPwaviewer_apply);
        end
        
    end


%%-------------modify this panel based on updated parameters---------------
    function count_loadproper_change(~,~)
        if viewer_ERPDAT.count_loadproper ==0
            return;
        end
        try
            ERPwaviewer_apply = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp('f_ERP_plotorg_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        gui_plotorg_waveviewer.grid.Value = ERPwaviewer_apply.plot_org.Grid;
        gui_plotorg_waveviewer.overlay.Value = ERPwaviewer_apply.plot_org.Overlay;
        gui_plotorg_waveviewer.pages.Value =  ERPwaviewer_apply.plot_org.Pages;
        AutoValue =  ERPwaviewer_apply.plot_org.gridlayout.op;
        if AutoValue ==1
            Enable = 'off';
            gui_plotorg_waveviewer.layout_auto.Value =1;
            gui_plotorg_waveviewer.layout_custom.Value = 0;
        else
            Enable = 'on';
            gui_plotorg_waveviewer.layout_auto.Value =0;
            gui_plotorg_waveviewer.layout_custom.Value = 1;
        end
        gui_plotorg_waveviewer.layout_auto.Enable ='on';
        gui_plotorg_waveviewer.layout_custom.Enable ='on';
        gui_plotorg_waveviewer.layout_custom_edit.Enable = Enable;
        gui_plotorg_waveviewer.rownum.Enable = Enable;
        gui_plotorg_waveviewer.columnnum.Enable = Enable;
        gui_plotorg_waveviewer.rowgap_auto.Enable = Enable;
        gui_plotorg_waveviewer.rowgapGTPcustom.Enable = Enable;
        gui_plotorg_waveviewer.rowoverlap.Enable = Enable;
        gui_plotorg_waveviewer.rowgapoverlayedit.Enable = Enable;
        gui_plotorg_waveviewer.columngapgtpop.Enable = Enable;
        gui_plotorg_waveviewer.columngapgtpcustom.Enable = Enable;
        gui_plotorg_waveviewer.columnoverlay.Enable = Enable;
        gui_plotorg_waveviewer.columngapoverlapedit.Enable = Enable;
        
        RowNum = ERPwaviewer_apply.plot_org.gridlayout.rows;
        columNum = ERPwaviewer_apply.plot_org.gridlayout.columns;
        gui_plotorg_waveviewer.rownum.Value = RowNum;
        gui_plotorg_waveviewer.columnnum.Value = columNum;
        
        %%Row gap and overlay
        rowgapValue =  ERPwaviewer_apply.plot_org.gridlayout.rowgap.GTPOP;
        rowgapCustom = ERPwaviewer_apply.plot_org.gridlayout.rowgap.GTPValue;
        rowoverlayValue = ERPwaviewer_apply.plot_org.gridlayout.rowgap.OverlayOP;
        rowoverlayCustom = ERPwaviewer_apply.plot_org.gridlayout.rowgap.OverlayValue;
        gui_plotorg_waveviewer.rowgap_auto.Value = rowgapValue;
        gui_plotorg_waveviewer.rowgapGTPcustom.String = num2str(rowgapCustom);
        gui_plotorg_waveviewer.rowoverlap.Value = rowoverlayValue;
        gui_plotorg_waveviewer.rowgapoverlayedit.String = num2str(rowoverlayCustom);
        if AutoValue==0 %% if Grid layout is Custom
            gui_plotorg_waveviewer.rowgap_auto.Enable = 'on';
            gui_plotorg_waveviewer.rowoverlap.Enable = 'on';
            if rowgapValue ==1
                gui_plotorg_waveviewer.rowgapGTPcustom.Enable = 'on';
                gui_plotorg_waveviewer.rowgapoverlayedit.Enable = 'off';
            end
            if rowoverlayValue ==1
                gui_plotorg_waveviewer.rowgapGTPcustom.Enable = 'off';
                gui_plotorg_waveviewer.rowgapoverlayedit.Enable = 'on';
            end
        end
        
        %%column gap and oveerlay
        columnGapValue =  ERPwaviewer_apply.plot_org.gridlayout.columngap.GTPOP;
        columnGapcustom = ERPwaviewer_apply.plot_org.gridlayout.columngap.GTPValue;
        columnoverlayValue = ERPwaviewer_apply.plot_org.gridlayout.columngap.OverlayOP;
        columnoverlaycustom =  ERPwaviewer_apply.plot_org.gridlayout.columngap.OverlayValue;
        gui_plotorg_waveviewer.columngapgtpop.Value = columnGapValue;
        gui_plotorg_waveviewer.columngapgtpcustom.String = num2str(columnGapcustom);
        gui_plotorg_waveviewer.columnoverlay.Value = columnoverlayValue;
        gui_plotorg_waveviewer.columngapoverlapedit.String = num2str(columnoverlaycustom);
        if AutoValue==0
            gui_plotorg_waveviewer.columngapgtpop.Enable = 'on';
            gui_plotorg_waveviewer.columnoverlay.Enable = 'on';
            if columnGapValue==1
                gui_plotorg_waveviewer.columngapgtpcustom.Enable = 'on';
                gui_plotorg_waveviewer.columngapoverlapedit.Enable = 'off';
            end
            if columnoverlayValue==1
                gui_plotorg_waveviewer.columngapgtpcustom.Enable = 'off';
                gui_plotorg_waveviewer.columngapoverlapedit.Enable = 'on';
            end
        end
    end

end