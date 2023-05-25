function varargout = DQ_preavg(varargin)
% DQ_PREAVG MATLAB code for DQ_preavg.fig
%      DQ_PREAVG, by itself, creates a new DQ_PREAVG or raises the existing
%      singleton*.
%
%      H = DQ_PREAVG returns the handle to a new DQ_PREAVG or the handle to
%      the existing singleton*.
%
%      DQ_PREAVG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DQ_PREAVG.M with the given input arguments.
%
%      DQ_PREAVG('Property','Value',...) creates a new DQ_PREAVG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DQ_preavg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DQ_preavg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DQ_preavg

% Last Modified by GUIDE v2.5 21-Apr-2022 15:48:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DQ_preavg_OpeningFcn, ...
                   'gui_OutputFcn',  @DQ_preavg_OutputFcn, ...
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


% --- Executes just before DQ_preavg is made visible.
function DQ_preavg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DQ_preavg (see VARARGIN)

% Choose default command line output for DQ_preavg
handles.output   = [];
handles.listname = [];
handles.indxline = 1;


try
    currdata = varargin{1};
catch
    currdata = 1;
end
try
    def = varargin{2};
    setindex = def{1};   % datasets to average
    
    %
    % Artifact rejection criteria for averaging
    %
    %  artcrite = 0 --> averaging all (good and bad trials)
    %  artcrite = 1 --> averaging only good trials
    %  artcrite = 2 --> averaging only bad trials
    artcrite = def{2};
    
    % Weighted average option. 1= yes, 0=no
    %wavg     = def{3};
    
    stderror   = def{4};% compute standard error
    excbound   = def{5};% exclude epochs having "boundary" events (or -99)
    compu2do   = def{6}; % 0:ERP; 1:ERP+TPS; 2:ERP+EPS; 3:ERP+BOTH
    wintype    = def{7}; % taper data with window: empty=no taper
    wintfunc   = def{8}; % taper function and (sub)window
catch
    setindex = 1;
    artcrite = 1;
    %wavg     = 1;
    stderror = 1;
    excbound = 1;
    compu2do = 0; % 0:ERP; 1:ERP+TPS; 2:ERP+EPS; 3:ERP+BOTH
    wintype  = 0; % taper data with window: 0=no taper
    wintfunc = [];
end
try
    nepochperdata = varargin{3};
catch
    nepochperdata = [];
end
try
    timelimits = varargin{4}; % in ms
catch
    timelimits = [0 0];
end


%
% Number of current epochs per dataset
%
handles.nepochperdata = nepochperdata;
handles.currdata      = currdata;
handles.timelimits    = timelimits; % in ms

if ~iscell(artcrite)
    if isnumeric(artcrite)
        if artcrite==0
            va=1;vb=0;vc=0;vd=0;
        elseif artcrite==1
            va=0;vb=1;vc=0;vd=0;
        elseif artcrite==2
            va=0;vb=0;vc=1;vd=0;
        else
            msgboxText =  'invalid option.';
            title = 'ERPLAB: DQ_preaverager GUI';
            errorfound(msgboxText, title);
            return
        end
%         set(handles.edit_include_indices,'Enable', 'off')
%         set(handles.pushbutton_loadlist,'Enable', 'off')
%         %set(handles.pushbutton_fileorvalues,'Enable', 'off')
%         set(handles.pushbutton_saveList,'Enable', 'off')
%         set(handles.pushbutton_viewfile,'Enable', 'off')
%         set(handles.radiobutton_usefilename, 'Enable', 'off')
%         set(handles.radiobutton_useindices, 'Enable', 'off')
%         set(handles.pushbutton_clearall, 'Enable', 'off')
%     else % char
%         va=0;vb=0;vc=0;vd=1;
%         set(handles.edit_include_indices,'Enable', 'on')
%         set(handles.pushbutton_loadlist,'Enable', 'on')
%         %set(handles.edit_include_indices,'String', artcrite)
%         %set(handles.pushbutton_fileorvalues,'Enable', 'on')
%         set(handles.pushbutton_saveList,'Enable', 'on')
%         set(handles.pushbutton_viewfile,'Enable', 'on')
%         set(handles.radiobutton_usefilename, 'Enable', 'on')
%         set(handles.radiobutton_useindices, 'Enable', 'on')
%         set(handles.pushbutton_clearall, 'Enable', 'on')
    end
% else
%     va=0;vb=0;vc=0;vd=1;
%     set(handles.edit_include_indices,'Enable', 'on')
%     set(handles.pushbutton_loadlist,'Enable', 'on')
end
%set dataset index 
set(handles.edit_dataset, 'String', vect2colon(setindex,'Delimiter','off')); 

%set epochs to include 
if vb == 1
    set(handles.checkbox_excludeartifacts, 'Value', vb); % exclude artifacts
elseif va == 1
    set(handles.checkbox_includeALL, 'Value', va);       % include artifacts
    
elseif vc == 1
    set(handles.checkbox_onlyartif, 'Value', vc);       %only artifacts
end

% set(handles.checkbox_onlyartifacts, 'Value', vc);    % exclude artifacts
% set(handles.checkbox_include_indices,'Value', vd)
% if vd==1
%     set(handles.pushbutton_epochAssistant, 'Value', 1)
%     if iscell(artcrite)
%         set(handles.edit_include_indices,'String', vect2colon([artcrite{:}],'Delimiter','off'))
%         set(handles.radiobutton_usefilename, 'Value', 0)
%         set(handles.radiobutton_useindices, 'Value', 1)
%     else
%         set(handles.edit_include_indices,'String', artcrite)
%         set(handles.radiobutton_usefilename, 'Value', 1)
%         set(handles.radiobutton_useindices, 'Value', 0)
%     end
% else
%     set(handles.pushbutton_epochAssistant,'Enable', 'off')
% end
%set(handles.checkbox_SEM, 'Value', stderror); % compute standard error
%set(handles.checkbox_exclude_boundary, 'Value', excbound); % exclude epochs having "boundary" events (or -99)


% 0:ERP; 1:ERP+TPS; 2:ERP+EPS; 3:ERP+BOTH
switch compu2do
    case 1
        set(handles.checkbox_Total_Power, 'Value', 1);
        set(handles.checkbox_Evoked_Power, 'Value', 0);
    case 2
        set(handles.checkbox_Total_Power, 'Value', 0);
        set(handles.checkbox_Evoked_Power, 'Value', 1);
    case 3
        set(handles.checkbox_Total_Power, 'Value', 1);
        set(handles.checkbox_Evoked_Power, 'Value', 1);
    otherwise
%         set(handles.checkbox_Total_Power, 'Value', 0);
%         set(handles.checkbox_Evoked_Power, 'Value', 0);
end

% compu2do = def{6}; % 0:ERP; 1:ERP+TPS; 2:ERP+EPS; 3:ERP+BOTH
% if wintype && ismember(compu2do, [1 2 3]) 
%     if iscell(wintfunc)
%         if isempty(wintfunc)
%             set(handles.checkbox_taper, 'Value', 0);
%             set(handles.edit_taperfunction,'Enable', 'off')
%         else
%             apostr      = wintfunc{1};
%             if ischar(apostr)
%                 set(handles.edit_taperfunction,'Enable', 'on')
%                 if length(wintfunc)>=2
%                     apowinms    = wintfunc{2}; % epoch's time range (in ms) for applying the taper (2 values)
%                     set(handles.edit_taperfunction, 'String', sprintf('''%s''  [%g %g]', apostr, apowinms));
%                 else
%                     set(handles.edit_taperfunction, 'String', sprintf('''%s''', apostr));
%                 end
%                 set(handles.checkbox_taper, 'Value', 1);
%             else
%                 set(handles.checkbox_taper, 'Value', 0);
%                 set(handles.edit_taperfunction, 'String', '!');
%                 set(handles.edit_taperfunction,'Enable', 'off')
%             end
%         end
%     else  % deprecated...
%         if isnumeric(wintfunc)
%             if wintfunc>0
%                 set(handles.checkbox_taper, 'Value', 1);
%                 set(handles.edit_taperfunction,'Enable', 'on')
%                 set(handles.edit_taperfunction, 'String', 'Hanning');
%             else
%                 set(handles.checkbox_taper, 'Value', 0);
%                 set(handles.edit_taperfunction,'Enable', 'off')
%                 set(handles.edit_taperfunction, 'String', '');
%             end
%         elseif ischar(wintfunc)
%             set(handles.checkbox_taper, 'Value', 1);
%             set(handles.edit_taperfunction,'Enable', 'on')
%             set(handles.edit_taperfunction, 'String', wintfunc);
%         else
%             set(handles.checkbox_taper, 'Value', 0);
%             set(handles.edit_taperfunction, 'String', '!!');
%             set(handles.edit_taperfunction,'Enable', 'off')
%         end
%     end
% else
%     set(handles.checkbox_taper, 'Value', 0);
%     set(handles.checkbox_taper,'Enable', 'off') 
%     set(handles.edit_taperfunction, 'String', '');
%     set(handles.edit_taperfunction,'Enable', 'off')    
% end

tooltip1  = ['<html><i>Each epoch (selected for getting the ERP waveform) is transformed<br>via fast-Fourier transform (FFT) to power spectrum, and then the <br>'...
    'average across all spectra is derived.'];
tooltip2  = '<html><i>The ERP waveform is transformed via fast-Fourier transform (FFT) <br>to power spectrum.';

tooltip3  = ['<html><i>Windowing functions act on raw data to reduce the effects of the<br>leakage that occurs during an FFT of the data. Leakage amounts to<br>'...
    'spectral information from an FFT showing up at the wrong frequencies.'];
tooltip_DQ  = ['<html><i>Data Quality measures will be scored for the metric<br>'...
    'Recommended default time and measure parameters can be used, or custom times and measures specified<br>'...
    'results stored in dataquality(1:n)'];

% set(handles.edit_tip_totalpower, 'tooltip',tooltip1);
% set(handles.edit_tip_evokedpower, 'tooltip',tooltip2);
% set(handles.edit_tip_hamming, 'tooltip',tooltip3);
set(handles.edit_tip_DQ, 'tooltip',tooltip_DQ);

oldDQ = def{10}; 
if isempty(oldDQ)
    dq_times_def = [1:6;-100:100:400;0:100:500]';
    handles.dq_times = dq_times_def;
    handles.DQ_spec = [];
else
    try
        dq_times_def = oldDQ(3).times;
        handles.dq_times = dq_times_def;
        handles.DQ_spec = oldDQ;
    catch
       dq_times_def = [1:6;-100:100:400;0:100:500]';
        handles.dq_times = dq_times_def;
        handles.DQ_spec = oldDQ;
    end
end

% Is averager or DQ Table on a pre-AVG?
handles.DQpreavg_txt = def{11}; 

% Did user specifcy custom DQ timewindows?
customWins = def{12}; 

if customWins
    set(handles.radiobuttonDQ2, 'Value', 1); 
    set(handles.pushbutton_DQ_adv,'Enable','on');
else
    set(handles.radiobuttonDQ1, 'Value', 1); 
end

handles.DQ_custom_wins = customWins; 



%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   EEGset -> DQ Table'])
set(handles.edit_dataset, 'String', num2str(currdata));

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

% % help
% helpbutton

% UIWAIT makes averagerxGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

% UIWAIT makes DQ_preavg wait for user response (see UIRESUME)
% uiwait(handles.gui_chassis);


% --- Outputs from this function are returned to the command line.
function varargout = DQ_preavg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)


% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4



%-------------------------------------------------------------------------
function checkbox_includeALL_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    set(handles.checkbox_excludeartifacts,'Value',0)
    set(handles.checkbox_onlyartif,'Value',0)
%     set(handles.checkbox_include_indices,'Value',0)
%     set(handles.edit_include_indices,'Enable', 'off')
%     set(handles.pushbutton_epochAssistant,'Enable', 'off')
%     set(handles.pushbutton_loadlist,'Enable', 'off')
%     %set(handles.pushbutton_fileorvalues,'Enable', 'off')
%     set(handles.pushbutton_saveList,'Enable', 'off')
%     set(handles.pushbutton_viewfile,'Enable', 'off')
%     set(handles.radiobutton_usefilename, 'Enable', 'off')
%     set(handles.radiobutton_useindices, 'Enable', 'off')
%     set(handles.pushbutton_clearall, 'Enable', 'off')
else
    set(handles.checkbox_includeALL,'Value',1)
end

% -------------------------------------------------------------------------
function checkbox_excludeartifacts_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
    set(handles.checkbox_includeALL,'Value',0)
    set(handles.checkbox_onlyartif,'Value',0)
%     set(handles.checkbox_include_indices,'Value',0)
%     set(handles.edit_include_indices,'Enable', 'off')
%     set(handles.pushbutton_epochAssistant,'Enable', 'off')
%     set(handles.pushbutton_loadlist,'Enable', 'off')
%     %set(handles.pushbutton_fileorvalues,'Enable', 'off')
%     set(handles.pushbutton_saveList,'Enable', 'off')
%     set(handles.pushbutton_viewfile,'Enable', 'off')
%     set(handles.radiobutton_usefilename, 'Enable', 'off')
%     set(handles.radiobutton_useindices, 'Enable', 'off')
%     set(handles.pushbutton_clearall, 'Enable', 'off')
else
    set(handles.checkbox_excludeartifacts,'Value',1)
end

% --- Executes on button press in radiobutton7.
function radiobutton7_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton7



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in radiobutton8.
function radiobutton8_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton8


% --- Executes on button press in radiobutton9.
function radiobutton9_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton9


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in pushbutton_DQ_adv.
function pushbutton_DQ_adv_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_DQ_adv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
old_DQ_spec = handles.DQ_spec;

custom_DQ_spec = avg_data_quality(old_DQ_spec,handles.timelimits);

if isempty(custom_DQ_spec)
    disp('User cancelled custom DQ window')
    %handles.DQ_spec = [];
else
    % The DQ Custom window ran successfully, so write the new DQ spec
    handles.DQ_spec = custom_DQ_spec;
end

% Update handles structure
guidata(hObject, handles);





function edit_dataset_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dataset as text
%        str2double(get(hObject,'String')) returns contents of edit_dataset as a double


% --- Executes during object creation, after setting all properties.
function edit_dataset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobuttonDQ1.
function radiobuttonDQ1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonDQ1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonDQ1
handles.DQ_custom_wins = 0;
guidata(hObject, handles);



% --- Executes on button press in radiobuttonDQ2.
function radiobuttonDQ2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonDQ2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonDQ2
% hObject    handle to radiobuttonDQ2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonDQ2
set(handles.pushbutton_DQ_adv,'Enable','on');
handles.DQ_custom_wins = 1;
guidata(hObject, handles);



% --- Executes on button press in pushbutton_RUN.
function pushbutton_RUN_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_RUN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


dataset  = str2num(char(get(handles.edit_dataset, 'String')));
incALL   = get(handles.checkbox_includeALL, 'Value');
excart   = get(handles.checkbox_excludeartifacts, 'Value');
onlyart  = get(handles.checkbox_onlyartif, 'Value'); 
incart   = 0;
incIndx  = 0;
excbound = 1; % exclude epochs having boundary events

Tspectrum  = 0;   % total power spectrum
Espectrum  = 0;  % evoked power spectrum
iswindowed = 0;       % apply a window?

winparam = ''; 
compu2do = 0; %do ERP only 

if incALL 
    artcrite = 0;
    disp('Metrics reflect all (good and bad) epochs..')
elseif excart
    artcrite = 1; 
    disp('Metrics reflect only good epochs')
    
else
    artcrite = 2; 
    disp('Metrics reflect only bad (artifact marked) epochs')
end

% DQ defaults
DQ_defaults = make_DQ_spec(handles.timelimits);
DQ_defaults(1).comments{1} = 'Defaults';


% DQ output
DQ_flag   = max(get(handles.radiobuttonDQ1, 'Value'),get(handles.radiobuttonDQ2, 'Value'));

use_defaults = get(handles.radiobuttonDQ1, 'Value');

if DQ_flag
    stderror = 1;
    
    if use_defaults || isempty(handles.DQ_spec)
        DQ_spec = DQ_defaults;
    else
        DQ_spec = handles.DQ_spec;
    end
    
    
else
    stderror = 0;
    DQ_spec = [];
end

DQ_preavg_txt = handles.DQpreavg_txt ;

custWin = handles.DQ_custom_wins; 
if custWin
    DQ_customWins = 1;
else
    DQ_customWins = 0;
end

if isempty(dataset)
    msgboxText =  'You should enter at least one dataset!';
    title = 'ERPLAB: averager GUI empty input';
    errorfound(msgboxText, title);
    return
else
    wavg = 1; %get(handles.checkbox_wavg,'Value'); % always weighted now...
    handles.output = {dataset, artcrite, wavg, stderror, excbound, compu2do, iswindowed, winparam,DQ_flag,DQ_spec,DQ_preavg_txt,DQ_customWins};
    
    % Update handles structure
    guidata(hObject, handles);
    uiresume(handles.gui_chassis);
end







% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);


% --- Executes on button press in checkbox_onlyartif.
function checkbox_onlyartif_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_onlyartif (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_onlyartif
if get(hObject,'Value')
    set(handles.checkbox_includeALL,'Value',0)
    set(handles.checkbox_excludeartifacts,'Value',0)
%     set(handles.checkbox_include_indices,'Value',0)
%     set(handles.edit_include_indices,'Enable', 'off')
%     set(handles.pushbutton_epochAssistant,'Enable', 'off')
%     set(handles.pushbutton_loadlist,'Enable', 'off')
%     %set(handles.pushbutton_fileorvalues,'Enable', 'off')
%     set(handles.pushbutton_saveList,'Enable', 'off')
%     set(handles.pushbutton_viewfile,'Enable', 'off')
%     set(handles.radiobutton_usefilename, 'Enable', 'off')
%     set(handles.radiobutton_useindices, 'Enable', 'off')
%     set(handles.pushbutton_clearall, 'Enable', 'off')
else
    set(handles.checkbox_onlyartif,'Value',1)
end
