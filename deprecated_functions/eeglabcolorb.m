%
% DEPRECATED
%

h = findobj('Tag','EEGLAB');
i = get(h,'Children');
k = get(i,'Tag');
tags = regexpi(k,'\w*win\w*','match');
tags = [tags{:}];
for a=1:length(tags)
      hh = findobj('Tag',tags{a});
      set(hh,'backgroundcolor','g')
end
hm = findobj('Tag', 'Frame1');
set(hm,'backgroundcolor','g')
hm = findobj('Tag', 'EEGLAB');
set(hm,'Color','g')
