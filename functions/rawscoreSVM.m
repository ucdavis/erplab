function [mvpc] = rawscoreSVM(mvpc, truelabel, predictedlabel) 

% this function reshapes the decorder outputs 
% and creates mvpa.raw_accuracy_1vsall 

%if classcoding == 2 
[Nitr, Nblock, Ntp, nBins] =  size(truelabel);
runs = Nitr*Nblock; %"run" is combination of iteration and fold

reshape_predictions = reshape(predictedlabel,[runs,Ntp,nBins]);
predictions = permute(reshape_predictions,[2 1 3]);
%predictions = Timepoint x Run x Class
%save predictions
mvpc.raw_predictions = predictions ;
    
%     mvpa.raw_accuracy_1vAll = struct();
%     
%     ind = 1; 
%     for tp = 1:Ntp
%         for run = 1:runs
%             mvpa.raw_accuracy_1vAll(ind).TimePoint = tp;
%             mvpa.raw_accuracy_1vAll(ind).Run = run;
%             for b = 1:nBins
%                 mvpa.raw_accuracy_1vAll(ind).(strcat('Class_',num2str(b))) =  ...
%                     predictions(tp,run,b); 
%             end
%             ind = ind + 1;
%         end
%     end
    

%    %create for 1v1 case
    
    
%else
%     disp('No SVM coding output?')
%    return
%end

end