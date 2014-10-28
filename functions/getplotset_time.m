% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

binArray       = plotset.ptime.binArray;
plotallbin     = plotset.ptime.plotallbin;
chanArray      = plotset.ptime.chanArray;
plotallch      = plotset.ptime.plotallch;
chanArray_MGFP = plotset.ptime.chanArray_MGFP;
blcorr         = plotset.ptime.blcorr;
xxscale        = plotset.ptime.xscale;
yyscale        = plotset.ptime.yscale;
linewidth      = plotset.ptime.linewidth;
isiy           = plotset.ptime.isiy;
fschan         = plotset.ptime.fschan;
fslege         = plotset.ptime.fslege;
fsaxtick       = plotset.ptime.fsaxtick;
pstyle         = plotset.ptime.pstyle;
errorstd       = plotset.ptime.errorstd;
stdalpha       = plotset.ptime.stdalpha;
isMGFP         = plotset.ptime.isMGFP;
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
        pbox   = plotset.ptime.pbox;
% end
counterwin     = plotset.ptime.counterwin;
holdch         = plotset.ptime.holdch;
yauto          = plotset.ptime.yauto;
yautoticks     = plotset.ptime.yautoticks;
xautoticks     = plotset.ptime.xautoticks;
binleg         = plotset.ptime.binleg;
chanleg        = plotset.ptime.chanleg;

ismaxim        = plotset.ptime.ismaxim;
%istopo         = plotset.ptime.istopo;
axsize         = plotset.ptime.axsize;
minorticks     = plotset.ptime.minorticks;
linespeci      = plotset.ptime.linespec;
legepos        = plotset.ptime.legepos;
posgui         = plotset.ptime.posgui;
posminigui     = plotset.ptime.posminigui;
posfig         = plotset.ptime.posfig;
ibckground     = plotset.ptime.ibckground;