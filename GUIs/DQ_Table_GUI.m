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

% Last Modified by GUIDE v2.5 05-Aug-2020 04:05:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
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
ERPSET_title_str = ['ERPSET - ' ERP.erpname];
handles.text_ERPSET_title.String = ERPSET_title_str;

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

handles.heatmap_on = 0;

% Update handles structure
handles.ERP = ERP;
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

% Check data exists, plot
if isempty(handles.ERP.dataquality(selected_DQ_type).data)
    
    % if pointwise SEM, use ERP.binerror
    if strcmp(handles.ERP.dataquality(selected_DQ_type).type,'Point-wise SEM') && isempty(handles.ERP.binerror) == 0
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

% Time-window labels
clear tw_labels
ERP = handles.ERP;
n_dq = numel(ERP.dataquality);
[n_elec, n_tw, n_bin] = size(ERP.dataquality(selected_DQ_type).data);
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

% Check data exists, plot
if isempty(handles.ERP.dataquality(selected_DQ_type).data)
    
    % if pointwise SEM, use ERP.binerror
    if strcmp(handles.ERP.dataquality(selected_DQ_type).type,'Point-wise SEM') && isempty(handles.ERP.binerror) == 0
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

if handles.heatmap_on
    redraw_heatmap(hObject, eventdata, handles);
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

table_data = handles.ERP.dataquality(selected_DQ_type).data(:,:,selected_bin);
handles.dq_table.Data = table_data;
handles.orig_data = table_data;

% Time-window labels
clear tw_labels
ERP = handles.ERP;
n_dq = numel(ERP.dataquality);
[n_elec, n_tw, n_bin] = size(ERP.dataquality(selected_DQ_type).data);
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
save_data_quality(handles.ERP,empty_filename,'xls',selected_DQ_type)



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
web https://github.com/lucklab/erplab/wiki/ -browser


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
    handles.heatmap_on = 1;
    redraw_heatmap(hObject, eventdata, handles);
    
else
    handles.heatmap_on = 0;
    clear_heatmap(hObject, eventdata, handles);
    
end
% Update handles structure
guidata(hObject, handles);
    

function redraw_heatmap(hObject, eventdata, handles)

color_map = viridis;
data = handles.dq_table.Data;

data_min = min(data(:));
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

