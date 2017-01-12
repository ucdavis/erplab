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

function varargout = assigncodesGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @assigncodesGUI_OpeningFcn, ...
        'gui_OutputFcn',  @assigncodesGUI_OutputFcn, ...
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
function assigncodesGUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output   = [];
handles.indxline = 1;
handles.fulltext = {};
handles.lastlineclicked = {};
handles.listname = [];
handles.owfp     = 0;  % over write file permission

try
        def = erpworkingmemory('assigncodesGUI'); %varargin{1};
catch
        def = [];
end
if isempty(def)
        def = {'' '' 1 'boundary' -99 2 1 1};
end

editlistname       = def{1};
newelname          = def{2};
updateEEG          = def{3};
boundarystrcode    = def{4};
newboundarynumcode = def{5};
option2do          = def{6};
iswarning          = def{7};
alphanum           = def{8};

if isempty(editlistname)
        set(handles.pushbutton_savelist,'Enable', 'off')
end
set(handles.edit_elname, 'String', newelname)
if isempty(newelname)
        set(handles.edit_elname, 'Enable', 'off');
        set(handles.radiobutton_totext, 'Value', 0);
end

set(handles.checkbox_update_EEG, 'Value', updateEEG)

if iscell(boundarystrcode)
    if isempty(boundarystrcode)
        boundarystrcode = ''; % bug fixed. Javier. 01/19/2015
    else
        boundarystrcode = boundarystrcode{1};
    end
end
if iscell(newboundarynumcode)
    if isempty(newboundarynumcode)
        newboundarynumcode = []; % bug fixed. Javier. 01/19/2015
    else
        newboundarynumcode = newboundarynumcode{1};
    end
end
if strcmpi(boundarystrcode, 'boundary') && newboundarynumcode==-99
        set(handles.checkbox_addm99code,'Value', 1)
        set(handles.edit_boundarycode,'Enable', 'off');
        set(handles.edit_numericode,'Enable', 'off');
elseif ~isempty(boundarystrcode)
        set(handles.edit_boundarycode, 'String', boundarystrcode)
        set(handles.edit_numericode, 'String', num2str(newboundarynumcode))
        set(handles.checkbox_convert_b,'Value', 1)
else
        set(handles.edit_boundarycode,'Enable', 'off');
        set(handles.edit_numericode,'Enable', 'off');
end

%
% What to do with the EVENTLIST?
if     option2do == 7;  % do all
        set(handles.radiobutton_tocurrentdata,'Value',1);
        set(handles.checkbox_toworkspace,'Value',1);
        set(handles.radiobutton_totext,'Value',1);
elseif option2do == 6;  % workspace & current data
        set(handles.radiobutton_tocurrentdata,'Value',1);
        set(handles.checkbox_toworkspace,'Value',1);
        set(handles.radiobutton_totext,'Value',0);
        set(handles.pushbutton_browse, 'Enable', 'off');
elseif option2do == 5;  %  workspace & text
        set(handles.radiobutton_tocurrentdata,'Value',0);
        set(handles.checkbox_toworkspace,'Value',1);
        set(handles.radiobutton_totext,'Value',1);
elseif option2do == 4;  %  workspace only
        set(handles.radiobutton_tocurrentdata,'Value',0);
        set(handles.checkbox_toworkspace,'Value',1);
        set(handles.radiobutton_totext,'Value',0);
        set(handles.pushbutton_browse, 'Enable', 'off');
elseif option2do == 3;  %  current data & text
        set(handles.radiobutton_tocurrentdata,'Value',1);
        set(handles.checkbox_toworkspace,'Value',0);
        set(handles.radiobutton_totext,'Value',1);
elseif option2do == 2;  % current data only
        set(handles.radiobutton_tocurrentdata,'Value',1);
        set(handles.checkbox_toworkspace,'Value',0);
        set(handles.radiobutton_totext,'Value',0);
        set(handles.pushbutton_browse, 'Enable', 'off');
elseif option2do == 1;  % text only
        set(handles.radiobutton_tocurrentdata,'Value',0);
        set(handles.checkbox_toworkspace,'Value',0);
        set(handles.radiobutton_totext,'Value',1);
else
        set(handles.radiobutton_tocurrentdata,'Value',1);
        set(handles.pushbutton_browse, 'Enable', 'off');
end

set(handles.ELwarning,'Value', iswarning);
set(handles.checkbox_alphanum, 'Value', alphanum); % for letterkilla. Oct 10, 2012

% set(handles.edit_elname, 'BackgroundColor', [0.83 0.82 0.78]);

set(handles.listbox_lines, 'String', {'new line'});
set(handles.edit_numeric_type, 'string','')
set(handles.edit_event_label, 'string','')
set(handles.edit_binindex, 'string','')
set(handles.edit_bindescription, 'string','')
set(handles.pushbutton_update,'Enable', 'off');

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   CREATE ADVANCED EVENTLIST GUI'])

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

if ~isempty(editlistname)
        try
                set(handles.edit_filelist,'String', editlistname)
                pushbutton_openlist_Callback(hObject, eventdata, handles, char(editlistname))
        catch
                set(handles.edit_filelist,'String', '')
        end
end

% help
helpbutton

% UIWAIT makes assigncodesGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

%--------------------------------------------------------------------------
function varargout = assigncodesGUI_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

%--------------------------------------------------------------------------
function listbox_lines_Callback(hObject, eventdata, handles)

set(handles.pushbutton_update,'Enable', 'on');
lastlineclicked = handles.lastlineclicked;

if ~isempty(lastlineclicked)
        numco = strtrim(get(handles.edit_numeric_type, 'String'));
        strco = strtrim(get(handles.edit_event_label, 'String'));
        bindx = strtrim(get(handles.edit_binindex, 'String'));
        %if isempty(bindx)
        %      bindx = '[]';
        %end
        bdesc = strtrim(get(handles.edit_bindescription, 'String'));
        %if isempty(bdesc)
        %      bdesc = '""';
        %end
        
        cmatch1 = strcmpi(lastlineclicked{1}, numco);
        cmatch2 = strcmpi(lastlineclicked{2}, strco);
        cmatch3 = strcmpi(lastlineclicked{3}, bindx);
        cmatch4 = strcmpi(lastlineclicked{4}, bdesc);
        condi   = cmatch1 && cmatch2 && cmatch3 && cmatch4;
else
        condi =1;
end
if condi
        fulltext  = get(handles.listbox_lines, 'String');
        indxline  = length(fulltext);
        
        if indxline>=1                
                currlineindx = get(handles.listbox_lines, 'Value');                
                if length(currlineindx)>1
                        set(handles.pushbutton_update, 'Enable','off');
                        set(handles.edit_numeric_type, 'Enable','off');
                        set(handles.edit_event_label, 'Enable','off');
                        set(handles.edit_binindex, 'Enable','off');
                        set(handles.edit_bindescription, 'Enable','off');
                else
                        set(handles.pushbutton_update, 'Enable','on');
                        set(handles.edit_numeric_type, 'Enable','on');
                        set(handles.edit_event_label, 'Enable','on');
                        set(handles.edit_binindex, 'Enable','on');
                        set(handles.edit_bindescription, 'Enable','on');
                end
                
                currlinestr  = fulltext{currlineindx};
                [strmat strtok] = regexp(currlinestr, '([-+]*\d+)\s*"(.*)"\s*(\d+|[[]]+)\s*"(.*)"', 'match', 'tokens');
                
                if ~isempty(strmat)
                        numco = strtok{1}{1};
                        strco = strtok{1}{2};
                        bindx = strtok{1}{3};
                        
                        if strcmp(bindx,'[]')
                                bindx = '';
                        end
                        
                        bdesc = strtok{1}{4};
                        set(handles.edit_numeric_type, 'ForegroundColor', [0 0 0]);
                        set(handles.edit_event_label, 'ForegroundColor', [0 0 0]);
                        set(handles.edit_binindex, 'ForegroundColor', [0 0 0]);
                        set(handles.edit_bindescription, 'ForegroundColor', [0 0 0]);
                        set(handles.edit_numeric_type, 'String', numco);
                        set(handles.edit_event_label, 'String', strco);
                        set(handles.edit_binindex, 'String', bindx);
                        set(handles.edit_bindescription, 'String', bdesc);
                        handles.lastlineclicked = {numco strco bindx bdesc currlineindx};
                        
                        % Update handles structure
                        guidata(hObject, handles);
                else
                        set(handles.edit_numeric_type, 'ForegroundColor', [0.7 0.7 0.7]);
                        set(handles.edit_event_label, 'ForegroundColor', [0.7 0.7 0.7]);
                        set(handles.edit_binindex, 'ForegroundColor', [0.7 0.7 0.7]);
                        set(handles.edit_bindescription, 'ForegroundColor', [0.7 0.7 0.7]);
                end
        end
else
        set(handles.listbox_lines, 'Enable', 'off');
        question =  sprintf('You modified the line # %g, but you did not update it!\n',lastlineclicked{5});
        title   = 'ERPLAB: update last line?';
        buttonames = {'Go back & update', 'Continue & do not update'};
        button     = askquestpoly(question, title, {'Go back & update', 'Continue & do not update'});
        
        if strcmpi(button, buttonames{2})
                handles.lastlineclicked = {};
                set(handles.listbox_lines, 'Value', get(handles.listbox_lines, 'Value'));
                set(handles.listbox_lines, 'Enable', 'on');
                listbox_lines_Callback(hObject, eventdata, handles)
                return
        else
                set(handles.listbox_lines, 'Value', lastlineclicked{5});
                set(handles.listbox_lines, 'Enable', 'on');
                return
        end
end

%--------------------------------------------------------------------------
function listbox_lines_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_numeric_type_Callback(hObject, eventdata, handles)

set(handles.edit_numeric_type, 'ForegroundColor', [0 0 0]);
set(handles.edit_event_label, 'ForegroundColor', [0 0 0]);
set(handles.edit_binindex, 'ForegroundColor', [0 0 0]);
set(handles.edit_bindescription, 'ForegroundColor', [0 0 0]);
numco = str2num(get(handles.edit_numeric_type, 'String'));
if isempty(numco)
        msgboxText =  'You must enter numeric value(s)';
        title = 'ERPLAB: assigncodesGUI() error';
        errorfound(msgboxText, title);
        return
end
set(handles.edit_numeric_type, 'String', vect2colon(numco, 'Delimiter','off', 'Repeat','off'));

% if ~isempty(get(handles.edit_event_label,'String'))
set(handles.pushbutton_update,'Enable', 'on');
% end

%--------------------------------------------------------------------------
function edit_numeric_type_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_event_label_Callback(hObject, eventdata, handles)

set(handles.edit_numeric_type, 'ForegroundColor', [0 0 0]);
set(handles.edit_event_label, 'ForegroundColor', [0 0 0]);
set(handles.edit_binindex, 'ForegroundColor', [0 0 0]);
set(handles.edit_bindescription, 'ForegroundColor', [0 0 0]);
strco = strtrim(get(handles.edit_event_label, 'String'));
if length(strco)>16
        msgboxText =  ['Told''ya!\n\n'...
                'Your event label has %d characters!\n'...
                'So, it will be shortened to 16 characters'];
        title = 'ERPLAB: very looooong bin description...';
        errorfound(sprintf(msgboxText, length(strco)), title, [1 1 0], [0 0 0], 0);
        strco = strco(1:16);
end
set(handles.edit_event_label, 'String', strco);

% if ~isempty(get(handles.edit_numeric_type,'String'))
%       set(handles.pushbutton_update,'Enable', 'on');
% end
%--------------------------------------------------------------------------
function edit_event_label_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_binindex_Callback(hObject, eventdata, handles)

set(handles.edit_numeric_type, 'ForegroundColor', [0 0 0]);
set(handles.edit_event_label, 'ForegroundColor', [0 0 0]);
set(handles.edit_binindex, 'ForegroundColor', [0 0 0]);
set(handles.edit_bindescription, 'ForegroundColor', [0 0 0]);
bindx = str2num((get(handles.edit_binindex, 'String')));

if length(bindx)>1
        msgboxText =  'You must enter a single numeric value';
        title = 'ERPLAB: assigncodesGUI() error';
        errorfound(msgboxText, title);
        return
end
if ~isempty(bindx)
        if nnz(bindx<=0)>0
                msgboxText =  'You must enter a positive interger value';
                title = 'ERPLAB: assigncodesGUI() error';
                errorfound(msgboxText, title);
                return
        end
        set(handles.edit_binindex, 'String', strtrim(num2str(bindx)));
end

%--------------------------------------------------------------------------
function edit_binindex_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_bindescription_Callback(hObject, eventdata, handles)

set(handles.edit_numeric_type, 'ForegroundColor', [0 0 0]);
set(handles.edit_event_label, 'ForegroundColor', [0 0 0]);
set(handles.edit_binindex, 'ForegroundColor', [0 0 0]);
set(handles.edit_bindescription, 'ForegroundColor', [0 0 0]);
bdesc = strtrim(get(handles.edit_bindescription, 'String'));

if length(bdesc)>48
        msgboxText =  ['Are you writing a letter?\n\n'...
                'Your bin description got %d characters!'];
        title = 'ERPLAB: very looooong bin description...';
        errorfound(sprintf(msgboxText, length(bdesc)), title, [1 1 0], [0 0 0], 0);
end
set(handles.edit_bindescription, 'String', bdesc);

%--------------------------------------------------------------------------
function edit_bindescription_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_update_Callback(hObject, eventdata, handles)

currline = get(handles.listbox_lines, 'Value');
fulltext = get(handles.listbox_lines, 'String');
lentext  = length(fulltext);

%
% Event type
%
numco    = str2num(get(handles.edit_numeric_type, 'String')); % numeric event type
lnumco = length(numco);

%
% Event label
%
elabel   = get(handles.edit_event_label, 'String');  % event label (no white spaces)

if lnumco==0 || isempty(elabel) || strcmp(elabel,'""')
        set(handles.pushbutton_update, 'Enable','off')
        msgboxText =  'Error: You must define both an Event Code (number) and Event Label (string).'; %SH
        title = 'ERPLAB: input';
        errorfound(msgboxText, title);
        set(handles.pushbutton_update, 'Enable','on')
        handles.lastlineclicked = {};
        
        % Update handles structure
        guidata(hObject, handles);
        return
end
if length(elabel)>16
        elabel = strtrim(elabel(1:16));
else
        elabel = strtrim(elabel);
end
elabel = regexprep(elabel, ' ','_');
elabel2 = regexprep(elabel, '"',''); % avoids multiple "
elabel = ['"' elabel2 '"'];

%
% Bin index
%
bini = strtrim(get(handles.edit_binindex, 'String'));
if isempty(bini)
        bini = '[]';
        bini2 = '';
else
        auxbin  = str2num(bini);
        if isempty(auxbin)
                msgboxText =  'Error: You have to specify a numeric bin index!';
                title = 'ERPLAB';
                errorfound(msgboxText, title);
                return
        else
                if length(auxbin)~=1
                        msgboxText =  'Error: You have to specify a single bin index!';
                        title = 'ERPLAB';
                        errorfound(msgboxText, title);
                        return
                end
        end
        bini2 = bini;
end

%
% Bin description
%
bindesc  = strtrim(get(handles.edit_bindescription, 'String'));
if ~strcmp(bini,'[]') && isempty(bindesc)
        msgboxText =  'Error: You must specify a bin description!';
        title = 'ERPLAB';
        errorfound(msgboxText, title);
        return
end
bindesc2  = regexprep(bindesc, '"',''); % avoids multiple "
bindesc   = ['"' bindesc2 '"'];

if currline==lentext && lnumco==1
        % extra line forward
        fulltext  = cat(1, fulltext, {'new line'});
elseif currline==lentext && lnumco>1
        fulltext  = cat(1, fulltext, repmat({''},lnumco-1,1),{'new line'});
elseif currline~=lentext && lnumco>1
        auxft = fulltext(currline+1:end);
        fulltext  = cat(1, fulltext(1:currline), repmat({''},lnumco-1,1),auxft);
end
for i=1:lnumco
        newline = sprintf('%5s %16s %5s %20s', num2str(numco(i)), elabel, bini, bindesc);
        fulltext{currline+i-1} = newline; %Javier's code
end
set(handles.listbox_lines, 'String', fulltext)
set(handles.listbox_lines, 'Value', currline+lnumco)
set(handles.edit_numeric_type, 'String', num2str(numco(end)))
indxline = length(fulltext);
handles.indxline = indxline;
handles.fulltext = fulltext;
handles.lastlineclicked = {strtrim(num2str(numco(end))), elabel2, bini2, bindesc2, currline};
handles.listname = [];

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function pushbutton_openlist_Callback(hObject, eventdata, handles, editlistname)
if nargin<4
        [filename, filepath] = uigetfile({'*.txt';'*.*'},'Select an edited file');
        
        if isequal(filename,0)
                disp('User selected Cancel')
                return
        else
                fullname = fullfile(filepath, filename);
        end
else
        fullname = editlistname;
end

set(handles.edit_filelist,'String',fullname);
fid_edition = fopen( fullname );
% try   
try
        formcell = importdata(fullname, '\t');
        fulltext = char(formcell);
catch
        formcell = textscan(fid_edition, '%[^\n]', 'CommentStyle','#', 'whitespace', '');
        fulltext = formcell{:}; % cellstr was removed
end
% catch
%         serr = lasterror;
%         msgboxText =  ['Please check your file: \n'...
%                 fullname '\n'...
%                 serr.message];
%         title = 'ERPLAB: pop_editeventlist() error:';
%         errorfound(sprintf(msgboxText), title);
%         return
% end

% extra line forward
fulltext  = cat(1, fulltext, {'new line'});
lentext   = length(fulltext);
fclose(fid_edition);

if lentext>0
        indxline = lentext;
        set(handles.listbox_lines,'String',fulltext);
        set(handles.listbox_lines,'Value',indxline);
        set(handles.pushbutton_savelist, 'Enable','on')
        handles.fulltext = fulltext;
        handles.indxline = indxline;
        listname = fullname;
        handles.listname = listname;
        set(handles.pushbutton_savelist,'Enable', 'on')
        
        % Update handles structure
        guidata(hObject, handles);
end

%--------------------------------------------------------------------------
function pushbutton_close_Callback(hObject, eventdata, handles)

handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function pushbutton_help_Callback(hObject, eventdata, handles)
% doc pop_editeventlist
web https://github.com/lucklab/erplab/wiki/Creating-An-EVENTLIST -browser

%--------------------------------------------------------------------------
function pushbutton_apply_Callback(hObject, eventdata, handles)

fulltext  = get(handles.listbox_lines, 'String');
fulltext  = fulltext(~ismember_bc2(fulltext, {'new line'})); % avoid multiple 'new line'
fulltext  = [fulltext; 'new line'];
nline     = length(fulltext);
currline  = get(handles.listbox_lines, 'Value');
lastlineclicked = handles.lastlineclicked;

if ~isempty(lastlineclicked)
        numco = get(handles.edit_numeric_type, 'String');
        strco = get(handles.edit_event_label, 'String');
        bindx = get(handles.edit_binindex, 'String');
        bdesc = get(handles.edit_bindescription, 'String');
        cmatch1 = strcmpi(lastlineclicked{1}, numco);
        cmatch2 = strcmpi(lastlineclicked{2}, strco);
        cmatch3 = strcmpi(lastlineclicked{3}, bindx);
        cmatch4 = strcmpi(lastlineclicked{4}, bdesc);
        condi = cmatch1 && cmatch2 && cmatch3 && cmatch4;
else
        cmatch1 = strcmpi(get(handles.edit_numeric_type, 'string'), '');
        cmatch2 = strcmpi(get(handles.edit_event_label, 'string'), '');
        cmatch3 = strcmpi(get(handles.edit_binindex, 'string'), '');
        cmatch4 = strcmpi(get(handles.edit_bindescription, 'string'), '');
        condi = cmatch1 && cmatch2 && cmatch3 && cmatch4;
end
if condi
        if nline>1
                fullt1 = char(fulltext);
                fullt2 = cellstr(fullt1(1:(nline-1),:));
                [strmat strtok] = regexp(fullt2, '([-+]*\d+)\s*"(.*)"\s*(\d+|[[]]+)\s*"(.*)"', 'match', 'tokens');
                
                if isempty([strtok{:}])
                        msgboxText =  'Error: There is one or more invalid eventcode entries!';
                        title = 'ERPLAB';
                        errorfound(msgboxText, title);
                        return
                end
                numbina = cell(1);
                for m=1:nline-1
                        numbina{m} = str2num(strtok{m}{1}{3});
                        if isempty(numbina{m})
                                numbina{m} = 0;  % since bin zero isn't allowed...
                        elseif numbina{m} < 1 %SH
                                numbina{m} = -1; % since you cannot start a bin at zero... %SH
                        end
                end
                indi   = find(cell2mat(numbina));
                if ~isempty(indi)
                        numbaux = cell2mat(numbina(indi));
                        nub  = length(numbaux);
                        unb  = unique_bc2(numbaux);
                        nunb = length(unb);
                        sbin    = sort(unb);
                        compbin = [1:nunb]==unb;
                        
                        if nnz(compbin)<nunb
                                msgboxText = [ 'Error: bin numbering must be consecutive starting from 1!\n'...
                                        'Note: Order does not matter.\n'];
                                title = 'ERPLAB';
                                errorfound(sprintf(msgboxText), title);
                                return
                        end
                end
        end
        if nline>1
                listname = handles.listname;
        else
                listname = '';
        end
        if isempty(listname) && nline>1
                BackERPLABcolor = [1 0.9 0.3];    % ERPLAB main window background
                question = ['You have not saved your changes.\n\n'...
                        'What would you like to do?'];
                title = 'Save List of changes';
                oldcolor = get(0,'DefaultUicontrolBackgroundColor');
                set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
                button = questdlg(sprintf(question), title,'Save and Continue','Save As', 'Cancel','Save and Continue');
                set(0,'DefaultUicontrolBackgroundColor',oldcolor)
                
                if strcmpi(button,'Save As')
                        fullname = savelist(hObject, eventdata, handles);
                        listname = fullname;
                        if isempty(listname)
                                return
                        end
                elseif strcmpi(button,'Save and Continue')
                        fulltext = char(fulltext); % get(handles.listbox_lines,'String'));
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
                        % Update handles structure
                        guidata(hObject, handles);
                        return
                end
        end
        
        outputparam{1} = listname;
        
        % To :
        button_tocurrentdata   = get(handles.radiobutton_tocurrentdata,'Value');
        button_toworkspace     = get(handles.checkbox_toworkspace,'Value');
        button_totext          = get(handles.radiobutton_totext,'Value');
        file4text              = strtrim(get(handles.edit_elname, 'String'));
        
        if strcmp(file4text,'') && button_totext
                msgboxText =  'You have to specify an EventList file output!';
                title = 'ERPLAB';
                errorfound(sprintf(msgboxText), title);
                return
        elseif ~strcmp(file4text,'') && button_totext
                [elpathname, elfilename, ext] = fileparts(file4text);
                
                if strcmpi(elpathname,'')
                        elpathname = cd;
                end
                if ~strcmpi(ext,'.txt')
                        ext='.txt';
                end
                
                elfilename = [elfilename ext];
                owfp = handles.owfp;  % over write file permission
                
                if exist(elfilename, 'file')~=0 && owfp==0
                        question = [elfilename ' already exists!\n'...
                                'Do you want to replace it?'];
                        title    = 'ERPLAB: Overwriting Confirmation';
                        button   = askquest(sprintf(question), title);
                        if ~strcmpi(button, 'yes')
                                return
                        end
                end
                disp(['For EVENTLIST text file, user selected ', fullfile(elpathname, elfilename)])
                outputparam{2} = elfilename;
        else
                outputparam{2} = 'none';
        end
        
        %
        % What to do with the EVENTLIST?
        if     button_toworkspace && button_tocurrentdata && button_totext
                option2do = 7;  % do all
        elseif button_toworkspace && button_tocurrentdata && ~button_totext
                option2do = 6;  % workspace & current data
        elseif button_toworkspace && ~button_tocurrentdata && button_totext
                option2do = 5;  %  workspace & text
        elseif button_toworkspace && ~button_tocurrentdata && ~button_totext
                option2do = 4;  %  workspace only
        elseif ~button_toworkspace && button_tocurrentdata && button_totext
                option2do = 3;  %  current data & text
        elseif ~button_toworkspace && button_tocurrentdata && ~button_totext
                option2do = 2;  % current data only
        elseif ~button_toworkspace && ~button_tocurrentdata && button_totext
                option2do = 1;  % text only
        else
                option2do = 0;  % do nothing -> error!!!
                title = 'ERPLAB';
                errorfound('pick something to do! (with the updated EVENTLIST...)', title);
                return
        end
        
        % Warning me when the eventlist text file already exist
        iswarning = get(handles.ELwarning,'Value');
        
        if get(handles.checkbox_update_EEG, 'Value')
                outputparam{3}=1;
        else
                outputparam{3}=0;
                fprintf('\n\nWARNING: You did not update your EEG.event struct.\n');
                fprintf('             Your current event info is within the EEG.EVENTLIST.eventinfo struct.\n');
                fprintf('             Use "Transfer eventinfo to EEG.event" menu.\n\n');
        end
        if get(handles.checkbox_addm99code,'Value')
                boundarystrcode1    = 'boundary';
                newboundarynumcode1 = -99;
        else
                boundarystrcode1    = [];
                newboundarynumcode1 = [];
        end
        if get(handles.checkbox_convert_b,'Value')
                boundarystrcode2    = strtrim(char(get(handles.edit_boundarycode, 'String')));
                boundarystrcode2    = char(regexprep(boundarystrcode2,'''|"','')); % eliminates 's and "s
                newboundarynumcode2 = str2num(get(handles.edit_numericode, 'String'));
                if isempty(boundarystrcode2)
                        msgboxText{1} =  'You must specify a boundary code!';
                        title = 'ERPLAB: empty input';
                        errorfound(msgboxText, title);
                        return
                end
                if isempty(newboundarynumcode2)
                        msgboxText{1} =  'You must specify a numeric code!';
                        title = 'ERPLAB: empty input';
                        errorfound(msgboxText, title);
                        return
                end
                if strcmp(boundarystrcode2, boundarystrcode1)
                        
                        boundarystrcode1 = [];
                        fprintf('\nWARNING: ''boundary'' event was specified twice for being numerically encoded.\n')
                        fprintf('ERPLAB will ignore one.\n')
                        %BackERPLABcolor = [1 0.9 0.3];    % ERPLAB main window background
                        %question = ['''boundary'' event is already specified to be numerically encoded.\n'...
                        %            'Please, disentangle this.\n'];
                        %title = 'Encoding boundary events';
                        %oldcolor = get(0,'DefaultUicontrolBackgroundColor');
                        %set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
                        %button = questdlg(sprintf(question), title,'OK','OK');
                        %set(0,'DefaultUicontrolBackgroundColor',oldcolor)
                        
                        %msgboxText{1} =  '''boundary'' event is already specified to be numerically encoded.';
                        %title = 'ERPLAB: duplicated inputs';
                        %errorfound(msgboxText, title);
                        %return
                end
        else
                boundarystrcode2    = [];
                newboundarynumcode2 = [];
        end
        
        boundarystrcode    = {boundarystrcode1 boundarystrcode2};
        newboundarynumcode = {newboundarynumcode1 newboundarynumcode2};
        boundarystrcode    = boundarystrcode(~cellfun(@isempty, boundarystrcode));
        newboundarynumcode = newboundarynumcode(~cellfun(@isempty, newboundarynumcode));
        outputparam{4} = boundarystrcode;
        outputparam{5} = newboundarynumcode;
        outputparam{6} = option2do;
        outputparam{7} = iswarning;
        
        alphanum = get(handles.checkbox_alphanum, 'Value'); % for letterkilla. Oct 10, 2012
        outputparam{8} = alphanum;       % for letterkilla. Oct 10, 2012
        
        handles.output = outputparam;        
        erpworkingmemory('assigncodesGUI', outputparam);
        
        % Update handles structure
        guidata(hObject, handles);
        uiresume(handles.gui_chassis);
else
        set(handles.listbox_lines, 'Enable', 'off');
        if nline~=currline
                msgboxText =  sprintf('You modified line # %g, but you did not update it!\n',currline);
        else
                msgboxText =  sprintf('You attempted to enter a new line, but you did not update it!\n');
        end
        title = 'ERPLAB: averager GUI empty input';
        buttonames = {'Go back & update', 'Continue & do not update'};
        button     = askquestpoly(msgboxText, title, {'Go back & update', 'Continue & do not update'});
        if strcmpi(button, buttonames{1})
                set(handles.listbox_lines, 'Value', currline);
                set(handles.listbox_lines, 'Enable', 'on');
                return
        elseif strcmpi(button, buttonames{2})
                handles.lastlineclicked = {};
                set(handles.listbox_lines, 'Value', get(handles.listbox_lines, 'Value'));
                set(handles.listbox_lines, 'Enable', 'on');
                listbox_lines_Callback(hObject, eventdata, handles)
                
                set(handles.edit_numeric_type, 'string','')
                set(handles.edit_event_label, 'string','')
                set(handles.edit_binindex, 'string','')
                set(handles.edit_bindescription, 'string','')
                pushbutton_apply_Callback(hObject, eventdata, handles)
                return
        end
end

%--------------------------------------------------------------------------
function pushbutton_delete_Callback(hObject, eventdata, handles)

fulltext = get(handles.listbox_lines, 'String');
indxline = length(fulltext);
fulltext = char(fulltext); % string matrix
currline = get(handles.listbox_lines, 'Value');

if nnz(~bitand(currline>=1,currline<indxline))==0
        fulltext(currline,:) = [];
        fulltext = cellstr(fulltext); % cell string
        set(handles.listbox_lines, 'String', fulltext);
        handles.lastlineclicked = {};
        
        % Update handles structure
        guidata(hObject, handles);
        
        set(handles.edit_numeric_type, 'string','')
        set(handles.edit_event_label, 'string','')
        set(handles.edit_binindex, 'string','')
        set(handles.edit_bindescription, 'string','')
        indxline = length(fulltext);
        currline = min(currline);
        if currline>indxline
                currline = indxline;
        end
        set(handles.listbox_lines, 'Value', currline);
        listbox_lines_Callback(hObject, eventdata, handles)
        handles.fulltext = fulltext;
        handles.listname = [];
        
        % Update handles structure
        guidata(hObject, handles);
end

%--------------------------------------------------------------------------
function pushbutton_savelistas_Callback(hObject, eventdata, handles)

fulltext = char(strtrim(get(handles.listbox_lines,'String')));
if min(size(fulltext)) > 1 %sh - changed length to min(size(fulltext))
        fullname = savelist(hObject, eventdata, handles);
        if isempty(fullname)
                return
        end
        set(handles.edit_filelist, 'String', fullname )
        set(handles.pushbutton_savelist, 'Enable', 'on')
        handles.listname = fullname;
        % Update handles structure
        guidata(hObject, handles);
else
        set(handles.pushbutton_savelistas,'Enable','off')
        msgboxText =  'You have not yet edited any event!';
        title = 'ERPLAB: geterpvalues GUI few inputs';
        errorfound(msgboxText, title);
        set(handles.pushbutton_savelistas,'Enable','on')
        return
end

%--------------------------------------------------------------------------
function pushbutton_update_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function radiobutton_totext_Callback(hObject, eventdata, handles)

if get(hObject, 'Value')
        set(handles.edit_elname, 'Enable', 'on');
        set(handles.pushbutton_browse, 'Enable', 'on');
        set(handles.edit_elname, 'BackgroundColor', [1 1 1]);
else
        set(handles.edit_elname, 'Enable', 'off');
        set(handles.pushbutton_browse, 'Enable', 'off');
        set(handles.edit_elname, 'BackgroundColor', [0.83 0.82 0.78]);
end

%--------------------------------------------------------------------------
function edit_binlistname_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_binlistname_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        uiresume(handles.gui_chassis);
else
        % The GUI is no longer waiting, just close it
        delete(handles.gui_chassis);
end

%--------------------------------------------------------------------------
function edit_elname_Callback(hObject, eventdata, handles)

fullname = get(hObject, 'String');
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
function checkbox_update_EEG_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function checkbox_modifyevent_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function togglebutton_summary_Callback(hObject, eventdata, handles)
try
        event = evalin('base', 'EEG.event');
        eval('[eventtypes histo] = squeezevents(event);')
catch
end

%--------------------------------------------------------------------------
function fullname = savelist(hObject, eventdata, handles)

fulltext = char(get(handles.listbox_lines,'String'));
namelist = char(strtrim(get(handles.edit_filelist,'String')));

%
% Save OUTPUT file
%
[filename, filepath, filterindex] = uiputfile({'*.txt';'*.dat';'*.*'},'Save edited code(s) as', namelist);

if isequal(filename,0)
        disp('User selected Cancel')
        fullname = [];
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
        disp(['For saving edited list of changes, user selected <a href="matlab: open(''' fullname ''')">' fullname '</a>'])
        fid_list   = fopen( fullname , 'w');
        for i=1:size(fulltext,1)-1
                fprintf(fid_list,'%s\n', fulltext(i,:));
        end
        fclose(fid_list);
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
function checkbox_addm99code_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function checkbox_convert_b_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
        set(handles.edit_boundarycode,'Enable', 'on');
        set(handles.edit_numericode,'Enable', 'on');
else
        set(handles.edit_boundarycode,'Enable', 'off');
        set(handles.edit_numericode,'Enable', 'off');
end

%--------------------------------------------------------------------------
function pushbutton_savelist_Callback(hObject, eventdata, handles)

fulltext = char(strtrim(get(handles.listbox_lines,'String')));
if length(fulltext)>1        
        fullname = get(handles.edit_filelist, 'String'); % name of the list        
        if ~strcmp(fullname,'')
                
                fid_list  = fopen( fullname , 'w');
                
                for i=1:size(fulltext,1)
                        fprintf(fid_list,'%s\n', fulltext(i,:));
                end
                
                fclose(fid_list);
                handles.listname = fullname;
                % Update handles structure
                guidata(hObject, handles);
                disp(['Saving list at <a href="matlab: open(''' fullname ''')">' fullname '</a>'])
        else
                pushbutton_savelistas_Callback(hObject, eventdata, handles)
                return
        end
else
        set(handles.pushbutton_savelist,'Enable','off')
        msgboxText =  'You have not written any eventcodes yet!'; %sh
        title = 'ERPLAB: chanoperGUI few inputs';
        errorfound(msgboxText, title);
        set(handles.pushbutton_savelist,'Enable','on')
        return
end

%--------------------------------------------------------------------------
function pushbutton23_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function checkbox6_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function button_clearfile_Callback(hObject, eventdata, handles)

set(handles.edit_filelist,'String','');
handles.listname = [];
set(handles.pushbutton_savelist,'Enable', 'off')
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function edit_filelist_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_filelist_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end


function checkbox_toworkspace_Callback(hObject, eventdata, handles)


function radiobutton_tocurrentdata_Callback(hObject, eventdata, handles)


function ELwarning_Callback(hObject, eventdata, handles)


function checkbox_alphanum_Callback(hObject, eventdata, handles)
