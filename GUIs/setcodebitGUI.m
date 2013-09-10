function varargout = setcodebitGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @setcodebitGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @setcodebitGUI_OutputFcn, ...
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
function setcodebitGUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
set(handles.radiobutton_byreset, 'Value', 1)
set(handles.radiobutton_bybit, 'Value', 0)
set(handles.togglebutton_lowerbyte, 'Enable', 'on')
set(handles.togglebutton_upperbyte, 'Enable', 'on')
set(handles.edit_set2zero, 'Enable', 'off')
set(handles.edit_set2one, 'Enable', 'off')

version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   Set code bits GUI'])

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
helpbutton

uiwait(handles.gui_chassis);

%--------------------------------------------------------------------------
function varargout = setcodebitGUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
delete(handles.gui_chassis);
pause(0.1)

%--------------------------------------------------------------------------
function pushbutton_help_Callback(hObject, eventdata, handles)
doc pop_setcodebit

%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);
%--------------------------------------------------------------------------
function pushbutton_ok_Callback(hObject, eventdata, handles)

if get(handles.radiobutton_byreset, 'Value')
        
        if get(handles.togglebutton_lowerbyte, 'Value') && ~get(handles.togglebutton_upperbyte, 'Value')
                output = {'lower'};
        elseif ~get(handles.togglebutton_lowerbyte, 'Value') && get(handles.togglebutton_upperbyte, 'Value')
                output = {'upper'};
        elseif get(handles.togglebutton_lowerbyte, 'Value') && get(handles.togglebutton_upperbyte, 'Value')
                output = {'all'};
        else
                msgboxText =  'You must press one button at least!';
                title = 'ERPLAB: setcodebitGUI few inputs';
                errorfound(msgboxText, title);
                return
        end
else
        bit2zero = str2num(get(handles.edit_set2zero, 'String'));
        bit2one  = str2num(get(handles.edit_set2one, 'String'));
        
        if isempty(bit2zero) && isempty(bit2one)
                msgboxText =  'You must specify one valid bit (1 to 16) at least!';
                title = 'ERPLAB: setcodebitGUI few inputs';
                errorfound(msgboxText, title);
                return
        end
        if ~isempty(bit2zero)
                if max(bit2zero)>16 || min(bit2zero)<1
                        msgboxText =  'For bits you must specify any integer between 1 to 16!';
                        title = 'ERPLAB: setcodebitGUI few inputs';
                        errorfound(msgboxText, title);
                        return
                end
        end
        if ~isempty(bit2one)
                if max(bit2one)>16 || min(bit2one)<1
                        msgboxText =  'For bits you must specify any integer between 1 to 16!';
                        title = 'ERPLAB: setcodebitGUI few inputs';
                        errorfound(msgboxText, title);
                        return
                end
        end       
        output = {'bit' bit2zero bit2one};
end
handles.output = output;
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function edit_set2zero_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_set2zero_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_set2one_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_set2one_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function radiobutton_byreset_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.radiobutton_bybit, 'Value', 0)
        set(handles.togglebutton_lowerbyte, 'Enable', 'on')
        set(handles.togglebutton_upperbyte, 'Enable', 'on')
        set(handles.edit_set2zero, 'Enable', 'off')
        set(handles.edit_set2one, 'Enable', 'off')
else
        set(handles.radiobutton_byreset, 'Value', 1)
end

%--------------------------------------------------------------------------
function radiobutton_bybit_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.radiobutton_byreset, 'Value', 0)
        set(handles.togglebutton_lowerbyte, 'Enable', 'off')
        set(handles.togglebutton_upperbyte, 'Enable', 'off')
        set(handles.edit_set2zero, 'Enable', 'on')
        set(handles.edit_set2one, 'Enable', 'on')
else
        set(handles.radiobutton_bybit, 'Value', 1)
end

%--------------------------------------------------------------------------
function togglebutton_lowerbyte_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function togglebutton_upperbyte_Callback(hObject, eventdata, handles)


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
