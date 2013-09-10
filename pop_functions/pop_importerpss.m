% PURPOSE  : 	Import ERP from ERPSS Text file format
%
% FORMAT   :
%
% ERP = pop_importerpss(parameters);
%
% The available parameters are as follows:
%
%    'Filename'     - ERPSS Text file
%    'Format'       - 'explicit'/'implicit'
%    'Pointat'      - 'col'/'row'
%    'Saveas'       - 'on'/'off'
%
% EXAMPLE 1  : Load a single ERPset
%
% ERP = pop_importerpss('Filename', {'/Users/etfoo/Documents/MATLAB/ERP_ERPSS_test.txt'}, 'Format', 'implicit', 'Pointat', 'row');
%
% EXAMPLE 2  : Load two ERPsets (ALLERP will store both; ERP will store the last one)
%
% [ ERP ALLERP ]  = pop_importerpss('Filename', {'/Users/etfoo/Documents/MATLAB/ERP_ERPSS_test1.txt' '/Users/etfoo/Documents/MATLAB/ERP_ERPSS_test2.txt'},...
%                                                'Format', 'implicit', 'Pointat', 'row');
%
%
% OUTPUTS  :
%
% ERP and/or ALLERP
%
%
% See also importERPSS_GUI.m importerpss2.m
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Eric Foo
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

function [ERP, ALLERP, erpcom] = pop_importerpss(varargin)
erpcom = '';
ERP    = preloadERP;
errorf = 0;
try
        ALLERP   = evalin('base', 'ALLERP');
        preindex = length(ALLERP);
catch
        disp('WARNING: ALLERP structure was not found. ERPLAB will create an empty one.')
        ALLERP = [];
        preindex = 0;
end
if nargin<1
        
        %
        % call GUI
        %
        answer = importERPSS_GUI; %(gui was modified)
        
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        
        fname      = answer{1}; % filename (+ whole path)
        dformat    = answer{2}; % data format
        dtranspose = answer{3}; % transpose data  (Fixed)
        
        if dformat==0
                dformatstr = 'explicit'; % points at columns
        else
                dformatstr = 'implicit'; % points at rows
        end
        if dtranspose==0
                orienpoint = 'column';   % points at columns
        else
                orienpoint = 'row';      % points at rows
        end
        
        %
        % Somersault
        %
        [ERP, ALLERP, erpcom] = pop_importerpss('Filename', fname, 'Format', dformatstr, 'Pointat', orienpoint, 'Saveas', 'on', 'History', 'gui');
        pause(0.1);
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
% option(s)
p.addParamValue('Filename', '');
p.addParamValue('Format', 'explicit', @ischar);
p.addParamValue('Pointat', 'col', @ischar);
p.addParamValue('Saveas', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting
p.parse(varargin{:});

filename = p.Results.Filename;

if strcmpi(p.Results.Format, 'explicit');
        dformat = 0;
else
        dformat = 1;
end
if ismember({lower(p.Results.Pointat)}, {'col','column','columns'});
        dtranspose = 0;
elseif ismember({lower(p.Results.Pointat)}, {'row','rows'});
        dtranspose = 1;
else
        error('ERPLAB says: ?')
end
if strcmpi(p.Results.Saveas, 'on');
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
if iscell(filename) % filename fixed. JLC
        nfile      = length(filename);
else
        nfile = 1;
        filename = cellstr(filename);
end

%
% load ERPsets(s)
%
fprintf('\n');
for i=1:nfile
        try
                fname = filename{i}; % pointer "i" fixed. JLC
                fprintf('%g) Importing ''%s'' into ERPLAB...\n', i, fname);
                
                %
                % subroutine
                %
                [ERP, serror] = importerpss2(fname, dformat, dtranspose);
                if serror
                        break
                end
        catch
                serror =1;
                break
        end
        checking = checkERP(ERP);        
        try
                if checking
                        if i==1 && isempty(ALLERP);
                                ALLERP = buildERPstruct([]);
                                ALLERP = ERP;
                        else
                                ALLERP(i+preindex) = ERP;
                        end
                else
                        errorf = 1;
                        break
                end
        catch
                errorf = 1; % fatal error
                break
        end
end
if serror
        msgboxText = ['Oops! Something went wrong reading your file.\n'...
                'Please verify the ascii file or double check your settings for importing.'];
        title = 'ERPLAB: pop_importerpss() inputs';
        errorfound(sprintf(msgboxText), title);
        return
elseif errorf
        msgboxText = ['Your erpset %s is not compatible at all with the current ERPLAB version.\n'...
                'Please, try upgrading your ERP structure.'];
        title = 'ERPLAB: pop_importerpss() Error';
        errorfound(sprintf(msgboxText, ERP.filename), title);
        return
end
fprintf('\n');

%
% Completion statement
%
msg2end

%
% History
%
skipfields = {'Saveas','History'};
fn     = fieldnames(p.Results);
erpcom = sprintf( ' ERP = pop_importerpss(');
for q=1:length(fn)
        fn2com = fn{q};
        if ~ismember(fn2com, skipfields)
                fn2res = p.Results.(fn2com);
                if ~isempty(fn2res)
                        if ischar(fn2res)
                                if ~strcmpi(fn2res,'off')
                                        erpcom = sprintf( '%s, ''%s'', ''%s''', erpcom, fn2com, fn2res);
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
                                                erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
                                        end
                                else
                                        erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
                                end
                        end
                end
        end
end

erpcom = sprintf( '%s );', erpcom);
erpcom = strrep(erpcom, '(,','(');
% get history from script. ERP
switch shist
        case 1 % from GUI
                displayEquiComERP(erpcom);
        case 2 % from script
                ERP = erphistory(ERP, [], erpcom, 1);
        case 3
                % implicit
        otherwise %off or none
                erpcom = '';
                return
end
%
% Completion statement
%
msg2end
return

