% Summarize erpset
% axs Apr 2019
% ERPLAB Toolbox
% https://github.com/lucklab/erplab
function info_out = erpset_summary(ALLERP,CURRENTERP)

info_out = '';

% input check
if exist('ALLERP','var') == 0
    ALLERP = evalin('base','ALLERP');  % I dislike grabbing arguments from base workspace, but allows a lazy call here.
end

if exist('CURRENTERP','var') == 0
    CURRENTERP = evalin('base','CURRENTERP');
end


% ver check?
[Matlab_release] = version('-release');
release_num = str2double(Matlab_release(1:4));
if strcmpi(Matlab_release(5),'b') == 1
    release_num = release_num + 0.5;
end

if release_num < 2013.5
    disp(ALLERP)
    disp('Please upgrade Matlab to see more info in Matlab Tables')
    disp('(Tables introduced in R2013b)')
    return
end

% Check not empty, nor l=1
%
%
n_ERPsets = numel(ALLERP);


% Catch empty or l=1 cases
if n_ERPsets == 0
    disp('No ERPsets currently loaded')
    return
elseif n_ERPsets == 1
    disp('Showing the one currently loaded ERPset:')
    disp(ALLERP);
    return
end

n_ERP_str = ['There are ' num2str(n_ERPsets) ' ERPsets currently loaded'];
disp(n_ERP_str)

% Make initial table 
ALLERP_T = struct2table(ALLERP);

% Remove some fields from plot
keep_fields = {'erpname','nchan','nbin'};
info_T = ALLERP_T(:,keep_fields);


% Reduce some fields to be more concise
got_locs = zeros(n_ERPsets,1);
DQ = zeros(n_ERPsets,1);
erpset_idx = 1:n_ERPsets;
Active_ERPset = zeros(n_ERPsets,1);
Active_ERPset(CURRENTERP) = 1;
trials_per_bin = {};

for i=1:n_ERPsets
    locs_here = ALLERP(i).chanlocs(1).sph_phi;
    if isempty(locs_here) == 0
        got_locs(i) = 1;
    end
    
    DQ(i) = numel(ALLERP(i).dataquality);
    trials_per_bin{i} = num2str(ALLERP(i).ntrials.accepted);
    
end


%disp(info_T)


ERPset_number = erpset_idx';
trials_per_bin = trials_per_bin';

info_T1 = table(ERPset_number,Active_ERPset);
info_T_tail = table(got_locs,DQ,trials_per_bin);

info_T2 = [info_T1 info_T info_T_tail];
disp('ALLERP includes:')
disp(info_T2)

curr_txt = ['The current active ERPset is ERPset ' num2str(CURRENTERP)];
disp(curr_txt);

info_out = info_T2;