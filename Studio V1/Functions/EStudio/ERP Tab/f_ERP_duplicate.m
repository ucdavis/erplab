function varargout = f_ERP_duplicate(varargin)
% F_ERP_DUPLICATE MATLAB code for f_ERP_duplicate.fig
%      F_ERP_DUPLICATE, by itself, creates a new F_ERP_DUPLICATE or raises the existing
%      singleton*.
%
%      H = F_ERP_DUPLICATE returns the handle to a new F_ERP_DUPLICATE or the handle to
%      the existing singleton*.
%
%      F_ERP_DUPLICATE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in F_ERP_DUPLICATE.M with the given input arguments.
%
%      F_ERP_DUPLICATE('Property','Value',...) creates a new F_ERP_DUPLICATE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before f_ERP_duplicate_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to f_ERP_duplicate_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help f_ERP_duplicate

% Last Modified by GUIDE v2.5 24-Jun-2022 06:43:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @f_ERP_duplicate_OpeningFcn, ...
    'gui_OutputFcn',  @f_ERP_duplicate_OutputFcn, ...
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


% --- Executes just before f_ERP_duplicate is made visible.
function f_ERP_duplicate_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for f_ERP_duplicate

try
    ERP  = varargin{1};
    currenterp = varargin{2};
    binArray = varargin{3};
    chanArray = varargin{4};
catch
    ERP.erpname  = 'No erp was imported';
    ERP.nbin  =1;
    ERP.nchan = 1;
    ERP.chanlocs(1).labels = 'None';
    ERP.bindescr{1} = 'None';
    binArray = 1;
    chanArray = 1;
    currenterp = [];
    ERP.bindata = zeros(1,10,1);
end

% handles.erpnameor = ERP.erpname;
handles.output = [];
handles.ERP = ERP;

erplab_studio_default_values;
version = erplabstudiover;
set(handles.gui_chassis,'Name', ['EStudio ' version '   -   Duplicate ERPset GUI'])
set(handles.edit_erpname, 'String', ERP.erpname);

if isempty(currenterp)
    set(handles.current_erp_label,'String', ['No active erpset was found'],...
        'FontWeight','Bold', 'FontSize', 16);
else
    set(handles.current_erp_label,'String', ['Creat a new erpset # ' num2str(currenterp+1)],...
        'FontWeight','Bold', 'FontSize', 16)
end



listb = {''};
nbin  = ERP.nbin; % Total number of bins
try
    for b=1:nbin
        listb{b}= ['BIN' num2str(b) ' = ' ERP.bindescr{b} ];
    end
catch
    listb = '';
end



%%%set(handles.popupmenu_bins,'String', listb)
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

set(handles.edit6_bin,'String', vect2colon(binArray, 'Delimiter', 'off'));
set(handles.edit7_chan,'String', vect2colon(chanArray, 'Delimiter', 'off'));



% Color GUI
handles = painterplabstudio(handles);
%
% %
% % Set font size
% %
handles = setfonterplabestudio(handles);



% Update handles structure
guidata(hObject, handles);


% UIWAIT makes savemyerpGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);




% --- Outputs from this function are returned to the command line.
function varargout = f_ERP_duplicate_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
% try
%     set(handles.menuerp.Children, 'Enable','on');
% catch
%     disp('ERPset menu was not found...')
% end
varargout{1} = handles.output;
delete(handles.gui_chassis);
pause(0.1)




% --- Executes on button press in radio_erpname.
function radio_erpname_Callback(hObject, eventdata, handles)



function edit_erpname_Callback(hObject, eventdata, handles)
erpname = strtrim(get(handles.edit_erpname, 'String'));
if isempty(erpname)
    msgboxText =  'You must enter an erpname at least!';
    title = 'EStudio: Duplicate ERPset GUI - empty erpname';
    errorfound(msgboxText, title);
    return
end

% --- Executes during object creation, after setting all properties.
function edit_erpname_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit6_bin_Callback(hObject, eventdata, handles)
BinString = str2num(handles.edit6_bin.String);
ERP = handles.ERP;
% [chk, msgboxText] = chckbinandchan(ERP, BinString, []);
[chk, msgboxText] = f_ERP_chckbinandchan(ERP, BinString, [],1);

if chk(1)
    title = 'EStudio: Duplicate ERPset GUI for bin input!';
    errorfound(msgboxText, title);
    return;
end




% --- Executes during object creation, after setting all properties.
function edit6_bin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit7_chan_Callback(hObject, eventdata, handles)
chanString = str2num(handles.edit7_chan.String);
ERP = handles.ERP;
% [chk, msgboxText] = chckbinandchan(ERP, BinString, []);
[chk, msgboxText] = f_ERP_chckbinandchan(ERP, [],chanString, 2);

if chk(2)
    title = 'EStudio: Duplicate ERPset GUI for channel input!';
    errorfound(msgboxText, title);
    return;
end


% --- Executes during object creation, after setting all properties.
function edit7_chan_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_bin_browse.
function pushbutton_bin_browse_Callback(hObject, eventdata, handles)
listb = handles.listb;
indxlistb = handles.indxlistb;
indxlistb = indxlistb(indxlistb<=length(listb));
titlename = 'Select Bin(s)';

if get(hObject, 'Value')
    %set(handles.pushbutton_browsechan, 'Enable', 'off')
    if ~isempty(listb)
        bin = browsechanbinGUI(listb, indxlistb, titlename);
        if ~isempty(bin)
            set(handles.edit6_bin, 'String', vect2colon(bin, 'Delimiter', 'off'));
            handles.indxlistb = bin;
            % Update handles structure
            guidata(hObject, handles);
        else
            disp('User selected Cancel')
            return
        end
    else
        msgboxText =  'No bin information was found';
        title = 'EStudio: Duplicate ERPset GUI for bin input';
        errorfound(msgboxText, title);
        return
    end
    
end


% --- Executes on button press in pushbutton_chan_browse.
function pushbutton_chan_browse_Callback(hObject, eventdata, handles)
listch = handles.listch;
indxlistch = handles.indxlistch;
indxlistch = indxlistch(indxlistch<=length(listch));
titlename = 'Select Channel(s)';

if get(hObject, 'Value')
    if ~isempty(listch)
        ch = browsechanbinGUI(listch, indxlistch, titlename);
        if ~isempty(ch)
            set(handles.edit7_chan, 'String', vect2colon(ch, 'Delimiter', 'off'));
            handles.indxlistch = ch;
            % Update handles structure
            guidata(hObject, handles);
        else
            disp('User selected Cancel')
            return
        end
    else
        msgboxText =  'No channel information was found';
        title = 'Duplicate ERPset GUI for channel input';
        errorfound(msgboxText, title);
        return
    end
end

% --- Executes on button press in pushbutton_Cancel.
function pushbutton_Cancel_Callback(hObject, eventdata, handles)
handles.output = [];
beep;
disp('User selected Cancel')
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);


% --- Executes on button press in pushbutton4_okay.
function pushbutton4_okay_Callback(hObject, eventdata, handles)
erpname = strtrim(get(handles.edit_erpname, 'String'));

if isempty(erpname)
    msgboxText =  'You must enter an erpname at least!';
    title = 'EStudio: Duplicate ERPset GUI - empty erpname';
    errorfound(msgboxText, title);
    return
end


BinArray = str2num(handles.edit6_bin.String);
ERP = handles.ERP;
[chk, msgboxText] = f_ERP_chckbinandchan(ERP, BinArray, [],1);

if chk(1)
    title = 'EStudio: Duplicate ERPset GUI for bin input!';
    errorfound(msgboxText, title);
    return;
end


ChanArray = str2num(handles.edit7_chan.String);
% ERP = handles.ERP;
% [chk, msgboxText] = chckbinandchan(ERP, BinString, []);
[chk, msgboxText] = f_ERP_chckbinandchan(ERP, [],ChanArray, 2);

if chk(2)
    title = 'EStudio: Duplicate ERPset GUI for channel input!';
    errorfound(msgboxText, title);
    return;
end


ERP.erpname = erpname;

ERP.bindata = ERP.bindata(ChanArray,:,BinArray);
ERP.nbin = numel(BinArray);
ERP.nchan = numel(ChanArray);
ERP.chanlocs = ERP.chanlocs(ChanArray);
for Numofbin = 1:numel(BinArray)
    Bindescr{Numofbin}  = ERP.bindescr{BinArray(Numofbin)};
end
ERP.bindescr = Bindescr;

ERP.saved = 'no';
ERP.filepath = '';
handles.output = ERP;
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
