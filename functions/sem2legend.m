% function sem2legend

%legendArray = get(hndl,'DisplayName')
fnddata = findobj('parent',hndl);
legendArray = get(fnddata,'DisplayName');
legendArray = legendArray';
legendArray = legendArray(~cellfun(@isempty, legendArray));
legendArray2 = {''};
nnlg = 2*length(legendArray);
gg=length(legendArray); hh=1;
for bb=1:nnlg
        if mod(bb,2)~=0
                legendArray2{bb} = legendArray{gg};
                gg=gg-1;
        else
                legendArray2{bb} = sprintf('s.e.m. for Bin %g', hh);
                hh=hh+1;
        end
end
legendArray2 = fliplr(legendArray2);
legendArray2 = [{''} legendArray2];
set(fnddata,{'DisplayName'}, legendArray2')