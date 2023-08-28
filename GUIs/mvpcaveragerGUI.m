%
% Author: Aaron Matthew Simmons & Steven Luck
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


function varargout = mvpcaveragerGUI(varargin)
% MVPCAVERAGERGUI MATLAB code for mvpcaveragerGUI.fig
%      MVPCAVERAGERGUI, by itself, creates a new MVPCAVERAGERGUI or raises the existing
%      singleton*.
%
%      H = MVPCAVERAGERGUI returns the handle to a new MVPCAVERAGERGUI or the handle to
%      the existing singleton*.
%
%      MVPCAVERAGERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MVPCAVERAGERGUI.M with the given input arguments.
%
%      MVPCAVERAGERGUI('Property','Value',...) creates a new MVPCAVERAGERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mvpcaveragerGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mvpcaveragerGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mvpcaveragerGUI

% Last Modified by GUIDE v2.5 15-May-2023 15:05:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mvpcaveragerGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @mvpcaveragerGUI_OutputFcn, ...
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


% --- Executes just before mvpcaveragerGUI is made visible.
function mvpcaveragerGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mvpcaveragerGUI (see VARARGIN)

% Choose default command line output for mvpcaveragerGUI
handles.output = [];
handles.indxline = 1; %for addmvpc set

try        
        %       optioni  = answer{2}; %1 means from a filelist, 0 means from mvpcsets menu
        %       mvpcset   = answer{3};
        %       stderror    = answer{4}; % 0;1
        
        def = varargin{1};
        actualnset = def{1}; % number of loaded mvpcsets at mvpcset menu
        optioni    = def{2};   % datasets to average, %1 means from a filelist, 0 means from mvpcsets menu
        mvpcset     = def{3}; % %indexs of ALLMVPC to average
        stderror    = def{4};
catch
        actualnset  = 0;
        optioni     = 1;
        mvpcset      = '';
%         artcrite    = 100;
%         wavg        = 0;
%         excnullbin  = 1;
        stderror    = 1;
end
if ~isempty(mvpcset)
        if ischar(mvpcset)
                listname = mvpcset;
        else
                listname = [];
        end
else
        listname = [];
end

%helpbutton; %not yet created
handles.actualnset = actualnset; 
handles.listname = listname; 
handles.mvpcset = mvpcset; 

if optioni==0 && actualnset>0  && isnumeric(mvpcset)
        mvpcs = mvpcset(mvpcset<=actualnset);
        if isempty(mvpcs)
                mvpcs = 1:actualnset;
        end
        set(handles.radiobutton_mvpcset, 'Value', 1);
        set(handles.radiobutton_mvpcset, 'Enable', 'on');
        set(handles.edit_mvpcset, 'String', vect2colon(mvpcs, 'Delimiter', 'off', 'Repeat', 'off'));
        set(handles.radiobutton_folders, 'Value', 0);
        set(handles.listbox_mvpcnames, 'Enable', 'off');
        set(handles.pushbutton_addmvpcset, 'Enable', 'off');
        set(handles.pushbutton_delmvpcset, 'Enable', 'off');
        set(handles.button_loadlist, 'Enable', 'off');
        set(handles.button_savelist, 'Enable', 'off');
        set(handles.button_savelistas, 'Enable', 'off');
        set(handles.button_clearfile, 'Enable', 'off');
elseif optioni==0 && actualnset>0  && ~isnumeric(mvpcset)
        set(handles.radiobutton_mvpcset, 'Value', 1);
        set(handles.radiobutton_mvpcset, 'Enable', 'on');
        set(handles.edit_mvpcset, 'String', vect2colon(1:actualnset, 'Delimiter', 'off'));
        set(handles.radiobutton_folders, 'Value', 0);
        set(handles.listbox_mvpcnames, 'Enable', 'off');
        set(handles.pushbutton_addmvpcset, 'Enable', 'off');
        set(handles.pushbutton_delmvpcset, 'Enable', 'off');
        set(handles.button_loadlist, 'Enable', 'off');
        set(handles.button_savelist, 'Enable', 'off');
        set(handles.button_savelistas, 'Enable', 'off');
        set(handles.button_clearfile, 'Enable', 'off');
elseif optioni>=0 && actualnset==0  && isnumeric(mvpcset)
        set(handles.edit_mvpcset, 'String', 'no mvpcset found');
        set(handles.edit_mvpcset, 'Enable', 'off');
        set(handles.radiobutton_mvpcset, 'Value', 0);
        set(handles.radiobutton_mvpcset, 'Enable', 'off');
        set(handles.radiobutton_folders, 'Value', 1);
        set(handles.listbox_mvpcnames, 'String', {'new mvpcset'});
elseif optioni==0 && actualnset==0  && ~isnumeric(mvpcset)
        set(handles.edit_mvpcset, 'String', 'no mvpcset found');
        set(handles.edit_mvpcset, 'Enable', 'off');
        set(handles.radiobutton_mvpcset, 'Value', 0);
        set(handles.radiobutton_mvpcset, 'Enable', 'off');
        set(handles.radiobutton_folders, 'Value', 1);
        set(handles.listbox_mvpcnames, 'String', {'new mvpcset'});
elseif optioni==1 && actualnset>=0 && ~isnumeric(mvpcset)
        set(handles.edit_mvpcset, 'String', 'no mvpcset found');
        set(handles.edit_mvpcset, 'Enable', 'off');
        set(handles.radiobutton_mvpcset, 'Value', 0);
        set(handles.radiobutton_mvpcset, 'Enable', 'on');
        set(handles.edit_mvpcset, 'String', vect2colon(1:actualnset, 'Delimiter', 'off'));
        
        set(handles.radiobutton_folders, 'Value', 1);
        if ~isempty(mvpcset)
                button_loadlist_Callback(hObject, eventdata, handles, 1)
                %listname = mvpcset;
        else
                set(handles.listbox_mvpcnames, 'String', {'new mvpcset'});
        end
else
        error('no entiendo esta combinacion :(')
end

set(handles.checkbox_SEM, 'Value', stderror); %


%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -  MVPC AVERAGER GUI'])

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
%helpbutton

% UIWAIT makes grandaveragerGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);


% UIWAIT makes mvpcaveragerGUI wait for user response (see UIRESUME)
% uiwait(handles.gui_chassis);


% --- Outputs from this function are returned to the command line.
function varargout = mvpcaveragerGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

% --- Executes on button press in radiobutton_folders.
function radiobutton_folders_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_folders (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject, 'Value')
        set(handles.radiobutton_folders, 'Value', 1);
        set(handles.radiobutton_folders, 'Enable', 'on');
        set(handles.listbox_mvpcnames, 'Enable', 'on');
        set(handles.pushbutton_addmvpcset, 'Enable', 'on');
        set(handles.pushbutton_delmvpcset, 'Enable', 'on');
%         set(handles.button_loadlist, 'Enable', 'on');
%         set(handles.button_savelist, 'Enable', 'on');
%         set(handles.button_savelistas, 'Enable', 'on');
%         set(handles.button_clearfile, 'Enable', 'on');
        set(handles.radiobutton_mvpcset, 'Value', 0);
        
        if handles.actualnset==0
                set(handles.radiobutton_mvpcset, 'Enable', 'off');
        else
                set(handles.radiobutton_mvpcset, 'Enable', 'on');
        end
        if isempty(get(handles.listbox_mvpcnames,'String'))
                set(handles.listbox_mvpcnames,'String',{'new mvpcset'});
        end
        
        set(handles.edit_mvpcset, 'Enable', 'off');
        set(handles.edit_mvpcset, 'String', '');
else
        set(handles.radiobutton_folders, 'Value', 1);
end

% Hint: get(hObject,'Value') returns toggle state of radiobutton_folders


% --- Executes on selection change in listbox_mvpcnames.
function listbox_mvpcnames_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_mvpcnames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_mvpcnames contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_mvpcnames
fulltext  = get(handles.listbox_mvpcnames, 'String');
indxline  = length(fulltext);
currlineindx = get(handles.listbox_mvpcnames, 'Value');


% --- Executes during object creation, after setting all properties.
function listbox_mvpcnames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_mvpcnames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton_mvpcset.
function radiobutton_mvpcset_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_mvpcset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_mvpcset
if get(hObject, 'Value')
        actualnset = handles.actualnset;
        set(handles.radiobutton_mvpcset, 'Value', 1);
        set(handles.radiobutton_mvpcset, 'Enable', 'on');
        set(handles.edit_mvpcset, 'Enable', 'on');
        set(handles.edit_mvpcset, 'String', vect2colon(1:actualnset, 'Delimiter', 'off'));
        set(handles.radiobutton_folders, 'Value', 0);
        set(handles.listbox_mvpcnames, 'Enable', 'off');
        set(handles.pushbutton_addmvpcset, 'Enable', 'off');
        set(handles.pushbutton_delmvpcset, 'Enable', 'off');
%         set(handles.button_loadlist, 'Enable', 'off');
%         set(handles.button_savelist, 'Enable', 'off');
%         set(handles.button_savelistas, 'Enable', 'off');
%         set(handles.button_clearfile, 'Enable', 'off');
else
        set(handles.radiobutton_mvpcset, 'Value', 1);
end


function edit_mvpcset_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mvpcset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mvpcset as text
%        str2double(get(hObject,'String')) returns contents of edit_mvpcset as a double


% --- Executes during object creation, after setting all properties.
function edit_mvpcset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mvpcset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.figure1 = [];
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);


% --- Executes on button press in pushbutton_GO.
function pushbutton_GO_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_GO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stderror   = get(handles.checkbox_SEM,'Value'); % for standard error  1=>yes
warnon     = get(handles.checkbox_warning,'Value'); 

%
% mvpcsets
%
if get(handles.radiobutton_mvpcset, 'Value')
        mvpcset = str2num(char(get(handles.edit_mvpcset, 'String')));
        
        if length(mvpcset)<2
                msgboxText =  'You have to specify 2 mvpcsets, at least!';
                title = 'ERPLAB: mvpcaveragerGUI() -> missing input';
                errorfound(msgboxText, title);
                return
        end
        if min(mvpcset)<1 || max(mvpcset)>handles.actualnset
                msgboxText =  'Nonexistent mvpcset index(es)';
                title = 'ERPLAB: mvpcaveragerGUI()  -> wrong input';
                errorfound(msgboxText, title);
                return
        else
                handles.output = {0, mvpcset, stderror, warnon};
        end
else
        mvpcset = cellstr(get(handles.listbox_mvpcnames, 'String'));
        nline  = length(mvpcset);
        
        if nline<3 % 'new_mvpcset' line is being included
                msgboxText =  'You have to specify 2 mvpcsets, at least!';
                title = 'ERPLAB: mvpcaveragerGUI() -> missing input';
                errorfound(msgboxText, title);
                return
        end
        
        listname = handles.listname;
        
        if isempty(listname) && nline>1                
                BackERPLABcolor = [1 0.9 0.3];    % yellow
                question = ['You have not saved your list.\n'...
                        'What would you like to do?'];
                title = 'Save List of mvpcsets';
                oldcolor = get(0,'DefaultUicontrolBackgroundColor');
                set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
                button = questdlg(sprintf(question), title,'Save and Continue','Save As', 'Cancel','Save and Continue');
                set(0,'DefaultUicontrolBackgroundColor',oldcolor)
                
                if strcmpi(button,'Save As')
                        fullname = savelist(hObject, eventdata, handles);                        
                        handles.listname = fullname;
                        % Update handles structure
                        guidata(hObject, handles);
                        return
                elseif strcmpi(button,'Save and Continue')                        
                        fulltext = char(get(handles.listbox_mvpcnames,'String'));
                        %listname = char(strtrim(get(handles.edit_filelist,'String')));
                        listname = '';   
                        if isempty(listname)
                                fullname = savelist(hObject, eventdata, handles);
                                listname = fullname;
                                if isempty(listname)
                                        return
                                end
                        else
                                fid_list = fopen( listname , 'w');
                                for i=1:size(fulltext,1)-1
                                        fprintf(fid_list,'%s\n', fulltext(i,:));
                                end
                                fclose(fid_list);
                        end                        
                elseif strcmpi(button,'Cancel') || strcmpi(button,'')
                        handles.output = [];
                        handles.listname = [];
                        % Update handles structure
                        guidata(hObject, handles);
                        return
                end
        end   
        
        
        handles.output = {1, listname, stderror, warnon};
end





% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);



% --- Executes on button press in checkbox_SEM.
function checkbox_SEM_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_SEM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_SEM


% --- Executes on button press in pushbutton_addmvpcset.
function pushbutton_addmvpcset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_addmvpcset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[mvpcfname, mvpcpathname] = uigetfile({  '*.mvpc','Multivariate Pattern Classification files (*.mvpc)'; ...
        '*.mat','Matlab (*.mat)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Select an edited file', ...
        'MultiSelect', 'on');

if isequal(mvpcfname,0)
        disp('User selected Cancel')
        return
else
        if ~iscell(mvpcfname)
                mvpcfname = {mvpcfname};
        end
        
        nmvpcn = length(mvpcfname);
        
        for i=1:nmvpcn
                newline  = fullfile(mvpcpathname, mvpcfname{i});
                currline = get(handles.listbox_mvpcnames, 'Value');
                fulltext = get(handles.listbox_mvpcnames, 'String');
                indxline = length(fulltext);
                
                if currline==indxline
                        % extra line forward
                        fulltext  = cat(1, fulltext, {'new mvpcset'});
                        set(handles.listbox_mvpcnames, 'Value', currline+1)
                else
                        set(handles.listbox_mvpcnames, 'Value', currline)
                        resto = fulltext(currline:indxline);
                        fulltext  = cat(1, fulltext, {'new mvpcset'});
                        set(handles.listbox_mvpcnames, 'Value', currline+1)
                        [fulltext{currline+1:indxline+1}] = resto{:};
                end
                
                fulltext{currline} = newline;
                set(handles.listbox_mvpcnames, 'String', fulltext)
        end
        
        indxline = length(fulltext);
        handles.indxline = indxline;
        handles.fulltext = fulltext;
        handles.listname = [];
     %   set(handles.edit_filelist,'String','');
        % Update handles structure
        guidata(hObject, handles);
end


% --- Executes on button press in pushbutton_delmvpcset.
function pushbutton_delmvpcset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_delmvpcset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fulltext = get(handles.listbox_mvpcnames, 'String');
indxline = length(fulltext);
fulltext = char(fulltext); % string matrix
currline = get(handles.listbox_mvpcnames, 'Value');

if currline>=1 && currline<indxline
        fulltext(currline,:) = [];
        fulltext = cellstr(fulltext); % cell string
        set(handles.listbox_mvpcnames, 'String', fulltext);
        listbox_mvpcnames_Callback(hObject, eventdata, handles)
        handles.fulltext = fulltext;
        indxline = length(fulltext);
        handles.listname = [];
        set(handles.edit_filelist,'String','');
        
        % Update handles structure
        guidata(hObject, handles);
end


% --- Executes when user attempts to close gui_chassis.
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to gui_chassis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
        %The GUI is still in UIWAIT, us UIRESUME
        handles.output = [];
        %Update handles structure
        guidata(hObject, handles);
        uiresume(handles.gui_chassis);
else
        % The GUI is no longer waiting, just close it
        delete(handles.gui_chassis);
end


function fullname = savelist(hObject, eventdata, handles)

fulltext  = char(strtrim(get(handles.listbox_mvpcnames,'String')));
%pre_fname = char(strtrim(get(handles.edit_filelist,'String')));
pre_fname ='';

%
% Save OUTPUT file
%
[filename, filepath, filterindex] = uiputfile({'*.txt';'*.dat';'*.*'},'Save mvpcset list as', pre_fname);

if isequal(filename,0)
        disp('User selected Cancel')
        fullname =[];
        return
else        
        [px, fname, ext] = fileparts(filename);
        
        if strcmp(ext,'')
                
                if filterindex==1 || filterindex==3
                        ext   = '.txt';
                else
                        ext   = '.dat';
                end
        end
        
        fname = [ fname ext];
        fullname = fullfile(filepath, fname);
        disp(['For saving mvpcset list, user selected <a href="matlab: open(''' fullname ''')">' fullname '</a>'])
        fid_list   = fopen( fullname , 'w');
        
        for i=1:size(fulltext,1)-1
                fprintf(fid_list,'%s\n', fulltext(i,:));
        end        
        fclose(fid_list);
end


% --- Executes on button press in button_clearfile.
function button_clearfile_Callback(hObject, eventdata, handles)
% hObject    handle to button_clearfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit_filelist,'String','');
set(handles.button_savelist, 'Enable', 'off')
handles.listname = [];
% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in button_savelistas.
function button_savelistas_Callback(hObject, eventdata, handles)
% hObject    handle to button_savelistas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fulltext = char(get(handles.listbox_mvpcnames,'String'));

if length(fulltext)>1
        
        fullname = savelist(hObject, eventdata, handles);
        
        if isempty(fullname)
                return
        end
        
        set(handles.edit_filelist, 'String', fullname )
        set(handles.button_savelist, 'Enable', 'on')
        handles.listname = fullname;
        % Update handles structure
        guidata(hObject, handles);
else
        set(handles.button_savelistas,'Enable','off')
        msgboxText =  'You have not specified any mvpcset!';
        title = 'ERPLAB: mvpcaverager GUI few inputs';
        errorfound(msgboxText, title);
        set(handles.button_savelistas,'Enable','on')
        return
end




% --- Executes on button press in button_savelist.
function button_savelist_Callback(hObject, eventdata, handles)
% hObject    handle to button_savelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fulltext = char(strtrim(get(handles.listbox_mvpcnames,'String')));

if length(fulltext)>1
        
        fullname = get(handles.edit_filelist, 'String');
        
        if ~strcmp(fullname,'') && strcmp(fullname,'new mvpcset')
                
                fid_list   = fopen( fullname , 'w');
                
                for i=1:size(fulltext,1)
                        fprintf(fid_list,'%s\n', fulltext(i,:));
                end
                
                fclose(fid_list);
                handles.listname = fullname;
                
                % Update handles structure
                guidata(hObject, handles);
                disp(['Saving equation list at <a href="matlab: open(''' fullname ''')">' fullname '</a>'])
        else
                button_savelistas_Callback(hObject, eventdata, handles)
                return
        end
else
        set(handles.button_savelistas,'Enable','off')
        msgboxText =  'You have not written any formula yet!';
        title = 'ERPLAB: mvpcaveragerGUI few inputs';
        errorfound(msgboxText, title);
        set(handles.button_savelistas,'Enable','on')
        return
end


% --- Executes on button press in button_loadlist.
function button_loadlist_Callback(hObject, eventdata, handles)
% hObject    handle to button_loadlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if nargin<4
        optionx=0;
end
if optionx==0
        [listname, lispath] = uigetfile({  '*.txt','Text File (*.txt)'; ...
                '*.*',  'All Files (*.*)'}, ...
                'Select an edited list', ...
                'MultiSelect', 'off');
        
        if isequal(listname,0)
                disp('User selected Cancel')
                return
        else
                fullname = fullfile(lispath, listname);
                disp(['For MVPCset list user selected  <a href="matlab: open(''' fullname ''')">' fullname '</a>'])
        end
else
        fullname = handles.mvpcset;
        if isnumeric(fullname)
                fullname = '';
        end
end
try
        fid_list = fopen( fullname );
        formcell = textscan(fid_list, '%[^\n]','CommentStyle','#', 'whitespace', ''); % JLC.05/12/15
catch
        fprintf('WARNING: %s was not found or is corrupted\n', fullname)
        return
end

lista = formcell{:};
% extra line forward
lista   = cat(1, lista, {'new mvpcset'});
lentext = length(lista);
fclose(fid_list);

if lentext>1
        set(handles.listbox_mvpcnames,'String',lista);
        set(handles.edit_filelist,'String',fullname);
        handles.listname = fullname;
        set(handles.button_savelist, 'Enable','on')
        
        % Update handles structure
        guidata(hObject, handles);
else
        msgboxText =  'This list is empty!';
        title = 'ERPLAB: mvpcaveragerGUI inputs';
        errorfound(msgboxText, title);
        handles.listname = [];
        set(handles.button_savelist, 'Enable','off')
        
        % Update handles structure
        guidata(hObject, handles);
end
set(handles.listbox_mvpcnames,'String',lista);


function edit_filelist_Callback(hObject, eventdata, handles)
% hObject    handle to edit_filelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_filelist as text
%        str2double(get(hObject,'String')) returns contents of edit_filelist as a double


% --- Executes during object creation, after setting all properties.
function edit_filelist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_filelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_warning.
function checkbox_warning_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_warning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_warning
