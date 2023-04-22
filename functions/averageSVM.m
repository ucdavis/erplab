function [mvpc] = averageSVM(mvpc, SVMcoding, smoothing)

% Create the decoding accuracy at each time point (averaged over classes) 

Nblock = mvpc.nCrossfolds;
Nitr = mvpc.nIter; 
Ntp = length(mvpc.times); 
Nclasses = mvpc.nClasses;
Nruns = Nblock*Nitr;
%chancelvl = 1/Nclasses; 

DecodingAccuracy = nan(Ntp,Nruns);
% We will compute decoding accuracy per subject in DecodingAccuracy,
% enter DecodingAccuracy into AverageAccuray, then overwrite next subj.

%% load SVM_ECOC output files

if SVMcoding == 2 %1vAll
    % Obtain predictions from SVM-ECOC model
    svmPrediction = squeeze(mvpc.raw_predictions);
   % tstTargets = squeeze(ALLMVPA(seta).targets);
    
    
    TrueAnswer = reshape([1:Nclasses],[Nclasses,1]); 

    
    for r = 1:Nruns
        for tp = 1:Ntp
            prediction = squeeze(svmPrediction(tp,r,:));
            Err = TrueAnswer - prediction;
            ACC = mean(Err == 0);
            DecodingAccuracy(tp,r) = ACC;
            
            
            
        end
    end
    
    grandAvg = mean(DecodingAccuracy,2); %average across runs
    % Perform temporal smoothing (5 point moving avg)
    if smoothing == 1
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
        
    else
        smoothed = grandAvg;
    end
    
else %1V1 case? 
    
end



% Save smoothe data
mvpc.average_accuracy_1vAll = smoothed; 

end