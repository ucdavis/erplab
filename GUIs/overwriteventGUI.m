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

function varargout = overwriteventGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @overwriteventGUI_OpeningFcn, ...
        'gui_OutputFcn',  @overwriteventGUI_OutputFcn, ...
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
function overwriteventGUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for overwriteventGUI
handles.output = [];

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   Modify EEG.event GUI'])
set(handles.radiobutton_clabels, 'Value', 1)
set(handles.checkbox_removenctype, 'Enable', 'off');

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

% UIWAIT makes overwriteventGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

% -------------------------------------------------------------------------
function varargout = overwriteventGUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.gui_chassis);

% -------------------------------------------------------------------------
function checkbox_removenctype_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function radiobutton_bini_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.checkbox_removenctype, 'Enable', 'on');        
        set(handles.radiobutton_blabels, 'Value', 0);
        set(handles.radiobutton_clabels, 'Value', 0);
        set(handles.radiobutton_numcodes, 'Value', 0);
else
        set(hObject, 'Value', 1);
end

% -------------------------------------------------------------------------
function radiobutton_blabels_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
%         set(handles.checkbox_removenctype, 'Value', 0); 
        set(handles.checkbox_removenctype, 'Enable', 'on');        
        set(handles.radiobutton_bini, 'Value', 0);
        set(handles.radiobutton_clabels, 'Value', 0);
        set(handles.radiobutton_numcodes, 'Value', 0);
else
        set(hObject, 'Value', 1);
end

% -------------------------------------------------------------------------
function radiobutton_clabels_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.checkbox_removenctype, 'Value', 0); 
        set(handles.checkbox_removenctype, 'Enable', 'off');        
        set(handles.radiobutton_blabels, 'Value', 0);
        set(handles.radiobutton_bini, 'Value', 0);
        set(handles.radiobutton_numcodes, 'Value', 0);
else
        set(hObject, 'Value', 1);
end

% -------------------------------------------------------------------------
function radiobutton_numcodes_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.checkbox_removenctype, 'Value', 0); 
        set(handles.checkbox_removenctype, 'Enable', 'off');        
        set(handles.radiobutton_blabels, 'Value', 0);
        set(handles.radiobutton_clabels, 'Value', 0);
        set(handles.radiobutton_bini, 'Value', 0);
else
        set(hObject, 'Value', 1);
end

% -------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

% -------------------------------------------------------------------------
function pushbutton_apply_Callback(hObject, eventdata, handles)
if get(handles.radiobutton_numcodes, 'Value') && ~get(handles.radiobutton_clabels, 'Value') && ~get(handles.radiobutton_blabels, 'Value') && ~get(handles.radiobutton_bini, 'Value')
        field = 'code';        
elseif ~get(handles.radiobutton_numcodes, 'Value') && get(handles.radiobutton_clabels, 'Value') && ~get(handles.radiobutton_blabels, 'Value') && ~get(handles.radiobutton_bini, 'Value')
        field = 'codelabel';
elseif ~get(handles.radiobutton_numcodes, 'Value') && ~get(handles.radiobutton_clabels, 'Value') && get(handles.radiobutton_blabels, 'Value') && ~get(handles.radiobutton_bini, 'Value')
        field = 'binlabel';
else       
        field = 'bini';
end
removenctype = get(handles.checkbox_removenctype, 'Value');
handles.output = {field, removenctype};

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);
disp('User selected Cancel')
return

%--------------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        uiresume(handles.gui_chassis);
else
        % The GUI is no longer waiting, just close it
        delete(handles.gui_chassis);
end
