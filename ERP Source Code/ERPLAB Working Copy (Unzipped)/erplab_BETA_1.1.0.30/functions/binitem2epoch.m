function iepoch = binitem2epoch(EEG,item)

iepoch = [];

if nargin<2
        return
end
if item<1
        return
end
if isempty(EEG)
        return
end
if isempty(EEG.epoch)
        return
end
if ~isfield(EEG, 'EVENTLIST')
        return
end
if isempty(EEG.EVENTLIST)
        return
end

nepoch = EEG.trials;

if nepoch~=length(EEG.epoch)
        error('ERPLAB says: EEG.trials & number of epochs (EEG.epoch) are not equal.')
end

for i=1:nepoch
        itemy = EEG.epoch(i).eventitem;
        if iscell(itemy)
                itemy = cell2mat(itemy);
        end
        if ~isempty(itemy)
                [tf loc]  = ismember(item, itemy);
                if tf
                        binstored = EEG.epoch(i).eventbini{loc};
                        if sum(binstored)>0
                                iepoch = [iepoch i];
                        end
                end
        end
end