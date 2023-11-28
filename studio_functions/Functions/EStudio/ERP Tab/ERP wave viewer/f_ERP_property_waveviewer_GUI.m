%%This function is to plot the panel for "Viewer properties".

% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022


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
% gui_erp_waviewer.Window.WindowButtonMotionFcn = {@ViewerPos};
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
        
        gui_property_waveviewer.viewer_pos_title = uiextras.HBox('Parent', gui_property_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_property_waveviewer.viewer_pos_title,'String','Position:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); %1A
        New_pos = gui_erp_waviewer.screen_pos;
        if isempty(New_pos)
            New_pos = [75,75];
            erpworkingmemory('ERPWaveScreenPos',New_pos);
        end
        
        New_pos1 = roundn(New_pos,-3);
        New_poStr = char([num2str(New_pos1(1)),32,num2str(New_pos1(2))]);
        
        gui_property_waveviewer.parameters_pos = uicontrol('Style','edit','Parent',gui_property_waveviewer.viewer_pos_title,'String',New_poStr,...
            'callback',@Viewerpos,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %
        set(gui_property_waveviewer.viewer_pos_title, 'Sizes',[70 165]);
        
        gui_property_waveviewer.viewer_pos_title1 = uiextras.HBox('Parent', gui_property_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_property_waveviewer.viewer_pos_title1,'String','',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); %1A
        uicontrol('Style','text','Parent',gui_property_waveviewer.viewer_pos_title1,'String','(width, height) in %',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def); %
        set(gui_property_waveviewer.viewer_pos_title1, 'Sizes',[68 165]);
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
        if indxs==1
            ext = '.mat';
        elseif indxs==2
            ext = '.mat';
        else
            ext = '.mat';
        end
        erpFilename = char(strcat(erpfilename,ext));
        
        try
            gui_erp_waviewer.ERPwaviewer = importdata([filepath,erpFilename]);
            gui_erp_waviewer.ERPwaviewer.ALLERP= ALLERP;
            gui_erp_waviewer.ERPwaviewer.ERP = ALLERP(end);
            gui_erp_waviewer.ERPwaviewer.CURRENTERP = length(ALLERP);
            gui_erp_waviewer.ERPwaviewer.SelectERPIdx = length(ALLERP);
            gui_erp_waviewer.ERPwaviewer.PageIndex = 1;
        catch
            beep;
            MessageViewer=['\n\n My viewer > Viewer Propoerties > Load: Cannot load the saved parameters of My viewer '];
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =4;
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
        namedef ='Viewer';
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
            beep;
            MessageViewer= char(strcat('Viewer Propoerties > Save: \n Cannot save the parameters of My viewer'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =3;
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
        namedef ='Viewer';
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
        
        %         [pathx, filename, ext] = fileparts(erpfilename);
        [pathstr, erpfilename, ext] = fileparts(erpfilename) ;
        if indxs==1
            ext = '.mat';
        elseif indxs==2
            ext = '.mat';
        else
            ext = '.mat';
        end
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
            beep;
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n\n My viewer > Viewer Propoerties > Save as: \n Cannot save the parameters of My viewer.\n\n');
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

%%--------------------change gui width and heigth--------------------------
    function Viewerpos(Str,~)
        New_pos1 = str2num(Str.String);
        MessageViewer= char(strcat('Viewer Properties > Position'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        try
            ScreenPos =  get( groot, 'Screensize' );
        catch
            ScreenPos =  get( 0, 'Screensize' );
        end
        try
            New_posin = erpworkingmemory('EStudioScreenPos');
        catch
            New_posin = [75,75];
        end
        if isempty(New_posin) ||numel(New_posin)~=2
            New_posin = [75,75];
        end
        New_posin(2) = abs(New_posin(2));
        
        New_pos = gui_erp_waviewer.Window.Position;
        if isempty(New_pos1) || numel(New_pos1)~=2
            MessageViewer= char(strcat('Viewer Properties > Position- 2 numbers are needed for Viewer position (e.g., [1 1 1200 700])'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =4;
            
            new_pos =[ScreenPos(3)*New_pos(3)/100,ScreenPos(4)*New_pos(4)/100];
            gui_property_waveviewer.parameters_pos.String = num2str(new_pos);
            return;
        end
        erpworkingmemory('ERPWaviewerScreenPos',New_pos1);
        
        %        gui_erp_waviewer.screen_pos = New_pos;
        try
            POS4 = (New_pos1(2)-New_posin(2))/100;
            new_pos =[New_pos(1),New_pos(2)-ScreenPos(4)*POS4,ScreenPos(3)*New_pos1(1)/100,ScreenPos(4)*New_pos1(2)/100];
            set(gui_erp_waviewer.Window, 'Position', new_pos);
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