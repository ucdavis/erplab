function  varargout = insertcodeatTTL(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
      'gui_Singleton',  gui_Singleton, ...
      'gui_OpeningFcn', @insertcodeatTTL_OpeningFcn, ...
      'gui_OutputFcn',  @insertcodeatTTL_OutputFcn, ...
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

%--------------------------------------------------------------------------
function insertcodeatTTL_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%
% Color GUI
%
handles = painterplab(handles);

% UIWAIT makes insertcodeonthefly2GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);

%--------------------------------------------------------------------------
function varargout = insertcodeatTTL_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.figure1);
pause(0.1)

%--------------------------------------------------------------------------
function popupmenu1_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_threshold_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_threshold_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_TTL_channel_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_TTL_channel_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_channel_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_channel_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_TTL_duration_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_TTL_duration_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit4_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_TTL_eventcode_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_TTL_eventcode_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);

%--------------------------------------------------------------------------
function pushbutton_RUN_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function figure1_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
      %The GUI is still in UIWAIT, us UIRESUME
      handles.output = '';
      %Update handles structure
      guidata(hObject, handles);
      uiresume(handles.figure1);
else
      % The GUI is no longer waiting, just close it
      delete(handles.figure1);
end
