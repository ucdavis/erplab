%
% Author: Javier Lopez-Calderon & Steven Luck & Guanghui ZHANG
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009 & 2022

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% Copyright (C) 2008   Javier Lopez-Calderon  &  Steven Luck,
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

function varargout = f_export2textGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @f_export2textGUI_OpeningFcn, ...
    'gui_OutputFcn',  @f_export2textGUI_OutputFcn, ...
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
function f_export2textGUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for f_export2textGUI
handles.output = [];
try
    ERP = varargin{1};
catch
    ERP.erpname  = 'No erp was imported';
    ERP.nbin  =1;
    ERP.nchan = 1;
    ERP.chanlocs(1).labels = 'None';
    ERP.bindescr{1} = 'None';
    ERP.bindata = zeros(1,10,1);
end

try
    
    binArray = varargin{3};
    chanArray = varargin{4};
catch
    binArray = 1;
    chanArray = 1;
end

try
    def = varargin{2};
catch
    def = {1,1000, 1, 1, 4, 1, ''};
end

istime    = def{1};
tunit     = def{2};
islabeled = def{3};
transpa   = def{4};
prec      = def{5};
filename  = def{6};

if tunit == 1
    tunitx = 1;
else
    tunitx = 2;
end

%
% Name & version
%
erplab_studio_default_values;
version = erplabstudiover;

set(handles.gui_chassis,'Name', ['EStudio ', version, '   -   Export ERP GUI'])

[pathx, erpfilename, ext] = fileparts(filename); 
ERPFileName = char(strcat(erpfilename,'.txt'));


set(handles.edit_saveas, 'String', fullfile(pathx,ERPFileName))
% set(handles.edit_bins, 'String', vect2colon(binArray, 'Delimiter', 'off'))
set(handles.popupmenu_tunits,'String',{'seconds';'milliseconds'})
set(handles.popupmenu_tunits,'Value', tunitx)
set(handles.popupmenu_precision,'String', num2str([1:10]'))
set(handles.popupmenu_precision,'Value', prec)
set(handles.checkbox_time,'Value', istime)
set(handles.checkbox_elabels,'Value', islabeled)
set(handles.radiobutton_pr_ec,'Value', prec)

if transpa==0
    set(handles.radiobutton_pr_ec,'Value', 1)
    set(handles.radiobutton_er_pc,'Value', 0)
else
    set(handles.radiobutton_pr_ec,'Value', 0)
    set(handles.radiobutton_er_pc,'Value', 1)
end

%%----------------------Setting for bin and channels-----------------------
listb = {''};
nbin  = ERP.nbin; % Total number of bins
try
    for b=1:nbin
        listb{b}= ['BIN' num2str(b) ' = ' ERP.bindescr{b} ];
    end
catch
    listb = '';
end
handles.listb      = listb;
handles.indxlistb  = binArray;

nchan  = ERP.nchan; % Total number of channels
if ~isfield(ERP.chanlocs,'labels')
    for e=1:nchan
        ERP.chanlocs(e).labels = ['Ch' num2str(e)];
    end
end
listch = {''};
try
    for ch =1:nchan
        listch{ch} = [num2str(ch) ' = ' ERP.chanlocs(ch).labels ];
    end
catch
    listch = '';
end
handles.listch     = listch;
handles.indxlistch = chanArray;

set(handles.edit3_custom_bin,'String', vect2colon(binArray, 'Delimiter', 'off'));
set(handles.edit_custom_chan,'String', vect2colon(chanArray, 'Delimiter', 'off'));
handles.ERP = ERP;


% helpbutton

%
% Color GUI
%
handles = painterplabstudio(handles);
%
% %
% % Set font size
% %
handles = setfonterplabestudio(handles);

% Update handles structure
guidata(hObject, handles);

% help
% helpbutton

% UIWAIT makes f_export2textGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

%--------------------------------------------------------------------------
function varargout = f_export2textGUI_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);


function edit3_custom_bin_Callback(hObject, eventdata, handles)

BinString = str2num(handles.edit3_custom_bin.String);
ERP = handles.ERP;
% [chk, msgboxText] = chckbinandchan(ERP, BinString, []);
[chk, msgboxText] = f_ERP_chckbinandchan(ERP, BinString, [],1);

if chk(1)
    title = 'EStudio: f_export2text GUI for bin input!';
    errorfound(msgboxText, title);
    return;
end
% --- Executes during object creation, after setting all properties.
function edit3_custom_bin_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton7_browse_bin.
function pushbutton7_browse_bin_Callback(hObject, eventdata, handles)
listb = handles.listb;
indxlistb = handles.indxlistb;
indxlistb = indxlistb(indxlistb<=length(listb));
titlename = 'Select Bin(s)';

if get(hObject, 'Value')
    %set(handles.pushbutton_browsechan, 'Enable', 'off')
    if ~isempty(listb)
        bin = browsechanbinGUI(listb, indxlistb, titlename);
        if ~isempty(bin)
            set(handles.edit3_custom_bin, 'String', vect2colon(bin, 'Delimiter', 'off'));
            handles.indxlistb = bin;
            % Update handles structure
            guidata(hObject, handles);
        else
            disp('User selected Cancel')
            return
        end
    else
        msgboxText =  'No bin information was found';
        title = 'EStudio: f_export2text GUI for bin input';
        errorfound(msgboxText, title);
        return
    end
    
end


function edit_custom_chan_Callback(hObject, eventdata, handles)
chanString = str2num(handles.edit_custom_chan.String);
ERP = handles.ERP;

[chk, msgboxText] = f_ERP_chckbinandchan(ERP, [],chanString, 2);

if chk(2)
    title = 'EStudio: f_export2text GUI for channel input!';
    errorfound(msgboxText, title);
    return;
end


% --- Executes during object creation, after setting all properties.
function edit_custom_chan_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton8_browse_chan.
function pushbutton8_browse_chan_Callback(hObject, eventdata, handles)

listch = handles.listch;
indxlistch = handles.indxlistch;
indxlistch = indxlistch(indxlistch<=length(listch));
titlename = 'Select Channel(s)';

if get(hObject, 'Value')
    if ~isempty(listch)
        ch = browsechanbinGUI(listch, indxlistch, titlename);
        if ~isempty(ch)
            set(handles.edit_custom_chan, 'String', vect2colon(ch, 'Delimiter', 'off'));
            handles.indxlistch = ch;
            % Update handles structure
            guidata(hObject, handles);
        else
            disp('User selected Cancel')
            return
        end
    else
        msgboxText =  'No channel information was found';
        title = 'EStudio: f_export2text GUI for channel input';
        errorfound(msgboxText, title);
        return
    end
end
%--------------------------------------------------------------------------
function checkbox_time_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function checkbox_elabels_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_tunits_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_tunits_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_precision_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_precision_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)

handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
% function pushbutton_help_Callback(hObject, eventdata, handles)
% % doc pop_export2text
% web 'https://github.com/lucklab/erplab/wiki/Exporting,-Editing,-and-Importing-EVENTLISTS' -browser
%--------------------------------------------------------------------------
function pushbutton_export_Callback(hObject, eventdata, handles)

istime = get(handles.checkbox_time, 'value');
timeu  = get(handles.popupmenu_tunits, 'value');

if timeu == 1
    timeunit = 1E0;
else
    timeunit = 1E-3;
end

islabeled = get(handles.checkbox_elabels, 'value');
transpa   = get(handles.radiobutton_er_pc, 'value');
precision = get(handles.popupmenu_precision, 'value');
filename  = get(handles.edit_saveas, 'string');
% bins      = str2num(get(handles.edit_bins, 'string'));

if isempty(filename)
    msgboxText =  'You must enter a filename!';
    title = 'EStudio: f_export2text GUI empty filename';
    errorfound(msgboxText, title);
    return
end


BinArray = str2num(handles.edit3_custom_bin.String);
ERP = handles.ERP;
[chk, msgboxText] = f_ERP_chckbinandchan(ERP, BinArray, [],1);

if chk(1)
    title = 'EStudio: f_export2text GUI for bin input!';
    errorfound(msgboxText, title);
    return;
end


ChanArray = str2num(handles.edit_custom_chan.String);
[chk, msgboxText] = f_ERP_chckbinandchan(ERP, [],ChanArray, 2);

if chk(2)
    title = 'EStudio: f_export2text GUI for channel input!';
    errorfound(msgboxText, title);
    return;
end

ERP.bindata = ERP.bindata(ChanArray,:,BinArray);
ERP.nbin = numel(BinArray);
ERP.nchan = numel(ChanArray);
ERP.chanlocs = ERP.chanlocs(ChanArray);
for Numofbin = 1:numel(BinArray)
    ERP.bindescr{Numofbin}  = ERP.bindescr{BinArray(Numofbin)};
end

answer = {istime, timeunit, islabeled, transpa, precision,filename,ERP};
handles.output = answer;

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

% -------------------------------------------------------------------------
function edit_saveas_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_saveas_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_browse_Callback(hObject, eventdata, handles)

%
% Save OUTPUT file
%
ERP = handles.ERP;
prename = get(handles.edit_saveas,'String');
[fname, pathname, filterindex] = uiputfile({'*.txt';'*.dat';'*.*'},['Save "', ERP.erpname,'" as'], prename);

if isequal(fname,0)
    disp('User selected Cancel')
    return
else
    
    [px, fname2, ext] = fileparts(fname);
    
    if strcmp(ext,'')
        
        if filterindex==1 || filterindex==3
            ext   = '.txt';
        else
            ext   = '.dat';
        end
        
        fname = [ fname2 ext];
    end
    
    set(handles.edit_saveas,'String', fullfile(pathname, fname));
    disp(['To save ERP, user selected ', fullfile(pathname, fname)])
end



%--------------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
    handles.output = [];
    %Update handles structure
    guidata(hObject, handles);
    uiresume(handles.gui_chassis);
else
    % The GUI is no longer waiting, just close it
    delete(handles.gui_chassis);
end
