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

function varargout = grandaveragerGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @grandaveragerGUI_OpeningFcn, ...
        'gui_OutputFcn',  @grandaveragerGUI_OutputFcn, ...
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
function grandaveragerGUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for grandaveragerGUI
handles.output = [];
handles.indxline = 1;

try
        ALLERP = varargin{1}; %evalin('base', 'ALLERP');
catch
        ALLERP = [];
end

handles.fulltext = [];
set(handles.listbox_erpnames, 'String', {'new erpset'});

nsets  = length(ALLERP);
handles.nsets = nsets;
handles.listname = [];

% Update handles structure
guidata(hObject, handles);

label1 = '<HTML><center>Use weighted average';
label2 = '<HTML><center>based on number of trials';
set(handles.checkbox_wavg, 'string',[label1 '<br>' label2]);
set(handles.checkbox_wavg, 'Value', 1);

%
% Name & version
%
version = geterplabversion;
set(handles.figure1,'Name', ['ERPLAB ' version '   -   GRAND AVERAGER GUI'])

if nsets>0 % from erpsets menu
        set(handles.radiobutton_erpset, 'Value', 1);
        set(handles.radiobutton_erpset, 'Enable', 'on');
        set(handles.edit_erpset, 'String', num2str(1:nsets));
        set(handles.radiobutton_folders, 'Value', 0);
        set(handles.listbox_erpnames, 'Enable', 'off');
        set(handles.pushbutton_adderpset, 'Enable', 'off');
        set(handles.pushbutton_delerpset, 'Enable', 'off'); 
        set(handles.button_loadlist, 'Enable', 'off');
        set(handles.button_savelist, 'Enable', 'off');
        set(handles.button_savelistas, 'Enable', 'off');
        set(handles.button_clearfile, 'Enable', 'off');
else  % from files
        set(handles.edit_erpset, 'String', 'no erpset');
        set(handles.edit_erpset, 'Enable', 'off');
        set(handles.radiobutton_erpset, 'Value', 0);
        set(handles.radiobutton_erpset, 'Enable', 'off');
        set(handles.radiobutton_folders, 'Value', 1);
end

set(handles.button_savelist, 'Enable', 'off');

%
% Color GUI
%
handles = painterplab(handles);

% UIWAIT makes grandaveragerGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);

%--------------------------------------------------------------------------
function varargout = grandaveragerGUI_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);
pause(0.5)

%--------------------------------------------------------------------------
function edit_erpset_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_erpset_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_GO_Callback(hObject, eventdata, handles)

wavg  = get(handles.checkbox_wavg,'Value');% for weighted average    1=>yes
stdev = get(handles.checkbox_STD,'Value'); % for standard deviation  1=>yes

if get(handles.radiobutton_erpset, 'Value')
        erpset = str2num(char(get(handles.edit_erpset, 'String')));
        
        if length(erpset)<2
                msgboxText =  'You have to specify 2 erpsets, at least!';
                title = 'ERPLAB: geterpvaluesGUI() -> missing input';
                errorfound(msgboxText, title);
                return
        end
        if min(erpset)<1 || max(erpset)>handles.nsets
                msgboxText =  'Unexisting erpset index(es)';
                title = 'ERPLAB: grandaveragerGUI() -> wrong input';
                errorfound(msgboxText, title);
                return
        else
                handles.output = {0, erpset, wavg, stdev};
        end
else
        erpset = cellstr(get(handles.listbox_erpnames, 'String'));
        nline  = length(erpset);
        
        if nline<3 % 'new_erpset' line is being included
                msgboxText =  'You have to specify 2 erpsets, at least!';
                title = 'ERPLAB: geterpvaluesGUI() -> missing input';
                errorfound(msgboxText, title);
                return
        end
        
        listname = handles.listname;
        
        if isempty(listname) && nline>1
                
                BackERPLABcolor = [1 0.9 0.3];    % yellow
                question{1} = 'You have not saved your list.';
                question{2} = 'What would you like to do?';
                title = 'Save List of ERPsets';
                oldcolor = get(0,'DefaultUicontrolBackgroundColor');
                set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
                button = questdlg(question, title,'Save and Continue','Save As', 'Cancel','Save and Continue');
                set(0,'DefaultUicontrolBackgroundColor',oldcolor)
                
                if strcmpi(button,'Save As')
                        fullname = savelist(hObject, eventdata, handles);
                        listname = fullname;
                        
                        if isempty(listname)
                                return
                        end
                elseif strcmpi(button,'Save and Continue')
                        
                        fulltext = char(get(handles.listbox_erpnames,'String'));
                        listname = char(strtrim(get(handles.edit_filelist,'String')));
                        
                        if isempty(listname)
                                fullname = savelist(hObject, eventdata, handles);
                                listname = fullname;
                                if isempty(listname)
                                        return
                                end
                        else
                                fid_list = fopen( listname , 'w');
                                for i=1:size(fulltext,1)-1
                                        fprintf(fid_list,'%s\n', fulltext(i,:));
                                end
                                fclose(fid_list);
                        end
                        
                elseif strcmpi(button,'Cancel') || strcmpi(button,'')
                        handles.output = [];
                        handles.listname = [];
                        % Update handles structure
                        guidata(hObject, handles);
                        return
                end
        end
        
        handles.output = {1, listname, wavg, stdev};
end

% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);

%--------------------------------------------------------------------------
function figure1_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
        %The GUI is still in UIWAIT, us UIRESUME
        handles.output = [];
        %Update handles structure
        guidata(hObject, handles);
        uiresume(handles.figure1);
else
        % The GUI is no longer waiting, just close it
        delete(handles.figure1);
end

%--------------------------------------------------------------------------
function radiobutton_folders_Callback(hObject, eventdata, handles)

if get(hObject, 'Value')
        set(handles.radiobutton_folders, 'Value', 1);
        set(handles.radiobutton_folders, 'Enable', 'on');
        set(handles.listbox_erpnames, 'Enable', 'on');
        set(handles.pushbutton_adderpset, 'Enable', 'on');
        set(handles.pushbutton_delerpset, 'Enable', 'on');
        set(handles.button_loadlist, 'Enable', 'on');
        set(handles.button_savelist, 'Enable', 'on');
        set(handles.button_savelistas, 'Enable', 'on');
        set(handles.button_clearfile, 'Enable', 'on');
        set(handles.radiobutton_erpset, 'Value', 0);
        
        if handles.nsets==0
                set(handles.radiobutton_erpset, 'Enable', 'off');
        end
        
        set(handles.edit_erpset, 'Enable', 'off');
        set(handles.edit_erpset, 'String', '');
else
        set(handles.radiobutton_folders, 'Value', 1);
end

%--------------------------------------------------------------------------
function radiobutton_erpset_Callback(hObject, eventdata, handles)

if get(hObject, 'Value')
        nsets = handles.nsets;
        set(handles.radiobutton_erpset, 'Value', 1);
        set(handles.radiobutton_erpset, 'Enable', 'on');
        set(handles.edit_erpset, 'Enable', 'on');
        set(handles.edit_erpset, 'String', num2str(1:nsets));
        set(handles.radiobutton_folders, 'Value', 0);
        set(handles.listbox_erpnames, 'Enable', 'off');
        set(handles.pushbutton_adderpset, 'Enable', 'off');
        set(handles.pushbutton_delerpset, 'Enable', 'off');
        set(handles.button_loadlist, 'Enable', 'off');
        set(handles.button_savelist, 'Enable', 'off');
        set(handles.button_savelistas, 'Enable', 'off');
        set(handles.button_clearfile, 'Enable', 'off');
else
        set(handles.radiobutton_erpset, 'Value', 1);
end

%--------------------------------------------------------------------------
function listbox_erpnames_Callback(hObject, eventdata, handles)

fulltext  = get(handles.listbox_erpnames, 'String');
indxline  = length(fulltext);

currlineindx = get(handles.listbox_erpnames, 'Value');

%--------------------------------------------------------------------------
function listbox_erpnames_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_adderpset_Callback(hObject, eventdata, handles)

[erpfname, erppathname] = uigetfile({  '*.erp','ERPLAB-files (*.erp)'; ...
        '*.mat','Matlab (*.mat)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Select an edited file', ...
        'MultiSelect', 'on');

if isequal(erpfname,0)
        disp('User selected Cancel')
        return
else
        if ~iscell(erpfname)
                erpfname = {erpfname};
        end
        
        nerpn = length(erpfname);
        
        for i=1:nerpn
                newline  = fullfile(erppathname, erpfname{i});
                currline = get(handles.listbox_erpnames, 'Value');
                fulltext = get(handles.listbox_erpnames, 'String');
                indxline = length(fulltext);
                
                if currline==indxline
                        % extra line forward
                        fulltext  = cat(1, fulltext, {'new erpset'});
                        set(handles.listbox_erpnames, 'Value', currline+1)
                else
                        set(handles.listbox_erpnames, 'Value', currline)
                        resto = fulltext(currline:indxline);
                        fulltext  = cat(1, fulltext, {'new erpset'});
                        set(handles.listbox_erpnames, 'Value', currline+1)
                        [fulltext{currline+1:indxline+1}] = resto{:};
                end
                
                fulltext{currline} = newline;
                set(handles.listbox_erpnames, 'String', fulltext)
        end
        
        indxline = length(fulltext);
        handles.indxline = indxline;
        handles.fulltext = fulltext;
        handles.listname = [];
        set(handles.edit_filelist,'String','');
        % Update handles structure
        guidata(hObject, handles);
        
end

%--------------------------------------------------------------------------
function pushbutton_delerpset_Callback(hObject, eventdata, handles)

fulltext = get(handles.listbox_erpnames, 'String');
indxline = length(fulltext);

fulltext = char(fulltext); % string matrix
currline = get(handles.listbox_erpnames, 'Value');

if currline>=1 && currline<indxline
        
        fulltext(currline,:) = [];
        fulltext = cellstr(fulltext); % cell string
        
        set(handles.listbox_erpnames, 'String', fulltext);
        listbox_erpnames_Callback(hObject, eventdata, handles)
        
        handles.fulltext = fulltext;
        indxline = length(fulltext);
        handles.listname = [];
        set(handles.edit_filelist,'String','');
        
        % Update handles structure
        guidata(hObject, handles);
end

%--------------------------------------------------------------------------
function checkbox_wavg_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)

handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);

%--------------------------------------------------------------------------
function button_loadlist_Callback(hObject, eventdata, handles)

[listname, lispath] = uigetfile({  '*.txt','Text File (*.txt)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Select an edited list', ...
        'MultiSelect', 'off');

if isequal(listname,0)
        disp('User selected Cancel')
        return
else
        fullname = fullfile(lispath, listname);
        disp(['For erpset list user selected  <a href="matlab: open(''' fullname ''')">' fullname '</a>'])
end

fid_list   = fopen( fullname );
formcell = textscan(fid_list, '%[^\n]','CommentStyle','#', 'whitespace', '');
lista = formcell{:};

% extra line forward
lista  = cat(1, lista, {'new erpset'});
lentext   = length(lista);
fclose(fid_list);

if lentext>1
        set(handles.listbox_erpnames,'String',lista);
        set(handles.edit_filelist,'String',fullname);
        handles.listname = fullname;
        set(handles.button_savelist, 'Enable','on')
        
        % Update handles structure
        guidata(hObject, handles);
else
        msgboxText =  'This list is empty!';
        title = 'ERPLAB: geterpvaluesGUI inputs';
        errorfound(msgboxText, title);
        handles.listname = [];
        set(handles.button_savelist, 'Enable','off')
        
        % Update handles structure
        guidata(hObject, handles);
end

set(handles.listbox_erpnames,'String',lista);

%--------------------------------------------------------------------------
function button_savelistas_Callback(hObject, eventdata, handles)

fulltext = char(get(handles.listbox_erpnames,'String'));

if length(fulltext)>1
        
        fullname = savelist(hObject, eventdata, handles);
        
        if isempty(fullname)
                return
        end
        
        set(handles.edit_filelist, 'String', fullname )
        set(handles.button_savelist, 'Enable', 'on')
        
        handles.listname = fullname;
        % Update handles structure
        guidata(hObject, handles);
else
        set(handles.button_savelistas,'Enable','off')
        msgboxText =  'You have not specified any erpset!';
        title = 'ERPLAB: averager GUI few inputs';
        errorfound(msgboxText, title);
        set(handles.button_savelistas,'Enable','on')
        return
end

%--------------------------------------------------------------------------
function fullname = savelist(hObject, eventdata, handles)

fulltext  = char(strtrim(get(handles.listbox_erpnames,'String')));
pre_fname = char(strtrim(get(handles.edit_filelist,'String')));

%
% Save OUTPUT file
%
[filename, filepath, filterindex] = uiputfile({'*.txt';'*.dat';'*.*'},'Save erpset list as', pre_fname);

if isequal(filename,0)
        disp('User selected Cancel')
        fullname =[];
        return
else
        
        [px, fname, ext, versn] = fileparts(filename);
        
        if strcmp(ext,'')
                
                if filterindex==1 || filterindex==3
                        ext   = '.txt';
                else
                        ext   = '.dat';
                end
        end
        
        fname = [ fname ext];
        fullname = fullfile(filepath, fname);
        disp(['For saving erpset list, user selected <a href="matlab: open(''' fullname ''')">' fullname '</a>'])
        
        fid_list   = fopen( fullname , 'w');
        
        for i=1:size(fulltext,1)-1
                fprintf(fid_list,'%s\n', fulltext(i,:));
        end
        
        fclose(fid_list);
end

%--------------------------------------------------------------------------
function button_savelist_Callback(hObject, eventdata, handles)

fulltext = char(strtrim(get(handles.listbox_erpnames,'String')));

if length(fulltext)>1
        
        fullname = get(handles.edit_filelist, 'String');
        
        if ~strcmp(fullname,'')
                
                fid_list   = fopen( fullname , 'w');
                
                for i=1:size(fulltext,1)
                        fprintf(fid_list,'%s\n', fulltext(i,:));
                end
                
                fclose(fid_list);
                handles.listname = fullname;
                
                % Update handles structure
                guidata(hObject, handles);
                disp(['Saving equation list at <a href="matlab: open(''' fullname ''')">' fullname '</a>'])
        else
                button_savelistas_Callback(hObject, eventdata, handles)
                return
        end
else
        set(handles.button_savelistas,'Enable','off')
        msgboxText =  'You have not written any formula yet!';
        title = 'ERPLAB: chanoperGUI few inputs';
        errorfound(msgboxText, title);
        set(handles.button_savelistas,'Enable','on')
        return
end

%--------------------------------------------------------------------------
function button_clearfile_Callback(hObject, eventdata, handles)

set(handles.edit_filelist,'String','');
set(handles.button_savelist, 'Enable', 'off')
handles.listname = [];
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function edit_filelist_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_filelist_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_STD.
function checkbox_STD_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_STD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_STD
