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

function varargout = averagerGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
      'gui_Singleton',  gui_Singleton, ...
      'gui_OpeningFcn', @averagerGUI_OpeningFcn, ...
      'gui_OutputFcn',  @averagerGUI_OutputFcn, ...
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

% -------------------------------------------------------------------------
function averagerGUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for averagerGUI
handles.output   = [];
handles.indxline = 1;

try
      currdata = varargin{1};
catch
      currdata = '';
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
      
      %
      % Weighted average option. 1= yes, 0=no
      %
      wavg     = def{3};
      
      %
      % Standard deviation option. 1= yes, 0=no
      %
      stdev     = def{4};
catch
      setindex = 1;
      artcrite = 1;
      wavg     = 1;
      stdev    = 1;
end

%
% Number of current epochs per dataset
%
try
nepochperdata = varargin{3};
catch
      nepochperdata = [];
end
handles.nepochperdata = nepochperdata;

if ~iscell(artcrite)
      if artcrite==0
            va=1;vb=0;vc=0;vd=0;
      elseif artcrite==1
            va=0;vb=1;vc=0;vd=0;
      elseif artcrite==2
            va=0;vb=0;vc=1;vd=0;
      else
            msgboxText =  'invalid option.';
            title = 'ERPLAB: averager GUI';
            errorfound(msgboxText, title);
            return
      end
else
      va=0;vb=0;vc=0;vd=1;
      set(handles.edit_include_indices,'Enable', 'on')
end

set(handles.edit_dataset, 'String', vect2colon(setindex,'Delimiter','off', 'Repeat', 'off')); 
set(handles.checkbox_includeALL, 'Value', va); 
set(handles.checkbox_excludeartifacts, 'Value', vb); 
set(handles.checkbox_onlyartifacts, 'Value', vc); 
set(handles.checkbox_STD, 'Value', stdev);

[img,map]=imread('erplab_help.jpg');
colormap(map)
[row,column] = size(img); 
x = ceil(row/50); 
y = ceil(column/190); 
imgbutton = img(1:x:end,1:y:end,:);
set(handles.pushbutton_help,'CData',imgbutton);

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   AVERAGER GUI'])

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

% UIWAIT makes averagerGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

% -------------------------------------------------------------------------
function varargout = averagerGUI_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

% -------------------------------------------------------------------------
function edit_dataset_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_dataset_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_help_Callback(hObject, eventdata, handles)
doc pop_averager

% -------------------------------------------------------------------------
function pushbutton_RUN_Callback(hObject, eventdata, handles)

dataset = str2num(char(get(handles.edit_dataset, 'String')));
incALL   = get(handles.checkbox_includeALL, 'Value');
excart   = get(handles.checkbox_excludeartifacts, 'Value');
incart   = get(handles.checkbox_onlyartifacts, 'Value');

if incALL && ~excart && ~incart  % average all (good and bad trials)
      artcrite = 0;
      disp('averaging all (good and bad epochs)...')
      
elseif ~incALL && excart && ~incart  % average only good trials
      artcrite = 1;
      disp('averaging only good epochs...')
      
elseif ~incALL && ~excart && incart % average only bad trials! (be cautios!)
      artcrite = 2;
      disp('averaging only bad epochs!!!...')
else
      msgboxText =  'Unexpected multiple choices for artifact rejection criteria!';
      title = 'ERPLAB: averager GUI';
      errorfound(msgboxText, title);
      return
end

if isempty(dataset)
      msgboxText =  'You should enter at least one dataset!';
      title = 'ERPLAB: averager GUI empty input';
      errorfound(msgboxText, title);
      return
else
      wavg = 1; %get(handles.checkbox_wavg,'Value'); % always weighted now...
      stdev = get(handles.checkbox_STD, 'Value');
      handles.output = {dataset, artcrite, wavg, stdev};
      
      % Update handles structure
      guidata(hObject, handles);
      uiresume(handles.gui_chassis);
end

% -------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%-------------------------------------------------------------------------
function checkbox_includeALL_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
      set(handles.checkbox_excludeartifacts,'Value',0)
      set(handles.checkbox_onlyartifacts,'Value',0)
      %set(handles.checkbox_include_indices,'Value',0)
      set(handles.edit_include_indices,'Enable', 'off')
else
      set(handles.checkbox_includeALL,'Value',1)
end

% -------------------------------------------------------------------------
function checkbox_excludeartifacts_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
      set(handles.checkbox_includeALL,'Value',0)
      set(handles.checkbox_onlyartifacts,'Value',0)
      %set(handles.checkbox_include_indices,'Value',0)
      set(handles.edit_include_indices,'Enable', 'off')
else
      set(handles.checkbox_excludeartifacts,'Value',1)
end

% -------------------------------------------------------------------------
function checkbox_onlyartifacts_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
      set(handles.checkbox_includeALL,'Value',0)
      set(handles.checkbox_excludeartifacts,'Value',0)
      %set(handles.checkbox_include_indices,'Value',0)
      set(handles.edit_include_indices,'Enable', 'off')
else
      set(handles.checkbox_onlyartifacts,'Value',1)
end

% -------------------------------------------------------------------------
function checkbox_STD_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
% function checkbox_include_indices_Callback(hObject, eventdata, handles)
% 
% if get(hObject,'Value')
%       set(handles.checkbox_includeALL,'Value',0)
%       set(handles.checkbox_excludeartifacts,'Value',0)
%       set(handles.checkbox_onlyartifacts,'Value',0)
%       set(handles.edit_include_indices,'Enable', 'on')
% else
%       set(handles.checkbox_include_indices,'Value',1)
% end

% -------------------------------------------------------------------------
function edit_include_indices_Callback(hObject, eventdata, handles)

%
% Just for testing
%
[tf epochArray] = getEpochIndices(hObject, eventdata, handles);

if tf==1 % error found
      msgboxText =  ['Sorry, this is not a valid Matlab expression.\n'...
            'Be sure that the expression gives you the range of indices you expect\n.'...
            'You may practice at command window first.'];
      title = 'ERPLAB: binoperGUI few inputs';
      errorfound(sprintf(msgboxText), title);
      return
end
if tf==2 % error found
      msgboxText =  ['Epoch indices must be real positive integers.\n'...
            'Be sure that the expression gives you the range of indices you expect\n.'...
            'You may practice at command window first.'];
      title = 'ERPLAB: binoperGUI few inputs';
      errorfound(sprintf(msgboxText), title);
      return
end
if tf==3 % error found
      msgboxText =  ['Repeated indices were found!\n'...
            'Be sure that the expression gives you the range of indices you expect\n.'...
            'You may practice at command window first.'];
      title = 'ERPLAB: binoperGUI few inputs';
      errorfound(sprintf(msgboxText), title);
      return
end

nepochperdata = handles.nepochperdata;
dataindx      = str2num(get(handles.edit_dataset,'String'));

if isempty(dataindx)
      msgboxText = 'You must specify valid dataset index(ices) first.\n';
      title = 'ERPLAB: binoperGUI few inputs';
      errorfound(sprintf(msgboxText), title);
      return
end
if max(epochArray)>min(nepochperdata(dataindx))      
      fprintf('\n\nDetail:\n')
      for j=1:length(dataindx)
            fprintf('dataset %g has %g epochs.\n', dataindx(j), nepochperdata(dataindx(j)))
      end
      fprintf('\n\n')
      
      msgboxText =  ['Unfortunately, some of your specified datasets\n'...
            'have less epochs than what you are indexing here.\n\n'...
            '(See command window for details)'];
      title = 'ERPLAB: binoperGUI few inputs';
      errorfound(sprintf(msgboxText), title);
      return
end

% -------------------------------------------------------------------------
function [tf epochArray] = getEpochIndices(hObject, eventdata, handles)

linein     = get(handles.edit_include_indices,'String');
epochArray = str2num(linein);
tf = 0;

if isempty(epochArray)
      
      %
      % Test valid expression
      %
      try
            epochArray = eval(linein);
      catch
            tf = 1; % error found
            return
      end
end

%
% Tests positive integer
%
b = epochArray-floor(epochArray);
if nnz(b)>0 || min(epochArray)<1
      tf=2; % non integer  or not positive index
      return
end

%
% Tests uniqueness
%
c = length(unique_bc2(epochArray));
if c~=length(epochArray)
      tf=3; % not unique indices
      return
end

% -------------------------------------------------------------------------
function edit_include_indices_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function pushbutton_epochwizard_Callback(hObject, eventdata, handles)

nepochperdata = handles.nepochperdata;
epochArray = epoch4avgGUI(nepochperdata);

% --- Executes during object creation, after setting all properties.
function edit_help_avg1_CreateFcn(hObject, eventdata, handles)

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
