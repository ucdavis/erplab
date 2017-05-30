% PURPOSE: Finds and removes additional eventcodes
%          If the subject has pressed a key several times, this removes the
%          later event codes and keeps only the first one.
%
%          Operates on the EEG.event structure in continuous EEG
%
% FORMAT
%
% EEG = remove_response_mistakes(EEG, Stim_codes, Response_codes, print_report)
%
%   Stim_codes and Response_codes should be 1xN numeric arrays, specifying
%   the eventcodes you tag as stimulus (once per 'trial') and the
%   eventcodes that are indicating user response.
%
%   ** Any responses after the first after a stimulus are deleted **
%
% Author: Andrew X Stewart
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% March 2017
%

function EEG = remove_response_mistakes(EEG, Stim_codes, Response_codes, print_report)

switch nargin
    
    case 4
        % all input specified
    case 3
        print_report = 1;
    otherwise
        warning('Please check remove_response_mistakes(EEG, Stim_code_array, Response_code_array)');
        return
        
        
end


% For example
% Stim_r = [21,112,12,121];
% Stim_f = [11,122,22,111];
%
% Stim_codes = [21,112,12,121,11,122,22,111]
%
% Response_codes = [8,9]



evN = numel(EEG.event);


% Check numeric or string type
if ischar(EEG.event(1).type)
    ec_type_is_str = 1;
else
    ec_type_is_str = 0;
end


trial_stim_N = 0;
errant_codes = [];
trials = [];
r_per_t = [];

% Create a new eventcode matrix, with a line for each trial
% Trial start indicated by finding a Stim eventcode
for i = 1:evN
    if ec_type_is_str
        ec_here = str2double(EEG.event(i).type);
    else
        ec_here = EEG.event(i).type;
    end
    
    if ismember(ec_here,Stim_codes)
        
        trial_stim_N = trial_stim_N + 1;
        
        found_next_stim = 0;
        i_next = i + 1;
        ec_train = 0;
        
        % Keep iterating til the following stim code is found
        while found_next_stim == 0 && i_next < evN
            if ec_type_is_str
                ec_next = str2double(EEG.event(i_next).type);
            else
                ec_next = EEG.event(i_next).type;
            end
            
            if ismember(ec_next,Stim_codes)
                found_next_stim = 1;
            elseif ismember(ec_next,Response_codes)
                ec_train = ec_train + 1;
                
                % Record extra
                if ec_train > 1
                    errant_codes = [errant_codes i_next];
                end
                
            end
            i_next = i_next + 1;
        end
        
        stim_here = [ec_here, EEG.event(i).latency/EEG.srate, ec_train];
        trials(trial_stim_N,:) = stim_here;
    end
end

%


% Now that we have each 'trial', we want to count the Responses made per
% trial
r_per_t_bins = unique(trials(:,3));

for i=1:numel(r_per_t_bins)
    matching_r = ismember(trials(:,3),r_per_t_bins(i));
    r_per_t(i,:) = [r_per_t_bins(i) sum(matching_r)];
end


if print_report
    col_names = 'Responses-per-trial | Count';
    info1 = ['There are ' num2str(length(trials)) ' trials identified from these stimulus codes'];
    info2 = ['There are ' num2str(numel(errant_codes)) ' additional responses'];
    
    disp(col_names)
    disp(r_per_t)
    disp(info1)
    disp(info2)
end


% Now let's delete the extra response codes
% (count backwards to avoid messing up the struct array
for i=numel(errant_codes):-1:1
    EEG.event(errant_codes(i)) = [];
end




