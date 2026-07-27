
function best2memory(BEST,indx) 

bestm = findobj('tag','linbest'); 
nbestset = length(bestm);

for s = 1:nbestset
    
    if s == nbestset-indx+1 %bottomup to topdown counting
        set(bestm(s),'checked','on');
        set(bestm(s),'ForegroundColor','#0072BD');
        menutitle = ['BESTset ' ...
            num2str(nbestset-s+1) ': ' BEST.bestname];
        set(bestm(s), 'Label', menutitle);

    else
        set(bestm(s),'checked','off');
        set(bestm(s),'ForegroundColor','k');
        currname = get(bestm(s),'Label');
        menutitle = regexprep(currname, '\s+', ' ');
        menutitle = regexprep(menutitle,'BESTset \d+',['BESTset ' num2str(nbestset-s+1)], 'ignorecase');
        set( bestm(s), 'Label', menutitle);

    end
    
    
end

CURRENTBEST = indx;
assignin('base','CURRENTBEST',CURRENTBEST); 
assignin('base','BEST',BEST); 

fprintf('\n------------------------------------------------------\n');
fprintf('BESTset #%g is ACTIVE\n', indx);
fprintf('------------------------------------------------------\n');

end