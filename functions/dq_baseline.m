% Add baseline measure as Data Quality measure
% part of the ERPLAB Toolbox
% axs May 2019
%
% Format:
%  ERP = dq_baseline(ERP);
%    or ERP = dq_baseline(ERP,start_time, end_time, subtract_mean_flag)
%
% INPUT:      * - mandatory
%  * ERP  - an ERP structure
%    
function [baseline_SD] = dq_baseline(ERP, start_ms, end_ms, subtract_mean_flag)

% Check input
try
    assert(isfield(ERP,'bindata'))
catch  
    warning('Making Data Quality baseline measures requires an ERPSET')
    beep
    return
end


% Populate any empty args with defaults
if exist('start_ms','var') == 0 || isempty(start_ms)
    start_ms = ERP.times(1);
end
if exist('end_ms','var') == 0 || isempty(end_ms)
    end_ms = 0;
end
if exist('subtract_mean_flag','var') == 0 || isempty(subtract_mean_flag)
    subtract_mean_flag = 1;
end


% Check desired times are within availible times
good_start = start_ms >= ERP.times;
good_end = end_ms <= ERP.times;
try
    assert(any(good_start)==1)
    assert(any(good_end)==1)
catch
    beep
    warning('The times requested for Data Quality baseline are not available in this ERPset.')
    return
end

start_dp = find(abs(ERP.times-start_ms)==min(abs(ERP.times-start_ms))); % datapoint closest to desired ms
start_dp = start_dp(1); % if it's a tie, take the first element
end_dp = find(abs(ERP.times-end_ms)==min(abs(ERP.times-end_ms)));
end_dp = end_dp(1);

% 
    
b_sd_1 =   std(ERP.bindata(1,start_dp:end_dp,1));

baseline_data = ERP.bindata(:,start_dp:end_dp,:);




bl_sd = std(baseline_data,0,2);

if subtract_mean_flag
    bl_means = mean(baseline_data,2);
    bl_sd = bl_sd - bl_means;
end

% quick plot of baseline sd
%imagesc(squeeze(bl_sd))

baseline_SD = bl_sd;


