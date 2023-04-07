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
% addlistener(viewer_ERPDAT,'v_currentERP_change',@Count_currentERPChanged);
addlistener(viewer_ERPDAT,'count_loadproper_change',@count_loadproper_change);


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

%-----------------------------Draw the panel-------------------------------------
drawui_plot_property();
varargout{1} = box_erpwave_viewer_property;

    function drawui_plot_property()
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        gui_property_waveviewer.DataSelBox = uiextras.VBox('Parent', box_erpwave_viewer_property,'BackgroundColor',ColorBviewer_def);
        
        %%-----------------Setting for
        %%parameters---------------------------------------
        gui_property_waveviewer.parameters_title = uiextras.HBox('Parent', gui_property_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        
        uicontrol('Style','text','Parent', gui_property_waveviewer.parameters_title,'String','Parameters:',...
            'FontSize',12,'BackgroundColor',ColorBviewer_def); %1A
        gui_property_waveviewer.parameters_load = uicontrol('Style','pushbutton','Parent', gui_property_waveviewer.parameters_title,'String','Load',...
            'callback',@parameters_load,'FontSize',12,'BackgroundColor',[1 1 1]); %
        gui_property_waveviewer.parameters_save = uicontrol('Style','pushbutton','Parent', gui_property_waveviewer.parameters_title,'String','Save',...
            'callback',@parameters_save,'FontSize',12,'BackgroundColor',[1 1 1]); %
        gui_property_waveviewer.parameters_saveas = uicontrol('Style','pushbutton','Parent', gui_property_waveviewer.parameters_title,'String','Save as',...
            'callback',@parameters_saveas,'FontSize',12,'BackgroundColor',[1 1 1]); %
        set(gui_property_waveviewer.parameters_title, 'Sizes',[70 55 55 55]);
        
        %%-----------Setting for viewer title-----------------------------
        gui_property_waveviewer.viewer_TN_title = uiextras.HBox('Parent', gui_property_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_property_waveviewer.viewer_TN_title,'String','Title:',...
            'FontSize',12,'BackgroundColor',ColorBviewer_def); %1A
        ViewerName = estudioworkingmemory('viewername');
        if isempty(ViewerName)
            ViewerName = char('My Viewer');
        end
        gui_property_waveviewer.parameters_load = uicontrol('Style','edit','Parent',gui_property_waveviewer.viewer_TN_title,'String',ViewerName,...
            'callback',@viewer_TN,'FontSize',12,'BackgroundColor',[1 1 1]); %
        set(gui_property_waveviewer.viewer_TN_title, 'Sizes',[70 165]);
        set(gui_property_waveviewer.DataSelBox ,'Sizes',[30 25])
    end



%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%


%%-------------------------Setting for load--------------------------------
    function parameters_load(~,~)
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
        MessageViewer= char(strcat('Viewer Properties > Load'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        
        try
            ERPwaviewer = importdata([filepath,erpFilename]);
            
            if isempty(ERPwaviewer.ALLERP)
                BackERPLABcolor = [1 0.9 0.3];    % yellow
                question = ['Do you want to use the default "ALLERP"? \n Because there is no "ALLERP" in the file'];
                title = 'My Viewer>Viewer Properties';
                oldcolor = get(0,'DefaultUicontrolBackgroundColor');
                set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
                button = questdlg(sprintf(question), title,'Cancel','No', 'Yes','Yes');
                set(0,'DefaultUicontrolBackgroundColor',oldcolor);
                if strcmpi(button,'Yes')
                    ERPwaviewerdef  = evalin('base','ALLERPwaviewer');
                    ERPwaviewer.ALLERP= ERPwaviewerdef.ALLERP;
                    ERPwaviewer.ERP = ERPwaviewerdef.ERP;
                else
                    if strcmpi(button,'No')
                        beep;
                        viewer_ERPDAT.Process_messg =3;
                        fprintf(2,'\n\n My viewer > Viewer Propoerties > Load: \n Cannot use the file because no ALLERP can be used.\n\n');
                    else
                        beep
                        viewer_ERPDAT.Process_messg =3;
                        fprintf(2,'\n\n My viewer > Viewer Propoerties > Load: \n User selected cancel.\n\n');
                    end
                    return;
                end
            end
            
            assignin('base','ALLERPwaviewer',ERPwaviewer);
        catch
            beep;
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n\n My viewer > Viewer Propoerties > Load: \n Cannot load the saved parameters of My viewer.\n\n');
            return;
        end
        viewer_ERPDAT.count_loadproper = viewer_ERPDAT.count_loadproper+1;
        %         estudioworkingmemory('zoomSpace',1.5);
        f_redrawERP_viewer_test();
        viewer_ERPDAT.Process_messg =2;
    end

%%-------------------------Setting for Save--------------------------------
    function parameters_save(~,~)
        MessageViewer= char(strcat('Viewer Properties > Save'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        try
            ERPwaviewer  = evalin('base','ALLERPwaviewer');
        catch
            beep;
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n\n My viewer > Viewer Propoerties > Save: \n There is no "ALLERPwaviewer" on Workspace, Please run My Viewer again.\n\n');
            return;
        end
        pathstr = pwd;
        namedef ='Viewer';
        erpFilename = char(strcat(namedef,'.mat'));
        
        BackERPLABcolor = [1 0.9 0.3];    % yellow
        question = ['Do you want to include "ALLERP"?'];
        title = 'My Viewer>Viewer Properties';
        oldcolor = get(0,'DefaultUicontrolBackgroundColor');
        set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
        button = questdlg(sprintf(question), title,'Cancel','No', 'Yes','Yes');
        set(0,'DefaultUicontrolBackgroundColor',oldcolor);
        
        if strcmpi(button,'No') || strcmpi(button,'Yes')
            if strcmpi(button,'No')
                ERPwaviewer.ALLERP = [];
                ERPwaviewer.ERP = [];
            end
            try
                save([pathstr,filesep,erpFilename],'ERPwaviewer','-v7.3');
                viewer_ERPDAT.Process_messg =2;
            catch
                beep;
                viewer_ERPDAT.Process_messg =3;
                fprintf(2,'\n\n My viewer > Viewer Propoerties > Save as: \n Cannot save the parameters of My viewer.\n\n');
                return;
            end
        else
            beep;
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n\n My viewer > Viewer Propoerties > Save as: \n User selected cancel.\n\n');
            return;
        end
        
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
        
        try
            ERPwaviewer  = evalin('base','ALLERPwaviewer');
        catch
            beep;
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n\n My viewer > Viewer Propoerties > Save as: \n There is no "ALLERPwaviewer" on Workspace, Please run My Viewer again.\n\n');
            return;
        end
        
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
        
        
        BackERPLABcolor = [1 0.9 0.3];    % yellow
        question = ['Do you want to include "ALLERP"?'];
        title = 'My Viewer>Viewer Properties';
        oldcolor = get(0,'DefaultUicontrolBackgroundColor');
        set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
        button = questdlg(sprintf(question), title,'Cancel','No', 'Yes','Yes');
        set(0,'DefaultUicontrolBackgroundColor',oldcolor);
        
        if strcmpi(button,'No') || strcmpi(button,'Yes')
            if strcmpi(button,'No')
                ERPwaviewer.ALLERP = [];
                ERPwaviewer.ERP = [];
            end
            try
                save([erppathname,erpFilename],'ERPwaviewer','-v7.3');
                viewer_ERPDAT.Process_messg =2;
            catch
                beep;
                viewer_ERPDAT.Process_messg =3;
                fprintf(2,'\n\n My viewer > Viewer Propoerties > Save as: \n Cannot save the parameters of My viewer.\n\n');
                return;
            end
        else
            beep;
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n\n My viewer > Viewer Propoerties > Save as: \n User selected cancel.\n\n');
            return;
        end
        
    end

%%----------------Setting for location path-----------------------------
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
        try
            ERPwaviewer  = evalin('base','ALLERPwaviewer');
        catch
            beep;
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n\n My Viewer > Viewer Propoerties > Title: \n There is no "ALLERPwaviewer" on Workspace, Please run My Viewer again.\n\n');
            return;
        end
        ERPwaviewer.figname = ViewerName;
        assignin('base','ALLERPwaviewer',ERPwaviewer);
        gui_erp_waviewer.Window.Name = currvers;
        viewer_ERPDAT.Process_messg =2;
    end
end