


function msgwrng = f_check_bestsets(ALLBEST,BESTArray)
msgwrng = '';
for j = 1:numel(BESTArray)

    BEST = ALLBEST(BESTArray(j));
    if j>1
        % number of bins
        if pre_nbin  ~= BEST.nbin
            msgwrng =  sprintf('BESTsets #%g and #%g have different number of bins, please select a single BESTset!', BESTArray(j-1), BESTArray(j));
            return;
        end

        %%bin description
        for Numofbin = 1:pre_nbin
            if ~strcmpi(pre_bindesc{Numofbin},BEST.bindesc{Numofbin})
                msgwrng =  sprintf('BESTsets #%g and #%g have different bin descriptions, please select a single BESTset!', BESTArray(j-1), BESTArray(j));
                return;
            end
        end
    end

    pre_nbin  = BEST.nbin;
    pre_bindesc = BEST.bindesc;
end

end