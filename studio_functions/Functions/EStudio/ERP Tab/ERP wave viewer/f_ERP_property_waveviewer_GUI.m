%%This function is to plot the panel for "Viewer properties".

% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022  && Nov 2023


function varargout = f_ERP_property_waveviewer_GUI(varargin)
global gui_erp_waviewer;
global viewer_ERPDAT;
addlistener(viewer_ERPDAT,'Reset_Waviewer_panel_change',@Reset_Waviewer_panel_change);
gui_property_waveviewer = struct();

%-----------------------------Name the title----------------------------------------------
% global box_erpwave_viewer_property;
[version reldate,ColorB_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    box_erpwave_viewer_property = uiextras.BoxPanel('Parent', fig, 'Title', 'Viewer Properties', 'Padding', 5,...
        'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w','FontSize', 12); % Create boxpanel
elseif nargin == 1
    box_erpwave_viewer_property = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Viewer Properties', 'Padding', 5,...
        'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w','FontSize', 12);
else
    box_erpwave_viewer_property = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Viewer Properties', 'Padding', 5,...
        'FontSize', varargin{2},'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w');
end
% gui_erp_waviewer.Window.WindowButtonMotionFcn = {@Viewerpos_width};
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
varargout{1} = box_erpwave_viewer_property;

    function drawui_plot_property(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        gui_property_waveviewer.DataSelBox = uiextras.VBox('Parent', box_erpwave_viewer_property,'BackgroundColor',ColorBviewer_def);
        
        %%-----------------Setting for
        %%parameters---------------------------------------
        gui_property_waveviewer.parameters_title = uiextras.HBox('Parent', gui_property_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        
        uicontrol('Style','text','Parent', gui_property_waveviewer.parameters_title,'String','Parameters:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); %1A
        gui_property_waveviewer.parameters_load = uicontrol('Style','pushbutton','Parent', gui_property_waveviewer.parameters_title,'String','Load',...
            'callback',@parameters_load,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %
        gui_property_waveviewer.parameters_save = uicontrol('Style','pushbutton','Parent', gui_property_waveviewer.parameters_title,'String','Save',...
            'callback',@parameters_save,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %
        gui_property_waveviewer.parameters_saveas = uicontrol('Style','pushbutton','Parent', gui_property_waveviewer.parameters_title,'String','Save as',...
            'callback',@parameters_saveas,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %
        set(gui_property_waveviewer.parameters_title, 'Sizes',[70 55 55 55]);
        
        %%-----------Setting for viewer title-----------------------------
        gui_property_waveviewer.viewer_TN_title = uiextras.HBox('Parent', gui_property_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_property_waveviewer.viewer_TN_title,'String','Title:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); %1A
        ViewerName = estudioworkingmemory('viewername');
        if isempty(ViewerName)
            ViewerName = char('My Viewer');
        end
        gui_property_waveviewer.parameters_load = uicontrol('Style','edit','Parent',gui_property_waveviewer.viewer_TN_title,'String',ViewerName,...
            'callback',@viewer_TN,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %
        set(gui_property_waveviewer.viewer_TN_title, 'Sizes',[70 165]);
        
        New_pos = gui_erp_waviewer.screen_pos;
        if isempty(New_pos) || numel(New_pos)~=2
            New_pos = [75,75];
            erpworkingmemory('ERPWaveScreenPos',New_pos);
        end
        
        New_pos = roundn(New_pos,-3);
        
        gui_property_waveviewer.viewer_pos_title1 = uiextras.HBox('Parent', gui_property_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_property_waveviewer.viewer_pos_title1,'String','Window size:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def,'FontWeight','bold'); %1A
        
        gui_property_waveviewer.viewer_wz_title = uiextras.HBox('Parent', gui_property_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_property_waveviewer.viewer_wz_title,'String','Width:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); %1A
        gui_property_waveviewer.parameters_pos_width = uicontrol('Style','edit','Parent',gui_property_waveviewer.viewer_wz_title,'String',num2str(New_pos(1)),...
            'callback',@Viewerpos_width,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %
        uicontrol('Style','text','Parent', gui_property_waveviewer.viewer_wz_title,'String','ms,',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); %1A
        uicontrol('Style','text','Parent', gui_property_waveviewer.viewer_wz_title,'String','Height:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); %1A
        gui_property_waveviewer.parameters_pos_height = uicontrol('Style','edit','Parent',gui_property_waveviewer.viewer_wz_title,'String',num2str(New_pos(2)),...
            'callback',@Viewerpos_height,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %
        uicontrol('Style','text','Parent', gui_property_waveviewer.viewer_wz_title,'String','ms',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); %1A
        
        set(gui_property_waveviewer.viewer_wz_title, 'Sizes',[40 55 20 45 55 20]);
        
        
        set(gui_property_waveviewer.DataSelBox ,'Sizes',[30 25 25 25])
    end



%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%-------------------------Setting for load--------------------------------
    function parameters_load(~,~)
        MessageViewer= char(strcat('Viewer Properties > Load'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        try
            ALLERP = evalin('base','ALLERP');
        catch
            MessageViewer= char(strcat('Viewer Properties > Load: ALLERP is not available on workspace, you therfore cannot further handle'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        if isempty(ALLERP)
            MessageViewer= char(strcat('Viewer Properties > Load: ALLERP is empty on workspace, you therfore cannot further handle'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        
        [filename, filepath,indxs] = uigetfile({'*.mat'}, ...
            'Load parametrs for "My viewer"', ...
            'MultiSelect', 'off');
        if isequal(filename,0)
            disp('User selected Cancel');
            return;
        end
        
        [pathstr, erpfilename, ext] = fileparts(filename) ;
        ext = '.mat';
        
        erpFilename = char(strcat(erpfilename,ext));
        
        try
            gui_erp_waviewer.ERPwaviewer = importdata([filepath,erpFilename]);
            gui_erp_waviewer.ERPwaviewer.ALLERP= ALLERP;
        catch
            beep;
            MessageViewer=['My viewer > Viewer Propoerties > Load: Cannot load the saved parameters of My viewer '];
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        
        try
            CURRENTERP = evalin('base','CURRENTERP');
        catch
            CURRENTERP = [];
        end
        if isempty(CURRENTERP) || numel(CURRENTERP)~=1 || any(CURRENTERP>length(ALLERP))
            CURRENTERP = length(ALLERP);
        end
        gui_erp_waviewer.ERPwaviewer.ERP = ALLERP(CURRENTERP);
        gui_erp_waviewer.ERPwaviewer.CURRENTERP = CURRENTERP;
        gui_erp_waviewer.ERPwaviewer.SelectERPIdx = CURRENTERP;
        gui_erp_waviewer.ERPwaviewer.PageIndex = 1;
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
            erplabstudioverNumOld = str2num(ERPwaviewer.version);
        catch
            erplabstudioverNumOld = [];
        end
        if isempty(erplabstudioverNumOld) || erplabstudioverNumOld<erplabstudioverNum
            if strcmpi(ERPtooltype,'EStudio')
                MessageViewer= char(strcat('Viewer Properties > Load - This settings file was created using an older version of EStudio'));
            elseif strcmpi(ERPtooltype,'ERPLAB')
                MessageViewer= char(strcat('Viewer Properties > Load - This settings file was created using an older version of ERPLAB'));
            end
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =4;
        end
        
        viewer_ERPDAT.loadproper_count = 1;
        f_redrawERP_viewer_test();
        
        MessageViewer= char(strcat('Viewer Properties > Load'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =2;
    end

%%-------------------------Setting for Save--------------------------------
    function parameters_save(~,~)
        MessageViewer= char(strcat('Viewer Properties > Save'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        ERPwaviewer  = gui_erp_waviewer.ERPwaviewer;
        
        pathstr = pwd;
        namedef ='Advanced_ERPWave_Viewer';
        erpFilename = char(strcat(namedef,'.mat'));
        
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
        ERPwaviewer.version = erplabstudiover;
        
        ERPwaviewer.ALLERP = [];
        ERPwaviewer.ERP = [];
        ERPwaviewer.CURRENTERP = [];
        ERPwaviewer.SelectERPIdx = [];
        ERPwaviewer.PageIndex = [];
        try
            save([pathstr,filesep,erpFilename],'ERPwaviewer','-v7.3');
        catch
            MessageViewer= char(strcat('Viewer Propoerties > Save: Cannot save the parameters of My viewer'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        MessageViewer= char(strcat('Viewer Properties > Save'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =2;
    end
%%-------------------------Setting for Save as--------------------------------
    function parameters_saveas(~,~)
        MessageViewer= char(strcat('Viewer Properties > Save as'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        
        pathstr = pwd;
        namedef ='Advanced_ERPWave_Viewer';
        [erpfilename, erppathname, indxs] = uiputfile({'*.mat'}, ...
            ['Save "','Information of My Viewer', '" as'],...
            fullfile(pathstr,namedef));
        
        if isequal(erpfilename,0)
            beep;
            viewer_ERPDAT.Process_messg =3;
            disp('User selected Cancel')
            return
        end
        
        ERPwaviewer  = gui_erp_waviewer.ERPwaviewer;
        
        [pathstr, erpfilename, ext] = fileparts(erpfilename) ;
        ext = '.mat';
        
        erpFilename = char(strcat(erpfilename,ext));
        
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
        ERPwaviewer.version = erplabstudiover;
        ERPwaviewer.ALLERP = [];
        ERPwaviewer.ERP = [];
        ERPwaviewer.CURRENTERP = [];
        ERPwaviewer.SelectERPIdx = [];
        ERPwaviewer.PageIndex = [];
        try
            save([erppathname,erpFilename],'ERPwaviewer','-v7.3');
        catch
            MessageViewer= char(strcat('Viewer Propoerties > Save: Cannot save the parameters of My viewer'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        MessageViewer= char(strcat('Viewer Properties > Save as'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =2;
        
    end

%%------------------Title name for Wave Viewer-----------------------------
    function viewer_TN(source_locationname,~)
        MessageViewer= char(strcat('Viewer Properties > Title'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        ViewerName = source_locationname.String;
        if isempty(ViewerName)
            ViewerName = 'My Viewer';
        end
        try
            [version1 reldate] = geterplabstudioversion;
            erplabstudiover = version1;
        catch
            erplabstudiover = '??';
        end
        currvers  = ['ERPLAB Studio ' erplabstudiover,'-',32,ViewerName];
        estudioworkingmemory('viewername',ViewerName);
        
        gui_erp_waviewer.ERPwaviewer.figname = ViewerName;
        gui_erp_waviewer.Window.Name = currvers;
        viewer_ERPDAT.Process_messg =2;
    end

%%-----------------------width for window size-----------------------------
    function Viewerpos_width(Str,~)
        New_pos1_width = str2num(Str.String);
        try
            New_posin = erpworkingmemory('ERPWaviewerScreenPos');
        catch
            New_posin = [75,75];
        end
        if isempty(New_posin) ||numel(New_posin)~=2
            New_posin = [75,75];
        end
        
        if isempty(New_pos1_width) || numel(New_pos1_width)~=1 || any(New_pos1_width<=0)
            Str.String = num2str(New_posin(1));
            MessageViewer= char(strcat('Viewer Properties > Window size > width: The width value is invalid and it must be a positive value'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        New_pos1(1) = New_pos1_width;
        New_pos1_h = str2num(gui_property_waveviewer.parameters_pos_height.String);
        
        if isempty(New_pos1_h) || numel(New_pos1_h)~=1 || any(New_pos1_h<=0)
            gui_property_waveviewer.parameters_pos_height.String = num2str(New_posin(2));
            MessageViewer= char(strcat('Viewer Properties > Window size > width: The height value is invalid and it must be a positive value'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        New_pos1(2) = New_pos1_h;
        
        MessageViewer= char(strcat('Viewer Properties > Window size > width'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        try
            ScreenPos =  get( groot, 'Screensize' );
        catch
            ScreenPos =  get( 0, 'Screensize' );
        end
        
        New_posin(2) = abs(New_posin(2));
        
        New_pos = gui_erp_waviewer.Window.Position;
       
        erpworkingmemory('ERPWaviewerScreenPos',New_pos1);
        
        try
            POS4 = (New_pos1(2)-New_posin(2))/100;
            new_pos =[New_pos(1),New_pos(2)-ScreenPos(4)*POS4,ScreenPos(3)*New_pos1(1)/100,ScreenPos(4)*New_pos1(2)/100];
            if new_pos(2)+new_pos(4)<ScreenPos(4)
                set(gui_erp_waviewer.Window, 'Position', new_pos);
            else%%exceed
                new_pos(2) = ScreenPos(4) - (new_pos(2)+new_pos(4));
                set(gui_erp_waviewer.Window, 'Position', new_pos);
            end
            
        catch
            erpworkingmemory('f_EEG_proces_messg',['The defined Window Size for Viewer is invalid and it must be two numbers']);
            viewer_ERPDAT.Process_messg =4;
            set(gui_erp_waviewer.Window, 'Position', [0 0 0.75*ScreenPos(3) 0.75*ScreenPos(4)]);
            erpworkingmemory('ERPWaviewerScreenPos',[75 75]);
        end
        gui_erp_waviewer.ERPwaviewer.FigOutpos = New_pos1;
        
        viewer_ERPDAT.Count_currentERP=1;
        viewer_ERPDAT.Process_messg =2;
    end

%%---------------------height for window size------------------------------
    function Viewerpos_height(Str,~)
        
        try
            New_posin = erpworkingmemory('ERPWaviewerScreenPos');
        catch
            New_posin = [75,75];
        end
        if isempty(New_posin) ||numel(New_posin)~=2
            New_posin = [75,75];
        end
        New_pos1_h = str2num(gui_property_waveviewer.parameters_pos_height.String);
        if isempty(New_pos1_h) || numel(New_pos1_h)~=1 || any(New_pos1_h<=0)
            gui_property_waveviewer.parameters_pos_height.String = num2str(New_posin(2));
            MessageViewer= char(strcat('Viewer Properties > Window size > height: The height value is invalid and it must be a positive value'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        New_pos1(2) = New_pos1_h;
        New_pos1_width = str2num(gui_property_waveviewer.parameters_pos_width.String);
        if isempty(New_pos1_width) || numel(New_pos1_width)~=1 || any(New_pos1_width<=0)
            gui_property_waveviewer.parameters_pos_width.String = num2str(New_posin(1));
            MessageViewer= char(strcat('Viewer Properties > Window size > height: The width value is invalid and it must be a positive value'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        New_pos1(1) = New_pos1_width;
        
        
        MessageViewer= char(strcat('Viewer Properties > Window size > height'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        try
            ScreenPos =  get( groot, 'Screensize' );
        catch
            ScreenPos =  get( 0, 'Screensize' );
        end
        
        New_posin(2) = abs(New_posin(2));
        
        New_pos = gui_erp_waviewer.Window.Position;
       
        erpworkingmemory('ERPWaviewerScreenPos',New_pos1);
        
        try
            POS4 = (New_pos1(2)-New_posin(2))/100;
            new_pos =[New_pos(1),New_pos(2)-ScreenPos(4)*POS4,ScreenPos(3)*New_pos1(1)/100,ScreenPos(4)*New_pos1(2)/100];
            if new_pos(2)+new_pos(4)<ScreenPos(4)
                set(gui_erp_waviewer.Window, 'Position', new_pos);
            else%%exceed
                new_pos(2) = ScreenPos(4) - (new_pos(2)+new_pos(4));
                set(gui_erp_waviewer.Window, 'Position', new_pos);
            end
            
        catch
            erpworkingmemory('f_EEG_proces_messg',['The defined Window Size for Viewer is invalid and it must be two numbers']);
            viewer_ERPDAT.Process_messg =4;
            set(gui_erp_waviewer.Window, 'Position', [0 0 0.75*ScreenPos(3) 0.75*ScreenPos(4)]);
            erpworkingmemory('ERPWaviewerScreenPos',[75 75]);
        end
        gui_erp_waviewer.ERPwaviewer.FigOutpos = New_pos1;
        
        viewer_ERPDAT.Count_currentERP=1;
        viewer_ERPDAT.Process_messg =2;
    end


%%------------------------------reset--------------------------------------
    function Reset_Waviewer_panel_change(~,~)
        if viewer_ERPDAT.Reset_Waviewer_panel~=8
            return;
        end
        erpworkingmemory('ERPWaviewerScreenPos',[75 75]);
        gui_erp_waviewer.ERPwaviewer.FigOutpos = [75 75];
        try
            ScreenPos =  get( groot, 'Screensize' );
        catch
            ScreenPos =  get( 0, 'Screensize' );
        end
        
        set(gui_erp_waviewer.Window, 'Position', [0 0 0.75*ScreenPos(3) 0.75*ScreenPos(4)]);
        erpworkingmemory('ERPWaviewerScreenPos',[75 75]);
        gui_property_waveviewer.parameters_pos.String = num2str([75 75]);
        
        %%name
        ViewerName = 'My Viewer';
        try
            [version1 reldate] = geterplabstudioversion;
            erplabstudiover = version1;
        catch
            erplabstudiover = '??';
        end
        currvers  = ['ERPLAB Studio ' erplabstudiover,'-',32,ViewerName];
        estudioworkingmemory('viewername',ViewerName);
        gui_erp_waviewer.ERPwaviewer.figname = ViewerName;
        gui_erp_waviewer.Window.Name = currvers;
    end

end