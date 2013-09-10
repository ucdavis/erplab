function varargout = insertcodearoundGUI(varargin)
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

% Last Modified by GUIDE v2.5 26-Aug-2013 13:02:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @insertcodearoundGUI_OpeningFcn, ...
        'gui_OutputFcn',  @insertcodearoundGUI_OutputFcn, ...
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
function insertcodearoundGUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = [];

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

% UIWAIT makes insertcodearoundGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

% -------------------------------------------------------------------------
function varargout = insertcodearoundGUI_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

% -------------------------------------------------------------------------
function edit_master_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_master_CreateFcn(hObject, eventdata, handles)

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
function edit_latency_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_latency_CreateFcn(hObject, eventdata, handles)

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

mastercodex = char(get(handles.edit_master, 'String'));
mastercodex = regexprep(mastercodex,'''|"','');
mastercell  = regexp(mastercodex,'(\S+)', 'tokens');

if isempty(mastercell)
        mastercode = str2num(mastercodex);
        if isempty(mastercode)
                mastercode = mastercodex;
        end
else
        for i=1:length(mastercell)
                mastercode{i} = char(mastercell{i});
        end
end

newcode  = str2num(get(handles.edit_newcode, 'String'));

newlate  = str2num(get(handles.edit_latency, 'String'));

if isempty(mastercode) ||     isempty(newcode) ||  isempty(newlate)
        msgboxText{1} =  'Error: Missing input(s).';
        title = 'ERPLAB: insertcodearoundGUI():';
        errorfound(msgboxText, title);
        return
end
if size(mastercode,1)>1 || size(newcode,1)>1 || size(newlate,1)>1
        msgboxText =  'pop_insertcodearound() only works with row arrays.';
        title = 'ERPLAB: pop_insertcodearound GUI';
        errorfound(msgboxText, title);
        return
end

if size(mastercode,1)~=size(newcode,1) || size(newcode,1)~=size(newlate,1)
        msgboxText =  'ERROR: Seed codes, new codes, and new latencies array must have the same size.';
        title = 'ERPLAB: pop_insertcodearound GUI';
        errorfound(msgboxText, title);
        return
end

handles.output = {mastercode, newcode, newlate};

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
