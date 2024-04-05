% PURPOSE:  pop_duplicateeg.m
%           duplicate ERPset
%

% FORMAT:
% [EEG, erpcom] = pop_duplicateeg( EEG, 'ChanArray',ChanArray,...
%         'Saveas', 'off', 'History', 'gui');

% Inputs:
%
%EEG           -EEG structure
%ChanArray   -index(es) of channels




% *** This function is part of ERPLAB Studio ***
% Author: Guanghui Zhang & Steven Luck
% ghzhang@ucdavis.edu, sjluck@ucdavis.edu
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Dec. 2024




function [EEG, erpcom] = pop_duplicateeg(EEG, varargin)
erpcom = '';

if nargin < 1
    help pop_duplicateeg
    return
end
if isempty(EEG)
    msgboxText =  'Cannot duplicate an empty EEGset';
    title = 'ERPLAB: pop_duplicateeg() error';
    errorfound(msgboxText, title);
    return
end
if isempty(EEG(1).data)
    msgboxText =  'Cannot duplicate an empty EEGset';
    title = 'ERPLAB: pop_duplicateeg() error';
    errorfound(msgboxText, title);
    return
end



if length(EEG)>1
    msgboxText =  'Cannot duplicate multiple EEGsets!';
    title = 'ERPLAB: pop_duplicateeg() error';
    errorfound(msgboxText, title);
    return
end
if nargin==1
    def   = erpworkingmemory('pop_duplicateeg');
    if isempty(def)
        def = {[]};
    end
    ChanArray =def{1};
    
    def =  f_ERP_duplicate(EEG,ChanArray);
    if isempty(def)
        return;
    end
    ChanArray = def{1};
    erpworkingmemory('pop_duplicateeg',def);
    %
    % Somersault
    %
    [EEG, erpcom] = pop_duplicateeg( EEG, 'ChanArray',ChanArray,...
        'Saveas', 'off', 'History', 'gui');
    return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG');
% option(s)
p.addParamValue('ChanArray', [],@isnumeric);
p.addParamValue('Saveas', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(EEG, varargin{:});

ChanArray = p.Results.ChanArray;
if isempty(ChanArray) || any(ChanArray(:)>EEG.nbchan) || any(ChanArray(:)<=0)
    ChanArray = [[1:EEG.nbchan]];
end


if ~isempty(ChanArray)
    EEG.saved = 'no';
    EEG.filepath = '';
    chanDelete = setdiff([1:EEG.nbchan],ChanArray);
    if ~isempty(chanDelete)
        count = 0;
        for ii = chanDelete
            count = count+1;
            ChanArrayStr{count}   = EEG.chanlocs(ii).labels;
        end
        EEG = pop_select( EEG, 'rmchannel', ChanArrayStr);
        EEG = eeg_checkset(EEG);
    end
end



if strcmpi(p.Results.Saveas,'on')
    issaveas = 1;
else
    issaveas = 0;
end
if strcmpi(p.Results.History,'implicit')
    shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
    shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
    shist = 1; % gui
else
    shist = 0; % off
end

EEG.saved  = 'no';

%
% History
%

skipfields = {'EEG', 'Saveas','History'};
fn     = fieldnames(p.Results);
erpcom = sprintf( '%s = pop_duplicateeg( %s ', inputname(1), inputname(1) );
for q=1:length(fn)
    fn2com = fn{q};
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com);
        if ~isempty(fn2res)
            if ischar(fn2res)
                if ~strcmpi(fn2res,'off')
                    erpcom = sprintf( '%s, ''%s'', ''%s''', erpcom, fn2com, fn2res);
                end
            else
                if iscell(fn2res)
                    if ischar([fn2res{:}])
                        fn2resstr = sprintf('''%s'' ', fn2res{:});
                    else
                        fn2resstr = vect2colon(cell2mat(fn2res), 'Sort','on');
                    end
                    fnformat = '{%s}';
                else
                    fn2resstr = vect2colon(fn2res, 'Sort','on');
                    fnformat = '%s';
                end
                if strcmpi(fn2com,'Criterion')
                    if p.Results.Criterion<100
                        erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
                    end
                else
                    erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
                end
            end
        end
    end
end
erpcom = sprintf( '%s );', erpcom);

%
% Save ERPset from GUI
%
if issaveas
[EEG, ~] = pop_saveset( EEG, 'filename',EEG.filename,'filepath',EEG.filepath);
end



% get history from script. EEG
switch shist
    case 1 % from GUI
        displayEquiComERP(erpcom);
    case 2 % from script
        ALLEEG(ii) = eegh(erpcom, ALLEEG(ii));
    case 3
        % implicit
    otherwise %off or none
        erpcom = '';
        return
end
return