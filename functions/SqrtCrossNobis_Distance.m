function CrossNobis_Distance = SqrtCrossNobis_Distance(measurementsA, labelsA, measurementsB, labelsB)
    %this function calculates the crossvalidated mahalanobis (i.e., "crossnobis")
    %distance between the conditions specified in labels across the values specified
    %in measurements, cross-validated across set A and set B
     
    %"measurements" should be a nTrials x nFeatures matrix. nFeatures
    %corresponds to the number of recording channels (e.g., electrodes)
    
    %"labels" should be a column vector of length = nTrials, with the value in each
    %row corresponding to the condition label for the current trial.

    %Extract the number of trials (nTrials) and number of features (nFeatures)
    %for the measurements, and the number of conditions (nConditions) for the
    %labels. Note: sets A and B should be of the same size.
    [nTrials, nFeatures] = size(measurementsA);
    conditions = unique(labelsA);
    nConditions = numel(conditions);
    
    %compute number of distances to calculate (each distance is a pairwise
    %comparison between conditions)
    Permutations = nchoosek(conditions,2);
    nPermutations = size(Permutations,1);
    
    %pre-allocate matrices for means and variances
    class_meanA = zeros(nConditions,nFeatures);   % class means for set A
    class_covA = zeros(nFeatures);              % within-class variability for set A
    class_meanB = zeros(nConditions,nFeatures);   % class means for set B
    
    %NOTE: we only need to calculate the covariance for Set A because the "scaling"
    %by variance is done based on the variance of the underlying
    %distribution from which the samples were drawn. Because Set A and Set
    %B were drawn from the same distribution, we only calculate the
    %covariance matrix for that set, and then scale our distance
    %calculation by that.
    
    for k=1:nConditions
        %select labels in the current class of interest
        msk=labelsA==conditions(k);

        %number of samples in k-th class
        n=sum(msk);
        
        %select measurements from current set
        class_samples=measurementsA(msk,:);
    
        class_meanA(k,:) = sum(class_samples,1)/n; % class mean
        res = bsxfun(@minus,class_samples,class_meanA(k,:)); % residuals
        class_covA = class_covA+res'*res; % estimate common covariance matrix
    end
    
    %[class_covA,shrinkage] = cov1para(class_meanA);
    class_covA = class_covA/nTrials; %scale covariance matrix by number of observations
    %class_covA = inv(class_covA);
    
    %apply regularization to the covariance matrix. This step is needed because 
    %extreme values (especially near zero) can render the covariance matrix
    %non-invertible, which disallows us from scaling the class means by the
    %variance. however, the current regularization is a bit "klugey" -- it might be
    %preferable to use a "shrinkage" algorithm, as in Ledoit & Wolf (2003).
    %I haven't figured out how to implement that, yet.
    
    regularization=0.01;
	reg=eye(nFeatures)*trace(class_covA)/max(1,nFeatures);
	class_cov_reg=class_covA+reg*regularization;
    
    for k=1:nConditions
        %select labels in the current class of interest
        msk=labelsB==conditions(k);

        %number of samples in k-th class
        n=sum(msk);
            
        %select measurements from current set
        class_samples=measurementsB(msk,:);

        class_meanB(k,:) = sum(class_samples,1)/n; % class mean
    end
    
    %compute class vectors for each set, sclaed by the regularized
    %covariance matrix
    class_vectorA = class_meanA / class_cov_reg;
    %class_vectorA = class_meanA * class_covA;
    %class_vectorA = class_meanA / class_covA;
    class_vectorB = class_meanB;
    
    % first, compute the (squared) distance for each feature channel: (conditionX-conditionY)_SetA * (conditionX-conditionY)_SetB
	temp_dist = zeros(1,nFeatures);
    for j = 1:nFeatures
        for k = 1:nPermutations
            temp_dist(k,j) = ((class_vectorA(Permutations(k,1),j) - class_vectorA(Permutations(k,2),j)) * (class_vectorB(Permutations(k,1),j) - class_vectorB(Permutations(k,2),j)));
        end            
    end
    
    % now, square root the above to get the distance for each feature channel
    % note that the negative distances signs are changed to positive,
    % square rooted, then returned to their negative value
    for j = 1:nFeatures
        for k = 1:nPermutations
            if temp_dist(k,j) >= 0
                temp_dist(k,j) = sqrt(temp_dist(k,j));
            else
                temp_dist(k,j) = -1*(sqrt(-1 * temp_dist(k,j)));
            end
        end
    end
    
    CrossNobis_Distance = nan(nPermutations,1);
    %sum the distances from each feature channel
    for i = 1:nPermutations
        CrossNobis_Distance(i,1) = sum(temp_dist(i,:)); %cross-validated mahalanobis distance
    end
    