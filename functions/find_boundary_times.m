% PURPOSE:
%   return a list of times at which boundary event occur
% FORMAT:
%   [boundary_times, num_boundaries] = find_boundary_times(EEG)
% OUTPUT:
%    boundary_times - a vector of times (latencies since start), one for
%    each boundary event.
%    num_boundaries - the number of found boundaries
%
% *** This function is part of ERPLAB Toolbox ***
% Andrew X Stewart
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2018
function [boundary_times, num_boundaries] = find_boundary_times(EEG)

% make array to keep track of boundaries
evT = struct2table(EEG.event);
boundary_times = 0;
num_boundaries = 0;

% Boundaries can be indicated with -99 or 'boundary'
% let's presume that the variable type of EEG.event.type reveals which
if isnumeric(evT.type(1))
    numeric_events = 1;
else
    numeric_events = 0;
end

if numeric_events == 1
    bound_evs = evT.type==-99;
else
    bound_evs = strcmp(evT.type,'boundary');
end

num_boundaries = sum(bound_evs);
where_bound = find(bound_evs==1);

if num_boundaries > 0
    boundary_times = zeros(num_boundaries,1);
    if num_boundaries >= 1  % when there is at least one boundary
        for i=1:num_boundaries
            boundary_times(i) = evT.latency(where_bound(i));
        end
    end
end