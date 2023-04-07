
%%ERPbindata contains the values for each point and it should be is column
%%vector. e.g., ERPbindata = [1 2 4 5 3 2 5 6 3 2 5 6 6 ....]


%%Time indexes for each time point e.g., timesrange =
%%[-199.21875,-195.3125,-191.40625,-187.5,-183.59375,-179.6875,-175.78125,-171.875,-167.96875,....]
%%if sampling rate is 256

%%time window which is to display the ERPwave, e.g., timew: [-100 700]


%%fs sampling rate of the data, e.g., fs =256


% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022


function [Xtimerange, bindata] = f_adjustbindtabasedtimedefd(ERPbindata, timesrange,timew,fs)

Xtimerange = [];
bindata = [];
if nargin<1
    help f_adjustbindtabasedtimedefd;
    return;
end

if nargin<2
    
    return;
end

if numel(unique(timesrange)) ==1
    return;
end

if timesrange(1)>= timesrange(end)
    return;
end



if nargin<3
    timew(1)=timerange(1);
    timew(2)=timerange(numel(timerange));
end
if isempty(timew) || numel(unique(timew))~=2
    timew(1)=timerange(1);
    timew(2)=timerange(numel(timerange));
end

if nargin<4
    fs = ceil(1000/(timesrange(2)-timesrange(1)));
end

deffs = ceil(1000/(timesrange(2)-timesrange(1)));

if deffs~=fs
    disp('The defined sampling rate dosenot match with the inputed "timesrange"');
    return;
end

if numel(timew) ==1
    beep;
    disp('"timew" has two elements!!!');
    return;
end

if timew(1)>= timew(2)
    return;
end

ERPbindata = reshape(ERPbindata,1,[]);%% reshape the data into a column vector
if numel(ERPbindata) ~=numel(timesrange)
    beep;
    disp('The number of time points for the inputed data doesnot match with "timesrange"');
    return;
end

time_bin = 1000/fs;

% [xxx, latsamp, latdiffms] = closest(ERP.times, timerange);
% time_range_times = ERP.times(latsamp(1):latsamp(2));


if (timew(1)< timesrange(1)) && (timew(2)<= timesrange(end)) %% case 1
    [xxx, latsamp, latdiffms] = closest(timesrange, timew);
    Xtimerange = timesrange(latsamp(1):latsamp(2));
    for ii = 1:1000000
        Xtimerange_first = Xtimerange(1)-time_bin;
        if timew(1) <= Xtimerange_first
            Xtimerange = [Xtimerange_first,Xtimerange];
        else
            break;
        end
    end
    
elseif (timew(1)< timesrange(1)) && (timew(2)> timesrange(end))%% case 2
    Xtimerange = timesrange;
    for ii = 1:1000000% loop for the left edge
        Xtimerange_first = Xtimerange(1)-time_bin;
        if timew(1) <= Xtimerange_first
            Xtimerange = [Xtimerange_first,Xtimerange];
        else
            break;
        end
    end
    for ii = 1:1000000%Loop for the right edge
        Xtimerange_last = Xtimerange(end)+time_bin;
        if timew(2) >= Xtimerange_last
            Xtimerange = [Xtimerange,Xtimerange_last];
        else
            break;
        end
    end
    
elseif (timew(1)>= timesrange(1)) && (timew(2)> timesrange(end))%% case 3
    
    [xxx, latsamp, latdiffms] = closest(timesrange, [timew(1) timesrange(end)]);
    Xtimerange = timesrange(latsamp(1):latsamp(2));
    
    for ii = 1:1000000%Loop for the right edge
        Xtimerange_last = Xtimerange(end)+time_bin;
        if timew(2) >= Xtimerange_last
            Xtimerange = [Xtimerange,Xtimerange_last];
        else
            break;
        end
    end
    
elseif  (timew(1)>= timesrange(1)) && (timew(2)<= timesrange(end))%%case 4: if the xtick range is within the defined time range
    [xxx, latsamp, latdiffms] = closest(timesrange, timew);
    Xtimerange =  timesrange(latsamp(1):latsamp(2));
end

if abs(Xtimerange(1))>abs(timew(1))%%check the first element
    Xtimerange(1) = [];
end

if abs(Xtimerange(end))>abs(timew(2))%% check the last element
    Xtimerange(end) = [];
end

%%------------------------Adjust the data based on the xtick time range-------------------------
bindata = nan(1,numel(Xtimerange));

if (timew(1)< timesrange(1)) && (timew(2)<= timesrange(end)) %% case 1
    [xxx, latsamp_xtick, latdiffms] = closest(Xtimerange,[timesrange(1),Xtimerange(end)]);
    
    [xxx, latsamp_time, latdiffms] = closest(timesrange,[timesrange(1),Xtimerange(end)]);
    bindata(1,latsamp_xtick(1):latsamp_xtick(2)) = ERPbindata(1,latsamp_time(1):latsamp_time(2));
    
elseif (timew(1)< timesrange(1)) && (timew(2)> timesrange(end))%% case 2
    [xxx, latsamp_xtick, latdiffms] = closest(Xtimerange,[timesrange(1),timesrange(end)]);
    bindata(1,latsamp_xtick(1):latsamp_xtick(2)) = ERPbindata;
    
elseif (timew(1)>= timesrange(1)) && (timew(2)> timesrange(end))%% case 3
    [xxx, latsamp_xtick, latdiffms] = closest(Xtimerange,[Xtimerange(1),timesrange(end)]);
    [xxx, latsamp_time, latdiffms] = closest(timesrange,[Xtimerange(1),timesrange(end)]);
    
    if numel(latsamp_xtick(1):latsamp_xtick(2)) -numel(latsamp_time(1):latsamp_time(2)) ==1
        latsamp_xtick(2) = latsamp_xtick(2)-1;
    end
    bindata(1,latsamp_xtick(1):latsamp_xtick(2)) = ERPbindata(1,latsamp_time(1):latsamp_time(2));
elseif  (timew(1)>= timesrange(1)) && (timew(2)<= timesrange(end))%%case 4: if the xtick range is within the defined time range
    [xxx, latsamp, latdiffms] = closest(timesrange, [Xtimerange(1),Xtimerange(end)]);
    bindata= ERPbindata(1,latsamp(1):latsamp(2));
end
end



