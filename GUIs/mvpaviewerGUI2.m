function varargout = mvpaviewerGUI2(varargin)
% MVPAVIEWERGUI2 MATLAB code for mvpaviewerGUI2.fig
%      MVPAVIEWERGUI2, by itself, creates a new MVPAVIEWERGUI2 or raises the existing
%      singleton*.
%
%      H = MVPAVIEWERGUI2 returns the handle to a new MVPAVIEWERGUI2 or the handle to
%      the existing singleton*.
%
%      MVPAVIEWERGUI2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MVPAVIEWERGUI2.M with the given input arguments.
%
%      MVPAVIEWERGUI2('Property','Value',...) creates a new MVPAVIEWERGUI2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mvpaviewerGUI2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mvpaviewerGUI2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mvpaviewerGUI2

% Last Modified by GUIDE v2.5 21-Mar-2023 18:00:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mvpaviewerGUI2_OpeningFcn, ...
                   'gui_OutputFcn',  @mvpaviewerGUI2_OutputFcn, ...
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


% --- Executes just before mvpaviewerGUI2 is made visible.
function mvpaviewerGUI2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mvpaviewerGUI2 (see VARARGIN)

% Choose default command line output for mvpaviewerGUI2
handles.output = [];

%defx   = erpworkingmemory('pop_geterpvalues');
% try
%         cerpi = evalin('base', 'CURRENTERP'); % current erp index
% catch
%         cerpi = 1;
% end
% handles.cerpi = cerpi;
try
        ALLMVPA = varargin{1};
        setArray = 1:length(ALLMVPA);
catch
        ALLMVPA          = buildERPstruct;
        ALLMVPA.times    = -200:800;
        ALLMVPA.xmin     = -0.2;
        ALLMVPA.xmax     = 0.8;
        ALLMVPA.nchan    = 1;
        ALLMVPA.pnts     = length(ALLMVPA.times);
        ALLMVPA.nbin     = 1;
        ALLMVPA.bindata  = zeros(1, ALLMVPA.pnts, 1);
        ALLMVPA.srate    = 1000;
        ALLMVPA.bindescr = {'empty'};
        ALLMVPA.chanlocs.labels = 'empty';
end
% if strcmpi(datatype, 'ERP')
%     meaword = 'latenc';
% else
%     meaword = 'frequenc';
% end
% if isempty(defx)
%         if isempty(ALLMVPA)
%                 inp1   = 1; %from hard drive
%                 erpset = [];
%         else
%                 inp1   = 0; %from erpset menu
%                 erpset = 1:length(ALLMVPA);
%         end
%         defx = {inp1 erpset '' 0 1 1 'instabl' 1 3 'pre' 0 1 5 0 0.5 0 0 0 '' 0 1};
% end
% try
%         def         = varargin{2};
%         AMP         = def{1};
%         Lat         = def{2};
%         binArray    = def{3};
%         chanArray   = def{4};
%         setArray    = def{5};
%         latency     = def{6};
%         moreoptions = def{7};
%         
%         blc        = moreoptions{1};
%         moption    = moreoptions{2};
%         tittle     = moreoptions{3};
%         dig        = moreoptions{4};
%         coi        = moreoptions{5};
%         polpeak    = moreoptions{6};
%         sampeak    = moreoptions{7};
%         locpeakrep = moreoptions{8};
%         frac       = moreoptions{9};
%         fracmearep = moreoptions{10};
%         intfactor  = moreoptions{11};
% catch
%         latency    = defx{4};
%         moption    = defx{7};
%         
%         AMP        = [];
%         Lat        = {{[-200 800]}};
%         binArray   = 1:ALLMVPA(1).nbin;
%         chanArray  = 1:ALLMVPA(1).nchan;
%         setArray   = 1:length(ALLMVPA);
%         %latency    = 0;
%         blc        = 'pre';
%         %moption    = 'instabl';
%         tittle     = 'nada';
%         dig        = 3;
%         coi        = [];
%         polpeak    = [];
%         sampeak    = [];
%         locpeakrep = [];
%         frac       = [];
%         fracmearep = [];
%         intfactor  = 1;
% end
%datatype2 = '';
if isfield(ALLMVPA(1).header, 'DecodingMethod')
        datatype = ALLMVPA(1).header.DecodingMethod;
        
        if strcmpi(datatype,'SVM')
            % here, treat SEM data like ERP data
            datatype = 'SVM';
           % datatype2 = 'SEM';
        end
        
else
        datatype = 'SVM';
end

if strcmpi(datatype, 'SVM')
        measurearray = {'Average Decoding Accuracy'};
else
        %blc        = 'none';
        measurearray = {'Average Decoding Accuracy'};
end

handles.measurearray = measurearray;

meacodes    =      {'avgdecodingacc' };

handles.meacodes    = meacodes;

%set(handles.text_measurementv, 'String', measurearray);

%[tfm, indxmeaX] = ismember_bc2({moption}, meacodes);

meamenu = 1; % 'Average Decoding Accuracy',...
set(handles.text_measurementv, 'String', measurearray{meamenu});
% set(handles.text_measurementv, 'Value', meamenu);
% set(handles.text_measurementv, 'Enable', 'inactive');

cwm = erpworkingmemory('WMColor'); % window color for measurement
cvl = erpworkingmemory('VLColor'); % line color for measurement
mwm = erpworkingmemory('WMmouse'); % select window measurement by mouse option

if isempty(cwm)
        cwm = [0.8490    1.0000    0.1510];
end
if isempty(cvl)
        cvl = [1 0 0];
end
if isempty(mwm)
        mwm = 0;
end

%handles.defx       = defx;
handles.cwm        = cwm;
handles.cvl        = cvl;
handles.ALLMVPA     = ALLMVPA;
%handles.binArray   = binArray;
%handles.chanArray  = chanArray;
handles.setArray   = setArray;
%handles.ich        = 1;
%handles.ibin       = 1;
handles.iset       = 1;
%handles.orilatency = latency;
%handles.blc        = blc;
%handles.moption    = moption;
%handles.tittle     = tittle;
handles.dig        = 3;
handles.x1         = -1.75;
handles.x2         = 1.75;

%
% create random x-values for scatter plot
%
% xscatt = rand(1,numel(AMP))*2.5-1.25;
% handles.xscatt = xscatt;
indxsetstr     = {''};
% end
handles.indxsetstr = indxsetstr;

% handles.membin     = [];
% handles.memch      = [];
% handles.memset     = [];
% 
% binvalue  = erpworkingmemory('BinHisto');    % value(s) for bin in histogram
% normhisto = erpworkingmemory('NormHisto');   % normalize histogram
% chisto    = erpworkingmemory('HistoColor');  % histogram color
% cfitnorm  = erpworkingmemory('FnormColor');  % line color for fitted normal distribution
% fitnormd  = erpworkingmemory('FitNormd');    % fit nomal distribution
% 
% if isempty(binvalue)
%         binvalue = 'auto';
% end
% if isempty(normhisto)
%         normhisto = 0;
% end
% if isempty(chisto)
%         chisto = [1 0.5 0.2];
% end
% if isempty(cfitnorm)
%         cfitnorm = [1 0 0];
% end
% if isempty(fitnormd)
%         fitnormd = 0;
% end

% handles.binvalue  = binvalue;
% handles.normhisto = normhisto;
% handles.chisto    = chisto;
% handles.cfitnorm  = cfitnorm;
% handles.fitnormd  = fitnormd;

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   VIEWER FOR MVPA GUI']); %, 'toolbar','figure')

% ibin  = 1;
% ich   = 1;
iset  = 1;
times = ALLMVPA(1).times;
if strcmpi(datatype, 'SVM')
    xlim  = [min(times) max(times)];
    ylim  = [-2 100];
    
else
    xlim  = [0 30];
    ylim  = [0 15];
    
end


% set(handles.edit_ylim, 'String', num2str(ylim))
% set(handles.edit_xlim, 'String', sprintf('%g %g', round(xlim)))

set(handles.edit_file, 'String', num2str(iset))

set(handles.checkbox_butterflyset,'Value', 0)

if length(setArray)==1
        set(handles.checkbox_butterflyset, 'Enable', 'off')
%         if frdm; set(handles.edit_file, 'Enable', 'off');end
        set(handles.pushbutton_right_file, 'Enable', 'off')
        set(handles.pushbutton_left_file, 'Enable', 'off')
end
handles.datatype = datatype;

%
% Color GUI
% %
% handles = painterplab(handles);
% 
% %
% % Set font size
% %
% handles = setfonterplab(handles);


% help
% helpbutton

%
% Drag
%
% set(handles.checkbox_dmouse,'Value', 0)
% set(handles.radiobutton_histo,'Value', 0)
% set(handles.radiobutton_histo,'Enable', 'off')
% set(handles.pushbutton_histosetting,'Enable', 'off')
% set(handles.radiobutton_scatter,'Value', 0)
% set(handles.radiobutton_scatter,'Enable', 'off')
% set(handles.checkbox_fileindx,'Value', 0)
% set(handles.checkbox_fileindx,'Enable', 'off')
% set(handles.checkbox_scatterlabels, 'Value',0)
% set(handles.checkbox_scatterlabels, 'Enable', 'off')
% set(handles.pushbutton_narrow, 'Enable', 'off')
% set(handles.pushbutton_wide, 'Enable', 'off')
% set(handles.checkbox_3sigma, 'Value',0)
% set(handles.checkbox_3sigma, 'Enable', 'off')
% % set(handles.togglebutton_y_axis_polarity, 'Enable', 'on');
% set(handles.gui_chassis,'DoubleBuffer','on')

% if isempty(AMP)
%         [ AMP, Lat, latency ] = getnewvals(hObject, handles, latency);
%         handles.AMP        = AMP;
%         handles.Lat        = Lat;
%         handles.latency    = latency;
% else
%         handles.AMP        = AMP;
%         handles.Lat        = Lat;
%         handles.latency    = latency;
%         
% end
% Update handles structure
guidata(hObject, handles);

%
% Plot figure
%
mplotdata(hObject, handles, iset, xlim, ylim)



% UIWAIT makes mvpaviewerGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

function mplotdata(hObject,handles,iset,xlim,ylim)

setArray = handles.setArray;

setinput = []; 
if get(handles.checkbox_butterflyset, 'Value')
        jseta      = setArray;
else
        setinput = str2num(get(handles.edit_file, 'String'));
        
        if length(setinput)>1
                jseta = setinput;
        else
                jseta      = setArray(iset);
        end
end

ALLMVPA = handles.ALLMVPA; 
times = ALLMVPA(iset).times;
p1 = times(1);
p2 = times(end); 
intfactor = 0; 
% if intfactor~=1
%         timex = linspace(p1,p2,round(pnts*intfactor));
% else
%         timex = timeor;
% end
timex = times;
%
% Colors
%
cwm = handles.cwm;
cvl = handles.cvl;
% 
% latmin = zeros(1, length(jbin)*length(jchannel)*length(jseta));
% latmax = zeros(1, length(jbin)*length(jchannel)*length(jseta));
axes(handles.axes1);
% fntsz = get(handles.edit_report, 'FontSize');
% set(handles.edit_report, 'FontSize', fntsz*1.5 )
% set(handles.edit_report, 'String', sprintf('\nWorking...\n'))
%drawnow
% tic

%calculate decoding accuracy per subject

% Nsub = length(setArray);
% Nblock = ALLMVPA(iset).header.nCrossfolds;
% Nitr = ALLMVPA(iset).header.nIter; 
% Ntp = length(times); 
% Nclasses = ALLMVPA(iset).header.nClasses;
% chancelvl = 1/Nclasses; 
% 
% AverageAccuracy = nan(Nsub,Ntp); 
% 
% 
% for seta = jseta
%     
%     DecodingAccuracy = nan(Ntp,Nblock,Nitr);
%     % We will compute decoding accuracy per subject in DecodingAccuracy,
%     % enter DecodingAccuracy into AverageAccuray, then overwrite next subj.
%     
%     %% load SVM_ECOC output files
% %     readThis =strcat(fileLocation,filesep,fName,num2str(subList(sub)),'.mat');
% %     load(readThis)
%      
%     % Obtain predictions from SVM-ECOC model
%     svmPrediction = squeeze(ALLMVPA(seta).modelPredict);
%     tstTargets = squeeze(ALLMVPA(seta).targets);
% 
%     
%     %% Step 5: Compute decoding accuracy of each decoding trial
%     for block = 1:Nblock
%         for itr = 1:Nitr
%             for tp = 1:Ntp  
% 
%                 prediction = squeeze(svmPrediction(itr,tp,block,:)); % this is predictions from models
%                 TrueAnswer = squeeze(tstTargets(itr,tp,block,:)); % this is predictions from models
%                 Err = TrueAnswer - prediction; %compute error. No error = 0
%                 ACC = mean(Err==0); %Correct hit = 0 (avg propotion of vector of 1s and 0s)
%                 DecodingAccuracy(tp,block,itr) = ACC; % average decoding accuracy at tp & block
% 
%             end
%         end
%     end
%       
%      % Average across block and iterations
%      grandAvg = squeeze(mean(mean(DecodingAccuracy,2),3));
%     
%      % Perform temporal smoothing (5 point moving avg) 
%      smoothed = nan(1,Ntp);
%      for tAvg = 1:Ntp
%          if tAvg ==1
%            smoothed(tAvg) = mean(grandAvg((tAvg):(tAvg+2)));
%          elseif tAvg ==2
%            smoothed(tAvg) = mean(grandAvg((tAvg-1):(tAvg+2)));
%          elseif tAvg == (Ntp-1)
%            smoothed(tAvg) = mean(grandAvg((tAvg-2):(tAvg+1)));
%          elseif tAvg == Ntp
%            smoothed(tAvg) = mean(grandAvg((tAvg-2):(tAvg)));
%          else
%            smoothed(tAvg) = mean(grandAvg((tAvg-2):(tAvg+2)));  
%          end
% 
%      end
%      
%      % Save smoothe data
%      AverageAccuracy(seta,:) =smoothed; % average across iteration and block
%     
% end

if Nsub == 1 
    plot(timex,AverageAccuracy, 'LineWidth',1,'Color',[0 0.1 0.5]); 
else
    plot(timex,AverageAccuracy(seta), 'LineWidth',1,'Color',[0 0.1 0.5]); 
end
hold on

%axis([xlim ylim]); 


% hold off 
% drawnow

nsetinput = length(setinput); 







% --- Outputs from this function are returned to the command line.
function varargout = mvpaviewerGUI2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_file_Callback(hObject, eventdata, handles)
% hObject    handle to edit_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_file as text
%        str2double(get(hObject,'String')) returns contents of edit_file as a double


% --- Executes during object creation, after setting all properties.
function edit_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_left_file.
function pushbutton_left_file_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_left_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_right_file.
function pushbutton_right_file_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_right_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox_butterflyset.
function checkbox_butterflyset_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_butterflyset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_butterflyset
