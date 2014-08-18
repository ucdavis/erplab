% *** This function is part of ERPLAB Toolbox ***
% Author: Johanna Kreither & Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2014

function [EEG, com] = pop_binlabel2type(EEG, varargin)

com = '';
if nargin<1
        help pop_binlabel2type
        return
end
if nargin==1
        serror = erplab_eegscanner(EEG, 'pop_binlabel2type', 0, 0, 0, 0, 2);
        if serror
                return
        end        
        def    = erpworkingmemory('pop_binlabel2type');
        if isempty(def)
                def = {'1'};
        end
        
        prompt    = {'Enter a multiplier (Optional. Default=1)'};
        dlg_title = 'Recovering numeric event codes from Bin Labels';
        %num_lines = 1;
        
        %
        % open window
        %
        %answer = inputvalue(prompt,dlg_title,num_lines,def);
        answer = inputvalueGUI(prompt,dlg_title, def, {1}, 0);
        
        if isempty(answer)
                disp('User selected Cancel')
                return
        end       
        multip = answer{1};
        if ischar(multip)
                multip = str2num(multip);
        end
        if length(multip)~=1
                msgboxText =  'You must specify a single value as a multiplier';
                title      = 'ERPLAB: pop_binlabel2type() error:';
                errorfound(msgboxText, title);
                return
        end
        multip = round(multip);
        
        erpworkingmemory('pop_binlabel2type', answer(1));
        
        if length(EEG)==1
                EEG.setname = [EEG.setname '_blabel2type']; %suggest a new name
        end
        
        %
        % Somersault
        %
        [EEG, com] = pop_binlabel2type(EEG, 'Multiplier', multip, 'History', 'gui');
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG');
% option(s)
p.addParamValue('Multiplier', 1, @isnumeric);
p.addParamValue('Warning', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting
p.parse(EEG, varargin{:});

if strcmpi(p.Results.History,'implicit')
        shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
        shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
        shist = 1; % gui
else
        shist = 0; % off
end

multip = p.Results.Multiplier;
if isempty(multip)
        multip = 1;
end
if multip==0
        multip = 1;
end
if length(multip)>1
        multip = multip(1);
end

%
% subroutine
%
EEG = binlabel2type(EEG, multip);

skipfields = {'EEG', 'History'};
fn  = fieldnames(p.Results);
com = sprintf('%s = pop_binlabel2type( %s', inputname(1), inputname(1));

for q=1:length(fn)
        fn2com = fn{q};
        if ~ismember_bc2(fn2com, skipfields)
                fn2res = p.Results.(fn2com);
                if ~isempty(fn2res)
                        if ischar(fn2res)
                                if ~strcmpi(fn2res,'off')
                                        com = sprintf( '%s, ''%s'', ''%s''', com, fn2com, fn2res);
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
                                                com = sprintf( ['%s, ''%s'', ' fnformat], com, fn2com, fn2resstr);
                                        end
                                else
                                        com = sprintf( ['%s, ''%s'', ' fnformat], com, fn2com, fn2resstr);
                                end
                        end
                end
        end
end
com = sprintf( '%s );', com);

% get history from script. EEG
switch shist
        case 1 % from GUI
                com = sprintf('%s %% GUI: %s', com, datestr(now));
                %fprintf('%%Equivalent command:\n%s\n\n', com);
                displayEquiComERP(com);
        case 2 % from script
                EEG = erphistory(EEG, [], com, 1);
        case 3
                % implicit
        otherwise %off or none
                com = '';
end

%
% Completion statement
%
msg2end
return