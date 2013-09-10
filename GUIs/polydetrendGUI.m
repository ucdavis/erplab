function varargout = polydetrendGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @polydetrendGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @polydetrendGUI_OutputFcn, ...
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

%-------------------------------------------------------------------------------------------------
function polydetrendGUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = [];

try
        def = varargin{1};
        imetho = def{1};
        ichan  = def{2};
        ww     = def{3};
        ws     = def{4};
catch
        imetho = 1;
        ichan  = 1;
        ww     = 5000;
        ws     = 2500;
end
try
        chanlocs = varargin{2};
catch
        chanlocs = [];
end
set(handles.popupmenu_method, 'String', {'Spline' 'Savitzky-Golay'})
set(handles.popupmenu_method, 'Value', imetho)
set(handles.edit_channels, 'String', vect2colon(ichan, 'Delimiter', 'off'))
set(handles.edit_window, 'String', num2str(ww))
if imetho==1
        set(handles.edit_step, 'String', num2str(ws))
else
        set(handles.edit_step, 'Enable', 'off')
end

%
% Prepare List of current Channels
%
nchan  = length(chanlocs);
if isempty(chanlocs)
        for e = 1:nchan
                chanlocs(e).labels = ['Ch' num2str(e)];
        end
end
listch = {''};
for ch =1:nchan
        listch{ch} = [num2str(ch) ' = ' chanlocs(ch).labels ];
end

handles.listch     = listch;
handles.indxlistch = ichan; % channel array

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

uiwait(handles.gui_chassis);

%-------------------------------------------------------------------------------------------------
function varargout = polydetrendGUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
delete(handles.gui_chassis);
pause(0.1)

%-------------------------------------------------------------------------------------------------
function popupmenu_method_Callback(hObject, eventdata, handles)

%-------------------------------------------------------------------------------------------------
function popupmenu_method_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%-------------------------------------------------------------------------------------------------
function edit_window_Callback(hObject, eventdata, handles)

%-------------------------------------------------------------------------------------------------
function edit_window_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%-------------------------------------------------------------------------------------------------
function edit_step_Callback(hObject, eventdata, handles)

%-------------------------------------------------------------------------------------------------
function edit_step_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%-------------------------------------------------------------------------------------------------
function edit_channels_Callback(hObject, eventdata, handles)

%-------------------------------------------------------------------------------------------------
function edit_channels_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%-------------------------------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
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

%-------------------------------------------------------------------------------------------------
function pushbutton_ok_Callback(hObject, eventdata, handles)

imetho = (get(handles.popupmenu_method, 'Value'));
ichan  = str2num(get(handles.edit_channels, 'String'));
ww     = str2num(get(handles.edit_window, 'String'));
ws     = str2num(get(handles.edit_step, 'String'));

handles.output = {imetho ichan ww ws};

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

% % % %-------------------------------------------------------------------------------------------------
% % % function popupmenu_channels_Callback(hObject, eventdata, handles)
% % % 
% % % %-------------------------------------------------------------------------------------------------
% % % function popupmenu_channels_CreateFcn(hObject, eventdata, handles)
% % % if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
% % %     set(hObject,'BackgroundColor','white');
% % % end

%--------------------------------------------------------------------------
function pushbutton_browsechan_Callback(hObject, eventdata, handles)

listch     = handles.listch;
indxlistch = handles.indxlistch;
indxlistch = indxlistch(indxlistch<=length(listch));
titlename  = 'Select Channel(s)';

if get(hObject, 'Value')
        if ~isempty(listch)
                ch = browsechanbinGUI(listch, indxlistch, titlename);
                if ~isempty(ch)
                        set(handles.edit_channels, 'String', vect2colon(ch, 'Delimiter', 'off'));
                        handles.indxlistch = ch;
                        % Update handles structure
                        guidata(hObject, handles);
                else
                        disp('User selected Cancel')
                        return
                end
        else
                msgboxText =  'No channel information was found';
                title = 'ERPLAB: polydetrend GUI input';
                errorfound(msgboxText, title);
                return
        end
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
