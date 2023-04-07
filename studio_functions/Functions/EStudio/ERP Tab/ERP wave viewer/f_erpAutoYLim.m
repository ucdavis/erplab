
% PURPOSE: subroutine for ploterpGUI.m
%          identifies minimum and maximum values of ERP amplitudes for Y scaling for the selected single ERP or multi-ERPsets.
%
% FORMAT
%
%  [yylim, serror] = erpAutoYLim(ALLERP,ERPsetArray, binArray, chanArray, xxlim)
%

% INPUTS
%
% ALLERP      - ALLERPset
% ERPsetArray  - indices of the seleted ERPsets
% binArray    - indices of bins from where to get the amplitude values
% chanArray   - indices of channels from where to get the amplitude values
% xxlim       - current scale for time ([min max] in ms)
% orgpar      - plot orginization including three elements: [Grid,Overlay,Pages]; Each element is equal to any of 1,2, and 3.
%               "1" is "Channel", "2" is "Bin", and "3" is "ERPset".
%
% OUTPUT
%
% yylim       - range for Y scale
% serror      - error flag. 0 means no errors.
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022




function [yylim_out, serror] = f_erpAutoYLim(ALLERP, ERPsetArray,orgpar,binArray, chanArray,CurrentERPIndex, xxlim,blcorrdata)

yylim_out = [];

serror = 0;
if nargin<2
    beep;
    error('f_erpAutoYLim needs 2 input arguments at least.');
    return;
end
if isempty(ALLERP)
    beep;
    error('f_erpAutoYLim() error: ALLERP is empty.');
    return;
end


if isempty(ERPsetArray)
    beep;
    error('f_erpAutoYLim() error: Indices of the seleted ERPsets are empty.');
    return;
end



if max(ERPsetArray) >length(ALLERP)
    beep;
    error('f_erpAutoYLim() error: One of indices of the seleted ERPsets is larger than the length of ALLERP.');
    return;
end

if min(ERPsetArray) <=0
    beep;
    error('f_erpAutoYLim() error: Indices of the seleted ERPsets should be positive values.');
    return;
end

if nargin<8
    blcorrdata = 'no';
end


if nargin<7
    xxlim = [];
end
if nargin< 6 || (CurrentERPIndex > length(ERPsetArray)) || (CurrentERPIndex <=0)
    CurrentERPIndex =   length(ERPsetArray);
end
if nargin<5
    chanArray = [];
end

if nargin<4
    binArray = [];
end

if nargin<3
    orgpar = [1 2 3];%%It means that Channel will be Grid, Bin will be Overlay, and ERPset will be pages
end
%%Generate the indices of tiem points

for Numofselectederp = 1:numel(ERPsetArray)
    SampNum_mp(Numofselectederp,1)   =  ALLERP(ERPsetArray(Numofselectederp)).pnts;
    StartTNum_mp(Numofselectederp,1)   =  ALLERP(ERPsetArray(Numofselectederp)).times(1);
    StopTNum_mp(Numofselectederp,1)   =  ALLERP(ERPsetArray(Numofselectederp)).times(end);
    SrateNum_mp(Numofselectederp,1)   =  ALLERP(ERPsetArray(Numofselectederp)).srate;
end



if numel(ERPsetArray) ==1
    TimeIndex = ALLERP(ERPsetArray).times;
else
    if numel(unique(SrateNum_mp))>1 %%Check if the sampling rate is the same across the selected ERPsets, otherwise, the "ERPsets" will be fixed as "Pages".
        %         msgboxText = ['EStudio says: Sampling rate varies across the selected ERPsets, we therefore set "ERPsets" to be "Pages".'];
        %         title = 'EStudio: f_geterpdata().';
        %         errorfound(msgboxText, title);
        if orgpar(1)==1 && (orgpar(2) ==2 || orgpar(2) ==3)
            orgpar = [1 2 3];
        elseif orgpar(1)==2 && (orgpar(2) ==1 || orgpar(2) ==3)
            orgpar = [2 1 3];
        elseif orgpar(1)==3 && (orgpar(2) ==1 || orgpar(2) ==2)
            orgpar = [setdiff([1 2 3],[orgpar(2) 3]), orgpar(2), 3];
        end
        TimeIndex = [];
    else%%if the sampling rate is the same across the selected ERPsets.
        
        if numel(unique(SampNum_mp))==1 && numel(unique(StartTNum_mp))==1 && numel(unique(StopTNum_mp))==1 && numel(unique(SrateNum_mp))==1 %%if the number of channels is the same
            TimeIndex = [];
        else
            Min_start = min(StartTNum_mp(:));%%Minimum
            Max_end = max(StopTNum_mp(:));%%Maximum
            TimeIndex = [Min_start:1000/SrateNum_mp(1):Max_end];
        end
        
    end
    
end

[ERPpdata,legendpName,ERPperrordata] = f_geterpdata(ALLERP,ERPsetArray,orgpar,CurrentERPIndex);

%%Get the ylim
try
    if orgpar(3) ==3%%if ERPset is assigned to be "Pages"
        for Numoferpset = 1:numel(ERPsetArray)
            ERPIN = ALLERP(ERPsetArray(Numoferpset));
            if isempty(binArray) || max(binArray)> ERPIN.nbin || min(binArray)<= 0
                binArrayin =   1:ERPIN.nbin;
            else
                binArrayin = binArray;
            end
            
            if isempty(chanArray) || max(chanArray)> ERPIN.nchan || min(chanArray)<= 0
                chanArrayin =   1:ERPIN.nchan;
            else
                chanArrayin = chanArray;
            end
            
            if isempty(xxlim) || min(xxlim) < ERPIN.times(1) || max(xxlim) > ERPIN.times(end)
                xxlimin = [ ERPIN.times(1), ERPIN.times(end)];
            else
                xxlimin = xxlim;
            end
            [yylim, serror] = erpAutoYLim(ERPIN, binArrayin, chanArrayin, xxlimin,blcorrdata);
            yylim_out(Numoferpset,:) = yylim;
        end
        
    elseif orgpar(3) ==1%%if Channel is assigned to be "Pages"
        yylim_outchan = [];
        ERPIN = ALLERP(ERPsetArray(1));%%
        for Numofchannel  = 1:size(ERPpdata,1)
            Databin = squeeze(ERPpdata(Numofchannel,:,:,:));%%samples by bins by ERPsets
            Databin = permute(Databin,[3 1 2]);%%ERPsets by samples by bins
            ERPIN.bindata = Databin;
            ERPIN.nchan = size(Databin,1);
            ERPIN.nbin = size(Databin,3);
            if ~isempty(TimeIndex)
                ERPIN.times = TimeIndex;
                ERPIN.xmin  = TimeIndex(1)/1000;
                ERPIN.xmax = TimeIndex(end)/1000;
            end
            
            if isempty(binArray) || max(binArray)> ERPIN.nbin || min(binArray)<= 0
                binArrayin =   1:ERPIN.nbin;
            else
                binArrayin = binArray;
            end
            chanArrayin = 1:ERPIN.nchan;
            
            [yylim, serror] = erpAutoYLim(ERPIN, binArrayin, chanArrayin);
            yylim_outchan(Numofchannel,:) = yylim;
        end
        
        if max(chanArray)> size(ERPpdata,1) || min(chanArray)<= 0
            yylim_out = yylim_outchan;
        else
            yylim_out = yylim_outchan(chanArray,:);
        end
        
    elseif orgpar(3) ==2%%if bin is assigned to be "Pages"
        ERPIN = ALLERP(ERPsetArray(1));%%
        for Numofbin  = 1:size(ERPpdata,3)
            Databin = squeeze(ERPpdata(:,:,Numofbin,:));%%samples by bins by ERPsets
            %             Databin = permute(Databin,[3 1 2]);%%ERPsets by samples by bins
            ERPIN.bindata = Databin;
            ERPIN.nchan = size(Databin,1);
            ERPIN.nbin = size(Databin,3);
            if ~isempty(TimeIndex)
                ERPIN.times = TimeIndex;
                ERPIN.xmin  = TimeIndex(1)/1000;
                ERPIN.xmax = TimeIndex(end)/1000;
            end
            
            if isempty(chanArray) || max(chanArray)> ERPIN.nchan || min(chanArray)<= 0
                chanArrayin =   1:ERPIN.nchan;
            else
                chanArrayin = chanArray;
            end
            binArrayin = 1:ERPIN.nbin;
            
            
            [yylim, serror] = erpAutoYLim(ERPIN, binArrayin, chanArrayin);
            yylim_outbin(Numofbin,:) = yylim;
        end
        
        if max(binArray)> size(ERPpdata,3) || min(binArray)<= 0
            yylim_out = yylim_outbin;
        else
            yylim_out = yylim_outbin(binArray,:);
        end
        
    else
        beep;
        error('f_erpAutoYLim() error: Please check if all of the parameters is correct.');
        return;
    end
    
    
catch
    
    beep;
    error('f_erpAutoYLim() error: Please check if all of the parameters is correct.');
    return;
end