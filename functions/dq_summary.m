% Write data quality summary to Matlab Command Window
% axs Sept 2019, ERPLAB
function dq_summary(ERP,dq_subfield_name)

% Check and populate missing args
if exist('ERP','var') == 0 || isempty(ERP)
    ERP = evalin('base','ERP');
end

if exist('dq_subfield_name','var') == 0 || isempty(dq_subfield_name)
    dq_subfield_name = 'aSME';
end

if isfield(ERP,'dataquality') == 0
    warning('No Dataquality measures here')
    return
end

dq_measure_n = numel(ERP.dataquality);
if dq_measure_n == 1
    if isequal(ERP.dataquality(1).type,'empty')
        disp('No Data Quality measures here')
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
        disp('Could''nt find aSME here')
        return
    end
    
end

try
dq_data = ERP.dataquality(dq_subfield).data;

if any(isnan(dq_data(:)))
    %disp('Warning - NaNs in Data Quality measures')
end

median_here = median(dq_data(:),'omitnan');
[dist, median_loc_i] = min(abs(dq_data(:)-median_here));
[med_elec,med_tw,med_bin] = ind2sub(size(dq_data),find(dq_data == dq_data(median_loc_i)));

min_here = min(dq_data(:));
[min_elec,min_tw,min_bin] = ind2sub(size(dq_data),find(dq_data == min_here));

max_here = max(dq_data(:));
[max_elec,max_tw,max_bin] = ind2sub(size(dq_data),find(dq_data == max_here));


% Disp to Command Window
str_info = ['Data Quality measure of <a href="https://github.com/lucklab/erplab/wiki">' dq_names{dq_subfield} '</a>'];
disp(str_info)

str_median = ['Median value of ' num2str(dq_data(median_loc_i)) ' at elec ' ERP.chanlocs(med_elec).labels ', and time-window ' num2str(ERP.dataquality(dq_subfield).times(med_tw,1)) ':' num2str(ERP.dataquality(dq_subfield).times(med_tw,2)) 'ms, on bin ' num2str(med_bin) ', ' ERP.bindescr{med_bin}];
disp(str_median)
str_min = ['Min value of    ' num2str(min_here) ' at elec ' ERP.chanlocs(min_elec).labels ', and time-window ' num2str(ERP.dataquality(dq_subfield).times(min_tw,1)) ':' num2str(ERP.dataquality(dq_subfield).times(med_tw,2)) 'ms, on bin ' num2str(min_bin) ', ' ERP.bindescr{min_bin}];
disp(str_min)
str_max = ['Max value of    ' num2str(max_here) ' at elec ' ERP.chanlocs(max_elec).labels ', and time-window  ' num2str(ERP.dataquality(dq_subfield).times(max_tw,1)) ':' num2str(ERP.dataquality(dq_subfield).times(max_tw,2)) 'ms, on bin ' num2str(max_bin) ', ' ERP.bindescr{max_bin}];
disp(str_max)

catch
end