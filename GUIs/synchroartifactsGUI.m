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
% Update handles structure
guidata(hObject, handles);

% tooltip1  = ['<html><i>To synchronize artifact marks from ERPLAB to EEGLAB<br>'...
%     'ERPLAB will set each EEG.reject.rejmanual(i) value according to its<br>'...
%     'corresponding EEG.epoch(i).eventflag value (only home item flag)<br>'...
%     'It means, if EEG.epoch(i).eventflag{home}>=1 then EEG.reject.rejmanual(i)=1.'];
% 
% tooltip2  = ['<html><i>To synchronize artifact marks from EEGLAB to ERPLAB<br>'...
%     'ERPLAB will set EEG.epoch(i).eventflag=1 and EEG.EVENTLIST.eventinfo<br>'...
%     'if any of the corresponding EEG.reject.<b>rejection_function</b>(i) values is 1.'];
% 
% set(handles.edit_tip_synchro_ART1, 'tooltip',tooltip1);
% set(handles.edit_tip_synchro_ART2, 'tooltip',tooltip2);
set(handles.checkbox_erplab_to_eeglab,'value',1)
set(handles.checkbox_eeglab_to_erplab,'value',1)

%
% Name & version
%
version = geterplabversion;
set(handles.figure1,'Name', ['ERPLAB ' version '   -   SYNCHRO ARTIFACTS GUI'])

%
% Color GUI
%
handles = painterplab(handles);
% UIWAIT makes synchroartifactsGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --------------------------------------------------------------------------
function varargout = synchroartifactsGUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);
pause(0.1)
% --------------------------------------------------------------------------
function checkbox_erplab_to_eeglab_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------------
function checkbox_eeglab_to_erplab_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];

% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);

% --------------------------------------------------------------------------
function pushbutton_ok_Callback(hObject, eventdata, handles)

erp2eeg = get(handles.checkbox_erplab_to_eeglab,'value');
eeg2erp = get(handles.checkbox_eeglab_to_erplab,'value');

if erp2eeg==1 && eeg2erp==0
    direction = 1; % erplab to eeglab synchro
elseif erp2eeg==0 && eeg2erp==1
    direction = 2; %eeglab to erplab synchro
elseif erp2eeg==1 && eeg2erp==1
    direction = 3; % both
else
    direction = 0; % none
end

handles.output = direction;
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);

%--------------------------------------------------------------------------
function figure1_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
        %The GUI is still in UIWAIT, us UIRESUME
        handles.output = [];
        %Update handles structure
        guidata(hObject, handles);
        uiresume(handles.figure1);
else
        % The GUI is no longer waiting, just close it
        delete(handles.figure1);
end
