%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 2022 && 2023 Oct.

% ERPLAB Studio

function varargout = f_ERP_plot_scalp_GUI(varargin)
global observe_ERPDAT;
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);
addlistener(observe_ERPDAT,'erp_two_panels_change',@erp_two_panels_change);
addlistener(observe_ERPDAT,'Reset_erp_panel_change',@Reset_erp_panel_change);

gui_erp_scalp_map = struct();
%-----------------------------Name the title----------------------------------------------
% global ERP_plot_scalp_gui;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    ERP_plot_scalp_gui = uiextras.BoxPanel('Parent', fig, 'Title', 'Plot Scalp Maps',...
        'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    ERP_plot_scalp_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Plot Scalp Maps',...
        'Padding', 5,'BackgroundColor',ColorB_def);
else
    ERP_plot_scalp_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Plot Scalp Maps',...
        'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);%, 'HelpFcn', @scap_help
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
drawui_erp_scalp_operation(FonsizeDefault);

varargout{1} = ERP_plot_scalp_gui;

    function drawui_erp_scalp_operation(FonsizeDefault)
        Enable_label = 'off';
        plegend.binnum = 1;
        plegend.bindesc = 1;
        plegend.type = 1;
        plegend.latency = 1;
        plegend.electrodes = 0;
        plegend.elestyle = 'on';
        plegend.elec3D = 'off';
        plegend.colorbar = 1;
        plegend.colormap = 0;
        plegend.maximize = 0;
        estudioworkingmemory('pscalp_plegend',plegend);
        agif.value =0;
        agif.fps =[];
        agif.fname ='';
        estudioworkingmemory('pscalp_agif',agif);
        
        ERPTab_plotscalp= estudioworkingmemory('ERPTab_plotscalp');
        
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------bin and latency setting----------------------
        gui_erp_scalp_map.ERPscalpops = uiextras.VBox('Parent', ERP_plot_scalp_gui,'BackgroundColor',ColorB_def);
        
        
        %%%------------BIN TO PLOT---------------------
        gui_erp_scalp_map.measurement_title = uiextras.HBox('Parent', gui_erp_scalp_map.ERPscalpops,'BackgroundColor',ColorB_def);
        gui_erp_scalp_map.measurement = uicontrol('Style', 'popupmenu','Parent', gui_erp_scalp_map.measurement_title,...
            'callback',@measurement_methods, 'String','','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable',Enable_label);
        measurearray = {'Instantaneous amplitude','Mean amplitude between two fixed latencies',...
            'Instantaneous amplitude Laplacian', 'Mean amplitude Laplacian', 'Root mean square value'};
        set(gui_erp_scalp_map.measurement,'String',measurearray,'Value',2);
        ERPTab_plotscalp{10} = gui_erp_scalp_map.measurement.Value;
        gui_erp_scalp_map.measurement.KeyPressFcn=  @erp_scalps_presskey;
        
        gui_erp_scalp_map.measurement_title1 = uiextras.HBox('Parent', gui_erp_scalp_map.ERPscalpops,'BackgroundColor',ColorB_def);
        gui_erp_scalp_map.measurement_exp = uicontrol('Style', 'text','Parent', gui_erp_scalp_map.measurement_title1,...
            'String','(min max pairs e.g., 300 400 ; 400 500)','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        gui_erp_scalp_map.bin_plot_title = uiextras.HBox('Parent', gui_erp_scalp_map.ERPscalpops,'BackgroundColor',ColorB_def);
        gui_erp_scalp_map.bin_plot = uicontrol('Style','text','Parent',gui_erp_scalp_map.bin_plot_title,...
            'String','Bin(s)','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 2F
        set(gui_erp_scalp_map.bin_plot,'HorizontalAlignment','left');
        gui_erp_scalp_map.bin_plot_edit = uicontrol('Style','edit','Parent',gui_erp_scalp_map.bin_plot_title,...
            'String','','callback',@scalp_bin_edit,'FontSize',FonsizeDefault,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        try binArray = ERPTab_plotscalp{1}; catch binArray = [];ERPTab_plotscalp{1} = [];end
        gui_erp_scalp_map.bin_plot_edit.String = num2str(binArray);
        
        gui_erp_scalp_map.bin_plot_edit.KeyPressFcn=  @erp_scalps_presskey;
        gui_erp_scalp_map.bin_plot_opt = uicontrol('Style','pushbutton','Parent',gui_erp_scalp_map.bin_plot_title,...
            'String','Browse','callback',@scalp_bin_op,'FontSize',FonsizeDefault,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        set(gui_erp_scalp_map.bin_plot_title ,'Sizes',[60 150 60]);
        
        %%%------------Latency TO PLOT---------------------
        gui_erp_scalp_map.latency_plot_title = uiextras.HBox('Parent', gui_erp_scalp_map.ERPscalpops,'BackgroundColor',ColorB_def);
        gui_erp_scalp_map.latency_plot = uicontrol('Style','text','Parent',gui_erp_scalp_map.latency_plot_title,...
            'String','Latency (ms) [min max]','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 2F
        set(gui_erp_scalp_map.latency_plot,'HorizontalAlignment','left');
        gui_erp_scalp_map.latency_plot_edit = uicontrol('Style','edit','Parent',gui_erp_scalp_map.latency_plot_title,...
            'String','','callback',@scalp_latency_plot,'FontSize',FonsizeDefault,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        gui_erp_scalp_map.latency_plot_edit.KeyPressFcn=  @erp_scalps_presskey;
        try Latency = ERPTab_plotscalp{2}; catch Latency = [];ERPTab_plotscalp{2} = [];end
        Latencystr = '';
        for ii = 1:size(Latency,1)
            if ii==1
                Latencystr = [num2str(Latency(ii,:))];
            else
                Latencystr = [Latencystr,';',num2str(Latency(ii,:))];
            end
        end
        gui_erp_scalp_map.latency_plot_edit.String = Latencystr;
        
        %%----------------------------------Map Type------------------------------
        gui_erp_scalp_map.map_type_title = uiextras.HBox('Parent',  gui_erp_scalp_map.ERPscalpops,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', gui_erp_scalp_map.map_type_title,...
            'String','Map Type:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        %%2d
        gui_erp_scalp_map.map_type = uiextras.Grid('Parent',gui_erp_scalp_map.ERPscalpops,'BackgroundColor',ColorB_def);
        %
        gui_erp_scalp_map.map_type_2d = uicontrol('Style', 'radiobutton','Parent', gui_erp_scalp_map.map_type,...
            'String','2D','callback',@map_type_2d,'Value',1,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_scalp_map.map_type_2d.KeyPressFcn=  @erp_scalps_presskey;
        try map2d = ERPTab_plotscalp{3}; catch map2d=1;ERPTab_plotscalp{3} = 1;end
        if isempty(map2d) || numel(map2d)~=1 || (map2d~=0 && map2d~=1)
            map2d=1;
        end
        gui_erp_scalp_map.map_type_2d.Value= map2d;
        
        gui_erp_scalp_map.map_type_3d = uicontrol('Style', 'radiobutton','Parent', gui_erp_scalp_map.map_type,...
            'String','3D','callback',@map_type_3d,'Value',~map2d,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_scalp_map.map_type_3d.KeyPressFcn=  @erp_scalps_presskey;
        
        gui_erp_scalp_map.map_type_2d_type = uicontrol('Style', 'popupmenu','Parent',gui_erp_scalp_map.map_type,...
            'callback',@map_type_2d_type,'String',{'map','contour','both','fill','blank'},'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        try twodtyep  = ERPTab_plotscalp{4}; catch twodtyep=1;ERPTab_plotscalp{4} = 1;end
        if isempty(twodtyep) || numel(twodtyep)~=1 || any(twodtyep>5) || any(twodtyep<1)
            twodtyep=1;ERPTab_plotscalp{4} = 1;
        end
        gui_erp_scalp_map.map_type_2d_type.Value=twodtyep;
        
        gui_erp_scalp_map.map_type_3d_spl = uicontrol('Style', 'pushbutton','Parent',gui_erp_scalp_map.map_type,...
            'String','Spline','callback',@map_type_3d_spl,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        gui_erp_scalp_map.map_type_2d_type_outside = uicontrol('Style', 'checkbox','Parent',gui_erp_scalp_map.map_type,...
            'String','Outside','Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', gui_erp_scalp_map.map_type);
        try mapoutside = ERPTab_plotscalp{5}; catch mapoutside=0;ERPTab_plotscalp{5} = 0;end
        if isempty(mapoutside) || numel(mapoutside)~=1 || (mapoutside~=0 && mapoutside~=1)
            mapoutside=0;
            ERPTab_plotscalp{5}=0;
        end
        gui_erp_scalp_map.map_type_2d_type_outside.Value = mapoutside;
        set(gui_erp_scalp_map.map_type, 'ColumnSizes',[50 130 90],'RowSizes',[25 30]);
        
        %%----------------------------------Bar scale------------------------------
        gui_erp_scalp_map.bar_scale_title = uiextras.HBox('Parent',  gui_erp_scalp_map.ERPscalpops,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', gui_erp_scalp_map.bar_scale_title,...
            'String','Color Bar Scale:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        gui_erp_scalp_map.bar_scale = uiextras.HBox('Parent',gui_erp_scalp_map.ERPscalpops,'BackgroundColor',ColorB_def);
        gui_erp_scalp_map.max_min = uicontrol('Style', 'radiobutton','Parent', gui_erp_scalp_map.bar_scale,...
            'String','Max-Min','callback',@bar_scale_max_min,'Value',1,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_scalp_map.max_min.KeyPressFcn=  @erp_scalps_presskey;
        gui_erp_scalp_map.custom_option = uicontrol('Style', 'radiobutton','Parent',gui_erp_scalp_map.bar_scale,...
            'String','Custom (min max:e.g.uv)','callback',@bar_scale_custom_opt,'Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_scalp_map.custom_option.KeyPressFcn=  @erp_scalps_presskey;
        set(gui_erp_scalp_map.bar_scale ,'Sizes',[100 170]);
        
        gui_erp_scalp_map.bar_scale_2 = uiextras.HBox('Parent',gui_erp_scalp_map.ERPscalpops,'BackgroundColor',ColorB_def);
        gui_erp_scalp_map.abs_max = uicontrol('Style', 'radiobutton','Parent', gui_erp_scalp_map.bar_scale_2,...
            'String','Abs Max','callback',@bar_scale_abs_max,'Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_scalp_map.abs_max.KeyPressFcn=  @erp_scalps_presskey;
        gui_erp_scalp_map.bar_scale_custom_option_edit = uicontrol('Style', 'edit','Parent',gui_erp_scalp_map.bar_scale_2,...
            'String',' ','callback',@bar_scale_custom_edit,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        gui_erp_scalp_map.bar_scale_custom_option_edit.KeyPressFcn=  @erp_scalps_presskey;
        set(gui_erp_scalp_map.bar_scale_2 ,'Sizes',[100 170]);
        try barscale = ERPTab_plotscalp{6}; catch barscale=1;ERPTab_plotscalp{65} = 1;end
        if isempty(barscale) || (numel(barscale)~=1 && numel(barscale)~=2)
            barscale=1;
            ERPTab_plotscalp{6}=1;
        end
        if numel(barscale)==1
            if barscale~=1 && barscale~=2
                barscale=1;
                ERPTab_plotscalp{6}=1;
            end
            if barscale==1
                gui_erp_scalp_map.max_min.Value=1;
                gui_erp_scalp_map.abs_max.Value=0;
                gui_erp_scalp_map.custom_option.Value=0;
            else
                gui_erp_scalp_map.max_min.Value=0;
                gui_erp_scalp_map.abs_max.Value=1;
                gui_erp_scalp_map.custom_option.Value=0;
            end
        elseif numel(barscale)==2
            gui_erp_scalp_map.max_min.Value=0;
            gui_erp_scalp_map.abs_max.Value=0;
            gui_erp_scalp_map.custom_option.Value=1;
            gui_erp_scalp_map.bar_scale_custom_option_edit.String = num2str(barscale);
        else
            gui_erp_scalp_map.max_min.Value=1;
            gui_erp_scalp_map.abs_max.Value=0;
            gui_erp_scalp_map.custom_option.Value=0;
        end
        
        %%----------------------------------Map Extras------------------------------
        gui_erp_scalp_map.map_extras_title = uiextras.HBox('Parent',  gui_erp_scalp_map.ERPscalpops,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', gui_erp_scalp_map.map_extras_title,...
            'String','Map Extras:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        %%view
        gui_erp_scalp_map.map_extras_view = uiextras.HBox('Parent',gui_erp_scalp_map.ERPscalpops,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', gui_erp_scalp_map.map_extras_view,...
            'String','View','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'HorizontalAlignment','left');
        morimenu = {'front', 'back', 'right', 'left', 'top',...
            'frontleft', 'frontright', 'backleft', 'backright',...
            'custom'};
        gui_erp_scalp_map.map_extras_view_ops = uicontrol('Style', 'popupmenu','Parent',gui_erp_scalp_map.map_extras_view,...
            'String',morimenu,'callback',@map_extras_view_ops,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        gui_erp_scalp_map.map_extras_view_ops.KeyPressFcn=  @erp_scalps_presskey;
        gui_erp_scalp_map.map_extras_view_location = uicontrol('Style', 'edit','Parent',gui_erp_scalp_map.map_extras_view,...
            'String','','callback',@map_extras_view_location,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        gui_erp_scalp_map.map_extras_view_location.KeyPressFcn=  @erp_scalps_presskey;
        set(gui_erp_scalp_map.map_extras_view,'Sizes',[70 100 100]);
        if map2d==1
            gui_erp_scalp_map.map_extras_view_ops.Value=1;
            ERPTab_plotscalp{7}=1;
        else
            try mapextrc = ERPTab_plotscalp{7}; catch mapextrc=1;ERPTab_plotscalp{7} = 1;end
            if isempty(mapextrc) || numel(mapextrc)~=1 || any(mapextrc<1) || any(mapextrc>10)
                mapextrc=1;
                ERPTab_plotscalp{7}=1;
            end
            gui_erp_scalp_map.map_extras_view_ops.Value=mapextrc;
        end
        
        %%Extras
        gui_erp_scalp_map.map_extras_cmap_display= uiextras.HBox('Parent',gui_erp_scalp_map.ERPscalpops,'BackgroundColor',ColorB_def);
        
        gui_erp_scalp_map.map_extras_cmap = uicontrol('Style', 'text','Parent',  gui_erp_scalp_map.map_extras_cmap_display,...
            'String','Colormap','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(gui_erp_scalp_map.map_extras_cmap,'HorizontalAlignment','left');
        cMap_par={'jet','hsv','hot','cool','gray','viridis'};
        gui_erp_scalp_map.map_extras_cmap_ops = uicontrol('Style', 'popupmenu','Parent', gui_erp_scalp_map.map_extras_cmap_display,...
            'String',cMap_par,'callback',@colormap,'Value',1,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1,1,1]);
        try clormap = ERPTab_plotscalp{8}; catch clormap=1;ERPTab_plotscalp{8} = 1;end
        if isempty(clormap) || numel(clormap)~=1 || any(clormap<1) || any(clormap>6)
            clormap=1;
        end
        gui_erp_scalp_map.map_extras_cmap_ops.Value = clormap;
        
        gui_erp_scalp_map.map_extras_cmap_ops.KeyPressFcn=  @erp_scalps_presskey;
        gui_erp_scalp_map.map_extras_cmapb_disp = uicontrol('Style', 'checkbox','Parent', gui_erp_scalp_map.map_extras_cmap_display,...
            'callback',@dispbar,'String','Display color scale bar','Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_scalp_map.map_extras_cmapb_disp.String =  '<html>Display Color<br />Scale Bar</html>';
        gui_erp_scalp_map.map_extras_cmapb_disp.KeyPressFcn=  @erp_scalps_presskey;
        set(gui_erp_scalp_map.map_extras_cmap_display ,'Sizes',[70 90 110]);
        try dispbar = ERPTab_plotscalp{9}; catch dispbar=0;ERPTab_plotscalp{9} = 0;end
        if isempty(dispbar) || numel(dispbar)~=1 || (dispbar~=0 && dispbar~=1)
            dispbar=0;ERPTab_plotscalp{9} = 0;
        end
        gui_erp_scalp_map.map_extras_cmapb_disp.Value = dispbar;
        %%-----------------Run---------------------------------------------
        gui_erp_scalp_map.run_title = uiextras.HBox('Parent', gui_erp_scalp_map.ERPscalpops,'BackgroundColor',ColorB_def);
        
        gui_erp_scalp_map.cancel = uicontrol('Style','pushbutton','Parent',gui_erp_scalp_map.run_title,...
            'String','Cancel','callback',@scap_cancel,'FontSize',FonsizeDefault,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        
        gui_erp_scalp_map.advanced = uicontrol('Style','pushbutton','Parent',gui_erp_scalp_map.run_title,...
            'String','Options','callback',@apply_advanced,'FontSize',FonsizeDefault,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        
        gui_erp_scalp_map.run = uicontrol('Style','pushbutton','Parent',gui_erp_scalp_map.run_title,...
            'String','Plot','callback',@apply_run,'FontSize',FonsizeDefault,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        set(gui_erp_scalp_map.ERPscalpops,'Sizes',[25 20 25,25,25 55 20 30 25 20 25 30 30]);
        
        estudioworkingmemory('ERPTab_topos',0);
        estudioworkingmemory('ERPTab_plotscalp',ERPTab_plotscalp);
    end

%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

    function measurement_methods(Source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_topos',1);
        gui_erp_scalp_map.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_scalp_map.run.ForegroundColor = [1 1 1];
        ERP_plot_scalp_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_scalp_map.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.cancel.ForegroundColor = [1 1 1];
        gui_erp_scalp_map.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.advanced.ForegroundColor = [1 1 1];
        Value = gui_erp_scalp_map.measurement.Value;
        switch Value
            case {1,3}
                gui_erp_scalp_map.measurement_exp.String='(one or more: e.g. 300 or 100:50:350)';
            case {2,4,5}
                gui_erp_scalp_map.measurement_exp.String='(min max pairs: e.g., 300 400 ; 400 500)';
        end
    end


%%-------------------Input bin number--------------------------------------
    function scalp_bin_edit(Source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_topos',1);
        gui_erp_scalp_map.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_scalp_map.run.ForegroundColor = [1 1 1];
        ERP_plot_scalp_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_scalp_map.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.cancel.ForegroundColor = [1 1 1];
        gui_erp_scalp_map.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.advanced.ForegroundColor = [1 1 1];
        BinArray =  str2num(Source.String);
        if isempty(BinArray) || any(BinArray(:)>observe_ERPDAT.ERP.nbin) || any(BinArray(:)<=0)
            msgboxText =  ['Plot Scalp Maps>Bins-Indexes of bins should be between 1 and',32,num2str(observe_ERPDAT.ERP.nbin)];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            gui_erp_scalp_map.bin_plot_edit.String = '';
            return;
        end
    end

%%---------------------bin options---------------------------------
    function scalp_bin_op(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_topos',1);
        gui_erp_scalp_map.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_scalp_map.run.ForegroundColor = [1 1 1];
        ERP_plot_scalp_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_scalp_map.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.cancel.ForegroundColor = [1 1 1];
        gui_erp_scalp_map.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.advanced.ForegroundColor = [1 1 1];
        
        ERP_CURRENT = evalin('base','ERP');
        for Numofbin = 1:length(ERP_CURRENT.bindescr)
            listb{Numofbin} = char(strcat(num2str(Numofbin),'.',ERP_CURRENT.bindescr{Numofbin}));
        end
        try
            indxlistb = 1:ERP_CURRENT.nbin;
        catch
            return;
        end
        titlename = 'Select Bin(s):';
        %----------------judge the number of latency/latencies--------
        if ~isempty(listb)
            bin_label_select = browsechanbinGUI(listb, indxlistb, titlename);
            if ~isempty(bin_label_select)
                binset = vect2colon(bin_label_select,'Sort', 'on');
                binset = erase(binset,{'[',']'});
                gui_erp_scalp_map.bin_plot_edit.String=binset;
            else
                return
            end
        else
            msgboxText =  ['Plot Scalp Maps>Bins>Browse-No bin information was found',];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end%Program end: Judge the number of latency/latencies
        %         observe_ERPDAT.Count_currentERP = 1;
    end

%%----------------------Define time window (two latencies)-----------------
    function scalp_latency_plot(Source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_topos',1);
        gui_erp_scalp_map.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_scalp_map.run.ForegroundColor = [1 1 1];
        ERP_plot_scalp_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_scalp_map.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.cancel.ForegroundColor = [1 1 1];
        gui_erp_scalp_map.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.advanced.ForegroundColor = [1 1 1];
        
        ERP_times = observe_ERPDAT.ERP.times;
        meamenu = gui_erp_scalp_map.measurement.Value;
        switch meamenu
            case 1
                measurement = 'insta';
            case 2
                measurement = 'mean';
            case 3
                measurement = 'instalapla';
            case 4
                measurement = 'meanlapla';
            case 5
                measurement = 'rms';
            otherwise
                measurement = 'insta';
        end
        
        latencyArray   = str2num(gui_erp_scalp_map.latency_plot_edit.String);
        if isempty(latencyArray)
            return;
        end
        indxh   = find(latencyArray>ERP_times(end),1);
        if ~isempty(indxh)
            msgboxText =  ['Plot Scalp Maps> Latency of ' num2str(latencyArray(indxh)) ' is larger than ERP.xmax = ' num2str(ERP_times(end)) ' msec!'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            gui_erp_scalp_map.latency_plot_edit.String = '';
            return
        end
        
        indxl  = find(latencyArray<ERP_times(1),1);
        if ~isempty(indxl)
            msgboxText =  ['Plot Scalp Maps> Latency of ' num2str(latencyArray(indxl)) ' is smaller than ERP.xmin = ' num2str(ERP_times(1)) ' msec!'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            gui_erp_scalp_map.latency_plot_edit.String = '';
            return
        end
        
        switch meamenu
            case {2, 4, 5} % mean, meanlapla, rms
                if size(latencyArray,2)<2
                    msgboxText =  ['Plot Scalp Maps>latency> You must specify 2 latencies, at least, for getting %s-values.'...
                        'For specifying two or more mean value maps, please use semicolon (;) to separate each latency range.'...
                        'For instance, to plot mean value maps for 0 to 100 ms AND 400 to 500 ms just write 0 100;400 500'];
                    titlNamerro = 'Warning for ERP Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    
                    gui_erp_scalp_map.latency_plot_edit.String = '';
                    return
                end
            case {1,3} % insta, instalapla
                if size(latencyArray,1)>1
                    msgboxText =  'Plot Scalp Maps>latency>For you must specify as many latencies as maps you would like to plot.You cannot use semicolon-separated values.';
                    titlNamerro = 'Warning for ERP Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    return
                end
        end
    end


%%-----------------Dispaly topography with 2D------------------------------
    function map_type_2d(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_topos',1);
        gui_erp_scalp_map.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_scalp_map.run.ForegroundColor = [1 1 1];
        ERP_plot_scalp_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_scalp_map.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.cancel.ForegroundColor = [1 1 1];
        gui_erp_scalp_map.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.advanced.ForegroundColor = [1 1 1];
        gui_erp_scalp_map.map_type_2d.Value=1;
        gui_erp_scalp_map.map_type_3d.Value=0;
        set(gui_erp_scalp_map.map_type_2d_type,'Enable','on','Value',1);
        gui_erp_scalp_map.map_type_3d_spl.Enable = 'off';
        gui_erp_scalp_map.map_extras_view_ops.Enable = 'off';
        gui_erp_scalp_map.map_extras_view_ops.String = '+X';
        gui_erp_scalp_map.map_extras_view_ops.Value =1;
        gui_erp_scalp_map.map_extras_view_location.String = num2str([-180 30]);
        gui_erp_scalp_map.map_extras_view_location.Enable = 'off';
        gui_erp_scalp_map.map_type_2d_type_outside.Enable = 'on';
    end



%%-----------------Dispaly topography with 3D------------------------------
    function map_type_3d(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_topos',1);
        gui_erp_scalp_map.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_scalp_map.run.ForegroundColor = [1 1 1];
        ERP_plot_scalp_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_scalp_map.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.cancel.ForegroundColor = [1 1 1];
        gui_erp_scalp_map.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.advanced.ForegroundColor = [1 1 1];
        gui_erp_scalp_map.map_type_2d.Value=0;
        gui_erp_scalp_map.map_type_3d.Value=1;
        gui_erp_scalp_map.map_type_3d_spl.Enable = 'on';
        morimenu = {'front', 'back', 'right', 'left', 'top',...
            'frontleft', 'frontright', 'backleft', 'backright',...
            'custom'};
        %%for 2D
        set(gui_erp_scalp_map.map_type_2d_type,'Enable','off');
        set(gui_erp_scalp_map.map_type_2d_type_outside,'Enable','off','Value',0);
        %%for 3D
        set(gui_erp_scalp_map.map_extras_view_ops,'String', morimenu,'Enable','on','Value',1);
        gui_erp_scalp_map.map_extras_view_location.String = num2str([-180 30]);
        gui_erp_scalp_map.map_extras_view_location.Enable = 'off';
    end


    function map_type_2d_type(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_topos',1);
        gui_erp_scalp_map.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_scalp_map.run.ForegroundColor = [1 1 1];
        ERP_plot_scalp_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_scalp_map.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.cancel.ForegroundColor = [1 1 1];
        gui_erp_scalp_map.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.advanced.ForegroundColor = [1 1 1];
    end


%%---------------------Spline setting for 3D-------------------------------
    function map_type_3d_spl(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_topos',1);
        gui_erp_scalp_map.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_scalp_map.run.ForegroundColor = [1 1 1];
        ERP_plot_scalp_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_scalp_map.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.cancel.ForegroundColor = [1 1 1];
        gui_erp_scalp_map.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.advanced.ForegroundColor = [1 1 1];
        
        pathName_def =  estudioworkingmemory('EEG_save_folder');
        if isempty(pathName_def)
            pathName_def =cd;
        end
        ERPArray= estudioworkingmemory('selectederpstudio');
        if isempty(ERPArray)%%Check indexs of the selected ERPsets
            ERPArray = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
            estudioworkingmemory('selectederpstudio',ERPArray);
        else
            [chk, msgboxText] = f_ERP_chckerpindex(observe_ERPDAT.ALLERP, ERPArray);
            if chk==1
                ERPArray = observe_ERPDAT.CURRENTERP;
            end
        end
        
        %%Send message to Message panel
        Selectederp_Index_save = [];
        count_scalp = 0;
        estudioworkingmemory('f_ERP_proces_messg','Plot Scalp Maps > 3D > Spline');
        observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
        ALLERPCOM = evalin('base','ALLERPCOM');
        for Numoferp = 1:length(ERPArray)
            ERP = observe_ERPDAT.ALLERP(ERPArray(Numoferp));
            ERP.filepath = pathName_def;
            try
                splnfile =  ERP.splinefile;
            catch
                splnfile = '';
            end
            if ~isempty(splnfile)
                [pathstr, file_name, ext] = fileparts(splnfile);
                splnfile = fullfile(pathName_def,[file_name,ext]);
            end
            
            %% open splinefilegui
            splineinfo = splinefileGUI({splnfile},ERP);
            if isempty(splineinfo)
                observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
                observe_ERPDAT.Process_messg =2;%%
                return
            end
            splinefile = splineinfo.path;
            if isempty(splinefile)
                msgboxText =  'Plot Scalp Maps: You must specify a name for the spline file';
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return
            end
            Save_file_label =0;
            if splineinfo.save
                if isempty(ERP.splinefile)
                    ERP.splinefile = splinefile;
                else
                    question = ['This ERPset already has spline file info.\n'...
                        'Would you like to replace it?'];
                    title_msg   = 'EStudio: spline file';
                    button   = askquest(sprintf(question), title_msg);
                    
                    if ~strcmpi(button,'yes')
                        return
                    else
                        ERP.splinefile = splinefile;
                    end
                end
                
                Answer = f_ERP_save_single_file(strcat(ERP.erpname,'_scalspline'),ERP.filename,ERPArray(Numoferp));
                if isempty(Answer)
                    observe_ERPDAT.Process_messg =2;%%
                    return;
                end
                
                if ~isempty(Answer)
                    ERPName = Answer{1};
                    if ~isempty(ERPName)
                        ERP.erpname = ERPName;
                    end
                    fileName_full = Answer{2};
                    if isempty(fileName_full)
                        ERP.filename = ERP.erpname;
                        Save_file_label =0;
                    elseif ~isempty(fileName_full)
                        [pathstr, file_name, ext] = fileparts(fileName_full);
                        ext = '.erp';
                        if strcmp(pathstr,'')
                            pathstr = cd;
                        end
                        ERP.filename = [file_name,ext];
                        ERP.filepath = pathstr;
                        Save_file_label =1;
                    end
                    
                end
                observe_ERPDAT.ALLERP(length(observe_ERPDAT.ALLERP)+1) = ERP;
                count_scalp = count_scalp+1;%%Record the new data;
                Selectederp_Index_save(count_scalp) = ERPArray(Numoferp);
                splineinfo.save = 0;
            else
                ERP.splinefile = splinefile;
                observe_ERPDAT.ALLERP(ERPArray(Numoferp)) = ERP;
            end
            
            if Save_file_label==1
                [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', ERP.filename, 'filepath',ERP.filepath);
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                assignin('base','ERPCOM',ERPCOM);
            end
        end%%end for ERPset loop
        
        if ~isempty(Selectederp_Index_save)
            try
                Selected_ERP_afd =  [length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1:length(observe_ERPDAT.ALLERP)];
                observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1;
            catch
                Selected_ERP_afd = length(observe_ERPDAT.ALLERP);
                observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
            end
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
            estudioworkingmemory('selectederpstudio',Selected_ERP_afd);
        end
        
        assignin('base','ALLERPCOM',ALLERPCOM);
        estudioworkingmemory('f_ERP_bin_opt',1);
        observe_ERPDAT.Count_currentERP = 1;
        observe_ERPDAT.Process_messg =2;
    end

%%------------------------------Color bar scale: Max-min----------------------------
    function bar_scale_max_min(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('ERPTab_topos',1);
        gui_erp_scalp_map.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_scalp_map.run.ForegroundColor = [1 1 1];
        ERP_plot_scalp_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_scalp_map.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.cancel.ForegroundColor = [1 1 1];
        gui_erp_scalp_map.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.advanced.ForegroundColor = [1 1 1];
        
        gui_erp_scalp_map.max_min.Value = 1;
        gui_erp_scalp_map.custom_option.Value = 0;
        gui_erp_scalp_map.abs_max.Value = 0;
        gui_erp_scalp_map.bar_scale_custom_option_edit.Enable = 'off';
    end


%%------------------------------Color bar scale: abs max----------------------------
    function bar_scale_abs_max(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_topos',1);
        gui_erp_scalp_map.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_scalp_map.run.ForegroundColor = [1 1 1];
        ERP_plot_scalp_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_scalp_map.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.cancel.ForegroundColor = [1 1 1];
        gui_erp_scalp_map.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.advanced.ForegroundColor = [1 1 1];
        gui_erp_scalp_map.max_min.Value = 0;
        gui_erp_scalp_map.custom_option.Value = 0;
        gui_erp_scalp_map.abs_max.Value = 1;
        gui_erp_scalp_map.bar_scale_custom_option_edit.Enable = 'off';
    end


%%------------------------------Color bar scale: custom----------------------------
    function bar_scale_custom_opt(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('ERPTab_topos',1);
        gui_erp_scalp_map.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_scalp_map.run.ForegroundColor = [1 1 1];
        ERP_plot_scalp_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_scalp_map.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.cancel.ForegroundColor = [1 1 1];
        gui_erp_scalp_map.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.advanced.ForegroundColor = [1 1 1];
        gui_erp_scalp_map.max_min.Value = 0;
        gui_erp_scalp_map.custom_option.Value = 1;
        gui_erp_scalp_map.abs_max.Value = 0;
        gui_erp_scalp_map.bar_scale_custom_option_edit.Enable = 'on';
    end
%%-------------------Bar scale custom edit---------------------------------
    function bar_scale_custom_edit(Source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_topos',1);
        gui_erp_scalp_map.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_scalp_map.run.ForegroundColor = [1 1 1];
        ERP_plot_scalp_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_scalp_map.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.cancel.ForegroundColor = [1 1 1];
        gui_erp_scalp_map.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.advanced.ForegroundColor = [1 1 1];
        barscale = str2num(Source.String);
        if isempty(barscale) || numel(barscale)~=2
            msgboxText =  ['Plot Scalp Maps > Color bar scale: it should be two values'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Source.String = '';
            return;
        end
    end

%%---------------location selection----------------------------------------
    function map_extras_view_ops(Source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_topos',1);
        gui_erp_scalp_map.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_scalp_map.run.ForegroundColor = [1 1 1];
        ERP_plot_scalp_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_scalp_map.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.cancel.ForegroundColor = [1 1 1];
        gui_erp_scalp_map.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.advanced.ForegroundColor = [1 1 1];
        
        if gui_erp_scalp_map.map_type_3d.Value%%%If 3D
            pos = Source.Value;
            lview = Source.String;
            strv  = lview{pos};
            if strcmpi(strv, 'custom')
                set(gui_erp_scalp_map.map_extras_view_location, 'Enable', 'on')
            else
                switch strv
                    case {'front','f'}
                        mview = [-180,30];
                    case {'back','b'}
                        mview = [0,30];
                    case {'left','l'}
                        mview =  [-90,30];
                    case {'right','r'}
                        mview =  [90,30];
                    case {'frontright','fr'}
                        mview =  [135,30];
                    case {'backright','br'}
                        mview =  [45,30];
                    case {'frontleft','fl'}
                        mview =  [-135,30];
                    case {'backleft','bl'}
                        mview =  [-45,30];
                    case 'top'
                        mview =  [0,90];
                    otherwise
                        mview =  [];
                end
                set(gui_erp_scalp_map.map_extras_view_location, 'String', vect2colon(mview, 'Delimiter', 'off'))
                set(gui_erp_scalp_map.map_extras_view_location, 'Enable', 'off')
            end
        end
    end

%%---------------------------view------------------------------------------
    function map_extras_view_location(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_topos',1);
        gui_erp_scalp_map.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_scalp_map.run.ForegroundColor = [1 1 1];
        ERP_plot_scalp_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_scalp_map.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.cancel.ForegroundColor = [1 1 1];
        gui_erp_scalp_map.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.advanced.ForegroundColor = [1 1 1];
    end


%%------------------------color map----------------------------------------
    function colormap(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_topos',1);
        gui_erp_scalp_map.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_scalp_map.run.ForegroundColor = [1 1 1];
        ERP_plot_scalp_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_scalp_map.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.cancel.ForegroundColor = [1 1 1];
        gui_erp_scalp_map.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.advanced.ForegroundColor = [1 1 1];
    end


%%------------------------display color bar?-------------------------------
    function dispbar(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_topos',1);
        gui_erp_scalp_map.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_scalp_map.run.ForegroundColor = [1 1 1];
        ERP_plot_scalp_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_scalp_map.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.cancel.ForegroundColor = [1 1 1];
        gui_erp_scalp_map.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.advanced.ForegroundColor = [1 1 1];
    end


%%---------------------Setting for advanced---------------------------------
    function apply_advanced(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_topos',1);
        gui_erp_scalp_map.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_scalp_map.run.ForegroundColor = [1 1 1];
        ERP_plot_scalp_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_scalp_map.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.cancel.ForegroundColor = [1 1 1];
        gui_erp_scalp_map.advanced.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_scalp_map.advanced.ForegroundColor = [1 1 1];
        is2Dmap  = gui_erp_scalp_map.map_type_2d.Value;
        
        
        latencyArray = str2num(gui_erp_scalp_map.latency_plot_edit.String);
        if isempty(latencyArray)
            msgboxText =  ['Plot Scalp Maps - No latency was defined'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        ERP_times = observe_ERPDAT.ERP.times;
        meamenu = gui_erp_scalp_map.measurement.Value;
        switch meamenu
            case 1
                measurement = 'insta';
            case 2
                measurement = 'mean';
            case 3
                measurement = 'instalapla';
            case 4
                measurement = 'meanlapla';
            case 5
                measurement = 'rms';
            otherwise
                measurement = 'insta';
        end
        
        latencyArray   = str2num(gui_erp_scalp_map.latency_plot_edit.String);
        if isempty(latencyArray)
            msgboxText =  ['Plot Scalp Maps - No latency was defined',];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        indxh   = find(latencyArray>ERP_times(end),1);
        if ~isempty(indxh)
            msgboxText =  ['Plot Scalp Maps - Latency of ' num2str(latencyArray(indxh)) ' is greater than ERP.xmax = ' num2str(ERP_times(end)) ' msec!'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            gui_erp_scalp_map.latency_plot_edit.String = '';
            return
        end
        
        indxl  = find(latencyArray<ERP_times(1),1);
        if ~isempty(indxl)
            msgboxText =  ['Plot Scalp Maps - Latency of ' num2str(latencyArray(indxl)) ' is lesser than ERP.xmin = ' num2str(ERP_times(1)) ' msec!'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return
        end
        
        switch meamenu
            case {2, 4, 5} % mean, meanlapla, rms
                if size(latencyArray,2)<2
                    msgboxText =  ['Plot Scalp Maps - You must specify 2 latencies, at least, for getting values.'...
                        'For specifying two or more mean value maps, please use semicolon (;) to separate each latency range.'...
                        'For instance, to plot mean value maps for 0 to 100 ms AND 400 to 500 ms just write 0 100;400 500'];
                    titlNamerro = 'Warning for ERP Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    return
                end
            case {1,3} % insta, instalapla
                if size(latencyArray,1)>1
                    msgboxText =  'Plot Scalp Maps - For you must specify as many latencies as maps you would like to plot.You cannot use semicolon-separated values.';
                    titlNamerro = 'Warning for ERP Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    return
                end
        end
        
        try
            pscalp_plegend =  estudioworkingmemory('pscalp_plegend');
            pscale_legend{1} = pscalp_plegend.binnum ;
            pscale_legend{2} = pscalp_plegend.bindesc;
            pscale_legend{3} = pscalp_plegend.type;
            pscale_legend{4}= pscalp_plegend.latency ;
            pscale_legend{5} = pscalp_plegend.electrodes ;
            pscale_legend{6}= pscalp_plegend.elestyle;
            pscale_legend{7}= pscalp_plegend.elec3D;
            pscale_legend{8}= pscalp_plegend.maximize;
            pscale_legend{9}= is2Dmap;
        catch
            pscale_legend = {1,1,1,1,0,'on','off',0,is2Dmap};
        end
        if isempty(pscale_legend)
            pscale_legend = {1,1,1,1,0,'on','off',0,is2Dmap};
        end
        
        try
            pscalp_agif =  estudioworkingmemory('pscalp_agif');
            pagif_legend{1}= pscalp_agif.value ;
            pagif_legend{2}= pscalp_agif.fps ;
            pagif_legend{3}=pscalp_agif.fname;
            pagif_legend{4}=latencyArray;
        catch
            pagif_legend = {0,[],'',latencyArray};
        end
        if isempty(pagif_legend)
            pagif_legend = {0,[],'',latencyArray};
        end
        
        
        Answer = f_scalplotadvanceGUI(pscale_legend,pagif_legend);
        if isempty(Answer)
            return;
        end
        %%{binnum, bindesc, type, latency, electrodes, elestyle, elec3D, ismaxim, 2Dvalue}
        %%parameters for agif
        pscale_legend = Answer{1};
        pscalp_plegend.binnum = pscale_legend{1};
        pscalp_plegend.bindesc = pscale_legend{2};
        pscalp_plegend.type = pscale_legend{3};
        pscalp_plegend.latency = pscale_legend{4};
        pscalp_plegend.electrodes = pscale_legend{5};
        pscalp_plegend.elestyle = pscale_legend{6};
        pscalp_plegend.elec3D = pscale_legend{7};
        pscalp_plegend.colorbar = gui_erp_scalp_map.map_extras_cmapb_disp.Value;
        pscalp_plegend.colormap = gui_erp_scalp_map.map_extras_cmap_ops.Value;
        pscalp_plegend.maximize = pscale_legend{8};
        %%parameters for agif
        pagif = Answer{2};
        pscalp_agif.value = pagif{1};
        pscalp_agif.fps = pagif{2};
        pscalp_agif.fname = pagif{4};
        %%Save parameters
        estudioworkingmemory('pscalp_plegend', pscalp_plegend);
        estudioworkingmemory('pscalp_agif', pscalp_agif);
    end

%%---------------------Run-------------------------------------------------
    function apply_run(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_topos',0);
        gui_erp_scalp_map.run.BackgroundColor =  [ 1 1 1];
        gui_erp_scalp_map.run.ForegroundColor = [0 0 0];
        ERP_plot_scalp_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_scalp_map.cancel.BackgroundColor =  [1 1 1];
        gui_erp_scalp_map.cancel.ForegroundColor = [0 0 0];
        gui_erp_scalp_map.advanced.BackgroundColor =  [1 1 1];
        gui_erp_scalp_map.advanced.ForegroundColor = [0 0 0];
        
        %%Send message to Message panel
        estudioworkingmemory('f_ERP_proces_messg','Plot Scalp Maps');
        observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
        
        ERPArray= estudioworkingmemory('selectederpstudio');
        if isempty(ERPArray)
            ERPArray = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP=length(observe_ERPDAT.ALLERP);
            estudioworkingmemory('selectederpstudio',ERPArray);
        end
        
        plegend = estudioworkingmemory('pscalp_plegend');
        if isempty(plegend)
            plegend.binnum = 1;
            plegend.bindesc = 1;
            plegend.type = 1;
            plegend.latency = 1;
            plegend.electrodes = 0;
            plegend.elestyle = 'on';
            plegend.elec3D = 'off';
            plegend.colorbar = gui_erp_scalp_map.map_extras_cmapb_disp.Value;
            plegend.colormap = gui_erp_scalp_map.map_extras_cmap_ops.Value;
            plegend.maximize = 0;
            estudioworkingmemory('pscalp_plegend',plegend);
        end
        agif  = estudioworkingmemory('pscalp_agif');
        if isempty(agif)
            agif.value =0;
            agif.fps =[];
            agif.fname ='';
            estudioworkingmemory('pscalp_agif',agif);
        end
        
        binArray     = str2num(gui_erp_scalp_map.bin_plot_edit.String);
        [chk, msgboxText] = f_ERP_chckbinandchan(observe_ERPDAT.ERP, binArray, [],1);
        if chk(1)
            msgboxText =  ['Plot Scalp Maps -',msgboxText];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            observe_ERPDAT.Process_messg =2;
            return;
        end
        
        ERP_times = observe_ERPDAT.ERP.times;
        meamenu = gui_erp_scalp_map.measurement.Value;
        switch meamenu
            case 1
                measurement = 'insta';
            case 2
                measurement = 'mean';
            case 3
                measurement = 'instalapla';
            case 4
                measurement = 'meanlapla';
            case 5
                measurement = 'rms';
            otherwise
                measurement = 'insta';
        end
        
        latencyArray   = str2num(gui_erp_scalp_map.latency_plot_edit.String);
        if isempty(latencyArray)
            msgboxText =  ['Plot Scalp Maps - No latency was defined',];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            observe_ERPDAT.Process_messg =2;
            return;
        end
        
        indxh   = find(latencyArray>ERP_times(end),1);
        if ~isempty(indxh)
            msgboxText =  ['Plot Scalp Maps - Latency of ' num2str(latencyArray(indxh)) ' is greater than ERP.xmax = ' num2str(ERP_times(end)) ' msec!'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            gui_erp_scalp_map.latency_plot_edit.String = '';
            observe_ERPDAT.Process_messg =2;
            return
        end
        
        indxl  = find(latencyArray<ERP_times(1),1);
        if ~isempty(indxl)
            msgboxText =  ['Plot Scalp Maps - Latency of ' num2str(latencyArray(indxl)) ' is lesser than ERP.xmin = ' num2str(ERP_times(1)) ' msec!'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            observe_ERPDAT.Process_messg =2;
            return
        end
        
        switch meamenu
            case {2, 4, 5} % mean, meanlapla, rms
                if size(latencyArray,2)<2
                    msgboxText =  ['Plot Scalp Maps - You must specify 2 latencies, at least, for getting values.'...
                        'For specifying two or more mean value maps, please use semicolon (;) to separate each latency range.'...
                        'For instance, to plot mean value maps for 0 to 100 ms AND 400 to 500 ms just write 0 100;400 500'];
                    titlNamerro = 'Warning for ERP Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    observe_ERPDAT.Process_messg =2;
                    return
                end
            case {1,3} % insta, instalapla
                if size(latencyArray,1)>1
                    msgboxText =  'Plot Scalp Maps - For you must specify as many latencies as maps you would like to plot.You cannot use semicolon-separated values.';
                    titlNamerro = 'Warning for ERP Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    observe_ERPDAT.Process_messg =2;
                    return
                end
        end
        
        baseline     = 'none';
        if gui_erp_scalp_map.max_min.Value
            maplimit     = 'maxmin';
        elseif gui_erp_scalp_map.abs_max.Value
            maplimit     = 'absmax';
        elseif gui_erp_scalp_map.custom_option.Value
            cusca  = str2num(gui_erp_scalp_map.bar_scale_custom_option_edit.String);
            if isempty(cusca)
                msgboxText =  ['Plot Scalp Maps - No value was defined for "Color Bar Scale"'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                observe_ERPDAT.Process_messg =2;
                return;
            else
                ncusca = length(cusca);
                if ncusca == 2
                    if cusca(1)<cusca(2)
                        maplimit = cusca;
                    else%%
                        msgboxText =  ['Plot Scalp Maps - the first value should be smaller than the second one for "Color Bar Scale"'];
                        titlNamerro = 'Warning for ERP Tab';
                        estudio_warning(msgboxText,titlNamerro);
                        observe_ERPDAT.Process_messg =2;
                        return;
                    end
                else%%one value
                    msgboxText =  ['Plot Scalp Maps - "Color Bar Scale" needs 2 values'];
                    titlNamerro = 'Warning for ERP Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    observe_ERPDAT.Process_messg =2;
                    return;
                end
            end
        else
            maplimit     = 'maxmin';
        end
        
        ismoviex     = agif.value;
        FPS          = agif.fps;
        fullgifname  = agif.fname;
        posfig       = [];%%xx
        if gui_erp_scalp_map.map_type_2d.Value
            mtype        = '2D';   % map type: 2D
        elseif gui_erp_scalp_map.map_type_3d.Value
            mtype        = '3D';   % map type: 3D
        end
        smapstylestr = {'map','contour','both','fill','blank'};
        smapstyle    = smapstylestr{gui_erp_scalp_map.map_type_2d_type.Value};   % map style: 'fill' 'both'
        
        mapoutside   = gui_erp_scalp_map.map_type_2d_type_outside.Value;
        viewselec = gui_erp_scalp_map.map_extras_view_ops.Value;
        if gui_erp_scalp_map.map_type_2d.Value  % 2D
            switch viewselec
                case 1
                    mapview = '+X';
                case 2
                    mapview = '-X';
                case 3
                    mapview = '+Y';
                case 4
                    mapview = '-Y';
                otherwise
                    mapview = '+X';
            end
        elseif gui_erp_scalp_map.map_type_3d.Value % 3D
            morimenu = {'front', 'back', 'right', 'left', 'top',...
                'frontleft', 'frontright', 'backleft', 'backright',...
                'custom'};
            try
                if viewselec<10
                    mapview  = morimenu{viewselec};
                elseif viewselec==10
                    mapview = str2num(gui_erp_scalp_map.map_extras_view_location.String);
                end
            catch
                return;
            end
        end
        splineinfo.path   = '';
        %%plegend
        binleg       = plegend.binnum;         % show bin number at legend
        bindesc      = plegend.bindesc;        % show bin description at legend
        vtype        = plegend.type ;          % show type of measurement at legend
        vlatency     = plegend.latency;        % show latency(ies) at legend
        showelec     = plegend.electrodes;     % show electrodes on scalp
        elestyle     = plegend.elestyle  ;     %
        elec3D       = plegend.elec3D;
        clrbar       = gui_erp_scalp_map.map_extras_cmapb_disp.Value;       % show color bar
        ismaxim      = plegend.maximize;       % show color bar
        clrmap       = gui_erp_scalp_map.map_extras_cmap_ops.Value;       % show color bar
        
        if clrbar==1
            colorbari = 'on';
        else
            colorbari = 'off';
        end
        if mapoutside==1   % 'plotrad',mplotrad,
            mplotrad = [];
        else
            mplotrad = 0.55;
        end
        
        %'jet|hsv|hot|cool|gray'
        cMap_par={'jet','hsv','hot','cool','gray','viridis'};
        try
            cmap = cMap_par{clrmap};
        catch
            cmap = 'jet';
        end
        if ismoviex==0
            ismoviexx = 'off';
            aff     = 'off'; % adjust first frame (aff)
        else
            if ismoviex==1
                aff = 'off'; % adjust first frame (aff)
            else
                aff = 'on';
            end
            ismoviexx = 'on';
        end
        if binleg==1
            binlegx = 'on';
        else
            binlegx = 'off';
        end
        if showelec==1
            showelecx = elestyle;
        else
            showelecx = 'off';
        end
        if ismaxim==1
            maxim = 'on';
        else
            maxim = 'off';
        end
        
        % legend
        logstring = ['bn'*binleg '-'*binleg 'bd'*bindesc '-'*bindesc 'me'*vtype '-'*vtype 'la'*vlatency];
        logstring = nonzeros(logstring)';
        mapleg    = strtrim(char(logstring));
        
        ERPArray =  estudioworkingmemory('selectederpstudio');
        if isempty(ERPArray)
            ERPArray =  length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = ERPArray;
            estudioworkingmemory('selectederpstudio',ERPArray);
        end
        
        ERPTab_plotscalp{1}=str2num(gui_erp_scalp_map.bin_plot_edit.String);
        ERPTab_plotscalp{2}=str2num(gui_erp_scalp_map.latency_plot_edit.String);
        ERPTab_plotscalp{3}=gui_erp_scalp_map.map_type_2d.Value;
        ERPTab_plotscalp{4} = gui_erp_scalp_map.map_type_2d_type.Value;
        ERPTab_plotscalp{5}=gui_erp_scalp_map.map_type_2d_type_outside.Value;
        if gui_erp_scalp_map.max_min.Value==1
            ERPTab_plotscalp{6}=1;
        elseif gui_erp_scalp_map.abs_max.Value==1
            ERPTab_plotscalp{6}=0;
        elseif gui_erp_scalp_map.custom_option.Value==1
            ERPTab_plotscalp{6}=  str2num(gui_erp_scalp_map.bar_scale_custom_option_edit.String);
        end
        ERPTab_plotscalp{7} = gui_erp_scalp_map.map_extras_view_ops.Value;
        ERPTab_plotscalp{8} =gui_erp_scalp_map.map_extras_cmap_ops.Value ;
        ERPTab_plotscalp{9}=gui_erp_scalp_map.map_extras_cmapb_disp.Value;
        ERPTab_plotscalp{10}=gui_erp_scalp_map.measurement.Value;
        estudioworkingmemory('ERPTab_plotscalp',ERPTab_plotscalp);
        
        
        try ALLERPCOM = evalin('base','ALLERPCOM'); catch   ALLERPCOM = [];end
        for Numoferp = 1:numel(ERPArray)
            ERP = observe_ERPDAT.ALLERP(ERPArray(Numoferp));
            if strcmpi(mtype, '3d')
                if isempty(ERP.splinefile) && isempty(splineinfo.path)
                    msgboxText =  ['Plot Scalp Maps - You must first set the spline file (by clicking the spline button) before creating a 3D plot for',32,ERP.erpname];
                    titlNamerro = 'Warning for ERP Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    observe_ERPDAT.Process_messg =2;
                    return;
                elseif isempty(ERP.splinefile) && ~isempty(splineinfo.path)
                    %if splineinfo.new==1
                    headplot('setup', ERP.chanlocs, splineinfo.path); %Builds the new spline file.
                elseif ~isempty(ERP.splinefile) && ~isempty(splineinfo.path)
                    headplot('setup', ERP.chanlocs, splineinfo.path); %Builds the new spline file.
                    splinefile = splineinfo.path;
                else
                    splinefile = ERP.splinefile;
                    headplot('setup', ERP.chanlocs, splinefile);
                end
            else
                splinefile = ERP.splinefile;
                if strcmpi(mtype, '3d')
                    headplot('setup', ERP.chanlocs, splinefile);
                end
            end
            if isempty(binArray)
                binArray = [1:ERP.nbin];
            end
            [ERP, ERPCOM] = pop_scalplot(ERP, binArray, latencyArray, 'Value', measurement, 'Blc', baseline, 'Maplimit', maplimit, 'Colorbar', colorbari,...
                'Colormap', cmap,'Animated', ismoviexx, 'AdjustFirstFrame', aff, 'FPS', FPS, 'Filename', fullgifname, 'Legend', mapleg, 'Electrodes', showelecx,...
                'Position', posfig, 'Maptype', mtype, 'Mapstyle', smapstyle, 'Plotrad', mplotrad,'Mapview', mapview, 'Splinefile', splinefile,...
                'Maximize', maxim, 'Electrodes3d', elec3D,'History', 'gui');
            if Numoferp ==numel(ERPArray)
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
            else
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
            end
            observe_ERPDAT.ALLERP(ERPArray(Numoferp)) = ERP;
        end
        
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
        observe_ERPDAT.Count_currentERP=1;
        observe_ERPDAT.Process_messg =2; %%Marking for the procedure has been started.
    end


%%------------------------cancel-------------------------------------------
    function scap_cancel(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=3
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_topos',0);
        gui_erp_scalp_map.run.BackgroundColor =  [ 1 1 1];
        gui_erp_scalp_map.run.ForegroundColor = [0 0 0];
        ERP_plot_scalp_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_scalp_map.cancel.BackgroundColor =  [1 1 1];
        gui_erp_scalp_map.cancel.ForegroundColor = [0 0 0];
        gui_erp_scalp_map.advanced.BackgroundColor =  [1 1 1];
        gui_erp_scalp_map.advanced.ForegroundColor = [0 0 0];
        
        ERPTab_plotscalp=estudioworkingmemory('ERPTab_plotscalp');
        try binArray = ERPTab_plotscalp{1}; catch binArray = [];ERPTab_plotscalp{1} = [];end
        nbinum = observe_ERPDAT.ERP.nbin;
        if isempty(binArray) || any(binArray<0) || any(binArray>nbinum)
            binArray = 1:nbinum;
            ERPTab_plotscalp{1} = binArray;
        end
        gui_erp_scalp_map.bin_plot_edit.String = num2str(binArray);
        
        try Latency = ERPTab_plotscalp{2}; catch Latency = [];ERPTab_plotscalp{2} = [];end
        if isempty(Latency)|| any(Latency(:)<observe_ERPDAT.ERP.times(1)) || any(Latency(:)>observe_ERPDAT.ERP.times(end))
            Latency = [];
            ERPTab_plotscalp{2} = Latency;
        end
        Latencystr = '';
        for ii = 1:size(Latency,1)
            if ii==1
                Latencystr = [num2str(Latency(ii,:))];
            else
                Latencystr = [Latencystr,';',num2str(Latency(ii,:))];
            end
        end
        
        gui_erp_scalp_map.latency_plot_edit.String = Latencystr;
        
        try map2d = ERPTab_plotscalp{3}; catch map2d=1;ERPTab_plotscalp{3} = 1;end
        if isempty(map2d) || numel(map2d)~=1 || (map2d~=1 && map2d~=0)
            map2d = 1;ERPTab_plotscalp{3}=1;
        end
        gui_erp_scalp_map.map_type_2d.Value= map2d;
        if map2d==1
            set(gui_erp_scalp_map.map_type_2d_type,'Enable','on');
            gui_erp_scalp_map.map_type_3d_spl.Enable = 'off';
            gui_erp_scalp_map.map_extras_view_ops.Enable = 'off';
            gui_erp_scalp_map.map_extras_view_ops.String = '+X';
            gui_erp_scalp_map.map_extras_view_ops.Value =1;
            gui_erp_scalp_map.map_extras_view_location.String = num2str([-180 30]);
            gui_erp_scalp_map.map_extras_view_location.Enable = 'off';
            gui_erp_scalp_map.map_type_2d_type_outside.Enable = 'on';
        else
            gui_erp_scalp_map.map_type_2d_type.Enable = 'off';
            gui_erp_scalp_map.map_type_2d_type_outside.Enable = 'off';
            morimenu = {'front', 'back', 'right', 'left', 'top',...
                'frontleft', 'frontright', 'backleft', 'backright',...
                'custom'};
            %%for 2D
            set(gui_erp_scalp_map.map_type_2d_type,'Enable','off');
            set(gui_erp_scalp_map.map_type_2d_type_outside,'Enable','off','Value',0);
            %%for 3D
            set(gui_erp_scalp_map.map_extras_view_ops,'String', morimenu,'Enable','on','Value',1);
            gui_erp_scalp_map.map_extras_view_location.String = num2str([-180 30]);
            gui_erp_scalp_map.map_extras_view_location.Enable = 'off';
        end
        
        gui_erp_scalp_map.map_type_3d.Value= ~map2d;
        
        
        try twodtyep  = ERPTab_plotscalp{4}; catch twodtyep=1;ERPTab_plotscalp{4} = 1;end
        if isempty(twodtyep) || numel(twodtyep)~=1 || any(twodtyep>5) || any(twodtyep<1)
            twodtyep=1;ERPTab_plotscalp{4} = 1;
        end
        gui_erp_scalp_map.map_type_2d_type.Value=twodtyep;
        
        try mapoutside = ERPTab_plotscalp{5}; catch mapoutside=0;ERPTab_plotscalp{5} = 0;end
        if isempty(mapoutside) || numel(mapoutside)~=1 || (mapoutside~=0 && mapoutside~=1)
            mapoutside=0;
            ERPTab_plotscalp{5}=0;
        end
        gui_erp_scalp_map.map_type_2d_type_outside.Value = mapoutside;
        
        try barscale = ERPTab_plotscalp{6}; catch barscale=1;ERPTab_plotscalp{65} = 1;end
        if isempty(barscale) || (numel(barscale)~=1 && numel(barscale)~=2)
            barscale=1;
            ERPTab_plotscalp{6}=1;
        end
        if numel(barscale)==1
            if barscale~=1 && barscale~=2
                barscale=1;
                ERPTab_plotscalp{6}=1;
            end
            if barscale==1
                gui_erp_scalp_map.max_min.Value=1;
                gui_erp_scalp_map.abs_max.Value=0;
                gui_erp_scalp_map.custom_option.Value=0;
            else
                gui_erp_scalp_map.max_min.Value=0;
                gui_erp_scalp_map.abs_max.Value=1;
                gui_erp_scalp_map.custom_option.Value=0;
            end
        elseif numel(barscale)==2
            gui_erp_scalp_map.max_min.Value=0;
            gui_erp_scalp_map.abs_max.Value=0;
            gui_erp_scalp_map.custom_option.Value=1;
            gui_erp_scalp_map.bar_scale_custom_option_edit.String = num2str(barscale);
        else
            gui_erp_scalp_map.max_min.Value=1;
            gui_erp_scalp_map.abs_max.Value=0;
            gui_erp_scalp_map.custom_option.Value=0;
        end
        
        if map2d==1
            gui_erp_scalp_map.map_extras_view_ops.Value=1;
            ERPTab_plotscalp{7}=1;
        else
            try mapextrc = ERPTab_plotscalp{7}; catch mapextrc=1;ERPTab_plotscalp{7} = 1;end
            if isempty(mapextrc) || numel(mapextrc)~=1 || any(mapextrc<1) || any(mapextrc>10)
                mapextrc=1;
                ERPTab_plotscalp{7}=1;
            end
            gui_erp_scalp_map.map_extras_view_ops.Value=mapextrc;
        end
        
        try clormap = ERPTab_plotscalp{8}; catch clormap=1;ERPTab_plotscalp{8} = 1;end
        if isempty(clormap) || numel(clormap)~=1 || any(clormap<1) || any(clormap>6)
            clormap=1;
        end
        gui_erp_scalp_map.map_extras_cmap_ops.Value = clormap;
        try dispbar = ERPTab_plotscalp{9}; catch dispbar=0;ERPTab_plotscalp{9} = 0;end
        if isempty(dispbar) || numel(dispbar)~=1 || (dispbar~=0 && dispbar~=1)
            dispbar=0;ERPTab_plotscalp{9} = 0;
        end
        gui_erp_scalp_map.map_extras_cmapb_disp.Value = dispbar;
        
        %%measurement methods
        try MeasValue = ERPTab_plotscalp{10};catch MeasValue=2; end
        if isempty(MeasValue) || numel(MeasValue)~=1 || any(MeasValue<1) || any(MeasValue>5)
            MeasValue=2;
        end
        gui_erp_scalp_map.measurement.Value=MeasValue;
        ERPTab_plotscalp{10} = MeasValue;
        Value = gui_erp_scalp_map.measurement.Value;
        switch Value
            case {1,3}
                gui_erp_scalp_map.measurement_exp.String='(one or more: e.g. 300 or 100:50:350)';
            case {2,4,5}
                gui_erp_scalp_map.measurement_exp.String='(min max pairs: e.g., 300 400 ; 400 500)';
        end
        estudioworkingmemory('ERPTab_plotscalp',ERPTab_plotscalp);
    end


%%--------Setting current ERPset/session history based on the current updated ERPset------------
    function Count_currentERPChanged(~,~)
        if observe_ERPDAT.Count_currentERP~=4
            return;
        end
        ViewerFlag=estudioworkingmemory('ViewerFlag');%%when open advanced wave viewer
        if isempty(ViewerFlag) || (ViewerFlag~=0 && ViewerFlag~=1)
            ViewerFlag=0;estudioworkingmemory('ViewerFlag',0);
        end
        if isempty(observe_ERPDAT.ALLERP)|| isempty(observe_ERPDAT.ERP) || ViewerFlag==1
            Enable_lab = 'off';
        else
            Enable_lab = 'on';
        end
        gui_erp_scalp_map.measurement.Enable = Enable_lab;
        %%bin & latency
        gui_erp_scalp_map.bin_plot_edit.Enable = Enable_lab;
        gui_erp_scalp_map.bin_plot_opt.Enable = Enable_lab;
        gui_erp_scalp_map.latency_plot_edit.Enable = Enable_lab;
        %%Map type
        gui_erp_scalp_map.map_type_2d.Enable = Enable_lab;
        gui_erp_scalp_map.map_type_3d.Enable = Enable_lab;
        gui_erp_scalp_map.map_type_2d_type.Enable = Enable_lab;
        gui_erp_scalp_map.map_type_3d_spl.Enable = Enable_lab;
        gui_erp_scalp_map.map_type_2d_type_outside.Enable = Enable_lab;
        %%Color bar scale
        gui_erp_scalp_map.max_min.Enable = Enable_lab;
        gui_erp_scalp_map.custom_option.Enable = Enable_lab;
        gui_erp_scalp_map.abs_max.Enable = Enable_lab;
        %%Map extras
        gui_erp_scalp_map.map_extras_view_ops.Enable= Enable_lab;
        gui_erp_scalp_map.map_extras_view_location.Enable= Enable_lab;
        gui_erp_scalp_map.map_extras_cmap_ops.Enable = Enable_lab;
        gui_erp_scalp_map.map_extras_cmapb_disp.Enable= Enable_lab;
        gui_erp_scalp_map.map_type_2d_type.Enable= Enable_lab;
        set(gui_erp_scalp_map.map_type_2d_type_outside,'Enable',Enable_lab);
        
        %%Run and advanced
        gui_erp_scalp_map.advanced.Enable= Enable_lab;
        gui_erp_scalp_map.run.Enable= Enable_lab;
        gui_erp_scalp_map.cancel.Enable= Enable_lab;
        if isempty(observe_ERPDAT.ALLERP)|| isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP =5;
            return;
        end
        ERPArray= estudioworkingmemory('selectederpstudio');
        if isempty(ERPArray) || any(ERPArray>length(observe_ERPDAT.ALLERP))
            ERPArray = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
            estudioworkingmemory('selectederpstudio',ERPArray);
            observe_ERPDAT.Count_currentERP =1;
        end
        
        BinArray = estudioworkingmemory('ERP_BinArray');
        if isempty(BinArray) || any(BinArray>observe_ERPDAT.ERP.nbin) || any(BinArray<=0)
            BinArray = [1:observe_ERPDAT.ERP.nbin];
            estudioworkingmemory('ERP_BinArray',BinArray);
            observe_ERPDAT.Count_currentERP =2;
        end
        binset = vect2colon(BinArray,'Sort', 'on');
        binset = erase(binset,{'[',']'});
        gui_erp_scalp_map.bin_plot_edit.String =binset;
        
        %%check latency
        latency= str2num(gui_erp_scalp_map.latency_plot_edit.String);
        if numel(latency)~=2 || any(latency(:)>observe_ERPDAT.ERP.times(end)) ||  any(latency(:)<observe_ERPDAT.ERP.times(1))
            gui_erp_scalp_map.latency_plot_edit.String = '';
        end
        
        if gui_erp_scalp_map.custom_option.Value
            gui_erp_scalp_map.bar_scale_custom_option_edit.Enable = 'on';
        else
            gui_erp_scalp_map.bar_scale_custom_option_edit.Enable = 'off';
        end
        
        if gui_erp_scalp_map.map_type_3d.Value==1%%%If select 3D
            gui_erp_scalp_map.map_type_3d_spl.Enable = 'on';
            morimenu = {'front', 'back', 'right', 'left', 'top',...
                'frontleft', 'frontright', 'backleft', 'backright',...
                'custom'};
            %%for 2D
            set(gui_erp_scalp_map.map_type_2d_type,'Enable','off');
            set(gui_erp_scalp_map.map_type_2d_type_outside,'Enable','off','Value',0);
            %%for 3D
            set(gui_erp_scalp_map.map_extras_view_ops,'String', morimenu,'Enable','on','Value',1);
            gui_erp_scalp_map.map_extras_view_location.String = num2str([-180 30]);
            gui_erp_scalp_map.map_extras_view_location.Enable = 'off';
        else
            set(gui_erp_scalp_map.map_type_2d_type,'Enable','on');
            gui_erp_scalp_map.map_type_3d_spl.Enable = 'off';
            gui_erp_scalp_map.map_extras_view_ops.Enable = 'off';
            gui_erp_scalp_map.map_extras_view_ops.String = '+X';
            gui_erp_scalp_map.map_extras_view_ops.Value =1;
            gui_erp_scalp_map.map_extras_view_location.String = num2str([-180 30]);
            gui_erp_scalp_map.map_extras_view_location.Enable = 'off';
            gui_erp_scalp_map.map_type_2d_type_outside.Enable = 'on';
        end
        if  gui_erp_scalp_map.map_type_2d.Value==1%%%If select 2D
            gui_erp_scalp_map.map_type_3d.Value=0;
            set(gui_erp_scalp_map.map_type_2d_type,'Enable','on','Value',1);
            gui_erp_scalp_map.map_type_3d_spl.Enable = 'off';
            gui_erp_scalp_map.map_extras_view_ops.Enable = 'off';
            gui_erp_scalp_map.map_extras_view_ops.String = '+X';
            gui_erp_scalp_map.map_extras_view_ops.Value = 1;
            gui_erp_scalp_map.map_extras_view_location.String = num2str([-180 30]);
            gui_erp_scalp_map.map_extras_view_location.Enable = 'off';
            gui_erp_scalp_map.map_type_2d_type_outside.Enable = 'on';
        end
        observe_ERPDAT.Count_currentERP =5;
    end


%%--------------press return to execute "Apply"----------------------------
    function erp_scalps_presskey(~,eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('ERPTab_topos');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            apply_run();
            estudioworkingmemory('ERPTab_topos',0);
            gui_erp_scalp_map.run.BackgroundColor =  [ 1 1 1];
            gui_erp_scalp_map.run.ForegroundColor = [0 0 0];
            ERP_plot_scalp_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
            gui_erp_scalp_map.cancel.BackgroundColor =  [1 1 1];
            gui_erp_scalp_map.cancel.ForegroundColor = [0 0 0];
            gui_erp_scalp_map.advanced.BackgroundColor =  [1 1 1];
            gui_erp_scalp_map.advanced.ForegroundColor = [0 0 0];
        else
            return;
        end
    end


    function Reset_erp_panel_change(~,~)
        if observe_ERPDAT.Reset_erp_paras_panel~=4
            return;
        end
        estudioworkingmemory('ERPTab_topos',0);
        gui_erp_scalp_map.run.BackgroundColor =  [ 1 1 1];
        gui_erp_scalp_map.run.ForegroundColor = [0 0 0];
        ERP_plot_scalp_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_scalp_map.cancel.BackgroundColor =  [1 1 1];
        gui_erp_scalp_map.cancel.ForegroundColor = [0 0 0];
        gui_erp_scalp_map.advanced.BackgroundColor =  [1 1 1];
        gui_erp_scalp_map.advanced.ForegroundColor = [0 0 0];
        try binArray = [1:observe_ERPDAT.ERP.nbin]; catch binArray = [];end
        binset = vect2colon(binArray,'Sort', 'on');
        binset = erase(binset,{'[',']'});
        gui_erp_scalp_map.bin_plot_edit.String =binset;
        gui_erp_scalp_map.latency_plot_edit.String = '';
        gui_erp_scalp_map.max_min.Value = 1;
        gui_erp_scalp_map.custom_option.Value = 0;
        gui_erp_scalp_map.abs_max.Value = 0;
        gui_erp_scalp_map.bar_scale_custom_option_edit.Enable = 'off';
        gui_erp_scalp_map.bar_scale_custom_option_edit.String = '';
        gui_erp_scalp_map.map_type_2d.Value=1;
        gui_erp_scalp_map.map_type_3d.Value=0;
        set(gui_erp_scalp_map.map_type_2d_type,'Enable','on','Value',1);
        gui_erp_scalp_map.map_type_3d_spl.Enable = 'off';
        gui_erp_scalp_map.map_extras_view_ops.Enable = 'off';
        gui_erp_scalp_map.map_extras_view_ops.String = '+X';
        gui_erp_scalp_map.map_extras_view_ops.Value = 1;
        gui_erp_scalp_map.map_extras_view_location.String = num2str([-180 30]);
        gui_erp_scalp_map.map_extras_view_location.Enable = 'off';
        gui_erp_scalp_map.map_type_2d_type_outside.Enable = 'on';
        gui_erp_scalp_map.map_extras_cmapb_disp.Value =0;
        gui_erp_scalp_map.map_extras_cmap_ops.Value =1;
        gui_erp_scalp_map.measurement.Value=2;
        pscale_legend = {1,1,1,1,0,'on','off',0,1};
        estudioworkingmemory('pscalp_plegend',pscale_legend);
        pagif_legend = {0,[],'',[]};
        estudioworkingmemory('pscalp_agif',pagif_legend);
        observe_ERPDAT.Reset_erp_paras_panel=5;
    end
end
