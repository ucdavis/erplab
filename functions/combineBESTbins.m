function BEST = combineBESTbins(BEST,new_bins,new_labels)

n_bins = size(new_bins,2);

BEST.nbin = n_bins; 
BEST.bindesc = new_labels'; 
BEST.original_bin = {}; %erase due to new BEST being combined


new_binwise_data = struct(); 
n_trials_per_bin = NaN(1,numel(new_bins)); 

%% combine bins
for b = 1:n_bins
    
    selected_bins = new_bins{b};
    if ischar(selected_bins) || isstring(selected_bins)
        selected_bins = str2num(selected_bins);
    end
    
    if numel(selected_bins) == 1
        data_splice = BEST.binwise_data(selected_bins).data; 
        n_trials_per_bin(b) = size(data_splice,3); %ntrials
        new_binwise_data(b).data = data_splice; 
        
        
    else
               
        for j = 1:numel(selected_bins)
    
            
            bin_index = selected_bins(j); 
            data_splices{j} = BEST.binwise_data(bin_index).data; 
            
            
        end
         
        C = cat(3,data_splices{:}); %combine trials
        n_trials_per_bin(b) = size(C,3); %ntrials
        new_binwise_data(b).data = C;
            
    end
    clear data_splices; 
    
end


BEST.binwise_data = new_binwise_data; 
BEST.n_trials_per_bin = n_trials_per_bin; 
BEST.saved = 'no'; 


end