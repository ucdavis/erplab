
%  Note: very preliminary alfa version. Only for testing purpose. May  2008
%
%  HELP PENDING for this function
%  Write erplab at command window for help
%
%
% Bin Operations:
%
% The ‘Bin Operations’ function allows you to compute acceptbin bins that are linear
% combinations of the bins in the current ERP structure.  For example, you can
% average multiple bins together, and you can compute difference waves.  It operates in the same manner as Channel Operations.  That is, you create equations that look like this: “bin6 = 0.5*bin3 – 0.5*bin2”.  This is like a simplified version of the erpmanip program in ERPSS.  We will eventually create a more sophisticated version that has the same power as erpmanip.
%
% Your bins are stored in a Matlab structure named ERP, at binavg field
% (ERP.binvg). This field has 3 dimensions:
%
%    row        =   channels
%    column     =   points (signal)
%    depth      =   bin's slot (bin index).
%
% So, the depth dimension will increase as you define a acceptbin bin, correctly
% numbered (sorted).   To create a acceptbin bin you have simply to use an algebraic expression for that bin.
%
% Example:
%
% Currently you have 4 bins created, and now you need to create a acceptbin bin
% (bin 5) with the difference between bin 2 and 4. So, you should go to Bin
% Operation, at the ERPLAB menu, and this will pop up a acceptbin GUI. At the editing window enter the next simple expression:
%
% bin5 = bin2 - bin4  label Something Important
%
% and press APPEND.
%
% Note1: You can also write in a short style expression: b5 = b2 - b4.
%
% For label setting you could use : ...label Something Important  or
% ....label = Something Important
%
% If you do not define a label, binoperator will use a short expression of
% the current formula as a label,  BIN5: B2-B4
%
% In case you need to create more than one acceptbin bin, you will need to enter
% a carriage return at the end of each expression (formula) as you are writing
% a list of algebraic expressions.
%
% Example:
%
% b5 = b2 - b4   label bla-bla
% b6 = (b1+b3)/2 label= attended   or     b6 = 0.5*b1 + 0.5*b3 ...
% b7 = abs(b5)   label rectified   or     b7 = sqrt(b5^2) ...
%
% and press APPEND.
%
% Note 2: You already realized you can use bins just predefined in your list,
% so be cautious with this predefinition to avoid mistakes in long lists.
%
% Note 3: Also you can use more complex expressions as this:
% bin8 = (b1+b2)/2 - (b3+b4)/2
% or, eventually, something much weirder as this    b9 = sqrt(b2^2 + b3^2)
%
% Finally, you can save and load your formulas in order to avoid to rewrite
% it more than one time. Use EXPORT & IMPORT buttons for this,
% respectively.
%
% See pop_binoperator()
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

% Begin initialization code - DO NOT EDIT

function varargout = binoperGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @binoperGUI_OpeningFcn, ...
        'gui_OutputFcn',  @binoperGUI_OutputFcn, ...
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
function binoperGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for binoperGUI
handles.output = [];
try
        ERP = varargin{1};
        %
        % Prepare List of current Bins
        %
        listb=[];
        nbinmax = ERP.nbin;
        for b=1:nbinmax
                listb{b}= ['BIN' num2str(b) ' = ' ERP.bindescr{b} ];
        end
catch
        ERP   = [];
        listb = '';
        nbinmax = 1;
end

example{1} = 'b$ = (b1+b3)/2 label attended left';
example{2} = 'B$ = (B1+B3+B5)/3 label = attended left';
example{3} = 'bin$ = sqrt(bin1^2+bin3^2) label distance';
example{4} = 'b$ = (b1-b3)/(b1+b3) label = Special';
example{5} = 'b$ = 0.5*b1+0.5*b3 label = attended left';
example{6} = 'b$ = wavgbin(1,3) label = attended left (weighted)';
example{7} = 'BIN$ = 0.5*b1 + 0.5*b3 label attended left';
example{8} = sprintf('L=[1 3 5 7 9]\nR=[2 4 6 8 10]\nB$ = 0.5*b3@L + 0.5*b4@R label GLOBAL CONTRA');

handles.nbinmax = nbinmax;
handles.example = example;
handles.exacounter = 0;
handles.listname = [];

% Update handles structure
guidata(hObject, handles);

%
% Name & version
%
version = geterplabversion;
set(handles.figure1,'Name', ['ERPLAB ' version '   -   Bin Operation GUI'])

formulas = erpworkingmemory('binformulas');

if isempty(formulas)
        set(handles.editor,'String','');
else
        set(handles.editor, 'String', formulas)
end

label1 = '<HTML><left>Send file rather than individual equations';
label2 = '<HTML><left>(creates compact history)';
set(handles.checkbox_sendfile2history, 'string',[label1 '<br>' label2]);
set(handles.listbox_bin,'String', listb)

%
% Gui memory
%
binopGUI = erpworkingmemory('binopGUI');

if isempty(binopGUI)
        set(handles.button_recursive,'Value', 1); % default is Modify existing ERPset (recursive updating)
        set(handles.button_savelist, 'Enable','off')
        
        %
        % File List
        %
        set(handles.edit_filelist,'String','');
        set(handles.checkbox_sendfile2history,'Value',0)        
else        
        if binopGUI.emode==0
                set(handles.button_recursive,'Value', 1);
                set(handles.button_no_recu,'Value', 0);
        else
                set(handles.button_recursive,'Value', 0);
                set(handles.button_no_recu,'Value', 1);
        end
        if binopGUI.hmode==0
                set(handles.checkbox_sendfile2history,'Value', 0);
        else
                set(handles.checkbox_sendfile2history,'Value', 1);
        end
        set(handles.edit_filelist,'String', binopGUI.listname );
end

wbmsgon = erpworkingmemory('wbmsgon');

if isempty(wbmsgon) || wbmsgon==0
        set(handles.bwarning,'Value', 0)
elseif wbmsgon==1
        set(handles.bwarning,'Value', 1)
else
        error('Oops...checkbox_warning memory failed')
end

%
% Color GUI
%
handles = painterplab(handles);
drawnow
uiwait(handles.figure1);

%--------------------------------------------------------------------------
function varargout = binoperGUI_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure

varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);
pause(0.5)

%--------------------------------------------------------------------------
function editor_Callback(hObject, eventdata, handles)

compacteditor(hObject, eventdata, handles);

handles.listname = [];
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function editor_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function acceptbin_Callback(hObject, eventdata, handles)

listname = handles.listname;

compacteditor(hObject, eventdata, handles);

formulalist = get(handles.editor,'String');

if strcmp(formulalist,'')
        msgboxText =  'You have not yet written a formula!';
        title = 'ERPLAB: binoperGUI few inputs';
        errorfound(msgboxText, title);
        return
end
if size(formulalist,2)>256
        msgboxText{1} =  'Formulas length exceed 256 characters.';
        msgboxText{2} =  'Be sure to press [Enter] after you have entered each formula.';
        title = 'ERPLAB: binoperGUI few inputs';
        errorfound(msgboxText, title);
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

[option recall goeson] = checkformulas(cellstr(formulalist), 'binoperGUI', editormode);

if goeson==0
        return
end

if isempty(listname) && get(handles.checkbox_sendfile2history,'Value')==1
        
        BackERPLABcolor = [ 0.65 0.68 .6];
        question{1} = 'Equations at editor window have not been saved yet.';
        question{2} = 'What would you like to do?';
        title = 'WARNING: Save List of edited bins';
        oldcolor = get(0,'DefaultUicontrolBackgroundColor');
        set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
        button = questdlg(question, title,'Save and run','Run without saving', 'Cancel','Run without saving');
        set(0,'DefaultUicontrolBackgroundColor',oldcolor)
        
        if strcmpi(button,'Save and run')
                fullname = savelist(hObject, eventdata, handles);
                listname = fullname;
                handles.output = {listname, 1}; % sent filenam string)
        elseif strcmpi(button,'Run without saving')
                handles.output = {cellstr(formulalist), 1}; % sent like a cell string (with formulas)
        elseif strcmpi(button,'Cancel') || strcmpi(button,'')
                handles.output   = [];
                handles.listname = [];
                % Update handles structure
                guidata(hObject, handles);
                return
        end
        
elseif isempty(listname) && get(handles.checkbox_sendfile2history,'Value')==0
        handles.output = {cellstr(formulalist), 1}; % sent like a cell string (with formulas)
        
elseif ~isempty(listname) && get(handles.checkbox_sendfile2history,'Value')==1
        handles.output = {listname, 1}; % sent filename string
        
elseif ~isempty(listname) && get(handles.checkbox_sendfile2history,'Value')==0
        handles.output = {cellstr(formulalist), 1}; % sent like a cell string (with formulas)
end

erpworkingmemory('binformulas', formulalist);

%
% memory for Gui
%
binopGUI.emode = editormode;
binopGUI.hmode = get(handles.checkbox_sendfile2history,'Value');
binopGUI.listname  = listname;

erpworkingmemory('binopGUI', binopGUI);

% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);

%--------------------------------------------------------------------------
function cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);

%--------------------------------------------------------------------------
function eraser_Callback(hObject, eventdata, handles)
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
help pop_binoperator

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
function button_saveaslist_Callback(hObject, eventdata, handles)

compacteditor(hObject, eventdata, handles);

fulltext = strtrim(get(handles.editor,'String'));

if size(fulltext,2)>256
        msgboxText{1} =  'Formulas length exceed 256 characters.';
        msgboxText{2} =  'Be sure to press [Enter] after you have entered each formula.';
        title = 'ERPLAB: binoperGUI few inputs';
        errorfound(msgboxText, title);
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
        msgboxText =  'You have not yet written a formula!';
        title = 'ERPLAB: binoperGUI few inputs';
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
        disp(['pop_binoperation(): For formulas-file, user selected ', fullname])
end

set(handles.edit_filelist,'String',fullname);

fid_formula = fopen( fullname );
try
        formcell    = textscan(fid_formula, '%s','delimiter', '\r');
        formulas    = char(formcell{:});
catch
        serr = lasterror;
        msgboxText{1} =  'Please, check your file: ';
        msgboxText{2} =  fullname;
        msgboxText{3} =  serr.message;
        title = 'ERPLAB: pop_binoperation() error:';
        errorfound(msgboxText, title);
        return
end

if size(formulas,2)>256
        msgboxText{1} =  'Formulas length exceed 256 characters.';
        msgboxText{2} =  'Be sure to press [Enter] after you have entered each formula.';
        title = 'ERPLAB: binoperGUI few inputs';
        errorfound(msgboxText, title);
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
function listbox_bin_Callback(hObject, eventdata, handles)

numbin   = get(hObject, 'Value');

if isempty(numbin)
        return
end

linet    = get(handles.editor, 'Value');

if linet == 0
        linet = 1;
end

formulas = cellstr(get(handles.editor, 'String'));
formulas{linet} = [formulas{linet} 'b' num2str(numbin)];
set(handles.editor, 'String', char(formulas));

%--------------------------------------------------------------------------
function listbox_bin_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function button_example_Callback(hObject, eventdata, handles)

nbinmax    = handles.nbinmax;
example    = handles.example;
exacounter = handles.exacounter;
exacounter = exacounter + 1;

if get(handles.button_no_recu,'Value')
        prechar = 'n';
else
        prechar = '';
end

text = cellstr(get(handles.editor, 'String'));

if isempty([text{:}]) || exacounter>length(example)
        exacounter = 1;
end

if length(text)==1 && strcmp(text{1}, '')
        exacurr = char(regexprep(example{exacounter},'\$',num2str(nbinmax+exacounter)));
        text{1} = [prechar exacurr];
else
        exacurr = char(regexprep(example{exacounter},'\$',num2str(nbinmax+exacounter)));
        text{end+1} = [prechar exacurr];
end

set(handles.editor, 'String', char(text));
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
        [px, fname, ext, versn] = fileparts(filename);
        
        if strcmp(ext,'')
                
                if filterindex==1 || filterindex==3
                        ext   = '.txt';
                else
                        ext   = '.dat';
                end
        end
        
        fname    = [ fname ext];
        fullname = fullfile(filepath, fname);
        fid_list = fopen( fullname , 'w');
        
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
        msgboxText{1} =  'Formulas length exceed 256 characters.';
        msgboxText{2} =  'Be sure to press [Enter] after you have entered each formula.';
        title = 'ERPLAB: binoperGUI few inputs';
        errorfound(msgboxText, title);
        return
end

if ~strcmp(fulltext,'')
        
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
        msgboxText =  'You have not yet written a formula!';
        title = 'ERPLAB: binoperGUI few inputs';
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

if  get(hObject,'Value')==0
        set(hObject,'Value',1)
else
        set(handles.button_no_recu,'Value',0)
end

%--------------------------------------------------------------------------
function button_no_recu_Callback(hObject, eventdata, handles)

if  get(hObject,'Value')==0
        set(hObject,'Value',1)
else
        set(handles.button_recursive,'Value',0)
end

%--------------------------------------------------------------------------
function bwarning_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
        %
        % Gui memory
        %
        erpworkingmemory('wbmsgon', 1);
else
        %
        % Gui memory
        %
        erpworkingmemory('wbmsgon', 0);
end

%--------------------------------------------------------------------------
function bwarning_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function cancel_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function acceptbin_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function panel1_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function button_example_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function eraser_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function help_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function button_loadlist_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function button_savelist_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function button_saveaslist_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function button_clearfile_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function button_recursive_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function button_no_recu_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function checkbox_sendfile2history_CreateFcn(hObject, eventdata, handles)
