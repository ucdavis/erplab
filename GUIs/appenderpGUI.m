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

function varargout = appenderpGUI(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @appenderpGUI_OpeningFcn, ...
        'gui_OutputFcn',  @appenderpGUI_OutputFcn, ...
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

% -----------------------------------------------------------------------
function appenderpGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for appenderpGUI
handles.output   = [];
handles.totline = 1;

try
        totalerpset = varargin{1};        
catch
        totalerpset = 0;
end

handles.totalerpset = totalerpset;
handles.full_list = [];

% Update handles structure
guidata(hObject, handles);


set(handles.radiobutton_includep, 'Value', 0);
set(handles.edit_prefix, 'Enable', 'off');
set(handles.pushbutton_addp, 'Enable', 'off');
set(handles.pushbutton_deletep, 'Enable', 'off');
set(handles.pushbutton_cleara, 'Enable', 'off');
set(handles.togglebutton_autonumber, 'Enable', 'off');
set(handles.listbox_prefix, 'Enable', 'off');
set(handles.listbox_prefix, 'String', {'new prefix'});

version = geterplabversion;
set(handles.figure1,'Name', ['ERPLAB ' version '   -   APPEND ERPs GUI'])
handles = painterplab(handles);

% UIWAIT makes appenderpGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);

% -----------------------------------------------------------------------
function varargout = appenderpGUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);

% -----------------------------------------------------------------------
function edit_dataset_Callback(hObject, eventdata, handles)

% -----------------------------------------------------------------------
function edit_dataset_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -----------------------------------------------------------------------
function pushbutton_RUN_Callback(hObject, eventdata, handles)

erpset = str2num(char(get(handles.edit_dataset, 'String')));

if isempty(erpset) || length(erpset)<2
        msgboxText =  'You should enter at least two datasets!';
        title = 'ERPLAB: appenderpGUI few inputs';
        errorfound(msgboxText, title);
        return
elseif length(erpset)>handles.totalerpset
        msgboxText =  'You must enter as many datasets as you have loaded at ERPSET MENU.';
        title = 'ERPLAB: appenderpGUI wrong inputs';
        errorfound(msgboxText, title);
        return
elseif min(erpset)<1 || max(erpset)>handles.totalerpset
        msgboxText =  'You must enter valid dataset indexes, according to ERPSET MENU.';
        title = 'ERPLAB: appenderpGUI wrong inputs';
        errorfound(msgboxText, title);
        return
else        
        prefixArray = get(handles.listbox_prefix, 'String')';
        totline = length(prefixArray)-1;
        
        if totline>0 && totline~=length(erpset)
                msgboxText =  'You must enter as many prefixes as erpsets you want to append.';
                title = 'ERPLAB: appenderpGUI few inputs';
                errorfound(msgboxText, title);
                return                
        end
        
        handles.output = {erpset, prefixArray(1:end-1)};
        
        % Update handles structure
        guidata(hObject, handles);
        uiresume(handles.figure1);
end

% -----------------------------------------------------------------------
function figure1_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
        %The GUI is still in UIWAIT, us UIRESUME
        handles.output = '';
        %Update handles structure
        guidata(hObject, handles);
        uiresume(handles.figure1);
else
        % The GUI is no longer waiting, just close it
        delete(handles.figure1);
end

% -----------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);

% -----------------------------------------------------------------------
function radiobutton_includep_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
        set(handles.edit_prefix, 'Enable', 'on');
        set(handles.pushbutton_addp, 'Enable', 'on');
        set(handles.pushbutton_deletep, 'Enable', 'on');
%         set(handles.togglebutton_autonumber, 'Enable', 'on');
        set(handles.listbox_prefix, 'Enable', 'on');
        set(handles.pushbutton_cleara, 'Enable', 'on');
else
        set(handles.edit_prefix, 'Enable', 'off');
        set(handles.pushbutton_addp, 'Enable', 'off');
        set(handles.pushbutton_deletep, 'Enable', 'off');
        set(handles.pushbutton_cleara, 'Enable', 'off');
        set(handles.togglebutton_autonumber, 'Enable', 'off');
        set(handles.listbox_prefix, 'Enable', 'off');
end

% -----------------------------------------------------------------------
function pushbutton_addp_Callback(hObject, eventdata, handles)

set(handles.togglebutton_autonumber, 'Value', 0);
set(handles.togglebutton_autonumber, 'Enable', 'on');

newline   = get(handles.edit_prefix,'String');
currline  = get(handles.listbox_prefix, 'Value');
full_list = get(handles.listbox_prefix, 'String');
totline  = length(full_list);

if currline==totline
        % extra line forward
        full_list  = cat(1, full_list, {'new prefix'});
        set(handles.listbox_prefix, 'Value', currline+1)
else
        set(handles.listbox_prefix, 'Value', currline)
        resto = full_list(currline:totline);
        
        full_list  = cat(1, full_list, {'new prefix'});
        set(handles.listbox_prefix, 'Value', currline+1)
        [full_list{currline+1:totline+1}] = resto{:};
end

full_list{currline} = newline;
totline             = length(full_list);
set(handles.listbox_prefix, 'String', full_list);
handles.totline     = totline;
handles.full_list   = full_list;

% Update handles structure
guidata(hObject, handles);

% -----------------------------------------------------------------------
function pushbutton_deletep_Callback(hObject, eventdata, handles)

full_list = get(handles.listbox_prefix, 'String');
totline   = length(full_list) ;
full_list = char(full_list); % string matrix
currline  = get(handles.listbox_prefix, 'Value');
set(handles.togglebutton_autonumber, 'Enable', 'off');

if currline>=1 && currline<totline
        
        full_list(currline,:) = [];
        full_list = cellstr(full_list); % cell string
        set(handles.listbox_prefix, 'String', full_list);
        listbox_prefix_Callback(hObject, eventdata, handles)
        
        handles.full_list = full_list;
        totline = length(full_list);
        
        % Update handles structure
        guidata(hObject, handles);
end

% -------------------------------------------------------------------------
function pushbutton_cleara_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cleara (see GCBO)

set(handles.listbox_prefix, 'String',{'new prefix'});
set(handles.listbox_prefix, 'Value',1);

% -----------------------------------------------------------------------
function togglebutton_autonumber_Callback(hObject, eventdata, handles)

if get(hObject,'value')
        
        erpset = str2num(char(get(handles.edit_dataset, 'String')));
        nerpset = length(erpset);
        full_list   = get(handles.listbox_prefix, 'String');
        backup_list = full_list;
        totline     = length(full_list)-1;
        full_list_new = cell(1);
        
        if  nerpset>0 && (totline==nerpset || totline==1)
                
                for i=1:nerpset
                        
                        if totline==1
                                j = 1;
                        else
                                j = i;
                        end
                        
                        full_list_new{i} = [full_list{j} ' ' num2str(i)];
                end
                
                full_list =   cat(1, full_list_new', {'new prefix'});
                set(handles.listbox_prefix, 'String', full_list);
        elseif nerpset==0
                set(handles.togglebutton_autonumber, 'Value', 0);
                set(handles.togglebutton_autonumber,'Enable','off')
                msgboxText =  'You must enter at least two datasets to use this button.';
                title = 'ERPLAB: Append ERP GUI automatic prefix numbering';
                errorfound(msgboxText, title);
                set(handles.togglebutton_autonumber,'Enable','on')
                set(handles.togglebutton_autonumber,'Enable','on')
                return
        else
                set(handles.togglebutton_autonumber,'Value',0)
                set(handles.togglebutton_autonumber,'Enable','off')
                msgboxText =  ['You have to enter 1 or ' num2str(nerpset) ' to use this button!'];
                title = 'ERPLAB: Append ERP GUI automatic prefix numbering';
                errorfound(msgboxText, title);
                set(handles.togglebutton_autonumber,'Enable','on')
                return
        end
        handles.backup_list = backup_list;
        % Update handles structure
        guidata(hObject, handles);
else
        set(handles.listbox_prefix, 'String', handles.backup_list);
end

% -----------------------------------------------------------------------
function edit_prefix_Callback(hObject, eventdata, handles)

% -----------------------------------------------------------------------
function edit_prefix_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -----------------------------------------------------------------------
function listbox_prefix_Callback(hObject, eventdata, handles)
full_list = get(handles.listbox_prefix, 'String');
totline   = length(full_list) ;
currline  = get(handles.listbox_prefix, 'Value');

if currline>=1 && currline<totline
        
        set(handles.edit_prefix,'String',full_list{currline})
        
        % Update handles structure
        guidata(hObject, handles);
end

% -----------------------------------------------------------------------
function listbox_prefix_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

