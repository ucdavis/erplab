%
% Author: Javier Lopez-Calderon & Steven Luck
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

function varargout = grandaveragerGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @grandaveragerGUI_OpeningFcn, ...
        'gui_OutputFcn',  @grandaveragerGUI_OutputFcn, ...
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
function grandaveragerGUI_OpeningFcn(hObject, eventdata, handles, varargin)
        
handles.output   = [];
handles.indxline = 1;

try        
        %       optioni  = answer{1}; %1 means from a filelist, 0 means from erpsets menu
        %       erpset   = answer{2};
        %       artcrite = answer{3}; % max percentage of rej to be included in the gaverage
        %       wavg     = answer{4}; % 0;1
        %       stderror    = answer{5}; % 0;1
        
        def = varargin{1};
        actualnset = def{1}; % number of loaded erpsets at erpset menu
        optioni    = def{2};   % datasets to average
        erpset     = def{3};
        artcrite   = def{4};
        
        %
        % Weighted average option. 1= yes, 0=no
        %
        wavg     = def{5};        
        excnullbin  = def{6};
        
        %
        % Standard deviation option. 1= yes, 0=no
        %
        stderror    = def{7};
catch
        actualnset  = 0;
        optioni     = 1;
        erpset      = '';
        artcrite    = 100;
        wavg        = 0;
        excnullbin  = 1;
        stderror    = 1;
end
if ~isempty(erpset)
        if ischar(erpset)
                listname = erpset;
        else
                listname = [];
        end
else
        listname = [];
end

helpbutton;
handles.fulltext = [];
handles.actualnset = actualnset;
handles.listname = listname;
% handles = painterplab(handles);
handles.erpset = erpset;

if optioni==0 && actualnset>0  && isnumeric(erpset)
        erps = erpset(erpset<=actualnset);
        if isempty(erps)
                erps = 1:actualnset;
        end
        set(handles.radiobutton_erpset, 'Value', 1);
        set(handles.radiobutton_erpset, 'Enable', 'on');
        set(handles.edit_erpset, 'String', vect2colon(erps, 'Delimiter', 'off', 'Repeat', 'off'));
        set(handles.radiobutton_folders, 'Value', 0);
        set(handles.listbox_erpnames, 'Enable', 'off');
        set(handles.pushbutton_adderpset, 'Enable', 'off');
        set(handles.pushbutton_delerpset, 'Enable', 'off');
        set(handles.button_loadlist, 'Enable', 'off');
        set(handles.button_savelist, 'Enable', 'off');
        set(handles.button_savelistas, 'Enable', 'off');
        set(handles.button_clearfile, 'Enable', 'off');
elseif optioni==0 && actualnset>0  && ~isnumeric(erpset)
        set(handles.radiobutton_erpset, 'Value', 1);
        set(handles.radiobutton_erpset, 'Enable', 'on');
        set(handles.edit_erpset, 'String', vect2colon(1:actualnset, 'Delimiter', 'off'));
        set(handles.radiobutton_folders, 'Value', 0);
        set(handles.listbox_erpnames, 'Enable', 'off');
        set(handles.pushbutton_adderpset, 'Enable', 'off');
        set(handles.pushbutton_delerpset, 'Enable', 'off');
        set(handles.button_loadlist, 'Enable', 'off');
        set(handles.button_savelist, 'Enable', 'off');
        set(handles.button_savelistas, 'Enable', 'off');
        set(handles.button_clearfile, 'Enable', 'off');
elseif optioni>=0 && actualnset==0  && isnumeric(erpset)
        set(handles.edit_erpset, 'String', 'no erpset found');
        set(handles.edit_erpset, 'Enable', 'off');
        set(handles.radiobutton_erpset, 'Value', 0);
        set(handles.radiobutton_erpset, 'Enable', 'off');
        set(handles.radiobutton_folders, 'Value', 1);
        set(handles.listbox_erpnames, 'String', {'new erpset'});
elseif optioni==0 && actualnset==0  && ~isnumeric(erpset)
        set(handles.edit_erpset, 'String', 'no erpset found');
        set(handles.edit_erpset, 'Enable', 'off');
        set(handles.radiobutton_erpset, 'Value', 0);
        set(handles.radiobutton_erpset, 'Enable', 'off');
        set(handles.radiobutton_folders, 'Value', 1);
        set(handles.listbox_erpnames, 'String', {'new erpset'});
elseif optioni==1 && actualnset>=0 && ~isnumeric(erpset)
        set(handles.edit_erpset, 'String', 'no erpset found');
        set(handles.edit_erpset, 'Enable', 'off');
        set(handles.radiobutton_erpset, 'Value', 0);
        set(handles.radiobutton_erpset, 'Enable', 'on');
        set(handles.edit_erpset, 'String', vect2colon(1:actualnset, 'Delimiter', 'off'));
        
        set(handles.radiobutton_folders, 'Value', 1);
        if ~isempty(erpset)
                button_loadlist_Callback(hObject, eventdata, handles, 1)
                %listname = erpset;
        else
                set(handles.listbox_erpnames, 'String', {'new erpset'});
        end
else
        error('no entiendo esta combinacion :(')
end

%label1 = '<HTML><center>Use weighted average';
%label2 = '<HTML><center>based on number of trials';
%set(handles.checkbox_wavg, 'string',[label1 '<br>' label2]);
set(handles.checkbox_SEM, 'Value', stderror); %
if wavg
        set(handles.checkbox_wavg, 'Value', wavg); % weighted average disable by default
        set(handles.checkbox_EXCNULLBIN, 'Value', 0)
        set(handles.checkbox_EXCNULLBIN, 'Enable', 'off')
else
        set(handles.checkbox_EXCNULLBIN, 'Value', excnullbin)
end
if isempty(artcrite)
        set(handles.edit_maxMART, 'String', '');
        set(handles.edit_maxMART, 'Enable', 'off');
        set(handles.checkbox_MERT, 'Value', 0);
else
        if artcrite==100
                set(handles.edit_maxMART, 'String', '');
                set(handles.edit_maxMART, 'Enable', 'off');
                set(handles.checkbox_MERT, 'Value', 0);
        else
                set(handles.edit_maxMART, 'String', num2str(artcrite)); %
                set(handles.checkbox_MERT, 'Value', 1);
        end
end

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   GRAND AVERAGER GUI'])

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

% UIWAIT makes grandaveragerGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

%--------------------------------------------------------------------------
function varargout = grandaveragerGUI_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

%--------------------------------------------------------------------------
function edit_erpset_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_erpset_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_help_Callback(hObject, eventdata, handles)
% doc pop_gaverager
web('https://github.com/lucklab/erplab/wiki/Averaging-Across-ERPSETS-_-Creating-Grand-Averages', '-browser');

%--------------------------------------------------------------------------
function pushbutton_GO_Callback(hObject, eventdata, handles)


%         optioni    = answer{1}; %1 means from a filelist, 0 means from erpsets menu
%         erpset     = answer{2};
%         artcrite   = answer{3}; % max percentage of rej to be included in the gaverage
%         wavg       = answer{4}; % 0;1
%         excnullbin = answer{5}; % 0;1
%         stderror   = answer{6}; % 0;1
%         jk         = answer{7}; % 0;1
%         jkerpname  = answer{8}; % erpname for JK grand averages
%         jkfilename = answer{9}; % filename for JK grand averages
%         def = {actualnset, optioni, erpset, artcrite, wavg, excnullbin, stderror};

wavg       = get(handles.checkbox_wavg,'Value');% for weighted average    1=>yes
stderror   = get(handles.checkbox_SEM,'Value'); % for standard error  1=>yes
excnullbin = get(handles.checkbox_EXCNULLBIN,'Value'); % for standard error  1=>yes

%
% Artifact detection threshold
%
if get(handles.checkbox_MERT, 'Value')
        artcrite = str2num(get(handles.edit_maxMART,'String'));
else
        artcrite = 100;
end
if isempty(artcrite)
        artcrite = 100; % means allow all erpset to be grand averaged
end
if artcrite<0 || artcrite>100
        msgboxText =  ['Invalid artifact detection proportion.\n'...
                'Please, enter a number between 0 and 100.'];
        title = 'ERPLAB: geterpvaluesGUI() -> missing input';
        errorfound(sprintf(msgboxText), title);
        return
end

%
% Jackknife
%
jk = get(handles.checkbox_JK,'Value'); % for Jackknifing  1=>yes

if jk      
      answer = savemyerpGUI; % open GUI to save erpset
      if isempty(answer)
            disp('User selected Cancel')
            return
      end
      jkerpname  = answer{1};
      if isempty(jkerpname)
            disp('User selected Cancel') % change
            return
      end
      
      jkfilename = answer{2};
      overw      = answer{3}; % over write in memory? 1=yes    
      
      if ~isempty(jkfilename) && overw==0
            [jkpath, jkname, ext] = fileparts(jkfilename);
            Files   = dir(jkpath);
            fnames  = {Files.name};
            detname = regexpi(fnames, jkname, 'match');
            detname = char([detname{:}]);    
            
            if ~isempty(detname)
                  BackERPLABcolor = [1 0.9 0.3];    % yellow
                  question = ['The filename file already exists.\n'...
                              'Do you want to overwrite it?'];
                  title = 'File already exists';
                  oldcolor = get(0,'DefaultUicontrolBackgroundColor');
                  set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
                  button = questdlg(sprintf(question), title,'No','Yes', 'No');
                  set(0,'DefaultUicontrolBackgroundColor',oldcolor)
                  
                  if ~strcmpi(button,'Yes')
                        return
                  end
            end            
      end
      if isempty(jkfilename)
            jkfilename = '';      
      end     
else
      jkerpname  = '';
      jkfilename = '';
end

%
% ERPsets
%
if get(handles.radiobutton_erpset, 'Value')
        erpset = str2num(char(get(handles.edit_erpset, 'String')));
        
        if length(erpset)<2
                msgboxText =  'You have to specify 2 erpsets, at least!';
                title = 'ERPLAB: geterpvaluesGUI() -> missing input';
                errorfound(msgboxText, title);
                return
        end
        if min(erpset)<1 || max(erpset)>handles.actualnset
                msgboxText =  'Unexisting erpset index(es)';
                title = 'ERPLAB: grandaveragerGUI() -> wrong input';
                errorfound(msgboxText, title);
                return
        else
                handles.output = {0, erpset, artcrite, wavg, excnullbin, stderror, jk, jkerpname, jkfilename};
        end
else
        erpset = cellstr(get(handles.listbox_erpnames, 'String'));
        nline  = length(erpset);
        
        if nline<3 % 'new_erpset' line is being included
                msgboxText =  'You have to specify 2 erpsets, at least!';
                title = 'ERPLAB: geterpvaluesGUI() -> missing input';
                errorfound(msgboxText, title);
                return
        end
        
        listname = handles.listname;
        
        if isempty(listname) && nline>1                
                BackERPLABcolor = [1 0.9 0.3];    % yellow
                question = ['You have not saved your list.\n'...
                        'What would you like to do?'];
                title = 'Save List of ERPsets';
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
                        fulltext = char(get(handles.listbox_erpnames,'String'));
                        listname = char(strtrim(get(handles.edit_filelist,'String')));                        
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
        handles.output = {1, listname, artcrite, wavg, excnullbin, stderror, jk, jkerpname, jkfilename};
end

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function radiobutton_folders_Callback(hObject, eventdata, handles)

if get(hObject, 'Value')
        set(handles.radiobutton_folders, 'Value', 1);
        set(handles.radiobutton_folders, 'Enable', 'on');
        set(handles.listbox_erpnames, 'Enable', 'on');
        set(handles.pushbutton_adderpset, 'Enable', 'on');
        set(handles.pushbutton_delerpset, 'Enable', 'on');
        set(handles.button_loadlist, 'Enable', 'on');
        set(handles.button_savelist, 'Enable', 'on');
        set(handles.button_savelistas, 'Enable', 'on');
        set(handles.button_clearfile, 'Enable', 'on');
        set(handles.radiobutton_erpset, 'Value', 0);
        
        if handles.actualnset==0
                set(handles.radiobutton_erpset, 'Enable', 'off');
        else
                set(handles.radiobutton_erpset, 'Enable', 'on');
        end
        if isempty(get(handles.listbox_erpnames,'String'))
                set(handles.listbox_erpnames,'String',{'new erpset'});
        end
        
        set(handles.edit_erpset, 'Enable', 'off');
        set(handles.edit_erpset, 'String', '');
else
        set(handles.radiobutton_folders, 'Value', 1);
end

%--------------------------------------------------------------------------
function radiobutton_erpset_Callback(hObject, eventdata, handles)

if get(hObject, 'Value')
        actualnset = handles.actualnset;
        set(handles.radiobutton_erpset, 'Value', 1);
        set(handles.radiobutton_erpset, 'Enable', 'on');
        set(handles.edit_erpset, 'Enable', 'on');
        set(handles.edit_erpset, 'String', vect2colon(1:actualnset, 'Delimiter', 'off'));
        set(handles.radiobutton_folders, 'Value', 0);
        set(handles.listbox_erpnames, 'Enable', 'off');
        set(handles.pushbutton_adderpset, 'Enable', 'off');
        set(handles.pushbutton_delerpset, 'Enable', 'off');
        set(handles.button_loadlist, 'Enable', 'off');
        set(handles.button_savelist, 'Enable', 'off');
        set(handles.button_savelistas, 'Enable', 'off');
        set(handles.button_clearfile, 'Enable', 'off');
else
        set(handles.radiobutton_erpset, 'Value', 1);
end

%--------------------------------------------------------------------------
function listbox_erpnames_Callback(hObject, eventdata, handles)

fulltext  = get(handles.listbox_erpnames, 'String');
indxline  = length(fulltext);
currlineindx = get(handles.listbox_erpnames, 'Value');

%--------------------------------------------------------------------------
function listbox_erpnames_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_adderpset_Callback(hObject, eventdata, handles)

[erpfname, erppathname] = uigetfile({  '*.erp','ERPLAB-files (*.erp)'; ...
        '*.mat','Matlab (*.mat)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Select an edited file', ...
        'MultiSelect', 'on');

if isequal(erpfname,0)
        disp('User selected Cancel')
        return
else
        if ~iscell(erpfname)
                erpfname = {erpfname};
        end
        
        nerpn = length(erpfname);
        
        for i=1:nerpn
                newline  = fullfile(erppathname, erpfname{i});
                currline = get(handles.listbox_erpnames, 'Value');
                fulltext = get(handles.listbox_erpnames, 'String');
                indxline = length(fulltext);
                
                if currline==indxline
                        % extra line forward
                        fulltext  = cat(1, fulltext, {'new erpset'});
                        set(handles.listbox_erpnames, 'Value', currline+1)
                else
                        set(handles.listbox_erpnames, 'Value', currline)
                        resto = fulltext(currline:indxline);
                        fulltext  = cat(1, fulltext, {'new erpset'});
                        set(handles.listbox_erpnames, 'Value', currline+1)
                        [fulltext{currline+1:indxline+1}] = resto{:};
                end
                
                fulltext{currline} = newline;
                set(handles.listbox_erpnames, 'String', fulltext)
        end
        
        indxline = length(fulltext);
        handles.indxline = indxline;
        handles.fulltext = fulltext;
        handles.listname = [];
        set(handles.edit_filelist,'String','');
        % Update handles structure
        guidata(hObject, handles);
end

%--------------------------------------------------------------------------
function pushbutton_delerpset_Callback(hObject, eventdata, handles)

fulltext = get(handles.listbox_erpnames, 'String');
indxline = length(fulltext);
fulltext = char(fulltext); % string matrix
currline = get(handles.listbox_erpnames, 'Value');

if currline>=1 && currline<indxline
        fulltext(currline,:) = [];
        fulltext = cellstr(fulltext); % cell string
        set(handles.listbox_erpnames, 'String', fulltext);
        listbox_erpnames_Callback(hObject, eventdata, handles)
        handles.fulltext = fulltext;
        indxline = length(fulltext);
        handles.listname = [];
        set(handles.edit_filelist,'String','');
        
        % Update handles structure
        guidata(hObject, handles);
end

%--------------------------------------------------------------------------
function checkbox_wavg_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.checkbox_EXCNULLBIN, 'Value', 0)
        set(handles.checkbox_EXCNULLBIN, 'Enable', 'off')
else
   set(handles.checkbox_EXCNULLBIN, 'Enable', 'on')     
end
        
%--------------------------------------------------------------------------
function checkbox_EXCNULLBIN_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)

handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function button_loadlist_Callback(hObject, eventdata, handles, optionx)
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
                disp(['For erpset list user selected  <a href="matlab: open(''' fullname ''')">' fullname '</a>'])
        end
else
        fullname = handles.erpset;
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
lista   = cat(1, lista, {'new erpset'});
lentext = length(lista);
fclose(fid_list);

if lentext>1
        set(handles.listbox_erpnames,'String',lista);
        set(handles.edit_filelist,'String',fullname);
        handles.listname = fullname;
        set(handles.button_savelist, 'Enable','on')
        
        % Update handles structure
        guidata(hObject, handles);
else
        msgboxText =  'This list is empty!';
        title = 'ERPLAB: geterpvaluesGUI inputs';
        errorfound(msgboxText, title);
        handles.listname = [];
        set(handles.button_savelist, 'Enable','off')
        
        % Update handles structure
        guidata(hObject, handles);
end
set(handles.listbox_erpnames,'String',lista);

%--------------------------------------------------------------------------
function button_savelistas_Callback(hObject, eventdata, handles)

fulltext = char(get(handles.listbox_erpnames,'String'));

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
        msgboxText =  'You have not specified any erpset!';
        title = 'ERPLAB: averager GUI few inputs';
        errorfound(msgboxText, title);
        set(handles.button_savelistas,'Enable','on')
        return
end

%--------------------------------------------------------------------------
function fullname = savelist(hObject, eventdata, handles)

fulltext  = char(strtrim(get(handles.listbox_erpnames,'String')));
pre_fname = char(strtrim(get(handles.edit_filelist,'String')));

%
% Save OUTPUT file
%
[filename, filepath, filterindex] = uiputfile({'*.txt';'*.dat';'*.*'},'Save erpset list as', pre_fname);

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
        disp(['For saving erpset list, user selected <a href="matlab: open(''' fullname ''')">' fullname '</a>'])
        fid_list   = fopen( fullname , 'w');
        
        for i=1:size(fulltext,1)-1
                fprintf(fid_list,'%s\n', fulltext(i,:));
        end        
        fclose(fid_list);
end

%--------------------------------------------------------------------------
function button_savelist_Callback(hObject, eventdata, handles)

fulltext = char(strtrim(get(handles.listbox_erpnames,'String')));

if length(fulltext)>1
        
        fullname = get(handles.edit_filelist, 'String');
        
        if ~strcmp(fullname,'')
                
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
        title = 'ERPLAB: chanoperGUI few inputs';
        errorfound(msgboxText, title);
        set(handles.button_savelistas,'Enable','on')
        return
end

%--------------------------------------------------------------------------
function button_clearfile_Callback(hObject, eventdata, handles)

set(handles.edit_filelist,'String','');
set(handles.button_savelist, 'Enable', 'off')
handles.listname = [];
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function edit_filelist_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function checkbox_JK_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function checkbox_MERT_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.edit_maxMART, 'Enable', 'on')
else
        set(handles.edit_maxMART, 'Enable', 'off')
end

%--------------------------------------------------------------------------
function edit_filelist_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function checkbox_SEM_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_maxMART_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_maxMART_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)

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
