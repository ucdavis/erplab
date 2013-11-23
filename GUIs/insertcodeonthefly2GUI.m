%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% ERPLAB Toolbox
% Copyright © 2007 The Regents of the University of California
% Created by Javier Lopez-Calderon and Steven Luck
% Center for Mind and Brain, University of California, Davis,
% javlopez@ucdavis.edu, sjluck@ucdavis.edu
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

function  varargout = insertcodeonthefly2GUI(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
      'gui_Singleton',  gui_Singleton, ...
      'gui_OpeningFcn', @insertcodeonthefly2GUI_OpeningFcn, ...
      'gui_OutputFcn',  @insertcodeonthefly2GUI_OutputFcn, ...
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
function insertcodeonthefly2GUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = [];
% Update handles structure

relalog = {'is equal to' 'is not equal to' 'is less than'...
      'is less than or equal to' 'is greater than or equal to' 'is greater than'};
relatop = {'=' '~=' '<' '<=' '>=' '>'};
handles.relatop = relatop;

try
      EEG   = varargin{1};
      nchan = EEG.nbchan; % Total number of channels
      
catch
      EEG = [];
      EEG.chanlocs = [];
      nchan  = 0;
end

%
% Prepare List of current Channels
%
listch = [];

if isempty(EEG.chanlocs)
      for e = 1:nchan
            EEG.chanlocs(e).labels = ['Ch' num2str(e)];
      end
end

for ch =1:nchan
      listch{ch} = [num2str(ch) ' = ' EEG.chanlocs(ch).labels ];
      set(handles.popupmenu_channel,'String', listch)
      set(handles.popupmenu_channel, 'Value', 1)
end

set(handles.popupmenu_logical, 'String', relalog)
set(handles.popupmenu_logical, 'Value', 5) % default = 'is greater than or equal to'
set(handles.edit_rela, 'String', sprintf('''%s''',relatop{5})) % default = 'is greater than or equal to'
set(handles.edit_threshold, 'String', '100')
set(handles.edit_newcode, 'String', '99')
set(handles.edit_refractory, 'String', '600')
set(handles.edit_latoffset, 'String', '0')

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

% UIWAIT makes insertcodeonthefly2GUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

% -------------------------------------------------------------------------
function varargout = insertcodeonthefly2GUI_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

% -------------------------------------------------------------------------
function edit_threshold_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_threshold_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function edit_newcode_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_newcode_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function edit_refractory_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_refractory_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)

handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

% -------------------------------------------------------------------------
function pushbutton_RUN_Callback(hObject, eventdata, handles)

newcode = str2num(get(handles.edit_newcode,'String'));
channel = str2num(get(handles.edit_chanArray,'String'));
relatop = get(handles.edit_rela,'String');
relatop = strrep(relatop, '''','');
relatop = regexp(relatop, ',|\s+', 'split');
relatop(cellfun(@isempty,relatop)) = [];

thresh  = str2num(get(handles.edit_threshold,'String'));

if isempty(newcode) || length(newcode)>1
      msgboxText =  'For this version, "new code" must be a single (positive) integer number except zero (even if your codes are strings).';
      title = 'ERPLAB: pop_insertcodeonthefly GUI';
      errorfound(msgboxText, title);
      return
end
if isempty(channel) || nnz(channel<=0)>0
      msgboxText =  'Channel must be an (positive) integer number except zero.';
      title = 'ERPLAB: pop_insertcodeonthefly GUI';
      errorfound(msgboxText, title);
      return
end
if isempty(thresh)
      msgboxText =  'You must define a threshold.';
      title = 'ERPLAB: pop_insertcodeonthefly GUI';
      errorfound(msgboxText, title);
      return
end
if length(unique_bc2([length(channel) length(relatop) length(thresh)]))~=1
      msgboxText =  'You must specify the same amount of elements for ''new code'',''channel'',''logical operator'', and ''threshold''';
      title = 'ERPLAB: pop_insertcodeonthefly GUI';
      errorfound(msgboxText, title);
      return
end


% switch relopv
%       case 1
%             relop = '==';
%       case 2
%             relop = '~=';
%       case 3
%             relop = '<';
%       case 4
%             relop = '<=';
%       case 5
%             relop = '>=';
%       case 6
%             relop = '>';
% end

refract    = str2num(get(handles.edit_refractory,'String'));
absolud    = get(handles.checkbox_absolute,'Value');
windowms   = str2num(get(handles.edit_TWW,'String'));
durationms = str2num(get(handles.edit_duration,'String'));
latoffset  = str2num(get(handles.edit_latoffset,'String'));

if ~isempty(durationms) && ~isempty(windowms)
      if durationms<=0 || durationms>windowms
            msgboxText = 'Duration parameter must be greater than zero and less than or equal to the test window width.';
            title = 'ERPLAB: pop_insertcodeonthefly GUI';
            errorfound(sprintf(msgboxText), title);
            return
      end
elseif isempty(durationms) && ~isempty(windowms)
      msgboxText =  'You must enter a duration parameter in miliseconds (less than or equal to the test window width)';
      title = 'ERPLAB: pop_insertcodeonthefly GUI';
      errorfound(msgboxText, title);
      return
elseif ~isempty(durationms) && isempty(windowms)
      msgboxText =  'You have to enter a Test window width in ms.';
      title = 'ERPLAB: pop_insertcodeonthefly GUI';
      errorfound(msgboxText, title);
      return
end

outcell = {newcode channel relatop thresh refract, absolud, windowms, durationms, latoffset};
% Choose default command line output for insertcodeonthefly2GUI
handles.output = outcell;

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

% -------------------------------------------------------------------------
function popupmenu_logical_Callback(hObject, eventdata, handles)

relatop = handles.relatop;

num = get(hObject, 'Value');
rel = relatop{num};
nst = get(handles.edit_rela, 'String');
nst = sprintf('%s ''%s''', nst, rel);
set(handles.edit_rela,'String', nst)


% -------------------------------------------------------------------------
function popupmenu_logical_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function popupmenu_channel_Callback(hObject, eventdata, handles)

numch = get(hObject, 'Value');
nums  = str2num(get(handles.edit_chanArray, 'String'));
nums  = [nums numch];
if isempty(nums)
        msgboxText =  'Invalid channel indexing.';
        title = 'ERPLAB: insertcodeonthefly2GUI() error:';
        errorfound(msgboxText, title);
        return
end
chxstr = vect2colon(nums,'Delimiter','off', 'Repeat', 'off');
set(handles.edit_chanArray,'String', chxstr)

% -------------------------------------------------------------------------
function popupmenu_channel_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
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

% -------------------------------------------------------------------------
function checkbox_absolute_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_TWW_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_TWW_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function edit_duration_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_duration_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function checkbox_absolute_CreateFcn(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function pushbutton_RUN_CreateFcn(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function pushbutton_cancel_CreateFcn(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_latoffset_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_latoffset_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function edit_chanArray_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_chanArray_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function edit_rela_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_rela_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
