function varargout = bdfVisualizer(varargin)
% BDFVISUALIZER MATLAB code for bdfVisualizer.fig
%      BDFVISUALIZER, by itself, creates a new BDFVISUALIZER or raises the existing
%      singleton*.
%
%      H = BDFVISUALIZER returns the handle to a new BDFVISUALIZER or the handle to
%      the existing singleton*.
%
%      BDFVISUALIZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BDFVISUALIZER.M with the given input arguments.
%
%      BDFVISUALIZER('Property','Value',...) creates a new BDFVISUALIZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bdfVisualizer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bdfVisualizer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bdfVisualizer

% Last Modified by GUIDE v2.5 15-Jan-2015 15:52:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @bdfVisualizer_OpeningFcn, ...
    'gui_OutputFcn',  @bdfVisualizer_OutputFcn, ...
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


% --- Executes just before bdfVisualizer is made visible.
function bdfVisualizer_OpeningFcn(hObject, ~, handles, varargin) %#ok<*DEFNU>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bdfVisualizer (see VARARGIN)


if(verLessThan('matlab', '8.2'))
    err_msg   = sprintf('Upgrade to Matlab 8.2 (2013b) or higher.\n\n BDF Visualizer will not run correctly for this Matlab version: %s.', version);
    err_title = 'Matlab Version Incompatibility';
    errorfound(err_msg, err_title);
    return;
end


% Choose default command line output for bdfVisualizer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes bdfVisualizer wait for user response (see UIRESUME)
% uiwait(handles.windowBDFVisualizer);


%% Load default ELIST
handles.EEG                  = struct();
handles.EEG.EVENTLIST        = generateDefaultEventlistStruct();                      % nested function within BDFVISUALIZER.M
guidata(hObject, handles);                                                            % save EVENTLIST to HANDLES

% UPDATE GUI: ELIST Window
% tableEventList                    = struct2table(handles.EEG.EVENTLIST.eventinfo);
% handles.numBits                   = 16;
% tableEventList.bini               = [];
%
% % Convert the flag variable into its binary representation and split into
% % its user-flag and artifact-flag
% binaryFlag                        = dec2bin(tableEventList.flag, handles.numBits);    % Convert artifact flags & user flags to binary
% tableEventList.artifactFlag       = binaryFlag(:, 1:handles.numBits/2);
% tableEventList.userFlag           = binaryFlag(:, handles.numBits/2+1:end);
%
%
% % Rearrange the event list table so that the bin label is a the end
% tableEventList                    = tableEventList(:,[1:9 11:12 10]);


% Save the event-list table to the UI-table
tableEventList                    = eventlist2table(handles.EEG.EVENTLIST.eventinfo);
hUITableELIST                     = handle(handles.uitableELIST);
hUITableELIST.Data                = table2cell(tableEventList);
hUITableELIST.ColumnName          = tableEventList.Properties.VariableNames';




% UPDATE GUI: Eventlist Max window
hEditEventlistMax                 = handle(handles.editTxtEventlistMax);              % Retrieve data from the GUI
hEditEventlistMax.String          = num2str(length(hUITableELIST.Data));


%% Load default BDF
handles.bdf                     = generateDefaultBDFStruct();                         % load the text-string into HANDLES

hEditBDF                        = handle(handles.editBDF);
hEditBDF.String                 = handles.bdf;                                        % Display BDF to GUI


%% Initiate default BDF Feedback Window
hUITableBinlisterFeedback         = handle(handles.uitableBinlisterFeedback);
hUITableBinlisterFeedback.Data    = {'Total Event Codes', 'Bin 1'; 0         , 0        };


handles.lastPath = pwd;
% handles.EEG      = [];
% Update handles structure
guidata(hObject, handles);                                                          % save HANDLES structure to GUI


% --- Outputs from this function are returned to the command line.
function varargout = bdfVisualizer_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editBDF_Callback(~, ~, ~)
% hObject    handle to editBDF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBDF as text
%        str2double(get(hObject,'String')) returns contents of editBDF as a double


% --- Executes during object creation, after setting all properties.
function editBDF_CreateFcn(hObject, ~, ~)
% hObject    handle to editBDF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonAnalyzeBDF.
function pushbuttonAnalyzeBDF_Callback(~, ~, handles)
% hObject    handle to pushbuttonAnalyzeBDF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    % Turn the interface off for processing.
    InterfaceObj=findobj(handle(handles.windowBDFVisualizer),'Enable','on');
    set(InterfaceObj,'Enable','off');
    drawnow;
    
    hEditEventlistMax   = handle(handles.editTxtEventlistMax);              % Retrieve BDF data from the GUI
    eventlistMax        = str2double(hEditEventlistMax.String);
    
    
    % Load BDF
    hEditBDF        = handle(handles.editBDF);              % Retrieve BDF data from the GUI
    BDFfilename     = fullfile(pwd,'BDF-tmp.txt');          % Create temporary BDF-file
    fileID          = fopen(BDFfilename, 'wt');             %
    fprintf(fileID,'%s\n', hEditBDF.String{:});             %
    fclose( fileID);
    
    % Load ELIST
    objELIST                    = handle(handles.uitableELIST);                         % Get the current Event List from the GUI
    
    
    handles.EEG.EVENTLIST.eventinfo = cell2struct(objELIST.Data(1:eventlistMax,:), objELIST.ColumnName', 2);  %
    
    
    %% RUN BINLISTER
    [handles.EEG, handles.EEG.EVENTLIST]  = binlister( handles.EEG ... % emptyEEG
        , BDFfilename       ...         % inputBinDescriptorFile
        , 'none'            ...         % inputEventList
        , 'none'            ...         % outputEventList
        , []                ...         % forbiddenCodeArray
        , []                ...         % ignoreCodeArray
        , 0                 );          % reportable
    
    
    if(isempty(handles.EEG.EVENTLIST));
        % Turn the interface back on
        set(InterfaceObj,'Enable','on');
        drawnow;
        return;
    end
    
    %% Display updated ELIST-struct to GUI
    %     tableEventList                    = struct2table(handles.EEG.EVENTLIST.eventinfo);
    %     tableEventList.binaryFlag         = dec2bin(tableEventList.flag, handles.numBits);                % Convert artifact flags & user flags to binary
    %
    % convert each numeric column to a string in order to save to
    % UITABLE.DATA
    %     for col_index = 1:width(tableEventList)
    %         if(isnumeric(tableEventList.(col_index)))
    %             tableEventList.(col_index) = num2str(tableEventList.(col_index));
    %         end
    %     end
    
    %     for col_index = 1:width(tableEventList)
    %         if(isnumeric(tableEventList.(col_index)))
    %             columnSize = size(tableEventList.(col_index), 2);
    %             if(columnSize > 1)
    %                 tableEventList.(col_index) = num2str(tableEventList.(col_index));
    %             end
    %         end
    %     end
    
    
    %     tableEventList.bini = [];
    
    
    tableEventList                    = eventlist2table(handles.EEG.EVENTLIST.eventinfo);
    hUITableELIST                     = handle(handles.uitableELIST);
    hUITableELIST.Data                = table2cell(tableEventList);
    hUITableELIST.ColumnName          = tableEventList.Properties.VariableNames';
    
    drawnow;
    
    % hUITableELIST.columnWidth         = 'auto';
    % hUITableELIST.columnName          = fieldnames(handles.EEG.EVENTLIST.eventinfo);
    
    
    
    %% Display updated BDF Feedback window
    totalEvents                       = length(handles.EEG.EVENTLIST.eventinfo);
    hUITableBinlisterFeedback         = handle(handles.uitableBinlisterFeedback);
    %     hUITableBinlisterFeedback.rowName = { 'Total Event Codes', handles.EEG.EVENTLIST.bdf.namebin };
    hUITableBinlisterFeedback.Data    = [{'Total Event Codes' handles.EEG.EVENTLIST.bdf.namebin}', num2cell([totalEvents handles.EEG.EVENTLIST.trialsperbin])'];
    %% Cleanup
    delete(BDFfilename);                                    % Delete temporary BDF-file
    %     delete(ELISTfilename);                                  % Delete temporary ELIST-file
    %     set( findall(handles.windowBDFVisualizer, '-property', 'Enable'), 'Enable', 'on')
    
    % Turn the interface back on
    set(InterfaceObj,'Enable','on');
    drawnow;
    
catch errorObj
    % If there is a problem, display the error message
    display(getReport(errorObj,'extended','hyperlinks','on'),'Error');
    %     set(InterfaceObj,'Enable','on');
    
    if(strcmpi(errorObj.stack(1).name, 'binlister') && errorObj.stack(1).line == 706)
        errordlg(sprintf('\n\n\tCannot analyze a BDF file containing RT-flags without an EEG dataset.\n\n\tRemove exist RT-flags from the BDF-file or load an existing EEG dataset.\n\n'), 'RT-Flag Error');
    elseif(strcmpi(errorObj.stack(1).name, 'pushbuttonAnalyzeBDF_Callback') && errorObj.stack(1).line == 171)
        errordlg(sprintf('\n\n\tBin numbers must be in sequential order.\n\n\tFix your bin numbers.\n\n'), 'BDF - Bin Number Error');
    else
        errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
    end
    
    % Turn the interface back on
    set(InterfaceObj,'Enable','on');
    drawnow;
    
end

% --- Executes on button press in pushbuttonLoadBDF.
function pushbuttonLoadBDF_Callback(hObject, ~, handles)
% hObject    handle to pushbuttonLoadBDF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    [fileName, pathName, filterIndex] = uigetfile(              ...
        {'*.txt', 'Select a bin descriptor file (BDF)'   ...
        ; '*.*'  , 'All files (*.*)'                   } ...
        , 'Select BDF File' ...
        , handles.lastPath);
    if(pathName)
        handles.lastPath = pathName;                                             % Update the last directory in HANDLES
        guidata(hObject,handles);                                                % Update the HANDLES data-structure
    end
    
    switch(filterIndex)
        case 0
            % User-selected Cancel
            display('User selected cancel');
        otherwise
            % Load file into ELIST-structure via READEVENTLIST
            BDFfilename                 = fullfile(pathName,fileName);
            fileID                      = fopen(BDFfilename);
            fileString                  = textscan(fileID, '%s', 'Delimiter','\n');
            fclose(fileID);
            
            handles.bdf                 = fileString{1};    % Update the BDF variable in HANDLES
            handles.lastPath            = pathName;         % Update the last directory in HANDLES
            guidata(hObject,handles);                       % Update the HANDLES data-structure
            
            %% DISPLAY LOADED BDF TO GUI
            hEditBDF               = handle(handles.editBDF);
            hEditBDF.String        = handles.bdf;
    end
    
catch errorObj
    % If there is a problem, display the error message
    display(getReport(errorObj,'extended','hyperlinks','on'),'Error');
    %     set(InterfaceObj,'Enable','on');
    
    if(strcmpi(errorObj.stack(1).name, 'readeventlist') && errorObj.stack(1).line == 140)
        errordlg(sprintf('\n\nIncorrect File Type:\tFile is not an acceptable BIN DESCRIPTOR FILE.\n\nSelect another BDF0file\n\n'), 'Incorrect File Type Error');
    else
        errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
    end
    
end

% --- Executes on button press in pushbuttonImportEventList.
function pushbuttonImportEventList_Callback(hObject, ~, handles)
% hObject    handle to pushbuttonImportEventList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    % Turn the interface off for processing.
    InterfaceObj=findobj(handle(handles.windowBDFVisualizer),'Enable','on');
    set(InterfaceObj,'Enable','off');
    drawnow;
    
    [fileName, pathName]        = uigetfile(               ...
        {'*.txt;*.set', 'ELIST (*.txt) or EEG file (*.set)';            ...
        '*.*','All Files (*.*)'                                }        ...
        , 'MultiSelect', 'off'                                          ...
        , 'Select Event List Source'                                    ...
        , handles.lastPath);   % Get filename/filepath
    
    if(pathName)
        % Clear the Binlister Feedback uiTable
        hUITableBinlisterFeedback         = handle(handles.uitableBinlisterFeedback);
        hUITableBinlisterFeedback.Data    = {'Total Event Codes', 'Bin 1'; 0         , 0         };
        
        [~,~,fileExtension] = fileparts(fileName);
        handles.lastPath    = pathName;                                                             % Update the last directory in HANDLES
        guidata(hObject,handles);                                                                   % Update the HANDLES data-structure
    else
        fileExtension       = 'cancel';
    end
    
    
    % Check if FILE SELECTED or if CANCEL is selected
    
    switch(fileExtension)
        case 'cancel'  % CANCEL
            display('User selected cancel');                                                    % User-selected Cancel
        case '.txt'  % ELIST-TXT file
            
            ELISTfilename               = fullfile(pathName,fileName);                          % Load file into ELIST-structure via READEVENTLIST
            [~, handles.EEG.EVENTLIST]  = readeventlist([], ELISTfilename);
            
            
            %% !!!!!!!!!!!!!!!!!!!!!!!!!!!
            % Display updated ELIST-struct to GUI
            tableEventList                    = eventlist2table(handles.EEG.EVENTLIST.eventinfo);
            hUITableELIST                     = handle(handles.uitableELIST);
            hUITableELIST.Data                = table2cell(tableEventList);
            hUITableELIST.ColumnName          = tableEventList.Properties.VariableNames';
            
            
            
            
            % UPDATE GUI: Eventlist Max window
            hEditEventlistMax                 = handle(handles.editTxtEventlistMax);              % Retrieve data from the GUI
            hEditEventlistMax.String          = num2str(length(hUITableELIST.Data));
            
            
        case '.set' % EEG-SET file
            handles.EEG = pop_loadset('filename',fileName,'filepath',pathName);
            handles.EEG = eeg_checkset( handles.EEG );
            
            % If EEG.EVENTLIST does not exist
            if(~isfield(handles.EEG, 'EVENTLIST'))
                % Create EVENTLIST from EEG dataset
                handles.EEG  = pop_creabasiceventlist( handles.EEG ...
                    ... %         , 'Eventlist','/Users/etfoo/Documents/MATLAB/Eventlist.txt' ...
                    , 'AlphanumericCleaning'    , 'on'              ...
                    , 'BoundaryNumeric'         , { -99 }           ...
                    , 'BoundaryString'          , { 'boundary' }    ...
                    , 'Warning'                 , 'off'              ...
                    );
            end
            
            
            %% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            % Update the GUI ELIST uiTable
            tableEventList                    = eventlist2table(handles.EEG.EVENTLIST.eventinfo);
            hUITableELIST                     = handle(handles.uitableELIST);
            hUITableELIST.Data                = table2cell(tableEventList);
            hUITableELIST.ColumnName          = tableEventList.Properties.VariableNames';
            
            % UPDATE GUI: Eventlist Max window
            hEditEventlistMax                 = handle(handles.editTxtEventlistMax);              % Retrieve data from the GUI
            hEditEventlistMax.String          = num2str(length(hUITableELIST.Data));
            
        otherwise
    end
    
    guidata(hObject,handles);                                                                   % Update the HANDLES data-structure
    
    
    % Turn the interface back on
    set(InterfaceObj,'Enable','on');
    drawnow;
    
    
catch errorObj
    % If there is a problem, display the error message
    display(getReport(errorObj,'extended','hyperlinks','on'),'Error');
    %     set(InterfaceObj,'Enable','on');
    
    if(strcmpi(errorObj.stack(1).name, 'readeventlist') && errorObj.stack(1).line == 140)
        errordlg(sprintf('\n\nIncorrect File Type:\tFile does not contain an acceptable EVENT LIST FILE.\n\nSelect another file\n\n'), 'Incorrect File Type Error');
    else
        errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
    end
    
    % Turn the interface back on
    set(InterfaceObj,'Enable','on');
    drawnow;
    
    
end



function editTxtEventlistMax_Callback(~, ~, ~)
% hObject    handle to editTxtEventlistMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTxtEventlistMax as text
%        str2double(get(hObject,'String')) returns contents of editTxtEventlistMax as a double


% --- Executes during object creation, after setting all properties.
function editTxtEventlistMax_CreateFcn(hObject, ~, ~)
% hObject    handle to editTxtEventlistMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonBDFManualLink.
function pushbuttonBDFManualLink_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonBDFManualLink (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('https://github.com/lucklab/erplab/wiki/Assigning-Events-to-Bins-with-BINLISTER','-browser');


% --- Executes on button press in pushbuttonBDFTutorialLink.
function pushbuttonBDFTutorialLink_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonBDFTutorialLink (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('https://github.com/lucklab/erplab/wiki/BDF-Library','-browser');




%% Nested functions


function eventlist = generateDefaultEventlistStruct()

eventlist                   = struct;
eventlist.setname           = 'none_specified';
eventlist.report            = '';
eventlist.bdfname           = '';
eventlist.nbin              = 0;
eventlist.version           = '4.0.3.1';
eventlist.account           = '';
eventlist.username          = '';
eventlist.trialsperbin      = 0;
eventlist.elname            = 'default eventlist';
eventlist.bdf               = struct;
eventlist.bdf.expression    = [];
eventlist.bdf.description   = [];
eventlist.bdf.prehome       = [];
eventlist.bdf.athome        = [];
eventlist.bdf.posthome      = [];
eventlist.bdf.namebin       = [];
eventlist.bdf.rtname        = [];
eventlist.bdf.rtindex       = [];
eventlist.bdf.rt            = [];
eventlist.eldate            = '14-Jan-2015 15:24:22';
eventlist.eventinfo                 = struct;

for x = 1:100
    eventlist.eventinfo(x).item         = 1;
    eventlist.eventinfo(x).bepoch       = 0;
    eventlist.eventinfo(x).code         = 256;
    eventlist.eventinfo(x).codelabel    = '"EMPTY"';
    eventlist.eventinfo(x).time         = single(x/10);
    eventlist.eventinfo(x).spoint       = single(x);
    eventlist.eventinfo(x).dura         = single(x);
    eventlist.eventinfo(x).flag         = 0;
    eventlist.eventinfo(x).enable       = 1;
    eventlist.eventinfo(x).bini         = -1;
    eventlist.eventinfo(x).binlabel     = '""';
end


function bdfFile = generateDefaultBDFStruct()

bdfFile      = cell(3, 1);
bdfFile{1,1} = 'bin 1';
bdfFile{2,1} = 'Empty trials';
bdfFile{3,1} = '.{256}';


function eventlistTable = eventlist2table(eventlistStruct)


% UPDATE GUI: ELIST Window
eventlistTable                    = struct2table(eventlistStruct);
handles.numBits                   = 16;
eventlistTable.bini               = [];

% Convert the flag variable into its binary representation and split into
% its user-flag and artifact-flag
mybinaryFlag                      = dec2bin(eventlistTable.flag, handles.numBits);    % Convert artifact flags & user flags to binary
eventlistTable.artifactFlag       = mybinaryFlag(:, handles.numBits/2+1:end);
eventlistTable.userFlag           = mybinaryFlag(:, 1:handles.numBits/2);


% Rearrange the event list table so that the bin label is a the end
varnames = eventlistTable.Properties.VariableNames;
others = ~strcmp('binlabel',varnames);
varnames = [varnames(others) 'binlabel'];
eventlistTable = eventlistTable(:,varnames);
