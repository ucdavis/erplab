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
%                 def = {inp1 erpset isprefix prefixl/ist};

handles.output  = [];
handles.totline = 1;

try
        totalerpset = varargin{1};
catch
        totalerpset = 0;
end
try
        %                        def = {inp1 erpset prefixlist};
        def = varargin{2};
        
catch
        def = {1 [] ''};
end

optioni    = def{1};
erpset     = def{2};
prefixlist = def{3};

handles.optioni     = optioni;
handles.erpset      = erpset;
handles.prefixlist  = prefixlist;
handles.totalerpset = totalerpset;
handles.full_list   = [];
handles.listname    = [];

% set GUI
handles = setbuttonsgui(hObject, eventdata, handles);

version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   APPEND ERPs GUI'])
handles = painterplab(handles);

%
% Set font size
%
handles = setfonterplab(handles);

% help button
helpbutton

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes appenderpGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

% -----------------------------------------------------------------------
function varargout = appenderpGUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

% -----------------------------------------------------------------------
function edit_erpset_Callback(hObject, eventdata, handles)
[chkerp] = checkERPs(hObject, eventdata, handles);
if chkerp
        return % problem was found
else
        set(handles.radiobutton_includep, 'Enable', 'on');
end

% -----------------------------------------------------------------------
function edit_erpset_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -----------------------------------------------------------------------
function pushbutton_RUN_Callback(hObject, eventdata, handles)
% nsets = handles.totalerpset;
if get(handles.radiobutton_erpset, 'Value')
        
        erpset = str2num(char(get(handles.edit_erpset, 'String')));
        
        %         if isempty(erpset)
        %                 msgboxText =  ['No ERPset indices were specified!\n\n'...
        %                         'You must use any integer value(s) between 1 and ' num2str(nsets)];
        %                 title = 'ERPLAB: geterpvaluesGUI inputs';
        %                 errorfound(sprintf(msgboxText), title);
        %                 return
        %         end
        %         if max(erpset)>nsets
        %                 msgboxText =  ['ERPset indexing out of range!\n\n'...
        %                         'You only have ' num2str(nsets) ' ERPsets loaded on your ERPset Menu.'];
        %                 title = 'ERPLAB: geterpvaluesGUI inputs';
        %                 errorfound(sprintf(msgboxText), title);
        %                 return
        %         end
        %         if min(erpset)<1
        %                 msgboxText =  ['Invalid ERPset indexing!\n\n'...
        %                         'You may use any integer value between 1 and ' num2str(nsets)];
        %                 title = 'ERPLAB: geterpvaluesGUI inputs';
        %                 errorfound(sprintf(msgboxText), title);
        %                 return
        %         end
        %
        %         chkerp = checkERPs(hObject, eventdata, handles);
        foption = 0; %from erpsets
else
        erpset = get(handles.listbox_erpnames, 'String');
        nline  = length(erpset);
        
        if nline==1
                msgboxText =  'You have to specify at least one erpset!';
                etitle = 'ERPLAB: geterpvaluesGUI() -> missing input';
                errorfound(msgboxText, etitle);
                return
        end
        
        listname = handles.listname; % file conteining the list of erpsets
        
        if isempty(listname) && nline>1
                BackERPLABcolor = [1 0.9 0.3];    % yellow
                question = ['You have not yet saved your list.\n'...
                        'What would you like to do?'];
                etitle       = 'Save List of ERPsets';
                oldcolor    = get(0,'DefaultUicontrolBackgroundColor');
                set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
                button      = questdlg(sprintf(question), etitle,'Save and Continue','Save As', 'Cancel','Save and Continue');
                set(0,'DefaultUicontrolBackgroundColor',oldcolor)
                
                if strcmpi(button,'Save As')
                        fullname = savelist(hObject, eventdata, handles);
                        listname = fullname;
                        set(handles.edit_filelist,'String', listname);
                        handles.listname = listname;
                        
                        % Update handles structure
                        guidata(hObject, handles);
                        return
                elseif strcmpi(button,'Save and Continue')
                        fulltext = char(get(handles.listbox_erpnames,'String'));
                        listname = char(strtrim(get(handles.edit_filelist,'String')));
                        
                        if isempty(listname)
                                % save as
                                fullname = savelist(hObject, eventdata, handles);
                                listname = fullname;
                                set(handles.edit_filelist,'String', listname);
                        else
                                % just save
                                fid_list = fopen( listname , 'w');
                                for i=1:size(fulltext,1)-1
                                        fprintf(fid_list,'%s\n', fulltext(i,:));
                                end
                                fclose(fid_list);
                        end
                elseif strcmpi(button,'Cancel') || strcmpi(button,'')
                        handles.output   = [];
                        handles.listname = [];
                        
                        % Update handles structure
                        guidata(hObject, handles);
                        return
                end
        end
        erpset  = listname;
        foption = 1; % from list
end
[chkerp ] = checkERPs(hObject, eventdata, handles);
if chkerp
        return
else
        if get(handles.checkbox_useerpname, 'Value')
                prefixArray = 0; % use filenames instead.
        else
                prefixArray = get(handles.listbox_prefix, 'String')';
                %totline = length(prefixArray)-1;
                %         if totline>0 && totline~=length(erpset)
                %                 msgboxText =  'You must enter as many prefixes as erpsets you want to append.';
                %                 title = 'ERPLAB: appenderpGUI few inputs';
                %                 errorfound(msgboxText, title);
                %                 return
                %         end
                prefixArray = prefixArray(1:end-1);
        end
        
        handles.output = {foption, erpset, prefixArray};
        
        % Update handles structure
        guidata(hObject, handles);
        uiresume(handles.gui_chassis);
end

% -----------------------------------------------------------------------
function radiobutton_includep_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.edit_prefix, 'Enable', 'on');
        set(handles.pushbutton_addp, 'Enable', 'on');
        set(handles.pushbutton_deletep, 'Enable', 'on');
        %set(handles.togglebutton_autonumber, 'Enable', 'on');
        set(handles.listbox_prefix, 'Enable', 'on');
        set(handles.pushbutton_cleara, 'Enable', 'on');
        set(handles.pushbutton_doit4me, 'Enable', 'on');
        set(handles.checkbox_useerpname, 'Enable', 'on');
else
        set(handles.edit_prefix, 'Enable', 'off');
        set(handles.pushbutton_addp, 'Enable', 'off');
        set(handles.pushbutton_deletep, 'Enable', 'off');
        set(handles.pushbutton_cleara, 'Enable', 'off');
        set(handles.togglebutton_autonumber, 'Enable', 'off');
        set(handles.listbox_prefix, 'Enable', 'off');
        set(handles.pushbutton_doit4me, 'Enable', 'off');
        set(handles.checkbox_useerpname, 'Value', 0);
        set(handles.checkbox_useerpname, 'Enable', 'off');
end

% -----------------------------------------------------------------------
function pushbutton_addp_Callback(hObject, eventdata, handles)
newline   = get(handles.edit_prefix,'String');
if isempty(strtrim(newline))
        return
end
set(handles.togglebutton_autonumber, 'Value', 0);
set(handles.togglebutton_autonumber, 'Enable', 'on');
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
        if get(handles.radiobutton_erpset,'Value')
                erpset  = str2num(char(get(handles.edit_erpset, 'String')));
                nerpset = length(erpset);
        else
                fulltext = get(handles.listbox_erpnames,'String');
                nerpset  = length(fulltext)-1;
        end
        
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
                etitle = 'ERPLAB: Append ERP GUI automatic prefix numbering';
                errorfound(msgboxText, etitle);
                set(handles.togglebutton_autonumber,'Enable','on')
                set(handles.togglebutton_autonumber,'Enable','on')
                return
        else
                set(handles.togglebutton_autonumber,'Value',0)
                set(handles.togglebutton_autonumber,'Enable','off')
                msgboxText =  ['You have to enter 1 or ' num2str(nerpset) ' to use this button!'];
                etitle = 'ERPLAB: Append ERP GUI automatic prefix numbering';
                errorfound(msgboxText, etitle);
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

% -----------------------------------------------------------------------
function pushbutton_doit4me_Callback(hObject, eventdata, handles)
pushbutton_cleara_Callback(hObject, eventdata, handles)
stringp = 'Group';

for i=1:5
        set(handles. edit_prefix,'String', stringp(1:i))
        pause(0.2)
end

pause(0.5)
set(handles.pushbutton_addp, 'Value', 1)
pushbutton_addp_Callback(hObject, eventdata, handles)
pause(0.5)
set(handles.pushbutton_addp, 'Value', 0)
pause(0.5)
set(handles.togglebutton_autonumber, 'Value', 1)
togglebutton_autonumber_Callback(hObject, eventdata, handles)

% -----------------------------------------------------------------------
function radiobutton_folders_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.radiobutton_erpset,'Value',0)
        set(handles.edit_erpset,'Enable','off')
        set(handles.listbox_erpnames,'Enable','on')
        set(handles.button_adderpset,'Enable','on')
        set(handles.button_delerpset,'Enable','on')
        
        if ~isempty(get(handles.edit_filelist,'String'))
                set(handles.button_savelist,'Enable','on')
                set(handles.button_clearfile,'Enable','on')
        end
        
        set(handles.button_savelistas,'Enable','on')
        set(handles.button_loadlist,'Enable','on')
        set(handles.edit_filelist,'Enable','on')
        set(handles.pushbutton_flush,'Enable','on')
else
        set(hObject,'Value',1)
end

% -----------------------------------------------------------------------
function pushbutton_flush_Callback(hObject, eventdata, handles)
button_clearfile_Callback(hObject, eventdata, handles)
set(handles.listbox_erpnames, 'String', '');
if get(handles.togglebutton_edit_list,'Value') % edit
        set(handles.listbox_erpnames, 'String', 'new erpset');
else
        set(handles.listbox_erpnames, 'String', {'new erpset'});
        set(handles.listbox_erpnames, 'Value', 1);
end
return

% -----------------------------------------------------------------------
function listbox_erpnames_Callback(hObject, eventdata, handles)

% % % fulltext  = get(handles.listbox_erpnames, 'String');
% % % indxline  = length(fulltext);
% % % currlineindx = get(handles.listbox_erpnames, 'Value');
% % %
% % %
% % %
% % %
% % %

% -----------------------------------------------------------------------
function listbox_erpnames_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -----------------------------------------------------------------------
function edit_filelist_Callback(hObject, eventdata, handles)

% -----------------------------------------------------------------------
function edit_filelist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -----------------------------------------------------------------------
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
try
        fid_list = fopen( fullname );
catch
        fprintf('WARNING: %s was not found or is corrupted\n', fullname)
        return
end
formcell = textscan(fid_list, '%[^\n]','CommentStyle','#', 'whitespace', '');
lista    = formcell{:};

% extra line forward
lista   = cat(1, lista, {'new erpset'});
lentext = length(lista);
fclose(fid_list);

if lentext>1
        %         try
        filereadin = strtrim(lista{1});
        ERP1 = load(filereadin, '-mat');
        ERP = ERP1.ERP;
        
        if ~iserpstruct(ERP)
                error('')
        end
        
        set(handles.listbox_erpnames,'String',lista);
        set(handles.edit_filelist,'String',fullname);
        listname = fullname;
        handles.listname = listname;
        set(handles.button_savelistas, 'Enable','on')
        
        set(handles.radiobutton_includep, 'Enable', 'on');
        
        
        % Update handles structure
        guidata(hObject, handles);
        %         catch
        %                 msgboxText =  'This list is anything but an ERPset list!';
        %                 title = 'ERPLAB: geterpvaluesGUI inputs';
        %                 errorfound(msgboxText, title)
        %                 handles.listname = [];
        %                 set(handles.button_savelist, 'Enable','off')
        %
        %                 % Update handles structure
        %                 guidata(hObject, handles);
        %         end
else
        msgboxText =  'This list is empty!';
        etitle = 'ERPLAB: geterpvaluesGUI inputs';
        errorfound(msgboxText, etitle);
        handles.listname = [];
        set(handles.button_savelist, 'Enable','off')
        
        % Update handles structure
        guidata(hObject, handles);
end

% -----------------------------------------------------------------------
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
        etitle = 'ERPLAB: chanoperGUI few inputs';
        errorfound(msgboxText, etitle);
        set(handles.button_savelistas,'Enable','on')
        return
end

% -----------------------------------------------------------------------
function button_adderpset_Callback(hObject, eventdata, handles)
[erpfname, erppathname] = uigetfile({  '*.erp','ERPLAB-files (*.erp)'; ...
        '*.mat','Matlab (*.mat)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Select an edited file', ...
        'MultiSelect', 'on');

if isequal(erpfname,0)
        disp('User selected Cancel')
        return
else
        %       try
        %
        % test current directory
        %
        % changecd(erppathname)
        
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
        
        handles.listname = [];
        indxline         = length(fulltext);
        handles.indxline = indxline;
        handles.fulltext = fulltext;
        set(handles.button_savelistas, 'Enable','on')
        set(handles.edit_filelist,'String','');
        set(handles.radiobutton_includep, 'Enable', 'on');
        
        
        % Update handles structure
        guidata(hObject, handles);
        %       catch
        %             set(handles.listbox_erpnames, 'String', '');
        %             msgboxText =  'A file you are attempting to load is not an ERPset!';
        %             title = 'ERPLAB: geterpvaluesGUI2 inputs';
        %             errorfound(msgboxText, title);
        %             handles.listname = [];
        %             set(handles.button_savelist, 'Enable','off')
        %
        %             % Update handles structure
        %             guidata(hObject, handles);
        %       end
end

% -----------------------------------------------------------------------
function button_clearfile_Callback(hObject, eventdata, handles)
set(handles.edit_filelist,'String','');
set(handles.button_savelist, 'Enable', 'off')
set(handles.radiobutton_includep, 'Enable', 'off');

handles.listname = [];
% Update handles structure
guidata(hObject, handles);

% -----------------------------------------------------------------------
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
        msgboxText =  'You have not specified any ERPset!';
        etitle = 'ERPLAB: averager GUI few inputs';
        errorfound(msgboxText, etitle);
        set(handles.button_savelistas,'Enable','on')
        return
end

% -----------------------------------------------------------------------
function button_delerpset_Callback(hObject, eventdata, handles)
fulltext = get(handles.listbox_erpnames, 'String');
indxline = length(fulltext);
fulltext = char(fulltext); % string matrix
currline = get(handles.listbox_erpnames, 'Value');

if currline>=1 && currline<indxline
        
        fulltext(currline,:) = [];
        fulltext = cellstr(fulltext); % cell string
        
        if length(fulltext)>1 % put this one first on the list
                newline = fulltext{1};
                ERP1    = load(newline, '-mat');
                ERP     = ERP1.ERP;
        end
        
        set(handles.listbox_erpnames, 'String', fulltext);
        listbox_erpnames_Callback(hObject, eventdata, handles)
        handles.fulltext = fulltext;
        indxline = length(fulltext);
        handles.listname = [];
        set(handles.edit_filelist,'String','');
        
        % Update handles structure
        guidata(hObject, handles);
else
        set(handles.button_savelistas, 'Enable','off')
end

% -----------------------------------------------------------------------
function togglebutton_edit_list_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        %list = get(handles.listbox_erpnames, 'String')
        set(handles.listbox_erpnames, 'Value',1)
        set(handles.listbox_erpnames, 'Style','edit')
        set(handles.listbox_erpnames, 'Max',2)
        set(handles.listbox_erpnames, 'HorizontalAlignment','left')
        set(handles.listbox_erpnames, 'Foregroundcolor',[0 0 0.72])
        
        set(handles.button_delerpset,'Enable','off')
        set(handles.button_adderpset,'Enable','off')
        set(handles.button_savelistas,'Enable','off')
        set(handles.button_savelist,'Enable','off')
        set(handles.button_clearfile,'Enable','off')
        set(handles.button_loadlist,'Enable','off')
else
        %list = get(handles.listbox_erpnames, 'String')
        set(handles.listbox_erpnames, 'Style','listbox')
        set(handles.listbox_erpnames, 'Value',1)
        set(handles.listbox_erpnames, 'Foregroundcolor',[0 0 0])
        set(handles.button_delerpset,'Enable','on')
        set(handles.button_adderpset,'Enable','on')
        set(handles.button_savelistas,'Enable','on')
        set(handles.button_savelist,'Enable','on')
        set(handles.button_clearfile,'Enable','on')
        set(handles.button_loadlist,'Enable','on')
end

% -----------------------------------------------------------------------
function radiobutton_erpset_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.edit_erpset,'Enable','on')
        set(handles.radiobutton_folders,'Value',0)
        set(handles.listbox_erpnames,'Enable','off')
        set(handles.button_adderpset,'Enable','off')
        set(handles.button_delerpset,'Enable','off')
        set(handles.button_savelist,'Enable','off')
        set(handles.button_clearfile,'Enable','off')
        set(handles.button_savelistas,'Enable','off')
        set(handles.button_loadlist,'Enable','off')
        set(handles.edit_filelist,'Enable','off')
        set(handles.pushbutton_flush,'Enable','off')
else
        set(hObject,'Value',1)
end

%--------------------------------------------------------------------------
function [chkerp ]= checkERPs(hObject, eventdata, handles)
chkerp   = 0; % no problem
errorerp = 0;
nerp     = handles.totalerpset;

%
% Read first ERPset
%
if get(handles.radiobutton_erpset, 'Value')==1;
        indexerp = unique_bc2(str2num(get(handles.edit_erpset, 'String')));
        
        if isempty(indexerp)
                msgboxText =  ['Invalid ERPset indexing!\n\n'...
                        'You must use any integer value between 1 and %g.'];
                etitle = 'ERPLAB: appenderpGUI inputs';
                errorfound(sprintf(msgboxText, num2str(nerp)), etitle);
                chkerp  = 1;
                return
        end
        if max(indexerp)>nerp
                msgboxText =  ['ERPset indexing out of range!\n\n'...
                        'You only have %g ERPsets loaded on your ERPset Menu.'];
                etitle = 'ERPLAB: appenderpGUI inputs';
                errorfound(sprintf(msgboxText, num2str(nerp)), etitle);
                chkerp  = 1;
                return
        end
        if min(indexerp)<1
                msgboxText =  ['Invalid ERPset indexing!\n\n'...
                        'You must use any integer value between 1 and %g' ];
                etitle = 'ERPLAB: appenderpGUI inputs';
                errorfound(sprintf(msgboxText, num2str(nerp)), etitle);
                chkerp  = 1;
                return
        end
        if length(indexerp)<2
                msgboxText =  'You have to specify 2 erpsets, at least!';
                title = 'ERPLAB: appenderpGUI() -> few inputs';
                errorfound(msgboxText, title);
                chkerp  = 1;
                return
        end
        
        ALLERP = evalin('base', 'ALLERP');
        
        if ~isempty(ALLERP)
                nerp2 = length(indexerp);
                numpoints = zeros(1,nerp2);
                numchans  = zeros(1,nerp2);
                nameerp = {''};
                for k=1:nerp2
                        numpoints(k) = ALLERP(indexerp(k)).pnts;
                        numchans(k)  = ALLERP(indexerp(k)).nchan;
                        nameerp{k}   = ALLERP(indexerp(k)).filename;
                end
        else
                chkerp  = 1;
                return
        end
        clear ALLERP
else
        listname = strtrim(char(get(handles.edit_filelist,'String')));
        
        %
        % open file containing the erp list
        %
        fid_list = fopen( listname );
        formcell = textscan(fid_list, '%[^\n]','CommentStyle','#', 'whitespace', '');
        lista    = formcell{:};
        
        % extra line forward
        lista    = cat(1, lista, {'new erpset'});
        lentext  = length(lista);
        fclose(fid_list);
        
        if lentext>1
                numpoints = zeros(1,lentext-1);
                numchans  = zeros(1,lentext-1);
                nameerp   = {''};
                for j=1:lentext-1
                        ERP1 = load(strtrim(lista{j}), '-mat');
                        ERP  = ERP1.ERP;
                        if ~iserpstruct(ERP)
                                %set(handles.listbox_erpnames, 'String', '');
                                msgboxText =  'A file you are attempting to load is not an ERPset!';
                                etitle = 'ERPLAB: appenderpGUI inputs';
                                errorfound(msgboxText, etitle);
                                handles.listname = [];
                                
                                % Update handles structure
                                guidata(hObject, handles);
                                errorerp = 1;
                                set(handles.button_savelist, 'Enable','off')
                                break
                        else
                                numpoints(j) = ERP.pnts;
                                numchans(j)  = ERP.nchan;
                                nameerp{j}   = ERP.filename;
                        end
                        
                        clear ERP1 ERP
                end
                if errorerp
                        chkerp  = 1;
                        return
                end
        end
        nerp2      = lentext-1;
        handles.listname = listname;
        % Update handles structure
        guidata(hObject, handles);
end
if length(unique_bc2(numpoints))>1
        fprintf('Detail:\n')
        fprintf('-------\n')
        for j=1:nerp2
                fprintf('Erpset %s has %g points per bin\n', nameerp{j}, numpoints(j));
        end
        msgboxText = 'ERPsets have different number of points\n';
        etitle = 'ERPLAB: appenderpGUI inputs';
        errorfound(sprintf(msgboxText), etitle);
        chkerp  = 1;
        return
end
if length(unique_bc2(numchans))>1
        fprintf('Detail:\n')
        fprintf('-------\n')
        for j=1:nerp2
                fprintf('Erpset %s has %g channels\n', nameerp{j}, numchans(j));
        end
        msgboxText = 'ERPsets have different number of channel\n';
        etitle = 'ERPLAB: appenderpGUI inputs';
        errorfound(sprintf(msgboxText), etitle);
        chkerp  = 1;
        return
end

% -----------------------------------------------------------------------
function handles = setbuttonsgui(hObject, eventdata, handles)
optioni    = handles.optioni;
erpset     = handles.erpset;
prefixlist = handles.prefixlist;
nsets      = handles.totalerpset;

if nsets>0 && optioni==0 %&& isnumeric(erpset)   % from erpset menu
        set(handles.radiobutton_erpset, 'Value', 1);
        set(handles.radiobutton_erpset, 'Enable', 'on');
        set(handles.radiobutton_folders, 'Value', 0);
        set(handles.listbox_erpnames, 'Enable', 'off');
        set(handles.button_adderpset, 'Enable', 'off');
        set(handles.button_delerpset, 'Enable', 'off');
        set(handles.button_savelistas, 'Enable', 'off');
        set(handles.button_savelist, 'Enable', 'off');
        set(handles.button_clearfile, 'Enable', 'off');
        set(handles.button_loadlist, 'Enable', 'off');
        set(handles.edit_erpset, 'String', vect2colon(erpset, 'Delimiter','off', 'Repeat', 'off'));
        set(handles.listbox_erpnames, 'String', {'new erpset'});
        set(handles.edit_filelist,'String', '')
        set(handles.pushbutton_flush,'Enable','off')
        set(handles.radiobutton_includep, 'Enable', 'on');
else % from hard drive
        set(handles.radiobutton_folders, 'Value', 1);
        set(handles.radiobutton_erpset, 'Value', 0);
        set(handles.edit_erpset, 'Enable', 'off');
        set(handles.pushbutton_flush,'Enable','on')
        set(handles.radiobutton_includep, 'Value', 0);
        
        if nsets==0
                set(handles.radiobutton_erpset, 'Enable', 'off');
                set(handles.edit_erpset, 'String', 'no erpset');
        else
                set(handles.edit_erpset, 'String', vect2colon(1:nsets, 'Delimiter','off', 'Repeat', 'off'));
        end
        if ~isempty(erpset) && ischar(erpset)
                
                %
                % open file containing the erp list
                %
                try
                        fid_list = fopen( erpset );
                catch
                        fprintf('WARNING: %s was not found or is corrupted\n', fullname)
                        return
                end
                formcell = textscan(fid_list, '%[^\n]','CommentStyle','#', 'whitespace', '');
                fclose(fid_list);
                
                lista = formcell{:};
                listname = erpset;
                set(handles.radiobutton_includep, 'Enable', 'on');
                set(handles.edit_filelist,'String', erpset)
        else
                lista    = {};
                listname = [];
                set(handles.radiobutton_includep, 'Enable', 'off');
        end
        
        % extra line forward
        lista   = cat(1, lista, {'new erpset'});
        %lentext = length(lista);
        
        handles.listname = listname;
        set(handles.button_savelistas, 'Enable','on')        
        set(handles.listbox_erpnames,'String',lista);
end
if isempty(prefixlist)
        set(handles.radiobutton_includep, 'Value', 0);
        set(handles.edit_prefix, 'Enable', 'off');
        set(handles.pushbutton_addp, 'Enable', 'off');
        set(handles.pushbutton_deletep, 'Enable', 'off');
        set(handles.pushbutton_cleara, 'Enable', 'off');
        set(handles.togglebutton_autonumber, 'Enable', 'off');
        set(handles.listbox_prefix, 'Enable', 'off');
        set(handles.listbox_prefix, 'String', {'new prefix'});
        set(handles.pushbutton_doit4me, 'Enable', 'off');
        set(handles.checkbox_useerpname, 'Enable', 'off');
elseif iscell(prefixlist)
        set(handles.radiobutton_includep, 'Value', 1);
        set(handles.edit_prefix, 'Enable', 'on');
        set(handles.pushbutton_addp, 'Enable', 'on');
        set(handles.pushbutton_deletep, 'Enable', 'on');
        set(handles.pushbutton_cleara, 'Enable', 'on');
        set(handles.togglebutton_autonumber, 'Enable', 'on');
        set(handles.listbox_prefix, 'Enable', 'on');
        set(handles.listbox_prefix, 'String', {prefixlist{:} 'new prefix'});
        set(handles.pushbutton_doit4me, 'Enable', 'on');
        set(handles.checkbox_useerpname, 'Enable', 'on');
else
        set(handles.radiobutton_includep, 'Value', 1);
        set(handles.edit_prefix, 'Enable', 'off');
        set(handles.pushbutton_addp, 'Enable', 'off');
        set(handles.pushbutton_deletep, 'Enable', 'off');
        set(handles.pushbutton_cleara, 'Enable', 'off');
        set(handles.togglebutton_autonumber, 'Enable', 'off');
        set(handles.listbox_prefix, 'Enable', 'off');
        set(handles.listbox_prefix, 'String', {'new prefix'});
        set(handles.pushbutton_doit4me, 'Enable', 'off');
        set(handles.checkbox_useerpname, 'Enable', 'on');
        set(handles.checkbox_useerpname, 'Value', 1);
end

%         set(handles.radiobutton_erpset, 'Value', 1);

%--------------------------------------------------------------------------
function fullname = savelist(hObject, eventdata, handles)
fullname = '';
fulltext = char(get(handles.listbox_erpnames,'String'));

%
% Save OUTPUT file
%
[filename, filepath, filterindex] = uiputfile({'*.txt';'*.dat';'*.*'},'Save erpset list as');

if isequal(filename,0)
        disp('User selected Cancel')
        return
else        
        [px, fname, ext] = fileparts(filename);
        
        if strcmp(ext,'')
                if filterindex==1 || filterindex==3
                        ext   = '.txt';
                else
                        ext   = '.dat';
                end
        end
        
        fname = [ fname ext];
        fullname = fullfile(filepath, fname);
        disp(['To Save erpset list, user selected ', fullname])
        
        fid_list   = fopen( fullname , 'w');
        
        for i=1:size(fulltext,1)-1
                fprintf(fid_list,'%s\n', fulltext(i,:));
        end        
        fclose(fid_list);
end

% -----------------------------------------------------------------------
function checkbox_useerpname_Callback(hObject, eventdata, handles)
if ~get(hObject,'Value')
        set(handles.edit_prefix, 'Enable', 'on');
        set(handles.pushbutton_addp, 'Enable', 'on');
        set(handles.pushbutton_deletep, 'Enable', 'on');
        %set(handles.togglebutton_autonumber, 'Enable', 'on');
        set(handles.listbox_prefix, 'Enable', 'on');
        set(handles.pushbutton_cleara, 'Enable', 'on');
        set(handles.pushbutton_doit4me, 'Enable', 'on');
else
        set(handles.edit_prefix, 'Enable', 'off');
        set(handles.pushbutton_addp, 'Enable', 'off');
        set(handles.pushbutton_deletep, 'Enable', 'off');
        set(handles.pushbutton_cleara, 'Enable', 'off');
        set(handles.togglebutton_autonumber, 'Enable', 'off');
        set(handles.listbox_prefix, 'Enable', 'off');
        set(handles.pushbutton_doit4me, 'Enable', 'off');
end

% if get(hObject, 'Value')
%         set(handles.radiobutton_includep, 'Value', 1)
% else
%         set(handles.radiobutton_includep, 'Value', 0)
% end


% -----------------------------------------------------------------------
function pushbutton_help_Callback(hObject, eventdata, handles)
web https://github.com/lucklab/erplab/wiki/Appending-ERPSETS -browser

% -----------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

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
