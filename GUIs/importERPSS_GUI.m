function varargout = importERPSS_GUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @importERPSS_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @importERPSS_GUI_OutputFcn, ...
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


%---------------------------------------------------------------------------
function importERPSS_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = [];

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   IMPORT ERP from ERPSS (ASCII) GUI'])

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

set(handles.radiobutton_explicit, 'Value', 1);
set(handles.checkbox_transpose, 'Enable', 'off');

% UIWAIT makes importERPSS_GUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

%---------------------------------------------------------------------------
function varargout = importERPSS_GUI_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

%---------------------------------------------------------------------------
function radiobutton_explicit_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.radiobutton_implicit, 'Value', 0);
        set(handles.checkbox_transpose, 'Value', 0);
        set(handles.checkbox_transpose, 'Enable', 'off');
else
        set(handles.radiobutton_explicit, 'Value', 1);
end

%---------------------------------------------------------------------------
function radiobutton_implicit_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.radiobutton_explicit, 'Value', 0);
        set(handles.checkbox_transpose, 'Enable', 'on');
else
        set(handles.radiobutton_implicit, 'Value', 1);
end
%---------------------------------------------------------------------------
function checkbox_transpose_Callback(hObject, eventdata, handles)

%---------------------------------------------------------------------------
function pushbutton_CANCEL_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%---------------------------------------------------------------------------
function pushbutton_OK_Callback(hObject, eventdata, handles)
fname = get(handles.edit_file, 'String');

if isempty(fname)
      msgboxText = 'You have to pick a file first.';
      title = 'ERPLAB: import ERPSS Error';
      errorfound(msgboxText, title);
      return
end
if get(handles.radiobutton_explicit, 'Value')==1
        erpssformat = 0;
else
        erpssformat = 1;
end
if get(handles.checkbox_transpose, 'Value')==1
        dtranspose = 1; % transpose
else
        dtranspose = 0; % do not transpose
end
handles.output = {fname, erpssformat, dtranspose};

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function edit_file_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_file_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_browse_Callback(hObject, eventdata, handles)
[filename, filepath, findex] = uigetfile({'*.txt','text file(*.txt)'; ...
      '*.*',  'All Files (*.*)'}, ...
      'Select an ascii file', ...
      'MultiSelect', 'on');

if ~iscell(filename)
        if isempty(filename)
                disp('User selected cancel.')
                return
        end
        if filename==0
                disp('User selected cancel.')
                return
        end
        filename = cellstr(filename);
end

for a=1:length(filename)
fname{a} = fullfile(filepath, filename{a});
end

lista = get(handles.edit_file, 'String');
lista = [lista ;fname'];
lista = lista(~cellfun(@isempty, lista));
set(handles.edit_file, 'String', lista);

%--------------------------------------------------------------------------
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
