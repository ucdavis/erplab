function [mvpc] = f_average_auc(mvpc, svm_scores,tst_target,smoothing)

% Create the decoding accuracy at each time point (averaged over classes)
[Nitr,Nblock,Ntp,Nclasses,~] = size(svm_scores);
% Nblock = mvpc.nCrossfolds;
% Nitr = mvpc.nIter;
% Ntp = length(mvpc.times);
% Nclasses = mvpc.nClasses;
% Nruns = Nblock*Nitr;
%chancelvl = 1/Nclasses;
for Numoftp = 1:Ntp
    for Numofitr = 1:Nitr
        scores_oneblock1 = squeeze(svm_scores(Numofitr,:,Numoftp,:,:));
        testd1 = squeeze(tst_target(Numofitr,:,Numoftp,:));
        scores_oneblock = [];
        testd = [];
        for Numofblock = 1:Nblock
            scores_oneblock = [scores_oneblock;squeeze(scores_oneblock1(Numofblock,:,:))];
            testd  = [testd;testd1(Numofblock,:)'];
        end

        rocObj = rocmetrics(testd,scores_oneblock,[1:mvpc.nClasses]);
        [FPR, TPR, Thresholds, AUC_avg] = average(rocObj, 'macro');%%'micro','macro'
        AUC_itr(Numofitr,1) = AUC_avg;
    end

    mvpc.average_score(1,Numoftp) = mean(AUC_itr,1);
    %standard error (assume binomial distribution)
    mvpc.stderror(1,Numoftp)  =  std(AUC_itr,0,1)/sqrt(numel(AUC_itr));
end


if smoothing == 1
    grandAvg= mvpc.average_score;
    smoothed = nan(1,Ntp);
    for tAvg = 1:Ntp
        if tAvg ==1
            smoothed(tAvg) = mean(grandAvg((tAvg):(tAvg+2)));
        elseif tAvg ==2
            smoothed(tAvg) = mean(grandAvg((tAvg-1):(tAvg+2)));
        elseif tAvg == (Ntp-1)
            smoothed(tAvg) = mean(grandAvg((tAvg-2):(tAvg+1)));
        elseif tAvg == Ntp
            smoothed(tAvg) = mean(grandAvg((tAvg-2):(tAvg)));
        else
            smoothed(tAvg) = mean(grandAvg((tAvg-2):(tAvg+2)));
        end

    end
    mvpc.average_score = smoothed;
end



end