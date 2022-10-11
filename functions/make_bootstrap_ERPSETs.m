% Make ERP averages based on bootstrapped (sampled-with-replacement)
% subsets of trials.
% axs July 17 - updated Aug 2021
% ams Oct 10 - updated Oct 2022 (works for epochs in multiple bins)
% INPUT
% Expects EEG as an already-processed bin-epoched EEGset with an attached
% eventlist.
%   nbootsets - requested number of bootstrapped ERP sets (default 100)
%   erpname - name appended to each bootstrapped ERP set ERP.erpname
%   artifacts_excluded_flag - The default of (1) will exclude artifact
%       tagged trials. Set to 0 to include artifact tagged trials.
%
% OUTPUT
% ALLBOOTERP - An ALLERP-like structure that includes all the bootstrap
% resampled ERP structures.
% bindatastruct - An optionally-returned structure with more boot info

function [ALLBOOTERP, bindatastruct] = make_bootstrap_ERPSETs(EEG, nbootsets, erpname, artifacts_excluded_flag)


try  
    assert(exist('EEG','var')==1)
    assert(numel(size(EEG.data))==3)
    assert(isfield(EEG,'EVENTLIST'))
catch
    beep
    error('Warning - make_BS_ERPSET requires a valid epoched EEG dataset and attached eventlist');
    return
end

if exist('nbootsets','var') == 0
    error('make_bootstrap_ERPSETs requires the number of bootstrap iterations as an explicit second argument');
    return
end

if exist('erpname','var') == 0
    erpname = EEG.setname;
end

[nelec, ntimes, neps] = size(EEG.data);
nbin = EEG.EVENTLIST.nbin;

if exist('artifacts_excluded_flag','var') == 0
    artifacts_excluded_flag = 1;
end

if artifacts_excluded_flag == 1
    allowed_artifact_flags = 0;
else
    allowed_artifact_flags = 0:256;
end

% Set up the trial indices
ti = 1:neps;
replacement = 1;


    
%% Prepare template ERPset
clear ALLBOOTERP BOOTERP
BOOTERP = buildERPstruct(EEG);




%% Get relevant epochs for each bin

N_valid_epochs = zeros(1,nbin); % This will hold number of valid epochs for each bin

% First, grab list of bin counts from eventlist
el = struct2table(EEG.EVENTLIST.eventinfo);
bin_list = el.bini;
if ~iscell(bin_list(1))
    bin_list = num2cell(el.bini); 
end

for bin = 1:nbin
    %bin_where(bin) = {ismember(bin_list,bin)};
    %bin_count(bin) = sum(ismember(bin_list,bin));
    
    bin_where(bin) = {cellfun(@(x) sum(ismember(x,bin)), bin_list)};
    bin_count(bin) = sum(cellfun(@(x) sum(ismember(x,bin)), bin_list));
    
    % prealloc bindatastruct(bin)(elec , times , eps)
    ep_data = zeros(nelec,ntimes,bin_count(bin));
    bindatastruct(bin).ep_data = ep_data;
    bindatastruct(bin).ep_list = [];
    bindatastruct(bin).bs_ep_list = [];
end

nbeps = numel(EEG.epoch);
valid_bin_ids = 1:nbin;

[boundary_times, boundary_number] = find_boundary_times(EEG);
if boundary_number
    boundary_str = ['Warning: ' num2str(boundary_number) ' boundary events remain in this EEG set'];
    disp(boundary_str)
end
boundary_names = {'-99','boundary'};


% Find the eventlist entries that correspond to a bin epoch
bin_list2 = el.bini;
if ~iscell(bin_list2(1))
    bin_list2 = num2cell(el.bini); 
end

%[el_where_binepoch] = find(el.bini>=0); %obtain indexes
[el_where_binepoch] = cellfun(@(x) any(x >= 0),bin_list2); %find(el.bini>=0);
[el_where_binepoch2] = find(el_where_binepoch>0); 

% Go thru the bin-epochs, save a list of epochs and data that will go in to
% the Bootstraps
for bepoch = 1:nbeps
    bep_mdata = EEG.EVENTLIST.eventinfo(el_where_binepoch2(bepoch));
    
    any_boundaries_here = ismember(bep_mdata.binlabel,boundary_names);
    any_boundaries_here2 = ismember(bep_mdata.codelabel,boundary_names); 
    
    % find the time-locking event in this bepoch
    % all epochs are already time-locked to TLE
%     if numel(bep_mdata.bini) == 1
%         tl_ev_here = 1;
%     else
%         tl_ev_here = find(cell2mat(EEG.epoch(bep_mdata.bepoch).eventlatency) == 0);
%     end
    
    % grab the bin-epoch info from the time-locked event only
    %bep_tl = bep_mdata(tl_ev_here);
    bep_tl = bep_mdata; 
    
    if ismember(bep_tl.bini, valid_bin_ids)
        if bep_tl.enable == 1
            if ismember(bep_tl.flag,allowed_artifact_flags)  % check artifact flags, exclude iff nessc.
                if any_boundaries_here == 0 & any_boundaries_here2 ==0 
                    
                    
                    b = bep_tl.bini;
                    N_valid_epochs(b) = N_valid_epochs(b) + 1;
                    
                    % get the data from event.epoch - NOT the eventlist bepoch
                    ep_data = EEG.data(:,:,bep_tl.bepoch);
                    
                    for b_ind = 1:numel(b) 
                        bindatastruct(b(b_ind)).ep_list = [bindatastruct(b(b_ind)).ep_list bep_tl.bepoch];
                        bindatastruct(b(b_ind)).ep_data(1:nelec,1:ntimes,N_valid_epochs(b(b_ind))) = ep_data;
                    end
                    
                end
            end
        end
        
        
        
    end
end

% clip the datamatrices to the actual size
% todo - Check  N_valid_epochs ==  bin_count, clip if not.      
        
        
%% Update the ERP template to include N_valid_epochs for each bin

%% Catch nbootsets=0 conventional average test case
if nbootsets == 0  % test a conventional (non-bootstrap draw) average through this pipeline 
    ALLBOOTERP(1) = BOOTERP;
     status_str = ['Making NON-bootstrap ERPset 1'];
    disp(status_str)
    
    bi = 1; % a single boot-indx
    
    for bin = 1:nbin
        bs_ti_here = 1:N_valid_epochs(bin);  % the bootstrap trial-indices used here
        
        bindatastruct(bin).bs_ep_list(bi,:) = bs_ti_here;
        data_for_avg = bindatastruct(bin).ep_data(:,:,bindatastruct(bin).bs_ep_list(bi,:));
        ALLBOOTERP(bi).bindata(:,:,bin) = mean(data_for_avg,3);
    end
     % ERPset housekeeping
    ALLBOOTERP(bi).erpname = ['boot_' num2str(bi) '_' erpname];
    ALLBOOTERP(bi).ntrials.accepted = N_valid_epochs;
    
    % return the single non-bootstrapped ERPSET in ALLBOOTERP
    return
    
end



%% Bootstrap draw

% Copy ERP template to all bootsets
ALLBOOTERP(1:nbootsets) = BOOTERP;

chk_valid = 0;
 
% Loop thru boot indices
% and make BS ERPsets from each
for bi = 1:nbootsets
    
    status_str = ['Making bootstrap ERPset ' num2str(bi) ' of ' num2str(nbootsets) ' ' erpname];
    disp(status_str)
    
    
    % get grab for each bin
    for bin = 1:nbin
        % Select trial indices for bootstrap using random sample with
        % replacement
        bs_ti_here = sort(randsample(1:N_valid_epochs(bin),round(N_valid_epochs(bin)),replacement));
        % the bootstrap trial-indices used here
        
        if chk_valid == 1
            bs_ti_here = 1:N_valid_epochs(bin);
            ALLBOOTERP(bi).erpname = ['boot_valid_' num2str(bi) '_' erpname];
        end
        
        
        bindatastruct(bin).bs_ep_list(bi,:) = bs_ti_here;
        
        data_for_avg = bindatastruct(bin).ep_data(:,:,bindatastruct(bin).bs_ep_list(bi,:));
        
        ALLBOOTERP(bi).bindata(:,:,bin) = mean(data_for_avg,3);
        
        
        
        
        
        
    end
    
    % ERPset housekeeping
    ALLBOOTERP(bi).erpname = ['boot_' num2str(bi) '_' erpname];
    ALLBOOTERP(bi).ntrials.accepted = N_valid_epochs;
    
end




%%
       
 