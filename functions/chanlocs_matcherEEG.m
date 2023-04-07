% PURPOSE: Super-simple matching of old chanlocs to new labels
%
% FORMAT: ERP = chanlocs_matcher(ERP, ERPold)
%
% ERP should be an ERP structure which is (presumably) needing channel locs
% ERPold should be an old ERP structure which has the desired channel
% location information
%
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Andrew X Stewart
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
function ERP = chanlocs_matcherEEG(ERP, ERPold)

if nargin==1
    disp('Need new ERP and old ERP for chanlocs');
    %ERPold = erpworkingmemory('chanopGUI');
end


newN = ERP.nbchan;
oldN = numel(ERPold.chanlocs);

if newN ~= numel(ERP.chanlocs)
    disp('Channel number and label number mismatch?? Can''t match locations')
    return
end
    

for i=1:newN
    new_labels{i} = ERP.chanlocs(i).labels;
    new.chanlocs(i).labels = ERP.chanlocs(i).labels;
end

for i=1:oldN
    old_labels{i} = ERPold.chanlocs(i).labels;
end

% Remover existing chanloc field
ERP = rmfield(ERP,'chanlocs');
%clear ERP.chanlocs

% make new empty chanloc struct
for flds =fieldnames(ERPold.chanlocs)'
    ERP.chanlocs.(flds{1}) = [];
end



% iterate thru new once, try match, fill in a new array
for i=1:newN
    
    % Rewrite the label as it was before
    %   this means non-matching chans still have their labels there
    ERP.chanlocs(i).labels = new_labels{i};
    
    % Search for a label match
    match_here = strcmp(new_labels{i},old_labels);
    % this new_label matches the Mth old label, from position index
    
    if sum(match_here) == 1  % only deal with exactly one match, else blank
        
        match_old_idx = find(match_here == 1);
        ERP.chanlocs(i) = ERPold.chanlocs(match_old_idx);
    end
end

