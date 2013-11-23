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

function varargout = str2codeGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @str2codeGUI_OpeningFcn, ...
        'gui_OutputFcn',  @str2codeGUI_OutputFcn, ...
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
function str2codeGUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.nameinput = '@#@'; % trick
try
    EEG     = varargin{1};
    nevent  = length(EEG.event);
catch
    EEG = [];
    nevent   = 0;
end

handles.output  = EEG;
handles.command = '';
indxcode = [];
ntype    = {[]};

for i=1:nevent
    capnum = str2num(EEG.event(i).type);
    if isempty(capnum)
        indxcode = [indxcode i]; % indexes where strings were found.
    end
    ntype{i} = capnum;
end

handles.indxcode = indxcode;
handles.EEG   = EEG;
handles.ntype = ntype;

if ~isempty(EEG)
    [lists, m1, capindx] = unique_bc2({EEG.event(indxcode).type});  % non-repeteaded found strings.
    handles.lists = lists;
    nlist   = length(lists);                     % amount of  non-repeteaded found strings.
    liststr = char((lists)');
    liststr = [num2str((1:nlist)') repmat(':   ',nlist,1) liststr];
    set(handles.edit_strings,'String', liststr)
    listnum = [num2str((1:nlist)') repmat(':   ',nlist,1) repmat('-99',nlist,1)];
    set(handles.edit_numerics,'String', listnum)
    handles.capindx = capindx;
end

% Update handles structure
guidata(hObject, handles);

%
% Color GUI
%
handles = painterplab(handles);

drawnow

% UIWAIT makes str2codeGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

%--------------------------------------------------------------------------
function varargout = str2codeGUI_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles.command;

% The figure can be deleted now
delete(handles.gui_chassis);

%--------------------------------------------------------------------------
function edit_strings_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_strings_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_numerics_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_numerics_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)

handles.command= '';
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function pushbutton_accept_Callback(hObject, eventdata, handles)

EEG       = handles.EEG;
nevent    = length(EEG.event);
indxcode  = handles.indxcode;
capindx   = handles.capindx;
ntype     = handles.ntype;

for i=1:nevent
        EEG.event(i).type = ntype{i}; % now each code is a number
end

allnumlist = get(handles.edit_numerics, 'String');
lastline   = size(allnumlist,1);

%replace strings by numbers
for i=1:lastline
        mat     = regexp(allnumlist(i,:),'(\-*\d+)','match');
        newcode(i) = str2num(char(mat{2}));
        p = find(capindx==i);
        [EEG.event(indxcode(p)).type] = deal(newcode(i));
end

lists = handles.lists;

com = sprintf('%s = erp_str2code( %s, { ', handles.nameinput, handles.nameinput);

for j=1:lastline
        com = sprintf('%s ''%s'' ', com, lists{j} );
end;

newcodestr = num2str(newcode);

com = sprintf('%s }, [%s]);', com, newcodestr);

handles.command = com;
handles.output  = EEG;

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        uiresume(handles.gui_chassis);
else
        % The GUI is no longer waiting, just close it
        delete(handles.gui_chassis);
end
