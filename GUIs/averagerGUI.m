%
% Author: Javier Lopez-Calderon & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

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

function varargout = averagerGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
      'gui_Singleton',  gui_Singleton, ...
      'gui_OpeningFcn', @averagerGUI_OpeningFcn, ...
      'gui_OutputFcn',  @averagerGUI_OutputFcn, ...
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
function averagerGUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for averagerGUI
handles.output   = [];
handles.indxline = 1;

try
      currdata = varargin{1};
catch
      currdata = '';
end

try
      def = varargin{2};
      setindex = def{1};   % datasets to average
      
      %
      % Artifact rejection criteria for averaging
      %
      %  artcrite = 0 --> averaging all (good and bad trials)
      %  artcrite = 1 --> averaging only good trials
      %  artcrite = 2 --> averaging only bad trials
      artcrite = def{2};
      
      %
      % Weighted average option. 1= yes, 0=no
      %
      wavg     = def{3};
      
      %
      % Standard deviation option. 1= yes, 0=no
      %
      stdev     = def{4};
catch
      setindex = 1;
      artcrite = 1;
      wavg     = 1;
      stdev    = 1;
end

if artcrite==0
      va=1;vb=0;vc=0;
elseif artcrite==1
      va=0;vb=1;vc=0;
elseif artcrite==2
      va=0;vb=0;vc=1;
else
      msgboxText =  'invalid option.';
      title = 'ERPLAB: averager GUI';
      errorfound(msgboxText, title);
      return
end

set(handles.edit_dataset, 'String', vect2colon(setindex,'Delimiter','off')); % exclude artifacts
set(handles.checkbox_includeALL, 'Value', va); % exclude artifacts
set(handles.checkbox_excludeartifacts, 'Value', vb); % exclude artifacts
set(handles.checkbox_onlyartifacts, 'Value', vc); % exclude artifacts
set(handles.checkbox_STD, 'Value', stdev); % exclude artifacts

% Update handles structure
guidata(hObject, handles);

%
% Name & version
%
version = geterplabversion;
set(handles.figure1,'Name', ['ERPLAB ' version '   -   WEIGHTED AVERAGER GUI'])
set(handles.edit_dataset, 'String', num2str(currdata));

%
% Color GUI
%
handles = painterplab(handles);

% UIWAIT makes averagerGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);

% -------------------------------------------------------------------------
function varargout = averagerGUI_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);
pause(0.1)

% -------------------------------------------------------------------------
function edit_dataset_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_dataset_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function pushbutton_RUN_Callback(hObject, eventdata, handles)

dataset = str2num(char(get(handles.edit_dataset, 'String')));
excart  = get(handles.checkbox_excludeartifacts, 'Value');
incart  = get(handles.checkbox_onlyartifacts, 'Value');

if excart==0 && incart==0 % average all (good and bad trials)
      artcrite = 0;
      disp('averaging all (good and bad trials)...')
elseif excart==1 && incart==0 % average only good trials
      artcrite = 1;
      disp('averaging only good trials...')
elseif excart==0 && incart==1 % average only bad trials! (be cautios!)
      artcrite = 2;
      disp('averaging only bad trials!!!...')
else
      msgboxText =  'Unexpected multiple choices for artifact rejection criteria!';
      title = 'ERPLAB: averager GUI';
      errorfound(msgboxText, title);
      return
end

if isempty(dataset)
      msgboxText =  'You should enter at least one dataset!';
      title = 'ERPLAB: averager GUI empty input';
      errorfound(msgboxText, title);
      return
else
      wavg = 1; %get(handles.checkbox_wavg,'Value'); % always weighted now...
      stdev = get(handles.checkbox_STD, 'Value');
      handles.output = {dataset, artcrite, wavg, stdev};
      
      % Update handles structure
      guidata(hObject, handles);
      uiresume(handles.figure1);
end

%--------------------------------------------------------------------------
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

% -------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);

%-------------------------------------------------------------------------
function checkbox_includeALL_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
      set(handles.checkbox_excludeartifacts,'Value',0)
      set(handles.checkbox_onlyartifacts,'Value',0)
else
      set(handles.checkbox_includeALL,'Value',1)
end

% -------------------------------------------------------------------------
function checkbox_excludeartifacts_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
      set(handles.checkbox_includeALL,'Value',0)
      set(handles.checkbox_onlyartifacts,'Value',0)
else
      set(handles.checkbox_excludeartifacts,'Value',1)
end

% -------------------------------------------------------------------------
function checkbox_onlyartifacts_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
      set(handles.checkbox_includeALL,'Value',0)
      set(handles.checkbox_excludeartifacts,'Value',0)
else
      set(handles.checkbox_onlyartifacts,'Value',1)
end

% --- Executes on button press in checkbox_STD.
function checkbox_STD_Callback(hObject, eventdata, handles)
