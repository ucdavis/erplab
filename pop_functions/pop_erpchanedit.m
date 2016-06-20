% PURPOSE: loads channel location information into an erpset
%
% FORMAT:
%
% ERP = erpchanedit(ERP, filename);
%
%
% See also borrowchanloc.m
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon && Johanna Kreither
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2013

function [ERP, erpcom] = pop_erpchanedit(ERP, filename, varargin)
erpcom = '';
if nargin<1
        help erpchanedit
        return
end
if nargin==1
        [filename, filepath] = uigetfile({ ...
                '*.elp','Besa Spherical (*.elp)'; ...
                '*.sfp','BESA/EGI (*.sfp)'; ...
                '*.loc','EEGLAB (*.loc)'; ...
                '*.ced','EEGLAB (ASCII) (*.ced)'; ...
                '*.xyz','EEGLAB (Matlab) (*.xyz)'; ...
                '*.elc','EETrack (*.elc)'; ...
                '*.sph','Matlab (*.sph)'; ...
                '*.asc','Neuroscan (*.asc)'; ...
                '*.dat','Neuroscan (*.dat)'; ...
                '*.elp','Polhemus (*.elp)'; ...
                '*.*',  'All Files (*.*)'}, ...
                'Select channel location file', ...
                'MultiSelect', 'off');
        if isequal(filename,0)
                disp('User selected Cancel')
                return
        else
                filename = fullfile(filepath, filename);
                disp(['For channel location file user selected  <a href="matlab: open(''' filename ''')">' filename '</a>'])
        end
        
        %
        % Somersault
        %
        [ERP, erpcom] = pop_erpchanedit(ERP, filename, 'Warning', 'on', 'Saveas', 'on', 'History', 'gui');
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ERP');
p.addRequired('filename', @ischar);
% option(s)
p.addParamValue('Warning', 'off', @ischar);
p.addParamValue('Saveas', 'off', @ischar); % 'on', 'off'
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ERP, filename, varargin{:});

if strcmpi(p.Results.Warning,'on')
        wchmsgon = 1;
else
        wchmsgon = 0;
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
if ismember_bc2({p.Results.Saveas}, {'on','yes'})
        issaveas  = 1;
else
        issaveas  = 0;
end

%
% Subroutine
%
[ERP, serror] = erpchanedit(ERP, filename);
if isempty(serror)
        disp('User selected Cancel')
        return
end
if serror~=0
        msgboxText = ['pop_erpchanedit could not find channel locations info.\n\n'...
                'Hint: Identify channel(s) without location looking at '...
                'command window comments (Channel lookup). Try again excluding this(ese) channel(s).'];
        tittle = 'pop_scalplot:  error:';
        errorfound(sprintf(msgboxText), tittle);
        return
end

ERP.saved  = 'no';
erpcom = sprintf('%s = pop_erpchanedit( %s, ''%s'');', inputname(1), inputname(1), filename);

if issaveas
        [ERP, issave, erpcom_save] = pop_savemyerp(ERP,'gui','erplab', 'History', 'implicit');
        if issave>0
                % generate text command
                if issave==2
                        erpcom = sprintf('%s\n%s', erpcom, erpcom_save);
                        msgwrng = '*** Your ERPset was saved on your hard drive.***';
                else
                        msgwrng = '*** Warning: Your ERPset was only saved on the workspace.***';
                end
                fprintf('\n%s\n\n', msgwrng)
                try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
        else
                ERP = ERPaux;
                msgwrng = 'ERPLAB Warning: Your changes were not saved';
                try cprintf([1 0.52 0.2], '%s\n\n', msgwrng);catch,fprintf('%s\n\n', msgwrng);end ;
        end
end
% get history from script. ERP
switch shist
        case 1 % from GUI
                displayEquiComERP(erpcom);
        case 2 % from script
                ERP = erphistory(ERP, [], erpcom, 1);
        case 3
                % implicit
                %ERP = erphistory(ERP, [], erpcom, 1);
                %fprintf('%%Equivalent command:\n%s\n\n', erpcom);
        otherwise %off or none
                erpcom = '';
end

%
% Completion statement
%
msg2end
return