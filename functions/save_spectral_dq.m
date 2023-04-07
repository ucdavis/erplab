% write data quality substructure to file
% part of the ERPLAB Toolbox (continuous EEG spectral version) 
% axs Apr 2019
% ams Jan 2023 (updated with SD across Trials)
% ams Feb 2023 (continuous EEG spectra version)
% Format:
%  save_data_quality(ERP, 'dq.mat')
%    or save_data_quality(ERP,filename,format_flag)
%
% INPUT:      * - mandatory
%  * FFT_OUT  - A matrix composed of [Chan BandAvg] where BandAvg is
%  average across frequencies within band. 
%    filename - a string which will specify the filename of the new saved
%         file. This can optionally contain a full path, and/or extension.
%         Default of ERP.filepath
%    format - String of 'mat', 'xls', or 'xlsx', specifying the requsted
%         format for the new save files. Default of 'mat'.
%    dq_subfield - which entry of the dq substructure to write.
%         default of 1
%
%
function save_spectral_dq(FFT_out, chans, bands,dq_selected, filename, format)

% Check input


format_was_empty = 0;
if exist('format','var') == 0 || isempty(format)
    format_was_empty = 1;
    format = 'mat';
end





if exist('filename','var') == 0 || isempty(filename)
    % if path missing, prompt from user
    %format_options = {'*.xls' ; '*.mat'};
    format_options = {['*.' format];'*.xlsx';'*.mat'};
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
    filename = [pwd filesep fname ext]; %choose pwd
    [fpath, fname, ext] = fileparts(filename);
end

if isempty(ext)
    filename = [filename '.' format];
end


try
    assert(exist(fpath,'dir')==7)  % check path is valid
catch
    warning('Problem saving EEG spectral data quality - this path does not exist')
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
  %  dq = ERP.dataquality(dq_subfield);
   % dq_fields = fieldnames(ERP.dataquality(dq_subfield));
   if dq_selected == 2 %2 = amplitude, 1 = power
       dq.type = 'Continuous EEG Frequency Spectra - Single-Sided Amplitude';
   else
       dq.type = 'Continuous EEG Frequency Spectra - Single-Sided Power';
   end 
   dq.data = FFT_out;
   dq.chans = chans; 
   dq.bands = bands;
   dq_datasize = size(FFT_out); 
    
%     if strcmp(dq.type, 'Point-wise SEM (Corrected)') | strcmp(dq.type, 'Point-wise SEM')
%         dq_datasize = size(ERP.binerror)
%         dq.data = ERP.binerror;
%         dq.times = [repmat(1:dq_datasize(2),[2,1])]';
%         dq.time_window_labels = cellstr([repmat('Timepoint ',[dq_datasize(2),1]) num2str(dq.times(:,1))])';
%     else
%         dq_datasize = size(ERP.dataquality(dq_subfield).data);
%     end
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
   
    maxlen = max(size(dq.data));
    Rows = cell(maxlen,1);
    Cols = cell(maxlen,1);

    
    try
        for i=1:length(chans)
            Rows{i} = chans(i);
        end
        for i=1:length(bands)
            Cols{i} = bands(i);
        end
        
         for b=1:size(dq.data,2)
             Sheets{b} = ['Band ' num2str(b) ' on Sheet 2'];
         end
     
        
    catch
        disp('Problem with DQ labels?');
    end
    
    label_T = table(Rows,Cols);
    writetable(label_T,filename,'Sheet',1,'Range','A10','WriteVariableNames',true)
    
    
    % and data written to subsequent sheets
    Elec = Rows;
    
    if dq_selected == 2 %2 = amplitude, 1 = power
        sheet_label = ['Amplitude ' ];
    else
        sheet_label = ['Power' ];
    end
    
    for j = 1:size(bands,1)
        sheet_label = [sheet_label, bands(j) ];
    end
    
    
    sheet_label_T = table(sheet_label);
    writetable(sheet_label_T,filename,'Sheet',2,'Range','A1','WriteVariableNames',false);  % writecell is introduced in R2019a, so another hacky Table here
    Submeasure = nan(maxlen); % square matrix of NaNs at maxlen for table to rectangular with labels. NaNs are not written to Excel file.
    
    Submeasure(1:length(chans),1:length(bands)) = dq.data;
    xls_d = table(Elec,Submeasure);
    writetable(xls_d,filename,'Sheet',2,'Range','A2','WriteVariableNames',false);  % write data

    
else
    % assume Matlab format
    dataquality = FFT_out;
    save(filename,'spectral_dq')
    
end

conf_str = ['Successfully wrote file ' filename];
disp(conf_str);



