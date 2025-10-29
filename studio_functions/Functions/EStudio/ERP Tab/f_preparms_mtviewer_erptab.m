%%this function is used to call back the parameters for plotting ERP wave

% *** This function is part of EStudio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Nov. 2023


function OutputViewerparerp = f_preparms_mtviewer_erptab(ERP,matlabfig,History,figureName)

OutputViewerparerp = '';
if nargin<1
    help f_preparms_erptab();
    return
end
if isempty(ERP)
    disp('f_preparms_erptab(): ERP is empty');
    return;
end

if nargin<3
    History = 'gui';
end

if nargin <2
    matlabfig=1;
end
if nargin <4
    figureName = '';
end

%%channel array and bin array
%
%%channels
ChanArray=estudioworkingmemory('ERP_ChanArray');
nbchan = ERP.nchan;
if isempty(ChanArray) || any(ChanArray(:)>nbchan) ||  any(ChanArray(:)<=0)
    ChanArray = 1:nbchan;
    estudioworkingmemory('ERP_ChanArray',ChanArray);
end

ERP_chanorders = estudioworkingmemory('ERP_chanorders');
ChanArray = reshape(ChanArray,1,[]);
try chanOrder = ERP_chanorders{1};catch chanOrder = 1;  end
if isempty(chanOrder) || any(chanOrder<=0) || numel(chanOrder)~=1 || (chanOrder~=1 && chanOrder~=2 && chanOrder~=3)
    chanOrder=1;
end
try
    if chanOrder==2
        if isfield(ERP,'chanlocs') && ~isempty(ERP.chanlocs)
            chanindexnew = f_estudio_chan_frontback_left_right(ERP.chanlocs(ChanArray));
            if ~isempty(chanindexnew)
                ChanArray = ChanArray(chanindexnew);
            end
        end
    elseif chanOrder==3
        [eloc, labels, theta, radius, indices] = readlocs(ERP.chanlocs);
        chanorders =   ERP_chanorders{2};
        chanorderindex = chanorders{1};
        chanorderindex1 = unique(chanorderindex);
        chanorderlabels = chanorders{2};
        [C,IA]= ismember_bc2(chanorderlabels,labels);
        Chanlanelsinst = labels(ChanArray);
        if ~any(IA==0) && numel(chanorderindex1) == length(labels)
            [C,IA1]= ismember_bc2(Chanlanelsinst,chanorderlabels);
            [C,IA2]= ismember_bc2(Chanlanelsinst,labels);
            ChanArray = IA2(chanorderindex(IA1));
        end
    end
catch
end

%
%%bins
BinArray=estudioworkingmemory('ERP_BinArray');
if isempty(BinArray) || any(BinArray(:)>ERP.nbin) || any(BinArray(:)<=0)
    BinArray  = [1:ERP.nbin];
    estudioworkingmemory('ERP_BinArray',BinArray);
end


%
%%Plot setting
ERPTab_plotset_pars = estudioworkingmemory('ERPTab_plotset_pars');

%
%%time range
timeStartdef = ERP.times(1);
timEnddef = ERP.times(end);
[def xstepdef]= default_time_ticks_studio(ERP, [ERP.times(1),ERP.times(end)]);

try timerange = ERPTab_plotset_pars{1}; catch timerange =[timeStartdef,timEnddef]; end
try
    timeStart = timerange(1);
catch
    timeStart = timeStartdef;
end
if isempty(timeStart) || numel(timeStart)~=1 || any(timeStart>timEnddef)
    timeStart = timeStartdef;
end

try
    timEnd = timerange(2);
catch
    timEnd = timEnddef;
end
if isempty(timEnd) || numel(timEnd)~=1 || any(timEnd<timeStart)
    timEnd = timEnddef;
end

if timeStart> timEnd
    timEnd = timEnddef;
    timeStart = timeStartdef;
end

try xtickstep = ERPTab_plotset_pars{2}; catch xtickstep = xstepdef; end
if isempty(xtickstep) || numel(xtickstep)~=1 || any(xtickstep<=0) || xtickstep > (timEnd-timeStart)
    xtickstep = xstepdef;
end

%%y scale
try PolarityValue=ERPTab_plotset_pars{7};catch PolarityValue=1; end
if isempty(PolarityValue) || numel(PolarityValue)~=1 || (PolarityValue~=1&&PolarityValue~=-1)
    PolarityValue=1;
end
if PolarityValue==1
    positive_up = 1;
else
    positive_up = -1;
end

YScaledef =prctile(ERP.bindata(:)*positive_up,95)*2/3;
if YScaledef>= 0&&YScaledef <=0.1
    YScaledef = 0.1;
elseif YScaledef< 0&& YScaledef > -0.1
    YScaledef = 0.1;
else
    YScaledef = round(YScaledef);
end
try YtickInterval = ERPTab_plotset_pars{3};catch YtickInterval= YScaledef; end
if isempty(YtickInterval) || numel(YtickInterval)~=1 || any(YtickInterval<0.1)
    YtickInterval= YScaledef;
end

try YtickSpace  =ERPTab_plotset_pars{4};catch YtickSpace=1.5; end
if isempty(YtickSpace) || numel(YtickSpace)~=1 || any(YtickSpace<=0)
    YtickSpace=1.5;
end

try Fillscreen = ERPTab_plotset_pars{5};catch Fillscreen=1; end
if isempty(Fillscreen) || numel(Fillscreen)~=1 || (Fillscreen~=0 && Fillscreen~=1)
    Fillscreen=1;
end

try columNum =ERPTab_plotset_pars{6}; catch columNum=1; end
if isempty(columNum) || numel(columNum)~=1 || any(columNum<=0)
    columNum=1;
end
columNum=1;

try Binchan_Overlay = ERPTab_plotset_pars{8}; catch Binchan_Overlay=0; end
if isempty(Binchan_Overlay) || numel(Binchan_Overlay)~=1 || (Binchan_Overlay~=0 && Binchan_Overlay~=1)
    Binchan_Overlay=0;
end
Binchan_Overlay=0;

if Binchan_Overlay==0
    rowNumdef = numel(ChanArray);
    plotArray = ChanArray;
    [~, labelsdef, ~, ~, ~] = readlocs(ERP.chanlocs(ChanArray));
    PLOTORG = [1 2 3];
    nplot = numel(BinArray);
    LegendName = ERP.bindescr(BinArray);
else
    rowNumdef = numel(BinArray);
    plotArray = BinArray;
    labelsdef =ERP.bindescr(BinArray);
    PLOTORG = [2 1 3];
    nplot = numel(ChanArray);
    [~, chanlabels, ~, ~, ~] = readlocs(ERP.chanlocs(ChanArray));
    LegendName = chanlabels(ChanArray);
end


try rowNum = ERPTab_plotset_pars{9};catch rowNum=rowNumdef; end
rowNum=rowNumdef;

figSize = estudioworkingmemory('egfigsize');
if isempty(figSize)
    figSize = [];
end


GridposArraydef = zeros(rowNum,columNum);
count = 0;
for Numofrow = 1:rowNum
    for Numofcolumn = 1:columNum
        count = count +1;
        if count<= numel(plotArray)
            GridposArraydef(Numofrow,Numofcolumn)=  plotArray(count);
        else
            break;
        end
    end
end



%%----------------------------Measurement tool-----------------------------
geterpvaluesparas = estudioworkingmemory('pop_geterpvalues');

try moption = geterpvaluesparas{7}; catch moption = 'meanbl'; end

try latency = geterpvaluesparas{4};catch latency = []; end

try  blc = geterpvaluesparas{10}; catch  blc = 'none'; end
% check for custom baseline
if isnumeric(blc) && length(blc) == 2
    %custom baseline, pass
elseif ischar(blc)
    vals = str2num(blc); %#ok<ST2NM>
    if isnumeric(vals) && length(vals) == 2
        %custom baseline, pass
    else
        if ~ismember_bc2(blc, {'none','pre','post','all','whole'})
            blc = 'none'; %invalid baseline string, default to none
        end
    end
else
    blc = 'none'; %invalid baseline format, default to none
end

try intfactor = geterpvaluesparas{21}; catch intfactor=1; end

if isempty(intfactor) || numel(intfactor)~=1 || any(intfactor<=0 ) || any(intfactor>10)
    intfactor=1;
end

try Resolution = geterpvaluesparas{9};catch Resolution=3; end
if isempty(Resolution) || numel(Resolution)~=1 || any(Resolution<1) || any(Resolution>6)
    Resolution =3;
end

try Afraction = geterpvaluesparas{15};catch Afraction =  0.5;end
if isempty(Afraction) || numel(Afraction)~=1 || any(Afraction<=0) || any(Afraction>=1)
    Afraction =  0.5;
end

try polpeak = geterpvaluesparas{12};catch polpeak=0; end
if isempty(polpeak) || numel(polpeak)~=1 || (polpeak~=0 && polpeak~=1)
    polpeak=0;
end

try locpeakrep= geterpvaluesparas{14};catch locpeakrep=1;  end
if isempty(locpeakrep) || numel(locpeakrep)~=1 || (locpeakrep~=0 && locpeakrep~=1)
    locpeakrep=0;%%NaN
end

% try fracmearep= geterpvaluesparas{16};catch fracmearep=1;  end
% if isempty(fracmearep) || numel(fracmearep)~=1 || (fracmearep~=0 && fracmearep~=1 && fracmearep~=2)
%     fracmearep=0;
% end
fracmearep=0;%%always NAN for preview: Apr 2024 GH

try PeakOnset = geterpvaluesparas{22};catch PeakOnset=1;  end
if isempty(PeakOnset) || numel(PeakOnset)~=1 || (PeakOnset~=0 && PeakOnset~=1)
    PeakOnset=1;
end
matlab_ver = version('-release');
Matlab_ver = str2double(matlab_ver(1:4));


try sampeak = geterpvaluesparas{14};catch sampeak=1;  end
if isempty(sampeak) ||numel(sampeak)~=1 || any(sampeak<1)
    sampeak=1;
end

if matlabfig==1
%     [EEG, eegcom] = pop_ploterptab(EEG,'ChanArray',ChanArray,'ICArray',ICArray,'Winlength',Winlength,...
%         'AmpScale',AmpScale,'ChanLabel',ChanLabel,'Submean',Submean,'EventOnset',EventOnset,...
%         'StackFlag',StackFlag,'NormFlag',NormFlag,'Startimes',Startimes,'figureName',figureName,'figSize',figSize,'History',History);
else
    OutputViewerparerp{1} = ChanArray;
    OutputViewerparerp{2} = BinArray;
    OutputViewerparerp{3} =timeStart;
    OutputViewerparerp{4} =timEnd;
    OutputViewerparerp{5} =xtickstep;
    OutputViewerparerp{6} =YtickInterval;
    OutputViewerparerp{7} =YtickSpace;
    OutputViewerparerp{8} =Fillscreen;
    OutputViewerparerp{9} = columNum;
    OutputViewerparerp{10} =positive_up;
    OutputViewerparerp{11} =Binchan_Overlay;
    OutputViewerparerp{12} =moption;
    OutputViewerparerp{13} =latency;
    OutputViewerparerp{14} =blc;
    OutputViewerparerp{15} =intfactor;
    OutputViewerparerp{16} =Resolution;
    OutputViewerparerp{17} =Afraction;
    OutputViewerparerp{18} =polpeak;
    OutputViewerparerp{19} = locpeakrep;
    OutputViewerparerp{20} =fracmearep;
    OutputViewerparerp{21} =PeakOnset;
    OutputViewerparerp{22} =Matlab_ver;
    OutputViewerparerp{23} =sampeak;
    OutputViewerparerp{24} =GridposArraydef;

end

end