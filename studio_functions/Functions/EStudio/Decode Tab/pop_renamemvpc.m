% PURPOSE:  pop_renamemvpc.m
%           rename ALLMVPCset
%

% FORMAT:
% [ALLMVPC, mvpccom] = pop_renamemvpc( ALLMVPC, 'mvpcnames',mvpcnames,...
%         'Saveas', 'off', 'History', 'gui');

% Inputs:
%
%ALLMVPC           -ALLMVPC structure
%mmvpcnames      -strings for mvpcsets



% *** This function is part of ERPLAB Studio ***
% Author: Guanghui Zhang & Steven Luck
% ghzhang@ucdavis.edu, sjluck@ucdavis.edu
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2024




function [ALLMVPC, mvpccom] = pop_renamemvpc(ALLMVPC, varargin)
mvpccom = '';

if nargin < 1
    help pop_renamemvpc
    return
end
if isempty(ALLMVPC)
    msgboxText =  'Cannot rename an empty ALLMVPCset';
    title = 'ERPLAB: pop_renamemvpc() error';
    errorfound(msgboxText, title);
    return
end


if nargin==1
    
    app = feval('Decode_Tab_mvpcrename_gui',ALLMVPC,1:length(ALLMVPC));
    waitfor(app,'Finishbutton',1);
    try
        mvpcnames = app.Output; %NO you don't want to output EEG with edited channel locations, you want to output the parameters to run decoding
        app.delete; %delete app from view
        pause(0.1); %wait for app to leave
    catch
        return;
    end
    if isempty(mvpcnames)
        return;
    end
    %
    % Somersault
    %
    [ALLMVPC, mvpccom] = pop_renamemvpc( ALLMVPC, 'mvpcnames',mvpcnames,...
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
p.addParamValue('mvpcnames', '',@iscell);
p.addParamValue('Saveas', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ALLMVPC, varargin{:});



mvpcnames = p.Results.mvpcnames;
if ischar(mvpcnames) && numel(ALLMVPC)==1
    ALLMVPC.mvpcname = mvpcnames;
    ALLMVPC.saved  = 'no';
elseif iscell(mvpcnames)
    for Numofbest = 1:numel(ALLMVPC)
        newName = mvpcnames{Numofbest};
        [~, newName, ~] = fileparts(newName) ;
        if ~isempty(newName)
            ALLMVPC(Numofbest).mvpcname = newName;
            ALLMVPC(Numofbest).saved  = 'no';
        else
            ALLMVPC(Numofbest).saved  = 'no';
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

skipfields = {'ALLMVPC', 'Saveas','History'};
fn     = fieldnames(p.Results);
mvpccom = sprintf( '%s = pop_renamemvpc( %s ', inputname(1), inputname(1) );
for q=1:length(fn)
    fn2com = fn{q};
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com);
        if ~isempty(fn2res)
            if ischar(fn2res)
                if ~strcmpi(fn2res,'off')
                    mvpccom = sprintf( '%s, ''%s'', {''%s'' ', mvpccom, fn2com, fn2res{1});
                end
            else
                if iscell(fn2res)
                    nn = length(fn2res);
                    mvpccom = sprintf( '%s, ''%s'', {''%s'' ', mvpccom, fn2com, fn2res{1});
                    for ff=2:nn
                        mvpccom = sprintf( '%s, ''%s'' ', mvpccom, fn2res{ff});
                    end
                    mvpccom = sprintf( '%s}', mvpccom);
                end
                
            end
        end
    end
end
mvpccom = sprintf( '%s );', mvpccom);

%
% Save ALLMVPCset from GUI
%
if issaveas
    for ii = 1:length(ALLMVPC)
        [ALLMVPC(ii), issave, mvpccom] = pop_savemymvpc(ALLMVPC(ii), 'mvpcname', ALLMVPC(ii).mvpcname, 'filename', ...
            ALLMVPC(ii).filename, 'filepath',ALLMVPC(ii).filepath);
    end
end

% eegh(mvpccom);

% get history from script. ALLMVPC
switch shist
    case 1 % from GUI
        displayEquiComERP(mvpccom);
    case 2 % from script
        %         for ii = 1:length(ALLMVPC)
        %             ALLMVPC(ii) = erphistory(ALLMVPC(ii), [], mvpccom, 1);
        %         end
    case 3
        % implicit
    otherwise %off or none
        mvpccom = '';
        return
end
return