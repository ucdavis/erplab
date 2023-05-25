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
    assert(isempty(ERP.dataquality(1).data)==0)
catch
    
    warning('Problem saving ERP data quality. Missing info?')
    beep
    return
end

format_was_empty = 0;
if exist('format','var') == 0 || isempty(format)
    format_was_empty = 1;
    format = 'mat';
end




if exist('dq_subfield','var') == 0 || isempty(dq_subfield)
    dq_measures = numel(ERP.dataquality);
    if dq_measures == 1
        dq_subfield = 1;
    else
        for i=1:dq_measures
            dq_names{i} = ERP.dataquality(i).type;
        end
        if isempty(ERP.erpname)%%changed by GH 2022
            title = 'Pick measure to write';
        else
            title = {['ERPset:',ERP.erpname],'Pick one measure to write' };
        end
        
        [s,v] = listdlg('Name','Which DQ?','PromptString',title,'SelectionMode','single','ListString',dq_names,...
            'ListSize',[250,340]);%%changed by GH 2022
        if s>0
            dq_subfield = s;
        else
            disp('User cancelled Data Quality write')
            return
        end
    end
end

if exist('filename','var') == 0 || isempty(filename)
    % if path missing, prompt from user
    %format_options = {'*.xls' ; '*.mat'};
    format_options = {['*.' format];'*.xls';'*.mat'};
    pick_str = 'Save Data Quality to file. Pick path:';
    [picked_file, picked_path] = uiputfile(format_options,pick_str);
    filename = [picked_path picked_file];
    if isequal(picked_path,0)
        disp('File path selected is not valid. Cancelling file write.')
        return
    end
    %filename = [ERP.filepath filesep ERP.erpname '_dataquality.' format];
    [fpath, fname, ext] = fileparts(filename);
    
    
    format = ext(isstrprop(ext,'alpha')); % with picked file, set format to letters of chosen type
    
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

write_spreadsheet = 0;
spreadsheet_like_formats = {'xls','xlsx'};
if ismember(format, spreadsheet_like_formats)
    write_spreadsheet = 1;
end

% Try dummy XLS write
if write_spreadsheet
    try
        blank_cell = {''};
        blank_T = table(blank_cell);
        writetable(blank_T, filename);
    catch
        beep
        warning('Excel XLS write server unavailible on this computer?');
        disp('We suggest exporting to a Matlab *.mat file instead.');
        return
    end
end

% write section

if write_spreadsheet
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
    
    
    
    
    % Write a list of labels for rows, cols, sheets
    maxlen = max(size(dq.data));
    Rows = cell(maxlen,1);
    Cols = cell(maxlen,1);
    Sheets = cell(maxlen,1);
    
    try
        for i=1:ERP.nchan
            Rows{i} = ERP.chanlocs(i).labels;
        end
        for i=1:length(dq.times)
            Cols{i} = [num2str(dq.times(i,1)) ' : ' num2str(dq.times(i,2))];
        end
        for b=1:size(dq.data,3)
            Sheets{b} = ['Bin ' num2str(b) ' on Sheet ' num2str(b+1)];
        end
        
    catch
        disp('Problem with DQ labels?');
    end
    
    label_T = table(Rows,Cols,Sheets);
    writetable(label_T,filename,'Sheet',1,'Range','A10','WriteVariableNames',true)
    
    line_start = ['A' num2str(10+3+maxlen)];
    
    if any(strcmpi(dq_fields,'time_window_labels'))
        time_name = {'Submeasure_Time_window_ranges'};
        xls_times = table(dq.time_window_labels','VariableNames',time_name);
        writetable(xls_times,filename,'Sheet',1,'Range',line_start,'WriteVariableNames',true);
        %writetable(xls_info_T,filename,'Sheet',1,'Range','A1','WriteVariableNames',false); % write again to sort col widths
    end
    
    % Bin-like data written to subsequent sheets
    Elec = Rows;
    for i = 1:dq_datasize(3)
        sheet_label = ['Bin ' num2str(i)];
        
        for j = 1:size(dq.times,1)
            sheet_label = [sheet_label, dq.time_window_labels(j) ];
        end
        
        
        sheet_label_T = table(sheet_label);
        writetable(sheet_label_T,filename,'Sheet',i+1,'Range','A1','WriteVariableNames',false);  % writecell is introduced in R2019a, so another hacky Table here
        Submeasure = nan(maxlen); % square matrix of NaNs at maxlen for table to rectangular with labels. NaNs are not written to Excel file.
        Submeasure(1:ERP.nchan,1:size(dq.data,2)) = dq.data(:,:,i);
        xls_d = table(Elec,Submeasure);
        writetable(xls_d,filename,'Sheet',1+i,'Range','A2','WriteVariableNames',false);  % write data
    end
    
else
    % assume Matlab format
    dataquality = ERP.dataquality(dq_subfield);
    save(filename,'dataquality')
    
end

conf_str = ['Successfully wrote file ' filename];
disp(conf_str);



