function varargout = grandaverager_DQ(varargin)
% GRANDAVERAGER_DQ MATLAB code for grandaverager_DQ.fig
%      GRANDAVERAGER_DQ, by itself, creates a new GRANDAVERAGER_DQ or raises the existing
%      singleton*.
%
%      H = GRANDAVERAGER_DQ returns the handle to a new GRANDAVERAGER_DQ or the handle to
%      the existing singleton*.
%
%      GRANDAVERAGER_DQ('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GRANDAVERAGER_DQ.M with the given input arguments.
%
%      GRANDAVERAGER_DQ('Property','Value',...) creates a new GRANDAVERAGER_DQ or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before grandaverager_DQ_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to grandaverager_DQ_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help grandaverager_DQ

% Last Modified by GUIDE v2.5 01-Aug-2019 05:05:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @grandaverager_DQ_OpeningFcn, ...
                   'gui_OutputFcn',  @grandaverager_DQ_OutputFcn, ...
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


% --- Executes just before grandaverager_DQ is made visible.
function grandaverager_DQ_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to grandaverager_DQ (see VARARGIN)

% Choose default command line output for grandaverager_DQ
handles.output = [];

%set(handles.gui_chassis,'Name', 'Grand Averager - Custom DQ Measure Combo')

%helpbutton;

% Sort DQ in
% Parse input
handles.ERPs_in = varargin{1};


% DQ out
handles.n_custom = 0;
handles.custom_DQ_list = [];
str0 = '';
set(handles.listbox_custom,'String',str0)

handles.combo.measures = [];
handles.combo.methods = [];


% Set up ALLERP -> DQ measure option list
ERPs = handles.ERPs_in;
if isfield(ERPs,'dataquality') == 0
    ERPs = []; % clear if not valid dataquality ERP sets
end

% Make DQ measure list from those in ALLERP / ERPs provided
if isempty(ERPs)
    
    % leave basic list as is
    
else
    
    % make a list of possible DQ measures present
    big_measure_list = {};
    nbm = 0;
    n_sets = numel(ERPs);
    for ds = 1:n_sets
        n_dq_here = numel(ERPs(ds).dataquality);
        for dqm = 1:n_dq_here
            nbm = nbm +1;
            big_measure_list{nbm} = ERPs(ds).dataquality(dqm).type;
        end
    end
    
    measure_list = unique(big_measure_list);
    
    handles.listbox_existing_DQ.String = measure_list;
end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes grandaverager_DQ wait for user response (see UIRESUME)
uiwait(handles.GAvDQ);


% --- Outputs from this function are returned to the command line.
function varargout = grandaverager_DQ_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
pause(0.1)
% Update handles structure
guidata(hObject, handles);

% make output struct
combo_out.measures = handles.combo.measures;
combo_out.methods = handles.combo.methods;
combo_out.measure_names = cellstr(get(handles.listbox_existing_DQ,'String'));
combo_out.method_names = cellstr(get(handles.listbox_combine_method,'String'));
combo_out.str = handles.output;

% Get default command line output from handles structure
varargout{1} = combo_out;
% The figure can be deleted now
pause(0.1)
delete(handles.GAvDQ);
pause(0.1)



% --- Executes on selection change in listbox_existing_DQ.
function listbox_existing_DQ_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_existing_DQ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_existing_DQ contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_existing_DQ


% --- Executes during object creation, after setting all properties.
function listbox_existing_DQ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_existing_DQ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in listbox_combine_method.
function listbox_combine_method_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_combine_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_combine_method contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_combine_method


% --- Executes during object creation, after setting all properties.
function listbox_combine_method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_combine_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in togglebutton_add.
function togglebutton_add_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton_add

add_this = get(hObject,'Value');

if add_this
    
    
    old_list = cellstr(get(handles.listbox_custom,'String'));
    old_n = numel(old_list);
    
    measure_n = get(handles.listbox_existing_DQ,'Value');
    measure_cell = cellstr(get(handles.listbox_existing_DQ,'String'));
    measure_str = measure_cell{measure_n};
    
    comb_n = get(handles.listbox_combine_method,'Value');
    comb_cell = cellstr(get(handles.listbox_combine_method,'String'));
    comb_str = comb_cell{comb_n};
    
    str_here = [measure_str ' ' comb_str];
    
    
    if isempty(old_list) || isempty(old_list{1})
        old_list{old_n} = str_here;
        handles.n_custom = handles.n_custom + 1;
        n = handles.n_custom;
    else
        
        old_list{old_n+1} = str_here;
        handles.n_custom = handles.n_custom + 1;
        n = handles.n_custom;
    end
    
    new_list = old_list;
    set(handles.listbox_custom,'String',new_list);
    
    % Keep track of what measures and methods were chosen
    handles.combo.measures(n) = measure_n;
    handles.combo.methods(n) = comb_n;
    
    % Pause for a beat, reset this button to 0
    pause(0.1);
    set(handles.togglebutton_add,'Value',0)
else
    % already down   
    pause(0.1);
    set(handles.togglebutton_add,'Value',0)
end


% Update handles structure
guidata(hObject, handles);




% --- Executes on selection change in listbox_custom.
function listbox_custom_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_custom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_custom contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_custom


% --- Executes during object creation, after setting all properties.
function listbox_custom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_custom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in togglebutton_remove.
function togglebutton_remove_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton_remove

remove1 = get(hObject,'Value');

if remove1
    handles.combo.measures = [];
    handles.combo.methods = [];
    handles.n_custom = 0;
    set(handles.listbox_custom,'String','');
    set(handles.listbox_custom,'Value',1);
    pause(0.1);
else
     %already down   
    pause(0.1);
    set(handles.togglebutton_remove,'Value',0)
    return
end

guidata(hObject, handles);




% if remove1
%     
%     measure_n = get(handles.listbox_custom,'Value');
%     measure_cell = cellstr(get(handles.listbox_custom,'String'));
%     
%     measure_cell(measure_n) = [];
%     
%     if isempty(measure_cell)
%         measure_cell{1} = '';
%     end
%     
%     set(handles.listbox_custom,'String',measure_cell);
%     
%     disp_txt = ['Custom entry ' num2str(measure_n) ' removed'];
%     pause(0.1);
%     set(handles.togglebutton_remove,'Value',0)
%     
%     handles.n_custom = handles.n_custom - 1;
%     if handles.n_custom < 0
%         handles.n_custom = 0;
%     end
%     handles.combo.measures(measure_n) = [];
%     handles.combo.methods(measure_n) = [];
%     
% else
%      % already down   
%     pause(0.1);
%     set(handles.togglebutton_remove,'Value',0)
%     return
% end

%set(hObject,'Value',1); % set to the first?
    % Update handles structure
%guidata(hObject, handles);
    


% --- Executes on button press in pushbutton_apply.
function pushbutton_apply_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = get(handles.listbox_custom,'String');
%handles.output = 2;
%disp(handles.output);

measure_names_all = cellstr(get(handles.listbox_existing_DQ,'String'));
measure_names_here = measure_names_all(handles.combo.measures);

% Check requested measure in target ERP sets
n_sets = numel(handles.ERPs_in);

if n_sets > 0
DQ_measure_match = check_DQ_measures(handles.ERPs_in,measure_names_here);
else
    DQ_measure_match = 1;
end

if DQ_measure_match
    % Update handles structure
guidata(hObject, handles);
uiresume(handles.GAvDQ); % exit

else
    % DQ mismatch
    beep
    errordlg('Not all requested measures are present in all ERPsets to be averaged. Please check requested measures and ERPsets.')
    pause(0.1)
end



% --- Executes on button press in pushbutton_help.
function pushbutton_help_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% doc pop_gaverager
web('https://github.com/lucklab/erplab/wiki/Averaging-Across-ERPSETS-(Creating-Grand-Averages)#grand-average-data-quality', '-browser');


% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if isequal(get(handles.GAvDQ, 'waitstatus'), 'waiting')
    %The GUI is still in UIWAIT, us UIRESUME
    handles.output = '';
    %Update handles structure
    guidata(hObject, handles);
    uiresume(handles.GAvDQ);
else
    % The GUI is no longer waiting, just close it
    delete(handles.GAvDQ);
end


% --- Executes when user attempts to close GAvDQ.
function GAvDQ_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to GAvDQ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(handles.GAvDQ, 'waitstatus'), 'waiting')
    %The GUI is still in UIWAIT, us UIRESUME
    handles.output = '';
    %Update handles structure
    guidata(hObject, handles);
    uiresume(handles.GAvDQ);
else
    % The GUI is no longer waiting, just close it
    delete(handles.GAvDQ);
end
