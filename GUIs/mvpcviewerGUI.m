function varargout = mvpcviewerGUI(varargin)
% MVPCVIEWERGUI MATLAB code for mvpcviewerGUI.fig
%      MVPCVIEWERGUI, by itself, creates a new MVPCVIEWERGUI or raises the existing
%      singleton*.
%
%      H = MVPCVIEWERGUI returns the handle to a new MVPCVIEWERGUI or the handle to
%      the existing singleton*.
%
%      MVPCVIEWERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MVPCVIEWERGUI.M with the given input arguments.
%
%      MVPCVIEWERGUI('Property','Value',...) creates a new MVPCVIEWERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mvpcviewerGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mvpcviewerGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mvpcviewerGUI

% Last Modified by GUIDE v2.5 06-Jun-2023 18:10:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mvpcviewerGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @mvpcviewerGUI_OutputFcn, ...
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


% --- Executes just before mvpcviewerGUI is made visible.
function mvpcviewerGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mvpcviewerGUI (see VARARGIN)

% Choose default command line output for mvpcviewerGUI
handles.output = [];

%defx   = erpworkingmemory('pop_geterpvalues');
% try
%         cerpi = evalin('base', 'CURRENTERP'); % current erp index
% catch
%         cerpi = 1;
% end
% handles.cerpi = cerpi;
ALLMVPC = varargin{1};
setArray = 1:length(ALLMVPC);

measurearray = {'Average Decoding Accuracy','Crossnobis Distance','None'};


%colors 
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

%
% Color GUI
%
handles = painterplab(handles);

%
% Set font size
%
handles = setfonterplab(handles);


if isempty(ALLMVPC)
    set(handles.radiobutton2,'Value',1)
    
    handles.measurearray = {''};
    handles.meacodes =   {''};
    handles.chance = 0;
    handles.stderror = 0;
    handles.alpha = {'0.10','0.20','0.30','0.40','0.50','0.60','0.70','0.80','0.90','1.0'};
    set(handles.popupmenu_alpha,'String', handles.alpha);
    set(handles.popupmenu_alpha,'Value',7);
    set(handles.popupmenu_alpha,'String', handles.alpha);
    set(handles.popupmenu_alpha,'Value',7);
    meamenu = 3;
    set(handles.text_measurementv, 'String', measurearray{meamenu});
    
    
    handles.ALLMVPA     = ALLMVPC;
    handles.setArray   = setArray;
    handles.iset       = 0;
    handles.dig        = 3;
    handles.x1         = -1.75;
    handles.x2         = 1.75;
    
    xlim  = [0 30]; %default for empty values
    ylim  = [0 15]; %default for emtpy values
    
    set(handles.edit_ylim, 'String', num2str(ylim));
    set(handles.edit_xlim, 'String', sprintf('%g %g', round(xlim)));
    
    iset = 0; %empty file
    set(handles.edit_file, 'String', num2str(iset));
    
    %set(handles.checkbox_butterflyset,'Enable', 'off');
    set(handles.checkbox_stderror,'Enable', 'off');
    

    %set(handles.checkbox_butterflyset, 'Enable', 'off')
    set(handles.pushbutton_right_file, 'Enable', 'off')
    set(handles.pushbutton_left_file, 'Enable', 'off')

    handles.datatype = '';
    
else
    
    iset = evalin('base','CURRENTMVPC'); 

   % set(handles.radiobutton1,'Value',1); 
    set(handles.listbox_mvpcnames,'Enable','on'); 
    set(handles.text3,'String','MVPC Menu File Index'); 
    
    fnames = {ALLMVPC(:).mvpcname};
    
    for n = 1:numel(fnames)
        fnames{n} = char(strcat(['File ' num2str(n) ': '], {' '},fnames{n}));
    end
    
    
    set(handles.listbox_mvpcnames,'String',fnames);
    set(handles.listbox_mvpcnames,'Value',iset); 
    
    if isfield(ALLMVPC(iset), 'DecodingMethod')
        datatype = ALLMVPC(iset).DecodingMethod;
         
    else
        datatype = 'SVM';
    end
    
    
    if strcmpi(datatype, 'SVM')
        meamenu = 1;
    else
        meamenu = 2;
    end
    
    handles.measurearray = measurearray;

    
    meacodes    =      {'avgdecodingacc' };
    
    handles.meacodes    = meacodes;
    
    handles.chance = 1; %set default on 
    set(handles.checkbox_chance,'Value',1); %set default on 
    handles.stderror = 0;
    handles.alpha = {'0.10','0.20','0.30','0.40','0.50','0.60','0.70','0.80','0.90','1.0'};
    set(handles.popupmenu_alpha,'String', handles.alpha);
    set(handles.popupmenu_alpha,'Value',3);
    
    
    %set(handles.text_measurementv, 'String', measurearray);
    %[tfm, indxmeaX] = ismember_bc2({moption}, meacodes);
    
    set(handles.text_measurementv, 'String', measurearray{meamenu});
    % set(handles.text_measurementv, 'Value', meamenu);
    % set(handles.text_measurementv, 'Enable', 'inactive');
    
    
    handles.ALLMVPA     = ALLMVPC;
    handles.ALLMVPA_reset = ALLMVPC; 
    %handles.binArray   = binArray;
    %handles.chanArray  = chanArray;
    handles.setArray   = setArray;
    %handles.ich        = 1;
    %handles.ibin       = 1;
    handles.iset       = iset;
    %handles.orilatency = latency;
    %handles.blc        = blc;
    %handles.moption    = moption;
    %handles.tittle     = tittle;
    handles.dig        = 3;
    handles.x1         = -1.75;
    handles.x2         = 1.75;
    
    
    % ibin  = 1;
    % ich   = 1;
    
    times = ALLMVPC(iset).times;
    if strcmpi(datatype, 'SVM')
        xlim  = [min(times) max(times)];
        if ALLMVPC(iset).chance*4 > 1
            ylim = [0 1];
        else
            ylim =  [0 ALLMVPC(iset).chance*4];
            
        end
        
    else
        xlim  = [min(times) max(times)];;
        ylim  = [abs(min(ALLMVPC(iset).average_score))*-1.10 max(ALLMVPC(iset).average_score)*1.10];
        
    end
    
    handles.ylim_set = []; %for user set limits 
    handles.xlim_set = []; %for user set limits
    
    set(handles.edit_ylim, 'String', num2str(ylim));
    set(handles.edit_xlim, 'String', sprintf('%g %g', round(xlim)));
    
    set(handles.edit_file, 'String', num2str(iset));
    
    %set(handles.checkbox_butterflyset,'Value', 0);
    set(handles.checkbox_stderror,'Value', 0);
    
    if length(setArray)==1
       % set(handles.checkbox_butterflyset, 'Enable', 'off')
        %         if frdm; set(handles.edit_file, 'Enable', 'off');end
        set(handles.pushbutton_right_file, 'Enable', 'off')
        set(handles.pushbutton_left_file, 'Enable', 'off')
    end
    handles.datatype = datatype;
    
    
    
    %
    % Plot figure
    %
    % Update handles structure
    guidata(hObject, handles);

    
    mplotdata(hObject, handles, iset, xlim, ylim); 
    
end

%
% create random x-values for scatter plot
%
% xscatt = rand(1,numel(AMP))*2.5-1.25;
% handles.xscatt = xscatt;
% indxsetstr     = {''};
% % end
% handles.indxsetstr = indxsetstr;

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
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   VIEWER FOR MVPC GUI']); %, 'toolbar','figure')

% Update handles structure
guidata(hObject, handles);



% UIWAIT makes mvpaviewerGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);




function mplotdata(hObject,handles,iset,xlim,ylim)

setArray = handles.setArray;
measurearray = handles.measurearray;


if ~isempty(handles.ylim_set)
    %user's preference
    ylim = handles.ylim_set; 
   
end
if ~isempty(handles.xlim_set)
    %users preference
    xlim = handles.xlim_set;   
end


%% only one file
% pervious version of this code plotted more than one file
% if checkbox_butterflyset was enabled
% For the first version of decoding toolbox, Steve
% decided we only view one file at a time 

%setinput = []; 
% if get(handles.checkbox_butterflyset, 'Value')
%         jseta      = setArray;
%         
%         
% else
setinput = eval(get(handles.edit_file, 'String'));

% if length(setinput)>1
%     jseta = setinput;
% else
 jseta      = setArray(iset);
% end
% end

ALLMVPC = handles.ALLMVPA; 
times = ALLMVPC(iset).times;

%MVPC listbox

fntsz = get(handles.edit_report, 'FontSize');
set(handles.edit_report, 'FontSize', fntsz*1.5)
set(handles.edit_report, 'String', sprintf('\nWorking...\n'))

linecols = ["red","green","blue","cyan","magenta","black"];
linecols_max = repmat(linecols,size(setArray)); %set max amount of colors
linecols = linecols_max(setArray); 



% p1 = times(1);
% p2 = times(end); 
% intfactor = 0; 
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
for i = 1:numel(jseta)
    
    seta = jseta(i); 
    
    AverageAccuracy = ALLMVPC(seta).average_score; %index datum(or data)
    
    if isfield(ALLMVPC(seta), 'DecodingMethod')
        datatype = ALLMVPC(seta).DecodingMethod;     
    else
        datatype = 'None';
    end
    
    
    if strcmpi(datatype, 'SVM')
        meamenu = 1;
    else
        meamenu = 2;
    end
    
    if numel(jseta) > 1      
        set(handles.text_measurementv, 'String', 'Multiple');
        set(handles.text11,'String','Multiple'); 
    else
        set(handles.text_measurementv, 'String', measurearray{meamenu});
        if meamenu == 1
            set(handles.text11,'String','Decoding Accuracy (proportion correct)'); 
        elseif meamenu == 2
             set(handles.text11,'String','Distance (uV)');
        end
    end

    
    %plot
    plot(timex,AverageAccuracy, 'LineWidth',1,'Color',linecols(seta));
    axis([xlim ylim]); 
    hold on
    
    if handles.chance == 1
        chancelvl = ALLMVPC(seta).chance; 
        line([timex(1),timex(end)],[chancelvl,chancelvl],... 
            'LineStyle','--','Color','black'); %chance line
        
    end
    
    if handles.stderror == 1
        indxalpha = handles.popupmenu_alpha.Value; 
        stdalpha = str2num(handles.alpha{indxalpha}); 
        yt1 = AverageAccuracy - ALLMVPC(seta).stderror; 
        yt2 = AverageAccuracy + ALLMVPC(seta).stderror; 
%         yt1 = data4plot(1,:,binArray(ibin)) - ERP.binerror(chanArray(i),:,binArray(ibin)).*errorstd;
%         yt2 = data4plot(1,:,binArray(ibin)) + ERP.binerror(chanArray(i),:,binArray(ibin)).*errorstd;
        ciplot(yt1,yt2, ALLMVPC(seta).times, linecols(seta), stdalpha);
        
    end

 
    
end

%update scales 
set(handles.edit_ylim, 'String', num2str(ylim));
set(handles.edit_xlim, 'String', sprintf('%g %g', round(xlim)));


hold off

set(handles.edit_report, 'String', '');
set(handles.edit_report, 'FontSize', fntsz);

nsetinput = length(setinput);
if nsetinput<=1
        set(handles.edit_file, 'String', num2str(jseta))
        handles.iset = iset;
        % Update handles structure
        guidata(hObject, handles);
end

setlabelx = '';
% if get(handles.checkbox_butterflyset, 'Value')
%         if length(setArray)>10
%                 var1 = vect2colon(setArray, 'Delimiter', 'off');
%         else
%                 var1 = num2str(setArray);
%         end
%         for i = 1:numel(jseta)
%             seta = jseta(i);
%             setlabelx{seta} = sprintf('(%s)', ALLMVPC(seta).mvpcname);
%             chancelabelx{seta} = ALLMVPC(seta).chance;
%             foldlabelx{seta} = ALLMVPC(seta).nCrossfolds;
%             methodlabelx{seta} = ALLMVPC(seta).DecodingMethod;
%         end
%         
if nsetinput == 1
        if nsetinput>10
                var1 = vect2colon(jseta, 'Delimiter', 'off');
        else
                var1 = num2str(jseta);
                if nsetinput==1
                        setlabelx = sprintf('(%s)', ALLMVPC(seta).mvpcname);
                        chancelabelx = ALLMVPC(jseta).chance;
                       % foldlabelx = ALLMVPC(jseta).nCrossfolds; 
                        methodlabelx = ALLMVPC(jseta).DecodingMethod; 
                end
                
        end
else
    %% what if more than one file is chosen, and with chance levels differnt? 
%     if nsetinput>10
%         var1 = vect2colon(jseta, 'Delimiter', 'off');
%     else
%         var1 = num2str(jseta);
%         if nsetinput==1
%             setlabelx = sprintf('(%s)', ALLMVPC(jseta).mvpcname);
%             chancelabelx = ALLMVPC(jseta).nChance;
%             foldlabelx = ALLMVPC(jseta).nCrossfolds;
%             methodlabelx = ALLMVPC(jseta).DecodingMethod;
%         end
%         
%     end
    
    var1 = vect2colon(jseta, 'Delimiter', 'off');
end





% if  ~get(handles.checkbox_butterflybin, 'Value') && ~get(handles.checkbox_butterflychan, 'Value') && ~get(handles.checkbox_butterflyset, 'Value') &&...
%                 nsetinput<=1 &&  nbinput<=1 && nchinput<=1
%         % none checked
%         strfrmt = ['File   : %s %s\nBin    : %s %s\nChannel: %s %s\nMeasu  : %s\nWindow : %s\nLate   : %s\nValue  : %.' num2str(dig) 'f\n'];
%         values2print = {var1, setlabelx, var2, binlabelx, var3,  chanlabelx, tittle, sprintf('%.2f\t', latency), sprintf('%.2f\t', truelat), val};
% else

% if ~get(handles.checkbox_butterflyset,'Value')
%     strfrmt = ['File   : %s %s\nChance level: %.4f \nCrossfold Validation: %i \nDecoding Method: %s '];
%     values2print = {var1, setlabelx, chancelabelx, foldlabelx, methodlabelx};
% else
%

% Only one file at a time
%strfrmt = ['File   : %s'];
 

strfrmt = repmat('MVPC Details \nFile %s: %s \nChance: %.4f \nMethod: %s',[1,numel(jseta)]);

p = 1;
for j = 1:1
    %only 1 file
    if p == 1
        values2print = {var1};
    end
    p = p + 1;
    values2print{p} = setlabelx;
    p = p + 1;
    values2print{p} = chancelabelx;
    p = p + 1;
    values2print{p} = methodlabelx; 
end


repo = sprintf(strfrmt, values2print{:});
% if ~isempty(nanindxfile) && length(jseta)>1
%         repo = sprintf('%sNaN values found at files: %s', repo, num2str(nanindxfile));
% end
set(handles.edit_report, 'String', repo)

%axis([xlim ylim]); 


% hold off 
drawnow

%nsetinput = length(setinput); 







% --- Outputs from this function are returned to the command line.
function varargout = mvpcviewerGUI_OutputFcn(hObject, eventdata, handles) 
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

try
    iset = eval(get(hObject,'String'));
catch
    msgboxText = 'You did not input a valid file number';
    title_msg  = 'ERPLAB: MVPCviewer() error:';
    errorfound(msgboxText, title_msg);
    set(hObject,'String',handles.iset); 
    return
end

if max(iset) > max(handles.setArray)
    msgboxText = 'You did not input a valid file number';
    title_msg  = 'ERPLAB: MVPCviewer() error:';
    errorfound(msgboxText, title_msg);
    set(hObject,'String',handles.iset); 
    return
end

%update listbox
set(handles.listbox_mvpcnames, 'Value', iset); 

%query reasonable xlim & ylim

ALLMVPC = handles.ALLMVPA;
times = ALLMVPC(iset).times;
datatype = ALLMVPC(iset).DecodingMethod; 
if strcmpi(datatype, 'SVM')
    xlim  = [min(times) max(times)];
    if ALLMVPC(iset).chance*4 > 1
        ylim = [0 1];
    else
        ylim =  [0 ALLMVPC(iset).chance*4];
        
    end
    
else
    xlim  = [min(times) max(times)];
    ylim  = [abs(min(ALLMVPC(iset).average_score))*-1.10 max(ALLMVPC(iset).average_score)*1.10];
    
end

%ylim = str2num(get(handles.edit_ylim, 'String' ));
%xlim = str2num(get(handles.edit_xlim, 'String' ));
mplotdata(hObject, handles,iset, xlim, ylim)


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
check_iset   = iset-1;

if check_iset<1
        return; %iset = 1;
else
    iset = check_iset;
end    
%handles.iset = iset;

%update listbox
set(handles.listbox_mvpcnames,'Value',iset); 

% Update handles structure
guidata(hObject, handles);

%query reasonable xlim & ylim

ALLMVPC = handles.ALLMVPA;
times = ALLMVPC(iset).times;
datatype = ALLMVPC(iset).DecodingMethod; 
if strcmpi(datatype, 'SVM')
    xlim  = [min(times) max(times)];
    if ALLMVPC(iset).chance*4 > 1
        ylim = [0 1];
    else
        ylim =  [0 ALLMVPC(iset).chance*4];
        
    end
    
else
    xlim  = [min(times) max(times)];
    ylim  = [abs(min(ALLMVPC(iset).average_score))*-1.10 max(ALLMVPC(iset).average_score)*1.10];
    
end

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
check_iset   = iset+1;

if check_iset>length(setArray)
        return; %iset = length(setArray);
else
    iset = check_iset; 
end
handles.iset      = iset;

set(handles.listbox_mvpcnames,'Value',iset); 

% Update handles structure
guidata(hObject, handles);

ALLMVPC = handles.ALLMVPA;
times = ALLMVPC(iset).times;
datatype = ALLMVPC(iset).DecodingMethod; 
if strcmpi(datatype, 'SVM')
    xlim  = [min(times) max(times)];
    if ALLMVPC(iset).chance*4 > 1
        ylim = [0 1];
    else
        ylim =  [0 ALLMVPC(iset).chance*4];
        
    end
    
else
    xlim  = [min(times) max(times)];
    ylim  = [abs(min(ALLMVPC(iset).average_score))*-1.10 max(ALLMVPC(iset).average_score)*1.10];
    
end

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
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));
% 
% if isempty(xlim) || isempty(ylim)
%         return
% end

% ich    = handles.ich;
% ibin   = handles.ibin;
iset   = handles.iset;

mplotdata(hObject, handles, iset, xlim, ylim)

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

ylim = str2num(get(handles.edit_ylim, 'String' ));
xlim = str2num(get(handles.edit_xlim, 'String' ));

mplotdata(hObject, handles,iset,xlim,ylim)

% Hint: get(hObject,'Value') returns toggle state of checkbox_chance



function edit_ylim_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ylim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ylim as text
%        str2double(get(hObject,'String')) returns contents of edit_ylim as a double
%tittle = handles.tittle;
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));

if length(xlim)~=2 || length(ylim)~=2 || any(isnan(xlim)) || any(isnan(ylim)) || any(isinf(xlim)) || any(isinf(ylim)) || xlim(1)>=xlim(2) || ylim(1)>=ylim(2)
        msgboxText =  'Invalid scale!\n You must enter 2 numeric values on each range.\tThe first one must be lower than the second one.';
        title = 'ERPLAB: mvpciewerGUI, invalid baseline input';
        errorfound(sprintf(msgboxText), title);
        return
end

handles.ylim_set = ylim;
handles.xlim_set = xlim; 

guidata(hObject, handles); %maintain set limits

iset   = handles.iset;

mplotdata(hObject, handles, iset, xlim, ylim)


% --- Executes during object creation, after setting all properties.
function edit_ylim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ylim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_xlim_Callback(hObject, eventdata, handles)
% hObject    handle to edit_xlim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_xlim as text
%        str2double(get(hObject,'String')) returns contents of edit_xlim as a double
%tittle = handles.tittle;
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));

if length(xlim)~=2 || length(ylim)~=2 || any(isnan(xlim)) || any(isnan(ylim)) || any(isinf(xlim)) || any(isinf(ylim)) || xlim(1)>=xlim(2) || ylim(1)>=ylim(2)
        msgboxText =  'Invalid scale!\n You must enter 2 numeric values on each range.\tThe first one must be lower than the second one.';
        title = 'ERPLAB: mvpciewerGUI, invalid baseline input';
        errorfound(sprintf(msgboxText), title);
        return
end

handles.ylim_set = ylim;
handles.xlim_set = xlim; 

guidata(hObject, handles); %maintain set limits

iset   = handles.iset;

mplotdata(hObject, handles, iset, xlim, ylim)


% --- Executes during object creation, after setting all properties.
function edit_xlim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_xlim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_createplot.
function pushbutton_createplot_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_createplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% h1=handles.axes1;
% %
% % Create figure
% %
% hbig = figure('Name','ERP VIEWER',...
%         'NumberTitle','on', 'Tag', 'Viewer_figure');erplab_figtoolbar(hbig);
% % objects=allchild(h1);
% copyobj(h1,hbig);
% opengl software
OFF_STD = 0.25; % std dev of figure offset
MIN_OFF = 0.15; % minimum offset for new figure
BORDER  = 0.04;  % screen edge tolerance

fig=handles.gui_chassis;
sel=handles.axes1;
%
% Get position for new figure
%
set(sel,'Units','normalized');
place = get(sel,'Position');
cmap  = colormap;
% newxy = (OFF_STD*randn(1,2))+place(1,1:2);
% newx  = newxy(1);newy=newxy(2);
%
% if abs(newx-place(1,1))<MIN_OFF, newx=place(1,1)+sign(newx-place(1,1))*MIN_OFF;end
% if abs(newy-place(1,1))<MIN_OFF, newy=place(1,1)+sign(newy-place(1,1))*MIN_OFF;end
% if newx<BORDER, newx=BORDER; end
% if newy<BORDER, newy=BORDER; end
% if newx+place(3)>1-BORDER, newx=1-BORDER-place(3); end
% if newy+place(4)>1-BORDER, newy=1-BORDER-place(4); end

% newfig = figure('Units','Normalized','Position',[newx,newy,place(1,3:4)]);
newfig = figure('Units','Normalized','Position', place, 'Name','MVPC VIEWER', 'NumberTitle','on', 'Tag', 'Viewer_figure');

%
% Copy object to new figure
%
set(newfig,'Color',[1 1 1]);
copyobj(sel,newfig);
set(gca,'Position',[0.130 0.110 0.775 0.815]);
set(gca,'Box', 'off')
colormap(cmap);
erplab_figtoolbar(newfig)

% %
% % Increase font size
% %
% set(findobj('parent',newfig,'type','axes'),'FontSize',14);
% set(get(gca,'XLabel'),'FontSize',16)
% set(get(gca,'YLabel'),'FontSize',16)
% set(get(gca,'Title'),'Fontsize',16);
%
% Add xtick and ytick labels if missing
%
% if strcmp(get(gca,'Box'),'on')
%    set(gca,'xticklabelmode','auto')
%    set(gca,'xtickmode','auto')
%    set(gca,'yticklabelmode','auto')
%    set(gca,'ytickmode','auto')
% end
%
% Turn on zoom in the new figure
%
% zoom on;
pause(0.2)

%latency = handles.latency;
%handles.output = NaN;

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);


% --- Executes on button press in checkbox_stderror.
function checkbox_stderror_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_stderror (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_stderror

iset   = handles.iset;
if get(hObject,'Value') 
    handles.stderror = 1; 
else
    handles.stderror = 0;
end

ylim = str2num(get(handles.edit_ylim, 'String' ));
xlim = str2num(get(handles.edit_xlim, 'String' ));

mplotdata(hObject, handles,iset,xlim,ylim)


% --- Executes on selection change in popupmenu_alpha.
function popupmenu_alpha_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_alpha contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_alpha
iset   = handles.iset;
if get(hObject,'Value') 
    handles.stderror = 1; 
else
    handles.stderror = 0;
end

ylim = str2num(get(handles.edit_ylim, 'String' ));
xlim = str2num(get(handles.edit_xlim, 'String' ));

mplotdata(hObject, handles,iset,xlim,ylim)


% --- Executes during object creation, after setting all properties.
function popupmenu_alpha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.radiobutton2,'Value',0); 
set(handles.listbox_mvpcnames,'Enable','off'); 
set(handles.pushbutton_addmvpc,'Enable','off'); 

set(handles.text3,'String','MVPC index'); 

%plot first MVPCset

ALLMVPC =  handles.ALLMVPA_reset; %obtain reset value
setArray = 1:length(ALLMVPC); 
  
    if isfield(ALLMVPC(1), 'DecodingMethod')
        datatype = ALLMVPC(1).DecodingMethod;
        
        if strcmpi(datatype,'SVM')
            % here, treat SEM data like ERP data
            datatype = 'SVM';
            % datatype2 = 'SEM';
        end
        
    else
        datatype = 'SVM';
    end
    
    
    if strcmpi(datatype, 'SVM')
        meamenu = 1;
    else
        meamenu = 2
    end
    
    measurearray = handles.measurearray; 

    handles.chance = 0;
    handles.stderror = 0;
    handles.alpha = {'0.10','0.20','0.30','0.40','0.50','0.60','0.70','0.80','0.90','1.0'};
    set(handles.popupmenu_alpha,'String', handles.alpha);
    set(handles.popupmenu_alpha,'Value',7);

    set(handles.text_measurementv, 'String', measurearray{meamenu});

    
    handles.ALLMVPA     = ALLMVPC;
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
    
    

    iset  = 1;
    times = ALLMVPC(1).times;
    if strcmpi(datatype, 'SVM')
        xlim  = [min(times) max(times)];
        if ALLMVPC(1).chance*3 > 1
            ylim = [0 1];
        else
            ylim =  [0 ALLMVPC(1).chance*3];
            
        end
        
    else
        xlim  = [0 30];
        ylim  = [0 15];
        
    end
    
    
    set(handles.edit_ylim, 'String', num2str(ylim));
    set(handles.edit_xlim, 'String', sprintf('%g %g', round(xlim)));
    
    set(handles.edit_file, 'String', num2str(iset));
    
    set(handles.checkbox_butterflyset,'Value', 0);
    set(handles.checkbox_stderror,'Value', 0);
    
    if length(setArray)==1
        set(handles.checkbox_butterflyset, 'Enable', 'off')
        %         if frdm; set(handles.edit_file, 'Enable', 'off');end
        set(handles.pushbutton_right_file, 'Enable', 'off')
        set(handles.pushbutton_left_file, 'Enable', 'off')
    end
    handles.datatype = datatype;
    
    
    
    %
    % Plot figure
    %
    % Update handles structure
    guidata(hObject, handles);

    
    mplotdata(hObject, handles, iset, xlim, ylim); 








% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.radiobutton1,'Value',0); 
set(handles.listbox_mvpcnames,'Enable','on');
set(handles.pushbutton_addmvpc,'Enable','on'); 

if isempty(get(handles.listbox_mvpcnames,'String'))
    set(handles.listbox_mvpcnames,'String',{'new mvpcset'});
    set(handles.edit_file,'String','0'); 
else

   set(handles.listbox_mvpcnames,'Value',1); 
   set(handles.listbox_mvpcnames,'String',{'new mvpcset'});
   set(handles.edit_file,'String','0');
end

set(handles.text3,'String','File index'); 



% Hint: get(hObject,'Value') returns toggle state of radiobutton2


% --- Executes on selection change in listbox_mvpcnames.
function listbox_mvpcnames_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_mvpcnames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_mvpcnames contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_mvpcnames

iset = get(hObject,'Value'); 

%query reasonable xlim & ylim

ALLMVPC = handles.ALLMVPA;
times = ALLMVPC(iset).times;
datatype = ALLMVPC(iset).DecodingMethod; 
if strcmpi(datatype, 'SVM')
    xlim  = [min(times) max(times)];
    if ALLMVPC(iset).chance*4 > 1
        ylim = [0 1];
    else
        ylim =  [0 ALLMVPC(iset).chance*4];
        
    end
    
else
    xlim  = [min(times) max(times)];
    ylim  = [abs(min(ALLMVPC(iset).average_score))*-1.10 max(ALLMVPC(iset).average_score)*1.10];
    
end

%ylim = str2num(get(handles.edit_ylim, 'String' ));
%xlim = str2num(get(handles.edit_xlim, 'String' ));
mplotdata(hObject, handles,iset, xlim, ylim)



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


% --- Executes on button press in pushbutton_addmvpc.
function pushbutton_addmvpc_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_addmvpc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%reset listbox
% handles.listbox_mvpcnames.String = [];
% handles.listbox_mvpcnames.Value = 0; 
% set(handles.listbox_mvpcnames,'String',{'new mvpcset'});
% set(handles.edit_file,'String','0');

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
        preindex = 0; 
        for i=1:(numel(handles.fulltext) - 1)
            
            
            %currline = get(handles.listbox_mvpcnames, 'Value');
            fullname = handles.listbox_mvpcnames.String{i}; 
            fprintf('Loading %s\n', fullname);
            L   = load(fullname, '-mat');
            MVPC = L.MVPC;
            %             if i == 1
            %                 BEST = L.BEST;
            %             else
            %                 BEST(i) = L.BEST;
            %             end
        
        if i == 1 
            ALLMVPC = MVPC;

        else
            ALLMVPC(i+preindex) = MVPC;

        end
        
        end
        
        %plot latest entry
         
        if isfield(ALLMVPC(end), 'DecodingMethod')
            datatype = ALLMVPC(end).DecodingMethod;
            
            if strcmpi(datatype,'SVM')
                % here, treat SEM data like ERP data
                datatype = 'SVM';
                % datatype2 = 'SEM';
            end
            
        else
            datatype = 'SVM';
        end
        
        
        if strcmpi(datatype, 'SVM')
            meamenu = 1;
        else
            meamenu = 2
        end
        
        measurearray = handles.measurearray ;
        

        
        handles.chance = 0;
        handles.stderror = 0;
        handles.alpha = {'0.10','0.20','0.30','0.40','0.50','0.60','0.70','0.80','0.90','1.0'};
        set(handles.popupmenu_alpha,'String', handles.alpha);
        set(handles.popupmenu_alpha,'Value',7);

        
        set(handles.text_measurementv, 'String', measurearray{meamenu});
        % set(handles.text_measurementv, 'Value', meamenu);
        % set(handles.text_measurementv, 'Enable', 'inactive');
        setArray = 1:length(ALLMVPC);
        
        handles.ALLMVPA     = ALLMVPC;
        %handles.binArray   = binArray;
        %handles.chanArray  = chanArray;
        handles.setArray   = setArray;
        %handles.ich        = 1;
        %handles.ibin       = 1;
        handles.iset       = setArray(end);
        %handles.orilatency = latency;
        %handles.blc        = blc;
        %handles.moption    = moption;
        %handles.tittle     = tittle;
        handles.dig        = 3;
        handles.x1         = -1.75;
        handles.x2         = 1.75;
        
        
        % ibin  = 1;
        % ich   = 1;
        iset  = setArray(end);
        times = ALLMVPC(end).times;
        if strcmpi(datatype, 'SVM')
            xlim  = [min(times) max(times)];
            if ALLMVPC(end).chance*3 > 1
                ylim = [0 1];
            else
                ylim =  [0 ALLMVPC(end).chance*3];
                
            end
            
        else
            xlim  = [0 30];
            ylim  = [0 15];
            
        end
        
        
        set(handles.edit_ylim, 'String', num2str(ylim));
        set(handles.edit_xlim, 'String', sprintf('%g %g', round(xlim)));
        
        set(handles.edit_file, 'String', num2str(iset));
        
        set(handles.checkbox_butterflyset,'Value', 0);
        set(handles.checkbox_stderror,'Value', 0);
        
        if length(setArray)==1
            set(handles.checkbox_butterflyset, 'Enable', 'off')
            %         if frdm; set(handles.edit_file, 'Enable', 'off');end
            set(handles.pushbutton_right_file, 'Enable', 'off')
            set(handles.pushbutton_left_file, 'Enable', 'off')
        else
            set(handles.checkbox_butterflyset, 'Enable', 'on')
            %         if frdm; set(handles.edit_file, 'Enable', 'off');end
            set(handles.pushbutton_right_file, 'Enable', 'on')
            set(handles.pushbutton_left_file, 'Enable', 'on')
            
        end
        handles.datatype = datatype;
        
         % Update handles structure
        guidata(hObject, handles);       
        
        mplotdata(hObject, handles, iset, xlim, ylim)
        
        
        
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
