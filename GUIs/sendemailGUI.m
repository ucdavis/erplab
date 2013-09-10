function varargout = sendemailGUI(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sendemailGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @sendemailGUI_OutputFcn, ...
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

%---------------------------------------------------------------------------------------------------
function sendemailGUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = [];

try
        def = varargin{1};
catch
        def = {'','You got an ERPmail!', 1};
end

memail = def{1}';
nm = length(memail);
memmailto = '';
for k=1:nm
        memmailto = sprintf('%s %s', memmailto, memail{k});
end
memmailto  = strtrim(memmailto);
memmailto  = strrep(memmailto, ' ', ', ');
memsubject = def{2};
memerpset  = def{3};
set(handles.edit_to, 'String', memmailto)
set(handles.edit_subject, 'String', memsubject)
set(handles.edit_erpsets, 'String', num2str(memerpset))

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   Send Email GUI'])
fromemail = getpref('Internet','SMTP_Username');
if isempty(fromemail)
      fromemail = 'email not found';
end
set(handles.text_myemail, 'String', fromemail)

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

% UIWAIT makes sendemailGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

%---------------------------------------------------------------------------------------------------
function varargout = sendemailGUI_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

%---------------------------------------------------------------------------------------------------
function edit_to_Callback(hObject, eventdata, handles)

%---------------------------------------------------------------------------------------------------
function edit_to_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%---------------------------------------------------------------------------------------------------
function edit_subject_Callback(hObject, eventdata, handles)

%---------------------------------------------------------------------------------------------------
function edit_subject_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%---------------------------------------------------------------------------------------------------
function edit_erpsets_Callback(hObject, eventdata, handles)

%---------------------------------------------------------------------------------------------------
function edit_erpsets_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%---------------------------------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);
%---------------------------------------------------------------------------------------------------
function pushbutton_send_Callback(hObject, eventdata, handles)

mailto  = get(handles.edit_to, 'String');
mailto  = regexp(mailto, ',|\s+', 'split');
mailto(cellfun(@isempty,mailto)) = [];
subject = get(handles.edit_subject, 'String');
msg     = cellstr(char(get(handles.edit_editor, 'String')));
attach  = str2num(get(handles.edit_erpsets, 'String'));

handles.output = {mailto, subject, msg, attach};
%sendmail(mailto, subject, msg);
%pause(0.2)

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%---------------------------------------------------------------------------------------------------
function edit_editor_Callback(hObject, eventdata, handles)

%---------------------------------------------------------------------------------------------------
function edit_editor_CreateFcn(hObject, eventdata, handles)
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
