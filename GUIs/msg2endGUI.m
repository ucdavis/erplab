function msg2endGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @msg2endGUI_OpeningFcn, ...
        'gui_OutputFcn',  @msg2endGUI_OutputFcn, ...
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

% -----------------------------------------------------------------------
function msg2endGUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = [];
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   Ending Message GUI'])

% Read file containing the message
[msg2show msgori mcolor] = readmsg2end;
handles.mcolor   = mcolor;
handles.msg2show = msg2show;
handles.msgori   = msgori;

%
% Examples
%
example{1} = 'Done!';
example{2} = 'I''m sick of working for you!';
example{3} = 'Listo Doctora!';
example{4} = '¡A sus órdenes jefe!';
example{5} = 'in the can!';
example{6} = 'sprintf(''I''''m done, Boss.\nDo you need something else?'')';
example{7} = 'sprintf(''finished at %s'', datestr(now, ''HH:MM:SS AM''))';
example{8} = 'eval(''currfun = dbstack;'');';
example{9} = 'sprintf(''%s has finished'', currfun(end).name)';

handles.example = example;
handles.exacounter = 0;

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

set(handles.edit_fcolor, 'BackgroundColor', mcolor)
set(handles.edit_msg, 'String', msgori)
set(handles.checkbox_preview, 'Value', 0)
% set(handles.pushbutton_examples, 'Enable', 'on')
uiwait(handles.gui_chassis);

% -----------------------------------------------------------------------
function varargout = msg2endGUI_OutputFcn(hObject, eventdata, handles)

delete(handles.gui_chassis);
pause(0.1)
% -----------------------------------------------------------------------
function edit_msg_Callback(hObject, eventdata, handles)

% -----------------------------------------------------------------------
function edit_msg_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -----------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);
% -----------------------------------------------------------------------
function pushbutton_ok_Callback(hObject, eventdata, handles)

msg = cellstr(get(handles.edit_msg, 'String'));
msg = [sprintf('<[%.4f %.4f %.4f]>', handles.mcolor); msg];
p = which('eegplugin_erplab');
p = p(1:strfind(p,'eegplugin_erplab.m')-1);
filename = fullfile(p,'functions','msg2end.txt');
fid = fopen(filename, 'w');

for i=1:length(msg)
      fprintf(fid, '%s\n', msg{i});
end

fclose(fid);
msg2end
uiresume(handles.gui_chassis);

% -----------------------------------------------------------------------
function pushbutton_clear_Callback(hObject, eventdata, handles)
question =  'Are you sure you want to clear the edition window?';
title    = 'ERPLAB: clear all';
button   = askquestpoly(question, title, {'Yes', 'No'});
if strcmpi(button, 'yes')
        set(handles.edit_msg, 'String', '');
        set(handles.checkbox_preview, 'Value', 0)
                set(handles.pushbutton_ok, 'Enable', 'on')
        set(handles.pushbutton_examples, 'Enable', 'on')
        set(handles.edit_msg, 'Enable', 'on')        
        exacounter = handles.exacounter;
        exacounter = exacounter - 1;
        if exacounter<1
                exacounter=1;
        end
        handles.exacounter = exacounter;
        % Update handles structure
        guidata(hObject, handles);
end

% -----------------------------------------------------------------------
function pushbutton_color_Callback(hObject, eventdata, handles)
c = uisetcolor(handles.mcolor,'Font Color') ;
set(handles.edit_fcolor, 'BackgroundColor', c)
handles.mcolor = c;
% Update handles structure
guidata(hObject, handles);

% -----------------------------------------------------------------------
function pushbutton_editfile_Callback(hObject, eventdata, handles)
p = which('eegplugin_erplab');
p = p(1:strfind(p,'eegplugin_erplab.m')-1);
filename = fullfile(p,'functions','msg2end.txt');
edit(filename);
uiresume(handles.gui_chassis);

% -----------------------------------------------------------------------
function checkbox_preview_Callback(hObject, eventdata, handles)

if get(hObject, 'Value')
        msg = get(handles.edit_msg, 'String');
        if isempty(msg)
                set(handles.checkbox_preview, 'Value', 0)
                return
        end        
        set(handles.pushbutton_ok, 'Enable', 'off')        
        msg = cellstr(msg);  % REVISAR PORQUE TODO QUEDA TAN SEPARADO AQUI
        msg2show  = readmsg2end(msg);
        msg2show  = char(cellstr(msg2show));
        set(handles.edit_msg, 'String', msg2show);
        set(handles.edit_msg, 'Enable', 'inactive')
        set(handles.pushbutton_examples, 'Enable', 'off')
        %handles.msg2show = msg2show;
        handles.msgori = msg;
        % Update handles structure
        guidata(hObject, handles);
else
        set(handles.edit_msg, 'Enable', 'on')
        set(handles.pushbutton_examples, 'Enable', 'on')
        msgori = handles.msgori;
        set(handles.edit_msg, 'String', msgori);
        set(handles.pushbutton_ok, 'Enable', 'on')        
end

% -----------------------------------------------------------------------
function pushbutton_examples_Callback(hObject, eventdata, handles)
set(handles.edit_msg, 'Enable', 'on')
example    = handles.example;
exacounter = handles.exacounter;
exacounter = exacounter + 1;
text       = cellstr(get(handles.edit_msg, 'String'));

if exacounter>length(example)
        exacounter = 1;
end
if length(text)==1 && strcmp(text{1}, '')
        text{1} = char(example{exacounter});
else
        text{end+1}  = char(example{exacounter});
end

set(handles.edit_msg, 'String', char(text));
handles.exacounter = exacounter;
% Update handles structure
guidata(hObject, handles);

% -----------------------------------------------------------------------
function edit_fcolor_Callback(hObject, eventdata, handles)

% -----------------------------------------------------------------------
function edit_fcolor_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

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
