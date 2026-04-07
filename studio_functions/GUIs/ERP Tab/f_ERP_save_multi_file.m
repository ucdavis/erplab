function varargout = f_ERP_save_multi_file(varargin)
% NOTE: Migrated from GUIDE (.fig) to programmatic .m for version control.
% Original .fig archived outside ERPLAB. Edit here, not the .fig.
% Migrated to .m: April 2026 by Kurt Winsler
%
% Usage: Answer = f_ERP_save_multi_file(ALLERP, EEGArray, suffix, ERPIndex, showEEGPathOption)
%   ALLERP            - struct array (ERPsets or EEGsets depending on ERPIndex)
%   EEGArray          - indices into ALLERP for sets being saved
%   suffix            - string appended to names (default '')
%   ERPIndex          - 1 = ALLERP has .erpname fields; 0 = has .setname fields
%   showEEGPathOption - true = show "Use EEGset path" checkbox (averaging context)
%
% Returns: {ALLERP_modified, Save_file_label, useEEGsetPath}

% --- Parse inputs ---
try
    ALLERP   = varargin{1};
    EEGArray = varargin{2};
    suffix   = varargin{3};
catch
    suffix = '';
    ALLERP(1).erpname  = 'No erpset was selected';
    ALLERP(1).filename = 'No erpset was selected';
    ALLERP(1).event    = [];
    ALLERP(1).chanlocs = [];
    ALLERP(1).nbchan   = 0;
    EEGArray = 1;
end
try; ERPIndex          = varargin{4}; catch; ERPIndex          = 1;     end
try; showEEGPathOption = varargin{5}; catch; showEEGPathOption = false;  end

erplab_default_values;
version = erplabver;

% --- Layout: pixel positions extracted from original .fig (683 x 319 px) ---
%
% When showEEGPathOption=true:
%   - Figure widens to 760 px to fit the "Use EEGset path" checkbox (right
%     edge at x=735) and to give the table enough width without scrolling.
%   - Figure grows by EEG_EXTRA pixels vertically.
%   - Path row + Save-ERPsets checkbox shift up by EEG_SHIFT.
%
% Table width = FIG_W - 24 (16px left margin + 8px right margin).
% ColumnWidth is sized so both columns fit without a horizontal scrollbar
% (row-number header takes ~40px, so each data column = (table_w-40)/2).
EEG_EXTRA = 20;
EEG_SHIFT = 20;

if showEEGPathOption
    FIG_W  = 760;
    FIG_H  = 319 + EEG_EXTRA;
    shift  = EEG_SHIFT;
    tbl_w  = FIG_W - 24;   % 736 px
    col_w  = 345;           % {345 345} = 690 px < 736-40 = 696 px  ✓
else
    FIG_W  = 683;
    FIG_H  = 319;
    shift  = 0;
    tbl_w  = FIG_W - 24;   % 659 px  (matches original .fig exactly)
    col_w  = 300;           % {300 300} = 600 px < 659-40 = 619 px  ✓
end

hfig = figure( ...
    'Units',           'pixels', ...
    'Position',        [100, 100, FIG_W, FIG_H], ...
    'Name',            ['EStudio ' version '   -   Save multiple erpsets GUI'], ...
    'NumberTitle',     'off', ...
    'MenuBar',         'none', ...
    'ToolBar',         'none', ...
    'Resize',          'off', ...
    'CloseRequestFcn', @gui_CloseRequestFcn, ...
    'Visible',         'off');
movegui(hfig, 'center');
ColorBG = get(hfig, 'Color');

% --- Table ---
tbl = uitable( ...
    'Parent',           hfig, ...
    'Tag',              'uitable1_erpset_table', ...
    'Units',            'pixels', ...
    'Position',         [16, 55, tbl_w, 164], ...
    'ColumnName',       {'ERP name', 'File name'}, ...
    'ColumnWidth',      {col_w col_w}, ...
    'ColumnEditable',   [true false], ...
    'RowName',          cellstr(num2str(EEGArray')), ...
    'BackgroundColor',  [1 1 1], ...
    'FontSize',         12, ...
    'CellEditCallback', @(h,e) uitable1_erpset_table_CellEditCallback(h, e, guidata(hfig)));

% --- Suffix row (left column) ---
% pushbutton: [16 235 160 31]
cb_suffix = uicontrol( ...
    'Style',           'pushbutton', ...
    'Tag',             'checkbox1_suffix', ...
    'Parent',          hfig, ...
    'Units',           'pixels', ...
    'Position',        [16, 235, 160, 31], ...
    'String',          'Add suffix to ERPset Names', ...
    'BackgroundColor', [1 1 1], ...
    'FontSize',        12, ...
    'Callback',        @(h,e) checkbox1_suffix_Callback(h, e, guidata(hfig)));

% edit_suffix_name: [187 236 282 30]
edit_suffix = uicontrol( ...
    'Style',               'edit', ...
    'Tag',                 'edit_suffix_name', ...
    'Parent',              hfig, ...
    'Units',               'pixels', ...
    'Position',            [187, 236, 282, 30], ...
    'String',              suffix, ...
    'BackgroundColor',     [1 1 1], ...
    'HorizontalAlignment', 'center', ...
    'FontSize',            12);

% --- Right column checkboxes ---

% checkbox2_save_label: [505 286 139 19] shifted up by `shift`
cb_save = uicontrol( ...
    'Style',           'checkbox', ...
    'Tag',             'checkbox2_save_label', ...
    'Parent',          hfig, ...
    'Units',           'pixels', ...
    'Position',        [505, 286+shift, 139, 19], ...
    'String',          'Save ERPsets to disk', ...
    'Value',           0, ...
    'BackgroundColor', ColorBG, ...
    'FontSize',        12, ...
    'Callback',        @(h,e) checkbox2_save_label_Callback(h, e, guidata(hfig)));

% "Use EEGset path" checkbox (averaging context only).
% Positioned at the midpoint between cb2 and cb3 (8px gaps on each side).
if showEEGPathOption
    cb_eeg_path = uicontrol( ...
        'Style',           'checkbox', ...
        'Tag',             'checkbox_use_eeg_path', ...
        'Parent',          hfig, ...
        'Units',           'pixels', ...
        'Position',        [505, 274, 230, 22], ...
        'String',          'Use EEGset path as ERPset path', ...
        'Value',           0, ...
        'Enable',          'off', ...
        'BackgroundColor', ColorBG, ...
        'FontSize',        12, ...
        'Callback',        @(h,e) checkbox_use_eeg_path_Callback(h, e, hfig));
else
    cb_eeg_path = [];
end

% checkbox3_filename_erpname: [504 234 167 34] — exact .fig position
cb_erpname = uicontrol( ...
    'Style',           'checkbox', ...
    'Tag',             'checkbox3_filename_erpname', ...
    'Parent',          hfig, ...
    'Units',           'pixels', ...
    'Position',        [504, 234, 167, 34], ...
    'String',          'Use ERP name as filename', ...
    'Value',           0, ...
    'Enable',          'off', ...
    'BackgroundColor', ColorBG, ...
    'FontSize',        12, ...
    'Callback',        @(h,e) checkbox3_filename_erpname_Callback(h, e, guidata(hfig)));

% --- Path row (left column): shifted up by `shift` ---

% text9 "Path:": [9 279 46 24]
% Stored so painterplabstudio sets its BackgroundColor consistently.
text9 = uicontrol( ...
    'Style',               'text', ...
    'Tag',                 'text9', ...
    'Parent',              hfig, ...
    'Units',               'pixels', ...
    'Position',            [9, 279+shift, 46, 24], ...
    'String',              'Path:', ...
    'BackgroundColor',     ColorBG, ...
    'HorizontalAlignment', 'left', ...
    'FontSize',            12);

% edit_path: [57 279 364 30]
edit_path = uicontrol( ...
    'Style',               'edit', ...
    'Tag',                 'edit_path', ...
    'Parent',              hfig, ...
    'Units',               'pixels', ...
    'Position',            [57, 279+shift, 364, 30], ...
    'String',              '', ...
    'Enable',              'off', ...
    'BackgroundColor',     [1 1 1], ...
    'HorizontalAlignment', 'left', ...
    'FontSize',            12);

% pushbutton_path_browse: [432 278 51 34]
btn_browse = uicontrol( ...
    'Style',    'pushbutton', ...
    'Tag',      'pushbutton_path_browse', ...
    'Parent',   hfig, ...
    'Units',    'pixels', ...
    'Position', [432, 278+shift, 51, 34], ...
    'String',   'Browse', ...
    'Enable',   'off', ...
    'FontSize', 12, ...
    'Callback', @(h,e) pushbutton_path_browse_Callback(h, e, guidata(hfig)));

% --- Buttons ---

% pushbutton_Cancel: [53 10 88 37]
btn_cancel = uicontrol( ...
    'Style',    'pushbutton', ...
    'Tag',      'pushbutton_Cancel', ...
    'Parent',   hfig, ...
    'Units',    'pixels', ...
    'Position', [53, 10, 88, 37], ...
    'String',   'Cancel', ...
    'FontSize', 12, ...
    'Callback', @(h,e) pushbutton_Cancel_Callback(h, e, guidata(hfig)));

% pushbutton4_okay: [351 9 88 37]
btn_ok = uicontrol( ...
    'Style',    'pushbutton', ...
    'Tag',      'pushbutton4_okay', ...
    'Parent',   hfig, ...
    'Units',    'pixels', ...
    'Position', [351, 9, 88, 37], ...
    'String',   'Okay', ...
    'FontSize', 12, ...
    'Callback', @(h,e) pushbutton4_okay_Callback(h, e, guidata(hfig)));

% --- Populate table ---
for Numoferpset = 1:numel(EEGArray)
    if ERPIndex==1
        DataString{Numoferpset,1} = strcat(ALLERP(EEGArray(Numoferpset)).erpname,  suffix);
    else
        DataString{Numoferpset,1} = strcat(ALLERP(EEGArray(Numoferpset)).setname, suffix);
    end
    DataString{Numoferpset,2} = '';
end
set(tbl, 'Data', cellstr(DataString));

% --- Store handles ---
handles.gui_chassis                = hfig;
handles.uitable1_erpset_table      = tbl;
handles.text9                      = text9;
handles.checkbox1_suffix           = cb_suffix;
handles.edit_suffix_name           = edit_suffix;
handles.checkbox2_save_label       = cb_save;
handles.checkbox_use_eeg_path      = cb_eeg_path;
handles.checkbox3_filename_erpname = cb_erpname;
handles.edit_path                  = edit_path;
handles.pushbutton_path_browse     = btn_browse;
handles.ALLERP                     = ALLERP;
handles.EEGArray                   = EEGArray;
handles.ERPIndex                   = ERPIndex;
handles.showEEGPathOption          = showEEGPathOption;
handles.output                     = [];

handles = painterplabstudio(handles);
handles = setfonterplabestudio(handles);
% Pixel positions are unaffected by the above calls — no re-pinning needed.

% Restore white backgrounds on edit/table controls after style calls
set(handles.edit_path,          'BackgroundColor', [1 1 1]);
set(handles.edit_suffix_name,   'BackgroundColor', [1 1 1]);
set(handles.uitable1_erpset_table, 'BackgroundColor', [1 1 1]);
set(handles.checkbox1_suffix,   'BackgroundColor', [1 1 1]);

guidata(hfig, handles);
set(hfig, 'Visible', 'on');
uiwait(hfig);

% Collect output after dialog closes
try
    out = guidata(hfig);
    varargout{1} = out.output;
catch
    varargout{1} = [];
end
try; delete(hfig); catch; end
pause(0.1);



% =========================================================================
% Callbacks
% =========================================================================

function checkbox1_suffix_Callback(hObject, eventdata, handles)
ALLERP       = handles.ALLERP;
EEGArray     = handles.EEGArray;
suffix_edit  = handles.edit_suffix_name.String;
DataString_before = handles.uitable1_erpset_table.Data;
for Numoferpset = 1:numel(EEGArray)
    if handles.ERPIndex==1
        DataString{Numoferpset,1} = strcat(ALLERP(EEGArray(Numoferpset)).erpname,  suffix_edit);
    else
        DataString{Numoferpset,1} = strcat(ALLERP(EEGArray(Numoferpset)).setname, suffix_edit);
    end
    if handles.checkbox2_save_label.Value==1
        if handles.checkbox3_filename_erpname.Value==0
            DataString{Numoferpset,2} = DataString_before{Numoferpset,2};
        else
            DataString{Numoferpset,2} = [DataString{Numoferpset,1},'.erp'];
        end
    else
        DataString{Numoferpset,2} = '';
    end
end
set(handles.uitable1_erpset_table, 'Data', cellstr(DataString));



function checkbox2_save_label_Callback(hObject, eventdata, handles)
Values   = handles.checkbox2_save_label.Value;
ALLERP   = handles.ALLERP;
EEGArray = handles.EEGArray;

if Values
    set(handles.checkbox3_filename_erpname, 'Enable', 'on');
    DataString_before = handles.uitable1_erpset_table.Data;
    for Numoferpset = 1:size(DataString_before,1)
        DataString{Numoferpset,1} = DataString_before{Numoferpset,1};
        fileName = ALLERP(EEGArray(Numoferpset)).filename;
        if isempty(fileName) || ~(ischar(fileName) || isstring(fileName))
            if handles.ERPIndex==1
                fileName = ALLERP(EEGArray(Numoferpset)).erpname;
            else
                fileName = ALLERP(EEGArray(Numoferpset)).setname;
            end
            if isempty(fileName) || ~(ischar(fileName) || isstring(fileName))
                fileName = '';
            end
        end
        [~, file_name, ~] = fileparts(fileName);
        DataString{Numoferpset,2} = [file_name,'.erp'];
    end
    set(handles.uitable1_erpset_table, 'Data', DataString);
    handles.uitable1_erpset_table.ColumnEditable(1) = true;
    handles.uitable1_erpset_table.ColumnEditable(2) = true;

    if handles.showEEGPathOption && ~isempty(handles.checkbox_use_eeg_path)
        set(handles.checkbox_use_eeg_path, 'Enable', 'on');
        if handles.checkbox_use_eeg_path.Value
            eegPath = handles.ALLERP(handles.EEGArray(1)).filepath;
            set(handles.edit_path, 'Enable', 'off', 'String', eegPath);
            set(handles.pushbutton_path_browse, 'Enable', 'off');
        else
            set(handles.edit_path, 'Enable', 'on', 'String', cd);
            set(handles.pushbutton_path_browse, 'Enable', 'on');
        end
    else
        set(handles.edit_path, 'Enable', 'on', 'String', cd);
        set(handles.pushbutton_path_browse, 'Enable', 'on');
    end
else
    set(handles.checkbox3_filename_erpname, 'Enable', 'off');
    DataString_before = handles.uitable1_erpset_table.Data;
    for Numoferpset = 1:size(DataString_before,1)
        DataString_before{Numoferpset,2} = '';
    end
    set(handles.uitable1_erpset_table, 'Data', DataString_before);
    handles.uitable1_erpset_table.ColumnEditable(1) = true;
    handles.uitable1_erpset_table.ColumnEditable(2) = false;

    if handles.showEEGPathOption && ~isempty(handles.checkbox_use_eeg_path)
        set(handles.checkbox_use_eeg_path, 'Enable', 'off');
    end
    set(handles.edit_path, 'Enable', 'off', 'String', '');
    set(handles.pushbutton_path_browse, 'Enable', 'off');
end



function checkbox_use_eeg_path_Callback(hObject, eventdata, figHandle)
handles = guidata(figHandle);
if handles.checkbox_use_eeg_path.Value
    eegPath = handles.ALLERP(handles.EEGArray(1)).filepath;
    set(handles.edit_path, 'Enable', 'off', 'String', eegPath);
    set(handles.pushbutton_path_browse, 'Enable', 'off');
else
    set(handles.edit_path, 'Enable', 'on', 'String', cd);
    set(handles.pushbutton_path_browse, 'Enable', 'on');
end



function checkbox3_filename_erpname_Callback(hObject, eventdata, handles)
Value_filename_erpname = handles.checkbox3_filename_erpname.Value;
ALLERP   = handles.ALLERP;
EEGArray = handles.EEGArray;
DataString_before = handles.uitable1_erpset_table.Data;

for Numoferpset = 1:size(DataString_before,1)
    DataString{Numoferpset,1} = DataString_before{Numoferpset,1};
    fileName = char(DataString_before{Numoferpset,1});
    if isempty(fileName)
        fileName = strcat(num2str(Numoferpset),'.erp');
    end
    [~, file_name, ~] = fileparts(fileName);
    if isempty(file_name)
        file_name = [num2str(EEGArray(Numoferpset)),'.erp'];
    else
        file_name = [file_name,'.erp'];
    end
    if Value_filename_erpname==1
        DataString{Numoferpset,2} = file_name;
    else
        % Revert to EEGset-derived filename with .erp extension
        eegFileName = ALLERP(EEGArray(Numoferpset)).filename;
        if isempty(eegFileName) || ~(ischar(eegFileName) || isstring(eegFileName))
            if handles.ERPIndex==1
                eegFileName = ALLERP(EEGArray(Numoferpset)).erpname;
            else
                eegFileName = ALLERP(EEGArray(Numoferpset)).setname;
            end
        end
        [~, base_name, ~] = fileparts(eegFileName);
        DataString{Numoferpset,2} = [base_name,'.erp'];
    end
end
set(handles.uitable1_erpset_table, 'Data', cellstr(DataString));
handles.uitable1_erpset_table.ColumnEditable(1) = true;
handles.uitable1_erpset_table.ColumnEditable(2) = (Value_filename_erpname==1);



function uitable1_erpset_table_CellEditCallback(hObject, eventdata, handles)
DataString = handles.uitable1_erpset_table.Data;
EEGArray   = handles.EEGArray;
if size(DataString,1) < numel(EEGArray)
    errorfound('EEG name and filename for one of erpsets are empty at least! Please give name to eegname and filename', ...
               'EStudio: f_ERP_save_multi_file empty erpname');
    return
end
for Numofselected = 1:numel(EEGArray)
    if isempty(DataString{Numofselected,1})
        errorfound('Erpname for one of erpsets is empty at least! Please give name to that erpset', ...
                   'EStudio: f_ERP_save_multi_file empty eegname');
        return
    end
end
if handles.checkbox3_filename_erpname.Value==1
    DataString_before = handles.uitable1_erpset_table.Data;
    for Numoferpset = 1:size(DataString_before,1)
        DataString{Numoferpset,1} = DataString_before{Numoferpset,1};
        fileName = char(DataString_before{Numoferpset,1});
        if isempty(fileName)
            fileName = strcat(num2str(Numoferpset),'.erp');
        end
        [~, file_name, ~] = fileparts(fileName);
        if isempty(file_name)
            file_name = [num2str(EEGArray(Numoferpset)),'.erp'];
        else
            file_name = [file_name,'.erp'];
        end
        DataString{Numoferpset,2} = file_name;
    end
    set(handles.uitable1_erpset_table, 'Data', cellstr(DataString));
end
guidata(hObject, handles);



function pushbutton_Cancel_Callback(hObject, eventdata, handles)
handles.output = [];
guidata(hObject, handles);
uiresume(handles.gui_chassis);



function pushbutton4_okay_Callback(hObject, eventdata, handles)
Data_String = handles.uitable1_erpset_table.Data;
ALLERP      = handles.ALLERP;
EEGArray    = handles.EEGArray;

if size(Data_String,1) < numel(EEGArray)
    errorfound('ERP name for one of erpsets is empty at least! Please give a name', ...
               'EStudio: f_ERP_save_multi_file empty eegname');
    return
end
if size(Data_String,1) > numel(EEGArray)
    errorfound('More eegname is given. Please delete it!!!', ...
               'EStudio: f_ERP_save_multi_file empty erpname');
    return
end
for Numofselected = 1:numel(EEGArray)
    if isempty(Data_String{Numofselected,1})
        errorfound('Erpname for one of erpsets is empty at least! Please give name to that erpset', ...
                   'EStudio: f_ERP_save_multi_file empty erpname');
        return
    end
end

pathName = handles.edit_path.String;
if isempty(pathName)
    pathName = cd;
end

useEEGsetPath = handles.showEEGPathOption && ~isempty(handles.checkbox_use_eeg_path) ...
                && handles.checkbox_use_eeg_path.Value && handles.checkbox2_save_label.Value;

for Numoferpset = 1:numel(EEGArray)
    if handles.ERPIndex==1
        ALLERP(EEGArray(Numoferpset)).erpname  = Data_String{Numoferpset,1};
    else
        ALLERP(EEGArray(Numoferpset)).setname = Data_String{Numoferpset,1};
    end
    fileName = char(Data_String{Numoferpset,2});
    if isempty(fileName)
        fileName = Data_String{Numoferpset,1};
    end
    [~, file_name, ~] = fileparts(fileName);
    if isempty(file_name)
        file_name = [num2str(EEGArray(Numoferpset)),'.erp'];
    else
        file_name = [file_name,'.erp'];
    end
    ALLERP(EEGArray(Numoferpset)).filename = file_name;

    % Only override filepath when saving to disk and NOT using EEGset path
    if handles.checkbox2_save_label.Value && ~useEEGsetPath
        ALLERP(EEGArray(Numoferpset)).filepath = pathName;
    end

    if handles.checkbox2_save_label.Value
        ALLERP(EEGArray(Numoferpset)).saved = 'yes';
    else
        ALLERP(EEGArray(Numoferpset)).saved = 'no';
    end
end

handles.output = {ALLERP, handles.checkbox2_save_label.Value, useEEGsetPath};
guidata(hObject, handles);
uiresume(handles.gui_chassis);



function pushbutton_path_browse_Callback(hObject, eventdata, handles)
pathName = handles.edit_path.String;
if isempty(pathName)
    pathName = cd;
end
select_path = uigetdir(pathName, 'Select folder for saving files');
if ~isequal(select_path, 0)
    handles.edit_path.String = select_path;
end



function gui_CloseRequestFcn(hObject, eventdata)
handles = guidata(hObject);
if isequal(get(hObject,'waitstatus'), 'waiting')
    handles.output = [];
    guidata(hObject, handles);
    uiresume(hObject);
else
    delete(hObject);
end
