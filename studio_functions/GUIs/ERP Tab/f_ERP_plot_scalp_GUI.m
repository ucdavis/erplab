%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 2022

% ERPLAB Studio

function varargout = f_ERP_plot_scalp_GUI(varargin)
global observe_ERPDAT;
gui_erp_scalp_map = struct();
% addlistener(observe_ERPDAT,'ALLERP_change',@allErpChanged);
% addlistener(observe_ERPDAT,'ERP_change',@onErpChanged);
% addlistener(observe_ERPDAT,'CURRENTERP_change',@cerpchange);
addlistener(observe_ERPDAT,'ERP_bin_change',@ERP_bin_changed);
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);



%-----------------------------Name the title----------------------------------------------
% global ERP_plot_scalp_gui;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    ERP_plot_scalp_gui = uiextras.BoxPanel('Parent', fig, 'Title', 'Plot Scalp Maps', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    ERP_plot_scalp_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Plot Scalp Maps', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    ERP_plot_scalp_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Plot Scalp Maps', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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
        %         FontSize_defualt = erpworkingmemory('fontsizeGUI');
        %         if isempty(FontSize_defualt)
        FontSize_defualt = 12;
        %         end
        if strcmp(observe_ERPDAT.ALLERP(1).erpname,'No ERPset loaded')
            Enable_label = 'off';
        else
            Enable_label = 'on';
        end
        
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
        
        
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------bin and latency setting----------------------
        gui_erp_scalp_map.ERPscalpops = uiextras.VBox('Parent', ERP_plot_scalp_gui,'BackgroundColor',ColorB_def);
        
        %%%------------BIN TO PLOT---------------------
        gui_erp_scalp_map.bin_latency_title = uiextras.HBox('Parent', gui_erp_scalp_map.ERPscalpops,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', gui_erp_scalp_map.bin_latency_title,...
            'String','Bin & Latency:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        gui_erp_scalp_map.bin_plot_title = uiextras.HBox('Parent', gui_erp_scalp_map.ERPscalpops,'BackgroundColor',ColorB_def);
        gui_erp_scalp_map.bin_plot = uicontrol('Style','text','Parent',gui_erp_scalp_map.bin_plot_title,...
            'String','Bin(s)','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        set(gui_erp_scalp_map.bin_plot,'HorizontalAlignment','left');
        gui_erp_scalp_map.bin_plot_edit = uicontrol('Style','edit','Parent',gui_erp_scalp_map.bin_plot_title,...
            'String','','callback',@scalp_bin_edit,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        gui_erp_scalp_map.bin_plot_opt = uicontrol('Style','pushbutton','Parent',gui_erp_scalp_map.bin_plot_title,...
            'String','Browse','callback',@scalp_bin_op,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        set(gui_erp_scalp_map.bin_plot_title ,'Sizes',[60 150 60]);
        
        %%%------------Latency TO PLOT---------------------
        gui_erp_scalp_map.latency_plot_title = uiextras.HBox('Parent', gui_erp_scalp_map.ERPscalpops,'BackgroundColor',ColorB_def);
        gui_erp_scalp_map.latency_plot = uicontrol('Style','text','Parent',gui_erp_scalp_map.latency_plot_title,...
            'String','Latency (ms) [min max]','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        set(gui_erp_scalp_map.latency_plot,'HorizontalAlignment','left');
        gui_erp_scalp_map.latency_plot_edit = uicontrol('Style','edit','Parent',gui_erp_scalp_map.latency_plot_title,...
            'String','','callback',@scalp_latency_plot,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        
        %%----------------------------------Map Type------------------------------
        gui_erp_scalp_map.map_type_title = uiextras.HBox('Parent',  gui_erp_scalp_map.ERPscalpops,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', gui_erp_scalp_map.map_type_title,...
            'String','Map Type:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        %%2d
        gui_erp_scalp_map.map_type = uiextras.Grid('Parent',gui_erp_scalp_map.ERPscalpops,'BackgroundColor',ColorB_def);
        %
        gui_erp_scalp_map.map_type_2d = uicontrol('Style', 'radiobutton','Parent', gui_erp_scalp_map.map_type,...
            'String','2D','callback',@map_type_2d,'Value',1,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        gui_erp_scalp_map.map_type_3d = uicontrol('Style', 'radiobutton','Parent', gui_erp_scalp_map.map_type,...
            'String','3D','callback',@map_type_3d,'Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        gui_erp_scalp_map.map_type_2d_type = uicontrol('Style', 'popupmenu','Parent',gui_erp_scalp_map.map_type,...
            'String',{'map','contour','both','fill','blank'},'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        gui_erp_scalp_map.map_type_3d_spl = uicontrol('Style', 'pushbutton','Parent',gui_erp_scalp_map.map_type,...
            'String','Spline','callback',@map_type_3d_spl,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        
        gui_erp_scalp_map.map_type_2d_type_outside = uicontrol('Style', 'checkbox','Parent',gui_erp_scalp_map.map_type,...
            'String','Outside','Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', gui_erp_scalp_map.map_type);
        
        set(gui_erp_scalp_map.map_type, 'ColumnSizes',[50 130 90],'RowSizes',[25 30]);
        
        %%----------------------------------Bar scale------------------------------
        gui_erp_scalp_map.bar_scale_title = uiextras.HBox('Parent',  gui_erp_scalp_map.ERPscalpops,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', gui_erp_scalp_map.bar_scale_title,...
            'String','Color Bar Scale:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        gui_erp_scalp_map.bar_scale = uiextras.HBox('Parent',gui_erp_scalp_map.ERPscalpops,'BackgroundColor',ColorB_def);
        
        gui_erp_scalp_map.max_min = uicontrol('Style', 'radiobutton','Parent', gui_erp_scalp_map.bar_scale,...
            'String','Max-Min','callback',@bar_scale_max_min,'Value',1,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_scalp_map.custom_option = uicontrol('Style', 'radiobutton','Parent',gui_erp_scalp_map.bar_scale,...
            'String','Custom (min max:e.g.uv)','callback',@bar_scale_custom_opt,'Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(gui_erp_scalp_map.bar_scale ,'Sizes',[100 170]);
        
        
        gui_erp_scalp_map.bar_scale_2 = uiextras.HBox('Parent',gui_erp_scalp_map.ERPscalpops,'BackgroundColor',ColorB_def);
        gui_erp_scalp_map.abs_max = uicontrol('Style', 'radiobutton','Parent', gui_erp_scalp_map.bar_scale_2,...
            'String','Abs Max','callback',@bar_scale_abs_max,'Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_scalp_map.bar_scale_custom_option_edit = uicontrol('Style', 'edit','Parent',gui_erp_scalp_map.bar_scale_2,...
            'String',' ','callback',@bar_scale_custom_edit,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        set(gui_erp_scalp_map.bar_scale_2 ,'Sizes',[100 170]);
        
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
        
        gui_erp_scalp_map.map_extras_view_location = uicontrol('Style', 'edit','Parent',gui_erp_scalp_map.map_extras_view,...
            'String','','callback',@map_extras_view_location,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        
        set(gui_erp_scalp_map.map_extras_view,'Sizes',[70 100 100]);
        
        
        %%Extras
        gui_erp_scalp_map.map_extras_cmap_display= uiextras.HBox('Parent',gui_erp_scalp_map.ERPscalpops,'BackgroundColor',ColorB_def);
        
        gui_erp_scalp_map.map_extras_cmap = uicontrol('Style', 'text','Parent',  gui_erp_scalp_map.map_extras_cmap_display,...
            'String','Colormap','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(gui_erp_scalp_map.map_extras_cmap,'HorizontalAlignment','left');
        cMap_par={'jet','hsv','hot','cool','gray','viridis'};
        gui_erp_scalp_map.map_extras_cmap_ops = uicontrol('Style', 'popupmenu','Parent', gui_erp_scalp_map.map_extras_cmap_display,...
            'String',cMap_par,'Value',1,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1,1,1]);
        
        gui_erp_scalp_map.map_extras_cmapb_disp = uicontrol('Style', 'checkbox','Parent', gui_erp_scalp_map.map_extras_cmap_display,...
            'String','Display color scale bar','Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_scalp_map.map_extras_cmapb_disp.String =  '<html>Display Color<br />Scale Bar</html>';
        set(gui_erp_scalp_map.map_extras_cmap_display ,'Sizes',[70 90 110]);
        
        
        %%-----------------Run---------------------------------------------
        gui_erp_scalp_map.run_title = uiextras.HBox('Parent', gui_erp_scalp_map.ERPscalpops,'BackgroundColor',ColorB_def);
        
        uicontrol('Style','pushbutton','Parent',gui_erp_scalp_map.run_title,...
            'String','?','callback',@scap_help,'FontSize',16,'Enable','on'); % 2F
        
        gui_erp_scalp_map.advanced = uicontrol('Style','pushbutton','Parent',gui_erp_scalp_map.run_title,...
            'String','Advanced','callback',@apply_advanced,'FontSize',FontSize_defualt,'Enable',Enable_label); % 2F
        
        gui_erp_scalp_map.run = uicontrol('Style','pushbutton','Parent',gui_erp_scalp_map.run_title,...
            'String','Apply','callback',@apply_run,'FontSize',FontSize_defualt,'Enable',Enable_label); % 2F
        set(gui_erp_scalp_map.ERPscalpops,'Sizes',[20,25,25,25 55 20 30 25 20 25 30 30]);
    end



%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

% %%------------------help---------------------------------------------
    function scap_help(~,~)%% It seems that it can be ignored
        web('https://github.com/lucklab/erplab/wiki/Topographic-Mapping','-browser');
    end


%%-------------------Input bin number---------------------------------------
    function scalp_bin_edit(Source,~)
        binNums =  str2num(Source.String);
        [chk, msgboxText] = f_ERP_chckbinandchan(observe_ERPDAT.ERP, binNums, [],1);
        
        if chk(1)
            beep;
            msgboxText =  ['Plot Scalp Maps>Bins-',msgboxText];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            
            gui_erp_scalp_map.bin_plot_edit.String = '';
            return;
        end
    end

%%---------------------bin options---------------------------------
    function scalp_bin_op(~,~)
        
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
                gui_erp_scalp_map.bin_plot_edit.String=num2str(vect2colon(bin_label_select,'Sort', 'on'));
            else
                disp('User selected Cancel');
                return
            end
        else
            msgboxText =  ['Plot Scalp Maps>Bins>Browse-No bin information was found',];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end%Program end: Judge the number of latency/latencies
        S_ws= estudioworkingmemory('geterpvalues');
        if isempty(S_ws)
            return;
        end
        
        S_ws.binArray = bin_label_select;
        estudioworkingmemory('geterpvalues',S_ws);clear S_ws;
        observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
    end


%%----------------------Define time window (two latencies)-----------------
    function scalp_latency_plot(Source,~)
        Latecny_scale = str2num(Source.String);
        ERP_times = observe_ERPDAT.ERP.times;
        if isempty(Latecny_scale)
            beep;
            msgboxText =  ['Plot Scalp Maps>latency-No latency was defined',];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
        
        latency = Latecny_scale;
        if length(latency)~=2
            beep;
            msgboxText =  ['Plot Scalp Maps>Latency-Latency needs two values',];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        elseif length(latency)==2
            if latency(1)>=latency(2)
                beep;
                msgboxText =  ['Plot Scalp Maps>Latency-The left edge should be smaller than the seocnd one'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            
            if latency(1)< ERP_times(1)
                beep;
                msgboxText =  ['Plot Scalp Maps>Latency-The left edge should be larger than the seocnd one',32, num2str(ERP_times(1)),'ms'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            
            if latency(2)> ERP_times(end)
                beep;
                msgboxText =  ['Plot Scalp Maps>Latency-The right edge should be smaller than the seocnd one',32, num2str(ERP_times(end)),'ms'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            
            if latency(1)> ERP_times(end)
                beep;
                msgboxText =  ['Plot Scalp Maps>Latency-The left edge should be smaller than the seocnd one',32, num2str(ERP_times(end)),'ms'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            
        end
    end




%%-----------------Dispaly topography with 2D------------------------------
    function map_type_2d(~,~)
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


%%---------------------Spline setting for 3D-------------------------------
    function map_type_3d_spl(~,~)
        pathName_def =  erpworkingmemory('ERP_save_folder');
        if isempty(pathName_def)
            pathName_def =cd;
        end
        Selectederp_Index= estudioworkingmemory('selectederpstudio');
        if isempty(Selectederp_Index)%%Check indexs of the selected ERPsets
            Selectederp_Index = observe_ERPDAT.CURRENTERP;
            if isempty(Selectederp_Index)
                msgboxText =  'No ERPset was imported!!!';
                title = 'EStudio: f_ERP_binoperation_GUI error.';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,Selectederp_Index);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        else
            [chk, msgboxText] = f_ERP_chckerpindex(observe_ERPDAT.ALLERP, Selectederp_Index);
            if chk==1
                Selectederp_Index = observe_ERPDAT.CURRENTERP;
                if isempty(Selectederp_Index)
                    msgboxText =  'No ERPset was imported!!!';
                    title = 'EStudio: f_ERP_binoperation_GUI error.';
                    errorfound(msgboxText, title);
                    return;
                end
                S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,Selectederp_Index);
                estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
                estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
            end
        end
        
        %%Send message to Message panel
        erpworkingmemory('f_ERP_proces_messg','Plot Scalp Maps');
        observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
        
        
        Selectederp_Index_save = [];
        count_scalp = 0;
        try
            erpworkingmemory('f_ERP_proces_messg','Plot Scalp Maps > 3D > Spline');
            observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
            ALLERPCOM = evalin('base','ALLERPCOM');
            for Numofselectederp = 1:length(Selectederp_Index)
                ERP = observe_ERPDAT.ALLERP(Selectederp_Index(Numofselectederp));
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
                    disp('User selected Cancel');
                    observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
                    observe_ERPDAT.Process_messg =3;%%
                    return
                end
                
                splinefile = splineinfo.path;
                
                if isempty(splinefile)
                    msgboxText =  'You must specify a name for the spline file.';
                    title = 'EStudio: Plot Scalp Maps inputs';
                    errorfound(msgboxText, title);
                    return
                end
                Save_file_label =0;
                if splineinfo.save
                    if isempty(ERP.splinefile)
                        ERP.splinefile = splinefile;
                        %                         ERP = pop_savemyerp(ERP, 'gui', 'erplab', 'History', 'off');
                    else
                        question = ['This ERPset already has spline file info.\n'...
                            'Would you like to replace it?'];
                        title_msg   = 'EStudio: spline file';
                        button   = askquest(sprintf(question), title_msg);
                        
                        if ~strcmpi(button,'yes')
                            disp('User selected Cancel')
                            return
                        else
                            ERP.splinefile = splinefile;
                        end
                    end
                    
                    Answer = f_ERP_save_single_file(strcat(ERP.erpname,'_scalspline'),ERP.filename,Selectederp_Index(Numofselectederp));
                    if isempty(Answer)
                        beep;
                        disp('User selectd cancal');
                        observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
                        observe_ERPDAT.Process_messg =3;%%
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
                    Selectederp_Index_save(count_scalp) = length(observe_ERPDAT.ALLERP);
                    splineinfo.save = 0;
                    observe_ERPDAT.ERP = ERP;
                else
                    ERP.splinefile = splinefile;
                    observe_ERPDAT.ALLERP(Selectederp_Index(Numofselectederp)) = ERP;
                    observe_ERPDAT.ERP = ERP;
                end
                
                
                if Save_file_label==1
                    [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', ERP.filename, 'filepath',ERP.filepath);
                    [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                    assignin('base','ERPCOM',ERPCOM);
                end
            end%%end for ERPset loop
            
            if ~isempty(Selectederp_Index_save)
                try
                    Selected_ERP_afd =  Selectederp_Index_save;
                    observe_ERPDAT.CURRENTERP = Selectederp_Index_save(1);
                catch
                    Selected_ERP_afd = length(observe_ERPDAT.ALLERP);
                    observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
                end
                observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
                estudioworkingmemory('selectederpstudio',Selected_ERP_afd);
            end
            
            assignin('base','ALLERPCOM',ALLERPCOM);
            erpworkingmemory('f_ERP_bin_opt',1);
            observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
            observe_ERPDAT.Process_messg =2;
            return;
        catch
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
            Selected_ERP_afd =observe_ERPDAT.CURRENTERP;
            estudioworkingmemory('selectederpstudio',Selected_ERP_afd);
            erpworkingmemory('f_ERP_bin_opt',1);
            observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
            observe_ERPDAT.Process_messg =3;%%
            return;
        end%%end for try
        
        
    end

%%------------------------------Color bar scale: Max-min----------------------------
    function bar_scale_max_min(~,~)
        gui_erp_scalp_map.max_min.Value = 1;
        gui_erp_scalp_map.custom_option.Value = 0;
        gui_erp_scalp_map.abs_max.Value = 0;
        gui_erp_scalp_map.bar_scale_custom_option_edit.Enable = 'off';
    end


%%------------------------------Color bar scale: abs max----------------------------
    function bar_scale_abs_max(~,~)
        gui_erp_scalp_map.max_min.Value = 0;
        gui_erp_scalp_map.custom_option.Value = 0;
        gui_erp_scalp_map.abs_max.Value = 1;
        gui_erp_scalp_map.bar_scale_custom_option_edit.Enable = 'off';
    end


%%------------------------------Color bar scale: custom----------------------------
    function bar_scale_custom_opt(~,~)
        gui_erp_scalp_map.max_min.Value = 0;
        gui_erp_scalp_map.custom_option.Value = 1;
        gui_erp_scalp_map.abs_max.Value = 0;
        gui_erp_scalp_map.bar_scale_custom_option_edit.Enable = 'on';
    end
%%-------------------Bar scale custom edit---------------------------------
    function bar_scale_custom_edit(Source,~)
        
        
    end




%%---------------location selection----------------------------------------
    function map_extras_view_ops(Source,~)
        
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

%%---------------------Setting for advanced---------------------------------
    function apply_advanced(~,~)
        
        is2Dmap  = gui_erp_scalp_map.map_type_2d.Value;
        
        pscale_legend = {1,1,1,1,0,'on','off',0,is2Dmap};
        Latecny_scale = str2num(gui_erp_scalp_map.latency_plot_edit.String);
        ERP_times = observe_ERPDAT.ERP.times;
        if isempty(Latecny_scale)
            beep;
            msgboxText =  ['Plot Scalp Maps - No latency was defined'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        latency = Latecny_scale;
        if length(latency)~=2
            beep;
            msgboxText =  ['Plot Scalp Maps - Latency needs two values'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        elseif length(latency)==2
            if latency(1)>=latency(2)
                beep;
                msgboxText =  ['Plot Scalp Maps - Left edge of Latency should be smaller than the seocnd one'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            
            if latency(1)< ERP_times(1)
                beep;
                msgboxText =  ['Plot Scalp Maps - Left edge of Latency should be larger than',32, num2str(ERP_times(1)),'ms'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            
            if latency(2)> ERP_times(end)
                beep;
                msgboxText =  ['Plot Scalp Maps - Right edge of Latency should be smaller than',32, num2str(ERP_times(end)),'ms'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            
            if latency(1)> ERP_times(end)
                beep;
                msgboxText =  ['Plot Scalp Maps - Left edge of Latency should be smaller than',32, num2str(ERP_times(end)),'ms'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
        end
        
        pagif_legend = {0,[],'',latency};
        Answer = f_scalplotadvanceGUI(pscale_legend,pagif_legend);
        if isempty(Answer)
            beep;
            disp('User selected cancel.');
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
        %%-------------------Plotting scalp mapping-----------------------
        %%Send message to Message panel
        erpworkingmemory('f_ERP_proces_messg','Plot Scalp Maps');
        observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
        
        
        pathName_def =  erpworkingmemory('ERP_save_folder');
        if isempty(pathName_def)
            pathName_def =cd;
        end
        
        Selectederp_Index= estudioworkingmemory('selectederpstudio');
        if isempty(Selectederp_Index)
            Selectederp_Index = observe_ERPDAT.CURRENTERP;
            
            if isempty(Selectederp_Index)
                beep;
                msgboxText =  ['Plot Scalp Maps - No ERPset was selected'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,Selectederp_Index);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
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
            beep;
            msgboxText =  ['Plot Scalp Maps -',msgboxText];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        latencyArray = str2num(gui_erp_scalp_map.latency_plot_edit.String);
        ERP_times = observe_ERPDAT.ERP.times;
        if isempty(latencyArray)
            beep;
            msgboxText =  ['Plot Scalp Maps - No latency was defined'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        if length(latencyArray)~=2
            beep;
            msgboxText =  ['Plot Scalp Maps - Latency needs two values'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        elseif length(latencyArray)==2
            if latencyArray(1)>=latencyArray(2)
                beep;
                msgboxText =  ['Plot Scalp Maps - The left edge of latency should be smaller than the seocnd one'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
                
            end
            
            if latencyArray(1)< ERP_times(1)
                beep;
                msgboxText =  ['Plot Scalp Maps - The left edge of latency should be larger than',32, num2str(ERP_times(1)),'ms'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            if latencyArray(2)> ERP_times(end)
                beep;
                msgboxText =  ['Plot Scalp Maps - The right edge of latency should be smaller than',32, num2str(ERP_times(end)),'ms'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            if latencyArray(1)> ERP_times(end)
                beep;
                msgboxText =  ['Plot Scalp Maps - The left edge of latency should be smaller than',32, num2str(ERP_times(end)),'ms'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
        end
        measurestr   = 'mean';
        baseline     = 'none';
        if gui_erp_scalp_map.max_min.Value
            maplimit     = 'maxmin';
        elseif gui_erp_scalp_map.abs_max.Value
            maplimit     = 'absmax';
        elseif gui_erp_scalp_map.custom_option.Value
            cusca  = str2num(gui_erp_scalp_map.bar_scale_custom_option_edit.String);
            if isempty(cusca)
                beep;
                msgboxText =  ['Plot Scalp Maps - No value was defined for "Color Bar Scale"'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            else
                ncusca = length(cusca);
                if ncusca == 2
                    if cusca(1)<cusca(2)
                        maplimit = cusca;
                        
                    else%%
                        beep;
                        msgboxText =  ['Plot Scalp Maps - the first value should be smaller than the second one for "Color Bar Scale"'];
                        fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                        erpworkingmemory('f_ERP_proces_messg',msgboxText);
                        observe_ERPDAT.Process_messg =4;
                        return;
                    end
                else%%one value
                    beep;
                    msgboxText =  ['Plot Scalp Maps - "Color Bar Scale" needs 2 values.'];
                    fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                    erpworkingmemory('f_ERP_proces_messg',msgboxText);
                    observe_ERPDAT.Process_messg =4;
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
        
        Selected_erpset =  estudioworkingmemory('selectederpstudio');
        if isempty(Selected_erpset)
            Selected_erpset =  observe_ERPDAT.CURRENTERP;
            S_erpbinchan = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,Selected_erpset);
            estudioworkingmemory('geterpbinchan',S_erpbinchan.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpbinchan.geterpplot);
            estudioworkingmemory('selectederpstudio',Selected_erpset);
        end
        
        ALLERPCOM = evalin('base','ALLERPCOM');
        try
            
            for Numofselcerp = 1:numel(Selected_erpset)
                ERP = observe_ERPDAT.ALLERP(Selected_erpset(Numofselcerp));
                if strcmpi(mtype, '3d')
                    
                    if isempty(ERP.splinefile) && isempty(splineinfo.path)
                        beep;
                        msgboxText =  ['Plot Scalp Maps -',ERP.erpname,' is not linked to any spline file.\n'...
                            'At the Scal plot GUI, use "spline file" button, under the Map type menu, to find/create one.'];
                        fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                        erpworkingmemory('f_ERP_proces_messg',msgboxText);
                        observe_ERPDAT.Process_messg =4;
                        return;
                    elseif isempty(ERP.splinefile) && ~isempty(splineinfo.path)
                        %if splineinfo.new==1
                        headplot('setup', ERP.chanlocs, splineinfo.path); %Builds the new spline file.
                        
                    elseif ~isempty(ERP.splinefile) && ~isempty(splineinfo.path)
                        headplot('setup', ERP.chanlocs, splineinfo.path); %Builds the new spline file.
                        splinefile = splineinfo.path;
                        
                    else
                        %disp('C')
                        splinefile = ERP.splinefile;
                        headplot('setup', ERP.chanlocs, splinefile);
                    end
                else
                    %splinefile = '';
                    splinefile = ERP.splinefile;
                    if strcmpi(mtype, '3d')
                        headplot('setup', ERP.chanlocs, splinefile);
                    end
                    %disp('D')
                end
                if isempty(binArray)
                    binArray = [1:ERP.nbin];
                end
                [ERP, ERPCOM] = pop_scalplot(ERP, binArray, latencyArray, 'Value', measurestr, 'Blc', baseline, 'Maplimit', maplimit, 'Colorbar', colorbari,...
                    'Colormap', cmap,'Animated', ismoviexx, 'AdjustFirstFrame', aff, 'FPS', FPS, 'Filename', fullgifname, 'Legend', mapleg, 'Electrodes', showelecx,...
                    'Position', posfig, 'Maptype', mtype, 'Mapstyle', smapstyle, 'Plotrad', mplotrad,'Mapview', mapview, 'Splinefile', splinefile,...
                    'Maximize', maxim, 'Electrodes3d', elec3D,'History', 'gui');
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                pause(0.1);
            end
            [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);
            assignin('base','ALLERPCOM',ALLERPCOM);
            assignin('base','ERPCOM',ERPCOM);
            observe_ERPDAT.Process_messg =2; %%Marking for the procedure has been started.
        catch
            observe_ERPDAT.Process_messg =3; %%Marking for the procedure has been started.
            return;
        end
    end

%%---------------------Run-------------------------------------------------
    function apply_run(~,~)
        
        %%Send message to Message panel
        erpworkingmemory('f_ERP_proces_messg','Plot Scalp Maps');
        observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
        pathName_def =  erpworkingmemory('ERP_save_folder');
        if isempty(pathName_def)
            pathName_def =cd;
        end
        
        Selectederp_Index= estudioworkingmemory('selectederpstudio');
        if isempty(Selectederp_Index)
            Selectederp_Index = observe_ERPDAT.CURRENTERP;
            if isempty(Selectederp_Index)
                beep;
                msgboxText =  ['Plot Scalp Maps - No ERPset was selected'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,Selectederp_Index);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        
        %         if isempty(plegend)
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
        
        agif.value =0;
        agif.fps =[];
        agif.fname ='';
        
        binArray     = str2num(gui_erp_scalp_map.bin_plot_edit.String);
        [chk, msgboxText] = f_ERP_chckbinandchan(observe_ERPDAT.ERP, binArray, [],1);
        if chk(1)
            beep;
            msgboxText =  ['Plot Scalp Maps -',msgboxText];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
        latencyArray = str2num(gui_erp_scalp_map.latency_plot_edit.String);
        ERP_times = observe_ERPDAT.ERP.times;
        if isempty(latencyArray)
            beep;
            msgboxText =  ['Plot Scalp Maps - No latency was defined',];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
        
        
        if length(latencyArray)~=2
            beep;
            msgboxText =  ['Plot Scalp Maps - Latency needs two values',];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
            
        elseif length(latencyArray)==2
            if latencyArray(1)>=latencyArray(2)
                beep;
                msgboxText =  ['Plot Scalp Maps - The left edge of latency should be smaller than the right one'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            
            if latencyArray(1)< ERP_times(1)
                beep;
                msgboxText =  ['Plot Scalp Maps - The left edge of latency should be larger than',32, num2str(ERP_times(1)),'ms'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            
            if latencyArray(2)> ERP_times(end)
                beep;
                msgboxText =  ['Plot Scalp Maps - The left edge of latency should be smaller than',32, num2str(ERP_times(end)),'ms'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            
            
            if latencyArray(1)> ERP_times(end)
                beep;
                msgboxText =  ['Plot Scalp Maps - The left edge of latency should be smaller than',32, num2str(ERP_times(end)),'ms'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
        end
        
        
        
        measurestr   = 'mean';
        baseline     = 'none';
        if gui_erp_scalp_map.max_min.Value
            maplimit     = 'maxmin';
        elseif gui_erp_scalp_map.abs_max.Value
            maplimit     = 'absmax';
        elseif gui_erp_scalp_map.custom_option.Value
            cusca  = str2num(gui_erp_scalp_map.bar_scale_custom_option_edit.String);
            if isempty(cusca)
                beep;
                msgboxText =  ['Plot Scalp Maps - No value was defined for "Color Bar Scale"'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            else
                ncusca = length(cusca);
                if ncusca == 2
                    if cusca(1)<cusca(2)
                        maplimit = cusca;
                        
                    else%%
                        beep;
                        msgboxText =  ['Plot Scalp Maps - the first value should be smaller than the second one for "Color Bar Scale"'];
                        fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                        erpworkingmemory('f_ERP_proces_messg',msgboxText);
                        observe_ERPDAT.Process_messg =4;
                        return;
                    end
                else%%one value
                    beep;
                    msgboxText =  ['Plot Scalp Maps - "Color Bar Scale" needs 2 values'];
                    fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                    erpworkingmemory('f_ERP_proces_messg',msgboxText);
                    observe_ERPDAT.Process_messg =4;
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
        
        Selected_erpset =  estudioworkingmemory('selectederpstudio');
        if isempty(Selected_erpset)
            Selected_erpset =  observe_ERPDAT.CURRENTERP;
            S_erpbinchan = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,Selected_erpset);
            estudioworkingmemory('geterpbinchan',S_erpbinchan.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpbinchan.geterpplot);
            estudioworkingmemory('selectederpstudio',Selected_erpset);
        end
        
        ALLERPCOM = evalin('base','ALLERPCOM');
        try
            
            for Numofselcerp = 1:numel(Selected_erpset)
                ERP = observe_ERPDAT.ALLERP(Selected_erpset(Numofselcerp));
                if strcmpi(mtype, '3d')
                    
                    if isempty(ERP.splinefile) && isempty(splineinfo.path)
                        beep;
                        msgboxText =  ['Plot Scalp Maps -',ERP.erpname,' is not linked to any spline file.\n'...
                            'At the Scal plot GUI, use "spline file" button, under the Map type menu, to find/create one.'];
                        fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                        erpworkingmemory('f_ERP_proces_messg',msgboxText);
                        observe_ERPDAT.Process_messg =4;
                        return;
                        
                    elseif isempty(ERP.splinefile) && ~isempty(splineinfo.path)
                        %if splineinfo.new==1
                        headplot('setup', ERP.chanlocs, splineinfo.path); %Builds the new spline file.
                        
                    elseif ~isempty(ERP.splinefile) && ~isempty(splineinfo.path)
                        headplot('setup', ERP.chanlocs, splineinfo.path); %Builds the new spline file.
                        splinefile = splineinfo.path;
                        
                    else
                        %disp('C')
                        splinefile = ERP.splinefile;
                        headplot('setup', ERP.chanlocs, splinefile);
                    end
                else
                    %splinefile = '';
                    splinefile = ERP.splinefile;
                    if strcmpi(mtype, '3d')
                        headplot('setup', ERP.chanlocs, splinefile);
                    end
                    %disp('D')
                end
                if isempty(binArray)
                    binArray = [1:ERP.nbin];
                end
                [ERP, ERPCOM] = pop_scalplot(ERP, binArray, latencyArray, 'Value', measurestr, 'Blc', baseline, 'Maplimit', maplimit, 'Colorbar', colorbari,...
                    'Colormap', cmap,'Animated', ismoviexx, 'AdjustFirstFrame', aff, 'FPS', FPS, 'Filename', fullgifname, 'Legend', mapleg, 'Electrodes', showelecx,...
                    'Position', posfig, 'Maptype', mtype, 'Mapstyle', smapstyle, 'Plotrad', mplotrad,'Mapview', mapview, 'Splinefile', splinefile,...
                    'Maximize', maxim, 'Electrodes3d', elec3D,'History', 'gui');
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                pause(0.1);
            end
            [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);
            assignin('base','ALLERPCOM',ALLERPCOM);
            assignin('base','ERPCOM',ERPCOM);
            observe_ERPDAT.Process_messg =2; %%Marking for the procedure has been started.
        catch
            observe_ERPDAT.Process_messg =3; %%Marking for the procedure has been started.
            return;
        end
    end




%%--------Setting current ERPset/session history based on the current updated ERPset------------
    function Count_currentERPChanged(~,~)
        
        Selectederp_Index= estudioworkingmemory('selectederpstudio');
        if isempty(Selectederp_Index)
            Selectederp_Index = observe_ERPDAT.CURRENTERP;
            if isempty(Selectederp_Index)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: f_ERP_binoperation_GUI error.';
                errorfound(msgboxText, title);
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
        
        if any(checked_ERPset_Index([1:2 4]))|| checked_curr_index
            Enable_lab = 'off';
        else
            Enable_lab = 'on';
        end
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
        if gui_erp_scalp_map.custom_option.Value
            gui_erp_scalp_map.bar_scale_custom_option_edit.Enable = 'on';
        else
            gui_erp_scalp_map.bar_scale_custom_option_edit.Enable = 'off';
        end
        %%Map extras
        gui_erp_scalp_map.map_extras_view_ops.Enable= Enable_lab;
        gui_erp_scalp_map.map_extras_view_location.Enable= Enable_lab;
        gui_erp_scalp_map.map_extras_cmap_ops.Enable = Enable_lab;
        gui_erp_scalp_map.map_extras_cmapb_disp.Enable= Enable_lab;
        gui_erp_scalp_map.map_type_2d_type.Enable= Enable_lab;
        %%Run and advanced
        gui_erp_scalp_map.advanced.Enable= Enable_lab;
        gui_erp_scalp_map.run.Enable= Enable_lab;
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
        
    end


%----------displayed bin label will be midified after vaied channels was selected--------
    function ERP_bin_changed(~,~)
        gui_erp_scalp_map.bin_plot_edit.String = num2str(vect2colon(observe_ERPDAT.ERP_bin,'Sort', 'on'));
        S_ws= estudioworkingmemory('geterpvalues');
        S_ws.binArray = observe_ERPDAT.ERP_bin;
        estudioworkingmemory('geterpvalues',S_ws);clear S_ws;
    end
end
