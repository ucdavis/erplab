function varargout = chanloc(varargin)
%
%  ERPLAB
%   axs 2017
%
%
% CHANLOC MATLAB code for chanloc.fig
%      CHANLOC, by itself, creates a new CHANLOC or raises the existing
%      singleton*.
%
%      H = CHANLOC returns the handle to a new CHANLOC or the handle to
%      the existing singleton*.
%
%      CHANLOC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHANLOC.M with the given input arguments.
%
%      CHANLOC('Property','Value',...) creates a new CHANLOC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before chanloc_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to chanloc_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help chanloc

% Last Modified by GUIDE v2.5 16-May-2017 06:02:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @chanloc_OpeningFcn, ...
                   'gui_OutputFcn',  @chanloc_OutputFcn, ...
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


% --- Executes just before chanloc is made visible.
function chanloc_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to chanloc (see VARARGIN)



axis(handles.hp_axes, 'off');

% Initialise some gui defaults
n_args = numel(varargin);
if n_args < 1
    disp('Arguments missing. Please call chanloc(EEG) with a valid dataset.')
    figure1_CloseRequestFcn(hObject)
end

EEG = varargin{1};
handles.output = [];

try
    assert(isstruct(EEG)==1)
    assert(isfield(EEG, 'chanlocs')==1)
catch
    disp('This doesn''t look like a valid dataset. Check input')
    figure1_CloseRequestFcn(hObject)
    
end

% Check for chaninfo
if isfield(EEG,'chaninfo') == 0
    EEG.chaninfo.icachanind = []; EEG.chaninfo.plotrad = []; EEG.chaninfo.shrink = []; EEG.chaninfo.nosedir = '+X'; EEG.chaninfo.nodatchans = [];
end

% Check the locations in the input dataset

handles.locmode = 1;

ch_n = numel(EEG.chanlocs);
locs_in = struct2cell(EEG.chanlocs);
locs_in = squeeze(locs_in)';
locs_in_size = size(locs_in);

fields_here = fieldnames(EEG.chanlocs);
field_x = find(strcmp(fields_here,'X')==1);
field_y = find(strcmp(fields_here,'Y')==1);
field_z = find(strcmp(fields_here,'Z')==1);
field_labels = find(strcmp(fields_here,'labels')==1);

locs_in_xyz = zeros(ch_n, 3);
missing = zeros(ch_n, 1);

ch_labels = locs_in(:,field_labels);

% Check for missing input
if locs_in_size(2) < 12
    
    % in the case of missing chanloc columns, leave as zeros
else
    % if not missing input, load from chanloc
    locs_cells = [locs_in(:,field_x) locs_in(:,field_y) locs_in(:,field_z)];
    
    % check for nans or empty, if so, write zeros
    empty_cells = cellfun('isempty',locs_cells);
    if any(empty_cells(:))
        for i = 1:numel(empty_cells)
            if empty_cells(i)
                locs_cells{i} = 0;
            end
        end
        
        % Record which chans were missing
        for ir = 1:ch_n
            if any(empty_cells(ir,:))
                missing(ir) = 1;
            end
        end
    end
    
    % convert de-nan'd cells to numeric array
    locs_in_xyz = cell2mat(locs_cells);
end


for i = 1:ch_n
    
    nchl(i).labels = ch_labels{i};
    nchl(i).type = [];
    nchl(i).theta = [];
    nchl(i).radius = [];
    nchl(i).X = locs_in_xyz(i,1);
    nchl(i).Y = locs_in_xyz(i,2);
    nchl(i).Z = locs_in_xyz(i,3);
    nchl(i).sph_theta = [];
    nchl(i).sph_phi = [];
    nchl(i).sph_radius = 85;
    nchl(i).urchan = i;
    nchl(i).ref = [];
end


[nchl] = pop_chanedit(nchl, 'convert','cart2topo');


%handles.locformat = {'channum','X','Y','Z','labels'};	
handles.locformat = 'sph';
handles.tformat = 'xyz';


handles.nchl = nchl;
handles.ch_n = ch_n;
handles.ch_labels = ch_labels;
handles.xyz = locs_in_xyz;
handles.nchl_orig = nchl;
handles.EEG = EEG;


refreshtable(hObject, handles);
refreshhp(hObject, handles);


guidata(hObject, handles);
% Use the buttondown code to refresh?



helpbutton;

% Choose default command line output for chanloc
%handles.output = hObject;
handles.output = EEG;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes chanloc wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = chanloc_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function refreshtable(hObject, handles)

%disp(handles.tformat);

if strcmp(handles.tformat,'xyz')
    
    for i = 1:handles.ch_n
        ch_xyz(i,:) = [handles.nchl(i).X handles.nchl(i).Y handles.nchl(i).Z];
    end
    set(handles.loc_table,'Data',ch_xyz,'ColumnName',{'X';'Y';'Z'},'RowName',handles.ch_labels );
    set(handles.loc_table,'ColumnEditable',true(1,2,3));
end


if strcmp(handles.tformat,'sph')
    
    for i = 1:handles.ch_n
        ch_sph(i,:) = [handles.nchl(i).sph_theta handles.nchl(i).sph_phi];
    end
    set(handles.loc_table,'Data',ch_sph,'ColumnName',{'sph_theta';'sph_radius';' '},'RowName',handles.ch_labels );
    set(handles.loc_table,'ColumnEditable',false);
    set(handles.loc_table,'ColumnEditable',true(1,2));
end


guidata(hObject, handles);

function refreshhp(hObject, handles)

% clear existing axes content
cla(handles.hp_axes)

hp_fig = figure('Visible','Off');
topoplot([],handles.nchl, 'style', 'blank',  'electrodes', 'labelpoint', 'chaninfo', handles.EEG.chaninfo);
topo_axes = gca;
topo2 = get(topo_axes,'children');
copyobj(topo2, handles.hp_axes);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
handles.output = handles.EEG;

delete(handles.figure1);


% --- Executes during object creation, after setting all properties.
function loc_table_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loc_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

ch_xyz = ones(16,3);
ch_labels = 'label';

%old_d = get(hObject, 'Data');
%disp(old_d);

set(hObject,'Data',ch_xyz,'ColumnName',{'X';'Y';'Z'},'RowName',ch_labels);


function loc_table_ButtonDownFcn(hObject, eventdata, handles)


% --- Executes when entered data in editable cell(s) in loc_table.
function loc_table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to loc_table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

% Get the new data from the table after an edit
tdata = get(handles.loc_table,'Data');



% recreate a new channel location structure
for i = 1:handles.ch_n
    
    nchl(i).labels = handles.ch_labels{i};
    nchl(i).type = [];
    nchl(i).theta = [];
    nchl(i).radius = [];
    nchl(i).X = [];%handles.xyz(i,1);
    nchl(i).Y = [];%handles.xyz(i,2);
    nchl(i).Z = [];%handles.xyz(i,3);
    nchl(i).sph_theta = [];
    nchl(i).sph_phi = [];
    nchl(i).sph_radius = 85;
    nchl(i).urchan = i;
    nchl(i).ref = [];
    
    
    if strcmp(handles.tformat,'xyz')  % in xyz
        nchl(i).X = tdata(i,1);
        nchl(i).Y = tdata(i,2);
        nchl(i).Z = tdata(i,3);
        
    elseif strcmp(handles.tformat,'sph')  % in sph
        nchl(i).sph_theta = tdata(i,1);
        nchl(i).sph_phi = tdata(i,2);
    end
    
    
end

if strcmp(handles.tformat,'xyz')  % in xyz
    [nchl] = pop_chanedit(nchl, 'convert','cart2all');
else
    [nchl] = pop_chanedit(nchl, 'convert','sph2all');
end

handles.nchl = nchl;

%disp(handles.xyz);
refreshtable(hObject, handles);
refreshhp(hObject, handles);


% --- Executes on button press in pushbutton_load_file.
function pushbutton_load_file_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
done_loading = 0;
[lfile,lpath] = uigetfile('locations.sph','Choose a file with channel location information');
%load_str = [lpath lfile];  ' ''filetype'' ''xyz'''];
%load_cell = {[lpath lfile], 'filetype', 'xyz'};
%EEG3 = pop_chanedit(handles.EEG,'load',load_cell);

if lfile == 0
    disp('Location load file cancelled')
    return
end


lnchl = readlocs([lpath lfile],'filetype',handles.locformat);
%try
    %lnchl = pop_chanedit(handles.nchl,'load',[lpath lfile],'format',handles.locformat);
    %lnchl = readlocs(handles.nchl,[lpath lfile],'format',handles.locformat);
%catch
    %disp('Location file loading problems?')
%end

% Sanity check
loaded = struct2cell(lnchl);
loaded = squeeze(loaded)';
loaded_labels = loaded(:,1);
loaded_n = length(lnchl);

if isequal(loaded_labels,handles.ch_labels)
    
    % if the labels exactly match, just write to handles
    handles.nchl = lnchl;
    done_loading = 1;
    
else
    
    EEG_loaded.chanlocs = lnchl;
    handles.EEG = chanlocs_matcher(handles.EEG,EEG_loaded);
    handles.nchl = handles.EEG.chanlocs;
end

loaded = struct2cell(handles.nchl);
loaded = squeeze(loaded)';
loaded_labels = loaded(:,1);
loaded_n = length(lnchl);

fields_here = fieldnames(handles.nchl);
field_x = find(strcmp(fields_here,'X')==1);
field_y = find(strcmp(fields_here,'Y')==1);
field_z = find(strcmp(fields_here,'Z')==1);
field_labels = find(strcmp(fields_here,'labels')==1);


% Remake the xyz num array
locs_cells = [loaded(:,field_x) loaded(:,field_y) loaded(:,field_z)];
empty_cells = cellfun('isempty',locs_cells);
if any(empty_cells(:))
    for i = 1:numel(empty_cells)
        if empty_cells(i)
            locs_cells{i} = 0;
        end
    end
    
    % Record which chans were missing
    for ir = 1:loaded_n
        if any(empty_cells(ir,:))
            missing(ir) = 1;
        end
    end
end

% convert de-nan'd cells to numeric array
handles.xyz = cell2mat(locs_cells);


% Update handles structure
guidata(hObject, handles);


refreshtable(hObject, handles);
refreshhp(hObject, handles);
    



% --- Executes on button press in pushbutton_load_set.
function pushbutton_load_set_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[lfile,lpath] = uigetfile('dataset_with_locs.set','Choose a dataset file that has channel location information');

if lfile == 0
    disp('Location load file cancelled')
    return
end

EEG_l = pop_loadset(lfile,lpath);
lnchl = EEG_l.chanlocs;

% Sanity check
loaded = struct2cell(lnchl);
loaded = squeeze(loaded)';
loaded_labels = loaded(:,1);
loaded_n = length(lnchl);

if isequal(loaded_labels,handles.ch_labels)
    
    % if the labels exactly match, just write to handles
    handles.nchl = lnchl;
    done_loading = 1;
    
else
    
    EEG_loaded.chanlocs = lnchl;
    handles.EEG = chanlocs_matcher(handles.EEG,EEG_loaded);
    handles.nchl = handles.EEG.chanlocs;
end

loaded = struct2cell(handles.nchl);
loaded = squeeze(loaded)';
loaded_labels = loaded(:,1);
loaded_n = length(lnchl);

fields_here = fieldnames(handles.nchl);
field_x = find(strcmp(fields_here,'X')==1);
field_y = find(strcmp(fields_here,'Y')==1);
field_z = find(strcmp(fields_here,'Z')==1);
field_labels = find(strcmp(fields_here,'labels')==1);


% Remake the xyz num array
locs_cells = [loaded(:,field_x) loaded(:,field_y) loaded(:,field_z)];
empty_cells = cellfun('isempty',locs_cells);
if any(empty_cells(:))
    for i = 1:numel(empty_cells)
        if empty_cells(i)
            locs_cells{i} = 0;
        end
    end
    
    % Record which chans were missing
    for ir = 1:loaded_n
        if any(empty_cells(ir,:))
            missing(ir) = 1;
        end
    end
end

% convert de-nan'd cells to numeric array
handles.xyz = cell2mat(locs_cells);

%nchl.type = 'nope';

% Update handles structure
guidata(hObject, handles);


refreshtable(hObject, handles);
refreshhp(hObject, handles);



% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[sfile,spath] = uiputfile('locations.sph','Choose a location save file name');

if sfile == 0
    disp('Save locations - file selection cancelled')
    return
end


writelocs(handles.nchl,[spath sfile],'filetype',handles.locformat);





% --- Executes on button press in pushbutton_help.
function pushbutton_help_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('https://github.com/lucklab/erplab/wiki/ERPLAB-Channel-location-editor','-browser')

% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure1_CloseRequestFcn(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_apply.
function pushbutton_apply_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handle.EEG.chanlocs = handles.nchl;
handles.output = handles.EEG;

varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.figure1);
pause(0.1)



% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton_save.
function pushbutton_save_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_reset.
function pushbutton_reset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

confirm_reset = questdlg('Reset the locations in this table to the original values?');

if strcmp(confirm_reset, 'Yes') == 1
    handles.nchl = handles.nchl_orig;
    refreshtable(hObject, handles);
    loc_table_CellEditCallback(hObject, eventdata, handles);
end


% --- Executes on selection change in popupmenu_format.
function popupmenu_format_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_format (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_format contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_format
menu =  get(hObject,'Value');
if menu == 1
    handles.tformat = 'xyz';
elseif menu == 2
    handles.tformat = 'sph';
end

refreshtable(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu_format_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_format (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
