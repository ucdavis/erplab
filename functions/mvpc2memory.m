
function mvpc2memory(MVPC,indx) 

mvpcm = findobj('tag','linmvpc'); 
nmvpcset = length(mvpcm);

for s = 1:nmvpcset
    
    if s == nmvpcset-indx+1 %bottomup to topdown counting
        set(mvpcm(s),'checked','on'); 
        menutitle = ['<Html><b>MVPCset' ...
            num2str(nmvpcset-s+1) ': ' MVPC.mvpcname '</b>'];
        set(mvpcm(s), 'Label', menutitle); 
        
    else
        set(mvpcm(s),'checked','off');
        currname = get(mvpcm(s),'Label');
        menutitle = regexprep(currname,'<b>|</b>','', 'ignorecase');
        menutitle = regexprep(menutitle, '\s+', ' ');
        menutitle = regexprep(menutitle,'MVPCset \d+',['MVPCset ' num2str(nmvpcset-s+1)], 'ignorecase');
        set( mvpcm(s), 'Label', menutitle);
        
    end
    
    
end

CURRENTMVPC = indx;
assignin('base','CURRENTMVPC',CURRENTMVPC); 
assignin('base','MVPC',MVPC); 

fprintf('\n------------------------------------------------------\n');
fprintf('MVPCset #%g is ACTIVE\n', indx);
fprintf('------------------------------------------------------\n');

end