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

function varargout = creabasiceventlistGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @creabasiceventlistGUI_OpeningFcn, ...
        'gui_OutputFcn',  @creabasiceventlistGUI_OutputFcn, ...
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
function creabasiceventlistGUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
handles.owfp = 0;  % over write file permission

% Update handles structure
guidata(hObject, handles);

set(handles.edit_elname,'String','');
set(handles.edit_elname,'Enable','off');
set(handles.pushbutton_browse,'Enable','off');
set(handles.checkbox_create_eventlist,'Value',0);
set(handles.checkbox_addm99,'Value',1);
set(handles.checkbox_convert_boundary,'Value',0);
set(handles.edit_boundarycode,'Enable', 'off');
set(handles.edit_numericode,'Enable', 'off');

%
% Default boundary code
%
boundarystrcode    = '''boundary''';
newboundarynumcode = -99;
set(handles.edit_boundarycode, 'String', boundarystrcode);
set(handles.edit_numericode, 'String',num2str(newboundarynumcode));

%
% Color GUI
%
handles = painterplab(handles);

% UIWAIT makes creabasiceventlistGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);

%--------------------------------------------------------------------------
function varargout = creabasiceventlistGUI_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);
pause(0.5)

%--------------------------------------------------------------------------
function checkbox_create_eventlist_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
        set(handles.edit_elname,'Enable','on');
        set(handles.pushbutton_browse,'Enable','on');
else
        set(handles.edit_elname,'Enable','off');
        set(handles.pushbutton_browse,'Enable','off');
end

%--------------------------------------------------------------------------
function edit_elname_Callback(hObject, eventdata, handles)

fullname = char(get(hObject, 'String'));
[elpathname, elfilename, ext, versn] = fileparts(fullname);

if strcmpi(elpathname,'')
        elpathname = cd;
end
if ~strcmpi(ext,'.txt')
        ext='.txt';
end

elfilename = [elfilename ext];
handles.elfilename  = elfilename;
handles.elpathname  = elpathname;

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function edit_elname_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_browse_Callback(hObject, eventdata, handles)

%
% Save EVENTLIST file
%
prename = get(handles.edit_elname,'String');
[elfname, elpathname] = uiputfile({'*.txt';'*.*'},'Save EVENTLIST text file as', prename);

if isequal(elfname,0)
        disp('User selected Cancel')
        handles.owfp = 0;  % over write file permission
        guidata(hObject, handles);
        return
else
        [pathx, elfilename, ext, versn] = fileparts(elfname);
        
        if ~strcmpi(ext,'.txt')
                ext='.txt';
        end
        
        elfilename = [elfilename ext];
        handles.elfilename  = elfilename;
        handles.elpathname  = elpathname;
        set(handles.edit_elname,'String', fullfile(elpathname, elfilename));
        handles.owfp     = 1;  % over write file permission
        
        % Update handles structure
        guidata(hObject, handles);
        disp(['For EVENTLIST text file, user selected ', fullfile(elpathname, elfilename)])
end

%--------------------------------------------------------------------------
function pushbutton_apply_Callback(hObject, eventdata, handles)

fullname  = char(get(handles.edit_elname, 'String'));

if get(handles.checkbox_create_eventlist, 'Value') && ~strcmp(fullname,'')
        
        [elpathname, elfilename, ext, versn] = fileparts(fullname);
        
        if strcmpi(elpathname,'')
                elpathname = cd;
        end
        
        if ~strcmpi(ext,'.txt')
                ext='.txt';
        end
        
        elfilename = [elfilename ext];
        
        owfp = handles.owfp;  % over write file permission
        
        if exist(elfilename, 'file')~=0 && owfp==0
                question{1} = [elfilename ' already exists!'];
                question{2} = 'Do you want to replace it?';
                title      = 'ERPLAB: Overwriting Confirmation';
                button      = askquest(question, title);
                
                if ~strcmpi(button, 'yes')
                        return
                end
        end
        
        disp(['For EVENTLIST text file, user selected ', fullfile(elpathname, elfilename)])
        
else
        elfilename = '';
end

if get(handles.checkbox_addm99,'Value')
        boundarystrcode1    = 'boundary';
        newboundarynumcode1 = -99;
else
        boundarystrcode1    = [];
        newboundarynumcode1 = [];
end

if get(handles.checkbox_convert_boundary,'Value')
        
        boundarystrcode2    = strtrim(char(get(handles.edit_boundarycode, 'String')));
        boundarystrcode2    = char(regexprep(boundarystrcode2,'''|"','')); % eliminates 's and "s
        newboundarynumcode2 = str2num(get(handles.edit_numericode, 'String'));
        
        if isempty(boundarystrcode2)
                msgboxText{1} =  'You must specify a boundary code!';
                title = 'ERPLAB: empty input';
                errorfound(msgboxText, title)
                return
        end
        if isempty(newboundarynumcode2)
                msgboxText{1} =  'You must specify a numeric code!';
                title = 'ERPLAB: empty input';
                errorfound(msgboxText, title)
                return
        end
        if strcmp(boundarystrcode2, boundarystrcode1)
                msgboxText{1} =  '''boundary'' event is already specified to be numerically encoded.';
                title = 'ERPLAB: duplicated inputs';
                errorfound(msgboxText, title)
                return
        end
else
        boundarystrcode2    = [];
        newboundarynumcode2 = [];
end

boundarystrcode    = {boundarystrcode1 boundarystrcode2};
newboundarynumcode = {newboundarynumcode1 newboundarynumcode2};
boundarystrcode    = boundarystrcode(~cellfun(@isempty, boundarystrcode));
newboundarynumcode = newboundarynumcode(~cellfun(@isempty, newboundarynumcode));

outputcell = {elfilename, boundarystrcode, newboundarynumcode};

handles.output = outputcell;
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);

%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)

handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);

%--------------------------------------------------------------------------
function figure1_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        handles.output = [];
        % Update handles structure
        guidata(hObject, handles);
        uiresume(handles.figure1);
else
        % The GUI is no longer waiting, just close it
        delete(handles.figure1);
end

%--------------------------------------------------------------------------
function edit_boundarycode_Callback(hObject, eventdata, handles)

boundarystrcode = strtrim(char(get(handles.edit_boundarycode, 'String')));
boundarystrcode = strtrim(boundarystrcode);
boundarystrcode = regexprep(boundarystrcode, '''|"','');
boundarystrcode = ['''' boundarystrcode ''''];
set(handles.edit_boundarycode, 'String', boundarystrcode)
return

%--------------------------------------------------------------------------
function edit_boundarycode_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_numericode_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_numericode_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function checkbox_addm99_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function checkbox_convert_boundary_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
        set(handles.edit_boundarycode,'Enable', 'on');
        set(handles.edit_numericode,'Enable', 'on');
else
        set(handles.edit_boundarycode,'Enable', 'off');
        set(handles.edit_numericode,'Enable', 'off');
end
