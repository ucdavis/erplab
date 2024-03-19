function varargout = f_EEG_update_gui(varargin)
% F_EEG_UPDATE_GUI MATLAB code for f_EEG_update_gui.fig
%      F_EEG_UPDATE_GUI, by itself, creates a new F_EEG_UPDATE_GUI or raises the existing
%      singleton*.
%
%      H = F_EEG_UPDATE_GUI returns the handle to a new F_EEG_UPDATE_GUI or the handle to
%      the existing singleton*.
%
%      F_EEG_UPDATE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in F_EEG_UPDATE_GUI.M with the given input arguments.
%
%      F_EEG_UPDATE_GUI('Property','Value',...) creates a new F_EEG_UPDATE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before f_EEG_update_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to f_EEG_update_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help f_EEG_update_gui

% Last Modified by GUIDE v2.5 17-Mar-2024 18:26:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @f_EEG_update_gui_OpeningFcn, ...
    'gui_OutputFcn',  @f_EEG_update_gui_OutputFcn, ...
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


% --- Executes just before f_EEG_update_gui is made visible.
function f_EEG_update_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for f_EEG_update_gui

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

erplab_studio_default_values;
version = erplabstudiover;

set(handles.gui_chassis,'Name', ['Estudio ' version '   -   Inspect/Label ICs tool GUI'])
% set(handles.edit_erpname, 'String', '_processed');
handles.current_erp_label.String = 'While you are using the Inspect/Label ICs tool, the main ERPLAB Studio window will be frozen. Click "Okay" when you have closed the Inspect/Label ICs tool.';

handles.pushbutton4_okay.String = 'Okay';

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
function varargout = f_EEG_update_gui_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
% try
%     set(handles.menuerp.Children, 'Enable','on');
% catch
%     disp('ERPset menu was not found...')
% end
try
varargout{1} = handles.output;
catch
  varargout{1} =0;  
end
pause(0.1)





% --- Executes during object creation, after setting all properties.
function edit_erpname_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_Cancel.
function pushbutton_Cancel_Callback(hObject, eventdata, handles)
handles.output = 0;
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);


% --- Executes on button press in pushbutton4_okay.
function pushbutton4_okay_Callback(hObject, eventdata, handles)


handles.output =1;
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
