function varargout = f_ERPwave_Viewer_pos(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @f_ERPwave_Viewer_pos_OpeningFcn, ...
    'gui_OutputFcn',  @f_ERPwave_Viewer_pos_OutputFcn, ...
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
function f_ERPwave_Viewer_pos_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = [];

try
    new_pos = varargin{1};
catch
    try
        ScreenPos =  get( groot, 'Screensize' );
    catch
        ScreenPos =  get( groot, 'Screensize' );
    end
    if ~isempty(ScreenPos)
        new_pos(1:2) = [1 1];
        new_pos(3:4) = ScreenPos(3:4)*3/4;
    else
        new_pos = [1 1 1000 600];
    end
end
handles.edit1_outpos.String = num2str(new_pos);


% Color GUI
%
% handles = painterplab(handles);
[version reldate,ColorBdef,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
set(handles.gui_chassis, 'Color', ColorBviewer_def);
handles.text1.BackgroundColor = ColorBviewer_def;
%
% Set font size
%
% handles = setfonterplab(handles);

% Update handles structure



guidata(hObject, handles);

set(handles.gui_chassis, 'Name', 'Outer Position [x,y,width,height]', 'WindowStyle','modal');

% UIWAIT makes f_ERPwave_Viewer_pos wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);


%-----------------------------------------------------------------------------------
function varargout = f_ERPwave_Viewer_pos_OutputFcn(hObject, eventdata, handles)
try
    varargout{1} = handles.output;
catch
    varargout{1} = [];
end
% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

%----------------------------------------------------------------------------------
% function listbox_list_Callback(hObject, eventdata, handles)
%
% %----------------------------------------------------------------------------------
% function listbox_list_CreateFcn(hObject, eventdata, handles)
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%         set(hObject,'BackgroundColor','white');
% end

%----------------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);


%----------------------------------------------------------------------------------
function pushbutton_ok_Callback(hObject, eventdata, handles)

Data = str2num(handles.edit1_outpos.String);
handles.output = Data;

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






function edit1_outpos_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_outpos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_outpos as text
%        str2double(get(hObject,'String')) returns contents of edit1_outpos as a double


% --- Executes during object creation, after setting all properties.
function edit1_outpos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_outpos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
