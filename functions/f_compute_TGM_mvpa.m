

function  TGM_erp =  f_compute_TGM_mvpa(mvpc,svm_predict_TGM,tst_target_TGM,svm_scores_TGM,OutcomeMetric)
% fprintf('Computing Temporal Generalization Matrices (ACC & AUC)...\n');

nTestT  = size(svm_predict_TGM,3);
TGM_erp = nan(nTestT, nTestT);
for Numoftest = 1:nTestT
    tst_target = squeeze(tst_target_TGM(:,:,:,:,Numoftest));
    svm_predict = squeeze(svm_predict_TGM(:,:,:,:,Numoftest));
    mvpc = rawscoreSVM(mvpc, tst_target, svm_predict); %compute raw method/decoder scores
    if strcmpi(OutcomeMetric,'ACC')%%GH 2025 August
        mvpc = averageSVM(mvpc,0); %average accuracy across runs, %no smoothing
        mvpc.DecodingUnit= 'proportion correct';
    else %% AUC
        svm_scores= squeeze(svm_scores_TGM(:,:,:,:,:,Numoftest));
        [mvpc] = f_average_auc(mvpc, svm_scores,tst_target,0);
    end
    TGM_erp(:,Numoftest) = mvpc.average_score;
end

end



