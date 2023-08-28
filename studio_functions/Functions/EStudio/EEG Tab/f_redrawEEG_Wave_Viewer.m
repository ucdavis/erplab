%PURPOSE  : Plot EEG waves within one axes as EEGLAB



% Author: Guanghui Zhang & Steve J. Luck
% Center for Mind and Brain
% University of California, Davis
% Davis, CA
% 2023



function f_redrawEEG_Wave_Viewer()

global observe_EEGDAT;
global EStudio_gui_erp_totl;%%Global variable
addlistener(observe_EEGDAT,'eeg_message_panel_change',@eeg_message_panel_change);
FonsizeDefault = f_get_default_fontsize();

if nargin>1
    help f_redrawEEG_Wave_Viewer;
    return;
end

% We first clear the existing axes ready to build a new one
if ishandle( EStudio_gui_erp_totl.eegViewAxes )
    delete( EStudio_gui_erp_totl.eegViewAxes );
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
    EEG_startime = 0;
else
    EEG_startime= estudioworkingmemory('EEG_startime');
    if isempty(EEG_startime) || min(EEG_startime)<0
        EEG_startime = 0;
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
    EEG_startimeMax = max(0,ceil((Frames-1)/multiplier)-Winlength);
    if observe_EEGDAT.EEG.trials>1
      EEG_startimeMax =EEG_startimeMax+1;  
    end
    if  EEG_startime > EEG_startimeMax
        EEG_startime = EEG_startimeMax;
    end
end
if ~isempty(observe_EEGDAT.EEG)
if observe_EEGDAT.EEG.trials>1  && EEG_startime ==0%%for epoched EEG, it should be from the first epoch
    EEG_startime=1;
end
end
estudioworkingmemory('EEG_startime',EEG_startime);

%%Selected EEGsets from memory file
EEGset_selected = estudioworkingmemory('EEGsets_selected');
if ~isempty(observe_EEGDAT.ALLEEG)  && ~isempty(observe_EEGDAT.EEG)
    if isempty(EEGset_selected) || min(EEGset_selected(:)) > length(observe_EEGDAT.ALLEEG) || max(EEGset_selected(:))>length(observe_EEGDAT.ALLEEG)
        EEGset_selected =  length(observe_EEGDAT.ALLEEG) ;
        estudioworkingmemory('EEGsets_selected',EEGset_selected);
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



EStudio_gui_erp_totl.eegplotgrid = uix.VBox('Parent',EStudio_gui_erp_totl.eegViewContainer,'Padding',0,'Spacing',0,'BackgroundColor',ColorB_def);

%%-----------------panel is to dispaly the EEGset names--------------------
EStudio_gui_erp_totl.eegpageinfo_box = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.eegplotgrid,'BackgroundColor',ColorB_def);
EStudio_gui_erp_totl.eegpageinfo_str = ['Page',32,num2str(pagecurrentNum),'/',num2str(pageNum),':',PageStr];
EStudio_gui_erp_totl.eegpageinfo_text = uicontrol('Parent',EStudio_gui_erp_totl.eegpageinfo_box,'Style','text','String',EStudio_gui_erp_totl.eegpageinfo_str,'FontSize',FonsizeDefault,'FontWeight','bold','BackgroundColor',ColorB_def);
EStudio_gui_erp_totl.eegpageinfo_minus = uicontrol('Parent',EStudio_gui_erp_totl.eegpageinfo_box,'Style', 'pushbutton', 'String', 'Prev.','Callback',@page_minus,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'FontWeight','bold');
EStudio_gui_erp_totl.eegpageinfo_edit = uicontrol('Parent',EStudio_gui_erp_totl.eegpageinfo_box,'Style', 'edit', 'String', num2str(pagecurrentNum),'Callback',@page_edit,'FontSize',FonsizeDefault+2,'BackgroundColor',[1 1 1]);
EStudio_gui_erp_totl.eegpageinfo_plus = uicontrol('Parent',EStudio_gui_erp_totl.eegpageinfo_box,'Style', 'pushbutton', 'String', 'Next','Callback',@page_plus,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'FontWeight','bold');
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
set(EStudio_gui_erp_totl.eegpageinfo_box, 'Sizes', [-1 50 50 50] );


EStudio_gui_erp_totl.eeg_plot_title = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.eegplotgrid,'BackgroundColor',ColorB_def);
%%panel is to dispaly the EEG wave
EStudio_gui_erp_totl.eegViewAxes = uix.ScrollingPanel( 'Parent', EStudio_gui_erp_totl.eeg_plot_title,'BackgroundColor',figbgdColor);

%%Changed by Guanghui Zhang Dec. 2022-------panel for display the processing procedure for some functions, e.g., filtering
EStudio_gui_erp_totl.eeg_plot_button_title = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.eegplotgrid,'BackgroundColor',ColorB_def);%%%Message
uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','text','String','','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
EStudio_gui_erp_totl.eeg_zoom_in_large = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','pushbutton','String','<<',...
    'FontSize',FonsizeDefault+5,'BackgroundColor',[1 1 1],'Callback',@zoomin_large);

EStudio_gui_erp_totl.eeg_zoom_in_small = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','pushbutton','String','<',...
    'FontSize',FonsizeDefault+5,'BackgroundColor',[1 1 1],'Callback',@zoomin_small);

EStudio_gui_erp_totl.eeg_zoom_edit = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','edit','String',num2str(EEG_startime),...
    'FontSize',FonsizeDefault+5,'BackgroundColor',[1 1 1],'Callback',@zoomedit);

EStudio_gui_erp_totl.eeg_zoom_out_small = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','pushbutton','String','>',...
    'FontSize',FonsizeDefault+5,'BackgroundColor',[1 1 1],'Callback',@zoomout_small);

EStudio_gui_erp_totl.eeg_zoom_out_large = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','pushbutton','String','>>',...
    'FontSize',FonsizeDefault+5,'BackgroundColor',[1 1 1],'Callback',@zoomout_large);
uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','text','String','','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);

EStudio_gui_erp_totl.eeg_figurecommand = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','pushbutton','String','Show Command',...
    'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Callback',@Show_command);


EStudio_gui_erp_totl.eeg_figuresaveas = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','pushbutton','String','Save Figure as',...
    'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Callback',@figure_saveas);

EStudio_gui_erp_totl.eeg_figureout = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','pushbutton','String','Create Static /Exportable Plot',...
    'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Callback',@figure_out);

EStudio_gui_erp_totl.eeg_Reset = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','pushbutton','String','Reset',...
    'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Callback',@Panel_Reset);


uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','text','String','','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
set(EStudio_gui_erp_totl.eeg_plot_button_title, 'Sizes', [10 50 50 50 50 50 -1 100 100 170 70 5]);


%%Changed by Guanghui Zhang Dec. 2022-------panel for display the processing procedure for some functions, e.g., filtering
EStudio_gui_erp_totl.eegxaxis_panel = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.eegplotgrid,'BackgroundColor',ColorB_def);%%%Message
EStudio_gui_erp_totl.eegProcess_messg = uicontrol('Parent',EStudio_gui_erp_totl.eegxaxis_panel,'Style','text','String','','FontSize',FonsizeDefault+2,'FontWeight','bold','BackgroundColor',ColorB_def);

% set(EStudio_gui_erp_totl.plot_wav_legend, 'Sizes', [10 -1]);
% set(EStudio_gui_erp_totl.erpwaviewer_legend_title, 'Sizes', [10 -1]);

EStudio_gui_erp_totl.myeegviewer = axes('Parent', EStudio_gui_erp_totl.eegViewAxes,'Color','none','Box','on','FontWeight','bold');
hold(EStudio_gui_erp_totl.myeegviewer,'on');
% myerpviewer = EStudio_gui_erp_totl.myeegviewe;
EStudio_gui_erp_totl.eegplotgrid.Heights(1) = 40; % set the first element (pageinfo) to 30px high
% EStudio_gui_erp_totl.eegplotgrid.Heights(2) = -1; % set the first element (pageinfo) to 30px high
pause(0.1);
EStudio_gui_erp_totl.eegplotgrid.Heights(3) = 30; % set the second element (x axis) to 30px high
EStudio_gui_erp_totl.eegplotgrid.Heights(4) = 30; % set the second element (x axis) to 30px high
Pos = EStudio_gui_erp_totl.myeegviewer.Position;
EStudio_gui_erp_totl.myeegviewer.Position = [Pos(1)*0.5,Pos(2)*0.95,Pos(3)*1.15,Pos(4)*0.95];

if ~isempty(observe_EEGDAT.ALLEEG) && ~isempty(observe_EEGDAT.EEG)
    EEG = observe_EEGDAT.EEG;
    OutputViewereegpar = f_preparms_eegwaviewer(EEG);
    
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

% %%resize the heights based on the number of rows
% Fill = 1;
% splot_n = size(OutputViewereegpar{6},1);
% if splot_n*pb_height<(EStudio_gui_erp_totl.eegplotgrid.Position(4)-EStudio_gui_erp_totl.eegplotgrid.Heights(1))&&Fill
%     pb_height = 0.9*(EStudio_gui_erp_totl.eegplotgrid.Position(4)-EStudio_gui_erp_totl.eegplotgrid.Heights(1)-EStudio_gui_erp_totl.eegplotgrid.Heights(2))/splot_n;
% else
%     pb_height = 0.9*pb_height;
% end
% if zoomSpace <0
%     EStudio_gui_erp_totl.eegViewAxes.Heights = splot_n*pb_height;
% else
%     EStudio_gui_erp_totl.eegViewAxes.Heights = splot_n*pb_height*(1+zoomSpace/100);
% end
%
% widthViewer = EStudio_gui_erp_totl.eegViewAxes.Position(3)-EStudio_gui_erp_totl.eegViewAxes.Position(2);
% if zoomSpace <0
%     EStudio_gui_erp_totl.eegViewAxes.Widths = widthViewer;
% else
%     EStudio_gui_erp_totl.eegViewAxes.Widths = widthViewer*(1+zoomSpace/100);
%
% end
% EStudio_gui_erp_totl.eegplotgrid.Units = 'normalized';
%
%
%
% %%Keep the same positions for Vertical and Horizontal scrolling bars asbefore
% if zoomSpace~=0 && zoomSpace>0
%     if EStudio_gui_erp_totl.ScrollVerticalOffsets<=1
%         try
%             EStudio_gui_erp_totl.eegViewAxes.VerticalOffsets= EStudio_gui_erp_totl.ScrollVerticalOffsets*EStudio_gui_erp_totl.eegViewAxes.Heights;
%         catch
%         end
%     end
%     if EStudio_gui_erp_totl.ScrollHorizontalOffsets<=1
%         try
%             EStudio_gui_erp_totl.eegViewAxes.HorizontalOffsets =EStudio_gui_erp_totl.ScrollHorizontalOffsets*EStudio_gui_erp_totl.eegViewAxes.Widths;
%         catch
%         end
%     end
% end
% % EStudio_gui_erp_totl.eegViewAxes.BackgroundColor = 'b';
%
%
%
%
% %%display the names of channels and bins if they diff across the selected
% %%ERPsets
% LabelsdiffFlag = OutputViewereegpar{48};
% ALLERPIN = OutputViewereegpar{1};
% PLOTORG =   OutputViewereegpar{3};
% ERPsetArray=   OutputViewereegpar{43};
% [chanStr,binStr,diff_mark,chanStremp,binStremp] = f_geterpschanbin(ALLERPIN,ERPsetArray);
%
% if (diff_mark(1) ==1 || diff_mark(2)==1) && LabelsdiffFlag==1 && PLOTORG(1)~=3
%     if diff_mark(1) ==1 && diff_mark(2) ==0
%         MessageViewer= char(strcat('Some grid Location Labels will be empty because CHANNELS differ across the selected ERPsets'));
%         erpworkingmemory('f_EEG_proces_messg',MessageViewer);
%         observe_EEGDAT.EEG_messg_panel=4;
%     elseif diff_mark(1) ==0 && diff_mark(2) ==1
%         MessageViewer= char(strcat('Some grid Location Labels will be empty because BINS differ across the selected ERPsets'));
%         erpworkingmemory('f_EEG_proces_messg',MessageViewer);
%         observe_EEGDAT.EEG_messg_panel=4;
%
%     elseif  diff_mark(1) ==1 && diff_mark(2) ==1
%         MessageViewer= char(strcat('Some grid Location Labels will be empty because CHANNELS and BINS differ across the selected ERPsets'));
%         erpworkingmemory('f_EEG_proces_messg',MessageViewer);
%         observe_EEGDAT.EEG_messg_panel=4;
%     end
%     f_display_binstr_chanstr(ALLERPIN, ERPsetArray,diff_mark)
% end
EStudio_gui_erp_totl.eegplotgrid.Heights(1) = 40; % set the first element (pageinfo) to 30px high
% EStudio_gui_erp_totl.eegplotgrid.Heights(2) = -1; % set the first element (pageinfo) to 30px high
pause(0.1);
EStudio_gui_erp_totl.eegplotgrid.Heights(3) = 30; % set the second element (x axis) to 30px high
EStudio_gui_erp_totl.eegplotgrid.Heights(4) = 30; % set the second element (x axis) to 30px high
% EStudio_gui_erp_totl.eegplotgrid.Units = 'pixels';

end % redrawDemo



%%------------------set to 0----------------------------------------
function zoomin_large(~,~)
global observe_EEGDAT;
global EStudio_gui_erp_totl;%%Global variable
if isempty(observe_EEGDAT.EEG)
    return;
end
if observe_EEGDAT.EEG.trials==1
    MessageViewer= char(strcat('Changing the start time of EEG to be 0s (<<)'));
else
    MessageViewer= char(strcat('Start the EEG from the first epoch (<<)'));
end
erpworkingmemory('f_EEG_proces_messg',MessageViewer);
observe_EEGDAT.eeg_message_panel=1;
if observe_EEGDAT.EEG.trials>1 % time in second or in trials
    EEG_startime =1;
else
    EEG_startime = 0;
end
EStudio_gui_erp_totl.eeg_zoom_edit.String =num2str(EEG_startime);
estudioworkingmemory('EEG_startime',EEG_startime);
f_redrawEEG_Wave_Viewer();
observe_EEGDAT.eeg_message_panel=2;
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
EEG_startimedef = str2num(EStudio_gui_erp_totl.eeg_zoom_edit.String);
if ~isempty(EEG_startimedef) && isnumeric(EEG_startimedef) && numel(EEG_startimedef)==1 && EEG_startimedef>=0
else
    EEG_startimedef = 0;
    EStudio_gui_erp_totl.eeg_zoom_edit.String = '0';
end

% if EEG_startimedef>0
EEG_startime = EEG_startimedef-fastif(Winlength>=5, round(Winlength/5), Winlength/5);
% end
if EEG_startime<0
    if observe_EEGDAT.EEG.trials>1
        EEG_startime=1;
    else
        EEG_startime=0;
    end
end

estudioworkingmemory('EEG_startime',EEG_startime);
erpworkingmemory('f_EEG_proces_messg',MessageViewer);
observe_EEGDAT.eeg_message_panel=1;
EStudio_gui_erp_totl.eeg_zoom_edit.String =num2str(EEG_startime);
f_redrawEEG_Wave_Viewer();
observe_EEGDAT.eeg_message_panel=2;
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
EEG_startime = str2num(EStudio_gui_erp_totl.eeg_zoom_edit.String);
if isempty(EEG_startime)
    EEG_startime = 0;
    Source.String = '0';
    MessageViewer= char(strcat('Start time for the displayed EEG should be a number'));
    erpworkingmemory('f_EEG_proces_messg',MessageViewer);
    observe_EEGDAT.eeg_message_panel=4;
end
if numel(EEG_startime)~=1
    EEG_startime = EEG_startime(1);
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
    EEG_startime = EEG_startime-1;
end
EEG_startime = max(0,min(EEG_startime,ceil((Frames-1)/multiplier)-Winlength));
if ndims(observe_EEGDAT.EEG.data) ==3
    EEG_startime = EEG_startime+1;
end
Source.String = num2str(EEG_startime);


estudioworkingmemory('EEG_startime',EEG_startime);
MessageViewer= char(strcat('Editing start time for the displayed EEG'));
erpworkingmemory('f_EEG_proces_messg',MessageViewer);
f_redrawEEG_Wave_Viewer();
observe_EEGDAT.eeg_message_panel=2;
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
EEG_startimedef = str2num(EStudio_gui_erp_totl.eeg_zoom_edit.String);
if ~isempty(EEG_startimedef) && isnumeric(EEG_startimedef) && numel(EEG_startimedef)==1 && EEG_startimedef>=0
else
    EEG_startimedef = 0;
end

EEG_startime = EEG_startimedef+fastif(Winlength>=5, round(Winlength/5), Winlength/5); %%> add one second
if EEG_startime<0
    EEG_startime=0;
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

EEG_startime = max(0,min(EEG_startime,ceil((Frames-1)/multiplier)-Winlength));
EStudio_gui_erp_totl.eeg_zoom_edit.String = num2str(EEG_startime);

estudioworkingmemory('EEG_startime',EEG_startime);
erpworkingmemory('f_EEG_proces_messg',MessageViewer);
observe_EEGDAT.eeg_message_panel=1;
f_redrawEEG_Wave_Viewer();
observe_EEGDAT.eeg_message_panel=2;
end




function zoomout_large(~,~)
global observe_EEGDAT;
global EStudio_gui_erp_totl;%%Global variable
if isempty(observe_EEGDAT.EEG)
    return;
end
MessageViewer= char(strcat('Changing the start time to be maximal (>>)'));
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
EEG_startimeMax = max(0,ceil((Frames-1)/multiplier)-Winlength);
if ndims(observe_EEGDAT.EEG.data)==3
    EEG_startimeMax = EEG_startimeMax+1;
end
EEG_startime = EEG_startimeMax;


estudioworkingmemory('EEG_startime',EEG_startime);
erpworkingmemory('f_EEG_proces_messg',MessageViewer);
observe_EEGDAT.eeg_message_panel=1;
EStudio_gui_erp_totl.eeg_zoom_edit.String =num2str(EEG_startime);
f_redrawEEG_Wave_Viewer();
observe_EEGDAT.eeg_message_panel=2;

end


%%-------------------------------Page Editor-------------------------------
function page_edit(Source,~)
global observe_EEGDAT
% addlistener(observe_EEGDAT,'page_xyaxis',@count_page_xyaxis_change);

try
    ERPwaviewer = evalin('base','ALLERPwaviewer');
catch
    beep;
    disp('Error > f_redrawEEG_Wave_Viewer() > page_edit().');
    return;
end
pagesValue =  ERPwaviewer.plot_org.Pages;

[messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
if ~isempty(messgStr)
    observe_EEGDAT.count_twopanels = observe_EEGDAT.count_twopanels +1;
end

Pagecurrent = str2num(Source.String);

if ~isempty(Pagecurrent) && Pagecurrent>0
    
    ERPArray = ERPwaviewer.SelectERPIdx;
    chanArray =ERPwaviewer.chan;
    binArray = ERPwaviewer.bin;
    if pagesValue==1
        pageNum = numel(chanArray);
    elseif pagesValue==2
        pageNum = numel(binArray);
    else
        pageNum = numel(ERPArray);
    end
    
    if  Pagecurrent<=pageNum
        ERPwaviewer.PageIndex = Pagecurrent;
        if pagesValue==3
            ERPwaviewer.ERP   = ERPwaviewer.ALLERP(ERPArray(Pagecurrent));
            ERPwaviewer.CURRENTERP  =ERPArray(Pagecurrent);
        end
        assignin('base','ALLERPwaviewer',ERPwaviewer);
        observe_EEGDAT.page_xyaxis = observe_EEGDAT.page_xyaxis+1;
        f_redrawEEG_Wave_Viewer();%%replot the waves
    end
end

end

%------------------Display the waveform for proir ERPset--------------------
function page_minus(~,~)
global observe_EEGDAT

[messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
if ~isempty(messgStr)
    observe_EEGDAT.count_twopanels = observe_EEGDAT.count_twopanels +1;
end

try
    ERPwaviewer_CHANGE = evalin('base','ALLERPwaviewer');
catch
    beep;
    disp('Please re-run ERP wave viewer.');
    return;
end
ERPwaviewer_CHANGE.PageIndex = ERPwaviewer_CHANGE.PageIndex-1;
pagesValue =  ERPwaviewer_CHANGE.plot_org.Pages;
ERPArray = ERPwaviewer_CHANGE.SelectERPIdx;
chanArray =ERPwaviewer_CHANGE.chan;
binArray = ERPwaviewer_CHANGE.bin;
if pagesValue==1
    pageNum = numel(chanArray);
elseif pagesValue==2
    pageNum = numel(binArray);
else
    pageNum = numel(ERPArray);
end
Pagecurrent = ERPwaviewer_CHANGE.PageIndex;
if  ERPwaviewer_CHANGE.PageIndex<= pageNum &&  ERPwaviewer_CHANGE.PageIndex>0
    if pagesValue==3
        ERPwaviewer_CHANGE.ERP   = ERPwaviewer_CHANGE.ALLERP(ERPArray(Pagecurrent));
        ERPwaviewer_CHANGE.CURRENTERP  =ERPArray(Pagecurrent);
    end
    
    assignin('base','ALLERPwaviewer',ERPwaviewer_CHANGE);
    MessageViewer= char(strcat('Plot prior page (<)'));
    erpworkingmemory('f_EEG_proces_messg',MessageViewer);
    observe_EEGDAT.page_xyaxis = observe_EEGDAT.page_xyaxis+1;%%change X/Y axis based on the changed pages
    observe_EEGDAT.eeg_message_panel=1;
    f_redrawEEG_Wave_Viewer();
    observe_EEGDAT.eeg_message_panel=2;
else
    return;
end
end


%------------------Display the waveform for next ERPset--------------------
function  page_plus(~,~)
global observe_EEGDAT
[messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
if ~isempty(messgStr)
    observe_EEGDAT.count_twopanels = observe_EEGDAT.count_twopanels +1;
end

try
    ERPwaviewer_CHANGE = evalin('base','ALLERPwaviewer');
catch
    beep;
    disp('Please re-run ERP wave viewer.');
    return;
end
ERPwaviewer_CHANGE.PageIndex = ERPwaviewer_CHANGE.PageIndex+1;
pagesValue =  ERPwaviewer_CHANGE.plot_org.Pages;
ERPArray = ERPwaviewer_CHANGE.SelectERPIdx;
chanArray =ERPwaviewer_CHANGE.chan;
binArray = ERPwaviewer_CHANGE.bin;
if pagesValue==1
    pageNum = numel(chanArray);
elseif pagesValue==2
    pageNum = numel(binArray);
else
    pageNum = numel(ERPArray);
end
Pagecurrent = ERPwaviewer_CHANGE.PageIndex;
if  ERPwaviewer_CHANGE.PageIndex<= pageNum &&  ERPwaviewer_CHANGE.PageIndex>0%% within the page range
    if pagesValue==3
        ERPwaviewer_CHANGE.ERP   = ERPwaviewer_CHANGE.ALLERP(ERPArray(Pagecurrent));
        ERPwaviewer_CHANGE.CURRENTERP  =ERPArray(Pagecurrent);
    end
    assignin('base','ALLERPwaviewer',ERPwaviewer_CHANGE);
    observe_EEGDAT.page_xyaxis = observe_EEGDAT.page_xyaxis+1;%%change X/Y axis based on the changed pages
    MessageViewer= char(strcat('Plot next page (>)'));
    erpworkingmemory('f_EEG_proces_messg',MessageViewer);
    observe_EEGDAT.eeg_message_panel=1;
    f_redrawEEG_Wave_Viewer();
    observe_EEGDAT.eeg_message_panel=2;
else
    return;
end

end

function Show_command(~,~)
global observe_EEGDAT;
if isempty(observe_EEGDAT.EEG)
    return;
end
[messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
if ~isempty(messgStr)
    observe_EEGDAT.count_twopanels = observe_EEGDAT.count_twopanels +1;
end

ViewerName = estudioworkingmemory('viewername');
if isempty(ViewerName)
    ViewerName = char('My Viewer');
end
MessageViewer= char(strcat('Show Command'));
erpworkingmemory('f_EEG_proces_messg',MessageViewer);
try
    observe_EEGDAT.eeg_message_panel=1;
    OutputViewereegpar = f_preparms_erpwaviewer(ViewerName,'command');
    observe_EEGDAT.eeg_message_panel=2;
catch
    observe_EEGDAT.eeg_message_panel=3;
end
end



%%-------------------------Save figure as----------------------------------
function figure_saveas(~,~)
global observe_EEGDAT;
% addlistener(observe_EEGDAT,'Messg_EEG_change',@Messg_EEG_change);
if isempty(observe_EEGDAT.EEG)
    return;
end

[messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
if ~isempty(messgStr)
    observe_EEGDAT.count_twopanels = observe_EEGDAT.count_twopanels +1;
end


MessageViewer= char(strcat('Save Figure As'));
erpworkingmemory('f_EEG_proces_messg',MessageViewer);

pathstr = pwd;
namedef ='Myviewer.pdf';
[erpfilename, erppathname, indxs] = uiputfile({'*.pdf';'*.svg';'*.jpg';'*.png';'*.tif';'*.bmp';'*.eps'},...
    'Save as',[fullfile(pathstr,namedef)]);


if isequal(erpfilename,0)
    beep;
    observe_EEGDAT.eeg_message_panel=3;
    disp('User selected Cancel')
    return
end

History = 'off';
[pathstr, erpfilename1, ext] = fileparts(erpfilename) ;

if isempty(ext)
    erpfilename = fullfile(erppathname,char(strcat(erpfilename,'.pdf')));
else
    erpfilename = fullfile(erppathname,erpfilename);
end

try
    observe_EEGDAT.eeg_message_panel=1;
    OutputViewereegpar = f_preparms_erpwaviewer(erpfilename,History);
    observe_EEGDAT.eeg_message_panel=2;
catch
    observe_EEGDAT.eeg_message_panel=3;
end

end


%%-----------------Pop figure---------------------------------------------
function figure_out(~,~)
global observe_EEGDAT;

if isempty(observe_EEGDAT.EEG)
    return;
end

[messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
if ~isempty(messgStr)
    observe_EEGDAT.count_twopanels = observe_EEGDAT.count_twopanels +1;
end

ViewerName = estudioworkingmemory('viewername');
if isempty(ViewerName)
    ViewerName = char('My Viewer');
end
MessageViewer= char(strcat('Create Static/Exportable Plot'));
erpworkingmemory('f_EEG_proces_messg',MessageViewer);
try
    observe_EEGDAT.eeg_message_panel=1;
    OutputViewereegpar = f_preparms_erpwaviewer(ViewerName,'script');
    observe_EEGDAT.eeg_message_panel=2;
catch
    observe_EEGDAT.eeg_message_panel=3;
end
end



%%Reset each panel that using the default parameters
function Panel_Reset(~,~)
global observe_EEGDAT;
global EStudio_gui_erp_totl

if isempty(observe_EEGDAT.EEG)
    return;
end

estudioworkingmemory('MERPWaveViewer_label',[]);
estudioworkingmemory('MERPWaveViewer_others',[]);

MessageViewer= char(strcat('Reset'));
erpworkingmemory('f_EEG_proces_messg',MessageViewer);

try
    observe_EEGDAT.eeg_message_panel=1;
%     observe_EEGDAT.Reset_Waviewer_panel=1;
    estudioworkingmemory('zoomSpace',0);
    f_redrawEEG_Wave_Viewer();
    observe_EEGDAT.eeg_message_panel=2;
catch
    observe_EEGDAT.eeg_message_panel=3;
end

%%Reset the window size and position
new_pos = [0.01,0.01,75,75];
erpworkingmemory('ERPWaveScreenPos',new_pos);
try
    ScreenPos =  get( groot, 'Screensize' );
catch
    ScreenPos =  get( 0, 'Screensize' );
end
EStudio_gui_erp_totl.screen_pos = new_pos;
new_pos =[ScreenPos(3)*new_pos(1)/100,ScreenPos(4)*new_pos(2)/100,ScreenPos(3)*new_pos(3)/100,ScreenPos(4)*new_pos(4)/100];
set(EStudio_gui_erp_totl.Window, 'Position', new_pos);

end





%%------------------------Message panel------------------------------------
function eeg_message_panel_change(~,~)
global observe_EEGDAT;
global EStudio_gui_erp_totl;
FonsizeDefault = f_get_default_fontsize();

try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;%%Get background color
catch
    ColorB_def = [0.7020 0.77 0.85];
end
if isempty(ColorB_def) || numel(ColorB_def)~=3 || min(ColorB_def(:))<0 || max(ColorB_def(:))>1
    ColorB_def = [0.7020 0.77 0.85];
end
EStudio_gui_erp_totl.eegProcess_messg.BackgroundColor = [0.95 0.95 0.95];
EStudio_gui_erp_totl.eegProcess_messg.FontSize = FonsizeDefault;
Processed_Method=erpworkingmemory('f_EEG_proces_messg');
if observe_EEGDAT.eeg_message_panel==1
    EStudio_gui_erp_totl.eegProcess_messg.String =  strcat('1- ',Processed_Method,': Running....');
    EStudio_gui_erp_totl.eegProcess_messg.ForegroundColor = [0 0 0];
elseif observe_EEGDAT.eeg_message_panel==2
    EStudio_gui_erp_totl.eegProcess_messg.String =  strcat('2- ',Processed_Method,': Complete');
    EStudio_gui_erp_totl.eegProcess_messg.ForegroundColor = [0 0.5 0];
    
elseif observe_EEGDAT.eeg_message_panel==3
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
if observe_EEGDAT.eeg_message_panel==1 || observe_EEGDAT.eeg_message_panel==2 || observe_EEGDAT.eeg_message_panel==3
    pause(0.01);
    EStudio_gui_erp_totl.eegProcess_messg.String = '';
    EStudio_gui_erp_totl.eegProcess_messg.BackgroundColor = ColorB_def;%[0.95 0.95 0.95];
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%-------------------------------Plot eeg waves--------------------------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function errmeg = f_plotviewereegwave(EEG,ChanArray,ICArray,EEGdispFlag,ICdispFlag,Winlength,...
    ScaleV,channeLabel,Submean,Plotevent,StackFlag,NormFlag,EEG_startime,myeegviewer)
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
    errmeg  = 'either original data or IC data was set to be plotted';
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
    ScaleV = 50;
end
if isempty(ScaleV) || numel(ScaleV)~=1 || ScaleV==0
    ScaleV = 50;
end
OldScaleV = ScaleV;

%%channe labels (name or number)
if nargin<8
    channeLabel = 1;
end
if isempty(channeLabel) || numel(channeLabel)~=1 || (channeLabel~=0 && channeLabel~=1)
    channeLabel = 1;
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
    Plotevent = 1;
end
if isempty(Plotevent) ||  numel(Plotevent)~=1 || (Plotevent~=0 && Plotevent~=1)
    Plotevent = 1;
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

% EEG_startime =20;
%%start time for the displayed data
if nargin < 13
    EEG_startime=0;
end

[ChanNum,Allsamples,tmpnb] = size(EEG.data);
Allsamples = Allsamples*tmpnb;
if ndims(EEG.data) > 2
    multiplier = size(EEG.data,2);
else
    multiplier = EEG.srate;
end

if isempty(EEG_startime) || EEG_startime<0 ||  EEG_startime>(ceil((Allsamples-1)/multiplier)-Winlength)
    EEG_startime=0;
end

%%determine the time range that will be dispalyed
lowlim = round(EEG_startime*multiplier+1);
highlim = round(min((EEG_startime+Winlength)*multiplier,Allsamples));


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
    %     Plotevent       = 1;
end

if isempty(Events)
    Plotevent      = 0;
end


chanNum = numel(ChanArray);


%%-------------------------------IC data----------------------------------
dataica = [];
meandataica =[];
if ICdispFlag==1
    if ~isempty(EEG.icaweights) && ~isempty(ICArray)%%pop_eegplot from eeglab
        tmpdata = eeg_getdatact(EEG, 'component', [1:size(EEG.icaweights,1)]);
        dataica = tmpdata(ICArray,:);
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
data = [];
meandata = [];
if EEGdispFlag==1
    data = EEG.data(ChanArray,:);
    switch Submean % subtract the mean ?
        case 1
            meandata = mean(data(:,lowlim:highlim)');
            if any(isnan(meandata))
                meandata = nan_mean(data(:,lowlim:highlim)');
            end
        otherwise, meandata = zeros(1,numel(ChanArray));
    end
    
end

%%---------------------------Normalize-------------------------------------
if NormFlag==1
    %%Norm for origanal
    %     data2 = [];
    if ~isempty(data)
        datastd = std(data(:,1:min(1000,Allsamples)),[],2);%
        for i = 1:size(data,1)
            data(i,:,:) = data(i,:,:)*datastd(i);
            %             if ~isempty(data2)
            %                 data2(i,:,:) = data2(i,:,:)*datastd(i);
            %             end
        end
    end
    
    %%norm for IC data
    if ~isempty(dataica)
        tmpdata = eeg_getdatact(EEG, 'component', [1:size(EEG.icaweights,1)]);
        dataica1 = tmpdata(ICArray,:);
        dataicstd = std(dataica(:,1:min(1000,Allsamples)),[],2);
        for i = 1:size(dataica,1)
            dataica(i,:,:) = dataica(i,:,:)*dataicstd(i);
            %        if ~isempty(data2)
            %            data2(i,:,:) = data2(i,:,:)*dataicstd(i);
            %        end
        end
    end
end


data = [data;dataica];
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
Ploteventdur =1;
Trialstag = size(EEG.data,2);
GapSize = ceil(numel([lowlim:highlim])/40);
if GapSize<=2
    GapSize=5;
end
% -------------------------------------------------------------------------
% -------------------------draw events if any------------------------------
% -------------------------------------------------------------------------
 ylims = [0 (PlotNum+1)*ScaleV];
if Plotevent==1
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
        %         if Ploteventdur && ~isempty(Eventlatencyend) ...
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
    ScaleV=0;
end
DEFAULT_GRID_SPACING =Winlength/5;

% -------------------------------------------------------------------------
% -----------------draw EEG wave if any------------------------------------
% -------------------------------------------------------------------------
%%Plot continuous EEG
tmpcolor = [ 0 0 0.4 ];
if ndims(EEG.data)==2
    if ~isempty(data) && PlotNum~=0
        plot(myeegviewer, bsxfun(@plus, data(end:-1:1,lowlim:highlim), ScaleV*[1:PlotNum]'-meandata(end:-1:1)')' + (PlotNum+1)*(OldScaleV-ScaleV)/2 +0*(OldScaleV-ScaleV), ...
            'color', tmpcolor, 'clipping','on','LineWidth',0.5);%%
        set(myeegviewer,'TickDir', 'in','LineWidth',1);
        %%xtick
        ScaleV = OldScaleV;
        set(myeegviewer, 'Xlim',[1 Winlength*multiplier],...
            'XTick',[1:multiplier*DEFAULT_GRID_SPACING:Winlength*multiplier+1]);
        set(myeegviewer, 'XTickLabel', num2str((EEG_startime:DEFAULT_GRID_SPACING:EEG_startime+Winlength)'));
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
        
        plot(myeegviewer, bsxfun(@plus, dataplot(end:-1:1,:), ScaleV*[1:PlotNum]'-meandata(end:-1:1)')' + (PlotNum+1)*(OldScaleV-ScaleV)/2 +0*(OldScaleV-ScaleV), ...
            'color', tmpcolor, 'clipping','on','LineWidth',0.5);%%
   
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
set(myeegviewer, 'ylim',[0 (PlotNum+1)*ScaleV],'YTick',[0:ScaleV:PlotNum*ScaleV]);
[YLabels,chaName,ICName] = f_eeg_read_chan_IC_names(EEG.chanlocs,ChanArray,ICArray,channeLabel);
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