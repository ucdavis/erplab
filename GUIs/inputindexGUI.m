function varargout = inputindexGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @inputindexGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @inputindexGUI_OutputFcn, ...
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


% --- Executes just before inputindexGUI is made visible.
function inputindexGUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = [];

try
      prompt    = char(varargin{1});
      num_lines = varargin{2};
      def       = varargin{3};      
catch
      prompt    = 'Enter value';
      num_lines = 1;
      def       = 1;
end

set(handles.uipanel_prompt,'Title', prompt)
set(handles.popupmenu_value,'String', cellstr(num2str(([1:num_lines]'))))
set(handles.popupmenu_value,'Value', def)

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

% help
% helpbutton

% UIWAIT makes inputindexGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

% -----------------------------------------------------------------------
function varargout = inputindexGUI_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

% -----------------------------------------------------------------------
function pushbutton_CANCEL_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

% -----------------------------------------------------------------------
function pushbutton_OK_Callback(hObject, eventdata, handles)

value = get(handles.popupmenu_value,'Value'); % JLC, 30 Aug 2012
handles.output = {value};

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);
% -----------------------------------------------------------------------
function popupmenu_value_Callback(hObject, eventdata, handles)

% -----------------------------------------------------------------------
function popupmenu_value_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% -----------------------------------------------------------------------
function uipanel_prompt_CreateFcn(hObject, eventdata, handles)

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
