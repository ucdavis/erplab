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

function varargout = averagerxGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @averagerxGUI_OpeningFcn, ...
    'gui_OutputFcn',  @averagerxGUI_OutputFcn, ...
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
function averagerxGUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for averagerxGUI
handles.output   = [];
handles.listname = [];
handles.indxline = 1;

try
    currdata = varargin{1};
catch
    currdata = 1;
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
    
    % Weighted average option. 1= yes, 0=no
    %wavg     = def{3};
    
    stderror   = def{4};% compute standard error
    excbound   = def{5};% exclude epochs having "boundary" events (or -99)
    compu2do   = def{6}; % 0:ERP; 1:ERP+TPS; 2:ERP+EPS; 3:ERP+BOTH
    wintype    = def{7}; % taper data with window: empty=no taper
    wintfunc   = def{8}; % taper function and (sub)window
catch
    setindex = 1;
    artcrite = 1;
    %wavg     = 1;
    stderror = 1;
    excbound = 0;
    compu2do = 0; % 0:ERP; 1:ERP+TPS; 2:ERP+EPS; 3:ERP+BOTH
    wintype  = 0; % taper data with window: 0=no taper
    wintfunc = [];
end
try
    nepochperdata = varargin{3};
catch
    nepochperdata = [];
end
try
    timelimits = round(varargin{4}*1000); % in ms
catch
    timelimits = [0 0];
end

%
% Number of current epochs per dataset
%
handles.nepochperdata = nepochperdata;
handles.currdata      = currdata;
handles.timelimits    = timelimits; % in ms

if ~iscell(artcrite)
    if isnumeric(artcrite)
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
        set(handles.edit_include_indices,'Enable', 'off')
        set(handles.pushbutton_loadlist,'Enable', 'off')
        %set(handles.pushbutton_fileorvalues,'Enable', 'off')
        set(handles.pushbutton_saveList,'Enable', 'off')
        set(handles.pushbutton_viewfile,'Enable', 'off')
        set(handles.radiobutton_usefilename, 'Enable', 'off')
        set(handles.radiobutton_useindices, 'Enable', 'off')
        set(handles.pushbutton_clearall, 'Enable', 'off')
    else % char
        va=0;vb=0;vc=0;vd=1;
        set(handles.edit_include_indices,'Enable', 'on')
        set(handles.pushbutton_loadlist,'Enable', 'on')
        %set(handles.edit_include_indices,'String', artcrite)
        %set(handles.pushbutton_fileorvalues,'Enable', 'on')
        set(handles.pushbutton_saveList,'Enable', 'on')
        set(handles.pushbutton_viewfile,'Enable', 'on')
        set(handles.radiobutton_usefilename, 'Enable', 'on')
        set(handles.radiobutton_useindices, 'Enable', 'on')
        set(handles.pushbutton_clearall, 'Enable', 'on')
    end
else
    va=0;vb=0;vc=0;vd=1;
    set(handles.edit_include_indices,'Enable', 'on')
    set(handles.pushbutton_loadlist,'Enable', 'on')
end
set(handles.edit_dataset, 'String', vect2colon(setindex,'Delimiter','off')); % exclude artifacts
set(handles.checkbox_includeALL, 'Value', va);       % exclude artifacts
set(handles.checkbox_excludeartifacts, 'Value', vb); % exclude artifacts
set(handles.checkbox_onlyartifacts, 'Value', vc);    % exclude artifacts
set(handles.checkbox_include_indices,'Value', vd)
if vd==1
    set(handles.pushbutton_epochAssistant, 'Value', 1)
    if iscell(artcrite)
        set(handles.edit_include_indices,'String', vect2colon([artcrite{:}],'Delimiter','off'))
        set(handles.radiobutton_usefilename, 'Value', 0)
        set(handles.radiobutton_useindices, 'Value', 1)
    else
        set(handles.edit_include_indices,'String', artcrite)
        set(handles.radiobutton_usefilename, 'Value', 1)
        set(handles.radiobutton_useindices, 'Value', 0)
    end
else
    set(handles.pushbutton_epochAssistant,'Enable', 'off')
end
set(handles.checkbox_SEM, 'Value', stderror); % compute standard error
set(handles.checkbox_exclude_boundary, 'Value', excbound); % exclude epochs having "boundary" events (or -99)


% 0:ERP; 1:ERP+TPS; 2:ERP+EPS; 3:ERP+BOTH
switch compu2do
    case 1
        set(handles.checkbox_Total_Power, 'Value', 1);
        set(handles.checkbox_Evoked_Power, 'Value', 0);
    case 2
        set(handles.checkbox_Total_Power, 'Value', 0);
        set(handles.checkbox_Evoked_Power, 'Value', 1);
    case 3
        set(handles.checkbox_Total_Power, 'Value', 1);
        set(handles.checkbox_Evoked_Power, 'Value', 1);
    otherwise
        set(handles.checkbox_Total_Power, 'Value', 0);
        set(handles.checkbox_Evoked_Power, 'Value', 0);
end

% compu2do = def{6}; % 0:ERP; 1:ERP+TPS; 2:ERP+EPS; 3:ERP+BOTH
if wintype && ismember(compu2do, [1 2 3]) 
    if iscell(wintfunc)
        if isempty(wintfunc)
            set(handles.checkbox_taper, 'Value', 0);
            set(handles.edit_taperfunction,'Enable', 'off')
        else
            apostr      = wintfunc{1};
            if ischar(apostr)
                set(handles.edit_taperfunction,'Enable', 'on')
                if length(wintfunc)>=2
                    apowinms    = wintfunc{2}; % epoch's time range (in ms) for applying the taper (2 values)
                    set(handles.edit_taperfunction, 'String', sprintf('''%s''  [%g %g]', apostr, apowinms));
                else
                    set(handles.edit_taperfunction, 'String', sprintf('''%s''', apostr));
                end
                set(handles.checkbox_taper, 'Value', 1);
            else
                set(handles.checkbox_taper, 'Value', 0);
                set(handles.edit_taperfunction, 'String', '!');
                set(handles.edit_taperfunction,'Enable', 'off')
            end
        end
    else  % deprecated...
        if isnumeric(wintfunc)
            if wintfunc>0
                set(handles.checkbox_taper, 'Value', 1);
                set(handles.edit_taperfunction,'Enable', 'on')
                set(handles.edit_taperfunction, 'String', 'Hanning');
            else
                set(handles.checkbox_taper, 'Value', 0);
                set(handles.edit_taperfunction,'Enable', 'off')
                set(handles.edit_taperfunction, 'String', '');
            end
        elseif ischar(wintfunc)
            set(handles.checkbox_taper, 'Value', 1);
            set(handles.edit_taperfunction,'Enable', 'on')
            set(handles.edit_taperfunction, 'String', wintfunc);
        else
            set(handles.checkbox_taper, 'Value', 0);
            set(handles.edit_taperfunction, 'String', '!!');
            set(handles.edit_taperfunction,'Enable', 'off')
        end
    end
else
    set(handles.checkbox_taper, 'Value', 0);
    set(handles.checkbox_taper,'Enable', 'off') 
    set(handles.edit_taperfunction, 'String', '');
    set(handles.edit_taperfunction,'Enable', 'off')    
end

tooltip1  = ['<html><i>Each epoch (selected for getting the ERP waveform) is transformed<br>via fast-Fourier transform (FFT) to power spectrum, and then the <br>'...
    'average across all spectra is derived.'];
tooltip2  = '<html><i>The ERP waveform is transformed via fast-Fourier transform (FFT) <br>to power spectrum.';

tooltip3  = ['<html><i>Windowing functions act on raw data to reduce the effects of the<br>leakage that occurs during an FFT of the data. Leakage amounts to<br>'...
    'spectral information from an FFT showing up at the wrong frequencies.'];

set(handles.edit_tip_totalpower, 'tooltip',tooltip1);
set(handles.edit_tip_evokedpower, 'tooltip',tooltip2);
set(handles.edit_tip_hamming, 'tooltip',tooltip3);

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   WEIGHTED AVERAGER GUI'])
set(handles.edit_dataset, 'String', num2str(currdata));

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

% UIWAIT makes averagerxGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

% -------------------------------------------------------------------------
function varargout = averagerxGUI_OutputFcn(hObject, eventdata, handles)

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
% doc pop_averager
web https://github.com/lucklab/erplab/wiki/Computing-Averaged-ERPs -browser

% -------------------------------------------------------------------------
function pushbutton_RUN_Callback(hObject, eventdata, handles)

dataset  = str2num(char(get(handles.edit_dataset, 'String')));
incALL   = get(handles.checkbox_includeALL, 'Value');
excart   = get(handles.checkbox_excludeartifacts, 'Value');
incart   = get(handles.checkbox_onlyartifacts, 'Value');
incIndx  = get(handles.checkbox_include_indices, 'Value');
excbound = get(handles.checkbox_exclude_boundary, 'Value'); % exclude epochs having boundary events

Tspectrum  = get(handles.checkbox_Total_Power, 'Value');   % total power spectrum
Espectrum  = get(handles.checkbox_Evoked_Power, 'Value');  % evoked power spectrum
iswindowed = get(handles.checkbox_taper, 'Value');       % apply a window?

if iswindowed
    winparam = get(handles.edit_taperfunction, 'string');
    [winsepa, idx] = regexp(winparam, '[a-z]\w*|[-]*\d*', 'match', 'start', 'ignorecase');
    
    if isempty(idx)
        %winparam = ''; % default parameter will be taken
        msgboxText =  ['For a taper function you must enter either ''hamming'', ''hanning'', ''blackmanharris'' or ''rectangular''.'...
            ' Also, you can add two numeric values (optional) as a (sub)window for estimating the spectra. E.g.\n''hanning'''...
            '   [-100 500]\n\nIn case you enter only two numeric values, ''hanning'' will be taken as the default taper function.'];
        title = 'ERPLAB: invalid taper type';
        errorfound(sprintf(msgboxText), title);
        return
        
    else
        switch length(idx)
            case 1
                apostrin = winsepa{1};
                apotest  = str2num(apostrin);
                if isempty(apotest)
                    winparam = lower(apostrin);
                    if ~ismember(winparam, {'hamming', 'hanning', 'blackmanharris', 'rectangular'})
                        msgboxText =  ['You must enter either ''hamming'', ''hanning'', ''blackmanharris'' or ''rectangular'''...
                            ' as a valid taper function name'];
                        title = 'ERPLAB: invalid taper type';
                        errorfound(msgboxText, title);
                        return
                    end
                else
                    msgboxText =  ['You must enter either ''hamming'', ''hanning'', ''blackmanharris'' or ''rectangular'''...
                        ' as a taper function name'];
                    title = 'ERPLAB: invalid taper type';
                    errorfound(msgboxText, title);
                    return
                end
                timelimits = handles.timelimits;
                winparam = {winparam [timelimits(1) timelimits(2)]};              
            case 2
                apostrin1 = winsepa{1};
                apostrin2 = winsepa{2};
                apotest1  = str2num(apostrin1);
                apotest2  = str2num(apostrin2);
                
                if isempty(apotest1) || isempty(apotest2)
                    msgboxText =  ['You must enter either ''hamming'', ''hanning'', ''blackmanharris'' or ''rectangular'''...
                        ' followed by two numeric values, or just only two numeric values (in which case ''hanning'''...
                        ' will be taken as the default taper function)'];
                    title = 'ERPLAB: invalid taper type';
                    errorfound(msgboxText, title);
                    return
                else
                    adj = 0;
                    timelimits = handles.timelimits;
                    if apotest1<timelimits(1)
                        apotest1 = timelimits(1);
                        adj = 1;
                    end
                    if apotest2>timelimits(2)
                        apotest2 = timelimits(2);
                        adj = 1;
                    end
                    if adj
                        fprintf('pop_averager(): Taper window has been adjusted to [%.2f %.2f] to fit data points limits', apotest1, apotest2)
                    end
                    winparam = {'hanning ' [apotest1 apotest2]};
                    
                    buttonA = 'yes, it''s fine';
                    buttonB = 'Cancel';
                    msgboxText =  ['Since a taper function was not specified for apodization, ERPLAB will use a ''hanning'' window.\n\n'...
                        '\tIs this fine?\n(otherwise cancel and specify either ''hamming'', ''hanning'', ''blackmanharris'' or ''rectangular'')'];
                    tittle  = 'ERPLAB: pop_averager(), default taper function is about to be used ';
                    button = askquest(sprintf(msgboxText), tittle, buttonA, buttonA, buttonB);
                    
                    if ~strcmpi(button, buttonA)
                        disp('User selected Cancel')
                        return
                    end
                end
            case 3
                apostrin1      = winsepa{1};
                apotest1 = str2num(apostrin1);
                if ~isempty(apotest1)
                    msgboxText =  ['When you specify 3 inputs in this window, you must enter first either ''hamming'''...
                        ', ''hanning'', ''blackmanharris'' or ''rectangular'', followed by two numeric values'];
                    title = 'ERPLAB: invalid taper type';
                    errorfound(msgboxText, title);
                    return
                end
                
                apostrin2      = winsepa{2};
                apotest2 = str2num(apostrin2);
                if isempty(apotest2)
                    msgboxText =  ['When you specify 3 inputs in this window, you should enter first either ''hamming'''...
                        ', ''hanning'', ''blackmanharris'' or ''rectangular'', followed by two numeric values'];
                    title = 'ERPLAB: invalid taper type';
                    errorfound(msgboxText, title);
                    return
                end
                
                apostrin3      = winsepa{3};
                apotest3 = str2num(apostrin3);
                if isempty(apotest3)
                    msgboxText =  ['When you specify 3 inputs in this window, you should enter first either ''hamming'''...
                        ', ''hanning'', ''blackmanharris'' or ''rectangular'', followed by two numeric values'];
                    title = 'ERPLAB: invalid taper type';
                    errorfound(msgboxText, title);
                    return
                end
                
                adj = 0;
                timelimits = handles.timelimits;
                if apotest2<timelimits(1)
                    apotest2 = timelimits(1);
                    adj = 1;
                end
                if apotest3>timelimits(2)
                    apotest3 = timelimits(2);
                    adj = 1;
                end
                if adj
                    fprintf('pop_averager(): Taper window has been adjusted to [%.2f %.2f] to fit data points limits', apotest2, apotest3)
                end 
                winparam = {strtrim(lower(apostrin1)) [apotest2 apotest3]};
            otherwise
                msgboxText =  ['You must enter either ''hamming'', ''hanning'', ''blackmanharris'' or ''rectangular'''...
                        ' followed by TWO numeric values, or just only two numeric values (in which case ''hanning'''...
                        ' will be taken as the default taper function)'];
                title = 'ERPLAB: invalid taper function''s parameters';
                errorfound(msgboxText, title);
                return
        end
    end
else
    winparam = '';
end

if Tspectrum==0 && Espectrum==0 % do ERP
    compu2do = 0;
elseif Tspectrum==0 && Espectrum==1 % do ERP + evoked spectrum
    compu2do = 2;
elseif Tspectrum==1 && Espectrum==0
    compu2do = 1; % do ERP + total spectrum
elseif Tspectrum==1 && Espectrum==1
    compu2do = 3; % do ERP + total spectrum + evoked spectrum
else
    error('algo salio mal...')
end

%compu2do = answer{6}; % 0:ERP; 1:ERP+TPS; 2:ERP+EPS; 3:ERP+BOTH
%wintype  = answer{7}; % taper data with window: 0:no; 1:yes

if incALL && ~excart && ~incart && ~incIndx % average all (good and bad trials)
    artcrite = 0;
    disp('averaging all (good and bad epochs)...')
elseif ~incALL && excart && ~incart && ~incIndx % average only good trials
    artcrite = 1;
    disp('averaging only good epochs...')
elseif ~incALL && ~excart && incart && ~incIndx % average only bad trials! (be cautios!)
    artcrite = 2;
    disp('averaging only bad epochs!!!...')
elseif ~incALL && ~excart && ~incart && incIndx
    if  isempty(get(handles.edit_include_indices, 'String'))
        msgboxText =  'You have to specify either a set of epoch''s index values or a filename.';
        title = 'ERPLAB: averagerxGUI unspecified input';
        errorfound(sprintf(msgboxText), title);
        return
    end
    if  ~get(handles.radiobutton_useindices, 'Value') && ~get(handles.radiobutton_usefilename, 'Value')
        msgboxText =  'You have to specify wheter you will use epoch''s index values\n or a text file containing them.';
        title = 'ERPLAB: averagerxGUI unspecified input';
        errorfound(sprintf(msgboxText), title);
        return
    end
    
    %
    % epochs' indices
    %
    [tf, epochArray] = getEpochIndices(hObject, eventdata, handles);
    
    if  ~get(handles.radiobutton_usefilename, 'Value') && size(epochArray,1)>1
        if isempty(handles.listname)
            msgboxText =  ['Epoch indices for multiple datasets were specified.\n'...
                'So, please save the list and select "use filename" instead.'];
        else
            msgboxText =  ['Epoch indices for multiple datasets were specified.\n'...
                'So, please select "use filename" instead.'];
        end
        title = 'ERPLAB: averagerxGUI, List too large';
        errorfound(sprintf(msgboxText), title);
        return
    end
    if  size(epochArray,1)~=1 && (size(epochArray,1)~= length(dataset))
        
        msgboxText =  ['Epoch indices for %g datasets were found.\n'...
            'However, you specified %g datasets to be averaged... '];
        title = 'ERPLAB: averagerxGUI, List too large';
        errorfound(sprintf(msgboxText, size(epochArray,1), length(dataset)) , title);
        return
    end
    if tf==1 % error found
        msgboxText =  ['Sorry, this is not a valid filename.\n'...
            'Be sure that the expression gives you the range of indices you expect\n.'...
            'You may practice at command window first.'];
        title = 'ERPLAB: averagerxGUI few inputs';
        errorfound(sprintf(msgboxText), title);
        return
    end
    if tf==2 % error found
        msgboxText =  ['Epoch indices must be real positive integers.\n'...
            'Be sure that the expression gives you the range of indices you expect\n.'...
            'You may practice at command window first.'];
        title = 'ERPLAB: averagerxGUI few inputs';
        errorfound(sprintf(msgboxText), title);
        return
    end
    if tf==3 % error found
        msgboxText =  ['Repeated indices were found!\n'...
            'Be sure that the expression gives you the range of indices you expect\n.'...
            'You may practice at command window first.'];
        title = 'ERPLAB: averagerxGUI few inputs';
        errorfound(sprintf(msgboxText), title);
        return
    end
    if tf==10 % error found
        msgboxText =  '%s does not exist.';
        title = 'ERPLAB: averagerxGUI';
        errorfound(sprintf(msgboxText, epochArray), title);
        return
    end
    
    nepochperdata = handles.nepochperdata;
    dataindx      = str2num(get(handles.edit_dataset,'String'));
    
    if isempty(dataindx)
        msgboxText = 'You must specify valid dataset index(ices) first.\n';
        title = 'ERPLAB: averagerxGUI few inputs';
        errorfound(sprintf(msgboxText), title);
        return
    end
    if isnumeric(epochArray)
        if max(epochArray)>min(nepochperdata(dataindx))
            fprintf('\n\nDetail:\n')
            for j=1:length(dataindx)
                fprintf('dataset %g has %g epochs.\n', dataindx(j), nepochperdata(dataindx(j)))
            end
            fprintf('\n\n')
            
            msgboxText =  ['Unfortunately, some of your specified datasets\n'...
                'have less epochs than what you are indexing here.\n\n'...
                '(See command window for details)'];
            title = 'ERPLAB: averagerxGUI few inputs';
            errorfound(sprintf(msgboxText), title);
            return
        end
        artcrite = {epochArray};
    else
        artcrite = epochArray;
    end
    
    disp('averaging only specified epochs...')
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
    stderror = get(handles.checkbox_SEM, 'Value');
    handles.output = {dataset, artcrite, wavg, stderror, excbound, compu2do, iswindowed, winparam};
    
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
    set(handles.checkbox_include_indices,'Value',0)
    set(handles.edit_include_indices,'Enable', 'off')
    set(handles.pushbutton_epochAssistant,'Enable', 'off')
    set(handles.pushbutton_loadlist,'Enable', 'off')
    %set(handles.pushbutton_fileorvalues,'Enable', 'off')
    set(handles.pushbutton_saveList,'Enable', 'off')
    set(handles.pushbutton_viewfile,'Enable', 'off')
    set(handles.radiobutton_usefilename, 'Enable', 'off')
    set(handles.radiobutton_useindices, 'Enable', 'off')
    set(handles.pushbutton_clearall, 'Enable', 'off')
else
    set(handles.checkbox_includeALL,'Value',1)
end

% -------------------------------------------------------------------------
function checkbox_excludeartifacts_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
    set(handles.checkbox_includeALL,'Value',0)
    set(handles.checkbox_onlyartifacts,'Value',0)
    set(handles.checkbox_include_indices,'Value',0)
    set(handles.edit_include_indices,'Enable', 'off')
    set(handles.pushbutton_epochAssistant,'Enable', 'off')
    set(handles.pushbutton_loadlist,'Enable', 'off')
    %set(handles.pushbutton_fileorvalues,'Enable', 'off')
    set(handles.pushbutton_saveList,'Enable', 'off')
    set(handles.pushbutton_viewfile,'Enable', 'off')
    set(handles.radiobutton_usefilename, 'Enable', 'off')
    set(handles.radiobutton_useindices, 'Enable', 'off')
    set(handles.pushbutton_clearall, 'Enable', 'off')
else
    set(handles.checkbox_excludeartifacts,'Value',1)
end

% -------------------------------------------------------------------------
function checkbox_onlyartifacts_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    set(handles.checkbox_includeALL,'Value',0)
    set(handles.checkbox_excludeartifacts,'Value',0)
    set(handles.checkbox_include_indices,'Value',0)
    set(handles.edit_include_indices,'Enable', 'off')
    set(handles.pushbutton_epochAssistant,'Enable', 'off')
    set(handles.pushbutton_loadlist,'Enable', 'off')
    %set(handles.pushbutton_fileorvalues,'Enable', 'off')
    set(handles.pushbutton_saveList,'Enable', 'off')
    set(handles.pushbutton_viewfile,'Enable', 'off')
    set(handles.radiobutton_usefilename, 'Enable', 'off')
    set(handles.radiobutton_useindices, 'Enable', 'off')
    set(handles.pushbutton_clearall, 'Enable', 'off')
else
    set(handles.checkbox_onlyartifacts,'Value',1)
end

% -------------------------------------------------------------------------
function checkbox_SEM_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function checkbox_include_indices_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    set(handles.checkbox_includeALL,'Value',0)
    set(handles.checkbox_excludeartifacts,'Value',0)
    set(handles.checkbox_onlyartifacts,'Value',0)
    set(handles.edit_include_indices,'Enable', 'on')
    set(handles.pushbutton_epochAssistant,'Enable', 'on')
    set(handles.pushbutton_loadlist,'Enable', 'on')
    %set(handles.pushbutton_fileorvalues,'Enable', 'on')
    set(handles.pushbutton_saveList,'Enable', 'on')
    set(handles.pushbutton_viewfile,'Enable', 'on')
    set(handles.radiobutton_usefilename, 'Enable', 'on')
    set(handles.radiobutton_useindices, 'Enable', 'on')
    set(handles.pushbutton_clearall, 'Enable', 'on')
else
    set(handles.checkbox_include_indices,'Value',1)
end

% -------------------------------------------------------------------------
function edit_include_indices_Callback(hObject, eventdata, handles)

linein = get(handles.edit_include_indices,'String');

if isempty(linein)
    %msgboxText = [ 'You must specify either a set of epoch indices,\n'...
    %      'or a valid filename.'];
    %title = 'ERPLAB: averagerxGUI few inputs';
    %errorfound(sprintf(msgboxText), title);
    set(handles.radiobutton_usefilename,'Value', 0)
    set(handles.radiobutton_useindices,'Value', 0)
    return
else
    cleanupindx(hObject, eventdata, handles)
    linein = get(handles.edit_include_indices,'String');
end

% [pathstr, name, ext] = fileparts(linein(1,:));

w = str2num(linein(1,:));

if isempty(w)
    set(handles.radiobutton_usefilename,'Value', 1)
    set(handles.radiobutton_useindices,'Value', 0)
else
    set(handles.radiobutton_usefilename,'Value', 0)
    set(handles.radiobutton_useindices,'Value', 1)
end
linein = char(strtrim(cellstr(linein)));
set(handles.edit_include_indices,'String', linein);

drawnow
pause(0.2)
return

%
% if isempty(pathstr) && isempty(ext)
%       if isempty(lispath)
%             listname = fullfile(cd, listname);
%       end
% end
% if isempty(lispath)
%       listname = fullfile(cd, listname);
% end

% a = get(handles.radiobutton_usefilename,'Value');
% b = get(handles.radiobutton_useindices,'Value');
%
% if isempty(pathstr) && isempty(ext) && (a || (~a && ~b))
%       set(handles.radiobutton_useindices,'Value', 1)
% elseif ~isempty(pathstr) && ~isempty(ext) && (a || (~a && ~b))
%       set(handles.radiobutton_usefilename,'Value', 1)
% end

% % %
% % % Just for testing
% % %
% % [tf epochArray] = getEpochIndices(hObject, eventdata, handles);
% % if tf==1 % error found
% %       msgboxText =  ['Sorry, this is not a valid filename.\n'...
% %             'Be sure that the expression gives you the range of indices you expect\n.'...
% %             'You may practice at command window first.'];
% %       title = 'ERPLAB: averagerxGUI few inputs';
% %       errorfound(sprintf(msgboxText), title);
% %       return
% % end
% % if tf==2 % error found
% %       msgboxText =  ['Epoch indices must be real positive integers.\n'...
% %             'Be sure that the expression gives you the range of indices you expect\n.'...
% %             'You may practice at command window first.'];
% %       title = 'ERPLAB: averagerxGUI few inputs';
% %       errorfound(sprintf(msgboxText), title);
% %       return
% % end
% % if tf==3 % error found
% %       msgboxText =  ['Repeated indices were found!\n'...
% %             'Be sure that the expression gives you the range of indices you expect\n.'...
% %             'You may practice at command window first.'];
% %       title = 'ERPLAB: averagerxGUI few inputs';
% %       errorfound(sprintf(msgboxText), title);
% %       return
% % end
% % nepochperdata = handles.nepochperdata;
% % dataindx      = str2num(get(handles.edit_dataset,'String'));
% % if isempty(dataindx)
% %       msgboxText = 'You must specify valid dataset index(ices) first.\n';
% %       title = 'ERPLAB: averagerxGUI few inputs';
% %       errorfound(sprintf(msgboxText), title);
% %       return
% % end
% % if max(epochArray)>min(nepochperdata(dataindx))
% %       fprintf('\n\nDetail:\n')
% %       for j=1:length(dataindx)
% %             fprintf('dataset %g has %g epochs.\n', dataindx(j), nepochperdata(dataindx(j)))
% %       end
% %       fprintf('\n\n')
% %
% %       msgboxText =  ['Unfortunately, some of your specified datasets\n'...
% %               'have less epochs than what you are indexing here.\n\n'...
% %               '(See command window for details)'];
% %       title = 'ERPLAB: averagerxGUI few inputs';
% %       errorfound(sprintf(msgboxText), title);
% %       return
% % end



% -------------------------------------------------------------------------
function checkbox_Total_Power_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    set(handles.checkbox_taper,'Enable', 'on')
else
    if ~get(handles.checkbox_Evoked_Power,'Value')
        set(handles.checkbox_taper,'Value', 0)
        set(handles.checkbox_taper,'Enable', 'off')
        set(handles.edit_taperfunction,'Enable', 'off')
    end
end

% -------------------------------------------------------------------------
function checkbox_Evoked_Power_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    set(handles.checkbox_taper,'Enable', 'on')
else
    if ~get(handles.checkbox_Total_Power,'Value')
        set(handles.checkbox_taper,'Value', 0)
        set(handles.checkbox_taper,'Enable', 'off')
        set(handles.edit_taperfunction,'Enable', 'off')
    end
end

% -------------------------------------------------------------------------
function checkbox_taper_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    set(handles.edit_taperfunction,'Enable', 'on')   
    if isempty(get(handles.edit_taperfunction, 'String'))        
        timelimits = handles.timelimits;
        set(handles.edit_taperfunction, 'String', sprintf('''hanning''  [%g  %g]', timelimits(1), timelimits(2)));
    end
else
    set(handles.edit_taperfunction,'Enable', 'off')
end

% -------------------------------------------------------------------------
function edit_taperfunction_Callback(hObject, eventdata, handles)


% -------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function edit_taperfunction_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function [tf epochArray] = getEpochIndices(hObject, eventdata, handles)
tf = 0; % no problems
linein = get(handles.edit_include_indices,'String');

if isempty(linein)
    msgboxText = [ 'You must specify either a set of epoch indices,\n'...
        'or a valid filename.'];
    title = 'ERPLAB: averagerxGUI few inputs';
    errorfound(sprintf(msgboxText), title);
else
    cleanupindx(hObject, eventdata, handles)
    linein = get(handles.edit_include_indices,'String');
end

E2 = get(handles.edit_include_indices, 'String');

s = cellstr(E2);
f = regexp(s, ' ', 'split'); % problema con esto '10' '40;' '100:200'
f = [f{:}]';
f = f(~cellfun(@isempty, f));
epochArray = readepochindx(f, 1);

if ~isempty(epochArray)
    %
    % Tests positive integer
    %
    N =  size(epochArray,1);
    for k=1:N
        epindx = [epochArray{k,:}];
        b = epindx-floor(epindx);
        if nnz(b)>0 || min(epindx)<1
            tf=2; % non integer  or not positive index
            break
        end
        
        %
        % Tests uniqueness
        %
        c = length(unique_bc2(epindx));
        if c~=length(epindx)
            tf=3; % not unique indices
            break
        end
    end
else
    epochArray = char(linein);
    if exist(epochArray, 'file')==0
        tf=10;
        return
    end
end
return

% -------------------------------------------------------------------------
function cleanupindx(hObject, eventdata, handles)

set(handles.edit_include_indices, 'Enable', 'on');
E2 = get(handles.edit_include_indices, 'String');
if isempty(E2)
    return
end
s = cellstr(E2);
f = regexp(s, ';', 'split'); % problema con esto '10' '40;' '100:200'
f = [f{:}]';
f = f(~cellfun(@isempty, f));
N = size(f,1);
if N==1
    return
end
ystr2 = E2;
% set(handles.edit_include_indices, 'String', '')
for k=1:N
    ystr1 = f{k};
    if k==1
        ystr2 = sprintf('%s\n;\n', ystr1);
    else
        ystr2 = sprintf('%s%s\n;\n', ystr2, ystr1);
    end
end
% w = char(cellstr(ystr2))
set(handles.edit_include_indices, 'String', ystr2)
% drawnow

% -------------------------------------------------------------------------
function edit_include_indices_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function pushbutton_epochAssistant_Callback(hObject, eventdata, handles)

nepochperdata = handles.nepochperdata;
setindex      = str2num(get(handles.edit_dataset,'string'));

%
% call assistant's GUI
%
answer = epoch4avgGUI(nepochperdata, setindex);
if isempty(answer)
    disp('User selected Cancel')
    return
end
ALLEEG        = evalin('base', 'ALLEEG');

%need to fix this later
%     case 'amap'
%         nepoch =
if strcmpi(answer{1}, 'amap')
    nepoch='amap';
else
    nepoch=answer{1};
end
switch answer{2}
    case 0
        artifact='all';
    case 1
        artifact='good';
    case 2
        artifact='bad';
end
switch answer{3}
    case 0
        catching='sequential';
    case 1
        catching='random';
    case 2
        catching='odd';
    case 3
        catching='even';
    case 4
        catching='prime';
end
switch answer{4}
    case 0
        indexing='absolute';
    case 1
        indexing='relative';
end
if strcmp(answer{5}, 'any')
    episode='any';
else
    episode=answer{5};
end
switch answer{6}
    case 0
        instance='first';
    case 1
        instance='anywhere';
    case 2
        instance='last';
end
switch answer{7}
    case 1
        warning='on';
    case 2
        warning='off';
end

%%%%%%% change dataset and bin

old_epochs_n = size(ALLEEG(setindex).epoch,2);
old_epochs = 1:old_epochs_n;

epocharray = getepochindex6(ALLEEG, 'Dataset', setindex, 'Bin', 1:ALLEEG(setindex(1)).EVENTLIST.nbin, 'Nepoch', nepoch,...
    'Artifact', artifact, 'Catching', catching, 'Indexing', indexing, 'Episode', episode, 'Instance', instance, 'Warning', warning);

old_epochs(ismember(old_epochs,epocharray{:}))=[];
other_epochs{:}=old_epochs;

% epocharray = cell2mat(epocharray);
%
% Call GUI
%
answer = savemyeindicesGUI;

if isempty(answer)
    disp('User selected Cancel')
    return
end

option   = answer{1};
filename = answer{2};
overw    = answer{3};
acolon   = answer{4};
openfile = answer{5};
save_others = answer{6};

if size(filename) <= 1
    filename = [pwd, '\saved_epochs.txt'];
end

if save_others
    wepoch2file([filename, '_non-selected.txt'],other_epochs,acolon,overw);
end

if option==0 % to editor
    
    %       epochArraystr = vect2colon(epocharray, 'Delimiter', 'off');
    nrow = size(epocharray, 1)
    s = ''; formstr   = '%s ';
    
    for k=1:nrow
        
        numstring = vect2colon([epocharray{k,:}], 'Delimiter', 'off');
        numcell   = regexp(numstring, '\s*','split');
        numcell   = numcell(~cellfun(@isempty, numcell))
        ncell     = length(numcell)
        m=1;
        while m<=ncell
            s = sprintf('%s %s ', s, numcell{m});
            %if mod(m,10)==0
            %      s = [s sprintf('\n')];
            %end
            m=m+1;
        end
        %if mod(m-1,10)==0
        %      s = [s sprintf(';\n')];
        %else
        s = sprintf('%s\n;\n', s);
        %end
    end
    
    s
    
    set(handles.edit_include_indices, 'String', s)
    set(handles.radiobutton_usefilename, 'Value', 0)
    set(handles.radiobutton_useindices, 'Value', 1)
elseif option==1 % to workspace
    assignin('base', 'epocharray', epocharray);
    disp('NOTE: A variable called epocharray has been sent to the workspace.')
    fprintf('%d ', epocharray);
    fprintf('\n');
elseif option==2       % to file
    wepoch2file(filename, epocharray, acolon, overw) % writes epoch indices into a file
    set(handles.edit_include_indices, 'String', filename)
    if openfile
        open(filename);
    end
    
    set(handles.radiobutton_usefilename, 'Value', 1)
    set(handles.radiobutton_useindices, 'Value', 0)
    
    handles.listname = filename;
    % Update handles structure
    guidata(hObject, handles);
    
else
    return
end

%--------------------------------------------------------------------------
function pushbutton_loadlist_Callback(hObject, eventdata, handles)

[listname, lispath] = uigetfile({  '*.txt','Text File (*.txt)'; ...
    '*.*',  'All Files (*.*)'}, ...
    'Select an edited list', ...
    'MultiSelect', 'off');

if isempty(lispath)
    listname = fullfile(cd, listname);
end
if isequal(listname,0)
    disp('User selected Cancel')
    return
else
    fullname = fullfile(lispath, listname);
    disp(['For epoch list user selected  <a href="matlab: open(''' fullname ''')">' fullname '</a>'])
    %
    % open file containing epoch indices
    %
    x = readepochindx(fullname)   ;
    nx = length(x);
    ystr1 = '';
    
    for k=1:nx
        y = [x{k,:}];
        ystr1 = vect2colon(y, 'Delimiter', 'off');
        if k==1
            ystr2 = sprintf('%s\n;\n', ystr1);
        else
            ystr2 = sprintf('%s%s\n;\n', ystr2, ystr1);
        end
    end
    
    set(handles.edit_include_indices, 'String', ystr2)
    [pathstr, name, ext] = fileparts(ystr2);
    a = get(handles.radiobutton_usefilename,'Value');
    b = get(handles.radiobutton_useindices,'Value');
    
    if isempty(pathstr) && isempty(ext) && (a || (~a && ~b))
        set(handles.radiobutton_useindices,'Value', 1)
        set(handles.radiobutton_usefilename,'Value', 0)
    elseif ~isempty(pathstr) && ~isempty(ext) && (a || (~a && ~b))
        set(handles.radiobutton_usefilename,'Value', 1)
        set(handles.radiobutton_useindices,'Value', 0)
    end
    
    handles.listname = fullname;
    % Update handles structure
    guidata(hObject, handles);
end

%--------------------------------------------------------------------------
function radiobutton_usefilename_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    listname = handles.listname;
    %listname = get(handles.edit_include_indices, 'String');
    if isempty(listname)
        msgboxText =  'Index values have not been saved yet.\nSave the list first.';
        title = 'ERPLAB: averagerxGUI listname was not found';
        errorfound(sprintf(msgboxText), title);
        set(handles.radiobutton_usefilename, 'Value', 0)
        return
    end
    
    [chk] = checklistandfile(listname, handles);
    
    if chk==0
        msgboxText =  'Index values have been modified.\nSave the list first.';
        title = 'ERPLAB: averagerxGUI listname was not found';
        errorfound(sprintf(msgboxText), title);
        set(handles.radiobutton_useindices, 'Value', 1)
        set(handles.radiobutton_usefilename, 'Value', 0)
        return
    end
    
    set(handles.edit_include_indices, 'String', listname)
    set(handles.radiobutton_useindices, 'Value', 0)
else
    set(handles.radiobutton_usefilename, 'Value', 1)
end

%--------------------------------------------------------------------------
function radiobutton_useindices_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    %listname = handles.listname;
    listname = get(handles.edit_include_indices, 'String');
    if isempty(listname)
        %msgboxText =  'Index values have not been saved yet.\nSave the list first.';
        %title = 'ERPLAB: averagerxGUI listname was not found';
        %errorfound(sprintf(msgboxText), title);
        %set(handles.radiobutton_useindices, 'Value', 0)
        set(handles.radiobutton_usefilename, 'Value', 0)
        return
    end
    if size(listname,1)>1
        msgboxText =  'Invalid filename.';
        title = 'ERPLAB: averagerxGUI';
        errorfound(sprintf(msgboxText), title);
        set(handles.radiobutton_useindices, 'Value', 0)
        set(handles.radiobutton_usefilename, 'Value', 1)
        return
    end
    listname = strtrim(listname);
    if exist(listname,'file')==0
        msgboxText =  '%s does not exist.';
        title = 'ERPLAB: averagerxGUI file was not found';
        errorfound(sprintf(msgboxText, listname), title);
        set(handles.radiobutton_useindices, 'Value', 0)
        set(handles.radiobutton_usefilename, 'Value', 1)
        return
    end
    EPINDX1 = readepochindx(listname);
    nx = size(EPINDX1,1);
    ystr1 = '';
    
    for k=1:nx
        y = [EPINDX1{k,:}];
        ystr1 = vect2colon(y, 'Delimiter', 'off');
        if k==1
            ystr2 = sprintf('%s\n;\n', ystr1);
        else
            ystr2 = sprintf('%s%s\n;\n', ystr2, ystr1);
        end
    end
    
    set(handles.edit_include_indices, 'String', ystr2)
    set(handles.radiobutton_usefilename, 'Value', 0)
else
    set(handles.radiobutton_useindices, 'Value', 1)
end

%--------------------------------------------------------------------------
function pushbutton_saveList_Callback(hObject, eventdata, handles)

cleanupindx(hObject, eventdata, handles)
E2 = get(handles.edit_include_indices, 'String');
if isempty(E2)
    disp('Editor is empty...')
    return
end
s = cellstr(E2);
f = regexp(s, ' ', 'split');
f = [f{:}]';
f = f(~cellfun(@isempty, f));
epochArray = readepochindx(f, 1);
%
% Save OUTPUT file
%
[fname, pathname] = uiputfile({'*.txt', 'Text file (*.txt)';...
    '*.*'  , 'All Files (*.*)'},'Save Output file as',...
    '*.txt');
if isequal(fname,0)
    disp('User selected Cancel')
    return
else
    set(handles.radiobutton_useindices, 'Value', 0)
    set(handles.radiobutton_usefilename, 'Value', 1)
    wepoch2file(fullfile(pathname, fname), epochArray, 1, 1) % writes epoch indices into a file
    set(handles.edit_include_indices,'String', fullfile(pathname, fname));
    
    handles.listname = fullfile(pathname, fname);
    % Update handles structure
    guidata(hObject, handles);
    
    disp(['To save list of epoch indices, user selected ', fullfile(pathname, fname)])
end

% if openfile
%       open(filename);
% end

%--------------------------------------------------------------------------
function pushbutton_viewfile_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function [chk EPINDX2] = checklistandfile(listname, handles)
chk = 1; % no problems by default
EPINDX1 = readepochindx(listname);
E2 = get(handles.edit_include_indices, 'String');
s = cellstr(E2);
f = regexp(s, ' ', 'split');
f = [f{:}]';
f = f(~cellfun(@isempty, f));
EPINDX2 = readepochindx(f, 1);

if size(EPINDX1,1)~=size(EPINDX2,1) || size(EPINDX1,2)~=size(EPINDX2,2) || isempty(EPINDX1) || isempty(EPINDX2)
    chk = 0; % error, do not pass
    return
end
N = size(EPINDX1,1);
for k=1:N
    a = length([EPINDX1{k,:}]);
    b = length([EPINDX2{k,:}]);
    if a~=b
        chk = 0; % error, do not pass
        break
    end
end
if chk==0
    return
end
for k=1:N
    a = sort([EPINDX1{k,:}]);
    b = sort([EPINDX2{k,:}]);
    c = ismember_bc2(a,b);
    d = find(c==0, 1);
    if ~isempty(d)
        chk = 0; % error, do not pass
        break
    end
end

%--------------------------------------------------------------------------
function pushbutton_clearall_Callback(hObject, eventdata, handles)

if isempty(get(handles.edit_include_indices, 'String'))
    set(handles.edit_include_indices, 'String', ''); % just for cleaning white spaces...
    return
end
question = 'Are you sure you want to clean the editor?';
title    = 'AVERAGER: Clear editor';
button = askquest(sprintf(question), title);

if ~strcmpi(button,'yes')
    disp('User selected Cancel')
    return
else
    set(handles.edit_include_indices, 'String', '');
    set(handles.radiobutton_useindices, 'Value', 0)
    set(handles.radiobutton_usefilename, 'Value', 0)
end

%--------------------------------------------------------------------------
function checkbox_exclude_boundary_Callback(hObject, eventdata, handles)

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
