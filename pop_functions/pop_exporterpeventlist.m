% PURPOSE  :	Export ERP eventlist to text file
%
% FORMAT   :
%
% pop_exporterpeventlist( ERP, 1, elname );
%
%
% INPUTS   :
%
% ERP       - input dataset
% Elname    - file output
%
% OUTPUTS  :
%
% .txt      - Text file 'elname.txt'
%
%
% EXAMPLE  :
%
% pop_exporterpeventlist( ERP, 1, '/Users/etfoo/Documents/MATLAB/test.txt' );
%
% See also exporterpeventlist.m
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

function [ERP, erpcom] = pop_exporterpeventlist(ERP, varargin)
erpcom = '';
if nargin < 1
        help pop_exporterpeventlist
        return
end
if nargin==1
        if isempty(ERP)
                msgboxText =  'pop_exporterpeventlist() error: cannot work with an empty erpset!';
                title = 'ERPLAB: No data';
                errorfound(msgboxText, title);
                return
        end
        if isempty(ERP.bindata)
                msgboxText =  'pop_exporterpeventlist() error: cannot work with an empty erpset!';
                title = 'ERPLAB: No data';
                errorfound(msgboxText, title);
                return
        end
        if isfield(ERP, 'EVENTLIST')
                if isempty(ERP.EVENTLIST)
                        msgboxText{1} =  'pop_exporterpeventlist() error: ERP.EVENTLIST structure is empty.';
                        title = 'ERPLAB: No EVENTLIST structure';
                        errorfound(msgboxText, title);
                        return
                end
                
                e2 = length(ERP.EVENTLIST);
                
                if e2>1 % JLC Aug 30, 2012
                        prompt    = {'Enter EVENTLIST index'};
                        num_lines = e2;
                        def       = 1;
                        answer    = inputindexGUI(prompt, num_lines, def);
                        
                        if isempty(answer)
                                disp('User selected Cancel')
                                return
                        else
                                indexel = answer{1};
                                if isempty(indexel) || indexel<1 || indexel>e2
                                        msgboxText{1} =  'pop_exporterpeventlist() error: not valid EVENTLIST index';
                                        title = 'ERPLAB: EVENTLIST index';
                                        errorfound(msgboxText, title);
                                        return
                                end
                        end
                else
                        indexel = 1;
                end
                if isfield(ERP.EVENTLIST(indexel), 'eventinfo')
                        if isempty(ERP.EVENTLIST(indexel).eventinfo)
                                msgboxText =  'pop_exporterpeventlist() error: ERP.EVENTLIST.eventinfo structure is empty.';
                                title = 'ERPLAB: No EVENTLIST.eventinfo structure';
                                errorfound(msgboxText, title);
                                return
                        end
                else
                        msgboxText =  'pop_exporterpeventlist() error: ERP.EVENTLIST.eventinfo structure was not found.';
                        title = 'ERPLAB: No EVENTLIST.eventinfo structure';
                        errorfound(msgboxText, title);
                        return
                end
        else
                msgboxText =  'pop_exporterpeventlist() error: ERP.EVENTLIST structure was not found.';
                title = 'ERPLAB: No EVENTLIST structure';
                errorfound(msgboxText, title);
                return
        end
        if ~isfield(ERP.EVENTLIST(indexel), 'bdf')
                msgboxText =  'pop_exporterpeventlist() error: ERP.EVENTLIST.bdf structure was not found.';
                title = 'ERPLAB: No EVENTLIST.bdf structure';
                errorfound(msgboxText, title);
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
                disp(['For ERP EVENTLIST output user selected ', elname])
        end
        
        %
        % Somersault
        %
        [ERP, erpcom] = pop_exporterpeventlist(ERP, 'ELIndex', indexel,'Filename', elname, 'History', 'gui');
        return
end

% indexel, elname)

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ERP');
% option(s)
p.addParamValue('ELIndex', [], @isnumeric); % erpset index or input file
p.addParamValue('Filename', '', @ischar); % erpset index or input file
p.addParamValue('History', 'script', @ischar); % history from scripting
p.parse(ERP, varargin{:});

elname   = p.Results.Filename;
indexel  = p.Results.ELIndex;

if strcmpi(p.Results.History,'implicit')
        shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
        shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
        shist = 1; % gui
else
        shist = 0; % off
end
if isempty(ERP.bindata)
        error('ERPLAB says: error at pop_exporterpeventlist(). Cannot work with an empty dataset!')
end
if isfield(ERP, 'EVENTLIST')
        if isempty(ERP.EVENTLIST)
                error('ERPLAB says: error at pop_exporterpeventlist(). ERP.EVENTLIST structure is empty.');
        end
        
        if isfield(ERP.EVENTLIST(indexel), 'eventinfo')
                if isempty(ERP.EVENTLIST(indexel).eventinfo)
                        error('ERPLAB says: error at pop_exporterpeventlist(). ERP.EVENTLIST.eventinfo structure is empty.');
                end
        else
                error('ERPLAB says: error at pop_exporterpeventlist(). ERP.EVENTLIST.eventinfo structure was not found.');
        end
else
        error('ERPLAB says: error at pop_exporterpeventlist(). ERP.EVENTLIST structure was not found.');
end
if ~isfield(ERP.EVENTLIST(indexel), 'bdf')
        error('ERPLAB says: error at pop_exporterpeventlist(). ERP.EVENTLIST.bdf structure was not found.');
end

%
% subroutine
%
exporterpeventlist(ERP, indexel, elname);
erpcom = sprintf( 'pop_exporterpeventlist(%s, %s, ''%s'');', inputname(1), num2str(indexel), elname);
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
end

%
% Completion statement
%
msg2end
return
