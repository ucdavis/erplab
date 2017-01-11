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
try
        def = varargin{1};
catch
        def = {'' 'boundary' -99 1 1};
end
try
        multieeg = varargin{2};
catch
        multieeg = 0;
end

elname             = def{1};
boundarystrcode    = def{2};
newboundarynumcode = def{3};
rwwarn             = def{4};
alphanum           = def{5};

if iscell(newboundarynumcode)
        newboundarynumcode = cell2mat(newboundarynumcode);
end

handles.output = [];
handles.owfp   = 0;  % over write file permission
set(handles.edit_elname,'String',elname);

if isempty(elname)
        set(handles.edit_elname,'Enable','off');
        set(handles.pushbutton_browse,'Enable','off');  
        set(handles.checkbox_create_eventlist,'Value',0);
else
        set(handles.checkbox_create_eventlist,'Value',1);
        set(handles.edit_elname,'Enable','on');
        set(handles.pushbutton_browse,'Enable','on');
end
set(handles.checkbox_addm99,'Value',0);
if isempty(boundarystrcode)
        set(handles.checkbox_convert_boundary,'Value',0);
        set(handles.edit_boundarycode,'Enable', 'off');
        set(handles.edit_numericode,'Enable', 'off');
else
        set(handles.checkbox_convert_boundary,'Value',1);
        set(handles.edit_boundarycode,'Enable', 'on');
        set(handles.edit_numericode,'Enable', 'on');
                
        if iscell(boundarystrcode)
              bb = sprintf('%s ', boundarystrcode{:});
        else
              bb = char(boundarystrcode);
        end
        set(handles.edit_boundarycode, 'String', bb);
        set(handles.edit_numericode, 'String',num2str(newboundarynumcode));
end

set(handles.ELwarning,'Value', rwwarn);
set(handles.checkbox_alphanum,'Value', alphanum);
if multieeg==1
        set(handles.pushbutton_advanced, 'Enable', 'off')
else
        set(handles.pushbutton_advanced, 'Enable', 'on')
end

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   CREATE BASIC EVENTLIST GUI'])

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
helpbutton


% UIWAIT makes creabasiceventlistGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

%--------------------------------------------------------------------------
function varargout = creabasiceventlistGUI_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
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
[elpathname, elfilename, ext] = fileparts(fullname);

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
        [pathx, elfilename, ext] = fileparts(elfname);
        
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
function pushbutton_help_Callback(hObject, eventdata, handles)
% doc pop_creaeventlist
web https://github.com/lucklab/erplab/wiki/Creating-An-EVENTLIST -browser

%--------------------------------------------------------------------------
function pushbutton_apply_Callback(hObject, eventdata, handles)

fullname  = char(get(handles.edit_elname, 'String'));

if get(handles.checkbox_create_eventlist, 'Value') && ~strcmp(fullname,'')
        
        [elpathname, elfilename, ext] = fileparts(fullname);
        
        if strcmpi(elpathname,'')
                elpathname = cd;
        end        
        if ~strcmpi(ext,'.txt')
                ext='.txt';
        end
      
        elfilename = fullfile(elpathname, [elfilename ext]);
        owfp = handles.owfp;  % over write file permission
        
        if exist(elfilename, 'file')~=0 && owfp==0
                question = ['%s already exists!\n\n'...
                           'Do you want to replace it?'];
                title    = 'ERPLAB: Overwriting Confirmation';
                button   = askquest(sprintf(question, elfilename), title);
                
                if ~strcmpi(button, 'yes')
                        return
                end
        end
        
        disp(['For EVENTLIST text file, user selected ', fullfile(elpathname, elfilename)])        
else
        elfilename = '';
end
if get(handles.checkbox_addm99,'Value')
      boundarystrcode1    = {'boundary'};
      newboundarynumcode1 = -99;
else
      boundarystrcode1    = {''};
      newboundarynumcode1 = [];
end
if get(handles.checkbox_convert_boundary,'Value')
      boundarystrcode2    = strtrim(char(get(handles.edit_boundarycode, 'String')));
      boundarystrcode2    = regexp(boundarystrcode2,'\s*\w*\s*', 'match');
      newboundarynumcode2 = str2num(get(handles.edit_numericode, 'String'));      
      
      if isempty(newboundarynumcode2)
            msgboxText =  'You must specify a numeric code!';
            title = 'ERPLAB: empty input';
            errorfound(msgboxText, title);
            return
      end      
      if isempty(boundarystrcode2)
            msgboxText =  'You must specify a boundary code!';
            title = 'ERPLAB: empty input';
            errorfound(msgboxText, title);
            return
      end      
      if length(newboundarynumcode2)~=length(boundarystrcode2)
            msgboxText =  'You must specify the same amount of numeric and string codes!';
            title = 'ERPLAB: different inputs';
            errorfound(msgboxText, title);
            return
      end           
      if get(handles.checkbox_addm99,'Value')            
            newboundarynumcode2 = newboundarynumcode2(~ismember_bc2(boundarystrcode2, 'boundary'));
            boundarystrcode2    = boundarystrcode2(~ismember_bc2(boundarystrcode2, 'boundary'));            
            if isempty(boundarystrcode2)
                  msgboxText =  '''boundary'' event is already specified!\nUncheck one option or change the event name.';
                  title = 'ERPLAB: redundant input';
                  errorfound(sprintf(msgboxText), title);
                  return
            end
      end
      if strcmp(boundarystrcode2, boundarystrcode1)
            msgboxText =  '''boundary'' event is already specified to be numerically encoded.';
            title = 'ERPLAB: duplicated inputs';
            errorfound(msgboxText, title);
            return
      end
else
      boundarystrcode2    = [];
      newboundarynumcode2 = [];
end

alphanum = get(handles.checkbox_alphanum, 'Value'); % for letterkilla. Oct 10, 2012

boundarystrcode    = [boundarystrcode1 boundarystrcode2];
newboundarynumcode = {newboundarynumcode1 newboundarynumcode2};
boundarystrcode    = boundarystrcode(~cellfun(@isempty, boundarystrcode));
newboundarynumcode = newboundarynumcode(~cellfun(@isempty, newboundarynumcode));
iswarning = get(handles.ELwarning, 'Value');
outputcell = {elfilename, boundarystrcode, newboundarynumcode, iswarning, alphanum};
handles.output = outputcell;
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
function edit_boundarycode_Callback(hObject, eventdata, handles)

boundarystrcode = strtrim(char(get(handles.edit_boundarycode, 'String')));
boundarystrcode = strtrim(boundarystrcode);
boundarystrcode = regexprep(boundarystrcode, '''|"','');
%boundarystrcode = ['''' boundarystrcode ''''];
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
if get(hObject,'Value')
        set(handles.checkbox_convert_boundary,'Value', 0);
        set(handles.edit_boundarycode,'Enable', 'off');
        set(handles.edit_numericode,'Enable', 'off');
else
        set(hObject, 'Value', 1)
end

%--------------------------------------------------------------------------
function checkbox_convert_boundary_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.checkbox_addm99,'Value', 0);
        set(handles.edit_boundarycode,'Enable', 'on');
        set(handles.edit_numericode,'Enable', 'on');
else
        set(hObject, 'Value', 1)
end

%--------------------------------------------------------------------------
function checkbox_alphanum_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function ELwarning_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton_advanced_Callback(hObject, eventdata, handles)
handles.output = 'advanced';
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        handles.output = [];
        % Update handles structure
        guidata(hObject, handles);
        uiresume(handles.gui_chassis);
else
        % The GUI is no longer waiting, just close it
        delete(handles.gui_chassis);
end

