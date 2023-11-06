

function [new_erp_data,Amp_out,Lat_out_trals,Amp,Lat]= f_ERP_plot_wav(ERPIN)
global observe_ERPDAT;

ERPArray= estudioworkingmemory('selectederpstudio');
if isempty(ERPArray) ||any(ERPArray(:) > length(observe_ERPDAT.ALLERP)) || any(ERPArray(:)<=0)
    ERPArray =  length(observe_ERPDAT.ALLERP) ;
    estudioworkingmemory('selectederpstudio',ERPArray);
    observe_ERPDAT.CURRENTERP = ERPArray;
    observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(ERPArray);
    assignin('base','ERP',observe_ERPDAT.ERP);
    assignin('base','ALLERP', observe_ERPDAT.ALLERP);
    assignin('base','CURRENTERP', observe_ERPDAT.CURRENTERP);
end

%%Parameter from bin and channel panel
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
Baseline = OutputViewerparerp{14};
InterpFactor =  OutputViewerparerp{15};
Resolution =OutputViewerparerp{16};
Afraction=OutputViewerparerp{17};
polpeak = OutputViewerparerp{18};
locpeakrep= OutputViewerparerp{19};
fracmearep= OutputViewerparerp{20};
PeakOnset= OutputViewerparerp{21};
Neighborhood= OutputViewerparerp{23};
if BinchanOverlay == 0
    splot_n = numel(OutputViewerparerp{1});
else
    splot_n = numel(OutputViewerparerp{2});
end

if BinchanOverlay == 0
    ndata = BinArray;
else
    ndata = ChanArray;
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

plot_erp_data = nan(tmax-tmin+1,numel(ndata));
for i = 1:splot_n
    if BinchanOverlay == 0
        for i_bin = 1:numel(ndata)
            plot_erp_data(:,i_bin,i) = ERPIN.bindata(ChanArray(i),tmin:tmax,BinArray(i_bin))'*positive_up; %
        end
    else
        for i_bin = 1:numel(ndata)
            plot_erp_data(:,i_bin,i) = ERPIN.bindata(ChanArray(i_bin),tmin:tmax,BinArray(i))'*positive_up; %
        end
    end
end

%%Transfer the original data to what can be used to plot in ERPlab Studio
%%based on the seleted channels and BinArray, time-window
perc_lim = Yscale;
percentile = perc_lim*3/2;
ind_plot_height = percentile*2;
offset = [];
if BinchanOverlay == 0
    offset = (numel(ChanArray)-1:-1:0)*ind_plot_height;
else
    offset = (numel(BinArray)-1:-1:0)*ind_plot_height;
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


MeasureName = {'meanbl','peakampbl', 'peaklatbl','fareatlat','fpeaklat','fninteglat','fareaplat','fareanlat',...
    'areat','ninteg','areap','arean','areazt','nintegz','areazp','areazn','instabl'};
[C,IA] = ismember_bc2({moption}, MeasureName);
if ~any(IA) || isempty(IA)
    IA =1;
end

if isempty(latency)
    msgboxText =  'Please set a Measurement window';
    title = 'ERPLAB: ERP Measurement Tool';
    errorfound(msgboxText, title);
    return;
end

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

MeasureName = {'meanbl','peakampbl', 'peaklatbl','fareatlat','fpeaklat','fninteglat','fareaplat','fareanlat',...
    'areat','ninteg','areap','arean','areazt','nintegz','areazp','areazn','instabl'};
[C,IA] = ismember_bc2({moption}, MeasureName);
if ~any(IA) || isempty(IA)
    IA =1;
end

if isempty(latency)
    msgboxText =  'Please set a Measurement window';
    title = 'ERPLAB: ERP Measurement Tool';
    errorfound(msgboxText, title);
    return;
end

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

if isempty(Afraction) || any(Afraction<=0) || any(Afraction>=0)
    Afraction  =0.5;
end

if isempty(polpeak) || numel(polpeak)~=1 || (polpeak~=0 && polpeak~=1)
    polpeak=0;
end

if isempty(locpeakrep) || numel(locpeakrep)~=1 || (locpeakrep~=0 && locpeakrep~=1)
    locpeakrep=1;
end

if isempty(fracmearep) || numel(fracmearep)~=1 || (fracmearep~=0 && fracmearep~=1 && fracmearep~=2)
    fracmearep=0;
end
Component = 0;

if isempty(PeakOnset) || numel(PeakOnset)~=1 || (PeakOnset~=0 && PeakOnset~=1)
    PeakOnset=1;
end
if isempty(Neighborhood) ||numel(Neighborhood)~=1 || any(Neighborhood<1)
    Neighborhood=1;
end


[Amp, Lat]  = geterpvalues(ERPIN, latency, binArray, chanArray, ...
    MeasureName{IA}, Baseline, Component,...
    polpeak, Neighborhood, locpeakrep,...
    Afraction, fracmearep, InterpFactor,PeakOnset);

Lat_out_trals = {};

for i = 1:splot_n
    if BinchanOverlay == 0
        for i_bin = 1:numel(ndata)
            Amp_out_trans(i_bin,i) = Amp(BinArray(i_bin),ChanArray(i))*positive_up; %
            if ~isempty(Lat)
                Lat_out_trals{i_bin,i} =  Lat{BinArray(i_bin),ChanArray(i)};
            end
        end
    else
        for i_bin = 1:numel(ndata)
            Amp_out_trans(i_bin,i) = Amp(BinArray(i),ChanArray(i_bin))*positive_up; %
            if ~isempty(Lat)
                Lat_out_trals{i_bin,i} =  Lat{BinArray(i),ChanArray(i_bin)};
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
        Amp_out(:,i) = Amp_out_trans(:,i)*positive_up;
    end
end

return;