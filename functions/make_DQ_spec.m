% Data Quality specification snippet to populate default values
% and verify times are in range
% axs June 2019, ERPLAB
function DQ_spec_out = make_DQ_spec(timelimits_ms)


% Check and populate missing args
if exist('timelimits_ms','var') == 0 || isempty(timelimits_ms)
    
    try
        evalin('base','timelimits = [EEG.xmin EEG.xmax]');
        timelimits_ms = timelimits * 1000;
        
    catch
        %warning('Couldn''t find time limits for DQ range, trying defaults')
        timelimits_ms = [-200 500];
    end
end




% Declare time ranges
win_size = 100; %ms
tw_neg = sort([0:-win_size:timelimits_ms(1)]);
tw_pos = [0:win_size:timelimits_ms(2)];


tw_starts = unique([tw_neg tw_pos]);
tw_ends = tw_starts + win_size;

tw_labels = 1:numel(tw_starts);
tw = [tw_labels; tw_starts; tw_ends]';

% Build spec with these times
DQ_defaults(1).type = 'Baseline Measure - SD';
DQ_defaults(1).times = [];
DQ_defaults(3).comments = [];
DQ_defaults(2).type = 'Point-wise SEM';
DQ_defaults(2).times = [];
DQ_defaults(3).comments = [];
DQ_defaults(3).type = 'aSME';
DQ_defaults(3).times = tw;
DQ_defaults(3).comments = [];

DQ_spec_out = DQ_defaults;