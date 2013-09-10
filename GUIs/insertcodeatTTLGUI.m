function  varargout = insertcodeatTTLGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
      'gui_Singleton',  gui_Singleton, ...
      'gui_OpeningFcn', @insertcodeatTTLGUI_OpeningFcn, ...
      'gui_OutputFcn',  @insertcodeatTTLGUI_OutputFcn, ...
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
function insertcodeatTTLGUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

try
      EEG = varargin{1};
      nchan  = EEG.nbchan; % Total number of channels
      
catch
      EEG = [];
      EEG.chanlocs = [];
      nchan  = 0;
end
%
% Prepare List of current Channels
%
listch = cell(1);

if isempty(EEG.chanlocs)
      for e = 1:nchan
            EEG.chanlocs(e).labels = ['Ch' num2str(e)];
      end
end

for ch =1:nchan
      listch{ch} = [num2str(ch) ' = ' EEG.chanlocs(ch).labels ];
      
end

set(handles.popupmenu_channel,'String', listch)
set(handles.popupmenu_channel, 'Value', 1)
relalog = {'is less than' 'is less than or equal to' 'is greater than or equal to' 'is greater than'};
set(handles.popupmenu_logical, 'String', relalog)
set(handles.popupmenu_logical, 'Value', 3) % default = 'is greater than or equal to'
set(handles.edit_threshold, 'String', '30')
set(handles.edit_TTL_eventcode, 'String', '')
set(handles.edit_TTL_duration, 'String', '')

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

tooltip1  = ['<html><i>TTL duration: You may define a minimum duration of the square<br>'...
             'pulse to be considered a "true" trigger event. If you leave this window<br>'...
             'empty, ERPLAB will use a duration criteria equal to 1 sample.'];
tooltip2  = ['<html><i><b>Event code to insert:</b>You may define as many (numeric) event codes<br>'...
             'as TTL channels you defined. If you define one event codes and several<br>'...
             'TTL channels, ERPLAB will use this event code for all those channels.<br>'...
             'If you leave this window empty or you use NaN, ERPLAB will use the<br>'...
             'duration of each square pulse (in sample) as an event code. If you want<br>'...
             'to intermix fixed and "duration" event codes you may use numbers and<br>'...
             'NaNs, e.g. 100 NaN 12'];

set(handles.edit_tip_option1, 'tooltip',tooltip1);
set(handles.edit_tip_option2, 'tooltip',tooltip2);

% UIWAIT makes insertcodeatTTLGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

%--------------------------------------------------------------------------
function varargout = insertcodeatTTLGUI_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

%--------------------------------------------------------------------------
function popupmenu_logical_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_logical_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_threshold_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_threshold_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_TTL_channel_Callback(hObject, eventdata, handles)

chx = str2num(get(handles.edit_TTL_channel,'String'));

if isempty(chx)
      msgboxText{1} =  'Invalid channel indexing.';
      title = 'ERPLAB: insertcodeatTTLGUI() error:';
      errorfound(msgboxText, title);
      return
end

chxstr = vect2colon(chx,'Delimiter','off', 'Sort','on');
set(handles.edit_TTL_channel,'String', chxstr)

%--------------------------------------------------------------------------
function edit_TTL_channel_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_channel_Callback(hObject, eventdata, handles)

numch = get(hObject, 'Value');
nums  = str2num(get(handles.edit_TTL_channel, 'String'));
nums  = [nums numch];

if isempty(nums)
      msgboxText{1} =  'Invalid channel indexing.';
      title = 'ERPLAB: insertcodeatTTLGUI() error:';
      errorfound(msgboxText, title);
      return
end
chxstr = vect2colon(nums,'Delimiter','off', 'Sort','on');
set(handles.edit_TTL_channel,'String', chxstr)

%--------------------------------------------------------------------------
function popupmenu_channel_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_TTL_duration_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_TTL_duration_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function text5_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_TTL_eventcode_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_TTL_eventcode_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function pushbutton_RUN_Callback(hObject, eventdata, handles)

channel = str2num(get(handles.edit_TTL_channel,'String'));   % TTL chanel(s)
thresh  = str2num(get(handles.edit_threshold,'String'));     % threshold to identify TTL-like pulse
newcode = str2num(get(handles.edit_TTL_eventcode,'String')); % new code to insert at the onset of a TTL.
                                                             % by default is the duration of the TTL in samples.                                                            
durcond = str2num(get(handles.edit_TTL_duration,'String'));  % new code to insert at the onset of a TTL.
relopv   = get(handles.popupmenu_logical,'Value');           % relational operator 

if isempty(channel)
      msgboxText{1} =  'You must specify one channel at least!.';
      title = 'ERPLAB: pop_insertcodeatTTLGUI';
      errorfound(msgboxText, title);
      return
end
if isempty(thresh)
      msgboxText{1} =  'You must specify a threshold value.';
      title = 'ERPLAB: pop_insertcodeatTTLGUI';
      errorfound(msgboxText, title);
      return
else
      if numel(thresh)>1
            msgboxText{1} =  'Threshold value must be unique.';
            title = 'ERPLAB: pop_insertcodeatTTLGUI';
            errorfound(msgboxText, title);
            return
      end
end
if ~isempty(newcode)
      if numel(newcode)~=1 && numel(newcode)~=numel(channel)
            msgboxText{1} =  ['You must define either a single event code or\n'...
                              'as many as channel you defined'];
            title = 'ERPLAB: pop_insertcodeatTTLGUI';
            errorfound(msgboxText, title);
            return
      end
      if newcode<=0
            msgboxText{1} =  'For this version, "new code" must be a positive integer number (not zero) (even if your current codes are strings).';
            title = 'ERPLAB: pop_insertcodeatTTLGUI';
            errorfound(msgboxText, title);
            return
      end
end
if ~isempty(durcond)
      if numel(durcond)>1
            msgboxText{1} =  'TTL duration value must be unique.';
            title = 'ERPLAB: pop_insertcodeatTTLGUI';
            errorfound(msgboxText, title);
            return
      end
      if durcond<=0
            msgboxText{1} =  'TTL duration condition must be an integer value >= 1 sample.';
            title = 'ERPLAB: pop_insertcodeatTTLGUI';
            errorfound(msgboxText, title);
            return
      end
end

switch relopv
      case 1
            relop = '<';
      case 2
            relop = '<=';
      case 3
            relop = '>=';
      case 4
            relop = '>';
end

outcell = {channel thresh newcode  durcond relop};
% Choose default command line output for insertcodeonthefly2GUI
handles.output = outcell;

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

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
