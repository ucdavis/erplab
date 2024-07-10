% PURPOSE:  pop_suffixbest.m
%           add suffix to ALLBEST names
%

% FORMAT:
% [ALLBEST, bestcom] = pop_suffixbest( ALLBEST, 'suffixstr',suffixstr,...
%         'Saveas', 'off', 'History', 'gui');

% Inputs:
%
%ALLBEST           -ALLBEST structure
%suffixstr        -strings for bestsets



% *** This function is part of ALLBESTLAB Studio ***
% Author: Guanghui Zhang & Steven Luck
% ghzhang@ucdavis.edu, sjluck@ucdavis.edu
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2024




function [ALLBEST, bestcom] = pop_suffixbest(ALLBEST, varargin)
bestcom = '';

if nargin < 1
    help pop_suffixbest
    return
end
if isempty(ALLBEST)
    msgboxText =  'Cannot add suffix to an empty BESTset';
    title = 'ERPLAB: pop_suffixbest() error';
    errorfound(msgboxText, title);
    return
end
if isempty(ALLBEST(1).binwise_data)
    msgboxText =  'Cannot rename an empty BESTset';
    title = 'ERPLAB: pop_suffixbest() error';
    errorfound(msgboxText, title);
    return
end


if nargin==1
    
    suffixstr = f_EEG_suffix_gui('Suffix',2);
    
    if isempty(suffixstr)
        return;
    end
    %
    % Somersault
    %
    [ALLBEST, bestcom] = pop_suffixbest( ALLBEST, 'suffixstr',suffixstr,...
        'Saveas', 'off', 'History', 'gui');
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
p.addParamValue('suffixstr', '',@ischar);
p.addParamValue('Saveas', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ALLBEST, varargin{:});



suffixstr = p.Results.suffixstr;

for Numoferp = 1:numel(ALLBEST)
    ALLBEST(Numoferp).bestname = [ALLBEST(Numoferp).bestname,'_',suffixstr];
    ALLBEST(Numoferp).saved  = 'no';
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

skipfields = {'ALLBEST', 'Saveas','History'};
fn     = fieldnames(p.Results);
bestcom = sprintf( '%s = pop_suffixbest( %s ', inputname(1), inputname(1) );
for q=1:length(fn)
    fn2com = fn{q};
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com);
        if ~isempty(fn2res)
            if ischar(fn2res)
                if ~strcmpi(fn2res,'off')
                    bestcom = sprintf( '%s, ''%s'', ''%s'' ', bestcom, fn2com, fn2res);
                end
            else
                if iscell(fn2res)
                    nn = length(fn2res);
                    bestcom = sprintf( '%s, ''%s'', {''%s'' ', bestcom, fn2com, fn2res{1});
                    for ff=2:nn
                        bestcom = sprintf( '%s, ''%s'' ', bestcom, fn2res{ff});
                    end
                    bestcom = sprintf( '%s}', bestcom);
                end
                
            end
        end
    end
end
bestcom = sprintf( '%s );', bestcom);

%
% Save ALLBESTset from GUI
%
if issaveas
    for ii = 1:length(ALLBEST)
        [ALLBEST(ii), issave, BESTCOM] = pop_savemybest(ALLBEST(ii), 'bestname', ALLBEST(ii).bestname, 'filename', ...
            ALLBEST(ii).filename, 'filepath',ALLBEST(ii).filepath);
    end
end



% get history from script. ALLBEST
switch shist
    case 1 % from GUI
        displayEquiComERP(bestcom);
    case 2 % from script
        for ii = 1:length(ALLBEST)
            ALLBEST(ii) = eegh(bestcom, ALLBEST(ii));
        end
    case 3
        % implicit
    otherwise %off or none
        bestcom = '';
        return
end
return