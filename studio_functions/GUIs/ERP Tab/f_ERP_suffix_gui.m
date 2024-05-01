function varargout = f_ERP_suffix_gui(varargin)
% F_ERP_SUFFIX_GUI MATLAB code for f_ERP_suffix_gui.fig
%      F_ERP_SUFFIX_GUI, by itself, creates a new F_ERP_SUFFIX_GUI or raises the existing
%      singleton*.
%
%      H = F_ERP_SUFFIX_GUI returns the handle to a new F_ERP_SUFFIX_GUI or the handle to
%      the existing singleton*.
%
%      F_ERP_SUFFIX_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in F_ERP_SUFFIX_GUI.M with the given input arguments.
%
%      F_ERP_SUFFIX_GUI('Property','Value',...) creates a new F_ERP_SUFFIX_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before f_ERP_suffix_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to f_ERP_suffix_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help f_ERP_suffix_gui

% Last Modified by GUIDE v2.5 02-Aug-2022 18:45:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @f_ERP_suffix_gui_OpeningFcn, ...
    'gui_OutputFcn',  @f_ERP_suffix_gui_OutputFcn, ...
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


% --- Executes just before f_ERP_suffix_gui is made visible.
function f_ERP_suffix_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for f_ERP_suffix_gui

try
    erpname  = varargin{1};
    
catch
    erpname  = '';
    
end

handles.erpnameor = erpname;
handles.output = [];
erpmenu  = findobj('tag', 'erpsets');

if ~isempty(erpmenu)
    handles.menuerp = get(erpmenu);
    set(handles.menuerp.Children, 'Enable','off');
end


erplab_default_values;
version = erplabver;
set(handles.gui_chassis,'Name', ['EStudio ' version '   -   Add Suffix GUI'])
set(handles.edit_erpname, 'String', erpname);

set(handles.current_erp_label,'String', ['Enter suffix, which will be added onto the name of each selected ERPset'],...
    'FontWeight','Bold', 'FontSize', 16);

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
function varargout = f_ERP_suffix_gui_OutputFcn(hObject, eventdata, handles)

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


function edit_erpname_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_erpname_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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


handles.output = erpname;
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
