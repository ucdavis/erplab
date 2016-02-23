function varargout = savemyeindicesGUI(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @savemyeindicesGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @savemyeindicesGUI_OutputFcn, ...
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


% --------------------------------------------------------------------------
function savemyeindicesGUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = [];

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

set(handles.radiobutton_indx2workspace, 'Value',1)
set(handles.radiobutton_warn, 'Value',1)
disablesaveas(hObject, eventdata, handles)

% UIWAIT makes savemyeindicesGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

% --------------------------------------------------------------------------
function varargout = savemyeindicesGUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

% --------------------------------------------------------------------------
function enablesaveas(hObject, eventdata, handles)
set(handles.edit_saveas, 'Enable','on')
set(handles.pushbutton_browse, 'Enable','on')
set(handles.radiobutton_warn, 'Enable','on')
set(handles.radiobutton_overwrite, 'Enable','on')
set(handles.radiobutton_append, 'Enable','on')
set(handles.checkbox_colon, 'Enable','on')
set(handles.checkbox_open, 'Enable','on')

% --------------------------------------------------------------------------
function disablesaveas(hObject, eventdata, handles)
set(handles.edit_saveas, 'Enable','off')
set(handles.pushbutton_browse, 'Enable','off')
set(handles.radiobutton_warn, 'Enable','off')
set(handles.radiobutton_overwrite, 'Enable','off')
set(handles.radiobutton_append, 'Enable','off')
set(handles.checkbox_colon, 'Enable','off')
set(handles.checkbox_open, 'Enable','off') 

% --------------------------------------------------------------------------
function checkbox_open_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------------
function checkbox_colon_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------------
function radiobutton_warn_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        %set(handles.radiobutton_warn, 'Value',1)
        set(handles.radiobutton_overwrite, 'Value',0)
        set(handles.radiobutton_append, 'Value',0)
else
        set(handles.radiobutton_warn, 'Value',1)
end

% --------------------------------------------------------------------------
function radiobutton_overwrite_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.radiobutton_warn, 'Value',0)
        %set(handles.radiobutton_overwrite, 'Value',1)
        set(handles.radiobutton_append, 'Value',0)
else
        set(handles.radiobutton_warn, 'Value',1)
end

% --------------------------------------------------------------------------
function radiobutton_append_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.radiobutton_warn, 'Value',0)
        set(handles.radiobutton_overwrite, 'Value',0)
        %set(handles.radiobutton_append, 'Value',1)
else
        set(handles.radiobutton_warn, 'Value',1)
end

% --------------------------------------------------------------------------
function edit_saveas_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------------
function edit_saveas_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function pushbutton_browse_Callback(hObject, eventdata, handles)
%
% Save OUTPUT file
%
fndefault = get(handles.edit_saveas,'String');
[fname, pathname] = uiputfile({'*.txt', 'Text file (*.txt)';...
                               '*.*'  , 'All Files (*.*)'},'Save Output file as',...
                               fndefault);

if isequal(fname,0)
        disp('User selected Cancel')
        return
else
        set(handles.edit_saveas,'String', fullfile(pathname, fname));
        disp(['To save ERP, user selected ', fullfile(pathname, fname)])
end

% -------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

% --------------------------------------------------------------------------
function radiobutton_indx2GUI_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        disablesaveas(hObject, eventdata, handles)
        set(handles.radiobutton_indx2txt, 'Value',0)
        set(handles.radiobutton_indx2workspace, 'Value',0)
        %set(handles.radiobutton_indx2GUI, 'Value',0)
else
        set(handles.radiobutton_indx2GUI, 'Value',1)
end
% --------------------------------------------------------------------------
function radiobutton_indx2workspace_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        disablesaveas(hObject, eventdata, handles)
        set(handles.radiobutton_indx2txt, 'Value',0)
        %set(handles.radiobutton_indx2workspace, 'Value',0)
        set(handles.radiobutton_indx2GUI, 'Value',0)
else
        set(handles.radiobutton_indx2workspace, 'Value',1)
end
% --------------------------------------------------------------------------
function radiobutton_indx2txt_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        enablesaveas(hObject, eventdata, handles)
        %set(handles.radiobutton_indx2txt, 'Value',0)
        set(handles.radiobutton_indx2workspace, 'Value',0)
        set(handles.radiobutton_indx2GUI, 'Value',0)
else
        set(handles.radiobutton_indx2txt, 'Value',1)
end

% --------------------------------------------------------------------------
function pushbutton_OK_Callback(hObject, eventdata, handles)
filename = [];
overw    = [];
acolon   = [];
openfile = [];

if get(handles.radiobutton_indx2GUI,'Value')
        option = 0; % to gui's window
elseif get(handles.radiobutton_indx2workspace,'Value')
        option = 1;  % to workspace
elseif get(handles.radiobutton_indx2txt,'Value')
        option=2; % to a file
        filename = strtrim(get(handles.edit_saveas, 'String'));
        
        if isempty(filename)
                msgboxText =  'You must enter a filename.';
                title = 'ERPLAB: filename';
                errorfound(msgboxText, title);
                return
        else
                [pathstr, name, ext] = fileparts(filename) ;
                
                if isempty(pathstr)
                        pathstr = cd;
                end
                if isempty(ext)
                        ext = '.txt';
                end
                filename = fullfile(pathstr, [name ext]);
        end
        if get(handles.radiobutton_warn,'Value')
                overw = 2;
        elseif get(handles.radiobutton_overwrite,'Value')
                overw = 1;
        else
                overw = 0; % append
        end
        if get(handles.checkbox_colon,'Value')
                acolon = 1;
        else
                acolon = 0;
        end
        if get(handles.checkbox_open,'Value')
                openfile = 1;
        else
                openfile = 0;
        end
else
        return
end

if get(handles.checkbox_save_other_subset,'Value')
    save_other = 1;
else
    save_other = 0;
end

handles.output = {option, filename, overw, acolon, openfile, save_other};

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


% --- Executes on button press in checkbox_save_other_subset.
function checkbox_save_other_subset_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_save_other_subset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_save_other_subset
