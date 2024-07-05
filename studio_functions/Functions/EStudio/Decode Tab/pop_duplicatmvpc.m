% PURPOSE:  pop_duplicatmvpc.m
%           duplicate MVPCsets
%

% FORMAT:
% [ALLMVPC, MVPCcom] = pop_duplicatmvpc( ALLMVPC, 'MVPCArray',MVPCArray,...
%         'Saveas', 'off', 'History', 'gui');

% Inputs:
%
%ALLMVPC     -ALLMVPC structure
%MVPCArray   -index(es) of MVPCArray



% *** This function is part of ERPLAB Studio ***
% Author: Guanghui Zhang & Steven Luck
% ghzhang@ucdavis.edu, sjluck@ucdavis.edu
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2024




function [ALLMVPCOUT, mvpcom] = pop_duplicatmvpc(ALLMVPC, varargin)
mvpcom = '';
ALLMVPCOUT = [];
if nargin < 1
    help pop_duplicatmvpc
    return
end
if isempty(ALLMVPC)
    msgboxText =  'Cannot duplicate an empty mvpcset';
    title = 'ERPLAB: pop_duplicatmvpc() error';
    errorfound(msgboxText, title);
    return
end
if isempty(ALLMVPC(1).average_score)
    msgboxText =  'Cannot duplicate an empty mvpcset';
    title = 'ERPLAB: pop_duplicatmvpc() error';
    errorfound(msgboxText, title);
    return
end

if nargin==1
    
    MVPCArray = [1:length(ALLMVPC)];
    % Somersault
    %
    [ALLMVPC, mvpcom] = pop_duplicatmvpc( ALLMVPC, 'MVPCArray',MVPCArray,...
        'History', 'gui');
    return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLMVPC');
% option(s)
p.addParamValue('MVPCArray', [],@isnumeric);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ALLMVPC, varargin{:});

MVPCArray = p.Results.MVPCArray;
if isempty(MVPCArray) || any(MVPCArray(:)>length(ALLMVPC)) || any(MVPCArray(:)<=0)
    MVPCArray = [1:length(ALLMVPC)];
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

skipfields = {'ALLMVPC','History'};
fn     = fieldnames(p.Results);
mvpcom = sprintf( '%s = pop_duplicatmvpc( %s ', inputname(1), inputname(1) );
for q=1:length(fn)
    fn2com = fn{q};
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com);
        if ~isempty(fn2res)
            if ischar(fn2res)
                if ~strcmpi(fn2res,'off')
                    mvpcom = sprintf( '%s, ''%s'', ''%s''', mvpcom, fn2com, fn2res);
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
                        mvpcom = sprintf( ['%s, ''%s'', ' fnformat], mvpcom, fn2com, fn2resstr);
                    end
                else
                    mvpcom = sprintf( ['%s, ''%s'', ' fnformat], mvpcom, fn2com, fn2resstr);
                end
            end
        end
    end
end
mvpcom = sprintf( '%s );', mvpcom);


Answer = f_mvpc_save_multi_file(ALLMVPC(MVPCArray),1:numel(MVPCArray),'_duplicate');
if isempty(Answer)
    ALLMVPCOUT = [];
    mvpcom = [];
    return;
end

ALLMVPC_out = Answer{1};
issaveas = Answer{2};

%
% Save ERPset from GUI
%
ALLMVPCOUT = ALLMVPC;
for NumofMVPC = 1:numel(MVPCArray)
    MVPC = ALLMVPC_out(NumofMVPC);
    if issaveas
        [MVPC, issave, ~] = pop_savemymvpc(MVPC, 'mvpcname', MVPC.mvpcname, 'filename', ...
            MVPC.filename, 'filepath',MVPC.filepath,'History','gui');
    else
        MVPC.saved = 'no';
    end
    ALLMVPCOUT(length(ALLMVPCOUT)+1) = MVPC;
end



% get history from script. ALLMVPC
switch shist
    case 1 % from GUI
        displayEquiComERP(mvpcom);
    case 2 % from script
        eegh(mvpcom);
    case 3
        % implicit
    otherwise %off or none
        mvpcom = '';
        return
end
return