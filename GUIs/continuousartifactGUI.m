% Author: Javier Lopez-Calderon
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

function varargout = continuousartifactGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @continuousartifactGUI_OpeningFcn, ...
    'gui_OutputFcn',  @continuousartifactGUI_OutputFcn, ...
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

% -----------------------------------------------------------------------
function continuousartifactGUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = [];
try
    fs       = varargin{1};
    nchan    = varargin{2};
    chanlocs = varargin{3};
catch
    fs       = 1000;
    nchan    = 1;
    chanlocs = [];
end

%
% Gui memory
%

% def{1}: threshold value(s); until 2 values
% def{2}: Moving Windows Width in ms
% def{3}: Window Step in ms
% def{4}: channel index(ices)
% def{5}: lowest freq in Hz
% def{6}: highest freq in Hz
% def{7}: include this band 1=include; o=exclude
% def{8}: only mark first detected art channel per windowing. (1: yes)
% def{9}: join short segments

memoryCARTGUI = erpworkingmemory('continuousartifactGUI');

if isempty(memoryCARTGUI)
    prompt     = {'Threshold (1 or 2 values)', 'Moving Windows Width (ms)',...
        'Window Step (ms)','Channel(s)', 'Frequency cutoffs (Hz)', 'lowest freq', 'highest freq'};
    dlg_title  =  'Input threshold';
    def        = {200 500 250 [1:nchan] [] [] [] 0 0 0 0};
    defx       = def  ;
    colorseg   = [1.0000    0.9765    0.5294]; % default
else
    try
        prompt     = memoryCARTGUI.prompt;
        dlg_title  = memoryCARTGUI.dlg_title;
        def        = memoryCARTGUI.def;
        defx       = memoryCARTGUI.defx;
        colorseg   = memoryCARTGUI.colorseg;
    catch
        prompt     = {'Threshold (1 or 2 values)', 'Moving Windows Width (ms)',...
            'Window Step (ms)','Channel(s)', 'Frequency cutoffs (Hz)', 'lowest freq', 'highest freq'};
        dlg_title  =  '';
        def        = {[] [] [] [1:nchan] [] [] [] 0 0 0 0};
        defx       = def;
        colorseg   = [1.0000    0.9765    0.5294]; % default
    end
end

% channel max
def{4}=def{4}(def{4}<=nchan);

% handles
handles.colorseg = colorseg;
handles.fs        = fs;
handles.prompt    = prompt;
handles.dlg_title = dlg_title;
handles.def       = def;
handles.defx      = defx;
fontsz            = 10;
handles.fontsz    = fontsz;
handles.defforder = 100; % default filter order

for i=1:length(prompt)
    set(handles.(['text' num2str(i)]),'String', prompt{i},'FontSize', fontsz)
    
    %         if i==1
    %                 strx = sprintf('%.1f  %.1f', def{i});
    %         else
    %                 strx = vect2colon(def{i},'Delimiter','off');
    %         end
    if i<length(prompt)
        if ~isempty(def{i})
            set(handles.(['edit' num2str(i)]),'String', vect2colon(def{i},'Delimiter','off'));
        end
    end
end
if isempty(def{7})
    set(handles.radiobutton_prefilter,'Value',0);
    set(handles.radiobutton_include,'Value', 0)
    set(handles.radiobutton_exclude,'Value', 0)
    set(handles.radiobutton_include,'Enable','off')
    set(handles.radiobutton_exclude,'Enable','off')
    set(handles.edit5,'String','')
    set(handles.edit6,'String','')
    set(handles.edit5,'Enable','off')
    set(handles.edit6,'Enable','off')
else
    set(handles.radiobutton_prefilter,'Value',1);
    set(handles.radiobutton_include,'Enable','on')
    set(handles.radiobutton_exclude,'Enable','on')
    set(handles.edit5,'Enable','on')
    set(handles.edit6,'Enable','on')
    
    if def{7}==1
        set(handles.radiobutton_include,'Value', 1)
        set(handles.radiobutton_exclude,'Value', 0)
    else
        set(handles.radiobutton_include,'Value', 0)
        set(handles.radiobutton_exclude,'Value', 1)
    end
end
set(handles.checkbox_firstart,'Value', def{8})
if isempty(def{9})
    set(handles.checkbox_shortsegments,'Value', 0)
    set(handles.edit_shortsegmentms,'String', '')
    set(handles.edit_shortsegmentms,'Enable', 'off')
else
    if def{9}>0
        set(handles.checkbox_shortsegments,'Value', 1)
        set(handles.edit_shortsegmentms,'String', num2str(def{9}))
    else
        set(handles.checkbox_shortsegments,'Value', 0)
        set(handles.edit_shortsegmentms,'String', '')
        set(handles.edit_shortsegmentms,'Enable', 'off')
    end
end
if isempty(def{10})
    set(handles.checkbox_unmark,'Value', 0)
    set(handles.edit_unmark,'String', '')
    set(handles.edit_unmark,'Enable', 'off')
else
    if def{10}>0
        set(handles.checkbox_unmark,'Value', 1)
        set(handles.edit_unmark,'String', num2str(def{10}))
    else
        set(handles.checkbox_unmark,'Value', 0)
        set(handles.edit_unmark,'String', '')
        set(handles.edit_unmark,'Enable', 'off')
    end
end
if isempty(def{11})
    set(handles.checkbox_move_onset,'Value', 0)
    set(handles.edit_move_onset,'String', '')
    set(handles.edit_move_onset,'Enable', 'off')
else
    if def{11}==0
        set(handles.checkbox_move_onset,'Value', 0)
        set(handles.edit_move_onset,'String', '')
        set(handles.edit_move_onset,'Enable', 'off')
    else
        set(handles.checkbox_move_onset,'Value', 1)
        set(handles.edit_move_onset,'String', num2str(def{11}))
    end
end

set(handles.gui_chassis, 'Name', dlg_title)
set(handles.edit_patch_color,'BackgroundColor', colorseg)

%
% Prepare List of current Channels
%
if isempty(chanlocs)
        for e = 1:nchan
                chanlocs(e).labels = ['Ch' num2str(e)];
        end
end
listch = {''};
for ch =1:nchan
        listch{ch} = [num2str(ch) ' = ' chanlocs(ch).labels ];
end

handles.listch     = listch;
handles.indxlistch = def{4}; % channel array

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
% UIWAIT makes continuousartifactGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

%--------------------------------------------------------------------------
function varargout = continuousartifactGUI_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

%--------------------------------------------------------------------------
function edit1_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit2_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit3_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit3_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit4_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit4_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit5_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit5_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
function edit6_Callback(hObject, eventdata, handles)

lowf = str2num(get(handles.edit5,'String'));
if isempty(lowf)
    set(handles.edit5,'String','0')
end

%--------------------------------------------------------------------------
function edit6_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function radiobutton_prefilter_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    %     set(handles.edit5,'String','')
    set(handles.edit5,'Enable','on')
    set(handles.edit6,'Enable','on')
    %     set(handles.edit6,'String','')
    set(handles.radiobutton_include,'Enable','on')
    set(handles.radiobutton_exclude,'Enable','on')
    set(handles.radiobutton_include,'Value', 1)
else
    set(handles.edit5,'String','')
    set(handles.edit5,'Enable','off')
    set(handles.edit6,'Enable','off')
    set(handles.edit6,'String','')
    set(handles.radiobutton_include,'Enable','off')
    set(handles.radiobutton_exclude,'Enable','off')
    set(handles.radiobutton_include,'Value',0)
    set(handles.radiobutton_exclude,'Value',0)
end

%--------------------------------------------------------------------------
function pushbutton_reset_Callback(hObject, eventdata, handles)

prompt = handles.prompt;
defx   = handles.defx;
%fontsz = handles.fontsz;

for i=1:length(prompt)
    %set(handles.(['text' num2str(i)]),'String', prompt{i},'FontSize', fontsz)
    if i<length(prompt)
        set(handles.(['edit' num2str(i)]),'String', vect2colon(defx{i},'Delimiter','off'));
    end
end
set(handles.radiobutton_prefilter,'Value',0);

%     set(handles.edit5,'String','')
set(handles.edit5,'Enable','off')
set(handles.edit6,'Enable','off')
set(handles.radiobutton_prefilter,'Value',0);
set(handles.radiobutton_include,'Enable','off')
set(handles.radiobutton_exclude,'Enable','off')

set(handles.checkbox_shortsegments,'Value',0);
set(handles.edit_shortsegmentms,'Enable','off')

%--------------------------------------------------------------------------
function radiobutton_include_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    set(handles.radiobutton_exclude,'Value',0)
else
    set(handles.radiobutton_include,'Value',1)
end

%--------------------------------------------------------------------------
function radiobutton_exclude_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    set(handles.radiobutton_include,'Value',0)
else
    set(handles.radiobutton_exclude,'Value',1)
end

%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)

handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function pushbutton_help_Callback(hObject, eventdata, handles)
% doc pop_continuousartdet
web https://github.com/lucklab/erplab/wiki/Artifact-Rejection-in-Continuous-Data -browser

%--------------------------------------------------------------------------
function pushbutton_accept_Callback(hObject, eventdata, handles)
drawnow; pause(0.1)
prompt = handles.prompt;
outputv = cell(1);

for k=1:4
    outputv{k} = str2num(get(handles.(['edit' num2str(k)]), 'String'));
end
% pre-filtering
if get(handles.radiobutton_prefilter, 'Value')
    for k=5:6
        outputv{k} = str2num(get(handles.(['edit' num2str(k)]), 'String'));
    end
    if get(handles.radiobutton_include, 'Value')
        outputv{7} = 1; % include freqs
    else
        outputv{7} = 0; % exclude freqs
    end
else
    for k=5:7
        outputv{k} = [];
    end
end

outputv{8}  = get(handles.checkbox_firstart, 'Value');
outputv{9}  = str2num(get(handles.edit_shortsegmentms, 'String'));
outputv{10} = str2num(get(handles.edit_unmark, 'String'));
outputv{11} = str2num(get(handles.edit_move_onset, 'String'));

% mini parsing
if length(outputv{1})~=1 && length(outputv{1})~=2
    msgboxText =  'Invalid threshold';
    title      = 'ERPLAB: continuousartifactGUI() error';
    errorfound(msgboxText, title);
    return
else  
    if length(outputv{1})==2 && outputv{1}(1)>=outputv{1}(2)
        msgboxText =  ['Invalid threshold\n'...
            'When 2 thresholds are specified, the first one must be lesser than the second one.'];
        title      = 'ERPLAB: continuousartifactGUI() error';
        errorfound(sprintf(msgboxText), title);
        return
    end   
end
if length(outputv{2})~=1
    msgboxText =  'Invalid window width';
    title      = 'ERPLAB: continuousartifactGUI() error';
    errorfound(msgboxText, title);
    return
end
if outputv{2}<1
    msgboxText =  'Invalid window width';
    title      = 'ERPLAB: continuousartifactGUI() error';
    errorfound(msgboxText, title);
    return
end
if length(outputv{3})~=1
    msgboxText =  'Invalid step width';
    title      = 'ERPLAB: continuousartifactGUI() error';
    errorfound(msgboxText, title);
    return
end
if outputv{3}<1
    msgboxText =  'Invalid step width';
    title      = 'ERPLAB: continuousartifactGUI() error';
    errorfound(msgboxText, title);
    return
end
if outputv{3}>outputv{2}
    msgboxText =  'Step width cannot be larger than window width';
    title      = 'ERPLAB: continuousartifactGUI() error';
    errorfound(msgboxText, title);
    return
end
if nnz(outputv{4}<=0)>0
    msgboxText =  'Invalid channel index(ices)';
    title      = 'ERPLAB: continuousartifactGUI() error';
    errorfound(msgboxText, title);
    return
end
if get(handles.radiobutton_prefilter, 'Value')
    fs = handles.fs;
    fsn = round(fs/2);
    
    if isempty(outputv{5})
        msgboxText =  'Invalid lowest frequency value';
        title      = 'ERPLAB: continuousartifactGUI() error';
        errorfound(msgboxText, title);
        return
    end
    if isempty(outputv{6})
        msgboxText =  'Invalid highest frequency value';
        title      = 'ERPLAB: continuousartifactGUI() error';
        errorfound(msgboxText, title);
        return
    end
    if outputv{5}<0
        msgboxText =  'Invalid lowest frequency value';
        title      = 'ERPLAB: continuousartifactGUI() error';
        errorfound(msgboxText, title);
        return
    end
    if outputv{6}<0
        msgboxText =  'Invalid highest frequency value';
        title      = 'ERPLAB: continuousartifactGUI() error';
        errorfound(msgboxText, title);
        return
    end
    if isnan(outputv{5}) || isnan(outputv{6})
        msgboxText =  'Invalid frequency value(s)';
        title      = 'ERPLAB: continuousartifactGUI() error';
        errorfound(msgboxText, title);
        return
    end
    if outputv{5}>fsn && ~isinf(outputv{5})
        msgboxText =  'Lowest frequency value cannot be higher than Nyquist''s frequency (%d Hz)';
        title      = 'ERPLAB: continuousartifactGUI() error';
        errorfound(sprintf(msgboxText, fsn), title);
        return
    end
    if outputv{6}>fsn && ~isinf(outputv{6})
        msgboxText =  'Highest frequency value cannot be higher than Nyquist''s frequency  (%d Hz)';
        title      = 'ERPLAB: continuousartifactGUI() error';
        errorfound(sprintf(msgboxText, fsn), title);
        return
    end
    if outputv{5}>= outputv{6} && (outputv{5}~=0 && outputv{6}~=0) && ~isinf(outputv{5}) && ~isinf(outputv{6})
        msgboxText =  ['Lowest frequency must be lower than highest one.\n\n'...
            'If you want to reject a band (notch filtering) just check "Exclude this frequency band"'];
        title      = 'ERPLAB: continuousartifactGUI() error';
        errorfound(sprintf(msgboxText), title);
        return
    end
end
if get(handles.checkbox_shortsegments, 'Value')
    if length(outputv{9})~=1
        msgboxText =  'Invalid input for segments'' separation';
        title      = 'ERPLAB: continuousartifactGUI() error';
        errorfound(msgboxText, title);
        return
    end
    if outputv{9}<0
        msgboxText =  'Invalid input for segments'' separation';
        title      = 'ERPLAB: continuousartifactGUI() error';
        errorfound(msgboxText, title);
        return
    end
else
    set(handles.edit_shortsegmentms, 'String', '')
    set(handles.edit_shortsegmentms, 'Enable', 'off')
    outputv{9} = [];
end
if get(handles.checkbox_unmark, 'Value')
    if length(outputv{10})~=1
        msgboxText =  'Invalid input for segments'' width';
        title      = 'ERPLAB: continuousartifactGUI() error';
        errorfound(msgboxText, title);
        return
    end
    if outputv{10}<0
        msgboxText =  'Invalid input for segments'' width';
        title      = 'ERPLAB: continuousartifactGUI() error';
        errorfound(msgboxText, title);
        return
    end
else
    set(handles.edit_unmark, 'String', '')
    set(handles.edit_unmark, 'Enable', 'off')
    outputv{10} = [];
end
if get(handles.checkbox_move_onset, 'Value')
    if length(outputv{11})~=1
        msgboxText =  'Invalid input for segments'' displacement';
        title      = 'ERPLAB: continuousartifactGUI() error';
        errorfound(msgboxText, title);
        return
    end
    if isinf(outputv{11})
        msgboxText =  'Invalid input for segments'' displacement';
        title      = 'ERPLAB: continuousartifactGUI() error';
        errorfound(msgboxText, title);
        return
    end
else
    set(handles.edit_move_onset, 'String', '')
    set(handles.edit_move_onset, 'Enable', 'off')
    outputv{11} = [];
end

handles.output = outputv;
memoryCARTGUI.prompt    = prompt;
memoryCARTGUI.dlg_title = handles.dlg_title;
memoryCARTGUI.def       = outputv;
memoryCARTGUI.defx      = handles.defx;
memoryCARTGUI.colorseg  = handles.colorseg;
erpworkingmemory('continuousartifactGUI', memoryCARTGUI);

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function checkbox_firstart_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function checkbox_shortsegments_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    set(handles.edit_shortsegmentms, 'Enable', 'on')
else
    set(handles.edit_shortsegmentms, 'Enable', 'off')
end

%--------------------------------------------------------------------------
function edit_shortsegmentms_Callback(hObject, eventdata, handles)
v = str2num(get(hObject,'String'));
if v<1
    set(hObject,'String','');
    set(hObject,'Enable','off');
    set(handles.checkbox_shortsegments, 'Value', 0)
end

%--------------------------------------------------------------------------
function edit_shortsegmentms_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function checkbox_unmark_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    set(handles.edit_unmark, 'Enable', 'on')
else
    set(handles.edit_unmark, 'Enable', 'off')
end
%--------------------------------------------------------------------------
function edit_unmark_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_unmark_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function checkbox_move_onset_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    set(handles.edit_move_onset, 'Enable', 'on')
else
    set(handles.edit_move_onset, 'Enable', 'off')
end

%--------------------------------------------------------------------------
function edit_move_onset_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_move_onset_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_segmentcolor_Callback(hObject, eventdata, handles)
c = uisetcolor([0.83 0.82 0.79],'ERPLAB color segment') ;
set(handles.edit_patch_color,'BackgroundColor', c)

handles.colorseg = c;
%Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
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


function pushbutton_browsechan_Callback(hObject, eventdata, handles)
listch     = handles.listch;
indxlistch = handles.indxlistch;
indxlistch = indxlistch(indxlistch<=length(listch));
titlename  = 'Select Channel(s)';

if get(hObject, 'Value')
        if ~isempty(listch)
                ch = browsechanbinGUI(listch, indxlistch, titlename);
                if ~isempty(ch)
                        set(handles.edit4, 'String', vect2colon(ch, 'Delimiter', 'off'));
                        handles.indxlistch = ch;
                        % Update handles structure
                        guidata(hObject, handles);
                else
                        disp('User selected Cancel')
                        return
                end
        else
                msgboxText =  'No channel information was found';
                title = 'ERPLAB: basicfilter GUI input';
                errorfound(msgboxText, title);
                return
        end
end
