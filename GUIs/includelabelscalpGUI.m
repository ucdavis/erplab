% Author: Javier Lopez-Calderon
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

function varargout = includelabelscalpGUI(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @includelabelscalpGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @includelabelscalpGUI_OutputFcn, ...
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
function includelabelscalpGUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = [];
%values = [binnum bindesc type latency electrodes colorbar];
try
      val = varargin{1};
catch
      val = [1 0 0 1 1 0];
end
binnum     = val(1);
bindesc    = val(2);
type       = val(3);
latency    = val(4);
electrodes = val(5);
% colorbar   = val(6);
ismaxim    = val(6);

set(handles.checkbox_binnumber,'Value', binnum)
set(handles.checkbox_bindescription,'Value', bindesc)
set(handles.checkbox_tvalue,'Value', type)
set(handles.checkbox_latency,'Value', latency)
set(handles.checkbox_electrodes,'Value', electrodes)
% set(handles.checkbox_cbar,'Value', colorbar)
set(handles.checkbox_maximize,'Value', ismaxim)

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

% UIWAIT makes includelabelscalpGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

% -----------------------------------------------------------------------
function varargout = includelabelscalpGUI_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

% -----------------------------------------------------------------------
function checkbox_binnumber_Callback(hObject, eventdata, handles)

% -----------------------------------------------------------------------
function checkbox_bindescription_Callback(hObject, eventdata, handles)

% -----------------------------------------------------------------------
function checkbox_tvalue_Callback(hObject, eventdata, handles)

% -----------------------------------------------------------------------
function checkbox_latency_Callback(hObject, eventdata, handles)

% -----------------------------------------------------------------------
function checkbox_electrodes_Callback(hObject, eventdata, handles)

% -----------------------------------------------------------------------
% function checkbox_cbar_Callback(hObject, eventdata, handles)

% -----------------------------------------------------------------------
function checkbox_maximize_Callback(hObject, eventdata, handles)

% -----------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

% -----------------------------------------------------------------------
function pushbutton_OK_Callback(hObject, eventdata, handles)

binnum     = get(handles.checkbox_binnumber,'Value');
bindesc    = get(handles.checkbox_bindescription,'Value');
type       = get(handles.checkbox_tvalue,'Value');
latency    = get(handles.checkbox_latency,'Value');
electrodes = get(handles.checkbox_electrodes,'Value');
% colorbar   = get(handles.checkbox_cbar,'Value');
ismaxim    = get(handles.checkbox_maximize,'Value');

% handles.output = [binnum bindesc type latency electrodes colorbar ismaxim];
handles.output = [binnum bindesc type latency electrodes ismaxim];

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);


% -----------------------------------------------------------------------
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
