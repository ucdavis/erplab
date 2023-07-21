function mvpc = avgconfusionCM(mvpc, xdist)
% create confusion matrix for crossnobis classification
%%%%% THIS FUNCTION IS A PART OF ERPLAB ***


%obtain permutations label
conditions = 1:mvpc.nClasses;
Permutations = nchoosek(conditions,2);
idx = [2 1]; 
Permutations_lower = Permutations(:,idx); 

%average pairwise distance across iteration 
avg_distance_itr = squeeze(mean(xdist,2));
npoints = size(avg_distance_itr,1) ; 

%confusion matrix empty
nconditions = numel(conditions); 
cf = zeros(nconditions,nconditions,npoints); %same order as in SVM dimensionwise

%index lower square
for t = 1:npoints
    %upper diagonal then lower diagonal
    for i = 1:size(Permutations,1)
        loc = Permutations(i,:);
        x = loc(1);
        y = loc(2);
        
        loc_bottom = Permutations_lower(i,:);
        
        z = loc_bottom(1);
        w = loc_bottom(2); 
        
        %index 
        cf(x,y,t) = avg_distance_itr(t,i);
        cf(z,w,t) = avg_distance_itr(t,i);
    end
    

end

mvpc.confusions.scores = cf;
mvpc.confusions.labels = mvpc.classlabels;



