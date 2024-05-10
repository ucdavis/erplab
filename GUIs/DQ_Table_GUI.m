function varargout = DQ_Table_GUI(varargin)
% DQ_TABLE_GUI MATLAB code for DQ_Table_GUI.fig
%      DQ_TABLE_GUI, by itself, creates a new DQ_TABLE_GUI or raises the existing
%      singleton*.
%
%      H = DQ_TABLE_GUI returns the handle to a new DQ_TABLE_GUI or the handle to
%      the existing singleton*.
%
%      DQ_TABLE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DQ_TABLE_GUI.M with the given input arguments.
%
%      DQ_TABLE_GUI('Property','Value',...) creates a new DQ_TABLE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DQ_Table_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DQ_Table_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to pushbutton_help DQ_Table_GUI

% Last Modified by GUIDE v2.5 14-Mar-2024 12:22:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @DQ_Table_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @DQ_Table_GUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before DQ_Table_GUI is made visible.
function DQ_Table_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DQ_Table_GUI (see VARARGIN)

% Choose default command line output for DQ_Table_GUI
handles.output = [];

% check input ERPset DQ
ERP = varargin{1};
ALLERP = varargin{2};
current_ERP = varargin{3};
guiwin_num = varargin{4};

%GUI positions (for multiple DQ tables)

if guiwin_num ~= 1
    offset_GUI = 25 * randi([1 10],1); %offset by
    % %set(hObject, 'Units', 'normalized');
    figureposition = get(handles.figure1, 'Position');
    set(hObject, 'Position', ...
        [ figureposition(1)-offset_GUI figureposition(2)-offset_GUI  ...
        figureposition(3) figureposition(4)])
end


%check contents

try
    assert(exist('ERP','var')==1)
    assert(isempty(ERP)==0)
    assert(isfield(ERP,'dataquality'))
    assert(strcmp(ERP.dataquality(1).type,'empty')==0)
catch
    beep
    warning('Data Quality not present in current ERPset?')
    delete(hObject);
    return
end

% Update GUI with ERPSET info
n_erp = numel(ALLERP);

if n_erp == 0
    %for the case of showing aSME preavg
    erp_names = ERP.erpname;
    handles.text_ERPSET_title.String = 'Selected EEG Dataset:';
    handles.text_ERPSET_title.FontSize = 12;
    handles.text11.Visible = 0;
    handles.newerpwin.Visible = 0;
    handles.pushbutton_selERP.Visible = 0;
    handles.active_erpset.Style = 'text';
    if numel(erp_names) > 15
        handles.active_erpset.FontSize = 12.0;
        set(handles.active_erpset,'FontUnits', 'normalized');
    end
    %update handles
    guidata(hObject, handles);
    
else
    
    for i = 1:n_erp
        erp_names{i} = ALLERP(i).erpname;
    end
    
end

%ERPSET_title_str = ['ERPSET - ' erp_names(current_ERP)];
handles.active_erpset.String = erp_names;
handles.active_erpset.Value = current_ERP;

%AMS: Multiple ERPset options
handles.newerpwin.String = erp_names;
handles.newerpwin.Value = current_ERP;



n_dq = numel(ERP.dataquality);
for i=1:n_dq
    type_names{i} = ERP.dataquality(i).type;
end

handles.popupmenu_DQ_type.String = type_names;
%handles.popupmenu_DQ_type.Value = n_dq;
%default to aSME (if available) or end of list

where_aSME = strcmpi('aSME',type_names);
where_aSME_corr = strcmpi('aSME (Corrected)',type_names);

if any(where_aSME)
    indx_type = find(where_aSME);
    
elseif any(where_aSME_corr)
    indx_type = find(where_aSME_corr);
else
    indx_type = n_dq;
end
handles.popupmenu_DQ_type.Value = indx_type;


try
    [n_elec, n_tw, n_bin] = size(ERP.dataquality(indx_type).data); %default to aSME (or last metric)
catch
    [n_elec, n_tw, n_bin] = size(ERP.dataquality.data); %if only one measure
end

if n_elec == 0
    % if the dq data is of zero size, then the 3rd dim may be mis-sized.
    % So set to default of ERP.nbin instead.
    n_bin = ERP.nbin;
end

n_bin_names = numel(ERP.bindescr);
if n_bin_names == n_bin
    
    for i=1:n_bin
        bin_names{i} = ['BIN ' num2str(i) ' - ' ERP.bindescr{i}];
    end
else
    % if not every bin has a bin description, leave then off
    for i=1:n_bin
        bin_names{i} = ['BIN ' num2str(i)];
    end
end


handles.popupmenu_bin.String = bin_names;

% handles.popupmenu_DQ_type.Value saves the indx of the selected DQ Measure
selected_DQ_type = handles.popupmenu_DQ_type.Value;
selected_bin = handles.popupmenu_bin.Value;

table_data = ERP.dataquality(selected_DQ_type).data(:,:,selected_bin);

pSEM = 0;

pointwise_str = {'Point-wise SEM', 'Point-wise SEM, GrandAvg RMS', ...
    'Point-wise SEM Pool ERPSETs, RMS GrandAvg Combine','Point-wise SEM Pool ERPSETs, mean GrandAvg combine',...
    'Point-wise SEM (Corrected), GrandAvg RMS', ...
    'Point-wise SEM Pool ERPSETs(Corrected), RMS GrandAvg Combine',...
    'Point-wise SEM Pool ERPSETs(Corrected), mean GrandAvg combine'};

handles.pointwise_str = pointwise_str;

if isempty(table_data) %check if potentially pointwise SEM
    if any(strcmpi(pointwise_str, ERP.dataquality(selected_DQ_type).type)) && isempty(ERP.binerror) == 0
        table_data = ERP.binerror(:,:,selected_bin);
        pSEM = 1;
        
        %     elseif strcmp(ERP.dataquality(selected_DQ_type).type,'Point-wise SEM (Corrected)') && isempty(ERP.binerror) == 0
        %         table_data = ERP.binerror(:,:,selected_bin);
        %         pSEM = 1;
        %
        
    else
        
        % Data empty here.
        table_data = nan(1);
        disp('DQ data not found for this DQ type and bin. Perhaps it has been cleared?');
    end
    
    
end

handles.dq_table.Data = table_data;
handles.orig_data = table_data;

% electrode labels from ERPset, iff present and number matches
if isfield(ERP.chanlocs,'labels') && numel(ERP.chanlocs) == n_elec
    for i=1:n_elec
        elec_labels{i} = ERP.chanlocs(i).labels;
    end
else
    
    for i=1:ERP.nchan
        elec_labels{i} = i;
    end
end
handles.dq_table.RowName = elec_labels;
handles.orig_RowName = elec_labels;

% Time-window labels
if isfield(ERP.dataquality(selected_DQ_type),'time_window_labels') && isempty(ERP.dataquality(selected_DQ_type).time_window_labels) == 0  && handles.checkbox_text_labels.Value == 1
    tw_labels = ERP.dataquality(selected_DQ_type).time_window_labels;
elseif isempty(ERP.dataquality(selected_DQ_type).times)
    tw_labels = [];
else
    for i=1:n_tw
        tw_labels{i} = [num2str(ERP.dataquality(selected_DQ_type).times(i,1)) ' : ' num2str(ERP.dataquality(selected_DQ_type).times(i,2))];
    end
end
if n_tw == 0 %no ERP.dataquality.data?
    
    if pSEM == 1
        tw_labels = [];
    else
        tw_labels = 'No data here. Perhaps it was cleared?';
    end
    
end
handles.dq_table.ColumnName = tw_labels;

% Set font size of DQ Table
desired_fontsize = erpworkingmemory('fontsizeGUI');
try
    handles.dq_table.FontSize = desired_fontsize;
catch
    handles.dq_table.FontSize =11;
end
handles.heatmap_on = 0;

%
% Prepare List of current Channels
%
nchan  = ERP.nchan; % Total number of channels
if ~isfield(ERP.chanlocs,'labels')
    for e=1:nchan
        ERP.chanlocs(e).labels = ['Ch' num2str(e)];
    end
end
listch = {''};
for ch =1:nchan
    listch{ch} = [num2str(ch) ' = ' ERP.chanlocs(ch).labels ];
end
handles.listch     = listch;

chanArray = 1:ERP.nchan; %default
handles.indxlistch = chanArray; %default
handles.orig_indxlistch = chanArray;
set(handles.chwindow, 'String', vect2colon(chanArray, 'Delimiter', 'off'));


% Set outliers text window off
set(handles.stdwindow,'Enable','Off');
set(handles.chwindow,'Enable','Off');
set(handles.chbutton,'Enable','Off');
set(handles.sdcorrection,'Enable','Off');
set(handles.sdcorrection,'Visible','Off');

%set outliers value in handles off initially
handles.outliers_on = 0;

% Update handles structure
handles.ERP = ERP;

if n_erp == 0
    %case of aSME preavg
    handles.ALLERP = ERP;
else
    handles.ALLERP = ALLERP;
end
handles.checkbox_heatmap.BackgroundColor = [0.94  0.94 0.94];
handles.checkbox_outliers.BackgroundColor = [0.94  0.94 0.94];
handles.checkbox_text_labels.BackgroundColor = [0.94  0.94 0.94];
handles.chbutton.BackgroundColor = [0.94  0.94 0.94];
handles.text13.BackgroundColor = [0.94  0.94 0.94];
handles.text6.BackgroundColor = [0.94  0.94 0.94];
handles.text_ERPSET_title.BackgroundColor = [0.94  0.94 0.94];
handles.text_DQ_type.BackgroundColor = [0.94  0.94 0.94];
handles.text9.BackgroundColor = [0.94  0.94 0.94];
handles.pushbutton_mat.BackgroundColor = [1 1 1];
handles.pushbutton_xls.BackgroundColor = [1 1 1];
handles.text11.BackgroundColor = [0.94  0.94 0.94];
handles.pushbutton_selERP.BackgroundColor = [1 1 1];
handles.pushbutton_help.BackgroundColor = [1 1 1];
handles.pushbutton_done.BackgroundColor = [1 1 1];
handles.chbutton.BackgroundColor = [1 1 1];
handles.text12.BackgroundColor = [0.94  0.94 0.94];
handles.stdwindow.BackgroundColor = [1 1 1];
handles.chwindow.BackgroundColor = [1 1 1];

guidata(hObject, handles);

% UIWAIT makes DQ_Table_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DQ_Table_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = [];


% --- Executes during object creation, after setting all properties.
function text_ERPSET_title_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_ERPSET_title (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in popupmenu_DQ_type.
function popupmenu_DQ_type_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_DQ_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_DQ_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_DQ_type
% handles.popupmenu_DQ_type.Value saves the indx of the selected DQ Measure
selected_DQ_type = handles.popupmenu_DQ_type.Value;
selected_bin = handles.popupmenu_bin.Value;
pointwise_str = handles.pointwise_str;
% Check data exists, plot
if isempty(handles.ERP.dataquality(selected_DQ_type).data)
    
    % if pointwise SEM, use ERP.binerror
    if any(strcmpi(pointwise_str, handles.ERP.dataquality(selected_DQ_type).type)) && isempty(handles.ERP.binerror) == 0
        table_data = handles.ERP.binerror(:,:,selected_bin);
    else
        %     elseif strcmp(handles.ERP.dataquality(selected_DQ_type).type,'Point-wise SEM (Corrected)') && isempty(handles.ERP.binerror) == 0
        %         table_data = handles.ERP.binerror(:,:,selected_bin);
        %     else
        %
        
        
        % Data empty here.
        table_data = nan(1);
        disp('DQ data not found for this DQ type and bin. Perhaps it has been cleared?');
    end
    
else
    % data is present and correct
    
    
    if strcmp(handles.ERP.dataquality(selected_DQ_type).type,'SD Across Trials') && isempty(handles.ERP.binerror) == 0
        table_data = handles.ERP.dataquality(selected_DQ_type).data.SD_bias(:,:,selected_bin); %SD (Divided by N-1)
        set(handles.sdcorrection,'Enable','On');
        set(handles.sdcorrection,'Visible','On');
    else
        table_data = handles.ERP.dataquality(selected_DQ_type).data(:,:,selected_bin);
        set(handles.sdcorrection,'Enable','Off');
        set(handles.sdcorrection,'Visible','Off');
    end
    
end

handles.dq_table.Data = table_data;
handles.orig_data = table_data;


% Time-window labels
clear tw_labels
ERP = handles.ERP;
n_dq = numel(ERP.dataquality);
if strcmp(handles.ERP.dataquality(selected_DQ_type).type,'SD Across Trials') && isempty(handles.ERP.binerror) == 0
    [n_elec, n_tw, n_bin] = size(ERP.dataquality(selected_DQ_type).data.SD_bias);
else
    [n_elec, n_tw, n_bin] = size(ERP.dataquality(selected_DQ_type).data);
end

if isfield(ERP.dataquality(selected_DQ_type),'time_window_labels') && isempty(ERP.dataquality(selected_DQ_type).time_window_labels) == 0 && handles.checkbox_text_labels.Value == 1
    tw_labels = ERP.dataquality(selected_DQ_type).time_window_labels;
elseif isempty(ERP.dataquality(selected_DQ_type).times)
    tw_labels = [];
elseif n_tw == 0  % some data problem, no tw here
    tw_labels{1} = 'No data here - measure cleared?';
else
    for i=1:n_tw
        tw_labels{i} = [num2str(ERP.dataquality(selected_DQ_type).times(i,1)) ' : ' num2str(ERP.dataquality(selected_DQ_type).times(i,2))];
    end
end
handles.dq_table.ColumnName = tw_labels;


if handles.heatmap_on
    redraw_heatmap(hObject, eventdata, handles);
end

if handles.outliers_on
    clear_heatmap(hObject, eventdata, handles);
    handles.heatmap_on = 0;
    
    redraw_outliers(hObject, eventdata, handles);
    set(handles.checkbox_outliers,'Value',1);
end


% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function popupmenu_DQ_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_DQ_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_bin.
function popupmenu_bin_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_bin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_bin contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_bin
% handles.popupmenu_DQ_type.Value saves the indx of the selected DQ Measure
selected_DQ_type = handles.popupmenu_DQ_type.Value;
selected_bin = handles.popupmenu_bin.Value;
pointwise_str = handles.pointwise_str;
% Check data exists, plot
if isempty(handles.ERP.dataquality(selected_DQ_type).data)
    
    % if pointwise SEM, use ERP.binerror
    if any(strcmpi(pointwise_str,handles.ERP.dataquality(selected_DQ_type).type)) && isempty(handles.ERP.binerror) == 0
        table_data = handles.ERP.binerror(:,:,selected_bin);
    else
        
        % Data empty here.
        table_data = nan(1);
        disp('DQ data not found for this DQ type and bin. Perhaps it has been cleared?');
    end
    
else
    % data is present and correct
    table_data = handles.ERP.dataquality(selected_DQ_type).data(:,:,selected_bin);
end


handles.dq_table.Data = table_data;
handles.orig_data = table_data;


%if user switches bin and both heatmap & outliers on,
%use shortcircuit to clear outliers and redraw heatmap only
if handles.heatmap_on %|| handles.outliers_on
    clear_outliers(hObject, eventdata, handles);
    redraw_heatmap(hObject, eventdata, handles);
    %turn outliers off
    handles.outliers = 0;
    set(handles.checkbox_outliers,'Value',0);
    
end

%if only outliers on, then clear heatmap and redraw outliers
if handles.outliers_on
    clear_heatmap(hObject, eventdata, handles);
    handles.heatmap_on = 0;
    
    redraw_outliers(hObject, eventdata, handles);
    set(handles.checkbox_outliers,'Value',1);
end


% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu_bin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_bin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_text_labels.
function checkbox_text_labels_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_text_labels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_text_labels
selected_DQ_type = handles.popupmenu_DQ_type.Value;
selected_bin = handles.popupmenu_bin.Value;

% if strcmp(handles.ERP.dataquality(selected_DQ_type).type,'SD Across Trials') && isempty(handles.ERP.binerror) == 0
%     table_data = handles.ERP.dataquality(selected_DQ_type).data.SD_bias(:,:,selected_bin);
% else
%     table_data = handles.ERP.dataquality(selected_DQ_type).data(:,:,selected_bin);
%
% end
% handles.dq_table.Data = table_data;
% handles.orig_data = table_data;

% Time-window labels
clear tw_labels
ERP = handles.ERP;
n_dq = numel(ERP.dataquality);
%[n_elec, n_tw, n_bin] = size(ERP.dataquality(selected_DQ_type).data);
if strcmp(handles.ERP.dataquality(selected_DQ_type).type,'SD Across Trials') && isempty(handles.ERP.binerror) == 0
    [n_elec, n_tw, n_bin] = size(ERP.dataquality(selected_DQ_type).data.SD_bias);
else
    [n_elec, n_tw, n_bin] = size(ERP.dataquality(selected_DQ_type).data);
end
if isfield(ERP.dataquality(selected_DQ_type),'time_window_labels') && isempty(ERP.dataquality(selected_DQ_type).time_window_labels) == 0 && handles.checkbox_text_labels.Value == 1
    tw_labels = ERP.dataquality(selected_DQ_type).time_window_labels;
elseif isempty(ERP.dataquality(selected_DQ_type).times)
    tw_labels = [];
elseif n_tw == 0  % some data problem, no tw here
    tw_labels{1} = 'No data here - measure cleared?';
else
    for i=1:n_tw
        tw_labels{i} = [num2str(ERP.dataquality(selected_DQ_type).times(i,1)) ' : ' num2str(ERP.dataquality(selected_DQ_type).times(i,2))];
    end
end
handles.dq_table.ColumnName = tw_labels;

if handles.heatmap_on
    redraw_heatmap(hObject, eventdata, handles);
end


% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton_xls.
function pushbutton_xls_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_xls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
empty_filename = [];
selected_DQ_type = handles.popupmenu_DQ_type.Value;
%sd_correction = handles.sdcorrection.Value;
save_data_quality(handles.ERP,empty_filename,'xlsx',selected_DQ_type)



% --- Executes on button press in pushbutton_mat.
function pushbutton_mat_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_mat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
empty_filename = [];
selected_DQ_type = handles.popupmenu_DQ_type.Value;
save_data_quality(handles.ERP,empty_filename,'mat',selected_DQ_type)


% --- Executes on button press in pushbutton_help.
function pushbutton_help_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web https://github.com/lucklab/erplab/wiki/ERPLAB-Data-Quality-Metrics -browser


% --- Executes on button press in pushbutton_done.
function pushbutton_done_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%figure1_CloseRequestFcn(hObject,eventdata,handles)
delete(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in checkbox_heatmap.
function checkbox_heatmap_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_heatmap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_heatmap
heatmap_on = get(hObject,'Value');

if heatmap_on == 1
    
    %if heatmap_on, then outliers not possible so clear outliers
    clear_outliers(hObject, eventdata, handles);
    handles.outliers_on = 0;
    set(handles.checkbox_outliers, 'Value', 0);
    
    redraw_heatmap(hObject, eventdata, handles);
    handles.heatmap_on = 1;
else
    clear_heatmap(hObject, eventdata, handles);
    handles.heatmap_on = 0;
    
    %if outliers is on, then keep outliers active
    if handles.outliers_on == 1
        redraw_outliers(hOBject, eventdata,handles);
    end
    
end
% Update handles structure
guidata(hObject, handles);


function redraw_heatmap(hObject, eventdata, handles)

color_map = viridis;
data = handles.dq_table.Data;
try
    data_min = min(data(:));
catch
    disp('Cannot show text-labels while color heatmap is activated')
    return
end
range_val = max(data(:)) - data_min;
range_colormap = size(color_map,1); % as in, 256 shades?
val_increase_per_shade = range_val / range_colormap;

% Use this @ anonymous function to make HTML tag in box in loop below
colergen = @(color,text) ['<html><table border=0 width=400 bgcolor=',color,'><TR><TD>',text,'</TD></TR> </table>'];


for cell = 1:numel(data)
    data_here = data(cell);
    shades_up_here = round((data_here - data_min) / val_increase_per_shade);
    if shades_up_here < 1
        shades_up_here = 1;
    end
    if shades_up_here > range_colormap
        shades_up_here = range_colormap;
    end
    RGB_here = color_map(shades_up_here,:);
    hex_color_here = ['#' dec2hex(round(255*RGB_here(1)),2) dec2hex(round(255*RGB_here(2)),2) dec2hex(round(255*RGB_here(3)),2)];
    data2{cell} = colergen(hex_color_here,num2str(data_here));
end

data2 = reshape(data2,size(data));

handles.dq_table.Data = data2;



function clear_heatmap(hObject, eventdata, handles)
handles.dq_table.Data = handles.orig_data;


% --- Executes when entered data in editable cell(s) in dq_table.
function dq_table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to dq_table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in newerpwin.
function newerpwin_Callback(hObject, eventdata, handles)
% hObject    handle to newerpwin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns newerpwin contents as cell array
%        contents{get(hObject,'Value')} returns selected item from newerpwin


% --- Executes during object creation, after setting all properties.
function newerpwin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newerpwin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_selERP.
function pushbutton_selERP_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_selERP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected_erpset = handles.newerpwin.Value;
sel_ERP = handles.ALLERP(selected_erpset);
DQ_Table_GUI(sel_ERP, handles.ALLERP, selected_erpset,2);


% --- Executes on button press in checkbox_outliers.
function checkbox_outliers_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_outliers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_outliers

% Hint: get(hObject,'Value') returns toggle state of checkbox_heatmap
outliers_on = get(hObject,'Value'); % this is not the same as handles.outliers_on

if outliers_on == 1
    set(handles.stdwindow,'Enable','On');
    set(handles.chwindow,'Enable','On');
    set(handles.chbutton,'Enable','On');
else
    set(handles.stdwindow,'Enable','Off');
    set(handles.chwindow,'Enable','Off');
    set(handles.chbutton,'Enable','Off');
end

%updated the handles object for outliers to be in sync with hObject
if outliers_on == 1
    handles.outliers_on = 1;
else
    handles.outliers_on = 0;
end


if handles.outliers_on == 1
    
    %if heatmap is currently on, stop it and turn its states off
    %before applying outliers fxn
    
    if handles.heatmap_on == 1
        clear_heatmap(hObject, eventdata, handles);
        handles.heatmap_on = 0;
        set(handles.checkbox_heatmap, 'Value', 0);
        
        %handles.outliers_on = 1;
        redraw_outliers(hObject, eventdata, handles);
        
    else
        %handles.outliers_on = 1;
        clear_outliers(hObject, eventdata, handles);
        %guidata(hObject, handles);
        redraw_outliers(hObject, eventdata, handles);
        
        
    end
    
else %but if outliers is off, and heatmap is wanted, you can do it
    
    %     if handles.heatmap_on ==1
    %
    %         clear_outliers(hObject, eventdata, handles);
    %         redraw_heatmap(hObject, eventdata, handles);
    %         handles.outliers_on = 0;
    %
    %     else
    %         clear_outliers(hObject, eventdata, handles);
    %         handles.outliers_on = 0;
    %
    %     end
    
    %also, redraw initial data/channels without outliers
    clear_outliers(hObject, eventdata, handles)
    
end


% %if heatmap is currently on, stop it and turn its states off
% %before applying outliers fxn
% if handles.heatmap_on == 1
%
%     clear_heatmap(hObject, eventdata, handles);
%     handles.heatmap_on = 0;
%     set(handles.checkbox_heatmap, 'Value', 0);
%
%     if outliers_on == 1
%         handles.outliers_on = 1;
%         redraw_outliers(hObject, eventdata, handles);
%     else
%
%         set(handles.stdwindow,'Enable','Off');
%         set(handles.chwindow,'Enable','Off');
%         set(handles.chbutton,'Enable','Off');
%         clear_outliers(hObject, eventdata, handles);
%         handles.outliers_on = 0;
%
%     end
%
% else
%
%      if outliers_on == 1
%         handles.outliers_on = 1;
%         redraw_outliers(hObject, eventdata, handles);
%      else
%         set(handles.stdwindow,'Enable','Off');
%         set(handles.chwindow,'Enable','Off');
%         set(handles.chbutton,'Enable','Off');
%         clear_outliers(hObject, eventdata, handles);
%         handles.outliers_on = 0;
%
%      end
%
% end
% Update handles structure
guidata(hObject, handles);

function redraw_outliers(hObject, eventdata, handles)
handles = guidata(hObject); %get the most updated handles struct
data = handles.dq_table.Data;

if iscell(data)
    %in case of new std from stdwindow
    data = handles.orig_data;
end

%either default(all) or from chbutton
chans_to_use = handles.indxlistch;
data = data(chans_to_use,:);
n_elec = length(chans_to_use);
ERPtouse = handles.ERP.chanlocs;

for i=1:n_elec
    curr_chanInd = chans_to_use(i);
    elec_labels{i} = ERPtouse(curr_chanInd).labels;
end

%save new labels to handles
handles.dq_table.RowName = elec_labels;

%compute outliers as X standard deviations from mean across channels

col_means = mean(data,1);
col_std = std(data,0,1);
chosen_std = str2double((handles.stdwindow.String));

% Use this @ anonymous function to make HTML tag in box in loop below
colergen = @(color,text) ['<html><table border=0 width=400 bgcolor=',color,'><TR><TD>',text,'</TD></TR> </table>'];

for cell = 1:numel(data)
    
    data_here = data(cell);
    [d_row,d_col] = ind2sub(size(data),cell);
    
    neg_thresh = col_means(d_col) - (chosen_std*col_std(d_col));
    pos_thresh = col_means(d_col) + (chosen_std*col_std(d_col));
    
    if data_here < neg_thresh || data_here > pos_thresh
        hex_color_here = ['#' dec2hex(255,2) dec2hex(0,2) dec2hex(0,2)];
        data2{cell} = colergen(hex_color_here,num2str(data_here));
    else
        data2{cell} = num2str(data_here);
        
    end
    
end

data2= reshape(data2,size(data));
handles.dq_table.Data = data2;

function clear_outliers(hObject, eventdata, handles)
%handles = guidata(hObject);
handles.dq_table.Data = handles.orig_data;
handles.dq_table.RowName = handles.orig_RowName;
handles.indxlistch = handles.orig_indxlistch;


% Re-Prepare List of current Channels
chanArray = handles.orig_indxlistch; %default
%handles.indxlistch = chanArray; %default
set(handles.chwindow, 'String', vect2colon(chanArray, 'Delimiter', 'off'));
% Update handles structure
guidata(hObject, handles);





function stdwindow_Callback(hObject, eventdata, handles)
% hObject    handle to stdwindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

newstd = get(hObject,'String');
handles.stdwindow.String= newstd;
redraw_outliers(hObject, eventdata, handles);

guidata(hObject, handles);




% Hints: get(hObject,'String') returns contents of stdwindow as text
%        str2double(get(hObject,'String')) returns contents of stdwindow as a double


% --- Executes during object creation, after setting all properties.
function stdwindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stdwindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function chwindow_Callback(hObject, eventdata, handles)
% hObject    handle to chwindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chwindow as text
%        str2double(get(hObject,'String')) returns contents of chwindow as a double

ch = get(hObject,'string');
nch = length(handles.listch);

ch_val = eval(ch);

if ~isempty(ch)
    
    %     testch = regexpi(ch,':') ;
    %
    %     if isempty(testch)
    %
    %         try
    %             ch_val = eval(ch);
    %             handles.listch(ch_val); %attempt to index
    %
    %         catch
    %             msgboxText =  'Invalid channel input: please enter channels as integers, with a space between each number, or ch1:chN array syntax';
    %             title = 'ERPLAB: channel GUI input';
    %             errorfound(msgboxText, title);
    %
    %         end
    %     else
    %         ch_val = eval(ch);
    %
    %     end
    %
    
    tf = checkchannels(ch_val, nch, 1);
    
    if tf
        return
    end
    
    
    %     if length(ch_val) > length(handles.orig_indxlistch)
    %         msgboxText =  'Exceeded Number of Available Channels';
    %         title = 'ERPLAB: channel GUI input';
    %         errorfound(msgboxText, title);
    %         return
    %     end
    %
    set(handles.chwindow, 'String', vect2colon(ch_val, 'Delimiter', 'off'));
    handles.indxlistch = ch_val;
    % Update handles structure
    guidata(hObject, handles);
    redraw_outliers(hObject, eventdata, handles);
    guidata(hObject, handles);
    
else
    msgboxText =  'Not valid channel';
    title = 'ERPLAB: channel GUI input';
    errorfound(msgboxText, title);
    return
end



% --- Executes during object creation, after setting all properties.
function chwindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chwindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chbutton.
function chbutton_Callback(hObject, eventdata, handles)
% hObject    handle to chbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
listch = handles.listch; %true channels list as labels
indxlistch = handles.indxlistch; %true array of channel indexs
indxlistch = indxlistch(indxlistch<=length(listch)); % true array of channel index if less than expected labels
titlename = 'Select Channel(s)';
if get(hObject, 'Value')
    if ~isempty(listch)
        ch = browsechanbinGUI(listch, indxlistch, titlename);
        if ~isempty(ch)
            set(handles.chwindow, 'String', vect2colon(ch, 'Delimiter', 'off'));
            handles.indxlistch = ch;
            % Update handles structure
            guidata(hObject, handles);
            redraw_outliers(hObject, eventdata, handles);
            guidata(hObject, handles);
            
            
        else
            disp('User selected Cancel')
            return
        end
    else
        msgboxText =  'No channel information was found';
        title = 'ERPLAB: ploterp GUI input';
        errorfound(msgboxText, title);
        return
    end
end


% --- Executes during object creation, after setting all properties.
function pushbutton_selERP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_selERP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in active_erpset.
function active_erpset_Callback(hObject, eventdata, handles)
% hObject    handle to active_erpset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

newactive = get(hObject,'Value');
ERPs = handles.ALLERP;
ERP = ERPs(newactive);

n_dq = numel(ERP.dataquality);
for i=1:n_dq
    type_names{i} = ERP.dataquality(i).type;
end

handles.popupmenu_DQ_type.String = type_names;
handles.popupmenu_DQ_type.Value = n_dq;


[n_elec, n_tw, n_bin] = size(ERP.dataquality(n_dq).data);

if n_elec == 0
    % if the dq data is of zero size, then the 3rd dim may be mis-sized.
    % So set to default of ERP.nbin instead.
    n_bin = ERP.nbin;
end

n_bin_names = numel(ERP.bindescr);
if n_bin_names == n_bin
    
    for i=1:n_bin
        bin_names{i} = ['BIN ' num2str(i) ' - ' ERP.bindescr{i}];
    end
else
    % if not every bin has a bin description, leave then off
    for i=1:n_bin
        bin_names{i} = ['BIN ' num2str(i)];
    end
end


handles.popupmenu_bin.String = bin_names;

% handles.popupmenu_DQ_type.Value saves the indx of the selected DQ Measure
selected_DQ_type = handles.popupmenu_DQ_type.Value;
selected_bin = handles.popupmenu_bin.Value;

table_data = ERP.dataquality(selected_DQ_type).data(:,:,selected_bin);
handles.dq_table.Data = table_data;
handles.orig_data = table_data;

% electrode labels from ERPset, iff present and number matches
if isfield(ERP.chanlocs,'labels') && numel(ERP.chanlocs) == n_elec
    for i=1:n_elec
        elec_labels{i} = ERP.chanlocs(i).labels;
    end
else
    
    for i=1:ERP.nchan
        elec_labels{i} = i;
    end
end
handles.dq_table.RowName = elec_labels;

% Time-window labels
if isfield(ERP.dataquality(selected_DQ_type),'time_window_labels') && isempty(ERP.dataquality(selected_DQ_type).time_window_labels) == 0  && handles.checkbox_text_labels.Value == 1
    tw_labels = ERP.dataquality(selected_DQ_type).time_window_labels;
elseif isempty(ERP.dataquality(selected_DQ_type).times)
    tw_labels = [];
else
    for i=1:n_tw
        tw_labels{i} = [num2str(ERP.dataquality(selected_DQ_type).times(i,1)) ' : ' num2str(ERP.dataquality(selected_DQ_type).times(i,2))];
    end
end
if n_tw == 0
    tw_labels = 'No data here. Perhaps it was cleared?';
end
handles.dq_table.ColumnName = tw_labels;

% Set font size of DQ Table
desired_fontsize = erpworkingmemory('fontsizeGUI');
handles.dq_table.FontSize = desired_fontsize;
handles.heatmap_on = handles.checkbox_heatmap.Value;

%
% Prepare List of current Channels
%
nchan  = ERP.nchan; % Total number of channels
if ~isfield(ERP.chanlocs,'labels')
    for e=1:nchan
        ERP.chanlocs(e).labels = ['Ch' num2str(e)];
    end
end
listch = {''};
for ch =1:nchan
    listch{ch} = [num2str(ch) ' = ' ERP.chanlocs(ch).labels ];
end
handles.listch     = listch;

chanArray = 1:ERP.nchan; %default
handles.indxlistch = chanArray; %default
set(handles.chwindow, 'String', vect2colon(chanArray, 'Delimiter', 'off'));



% Set outliers text window off
set(handles.stdwindow,'Enable','Off');
set(handles.chwindow,'Enable','Off');
set(handles.chbutton,'Enable','Off');

% Update handles structure
handles.ERP = ERP;
handles.ALLERP = ERPs;


%clear all perviously set options
set(handles.checkbox_outliers,'Value',0);
% set(handles.checkbox_heatmap,'Value',0);
set(handles.checkbox_text_labels,'Value',0);
set(handles.stdwindow,'Enable','Off');
set(handles.chwindow,'Enable','Off');
set(handles.chbutton,'Enable','Off');

%check to see if outliers is on prior to switching active erpset?
%checkbox_outliers_Callback(hObject, eventdata, handles)

heatmap_on = handles.heatmap_on ;
if heatmap_on == 1
    
    %if heatmap_on, then outliers not possible so clear outliers
    clear_outliers(hObject, eventdata, handles);
    handles.outliers_on = 0;
    set(handles.checkbox_outliers, 'Value', 0);
    redraw_heatmap(hObject, eventdata, handles);
    handles.heatmap_on = 1;
else
    clear_heatmap(hObject, eventdata, handles);
    handles.heatmap_on = 0;
    
    %if outliers is on, then keep outliers active
    if handles.outliers_on == 1
        redraw_outliers(hOBject, eventdata,handles);
    end
end

guidata(hObject, handles);

% Hints: contents = cellstr(get(hObject,'String')) returns active_erpset contents as cell array
%        contents{get(hObject,'Value')} returns selected item from active_erpset


% --- Executes during object creation, after setting all properties.
function active_erpset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to active_erpset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function tf = checkchannels(chx, nchan, showmsg)

if nargin<3
    showmsg = 1;
end
tf = 0; % no problem by default

if ~mod(chx, 1) == 0
    if showmsg
        msgboxText =  'Invalid channel indexing.';
        title = 'ERPLAB: basicfilterGUI() error:';
        errorfound(msgboxText, title);
    end
    tf = 1; %
    
end

if isempty(chx)
    if showmsg
        msgboxText =  'Invalid channel indexing.';
        title = 'ERPLAB: basicfilterGUI() error:';
        errorfound(msgboxText, title);
    end
    tf = 1; %
    return
end
if ~isempty(find(chx>nchan))
    if showmsg
        msgboxText =  ['You only have %g channels,\n'...
            'so you cannot specify indices greater than this.'];
        title = 'ERPLAB: basicfilterGUI() error:';
        errorfound(sprintf(msgboxText, nchan), title);
    end
    tf = 1; %
    return
end
if ~isempty(find(chx<1))
    if showmsg
        msgboxText =  'You cannot use zero or a negative number as a channel indexing';
        title = 'ERPLAB: basicfilterGUI() error:';
        errorfound(msgboxText, title);
    end
    tf = 1; %
    return
end
if length(chx)>length(unique_bc2(chx))
    if showmsg
        msgboxText =  ['Repeated channels are not allowed.\n'...
            'Therefore, ERPLAB will get rid of them.'];
        title = 'ERPLAB: basicfilterGUI() error:';
        errorfound(sprintf(msgboxText), title, [1 1 0], [0 0 0], 0)
    end
    tf = 0; %
    return
end


% --- Executes on button press in sdcorrection.
function sdcorrection_Callback(hObject, eventdata, handles)
% hObject    handle to sdcorrection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected_DQ_type = handles.popupmenu_DQ_type.Value;
selected_bin = handles.popupmenu_bin.Value;

if handles.sdcorrection.Value == 1
    table_data = handles.ERP.dataquality(selected_DQ_type).data.SD_unbias(:,:,selected_bin); %SD (Gurland & Tripathi, 1971)
else
    table_data = handles.ERP.dataquality(selected_DQ_type).data.SD_bias(:,:,selected_bin); %SD (N-1)
end
handles.dq_table.Data = table_data;
handles.orig_data = table_data;

%update handles struct
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of sdcorrection


% --- Executes during object creation, after setting all properties.
function checkbox_outliers_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox_outliers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
