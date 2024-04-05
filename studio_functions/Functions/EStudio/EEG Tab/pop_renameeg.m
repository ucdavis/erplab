% PURPOSE:  pop_renameeg.m
%           rename ALLEEGset
%

% FORMAT:
% [ALLEEG, erpcom] = pop_renameeg( ALLEEG, 'eegnames',eegnames,...
%         'Saveas', 'off', 'History', 'gui');

% Inputs:
%
%ALLEEG           -ALLEEG structure
%eegnames      -strings for erpsets



% *** This function is part of ALLEEGLAB Studio ***
% Author: Guanghui Zhang & Steven Luck
% ghzhang@ucdavis.edu, sjluck@ucdavis.edu
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Dec. 2024




function [ALLEEG, erpcom] = pop_renameeg(ALLEEG, varargin)
erpcom = '';

if nargin < 1
    help pop_renameeg
    return
end
if isempty(ALLEEG)
    msgboxText =  'Cannot rename an empty EEGset';
    title = 'ERPLAB: pop_renameeg() error';
    errorfound(msgboxText, title);
    return
end
if isempty(ALLEEG(1).data)
    msgboxText =  'Cannot rename an empty EEGset';
    title = 'ERPLAB: pop_renameeg() error';
    errorfound(msgboxText, title);
    return
end



if nargin==1
    
    app = feval('EEG_Tab_rename_gui',ALLEEG,1:length(ALLEEG));
    waitfor(app,'Finishbutton',1);
    try
        eegnames = app.Output; %NO you don't want to output EEG with edited channel locations, you want to output the parameters to run decoding
        app.delete; %delete app from view
        pause(0.1); %wait for app to leave
    catch
        return;
    end
    if isempty(eegnames)
        return;
    end
    %
    % Somersault
    %
    [ALLEEG, erpcom] = pop_renameeg( ALLEEG, 'eegnames',eegnames,...
        'Saveas', 'off', 'History', 'gui');
    return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLEEG');
% option(s)
p.addParamValue('eegnames', '',@iscell);
p.addParamValue('Saveas', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ALLEEG, varargin{:});



eegnames = p.Results.eegnames;
if ischar(eegnames) && numel(ALLEEG)==1
    ALLEEG.erpname = eegnames;
    ALLEEG.saved  = 'no';
elseif iscell(eegnames)
    for Numoferp = 1:numel(ALLEEG)
        newName = eegnames{Numoferp};
        [~, newName, ~] = fileparts(newName) ;
        if ~isempty(newName)
            ALLEEG(Numoferp).setname = newName;
            ALLEEG(Numoferp).saved  = 'no';
        else
            ALLEEG(Numoferp).saved  = 'no';
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

skipfields = {'ALLEEG', 'Saveas','History'};
fn     = fieldnames(p.Results);
erpcom = sprintf( '%s = pop_renameeg( %s ', inputname(1), inputname(1) );
for q=1:length(fn)
    fn2com = fn{q};
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com);
        if ~isempty(fn2res)
            if ischar(fn2res)
                if ~strcmpi(fn2res,'off')
                    erpcom = sprintf( '%s, ''%s'', {''%s'' ', erpcom, fn2com, fn2res{1});
                end
            else
                if iscell(fn2res)
                    nn = length(fn2res);
                    erpcom = sprintf( '%s, ''%s'', {''%s'' ', erpcom, fn2com, fn2res{1});
                    for ff=2:nn
                        erpcom = sprintf( '%s, ''%s'' ', erpcom, fn2res{ff});
                    end
                    erpcom = sprintf( '%s}', erpcom);
                end
                
            end
        end
    end
end
erpcom = sprintf( '%s );', erpcom);

%
% Save ALLEEGset from GUI
%
if issaveas
    for ii = 1:length(ALLEEG)
         [ALLEEG(ii), ~] = pop_saveset( ALLEEG(ii), 'filename',ALLEEG(ii).filename,'filepath',[ALLEEG(ii).filepath,filesep]);
    end
end



% get history from script. ALLEEG
switch shist
    case 1 % from GUI
        displayEquiComERP(erpcom);
    case 2 % from script
        for ii = 1:length(ALLEEG)
            ALLEEG(ii) = eegh(erpcom, ALLEEG(ii));
        end
    case 3
        % implicit
    otherwise %off or none
        erpcom = '';
        return
end
return