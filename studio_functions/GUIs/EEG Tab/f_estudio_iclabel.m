%%This function is to change the title of inputdlg3 so that the users are
%%easy to know which eegset that they are seeing when using ICLabel


% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Sep. 2023


function EEG = f_estudio_iclabel(EEG,CURRENTEEGSET)

if nargin < 1
    help f_estudio_iclabel;
    return;
end;

if nargin < 2
    CURRENTEEGSET = 1; % default
end;

%%Label independent components using ICLabel

try
    icversion=inputdlg3('prompt', {'Select which icversion of ICLabel to use:', 'Default (recommended)|Lite|Beta'}, ...
        'style', {'text', 'popupmenu'}, ...
        'default', {[], 1}, ...
        'title', ['eegset',32,num2str(CURRENTEEGSET),': ICLabel']);
    icversion = icversion{2};
catch
    icversion = 0;
end
switch icversion
    case 0
        icversion = 'default';
    case 1
        icversion = 'default';
    case 2
        icversion = 'lite';
    case 3
        icversion = 'beta';
end
EEG = iclabel(EEG, icversion);%%somthing goes wrong
LASTCOM1 = ['EEG = pop_iclabel(EEG, ''' icversion ''');'];
EEG = eegh(LASTCOM1, EEG);
fprintf([LASTCOM1,'\n']);


%%----------------See  common properties of many ICs-----------------------
typecomp = 0;
PLOTPERFIG = 35;
promptstr    = { fastif(typecomp,'Channel indices to plot:','Component indices to plot:') ...
    'Spectral options (see spectopo() help):','Erpimage options (see erpimage() help):' ...
    [' Draw events over scrolling ' fastif(typecomp,'channel','component') ' activity']};
if typecomp
    inistr       = { ['1:' int2str(length(EEG.chanlocs))] ['''freqrange'', [2 ' num2str(min(80, EEG.srate/2)) ']'] '' 1};
else
    inistr       = { ['1:' int2str(size(EEG.icawinv, 2))] ['''freqrange'', [2 ' num2str(min(80, EEG.srate/2)) ']'] '' 1};
end
stylestr     = {'edit', 'edit', 'edit', 'checkbox'};

% labels when available
if ~typecomp && isfield(EEG.etc, 'ic_classification')
    classifiers = fieldnames(EEG.etc.ic_classification);
    if ~isempty(classifiers)
        iclabel_ind = find(strcmpi(classifiers, 'ICLabel'));
        promptstr = [promptstr {classifiers}];
        inistr = [inistr {fastif(isempty(iclabel_ind), 1, iclabel_ind)}];
        stylestr = [stylestr {'popupmenu'}];
    end
end

try
    result       = inputdlg3( 'prompt', promptstr,'style', stylestr, ...
        'default',  inistr, 'title', ['eegset',32,num2str(CURRENTEEGSET),': View comp. properties -- pop_viewprops']);
catch
    result = [];
end
if size( result, 1 ) == 0
    return; end

chanorcomp   = eval( [ '[' result{1} ']' ] );
spec_opt     = eval( [ '{' result{2} '}' ] );
erp_opt     = eval( [ '{' result{3} '}' ] );

scroll_event     = result{4};
if ~typecomp && isfield(EEG.etc, 'ic_classification') && ~isempty(classifiers)
    classifiers = fieldnames(EEG.etc.ic_classification);
    classifier_name = classifiers{result{5}};
end

if length(chanorcomp) > PLOTPERFIG
    ButtonName=questdlg2(strvcat(['More than ' int2str(PLOTPERFIG) fastif(typecomp,' channels',' components') ' so'],...
        'this function will pop-up several windows'), 'Confirmation', 'Cancel', 'OK','OK');
    if  ~isempty( strmatch(lower(ButtonName), 'cancel')), return; end;
end;
if ~exist('ICLabel','dir') && ~exist('eegplugin_iclabel', 'file')
    fprintf(2, 'Warning: ICLabel default plugin missing (probably due to downloading zip file from Github). Install manually.\n');
    EEG = [];
    return;
end
try
    LASTCOM1 = pop_viewprops( EEG, 0, chanorcomp, spec_opt, erp_opt, scroll_event, classifier_name);
catch
    pathName = which ('eegplugin_iclabel');
    pathName = pathName(1:findstr(pathName,'eegplugin_iclabel.m')-1);
    % add all ERPLAB subfolders
    addpath(genpath(pathName));
    try
        LASTCOM1 = pop_viewprops( EEG, 0, chanorcomp, spec_opt, erp_opt, scroll_event, classifier_name);
    catch
        EEG = [];
    end
end
EEG = eegh(LASTCOM1, EEG);
fprintf([LASTCOM1,'\n']);
 eegh(LASTCOM1);

end




%%---------This subfunction is copied from the function "pop_iclabel"------
%%---------in eeglab. Please update this if there is any changes in--------
%%---------the original function-------------------------------------------

function [result, userdat, strhalt, resstruct] = inputdlg3( varargin)

if nargin < 2
    help inputdlg3;
    return;
end;

% check input values
% ------------------
[opt addopts] = finputcheck(varargin, { 'prompt'  'cell'  []   {};
    'style'   'cell'  []   {};
    'default' 'cell'  []   {};
    'tag'     'cell'  []   {};
    'tooltip','cell'  []   {}}, 'inputdlg3', 'ignore');
if isempty(opt.prompt),  error('The ''prompt'' parameter must be non empty'); end;
if isempty(opt.style),   opt.style = cell(1,length(opt.prompt)); opt.style(:) = {'edit'}; end;
if isempty(opt.default), opt.default = cell(1,length(opt.prompt)); opt.default(:) = {0}; end;
if isempty(opt.tag),     opt.tag = cell(1,length(opt.prompt)); opt.tag(:) = {''}; end;

% creating GUI list input
% -----------------------
uilist = {};
uigeometry = {};
outputind  = ones(1,length(opt.prompt));
for index = 1:length(opt.prompt)
    if strcmpi(opt.style{index}, 'edit')
        uilist{end+1} = { 'style' 'text' 'string' opt.prompt{index} };
        uilist{end+1} = { 'style' 'edit' 'string' opt.default{index} 'tag' opt.tag{index} 'tooltip' opt.tag{index}};
        uigeometry{index} = [2 1];
    else
        uilist{end+1} = { 'style' opt.style{index} 'string' opt.prompt{index} 'value' opt.default{index} 'tag' opt.tag{index} 'tooltip' opt.tag{index}};
        uigeometry{index} = [1];
    end;
    if strcmpi(opt.style{index}, 'text')
        outputind(index) = 0;
    end;
end;

w = warning('off', 'MATLAB:namelengthmaxexceeded');
[tmpresult, userdat, strhalt, resstruct] = inputgui('uilist', uilist,'geometry', uigeometry, addopts{:});
warning(w.state, 'MATLAB:namelengthmaxexceeded') %  warning suppression added by luca
result = cell(1,length(opt.prompt));
result(find(outputind)) = tmpresult;
end
