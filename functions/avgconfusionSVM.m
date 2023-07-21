function [mvpc] = avgconfusionSVM(mvpc, truelabel, predictedlabel) 

% this function reshapes the decorder outputs 
% and creates mvpa.raw_accuracy_1vsall 
Nclasses = mvpc.nClasses; 

% if classcoding == 2 
[Nitr, Nblock, Ntp, nBins] =  size(truelabel);
runs = Nitr*Nblock; %"run" is combination of iteration and fold

reshape_predictions = reshape(predictedlabel,[runs,Ntp,nBins]);
predictions = permute(reshape_predictions,[2 1 3]);

reshape_truelabels = reshape(truelabel,[runs,Ntp,nBins]);
truelabels = permute(reshape_truelabels,[2 1 3]);
%predictions = Timepoint x Run x Class
%save predictions
%mvpc.raw_predictions = predictions ;

% TrueAnswer = reshape([1:Nclasses],[Nclasses,1]);

%preallocate confusions at each tp
confusions = zeros(nBins,nBins,Ntp);

for tp = 1:Ntp
    
    %pmats
    pred = squeeze(predictions(tp,:,:));
    pmat_tp = reshape(pred,[1 Nclasses*runs]);
    
    %tmats
    trues = squeeze(truelabels(tp,:,:));
    tmat_tp = reshape(trues,[1 Nclasses*runs]);
    
    [C,c3] = confusionmat(tmat_tp, pmat_tp);
    confusions(:,:,tp) = C/(unique(sum(C,2)));  % row is true labels, column is predicted labels
    
end

mvpc.confusions.scores = confusions;
mvpc.confusions.labels = mvpc.classlabels;

     
% elseif classcoding == 1
%     %create for 1v1 case
%     
%     
% else
%     disp('No SVM coding output?')
%     return
% end

end