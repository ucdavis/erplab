function EEG = bepoch2EL(EEG)

if isempty(EEG)
        msgboxText{1} =  'bepoch2EL() error: cannot work with an empty dataset!';
        tittle = 'ERPLAB: No data';
        errorfound(msgboxText, tittle)
        return
end

if isempty(EEG.data)
        msgboxText{1} =  'bepoch2EL() error: cannot work with an empty dataset!';
        tittle = 'ERPLAB: No data';
        errorfound(msgboxText, tittle)
        return
end

if isfield(EEG, 'EVENTLIST')
        if isfield(EEG.EVENTLIST, 'eventinfo')
                if isempty(EEG.EVENTLIST.eventinfo)
                        msgboxText{1} =  '      EVENTLIST.eventinfo structure is empty!';
                        msgboxText{2} =  'Use Create EVENTLIST before BINLISTER';
                        tittle = 'ERPLAB: Error';
                        errorfound(msgboxText, tittle)
                        return
                end
        else
                msgboxText{1} =  '      EVENTLIST.eventinfo structure was not found!';
                msgboxText{2} =  'Use Create EVENTLIST before BINLISTER';
                tittle = 'ERPLAB: Error';
                errorfound(msgboxText, tittle)
                return
        end
        
else
        msgboxText{1} =  '      EVENTLIST structure was not found!';
        msgboxText{2} =  'Use Create EVENTLIST before BINLISTER';
        tittle = 'ERPLAB: Error';
        errorfound(msgboxText, tittle)
        return
end

if isfield(EEG, 'epoch')
        if isempty(EEG.epoch)
                msgboxText{1} =  '     EEG.epoch structure is empty!';
                msgboxText{2} =  'Use must bin-epoch your data first.';
                tittle = 'ERPLAB: Error';
                errorfound(msgboxText, tittle)
                return
        end
else
        msgboxText{1} =  '     EEG.epoch structure was not found!';
        msgboxText{2} =  'Something is going wrong. Please, check your EEG struct';
        tittle = 'ERPLAB: Error';
        errorfound(msgboxText, tittle)
        return
end

nbepoch = length(EEG.epoch);

for i=1:nbepoch
        
        if length(EEG.epoch(i).eventlatency) == 1
                
                bines = EEG.epoch(i).eventbini;
                eventitem = EEG.epoch(i).eventitem;
                
                if iscell(bines)
                        bines = cell2mat(bines);
                end
                if iscell(eventitem)
                        eventitem = cell2mat(eventitem);
                end
                
                if sum(bines)>0
                        EEG.EVENTLIST.eventinfo(eventitem).bepoch = i;
                else
                        EEG.EVENTLIST.eventinfo(eventitem).bepoch = 0; % no bepoch for this item
                end
                
        elseif length(EEG.epoch(i).eventlatency) > 1
                
                indxtimelock = find(cell2mat(EEG.epoch(i).eventlatency) == 0,1,'first'); % catch zero-time locked type,
                bines = EEG.epoch(i).eventbini{indxtimelock};
                eventitem = EEG.epoch(i).eventitem{indxtimelock};
                
                if iscell(eventitem)
                        eventitem = cell2mat(eventitem);
                end
                
                if sum(bines)>0
                        EEG.EVENTLIST.eventinfo(eventitem).bepoch = i;
                else
                        EEG.EVENTLIST.eventinfo(eventitem).bepoch = 0; % no bepoch for this item
                end
        end
end