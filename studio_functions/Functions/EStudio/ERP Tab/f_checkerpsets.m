% PURPOSE :  Checking if the number of bins/channels and data type for different ERPsets
%
% FORMAT :
%
% chkerp = f_checkerpsets(ALLERP,indexerp)

% INPUTS :
%
% ALLERP    - structure array of ERP structures (ERPsets)
%             To read the ERPset from a list in a text file,
%             replace ALLERP by the whole filename.
%
% indexerp  - The labels of the selected ERPsets that are to be checked.
%             Any label in indexerp should be no more than the length of ALLERPsets.
%             If indexerp is empty, all ERPsets will be checked
%
%
%OUTPUT :
%
%chkerp      - If either the number of bins/channels or data type varies
%              across  the selected ERPsets, chkerp will be larger than 0.
%
%
%Example :
%
%chkerp = f_checkerpsets(ALLERP,[1 3 5]);

%
% ***This function is part of ERP Studio Toolbox***
% Author: Guanghui ZHANG & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA, USA
% Feb. 2022



function chkerp = f_checkerpsets(ALLERP,indexerp)

chkerp = [0 0 0 0 0 0 0]; % no problem

if nargin <1
    help f_checkerpsets
    return;
end

if nargin ==1
    if ~isstruct(ALLERP)
        msgboxText =  'ALLERP is empty';
        title = 'EStudio: f_checkerpsets';
        errorfound(msgboxText, title);
    end
end

if nargin < 2
    indexerp = [1:length(ALLERP)];
else
    if isempty(indexerp)
        %         msgboxText =  'The index of the checked ERPsets is not numeric';
        %         title = 'EStudio: f_checkerpsets';
        %         errorfound(msgboxText, title); % not numeric
        return;
    end
end

if length(indexerp)==1
    %     beep;
    chkerp = [0 0 0 0 0 0 0];
    %     msgboxText =  'Only one ERPset was checked!';
    %     disp(msgboxText); % not numeric
    return;
    
end


nerp = length(ALLERP);

if max(indexerp)>nerp
    %     msgboxText =  ['ERPset indexing out of range!'...
    %         'You only have ' num2str(nerp) ' ERPsets loaded on your ERPset Menu.'];
    %     %     chkerp  = 2; % indexing out of range
    %     title = 'EStudio: f_checkerpsets';
    %     errorfound(msgboxText, title);
    return
end



if min(indexerp)<1
    msgboxText =  ['Invalid ERPset indexing!'...
        'You may use any integer value between 1 and ',32, num2str(nerp)];
    %     chkerp  = 3; % indexing lesser than 1
    title = 'EStudio: f_checkerpsets';
    errorfound(msgboxText, title);
    return
end

nerp2 = length(indexerp);%% the length of the checked ERPsets



%%-------get the number of bins/channels/datatype for each subject---------
for k=1:nerp2
    try
        kbin(k)   = ALLERP(indexerp(k)).nbin;
        kchan(k)  = ALLERP(indexerp(k)).nchan;
        kdtype{k} = ALLERP(indexerp(k)).datatype;
        kdlength(k) = ALLERP(indexerp(k)).pnts;
        kstartepoch(k) = ALLERP(indexerp(k)).times(1);
        kendepoch(k) = ALLERP(indexerp(k)).times(end);
        ksrate(k) = ALLERP(indexerp(k)).srate;
    catch
        msgboxText = ['ERPset',32,num2str(k),32,'has a invalid number of bins/channels/samples or different data type.'];
        %         chkerp  = 4; % invalid number of bins/channel
        disp(msgboxText);
        break;
    end
end

% if chkerp==4
%     return
% end

%%--------------------------check the number of bins-----------------------
bintest   = length(unique(kbin));
if bintest>1
    fprintf('Detail:\n')
    fprintf('-------\n')
    
    for j=1:nerp2
        fprintf('Erpset #%g = %g bins\n', indexerp(j),ALLERP(indexerp(j)).nbin)
    end
    msgboxText =  ['Number of bins across ERPsets is different!'...
        'See detail at command window'];
    disp(msgboxText);
    chkerp(1)  = 1; % Number of bins across ERPsets is different!
    %     return
    % else
    %     nbin = unique_bc2(kbin);
end


%%---------------------------check the number of channels------------------
chantest  = length(unique(kchan));
if chantest>1
    fprintf('Detail:\n')
    fprintf('-------\n')
    
    for j=1:nerp2
        fprintf('Erpset #%g = %g channnels\n', indexerp(j),ALLERP(indexerp(j)).nchan)
    end
    msgboxText =  ['Number of channels across ERPsets is different!'...
        'See detail at command window.'];
    disp(msgboxText);
    chkerp(2)  = 2; % Number of channels across ERPsets is different
    %     return
else
    nchan = unique_bc2(kchan);
end


%%-------------------check the type of different ERPsets-------------------
dtypetest = length(unique(kdtype));

if dtypetest>1
    fprintf('Detail:\n')
    fprintf('-------\n')
    
    for j=1:nerp2
        fprintf('Erpset #%g has data type ''%s''\n', indexerp(j),ALLERP(indexerp(j)).datatype)
    end
    beep;
    msgboxText =  ['Type of data across ERPsets is different!'...
        'See detail at command window.'];
    disp(msgboxText);
    chkerp(3)  = 3; % data type across ERPsets is different
    %     return
end


%-----------------------check the length of ERPsets----------------------
dlengthtest = length(unique(kdlength));
if dlengthtest>1
    fprintf('Detail:\n')
    fprintf('-------\n')
    
    for j=1:nerp2
        fprintf('Erpset #%g = %g time samples\n', indexerp(j),ALLERP(indexerp(j)).pnts)
    end
    msgboxText =  ['Number of samples across ERPsets is different!'...
        'See detail at command window.'];
    disp(msgboxText);
    chkerp(4)  = 4; % data type across ERPsets is different
    %     return
end


%-----------------------check the start time of epoch for the selected ERPsets----------------------
dlengthtest = length(unique(kstartepoch));
if dlengthtest>1
    fprintf('Detail:\n')
    fprintf('-------\n')
    
    for j=1:nerp2
        fprintf('Erpset #%g = %g start time of epoch\n', indexerp(j),kstartepoch(j))
    end
    msgboxText =  ['Start time of epoch across ERPsets is different!'...
        'See detail at command window.'];
    disp(msgboxText);
    chkerp(5)  = 5; % data type across ERPsets is different
    %     return
end


%-----------------------check the start time of epoch for the selected ERPsets----------------------
dlengthtest = length(unique(kendepoch));
if dlengthtest>1
    fprintf('Detail:\n')
    fprintf('-------\n')
    
    for j=1:nerp2
        fprintf('Erpset #%g = %g end time of epoch\n', indexerp(j),kendepoch(j))
    end
    msgboxText =  ['End time of epoch across ERPsets is different!'...
        'See detail at command window.'];
    disp(msgboxText);
    chkerp(6)  = 6; % data type across ERPsets is different
    %     return
end



%-----------------------check sampling rate the selected ERPsets----------------------
dlengthtest = length(unique(ksrate));
if dlengthtest>1
    fprintf('Detail:\n')
    fprintf('-------\n')
    
    for j=1:nerp2
        fprintf('Erpset #%g = %g end time of epoch\n', indexerp(j),ksrate(j))
    end
    msgboxText =  ['Sampling rate across ERPsets is different!'...
        'See detail at command window.'];
    disp(msgboxText);
    chkerp(7)  = 7; % data type across ERPsets is different
    %     return
end

return;