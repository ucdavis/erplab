% Convert bin-epoched EEG to a bin-organized EEG structure
% may be useful for subsequent decoding scripts
% axs 2020
%
% Inputs:
%    EEG - an EEG set, which must have been processed with ERPLAB, with
%         valid EventList, and be bin-epoched EEG data
%    write_file_path - optional full path to write file to, string
%
% Outputs:
%  binorgEEG - reorganisation of the EEG data, around the ERPLAB bins
%              with the data in binorgEEG.binwise_data(bin_n).data(elec,timepoints,trial_n)
function binorgEEG = binepEEG_to_binorgEEG(EEG, write_file_path)

dim_data = numel(size(EEG.data));
if dim_data ~= 3
    error('binepEEG_to_binorgEEG works on bin-epoched EEG. Please ensure data is epoched (not continuous) and has bin labels');
end

% Prepare info for averager call
artif = 1; stderror = 1; excbound = 1;

% Call ERP Averager subfunction, populating the epoch_list

[ERP2, EVENTLISTi, countbiORI, countbinINV, countbinOK, countflags, workfname,epoch_list] = averager(EEG, artif, stderror, excbound);


% We now have epoch_list, which has a list of 'good' bepoch indecies to use
% epoch_list(1).good_bep_indx(:) has those trials for bin 1
% epoch_list(2).good_bep_indx(:) has those trials for bin 2, etc
nbin = ERP2.nbin;

% Prepare binorg data structure
for bin = 1:nbin
    
    binorgEEG.binwise_data(bin).data = EEG.data(:,:,epoch_list(bin).good_bep_indx);
    binorgEEG.n_trials_this_bin(bin) = numel(epoch_list(bin).good_bep_indx);
    
end

% Now, the data from each trial is saved, reorganized by bin, such that:
% for bin X
%  binorgEEG.binwise_data(X).data(:,:,1) gives all elecs and all
%  timepoints for the 1st trial of bin X


if ischar(write_file_path)
    % If a string of a full write file path is provided in arg, save it there
    save(write_file_path,'binorgEEG')
    
elseif write_file_path == 1
    % UI file pick when write_file_path == 1
    [file_name, file_path] = uiputfile('*.mat','Please pick a path to save the Bin-Organized EEG data');
    write_file_path = [file_path file_name];
    save(write_file_path,'binorgEEG');
end