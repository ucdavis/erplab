
function varargout = saveRTGUI(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @saveRTGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @saveRTGUI_OutputFcn, ...
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


% -------------------------------------------------------------------------
function saveRTGUI_OpeningFcn(hObject, eventdata, handles, varargin)

try
      def      = varargin{1};
      filename = def{1};
      formati  = def{2};
      headeri  = def{3};  % 1 means include header (name of variables)
      arfilter = def{4};  % 1 means discard RT with marked flag(s)


        if strcmpi(formati,'basic')
                format = 1;
        else
                format = 0;
        end
        if strcmpi(headeri,'on')
                header = 1;
        else
                header = 0;
        end
        if strcmpi(arfilter,'on')
              arfilt = 1;
        else
              arfilt = 0;
        end
catch
        filename  = '';
        format    = 1;
        header    = 1;  % 1 means include header (name of variables)
        arfilt    = 0;

end

handles.output = hObject;
handles.owfp   = 0;  % over write file permission

% Update handles structure
guidata(hObject, handles);

%
% Name & version
%
version = geterplabversion;
set(handles.figure1,'Name', ['ERPLAB ' version '   -   Save Reaction Time GUI'])

set(handles.edit_saveas,'String', filename)
set(handles.checkbox_header,'Value', header)
set(handles.radiobutton_basic,'Value', format)
set(handles.radiobutton_itemized,'Value', ~format)
set(handles.checkbox_arfilter,'Value', arfilt)

%
% Color GUI
%
handles = painterplab(handles);

% UIWAIT makes saveRTGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = saveRTGUI_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.figure1);
pause(0.1)

% -------------------------------------------------------------------------
function edit_saveas_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
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
if ispc
        [fname, pathname] = uiputfile({'*.xls';'*.txt';'*.dat';'*.*'},'Save Reaction Time file as',...
                fndefault);
else
        [fname, pathname] = uiputfile({'*.txt';'*.dat';'*.*'},'Save Reaction Time file as',...
                fndefault);
end

if isequal(fname,0)
        disp('User selected Cancel')
        guidata(hObject, handles);
        handles.owfp = 0;  % over write file permission
        guidata(hObject, handles);
else        
        set(handles.edit_saveas,'String', fullfile(pathname, fname));
        disp(['To save Reaction Times, user selected ', fullfile(pathname, fname)])
        handles.owfp = 1;  % over write file permission. Browser allows it already
        guidata(hObject, handles);
end

% -------------------------------------------------------------------------
function radiobutton_basic_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
        set(handles.radiobutton_itemized,'Value', 0)
else
        set(hObject,'Value', 1)
end

% -------------------------------------------------------------------------
function radiobutton_itemized_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.radiobutton_basic,'Value', 0)
else
        set(hObject,'Value', 1)
end

% -------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);


% -------------------------------------------------------------------------
function pushbutton_ok_Callback(hObject, eventdata, handles)

filename = strtrim(get(handles.edit_saveas,'String'));

if isempty(filename)
        msgboxText =  'You must enter an filename!';
        title = 'ERPLAB: empty filename';
        errorfound(msgboxText, title);
        return
end

owfp = handles.owfp;  % over write file permission

if exist(filename, 'file')~=0 && owfp==0
        question{1} = [filename ' already exist!'];
        question{2} = 'Do you want to replace it?';
        title       = 'ERPLAB: Overwriting Confirmation';
        button      = askquest(question, title);

        if ~strcmpi(button, 'yes')
                return
        end
end

if get(handles.radiobutton_basic, 'Value')
        format = 'basic';
else
        format = 'itemized';
end

header  = get(handles.checkbox_header,'Value');
afilter = get(handles.checkbox_arfilter,'Value');
handles.output = {filename, format, header, afilter};

% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);

% -----------------------------------------------------------------------
function figure1_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
        %The GUI is still in UIWAIT, us UIRESUME
        handles.output = '';
        %Update handles structure
        guidata(hObject, handles);
        uiresume(handles.figure1);
else
        % The GUI is no longer waiting, just close it
        delete(handles.figure1);
end

% -----------------------------------------------------------------------
function checkbox_header_Callback(hObject, eventdata, handles)


% -----------------------------------------------------------------------
function checkbox_arfilter_Callback(hObject, eventdata, handles)
