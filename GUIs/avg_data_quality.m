function varargout = avg_data_quality(varargin)
% AVG_DATA_QUALITY MATLAB code for avg_data_quality.fig
%      AVG_DATA_QUALITY, by itself, creates a new AVG_DATA_QUALITY or raises the existing
%      singleton*.
%
%      H = AVG_DATA_QUALITY returns the handle to a new AVG_DATA_QUALITY or the handle to
%      the existing singleton*.
%
%      AVG_DATA_QUALITY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AVG_DATA_QUALITY.M with the given input arguments.
%
%      AVG_DATA_QUALITY('Property','Value',...) creates a new AVG_DATA_QUALITY or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before avg_data_quality_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to avg_data_quality_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help avg_data_quality

% Last Modified by GUIDE v2.5 18-Oct-2018 06:52:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @avg_data_quality_OpeningFcn, ...
                   'gui_OutputFcn',  @avg_data_quality_OutputFcn, ...
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

% --- Executes just before avg_data_quality is made visible.
function avg_data_quality_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to avg_data_quality (see VARARGIN)

handles.output = hObject;

disp('Awaiting Data Quality settings...');

% Choose default command line output for avg_data_quality

handles.DQout = zeros(2,3);
handles.tupdate = 0;
handles.num_tests = 1;

handles.paraSME = 1;
handles.tdata = handles.SME_table.Data;

handles.Tout = handles.tdata;
disp(handles.Tout);

% Update handles structure
guidata(hObject, handles);

%helpbutton
initialize_gui(hObject, handles, false);

% UIWAIT makes avg_data_quality wait for user response (see UIRESUME)
uiwait(handles.avg_dq);


% --- Outputs from this function are returned to the command line.
function varargout = avg_data_quality_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
pause(0.1)
% Update handles structure
guidata(hObject, handles);

% Get default command line output from handles structure
varargout{1} = handles.output;
% The figure can be deleted now
pause(0.1)
delete(handles.avg_dq);
pause(0.1)

% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('User canceled Advanced Data Quality options.');
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.avg_dq);


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp('Saving Data Quality settings...');

if handles.paraSME == 1
    num_tests = 1;
    type = 'SME';
end

DQout.num_tests = num_tests;
DQout(1).type = type;
DQout(1).times = handles.Tout;

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
disp(SME_here);
if SME_here
    set(handles.SME_table,'Enable','on');
else
    set(handles.SME_table,'Enable','off');
end


function pushbutton_help_Callback(hObject, eventdata, handles)
% doc pop_averager
web https://github.com/lucklab/erplab/wiki/Computing-Averaged-ERPs -browser


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

if curr_rows <= 1
    beep
    disp('Already at 1 rows')
else
    new_rows = curr_rows - 1;
    
    new_Tout = handles.Tout(1:new_rows,:);
    handles.Tout = new_Tout;
    
%     row_drop_txt = ['The number of rows was ' num2str(curr_rows) '. Now dropping to ' num2str(new_rows)];
% disp(row_drop_txt)
set(handles.SME_table,'Data',new_Tout)
    
end


guidata(hObject, handles);


% --- Executes on button press in SME_row_plus.
function SME_row_plus_Callback(hObject, eventdata, handles)
% hObject    handle to SME_row_plus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

curr_rows = size(handles.Tout,1);


    new_rows = curr_rows + 1;
    
    new_Tout = zeros(new_rows,size(handles.Tout,2));
    
    new_Tout(1:curr_rows,:) = handles.Tout(1:curr_rows,:);
    handles.Tout = new_Tout;
    
%     row_drop_txt = ['The number of rows was ' num2str(curr_rows) '. Now increasing to ' num2str(new_rows)];
% disp(row_drop_txt)
set(handles.SME_table,'Data',new_Tout)
    


guidata(hObject, handles);
