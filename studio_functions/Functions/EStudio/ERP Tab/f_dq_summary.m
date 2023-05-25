% Write data quality summary to Matlab Command Window
% axs April 2022, ERPLAB


function ERP_summary = f_dq_summary(ERP,dq_subfield_name)

% Check and populate missing args
if exist('ERP','var') == 0 || isempty(ERP)
    ERP = evalin('base','ERP');
end

if exist('dq_subfield_name','var') == 0 || isempty(dq_subfield_name)
    dq_subfield_name = 'aSME';
end

if isfield(ERP,'dataquality') == 0
%     beep;
%     warning('No Dataquality measures here');
    return;
end

dq_measure_n = numel(ERP.dataquality);
if dq_measure_n == 1
    if isequal(ERP.dataquality(1).type,'empty')
%         beep;
%         disp('No Data Quality measures here')
    else
    dq_subfield = 1;
    end
else
    for i=1:dq_measure_n
        dq_names{i} = ERP.dataquality(i).type;
    end
    if any(strcmpi(dq_names,dq_subfield_name))
        dq_subfield = find(strcmpi(dq_names,dq_subfield_name) == 1);
    else
%         beep;
        disp('Could not find aSME here');
        return
    end
    
end
ERP_summary = {0 0 0; 0 0 0; [0 0] [0 0] [0 0]; 0 0 0};
try
dq_data = ERP.dataquality(dq_subfield).data;

if any(isnan(dq_data(:)))
    beep;
%     disp('Warning - NaNs in Data Quality measures')
    return;
end

if isempty(dq_data)
%      beep;
%     disp('Warning - No value was found in Data Quality measures')
    return;
end
median_here = median(dq_data(:),'omitnan');
[dist, median_loc_i] = min(abs(dq_data(:)-median_here));
[med_elec,med_tw,med_bin] = ind2sub(size(dq_data),find(dq_data == dq_data(median_loc_i)));

min_here = min(dq_data(:));
[min_elec,min_tw,min_bin] = ind2sub(size(dq_data),find(dq_data == min_here));

max_here = max(dq_data(:));
[max_elec,max_tw,max_bin] = ind2sub(size(dq_data),find(dq_data == max_here));

ERP_summary{1,1} = dq_data(median_loc_i);
ERP_summary{1,2} = min_here;
ERP_summary{1,3} = max_here;

ERP_summary{2,1} = med_elec;
ERP_summary{2,2} = min_elec;
ERP_summary{2,3} = max_elec;

ERP_summary{3,1} = [ERP.dataquality(dq_subfield).times(med_tw,1),ERP.dataquality(dq_subfield).times(med_tw,2)];
ERP_summary{3,2} = [ERP.dataquality(dq_subfield).times(min_tw,1),ERP.dataquality(dq_subfield).times(med_tw,2)];
ERP_summary{3,3} = [ERP.dataquality(dq_subfield).times(max_tw,1),ERP.dataquality(dq_subfield).times(max_tw,2)];

ERP_summary{4,1} = med_bin;
ERP_summary{4,2} = min_bin;
ERP_summary{4,3} = max_bin;

catch
end