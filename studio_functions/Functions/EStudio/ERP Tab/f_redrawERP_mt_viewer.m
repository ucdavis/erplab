%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 2022

% ERPLAB Studio





function f_redrawERP_mt_viewer()
% Draw a demo ERP into the axes provided
% global EStudio_gui_erp_totl;
global observe_ERPDAT;
global EStudio_gui_erp_totl;
S_ws_geterpset= estudioworkingmemory('selectederpstudio');
if isempty(S_ws_geterpset)
    S_ws_geterpset = observe_ERPDAT.CURRENTERP;
    
    if isempty(S_ws_geterpset)
        msgboxText =  'No ERPset was selected!!!';
        title = 'EStudio: ERPsets';
        errorfound(msgboxText, title);
        return;
    end
    S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,S_ws_geterpset);
    estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
    estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
end

S_ws_getbinchan =  estudioworkingmemory('geterpbinchan');
Select_index = S_ws_getbinchan.Select_index;
S_ws_geterpplot = estudioworkingmemory('geterpplot');


S_ws_geterpvalues =  estudioworkingmemory('geterpvalues');
try
    
    Viewer_Label = S_ws_geterpvalues.Viewer;
catch
    mnamex = '"Viewer" was not selected for the measured ERPset.';
    question = [ '%s\n\n Please select "On" for "Viewer" on the "ERP Measurement Tool" panel .\n'];
    title       = 'ERPLAB Studio: ERP Measurement Tool';
    button      = questdlg(sprintf(question, mnamex), title,'OK','OK');
    return;
end

if isempty(Viewer_Label) || ~strcmp(Viewer_Label,'on')
    mnamex = '"Off" was selected for "Viewer" on the "ERP Measurement Tool" panel.';
    question = [ '%s\n\n Please check "S" on Workspace of Matlab.\n'];
    title       = 'ERPLAB Studio: ERP Measurement Tool';
    button      = questdlg(sprintf(question, mnamex), title,'OK','OK');
    return;
end


try
    moption = S_ws_geterpvalues.Measure;
catch
    mnamex = 'Measurement type was not selected on the "ERP Measurement Tool" panel.';
    question = [ '%s\n\n Please select anyone of measurement types from pop menu of "Measurement Type".\n'];
    title       = 'ERPLAB Studio: ERP Measurement Tool';
    button      = questdlg(sprintf(question, mnamex), title,'OK','OK');
    return;
end


try
    latency = S_ws_geterpvalues.latency;
catch
    mnamex = 'Measurement window was not defined on the "ERP Measurement Tool" panel.';
    question = [ '%s\n\n Please set measurement window on "Measurement window".\n'];
    title       = 'ERPLAB Studio: ERP Measurement Tool';
    button      = questdlg(sprintf(question, mnamex), title,'OK','OK');
    return;
end

Times_erp_curr = observe_ERPDAT.ERP.times;

if numel(latency) ==1
    if latency(1)< Times_erp_curr(1)
        msgboxText = ['For latency range, lower time limit must be larger than',32,num2str(Times_erp_curr(1)),'.\n'];
        title = 'EStudio: ERP measurement tool- Viewer "on". ';
        errorfound(sprintf(msgboxText), title);
        return
        
    elseif latency(1)> Times_erp_curr(end)
        msgboxText = ['For latency range, upper time limit must be smaller than',32,num2str(Times_erp_curr(end)),'.\n'];
        title = 'EStudio: ERP measurement tool- Viewer "on". ';
        errorfound(sprintf(msgboxText), title);
        return
    end
    
    
else
    
    if latency(1) < Times_erp_curr(1)
        msgboxText = ['For latency range, lower time limit must be larger than',32,num2str(Times_erp_curr(1)),'.\n'];
        title = 'EStudio: ERP measurement tool- Viewer "on". ';
        errorfound(sprintf(msgboxText), title);
        return
        
    elseif latency(end)  > Times_erp_curr(end)
        msgboxText = ['For latency range, upper time limit must be smaller than',32,num2str(Times_erp_curr(end)),'.\n'];
        title = 'EStudio: ERP measurement tool- Viewer "on". ';
        errorfound(sprintf(msgboxText), title);
        return
    end
end

%%Parameter from bin and channel panel
Elecs_shown = S_ws_getbinchan.elecs_shown{Select_index};
Bins = S_ws_getbinchan.bins{Select_index};
Bin_chans = S_ws_getbinchan.bins_chans(Select_index);
Elec_list = S_ws_getbinchan.elec_list{Select_index};
Matlab_ver = S_ws_getbinchan.matlab_ver;



%%Parameter from plotting panel
Min_vspacing = S_ws_geterpplot.min_vspacing(Select_index);
Min_time = S_ws_geterpplot.min(Select_index);
Max_time = S_ws_geterpplot.max(Select_index);
Yscale = S_ws_geterpplot.yscale(Select_index);
Timet_low =S_ws_geterpplot.timet_low(Select_index);
Timet_high =S_ws_geterpplot.timet_high(Select_index);
Timet_step=S_ws_geterpplot.timet_step(Select_index);
Fill = S_ws_geterpplot.fill(Select_index);
Plority_plot = S_ws_geterpplot.Positive_up(Select_index);


if Bin_chans == 0
    elec_n = S_ws_getbinchan.elec_n(Select_index);
    max_elec_n = observe_ERPDAT.ALLERP(S_ws_geterpset(Select_index)).nchan;
else
    elec_n = S_ws_getbinchan.bin_n(Select_index);
    max_elec_n = observe_ERPDAT.ALLERP(S_ws_geterpset(Select_index)).nbin;
end

% We first clear the existing axes ready to build a new one
if ishandle( EStudio_gui_erp_totl.ViewAxes )
    delete( EStudio_gui_erp_totl.ViewAxes );
end


% Get chan labels
S_chan.chan_label = cell(1,max_elec_n);
S_chan.chan_label_place = zeros(1,max_elec_n);


if Bin_chans == 0
    for i = 1:elec_n
        S_chan.chan_label{i} = observe_ERPDAT.ERP.chanlocs(Elecs_shown(i)).labels;
    end
else
    for i = 1:elec_n
        S_chan.chan_label{i} = observe_ERPDAT.ERP.bindescr(Bins(i));
    end
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


pb_height = Min_vspacing*Res(4);  %px


% Plot data in the main viewer fig
splot_n = elec_n;
tsize   = 13;

%%Get the background color
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;%%Get background color
catch
    ColorB_def = [0. 95 0.95 0.95];
end
if isempty(ColorB_def)
    ColorB_def = [0. 95 0.95 0.95];
end

clear pb r_ax plotgrid
EStudio_gui_erp_totl.plotgrid = uiextras.VBox('Parent',EStudio_gui_erp_totl.ViewContainer,'Padding',0,'Spacing',0,'BackgroundColor',ColorB_def);

pageinfo_box = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plotgrid,'BackgroundColor',ColorB_def);

EStudio_gui_erp_totl.plot_wav_legend = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plotgrid,'BackgroundColor',[1 1 1]);
EStudio_gui_erp_totl.ViewAxes_legend = uix.ScrollingPanel( 'Parent', EStudio_gui_erp_totl.plot_wav_legend,'BackgroundColor',ColorB_def);
EStudio_gui_erp_totl.ViewAxes = uix.ScrollingPanel( 'Parent', EStudio_gui_erp_totl.plot_wav_legend,'BackgroundColor',[1 1 1]);
EStudio_gui_erp_totl.ERP_M_T_Viewer = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plotgrid,'BackgroundColor',ColorB_def);
%%-------------------Display the processing procedure-----------------------
%%Changed by Guanghui Zhang 2 August 2022-------panel for display the processing procedure for some functions, e.g., filtering
xaxis_panel = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.plotgrid );%%%Message
EStudio_gui_erp_totl.Process_messg = uicontrol('Parent',xaxis_panel,'Style','text','String','','FontSize',20,'FontWeight','bold','BackgroundColor',ColorB_def);


%%Setting title
EStudio_gui_erp_totl.pageinfo_minus = uicontrol('Parent',pageinfo_box,'Style', 'pushbutton', 'String', '<','Callback',{@page_minus,EStudio_gui_erp_totl},'FontSize',30,'BackgroundColor',[1 1 1]);
if Select_index ==1
    EStudio_gui_erp_totl.pageinfo_minus.Enable = 'off';
end

EStudio_gui_erp_totl.pageinfo_edit = uicontrol('Parent',pageinfo_box,'Style', 'edit', 'String', num2str(S_ws_getbinchan.Select_index),'Callback',{@page_edit,EStudio_gui_erp_totl},'FontSize',20,'BackgroundColor',[1 1 1]);
if S_ws_getbinchan.Select_index ==1
    EStudio_gui_erp_totl.pageinfo_edit.Enable = 'on';
end


EStudio_gui_erp_totl.pageinfo_plus = uicontrol('Parent',pageinfo_box,'Style', 'pushbutton', 'String', '>','Callback',{@page_plus,EStudio_gui_erp_totl},'FontSize',30,'BackgroundColor',[1 1 1]);
if S_ws_getbinchan.Select_index == numel(S_ws_geterpset)
    EStudio_gui_erp_totl.pageinfo_plus.Enable = 'off';
end

pageinfo_str = ['Page',32,num2str(Select_index),'/',num2str(numel(S_ws_geterpset)),':',32,observe_ERPDAT.ERP.erpname];
pageinfo_text = uicontrol('Parent',pageinfo_box,'Style','text','String',pageinfo_str,'FontSize',14,'FontWeight','bold');

if length(S_ws_geterpset) ==1
    Enable_minus = 'off';
    Enable_plus = 'off';
    Enable_plus_BackgroundColor = [1 1 1];
    Enable_minus_BackgroundColor = [0 0 0];
else
    
    if Select_index ==1
        Enable_minus = 'off';
        Enable_plus = 'on';
        
        Enable_plus_BackgroundColor = [0 1 0];
        Enable_minus_BackgroundColor = [0 0 0];
    elseif  Select_index == length(S_ws_geterpset)
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

set(pageinfo_box, 'Sizes', [50 50 50 -1] );
set(pageinfo_box,'BackgroundColor',ColorB_def);
set(pageinfo_text,'BackgroundColor',ColorB_def);
%Setting title. END

%for i=1:splot_n

ndata = 0;
nplot = 0;
if Bin_chans == 0
    ndata = Bins;
    nplot = Elecs_shown;
else
    ndata = Elecs_shown;
    nplot = Bins;
end

%Both equation is incorrect.

pnts    = observe_ERPDAT.ERP.pnts;
timeor  = observe_ERPDAT.ERP.times; % original time vector
p1      = timeor(1);
p2      = timeor(end);

try
    intfactor = S_ws_geterpvalues.InterpFactor;
catch
    intfactor =1;
end

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

try
    blc = S_ws_geterpvalues.Baseline;
catch
    blc = 'none';
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
    if Bin_chans == 0
        for i_bin = 1:numel(ndata)
            plot_erp_data(:,i_bin,i) = Bindata(Elecs_shown(i),tmin:tmax,Bins(i_bin))'*Plority_plot; %
        end
    else
        for i_bin = 1:numel(ndata)
            plot_erp_data(:,i_bin,i) = Bindata(Elecs_shown(i_bin),tmin:tmax,Bins(i))'*Plority_plot; %
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
if Bin_chans == 0
    offset = (numel(Elecs_shown)-1:-1:0)*ind_plot_height;
else
    offset = (numel(Bins)-1:-1:0)*ind_plot_height;
end
[~,~,Num_plot] = size(plot_erp_data);

for i = 1:Num_plot
    plot_erp_data(:,:,i) = plot_erp_data(:,:,i) + ones(size(plot_erp_data(:,:,i)))*offset(i);
end

if ~strcmpi(observe_ERPDAT.ERP.erpname,'No ERPset loaded')
    %pb_ax = uipanel('Parent',EStudio_gui_erp_totl.plotgrid);
    r_ax = axes('Parent', EStudio_gui_erp_totl.ViewAxes,'Color',[1 1 1],'Box','on');
    hold(r_ax,'on');
    set(EStudio_gui_erp_totl.plot_wav_legend,'Sizes',[80 -10]);
    r_ax_legend = axes('Parent', EStudio_gui_erp_totl.ViewAxes_legend,'Color','none','Box','off');
    hold(r_ax_legend,'on');
    
    
    set(r_ax,'XLim',[Min_time Max_time]);
    ts = timex(tmin:tmax);
    [a,Num_data,Num_plot] = size(plot_erp_data);
    new_erp_data = zeros(a,Num_plot*Num_data);
    for i = 1:Num_plot
        new_erp_data(:,((Num_data*(i-1))+1):(Num_data*i)) = plot_erp_data(:,:,i);
    end
    
    % plot_erp_data_fin = [repmat((1:numel(nplot)-1)*ind_plot_height,[numel(ts) 1]) new_erp_data];
    
    % pb_here = plot(r_ax,ts,plot_erp_data_fin,'LineWidth',1);
    pb_here = plot(r_ax,ts,new_erp_data,'LineWidth',1.5);
    hold(r_ax,'on');%Same function as hold on;
    r_ax.LineWidth=1.5;
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
        [def xstep]= default_time_ticks_studio(observe_ERPDAT.ERP, [Timet_low,Timet_high]);
        xticks = str2num(def{1,1});
    else
        xticks = (Timet_low:Timet_step:Timet_high);
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
    % if ~isempty(xticks_label)
    %     xticks(xticks_label) = [];
    % end
    for Numofxlabel = 1:numel(xticks)
        xticks_labels{Numofxlabel} = num2str(xticks(Numofxlabel));
    end
    
    try
        moption =  S_ws_geterpvalues.Measure;
    catch
        moption = 'meanbl';
    end
    
    
    for jj = 1:numel(offset)
        plot(r_ax,ts,x_axs.*offset(end),'color',[1 1 1],'LineWidth',3);
        set(r_ax,'XLim',[Timet_low,Timet_high]);
        set(r_ax,'XTick',xticks, ...
            'box','off', 'Color','none','xticklabels',xticks_labels,'FontWeight','bold');
        myX_Crossing = offset(jj);
        props = get(r_ax);
        
        tick_bottom = -props.TickLength(1)*diff(props.YLim);
        if abs(tick_bottom) > abs(Yscale)/5
            try
                tick_bottom = - abs(Yscale)/5;
            catch
                tick_bottom = tick_bottom;
            end
        end
        tick_top = 0;
        
        line(r_ax,props.XLim, [0 0] + myX_Crossing, 'color', 'k','LineWidth',1.5);
        
        if ~isempty(props.XTick)
            xtick_x = repmat(props.XTick, 2, 1);
            xtick_y = repmat([tick_bottom; tick_top] + myX_Crossing, 1, length(props.XTick));
            h_ticks = line(r_ax,xtick_x, xtick_y, 'color', 'k','LineWidth',1.5);
        end
        set(r_ax, 'XTick', [], 'XTickLabel', []);
        %         tick_bottom = -props.TickLength(1)*diff(props.YLim);
        nTicks = length(props.XTick);
        h_ticklabels = zeros(size(props.XTick));
        if nTicks>1
            if numel(offset)==jj
                kkkk = 1;
            else
                if abs(Timet_low - xticks(1)) > 1000/observe_ERPDAT.ERP.srate
                    kkkk = 1;
                else
                    kkkk = 2;
                end
            end
            for iCount = kkkk:nTicks
                xtick_label = (props.XTickLabel(iCount, :));
                text(r_ax,props.XTick(iCount), tick_bottom + myX_Crossing, ...
                    xtick_label, ...
                    'HorizontalAlignment', 'Center', ...
                    'VerticalAlignment', 'Top', ...
                    'FontSize', 12, ...
                    'FontName', props.FontName, ...
                    'FontAngle', props.FontAngle, ...
                    'FontUnits', props.FontUnits, ...
                    'FontWeight', 'bold');
            end
        end
    end
    % end
    
    %%%Mark the area/latency/amplitude of interest within the defined window.
    ERP_mark_area_latency(r_ax,timex(tmin:tmax),moption,plot_erp_data,latency,line_colors,offset,Plority_plot);%cwm = [0 0 0];% white: Background color for measurement window
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % set(r_ax,'XLim',[Timet_low,Timet_high]);
    
    %%%%%%%%-----------------------------
    
    [xxx, latsamp,cdiff] = closest(timex, 0);
    if cdiff<1000/observe_ERPDAT.ERP.srate
        xline(r_ax,timex(latsamp),'k-.','LineWidth',1);%%Marking start time point for each column
    end
    
    if top_vspace < 0
        top_vspace = 0;
    end
    
    if bot_vspace > 0
        bot_vspace = 0;
    end
    set(r_ax,'XLim',[Timet_low,Timet_high],'Ylim',newlim);
    
    for i = 1:numel(pb_here)
        pb_here(i).Color = line_colors(i,:);
    end
    
    
    Ylabels_new = ylabs.*Plority_plot;
    [~,Y_label] = find(Ylabels_new == -0);
    Ylabels_new(Y_label) = 0;
    
    
    if numel(offset)>1
        count = 0;
        for i = 0:numel(offset)-1
            leg_str = '';
            
            count  = count+1;
            try
                if Bin_chans == 0
                    leg_str = sprintf('%s',strrep(Elec_list{Elecs_shown(count)},'_','\_'));
                else
                    leg_str = sprintf('%s',strrep(observe_ERPDAT.ERP.bindescr{Bins(count)},'_','\_'));
                end
            catch
                leg_str = '';
            end
            text(r_ax,Timet_low,offset(i+1)+offset(end-1)/6,leg_str,'FontWeight','bold','FontSize', 14);
            
        end
    end
    
    try
        if Bin_chans == 0
            leg_str = sprintf('%s',strrep(Elec_list{Elecs_shown(end)},'_','\_'));
        else
            leg_str = sprintf('%s',strrep(observe_ERPDAT.ERP.bindescr{Bins(end)},'_','\_'));
        end
    catch%%
        leg_str = '';
    end
    
    try
        text(r_ax,Timet_low,offset(end-1)/6,leg_str,'FontWeight','bold','FontSize', 14);
    catch
        text(r_ax,Timet_low,Yscale/2,leg_str,'FontWeight','bold','FontSize', 14);
    end
    
    
    % xticks = (Min_time:Timet_step:Max_time);
    % some options currently only work post Matlab R2016a
    if Matlab_ver >= 2016
        set(r_ax,'FontSize',tsize,'FontWeight','bold','XAxisLocation','origin',...
            'XGrid','on','YGrid','on','YTick',yticks,'YTickLabel',Ylabels_new, ...
            'YLim',newlim,'XTick',xticks, ...
            'box','off', 'Color','none','XLim',[Timet_low Timet_high]);
    else
        set(r_ax,'FontSize',tsize,'FontWeight','bold','XAxisLocation','bottom',...
            'XGrid','on','YGrid','on','YTick',yticks,'YTickLabel',Ylabels_new, ...
            'YLim',newlim, 'XTick',xticks,...
            'box','off', 'Color','none','XLim',[Timet_low Timet_high]);
        hline(0,'k'); % backup xaxis
    end
    hold(r_ax,'off');
    % if numel(offset)>1
    set(r_ax, 'XTick', [], 'XTickLabel', []);
    % end
    %%%%%%%%%%%%
    % r_ax.Position(1) =r_ax.Position(1)+0.5;
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
        plot(r_ax_legend,[0 0],'Color',line_colors_ldg(Numofplot,:,:),'LineWidth',3)
    end
    
    if Bin_chans == 0
        Leg_Name = '';
        for Numofbin = 1:numel(Bins)
            Leg_Name{Numofbin} = strcat('Bin',num2str(Bins(Numofbin)));
        end
        
    else
        for Numofchan = 1:numel(Elecs_shown)
            Leg_Name{Numofchan} = strrep(Elec_list{Elecs_shown(Numofchan)},'_','\_');
        end
    end
    here_lgd = legend(r_ax_legend,Leg_Name,'FontSize',14,'TextColor','blue');
    legend(r_ax_legend,'boxoff');
    
    
    
    %end
    EStudio_gui_erp_totl.plotgrid.Heights(1) = 30; % set the first element (pageinfo) to 30px high
    EStudio_gui_erp_totl.plotgrid.Heights(3) = 30; % set the second element (x axis) to 30px high
    EStudio_gui_erp_totl.plotgrid.Heights(4) = 30; % set the second element (x axis) to 30px high
    EStudio_gui_erp_totl.plotgrid.Units = 'pixels';
    if splot_n*pb_height<(EStudio_gui_erp_totl.plotgrid.Position(4)-EStudio_gui_erp_totl.plotgrid.Heights(1))&&Fill
        pb_height = (EStudio_gui_erp_totl.plotgrid.Position(4)-EStudio_gui_erp_totl.plotgrid.Heights(1)-EStudio_gui_erp_totl.plotgrid.Heights(2))/splot_n;
    end
    
    EStudio_gui_erp_totl.ViewAxes.Heights = splot_n*pb_height;
    % EStudio_gui_erp_totl.ViewAxes.Widths = -10;
    EStudio_gui_erp_totl.plotgrid.Units = 'normalized';
    EStudio_gui_erp_totl.plotgrid.Heights =[30 -1 80 30];
    %%%-------------------Display results obtained from "Measurement Tool" Panel---------------------------------
    [~,~,~,Amp,Lat]= f_ERP_plot_wav(observe_ERPDAT.ERP);
    try
        Resolution =S_ws_geterpvalues.Resolution;
    catch
        Resolution =3;
    end
    try
        moption =S_ws_geterpvalues.Measure;
    catch
        beep;
        disp('Please select one of Measurement type');
        return;
    end
    
    %%Get name for the selected rows (i.e.,bins) and columns (i.e., channels)
    RowName = {};
    for Numofbin = 1:numel(Bins)
        RowName{Numofbin} = strcat('Bin',num2str(Bins(Numofbin)));%'<html><font size= >',':',32,observe_ERPDAT.ERP.bindescr{Bins(Numofbin)}
    end
    ColumnName = {};
    for Numofsel_chan = 1:numel(Elecs_shown)
        ColumnName{Numofsel_chan} = ['<html><font size= >',num2str(Elecs_shown(Numofsel_chan)),'.',32,Elec_list{Elecs_shown(Numofsel_chan)}];
    end
    
    % txt_title = uicontrol('Parent',EStudio_gui_erp_totl.ERP_M_T_Viewer,'Style', 'text', 'String', 'My Example Title');
    try
        if ismember_bc2(moption, {'instabl','peaklatbl','fpeaklat','fareatlat','fninteglat','fareaplat','fareanlat','meanbl','peakampbl','areat','ninteg','areap','arean','ninteg','areazt','nintegz','areazp','areazn'})
            Data_display = Amp(Bins,Elecs_shown);
        else
            Data_display = Lat(Bins,Elecs_shown);
        end
        
        if ismember_bc2(moption,{'arean','areazn'})
            Data_display= -1.*Data_display;
        end
        
        Data_display_tra = {};
        for Numofone = 1:size(Data_display,1)
            for Numoftwo = 1:size(Data_display,2)
                if ~isnan(Data_display(Numofone,Numoftwo))
                    if Bin_chans == 0
                        Data_display_tra{Numofone,Numoftwo} = sprintf(['<html><tr><td align=center width=9999><FONT color="white">%.',num2str(Resolution),'f'], Data_display(Numofone,Numoftwo));
                    else
                        Data_display_tra{Numoftwo,Numofone} = sprintf(['<html><tr><td align=center width=9999><FONT color="white">%.',num2str(Resolution),'f'], Data_display(Numofone,Numoftwo));
                    end
                    
                else
                    if Bin_chans == 0
                        Data_display_tra{Numofone,Numoftwo} = ['<html><tr><td align=center width=9999><FONT color="white">NaN'];
                    else
                        Data_display_tra{Numoftwo,Numofone} = ['<html><tr><td align=center width=9999><FONT color="white">NaN'];
                    end
                end
            end
        end
        
        EStudio_gui_erp_totl.ERP_M_T_Viewer_table = uitable(EStudio_gui_erp_totl.ERP_M_T_Viewer,'Data',Data_display_tra,'Units','Normalize');
        if Bin_chans == 0
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
    
    EStudio_gui_erp_totl.ERP_M_T_Viewer_table.FontSize = 12;
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
S_ws_geterpset= estudioworkingmemory('selectederpstudio');
if isempty(S_ws_geterpset)
    S_ws_geterpset = observe_ERPDAT.CURRENTERP;
    
    if isempty(S_ws_geterpset)
        msgboxText =  'No ERPset was selected!!!';
        title = 'EStudio: ERPsets';
        errorfound(msgboxText, title);
        return;
    end
    S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,S_ws_geterpset);
    estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
    estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
end
S_ws_getbinchan =  estudioworkingmemory('geterpbinchan');
S_ws_getbinchan.Select_index  = S_ws_getbinchan.Select_index-1;
Current_erp_Index = S_ws_geterpset(S_ws_getbinchan.Select_index);
if Current_erp_Index > length(observe_ERPDAT.ALLERP)
    beep;
    disp('Waiting for modifing');
    return;
end
observe_ERPDAT.CURRENTERP =  Current_erp_Index;
observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(Current_erp_Index);
estudioworkingmemory('geterpbinchan',S_ws_getbinchan);
if length(S_ws_geterpset) ==1
    Enable_minus = 'off';
    Enable_plus = 'off';
    Enable_plus_BackgroundColor = [0 0 0];
    Enable_minus_BackgroundColor = [0 0 0];
else
    
    if S_ws_getbinchan.Select_index ==1
        Enable_minus = 'off';
        Enable_plus = 'on';
        
        Enable_plus_BackgroundColor = [0 1 0];
        Enable_minus_BackgroundColor = [0 0 0];
    elseif  S_ws_getbinchan.Select_index == length(S_ws_geterpset)
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
f_redrawERP_mt_viewer();
EStudio_gui_erp_totl.pageinfo_plus.ForegroundColor = Enable_plus_BackgroundColor;
EStudio_gui_erp_totl.pageinfo_minus.ForegroundColor = Enable_minus_BackgroundColor;

MessageViewer= char(strcat('Plot prior page (<)'));
erpworkingmemory('f_ERP_proces_messg',MessageViewer);
observe_ERPDAT.Process_messg =1;
try
    observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
    observe_ERPDAT.Process_messg =2;
catch
    observe_ERPDAT.Process_messg =3;
end
observe_ERPDAT.Two_GUI = observe_ERPDAT.Two_GUI+1;
end



%%Edit the index of ERPsets
function page_edit(Str,~,EStudio_gui_erp_totl)
CurrentERPindex = str2num(Str.String);
global observe_ERPDAT;
S_ws_geterpset= estudioworkingmemory('selectederpstudio');
if isempty(S_ws_geterpset)
    S_ws_geterpset = observe_ERPDAT.CURRENTERP;
    if isempty(S_ws_geterpset)
        msgboxText =  'No ERPset was selected!!!';
        title = 'EStudio: ERPsets';
        errorfound(msgboxText, title);
        return;
    end
    S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,S_ws_geterpset);
    estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
    estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
end
S_ws_getbinchan =  estudioworkingmemory('geterpbinchan');
if ~isempty(CurrentERPindex) &&  numel(CurrentERPindex)==1 && (CurrentERPindex<= numel(S_ws_geterpset))
    S_ws_getbinchan.Select_index  = CurrentERPindex;
    Current_erp_Index = S_ws_geterpset(S_ws_getbinchan.Select_index);
    % EStudio_gui_erp_totl.pageinfo_edit.String = num2str(S_ws_getbinchan.Select_index);
    if Current_erp_Index > length(observe_ERPDAT.ALLERP)
        beep;
        disp('Waiting for modifing');
        return;
    end
    observe_ERPDAT.CURRENTERP =  Current_erp_Index;
    observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(Current_erp_Index);
    estudioworkingmemory('geterpbinchan',S_ws_getbinchan);
    if length(S_ws_geterpset) ==1
        Enable_minus = 'off';
        Enable_plus = 'off';
        Enable_plus_BackgroundColor = [0 0 0];
        Enable_minus_BackgroundColor = [0 0 0];
    else
        if CurrentERPindex ==1
            Enable_minus = 'off';
            Enable_plus = 'on';
            Enable_plus_BackgroundColor = [0 1 0];
            Enable_minus_BackgroundColor = [1 1 1];
        elseif  CurrentERPindex == length(S_ws_geterpset)
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
        observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
        observe_ERPDAT.Process_messg =2;
    catch
        observe_ERPDAT.Process_messg =3;
    end
end
observe_ERPDAT.Two_GUI = observe_ERPDAT.Two_GUI+1;
end


%------------------Display the waveform for next ERPset--------------------
function page_plus(~,~,EStudio_gui_erp_totl)
global observe_ERPDAT;
S_ws_geterpset= estudioworkingmemory('selectederpstudio');
if isempty(S_ws_geterpset)
    S_ws_geterpset = observe_ERPDAT.CURRENTERP;
    if isempty(S_ws_geterpset)
        msgboxText =  'No ERPset was selected!!!';
        title = 'EStudio: ERPsets';
        errorfound(msgboxText, title);
        return;
    end
    S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,S_ws_geterpset);
    estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
    estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
end
S_ws_getbinchan =  estudioworkingmemory('geterpbinchan');
S_ws_getbinchan.Select_index  = S_ws_getbinchan.Select_index+1;
Current_erp_Index = S_ws_geterpset(S_ws_getbinchan.Select_index);
if Current_erp_Index > length(observe_ERPDAT.ALLERP)
    beep;
    disp('Waiting for modifing');
    return;
end
observe_ERPDAT.CURRENTERP =  Current_erp_Index;
observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(Current_erp_Index);
estudioworkingmemory('geterpbinchan',S_ws_getbinchan);
if length(S_ws_geterpset) ==1
    Enable_minus = 'off';
    Enable_plus = 'off';
    Enable_plus_BackgroundColor = [0 0 0];
    Enable_minus_BackgroundColor = [0 0 0];
else
    
    if S_ws_getbinchan.Select_index ==1
        Enable_minus = 'off';
        Enable_plus = 'on';
        Enable_plus_BackgroundColor = [0 1 0];
        Enable_minus_BackgroundColor = [1 1 1];
    elseif  S_ws_getbinchan.Select_index == length(S_ws_geterpset)
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
    observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
    observe_ERPDAT.Process_messg =2;
catch
    observe_ERPDAT.Process_messg =3;
end
observe_ERPDAT.Two_GUI = observe_ERPDAT.Two_GUI+1;
end


%%Mark the area or latency/amplitude of interest within defined latecies%%%
function ERP_mark_area_latency(r_ax,timex,moption,plot_erp_data,latency,line_colors,offset,Plority_plot)
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
                if Plority_plot==1
                    dataxx(data_check<0) = [];
                    timexx(data_check<0) = [];
                elseif Plority_plot ==-1
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
                if Plority_plot==1
                    dataxx(data_check>0) = [];
                    timexx(data_check>0) = [];
                elseif Plority_plot ==-1
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
                if Plority_plot==1
                    dataxxp(data_check<0) = [];
                    timexxp(data_check<0) = [];
                    dataxxn(data_check>0) = [];
                    timexxn(data_check>0) = [];
                    
                elseif Plority_plot ==-1
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
                    if Plority_plot==1
                        dataxx(data_check<0) = [];
                        timexx(data_check<0) = [];
                        data_check_unsl(data_check>0) =[];
                        timexx_unsl(data_check>0) = [];
                    elseif Plority_plot ==-1
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
                    if Plority_plot==1
                        dataxx(data_check>0) = [];
                        timexx(data_check>0) = [];
                        data_check_unsl(data_check<0) =[];
                        timexx_unsl(data_check<0) = [];
                    elseif Plority_plot ==-1
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
                    if Plority_plot==1
                        dataxx(data_check<0) = [];
                        timexx(data_check<0) = [];
                        data_check_unsl(data_check>0) =[];
                        timexx_unsl(data_check>0) = [];
                    elseif Plority_plot ==-1
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
