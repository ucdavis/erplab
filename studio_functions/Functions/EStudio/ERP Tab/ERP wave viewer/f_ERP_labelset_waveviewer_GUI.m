%%This function is to plot the panel for "Viewer properties".

% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022


function varargout = f_ERP_labelset_waveviewer_GUI(varargin)

global viewer_ERPDAT;
addlistener(viewer_ERPDAT,'loadproper_change',@loadproper_change);
% addlistener(viewer_ERPDAT,'Process_messg_change',@Process_messg_change);
addlistener(viewer_ERPDAT,'count_twopanels_change',@count_twopanels_change);
addlistener(viewer_ERPDAT,'Reset_Waviewer_panel_change',@Reset_Waviewer_panel_change);

gui_labelset_waveviewer = struct();

%-----------------------------Name the title----------------------------------------------
% global box_erplabelset_viewer_property;
[version reldate,ColorB_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    box_erplabelset_viewer_property = uiextras.BoxPanel('Parent', fig, 'Title', 'Chan/Bin/ERPset Label Properties', 'Padding', 5,...
        'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w','FontSize',12); % Create boxpanel
elseif nargin == 1
    box_erplabelset_viewer_property = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Chan/Bin/ERPset Label Properties', 'Padding', 5,...
        'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w','FontSize',12);
else
    box_erplabelset_viewer_property = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Chan/Bin/ERPset Label Properties', 'Padding', 5, ...
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

drawui_plot_property(FonsizeDefault);
varargout{1} = box_erplabelset_viewer_property;

    function drawui_plot_property(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
        
        try
            ERPwaviewer  = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp('f_ERP_labelset_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        %%--------------------channel and bin setting----------------------
        gui_labelset_waveviewer.DataSelBox = uiextras.VBox('Parent', box_erplabelset_viewer_property,'BackgroundColor',ColorBviewer_def);
        
        %%-----------------Setting for label location title-------
        gui_labelset_waveviewer.location_title = uiextras.HBox('Parent', gui_labelset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_labelset_waveviewer.location_title,'String','Label Location:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',1,'FontWeight','bold'); %,'HorizontalAlignment','left'
        
        %%-----------------Setting for Auto-------
        %%get the parameters from memory file
        MERPWaveViewer_label= estudioworkingmemory('MERPWaveViewer_label');
        try
            locationAuto = MERPWaveViewer_label{1};
            locationno = MERPWaveViewer_label{2};
            locationcustom = MERPWaveViewer_label{3};
        catch
            locationAuto = 1;
            locationno = 0;
            locationcustom = 0;%% the default value
            MERPWaveViewer_label{1} = 1;
            MERPWaveViewer_label{2} = 0;
            MERPWaveViewer_label{3} = 0;
        end
        if locationAuto ==1
            locationno =0;
            locationcustom =0;
        elseif locationno ==1
            locationAuto = 0;
            locationcustom =0;
        elseif locationcustom ==1
            locationAuto = 0;
            locationno =0;
        end
        gui_labelset_waveviewer.parameters_title = uiextras.HBox('Parent', gui_labelset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        gui_labelset_waveviewer.labelauto = uicontrol('Style','radiobutton','Parent', gui_labelset_waveviewer.parameters_title,'String','Auto',...
            'callback',@labelauto,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',locationAuto); %
        gui_labelset_waveviewer.labelauto.KeyPressFcn = @labels_presskey;
        gui_labelset_waveviewer.nolabel = uicontrol('Style','radiobutton','Parent', gui_labelset_waveviewer.parameters_title,'String','No labels',...
            'callback',@nolabel,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',locationno); %
        gui_labelset_waveviewer.nolabel.KeyPressFcn = @labels_presskey;
        gui_labelset_waveviewer.customlabel = uicontrol('Style','radiobutton','Parent', gui_labelset_waveviewer.parameters_title,'String','Custom',...
            'callback',@customlabel,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',locationcustom); %
        gui_labelset_waveviewer.customlabel.KeyPressFcn = @labels_presskey;
        if gui_labelset_waveviewer.labelauto.Value
            gui_labelset_waveviewer.nolabel.Value = ~gui_labelset_waveviewer.labelauto.Value;
            gui_labelset_waveviewer.customlabel.Value = ~gui_labelset_waveviewer.labelauto.Value;
            customdefEnable = 'off';
        elseif gui_labelset_waveviewer.nolabel.Value
            gui_labelset_waveviewer.labelauto.Value = ~gui_labelset_waveviewer.nolabel.Value;
            gui_labelset_waveviewer.customlabel.Value = ~gui_labelset_waveviewer.nolabel.Value;
            customdefEnable = 'off';
        elseif gui_labelset_waveviewer.customlabel.Value
            gui_labelset_waveviewer.labelauto.Value = ~gui_labelset_waveviewer.customlabel.Value;
            gui_labelset_waveviewer.nolabel.Value = ~gui_labelset_waveviewer.customlabel.Value;
            customdefEnable = 'on';
        end
        ERPwaviewer.chanbinsetlabel.location.auto = gui_labelset_waveviewer.labelauto.Value;
        ERPwaviewer.chanbinsetlabel.location.no = gui_labelset_waveviewer.nolabel.Value;
        ERPwaviewer.chanbinsetlabel.location.custom =gui_labelset_waveviewer.customlabel.Value;
        if locationAuto ==1
            xperDef = 50;
            yperDef = 100;
        else
            try
                xperDef= MERPWaveViewer_label{4};
                yperDef= MERPWaveViewer_label{5};
            catch
                xperDef = 50;
                yperDef = 100;
                MERPWaveViewer_label{4} = xperDef;
                MERPWaveViewer_label{5} = yperDef;
            end
        end
        try
            CenDef = MERPWaveViewer_label{6};
        catch
            CenDef = 1;
            MERPWaveViewer_label{6} =1;
        end
        gui_labelset_waveviewer.labelloc_title = uiextras.HBox('Parent', gui_labelset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        gui_labelset_waveviewer.xperctitle = uicontrol('Style','text','Parent', gui_labelset_waveviewer.labelloc_title,'String','X%',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Value',~gui_labelset_waveviewer.labelauto.Value); %
        gui_labelset_waveviewer.xperc_edit = uicontrol('Style','edit','Parent', gui_labelset_waveviewer.labelloc_title,'String',num2str(xperDef),...
            'callback',@label_xperc, 'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable',customdefEnable); %
        gui_labelset_waveviewer.xperc_edit.KeyPressFcn = @labels_presskey;
        gui_labelset_waveviewer.yperctitle = uicontrol('Style','text','Parent', gui_labelset_waveviewer.labelloc_title,'String','Y%',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); %
        gui_labelset_waveviewer.yperc_edit = uicontrol('Style','edit','Parent', gui_labelset_waveviewer.labelloc_title,'String',num2str(yperDef),...
            'callback',@label_yperc, 'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable',customdefEnable); %
        gui_labelset_waveviewer.yperc_edit.KeyPressFcn = @labels_presskey;
        gui_labelset_waveviewer.center = uicontrol('Style','checkbox','Parent', gui_labelset_waveviewer.labelloc_title,'String','Centered',...
            'callback',@label_center,'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'Enable',customdefEnable,'Value',CenDef); %
        gui_labelset_waveviewer.center.KeyPressFcn = @labels_presskey;
        set(gui_labelset_waveviewer.labelloc_title,'Sizes',[30 45 30 45 80]);
        ERPwaviewer.chanbinsetlabel.location.xperc = str2num(char(gui_labelset_waveviewer.xperc_edit.String));
        ERPwaviewer.chanbinsetlabel.location.yperc = str2num(char(gui_labelset_waveviewer.yperc_edit.String));
        ERPwaviewer.chanbinsetlabel.location.center = gui_labelset_waveviewer.center.Value;
        
        %
        %%--------------------font and font size---------------------------
        gui_labelset_waveviewer.font_title = uiextras.HBox('Parent', gui_labelset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        try
            fontDef=MERPWaveViewer_label{7};
        catch
            fontDef = 3;
            MERPWaveViewer_label{7}=3;
        end
        fontsize  = {'4','6','8','10','12','14','16','18','20','24','28','32','36',...
            '40','50','60','70','80','90','100'};
        labelfontsizeinum = str2num(char(fontsize));
        try
            LabelfontsizeValue = MERPWaveViewer_label{8};
        catch
            LabelfontsizeValue = 4;
            MERPWaveViewer_label{8}=4;
        end
        if numel(LabelfontsizeValue)~=1 || LabelfontsizeValue<=0 || LabelfontsizeValue>20
            LabelfontsizeValue = 4;
            MERPWaveViewer_label{8}=4;
        end
        uicontrol('Style','text','Parent', gui_labelset_waveviewer.font_title,'String','Label Font & Fontsize & Color:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'FontWeight','bold'); %,'HorizontalAlignment','left'
        gui_labelset_waveviewer.font_custom_title = uiextras.HBox('Parent', gui_labelset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_labelset_waveviewer.font_custom_title ,'String','Font',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); %
        fonttype = {'Courier','Geneva','Helvetica','Monaco','Times'};
        gui_labelset_waveviewer.font_custom_type = uicontrol('Style','popupmenu','Parent', gui_labelset_waveviewer.font_custom_title ,'String',fonttype,...
            'callback',@label_font,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Value',fontDef,'Enable',customdefEnable); %
        gui_labelset_waveviewer.font_custom_type.KeyPressFcn = @labels_presskey;
        uicontrol('Style','text','Parent', gui_labelset_waveviewer.font_custom_title ,'String','Size',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); %
        
        gui_labelset_waveviewer.font_custom_size = uicontrol('Style','popupmenu','Parent', gui_labelset_waveviewer.font_custom_title ,'String',fontsize,...
            'callback',@label_fontsize,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Value',LabelfontsizeValue,'Enable',customdefEnable); %
        gui_labelset_waveviewer.font_custom_size.KeyPressFcn = @labels_presskey;
        set(gui_labelset_waveviewer.font_custom_title,'Sizes',[30 110 30 70]);
        ERPwaviewer.chanbinsetlabel.font = gui_labelset_waveviewer.font_custom_type.Value;
        ERPwaviewer.chanbinsetlabel.fontsize = labelfontsizeinum(gui_labelset_waveviewer.font_custom_size.Value);
        
        %%--------------Label text color-----------
        try
            Labelfontcolor= MERPWaveViewer_label{9};
        catch
            Labelfontcolor =1;
            MERPWaveViewer_label{9} =1;
        end
        gui_labelset_waveviewer.labelcolor_title = uiextras.HBox('Parent', gui_labelset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent',  gui_labelset_waveviewer.labelcolor_title,'String','Color',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left'); %
        textColor = {'Black','Red','Blue','Green','Orange','Cyan','Magenla'};
        gui_labelset_waveviewer.labelcolor = uicontrol('Style','popupmenu','Parent',gui_labelset_waveviewer.labelcolor_title,'String',textColor,...
            'callback',@label_color,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable',customdefEnable,'Value',Labelfontcolor); %
        gui_labelset_waveviewer.labelcolor.KeyPressFcn = @labels_presskey;
        uiextras.Empty('Parent',gui_labelset_waveviewer.labelcolor_title);
        uiextras.Empty('Parent',gui_labelset_waveviewer.labelcolor_title);
        set(gui_labelset_waveviewer.labelcolor_title,'Sizes',[40 100 30 70]);
        ERPwaviewer.chanbinsetlabel.textcolor = gui_labelset_waveviewer.labelcolor.Value;
        
        %%-----------------------help and apply----------------------------
        gui_labelset_waveviewer.help_apply_title = uiextras.HBox('Parent', gui_labelset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uiextras.Empty('Parent',gui_labelset_waveviewer.help_apply_title );
        uicontrol('Style','pushbutton','Parent', gui_labelset_waveviewer.help_apply_title  ,'String','Cancel',...
            'callback',@label_help,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %,'FontWeight','bold','HorizontalAlignment','left'
        uiextras.Empty('Parent',gui_labelset_waveviewer.help_apply_title  );
        gui_labelset_waveviewer.Apply= uicontrol('Style','pushbutton','Parent',gui_labelset_waveviewer.help_apply_title  ,'String','Apply',...
            'callback',@label_apply,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %,'HorizontalAlignment','left'
        uiextras.Empty('Parent',gui_labelset_waveviewer.help_apply_title  );
        set(gui_labelset_waveviewer.help_apply_title ,'Sizes',[40 70 20 70 20]);
        set(gui_labelset_waveviewer.DataSelBox ,'Sizes',[20 25 25 20 25 25 25]);
        assignin('base','ALLERPwaviewer',ERPwaviewer);
        estudioworkingmemory('MERPWaveViewer_label',MERPWaveViewer_label);
    end

%%***********************************************************************%%
%%--------------------------Sub function---------------------------------%%
%%***********************************************************************%%
%%-------------------------Setting for load--------------------------------
    function labelauto(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=5
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_labels',1);
        gui_labelset_waveviewer.Apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_labelset_waveviewer.Apply.ForegroundColor = [1 1 1];
        box_erplabelset_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_labelset_waveviewer.labelauto.Value = 1;
        gui_labelset_waveviewer.nolabel.Value = 0;
        gui_labelset_waveviewer.customlabel.Value = 0;
        Enable = 'off';
        gui_labelset_waveviewer.xperc_edit.Enable =Enable ;
        gui_labelset_waveviewer.yperc_edit.Enable = Enable;
        gui_labelset_waveviewer.center.Enable = Enable;
        gui_labelset_waveviewer.font_custom_type.Enable = Enable;
        gui_labelset_waveviewer.font_custom_size.Enable = Enable;
        gui_labelset_waveviewer.font_custom_type.Value = 3;
        gui_labelset_waveviewer.font_custom_size.Value = 4;
        gui_labelset_waveviewer.xperc_edit.String ='50' ;
        gui_labelset_waveviewer.yperc_edit.String = '100';
        gui_labelset_waveviewer.labelcolor.Enable = Enable;
        gui_labelset_waveviewer.label_customtable.Enable = Enable;
        gui_labelset_waveviewer.labelcolor.Value = 1;
        %%----------------Update the label-----------------
        try
            ALLERPwaviewer = evalin('base','ALLERPwaviewer');
            ERPwaviewer = ALLERPwaviewer;
        catch
            beep;
            disp('f_ERP_labelset_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        
        binArray = ERPwaviewer.bin;
        chanArray = ERPwaviewer.chan;
        ERPsetArray = ERPwaviewer.SelectERPIdx;
        ALLERPIN = ERPwaviewer.ALLERP;
        if max(ERPsetArray) >length(ALLERPIN)
            ERPsetArray =length(ALLERPIN);
        end
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERPIN,ERPsetArray);
        for ii = 1:100
            LabelName{ii,1} = '';
            LabelNamenum(ii,1) =ii;
        end
        if ERPwaviewer.plot_org.Grid ==1 %% if  the selected Channel is "Grid"
            plotArray = chanArray;
            for Numofplot = 1:numel(plotArray)
                LabelName{Numofplot,1} = chanStr{plotArray(Numofplot)};
            end
        elseif ERPwaviewer.plot_org.Grid == 2 %% if the selected Bin is "Grid"
            plotArray = binArray;
            for Numofplot = 1:numel(plotArray)
                LabelName{Numofplot,1} = chanStr{plotArray(Numofplot)};
            end
        elseif ERPwaviewer.plot_org.Grid == 3%% if the selected ERPset is "Grid"
            plotArray = ERPsetArray;
            for Numoferpset = 1:numel(plotArray)
                LabelName{Numoferpset,1} = {char(ALLERPIN(plotArray(Numoferpset)).erpname)};
            end
        else
            plotArray = chanArray;
            for Numofplot = 1:numel(plotArray)
                LabelName{Numofplot,1} = chanStr{plotArray(Numofplot)};
            end
        end
        
        labels_str = table(LabelNamenum,LabelName);
        labels_str = table2cell(labels_str);
        gui_labelset_waveviewer.label_customtable.Data = labels_str;
    end

%%-------------------------Setting for Save--------------------------------
    function nolabel(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=5
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_labels',1);
        gui_labelset_waveviewer.Apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_labelset_waveviewer.Apply.ForegroundColor = [1 1 1];
        box_erplabelset_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_labelset_waveviewer.labelauto.Value = 0;
        gui_labelset_waveviewer.nolabel.Value = 1;
        gui_labelset_waveviewer.customlabel.Value = 0;
        Enable = 'off';
        gui_labelset_waveviewer.xperc_edit.Enable =Enable ;
        gui_labelset_waveviewer.yperc_edit.Enable = Enable;
        gui_labelset_waveviewer.center.Enable = Enable;
        gui_labelset_waveviewer.font_custom_type.Enable = Enable;
        gui_labelset_waveviewer.font_custom_size.Enable = Enable;
        gui_labelset_waveviewer.labelcolor.Enable = Enable;
        gui_labelset_waveviewer.label_customtable.Enable = Enable;
    end

%%-------------------------Setting for Save as-----------------------------
    function customlabel(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=5
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_labels',1);
        gui_labelset_waveviewer.Apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_labelset_waveviewer.Apply.ForegroundColor = [1 1 1];
        box_erplabelset_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_labelset_waveviewer.labelauto.Value = 0;
        gui_labelset_waveviewer.nolabel.Value =0;
        gui_labelset_waveviewer.customlabel.Value = 1;
        Enable = 'on';
        gui_labelset_waveviewer.xperc_edit.Enable =Enable ;
        gui_labelset_waveviewer.yperc_edit.Enable = Enable;
        gui_labelset_waveviewer.center.Enable = Enable;
        gui_labelset_waveviewer.font_custom_type.Enable = Enable;
        gui_labelset_waveviewer.font_custom_size.Enable = Enable;
        gui_labelset_waveviewer.labelcolor.Enable = Enable;
        gui_labelset_waveviewer.label_customtable.Enable = Enable;
    end

%%-------------------X percentage------------------------------------------
    function label_xperc(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=5
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_labels',1);
        gui_labelset_waveviewer.Apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_labelset_waveviewer.Apply.ForegroundColor = [1 1 1];
        box_erplabelset_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        if isempty(str2num(Source.String)) || numel(str2num(Source.String))~=1
            viewer_ERPDAT.Process_messg =4;
            messgStr =  strcat('Chan/Bin/ERPset Label Properties > X% should a number and we therefore used 50');
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            gui_labelset_waveviewer.xperc_edit.String ='50' ;
        end
    end

%%-------------------Y percentage------------------------------------------
    function label_yperc(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=5
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_labels',1);
        gui_labelset_waveviewer.Apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_labelset_waveviewer.Apply.ForegroundColor = [1 1 1];
        box_erplabelset_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
        if isempty(str2num(Source.String)) || numel(str2num(Source.String))~=1
            viewer_ERPDAT.Process_messg =4;
            messgStr =  strcat('Chan/Bin/ERPset Label Properties > Y% should a number and we therefore used 100');
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            gui_labelset_waveviewer.yperc_edit.String = '100';
        end
    end

%%-------------------------center for label text---------------------------
    function label_center(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=5
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_labels',1);
        gui_labelset_waveviewer.Apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_labelset_waveviewer.Apply.ForegroundColor = [1 1 1];
        box_erplabelset_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
    end

%%--------------------------Font of label text-----------------------------
    function label_font(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=5
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_labels',1);
        gui_labelset_waveviewer.Apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_labelset_waveviewer.Apply.ForegroundColor = [1 1 1];
        box_erplabelset_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
    end

%%------------------------Fontsize of label text---------------------------
    function label_fontsize(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=5
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_labels',1);
        gui_labelset_waveviewer.Apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_labelset_waveviewer.Apply.ForegroundColor = [1 1 1];
        box_erplabelset_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
    end

%%-----------------------color of label text-------------------------------
    function label_color(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=5
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_labels',1);
        gui_labelset_waveviewer.Apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_labelset_waveviewer.Apply.ForegroundColor = [1 1 1];
        box_erplabelset_viewer_property.TitleColor= [0.4940 0.1840 0.5560];
    end

%%--------------------------Help-------------------------------------------
    function label_help(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=5
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        MessageViewer= char(strcat('Chan/Bin/ERPset Labels > Cancel'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        changeFlag =  estudioworkingmemory('MyViewer_labels');
        if changeFlag~=1
            MessageViewer= char(strcat('Chan/Bin/ERPset Labels > Cancel'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =2;
            return;
        end
        
        try
            ERPwaviewer_apply = evalin('base','ALLERPwaviewer');
        catch
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n Chan/Bin/ERPset Labels > Apply-f_ERP_labelset_waveviewer_GUI() error: Cannot get parameters for whole panel.\n Please run My viewer again.\n\n');
            return;
        end
        
        if ERPwaviewer_apply.chanbinsetlabel.location.auto==1
            Enable = 'off';
            gui_labelset_waveviewer.labelauto.Value = 1;
            gui_labelset_waveviewer.nolabel.Value = 0;
            gui_labelset_waveviewer.customlabel.Value = 0;
        elseif ERPwaviewer_apply.chanbinsetlabel.location.no==1
            Enable = 'off';
            gui_labelset_waveviewer.labelauto.Value = 0;
            gui_labelset_waveviewer.nolabel.Value = 1;
            gui_labelset_waveviewer.customlabel.Value = 0;
        elseif ERPwaviewer_apply.chanbinsetlabel.location.custom==1
            Enable = 'on';
            gui_labelset_waveviewer.labelauto.Value = 0;
            gui_labelset_waveviewer.nolabel.Value = 0;
            gui_labelset_waveviewer.customlabel.Value = 1;
        end
        gui_labelset_waveviewer.xperc_edit.Enable = Enable;
        gui_labelset_waveviewer.xperc_edit.String = num2str( ERPwaviewer_apply.chanbinsetlabel.location.xperc);
        gui_labelset_waveviewer.yperc_edit.Enable = Enable;
        gui_labelset_waveviewer.yperc_edit.String = num2str( ERPwaviewer_apply.chanbinsetlabel.location.yperc);
        gui_labelset_waveviewer.font_custom_type.Enable = Enable;
        gui_labelset_waveviewer.font_custom_type.Value = ERPwaviewer_apply.chanbinsetlabel.font;
        gui_labelset_waveviewer.font_custom_size.Enable = Enable;
        FontSize = ERPwaviewer_apply.chanbinsetlabel.fontsize;
        fontsizeStr  = {'4','6','8','10','12','14','16','18','20','24','28','32','36',...
            '40','50','60','70','80','90','100'};
        labelfontsizeinum = str2num(char(fontsizeStr));
        [X_label,Y_label] = find(labelfontsizeinum==FontSize);
        if isempty(X_label) ||  X_label> numel(labelfontsizeinum)
            X_label = 4;
        end
        gui_labelset_waveviewer.font_custom_size.Value = X_label;
        gui_labelset_waveviewer.labelcolor.Enable = Enable;
        gui_labelset_waveviewer.labelcolor.Value = ERPwaviewer_apply.chanbinsetlabel.textcolor;
        gui_labelset_waveviewer.center.Enable = Enable;
        gui_labelset_waveviewer.center.Value = ERPwaviewer_apply.chanbinsetlabel.location.center;
        
        estudioworkingmemory('MyViewer_labels',0);
        gui_labelset_waveviewer.Apply.BackgroundColor =  [1 1 1];
        gui_labelset_waveviewer.Apply.ForegroundColor = [0 0 0];
        box_erplabelset_viewer_property.TitleColor= [0.5 0.5 0.9];
        MessageViewer= char(strcat('Chan/Bin/ERPset Labels > Cancel'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =2;
    end

%%------------------------------Apply--------------------------------------
    function label_apply(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=5
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        
        estudioworkingmemory('MyViewer_labels',0);
        gui_labelset_waveviewer.Apply.BackgroundColor =  [1 1 1];
        gui_labelset_waveviewer.Apply.ForegroundColor = [0 0 0];
        box_erplabelset_viewer_property.TitleColor= [0.5 0.5 0.9];
        
        MessageViewer= char(strcat('Chan/Bin/ERPset Labels > Apply'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        try
            ERPwaviewer_apply = evalin('base','ALLERPwaviewer');
        catch
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n Chan/Bin/ERPset Labels > Apply-f_ERP_labelset_waveviewer_GUI() error: Cannot get parameters for whole panel.\n Please run My viewer again.\n\n');
            return;
        end
        ERPwaviewer_apply.chanbinsetlabel.location.auto = gui_labelset_waveviewer.labelauto.Value;
        ERPwaviewer_apply.chanbinsetlabel.location.no = gui_labelset_waveviewer.nolabel.Value;
        ERPwaviewer_apply.chanbinsetlabel.location.custom =gui_labelset_waveviewer.customlabel.Value;
        ERPwaviewer_apply.chanbinsetlabel.location.xperc = str2num(char(gui_labelset_waveviewer.xperc_edit.String));
        ERPwaviewer_apply.chanbinsetlabel.location.yperc = str2num(char(gui_labelset_waveviewer.yperc_edit.String));
        MERPWaveViewer_label{1} = ERPwaviewer_apply.chanbinsetlabel.location.auto;
        MERPWaveViewer_label{2} = ERPwaviewer_apply.chanbinsetlabel.location.no;
        MERPWaveViewer_label{3} =ERPwaviewer_apply.chanbinsetlabel.location.custom;
        MERPWaveViewer_label{4} =ERPwaviewer_apply.chanbinsetlabel.location.xperc;
        MERPWaveViewer_label{5} =ERPwaviewer_apply.chanbinsetlabel.location.yperc;
        
        if ( ERPwaviewer_apply.chanbinsetlabel.location.no==1 ||  ERPwaviewer_apply.chanbinsetlabel.location.custom ==1) &&  (isempty(ERPwaviewer_apply.chanbinsetlabel.location.xperc) || isempty(ERPwaviewer_apply.chanbinsetlabel.location.yperc))
            ERPwaviewer_apply.chanbinsetlabel.location.auto = 1;
            ERPwaviewer_apply.chanbinsetlabel.location.no = 0;
            ERPwaviewer_apply.chanbinsetlabel.location.custom =0;
        end
        ERPwaviewer_apply.chanbinsetlabel.location.center = gui_labelset_waveviewer.center.Value;
        MERPWaveViewer_label{6} = ERPwaviewer_apply.chanbinsetlabel.location.center;
        
        fontsize  = {'4','6','8','10','12','14','16','18','20','24','28','32','36',...
            '40','50','60','70','80','90','100'};
        labelfontsizeinum = str2num(char(fontsize));
        ERPwaviewer_apply.chanbinsetlabel.font = gui_labelset_waveviewer.font_custom_type.Value;
        MERPWaveViewer_label{7} = ERPwaviewer_apply.chanbinsetlabel.font;
        try
            ERPwaviewer_apply.chanbinsetlabel.fontsize = labelfontsizeinum(gui_labelset_waveviewer.font_custom_size.Value);
        catch
            ERPwaviewer_apply.chanbinsetlabel.fontsize = 10;
        end
        ERPwaviewer_apply.chanbinsetlabel.textcolor = gui_labelset_waveviewer.labelcolor.Value;
        MERPWaveViewer_label{8}  = gui_labelset_waveviewer.font_custom_size.Value;
        MERPWaveViewer_label{9}  = ERPwaviewer_apply.chanbinsetlabel.textcolor;
        
        ALLERPwaviewer=ERPwaviewer_apply;
        assignin('base','ALLERPwaviewer',ALLERPwaviewer);
        f_redrawERP_viewer_test();
        viewer_ERPDAT.Process_messg =2;
        estudioworkingmemory('MERPWaveViewer_label',MERPWaveViewer_label);
    end


%%-------------change this panel based on the loaded parameters------------
    function loadproper_change(~,~)
        if viewer_ERPDAT.loadproper_count ~=5
            return;
        end
        try
            ERPwaviewer_apply = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp('f_ERP_labelset_waveviewer_GUI() > Apply error: Please run the ERP wave viewer again.');
            return;
        end
        AutoValue =  ERPwaviewer_apply.chanbinsetlabel.location.auto;
        NoValue =  ERPwaviewer_apply.chanbinsetlabel.location.no;
        CustomValue =  ERPwaviewer_apply.chanbinsetlabel.location.custom;
        if AutoValue ==1 && NoValue==0 && CustomValue==0
            gui_labelset_waveviewer.labelauto.Value = 1;
            gui_labelset_waveviewer.nolabel.Value = 0;
            gui_labelset_waveviewer.customlabel.Value = 0;
            Enable = 'off';
            gui_labelset_waveviewer.xperc_edit.Enable =Enable ;
            gui_labelset_waveviewer.yperc_edit.Enable = Enable;
            gui_labelset_waveviewer.center.Enable = Enable;
            gui_labelset_waveviewer.font_custom_type.Enable = Enable;
            gui_labelset_waveviewer.font_custom_size.Enable = Enable;
            gui_labelset_waveviewer.font_custom_type.Value = 2;
            gui_labelset_waveviewer.font_custom_size.Value = 4;
            gui_labelset_waveviewer.xperc_edit.String ='50' ;
            gui_labelset_waveviewer.yperc_edit.String = '100';
            gui_labelset_waveviewer.labelcolor.Enable = Enable;
            gui_labelset_waveviewer.label_customtable.Enable = Enable;
        elseif AutoValue ==0 && NoValue==1 && CustomValue==0
            gui_labelset_waveviewer.labelauto.Value = 0;
            gui_labelset_waveviewer.nolabel.Value = 1;
            gui_labelset_waveviewer.customlabel.Value = 0;
            Enable = 'off';
            gui_labelset_waveviewer.xperc_edit.Enable =Enable ;
            gui_labelset_waveviewer.yperc_edit.Enable = Enable;
            gui_labelset_waveviewer.center.Enable = Enable;
            gui_labelset_waveviewer.font_custom_type.Enable = Enable;
            gui_labelset_waveviewer.font_custom_size.Enable = Enable;
            gui_labelset_waveviewer.labelcolor.Enable = Enable;
            gui_labelset_waveviewer.label_customtable.Enable = Enable;
        elseif AutoValue ==0 && NoValue==0 && CustomValue==1
            gui_labelset_waveviewer.labelauto.Value = 0;
            gui_labelset_waveviewer.nolabel.Value =0;
            gui_labelset_waveviewer.customlabel.Value = 1;
            Enable = 'on';
            gui_labelset_waveviewer.xperc_edit.Enable =Enable ;
            gui_labelset_waveviewer.yperc_edit.Enable = Enable;
            gui_labelset_waveviewer.center.Enable = Enable;
            gui_labelset_waveviewer.font_custom_type.Enable = Enable;
            gui_labelset_waveviewer.font_custom_size.Enable = Enable;
            gui_labelset_waveviewer.labelcolor.Enable = Enable;
            gui_labelset_waveviewer.label_customtable.Enable = Enable;
        end
        Xperc = ERPwaviewer_apply.chanbinsetlabel.location.xperc;
        Yperc  = ERPwaviewer_apply.chanbinsetlabel.location.yperc;
        Center = ERPwaviewer_apply.chanbinsetlabel.location.center;
        gui_labelset_waveviewer.xperc_edit.String = num2str(Xperc);
        gui_labelset_waveviewer.yperc_edit.String = num2str(Yperc);
        if Center ==1
            gui_labelset_waveviewer.center.Value = 1;
        else
            gui_labelset_waveviewer.center.Value = 0;
        end
        Labelfont = ERPwaviewer_apply.chanbinsetlabel.font;
        gui_labelset_waveviewer.font_custom_type.Value = Labelfont;
        Labelfontsize = ERPwaviewer_apply.chanbinsetlabel.fontsize;
        fontsize  = {'4','6','8','10','12','14','16','18','20','24','28','32','36',...
            '40','50','60','70','80','90','100'};
        fontsize = str2num(char(fontsize));
        [xsize,y] = find(fontsize ==Labelfontsize);
        gui_labelset_waveviewer.font_custom_size.Value = xsize;
        textColor = ERPwaviewer_apply.chanbinsetlabel.textcolor;
        gui_labelset_waveviewer.labelcolor.Value = textColor;
        viewer_ERPDAT.loadproper_count =6;
        
        %%save the parameters to memory file
        MERPWaveViewer_label{1} = ERPwaviewer_apply.chanbinsetlabel.location.auto;
        MERPWaveViewer_label{2} = ERPwaviewer_apply.chanbinsetlabel.location.no;
        MERPWaveViewer_label{3} =ERPwaviewer_apply.chanbinsetlabel.location.custom;
        MERPWaveViewer_label{4} =ERPwaviewer_apply.chanbinsetlabel.location.xperc;
        MERPWaveViewer_label{5} =ERPwaviewer_apply.chanbinsetlabel.location.yperc;
        MERPWaveViewer_label{6} = ERPwaviewer_apply.chanbinsetlabel.location.center;
        MERPWaveViewer_label{7} = ERPwaviewer_apply.chanbinsetlabel.font;
        MERPWaveViewer_label{8}  = gui_labelset_waveviewer.font_custom_size.Value;
        MERPWaveViewer_label{9}  = ERPwaviewer_apply.chanbinsetlabel.textcolor;
        estudioworkingmemory('MERPWaveViewer_label',MERPWaveViewer_label);
    end


%%-------------------------------------------------------------------------
%%Automatically saving the changed parameters for the current panel if the
%%user change parameters for the other panels.
%%-------------------------------------------------------------------------
    function count_twopanels_change(~,~)
        if viewer_ERPDAT.count_twopanels==0
            return;
        end
        changeFlag =  estudioworkingmemory('MyViewer_labels');
        if changeFlag~=1
            return;
        end
        label_apply();
    end

%%-------------------------------------------------------------------------
%%-----------------Reset this panel with the default parameters------------
%%-------------------------------------------------------------------------
    function Reset_Waviewer_panel_change(~,~)
        if viewer_ERPDAT.Reset_Waviewer_panel==5
            try
                ERPwaviewerin = evalin('base','ALLERPwaviewer');
            catch
                beep;
                disp('f_ERP_labelset_waveviewer_GUI error: Restart ERPwave Viewer');
                return;
            end
            gui_labelset_waveviewer.labelauto.Value=1; %
            gui_labelset_waveviewer.nolabel.Value=0; %
            gui_labelset_waveviewer.customlabel.Value=0; %
            ERPwaviewerin.chanbinsetlabel.location.auto =1;
            ERPwaviewerin.chanbinsetlabel.location.no =0;
            ERPwaviewerin.chanbinsetlabel.location.custom=0;
            %%label position
            gui_labelset_waveviewer.xperc_edit.String = '50';
            gui_labelset_waveviewer.xperc_edit.Enable ='off'; %
            gui_labelset_waveviewer.yperc_edit.String ='100';
            gui_labelset_waveviewer.yperc_edit.Enable='off'; %
            gui_labelset_waveviewer.center.Value =1;
            gui_labelset_waveviewer.center.Enable='off'; %
            ERPwaviewerin.chanbinsetlabel.location.xperc =50;
            ERPwaviewerin.chanbinsetlabel.location.yperc = 100;
            ERPwaviewerin.chanbinsetlabel.location.center =1;
            %%label font, fontsize and color
            ERPwaviewerin.chanbinsetlabel.font =3;
            ERPwaviewerin.chanbinsetlabel.fontsize =10;
            ERPwaviewerin.chanbinsetlabel.textcolor=1;
            fonttype = {'Courier','Geneva','Helvetica','Monaco','Times'};
            gui_labelset_waveviewer.font_custom_type.Value=3;
            gui_labelset_waveviewer.font_custom_type.String = fonttype;
            gui_labelset_waveviewer.font_custom_type.Enable='off'; %
            gui_labelset_waveviewer.font_custom_size.Value=4;
            gui_labelset_waveviewer.font_custom_size.Enable='off'; %
            gui_labelset_waveviewer.labelcolor.Value=1;
            gui_labelset_waveviewer.labelcolor.Enable='off'; %
            assignin('base','ALLERPwaviewer',ERPwaviewerin);
            gui_labelset_waveviewer.Apply.BackgroundColor =  [1 1 1];
            gui_labelset_waveviewer.Apply.ForegroundColor = [0 0 0];
            box_erplabelset_viewer_property.TitleColor= [0.5 0.5 0.9];
            
            %%save the default parameters to memory file
            MERPWaveViewer_label{1} = ERPwaviewerin.chanbinsetlabel.location.auto;
            MERPWaveViewer_label{2} = ERPwaviewerin.chanbinsetlabel.location.no;
            MERPWaveViewer_label{3} =ERPwaviewerin.chanbinsetlabel.location.custom;
            MERPWaveViewer_label{4} =ERPwaviewerin.chanbinsetlabel.location.xperc;
            MERPWaveViewer_label{5} =ERPwaviewerin.chanbinsetlabel.location.yperc;
            MERPWaveViewer_label{6} = ERPwaviewerin.chanbinsetlabel.location.center;
            MERPWaveViewer_label{7} = ERPwaviewerin.chanbinsetlabel.font;
            MERPWaveViewer_label{8}  = gui_labelset_waveviewer.font_custom_size.Value;
            MERPWaveViewer_label{9}  = ERPwaviewerin.chanbinsetlabel.textcolor;
            estudioworkingmemory('MERPWaveViewer_label',MERPWaveViewer_label);
            
            viewer_ERPDAT.Reset_Waviewer_panel=6;
        end
    end

%%using "Return" key to execute this panel
    function labels_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            label_apply();
            estudioworkingmemory('MyViewer_labels',0);
            gui_labelset_waveviewer.Apply.BackgroundColor =  [1 1 1];
            gui_labelset_waveviewer.Apply.ForegroundColor = [0 0 0];
            box_erplabelset_viewer_property.TitleColor= [0.5 0.5 0.9];
        else
            return;
        end
    end

end