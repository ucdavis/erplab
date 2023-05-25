function varargout = f_ERP_save_single_file(varargin)
% F_ERP_SAVE_SINGLE_FILE MATLAB code for f_ERP_save_single_file.fig
%      F_ERP_SAVE_SINGLE_FILE, by itself, creates a new F_ERP_SAVE_SINGLE_FILE or raises the existing
%      singleton*.
%
%      H = F_ERP_SAVE_SINGLE_FILE returns the handle to a new F_ERP_SAVE_SINGLE_FILE or the handle to
%      the existing singleton*.
%
%      F_ERP_SAVE_SINGLE_FILE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in F_ERP_SAVE_SINGLE_FILE.M with the given input arguments.
%
%      F_ERP_SAVE_SINGLE_FILE('Property','Value',...) creates a new F_ERP_SAVE_SINGLE_FILE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before f_ERP_save_single_file_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to f_ERP_save_single_file_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help f_ERP_save_single_file

% Last Modified by GUIDE v2.5 02-Aug-2022 18:34:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @f_ERP_save_single_file_OpeningFcn, ...
    'gui_OutputFcn',  @f_ERP_save_single_file_OutputFcn, ...
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


% --- Executes just before f_ERP_save_single_file is made visible.
function f_ERP_save_single_file_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for f_ERP_save_single_file

try
    erpname  = varargin{1};
    filename = varargin{2};
    currenterp = varargin{3};
    [pathstr, file_name, ext] = fileparts(erpname);
    erpname =file_name;
catch
    erpname  = '';
    filename = '';
    currenterp = '';
end

handles.erpnameor = erpname;
handles.output = [];
erpmenu  = findobj('tag', 'erpsets');

if ~isempty(erpmenu)
    handles.menuerp = get(erpmenu);
    set(handles.menuerp.Children, 'Enable','off');
end

erplab_studio_default_values;
version = erplabstudiover;
set(handles.gui_chassis,'Name', ['EStudio ' version '   -   Save single Erpset GUI'])
set(handles.edit_erpname, 'String', erpname);
set(handles.radio_erpname,'Value',1);
if isempty(currenterp)
    set(handles.current_erp_label,'String', ['No active erpset was found'],...
                'FontWeight','Bold', 'FontSize', 16);
else
    
    set(handles.current_erp_label,'String', ['Your active erpset is # ' num2str(currenterp)],...
                'FontWeight','Bold', 'FontSize', 16)
end
if ~isempty(filename)
    set(handles.edit_filename, 'Enable', 'off');
    set(handles.edit_filename, 'String', '');
    set(handles.radiobutton_saveas, 'Value', 0);
    set(handles.filename_erpname, 'Enable', 'off');
    set(handles.erpname_filename, 'Enable', 'off');
    set(handles.pushbutton_browse, 'Enable', 'off');
else
    set(handles.edit_filename, 'String', '');
    set(handles.radiobutton_saveas, 'Value', 0);
    set(handles.edit_filename, 'Enable', 'off');
    set(handles.filename_erpname, 'Enable', 'off');
    set(handles.erpname_filename, 'Enable', 'off');
    set(handles.pushbutton_browse, 'Enable', 'off');
end
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
set(handles.filename_erpname,'BackgroundColor','white')

% UIWAIT makes savemyerpGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);




% --- Outputs from this function are returned to the command line.
function varargout = f_ERP_save_single_file_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
% try
%     set(handles.menuerp.Children, 'Enable','on');
% catch
%     disp('ERPset menu was not found...')
% end
varargout{1} = handles.output;
delete(handles.gui_chassis);
pause(0.1)




% --- Executes on button press in radio_erpname.
function radio_erpname_Callback(hObject, eventdata, handles)
% hObject    handle to radio_erpname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_erpname
Value_radio_erpname = get(hObject,'Value');
set(handles.radio_erpname, 'Value', 1);



function edit_erpname_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_erpname_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in erpname_filename.
function erpname_filename_Callback(hObject, eventdata, handles)

fname   = get(handles.edit_filename, 'String');
%
if strcmp(fname,'')
    msgboxText =  'You must enter a filename first!';
    title = 'ERPLAB: f_ERP_save_single GUI empty filename';
    errorfound(msgboxText, title);
    return
end
[pathstr, fname, ext] = fileparts(fname);
erpname = fname;
set(handles.edit_erpname, 'String', erpname);


% --- Executes on button press in radiobutton_saveas.
function radiobutton_saveas_Callback(hObject, eventdata, handles)

if get(hObject, 'Value')
    set(handles.edit_filename, 'Enable', 'on');
    set(handles.filename_erpname, 'Enable', 'on');
    set(handles.pushbutton_browse, 'Enable', 'on');
    set(handles.erpname_filename, 'Enable', 'on');
else
    set(handles.edit_filename, 'Enable', 'off');
    set(handles.filename_erpname, 'Enable', 'off');
    set(handles.pushbutton_browse, 'Enable', 'off');
    set(handles.erpname_filename, 'Enable', 'off');
    set(handles.edit_filename, 'String', '');
end


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


% --- Executes on button press in filename_erpname.
function filename_erpname_Callback(hObject, eventdata, handles)
% hObject    handle to filename_erpname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fname   = get(handles.edit_erpname, 'String');
%
if strcmp(fname,'') || isempty(fname)
    msgboxText =  'You must enter a filename first!';
    title = 'ERPLAB: f_ERP_save_single GUI empty filename';
    errorfound(msgboxText, title);
    return
end
[pathstr, fname, ext] = fileparts(fname);
erpname = fname;
set(handles.edit_filename, 'String', erpname);




% --- Executes on button press in pushbutton_browse.
function pushbutton_browse_Callback(hObject, eventdata, handles)
fndefault = get(handles.edit_filename,'String');
[fname, pathname] = uiputfile({'*.erp', 'ERPset (*.erp)';...
    '*.mat', 'MAT-files (*.mat)';...
    '*.*'  , 'All Files (*.*)'},'Save Output file as',...
    fndefault);

if isequal(fname,0)
    disp('User selected Cancel')
    guidata(hObject, handles);
    handles.owfp = 0;  % over write file permission
    guidata(hObject, handles);
else
    set(handles.edit_filename,'String', fullfile(pathname, fname));
    %         disp(['To save ERP, user selected ', fullfile(pathname, fname)])
    handles.owfp = 1;  % over write file permission
    guidata(hObject, handles);
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
erpname = strtrim(get(handles.edit_erpname, 'String'));

if isempty(erpname)
    msgboxText =  'You must enter an erpname at least!';
    title = 'EStudio: f_ERP_save_single_file empty erpname';
    errorfound(msgboxText, title);
    return
end

fname   = strtrim(get(handles.edit_filename, 'String'));
if ~isempty(fname) && get(handles.radiobutton_saveas, 'Value')
    
    [pathstr, name, ext] = fileparts(fname);
    
    if ~strcmp(ext,'.erp') && ~strcmp(ext,'.mat')
        ext = '.erp';
    end
    if strcmp(pathstr,'')
        pathstr = cd;
    end
    
    fullname = fullfile(pathstr, [name ext]);
elseif isempty(fname) && get(handles.radiobutton_saveas, 'Value')
    msgboxText =  'You must enter a filename!';
    title = 'EStudio: f_ERP_save_single_file empty filename';
    errorfound(msgboxText, title);
    return;
else
    fullname = [];
end

handles.output = {erpname, fullname};
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
