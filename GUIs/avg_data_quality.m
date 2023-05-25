function varargout = avg_data_quality(varargin)
% AVG_DATA_QUALITY MATLAB code for avg_data_quality.fig
%      AVG_DATA_QUALITY, by itself, creates a new AVG_DATA_QUALITY or raises the existing
%      singleton*.
%
%      H = AVG_DATA_QUALITY returns the handle to a new AVG_DATA_QUALITY or the handle to
%      the existing singleton*.
%
%      AVG_DATA_QUALITY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AVG_DATA_QUALITY.M with the given input arguments.
%
%      AVG_DATA_QUALITY('Property','Value',...) creates a new AVG_DATA_QUALITY or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before avg_data_quality_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to avg_data_quality_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help avg_data_quality

% Last Modified by GUIDE v2.5 17-Jan-2023 13:20:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @avg_data_quality_OpeningFcn, ...
    'gui_OutputFcn',  @avg_data_quality_OutputFcn, ...
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

% --- Executes just before avg_data_quality is made visible.
function avg_data_quality_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to avg_data_quality (see VARARGIN)

handles.output = hObject;

disp('Awaiting Data Quality settings...');

% Parse input
handles.DQ_spec = varargin{1};
handles.timelimits = varargin{2};

if isempty(varargin{1})

    preAvg_info = make_DQ_spec(handles.timelimits);
    sme_tw_labels = preAvg_info(3).time_window_labels;
    sme_tw = num2cell(preAvg_info(3).times);
    preAvg_labels = strrep(sme_tw_labels,'aSME','(Metric)');
    sme_tw3= [preAvg_labels' sme_tw];

else 
    preAvg_info = varargin{1};
    
    nDQ = length(preAvg_info);
    times_ind = zeros(1, nDQ); 
    
    %search "times" struct
    %time_present = 0; 
    for ti = 1:nDQ
        
        if ~isempty(preAvg_info(ti).times)
            times_ind(ti) = 1; 
        end
        
    end
       
    if ~any(times_ind) %no valid times
        sme_tw3 = []; 
%         preAvg_labels_old = preAvg_info(3).time_window_labels';
%         preAvg_info_times = num2cell(preAvg_info(3).times);
    else
         try %in case there is only one time-window metric
             preAvg_info_times = num2cell(preAvg_info.times);
             %             preAvg_info_times = num2cell(preAvg_info.times);
             %
   
%              sme_tw2 = cellstr(strcat({'(Metric) at '}, ... 
%                 string(preAvg_info_times(:,1)),{' to '},string(preAvg_info_times(:,2))));
            sme_tw2 = preAvg_info.time_window_labels;
            
     
            sme_tw2 = strrep(sme_tw2,'aSME','');
            sme_tw2 = strrep(sme_tw2,'(Corrected)','');
            sme_tw2 = strrep(sme_tw2,'aSD',''); 
            sme_tw2 = strcat('(Metric)',sme_tw2);
            
            try
                sme_tw3 = [sme_tw2 preAvg_info_times]; 
            catch
                sme_tw3 = [sme_tw2' preAvg_info_times]; 
            end
            
              
         catch
             %find usable inddex
             use_row = find(times_ind ==1);
             preAvg_info_times = num2cell(preAvg_info(use_row(1)).times);
             
             %retain time_window_labels if previously set

%             sme_tw2 = cellstr(strcat({'(Metric) at '}, ... 
%                 string(preAvg_info_times(:,1)),{' to '},string(preAvg_info_times(:,2))));

            sme_tw2 = preAvg_info(use_row(1)).time_window_labels;
            sme_tw2 = strrep(sme_tw2,'aSME','');
            sme_tw2 = strrep(sme_tw2,'(Corrected)','');
            sme_tw2 = strrep(sme_tw2,'aSD',''); 
          %  sme_tw2 = strrep(sme_tw2,'aSD (Corrected)','('); 
          
            
            sme_tw2 = strcat('(Metric)',sme_tw2); 
            
            try
                sme_tw3 = [sme_tw2 preAvg_info_times]; 
            catch
                sme_tw3 = [sme_tw2' preAvg_info_times]; 
            end
         end
        
    end

%     try 
%        
%     catch ME
%         switch ME.identifier 
%             case 'MATLAB:nonExistentField'
%                 preAvg_labels_old = 'EMPTY';
%                 preAvg_info_times = 'NAN'; 
%             otherwise 
%                 preAvg_labels_old = preAvg_info.time_window_labels';
%                 preAvg_info_times = num2cell(preAvg_info.times);
%         end
%         
%     end
%     preAvg_labels = strrep(preAvg_labels_old,'aSME','(Metric)'); 
% 
%    
%     try 
%         sme_tw2= [preAvg_labels' preAvg_info_times]; 
%     catch
%         sme_tw2= [preAvg_labels preAvg_info_times]; 
%     end
    
end

% Choose default command line output for avg_data_quality

handles.DQout = zeros(2,4);
handles.tupdate = 0;
handles.num_tests = 1;

handles.paraSME = 1;
handles.tdata = handles.SME_table.Data;
handles.SME_table.Data = sme_tw3;

handles.Tout = sme_tw3;
disp(handles.Tout);

handles.sel_row = size(handles.Tout,1); % set to max on load

%read from default/working memory values 
type_struct = {preAvg_info.type};

for curtype = type_struct
    switch char(curtype)
        
        case 'Baseline Measure - SD'
            set(handles.checkbox_baseline_noise,'Value',1);
            set(handles.radiobutton_basel_sd,'Value',1);
            
        case 'Baseline Measure - SD (Corrected)'
            set(handles.checkbox_baseline_noise,'Value',1);
            set(handles.radiobutton_basel_sdcorr,'Value',1);
             
        case 'Baseline Measure - RMS'
            set(handles.checkbox_baseline_noise,'Value',1);
            set(handles.radiobutton_basel_rms,'Value',1);
            
        case 'Point-wise SEM'
            set(handles.checkbox_SEM,'Value',1);
            set(handles.radiobutton12, 'Value',1); 
            
        case 'Point-wise SEM (Corrected)'
            set(handles.checkbox_SEM,'Value',1);
            set(handles.radiobutton_sem_corr,'Value',1);
            
        case 'aSME'
            set(handles.checkbox1_paraSME,'Value',1);
            set(handles.radiobutton_SD,'Value',1);
            
        case 'aSME (Corrected)'
            set(handles.checkbox1_paraSME,'Value',1);
            set(handles.radiobutton_SD_corr,'Value',1);
            
        case 'aSD'
            set(handles.checkbox6_paraSD,'Value',1);
            set(handles.radiobutton_SD,'Value',1);
            
        case 'aSD (Corrected)'
            set(handles.checkbox6_paraSD,'Value',1);
            set(handles.radiobutton_SD_corr,'Value',1);
    end
           
end


% Update handles structure
guidata(hObject, handles);

%helpbutton
initialize_gui(hObject, handles, false);

% UIWAIT makes avg_data_quality wait for user response (see UIRESUME)
uiwait(handles.avg_dq);


% --- Outputs from this function are returned to the command line.
function varargout = avg_data_quality_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
pause(0.1)
% Update handles structure
guidata(hObject, handles);

% Get default command line output from handles structure
varargout{1} = handles.output;
% The figure can be deleted now
pause(0.1)
delete(handles.avg_dq);
pause(0.1)

% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if isequal(get(handles.avg_dq, 'waitstatus'), 'waiting')
    %The GUI is still in UIWAIT, us UIRESUME
    handles.output = '';
    %Update handles structure
    guidata(hObject, handles);
    uiresume(handles.avg_dq);
else
    % The GUI is no longer waiting, just close it
    delete(handles.avg_dq);
end

% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% First, check time windows are valid
try 
    times_here = cell2mat(handles.Tout(:,2:3));
    if any(times_here(:) < min(handles.timelimits)) || any(times_here(:) > max(handles.timelimits))
        beep
        time_off_str = ['It appears that some of the listed times are out of bounds of the epoch time of this EEG set'];
        disp(time_off_str)
        time_off2 = ['Time limits here are: ' num2str(handles.timelimits)];
        disp(time_off2)
        pause(0.1)
        return
    end
catch
    times_here = []; 
    
end

disp('Saving Data Quality settings...');

if handles.paraSME == 1
    num_tests = 1;
    type = 'SME';
end

baseline_on = get(handles.checkbox_baseline_noise,'Value');
sem_on = get(handles.checkbox_SEM,'Value');
asme_on = get(handles.checkbox1_paraSME,'Value');
aSD_on = get(handles.checkbox6_paraSD,'Value'); 


%num_tests = baseline_on + sem_on + asme_on;



% Make DQout
DQout = [];
dq_slot = 0;
if baseline_on
    dq_slot = dq_slot + 1;
    
    basel_sd = get(handles.radiobutton_basel_sd,'Value');
    basel_rms = get(handles.radiobutton_basel_rms,'Value');
    %basel_sdcorr = get(handles.radiobutton_basel_sdcorr,(
    if basel_sd
        DQout(dq_slot).type = 'Baseline Measure - SD';
    elseif basel_rms
        DQout(dq_slot).type = 'Baseline Measure - RMS';
    else
        DQout(dq_slot).type = 'Baseline Measure - SD (Corrected)'; 
    end
    
    default_t = get(handles.checkbox_basel_default_times,'Value');
    if default_t
        DQout(dq_slot).times = [];
    else
        custom_t = [1 str2double(get(handles.baseline_start,'String')) str2double(get(handles.baseline_end,'String'))];
        DQout(dq_slot).times = custom_t;
    end
end

if sem_on
    dq_slot = dq_slot + 1;
    sem_corr = get(handles.radiobutton_sem_corr,'Value'); 
    
    if sem_corr
        DQout(dq_slot).type = 'Point-wise SEM (Corrected)'; 
    else
        DQout(dq_slot).type = 'Point-wise SEM';
    end
end




if asme_on
    dq_slot = dq_slot + 1;
    
    dq_sd = get(handles.radiobutton_SD,'Value');
    if dq_sd
        DQout(dq_slot).type = 'aSME';
        DQout(dq_slot).times = times_here; 
        DQout(dq_slot).time_window_labels = strrep(handles.Tout(:,1),'(Metric)','aSME');
    else
        DQout(dq_slot).type = 'aSME (Corrected)';
        DQout(dq_slot).times = times_here; 
        DQout(dq_slot).time_window_labels = strrep(handles.Tout(:,1),'(Metric)','aSME (Corrected)');
    end
     
   % DQout(dq_slot).time_window_labels = strrep(handles.Tout(:,1),'(Metric)','aSME');

end

if aSD_on 
    dq_slot = dq_slot + 1;
    
    dq_sd = get(handles.radiobutton_SD,'Value');
    if dq_sd
        DQout(dq_slot).type = 'aSD';
        DQout(dq_slot).times = times_here;
        DQout(dq_slot).time_window_labels = strrep(handles.Tout(:,1),'(Metric)','aSD');
    else
        DQout(dq_slot).type = 'aSD (Corrected)';
        DQout(dq_slot).times = times_here;
        DQout(dq_slot).time_window_labels = strrep(handles.Tout(:,1),'(Metric)','aSD (Corrected)');
    end
        
    

   % DQout(dq_slot).time_window_labels = strrep(handles.Tout(:,1),'(Metric)','aSD');

        

    
end


%DQout.num_tests = num_tests;

handles.output = DQout;

% Update handles structure
guidata(hObject, handles);
uiresume(handles.avg_dq);
%avg_dq_CloseRequestFcn(hObject, eventdata, handles);



% --- Executes when selected object changed in unitgroup.
function unitgroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in unitgroup
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset)
% If the metricdata field is present and the save flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to save the data.
if isfield(handles, 'metricdata') && ~isreset
    return;
end


% Update handles structure
guidata(handles.avg_dq, handles);


% --- Executes on button press in checkbox1_paraSME.
function checkbox1_paraSME_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1_paraSME (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1_paraSME
SME_here = get(hObject,'Value');
%disp(SME_here);

temp_times = handles.Tout;

if SME_here
    set(handles.SME_table,'Enable','on');
    set(handles.radiobutton_SD,'Enable','on');
    set(handles.radiobutton_SD_corr,'Enable','on');
    
    if isempty(temp_times)
        temp_DQ_spec = make_DQ_spec(handles.timelimits);
        sme_tw_labels_old = temp_DQ_spec(3).time_window_labels;
        sme_tw_labels = strrep(sme_tw_labels_old,'aSME','(Metric)');
        sme_tw = num2cell(temp_DQ_spec(3).times);
        sme_tw2 = [sme_tw_labels' sme_tw];
        
        handles.Tout = sme_tw2;
        set(handles.SME_table, 'Data', sme_tw2);
        pause(0.3)
    end
    
else
    
    SD_check = get(handles.checkbox6_paraSD,'Value');
    if SD_check == 0
        set(handles.SME_table,'Enable','off');
        set(handles.radiobutton_SD,'Enable','off');
        set(handles.radiobutton_SD_corr,'Enable','off');  
        
    end
end


guidata(hObject, handles);


function pushbutton_help_Callback(hObject, eventdata, handles)
% doc pop_averager
web('https://github.com/lucklab/erplab/wiki/Computing-Averaged-ERPs#data-quality-measures', '-browser');


% --- Executes when user attempts to close avg_dq.
function avg_dq_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to avg_dq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




if isequal(get(handles.avg_dq, 'waitstatus'), 'waiting')
    %The GUI is still in UIWAIT, us UIRESUME
    handles.output = '';
    %Update handles structure
    guidata(hObject, handles);
    uiresume(handles.avg_dq);
else
    % The GUI is no longer waiting, just close it
    delete(handles.avg_dq);
end
% Hint: delete(hObject) closes the figure
%delete(hObject);


% --- Executes during object creation, after setting all properties.
function SME_table_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SME_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


Tout = hObject.Data;
handles.Tout = Tout;
guidata(hObject, handles);



% --- Executes when entered data in editable cell(s) in SME_table.
function SME_table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to SME_table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
% handles.tdata = eventdata.NewData;
% handles.SME_table.Data = handles.tdata;


Tout = hObject.Data;
handles.Tout = Tout;
guidata(hObject, handles);


% --- Executes on button press in SME_row_minus.
function SME_row_minus_Callback(hObject, eventdata, handles)
% hObject    handle to SME_row_minus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

curr_rows = size(handles.Tout,1);

row_del = handles.sel_row;


if curr_rows <= 1
    beep
    disp('Already at 1 rows')
else
    
    % notify
    row_del_text = ['Now removing row ' num2str(row_del)];
    disp(row_del_text)
    
    new_rows = curr_rows - 1;
    
    new_Tout = handles.Tout;
    new_Tout(row_del,:) = []; % pop the selected row out
    handles.Tout = new_Tout;
    
    %     row_drop_txt = ['The number of rows was ' num2str(curr_rows) '. Now dropping to ' num2str(new_rows)];
    % disp(row_drop_txt)
    set(handles.SME_table,'Data',new_Tout)
    pause(0.3)
    handles.sel_row = new_rows;
        
    % 
    
end


guidata(hObject, handles);


% --- Executes on button press in SME_row_plus.
function SME_row_plus_Callback(hObject, eventdata, handles)
% hObject    handle to SME_row_plus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

curr_rows = size(handles.Tout,1);
new_rows = curr_rows + 1;

old_Tout = handles.Tout;
win_size = old_Tout{end,3} - old_Tout{end,2};

new_row_str = ['(Metric) Time Window custom ' num2str(new_rows)];
new_row_cell = {new_row_str,old_Tout{end,3},old_Tout{end,3}+win_size};
new_Tout = [old_Tout;new_row_cell];

handles.Tout = new_Tout;

set(handles.SME_table,'Data',new_Tout);



guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function text_time_range_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_time_range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in checkbox_baseline_noise.
function checkbox_baseline_noise_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_baseline_noise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hint: get(hObject,'Value') returns toggle state of checkbox_baseline_noise
inc_baseline = get(hObject,'Value');
if inc_baseline == 1
    set(handles.checkbox_basel_default_times,'Value',1);
    set(handles.radiobutton_basel_custom_times,'Value',1);
    set(handles.radiobutton_basel_sd,'Value',1);
    set(handles.radiobutton_basel_sdcorr,'Value',1);
    set(handles.radiobutton_basel_rms,'Value',1); 
else
    set(handles.checkbox_basel_default_times,'Value',0);
    set(handles.radiobutton_basel_custom_times,'Value',0);
    set(handles.radiobutton_basel_sd,'Value',0);
    set(handles.radiobutton_basel_sdcorr,'Value',0);
    set(handles.radiobutton_basel_rms,'Value',0); 
end
guidata(hObject, handles);


% --- Executes on button press in checkbox_SEM.
function checkbox_SEM_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_SEM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_SEM
inc_SEM = get(hObject,'Value');
if inc_SEM == 1
    set(handles.radiobutton12,'Value',1);
    set(handles.radiobutton_sem_corr,'Value',1);
else
    set(handles.radiobutton12,'Value',0);
    set(handles.radiobutton_sem_corr,'Value',0);
end
guidata(hObject, handles);



function baseline_start_Callback(hObject, eventdata, handles)
% hObject    handle to baseline_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of baseline_start as text
%        str2double(get(hObject,'String')) returns contents of baseline_start as a double


% --- Executes during object creation, after setting all properties.
function baseline_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baseline_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function baseline_end_Callback(hObject, eventdata, handles)
% hObject    handle to baseline_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of baseline_end as text
%        str2double(get(hObject,'String')) returns contents of baseline_end as a double


% --- Executes during object creation, after setting all properties.
function baseline_end_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baseline_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_baseline_subtract.
function checkbox_baseline_subtract_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_baseline_subtract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_baseline_subtract


% --- Executes on button press in radiobutton_basel_sd.
function radiobutton_basel_sd_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_basel_sd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_basel_sd
basel_sd = get(hObject,'Value');

if basel_sd
    set(handles.radiobutton_basel_rms,'Value',0);
end



% --- Executes on button press in radiobutton_basel_rms.
function radiobutton_basel_rms_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_basel_rms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_basel_rms
basel_rms = get(hObject,'Value');

if basel_rms
    set(handles.radiobutton_basel_sd,'Value',0);
end


% --- Executes on button press in checkbox_basel_default_times.
function checkbox_basel_default_times_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_basel_default_times (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_basel_default_times
default_times = get(hObject,'Value');

if default_times
    set(handles.baseline_start,'Enable','off');
    set(handles.baseline_end,'Enable','off');
    %set(handles.radiobutton_basel_custom_times,'Enable','off');
    set(handles.text_basel2,'Enable','off');
    set(handles.text_basel3,'Enable','off');
    
else
    set(handles.baseline_start,'Enable','on');
    set(handles.baseline_end,'Enable','on');
    %set(handles.radiobutton_basel_custom_times,'Enable','on');
    set(handles.text_basel2,'Enable','on');
    set(handles.text_basel3,'Enable','on');
end


% --- Executes on button press in radiobutton_basel_custom_times.
function radiobutton_basel_custom_times_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_basel_custom_times (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_basel_custom_times
custom_times = get(hObject,'Value');

if custom_times
    set(handles.baseline_start,'Enable','on');
    set(handles.baseline_end,'Enable','on');
    %set(handles.radiobutton_basel_custom_times,'Enable','on');
    set(handles.text_basel2,'Enable','on');
    set(handles.text_basel3,'Enable','on');
else
    set(handles.baseline_start,'Enable','off');
    set(handles.baseline_end,'Enable','off');
    %set(handles.radiobutton_basel_custom_times,'Enable','off');
    set(handles.text_basel2,'Enable','off');
    set(handles.text_basel3,'Enable','off');  
end


% --- Executes when selected cell(s) is changed in SME_table.
function SME_table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to SME_table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

%disp(eventdata)
% if the selected cell info exists, save it to handles
if numel(eventdata.Indices)
    row_here = eventdata.Indices(1);
    old_row = handles.sel_row;
    handles.sel_row = row_here;
    if isequal(row_here,old_row) == 0
        row_text = ['Row number ' num2str(row_here) ' now selected'];
        disp(row_text)
    end
    guidata(hObject, handles);
end




% --- Executes on button press in restbutton.
function restbutton_Callback(hObject, eventdata, handles)
% hObject    handle to restbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get default timewindows
temp_DQ_spec = make_DQ_spec(handles.timelimits);
sme_tw_labels_old = temp_DQ_spec(3).time_window_labels;
sme_tw_labels = strrep(sme_tw_labels_old,'aSME','(Metric)'); 
sme_tw = num2cell(temp_DQ_spec(3).times);
sme_tw2 = [sme_tw_labels' sme_tw];

handles.Tout = sme_tw2; 
set(handles.SME_table, 'Data', sme_tw2); 
pause(0.3)


guidata(hObject, handles);


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox6_paraSD.
function checkbox6_paraSD_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6_paraSD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SD_check = get(hObject,'Value');
%disp(SME_here);
temp_times = handles.Tout; 

if SD_check
    set(handles.SME_table,'Enable','on');
    set(handles.radiobutton_SD,'Enable','on');
    set(handles.radiobutton_SD_corr,'Enable','on');
    
    if isempty(temp_times)
        temp_DQ_spec = make_DQ_spec(handles.timelimits);
        sme_tw_labels_old = temp_DQ_spec(3).time_window_labels;
        sme_tw_labels = strrep(sme_tw_labels_old,'aSME','(Metric)');
        sme_tw = num2cell(temp_DQ_spec(3).times);
        sme_tw2 = [sme_tw_labels' sme_tw];
        
        handles.Tout = sme_tw2;
        set(handles.SME_table, 'Data', sme_tw2);
        pause(0.3)
    end
 
    
else
    SME_check = get(handles.checkbox1_paraSME,'Value');
    if SME_check == 0 
    set(handles.SME_table,'Enable','off');
    set(handles.radiobutton_SD,'Enable','off'); 
    set(handles.radiobutton_SD_corr,'Enable','off');
    end
end

guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of checkbox6_paraSD


% --- Executes on button press in radiobutton_SD_corr.
function radiobutton_SD_corr_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_SD_corr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_SD_corr
