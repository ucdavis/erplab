function EEG = updatebdfstruct(EEG)

%
% Tests RT info
%
if ~isfield(EEG.EVENTLIST.bdf, 'rt')
      return
else
      valid_rt = nnz(~cellfun(@isempty,{EEG.EVENTLIST.bdf.rt}));
      
      if valid_rt==0
            return
      end
end

nbin = EEG.EVENTLIST.nbin;

for i=1:nbin
      
      col = size(EEG.EVENTLIST.bdf(i).rtitem,2);
      
      for j=1:col
            indxitem = EEG.EVENTLIST.bdf(i).rtitem(:,j);
            flags = num2cell([EEG.EVENTLIST.eventinfo(indxitem).flag]);
            [EEG.EVENTLIST.bdf(i).rtflag(:,j)] = flags{:};
      end
end

