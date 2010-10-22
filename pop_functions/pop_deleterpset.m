%
% Author: Javier Lopez-Calderon & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

function [ALLERP erpcom] = pop_deleterpset(ALLERP, index)
erpcom = '';

if nargin<1
      help pop_deleterpset
end

if nargin<2
      
      try
            CURRENTERP = evalin('base', 'CURRENTERP');
      catch
            CURRENTERP = 0;
      end
      
      if  CURRENTERP == 0
            msgboxText{1} =  'ERPsets menu is already empty...';
            title        =  'ERPLAB: no erpset(s)';
            errorfound(msgboxText, title);
            return
      end
      
      prompt    = {'Erpset(s) to clear:'};
      dlg_title = 'Delete erpset(s)';
      num_lines = 1;
      
      def = {num2str(CURRENTERP)}; %01-13-2009
      answer = inputvalue(prompt,dlg_title,num_lines,def);
      
      if isempty(answer)
            disp('User selected Cancel')
            return
      end
      
      index =  str2num(answer{1});
      
elseif nargin>2
      disp('wrong inputs')
      return
end

nerpset = length(ALLERP);
index   = unique(index);

if isempty(index)
      msgboxText{1} =  'Wrong erpset index(es)';
      title        =  'ERPLAB: unrecognizable erpset(s)';
      errorfound(msgboxText, title);
      return
end
if max(index)>nerpset || min(index)<1
      msgboxText{1} =  'Wrong erpset index(es)';
      msgboxText{2} =  'Check your erpset menu or write length(ALLERP) at command window for comprobation';
      title        =  'ERPLAB: pop_deleterpset not existing erpset(s)';
      errorfound(msgboxText, title);
      return
end


detect = ~ismember(1:nerpset,index);
newindex = find(detect);

if isempty(newindex)
      ALLERP = [];
else
      ALLERP = ALLERP(newindex);
end

updatemenuerp(ALLERP, -1)

erpcom = sprintf('ALLERP = pop_deleterpset( ALLERP, [%s]);', num2str(index));
try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
return
