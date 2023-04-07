
% PURPOSE  :	form the time points based on the defined time range and xtick range;
%
% FORMAT   :
%
%   [xtick_time, bindata] = f_get_erp_xticklabel_time(ERP, timerange,xtickrange)

%
%
% INPUTS   :
%ERP        - ERP structures (ERPsets)

%timerange       - time range where we want to display the wave e.g., [-200 800].
%                  In fact, it is fixed that is equal to [ERP.time(1),ERP.times(end)].

%xtickrange      - x-axis limits, e.g., [-300 900]

% OUTPUTS   :
%
%xtick_time: includes the sampling points for the x-axis limits
%bindata: the length of the "bindata" is equal to that of xtickrange.



% *** This function is part of EStudio Toolbox ***
% Author: Guanghui Zhang
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022


function [xtick_time, bindata] = f_get_erp_xticklabel_time(ERP, timerange,xtickrange)


if nargin<1
    xtick_time = [];
    bindata = [];
    return;
end

if nargin<2
    timerange(1) = ERP.times(1);
    timerange(2) = ERP.times(end);
end

if numel(timerange) ==1
    xtick_time = [];
    bindata = [];
    return;
end


if timerange(1)>= timerange(2)
    xtick_time = [];
    bindata = [];
    return;
end



if nargin<3
    xtickrange(1) = ERP.times(1);
    xtickrange(2) = ERP.times(end);
end


if numel(xtickrange) ==1
    xtick_time = [];
    bindata = [];
    return;
end


if xtickrange(1)>= xtickrange(2)
    xtick_time = [];
    bindata = [];
    return;
end

time_bin = 1000/ERP.srate;

[xxx, latsamp, latdiffms] = closest(ERP.times, timerange);
time_range_times = ERP.times(latsamp(1):latsamp(2));


if (xtickrange(1)< timerange(1)) && (xtickrange(2)<= timerange(2)) %% case 1
    [xxx, latsamp, latdiffms] = closest(ERP.times, [timerange(1) xtickrange(2)]);
    xtick_time = ERP.times(latsamp(1):latsamp(2));
    for ii = 1:1000000
        xtick_time_first = xtick_time(1)-time_bin;
        if xtickrange(1) <= xtick_time_first
            xtick_time = [xtick_time_first,xtick_time];
        else
            break;
        end
    end
    
elseif (xtickrange(1)< timerange(1)) && (xtickrange(2)> timerange(2))%% case 2
    xtick_time = time_range_times;
    for ii = 1:1000000% loop for the left edge
        xtick_time_first = xtick_time(1)-time_bin;
        if xtickrange(1) <= xtick_time_first
            xtick_time = [xtick_time_first,xtick_time];
        else
            break;
        end
    end
    
    for ii = 1:1000000%Loop for the right edge
        xtick_time_last = xtick_time(end)+time_bin;
        if xtickrange(2) >= xtick_time_last
            xtick_time = [xtick_time,xtick_time_last];
        else
            break;
        end
    end
    
    
elseif (xtickrange(1)>= timerange(1)) && (xtickrange(2)> timerange(2))%% case 3
    
    [xxx, latsamp, latdiffms] = closest(ERP.times, [xtickrange(1) timerange(2)]);
    xtick_time = ERP.times(latsamp(1):latsamp(2));
    
    for ii = 1:1000000%Loop for the right edge
        xtick_time_last = xtick_time(end)+time_bin;
        if xtickrange(2) >= xtick_time_last
            xtick_time = [xtick_time,xtick_time_last];
        else
            break;
        end
    end
    
elseif  (xtickrange(1)>= timerange(1)) && (xtickrange(2)<= timerange(2))%%case 4: if the xtick range is within the defined time range
    [xxx, latsamp, latdiffms] = closest(ERP.times, xtickrange);
    xtick_time =  ERP.times(latsamp(1):latsamp(2));
end

if abs(xtick_time(1))>abs(xtickrange(1))%%check the first element
    xtick_time(1) = [];
end

if abs(xtick_time(end))>abs(xtickrange(2))%% check the last element
    xtick_time(end) = [];
end

%%------------------------Adjust the data based on the xtick time range-------------------------
bindata = nan(size(ERP.bindata,1),numel(xtick_time),size(ERP.bindata,3));

if (xtickrange(1)< timerange(1)) && (xtickrange(2)<= timerange(2)) %% case 1
    [xxx, latsamp_xtick, latdiffms] = closest(xtick_time,[timerange(1),xtick_time(end)]);
    [xxx, latsamp_time, latdiffms] = closest(ERP.times,[timerange(1),xtick_time(end)]);
    bindata(:,latsamp_xtick(1):latsamp_xtick(2),:) = ERP.bindata(:,latsamp_time(1):latsamp_time(2),:);
    
elseif (xtickrange(1)< timerange(1)) && (xtickrange(2)> timerange(2))%% case 2
    [xxx, latsamp_time, latdiffms] = closest(ERP.times,[timerange(1),timerange(end)]);
    [xxx, latsamp_xtick, latdiffms] = closest(xtick_time,[ERP.times(latsamp_time(1)),ERP.times(latsamp_time(2))]);
    bindata(:,latsamp_xtick(1):latsamp_xtick(2),:) = ERP.bindata(:,latsamp_time(1):latsamp_time(2),:);
    
elseif (xtickrange(1)>= timerange(1)) && (xtickrange(2)> timerange(2))%% case 3
    [xxx, latsamp_xtick, latdiffms] = closest(xtick_time,[xtick_time(1),timerange(2)]);
    [xxx, latsamp_time, latdiffms] = closest(ERP.times,[xtick_time(1),timerange(2)]);
    if numel(latsamp_xtick(1):latsamp_xtick(2)) -numel(latsamp_time(1):latsamp_time(2)) ==1
        latsamp_xtick(2) = latsamp_xtick(2)-1;
    end
    
    bindata(:,latsamp_xtick(1):latsamp_xtick(2),:) = ERP.bindata(:,latsamp_time(1):latsamp_time(2),:);
    
elseif  (xtickrange(1)>= timerange(1)) && (xtickrange(2)<= timerange(2))%%case 4: if the xtick range is within the defined time range
    [xxx, latsamp, latdiffms] = closest(ERP.times, [xtick_time(1),xtick_time(end)]);
    bindata= ERP.bindata(:,latsamp(1):latsamp(2),:);
end


end



