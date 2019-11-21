% Checks ERPSETs for DQ measure coverage
% cautions if desired is not availible
% axs July 2019
%
% INPUT
%   ALLERP - Structure of ERP sets
%   desired_DQ_measures - cell array of strings, text name of desired
%   measures
function DQ_ok = check_DQ_measures(ALLERP, desired_DQ_measures)

% Check and populate missing args
if exist('desired_DQ_measures','var') == 0 || isempty(desired_DQ_measures)
    desired_DQ_measures = {'Baseline','SEM','aSME'};
end


if isfield(ALLERP,'dataquality') == 0
    warning('No DQ measures here')
    DQ_ok = 0;
    return
end

% clear DQ_here str in_this_set

% make a 2D cell array of what DQ measures are in this ALLERP struct
% sets x measures
n_sets = numel(ALLERP);
n_desired_dqm = numel(desired_DQ_measures);

for ds = 1:n_sets
    n_dq_here = numel(ALLERP(ds).dataquality);
    for dqm = 1:n_dq_here
        DQ_here{ds,dqm} = ALLERP(ds).dataquality(dqm).type;
    end
end


% now, see which of the desired measures are present in each set
% sets x desired_measure
max_dqm = size(DQ_here,2);
for ds = 1:n_sets
    for dqm = 1:n_desired_dqm
       in_this_set(ds,dqm) = any(strcmpi(DQ_here(ds,:),desired_DQ_measures(dqm)));
    end
end

% which desired measures present in ALL
% describe
dqm_met = all(in_this_set,1)==1;
sets_complete = all(in_this_set,2)==1;

if all(in_this_set(:))
    DQ_ok = 1;
    write_out = 0;
else
    DQ_ok = 0;
    write_out = 1;
end


if write_out
    str{1} = ['There are ' num2str(n_sets) ' sets'];
    str{2} = ['There are ' num2str(n_desired_dqm) ' desired DQ measures'];
    str{3} = ['All sets match desired measures in ' num2str(sum(all(in_this_set,1)==1)) ' of ' num2str(n_desired_dqm) ' desired DQ measures'];
    str{4} = ['All desired measures are present in ' num2str(sum(all(in_this_set,2)==1)) ' of ' num2str(n_sets) ' sets'];
    
    disp(str')
    disp(in_this_set)
    
    
end
