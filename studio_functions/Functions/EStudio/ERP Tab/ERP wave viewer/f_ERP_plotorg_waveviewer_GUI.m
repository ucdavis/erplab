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
addlistener(viewer_ERPDAT,'loadproper_change',@loadproper_change);
addlistener(viewer_ERPDAT,'count_twopanels_change',@count_twopanels_change);
addlistener(viewer_ERPDAT,'Reset_Waviewer_panel_change',@Reset_Waviewer_panel_change);

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
try
    FonsizeDefault = varargin{2};
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
    FonsizeDefault = f_get_default_fontsize();
end

drawui_plot_org(FonsizeDefault);
varargout{1} = box_erpwave_viewer_plotorg;

    function drawui_plot_org(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        try
            ERPwaviewerin = evalin('base','ALLERPwaviewer');
            ALLERP = ERPwaviewerin.ALLERP;
            indexerp =  ERPwaviewerin.SelectERPIdx;
        catch
            beep;
            disp('f_ERP_plotorg_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        
        for Numofselectederp = 1:numel(indexerp)
            SrateNum_mp(Numofselectederp,1)   =  ALLERP(indexerp(Numofselectederp)).srate;
        end
        
        MERPWaveViewer_plotorg= estudioworkingmemory('MERPWaveViewer_plotorg');%%call the memery for this panel
        try
            plotorg_Index = MERPWaveViewer_plotorg{1};
        catch
            plotorg_Index=1;
            MERPWaveViewer_plotorg{1}=1;
        end
        if isempty(plotorg_Index) || plotorg_Index<=0 || plotorg_Index>6
            plotorg_Index=1;
            MERPWaveViewer_plotorg{1}=1;
        end
        
        if numel(unique(SrateNum_mp))~=1  && (plotorg_Index~=1 && plotorg_Index~=3)
            MessageViewer= char(strcat('Plot Organization - We will use "Channels,Bins, ERPsets" because Sampling rate varies across the selected ERPsets'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =4;
            plotorg_Index=1;
            MERPWaveViewer_plotorg{1}=1;
        end
        if plotorg_Index==1
            plotorg_Value = [1,0,0,0,0,0];
        elseif plotorg_Index==2
            plotorg_Value = [0,1,0,0,0,0];
        elseif plotorg_Index==3
            plotorg_Value = [0,0,1,0,0,0];
        elseif plotorg_Index==4
            plotorg_Value = [0,0,0,1,0,0];
        elseif plotorg_Index==5
            plotorg_Value = [0,0,0,0,1,0];
        elseif plotorg_Index==6
            plotorg_Value = [0,0,0,0,0,1];
        end
        gui_plotorg_waveviewer.DataSelBox = uiextras.VBox('Parent', box_erpwave_viewer_plotorg,'BackgroundColor',ColorBviewer_def);
        %%--------------------grind overlay and pages----------------------
        gui_plotorg_waveviewer.DataSelGrid = uiextras.Grid('Parent', gui_plotorg_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        % First column:
        uiextras.Empty('Parent',gui_plotorg_waveviewer.DataSelGrid);
        gui_plotorg_waveviewer.plotorg_c1 =  uicontrol('Style','radiobutton','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','',...
            'callback',@plotorg_c1,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',plotorg_Value(1)); % 1B
        gui_plotorg_waveviewer.plotorg_c1.KeyPressFcn = @plotorg_presskey;
        gui_plotorg_waveviewer.plotorg_c2 = uicontrol('Style','radiobutton','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','',...
            'callback',@plotorg_c2,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',plotorg_Value(2)); % 1B
        gui_plotorg_waveviewer.plotorg_c2.KeyPressFcn = @plotorg_presskey;
        gui_plotorg_waveviewer.plotorg_c3 = uicontrol('Style','radiobutton','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','',...
            'callback',@plotorg_c3,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',plotorg_Value(3)); % 1B
        gui_plotorg_waveviewer.plotorg_c3.KeyPressFcn = @plotorg_presskey;
        gui_plotorg_waveviewer.plotorg_c4 =  uicontrol('Style','radiobutton','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','',...
            'callback',@plotorg_c4,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',plotorg_Value(4)); % 1B
        gui_plotorg_waveviewer.plotorg_c4.KeyPressFcn = @plotorg_presskey;
        gui_plotorg_waveviewer.plotorg_c5 = uicontrol('Style','radiobutton','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','',...
            'callback',@plotorg_c5,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',plotorg_Value(5)); % 1B
        gui_plotorg_waveviewer.plotorg_c5.KeyPressFcn = @plotorg_presskey;
        gui_plotorg_waveviewer.plotorg_c6 = uicontrol('Style','radiobutton','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','',...
            'callback',@plotorg_c6,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',plotorg_Value(6)); % 1B
        gui_plotorg_waveviewer.plotorg_c6.KeyPressFcn = @plotorg_presskey;
        % Second column:
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','Grid',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'FontWeight','bold'); % 2A
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','Channels',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); % 2B
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','Channels',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); % 2C
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','Bins',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); % 2D
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','Bins',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); % 2E
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','ERPsets',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); % 2F
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','ERPsets',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); % 2G
        
        % Third column:
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','Overlay',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'FontWeight','bold'); % 3A
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','Bins',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); % 3B
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','ERPsets',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); % 3C
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','Channels',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); % 3D
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','ERPsets',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); % 3E
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','Chans',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); % 3F
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','Bins',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); % 3G
        
        % Fourth column:
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','Pages',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'FontWeight','bold'); % 3A
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','ERPsets',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); % 3B
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','Bins',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); % 3C
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','ERPsets',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); % 3D
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','Channels',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); % 3E
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','Bins',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); % 3F
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.DataSelGrid,'String','Channels',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); % 3G
        set(gui_plotorg_waveviewer.DataSelGrid, 'ColumnSizes',[30 70 70 70],'RowSizes',[20 20 20 20 20 20 20]);
        if gui_plotorg_waveviewer.plotorg_c1.Value ==1
            GridValue=1; OverlayValue = 2; PageValue =3;
        elseif  gui_plotorg_waveviewer.plotorg_c2.Value ==1
            GridValue=1; OverlayValue = 3; PageValue =2;
        elseif  gui_plotorg_waveviewer.plotorg_c3.Value ==1
            GridValue=2; OverlayValue = 1; PageValue =3;
        elseif  gui_plotorg_waveviewer.plotorg_c4.Value ==1
            GridValue=2; OverlayValue = 3; PageValue =1;
        elseif gui_plotorg_waveviewer.plotorg_c5.Value ==1
            GridValue=3; OverlayValue = 1; PageValue =2;
        elseif gui_plotorg_waveviewer.plotorg_c6.Value ==1
            GridValue=3; OverlayValue = 2; PageValue =1;
        end
        ERPwaviewerin.plot_org.Grid = GridValue;
        ERPwaviewerin.plot_org.Overlay = OverlayValue;
        ERPwaviewerin.plot_org.Pages =PageValue;
        gui_plotorg_waveviewer.LayoutFlag = plotorg_Value;
        
        %%----------------------Setting for grid layout-------------------
        gui_plotorg_waveviewer.layout_title = uiextras.HBox('Parent', gui_plotorg_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        try
            gridlayoutValue=  MERPWaveViewer_plotorg{2};
        catch
            gridlayoutValue = 1;
            MERPWaveViewer_plotorg{2}=1;
        end
        if isempty(gridlayoutValue) || numel(gridlayoutValue)~=1 || (gridlayoutValue~=0 &&gridlayoutValue~=1)
            gridlayoutValue = 1;
            MERPWaveViewer_plotorg{2}=1;
        end
        % First column:
        gui_plotorg_waveviewer.layout=  uicontrol('Style','text','Parent', gui_plotorg_waveviewer.layout_title,'String','Grid Layout: ',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'FontWeight','bold'); %
        set(gui_plotorg_waveviewer.layout,'HorizontalAlignment','left');
        gui_plotorg_waveviewer.layout_auto = uicontrol('Style','radiobutton','Parent', gui_plotorg_waveviewer.layout_title,'String','Auto',...
            'callback',@layout_auto,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',gridlayoutValue); %
        gui_plotorg_waveviewer.layout_auto.KeyPressFcn = @plotorg_presskey;
        gui_plotorg_waveviewer.layout_custom = uicontrol('Style','radiobutton','Parent', gui_plotorg_waveviewer.layout_title,'String','Custom',...
            'callback',@layout_custom,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',~gridlayoutValue); %
        gui_plotorg_waveviewer.layout_custom.KeyPressFcn = @plotorg_presskey;
        set(gui_plotorg_waveviewer.layout_title, 'Sizes',[90 60 70]);
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
        elseif GridValue == 2 %% if the selected Bin is "Grid"
            plotArray = binArray;
            plotArrayStr = binStr(binArray);
            plotArrayFormt = plotArrayStr;
        elseif GridValue == 3%% if the selected ERPset is "Grid"
            plotArray = ERPsetArray;
            plotArrayStr = cell(numel(ERPsetArray),1);
            for Numoferpset = 1:numel(ERPsetArray)
                plotArrayStr(Numoferpset,1) = {char(ALLERPIN(ERPsetArray(Numoferpset)).erpname)};
            end
            plotArrayFormt = plotArrayStr;
            
        else
            plotArray = chanArray;
            plotArrayStr = chanStr(chanArray);
            plotArrayFormt = plotArrayStr;
        end
        
        
        plotBoxdef = f_getrow_columnautowaveplot(plotArray);%% the first element is number of rows and the second element is the number of columns
        try
            plotBox= MERPWaveViewer_plotorg{3};
        catch
            plotBox = plotBoxdef;
            MERPWaveViewer_plotorg{3}=plotBox;
        end
        if isempty(plotBox) || numel(plotBox)~=2 || min(plotBox(:))<1 || max(plotBox(:))>256
            plotBox = plotBoxdef;
            MERPWaveViewer_plotorg{3}=plotBox;
        end
        try
            Numrows = plotBox(1);
            Numcolumns = plotBox(2);
        catch
            Numrows = 1;
            Numcolumns = 1;
            MERPWaveViewer_plotorg{3}=[1 1];
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
            'FontSize',FonsizeDefault-2,'BackgroundColor',ColorBviewer_def); % 1B
        gui_plotorg_waveviewer.rownum = uicontrol('Style','popupmenu','Parent', gui_plotorg_waveviewer.row_column_title,'String',rowcolumnString,...
            'callback',@plotorg_rownum,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Value',Numrows,'Enable',rowcolumnEnable); % 1B
        gui_plotorg_waveviewer.rownum.KeyPressFcn = @plotorg_presskey;
        uicontrol('Style','text','Parent', gui_plotorg_waveviewer.row_column_title,'String','Column(s)',...
            'FontSize',FonsizeDefault-2,'BackgroundColor',ColorBviewer_def); % 1B
        gui_plotorg_waveviewer.columnnum = uicontrol('Style','popupmenu','Parent', gui_plotorg_waveviewer.row_column_title,'String',rowcolumnString,...
            'callback',@plotorg_columnnum,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Value',Numcolumns,'Enable',rowcolumnEnable); % 1B
        gui_plotorg_waveviewer.columnnum.KeyPressFcn = @plotorg_presskey;
        set(gui_plotorg_waveviewer.row_column_title, 'Sizes',[20 35 65 55 65]);
        ERPwaviewerin.plot_org.gridlayout.rows = gui_plotorg_waveviewer.rownum.Value;
        ERPwaviewerin.plot_org.gridlayout.columns =gui_plotorg_waveviewer.columnnum.Value;
        
        %%-------------------------Grid information------------------------
        count = 0;
        for Numofrows = 1:Numrows
            for Numofcolumns = 1:Numcolumns
                count = count +1;
                if count> numel(plotArray)
                    GridinforData{Numofrows,Numofcolumns} = '';
                else
                    GridinforData{Numofrows,Numofcolumns} = char(plotArrayStr(count));
                end
            end
        end
        ERPwaviewerin.plot_org.gridlayout.data =GridinforData;
        columFormat = plotArrayFormt';
        ERPwaviewerin.plot_org.gridlayout.columFormat = columFormat;
        %         ERPwaviewerin.plot_org.gridlayout.columFormatOrig = columFormat;
        
        %%---------------------Gap between rows----------------------------
        try
            rowgapgtpValue= MERPWaveViewer_plotorg{4} ;
        catch
            rowgapgtpValue = 1;
            MERPWaveViewer_plotorg{4}=1;
        end
        if isempty(rowgapgtpValue) || numel(rowgapgtpValue)~=1 || (rowgapgtpValue~=1 && rowgapgtpValue~=0)
            MERPWaveViewer_plotorg{4}=1;
            rowgapgtpValue = 1;
        end
        try
            RowGTPStr= MERPWaveViewer_plotorg{5};
        catch
            RowGTPStr = 10;
            MERPWaveViewer_plotorg{5}=10;
        end
        if rowgapgtpValue==1
            RowgapgtpEnable = 'on';
            RowgapOVERLAPEnable = 'off';
            RowGTPStr = 10;
            MERPWaveViewer_plotorg{5}=10;
        else
            RowgapgtpEnable = 'off';
            RowgapOVERLAPEnable = 'on';
        end
        if gridlayoutValue==1
            rowcolumnEnable = 'off';
            RowGTPStr = 10;
            MERPWaveViewer_plotorg{5}=10;
            rowgapgtpValue = 1;
            MERPWaveViewer_plotorg{4}=1;
            RowgapgtpEnable = 'off';
        else
            rowcolumnEnable = 'on';
        end
        if isempty(RowGTPStr)|| numel(RowGTPStr)~=1 ||RowGTPStr<=0
            RowGTPStr = 10;
            MERPWaveViewer_plotorg{5}=10;
        end
        gui_plotorg_waveviewer.rowgap_title = uiextras.HBox('Parent', gui_plotorg_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        gui_plotorg_waveviewer.rowgap = uicontrol('Style','text','Parent', gui_plotorg_waveviewer.rowgap_title,'String','Row:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); %
        set(gui_plotorg_waveviewer.rowgap,'HorizontalAlignment','left');
        gui_plotorg_waveviewer.rowgap_auto = uicontrol('Style','radiobutton','Parent', gui_plotorg_waveviewer.rowgap_title,'String','Gap (%)',...
            'callback',@rowgapgtpauto,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',rowgapgtpValue,'Enable',rowcolumnEnable); %
        gui_plotorg_waveviewer.rowgap_auto.KeyPressFcn = @plotorg_presskey;
        gui_plotorg_waveviewer.rowgapGTPcustom = uicontrol('Style','edit','Parent', gui_plotorg_waveviewer.rowgap_title,'String',num2str(RowGTPStr),...
            'callback',@rowgapgtpcustom,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable',RowgapgtpEnable); %
        gui_plotorg_waveviewer.rowgapGTPcustom.KeyPressFcn = @plotorg_presskey;
        if gui_plotorg_waveviewer.layout_auto.Value ==1
            gui_plotorg_waveviewer.rowgapGTPcustom.String = '10';
        end
        set(gui_plotorg_waveviewer.rowgap_title, 'Sizes',[60 90 85]);
        ERPwaviewerin.plot_org.gridlayout.rowgap.GTPOP = gui_plotorg_waveviewer.rowgap_auto.Value;
        ERPwaviewerin.plot_org.gridlayout.rowgap.GTPValue = str2num(gui_plotorg_waveviewer.rowgapGTPcustom.String);
        
        try
            RowoverlayStr= MERPWaveViewer_plotorg{6};
        catch
            RowoverlayStr = 40;
            MERPWaveViewer_plotorg{6}=40;
        end
        if isempty(RowoverlayStr) ||  numel(RowoverlayStr)~=1 || RowoverlayStr<=0 || RowoverlayStr>=100
            MERPWaveViewer_plotorg{6}=40;
            RowoverlayStr = 40;
        end
        if gridlayoutValue==1
            RowgapOVERLAPEnable = 'off';
        end
        gui_plotorg_waveviewer.rowgapcustom_title = uiextras.HBox('Parent', gui_plotorg_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uiextras.Empty('Parent',gui_plotorg_waveviewer.rowgapcustom_title);
        gui_plotorg_waveviewer.rowoverlap = uicontrol('Style','radiobutton','Parent', gui_plotorg_waveviewer.rowgapcustom_title,'String','Overlap (%)',...
            'callback',@rowoverlap, 'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Enable',rowcolumnEnable,'Value',~rowgapgtpValue); %
        gui_plotorg_waveviewer.rowoverlap.KeyPressFcn = @plotorg_presskey;
        gui_plotorg_waveviewer.rowgapoverlayedit = uicontrol('Style','edit','Parent', gui_plotorg_waveviewer.rowgapcustom_title,'String',num2str(RowoverlayStr),...
            'callback',@rowoverlapcustom,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable',RowgapOVERLAPEnable); %
        gui_plotorg_waveviewer.rowgapoverlayedit.KeyPressFcn = @plotorg_presskey;
        set(gui_plotorg_waveviewer.rowgapcustom_title, 'Sizes',[60 90  85]);
        ERPwaviewerin.plot_org.gridlayout.rowgap.OverlayOP = gui_plotorg_waveviewer.rowoverlap.Value;
        ERPwaviewerin.plot_org.gridlayout.rowgap.OverlayValue = str2num(gui_plotorg_waveviewer.rowgapoverlayedit.String);
        
        %%---------------------Gap between columns------------------------
        try
            columngapgtpValue= MERPWaveViewer_plotorg{7};
        catch
            columngapgtpValue = 1;
            MERPWaveViewer_plotorg{7}=1;
        end
        if isempty(columngapgtpValue) ||  numel(columngapgtpValue)~=1 || (columngapgtpValue~=0 && columngapgtpValue~=1)
            columngapgtpValue = 1;
            MERPWaveViewer_plotorg{7}=1;
        end
        try
            columnGTPStr = MERPWaveViewer_plotorg{8};
        catch
            columnGTPStr = 10;
            MERPWaveViewer_plotorg{8} = 10;
        end
        if isempty(columnGTPStr) || numel(columnGTPStr)~=1 || columnGTPStr<0
            columnGTPStr = 10;
            MERPWaveViewer_plotorg{8} = 10;
        end
        if columngapgtpValue==1
            columngapgtpEnable = 'on';
        else
            columngapgtpEnable = 'off';
        end
        if gridlayoutValue==1
            columngapgtpEnable = 'off';
            columnGTPStr = 10;
            MERPWaveViewer_plotorg{8} = 10;
            columngapgtpValue = 1;
            MERPWaveViewer_plotorg{7}=1;
        end
        gui_plotorg_waveviewer.columngap_title = uiextras.HBox('Parent', gui_plotorg_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        gui_plotorg_waveviewer.columngap = uicontrol('Style','text','Parent', gui_plotorg_waveviewer.columngap_title,'String','Column:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); %
        set(gui_plotorg_waveviewer.columngap,'HorizontalAlignment','left');
        gui_plotorg_waveviewer.columngapgtpop = uicontrol('Style','radiobutton','Parent', gui_plotorg_waveviewer.columngap_title,'String','Gap (%)',...
            'callback',@columngapgtpop,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',columngapgtpValue,...
            'Enable',rowcolumnEnable); %
        gui_plotorg_waveviewer.columngapgtpop.KeyPressFcn = @plotorg_presskey;
        gui_plotorg_waveviewer.columngapgtpcustom = uicontrol('Style','edit','Parent', gui_plotorg_waveviewer.columngap_title,'String',num2str(columnGTPStr),...
            'callback',@columngapGTPcustom,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable',columngapgtpEnable); %
        gui_plotorg_waveviewer.columngapgtpcustom.KeyPressFcn = @plotorg_presskey;
        if gui_plotorg_waveviewer.layout_auto.Value ==1
            gui_plotorg_waveviewer.columngapgtpcustom.String = '10';
        end
        set(gui_plotorg_waveviewer.columngap_title, 'Sizes',[60 90  85]);
        ERPwaviewerin.plot_org.gridlayout.columngap.GTPOP = gui_plotorg_waveviewer.columngapgtpop.Value;
        ERPwaviewerin.plot_org.gridlayout.columngap.GTPValue = str2num(gui_plotorg_waveviewer.columngapgtpcustom.String);
        try
            columnoverlayStr = MERPWaveViewer_plotorg{9};
        catch
            columnoverlayStr =40;
            MERPWaveViewer_plotorg{9}=40;
        end
        if isempty(columnoverlayStr) || numel(columnoverlayStr)~=1 || columnoverlayStr<=0 || columnoverlayStr>=100
            columnoverlayStr =40;
            MERPWaveViewer_plotorg{9}=40;
        end
        if gridlayoutValue==1
            columngapOVERLAPEnable = 'off';
        else
            columngapOVERLAPEnable = 'on';
        end
        
        if gui_plotorg_waveviewer.layout_auto.Value
            columngapOVERLAPEnable = 'off';
        end
        gui_plotorg_waveviewer.columngapcustom_title = uiextras.HBox('Parent', gui_plotorg_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uiextras.Empty('Parent',gui_plotorg_waveviewer.columngapcustom_title);
        gui_plotorg_waveviewer.columnoverlay = uicontrol('Style','radiobutton','Parent', gui_plotorg_waveviewer.columngapcustom_title,'String','Overlap (%)',...
            'callback',@columnoverlap, 'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Enable',rowcolumnEnable,'Value',~columngapgtpValue); %
        gui_plotorg_waveviewer.columnoverlay.KeyPressFcn = @plotorg_presskey;
        
        gui_plotorg_waveviewer.columngapoverlapedit = uicontrol('Style','edit','Parent', gui_plotorg_waveviewer.columngapcustom_title,'String',num2str(columnoverlayStr),...
            'callback',@columnoverlaycustom,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable',columngapOVERLAPEnable); %
        gui_plotorg_waveviewer.columngapoverlapedit.KeyPressFcn = @plotorg_presskey;
        set(gui_plotorg_waveviewer.columngapcustom_title, 'Sizes',[60 90  85]);
        ERPwaviewerin.plot_org.gridlayout.columngap.OverlayOP = gui_plotorg_waveviewer.columnoverlay.Value;
        ERPwaviewerin.plot_org.gridlayout.columngap.OverlayValue = str2num(gui_plotorg_waveviewer.columngapoverlapedit.String);
        
        %%---------------help and apply the changed parameters-------------
        try
            layout_custom_editValue =  MERPWaveViewer_plotorg{10};
        catch
            layout_custom_editValue=0;
        end
        if isempty(layout_custom_editValue) || numel(layout_custom_editValue)~=1 || (layout_custom_editValue~=1 && layout_custom_editValue~=0)
            layout_custom_editValue=0;
        end
        layout_custom_editValue =0;
        gui_plotorg_waveviewer.editgridlayout_title = uiextras.HBox('Parent', gui_plotorg_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        gui_plotorg_waveviewer.layout_custom_edit_checkbox = uicontrol('Style','checkbox','Parent',  gui_plotorg_waveviewer.editgridlayout_title,'String','Custom Grid Locations',...
            'callback',@plotorg_edit_checkbox,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',layout_custom_editValue); %,'HorizontalAlignment','left'
        gui_plotorg_waveviewer.layout_custom_edit_checkbox.KeyPressFcn = @plotorg_presskey;
        
        gui_plotorg_waveviewer.layout_custom_edit = uicontrol('Style','pushbutton','Parent',  gui_plotorg_waveviewer.editgridlayout_title,'String','Edit',...
            'callback',@plotorg_edit,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %,'HorizontalAlignment','left'
        if gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value==1
            gui_plotorg_waveviewer.layout_custom_edit.Enable = 'on';
        else
            gui_plotorg_waveviewer.layout_custom_edit.Enable = 'off';
        end
        set( gui_plotorg_waveviewer.editgridlayout_title,'Sizes',[150 60]);
        MERPWaveViewer_plotorg{10}=gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value;
        ERPwaviewerin.plot_org.gridlayout.GridLayoutAuto=gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value;
        
        gui_plotorg_waveviewer.help_run_title = uiextras.HBox('Parent', gui_plotorg_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        
        gui_plotorg_waveviewer.layout_custom_load = uicontrol('Style','pushbutton','Parent', gui_plotorg_waveviewer.help_run_title,'String','Load',...
            'callback',@layout_custom_load,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %
        gui_plotorg_waveviewer.layout_custom_save = uicontrol('Style','pushbutton','Parent', gui_plotorg_waveviewer.help_run_title,'String','Save as',...
            'callback',@layout_custom_save,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %
        
        gui_plotorg_waveviewer.cancel = uicontrol('Style','pushbutton','Parent',  gui_plotorg_waveviewer.help_run_title,'String','Cancel',...
            'callback',@plotorg_cancel,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        %         gui_plotorg_waveviewer.apply.KeyPressFcn = @plotorg_presskey;
        gui_plotorg_waveviewer.apply = uicontrol('Style','pushbutton','Parent',  gui_plotorg_waveviewer.help_run_title,'String','Apply',...
            'callback',@plotorg_apply,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %,'HorizontalAlignment','left'
        gui_plotorg_waveviewer.apply.KeyPressFcn = @plotorg_presskey;
        
        set(gui_plotorg_waveviewer.DataSelBox,'Sizes',[150 25 25 25 25 25 25 25 25]);
        gui_plotorg_waveviewer.columFormatStr = '';
        assignin('base','ALLERPwaviewer',ERPwaviewerin);
        estudioworkingmemory('MERPWaveViewer_plotorg',MERPWaveViewer_plotorg);%%save parameters for this panel to memory file
    end


%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%-------------------------Setting for Grid--------------------------------
    function plotorg_c1(source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        try
            ERPwaviewerin = evalin('base','ALLERPwaviewer');
            ALLERP = ERPwaviewerin.ALLERP;
            indexerp =  ERPwaviewerin.SelectERPIdx;
        catch
            beep;
            disp('f_ERP_plotorg_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        for Numofselectederp = 1:numel(indexerp)
            SrateNum_mp(Numofselectederp,1)   =  ALLERP(indexerp(Numofselectederp)).srate;
            Datype{Numofselectederp} =   ALLERP(indexerp(Numofselectederp)).datatype;
        end
        if length(unique(Datype))~=1 || (numel(indexerp)==1 && strcmpi(char(Datype),'ERP')~=1)
            MessageViewer= char(strcat('Warning: Type of data varies across ERPsets. We only plot waves for ERPset'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        try
            GridValueOld =  ERPwaviewerin.plot_org.Grid;
        catch
            GridValueOld=1;
        end
        LayoutFlag =  gui_plotorg_waveviewer.LayoutFlag;
        [~,y_Flag] = find(LayoutFlag==1);
        if length(unique(SrateNum_mp))~=1
            gui_plotorg_waveviewer.plotorg_c2.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c4.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c5.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c6.Enable = 'off';
            if y_Flag~=1 && y_Flag~= 3
                MessageViewer= char(strcat('Sampling rate varies across ERPsets. Please select the first or third options'));
                erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
                viewer_ERPDAT.Process_messg =4;
                gui_plotorg_waveviewer.plotorg_c1.Value = 1;
                gui_plotorg_waveviewer.plotorg_c2.Value = 0;
                gui_plotorg_waveviewer.plotorg_c3.Value = 0;
                gui_plotorg_waveviewer.plotorg_c4.Value = 0;
                gui_plotorg_waveviewer.plotorg_c5.Value = 0;
                gui_plotorg_waveviewer.plotorg_c6.Value = 0;
                gui_plotorg_waveviewer.LayoutFlag = [1,0,0,0,0,0];
                if GridValueOld~=1
                    gui_plotorg_waveviewer.layout_auto.Value =1;
                    gui_plotorg_waveviewer.layout_custom.Value = 0;
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
                    gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value=0;
                    gui_plotorg_waveviewer.layout_custom_edit.Enable = 'off';
                end
                return;
            else
                
            end
        else
            gui_plotorg_waveviewer.plotorg_c2.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c4.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c5.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c6.Enable = 'on';
        end
        
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_plotorg_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpwave_viewer_plotorg.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_plotorg_waveviewer.plotorg_c1.Value = 1;
        gui_plotorg_waveviewer.plotorg_c2.Value = 0;
        gui_plotorg_waveviewer.plotorg_c3.Value = 0;
        gui_plotorg_waveviewer.plotorg_c4.Value = 0;
        gui_plotorg_waveviewer.plotorg_c5.Value = 0;
        gui_plotorg_waveviewer.plotorg_c6.Value = 0;
        gui_plotorg_waveviewer.LayoutFlag = [1,0,0,0,0,0];
        try
            chanArray = ERPwaviewerin.chan;
            plotArray = chanArray;
            plotBox = f_getrow_columnautowaveplot(plotArray);%% the first element is number of rows and the second element is the number of columns
        catch
            plotBox = [1 1];
        end
        if GridValueOld~=1
            gui_plotorg_waveviewer.layout_auto.Value =1;
            gui_plotorg_waveviewer.layout_custom.Value = 0;
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
            gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value=0;
            gui_plotorg_waveviewer.layout_custom_edit.Enable = 'off';
        end
        
        if gui_plotorg_waveviewer.layout_auto.Value==1
            try
                gui_plotorg_waveviewer.rownum.Value = plotBox(1);
                gui_plotorg_waveviewer.columnnum.Value = plotBox(2);
            catch
            end
        end
        estudioworkingmemory('OverlayIndex',1);
    end

%%-------------------------Setting for Overlay--------------------------------
    function plotorg_c2(source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        try
            ERPwaviewerin = evalin('base','ALLERPwaviewer');
            ALLERP = ERPwaviewerin.ALLERP;
            indexerp =  ERPwaviewerin.SelectERPIdx;
        catch
            beep;
            disp('f_ERP_plotorg_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        for Numofselectederp = 1:numel(indexerp)
            SrateNum_mp(Numofselectederp,1)   =  ALLERP(indexerp(Numofselectederp)).srate;
            Datype{Numofselectederp} =   ALLERP(indexerp(Numofselectederp)).datatype;
        end
        if length(unique(Datype))~=1 || (numel(indexerp)==1 && strcmpi(char(Datype),'ERP')~=1)
            MessageViewer= char(strcat('Type of data varies across ERPsets. We only plot waves for ERPset'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        try
            GridValueOld =  ERPwaviewerin.plot_org.Grid;
        catch
            GridValueOld=1;
        end
        
        LayoutFlag =  gui_plotorg_waveviewer.LayoutFlag;
        [~,y_Flag] = find(LayoutFlag==1);
        if length(unique(SrateNum_mp))~=1
            gui_plotorg_waveviewer.plotorg_c2.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c4.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c5.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c6.Enable = 'off';
            if  y_Flag~=1 && y_Flag~= 3
                MessageViewer= char(strcat('Sampling rate varies across ERPsets. Please select the first or third options'));
                erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
                viewer_ERPDAT.Process_messg =4;
                gui_plotorg_waveviewer.plotorg_c1.Value = 1;
                gui_plotorg_waveviewer.plotorg_c2.Value = 0;
                gui_plotorg_waveviewer.plotorg_c3.Value = 0;
                gui_plotorg_waveviewer.plotorg_c4.Value = 0;
                gui_plotorg_waveviewer.plotorg_c5.Value = 0;
                gui_plotorg_waveviewer.plotorg_c6.Value = 0;
                gui_plotorg_waveviewer.LayoutFlag = [1,0,0,0,0,0];
                
                if GridValueOld~=1
                    gui_plotorg_waveviewer.layout_auto.Value =1;
                    gui_plotorg_waveviewer.layout_custom.Value = 0;
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
                    gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value=0;
                    gui_plotorg_waveviewer.layout_custom_edit.Enable = 'off';
                end
                return;
            else
                gui_plotorg_waveviewer.plotorg_c2.Value = 0;
                return;
            end
        else
            gui_plotorg_waveviewer.plotorg_c2.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c4.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c5.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c6.Enable = 'on';
        end
        
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_plotorg_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpwave_viewer_plotorg.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_plotorg_waveviewer.plotorg_c1.Value = 0;
        gui_plotorg_waveviewer.plotorg_c2.Value = 1;
        gui_plotorg_waveviewer.plotorg_c3.Value = 0;
        gui_plotorg_waveviewer.plotorg_c4.Value = 0;
        gui_plotorg_waveviewer.plotorg_c5.Value = 0;
        gui_plotorg_waveviewer.plotorg_c6.Value = 0;
        gui_plotorg_waveviewer.LayoutFlag = [0,1,0,0,0,0];
        chanArray = ERPwaviewerin.chan;
        try
            plotArray = chanArray;
            plotBox = f_getrow_columnautowaveplot(plotArray);%% the first element is number of rows and the second element is the number of columns
        catch
            plotBox = [1 1];
        end
        if GridValueOld~=1
            gui_plotorg_waveviewer.layout_auto.Value =1;
            gui_plotorg_waveviewer.layout_custom.Value = 0;
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
            gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value=0;
            gui_plotorg_waveviewer.layout_custom_edit.Enable = 'off';
        end
        if gui_plotorg_waveviewer.layout_auto.Value==1
            try
                gui_plotorg_waveviewer.rownum.Value = plotBox(1);
                gui_plotorg_waveviewer.columnnum.Value = plotBox(2);
            catch
            end
        end
        
        estudioworkingmemory('OverlayIndex',1);
    end

%%-------------------------Setting for Pages--------------------------------
    function plotorg_c3(source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        try
            ERPwaviewerin = evalin('base','ALLERPwaviewer');
            ALLERP = ERPwaviewerin.ALLERP;
            indexerp =  ERPwaviewerin.SelectERPIdx;
        catch
            beep;
            disp('f_ERP_plotorg_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        for Numofselectederp = 1:numel(indexerp)
            SrateNum_mp(Numofselectederp,1)   =  ALLERP(indexerp(Numofselectederp)).srate;
            Datype{Numofselectederp} =   ALLERP(indexerp(Numofselectederp)).datatype;
        end
        if length(unique(Datype))~=1 || (numel(indexerp)==1 && strcmpi(char(Datype),'ERP')~=1)
            MessageViewer= char(strcat('Warning: Type of data varies across ERPsets. We only plot waves for ERPset'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        try
            GridValueOld =  ERPwaviewerin.plot_org.Grid;
        catch
            GridValueOld=1;
        end
        
        LayoutFlag =  gui_plotorg_waveviewer.LayoutFlag;
        [~,y_Flag] = find(LayoutFlag==1);
        if length(unique(SrateNum_mp))~=1
            gui_plotorg_waveviewer.plotorg_c2.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c4.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c5.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c6.Enable = 'off';
            if y_Flag~=1 && y_Flag~=3
                MessageViewer= char(strcat('Sampling rate varies across ERPsets. Please select the first or third options'));
                erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
                viewer_ERPDAT.Process_messg =4;
                gui_plotorg_waveviewer.plotorg_c1.Value = 1;
                gui_plotorg_waveviewer.plotorg_c2.Value = 0;
                gui_plotorg_waveviewer.plotorg_c3.Value = 0;
                gui_plotorg_waveviewer.plotorg_c4.Value = 0;
                gui_plotorg_waveviewer.plotorg_c5.Value = 0;
                gui_plotorg_waveviewer.plotorg_c6.Value = 0;
                gui_plotorg_waveviewer.LayoutFlag = [1,0,0,0,0,0];
                if GridValueOld~=1
                    gui_plotorg_waveviewer.layout_auto.Value =1;
                    gui_plotorg_waveviewer.layout_custom.Value = 0;
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
                    gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value=0;
                    gui_plotorg_waveviewer.layout_custom_edit.Enable = 'off';
                end
                return;
            else
                
            end
        else
            gui_plotorg_waveviewer.plotorg_c2.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c4.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c5.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c6.Enable = 'on';
        end
        
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_plotorg_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpwave_viewer_plotorg.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_plotorg_waveviewer.plotorg_c1.Value = 0;
        gui_plotorg_waveviewer.plotorg_c2.Value = 0;
        gui_plotorg_waveviewer.plotorg_c3.Value = 1;
        gui_plotorg_waveviewer.plotorg_c4.Value = 0;
        gui_plotorg_waveviewer.plotorg_c5.Value = 0;
        gui_plotorg_waveviewer.plotorg_c6.Value = 0;
        gui_plotorg_waveviewer.LayoutFlag = [0,0,1,0,0,0];
        try
            plotArray = ERPwaviewerin.bin;
            plotBox = f_getrow_columnautowaveplot(plotArray);%% the first element is number of rows and the second element is the number of columns
        catch
            plotBox = [1 1];
        end
        if GridValueOld~=2
            gui_plotorg_waveviewer.layout_auto.Value =1;
            gui_plotorg_waveviewer.layout_custom.Value = 0;
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
            gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value=0;
            gui_plotorg_waveviewer.layout_custom_edit.Enable = 'off';
        end
        if gui_plotorg_waveviewer.layout_auto.Value==1
            try
                gui_plotorg_waveviewer.rownum.Value = plotBox(1);
                gui_plotorg_waveviewer.columnnum.Value = plotBox(2);
            catch
            end
        end
        
        estudioworkingmemory('OverlayIndex',1);
    end


%%-------------------------Setting for Pages--------------------------------
    function plotorg_c4(source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        
        try
            ERPwaviewerin = evalin('base','ALLERPwaviewer');
            ALLERP = ERPwaviewerin.ALLERP;
            indexerp =  ERPwaviewerin.SelectERPIdx;
        catch
            beep;
            disp('f_ERP_plotorg_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        for Numofselectederp = 1:numel(indexerp)
            SrateNum_mp(Numofselectederp,1)   =  ALLERP(indexerp(Numofselectederp)).srate;
            Datype{Numofselectederp} =   ALLERP(indexerp(Numofselectederp)).datatype;
        end
        if length(unique(Datype))~=1 || (numel(indexerp)==1 && strcmpi(char(Datype),'ERP')~=1)
            MessageViewer= char(strcat('Warning: Type of data varies across ERPsets. We only plot waves for ERPset'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        
        try
            GridValueOld =  ERPwaviewerin.plot_org.Grid;
        catch
            GridValueOld=1;
        end
        LayoutFlag =  gui_plotorg_waveviewer.LayoutFlag;
        [~,y_Flag] = find(LayoutFlag==1);
        if length(unique(SrateNum_mp))~=1
            gui_plotorg_waveviewer.plotorg_c2.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c4.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c5.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c6.Enable = 'off';
            if  y_Flag~=1 && y_Flag~= 3
                MessageViewer= char(strcat('Sampling rate varies across ERPsets. Please select the first or third options'));
                erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
                viewer_ERPDAT.Process_messg =4;
                gui_plotorg_waveviewer.plotorg_c1.Value = 1;
                gui_plotorg_waveviewer.plotorg_c2.Value = 0;
                gui_plotorg_waveviewer.plotorg_c3.Value = 0;
                gui_plotorg_waveviewer.plotorg_c4.Value = 0;
                gui_plotorg_waveviewer.plotorg_c5.Value = 0;
                gui_plotorg_waveviewer.plotorg_c6.Value = 0;
                gui_plotorg_waveviewer.LayoutFlag = [1,0,0,0,0,0];
                if GridValueOld~=1
                    gui_plotorg_waveviewer.layout_auto.Value =1;
                    gui_plotorg_waveviewer.layout_custom.Value = 0;
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
                    gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value=0;
                    gui_plotorg_waveviewer.layout_custom_edit.Enable = 'off';
                end
                return;
            else
                gui_plotorg_waveviewer.plotorg_c4.Value = 0;
                return;
            end
        else
            gui_plotorg_waveviewer.plotorg_c2.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c4.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c5.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c6.Enable = 'on';
        end
        
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_plotorg_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpwave_viewer_plotorg.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_plotorg_waveviewer.plotorg_c1.Value = 0;
        gui_plotorg_waveviewer.plotorg_c2.Value = 0;
        gui_plotorg_waveviewer.plotorg_c3.Value = 0;
        gui_plotorg_waveviewer.plotorg_c4.Value = 1;
        gui_plotorg_waveviewer.plotorg_c5.Value = 0;
        gui_plotorg_waveviewer.plotorg_c6.Value = 0;
        gui_plotorg_waveviewer.LayoutFlag = [0,0,0,1,0,0];
        try
            plotArray = ERPwaviewerin.bin;
            plotBox = f_getrow_columnautowaveplot(plotArray);%% the first element is number of rows and the second element is the number of columns
        catch
            plotBox = [1 1];
        end
        if GridValueOld~=2
            gui_plotorg_waveviewer.layout_auto.Value =1;
            gui_plotorg_waveviewer.layout_custom.Value = 0;
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
            gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value=0;
            gui_plotorg_waveviewer.layout_custom_edit.Enable = 'off';
        end
        
        if gui_plotorg_waveviewer.layout_auto.Value==1
            try
                gui_plotorg_waveviewer.rownum.Value = plotBox(1);
                gui_plotorg_waveviewer.columnnum.Value = plotBox(2);
            catch
            end
        end
        estudioworkingmemory('OverlayIndex',1);
        
        
    end


%%-------------------------Setting for Pages--------------------------------
    function plotorg_c5(source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        
        try
            ERPwaviewerin = evalin('base','ALLERPwaviewer');
            ALLERP = ERPwaviewerin.ALLERP;
            indexerp =  ERPwaviewerin.SelectERPIdx;
        catch
            beep;
            disp('f_ERP_plotorg_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        for Numofselectederp = 1:numel(indexerp)
            SrateNum_mp(Numofselectederp,1)   =  ALLERP(indexerp(Numofselectederp)).srate;
            Datype{Numofselectederp} =   ALLERP(indexerp(Numofselectederp)).datatype;
        end
        if length(unique(Datype))~=1 || (numel(indexerp)==1 && strcmpi(char(Datype),'ERP')~=1)
            MessageViewer= char(strcat('Warning: Type of data varies across ERPsets. We only plot waves for ERPset'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        try
            GridValueOld =  ERPwaviewerin.plot_org.Grid;
        catch
            GridValueOld=1;
        end
        LayoutFlag =  gui_plotorg_waveviewer.LayoutFlag;
        [~,y_Flag] = find(LayoutFlag==1);
        if length(unique(SrateNum_mp))~=1
            gui_plotorg_waveviewer.plotorg_c2.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c4.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c5.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c6.Enable = 'off';
            if  y_Flag~=1 && y_Flag~= 3
                MessageViewer= char(strcat('Sampling rate varies across ERPsets. Please select the first or third options'));
                erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
                viewer_ERPDAT.Process_messg =4;
                gui_plotorg_waveviewer.plotorg_c1.Value = 1;
                gui_plotorg_waveviewer.plotorg_c2.Value = 0;
                gui_plotorg_waveviewer.plotorg_c3.Value = 0;
                gui_plotorg_waveviewer.plotorg_c4.Value = 0;
                gui_plotorg_waveviewer.plotorg_c5.Value = 0;
                gui_plotorg_waveviewer.plotorg_c6.Value = 0;
                gui_plotorg_waveviewer.LayoutFlag = [1,0,0,0,0,0];
                if GridValueOld~=1
                    gui_plotorg_waveviewer.layout_auto.Value =1;
                    gui_plotorg_waveviewer.layout_custom.Value = 0;
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
                    gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value=0;
                    gui_plotorg_waveviewer.layout_custom_edit.Enable = 'off';
                end
                return;
            else
                gui_plotorg_waveviewer.plotorg_c5.Value = 0;
                return;
            end
        else
            gui_plotorg_waveviewer.plotorg_c2.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c4.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c5.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c6.Enable = 'on';
        end
        
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_plotorg_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpwave_viewer_plotorg.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_plotorg_waveviewer.plotorg_c1.Value = 0;
        gui_plotorg_waveviewer.plotorg_c2.Value = 0;
        gui_plotorg_waveviewer.plotorg_c3.Value = 0;
        gui_plotorg_waveviewer.plotorg_c4.Value = 0;
        gui_plotorg_waveviewer.plotorg_c5.Value = 1;
        gui_plotorg_waveviewer.plotorg_c6.Value = 0;
        gui_plotorg_waveviewer.LayoutFlag = [0,0,0,0,1,0];
        try
            plotArray = indexerp;
            plotBox = f_getrow_columnautowaveplot(plotArray);%% the first element is number of rows and the second element is the number of columns
        catch
            plotBox = [1 1];
        end
        if GridValueOld~=3
            gui_plotorg_waveviewer.layout_auto.Value =1;
            gui_plotorg_waveviewer.layout_custom.Value = 0;
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
            gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value=0;
            gui_plotorg_waveviewer.layout_custom_edit.Enable = 'off';
            
        end
        if gui_plotorg_waveviewer.layout_auto.Value==1
            try
                gui_plotorg_waveviewer.rownum.Value = plotBox(1);
                gui_plotorg_waveviewer.columnnum.Value = plotBox(2);
            catch
            end
        end
        estudioworkingmemory('OverlayIndex',1);
        
    end


%%-------------------------Setting for Pages--------------------------------
    function plotorg_c6(source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        
        try
            ERPwaviewerin = evalin('base','ALLERPwaviewer');
            ALLERP = ERPwaviewerin.ALLERP;
            indexerp =  ERPwaviewerin.SelectERPIdx;
        catch
            beep;
            disp('f_ERP_plotorg_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        for Numofselectederp = 1:numel(indexerp)
            SrateNum_mp(Numofselectederp,1)   =  ALLERP(indexerp(Numofselectederp)).srate;
            Datype{Numofselectederp} =   ALLERP(indexerp(Numofselectederp)).datatype;
        end
        if length(unique(Datype))~=1 || (numel(indexerp)==1 && strcmpi(char(Datype),'ERP')~=1)
            MessageViewer= char(strcat('Warning: Type of data varies across ERPsets. We only plot waves for ERPset'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        try
            GridValueOld =  ERPwaviewerin.plot_org.Grid;
        catch
            GridValueOld=1;
        end
        LayoutFlag =  gui_plotorg_waveviewer.LayoutFlag;
        [~,y_Flag] = find(LayoutFlag==1);
        if length(unique(SrateNum_mp))~=1
            gui_plotorg_waveviewer.plotorg_c2.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c4.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c5.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c6.Enable = 'off';
            if  y_Flag~=1 && y_Flag~= 3
                MessageViewer= char(strcat('Sampling rate varies across ERPsets. Please select the first or third options'));
                erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
                viewer_ERPDAT.Process_messg =4;
                gui_plotorg_waveviewer.plotorg_c1.Value = 1;
                gui_plotorg_waveviewer.plotorg_c2.Value = 0;
                gui_plotorg_waveviewer.plotorg_c3.Value = 0;
                gui_plotorg_waveviewer.plotorg_c4.Value = 0;
                gui_plotorg_waveviewer.plotorg_c5.Value = 0;
                gui_plotorg_waveviewer.plotorg_c6.Value = 0;
                gui_plotorg_waveviewer.LayoutFlag = [1,0,0,0,0,0];
                if GridValueOld~=1
                    gui_plotorg_waveviewer.layout_auto.Value =1;
                    gui_plotorg_waveviewer.layout_custom.Value = 0;
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
                    gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value=0;
                    gui_plotorg_waveviewer.layout_custom_edit.Enable = 'off';
                    gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value=0;
                    gui_plotorg_waveviewer.layout_custom_edit.Enable = 'off';
                end
                return;
            else
                gui_plotorg_waveviewer.plotorg_c6.Value = 0;
                return;
            end
        else
            gui_plotorg_waveviewer.plotorg_c2.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c4.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c5.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c6.Enable = 'on';
        end
        
        
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_plotorg_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpwave_viewer_plotorg.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_plotorg_waveviewer.plotorg_c1.Value = 0;
        gui_plotorg_waveviewer.plotorg_c2.Value = 0;
        gui_plotorg_waveviewer.plotorg_c3.Value = 0;
        gui_plotorg_waveviewer.plotorg_c4.Value = 0;
        gui_plotorg_waveviewer.plotorg_c5.Value = 0;
        gui_plotorg_waveviewer.plotorg_c6.Value = 1;
        gui_plotorg_waveviewer.LayoutFlag = [0,0,0,0,0,1];
        if GridValueOld~=3
            gui_plotorg_waveviewer.layout_auto.Value =1;
            gui_plotorg_waveviewer.layout_custom.Value = 0;
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
            gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value=0;
            gui_plotorg_waveviewer.layout_custom_edit.Enable = 'off';
        end
        try
            plotArray = indexerp;
            plotBox = f_getrow_columnautowaveplot(plotArray);%% the first element is number of rows and the second element is the number of columns
        catch
            plotBox = [1 1];
        end
        if gui_plotorg_waveviewer.layout_auto.Value==1
            try
                gui_plotorg_waveviewer.rownum.Value = plotBox(1);
                gui_plotorg_waveviewer.columnnum.Value = plotBox(2);
            catch
            end
        end
        estudioworkingmemory('OverlayIndex',1);
    end


%%----------------Setting for gridlayout auto-----------------------------
    function layout_auto(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_plotorg_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpwave_viewer_plotorg.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_plotorg_waveviewer.layout_auto.Value =1;
        gui_plotorg_waveviewer.layout_custom.Value = 0;
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
        
        
    end


%%--------------Setting for layout custom----------------------------------
    function layout_custom(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_plotorg_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpwave_viewer_plotorg.TitleColor= [0.4940 0.1840 0.5560];
        gui_plotorg_waveviewer.layout_auto.Value =0;
        gui_plotorg_waveviewer.layout_custom.Value = 1;
        gui_plotorg_waveviewer.rownum.Enable = 'on';
        gui_plotorg_waveviewer.columnnum.Enable = 'on';
        
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
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_plotorg_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpwave_viewer_plotorg.TitleColor= [0.4940 0.1840 0.5560];
    end


%%------------------------------Number of columns--------------------------
    function plotorg_columnnum(Str,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_plotorg_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpwave_viewer_plotorg.TitleColor= [0.4940 0.1840 0.5560];
    end



%%-------------------row GTP option----------------------------------------
    function rowgapgtpauto(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_plotorg_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpwave_viewer_plotorg.TitleColor= [0.4940 0.1840 0.5560];
        gui_plotorg_waveviewer.rowgap_auto.Value = 1;
        gui_plotorg_waveviewer.rowgapGTPcustom.Enable = 'on';
        gui_plotorg_waveviewer.rowoverlap.Value =0;
        gui_plotorg_waveviewer.rowgapoverlayedit.Enable = 'off';
    end

%%----------------------row GTP custom-------------------------------------
    function rowgapgtpcustom(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_plotorg_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpwave_viewer_plotorg.TitleColor= [0.4940 0.1840 0.5560];
        rowgap = str2num(Source.String);
        if isempty(rowgap) || numel(rowgap)~=1 || rowgap<=0
            MessageViewer= char(strcat('Plot Organization > Row > Gap should be larger than 0'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =4;
            Source.String = '10';
            return;
        end
    end


%%----------------row gap overlay option-----------------------------------
    function rowoverlap(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_plotorg_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpwave_viewer_plotorg.TitleColor= [0.4940 0.1840 0.5560];
        gui_plotorg_waveviewer.rowgap_auto.Value = 0;
        gui_plotorg_waveviewer.rowgapGTPcustom.Enable = 'off';
        gui_plotorg_waveviewer.rowoverlap.Value =1;
        gui_plotorg_waveviewer.rowgapoverlayedit.Enable = 'on';
    end

%%-------------------row gap overlay custom--------------------------------
    function rowoverlapcustom(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_plotorg_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpwave_viewer_plotorg.TitleColor= [0.4940 0.1840 0.5560];
        rowoverlay = str2num(Source.String);
        if isempty(rowoverlay) || numel(rowoverlay)~=1 || rowoverlay<=0 || rowoverlay>=100
            MessageViewer= char(strcat('Plot Organization > Column > Overlap should be larger than 0 and smaller than 100'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =4;
            
            Source.String = '40';
            return;
        end
    end


%%----------------column GTP option----------------------------------------
    function columngapgtpop(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_plotorg_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpwave_viewer_plotorg.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_plotorg_waveviewer.columngapgtpop.Value =1;
        gui_plotorg_waveviewer.columngapgtpcustom.Enable = 'on';
        gui_plotorg_waveviewer.columnoverlay.Value=0;
        gui_plotorg_waveviewer.columngapoverlapedit.Enable = 'off';
    end
%%-----------------column GTP custom---------------------------------------
    function columngapGTPcustom(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_plotorg_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpwave_viewer_plotorg.TitleColor= [0.4940 0.1840 0.5560];
        columngap = str2num(Source.String);
        if isempty(columngap) || numel(columngap)~=1 || columngap<=0
            MessageViewer= char(strcat('Plot Organization > Column > Gap should be larger than 0'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =4;
            Source.String = '10';
            return;
        end
    end


%%----------------column overlay option------------------------------------
    function columnoverlap(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_plotorg_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpwave_viewer_plotorg.TitleColor= [0.4940 0.1840 0.5560];
        
        colnOverlay = str2num(char( gui_plotorg_waveviewer.columngapoverlapedit.String));
        gui_plotorg_waveviewer.columngapgtpop.Value =0;
        gui_plotorg_waveviewer.columngapgtpcustom.Enable = 'off';
        gui_plotorg_waveviewer.columnoverlay.Value=1;
        gui_plotorg_waveviewer.columngapoverlapedit.Enable = 'on';
        if isempty(colnOverlay)
            gui_plotorg_waveviewer.columngapoverlapedit.String = '40';
        end
    end


%%-----------------column overlay custom-----------------------------------
    function columnoverlaycustom(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_plotorg_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpwave_viewer_plotorg.TitleColor= [0.4940 0.1840 0.5560];
        
        columnoverlay = str2num(Source.String);
        if isempty(columnoverlay) || numel(columnoverlay)~=1 || columnoverlay<=0 || columnoverlay>=100
            Source.String = '40';
            return;
        end
    end



%%
    function plotorg_edit_checkbox(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) %% && viewerpanelIndex~=4
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_plotorg_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpwave_viewer_plotorg.TitleColor= [0.4940 0.1840 0.5560];
        if Source.Value==1
            gui_plotorg_waveviewer.layout_custom_edit.Enable = 'on';
        else
            gui_plotorg_waveviewer.layout_custom_edit.Enable = 'off';
        end
        
        
        if Source.Value==0
            try
                ERPwaviewerin = evalin('base','ALLERPwaviewer');
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
            if gui_plotorg_waveviewer.plotorg_c3.Value ==1 || gui_plotorg_waveviewer.plotorg_c4.Value ==1
                GridValue=2;
            elseif gui_plotorg_waveviewer.plotorg_c5.Value==1 || gui_plotorg_waveviewer.plotorg_c6.Value ==1
                GridValue=3;
            else
                GridValue=1;
            end
            
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
                        GridinforData{Numofrows,Numofcolumns} = '';
                    else
                        GridinforData{Numofrows,Numofcolumns} = char(plotArrayStr(count));
                    end
                end
            end
            ERPwaviewerin.plot_org.gridlayout.data = GridinforData;
            ERPwaviewerin.plot_org.gridlayout.columFormat = plotArrayStr';
            ERPwaviewerin.plot_org.gridlayout.GridLayoutAuto = 0;
            assignin('base','ALLERPwaviewer',ERPwaviewerin);
        end
    end

%%-----------------Edit the layout-----------------------------------------
    function plotorg_edit(Source,~)
        if Source.Value==0
            return;
        end
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) %% && viewerpanelIndex~=4
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_plotorg',1);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_plotorg_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erpwave_viewer_plotorg.TitleColor= [0.4940 0.1840 0.5560];
        
        MessageViewer= char(strcat('Plot Organization > Custom Grid Locations > Edit'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        try
            ERPwaviewerin = evalin('base','ALLERPwaviewer');
        catch
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n f_ERP_plotorg_waveviewer_GUI()> plotorg_edit() error: Cannot get parameters for whole panel.\n Please run My viewer again.\n\n');
            return;
        end
        
        columFormat =  ERPwaviewerin.plot_org.gridlayout.columFormat;
        
        plotBox(1) = ERPwaviewerin.plot_org.gridlayout.rows;
        plotBox(2) = ERPwaviewerin.plot_org.gridlayout.columns;
        try
            GridinforData = ERPwaviewerin.plot_org.gridlayout.data;
        catch
            GridinforData = [];
        end
        
        
        ERPsetArray = ERPwaviewerin.SelectERPIdx;
        ALLERPIN = ERPwaviewerin.ALLERP;
        if max(ERPsetArray) >length(ALLERPIN)
            ERPsetArray =length(ALLERPIN);
        end
        GridValue= ERPwaviewerin.plot_org.Grid;
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERPIN,ERPsetArray);
        if GridValue ==1 %% if  the selected Channel is "Grid"
            AllabelArray = chanStr;
        elseif GridValue == 2 %% if the selected Bin is "Grid"
            AllabelArray = binStr;
        elseif GridValue == 3%% if the selected ERPset is "Grid"
            for ii = 1:length(ALLERPIN)
                AllabelArray(ii,1) ={char(ALLERPIN(ii).erpname)};
            end
        else
            AllabelArray = chanStr;
        end
        
        def =  ERP_layoutstringGUI(columFormat,GridinforData,plotBox,AllabelArray);
        if isempty(def)
            estudioworkingmemory('MyViewer_plotorg',0);
            gui_plotorg_waveviewer.apply.BackgroundColor =  [1,1,1];
            box_erpwave_viewer_plotorg.TitleColor= [0.5 0.5 0.9];
            gui_plotorg_waveviewer.apply.ForegroundColor = [0 0 0];
            disp('User selected cancel');
            return;
        end
        
        TableDataDf = def{1};
        ERPwaviewerin.plot_org.gridlayout.rows = size(TableDataDf,1);
        ERPwaviewerin.plot_org.gridlayout.columns =size(TableDataDf,2);
        gui_plotorg_waveviewer.rownum.Value =size(TableDataDf,1);
        gui_plotorg_waveviewer.columnnum.Value =size(TableDataDf,2);
        try
            columFormatout = def{2};
        catch
            columFormatout = columFormat;
        end
        gui_plotorg_waveviewer.columFormatStr = columFormatout;
        ERPwaviewerin.plot_org.gridlayout.columFormat = columFormatout;
        ERPwaviewerin.plot_org.gridlayout.data =TableDataDf;
        if ERPwaviewerin.plot_org.Grid==1
            try
                ERPwaviewerin.chan = def{3};
            catch
            end
            MERPWaveViewer_plotorg{1}=1;
        elseif ERPwaviewerin.plot_org.Grid==2
            try
                ERPwaviewerin.bin = def{3};
            catch
            end
            MERPWaveViewer_plotorg{1}=2;
        elseif ERPwaviewerin.plot_org.Grid==3
            try
                ERPwaviewerin.SelectERPIdx = def{3};
            catch
            end
            if ERPwaviewerin.PageIndex> numel(ERPwaviewerin.SelectERPIdx)
                ERPwaviewerin.PageIndex=1;
            end
            MERPWaveViewer_plotorg{1}=3;
        end
        assignin('base','ALLERPwaviewer',ERPwaviewerin);
        
        MERPWaveViewer_plotorg{2}=gui_plotorg_waveviewer.layout_auto.Value;
        plotBox(1) = gui_plotorg_waveviewer.rownum.Value;
        plotBox(2) = gui_plotorg_waveviewer.columnnum.Value;
        MERPWaveViewer_plotorg{3}=plotBox;
        MERPWaveViewer_plotorg{4}= gui_plotorg_waveviewer.rowgap_auto.Value;
        MERPWaveViewer_plotorg{5}=str2num(gui_plotorg_waveviewer.rowgapGTPcustom.String);
        MERPWaveViewer_plotorg{6}=str2num(gui_plotorg_waveviewer.rowgapoverlayedit.String);
        MERPWaveViewer_plotorg{7} = gui_plotorg_waveviewer.columngapgtpop.Value;
        MERPWaveViewer_plotorg{8}=str2num(gui_plotorg_waveviewer.columngapgtpcustom.String);
        MERPWaveViewer_plotorg{9}=str2num(gui_plotorg_waveviewer.columngapoverlapedit.String);
        MERPWaveViewer_plotorg{10}=gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value;
        estudioworkingmemory('MERPWaveViewer_plotorg',MERPWaveViewer_plotorg);%%save parameters for this panel to memory file
        viewer_ERPDAT.ERPset_Chan_bin_label=1;
        
        f_redrawERP_viewer_test();
        estudioworkingmemory('MyViewer_plotorg',0);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [1,1,1];
        box_erpwave_viewer_plotorg.TitleColor= [0.5 0.5 0.9];
        gui_plotorg_waveviewer.apply.ForegroundColor = [0 0 0];
    end




%%-------load the saved parameters for plotting organization---------------
    function layout_custom_load(~,~)
        MessageViewer= char(strcat('Plot Organization > Load'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        
        [filename, filepath] = uigetfile('*.mat', ...
            'Load parametrs for "Plot Organization"', ...
            'MultiSelect', 'off');
        if isequal(filename,0)
            disp('User selected Cancel');
            return;
        end
        try
            Plot_orgpar = importdata([filepath,filename]);
        catch
            beep;
            disp('Cannot load the file.');
            return;
        end
        try
            ERPwaviewerin = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp('f_ERP_plotorg_waveviewer_GUI() > layout_custom_load() error: Please run the ERP wave viewer again.');
            return;
        end
        
        %%check current version
        ERPtooltype = erpgettoolversion('tooltype');
        if strcmpi(ERPtooltype,'EStudio')
            try
                [version1 reldate] = geterplabstudioversion;
                erplabstudiover = version1;
            catch
                erplabstudiover = '';
            end
        else
            try
                [version1 reldate] = geterplabversion;
                erplabstudiover = version1;
            catch
                erplabstudiover = '';
            end
        end
        erplabstudioverNum = str2num(erplabstudiover);
        try
            erplabstudioverNumOld = str2num(Plot_orgpar.version);
        catch
            erplabstudioverNumOld = [];
        end
        if isempty(erplabstudioverNumOld) || erplabstudioverNumOld<erplabstudioverNum
            if strcmpi(ERPtooltype,'EStudio')
                MessageViewer= char(strcat('Plot Organization > Load - This settings file was created using an older version of EStudio'));
            elseif strcmpi(ERPtooltype,'ERPLAB')
                MessageViewer= char(strcat('Plot Organization > Load - This settings file was created using an older version of ERPLAB'));
            end
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =4;
        end
        
        try
            GridValue  = Plot_orgpar.Grid;
            OverlayValue = Plot_orgpar.Overlay;
            PageValue=Plot_orgpar.Pages;
        catch
            GridValue  = 1;OverlayValue = 2;PageValue=3;
        end
        
        %%------------------default labels---------------------------------
        binArray = ERPwaviewerin.bin;
        chanArray = ERPwaviewerin.chan;
        ERPsetArray = ERPwaviewerin.SelectERPIdx;
        ALLERPIN = ERPwaviewerin.ALLERP;
        if max(ERPsetArray) >length(ALLERPIN)
            ERPsetArray =length(ALLERPIN);
        end
        for Numofselectederp = 1:numel(ERPsetArray)
            SrateNum_mp(Numofselectederp,1)   =  ALLERPIN(ERPsetArray(Numofselectederp)).srate;
        end
        if numel(unique(SrateNum_mp))>1
            gui_plotorg_waveviewer.plotorg_c2.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c4.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c5.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c6.Enable = 'off';
            if PageValue~= 3
                MessageViewer= char(strcat('Plot Organization > Load - Sampling rate varies across ERPsets. We used the first option'));
                erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
                viewer_ERPDAT.Process_messg =4;
                GridValue  = 1;OverlayValue = 2;PageValue=3;
            end
        else
            gui_plotorg_waveviewer.plotorg_c2.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c4.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c5.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c6.Enable = 'on';
        end
        
        if   GridValue==1 && OverlayValue == 2&& PageValue ==3
            gui_plotorg_waveviewer.plotorg_c1.Value =1;
            gui_plotorg_waveviewer.plotorg_c2.Value =0;
            gui_plotorg_waveviewer.plotorg_c3.Value =0;
            gui_plotorg_waveviewer.plotorg_c4.Value =0;
            gui_plotorg_waveviewer.plotorg_c5.Value =0;
            gui_plotorg_waveviewer.plotorg_c6.Value =0;
            gui_plotorg_waveviewer.LayoutFlag = [1,0,0,0,0,0];
            MERPWaveViewer_plotorg{1}=1;
        elseif  GridValue==1 && OverlayValue == 3&& PageValue ==2
            gui_plotorg_waveviewer.plotorg_c1.Value =0;
            gui_plotorg_waveviewer.plotorg_c2.Value =1;
            gui_plotorg_waveviewer.plotorg_c3.Value =0;
            gui_plotorg_waveviewer.plotorg_c4.Value =0;
            gui_plotorg_waveviewer.plotorg_c5.Value =0;
            gui_plotorg_waveviewer.plotorg_c6.Value =0;
            gui_plotorg_waveviewer.LayoutFlag = [0,1,0,0,0,0];
            MERPWaveViewer_plotorg{1}=2;
        elseif  GridValue==2 && OverlayValue == 1 && PageValue ==3
            gui_plotorg_waveviewer.plotorg_c1.Value =0;
            gui_plotorg_waveviewer.plotorg_c2.Value =0;
            gui_plotorg_waveviewer.plotorg_c3.Value =1;
            gui_plotorg_waveviewer.plotorg_c4.Value =0;
            gui_plotorg_waveviewer.plotorg_c5.Value =0;
            gui_plotorg_waveviewer.plotorg_c6.Value =0;
            gui_plotorg_waveviewer.LayoutFlag = [0,0,1,0,0,0];
            MERPWaveViewer_plotorg{1}=3;
        elseif  GridValue==2 && OverlayValue == 3 && PageValue ==1
            gui_plotorg_waveviewer.plotorg_c1.Value =0;
            gui_plotorg_waveviewer.plotorg_c2.Value =0;
            gui_plotorg_waveviewer.plotorg_c3.Value =0;
            gui_plotorg_waveviewer.plotorg_c4.Value =1;
            gui_plotorg_waveviewer.plotorg_c5.Value =0;
            gui_plotorg_waveviewer.plotorg_c6.Value =0;
            gui_plotorg_waveviewer.LayoutFlag = [0,0,0,1,0,0];
            MERPWaveViewer_plotorg{1}=4;
        elseif GridValue==3 && OverlayValue == 1 && PageValue ==2
            gui_plotorg_waveviewer.plotorg_c1.Value =0;
            gui_plotorg_waveviewer.plotorg_c2.Value =0;
            gui_plotorg_waveviewer.plotorg_c3.Value =0;
            gui_plotorg_waveviewer.plotorg_c4.Value =0;
            gui_plotorg_waveviewer.plotorg_c5.Value =1;
            gui_plotorg_waveviewer.plotorg_c6.Value =0;
            gui_plotorg_waveviewer.LayoutFlag = [0,0,0,0,1,0];
            MERPWaveViewer_plotorg{1}=5;
        elseif GridValue==3 && OverlayValue == 2 && PageValue ==1
            gui_plotorg_waveviewer.plotorg_c1.Value =0;
            gui_plotorg_waveviewer.plotorg_c2.Value =0;
            gui_plotorg_waveviewer.plotorg_c3.Value =0;
            gui_plotorg_waveviewer.plotorg_c4.Value =0;
            gui_plotorg_waveviewer.plotorg_c5.Value =0;
            gui_plotorg_waveviewer.plotorg_c6.Value =1;
            gui_plotorg_waveviewer.LayoutFlag = [0,0,0,0,0,1];
            MERPWaveViewer_plotorg{1}=6;
        end
        
        try
            gui_plotorg_waveviewer.layout_auto.Value=Plot_orgpar.gridlayout.op;
            gui_plotorg_waveviewer.layout_custom.Value = ~Plot_orgpar.gridlayout.op;
            ERPwaviewerin.plot_org.Grid= GridValue;
            ERPwaviewerin.plot_org.Overlay =OverlayValue;
            ERPwaviewerin.plot_org.Pages=PageValue;
        catch
            beep;
            disp('The imported parameters were invalid.')
            return;
        end
        
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERPIN,ERPsetArray);
        if GridValue ==1 %% if  the selected Channel is "Grid"
            plotArray = chanArray;
            plotArrayStr = chanStr(chanArray);
            plotArrayFormtdef = plotArrayStr;
        elseif GridValue == 2 %% if the selected Bin is "Grid"
            plotArray = binArray;
            plotArrayStr = binStr(binArray);
            plotArrayFormtdef = plotArrayStr;
            
        elseif GridValue == 3%% if the selected ERPset is "Grid"
            plotArray = ERPsetArray;
            for Numoferpset = 1:numel(ERPsetArray)
                plotArrayStr(Numoferpset,1) = {char(ALLERPIN(ERPsetArray(Numoferpset)).erpname)};
            end
            plotArrayFormtdef = plotArrayStr;
        else
            plotArray = chanArray;
            plotArrayStr = chanStr(chanArray);
            plotArrayFormtdef = plotArrayStr;
        end
        plotBox = f_getrow_columnautowaveplot(plotArray);%% the first element is number of rows and the second element is the number of columns
        
        
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
        gui_plotorg_waveviewer.rownum.Value=Plot_orgpar.gridlayout.rows;
        gui_plotorg_waveviewer.columnnum.Value=Plot_orgpar.gridlayout.columns;
        NumrowsDef = plotBox(1);
        NumcolumnsDef=plotBox(2);
        count = 0;
        for Numofrows = 1:NumrowsDef
            for Numofcolumns = 1:NumcolumnsDef
                count = count +1;
                if count> numel(plotArray)
                    GridinforDatadef{Numofrows,Numofcolumns} = '';
                else
                    GridinforDatadef{Numofrows,Numofcolumns} = char(plotArrayStr(count));
                end
            end
        end
        
        if gui_plotorg_waveviewer.layout_auto.Value==1
            LayOutauto = 'off';
        else
            LayOutauto = 'on';
        end
        try
            gui_plotorg_waveviewer.layoutinfor_table.Enable =LayOutauto;
            gui_plotorg_waveviewer.rownum.Enable=LayOutauto;
            gui_plotorg_waveviewer.columnnum.Enable=LayOutauto;
            ERPwaviewerin.plot_org.gridlayout.rows = Plot_orgpar.gridlayout.rows;
            ERPwaviewerin.plot_org.gridlayout.columns =Plot_orgpar.gridlayout.columns;
            %             ERPwaviewerin.plot_org.gridlayout.columFormat = plotArrayFormtimpChag;
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
        
        if Plot_orgpar.gridlayout.GridLayoutAuto==0
            gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value = 0;
            gui_plotorg_waveviewer.layout_custom_edit.Enable = 'off';
            ERPwaviewerin.plot_org.gridlayout.data= GridinforDatadef;
        else
            EmptyItemStr = '';
            gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value = 1;
            gui_plotorg_waveviewer.layout_custom_edit.Enable = 'on';
            ERPwaviewerin.plot_org.gridlayout.columFormat = plotArrayFormtdef;
            plotArrayFormt=   ERPwaviewerin.plot_org.gridlayout.columFormat';
            GridinforDataOrg =  Plot_orgpar.gridlayout.data;
            %             LabelUsedIndex = [];
            %             countlabel=0;
            for ii = 1:size(GridinforDataOrg,1)
                for jj = 1:size(GridinforDataOrg,2)
                    code = 0;
                    for kk = 1:length(plotArrayFormt)
                        if strcmp(GridinforDataOrg{ii,jj},char(plotArrayFormt(kk)))
                            code = 1;
                        end
                    end
                    if code==0
                        if ~isempty(GridinforDataOrg{ii,jj})
                            if isnumeric(GridinforDataOrg{ii,jj})
                                EmptyItemStr = strcat(EmptyItemStr,32,num2str(GridinforDataOrg{ii,jj}));
                            else
                                EmptyItemStr = strcat(EmptyItemStr,32,num2str(GridinforDataOrg{ii,jj}));
                            end
                        end
                        GridinforDataOrg{ii,jj} = '';
                    end
                end
            end
            if ~isempty(EmptyItemStr)
                MessageViewer= char(strcat('Plot Organization > Load - Undefined items in grid locations:',EmptyItemStr,32,'. Because they donot match with the selected labels'));
                erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
                viewer_ERPDAT.Process_messg =4;
            end
         
            
            ERPwaviewerin.plot_org.gridlayout.data =GridinforDataOrg;
            gui_plotorg_waveviewer.rownum.Value = size(GridinforDataOrg,1);
            gui_plotorg_waveviewer.columnnum.Value= size(GridinforDataOrg,2);
            ERPwaviewerin.plot_org.gridlayout.rows = gui_plotorg_waveviewer.rownum.Value;
            ERPwaviewerin.plot_org.gridlayout.columns =gui_plotorg_waveviewer.columnnum.Value;
        end
        
        
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
        ERPwaviewerin.plot_org.gridlayout.GridLayoutAuto = gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value;
        
        
        MERPWaveViewer_plotorg{2}=gui_plotorg_waveviewer.layout_auto.Value;
        plotBox(1) = gui_plotorg_waveviewer.rownum.Value;
        plotBox(2) = gui_plotorg_waveviewer.columnnum.Value;
        MERPWaveViewer_plotorg{3}=plotBox;
        MERPWaveViewer_plotorg{4}= gui_plotorg_waveviewer.rowgap_auto.Value;
        MERPWaveViewer_plotorg{5}=str2num(gui_plotorg_waveviewer.rowgapGTPcustom.String);
        MERPWaveViewer_plotorg{6}=str2num(gui_plotorg_waveviewer.rowgapoverlayedit.String);
        MERPWaveViewer_plotorg{7} = gui_plotorg_waveviewer.columngapgtpop.Value;
        MERPWaveViewer_plotorg{8}=str2num(gui_plotorg_waveviewer.columngapgtpcustom.String);
        MERPWaveViewer_plotorg{9}=str2num(gui_plotorg_waveviewer.columngapoverlapedit.String);
        MERPWaveViewer_plotorg{10}=gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value;
        estudioworkingmemory('MERPWaveViewer_plotorg',MERPWaveViewer_plotorg);%%save parameters for this panel to memory file
        
        assignin('base','ALLERPwaviewer',ERPwaviewerin);
        
        viewer_ERPDAT.page_xyaxis = viewer_ERPDAT.page_xyaxis+1;
        %%change the legend names based on the imported parameters
        viewer_ERPDAT.count_legend  = viewer_ERPDAT.count_legend+1;
        f_redrawERP_viewer_test();
        MessageViewer= char(strcat('Plot Organization > Load'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =2;
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
        
        MessageViewer= char(strcat('Plot Organization > Save as'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        
        ERPtooltype = erpgettoolversion('tooltype');
        if strcmpi(ERPtooltype,'EStudio')
            try
                [version1 reldate] = geterplabstudioversion;
                erplabstudiover = version1;
            catch
                erplabstudiover = '';
            end
        else
            try
                [version1 reldate] = geterplabversion;
                erplabstudiover = version1;
            catch
                erplabstudiover = '';
            end
        end
        
        
        try
            ERPwaviewerin  = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp('f_ERP_plotorg_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        
        if gui_plotorg_waveviewer.plotorg_c1.Value ==1
            GridValue=1; OverlayValue = 2; PageValue =3;
        elseif  gui_plotorg_waveviewer.plotorg_c2.Value ==1
            GridValue=1; OverlayValue = 3; PageValue =2;
        elseif  gui_plotorg_waveviewer.plotorg_c3.Value ==1
            GridValue=2; OverlayValue = 1; PageValue =3;
        elseif  gui_plotorg_waveviewer.plotorg_c4.Value ==1
            GridValue=2; OverlayValue = 3; PageValue =1;
        elseif gui_plotorg_waveviewer.plotorg_c5.Value ==1
            GridValue=3; OverlayValue = 1; PageValue =2;
        elseif gui_plotorg_waveviewer.plotorg_c6.Value ==1
            GridValue=3; OverlayValue = 2; PageValue =1;
        end
        Plot_orgpar.version = erplabstudiover;
        Plot_orgpar.Grid =GridValue;
        Plot_orgpar.Overlay = OverlayValue;
        Plot_orgpar.Pages = PageValue;
        Plot_orgpar.gridlayout.op =gui_plotorg_waveviewer.layout_auto.Value;
        Plot_orgpar.gridlayout.data =ERPwaviewerin.plot_org.gridlayout.data;
        Plot_orgpar.gridlayout.rows = gui_plotorg_waveviewer.rownum.Value;
        Plot_orgpar.gridlayout.columns = gui_plotorg_waveviewer.columnnum.Value;
        Plot_orgpar.gridlayout.columFormat = ERPwaviewerin.plot_org.gridlayout.columFormat;
        Plot_orgpar.gridlayout.rowgap.GTPOP = ERPwaviewerin.plot_org.gridlayout.rowgap.GTPOP;
        Plot_orgpar.gridlayout.rowgap.GTPValue = ERPwaviewerin.plot_org.gridlayout.rowgap.GTPValue;
        Plot_orgpar.gridlayout.rowgap.OverlayOP = ERPwaviewerin.plot_org.gridlayout.rowgap.OverlayOP;
        Plot_orgpar.gridlayout.rowgap.OverlayValue = ERPwaviewerin.plot_org.gridlayout.rowgap.OverlayValue;
        
        Plot_orgpar.gridlayout.columngap.GTPOP = ERPwaviewerin.plot_org.gridlayout.columngap.GTPOP;
        Plot_orgpar.gridlayout.columngap.GTPValue = ERPwaviewerin.plot_org.gridlayout.columngap.GTPValue;
        Plot_orgpar.gridlayout.columngap.OverlayOP = ERPwaviewerin.plot_org.gridlayout.columngap.OverlayOP;
        Plot_orgpar.gridlayout.columngap.OverlayValue = ERPwaviewerin.plot_org.gridlayout.columngap.OverlayValue;
        Plot_orgpar.gridlayout.GridLayoutAuto= ERPwaviewerin.plot_org.gridlayout.GridLayoutAuto;
        pathstr = pwd;
        namedef ='LayoutInfor';
        [erpfilename, erppathname, indxs] = uiputfile({'*.mat'}, ...
            ['Save "','Information of Plot Organization', '" as'],...
            fullfile(pathstr,namedef));
        if isequal(erpfilename,0)
            disp('User selected Cancel')
            return
        end
        %         [pathx, filename, ext] = fileparts(erpfilename);
        [pathstr, erpfilename, ext] = fileparts(erpfilename) ;
        ext = '.mat';
        erpFilename = char(strcat(erpfilename,ext));
        try
            save([erppathname,erpFilename],'Plot_orgpar','-v7.3');
        catch
            MessageViewer = ['Plot Organization > Save as: Cannot save the parameters for "Plot Organization", please try again'];
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =3;
            return;
        end
        MessageViewer= char(strcat('Plot Organization > Save as'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =2;
        
    end


%%--------------Canel changed parameters-----------------------------------
    function plotorg_cancel(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        changeFlag =  estudioworkingmemory('MyViewer_plotorg');
        if changeFlag~=1
            return;
        end
         MessageViewer= char(strcat('Plot Organization > Cancel'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        
        try
            ERPwaviewer_apply = evalin('base','ALLERPwaviewer');
        catch
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n Plot Organization > Cancel error: Cannot get parameters for whole panel.\n Please run My viewer again.\n\n');
            return;
        end
        try
            GridValue=ERPwaviewer_apply.plot_org.Grid ;
            OverlayValue=ERPwaviewer_apply.plot_org.Overlay;
            PageValue=ERPwaviewer_apply.plot_org.Pages;
        catch
            GridValue=1; OverlayValue = 2; PageValue =3;
        end
        
        try
            ALLERP = ERPwaviewer_apply.ALLERP;
            indexerp =  ERPwaviewer_apply.SelectERPIdx;
        catch
            beep;
            disp('f_ERP_plotorg_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        for Numofselectederp = 1:numel(indexerp)
            SrateNum_mp(Numofselectederp) =   ALLERP(indexerp(Numofselectederp)).srate;
        end
        if length(unique(SrateNum_mp))~=1
            gui_plotorg_waveviewer.plotorg_c2.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c4.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c5.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c6.Enable = 'off';
            if PageValue~=3
                GridValue=1; OverlayValue = 2; PageValue =3;
            end
        else
            gui_plotorg_waveviewer.plotorg_c2.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c4.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c5.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c6.Enable = 'on';
        end
        
        if   GridValue==1 && OverlayValue == 2&& PageValue ==3
            gui_plotorg_waveviewer.plotorg_c1.Value =1;
            gui_plotorg_waveviewer.plotorg_c2.Value =0;
            gui_plotorg_waveviewer.plotorg_c3.Value =0;
            gui_plotorg_waveviewer.plotorg_c4.Value =0;
            gui_plotorg_waveviewer.plotorg_c5.Value =0;
            gui_plotorg_waveviewer.plotorg_c6.Value =0;
            gui_plotorg_waveviewer.LayoutFlag = [1,0,0,0,0,0];
        elseif  GridValue==1 && OverlayValue == 3&& PageValue ==2
            gui_plotorg_waveviewer.plotorg_c1.Value =0;
            gui_plotorg_waveviewer.plotorg_c2.Value =1;
            gui_plotorg_waveviewer.plotorg_c3.Value =0;
            gui_plotorg_waveviewer.plotorg_c4.Value =0;
            gui_plotorg_waveviewer.plotorg_c5.Value =0;
            gui_plotorg_waveviewer.plotorg_c6.Value =0;
            gui_plotorg_waveviewer.LayoutFlag = [0,1,0,0,0,0];
        elseif  GridValue==2 && OverlayValue == 1 && PageValue ==3
            gui_plotorg_waveviewer.plotorg_c1.Value =0;
            gui_plotorg_waveviewer.plotorg_c2.Value =0;
            gui_plotorg_waveviewer.plotorg_c3.Value =1;
            gui_plotorg_waveviewer.plotorg_c4.Value =0;
            gui_plotorg_waveviewer.plotorg_c5.Value =0;
            gui_plotorg_waveviewer.plotorg_c6.Value =0;
            gui_plotorg_waveviewer.LayoutFlag = [0,0,1,0,0,0];
        elseif  GridValue==2 && OverlayValue == 3 && PageValue ==1
            gui_plotorg_waveviewer.plotorg_c1.Value =0;
            gui_plotorg_waveviewer.plotorg_c2.Value =0;
            gui_plotorg_waveviewer.plotorg_c3.Value =0;
            gui_plotorg_waveviewer.plotorg_c4.Value =1;
            gui_plotorg_waveviewer.plotorg_c5.Value =0;
            gui_plotorg_waveviewer.plotorg_c6.Value =0;
            gui_plotorg_waveviewer.LayoutFlag = [0,0,0,1,0,0];
        elseif GridValue==3 && OverlayValue == 1 && PageValue ==2
            gui_plotorg_waveviewer.plotorg_c1.Value =0;
            gui_plotorg_waveviewer.plotorg_c2.Value =0;
            gui_plotorg_waveviewer.plotorg_c3.Value =0;
            gui_plotorg_waveviewer.plotorg_c4.Value =0;
            gui_plotorg_waveviewer.plotorg_c5.Value =1;
            gui_plotorg_waveviewer.plotorg_c6.Value =0;
            gui_plotorg_waveviewer.LayoutFlag = [0,0,0,0,1,0];
        elseif GridValue==3 && OverlayValue == 2 && PageValue ==1
            gui_plotorg_waveviewer.plotorg_c1.Value =0;
            gui_plotorg_waveviewer.plotorg_c2.Value =0;
            gui_plotorg_waveviewer.plotorg_c3.Value =0;
            gui_plotorg_waveviewer.plotorg_c4.Value =0;
            gui_plotorg_waveviewer.plotorg_c5.Value =0;
            gui_plotorg_waveviewer.plotorg_c6.Value =1;
            gui_plotorg_waveviewer.LayoutFlag = [0,0,0,0,0,1];
        end
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
        
        if ERPwaviewer_apply.plot_org.gridlayout.GridLayoutAuto ==0
            gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value = 0;
            gui_plotorg_waveviewer.layout_custom_edit.Enable = 'off';
        else
            gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value = 1;
            gui_plotorg_waveviewer.layout_custom_edit.Enable = 'on';
        end
        
        gui_plotorg_waveviewer.columFormatStr  = '';
        estudioworkingmemory('MyViewer_plotorg',0);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [1 1 1];
        gui_plotorg_waveviewer.apply.ForegroundColor = [0 0 0];
        box_erpwave_viewer_plotorg.TitleColor= [0.5 0.5 0.9];
          MessageViewer= char(strcat('Plot Organization > Cancel'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =2;
    end



%%----------------------Apply the changed parameters-----------------------
    function plotorg_apply(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=4
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_plotorg',0);
        gui_plotorg_waveviewer.apply.BackgroundColor =  [1 1 1];
        gui_plotorg_waveviewer.apply.ForegroundColor = [0 0 0];
        box_erpwave_viewer_plotorg.TitleColor= [0.5 0.5 0.9];
        
        MessageViewer= char(strcat('Plot Organization > Apply'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
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
        
        if gui_plotorg_waveviewer.plotorg_c1.Value ==1
            GridValue=1; OverlayValue = 2; PageValue =3;
            MERPWaveViewer_plotorg{1}=1;
        elseif  gui_plotorg_waveviewer.plotorg_c2.Value ==1
            GridValue=1; OverlayValue = 3; PageValue =2;
            MERPWaveViewer_plotorg{1}=2;
        elseif  gui_plotorg_waveviewer.plotorg_c3.Value ==1
            GridValue=2; OverlayValue = 1; PageValue =3;
            MERPWaveViewer_plotorg{1}=3;
        elseif  gui_plotorg_waveviewer.plotorg_c4.Value ==1
            GridValue=2; OverlayValue = 3; PageValue =1;
            MERPWaveViewer_plotorg{1}=4;
        elseif gui_plotorg_waveviewer.plotorg_c5.Value ==1
            GridValue=3; OverlayValue = 1; PageValue =2;
            MERPWaveViewer_plotorg{1}=5;
        elseif gui_plotorg_waveviewer.plotorg_c6.Value ==1
            GridValue=3; OverlayValue = 2; PageValue =1;
            MERPWaveViewer_plotorg{1}=6;
        end
        
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERPIN,ERPsetArray);
        if GridValue ==1 %% if  the selected Channel is "Grid"
            plotArray = chanArray;
            plotArrayStr = chanStr(chanArray);
            plotArrayFormt = plotArrayStr;
        elseif GridValue == 2 %% if the selected Bin is "Grid"
            plotArray = binArray;
            plotArrayStr = binStr(binArray);
            plotArrayFormt = plotArrayStr;
        elseif GridValue == 3%% if the selected ERPset is "Grid"
            plotArray = ERPsetArray;
            for Numoferpset = 1:numel(ERPsetArray)
                plotArrayStr(Numoferpset,1) = {char(ALLERPIN(ERPsetArray(Numoferpset)).erpname)};
            end
            plotArrayFormt = plotArrayStr;
            
        else
            plotArray = chanArray;
            plotArrayStr = chanStr(chanArray);
            plotArrayFormt = plotArrayStr;
        end
        
        plotBox = f_getrow_columnautowaveplot(plotArray);%% the first element is number of rows and the second element is the number of columns
        try
            NumrowsDef = plotBox(1);
            NumcolumnsDef = plotBox(2);
        catch
            NumrowsDef = 1;
            NumcolumnsDef = 1;
        end
        
        count = 0;
        for Numofrows = 1:NumrowsDef
            for Numofcolumns = 1:NumcolumnsDef
                count = count +1;
                if count> numel(plotArray)
                    GridinforDatadef{Numofrows,Numofcolumns} = '';
                else
                    GridinforDatadef{Numofrows,Numofcolumns} = char(plotArrayStr(count));
                end
            end
        end
        
        if gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value ==0
            ERPwaviewerin.plot_org.gridlayout.rows = gui_plotorg_waveviewer.rownum.Value;
            ERPwaviewerin.plot_org.gridlayout.columns =gui_plotorg_waveviewer.columnnum.Value;
            ERPwaviewerin.plot_org.gridlayout.columFormat = plotArrayFormt';
            ERPwaviewerin.plot_org.gridlayout.data =GridinforDatadef;
        else
            EmptyItemStr = '';
            ERPwaviewerin.plot_org.gridlayout.columFormat=plotArrayFormt';
            GridinforDataOrg =  ERPwaviewerin.plot_org.gridlayout.data;
            countEmp = 0;
            for ii = 1:size(GridinforDataOrg,1)
                for jj = 1:size(GridinforDataOrg,2)
                    code = 0;
                    for kk = 1:length(plotArrayFormt)
                        if strcmp(GridinforDataOrg{ii,jj},char(plotArrayFormt(kk)))
                            code = 1;
                        end
                    end
                    if code==0
                        if ~isempty(GridinforDataOrg{ii,jj})
                            if isnumeric(GridinforDataOrg{ii,jj})
                                EmptyItemStr = strcat(EmptyItemStr,32,num2str(GridinforDataOrg{ii,jj}));
                            else
                                EmptyItemStr = strcat(EmptyItemStr,32,num2str(GridinforDataOrg{ii,jj}));
                            end
                        else
                            countEmp = countEmp+1;
                        end
                        GridinforDataOrg{ii,jj} = '';
                    end
                end
            end
            if ~isempty(EmptyItemStr)
                MessageViewer= char(strcat('Plot Organization > Apply-Undefined item(s) in grid locations:',EmptyItemStr,32,'because they donot match with the selected labels'));
                erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
                viewer_ERPDAT.Process_messg =4;
            end
            if countEmp == size(GridinforDataOrg,1)*size(GridinforDataOrg,2) || isempty(EmptyItemStr)
                EmptyItemStr = '';
                for kk = 1:length(plotArrayFormt)
                    EmptyItemStr = strcat(EmptyItemStr,32,char(plotArrayFormt(kk)));
                end
                if ~isempty(EmptyItemStr)
                    MessageViewer= char(strcat('Plot Organization > Apply-Undefined item(s) in grid locations:',EmptyItemStr,32,'because they donot match with the selected labels'));
                    erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
                    viewer_ERPDAT.Process_messg =4;
                end
            end
            
            ERPwaviewerin.plot_org.gridlayout.data =GridinforDataOrg;
            gui_plotorg_waveviewer.rownum.Value = size(GridinforDataOrg,1);
            gui_plotorg_waveviewer.columnnum.Value= size(GridinforDataOrg,2);
        end
        
        ERPwaviewerin.plot_org.Grid = GridValue;
        ERPwaviewerin.plot_org.Overlay = OverlayValue;
        ERPwaviewerin.plot_org.Pages = PageValue;
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
        ERPwaviewerin.plot_org.gridlayout.GridLayoutAuto = gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value;
        
        
        MERPWaveViewer_plotorg{2}=gui_plotorg_waveviewer.layout_auto.Value;
        plotBox(1) = gui_plotorg_waveviewer.rownum.Value;
        plotBox(2) = gui_plotorg_waveviewer.columnnum.Value;
        MERPWaveViewer_plotorg{3}=plotBox;
        MERPWaveViewer_plotorg{4}= gui_plotorg_waveviewer.rowgap_auto.Value;
        MERPWaveViewer_plotorg{5}=str2num(gui_plotorg_waveviewer.rowgapGTPcustom.String);
        MERPWaveViewer_plotorg{6}=str2num(gui_plotorg_waveviewer.rowgapoverlayedit.String);
        MERPWaveViewer_plotorg{7} = gui_plotorg_waveviewer.columngapgtpop.Value;
        MERPWaveViewer_plotorg{8}=str2num(gui_plotorg_waveviewer.columngapgtpcustom.String);
        MERPWaveViewer_plotorg{9}=str2num(gui_plotorg_waveviewer.columngapoverlapedit.String);
        MERPWaveViewer_plotorg{10}=gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value;
        estudioworkingmemory('MERPWaveViewer_plotorg',MERPWaveViewer_plotorg);%%save parameters for this panel to memory file
        
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
        indexerp =  ERPwaviewer_apply.SelectERPIdx;
        ALLERP = ERPwaviewer_apply.ALLERP;
        for Numofselectederp = 1:numel(indexerp)
            SrateNum_mp(Numofselectederp,1)   =  ALLERP(indexerp(Numofselectederp)).srate;
        end
        LayoutFlag=gui_plotorg_waveviewer.LayoutFlag;
        [~,y_Flag] = find(LayoutFlag==1);
        if numel(unique(SrateNum_mp))>1
            gui_plotorg_waveviewer.plotorg_c2.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c4.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c5.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c6.Enable = 'off';
            if  y_Flag~=1 && y_Flag~= 3
                MessageViewer= char(strcat('Sampling rate varies across ERPsets.\n We used the first option (i.e., Channels, Bins, ERPsets)'));
                erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
                viewer_ERPDAT.Process_messg =4;
                gui_plotorg_waveviewer.plotorg_c1.Value = 1;
                gui_plotorg_waveviewer.plotorg_c2.Value = 0;
                gui_plotorg_waveviewer.plotorg_c3.Value = 0;
                gui_plotorg_waveviewer.plotorg_c4.Value = 0;
                gui_plotorg_waveviewer.plotorg_c5.Value = 0;
                gui_plotorg_waveviewer.plotorg_c6.Value = 0;
                gui_plotorg_waveviewer.LayoutFlag = [1,0,0,0,0,0];
            end
        else
            gui_plotorg_waveviewer.plotorg_c2.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c4.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c5.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c6.Enable = 'on';
        end
        binArray = ERPwaviewer_apply.bin;
        chanArray = ERPwaviewer_apply.chan;
        ERPsetArray = ERPwaviewer_apply.SelectERPIdx;
        ALLERPIN = ERPwaviewer_apply.ALLERP;
        if max(ERPsetArray) >length(ALLERPIN)
            ERPsetArray =length(ALLERPIN);
            ERPwaviewer_apply.SelectERPIdx = ERPsetArray;
        end
        
        if gui_plotorg_waveviewer.plotorg_c1.Value ==1
            GridValue=1; OverlayValue = 2; PageValue =3;
        elseif  gui_plotorg_waveviewer.plotorg_c2.Value ==1
            GridValue=1; OverlayValue = 3; PageValue =2;
        elseif  gui_plotorg_waveviewer.plotorg_c3.Value ==1
            GridValue=2; OverlayValue = 1; PageValue =3;
        elseif  gui_plotorg_waveviewer.plotorg_c4.Value ==1
            GridValue=2; OverlayValue = 3; PageValue =1;
        elseif gui_plotorg_waveviewer.plotorg_c5.Value ==1
            GridValue=3; OverlayValue = 1; PageValue =2;
        elseif gui_plotorg_waveviewer.plotorg_c6.Value ==1
            GridValue=3; OverlayValue = 2; PageValue =1;
        end
        ERPwaviewer_apply.plot_org.Grid =GridValue;
        ERPwaviewer_apply.plot_org.Overlay = OverlayValue;
        ERPwaviewer_apply.plot_org.Pages = PageValue;
        
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERPIN,ERPsetArray);
        if numel(binArray)> length(binStr)
            binArray = [1:length(binStr)];
            ERPwaviewer_apply.bin = binArray;
        end
        if numel(chanArray)> length(chanStr)
            chanArray = [1:length(chanStr)];
            ERPwaviewer_apply.chan = chanArray;
        end
        
        if GridValue ==1 %% if  the selected Channel is "Grid"
            plotArray = chanArray;
            plotArrayStr = chanStr(chanArray);
            plotArrayFormt = plotArrayStr;
        elseif GridValue == 2 %% if the selected Bin is "Grid"
            plotArray = binArray;
            plotArrayStr = binStr(binArray);
            plotArrayFormt = plotArrayStr;
        elseif GridValue == 3%% if the selected ERPset is "Grid"
            plotArray = ERPsetArray;
            for Numoferpset = 1:numel(ERPsetArray)
                plotArrayStr(Numoferpset,1) = {char(ALLERPIN(ERPsetArray(Numoferpset)).erpname)};
            end
            plotArrayFormt = plotArrayStr;
        else
            plotArray = chanArray;
            plotArrayStr = chanStr(chanArray);
            plotArrayFormt = plotArrayStr;
        end
        
        plotBox = f_getrow_columnautowaveplot(plotArray);%% the first element is number of rows and the second element is the number of columns
        if gui_plotorg_waveviewer.layout_auto.Value
            try
                gui_plotorg_waveviewer.rownum.Value = plotBox(1);
                gui_plotorg_waveviewer.columnnum.Value = plotBox(2);
            catch
                gui_plotorg_waveviewer.rownum.Value=1;
                gui_plotorg_waveviewer.columnnum.Value=1;
            end
        end
        Numrows = gui_plotorg_waveviewer.rownum.Value;
        Numcolumns=gui_plotorg_waveviewer.columnnum.Value;
        count = 0;
        for Numofrows = 1:Numrows
            for Numofcolumns = 1:Numcolumns
                count = count +1;
                if count> numel(plotArray)
                    GridinforData{Numofrows,Numofcolumns} = '';
                else
                    GridinforData{Numofrows,Numofcolumns} = char(plotArrayStr(count));
                end
            end
        end
        if gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value==0
            ERPwaviewer_apply.plot_org.gridlayout.data =GridinforData;
            gui_plotorg_waveviewer.rownum.Value = size(GridinforData,1);
            gui_plotorg_waveviewer.columnnum.Value= size(GridinforData,2);
            ERPwaviewer_apply.plot_org.gridlayout.columFormat = plotArrayFormt';
        else
            EmptyItemStr = '';
            ERPwaviewer_apply.plot_org.gridlayout.columFormat=plotArrayFormt';
            GridinforDataOrg =  ERPwaviewer_apply.plot_org.gridlayout.data;
            for ii = 1:size(GridinforDataOrg,1)
                for jj = 1:size(GridinforDataOrg,2)
                    code = 0;
                    for kk = 1:length(plotArrayFormt)
                        if strcmp(GridinforDataOrg{ii,jj},char(plotArrayFormt(kk)))
                            code = 1;
                        end
                    end
                    if code==0
                        if ~isempty(GridinforDataOrg{ii,jj})
                            if isnumeric(GridinforDataOrg{ii,jj})
                                EmptyItemStr = strcat(EmptyItemStr,32,num2str(GridinforDataOrg{ii,jj}));
                            else
                                EmptyItemStr = strcat(EmptyItemStr,32,num2str(GridinforDataOrg{ii,jj}));
                            end
                        end
                        GridinforDataOrg{ii,jj} = '';
                    end
                end
            end
            
            if ~isempty(EmptyItemStr)
                MessageViewer= char(strcat('Plot Organization > v_currentERP_change() - Undefined items in grid locations:',EmptyItemStr,32,'. Because they donot match with the selected labels'));
                erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
                viewer_ERPDAT.Process_messg =4;
            end
            
            ERPwaviewer_apply.plot_org.gridlayout.data =GridinforDataOrg;
            gui_plotorg_waveviewer.rownum.Value = size(GridinforDataOrg,1);
            gui_plotorg_waveviewer.columnnum.Value= size(GridinforDataOrg,2);
        end
        ERPwaviewer_apply.plot_org.gridlayout.rows = gui_plotorg_waveviewer.rownum.Value;
        ERPwaviewer_apply.plot_org.gridlayout.columns =gui_plotorg_waveviewer.columnnum.Value;
        assignin('base','ALLERPwaviewer',ERPwaviewer_apply);
        
        %%save the parameters for this panel to memory file
        if gui_plotorg_waveviewer.plotorg_c1.Value ==1
            MERPWaveViewer_plotorg{1}=1;
        elseif  gui_plotorg_waveviewer.plotorg_c2.Value ==1
            MERPWaveViewer_plotorg{1}=2;
        elseif  gui_plotorg_waveviewer.plotorg_c3.Value ==1
            MERPWaveViewer_plotorg{1}=3;
        elseif  gui_plotorg_waveviewer.plotorg_c4.Value ==1
            MERPWaveViewer_plotorg{1}=4;
        elseif gui_plotorg_waveviewer.plotorg_c5.Value ==1
            MERPWaveViewer_plotorg{1}=5;
        elseif gui_plotorg_waveviewer.plotorg_c6.Value ==1
            MERPWaveViewer_plotorg{1}=6;
        end
        MERPWaveViewer_plotorg{2}=gui_plotorg_waveviewer.layout_auto.Value;
        plotBox(1) = gui_plotorg_waveviewer.rownum.Value;
        plotBox(2) = gui_plotorg_waveviewer.columnnum.Value;
        MERPWaveViewer_plotorg{3}=plotBox;
        MERPWaveViewer_plotorg{4}= gui_plotorg_waveviewer.rowgap_auto.Value;
        MERPWaveViewer_plotorg{5}=str2num(gui_plotorg_waveviewer.rowgapGTPcustom.String);
        MERPWaveViewer_plotorg{6}=str2num(gui_plotorg_waveviewer.rowgapoverlayedit.String);
        MERPWaveViewer_plotorg{7} = gui_plotorg_waveviewer.columngapgtpop.Value;
        MERPWaveViewer_plotorg{8}=str2num(gui_plotorg_waveviewer.columngapgtpcustom.String);
        MERPWaveViewer_plotorg{9}=str2num(gui_plotorg_waveviewer.columngapoverlapedit.String);
        MERPWaveViewer_plotorg{10}=gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value;
        estudioworkingmemory('MERPWaveViewer_plotorg',MERPWaveViewer_plotorg);%%save parameters for this panel to memory file
        
    end


%%-------------modify this panel based on updated parameters---------------
    function loadproper_change(~,~)
        if viewer_ERPDAT.loadproper_count ~=4
            return;
        end
        try
            ERPwaviewer_apply = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp('f_ERP_plotorg_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        
        try
            GridValue=ERPwaviewer_apply.plot_org.Grid ;
            OverlayValue=ERPwaviewer_apply.plot_org.Overlay;
            PageValue=ERPwaviewer_apply.plot_org.Pages;
        catch
            GridValue=1; OverlayValue = 2; PageValue =3;
        end
        
        try
            ALLERP = ERPwaviewer_apply.ALLERP;
            indexerp =  ERPwaviewer_apply.SelectERPIdx;
            ERPsetArray = ERPwaviewer_apply.SelectERPIdx;
            chanArray = ERPwaviewer_apply.chan;
            binArray = ERPwaviewer_apply.bin;
        catch
            beep;
            disp('f_ERP_plotorg_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        for Numofselectederp = 1:numel(indexerp)
            SrateNum_mp(Numofselectederp) =   ALLERP(indexerp(Numofselectederp)).srate;
        end
        if length(unique(SrateNum_mp))~=1
            gui_plotorg_waveviewer.plotorg_c2.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c4.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c5.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c6.Enable = 'off';
            if PageValue ~=3
                MessageViewer= char(strcat('Warning: Sampling rate varies across ERPsets. We used the first option'));
                erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
                viewer_ERPDAT.Process_messg =4;
                GridValue=1; OverlayValue = 2; PageValue =3;
                ERPwaviewer_apply.plot_org.Grid = 1;
                ERPwaviewer_apply.plot_org.Overlay = 2;
                ERPwaviewer_apply.plot_org.Pages = 3;
                ALLERPIN = ERPwaviewer_apply.ALLERP;
                if max(ERPsetArray) >length(ALLERPIN)
                    ERPsetArray =length(ALLERPIN);
                    ERPwaviewer_apply.SelectERPIdx = ERPsetArray;
                end
                [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERPIN,ERPsetArray);
                plotArray = chanArray;
                plotArrayStr = chanStr(chanArray);
                plotArrayFormt = plotArrayStr;
                plotBox = f_getrow_columnautowaveplot(plotArray);
                try
                    Numrows = plotBox(1);
                    Numcolumns = plotBox(2);
                catch
                    Numrows = 1;
                    Numcolumns = 1;
                end
                count = 0;
                for Numofrows = 1:Numrows
                    for Numofcolumns = 1:Numcolumns
                        count = count +1;
                        if count> numel(plotArray)
                            GridinforData{Numofrows,Numofcolumns} = '';
                        else
                            GridinforData{Numofrows,Numofcolumns} = char(plotArrayStr(count));
                        end
                    end
                end
                ERPwaviewer_apply.plot_org.gridlayout.data =GridinforData;
                ERPwaviewer_apply.plot_org.gridlayout.rows = Numrows;
                ERPwaviewer_apply.plot_org.gridlayout.columns =Numcolumns;
                ERPwaviewer_apply.plot_org.gridlayout.columFormat = plotArrayFormt';
            end
        else
            gui_plotorg_waveviewer.plotorg_c2.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c4.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c5.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c6.Enable = 'on';
        end
        
        
        if   GridValue==1 && OverlayValue == 2&& PageValue ==3
            gui_plotorg_waveviewer.plotorg_c1.Value =1;
            gui_plotorg_waveviewer.plotorg_c2.Value =0;
            gui_plotorg_waveviewer.plotorg_c3.Value =0;
            gui_plotorg_waveviewer.plotorg_c4.Value =0;
            gui_plotorg_waveviewer.plotorg_c5.Value =0;
            gui_plotorg_waveviewer.plotorg_c6.Value =0;
            gui_plotorg_waveviewer.LayoutFlag = [1,0,0,0,0,0];
        elseif  GridValue==1 && OverlayValue == 3&& PageValue ==2
            gui_plotorg_waveviewer.plotorg_c1.Value =0;
            gui_plotorg_waveviewer.plotorg_c2.Value =1;
            gui_plotorg_waveviewer.plotorg_c3.Value =0;
            gui_plotorg_waveviewer.plotorg_c4.Value =0;
            gui_plotorg_waveviewer.plotorg_c5.Value =0;
            gui_plotorg_waveviewer.plotorg_c6.Value =0;
            gui_plotorg_waveviewer.LayoutFlag = [0,1,0,0,0,0];
        elseif  GridValue==2 && OverlayValue == 1 && PageValue ==3
            gui_plotorg_waveviewer.plotorg_c1.Value =0;
            gui_plotorg_waveviewer.plotorg_c2.Value =0;
            gui_plotorg_waveviewer.plotorg_c3.Value =1;
            gui_plotorg_waveviewer.plotorg_c4.Value =0;
            gui_plotorg_waveviewer.plotorg_c5.Value =0;
            gui_plotorg_waveviewer.plotorg_c6.Value =0;
            gui_plotorg_waveviewer.LayoutFlag = [0,0,1,0,0,0];
        elseif  GridValue==2 && OverlayValue == 3 && PageValue ==1
            gui_plotorg_waveviewer.plotorg_c1.Value =0;
            gui_plotorg_waveviewer.plotorg_c2.Value =0;
            gui_plotorg_waveviewer.plotorg_c3.Value =0;
            gui_plotorg_waveviewer.plotorg_c4.Value =1;
            gui_plotorg_waveviewer.plotorg_c5.Value =0;
            gui_plotorg_waveviewer.plotorg_c6.Value =0;
            gui_plotorg_waveviewer.LayoutFlag = [0,0,0,1,0,0];
        elseif GridValue==3 && OverlayValue == 1 && PageValue ==2
            gui_plotorg_waveviewer.plotorg_c1.Value =0;
            gui_plotorg_waveviewer.plotorg_c2.Value =0;
            gui_plotorg_waveviewer.plotorg_c3.Value =0;
            gui_plotorg_waveviewer.plotorg_c4.Value =0;
            gui_plotorg_waveviewer.plotorg_c5.Value =1;
            gui_plotorg_waveviewer.plotorg_c6.Value =0;
            gui_plotorg_waveviewer.LayoutFlag = [0,0,0,0,1,0];
        elseif GridValue==3 && OverlayValue == 2 && PageValue ==1
            gui_plotorg_waveviewer.plotorg_c1.Value =0;
            gui_plotorg_waveviewer.plotorg_c2.Value =0;
            gui_plotorg_waveviewer.plotorg_c3.Value =0;
            gui_plotorg_waveviewer.plotorg_c4.Value =0;
            gui_plotorg_waveviewer.plotorg_c5.Value =0;
            gui_plotorg_waveviewer.plotorg_c6.Value =1;
            gui_plotorg_waveviewer.LayoutFlag = [0,0,0,0,0,1];
        end
        
        
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERP,ERPsetArray);
        if GridValue ==1 %% if  the selected Channel is "Grid"
            plotArray = chanArray;
            plotArrayStr = chanStr(chanArray);
            plotArrayFormtdef = plotArrayStr;
        elseif GridValue == 2 %% if the selected Bin is "Grid"
            plotArray = binArray;
            plotArrayStr = binStr(binArray);
            plotArrayFormtdef = plotArrayStr;
        elseif GridValue == 3%% if the selected ERPset is "Grid"
            plotArray = ERPsetArray;
            for Numoferpset = 1:numel(ERPsetArray)
                plotArrayStr(Numoferpset,1) = {char(ALLERPIN(ERPsetArray(Numoferpset)).erpname)};
            end
            plotArrayFormtdef = plotArrayStr;
        else
            plotArray = chanArray;
            plotArrayStr = chanStr(chanArray);
            plotArrayFormtdef = plotArrayStr;
        end
        
        plotBox = f_getrow_columnautowaveplot(plotArray);%% the first element is number of rows and the second element is the number of columns
        try
            NumrowsDef = plotBox(1);
            NumcolumnsDef = plotBox(2);
        catch
            NumrowsDef = 1;
            NumcolumnsDef = 1;
        end
        
        count = 0;
        for Numofrows = 1:NumrowsDef
            for Numofcolumns = 1:NumcolumnsDef
                count = count +1;
                if count> numel(plotArray)
                    GridinforDatadef{Numofrows,Numofcolumns} = '';
                else
                    GridinforDatadef{Numofrows,Numofcolumns} = char(plotArrayStr(count));
                end
            end
        end
        AutoValue =  ERPwaviewer_apply.plot_org.gridlayout.op;
        if AutoValue ==1
            Enable = 'off';
            gui_plotorg_waveviewer.layout_auto.Value =1;
            gui_plotorg_waveviewer.layout_custom.Value = 0;
            ERPwaviewer_apply.plot_org.gridlayout.rows =NumrowsDef;
            ERPwaviewer_apply.plot_org.gridlayout.columns = NumcolumnsDef;
            ERPwaviewer_apply.plot_org.gridlayout.rowgap.GTPOP=1;
            ERPwaviewer_apply.plot_org.gridlayout.rowgap.GTPValue=10;
            ERPwaviewer_apply.plot_org.gridlayout.rowgap.OverlayOP=0;
            ERPwaviewer_apply.plot_org.gridlayout.rowgap.OverlayValue=40;
            ERPwaviewer_apply.plot_org.gridlayout.columngap.GTPOP=1;
            ERPwaviewer_apply.plot_org.gridlayout.columngap.GTPValue=10;
            ERPwaviewer_apply.plot_org.gridlayout.columngap.OverlayOP=0;
            ERPwaviewer_apply.plot_org.gridlayout.columngap.OverlayValue=40;
        else
            Enable = 'on';
            gui_plotorg_waveviewer.layout_auto.Value =0;
            gui_plotorg_waveviewer.layout_custom.Value = 1;
            
            
        end
        try
            GridLayoutAuto = ERPwaviewer_apply.plot_org.gridlayout.GridLayoutAuto;
        catch
            GridLayoutAuto=0;
        end
        if  GridLayoutAuto==0
            ERPwaviewer_apply.plot_org.gridlayout.data = GridinforDatadef;
            ERPwaviewer_apply.plot_org.gridlayout.columFormat=plotArrayFormtdef;
            gui_plotorg_waveviewer.layout_custom_edit.Enable = 'off';
            gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value =0;
        else
            gui_plotorg_waveviewer.layout_custom_edit.Enable = 'on';
            gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value =1;
            ERPwaviewer_apply.plot_org.gridlayout.columFormat=plotArrayFormtdef;
            Datanew = ERPwaviewer_apply.plot_org.gridlayout.data;
            ERPwaviewer_apply.plot_org.gridlayout.rows =size(Datanew,1);
            ERPwaviewer_apply.plot_org.gridlayout.columns = size(Datanew,2);
            LabelUsedIndex = [];
            countlabel=0;
            EmptyItemStr ='';
            for ii = 1:size(Datanew,1)
                for jj = 1:size(Datanew,2)
                    code1 = 0;
                    for kk = 1:length(plotArrayFormtdef)
                        if strcmp(Datanew{ii,jj},plotArrayFormtdef{kk})
                            code1=1;
                        end
                    end
                    if code1==0
                        if ~isempty(Datanew{ii,jj})
                            if isnumeric(Datanew{ii,jj})
                                EmptyItemStr = strcat(EmptyItemStr,32,num2str(Datanew{ii,jj}));
                            else
                                EmptyItemStr = strcat(EmptyItemStr,32,num2str(Datanew{ii,jj}));
                            end
                        end
                        Datanew{ii,jj} = '';
                    end
                end
            end
            ERPwaviewer_apply.plot_org.gridlayout.data = Datanew;
            
            if ~isempty(EmptyItemStr)
                MessageViewer= char(strcat('Plot Organization > loadproper_change() - Undefined items in grid locations:',EmptyItemStr,32,'. Because they donot match with the selected labels'));
                erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
                viewer_ERPDAT.Process_messg =4;
            end
            
            
        end
        
        gui_plotorg_waveviewer.layout_auto.Enable ='on';
        gui_plotorg_waveviewer.layout_custom.Enable ='on';
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
        
        %%column gap and overlay
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
        assignin('base','ALLERPwaviewer',ERPwaviewer_apply);
        
        %%save the parameters for this panel to memory file
        if gui_plotorg_waveviewer.plotorg_c1.Value ==1
            MERPWaveViewer_plotorg{1}=1;
        elseif  gui_plotorg_waveviewer.plotorg_c2.Value ==1
            MERPWaveViewer_plotorg{1}=2;
        elseif  gui_plotorg_waveviewer.plotorg_c3.Value ==1
            MERPWaveViewer_plotorg{1}=3;
        elseif  gui_plotorg_waveviewer.plotorg_c4.Value ==1
            MERPWaveViewer_plotorg{1}=4;
        elseif gui_plotorg_waveviewer.plotorg_c5.Value ==1
            MERPWaveViewer_plotorg{1}=5;
        elseif gui_plotorg_waveviewer.plotorg_c6.Value ==1
            MERPWaveViewer_plotorg{1}=6;
        end
        MERPWaveViewer_plotorg{2}=gui_plotorg_waveviewer.layout_auto.Value;
        plotBox(1) = gui_plotorg_waveviewer.rownum.Value;
        plotBox(2) = gui_plotorg_waveviewer.columnnum.Value;
        MERPWaveViewer_plotorg{3}=plotBox;
        MERPWaveViewer_plotorg{4}= gui_plotorg_waveviewer.rowgap_auto.Value;
        MERPWaveViewer_plotorg{5}=str2num(gui_plotorg_waveviewer.rowgapGTPcustom.String);
        MERPWaveViewer_plotorg{6}=str2num(gui_plotorg_waveviewer.rowgapoverlayedit.String);
        MERPWaveViewer_plotorg{7} = gui_plotorg_waveviewer.columngapgtpop.Value;
        MERPWaveViewer_plotorg{8}=str2num(gui_plotorg_waveviewer.columngapgtpcustom.String);
        MERPWaveViewer_plotorg{9}=str2num(gui_plotorg_waveviewer.columngapoverlapedit.String);
        MERPWaveViewer_plotorg{10}=gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value;
        estudioworkingmemory('MERPWaveViewer_plotorg',MERPWaveViewer_plotorg);%%save parameters for this panel to memory file
        
        viewer_ERPDAT.loadproper_count =5;
    end



%%-------------------------------------------------------------------------
%%Automatically saving the changed parameters for the current panel if the
%%user change parameters for the other panels.
%%-------------------------------------------------------------------------
    function count_twopanels_change(~,~)
        if viewer_ERPDAT.count_twopanels==0
            return;
        end
        changeFlag =  estudioworkingmemory('MyViewer_plotorg');
        if changeFlag~=1
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
        ERPsetArray = ERPwaviewerin.SelectERPIdx;
        ALLERPIN = ERPwaviewerin.ALLERP;
        if max(ERPsetArray) >length(ALLERPIN)
            ERPsetArray =length(ALLERPIN);
        end
        for ii = 1:numel(ERPsetArray)
            Srates(ii) =  ALLERPIN(ERPsetArray(ii)).srate;
        end
        LayoutFlag=gui_plotorg_waveviewer.LayoutFlag;
        [~,y_Flag] = find(LayoutFlag==1);
        if numel(unique(Srates))~=1%%If the sampling rate varies across ERPsets, ERPsets must be "Pages".
            gui_plotorg_waveviewer.plotorg_c2.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c4.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c5.Enable = 'off';
            gui_plotorg_waveviewer.plotorg_c6.Enable = 'off';
            if  y_Flag~=1 && y_Flag~= 3
                MessageViewer= char(strcat('Warning: Sampling rate varies across ERPsets. We used the first option'));
                erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
                viewer_ERPDAT.Process_messg =4;
                gui_plotorg_waveviewer.plotorg_c1.Value = 1;
                gui_plotorg_waveviewer.plotorg_c2.Value = 0;
                gui_plotorg_waveviewer.plotorg_c3.Value = 0;
                gui_plotorg_waveviewer.plotorg_c4.Value = 0;
                gui_plotorg_waveviewer.plotorg_c5.Value = 0;
                gui_plotorg_waveviewer.plotorg_c6.Value = 0;
                gui_plotorg_waveviewer.LayoutFlag = [1,0,0,0,0,0];
                ERPwaviewerin.plot_org.Grid = 1;
                ERPwaviewerin.plot_org.Overlay = 2;
                ERPwaviewerin.plot_org.Pages = 3;
                assignin('base','ALLERPwaviewer',ERPwaviewerin);
            end
        else
            gui_plotorg_waveviewer.plotorg_c2.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c4.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c5.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c6.Enable = 'on';
        end
        plotorg_apply();
    end


%%-------------------------------------------------------------------------
%%-----------------Reset this panel with the default parameters------------
%%-------------------------------------------------------------------------
    function Reset_Waviewer_panel_change(~,~)
        if viewer_ERPDAT.Reset_Waviewer_panel==4
            try
                ERPwaviewerin = evalin('base','ALLERPwaviewer');
                ALLERP = ERPwaviewerin.ALLERP;
                indexerp =  ERPwaviewerin.SelectERPIdx;
            catch
                beep;
                disp('f_ERP_plotorg_waveviewer_GUI error: Restart ERPwave Viewer');
                return;
            end
            gui_plotorg_waveviewer.plotorg_c1.Value = 1;
            gui_plotorg_waveviewer.plotorg_c2.Value = 0;
            gui_plotorg_waveviewer.plotorg_c3.Value = 0;
            gui_plotorg_waveviewer.plotorg_c4.Value = 0;
            gui_plotorg_waveviewer.plotorg_c5.Value = 0;
            gui_plotorg_waveviewer.plotorg_c6.Value = 0;
            gui_plotorg_waveviewer.LayoutFlag = [1,0,0,0,0,0];
            ERPwaviewerin.plot_org.Grid = 1;
            ERPwaviewerin.plot_org.Overlay = 2;
            ERPwaviewerin.plot_org.Pages = 3;
            estudioworkingmemory('OverlayIndex',1);
            %%check sampling rate and data type
            for Numofselectederp = 1:numel(indexerp)
                SrateNum_mp(Numofselectederp,1)   =  ALLERP(indexerp(Numofselectederp)).srate;
                Datype{Numofselectederp} =   ALLERP(indexerp(Numofselectederp)).datatype;
            end
            if length(unique(Datype))~=1 || (numel(indexerp)==1 && strcmpi(char(Datype),'ERP')~=1)
                MessageViewer= char(strcat('Warning: Type of data varies across ERPsets. We only plot waves for ERPset'));
                erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
                viewer_ERPDAT.Process_messg =4;
                return;
            end
            gui_plotorg_waveviewer.plotorg_c2.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c4.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c5.Enable = 'on';
            gui_plotorg_waveviewer.plotorg_c6.Enable = 'on';
            ERPwaviewerin.plot_org.gridlayout.op = 1;
            gui_plotorg_waveviewer.layout_auto.Value =1;
            gui_plotorg_waveviewer.layout_custom.Value =0;
            %%row and column numbers
            plotArray =  ERPwaviewerin.chan;
            if isempty(plotArray)
                plotArray   = [1:ERPwaviewerin.ERP.nchan];
            end
            plotBox = f_getrow_columnautowaveplot(plotArray);
            try
                NumrowsDef = plotBox(1);
                NumcolumnsDef = plotBox(2);
            catch
                NumrowsDef = 1;
                NumcolumnsDef = 1;
            end
            gui_plotorg_waveviewer.rownum.Value=NumrowsDef;
            gui_plotorg_waveviewer.columnnum.Value=NumcolumnsDef;
            gui_plotorg_waveviewer.rownum.Enable='off';
            gui_plotorg_waveviewer.columnnum.Enable='off';
            
            ERPwaviewerin.plot_org.gridlayout.rows = NumrowsDef;
            ERPwaviewerin.plot_org.gridlayout.columns=NumcolumnsDef;
            ERPsetArray = ERPwaviewerin.SelectERPIdx;
            ALLERPIN = ERPwaviewerin.ALLERP;
            if max(ERPsetArray) >length(ALLERPIN)
                ERPsetArray =length(ALLERPIN);
            end
            [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERPIN,ERPsetArray);
            plotArrayStr = chanStr(plotArray);
            count = 0;
            for Numofrows = 1:NumrowsDef
                for Numofcolumns = 1:NumcolumnsDef
                    count = count +1;
                    if count> numel(plotArray)
                        GridinforData{Numofrows,Numofcolumns} = '';
                    else
                        GridinforData{Numofrows,Numofcolumns} = char(plotArrayStr(count));
                    end
                end
            end
            ERPwaviewerin.plot_org.gridlayout.data =GridinforData;
            plotArrayFormt = plotArrayStr;
            ERPwaviewerin.plot_org.gridlayout.columFormat = plotArrayFormt';
            %%Grid spacing
            gui_plotorg_waveviewer.rowgap_auto.Value =1;
            gui_plotorg_waveviewer.rowgapGTPcustom.String = '10';
            gui_plotorg_waveviewer.rowoverlap.Value = 0;
            gui_plotorg_waveviewer.rowgapoverlayedit.String = '40';
            gui_plotorg_waveviewer.columngapgtpop.Value =1;
            gui_plotorg_waveviewer.columngapgtpcustom.String = '10';
            gui_plotorg_waveviewer.columnoverlay.Value=0;
            gui_plotorg_waveviewer.columngapoverlapedit.String = '40';
            gui_plotorg_waveviewer.rowgap_auto.Enable ='off';
            gui_plotorg_waveviewer.rowgapGTPcustom.Enable ='off';
            gui_plotorg_waveviewer.rowoverlap.Enable ='off';
            gui_plotorg_waveviewer.rowgapoverlayedit.Enable ='off';
            gui_plotorg_waveviewer.columngapgtpop.Enable ='off';
            gui_plotorg_waveviewer.columngapgtpcustom.Enable ='off';
            gui_plotorg_waveviewer.columnoverlay.Enable ='off';
            gui_plotorg_waveviewer.columngapoverlapedit.Enable ='off';
            
            ERPwaviewerin.plot_org.gridlayout.rowgap.GTPOP = gui_plotorg_waveviewer.rowgap_auto.Value;
            ERPwaviewerin.plot_org.gridlayout.rowgap.GTPValue = str2num(gui_plotorg_waveviewer.rowgapGTPcustom.String);
            ERPwaviewerin.plot_org.gridlayout.rowgap.OverlayOP = gui_plotorg_waveviewer.rowoverlap.Value;
            ERPwaviewerin.plot_org.gridlayout.rowgap.OverlayValue = str2num(gui_plotorg_waveviewer.rowgapoverlayedit.String);
            ERPwaviewerin.plot_org.gridlayout.columngap.GTPOP = gui_plotorg_waveviewer.columngapgtpop.Value;
            ERPwaviewerin.plot_org.gridlayout.columngap.GTPValue = str2num(gui_plotorg_waveviewer.columngapgtpcustom.String);
            ERPwaviewerin.plot_org.gridlayout.columngap.OverlayOP = gui_plotorg_waveviewer.columnoverlay.Value;
            ERPwaviewerin.plot_org.gridlayout.columngap.OverlayValue = str2num(gui_plotorg_waveviewer.columngapoverlapedit.String);
            
            gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value=0; %,'HorizontalAlignment','left'
            gui_plotorg_waveviewer.layout_custom_edit.Enable='off';
            
            assignin('base','ALLERPwaviewer',ERPwaviewerin);
            
            %%Using the default background color for "apply" and title bar
            gui_plotorg_waveviewer.apply.BackgroundColor =  [1 1 1];
            gui_plotorg_waveviewer.apply.ForegroundColor = [0 0 0];
            box_erpwave_viewer_plotorg.TitleColor= [0.5 0.5 0.9];
            
            %%save the parameters for this panel to memory file
            MERPWaveViewer_plotorg{1}=1;
            MERPWaveViewer_plotorg{2}=gui_plotorg_waveviewer.layout_auto.Value;
            plotBox(1) = gui_plotorg_waveviewer.rownum.Value;
            plotBox(2) = gui_plotorg_waveviewer.columnnum.Value;
            MERPWaveViewer_plotorg{3}=plotBox;
            MERPWaveViewer_plotorg{4}= gui_plotorg_waveviewer.rowgap_auto.Value;
            MERPWaveViewer_plotorg{5}=str2num(gui_plotorg_waveviewer.rowgapGTPcustom.String);
            MERPWaveViewer_plotorg{6}=str2num(gui_plotorg_waveviewer.rowgapoverlayedit.String);
            MERPWaveViewer_plotorg{7} = gui_plotorg_waveviewer.columngapgtpop.Value;
            MERPWaveViewer_plotorg{8}=str2num(gui_plotorg_waveviewer.columngapgtpcustom.String);
            MERPWaveViewer_plotorg{9}=str2num(gui_plotorg_waveviewer.columngapoverlapedit.String);
            MERPWaveViewer_plotorg{10}=gui_plotorg_waveviewer.layout_custom_edit_checkbox.Value;
            estudioworkingmemory('MERPWaveViewer_plotorg',MERPWaveViewer_plotorg);%%save parameters for this panel to memory file
            
            %%execute next panel
            viewer_ERPDAT.Reset_Waviewer_panel=5;
        end
    end%%end of reset


    function plotorg_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        if strcmp (keypress, 'return') || strcmp (keypress, 'enter')
            plotorg_apply();
            estudioworkingmemory('MyViewer_plotorg',0);
            gui_plotorg_waveviewer.apply.BackgroundColor =  [1 1 1];
            gui_plotorg_waveviewer.apply.ForegroundColor = [0 0 0];
            box_erpwave_viewer_plotorg.TitleColor= [0.5 0.5 0.9];
        else
            return;
        end
    end
end