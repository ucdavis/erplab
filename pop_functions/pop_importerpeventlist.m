% PURPOSE  :	Apply imported eventlist from textfile to current ERP datset
%
% FORMAT   :
%
% ERP = pop_importerpeventlist(ERP, ELfullname, repEL, indexel)
%
%
% INPUTS   :
%
% ERP           - input ERPset
% ELfullname    - name of eventlist text file to be imported
% repEL    - replace the current EVENTLIST structure with:
%                 Options:
%                 0 - Delete All Existing EVENTLIST(s) and make imported
%                     EVENTLIST #1
%                 2 - Append Imported EVENTLIST as the next # eventlist (ie if
%                     ERPset containds 4 EVENTLISTS, then imported eventlist
%                     will be #5
% indexel       - EVENTLIST index (for multiple EVENTLIST)
%
% OUTPUTS
%
% ERP	- EVENTLIST structure added to current ERP structure or workspace
%
% EXAMPLE  :
%
% ERP = pop_importerpeventlist( ERP, '/Users/etfoo/Documents/MATLAB/test.txt', 2, 1);
%
% See also eventlist2erpGUI.m pasteeventlist.m
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Steven Luck
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

function [ERP, erpcom] = pop_importerpeventlist(ERP, ELfullname, varargin)
erpcom = '';
if nargin < 1
        help pop_importerpeventlist
        return
end
if isempty(ERP)
        msgboxText =  'pop_importerpeventlist() cannot work with an empty erpset!';
        title = 'ERPLAB: pop_importerpeventlist() error';
        errorfound(msgboxText, title);
        return
end
if isempty(ERP.bindata)
        msgboxText =  'pop_importerpeventlist() cannot work with an empty erpset!';
        title = 'ERPLAB: pop_importerpeventlist() error';
        errorfound(msgboxText, title);
        return
end
if nargin==1
        %
        % Call GUI
        %
        answer = eventlist2erpGUI(ERP);
        
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        
        ELfullname = answer{1};
        repEL      = answer{2};
        indexel    = answer{3};
        
        if repEL==0
                repEL = 'replaceall';
        elseif repEL==1
                repEL = 'replace';
        elseif repEL==2
                repEL = 'append';
        else
                disp('User selected Cancel')
                return
        end
        
        ERP.erpname = [ERP.erpname '_impel']; %suggest a new name (Imported Event List)
        
        %
        % Somersault
        %
        [ERP, erpcom] = pop_importerpeventlist(ERP, ELfullname, 'ReplaceEventList', repEL, 'EventListIndex', indexel, 'Saveas', 'on', 'History', 'gui');
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ERP');
p.addRequired('ELfullname', @ischar);
% option(s)
p.addParamValue('Saveas', 'off', @ischar); % 'on', 'off'
p.addParamValue('ReplaceEventList', 'off', @ischar);
p.addParamValue('EventListIndex', 1, @isnumeric);
p.addParamValue('Warning', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ERP, ELfullname, varargin{:});

indexel = p.Results.EventListIndex;

if strcmpi(p.Results.ReplaceEventList,'replaceall')
        repEL = 0;
elseif strcmpi(p.Results.ReplaceEventList,'replace')
        repEL = 1;
elseif strcmpi(p.Results.ReplaceEventList,'append')
        repEL = 2;
else
        error('ERPLAB says: Invalid value for "ReplaceEventList"')
end
if strcmpi(p.Results.Warning, 'on')
        rwwarn = 1;
else
        rwwarn = 0;
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
ERPaux = ERP;
%
% subroutine
%
[ERP, EVENTLIST, serror] = importerpeventlist(ERP, ELfullname);

if serror==1
        return
end

% [pathstr, filename, ext] = fileparts(ELfullname); %#ok<NASGU>

if repEL==0 % make #1
        ERP.EVENTLIST = [];
        ERP = pasteeventlist(ERP, EVENTLIST, 1);
elseif repEL==1 % replace
        ERP = pasteeventlist(ERP, EVENTLIST, 1, indexel);
elseif repEL==2  % append
        nelnext = length(ERP.EVENTLIST)+1;
        ERP = pasteeventlist(ERP, EVENTLIST, 1, nelnext);
else
        ERP = pasteeventlist(ERP, EVENTLIST, 0);
        %filenamex = regexprep(filename, ' ', '_');
        %assignin('base',filenamex,EVENTLIST);
        %disp(['EVENTLIST was added to WORKSPACE as ' filenamex] )
        return
end
ERP.saved   = 'no';

%
% History
%
skipfields = {'ERP', 'ELfullname', 'Saveas','History'};
fn     = fieldnames(p.Results);
erpcom = sprintf( '%s = pop_importerpeventlist( %s, "%s" ', inputname(1), inputname(1), ELfullname);
for q=1:length(fn)
        fn2com = fn{q};
        if ~ismember_bc2(fn2com, skipfields)
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

if issaveas      
      [ERP, issave, erpcom_save] = pop_savemyerp(ERP,'gui','erplab', 'History', 'off');      
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
                % ERP = erphistory(ERP, [], erpcom, 1);
                % fprintf('%%Equivalent command:\n%s\n\n', erpcom);
        otherwise %off or none
                erpcom = '';
                return
end
%
% Completion statement
%
msg2end
return