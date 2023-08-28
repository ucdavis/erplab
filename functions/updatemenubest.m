% PURPOSE: updates BESTset menu 


function updatemenubest(ALLBEST,overw) 
if nargin<2
      overw=0; % overwrite bestset menu? 0=no; 1=yes; -1=delete
end

%
% Checks BESTsets menu status
%
BESTmenu  = findobj('tag', 'bestsets');
statbestm = get(BESTmenu, 'Enable');
if strcmp(statbestm,'off')
      set(BESTmenu, 'Enable', 'on'); % activates bestsets menu
end

maxindexbest = length(ALLBEST); 
BESTSETMENU = zeros(1,maxindexbest); 
bestsetlist = findobj('tag','linbest'); 

if isempty(bestsetlist)
    nbestset = 0;
    overw = 0 ; %add a new bestset
elseif length(bestsetlist) > maxindexbest
    nbestset = length(bestsetlist);
    overw = -1; %delete bestset
elseif length(bestsetlist) < maxindexbest
    nbestset = length(bestsetlist);
    overw = 0; %add bestset 
    
else
    nbestset = length(bestsetlist); 
end

if overw == 1
    %overwrite. Just change the current bestset 
    
    for s = 1:nbestset
        strcheck = get(bestsetlist(s), 'checked'); 
        
        if strcmp(strcheck,'on')
            catchindx = nbestset-s+1;
            bestn = ALLBEST(nbestset-s+1).bestname; 
            menutitle = sprintf('BESTset %d: %s', nbestset-s+1,bestn); 
            set(bestsetlist(s), 'Label', menutitle); 
        end
            
    end
    best2memory(ALLBEST(catchindx),catchindx); 
    
elseif overw == 0 || overw == -1
    
    if overw == 0 %add a new bestset to the bestset menu
        indexbest = nbestset + 1; 
    else %delete bestset from menu
            menux = findobj(0, 'tag', 'bestsets');
            h = get(menux);
            delete(h.Children);
            indexbest = 1;
            if maxindexbest==0
                  assignin('base','CURRENTBEST', 0);  % save to workspace
                  set(BESTmenu, 'enable', 'off');
                  return
            end
    end
    
    while indexbest <= maxindexbest 
        BESTSETMENU(indexbest) = uimenu(BESTmenu, 'tag', 'linbest'); 
        fbest = ['best2memory(ALLBEST(' num2str(indexbest) '),' num2str(indexbest) ');']; 
        bestn = ALLBEST(indexbest).bestname; 
        if iscell(bestn)
            bestn = '';
        end
        menutitle   = ['<Html><FONT color="black" >BESTset ' num2str(indexbest) ': ' bestn '</font>'];
        set( BESTSETMENU(indexbest), 'Label', menutitle);
        set( BESTSETMENU(indexbest), 'CallBack', fbest );
        set( BESTSETMENU(indexbest), 'Enable', 'on' );
        indexbest = indexbest + 1;
        
    end
    
    if maxindexbest ~= 0 
        best2memory(ALLBEST(maxindexbest),maxindexbest);
    end
    
        
        
        
else
    error('ERPLAB sasys: wrong input parameter') 
   
             
       
end
    
eeglab redraw; 
%set(BESTmenu, 'Enable', 'on'); % activates erpsets menu after redraw (eeglab hack)

end