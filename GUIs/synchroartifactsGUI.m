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

function varargout = synchroartifactsGUI(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @synchroartifactsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @synchroartifactsGUI_OutputFcn, ...
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
function synchroartifactsGUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
set(handles.radiobutton_erplab_to_eeglab,'value',1)

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   SYNCHRO ARTIFACTS GUI'])

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

% UIWAIT makes synchroartifactsGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

% --------------------------------------------------------------------------
function varargout = synchroartifactsGUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)
% --------------------------------------------------------------------------
function radiobutton_erplab_to_eeglab_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
      set(handles.radiobutton_eeglab_to_erplab,'value',0)
      set(handles.radiobutton_bidirectional,'value',0)
else
      set(handles.radiobutton_erplab_to_eeglab,'value',1)
end

% --------------------------------------------------------------------------
function radiobutton_eeglab_to_erplab_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
      set(handles.radiobutton_erplab_to_eeglab,'value',0)
      set(handles.radiobutton_bidirectional,'value',0)
else
      set(handles.radiobutton_eeglab_to_erplab,'value',1)
end

% --------------------------------------------------------------------------
function radiobutton_bidirectional_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
      set(handles.radiobutton_erplab_to_eeglab,'value',0)
      set(handles.radiobutton_eeglab_to_erplab,'value',0)
else
      set(handles.radiobutton_bidirectional,'value',1)
end

% --------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

% --------------------------------------------------------------------------
function pushbutton_ok_Callback(hObject, eventdata, handles)

erp2eeg = get(handles.radiobutton_erplab_to_eeglab,'value');
eeg2erp = get(handles.radiobutton_eeglab_to_erplab,'value');
bidirec = get(handles.radiobutton_bidirectional,'value');

if erp2eeg==1 && eeg2erp==0 && bidirec==0
    direction = 1; % erplab to eeglab synchro
elseif erp2eeg==0 && eeg2erp==1 && bidirec==0
    direction = 2; %eeglab to erplab synchro
elseif erp2eeg==0 && eeg2erp==0 && bidirec==1
    direction = 3; % both
else
    direction = 0; % none
end

handles.output = direction;

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
        %The GUI is still in UIWAIT, us UIRESUME
        handles.output = [];
        %Update handles structure
        guidata(hObject, handles);
        uiresume(handles.gui_chassis);
else
        % The GUI is no longer waiting, just close it
        delete(handles.gui_chassis);
end
