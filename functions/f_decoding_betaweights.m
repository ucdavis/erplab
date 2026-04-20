

function BetaWeights_bin = f_decoding_betaweights(mdl,nDecoders,method,nBins)
% ddd=0;
% for iiii = 1:nDecoders
%     for j = iiii+1:nDecoders
%         ddd = ddd+1;
%         BetaWeights_bin(ddd,:) = mdl.Coeffs(iiii,j).Linear;
%     end
% end

if method==1%% SVM%%GH August 2025
    if nBins > 2
        for d = 1:nDecoders
            BetaWeights_bin(d,:) = mdl.BinaryLearners{d}.Beta;% SVM weights uncorrected
        end
    else
        %binary decoder
        for d = 1:nDecoders
            BetaWeights_bin(d,:) = mdl.Beta;% SVM weights uncorrected
        end
    end
elseif method==2%% LDA%%GH August 2025
    % for d = 1:nDecoders
    %     BetaWeights_Raw(iter,t,i,d,:) = mdl.Coeffs(1,2).Linear;
    % end
    if nBins > 2
        d = 0;
        for iiii = 1:nDecoders
            for j = iiii+1:nDecoders
                d = d+1;
                BetaWeights_bin(d,:) = mdl.Coeffs(iiii,j).Linear;
            end
        end
    else
        %binary decoder
        for d = 1:nDecoders
            BetaWeights_bin(d,:) = mdl.Coeffs(1,2).Linear;% LDA weights uncorrected
        end
    end
end
BetaWeights_bin = squeeze(mean(BetaWeights_bin,1));
