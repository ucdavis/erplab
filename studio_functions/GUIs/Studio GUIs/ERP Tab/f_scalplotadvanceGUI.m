% Author: Javier Lopez-Calderon % Sam London
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% EStudio Toolbox
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

function varargout = f_scalplotadvanceGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @f_scalplotadvanceGUI_OpeningFcn, ...
    'gui_OutputFcn',  @f_scalplotadvanceGUI_OutputFcn, ...
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
function f_scalplotadvanceGUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for f_scalplotadvanceGU
try
    pscale_legend = varargin{1};
catch
    %%{binnum, bindesc, type, latency, electrodes, elestyle, elec3D, ismaxim, 2Dvalue}
    pscale_legend = {1,1,1,1,0,'on','off',0,1};
end

binnum     = pscale_legend{1};
bindesc    = pscale_legend{2};
type       = pscale_legend{3};
latency    = pscale_legend{4};
electrodes = pscale_legend{5};
elestyle   = pscale_legend{6};
elec3D     = pscale_legend{7};
% colorbar   = val(6);
ismaxim    = pscale_legend{8};
is2Dmap = pscale_legend{9};

handles.is2Dmap = is2Dmap;
% Name & version
%
erplab_studio_default_values;
version = erplabstudiover;
set(handles.gui_chassis,'Name', ['EStudio ' version '   -   SCALP MAPPING ADVANCED GUI'])



set(handles.checkbox_binnumber,'Value', binnum)
set(handles.checkbox_bindescription,'Value', bindesc)
set(handles.checkbox_tvalue,'Value', type)
set(handles.checkbox_latency,'Value', latency)

if electrodes && ~strcmpi(elec3D, 'on')
    switch elestyle
        case 'on'
            set(handles.checkbox_electrodes,'Value', 1)
            set(handles.radiobutton_excludepoints,'Value', 0)
            set(handles.radiobutton_showenumber,'Value', 0)
            set(handles.radiobutton_showelabel,'Value', 0)
            set(handles.radiobutton_excludepoints,'Enable', 'off')
        case 'off'
            set(handles.checkbox_electrodes,'Value', 0)
            set(handles.radiobutton_excludepoints,'Value', 0)
            set(handles.radiobutton_showenumber,'Value', 0)
            set(handles.radiobutton_showelabel,'Value', 0)
            
            set(handles.radiobutton_excludepoints,'Enable', 'off')
            set(handles.radiobutton_showenumber,'Enable', 'off')
            set(handles.radiobutton_showelabel,'Enable', 'off')
        case 'numbers'
            set(handles.checkbox_electrodes,'Value', 1)
            set(handles.radiobutton_excludepoints,'Value', 1)
            set(handles.radiobutton_showenumber,'Value', 1)
            set(handles.radiobutton_showelabel,'Value', 0)
        case 'labels'
            set(handles.checkbox_electrodes,'Value', 1)
            set(handles.radiobutton_excludepoints,'Value', 1)
            set(handles.radiobutton_showenumber,'Value', 0)
            set(handles.radiobutton_showelabel,'Value', 1)
        case 'ptsnumbers'
            set(handles.checkbox_electrodes,'Value', 1)
            set(handles.radiobutton_excludepoints,'Value', 0)
            set(handles.radiobutton_showenumber,'Value', 1)
            set(handles.radiobutton_showelabel,'Value', 0)
        case 'ptslabels'
            set(handles.checkbox_electrodes,'Value', 1)
            set(handles.radiobutton_excludepoints,'Value', 0)
            set(handles.radiobutton_showenumber,'Value', 0)
            set(handles.radiobutton_showelabel,'Value', 1)
        otherwise
            set(handles.checkbox_electrodes,'Value', 0)
            set(handles.radiobutton_excludepoints,'Value', 0)
            set(handles.radiobutton_showenumber,'Value', 0)
            set(handles.radiobutton_showelabel,'Value', 0)
            
            set(handles.radiobutton_excludepoints,'Enable', 'off')
            set(handles.radiobutton_showenumber,'Enable', 'off')
            set(handles.radiobutton_showelabel,'Enable', 'off')
    end
    
    %         if ~elecexcpnts && ~elecshownum && ~elecshowlab
    %                 %'on','off','labels','numbers','ptslabels','ptsnumbers'
    %                 elestyle = 'on';
    %         elseif ~elecexcpnts && elecshownum && ~elecshowlab
    %                 %'on','off','labels','numbers','ptslabels','ptsnumbers'
    %                 elestyle = 'numbers';
    %         elseif ~elecexcpnts && ~elecshownum && elecshowlab
    %                 %'on','off','labels','numbers','ptslabels','ptsnumbers'
    %                 elestyle = 'labels';
    %         elseif elecexcpnts && elecshownum && ~elecshowlab
    %                 %'on','off','labels','numbers','ptslabels','ptsnumbers'
    %                 elestyle = 'ptsnumbers';
    %         elseif elecexcpnts && ~elecshownum && elecshowlab
    %                 %'on','off','labels','numbers','ptslabels','ptsnumbers'
    %                 elestyle = 'ptslabels';
    %         else
    %                 return
    %         end
else
    %elestyle = 'off';
    set(handles.checkbox_electrodes,'Value', 0);
    set(handles.radiobutton_excludepoints,'Enable', 'off','Value',0)
    set(handles.radiobutton_showenumber,'Enable', 'off','Value',0);
    set(handles.radiobutton_showelabel,'Enable', 'off','Value',0);
    set(handles.checkbox_3Delec,'Value', 0,'Enable', 'off');
end
if is2Dmap
    set(handles.checkbox_3Delec,'Value', 0)
    set(handles.checkbox_3Delec,'Enable', 'off')
else
    if strcmpi(elec3D, 'on')
        set(handles.checkbox_3Delec,'Value', 1)
        set(handles.checkbox_electrodes,'Value', 1)
        
        set(handles.radiobutton_excludepoints,'Value', 0)
        set(handles.radiobutton_showenumber,'Value', 0)
        set(handles.radiobutton_showelabel,'Value', 0)
        
        %set(handles.checkbox_electrodes,'Enable', 'off')
        set(handles.radiobutton_excludepoints,'Enable', 'off')
        set(handles.radiobutton_showenumber,'Enable', 'off')
        set(handles.radiobutton_showelabel,'Enable', 'off')
    end
end

set(handles.checkbox_maximize,'Value', ismaxim)
%

try
    pagif_legend = varargin{2};
catch
    %%{binnum, bindesc, type, latency, electrodes, elestyle, elec3D, ismaxim, 2Dvalue}
    pagif_legend = {0,[],'',[]};
end

agif   = pagif_legend{1};
FPS    = pagif_legend{2};
fnameagif = pagif_legend{3};
latency   =pagif_legend{4};
handles.latency = latency;


if agif>0
    set(handles.checkbox_animation,'Value', 1)
    set(handles.checkbox_adjust1frame,'Enable', 'on')
    set(handles.edit_fps,'Enable', 'on')
    set(handles.edit_fps,'String', num2str(FPS))
    set(handles.edit_fname_animation,'Enable', 'on')
    set(handles.edit_fname_animation,'String', fnameagif)
    set(handles.pushbutton_browse_animation,'Enable', 'on')
    
    if agif==2
        set(handles.checkbox_adjust1frame,'Value', 1)
    else
        set(handles.checkbox_adjust1frame,'Value', 0)
    end
    set(handles.checkbox_adjust1frame,'Enable', 'on')
else
    set(handles.checkbox_animation,'Value', 0)
    set(handles.checkbox_animation,'Value', 0)
    set(handles.checkbox_adjust1frame,'Value', 0)
    set(handles.checkbox_adjust1frame,'Enable', 'off')
    set(handles.edit_fps,'Enable', 'off')
    set(handles.edit_fname_animation,'Enable', 'off')
    set(handles.pushbutton_browse_animation,'Enable', 'off')
    set(handles.checkbox_adjust1frame,'Value', 0)
    set(handles.checkbox_adjust1frame,'Enable', 'off')
end


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

% PDF button
% pdfbutton

% set all objects
% setall(hObject, eventdata, handles)

% UIWAIT makes geterpvaluesGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

%--------------------------------------------------------------------------
function varargout = f_scalplotadvanceGUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
% varargout{2} = handles.ERP;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)


%--------------------------------------------------------------------------
function pushbutton_OK_Callback(hObject, eventdata, handles)
% Animation
%
if get(handles.checkbox_animation, 'Value')
    if get(handles.checkbox_adjust1frame, 'Value')
        isagif    = 2; % adjust first frame
    else
        isagif    = 1;
    end
    
    FPS    = str2num(get(handles.edit_fps, 'String'));
    fnameagif = get(handles.edit_fname_animation, 'String');
    
    if isempty(FPS) || FPS<1 || FPS>1000
        msgboxText =  'Error: You must specify a scalar value between 1 and 1000 inclusive';
        title = 'EStudio: f_scalplotadvanceGUI() error:';
        errorfound(msgboxText, title);
        return
    end
    if isempty(strtrim(fnameagif))
        msgboxText =  'Error: You must specify a valid file name for your animated GIF';
        title = 'EStudio: f_scalplotadvanceGUI() error:';
        errorfound(msgboxText, title);
        return
    else
        [pthxz, fnamez, ext] = fileparts(fnameagif);
        if strcmp(ext,'')
            ext   = '.gif';
        end
        fnameagif = fullfile(pthxz,[ fnamez ext]);
    end
else
    isagif    = 0;
    FPS       = [];
    fnameagif = '';
end



binnum     = get(handles.checkbox_binnumber,'Value');
bindesc    = get(handles.checkbox_bindescription,'Value');
type       = get(handles.checkbox_tvalue,'Value');
latency    = get(handles.checkbox_latency,'Value');
electrodes = get(handles.checkbox_electrodes,'Value');

elecexcpnts = get(handles.radiobutton_excludepoints,'Value');
elecshownum = get(handles.radiobutton_showenumber,'Value');
elecshowlab = get(handles.radiobutton_showelabel,'Value');

if electrodes
    if ~elecexcpnts && ~elecshownum && ~elecshowlab
        %'on','off','labels','numbers','ptslabels','ptsnumbers'
        elestyle = 'on';
    elseif ~elecexcpnts && elecshownum && ~elecshowlab
        %'on','off','labels','numbers','ptslabels','ptsnumbers'
        elestyle = 'ptsnumbers';
    elseif ~elecexcpnts && ~elecshownum && elecshowlab
        %'on','off','labels','numbers','ptslabels','ptsnumbers'
        elestyle = 'ptslabels';
    elseif elecexcpnts && elecshownum && ~elecshowlab
        %'on','off','labels','numbers','ptslabels','ptsnumbers'
        elestyle = 'numbers';
    elseif elecexcpnts && ~elecshownum && elecshowlab
        %'on','off','labels','numbers','ptslabels','ptsnumbers'
        elestyle = 'labels';
    else
        return
    end
else
    elestyle = 'off';
end

el3D = get(handles.checkbox_3Delec,'Value');
if el3D
    elec3D = 'on';
else
    elec3D = 'off';
end

% colorbar   = get(handles.checkbox_cbar,'Value');
ismaxim    = get(handles.checkbox_maximize,'Value');

is2Dmap=handles.is2Dmap;
%%{binnum, bindesc, type, latency, electrodes, elestyle, elec3D, ismaxim, 2Dvalue}
pscale_legend = {binnum, bindesc, type, latency, electrodes, elestyle, elec3D, ismaxim,is2Dmap};

%%isagif; FPS;fnameagif
pagif_legend = {isagif,FPS,'',fnameagif};


handles.output  = {pscale_legend,pagif_legend};

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);
%         end
% end






%--------------------------------------------------------------------------
function edit_customblc_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end







%--------------------------------------------------------------------------
function edit_exchan_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_exchan_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_exchan_Callback(hObject, eventdata, handles)
numch = get(hObject, 'Value');
nums  = get(handles.edit_exchan, 'String');
nums  = [nums ' ' num2str(numch)];
set(handles.edit_exchan, 'String', nums);

%--------------------------------------------------------------------------
function popupmenu_exchan_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function checkbox_animation_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    set(handles.edit_fps,'Enable', 'on')
    set(handles.edit_fname_animation,'Enable', 'on')
    set(handles.pushbutton_browse_animation,'Enable', 'on')
    set(handles.checkbox_adjust1frame,'Enable', 'on')
else
    set(handles.edit_fps,'Enable', 'off')
    set(handles.edit_fname_animation,'Enable', 'off')
    set(handles.pushbutton_browse_animation,'Enable', 'off')
    set(handles.checkbox_adjust1frame,'Enable', 'off')
end

%--------------------------------------------------------------------------
function edit_fname_animation_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_fname_animation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_browse_animation_Callback(hObject, eventdata, handles)

%
% Save GIF, mov, or mpg
%
prename = get(handles.edit_fname_animation,'String');
%[blfilename, blpathname, filterindex] = uiputfile({'*.gif';'*.*'},'Save animation as',prename);

[blfilename, blpathname, filterindex] = uiputfile( ...
    {'*.gif','Animated GIF (*.gif)';
    '*.mat', 'Matlab movie (*.mat)';...
    '*.avi','AVI file (*.avi)'},...
    'Save animation as', prename);

if isequal(blfilename,0)
    disp('User selected Cancel')
    return
else
    [px, fname, ext] = fileparts(blfilename);
    if  filterindex==1
        ext = '.gif';
    elseif  filterindex==2
        ext = '.mat';
    elseif  filterindex==3
        ext = '.avi';
    else
        ext = '.gif';
    end
    
    fname = [ fname ext];
    
    fullgifname = fullfile(blpathname, fname);
    set(handles.edit_fname_animation,'String', fullgifname);
    disp(['Animatation will be saved at ' fullgifname])
end

%--------------------------------------------------------------------------
function edit_fps_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_fps_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
% function checkbox_colorbar_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton_ploterp_Callback(hObject, eventdata, handles)
plotset = getplotset(hObject, eventdata, handles);
if isempty(plotset.ptime)
    return
else
    plotset.ptime.binArray = plotset.pscalp.binArray ;
    plotset.ptime.blcorr   =  plotset.pscalp.baseline;
    assignin('base','plotset', plotset);
    handles.eplot = 1;
    
    %Update handles structure
    guidata(hObject, handles);
    uiresume(handles.figure1);
end




%--------------------------------------------------------------------------
function checkbox_adjust1frame_Callback(hObject, eventdata, handles)



%--------------------------------------------------------------------------
function popupmenu_orientation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%--------------------------------------------------------------------------
function edit_customview_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%--------------------------------------------------------------------------
function popupmenu_measurement_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




%--------------------------------------------------------------------------
function popupmenu_mapstyle_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%--------------------------------------------------------------------------
function checkbox_realtime_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    lat = handles.latency;
    if isempty(lat)
        msgboxText =  'You must specify a latency vector first.';
        title = 'EStudio: f_scalplotadvancedGUI input';
        errorfound(msgboxText, title);
        return
    end
%     lat = str2num(lat);
    T = unique_bc2(diff(lat));
    if isempty(T)
        msgboxText =  'You must specify a latency vector first.';
        title = 'EStudio: f_scalplotadvancedGUI input';
        errorfound(msgboxText, title);
        return
    end
    if length(T)>1
        msgboxText =  ['The latency vector does not have a fixed step to determine its periodicity.\n\n'...
            'You may use colon notation, e.g. start:step:end, to specify your latency vector.\n'...
            'This may work better to generate the time of each frame.'];
        title = 'EStudio: f_scalplotadvancedGUI input';
        errorfound(sprintf(msgboxText), title);
        return
    end
    f = round(1/(T/1000));
    set(handles.edit_fps, 'String', num2str(f));
    set(handles.edit_fps,'Enable', 'off')
else
    set(handles.edit_fps,'Enable', 'on')
end




%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% plotset = evalin('base', 'plotset');
% plotset.pscalp = [];
handles.output = {};

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
    %The GUI is still in UIWAIT, us UIRESUME
%     plotset = evalin('base', 'plotset');
%     plotset.pscalp = [];
    handles.output = {};
    %Update handles structure
    guidata(hObject, handles);
    uiresume(handles.gui_chassis);
else
    % The GUI is no longer waiting, just close it
    delete(handles.gui_chassis);
end


% --- Executes on button press in checkbox_binnumber.
function checkbox_binnumber_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_binnumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_binnumber


% --- Executes on button press in checkbox_bindescription.
function checkbox_bindescription_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_bindescription (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_bindescription


% --- Executes on button press in checkbox_latency.
function checkbox_latency_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_latency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_latency


% --- Executes on button press in checkbox_tvalue.
function checkbox_tvalue_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_tvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_tvalue


% --- Executes on button press in checkbox_maximize.
function checkbox_maximize_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_maximize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_maximize


% --- Executes on button press in checkbox_electrodes.
function checkbox_electrodes_Callback(hObject, eventdata, handles)

is2Dmap = handles.is2Dmap;

if get(hObject, 'value')
    set(handles.radiobutton_excludepoints,'Enable', 'off')
    set(handles.radiobutton_showenumber,'Enable', 'on')
    set(handles.radiobutton_showelabel,'Enable', 'on')
    
    set(handles.checkbox_3Delec,'Enable', 'on')
else
    set(handles.radiobutton_excludepoints,'Value', 0)
    set(handles.radiobutton_showenumber,'Value', 0)
    set(handles.radiobutton_showelabel,'Value', 0)
    set(handles.checkbox_3Delec,'Value', 0)
    
    set(handles.radiobutton_excludepoints,'Enable', 'off')
    set(handles.radiobutton_showenumber,'Enable', 'off')
    set(handles.radiobutton_showelabel,'Enable', 'off')
    set(handles.checkbox_3Delec,'Enable', 'off')
end




% --- Executes on button press in radiobutton_excludepoints.
function radiobutton_excludepoints_Callback(hObject, eventdata, handles)
% if get(hObject, 'value')
%
% else
%
% end


% --- Executes on button press in checkbox_3Delec.
function checkbox_3Delec_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    %set(handles.checkbox_electrodes,'Value', 0)
    set(handles.radiobutton_excludepoints,'Value', 0)
    set(handles.radiobutton_showenumber,'Value', 0)
    set(handles.radiobutton_showelabel,'Value', 0)
    
    %set(handles.checkbox_electrodes,'Enable', 'off')
    set(handles.radiobutton_excludepoints,'Enable', 'off')
    set(handles.radiobutton_showenumber,'Enable', 'off')
    set(handles.radiobutton_showelabel,'Enable', 'off')
else
    %set(handles.radiobutton_excludepoints,'Value', 0)
    %set(handles.radiobutton_showenumber,'Value', 0)
    %set(handles.radiobutton_showelabel,'Value', 0)
    
    %set(handles.checkbox_electrodes,'Enable', 'off')
    set(handles.radiobutton_excludepoints,'Enable', 'off')
    set(handles.radiobutton_showenumber,'Enable', 'on')
    set(handles.radiobutton_showelabel,'Enable', 'on')
end


% --- Executes on button press in radiobutton_showelabel.
function radiobutton_showelabel_Callback(hObject, eventdata, handles)

if get(hObject, 'value')
    set(handles.radiobutton_showenumber,'Value', 0)
    set(handles.radiobutton_excludepoints,'Enable', 'on')
else
    %set(handles.radiobutton_showelabel,'Value', 1)
    if ~get(handles.radiobutton_showelabel,'Value')
        set(handles.radiobutton_excludepoints,'Value', 0)
        set(handles.radiobutton_excludepoints,'Enable', 'off')
    end
end


% --- Executes on button press in radiobutton_showenumber.
function radiobutton_showenumber_Callback(hObject, eventdata, handles)
if get(hObject, 'value')
    set(handles.radiobutton_showelabel,'Value', 0)
    set(handles.radiobutton_excludepoints,'Enable', 'on')
else
    %set(handles.radiobutton_showenumber,'Value', 1
    if ~get(handles.radiobutton_showenumber,'Value')
        set(handles.radiobutton_excludepoints,'Value', 0)
        set(handles.radiobutton_excludepoints,'Enable', 'off')
    end
end



% --- Executes during object creation, after setting all properties.
function checkbox_maximize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox_maximize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes during object creation, after setting all properties.
function checkbox_electrodes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox_maximize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
