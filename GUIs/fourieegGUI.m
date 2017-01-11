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

function varargout = fourieegGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @fourieegGUI_OpeningFcn, ...
        'gui_OutputFcn',  @fourieegGUI_OutputFcn, ...
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
function fourieegGUI_OpeningFcn(hObject, eventdata, handles, varargin)


% defx = 
% 
%     [1]    [1]    [0]    [250]    [256]    [1x2 double]    [1]
% 
% 
% def = 
% 
%     [1]    []    [1]    [80]    [256]    [1x2 double]    [1]
%     
     
 
handles.output = [];
try
        ERPLAB = varargin{1};
catch
        ERPLAB = [];
end
try
        def = varargin{2};
        chanArray = def{1};
        binArray  = def{2};
        f1        = def{3};
        f2        = def{4};
        np        = def{5};
        latwindow = def{6};
        includelege = def{7};
catch
        chanArray = 1;
        binArray  = 1;
        f1        = 0;
        f2        = 30;
        np        = 256;
        latwindow = [0 200];
        includelege = 1;     
end
if isempty(ERPLAB)
        nchan    = 0;
        typedata = '?';
        fs       = 0;
        ERPLAB.chanlocs = [];
        nbin     = [];
        listb    = [];
else
        if iserpstruct(ERPLAB)
                nchan    = ERPLAB.nchan;
                typedata = 'ERP';
                nbin     = ERPLAB.nbin;
                listb    = {''};
                for b=1:nbin
                        listb{b} = ['BIN' num2str(b) ' = ' ERPLAB.bindescr{b} ];
                end
        else
                nchan    = ERPLAB.nbchan;
                typedata = 'EEG';
                if isempty(ERPLAB.epoch) % EEG continuous
                        nbin     = [];
                        listb    = [];
                else  % EEG epoched
                        if isfield(ERPLAB, 'EVENTLIST') && ~isempty(ERPLAB.EVENTLIST)
                                nbin  = ERPLAB.EVENTLIST.nbin;
                                listb = {''};
                                for b=1:nbin
                                        listb{b} = ['BIN' num2str(b) ' = ' ERPLAB.EVENTLIST.bdf(b).description ];
                                end
                        else
                                nbin      = [];
                                listb     = [];
                        end
                end
        end
        fs = ERPLAB.srate;
end
chanArray = chanArray(chanArray<=nchan);
binArray  = binArray(binArray<=nbin);
handles.chanArray = chanArray;
handles.binArray  = binArray;
handles.f1        = f1;
handles.f2        = f2;
handles.np        = np;
handles.latwindow = latwindow;
handles.fs = fs;
handles.typedata  = typedata;
handles.listb     = listb;
handles.indxlistb = binArray;
handles.nbin      = nbin;

if isempty(listb) || isempty(nbin)
        set(handles.edit_bins, 'String', '')
        set(handles.edit_bins, 'Enable', 'off')
        set(handles.pushbutton_browsebins, 'Enable', 'off')
end

%
% Prepare List of current Channels
%
if isempty(ERPLAB.chanlocs)
        for e = 1:nchan
                ERPLAB.chanlocs(e).labels = ['Ch' num2str(e)];
        end
end
listch = {''};
for ch =1:nchan
        listch{ch} = [num2str(ch) ' = ' ERPLAB.chanlocs(ch).labels ];
end
handles.listch     = listch;
handles.indxlistch = chanArray;

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   ' typedata ' Amplitude Spectrum GUI'])

set(handles.edit_channels,'String', vect2colon(chanArray, 'Delimiter', 'off'));
set(handles.edit_bins,'String', vect2colon(binArray, 'Delimiter', 'off'));
set(handles.edit_f1,'String', num2str(f1));
set(handles.edit_f2,'String', num2str(f2));
set(handles.checkbox_inclege, 'Value', includelege)

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

% UIWAIT makes fourieegGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

%--------------------------------------------------------------------------
function varargout = fourieegGUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

%--------------------------------------------------------------------------
function edit_f1_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_f1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_f2_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_f2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_browsechan_Callback(hObject, eventdata, handles)

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

%--------------------------------------------------------------------------
function pushbutton_browsechan_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)

handles.output= '';
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function pushbutton_help_Callback(hObject, eventdata, handles)

% typedata = handles.typedata;
% if strcmpi(typedata, 'EEG')
%       doc pop_fourieeg
% else
%       doc pop_fourierp
% end
web https://github.com/lucklab/erplab/wiki/Filtering -browser

%--------------------------------------------------------------------------
function pushbutton_plot_Callback(hObject, eventdata, handles)

chanArray  = str2num(get(handles.edit_channels,'String'));

if isempty(chanArray)
        msgboxText =  'You must specify one channel at least!';
        title = 'ERPLAB: fourieeg GUI few inputs';
        errorfound(msgboxText, title);
        return
end
if strcmpi(get(handles.edit_bins, 'Enable'), 'off')
        binArray   = [];
else
        binArray   = str2num(get(handles.edit_bins,'String'));
end

f1 = str2num(get(handles.edit_f1,'String'));
f2 = str2num(get(handles.edit_f2,'String'));
fs = handles.fs;

if isempty(f1) || isempty(f2)
        msgboxText =  'You must specify both frequency boudaries.';
        title = 'ERPLAB: fourieeg GUI few inputs';
        errorfound(msgboxText, title);
        return
end
if f1>=f2
        msgboxText =  'f1 must be lower than f2';
        title = 'ERPLAB: fourieeg GUI wrong inputs';
        errorfound(msgboxText, title);
        return
end
if f1<0 || f2<0
        msgboxText =  'Both f1 and f2 must be positive values';
        title = 'ERPLAB: fourieeg GUI wrong inputs';
        errorfound(msgboxText, title);
        return
end
if f1>fs/2 || f2>fs/2
        msgboxText =  'Both f1 and f2 must be lower (or equal) than the Nyquist frequency (fs/2).';
        title = 'ERPLAB: fourieeg GUI wrong inputs';
        errorfound(msgboxText, title);
        return
end
np = handles.np;
latwindow = handles.latwindow;

includelege = get(handles.checkbox_inclege, 'Value');

outstr    = {chanArray, binArray, f1, f2, np, latwindow, includelege};
handles.output = outstr;

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function edit_bins_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_bins_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_channels_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_channels_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_browsebins_Callback(hObject, eventdata, handles)
listb = handles.listb;
indxlistb = handles.indxlistb;
indxlistb = indxlistb(indxlistb<=length(listb));
titlename = 'Select Bin(s)';

if get(hObject, 'Value')
        if ~isempty(listb)
                bin = browsechanbinGUI(listb, indxlistb, titlename);
                if ~isempty(bin)
                        set(handles.edit_bins, 'String', vect2colon(bin, 'Delimiter', 'off'));
                        handles.indxlistb = bin;
                        % Update handles structure
                        guidata(hObject, handles);
                else
                        disp('User selected Cancel')
                        return
                end
        else
                msgboxText =  'No bin information was found';
                title = 'ERPLAB: geterpvalues GUI input';
                errorfound(msgboxText, title);
                return
        end
end

%--------------------------------------------------------------------------
function checkbox_inclege_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        uiresume(handles.gui_chassis);
else
        % The GUI is no longer waiting, just close it
        delete(handles.gui_chassis);
end

