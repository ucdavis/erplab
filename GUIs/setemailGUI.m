function setemailGUI(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @setemailGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @setemailGUI_OutputFcn, ...
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

%------------------------------------------------------------------------------------------------------------
function setemailGUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = [];
set(handles.checkbox_showpassword, 'Value', 0);
% set(handles.popupmenu_account, 'String', {'@gmail.com' '@yahoo.com'});

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   Set email GUI'])

%
% email settings
%
m = getpref('Internet','SMTP_Username');
if ~isempty(m)
        m = regexp(m, '@','split');
        set(handles.edit_username, 'String', m{1});
end

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

% UIWAIT makes setemailGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

%------------------------------------------------------------------------------------------------------------
function varargout = setemailGUI_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = [];

% The figure can be deleted now
delete(handles.gui_chassis);
fprintf('\nYour email account was successfully set!.\n');
pause(0.1)

%------------------------------------------------------------------------------------------------------------
function edit_username_Callback(hObject, eventdata, handles)

%------------------------------------------------------------------------------------------------------------
function edit_username_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%------------------------------------------------------------------------------------------------------------
% function popupmenu_account_Callback(hObject, eventdata, handles)

%------------------------------------------------------------------------------------------------------------
% function popupmenu_account_CreateFcn(hObject, eventdata, handles)
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%         set(hObject,'BackgroundColor','white');
% end

%------------------------------------------------------------------------------------------------------------
function radiobutton_gmail_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.edit_account, 'String', 'gmail.com')
        set(handles.edit_account, 'Enable', 'off')
        set(handles.radiobutton_yahoo, 'Value', 0)
        set(handles.edit_smtp, 'Enable', 'off')
else
        set(handles.edit_account, 'Enable', 'on')
        set(handles.edit_smtp, 'Enable', 'on')
end

%------------------------------------------------------------------------------------------------------------
function radiobutton_yahoo_Callback(hObject, eventdata, handles)

if get(hObject, 'Value')
        set(handles.edit_account, 'String', 'yahoo.com')
        set(handles.edit_account, 'Enable', 'off')
        set(handles.radiobutton_gmail, 'Value', 0)
        set(handles.edit_smtp, 'Enable', 'off')
else
        set(handles.edit_account, 'Enable', 'on')
        set(handles.edit_smtp, 'Enable', 'on')
end

%------------------------------------------------------------------------------------------------------------
function edit_account_Callback(hObject, eventdata, handles)
accname = get(handles.edit_account, 'String');
accname = strrep(accname, '@','');
set(handles.edit_account, 'String', accname)

if strcmpi(accname, 'gmail.com') || strcmpi(accname, 'gmail')
        set(handles.radiobutton_gmail, 'Value', 1)
        set(handles.radiobutton_yahoo, 'Value', 0)
        set(handles.edit_smtp, 'Enable', 'off')
        set(handles.edit_account, 'String', 'gmail.com');
        set(handles.edit_account, 'Enable', 'off')        
elseif strcmpi(accname, 'yahoo.com')
        set(handles.radiobutton_gmail, 'Value', 0)
        set(handles.radiobutton_yahoo, 'Value', 1)
        set(handles.edit_smtp, 'Enable', 'off')
        set(handles.edit_account, 'Enable', 'off')
end

%------------------------------------------------------------------------------------------------------------
function edit_password_Callback(hObject, eventdata, handles)
drawnow

%------------------------------------------------------------------------------------------------------------
function hidepassword(hObject, eventdata, handles)
if ~get(handles.checkbox_showpassword,'Value')
      
      %
      % Inspired by Jeremy Smith's work (http://www.mathworks.com/matlabcentral/fileexchange/8499)
      %
      passw = get(handles.edit_password,'Userdata');
      key   = get(handles.gui_chassis,'currentkey');
      if strcmpi(key, 'backspace')
            passw = passw(1:end-1);
      else
            passw = [passw get(handles.gui_chassis,'currentcharacter')];
      end
      sizepass = size(passw);
      if sizepass(2) > 0
            astrsk(1,1:sizepass(2)) = '*';
            set(handles.edit_password,'String',astrsk)
      else
            set(handles.edit_password,'String','')
      end
      set(handles.edit_password,'Userdata',passw)
end

% Update handles structure
guidata(hObject, handles);


%------------------------------------------------------------------------------------------------------------
function edit_password_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%------------------------------------------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%------------------------------------------------------------------------------------------------------------
function pushbutton_OK_Callback(hObject, eventdata, handles)

accname = get(handles.edit_account, 'String');
accname = strrep(accname, '@','');
usrname = get(handles.edit_username, 'String');

% if isempty(accname)
% end
% if isempty(usrname)
% end

passw   = get(handles.edit_password,'Userdata');
if isempty(passw)
        passw   = get(handles.edit_password,'String');
end

% email address
mailstr = sprintf('%s@%s', usrname, accname);

if isempty(accname) || isempty(usrname) || isempty(passw)
      msgboxText =  ['You have left blank fields.\n'...
            'If you continue you will delete your e-mail setting using ERPLAB.\n\n'...
            'Do you want to continue anyway?'];
      title = 'ERPLAB: E-mail setting WARNING';
      button = askquest(sprintf(msgboxText), title);
      
      if ~strcmpi(button,'yes')
            disp('User selected Cancel')
            return
      else
            mailstr = [];
            passw   = [];
      end
end

setpref('Internet','E_mail', mailstr);
% Server
if strcmpi(accname, 'gmail.com') || strcmpi(accname, 'gmail')
        setpref('Internet','SMTP_Server','smtp.gmail.com');
        setpref('Internet','SMTP_Username', mailstr);
elseif strcmpi(accname, 'yahoo.com')
        setpref('Internet','SMTP_Server','smtp.mail.yahoo.com');
        setpref('Internet','SMTP_Username', mailstr);
else
        smtpser = get(handles.edit_smtp, 'String');
        if isempty(smtpser)
                msgboxText =  'You must specify a SMTP server';
                etitle     = 'ERPLAB: E-mail setting WARNING';
                errorfound(msgboxText, etitle);
                return
        end        
        setpref('Internet','SMTP_Server', smtpser);
        setpref('Internet','SMTP_Username', usrname);
end
% setpref('Internet','SMTP_Username', mailstr);
setpref('Internet','SMTP_Password', passw);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%------------------------------------------------------------------------------------------------------------
function checkbox_showpassword_Callback(hObject, eventdata, handles)
if get(hObject,'Value') % show password
      passw = get(handles.edit_password,'Userdata');
      set(handles.edit_password,'String', passw);
else  % hide password
      passw = get(handles.edit_password,'String');
      set(handles.edit_password,'Userdata',passw)
      maskp = repmat('*',1,length(passw));
      set(handles.edit_password,'String',maskp)      
end

%--------------------------------------------------------------------------
function pushbutton_reset_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
      msgboxText =  'Are you sure you want to delete your e-mail setting using ERPLAB.';
      title = 'ERPLAB: E-mail setting, reset';
      button = askquest(sprintf(msgboxText), title);
      
      if ~strcmpi(button,'yes')
            disp('User selected Cancel')
            return
      else
            setpref('Internet','E_mail', []);
            setpref('Internet','SMTP_Username', []);
            setpref('Internet','SMTP_Password', []);
      end
end

%--------------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
      % The GUI is still in UIWAIT, us UIRESUME
      uiresume(handles.gui_chassis);
else
      % The GUI is no longer waiting, just close it
      delete(handles.gui_chassis);
end


function edit_account_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_smtp_Callback(hObject, eventdata, handles)


function edit_smtp_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
