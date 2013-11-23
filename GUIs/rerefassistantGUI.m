function varargout = rerefassistantGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
      'gui_Singleton',  gui_Singleton, ...
      'gui_OpeningFcn', @rerefassistantGUI_OpeningFcn, ...
      'gui_OutputFcn',  @rerefassistantGUI_OutputFcn, ...
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
function rerefassistantGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for rerefassistantGUI
handles.output = hObject;
try
      handles.norichan  = varargin{1};
      listch = varargin{2};
      listch = regexprep(listch, '.*=','','ignorecase');
      listch = strtrim(listch);
      handles.listch = listch;
catch
      handles.norichan  = 1;
      handles.listch = {};
end

%
% Gui memory
%
rerefwizardGUI = erpworkingmemory('rerefwizardGUI');

if isempty(rerefwizardGUI)
      set(handles.edit_includechan,'String','');
      set(handles.radiobutton_allchan,'Value',1)
      set(handles.radiobutton_chan2inclu,'Value',0)
      set(handles.radiobutton_chan2exclu,'Value',0)
      set(handles.edit_excludechan,'String','');
      set(handles.checkbox_addrefchan2mydata,'Value', 0);  % 1 means yes
      set(handles.checkbox_copynewlabel,'Value', 1);
      set(handles.edit_equation,'String', '');
      set(handles.checkbox_addunrefequ,'Value', 0);
      set(handles.edit_includechan,'Enable','off')
      set(handles.edit_excludechan,'Enable','off')
      chArray = 1:handles.norichan;
else
      incexc   = rerefwizardGUI.incexc ;
      chArray  = rerefwizardGUI.chArray;
      addref   = rerefwizardGUI.addref;
      addlab   = rerefwizardGUI.addlab;
      equation = rerefwizardGUI.equation;
      addunrefequ = rerefwizardGUI.addunrefequ;
      
      if incexc
            set(handles.radiobutton_chan2inclu,'Value',1)
            set(handles.radiobutton_chan2exclu,'Value',0)
            set(handles.edit_includechan,'String',vect2colon(chArray,'Delimiter','off'));
            set(handles.edit_excludechan,'String','');
            %set(handles.edit_includechan,'Enable','off')
            set(handles.edit_excludechan,'Enable','off')
      else
            set(handles.radiobutton_chan2inclu,'Value',0)
            set(handles.radiobutton_chan2exclu,'Value',1)
            set(handles.edit_includechan,'String', '');
            set(handles.edit_excludechan,'String', vect2colon(chArray,'Delimiter','off'));
            set(handles.edit_includechan,'Enable','off')
            %set(handles.edit_excludechan,'Enable','off')
      end
      set(handles.checkbox_addrefchan2mydata,'Value', addref);  % 1 means yes
      set(handles.checkbox_copynewlabel,'Value', addlab);
      set(handles.edit_equation,'String', equation);
      set(handles.checkbox_addunrefequ,'Value', addunrefequ);
end

handles.chArray = chArray;

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   Rereference GUI'])

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

%--------------------------------------------------------------------------
function varargout = rerefassistantGUI_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

%--------------------------------------------------------------------------
function edit_equation_Callback(hObject, eventdata, handles)

%
% In case user writes "Ch_REF =", this will be erased.
%
formula = get(hObject,'String');
formula = regexprep(formula, '.*s*=','','ignorecase');
formula = lower(formula);
set(hObject,'String', formula);

%--------------------------------------------------------------------------
function edit_equation_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function radiobutton_allchan_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
      set(handles.radiobutton_chan2inclu,'Value',0)
      set(handles.radiobutton_chan2exclu,'Value',0)
      set(handles.edit_includechan,'Enable','off')
      set(handles.edit_excludechan,'Enable','off')
else
      set(handles.radiobutton_allchan,'Value',1)
end

%--------------------------------------------------------------------------
function radiobutton_chan2inclu_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
      set(handles.radiobutton_allchan,'Value',0)
      set(handles.radiobutton_chan2exclu,'Value',0)
      set(handles.edit_includechan,'Enable','on')
      set(handles.edit_excludechan,'Enable','off')
else
      set(handles.radiobutton_chan2inclu,'Value',1)
end

%--------------------------------------------------------------------------
function radiobutton_chan2exclu_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
      set(handles.radiobutton_allchan,'Value',0)
      set(handles.radiobutton_chan2inclu,'Value',0)
      set(handles.edit_includechan,'Enable','off')
      set(handles.edit_excludechan,'Enable','on')
else
      set(handles.radiobutton_chan2exclu,'Value',1)
end

%--------------------------------------------------------------------------
function edit_includechan_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_includechan_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_excludechan_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_excludechan_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function pushbutton2_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton_OK_Callback(hObject, eventdata, handles)

addref    = get(handles.checkbox_addrefchan2mydata,'Value');  % 1 means yes
addlabel  = get(handles.checkbox_copynewlabel,'Value');
equation  = get(handles.edit_equation,'String');
addunrefequ = get(handles.checkbox_addunrefequ,'Value');  % 1 means yes

if isempty(equation)
      msgboxText =  'You have not written any expression yet!';
      title = 'ERPLAB: rerefwizardGUI empty input';
      errorfound(msgboxText, title);
      return
end

abut = get(handles.radiobutton_allchan,'Value');    % all
bbut = get(handles.radiobutton_chan2inclu,'Value'); % include
cbut = get(handles.radiobutton_chan2exclu,'Value'); % exclude
norichan = handles.norichan;

if abut && ~bbut && ~cbut
      incexc  = 1; % include
      chArray = 1:norichan;
elseif ~abut && bbut && ~cbut
      incexc  = 1; % include
      chArray = str2num(get(handles.edit_includechan,'String'));
      if isempty(chArray)
            msgboxText =  'You have not specified any channel yet!';
            title = 'ERPLAB: rerefwizardGUI empty input';
            errorfound(msgboxText, title);
            return
      end
elseif ~abut && ~bbut && cbut
      incexc  = 0; % exclude
      chArray = str2num(get(handles.edit_excludechan,'String'));
else
      fprintf('\nOops! something went wrong with this gui.\n')
      return
end
% if get(handles.radiobutton_chan2inclu,'Value') && ~get(handles.radiobutton_chan2exclu,'Value')
%       incexc = 1; % include
%       chArray = str2num(get(handles.edit_includechan,'String'));
% elseif ~get(handles.radiobutton_chan2inclu,'Value') && get(handles.radiobutton_chan2exclu,'Value')
%       incexc = 0; % exclude
%       chArray = str2num(get(handles.edit_excludechan,'String'));
% else
%       return
% end

formulalist    = createformulas(handles, incexc, chArray, addref, equation, addunrefequ);
handles.output = {formulalist};

%
% memory for Gui
%
rerefwizardGUI.incexc    = incexc;
rerefwizardGUI.chArray   = chArray;
rerefwizardGUI.addref    = addref;
rerefwizardGUI.addlab    = addlabel;
rerefwizardGUI.equation  = equation;
rerefwizardGUI.addunrefequ = addunrefequ;

erpworkingmemory('rerefwizardGUI', rerefwizardGUI);

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function checkbox_addrefchan2mydata_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function formulalist = createformulas(handles, incexc, chArray, addref, equation, addunrefequ)

%
% Creates list of formulas for referencing
%
norichan = handles.norichan; % number of original channels
listch   = handles.listch;

if incexc
      chanArray = chArray;
else
      orichanArray = 1:norichan;
      chanArray    = orichanArray(~ismember_bc2(orichanArray, chArray));
end
% nchan = length(chanArray); % number of chs to reref

unrefchanArray = 1:norichan;
unrefchanArray = unrefchanArray(~ismember_bc2(unrefchanArray, chanArray));

for i=1:norichan
      if get(handles.checkbox_copynewlabel,'Value')
            try
                  newlabel = listch{i};
            catch
                  newlabel = 'undefined';
            end            
            if ismember_bc2(i, unrefchanArray) && addunrefequ
                  flist{i} = sprintf('ch%g = ch%g  Label %s', i, i, newlabel);
            elseif ismember_bc2(i, chanArray)
                  flist{i} = sprintf('ch%g = ch%g - ( %s ) Label %s', i, i, equation, newlabel)  ;
            end
      else
            if ismember_bc2(i, unrefchanArray) && addunrefequ
                  flist{i} = sprintf('ch%g = ch%g', i, i)  ;
            elseif ismember_bc2(i, chanArray)
                  flist{i} = sprintf('ch%g = ch%g - ( %s )', i, i, equation)  ;
            end
      end
end
flist = flist(~cellfun(@isempty, flist));

% for i=1:nchan
%       if get(handles.checkbox_copynewlabel,'Value')
%             try
%                   newlabel = listch{chanArray(i)};
%             catch
%                   newlabel = 'undefined';
%             end
%             flist{i} = sprintf('ch%g = ch%g - ( %s ) Label %s', chanArray(i), chanArray(i), equation, newlabel)  ;
%       else
%             flist{i} = sprintf('ch%g = ch%g - ( %s )', chanArray(i), chanArray(i), equation)  ;
%       end
% end
% 
% 
% 
% 
% if addunrefequ
%       unrefchanArray = 1:norichan;
%       unrefchanArray = unrefchanArray(~ismember_bc2(unrefchanArray, chanArray));   
%       unchan = length(unrefchanArray);
%       for i=1:unchan
%             if get(handles.checkbox_copynewlabel,'Value')
%                   try
%                         newlabel = listch{unrefchanArray(i)};
%                   catch
%                         newlabel = 'undefined';
%                   end
%                   flist{i+nchan} = sprintf('ch%g = ch%g  Label %s', unrefchanArray(i), unrefchanArray(i), newlabel)  ;
%             else
%                   flist{i+nchan} = sprintf('ch%g = ch%g', unrefchanArray(i), unrefchanArray(i))  ;
%             end
%       end
% end

if addref
      flist{end+1} = sprintf('ch%g = %s  Label New Ref', norichan+1, equation)  ;
end
formulalist = char(flist);
return

%--------------------------------------------------------------------------
function pushbutton_avgref_Callback(hObject, eventdata, handles)
chArray = handles.chArray;
set(handles.edit_equation, 'String','')
avgformula = sprintf('avgchan(%s)', vect2colon(chArray, 'Delimiter', 'off'));
set(handles.edit_equation, 'String', avgformula)

%--------------------------------------------------------------------------
function checkbox_copynewlabel_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function checkbox_addunrefequ_Callback(hObject, eventdata, handles)

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
