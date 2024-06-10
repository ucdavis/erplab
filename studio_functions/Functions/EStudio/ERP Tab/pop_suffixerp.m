% PURPOSE:  pop_suffixerp.m
%           add suffix to ALLERP names
%

% FORMAT:
% [ALLERP, erpcom] = pop_suffixerp( ALLERP, 'suffixstr',suffixstr,...
%         'Saveas', 'off', 'History', 'gui');

% Inputs:
%
%ALLERP           -ALLERP structure
%suffixstr        -strings for erpsets



% *** This function is part of ALLERPLAB Studio ***
% Author: Guanghui Zhang & Steven Luck
% ghzhang@ucdavis.edu, sjluck@ucdavis.edu
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Dec. 2024




function [ALLERP, erpcom] = pop_suffixerp(ALLERP, varargin)
erpcom = '';

if nargin < 1
    help pop_suffixerp
    return
end
if isempty(ALLERP)
    msgboxText =  'Cannot rename an empty ALLERPset';
    title = 'ERPLAB: pop_suffixerp() error';
    errorfound(msgboxText, title);
    return
end
if isempty(ALLERP(1).bindata)
    msgboxText =  'Cannot rename an empty ALLERPset';
    title = 'ERPLAB: pop_suffixerp() error';
    errorfound(msgboxText, title);
    return
end

datatype = checkdatatype(ALLERP(1));
if ~strcmpi(datatype, 'ERP')
    msgboxText =  'Cannot rename Power Spectrum waveforms!';
    title = 'ERPLAB: pop_suffixerp() error';
    errorfound(msgboxText, title);
    return
end

if nargin==1
    
    suffixstr = f_ERP_suffix_gui('Suffix');
    
    if isempty(suffixstr)
        return;
    end
    %
    % Somersault
    %
    [ALLERP, erpcom] = pop_suffixerp( ALLERP, 'suffixstr',suffixstr,...
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
p.addParamValue('suffixstr', '',@ischar);
p.addParamValue('Saveas', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ALLERP, varargin{:});



suffixstr = p.Results.suffixstr;

for Numoferp = 1:numel(ALLERP)
    ALLERP(Numoferp).erpname = [ALLERP(Numoferp).erpname,'_',suffixstr];
    ALLERP(Numoferp).saved  = 'no';
    
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
erpcom = sprintf( '%s = pop_suffixerp( %s ', inputname(1), inputname(1) );
for q=1:length(fn)
    fn2com = fn{q};
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com);
        if ~isempty(fn2res)
            if ischar(fn2res)
                if ~strcmpi(fn2res,'off')
                    erpcom = sprintf( '%s, ''%s'', ''%s'' ', erpcom, fn2com, fn2res);
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