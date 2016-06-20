function varargout = gui_eegtrim(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_eegtrim_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_eegtrim_OutputFcn, ...
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


%-------------------------------------------------------------------------------------------------------------
function gui_eegtrim_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = [];

try
        def      = varargin{1};
        pretime  = def{1};
        posttime = def{2};
catch
        pretime  = 1000;
        posttime = 1000;
end

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   Data Trimmer GUI'])

% memory
set(handles.edit_pretime, 'String', sprintf('%g', pretime));
set(handles.edit_posttime, 'String', sprintf('%g', posttime));

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

% UIWAIT makes gui_eegtrim wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);


%-------------------------------------------------------------------------------------------------------------
function varargout = gui_eegtrim_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.gui_chassis);
%-------------------------------------------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%-------------------------------------------------------------------------------------------------------------
function pushbutton_OK_Callback(hObject, eventdata, handles)
pretime  = str2num(get(handles.edit_pretime, 'String'));
if isempty(pretime) %|| pretime<0
        msgboxText =  'Invalid value for the pre-stimulation time';
        title = 'ERPLAB: data trimmer GUI';
        errorfound(msgboxText, title);
        return
end
posttime = str2num(get(handles.edit_posttime, 'String'));
if isempty(posttime) %|| posttime<0
        msgboxText =  'Invalid value for the post-stimulation time';
        title = 'ERPLAB: data trimmer GUI';
        errorfound(msgboxText, title);
        return
end

handles.output = {pretime, posttime};

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%-------------------------------------------------------------------------------------------------------------
function edit_pretime_Callback(hObject, eventdata, handles)

%-------------------------------------------------------------------------------------------------------------
function edit_pretime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%-------------------------------------------------------------------------------------------------------------
function edit_posttime_Callback(hObject, eventdata, handles)

%-------------------------------------------------------------------------------------------------------------
function edit_posttime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

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
