function varargout = shuffleGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @shuffleGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @shuffleGUI_OutputFcn, ...
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


%-----------------------------------------------------------------------
function shuffleGUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = [];
try
        def = varargin{1};
        values = def{1};        
        if isnumeric(values)
                val = vect2colon(values, 'delimiter', 'off');
                set(handles.edit_values, 'String', val)
        else
                if strcmpi(char(values), 'off')
                        values = '';
                end
                set(handles.edit_values, 'String', char(values))
        end        
        fieldop = def{2};
        if fieldop==0% shuffle code
                set(handles.radiobutton_codes, 'Value', 1)
                set(handles.radiobutton_bin, 'Value', 0)
                set(handles.radiobutton_datasamples, 'Value', 0)
                set(handles.edit_values, 'Enable', 'on')
        elseif fieldop==1% shuffle bin
                set(handles.radiobutton_codes, 'Value', 0)
                set(handles.radiobutton_bin, 'Value', 1)
                set(handles.radiobutton_datasamples, 'Value', 0)
                set(handles.edit_values, 'Enable', 'on')
        elseif fieldop==2 % shuffle data
                set(handles.radiobutton_codes, 'Value', 0)
                set(handles.radiobutton_bin, 'Value', 0)
                set(handles.radiobutton_datasamples, 'Value', 1)
                set(handles.edit_values, 'Enable', 'off')
        else
                set(handles.radiobutton_codes, 'Value', 1)                
                set(handles.radiobutton_bin, 'Value', 0)
                set(handles.radiobutton_datasamples, 'Value', 0)
        end
catch
        set(handles.radiobutton_codes, 'Value', 1)
end

version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   Shuffler GUI'])

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

% UIWAIT makes shuffleGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

%-----------------------------------------------------------------------
function varargout = shuffleGUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

%-----------------------------------------------------------------------
function edit_values_Callback(hObject, eventdata, handles)

%-----------------------------------------------------------------------
function edit_values_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%-----------------------------------------------------------------------
function radiobutton_codes_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
      set(handles.radiobutton_bin, 'Value', 0)
      set(handles.radiobutton_datasamples, 'Value', 0)
      set(handles.edit_values, 'Enable', 'on')
else
      set(handles.radiobutton_codes, 'Value', 1)
end

%-----------------------------------------------------------------------
function radiobutton_bin_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
      set(handles.radiobutton_codes, 'Value', 0)
      set(handles.radiobutton_datasamples, 'Value', 0)
      set(handles.edit_values, 'Enable', 'on')
else
      set(handles.radiobutton_bin, 'Value', 1)
end

%-----------------------------------------------------------------------
function radiobutton_datasamples_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.radiobutton_codes, 'Value', 0)
        set(handles.radiobutton_bin, 'Value', 0)
        set(handles.edit_values, 'Enable', 'off')
else
        set(hObject, 'Value', 1)
end

%-----------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%-----------------------------------------------------------------------
function pushbutton_OK_Callback(hObject, eventdata, handles)
if get(handles.radiobutton_codes, 'Value')
        fieldop = 0;
elseif get(handles.radiobutton_bin, 'Value')
        fieldop = 1;
elseif get(handles.radiobutton_datasamples, 'Value')
        fieldop = 2;
else
        return
end
if fieldop~=2
        values = get(handles.edit_values, 'string');
        
        if ~strcmpi(values, 'all')
                values = str2num(values);
                if isempty(values) || length(values)<2
                        msgboxText = 'You have to specify 2 numeric values at least!';
                        title = 'ERPLAB: pop_eventshuffler(). Permission denied';
                        errorfound(sprintf(msgboxText), title);
                        return
                end
        end
else
        values = [];
end

handles.output = {values, fieldop};

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
