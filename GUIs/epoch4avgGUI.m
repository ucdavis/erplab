%
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

function varargout = epoch4avgGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @epoch4avgGUI_OpeningFcn, ...
        'gui_OutputFcn',  @epoch4avgGUI_OutputFcn, ...
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


% --- Executes just before epoch4avgGUI is made visible.
function epoch4avgGUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for epoch4avgGUI
handles.output = hObject;
try
        nepochperdata  = varargin{1};
catch
        nepochperdata = 0;
end

handles.nepochperdata = nepochperdata;

ardetect_list = {'ignore artifact detection','exclude marked epochs (recommended)', 'include ONLY marked epochs (use with care)'};
catching_list = {'sequential','at random', 'odd epochs', 'even epochs', 'prime epochs'};
instance_list = {'first','anywhere', 'last'};

set(handles.popupmenu_ardetection,'String', ardetect_list)
set(handles.popupmenu_catching,'String', catching_list)
set(handles.popupmenu_instance,'String', instance_list)


%
% Gui memory
%
epoch4avgGUI = erpworkingmemory('epoch4avgGUI');


if isempty(epoch4avgGUI)
        
        nepochsperbin = [];
        ardetcriterio = 0;
        catching      = 0;
        reference     = 0;
        episode       = 'any';
        instance      = 0;
        warnme        = 1;
        save_not_selected = 0;
else
    
        nepochsperbin = epoch4avgGUI.nepochsperbin;
        ardetcriterio = epoch4avgGUI.ardetcriterio;
        catching      = epoch4avgGUI.catching;
        reference     = epoch4avgGUI.reference;
        episode       = epoch4avgGUI.episode;
        instance      = epoch4avgGUI.instance;
        warnme        = epoch4avgGUI.warnme;
        save_not_selected = epoch4avgGUI.save_not_selected;
end

epoch4avgGUI.save_not_selected = 0;

%Number of epochs per bin to average
if ischar(nepochsperbin)
        set(handles.radiobutton_asitis,'Value', 1)
        set(handles.radiobutton_asfollowed,'Value', 0)
        set(handles.edit_numberofepochsperbin,'Enable', 'off')
else
        if isempty(nepochsperbin)
                set(handles.radiobutton_asitis,'Value', 1)
                set(handles.radiobutton_asfollowed,'Value', 0)
                set(handles.edit_numberofepochsperbin,'Enable', 'off')
        else
                set(handles.radiobutton_asitis,'Value', 0)
                set(handles.radiobutton_asfollowed,'Value', 1)
                set(handles.edit_numberofepochsperbin,'Enable', 'on')
                set(handles.edit_numberofepochsperbin,'String', vect2colon(nepochsperbin,'Delimiter','off'))
        end
end

%Artifact detection criterion
set(handles.popupmenu_ardetection,'Value', ardetcriterio+1)

% Epoch catching
set(handles.popupmenu_catching,'Value', catching+1)

% Reference
if reference==0 % absolute
        set(handles.radiobutton_refabsolute,'Value', 1)
else
        set(handles.radiobutton_refrelative,'Value', 1)
end

% Epochs' episode
if ischar(episode)
        set(handles.radiobutton_fromanytime,'Value', 1)
        set(handles.radiobutton_frompart,'Value', 0)
        set(handles.edit_frompart,'Enable', 'off')
else
        if mod(length(episode),2)>0
                set(handles.radiobutton_fromanytime,'Value', 1)
                set(handles.radiobutton_frompart,'Value', 0)
                set(handles.edit_frompart,'Enable', 'off')
                %set(handles.edit_outof,'Enable', 'off')
        else
                set(handles.radiobutton_fromanytime,'Value', 0)
                set(handles.radiobutton_frompart,'Value', 1)
                set(handles.edit_frompart,'Enable', 'on')
                %set(handles.edit_outof,'Enable', 'on')
                set(handles.edit_frompart,'String', vect2colon(episode, 'Delimiter','off'))
                %set(handles.edit_outof,'String', num2str(total))
        end
end

% Instance
set(handles.popupmenu_instance,'Value', instance+1)

% Warn me
if warnme
        set(handles.checkbox_warnme, 'Value', 1)
else
        set(handles.checkbox_warnme, 'Value', 0)
end


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
% helpbutton

drawnow
uiwait(handles.gui_chassis);

% --- Outputs from this function are returned to the command line.
function varargout = epoch4avgGUI_OutputFcn(~, eventdata, handles)
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)
%-------------------------------------------------------------------------
function radiobutton_asitis_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.radiobutton_asfollowed,'Value', 0)
        set(handles.edit_numberofepochsperbin,'Enable', 'off')
else
        set(hObject,'Value', 1)
end

%-------------------------------------------------------------------------
function radiobutton_asfollowed_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.radiobutton_asitis,'Value', 0)
        set(handles.edit_numberofepochsperbin,'Enable', 'on')
else
        set(hObject,'Value', 1)
end

%-------------------------------------------------------------------------
function edit_numberofepochsperbin_Callback(hObject, eventdata, handles)
nepochperdata = handles.nepochperdata;
numperep      = str2num(get(hObject,'String'));
tf = isnegative(numperep, 'first');

if tf
        msgboxText =  ['The number of epochs per bin must have positive integer values.\n'...
                'For instance, 230 460 230 690\n\n'...
                'For a fix number of epochs per bin just specify one single value.'];
        title = 'ERPLAB: epoch4avgGUI input error';
        errorfound(sprintf(msgboxText), title);
        return
end
if ~isempty(numperep)
        if max(numperep)>max(nepochperdata)
                msgboxText =  ['Specified number of epochs does not seem realistic.\n'...
                        'The largest dataset for averaging only has %g epochs.'];
                title = 'ERPLAB: epoch4avgGUI input error';
                errorfound(sprintf(msgboxText, max(nepochperdata)), title);
                return
        end
end

%-------------------------------------------------------------------------
function edit_numberofepochsperbin_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%-------------------------------------------------------------------------
function radiobutton_ignoreAD_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        %set(handles.radiobutton_ignoreAD,'Value', 0)
        set(handles.radiobutton_excludemarkedepochs,'Value', 0)
        set(handles.radiobutton_includeonlymarked,'Value', 0)
else
        set(hObject,'Value', 1)
end

%-------------------------------------------------------------------------
function radiobutton_excludemarkedepochs_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.radiobutton_ignoreAD,'Value', 0)
        %set(handles.radiobutton_excludemarkedepochs,'Value', 0)
        set(handles.radiobutton_includeonlymarked,'Value', 0)
else
        set(hObject,'Value', 1)
end

%-------------------------------------------------------------------------
function radiobutton_includeonlymarked_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.radiobutton_ignoreAD,'Value', 0)
        set(handles.radiobutton_excludemarkedepochs,'Value', 0)
        %set(handles.radiobutton_includeonlymarked,'Value', 0)
else
        set(hObject,'Value', 1)
end

%-------------------------------------------------------------------------
function radiobutton_onthefly_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        %set(handles.radiobutton_onthefly,'Value', 0)
        set(handles.radiobutton_atrandom,'Value', 0)
        set(handles.radiobutton_oddepochs,'Value', 0)
        set(handles.radiobutton_evenepochs,'Value', 0)
else
        set(hObject,'Value', 1)
end

%-------------------------------------------------------------------------
function radiobutton_atrandom_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.radiobutton_onthefly,'Value', 0)
        %set(handles.radiobutton_atrandom,'Value', 0)
        set(handles.radiobutton_oddepochs,'Value', 0)
        set(handles.radiobutton_evenepochs,'Value', 0)
else
        set(hObject,'Value', 1)
end

%-------------------------------------------------------------------------
function radiobutton_oddepochs_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.radiobutton_onthefly,'Value', 0)
        set(handles.radiobutton_atrandom,'Value', 0)
        %set(handles.radiobutton_oddepochs,'Value', 0)
        set(handles.radiobutton_evenepochs,'Value', 0)
else
        set(hObject,'Value', 1)
end

%-------------------------------------------------------------------------
function radiobutton_evenepochs_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.radiobutton_onthefly,'Value', 0)
        set(handles.radiobutton_atrandom,'Value', 0)
        set(handles.radiobutton_oddepochs,'Value', 0)
        %set(handles.radiobutton_evenepochs,'Value', 0)
else
        set(hObject,'Value', 1)
end

%-------------------------------------------------------------------------
function radiobutton_fromanytime_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.radiobutton_frompart,'Value', 0)
        set(handles.edit_frompart,'Enable', 'off')
        %set(handles.edit_outof,'Enable', 'off')
else
        set(hObject,'Value', 1)
end

%-------------------------------------------------------------------------
function radiobutton_frompart_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.radiobutton_fromanytime,'Value', 0)
        set(handles.edit_frompart,'Enable', 'on')
        %set(handles.edit_outof,'Enable', 'on')
else
        set(hObject,'Value', 1)
end

%-------------------------------------------------------------------------
function edit_frompart_Callback(hObject, eventdata, handles)
pt  = str2num(get(hObject,'String'));
npt = length(pt);
if mod(length(pt),2)>0
        msgboxText =  ['The range of episode(s) has to have an even number of values.\n'...
                'For instance, 100 2500 5000 9000 when in ms\n'...
                'or equally, asuming you recording was 10000 ms long, you may indicate\n'...
                '0.01 0.25 0.5 0.9 as proportions.\n\n'...
                'ERPLAB will understand as a range in proportion (couple of) numbers lesser or equal to 1\n'...
                'Please use one nomenclature at a time.\n'];
        title = 'ERPLAB: epoch4avgGUI input error';
        errorfound(sprintf(msgboxText), title);
        return
end
tf = isnegative(pt, 'first');
if tf
        msgboxText =  ['The range of episode(s) must have positive values.\n'...
                'For instance, 100 2500 5000 9000 when in ms\n'...
                'or equally, asuming you recording was 10000 ms long, you may indicate\n'...
                '0.01 0.25 0.5 0.9 as proportions.\n\n'...
                'ERPLAB will understand as a range in proportion (couple of) numbers lesser or equal to 1\n'...
                'Please use one nomenclature at a time.\n'];
        title = 'ERPLAB: epoch4avgGUI input error';
        errorfound(sprintf(msgboxText), title);
        return
end


%-------------------------------------------------------------------------
function edit_frompart_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%-------------------------------------------------------------------------
function checkbox_warnme_Callback(hObject, eventdata, handles)

%-------------------------------------------------------------------------


%-------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%-------------------------------------------------------------------------
function pushbutton_OK_Callback(hObject, eventdata, handles)

%Number of epochs per bin to average
aival = get(handles.radiobutton_asitis,'Value'); % as it is
bival = get(handles.radiobutton_asfollowed,'Value'); % as followed

if aival && ~ bival %(safe way for radiobuttons...)
        nepochsperbin = 'amap';
else
        nepochsperbin  = str2num(get(handles.edit_numberofepochsperbin,'String'));
        tf = isnegative(nepochsperbin, 'first');
        if tf
                msgboxText =  ['The number of epochs per bin must have positive integer values.\n'...
                        'For instance, 230 460 230 690\n\n'...
                        'For a fix number of epochs per bin just specify one single value.'];
                title = 'ERPLAB: epoch4avgGUI input error';
                errorfound(sprintf(msgboxText), title);
                return
        end
end

%
% Artifact detection criterion
%
if get(handles.popupmenu_ardetection,'Value')==1; % ignore AD
        ardetcriterio = 0;
elseif get(handles.popupmenu_ardetection,'Value')==2; % ignore AD
        ardetcriterio = 1;
else
        ardetcriterio = 2;
end

%
% Catching criterion
%
if get(handles.popupmenu_catching,'Value')==1; % on the fly
        catching = 0;
elseif get(handles.popupmenu_catching,'Value')==2; % at random
        catching = 1;
elseif get(handles.popupmenu_catching,'Value')==3; % odd epochs
        catching = 2;
elseif get(handles.popupmenu_catching,'Value')==4; % even epochs
        catching = 3;
else
        catching = 4;
end

%
% Reference for indexing
%
cival = get(handles.radiobutton_refabsolute,'Value'); %
dival = get(handles.radiobutton_refrelative,'Value'); %
if cival && ~ dival
        reference = 0;
else
        reference = 1;
end

%
% Epochs' Episode
%
jival = get(handles.radiobutton_fromanytime,'Value'); % from any time
kival = get(handles.radiobutton_frompart,'Value'); % from specific part of the recording
if jival && ~ kival
        episode = 'any';
else
        episode = str2num(get(handles.edit_frompart,'String'));% total}
        if mod(length(episode),2)>0
                msgboxText =  ['The range of episode(s) has to have an even number of values.\n'...
                        'For instance, 100 2500 5000 9000 when in ms\n'...
                        'or equally, asuming you recording was 10000 ms long, you may indicate\n'...
                        '0.01 0.25 0.5 0.9 as proportions.\n\n'...
                        'ERPLAB will understand as a range in proportion (couple of) numbers lesser or equal to 1\n'...
                        'Please use one nomenclature at a time.\n'];
                title = 'ERPLAB: epoch4avgGUI input error';
                errorfound(sprintf(msgboxText), title);
                return
        end
        tf = isnegative(episode, 'first');
        if tf
                msgboxText =  ['The range of episode(s) must have positive values.\n'...
                        'For instance, 100 2500 5000 9000 when in ms\n'...
                        'or equally, asuming you recording was 10000 ms long, you may indicate\n'...
                        '0.01 0.25 0.5 0.9 as proportions.\n\n'...
                        'ERPLAB will understand as a range in proportion (couple of) numbers lesser or equal to 1\n'...
                        'Please use one nomenclature at a time.\n'];
                title = 'ERPLAB: epoch4avgGUI input error';
                errorfound(sprintf(msgboxText), title);
                return
        end
end

%
% Instance
%
if get(handles.popupmenu_instance,'Value')==1; % sequential
        instance = 0;
elseif get(handles.popupmenu_instance,'Value')==2; % at random
        instance = 1;
elseif get(handles.popupmenu_instance,'Value')==3; % odd epochs
        instance = 2;
end


%
% Save non-selected?
%
save_not_selected = 0;  % Deal with this in 'savemyindicies' instead, but create now

warnme = get(handles.checkbox_warnme, 'Value');
handles.output = {nepochsperbin, ardetcriterio, catching, reference, episode, instance, warnme, save_not_selected};

%
% memory for Gui
%
epoch4avgGUI.nepochsperbin = nepochsperbin;
epoch4avgGUI.ardetcriterio = ardetcriterio;
epoch4avgGUI.catching      = catching;
epoch4avgGUI.reference     = reference;
epoch4avgGUI.episode       = episode;
epoch4avgGUI.instance      = instance;
epoch4avgGUI.warnme        = warnme;
epoch4avgGUI.save_not_selected = save_not_selected;
erpworkingmemory('epoch4avgGUI', epoch4avgGUI);

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function popupmenu_catching_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_catching_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_ardetection_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_ardetection_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function radiobutton_refabsolute_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.radiobutton_refrelative,'Value', 0)
else
        set(hObject,'Value', 1)
end

%--------------------------------------------------------------------------
function radiobutton_refrelative_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.radiobutton_refabsolute,'Value', 0)
else
        set(hObject,'Value', 1)
end



%--------------------------------------------------------------------------
function popupmenu_instance_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_instance_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

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


