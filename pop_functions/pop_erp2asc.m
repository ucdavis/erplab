% PURPOSE  :	Exports ERP to text (readable by ERPSS)
%
% FORMAT   :
%
% pop_erp2asc( ERP, filename )
%
% INPUTS   :
%
% ERP           - input dataset
% Filename      - file output
%
%
% OUTPUTS
%
% -	outputted text file 'filename.txt' of ERP data, readable by ERPSS
%
% EXAMPLE  :
%
% pop_erp2asc( ERP, 'S1_EEG_ERPs.erp' )
%
% See alsoo uiputfile.m  erp2asc.m
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

function [ERP, erpcom] = pop_erp2asc(ERP, filename, varargin)
erpcom = '';
if nargin < 1
        help pop_erp2asc
        return
end
if nargin==1
        if isempty(ERP)
                msgboxText =  'cannot export an empty ERP dataset';
                title = 'ERPLAB: pop_erp2asc() error:';
                errorfound(msgboxText, title);
                return
        end
        if ~isfield(ERP, 'bindata')
                msgboxText  =  'cannot export an empty ERP dataset';
                title = 'ERPLAB: pop_erp2asc() error:';
                errorfound(msgboxText, title);
                return
        end
        if isempty(ERP.bindata)
                msgboxText  =  'cannot export an empty ERP dataset';
                title = 'ERPLAB: pop_erp2asc() error:';
                errorfound(msgboxText, title);
                return
        end
        
        %
        % Save ascii file
        %
        [filenamei, pathname] = uiputfile({'*.txt';'*.*'},'Save Exported Averaged file as');
        
        if isequal(filenamei,0)
                disp('User selected Cancel')
                return
        else
                [pathx, filename, ext] = fileparts(filenamei);
                if ~strcmpi(ext,'.txt')
                        ext = '.txt';
                end
                
                filename = [filename ext];
                filename = fullfile(pathname, filename);
                disp(['For text exporting ERP, user selected ' filename])
        end
        
        %
        % Somersault
        %
        [ERP, erpcom] = pop_erp2asc(ERP, filename, 'Warning', 'on', 'History', 'gui');
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

[pathname, filename, ext] = fileparts(filename);

if ~strcmpi(ext,'.txt')
        ext = '.txt';
end
filename = [filename ext];

%
% subroutine
%
erp2asc(ERP, filename, pathname);

filename = fullfile(pathname, filename);
erpcom = sprintf( 'pop_erp2asc( %s, ''%s'');',  inputname(1), filename);

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
end


%
% Completion statement
%
msg2end
return