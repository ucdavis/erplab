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

function varargout = savemyerpGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @savemyerpGUI_OpeningFcn, ...
        'gui_OutputFcn',  @savemyerpGUI_OutputFcn, ...
        'gui_LayoutFcn',  [] , ...
        'gui_Callback',   []);

if nargin && ischar(varargin{1})
        if isempty(strfind(varargin{1},' ')) && isempty(str2num(varargin{1})) && isempty(strfind(varargin{1},'&'))
                gui_State.gui_Callback = str2func(varargin{1});
        end
end

if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
        gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% -------------------------------------------------------------------------
function savemyerpGUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for savemyerpGUI

try
        erpname  = varargin{1};
        filename = varargin{2};
        overw    = varargin{3};
catch
        erpname  = '';
        filename = '';
        overw    = 0;
end

handles.erpnameor = erpname;
handles.output = [];
erpmenu  = findobj('tag', 'erpsets');

if ~isempty(erpmenu)
    handles.menuerp = get(erpmenu);
    set(handles.menuerp.Children, 'Enable','off');
end

handles.owfp = 0;  % over write file permission

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   Save Erpset GUI'])
set(handles.edit_erpname, 'String', erpname);

if ~isempty(filename)
        set(handles.edit_saveas, 'Enable', 'on');
        set(handles.edit_saveas, 'String', filename);
        set(handles.radiobutton_saveas, 'Value', 1);
        set(handles.pushbutton_same_as_erpname, 'Enable', 'on');
        set(handles.pushbutton_same_as_filename, 'Enable', 'on');
        set(handles.pushbutton_browse, 'Enable', 'on');
else
        set(handles.edit_saveas, 'String', '');
        set(handles.radiobutton_saveas, 'Value', 0);
        set(handles.edit_saveas, 'Enable', 'off');
        set(handles.pushbutton_same_as_erpname, 'Enable', 'off');
        set(handles.pushbutton_same_as_filename, 'Enable', 'off');       
        set(handles.pushbutton_browse, 'Enable', 'off');
end
if overw==0
        set(handles.radiobutton_newerpset, 'Value', 1);
        set(handles.radiobutton_overwrite, 'Value', 0);
else
        set(handles.radiobutton_newerpset, 'Value', 0);
        set(handles.radiobutton_overwrite, 'Value', 1);
end
[nset CURRENTERP] = getallerpstate;
if nset>0
        set(handles.text_question,'String', ['Your active erpset is # ' num2str(CURRENTERP)],...
                'FontWeight','Bold', 'FontSize', 12)
        set(handles.radiobutton_overwrite,'String', ['Overwrite in memory erpset # ' num2str(CURRENTERP)])
        set(handles.radiobutton_newerpset,'String', ['Create a new erpset # ' num2str(nset+1)])
else
        set(handles.text_question,'String', 'You are creating a new erpset',...
                'FontSize', 12, 'FontWeight','Bold')
        set(handles.radiobutton_overwrite,'String', 'Overwrite in memory')
        set(handles.radiobutton_newerpset, 'Value', 1);
        set(handles.radiobutton_overwrite, 'Value', 0);
        set(handles.radiobutton_overwrite,'Enable', 'off')
        set(handles.radiobutton_newerpset,'String', ['Create a new erpset # ' num2str(nset+1)])
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

% UIWAIT makes savemyerpGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

% -------------------------------------------------------------------------
function varargout = savemyerpGUI_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
try
        set(handles.menuerp.Children, 'Enable','on');
catch
        disp('ERPset menu was not found...')
end
varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

% -------------------------------------------------------------------------
function edit_erpname_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_erpname_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function edit_saveas_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_saveas_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function pushbutton_browse_Callback(hObject, eventdata, handles)
%
% Save OUTPUT file
%
fndefault = get(handles.edit_saveas,'String');
[fname, pathname] = uiputfile({'*.erp', 'ERPset (*.erp)';...
                               '*.mat', 'MAT-files (*.mat)';...
                               '*.*'  , 'All Files (*.*)'},'Save Output file as',...
                               fndefault);

if isequal(fname,0)
        disp('User selected Cancel')
        guidata(hObject, handles);
        handles.owfp = 0;  % over write file permission
        guidata(hObject, handles);
else
        set(handles.edit_saveas,'String', fullfile(pathname, fname));
        disp(['To save ERP, user selected ', fullfile(pathname, fname)])
        handles.owfp = 1;  % over write file permission
        guidata(hObject, handles);
end

% -------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

% -------------------------------------------------------------------------
function pushbutton_OK_Callback(hObject, eventdata, handles)

erpname = strtrim(get(handles.edit_erpname, 'String'));

if isempty(erpname)
        msgboxText =  'You must enter an erpname at least!';
        title = 'ERPLAB: averager GUI empty erpname';
        errorfound(msgboxText, title);
        return
end

fname   = strtrim(get(handles.edit_saveas, 'String'));
overw   = get(handles.radiobutton_overwrite, 'Value');

if ~isempty(fname) && get(handles.radiobutton_saveas, 'Value')
        
        owfp = handles.owfp;  % over write file permission        
        [pathstr, name, ext] = fileparts(fname);
        
        if ~strcmp(ext,'.erp') && ~strcmp(ext,'.mat')
                ext = '.erp';
        end        
        if strcmp(pathstr,'')
                pathstr = cd;
        end
        
        fullname = fullfile(pathstr, [name ext]);
        
        if exist(fullname, 'file')~=0 && owfp ==0
                question{1} = [fullname ' already exists!'];
                question{2} = 'Do you want to replace it?';
                title      = 'ERPLAB: Overwriting Confirmation';
                button      = askquest(question, title);
                
                if ~strcmpi(button, 'yes')
                        return
                end
        end        
elseif isempty(fname) && get(handles.radiobutton_saveas, 'Value')
        msgboxText =  'You must enter a filename!';
        title = 'ERPLAB: averager GUI empty filename';
        errorfound(msgboxText, title);
        return        
else
        fullname = [];
end

handles.output = {erpname, fullname, overw};
% Update handles structure
guidata(hObject, handles);

uiresume(handles.gui_chassis);

% -------------------------------------------------------------------------
function radiobutton_saveas_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.edit_saveas, 'Enable', 'on');
        set(handles.pushbutton_browse, 'Enable', 'on');
        set(handles.pushbutton_same_as_erpname, 'Enable', 'on');
        set(handles.pushbutton_same_as_filename, 'Enable', 'on');       
else
        set(handles.edit_saveas, 'Enable', 'off');
        set(handles.pushbutton_browse, 'Enable', 'off');
        set(handles.pushbutton_same_as_erpname, 'Enable', 'off');
        set(handles.pushbutton_same_as_filename, 'Enable', 'off'); 
        set(handles.edit_saveas, 'String', '');
end

% -----------------------------------------------------------------------
function pushbutton_same_as_filename_Callback(hObject, eventdata, handles)
fname   = get(handles.edit_saveas, 'String');
%erpname = get(handles.edit_erpname, 'String');
if strcmp(fname,'')
      msgboxText =  'You must enter a filename first!';
      title = 'ERPLAB: averager GUI empty filename';
      errorfound(msgboxText, title);
      return
end
[pathstr, fname, ext] = fileparts(fname);
erpname = fname;
set(handles.edit_erpname, 'String', erpname);

% -------------------------------------------------------------------------
function pushbutton_same_as_erpname_Callback(hObject, eventdata, handles)
fname   = get(handles.edit_saveas, 'String');
erpname = get(handles.edit_erpname, 'String');
if strcmp(erpname,'')
        msgboxText =  'You must enter an erpname!';
        title = 'ERPLAB: averager GUI empty erpname';
        errorfound(msgboxText, title);
        return
end
if ~strcmp(fname,'')        
        [pathstr, name, ext] = fileparts(fname);
        name = erpname;
        if ~strcmp(ext,'.erp') && ~strcmp(ext,'.mat');
                ext = '.erp';
        end
        
        fname = fullfile(pathstr,[name ext]);
else
        fname=[erpname '.erp'];
end
set(handles.edit_saveas, 'String', fname);

% -------------------------------------------------------------------------
function radiobutton_overwrite_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
        set(handles.radiobutton_newerpset,'Value',0)        
        erpname = strtrim(get(handles.edit_erpname, 'String'));        
        if isempty(erpname)
                erpname = handles.erpnameor;
                set(handles.edit_erpname, 'String', erpname);
        end
else
        set(handles.radiobutton_overwrite, 'Value',1);        
end

% -------------------------------------------------------------------------
function radiobutton_newerpset_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
        set(handles.radiobutton_overwrite, 'Value',0);        
        erpname = strtrim(get(handles.edit_erpname, 'String'));
        
        if isempty(erpname)
                erpname = handles.erpnameor;
                set(handles.edit_erpname, 'String', erpname);
        end
else
        set(handles.radiobutton_newerpset, 'Value',1);
        
end

% -----------------------------------------------------------------------
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
