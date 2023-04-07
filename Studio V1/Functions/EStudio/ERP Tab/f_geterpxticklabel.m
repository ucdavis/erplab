
%%This function is to get the xticks and xtick lables if we plot the
%%waveform with two or more columns.


% *** This function is part of EStudio Toolbox ***
% Author: Guanghui ZHANG & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022




function [xtickout,xticklabelout] = f_geterpxticklabel(ERP,xticks_clomn,columNum,timeRange,Timet_step)

xtickout = [];
xticklabelout = [];
if nargin<2
    help f_geterpxticklabel
    return;
end

if nargin<3
    columNum =1;
end

%-- only display the waveform within the defined time range, e.g., [-200 800]
if nargin<4
    timeRange(1) = ERP.times(1);
    timeRange(2) = ERP.times(end);
end

if isempty(timeRange) || numel(timeRange) ==1
    timeRange(1) = ERP.times(1);
    timeRange(2) = ERP.times(end);
end


try
    tbin = 1000/ERP.srate;
catch
    
    disp('Sampling rate should be greater than 0 Hz');
    return;
end

if nargin <5
    xticks_clomn = [];
    [def Timet_step]= default_time_ticks_studio(ERP, timeRange);
end
% if ~isempty(def)
%     xticks_clomn = str2num(def{1,1});
%     while xticks_clomn(end)<=timeRange(2)
%         xticks_clomn(numel(xticks_clomn)+1) = xticks_clomn(end)+Timet_step;
%         if xticks_clomn(end)>timeRange(2)
%             xticks_clomn = xticks_clomn(1:end-1);
%             break;
%         end
%     end
% end

[xtick_time, Bindata] = f_get_erp_xticklabel_time(ERP, [ERP.times(1), ERP.times(end)],timeRange);


% Timet_step_pt = ceil(Timet_step/tbin);

timeRange_start = timeRange(1);
timeRange_end = timeRange(2);
if timeRange_start>0
    timeRange_start = ceil(timeRange_start);
    timeRange_end = ceil(timeRange_end);
elseif timeRange_start<0
    timeRange_start = floor(timeRange_start);
    timeRange_end = floor(timeRange_end);
end
try
Time_reso = 1000/ERP.srate;
catch
 Time_reso = 1;   
end
Timet_step_p = ceil(Timet_step/Time_reso);

if ~isempty(xticks_clomn)
    
    if columNum==1
        xtickout = xticks_clomn;
        for Numofxlabel = 1:numel(xticks)
            xticklabelout{Numofxlabel} = num2str(xticks(Numofxlabel));
        end
    elseif columNum>1
        
        xtickout = xticks_clomn;
        
        for Numofcolumn = 1:columNum-1
%             xtickout  = [xtickout,ones(1,numel(xticks_clomn))*(xtickout(end)+timeRange_end-xticks_clomn(end) +Timet_step) + (xticks_clomn-timeRange_start)+Numofcolumn*tbin];
         xtickout  = [xtickout,xticks_clomn+ Numofcolumn*(xtick_time(end)-xtick_time(1)+(Timet_step_p+1)*Time_reso)];%%changed by Guanghui Oct 2022
        end
        
        count = 0;
        for Numofcolumn = 1:columNum
            for Numofxlabel = 1:numel(xticks_clomn)
                count = count +1;
                xticklabelout{count} = num2str(xticks_clomn(Numofxlabel));
            end
        end
    end
end
