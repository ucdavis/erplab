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

function varargout = artifactinterpGUI(varargin)
% ARTIFACTINTERPGUI MATLAB code for artifactinterpGUI.fig
%      ARTIFACTINTERPGUI, by itself, creates a new ARTIFACTINTERPGUI or raises the existing
%      singleton*.
%
%      H = ARTIFACTINTERPGUI returns the handle to a new ARTIFACTINTERPGUI or the handle to
%      the existing singleton*.
%
%      ARTIFACTINTERPGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ARTIFACTINTERPGUI.M with the given input arguments.
%
%      ARTIFACTINTERPGUI('Property','Value',...) creates a new ARTIFACTINTERPGUI or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before artifactinterpGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to artifactinterpGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help artifactinterpGUI

% Last Modified by GUIDE v2.5 31-May-2023 11:45:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @artifactinterpGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @artifactinterpGUI_OutputFcn, ...
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

% --- Executes just before artifactinterpGUI is made visible.
function artifactinterpGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to artifactinterpGUI (see VARARGIN)

% Choose default command line output for artifactinterpGUI
handles.output = []; %hObject
%handles.output = [];

%default "defx" positions:
%first pos: no previous flag selected
%second pos: no previous method selected (default to 'spherical')
%third pos: no prev electrode selected (should agree with fourth pos)
%fourth pos: no prev "channel-label" selected (should agree with third pos)
%fifth pos: no prev "channels" to ignore

try
    dlg_title = varargin{1}{1}; %title
    def = varargin{2}; % memory
    defx = varargin{3}; %incase of reset
    chanlabels = varargin{4};
    active_flags = varargin{5};
    
catch 
    dlg_title = 'Interpolate Flagged Artifact Epochs';
    def = {0, 'spherical',[],[],[]};  %holds all of the defaults
    defx =def; 
    chanlabels = [];
    active_flags = varargin{5};   
end


handles.defx = defx; 

%prepare important handles-variables for output 
handles.flagx = def{1};
handles.methodx = def{2};
handles.indxlistch = def{3};
handles.chanxlabel = def{4}; 
handles.ignoreChannels = def{5}; 
handles.many_electrodes = def{6}; 
handles.threshold_perc = def{7}; 

%set flag button positions defaults
for j=1:8
        handles.flg(j) = 0; %at this point, no flag selected
end
for i=2:8
        set(handles.(['flag_' num2str(i)]),'Value', 0);
end


% query currently marked epochs ONLY!
flagx = active_flags; %flagx has currently active flags info

%if flags were detected, take "no flags were detected off the screen 
if any(flagx)
    set(handles.NoFlags1,'Visible', 'off');
    set(handles.NoFlags2,'Visible', 'off');
end

if ~any(flagx)
    %if no active flags, handles.flagx = 0
    handles.flagx = 0;
end


flags_active = []; 
%mark flags on GUI for user to see currently marked flags & choose 
for f = 1:length(flagx)
    if flagx(f)>0
        flags_active(f) = f; 
        set(handles.(['flag_' num2str(f)]),'value', 1);
        set(handles.(['flag_' num2str(f)]),'Enable', 'inactive');
        handles.flg(f) = 1; %whatever is selected, put into backup array
        %place interpolate choice on last reasonable flag
        %overridden by previous user choice (see below)
        set(handles.(['radiobutton' num2str(f)]), 'value',1); 
    else
        %turn off/invisible all not-active-flag choices
        if f < 9 %no flags over 8
            set(handles.(['flag_' num2str(f)]),'Visible','off'); 
            set(handles.(['radiobutton' num2str(f)]), 'Enable','inactive');
            set(handles.(['radiobutton' num2str(f)]), 'Visible','off');
        end
    end
    
end

%if user selected a flag previously & it is valid,  it will show here 

if handles.flagx ~= 0 
    
    if ismember(handles.flagx,flags_active) 
        set(handles.(['radiobutton' num2str(handles.flagx)]), 'value',1); 
    end
end

%if user had previous ignore channel, populate ignore channels box

if ~isempty(handles.ignoreChannels) 
    %if user previously had channels to ignore
    
    editStr = num2str(handles.ignoreChannels);
    set(handles.editbox_ignoreChannels,'String',editStr); 
    
end

%flag 1 is reserved 
set(handles.flag_1, 'Value',1); %flag 1 is reserved 
set(handles.flag_1, 'Enable', 'inactive');% flag 1 is pressed but inactive
%set(handles.flag_1, 'Visible', 'off');
set(handles.radiobutton1, 'Enable', 'inactive'); 
%set(handles.radiobutton1, 'Visibile', 'off'); 

%set interpolate method choice 

if strcmpi(handles.methodx,'spherical') 
    set(handles.radiobutton_spherical,'Value',1); 
else
    set(handles.radiobutton_invdist,'Value',1); 
end

%set electrode options 
if handles.many_electrodes == 1 
    set(handles.radiobutton_interpAny,'Value',1);
    set(handles.radiobutton_interpOne,'Value',0);   
    set(handles.electrode_threshold,'String',num2str(handles.threshold_perc)); 
    set(handles.electrode_threshold,'Enable','On');
    set(handles.popupmenu1,'Enable','Off'); 
    %set(handles.popupmenu2,'Enable','Off'); 
else
    set(handles.radiobutton_interpAny,'Value',0);
    set(handles.radiobutton_interpOne,'Value',1);
    set(handles.electrode_threshold,'String',num2str(handles.threshold_perc)); 
    set(handles.electrode_threshold,'Enable','On');    
    set(handles.popupmenu1,'Enable','On');
   % set(handles.popupmenu2,'Enable','On'); 
end


%title of gui 
set(handles.gui_chassis, 'Name', dlg_title);

%
% Prepare List of current Channels
%
listch = {''};
nchan  = length(chanlabels); % Total number of channels
if isempty(chanlabels)
        for e = 1:nchan
                chanlabels{e} = ['Ch' num2str(e)];
        end
end
for ch =1:nchan
        listch{ch} = [num2str(ch) ' = ' chanlabels{ch} ];
end

handles.listch     = listch;
handles.indxlistch = def{1}; % what channel is prev selected

%set channels popup menu
set(handles.popupmenu1, 'string', listch); 
%set(handles.popupmenu2, 'string', listch); 

%
% Paint GUI
%
handles = painterplab(handles);

%
% Set font size
%
handles = setfonterplab(handles);

%set(handles.uipanel1, 'BackgroundColor', 'b');
%set(handles.flag_1, 'Backgroundcolor', [0 0 0]); 
%set(handles.flag_1,'string', '<HTML><BODY bgcolor ="red">hi'); 

% flag 1 is pressed but inactive


% Update handles structure
guidata(hObject, handles);
%guidata(handles.gui_chassis, handles);

%artifactinterpGUI(hObject, handles, false);

% UIWAIT makes artifactinterpGUI wait for user response (see UIRESUME)
 uiwait(handles.gui_chassis);


% --- Outputs from this function are returned to the command line.
function varargout = artifactinterpGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.gui_chassis); 
%varargout{1} = [];
pause(0.1)



% --- Executes on button press in flag_1.
function flag_1_Callback(hObject, eventdata, handles)
% hObject    handle to flag_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in flag_2.
function flag_2_Callback(hObject, eventdata, handles)
% hObject    handle to flag_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in flag_3.
function flag_3_Callback(hObject, eventdata, handles)
% hObject    handle to flag_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in flag_4.
function flag_4_Callback(hObject, eventdata, handles)
% hObject    handle to flag_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in flag_5.
function flag_5_Callback(hObject, eventdata, handles)
% hObject    handle to flag_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in flag_6.
function flag_6_Callback(hObject, eventdata, handles)
% hObject    handle to flag_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in flag_7.
function flag_7_Callback(hObject, eventdata, handles)
% hObject    handle to flag_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in flag_8.
function flag_8_Callback(hObject, eventdata, handles)
% hObject    handle to flag_8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_interpolate.
function pushbutton_interpolate_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_interpolate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%query flag selected 
for i=2:8 %only flags 2-8 for now
        if get(handles.(['radiobutton' num2str(i)]),'Value')
                handles.flagx = i;
        end;
end

if handles.flagx == 0
    %if no active flag, error
    error_msg = sprintf('Error: No flags on epoched data. Cannot selectively interpolate epochs!');
    error(error_msg); 
    
    
end

%query interpolation method

if get(handles.radiobutton_spherical,'Value') 
    handles.methodx = 'spherical';
else
    handles.methodx = 'inverse_distance';
end

%query channel selected
allItems = get(handles.popupmenu1,'String'); 
chanIndex = get(handles.popupmenu1,'Value');
%measIndex = get(handles.popupmenu2,'Value'); 

handles.indxlistch = chanIndex; 
handles.chanxlabel = allItems{chanIndex}; 
%meas_chan = allItems{measIndex}; 

% updates handles.output (include channels to ignore/replace)
% order: flag to use, method of interpolate, channel index,
% channel_to_interp, channels to replace 
handles.output = {handles.flagx, handles.methodx, ...
    handles.indxlistch, handles.chanxlabel, handles.ignoreChannels, ...
    handles.radiobutton_interpAny.Value, handles.threshold_perc};

guidata(hObject, handles);
uiresume(handles.gui_chassis);




% --- Executes on button press in radiobutton_spherical.
function radiobutton_spherical_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_spherical (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_spherical


% --- Executes on button press in radiobutton_inverseDistance.
function radiobutton_inverseDistance_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_inverseDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_inverseDistance



function editbox_replaceChannels_Callback(hObject, eventdata, handles)
% hObject    handle to editbox_replaceChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editbox_replaceChannels as text
%        str2double(get(hObject,'String')) returns contents of editbox_replaceChannels as a double


% --- Executes during object creation, after setting all properties.
function editbox_replaceChannels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editbox_replaceChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editbox_ignoreChannels_Callback(hObject, eventdata, handles)
% hObject    handle to editbox_ignoreChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editbox_ignoreChannels as text
%        str2double(get(hObject,'String')) returns contents of editbox_ignoreChannels as a double

% Strip any non-numeric token and replace w/ whitespace (' ')
editString              = regexprep(get(hObject,'String'), '[\D]', ' ');
handles.replaceChannels = str2num(editString);  %#ok<ST2NM>

% Display corrected channels back to GUI
set(handles.editbox_ignoreChannels, 'String', editString);

% Save the new replace channels value
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function editbox_ignoreChannels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editbox_ignoreChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_viewer.
function checkbox_viewer_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_viewer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_viewer


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get list of channels
%chanlist = handles.listch;  

%update handles struct
%guidata(handles.gui_chassis,handles); 

%set(handles.popupmenu1, 'string', chanlist)






% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function flag_2_CreateFcn(hObject, eventdata, handles)
set(hObject,'Backgroundcolor',[0 0 0]);
% hObject    handle to flag_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton_help.
function pushbutton_help_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('https://github.com/lucklab/erplab/wiki/Artifact-Detection-in-Epoched-Data#ERPLAB-Post-Artifact-Detection-Epoch-Interpolation',...
    '-browser');


% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);


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


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton7.
function radiobutton7_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton7


% --- Executes on button press in radiobutton_interpOne.
function radiobutton_interpOne_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_interpOne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_interpOne

if get(hObject,'Value') == 1
    set(handles.radiobutton_interpAny,'Value',0');
    set(handles.electrode_threshold,'Enable','On');
    
    set(handles.radiobutton_interpOne,'Value',1);
    set(handles.popupmenu1,'Enable','On'); 
    %set(handles.popupmenu2,'Enable','Off'); 
    

    
end



function electrode_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to electrode_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of electrode_threshold as text
%        str2double(get(hObject,'String')) returns contents of electrode_threshold as a double

% Test string
perc = str2num(get(hObject,'String')); 
if perc >= 1 & perc <= 100
    handles.threshold_perc = perc; 
else
    msgboxText{1} =  'ERROR: Cannot be less than 1 or greater than 100';
    title = 'ERPLAB: input error';
    errorfound(msgboxText, title);
    handles.threshold_perc = 10; 
    set(handles.electrode_threshold,'String',''); 
    return
end


% --- Executes during object creation, after setting all properties.
function electrode_threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to electrode_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton_interpAny.
function radiobutton_interpAny_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_interpAny (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject,'Value') == 1 %interpolate any flagged channel
    
    set(handles.radiobutton_interpOne,'Value',0);
    set(handles.popupmenu1,'Enable','Off'); 
    %set(handles.popupmenu2,'Enable','On'); 
    
    set(handles.radiobutton_interpAny,'Value',1);
    set(handles.electrode_threshold,'Enable','On'); 
    
    
end
    

% Hint: get(hObject,'Value') returns toggle state of radiobutton_interpAny


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Prepare List of current Channels
%
% listch = {''};
% nchan  = length(chanlabels); % Total number of channels
% if isempty(chanlabels)
%         for e = 1:nchan
%                 chanlabels{e} = ['Ch' num2str(e)];
%         end
% end
% for ch =1:nchan
%         listch{ch} = [num2str(ch) ' = ' chanlabels{ch} ];
% end

listch = handles.listch; 
indxlistch = 1:numel(listch); 
titlename = 'Select Channels to Ignore'; 


if ~isempty(listch)
    ch = browsechanbinGUI(listch, indxlistch, titlename);
    if ~isempty(ch)
        %set(handles.chwindow, 'String', vect2colon(ch, 'Delimiter', 'off'));
        set(handles.editbox_ignoreChannels,'String',vect2colon(ch, 'Delimiter','off'));
        %handles.indxlistch = ch;
        % Update app structure
        handles.ignoreChannels = ch;
        guidata(hObject, handles);
        %                     guidata(hObject, handles);
        %                     redraw_outliers(hObject, eventdata, handles);
        %                     guidata(hObject, handles);
        
    else
        disp('User selected Cancel')
        return
    end
else
    msgboxText =  'No channel information was found';
    title = 'ERPLAB: BrowseChans GUI input';
    errorfound(msgboxText, title);
    return
end



%handles.indxlistch = def{1}; % what channel is prev selected

%set channels popup menu
set(handles.popupmenu1, 'string', listch); 
