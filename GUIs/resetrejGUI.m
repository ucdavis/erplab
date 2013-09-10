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

function varargout = resetrejGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @resetrejGUI_OpeningFcn, ...
        'gui_OutputFcn',  @resetrejGUI_OutputFcn, ...
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
function resetrejGUI_OpeningFcn(hObject, eventdata, handles, varargin)

for i=1:16
        handles.(['flg' num2str(i)]) = 0;
end
% Choose default command line output for resetrejGUI
handles.output = [];

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB BETA ' version '   -   Reset Artifact Detection Process GUI'])

set(handles.checkbox_resetARM, 'value',1)
set(handles.checkbox_flags, 'value',0)
set(handles.ALL_flags, 'enable', 'off')

for i=1:16
        eval(['set(handles.flag_' num2str(i) ', ''value'', 0);'])
        eval(['set(handles.flag_' num2str(i) ', ''enable'', ''off'');'])
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

% UIWAIT makes resetrejGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

%--------------------------------------------------------------------------
function varargout = resetrejGUI_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.gui_chassis);pause(0.5)

%--------------------------------------------------------------------------
function flag_16_Callback(hObject, eventdata, handles)

for i=1:16
        eval(['flg' num2str(i) ' = get(handles.flag_' num2str(i) ',''value'');'])
end
for i=1:16
        eval(['handles.flg' num2str(i) ' = flg' num2str(i) ';'])
end
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function flag_15_Callback(hObject, eventdata, handles)

for i=1:16
        eval(['flg' num2str(i) ' = get(handles.flag_' num2str(i) ',''value'');'])
end
for i=1:16
        eval(['handles.flg' num2str(i) ' = flg' num2str(i) ';'])
end
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function flag_14_Callback(hObject, eventdata, handles)

for i=1:16
        eval(['flg' num2str(i) ' = get(handles.flag_' num2str(i) ',''value'');'])
end
for i=1:16
        eval(['handles.flg' num2str(i) ' = flg' num2str(i) ';'])
end
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function flag_13_Callback(hObject, eventdata, handles)

for i=1:16
        eval(['flg' num2str(i) ' = get(handles.flag_' num2str(i) ',''value'');'])
end
for i=1:16
        eval(['handles.flg' num2str(i) ' = flg' num2str(i) ';'])
end
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function flag_12_Callback(hObject, eventdata, handles)

for i=1:16
        eval(['flg' num2str(i) ' = get(handles.flag_' num2str(i) ',''value'');'])
end
for i=1:16
        eval(['handles.flg' num2str(i) ' = flg' num2str(i) ';'])
end
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function flag_11_Callback(hObject, eventdata, handles)

for i=1:16
        eval(['flg' num2str(i) ' = get(handles.flag_' num2str(i) ',''value'');'])
end
for i=1:16
        eval(['handles.flg' num2str(i) ' = flg' num2str(i) ';'])
end
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function flag_10_Callback(hObject, eventdata, handles)

for i=1:16
        eval(['flg' num2str(i) ' = get(handles.flag_' num2str(i) ',''value'');'])
end
for i=1:16
        eval(['handles.flg' num2str(i) ' = flg' num2str(i) ';'])
end
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function flag_9_Callback(hObject, eventdata, handles)

for i=1:16
        eval(['flg' num2str(i) ' = get(handles.flag_' num2str(i) ',''value'');'])
end
for i=1:16
        eval(['handles.flg' num2str(i) ' = flg' num2str(i) ';'])
end
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function flag_8_Callback(hObject, eventdata, handles)

for i=1:16
        eval(['flg' num2str(i) ' = get(handles.flag_' num2str(i) ',''value'');'])
end
for i=1:16
        eval(['handles.flg' num2str(i) ' = flg' num2str(i) ';'])
end
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function flag_7_Callback(hObject, eventdata, handles)

for i=1:16
        eval(['flg' num2str(i) ' = get(handles.flag_' num2str(i) ',''value'');'])
end
for i=1:16
        eval(['handles.flg' num2str(i) ' = flg' num2str(i) ';'])
end
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function flag_6_Callback(hObject, eventdata, handles)

for i=1:16
        eval(['flg' num2str(i) ' = get(handles.flag_' num2str(i) ',''value'');'])
end
for i=1:16
        eval(['handles.flg' num2str(i) ' = flg' num2str(i) ';'])
end
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function flag_5_Callback(hObject, eventdata, handles)

for i=1:16
        eval(['flg' num2str(i) ' = get(handles.flag_' num2str(i) ',''value'');'])
end
for i=1:16
        eval(['handles.flg' num2str(i) ' = flg' num2str(i) ';'])
end
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function flag_4_Callback(hObject, eventdata, handles)

for i=1:16
        eval(['flg' num2str(i) ' = get(handles.flag_' num2str(i) ',''value'');'])
end
for i=1:16
        eval(['handles.flg' num2str(i) ' = flg' num2str(i) ';'])
end
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function flag_3_Callback(hObject, eventdata, handles)

for i=1:16
        eval(['flg' num2str(i) ' = get(handles.flag_' num2str(i) ',''value'');'])
end
for i=1:16
        eval(['handles.flg' num2str(i) ' = flg' num2str(i) ';'])
end
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function flag_2_Callback(hObject, eventdata, handles)

for i=1:16
        eval(['flg' num2str(i) ' = get(handles.flag_' num2str(i) ',''value'');'])
end
for i=1:16
        eval(['handles.flg' num2str(i) ' = flg' num2str(i) ';'])
end
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function flag_1_Callback(hObject, eventdata, handles)

for i=1:16
        eval(['flg' num2str(i) ' = get(handles.flag_' num2str(i) ',''value'');'])
end
for i=1:16
        eval(['handles.flg' num2str(i) ' = flg' num2str(i) ';'])
end
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function checkbox_resetARM_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function checkbox_flags_Callback(hObject, eventdata, handles)

if get(hObject, 'value')
        
        set(handles.ALL_flags, 'enable', 'on')
        for i=1:16
                eval(['set(handles.flag_' num2str(i) ', ''value'', 0);'])
                eval(['set(handles.flag_' num2str(i) ', ''enable'', ''on'');'])
        end
else
        set(handles.ALL_flags, 'enable', 'off')
        for i=1:16
                eval(['set(handles.flag_' num2str(i) ', ''value'', 0);'])
                eval(['set(handles.flag_' num2str(i) ', ''enable'', ''off'');'])
        end
end

%--------------------------------------------------------------------------
function ALL_flags_Callback(hObject, eventdata, handles)

for i=1:16
        eval(['flg' num2str(i) ' = handles.flg' num2str(i) ';'])
end

if get(hObject, 'value')
        for i=1:16
                eval(['set(handles.flag_' num2str(i) ',''value'', 1);'])
        end
        
        
else
        for i=1:16
                eval(['set(handles.flag_' num2str(i) ',''value'', flg' num2str(i) ');'])
        end
        
end

%--------------------------------------------------------------------------
function radiobutton2_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton_reset_Callback(hObject, eventdata, handles)

for i=1:16
        eval(['flg' num2str(i) ' = get(handles.flag_' num2str(i) ',''value'');'])
end

flagdec = bin2dec(num2str([flg16 flg15 flg14 flg13 flg12 flg11 flg10...
        flg9 flg8 flg7 flg6 flg5 flg4 flg3 flg2 flg1]));

eeglabAR = get(handles.checkbox_resetARM, 'value');

handles.output = {eeglabAR, flagdec};

% Update handles structure
guidata(hObject, handles);

uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];

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
