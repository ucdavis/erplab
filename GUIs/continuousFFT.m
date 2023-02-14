function varargout = continuousFFT(varargin)
% CONTINUOUSFFT MATLAB code for continuousFFT.fig
%      CONTINUOUSFFT, by itself, creates a new CONTINUOUSFFT or raises the existing
%      singleton*.
%
%      H = CONTINUOUSFFT returns the handle to a new CONTINUOUSFFT or the handle to
%      the existing singleton*.
%
%      CONTINUOUSFFT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONTINUOUSFFT.M with the given input arguments.
%
%      CONTINUOUSFFT('Property','Value',...) creates a new CONTINUOUSFFT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before continuousFFT_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to continuousFFT_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help continuousFFT

% Last Modified by GUIDE v2.5 13-Feb-2023 12:54:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @continuousFFT_OpeningFcn, ...
                   'gui_OutputFcn',  @continuousFFT_OutputFcn, ...
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


% --- Executes just before continuousFFT is made visible.
function continuousFFT_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to continuousFFT (see VARARGIN)

% Choose default command line output for continuousFFT
handles.output = [];

try 
    EEG = varargin{1};
catch
    EEG = []; 
end

try
        def = varargin{2};
        chanArray = def{1};
        fqband      = def{2};
        fqlabels    = def{3};
        %winpercent  = def{4}; 
        %np        = EEG.srate/2;
        %custombands = def{5}; 
catch
        chanArray = 1:EEG.nbchan;
        fqnyq      = EEG.srate/2; 
        fqband     =  [0 3;3 8;8 12;8 30;30 48;49 51;59 61; 0 fqnyq]; %defaults
        fqlabels = {'delta','theta','alpha','beta','gamma','50hz-noise','60hz-noise','broadband'}; %defaults
        %winpercent = 20; 
        % np        = def{4};
       % custombands = 0; 
end
   
% EEG continuous
nchan = EEG.nbchan;
fs = EEG.srate;
chanArray = chanArray(chanArray<=nchan); 
handles.chanArray = chanArray; 
handles.fs = fs;

%make table
data_tab = [fqlabels num2cell(fqband)];
handles.Band_Table.Data = data_tab; 
handles.fqout = data_tab;
%handles.fqlabels = bandlabels'; 
handles.sel_row = size(handles.fqout,1); % set to max on load


%
% Prepare List of current Channels
%
if isempty(EEG.chanlocs)
        for e = 1:nchan
                EEG.chanlocs(e).labels = ['Ch' num2str(e)];
        end
end
listch = {''};
for ch =1:nchan
        listch{ch} = [num2str(ch) ' = ' EEG.chanlocs(ch).labels ];
end
handles.listch     = listch;
handles.indxlistch = chanArray;

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version ' - Summarize Continuous EEG Data Spectrum GUI'])
set(handles.edit_channels,'String', vect2colon(chanArray, 'Delimiter', 'off'));


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes avg_data_quality wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);


% --- Outputs from this function are returned to the command line.
function varargout = continuousFFT_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Get default command line output from handles structure
varargout{1} = handles.output;
%the figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in button_addband.
function button_addband_Callback(hObject, eventdata, handles)
% hObject    handle to button_addband (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

curr_rows = size(handles.fqout,1);
new_rows = curr_rows + 1;

old_fqout = handles.fqout;
win_size = old_fqout{end,3} - old_fqout{end,2};

new_row_str = ['Custom Band' num2str(new_rows)];
new_row_cell = {new_row_str,[],[]};
new_fqout = [old_fqout;new_row_cell];

handles.fqout = new_fqout;
%handles.fqlabels = {new_fqout(:,1)}'; 

set(handles.Band_Table,'Data',new_fqout);



guidata(hObject, handles);




% --- Executes on button press in button_remove.
function button_remove_Callback(hObject, eventdata, handles)
% hObject    handle to button_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curr_rows = size(handles.fqout,1);

row_del = handles.sel_row;


if curr_rows <= 1
    beep
    disp('Already at 1 rows')
else
    
    % notify
    %row_del_text = ['Now removing row ' num2str(row_del)];
    %disp(row_del_text)
    
    new_rows = curr_rows - 1;
    
    new_Tout = handles.fqout;
    new_Tout(row_del,:) = []; % pop the selected row out
    handles.fqout = new_Tout;
    
    %     row_drop_txt = ['The number of rows was ' num2str(curr_rows) '. Now dropping to ' num2str(new_rows)];
    % disp(row_drop_txt)
    set(handles.Band_Table,'Data',new_Tout)
    pause(0.3)
    handles.sel_row = new_rows;
        
    % 
    
end


guidata(hObject, handles);



% --- Executes on button press in button_reset.
function button_reset_Callback(hObject, eventdata, handles)
% hObject    handle to button_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Table of Frequency Band Values
fqnyq = handles.fs/2;
def_labels = {'delta','theta','alpha','beta','gamma','50hz-noise','60hz-noise','broadband'}; %defaults
def_bands = [0 3;3 8;8 12;8 30;30 48;49 51;59 61; 0 fqnyq];
%make table
data_tab = [def_labels' num2cell(def_bands)];
handles.Band_Table.Data = data_tab; 
handles.fqout = data_tab;
handles.sel_row = size(handles.fqout,1); % set to max on load
guidata(hObject, handles);



% --- Executes on button press in browse_buton.
function browse_buton_Callback(hObject, eventdata, handles)
% hObject    handle to browse_buton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

listch     = handles.listch;
indxlistch = handles.indxlistch;
indxlistch = indxlistch(indxlistch<=length(listch));
titlename  = 'Select Channel(s)';

if get(hObject, 'Value')
        if ~isempty(listch)
                ch = browsechanbinGUI(listch, indxlistch, titlename);
                if ~isempty(ch)
                        set(handles.edit_channels, 'String', vect2colon(ch, 'Delimiter', 'off'));
                        handles.indxlistch = ch;
                        % Update handles structure
                        guidata(hObject, handles);
                else
                        disp('User selected Cancel')
                        return
                end
        else
                msgboxText =  'No channel information was found';
                title = 'ERPLAB: fourieeg GUI input';
                errorfound(msgboxText, title);
                return
        end
end




function edit_channels_Callback(hObject, eventdata, handles)
% hObject    handle to edit_channels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ch = get(hObject,'string'); 
nch = length(handles.listch);

ch_val = eval(ch); 

if ~isempty(ch)
    

    tf = checkchannels(ch_val, nch, 1); 
    
    if tf
        return
    end

    
%     if length(ch_val) > length(handles.orig_indxlistch)
%         msgboxText =  'Exceeded Number of Available Channels';
%         title = 'ERPLAB: channel GUI input';
%         errorfound(msgboxText, title);
%         return
%     end
%     
    set(handles.edit_channels, 'String', vect2colon(ch_val, 'Delimiter', 'off'));
    handles.indxlistch = ch_val;
    % Update handles structure
    guidata(hObject, handles);

else
    msgboxText =  'Not valid channel';
    title = 'ERPLAB: channel GUI input';
    errorfound(msgboxText, title);
    return
end

% Hints: get(hObject,'String') returns contents of edit_channels as text
%        str2double(get(hObject,'String')) returns contents of edit_channels as a double


% --- Executes during object creation, after setting all properties.
function edit_channels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_channels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_cancel.
function button_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to button_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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

% --- Executes on button press in buton_run.
function buton_run_Callback(hObject, eventdata, handles)
% hObject    handle to buton_run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


disp('Saving settings....');

%Chosen Channels
chanArray = handles.indxlistch;
fqbands = [handles.fqout{:,2}; handles.fqout{:,3}]';
fqlabels = {handles.fqout{:,1}}' ; 
%winp = handles.winp; %percent windows
%np = handles.np; 

outstr = {chanArray, fqbands, fqlabels}; 

handles.output = outstr;
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);




% --- Executes on button press in button_help.
function button_help_Callback(hObject, eventdata, handles)
% hObject    handle to button_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web https://github.com/lucklab/erplab/wiki/Spectral-Data-Quality-(continuous-eeg) -browser

% --- Executes when entered data in editable cell(s) in Band_Table.
function Band_Table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to Band_Table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
fqout = hObject.Data;
handles.fqout = fqout;
guidata(hObject, handles);


% --- Executes on button press in all_button.
function all_button_Callback(hObject, eventdata, handles)
% hObject    handle to all_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



listch     = handles.listch; %original list
nChan = 1:length(listch); 
handles.indxlistch = nChan; 
set(handles.edit_channels, 'String', vect2colon(nChan, 'Delimiter', 'off'));
guidata(hObject,handles); 


% --- Executes when selected cell(s) is changed in Band_Table.
function Band_Table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to Band_Table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
if numel(eventdata.Indices)
    row_here = eventdata.Indices(1);
    old_row = handles.sel_row;
    handles.sel_row = row_here;
%     if isequal(row_here,old_row) == 0
%         row_text = ['Row number ' num2str(row_here) ' now selected'];
%         disp(row_text)
%     end
    guidata(hObject, handles);
end


% 
% function win_percent_box_Callback(hObject, eventdata, handles)
% % hObject    handle to win_percent_box (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% newval =  str2double(get(hObject,'String'));
% handles.winp = newval; 
% guidata(hObject,handles); 

% Hints: get(hObject,'String') returns contents of win_percent_box as text
%        str2double(get(hObject,'String')) returns contents of win_percent_box as a double


% --- Executes during object creation, after setting all properties.
function win_percent_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to win_percent_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function tf = checkchannels(chx, nchan, showmsg)

if nargin<3
        showmsg = 1;
end
tf = 0; % no problem by default

if ~mod(chx, 1) == 0
    if showmsg
        msgboxText =  'Invalid channel indexing.';
        title = 'ERPLAB: basicfilterGUI() error:';
        errorfound(msgboxText, title);
    end
    tf = 1; %
    
end

if isempty(chx)
        if showmsg
                msgboxText =  'Invalid channel indexing.';
                title = 'ERPLAB: basicfilterGUI() error:';
                errorfound(msgboxText, title);
        end
        tf = 1; %
        return
end
if ~isempty(find(chx>nchan))
        if showmsg
                msgboxText =  ['You only have %g channels,\n'...
                        'so you cannot specify indices greater than this.'];
                title = 'ERPLAB: basicfilterGUI() error:';
                errorfound(sprintf(msgboxText, nchan), title);
        end
        tf = 1; %
        return
end
if ~isempty(find(chx<1))
        if showmsg
                msgboxText =  'You cannot use zero or a negative number as a channel indexing';
                title = 'ERPLAB: basicfilterGUI() error:';
                errorfound(msgboxText, title);
        end
        tf = 1; %
        return
end
if length(chx)>length(unique_bc2(chx))
        if showmsg
                msgboxText =  ['Repeated channels are not allowed.\n'...
                        'Therefore, ERPLAB will get rid of them.'];
                title = 'ERPLAB: basicfilterGUI() error:';
                errorfound(sprintf(msgboxText), title, [1 1 0], [0 0 0], 0)
        end
        tf = 0; %
        return
end


% --- Executes when user attempts to close gui_chassis.
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to gui_chassis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        uiresume(handles.gui_chassis);
else
        % The GUI is no longer waiting, just close it
        delete(handles.gui_chassis);
end
