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

function varargout = menuBinListGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @menuBinListGUI_OpeningFcn, ...
        'gui_OutputFcn',  @menuBinListGUI_OutputFcn, ...
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
function menuBinListGUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = [];
handles.owfp = 0;  % over write file permission

try
        ERPLAB1 = varargin{1};
        ERPLAB2 = varargin{2};
catch
        ERPLAB1 = [];
        ERPLAB2 = [];
end

% {file1, file2, file3, flagrst, forbiddenCodeArray, updevent, option2do, reportable});

try
        def = varargin{3};
catch
        def = {'' '' '' 0 [] [] 1 0 0 1 0};
end

handles.ERPLAB1 = ERPLAB1;
handles.ERPLAB2 = ERPLAB2;
handles.def = def;

% Update handles structure
guidata(hObject, handles);
setall(hObject, eventdata, handles)

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

uiwait(handles.gui_chassis);

%--------------------------------------------------------------------------
function varargout = menuBinListGUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

%--------------------------------------------------------------------------
function pushbutton_help_Callback(hObject, eventdata, handles)
% doc pop_binlister
web https://github.com/lucklab/erplab/wiki/Assigning-Events-to-Bins-with-BINLISTER -browser

%--------------------------------------------------------------------------
function edit_load_BDF_Callback(hObject, eventdata, handles)
if isempty(get(hObject,'String'))
        set(handles.pushbutton_tal_bdf, 'Enable', 'off')
else
        set(handles.pushbutton_tal_bdf, 'Enable', 'on')
end

%--------------------------------------------------------------------------
function edit_load_BDF_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_load_EL_Callback(hObject, eventdata, handles)
if isempty(get(hObject,'String'))
        set(handles.pushbutton_tal_EL, 'Enable','off')
else
        set(handles.pushbutton_tal_EL, 'Enable','on')
end

%--------------------------------------------------------------------------
function edit_load_EL_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_browse_BDF_Callback(hObject, eventdata, handles)
try
        pre_patha = get(handles.edit_load_BDF, 'String');
        [pre_pathb, nameq, extq] = fileparts(pre_patha);
        
        [bdfilename,bdfpathname] = uigetfile({'*.txt';'*.*'},'Select a Bin Descriptor File (BDF)', pre_pathb);
catch
        [bdfilename,bdfpathname] = uigetfile({'*.txt';'*.*'},'Select a Bin Descriptor File (BDF)');
end
if isequal(bdfilename,0)
        disp('User selected Cancel')
        return
else
        set(handles.pushbutton_tal_bdf, 'Enable', 'on')
        handle.bdfilename  = bdfilename;
        handle.bdfpathname = bdfpathname;
        set(handles.edit_load_BDF, 'String', fullfile(bdfpathname, bdfilename));
        
        % Update handles structure
        guidata(hObject, handles);
        
        flinkname = fullfile(bdfpathname, bdfilename);
        disp(['For Bin Descriptor file (BDF), user selected <a href="matlab: open(''' flinkname ''')">' flinkname '</a>'])
end

%--------------------------------------------------------------------------
function pushbutton_tal_bdf_Callback(hObject, eventdata, handles)
fname =  get(handles.edit_load_BDF, 'String');
if exist(fname,'file')==2
        uiopen(fname,1);
else
        msgboxText =  'File does not exist!'
        title = 'ERPLAB: input error';
        errorfound(sprintf(msgboxText), title);
        return
end

%--------------------------------------------------------------------------
function pushbutton_browse_EL_Callback(hObject, eventdata, handles)
%
% Load log file
%
try
        pre_patha = get(handles.edit_load_EL, 'String');
        [pre_pathb, nameq, extq] = fileparts(pre_patha);
        
        [logfilename,logpathname] = uigetfile({'*.txt';'*.*'},'Select a EVENTLIST text file (ex LOG file)', pre_pathb);
catch
        [logfilename,logpathname] = uigetfile({'*.txt';'*.*'},'Select a EVENTLIST text file (ex LOG file)');
end
if isequal(logfilename,0)
        disp('User selected Cancel')
        return
else
        set(handles.pushbutton_tal_EL, 'Enable', 'on')
        handle.logfilename  = logfilename;
        handle.logpathname  = logpathname;
        set(handles.edit_load_EL,'String', fullfile(logpathname, logfilename));
        
        % Update handles structure
        guidata(hObject, handles);
        
        flinkname = fullfile(logpathname, logfilename);
        disp(['For input EventList file, user selected <a href="matlab: open(''' flinkname ''')">' flinkname '</a>'])
end

%--------------------------------------------------------------------------
function pushbutton_tal_EL_Callback(hObject, eventdata, handles)
fname =  get(handles.edit_load_EL, 'String');
if exist(fname,'file')==2
        uiopen(fname,1);
else
        msgboxText =  'File does not exist!'
        title = 'ERPLAB: input error';
        errorfound(sprintf(msgboxText), title);
        return
end

%--------------------------------------------------------------------------
function pushbutton_browse_save_BL_Callback(hObject, eventdata, handles)

%
% Save BINLIST file
%
try
        prename = get(handles.edit_save_BL,'String');
        [blfilename, blpathname] = uiputfile({'*.txt';'*.*'},'Save EVENTLIST text file as',prename);
catch
        [blfilename, blpathname] = uiputfile({'*.txt';'*.*'},'Save EVENTLIST text file as');
end
if isequal(blfilename,0)
        disp('User selected Cancel')
        handles.owfp = 0;  % over write file permission
        guidata(hObject, handles);
        return
else
        handle.blfilename  = blfilename;
        handle.blpathname  = blpathname;
        set(handles.edit_save_BL,'String', fullfile(blpathname, blfilename));
        handles.owfp     = 1;  % over write file permission
        
        % Update handles structure
        guidata(hObject, handles);
        disp(['For BINLIST, user selected ', fullfile(blpathname, blfilename)])
end

%--------------------------------------------------------------------------
function listbox1_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function listbox1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu1_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_forbidden_ec_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_forbidden_ec_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function listbox3_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function listbox3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function checkbox_AR_reset_flags_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton_run_Callback(hObject, eventdata, handles)

% From :
button_fromcurrentdata = get(handles.radiobutton_fromcurrentdata,'Value');
button_fromcurrentERP  = get(handles.radiobutton_fromcurrentERP,'Value');
button_fromtext        = get(handles.radiobutton_fromtext,'Value');

% To :
button_tocurrentdata   = get(handles.radiobutton_tocurrentdata,'Value');
button_toworkspace     = get(handles.checkbox_toworkspace,'Value');
button_totext          = get(handles.radiobutton_totext,'Value');
% File names

%
% bin descriptormfile: input
%
bdfile  = char(get(handles.edit_load_BDF,'String'));
if isempty(bdfile)
        msgboxText = 'You must specify a bin descriptor file';
        title = 'ERPLAB: missing input';
        errorfound(msgboxText, title);
        return
end

%
% Event list file: input
%
evfile  = char(get(handles.edit_load_EL,'String'));
if isempty(evfile) && button_fromtext
        msgboxText =  'You must specify an EventList file as an input';
        title = 'ERPLAB: missing input';
        errorfound(msgboxText, title);
        return
end

%
% Event list file: output
%
blfile  = char(get(handles.edit_save_BL,'String'));
if isempty(blfile) && button_totext
        msgboxText =  'You must specify an EventList file as an output!';
        title = 'ERPLAB: missing input';
        errorfound(msgboxText, title);
        return
end

indexEL = get(handles.popupmenu_indexEL,'Value'); % in case of multiple EVENTLIST (only for Erpset)

if button_fromcurrentERP
        getfromerp =1;
else
        getfromerp =0;
        indexEL = 1; % only a single EVENTLIST is allowed for EEG data
end
if ~isempty(blfile)
        [blfilepath, blfile, extbf] = fileparts(blfile);
        
        if ~strcmp(extbf,'.txt')
                extbf   = '.txt';
        end
        
        blfile = fullfile(blfilepath,[blfile extbf]);
else
        blfile = '';
end

owfp = handles.owfp;  % over write file permission

if exist(blfile, 'file')~=0 && owfp==0 && get(handles.radiobutton_totext,'Value')
        question = [blfile ' already exist!\n\n'...
                'Do you want to replace it?'];
        title    = 'ERPLAB: Overwriting Confirmation';
        button   = askquest(sprintf(question), title);
        
        if ~strcmpi(button, 'yes')
                return
        end
end

[pathstrbdf] = fileparts(bdfile);
[pathstrevf] = fileparts(evfile);
[pathstrblf] = fileparts(blfile);

if isempty(pathstrbdf)
        bdfile = fullfile(cd, bdfile); % complete bdf path
end
if isempty(pathstrblf) && button_totext
        blfile = fullfile(cd, blfile); % complete output eventlist path (ex binlist)
end
if isempty(pathstrevf) && button_fromtext
        evfile = fullfile(cd, evfile); % complete input eventlist path
end

ARflagrst = get(handles.checkbox_AR_reset_flags,  'Value'); % Artifact Flags reset button
USflagrst = get(handles.checkbox_USER_reset_flags,'Value'); % User Flags reset button

if ARflagrst==0 && USflagrst==0
        flagrst = 0; % no reset
elseif ARflagrst==1 && USflagrst==0
        flagrst = 1; % reset Artifact Flags
elseif ARflagrst==0 && USflagrst==1
        flagrst = 2; % reset User Flags
elseif ARflagrst==1 && USflagrst==1
        flagrst = 3; % reset ALL Flags
end

forbiddencodes = str2num(get(handles.edit_forbidden_ec,'String'));
ignorecodes    = str2num(get(handles.edit_ignored_ec,'String'));
updateeeg      = get(handles.checkbox_update_eegevent,'Value');

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


% if button_toworkspace && ~button_tocurrentdata
%         option2do = 1;  % send EVENTLIST to workspace
% elseif button_toworkspace && button_tocurrentdata
%         option2do = 2;  % append to EEG and send EVENTLIST to workspace
% elseif ~button_toworkspace && button_tocurrentdata
%         option2do = 0;  % append to EEG
% else
%         option2do = 3 ; % ?  just export EVENTLIS to text
% end

% reportx   = get(handles.checkbox_report,'Value');
reportx   = 0;
iswarning = get(handles.ELwarning,'Value');
filestr   = {bdfile, evfile, blfile, flagrst, forbiddencodes, ignorecodes, updateeeg, option2do, reportx, iswarning, getfromerp, indexEL};
handles.output = filestr;

% set(handles.text_wait_message, 'ForegroundColor', [1 0 0], 'FontSize' ,12, ...
%         'String', 'Processing bin capturing....please wait.')

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = '';
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function edit_ignored_ec_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_ignored_ec_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function checkbox_update_eegevent_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function checkbox3_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function radiobutton_fromcurrentdata_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.radiobutton_fromtext, 'value', 0 )
        set(handles.radiobutton_fromcurrentERP, 'value', 0 )
        set(handles.edit_load_EL, 'String', '')
        set(handles.edit_load_EL, 'Enable', 'off')
        set(handles.pushbutton_browse_EL, 'Enable','off')
        set(handles.popupmenu_indexEL, 'Enable','off')
        set(handles.pushbutton_tal_EL, 'Enable','off')
        
else
        set(hObject,'Value',1)
end

%--------------------------------------------------------------------------
function radiobutton_fromcurrentERP_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.radiobutton_fromcurrentdata, 'value', 0 )
        set(handles.radiobutton_fromtext, 'value', 0 )
        set(handles.edit_load_EL, 'String', '')
        set(handles.edit_load_EL, 'Enable', 'off')
        set(handles.pushbutton_browse_EL, 'Enable','off')
        set(handles.popupmenu_indexEL, 'Enable','on')
        set(handles.pushbutton_tal_EL, 'Enable','off')
        
else
        set(hObject,'Value',1)
end

%--------------------------------------------------------------------------
function radiobutton_fromtext_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.radiobutton_fromcurrentdata, 'value', 0 )
        set(handles.radiobutton_fromcurrentERP, 'value', 0 )
        set(handles.edit_load_EL, 'Enable','on')
        set(handles.pushbutton_browse_EL, 'Enable','on')
        set(handles.popupmenu_indexEL, 'Enable','off')
        
        if isempty(get(handles.edit_load_EL, 'String'))
                set(handles.pushbutton_tal_EL, 'Enable','off')
        else
                set(handles.pushbutton_tal_EL, 'Enable','on')
        end
else
        set(hObject,'Value',1)
end

%--------------------------------------------------------------------------
function radiobutton3_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_save_BL_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_save_BL_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton6_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function radiobutton_totext_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        %set(handles.checkbox_report, 'Enable','on')
        set(handles.pushbutton_browse_save_BL, 'Enable','on')
        set(handles.edit_save_BL, 'Enable','on')
else
        if ~get(handles.radiobutton_tocurrentdata, 'Value') && ~get(handles.checkbox_toworkspace, 'Value')
                set(handles.radiobutton_totext, 'Value', 1)
        else
                %set(handles.checkbox_report, 'Value', 0)
                %set(handles.checkbox_report, 'Enable','off')
                set(handles.pushbutton_browse_save_BL, 'Enable','off')
                set(handles.edit_save_BL, 'String','')
                set(handles.edit_save_BL, 'Enable','off')
        end
end

%--------------------------------------------------------------------------
function checkbox_toworkspace_Callback(hObject, eventdata, handles)
if ~get(hObject,'Value')
        if ~get(handles.radiobutton_totext, 'Value') && ~get(handles.radiobutton_tocurrentdata, 'Value')
                set(handles.checkbox_toworkspace, 'Value', 1)
        end
end

%--------------------------------------------------------------------------
function radiobutton_tocurrentdata_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.checkbox_update_eegevent, 'Enable','on')
        set(handles.ELwarning, 'Enable','on')
else
        if ~get(handles.radiobutton_totext, 'Value') && ~get(handles.checkbox_toworkspace, 'Value')
                set(handles.radiobutton_tocurrentdata, 'Value', 1)
        else
                set(handles.checkbox_update_eegevent, 'Enable','off')
                set(handles.ELwarning, 'Enable','off')
        end
end

%--------------------------------------------------------------------------
% function checkbox_report_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function ELwarning_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function checkbox_USER_reset_flags_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function setall(hObject, eventdata, handles)
ERPLAB1 = handles.ERPLAB1;
ERPLAB2 = handles.ERPLAB2;

if isfield(ERPLAB2, 'EVENTLIST')
        nEVL = length(ERPLAB2.EVENTLIST);
        if nEVL~=0
                set(handles.popupmenu_indexEL, 'String', {1:nEVL})
                set(handles.popupmenu_indexEL, 'Value', nEVL)
        end
end

def        = handles.def;
file1      = def{1};
file2      = def{2};
file3      = def{3};
flagrst    = def{4};      %1 means reset flags
forbiddenCodeArray = def{5};
ignoreCodeArray    = def{6};
updevent   = def{7};
option2do  = def{8};      % see below
reportable = def{9};      % 1 means create a report about binlister work.
iswarning  = def{10};

if exist(file1, 'file')==2
        set(handles.edit_load_BDF, 'String', file1)
else
        set(handles.pushbutton_tal_bdf, 'Enable', 'off')
end
erpok = 1;
%
% FROM
%

% from Dataset
if iseegstruct(ERPLAB1) && isfield(ERPLAB1, 'EVENTLIST')
        currdatastr = ['<html>Current dataset  :<i>' ERPLAB1.setname '</i>'];
        if isempty(ERPLAB1.epoch) % continuous
                set(handles.radiobutton_fromcurrentdata, 'String', currdatastr )
                set(handles.radiobutton_tocurrentdata, 'String', currdatastr)
                set(handles.checkbox_update_eegevent, 'Enable', 'on')
                datatype = 1; % continuous
        else % epoched
                set(handles.radiobutton_fromcurrentdata, 'String', currdatastr )
                set(handles.radiobutton_tocurrentdata, 'String', 'Current dataset : not allowed in epoched data')
                datatype = 2; % epoched
        end
elseif iseegstruct(ERPLAB1) && ~isfield(ERPLAB1, 'EVENTLIST')
        set(handles.radiobutton_tocurrentdata, 'String', 'Current dataset : EVENTLIST was not found')
        set(handles.radiobutton_tocurrentdata, 'Enable', 'off')
        set(handles.radiobutton_fromcurrentdata, 'String', 'Current dataset : EVENTLIST was not found' )
        set(handles.radiobutton_fromcurrentdata, 'Value', 0 )
        set(handles.radiobutton_fromcurrentdata, 'Enable', 'off')
        set(handles.checkbox_update_eegevent, 'Value',0)
        set(handles.checkbox_update_eegevent, 'Enable', 'off')
        datatype = 0; % no data
else  % no dataset has been loaded yet...
        set(handles.radiobutton_tocurrentdata, 'String', 'No data')
        set(handles.radiobutton_tocurrentdata, 'Enable', 'off')
        set(handles.radiobutton_fromcurrentdata, 'Value', 0 )
        set(handles.radiobutton_fromcurrentdata, 'String', 'No data' )
        set(handles.radiobutton_fromcurrentdata, 'Enable', 'off')
        set(handles.checkbox_update_eegevent, 'Value',0)
        set(handles.checkbox_update_eegevent, 'Enable', 'off')
        datatype = 0; % no data
end

% from ERPset
if iserpstruct(ERPLAB2) && isfield(ERPLAB2, 'EVENTLIST') && ~isempty(ERPLAB2.EVENTLIST)
        currdatastr = ['<html>Current ERPset  :<i>' ERPLAB2.erpname '</i>'];
        set(handles.radiobutton_fromcurrentERP, 'String', currdatastr )
elseif iserpstruct(ERPLAB2) && isfield(ERPLAB2, 'EVENTLIST') && isempty(ERPLAB2.EVENTLIST)
        set(handles.radiobutton_fromcurrentERP, 'String', 'Current ERPset : EVENTLIST is empty' )
        set(handles.radiobutton_fromcurrentERP, 'Value', 0 )
        set(handles.radiobutton_fromcurrentERP, 'Enable', 'off')
        set(handles.popupmenu_indexEL, 'Enable','off')
        set(handles.text_indexEL, 'Enable','off')
        erpok = 0;
elseif iseegstruct(ERPLAB2) && ~isfield(ERPLAB2, 'EVENTLIST')
        set(handles.radiobutton_fromcurrentERP, 'String', 'Current ERPset : EVENTLIST was not found' )
        set(handles.radiobutton_fromcurrentERP, 'Value', 0 )
        set(handles.radiobutton_fromcurrentERP, 'Enable', 'off')
        set(handles.popupmenu_indexEL, 'Enable','off')
        set(handles.text_indexEL, 'Enable','off')
        erpok = 0;
else  % no erpset has been loaded yet...
        set(handles.radiobutton_fromcurrentERP, 'Value', 0 )
        set(handles.radiobutton_fromcurrentERP, 'String', 'No ERPset' )
        set(handles.radiobutton_fromcurrentERP, 'Enable', 'off')
        set(handles.popupmenu_indexEL, 'Enable','off')
        set(handles.text_indexEL, 'Enable','off')
        erpok = 0;
end

% from Text
if isempty(file2) || strcmpi(file2, 'no') || strcmpi(file2, 'none')  % Read EVENTLIST from
        if datatype==1
                set(handles.radiobutton_fromcurrentdata, 'Value', 1)
                set(handles.radiobutton_fromtext, 'Value', 0)
                set(handles.pushbutton_browse_EL, 'Enable','off')
                set(handles.edit_load_EL, 'Enable','off')
                
                set(handles.pushbutton_tal_EL, 'Enable','off')
                
                
                
                set(handles.popupmenu_indexEL, 'Enable','off')
        elseif datatype==2
                set(handles.radiobutton_fromcurrentdata, 'Value', 1)
                set(handles.pushbutton_browse_EL, 'Enable','off')
                set(handles.edit_load_EL, 'Enable','off')
                set(handles.pushbutton_tal_EL, 'Enable','off')
                
                set(handles.popupmenu_indexEL, 'Enable','off')
        else
                if erpok==0
                        set(handles.radiobutton_fromtext, 'Value', 1)
                        set(handles.pushbutton_browse_EL, 'Enable','on')
                        set(handles.edit_load_EL, 'Enable','on')
                        set(handles.pushbutton_tal_EL, 'Enable','off')
                        
                        set(handles.popupmenu_indexEL, 'Enable','off')
                else
                        set(handles.radiobutton_fromcurrentERP, 'Value', 1 )
                        set(handles.popupmenu_indexEL, 'Enable','on')
                end
        end
        set(handles.edit_load_EL, 'String', '')
else
        set(handles.radiobutton_fromcurrentdata, 'Value', 0)
        set(handles.radiobutton_fromtext, 'Value', 1)
        set(handles.pushbutton_browse_EL, 'Enable','on')
        set(handles.edit_load_EL, 'String', file2)
        set(handles.pushbutton_tal_EL, 'Enable','on')
        set(handles.popupmenu_indexEL, 'Enable','off')
end

%
% TO
%
if isempty(file3) || strcmpi(file3, 'no') || strcmpi(file3, 'none') % Write resulting EVENTLIST to
        set(handles.radiobutton_totext, 'Value', 0)
        set(handles.edit_save_BL, 'Enable', 'off')
        set(handles.pushbutton_browse_save_BL, 'Enable','off')
        %set(handles.checkbox_report, 'Value',0)
        %set(handles.checkbox_report, 'Enable','off')
        set(handles.edit_save_BL, 'String', '')
else
        set(handles.edit_save_BL, 'Enable', 'on')
        set(handles.pushbutton_browse_save_BL, 'Enable','on')
        set(handles.edit_save_BL, 'String', file3)
        if reportable==1
                %set(handles.checkbox_report, 'Enable','on')
                %set(handles.checkbox_report, 'Value',1)
        else
                %set(handles.checkbox_report, 'Value',0)
                %set(handles.checkbox_report, 'Enable','off')
        end
end
if ismember_bc2(option2do, [0 2 3 6 7]) && datatype~=0 && datatype~=2 % EEG
        set(handles.radiobutton_tocurrentdata, 'Enable','on')
        set(handles.radiobutton_tocurrentdata, 'Value',1)
        set(handles.checkbox_update_eegevent, 'Value', updevent)
        set(handles.ELwarning, 'Value', iswarning)
elseif ~ismember_bc2(option2do, [0 2 3 6 7]) && datatype~=0 && datatype~=2 % EEG
        set(handles.radiobutton_tocurrentdata, 'Enable','on')
        set(handles.radiobutton_tocurrentdata, 'Value',0)
        set(handles.checkbox_update_eegevent, 'Value', 0)
        set(handles.ELwarning, 'Value', 0)
        set(handles.checkbox_update_eegevent, 'Enable','off')
        set(handles.ELwarning, 'Enable','off')
else
        set(handles.radiobutton_tocurrentdata, 'Value',0)
        set(handles.radiobutton_tocurrentdata, 'Enable','off')
        set(handles.checkbox_update_eegevent, 'Value', 0)
        set(handles.ELwarning, 'Value', 0)
        set(handles.checkbox_update_eegevent, 'Enable','off')
        set(handles.ELwarning, 'Enable','off')
end
if ismember_bc2(option2do, [1 3 5 7]) && (~isempty(file3) && ~strcmpi(file3, 'no') && ~strcmpi(file3, 'none'))% Text
        set(handles.radiobutton_totext, 'Value',1)
end
if ismember_bc2(option2do, [4 5 6 7]) % Workspace
        set(handles.checkbox_toworkspace, 'Value',1)
end
set(handles.edit_forbidden_ec, 'String', vect2colon(forbiddenCodeArray, 'Delimiter', 'off'))
set(handles.edit_ignored_ec, 'String', vect2colon(ignoreCodeArray, 'Delimiter', 'off') )
switch flagrst
        case 1
                set(handles.checkbox_AR_reset_flags, 'Value', 1)
                set(handles.checkbox_USER_reset_flags, 'Value', 0)
        case 2
                set(handles.checkbox_AR_reset_flags, 'Value', 0)
                set(handles.checkbox_USER_reset_flags, 'Value', 1)
        case 3
                set(handles.checkbox_AR_reset_flags, 'Value', 1)
                set(handles.checkbox_USER_reset_flags, 'Value', 1)
        otherwise
                set(handles.checkbox_AR_reset_flags, 'Value', 0)
                set(handles.checkbox_USER_reset_flags, 'Value', 0)
end

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   BINLISTER GUI'])
BackERPLABcolor = [ 0.83 0.82 .78];    % ERPLAB main window background
set(handles.gui_chassis,'Color', BackERPLABcolor)

%--------------------------------------------------------------------------
function popupmenu_indexEL_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_indexEL_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
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
