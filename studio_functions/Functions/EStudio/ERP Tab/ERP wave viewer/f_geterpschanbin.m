% PURPOSE  :	Get the name of channels and bins for single and mutiple ERPsets
%
% FORMAT   :

% f_geterpschanbin(ALLERP,SelectedERPIndex);
%
%
% INPUTS   :
%
% ALLERP        - structure array of ERP structures (ERPsets)
%                 To read the ERPset from a list in a text file,
%                 replace ALLERP by the whole filename.
%SelectedERPIndex  -Index of the selected ERPsets e.g., [1 2 3], the index
%                  should be not larger than the length of ALLERP




% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022



function [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERP,SelectedERPIndex)
diff_mark = [0 0];
chanStr = [];
binStr = [];
if nargin==0
    beep;
    help f_geterpschanbin;
    return;
end


if nargin<2 || isempty(SelectedERPIndex)
    beep;
    disp('Please input the index of the selected ERPsets');
    return;
end

if isempty(ALLERP)
    beep;
    disp('Inputed ALLERP is empty');
    return;
    
end

[x,y] = find(SelectedERPIndex>length(ALLERP));
if ~isempty(y)
    beep;
    disp('Please the index of the selected ERPsets should not be larger than the length of ALLERP.');
    
    return;
end

[x,y] = find(SelectedERPIndex<=0);
if ~isempty(y)
    beep;
    disp('Please the index of the selected ERPsets should be positive integer.');
    return;
end

%
%%--------------------When only one ERPset is selected.--------------------
if numel(SelectedERPIndex) ==1
    ERP = ALLERP(SelectedERPIndex);
    
    %%--------Get the names of bins-----------
    BinNum = ERP.nbin;
    BinName = ERP.bindescr;
    binStr = cell(BinNum,1);
    for i = 1:BinNum
        try
            binStr(i) = {char(BinName{i})};
        catch
            binStr(i) = {['Bin',num2str(i)]};
        end
    end
    
    %%--------Get the names of chans-----------
    ChanNum = ERP.nchan;
    Chanlist = ERP.chanlocs;
    chanStr = cell(ChanNum,1);
    for Numofchan = 1:length(Chanlist)
        try
            chanStr(Numofchan) = {char(Chanlist(Numofchan).labels)};
        catch
            chanStr(Numofchan) = {['Chan',num2str(Numofchan)]};
        end
    end
    return;
end


%
%%------------------When multiple ERPsets are selected-------------------

chanNum_mp = [];%%Number of channels for multiple subjects
BinNum_mp = [];%%Number of bins for multiple subjects.


for Numofselectederp = 1:numel(SelectedERPIndex)
    chanNum_mp(Numofselectederp,1)   =  ALLERP(SelectedERPIndex(Numofselectederp)).nchan;
    BinNum_mp(Numofselectederp,1)   =  ALLERP(SelectedERPIndex(Numofselectederp)).nbin;
end



%%Getting the names of bins and chans
%%for the first selected ERPsets.
ERP = ALLERP(SelectedERPIndex(1));

%%-------check if the number of channels is the same across the selected ERPsets--------
if numel(unique(chanNum_mp))==1%%if the number of channels is the same
    ChanNum = ERP.nchan;
    Chanlist = ERP.chanlocs;
    chanStr = cell(ChanNum,1);
    for Numofchan = 1:length(Chanlist)
        chanStr(Numofchan) = {char(Chanlist(Numofchan).labels)};
    end
    
elseif numel(unique(chanNum_mp))>1%%varies across the selected ERPsets
    [x_chan,y_chan] = find(chanNum_mp==max(chanNum_mp(:)));%% find the position of max. value
    
    ERP = ALLERP(SelectedERPIndex(x_chan));
    
    ChanNum = ERP.nchan;
    Chanlist = ERP.chanlocs;
    chanStr_max = cell(ChanNum,1);
    for Numofchan = 1:length(Chanlist)
        try
            chanStr_max(Numofchan) = {Chanlist(Numofchan).labels};
        catch
            chanStr_max(Numofchan) = {['Chan',num2str(Numofchan)]};
        end
    end
    
    SelectedERPIndex_chan_lf =SelectedERPIndex(setdiff(1:numel(SelectedERPIndex),x_chan));
    
    for Numoferpleft = 1:numel(SelectedERPIndex_chan_lf)
        ERP = ALLERP(SelectedERPIndex_chan_lf(Numoferpleft));
        ChanNum1 = ERP.nchan;
        
        for Numofchan = 1:ChanNum1
            if  ~strcmpi(chanStr_max(Numofchan),ERP.chanlocs(Numofchan).labels)
                chanStr_checkc = char(chanStr_max(Numofchan));
                if ~strcmpi(chanStr_checkc(1),'*')
                    chanStr_max(Numofchan) = {char(strcat('**',chanStr_max(Numofchan)))};
                end
            end
        end
        for Numofchan = ChanNum1+1:length(chanStr_max)
            chanStr_checkc = char(chanStr_max(Numofchan));
            if ~strcmpi(chanStr_checkc(1),'*')
                chanStr_max(Numofchan) = {char(strcat('**',chanStr_max(Numofchan)))};
            end
        end
        clear ERP;
    end
    diff_mark(1) = 1;
    
    chanStr = cell(length(chanStr_max),1);
    for Numofchan = 1:length(chanStr_max)
        chanStr(Numofchan) = {char(chanStr_max(Numofchan))};
    end
    
end

%
%%-------check if the number of bins is the same across the selcted ERPsets--------
ERP = ALLERP(SelectedERPIndex(1));
if numel(unique(BinNum_mp))==1%%if the number of bins is the same
    BinNum = ERP.nbin;
    BinName = ERP.bindescr;
    binStr = cell(BinNum,1);
    for Numofbin = 1:BinNum
        try
            binStr(Numofbin) = {char(BinName{Numofbin})};
        catch
            binStr(Numofbin) = {['Bin',num2str(Numofbin)]};
        end
    end
    
elseif numel(unique(BinNum_mp))>1%%varies across the selected ERPsets
    [x_bin,y_bin] = find(BinNum_mp==max(BinNum_mp));%% find the position of max. value
    
    ERP = ALLERP(SelectedERPIndex(x_bin));
    
    BinNum = ERP.nbin;
    BinName = ERP.bindescr;
    
    
    binStr_max = cell(BinNum,1);
    for Numofbin = 1:BinNum
        try
            binStr_max(Numofbin) = {char(BinName{Numofbin})};
        catch
            binStr_max(Numofbin) = {['Bin',num2str(Numofbin)]};
        end
    end
    
    
    SelectedERPIndex_bin_lf =SelectedERPIndex(setdiff(1:numel(SelectedERPIndex),x_bin));
    for Numoferpleft = 1:numel(SelectedERPIndex_bin_lf)
        ERP = ALLERP(SelectedERPIndex_bin_lf(Numoferpleft));
        BinNum1 = ERP.nbin;
        for Numofbin = 1:BinNum1
            if  ~strcmpi(binStr_max(Numofbin),ERP.bindescr{Numofbin})
                binStr_checkc = char(binStr_max(Numofbin));
                if ~strcmpi(binStr_checkc(1),'*')%%Check if the bins which vary across selected ERPsets have been marked.
                    binStr_max(Numofbin) = {char(strcat('**',binStr_max(Numofbin)))};
                end
            end
        end
        
        for Numofbin = BinNum1+1:length(binStr_max)
            binStr_checkc = char(binStr_max(Numofbin));
            if ~strcmpi(binStr_checkc(1),'*')
                binStr_max(Numofbin) = {char(strcat('**',binStr_max(Numofbin)))};
            end
        end
        clear ERP;
    end
    diff_mark(2) = 1;
    binStr = cell(length(binStr_max),1);
    for Numofbin = 1:length(binStr_max)
        binStr(Numofbin) = {char(binStr_max(Numofbin))};
    end
end

end

