%This function is to plot ERP wave with single or multiple columns on one page.



% Author: Guanghui Zhang & Steve J. Luck & Andrew Stewart
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022



function f_redrawERP_try()
% Draw a demo ERP into the axes provided
global gui_erp;
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

S_ws_geterpplot = estudioworkingmemory('geterpplot');


%%Parameter from bin and channel panel
Elecs_shown = S_ws_getbinchan.elecs_shown{S_ws_getbinchan.Select_index};
Bins = S_ws_getbinchan.bins{S_ws_getbinchan.Select_index};
Bin_chans = S_ws_getbinchan.bins_chans(S_ws_getbinchan.Select_index);
Elec_list = S_ws_getbinchan.elec_list{S_ws_getbinchan.Select_index};
Matlab_ver = S_ws_getbinchan.matlab_ver;



%%Parameter from plotting panel
try
    Min_vspacing = S_ws_geterpplot.min_vspacing(S_ws_getbinchan.Select_index);
    Min_time = S_ws_geterpplot.min(S_ws_getbinchan.Select_index);
    Max_time = S_ws_geterpplot.max(S_ws_getbinchan.Select_index);
    Yscale = S_ws_geterpplot.yscale(S_ws_getbinchan.Select_index);
    Timet_low =S_ws_geterpplot.timet_low(S_ws_getbinchan.Select_index);
    Timet_high =S_ws_geterpplot.timet_high(S_ws_getbinchan.Select_index);
    Timet_step=S_ws_geterpplot.timet_step(S_ws_getbinchan.Select_index);
    Fill = S_ws_geterpplot.fill(S_ws_getbinchan.Select_index);
    Plority_plot = S_ws_geterpplot.Positive_up(S_ws_getbinchan.Select_index);
    ColumnNum = S_ws_geterpplot.Plot_column;
catch
    return;
end

Column_label = ColumnNum(S_ws_getbinchan.Select_index);

if Bin_chans == 0
    elec_n = S_ws_getbinchan.elec_n(S_ws_getbinchan.Select_index);
    max_elec_n = observe_ERPDAT.ALLERP(S_ws_geterpset(S_ws_getbinchan.Select_index)).nchan;
else
    elec_n = S_ws_getbinchan.bin_n(S_ws_getbinchan.Select_index);
    max_elec_n = observe_ERPDAT.ALLERP(S_ws_geterpset(S_ws_getbinchan.Select_index)).nbin;
end

% We first clear the existing axes ready to build a new one
if ishandle( gui_erp.ViewAxes )
    delete( gui_erp.ViewAxes );
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


clear pb r_ax plotgrid;
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;%%Get background color
catch
    ColorB_def = [0.95 0.95 0.95];
end
if isempty(ColorB_def)
    ColorB_def = [0.95 0.95 0.95];
end
gui_erp.plotgrid = uix.VBox('Parent',gui_erp.ViewContainer,'Padding',0,'Spacing',0,'BackgroundColor',ColorB_def);

pageinfo_box = uiextras.HBox( 'Parent', gui_erp.plotgrid,'BackgroundColor',ColorB_def);

gui_erp.plot_wav_legend = uiextras.HBox( 'Parent', gui_erp.plotgrid,'BackgroundColor',[1 1 1]);
gui_erp.ViewAxes_legend = uix.ScrollingPanel( 'Parent', gui_erp.plot_wav_legend,'BackgroundColor',ColorB_def);

gui_erp.ViewAxes = uix.ScrollingPanel( 'Parent', gui_erp.plot_wav_legend,'BackgroundColor',[1 1 1]);


%%Changed by Guanghui Zhang 2 August 2022-------panel for display the processing procedure for some functions, e.g., filtering
xaxis_panel = uiextras.HBox( 'Parent', gui_erp.plotgrid,'BackgroundColor',ColorB_def);%%%Message
gui_erp.Process_messg = uicontrol('Parent',xaxis_panel,'Style','text','String','','FontSize',20,'FontWeight','bold','BackgroundColor',ColorB_def);


%%Setting title
gui_erp.pageinfo_minus = uicontrol('Parent',pageinfo_box,'Style', 'pushbutton', 'String', '<','Callback',@page_minus,'FontSize',30,'BackgroundColor',[1 1 1]);
if S_ws_getbinchan.Select_index ==1
    gui_erp.pageinfo_minus.Enable = 'off';
end

gui_erp.pageinfo_plus = uicontrol('Parent',pageinfo_box,'Style', 'pushbutton', 'String', '>','Callback',@page_plus,'FontSize',30,'BackgroundColor',[1 1 1]);
if S_ws_getbinchan.Select_index == numel(S_ws_geterpset)
    gui_erp.pageinfo_plus.Enable = 'off';
end

pageinfo_str = ['Page',32,num2str(S_ws_getbinchan.Select_index),'/',num2str(numel(S_ws_geterpset)),':',32,observe_ERPDAT.ERP.erpname];

pageinfo_text = uicontrol('Parent',pageinfo_box,'Style','text','String',pageinfo_str,'FontSize',14,'FontWeight','bold');

if length(S_ws_geterpset) ==1
    Enable_minus = 'off';
    Enable_plus = 'off';
    Enable_plus_BackgroundColor = [1 1 1];
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
gui_erp.pageinfo_minus.Enable = Enable_minus;
gui_erp.pageinfo_plus.Enable = Enable_plus;
gui_erp.pageinfo_plus.ForegroundColor = Enable_plus_BackgroundColor;
gui_erp.pageinfo_minus.ForegroundColor = Enable_minus_BackgroundColor;

set(pageinfo_box, 'Sizes', [50 50 -1] );
set(pageinfo_box,'BackgroundColor',ColorB_def);
set(pageinfo_text,'BackgroundColor',ColorB_def);
%Setting title. END,'BackgroundColor',ColorB_def

%for i=1:splot_n

%
%%------------Setting the number of data and plotting---------------------
ndata = 0;
nplot = 0;
if Bin_chans == 0 %if channels with bin overlay
    ndata = Bins;
    nplot = Elecs_shown;
else %if bins with channel overlay
    ndata = Elecs_shown;
    nplot = Bins;
end

%
timeor  = observe_ERPDAT.ERP.times; % original time vector
timex = timeor;
[xxx, latsamp, latdiffms] = closest(timex, [Min_time Max_time]);
tmin = latsamp(1);
tmax = latsamp(2);

if tmin < 1
    tmin = 1;
end

if tmax > numel(observe_ERPDAT.ERP.times)
    tmax = numel(observe_ERPDAT.ERP.times);
end

plot_erp_data = nan(tmax-tmin+1,numel(ndata));
for i = 1:splot_n
    if Bin_chans == 0
        for i_bin = 1:numel(ndata)
            plot_erp_data(:,i_bin,i) = observe_ERPDAT.ERP.bindata(Elecs_shown(i),tmin:tmax,Bins(i_bin))'*Plority_plot; %
        end
    else
        for i_bin = 1:numel(ndata)
            plot_erp_data(:,i_bin,i) = observe_ERPDAT.ERP.bindata(Elecs_shown(i_bin),tmin:tmax,Bins(i))'*Plority_plot; %
        end
    end
end

perc_lim = Yscale;
percentile = perc_lim*3/2;

[~,~,b] = size(plot_erp_data);


%
%%%------------Setting xticklabels for each row of each wave--------------
xstep_label = estudioworkingmemory('erp_xtickstep');
if isempty(xstep_label)
    xstep_label =0;
end
if ~xstep_label
    [def Timet_step]= default_time_ticks_studio(observe_ERPDAT.ERP, [Min_time,Max_time]);
    if ~isempty(def{1,1})
        xticks_clomn = str2num(def{1,1});
        while xticks_clomn(end)<=Max_time
            xticks_clomn(numel(xticks_clomn)+1) = xticks_clomn(end)+Timet_step;
            if xticks_clomn(end)>Max_time
                xticks_clomn = xticks_clomn(1:end-1);
                break;
            end
        end
    else
        xticks_clomn = (Min_time:Timet_step:Max_time);
    end
else
    
    
    xticks_clomn = (Min_time:Timet_step:Max_time);
end
Timet_step_p = ceil(Timet_step/(1000/observe_ERPDAT.ERP.srate));%% Time points of the gap between columns

%
%%----------------------Modify the data into  multiple-columns---------------------------------------
rowNum = ceil(b/Column_label);
plot_erp_data_new = NaN(size(plot_erp_data,1),size(plot_erp_data,2),rowNum*Column_label);

plot_erp_data_new(:,:,1:size(plot_erp_data,3))  =  plot_erp_data;
plot_erp_data_new_trans = [];


if  Column_label==1
    for Numofrow = 1:rowNum
        plot_erp_data_new_trans(:,:,:,Numofrow) = plot_erp_data_new(:,:,(Numofrow-1)*Column_label+1:Numofrow*Column_label);
    end
    
    clear plot_erp_data;
    plot_erp_data_new_trans = permute(plot_erp_data_new_trans,[1,3,2,4]) ;
    plot_erp_data = reshape(plot_erp_data_new_trans,size(plot_erp_data_new_trans,1)*size(plot_erp_data_new_trans,2),size(plot_erp_data_new_trans,3),size(plot_erp_data_new_trans,4));
    
elseif Column_label>1
    
    plot_erp_data_trans_clumns = NaN(size(plot_erp_data_new,1)*Column_label+(Column_label-1)*Timet_step_p,size(plot_erp_data_new,2),rowNum);
    for Numofrow = 1:rowNum
        Data_column = plot_erp_data_new(:,:,(Numofrow-1)*Column_label+1:Numofrow*Column_label);
        for Numofcolumn = 1:Column_label
            low_interval = size(plot_erp_data_new,1)*(Numofcolumn-1)+1+(Numofcolumn-1)*Timet_step_p;
            high_interval = size(plot_erp_data_new,1)*(Numofcolumn-1)+(Numofcolumn-1)*Timet_step_p+size(plot_erp_data_new,1);
            plot_erp_data_trans_clumns(low_interval:high_interval,:,Numofrow) = squeeze(Data_column(:,:,Numofcolumn));
        end
    end
    plot_erp_data = plot_erp_data_trans_clumns;
end

ind_plot_height = percentile*2; % Height of each individual subplot

offset = [];
if Bin_chans == 0
    offset = (size(plot_erp_data,3)-1:-1:0)*ind_plot_height;
else
    offset = (size(plot_erp_data,3)-1:-1:0)*ind_plot_height;
end
[~,~,b] = size(plot_erp_data);
for i = 1:b
    plot_erp_data(:,:,i) = plot_erp_data(:,:,i) + ones(size(plot_erp_data(:,:,i)))*offset(i);
end



r_ax = axes('Parent', gui_erp.ViewAxes,'Color','none','Box','on','FontWeight','bold');
hold(r_ax,'on');
set(gui_erp.plot_wav_legend,'Sizes',[80 -10]);
r_ax_legend = axes('Parent', gui_erp.ViewAxes_legend,'Color','none','Box','off');
hold(r_ax_legend,'on');


try
    f_bin = 1000/observe_ERPDAT.ERP.srate;
catch
    f_bin = 1;
end

ts = observe_ERPDAT.ERP.times(tmin:tmax);
ts_colmn = ts;

%
%%------------------Adjust the data into multiple/single columns------------
if  Column_label>1 % Plotting waveforms with munltiple-columns
    xticks_org = xticks_clomn;
    
    for Numofcolumn = 1:Column_label-1
        xticks_clomn_add = [1:numel(ts)+Timet_step_p].*f_bin+(ts_colmn(end).*ones(1,numel(ts)+Timet_step_p));
        ts_colmn = [ts_colmn,xticks_clomn_add];
    end
    
    X_zero_line(1) =ts(1);
    for Numofcolumn = 1:Column_label-1
        if Numofcolumn ==1
            X_zero_line(Numofcolumn+1) = X_zero_line(Numofcolumn)+ ts(end)-ts(1)+f_bin + (Timet_step_p/2)*f_bin;
        else
            X_zero_line(Numofcolumn+1) = X_zero_line(Numofcolumn)+ ts(end)-ts(1)+f_bin + (Timet_step_p)*f_bin;
        end
    end
    
    [xticks,xticks_labels] = f_geterpxticklabel(observe_ERPDAT.ERP,xticks_clomn,Column_label,[Min_time Max_time],Timet_step);
    ts = ts_colmn;
    Min_time = ts(1);
    Max_time = ts(end);
    
else%% Plotting waveforms with single-column
    %%%------------getting xticklabels for each row of each wave--------------
    xticks =xticks_clomn;
    X_zero_line(1) =ts(1);
    for Numofxlabel = 1:numel(xticks)
        xticks_labels{Numofxlabel} = num2str(xticks(Numofxlabel));
    end
end


splot_n = size(plot_erp_data,3);%%Adjust the columns

set(r_ax,'XLim',[Min_time Max_time]);

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
    plot(r_ax,ts,x_axs.*offset(end),'color',[1 1 1],'LineWidth',1);
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
    elseif abs(tick_bottom)<abs(Yscale)/5
        tick_bottom = - abs(Yscale)/5;
    end
    %
    tick_top = 0;
    
    line(r_ax,props.XLim, [0 0] + myX_Crossing, 'color', [1 1 1]);%'k'
    
    if ~isempty(props.XTick)
        xtick_x = repmat(props.XTick, 2, 1);
        xtick_y = repmat([tick_bottom; tick_top] + myX_Crossing, 1, length(props.XTick));
        line(r_ax,xtick_x, xtick_y, 'color', 'k','LineWidth',1.5);
    end
    set(r_ax, 'XTick', [], 'XTickLabel', []);
    %         tick_bottom = -props.TickLength(1)*diff(props.YLim);
    nTicks = length(props.XTick);
    h_ticklabels = zeros(size(props.XTick));
    if nTicks>1
        if numel(offset)==jj
            kkkk = 1;
        else
            kkkk = 2;
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

%
%%----------------Start:Remove xticks for the columns without waves in the last row-------------------------
Element_left = numel(nplot) - (ceil(numel(nplot)/Column_label)-1)*Column_label;
x_axset = plot(r_ax,ts,x_axs.*offset(end),'color', [1 1 1],'LineWidth',1);
set(r_ax,'XTick',xticks, ...
    'box','off', 'Color','none','xticklabels',xticks_labels,'FontWeight','bold');
myX_Crossing = offset(end);
props = get(r_ax);

tick_bottom = -props.TickLength(1)*diff(props.YLim);
if abs(tick_bottom) > abs(Yscale)/5
    try
        tick_bottom = - abs(Yscale)/5;
    catch
        tick_bottom = tick_bottom;
    end
elseif abs(tick_bottom)<abs(Yscale)/5
    tick_bottom = - abs(Yscale)/5;
end

tick_top = 0;
line(r_ax,props.XLim, [0 0] + myX_Crossing, 'color', [1 1 1]);%'k'
nTicks = length(props.XTick);
if ~isempty(props.XTick)
    xtick_x = repmat(props.XTick, 2, 1);
    xtick_y = repmat([tick_bottom; tick_top] + myX_Crossing, 1, length(props.XTick));
    line(r_ax,xtick_x(:,1:ceil(nTicks/Column_label*Element_left)), xtick_y(:,1:ceil(nTicks/Column_label*Element_left)), 'color', 'k','LineWidth',1.5);
end
set(r_ax, 'XTick', [], 'XTickLabel', []);
if nTicks>1
    for iCount = 1:ceil(nTicks/Column_label*Element_left)
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
%%--------------------------End:Remove xticks for the columns without waves in the last row-------------------------

%
%%-----------------Get zeroline for each row-----------------------------
row_baseline = NaN(numel(ts),splot_n);
count = 0;
for Numofsplot = 0:splot_n-1
    for Numofcolumn = 1:Column_label
        count = count +1;
        if count> numel(nplot)
            
            break;
            
        end
        low_interval = size(plot_erp_data_new,1)*(Numofcolumn-1)+1+(Numofcolumn-1)*Timet_step_p;
        high_interval = size(plot_erp_data_new,1)*(Numofcolumn-1)+(Numofcolumn-1)*Timet_step_p+size(plot_erp_data_new,1);
        row_baseline(low_interval:high_interval,Numofsplot+1) = ones(numel(low_interval:high_interval),1).*offset(Numofsplot+1);
    end
end


%
%%-------------------------Plotting ERP waves-----------------------------
pb_here = plot(r_ax,ts, [new_erp_data],'LineWidth',1.5);

set(r_ax, 'XTick', [], 'XTickLabel', []);

%
%%----------------Marking 0 point (event-locked)--------------------------
[xxx, latsamp_0, latdiffms_0] = closest(xticks, [0]);
if numel(offset)>1
    if latdiffms_0 ==0
        for Numofcolumn = 1:Column_label
            xline(r_ax,xticks((Numofcolumn-1)*numel(xticks_clomn)+latsamp_0),'k-.','LineWidth',1);%%'Color',Marking start time point for each column
        end
    end
elseif numel(offset)==1
    
    for Numofcolumn = 1:numel(nplot)
        xline(r_ax,xticks((Numofcolumn-1)*numel(xticks_clomn)+latsamp_0),'k-.','LineWidth',1);%%'Color',Marking start time point for each column
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
set(r_ax,'XLim',[Min_time Max_time],'Ylim',newlim);


%
%%--------------Setting color for each wave--------------------------
% if Column_label>1
%     for i = 0:splot_n-1
%         r_ax.Children(end-i).Color = [1 1 1];
%     end
% end

% for i = splot_n+1:numel(pb_here)
%     pb_here(i).Color = line_colors((i-splot_n),:);
% end
for i = 1:numel(pb_here)
    pb_here(i).Color = line_colors(i,:);
end
%
% for i = 1:splot_n-1
%     pb_here(i).Color = [0 0 0];
%     pb_here(i).LineWidth=.01;
% end




%%------------Marking start time point for each column---------------------
if  Column_label>1
    for ii = 2:numel(X_zero_line)
        xline(r_ax,X_zero_line(ii), 'y--','LineWidth',2);
    end
end

for Numofplot = 1:size(row_baseline,2)
    plot(r_ax,ts,row_baseline(:,Numofplot),'color',[0 0 0],'LineWidth',1.5);
end
ylabs = [fliplr(-perc_lim:-perc_lim:newlim(1)) ylabs(2:end-1) (yticks(end):perc_lim:newlim(2))-yticks(end)+perc_lim];
yticks = [fliplr(-perc_lim:-perc_lim:newlim(1)) yticks(2:end-1) yticks(end):perc_lim:newlim(2)];



%
%%-------------Name of bin/channel for each subplot--------------------------
if  Column_label==1
    if numel(offset)>1
        count = 0;
        for i = 0:numel(offset)-1
            leg_str = '';
            
            count  = count+1;
            try
                if Bin_chans == 0
                    leg_str = sprintf('%s',Elec_list{Elecs_shown(count)});
                else
                    leg_str = sprintf('%s',observe_ERPDAT.ERP.bindescr{Bins(count)});
                end
            catch
                leg_str = '';
            end
            text(r_ax,ts(1),offset(i+1)+offset(end-1)/6,leg_str,'FontWeight','bold','FontSize', 14);
        end
    end
    
    try
        if Bin_chans == 0
            leg_str = sprintf('%s',Elec_list{Elecs_shown(end)});
        else
            leg_str = sprintf('%s',observe_ERPDAT.ERP.bindescr{Bins(end)});
        end
    catch%%
        leg_str = '';
    end
    
    try
        text(r_ax,ts(1),offset(end-1)/6,leg_str,'FontWeight','bold','FontSize', 14);
    catch
        text(r_ax,ts(1),Yscale/2,leg_str,'FontWeight','bold','FontSize', 14);
    end
else%% Getting y ticks and legends for multiple-columns
    if numel(offset)>1
        count = 0;
        for i = 0:numel(offset)-1
            leg_str = '';
            for Numofcolumn = 1: Column_label
                count  = count+1;
                try
                    if Bin_chans == 0
                        leg_str = sprintf('%s',Elec_list{Elecs_shown(count)});
                    else
                        leg_str = sprintf('%s',observe_ERPDAT.ERP.bindescr{Bins(count)});
                    end
                catch
                    leg_str = '';
                end
                if Numofcolumn ==1
                    text(r_ax,X_zero_line(Numofcolumn),offset(i+1)+offset(end-1)/6,leg_str,'FontWeight','bold','FontSize', 14);
                else
                    text(r_ax,X_zero_line(Numofcolumn)+Timet_step/2,offset(i+1)+offset(end-1)/6,leg_str,'FontWeight','bold','FontSize', 14);
                end
            end
        end
    end
    
    
    count = (numel(offset)-1)*Column_label;
    leg_str = '';
    for Numofcolumn = 1:Column_label
        count  = count+1;
        try
            if Bin_chans == 0
                leg_str = sprintf('%s',Elec_list{Elecs_shown(count)});
            else
                leg_str = sprintf('%s',observe_ERPDAT.ERP.bindescr{Bins(count)});
            end
        catch%%
            leg_str = '';
        end
        try
            
            if Numofcolumn ==1
                text(r_ax,X_zero_line(Numofcolumn),offset(i+1)+offset(end-1)/6,leg_str,'FontWeight','bold','FontSize', 14);
            else
                text(r_ax,X_zero_line(Numofcolumn)+Timet_step/2,offset(i+1)+offset(end-1)/6,leg_str,'FontWeight','bold','FontSize', 14);
            end
        catch
            
            if Numofcolumn ==1
                text(r_ax,X_zero_line(Numofcolumn),Yscale/2,leg_str,'FontWeight','bold','FontSize', 14);
            else
                text(r_ax,X_zero_line(Numofcolumn)+Timet_step/2,Yscale/2,leg_str,'FontWeight','bold','FontSize', 14);
            end
            %             text(r_ax,X_zero_line(Numofcolumn),Yscale/2,leg_str,'FontWeight','bold','FontSize', 14);
        end
    end
    
end
%


%
%%-------------Setting x/yticks and ticklabels--------------------------------
Ylabels_new = ylabs.*Plority_plot;
[~,Y_label] = find(Ylabels_new == -0);
Ylabels_new(Y_label) = 0;
% xticks = (Min_time:Timet_step:Max_time);
% some options currently only work post Matlab R2016a ,'XLim',[Min_time Max_time],'XLim',[Min_time Max_time]
if Matlab_ver >= 2016
    set(r_ax,'FontSize',tsize,'FontWeight','bold','XAxisLocation','origin',...
        'XGrid','on','YGrid','on','YTick',yticks,'YTickLabel',Ylabels_new, ...
        'YLim',newlim,'XTick',xticks, ...
        'box','off', 'Color','none','xticklabels',xticks_labels);
else
    set(r_ax,'FontSize',tsize,'FontWeight','bold','XAxisLocation','bottom',...
        'XGrid','on','YGrid','on','YTick',yticks,'YTickLabel',Ylabels_new, ...
        'YLim',newlim, 'XTick',xticks, ...
        'box','off', 'Color','none','xticklabels',xticks_labels);
    hline(0,'k'); % backup xaxis
end
if Column_label>1
    set(r_ax,'XGrid','on','YGrid','on');%,'XDir','reverse'
end
set(r_ax, 'XTick', [], 'XTickLabel', [],'FontWeight', 'bold');
r_ax.YAxis.LineWidth = 1.5;

hold(r_ax,'off');
%



%
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
    plot(r_ax_legend,[0 0],'Color',line_colors_ldg(Numofplot,:,:),'LineWidth',3)
end

if Bin_chans == 0
    
    Leg_Name = {};
    
    for Numofbin = 1:numel(Bins)
        Leg_Name{Numofbin} = strcat('Bin',num2str(Bins(Numofbin)));
    end
else
    for Numofchan = 1:numel(Elecs_shown)
        Leg_Name{Numofchan} = Elec_list{Numofchan};
    end
end
legend(r_ax_legend,Leg_Name,'FontSize',14,'TextColor','blue');
legend(r_ax_legend,'boxoff');
%

%-------fix scaling shrinkage--------------
pos_fix = r_ax.Position;
pos_fix(2) = 1; % Start at the bottom
pos_fix(4) = pb_height - 1; % fill the height;

gui_erp.plotgrid.Heights(1) = 30; % set the first element (pageinfo) to 30px high
gui_erp.plotgrid.Heights(3) = 30; % set the second element (x axis) to 30px high
gui_erp.plotgrid.Units = 'pixels';
if splot_n*pb_height<(gui_erp.plotgrid.Position(4)-gui_erp.plotgrid.Heights(1))&&Fill
    pb_height = (gui_erp.plotgrid.Position(4)-gui_erp.plotgrid.Heights(1)-gui_erp.plotgrid.Heights(2))/splot_n;
end

gui_erp.ViewAxes.Heights = splot_n*pb_height;
gui_erp.plotgrid.Units = 'normalized';

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
function page_minus(~,~)
global observe_ERPDAT;
global  gui_erp;


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


observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;


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
gui_erp.pageinfo_minus.Enable = Enable_minus;
gui_erp.pageinfo_plus.Enable = Enable_plus;
% f_redrawERP_mt_viewer();
gui_erp.pageinfo_plus.ForegroundColor = Enable_plus_BackgroundColor;
gui_erp.pageinfo_minus.ForegroundColor = Enable_minus_BackgroundColor;
end





%------------------Display the waveform for next ERPset--------------------
function page_plus(~,~)
global observe_ERPDAT;
global  gui_erp;


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

observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;


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
gui_erp.pageinfo_minus.Enable = Enable_minus;
gui_erp.pageinfo_plus.Enable = Enable_plus;
gui_erp.pageinfo_plus.ForegroundColor = Enable_plus_BackgroundColor;
gui_erp.pageinfo_minus.ForegroundColor = Enable_minus_BackgroundColor;
end


