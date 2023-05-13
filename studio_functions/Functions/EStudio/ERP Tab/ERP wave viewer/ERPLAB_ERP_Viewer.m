
% New ERP viewer GUI Layout - Simple ERP viewer 0.014
%
% Author: Guanghui Zhang & Steve J. Luck & Andrew Stewart
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022

% ERPLAB Studio Toolbox
%

%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% Reqs:
% - data loaded in valid ERPset
% - GUI Layout Toolbox
% - EEGLAB and ERPLAB


%
% Demo to explore an ERP Viewer using the new GUI Layout Toolbox
% Now with more in nested functions

function  ERPLAB_ERP_Viewer(ALLERP,selectedERP_index,binArray,chanArray,Parameterfile)

global viewer_ERPDAT;
global gui_erp_waviewer;
ERPtooltype = erpgettoolversion('tooltype');
% global observe_ERPDAT;
% if ~strcmpi(ERPtooltype,'EStudio')
viewer_ERPDAT = v_ERPDAT;
% end
% addlistener(observe_ERPDAT,'erpschange',@allErpChanged);
if ~strcmpi(ERPtooltype,'EStudio') &&  ~strcmpi(ERPtooltype,'ERPLAB')
    global observe_ERPDAT;
    observe_ERPDAT = o_ERPDAT;
    observe_ERPDAT.Two_GUI = 0;
    observe_ERPDAT.ALLERP = [];
    observe_ERPDAT.CURRENTERP = [];
    observe_ERPDAT.ERP = [];
    observe_ERPDAT.Count_ERP = 0;
    observe_ERPDAT.Count_currentERP = 0;
    observe_ERPDAT.Process_messg = 0;
end
try
    close(EStudio_gui_erp_totl.Window);
catch
end

if nargin<1
    beep;
    disp('ERP_wave_viewer() error: ALLERP should be imported.');
    return;
end

if isempty(ALLERP)
    beep;
    disp('ERP_wave_viewer() error: The imported ALLERP is empty.');
    return;
end

%%checking datatype
counterp = 0;
datatypeFlag = [];
for Numoferpset = 1:length(ALLERP)
    if ~strcmpi(ALLERP(Numoferpset).datatype, 'ERP') && ~strcmpi(ALLERP(Numoferpset).datatype, 'CSD')
        counterp =   counterp+1;
        datatypeFlag(counterp) = Numoferpset;
    end
end
if ~isempty(datatypeFlag)
    msgboxText =  ['ERP Wave Viewer donot support to plot the wave for the data that donot belong to "ERP" or "CSD".\n'...
        'Please remove the following ERPset with index(es):',32,num2str(datatypeFlag),'.'];
    if strcmpi(ERPtooltype,'ERPLAB')
        title_msg = 'ERPLAB: ERPLAB_ERP_Viewer() datatype error:';
    elseif strcmpi(ERPtooltype,'EStudio')
        title_msg = 'EStudio: ERPLAB_ERP_Viewer() datatype error:';
    else
        title_msg = ' ERPLAB_ERP_Viewer() datatype error:';
    end
    errorfound(sprintf(msgboxText), title_msg);
    return;
end



if nargin<2
    selectedERP_index = length(ALLERP);
    try
        binArray = [1:ALLERP(selectedERP_index).nbin];
        chanArray =[1:ALLERP(selectedERP_index).nchan];
    catch
        binArray = [1:ALLERP(end).nbin];
        chanArray =[1:ALLERP(end).nchan];
    end
    Parameterfile = [];
end
if isempty(selectedERP_index) || min(selectedERP_index)<=0 || max(selectedERP_index)>length(ALLERP)
    selectedERP_index = length(ALLERP);
end

if nargin<3
    try
        binArray = [1:ALLERP(selectedERP_index).nbin];
        chanArray =[1:ALLERP(selectedERP_index).nchan];
    catch
        binArray = [1:ALLERP(end).nbin];
        chanArray =[1:ALLERP(end).nchan];
    end
    Parameterfile = [];
end

if nargin<4
    try
        chanArray =[1:ALLERP(selectedERP_index).nchan];
    catch
        
        chanArray =[1:ALLERP(end).nchan];
    end
    Parameterfile = [];
end
if nargin<5
    Parameterfile = [];
end
if nargin>6
    help ERP_wave_viewer;
    return;
end


% if ~strcmpi(ERPtooltype,'EStudio')
%     addlistener(viewer_ERPDAT,'count_loadproper_change',@count_loadproper_change);
%     addlistener(viewer_ERPDAT,'v_currentERP_change',@v_currentERP_change);
%     addlistener(viewer_ERPDAT,'v_messg_change',@V_messg_change);
%     addlistener(viewer_ERPDAT,'count_legend_change',@count_legend_change);
%     addlistener(viewer_ERPDAT,'page_xyaxis_change',@page_xyaxis_change);
% % end


viewer_ERPDAT.Count_currentERP = 0;
% viewer_ERPDAT.Process_messg = 0;%0 is the default means there is no message for processing procedure;
%1 means the processign procedure is running
%2 means the processign procedure is done
%3 means there are some errors for processing procedure
viewer_ERPDAT.count_legend=0;%% this is to capture the changes of legend name
viewer_ERPDAT.page_xyaxis=0;%%get the changes of x/y axis based on the changed pages or selected ERPsets
viewer_ERPDAT.count_loadproper = 0;
viewer_ERPDAT.Process_messg = 0;
viewer_ERPDAT.count_twopanels = 0;%% Automaticlly saving the changes on the other panel if the current panel is changed
viewer_ERPDAT.Reset_Waviewer_panel = 0;

viewer_ERPDAT.ALLERP = ALLERP;
viewer_ERPDAT.ERP_bin =  binArray;
viewer_ERPDAT.ERP_chan =  chanArray;
%
% Count_ERP = 1;
% Count_currentERP =0;
% Sanity checks
try
    test = uix.HBoxFlex();
catch
    beep;
    disp('The GUI Layout Toolbox might not be installed. Quitting')
    return
end

%%Setting the flags for all panels that are used to get the changes from
%%each panel
estudioworkingmemory('MyViewer_ERPsetpanel',0);
estudioworkingmemory('MyViewer_chanbin',0);
estudioworkingmemory('MyViewer_xyaxis',0);
estudioworkingmemory('MyViewer_plotorg',0);
estudioworkingmemory('MyViewer_labels',0);
estudioworkingmemory('MyViewer_linelegend',0);
estudioworkingmemory('MyViewer_other',0);

ERPwaviewer.ALLERP =ALLERP;
ERPwaviewer.ERP = ALLERP(1);
ERPwaviewer.CURRENTERP =selectedERP_index(1);
ERPwaviewer.SelectERPIdx =selectedERP_index;
ERPwaviewer.bin = binArray;
ERPwaviewer.chan = chanArray;
ERPwaviewer.erp_binchan_op = 1;%% 1. Auto; 2.Custom
ERPwaviewer.binchan_op = 1;%% 1. Auto; 2.Custom

ERPwaviewer.plot_org.Grid = 1; %1.Channels; 2.Bins; 3. ERPsets; 4. None
ERPwaviewer.plot_org.Overlay = 2; %1.Channels; 2.Bins; 3. ERPsets; 4. None
ERPwaviewer.plot_org.Pages = 3; %1.Channels; 2.Bins; 3. ERPsets; 4. None
ERPwaviewer.plot_org.gridlayout.op = 1; %1.Auto; 2. Custom
ERPwaviewer.plot_org.gridlayout.data = [];
ERPwaviewer.Lines = [];
ERPwaviewer.Legend = [];
ERPwaviewer.xaxis = [];
ERPwaviewer.yaxis = [];
ERPwaviewer.polarity = [];
ERPwaviewer.SEM = [];
ERPwaviewer.PageIndex = 1;
ERPwaviewer.baselinecorr = 'none';
ERPwaviewer.chanbinsetlabel = [];
ERPwaviewer.figbackgdcolor = [];
ERPwaviewer.figname = 'My Viewer';
assignin('base','ALLERPwaviewer',ERPwaviewer);

estudioworkingmemory('zoomSpace',0);%%sett for zoom in and zoom out
try
    close(gui_erp_waviewer.Window);%%close previous GUI if exists
catch
end

gui_erp_waviewer = struct();

gui_erp_waviewer = createInterface();

f_redrawERP_viewer_test();
if ~isempty( Parameterfile)%% update the panels based on the saved file
    
    if isempty(Parameterfile.ALLERP)
        BackERPLABcolor = [1 0.9 0.3];    % yellow
        question = ['Do you want to use the default "ALLERP"? \n Because there is no "ALLERP" in the "Parameterfile"'];
        title = 'My Viewer>ERPLAB_ERP_Viewer';
        oldcolor = get(0,'DefaultUicontrolBackgroundColor');
        set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
        button = questdlg(sprintf(question), title,'Cancel','No', 'Yes','Yes');
        set(0,'DefaultUicontrolBackgroundColor',oldcolor);
        
        if strcmpi(button,'Yes')
            ERPwaviewerdef  = evalin('base','ALLERPwaviewer');
            Parameterfile.ALLERP= ERPwaviewerdef.ALLERP;
            Parameterfile.ERP = ERPwaviewerdef.ERP;
        else
            if strcmpi(button,'No')
                beep;
                viewer_ERPDAT.Process_messg =3;
                fprintf(2,'\n\n My viewer > ERPLAB_ERP_Viewer: \n Cannot use the file because no ALLERP can be used.\n\n');
            else
                beep
                viewer_ERPDAT.Process_messg =3;
                fprintf(2,'\n\n My viewer > ERPLAB_ERP_Viewer: \n User selected cancel.\n\n');
            end
            return;
        end
    end
    assignin('base','ALLERPwaviewer',Parameterfile);
    viewer_ERPDAT.count_loadproper = viewer_ERPDAT.count_loadproper+1;
    f_redrawERP_viewer_test();
end

    function gui_erp_waviewer = createInterface();
        ERPtooltype = erpgettoolversion('tooltype');
        
        if strcmpi(ERPtooltype,'EStudio')
            try
                [version reldate] = geterplabstudioversion;
                erplabstudiover = version;
            catch
                erplabstudiover = '??';
            end
            
            currvers  = ['ERPLAB Studio ' erplabstudiover,'- My Viewer'];
        else
            try
                [version reldate] = geterplabversion;
                erplabstudiover = version;
            catch
                erplabstudiover = '??';
            end
            
            currvers  = ['ERPLAB ' erplabstudiover,'- My Viewer'];
        end
        estudioworkingmemory('viewername','My Viewer');
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
        catch
            ColorBviewer_def = [0.7765,0.7294,0.8627];
        end
        %         gui_erp_waviewer = struct();
        % First, let's start the window
        gui_erp_waviewer.Window = figure( 'Name', currvers, ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'HandleVisibility', 'off', 'tag', 'rollover');
        
        
        new_pos = [1 1 1000 1000];
        set(gui_erp_waviewer.Window, 'Position', new_pos);
        
        % + View menu
        gui_erp_waviewer.exit = uimenu( gui_erp_waviewer.Window, 'Label','Exit', 'Callback', @onExit);
        
        gui_erp_waviewer.help = uimenu( gui_erp_waviewer.Window, 'Label', 'Help', 'Callback', @onhelp);
        
        %%-----------Setting------------------------------------------------
        %% Create tabs
        context_tabs =  uix.VBox('Parent', gui_erp_waviewer.Window);
        gui_erp_waviewer.tabERP = uix.HBoxFlex( 'Parent', context_tabs, 'Spacing', 10,'BackgroundColor',ColorBviewer_def);
        %% Arrange the main interface for ERP panel (Tab3)
        gui_erp_waviewer.ViewBox = uix.VBox('Parent', gui_erp_waviewer.tabERP,'BackgroundColor',ColorBviewer_def);
        
        
        gui_erp_waviewer.ViewPanel = uix.BoxPanel('Parent', gui_erp_waviewer.ViewBox,'TitleColor',ColorBviewer_def,'ForegroundColor','k');%
        gui_erp_waviewer.ViewContainer = uicontainer('Parent', gui_erp_waviewer.ViewPanel);
        
        gui_erp_waviewer.panelscroll = uix.ScrollingPanel('Parent', gui_erp_waviewer.tabERP);
        set(gui_erp_waviewer.panelscroll,'BackgroundColor',ColorBviewer_def);
        % + Adjust the main layout
        set( gui_erp_waviewer.tabERP, 'Widths', [-4, 270]); % Viewpanel and settings panel
        
        
        gui_erp_waviewer.panel_fonts = 12;
        gui_erp_waviewer.settingLayout = uiextras.VBox('Parent', gui_erp_waviewer.panelscroll,'BackgroundColor',ColorBviewer_def);
        
        % + Create the settings window panels for ERP panel
        gui_erp_waviewer.panel{1} = f_ERPsets_waviewer_GUI(gui_erp_waviewer.settingLayout,gui_erp_waviewer.panel_fonts);
        gui_erp_waviewer.panelSizes(1) = 280;
        
        gui_erp_waviewer.panel{2} = f_ERP_Binchan_waviewer_GUI(gui_erp_waviewer.settingLayout,gui_erp_waviewer.panel_fonts);
        gui_erp_waviewer.panelSizes(2) = 280;
        
        gui_erp_waviewer.panel{3} = f_ERP_timeampscal_waveviewer_GUI(gui_erp_waviewer.settingLayout,gui_erp_waviewer.panel_fonts);
        gui_erp_waviewer.panelSizes(3) = 490;
        
        gui_erp_waviewer.panel{4} = f_ERP_plotorg_waveviewer_GUI(gui_erp_waviewer.settingLayout,gui_erp_waviewer.panel_fonts);
        gui_erp_waviewer.panelSizes(4) = 405;
        
        gui_erp_waviewer.panel{5} = f_ERP_labelset_waveviewer_GUI(gui_erp_waviewer.settingLayout,gui_erp_waviewer.panel_fonts);
        gui_erp_waviewer.panelSizes(5) = 200;
        
        gui_erp_waviewer.panel{6} = f_ERP_lineset_waveviewer_GUI(gui_erp_waviewer.settingLayout,gui_erp_waviewer.panel_fonts);
        gui_erp_waviewer.panelSizes(6) = 555;
        
        gui_erp_waviewer.panel{7} = f_ERP_otherset_waveviewer_GUI(gui_erp_waviewer.settingLayout,gui_erp_waviewer.panel_fonts);
        gui_erp_waviewer.panelSizes(7) = 225;
        
        gui_erp_waviewer.panel{8} = f_ERP_property_waveviewer_GUI(gui_erp_waviewer.settingLayout,gui_erp_waviewer.panel_fonts);
        gui_erp_waviewer.panelSizes(8) = 90;
        
        set(gui_erp_waviewer.settingLayout, 'Heights', gui_erp_waviewer.panelSizes);
        gui_erp_waviewer.panelscroll.Heights = sum(gui_erp_waviewer.panelSizes);
        
        %% Hook up the minimize callback and IsMinimized
        set( gui_erp_waviewer.panel{1}, 'MinimizeFcn', {@nMinimize, 1} );
        set( gui_erp_waviewer.panel{2}, 'MinimizeFcn', {@nMinimize, 2});
        set( gui_erp_waviewer.panel{3}, 'MinimizeFcn', {@nMinimize, 3});
        set( gui_erp_waviewer.panel{4}, 'MinimizeFcn', {@nMinimize, 4});
        set( gui_erp_waviewer.panel{5}, 'MinimizeFcn', {@nMinimize, 5});
        set( gui_erp_waviewer.panel{6}, 'MinimizeFcn', {@nMinimize, 6});
        set( gui_erp_waviewer.panel{7}, 'MinimizeFcn', {@nMinimize, 7});
        set( gui_erp_waviewer.panel{8}, 'MinimizeFcn', {@nMinimize, 8});
        whichpanel = [4:8];
        for Numofpanel = 1:length(whichpanel)
            minned = gui_erp_waviewer.panel{whichpanel(Numofpanel)}.IsMinimized;
            szs = get( gui_erp_waviewer.settingLayout, 'Sizes' );
            if minned
                set( gui_erp_waviewer.panel{whichpanel(Numofpanel)}, 'IsMinimized', false);
                szs(whichpanel(Numofpanel)) = gui_erp_waviewer.panelSizes(whichpanel(Numofpanel));
            else
                set( gui_erp_waviewer.panel{whichpanel(Numofpanel)}, 'IsMinimized', true);
                szs(whichpanel(Numofpanel)) = 25;
            end
            set( gui_erp_waviewer.settingLayout, 'Sizes', szs );
            gui_erp_waviewer.panelscroll.Heights = sum(szs);
        end
        %% + Create the view
        p = gui_erp_waviewer.ViewContainer;
        gui_erp_waviewer.ViewAxes = uiextras.HBox( 'Parent', p,'BackgroundColor',ColorBviewer_def);
        
    end % createInterface


    function nMinimize( eventSource, eventData, whichpanel) %#ok<INUSL>
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
        catch
            ColorBviewer_def = [0.7020 0.77 0.85];
        end
        minned = gui_erp_waviewer.panel{whichpanel}.IsMinimized;
        szs = get( gui_erp_waviewer.settingLayout, 'Sizes' );
        if minned
            set( gui_erp_waviewer.panel{whichpanel}, 'IsMinimized', false);
            szs(whichpanel) = gui_erp_waviewer.panelSizes(whichpanel);
        else
            set( gui_erp_waviewer.panel{whichpanel}, 'IsMinimized', true);
            szs(whichpanel) = 25;
        end
        set( gui_erp_waviewer.settingLayout, 'Sizes', szs ,'BackgroundColor',ColorBviewer_def);
        gui_erp_waviewer.panelscroll.Heights = sum(szs);
        set(gui_erp_waviewer.panelscroll,'BackgroundColor',ColorBviewer_def);
    end % nMinimize


%%--------------------Function is to close the toolbox---------------------
    function onExit(~,~)
        BackERPLABcolor1 = [1 0.9 0.3];    % yellow
        question1 = ['Are you sure to quit "ERP wave viewer"?'];
        title1 = 'My Viewer>Exit';
        oldcolor1 = get(0,'DefaultUicontrolBackgroundColor');
        set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor1)
        button1 = questdlg(sprintf(question1), title1,'Cancel','No', 'Yes','Yes');
        set(0,'DefaultUicontrolBackgroundColor',oldcolor1);
        if strcmpi(button1,'Yes')
            try
                close(gui_erp_waviewer.Window);
                clear ALLERPwaviewer;
            catch
                return;
            end
        else
            return;
        end
    end

%%-------------Help for my Viewer------------------------------------------
    function onhelp(~,~)
        
        
    end

%%%%%%%%%%%%%%%%%%%%%%%
end % end of the function