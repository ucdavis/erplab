%%This function is to plot the panel for "plot organization".

% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022


function f_ERP_plotorglayout_waveviewer_GUI(varargin)

global viewer_ERPDAT;
addlistener(viewer_ERPDAT,'count_loadproper_change',@count_loadproper_change);

gui_plotorglayout_waveviewer = struct();

%-----------------------------Name the title----------------------------------------------
% global box_erpwave_viewer_plotorg;
[version reldate,ColorBdef,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;

try
    [version reldate] = geterplabstudioversion;
    erplabstudiover = version;
catch
    erplabstudiover = '??';
end

currvers  = ['ERPLAB Studio ' erplabstudiover,'- Grid Layout of Plot Organization '];
box_erpwave_viewer_plotorglayout = figure( 'Name', currvers, ...
    'NumberTitle', 'off', ...
    'MenuBar', 'none', ...
    'Toolbar', 'none', ...
    'HandleVisibility', 'off', 'tag', 'rollover');

%-----------------------------Draw the panel-------------------------------------
drawui_plot_orglayout();
% varargout{1} = box_erpwave_viewer_plotorg;

    function drawui_plot_orglayout()
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        try
            ALLERPwaviewer = evalin('base','ALLERPwaviewer');
            ERPwaviewerin = ALLERPwaviewer;
        catch
            beep;
            disp('f_ERP_plotorglayout_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        gui_plotorglayout_waveviewer.DataSelBox = uiextras.VBox('Parent', box_erpwave_viewer_plotorglayout,'BackgroundColor',ColorBviewer_def);
        
        %%----------------------Setting for grid layout--------------------
        gridlayoutValue = 1;
        GridValue = 1;
        try
            GridValue= ERPwaviewerin.plot_org.Grid;
        catch
            GridValue =1;
        end
        if isempty(GridValue) || numel(GridValue)~=1 || GridValue<0 || GridValue>3
            GridValue =1;
        end
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
        
        try
            Numrows = ERPwaviewerin.plot_org.gridlayout.rows;
            Numcolumns = ERPwaviewerin.plot_org.gridlayout.columns;
        catch
            Numrows = Numrows;
            Numcolumns = Numcolumns;
        end
        
        %%-------------------------Grid information------------------------
        count = 0;
        for Numofrows = 1:Numrows
            for Numofcolumns = 1:Numcolumns
                count = count +1;
                if count> numel(plotArray)
                    GridinforDatadef{Numofrows,Numofcolumns} = char('None');
                else
                    GridinforDatadef{Numofrows,Numofcolumns} = char(plotArrayStr(count));
                end
            end
        end
        try
            GridinforData =  ERPwaviewerin.plot_org.gridlayout.data;
            if size(GridinforData,1)~= Numrows || size(GridinforData,2)~= Numcolumns
                GridinforData = GridinforDatadef;
            end
        catch
            GridinforData =   GridinforDatadef;
        end
        
        gui_plotorglayout_waveviewer.layoutinfortitle = uiextras.HBox('Parent', gui_plotorglayout_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        gui_plotorglayout_waveviewer.layoutinfor_table = uitable(gui_plotorglayout_waveviewer.layoutinfortitle);
        tablePosition = gui_plotorglayout_waveviewer.layoutinfor_table.Position;
        gui_plotorglayout_waveviewer.layoutinfor_table.BackgroundColor = [1 1 1; 1 1 1];
        gui_plotorglayout_waveviewer.layoutinfor_table.Data = GridinforData;
        columFormatOld = ERPwaviewerin.plot_org.gridlayout.columFormat;
        if length(columFormatOld) ==length(plotArrayFormt)
            plotArrayFormt = columFormatOld';
        end
        for Numofcolumns = 1:Numcolumns
            if size(plotArrayFormt,1) > size(plotArrayFormt,2)
                columFormat{Numofcolumns} = plotArrayFormt';
            else
                columFormat{Numofcolumns} = plotArrayFormt;
            end
            ColumnEditable(Numofcolumns) =1;
            ColumnName{1,Numofcolumns} = char(['C',num2str(Numofcolumns)]);
            ColumnWidth{Numofcolumns} =tablePosition(3)/(Numcolumns+0.2);
        end
        for Numofrows = 1:Numrows
            RowName{1,Numofrows} = char(['R',num2str(Numofrows)]);
        end
        
        gui_plotorglayout_waveviewer.layoutinfor_table.ColumnFormat = columFormat;
        gui_plotorglayout_waveviewer.layoutinfor_table.ColumnEditable = logical(ColumnEditable);
        gui_plotorglayout_waveviewer.layoutinfor_table.ColumnName = ColumnName;
        gui_plotorglayout_waveviewer.layoutinfor_table.RowName= RowName;
        if Numcolumns <20
            gui_plotorglayout_waveviewer.layoutinfor_table.ColumnWidth = ColumnWidth;
        end
        gui_plotorglayout_waveviewer.layoutinfor_table.FontSize = 12;
        gui_plotorglayout_waveviewer.layoutinfor_table.CellEditCallback  = {@layout_customtable};
        ERPwaviewerin.plot_org.gridlayout.data = gui_plotorglayout_waveviewer.layoutinfor_table.Data;
        ERPwaviewerin.plot_org.gridlayout.columFormat = columFormat{1};
        
        %%---------------help and apply the changed parameters-------------
        gui_plotorglayout_waveviewer.help_run_title = uiextras.HBox('Parent', gui_plotorglayout_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uiextras.Empty('Parent',   gui_plotorglayout_waveviewer.help_run_title);
        uicontrol('Style','pushbutton','Parent',  gui_plotorglayout_waveviewer.help_run_title,'String','Edit',...
            'callback',@plotorg_edit,'FontSize',12,'BackgroundColor',[1 1 1]); %,'HorizontalAlignment','left'
        % %         uiextras.Empty('Parent',   gui_plotorglayout_waveviewer.help_run_title );
        uiextras.Empty('Parent',   gui_plotorglayout_waveviewer.help_run_title);
        gui_plotorglayout_waveviewer.layout_custom_save = uicontrol('Style','pushbutton','Parent', gui_plotorglayout_waveviewer.help_run_title,'String','Cancel',...
            'callback',@layout_cancel,'FontSize',12,'BackgroundColor',[1 1 1]); %
        uiextras.Empty('Parent',   gui_plotorglayout_waveviewer.help_run_title);
        uicontrol('Style','pushbutton','Parent',  gui_plotorglayout_waveviewer.help_run_title,'String','Apply',...
            'callback',@plotorg_apply,'FontSize',12,'BackgroundColor',[1 1 1]); %,'HorizontalAlignment','left'
        uiextras.Empty('Parent', gui_plotorglayout_waveviewer.help_run_title);
        set(gui_plotorglayout_waveviewer.help_run_title,'Sizes',[100 60 60 60 60 60 100]);
        set(gui_plotorglayout_waveviewer.DataSelBox,'Sizes',[-1 30]);
        ALLERPwaviewer=ERPwaviewerin;
        assignin('base','ALLERPwaviewer',ALLERPwaviewer);
    end

%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%
    function layout_customtable(Str,~)
        TableDataDf = Str.Data;
        [NumRows,NumColumns] = size(TableDataDf);
        columFormat = gui_plotorglayout_waveviewer.layoutinfor_table.ColumnFormat{1};
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
    end

%%-------------edit the plot array-----------------------------
    function plotorg_edit(~,~)
        plotArrayFormt = gui_plotorglayout_waveviewer.layoutinfor_table.ColumnFormat{1};
        [Numrows,Numcolumns]= size(plotArrayFormt);
        
        if Numrows ==1 && Numcolumns>=2
            for Numofcolumns = 1:Numcolumns-1
                plotArrayFormtin{Numofcolumns,1} =   char(plotArrayFormt{Numofcolumns});
            end
        elseif Numrows >=2 && Numcolumns==1
            for Numofrows = 1:Numrows-1
                plotArrayFormtin{Numofrows,1} =   char(plotArrayFormt{Numofrows});
            end
        else
            return;
        end
        try
            ALLERPwaviewer = evalin('base','ALLERPwaviewer');
            ERPwaviewerin = ALLERPwaviewer;
        catch
            beep;
            disp('f_ERP_plotorglayout_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        try
            plotArrayFormtOld = ERPwaviewerin.plot_org.gridlayout.columFormatOrig;
        catch
            plotArrayFormtOld = plotArrayFormt;
        end
        
        for Numofplot = 1:length(plotArrayFormtOld)-1
            plotArrayFormtOldRo{Numofplot,1} = char(plotArrayFormtOld{Numofplot});
        end
        plotArrayFormtOld = plotArrayFormtOldRo;
        PLOTORG(1) =    ERPwaviewerin.plot_org.Grid;
        PLOTORG(2) = ERPwaviewerin.plot_org.Overlay ;
        PLOTORG(3) = ERPwaviewerin.plot_org.Pages;
        changedoutput = editlayoutstringGUI(plotArrayFormtOld,plotArrayFormtin,PLOTORG);
        if isempty(changedoutput)
            return;
        end
        try
            for Numofrows = 1:size(changedoutput)
                changeStr{Numofrows} = char(changedoutput{Numofrows,2});
            end
        catch
            for Numofrows = 1:size(changedoutput)
                changeStr{Numofrows} = char(changedoutput{Numofrows,1});
            end
        end
        if ~isempty(changeStr)
            columFormat =  gui_plotorglayout_waveviewer.layoutinfor_table.ColumnFormat;
            columFormatOld = columFormat{1};
            GridinforDataOld = gui_plotorglayout_waveviewer.layoutinfor_table.Data;
            [Numrows,Numcolumns] = size(GridinforDataOld);
            for Numofrow = 1:Numrows
                for Numofcolumn = 1:Numcolumns
                    SingleStr =  char(GridinforDataOld{Numofrow,Numofcolumn});
                    [C,IA] = ismember_bc2(SingleStr,columFormatOld);
                    if C ==1
                        if IA < length(columFormatOld)
                            try
                                GridinforDataOld{Numofrow,Numofcolumn} = char(changeStr{IA});
                            catch
                                GridinforDataOld{Numofrow,Numofcolumn} = char('');
                            end
                        elseif IA == length(columFormatOld)
                            GridinforDataOld{Numofrow,Numofcolumn}  = char('None');
                        end
                    else
                        GridinforDataOld{Numofrow,Numofcolumn}  = char('None');
                    end
                end
            end
            gui_plotorglayout_waveviewer.layoutinfor_table.Data = GridinforDataOld;
            changeStr{length(changeStr)+1} = char('None');
            for Numofcolumns = 1:Numcolumns
                gui_plotorglayout_waveviewer.layoutinfor_table.ColumnFormat{Numofcolumns} = changeStr;
            end
        end
    end

%%-------------------------------Cancel------------------------------------
    function layout_cancel(~,~)
        try
            close(box_erpwave_viewer_plotorglayout);
            disp('You selected Cancel.');
        catch
            return;
        end
    end

%%----------------------Apply the changed parameters-----------------------
    function plotorg_apply(~,~)
        TableDataDf = gui_plotorglayout_waveviewer.layoutinfor_table.Data;
        [NumRows,NumColumns] = size(TableDataDf);
        columFormat = gui_plotorglayout_waveviewer.layoutinfor_table.ColumnFormat{1};
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
            ALLERPwaviewer = evalin('base','ALLERPwaviewer');
            ERPwaviewerin = ALLERPwaviewer;
        catch
            beep;
            disp('f_ERP_plotorglayout_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        columFormat = gui_plotorglayout_waveviewer.layoutinfor_table.ColumnFormat;
        ERPwaviewerin.plot_org.gridlayout.columFormat = columFormat{1};
        ERPwaviewerin.plot_org.gridlayout.data =gui_plotorglayout_waveviewer.layoutinfor_table.Data;
        
        ALLERPwaviewerApply=ERPwaviewerin;
        assignin('base','ALLERPwaviewer',ALLERPwaviewerApply);
        try
            close(box_erpwave_viewer_plotorglayout);
        catch
            return;
        end
        f_redrawERP_viewer_test();
        viewer_ERPDAT.Process_messg =2;
        
    end
end