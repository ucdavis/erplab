function varargout = f_EEG_duplicate_GUI(varargin)
% F_EEG_DUPLICATE_GUI MATLAB code for f_EEG_duplicate_GUI.fig
%      F_EEG_DUPLICATE_GUI, by itself, creates a new F_EEG_DUPLICATE_GUI or raises the existing
%      singleton*.
%
%      H = F_EEG_DUPLICATE_GUI returns the handle to a new F_EEG_DUPLICATE_GUI or the handle to
%      the existing singleton*.
%
%      F_EEG_DUPLICATE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in F_EEG_DUPLICATE_GUI.M with the given input arguments.
%
%      F_EEG_DUPLICATE_GUI('Property','Value',...) creates a new F_EEG_DUPLICATE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before f_EEG_duplicate_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to f_EEG_duplicate_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help f_EEG_duplicate_GUI

% Last Modified by GUIDE v2.5 14-Aug-2023 08:24:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @f_EEG_duplicate_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @f_EEG_duplicate_GUI_OutputFcn, ...
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


% --- Executes just before f_EEG_duplicate_GUI is made visible.
function f_EEG_duplicate_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for f_EEG_duplicate_GUI

try
    EEG  = varargin{1};
    currentset = varargin{2};
    chanArray = varargin{3};
catch
    EEG.setname  = 'No erp was imported';
    EEG.nbchan = 1;
    EEG.chanlocs(1).labels = 'None';
    chanArray = 1;
    currentset = [];
    EEG.data = zeros(1,10,1);
end

% handles.erpnameor = ERP.erpname;
handles.output = [];
handles.EEG = EEG;

erplab_studio_default_values;
version = erplabstudiover;
set(handles.gui_chassis,'Name', ['EStudio ' version '   -   Duplicate EEGset GUI'])
set(handles.edit_erpname, 'String', EEG.setname);

if isempty(currentset)
    set(handles.current_erp_label,'String', ['No active eegset was found'],...
        'FontWeight','Bold', 'FontSize', 16);
else
    set(handles.current_erp_label,'String', ['Creat a new eegset # ' num2str(currentset+1)],...
        'FontWeight','Bold', 'FontSize', 16)
end

nchan  = EEG.nbchan; % Total number of channels
if ~isfield(EEG.chanlocs,'labels')
    for e=1:nchan
        EEG.chanlocs(e).labels = ['Ch' num2str(e)];
    end
end
listch = {''};
try
    for ch =1:nchan
        listch{ch} = [num2str(ch) ' = ' EEG.chanlocs(ch).labels ];
    end
catch
    listch = '';
end
handles.listch     = listch;
handles.indxlistch = chanArray;
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
function varargout = f_EEG_duplicate_GUI_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
% try
%     set(handles.menuerp.Children, 'Enable','on');
% catch
%     disp('EEGset menu was not found...')
% end
varargout{1} = handles.output;
delete(handles.gui_chassis);
pause(0.1)




% --- Executes on button press in radio_erpname.
function radio_erpname_Callback(hObject, eventdata, handles)



function edit_erpname_Callback(hObject, eventdata, handles)
eegname = strtrim(get(handles.edit_erpname, 'String'));
if isempty(eegname)
    msgboxText =  'You must enter an eegname at least!';
    title = 'EStudio: Duplicate EEGset GUI - empty eegname';
    errorfound(msgboxText, title);
    return
end

% --- Executes during object creation, after setting all properties.
function edit_erpname_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function edit7_chan_Callback(hObject, eventdata, handles)
chanString = str2num(handles.edit7_chan.String);
EEG = handles.EEG;
msgboxText = f_EEG_chck_chan(EEG, chanString);

if ~isempty(msgboxText);
    title = 'EStudio: Duplicate EEGset GUI for channel input!';
    errorfound(msgboxText, title);
    return;
end


% --- Executes during object creation, after setting all properties.
function edit7_chan_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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
        title = 'Duplicate EEGset GUI for channel input';
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
EEG = handles.EEG;
eegname = strtrim(get(handles.edit_erpname, 'String'));
if isempty(eegname)
    msgboxText =  'You must enter an eegname at least!';
    title = 'EStudio: Duplicate EEGset GUI - eegname';
    errorfound(msgboxText, title);
    return
end
EEG.setname = eegname;

ChanArray = str2num(handles.edit7_chan.String);
if isempty(ChanArray) || min(ChanArray(:)) > EEG.nbchan || max(ChanArray(:)) > EEG.nbchan
    ChanArray = 1:EEG.nbchan;
end
msgboxText = f_EEG_chck_chan(EEG, ChanArray);
if  ~isempty(msgboxText)
    title = 'EStudio: Duplicate EEGset GUI for channel input!';
    errorfound(msgboxText, title);
    return;
end

EEG.saved = 'no';
EEG.filepath = '';
chanDelete = setdiff([1:EEG.nbchan],ChanArray);
if ~isempty(chanDelete)
    count = 0;
    for ii = chanDelete
        count = count+1;
        ChanArrayStr{count}   = EEG.chanlocs(ii).labels;
    end
    EEG = pop_select( EEG, 'rmchannel', ChanArrayStr);
    EEG = eeg_checkset(EEG);
end

handles.output = EEG;
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



function  msgboxText = f_EEG_chck_chan(EEG, chanArray)
msgboxText = '';


if isempty(chanArray)
    msgboxText =  'You have not specified any channel';
    return
end
if any(chanArray<=0)
    msgboxText =  sprintf('Invalid channel index.\n Please specify only positive integer values.');
    return
end
if any(chanArray>EEG.nbchan)
    msgboxText =  sprintf(['Channel index out of range!\nYou only have %g channels in this EEGset']);
    return
end
if length(chanArray)~=length(unique_bc2(chanArray))
    msgboxText = 'You have specified repeated channels.';
    return
end
return;
