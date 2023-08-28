% PURPOSE: updates MVPCset menu 


function updatemenumvpc(ALLMVPC,overw) 
if nargin<2
      overw=0; % overwrite MVPCset menu? 0=no; 1=yes; -1=delete
end

%
% Checks MVPCset menu status
%
MVPCmenu  = findobj('tag', 'mvpcsets');
statbestm = get(MVPCmenu, 'Enable');
if strcmp(statbestm,'off')
      set(MVPCmenu, 'Enable', 'on'); % activates bestsets menu
end

maxindexmvpc = length(ALLMVPC); 
MVPCSETMENU = zeros(1,maxindexmvpc); 
mvpcsetlist = findobj('tag','linmvpc'); 

if isempty(mvpcsetlist)
    nmvpcset = 0;
    overw = 0 ; %add a new MVPCset
elseif length(mvpcsetlist) > maxindexmvpc
    nmvpcset = length(mvpcsetlist);
    overw = -1; %delete MVPCset
elseif length(mvpcsetlist) < maxindexmvpc
    nmvpcset = length(mvpcsetlist);
    overw = 0; %add MVPCset
    
else
    nmvpcset = length(mvpcsetlist); 
end

if overw == 1
    %overwrite. Just change the current bestset 
    
    for s = 1:nmvpcset
        strcheck = get(mvpcsetlist(s), 'checked'); 
        
        if strcmp(strcheck,'on')
            catchindx = nmvpcset-s+1;
            mvpcn = ALLMVPC(nmvpcset-s+1).mvpcname; 
            menutitle = sprintf('MVPCset %d: %s', nmvpcset-s+1,mvpcn); 
            set(mvpcsetlist(s), 'Label', menutitle); 
        end
            
    end
    mvpc2memory(ALLMVPC(catchindx),catchindx); 
    
elseif overw == 0 || overw == -1
    
    if overw == 0 %add a new bestset to the bestset menu
        indexmvpc = nmvpcset + 1; 
    else %delete bestset from menu
            menux = findobj(0, 'tag', 'mvpcsets');
            h = get(menux);
            delete(h.Children);
            indexmvpc = 1;
            if maxindexmvpc==0
                  assignin('base','CURRENTMVPC', 0);  % save to workspace
                  set(MVPCmenu, 'enable', 'off');
                  return
            end
    end
    
    while indexmvpc <= maxindexmvpc 
        MVPCSETMENU(indexmvpc) = uimenu(MVPCmenu, 'tag', 'linmvpc'); 
        fmvpc = ['mvpc2memory(ALLMVPC(' num2str(indexmvpc) '),' num2str(indexmvpc) ');']; 
        mvpcn = ALLMVPC(indexmvpc).mvpcname; 
        if iscell(mvpcn)
            mvpcn = '';
        end
        menutitle   = ['<Html><FONT color="black" >MVPCset ' num2str(indexmvpc) ': ' mvpcn '</font>'];
        set( MVPCSETMENU(indexmvpc), 'Label', menutitle);
        set( MVPCSETMENU(indexmvpc), 'CallBack', fmvpc );
        set( MVPCSETMENU(indexmvpc), 'Enable', 'on' );
        indexmvpc = indexmvpc + 1;
        
    end
    
    if maxindexmvpc ~= 0 
        mvpc2memory(ALLMVPC(maxindexmvpc),maxindexmvpc);
    end
    
        
        
        
else
    error('ERPLAB sasys: wrong input parameter') 
   
             
       
end
    
eeglab redraw; 
%set(MVPCmenu, 'Enable', 'on'); % activates erpsets menu after redraw (eeglab hack)

end