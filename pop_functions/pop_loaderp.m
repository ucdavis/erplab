% PURPOSE  : 	Loads ERPset(s)
%
% FORMAT   :
%
% ERP = pop_loaderp(parameters);
%
% PARAMETERS     :
%
% 'filename'        - ERPset filename
% 'filepath'        - ERPset's filepath
% 'overwrite'       - overwrite current erpset. 'on'/'off'
% 'Warning'         - 'on'/'off'
% 'multiload'       - load multiple ERPset using a single output variable (see example 2). 'on'/'off'
% 'UpdateMainGui'   - 'on'/'off'
%
%
% OUTPUTS  :
%
% ERP	- output ERPset
%
%
% EXAMPLE 1  : Load a single ERPset
%
% ERP = pop_loaderp('filename','S1_ERPS.erp','filepath','/Users/etfoo/Documents/MATLAB/','overwrite','off','Warning','on');
%
% EXAMPLE 2  : Load multiple ERPsets using a single output variable
%
% ERP = pop_loaderp('filename',{'S1_ERPS.erp' 'S2_ERPS.erp' 'S3_ERPS.erp'},'filepath','/Users/etfoo/Documents/MATLAB/','multiload','on');
%
% EXAMPLE 3  : Load multiple ERPsets using two output variable (ERP ALLERP). ALLERP will store all. ERP will store the last ERPset.
%
% [ERP ALLERP] = pop_loaderp('filename',{'S1_ERPS.erp' 'S2_ERPS.erp' 'S3_ERPS.erp'},'filepath','/Users/etfoo/Documents/MATLAB/');
%
%
% See also olderpscan.m
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% ERPLAB Toolbox
% Copyright © 2007 The Regents of the University of California
% Created by Javier Lopez-Calderon and Steven Luck
% Center for Mind and Brain, University of California, Davis,
% javlopez@ucdavis.edu, sjluck@ucdavis.edu
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

function [ERP, ALLERP, erpcom] = pop_loaderp(varargin)
erpcom = '';
ERP    = preloadERP;
try
        ALLERP   = evalin('base', 'ALLERP');
        preindex = length(ALLERP);
catch
        disp('WARNING: ALLERP structure was not found. ERPLAB will create an empty one.')
        ALLERP = [];
        %ALLERP   = buildERPstruct([]);
        preindex = 0;
end
if nargin<1
        help pop_loaderp
        return
end
if nargin==1
        filename = varargin{1};
        if strcmpi(filename,'workspace')
                filepath = '';
        else
                if isempty(filename)
                        [filename, filepath] = uigetfile({'*.erp','ERP (*.erp)';...
                                '*.mat','ERP (*.mat)'}, ...
                                'Load ERP', ...
                                'MultiSelect', 'on');
                        if isequal(filename,0)
                                disp('User selected Cancel')
                                return
                        end
                        
                        %
                        % test current directory
                        %
                        %changecd(filepath) % Steve does not like this...
                else
                        filepath = cd;
                end
        end
        
        %
        % Somersault
        %
        [ERP, ALLERP, erpcom] = pop_loaderp('filename', filename, 'filepath', filepath, 'Warning', 'on', 'UpdateMainGui', 'on', 'multiload', 'off',...
                'History', 'gui');
        return
end

% parsing inputs
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
% option(s)
p.addParamValue('filename', '');
p.addParamValue('filepath', '', @ischar);
p.addParamValue('overwrite', 'off', @ischar);
p.addParamValue('Warning', 'off', @ischar);
p.addParamValue('multiload', 'off', @ischar); % ERP stores ALLERP's contain (ERP = ...), otherwise [ERP ALLERP] = ... must to be specified.
p.addParamValue('UpdateMainGui', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(varargin{:});

filename = strtrim(p.Results.filename);
filepath = strtrim(p.Results.filepath);

if strcmpi(filename,'workspace')
        filepath = '';
        nfile = 1;
        loadfrom = 0;  % load from workspace
else
        loadfrom = 1; % load from: 1=hard drive; 0=workspace
end
if strcmpi(p.Results.Warning,'on')
        popupwin = 1;
else
        popupwin = 0;
end
if strcmpi(p.Results.UpdateMainGui,'on')
        updatemaingui = 1;
else
        updatemaingui = 0;
end
if strcmpi(p.Results.multiload,'on')
        multiload = 1;
else
        multiload = 0;
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
if loadfrom==1
        if iscell(filename)
                nfile      = length(filename);
                inputfname = filename;
        else
                nfile = 1;
                inputfname = {filename};
        end
else
        inputfname = {'workspace'};
end

inputpath = filepath;
errorf    = 0; % no error found, by default
conti     = 1; % continue?  1=yes; 0=no
% if strcmpi(p.Results.overwrite,'on')||strcmpi(p.Results.overwrite,'yes')
%     ovatmenu = 1;
% else
%     ovatmenu = 0;
% end

%
% load ERPsets(s)
%
for i=1:nfile
        if loadfrom==1
                fullname = fullfile(inputpath, inputfname{i});
                fprintf('Loading %s\n', fullname);
                L   = load(fullname, '-mat');
                ERP = L.ERP;
        else
                ERP = evalin('base', 'ERP');
        end
        
        [ERP, conti, serror] = olderpscan(ERP, popupwin);
        if conti==0
                break
        end
        if serror
                msgboxText = ['Your erpset %s is not compatible at all with the current ERPLAB version.\n'...
                        'Please, try upgrading your ERP structure.'];
                
                if shist==1
                        title = 'ERPLAB: pop_loaderp() Error';
                        errorfound(sprintf(msgboxText, ERP.filename), title);
                        errorf = 1;
                        break
                else
                        error(sprintf(msgboxText, ERP.filename))
                end
        end
        
        %
        % Check (and fix) ERP structure (basic)
        %
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
                        msgboxText = ['Your erpset %s is not compatible at all with the current ERPLAB version.\n'...
                                'Please, try upgrading your ERP structure.'];
                        
                        if shist==1
                                title = 'ERPLAB: pop_loaderp() Error';
                                errorfound(sprintf(msgboxText, ERP.filename), title);
                                errorf = 1;
                                break
                        else
                                error(sprintf(msgboxText, ERP.filename))
                        end
                end
        catch
                msgboxText = ['Your erpset %s is not compatible at all with the current ERPLAB version.\n'...
                        'Please, try upgrading your ERP structure.'];
                
                if shist==1
                        title = 'ERPLAB: pop_loaderp() Error';
                        errorfound(sprintf(msgboxText, ERP.filename), title);
                        errorf = 1;
                        break
                else
                        error(sprintf(msgboxText, ERP.filename))
                end
        end
        
        %
        % look for null bins
        %
        c = look4nullbin(ERP);
        if c>0
                 msgnull = sprintf('bin #%g has flatlined ERPs.\n', c);
                 msgnull = sprintf('WARNING:\n%s', msgnull);
                 warningatcw(msgnull, [1 0 0]);
        end
end
if conti==0
        return
end
if nargout==1 && multiload==1
        ERP = ALLERP;
end
if nfile==1
        outv = 'ERP';
else
        outv = '[ERP ALLERP]';
end
if errorf==0 && serror==0
        if updatemaingui % update erpset menu at main gui
                assignin('base','ALLERP',ALLERP);  % save to workspace
                updatemenuerp(ALLERP); % add a new erpset to the erpset menu
        end
        fn         = fieldnames(p.Results);
        erpcom     = sprintf( '%s = pop_loaderp(', outv);
        skipfields = {'UpdateMainGui', 'Warning','History'};        
        for q=1:length(fn)
                fn2com = fn{q};
                if ~ismember_bc2(fn2com, skipfields)
                        fn2res = p.Results.(fn2com);
                        if iscell(fn2res) % 10-21-11
                                nc = length(fn2res);
                                xfn2res = sprintf('{''%s''', fn2res{1} );
                                for f=2:nc
                                        xfn2res = sprintf('%s, ''%s''', xfn2res, fn2res{f} );
                                end
                                fn2res = sprintf('%s}', xfn2res);
                        else
                                if ~strcmpi(fn2res,'off') %&& ~strcmpi(fn2res,'on')
                                        fn2res = ['''' fn2res ''''];
                                end
                        end
                        if ~isempty(fn2res)
                                if ischar(fn2res)
                                        if ~strcmpi(fn2res,'off')
                                                if q==1
                                                        erpcom = sprintf( '%s ''%s'', %s', erpcom, fn2com, fn2res);
                                                else
                                                        erpcom = sprintf( '%s, ''%s'', %s', erpcom, fn2com, fn2res);
                                                end
                                        end
                                else
                                        erpcom = sprintf( '%s, ''%s'', %s', erpcom, fn2com, vect2colon(fn2res,'Repeat','on'));
                                end
                        end
                end
        end        
        erpcom = sprintf( '%s );', erpcom);
else
        %       if strcmpi(filename,'workspace')
        %             assignin('base','ALLERP',ALLERP);  % save to workspace
        %             updatemenuerp(ALLERP);
        %       end
end
% get history from script. ERP
switch shist
        case 1 % from GUI
                displayEquiComERP(erpcom);
        case 2 % from script
                ERP = erphistory(ERP, [], erpcom, 1);
        case 3
                % implicit
                % ERP = erphistory(ERP, [], erpcom, 1);
                % fprintf('%%Equivalent command:\n%s\n\n', erpcom);
        otherwise %off or none
                erpcom = '';
                return
end

%
% Completion statement
%
prefunc = dbstack;
nf = length(unique_bc2({prefunc.name}));
if nf==1
        msg2end
end
return


