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

% Last Modified by GUIDE v2.5 27-Mar-2023 16:58:03

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

handles.chance = 0; 


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
fntsz = get(handles.edit_report, 'FontSize');
set(handles.edit_report, 'FontSize', fntsz*1.5)
set(handles.edit_report, 'String', sprintf('\nWorking...\n'))

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
for seta = jseta 
    
    AverageAccuracy = ALLMVPA(seta).average_accuracy_1vAll; 

    %plot
    plot(timex,AverageAccuracy, 'LineWidth',1,'Color',[0 0.1 0.5]);
    hold on
    
    if handles.chance == 1
        chancelvl = ALLMVPA(seta).header.nChance; 
        line([timex(1),timex(end)],[chancelvl,chancelvl]); %chance line
    end

 
    
end



hold off

set(handles.edit_report, 'String', '');
set(handles.edit_report, 'FontSize', fntsz);

nsetinput = length(setinput);
if ~get(handles.checkbox_butterflyset, 'Value') && nsetinput<=1
        set(handles.edit_file, 'String', num2str(jseta))
        handles.iset = iset;
        % Update handles structure
        guidata(hObject, handles);
end

setlabelx = '';
if get(handles.checkbox_butterflyset, 'Value')
        if length(setArray)>10
                var1 = vect2colon(setArray, 'Delimiter', 'off');
        else
                var1 = num2str(setArray);
        end
elseif nsetinput>0
        if nsetinput>10
                var1 = vect2colon(jseta, 'Delimiter', 'off');
        else
                var1 = num2str(jseta);
                if nsetinput==1
                        setlabelx = sprintf('(%s)', ALLMVPA(jseta).header.subjectID);
                        chancelabelx = ALLMVPA(jseta).header.nChance;
                        foldlabelx = ALLMVPA(jseta).header.nCrossfolds; 
                        methodlabelx = ALLMVPA(jseta).header.DecodingMethod; 
                end
                
        end
else
        var1 = ALLERP(seta).mvpaname;
end





% if  ~get(handles.checkbox_butterflybin, 'Value') && ~get(handles.checkbox_butterflychan, 'Value') && ~get(handles.checkbox_butterflyset, 'Value') &&...
%                 nsetinput<=1 &&  nbinput<=1 && nchinput<=1
%         % none checked
%         strfrmt = ['File   : %s %s\nBin    : %s %s\nChannel: %s %s\nMeasu  : %s\nWindow : %s\nLate   : %s\nValue  : %.' num2str(dig) 'f\n'];
%         values2print = {var1, setlabelx, var2, binlabelx, var3,  chanlabelx, tittle, sprintf('%.2f\t', latency), sprintf('%.2f\t', truelat), val};
% else

if ~get(handles.checkbox_butterflyset,'Value')
    strfrmt = ['File   : %s %s\nChance level: %.4f \nCrossfold Validation: %i \nDecoding Method: %s '];
    values2print = {var1, setlabelx, chancelabelx, foldlabelx, methodlabelx};
else
    strfrmt = ['File   : %s %s'];
    values2print = {var1, setlabelx};
end

repo = sprintf(strfrmt, values2print{:});
% if ~isempty(nanindxfile) && length(jseta)>1
%         repo = sprintf('%sNaN values found at files: %s', repo, num2str(nanindxfile));
% end
set(handles.edit_report, 'String', repo)

%axis([xlim ylim]); 


% hold off 
drawnow

nsetinput = length(setinput); 







% --- Outputs from this function are returned to the command line.
function varargout = mvpaviewerGUI2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)



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
% tittle = handles.tittle;
% ich    = handles.ich;
% ibin   = handles.ibin;
iset   = handles.iset;
iset   = iset-1;

if iset<1
        return; %iset = 1;
end
handles.iset = iset;

% Update handles structure
guidata(hObject, handles);

%ylim = str2num(get(handles.edit_ylim, 'String' ));
%xlim = str2num(get(handles.edit_xlim, 'String' ));
mplotdata(hObject, handles,iset, xlim, ylim)


% --- Executes on button press in pushbutton_right_file.
function pushbutton_right_file_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_right_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%tittle = handles.tittle;
setArray = handles.setArray;
% ich    = handles.ich;
% ibin   = handles.ibin;
iset   = handles.iset;
iset   = iset+1;

if iset>length(setArray)
        return; %iset = length(setArray);
end
handles.iset      = iset;

% Update handles structure
guidata(hObject, handles);

% ylim = str2num(get(handles.edit_ylim, 'String' ));
% xlim = str2num(get(handles.edit_xlim, 'String' ));
mplotdata(hObject, handles,iset,xlim,ylim)


% --- Executes on button press in checkbox_butterflyset.
function checkbox_butterflyset_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_butterflyset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setArray = handles.setArray;
if get(hObject, 'Value')
        set(handles.edit_file, 'String', vect2colon(setArray, 'Delimiter', 'off'))
        set(handles.edit_file, 'Enable', 'off');
        set(handles.pushbutton_right_file, 'Enable', 'off')
        set(handles.pushbutton_left_file, 'Enable', 'off')

else
        set(handles.edit_file, 'Enable', 'on');
        setinput  = str2num(get(handles.edit_file, 'String'));
        if length(setinput)>1 
                setinput = setinput(1);
                [xxx, iset] = closest(setArray, setinput);
                handles.iset=iset;
                set(handles.edit_file, 'String', num2str(setinput))
        end
        if length(setinput)<=1
                set(handles.pushbutton_right_file, 'Enable', 'on')
                set(handles.pushbutton_left_file, 'Enable', 'on')
        else
                set(handles.pushbutton_right_file, 'Enable', 'off')
                set(handles.pushbutton_left_file, 'Enable', 'off')
        end
end

% tittle = handles.tittle;
% ylim   = str2num(get(handles.edit_ylim, 'String' ));
% xlim   = str2num(get(handles.edit_xlim, 'String' ));
% 
% if isempty(xlim) || isempty(ylim)
%         return
% end

% ich    = handles.ich;
% ibin   = handles.ibin;
iset   = handles.iset;

mplotdata(hObject, handles,iset)

% Hint: get(hObject,'Value') returns toggle state of checkbox_butterflyset



function edit_report_Callback(hObject, eventdata, handles)
% hObject    handle to edit_report (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_report as text
%        str2double(get(hObject,'String')) returns contents of edit_report as a double


% --- Executes during object creation, after setting all properties.
function edit_report_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_report (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_chance.
function checkbox_chance_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_chance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
iset   = handles.iset;
if get(hObject,'Value') 
    handles.chance = 1; 
else
    handles.chance = 0;
end
mplotdata(hObject, handles,iset)

% Hint: get(hObject,'Value') returns toggle state of checkbox_chance
