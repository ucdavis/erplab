% PURPOSE:  pop_renamerp.m
%           rename ALLERPset
%

% FORMAT:
% [ALLERP, erpcom] = pop_renamerp( ALLERP, 'erpnames',erpnames,...
%         'Saveas', 'off', 'History', 'gui');

% Inputs:
%
%ALLERP           -ALLERP structure
%erpnames      -strings for erpsets



% *** This function is part of ALLERPLAB Studio ***
% Author: Guanghui Zhang & Steven Luck
% ghzhang@ucdavis.edu, sjluck@ucdavis.edu
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Dec. 2024




function [ALLERP, erpcom] = pop_renamerp(ALLERP, varargin)
erpcom = '';

if nargin < 1
    help pop_renamerp
    return
end
if isempty(ALLERP)
    msgboxText =  'Cannot rename an empty ALLERPset';
    title = 'ALLERPLAB: pop_renamerp() error';
    errorfound(msgboxText, title);
    return
end
if isempty(ALLERP(1).bindata)
    msgboxText =  'Cannot rename an empty ALLERPset';
    title = 'ALLERPLAB: pop_renamerp() error';
    errorfound(msgboxText, title);
    return
end

datatype = checkdatatype(ALLERP(1));
if ~strcmpi(datatype, 'ERP')
    msgboxText =  'Cannot rename Power Spectrum waveforms!';
    title = 'ALLERPLAB: pop_renamerp() error';
    errorfound(msgboxText, title);
    return
end

if nargin==1
    
    app = feval('ERP_Tab_rename_gui',ALLERP,1:length(ALLERP));
    waitfor(app,'Finishbutton',1);
    try
        erpnames = app.Output; %NO you don't want to output EEG with edited channel locations, you want to output the parameters to run decoding
        app.delete; %delete app from view
        pause(0.1); %wait for app to leave
    catch
        return;
    end
    if isempty(erpnames)
        return;
    end
    %
    % Somersault
    %
    [ALLERP, erpcom] = pop_renamerp( ALLERP, 'erpnames',erpnames,...
        'Saveas', 'off', 'History', 'gui');
    return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLERP');
% option(s)
p.addParamValue('erpnames', '',@iscell);
p.addParamValue('Saveas', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ALLERP, varargin{:});



erpnames = p.Results.erpnames;
if ischar(erpnames) && numel(ALLERP)==1
    ALLERP.erpname = erpnames;
    ALLERP.saved  = 'no';
elseif iscell(erpnames)
    for Numoferp = 1:numel(ALLERP)
        newName = erpnames{Numoferp};
        [~, newName, ~] = fileparts(newName) ;
        if ~isempty(newName)
            ALLERP(Numoferp).erpname = newName;
            ALLERP(Numoferp).saved  = 'no';
        else
            ALLERP(Numoferp).saved  = 'no';
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

skipfields = {'ALLERP', 'Saveas','History'};
fn     = fieldnames(p.Results);
erpcom = sprintf( '%s = pop_renamerp( %s ', inputname(1), inputname(1) );
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
% Save ALLERPset from GUI
%
if issaveas
    for ii = 1:length(ALLERP)
        [ALLERP(ii), issave, erpcom_save] = pop_savemyerp(ALLERP(ii),'gui','erplab', 'History', 'off');
    end
end



% get history from script. ALLERP
switch shist
    case 1 % from GUI
        displayEquiComERP(erpcom);
    case 2 % from script
        for ii = 1:length(ALLERP)
            ALLERP(ii) = erphistory(ALLERP(ii), [], erpcom, 1);
        end
    case 3
        % implicit
    otherwise %off or none
        erpcom = '';
        return
end
return