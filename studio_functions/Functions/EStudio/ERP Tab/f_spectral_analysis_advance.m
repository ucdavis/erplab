%
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% Copyright (C) 2022   Guanghui ZHANG  &  Steven Luck,
% Center for Mind and Brain, University of California, Davis,
% ghzhang@ucdavis.edu, sjluck@ucdavis.edu
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

function varargout = f_spectral_analysis_advance(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @f_spectral_analysis_advance_OpeningFcn, ...
    'gui_OutputFcn',  @f_spectral_analysis_advance_OutputFcn, ...
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
function f_spectral_analysis_advance_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for f_spectral_analysis_advance
handles.output = [];
try
    ERP = varargin{1};
catch
    ERP = [];
    ERP = buildERPstruct([]);
    ERP.xmin  = 0;
    ERP.xmax  = 0;
    ERP.nbin  = 1;
    ERP.nchan = 1;
    
end
handles.ERP = ERP;

try
    def = varargin{2};
catch
    def = {1,[], [], [1 16], 1, 1,1,0};
end

bin_chan_label = def{1};
BinArray = def{2};
ChanArray = def{3};
freqRange = def{4};
Auto_freq = def{5};
RowNum = def{6};
ColumnNum = def{7};

listb = {''};
nbin  = ERP.nbin; % Total number of bins
try
    for b=1:nbin
        listb{b}= ['BIN' num2str(b) ' = ' ERP.bindescr{b} ];
    end
catch
    listb = {};
end


%%%set(handles.popupmenu_bins,'String', listb)
handles.listb      = listb;
handles.indxlistb  = BinArray;


nchan  = ERP.nchan; % Total number of channels
if ~isfield(ERP.chanlocs,'labels')
    for e=1:nchan
        ERP.chanlocs(e).labels = ['Ch' num2str(e)];
    end
end
listch = {''};
for ch =1:nchan
    listch{ch} = [num2str(ch) ' = ' ERP.chanlocs(ch).labels ];
end
handles.listch     = listch;
handles.indxlistch = ChanArray;

for Numofrow = 1:256
    FramString{Numofrow}= num2str(Numofrow);
end

set(handles.popupmenu_row_num,'String',FramString);
set(handles.popupmenu_column_num,'String',FramString);

set(handles.popupmenu_row_num,'Value',nchan);

if bin_chan_label ==1
    set(handles.radiobutton_all_bin_chan,'Value',1);
    set(handles.radiobutton_selected_bin_chan,'Value',0);
    set(handles.radiobutton_Custom_bin_chan,'Value',0);
    set(handles.pushbutton_browse_bin,'Enable','off');
    set(handles.pushbutton_browse_chan,'Enable','off');
    set(handles.edit_bin_custom,'String',num2str(vect2colon([1:ERP.nbin],'Sort', 'on')));
    set(handles.edit_channel_custom,'String',num2str(vect2colon([1:ERP.nchan],'Sort', 'on')));
elseif bin_chan_label ==2
    set(handles.radiobutton_all_bin_chan,'Value',0);
    set(handles.radiobutton_selected_bin_chan,'Value',1);
    set(handles.radiobutton_Custom_bin_chan,'Value',0);
    set(handles.pushbutton_browse_bin,'Enable','off');
    set(handles.pushbutton_browse_chan,'Enable','off');
    [chk, msgboxText] = chckbinandchan(ERP, BinArray, ChanArray);
    if chk(1)
        BinString = [1:ERP.nbin];
    else
        BinString = BinArray;
    end
    if chk(2)
        ChanString = [1:ERP.nchan];
    else
        ChanString = ChanArray;
    end
    
    set(handles.edit_bin_custom,'String',num2str(vect2colon(BinString,'Sort', 'on')));
    set(handles.edit_channel_custom,'String',num2str(vect2colon(ChanString,'Sort', 'on')));
    
elseif bin_chan_label ==3
    set(handles.radiobutton_all_bin_chan,'Value',0);
    set(handles.radiobutton_selected_bin_chan,'Value',0);
    set(handles.radiobutton_Custom_bin_chan,'Value',1);
    set(handles.pushbutton_browse_bin,'Enable','on');
    set(handles.pushbutton_browse_chan,'Enable','on');
else
    set(handles.radiobutton_all_bin_chan,'Value',1);
    set(handles.radiobutton_selected_bin_chan,'Value',0);
    set(handles.radiobutton_Custom_bin_chan,'Value',0);
    set(handles.pushbutton_browse_bin,'Enable','off');
    set(handles.pushbutton_browse_chan,'Enable','off');
    set(handles.edit_bin_custom,'String',num2str(vect2colon([1:ERP.nbin],'Sort', 'on')));
    set(handles.edit_channel_custom,'String',num2str(vect2colon([1:ERP.nchan],'Sort', 'on')));
end
set(handles.checkbox_freq_ticks_auto,'Value',1);
set(handles.edit_freq_tick_auto,'Enable','off');

set(handles.edit_freq_range,'String',num2str(freqRange));



erplab_studio_default_values;
version = erplabstudiover;
set(handles.gui_chassis,'Name', ['EStudio',version,'  -   Plot and save spectrum for the selected ERP GUI '])
handles = painterplabstudio(handles);
handles = setfonterplabestudio(handles);

% helpbutton

%
% Color GUI
%
% handles = painterplab(handles);

%
% Set font size
%
% handles = setfonterplab(handles);

% Update handles structure
guidata(hObject, handles);

% help
% helpbutton

% UIWAIT makes f_spectral_analysis_advance wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

%--------------------------------------------------------------------------
function varargout = f_spectral_analysis_advance_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);

% --- Executes on button press in radiobutton_all_bin_chan.
function radiobutton_all_bin_chan_Callback(hObject, eventdata, handles)
set(handles.radiobutton_Custom_bin_chan,'Value',0);
set(handles.radiobutton_selected_bin_chan,'Value',0);
set(handles.radiobutton_all_bin_chan,'Value',1);
set(handles.pushbutton_browse_bin,'Enable','off');
set(handles.pushbutton_browse_chan,'Enable','off');
BinString = handles.ERP.nbin;
ChanString = handles.ERP.nchan;

set(handles.edit_bin_custom,'String',num2str(vect2colon(1:BinString,'Sort', 'on')));
set(handles.edit_channel_custom,'String',num2str(vect2colon(1:ChanString,'Sort', 'on')));

% --- Executes on button press in radiobutton_selected_bin_chan.
function radiobutton_selected_bin_chan_Callback(hObject, eventdata, handles)
set(handles.radiobutton_Custom_bin_chan,'Value',0);
set(handles.radiobutton_selected_bin_chan,'Value',1);
set(handles.radiobutton_all_bin_chan,'Value',0);
set(handles.pushbutton_browse_bin,'Enable','off');
set(handles.pushbutton_browse_chan,'Enable','off');

ERP = handles.ERP;

BinString = handles.indxlistb;
ChanString = handles.indxlistch;
if isempty(BinString)
    BinString =[1:ERP.nbin];
end
if isempty(ChanString)
    ChanString =[1:ERP.nchan];
end
[chk, msgboxText] = chckbinandchan(ERP, BinString, ChanString);
if chk(1)
    BinString = 1:ERP.nbin;
end
if chk(2)
    ChanString = 1:ERP.nchan;
end
set(handles.edit_bin_custom,'String',num2str(vect2colon(BinString,'Sort', 'on')));
set(handles.edit_channel_custom,'String',num2str(vect2colon(ChanString,'Sort', 'on')));


% --- Executes on button press in radiobutton_Custom_bin_chan.
function radiobutton_Custom_bin_chan_Callback(hObject, eventdata, handles)
set(handles.radiobutton_Custom_bin_chan,'Value',1);
set(handles.radiobutton_selected_bin_chan,'Value',0);
set(handles.radiobutton_all_bin_chan,'Value',0);
set(handles.pushbutton_browse_bin,'Enable','on');
set(handles.pushbutton_browse_chan,'Enable','on');


function edit_bin_custom_Callback(hObject, eventdata, handles)
BinString = str2num(handles.edit_bin_custom.String);
ERP = handles.ERP;
% [chk, msgboxText] = chckbinandchan(ERP, BinString, []);
[chk, msgboxText] = f_ERP_chckbinandchan(ERP, BinString, [],1);

if chk(1)
    title = 'EStudio: Spectral analysis GUI input';
    errorfound(msgboxText, title);
    return;
end



% --- Executes during object creation, after setting all properties.
function edit_bin_custom_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_channel_custom_Callback(hObject, eventdata, handles)
ChanString = str2num(handles.edit_channel_custom.String);
ERP = handles.ERP;
[chk, msgboxText] = chckbinandchan(ERP, [], ChanString);


if chk(2)
    title = 'EStudio: Spectral analysis GUI input';
    errorfound(msgboxText, title);
    return;
end

chanArray    = ChanString;
ColumnNum = get(handles.popupmenu_column_num, 'Value');
RowNum = ceil((numel(chanArray))/ColumnNum);
ColumnNum = ceil((numel(chanArray))/RowNum);
if RowNum<=0
    RowNum=1;
end
set(handles.popupmenu_row_num, 'Value', RowNum);
set(handles.popupmenu_column_num, 'Value', ColumnNum);

% --- Executes during object creation, after setting all properties.
function edit_channel_custom_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_browse_bin_Callback(hObject, eventdata, handles)
listb = handles.listb;
indxlistb = handles.indxlistb;
indxlistb = indxlistb(indxlistb<=length(listb));
titlename = 'Select Bin(s)';

if get(hObject, 'Value')
    %set(handles.pushbutton_browsechan, 'Enable', 'off')
    if ~isempty(listb)
        bin = browsechanbinGUI(listb, indxlistb, titlename);
        if ~isempty(bin)
            set(handles.edit_bin_custom, 'String', vect2colon(bin, 'Delimiter', 'off'));
            handles.indxlistb = bin;
            % Update handles structure
            guidata(hObject, handles);
        else
            disp('User selected Cancel')
            return
        end
    else
        msgboxText =  'No bin information was found';
        title = 'EStudio: Spectral analysis GUI input';
        errorfound(msgboxText, title);
        return
    end
    
end



% --- Executes on button press in pushbutton_browse_chan.
function pushbutton_browse_chan_Callback(hObject, eventdata, handles)
listch = handles.listch;
indxlistch = handles.indxlistch;
indxlistch = indxlistch(indxlistch<=length(listch));
titlename = 'Select Channel(s)';

if get(hObject, 'Value')
    if ~isempty(listch)
        ch = browsechanbinGUI(listch, indxlistch, titlename);
        if ~isempty(ch)
            set(handles.edit_channel_custom, 'String', vect2colon(ch, 'Delimiter', 'off'));
            handles.indxlistch = ch;
            
            chanArray    = ch;
            ColumnNum = get(handles.popupmenu_column_num, 'Value');
            RowNum = ceil((numel(chanArray))/ColumnNum);
            if RowNum<=0
                RowNum=1;
            end
            set(handles.popupmenu_row_num, 'Value', RowNum);
            
            % Update handles structure
            guidata(hObject, handles);
        else
            disp('User selected Cancel')
            return
        end
    else
        msgboxText =  'No channel information was found';
        title = 'EStudio: Spectral analysis GUI input';
        errorfound(msgboxText, title);
        return
    end
end

%Freq. range [min max] in Hz
function edit_freq_range_Callback(hObject, eventdata, handles)
freqx = str2num(get(handles.edit_freq_range, 'String'));
if isempty(freqx)
    msgboxText =  'Invalid input for frequency range of interest';
    title      = 'EStudio: f_spectral_analysis_advance().';
    errorfound(msgboxText, title);
    return
end
if length(freqx)~=2
    msgboxText =  'Please, enter two values';
    title = 'EStudio: f_spectral_analysis_advance().';
    errorfound(msgboxText, title);
    return
end


if freqx(1)>= freqx(2)
    msgboxText =  'The first value must be smaller than the second one!';
    title      = 'EStudio: f_spectral_analysis_advance().';
    errorfound(msgboxText, title);
    return
end
ERP = handles.ERP;
try
    freq_half = ERP.srate/2;
catch
    freq_half =freqx(2);
end

if freqx(2)> freq_half
    msgboxText =  ['Second value must be smaller than',32,num2str(ERP.srate/2)];
    title      = 'ERPLAB Studio: f_ERP_spectral_advance_GUI() error';
    errorfound(msgboxText, title);
    return
end

Auto_tick =  get(handles.checkbox_freq_ticks_auto,'Value');

if ~Auto_tick
    def_ticks = default_time_ticks(handles.ERP, freqx);
    set(handles.edit_freq_tick_auto,'String',num2str(def_ticks{1}));
end


% --- Executes during object creation, after setting all properties.
function edit_freq_range_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in checkbox_freq_ticks_auto.
function checkbox_freq_ticks_auto_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.edit_freq_tick_auto,'Enable','off');
    set(handles.edit_freq_tick_auto,'String','');
else
    set(handles.edit_freq_tick_auto,'Enable','on');
    
    freqx = str2num(get(handles.edit_freq_range, 'String')); % XL
    if isempty(freqx)
        msgboxText =  'Invalid input for frequency range of interest on "Freq. range [min max] in Hz"';
        title      = 'EStudio: f_spectral_analysis_advance().';
        errorfound(msgboxText, title);
        return
    end
    if length(freqx)~=2
        msgboxText =  'Please, enter two values on "Freq. range [min max] in Hz"';
        title = 'EStudio: f_spectral_analysis_advance().';
        errorfound(msgboxText, title);
        return
    end
    
    
    if freqx(1)>= freqx(2)
        msgboxText =  'The first value must be smaller than the second one on "Freq. range [min max] in Hz"';
        title      = 'EStudio: f_spectral_analysis_advance().';
        errorfound(msgboxText, title);
        return
    end
    if freqx(1)<0
        msgboxText =  'The first value must be larger than 0Hz on "Freq. range [min max] in Hz"';
        title      = 'EStudio: f_spectral_analysis_advance().';
        errorfound(msgboxText, title);
        return
    end
    
    ERP = handles.ERP;
    if freqx(2)> ERP.srate/2
        msgboxText =  ['Second value must be smaller than',32,num2str(observe_ERPDAT.ERP.srate/2),'Hz',32,'on "Freq. range [min max] in Hz"'];
        title      = 'ERPLAB Studio: f_ERP_spectral_advance_GUI() error';
        errorfound(msgboxText, title);
        return
    end
    
    
    def_ticks = default_time_ticks(handles.ERP, freqx);
    if ~isempty(def_ticks)
        set(handles.edit_freq_tick_auto,'String',num2str(def_ticks{1}));
    end
end





function edit_freq_tick_auto_Callback(hObject, eventdata, handles)
answer = get(handles.edit_freq_tick_auto,'String');
nanswer = str2num(strtrim(char(answer)));
if isempty(nanswer)
    msgboxText = 'Invalid range of values on freq. ticks!\n';
    title = 'ERPLAB Studio: f_ERP_spectral_advance_GUI() error';
    errorfound(sprintf(msgboxText), title);
    return
end






% --- Executes during object creation, after setting all properties.
function edit_freq_tick_auto_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_freq_tick_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_row_num.
function popupmenu_row_num_Callback(hObject, eventdata, handles)
chanArraystr = get(handles.edit_channel_custom, 'String');
chanArray    = str2num(chanArraystr);
if isempty(chanArray)
    chanArray = [1:handles.ERP.nchan];
end
RowNum= get(handles.popupmenu_row_num, 'Value');
ColumnNum = ceil((numel(chanArray))/RowNum);
if ColumnNum<=0
    ColumnNum=1;
end
set(handles.popupmenu_column_num, 'Value', ColumnNum);


% --- Executes during object creation, after setting all properties.
function popupmenu_row_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_row_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_column_num.
function popupmenu_column_num_Callback(hObject, eventdata, handles)

chanArraystr = get(handles.edit_channel_custom, 'String');
chanArray    = str2num(chanArraystr);

if isempty(chanArray)
    chanArray = [1:handles.ERP.nchan];
end
ColumnNum = get(handles.popupmenu_column_num, 'Value');
RowNum = ceil((numel(chanArray))/ColumnNum);
if RowNum<=0
    RowNum=1;
end
set(handles.popupmenu_row_num, 'Value', RowNum);


% --- Executes during object creation, after setting all properties.
function popupmenu_column_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_column_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)

handles.output = [];
disp('User selected Cancel');
guidata(hObject, handles);
uiresume(handles.gui_chassis);

% %--------------------------------------------------------------------------
% function pushbutton_help_Callback(hObject, eventdata, handles)
% % doc pop_export2text
% web 'https://github.com/lucklab/erplab/wiki/Exporting,-Editing,-and-Importing-EVENTLISTS' -browser
%--------------------------------------------------------------------------
function pushbutton_apply_Callback(hObject, eventdata, handles)

BinArray = str2num(handles.edit_bin_custom.String);
ChanArray = str2num(handles.edit_channel_custom.String);
ERP = handles.ERP;
[chk, msgboxText] = chckbinandchan(ERP, BinArray, ChanArray);
if chk(1)
    title = 'ERPLAB Studio: f_ERP_spectral_advance_GUI() error';
    errorfound(sprintf(msgboxText), title);
    return;
end
if chk(2)
    title = 'ERPLAB Studio: f_ERP_spectral_advance_GUI() error';
    errorfound(sprintf(msgboxText), title);
    return;
end



freqRange = str2num(get(handles.edit_freq_range, 'String')); % XL
if isempty(freqRange)
    msgboxText =  'Invalid input for frequency range of interest on "Freq. range [min max] in Hz"';
    title      = 'EStudio: f_spectral_analysis_advance().';
    errorfound(msgboxText, title);
    return
end
if length(freqRange)~=2
    msgboxText =  'Please, enter two values on "Freq. range [min max] in Hz"';
    title = 'EStudio: f_spectral_analysis_advance().';
    errorfound(msgboxText, title);
    return
end


if freqRange(1)>= freqRange(2)
    msgboxText =  'The first value must be smaller than the second one on "Freq. range [min max] in Hz"';
    title      = 'EStudio: f_spectral_analysis_advance().';
    errorfound(msgboxText, title);
    return
end
if freqRange(1)<0
    msgboxText =  'The first value must be larger than 0Hz on "Freq. range [min max] in Hz"';
    title      = 'EStudio: f_spectral_analysis_advance().';
    errorfound(msgboxText, title);
    return
end


if freqRange(2)> ERP.srate/2
    msgboxText =  ['Second value must be smaller than',32,num2str(observe_ERPDAT.ERP.srate/2),'Hz',32,'on "Freq. range [min max] in Hz"'];
    title      = 'ERPLAB Studio: f_ERP_spectral_advance_GUI() error';
    errorfound(msgboxText, title);
    return
end




if handles.checkbox_freq_ticks_auto.Value
    Auto_freq = [];
else
    Auto_freq_String = handles.edit_freq_tick_auto.String;
    Auto_freq = str2num(Auto_freq_String);
end

RowNum = handles.popupmenu_row_num.Value;
ColumnNum = handles.popupmenu_column_num.Value;

if handles.radiobutton_all_bin_chan.Value
    bin_chan_label = 1;
elseif handles.radiobutton_selected_bin_chan.Value
    bin_chan_label = 2;
elseif handles.radiobutton_Custom_bin_chan.Value
    bin_chan_label = 3;
end


Save_label = handles.pushbutton_save.Value;

answer = {bin_chan_label,BinArray, ChanArray,freqRange,Auto_freq,RowNum,ColumnNum,Save_label};
handles.output = answer;

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);


% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
BinArray = str2num(handles.edit_bin_custom.String);
ChanArray = str2num(handles.edit_channel_custom.String);
ERP = handles.ERP;
[chk, msgboxText] = chckbinandchan(ERP, BinArray, ChanArray);
if chk(1)
    title = 'ERPLAB Studio: f_ERP_spectral_advance_GUI() error';
    errorfound(sprintf(msgboxText), title);
    return;
end
if chk(2)
    title = 'ERPLAB Studio: f_ERP_spectral_advance_GUI() error';
    errorfound(sprintf(msgboxText), title);
    return;
end

freqRange = str2num(get(handles.edit_freq_range, 'String')); % XL
if isempty(freqRange)
    msgboxText =  'Invalid input for frequency range of interest on "Freq. range [min max] in Hz"';
    title      = 'EStudio: f_spectral_analysis_advance().';
    errorfound(msgboxText, title);
    return
end
if length(freqRange)~=2
    msgboxText =  'Please, enter two values on "Freq. range [min max] in Hz"';
    title = 'EStudio: f_spectral_analysis_advance().';
    errorfound(msgboxText, title);
    return
end


if freqRange(1)>= freqRange(2)
    msgboxText =  'The first value must be smaller than the second one on "Freq. range [min max] in Hz"';
    title      = 'EStudio: f_spectral_analysis_advance().';
    errorfound(msgboxText, title);
    return
end
if freqRange(1)<0
    msgboxText =  'The first value must be larger than 0Hz on "Freq. range [min max] in Hz"';
    title      = 'EStudio: f_spectral_analysis_advance().';
    errorfound(msgboxText, title);
    return
end


if freqRange(2)> ERP.srate/2
    msgboxText =  ['Second value must be smaller than',32,num2str(observe_ERPDAT.ERP.srate/2),'Hz',32,'on "Freq. range [min max] in Hz"'];
    title      = 'ERPLAB Studio: f_ERP_spectral_advance_GUI() error';
    errorfound(msgboxText, title);
    return
end




if handles.checkbox_freq_ticks_auto.Value
    Auto_freq = [];
else
    Auto_freq_String = handles.edit_freq_tick_auto.String;
    Auto_freq = str2num(Auto_freq_String);
end

RowNum = handles.popupmenu_row_num.Value;
ColumnNum = handles.popupmenu_column_num.Value;

if handles.radiobutton_all_bin_chan.Value
    bin_chan_label = 1;
elseif handles.radiobutton_selected_bin_chan.Value
    bin_chan_label = 2;
elseif handles.radiobutton_Custom_bin_chan.Value
    bin_chan_label = 3;
end


Save_label = handles.pushbutton_save.Value;

answer = {bin_chan_label,BinArray, ChanArray,freqRange,Auto_freq,RowNum,ColumnNum,Save_label};
handles.output = answer;

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);



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





function [chk, msgboxText] = chckbinandchan(ERP, binArray, chanArray)
chk=[0 0];
msgboxText = '';
if isempty(binArray)
    msgboxText =  'You have not specified any bin';
    chk(1) = 1;
    %     return
end
if any(binArray<=0)
    msgboxText =  sprintf('Invalid bin index.\nPlease specify only positive integer values.');
    chk(1) = 1;
    return
end
if any(binArray>ERP.nbin)
    msgboxText =  sprintf('Bin index out of range!\nYou only have %g bins in this ERPset',ERP.nbin);
    chk(1) = 1;
    return
end
if length(binArray)~=length(unique_bc2(binArray))
    msgboxText = 'You have specified repeated bins for plotting.';
    chk(1) = 1;
    return
end
if isempty(chanArray)
    msgboxText =  'You have not specified any channel';
    chk(2) = 1;
    return
end
if any(chanArray<=0)
    msgboxText =  sprintf('Invalid channel index.\nPlease specify only positive integer values.');
    chk(2) = 1;
    return
end
if any(chanArray>ERP.nchan)
    msgboxText =  sprintf('Channel index out of range!\nYou only have %g channels in this ERPset', ERP.nchan);
    chk(2) = 1;
    return
end
if length(chanArray)~=length(unique_bc2(chanArray))
    msgboxText = 'You have specified repeated channels for plotting.';
    chk(2) = 1;
    return
end
