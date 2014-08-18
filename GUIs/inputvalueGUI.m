function varargout = inputvalueGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @inputvalueGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @inputvalueGUI_OutputFcn, ...
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


% --- Executes just before inputvalueGUI is made visible.
function inputvalueGUI_OpeningFcn(hObject, eventdata, handles, varargin)


% Choose default command line output for inputvalueGUI
handles.output = [];

 try
      prompt    = varargin{1};
      dlg_title = varargin{2};
      memov     = strtrim(char(varargin{3}));
      def       = varargin{4};
      option01  = varargin{5};
 catch
       prompt    = 'test';
       dlg_title = 'TEST';
       memov     = 'Hello World!';
       def       = 'que?';
       option01  = 0;
 end
 
 handles.memov = memov;
 handles.def   = def;
 set(handles.edit_ticks,'String', memov)
 set(handles.prompt,'String', prompt);
 set(handles.gui_chassis,'Name', dlg_title);
 set(handles.edit_ticks,'String', memov);
 
 if strcmpi(dlg_title,'Recovering numeric event codes from Bin Labels')
         set(handles.checkbox_option01,'Visible', 'off');
         set(handles.checkbox_option01,'Visible', 'off');
         set(handles.pushbutton_reset,'Visible', 'off');
         tooltip1  = ['<html><i>You may want to differentiate between your recovered event codes<br>'...
                 'and those that were not bin-captured and that still remain in your dataset.<br>'...
                 'In order to do so, you can enter a single integer here that will work as a<br>'...
                 'multiplier for each recovered event code. For instance, if you use a value<br>'...
                 'of 100 then recovered event codes like 23 or 41 will appear as 2300 and 4100.<br><br>'...
                 'Otherwise enter a value of 1.'];
         set(handles.edit_tip_tip_multiplier,'Visible', 'on');
         set(handles.edit_tip_tip_multiplier, 'tooltip',tooltip1);
         
         %
         % Tooltip timing
         %
         try
                 tm = javax.swing.ToolTipManager.sharedInstance;
                 initialDelay = javaMethodEDT('getInitialDelay',tm);
                 javaMethodEDT('setInitialDelay',tm,0);
                 dismissDelay = javaMethodEDT('getDismissDelay',tm);
                 javaMethodEDT('setDismissDelay',tm,20000);
                 javaMethodEDT('setEnabled',tm,false);
                 pause(0.2)
                 javaMethodEDT('setEnabled',tm,true);
                 javaMethodEDT('setInitialDelay',tm,initialDelay);
                 javaMethodEDT('setDismissDelay',tm,dismissDelay);
         catch
                 disp('Tooltip timing setting could not be changed...')
         end
 else
         set(handles.checkbox_option01,'String', 'Include minor ticks');
         set(handles.checkbox_option01,'Value', option01);
         set(handles.edit_tip_tip_multiplier,'Visible', 'off');
 end
 
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

% UIWAIT makes inputvalueGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);


% --- Outputs from this function are returned to the command line.
function varargout = inputvalueGUI_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

%------------------------------------------------------------------------------
function edit_ticks_Callback(hObject, eventdata, handles)

%------------------------------------------------------------------------------
function edit_ticks_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%------------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%------------------------------------------------------------------------------
function pushbutton_reset_Callback(hObject, eventdata, handles)
def = handles.def;
set(handles.edit_ticks,'String', def);

%------------------------------------------------------------------------------
function pushbutton_ok_Callback(hObject, eventdata, handles)
answer = get(handles.edit_ticks,'String');
nanswer = str2num(strtrim(char(answer)));
if isempty(nanswer)
      msgboxText = 'Invalid range of values!\n';
      title = 'ERPLAB: Inputs';
      errorfound(sprintf(msgboxText), title);
      return
end
op01 = get(handles.checkbox_option01,'Value');

handles.output = {strtrim(char(answer)) op01};
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
      % The GUI is still in UIWAIT, us UIRESUME
      uiresume(handles.gui_chassis);
else
      % The GUI is no longer waiting, just close it
      delete(handles.gui_chassis);
end


function checkbox_option01_Callback(hObject, eventdata, handles)
