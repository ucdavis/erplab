% PURPOSE  :	Get the legend and bindata and binerror data for single and mutiple ERPsets
%
% FORMAT   :

% f_geterpdata(ALLERP,ERPsetArray,orgpar);
%
%
% INPUTS   :
%
% ALLERP        - structure array of ERP structures (ERPsets)
%                 To read the ERPset from a list in a text file,
%                 replace ALLERP by the whole filename.

%ERPsetArray  -Index of the selected ERPsets e.g., [1 2 3], the index
%                  should be not larger than the length of ALLERP

%orgpar           -Indicates how to display the selected ERPsets which
%                  contains three elements: first one is Grid; the second
%                  one is Overlay; the last one is Page. For example, [1 2 3]
%                  represents that Channel will be Grid, Bin will be
%                  Overlay, and ERPset will be Page.


% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022

%%%Note: please ensure that the sampling rate is the same across the
%%%selected ERPsets at least. Otherwise, "ERPsets" will be fixed as "Pages"

function [ERPdata,legendName,ERPerrordata,timeRange] = f_geterpdata(ALLERP,ERPsetArray,orgpar,ERPselectIndex)
ERPdata = [];
legendName = [];
ERPerrordata = [];
timeRange = [];
if nargin==0
    beep;
    help f_geterpdata;
    return;
end
if nargin<2 || isempty(ERPsetArray)
    beep;
    disp('Please input the index of the selected ERPsets');
    return;
end
if isempty(ALLERP)
    beep;
    disp('Inputed ALLERP is empty');
    return;
end
[x,y] = find(ERPsetArray>length(ALLERP));
if ~isempty(y)
    beep;
    disp('Please the index of the selected ERPsets should not be larger than the length of ALLERP.');
    return;
end

[x,y] = find(ERPsetArray<=0);
if ~isempty(y)
    beep;
    disp('Please the index of the selected ERPsets should be positive integer.');
    return;
end

if nargin<3
    orgpar = [1 2 3];%% Grid is channel; Overlay is bin; page is ERPset
end

if nargin<4|| (ERPselectIndex>length(ERPsetArray))
  ERPselectIndex =length(ERPsetArray);  
end

%
%%--------------------When only one ERPset is selected.--------------------
if numel(ERPsetArray) ==1
    
    ERPdata = ALLERP(ERPsetArray).bindata;%% ERP data for different bins
    
    ERPerrordata = ALLERP(ERPsetArray).binerror;%% ERP eroor data
    if isempty(ERPerrordata)
        ERPerrordata = nan(size(ERPdata,1),size(ERPdata,2),size(ERPdata,3));
    end
    timeRange = ALLERP(ERPsetArray).times;
    switch orgpar(2)%%Get the legend name according to overlay: overlay is 1 (channel), 2(bin), and 3(ERPset)
        case 1
            legendName = cell(ALLERP(ERPsetArray).nchan,1);
            chanlabels = ALLERP(ERPsetArray).chanlocs;
            for Numofchan = 1:ALLERP(ERPsetArray).nchan
                legendName(Numofchan,1) = {char(chanlabels(Numofchan).labels)};
            end
        case 2
            legendName = cell(ALLERP(ERPsetArray).nbin,1);
            bindescrp = ALLERP(ERPsetArray).bindescr;
            for Numofbin = 1:ALLERP(ERPsetArray).nbin
                legendName(Numofbin,1) = {char(bindescrp{Numofbin})};
            end
            
        case 3
            legendName = cell(1,1);
            legendName(1,1) = {ALLERP(ERPsetArray).erpname};
        otherwise
            legendName = cell(ALLERP(ERPsetArray).nbin,1);
            bindescrp = ALLERP(ERPsetArray).bindescr;
            for Numofbin = 1:ALLERP(ERPsetArray).nbin
                legendName(Numofbin,1) = {char(bindescrp{Numofbin})};
            end
    end
    return;
end

%
%%--------------------When mutiple ERPsets are selected.--------------------

%%Check the number of bins and channels and samples across ERPsets
chanNum_mp = [];%%Number of channels for multiple subjects
BinNum_mp = [];%%Number of bins for multiple subjects.
SampNum_mp = [];%%Number of samples
StartTNum_mp = [];%%Start time of epoch
StopTNum_mp = [];%%Stop time of epoch
SrateNum_mp = [];%%Sampling rate

for Numofselectederp = 1:numel(ERPsetArray)
    chanNum_mp(Numofselectederp,1)   =  ALLERP(ERPsetArray(Numofselectederp)).nchan;
    BinNum_mp(Numofselectederp,1)   =  ALLERP(ERPsetArray(Numofselectederp)).nbin;
    SampNum_mp(Numofselectederp,1)   =  ALLERP(ERPsetArray(Numofselectederp)).pnts;
    StartTNum_mp(Numofselectederp,1)   =  ALLERP(ERPsetArray(Numofselectederp)).times(1);
    StopTNum_mp(Numofselectederp,1)   =  ALLERP(ERPsetArray(Numofselectederp)).times(end);
    SrateNum_mp(Numofselectederp,1)   =  ALLERP(ERPsetArray(Numofselectederp)).srate;
end

if numel(unique(SrateNum_mp))>1 %%Check if the sampling rate is the same across the selected ERPsets, otherwise, the "ERPsets" will be fixed as "Pages".
%     msgboxText = ['EStudio says: Sampling rate varies across the selected ERPsets, we therefore set "ERPsets" to be "Pages".'];
%     title = 'EStudio: f_geterpdata().';
%     errorfound(msgboxText, title);
    if orgpar(1)==1 && (orgpar(2) ==2 || orgpar(2) ==3)
        orgpar = [1 2 3];
    elseif orgpar(1)==2 && (orgpar(2) ==1 || orgpar(2) ==3)
        orgpar = [2 1 3];
    elseif orgpar(1)==3 && (orgpar(2) ==1 || orgpar(2) ==2)
        orgpar = [setdiff([1 2 3],[orgpar(2) 3]), orgpar(2), 3];
    end
end

%%-------check if the numbers of channels and bins and samples are the same across the selected ERPsets--------
if numel(unique(chanNum_mp))==1 && numel(unique(SampNum_mp))==1 && numel(unique(BinNum_mp))==1 && numel(unique(StartTNum_mp))==1 && numel(unique(StopTNum_mp))==1 && numel(unique(SrateNum_mp))==1 %%if the number of channels is the same
    ERPdata = nan(max(chanNum_mp),max(SampNum_mp),max(BinNum_mp),numel(ERPsetArray));
    ERPerrordata = nan(max(chanNum_mp),max(SampNum_mp),max(BinNum_mp),numel(ERPsetArray));%% ERP eroor data
    %%Get the data acorss ERPsets
    for Numofselectederp = 1:numel(ERPsetArray)
        ERPdata(:,:,:,Numofselectederp) = ALLERP(ERPsetArray(Numofselectederp)).bindata;
        errordata =  ALLERP(ERPsetArray(Numofselectederp)).binerror;
        if ~isempty(errordata)
            ERPerrordata(:,:,:,Numofselectederp)  =errordata;
        end
    end
    timeRange = ALLERP(ERPsetArray(Numofselectederp)).times;
    
else%%If any of bins, channels, samples varies across the selected ERPsets.
    
    %%There are two possible situations: one is that the sampling rate is the same
    %%across the selected ERPsets and the other one is sampling rate varies
    
    %
    %%First situation:the sampling rate is the same across the selected ERPsets
    if numel(unique(SrateNum_mp))==1
        Min_start = min(StartTNum_mp(:));
        Max_end = max(StopTNum_mp(:));%%Maximum
        
        Times = [Min_start:1000/SrateNum_mp(1):Max_end];
        timeRange = Times;
        ERPdata = nan(max(chanNum_mp),numel(Times),max(BinNum_mp),numel(ERPsetArray));
        ERPerrordata = nan(max(chanNum_mp),numel(Times),max(BinNum_mp),numel(ERPsetArray));
        
        for Numofselectederp = 1:numel(ERPsetArray)
            ERP_sg =  ALLERP(ERPsetArray(Numofselectederp));
            EpochStart = ERP_sg.times(1);
            EpochEnd = ERP_sg.times(end);
            [xxx, latsamp, latdiffms] = closest(Times, [EpochStart,EpochEnd]);
            ERPdata(1:ERP_sg.nchan,latsamp(1):latsamp(2),1:ERP_sg.nbin,Numofselectederp) = ERP_sg.bindata;
            errordata =  ERP_sg.binerror;
            if ~isempty(errordata)
                ERPerrordata(1:ERP_sg.nchan,latsamp(1):latsamp(2),1:ERP_sg.nbin,Numofselectederp)  =errordata;
            end
            
        end
        
        %%Second situation is that the sampling rate varies across the selected ERPsets.
    else
        ERPdata = nan(max(chanNum_mp),SampNum_mp(ERPselectIndex),max(BinNum_mp),numel(ERPsetArray));
        ERPerrordata = nan(max(chanNum_mp),SampNum_mp(ERPselectIndex),max(BinNum_mp),numel(ERPsetArray));
        
            ERP_sg =  ALLERP(ERPsetArray(ERPselectIndex));%%The information for individual subject
            ERPdata(1:chanNum_mp(ERPselectIndex),:,1:BinNum_mp(ERPselectIndex),ERPselectIndex) = ERP_sg.bindata;
            errordata =  ERP_sg.binerror;
            if ~isempty(errordata)%%Get the error data
                ERPerrordata(1:chanNum_mp(ERPselectIndex),:,1:BinNum_mp(ERPselectIndex),ERPselectIndex)  =errordata;
            end
    end
end

%%Get the legend name according to overlay: overlay is 1 (channel), 2(bin), and 3(ERPset)
switch orgpar(2)
    case 1
        [chanStr,binStr,~] = f_geterpschanbin(ALLERP,ERPsetArray);
        legendName = chanStr;
    case 2
        [chanStr,binStr,~] = f_geterpschanbin(ALLERP,ERPsetArray);
        legendName = binStr;
    case 3
        legendName = cell(numel(ERPsetArray),1);
        for Numoferp = 1:numel(ERPsetArray)
            legendName(Numoferp,1) = {ALLERP(ERPsetArray(Numoferp)).erpname};
        end
    otherwise
        [chanStr,binStr,~] = f_geterpschanbin(ALLERP,ERPsetArray);
        legendName = chanStr;
end

end