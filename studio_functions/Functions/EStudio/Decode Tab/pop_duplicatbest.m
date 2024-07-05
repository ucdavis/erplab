% PURPOSE:  pop_duplicatbest.m
%           duplicate BESTsets
%

% FORMAT:
% [ALLBEST, bestcom] = pop_duplicatbest( ALLBEST, 'BESTArray',BESTArray,...
%         'Saveas', 'off', 'History', 'gui');

% Inputs:
%
%ALLBEST     -ALLBEST structure
%BESTArray   -index(es) of BESTArray



% *** This function is part of ERPLAB Studio ***
% Author: Guanghui Zhang & Steven Luck
% ghzhang@ucdavis.edu, sjluck@ucdavis.edu
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2024




function [ALLBESTOUT, erpcom] = pop_duplicatbest(ALLBEST, varargin)
erpcom = '';
ALLBESTOUT = [];
if nargin < 1
    help pop_duplicatbest
    return
end
if isempty(ALLBEST)
    msgboxText =  'Cannot duplicate an empty bestset';
    title = 'ERPLAB: pop_duplicatbest() error';
    errorfound(msgboxText, title);
    return
end
if isempty(ALLBEST(1).binwise_data(1).data)
    msgboxText =  'Cannot duplicate an empty bestset';
    title = 'ERPLAB: pop_duplicatbest() error';
    errorfound(msgboxText, title);
    return
end

if nargin==1
    
    BESTArray = [1:length(ALLBEST)];
    % Somersault
    %
    [ALLBEST, erpcom] = pop_duplicatbest( ALLBEST, 'BESTArray',BESTArray,...
        'History', 'gui');
    return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLBEST');
% option(s)
p.addParamValue('BESTArray', [],@isnumeric);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ALLBEST, varargin{:});

BESTArray = p.Results.BESTArray;
if isempty(BESTArray) || any(BESTArray(:)>length(ALLBEST)) || any(BESTArray(:)<=0)
    BESTArray = [1:length(ALLBEST)];
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


%
% History
%

skipfields = {'ALLBEST','History'};
fn     = fieldnames(p.Results);
erpcom = sprintf( '%s = pop_duplicatbest( %s ', inputname(1), inputname(1) );
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


Answer = f_BEST_save_multi_file(ALLBEST(BESTArray),1:numel(BESTArray),'_duplicate');
if isempty(Answer)
    ALLBESTOUT = [];
    erpcom = [];
    return;
end

ALLBEST_out = Answer{1};
issaveas = Answer{2};

%
% Save ERPset from GUI
%
ALLBESTOUT = ALLBEST;
for Numofbest = 1:numel(BESTArray)
    BEST = ALLBEST_out(Numofbest);
    if issaveas
        [BEST, issave, BESTCOM] = pop_savemybest(BEST, 'bestname', BEST.bestname,...
            'filename', BEST.filename, 'filepath',BEST.filepath,'History','gui');
    else
        BEST.saved = 'no';
    end
    ALLBESTOUT(length(ALLBESTOUT)+1) = BEST;
end



% get history from script. ALLBEST
switch shist
    case 1 % from GUI
        displayEquiComERP(erpcom);
    case 2 % from script
        for Numofbest = 1:numel(BESTArray)
            BEST = ALLBESTOUT(length(ALLBESTOUT)-numel(BESTArray)+Numofbest);
            if ~isempty(erpcom) && ~isempty(BEST.EEGhistory)
                olderpcom = cellstr(BEST.EEGhistory);
                newerpcom = [olderpcom; {[erpcom ,'% ', 'GUI: ', datestr(now)]}];
                BEST.EEGhistory = char(newerpcom);
            elseif ~isempty(erpcom) && isempty(BEST.EEGhistory)
                BEST.EEGhistory = [char(erpcom) , '% ', 'GUI: ', datestr(now)];
            end
            ALLBESTOUT(length(ALLBESTOUT)-numel(BESTArray)+Numofbest) = BEST;
        end
        
    case 3
        % implicit
    otherwise %off or none
        erpcom = '';
        return
end
return