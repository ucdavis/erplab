% PURPOSE  :	Export EEG eventlist to text file
%
% FORMAT   :
%
% EEG = pop_exporteegeventlist( EEG, elname )
%
%
% INPUTS   :
%
% EEG           - eeglab dataset
% Elname        - file output
%
% OUTPUTS  :
%
% .txt          - Text file 'elname.txt'
%
%
% EXAMPLE  :
%
% EEG = pop_exporteegeventlist( EEG, '/Users/etfoo/Documents/MATLAB/ test.txt');
%
% See also creaeventlist.m
%
%*** This function is part of ERPLAB Toolbox ***
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

function [EEG, com] = pop_exporteegeventlist(EEG, varargin)
com = '';
if nargin < 1
        help pop_exporteegeventlist
        return
end
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if length(EEG)>1
        msgboxText =  'Unfortunately, this function does not work with multiple datasets';
        title = 'ERPLAB: multiple inputs';
        errorfound(msgboxText, title);
        return
end
if nargin==1
        if isempty(EEG)
                msgboxText =  'pop_exporteegeventlist() error: cannot work with an empty dataset!';
                title = 'ERPLAB: No data';
                errorfound(msgboxText, title);
                return
        end
        if isempty(EEG.data)
                msgboxText =  'pop_exporteegeventlist() error: cannot work with an empty dataset!';
                title = 'ERPLAB: No data';
                errorfound(msgboxText, title);
                return
        end
        if isfield(EEG, 'EVENTLIST')
                if isempty(EEG.EVENTLIST)
                        msgboxText =  ['EEG.EVENTLIST structure is empty.\n\n'...
                                'Please, use ERPLAB --> EVENTLIST --> Create EEG EventList menu before exporting to text.'];
                        title = 'ERPLAB: pop_exporteegeventlist() error, EVENTLIST structure';
                        errorfound(sprintf(msgboxText), title);
                        return
                end
                if isfield(EEG.EVENTLIST, 'eventinfo')
                        if isempty(EEG.EVENTLIST.eventinfo)
                                msgboxText =  ['EEG.EVENTLIST.eventinfo structure is empty.\n\n'...
                                        'Please, use ERPLAB --> EVENTLIST --> Create EEG EventList menu before exporting to text.'];
                                title = 'ERPLAB: pop_exporteegeventlist() error, EVENTLIST structure';
                                errorfound(sprintf(msgboxText), title);
                                return
                        end
                else
                        msgboxText =  ['EEG.EVENTLIST.eventinfo structure is empty.\n\n'...
                                'Please, use ERPLAB --> EVENTLIST --> Create EEG EventList menu before exporting to text.'];
                        title = 'ERPLAB: pop_exporteegeventlist() error, EVENTLIST structure';
                        errorfound(sprintf(msgboxText), title);
                        return
                end
        else
                msgboxText =  ['EEG.EVENTLIST structure is empty.\n\n'...
                        'Please, use ERPLAB --> EVENTLIST --> Create EEG EventList menu before exporting to text.'];
                title = 'ERPLAB: pop_exporteegeventlist() error, EVENTLIST structure';
                errorfound(sprintf(msgboxText), title);
                return
        end
        if ~isfield(EEG.EVENTLIST, 'bdf')
                msgboxText =  ['EEG.EVENTLIST.bdf structure is empty.\n\n'...
                        'Please, use ERPLAB --> EVENTLIST --> Create EEG EventList menu before exporting to text.'];
                title = 'ERPLAB: pop_exporteegeventlist() error, EVENTLIST structure';
                errorfound(sprintf(msgboxText), title);
                return
        end
        
        %
        % Save OUTPUT file
        %
        [fname, pathname] = uiputfile({'*.txt';'*.*'},'Save EVENTLIST file as');
        
        if isequal(fname,0)
                disp('User selected Cancel')
                return
        else
                [xpath, fname, ext] = fileparts(fname);
                
                if ~strcmp(ext,'.txt')
                        ext = '.txt';
                end
                
                fname  = [fname ext];
                elname = fullfile(pathname, fname);
                disp(['For EVENTLIST output user selected ', elname])
        end
        
        %
        % Somersault
        %
        [EEG, com] = pop_exporteegeventlist(EEG, 'Filename', elname, 'History', 'gui');
        return
end
if nargin==2
        %
        % Parsing inputs (versions<4.0)
        %
        p = inputParser;
        p.FunctionName  = mfilename;
        p.CaseSensitive = false;
        p.addRequired('EEG');
        p.addRequired('varargin');
        
        % option(s)
        p.addParamValue('History', 'script', @ischar); % history from scripting
        p.parse(EEG, varargin{:});
        elname   = varargin{:};
else
        %
        % Parsing inputs
        %
        p = inputParser;
        p.FunctionName  = mfilename;
        p.CaseSensitive = false;
        p.addRequired('EEG');
        % option(s)
        p.addParamValue('Filename', '', @ischar); % erpset index or input file
        p.addParamValue('History', 'script', @ischar); % history from scripting
        p.parse(EEG, varargin{:});
        elname   = p.Results.Filename;
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
if isempty(EEG.data)
        error('ERPLAB says: error at pop_exporteegeventlist(). cannot work with an empty dataset!')
end
if isfield(EEG, 'EVENTLIST')
        if isempty(EEG.EVENTLIST)
                error('ERPLAB says: error at pop_exporteegeventlist(). EEG.EVENTLIST structure is empty.');
        end
        
        if isfield(EEG.EVENTLIST, 'eventinfo')
                if isempty(EEG.EVENTLIST.eventinfo)
                        error('ERPLAB says: error at pop_exporteegeventlist(). EEG.EVENTLIST.eventinfo structure is empty.');
                end
        else
                error('ERPLAB says: error at pop_exporteegeventlist(). EEG.EVENTLIST.eventinfo structure was not found.');
        end
else
        error('ERPLAB says: error at pop_exporteegeventlist(). EEG.EVENTLIST structure was not found.');
end
if ~isfield(EEG.EVENTLIST, 'bdf')
        error('ERPLAB says: error at pop_exporteegeventlist(). EEG.EVENTLIST.bdf structure was not found.');
end


EVENTLIST = EEG.EVENTLIST;

%
% subroutine
%
creaeventlist(EEG, EVENTLIST, elname, 1);

%
% History
%
skipfields = {'EEG','History'};
fn     = fieldnames(p.Results);
com = sprintf( '%s = pop_exporteegeventlist( %s ', inputname(1), inputname(1) );
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
                % EEG = erphistory(EEG, [], com, 1);
                % fprintf('%%Equivalent command:\n%s\n\n', com);
        otherwise %off or none
                com = '';
end

%
% Completion statement
%
msg2end
return
