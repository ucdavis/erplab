function varargout = splinefileGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
      'gui_Singleton',  gui_Singleton, ...
      'gui_OpeningFcn', @splinefileGUI_OpeningFcn, ...
      'gui_OutputFcn',  @splinefileGUI_OutputFcn, ...
      'gui_LayoutFcn',  [] , ...
      'gui_Callback',   []);
if nargin && ischar(varargin{1})
      if ~isempty(varargin{1})
            gui_State.gui_Callback = str2func(varargin{1});
      end
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before splinefileGUI is made visible.
function splinefileGUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = [];
try
      splinefile = varargin{1};
      splinefile = splinefile{:};
catch
      splinefile = '';
end

if isempty(splinefile)
      mainmsg = 'Your ERPset does not have a spline file info.\n A spline file is needed for 3d plotting.';
else
      mainmsg = 'Load a spline file for 3d plotting.';
end
set(handles.text_main, 'String', sprintf(mainmsg))
set(handles.edit_splinepath, 'String', splinefile)
set(handles.radiobutton_path, 'Value', 1)
set(handles.edit_saveas, 'Enable', 'off');
set(handles.pushbutton_browse_saves_as, 'Enable', 'off');

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

% UIWAIT makes splinefileGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

% --- Outputs from this function are returned to the command line.
function varargout = splinefileGUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

%--------------------------------------------------------------------------
function radiobutton_path_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
      set(handles.radiobutton_newspline, 'Value', 0);
      set(handles.edit_splinepath, 'Enable', 'on');
      set(handles.pushbutton_browse, 'Enable', 'on');      
      set(handles.edit_saveas, 'Enable', 'off');
      set(handles.pushbutton_browse_saves_as, 'Enable', 'off');
else
      set(hObject, 'Value', 1)
end

%--------------------------------------------------------------------------
function radiobutton_newspline_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
      set(handles.radiobutton_path, 'Value', 0);
      set(handles.edit_splinepath, 'Enable', 'off');
      set(handles.pushbutton_browse, 'Enable', 'off');      
      set(handles.edit_saveas, 'Enable', 'on');
      set(handles.pushbutton_browse_saves_as, 'Enable', 'on');      
else
      set(hObject, 'Value', 1)
end

%--------------------------------------------------------------------------
function checkbox_savespline_Callback(hObject, eventdata, handles)

function edit_splinepath_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_splinepath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_browse_Callback(hObject, eventdata, handles)
%
% load
%
% prename = get(handles.edit_splinepath,'String');
[blfilename, blpathname, filterindex] = uigetfile({'*.*'},'Load spline file ');

if isequal(blfilename,0)
        disp('User selected Cancel')
        return
else
        [px, fname, ext] = fileparts(blfilename);
        fname = [ fname ext];
        fullsplinename = fullfile(blpathname, fname);
        set(handles.edit_splinepath,'String', fullsplinename);
        disp(['Spline file will be loaded from ' fullsplinename])
end

%--------------------------------------------------------------------------
function pushbutton_OK_Callback(hObject, eventdata, handles)

if get(handles.radiobutton_path, 'Value')
      splineinfo.path = get(handles.edit_splinepath,'String');
      splineinfo.new = 0;
      %splineinfo.newname = [];
else
      if get(handles.radiobutton_newspline, 'Value')
            splineinfo.path = get(handles.edit_saveas,'String');
            splineinfo.new  = 1; 
            %splineinfo.newname = get(handles.edit_saveas,'String');
      else
            splineinfo.path = [];
            splineinfo.new = [];
            %splineinfo.newname = [];
      end
end
if isempty(splineinfo.path)        
        msgboxText =  'You must specify a name for the spline file.';
        title = 'ERPLAB: spline file for 3D maps';
        errorfound(msgboxText, title);
        return
end
if get(handles.checkbox_savespline, 'Value')
      splineinfo.save = 1;
else
      splineinfo.save = 0;
end

handles.output = splineinfo;

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);


%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)

% splinefile.path = [];
% splinefile.new = [];
% splinefile.save = [];
% handles.output = splinefile;

handles.output = [];

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
      handles.output = [];
      %Update handles structure
      guidata(hObject, handles);
      uiresume(handles.gui_chassis);
else
      % The GUI is no longer waiting, just close it
      delete(handles.gui_chassis);
end

%--------------------------------------------------------------------------
function edit_saveas_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_saveas_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_browse_saves_as_Callback(hObject, eventdata, handles)

prename = get(handles.edit_saveas,'String');
[blfilename, blpathname, filterindex] = uiputfile({'*.*'},'Save new spline file as ', prename);

if isequal(blfilename,0)
        disp('User selected Cancel')
        return
else
        [px, fname, ext] = fileparts(blfilename);
        fname = [ fname ext];
        fullsplinename = fullfile(blpathname, fname);
        set(handles.edit_saveas,'String', fullsplinename);
end
