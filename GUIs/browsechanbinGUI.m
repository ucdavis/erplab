function varargout = browsechanbinGUI(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @browsechanbinGUI_OpeningFcn, ...
        'gui_OutputFcn',  @browsechanbinGUI_OutputFcn, ...
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

%-----------------------------------------------------------------------------------
function browsechanbinGUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = [];

try
        list = varargin{1};
catch
        list = {'A' 'B' 'C'};
end
try
        indxlistb = varargin{2};
catch
        indxlistb = [];
end
try
        titlename = varargin{3};
catch
        titlename = 'Testing this GUI';
end

%
% Color GUI
%
handles = painterplab(handles);

%
% Set font size
%
handles = setfonterplab(handles);

% Update handles structure
guidata(hObject, handles);

set(handles.listbox_list, 'Max', 2);
set(handles.listbox_list, 'String', list);
set(handles.listbox_list, 'Value', indxlistb);
set(handles.gui_chassis, 'Name', titlename, 'WindowStyle','modal');


% UIWAIT makes browsechanbinGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);


%-----------------------------------------------------------------------------------
function varargout = browsechanbinGUI_OutputFcn(hObject, eventdata, handles)
try
        varargout{1} = handles.output;
catch
        varargout{1} = [];
end
% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

%----------------------------------------------------------------------------------
function listbox_list_Callback(hObject, eventdata, handles)

%----------------------------------------------------------------------------------
function listbox_list_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%----------------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);
%----------------------------------------------------------------------------------
function pushbutton_ok_Callback(hObject, eventdata, handles)

val = get(handles.listbox_list, 'Value');
handles.output = val;

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%----------------------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        uiresume(handles.gui_chassis);
else
        % The GUI is no longer waiting, just close it
        delete(handles.gui_chassis);
end
