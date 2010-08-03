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

% Choose default command line output for assigncodesGUI
handles.output   = [];
handles.indxline = 1;
handles.fulltext = {};
handles.lastlineclicked = {};
handles.listname = [];
handles.owfp     = 0;  % over write file permission

% Update handles structure
guidata(hObject, handles);

%
% Name & version
%
version = geterplabversion;
set(handles.figure1,'Name', ['ERPLAB BETA ' version '   -   EVENTLIST GUI'])
set(handles.checkbox_create_eventlist,'Value', 0)
set(handles.checkbox_update_EEG,'Value', 1)
set(handles.edit_elname, 'Enable', 'off');
set(handles.pushbutton_browse, 'Enable', 'off');
set(handles.edit_elname, 'BackgroundColor', [0.83 0.82 0.78]);
set(handles.listbox_lines, 'String', {'new line'});
set(handles.edit_numeric, 'string','')
set(handles.edit_string, 'string','')
set(handles.edit_binindex, 'string','')
set(handles.edit_bindescription, 'string','')
set(handles.checkbox_addm99code,'Value', 1)
set(handles.edit_boundarycode,'Enable', 'off');
set(handles.edit_numericode,'Enable', 'off');

%
% Default boundary code
%
boundarystrcode    = '''boundary''';
newboundarynumcode = -99;
set(handles.edit_boundarycode, 'String', boundarystrcode);
set(handles.edit_numericode, 'String',num2str(newboundarynumcode));
set(handles.pushbutton_savelist,'Enable', 'off')

%
% Color GUI
%
handles = painterplab(handles);

% UIWAIT makes assigncodesGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


%--------------------------------------------------------------------------
function varargout = assigncodesGUI_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);
pause(0.5)

%--------------------------------------------------------------------------
function listbox_lines_Callback(hObject, eventdata, handles)

lastlineclicked = handles.lastlineclicked;

if ~isempty(lastlineclicked)
        numco = get(handles.edit_numeric, 'String');
        strco = get(handles.edit_string, 'String');
        bindx = get(handles.edit_binindex, 'String');
        bdesc = get(handles.edit_bindescription, 'String');
        
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
                        set(handles.edit_numeric, 'Enable','off');
                        set(handles.edit_string, 'Enable','off');
                        set(handles.edit_binindex, 'Enable','off');
                        set(handles.edit_bindescription, 'Enable','off');
                else
                        set(handles.pushbutton_update, 'Enable','on');
                        set(handles.edit_numeric, 'Enable','on');
                        set(handles.edit_string, 'Enable','on');
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
                        set(handles.edit_numeric, 'ForegroundColor', [0 0 0]);
                        set(handles.edit_string, 'ForegroundColor', [0 0 0]);
                        set(handles.edit_binindex, 'ForegroundColor', [0 0 0]);
                        set(handles.edit_bindescription, 'ForegroundColor', [0 0 0]);
                        set(handles.edit_numeric, 'String', numco);
                        set(handles.edit_string, 'String', strco);
                        set(handles.edit_binindex, 'String', bindx);
                        set(handles.edit_bindescription, 'String', bdesc);
                        handles.lastlineclicked = {numco strco bindx bdesc currlineindx};
                        
                        % Update handles structure
                        guidata(hObject, handles);
                else
                        set(handles.edit_numeric, 'ForegroundColor', [0.7 0.7 0.7]);
                        set(handles.edit_string, 'ForegroundColor', [0.7 0.7 0.7]);
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
        
        if strcmpi(button, buttonames{1})
                set(handles.listbox_lines, 'Value', lastlineclicked{5});
                set(handles.listbox_lines, 'Enable', 'on');
                return
        elseif strcmpi(button, buttonames{2})
                handles.lastlineclicked = {};
                set(handles.listbox_lines, 'Value', get(handles.listbox_lines, 'Value'));
                set(handles.listbox_lines, 'Enable', 'on');
                listbox_lines_Callback(hObject, eventdata, handles)
                return
        end
end

%--------------------------------------------------------------------------
function listbox_lines_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_numeric_Callback(hObject, eventdata, handles)

set(handles.edit_numeric, 'ForegroundColor', [0 0 0]);
set(handles.edit_string, 'ForegroundColor', [0 0 0]);
set(handles.edit_binindex, 'ForegroundColor', [0 0 0]);
set(handles.edit_bindescription, 'ForegroundColor', [0 0 0]);
numco = strtrim(get(handles.edit_numeric, 'String'));
set(handles.edit_numeric, 'String', numco);

%--------------------------------------------------------------------------
function edit_numeric_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_string_Callback(hObject, eventdata, handles)

set(handles.edit_numeric, 'ForegroundColor', [0 0 0]);
set(handles.edit_string, 'ForegroundColor', [0 0 0]);
set(handles.edit_binindex, 'ForegroundColor', [0 0 0]);
set(handles.edit_bindescription, 'ForegroundColor', [0 0 0]);
strco = strtrim(get(handles.edit_string, 'String'));
set(handles.edit_string, 'String', strco);

%--------------------------------------------------------------------------
function edit_string_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_binindex_Callback(hObject, eventdata, handles)

set(handles.edit_numeric, 'ForegroundColor', [0 0 0]);
set(handles.edit_string, 'ForegroundColor', [0 0 0]);
set(handles.edit_binindex, 'ForegroundColor', [0 0 0]);
set(handles.edit_bindescription, 'ForegroundColor', [0 0 0]);
bindx = strtrim(get(handles.edit_binindex, 'String'));
set(handles.edit_binindex, 'String', bindx);

%--------------------------------------------------------------------------
function edit_binindex_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_bindescription_Callback(hObject, eventdata, handles)

set(handles.edit_numeric, 'ForegroundColor', [0 0 0]);
set(handles.edit_string, 'ForegroundColor', [0 0 0]);
set(handles.edit_binindex, 'ForegroundColor', [0 0 0]);
set(handles.edit_bindescription, 'ForegroundColor', [0 0 0]);
bdesc = strtrim(get(handles.edit_bindescription, 'String'));
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

indxline = length(fulltext);
numco = strtrim(get(handles.edit_numeric, 'String'));
strc1 = get(handles.edit_string, 'String');

if ~isempty(strc1) && ~strcmp(strc1, '')
        
        if length(strc1)>16
                strco = strtrim(strc1(1:16));
        else
                strco = strtrim(strc1);
        end
        
        strcox = regexprep(strco, ' ','_');
        strcox = regexprep(strco, '"',''); % avoids multiple "s
else
        strcox = '';
end

strco = ['"' strcox '"'];
bindx = strtrim(get(handles.edit_binindex, 'String'));

if ~strcmp(bindx,'')
        auxbin = str2num(bindx);
        bindx_T = bindx;
        if isempty(auxbin)
                msgboxText{1} =  'Error: You have to specify a numeric bin index!';
                title = 'ERPLAB';
                errorfound(msgboxText, title)
                return
        else
                if length(auxbin)~=1
                        msgboxText{1} =  'Error: You have to specify a unique numeric bin index!';
                        title = 'ERPLAB';
                        errorfound(msgboxText, title)
                        return
                end
        end
else
        bindx_T = '[]';
end

bdesc   = strtrim(get(handles.edit_bindescription, 'String'));
bdesc_T = regexprep(bdesc, '"',''); % avoids multiple "s
bdesc   = ['"' bdesc_T '"'];

%
% Test numeric inputs for numeric code and bin descripton
%
auxnum  = str2num(numco);
testnum = ~isempty(auxnum);

if testnum && ~strcmp(strco,'""')
        
        if length(auxnum)==1
                
                newline = sprintf('%5s %16s %5s %20s', numco, strco, bindx_T, bdesc);
                               
                if currline==indxline
                        % extra line forward
                        fulltext  = cat(1, fulltext, {'new line'});
                        set(handles.listbox_lines, 'Value', currline+1)
                        set(handles.edit_numeric, 'ForegroundColor', [0.7 0.7 0.7]);
                        set(handles.edit_string,  'ForegroundColor', [0.7 0.7 0.7]);
                        set(handles.edit_binindex, 'ForegroundColor', [0.7 0.7 0.7]);
                        set(handles.edit_bindescription, 'ForegroundColor', [0.7 0.7 0.7]);
                else
                        set(handles.listbox_lines, 'Value', currline)
                end
                
                set(handles.pushbutton_savelistas, 'Enable','on')
                
                %Stanley Huang start---------------------------------------
                binnum = str2num(bindx_T);
                if isempty(binnum) && ~isempty(bdesc_T)
                        if indxline == currline
                                set(handles.listbox_lines, 'Value', length(fulltext)-1)
                                fulltext = char(fulltext); % string matrix
                                fulltext(currline,:) = [];
                                fulltext = cellstr(fulltext); % cell string
                        end
                        set(handles.listbox_lines, 'String', fulltext);
                        msgboxText{1} =  'Error: You must define both a bin number and bin description! ';
                        title = 'ERPLAB';
                        errorfound(msgboxText, title)
                elseif ~isempty(binnum) && isempty(bdesc_T)
                        if indxline == currline
                                set(handles.listbox_lines, 'Value', length(fulltext)-1)
                                fulltext = char(fulltext); % string matrix
                                fulltext(currline,:) = [];
                                fulltext = cellstr(fulltext); % cell string
                        end
                        set(handles.listbox_lines, 'String', fulltext);
                        msgboxText{1} =  'Error: You must define both a bin number and bin description! ';
                        title = 'ERPLAB';
                        errorfound(msgboxText, title)
                elseif ~isempty(bindx_T) && ~isempty(bdesc)
                        fulltext{currline} = newline; %Javier's code
                        set(handles.listbox_lines, 'String', fulltext)
                end
                %Stanley Huang end-----------------------------------------
                
                indxline = length(fulltext);
                handles.indxline = indxline;
                handles.fulltext = fulltext;
                
                handles.lastlineclicked = {numco strcox bindx bdesc_T currline};
                handles.listname = [];
                
                % Update handles structure
                guidata(hObject, handles);
        end
else
        set(handles.pushbutton_update, 'Enable','off')
        msgboxText{1} =  'Error: You must define both an Event Code (number) and Event Label (string)!'; %SH
        title = 'ERPLAB';
        errorfound(msgboxText, title)
        set(handles.pushbutton_update, 'Enable','on')
        handles.lastlineclicked = {};
        
        % Update handles structure
        guidata(hObject, handles);
        return
end

%--------------------------------------------------------------------------
function pushbutton_openlist_Callback(hObject, eventdata, handles)

[filename, filepath] = uigetfile({'*.txt';'*.*'},'Select an edited file');

if isequal(filename,0)
        disp('User selected Cancel')
        return
else
        fullname = fullfile(filepath, filename);
end

set(handles.edit_filelist,'String',fullname);

fid_edition = fopen( fullname );

try        
        formcell    = textscan(fid_edition, '%[^\n]', 'CommentStyle','#', 'whitespace', '');
        fulltext    = formcell{:}; % cellstr was removed
catch
        serr = lasterror;
        msgboxText =  ['Please check your file: \n'...
                fullname '\n'...
                serr.message];
        title = 'ERPLAB: pop_editeventlist() error:';
        errorfound(sprintf(msgboxText), title)
        return
end

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
uiresume(handles.figure1);

%--------------------------------------------------------------------------
function pushbutton_apply_Callback(hObject, eventdata, handles)

fulltext  = get(handles.listbox_lines, 'String');
nline     = length(fulltext);
currline  = get(handles.listbox_lines, 'Value');
lastlineclicked = handles.lastlineclicked;

if ~isempty(lastlineclicked)
        numco = get(handles.edit_numeric, 'String');
        strco = get(handles.edit_string, 'String');
        bindx = get(handles.edit_binindex, 'String');
        bdesc = get(handles.edit_bindescription, 'String');
        cmatch1 = strcmpi(lastlineclicked{1}, numco);
        cmatch2 = strcmpi(lastlineclicked{2}, strco);
        cmatch3 = strcmpi(lastlineclicked{3}, bindx);
        cmatch4 = strcmpi(lastlineclicked{4}, bdesc);
        condi = cmatch1 && cmatch2 && cmatch3 && cmatch4;
else
        cmatch1 = strcmpi(get(handles.edit_numeric, 'string'), '');
        cmatch2 = strcmpi(get(handles.edit_string, 'string'), '');
        cmatch3 = strcmpi(get(handles.edit_binindex, 'string'), '');
        cmatch4 = strcmpi(get(handles.edit_bindescription, 'string'), '');
        condi = cmatch1 && cmatch2 && cmatch3 && cmatch4;
end

if condi
        
        fullname  = get(handles.edit_elname, 'String');
        
        if nline>1
                
                fullt1 = char(fulltext);
                fullt2 = cellstr(fullt1(1:(nline-1),:));
                
                [strmat strtok] = regexp(fullt2, '([-+]*\d+)\s*"(.*)"\s*(\d+|[[]]+)\s*"(.*)"', 'match', 'tokens');
                
                if isempty([strtok{:}])
                        msgboxText{1} =  'Error: There is one or more invalid eventcode entries!';
                        title = 'ERPLAB';
                        errorfound(msgboxText, title)
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
                        unb  = unique(numbaux);
                        nunb = length(unb);
                        
                        sbin    = sort(unb);
                        compbin = [1:nunb]==unb;
                        
                        if nnz(compbin)<nunb
                                msgboxText = [ 'Error: bin numbering must be consecutive starting from 1!\n'...
                                               'Note: Order does not matter.\n'];
                                title = 'ERPLAB';
                                errorfound(sprintf(msgboxText), title)
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
                question{1} = 'You have not saved your changes.';
                question{2} = 'What would you like to do?';
                title = 'Save List of changes';
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
                        
                        fulltext = char(get(handles.listbox_lines,'String'));
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
        
        if get(handles.checkbox_create_eventlist, 'Value')
                
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
                outputparam{2} = elfilename;
                
        else
                outputparam{2} = '';
        end
        
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
        
        outputparam{4} = boundarystrcode;
        outputparam{5} = newboundarynumcode;
        
        handles.output = outputparam;
        
        % Update handles structure
        guidata(hObject, handles);
        uiresume(handles.figure1);
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
                
                set(handles.edit_numeric, 'string','')
                set(handles.edit_string, 'string','')
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
        
        set(handles.edit_numeric, 'string','')
        set(handles.edit_string, 'string','')
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
        errorfound(msgboxText, title)
        set(handles.pushbutton_savelistas,'Enable','on')
        return
end

%--------------------------------------------------------------------------
function pushbutton_update_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function checkbox_create_eventlist_Callback(hObject, eventdata, handles)

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
function figure1_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        uiresume(handles.figure1);
else
        % The GUI is no longer waiting, just close it
        delete(handles.figure1);
end

%--------------------------------------------------------------------------
function edit_elname_Callback(hObject, eventdata, handles)

fullname = get(hObject, 'String');
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
function checkbox_update_EEG_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function checkbox_modifyevent_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function togglebutton_summary_Callback(hObject, eventdata, handles)
event = evalin('base', 'EEG.event');
eval('[eventtypes histo] = squeezevents(event);')

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
        errorfound(msgboxText, title)
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
