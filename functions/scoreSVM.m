function [mvpa] = scoreSVM(mvpa, truelabel, predictedlabel) 

    [Nitr, Nblock, Ntp, nBins] =  size(truelabel); 
    
     DecodingAccuracy = nan(Ntp,Nblock,Nitr);
     
    % Obtain predictions from SVM-ECOC model
    svmPrediction = squeeze(predictedlabel);
    tstTargets = squeeze(truelabel);

    
    %% Step 5: Compute decoding accuracy of each decoding trial
    for block = 1:Nblock
        for itr = 1:Nitr
            for tp = 1:Ntp  

                prediction = squeeze(svmPrediction(itr,tp,block,:)); % this is predictions from models
                TrueAnswer = squeeze(tstTargets(itr,tp,block,:)); % this is predictions from models
                Err = TrueAnswer - prediction; %compute error. No error = 0
                ACC = mean(Err==0); %Correct hit = 0 (avg propotion of vector of 1s and 0s)
                DecodingAccuracy(tp,block,itr) = ACC; % average decoding accuracy at tp & block

            end
        end
    end
      
     % Average across block and iterations
     grandAvg = squeeze(mean(mean(DecodingAccuracy,2),3));
    
     % Perform temporal smoothing (5 point moving avg) 
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
     
     % Save smoothe data
     AverageAccuracy(seta,:) =smoothed; % average across iteration and block


    reshape_targ = reshape(svm_predict,[Nitr*Nblock,Ntp,nBins]);
    final_targ = permute(new_targ,[2 1 3]); 



end