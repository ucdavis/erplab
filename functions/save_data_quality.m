% write data quality substructure to file
% part of the ERPLAB Toolbox
% axs Apr 2019
%
% Format:
%  save_data_quality(ERP, 'dq.mat')
%    or save_data_quality(ERP,filename,format_flag)
%
% INPUT:      * - mandatory
%  * ERP  - an ERP structure, which must contain a ERP.dataquality substruct
%    filename - a string which will specify the filename of the new saved
%         file. This can optionally contain a full path, and/or extension.
%         Default of ERP.filepath
%    format - String of 'mat', 'xls', or 'xlsx', specifying the requsted
%         format for the new save files. Default of 'mat'.
%    dq_subfield - which entry of the dq substructure to write.
%         default of 1
function save_data_quality(ERP, filename, format, dq_subfield)

% Check input
try
    assert(isfield(ERP,'dataquality'))
    assert(isempty(ERP.dataquality.data)==0)
catch
    warning('Problem saving ERP data quality. Missing info?')
    return
end

format_was_empty = 0;
if exist('format','var') == 0 || isempty(format)
    format_was_empty = 1;
    format = 'mat';
end

spreadsheet_like_formats = {'xls','xlsx'};
if ismember(format, spreadsheet_like_formats)
    write_spreadsheet = 1;
end


if exist('dq_subfield','var') == 0 || isempty(dq_subfield)
    dq_subfield = 1;
end

if exist('filename','var') == 0 || isempty(filename)
    
    filename = [ERP.filepath filesep ERP.erpname '_dataquality.' format];
end



[fpath, fname, ext] = fileparts(filename);

% check path exists, not overwrite
if isempty(fpath)
    filename = [ERP.filepath filesep fname ext];
    [fpath, fname, ext] = fileparts(filename);
end

if isempty(ext)
    filename = [filename '.' format];
end


try
    assert(exist(fpath,'dir')==7)  % check path is valid
catch
    warning('Problem saving ERP data quality - this path does not exist')
    return
end


% write section

if strcmpi(format,'mat')
    dataquality = ERP.dataquality(dq_subfield);
    save(filename,'dataquality')
    
    
elseif write_spreadsheet
    % set up data to write to spreadsheet
    dq = ERP.dataquality(dq_subfield);
    dq_fields = fieldnames(ERP.dataquality(dq_subfield));
    dq_datasize = size(ERP.dataquality(dq_subfield).data);
    dq_size_str = '';
    for i=1:numel(dq_datasize)
        dq_size_str = [dq_size_str ' ' num2str(dq_datasize(i))];
    end
    
    xls_info = ...
        {'ERP Data Quality info from ERPLAB',' ';
        ' ', ' ';
        'DQ measure type',dq.type;
        'Data shown on subsequent sheets', '';
        'Data size:',dq_size_str;};
    
    xls_info_T = table(xls_info);
    
    writetable(xls_info_T,filename,'Sheet',1,'Range','A1','WriteVariableNames',false);
    
    if any(strcmpi(dq_fields,'times'))
        time_name = {'Time_window_ranges'};
        xls_times = table(dq.times,'VariableNames',time_name);
        writetable(xls_times,filename,'Sheet',1,'Range','A10','WriteVariableNames',true);
        writetable(xls_info_T,filename,'Sheet',1,'Range','A1','WriteVariableNames',false); % write again to sort col widths
    end
    
    for i = 1:dq_datasize(3)
        xls_d = table(dq.data(:,:,i));
        writetable(xls_d,filename,'Sheet',1+i,'Range','A1','WriteVariableNames',false);
    end
    
    
end





