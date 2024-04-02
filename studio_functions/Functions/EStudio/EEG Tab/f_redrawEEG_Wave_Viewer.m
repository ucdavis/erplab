%PURPOSE  : Plot EEG waves within one axes as EEGLAB

% Author: Guanghui Zhang & Steve J. Luck
% Center for Mind and Brain
% University of California, Davis
% Davis, CA
% 2023



function f_redrawEEG_Wave_Viewer()

global observe_EEGDAT;
global EStudio_gui_erp_totl;%%Global variable
addlistener(observe_EEGDAT,'eeg_panel_change_message',@eeg_panel_change_message);
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);


if nargin>1
    help f_redrawEEG_Wave_Viewer;
    return;
end

if isempty(observe_EEGDAT.EEG)
    Startimes = 0;
else
    Startimes= estudioworkingmemory('Startimes');
    if isempty(Startimes) || min(Startimes)<0
        Startimes = 0;
    end
    EEG_plotset = estudioworkingmemory('EEG_plotset');
    try
        Winlength =   EEG_plotset{3};
    catch
        Winlength = 5;
    end
    
    [chaNum,sampleNum,trialNum]=size(observe_EEGDAT.EEG.data);
    Frames = sampleNum*trialNum;
    if observe_EEGDAT.EEG.trials>1 % time in second or in trials
        multiplier = size(observe_EEGDAT.EEG.data,2);
    else
        multiplier = observe_EEGDAT.EEG.srate;
    end
    if isempty(Winlength)|| Winlength<0 ||  (Winlength>floor(Frames/observe_EEGDAT.EEG.srate))
        Winlength = 5;
    end
    StartimesMax = max(0,ceil((Frames-1)/multiplier)-Winlength);
    if observe_EEGDAT.EEG.trials>1
        StartimesMax =StartimesMax+1;
    end
    if  Startimes > StartimesMax
        Startimes = StartimesMax;
    end
end
if ~isempty(observe_EEGDAT.EEG)
    if observe_EEGDAT.EEG.trials>1  && Startimes ==0%%for epoched EEG, it should be from the first epoch
        Startimes=1;
    end
end
estudioworkingmemory('Startimes',Startimes);

%%Selected EEGsets from memory file
EEGset_selected = estudioworkingmemory('EEGArray');
if ~isempty(observe_EEGDAT.ALLEEG)  && ~isempty(observe_EEGDAT.EEG)
    if isempty(EEGset_selected) || min(EEGset_selected(:)) > length(observe_EEGDAT.ALLEEG) || max(EEGset_selected(:))>length(observe_EEGDAT.ALLEEG)
        EEGset_selected =  length(observe_EEGDAT.ALLEEG) ;
        estudioworkingmemory('EEGArray',EEGset_selected);
        observe_EEGDAT.CURRENTSET = EEGset_selected;
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(EEGset_selected);
        assignin('base','EEG',observe_EEGDAT.EEG);
        assignin('base','ALLEEG', observe_EEGDAT.ALLEEG);
        assignin('base','CURRENTSET', observe_EEGDAT.CURRENTSET);
    end
    [xpos,ypos] = find(EEGset_selected==observe_EEGDAT.CURRENTSET);
    if ~isempty(ypos)
        pagecurrentNum = ypos;
        pageNum = numel(EEGset_selected);
        PageStr = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET).setname;
    else
        pageNum=1;
        pagecurrentNum=1;
        PageStr = observe_EEGDAT.EEG.setname;
    end
    Enableflag = 'on';
else
    pageNum=1;
    pagecurrentNum=1;
    PageStr = 'No EEG was loaded';
    Enableflag = 'off';
end

EEG_autoplot = EStudio_gui_erp_totl.EEG_autoplot;

EStudio_gui_erp_totl.eegpageinfo_text.String=['Page',32,num2str(pagecurrentNum),'/',num2str(pageNum),':',PageStr];
EStudio_gui_erp_totl.eegpageinfo_minus.Callback=@page_minus;
set(EStudio_gui_erp_totl.eegpageinfo_edit,'String',num2str(pagecurrentNum),'Enable','on');
if EEG_autoplot ==0
    EStudio_gui_erp_totl.eegpageinfo_text.String='Plotting is disabled, to enable it, please go to "Plotting Options" at the bottom of the plotting area to active it.';
    Enableflag = 'off';
end
EStudio_gui_erp_totl.eegpageinfo_edit.Callback=@page_edit;
EStudio_gui_erp_totl.eegpageinfo_plus.Callback=@page_plus;
if pageNum ==1
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
    elseif  pagecurrentNum == pageNum
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

if ~isempty(observe_EEGDAT.ALLEEG) && ~isempty(observe_EEGDAT.EEG) && EEG_autoplot==0
    Enable_minus = 'off';
    Enable_plus = 'off';
    EStudio_gui_erp_totl.eegpageinfo_edit.Enable = 'off';
end

%%----Processing for label ICs or using IClabel
EEGUpdate = erpworkingmemory('EEGUpdate');
if isempty(EEGUpdate) || numel(EEGUpdate)~=1 || (EEGUpdate~=0 && EEGUpdate~=1)
    EEGUpdate = 0;  erpworkingmemory('EEGUpdate',0);
end
if EEGUpdate==1
    Enableflag = 'off';
    Enable_minus = 'off';
    Enable_plus = 'off';
    EStudio_gui_erp_totl.eegpageinfo_edit.Enable = 'off';
end


EStudio_gui_erp_totl.eegpageinfo_minus.Enable = Enable_minus;
EStudio_gui_erp_totl.eegpageinfo_plus.Enable = Enable_plus;
EStudio_gui_erp_totl.eegpageinfo_plus.ForegroundColor = Enable_plus_BackgroundColor;
EStudio_gui_erp_totl.eegpageinfo_minus.ForegroundColor = Enable_minus_BackgroundColor;
set(EStudio_gui_erp_totl.eegpageinfo_box, 'Sizes', [-1 70 50 70] );
set(EStudio_gui_erp_totl.eeg_zoom_in_large,'Callback',@zoomin_large,'Enable',Enableflag);
set(EStudio_gui_erp_totl.eeg_zoom_in_fivesmall,'Callback',@zoomin_fivesmall,'Enable',Enableflag);
set(EStudio_gui_erp_totl.eeg_zoom_in_small,'Callback',@zoomin_small,'Enable',Enableflag);
set(EStudio_gui_erp_totl.eeg_zoom_edit,'String',num2str(Startimes),'Enable',Enableflag);
set(EStudio_gui_erp_totl.eeg_zoom_edit,'Callback',@zoomedit,'Enable',Enableflag);
set(EStudio_gui_erp_totl.eeg_zoom_out_small,'Callback',@zoomout_small,'Enable',Enableflag);
set(EStudio_gui_erp_totl.eeg_zoom_out_fivelarge,'Callback',@zoomout_fivelarge,'Enable',Enableflag);
set(EStudio_gui_erp_totl.eeg_zoom_out_large,'Callback',@zoomout_large,'Enable',Enableflag);
if ~isempty(observe_EEGDAT.ALLEEG) && ~isempty(observe_EEGDAT.EEG)
    set(EStudio_gui_erp_totl.popmemu_eeg,'Callback',@popmemu_eeg,'Enable','on','String',...
        {'Plotting Options','Automatic Plotting','Window Size','Show Command','Save Figure as','Create Static/Exportable Plot'});
else
    set(EStudio_gui_erp_totl.popmemu_eeg,'Callback',@popmemu_eeg,'Enable','on','String',{'Plotting Options','Automatic Plotting','Window Size'});
end
popmemu_eeg = EStudio_gui_erp_totl.popmemu_eeg.String;
if EEG_autoplot==1
    popmemu_eeg{2} = 'Automatic Plotting: On';
else
    popmemu_eeg{2} = 'Automatic Plotting: Off';
end
EStudio_gui_erp_totl.popmemu_eeg.String=popmemu_eeg;


set(EStudio_gui_erp_totl.eeg_reset,'Callback',@eeg_paras_reset,'Enable','on');
set(EStudio_gui_erp_totl.eeg_plot_button_title, 'Sizes', [10 40 40 40 40 40 40 40 -1 150 50 5]);

if ~isempty(observe_EEGDAT.ALLEEG) && ~isempty(observe_EEGDAT.EEG) && EEG_autoplot==1
    EEG = observe_EEGDAT.EEG;
    OutputViewereegpar = f_preparms_eegwaviewer(EEG,0);
    % %%Plot the eeg waves
    if ~isempty(OutputViewereegpar)
        EStudio_gui_erp_totl = f_plotviewereegwave(EEG,OutputViewereegpar{1},OutputViewereegpar{2},...
            OutputViewereegpar{3},OutputViewereegpar{4},OutputViewereegpar{5},...
            OutputViewereegpar{6},OutputViewereegpar{7},OutputViewereegpar{8},...
            OutputViewereegpar{9},OutputViewereegpar{10},OutputViewereegpar{11},...
            OutputViewereegpar{12},OutputViewereegpar{13},OutputViewereegpar{14},EStudio_gui_erp_totl);
    else
        return;
    end
end

if isempty(observe_EEGDAT.EEG) ||  EEG_autoplot==0
    EStudio_gui_erp_totl.myeegviewer = axes('Parent', EStudio_gui_erp_totl.eegViewAxes,'Color','none','Box','on','FontWeight','normal');
    hold(EStudio_gui_erp_totl.myeegviewer,'on');
    set(EStudio_gui_erp_totl.myeegviewer, 'XTick', [], 'YTick', [],'Box','off', 'Color','none','xcolor','none','ycolor','none');
else
end
EStudio_gui_erp_totl.eegplotgrid.Heights(1) = 30; % set the first element (pageinfo) to 30px high
EStudio_gui_erp_totl.eegplotgrid.Heights(3) = 5;
EStudio_gui_erp_totl.eegplotgrid.Heights(4) = 30; % set the second element (x axis) to 30px high
EStudio_gui_erp_totl.eegplotgrid.Heights(5) = 30; % set the second element (x axis) to 30px high
end % redrawDemo

%%-------------------------------------------------------------------------
%%-----------------------------Subfunctions--------------------------------
%%-------------------------------------------------------------------------

function popmemu_eeg(Source,~)
global EStudio_gui_erp_totl;
Value = Source.Value;
if Value==2
    app = feval('EStudio_plot_set_waves',EStudio_gui_erp_totl.EEG_autoplot,1);
    waitfor(app,'Finishbutton',1);
    try
        plotSet = app.output; %NO you don't want to output EEG with edited channel locations, you want to output the parameters to run decoding
        app.delete; %delete app from view
        pause(0.01); %wait for app to leave
    catch
        return;
    end
    if isempty(plotSet)||numel(plotSet)~=1 || (plotSet~=0&&plotSet~=1)
        plotSet=1;
    end
    popmemu_eegString = EStudio_gui_erp_totl.popmemu_eeg.String;
    if plotSet==1
        popmemu_eegString{2} = 'Automatic Plotting: On';
    else
        popmemu_eegString{2} = 'Automatic Plotting: Off';
    end
    EStudio_gui_erp_totl.popmemu_eeg.String=popmemu_eegString;
    EStudio_gui_erp_totl.EEG_autoplot = plotSet;
    f_redrawEEG_Wave_Viewer();
elseif Value==3
    EStudiowinsize();
elseif Value==4
    Show_command();
elseif Value==5
    figure_saveas();
elseif  Value==6
    figure_out();
end
Source.Value=1;
end


%%--------------------Setting for EStudio window size----------------------
function EStudiowinsize(~,~)
global observe_EEGDAT;
global EStudio_gui_erp_totl;%%Global variable
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
    pause(0.01); %wait for app to leave
catch
    return;
end
try New_pos1(2) = abs(New_pos1(2));catch; end;

if isempty(New_pos1) || numel(New_pos1)~=2
    erpworkingmemory('f_EEG_proces_messg',['The defined Window Size for EStudio is invalid and it must be two numbers']);
    observe_EEGDAT.eeg_panel_message =4;
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
    erpworkingmemory('f_EEG_proces_messg',['The defined Window Size for EStudio is invalid and it must be two numbers']);
    observe_EEGDAT.eeg_panel_message =4;
    set(EStudio_gui_erp_totl.Window, 'Position', [0 0 0.75*ScreenPos(3) 0.75*ScreenPos(4)]);
    erpworkingmemory('EStudioScreenPos',[75 75]);
end
f_redrawEEG_Wave_Viewer();
f_redrawERP();
EStudio_gui_erp_totl.context_tabs.TabSize = (new_pos(3)-20)/2;
%         EStudio_gui_erp_totl.context_tabs.TabSize = (new_pos(3)-20)/3;
end


%%------------------set to 0----------------------------------------
function zoomin_large(~,~)
global observe_EEGDAT;
global EStudio_gui_erp_totl;%%Global variable
if isempty(observe_EEGDAT.EEG)
    return;
end
EStudio_gui_erp_totl.eegProcess_messg.String = '';
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;%%Get background color
catch
    ColorB_def = [0.7020 0.77 0.85];
end
if isempty(ColorB_def) || numel(ColorB_def)~=3 || min(ColorB_def(:))<0 || max(ColorB_def(:))>1
    ColorB_def = [0.7020 0.77 0.85];
end
EStudio_gui_erp_totl.eegProcess_messg.BackgroundColor = ColorB_def;

if observe_EEGDAT.EEG.trials>1 % time in second or in trials
    Startimes =1;
else
    Startimes = 0;
end
EStudio_gui_erp_totl.eeg_zoom_edit.String =num2str(Startimes);
estudioworkingmemory('Startimes',Startimes);
f_redrawEEG_Wave_Viewer();
% observe_EEGDAT.eeg_panel_message=2;
end


%%reduce the start time of the displayed EEG
function zoomin_fivesmall(~,~)
global observe_EEGDAT;
global EStudio_gui_erp_totl;%%Global variable
if isempty(observe_EEGDAT.EEG)
    return;
end
EStudio_gui_erp_totl.eegProcess_messg.String = '';
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;%%Get background color
catch
    ColorB_def = [0.7020 0.77 0.85];
end
if isempty(ColorB_def) || numel(ColorB_def)~=3 || min(ColorB_def(:))<0 || max(ColorB_def(:))>1
    ColorB_def = [0.7020 0.77 0.85];
end
EStudio_gui_erp_totl.eegProcess_messg.BackgroundColor = ColorB_def;

% MessageViewer= char(strcat('Decreasing start time for the displayed EEG (<<)'));
EEG_plotset = estudioworkingmemory('EEG_plotset');
% observe_EEGDAT.eeg_panel_message=1;
try
    Winlength =   EEG_plotset{3};
catch
    Winlength = 5;
    EEG_plotset{3} = 5;
end
[chaNum,sampleNum,trialNum]=size(observe_EEGDAT.EEG.data);
Frames = sampleNum*trialNum;
if observe_EEGDAT.EEG.trials>1 % time in second or in trials
    multiplier_winleg = size(observe_EEGDAT.EEG.data,2);
else
    multiplier_winleg = observe_EEGDAT.EEG.srate;
end
if isempty(Winlength)|| Winlength<0 || Winlength>floor(Frames/multiplier_winleg)
    Winlength = 5;
    EEG_plotset{3} = 5;
end
estudioworkingmemory('EEG_plotset',EEG_plotset);
Startimesdef = str2num(EStudio_gui_erp_totl.eeg_zoom_edit.String);
if ~isempty(Startimesdef) && isnumeric(Startimesdef) && numel(Startimesdef)==1 && Startimesdef>=0
else
    Startimesdef = 0;
    EStudio_gui_erp_totl.eeg_zoom_edit.String = '0';
end

% if Startimesdef>0
Startimes = Startimesdef-fastif(Winlength>=5, round(5*Winlength), 5*Winlength);
% end
if Startimes<0
    if observe_EEGDAT.EEG.trials>1
        Startimes=1;
    else
        Startimes=0;
    end
end

estudioworkingmemory('Startimes',Startimes);
% erpworkingmemory('f_EEG_proces_messg',MessageViewer);
EStudio_gui_erp_totl.eeg_zoom_edit.String =num2str(Startimes);
f_redrawEEG_Wave_Viewer();
% observe_EEGDAT.eeg_panel_message=2;

end


%%prev time period
function zoomin_small(~,~)

global observe_EEGDAT;
global EStudio_gui_erp_totl;%%Global variable
if isempty(observe_EEGDAT.EEG)
    return;
end
EStudio_gui_erp_totl.eegProcess_messg.String = '';
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;%%Get background color
catch
    ColorB_def = [0.7020 0.77 0.85];
end
if isempty(ColorB_def) || numel(ColorB_def)~=3 || min(ColorB_def(:))<0 || max(ColorB_def(:))>1
    ColorB_def = [0.7020 0.77 0.85];
end
EStudio_gui_erp_totl.eegProcess_messg.BackgroundColor = ColorB_def;

% MessageViewer= char(strcat('Decreasing start time for the displayed EEG (<)'));
EEG_plotset = estudioworkingmemory('EEG_plotset');
% observe_EEGDAT.eeg_panel_message=1;
try
    Winlength =   EEG_plotset{3};
catch
    Winlength = 5;
    EEG_plotset{3} = 5;
end
[chaNum,sampleNum,trialNum]=size(observe_EEGDAT.EEG.data);
Frames = sampleNum*trialNum;
if observe_EEGDAT.EEG.trials>1 % time in second or in trials
    multiplier_winleg = size(observe_EEGDAT.EEG.data,2);
else
    multiplier_winleg = observe_EEGDAT.EEG.srate;
end
if isempty(Winlength)|| Winlength<0 || Winlength>floor(Frames/multiplier_winleg)
    Winlength = 5;
    EEG_plotset{3} = 5;
end
estudioworkingmemory('EEG_plotset',EEG_plotset);
Startimesdef = str2num(EStudio_gui_erp_totl.eeg_zoom_edit.String);
if ~isempty(Startimesdef) && isnumeric(Startimesdef) && numel(Startimesdef)==1 && Startimesdef>=0
else
    Startimesdef = 0;
    EStudio_gui_erp_totl.eeg_zoom_edit.String = '0';
end

% if Startimesdef>0
Startimes = Startimesdef-fastif(Winlength>=5, round(Winlength), Winlength);
% end
if Startimes<0
    if observe_EEGDAT.EEG.trials>1
        Startimes=1;
    else
        Startimes=0;
    end
end

estudioworkingmemory('Startimes',Startimes);
% erpworkingmemory('f_EEG_proces_messg',MessageViewer);
% observe_EEGDAT.eeg_panel_message=1;
EStudio_gui_erp_totl.eeg_zoom_edit.String =num2str(Startimes);
f_redrawEEG_Wave_Viewer();
% observe_EEGDAT.eeg_panel_message=2;
end


%%Editing the start the time for the displayed EEG data
function zoomedit(Source,~)
global observe_EEGDAT;
global EStudio_gui_erp_totl;%%Global variable
if isempty(observe_EEGDAT.EEG)
    Source.String ='0';
    return;
end
EStudio_gui_erp_totl.eegProcess_messg.String = '';
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;%%Get background color
catch
    ColorB_def = [0.7020 0.77 0.85];
end
if isempty(ColorB_def) || numel(ColorB_def)~=3 || min(ColorB_def(:))<0 || max(ColorB_def(:))>1
    ColorB_def = [0.7020 0.77 0.85];
end
EStudio_gui_erp_totl.eegProcess_messg.BackgroundColor = ColorB_def;

% MessageViewer= char(strcat('Editing start time for the displayed EEG'));
% erpworkingmemory('f_EEG_proces_messg',MessageViewer);
Startimes = str2num(EStudio_gui_erp_totl.eeg_zoom_edit.String);
if isempty(Startimes)
    Startimes = 0;
    Source.String = '0';
    MessageViewer= char(strcat('Start time for the displayed EEG should be a number'));
    erpworkingmemory('f_EEG_proces_messg',MessageViewer);
    observe_EEGDAT.eeg_panel_message=4;
end
if numel(Startimes)~=1
    Startimes = Startimes(1);
end


EEG_plotset = estudioworkingmemory('EEG_plotset');
try
    Winlength =   EEG_plotset{3};
catch
    Winlength = 5;
    EEG_plotset{3} = 5;
end
[chaNum,sampleNum,trialNum]=size(observe_EEGDAT.EEG.data);
Frames = sampleNum*trialNum;
if observe_EEGDAT.EEG.trials>1 % time in second or in trials
    multiplier = size(observe_EEGDAT.EEG.data,2);
    multiplier_winleg = size(observe_EEGDAT.EEG.data,2);
else
    multiplier = observe_EEGDAT.EEG.srate;
    multiplier_winleg = observe_EEGDAT.EEG.srate;
end

if isempty(Winlength)|| Winlength<0 ||  (Winlength>floor(Frames/multiplier_winleg))
    Winlength = 5;
    EEG_plotset{3} = 5;
end
estudioworkingmemory('EEG_plotset',EEG_plotset);
if ndims(observe_EEGDAT.EEG.data) ==3
    Startimes = Startimes-1;
end
Startimes = max(0,min(Startimes,ceil((Frames-1)/multiplier)-Winlength));
if ndims(observe_EEGDAT.EEG.data) ==3
    Startimes = Startimes+1;
end
Source.String = num2str(Startimes);


estudioworkingmemory('Startimes',Startimes);
% MessageViewer= char(strcat('Editing start time for the displayed EEG'));
% erpworkingmemory('f_EEG_proces_messg',MessageViewer);
f_redrawEEG_Wave_Viewer();
% observe_EEGDAT.eeg_panel_message=2;
end




%%-------------------% > add one second for displayed EEG------------------
function zoomout_small(~,~)
global observe_EEGDAT;
global EStudio_gui_erp_totl;%%Global variable
% tic;%
% MessageViewer= char(strcat('Increasing start time for the displayed EEG (>)'));
EEG_plotset = estudioworkingmemory('EEG_plotset');
% observe_EEGDAT.eeg_panel_message=1;
try
    Winlength =   EEG_plotset{3};
catch
    Winlength = 5;
    EEG_plotset{3} = 5;
end
if isempty(observe_EEGDAT.EEG)
    return;
end
EStudio_gui_erp_totl.eegProcess_messg.String = '';
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;%%Get background color
catch
    ColorB_def = [0.7020 0.77 0.85];
end
if isempty(ColorB_def) || numel(ColorB_def)~=3 || min(ColorB_def(:))<0 || max(ColorB_def(:))>1
    ColorB_def = [0.7020 0.77 0.85];
end
EStudio_gui_erp_totl.eegProcess_messg.BackgroundColor = ColorB_def;

[chaNum,sampleNum,trialNum]=size(observe_EEGDAT.EEG.data);
Frames = sampleNum*trialNum;
if observe_EEGDAT.EEG.trials>1 % time in second or in trials
    multiplier = size(observe_EEGDAT.EEG.data,2);
    multiplier_winleg = size(observe_EEGDAT.EEG.data,2);
else
    multiplier = observe_EEGDAT.EEG.srate;
    multiplier_winleg = multiplier;
end

if isempty(Winlength)|| Winlength<0 || Winlength>floor(Frames/multiplier_winleg)
    Winlength = 5;
    EEG_plotset{3} = 5;
end
estudioworkingmemory('EEG_plotset',EEG_plotset);
Startimesdef = str2num(EStudio_gui_erp_totl.eeg_zoom_edit.String);
if ~isempty(Startimesdef) && isnumeric(Startimesdef) && numel(Startimesdef)==1 && Startimesdef>=0
else
    Startimesdef = 0;
end

Startimes = Startimesdef+fastif(Winlength>=5, round(Winlength), Winlength); %%> add one second
if Startimes<0
    Startimes=0;
end

EEG_plotset = estudioworkingmemory('EEG_plotset');
try
    Winlength =   EEG_plotset{3};
catch
    Winlength = 5;
    EEG_plotset{3} = 5;
end

if isempty(Winlength)|| Winlength<0 ||  (Winlength>floor(Frames/multiplier_winleg))
    Winlength = floor(Frames/multiplier_winleg);
    EEG_plotset{3} = floor(Frames/multiplier_winleg);
end
estudioworkingmemory('EEG_plotset',EEG_plotset);
StartimesMax = max(0,ceil((Frames-1)/multiplier)-Winlength);
if ndims(observe_EEGDAT.EEG.data)==3
    StartimesMax = StartimesMax+1;
end
if Startimes>StartimesMax
    Startimes=StartimesMax;
end
EStudio_gui_erp_totl.eeg_zoom_edit.String = num2str(Startimes);

estudioworkingmemory('Startimes',Startimes);
% erpworkingmemory('f_EEG_proces_messg',MessageViewer);
f_redrawEEG_Wave_Viewer();
% observe_EEGDAT.eeg_panel_message=2;
% timeElapsed = toc;
% fprintf([32,'It took',32,num2str(timeElapsed),'s plot eeg waves.\n\n']);

end


function zoomout_fivelarge(~,~)
global observe_EEGDAT;
global EStudio_gui_erp_totl;%%Global variable
% MessageViewer= char(strcat('Increasing start time for the displayed EEG (>>)'));
EEG_plotset = estudioworkingmemory('EEG_plotset');
% observe_EEGDAT.eeg_panel_message=1;
try
    Winlength =   EEG_plotset{3};
catch
    Winlength = 5;
    EEG_plotset{3} = 5;
end
if isempty(observe_EEGDAT.EEG)
    return;
end
EStudio_gui_erp_totl.eegProcess_messg.String = '';
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;%%Get background color
catch
    ColorB_def = [0.7020 0.77 0.85];
end
if isempty(ColorB_def) || numel(ColorB_def)~=3 || min(ColorB_def(:))<0 || max(ColorB_def(:))>1
    ColorB_def = [0.7020 0.77 0.85];
end
EStudio_gui_erp_totl.eegProcess_messg.BackgroundColor = ColorB_def;

[chaNum,sampleNum,trialNum]=size(observe_EEGDAT.EEG.data);
Frames = sampleNum*trialNum;
if observe_EEGDAT.EEG.trials>1 % time in second or in trials
    multiplier = size(observe_EEGDAT.EEG.data,2);
    multiplier_winleg = size(observe_EEGDAT.EEG.data,2);
else
    multiplier = observe_EEGDAT.EEG.srate;
    multiplier_winleg = multiplier;
end

if isempty(Winlength)|| Winlength<0 || Winlength>floor(Frames/multiplier_winleg)
    Winlength = 5;
    EEG_plotset{3} = 5;
end
estudioworkingmemory('EEG_plotset',EEG_plotset);
Startimesdef = str2num(EStudio_gui_erp_totl.eeg_zoom_edit.String);
if ~isempty(Startimesdef) && isnumeric(Startimesdef) && numel(Startimesdef)==1 && Startimesdef>=0
else
    Startimesdef = 0;
end

Startimes = Startimesdef+fastif(Winlength>=5, round(5*Winlength), 5*Winlength); %%> add one second
if Startimes<0
    Startimes=0;
end

EEG_plotset = estudioworkingmemory('EEG_plotset');
try
    Winlength =   EEG_plotset{3};
catch
    Winlength = 5;
    EEG_plotset{3} = 5;
end

if isempty(Winlength)|| Winlength<0 ||  (Winlength>floor(Frames/multiplier_winleg))
    Winlength = floor(Frames/multiplier_winleg);
    EEG_plotset{3} = floor(Frames/multiplier_winleg);
end
estudioworkingmemory('EEG_plotset',EEG_plotset);
StartimesMax = max(0,ceil((Frames-1)/multiplier)-Winlength);
if ndims(observe_EEGDAT.EEG.data)==3
    StartimesMax = StartimesMax+1;
end
if Startimes>StartimesMax
    Startimes=StartimesMax;
end
EStudio_gui_erp_totl.eeg_zoom_edit.String = num2str(Startimes);

estudioworkingmemory('Startimes',Startimes);
% erpworkingmemory('f_EEG_proces_messg',MessageViewer);
f_redrawEEG_Wave_Viewer();
% observe_EEGDAT.eeg_panel_message=2;
end




function zoomout_large(~,~)
global observe_EEGDAT;
global EStudio_gui_erp_totl;%%Global variable
if isempty(observe_EEGDAT.EEG)
    return;
end
EStudio_gui_erp_totl.eegProcess_messg.String = '';
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;%%Get background color
catch
    ColorB_def = [0.7020 0.77 0.85];
end
if isempty(ColorB_def) || numel(ColorB_def)~=3 || min(ColorB_def(:))<0 || max(ColorB_def(:))>1
    ColorB_def = [0.7020 0.77 0.85];
end
EStudio_gui_erp_totl.eegProcess_messg.BackgroundColor = ColorB_def;

% MessageViewer= char(strcat('Changing the start time to be maximal (>|)'));
EEG_plotset = estudioworkingmemory('EEG_plotset');
% observe_EEGDAT.eeg_panel_message=1;%%this will slow down the plotting speed
try
    Winlength =   EEG_plotset{3};
catch
    Winlength = 5;
    EEG_plotset{3} = 5;
end
[chaNum,sampleNum,trialNum]=size(observe_EEGDAT.EEG.data);
Frames = sampleNum*trialNum;
if observe_EEGDAT.EEG.trials>1 % time in second or in trials
    multiplier = size(observe_EEGDAT.EEG.data,2);
    multiplier_winleg = size(observe_EEGDAT.EEG.data,2);
else
    multiplier = observe_EEGDAT.EEG.srate;
    multiplier_winleg = multiplier;
end

if isempty(Winlength)|| Winlength<0 ||  (Winlength>floor(Frames/multiplier_winleg))
    Winlength = 5;
    EEG_plotset{3} = 5;
end
estudioworkingmemory('EEG_plotset',EEG_plotset);
StartimesMax = max(0,ceil((Frames-1)/multiplier)-Winlength);
if ndims(observe_EEGDAT.EEG.data)==3
    StartimesMax = StartimesMax+1;
end
Startimes = StartimesMax;


estudioworkingmemory('Startimes',Startimes);
% erpworkingmemory('f_EEG_proces_messg',MessageViewer);

EStudio_gui_erp_totl.eeg_zoom_edit.String =num2str(Startimes);
f_redrawEEG_Wave_Viewer();
% observe_EEGDAT.eeg_panel_message=2;
end


%%-------------------------------Page Editor-------------------------------
function page_edit(Source,~)
global observe_EEGDAT;
% addlistener(observe_EEGDAT,'page_xyaxis',@count_page_xyaxis_change);
if isempty(observe_EEGDAT.EEG)
    return;
end

[messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
if ~isempty(messgStr)
    observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;
end

Pagecurrent = str2num(Source.String);

EEGset_selected = estudioworkingmemory('EEGArray');
if isempty(EEGset_selected)
    EEGset_selected=observe_EEGDAT.CURRENTSET;
    estudioworkingmemory('EEGArray',EEGset_selected);
end

pageNum = numel(EEGset_selected);
if  ~isempty(Pagecurrent) &&  numel(Pagecurrent)~=1 %%if two or more numbers are entered
    Pagecurrent =Pagecurrent(1);
end

if ~isempty(Pagecurrent) && Pagecurrent>0 && Pagecurrent<= pageNum%%
    Source.String = num2str(Pagecurrent);
    observe_EEGDAT.CURRENTSET = EEGset_selected(Pagecurrent);
    observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
    estudioworkingmemory('Startimes',0);
    f_redrawEEG_Wave_Viewer();
    observe_EEGDAT.count_current_eeg=2;
    %      observe_EEGDAT.eeg_panel_message=2;
end
end




%------------------Display the waveform for proir ERPset--------------------
function page_minus(~,~)
global observe_EEGDAT;
global EStudio_gui_erp_totl;
if isempty(observe_EEGDAT.EEG)
    return;
end
%%first check if the changed parameters have been applied in any panels
[messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
if ~isempty(messgStr)
    observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;
end
Pagecurrent = str2num(EStudio_gui_erp_totl.eegpageinfo_edit.String);
EEGset_selected = estudioworkingmemory('EEGArray');
if isempty(EEGset_selected)
    EEGset_selected=observe_EEGDAT.CURRENTSET;
    estudioworkingmemory('EEGArray',EEGset_selected);
end

pageNum = numel(EEGset_selected);
if  ~isempty(Pagecurrent) &&  numel(Pagecurrent)~=1 %%if two or more numbers are entered
    Pagecurrent =Pagecurrent(1);
elseif isempty(Pagecurrent)
    [xpos, ypos] = find(EEGset_selected==observe_EEGDAT.CURRENTSET);
    if isempty(ypos)
        Pagecurrent=1;
        observe_EEGDAT.CURRENTSET = EEGset_selected(1);
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
    else
        Pagecurrent = ypos;
    end
end
Pagecurrent = Pagecurrent-1;
if  Pagecurrent>0 && Pagecurrent<=pageNum
    EStudio_gui_erp_totl.eegpageinfo_edit.String = num2str(Pagecurrent);
    observe_EEGDAT.CURRENTSET = EEGset_selected(Pagecurrent);
    observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
    %     MessageViewer= char(strcat('Plot wave for the previous EEGset'));
    %     erpworkingmemory('f_EEG_proces_messg',MessageViewer);
    %     observe_EEGDAT.eeg_panel_message=1;
    estudioworkingmemory('Startimes',0);
    f_redrawEEG_Wave_Viewer();
    observe_EEGDAT.count_current_eeg=2;
    %     observe_EEGDAT.eeg_panel_message=2;
else
    return;
end
end


%------------------Display the waveform for next ERPset--------------------
function  page_plus(~,~)
global observe_EEGDAT;
global EStudio_gui_erp_totl;
if isempty(observe_EEGDAT.EEG)
    return;
end
%%first check if the changed parameters have been applied in any panels
[messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
if ~isempty(messgStr)
    observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;
end
Pagecurrent = str2num(EStudio_gui_erp_totl.eegpageinfo_edit.String);
EEGset_selected = estudioworkingmemory('EEGArray');
if isempty(EEGset_selected)
    EEGset_selected=observe_EEGDAT.CURRENTSET;
    estudioworkingmemory('EEGArray',EEGset_selected);
end

pageNum = numel(EEGset_selected);
if  ~isempty(Pagecurrent) &&  numel(Pagecurrent)~=1 %%if two or more numbers are entered
    Pagecurrent =Pagecurrent(1);
elseif isempty(Pagecurrent)
    [xpos, ypos] = find(EEGset_selected==observe_EEGDAT.CURRENTSET);
    if isempty(ypos)
        Pagecurrent=1;
        observe_EEGDAT.CURRENTSET = EEGset_selected(1);
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
        observe_EEGDAT.count_current_eeg =2;
        f_redrawEEG_Wave_Viewer();
        return;
    else
        Pagecurrent = ypos;
    end
end
Pagecurrent = Pagecurrent+1;
if  Pagecurrent>0 && Pagecurrent<=pageNum
    EStudio_gui_erp_totl.eegpageinfo_edit.String = num2str(Pagecurrent);
    observe_EEGDAT.CURRENTSET = EEGset_selected(Pagecurrent);
    observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
    %     MessageViewer= char(strcat('Plot wave for the next EEGset'));
    %     erpworkingmemory('f_EEG_proces_messg',MessageViewer);
    %     observe_EEGDAT.eeg_panel_message=1;
    estudioworkingmemory('Startimes',0);
    f_redrawEEG_Wave_Viewer();
    observe_EEGDAT.count_current_eeg=2;
    %     observe_EEGDAT.eeg_panel_message=2;
else
    return;
end
end





function Show_command(~,~)
global observe_EEGDAT;
if isempty(observe_EEGDAT.EEG)
    return;
end
%%first check if the changed parameters have been applied in any panels
[messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
if ~isempty(messgStr)
    observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;
end
MessageViewer= char(strcat('Show Command'));
erpworkingmemory('f_EEG_proces_messg',MessageViewer);
try
    observe_EEGDAT.eeg_panel_message=1;
    OutputViewereegpar = f_preparms_eegwaviewer(observe_EEGDAT.EEG,1,'command');
    observe_EEGDAT.eeg_panel_message=2;
catch
    observe_EEGDAT.eeg_panel_message=3;
end
end



%%-------------------------Save figure as----------------------------------
function figure_saveas(~,~)
global observe_EEGDAT;
% addlistener(observe_EEGDAT,'Messg_EEG_change',@Messg_EEG_change);
if isempty(observe_EEGDAT.EEG)
    return;
end

%%first check if the changed parameters have been applied in any panels
[messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
if ~isempty(messgStr)
    observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;
end
MessageViewer= char(strcat('Save Figure As'));
erpworkingmemory('f_EEG_proces_messg',MessageViewer);

pathstr = pwd;
[~, namedef, ~] = fileparts(observe_EEGDAT.EEG.setname);
[figurename, erppathname, indxs] = uiputfile({'*.pdf';'*.svg';'*.jpg';'*.png';'*.tif';'*.bmp';'*.eps'},...
    'Save as',[fullfile(pathstr,namedef)]);

if isequal(figurename,0)
    %     observe_EEGDAT.eeg_panel_message=3;
    return
end

History = 'off';
[pathstr, figurename1, ext] = fileparts(figurename) ;

if isempty(ext)
    figurename = fullfile(erppathname,char(strcat(figurename,'.pdf')));
else
    figurename = fullfile(erppathname,figurename);
end

observe_EEGDAT.eeg_panel_message=1;
OutputViewereegpar = f_preparms_eegwaviewer(observe_EEGDAT.EEG,1,History,figurename);
observe_EEGDAT.eeg_panel_message=2;

end


%%------------------------Reset parameters---------------------------------
function eeg_paras_reset(~,~)
global observe_EEGDAT;
global observe_ERPDAT;
global EStudio_gui_erp_totl;

erpworkingmemory('EEGUpdate',0);
observe_EEGDAT.count_current_eeg =1;

erpworkingmemory('ViewerFlag', 0);
observe_ERPDAT.Count_currentERP=1;

%%first check if the changed parameters have been applied in any panels
[messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
if ~isempty(messgStr)
    observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;
end

erpworkingmemory('f_EEG_proces_messg','Reset parameters for EEG panels');
app = feval('estudio_reset_paras',[1 0 0 0]);
waitfor(app,'Finishbutton',1);
reset_paras = [0 0 0 0];
try
    reset_paras = app.output; %NO you don't want to output EEG with edited channel locations, you want to output the parameters to run decoding
    app.delete; %delete app from view
    pause(0.1); %wait for app to leave
catch
    return;
end
if isempty(reset_paras)
    return;
end
EStudio_gui_erp_totl.ERP_autoplot=1;
EStudio_gui_erp_totl.EEG_autoplot = 1;

observe_EEGDAT.eeg_panel_message=1;
if reset_paras(2)==1
    EStudio_gui_erp_totl.clear_alleeg = 1;
else
    EStudio_gui_erp_totl.clear_alleeg = 0;
end

if reset_paras(1)==1
    observe_EEGDAT.Reset_eeg_paras_panel=1;
    if EStudio_gui_erp_totl.clear_alleeg == 0
        f_redrawEEG_Wave_Viewer();
    else
        observe_EEGDAT.ALLEEG = [];
        observe_EEGDAT.EEG = [];
        observe_EEGDAT.CURRENTSET  = 0;
        estudioworkingmemory('EEGArray',1);
        observe_EEGDAT.count_current_eeg =1;
    end
else
    if EStudio_gui_erp_totl.clear_alleeg == 1
        observe_EEGDAT.ALLEEG = [];
        observe_EEGDAT.EEG = [];
        observe_EEGDAT.CURRENTSET  = 0;
        estudioworkingmemory('EEGArray',1);
        observe_EEGDAT.count_current_eeg =1;
    end
end
observe_EEGDAT.eeg_panel_message=2;
%%---------------- -------------erp tab------------------------------------
if reset_paras(4)==1
    EStudio_gui_erp_totl.clear_allerp = 1;
else
    EStudio_gui_erp_totl.clear_allerp = 0;
end

if reset_paras(3)==1
    observe_ERPDAT.Reset_erp_paras_panel = 1;
    if EStudio_gui_erp_totl.clear_allerp == 0
        f_redrawERP();
    else
        observe_ERPDAT.ALLERP = [];
        observe_ERPDAT.ERP = [];
        observe_ERPDAT.CURRENTERP  = 1;
        estudioworkingmemory('selectederpstudio',1);
        observe_ERPDAT.Count_currentERP = 1;
    end
else
    if EStudio_gui_erp_totl.clear_allerp == 1
        
        observe_ERPDAT.ALLERP = [];
        observe_ERPDAT.ERP = [];
        observe_ERPDAT.CURRENTERP  = 1;
        estudioworkingmemory('selectederpstudio',1);
        observe_ERPDAT.Count_currentERP = 1;
    end
end

end



%%-----------------Pop figure---------------------------------------------
function figure_out(~,~)
global observe_EEGDAT;

if isempty(observe_EEGDAT.EEG)
    return;
end

%%first check if the changed parameters have been applied in any panels
[messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
if ~isempty(messgStr)
    observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;
end


MessageViewer= char(strcat('Create Static/Exportable Plot'));
erpworkingmemory('f_EEG_proces_messg',MessageViewer);
try
    figurename = observe_EEGDAT.EEG.setname;
catch
    figurename = '';
end
History = 'off';
observe_EEGDAT.eeg_panel_message=1;
OutputViewereegpar = f_preparms_eegwaviewer(observe_EEGDAT.EEG,1,History,figurename);
observe_EEGDAT.eeg_panel_message=2;
end


% %%------------------------Message panel------------------------------------
function eeg_panel_change_message(~,~)
global observe_EEGDAT;
global EStudio_gui_erp_totl;
% addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);

if isempty(observe_EEGDAT.EEG) || isempty(observe_EEGDAT.ALLEEG)
    return;
end
FonsizeDefault = f_get_default_fontsize();
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;%%Get background color
catch
    ColorB_def = [0.7020 0.77 0.85];
end
if isempty(ColorB_def) || numel(ColorB_def)~=3 || min(ColorB_def(:))<0 || max(ColorB_def(:))>1
    ColorB_def = [0.7020 0.77 0.85];
end
Processed_Method=erpworkingmemory('f_EEG_proces_messg');
EEGMessagepre = erpworkingmemory('f_EEG_proces_messg_pre');
if isempty(EEGMessagepre)
    EEGMessagepre = {'',0};
end
try
    if strcmpi(EEGMessagepre{1},Processed_Method) && observe_EEGDAT.eeg_panel_message == EEGMessagepre{2}
        return;
    end
catch
end
erpworkingmemory('f_EEG_proces_messg_pre',{Processed_Method,observe_EEGDAT.eeg_panel_message});

%%Update the current EEGset after Inspect/label IC and update artifact marks
eegicinspectFlag = erpworkingmemory('eegicinspectFlag');
% if ~isempty(eegicinspectFlag)  && (eegicinspectFlag==1 || eegicinspectFlag==2)
%     EEGArray =  estudioworkingmemory('EEGArray');
%     if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
%         EEGArray = observe_EEGDAT.CURRENTSET;
%     end
%     if numel(EEGArray) ==1
%         %%set a reminder that can give the users second chance to update
%         %%current EEGset
%         if  eegicinspectFlag==1
%             question = ['We strongly recommend your to label ICs before any further analyses. Otherwise, there may be some bugs.\n\n',...
%                 'Have you Labelled ICs? \n\n',...
%                 'Please select "No" if you didnot. \n\n'];
%             title       = 'EStudio: Label ICs';
%         end
%
%         BackERPLABcolor = [1 0.9 0.3];
%         oldcolor = get(0,'DefaultUicontrolBackgroundColor');
%         set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
%         button      = questdlg(sprintf(question,''), title,'No','Yes','Yes');
%         set(0,'DefaultUicontrolBackgroundColor',[1 1 1]);
%         if isempty(button) ||   strcmpi(button,'No')
%             erpworkingmemory('eegicinspectFlag',0);
%             return;
%         end
%         %%close the figures for inspect/label ICs or artifact detection for
%         %%epoched eeg (preview)
%         try
%             for Numofig = 1:1000
%                 fig = gcf;
%                 if strcmpi(fig.Tag,'EEGPLOT') || strcmpi(fig.Tag(1:7),'selcomp')
%                     close(fig.Name);
%                 else
%                     break;
%                 end
%             end
%         catch
%         end
%         try
%             observe_EEGDAT.ALLEEG(EEGArray) = evalin('base','EEG');
%             observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(EEGArray);
%             erpworkingmemory('eegicinspectFlag',0);
%             observe_EEGDAT.count_current_eeg=1;
%         catch
%             erpworkingmemory('eegicinspectFlag',0);
%         end
%     end
% end
if eegicinspectFlag~=0
    return;
end

EStudio_gui_erp_totl.eegProcess_messg.BackgroundColor = [0.95 0.95 0.95];
EStudio_gui_erp_totl.eegProcess_messg.FontSize = FonsizeDefault;

if observe_EEGDAT.eeg_panel_message==1
    EStudio_gui_erp_totl.eegProcess_messg.String =  strcat('1- ',Processed_Method,': Running....');
    EStudio_gui_erp_totl.eegProcess_messg.ForegroundColor = [0 0 0];
    pause(0.1);
elseif observe_EEGDAT.eeg_panel_message==2
    EStudio_gui_erp_totl.eegProcess_messg.String =  strcat('2- ',Processed_Method,': Complete');
    EStudio_gui_erp_totl.eegProcess_messg.ForegroundColor = [0 0.5 0];
    pause(0.1);
elseif observe_EEGDAT.eeg_panel_message==3
    if ~strcmp(EStudio_gui_erp_totl.eegProcess_messg.String,strcat('3- ',Processed_Method,': Error (see Command Window)'))
        fprintf([Processed_Method,32,32,32,datestr(datetime('now')),'\n.']);
    end
    EStudio_gui_erp_totl.eegProcess_messg.String =  strcat('3- ',Processed_Method,': Error (see Command Window)');
    EStudio_gui_erp_totl.eegProcess_messg.ForegroundColor = [1 0 0];
else
    if ~strcmpi(EStudio_gui_erp_totl.eegProcess_messg.String,strcat('Warning:',32,Processed_Method,32,'(see Command Window).'))
        fprintf([Processed_Method,32,32,32,datestr(datetime('now')),'\n.']);
    end
    EStudio_gui_erp_totl.eegProcess_messg.String =  strcat('Warning:',32,Processed_Method,32,'(see Command Window).');
    
    pause(0.1);
    EStudio_gui_erp_totl.eegProcess_messg.ForegroundColor = [1 0.65 0];
end
if  observe_EEGDAT.eeg_panel_message==2 || observe_EEGDAT.eeg_panel_message==3
    pause(0.01);
    EStudio_gui_erp_totl.eegProcess_messg.String = '';
    EStudio_gui_erp_totl.eegProcess_messg.BackgroundColor = ColorB_def;%[0.95 0.95 0.95];
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%-------------------------------Plot eeg waves--------------------------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [EStudio_gui_erp_totl,errmeg] = f_plotviewereegwave(EEG,ChanArray,ICArray,EEGdispFlag,ICdispFlag,Winlength,...
    AmpScale,ChanLabel,Submean,EventOnset,StackFlag,NormFlag,Startimes,AmpIC,bufftobo,EStudio_gui_erp_totl)


EStudio_gui_erp_totl.myeegviewer = axes('Parent', EStudio_gui_erp_totl.eegViewAxes,'Color','none','Box','on','FontWeight','normal');
hold(EStudio_gui_erp_totl.myeegviewer,'on');
Pos = EStudio_gui_erp_totl.myeegviewer.Position;
EStudio_gui_erp_totl.myeegviewer.Position = [Pos(1)*0.5,Pos(2)*0.5,Pos(3)*1.15,Pos(4)*1.05];%%x,y,width,height
estudioworkingmemory('egfigsize',[EStudio_gui_erp_totl.myeegviewer.Position(3),EStudio_gui_erp_totl.myeegviewer.Position(4)]);
myeegviewer = EStudio_gui_erp_totl.myeegviewer;


errmeg = [];
if nargin<1
    help f_plotviewereegwave;
    return
end

if isempty(EEG)
    errmeg  = 'EEG is empty';
    return;
end


%%selected channels
nbchan = EEG.nbchan;
if nargin<2
    ChanArray = 1:nbchan;
end
if isempty(ChanArray) || min(ChanArray(:)) >nbchan || max(ChanArray(:))> nbchan||  min(ChanArray(:))<=0
    ChanArray = 1:nbchan;
end

%%selected ICs
if nargin<3
    ICArray = [];
end
if isempty(EEG.icachansind)
    ICArray = [];
else
    nIC = numel(EEG.icachansind);
    if isempty(ICArray) || min(ICArray(:))>nIC || max(ICArray(:)) >  nIC ||  min(ICArray(:))<=0
        ICArray = 1:nIC;
    end
end

%%display EEG?
if nargin<4
    EEGdispFlag=1;
end
if isempty(EEGdispFlag) || (EEGdispFlag~=0 && EEGdispFlag~=1)
    EEGdispFlag = 1;
end

%%Dispaly ICs?
if nargin<5
    ICdispFlag=0;
end
if isempty(ICdispFlag) || (ICdispFlag~=0 && ICdispFlag~=1)
    ICdispFlag = 0;
end
if ICdispFlag==0
    ICArray = [];
end

%%Time range that is to display (1s or 5s)?
if nargin<6
    Winlength=5;
end
if isempty(Winlength) || numel(Winlength)~=1 || min(Winlength(:))<=0
    Winlength=5;
end

%%Vertical scale?
if nargin<7
    AmpScale = 50;
end
if isempty(AmpScale) || numel(AmpScale)~=1 || AmpScale<=0
    AmpScale = 50;
end
OldAmpScale = AmpScale;

%%channe labels (name or number)
if nargin<8
    ChanLabel = 1;
end
if isempty(ChanLabel) || numel(ChanLabel)~=1 || (ChanLabel~=0 && ChanLabel~=1)
    ChanLabel = 1;
end

%%remove DC?
if nargin<9
    Submean = 0;
end
if isempty(Submean) || numel(Submean)~=1 || (Submean~=0 && Submean~=1)
    Submean = 1;
end


%%Display events?
if nargin<10
    EventOnset = 1;
end
if isempty(EventOnset) ||  numel(EventOnset)~=1 || (EventOnset~=0 && EventOnset~=1)
    EventOnset = 1;
end


%%Stack?
if nargin<11
    StackFlag = 0;
end
if isempty(StackFlag) || numel(StackFlag)~=1 || (StackFlag~=0&&StackFlag~=1)
    StackFlag = 0;
end

%%Norm?
if nargin<12
    NormFlag = 0;
end
if isempty(NormFlag) ||numel(NormFlag)~=1 || (NormFlag~=0 && NormFlag~=1)
    NormFlag = 0;
end

% Startimes =20;
%%start time for the displayed data
if nargin < 13
    if ndims(EEG.data) ==3
        Startimes=1;
    else
        Startimes=0;
    end
end

%%VERTICAL SCALE for ICs
if nargin<14
    AmpIC = 20;
end

if isempty(AmpIC) || numel(AmpIC)~=1 || AmpIC<=0
    AmpIC = 20;
end
OldAmpIC = AmpIC;

%%buffer at top and bottom
if nargin<15
    bufftobo = 100;
end
if isempty(bufftobo) || numel(bufftobo)~=1 || any(bufftobo(:)<=0)
    bufftobo = 100;
end


[ChanNum,Allsamples,tmpnb] = size(EEG.data);
Allsamples = Allsamples*tmpnb;
if ndims(EEG.data) > 2
    multiplier = size(EEG.data,2);
else
    multiplier = EEG.srate;
end

if isempty(Startimes) || Startimes<0 ||  Startimes>(ceil((Allsamples-1)/multiplier)-Winlength)
    if ndims(EEG.data) ==3
        Startimes=1;
    else
        Startimes=0;
    end
end

%%determine the time range that will be dispalyed
lowlim = round(Startimes*multiplier+1);
highlim = round(min((Startimes+Winlength)*multiplier+1,Allsamples));


%%--------------------prepare event array if any --------------------------
Events = EEG.event;
if ~isempty(Events)
    if ~isfield(Events, 'type') || ~isfield(Events, 'latency'), Events = []; end
end
if ~isempty(Events)
    if ischar(Events(1).type)
        [Eventtypes tmpind indexcolor] = unique_bc({Events.type}); % indexcolor countinas the event type
    else [Eventtypes tmpind indexcolor] = unique_bc([ Events.type ]);
    end
    Eventcolors     = { 'r', [0 0.8 0], 'm', 'c', 'k', 'b', [0 0.8 0] };
    Eventstyle      = { '-' '-' '-'  '-'  '-' '-' '-' '--' '--' '--'  '--' '--' '--' '--'};
    Eventwidths     = [ 2.5 1 ];
    Eventtypecolors = Eventcolors(mod([1:length(Eventtypes)]-1 ,length(Eventcolors))+1);
    Eventcolors     = Eventcolors(mod(indexcolor-1               ,length(Eventcolors))+1);
    Eventtypestyle  = Eventstyle (mod([1:length(Eventtypes)]-1 ,length(Eventstyle))+1);
    Eventstyle      = Eventstyle (mod(indexcolor-1               ,length(Eventstyle))+1);
    
    % for width, only boundary events have width 2 (for the line)
    % -----------------------------------------------------------
    indexwidth = ones(1,length(Eventtypes))*2;
    if iscell(Eventtypes)
        for index = 1:length(Eventtypes)
            if strcmpi(Eventtypes{index}, 'boundary'), indexwidth(index) = 1; end
        end
    else
    end
    Eventtypewidths = Eventwidths (mod(indexwidth([1:length(Eventtypes)])-1 ,length(Eventwidths))+1);
    Eventwidths     = Eventwidths (mod(indexwidth(indexcolor)-1               ,length(Eventwidths))+1);
    
    % latency and duration of events
    % ------------------------------
    Eventlatencies  = [ Events.latency ]+1;
    if isfield(Events, 'duration')
        durations = { Events.duration };
        durations(cellfun(@isempty, durations)) = { NaN };
        Eventlatencyend   = Eventlatencies + [durations{:}]+1;
    else Eventlatencyend   = [];
    end
    %     EventOnset       = 1;
end

if isempty(Events)
    EventOnset  = 0;
end

chanNum = numel(ChanArray);


%%-------------------------------IC and original data----------------------
dataica = [];chaNum=0;
if ~isempty(EEG.icaweights) && ~isempty(ICArray)%%pop_eegplot from eeglab
    tmpdata = eeg_getdatact(EEG, 'component', [1:size(EEG.icaweights,1)]);
    try
        dataica = tmpdata(ICArray,:);
    catch
        dataica = tmpdata(:,:);
        ICArray = [1:size(tmpdata,1)];
    end
end

if EEGdispFlag==1
    dataeeg = EEG.data(ChanArray,:);
    chaNum = numel(ChanArray);
else
    dataeeg =[];
    chaNum = 0;
end

%%---------------------------Normalize-------------------------------------
if NormFlag==1
    %%Norm for origanal
    %     data2 = [];
    if ~isempty(dataeeg)
        datastd = std(dataeeg(:,1:min(1000,Allsamples)),[],2);%
        for i = 1:size(dataeeg,1)
            dataeeg(i,:,:) = dataeeg(i,:,:)/datastd(i);
            %             if ~isempty(data2)
            %                 data2(i,:,:) = data2(i,:,:)*datastd(i);
            %             end
        end
    end
    
    %%norm for IC data
    if ~isempty(dataica)
        dataicstd = std(dataica(:,1:min(1000,Allsamples)),[],2);
        for i = 1:size(dataica,1)
            dataica(i,:,:) = dataica(i,:,:)/dataicstd(i);
            %        if ~isempty(data2)
            %            data2(i,:,:) = data2(i,:,:)*dataicstd(i);
            %        end
        end
    end
end

% Removing DC for IC data?
% -------------------------
meandataica =[];ICNum=0;
if ICdispFlag==1
    if ~isempty(EEG.icaweights) && ~isempty(ICArray) && ~isempty(dataica)%%pop_eegplot from eeglab
        switch Submean % subtract the mean ?
            case 1
                meandataica = mean(dataica(:,lowlim:highlim)');
                if any(isnan(meandataica))
                    meandataica = nan_mean(dataica(:,lowlim:highlim)');
                end
            otherwise, meandataica = zeros(1,numel(ICArray));
        end
    end
    ICNum = numel(ICArray);
else
    ICNum = 0;
end

% Removing DC for original data?
% -------------------------
meandata = [];
if EEGdispFlag==1 && ~isempty(dataeeg)
    switch Submean % subtract the mean ?
        case 1
            meandata = mean(dataeeg(:,lowlim:highlim)');
            if any(isnan(meandata))
                meandata = nan_mean(dataeeg(:,lowlim:highlim)');
            end
        otherwise, meandata = zeros(1,numel(ChanArray));
    end
end


PlotNum = chaNum+ICNum;
if chaNum==0 && ICNum==0
    Ampscold = 0*[1:PlotNum]';
    if StackFlag==1
        Ampsc = 0*[1:PlotNum]';
    else
        Ampsc = Ampscold;
    end
    AmpScaleold = 0;
    ylims = [0 (PlotNum+1)*AmpScale];
    data = [dataeeg;dataica];
    meandata = [meandata,meandataica];
elseif ICNum==0 && chaNum~=0
    Ampscold = AmpScale*[1:PlotNum]';
    if  StackFlag==1
        Ampsc = ((Ampscold(end)+AmpScale)/2)*ones(1,PlotNum)';
    else
        Ampsc = Ampscold;
    end
    AmpScaleold = AmpScale;
    ylims = [AmpScale*(100-bufftobo)/100 PlotNum*AmpScale+AmpScale*bufftobo/100];
    data = [dataeeg;dataica];
    meandata = [meandata,meandataica];
elseif ICNum~=0 && chaNum==0
    Ampscold = AmpIC*[1:PlotNum]';
    if  StackFlag==1
        Ampsc = ((Ampscold(end)+AmpIC)/2)*ones(1,PlotNum)';
    else
        Ampsc = Ampscold;
    end
    ylims = [AmpIC*(100-bufftobo)/100 PlotNum*AmpIC+AmpIC*bufftobo/100];
    AmpScaleold = AmpIC;
    data = [dataeeg;dataica];
    meandata = [meandata,meandataica];
    AmpICNew = AmpIC;
elseif ICNum~=0 && chaNum~=0
    AmpICNew = (AmpScale*chaNum+AmpScale/2)/ICNum;
    Ampscold1 = AmpICNew*[1:ICNum]';
    Ampscold2 = Ampscold1(end)+AmpScale/2+AmpScale*[1:chaNum]';
    Ampscold = [Ampscold1;Ampscold2];
    if  StackFlag==1
        Ampsc = [(Ampscold1(end)/2)*ones(ICNum,1);((Ampscold2(end)+AmpScale+Ampscold2(1)+AmpIC)/2)*ones(chaNum,1)];
    else
        Ampsc = Ampscold;
    end
    AmpScaleold = AmpScale;
    ylims = [AmpICNew*(100-bufftobo)/100 Ampscold(end)+AmpScale*bufftobo/100];
    data = [dataeeg;(AmpICNew/AmpIC)*dataica];
    meandata = [meandata,(AmpICNew/AmpIC)*meandataica];
end


Colorgbwave = [];
%%set the wave color for each channel
if ~isempty(data)
    ColorNamergb = roundn([255 0 7;186 85 255;255 192 0;0 238 237;0 78 255;0 197 0]/255,-3);
    Colorgb_chan = [];
    if ~isempty(dataeeg)
        chanNum = numel(ChanArray);
        if chanNum<=6
            Colorgb_chan = ColorNamergb(1:chanNum,:);
        else
            jj = floor(chanNum/6);
            Colorgb_chan = [];
            for ii = 1:jj
                Colorgb_chan = [Colorgb_chan; ColorNamergb];
            end
            if jj*6~=chanNum
                Colorgb_chan = [Colorgb_chan; ColorNamergb(1:chanNum-jj*6,:)];
            end
        end
    end
    
    %%colors for ICs
    %     Coloricrgb = roundn([211,211,211;169,169,16;128,128,128]/255,-3);
    Coloricrgb = roundn([180 0 0;127 68 127;228 88 44;15 175 175;0 0 0;9 158 74]/255,-3);
    Colorgb_IC = [];
    if ~isempty(ICArray)
        ICNum = numel(ICArray);
        if ICNum<7
            Colorgb_IC = Coloricrgb(1:ICNum,:);
        else
            jj = floor(ICNum/6);
            for ii = 1:jj
                Colorgb_IC = [Colorgb_IC; Coloricrgb];
            end
            
            if jj*6~=ICNum
                Colorgb_IC = [Colorgb_IC; Coloricrgb(1:ICNum-jj*6,:)];
            end
            
        end
    end
    Colorgbwave = [Colorgb_chan;Colorgb_IC];
end


PlotNum =0;
if ICdispFlag==1 && EEGdispFlag==1
    if ~isempty(EEG.icaweights) && ~isempty(ICArray)
        PlotNum = chanNum +numel(ICArray);
    else
        PlotNum = chanNum;
    end
elseif ICdispFlag==0 && EEGdispFlag==1
    PlotNum = chanNum;
elseif ICdispFlag==1 && EEGdispFlag==0
    if ~isempty(EEG.icaweights) && ~isempty(ICArray)
        PlotNum =  numel(ICArray);
    end
end
%%
EventOnsetdur =1;
Trialstag = size(EEG.data,2);
GapSize = ceil(numel([lowlim:highlim])/40);
if GapSize<=2
    GapSize=5;
end
% -------------------------------------------------------------------------
% -------------------------draw events if any------------------------------
% -------------------------------------------------------------------------
% ylims = [0 (PlotNum+1)*AmpScale];

FonsizeDefault = f_get_default_fontsize();
if isempty(FonsizeDefault) || numel(FonsizeDefault)~=1|| any(FonsizeDefault(:)<=0)
    FonsizeDefault=10;
end

if EventOnset==1 && ~isempty(data) && PlotNum~=0
    MAXEVENTSTRING = 75;
    if MAXEVENTSTRING<0
        MAXEVENTSTRING = 0;
    elseif MAXEVENTSTRING>75
        MAXEVENTSTRING=75;
    end
    %     AXES_POSITION = [0.0964286 0.15 0.842 0.75-(MAXEVENTSTRING-5)/100];
    %
    
    % find event to plot
    % ------------------
    event2plot    = find ( Eventlatencies >=lowlim & Eventlatencies <= highlim );
    if ~isempty(Eventlatencyend)
        event2plot2 = find ( Eventlatencyend >= lowlim & Eventlatencyend <= highlim );
        event2plot3 = find ( Eventlatencies  <  lowlim & Eventlatencyend >  highlim );
        event2plot  = setdiff(union(event2plot, event2plot2), event2plot3);
    end
    for index = 1:length(event2plot)
        %Just repeat for the first one
        if index == 1
            EVENTFONT = [' \fontsize{',num2str(FonsizeDefault),'} '];
        end
        
        % draw latency line
        % -----------------
        if ndims(EEG.data)==2
            tmplat = Eventlatencies(event2plot(index))-lowlim-1;
        else
            % -----------------
            tmptaglat = [lowlim:highlim];
            tmpind = find(mod(tmptaglat-1,Trialstag) == 0);
            tmpind = setdiff(tmpind,[1,numel(tmptaglat)]);
            alltaglat = setdiff(tmptaglat(tmpind),[1,tmptaglat(end)]);
            %%add gap between epochs if any
            if ~isempty(tmpind) && ~isempty(alltaglat) %%two or multiple epochs were displayed
                if length(alltaglat)==1
                    if Eventlatencies(event2plot(index)) >= alltaglat
                        Singlat = Eventlatencies(event2plot(index))+GapSize;
                    else
                        Singlat = Eventlatencies(event2plot(index));
                    end
                else
                    if  Eventlatencies(event2plot(index)) < alltaglat(1)%%check the first epoch
                        Singlat = Eventlatencies(event2plot(index));
                    else%%the other epochs
                        for ii  = 2:length(alltaglat)
                            if Eventlatencies(event2plot(index)) >= alltaglat(ii-1) && Eventlatencies(event2plot(index)) < alltaglat(ii)
                                Singlat = Eventlatencies(event2plot(index))+GapSize*(ii-1);
                                break;
                            elseif Eventlatencies(event2plot(index)) >= alltaglat(end)  %%check the last epoch
                                Singlat = Eventlatencies(event2plot(index))+GapSize*length(alltaglat);
                                break;
                            end
                        end
                    end
                end
                tmplat = Singlat-lowlim;%%adjust the latency if any
            else%%within one epoch
                tmplat = Eventlatencies(event2plot(index))-lowlim;%-1;
            end
        end
        tmph   = plot(myeegviewer, [ tmplat tmplat ], ylims, 'color', Eventcolors{ event2plot(index) }, ...
            'linestyle', Eventstyle { event2plot(index) }, ...
            'linewidth', Eventwidths( event2plot(index) ) );
        
        % schtefan: add Event types text above event latency line
        % -------------------------------------------------------
        evntxt = strrep(num2str(Events(event2plot(index)).type),'_','-');
        if length(evntxt)>MAXEVENTSTRING, evntxt = [ evntxt(1:MAXEVENTSTRING-1) '...' ]; end % truncate
        try,
            tmph2 = text(myeegviewer, [tmplat], ylims(2)-0.005, [EVENTFONT evntxt], ...
                'color', Eventcolors{ event2plot(index) }, ...
                'horizontalalignment', 'left',...
                'rotation',90,'FontSize',FonsizeDefault);
        catch, end
        
        % draw duration is not 0
        % ----------------------
        %         if EventOnsetdur && ~isempty(Eventlatencyend) ...
        %                 && Eventwidths( event2plot(index) ) ~= 2.5 % do not plot length of boundary events
        %             tmplatend = Eventlatencyend(event2plot(index))-lowlim-1;
        %             if tmplatend ~= 0
        %                 tmplim = ylims;
        %                 tmpcol = Eventcolors{ event2plot(index) };
        %                 h = patch(myeegviewer, [ tmplat tmplatend tmplatend tmplat ], ...
        %                     [ tmplim(1) tmplim(1) tmplim(2) tmplim(2) ], ...
        %                     tmpcol );  % this argument is color
        %                 set(h, 'EdgeColor', 'none')
        %             end
        %         end
    end
else % JavierLC
    MAXEVENTSTRING = 10; % default
    %     AXES_POSITION = [0.0964286 0.15 0.842 0.75-(MAXEVENTSTRING-5)/100];
end


DEFAULT_GRID_SPACING =Winlength/5;

% if StackFlag==1
%     AmpScale=0;
% end

% Ampsc = AmpScale*[1:PlotNum]';
% -------------------------------------------------------------------------
% -----------------draw EEG wave if any------------------------------------
% -------------------------------------------------------------------------
leftintv = [];
%%Plot continuous EEG
tmpcolor = [ 0 0 0.4 ];
if ndims(EEG.data)==2
    if ~isempty(data) && PlotNum~=0
        
        for ii = size(data,1):-1:1
            try
                plot(myeegviewer, (data(ii,lowlim:highlim)+ Ampsc(size(data,1)-ii+1)-meandata(ii))' , ...
                    'color', Colorgbwave(ii,:), 'clipping','on','LineWidth',0.75);%%
            catch
                plot(myeegviewer, (data(ii,lowlim:highlim)+ Ampsc(size(data,1)-ii+1)-meandata(ii))', ...
                    'color', tmpcolor, 'clipping','on','LineWidth',0.75);%%
            end
        end
        set(myeegviewer,'TickDir', 'in','LineWidth',1);
        %%xtick
        set(myeegviewer, 'Xlim',[1 Winlength*multiplier+1],...
            'XTick',[1:multiplier*DEFAULT_GRID_SPACING:Winlength*multiplier+1]);
        set(myeegviewer, 'XTickLabel', num2str((Startimes:DEFAULT_GRID_SPACING:Startimes+Winlength)'));
        
        %%
        %%-----------------plot scale------------------
        leftintv = Winlength*multiplier+1;
    else
        set(myeegviewer, 'XTick', [], 'YTick', [],'Box','off', 'Color','none','xcolor','none','ycolor','none');
    end
end

%%------------------------------plot single-trial EEG----------------------
%%Thanks for the eeglab developers so that we can borrow their codes
isfreq = 0;
Limits = [EEG.times(1),EEG.times(end)];
Srate = EEG.srate;
Freqlimits = [];
if EEG.trials>1
    if ~isempty(data) && PlotNum~=0
        % plot trial limits
        % -----------------
        tmptag = [lowlim:highlim];
        tmpind = find(mod(tmptag-1,Trialstag) == 0);
        %         for index = tmpind
        %             plot(ax0, [tmptag(index)-lowlim tmptag(index)-lowlim], [0 1], 'b--');
        %         end
        alltag = tmptag(tmpind);
        if isempty(tmpind)
            epochNum = 0;
        else
            epochNum = numel(setdiff(tmpind,[0 1 numel(tmptag)]));
        end
        % compute epoch number
        % --------------
        alltag1 = alltag;
        if ~isempty(tmpind)
            tagnum = (alltag1-1)/Trialstag+1;
            for ii = 1:numel(tmpind)
                alltag1(ii)  = alltag1(ii)+(ii-1)*GapSize;
            end
            for ii = 1:numel(tagnum)
                text(myeegviewer, [alltag1(ii)-lowlim+Trialstag/2],ylims(2)+1.1, [32,num2str(tagnum(ii))], ...
                    'color', 'k','FontSize',FonsizeDefault, ...
                    'horizontalalignment', 'left','rotation',90); %%
                set(myeegviewer,'Xlim',[1 (Winlength*multiplier+epochNum*GapSize)]);
            end
        end
        
        %%add the gap between epochs if any
        Epochintv = [];
        
        if ~isempty(tmpind)
            if (numel(tmpind)==1 && tmpind(end) == numel(tmptag)) || (numel(tmpind)==1 && tmpind(1) == 1)
                dataplot =   data(:,lowlim:highlim);
                Epochintv(1,1) =1;
                Epochintv(1,2) =numel(lowlim:highlim);
            else
                tmpind = unique(setdiff([0,tmpind, numel(tmptag)],1));
                dataplotold =    data(:,lowlim:highlim);
                dataplot_new = [];
                for ii = 2:numel(tmpind)
                    GapLeft = tmpind(ii-1)+1;
                    GapRight = tmpind(ii);
                    if GapLeft<1
                        GapLeft =1;
                    end
                    if GapRight > numel(tmptag)
                        GapRight =  numel(tmptag);
                    end
                    dataplot_new = [dataplot_new,dataplotold(:,GapLeft:GapRight),nan(size(dataplotold,1),GapSize)];
                    Epochintv(ii-1,1) = GapLeft+(ii-2)*GapSize;
                    Epochintv(ii-1,2) = GapRight+(ii-2)*GapSize;
                end
                if ~isempty(dataplot_new)
                    dataplot = dataplot_new;
                else
                    dataplot = dataplotold;
                end
            end
        end
        
        %%-----------plot background color for trias with artifact---------
        %%highlight waves with labels
        Value_adjust = floor(Startimes+1);
        if Value_adjust<1
            Value_adjust=1;
        end
        tagnum  = unique([Value_adjust,tagnum]);
        
        try trialsMakrs = EEG.reject.rejmanual(tagnum);catch trialsMakrs = zeros(1,numel(tagnum)) ; end
        try trialsMakrschan = EEG.reject.rejmanualE(:,tagnum);catch trialsMakrschan = zeros(EEG.nbchan,numel(tagnum)) ; end
        tmpcolsbgc = [1 1 0.783];
        if ~isempty(Epochintv)
            for jj = 1:size(Epochintv,1)
                [xpos,~]=find(trialsMakrschan(:,jj)==1);
                if jj<= numel(trialsMakrs) && ~isempty(xpos)
                    if trialsMakrs(jj)==1
                        patch(myeegviewer,[Epochintv(jj,1),Epochintv(jj,2),Epochintv(jj,2),Epochintv(jj,1)],...
                            [ylims(1),ylims(1),ylims(end),ylims(end)],tmpcolsbgc,'EdgeColor','none','FaceAlpha',.5);
                        %%highlight the wave if the channels exist
                        if  chaNum~=0
                            ChanArray = reshape(ChanArray,1,numel(ChanArray));
                            [~,ypos1]=find(ChanArray==xpos);
                            if ~isempty(ypos1)
                                for kk = 1:numel(ypos1)
                                    dataChan = nan(1,size(dataplot,2));
                                    dataChan (1,Epochintv(jj,1):Epochintv(jj,2)) = dataplot(ypos1(kk),Epochintv(jj,1):Epochintv(jj,2));
                                    dataChan1= nan(1,size(dataplot,2));
                                    dataChan1 (1,Epochintv(jj,1):Epochintv(jj,1)) = dataplot(ypos1(kk),Epochintv(jj,1):Epochintv(jj,1));
                                    try
                                        plot(myeegviewer, (dataChan+ Ampsc(size(dataplot,1)-ypos1(kk)+1)-meandata(ypos1(kk)))' , ...
                                            'color', Colorgbwave(ypos1(kk),:), 'clipping','on','LineWidth',1.5);%%
                                        
                                        plot(myeegviewer, (dataChan1+ Ampsc(size(dataplot,1)-ypos1(kk)+1)-meandata(ypos1(kk)))' , ...
                                            'color', Colorgbwave(ypos1(kk),:), 'clipping','on','LineWidth',1.5,'Marker' ,'s','MarkerSize',8,...
                                            'MarkerEdgeColor',Colorgbwave(ypos1(kk),:),'MarkerFaceColor',Colorgbwave(ypos1(kk),:));%%
                                    catch
                                        plot(myeegviewer, (dataChan+ Ampsc(size(dataplot,1)-ypos1(kk)+1)-meandata(ypos1(kk)))', ...
                                            'color', tmpcolor, 'clipping','on','LineWidth',1.5);%%
                                        plot(myeegviewer, (dataChan1+ Ampsc(size(dataplot,1)-ypos1(kk)+1)-meandata(ypos1(kk)))', ...
                                            'color', tmpcolor, 'clipping','on','LineWidth',1.5,'Marker' ,'s','MarkerSize',8,...
                                            'MarkerEdgeColor',Colorgbwave(ypos1(kk),:),'MarkerFaceColor',Colorgbwave(ypos1(kk),:));%%
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        %%
        for ii = size(dataplot,1):-1:1
            try
                plot(myeegviewer, (dataplot(ii,:)+ Ampsc(size(dataplot,1)-ii+1)-meandata(ii))' + (PlotNum+1)*(OldAmpScale-AmpScale)/2, ...
                    'color', Colorgbwave(ii,:), 'clipping','on','LineWidth',0.75);%%
            catch
                plot(myeegviewer, (dataplot(ii,:)+ Ampsc(size(dataplot,1)-ii+1)-meandata(ii))' + (PlotNum+1)*(OldAmpScale-AmpScale)/2, ...
                    'color', tmpcolor, 'clipping','on','LineWidth',0.75);%%
            end
        end
        
        %------------------------Xticks------------------------------------
        tagpos  = [];
        tagtext = [];
        if ~isempty(alltag)
            alltag = [alltag(1)-Trialstag alltag alltag(end)+Trialstag]; % add border trial limits
        else
            alltag = [ floor(lowlim/Trialstag)*Trialstag ceil(highlim/Trialstag)*Trialstag ]+1;
        end
        
        nbdiv = 20/Winlength; % approximative number of divisions
        divpossible = [ 100000./[1 2 4 5] 10000./[1 2 4 5] 1000./[1 2 4 5] 100./[1 2 4 5 10 20]]; % possible increments
        [tmp indexdiv] = min(abs(nbdiv*divpossible-(Limits(2)-Limits(1)))); % closest possible increment
        incrementpoint = divpossible(indexdiv)/1000*Srate;
        
        % tag zero below is an offset used to be sure that 0 is included
        % in the absicia of the data epochs
        if Limits(2) < 0, tagzerooffset  = (Limits(2)-Limits(1))/1000*Srate+1;
        else                tagzerooffset  = -Limits(1)/1000*Srate;
        end
        if tagzerooffset < 0, tagzerooffset = 0; end
        
        for i=1:length(alltag)-1
            if ~isempty(tagpos) && tagpos(end)-alltag(i)<2*incrementpoint/3
                tagpos  = tagpos(1:end-1);
            end
            if ~isempty(Freqlimits)
                tagpos  = [ tagpos linspace(alltag(i),alltag(i+1)-1, nbdiv) ];
            else
                if tagzerooffset ~= 0
                    tmptagpos = [alltag(i)+tagzerooffset:-incrementpoint:alltag(i)];
                else
                    tmptagpos = [];
                end
                tagpos  = [ tagpos [tmptagpos(end:-1:2) alltag(i)+tagzerooffset:incrementpoint:(alltag(i+1)-1)]];
            end
        end
        
        % find corresponding epochs
        % -------------------------
        if ~isfreq
            tmplimit = Limits;
            tpmorder = 1E-3;
        else
            tmplimit =Freqlimits;
            tpmorder = 1;
        end
        tagtext = eeg_point2lat(tagpos, floor((tagpos)/Trialstag)+1, Srate, tmplimit,tpmorder);
        
        %%adjust xticks
        EpochFlag = floor((tagpos)/Trialstag)+1;%%
        
        EpochFlag = reshape(EpochFlag,1,numel(EpochFlag));
        xtickstr =  tagpos-lowlim+1;
        [xpos,ypos] = find(xtickstr>0);
        if ~isempty(ypos)
            EpochFlag =EpochFlag(ypos);
            xtickstr = xtickstr(ypos);
            tagtext = tagtext(ypos);
        end
        
        EpochFlagunique =unique(setdiff(EpochFlag,0));
        if  numel(EpochFlagunique)~=1
            for ii = 2:numel(EpochFlagunique)
                [xpos,ypos]=  find(EpochFlag==EpochFlagunique(ii));
                if ~isempty(ypos)
                    xtickstr(ypos) = xtickstr(ypos)+(EpochFlagunique(ii)-EpochFlagunique(1))*GapSize;%*(1000/Srate);
                end
            end
        end
        set(myeegviewer,'XTickLabel', tagtext,...
            'Xlim',[1 (Winlength*multiplier+epochNum*GapSize)],...
            'XTick',xtickstr,...
            'FontWeight','normal',...
            'xaxislocation', 'bottom','FontSize',FonsizeDefault);
        
        %%
        %%-----------------plot scale------------------
        leftintv = (Winlength*multiplier+epochNum*GapSize);
    else
        set(myeegviewer, 'XTick', [], 'YTick', [],'Box','off', 'Color','none','xcolor','none','ycolor','none');
    end
end


%%
%%----------------------------plot y scale---------------------------------
if ~isempty(data) && PlotNum~=0  && ~isempty(leftintv)
    ytick_bottom = myeegviewer.TickLength(1)*diff(myeegviewer.XLim);
    %     xtick_bottom = myeegviewer.TickLength(1)*diff(myeegviewer.YLim);
    leftintv = leftintv+ytick_bottom*2.5;
    rightintv = leftintv;
    if ICdispFlag~=0
        line(myeegviewer,[leftintv,rightintv],[ylims(1) AmpICNew+ylims(1)],'color','k','LineWidth',1, 'clipping','off');
        line(myeegviewer,[leftintv-ytick_bottom,rightintv+ytick_bottom],[ylims(1) ylims(1)],'color','k','LineWidth',1, 'clipping','off');
        line(myeegviewer,[leftintv-ytick_bottom,rightintv+ytick_bottom],[AmpICNew+ylims(1) AmpICNew+ylims(1)],'color','k','LineWidth',1, 'clipping','off');
        text(myeegviewer,leftintv,((ylims(2)-ylims(1))/43+AmpICNew+ylims(1)), [num2str(AmpIC),32,'\muV'],'HorizontalAlignment', 'center','FontSize',FonsizeDefault);
        text(myeegviewer,leftintv,((ylims(2)-ylims(1))/20+AmpICNew+ylims(1)), ['ICs'],'HorizontalAlignment', 'center','FontSize',FonsizeDefault);
    end
    if EEGdispFlag~=0
        line(myeegviewer,[leftintv,rightintv],[ylims(end)-AmpScale ylims(end)],'color','k','LineWidth',1, 'clipping','off');
        line(myeegviewer,[leftintv-ytick_bottom,rightintv+ytick_bottom],[ylims(end)-AmpScale ylims(end)-AmpScale],'color','k','LineWidth',1, 'clipping','off');
        line(myeegviewer,[leftintv-ytick_bottom,rightintv+ytick_bottom],[ylims(end) ylims(end)],'color','k','LineWidth',1, 'clipping','off');
        text(myeegviewer,leftintv,(ylims(2)-ylims(1))/43+ylims(end), [num2str(AmpScale),32,'\muV'],'HorizontalAlignment', 'center','FontSize',FonsizeDefault);
        text(myeegviewer,leftintv,(ylims(2)-ylims(1))/20+ylims(end), ['Chans'],'HorizontalAlignment', 'center','FontSize',FonsizeDefault);
    end
end

%%---------------------------ytick ticklabels------------------------------
if ~isempty(data) && PlotNum~=0
    if chaNum==0
        ChanArray = [];
    end
    set(myeegviewer, 'ylim',[ylims(1) ylims(end)],'YTick',[ylims(1) Ampscold']);
    [YLabels,chaName,ICName] = f_eeg_read_chan_IC_names(EEG.chanlocs,ChanArray,ICArray,ChanLabel);
    YLabels = flipud(char(YLabels,''));
    set(myeegviewer,'YTickLabel',cellstr(YLabels),...
        'TickLength',[.005 .005],...
        'Color','none',...
        'XColor','k',...
        'YColor','k',...
        'FontWeight','normal',...
        'TickDir', 'in',...
        'LineWidth',0.5,'FontSize',FonsizeDefault);%%,'HorizontalAlignment','center'
    count=0;
    for ii = length(myeegviewer.YTickLabel):-1:2
        count = count+1;
        Cellsing = strrep(myeegviewer.YTickLabel{ii},'_','\_');
        myeegviewer.YTickLabel{ii} = strcat('\color[rgb]{',num2str(Colorgbwave(count,:)),'}', Cellsing);
    end
end
end

