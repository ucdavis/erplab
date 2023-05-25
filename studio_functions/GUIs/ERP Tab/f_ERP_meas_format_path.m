function varargout = f_ERP_meas_format_path(varargin)
% F_ERP_MEAS_FORMAT_PATH MATLAB code for f_ERP_meas_format_path.fig
%      F_ERP_MEAS_FORMAT_PATH, by itself, creates a new F_ERP_MEAS_FORMAT_PATH or raises the existing
%      singleton*.
%
%      H = F_ERP_MEAS_FORMAT_PATH returns the handle to a new F_ERP_MEAS_FORMAT_PATH or the handle to
%      the existing singleton*.
%
%      F_ERP_MEAS_FORMAT_PATH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in F_ERP_MEAS_FORMAT_PATH.M with the given input arguments.
%
%      F_ERP_MEAS_FORMAT_PATH('Property','Value',...) creates a new F_ERP_MEAS_FORMAT_PATH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before f_ERP_meas_format_path_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to f_ERP_meas_format_path_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help f_ERP_meas_format_path

% Last Modified by GUIDE v2.5 07-Aug-2022 18:19:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @f_ERP_meas_format_path_OpeningFcn, ...
    'gui_OutputFcn',  @f_ERP_meas_format_path_OutputFcn, ...
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


% --- Executes just before f_ERP_meas_format_path is made visible.
function f_ERP_meas_format_path_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for f_ERP_meas_format_path

try
    foutputstr  = varargin{1}; %% 1. long; 0 wide
    pathName= varargin{2};
    
catch
    foutputstr  = 1; %% 1. long; 0 wide
    pathName= cd;
end

handles.output = [];
erpmenu  = findobj('tag', 'erpsets');
handles.pathName = pathName;
if ~isempty(erpmenu)
    handles.menuerp = get(erpmenu);
    set(handles.menuerp.Children, 'Enable','off');
end

erplab_studio_default_values;
version = erplabstudiover;
set(handles.gui_chassis,'Name', ['EStudio ' version '   -   ERP Measurement Tool'])


set(handles.current_erp_label,'String', ['ERP Measurement Tool: File format and path'],...
    'FontWeight','Bold', 'FontSize', 16);
if foutputstr
    set(handles.radiobutton_wide, 'Value', 1);
    set(handles.radiobutton5_long, 'Value', 0);
else
    set(handles.radiobutton_wide, 'Value', 0);
    set(handles.radiobutton5_long, 'Value', 1);
end
set(handles.edit_filename, 'String', pathName);
%
% % Color GUI
% %
handles = painterplabstudio(handles);
%
% %
% % Set font size
% %
handles = setfonterplabestudio(handles);

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes savemyerpGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);




% --- Outputs from this function are returned to the command line.
function varargout = f_ERP_meas_format_path_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
% try
%     set(handles.menuerp.Children, 'Enable','on');
% catch
%     disp('ERPset menu was not found...')
% end
varargout{1} = handles.output;
delete(handles.gui_chassis);
pause(0.1)




% % --- Executes on button press in radio_erpname.
% function radio_erpname_Callback(hObject, eventdata, handles)
% % hObject    handle to radio_erpname (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
%
% % Hint: get(hObject,'Value') returns toggle state of radio_erpname
% Value_radio_erpname = get(hObject,'Value');
% set(handles.radio_erpname, 'Value', 1);



% % --- Executes on button press in radiobutton_saveas.
% function radiobutton_saveas_Callback(hObject, eventdata, handles)
%
% if get(hObject, 'Value')
%     set(handles.edit_filename, 'Enable', 'on');
%     set(handles.filename_erpname, 'Enable', 'on');
%     set(handles.pushbutton_browse, 'Enable', 'on');
%     set(handles.erpname_filename, 'Enable', 'on');
% else
%     set(handles.edit_filename, 'Enable', 'off');
%     set(handles.filename_erpname, 'Enable', 'off');
%     set(handles.pushbutton_browse, 'Enable', 'off');
%     set(handles.erpname_filename, 'Enable', 'off');
%     set(handles.edit_filename, 'String', '');
% end


function edit_filename_Callback(hObject, eventdata, handles)
% hObject    handle to edit_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_filename as text
%        str2double(get(hObject,'String')) returns contents of edit_filename as a double


% --- Executes during object creation, after setting all properties.
function edit_filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton_wide.
function radiobutton_wide_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_wide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_wide
set(handles.radiobutton_wide, 'Value', 1);
set(handles.radiobutton5_long, 'Value', 0);

% --- Executes on button press in radiobutton5_long.
function radiobutton5_long_Callback(hObject, eventdata, handles)
set(handles.radiobutton_wide, 'Value', 0);
set(handles.radiobutton5_long, 'Value', 1);






% --- Executes on button press in pushbutton_browse.
function pushbutton_browse_Callback(hObject, eventdata, handles)

pathName = handles.pathName;

title = 'Save output file as';

[filename, filepath,filterindex] = uiputfile({'*.txt'; '*.dat'}, ...
    title,pathName);

if isequal(filterindex,0)
    disp('User selected Cancel');
    return;
else
    [px, fname, ext] = fileparts(filename);
    if strcmp(ext,'')
        if filterindex==1 || filterindex==3
            ext   = '.txt';
        else
            ext   = '.dat';
        end
    end
    Filename = [fname ext];
    set(handles.edit_filename,'String',fullfile(filepath,Filename));
end





% --- Executes on button press in pushbutton_Cancel.
function pushbutton_Cancel_Callback(hObject, eventdata, handles)
handles.output = [];
beep;
disp('User selected Cancel')
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);


% --- Executes on button press in pushbutton4_okay.
function pushbutton4_okay_Callback(hObject, eventdata, handles)
Filename = strtrim(get(handles.edit_filename, 'String'));

[px, fname, ext] = fileparts(Filename);
if isempty(fname)
    msgboxText =  'You must enter a name for the saved file at least!';
    title = 'EStudio: f_ERP_save_single_file empty filename';
    errorfound(msgboxText, title);
    return
end


Wide_fromat = (get(handles.radiobutton_wide, 'Value'));

Long_fromat = (get(handles.radiobutton5_long, 'Value'));


if Wide_fromat
    FileFormat = 1;
elseif Long_fromat
    FileFormat = 0;
end

handles.output = {FileFormat, Filename};
% Update handles structure
guidata(hObject, handles);

uiresume(handles.gui_chassis);




% -----------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
    %The GUI is still in UIWAIT, us UIRESUME
    handles.output = '';
    %Update handles structure
    guidata(hObject, handles);
    uiresume(handles.gui_chassis);
else
    % The GUI is no longer waiting, just close it
    delete(handles.gui_chassis);
end
