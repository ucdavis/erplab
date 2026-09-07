% PURPOSE: Advanced Data Quality options dialog (custom aSME/aSD time windows,
%          baseline noise measure, point-wise SEM).
%
% FORMAT:
%
% DQ_spec = avg_data_quality(old_DQ_spec, timelimits)
%
% old_DQ_spec - existing DQ specification struct, or [] for defaults
% timelimits  - epoch limits in ms, [min max]
%
% Returns the edited DQ specification, or empty if the user cancelled.
%
% Called from Classic (averagerxGUI, DQ_preavg) and from Studio
% (f_EEG_avg_erp_GUI, f_EEG_dq_epoch_GUI).
%
% NOTE: Migrated from GUIDE (.fig) to programmatic .m. The original .fig stored
% control positions in character units, which are font-metric derived and so grew
% with the macOS ScreenPixelsPerInch change in MATLAB R2025a, overflowing the
% window. Positions and font sizes here are both in pixels, which are unaffected.
% Original .fig archived outside ERPLAB. Edit here, not the .fig.
% Migrated to .m: September 2026 by Kurt Winsler
%
% *** This function is part of ERPLAB Toolbox ***

function varargout = avg_data_quality(varargin)

if nargin < 2
    error('ERPLAB says: avg_data_quality needs a DQ spec and epoch time limits.')
end

disp('Awaiting Data Quality settings...');

FIG_W = 507;  FIG_H = 792;

% Font units must be pixels BEFORE any component is created: setting them
% afterwards makes MATLAB rewrite FontSize to preserve the rendered size.
hfig = figure( ...
    'Units',            'pixels', ...
    'Position',         [100, 100, FIG_W, FIG_H], ...
    'Tag',              'avg_dq', ...
    'Name',             'Data Quality Options', ...
    'NumberTitle',      'off', ...
    'MenuBar',          'none', ...
    'ToolBar',          'none', ...
    'Resize',           'on', ...
    'CloseRequestFcn',  @(h,e) avg_dq_CloseRequestFcn(h, e, guidata(h)), ...
    'Visible',          'off', ...
    'defaultUicontrolFontUnits',     'pixels', ...
    'defaultUipanelFontUnits',       'pixels', ...
    'defaultUibuttongroupFontUnits', 'pixels', ...
    'defaultUitableFontUnits',       'pixels');
erplab_lighttheme(hfig);
movegui(hfig, 'center');
ColorBG = get(hfig, 'Color');

% --- Controls (pixel positions extracted from .fig) ---

% Tag: cancel                                    Style: pushbutton
cancel = uicontrol( ...
    'Style',           'pushbutton', ...
    'Tag',             'cancel', ...
    'Parent',          hfig, ...
    'Units',           'pixels', ...
    'Position',        [233 7 95 72], ...
    'String',          'Cancel', ...
    'BackgroundColor', ColorBG, ...
    'Callback',        @(h,e) cancel_Callback(h, e, guidata(hfig)), ...
    'FontSize',        12);

% Tag: pushbutton_help                           Style: pushbutton
pushbutton_help = uicontrol( ...
    'Style',           'pushbutton', ...
    'Tag',             'pushbutton_help', ...
    'Parent',          hfig, ...
    'Units',           'pixels', ...
    'Position',        [328 7 46 72], ...
    'String',          '?', ...
    'BackgroundColor', ColorBG, ...
    'TooltipString',   'Help on ERPLAB wiki', ...
    'Callback',        @(h,e) pushbutton_help_Callback(h, e, guidata(hfig)), ...
    'FontSize',        12);

% Tag: text8                                     Style: text
text8 = uicontrol( ...
    'Style',           'text', ...
    'Tag',             'text8', ...
    'Parent',          hfig, ...
    'Units',           'pixels', ...
    'Position',        [71 768 377 20], ...
    'Visible',          'off', ...  % off-canvas in the .fig; never rendered
    'String',          'Set advanced options for Data Quality here.', ...
    'BackgroundColor', ColorBG, ...
    'FontSize',        12);

% Tag: save                                      Style: pushbutton
save_btn = uicontrol( ...
    'Style',           'pushbutton', ...
    'Tag',             'save', ...
    'Parent',          hfig, ...
    'Units',           'pixels', ...
    'Position',        [375 7 95 72], ...
    'String',          'Save', ...
    'BackgroundColor', ColorBG, ...
    'Callback',        @(h,e) save_Callback(h, e, guidata(hfig)), ...
    'FontSize',        12);

% Tag: uipanel1  (uipanel)
uipanel1 = uipanel( ...
    'Parent',      hfig, ...
    'Tag',         'uipanel1', ...
    'Units',       'pixels', ...
    'Position',    [10 80 490 686], ...
    'Title',       'Set custom ERP Data Quality options', ...
    'BorderType',  'etchedin', ...
    'BackgroundColor', ColorBG, ...
    'FontSize',    12);

% Tag: text17                                    Style: text
text17 = uicontrol( ...
    'Style',           'text', ...
    'Tag',             'text17', ...
    'Parent',          uipanel1, ...
    'Units',           'pixels', ...
    'Position',        [15 6 296 26], ...
    'String',          '*Correction for Standard Deviation (Gurland & Tripathi, 1971)', ...
    'BackgroundColor', ColorBG, ...
    'FontSize',        10);

% Tag: uibuttongroup4  (uibuttongroup)
uibuttongroup4 = uibuttongroup( ...
    'Parent',      uipanel1, ...
    'Tag',         'uibuttongroup4', ...
    'Units',       'pixels', ...
    'Position',    [42 357 423 68], ...
    'Title',       'Bias Correction', ...
    'BorderType',  'etchedin', ...
    'BackgroundColor', ColorBG, ...
    'FontSize',    10);

% Tag: checkbox_SEM                              Style: checkbox
checkbox_SEM = uicontrol( ...
    'Style',           'checkbox', ...
    'Tag',             'checkbox_SEM', ...
    'Parent',          uipanel1, ...
    'Units',           'pixels', ...
    'Position',        [15 434 453 24], ...
    'String',          'Include Pointwise SEM', ...
    'Value',           0, ...
    'BackgroundColor', ColorBG, ...
    'FontWeight',      'bold', ...
    'Callback',        @(h,e) checkbox_SEM_Callback(h, e, guidata(hfig)), ...
    'FontSize',        12);

% Tag: uipanel2  (uipanel)
uipanel2 = uipanel( ...
    'Parent',      uipanel1, ...
    'Tag',         'uipanel2', ...
    'Units',       'pixels', ...
    'Position',    [17 42 458 307], ...
    'Title',       'Time-Window ERP Data Quality Metrics', ...
    'BorderType',  'etchedin', ...
    'BackgroundColor', ColorBG, ...
    'FontSize',    12);

% Tag: uibuttongroup3  (uibuttongroup)
uibuttongroup3 = uibuttongroup( ...
    'Parent',      uipanel1, ...
    'Tag',         'uibuttongroup3', ...
    'Units',       'pixels', ...
    'Position',    [40 464 423 101], ...
    'Title',       'Baseline variablity method', ...
    'BorderType',  'etchedin', ...
    'BackgroundColor', ColorBG, ...
    'FontSize',    10);

% Tag: uibuttongroup2  (uibuttongroup)
uibuttongroup2 = uibuttongroup( ...
    'Parent',      uipanel1, ...
    'Tag',         'uibuttongroup2', ...
    'Units',       'pixels', ...
    'Position',    [40 571 425 73], ...
    'Title',       'Baseline time range', ...
    'BorderType',  'etchedin', ...
    'BackgroundColor', ColorBG, ...
    'FontSize',    10);

% Tag: checkbox_baseline_noise                   Style: checkbox
checkbox_baseline_noise = uicontrol( ...
    'Style',           'checkbox', ...
    'Tag',             'checkbox_baseline_noise', ...
    'Parent',          uipanel1, ...
    'Units',           'pixels', ...
    'Position',        [15 648 462 24], ...
    'String',          'Include Baseline Variability Metric', ...
    'Value',           0, ...
    'BackgroundColor', ColorBG, ...
    'FontWeight',      'bold', ...
    'Callback',        @(h,e) checkbox_baseline_noise_Callback(h, e, guidata(hfig)), ...
    'FontSize',        12);

% Tag: radiobutton_sem_corr                      Style: radiobutton
radiobutton_sem_corr = uicontrol( ...
    'Style',           'radiobutton', ...
    'Tag',             'radiobutton_sem_corr', ...
    'Parent',          uibuttongroup4, ...
    'Units',           'pixels', ...
    'Position',        [25 9 322 21], ...
    'String',          'Pointwise SEM (corrected for bias)*', ...
    'Value',           0, ...
    'BackgroundColor', ColorBG, ...
    'FontSize',        10);

% Tag: radiobutton12                             Style: radiobutton
radiobutton12 = uicontrol( ...
    'Style',           'radiobutton', ...
    'Tag',             'radiobutton12', ...
    'Parent',          uibuttongroup4, ...
    'Units',           'pixels', ...
    'Position',        [26 33 240 21], ...
    'String',          'Pointwise SEM (uncorrected)', ...
    'Value',           1, ...
    'BackgroundColor', ColorBG, ...
    'FontSize',        10);

% Tag: checkbox1_paraSME                         Style: checkbox
checkbox1_paraSME = uicontrol( ...
    'Style',           'checkbox', ...
    'Tag',             'checkbox1_paraSME', ...
    'Parent',          uipanel2, ...
    'Units',           'pixels', ...
    'Position',        [13 263 438 24], ...
    'String',          'Include analytic Standardized Measurement Error (aSME)', ...
    'Value',           0, ...
    'BackgroundColor', ColorBG, ...
    'FontWeight',      'bold', ...
    'Callback',        @(h,e) checkbox1_paraSME_Callback(h, e, guidata(hfig)), ...
    'FontSize',        12);

% Tag: uibuttongroup5  (uibuttongroup)
uibuttongroup5 = uibuttongroup( ...
    'Parent',      uipanel2, ...
    'Tag',         'uibuttongroup5', ...
    'Units',       'pixels', ...
    'Position',    [46 163 376 63], ...
    'Title',       'Bias Correction for aSME & aSD', ...
    'BorderType',  'etchedin', ...
    'BackgroundColor', ColorBG, ...
    'FontSize',    10);

% Tag: checkbox6_paraSD                          Style: checkbox
checkbox6_paraSD = uicontrol( ...
    'Style',           'checkbox', ...
    'Tag',             'checkbox6_paraSD', ...
    'Parent',          uipanel2, ...
    'Units',           'pixels', ...
    'Position',        [13 239 365 21], ...
    'String',          'Include analytic Standard Deviation Across Trials (aSD)', ...
    'Value',           0, ...
    'BackgroundColor', ColorBG, ...
    'FontWeight',      'bold', ...
    'Callback',        @(h,e) checkbox6_paraSD_Callback(h, e, guidata(hfig)), ...
    'FontSize',        12);

% Tag: restbutton                                Style: pushbutton
restbutton = uicontrol( ...
    'Style',           'pushbutton', ...
    'Tag',             'restbutton', ...
    'Parent',          uipanel2, ...
    'Units',           'pixels', ...
    'Position',        [279 9 60 22], ...
    'String',          'Reset', ...
    'BackgroundColor', ColorBG, ...
    'TooltipString',   'Fewer rows', ...
    'Callback',        @(h,e) restbutton_Callback(h, e, guidata(hfig)), ...
    'FontSize',        12);

% Tag: SME_row_plus                              Style: pushbutton
SME_row_plus = uicontrol( ...
    'Style',           'pushbutton', ...
    'Tag',             'SME_row_plus', ...
    'Parent',          uipanel2, ...
    'Units',           'pixels', ...
    'Position',        [42 9 88 22], ...
    'String',          '+ Add a row', ...
    'BackgroundColor', ColorBG, ...
    'Callback',        @(h,e) SME_row_plus_Callback(h, e, guidata(hfig)), ...
    'FontSize',        12);

% Tag: SME_row_minus                             Style: pushbutton
SME_row_minus = uicontrol( ...
    'Style',           'pushbutton', ...
    'Tag',             'SME_row_minus', ...
    'Parent',          uipanel2, ...
    'Units',           'pixels', ...
    'Position',        [140 9 128 22], ...
    'String',          'Remove selected row', ...
    'BackgroundColor', ColorBG, ...
    'TooltipString',   'Fewer rows', ...
    'Callback',        @(h,e) SME_row_minus_Callback(h, e, guidata(hfig)), ...
    'FontSize',        12);

% Tag: SME_table
SME_table = uitable( ...
    'Parent',           uipanel2, ...
    'Tag',              'SME_table', ...
    'Units',            'pixels', ...
    'Position',         [18 35 422 118], ...
    'ColumnName',      {'Submetric label', 'Start (ms)', 'End (ms)'}, ...
    'ColumnWidth',     {190 95 95}, ...
    'ColumnEditable',  [true true true], ...
    'RowName',          'numbered', ...
    'BackgroundColor', [1 1 1], ...
    'CellEditCallback', @(h,e) SME_table_CellEditCallback(h, e, guidata(hfig)), ...
    'CellSelectionCallback', @(h,e) SME_table_CellSelectionCallback(h, e, guidata(hfig)), ...
    'FontSize',         11);

% Tag: radiobutton_basel_sdcorr                  Style: radiobutton
radiobutton_basel_sdcorr = uicontrol( ...
    'Style',           'radiobutton', ...
    'Tag',             'radiobutton_basel_sdcorr', ...
    'Parent',          uibuttongroup3, ...
    'Units',           'pixels', ...
    'Position',        [19 33 393 21], ...
    'String',          'Standard Deviation of baseline period (corrected for bias - recommended)*', ...
    'Value',           0, ...
    'BackgroundColor', ColorBG, ...
    'FontSize',        10);

% Tag: radiobutton_basel_rms                     Style: radiobutton
radiobutton_basel_rms = uicontrol( ...
    'Style',           'radiobutton', ...
    'Tag',             'radiobutton_basel_rms', ...
    'Parent',          uibuttongroup3, ...
    'Units',           'pixels', ...
    'Position',        [19 9 312 24], ...
    'String',          'Root Mean Square of baseline period', ...
    'Value',           0, ...
    'BackgroundColor', ColorBG, ...
    'Callback',        @(h,e) radiobutton_basel_rms_Callback(h, e, guidata(hfig)), ...
    'FontSize',        10);

% Tag: radiobutton_basel_sd                      Style: radiobutton
radiobutton_basel_sd = uicontrol( ...
    'Style',           'radiobutton', ...
    'Tag',             'radiobutton_basel_sd', ...
    'Parent',          uibuttongroup3, ...
    'Units',           'pixels', ...
    'Position',        [19 54 379 24], ...
    'String',          'Standard Deviation of baseline period (uncorrected)', ...
    'Value',           1, ...
    'BackgroundColor', ColorBG, ...
    'Callback',        @(h,e) radiobutton_basel_sd_Callback(h, e, guidata(hfig)), ...
    'FontSize',        10);

% Tag: text_basel3                               Style: text
text_basel3 = uicontrol( ...
    'Style',           'text', ...
    'Tag',             'text_basel3', ...
    'Parent',          uibuttongroup2, ...
    'Units',           'pixels', ...
    'Position',        [383 7 34 18], ...
    'String',          'ms', ...
    'Enable',          'off', ...
    'BackgroundColor', ColorBG, ...
    'FontSize',        10);

% Tag: checkbox_basel_default_times              Style: radiobutton
checkbox_basel_default_times = uicontrol( ...
    'Style',           'radiobutton', ...
    'Tag',             'checkbox_basel_default_times', ...
    'Parent',          uibuttongroup2, ...
    'Units',           'pixels', ...
    'Position',        [18 34 342 24], ...
    'String',          'Default time range (everything up to zero ms)', ...
    'Value',           1, ...
    'BackgroundColor', ColorBG, ...
    'Callback',        @(h,e) checkbox_basel_default_times_Callback(h, e, guidata(hfig)), ...
    'FontSize',        10);

% Tag: baseline_end                              Style: edit
baseline_end = uicontrol( ...
    'Style',           'edit', ...
    'Tag',             'baseline_end', ...
    'Parent',          uibuttongroup2, ...
    'Units',           'pixels', ...
    'Position',        [327 7 56 18], ...
    'String',          '0', ...
    'Enable',          'off', ...
    'BackgroundColor', [1 1 1], ...
    'HorizontalAlignment', 'center', ...
    'Callback',        @(h,e) baseline_end_Callback(h, e, guidata(hfig)), ...
    'FontSize',        10);

% Tag: text_basel2                               Style: text
text_basel2 = uicontrol( ...
    'Style',           'text', ...
    'Tag',             'text_basel2', ...
    'Parent',          uibuttongroup2, ...
    'Units',           'pixels', ...
    'Position',        [294 7 25 18], ...
    'String',          'to', ...
    'Enable',          'off', ...
    'BackgroundColor', ColorBG, ...
    'FontSize',        10);

% Tag: baseline_start                            Style: edit
baseline_start = uicontrol( ...
    'Style',           'edit', ...
    'Tag',             'baseline_start', ...
    'Parent',          uibuttongroup2, ...
    'Units',           'pixels', ...
    'Position',        [222 7 56 18], ...
    'String',          '-200', ...
    'Enable',          'off', ...
    'BackgroundColor', [1 1 1], ...
    'HorizontalAlignment', 'center', ...
    'Callback',        @(h,e) baseline_start_Callback(h, e, guidata(hfig)), ...
    'FontSize',        10);

% Tag: radiobutton_basel_custom_times            Style: radiobutton
radiobutton_basel_custom_times = uicontrol( ...
    'Style',           'radiobutton', ...
    'Tag',             'radiobutton_basel_custom_times', ...
    'Parent',          uibuttongroup2, ...
    'Units',           'pixels', ...
    'Position',        [18 14 186 18], ...
    'String',          '..or custom time range from:', ...
    'Value',           0, ...
    'BackgroundColor', ColorBG, ...
    'Callback',        @(h,e) radiobutton_basel_custom_times_Callback(h, e, guidata(hfig)), ...
    'FontSize',        10);

% Tag: radiobutton_SD_corr                       Style: radiobutton
radiobutton_SD_corr = uicontrol( ...
    'Style',           'radiobutton', ...
    'Tag',             'radiobutton_SD_corr', ...
    'Parent',          uibuttongroup5, ...
    'Units',           'pixels', ...
    'Position',        [25 9 322 21], ...
    'String',          'Corrected for bias*', ...
    'Value',           0, ...
    'BackgroundColor', ColorBG, ...
    'Callback',        @(h,e) radiobutton_SD_corr_Callback(h, e, guidata(hfig)), ...
    'FontSize',        10);

% Tag: radiobutton_SD                            Style: radiobutton
radiobutton_SD = uicontrol( ...
    'Style',           'radiobutton', ...
    'Tag',             'radiobutton_SD', ...
    'Parent',          uibuttongroup5, ...
    'Units',           'pixels', ...
    'Position',        [25 31 240 21], ...
    'String',          'Uncorrected for bias', ...
    'Value',           1, ...
    'BackgroundColor', ColorBG, ...
    'FontSize',        10);

% --- Store handles ---
handles.gui_chassis = hfig;
handles.avg_dq      = hfig;   % callbacks refer to the figure by its old tag
handles.cancel                                   = cancel;
handles.pushbutton_help                          = pushbutton_help;
handles.text8                                    = text8;
handles.save                                     = save_btn;
handles.uipanel1                                 = uipanel1;
handles.text17                                   = text17;
handles.uibuttongroup4                           = uibuttongroup4;
handles.checkbox_SEM                             = checkbox_SEM;
handles.uipanel2                                 = uipanel2;
handles.uibuttongroup3                           = uibuttongroup3;
handles.uibuttongroup2                           = uibuttongroup2;
handles.checkbox_baseline_noise                  = checkbox_baseline_noise;
handles.radiobutton_sem_corr                     = radiobutton_sem_corr;
handles.radiobutton12                            = radiobutton12;
handles.checkbox1_paraSME                        = checkbox1_paraSME;
handles.uibuttongroup5                           = uibuttongroup5;
handles.checkbox6_paraSD                         = checkbox6_paraSD;
handles.restbutton                               = restbutton;
handles.SME_row_plus                             = SME_row_plus;
handles.SME_row_minus                            = SME_row_minus;
handles.SME_table                                = SME_table;
handles.radiobutton_basel_sdcorr                 = radiobutton_basel_sdcorr;
handles.radiobutton_basel_rms                    = radiobutton_basel_rms;
handles.radiobutton_basel_sd                     = radiobutton_basel_sd;
handles.text_basel3                              = text_basel3;
handles.checkbox_basel_default_times             = checkbox_basel_default_times;
handles.baseline_end                             = baseline_end;
handles.text_basel2                              = text_basel2;
handles.baseline_start                           = baseline_start;
handles.radiobutton_basel_custom_times           = radiobutton_basel_custom_times;
handles.radiobutton_SD_corr                      = radiobutton_SD_corr;
handles.radiobutton_SD                           = radiobutton_SD;
handles.output     = [];
handles.DQ_spec    = varargin{1};
handles.timelimits = varargin{2};

% ---- opening logic (ported from avg_data_quality_OpeningFcn) ----
if isempty(varargin{1})

    preAvg_info = make_DQ_spec(handles.timelimits);
    sme_tw_labels = preAvg_info(3).time_window_labels;
    sme_tw = num2cell(preAvg_info(3).times);
    preAvg_labels = strrep(sme_tw_labels,'aSME','(Metric)');
    sme_tw3= [preAvg_labels' sme_tw];

else 
    preAvg_info = varargin{1};
    
    nDQ = length(preAvg_info);
    times_ind = zeros(1, nDQ); 
    
    %search "times" struct
    %time_present = 0; 
    for ti = 1:nDQ
        
        if ~isempty(preAvg_info(ti).times)
            times_ind(ti) = 1; 
        end
        
    end
       
    if ~any(times_ind) %no valid times
        sme_tw3 = []; 
%         preAvg_labels_old = preAvg_info(3).time_window_labels';
%         preAvg_info_times = num2cell(preAvg_info(3).times);
    else
         try %in case there is only one time-window metric
             preAvg_info_times = num2cell(preAvg_info.times);
             %             preAvg_info_times = num2cell(preAvg_info.times);
             %
   
%              sme_tw2 = cellstr(strcat({'(Metric) at '}, ... 
%                 string(preAvg_info_times(:,1)),{' to '},string(preAvg_info_times(:,2))));
            sme_tw2 = preAvg_info.time_window_labels;
            
     
            sme_tw2 = strrep(sme_tw2,'aSME','');
            sme_tw2 = strrep(sme_tw2,'(Corrected)','');
            sme_tw2 = strrep(sme_tw2,'aSD',''); 
            sme_tw2 = strcat('(Metric)',sme_tw2);
            
            try
                sme_tw3 = [sme_tw2 preAvg_info_times]; 
            catch
                sme_tw3 = [sme_tw2' preAvg_info_times]; 
            end
            
              
         catch
             %find usable inddex
             use_row = find(times_ind ==1);
             preAvg_info_times = num2cell(preAvg_info(use_row(1)).times);
             
             %retain time_window_labels if previously set

%             sme_tw2 = cellstr(strcat({'(Metric) at '}, ... 
%                 string(preAvg_info_times(:,1)),{' to '},string(preAvg_info_times(:,2))));

            sme_tw2 = preAvg_info(use_row(1)).time_window_labels;
            sme_tw2 = strrep(sme_tw2,'aSME','');
            sme_tw2 = strrep(sme_tw2,'(Corrected)','');
            sme_tw2 = strrep(sme_tw2,'aSD',''); 
          %  sme_tw2 = strrep(sme_tw2,'aSD (Corrected)','('); 
          
            
            sme_tw2 = strcat('(Metric)',sme_tw2); 
            
            try
                sme_tw3 = [sme_tw2 preAvg_info_times]; 
            catch
                sme_tw3 = [sme_tw2' preAvg_info_times]; 
            end
         end
        
    end

%     try 
%        
%     catch ME
%         switch ME.identifier 
%             case 'MATLAB:nonExistentField'
%                 preAvg_labels_old = 'EMPTY';
%                 preAvg_info_times = 'NAN'; 
%             otherwise 
%                 preAvg_labels_old = preAvg_info.time_window_labels';
%                 preAvg_info_times = num2cell(preAvg_info.times);
%         end
%         
%     end
%     preAvg_labels = strrep(preAvg_labels_old,'aSME','(Metric)'); 
% 
%    
%     try 
%         sme_tw2= [preAvg_labels' preAvg_info_times]; 
%     catch
%         sme_tw2= [preAvg_labels preAvg_info_times]; 
%     end
    
end

% Choose default command line output for avg_data_quality

handles.DQout = zeros(2,4);
handles.tupdate = 0;
handles.num_tests = 1;

handles.paraSME = 1;
handles.tdata = handles.SME_table.Data;
handles.SME_table.Data = sme_tw3;

handles.Tout = sme_tw3;
disp(handles.Tout);

handles.sel_row = size(handles.Tout,1); % set to max on load

%read from default/working memory values 
type_struct = {preAvg_info.type};

for curtype = type_struct
    switch char(curtype)
        
        case 'Baseline Measure - SD'
            set(handles.checkbox_baseline_noise,'Value',1);
            set(handles.radiobutton_basel_sd,'Value',1);
            
        case 'Baseline Measure - SD (Corrected)'
            set(handles.checkbox_baseline_noise,'Value',1);
            set(handles.radiobutton_basel_sdcorr,'Value',1);
             
        case 'Baseline Measure - RMS'
            set(handles.checkbox_baseline_noise,'Value',1);
            set(handles.radiobutton_basel_rms,'Value',1);
            
        case 'Point-wise SEM'
            set(handles.checkbox_SEM,'Value',1);
            set(handles.radiobutton12, 'Value',1); 
            
        case 'Point-wise SEM (Corrected)'
            set(handles.checkbox_SEM,'Value',1);
            set(handles.radiobutton_sem_corr,'Value',1);
            
        case 'aSME'
            set(handles.checkbox1_paraSME,'Value',1);
            set(handles.radiobutton_SD,'Value',1);
            
        case 'aSME (Corrected)'
            set(handles.checkbox1_paraSME,'Value',1);
            set(handles.radiobutton_SD_corr,'Value',1);
            
        case 'aSD'
            set(handles.checkbox6_paraSD,'Value',1);
            set(handles.radiobutton_SD,'Value',1);
            
        case 'aSD (Corrected)'
            set(handles.checkbox6_paraSD,'Value',1);
            set(handles.radiobutton_SD_corr,'Value',1);
    end
           
end



guidata(hfig, handles);


% UIWAIT makes avg_data_quality wait for user response (see UIRESUME)
sync_metric_enable(handles);
guidata(hfig, handles);
initialize_gui(hfig, handles, false);
set(hfig, 'Visible', 'on');
uiwait(hfig);

% ---- collect output after the dialog closes ----
try
    out = guidata(hfig);
    varargout{1} = out.output;
catch
    varargout{1} = [];
end
try, delete(hfig); catch, end
pause(0.1);


% =========================================================================
%                              Callbacks
% =========================================================================

% --- Greys out each metric's options unless its own checkbox is ticked, so a
% --- deselected radio button cannot be clicked back on.
function sync_metric_enable(handles)

onoff = {'off','on'};
basel = get(handles.checkbox_baseline_noise,'Value');
sem   = get(handles.checkbox_SEM,'Value');
tw    = get(handles.checkbox1_paraSME,'Value') || get(handles.checkbox6_paraSD,'Value');

% baseline variability: the time-range group and the method group
set([handles.checkbox_basel_default_times, handles.radiobutton_basel_custom_times, ...
     handles.radiobutton_basel_sd, handles.radiobutton_basel_sdcorr, ...
     handles.radiobutton_basel_rms], 'Enable', onoff{basel+1});

% the custom latency boxes need a custom range selected as well
custom = basel && get(handles.radiobutton_basel_custom_times,'Value');
set([handles.baseline_start, handles.baseline_end, ...
     handles.text_basel2, handles.text_basel3], 'Enable', onoff{custom+1});

% point-wise SEM
set([handles.radiobutton12, handles.radiobutton_sem_corr], 'Enable', onoff{sem+1});

% time-window metrics share one table and one bias-correction group
set([handles.SME_table, handles.radiobutton_SD, handles.radiobutton_SD_corr], ...
    'Enable', onoff{tw+1});


function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if isequal(get(handles.avg_dq, 'waitstatus'), 'waiting')
    %The GUI is still in UIWAIT, us UIRESUME
    handles.output = '';
    %Update handles structure
    guidata(hObject, handles);
    uiresume(handles.avg_dq);
else
    % The GUI is no longer waiting, just close it
    delete(handles.avg_dq);
end

% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% First, check time windows are valid
try 
    times_here = cell2mat(handles.Tout(:,2:3));
    if any(times_here(:) < min(handles.timelimits)) || any(times_here(:) > max(handles.timelimits))
        beep
        time_off_str = ['It appears that some of the listed times are out of bounds of the epoch time of this EEG set'];
        disp(time_off_str)
        time_off2 = ['Time limits here are: ' num2str(handles.timelimits)];
        disp(time_off2)
        pause(0.1)
        return
    end
catch
    times_here = []; 
    
end

disp('Saving Data Quality settings...');

if handles.paraSME == 1
    num_tests = 1;
    type = 'SME';
end

baseline_on = get(handles.checkbox_baseline_noise,'Value');
sem_on = get(handles.checkbox_SEM,'Value');
asme_on = get(handles.checkbox1_paraSME,'Value');
aSD_on = get(handles.checkbox6_paraSD,'Value'); 


%num_tests = baseline_on + sem_on + asme_on;



% Make DQout
DQout = [];
dq_slot = 0;
if baseline_on
    dq_slot = dq_slot + 1;
    
    basel_sd = get(handles.radiobutton_basel_sd,'Value');
    basel_rms = get(handles.radiobutton_basel_rms,'Value');
    %basel_sdcorr = get(handles.radiobutton_basel_sdcorr,(
    if basel_sd
        DQout(dq_slot).type = 'Baseline Measure - SD';
    elseif basel_rms
        DQout(dq_slot).type = 'Baseline Measure - RMS';
    else
        DQout(dq_slot).type = 'Baseline Measure - SD (Corrected)'; 
    end
    
    default_t = get(handles.checkbox_basel_default_times,'Value');
    if default_t
        DQout(dq_slot).times = [];
    else
        custom_t = [1 str2double(get(handles.baseline_start,'String')) str2double(get(handles.baseline_end,'String'))];
        DQout(dq_slot).times = custom_t;
    end
end

if sem_on
    dq_slot = dq_slot + 1;
    sem_corr = get(handles.radiobutton_sem_corr,'Value'); 
    
    if sem_corr
        DQout(dq_slot).type = 'Point-wise SEM (Corrected)'; 
    else
        DQout(dq_slot).type = 'Point-wise SEM';
    end
end




if asme_on
    dq_slot = dq_slot + 1;
    
    dq_sd = get(handles.radiobutton_SD,'Value');
    if dq_sd
        DQout(dq_slot).type = 'aSME';
        DQout(dq_slot).times = times_here; 
        DQout(dq_slot).time_window_labels = strrep(handles.Tout(:,1),'(Metric)','aSME');
    else
        DQout(dq_slot).type = 'aSME (Corrected)';
        DQout(dq_slot).times = times_here; 
        DQout(dq_slot).time_window_labels = strrep(handles.Tout(:,1),'(Metric)','aSME (Corrected)');
    end
     
   % DQout(dq_slot).time_window_labels = strrep(handles.Tout(:,1),'(Metric)','aSME');

end

if aSD_on 
    dq_slot = dq_slot + 1;
    
    dq_sd = get(handles.radiobutton_SD,'Value');
    if dq_sd
        DQout(dq_slot).type = 'aSD';
        DQout(dq_slot).times = times_here;
        DQout(dq_slot).time_window_labels = strrep(handles.Tout(:,1),'(Metric)','aSD');
    else
        DQout(dq_slot).type = 'aSD (Corrected)';
        DQout(dq_slot).times = times_here;
        DQout(dq_slot).time_window_labels = strrep(handles.Tout(:,1),'(Metric)','aSD (Corrected)');
    end
        
    

   % DQout(dq_slot).time_window_labels = strrep(handles.Tout(:,1),'(Metric)','aSD');

        

    
end


%DQout.num_tests = num_tests;

handles.output = DQout;

% Update handles structure
guidata(hObject, handles);
uiresume(handles.avg_dq);
%avg_dq_CloseRequestFcn(hObject, eventdata, handles);



% --- Executes when selected object changed in unitgroup.
function unitgroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in unitgroup
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset)
% If the metricdata field is present and the save flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to save the data.
if isfield(handles, 'metricdata') && ~isreset
    return;
end


% Update handles structure
guidata(handles.avg_dq, handles);


% --- Executes on button press in checkbox1_paraSME.
function checkbox1_paraSME_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1_paraSME (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1_paraSME
SME_here = get(hObject,'Value');
%disp(SME_here);

temp_times = handles.Tout;

if SME_here
    set(handles.SME_table,'Enable','on');
    set(handles.radiobutton_SD,'Enable','on');
    set(handles.radiobutton_SD_corr,'Enable','on');
    
    if isempty(temp_times)
        temp_DQ_spec = make_DQ_spec(handles.timelimits);
        sme_tw_labels_old = temp_DQ_spec(3).time_window_labels;
        sme_tw_labels = strrep(sme_tw_labels_old,'aSME','(Metric)');
        sme_tw = num2cell(temp_DQ_spec(3).times);
        sme_tw2 = [sme_tw_labels' sme_tw];
        
        handles.Tout = sme_tw2;
        handles.sel_row = size(sme_tw2,1);
        guidata(hObject, handles);
        set(handles.SME_table, 'Data', sme_tw2);
        pause(0.3)
    end
    
else
    
    SD_check = get(handles.checkbox6_paraSD,'Value');
    if SD_check == 0
        set(handles.SME_table,'Enable','off');
        set(handles.radiobutton_SD,'Enable','off');
        set(handles.radiobutton_SD_corr,'Enable','off');  
        
    end
end


sync_metric_enable(handles);
guidata(hObject, handles);


function pushbutton_help_Callback(hObject, eventdata, handles)
% doc pop_averager
web('https://github.com/lucklab/erplab/wiki/Computing-Averaged-ERPs#data-quality-measures', '-browser');


% --- Executes when user attempts to close avg_dq.
function avg_dq_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to avg_dq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




if isequal(get(handles.avg_dq, 'waitstatus'), 'waiting')
    %The GUI is still in UIWAIT, us UIRESUME
    handles.output = '';
    %Update handles structure
    guidata(hObject, handles);
    uiresume(handles.avg_dq);
else
    % The GUI is no longer waiting, just close it
    delete(handles.avg_dq);
end
% Hint: delete(hObject) closes the figure
%delete(hObject);


% --- Executes during object creation, after setting all properties.
function SME_table_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SME_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


Tout = hObject.Data;
handles.Tout = Tout;
guidata(hObject, handles);



% --- Executes when entered data in editable cell(s) in SME_table.
function SME_table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to SME_table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
% handles.tdata = eventdata.NewData;
% handles.SME_table.Data = handles.tdata;


Tout = hObject.Data;
handles.Tout = Tout;
guidata(hObject, handles);


% --- Executes on button press in SME_row_minus.
function SME_row_minus_Callback(hObject, eventdata, handles)
% hObject    handle to SME_row_minus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

curr_rows = size(handles.Tout,1);

row_del = handles.sel_row;


if curr_rows <= 1
    beep
    disp('Already at 1 rows')
else
    
    % notify
    row_del_text = ['Now removing row ' num2str(row_del)];
    disp(row_del_text)
    
    new_rows = curr_rows - 1;
    
    row_del = min(max(row_del,1), curr_rows); % selection can be stale after a reset
    new_Tout = handles.Tout;
    new_Tout(row_del,:) = []; % pop the selected row out
    handles.Tout = new_Tout;
    handles.sel_row = new_rows;
    guidata(hObject, handles);

    %     row_drop_txt = ['The number of rows was ' num2str(curr_rows) '. Now dropping to ' num2str(new_rows)];
    % disp(row_drop_txt)
    set(handles.SME_table,'Data',new_Tout)
    pause(0.3)

    %

end


guidata(hObject, handles);


% --- Executes on button press in SME_row_plus.
function SME_row_plus_Callback(hObject, eventdata, handles)
% hObject    handle to SME_row_plus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

curr_rows = size(handles.Tout,1);
new_rows = curr_rows + 1;

old_Tout = handles.Tout;
win_size = old_Tout{end,3} - old_Tout{end,2};

new_row_str = ['(Metric) Time Window custom ' num2str(new_rows)];
new_row_cell = {new_row_str,old_Tout{end,3},old_Tout{end,3}+win_size};
new_Tout = [old_Tout;new_row_cell];

handles.Tout = new_Tout;
guidata(hObject, handles);

set(handles.SME_table,'Data',new_Tout);


% --- Executes during object creation, after setting all properties.
function text_time_range_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_time_range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in checkbox_baseline_noise.
function checkbox_baseline_noise_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_baseline_noise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hint: get(hObject,'Value') returns toggle state of checkbox_baseline_noise
inc_baseline = get(hObject,'Value');
if inc_baseline == 1
    %%one selection per button group: setting several in a row leaves only the last
    set(handles.checkbox_basel_default_times,'Value',1);   % uibuttongroup2: default vs custom times
    set(handles.radiobutton_basel_sd,'Value',1);           % uibuttongroup3: SD vs SD-corrected vs RMS
else
    set(handles.checkbox_basel_default_times,'Value',0);
    set(handles.radiobutton_basel_custom_times,'Value',0);
    set(handles.radiobutton_basel_sd,'Value',0);
    set(handles.radiobutton_basel_sdcorr,'Value',0);
    set(handles.radiobutton_basel_rms,'Value',0); 
end
sync_metric_enable(handles);
guidata(hObject, handles);


% --- Executes on button press in checkbox_SEM.
function checkbox_SEM_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_SEM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_SEM
inc_SEM = get(hObject,'Value');
if inc_SEM == 1
    set(handles.radiobutton12,'Value',1);          % uibuttongroup4: uncorrected, matching the other two metrics
else
    set(handles.radiobutton12,'Value',0);
    set(handles.radiobutton_sem_corr,'Value',0);
end
sync_metric_enable(handles);
guidata(hObject, handles);



function baseline_start_Callback(hObject, eventdata, handles)
% hObject    handle to baseline_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of baseline_start as text
%        str2double(get(hObject,'String')) returns contents of baseline_start as a double


% --- Executes during object creation, after setting all properties.
function baseline_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baseline_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function baseline_end_Callback(hObject, eventdata, handles)
% hObject    handle to baseline_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of baseline_end as text
%        str2double(get(hObject,'String')) returns contents of baseline_end as a double


% --- Executes during object creation, after setting all properties.
function baseline_end_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baseline_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_baseline_subtract.
function checkbox_baseline_subtract_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_baseline_subtract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_baseline_subtract


% --- Executes on button press in radiobutton_basel_sd.
function radiobutton_basel_sd_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_basel_sd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_basel_sd
basel_sd = get(hObject,'Value');

if basel_sd
    set(handles.radiobutton_basel_rms,'Value',0);
end



% --- Executes on button press in radiobutton_basel_rms.
function radiobutton_basel_rms_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_basel_rms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_basel_rms
basel_rms = get(hObject,'Value');

if basel_rms
    set(handles.radiobutton_basel_sd,'Value',0);
end


% --- Executes on button press in checkbox_basel_default_times.
function checkbox_basel_default_times_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_basel_default_times (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_basel_default_times
default_times = get(hObject,'Value');

if default_times
    set(handles.baseline_start,'Enable','off');
    set(handles.baseline_end,'Enable','off');
    %set(handles.radiobutton_basel_custom_times,'Enable','off');
    set(handles.text_basel2,'Enable','off');
    set(handles.text_basel3,'Enable','off');
    
else
    set(handles.baseline_start,'Enable','on');
    set(handles.baseline_end,'Enable','on');
    %set(handles.radiobutton_basel_custom_times,'Enable','on');
    set(handles.text_basel2,'Enable','on');
    set(handles.text_basel3,'Enable','on');
end


% --- Executes on button press in radiobutton_basel_custom_times.

sync_metric_enable(handles);
guidata(hObject, handles);


function radiobutton_basel_custom_times_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_basel_custom_times (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_basel_custom_times
custom_times = get(hObject,'Value');

if custom_times
    set(handles.baseline_start,'Enable','on');
    set(handles.baseline_end,'Enable','on');
    %set(handles.radiobutton_basel_custom_times,'Enable','on');
    set(handles.text_basel2,'Enable','on');
    set(handles.text_basel3,'Enable','on');
else
    set(handles.baseline_start,'Enable','off');
    set(handles.baseline_end,'Enable','off');
    %set(handles.radiobutton_basel_custom_times,'Enable','off');
    set(handles.text_basel2,'Enable','off');
    set(handles.text_basel3,'Enable','off');  
end


% --- Executes when selected cell(s) is changed in SME_table.

sync_metric_enable(handles);
guidata(hObject, handles);


function SME_table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to SME_table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

%disp(eventdata)
% if the selected cell info exists, save it to handles
if numel(eventdata.Indices)
    row_here = eventdata.Indices(1);
    old_row = handles.sel_row;
    handles.sel_row = row_here;
    if isequal(row_here,old_row) == 0
        row_text = ['Row number ' num2str(row_here) ' now selected'];
        disp(row_text)
    end
    guidata(hObject, handles);
end




% --- Executes on button press in restbutton.
function restbutton_Callback(hObject, eventdata, handles)
% hObject    handle to restbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get default timewindows
temp_DQ_spec = make_DQ_spec(handles.timelimits);
sme_tw_labels_old = temp_DQ_spec(3).time_window_labels;
sme_tw_labels = strrep(sme_tw_labels_old,'aSME','(Metric)'); 
sme_tw = num2cell(temp_DQ_spec(3).times);
sme_tw2 = [sme_tw_labels' sme_tw];

handles.Tout = sme_tw2;
handles.sel_row = size(sme_tw2,1); % table just shrank; keep the selection in range
guidata(hObject, handles);
set(handles.SME_table, 'Data', sme_tw2);
pause(0.3)


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox6_paraSD.
function checkbox6_paraSD_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6_paraSD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SD_check = get(hObject,'Value');
%disp(SME_here);
temp_times = handles.Tout; 

if SD_check
    set(handles.SME_table,'Enable','on');
    set(handles.radiobutton_SD,'Enable','on');
    set(handles.radiobutton_SD_corr,'Enable','on');
    
    if isempty(temp_times)
        temp_DQ_spec = make_DQ_spec(handles.timelimits);
        sme_tw_labels_old = temp_DQ_spec(3).time_window_labels;
        sme_tw_labels = strrep(sme_tw_labels_old,'aSME','(Metric)');
        sme_tw = num2cell(temp_DQ_spec(3).times);
        sme_tw2 = [sme_tw_labels' sme_tw];
        
        handles.Tout = sme_tw2;
        handles.sel_row = size(sme_tw2,1);
        guidata(hObject, handles);
        set(handles.SME_table, 'Data', sme_tw2);
        pause(0.3)
    end
 
    
else
    SME_check = get(handles.checkbox1_paraSME,'Value');
    if SME_check == 0 
    set(handles.SME_table,'Enable','off');
    set(handles.radiobutton_SD,'Enable','off'); 
    set(handles.radiobutton_SD_corr,'Enable','off');
    end
end

guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of checkbox6_paraSD


% --- Executes on button press in radiobutton_SD_corr.

sync_metric_enable(handles);
guidata(hObject, handles);


function radiobutton_SD_corr_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_SD_corr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_SD_corr
