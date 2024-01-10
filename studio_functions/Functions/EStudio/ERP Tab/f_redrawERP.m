%This function is to plot ERP waves with single or multiple columns on one page.



% Author: Guanghui Zhang & Steve J. Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022 & Oct-Nov 2023



function f_redrawERP()
% Draw a demo ERP into the axes provided
global observe_ERPDAT;
global EStudio_gui_erp_totl;
% addlistener(observe_ERPDAT,'Messg_change',@Count_Process_messg_change);
FonsizeDefault = f_get_default_fontsize();
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;%%Get background color
catch
    ColorB_def = [0.95 0.95 0.95];
end
if isempty(ColorB_def)
    ColorB_def = [0.95 0.95 0.95];
end
% We first clear the existing axes ready to build a new one
if ishandle( EStudio_gui_erp_totl.ViewAxes )
    delete( EStudio_gui_erp_totl.ViewAxes );
end
%Sets the units of your root object (screen) to pixels
set(0,'units','pixels')
%Obtains this pixel information
Pix_SS = get(0,'screensize');
%Sets the units of your root object (screen) to inches
set(0,'units','inches')
%Obtains this inch information
Inch_SS = get(0,'screensize');
%Calculates the resolution (pixels per inch)
Resolation = Pix_SS./Inch_SS;
ERPArray= estudioworkingmemory('selectederpstudio');
if ~isempty(observe_ERPDAT.ALLERP)  && ~isempty(observe_ERPDAT.ERP)
    if isempty(ERPArray) ||any(ERPArray(:) > length(observe_ERPDAT.ALLERP)) || any(ERPArray(:)<=0)
        ERPArray =  length(observe_ERPDAT.ALLERP) ;
        estudioworkingmemory('selectederpstudio',ERPArray);
        observe_ERPDAT.CURRENTERP = ERPArray;
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(ERPArray);
        assignin('base','ERP',observe_ERPDAT.ERP);
        assignin('base','ALLERP', observe_ERPDAT.ALLERP);
        assignin('base','CURRENTERP', observe_ERPDAT.CURRENTERP);
    end
    [xpos,ypos] = find(ERPArray==observe_ERPDAT.CURRENTERP);
    if ~isempty(ypos)
        pagecurrentNum = ypos;
        pageNum = numel(ERPArray);
        PageStr = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP).erpname;
    else
        pageNum=1;
        pagecurrentNum=1;
        PageStr = observe_EEGDAT.EEG.setname;
    end
    Enableflag = 'on';
else
    pageNum=1;
    pagecurrentNum=1;
    PageStr = 'No ERPset was loaded';
    ERPArray= 1;
    estudioworkingmemory('selectederpstudio',1);
    Enableflag = 'off';
end
EStudio_gui_erp_totl.plotgrid = uix.VBox('Parent',EStudio_gui_erp_totl.ViewContainer,'Padding',0,'Spacing',0,'BackgroundColor',ColorB_def);

%%Setting title
pageinfo_box = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plotgrid,'BackgroundColor',ColorB_def);
pageinfo_str = ['Page',32,num2str(pagecurrentNum),'/',num2str(pageNum),':',32,PageStr];
EStudio_gui_erp_totl.pageinfo_text = uicontrol('Parent',pageinfo_box,'Style','text','String',pageinfo_str,'FontSize',FonsizeDefault);
EStudio_gui_erp_totl.pageinfo_minus = uicontrol('Parent',pageinfo_box,'Style', 'pushbutton', 'String', 'Prev.','Callback',{@page_minus,EStudio_gui_erp_totl},'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
EStudio_gui_erp_totl.pageinfo_edit = uicontrol('Parent',pageinfo_box,'Style', 'edit', 'String', num2str(pagecurrentNum),'Callback',{@page_edit,EStudio_gui_erp_totl},'FontSize',FonsizeDefault+2,'BackgroundColor',[1 1 1]);
EStudio_gui_erp_totl.pageinfo_plus = uicontrol('Parent',pageinfo_box,'Style', 'pushbutton', 'String', 'Next','Callback',{@page_plus,EStudio_gui_erp_totl},'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
set(pageinfo_box, 'Sizes', [-1 70 50 70] );
set(pageinfo_box,'BackgroundColor',ColorB_def);


%%legends
ViewAxes_legend_title = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plotgrid,'BackgroundColor',[1 1 1]);
EStudio_gui_erp_totl.ViewAxes_legend = uix.ScrollingPanel( 'Parent', ViewAxes_legend_title,'BackgroundColor',[1 1 1]);
%%waves
EStudio_gui_erp_totl.plot_wav_legend = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plotgrid,'BackgroundColor',[1 1 1]);
EStudio_gui_erp_totl.ViewAxes = uix.ScrollingPanel( 'Parent', EStudio_gui_erp_totl.plot_wav_legend,'BackgroundColor',[1 1 1]);

%%save figure, command....
commandfig_panel = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plotgrid,'BackgroundColor',ColorB_def);%%%Message
EStudio_gui_erp_totl.advanced_viewer = uicontrol('Parent',commandfig_panel,'Style','pushbutton','String','Advanced Wave Viewer',...
    'Callback',@Advanced_viewer,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable',Enableflag);
uiextras.Empty('Parent', commandfig_panel); % 1A
EStudio_gui_erp_totl.erp_winsize = uicontrol('Parent',commandfig_panel,'Style','pushbutton','String','Window Size',...
    'Callback',@EStudiowinsize, 'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable',Enableflag);
EStudio_gui_erp_totl.erp_figurecommand = uicontrol('Parent',commandfig_panel,'Style','pushbutton','String','Show Command',...
    'Callback',@Show_command, 'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable',Enableflag);
EStudio_gui_erp_totl.erp_figuresaveas = uicontrol('Parent',commandfig_panel,'Style','pushbutton','String','Save Figure as',...
    'Callback',@figure_saveas, 'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable',Enableflag);
EStudio_gui_erp_totl.erp_figureout = uicontrol('Parent',commandfig_panel,'Style','pushbutton','String','Create Static/Exportable Plot',...
    'Callback', @figure_out,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable',Enableflag);
uiextras.Empty('Parent', commandfig_panel); % 1A
set(commandfig_panel, 'Sizes', [150 -1 100 100 100 170 5]);

%%message
xaxis_panel = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plotgrid,'BackgroundColor',ColorB_def);%%%Message
EStudio_gui_erp_totl.Process_messg = uicontrol('Parent',xaxis_panel,'Style','text','String','','FontSize',FonsizeDefault,'FontWeight','bold','BackgroundColor',ColorB_def);

if length(ERPArray) ==1
    Enable_minus = 'off';
    Enable_plus = 'off';
    Enable_plus_BackgroundColor = [1 1 1];
    Enable_minus_BackgroundColor = [0 0 0];
else
    if pagecurrentNum ==1
        Enable_minus = 'off';
        Enable_plus = 'on';
        Enable_plus_BackgroundColor = [0 1 0];
        Enable_minus_BackgroundColor = [0 0 0];
    elseif  pagecurrentNum == length(ERPArray)
        Enable_minus = 'on';
        Enable_plus = 'off';
        Enable_plus_BackgroundColor = [0 0 0];
        Enable_minus_BackgroundColor = [0 1 0];
    else
        Enable_minus = 'on';
        Enable_plus = 'on';
        Enable_plus_BackgroundColor = [0 1 0];
        Enable_minus_BackgroundColor = [0 1 0];
    end
end
EStudio_gui_erp_totl.pageinfo_minus.Enable = Enable_minus;
EStudio_gui_erp_totl.pageinfo_plus.Enable = Enable_plus;
EStudio_gui_erp_totl.pageinfo_plus.ForegroundColor = Enable_plus_BackgroundColor;
EStudio_gui_erp_totl.pageinfo_minus.ForegroundColor = Enable_minus_BackgroundColor;
set(EStudio_gui_erp_totl.pageinfo_text,'BackgroundColor',ColorB_def);
if isempty(observe_ERPDAT.ALLERP)  ||  isempty(observe_ERPDAT.ERP)
    EStudio_gui_erp_totl.erptabwaveiwer = axes('Parent', EStudio_gui_erp_totl.ViewAxes,'Color','none','Box','on','FontWeight','normal');
    set(EStudio_gui_erp_totl.erptabwaveiwer, 'XTick', [], 'YTick', [],'Box','off', 'Color','none','xcolor','none','ycolor','none');
end

if ~isempty(observe_ERPDAT.ALLERP) && ~isempty(observe_ERPDAT.ERP)
    EStudio_gui_erp_totl.erptabwaveiwer = axes('Parent', EStudio_gui_erp_totl.ViewAxes,'Color','none','Box','on','FontWeight','normal');
    hold(EStudio_gui_erp_totl.erptabwaveiwer,'on');
    EStudio_gui_erp_totl.erptabwaveiwer_legend = axes('Parent', EStudio_gui_erp_totl.ViewAxes_legend,'Color','none','Box','off');
    hold(EStudio_gui_erp_totl.erptabwaveiwer_legend,'on');
    set(EStudio_gui_erp_totl.erptabwaveiwer_legend, 'XTick', [], 'YTick', []);
    ERP = observe_ERPDAT.ERP;
    OutputViewerparerp = f_preparms_erptab(ERP,0);
    
    % %%Plot the eeg waves
    if ~isempty(OutputViewerparerp)
        f_plotaberpwave(ERP,OutputViewerparerp{1},OutputViewerparerp{2},...
            OutputViewerparerp{3},OutputViewerparerp{4},OutputViewerparerp{5},...
            OutputViewerparerp{6},OutputViewerparerp{9},OutputViewerparerp{10},OutputViewerparerp{11},...
            OutputViewerparerp{12},OutputViewerparerp{13},...
            EStudio_gui_erp_totl.erptabwaveiwer,EStudio_gui_erp_totl.erptabwaveiwer_legend);
    else
        return;
    end
    pb_height =  OutputViewerparerp{7}*Resolation(4);  %px
    Fillscreen = OutputViewerparerp{8};
    if isempty(Fillscreen) || numel(Fillscreen)~=1 || (Fillscreen~=0 && Fillscreen~=1)
        Fillscreen=1;
    end
    BinchanOverlay = OutputViewerparerp{11};
    if isempty(BinchanOverlay) || numel(BinchanOverlay)~=1   || (BinchanOverlay~=0 && BinchanOverlay~=1 )
        BinchanOverlay=0;
    end
    if BinchanOverlay == 0
        splot_n = numel(OutputViewerparerp{1});
    else
        splot_n = numel(OutputViewerparerp{2});
    end
    EStudio_gui_erp_totl.plotgrid.Heights(1) = 30;
    EStudio_gui_erp_totl.plotgrid.Heights(2) = 70;% set the first element (pageinfo) to 30px high
    EStudio_gui_erp_totl.plotgrid.Heights(4) = 30;
    EStudio_gui_erp_totl.plotgrid.Heights(5) = 30;% set the second element (x axis) to 30px high
    EStudio_gui_erp_totl.plotgrid.Units = 'normalized';
    if splot_n*pb_height<(EStudio_gui_erp_totl.plotgrid.Position(4)-EStudio_gui_erp_totl.plotgrid.Heights(1))&&Fillscreen
        pb_height = 0.9*(EStudio_gui_erp_totl.plotgrid.Position(4)-EStudio_gui_erp_totl.plotgrid.Heights(1)-EStudio_gui_erp_totl.plotgrid.Heights(2))/splot_n;
    end
    %         EStudio_gui_erp_totl.ViewAxes.Heights = splot_n*pb_height;
    EStudio_gui_erp_totl.ViewAxes.Heights = 0.95*EStudio_gui_erp_totl.ViewAxes.Position(4);
    EStudio_gui_erp_totl.plotgrid.Units = 'pixels';
end
EStudio_gui_erp_totl.plotgrid.Heights(1) = 30;
EStudio_gui_erp_totl.plotgrid.Heights(2) = 70;% set the first element (pageinfo) to 30px high
EStudio_gui_erp_totl.plotgrid.Heights(4) = 30;
EStudio_gui_erp_totl.plotgrid.Heights(5) = 30;% set the second element (x axis) to 30px high
end

%%-------------------------------------------------------------------------
%%-----------------------------Subfunctions--------------------------------
%%-------------------------------------------------------------------------

%%--------------------Setting for EStudio window size----------------------
function EStudiowinsize(~,~)
global EStudio_gui_erp_totl;
global observe_ERPDAT;

try
    ScreenPos= EStudio_gui_erp_totl.ScreenPos;
catch
    ScreenPos =  get( 0, 'Screensize' );
end
try
    New_pos = EStudio_gui_erp_totl.Window.Position;
catch
    return;
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

app = feval('EStudio_pos_gui',New_posin);
waitfor(app,'Finishbutton',1);
try
    New_pos1 = app.output; %NO you don't want to output EEG with edited channel locations, you want to output the parameters to run decoding
    app.delete; %delete app from view
    pause(0.5); %wait for app to leave
catch
    disp('User selected Cancel');
    return;
end
try New_pos1(2) = abs(New_pos1(2));catch; end;

if isempty(New_pos1) || numel(New_pos1)~=2
    erpworkingmemory('f_ERP_proces_messg',['The defined Window Size for EStudio is invalid and it must be two numbers']);
    observe_ERPDAT.Process_messg =4;
    return;
end
erpworkingmemory('EStudioScreenPos',New_pos1);
try
    POS4 = (New_pos1(2)-New_posin(2))/100;
    new_pos =[New_pos(1),New_pos(2)-ScreenPos(4)*POS4,ScreenPos(3)*New_pos1(1)/100,ScreenPos(4)*New_pos1(2)/100];
    if new_pos(2) <  -abs(new_pos(4))%%if
        
    end
    set(EStudio_gui_erp_totl.Window, 'Position', new_pos);
catch
    erpworkingmemory('f_ERP_proces_messg',['The defined Window Size for EStudio is invalid and it must be two numbers']);
    observe_ERPDAT.Process_messg =4;
    set(EStudio_gui_erp_totl.Window, 'Position', [0 0 0.75*ScreenPos(3) 0.75*ScreenPos(4)]);
    erpworkingmemory('EStudioScreenPos',[75 75]);
end
f_redrawEEG_Wave_Viewer();
f_redrawERP();
%         EStudio_gui_erp_totl.context_tabs.TabSize = (new_pos(3)-20)/3;
end

%------------------Display the waveform for proir ERPset-------------------
function page_minus(~,~,EStudio_gui_erp_totl)
global observe_ERPDAT;
if isempty(observe_ERPDAT.ALLERP) || isempty(observe_ERPDAT.ERP)
    return;
end

ERPArray= estudioworkingmemory('selectederpstudio');
if isempty(ERPArray)
    ERPArray = length(observe_ERPDAT.ALLERP);
    observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
    observe_ERPDAT.CURRENTERP = ERPArray;
    estudioworkingmemory('selectederpstudio',ERPArray);
end

Pagecurrent = str2num(EStudio_gui_erp_totl.pageinfo_edit.String);
pageNum = numel(ERPArray);
if  ~isempty(Pagecurrent) &&  numel(Pagecurrent)~=1 %%if two or more numbers are entered
    Pagecurrent =1;
elseif isempty(Pagecurrent)
    [xpos, ypos] = find(ERPArray==observe_ERPDAT.CURRENTERP);
    if isempty(ypos)
        Pagecurrent=1;
    else
        Pagecurrent = ypos;
    end
end

Pagecurrent = Pagecurrent-1;
if  Pagecurrent>0 && Pagecurrent<=pageNum
else
    Pagecurrent=1;
end

Current_erp_Index = ERPArray(Pagecurrent);
EStudio_gui_erp_totl.pageinfo_edit.String = num2str(Pagecurrent);

observe_ERPDAT.CURRENTERP =  Current_erp_Index;
observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(Current_erp_Index);

% f_redrawERP();
if length(ERPArray) ==1
    Enable_minus = 'off';
    Enable_plus = 'off';
    Enable_plus_BackgroundColor = [0 0 0];
    Enable_minus_BackgroundColor = [0 0 0];
else
    if Pagecurrent ==1
        Enable_minus = 'off';
        Enable_plus = 'on';
        Enable_plus_BackgroundColor = [0 1 0];
        Enable_minus_BackgroundColor = [0 0 0];
    elseif  Pagecurrent == length(ERPArray)
        Enable_minus = 'on';
        Enable_plus = 'off';
        Enable_plus_BackgroundColor = [0 0 0];
        Enable_minus_BackgroundColor = [0 1 0];
    else
        Enable_minus = 'on';
        Enable_plus = 'on';
        Enable_plus_BackgroundColor = [0 1 0];
        Enable_minus_BackgroundColor = [0 1 0];
    end
end
EStudio_gui_erp_totl.pageinfo_minus.Enable = Enable_minus;
EStudio_gui_erp_totl.pageinfo_plus.Enable = Enable_plus;
EStudio_gui_erp_totl.pageinfo_plus.ForegroundColor = Enable_plus_BackgroundColor;
EStudio_gui_erp_totl.pageinfo_minus.ForegroundColor = Enable_minus_BackgroundColor;

MessageViewer= char(strcat('Plot previous page (<)'));
erpworkingmemory('f_ERP_proces_messg',MessageViewer);
observe_ERPDAT.Process_messg =1;
try
    observe_ERPDAT.Count_currentERP = 1;
    observe_ERPDAT.Process_messg =2;
catch
    observe_ERPDAT.Process_messg =3;
end
observe_ERPDAT.Two_GUI = observe_ERPDAT.Two_GUI+1;
end


%%--------------------Edit the index of ERPsets----------------------------
function page_edit(Str,~,EStudio_gui_erp_totl)
global observe_ERPDAT;

if isempty(observe_ERPDAT.ALLERP) || isempty(observe_ERPDAT.ERP)
    return;
end
ERPArray= estudioworkingmemory('selectederpstudio');
if isempty(ERPArray)
    ERPArray = length(observe_ERPDAT.ALLERP);
    observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
    observe_ERPDAT.CURRENTERP = ERPArray;
    estudioworkingmemory('selectederpstudio',ERPArray);
end

Pagecurrent = str2num(Str.String);
if isempty(Pagecurrent) || numel(Pagecurrent)~=1 || any(Pagecurrent>numel(ERPArray)) || any(Pagecurrent<1)
    [xpos, ypos] = find(ERPArray==observe_ERPDAT.CURRENTERP);
    if isempty(ypos)
        Pagecurrent=1;
    else
        Pagecurrent = ypos;
    end
    observe_ERPDAT.CURRENTERP =  ERPArray(Pagecurrent);
    observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(ERPArray(Pagecurrent));
end
EStudio_gui_erp_totl.pageinfo_edit.String = num2str(Pagecurrent);

if length(ERPArray) ==1
    Enable_minus = 'off';
    Enable_plus = 'off';
    Enable_plus_BackgroundColor = [0 0 0];
    Enable_minus_BackgroundColor = [0 0 0];
else
    if Pagecurrent ==1
        Enable_minus = 'off';
        Enable_plus = 'on';
        Enable_plus_BackgroundColor = [0 1 0];
        Enable_minus_BackgroundColor = [1 1 1];
    elseif  Pagecurrent == length(ERPArray)
        Enable_minus = 'on';
        Enable_plus = 'off';
        Enable_plus_BackgroundColor = [0 0 0];
        Enable_minus_BackgroundColor = [0 1 0];
    else
        Enable_minus = 'on';
        Enable_plus = 'on';
        Enable_plus_BackgroundColor = [0 1 0];
        Enable_minus_BackgroundColor = [0 1 0];
    end
end
EStudio_gui_erp_totl.pageinfo_minus.Enable = Enable_minus;
EStudio_gui_erp_totl.pageinfo_plus.Enable = Enable_plus;
EStudio_gui_erp_totl.pageinfo_plus.ForegroundColor = Enable_plus_BackgroundColor;
EStudio_gui_erp_totl.pageinfo_minus.ForegroundColor = Enable_minus_BackgroundColor;

MessageViewer= char(strcat('Page Editor'));
erpworkingmemory('f_ERP_proces_messg',MessageViewer);
observe_ERPDAT.Process_messg =1;
try
    observe_ERPDAT.Count_currentERP = 1;
    observe_ERPDAT.Process_messg =2;
catch
    observe_ERPDAT.Process_messg =3;
end

observe_ERPDAT.Two_GUI = observe_ERPDAT.Two_GUI+1;
end


%------------------Display the waveform for next ERPset--------------------
function page_plus(~,~,EStudio_gui_erp_totl)
global observe_ERPDAT;

if isempty(observe_ERPDAT.ALLERP) || isempty(observe_ERPDAT.ERP)
    return;
end
ERPArray= estudioworkingmemory('selectederpstudio');
if isempty(ERPArray)
    ERPArray = length(observe_ERPDAT.ALLERP);
    observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
    observe_ERPDAT.CURRENTERP = ERPArray;
    estudioworkingmemory('selectederpstudio',ERPArray);
end
Pagecurrent = str2num(EStudio_gui_erp_totl.pageinfo_edit.String);
pageNum = numel(ERPArray);
if  ~isempty(Pagecurrent) &&  numel(Pagecurrent)~=1 %%if two or more numbers are entered
    Pagecurrent =1;
elseif isempty(Pagecurrent)
    [xpos, ypos] = find(ERPArray==observe_ERPDAT.CURRENTERP);
    if isempty(ypos)
        Pagecurrent=1;
    else
        Pagecurrent = ypos;
    end
end

Pagecurrent = Pagecurrent+1;
if  Pagecurrent>0 && Pagecurrent<=pageNum
else
    Pagecurrent = pageNum;
end

Current_erp_Index = ERPArray(Pagecurrent);
EStudio_gui_erp_totl.pageinfo_edit.String = num2str(Pagecurrent);

observe_ERPDAT.CURRENTERP =  Current_erp_Index;
observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(Current_erp_Index);
estudioworkingmemory('selectederpstudio',ERPArray);
if length(ERPArray) ==1
    Enable_minus = 'off';
    Enable_plus = 'off';
    Enable_plus_BackgroundColor = [0 0 0];
    Enable_minus_BackgroundColor = [0 0 0];
else
    if Current_erp_Index ==1
        Enable_minus = 'off';
        Enable_plus = 'on';
        Enable_plus_BackgroundColor = [0 1 0];
        Enable_minus_BackgroundColor = [1 1 1];
    elseif  Current_erp_Index == length(ERPArray)
        Enable_minus = 'on';
        Enable_plus = 'off';
        Enable_plus_BackgroundColor = [0 0 0];
        Enable_minus_BackgroundColor = [0 1 0];
    else
        Enable_minus = 'on';
        Enable_plus = 'on';
        Enable_plus_BackgroundColor = [0 1 0];
        Enable_minus_BackgroundColor = [0 1 0];
    end
end
EStudio_gui_erp_totl.pageinfo_minus.Enable = Enable_minus;
EStudio_gui_erp_totl.pageinfo_plus.Enable = Enable_plus;
EStudio_gui_erp_totl.pageinfo_plus.ForegroundColor = Enable_plus_BackgroundColor;
EStudio_gui_erp_totl.pageinfo_minus.ForegroundColor = Enable_minus_BackgroundColor;

MessageViewer= char(strcat('Plot next page (>)'));
erpworkingmemory('f_ERP_proces_messg',MessageViewer);
observe_ERPDAT.Process_messg =1;
try
    observe_ERPDAT.Count_currentERP = 1;
    observe_ERPDAT.Process_messg =2;
catch
    observe_ERPDAT.Process_messg =3;
end
observe_ERPDAT.Two_GUI = observe_ERPDAT.Two_GUI+1;
end



%%--------------------------show the command-------------------------------
function Show_command(~,~)
global observe_ERPDAT;
if isempty(observe_ERPDAT.ALLERP) || isempty(observe_ERPDAT.ERP)
    return;
end
[messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
if ~isempty(messgStr)
    observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
end
erpworkingmemory('f_ERP_proces_messg','Show Command');
observe_ERPDAT.Process_messg =1;
f_preparms_erptab(observe_ERPDAT.ERP,1,'command');
observe_ERPDAT.Process_messg =2;
end

%%----------------------------save figure as-------------------------------
function figure_saveas(~,~)
global observe_ERPDAT;
if isempty(observe_ERPDAT.ALLERP) || isempty(observe_ERPDAT.ERP)
    return;
end
[messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
if ~isempty(messgStr)
    observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
end

erpworkingmemory('f_ERP_proces_messg','Save figure as');
observe_ERPDAT.Process_messg =1;
pathstr = pwd;
namedef =[observe_ERPDAT.ERP.erpname,'.pdf'];
[erpfilename, erppathname, indxs] = uiputfile({'*.pdf';'*.svg';'*.jpg';'*.png';'*.tif';'*.bmp';'*.eps'},...
    'Save as',[fullfile(pathstr,namedef)]);


if isequal(erpfilename,0)
    beep;
    observe_ERPDAT.Process_messg =3;
    disp('User selected Cancel')
    return
end

History = 'off';
[pathstr, erpfilename1, ext] = fileparts(erpfilename) ;

if isempty(ext)
    figurename = fullfile(erppathname,char(strcat(erpfilename,'.pdf')));
else
    figurename = fullfile(erppathname,erpfilename);
end

% try
f_preparms_erptab(observe_ERPDAT.ERP,1,History,figurename);
observe_ERPDAT.Process_messg =2;
% catch
%     observe_ERPDAT.Process_messg =3;
% end

end

%%--------------------Create static/eportable plot-------------------------
function figure_out(~,~)
global observe_ERPDAT;
if isempty(observe_ERPDAT.ALLERP) || isempty(observe_ERPDAT.ERP)
    return;
end
[messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
if ~isempty(messgStr)
    observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
end

MessageViewer= char(strcat('Create Static/Exportable Plot'));
erpworkingmemory('f_ERP_proces_messg',MessageViewer);
observe_ERPDAT.Process_messg =1;
try
    figurename = observe_ERPDAT.ERP.erpname;
catch
    figurename = '';
end
History = 'off';
f_preparms_erptab(observe_ERPDAT.ERP,1,History,figurename);
observe_ERPDAT.Process_messg =2;
end




function Advanced_viewer(Source,~)
global observe_ERPDAT;
if isempty(observe_ERPDAT.ALLERP) || isempty(observe_ERPDAT.ERP)
    Source.Enable = 'off';
    return;
end
erpworkingmemory('f_ERP_proces_messg','Launching "Advanced Wave Viewer"');
observe_ERPDAT.Process_messg =1;

ChanArray= estudioworkingmemory('ERP_ChanArray');
if isempty(ChanArray) || any(ChanArray<1) || any(ChanArray>observe_ERPDAT.ERP.nchan)
    ChanArray = [1:observe_ERPDAT.ERP.nchan];
end
BinArray= estudioworkingmemory('ERP_BinArray');
if isempty(BinArray) || any(BinArray<1) || any(BinArray>observe_ERPDAT.ERP.nbin)
    BinArray = [1:observe_ERPDAT.ERP.nbin];
end
ERPArray= estudioworkingmemory('selectederpstudio');
if isempty(ERPArray)
    ERPArray = length(observe_ERPDAT.ALLERP);
    observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
    observe_ERPDAT.CURRENTERP = ERPArray;
    estudioworkingmemory('selectederpstudio',ERPArray);
end
ERPLAB_ERP_Viewer(observe_ERPDAT.ALLERP,ERPArray,BinArray,ChanArray);
observe_ERPDAT.Process_messg =2;
end




function f_plotaberpwave(ERP,ChanArray,BinArray,timeStart,timEnd,xtickstep,YtickInterval,columNum,...
    positive_up,BinchanOverlay,rowNums,GridposArray,waveview,legendview)

FonsizeDefault = f_get_default_fontsize();
%%matlab version
matlab_ver = version('-release');
Matlab_ver = str2double(matlab_ver(1:4));


qtimeRange = [timeStart timEnd];
if BinchanOverlay==0
    qPLOTORG = [1 2 3];
    [~, qplotArrayStr, ~, ~, ~]  = readlocs(ERP.chanlocs(ChanArray));
    qLegendName= ERP.bindescr(BinArray);
else
    qPLOTORG = [2 1 3];
    [~, qLegendName, ~, ~, ~]  = readlocs(ERP.chanlocs(ChanArray));
    qplotArrayStr = ERP.bindescr(BinArray);
end
[ERPdatadef,legendNamedef,ERPerrordatadef,timeRangedef] = f_geterpdata(ERP,1,qPLOTORG,1);

if qPLOTORG(1)==1 && qPLOTORG(2)==2 %% Array is plotnum by samples by datanum
    bindata = ERPdatadef(ChanArray,:,BinArray,1);
    plotArray = ChanArray;
elseif  qPLOTORG(1)==2 && qPLOTORG(2)==1
    bindata = ERPdatadef(ChanArray,:,BinArray,1);
    bindata = permute(bindata,[3 2 1 4]);
    plotArray = BinArray;
end
if isempty(timeRangedef)
    timeRangedef = ERP.times;
end
fs= ERP.srate;
qYScales = [-YtickInterval,YtickInterval];
Ypert =20;
%%get y axis
y_scale_def = [1.1*min(bindata(:)),1.1*max(bindata(:))];

if numel(qYScales)==2
    yscaleall = qYScales(end)-qYScales(1);
else
    yscaleall = 2*max(abs(qYScales));
    qYScales = [-max(abs(qYScales)),max(abs(qYScales))];
end
if yscaleall < y_scale_def(2)-y_scale_def(1)
    yscaleall = y_scale_def(2)-y_scale_def(1);
end
for Numofrows = 1:rowNums
    OffSetY(Numofrows) = yscaleall*(rowNums-Numofrows)*(Ypert/100+1);
end

qYticksdef = str2num(char(default_amp_ticks_viewer(qYScales)));
qYticks = [-YtickInterval,0, YtickInterval];
if isempty(qYticks) || numel(qYticks)<2
    qYticks = qYticksdef;
end


%%gap between columns
Xpert = 20;
try
    StepX = (ERP.times(end)-ERP.times(1))*(Xpert/100);
catch
    beep;
    disp('ERP.times only has one element.');
    return;
end
StepXP = ceil(StepX/(1000/fs));

qPolarityWave = positive_up;

NumOverlay = size(bindata,3);
isxaxislabel=1;

%%line color
qLineColorspec = get_colors(NumOverlay);
%%xticks
[timeticksdef stepX]= default_time_ticks_studio(ERP, qtimeRange);
timeticksdef = str2num(char(timeticksdef));
qtimeRangedef = round(qtimeRange/100)*100;
qXticks = xtickstep+qtimeRangedef(1);
for ii=1:1000
    xtickcheck = qXticks(end)+xtickstep;
    if xtickcheck>qtimeRangedef(2)
        break;
    else
        qXticks(numel(qXticks)+1) =xtickcheck;
    end
end
if isempty(qXticks)|| stepX==xtickstep
    qXticks =  timeticksdef;
end
%%remove the margins of a plot
ax = waveview;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

%%check elements in qGridposArray
plotArray = reshape(plotArray,1,[]);
for Numofrows = 1:size(GridposArray,1)
    for Numofcolumns = 1:size(GridposArray,2)
        SingleGridpos = GridposArray(Numofrows,Numofcolumns);
        if SingleGridpos~=0
            ExistGridops = f_existvector(plotArray,SingleGridpos);
            if ExistGridops==1
                GridposArray(Numofrows,Numofcolumns) =0;
            else
                [xpos,ypos]=  find(plotArray==SingleGridpos);
                GridposArray(Numofrows,Numofcolumns) =ypos;
            end
        end
    end
end
fontnames = 'Helvetica';

hplot = [];
countPlot = 0;
for Numofrows = 1:rowNums
    for Numofcolumns = 1:columNum
        try
            plotdatalabel = GridposArray(Numofrows,Numofcolumns);
        catch
            plotdatalabel = 0;
        end
        
        try
            labelcbe = qplotArrayStr{plotdatalabel};
            if isempty(labelcbe)
                labelcbe  = 'No label';
            end
        catch
            labelcbe = 'no';
        end
        try
            plotbindata =  bindata(plotdatalabel,:,:,:);
        catch
            plotbindata = [];
        end
        
        if plotdatalabel ~=0 && plotdatalabel<= numel(plotArray) && ~isempty(plotbindata)
            countPlot =countPlot +1;
            if qPolarityWave==1
                data4plot = squeeze(bindata(plotdatalabel,:,:,1));
            else
                data4plot = squeeze(bindata(plotdatalabel,:,:,1))*(-1);
            end
            
            data4plot = reshape(data4plot,numel(timeRangedef),NumOverlay);
            for Numofoverlay = 1:NumOverlay
                [Xtimerange, bindatatrs] = f_adjustbindtabasedtimedefd(squeeze(data4plot(:,Numofoverlay)), timeRangedef,qtimeRange,fs);
                PosIndexsALL = [Numofrows,columNum];
                if isxaxislabel==2
                    [~,XtimerangetrasfALL,~,~,~] = f_adjustdata_xyrange_xyticks_overlay(bindatatrs,Xtimerange,qXticks,OffSetY,columNum,PosIndexsALL,StepXP);
                else
                    [~,XtimerangetrasfALL,~] = f_adjustdata_xyrange_xyticks(bindatatrs,Xtimerange,qXticks,OffSetY,columNum,PosIndexsALL,StepX,fs);
                end
                PosIndexs = [Numofrows,Numofcolumns];
                if isxaxislabel==2
                    [bindatatrs,Xtimerangetrasf,qXtickstransf,TimeAdjustOut,XtimerangeadjustALL] = f_adjustdata_xyrange_xyticks_overlay(bindatatrs,Xtimerange,qXticks,OffSetY,columNum,PosIndexs,StepXP);
                else
                    [bindatatrs,Xtimerangetrasf,qXtickstransf] = f_adjustdata_xyrange_xyticks(bindatatrs,Xtimerange,qXticks,OffSetY,columNum,PosIndexs,StepX,fs);
                end
                hplot(Numofoverlay) = plot(waveview,Xtimerangetrasf, bindatatrs,'LineWidth',1,...
                    'Color', qLineColorspec(Numofoverlay,:));
            end
            
            %             if numel(OffSetY)==1 && OffSetY==0
            %                 if ~qPolarityWave
            %                     YscalesNew =  sort(y_scale_def*(-1));
            %                 else
            %                     YscalesNew =  y_scale_def;
            %                 end
            %                 set(waveview,'ylim',YscalesNew);
            %             else
            %                 if qPolarityWave
            %                     ylimleftedge = min([floor(y_scale_def(1)),qYScales(1)]);
            %                     ylimrightedge = ceil(y_scale_def(end))+OffSetY(1);
            %                 else
            %                     ylimleftedge = -max([abs(ceil(y_scale_def(end))),abs(qYScales(end))]);
            %                     ylimrightedge = ceil(abs(y_scale_def(1)))+OffSetY(1);
            %                 end
            % %                 set(waveview,'ylim',[ylimleftedge,ylimrightedge]);
            %             end
            %
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%----------------------Adjust y axis------------------------%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            props = get(waveview);
            if qPolarityWave
                props.YTick = qYticks+OffSetY(Numofrows);
            else
                props.YTick =  fliplr (-1*qYticks)+OffSetY(Numofrows);
            end
            props.YTickLabel = cell(numel(props.YTick),1);
            
            
            for Numofytick = 1:numel(props.YTick)
                props.YTickLabel(Numofytick) = {num2str(props.YTick(Numofytick))};
            end
            
            [x,y_0] = find(Xtimerange==0);
            if isempty(y_0)
                y_0 = 1;
            end
            myY_Crossing = Xtimerangetrasf(y_0);
            tick_top = 0;
            
            if countPlot ==1
                ytick_bottom = -props.TickLength(1)*diff(props.XLim);
                ytick_bottomratio = abs(ytick_bottom)/diff(props.XLim);
            else
                try
                    ytick_bottom = ytick_bottom;
                    ytick_bottomratio = ytick_bottomratio;
                catch
                    ytick_bottom = -props.TickLength(1)*diff(props.XLim);
                    ytick_bottomratio = abs(ytick_bottom)/diff(props.XLim);
                end
            end
            %%add  yunits
            if ~isempty(props.YTick)
                ytick_y = repmat(props.YTick, 2, 1);
                ytick_x = repmat([tick_top;ytick_bottom] +myY_Crossing, 1, length(props.YTick));
                line(waveview,ytick_x(:,:), ytick_y(:,:), 'color', 'k','LineWidth',1);
                try
                    [~,y_below0] =find(qYticks<0);
                    if isempty(y_below0) && qYScales(1)<0
                        line(waveview,ytick_x(:,:), ones(2,1)*(qYScales(1)+OffSetY(Numofrows)), 'color', 'k','LineWidth',1);
                    end
                    [~,y_over0] =find(qYticks>0);
                    if isempty(y_over0) && qYScales(2)>0
                        line(waveview,ytick_x(:,:), ones(2,1)*(qYScales(2)+OffSetY(Numofrows)), 'color', 'k','LineWidth',1);
                    end
                catch
                end
            end
            
            if ~isempty(qYScales)  && numel(qYScales)==2 %qYScales(end))+OffSetY(1)
                if  qPolarityWave==0
                    qYScalestras =   fliplr (-1*qYScales);
                else
                    qYScalestras = qYScales;
                end
                plot(waveview,ones(numel(qYScalestras),1)*myY_Crossing, qYScalestras+OffSetY(Numofrows),'k','LineWidth',1);
            else
                if ~isempty(y_scale_def) && numel(unique(y_scale_def))==2
                    if  qPolarityWave==0
                        qYScalestras =   fliplr (-1*y_scale_def);
                    else
                        qYScalestras = y_scale_def;
                    end
                    plot(waveview,ones(numel(qYScales),1)*myY_Crossing, qYScalestras+OffSetY(Numofrows),'k','LineWidth',1);
                else
                end
            end
            
            qYtickdecimal=1;
            nYTicks = length(props.YTick);
            for iCount = 1:nYTicks
                if qPolarityWave==1
                    ytick_label= sprintf(['%.',num2str(qYtickdecimal),'f'],str2num(char(props.YTickLabel(iCount, :)))-OffSetY(Numofrows));
                else
                    qyticktras =   fliplr(-1*qYticks);
                    ytick_label= sprintf(['%.',num2str(qYtickdecimal),'f'],-qyticktras(iCount));
                end
                %                 end
                if str2num(char(ytick_label)) ==0 || (str2num(char(ytick_label))<0.0001 && str2num(char(ytick_label))>0) || (str2num(char(ytick_label))>-0.0001 && str2num(char(ytick_label))<0)
                    ytick_label = '';
                end
                text(waveview,myY_Crossing-2*abs(ytick_bottom),props.YTick(iCount),  ...
                    ytick_label, ...
                    'HorizontalAlignment', 'right', ...
                    'VerticalAlignment', 'middle', ...
                    'FontSize', FonsizeDefault, ...
                    'FontAngle', props.FontAngle, ...
                    'FontUnits', props.FontUnits,...
                    'FontName', fontnames, ...
                    'Color',[0 0 0]);%
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%----------------------Adjust x axis------------------------%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            props.XTick = qXtickstransf;
            props.XTickLabel = cell(numel(qXticks),1);
            for Numofytick = 1:numel(props.XTick)
                props.XTickLabel(Numofytick) = {num2str(qXticks(Numofytick))};
            end
            myX_Crossing = OffSetY(Numofrows);
            if countPlot ==1
                xtick_bottom = -props.TickLength(2)*max(props.YLim);
                if abs(xtick_bottom)/max(props.YLim) > ytick_bottomratio
                    xtick_bottom = -ytick_bottomratio*max(props.YLim);
                end
            else
                try
                    xtick_bottom = xtick_bottom;
                catch
                    xtick_bottom = -props.TickLength(2)*max(props.YLim);
                    if abs(xtick_bottom)/max(props.YLim) > ytick_bottomratio
                        xtick_bottom = -ytick_bottomratio*max(props.YLim);
                    end
                end
            end
            if ~isempty(props.XTick)
                xtick_x = repmat(props.XTick, 2, 1);
                xtick_y = repmat([xtick_bottom; tick_top]*0.5 + myX_Crossing, 1, length(props.XTick));
                line(waveview,xtick_x, xtick_y, 'color', 'k','LineWidth',1);
            end
            [x_xtick,y_xtick] = find(props.XTick==0);
            if ~isempty(y_xtick)
                props.XTick(y_xtick) = 2*xtick_bottom;
            end
            plot(waveview,Xtimerangetrasf, myX_Crossing.*ones(numel(Xtimerangetrasf),1),'k','LineWidth',1);
            nxTicks = length(props.XTick);
            qXticklabel = 'on';
            for iCount = 1:nxTicks
                xtick_label = (props.XTickLabel(iCount, :));
                if strcmpi(qXticklabel,'on')
                    if strcmpi(xtick_label,'0')
                        xtick_label = '';
                    end
                else
                    xtick_label = '';
                end
                text(waveview,props.XTick(iCount), xtick_bottom*0.5 + myX_Crossing, ...
                    xtick_label, ...
                    'HorizontalAlignment', 'Center', ...
                    'VerticalAlignment', 'Top', ...
                    'FontSize', FonsizeDefault, ...
                    'FontAngle', props.FontAngle, ...
                    'FontUnits', props.FontUnits,...
                    'FontName', fontnames, ...
                    'Color',[0 0 0]);%'FontName', qXlabelfont, ...
            end
            %%-----------------minor X---------------
            set(waveview,'xlim',[Xtimerange(1),Xtimerangetrasf(end)]);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%------------------channel/bin/erpset label-----------------%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ypercentage =100;
            ypos_LABEL = (qYScalestras(end)-qYScalestras(1))*(ypercentage)/100+qYScalestras(1);
            xpercentage = 50;
            xpos_LABEL = (Xtimerangetrasf(end)-Xtimerangetrasf(1))*xpercentage/100 + Xtimerangetrasf(1);
            labelcbe =  strrep(char(labelcbe),'_','\_');
            try
                labelcbe = regexp(labelcbe, '\;', 'split');
            catch
            end
            text(waveview,xpos_LABEL,ypos_LABEL+OffSetY(Numofrows), char(labelcbe),'FontName', fontnames,'HorizontalAlignment', 'center');%'FontWeight', 'bold',
        else
        end
        try
            if 2<columNum && columNum<5
                set(waveview,'xlim',[Xtimerange(1)-(Xtimerange(end)-Xtimerange(1))/20,XtimerangetrasfALL(end)+(Xtimerange(end)-Xtimerange(1))/20]);
            elseif columNum==1
                set(waveview,'xlim',[Xtimerange(1)-(Xtimerange(end)-Xtimerange(1))/40,XtimerangetrasfALL(end)+(Xtimerange(end)-Xtimerange(1))/40]);
            elseif columNum==2
                set(waveview,'xlim',[Xtimerange(1)-(Xtimerange(end)-Xtimerange(1))/30,XtimerangetrasfALL(end)+(Xtimerange(end)-Xtimerange(1))/30]);
            else
                set(waveview,'xlim',[Xtimerange(1)-(Xtimerange(end)-Xtimerange(1))/10,XtimerangetrasfALL(end)+(Xtimerange(end)-Xtimerange(1))/10]);
            end
        catch
        end
    end%% end of columns
    ylim([1.1*(min(OffSetY(:))+qYScales(1)),1.1*(max(OffSetY(:))+qYScales(end))]);
    if qPolarityWave==-1
        ylimleftedge = min([1.1*(min(OffSetY(:))+qYScales(1)),-abs(y_scale_def(2))]);
        ylim([ylimleftedge,1.1*(max(OffSetY(:))+qYScales(end))]);
    end
end%% end of rows
set(waveview, 'XTick', [], 'YTick', [],'Box','off', 'Color','none','xcolor','none','ycolor','none');
if ~isempty(hplot)
    NumColumns = ceil(sqrt(length(qLegendName)));
    for Numofoverlay = 1:numel(hplot)
        qLegendName{Numofoverlay} = strrep(qLegendName{Numofoverlay},'_','\_');
        LegendName{Numofoverlay} = char(strcat('\color[rgb]{',num2str([0 0 0]),'}',32,qLegendName{Numofoverlay}));
    end
    p  = get(legendview,'position');
    h_legend = legend(legendview,hplot,qLegendName);
    legend('boxoff');
    set(h_legend,'NumColumns',NumColumns,'FontName', fontnames, 'Color', [1 1 1], 'position', p,'FontSize',FonsizeDefault);
end
end



function colors = get_colors(ncolors)
% Each color gets 1 point divided into up to 2 of 3 groups (RGB).
degree_step = 6/ncolors;
angles = (0:ncolors-1)*degree_step;
colors = nan(numel(angles),3);
for i = 1:numel(angles)
    if angles(i) < 1
        colors(i,:) = [1 (angles(i)-floor(angles(i))) 0]*0.75;
    elseif angles(i) < 2
        colors(i,:) = [(1-(angles(i)-floor(angles(i)))) 1 0]*0.75;
    elseif angles(i) < 3
        colors(i,:) = [0 1 (angles(i)-floor(angles(i)))]*0.75;
    elseif angles(i) < 4
        colors(i,:) = [0 (1-(angles(i)-floor(angles(i)))) 1]*0.75;
    elseif angles(i) < 5
        colors(i,:) = [(angles(i)-floor(angles(i))) 0 1]*0.75;
    else
        colors(i,:) = [1 0 (1-(angles(i)-floor(angles(i))))]*0.75;
    end
end
end