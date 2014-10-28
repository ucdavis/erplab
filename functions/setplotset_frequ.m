plotset.pfrequ.binArray   = binArray;
plotset.pfrequ.plotallbin = plotallbin;
plotset.pfrequ.chanArray  = chanArray;
plotset.pfrequ.plotallch  = plotallch;
plotset.pfrequ.chanArray_MGFP = chanArray_MGFP;
plotset.pfrequ.blcorr     = blcorr;
plotset.pfrequ.xscale     = xxscale;
plotset.pfrequ.yscale     = yyscale;
plotset.pfrequ.linewidth  = linewidth;
plotset.pfrequ.isiy       = isiy;
plotset.pfrequ.fschan     = fschan;
plotset.pfrequ.fslege     = fslege;
plotset.pfrequ.fsaxtick   = fsaxtick;
%plotset.pfrequ.meap       = meap;
plotset.pfrequ.pstyle     = pstyle;
plotset.pfrequ.errorstd   = errorstd;
plotset.pfrequ.stdalpha   = stdalpha;
plotset.pfrequ.pbox       = pbox;
plotset.pfrequ.counterwin = counterwin;
plotset.pfrequ.holdch     = holdch;
plotset.pfrequ.yauto      = yauto;
plotset.pfrequ.yautoticks = yautoticks;
plotset.pfrequ.xautoticks = xautoticks;
plotset.pfrequ.binleg     = binleg;
plotset.pfrequ.chanleg    = chanleg;
plotset.pfrequ.isMGFP     = isMGFP;
plotset.pfrequ.ismaxim    = ismaxim;
%plotset.pfrequ.istopo     = istopo;
plotset.pfrequ.axsize     = axsize;
plotset.pfrequ.minorticks = minorticks;
plotset.pfrequ.linespec   = linespeci;
plotset.pfrequ.legepos    = legepos;
plotset.pfrequ.posgui     = posgui;
if ~isfield(plotset.pfrequ, 'posminigui')
        plotset.pfrequ.posminigui = [];
end
plotset.pfrequ.posfig     = posfig;

% adjusting
plotset.pfrequ.binArray   = plotset.pfrequ.binArray(plotset.pfrequ.binArray<=ERP.nbin);
plotset.pfrequ.chanArray  = plotset.pfrequ.chanArray(plotset.pfrequ.chanArray<=ERP.nchan);
plotset.pfrequ.chanArray_MGFP = plotset.pfrequ.chanArray_MGFP(plotset.pfrequ.chanArray_MGFP<=ERP.nchan);

plotset.pfrequ.ibckground  = ibckground;

% if plotset.pfrequ.xscale(1) < ERP.xmin*1000
%       plotset.pfrequ.xscale(1) = ceil(ERP.xmin*1000);
% end
% if plotset.pfrequ.xscale(2) > ERP.xmax*1000
%       plotset.pfrequ.xscale(2) = floor(ERP.xmax*1000);
% end