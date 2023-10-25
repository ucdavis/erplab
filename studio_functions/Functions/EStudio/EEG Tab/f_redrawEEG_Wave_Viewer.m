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
FonsizeDefault = f_get_default_fontsize();

if nargin>1
    help f_redrawEEG_Wave_Viewer;
    return;
end

% We first clear the existing axes ready to build a new one
% if ishandle( EStudio_gui_erp_totl.eegViewAxes )
%     delete( EStudio_gui_erp_totl.eegViewAxes );
% end

%Sets the units of your root object (screen) to pixels
set(0,'units','pixels')
%Obtains this pixel information
Pix_SS = get(0,'screensize');
%Sets the units of your root object (screen) to inches
set(0,'units','inches')
%Obtains this inch information
Inch_SS = get(0,'screensize');
%Calculates the resolution (pixels per inch)
Res = Pix_SS./Inch_SS;

pb_height = 1*Res(4);
try
    [~, ~,ColorB_def,~,~,~] = geterplabstudiodef;%%Get background color
catch
    ColorB_def = [0.7020 0.77 0.85];
end
if isempty(ColorB_def) || numel(ColorB_def)~=3
    ColorB_def = [0.7020 0.77 0.85];
end

figbgdColor = [1 1 1];%%need to set

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
        %%Insert something to call the function that can change the parameters in
        %%the other panels
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
else
    pageNum=1;
    pagecurrentNum=1;
    PageStr = 'No EEG was loaded';
end

% EStudio_gui_erp_totl.eegplotgrid = uix.VBox('Parent',EStudio_gui_erp_totl.eegViewContainer,'Padding',0,'Spacing',0,'BackgroundColor',ColorB_def);
%%-----------------panel is to dispaly the EEGset names--------------------
EStudio_gui_erp_totl.eegpageinfo_str = ['Page',32,num2str(pagecurrentNum),'/',num2str(pageNum),':',PageStr];
EStudio_gui_erp_totl.eegpageinfo_text.String=EStudio_gui_erp_totl.eegpageinfo_str;

EStudio_gui_erp_totl.eegpageinfo_minus.Callback=@page_minus;
EStudio_gui_erp_totl.eegpageinfo_edit.String=num2str(pagecurrentNum);
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
EStudio_gui_erp_totl.eegpageinfo_minus.Enable = Enable_minus;
EStudio_gui_erp_totl.eegpageinfo_plus.Enable = Enable_plus;
EStudio_gui_erp_totl.eegpageinfo_plus.ForegroundColor = Enable_plus_BackgroundColor;
EStudio_gui_erp_totl.eegpageinfo_minus.ForegroundColor = Enable_minus_BackgroundColor;
set(EStudio_gui_erp_totl.eegpageinfo_box, 'Sizes', [-1 70 50 70] );


EStudio_gui_erp_totl.eeg_zoom_in_large.Callback=@zoomin_large;
EStudio_gui_erp_totl.eeg_zoom_in_fivesmall.Callback=@zoomin_fivesmall;
EStudio_gui_erp_totl.eeg_zoom_in_small.Callback=@zoomin_small;

EStudio_gui_erp_totl.eeg_zoom_edit.String=num2str(Startimes);
EStudio_gui_erp_totl.eeg_zoom_edit.Callback=@zoomedit;


EStudio_gui_erp_totl.eeg_zoom_out_small.Callback = @zoomout_small;
EStudio_gui_erp_totl.eeg_zoom_out_fivelarge.Callback =@zoomout_fivelarge;
EStudio_gui_erp_totl.eeg_zoom_out_large.Callback =@zoomout_large;

EStudio_gui_erp_totl.eeg_figurecommand.Callback=@Show_command;


EStudio_gui_erp_totl.eeg_figuresaveas.Callback=@figure_saveas;

EStudio_gui_erp_totl.eeg_figureout.Callback = @figure_out;


set(EStudio_gui_erp_totl.eeg_plot_button_title, 'Sizes', [10 40 40 40 40 40 40 40 -1 100 100 170 5]);


EStudio_gui_erp_totl.myeegviewer = axes('Parent', EStudio_gui_erp_totl.eegViewAxes,'Color','none','Box','on','FontWeight','normal');
hold(EStudio_gui_erp_totl.myeegviewer,'on');
hold(EStudio_gui_erp_totl.myeegviewer,'on');

EStudio_gui_erp_totl.eegplotgrid.Heights(1) = 40; % set the first element (pageinfo) to 30px high
pause(0.1);
EStudio_gui_erp_totl.eegplotgrid.Heights(3) = 30; % set the second element (x axis) to 30px high
EStudio_gui_erp_totl.eegplotgrid.Heights(4) = 30; % set the second element (x axis) to 30px high
Pos = EStudio_gui_erp_totl.myeegviewer.Position;
EStudio_gui_erp_totl.myeegviewer.Position = [Pos(1)*0.5,Pos(2)*0.5,Pos(3)*1.15,Pos(4)*1.05];%%x,y,width,height
estudioworkingmemory('egfigsize',[EStudio_gui_erp_totl.myeegviewer.Position(3),EStudio_gui_erp_totl.myeegviewer.Position(4)]);
if ~isempty(observe_EEGDAT.ALLEEG) && ~isempty(observe_EEGDAT.EEG)
    EEG = observe_EEGDAT.EEG;
    OutputViewereegpar = f_preparms_eegwaviewer(EEG,0);
    
    % %%Plot the eeg waves
    if ~isempty(OutputViewereegpar)
        f_plotviewereegwave(EEG,OutputViewereegpar{1},OutputViewereegpar{2},...
            OutputViewereegpar{3},OutputViewereegpar{4},OutputViewereegpar{5},...
            OutputViewereegpar{6},OutputViewereegpar{7},OutputViewereegpar{8},...
            OutputViewereegpar{9},OutputViewereegpar{10},OutputViewereegpar{11},...
            OutputViewereegpar{12},EStudio_gui_erp_totl.myeegviewer);
    end
end

%%
if isempty(observe_EEGDAT.EEG)
    set(EStudio_gui_erp_totl.myeegviewer, 'XTick', [], 'YTick', [],'Box','off', 'Color','none','xcolor','none','ycolor','none');
else
    %     set(EStudio_gui_erp_totl.myeegviewer, 'XTick', [], 'XTickLabel', []);
end

end % redrawDemo



%%------------------set to 0----------------------------------------
function zoomin_large(~,~)
global observe_EEGDAT;
global EStudio_gui_erp_totl;%%Global variable
if isempty(observe_EEGDAT.EEG)
    return;
end
if observe_EEGDAT.EEG.trials==1
    MessageViewer= char(strcat('Changing the start time of EEG to be 0s (|<)'));
else
    MessageViewer= char(strcat('Start the EEG from the first epoch (<<)'));
end
erpworkingmemory('f_EEG_proces_messg',MessageViewer);
observe_EEGDAT.eeg_panel_message=1;
if observe_EEGDAT.EEG.trials>1 % time in second or in trials
    Startimes =1;
else
    Startimes = 0;
end
EStudio_gui_erp_totl.eeg_zoom_edit.String =num2str(Startimes);
estudioworkingmemory('Startimes',Startimes);
f_redrawEEG_Wave_Viewer();
observe_EEGDAT.eeg_panel_message=2;
end


%%reduce the start time of the displayed EEG
function zoomin_fivesmall(~,~)
global observe_EEGDAT;
global EStudio_gui_erp_totl;%%Global variable
if isempty(observe_EEGDAT.EEG)
    return;
end
MessageViewer= char(strcat('Decreasing start time for the displayed EEG (<<)'));
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
erpworkingmemory('f_EEG_proces_messg',MessageViewer);
observe_EEGDAT.eeg_panel_message=1;
EStudio_gui_erp_totl.eeg_zoom_edit.String =num2str(Startimes);
f_redrawEEG_Wave_Viewer();
observe_EEGDAT.eeg_panel_message=2;

end


%%prev time period
function zoomin_small(~,~)

global observe_EEGDAT;
global EStudio_gui_erp_totl;%%Global variable
if isempty(observe_EEGDAT.EEG)
    return;
end
MessageViewer= char(strcat('Decreasing start time for the displayed EEG (<)'));
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
erpworkingmemory('f_EEG_proces_messg',MessageViewer);
observe_EEGDAT.eeg_panel_message=1;
EStudio_gui_erp_totl.eeg_zoom_edit.String =num2str(Startimes);
f_redrawEEG_Wave_Viewer();
observe_EEGDAT.eeg_panel_message=2;
end


%%Editing the start the time for the displayed EEG data
function zoomedit(Source,~)
global observe_EEGDAT;
global EStudio_gui_erp_totl;%%Global variable
if isempty(observe_EEGDAT.EEG)
    Source.String ='0';
    return;
end

MessageViewer= char(strcat('Editing start time for the displayed EEG'));
erpworkingmemory('f_EEG_proces_messg',MessageViewer);
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
MessageViewer= char(strcat('Editing start time for the displayed EEG'));
erpworkingmemory('f_EEG_proces_messg',MessageViewer);
f_redrawEEG_Wave_Viewer();
observe_EEGDAT.eeg_panel_message=2;
end




%%-------------------% > add one second for displayed EEG------------------
function zoomout_small(~,~)
global observe_EEGDAT;
global EStudio_gui_erp_totl;%%Global variable
MessageViewer= char(strcat('Increasing start time for the displayed EEG (>)'));
EEG_plotset = estudioworkingmemory('EEG_plotset');
try
    Winlength =   EEG_plotset{3};
catch
    Winlength = 5;
    EEG_plotset{3} = 5;
end
if isempty(observe_EEGDAT.EEG)
    return;
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
erpworkingmemory('f_EEG_proces_messg',MessageViewer);
observe_EEGDAT.eeg_panel_message=1;
f_redrawEEG_Wave_Viewer();
observe_EEGDAT.eeg_panel_message=2;
end


function zoomout_fivelarge(~,~)
global observe_EEGDAT;
global EStudio_gui_erp_totl;%%Global variable
MessageViewer= char(strcat('Increasing start time for the displayed EEG (>>)'));
EEG_plotset = estudioworkingmemory('EEG_plotset');
try
    Winlength =   EEG_plotset{3};
catch
    Winlength = 5;
    EEG_plotset{3} = 5;
end
if isempty(observe_EEGDAT.EEG)
    return;
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
erpworkingmemory('f_EEG_proces_messg',MessageViewer);
observe_EEGDAT.eeg_panel_message=1;
f_redrawEEG_Wave_Viewer();
observe_EEGDAT.eeg_panel_message=2;

end




function zoomout_large(~,~)
global observe_EEGDAT;
global EStudio_gui_erp_totl;%%Global variable
if isempty(observe_EEGDAT.EEG)
    return;
end
MessageViewer= char(strcat('Changing the start time to be maximal (>|)'));
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
erpworkingmemory('f_EEG_proces_messg',MessageViewer);
observe_EEGDAT.eeg_panel_message=1;
EStudio_gui_erp_totl.eeg_zoom_edit.String =num2str(Startimes);
f_redrawEEG_Wave_Viewer();
observe_EEGDAT.eeg_panel_message=2;

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
    observe_EEGDAT.count_current_eeg =2;
    f_redrawEEG_Wave_Viewer();%%replot the waves
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
        observe_EEGDAT.count_current_eeg =2;
        f_redrawEEG_Wave_Viewer();
        return;
    else
        Pagecurrent = ypos;
    end
end
Pagecurrent = Pagecurrent-1;
if  Pagecurrent>0 && Pagecurrent<=pageNum
    EStudio_gui_erp_totl.eegpageinfo_edit.String = num2str(Pagecurrent);
    observe_EEGDAT.CURRENTSET = EEGset_selected(Pagecurrent);
    observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
    MessageViewer= char(strcat('Plot wave for the previous EEGset'));
    erpworkingmemory('f_EEG_proces_messg',MessageViewer);
    observe_EEGDAT.eeg_panel_message=1;
    observe_EEGDAT.count_current_eeg =2;
    f_redrawEEG_Wave_Viewer();
    observe_EEGDAT.eeg_panel_message=2;
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
    MessageViewer= char(strcat('Plot wave for the next EEGset'));
    erpworkingmemory('f_EEG_proces_messg',MessageViewer);
    observe_EEGDAT.eeg_panel_message=1;
    observe_EEGDAT.count_current_eeg =2;
    f_redrawEEG_Wave_Viewer();
    observe_EEGDAT.eeg_panel_message=2;
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
    beep;
    observe_EEGDAT.eeg_panel_message=3;
    disp('User selected Cancel')
    return
end

History = 'off';
[pathstr, figurename1, ext] = fileparts(figurename) ;

if isempty(ext)
    figurename = fullfile(erppathname,char(strcat(figurename,'.pdf')));
else
    figurename = fullfile(erppathname,figurename);
end

try
    observe_EEGDAT.eeg_panel_message=1;
    OutputViewereegpar = f_preparms_eegwaviewer(observe_EEGDAT.EEG,1,History,figurename);
    observe_EEGDAT.eeg_panel_message=2;
catch
    observe_EEGDAT.eeg_panel_message=3;
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
try
    observe_EEGDAT.eeg_panel_message=1;
    OutputViewereegpar = f_preparms_eegwaviewer(observe_EEGDAT.EEG,1,History,figurename);
    observe_EEGDAT.eeg_panel_message=2;
catch
    observe_EEGDAT.eeg_panel_message=3;
end
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
if ~isempty(eegicinspectFlag)  && (eegicinspectFlag==1 || eegicinspectFlag==2)
    EEGArray =  estudioworkingmemory('EEGArray');
    if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
        EEGArray = observe_EEGDAT.CURRENTSET;
    end
    if numel(EEGArray) ==1
        
        %%set a reminder that can give the users second chance to update
        %%current EEGset
        if  eegicinspectFlag==1
            question = ['We strongly recommend your to label ICs before any further analyses. Otherwise, there may be some bugs.\n\n',...
                'Have you Labelled ICs? \n\n',...
                'Please select "No" if you didnot. \n\n'];
            title       = 'EStudio: Label ICs';
        elseif eegicinspectFlag==2
            question = ['We strongly recommend your to update artifact marks for epoched EEG before any further analyses. Otherwise, there may be some bugs.\n\n',...
                'Have you updated artifact marks? \n\n',...
                'Please select "No" if you didnot. \n\n'];
            title       = 'EStudio: Update artifact marks';
        end
        
        BackERPLABcolor = [1 0.9 0.3];
        oldcolor = get(0,'DefaultUicontrolBackgroundColor');
        set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
        button      = questdlg(sprintf(question,''), title,'No','Yes','Yes');
        set(0,'DefaultUicontrolBackgroundColor',[1 1 1]);
        if isempty(button) ||   strcmpi(button,'No')
            return;
        end
        %%close the figures for inspect/label ICs or artifact detection for
        %%epoched eeg (preview)
        try
            for Numofig = 1:1000
                fig = gcf;
                if strcmpi(fig.Tag,'EEGPLOT') || strcmpi(fig.Tag(1:7),'selcomp')
                    close(fig.Name);
                else
                    break;
                end
            end
        catch 
        end
        
        try
            observe_EEGDAT.ALLEEG(EEGArray) = evalin('base','EEG');
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(EEGArray);
            erpworkingmemory('eegicinspectFlag',0);
            observe_EEGDAT.count_current_eeg=1;
        catch
            erpworkingmemory('eegicinspectFlag',0);
        end
    end
end
if eegicinspectFlag~=0
    return;
end

EStudio_gui_erp_totl.eegProcess_messg.BackgroundColor = [0.95 0.95 0.95];
EStudio_gui_erp_totl.eegProcess_messg.FontSize = FonsizeDefault;

if observe_EEGDAT.eeg_panel_message==1
    EStudio_gui_erp_totl.eegProcess_messg.String =  strcat('1- ',Processed_Method,': Running....');
    EStudio_gui_erp_totl.eegProcess_messg.ForegroundColor = [0 0 0];
elseif observe_EEGDAT.eeg_panel_message==2
    EStudio_gui_erp_totl.eegProcess_messg.String =  strcat('2- ',Processed_Method,': Complete');
    EStudio_gui_erp_totl.eegProcess_messg.ForegroundColor = [0 0.5 0];
    
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
    
    pause(0.5);
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
function errmeg = f_plotviewereegwave(EEG,ChanArray,ICArray,EEGdispFlag,ICdispFlag,Winlength,...
    AmpScale,ChanLabel,Submean,EventOnset,StackFlag,NormFlag,Startimes,myeegviewer)
fig = myeegviewer;
errmeg = [];

if nargin<1
    help f_plotviewereegwave;
    return
end

if isempty(EEG)
    errmeg  = 'EEG is empty';
    return;
end
if ICdispFlag==0 && EEGdispFlag==0
    errmeg  = 'either original data or IC data should be plotted';
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
if isempty(AmpScale) || numel(AmpScale)~=1 || AmpScale==0
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
    Submean = 0;
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
highlim = round(min((Startimes+Winlength)*multiplier,Allsamples));


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
        %         if option_boundary99
        %             indexwidth = [ Eventtypes == -99 ];
        %         end
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

%%-------------------------------IC data----------------------------------
dataica = [];
meandataica =[];
if ICdispFlag==1
    if ~isempty(EEG.icaweights) && ~isempty(ICArray)%%pop_eegplot from eeglab
        tmpdata = eeg_getdatact(EEG, 'component', [1:size(EEG.icaweights,1)]);
        try
            dataica = tmpdata(ICArray,:);
        catch
            dataica = tmpdata(:,:);
            ICArray = [1:size(tmpdata,1)];
        end
        switch Submean % subtract the mean ?
            case 1
                meandataica = mean(dataica(:,lowlim:highlim)');
                if any(isnan(meandataica))
                    meandataica = nan_mean(dataica(:,lowlim:highlim)');
                end
            otherwise, meandataica = zeros(1,numel(ICArray));
        end
        
    end
end


% Removing DC for original data?
% -------------------------
dataeeg = [];
meandata = [];
if EEGdispFlag==1
    dataeeg = EEG.data(ChanArray,:);
    switch Submean % subtract the mean ?
        case 1
            meandata = mean(dataeeg(:,lowlim:highlim)');
            if any(isnan(meandata))
                meandata = nan_mean(dataeeg(:,lowlim:highlim)');
            end
        otherwise, meandata = zeros(1,numel(ChanArray));
    end
    
end

%%---------------------------Normalize-------------------------------------
if NormFlag==1
    %%Norm for origanal
    %     data2 = [];
    if ~isempty(dataeeg)
        datastd = std(dataeeg(:,1:min(1000,Allsamples)),[],2);%
        for i = 1:size(dataeeg,1)
            dataeeg(i,:,:) = dataeeg(i,:,:)*datastd(i);
            %             if ~isempty(data2)
            %                 data2(i,:,:) = data2(i,:,:)*datastd(i);
            %             end
        end
    end
    
    %%norm for IC data
    if ~isempty(dataica)
        tmpdata = eeg_getdatact(EEG, 'component', [1:size(EEG.icaweights,1)]);
        try
            dataica1 = tmpdata(ICArray,:);
        catch
            dataica1 =  tmpdata(:,:);
        end
        dataicstd = std(dataica(:,1:min(1000,Allsamples)),[],2);
        for i = 1:size(dataica,1)
            dataica(i,:,:) = dataica(i,:,:)*dataicstd(i);
            %        if ~isempty(data2)
            %            data2(i,:,:) = data2(i,:,:)*dataicstd(i);
            %        end
        end
    end
end


data = [dataeeg;dataica];
meandata = [meandata,meandataica];
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
ylims = [0 (PlotNum+1)*AmpScale];
if EventOnset==1
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
            EVENTFONT = ' \fontsize{10} ';
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
                tmplat = Eventlatencies(event2plot(index))-lowlim-1;
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
                'rotation',90);
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


if StackFlag==1
    AmpScale=0;
end
DEFAULT_GRID_SPACING =Winlength/5;

% -------------------------------------------------------------------------
% -----------------draw EEG wave if any------------------------------------
% -------------------------------------------------------------------------
%%Plot continuous EEG
tmpcolor = [ 0 0 0.4 ];
if ndims(EEG.data)==2
    if ~isempty(data) && PlotNum~=0
        
        if isempty(dataica) && ~isempty(dataeeg)%%only EEG data
            plot(myeegviewer, bsxfun(@plus, data(end:-1:1,lowlim:highlim), AmpScale*[1:PlotNum]'-meandata(end:-1:1)')' + (PlotNum+1)*(OldAmpScale-AmpScale)/2, ...
                'color', tmpcolor, 'clipping','on','LineWidth',0.5);%%
        elseif ~isempty(dataica) && isempty(dataeeg)%%only IC data
            plot(myeegviewer, bsxfun(@plus, data(end:-1:1,lowlim:highlim), AmpScale*[1:PlotNum]'-meandata(end:-1:1)')' + (PlotNum+1)*(OldAmpScale-AmpScale)/2, ...
                'color', [0.6667    0.2902    0.2667], 'clipping','on','LineWidth',0.5);%%
        else
            tvmid = size(data,1)-size(dataica,1)+1;
            %%plot ic
            plot(myeegviewer, bsxfun(@plus, data(end:-1:tvmid,lowlim:highlim), AmpScale*[1:size(dataica,1)]'-meandata(end:-1:tvmid)')' + (PlotNum+1)*(OldAmpScale-AmpScale)/2, ...
                'color', [0.6667    0.2902    0.2667], 'clipping','on','LineWidth',0.5);%%
            %%plot eeg
            plot(myeegviewer, bsxfun(@plus, data(tvmid-1:-1:1,lowlim:highlim), AmpScale*[size(dataica,1)+1:PlotNum]'-meandata(tvmid-1:-1:1)')' + (PlotNum+1)*(OldAmpScale-AmpScale)/2, ...
                'color', tmpcolor, 'clipping','on','LineWidth',0.5);%%
        end
        
        set(myeegviewer,'TickDir', 'in','LineWidth',1);
        %%xtick
        AmpScale = OldAmpScale;
        set(myeegviewer, 'Xlim',[1 Winlength*multiplier],...
            'XTick',[1:multiplier*DEFAULT_GRID_SPACING:Winlength*multiplier+1]);
        set(myeegviewer, 'XTickLabel', num2str((Startimes:DEFAULT_GRID_SPACING:Startimes+Winlength)'));
    end
end

%%------------------------------plot single-trial EEG----------------------
%%Thanks for the eeglab developers so that we can borrow their codes
isfreq = 0;
Limits = [EEG.times(1),EEG.times(end)];
Srate = EEG.srate;
Freqlimits = [];
if ndims(EEG.data)==3
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
            %      	set(myeegviewer1,'XTickLabel', tagnum,'YTickLabel', [],...
            % 		 'Xlim',[1 (Winlength*multiplier+epochNum*GapSize)],...
            % 		'XTick',alltag-lowlim+Trialstag/2, 'YTick',[],'xaxislocation', 'top');
            for ii = 1:numel(tagnum)
                text(myeegviewer, [alltag1(ii)-lowlim+Trialstag/2],ylims(2)+1.1, [32,num2str(tagnum(ii))], ...
                    'color', 'k', ...
                    'horizontalalignment', 'left','rotation',90); %%
                set(myeegviewer,'Xlim',[1 (Winlength*multiplier+epochNum*GapSize)]);
            end
        end
        
        %%add the gap between epochs if any
        if ~isempty(tmpind)
            if (numel(tmpind)==1 && tmpind(end) == numel(tmptag)) || (numel(tmpind)==1 && tmpind(1) == 1)
                dataplot =   data(:,lowlim:highlim);
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
                end
                if ~isempty(dataplot_new)
                    dataplot = dataplot_new;
                else
                    dataplot = dataplotold;
                end
            end
        end
        
        %%
        if isempty(dataica) && ~isempty(dataeeg)%%only EEG data
            plot(myeegviewer, bsxfun(@plus, dataplot(end:-1:1,:), AmpScale*[1:PlotNum]'-meandata(end:-1:1)')' + (PlotNum+1)*(OldAmpScale-AmpScale)/2, ...
                'color', tmpcolor, 'clipping','on','LineWidth',0.5);%%
        elseif ~isempty(dataica) && isempty(dataeeg)%%only IC data
            plot(myeegviewer, bsxfun(@plus, dataplot(end:-1:1,:), AmpScale*[1:PlotNum]'-meandata(end:-1:1)')' + (PlotNum+1)*(OldAmpScale-AmpScale)/2, ...
                'color', [0.6667    0.2902    0.2667], 'clipping','on','LineWidth',0.5);%%
        else
            tvmid = size(dataplot,1)-size(dataica,1)+1;
            %%plot ic
            plot(myeegviewer, bsxfun(@plus, dataplot(end:-1:tvmid,:), AmpScale*[1:size(dataica,1)]'-meandata(end:-1:tvmid)')' + (PlotNum+1)*(OldAmpScale-AmpScale)/2, ...
                'color', [0.6667    0.2902    0.2667], 'clipping','on','LineWidth',0.5);%%
            %%plot eeg
            plot(myeegviewer, bsxfun(@plus, dataplot(tvmid-1:-1:1,:), AmpScale*[size(dataica,1)+1:PlotNum]'-meandata(tvmid-1:-1:1)')' + (PlotNum+1)*(OldAmpScale-AmpScale)/2, ...
                'color', tmpcolor, 'clipping','on','LineWidth',0.5);%%
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
            'xaxislocation', 'bottom');
    end
end

%%ytick ticklabels
set(myeegviewer, 'ylim',[0 (PlotNum+1)*OldAmpScale],'YTick',[0:OldAmpScale:PlotNum*OldAmpScale]);
[YLabels,chaName,ICName] = f_eeg_read_chan_IC_names(EEG.chanlocs,ChanArray,ICArray,ChanLabel);
YLabels = flipud(char(YLabels,''));
set(myeegviewer,'YTickLabel',cellstr(YLabels),...
    'TickLength',[.005 .005],...
    'Color','none',...
    'XColor','k',...
    'YColor','k',...
    'FontWeight','normal',...
    'TickDir', 'in',...
    'LineWidth',0.5);%%,'HorizontalAlignment','center'
try
    set(myeegviewer, 'TickLabelInterpreter', 'none'); % for old Matlab 2011
catch
end

end