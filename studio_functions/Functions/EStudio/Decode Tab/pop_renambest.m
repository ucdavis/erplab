% PURPOSE:  pop_renambest.m
%           rename ALLBESTset
%

% FORMAT:
% [ALLBEST, bestcom] = pop_renambest( ALLBEST, 'bestnames',bestnames,...
%         'Saveas', 'off', 'History', 'gui');

% Inputs:
%
%ALLBEST           -ALLBEST structure
%bestnames      -strings for bestsets



% *** This function is part of ERPLAB Studio ***
% Author: Guanghui Zhang & Steven Luck
% ghzhang@ucdavis.edu, sjluck@ucdavis.edu
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2024




function [ALLBEST, bestcom] = pop_renambest(ALLBEST, varargin)
bestcom = '';

if nargin < 1
    help pop_renambest
    return
end
if isempty(ALLBEST)
    msgboxText =  'Cannot rename an empty ALLBESTset';
    title = 'ERPLAB: pop_renambest() error';
    errorfound(msgboxText, title);
    return
end


if nargin==1
    
    app = feval('Decode_Tab_rename_gui',ALLBEST,1:length(ALLBEST));
    waitfor(app,'Finishbutton',1);
    try
        bestnames = app.Output; %NO you don't want to output EEG with edited channel locations, you want to output the parameters to run decoding
        app.delete; %delete app from view
        pause(0.1); %wait for app to leave
    catch
        return;
    end
    if isempty(bestnames)
        return;
    end
    %
    % Somersault
    %
    [ALLBEST, bestcom] = pop_renambest( ALLBEST, 'bestnames',bestnames,...
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
p.addParamValue('bestnames', '',@iscell);
p.addParamValue('Saveas', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ALLBEST, varargin{:});



bestnames = p.Results.bestnames;
if ischar(bestnames) && numel(ALLBEST)==1
    ALLBEST.bestname = bestnames;
    ALLBEST.saved  = 'no';
elseif iscell(bestnames)
    for Numofbest = 1:numel(ALLBEST)
        newName = bestnames{Numofbest};
        [~, newName, ~] = fileparts(newName) ;
        if ~isempty(newName)
            ALLBEST(Numofbest).bestname = newName;
            ALLBEST(Numofbest).saved  = 'no';
        else
            ALLBEST(Numofbest).saved  = 'no';
        end
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




%
% History
%

skipfields = {'ALLBEST', 'Saveas','History'};
fn     = fieldnames(p.Results);
bestcom = sprintf( '%s = pop_renambest( %s ', inputname(1), inputname(1) );
for q=1:length(fn)
    fn2com = fn{q};
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com);
        if ~isempty(fn2res)
            if ischar(fn2res)
                if ~strcmpi(fn2res,'off')
                    bestcom = sprintf( '%s, ''%s'', {''%s'' ', bestcom, fn2com, fn2res{1});
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

eegh(bestcom);

% get history from script. ALLBEST
switch shist
    case 1 % from GUI
        displayEquiComERP(bestcom);
    case 2 % from script
        %         for ii = 1:length(ALLBEST)
        %             ALLBEST(ii) = erphistory(ALLBEST(ii), [], bestcom, 1);
        %         end
    case 3
        % implicit
    otherwise %off or none
        bestcom = '';
        return
end
return