

function [new_erp_data,Amp_out,Lat_out_trals,Amp,Lat]= f_ERP_plot_wav(ERPIN)
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
Min_vspacing = S_ws_geterpplot.min_vspacing(S_ws_getbinchan.Select_index);
Min_time = S_ws_geterpplot.min(S_ws_getbinchan.Select_index);
Max_time = S_ws_geterpplot.max(S_ws_getbinchan.Select_index);
Yscale = S_ws_geterpplot.yscale(S_ws_getbinchan.Select_index);
Timet_low =S_ws_geterpplot.timet_low(S_ws_getbinchan.Select_index);
Timet_high =S_ws_geterpplot.timet_high(S_ws_getbinchan.Select_index);
Timet_step=S_ws_geterpplot.timet_step(S_ws_getbinchan.Select_index);
Fill = S_ws_geterpplot.fill(S_ws_getbinchan.Select_index);
Plority_plot = S_ws_geterpplot.Positive_up(S_ws_getbinchan.Select_index);


if Bin_chans == 0
    elec_n = S_ws_getbinchan.elec_n(S_ws_getbinchan.Select_index);
    max_elec_n = ERPIN.nchan;
else
    elec_n = S_ws_getbinchan.bin_n(S_ws_getbinchan.Select_index);
    max_elec_n = ERPIN.nbin;
end


ndata = 0;
nplot = 0;
if Bin_chans == 0
    ndata = Bins;
    nplot = Elecs_shown;
else
    ndata = Elecs_shown;
    nplot = Bins;
end



[xxx, latsamp, latdiffms] = closest(ERPIN.times, [Min_time Max_time]);
tmin = latsamp(1);
tmax = latsamp(2);

if tmin < 1
    tmin = 1;
end

if tmax > numel(ERPIN.times)
    tmax = numel(ERPIN.times);
end


splot_n = elec_n;

plot_erp_data = nan(tmax-tmin+1,numel(ndata));
for i = 1:splot_n
    if Bin_chans == 0
        for i_bin = 1:numel(ndata)
            plot_erp_data(:,i_bin,i) = ERPIN.bindata(Elecs_shown(i),tmin:tmax,Bins(i_bin))'*Plority_plot; %
        end
    else
        for i_bin = 1:numel(ndata)
            plot_erp_data(:,i_bin,i) = ERPIN.bindata(Elecs_shown(i_bin),tmin:tmax,Bins(i))'*Plority_plot; %
        end
    end
end


%%Transfer the original data to what can be used to plot in ERPlab Studio
%%based on the seleted channels and bins, time-window
perc_lim = Yscale;
percentile = perc_lim*3/2;
ind_plot_height = percentile*2;
offset = [];
if Bin_chans == 0
    offset = (numel(Elecs_shown)-1:-1:0)*ind_plot_height;
else
    offset = (numel(Bins)-1:-1:0)*ind_plot_height;
end
[~,~,b] = size(plot_erp_data);

for i = 1:b
    plot_erp_data(:,:,i) = plot_erp_data(:,:,i) + ones(size(plot_erp_data(:,:,i)))*offset(i);
end



[a,c,b] = size(plot_erp_data);
new_erp_data = zeros(a,b*c);
for i = 1:b
    new_erp_data(:,((c*(i-1))+1):(c*i)) = plot_erp_data(:,:,i);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%Find the amplitude and latency based on geterpvalues%%%%%%%%%%%%%%%%%%%%%%%%%%%%



erp_m_t_p = estudioworkingmemory('geterpvalues');

if isempty(erp_m_t_p)
    msgboxText = ['EStudio says: Please select the meaurement type of interest and set the related parameters from "ERP measurement tool".'];
    title = 'EStudio: ERP measurement tool';
    errorfound(msgboxText, title);
    return;
end


MeasureName = {'meanbl','peakampbl', 'peaklatbl','fareatlat','fpeaklat','fninteglat','fareaplat','fareanlat',...
    'areat','ninteg','areap','arean','areazt','nintegz','areazp','areazn','instabl'};
[C,IA] = ismember_bc2({erp_m_t_p.Measure}, MeasureName);
if ~any(IA) || isempty(IA)
    IA =1;
end


if isempty(erp_m_t_p.latency)
    msgboxText =  'Please set a Measurement window';
    title = 'ERPLAB: ERP Measurement Tool';
    errorfound(msgboxText, title);
    return;
end
moption = erp_m_t_p.Measure;
latency = erp_m_t_p.latency;
if isempty(moption)
    msgboxText = ['EStudio says: User must specify a type of measurement.'];
    title = 'EStudio: ERP measurement tool- "Measurement type".';
    errorfound(msgboxText, title);
    return;
end
if ismember_bc2({moption}, {'instabl', 'areazt','areazp','areazn', 'nintegz'})
    if length(latency)~=1
        msgboxText = ['EStudio says: ' moption ' only needs 1 latency value.'];
        title = 'EStudio: ERP measurement tool- "Measurement type".';
        errorfound(msgboxText, title);
        return;
    end
else
    if length(latency)~=2
        msgboxText = ['EStudio says: ' moption ' needs 2 latency values.'];
        title = 'EStudio: ERP measurement tool- "Measurement type".';
        errorfound(msgboxText, title);
        return;
    else
        if latency(1)>=latency(2)
            msgboxText = ['For latency range, lower time limit must be on the left.\n'...
                'Additionally, lower time limit must be at least 1/samplerate seconds lesser than the higher one.'];
            title = 'EStudio: ERP measurement tool-Measurement window';
            errorfound(sprintf(msgboxText), title);
            return
        end
    end
end
binArray =[1:ERPIN.nbin];
chanArray = [1:ERPIN.nchan];
Amp   = zeros(length(binArray), length(chanArray));
Lat   = [];

erp_m_t_p.Erpsets = S_ws_geterpset;




MeasureName = {'meanbl','peakampbl', 'peaklatbl','fareatlat','fpeaklat','fninteglat','fareaplat','fareanlat',...
    'areat','ninteg','areap','arean','areazt','nintegz','areazp','areazn','instabl'};
[C,IA] = ismember_bc2({erp_m_t_p.Measure}, MeasureName);
if ~any(IA) || isempty(IA)
    IA =1;
end

if isempty(erp_m_t_p.latency)
    msgboxText =  'Please set a Measurement window';
    title = 'ERPLAB: ERP Measurement Tool';
    errorfound(msgboxText, title);
    return;
end
moption = erp_m_t_p.Measure;
latency = erp_m_t_p.latency;
if isempty(moption)
    msgboxText = ['ERPLAB says: User must specify a type of measurement.'];
    title = 'EStudio: ERP measurement tool- "Measurement type".';
    errorfound(msgboxText, title);
    return;
end
if ismember_bc2({moption}, {'instabl', 'areazt','areazp','areazn', 'nintegz'})
    if length(latency)~=1
        msgboxText = ['ERPLAB says: ' moption ' only needs 1 latency value.'];
        title = 'EStudio: ERP measurement tool- "Measurement type".';
        errorfound(msgboxText, title);
        return;
    end
else
    if length(latency)~=2
        msgboxText = ['ERPLAB says: ' moption ' needs 2 latency values.'];
        title = 'EStudio: ERP measurement tool- "Measurement type".';
        errorfound(msgboxText, title);
        return;
    else
        if latency(1)>=latency(2)
            msgboxText = ['For latency range, lower time limit must be on the left.\n'...
                'Additionally, lower time limit must be at least 1/samplerate seconds lesser than the higher one.'];
            title = 'EStudio: ERP measurement tool-Measurement window';
            errorfound(sprintf(msgboxText), title);
            return
        end
    end
end

% ALLERP = evalin('base','ALLERP');
if isempty(erp_m_t_p.Afraction)
    erp_m_t_p.Afraction  =0.5;
end

if strcmp(erp_m_t_p.Peakpolarity,'positive')%check the polirity
    polpeak =1;
else
    polpeak =0;
end

if strcmp( erp_m_t_p.Peakreplace,'NaN')
    locpeakrep=0;
else
    locpeakrep =1;
end


if strcmp(erp_m_t_p.Fracreplace,'NaN')
    fracmearep =0;
elseif strcmp(erp_m_t_p.Fracreplace,'absolute')
    fracmearep=1;
else
    fracmearep =2;
end

[Amp, Lat]  = geterpvalues(ERPIN, erp_m_t_p.latency, binArray, chanArray, ...
    MeasureName{IA}, erp_m_t_p.Baseline, erp_m_t_p.Component,...
    polpeak, erp_m_t_p.Neighborhood, locpeakrep,...
    erp_m_t_p.Afraction, fracmearep, erp_m_t_p.InterpFactor,erp_m_t_p.PeakOnset);

% [ALLERP, Amp, Lat] = pop_geterpvalues(ALLERP, erp_m_t_p.latency, binArray,chanArray,...
%     'Erpsets', Current_ERP, 'Measure',MeasureName{IA}, 'Component', erp_m_t_p.Component,...
%     'Resolution', erp_m_t_p.Resolution, 'Baseline', erp_m_t_p.Baseline, 'Binlabel', erp_m_t_p.Binlabel,...
%     'Peakpolarity',erp_m_t_p.Peakpolarity, 'Neighborhood', erp_m_t_p.Neighborhood, 'Peakreplace', erp_m_t_p.Peakreplace,...
%      'Warning',erp_m_t_p.Warning,'SendtoWorkspace', erp_m_t_p.SendtoWorkspace, 'Append', erp_m_t_p.Append,...
%     'FileFormat', erp_m_t_p.FileFormat,'Afraction', erp_m_t_p.Afraction, 'Mlabel', erp_m_t_p.Mlabel,...
%     'Fracreplace', erp_m_t_p.Fracreplace,'IncludeLat', erp_m_t_p.IncludeLat, 'InterpFactor', erp_m_t_p.InterpFactor,...
%     'PeakOnset',erp_m_t_p.PeakOnset);

Lat_out_trals = {};

for i = 1:splot_n
    if Bin_chans == 0
        for i_bin = 1:numel(ndata)
            Amp_out_trans(i_bin,i) = Amp(Bins(i_bin),Elecs_shown(i))*Plority_plot; %
            if ~isempty(Lat)
                Lat_out_trals{i_bin,i} =  Lat{Bins(i_bin),Elecs_shown(i)};
            end
        end
    else
        for i_bin = 1:numel(ndata)
            Amp_out_trans(i_bin,i) = Amp(Bins(i),Elecs_shown(i_bin))*Plority_plot; %
            if ~isempty(Lat)
                Lat_out_trals{i_bin,i} =  Lat{Bins(i),Elecs_shown(i_bin)};
            end
        end
    end
end
Amp_out = zeros(c,b);

if ismember_bc2(moption, {'meanbl','peakampbl','areazt','areazp','areazn', 'nintegz','instabl'})
    for i = 1:b
        Amp_out(:,i) = Amp_out_trans(:,i) + ones(size(Amp_out_trans(:,i)))*offset(i);
    end
elseif ismember_bc2(moption, {'peaklatbl','fpeaklat','fareatlat', 'fareaplat','fninteglat','fareanlat'})
    
    for i = 1:b
        Amp_out(:,i) = Amp_out_trans(:,i)*Plority_plot;
    end
    
end



return;