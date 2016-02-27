function varargout = guideApp(varargin)
% GUIDEAPP MATLAB code for guideApp.fig
%      GUIDEAPP, by itself, creates a new GUIDEAPP or raises the existing
%      singleton*.
%
%      H = GUIDEAPP returns the handle to a new GUIDEAPP or the handle to
%      the existing singleton*.
%
%      GUIDEAPP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIDEAPP.M with the given input arguments.
%
%      GUIDEAPP('Property','Value',...) creates a new GUIDEAPP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guideApp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guideApp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

%   Copyright 2009-2013 The MathWorks Ltd.

% Edit the above text to modify the response to help guideApp

% Last Modified by GUIDE v2.5 21-Jul-2010 07:36:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guideApp_OpeningFcn, ...
                   'gui_OutputFcn',  @guideApp_OutputFcn, ...
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


% --- Executes just before guideApp is made visible.
function guideApp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guideApp (see VARARGIN)

% Choose default command line output for guideApp
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Put a layout in the panel
g = uix.GridFlex( 'Parent', handles.uipanel1, ...
    'Units', 'Normalized', 'Position', [0 0 1 1], ...
    'Spacing', 5 );
uix.BoxPanel( 'Parent', g, 'Title', 'Panel 1' );
uix.BoxPanel( 'Parent', g, 'Title', 'Panel 2' );
uix.BoxPanel( 'Parent', g, 'Title', 'Panel 3' );
uix.BoxPanel( 'Parent', g, 'Title', 'Panel 4' );
g.Heights = [-1 -1];

% UIWAIT makes guideApp wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = guideApp_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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
