
% Begin initialization code - DO NOT EDIT
function varargout = chanoperGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @chanoperGUI_OpeningFcn, ...
        'gui_OutputFcn',  @chanoperGUI_OutputFcn, ...
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
function chanoperGUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = [];
example{1}  = 'ch@ = ch6 - ch5 label HEOG';
example{2}  = 'chan@ = ch6 - ch5 label = HEOG';
example{3}  = 'ch@ = 0.5*chan7 + 0.5*chan9 label LINKM';
example{4}  = 'ch@ = mahaleeg(ch1,ch2) label MAHAL01';
example{5}  = 'CH@ = mahaleeg(ch40) label SELFMAHAL';
example{6}  = 'ch@ = (ch11+ch12+ch13)/3 label = ROI temporal';
example{7}  = 'CHAN@ = (ch11 + ch12 + ch13)/3 label ROI temporal';
example{8}  = 'ch@ = abs(ch110) label E110 rectified ';

try
        ERPLAB = varargin{1};
        
        if iserpstruct(ERPLAB)
                nchan      = ERPLAB.nchan; % Total number of channels
                typedata   = 'ERP';
                datastr    = 'ERPset';
                formtype   = 'erpchanformulas';
                example{5} = 'ch@ = mgfperp(ERP) label MGFPower';
        else
                example{3} = 'ch@ = chinterpol';
                nchan    = ERPLAB.nbchan; % Total number of channels
                typedata = 'EEG';
                datastr  = 'dataset';
                formtype = 'eegchanformulas';
        end
catch
        ERPLAB.chanlocs = [];
        listch   = '';
        nchan    = 1;
        formtype = [];
        typedata = 'unspecific data';
        datastr  = 'who-knows-what';
end
try
        def = varargin{2};
        formulas = def{1};
        wchmsgon = def{2};
catch
        formulas = [];
        wchmsgon = 1;
end

handles.nchan    = nchan;
% handles.listname = [];
handles.example  = example;
handles.exacounter = 0;
handles.typedata = typedata;
handles.formtype = formtype;

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   Channel Operation GUI for ' typedata])

% formulas = erpworkingmemory(formtype);

if isempty(formulas)
        set(handles.editor,'String','');
else
        set(handles.editor, 'String', formulas)
end

% For undo & redo
% handles.formulas{1} = get(handles.editor, 'String');
% handles.undocount = 1;
% set(handles.pushbutton_undo,'Enable','off')
% set(handles.pushbutton_redo,'Enable','off')

%
% Prepare List of current Channels
%
listch=[];
if isempty(ERPLAB.chanlocs)
        for e=1:nchan
                ERPLAB.chanlocs(e).labels = ['Ch' num2str(e)];
        end
end
listch = cell(1,nchan);
for ch =1:nchan
        listch{ch} = [num2str(ch) ' = ' ERPLAB.chanlocs(ch).labels ];
end

set(handles.listboxchan1,'String', listch)
label1 = '<HTML><left>Send file rather than individual equations';
label2 = '<HTML><left>(creates compact history)';
set(handles.checkbox_sendfile2history, 'string',[label1 '<br>' label2])
handles.listch = listch;

%
% Mode buttons
%
set(handles.button_recursive, 'String', sprintf('Modify existing %s (recursive updating)', datastr));
set(handles.button_no_recu, 'String', sprintf('Create new %s (independent transformations)',datastr));

%
% Gui memory
%
chanopGUI = erpworkingmemory('chanopGUI');

if isempty(chanopGUI)
        set(handles.button_recursive,'Value', 1); % default is Modify existing ERPset (recursive updating)
        set(handles.button_savelist, 'Enable','off')
        
        %
        % File List
        %
        set(handles.edit_filelist,'String','');
        set(handles.checkbox_sendfile2history,'Value',0)
        handles.listname = [];
else
        if chanopGUI.emode==0
                set(handles.button_recursive,'Value', 1);
                set(handles.button_no_recu,'Value', 0);
        else
                set(handles.button_recursive,'Value', 0);
                set(handles.button_no_recu,'Value', 1);
        end
        if chanopGUI.hmode==0
                set(handles.checkbox_sendfile2history,'Value', 0);
        else
                set(handles.checkbox_sendfile2history,'Value', 1);
        end
        listname = chanopGUI.listname;
        set(handles.edit_filelist,'String', listname );
        handles.listname = listname; % JLC Sept 1, 2012
end

% wchmsgon = erpworkingmemory('wchmsgon');

if isempty(wchmsgon) || wchmsgon==0
        set(handles.chwarning,'Value', 0)
elseif wchmsgon==1
        set(handles.chwarning,'Value', 1)
else
        error('Oops...checkbox_warning memory failed')
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
helpbutton

drawnow
uiwait(handles.gui_chassis);

%--------------------------------------------------------------------------
function varargout = chanoperGUI_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure

varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

%--------------------------------------------------------------------------
function editor_Callback(hObject, eventdata, handles)

set(handles.edit_filelist, 'String','');
compacteditor(hObject, eventdata, handles);

% handles = editorbackup(hObject, eventdata, handles);
% formulas  = get(handles.editor, 'String');
% undocount = handles.undocount;
% undocount = undocount + 1;
% handles.formulas{undocount} = formulas;
% handles.undocount = undocount;

handles.listname  = [];

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function editor_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_help_Callback(hObject, eventdata, handles)
% doc pop_eegchanoperator
web https://github.com/lucklab/erplab/wiki/EEG-and-ERP-Channel-Operations -browser

%--------------------------------------------------------------------------
function pushbutton_RUN_Callback(hObject, eventdata, handles)
listname    = handles.listname;
compacteditor(hObject, eventdata, handles);
formulalist = get(handles.editor,'String');
wchmsgon    = get(handles.chwarning,'Value');

if strcmp(formulalist,'')
        msgboxText =  'You have not written any formula!';
        title = 'ERPLAB: chanoperGUI few inputs';
        errorfound(msgboxText, title);
        return
end
if size(formulalist,2)>256
        msgboxText = ['Formulas length exceed 256 characters.\n\n'...
                'Be sure to press [Enter] after you have entered each formula.'];
        title = 'ERPLAB: chanoperGUI few inputs';
        errorfound(sprintf(msgboxText), title);
        return
end

%
% Check formulas
%
if get(handles.button_recursive,'Value')
        editormode = 0;
else
        editormode = 1;
end

typedata = lower(handles.typedata);
[option, recall, goeson] = checkformulas(cellstr(formulalist), [typedata 'chanoperGUI'], editormode);

if goeson==0
        return
end
if isempty(listname) && get(handles.checkbox_sendfile2history,'Value')==1
        BackERPLABcolor = [1 0.9 0.3];    % yellow
        question = ['Equations at editor window have not been saved yet.\n\n'...
                'What would you like to do?'];
        title = 'WARNING: Save List of edited chans';
        oldcolor = get(0,'DefaultUicontrolBackgroundColor');
        set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
        button = questdlg(sprintf(question), title,'Save and run','Run without saving', 'Cancel','Run without saving');
        set(0,'DefaultUicontrolBackgroundColor',oldcolor)
        
        if strcmpi(button,'Save and run')
                fullname = savelist(hObject, eventdata, handles);
                listname = fullname;
                handles.output = {listname, wchmsgon}; % sent filenam string)
        elseif strcmpi(button,'Run without saving')
                handles.output = {cellstr(formulalist), wchmsgon}; % sent like a cell string (with formulas)
        elseif strcmpi(button,'Cancel') || strcmpi(button,'')
                handles.output   = [];
                handles.listname = [];
                % Update handles structure
                guidata(hObject, handles);
                return
        end
elseif isempty(listname) && get(handles.checkbox_sendfile2history,'Value')==0
        handles.output = {cellstr(formulalist), wchmsgon}; % sent like a cell string (with formulas)
        
elseif ~isempty(listname) && get(handles.checkbox_sendfile2history,'Value')==1
        handles.output = {listname, wchmsgon}; % sent filename string
        
elseif ~isempty(listname) && get(handles.checkbox_sendfile2history,'Value')==0
        handles.output = {cellstr(formulalist), wchmsgon}; % sent like a cell string (with formulas)
end

% handles.output
% formtype = handles.formtype;
% erpworkingmemory(formtype, formulalist);

%
% memory for Gui
%
chanopGUI.emode = editormode;
chanopGUI.hmode = get(handles.checkbox_sendfile2history,'Value');
chanopGUI.listname  = listname;
erpworkingmemory('chanopGUI', chanopGUI);

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function cancel_Callback(hObject, eventdata, handles)

handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function eraser_Callback(hObject, eventdata, handles)
% %
% % for undo
% %
% formulas  = get(handles.editor, 'String');
% undocount = handles.undocount;
% handles.formulas{undocount} = formulas;
% undocount = undocount + 1;
% handles.undocount = undocount;
formulas  = get(handles.editor, 'String');
if isempty(formulas)
        return
end

% handles = editorbackup(hObject, eventdata, handles);
set(handles.editor, 'String','')
handles.output = [];
disp('Formulas were erased.')
set(handles.button_savelist, 'Enable','off')
handles.listname = [];
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function help_Callback(hObject, eventdata, handles)

fprintf('\n\n\n\n\n')
help pop_chanoperator

%--------------------------------------------------------------------------
function button_saveaslist_Callback(hObject, eventdata, handles)

compacteditor(hObject, eventdata, handles);
fulltext = strtrim(get(handles.editor,'String'));

if size(fulltext,2)>256
        msgboxText =  ['Formulas length exceed 256 characters.\n\n'...
                'Be sure to press [Enter] after you have entered each formula.'];
        title = 'ERPLAB: chanoperGUI few inputs';
        errorfound(sprintf(msgboxText), title);
        return
end
if ~strcmp(fulltext,'')
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
        set(handles.button_saveaslist,'Enable','off')
        msgboxText =  'You have not written any formula yet!';
        title = 'ERPLAB: chanoperGUI few inputs';
        errorfound(msgboxText, title);
        set(handles.button_saveaslist,'Enable','on')
        return
end

%--------------------------------------------------------------------------
function button_loadlist_Callback(hObject, eventdata, handles)
[filename, filepath] = uigetfile({'*.txt';'*.*'},'Select a formulas-file');

if isequal(filename,0)
        disp('User selected Cancel')
        return
else
        fullname = fullfile(filepath, filename);
        disp(['pop_chanoperation(): For formulas-file, user selected ', fullname])
end

set(handles.edit_filelist,'String',fullname);
fid_formula = fopen( fullname );

try
        formcell    = textscan(fid_formula, '%s','delimiter', '\r');
        formulas    = char(formcell{:});
catch
        serr = lasterror;
        msgboxText =  ['Please, check your file: \n';
                fullname '\n'...
                serr.message];
        title = 'ERPLAB: pop_chanoperation() error:';
        errorfound(sprintf(msgboxText), title);
        return
end
if size(formulas,2)>256
        msgboxText =  ['Formulas length exceed 256 characters.\n\n'...
                'Be sure to press [Enter] after you have entered each formula.'];
        title = 'ERPLAB: chanoperGUI few inputs';
        errorfound(sprintf(msgboxText), title);
        return
end

compacteditor(hObject, eventdata, handles);
set(handles.editor,'String',formulas);
fclose(fid_formula);
set(handles.button_savelist, 'Enable','on')
handles.listname = fullname;

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function listboxchan1_Callback(hObject, eventdata, handles)

numchan   = get(hObject, 'Value');
if isempty(numchan)
        return
end

linet    = get(handles.editor, 'Value');

if nnz(linet) == 0
        linet = 1;
end

formulas = cellstr(get(handles.editor, 'String'));
formulas{linet} = [formulas{linet} 'ch' num2str(numchan)];
set(handles.editor, 'String', char(formulas));

%--------------------------------------------------------------------------
function listboxchan1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function button_example_Callback(hObject, eventdata, handles)

% %
% % for undo
% %
% formulas  = get(handles.editor, 'String');
% undocount = handles.undocount;
% handles.formulas{undocount} = formulas;
% undocount = undocount + 1;
% handles.undocount = undocount;

nchan      = handles.nchan;
example    = handles.example;
exacounter = handles.exacounter;
exacounter = exacounter + 1;
text       = cellstr(get(handles.editor, 'String'));

if get(handles.button_no_recu,'Value')
        prechar = 'n';
else
        prechar = '';
end
if isempty([text{:}]) || exacounter>length(example)
        exacounter = 1;
end
if length(text)==1 && strcmp(text{1}, '')
        exacurr = char(regexprep(example{exacounter},'@',num2str(nchan+exacounter)));
        text{1} = [prechar exacurr];
else
        exacurr = char(regexprep(example{exacounter},'@',num2str(nchan+exacounter)));
        text{end+1} = [prechar exacurr];
end

set(handles.editor, 'String', char(text));
% handles    = editorbackup(hObject, eventdata, handles);
handles.exacounter = exacounter;
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function fullname = savelist(hObject, eventdata, handles)
fulltext = char(get(handles.editor,'String'));

if isempty(fulltext)
        return
end

fullnamepre = get(handles.edit_filelist,'String');

%
% Save OUTPUT file
%
[filename, filepath, filterindex] = uiputfile({'*.txt';'*.dat';'*.*'},'Save formulas-file as', fullnamepre);

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
        
        fid_list   = fopen( fullname , 'w');
        
        for i=1:size(fulltext,1)
                fprintf(fid_list,'%s\n', fulltext(i,:));
        end
        
        fclose(fid_list);
        set(handles.button_savelist, 'Enable','on')
end

%--------------------------------------------------------------------------
function compacteditor(hObject, eventdata, handles)
texteditor = strtrim(get(handles.editor,'String'));

if isempty(texteditor)
        return
end

formul = cellstr(texteditor);
nfl    = length(formul);
k = 1;
formulalist = cell(1);

% removes blank lines
for i=1:nfl
        if ~strcmp(formul{i},'')
                % removes blank lines
                formulalist{k} = regexprep(formul{i},'[^\s](label)[^\s]',' $1 ', 'ignorecase');
                k = k+1;
        end
end

formulalist = strtrimx(formulalist); % special white space removing
set(handles.editor,'String', char(formulalist));
drawnow

%--------------------------------------------------------------------------
function check_aoperations(hObject, eventdata, handles)
texteditor = strtrim(get(handles.editor,'String'));
if isempty(texteditor)
        return
end

formul = cellstr(texteditor);
nfl = length(formul);
k   = 1;
formulalist = cell(1);

for i=1:nfl
        if ~strcmp(formul{i},'')
                formulalist{k} = formul{i};
                k = k+1;
        end
end

formulalist = strtrimx(formulalist);
set(handles.editor,'String', char(formulalist));

%--------------------------------------------------------------------------
function button_savelist_Callback(hObject, eventdata, handles)
compacteditor(hObject, eventdata, handles);
fulltext = strtrim(get(handles.editor,'String'));

if size(fulltext,2)>256
        msgboxText = ['Formulas length exceed 256 characters.\n\n'...
                'Be sure to press [Enter] after you have entered each formula.'];
        title = 'ERPLAB: chanoperGUI few inputs';
        errorfound(sprintf(msgboxText), title);
        return
end
if ~isempty(fulltext)
        
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
                button_saveaslist_Callback(hObject, eventdata, handles)
                return
        end
else
        set(handles.button_saveaslist,'Enable','off')
        msgboxText =  'You have not written any formula yet!';
        title      = 'ERPLAB: chanoperGUI few inputs';
        errorfound(msgboxText, title);
        set(handles.button_saveaslist,'Enable','on')
        return
end

%--------------------------------------------------------------------------
function checkbox_sendfile2history_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_filelist_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_filelist_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function button_clearfile_Callback(hObject, eventdata, handles)
set(handles.edit_filelist,'String','');
set(handles.button_savelist, 'Enable', 'off')

%--------------------------------------------------------------------------
function button_recursive_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.button_no_recu,'Value',0)
        val = testsyntaxtype(hObject, eventdata, handles, 'recu');
        
        if val==0;
                set(handles.button_recursive, 'Value', 0)
                set(handles.button_no_recu, 'Value', 1)                
        end
        
        %%%       handles = editorbackup(hObject, eventdata, handles);
        %%% Update handles structure
        %%guidata(hObject, handles);
else
        set(hObject,'Value',1)
end

%--------------------------------------------------------------------------
function button_no_recu_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.button_recursive,'Value',0)
        val = testsyntaxtype(hObject, eventdata, handles, 'norecu');
        if val==0
                set(handles.button_recursive, 'Value', 1)
                set(handles.button_no_recu, 'Value', 0)
        end
        %%%       handles = editorbackup(hObject, eventdata, handles);
        %%% Update handles structure
        %%%guidata(hObject, handles);
else
        set(hObject,'Value',1)
end

%--------------------------------------------------------------------------
function val = testsyntaxtype(hObject, eventdata, handles, whocall)
val = 1;
formulaArray = get(handles.editor,'String');

if isempty(formulaArray)
        return
else
        formulaArray = strtrim(cellstr(formulaArray));
end
nformulas = length(formulaArray);

[expspliter parts] = regexp(formulaArray, '=','match','split');
ask4fix = 1;
wantfix = 0;
newnumchan = 1;

for t=1:nformulas        
        fcomm = formulaArray{t};
        tokcommentb  = regexpi(fcomm, '^#', 'match');  % comment symbol (June 3, 2013)     
        
        if isempty(tokcommentb) % skip comment symbol               
                pleft  = regexpi(parts{t}{1}, '(\s*nch[an]*\d+)', 'tokens');
                plcom  = regexpi(parts{t}{1}, '(\s*ch[an]*\d+)', 'tokens');
                
                if isempty(pleft) &&  ~isempty(plcom) && strcmpi(whocall,'norecu')
                        if ask4fix
                                BackERPLABcolor = [1 0.9 0.3];    % yellow
                                question = ['For non recursive mode, left side of equation\nmust be define as a new channel.\n'...
                                            'For instance, nchan1 = ...\n\n'...
                                            'Do you want that ERPLAB corrects the syntax for you?'];
                                title = 'WARNING: Syntax is not proper for non recursive mode';
                                oldcolor = get(0,'DefaultUicontrolBackgroundColor');
                                set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
                                button = questdlg(sprintf(question), title,'Cancel','No', 'Yes','Yes');
                                set(0,'DefaultUicontrolBackgroundColor',oldcolor)
                                
                                if strcmpi(button,'Yes')
                                        ask4fix = 0;
                                        wantfix = 1;
                                elseif strcmpi(button,'Cancel')
                                        val = 0; % cancel
                                        break
                                else
                                        ask4fix = 0;
                                        wantfix = 0;
                                end
                                %else
                                %      wantfix =1;
                        end
                elseif ~isempty(pleft) && strcmpi(whocall,'recu')
                        if ask4fix
                                BackERPLABcolor = [1 0.9 0.3];    % yellow
                                question = ['For recursive mode, left side of equation cannot\nbe define as a new channel.\n'...
                                            'For instance, you must write chan1 = ...\n\n'...
                                            'Do you want that ERPLAB corrects the syntax for you?'];
                                title = 'WARNING: Syntax is not proper for recursive mode';
                                oldcolor = get(0,'DefaultUicontrolBackgroundColor');
                                set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
                                button = questdlg(sprintf(question), title,'Cancel','No', 'Yes','Yes');
                                set(0,'DefaultUicontrolBackgroundColor',oldcolor)
                                
                                if strcmpi(button,'Yes')
                                        ask4fix = 0;
                                        wantfix =1;
                                elseif strcmpi(button,'Cancel')
                                        val = 0; % cancel
                                        break
                                else
                                        ask4fix = 0;
                                        wantfix = 0;
                                end
                                %else
                                %      wantfix =1;
                        end
                        %else
                        %      wantfix = 0;
                end
                if wantfix && (~isempty(pleft) || ~isempty(plcom))% fixed  (June 3, 2013): JLC
                        fprintf('WARNING: equation %s ', formulaArray{t})
                        if strcmpi(whocall,'recu') % for recursive mode delete the n in nch
                                formulaArray{t} = sprintf('%s = %s', strtrim(regexprep(parts{t}{1}, '^n*','','ignorecase')), strtrim(parts{t}{2}));
                        else
                                formulaArray{t} = sprintf('%s = %s', strtrim(regexprep(parts{t}{1}, '^n*ch(\D*)(\d*)',['nch$1' num2str(newnumchan)],'ignorecase')), strtrim(parts{t}{2}));
                                newnumchan = newnumchan+1;
                        end
                        fprintf('was changed to equation %s \n', formulaArray{t})
                end
        end
end
if val==1
        set(handles.editor,'String', char(formulaArray));
end

%--------------------------------------------------------------------------
function chwarning_Callback(hObject, eventdata, handles)
%
% if get(hObject,'Value')
%       %
%       % Gui memory
%       %
%       erpworkingmemory('wchmsgon', 1);
% else
%       %
%       % Gui memory
%       %
%       erpworkingmemory('wchmsgon', 0);
% end

%--------------------------------------------------------------------------
function pushbutton_export_chan_list_Callback(hObject, eventdata, handles)
list_of_chans = get(handles.listboxchan1,'String');
nloch = length(list_of_chans);

for i=1:nloch
        fprintf('%s\n',list_of_chans{i});
end

fprintf('\n\nEnd of list.\n\n')

%--------------------------------------------------------------------------
function pushbutton_removechan_Callback(hObject, eventdata, handles)
typedata = handles.typedata;
chan2del = deletechanGUI(typedata);
nchan    = handles.nchan;

if ~isempty(chan2del)        
        chan2del = unique_bc2(cell2mat(chan2del));        
        if max(chan2del)>nchan && nnz(isinf(chan2del))==0
                msgboxText = 'You are specifying non-existing channels!';
                title = 'ERPLAB: chanoperGUI  remove channels';
                errorfound(sprintf(msgboxText), title);
                return
        end
        if min(chan2del)<1 && nnz(isinf(chan2del))==0
                msgboxText = 'You are specifying freaky non-existing channels!';
                title = 'ERPLAB: chanoperGUI  remove channels';
                errorfound(sprintf(msgboxText), title);
                return
        end
        if nnz(isnan(chan2del))>0  || nnz(isinf(chan2del))>0
                msgboxText = ['What are you smokin dude???\n'...
                        'You are specifying freaky non-existing channels!'];
                title = 'ERPLAB: chanoperGUI  remove channels';
                errorfound(sprintf(msgboxText), title);
                return
        end
        if strcmpi(typedata, 'EEG')
                eqtn = sprintf('deletechan(%s)', vect2colon(chan2del, 'Delimiter','off'));
        else
                eqtn = sprintf('delerpchan(%s)', vect2colon(chan2del, 'Delimiter','off'));
        end
        
        wchmsgon    = get(handles.chwarning,'Value');
        handles.output = {{eqtn}, wchmsgon}; % sent like a cell string (with formulas)
        % Update handles structure
        guidata(hObject, handles);
        uiresume(handles.gui_chassis);
else
        return
end

%--------------------------------------------------------------------------
function pushbutton_rerefwizard_Callback(hObject, eventdata, handles)
% set to non-recursive mode
set(handles.button_recursive, 'Value', 0)
set(handles.button_no_recu, 'Value', 1)

% open reference wizard
formulalist = rerefassistantGUI(handles.nchan, handles.listch);
if isempty(formulalist)
        return
end

compacteditor(hObject, eventdata, handles);
formulas  = get(handles.editor, 'String');

if get(handles.button_no_recu,'Value')
        formulalist = cellstr([formulalist{:}]);
        for t=1:length(formulalist)
                [expspliter parts] = regexp(formulalist, '=','match','split');
                formulalist{t} = sprintf('%s = %s', strtrim(regexprep(parts{t}{1}, '[^n]*ch','nch','ignorecase')), strtrim(parts{t}{2}));
        end
        formulalist = char(formulalist);
end

if isempty(formulas)
        set(handles.editor,'String',formulalist);
else
        formulalist = cellstr(formulalist);
        formulas = cellstr(formulas);
        formt = [formulas ;formulalist];
        formt = char(formt);
        set(handles.editor,'String',formt);
end

% %--------------------------------------------------------------------------
% function pushbutton_undo_Callback(hObject, eventdata, handles)
%
% undocount = handles.undocount;
% if undocount>1
%       undocount = undocount - 1;
%       formulas  = handles.formulas{undocount};
%       handles.undocount = undocount;
%       set(handles.editor, 'String',char(formulas));
%       set(handles.pushbutton_redo,'Enable','on')
%
%       % formulas = get(handles.edit_filelist, 'String');
%       % Update handles structure
%       guidata(hObject, handles);
% end
% if undocount==1
%       set(handles.pushbutton_undo,'Enable','off')
%       set(handles.pushbutton_redo,'Enable','on')
% end

%--------------------------------------------------------------------------
% function pushbutton_redo_Callback(hObject, eventdata, handles)
%
% nformu    = length(handles.formulas);
% undocount = handles.undocount;
% if undocount<nformu
%       undocount = undocount + 1;
%       formulas  = handles.formulas{undocount};
%       handles.undocount = undocount;
%       set(handles.editor, 'String',char(formulas));
%       % formulas = get(handles.edit_filelist, 'String');
%       % Update handles structure
%       guidata(hObject, handles);
% end
% if undocount==nformu
%       set(handles.pushbutton_redo,'Enable','off')
%       set(handles.pushbutton_undo,'Enable','on')
% end

%--------------------------------------------------------------------------
% function handles = editorbackup(hObject, eventdata, handles)
%
% %
% % for undo
% %
% formulas = get(handles.editor, 'String');
% if isempty(formulas)
%       return
% end
%
% lastform = handles.formulas(end);
%
% if strcmp(char(formulas),char(lastform))
%       return
% end
%
% undocount = length(handles.formulas);
% undocount = undocount + 1;
% handles.formulas{undocount} = formulas;
% set(handles.pushbutton_undo,'Enable','on')
% set(handles.pushbutton_redo,'Enable','off')
%
% handles.undocount = undocount;
% % Update handles structure
% %guidata(hObject, handles);
% return

%--------------------------------------------------------------------------
function pushbutton_RUN_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function button_loadlist_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function button_savelist_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function button_saveaslist_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function button_clearfile_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function checkbox_sendfile2history_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function eraser_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function button_example_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function help_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function button_recursive_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function button_no_recu_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function cancel_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        uiresume(handles.gui_chassis);
else
        % The GUI is no longer waiting, just close it
        delete(handles.gui_chassis);
end
