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

function varargout = code2strGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @code2strGUI_OpeningFcn, ...
        'gui_OutputFcn',  @code2strGUI_OutputFcn, ...
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
function code2strGUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.nameinput = '@#@'; % trick
EEG             = varargin{1};
handles.output  = EEG;
handles.command = '';
nevent   = length(EEG.event);

[lists, m1, capindx] = unique_bc2(cell2mat({EEG.event.type}));  % non-repeteaded found strings.
handles.lists = lists;
nlist   = length(lists);                                    % amount of  non-repeteaded found strings.
liststr = num2str(lists');
liststr = [num2str((1:nlist)') repmat(': type ',nlist,1) liststr];
listnew = [num2str((1:nlist)') repmat(':   ',nlist,1) repmat('...',nlist,1)];
auxbin  = [repmat('bin',nlist,1) num2str((1:nlist)')];
auxbin  = char(regexprep(cellstr(auxbin),' ',''));
listbin = [num2str((1:nlist)') repmat(':   ',nlist,1) auxbin];

set(handles.edit_numerics,'String', liststr)
set(handles.edit_strings,'String', listnew)
set(handles.edit_bins,'String', listbin)

handles.capindx = capindx;

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

%--------------------------------------------------------------------------
function varargout = code2strGUI_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

%--------------------------------------------------------------------------
function edit_numerics_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_numerics_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_strings_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_strings_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_bins_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_bins_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_deletebins_Callback(hObject, eventdata, handles)

button = questdlg('Are you sure you want to delete all bins edited here?','Bin Editing','NO','YES','NO');

if strcmpi(button, 'yes')
        
        lists   = handles.lists;
        nlist   = length(lists);                                    % amount of  non-repeteaded found strings.
        listbin = [num2str((1:nlist)') repmat(':   ',nlist,1) repmat('...',nlist,1)];
        set(handles.edit_bins,'String', listbin)
        disp('All edited bins were deleted.')
else
        disp('User has regreted...')
end

%--------------------------------------------------------------------------
function pushbutton_deletestrings_Callback(hObject, eventdata, handles)

button = questdlg('Are you sure you want to delete all string codes edited here?','String Code Editing','NO','YES','NO');

if strcmpi(button, 'yes')
        
        lists   = handles.lists;
        nlist   = length(lists);                                    % amount of  non-repeteaded found strings.
        liststr = [num2str((1:nlist)') repmat(':   ',nlist,1) repmat('...',nlist,1)];
        set(handles.edit_strings,'String', liststr)
        disp('All edited string codes were deleted.')
else
        disp('User has regreted...')
end

%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)

handles.command= '';
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function pushbutton_accept_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        uiresume(handles.gui_chassis);
else
        % The GUI is no longer waiting, just close it
        delete(handles.gui_chassis);
end
