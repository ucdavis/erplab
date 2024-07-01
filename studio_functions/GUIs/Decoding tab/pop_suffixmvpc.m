% PURPOSE:  pop_suffixmvpc.m
%           add suffix to ALLMVPC names
%

% FORMAT:
% [ALLMVPC, mvpcom] = pop_suffixmvpc( ALLMVPC, 'suffixstr',suffixstr,...
%         'Saveas', 'off', 'History', 'gui');

% Inputs:
%
%ALLMVPC           -ALLMVPC structure
%suffixstr        -strings for bestsets



% *** This function is part of ERPLAB Studio ***
% Author: Guanghui Zhang & Steven Luck
% ghzhang@ucdavis.edu, sjluck@ucdavis.edu
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2024




function [ALLMVPC, mvpcom] = pop_suffixmvpc(ALLMVPC, varargin)
mvpcom = '';

if nargin < 1
    help pop_suffixmvpc
    return
end
if isempty(ALLMVPC)
    msgboxText =  'Cannot add suffix to an empty MVPCset';
    title = 'ERPLAB: pop_suffixmvpc() error';
    errorfound(msgboxText, title);
    return
end
if isempty(ALLMVPC(1).average_score)
    msgboxText =  'Cannot rename an empty MVPCset';
    title = 'ERPLAB: pop_suffixmvpc() error';
    errorfound(msgboxText, title);
    return
end


if nargin==1
    
    suffixstr = f_EEG_suffix_gui('Suffix',3);
    
    if isempty(suffixstr)
        return;
    end
    %
    % Somersault
    %
    [ALLMVPC, mvpcom] = pop_suffixmvpc( ALLMVPC, 'suffixstr',suffixstr,...
        'Saveas', 'off', 'History', 'gui');
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
p.addParamValue('suffixstr', '',@ischar);
p.addParamValue('Saveas', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ALLMVPC, varargin{:});


suffixstr = p.Results.suffixstr;

for Numoferp = 1:numel(ALLMVPC)
    ALLMVPC(Numoferp).mvpcname = [ALLMVPC(Numoferp).mvpcname,'_',suffixstr];
    ALLMVPC(Numoferp).saved  = 'no';
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




%
% History
%

skipfields = {'ALLMVPC', 'Saveas','History'};
fn     = fieldnames(p.Results);
mvpcom = sprintf( '%s = pop_suffixmvpc( %s ', inputname(1), inputname(1) );
for q=1:length(fn)
    fn2com = fn{q};
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com);
        if ~isempty(fn2res)
            if ischar(fn2res)
                if ~strcmpi(fn2res,'off')
                    mvpcom = sprintf( '%s, ''%s'', ''%s'' ', mvpcom, fn2com, fn2res);
                end
            else
                if iscell(fn2res)
                    nn = length(fn2res);
                    mvpcom = sprintf( '%s, ''%s'', {''%s'' ', mvpcom, fn2com, fn2res{1});
                    for ff=2:nn
                        mvpcom = sprintf( '%s, ''%s'' ', mvpcom, fn2res{ff});
                    end
                    mvpcom = sprintf( '%s}', mvpcom);
                end
                
            end
        end
    end
end
mvpcom = sprintf( '%s );', mvpcom);

%
% Save ALLMVPCset from GUI
%
if issaveas
    for ii = 1:length(ALLMVPC)
        [ALLMVPC(ii), issave, mvpccom] = pop_savemymvpc(ALLMVPC(ii), 'mvpcname', ALLMVPC(ii).mvpcname, 'filename', ...
            ALLMVPC(ii).filename, 'filepath',ALLMVPC(ii).filepath);
    end
end



% get history from script. ALLMVPC
switch shist
    case 1 % from GUI
        displayEquiComERP(mvpcom);
    case 2 % from script
        for ii = 1:length(ALLMVPC)
            ALLMVPC(ii) = eegh(mvpcom, ALLMVPC(ii));
        end
    case 3
        % implicit
    otherwise %off or none
        mvpcom = '';
        return
end
return