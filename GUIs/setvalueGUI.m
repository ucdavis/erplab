% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2012

function varargout = setvalueGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @setvalueGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @setvalueGUI_OutputFcn, ...
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


% --- Executes just before setvalueGUI is made visible.
function setvalueGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for setvalueGUI
handles.output = [];

try
      def = varargin{1};
catch
      def = {8.8 1};
end
if isempty(def{1}) || isempty(def{2})
      def = {8.8 1};
end
if def{1}<=0
      def{1}=8.8;
end
if ~strcmpi(def{2},'points') && ~strcmpi(def{2},'pixels')
      def{2}='points';
end
set(handles.popupmenu_units, 'String', {'points','pixels'})
set(handles.edit_fontsize, 'String', num2str(def{1}));

funits = def{2};
switch funits
      case 'points'
            fu = 1;
      case 'pixels'
            fu = 2;
      otherwise
            fu = 1;
end
set(handles.popupmenu_units, 'Value', fu)

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   Font size'])

%
% Color GUI and font soze
%
handles = painterplab(handles);
handles = setfonterplab(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes setvalueGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);


% --- Outputs from this function are returned to the command line.
function varargout = setvalueGUI_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

%------------------------------------------------------------------------------
function edit_fontsize_Callback(hObject, eventdata, handles)

%------------------------------------------------------------------------------
function edit_fontsize_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%------------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%------------------------------------------------------------------------------
function pushbutton_ok_Callback(hObject, eventdata, handles)

answer  = get(handles.edit_fontsize,'String');
nanswer = str2num(strtrim(char(answer)));
if isempty(nanswer)
      msgboxText = 'Value must be numerical!\n';
      title = 'ERPLAB: Inputs';
      errorfound(sprintf(msgboxText), title);
      return
end
if length(nanswer)~=1
      msgboxText = 'You must specify a single value.\n';
      title = 'ERPLAB: Inputs';
      errorfound(sprintf(msgboxText), title);
      return
end
unitsopt = get(handles.popupmenu_units,'Value');
switch unitsopt
      case 1
            funits = 'points';            
      case 2
            funits = 'pixels';            
      otherwise
            funits = 'points';
end

handles.output = {nanswer funits};
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%------------------------------------------------------------------------------
function pushbutton_apply_Callback(hObject, eventdata, handles)
answer  = get(handles.edit_fontsize,'String');
nanswer = str2num(strtrim(char(answer)));
if isempty(nanswer)
      msgboxText = 'Value must be numerical!\n';
      title = 'ERPLAB: Inputs';
      errorfound(sprintf(msgboxText), title);
      return
end
if length(nanswer)~=1
      msgboxText = 'You must specify a single value.\n';
      title = 'ERPLAB: Inputs';
      errorfound(sprintf(msgboxText), title);
      return
end
unitsopt = get(handles.popupmenu_units,'Value');
switch unitsopt
      case 1
            funits = 'points';            
      case 2
            funits = 'pixels';            
      otherwise
            funits = 'points';
end

erpworkingmemory('fontsizeGUI', nanswer);
erpworkingmemory('fontunitsGUI', funits);

handles = setfonterplab(handles);

% Update handles structure
guidata(hObject, handles);

%------------------------------------------------------------------------------
function popupmenu_units_Callback(hObject, eventdata, handles)

%------------------------------------------------------------------------------
function popupmenu_units_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
      % The GUI is still in UIWAIT, us UIRESUME
      uiresume(handles.gui_chassis);
else
      % The GUI is no longer waiting, just close it
      delete(handles.gui_chassis);
end
