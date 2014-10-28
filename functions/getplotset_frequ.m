% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

binArray       = plotset.pfrequ.binArray;
plotallbin     = plotset.pfrequ.plotallbin;
chanArray      = plotset.pfrequ.chanArray;
plotallch      = plotset.pfrequ.plotallch;
chanArray_MGFP = plotset.pfrequ.chanArray_MGFP;
blcorr         = plotset.pfrequ.blcorr;
xxscale        = plotset.pfrequ.xscale;
yyscale        = plotset.pfrequ.yscale;
linewidth      = plotset.pfrequ.linewidth;
isiy           = plotset.pfrequ.isiy;
fschan         = plotset.pfrequ.fschan;
fslege         = plotset.pfrequ.fslege;
fsaxtick       = plotset.pfrequ.fsaxtick;
pstyle         = plotset.pfrequ.pstyle;
errorstd       = plotset.pfrequ.errorstd;
stdalpha       = plotset.pfrequ.stdalpha;
isMGFP         = plotset.pfrequ.isMGFP;
% 
% if plotallch        
%         newnch = numel(chanArray);
%         if isMGFP
%                 newnch = newnch + 1;
%         end
%         dsqr   = round(sqrt(newnch));
%         sqrdif = dsqr^2 - newnch;
%         if sqrdif<0
%                 pbox(1) = dsqr + 1;
%         else
%                 pbox(1) = dsqr;
%         end
%         pbox(2) = dsqr;        
% else
        pbox   = plotset.pfrequ.pbox;
% end
counterwin     = plotset.pfrequ.counterwin;
holdch         = plotset.pfrequ.holdch;
yauto          = plotset.pfrequ.yauto;
yautoticks     = plotset.pfrequ.yautoticks;
xautoticks     = plotset.pfrequ.xautoticks;
binleg         = plotset.pfrequ.binleg;
chanleg        = plotset.pfrequ.chanleg;

ismaxim        = plotset.pfrequ.ismaxim;
%istopo         = plotset.pfrequ.istopo;
axsize         = plotset.pfrequ.axsize;
minorticks     = plotset.pfrequ.minorticks;
linespeci      = plotset.pfrequ.linespec;
legepos        = plotset.pfrequ.legepos;
posgui         = plotset.pfrequ.posgui;
posminigui     = plotset.pfrequ.posminigui;
posfig         = plotset.pfrequ.posfig;
ibckground     = plotset.pfrequ.ibckground;