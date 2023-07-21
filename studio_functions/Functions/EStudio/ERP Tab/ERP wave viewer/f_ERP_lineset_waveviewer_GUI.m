%%This function is to plot the panel for "Viewer properties".

% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022


function varargout = f_ERP_lineset_waveviewer_GUI(varargin)

global viewer_ERPDAT;
addlistener(viewer_ERPDAT,'legend_change',@legend_change);
addlistener(viewer_ERPDAT,'page_xyaxis_change',@page_xyaxis_change);
addlistener(viewer_ERPDAT,'loadproper_change',@loadproper_change);
addlistener(viewer_ERPDAT,'v_currentERP_change',@v_currentERP_change);
addlistener(viewer_ERPDAT,'count_twopanels_change',@count_twopanels_change);
addlistener(viewer_ERPDAT,'Reset_Waviewer_panel_change',@Reset_Waviewer_panel_change);


gui_erplinset_waveviewer = struct();

%-----------------------------Name the title----------------------------------------------
% global box_erplineset_viewer_property;

[version reldate,ColorB_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    box_erplineset_viewer_property = uiextras.BoxPanel('Parent', fig, 'Title', 'Lines & Legends', 'Padding', 5,...
        'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w','FontSize', 12); % Create boxpanel
elseif nargin == 1
    box_erplineset_viewer_property = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Lines & Legends', 'Padding', 5,...
        'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w');%[0.7765,0.7294,0.8627]
else
    box_erplineset_viewer_property = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Lines & Legends', 'Padding', 5, ...
        'FontSize', varargin{2},'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w');
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
drawui_lineset_property(FonsizeDefault);
varargout{1} = box_erplineset_viewer_property;

    function drawui_lineset_property(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
        try
            ERPwaviewer = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp('f_ERP_lineset_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        
        %%--------------------channel and bin setting----------------------
        gui_erplinset_waveviewer.DataSelBox = uiextras.VBox('Parent', box_erplineset_viewer_property,'BackgroundColor',ColorBviewer_def);
        %%-----------------Setting for Auto-------
        MERPWaveViewer_linelegend= estudioworkingmemory('MERPWaveViewer_linelegend');%%call the parameters for this panel
        try
            linAutoValue= MERPWaveViewer_linelegend{1};
        catch
            linAutoValue = 1;
            MERPWaveViewer_linelegend{1}=1;
        end
        if isempty(linAutoValue) ||numel(linAutoValue)~=1 || (linAutoValue~=0 && linAutoValue~=1)
            linAutoValue = 1;
            MERPWaveViewer_linelegend{1}=1;
        end
        if linAutoValue ==1
            DataEnable = 'off';
        else
            DataEnable = 'on';
        end
        gui_erplinset_waveviewer.parameters_title = uiextras.HBox('Parent', gui_erplinset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_erplinset_waveviewer.parameters_title,'String','Lines:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left','FontWeight','bold'); %
        
        gui_erplinset_waveviewer.linesauto = uicontrol('Style','radiobutton','Parent', gui_erplinset_waveviewer.parameters_title,'String','Auto',...
            'callback',@lines_auto,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',linAutoValue); %
        gui_erplinset_waveviewer.linesauto.KeyPressFcn = @line_presskey;
        gui_erplinset_waveviewer.linescustom = uicontrol('Style','radiobutton','Parent', gui_erplinset_waveviewer.parameters_title,'String','Custom',...
            'callback',@lines_custom,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',~linAutoValue); %
        gui_erplinset_waveviewer.linescustom.KeyPressFcn = @line_presskey;
        set(gui_erplinset_waveviewer.parameters_title,'Sizes',[60 70 70]);
        
        %%-----------Setting for line table-----------------------------
        gui_erplinset_waveviewer.line_customtable_title = uiextras.HBox('Parent', gui_erplinset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        try
            plot_org = ERPwaviewer.plot_org;
            if plot_org.Grid ==1
                GridNum = numel(ERPwaviewer.chan);
            elseif plot_org.Grid ==2
                GridNum = numel(ERPwaviewer.bin);
            elseif plot_org.Grid ==3
                GridNum = numel(ERPwaviewer.SelectERPIdx);
            else
                GridNum = numel(ERPwaviewer.chan);
            end
        catch
            GridNum = [];
        end
        [lineNameStr,linecolors,linetypes,linewidths,linecolors_str,linetypes_str,linewidths_str,linecolorsrgb] = f_get_lineset_ERPviewer();
        if linAutoValue
            lineset_str  =table(lineNameStr,linecolors,linetypes,linewidths);
            lineset_strdef = table2cell(lineset_str);
        else
            lineset_str  =table(lineNameStr,linecolorsrgb,linetypes,linewidths);
            lineset_strdef = table2cell(lineset_str);
        end
        try
            lineset_str= MERPWaveViewer_linelegend{2};
        catch
            lineset_str = lineset_strdef;
            MERPWaveViewer_linelegend{2}=lineset_str;
        end
        gui_erplinset_waveviewer.line_customtable = uitable(gui_erplinset_waveviewer.line_customtable_title);
        gui_erplinset_waveviewer.line_customtable.ColumnFormat = {'char', 'char',...
            {'solid','dash','dot','dashdot','plus','circle','asterisk'},...
            {'0.25','0.5','1','1.5','2','2.5','3','3.5','4','4.5','5','5.5','6','6.5','7','7.5','8','8.5','9','9.5','10','10.5'}};
        gui_erplinset_waveviewer.line_customtable.Data = lineset_str;
        gui_erplinset_waveviewer.line_customtable.ColumnEditable = [false, true,true,true];
        gui_erplinset_waveviewer.line_customtable.FontSize = FonsizeDefault;
        gui_erplinset_waveviewer.line_customtable.ColumnName = {'<html><font size=3 >#','<html><font size= 3>Color','<html><font size=3 >Style', '<html><font size=3 >Width'};
        gui_erplinset_waveviewer.line_customtable.Enable = DataEnable;
        gui_erplinset_waveviewer.line_customtable.BackgroundColor = [1 1 1;1 1 1];
        gui_erplinset_waveviewer.line_customtable.RowName = [];
        gui_erplinset_waveviewer.line_customtable.ColumnWidth = {25 80 65 50};
        gui_erplinset_waveviewer.line_customtable.CellEditCallback  = @line_customtable;
        gui_erplinset_waveviewer.line_customtable.KeyPressFcn = @line_presskey;
        %%setting for uitable: https://undocumentedmatlab.com/artiALLERPwaviewercles/multi-line-uitable-column-headers
        if gui_erplinset_waveviewer.linesauto.Value ==1
            gui_erplinset_waveviewer.line_customtable.Enable = 'off';
        else
            gui_erplinset_waveviewer.line_customtable.Enable = 'on';
        end
        ERPwaviewer.Lines.auto =gui_erplinset_waveviewer.linesauto.Value;
        ERPwaviewer.Lines.data =gui_erplinset_waveviewer.line_customtable.Data;
        
        
        %%-----------Setting for legend table -----------------------------
        %         gui_erplinset_waveviewer.legend_customtable_title = uiextras.HBox('Parent', gui_erplinset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        for ii = 1:100
            LegendName{ii,1} = '';
            LegendNamenum(ii,1) =ii;
        end
        ALLERPIN = ERPwaviewer.ALLERP;
        ERPsetArray = ERPwaviewer.SelectERPIdx;
        if max(ERPsetArray(:))> length(ALLERPIN)
            ERPsetArray =length(ALLERPIN);
        end
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERPIN,ERPsetArray);
        try
            plot_org = ERPwaviewer.plot_org;
            ERPIN = ERPwaviewer.ERP;
            if plot_org.Overlay ==1
                ChanArray = ERPwaviewer.chan;
                for Numofchan = 1:numel(ChanArray)
                    LegendName{Numofchan,1} = char(chanStr(ChanArray(Numofchan)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
                LegendArray = ChanArray;
            elseif plot_org.Overlay ==2
                binArray = ERPwaviewer.bin;
                for Numofbin = 1:numel(binArray)
                    LegendName{Numofbin,1} = char(binStr(binArray(Numofbin)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
                LegendArray = binArray;
            elseif plot_org.Overlay ==3
                ALLERP = ERPwaviewer.ALLERP;
                ERPsetArray = ERPwaviewer.SelectERPIdx;
                for Numoferpset = 1:numel(ERPsetArray)
                    LegendName{Numoferpset,1} = char(ALLERP(Numoferpset).erpname);
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
                LegendArray = ERPsetArray;
            else
                binArray = ERPwaviewer.bin;
                for Numofbin = 1:numel(binArray)
                    LegendName{Numofbin,1} = char(binStr(binArray(Numofbin)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
                LegendArray = binArray;
            end
        catch
            legendset_str = table(LegendNamenum,LegendName);
            legendset_str = table2cell(legendset_str);
        end
        ERPwaviewer.Legend.data = legendset_str;
        
        %
        %%--------------------legend font and font size---------------------------
        gui_erplinset_waveviewer.fontcolor_title = uiextras.HBox('Parent', gui_erplinset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_erplinset_waveviewer.fontcolor_title,'String','Legend:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left','FontWeight','bold'); %
        try
            fontcolorAuto=MERPWaveViewer_linelegend{3};
        catch
            fontcolorAuto=1;
            MERPWaveViewer_linelegend{3}=1;
        end
        if isempty(fontcolorAuto) || numel(fontcolorAuto)~=1 || (fontcolorAuto~=0 && fontcolorAuto~=1)
            fontcolorAuto=1;
            MERPWaveViewer_linelegend{3}=1;
        end
        gui_erplinset_waveviewer.font_colorauto = uicontrol('Style','radiobutton','Parent',gui_erplinset_waveviewer.fontcolor_title,'String','Auto',...
            'callback',@font_color_auto,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',fontcolorAuto); %
        gui_erplinset_waveviewer.font_colorauto.KeyPressFcn = @line_presskey;
        gui_erplinset_waveviewer.font_colorcustom = uicontrol('Style','radiobutton','Parent', gui_erplinset_waveviewer.fontcolor_title,'String','Custom',...
            'callback',@font_color_custom,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',~fontcolorAuto); %
        gui_erplinset_waveviewer.font_colorcustom.KeyPressFcn = @line_presskey;
        set(gui_erplinset_waveviewer.fontcolor_title,'Sizes',[60 70 70]);
        ERPwaviewer.Legend.FontColorAuto = gui_erplinset_waveviewer.font_colorauto.Value;
        if gui_erplinset_waveviewer.font_colorauto.Value==1
            fontEnable = 'off';
        else
            fontEnable = 'on';
        end
        
        gui_erplinset_waveviewer.labelfont_title = uiextras.HBox('Parent', gui_erplinset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        
        try
            fontDef =  MERPWaveViewer_linelegend{4};
        catch
            fontDef = 3;
            MERPWaveViewer_linelegend{4}=3;
        end
        if isempty(fontDef) ||  numel(fontDef)~=1 || fontDef<1 || fontDef>5
            fontDef = 3;
            MERPWaveViewer_linelegend{4}=3;
        end
        fontsize  = {'4','6','8','10','12','14','16','18','20','24','28','32','36',...
            '40','50','60','70','80','90','100'};
        labelfontsizeinum = str2num(char(fontsize));
        try
            LabelfontsizeValue =  MERPWaveViewer_linelegend{5};
        catch
            LabelfontsizeValue = 4;
            MERPWaveViewer_linelegend{5}=4;
        end
        if isempty(LabelfontsizeValue) ||  numel(LabelfontsizeValue)~=1 || LabelfontsizeValue<1 || LabelfontsizeValue>20
            LabelfontsizeValue = 4;
            MERPWaveViewer_linelegend{5}=4;
        end
        
        uicontrol('Style','text','Parent', gui_erplinset_waveviewer.labelfont_title ,'String','Font',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); %
        fonttype = {'Courier','Geneva','Helvetica','Monaco','Times'};
        gui_erplinset_waveviewer.font_custom_type = uicontrol('Style','popupmenu','Parent', gui_erplinset_waveviewer.labelfont_title ,'String',fonttype,...
            'callback',@legendfont,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Value',fontDef,'Enable',fontEnable); %
        gui_erplinset_waveviewer.font_custom_type.KeyPressFcn = @line_presskey;
        uicontrol('Style','text','Parent', gui_erplinset_waveviewer.labelfont_title ,'String','Size',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); %
        gui_erplinset_waveviewer.font_custom_size = uicontrol('Style','popupmenu','Parent', gui_erplinset_waveviewer.labelfont_title ,'String',fontsize,...
            'callback',@legendfontsize,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Value',LabelfontsizeValue,'Enable',fontEnable); %
        gui_erplinset_waveviewer.font_custom_size.KeyPressFcn = @line_presskey;
        set(gui_erplinset_waveviewer.labelfont_title,'Sizes',[30 110 30 70]);
        ERPwaviewer.Legend.font = gui_erplinset_waveviewer.font_custom_type.Value;
        ERPwaviewer.Legend.fontsize = labelfontsizeinum(gui_erplinset_waveviewer.font_custom_size.Value);
        
        
        %%----------------------------Legend textcolor---------------------
        try
            legendtextcolorAuto=  MERPWaveViewer_linelegend{6};
        catch
            legendtextcolorAuto =1;
            MERPWaveViewer_linelegend{6} =1;
        end
        if isempty(legendtextcolorAuto) || numel(legendtextcolorAuto)~=1 || (legendtextcolorAuto~=0 && legendtextcolorAuto~=1)
            legendtextcolorAuto =1;
            MERPWaveViewer_linelegend{6} =1;
        end
        if isempty(legendtextcolorAuto) || numel(legendtextcolorAuto)~=1 || (legendtextcolorAuto~=0 && legendtextcolorAuto~=1)
            legendtextcolorAuto =1;
            MERPWaveViewer_linelegend{6} =1;
        end
        gui_erplinset_waveviewer.legend_textitle = uiextras.HBox('Parent', gui_erplinset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_erplinset_waveviewer.legend_textitle,'String','Text color',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left'); %
        gui_erplinset_waveviewer.legendtextauto = uicontrol('Style','radiobutton','Parent', gui_erplinset_waveviewer.legend_textitle,'String','Auto',...
            'callback',@legendtextauto,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',legendtextcolorAuto,'Enable',fontEnable); %
        gui_erplinset_waveviewer.legendtextauto.KeyPressFcn = @line_presskey;
        gui_erplinset_waveviewer.legendtextcustom = uicontrol('Style','radiobutton','Parent',gui_erplinset_waveviewer.legend_textitle,'String','Same as lines',...
            'callback',@legendtextcustom,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',~legendtextcolorAuto,'Enable',fontEnable,'HorizontalAlignment','left'); %
        gui_erplinset_waveviewer.legendtextcustom.KeyPressFcn = @line_presskey;
        set(gui_erplinset_waveviewer.legend_textitle,'Sizes',[70 60 150]);
        ERPwaviewer.Legend.textcolor = gui_erplinset_waveviewer.legendtextauto.Value;
        
        %%------------------------Legend columns---------------------------
        legendcolumnsdef =  round(sqrt( length(LegendArray)));
        try
            legendcolumns= MERPWaveViewer_linelegend{7};
        catch
            legendcolumns =legendcolumnsdef;
            MERPWaveViewer_linelegend{7}=legendcolumnsdef;
        end
        if isempty(legendcolumns) || numel(legendcolumns)~=1 ||legendcolumns<1 || legendcolumns>100
            legendcolumns =legendcolumnsdef;
            MERPWaveViewer_linelegend{7}=legendcolumnsdef;
        end
        if fontcolorAuto==1
            legendcolumns =legendcolumnsdef;
            MERPWaveViewer_linelegend{7}=legendcolumnsdef;
        end
        gui_erplinset_waveviewer.legend_columnstitle = uiextras.HBox('Parent', gui_erplinset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_erplinset_waveviewer.legend_columnstitle,'String','Columns',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left'); %
        for Numoflegend = 1:100
            columnStr{Numoflegend} = num2str(Numoflegend);
        end
        gui_erplinset_waveviewer.legendcolumns = uicontrol('Style','popupmenu','Parent', gui_erplinset_waveviewer.legend_columnstitle,'String',columnStr,...
            'callback',@legendcolumns,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Value',legendcolumns,'Enable',fontEnable); %
        gui_erplinset_waveviewer.legendcolumns.KeyPressFcn = @line_presskey;
        uiextras.Empty('Parent', gui_erplinset_waveviewer.legend_columnstitle );
        set(gui_erplinset_waveviewer.legend_columnstitle,'Sizes',[60 100 70]);
        ERPwaviewer.Legend.columns = gui_erplinset_waveviewer.legendcolumns.Value;
        
        
        %%-------------------------help and apply--------------------------
        gui_erplinset_waveviewer.help_apply_title = uiextras.HBox('Parent', gui_erplinset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uiextras.Empty('Parent',gui_erplinset_waveviewer.help_apply_title );
        uicontrol('Style','pushbutton','Parent', gui_erplinset_waveviewer.help_apply_title  ,'String','Cancel',...
            'callback',@linelegend_help,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %,'FontWeight','bold','HorizontalAlignment','left'
        uiextras.Empty('Parent',gui_erplinset_waveviewer.help_apply_title  );
        gui_erplinset_waveviewer.apply = uicontrol('Style','pushbutton','Parent',gui_erplinset_waveviewer.help_apply_title  ,'String','Apply',...
            'callback',@LineLegend_apply,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %,'HorizontalAlignment','left'
        uiextras.Empty('Parent',gui_erplinset_waveviewer.help_apply_title  );
        set(gui_erplinset_waveviewer.help_apply_title ,'Sizes',[40 70 20 70 20]);
        
        set(gui_erplinset_waveviewer.DataSelBox ,'Sizes',[20 200 20 25 25 25 25]);
        assignin('base','ALLERPwaviewer',ERPwaviewer);
        estudioworkingmemory('MERPWaveViewer_linelegend',MERPWaveViewer_linelegend);
    end

%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%-------------------------Setting for load--------------------------------
    function lines_auto(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();%%check if the changes were applied for the other panels
        if ~isempty(messgStr) && viewerpanelIndex~=6
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_linelegend',1);
        gui_erplinset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560]; %%mark the changes
        gui_erplinset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erplineset_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_erplinset_waveviewer.linesauto.Value =1;
        gui_erplinset_waveviewer.linescustom.Value = 0;
        gui_erplinset_waveviewer.line_customtable.Enable = 'off';
        try
            ALLERPwaviewer = evalin('base','ALLERPwaviewer');
            ERPwaviewer = ALLERPwaviewer;
        catch
            beep;
            disp('f_ERP_lineset_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        try
            plot_org = ERPwaviewer.plot_org;
            if plot_org.Grid ==1
                GridNum = numel(ERPwaviewer.chan);
            elseif plot_org.Grid ==2
                GridNum = numel(ERPwaviewer.bin);
            elseif plot_org.Grid ==3
                GridNum = numel(ERPwaviewer.SelectERPIdx);
                
            else
                GridNum = numel(ERPwaviewer.chan);
            end
        catch
            GridNum = [];
        end
        [lineNameStr,linecolors,linetypes,linewidths,linecolors_str,linetypes_str,linewidths_str,linecolorsrgb] = f_get_lineset_ERPviewer();
        lineset_str  =table(lineNameStr,linecolors,linetypes,linewidths);
        lineset_str = table2cell(lineset_str);
        gui_erplinset_waveviewer.line_customtable.ColumnFormat = {'char', 'char',...
            {'solid','dash','dot','dashdot','plus','circle','asterisk'},...
            {'0.25','0.5','1','1.5','2','2.5','3','3.5','4','4.5','5','5.5','6','6.5','7','7.5','8','8.5','9','9.5','10','10.5'}};
        gui_erplinset_waveviewer.line_customtable.Data = lineset_str;
    end

%%-------------------------Setting for Save--------------------------------
    function lines_custom(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();%%check if the changes were applied for the other panels
        if ~isempty(messgStr) && viewerpanelIndex~=6
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_linelegend',1);
        gui_erplinset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560]; %%mark the changes
        gui_erplinset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erplineset_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_erplinset_waveviewer.linesauto.Value =0;
        gui_erplinset_waveviewer.linescustom.Value = 1;
        gui_erplinset_waveviewer.line_customtable.Enable = 'on';
        [lineNameStr,linecolors,linetypes,linewidths,linecolors_str,linetypes_str,linewidths_str,linecolorsrgb] = f_get_lineset_ERPviewer();
        lineset_str  =table(lineNameStr,linecolorsrgb,linetypes,linewidths);
        lineset_str = table2cell(lineset_str);
        gui_erplinset_waveviewer.line_customtable.ColumnFormat = {'char', 'char',...
            {'solid','dash','dot','dashdot','plus','circle','asterisk'},...
            {'0.25','0.5','1','1.5','2','2.5','3','3.5','4','4.5','5','5.5','6','6.5','7','7.5','8','8.5','9','9.5','10','10.5'}};
        for ii = 1:length(linecolorsrgb)
            gui_erplinset_waveviewer.line_customtable.Data{ii,2} = linecolorsrgb{ii};
        end
    end

%%-------------------------Setting for Save as--------------------------------
    function line_customtable(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();%%check if the changes were applied for the other panels
        if ~isempty(messgStr) && viewerpanelIndex~=6
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_linelegend',1);
        gui_erplinset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560]; %%mark the changes
        gui_erplinset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erplineset_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
    end



%%Auto for  font, fontsize, color, columns for legend
    function font_color_auto(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();%%check if the changes were applied for the other panels
        if ~isempty(messgStr) && viewerpanelIndex~=6
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_linelegend',1);
        gui_erplinset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560]; %%mark the changes
        gui_erplinset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erplineset_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        try
            ERPwaviewer = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp(' Line & Legends> Legend Auto error: Please run the ERP wave viewer again.');
            return;
        end
        ALLERPIN = ERPwaviewer.ALLERP;
        ERPsetArray = ERPwaviewer.SelectERPIdx;
        if max(ERPsetArray(:))> length(ALLERPIN)
            ERPsetArray =length(ALLERPIN);
        end
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERPIN,ERPsetArray);
        plot_org = ERPwaviewer.plot_org;
        if plot_org.Overlay ==1
            LegendArray = ERPwaviewer.chan;
        elseif plot_org.Overlay ==2
            LegendArray = ERPwaviewer.bin;
        elseif plot_org.Overlay ==3
            LegendArray = ERPwaviewer.SelectERPIdx;
        else
            LegendArray = ERPwaviewer.bin;
        end
        
        
        gui_erplinset_waveviewer.font_colorauto.Value=1; %
        gui_erplinset_waveviewer.font_colorcustom.Value = 0;
        gui_erplinset_waveviewer.font_custom_type.Enable = 'off'; %
        gui_erplinset_waveviewer.font_custom_size.Enable = 'off';
        gui_erplinset_waveviewer.legendtextauto.Enable = 'off';
        gui_erplinset_waveviewer.legendtextcustom.Enable = 'off';
        gui_erplinset_waveviewer.legendtextauto.Value = 1;
        gui_erplinset_waveviewer.legendtextcustom.Value = 0;
        gui_erplinset_waveviewer.legendcolumns.Value =round(sqrt(length(LegendArray)));
        gui_erplinset_waveviewer.legendcolumns.Enable = 'off';
        gui_erplinset_waveviewer.font_custom_size.Value = 4;
        gui_erplinset_waveviewer.font_custom_type.Value =3;
        
    end

%%Custom for font, fontsize, color, columns for legend
    function font_color_custom(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();%%check if the changes were applied for the other panels
        if ~isempty(messgStr) && viewerpanelIndex~=6
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_linelegend',1);
        gui_erplinset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560]; %%mark the changes
        gui_erplinset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erplineset_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_erplinset_waveviewer.font_colorauto.Value=0; %
        gui_erplinset_waveviewer.font_colorcustom.Value = 1;
        gui_erplinset_waveviewer.font_custom_type.Enable = 'on'; %
        gui_erplinset_waveviewer.font_custom_size.Enable = 'on';
        gui_erplinset_waveviewer.legendtextauto.Enable = 'on';
        gui_erplinset_waveviewer.legendtextcustom.Enable = 'on';
        gui_erplinset_waveviewer.legendcolumns.Enable = 'on';
    end

%%----------------------font of legend text--------------------------------
    function legendfont(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();%%check if the changes were applied for the other panels
        if ~isempty(messgStr) && viewerpanelIndex~=6
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_linelegend',1);
        gui_erplinset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560]; %%mark the changes
        gui_erplinset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erplineset_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
    end

%%----------------------fontsize of legend text----------------------------
    function legendfontsize(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();%%check if the changes were applied for the other panels
        if ~isempty(messgStr) && viewerpanelIndex~=6
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_linelegend',1);
        gui_erplinset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560]; %%mark the changes
        gui_erplinset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erplineset_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
    end


%%----------------------------textcolor auto-------------------------------
    function legendtextauto(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();%%check if the changes were applied for the other panels
        if ~isempty(messgStr) && viewerpanelIndex~=6
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewelinelegend',1);
        gui_erplinset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560]; %%mark the changes
        gui_erplinset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erplineset_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_erplinset_waveviewer.legendtextauto.Value =1; %
        gui_erplinset_waveviewer.legendtextcustom.Value =0;
    end


%%----------------------------textcolor auto-------------------------------
    function legendtextcustom(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();%%check if the changes were applied for the other panels
        if ~isempty(messgStr) && viewerpanelIndex~=6
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_linelegend',1);
        gui_erplinset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560]; %%mark the changes
        gui_erplinset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erplineset_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_erplinset_waveviewer.legendtextauto.Value =0; %
        gui_erplinset_waveviewer.legendtextcustom.Value =1;
    end

%%----------------------Columns of legend names----------------------------
    function legendcolumns(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();%%check if the changes were applied for the other panels
        if ~isempty(messgStr) && viewerpanelIndex~=6
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_linelegend',1);
        gui_erplinset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560]; %%mark the changes
        gui_erplinset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erplineset_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
    end


%%-------------------------------Help--------------------------------------
    function linelegend_help(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();%%check if the changes were applied for the other panels
        if ~isempty(messgStr) && viewerpanelIndex~=6
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        MessageViewer= char(strcat('Lines & Legends > Cancel'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        
        changeFlag =  estudioworkingmemory('MyViewer_linelegend');
        if changeFlag~=1
            MessageViewer= char(strcat('Lines & Legends > Cancel'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =2;
            return;
        end
        
        try
            ERPwaviewer_apply = evalin('base','ALLERPwaviewer');
        catch
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\nLines & Legends > Cancel-f_ERP_lineset_waveviewer_GUI() error: Cannot get parameters for whole panel.\n Please run My viewer again.\n\n');
            return;
        end
        
        gui_erplinset_waveviewer.linesauto.Value= ERPwaviewer_apply.Lines.auto;
        gui_erplinset_waveviewer.linescustom.Value= ~ERPwaviewer_apply.Lines.auto;
        gui_erplinset_waveviewer.line_customtable.Data=ERPwaviewer_apply.Lines.data;
        if gui_erplinset_waveviewer.linesauto.Value==1
            gui_erplinset_waveviewer.line_customtable.Enable = 'off';
        else
            gui_erplinset_waveviewer.line_customtable.Enable = 'on';
        end
        
        
        fontsize  = {'4','6','8','10','12','14','16','18','20','24','28','32','36',...
            '40','50','60','70','80','90','100'};
        labelfontsizeinum = str2num(char(fontsize));
        gui_erplinset_waveviewer.font_custom_type.Value= ERPwaviewer_apply.Legend.font;
        fontsizeValue = ERPwaviewer_apply.Legend.fontsize ;
        [x_label,y_label] = find(labelfontsizeinum==fontsizeValue);
        if isempty(x_label)
            x_label = 4;
        end
        gui_erplinset_waveviewer.font_custom_size.Value= x_label;
        gui_erplinset_waveviewer.legendtextauto.Value= ERPwaviewer_apply.Legend.textcolor;
        gui_erplinset_waveviewer.legendtextcustom.Value= ~ERPwaviewer_apply.Legend.textcolor;
        gui_erplinset_waveviewer.legendcolumns.Value=ERPwaviewer_apply.Legend.columns;
        try
            FontColorAuto= ERPwaviewer_apply.Legend.FontColorAuto;
        catch
            FontColorAuto=1;
        end
        gui_erplinset_waveviewer.font_colorauto.Value=FontColorAuto; %
        
        gui_erplinset_waveviewer.font_colorcustom.Value=~FontColorAuto; %
        if FontColorAuto==1
            LegendEnable = 'off';
        else
            LegendEnable = 'on';
        end
        gui_erplinset_waveviewer.font_custom_type.Enable = LegendEnable;
        gui_erplinset_waveviewer.font_custom_size.Enable = LegendEnable;
        gui_erplinset_waveviewer.legendtextauto.Enable = LegendEnable;
        gui_erplinset_waveviewer.legendtextcustom.Enable = LegendEnable;
        gui_erplinset_waveviewer.legendcolumns.Enable = LegendEnable;
        
        
        estudioworkingmemory('MyViewer_linelegend',0);
        gui_erplinset_waveviewer.apply.BackgroundColor =  [1 1 1];
        gui_erplinset_waveviewer.apply.ForegroundColor = [0 0 0];
        box_erplineset_viewer_property.TitleColor= [0.5 0.5 0.9];
        MessageViewer= char(strcat('Lines & Legends > Cancel'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =2;
    end


%%-----------------Apply the changed parameters----------------------------
    function LineLegend_apply(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();%%check if the changes were applied for the other panels
        if ~isempty(messgStr) && viewerpanelIndex~=6
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        
        estudioworkingmemory('MyViewer_linelegend',0);
        gui_erplinset_waveviewer.apply.BackgroundColor =  [1 1 1];
        gui_erplinset_waveviewer.apply.ForegroundColor = [0 0 0];
        box_erplineset_viewer_property.TitleColor= [0.5 0.5 0.9];
        
        MessageViewer= char(strcat('Lines & Legends > Apply'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        try
            ALLERPwaviewer = evalin('base','ALLERPwaviewer');
            ERPwaviewer_apply = ALLERPwaviewer;
        catch
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n Lines & Legends > Apply-f_ERP_lineset_waveviewer_GUI() error: Cannot get parameters for whole panel.\n Please run My viewer again.\n\n');
            return;
        end
        ERPwaviewer_apply.Lines.auto = gui_erplinset_waveviewer.linesauto.Value;
        ERPwaviewer_apply.Lines.data = gui_erplinset_waveviewer.line_customtable.Data;
        fontsize  = {'4','6','8','10','12','14','16','18','20','24','28','32','36',...
            '40','50','60','70','80','90','100'};
        labelfontsizeinum = str2num(char(fontsize));
        ERPwaviewer_apply.Legend.font = gui_erplinset_waveviewer.font_custom_type.Value;
        ERPwaviewer_apply.Legend.fontsize = labelfontsizeinum(gui_erplinset_waveviewer.font_custom_size.Value);
        ERPwaviewer_apply.Legend.textcolor = gui_erplinset_waveviewer.legendtextauto.Value;
        ERPwaviewer_apply.Legend.columns = gui_erplinset_waveviewer.legendcolumns.Value;
        ERPwaviewer_apply.Legend.FontColorAuto = gui_erplinset_waveviewer.font_colorauto.Value;
        assignin('base','ALLERPwaviewer',ERPwaviewer_apply);
        
        
        %%Save the parameters for this panel to memory file
        MERPWaveViewer_linelegend{1}=gui_erplinset_waveviewer.linesauto.Value;
        MERPWaveViewer_linelegend{2}= gui_erplinset_waveviewer.line_customtable.Data;
        MERPWaveViewer_linelegend{3}=gui_erplinset_waveviewer.font_colorauto.Value;
        MERPWaveViewer_linelegend{4}=gui_erplinset_waveviewer.font_custom_type.Value;
        MERPWaveViewer_linelegend{5}=gui_erplinset_waveviewer.font_custom_size.Value;
        MERPWaveViewer_linelegend{6}= gui_erplinset_waveviewer.legendtextauto.Value;
        MERPWaveViewer_linelegend{7}=gui_erplinset_waveviewer.legendcolumns.Value;
        estudioworkingmemory('MERPWaveViewer_linelegend',MERPWaveViewer_linelegend);%%save the parameters for this panel to memory file
        
        f_redrawERP_viewer_test();
        viewer_ERPDAT.Process_messg =2;
    end


%%--------------change the legend name-------------------------------------
    function legend_change(~,~)
        if viewer_ERPDAT.count_legend==0
            return;
        end
        try
            ERPwaviewer = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp('f_ERP_lineset_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        for ii = 1:100
            LegendName{ii,1} = '';
            LegendNamenum(ii,1) =ii;
        end
        ALLERPIN = ERPwaviewer.ALLERP;
        ERPsetArray = ERPwaviewer.SelectERPIdx;
        if max(ERPsetArray(:))> length(ALLERPIN)
            ERPsetArray =length(ALLERPIN);
        end
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERPIN,ERPsetArray);
        LegendArray = [1:4];
        try
            plot_org = ERPwaviewer.plot_org;
            ERPIN = ERPwaviewer.ERP;
            if plot_org.Overlay ==1
                ChanArray = ERPwaviewer.chan;
                for Numofchan = 1:numel(ChanArray)
                    LegendName{Numofchan,1} = char(chanStr(ChanArray(Numofchan)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
                LegendArray = ChanArray;
            elseif plot_org.Overlay ==2
                binArray = ERPwaviewer.bin;
                for Numofbin = 1:numel(binArray)
                    LegendName{Numofbin,1} = char(binStr(binArray(Numofbin)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
                LegendArray = binArray;
            elseif plot_org.Overlay ==3
                ALLERP = ERPwaviewer.ALLERP;
                ERPsetArray = ERPwaviewer.SelectERPIdx;
                for Numoferpset = 1:numel(ERPsetArray)
                    LegendName{Numoferpset,1} = char(ALLERP(ERPsetArray(Numoferpset)).erpname);
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
                LegendArray = ERPsetArray;
            else
                binArray = ERPwaviewer.bin;
                for Numofbin = 1:numel(binArray)
                    LegendName{Numofbin,1} = char(binStr(binArray(Numofbin)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
                LegendArray = binArray;
            end
        catch
            legendset_str = table(LegendNamenum,LegendName);
            legendset_str = table2cell(legendset_str);
        end
        ERPwaviewer.Legend.data = legendset_str;
        if gui_erplinset_waveviewer.font_colorauto.Value==1
            gui_erplinset_waveviewer.legendcolumns.Value =round(sqrt(length(LegendArray)));
            ERPwaviewer.Legend.columns = round(sqrt(length(LegendArray)));
        end
        assignin('base','ALLERPwaviewer',ERPwaviewer);
        
        %%Save parameters for this panel to memory file
        MERPWaveViewer_linelegend{1}=gui_erplinset_waveviewer.linesauto.Value;
        MERPWaveViewer_linelegend{2}= gui_erplinset_waveviewer.line_customtable.Data;
        MERPWaveViewer_linelegend{3}=gui_erplinset_waveviewer.font_colorauto.Value;
        MERPWaveViewer_linelegend{4}=gui_erplinset_waveviewer.font_custom_type.Value;
        MERPWaveViewer_linelegend{5}=gui_erplinset_waveviewer.font_custom_size.Value;
        MERPWaveViewer_linelegend{6}= gui_erplinset_waveviewer.legendtextauto.Value;
        MERPWaveViewer_linelegend{7}=gui_erplinset_waveviewer.legendcolumns.Value;
        estudioworkingmemory('MERPWaveViewer_linelegend',MERPWaveViewer_linelegend);%%save the parameters for this panel to memory file
    end

%%--------changed the legend names based on the current page---------------
    function page_xyaxis_change(~,~)
        if viewer_ERPDAT.page_xyaxis==0
            return;
        end
        try
            ERPwaviewer = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp('f_ERP_lineset_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        for ii = 1:100
            LegendName{ii,1} = '';
            LegendNamenum(ii,1) =ii;
        end
        ALLERPIN = ERPwaviewer.ALLERP;
        ERPsetArray = ERPwaviewer.SelectERPIdx;
        if max(ERPsetArray(:))> length(ALLERPIN)
            ERPsetArray =length(ALLERPIN);
        end
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERPIN,ERPsetArray);
        LegendArray = [1:4];
        try
            plot_org = ERPwaviewer.plot_org;
            ERPIN = ERPwaviewer.ERP;
            if plot_org.Overlay ==1
                ChanArray = ERPwaviewer.chan;
                for Numofchan = 1:numel(ChanArray)
                    LegendName{Numofchan,1} = char(chanStr(ChanArray(Numofchan)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
                LegendArray = ChanArray;
            elseif plot_org.Overlay ==2
                binArray = ERPwaviewer.bin;
                for Numofbin = 1:numel(binArray)
                    LegendName{Numofbin,1} = char(binStr(binArray(Numofbin)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
                LegendArray = binArray;
            elseif plot_org.Overlay ==3
                ALLERP = ERPwaviewer.ALLERP;
                ERPsetArray = ERPwaviewer.SelectERPIdx;
                for Numoferpset = 1:numel(ERPsetArray)
                    LegendName{Numoferpset,1} = char(ALLERP(ERPsetArray(Numoferpset)).erpname);
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
                LegendArray = ERPsetArray;
            else
                binArray = ERPwaviewer.bin;
                for Numofbin = 1:numel(binArray)
                    LegendName{Numofbin,1} = char(binStr(binArray(Numofbin)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
                LegendArray = binArray;
            end
        catch
            legendset_str = table(LegendNamenum,LegendName);
            legendset_str = table2cell(legendset_str);
        end
        
        ERPwaviewer.Legend.data = legendset_str;
        if gui_erplinset_waveviewer.font_colorauto.Value==1
            gui_erplinset_waveviewer.legendcolumns.Value =round(sqrt(length(LegendArray)));
            ERPwaviewer.Legend.columns = round(sqrt(length(LegendArray)));
        end
        assignin('base','ALLERPwaviewer',ERPwaviewer);
        
        MERPWaveViewer_linelegend{1}=gui_erplinset_waveviewer.linesauto.Value;
        MERPWaveViewer_linelegend{2}= gui_erplinset_waveviewer.line_customtable.Data;
        MERPWaveViewer_linelegend{3}=gui_erplinset_waveviewer.font_colorauto.Value;
        MERPWaveViewer_linelegend{4}=gui_erplinset_waveviewer.font_custom_type.Value;
        MERPWaveViewer_linelegend{5}=gui_erplinset_waveviewer.font_custom_size.Value;
        MERPWaveViewer_linelegend{6}= gui_erplinset_waveviewer.legendtextauto.Value;
        MERPWaveViewer_linelegend{7}=gui_erplinset_waveviewer.legendcolumns.Value;
        estudioworkingmemory('MERPWaveViewer_linelegend',MERPWaveViewer_linelegend);%%save the parameters for this panel to memory file
    end


%%-----change legend if ERPsets is changed from the first two panels-------
    function v_currentERP_change(~,~)
        if viewer_ERPDAT.Count_currentERP == 0
            return;
        end
        try
            ERPwaviewer = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp('f_ERP_lineset_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        for ii = 1:100
            LegendName{ii,1} = '';
            LegendNamenum(ii,1) =ii;
        end
        ALLERP = ERPwaviewer.ALLERP;
        ERPsetArray = ERPwaviewer.SelectERPIdx;
        if max(ERPsetArray(:))> length(ALLERP)
            ERPsetArray =length(ALLERP);
        end
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERP,ERPsetArray);
        LegendArray = [1:4];
        try
            plot_org = ERPwaviewer.plot_org;
            if plot_org.Overlay ==1
                ChanArray = ERPwaviewer.chan;
                for Numofchan = 1:numel(ChanArray)
                    LegendName{Numofchan,1} = char(chanStr(ChanArray(Numofchan)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
                LegendArray =ChanArray ;
            elseif plot_org.Overlay ==2
                binArray = ERPwaviewer.bin;
                for Numofbin = 1:numel(binArray)
                    LegendName{Numofbin,1} = char(binStr(binArray(Numofbin)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
                LegendArray =binArray ;
            elseif plot_org.Overlay ==3
                for Numoferpset = 1:numel(ERPsetArray)
                    LegendName{Numoferpset,1} = char(ALLERP(ERPsetArray(Numoferpset)).erpname);
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
                LegendArray =ERPsetArray ;
            else
                binArray = ERPwaviewer.bin;
                for Numofbin = 1:numel(binArray)
                    LegendName{Numofbin,1} = char(binStr(binArray(Numofbin)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
                LegendArray =binArray ;
            end
        catch
            legendset_str = table(LegendNamenum,LegendName);
            legendset_str = table2cell(legendset_str);
        end
        ERPwaviewer.Legend.data = legendset_str;
        if gui_erplinset_waveviewer.font_colorauto.Value==1
            gui_erplinset_waveviewer.legendcolumns.Value =round(sqrt(length(LegendArray)));
            ERPwaviewer.Legend.columns = round(sqrt(length(LegendArray)));
        end
        assignin('base','ALLERPwaviewer',ERPwaviewer);
        
        MERPWaveViewer_linelegend{1}=gui_erplinset_waveviewer.linesauto.Value;
        MERPWaveViewer_linelegend{2}= gui_erplinset_waveviewer.line_customtable.Data;
        MERPWaveViewer_linelegend{3}=gui_erplinset_waveviewer.font_colorauto.Value;
        MERPWaveViewer_linelegend{4}=gui_erplinset_waveviewer.font_custom_type.Value;
        MERPWaveViewer_linelegend{5}=gui_erplinset_waveviewer.font_custom_size.Value;
        MERPWaveViewer_linelegend{6}= gui_erplinset_waveviewer.legendtextauto.Value;
        MERPWaveViewer_linelegend{7}=gui_erplinset_waveviewer.legendcolumns.Value;
        estudioworkingmemory('MERPWaveViewer_linelegend',MERPWaveViewer_linelegend);%%save the parameters for this panel to memory file
        
    end



%%-------------change this panel based on the loaded parameters------------
    function loadproper_change(~,~)
        if viewer_ERPDAT.loadproper_count ~=6
            return;
        end
        try
            ERPwaviewer = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp('f_ERP_lineset_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        %%-----------------------Line settings-----------------------------
        LineValue =  ERPwaviewer.Lines.auto;
        if numel(LineValue)~=1 || (LineValue~=1 && LineValue~=0)
            LineValue  = 1;
            ERPwaviewer.Lines.auto = 1;
        end
        if LineValue==1
            gui_erplinset_waveviewer.linesauto.Value =1;
            gui_erplinset_waveviewer.linescustom.Value = 0;
            gui_erplinset_waveviewer.line_customtable.Enable = 'off';
        else
            gui_erplinset_waveviewer.linesauto.Value =0;
            gui_erplinset_waveviewer.linescustom.Value = 1;
            gui_erplinset_waveviewer.line_customtable.Enable = 'on';
        end
        
        
        [lineNameStr,linecolors,linetypes,linewidths,linecolors_str,linetypes_str,linewidths_str,linecolorsrgb] = f_get_lineset_ERPviewer();
        lineset_str  =table(lineNameStr,linecolors,linetypes,linewidths);
        lineset_str = table2cell(lineset_str);
        gui_erplinset_waveviewer.line_customtable.ColumnFormat = {'char', 'char',...
            {'solid','dash','dot','dashdot','plus','circle','asterisk'},...
            {'0.25','0.5','1','1.5','2','2.5','3','3.5','4','4.5','5','5.5','6','6.5','7','7.5','8','8.5','9','9.5','10','10.5'}};
        
        LineData = ERPwaviewer.Lines.data;
        if LineValue==1
            LineData= lineset_str;
            ERPwaviewer.Lines.data = LineData;
        end
        gui_erplinset_waveviewer.line_customtable.Data = LineData;
        
        %
        %%---------------------Legend setting------------------------------
        for ii = 1:100
            LegendName{ii,1} = '';
            LegendNamenum(ii,1) =ii;
        end
        ALLERP = ERPwaviewer.ALLERP;
        ERPsetArray = ERPwaviewer.SelectERPIdx;
        if max(ERPsetArray(:))> length(ALLERP)
            ERPsetArray =length(ALLERP);
        end
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERP,ERPsetArray);
        LegendArray = [1:4];
        try
            plot_org = ERPwaviewer.plot_org;
            if plot_org.Overlay ==1
                ChanArray = ERPwaviewer.chan;
                for Numofchan = 1:numel(ChanArray)
                    LegendName{Numofchan,1} = char(chanStr(ChanArray(Numofchan)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
                LegendArray = ChanArray;
            elseif plot_org.Overlay ==2
                binArray = ERPwaviewer.bin;
                for Numofbin = 1:numel(binArray)
                    LegendName{Numofbin,1} = char(binStr(binArray(Numofbin)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
                LegendArray = binArray;
            elseif plot_org.Overlay ==3
                for Numoferpset = 1:numel(ERPsetArray)
                    LegendName{Numoferpset,1} = char(ALLERP(ERPsetArray(Numoferpset)).erpname);
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
                LegendArray = ERPsetArray;
            else
                binArray = ERPwaviewer.bin;
                for Numofbin = 1:numel(binArray)
                    LegendName{Numofbin,1} = char(binStr(binArray(Numofbin)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
                LegendArray = binArray;
            end
        catch
            legendset_str = table(LegendNamenum,LegendName);
            legendset_str = table2cell(legendset_str);
        end
        ERPwaviewer.Legend.data=legendset_str;
        
        LegendfontColorAuto = gui_erplinset_waveviewer.font_colorauto.Value;
        if LegendfontColorAuto==1
            gui_erplinset_waveviewer.font_custom_type.Enable = 'off'; %
            gui_erplinset_waveviewer.font_custom_size.Enable = 'off';
            gui_erplinset_waveviewer.legendtextauto.Enable = 'off';
            gui_erplinset_waveviewer.legendtextcustom.Enable = 'off';
            gui_erplinset_waveviewer.legendtextauto.Value = 1;
            gui_erplinset_waveviewer.legendtextcustom.Value = 0;
            %             gui_erplinset_waveviewer.legendcolumns.Value =1;
            gui_erplinset_waveviewer.legendcolumns.Value =round(sqrt(length(LegendArray)));
            gui_erplinset_waveviewer.legendcolumns.Enable = 'off';
            gui_erplinset_waveviewer.font_colorauto.Value=1;
            gui_erplinset_waveviewer.font_colorcustom.Value = 0;
        else
            gui_erplinset_waveviewer.font_custom_type.Enable = 'on'; %
            gui_erplinset_waveviewer.font_custom_size.Enable = 'on';
            gui_erplinset_waveviewer.legendtextauto.Enable = 'on';
            gui_erplinset_waveviewer.legendtextcustom.Enable = 'on';
            gui_erplinset_waveviewer.legendcolumns.Enable = 'on';
            gui_erplinset_waveviewer.font_colorauto.Value=0;
            gui_erplinset_waveviewer.font_colorcustom.Value = 1;
        end
        
        
        legendfont =ERPwaviewer.Legend.font;
        gui_erplinset_waveviewer.font_custom_type.Value = legendfont;
        legendfontsize = ERPwaviewer.Legend.fontsize;
        fontsize  = {'4','6','8','10','12','14','16','18','20','24','28','32','36',...
            '40','50','60','70','80','90','100'};
        gui_erplinset_waveviewer.font_custom_size.String = fontsize;
        fontsize = str2num(char(fontsize));
        [xsize,y] = find(fontsize ==legendfontsize);
        gui_erplinset_waveviewer.font_custom_size.Value = xsize;
        
        Legendtextcolor = ERPwaviewer.Legend.textcolor;
        if Legendtextcolor==1
            gui_erplinset_waveviewer.legendtextauto.Value =1; %
            gui_erplinset_waveviewer.legendtextcustom.Value =0;
        else
            gui_erplinset_waveviewer.legendtextauto.Value =0; %
            gui_erplinset_waveviewer.legendtextcustom.Value =1;
        end
        legendColumns = ERPwaviewer.Legend.columns;
        gui_erplinset_waveviewer.legendcolumns.Value = legendColumns;
        for Numoflegend = 1:100
            columnStr{Numoflegend} = num2str(Numoflegend);
        end
        gui_erplinset_waveviewer.legendcolumns.String = columnStr;
        assignin('base','ALLERPwaviewer',ERPwaviewer);
        
        %%save the parameters to memory file
        MERPWaveViewer_linelegend{1}=gui_erplinset_waveviewer.linesauto.Value;
        MERPWaveViewer_linelegend{2}= gui_erplinset_waveviewer.line_customtable.Data;
        MERPWaveViewer_linelegend{3}=gui_erplinset_waveviewer.font_colorauto.Value;
        MERPWaveViewer_linelegend{4}=gui_erplinset_waveviewer.font_custom_type.Value;
        MERPWaveViewer_linelegend{5}=gui_erplinset_waveviewer.font_custom_size.Value;
        MERPWaveViewer_linelegend{6}= gui_erplinset_waveviewer.legendtextauto.Value;
        MERPWaveViewer_linelegend{7}=gui_erplinset_waveviewer.legendcolumns.Value;
        estudioworkingmemory('MERPWaveViewer_linelegend',MERPWaveViewer_linelegend);%%save the parameters for this panel to memory file
        
        viewer_ERPDAT.loadproper_count =7;
    end

%%-------------------------------------------------------------------------
%%Automatically saving the changed parameters for the current panel if the
%%user change parameters for the other panels.
%%-------------------------------------------------------------------------
    function count_twopanels_change(~,~)
        if viewer_ERPDAT.count_twopanels==0
            return;
        end
        changeFlag =  estudioworkingmemory('MyViewer_linelegend');
        if changeFlag~=1
            return;
        end
        LineLegend_apply();
    end

%%-------------------------------------------------------------------------
%%-----------------Reset this panel with the default parameters------------
%%-------------------------------------------------------------------------
    function Reset_Waviewer_panel_change(~,~)
        if viewer_ERPDAT.Reset_Waviewer_panel==6
            try
                ERPwaviewerin = evalin('base','ALLERPwaviewer');
            catch
                beep;
                disp('f_ERP_lineset_waveviewer_GUI error: Restart ERPwave Viewer');
                return;
            end
            %%-------------------------Lines-------------------------------
            gui_erplinset_waveviewer.linesauto.Value =1;
            gui_erplinset_waveviewer.linescustom.Value = 0;
            gui_erplinset_waveviewer.line_customtable.Enable = 'off';
            [lineNameStr,linecolors,linetypes,linewidths,linecolors_str,linetypes_str,linewidths_str,linecolorsrgb] = f_get_lineset_ERPviewer();
            lineset_str  =table(lineNameStr,linecolors,linetypes,linewidths);
            lineset_str = table2cell(lineset_str);
            gui_erplinset_waveviewer.line_customtable.ColumnFormat = {'char', 'char',...
                {'solid','dash','dot','dashdot','plus','circle','asterisk'},...
                {'0.25','0.5','1','1.5','2','2.5','3','3.5','4','4.5','5','5.5','6','6.5','7','7.5','8','8.5','9','9.5','10','10.5'}};
            gui_erplinset_waveviewer.line_customtable.Data = lineset_str;
            ERPwaviewerin.Lines.auto =1;
            ERPwaviewerin.Lines.data = gui_erplinset_waveviewer.line_customtable.Data;
            
            %%-----------------------Legends-------------------------------
            gui_erplinset_waveviewer.font_colorauto.Value =1;
            gui_erplinset_waveviewer.font_colorcustom.Value =0;
            
            gui_erplinset_waveviewer.font_custom_type.Enable = 'off'; %
            gui_erplinset_waveviewer.font_custom_size.Enable = 'off';
            gui_erplinset_waveviewer.legendtextauto.Enable = 'off';
            gui_erplinset_waveviewer.legendtextcustom.Enable = 'off';
            gui_erplinset_waveviewer.legendtextauto.Value = 1;
            gui_erplinset_waveviewer.legendtextcustom.Value = 0;
            %             gui_erplinset_waveviewer.legendcolumns.Value =1;
            gui_erplinset_waveviewer.legendcolumns.Enable = 'off';
            %
            for ii = 1:100
                LegendName{ii,1} = '';
                LegendNamenum(ii,1) =ii;
            end
            ALLERP = ERPwaviewerin.ALLERP;
            ERPsetArray = ERPwaviewerin.SelectERPIdx;
            if max(ERPsetArray(:))> length(ALLERP)
                ERPsetArray =length(ALLERP);
            end
            [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERP,ERPsetArray);
            LegendArray = [1:4];
            try
                plot_org = ERPwaviewerin.plot_org;
                if plot_org.Overlay ==1
                    ChanArray = ERPwaviewerin.chan;
                    for Numofchan = 1:numel(ChanArray)
                        LegendName{Numofchan,1} = char(chanStr(ChanArray(Numofchan)));
                    end
                    legendset_str = table(LegendNamenum,LegendName);
                    legendset_str = table2cell(legendset_str);
                    LegendArray =ChanArray;
                elseif plot_org.Overlay ==2
                    binArray = ERPwaviewerin.bin;
                    for Numofbin = 1:numel(binArray)
                        LegendName{Numofbin,1} = char(binStr(binArray(Numofbin)));
                    end
                    legendset_str = table(LegendNamenum,LegendName);
                    legendset_str = table2cell(legendset_str);
                    LegendArray =binArray;
                elseif plot_org.Overlay ==3
                    for Numoferpset = 1:numel(ERPsetArray)
                        LegendName{Numoferpset,1} = char(ALLERP(ERPsetArray(Numoferpset)).erpname);
                    end
                    legendset_str = table(LegendNamenum,LegendName);
                    legendset_str = table2cell(legendset_str);
                    LegendArray =ERPsetArray;
                else
                    binArray = ERPwaviewerin.bin;
                    for Numofbin = 1:numel(binArray)
                        LegendName{Numofbin,1} = char(binStr(binArray(Numofbin)));
                    end
                    legendset_str = table(LegendNamenum,LegendName);
                    legendset_str = table2cell(legendset_str);
                    LegendArray =binArray;
                end
            catch
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
            end
            
            gui_erplinset_waveviewer.legendcolumns.Value =round(sqrt(length(LegendArray)));
            gui_erplinset_waveviewer.font_custom_size.Value = 4;
            gui_erplinset_waveviewer.font_custom_type.Value =3;
            ERPwaviewerin.Legend.data =legendset_str;
            ERPwaviewerin.Legend.font=3;
            ERPwaviewerin.Legend.fontsize=10;
            ERPwaviewerin.Legend.textcolor=1;
            ERPwaviewerin.Legend.columns=1;
            ERPwaviewerin.Legend.FontColorAuto=1;
            
            assignin('base','ALLERPwaviewer',ERPwaviewerin);
            gui_erplinset_waveviewer.apply.BackgroundColor =  [1 1 1];
            gui_erplinset_waveviewer.apply.ForegroundColor = [0 0 0];
            box_erplineset_viewer_property.TitleColor= [0.5 0.5 0.9];
            
            MERPWaveViewer_linelegend{1}=gui_erplinset_waveviewer.linesauto.Value;
            MERPWaveViewer_linelegend{2}= gui_erplinset_waveviewer.line_customtable.Data;
            MERPWaveViewer_linelegend{3}=gui_erplinset_waveviewer.font_colorauto.Value;
            MERPWaveViewer_linelegend{4}=gui_erplinset_waveviewer.font_custom_type.Value;
            MERPWaveViewer_linelegend{5}=gui_erplinset_waveviewer.font_custom_size.Value;
            MERPWaveViewer_linelegend{6}= gui_erplinset_waveviewer.legendtextauto.Value;
            MERPWaveViewer_linelegend{7}=gui_erplinset_waveviewer.legendcolumns.Value;
            estudioworkingmemory('MERPWaveViewer_linelegend',MERPWaveViewer_linelegend);%%save the parameters for this panel to memory file
            
            viewer_ERPDAT.Reset_Waviewer_panel=7;
        end
    end

    function line_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            LineLegend_apply();
            estudioworkingmemory('MyViewer_linelegend',0);
            gui_erplinset_waveviewer.apply.BackgroundColor =  [1 1 1];
            gui_erplinset_waveviewer.apply.ForegroundColor = [0 0 0];
            box_erplineset_viewer_property.TitleColor= [0.5 0.5 0.9];
        else
            return;
        end
    end
end