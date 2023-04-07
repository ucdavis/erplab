% Data Quality specification snippet to populate default values
% and verify times are in range
% axs June 2019, ERPLAB
% ams Dec 2022, ERPLAB update: incl'd smaller window for short epoch(<100ms)
function DQ_spec_out = make_DQ_spec(timelimits_ms)


% Check and populate missing args
if exist('timelimits_ms','var') == 0 || isempty(timelimits_ms)
    
    try
        evalin('base','timelimits = [EEG.xmin EEG.xmax];');
        timelimits_ms = timelimits * 1000;
        
    catch
        %warning('Couldn''t find time limits for DQ range, trying defaults')
        timelimits_ms = [-200 500];
    end
end




% Prepare time range and time-windows
win_size = 100; %ms
%     If crossing zero, ensure windows are centered on zero
if (min(timelimits_ms) < 0) && (max(timelimits_ms) > 0)
    % if crossing zero, grow 0:-win_size:min and 0:win_size:max
    
    tw_neg = sort([0:-win_size:timelimits_ms(1)]);
    tw_pos = [0:win_size:timelimits_ms(2)];
    
    % concatenate
    tw_starts = unique([tw_neg tw_pos]);
    tw_ends = tw_starts + win_size;
    
else
    % else, grow min:win_size:term
    
    tw_starts = min(timelimits_ms):win_size:max(timelimits_ms);
    tw_ends = tw_starts + win_size;
end

% remove time-windows out of range
if tw_ends(end) > max(timelimits_ms)
    tw_starts(end) = [];
    tw_ends(end) = [];
end

% for tw less than 100ms 
if isempty(tw_starts) & isempty(tw_ends) 
    win_size = 2;  %considers typical auditory brainstem responses (ABRs) (eg, 25ms epochs)
                   %thanks Dr. Kelsey Mankel! 
    if (min(timelimits_ms) < 0) && (max(timelimits_ms) > 0)
        % if crossing zero, grow 0:-win_size:min and 0:win_size:max
        
        tw_neg = sort([0:-win_size:timelimits_ms(1)]);
        tw_pos = [0:win_size:timelimits_ms(2)];
        
        % concatenate
        tw_starts = unique([tw_neg tw_pos]);
        tw_ends = tw_starts + win_size;
        
    else
        % else, grow min:win_size:term
        
        tw_starts = min(timelimits_ms):win_size:max(timelimits_ms);
        tw_ends = tw_starts + win_size;
    end
    
    % remove time-windows out of range
    if tw_ends(end) > max(timelimits_ms)
        tw_starts(end) = [];
        tw_ends(end) = [];
    end

    
end



% make labels
root_str = 'aSME at ';
for i = 1:numel(tw_starts)
    tw_labels{i} = [root_str num2str(tw_starts(i)) ' to ' num2str(tw_ends(i)) ];
end

root_str = 'aSD Across Trials at ';
for i = 1:numel(tw_starts)
    tw_labels_sd{i} = [root_str num2str(tw_starts(i)) ' to ' num2str(tw_ends(i)) ];
end

tw = [tw_starts; tw_ends]';

% Build spec with these times
DQ_defaults(1).type = 'Baseline Measure - SD';

DQ_defaults(2).type = 'Point-wise SEM';

DQ_defaults(3).type = 'aSME';
DQ_defaults(3).times = tw;
DQ_defaults(3).time_window_labels = tw_labels;
DQ_defaults(3).comments = [];

%add SD across trials (01/05/22)
DQ_defaults(4).type = 'SD Across Trials';
DQ_defaults(4).times = tw;
DQ_defaults(4).time_window_labels = tw_labels_sd;
DQ_defaults(4).comments=[]; 


DQ_spec_out = DQ_defaults;