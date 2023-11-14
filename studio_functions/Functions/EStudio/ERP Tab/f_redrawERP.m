%This function is to plot ERP waves with single or multiple columns on one page.



% Author: Guanghui Zhang & Steve J. Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022 & 2023 Oct



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
else
    pageNum=1;
    pagecurrentNum=1;
    PageStr = 'No ERPset was loaded';
    ERPArray= 1;
    estudioworkingmemory('selectederpstudio',1);
end
EStudio_gui_erp_totl.plotgrid = uix.VBox('Parent',EStudio_gui_erp_totl.ViewContainer,'Padding',0,'Spacing',0,'BackgroundColor',ColorB_def);

pageinfo_box = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plotgrid,'BackgroundColor',ColorB_def);

EStudio_gui_erp_totl.plot_wav_legend = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plotgrid,'BackgroundColor',[1 1 1]);
EStudio_gui_erp_totl.ViewAxes_legend = uix.ScrollingPanel( 'Parent', EStudio_gui_erp_totl.plot_wav_legend,'BackgroundColor',ColorB_def);

EStudio_gui_erp_totl.ViewAxes = uix.ScrollingPanel( 'Parent', EStudio_gui_erp_totl.plot_wav_legend,'BackgroundColor',[1 1 1]);

xaxis_panel = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plotgrid,'BackgroundColor',ColorB_def);%%%Message
EStudio_gui_erp_totl.Process_messg = uicontrol('Parent',xaxis_panel,'Style','text','String','','FontSize',FonsizeDefault,'FontWeight','bold','BackgroundColor',ColorB_def);

%%Setting title
EStudio_gui_erp_totl.pageinfo_minus = uicontrol('Parent',pageinfo_box,'Style', 'pushbutton', 'String', 'Prev.','Callback',{@page_minus,EStudio_gui_erp_totl},'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
EStudio_gui_erp_totl.pageinfo_edit = uicontrol('Parent',pageinfo_box,'Style', 'edit', 'String', num2str(pagecurrentNum),'Callback',{@page_edit,EStudio_gui_erp_totl},'FontSize',FonsizeDefault+2,'BackgroundColor',[1 1 1]);
EStudio_gui_erp_totl.pageinfo_plus = uicontrol('Parent',pageinfo_box,'Style', 'pushbutton', 'String', 'Next','Callback',{@page_plus,EStudio_gui_erp_totl},'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
pageinfo_str = ['Page',32,num2str(pagecurrentNum),'/',num2str(pageNum),':',32,PageStr];
EStudio_gui_erp_totl.pageinfo_text = uicontrol('Parent',pageinfo_box,'Style','text','String',pageinfo_str,'FontSize',FonsizeDefault);

EStudio_gui_erp_totl.advanced_viewer = uicontrol('Parent',pageinfo_box,'Style','pushbutton','String','Advanced Wave Viewer',...
    'Callback',@Advanced_viewer,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
if ~isempty(observe_ERPDAT.ALLERP)  && ~isempty(observe_ERPDAT.ERP)
    EStudio_gui_erp_totl.advanced_viewer.Enable = 'on';
else
    EStudio_gui_erp_totl.advanced_viewer.Enable = 'off';
end

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
set(pageinfo_box, 'Sizes', [50 50 50 -1 150] );
set(pageinfo_box,'BackgroundColor',ColorB_def);
set(EStudio_gui_erp_totl.pageinfo_text,'BackgroundColor',ColorB_def);

if isempty(observe_ERPDAT.ALLERP)  ||  isempty(observe_ERPDAT.ERP)
    EStudio_gui_erp_totl.erptabwaveiwer = axes('Parent', EStudio_gui_erp_totl.ViewAxes,'Color','none','Box','on','FontWeight','normal');
    set(EStudio_gui_erp_totl.erptabwaveiwer, 'XTick', [], 'YTick', [],'Box','off', 'Color','none','xcolor','none','ycolor','none');
end

if ~isempty(observe_ERPDAT.ALLERP) && ~isempty(observe_ERPDAT.ERP)
    EStudio_gui_erp_totl.erptabwaveiwer = axes('Parent', EStudio_gui_erp_totl.ViewAxes,'Color','none','Box','on','FontWeight','normal');
    hold(EStudio_gui_erp_totl.erptabwaveiwer,'on');
    set(EStudio_gui_erp_totl.plot_wav_legend,'Sizes',[80 -10]);
    EStudio_gui_erp_totl.erptabwaveiwer_legend = axes('Parent', EStudio_gui_erp_totl.ViewAxes_legend,'Color','none','Box','off');
    hold(EStudio_gui_erp_totl.erptabwaveiwer_legend,'on');
    
    ERP = observe_ERPDAT.ERP;
    OutputViewerparerp = f_preparms_erptab(ERP,0);
    
    % %%Plot the eeg waves
    if ~isempty(OutputViewerparerp)
        f_plotaberpwave(ERP,OutputViewerparerp{1},OutputViewerparerp{2},...
            OutputViewerparerp{3},OutputViewerparerp{4},OutputViewerparerp{5},...
            OutputViewerparerp{6},OutputViewerparerp{9},OutputViewerparerp{10},OutputViewerparerp{11},...
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
    EStudio_gui_erp_totl.plotgrid.Units = 'normalized';
    EStudio_gui_erp_totl.plotgrid.Heights(1) = 30; % set the first element (pageinfo) to 30px high
    EStudio_gui_erp_totl.plotgrid.Heights(3) = 30; % set the second element (x axis) to 30px high
    EStudio_gui_erp_totl.plotgrid.Units = 'pixels';
    if splot_n*pb_height<(EStudio_gui_erp_totl.plotgrid.Position(4)-EStudio_gui_erp_totl.plotgrid.Heights(1))&&Fillscreen
        pb_height = (EStudio_gui_erp_totl.plotgrid.Position(4)-EStudio_gui_erp_totl.plotgrid.Heights(1)-EStudio_gui_erp_totl.plotgrid.Heights(2))/splot_n;
    end
    EStudio_gui_erp_totl.ViewAxes.Heights = splot_n*pb_height;
else
    set(EStudio_gui_erp_totl.plot_wav_legend,'Sizes',[80 -10]);
    EStudio_gui_erp_totl.plotgrid.Heights(1) = 30; % set the first element (pageinfo) to 30px high
    EStudio_gui_erp_totl.plotgrid.Heights(3) = 30;
end

end

%------------------Display the waveform for proir ERPset--------------------
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


%%Edit the index of ERPsets
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
    positive_up,BinchanOverlay,waveview,legendview)

FonsizeDefault = f_get_default_fontsize();
%%matlab version
matlab_ver = version('-release');
Matlab_ver = str2double(matlab_ver(1:4));

%%channel labels
[~, chanLabels, ~, ~, ~] = readlocs(ERP.chanlocs);

if BinchanOverlay == 0
    splot_n = numel(ChanArray);
else
    splot_n = numel(BinArray);
end

%
%%------------Setting the number of data and plotting---------------------
ndata = 0;
nplot = 0;
if BinchanOverlay == 0 %if channels with bin overlay
    ndata = BinArray;
    nplot = ChanArray;
else %if bins with channel overlay
    ndata = ChanArray;
    nplot = BinArray;
end

[xtick_time, Bindata] = f_get_erp_xticklabel_time(ERP, [ERP.times(1) ERP.times(end)],[timeStart,timEnd]);
% plot_erp_data = nan(tmax-tmin+1,numel(ndata));
plot_erp_data = [];
for i = 1:splot_n
    if BinchanOverlay == 0
        for i_bin = 1:numel(ndata)
            plot_erp_data(:,i_bin,i) = Bindata(ChanArray(i),:,BinArray(i_bin))'*positive_up; %
        end
    else
        for i_bin = 1:numel(ndata)
            plot_erp_data(:,i_bin,i) = Bindata(ChanArray(i_bin),:,BinArray(i))'*positive_up; %
        end
    end
end
if YtickInterval==0
    YtickInterval = max(abs(Bindata(:)));
end
perc_lim = YtickInterval;
percentile = perc_lim*3/2;
[~,~,b] = size(plot_erp_data);
%
%%%------------Setting xticklabels for each row of each wave--------------
xstep_label = estudioworkingmemory('erp_xtickstep');
if isempty(xstep_label)
    xstep_label =0;
end
if ~xstep_label
    [def xtickstep]= default_time_ticks_studio(ERP, [timeStart,timEnd]);
    if ~isempty(def)
        xticks_clomn = str2num(def{1,1});
        while xticks_clomn(end)<=timEnd
            xticks_clomn(numel(xticks_clomn)+1) = xticks_clomn(end)+xtickstep;
            if xticks_clomn(end)>timEnd
                xticks_clomn = xticks_clomn(1:end-1);
                break;
            end
        end
    else
        xticks_clomn = (timeStart:xtickstep:timEnd);
    end
else
    xticks_clomn = (timeStart:xtickstep:timEnd);
end

xtickstep_p = ceil(xtickstep/(1000/ERP.srate));%% Time points of the gap between columns
%
%%----------------------Modify the data into  multiple-columns---------------------------------------
rowNum = ceil(b/columNum);
plot_erp_data_new = NaN(size(plot_erp_data,1),size(plot_erp_data,2),rowNum*columNum);
plot_erp_data_new(:,:,1:size(plot_erp_data,3))  =  plot_erp_data;
plot_erp_data_new_trans = [];

if  columNum==1
    for Numofrow = 1:rowNum
        plot_erp_data_new_trans(:,:,:,Numofrow) = plot_erp_data_new(:,:,(Numofrow-1)*columNum+1:Numofrow*columNum);
    end
    clear plot_erp_data;
    plot_erp_data_new_trans = permute(plot_erp_data_new_trans,[1,3,2,4]) ;
    plot_erp_data = reshape(plot_erp_data_new_trans,size(plot_erp_data_new_trans,1)*size(plot_erp_data_new_trans,2),size(plot_erp_data_new_trans,3),size(plot_erp_data_new_trans,4));
    
elseif columNum>1
    plot_erp_data_trans_clumns = NaN(size(plot_erp_data_new,1)*columNum+(columNum-1)*xtickstep_p,size(plot_erp_data_new,2),rowNum);
    for Numofrow = 1:rowNum
        Data_column = plot_erp_data_new(:,:,(Numofrow-1)*columNum+1:Numofrow*columNum);
        for Numofcolumn = 1:columNum
            low_interval = size(plot_erp_data_new,1)*(Numofcolumn-1)+1+(Numofcolumn-1)*xtickstep_p;
            high_interval = size(plot_erp_data_new,1)*(Numofcolumn-1)+(Numofcolumn-1)*xtickstep_p+size(plot_erp_data_new,1);
            plot_erp_data_trans_clumns(low_interval:high_interval,:,Numofrow) = squeeze(Data_column(:,:,Numofcolumn));
        end
    end
    plot_erp_data = plot_erp_data_trans_clumns;
end

ind_plot_height = percentile*2; % Height of each individual subplot

offset = [];
if BinchanOverlay == 0
    offset = (size(plot_erp_data,3)-1:-1:0)*ind_plot_height;
else
    offset = (size(plot_erp_data,3)-1:-1:0)*ind_plot_height;
end
[~,~,b] = size(plot_erp_data);
for i = 1:b
    plot_erp_data(:,:,i) = plot_erp_data(:,:,i) + ones(size(plot_erp_data(:,:,i)))*offset(i);
end

try
    f_bin = 1000/ERP.srate;
catch
    f_bin = 1;
end

ts = xtick_time;
ts_colmn = ts;

%
%%------------------Adjust the data into multiple/single columns------------
if  columNum>1 % Plotting waveforms with munltiple-columns
    xticks_org = xticks_clomn;
    for Numofcolumn = 1:columNum-1
        xticks_clomn_add = [1:numel(ts)+xtickstep_p].*f_bin+(ts_colmn(end).*ones(1,numel(ts)+xtickstep_p));
        ts_colmn = [ts_colmn,xticks_clomn_add];
    end
    X_zero_line(1) =ts(1);
    for Numofcolumn = 1:columNum-1
        if Numofcolumn ==1
            X_zero_line(Numofcolumn+1) = X_zero_line(Numofcolumn)+ ts(end)-ts(1)+f_bin + (xtickstep_p/2)*f_bin;
        else
            X_zero_line(Numofcolumn+1) = X_zero_line(Numofcolumn)+ ts(end)-ts(1)+f_bin + (xtickstep_p)*f_bin;
        end
    end
    [xticks,xticks_labels] = f_geterpxticklabel(ERP,xticks_clomn,columNum,[timeStart,timEnd],xtickstep);
    ts = ts_colmn;
    timeStart= ts(1);
    timEnd= ts(end);
    for ii =1:100
        if timEnd <xticks(end)
            timEnd =timEnd +f_bin;
        else
            break;
        end
    end
else%% Plotting waveforms with single-column
    xticks =xticks_clomn;
    X_zero_line(1) =ts(1);
    for Numofxlabel = 1:numel(xticks)
        xticks_labels{Numofxlabel} = num2str(xticks(Numofxlabel));
    end
end


splot_n = size(plot_erp_data,3);%%Adjust the columns
set(waveview,'XLim',[timeStart,timEnd]);

[a,c,b] = size(plot_erp_data);
new_erp_data = zeros(a,b*c);
for i = 1:b
    new_erp_data(:,((c*(i-1))+1):(c*i)) = plot_erp_data(:,:,i);
end

line_colors = erpworkingmemory('PWColor');
if size(line_colors,1)~= numel(ndata)
    if numel(ndata)> size(line_colors,1)
        line_colors = get_colors(numel(ndata));
    else
        line_colors = line_colors(1:numel(ndata),:,:);
    end
end
if isempty(line_colors)
    line_colors = get_colors(numel(ndata));
end
line_colors = repmat(line_colors,[splot_n 1]); %repeat the colors once for every plot
%
%%------------Setting xticklabels for each row --------------
x_axs = ones(size(new_erp_data,1),1);
for jj = 1:numel(offset)-1
    %     plot(waveview,ts,x_axs.*offset(end),'color',[1 1 1],'LineWidth',1);
    set(waveview,'XTick',xticks, ...
        'box','off', 'Color','none','xticklabels',xticks_labels);
    myX_Crossing = offset(jj);
    props = get(waveview);
    
    tick_bottom = -props.TickLength(1)*diff(props.YLim);
    if abs(tick_bottom) > abs(YtickInterval)/5
        try
            tick_bottom = - abs(YtickInterval)/5;
        catch
            tick_bottom = tick_bottom;
        end
    elseif abs(tick_bottom)<abs(YtickInterval)/5
        tick_bottom = - abs(YtickInterval)/5;
    end
    %
    tick_top = 0;
    line(waveview,props.XLim, [0 0] + myX_Crossing, 'color', [1 1 1]);%'k'
    
    if ~isempty(props.XTick)
        xtick_x = repmat(props.XTick, 2, 1);
        xtick_y = repmat([tick_bottom; tick_top] + myX_Crossing, 1, length(props.XTick));
        line(waveview,xtick_x, xtick_y, 'color', 'k','LineWidth',1);
    end
    set(waveview, 'XTick', [], 'XTickLabel', []);
    nTicks = length(props.XTick);
    if nTicks>1
        if numel(offset)==jj
            kkkk = 1;
        else
            if abs(timeStart - xticks(1)) > 1000/ERP.srate
                kkkk = 1;
            else
                kkkk = 2;
            end
        end
        for iCount = kkkk:nTicks
            xtick_label = (props.XTickLabel(iCount, :));
            text(waveview,props.XTick(iCount), tick_bottom + myX_Crossing, ...
                xtick_label, ...
                'HorizontalAlignment', 'Center', ...
                'VerticalAlignment', 'Top', ...
                'FontSize', FonsizeDefault, ...
                'FontName', props.FontName, ...
                'FontAngle', props.FontAngle, ...
                'FontUnits', props.FontUnits);
        end
    end
end

%
%%----------------Start:Remove xticks for the columns without waves in the last row-------------------------
Element_left = numel(nplot) - (ceil(numel(nplot)/columNum)-1)*columNum;
plot(waveview,ts,x_axs.*offset(end),'color', [1 1 1],'LineWidth',1);
set(waveview,'XTick',xticks, ...
    'box','off', 'Color','none','xticklabels',xticks_labels);
myX_Crossing = offset(end);
props = get(waveview);

tick_bottom = -props.TickLength(1)*diff(props.YLim);
if abs(tick_bottom) > abs(YtickInterval)/5
    try
        tick_bottom = - abs(YtickInterval)/5;
    catch
        tick_bottom = tick_bottom;
    end
elseif abs(tick_bottom)<abs(YtickInterval)/5
    tick_bottom = - abs(YtickInterval)/5;
end

tick_top = 0;
line(waveview,props.XLim, [0 0] + myX_Crossing, 'color', [1 1 1]);%'k'
nTicks = length(props.XTick);
if ~isempty(props.XTick)
    xtick_x = repmat(props.XTick, 2, 1);
    xtick_y = repmat([tick_bottom; tick_top] + myX_Crossing, 1, length(props.XTick));
    line(waveview,xtick_x(:,1:ceil(nTicks/columNum*Element_left)), xtick_y(:,1:ceil(nTicks/columNum*Element_left)), 'color', 'k','LineWidth',1);
end
set(waveview, 'XTick', [], 'XTickLabel', []);
if nTicks>1
    for iCount = 1:ceil(nTicks/columNum*Element_left)
        xtick_label = (props.XTickLabel(iCount, :));
        text(waveview,props.XTick(iCount), tick_bottom + myX_Crossing, ...
            xtick_label, ...
            'HorizontalAlignment', 'Center', ...
            'VerticalAlignment', 'Top', ...
            'FontSize', FonsizeDefault, ...
            'FontName', props.FontName, ...
            'FontAngle', props.FontAngle, ...
            'FontUnits', props.FontUnits);
    end
end
%%--------------------------End:Remove xticks for the columns without waves in the last row-------------------------

%%-----------------Get zeroline for each row-----------------------------
row_baseline = NaN(numel(ts),splot_n);
count = 0;
for Numofsplot = 0:splot_n-1
    for Numofcolumn = 1:columNum
        count = count +1;
        if count> numel(nplot)
            break;
        end
        low_interval = size(plot_erp_data_new,1)*(Numofcolumn-1)+1+(Numofcolumn-1)*xtickstep_p;
        high_interval = size(plot_erp_data_new,1)*(Numofcolumn-1)+(Numofcolumn-1)*xtickstep_p+size(plot_erp_data_new,1);
        row_baseline(low_interval:high_interval,Numofsplot+1) = ones(numel(low_interval:high_interval),1).*offset(Numofsplot+1);
    end
end
%
%%-------------------------Plotting ERP waves-----------------------------
pb_here = plot(waveview,ts, [new_erp_data],'LineWidth',1);
set(waveview, 'XTick', [], 'XTickLabel', []);

%
%%----------------Marking 0 point (event-locked)--------------------------
[xxx, latsamp_0, latdiffms_0] = closest(xticks, [0]);
if numel(offset)>1
    if latdiffms_0 ==0
        for Numofcolumn = 1:columNum
            xline(waveview,xticks((Numofcolumn-1)*numel(xticks_clomn)+latsamp_0),'k-.','LineWidth',1);%%'Color',Marking start time point for each column
        end
    end
elseif numel(offset)==1
    
    for Numofcolumn = 1:numel(nplot)
        xline(waveview,xticks((Numofcolumn-1)*numel(xticks_clomn)+latsamp_0),'k-.','LineWidth',1);%%'Color',Marking start time point for each column
    end
end
%
yticks  = -perc_lim:perc_lim:((2*percentile*b)-(2*perc_lim));
ylabs = repmat([-perc_lim 0 perc_lim],[1,b]);
oldlim = [-percentile yticks(end)-perc_lim+percentile];
top_vspace = max( max( new_erp_data))-oldlim(2);
bot_vspace = min( min( new_erp_data))-oldlim(1);
if top_vspace < 0
    top_vspace = 0;
end

if bot_vspace > 0
    bot_vspace = 0;
end
newlim = oldlim + [bot_vspace top_vspace];
set(waveview,'XLim',[timeStart,timEnd],'Ylim',newlim);

for i = 1:numel(pb_here)
    pb_here(i).Color = line_colors(i,:);
end

%%------------Marking start time point for each column---------------------
if  columNum>1
    for ii = 2:numel(X_zero_line)
        xline(waveview,X_zero_line(ii), 'y--','LineWidth',1);
    end
end

for Numofplot = 1:size(row_baseline,2)
    plot(waveview,ts,row_baseline(:,Numofplot),'color',[0 0 0],'LineWidth',1);
end
ylabs = [fliplr(-perc_lim:-perc_lim:newlim(1)) ylabs(2:end-1) (yticks(end):perc_lim:newlim(2))-yticks(end)+perc_lim];
yticks = [fliplr(-perc_lim:-perc_lim:newlim(1)) yticks(2:end-1) yticks(end):perc_lim:newlim(2)];

%
%%-------------Name of bin/channel for each subplot--------------------------
if  columNum==1
    if numel(offset)>1
        count = 0;
        for i = 0:numel(offset)-1
            leg_str = '';
            count  = count+1;
            try
                if BinchanOverlay == 0
                    leg_str = sprintf('%s',strrep(chanLabels{ChanArray(count)},'_','\_'));
                else
                    leg_str = sprintf('%s',strrep(ERP.bindescr{BinArray(count)},'_','\_'));
                end
            catch
                leg_str = '';
            end
            text(waveview,ts(1),offset(i+1)+offset(end-1)/6,leg_str,'FontSize', FonsizeDefault);
        end
    end
    
    try
        if BinchanOverlay == 0
            leg_str = sprintf('%s',strrep(chanLabels{ChanArray(end)},'_','\_'));
        else
            leg_str = sprintf('%s',strrep(ERP.bindescr{BinArray(end)},'_','\_'));
        end
    catch%%
        leg_str = '';
    end
    
    try
        text(waveview,ts(1),offset(end-1)/6,leg_str,'FontSize', FonsizeDefault);
    catch
        text(waveview,ts(1),YtickInterval/2,leg_str,'FontSize', FonsizeDefault);
    end
else%% Getting y ticks and legends for multiple-columns
    if numel(offset)>1
        count = 0;
        for i = 0:numel(offset)-1
            leg_str = '';
            for Numofcolumn = 1: columNum
                count  = count+1;
                try
                    if BinchanOverlay == 0
                        leg_str = sprintf('%s',strrep(chanLabels{ChanArray(count)},'_','\_'));
                    else
                        leg_str = sprintf('%s',strrep(ERP.bindescr{BinArray(count)},'_','\_'));
                    end
                catch
                    leg_str = '';
                end
                if Numofcolumn ==1
                    text(waveview,X_zero_line(Numofcolumn),offset(i+1)+offset(end-1)/6,leg_str,'FontSize', FonsizeDefault);
                else
                    text(waveview,X_zero_line(Numofcolumn)+xtickstep/2,offset(i+1)+offset(end-1)/6,leg_str,'FontSize', FonsizeDefault);
                end
            end
        end
    end
    
    count = (numel(offset)-1)*columNum;
    leg_str = '';
    for Numofcolumn = 1:columNum
        count  = count+1;
        try
            if BinchanOverlay == 0
                leg_str = sprintf('%s',strrep(chanLabels{ChanArray(count)},'_','\_'));
            else
                leg_str = sprintf('%s',strrep(ERP.bindescr{BinArray(count)},'_','\_'));
            end
        catch%%
            leg_str = '';
        end
        try
            if Numofcolumn ==1
                text(waveview,X_zero_line(Numofcolumn),offset(i+1)+offset(end-1)/6,leg_str,'FontSize', FonsizeDefault);
            else
                text(waveview,X_zero_line(Numofcolumn)+xtickstep/2,offset(i+1)+offset(end-1)/6,leg_str,'FontSize', FonsizeDefault);
            end
        catch
            if Numofcolumn ==1
                text(waveview,X_zero_line(Numofcolumn),YtickInterval/2,leg_str,'FontSize', FonsizeDefault);
            else
                text(waveview,X_zero_line(Numofcolumn)+xtickstep/2,YtickInterval/2,leg_str,'FontSize', FonsizeDefault);
            end
        end
    end
end

%
%%-------------Setting x/yticks and ticklabels--------------------------------
Ylabels_new = ylabs.*positive_up;
[~,Y_label] = find(Ylabels_new == -0);
Ylabels_new(Y_label) = 0;
% xticks = (timeStartdef:xtickstep:timEnddef);
% some options currently only work post Matlab R2016a ,'XLim',[timeStartdef timEnddef],'XLim',[timeStartdef timEnddef]
if Matlab_ver >= 2016
    set(waveview,'FontSize',FonsizeDefault,'XAxisLocation','origin',...
        'XGrid','on','YGrid','on','YTick',yticks,'YTickLabel',Ylabels_new, ...
        'YLim',newlim,'XTick',xticks, ...
        'box','off', 'Color','none','xticklabels',xticks_labels);
else
    set(waveview,'FontSize',FonsizeDefault,'XAxisLocation','bottom',...
        'XGrid','on','YGrid','on','YTick',yticks,'YTickLabel',Ylabels_new, ...
        'YLim',newlim, 'XTick',xticks, ...
        'box','off', 'Color','none','xticklabels',xticks_labels);
    hline(0,'k'); % backup xaxis
end
set(waveview, 'XTick', [], 'XTickLabel', []);
waveview.YAxis.LineWidth = 1;
hold(waveview,'off');

%%--------------------------Setting legend---------------------------------
line_colors_ldg = erpworkingmemory('PWColor');
if isempty(line_colors_ldg)
    line_colors_ldg = get_colors(numel(ndata));
end

if size(line_colors_ldg,1)~= numel(ndata)
    if numel(ndata)> size(line_colors_ldg,1)
        line_colors_ldg = get_colors(numel(ndata));
    else
        line_colors_ldg = line_colors_ldg(1:numel(ndata),:,:);
    end
end

for Numofplot = 1:size(plot_erp_data,2)
    plot(legendview,[0 0],'Color',line_colors_ldg(Numofplot,:,:),'LineWidth',2)
end

if BinchanOverlay == 0
    Leg_Name = {};
    for Numofbin = 1:numel(BinArray)
        Leg_Name{Numofbin} = strcat('Bin',num2str(BinArray(Numofbin)));
    end
else
    for Numofchan = 1:numel(ChanArray)
        Leg_Name{Numofchan} = strrep(chanLabels{ChanArray(Numofchan)},'_','\_');
    end
end
legend(legendview,Leg_Name,'FontSize',FonsizeDefault,'TextColor','blue');
legend(legendview,'boxoff');
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