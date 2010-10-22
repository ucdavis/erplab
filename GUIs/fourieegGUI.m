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

function varargout = fourieegGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @fourieegGUI_OpeningFcn, ...
        'gui_OutputFcn',  @fourieegGUI_OutputFcn, ...
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
function fourieegGUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = [];
ERPLAB = varargin{1};

if iserpstruct(ERPLAB)
        nchan    = ERPLAB.nchan;
        typedata = 'ERP';
else
        nchan    = ERPLAB.nbchan;
        typedata = 'EEG';
end

fs = ERPLAB.srate;
handles.fs = fs;

% Update handles structure
guidata(hObject, handles);

%
% Name & version
%
version = geterplabversion;
set(handles.figure1,'Name', ['ERPLAB ' version '   -   ' typedata ' Amplitude Spectrum GUI'])

%
% Prepare List of current Channels
%
listch = [];

if isempty(ERPLAB.chanlocs)
        for e = 1:nchan
                ERPLAB.chanlocs(e).labels = ['Ch' num2str(e)];
        end
end

for ch =1:nchan
        listch{ch} = [num2str(ch) ' = ' ERPLAB.chanlocs(ch).labels ];
end

listch{end+1} = 'All Channels';

set(handles.popupmenu_channels,'String', listch)
set(handles.edit_f1,'String', '1');
set(handles.edit_f2,'String', num2str(fs/2));

%
% Color GUI
%
handles = painterplab(handles);

% UIWAIT makes fourieegGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);

%--------------------------------------------------------------------------
function varargout = fourieegGUI_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);
pause(0.1)

%--------------------------------------------------------------------------
function edit_f1_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_f1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_f2_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_f2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_channels_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_channels_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)

handles.output= '';
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);

%--------------------------------------------------------------------------
function pushbutton_plot_Callback(hObject, eventdata, handles)

channel  = get(handles.popupmenu_channels,'Value');
strchlen = length(get(handles.popupmenu_channels,'String'));

if channel==strchlen
        channel = 1:strchlen-1;
end

f1 = str2num(get(handles.edit_f1,'String'));
f2 = str2num(get(handles.edit_f2,'String'));
fs = handles.fs;

if isempty(f1) || isempty(f2)
        return
end
if f1>=f2
        return
end
if f1<0 || f2<0
        return
end
if f1>fs/2 || f2>fs/2
        return
end

outstr = {channel, f1, f2};
handles.output = outstr;

% Update handles structure
guidata(hObject, handles);

uiresume(handles.figure1);

%--------------------------------------------------------------------------
function figure1_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        uiresume(handles.figure1);
else
        % The GUI is no longer waiting, just close it
        delete(handles.figure1);
end
