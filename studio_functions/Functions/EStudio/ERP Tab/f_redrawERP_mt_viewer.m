%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 2022 && Nov. 2023

% ERPLAB Studio


function f_redrawERP_mt_viewer()

global observe_ERPDAT;
global EStudio_gui_erp_totl;

%%Get the background color
FonsizeDefault = f_get_default_fontsize();
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;%%Get background color
catch
    ColorB_def = [0. 95 0.95 0.95];
end
if isempty(ColorB_def)
    ColorB_def = [0. 95 0.95 0.95];
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
Res = Pix_SS./Inch_SS;

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
EStudio_gui_erp_totl.plotgrid = uiextras.VBox('Parent',EStudio_gui_erp_totl.ViewContainer,'Padding',0,'Spacing',0,'BackgroundColor',ColorB_def);
pageinfo_box = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plotgrid,'BackgroundColor',ColorB_def);
EStudio_gui_erp_totl.plot_wav_legend = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plotgrid,'BackgroundColor',[1 1 1]);
EStudio_gui_erp_totl.ViewAxes_legend = uix.ScrollingPanel( 'Parent', EStudio_gui_erp_totl.plot_wav_legend,'BackgroundColor',ColorB_def);
EStudio_gui_erp_totl.ViewAxes = uix.ScrollingPanel( 'Parent', EStudio_gui_erp_totl.plot_wav_legend,'BackgroundColor',[1 1 1]);
EStudio_gui_erp_totl.ERP_M_T_Viewer = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plotgrid,'BackgroundColor',ColorB_def);
xaxis_panel = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plotgrid );%%%Message
EStudio_gui_erp_totl.Process_messg = uicontrol('Parent',xaxis_panel,'Style','text','String','','FontSize',FonsizeDefault,'FontWeight','bold','BackgroundColor',ColorB_def);
EStudio_gui_erp_totl.pageinfo_minus = uicontrol('Parent',pageinfo_box,'Style', 'pushbutton', 'String', 'Prev.','Callback',{@page_minus,EStudio_gui_erp_totl},'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
EStudio_gui_erp_totl.pageinfo_edit = uicontrol('Parent',pageinfo_box,'Style', 'edit', 'String', num2str(pagecurrentNum),'Callback',{@page_edit,EStudio_gui_erp_totl},'FontSize',FonsizeDefault+2,'BackgroundColor',[1 1 1]);
EStudio_gui_erp_totl.pageinfo_plus = uicontrol('Parent',pageinfo_box,'Style', 'pushbutton', 'String', 'Next','Callback',{@page_plus,EStudio_gui_erp_totl},'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
EStudio_gui_erp_totl.pageinfo_plus.Enable = 'off';
pageinfo_str = ['Page',32,num2str(pagecurrentNum),'/',num2str(pageNum),':',32,PageStr];
pageinfo_text = uicontrol('Parent',pageinfo_box,'Style','text','String',pageinfo_str,'FontSize',FonsizeDefault);
EStudio_gui_erp_totl.advanced_viewer = uicontrol('Parent',pageinfo_box,'Style','pushbutton','String','Advanced Wave Viewer',...
    'Callback',@Advanced_viewer,'FontSize',FonsizeDefault);
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
set(pageinfo_text,'BackgroundColor',ColorB_def);

if isempty(observe_ERPDAT.ALLERP)  ||  isempty(observe_ERPDAT.ERP)
    EStudio_gui_erp_totl.erptabwaveiwer = axes('Parent', EStudio_gui_erp_totl.ViewAxes,'Color','none','Box','on','FontWeight','normal');
    set(EStudio_gui_erp_totl.erptabwaveiwer, 'XTick', [], 'YTick', [],'Box','off', 'Color','none','xcolor','none','ycolor','none');
end
if ~isempty(observe_ERPDAT.ALLERP) &&  ~isempty(observe_ERPDAT.ERP)
    ERP = observe_ERPDAT.ERP;
    OutputViewerparerp = f_preparms_mtviewer_erptab(ERP,0);
    
    ChanArray = OutputViewerparerp{1};
    BinArray = OutputViewerparerp{2};
    timeStart =OutputViewerparerp{3};
    timEnd =OutputViewerparerp{4};
    Timet_step=OutputViewerparerp{5};
    [~, chanLabels, ~, ~, ~] = readlocs(ERP.chanlocs);
    Yscale = OutputViewerparerp{6};
    Min_vspacing = OutputViewerparerp{7};
    Fillscreen = OutputViewerparerp{8};
    positive_up = OutputViewerparerp{10};
    BinchanOverlay= OutputViewerparerp{11};
    moption= OutputViewerparerp{12};
    latency= OutputViewerparerp{13};
    Min_time = observe_ERPDAT.ERP.times(1);
    Max_time = observe_ERPDAT.ERP.times(end);
    blc = OutputViewerparerp{14};
    intfactor =  OutputViewerparerp{15};
    Resolution =OutputViewerparerp{16};
    Matlab_ver = OutputViewerparerp{22};
    if BinchanOverlay == 0
        splot_n = numel(OutputViewerparerp{1});
    else
        splot_n = numel(OutputViewerparerp{2});
    end
    pb_height = Min_vspacing*Res(4);  %px
    
    if BinchanOverlay == 0
        ndata = BinArray;
        nplot = ChanArray;
    else
        ndata = ChanArray;
        nplot = BinArray;
    end
    pnts    = observe_ERPDAT.ERP.pnts;
    timeor  = observe_ERPDAT.ERP.times; % original time vector
    p1      = timeor(1);
    p2      = timeor(end);
    if intfactor~=1
        timex = linspace(p1,p2,round(pnts*intfactor));
    else
        timex = timeor;
    end
    [xxx, latsamp, latdiffms] = closest(timex, [Min_time Max_time]);
    tmin = latsamp(1);
    tmax = latsamp(2);
    if tmin < 1
        tmin = 1;
    end
    if tmax > numel(timex)
        tmax = numel(timex);
    end
    
    if intfactor~=1
        Plot_erp_data_TRAN = [];
        for Numoftwo = 1:size(observe_ERPDAT.ERP.bindata,3)
            for Numofone = 1:size(observe_ERPDAT.ERP.bindata,1)
                data = squeeze(observe_ERPDAT.ERP.bindata(Numofone,:,Numoftwo));
                data  = spline(timeor, data, timex); % re-sampled data
                blv    = blvalue2(data, timex, blc);
                data   = data - blv;
                Plot_erp_data_TRAN(Numofone,:,Numoftwo) = data;
            end
        end
        Bindata = Plot_erp_data_TRAN;
    else
        Bindata = observe_ERPDAT.ERP.bindata;
    end
    
    plot_erp_data = nan(tmax-tmin+1,numel(ndata));
    for i = 1:splot_n
        if BinchanOverlay == 0
            for i_bin = 1:numel(ndata)
                plot_erp_data(:,i_bin,i) = Bindata(ChanArray(i),tmin:tmax,BinArray(i_bin))'*positive_up; %
            end
        else
            for i_bin = 1:numel(ndata)
                plot_erp_data(:,i_bin,i) = Bindata(ChanArray(i_bin),tmin:tmax,BinArray(i))'*positive_up; %
            end
        end
    end
    perc_lim = Yscale;
    percentile = perc_lim*3/2;
    %How to get x unique colors?
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
    
    ind_plot_height = percentile*2; % Height of each individual subplot
    
    offset = [];
    if BinchanOverlay == 0
        offset = (numel(ChanArray)-1:-1:0)*ind_plot_height;
    else
        offset = (numel(BinArray)-1:-1:0)*ind_plot_height;
    end
    [~,~,Num_plot] = size(plot_erp_data);
    
    for i = 1:Num_plot
        plot_erp_data(:,:,i) = plot_erp_data(:,:,i) + ones(size(plot_erp_data(:,:,i)))*offset(i);
    end
    
    %pb_ax = uipanel('Parent',EStudio_gui_erp_totl.plotgrid);
    EStudio_gui_erp_totl.erptabwaveiwer = axes('Parent', EStudio_gui_erp_totl.ViewAxes,'Color',[1 1 1],'Box','on');
    hold(EStudio_gui_erp_totl.erptabwaveiwer,'on');
    set(EStudio_gui_erp_totl.plot_wav_legend,'Sizes',[80 -10]);
    EStudio_gui_erp_totl.erptabwaveiwer_legend = axes('Parent', EStudio_gui_erp_totl.ViewAxes_legend,'Color','none','Box','off');
    hold(EStudio_gui_erp_totl.erptabwaveiwer_legend,'on');
    
    set(EStudio_gui_erp_totl.erptabwaveiwer,'XLim',[Min_time Max_time]);
    ts = timex(tmin:tmax);
    [a,Num_data,Num_plot] = size(plot_erp_data);
    new_erp_data = zeros(a,Num_plot*Num_data);
    for i = 1:Num_plot
        new_erp_data(:,((Num_data*(i-1))+1):(Num_data*i)) = plot_erp_data(:,:,i);
    end
    
    % pb_here = plot(EStudio_gui_erp_totl.erptabwaveiwer,ts,plot_erp_data_fin,'LineWidth',1);
    pb_here = plot(EStudio_gui_erp_totl.erptabwaveiwer,ts,new_erp_data,'LineWidth',1);
    hold(EStudio_gui_erp_totl.erptabwaveiwer,'on');%Same function as hold on;
    EStudio_gui_erp_totl.erptabwaveiwer.LineWidth=1;
    yticks  = -perc_lim:perc_lim:((2*percentile*Num_plot)-(2*perc_lim));
    
    oldlim = [-percentile yticks(end)-perc_lim+percentile];
    top_vspace = max( max( new_erp_data ) )-oldlim(2);
    bot_vspace = min( min( new_erp_data ) )-oldlim(1);
    
    newlim = oldlim + [bot_vspace top_vspace];
    ylabs = repmat([-perc_lim 0 perc_lim],[1,Num_plot]);
    ylabs = [fliplr(-perc_lim:-perc_lim:newlim(1)) ylabs(2:end-1) (yticks(end):perc_lim:newlim(2))-yticks(end)+perc_lim];
    yticks = [fliplr(-perc_lim:-perc_lim:newlim(1)) yticks(2:end-1) yticks(end):perc_lim:newlim(2)];
    
    %%%------------Setting xticklabels for each row of each wave--------------
    xstep_label = estudioworkingmemory('erp_xtickstep');
    if isempty(xstep_label)
        xstep_label =0;
    end
    if ~xstep_label
        [def xstep]= default_time_ticks_studio(observe_ERPDAT.ERP, [timeStart,timEnd]);
        xticks = str2num(def{1,1});
    else
        xticks = (timeStart:Timet_step:timEnd);
    end
    % estudioworkingmemory('erp_xtickstep',0);
    x_axs = ones(size(new_erp_data,1),1);
    xticks_label = [];
    count = 0;
    for jjj = 1:numel(xticks)
        if xticks(jjj)< Min_time || xticks(jjj)> Max_time
            count = count +1;
            xticks_label(count) = jjj;
        end
    end
    for Numofxlabel = 1:numel(xticks)
        xticks_labels{Numofxlabel} = num2str(xticks(Numofxlabel));
    end
    
    for jj = 1:numel(offset)
        plot(EStudio_gui_erp_totl.erptabwaveiwer,ts,x_axs.*offset(end),'color',[1 1 1],'LineWidth',1);
        set(EStudio_gui_erp_totl.erptabwaveiwer,'XLim',[timeStart,timEnd]);
        set(EStudio_gui_erp_totl.erptabwaveiwer,'XTick',xticks, ...
            'box','off', 'Color','none','xticklabels',xticks_labels);
        myX_Crossing = offset(jj);
        props = get(EStudio_gui_erp_totl.erptabwaveiwer);
        
        tick_bottom = -props.TickLength(1)*diff(props.YLim);
        if abs(tick_bottom) > abs(Yscale)/5
            try
                tick_bottom = - abs(Yscale)/5;
            catch
                tick_bottom = tick_bottom;
            end
        end
        tick_top = 0;
        line(EStudio_gui_erp_totl.erptabwaveiwer,props.XLim, [0 0] + myX_Crossing, 'color', 'k','LineWidth',1);
        if ~isempty(props.XTick)
            xtick_x = repmat(props.XTick, 2, 1);
            xtick_y = repmat([tick_bottom; tick_top] + myX_Crossing, 1, length(props.XTick));
            h_ticks = line(EStudio_gui_erp_totl.erptabwaveiwer,xtick_x, xtick_y, 'color', 'k','LineWidth',1);
        end
        set(EStudio_gui_erp_totl.erptabwaveiwer, 'XTick', [], 'XTickLabel', []);
        %         tick_bottom = -props.TickLength(1)*diff(props.YLim);
        nTicks = length(props.XTick);
        h_ticklabels = zeros(size(props.XTick));
        if nTicks>1
            if numel(offset)==jj
                kkkk = 1;
            else
                if abs(timeStart - xticks(1)) > 1000/observe_ERPDAT.ERP.srate
                    kkkk = 1;
                else
                    kkkk = 2;
                end
            end
            for iCount = kkkk:nTicks
                xtick_label = (props.XTickLabel(iCount, :));
                text(EStudio_gui_erp_totl.erptabwaveiwer,props.XTick(iCount), tick_bottom + myX_Crossing, ...
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
    
    %%%Mark the area/latency/amplitude of interest within the defined window.
    ERP_mark_area_latency(EStudio_gui_erp_totl.erptabwaveiwer,timex(tmin:tmax),moption,plot_erp_data,latency,line_colors,offset,positive_up);%cwm = [0 0 0];% white: Background color for measurement window
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [xxx, latsamp,cdiff] = closest(timex, 0);
    if cdiff<1000/observe_ERPDAT.ERP.srate
        xline(EStudio_gui_erp_totl.erptabwaveiwer,timex(latsamp),'k-.','LineWidth',1);%%Marking start time point for each column
    end
    set(EStudio_gui_erp_totl.erptabwaveiwer,'XLim',[timeStart,timEnd],'Ylim',newlim);
    for i = 1:numel(pb_here)
        pb_here(i).Color = line_colors(i,:);
    end
    Ylabels_new = ylabs.*positive_up;
    [~,Y_label] = find(Ylabels_new == -0);
    Ylabels_new(Y_label) = 0;
    
    if numel(offset)>1
        count = 0;
        for i = 0:numel(offset)-1
            leg_str = '';
            count  = count+1;
            try
                if BinchanOverlay == 0
                    leg_str = sprintf('%s',strrep(chanLabels{ChanArray(count)},'_','\_'));
                else
                    leg_str = sprintf('%s',strrep(observe_ERPDAT.ERP.bindescr{BinArray(count)},'_','\_'));
                end
            catch
                leg_str = '';
            end
            text(EStudio_gui_erp_totl.erptabwaveiwer,timeStart,offset(i+1)+offset(end-1)/6,leg_str,'FontSize', FonsizeDefault);
        end
    end
    
    try
        if BinchanOverlay == 0
            leg_str = sprintf('%s',strrep(chanLabels{ChanArray(end)},'_','\_'));
        else
            leg_str = sprintf('%s',strrep(observe_ERPDAT.ERP.bindescr{BinArray(end)},'_','\_'));
        end
    catch%%
        leg_str = '';
    end
    
    try
        text(EStudio_gui_erp_totl.erptabwaveiwer,timeStart,offset(end-1)/6,leg_str,'FontSize', FonsizeDefault);
    catch
        text(EStudio_gui_erp_totl.erptabwaveiwer,timeStart,Yscale/2,leg_str,'FontSize', FonsizeDefault);
    end
    
    if Matlab_ver >= 2016
        set(EStudio_gui_erp_totl.erptabwaveiwer,'FontSize',FonsizeDefault,'XAxisLocation','origin',...
            'XGrid','on','YGrid','on','YTick',yticks,'YTickLabel',Ylabels_new, ...
            'YLim',newlim,'XTick',xticks, ...
            'box','off', 'Color','none','XLim',[timeStart timEnd]);
    else
        set(EStudio_gui_erp_totl.erptabwaveiwer,'FontSize',FonsizeDefault,'XAxisLocation','bottom',...
            'XGrid','on','YGrid','on','YTick',yticks,'YTickLabel',Ylabels_new, ...
            'YLim',newlim, 'XTick',xticks,...
            'box','off', 'Color','none','XLim',[timeStart timEnd]);
        hline(0,'k'); % backup xaxis
    end
    hold(EStudio_gui_erp_totl.erptabwaveiwer,'off');
    set(EStudio_gui_erp_totl.erptabwaveiwer, 'XTick', [], 'XTickLabel', []);
    
    % EStudio_gui_erp_totl.erptabwaveiwer.Position(1) =EStudio_gui_erp_totl.erptabwaveiwer.Position(1)+0.5;
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
        plot(EStudio_gui_erp_totl.erptabwaveiwer_legend,[0 0],'Color',line_colors_ldg(Numofplot,:,:),'LineWidth',1)
    end
    if BinchanOverlay == 0
        Leg_Name = '';
        for Numofbin = 1:numel(BinArray)
            Leg_Name{Numofbin} = strcat('Bin',num2str(BinArray(Numofbin)));
        end
    else
        for Numofchan = 1:numel(ChanArray)
            Leg_Name{Numofchan} = strrep(chanLabels{ChanArray(Numofchan)},'_','\_');
        end
    end
    here_lgd = legend(EStudio_gui_erp_totl.erptabwaveiwer_legend,Leg_Name,'FontSize',FonsizeDefault,'TextColor','blue');
    legend(EStudio_gui_erp_totl.erptabwaveiwer_legend,'boxoff');
    
    %%%-------------------Display results obtained from "Measurement Tool" Panel---------------------------------
    [~,~,~,Amp,Lat]= f_ERP_plot_wav(observe_ERPDAT.ERP);
    
    %%Get name for the selected rows (i.e.,BinArray) and columns (i.e., channels)
    RowName = {};
    for Numofbin = 1:numel(BinArray)
        RowName{Numofbin} = strcat('Bin',num2str(BinArray(Numofbin)));%'<html><font size= >',':',32,observe_ERPDAT.ERP.bindescr{BinArray(Numofbin)}
    end
    ColumnName = {};
    for Numofsel_chan = 1:numel(ChanArray)
        ColumnName{Numofsel_chan} = ['<html><font size= >',num2str(ChanArray(Numofsel_chan)),'.',32,chanLabels{ChanArray(Numofsel_chan)}];
    end
    
    try
        if ismember_bc2(moption, {'instabl','peaklatbl','fpeaklat','fareatlat','fninteglat','fareaplat','fareanlat','meanbl','peakampbl','areat','ninteg','areap','arean','ninteg','areazt','nintegz','areazp','areazn'})
            Data_display = Amp(BinArray,ChanArray);
        else
            Data_display = Lat(BinArray,ChanArray);
        end
        if ismember_bc2(moption,{'arean','areazn'})
            Data_display= -1.*Data_display;
        end
        Data_display_tra = {};
        for Numofone = 1:size(Data_display,1)
            for Numoftwo = 1:size(Data_display,2)
                if ~isnan(Data_display(Numofone,Numoftwo))
                    if BinchanOverlay == 0
                        Data_display_tra{Numofone,Numoftwo} = sprintf(['<html><tr><td align=center width=9999><FONT color="white">%.',num2str(Resolution),'f'], Data_display(Numofone,Numoftwo));
                    else
                        Data_display_tra{Numoftwo,Numofone} = sprintf(['<html><tr><td align=center width=9999><FONT color="white">%.',num2str(Resolution),'f'], Data_display(Numofone,Numoftwo));
                    end
                else
                    if BinchanOverlay == 0
                        Data_display_tra{Numofone,Numoftwo} = ['<html><tr><td align=center width=9999><FONT color="white">NaN'];
                    else
                        Data_display_tra{Numoftwo,Numofone} = ['<html><tr><td align=center width=9999><FONT color="white">NaN'];
                    end
                end
            end
        end
        EStudio_gui_erp_totl.ERP_M_T_Viewer_table = uitable(EStudio_gui_erp_totl.ERP_M_T_Viewer,'Data',Data_display_tra,'Units','Normalize');
        if BinchanOverlay == 0
            EStudio_gui_erp_totl.ERP_M_T_Viewer_table.RowName = RowName;
            EStudio_gui_erp_totl.ERP_M_T_Viewer_table.ColumnName = ColumnName;
        else
            EStudio_gui_erp_totl.ERP_M_T_Viewer_table.RowName = ColumnName;
            EStudio_gui_erp_totl.ERP_M_T_Viewer_table.ColumnName = RowName;
        end
        EStudio_gui_erp_totl.ERP_M_T_Viewer_table.BackgroundColor = line_colors_ldg;
        
        if size(Data_display_tra,2)<12
            ColumnWidth = {};
            for Numofchan =1:size(Data_display_tra,2)
                ColumnWidth{Numofchan} = EStudio_gui_erp_totl.ERP_M_T_Viewer.Position(3)/size(Data_display_tra,2);
            end
            EStudio_gui_erp_totl.ERP_M_T_Viewer_table.ColumnWidth = ColumnWidth;
        elseif size(Data_display_tra,2) ==1
            EStudio_gui_erp_totl.ERP_M_T_Viewer_table.ColumnWidth = {EStudio_gui_erp_totl.ERP_M_T_Viewer.Position(3)};
        end
    catch
        for Numofbin = 1:observe_ERPDAT.ERP.nbin
            Data_display{Numofbin,1} = '';
        end
        RowName = {};
        for Numofbin = 1:observe_ERPDAT.ERP.nbin
            RowName{Numofbin} = strcat('Bin',num2str((Numofbin)));
        end
        EStudio_gui_erp_totl.ERP_M_T_Viewer_table = uitable(EStudio_gui_erp_totl.ERP_M_T_Viewer,'Data',Data_display);
        EStudio_gui_erp_totl.ERP_M_T_Viewer_table.RowName = RowName;
        EStudio_gui_erp_totl.ERP_M_T_Viewer_table.ColumnName = {'No data are avalible'};
        EStudio_gui_erp_totl.ERP_M_T_Viewer_table.ColumnWidth = {EStudio_gui_erp_totl.ERP_M_T_Viewer.Position(3)};
        EStudio_gui_erp_totl.ERP_M_T_Viewer_table.BackgroundColor = line_colors_ldg;
        EStudio_gui_erp_totl.ERP_M_T_Viewer_table.ForegroundColor = [1 1 1];
    end
    EStudio_gui_erp_totl.plotgrid.Units = 'normalized';
    EStudio_gui_erp_totl.plotgrid.Heights(1) = 30; % set the first element (pageinfo) to 30px high
    EStudio_gui_erp_totl.plotgrid.Heights(3) = 80; % set the second element (x axis) to 30px high
    EStudio_gui_erp_totl.plotgrid.Heights(4) = 30; % set the second element (x axis) to 30px high
    EStudio_gui_erp_totl.plotgrid.Units = 'pixels';
    
    if splot_n*pb_height<(EStudio_gui_erp_totl.plotgrid.Position(4)-EStudio_gui_erp_totl.plotgrid.Heights(1))&&Fillscreen
        pb_height = (EStudio_gui_erp_totl.plotgrid.Position(4)-EStudio_gui_erp_totl.plotgrid.Heights(1)-EStudio_gui_erp_totl.plotgrid.Heights(2))/splot_n;
    end
    EStudio_gui_erp_totl.ViewAxes.Heights = splot_n*pb_height;
    EStudio_gui_erp_totl.ERP_M_T_Viewer_table.FontSize = FonsizeDefault;
else
    set(EStudio_gui_erp_totl.plot_wav_legend,'Sizes',[80 -10]);
    EStudio_gui_erp_totl.plotgrid.Heights(1) = 30; % set the first element (pageinfo) to 30px high
    EStudio_gui_erp_totl.plotgrid.Heights(3) = 30; % set the second element (x axis) to 30px high
    EStudio_gui_erp_totl.plotgrid.Heights(4) = 30;
end
end % redrawDemo


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



%%Mark the area or latency/amplitude of interest within defined latecies%%%
function ERP_mark_area_latency(r_ax,timex,moption,plot_erp_data,latency,line_colors,offset,positive_up)
try
    cwm_backgb   = erpworkingmemory('MWColor');
catch
    cwm_backgb=[0.7 0.7 0.7];
end
if isempty(cwm_backgb)
    cwm_backgb=[0.7 0.7 0.7];
end

try
    cwm   = erpworkingmemory('MTLineColor');
catch
    cwm  =[0 0 0];
end
if isempty(cwm)
    cwm=[0 0 0];
end

global observe_ERPDAT;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Plot area within the defined time-window%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Set area within the defined time-window for 1.Fractional area latency, 2. Numerical integration/Area between two fixed latencies
mearea    = { 'areat', 'areap', 'arean','areazt','areazp','areazn', 'ninteg','nintegz'};

[~,Num_data,Num_plot] = size(plot_erp_data);

if ismember_bc2(moption, mearea)  || ismember_bc2(moption, {'fareatlat', 'fareaplat','fninteglat','fareanlat'})
    if numel(latency) ==2
        latx = latency;
        [xxx, latsamp] = closest(timex, latx);
        datax = plot_erp_data(latsamp(1):latsamp(2),:,:);
    end
    Time_res = timex(2)-timex(1);
    
    if ismember_bc2(moption, {'areap', 'fareaplat'}) % positive area
        
        for Numofstione = 1:size(datax,3)
            for Numofstitwo = 1:size(datax,2)
                timexx = timex(latsamp(1):latsamp(2));
                dataxx = squeeze(datax(:,Numofstitwo,Numofstione));
                data_check  = dataxx-offset(Numofstione);
                if positive_up==1
                    dataxx(data_check<0) = [];
                    timexx(data_check<0) = [];
                elseif positive_up ==-1
                    dataxx(data_check>0) = [];
                    timexx(data_check>0) = [];
                else
                    dataxx(data_check<0) = [];
                    timexx(data_check<0) = [];
                end
                
                if ~isempty(dataxx) && numel(dataxx)>=2
                    %%Check isolated point
                    Check_outlier =[];
                    count = 0;
                    
                    if (timexx(2)-timexx(1)>Time_res)
                        count= count +1;
                        Check_outlier(count) = 1;
                    end
                    if numel(dataxx)>=3
                        for Numofsample = 2:length(timexx)-1
                            if (timexx(Numofsample+1)-timexx(Numofsample)>Time_res) &&  (timexx(Numofsample)-timexx(Numofsample-1)< Time_res)
                                count = count+1;
                                Check_outlier(count) = Numofsample;
                            end
                        end
                    end
                    dataxx(Check_outlier) = [];
                    timexx(Check_outlier) = [];
                    
                    Check_isolated =[];
                    count = 0;
                    for Numofsample = 1:length(timexx)-1
                        if timexx(Numofsample+1)-timexx(Numofsample)>Time_res
                            count = count+1;
                            Check_isolated(count) = Numofsample;
                        end
                    end
                    if numel(Check_isolated) ==1
                        inBetweenRegionX1 = [timexx(1:Check_isolated(1)),fliplr(timexx(1:Check_isolated(1)))];
                        inBetweenRegionY1 = [squeeze(dataxx(1:Check_isolated(1)))',fliplr(offset(Numofstione)*ones(1,numel(timexx(1:Check_isolated(1)))))];
                        fill(r_ax,inBetweenRegionX1, inBetweenRegionY1,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                        
                        inBetweenRegionX2 = [timexx(Check_isolated(1)+1:end),fliplr(timexx(Check_isolated(1)+1:end))];
                        inBetweenRegionY2 = [squeeze(dataxx(Check_isolated(1)+1:end))',fliplr(offset(Numofstione)*ones(1,numel(timexx(Check_isolated(1)+1:end))))];
                        fill(r_ax,inBetweenRegionX2, inBetweenRegionY2,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                    elseif numel(Check_isolated) >1
                        for Numofrange = 1:numel(Check_isolated)-1
                            
                            inBetweenRegionX = [timexx(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)),fliplr(timexx(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)))];
                            inBetweenRegionY = [squeeze(dataxx(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)))',fliplr(offset(Numofstione)*ones(1,numel(timexx(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)))))];
                            fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                            
                        end
                        inBetweenRegionX1 = [timexx(1:Check_isolated(1)),fliplr(timexx(1:Check_isolated(1)))];
                        inBetweenRegionY1 = [squeeze(dataxx(1:Check_isolated(1)))',fliplr(offset(Numofstione)*ones(1,numel(timexx(1:Check_isolated(1)))))];
                        fill(r_ax,inBetweenRegionX1, inBetweenRegionY1,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                        
                        inBetweenRegionX2 = [timexx(Check_isolated(Numofrange+1)+1:end),fliplr(timexx(Check_isolated(Numofrange+1)+1:end))];
                        inBetweenRegionY2 = [squeeze(dataxx(Check_isolated(Numofrange+1)+1:end))',fliplr(offset(Numofstione)*ones(1,numel(timexx(Check_isolated(Numofrange+1)+1:end))))];
                        fill(r_ax,inBetweenRegionX2, inBetweenRegionY2,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                        
                    else
                        inBetweenRegionX = [timexx,fliplr(timexx)];
                        inBetweenRegionY = [squeeze(dataxx)',fliplr(offset(Numofstione)*ones(1,numel(timexx)))];
                        fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                    end
                end
                
            end
            
        end
    elseif ismember_bc2(moption, {'arean', 'fareanlat'}) % negative area
        for Numofstione = 1:size(datax,3)
            for Numofstitwo = 1:size(datax,2)
                timexx = timex(latsamp(1):latsamp(2));
                dataxx = squeeze(datax(:,Numofstitwo,Numofstione));
                data_check  = dataxx-offset(Numofstione);
                if positive_up==1
                    dataxx(data_check>0) = [];
                    timexx(data_check>0) = [];
                elseif positive_up ==-1
                    dataxx(data_check<0) = [];
                    timexx(data_check<0) = [];
                else
                    dataxx(data_check>0) = [];
                    timexx(data_check>0) = [];
                end
                
                %%Check isolated point
                if ~isempty(dataxx) && numel(dataxx)>=2
                    Check_outlier =[];
                    count = 0;
                    
                    if (timexx(2)-timexx(1)>Time_res)
                        count= count +1;
                        Check_outlier(count) = 1;
                    end
                    if numel(dataxx)>=3
                        for Numofsample = 2:length(timexx)-1
                            if (timexx(Numofsample+1)-timexx(Numofsample)>Time_res) &&  (timexx(Numofsample)-timexx(Numofsample-1)< Time_res)
                                count = count+1;
                                Check_outlier(count) = Numofsample;
                            end
                        end
                    end
                    dataxx(Check_outlier) = [];
                    timexx(Check_outlier) = [];
                    
                    Check_isolated =[];
                    count = 0;
                    for Numofsample = 1:length(timexx)-1
                        if timexx(Numofsample+1)-timexx(Numofsample)>Time_res
                            count = count+1;
                            Check_isolated(count) = Numofsample;
                        end
                    end
                    if numel(Check_isolated) ==1
                        inBetweenRegionX1 = [timexx(1:Check_isolated(1)),fliplr(timexx(1:Check_isolated(1)))];
                        inBetweenRegionY1 = [squeeze(dataxx(1:Check_isolated(1)))',fliplr(offset(Numofstione)*ones(1,numel(timexx(1:Check_isolated(1)))))];
                        fill(r_ax,inBetweenRegionX1, inBetweenRegionY1,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                        
                        inBetweenRegionX2 = [timexx(Check_isolated(1)+1:end),fliplr(timexx(Check_isolated(1)+1:end))];
                        inBetweenRegionY2 = [squeeze(dataxx(Check_isolated(1)+1:end))',fliplr(offset(Numofstione)*ones(1,numel(timexx(Check_isolated(1)+1:end))))];
                        fill(r_ax,inBetweenRegionX2, inBetweenRegionY2,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                    elseif numel(Check_isolated) >1
                        for Numofrange = 1:numel(Check_isolated)-1
                            inBetweenRegionX = [timexx(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)),fliplr(timexx(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)))];
                            inBetweenRegionY = [squeeze(dataxx(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)))',fliplr(offset(Numofstione)*ones(1,numel(timexx(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)))))];
                            fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                        end
                        inBetweenRegionX1 = [timexx(1:Check_isolated(1)),fliplr(timexx(1:Check_isolated(1)))];
                        inBetweenRegionY1 = [squeeze(dataxx(1:Check_isolated(1)))',fliplr(offset(Numofstione)*ones(1,numel(timexx(1:Check_isolated(1)))))];
                        fill(r_ax,inBetweenRegionX1, inBetweenRegionY1,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                        
                        inBetweenRegionX2 = [timexx(Check_isolated(Numofrange+1)+1:end),fliplr(timexx(Check_isolated(Numofrange+1)+1:end))];
                        inBetweenRegionY2 = [squeeze(dataxx(Check_isolated(Numofrange+1)+1:end))',fliplr(offset(Numofstione)*ones(1,numel(timexx(Check_isolated(Numofrange+1)+1:end))))];
                        fill(r_ax,inBetweenRegionX2, inBetweenRegionY2,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                        
                    else
                        inBetweenRegionX = [timexx,fliplr(timexx)];
                        inBetweenRegionY = [squeeze(dataxx)',fliplr(offset(Numofstione)*ones(1,numel(timexx)))];
                        fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                    end
                end
            end
        end
        
        
    elseif ismember_bc2(moption, {'ninteg', 'fninteglat'}) % integration(area for negative substracted from area for positive)
        for Numofstione = 1:size(datax,3)
            for Numofstitwo = 1:size(datax,2)
                timexxp = timex(latsamp(1):latsamp(2));
                dataxxp = squeeze(datax(:,Numofstitwo,Numofstione));
                timexxn = timex(latsamp(1):latsamp(2));
                dataxxn = squeeze(datax(:,Numofstitwo,Numofstione));
                data_check  = dataxxn-offset(Numofstione);
                if positive_up==1
                    dataxxp(data_check<0) = [];
                    timexxp(data_check<0) = [];
                    dataxxn(data_check>0) = [];
                    timexxn(data_check>0) = [];
                elseif positive_up ==-1
                    dataxxp(data_check>0) = [];
                    timexxp(data_check>0) = [];
                    dataxxn(data_check<0) = [];
                    timexxn(data_check<0) = [];
                else
                    dataxxp(data_check<0) = [];
                    timexxp(data_check<0) = [];
                    dataxxn(data_check>0) = [];
                    timexxn(data_check>0) = [];
                end
                
                if ~isempty(dataxxp) && numel(dataxxp)>=2
                    %%Check isolated point
                    Check_outlierp =[];
                    count = 0;
                    
                    if (timexxp(2)-timexxp(1)>Time_res)
                        count= count +1;
                        Check_outlierp(count) = 1;
                    end
                    if numel(dataxxp)>=3
                        for Numofsample = 2:length(timexxp)-1
                            if (timexxp(Numofsample+1)-timexxp(Numofsample)>Time_res) &&  (timexxp(Numofsample)-timexxp(Numofsample-1)< Time_res)
                                count = count+1;
                                Check_outlierp(count) = Numofsample;
                            end
                        end
                    end
                    dataxxp(Check_outlierp) = [];
                    timexxp(Check_outlierp) = [];
                    
                    Check_isolated =[];
                    count = 0;
                    for Numofsample = 1:length(timexxp)-1
                        if timexxp(Numofsample+1)-timexxp(Numofsample)>Time_res
                            count = count+1;
                            Check_isolated(count) = Numofsample;
                        end
                    end
                    if numel(Check_isolated) ==1
                        inBetweenRegionXp1 = [timexxp(1:Check_isolated(1)),fliplr(timexxp(1:Check_isolated(1)))];
                        inBetweenRegionYp1 = [squeeze(dataxxp(1:Check_isolated(1)))',fliplr(offset(Numofstione)*ones(1,numel(timexxp(1:Check_isolated(1)))))];
                        fill(r_ax,inBetweenRegionXp1, inBetweenRegionYp1,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                        
                        inBetweenRegionXp2 = [timexxp(Check_isolated(1)+1:end),fliplr(timexxp(Check_isolated(1)+1:end))];
                        inBetweenRegionYp2 = [squeeze(dataxxp(Check_isolated(1)+1:end))',fliplr(offset(Numofstione)*ones(1,numel(timexxp(Check_isolated(1)+1:end))))];
                        fill(r_ax,inBetweenRegionXp2, inBetweenRegionYp2,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                    elseif numel(Check_isolated) >1
                        for Numofrange = 1:numel(Check_isolated)-1
                            
                            inBetweenRegionX = [timexxp(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)),fliplr(timexxp(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)))];
                            inBetweenRegionY = [squeeze(dataxxp(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)))',fliplr(offset(Numofstione)*ones(1,numel(timexxp(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)))))];
                            fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                            
                        end
                        inBetweenRegionX1 = [timexxp(1:Check_isolated(1)),fliplr(timexxp(1:Check_isolated(1)))];
                        inBetweenRegionY1 = [squeeze(dataxxp(1:Check_isolated(1)))',fliplr(offset(Numofstione)*ones(1,numel(timexxp(1:Check_isolated(1)))))];
                        fill(r_ax,inBetweenRegionX1, inBetweenRegionY1,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                        
                        inBetweenRegionX2 = [timexxp(Check_isolated(Numofrange+1)+1:end),fliplr(timexxp(Check_isolated(Numofrange+1)+1:end))];
                        inBetweenRegionY2 = [squeeze(dataxxp(Check_isolated(Numofrange+1)+1:end))',fliplr(offset(Numofstione)*ones(1,numel(timexxp(Check_isolated(Numofrange+1)+1:end))))];
                        fill(r_ax,inBetweenRegionX2, inBetweenRegionY2,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                        
                    else
                        inBetweenRegionX = [timexxp,fliplr(timexxp)];
                        inBetweenRegionY = [squeeze(dataxxp)',fliplr(offset(Numofstione)*ones(1,numel(timexxp)))];
                        fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                    end
                end%Positive part end
                
                if ~isempty(dataxxn) && numel(dataxxn)>=2
                    %%Check isolated point
                    Check_outliern =[];
                    count = 0;
                    
                    if (timexxn(2)-timexxn(1)>Time_res)
                        count= count +1;
                        Check_outliern(count) = 1;
                    end
                    if numel(dataxxn)>=3
                        for Numofsample = 2:length(timexxn)-1
                            if (timexxn(Numofsample+1)-timexxn(Numofsample)>Time_res) &&  (timexxn(Numofsample)-timexxn(Numofsample-1)< Time_res)
                                count = count+1;
                                Check_outliern(count) = Numofsample;
                            end
                        end
                    end
                    dataxxn(Check_outliern) = [];
                    timexxn(Check_outliern) = [];
                    
                    Check_isolated =[];
                    count = 0;
                    for Numofsample = 1:length(timexxn)-1
                        if timexxn(Numofsample+1)-timexxn(Numofsample)>Time_res
                            count = count+1;
                            Check_isolated(count) = Numofsample;
                        end
                    end
                    if numel(Check_isolated) ==1
                        inBetweenRegionXp1 = [timexxn(1:Check_isolated(1)),fliplr(timexxn(1:Check_isolated(1)))];
                        inBetweenRegionYp1 = [squeeze(dataxxn(1:Check_isolated(1)))',fliplr(offset(Numofstione)*ones(1,numel(timexxn(1:Check_isolated(1)))))];
                        fill(r_ax,inBetweenRegionXp1, inBetweenRegionYp1,line_colors(Numofstitwo,:,:).*0.3,'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                        
                        inBetweenRegionXp2 = [timexxn(Check_isolated(1)+1:end),fliplr(timexxn(Check_isolated(1)+1:end))];
                        inBetweenRegionYp2 = [squeeze(dataxxn(Check_isolated(1)+1:end))',fliplr(offset(Numofstione)*ones(1,numel(timexxn(Check_isolated(1)+1:end))))];
                        fill(r_ax,inBetweenRegionXp2, inBetweenRegionYp2,line_colors(Numofstitwo,:,:).*0.3,'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                    elseif numel(Check_isolated) >1
                        for Numofrange = 1:numel(Check_isolated)-1
                            
                            inBetweenRegionX = [timexxn(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)),fliplr(timexxn(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)))];
                            inBetweenRegionY = [squeeze(dataxxn(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)))',fliplr(offset(Numofstione)*ones(1,numel(timexxn(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)))))];
                            fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(Numofstitwo,:,:).*0.3,'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                            
                        end
                        inBetweenRegionX1 = [timexxn(1:Check_isolated(1)),fliplr(timexxn(1:Check_isolated(1)))];
                        inBetweenRegionY1 = [squeeze(dataxxn(1:Check_isolated(1)))',fliplr(offset(Numofstione)*ones(1,numel(timexxn(1:Check_isolated(1)))))];
                        fill(r_ax,inBetweenRegionX1, inBetweenRegionY1,line_colors(Numofstitwo,:,:).*0.3,'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                        
                        inBetweenRegionX2 = [timexxn(Check_isolated(Numofrange+1)+1:end),fliplr(timexxn(Check_isolated(Numofrange+1)+1:end))];
                        inBetweenRegionY2 = [squeeze(dataxxn(Check_isolated(Numofrange+1)+1:end))',fliplr(offset(Numofstione)*ones(1,numel(timexxn(Check_isolated(Numofrange+1)+1:end))))];
                        fill(r_ax,inBetweenRegionX2, inBetweenRegionY2,line_colors(Numofstitwo,:,:).*0.3,'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                    else
                        inBetweenRegionX = [timexxn,fliplr(timexxn)];
                        inBetweenRegionY = [squeeze(dataxxn)',fliplr(offset(Numofstione)*ones(1,numel(timexxn)))];
                        fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(Numofstitwo,:,:).*0.3,'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                    end
                end%%Negative part end
            end
        end
        
    elseif ismember_bc2(moption, {'areat', 'fareatlat'})%  negative values become positive
        for Numofstione = 1:size(datax,3)
            for Numofstitwo = 1:size(datax,2)
                timexx = timex(latsamp(1):latsamp(2));
                dataxx = squeeze(datax(:,Numofstitwo,Numofstione));
                inBetweenRegionX = [timexx,fliplr(timexx)];
                inBetweenRegionY = [squeeze(dataxx)',fliplr(offset(Numofstione)*ones(1,numel(timexx)))];
                fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
            end
        end
        
    elseif ismember_bc2(moption,  {'areazt','areazp','areazn', 'nintegz'})
        [new_erp_data, Amp_out,Lat]= f_ERP_plot_wav(observe_ERPDAT.ERP);
        if strcmp(moption,'areazt')%% all area were included
            
            for Numofstione = 1:size(plot_erp_data,3)
                for Numofstitwo = 1:size(plot_erp_data,2)
                    latx = Lat{Numofstitwo,Numofstione};
                    [xxx, latsamp] = closest(timex, latx);
                    datax = plot_erp_data(latsamp(1):latsamp(2),:,:);
                    timexx = timex(latsamp(1):latsamp(2));
                    dataxx = squeeze(datax(:,Numofstitwo,Numofstione));
                    inBetweenRegionX = [timexx,fliplr(timexx)];
                    inBetweenRegionY = [squeeze(dataxx)',fliplr(offset(Numofstione)*ones(1,numel(timexx)))];
                    fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                end
            end
            
        elseif strcmp(moption,'areazp')%% Only positive area was included
            
            for Numofstione = 1:size(plot_erp_data,3)
                for Numofstitwo = 1:size(plot_erp_data,2)
                    latx = Lat{Numofstitwo,Numofstione};
                    [xxx, latsamp] = closest(timex, latx);
                    datax = plot_erp_data(latsamp(1):latsamp(2),:,:);
                    timexx = timex(latsamp(1):latsamp(2));
                    timexx_unsl = timex(latsamp(1):latsamp(2));
                    dataxx = squeeze(datax(:,Numofstitwo,Numofstione));
                    data_check_unsl = squeeze(datax(:,Numofstitwo,Numofstione));
                    data_check  = dataxx -offset(Numofstione);
                    if positive_up==1
                        dataxx(data_check<0) = [];
                        timexx(data_check<0) = [];
                        data_check_unsl(data_check>0) =[];
                        timexx_unsl(data_check>0) = [];
                    elseif positive_up ==-1
                        dataxx(data_check>0) = [];
                        timexx(data_check>0) = [];
                        data_check_unsl(data_check<0) =[];
                        timexx_unsl(data_check<0) = [];
                    else
                        dataxx(data_check<0) = [];
                        timexx(data_check<0) = [];
                        data_check_unsl(data_check>0) =[];
                        timexx_unsl(data_check>0) = [];
                    end
                    inBetweenRegionX = [timexx,fliplr(timexx)];
                    inBetweenRegionY = [squeeze(dataxx)',fliplr(offset(Numofstione)*ones(1,numel(timexx)))];
                    fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                    inBetweenRegionX_unsl = [timexx_unsl,fliplr(timexx_unsl)];
                    inBetweenRegionY_unsl = [squeeze(data_check_unsl)',fliplr(offset(Numofstione)*ones(1,numel(timexx_unsl)))];
                    fill(r_ax,inBetweenRegionX_unsl, inBetweenRegionY_unsl,[1 1 1],'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                end
            end
            
            
        elseif strcmp(moption,'areazn')%% Only positive area was included
            
            for Numofstione = 1:size(plot_erp_data,3)
                for Numofstitwo = 1:size(plot_erp_data,2)
                    latx = Lat{Numofstitwo,Numofstione};
                    [xxx, latsamp] = closest(timex, latx);
                    datax = plot_erp_data(latsamp(1):latsamp(2),:,:);
                    timexx = timex(latsamp(1):latsamp(2));
                    timexx_unsl = timex(latsamp(1):latsamp(2));
                    dataxx = squeeze(datax(:,Numofstitwo,Numofstione));
                    data_check_unsl = squeeze(datax(:,Numofstitwo,Numofstione));
                    data_check  = dataxx -offset(Numofstione);
                    if positive_up==1
                        dataxx(data_check>0) = [];
                        timexx(data_check>0) = [];
                        data_check_unsl(data_check<0) =[];
                        timexx_unsl(data_check<0) = [];
                    elseif positive_up ==-1
                        dataxx(data_check<0) = [];
                        timexx(data_check<0) = [];
                        data_check_unsl(data_check>0) =[];
                        timexx_unsl(data_check>0) = [];
                    else
                        dataxx(data_check>0) = [];
                        timexx(data_check>0) = [];
                        data_check_unsl(data_check<0) =[];
                        timexx_unsl(data_check<0) = [];
                    end
                    inBetweenRegionX = [timexx,fliplr(timexx)];
                    inBetweenRegionY = [squeeze(dataxx)',fliplr(offset(Numofstione)*ones(1,numel(timexx)))];
                    fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                    inBetweenRegionX_unsl = [timexx_unsl,fliplr(timexx_unsl)];
                    inBetweenRegionY_unsl = [squeeze(data_check_unsl)',fliplr(offset(Numofstione)*ones(1,numel(timexx_unsl)))];
                    fill(r_ax,inBetweenRegionX_unsl, inBetweenRegionY_unsl,[1 1 1],'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                end
            end
            
        elseif strcmp(moption,'nintegz')%% Only positive area was included
            
            for Numofstione = 1:size(plot_erp_data,3)
                for Numofstitwo = 1:size(plot_erp_data,2)
                    latx = Lat{Numofstitwo,Numofstione};
                    [xxx, latsamp] = closest(timex, latx);
                    datax = plot_erp_data(latsamp(1):latsamp(2),:,:);
                    timexx = timex(latsamp(1):latsamp(2));
                    timexx_unsl = timex(latsamp(1):latsamp(2));
                    dataxx = squeeze(datax(:,Numofstitwo,Numofstione));
                    data_check_unsl = squeeze(datax(:,Numofstitwo,Numofstione));
                    data_check  = dataxx -offset(Numofstione);
                    if positive_up==1
                        dataxx(data_check<0) = [];
                        timexx(data_check<0) = [];
                        data_check_unsl(data_check>0) =[];
                        timexx_unsl(data_check>0) = [];
                    elseif positive_up ==-1
                        dataxx(data_check>0) = [];
                        timexx(data_check>0) = [];
                        data_check_unsl(data_check<0) =[];
                        timexx_unsl(data_check<0) = [];
                    else
                        dataxx(data_check<0) = [];
                        timexx(data_check<0) = [];
                        data_check_unsl(data_check>0) =[];
                        timexx_unsl(data_check>0) = [];
                    end
                    inBetweenRegionX = [timexx,fliplr(timexx)];
                    inBetweenRegionY = [squeeze(dataxx)',fliplr(offset(Numofstione)*ones(1,numel(timexx)))];
                    fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                    inBetweenRegionX_unsl = [timexx_unsl,fliplr(timexx_unsl)];%
                    inBetweenRegionY_unsl = [squeeze(data_check_unsl)',fliplr(offset(Numofstione)*ones(1,numel(timexx_unsl)))];
                    fill(r_ax,inBetweenRegionX_unsl, inBetweenRegionY_unsl,line_colors(Numofstitwo,:,:)*0.5,'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                end
            end
        end
    end
end


if length(latency)==1
    if ismember_bc2(moption,  {'areazt','areazp','areazn', 'nintegz'})%% Four options for Numerical integration/Area between two (automatically detected)zero-crossing latencies
        xline(r_ax,latency, 'Color', cwm,'LineWidth' ,1);
    else
        xline(r_ax,latency, 'Color', cwm,'LineWidth' ,1);
    end
    if  ismember_bc2(moption, 'instabl')
        [new_erp_data, Amp_out,Lat]= f_ERP_plot_wav(observe_ERPDAT.ERP);
        
        for Numofstione = 1:Num_plot
            for Numofstitwo = 1:Num_data
                plot(r_ax,latency,squeeze(Amp_out(Numofstitwo,Numofstione)),'Color',line_colors(Numofstitwo,:,:),'Marker','x');
            end
        end
        
    end
elseif length(latency)==2
    Max_values = max(abs(plot_erp_data(:)));
    plot_area_up = area(r_ax,[latency latency(2) latency(1)],[-2*Max_values-500,Max_values*2 -2*Max_values-500,Max_values*2]);
    plot_area_low = area(r_ax,[latency latency(2) latency(1)],[0,-Max_values*2 0,-Max_values*2]);
    
    set(plot_area_up,'FaceAlpha',0.2, 'EdgeAlpha', 0.1, 'EdgeColor', cwm,'FaceColor',cwm_backgb);
    set(plot_area_low,'FaceAlpha',0.2, 'EdgeAlpha', 0.1, 'EdgeColor', cwm,'FaceColor',cwm_backgb);
    
    if ismember_bc2(moption, {'peakampbl'})%Local Peak amplitude
        
        [new_erp_data, Amp_out,Lat]= f_ERP_plot_wav(observe_ERPDAT.ERP);
        for Numofstione = 1:Num_plot
            for Numofstitwo = 1:Num_data
                line(r_ax, [Lat{Numofstitwo,Numofstione} Lat{Numofstitwo,Numofstione}],[offset(Numofstione),squeeze(Amp_out(Numofstitwo,Numofstione))],'Color',line_colors(Numofstitwo,:,:),'LineWidth',3,'LineStyle','--','Marker','x');
            end
        end
    elseif ismember_bc2(moption, { 'fareatlat', 'fareaplat','fninteglat','fareanlat'})%fractional area latency
        [new_erp_data, Amp_out,Lat]= f_ERP_plot_wav(observe_ERPDAT.ERP);
        for Numofstione = 1:Num_plot
            for Numofstitwo = 1:Num_data
                Amp_all = squeeze(plot_erp_data(:,Numofstitwo,Numofstione));
                if ~isnan(Amp_out(Numofstitwo,Numofstione))
                    [xxx, latsamp, latdiffms] = closest(timex, Amp_out(Numofstitwo,Numofstione));
                    line(r_ax, [Amp_out(Numofstitwo,Numofstione) Amp_out(Numofstitwo,Numofstione)],[offset(Numofstione),Amp_all(latsamp)],'Color',line_colors(Numofstitwo,:,:),'LineWidth',3,'LineStyle','--','Marker','x');
                end
            end
        end
        
    elseif ismember_bc2(moption,  {'peaklatbl','fpeaklat'}) % fractional peak latency && Local peak latency
        [new_erp_data, Amp_out,Lat]= f_ERP_plot_wav(observe_ERPDAT.ERP);
        for Numofstione = 1:Num_plot
            for Numofstitwo = 1:Num_data
                Amp_all = squeeze(plot_erp_data(:,Numofstitwo,Numofstione));
                if ~isnan(Amp_out(Numofstitwo,Numofstione))
                    [xxx, latsamp, latdiffms] = closest(timex, Amp_out(Numofstitwo,Numofstione));
                    line(r_ax, [Amp_out(Numofstitwo,Numofstione) Amp_out(Numofstitwo,Numofstione)],[offset(Numofstione),Amp_all(latsamp)],'Color',line_colors(Numofstitwo,:,:),'LineWidth',3,'LineStyle','--','Marker','x');
                end
            end
        end
        
    end
end

end
