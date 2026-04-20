function [svm_predict_TGM,tst_target_TGM,svm_scores_TGM] = f_test_all_times_TGM(blockDat_filtData,blockNum,train_b,mdl,tstl)

for t_test = 1:size(blockDat_filtData,3)
    dataAtTest = squeeze(mean(blockDat_filtData(:,:,t_test),3));
    tstD = dataAtTest(blockNum==train_b,:);
    [preds, scores] = predict(mdl, tstD);
    svm_predict_TGM(:,t_test) = preds;
    tst_target_TGM(:,t_test)  = tstl;
    svm_scores_TGM(:,:,t_test) = scores;
end

end