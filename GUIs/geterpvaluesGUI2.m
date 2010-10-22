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

function varargout = geterpvaluesGUI2(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
      'gui_Singleton',  gui_Singleton, ...
      'gui_OpeningFcn', @geterpvaluesGUI2_OpeningFcn, ...
      'gui_OutputFcn',  @geterpvaluesGUI2_OutputFcn, ...
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
function geterpvaluesGUI2_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for geterpvaluesGUI2
handles.output   = [];
handles.indxline = 1;
handles.listname = [];
handles.owfp = 0;  % over write file permission

try
      ALLERP = varargin{1}; %evalin('base', 'ALLERP');
      
      if isstruct(ALLERP)
            handles.xmin  = ALLERP(1).xmin;
            handles.xmax  = ALLERP(1).xmax;
            handles.srate = ALLERP(1).srate;
            handles.nsets = length(ALLERP);
      else
            handles.xmin  = [];
            handles.xmax  = [];
            handles.srate = [];
            handles.nsets = [];
      end
catch
      ALLERP = [];
      handles.xmin  = [];
      handles.xmax  = [];
      handles.srate = [];
      handles.nsets = [];
end

try
      memoryinput = varargin{2};
      handles.memoryinput = memoryinput;
catch
      memoryinput = [];
      handles.memoryinput = memoryinput;
end

handles.ALLERP = ALLERP;

% Update handles structure
guidata(hObject, handles);

setall(hObject, eventdata, handles)

%
% Color GUI
%
handles = painterplab(handles);

%
% Set Measurement menu
%
set(handles.popupmenu_measurement, 'Backgroundcolor',[1 1 0.8])
set(handles.popupmenu_pol_amp, 'Backgroundcolor',[1 1 0.8])
set(handles.popupmenu_samp_amp, 'Backgroundcolor',[1 1 0.8])
set(handles.popupmenu_localop, 'Backgroundcolor',[1 1 0.8])
set(handles.popupmenu_bins, 'Backgroundcolor',[1 1 0.8])
set(handles.popupmenu_precision, 'Backgroundcolor',[1 1 0.8])
set(handles.popupmenu_channels, 'Backgroundcolor',[1 1 0.8])

drawnow

% UIWAIT makes geterpvaluesGUI2 wait for user response (see UIRESUME)
uiwait(handles.figure1);

%--------------------------------------------------------------------------
function varargout = geterpvaluesGUI2_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);
pause(0.5)

%--------------------------------------------------------------------------
function menupeakoff(hObject, eventdata, handles)

set(handles.popupmenu_pol_amp, 'Enable', 'off')
set(handles.text7, 'Enable', 'off')
set(handles.popupmenu_samp_amp, 'Enable', 'off')
set(handles.text_samp, 'Enable', 'off')
set(handles.text12, 'Enable', 'off')
set(handles.popupmenu_localop, 'Enable', 'off')

%--------------------------------------------------------------------------
function menupeakon(hObject, eventdata, handles)

set(handles.popupmenu_pol_amp, 'Enable', 'on')
set(handles.text7, 'Enable', 'on')
set(handles.popupmenu_samp_amp, 'Enable', 'on')
set(handles.text_samp, 'Enable', 'on')
set(handles.text12, 'Enable', 'on')
set(handles.popupmenu_localop, 'Enable', 'on')

%--------------------------------------------------------------------------
function edit_fname_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_fname_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function button_browse_Callback(hObject, eventdata, handles)

%
% Save OUTPUT file
%
prename = get(handles.edit_fname,'String');

if ispc
      [filename, filepath, filterindex] = uiputfile({'*.xls';'*.txt';'*.dat';'*.*'}, 'Save Output file as', prename);
else
      [filename, filepath, filterindex] = uiputfile({'*.txt';'*.dat';'*.*'}, 'Save Output file as', prename);
end

if isequal(filename,0)
      disp('User selected Cancel')
      handles.owfp = 0;  % over write file permission
      guidata(hObject, handles);
      return
else
      
      [px, fname, ext, versn] = fileparts(filename);
      
      if ispc
            if filterindex==2 || filterindex==4
                  ext2   = '.txt';
            elseif filterindex==3
                  ext2   = '.dat';
            else
                  ext2   = '.xls';
            end
      else
            if filterindex==1 || filterindex==3
                  ext2   = '.txt';
            else
                  ext2   = '.dat';
            end
      end
      
      fname = [ fname ext2];
      fullname = fullfile(filepath, fname);
      set(handles.edit_fname,'String', fullname);
      disp(['To Save Output file, user selected ', fullname])
      
      handle.fname     = fname;
      handle.pathname  = filepath;
      handles.owfp     = 1;  % over write file permission
      set(handles.edit_fname,'String', fullfile(filepath, fname));
      
      % Update handles structure
      guidata(hObject, handles);
      
end

%--------------------------------------------------------------------------
function edit_latency_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_latency_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)

handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);

%--------------------------------------------------------------------------
function pushbutton_run_Callback(hObject, eventdata, handles)

if get(handles.radiobutton_erpset, 'Value')
      
      erpset = str2num(char(get(handles.edit_erpset, 'String')));
      
      if isempty(erpset) || min(erpset)<1 || max(erpset)>handles.nsets
            msgboxText =  'Unrecognizable erpset index(es)';
            title = 'ERPLAB: geterpvaluesGUI() -> wrong input';
            errorfound(msgboxText, title);
            return
      else
            foption = 0; %from erpsets
      end
else
      erpset = get(handles.listbox_erpnames, 'String');
      nline  = length(erpset);
      
      if nline==1
            msgboxText =  'You have to specify at least one erpset!';
            title = 'ERPLAB: geterpvaluesGUI() -> missing input';
            errorfound(msgboxText, title);
            return
      end
      
      listname = handles.listname;
      
      if isempty(listname) && nline>1
            
            BackERPLABcolor = [1 0.9 0.3];    % yellow
            question{1} = 'You have not saved your list.';
            question{2} = 'What would you like to do?';
            title       = 'Save List of ERPsets';
            oldcolor    = get(0,'DefaultUicontrolBackgroundColor');
            set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
            button      = questdlg(question, title,'Save and Continue','Save As', 'Cancel','Save and Continue');
            set(0,'DefaultUicontrolBackgroundColor',oldcolor)
            
            if strcmpi(button,'Save As')
                  fullname = savelist(hObject, eventdata, handles);
                  listname = fullname;
                  
                  set(handles.edit_filelist,'String', listname);
                  
                  handles.listname = listname;
                  % Update handles structure
                  guidata(hObject, handles);
                  return
                  
                  %if isempty(listname)
                  %        return
                  %end
            elseif strcmpi(button,'Save and Continue')
                  
                  fulltext = char(get(handles.listbox_erpnames,'String'));
                  listname = char(strtrim(get(handles.edit_filelist,'String')));
                  
                  if isempty(listname)
                        fullname = savelist(hObject, eventdata, handles);
                        listname = fullname;
                        set(handles.edit_filelist,'String', listname);
                        
                        %if isempty(listname)
                        %        return
                        %end
                  else
                        fid_list = fopen( listname , 'w');
                        for i=1:size(fulltext,1)-1
                              fprintf(fid_list,'%s\n', fulltext(i,:));
                        end
                        fclose(fid_list);
                  end
                  
            elseif strcmpi(button,'Cancel') || strcmpi(button,'')
                  handles.output   = [];
                  handles.listname = [];
                  % Update handles structure
                  guidata(hObject, handles);
                  return
            end
      end
      
      erpset = listname;
      foption = 1; % from list
end

xmin  = handles.xmin;
xmax  = handles.xmax;
fname = strtrim(get(handles.edit_fname, 'String'));

%
% Send to workspace
%
send2ws = get(handles.checkbox_send2ws, 'Value'); % 0:no; 1:yes
owfp    = handles.owfp;  % over write file permission
appendfile = 0;

if isempty(fname) && ~send2ws
      msgboxText =  'You have not yet written a file name for your outputs!';
      title = 'ERPLAB: geterpvaluesGUI() -> no file name';
      errorfound(msgboxText, title);
      return
elseif isempty(fname) && send2ws
      fname = 'no_save.no_save';
else
      [pu, fnameu, extu, versn] = fileparts(fname);
      if strcmp(extu,'')
            extu   = '.txt';
      end
      
      fname = fullfile(pu,[fnameu extu]);
      
      if exist(fname, 'file')~=0 && owfp==0
            question{1} = [fname ' already exists!'];
            question{2} = 'What would you like to do?';
            title       = 'ERPLAB: Overwriting Confirmation';
            %button      = askquest(question, title);
            
            BackERPLABcolor = [1 0.9 0.3];    % yellow
            %question{1} = 'You have not saved your list.';
            %question{2} = 'What would you like to do?';
            %title       = 'Save List of ERPsets';
            oldcolor    = get(0,'DefaultUicontrolBackgroundColor');
            set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
            button      = questdlg(question, title,'Append','Overwrite', 'Cancel','Append');
            set(0,'DefaultUicontrolBackgroundColor',oldcolor)
            
            if strcmpi(button, 'Append')
                  appendfile = 1;
            elseif strcmpi(button, 'Overwrite')
                  appendfile = 0;
            else
                  return
            end
      end
end

binArraystr  = get(handles.edit_bins, 'String');
chanArraystr = get(handles.edit_channels, 'String');
latestr      = get(handles.edit_latency, 'String');

if ~strcmp(chanArraystr, '') && ~isempty(chanArraystr) && ...
            ~strcmp(fname, '') && ~isempty(fname) && ...
            ~strcmp(latestr, '') && ~isempty(latestr) && ...
            ~strcmp(binArraystr, '') && ~isempty(binArraystr)
      
      binArray   = str2num(binArraystr);
      chanArray  = str2num(chanArraystr);
      late       = str2num(latestr);
      nlate      = length(late);
      
      if length(late)==2
            if late(1)>=late(2)
                  msgboxText{1} =  'For latency range, lower time limit must be on the left. ';
                  msgboxText{2} =  'Additionally, lower latency limit must be at least 1/sample rate seconds lesser than the higher one.';
                  title = 'ERPLAB: Bin-based epoch inputs';
                  found(msgboxText, title)
                  return
            end
      end
      
      polpeak = [];
      sampeak = [];
      coi     = 1;
      localop = 0;
      
      measure_option = get(handles.popupmenu_measurement, 'Value');
      
      switch measure_option
            case 1
                  if nlate==2
                        colorold = get(handles.edit_latency, 'BackgroundColor');
                        set(handles.edit_latency, 'BackgroundColor', [1 0 0]);
                        pause(0.5)
                        set(handles.edit_latency, 'BackgroundColor', colorold);
                        beep
                        return
                  end
                  
                  moption = 'instabl';
                  fprintf('\nInstantaneous amplitude measurement in progress...\n');
            case 2
                  if nlate==1
                        colorold = get(handles.edit_latency, 'BackgroundColor');
                        set(handles.edit_latency, 'BackgroundColor', [1 0 0]);
                        pause(0.5)
                        set(handles.edit_latency, 'BackgroundColor', colorold);
                        beep
                        return
                  end
                  
                  moption = 'peakampbl';
                  polpeak = 2-get(handles.popupmenu_pol_amp,'Value');
                  sampeak = get(handles.popupmenu_samp_amp,'Value') - 1;
                  localop = 2-get(handles.popupmenu_localop,'Value');
                  fprintf('\nLocal peak measurement in progress...\n');
            case 3
                  if nlate==1
                        colorold = get(handles.edit_latency, 'BackgroundColor');
                        set(handles.edit_latency, 'BackgroundColor', [1 0 0]);
                        pause(0.5)
                        set(handles.edit_latency, 'BackgroundColor', colorold);
                        beep
                        return
                  end
                  
                  moption = 'peaklatbl';
                  polpeak = 2-get(handles.popupmenu_pol_amp,'Value');
                  sampeak = get(handles.popupmenu_samp_amp,'Value') - 1;
                  localop = 2-get(handles.popupmenu_localop,'Value');
                  fprintf('\nLocal peak latency measurement in progress...\n');
            case 4
                  if nlate==1
                        colorold = get(handles.edit_latency, 'BackgroundColor');
                        set(handles.edit_latency, 'BackgroundColor', [1 0 0]);
                        pause(0.5)
                        set(handles.edit_latency, 'BackgroundColor', colorold);
                        beep
                        return
                  end
                  
                  moption = 'meanbl';
                  fprintf('\nMean amplitude measurement in progress...\n');
            case 5
                  if nlate==1
                        colorold = get(handles.edit_latency, 'BackgroundColor');
                        set(handles.edit_latency, 'BackgroundColor', [1 0 0]);
                        pause(0.5)
                        set(handles.edit_latency, 'BackgroundColor', colorold);
                        beep
                        return
                  end
                  
                  moption = 'area';
                  fprintf('\nArea measurement in progress...\n');
            case 6
                  if nlate==1
                        colorold = get(handles.edit_latency, 'BackgroundColor');
                        set(handles.edit_latency, 'BackgroundColor', [1 0 0]);
                        pause(0.5)
                        set(handles.edit_latency, 'BackgroundColor', colorold);
                        beep
                        return
                  end                  
                  moption = 'areaz';
      end
      
      %
      % Baseline range
      %
      if get(handles.radiobutton_none, 'Value')
            blc = 'none';
      end
      if get(handles.radiobutton_pre, 'Value')
            blc = 'pre';
      end
      if get(handles.radiobutton_post, 'Value')
            blc = 'post';
      end
      if get(handles.radiobutton_all, 'Value')
            blc = 'all';
      end
      if get(handles.radiobutton_custom, 'Value')
            
            blcnumx = str2num(get(handles.edit_custom,'String'));
            
            if isempty(blcnumx) %char
                  msgboxText{1} =  'Invalid Baseline range!';
                  msgboxText{2} =  'Please enter a numeric range';
                  title = 'ERPLAB: geterpvaluesGUI() -> invalid input';
                  errorfound(msgboxText, title);
                  return
            else %num
                  
                  blcnum = blcnumx/1000;               % from msec to secs  03-28-2009
                  
                  %
                  % Check & fix baseline range
                  %
                  if blcnum(1)<xmin
                        blcnum(1) = xmin;
                  end
                  if blcnum(2)>xmax
                        blcnum(2) = xmax;
                  end
                  
                  blc = blcnum*1000;  % sec to msec
            end
      end
      
      %
      % Format output
      %
      if get(handles.radiobutton_f0_1erp_per_line,'Value')
            foutput = 0; % 1 erpset per line
      else
            foutput = 1; % 1 measurement per line
      end
      
      dig   = get(handles.popupmenu_precision, 'Value');
      binlabop = get(handles.checkbox_binlabel,'Value'); % bin label option for table
      outstr = {foption, erpset, fname, late, binArray, chanArray, moption,...
            coi, dig, blc, binlabop, polpeak, sampeak, localop, send2ws, appendfile, foutput};
      handles.output = outstr;
      
      % Update handles structure
      guidata(hObject, handles);
      
      uiresume(handles.figure1);
      %         end
else
      msgboxText =  'Please fill-up required fields';
      title = 'ERPLAB: geterpvaluesGUI() -> missing information';
      errorfound(msgboxText, title);
      return
end

%--------------------------------------------------------------------------
function edit_channels_Callback(hObject, eventdata, handles)

channnums =  str2num(get(handles.edit_channels,'String'));

if ~isempty(channnums)
      chanstr = get(handles.popupmenu_channels, 'String');
      
      if max(channnums)<=length(chanstr)
            set(handles.popupmenu_channels, 'Value',max(channnums));
      end
end

%--------------------------------------------------------------------------
function edit_channels_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_channels_Callback(hObject, eventdata, handles)

numch   = get(hObject, 'Value');

nums = get(handles.edit_channels, 'String');
nums = [nums ' ' num2str(numch)];
set(handles.edit_channels, 'String', nums);

%--------------------------------------------------------------------------
function popupmenu_channels_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
% function checkbox_catch_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_precision_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_precision_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function figure1_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
      % The GUI is still in UIWAIT, us UIRESUME
      uiresume(handles.figure1);
else
      % The GUI is no longer waiting, just close it
      delete(handles.figure1);
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
function button_adderpset_Callback(hObject, eventdata, handles)

[erpfname, erppathname] = uigetfile({  '*.erp','ERPLAB-files (*.erp)'; ...
      '*.mat','Matlab (*.mat)'; ...
      '*.*',  'All Files (*.*)'}, ...
      'Select an edited file', ...
      'MultiSelect', 'on');

if isequal(erpfname,0)
      disp('User selected Cancel')
      return
else
      try            
            %
            % test current directory
            %
            changecd(erppathname)
            
            if ~iscell(erpfname)
                  erpfname = {erpfname};
            end
            
            nerpn = length(erpfname);
            
            for i=1:nerpn
                  newline  = fullfile(erppathname, erpfname{i});
                  currline = get(handles.listbox_erpnames, 'Value');
                  fulltext = get(handles.listbox_erpnames, 'String');
                  
                  indxline = length(fulltext);
                  
                  if i==1 && length(fulltext)-1==0  % put this one on the list
                        ERP1 = load(newline, '-mat');
                        ERP = ERP1.ERP;
                        
                        if ~iserpstruct(ERP)
                              error('')
                        end
                        handles.srate = ERP.srate;
                        %
                        % Prepare List of current Channels and bins
                        %
                        preparelists(ERP, hObject, eventdata, handles);
                  end
                  
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
            
            handles.listname = [];
            indxline = length(fulltext);
            handles.indxline = indxline;
            handles.fulltext = fulltext;
            set(handles.button_savelistas, 'Enable','on')
            set(handles.edit_filelist,'String','');
            
            % Update handles structure
            guidata(hObject, handles);
      catch
            msgboxText =  'A file you are attempting to load is not an ERPset!';
            title = 'ERPLAB: geterpvaluesGUI2 inputs';
            errorfound(msgboxText, title);
            handles.listname = [];
            set(handles.button_savelist, 'Enable','off')
            
            % Update handles structure
            guidata(hObject, handles);
      end
      
end

%--------------------------------------------------------------------------
function button_delerpset_Callback(hObject, eventdata, handles)

fulltext = get(handles.listbox_erpnames, 'String');
indxline = length(fulltext);
fulltext = char(fulltext); % string matrix
currline = get(handles.listbox_erpnames, 'Value');

if currline>=1 && currline<indxline
      
      fulltext(currline,:) = [];
      fulltext = cellstr(fulltext); % cell string
      
      if length(fulltext)>1 % put this one first on the list
            newline = fulltext{1};
            ERP1 = load(newline, '-mat');
            ERP = ERP1.ERP;
            %
            % Prepare List of current Channels and bins
            %
            preparelists(ERP, hObject, eventdata, handles);
      else
            preparelists([], hObject, eventdata, handles);
      end
      
      set(handles.listbox_erpnames, 'String', fulltext);
      listbox_erpnames_Callback(hObject, eventdata, handles)
      handles.fulltext = fulltext;
      indxline = length(fulltext);
      handles.listname = [];
      set(handles.edit_filelist,'String','');
      % Update handles structure
      guidata(hObject, handles);
else
      set(handles.button_savelistas, 'Enable','off')
end

%--------------------------------------------------------------------------
function edit_bins_Callback(hObject, eventdata, handles)

binnums =  str2num(get(handles.edit_bins,'String'));

if ~isempty(binnums)
      binstr = get(handles.popupmenu_bins, 'String');
      
      if max(binnums)<=length(binstr)
            set(handles.popupmenu_bins, 'Value',max(binnums));
      end
end

%--------------------------------------------------------------------------
function edit_bins_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_bins_Callback(hObject, eventdata, handles)

numbin   = get(hObject, 'Value');
nums = get(handles.edit_bins, 'String');
nums = [nums ' ' num2str(numbin)];
set(handles.edit_bins, 'String', nums);

%--------------------------------------------------------------------------
function popupmenu_bins_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_custom_Callback(hObject, eventdata, handles)

blcstr = get(handles.edit_custom,'String');
blc = str2num(blcstr);

if isempty(blc)
      msgboxText =  'Invalid baseline! You have to enter 2 numeric values, in ms.';
      title = 'ERPLAB: geterpvalues GUI invalid baseline input';
      errorfound(msgboxText, title);
      return
else
      if size(blc,1)>1 || size(blc,2)~=2
            msgboxText =  'Invalid baseline! You have to enter 2 numeric values, in ms.';
            title = 'ERPLAB: geterpvalues GUI invalid baseline input';
            errorfound(msgboxText, title);
            return
      end
end

%--------------------------------------------------------------------------
function edit_custom_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

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
      msgboxText =  'You have not specified any ERPset!';
      title = 'ERPLAB: averager GUI few inputs';
      errorfound(msgboxText, title);
      set(handles.button_savelistas,'Enable','on')
      return
end

%--------------------------------------------------------------------------
function button_loadlist_Callback(hObject, eventdata, handles)

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

fid_list   = fopen( fullname );
formcell = textscan(fid_list, '%[^\n]','CommentStyle','#', 'whitespace', '');
lista = formcell{:};

% extra line forward
lista   = cat(1, lista, {'new erpset'});
lentext = length(lista);
fclose(fid_list);

if lentext>1
      %         try
      filereadin = strtrim(lista{1});
      ERP1 = load(filereadin, '-mat');
      ERP = ERP1.ERP;
      
      if ~iserpstruct(ERP)
            error('')
      end
      
      handles.srate = ERP.srate;
      %
      % Prepare List of current Channels and bins
      %
      preparelists(ERP, hObject, eventdata, handles);
      
      set(handles.listbox_erpnames,'String',lista);
      set(handles.edit_filelist,'String',fullname);
      listname = fullname;
      handles.listname = listname;
      set(handles.button_savelistas, 'Enable','on')
      
      % Update handles structure
      guidata(hObject, handles);
      %         catch
      %                 msgboxText =  'This list is anything but an ERPset list!';
      %                 title = 'ERPLAB: geterpvaluesGUI inputs';
      %                 errorfound(msgboxText, title)
      %                 handles.listname = [];
      %                 set(handles.button_savelist, 'Enable','off')
      %
      %                 % Update handles structure
      %                 guidata(hObject, handles);
      %         end
else
      msgboxText =  'This list is empty!';
      title = 'ERPLAB: geterpvaluesGUI inputs';
      errorfound(msgboxText, title);
      handles.listname = [];
      set(handles.button_savelist, 'Enable','off')
      
      % Update handles structure
      guidata(hObject, handles);
end

%--------------------------------------------------------------------------
function xxx_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_erpset_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_erpset_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function radiobutton_erpset_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
      set(handles.edit_erpset,'Enable','on')
      set(handles.radiobutton_folders,'Value',0)
      set(handles.listbox_erpnames,'Enable','off')
      set(handles.button_adderpset,'Enable','off')
      set(handles.button_delerpset,'Enable','off')
      set(handles.button_savelist,'Enable','off')
      set(handles.button_clearfile,'Enable','off')
      set(handles.button_savelistas,'Enable','off')
      set(handles.button_loadlist,'Enable','off')
      set(handles.edit_filelist,'Enable','off')
      set(handles.pushbutton_flush,'Enable','off')
else
      set(hObject,'Value',1)
end

%--------------------------------------------------------------------------
function radiobutton_folders_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
      set(handles.radiobutton_erpset,'Value',0)
      set(handles.edit_erpset,'Enable','off')
      set(handles.listbox_erpnames,'Enable','on')
      set(handles.button_adderpset,'Enable','on')
      set(handles.button_delerpset,'Enable','on')
      
      if ~isempty(get(handles.edit_filelist,'String'))
            set(handles.button_savelist,'Enable','on')
            set(handles.button_clearfile,'Enable','on')
      end
      
      set(handles.button_savelistas,'Enable','on')
      set(handles.button_loadlist,'Enable','on')
      set(handles.edit_filelist,'Enable','on')
      set(handles.pushbutton_flush,'Enable','on')
else
      set(hObject,'Value',1)
end

%--------------------------------------------------------------------------
function fullname = savelist(hObject, eventdata, handles)

fullname = '';
fulltext = char(get(handles.listbox_erpnames,'String'));
%
% Save OUTPUT file
%
[filename, filepath, filterindex] = uiputfile({'*.txt';'*.dat';'*.*'},'Save erpset list as');

if isequal(filename,0)
      disp('User selected Cancel')
      return
else
      
      [px, fname, ext, versn] = fileparts(filename);
      
      if strcmp(ext,'')            
            if filterindex==1 || filterindex==3
                  ext   = '.txt';
            else
                  ext   = '.dat';
            end
      end
      
      fname = [ fname ext];
      fullname = fullfile(filepath, fname);
      disp(['To Save erpset list, user selected ', fullname])
      
      fid_list   = fopen( fullname , 'w');
      
      for i=1:size(fulltext,1)-1
            fprintf(fid_list,'%s\n', fulltext(i,:));
      end
      
      fclose(fid_list);
end

% -------------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function preparelists(ERPi, hObject, eventdata, handles)

%
% Prepare List of current Channels and bins
%
if ~isempty(ERPi)
      ERPi   = ERPi(1);
      listch = [];
      nchan  = ERPi.nchan; %
      nbin   = ERPi.nbin; %
      xmin   = ERPi.xmin; %
      xmax   = ERPi.xmax; %
      srate  = ERPi.srate; %
      
      if isempty(ERPi.chanlocs)
            for e=1:nchan
                  ERPi.chanlocs(e).labels = ['Ch' num2str(e)];
            end
      end      
      for ch =1:nchan
            listch{ch} = [num2str(ch) ' = ' ERPi.chanlocs(ch).labels ];
      end
      
      %
      % Prepare List of current Bins
      %
      listb = [];
      
      for b=1:nbin
            listb{b}= ['BIN' num2str(b) ' = ' ERPi.bindescr{b} ];
      end
      
      memoryinput = handles.memoryinput;
      
      if ~isempty(memoryinput)
            binArray  = memoryinput{5};
            chanArray = memoryinput{6};
            selchan   = chanArray(chanArray>=1 & chanArray<=nchan);
            selbin    = binArray(binArray>=1 & binArray<=nbin);
      else
            selchan = 1:nchan;
            selbin  = 1:nbin;
      end
      
      set(handles.popupmenu_bins,'String', listb)
      set(handles.edit_bins,'String', vect2colon(selbin, 'Delimiter','no'))
      set(handles.popupmenu_channels,'String', listch)
      set(handles.edit_channels,'String', vect2colon(selchan, 'Delimiter','no'))
      drawnow
else
      nchan = 0;
      nbin  = 0;
      xmin  = [];
      xmax  = [];
      srate = [];
      set(handles.popupmenu_channels,'String', 'No Chans')
      set(handles.popupmenu_bins,'String', 'No Bins')
      set(handles.edit_bins,'String', '')
      set(handles.edit_channels,'String', '')
      drawnow
end

handles.nchan = nchan;
handles.nbin  = nbin;
handles.xmin  = xmin;
handles.xmax  = xmax;
handles.srate = srate;

% Update handles structure
guidata(hObject, handles);

% -------------------------------------------------------------------------
function checkbox_binlabel_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function checkbox_binlabel_CreateFcn(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function pushbutton_run_CreateFcn(hObject, eventdata, handles)

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
function edit_filelist_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_pol_amp_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_pol_amp_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_samp_amp_Callback(hObject, eventdata, handles)

srate = handles.srate;
pnts = get(handles.popupmenu_samp_amp,'Value')-1;
if isempty(srate)
      msecstr = sprintf('pnts ( ? ms)');
else
      msecstr = sprintf('pnts (%4.1f ms)', (pnts/srate)*1000);
end
set(handles.text_samp,'String',msecstr)

%--------------------------------------------------------------------------
function popupmenu_samp_amp_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_measurement_Callback(hObject, eventdata, handles)
%
% Name & version
%
meamenu  = get(handles.popupmenu_measurement, 'String');
currentm = get(handles.popupmenu_measurement, 'Value');
version = geterplabversion;
set(handles.figure1,'Name', ['ERPLAB ' version '   -   ERP Measurements GUI   -   ' meamenu{currentm}])

switch currentm
      case 1
            menupeakoff(hObject, eventdata, handles)
            set(handles.uipanel_inputlat, 'Title','at latency (just one)');
      case {2,3}
            menupeakon(hObject, eventdata, handles)
            set(handles.uipanel_inputlat, 'Title','between latencies (2)');
            %         case 3
            %                 menupeakon(hObject, eventdata, handles)
            %                 set(handles.uipanel_inputlat, 'Title','between latencies (2)');
      case {4,5}
            menupeakoff(hObject, eventdata, handles)
            set(handles.uipanel_inputlat, 'Title','between latencies (2)');
            %         case 5
            %                 menupeakoff(hObject, eventdata, handles)
            %                 set(handles.uipanel_inputlat, 'Title','between latencies (2)');
      otherwise
            menupeakoff(hObject, eventdata, handles)
            set(handles.uipanel_inputlat, 'Title','between latencies (2)');
end

%--------------------------------------------------------------------------
function popupmenu_measurement_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_localop_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_localop_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function uipanel9_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function uipanel1_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function uipanel2_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton_cancel_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function uipanel_inputlat_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function uipanel4_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function uipanel6_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function uipanel8_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function uipanel12_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function uipanel13_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function radiobutton_erpset_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function radiobutton_folders_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
% --- Executes on button press in radiobutton_custom.
function radiobutton_custom_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
      set(handles.radiobutton_pre,'Value',0)
      set(handles.radiobutton_post,'Value',0)
      set(handles.radiobutton_all,'Value',0)
      set(handles.radiobutton_none,'Value',0)
      set(handles.edit_custom,'Enable','on')
else
      set(hObject,'Value',1)
end
%--------------------------------------------------------------------------
% --- Executes on button press in radiobutton_all.
function radiobutton_all_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
      set(handles.radiobutton_pre,'Value',0)
      set(handles.radiobutton_post,'Value',0)
      set(handles.radiobutton_none,'Value',0)
      set(handles.radiobutton_custom,'Value',0)
      set(handles.edit_custom,'Enable','off')
      edcust = sprintf('%.1f  %.1f', handles.xmin*1000, handles.xmax*1000);
      set(handles.edit_custom,'String', edcust)
else
      set(hObject,'Value',1)
end

%--------------------------------------------------------------------------
function radiobutton_none_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
      set(handles.radiobutton_pre,'Value',0)
      set(handles.radiobutton_post,'Value',0)
      set(handles.radiobutton_all,'Value',0)
      set(handles.radiobutton_custom,'Value',0)
      set(handles.edit_custom,'Enable','off')
      %edcust = sprintf('%.1f  %.1f', handles.xmin*1000, handles.xmax*1000)
      edcust = 'none';
      set(handles.edit_custom,'String', edcust)
else
      set(hObject,'Value',1)
end

%--------------------------------------------------------------------------
% --- Executes on button press in radiobutton_pre.
function radiobutton_pre_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
      set(handles.radiobutton_none,'Value',0)
      set(handles.radiobutton_post,'Value',0)
      set(handles.radiobutton_all,'Value',0)
      set(handles.radiobutton_custom,'Value',0)
      set(handles.edit_custom,'Enable','off')
      edcust = sprintf('%.1f  %.1f', handles.xmin*1000, 0);
      set(handles.edit_custom,'String', edcust)
else
      set(hObject,'Value',1)
end

%--------------------------------------------------------------------------
% --- Executes on button press in radiobutton_post.
function radiobutton_post_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
      set(handles.radiobutton_pre,'Value',0)
      set(handles.radiobutton_none,'Value',0)
      set(handles.radiobutton_all,'Value',0)
      set(handles.radiobutton_custom,'Value',0)
      set(handles.edit_custom,'Enable','off')
      edcust = sprintf('%.1f  %.1f', 0, handles.xmax*1000);
      set(handles.edit_custom,'String', edcust)
else
      set(hObject,'Value',1)
end

%--------------------------------------------------------------------------
function setall(hObject, eventdata, handles)

ALLERP   = handles.ALLERP;
% xmin     = handles.xmin;
% xmax     = handles.xmax;
% owfp     = handles.owfp;

if isstruct(ALLERP)
      nsets    = length(ALLERP);
      %
      % Prepare List of current Channels and bins
      %
      preparelists(ALLERP(1), hObject, eventdata, handles);
else
      nsets = 0;
      %
      % Prepare List of current Channels and bins
      %
      preparelists([], hObject, eventdata, handles);
end

set(handles.popupmenu_samp_amp,'String',cellstr(num2str([0:40]')))
set(handles.popupmenu_precision,'String', num2str([1:6]'))
% set(handles.popupmenu_precision, 'Value', 3);

measurearray = {'Instantaneous amplitude','Peak amplitude','Peak latency',...
      'Mean amplitude between two fixed latencies','Area between two fixed latencies'};

set(handles.popupmenu_measurement, 'String', measurearray);
set(handles.popupmenu_localop, 'String', {'use the absolute peak','use "not a number" (NaN)'});
memoryinput = handles.memoryinput;

if ~isempty(memoryinput)
      optioni   = memoryinput{1}; %1 means from hard drive, 0 means from erpsets menu
      erpset    = memoryinput{2}; % indices of erpset or filename of list of erpsets
      fname     = memoryinput{3};
      latency   = memoryinput{4};
      binArray  = memoryinput{5};
      chanArray = memoryinput{6};
      op        = memoryinput{7}; % option: type of measurement ---> instabl, meanbl, peakampbl, peaklatbl, area, areaz, or errorbl.
      coi       = memoryinput{8};
      dig       = memoryinput{9};
      %measu     = memoryinput{10};% include late? (1:yes or 0:no)
      blc       = memoryinput{10};
      binlabop  = memoryinput{11}; % 0: bin# as bin label for table, 1 bin label
      polpeak   = memoryinput{12}; % local peak polarity
      sampeak   = memoryinput{13}; % number of samples (one-side) for local peak detection criteria
      localop   = memoryinput{14}; % 1 abs peak , 0 Nan
      send2ws   = memoryinput{15}; % 1 send to ws, 0 dont do
      foutput   = memoryinput{16}; % 1 = 1 measurement per line; 0 = 1 erpset per line
      
      [tfm indxmea] = ismember({op}, {'instabl', 'peakampbl', 'peaklatbl', 'meanbl', 'area'} );
      
      if ischar(blc)
            [tfm indxblc] = ismember({blc}, {'none', 'pre', 'post', 'whole', 'custom'} );
      else
            indxblc = NaN;
      end
      
      if foutput==0
            set(handles.radiobutton_f0_1erp_per_line,'Value',1)
            set(handles.radiobutton_f1_1mea_per_line,'Value',0)
      else
            set(handles.radiobutton_f0_1erp_per_line,'Value',0)
            set(handles.radiobutton_f1_1mea_per_line,'Value',1)
      end
      
      set(handles.popupmenu_measurement,'value', indxmea);
      
      switch indxmea
            case 1
                  menupeakoff(hObject, eventdata, handles)
                  set(handles.uipanel_inputlat, 'Title','at latency (just one)');
            case {2,3}
                  menupeakon(hObject, eventdata, handles)
                  set(handles.uipanel_inputlat, 'Title','between latencies (2)');
                  set(handles.popupmenu_pol_amp,'value',2-polpeak)
                  set(handles.popupmenu_samp_amp,'value',sampeak+1);
                  set(handles.popupmenu_localop,'value',2-localop);
                  %         case 3
                  %                 menupeakon(hObject, eventdata, handles)
                  %                 set(handles.uipanel_inputlat, 'Title','between latencies (2)');
            case {4,5}
                  menupeakoff(hObject, eventdata, handles)
                  set(handles.uipanel_inputlat, 'Title','between latencies (2)');
                  %         case 5
                  %                 menupeakoff(hObject, eventdata, handles)
                  %                 set(handles.uipanel_inputlat, 'Title','between latencies (2)');
            otherwise
                  menupeakoff(hObject, eventdata, handles)
                  set(handles.uipanel_inputlat, 'Title','between latencies (2)');
      end
      
      
      % %
      % %
      % %
      % %
      % %
      % %
      % %
      % %
      % %
      % %         if indxmea==2 || indxmea==3
      % %                 menupeakon(hObject, eventdata, handles)
      % %                 set(handles.popupmenu_pol_amp,'value',2-polpeak)
      % %                 set(handles.popupmenu_samp_amp,'value',sampeak+1);
      % %                 set(handles.popupmenu_localop,'value',2-localop);
      % % % %                 srate = handles.srate;
      % % % %                 try
      % % % %                 msecstr = sprintf('pnts (%4.1f ms)', (sampeak/srate)*1000);
      % % % %                 catch
      % % % %                         msecstr = 'pnts (... ms)';
      % % % %                 end
      % % % %                 set(handles.text_samp,'String',msecstr)
      % %         else
      % %                 menupeakoff(hObject, eventdata, handles)
      % %         end
      
      set(handles.edit_latency, 'String',  vect2colon(latency, 'Delimiter', 'off'))
      set(handles.popupmenu_precision, 'Value', dig)
      
      %
      % Clear blc buttons
      %
      set(handles.radiobutton_none, 'Value', 0)
      set(handles.radiobutton_pre, 'Value', 0)
      set(handles.radiobutton_post, 'Value', 0)
      set(handles.radiobutton_all, 'Value', 0)
      set(handles.radiobutton_custom, 'Value', 0)
      
      switch indxblc
            
            case 1
                  set(handles.radiobutton_none, 'Value', 1)
            case 2
                  set(handles.radiobutton_pre, 'Value', 1)
            case 3
                  set(handles.radiobutton_post, 'Value', 1)
            case 4
                  set(handles.radiobutton_all, 'Value', 1)
                  
            otherwise
                  set(handles.radiobutton_custom, 'Value', 1)
                  try
                        blcstrm = num2str(blc);
                  catch
                        blcstrm = '?????';
                  end
                  set(handles.edit_custom,'String', blcstrm)
      end
      
      set(handles.edit_bins, 'String', vect2colon(binArray, 'Delimiter', 'off'))
      
      maxbi = max(binArray);
      set(handles.popupmenu_bins,'Value', maxbi)
      
      if binlabop==0
            set(handles.checkbox_binlabel, 'Value', 0) % use bin number as binlabel
      else
            set(handles.checkbox_binlabel, 'Value', 1) % use bin descr as binlabel
      end
      
      set(handles.edit_channels, 'String', vect2colon(chanArray, 'Delimiter', 'off'))
      maxch = max(chanArray);
      set(handles.popupmenu_channels,'Value', maxch)
      set(handles.edit_fname, 'String', fname);
      set(handles.checkbox_send2ws, 'Value', send2ws);
      
      if nsets>0 && optioni==0
            set(handles.radiobutton_erpset, 'Value', 1);
            set(handles.radiobutton_erpset, 'Enable', 'on');
            set(handles.radiobutton_folders, 'Value', 0);
            set(handles.listbox_erpnames, 'Enable', 'off');
            set(handles.button_adderpset, 'Enable', 'off');
            set(handles.button_delerpset, 'Enable', 'off');
            set(handles.button_savelistas, 'Enable', 'off');
            set(handles.button_savelist, 'Enable', 'off');
            set(handles.button_clearfile, 'Enable', 'off');
            set(handles.button_loadlist, 'Enable', 'off');
            set(handles.edit_erpset, 'String', vect2colon(erpset, 'Delimiter', 'off'));
            set(handles.listbox_erpnames, 'String', {'new erpset'});
            set(handles.edit_filelist,'String', '')
            set(handles.pushbutton_flush,'Enable','off')
      else
            set(handles.radiobutton_folders, 'Value', 1);
            set(handles.radiobutton_erpset, 'Value', 0);
            set(handles.edit_erpset, 'Enable', 'off');
            set(handles.pushbutton_flush,'Enable','on')
            
            if nsets==0
                  set(handles.radiobutton_erpset, 'Enable', 'off');
                  set(handles.edit_erpset, 'String', 'no erpset');
            else
                  set(handles.edit_erpset, 'String', vect2colon(1:nsets, 'Delimiter', 'off'));
            end
            
            %{option erpset fname latency binArray chanArray op coi dig blc binlabop polpeak sampeak localp}
            
            if ~isempty(erpset) && ischar(erpset)
                  
                  fid_list   = fopen( erpset );
                  formcell = textscan(fid_list, '%[^\n]','CommentStyle','#', 'whitespace', '');
                  lista = formcell{:};
                  
                  % extra line forward
                  lista   = cat(1, lista, {'new erpset'});
                  lentext = length(lista);
                  fclose(fid_list);
                  
                  if lentext>1
                        try
                              ERP1 = load(strtrim(lista{1}), '-mat');
                              ERP = ERP1.ERP;
                              
                              if ~iserpstruct(ERP)
                                    error('')
                              end
                              
                              handles.srate = ERP.srate;
                              %
                              % Prepare List of current Channels and bins
                              %
                              preparelists(ERP, hObject, eventdata, handles);
                              
                              set(handles.listbox_erpnames,'String',lista);
                              listname = erpset;
                              handles.listname = listname;
                              set(handles.button_savelistas, 'Enable','on')
                              set(handles.edit_filelist,'String', erpset)
                              
                              % Update handles structure
                              guidata(hObject, handles);
                        catch
                              handles.listname = [];
                              set(handles.button_savelist, 'Enable','off')
                              
                              % Update handles structure
                              guidata(hObject, handles);
                        end
                  else
                        handles.listname = [];
                        set(handles.button_savelist, 'Enable','off')
                        
                        % Update handles structure
                        guidata(hObject, handles);
                  end
            else
                  set(handles.listbox_erpnames, 'String', {'new erpset'});
                  set(handles.edit_filelist,'String', '')
            end
      end
else
      if nsets>0
            set(handles.radiobutton_erpset, 'Value', 1);
            set(handles.radiobutton_erpset, 'Enable', 'on');
            set(handles.radiobutton_folders, 'Value', 0);
            set(handles.listbox_erpnames, 'Enable', 'off');
            set(handles.button_adderpset, 'Enable', 'off');
            set(handles.button_delerpset, 'Enable', 'off');
            set(handles.button_savelistas, 'Enable', 'off');
            set(handles.button_loadlist, 'Enable', 'off');
            set(handles.edit_erpset, 'String', num2str(1:nsets));
      else
            set(handles.radiobutton_folders, 'Value', 1);
            set(handles.edit_erpset, 'String', 'no erpset');
            set(handles.edit_erpset, 'Enable', 'off');
            set(handles.radiobutton_erpset, 'Value', 0);
            set(handles.radiobutton_erpset, 'Enable', 'off');
            set(handles.button_savelistas, 'Enable','off')
      end
      
      set(handles.radiobutton_f0_1erp_per_line,'Value',1)
      set(handles.radiobutton_f1_1mea_per_line,'Value',0)
      set(handles.listbox_erpnames, 'String', {'new erpset'});
      set(handles.edit_filelist,'String', '')
      set(handles.popupmenu_precision, 'Value', 3);
      set(handles.checkbox_send2ws, 'Value', 0);
      msecstr = sprintf('pnts (%4.1f ms)', 0);
      set(handles.text_samp,'String',msecstr)
end

srate = handles.srate;
try
      msecstr = sprintf('pnts (%4.1f ms)', (sampeak/srate)*1000);
catch
      msecstr = 'pnts (... ms)';
end
set(handles.text_samp,'String',msecstr)


%
% Name & version
%
meamenu  = get(handles.popupmenu_measurement, 'String');
currentm = get(handles.popupmenu_measurement, 'Value');
version  = geterplabversion;
set(handles.figure1,'Name', ['ERPLAB ' version '   -   ERP Measurements GUI   -   ' meamenu{currentm}])

%--------------------------------------------------------------------------
function figure1_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function checkbox_send2ws_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton_flush_Callback(hObject, eventdata, handles)
set(handles.listbox_erpnames, 'String', {'new erpset'});
button_clearfile_Callback(hObject, eventdata, handles)
return

%--------------------------------------------------------------------------
% --- Executes on button press in radiobutton_f0_1erp_per_line.
function radiobutton_f0_1erp_per_line_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
      set(handles.radiobutton_f1_1mea_per_line,'Value',0)
else
      set(hObject,'Value',1)
end

%--------------------------------------------------------------------------
% --- Executes on button press in radiobutton_f1_1mea_per_line.
function radiobutton_f1_1mea_per_line_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
      set(handles.radiobutton_f0_1erp_per_line,'Value',0)
else
      set(hObject,'Value',1)
end
