%This function is to plot MVPC waves with single or multiple columns on one page.

% Author: Guanghui Zhang & Steve J. Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2024



function f_redrawmvpc_Wave_Viewer()
global observe_DECODE;
global EStudio_gui_erp_totl;

FonsizeDefault = f_get_default_fontsize();
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;%%Get background color
catch
    ColorB_def = [0.702,0.77,0.85];
end
if isempty(ColorB_def)
    ColorB_def = [0.702,0.77,0.85];
end

set(0,'units','pixels')
Pix_SS = get(0,'screensize');
set(0,'units','inches')
Inch_SS = get(0,'screensize');
Resolation = Pix_SS./Inch_SS;

try
    EStudio_gui_erp_totl.decode_VerticalOffsets = EStudio_gui_erp_totl.View_decode_Axes.VerticalOffsets/EStudio_gui_erp_totl.View_decode_Axes.Heights;
    EStudio_gui_erp_totl.decode_HorizontalOffsets = EStudio_gui_erp_totl.View_decode_Axes.HorizontalOffsets/EStudio_gui_erp_totl.View_decode_Axes.Widths;
catch
    EStudio_gui_erp_totl.decode_VerticalOffsets=0;
    EStudio_gui_erp_totl.decode_HorizontalOffsets=0;
end
if ishandle( EStudio_gui_erp_totl.View_decode_Axes )
    delete( EStudio_gui_erp_totl.View_decode_Axes );
end
zoomSpace = estudioworkingmemory('DecodeTab_zoomSpace');
if isempty(zoomSpace)
    zoomSpace = 100;
else
    if zoomSpace<100
        zoomSpace =100;
    end
end
if zoomSpace ==100
    EStudio_gui_erp_totl.decode_VerticalOffsets=0;
    EStudio_gui_erp_totl.decode_HorizontalOffsets=0;
end

if ~isempty(observe_DECODE.ALLMVPC)  && ~isempty(observe_DECODE.MVPC)
    Enableflag = 'on';
else
    Enableflag = 'off';
end
Decode_autoplot = EStudio_gui_erp_totl.Decode_autoplot;
if Decode_autoplot==1
    Enableflag = 'on';
else
    Enableflag = 'off';
end

set(EStudio_gui_erp_totl.decode_zoom_in,'Callback',@zoomin,'Enable',Enableflag);
set(EStudio_gui_erp_totl.decode_zoom_edit,'Callback',@zoomedit,'Enable',Enableflag,'String',num2str(zoomSpace));
set(EStudio_gui_erp_totl.decode_zoom_out,'Callback',@zoomout,'Enable',Enableflag);

if ~isempty(observe_DECODE.ALLMVPC) && ~isempty(observe_DECODE.MVPC)
    set(EStudio_gui_erp_totl.decode_popmemu,'String',{'Plotting Options','Automatic Plotting','Window Size','Show Command','Save Figure as','Create Static/Exportable Plot'},...
        'Callback',@decode_popmemu);
else
    set(EStudio_gui_erp_totl.decode_popmemu,'String',{'Plotting Options','Automatic Plotting','Window Size'},...
        'Enable','on','BackgroundColor',ColorB_def,'Callback',@decode_popmemu);
end
decode_popmemu = EStudio_gui_erp_totl.decode_popmemu.String;
if Decode_autoplot==1
    decode_popmemu{2} = 'Automatic Plotting: On';
else
    decode_popmemu{2} = 'Automatic Plotting: Off';
end
EStudio_gui_erp_totl.decode_popmemu.String=decode_popmemu;
set(EStudio_gui_erp_totl.decode_reset,'Callback', @decode_reset,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','on');
if Decode_autoplot==0
    EStudio_gui_erp_totl.Process_decode_messg.String='Plotting is disabled, to enable it, please go to "Plotting Options" at the bottom of the plotting area to active it.';
end

EStudio_gui_erp_totl.plot_decode_grid.Heights(1) = 70;% set the first element (pageinfo) to 30px high
EStudio_gui_erp_totl.plot_decode_grid.Heights(3) = 5;
EStudio_gui_erp_totl.plot_decode_grid.Heights(4) = 30;
EStudio_gui_erp_totl.plot_decode_grid.Heights(5) = 30;% set the second element (x axis) to 30px high
EStudio_gui_erp_totl.plot_decode_grid.Units = 'pixels';
EStudio_gui_erp_totl.View_decode_Axes = uix.ScrollingPanel( 'Parent', EStudio_gui_erp_totl.plot_decode_legend,'BackgroundColor',[1 1 1]);

if isempty(observe_DECODE.ALLMVPC)  ||  isempty(observe_DECODE.MVPC) || Decode_autoplot==0
    EStudio_gui_erp_totl.mvpcwave_Axes = axes('Parent', EStudio_gui_erp_totl.View_decode_Axes,'Color','none','Box','on','FontWeight','normal');
    set(EStudio_gui_erp_totl.mvpcwave_Axes, 'XTick', [], 'YTick', [],'Box','off', 'Color','none','xcolor','none','ycolor','none');
end

if ~isempty(observe_DECODE.ALLMVPC) && ~isempty(observe_DECODE.MVPC) && Decode_autoplot==1
    EStudio_gui_erp_totl.mvpcwave_Axes = axes('Parent', EStudio_gui_erp_totl.View_decode_Axes,'Color','none','Box','on','FontWeight','normal');
    hold(EStudio_gui_erp_totl.mvpcwave_Axes,'on');
    EStudio_gui_erp_totl.mvpcwave_Axes_legend = axes('Parent', EStudio_gui_erp_totl.View_decode_Axes_legend,'Color','none','Box','off');
    hold(EStudio_gui_erp_totl.mvpcwave_Axes_legend,'on');
    set(EStudio_gui_erp_totl.mvpcwave_Axes_legend, 'XTick', [], 'YTick', [],'Box','off', 'Color','none','xcolor','none','ycolor','none');
    MVPC = observe_DECODE.MVPC;
    OutputViewerparerp = f_preparms_decodetab(MVPC,0);
    
    % %%Plot the eeg waves
    if ~isempty(OutputViewerparerp)
        f_plotabmvpcwave(observe_DECODE.ALLMVPC,OutputViewerparerp{1}, OutputViewerparerp{2},OutputViewerparerp{3},...
            OutputViewerparerp{4},OutputViewerparerp{5},OutputViewerparerp{6},OutputViewerparerp{7},...
            OutputViewerparerp{8},OutputViewerparerp{9},OutputViewerparerp{10},OutputViewerparerp{11},...
            OutputViewerparerp{12},OutputViewerparerp{13},OutputViewerparerp{14},OutputViewerparerp{15},...
            OutputViewerparerp{16},OutputViewerparerp{17},OutputViewerparerp{18},OutputViewerparerp{19},...
            OutputViewerparerp{20},OutputViewerparerp{21},OutputViewerparerp{22},OutputViewerparerp{23},...
            OutputViewerparerp{24},EStudio_gui_erp_totl.mvpcwave_Axes,EStudio_gui_erp_totl.mvpcwave_Axes_legend);
    else
        return;
    end
    pb_height =  1*Resolation(4);
    
    if pb_height<(EStudio_gui_erp_totl.plot_decode_grid.Position(4)-EStudio_gui_erp_totl.plot_decode_grid.Heights(1))
        pb_height = 0.9*(EStudio_gui_erp_totl.plot_decode_grid.Position(4)-EStudio_gui_erp_totl.plot_decode_grid.Heights(1)-EStudio_gui_erp_totl.plot_decode_grid.Heights(2));
    else
        pb_height = 0.9*pb_height;
    end
    zoomSpace = zoomSpace-100;
    if zoomSpace <=0
        EStudio_gui_erp_totl.View_decode_Axes.Heights = 0.95*EStudio_gui_erp_totl.View_decode_Axes.Position(4);
    else
        EStudio_gui_erp_totl.View_decode_Axes.Heights = pb_height*(1+zoomSpace/100);
    end
    
    widthViewer = EStudio_gui_erp_totl.View_decode_Axes.Position(3)-EStudio_gui_erp_totl.View_decode_Axes.Position(2);
    if zoomSpace <=0
        EStudio_gui_erp_totl.View_decode_Axes.Widths = widthViewer;
    else
        EStudio_gui_erp_totl.View_decode_Axes.Widths = widthViewer*(1+zoomSpace/100);
    end
    
    %%Keep the same positions for Vertical and Horizontal scrolling bars asbefore
    if zoomSpace~=0 && zoomSpace>0
        if EStudio_gui_erp_totl.decode_VerticalOffsets<=1
            try
                EStudio_gui_erp_totl.View_decode_Axes.VerticalOffsets= EStudio_gui_erp_totl.decode_VerticalOffsets*EStudio_gui_erp_totl.View_decode_Axes.Heights;
            catch
            end
        end
        if EStudio_gui_erp_totl.decode_HorizontalOffsets<=1
            try
                EStudio_gui_erp_totl.View_decode_Axes.HorizontalOffsets =EStudio_gui_erp_totl.decode_HorizontalOffsets*EStudio_gui_erp_totl.View_decode_Axes.Widths;
            catch
            end
        end
    end
end
EStudio_gui_erp_totl.View_decode_Axes.Children.Title.Color = [1 0 0];
end


%%-------------------------------------------------------------------------
%%-----------------------------Subfunctions--------------------------------
%%-------------------------------------------------------------------------
function decode_popmemu(Source,~)
global EStudio_gui_erp_totl;
Value = Source.Value;
if Value==2
    app = feval('EStudio_plot_set_waves',EStudio_gui_erp_totl.Decode_autoplot,2);
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
    popmemu_eegString = EStudio_gui_erp_totl.decode_popmemu.String;
    if plotSet==1
        popmemu_eegString{2} = 'Automatic Plotting: On';
    else
        popmemu_eegString{2} = 'Automatic Plotting: Off';
    end
    EStudio_gui_erp_totl.decode_popmemu.String=popmemu_eegString;
    EStudio_gui_erp_totl.Decode_autoplot = plotSet;
    f_redrawmvpc_Wave_Viewer();
elseif Value==3
    EStudiowinsize();
elseif Value==4
    Advanced_viewer();
elseif Value==5
    Show_command();
elseif Value==6
    figure_saveas();
elseif Value==7
    figure_out();
end
Source.Value=1;
end



%%----------------Zoom in-------------------------------------------------
function zoomin(~,~)
global observe_DECODE;

[messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
if ~isempty(messgStr)
    observe_DECODE.Count_currentMVPC=eegpanelIndex+1;
end
zoomSpace = estudioworkingmemory('DecodeTab_zoomSpace');
if isempty(zoomSpace)
    estudioworkingmemory('DecodeTab_zoomSpace',0);
else
    if zoomSpace<100
        zoomSpace = 100;
    end
    zoomSpace =zoomSpace+50;
    estudioworkingmemory('DecodeTab_zoomSpace',zoomSpace) ;
end
MessageViewer= char(strcat('Zoom In'));
estudioworkingmemory('f_ERP_proces_messg',MessageViewer);
try
    observe_DECODE.Process_messg =1;
   f_redrawmvpc_Wave_Viewer();
    observe_DECODE.Process_messg =2;
catch
    observe_DECODE.Process_messg =3;
end
end


function zoomedit(Source,~)
global observe_DECODE;

[messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
if ~isempty(messgStr)
    observe_DECODE.Count_currentMVPC=eegpanelIndex+1;
end

zoomspaceEdit = str2num(Source.String);
MessageViewer= char(strcat('Zoom Editor'));
estudioworkingmemory('f_ERP_proces_messg',MessageViewer);
if ~isempty(zoomspaceEdit) && numel(zoomspaceEdit)==1 && zoomspaceEdit>=100
    estudioworkingmemory('DecodeTab_zoomSpace',zoomspaceEdit);
    try
        observe_DECODE.Process_messg =1;
       f_redrawmvpc_Wave_Viewer();
        observe_DECODE.Process_messg =2;
        return;
    catch
        observe_DECODE.Process_messg =3;
        return;
    end
else
    if isempty(zoomspaceEdit)
        estudioworkingmemory('f_ERP_proces_messg',['\n Zoom Editor:The input must be a number']);
        observe_DECODE.Process_messg =4;
        return;
    end
    if numel(zoomspaceEdit)>1
        estudioworkingmemory('f_ERP_proces_messg',['Zoom Editor:The input must be a single number']);
        observe_DECODE.Process_messg =4;
        return;
    end
    if zoomspaceEdit<100
        estudioworkingmemory('f_ERP_proces_messg',[' Zoom Editor:The input must not be smaller than 100.']);
        observe_DECODE.Process_messg =4;
        return;
    end
end

end


%%----------------Zoom out-------------------------------------------------
function zoomout(~,~)
global observe_DECODE;

[messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
if ~isempty(messgStr)
    observe_DECODE.Count_currentMVPC=eegpanelIndex+1;
end

zoomSpace = estudioworkingmemory('DecodeTab_zoomSpace');
if isempty(zoomSpace)
    estudioworkingmemory('DecodeTab_zoomSpace',0)
else
    zoomSpace =zoomSpace-50;
    if zoomSpace <100
        zoomSpace =100;
    end
    estudioworkingmemory('DecodeTab_zoomSpace',zoomSpace) ;
end
MessageViewer= char(strcat('Zoom Out'));
estudioworkingmemory('f_ERP_proces_messg',MessageViewer);
observe_DECODE.Process_messg =1;
f_redrawmvpc_Wave_Viewer();
observe_DECODE.Process_messg =2;
end



%%--------------------Setting for EStudio window size----------------------
function EStudiowinsize(~,~)
global EStudio_gui_erp_totl;
global observe_DECODE;

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
    New_posin = estudioworkingmemory('EStudioScreenPos');
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
    estudioworkingmemory('f_ERP_proces_messg',['The defined Window Size for EStudio is invalid and it must be two numbers']);
    observe_DECODE.Process_messg =4;
    return;
end
estudioworkingmemory('EStudioScreenPos',New_pos1);
try
    POS4 = (New_pos1(2)-New_posin(2))/100;
    new_pos =[New_pos(1),New_pos(2)-ScreenPos(4)*POS4,ScreenPos(3)*New_pos1(1)/100,ScreenPos(4)*New_pos1(2)/100];
    if new_pos(2) <  -abs(new_pos(4))%%if
        
    end
    set(EStudio_gui_erp_totl.Window, 'Position', new_pos);
catch
    estudioworkingmemory('f_ERP_proces_messg',['The defined Window Size for EStudio is invalid and it must be two numbers']);
    observe_DECODE.Process_messg =4;
    set(EStudio_gui_erp_totl.Window, 'Position', [0 0 0.75*ScreenPos(3) 0.75*ScreenPos(4)]);
    estudioworkingmemory('EStudioScreenPos',[75 75]);
end
f_redrawEEG_Wave_Viewer();
f_redrawERP();
 f_redrawmvpc_Wave_Viewer();
EStudio_gui_erp_totl.context_tabs.TabSize = (new_pos(3)-20)/length(EStudio_gui_erp_totl.context_tabs.TabNames);
%         EStudio_gui_erp_totl.context_tabs.TabSize = (new_pos(3)-20)/3;
end




%%--------------------------show the command-------------------------------
function Show_command(~,~)
global observe_DECODE;
if isempty(observe_DECODE.ALLMVPC) || isempty(observe_DECODE.MVPC)
    return;
end
[messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
if ~isempty(messgStr)
    observe_DECODE.Count_currentMVPC=eegpanelIndex+1;%%call the functions from the other panel
end
estudioworkingmemory('f_ERP_proces_messg','Show Command');
observe_DECODE.Process_messg =1;
f_preparms_erptab(observe_DECODE.MVPC,1,'command');
observe_DECODE.Process_messg =2;
end

%%----------------------------save figure as-------------------------------
function figure_saveas(~,~)
global observe_DECODE;
if isempty(observe_DECODE.ALLMVPC) || isempty(observe_DECODE.MVPC)
    return;
end
[messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
if ~isempty(messgStr)
    observe_DECODE.Count_currentMVPC=eegpanelIndex+1;%%call the functions from the other panel
end

estudioworkingmemory('f_ERP_proces_messg','Save figure as');
observe_DECODE.Process_messg =1;
pathstr = pwd;
namedef =[observe_DECODE.MVPC.erpname,'.pdf'];
[erpfilename, erppathname, indxs] = uiputfile({'*.pdf';'*.svg';'*.jpg';'*.png';'*.tif';'*.bmp';'*.eps'},...
    'Save as',[fullfile(pathstr,namedef)]);


if isequal(erpfilename,0)
    beep;
    observe_DECODE.Process_messg =3;
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

f_preparms_erptab(observe_DECODE.MVPC,1,History,figurename);
observe_DECODE.Process_messg =2;
end

%%--------------------Create static/eportable plot-------------------------
function figure_out(~,~)
global observe_DECODE;
if isempty(observe_DECODE.ALLMVPC) || isempty(observe_DECODE.MVPC)
    return;
end
[messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
if ~isempty(messgStr)
    observe_DECODE.Count_currentMVPC=eegpanelIndex+1;%%call the functions from the other panel
end

MessageViewer= char(strcat('Create Static/Exportable Plot'));
estudioworkingmemory('f_ERP_proces_messg',MessageViewer);
observe_DECODE.Process_messg =1;
try
    figurename = observe_DECODE.MVPC.erpname;
catch
    figurename = '';
end
History = 'off';
f_preparms_erptab(observe_DECODE.MVPC,1,History,figurename);
observe_DECODE.Process_messg =2;
end


%%------------------------Reset parameters---------------------------------
function decode_reset(~,~)
global observe_DECODE;
global EStudio_gui_erp_totl;
global observe_EEGDAT;

estudioworkingmemory('ViewerFlag', 0);

MessageViewer= char(strcat('Reset parameters for ERP panels '));
estudioworkingmemory('f_ERP_proces_messg',MessageViewer);
app = feval('estudio_reset_paras',[0 0 1 0]);
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
EStudio_gui_erp_totl.Decode_autoplot=1;
EStudio_gui_erp_totl.EEG_autoplot = 1;
%%---------------------------EEG Tab---------------------------------------
if reset_paras(2)==1
    EStudio_gui_erp_totl.clear_alleeg = 1;
else
    EStudio_gui_erp_totl.clear_alleeg = 0;
end

if reset_paras(1)==1
    if ~isempty(observe_EEGDAT.EEG) && ~isempty(observe_EEGDAT.ALLEEG)
        observe_EEGDAT.Reset_eeg_paras_panel=1;
    end
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


%%---------------- -------------erp tab------------------------------------
if reset_paras(4)==1
    EStudio_gui_erp_totl.clear_allerp = 1;
else
    EStudio_gui_erp_totl.clear_allerp = 0;
end
observe_DECODE.Process_messg =1;
if reset_paras(3)==1
    if ~isempty(observe_DECODE.MVPC) && ~isempty(observe_DECODE.ALLMVPC)
        observe_DECODE.Reset_erp_paras_panel = 1;
    end
    if EStudio_gui_erp_totl.clear_allerp == 0
        f_redrawERP();
    else
        observe_DECODE.ALLMVPC = [];
        observe_DECODE.MVPC = [];
        observe_DECODE.CURRENTMVPC  = 1;
        estudioworkingmemory('MVPCArray',1);
    end
else
    if EStudio_gui_erp_totl.clear_allerp == 1
        
        observe_DECODE.ALLMVPC = [];
        observe_DECODE.MVPC = [];
        observe_DECODE.CURRENTMVPC  = 1;
        estudioworkingmemory('MVPCArray',1);
    end
end
observe_DECODE.Count_currentMVPC = 1;
observe_DECODE.Process_messg =2;
end






function f_plotabmvpcwave(ALLMVPC,MVPCArray,qtimeRange,qXticks,qXtickdecimal,Xlabelfont,Xlabelfontsize,Xlabelcolor,...
    qYScales,qYticks,qYtickdecimal,qYlabelfont,qYlabelfontsize,qYlabelcolor,Standerr,Transparency,...
    qLineColorspec,qLineStylespec,qLineMarkerspec,qLineWidthspec,qFontLeg,qTextcolorLeg,qLegcolumns,qFontSizeLeg,chanLevel,...
    waveview,legendview)

%%------------Get the data and SEM (standard error of the mean)------------
if isempty(MVPCArray) || any(MVPCArray(:)<1) || any(MVPCArray(:)>length(ALLMVPC))
    MVPCArray  = length(ALLMVPC);
end
[serror, msgwrng] = f_checkmvpc(ALLMVPC,MVPCArray);
if serror==1
    MVPCArray  = length(ALLMVPC);
end
MVPC = ALLMVPC(MVPCArray(1));


[bindata,bindataerror,timesnew] = f_getmvpcdata(ALLMVPC,MVPCArray,qtimeRange);

%%xticks
[timeticksdef stepX]= default_time_ticks_decode(MVPC, qtimeRange);
if isempty(qXticks)
    qXticks =  str2num(timeticksdef);
end
%%precision
if isempty(qXtickdecimal) || ~isnumeric(qXtickdecimal) || numel(qXtickdecimal)~=1 || any(qXtickdecimal(:)<1)
    qXtickdecimal=0;
end


%%font for x axis
if isempty(Xlabelfont) || ~ischar(Xlabelfontsize)
    Xlabelfont = 'Helvetica';
end
%%font size for x axis
if isempty(Xlabelfontsize) || ~isnumeric(Xlabelfontsize) || numel(Xlabelfontsize)~=1
    Xlabelfontsize = 12;
end
%%text color for x axis
if isempty(Xlabelcolor) || ~isnumeric(Xlabelcolor) || any(Xlabelcolor(:)<0) || any(Xlabelcolor(:)>1) || numel(Xlabelcolor)~=3
    Xlabelcolor = [0 0 0];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%------------------------settings for y axis------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[def, minydef, maxydef] = default_amp_ticks_decode(ALLMVPC(MVPCArray));
if ~isempty(minydef) && ~isempty(maxydef)
    if minydef==maxydef
        minydef=0;
        maxydef=1;
    end
elseif isempty(minydef) || isempty(maxydef)
    minydef=0;
    maxydef=1;
end
%%y scale
y_scale_def = [minydef,maxydef];
if isempty(qYScales) || numel(qYScales)~=2
    qYScales = y_scale_def;
end
%%y ticks
defyticks = default_amp_ticks_viewer(qYScales);
qYticksdef = str2num(defyticks);
if isempty(qYticks) || numel(qYticks)<2
    qYticks = qYticksdef;
end
%%precision
if isempty(qYtickdecimal) || ~isnumeric(qYtickdecimal) || numel(qYtickdecimal)~=1 || any(qYtickdecimal(:)<1)
    qYtickdecimal=1;
end
%%font for y axis
if isempty(qYlabelfont) %%|| ~char(qYlabelfont)
    qYlabelfont = 'Helvetica';
end
%%font size for y axis
if isempty(qYlabelfontsize) || numel(qYlabelfontsize)~=1 || any(qYlabelfontsize(:)<1)
    qYlabelfontsize = 12;
end
%%text color for y axis
if isempty(qYlabelcolor) || ~isnumeric(qYlabelcolor) || numel(qYlabelcolor)~=3 || any(qYlabelcolor(:)<0) || any(qYlabelcolor(:)>1)
    qYlabelcolor = [0 0 0];
end

%%standard error of mean
if isempty(Standerr) || numel(Standerr)~=1 || any(Standerr<0) || any(Standerr>10)
    Standerr=1;
end
if isempty(Transparency) || numel(Transparency)~=1 || any(Transparency<0)|| any(Transparency>1)
    Transparency=0.2;
end


%%line color
for Numofmvpc = 1:numel(MVPCArray)
    try
        colornames =  qLineColorspec(Numofmvpc,:);
        if isempty(colornames) || numel(colornames)~=3 || any(colornames(:)<0)|| any(colornames(:)>1)
            colornames = [0 0 0];
        end
        qLineColorspec(Numofmvpc,:) = colornames;
    catch
        qLineColorspec(Numofmvpc,:)  = [0 0 0];
    end
end


%%line styles
for Numofmvpc = 1:numel(MVPCArray)
    try
        colornames =  qLineStylespec{Numofmvpc};
        if isempty(colornames) || ~ischar(colornames) || ~ismember_bc2({'-','--',':','-.','none'},colornames)
            colornames = 'none';
        end
        qLineStylespec{Numofmvpc} = colornames;
    catch
        qLineStylespec{Numofmvpc}  = '-';
    end
end
%%line marks
for Numofmvpc = 1:numel(MVPCArray)
    try
        colornames =  qLineMarkerspec{Numofmvpc};
        if isempty(colornames) || ~ischar(colornames)
            colornames = 'none';
        end
        qLineMarkerspec{Numofmvpc} = colornames;
    catch
        qLineMarkerspec{Numofmvpc}  = 'none';
    end
end
%%line width
for Numofmvpc = 1:numel(MVPCArray)
    try
        linewidthone =  qLineWidthspec(Numofmvpc);
        if isempty(linewidthone) || ~isnumeric(linewidthone) || any(linewidthone(:)<1)
            linewidthone =1;
        end
        qLineWidthspec(Numofmvpc) = linewidthone;
    catch
        qLineWidthspec(Numofmvpc)  = 1;
    end
end

if isempty(chanLevel) || numel(chanLevel)~=1 || (chanLevel~=0 && chanLevel~=1)
    chanLevel=1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%------------------------------setting for legend-------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(qFontLeg) || ~ischar(qFontLeg)
    qFontLeg ='Helvetica';
end

if isempty(qTextcolorLeg) || ~isnumeric(qTextcolorLeg) || numel(qTextcolorLeg)~=1 || (qTextcolorLeg~=0 && qTextcolorLeg~=1)
    qTextcolorLeg=1;
end
if isempty(qLegcolumns) || ~isnumeric(qLegcolumns) || numel(qLegcolumns)~=1|| any(qLegcolumns(:)<1)
    qLegcolumns = ceil(sqrt(numel(MVPCArray)));
end

if isempty(qFontSizeLeg) || ~isnumeric(qFontSizeLeg) || numel(qFontSizeLeg)~=1 || any(qFontSizeLeg(:)<1)
    qFontSizeLeg = 12;
end


%%remove the margins of a plot
ax = waveview;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
% ax.Position = [left bottom ax_width ax_height];
% ax.Position(3:4) = [ax_width ax_height];

%%check elements in qGridposArray
hplot11 = [];
if chanLevel==1
    yline(waveview,ALLMVPC(MVPCArray(1)).chance,'--','Color' ,[0 0 0],'LineWidth',1);
end
for Numofoverlay = 1:numel(MVPCArray)
    bindatatrs = bindata(:,Numofoverlay);
    bindataerrtrs = bindataerror(:,Numofoverlay);
    if  Standerr>=1 &&Transparency>0 %SEM
        yt1 = bindatatrs - bindataerrtrs.*Standerr;
        yt2 = bindatatrs + bindataerrtrs.*Standerr;
        fill(waveview,[timesnew fliplr(timesnew)],[yt2' fliplr(yt1')], qLineColorspec(Numofoverlay,:), 'FaceAlpha', Transparency, 'EdgeColor', 'none');
    end
    try
        hplot11(Numofoverlay) = plot(waveview,timesnew, bindatatrs,'LineWidth',qLineWidthspec(Numofoverlay),...
            'Color', qLineColorspec(Numofoverlay,:),'Marker',char(qLineMarkerspec{Numofoverlay}),...
            'LineStyle',char(qLineStylespec{Numofoverlay}));
    catch
        hplot11(Numofoverlay) = plot(waveview,timesnew, bindatatrs,'LineWidth',1,...
            'Color', [0 0 0]);
    end
end
set(waveview,'box','off');
xlim(waveview,[timesnew(1),timesnew(end)]);
ylim(waveview,qYScales)
%%x axis
if ~isempty(qXticks)
    waveview.XAxis.TickValues = qXticks;
    for Numofytick = 1:numel(qXticks)
        xtick_label= sprintf(['%.',num2str(qXtickdecimal),'f'],qXticks(Numofytick));
        waveview.XAxis.TickLabels{Numofytick,1} = xtick_label;
    end
end
waveview.XAxis.FontSize = Xlabelfontsize;
waveview.XAxis.FontName = Xlabelfont;
waveview.XAxis.Color = Xlabelcolor;
xlabel(waveview,'Time (ms)','FontSize',Xlabelfontsize,'FontWeight',...
    'normal','Color',Xlabelcolor,'FontName',Xlabelfont);
waveview.TickDir = 'out';
waveview.XAxis.LineWidth=1;

%%Y axis
if ~isempty(qYticks)
    waveview.YAxis.TickValues = qYticks;
    for Numofytick = 1:numel(qYticks)
        xtick_label= sprintf(['%.',num2str(qYtickdecimal),'f'],qYticks(Numofytick));
        waveview.YAxis.TickLabels{Numofytick,1} = xtick_label;
    end
end
waveview.YAxis.FontSize = qYlabelfontsize;
waveview.YAxis.FontName = qYlabelfont;
waveview.YAxis.Color = qYlabelcolor;
ylabel(waveview,'Decoding Accuracy','FontSize',qYlabelfontsize,'FontWeight',...
    'normal','Color',qYlabelcolor,'FontName',qYlabelfont);
waveview.YAxis.LineWidth=1;
if ~isempty(hplot11)
    for Numofoverlay = 1:numel(hplot11)
        qLegendName{Numofoverlay} = strrep(ALLMVPC(MVPCArray(Numofoverlay)).mvpcname,'_','\_');
        if qTextcolorLeg==1
            legdcolor = [0 0 0];
        else
            legdcolor = qLineColorspec(Numofoverlay,:);
        end
        LegendName{Numofoverlay} = char(strcat('\color[rgb]{',num2str(legdcolor),'}',32,qLegendName{Numofoverlay}));
    end
    p  = get(legendview,'position');
    h_legend = legend(legendview,hplot11,LegendName);
    legend(legendview,'boxoff');
    set(h_legend,'NumColumns',qLegcolumns,'FontName', qFontLeg, 'Color', [1 1 1], 'position', p,'FontSize',qFontSizeLeg);
end
end


