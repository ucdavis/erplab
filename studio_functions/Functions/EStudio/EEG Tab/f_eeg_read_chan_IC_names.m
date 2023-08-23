


function  [AllStr,chanName,ICName] = f_eeg_read_chan_IC_names(chanlocs,ChanArray,ICArray)
chanName = '';
ICName = '';
AllStr = '';
if isempty(chanlocs) && isempty(ChanArray)
    return;
end

if ~isempty(chanlocs)
    if isempty(ChanArray) || min(ChanArray(:))>length(chanlocs) || max(ChanArray(:))>length(chanlocs)
        ChanArray = [1:length(chanlocs)];
    end
    chanlocs = chanlocs(ChanArray);
    tmplocs = readlocs(chanlocs);
    chanName = { tmplocs.labels };
    chanName = strrep(chanName,'_','\_');
    %     chanName = strvcat(chanName);
elseif isempty(chanlocs) && ~isempty(ChanArray)
    count = 0;
    for ii = ChanArray
        count = count +1;
        chanName{count,1} = ['chan',32,num2str(ii)];
    end
    chanName = char(chanName);
end
AllStr = chanName;
%%IC names
if isempty(ICArray)
    AllStr = char(AllStr);
    return;
end
count = 0;
for ii = ICArray
    count = count +1;
    ICName{count,1} = ['IC',32,num2str(ii)];
end

if isempty(AllStr)
    AllStr = char(ICName);
else
    
    count = 0;
    for ii = ICArray
        count = count +1;
        AllStr{length(AllStr)+1} = ['IC',32,num2str(ii)];
    end
    
end
AllStr = char(AllStr);
ICName = char(ICName);
end