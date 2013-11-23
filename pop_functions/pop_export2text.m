% PURPOSE  :	Exports ERP set to text
%
% FORMAT   :
%
% ERP = pop_export2text(ERP, filename, binArray, parameters)  
%
%
% INPUTS     :
%
% ERP           - ERPset (ERPLAB structure) 
% filename      - filename of outputted file
% binArray      - bins to export
%
% The available parameters are as follows:
% 
%         'time'        - 'on'=include time values; 'off'=don't include time values
%         'timeunit'    - 1=seconds; 1E-3=milliseconds
%         'electrodes'  - 'on'=include electrode labels' 'off'=don't include electrode labels
%         'transpose'   - 'on'= (points=rows) & (electrode=columns)
%                         'off' = (electrode=rows) & (points=column)
%         'precision'   - [float] number of significant digits in output. Default 4.
%
% OUTPUTS
%
% - text file
%
%
% EXAMPLE :
%
% ERP = pop_export2text( ERP, '/Users/etfoo/Documents/MATLAB/test.txt', [ 1 2],'time','on','timeunit',1,'electrodes','on',...
%                       'transpose','off','precision',4);
%
%
% See also export2textGUI.m
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Eric Foo
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
%
% BUGs FIXED
% Jan 3, 2012. Replace forbidden characters for bindesc and chan labels. Thanks Naomi Bleich

function [ERP, erpcom] = pop_export2text(ERP, filename, binArray, varargin)
erpcom = '';
if nargin < 1
        help pop_export2text;
        return;
end;
if isempty(ERP)
        msgboxText =  'No ERPset was found!';
        title_msg  = 'ERPLAB: pop_export2text() error:';
        errorfound(msgboxText, title_msg);
        return
end
if ~isfield(ERP, 'bindata')
        msgboxText =  'pop_export2text cannot export an empty ERP dataset';
        title = 'ERPLAB: pop_export2text() error:';
        errorfound(msgboxText, title);
        return
end
if isempty(ERP.bindata)
        msgboxText =  'pop_export2text cannot export an empty ERP dataset';
        title = 'ERPLAB: pop_export2text() error:';
        errorfound(msgboxText, title);
        return
end
if nargin==1    
        def  = erpworkingmemory('pop_export2text');
        if isempty(def)
                def = {1,1000, 1, 1, 4, 1, ''};
        end
        
        %
        % Call GUI
        %
        answer = export2textGUI(ERP, def);
        
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        
        istime    = answer{1};
        tunit     = answer{2};
        islabeled = answer{3};
        transpa   = answer{4};
        prec      = answer{5};
        binArray  = answer{6};
        filename  = answer{7};
        
        erpworkingmemory('pop_export2text', answer);
        
        if istime
                time = 'on';
        else
                time = 'off';
        end
        if islabeled
                elabel = 'on';
        else
                elabel = 'off';
        end
        if transpa
                tra = 'on';
        else
                tra = 'off';
        end
        
        %
        % Somersault
        %
        [ERP, erpcom] = pop_export2text(ERP, filename, binArray, 'time', time, 'timeunit', tunit, 'electrodes', elabel,...
                'transpose', tra, 'precision', prec, 'History', 'gui');
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
p.addRequired('binArray', @isnumeric);
% option(s)
p.addParamValue('time', 'on', @ischar);
p.addParamValue('timeunit', 1E-3, @isnumeric); % milliseconds by default
p.addParamValue('electrodes', 'on', @ischar);
p.addParamValue('transpose', 'on', @ischar);
p.addParamValue('precision', 4, @isnumeric);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ERP, filename, binArray, varargin{:});

if strcmpi(p.Results.time, 'on')
        time = 1;
else
        time = 0;
end
timeunit   = p.Results.timeunit;
if strcmpi(p.Results.electrodes, 'on')
        electrodes = 1;
else
        electrodes = 0;
end
if strcmpi(p.Results.transpose, 'on')
        transpose = 1;
else
        transpose = 0;
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
precision  = p.Results.precision;

%
% subroutine
%
serror = export2text(ERP, filename, binArray, time, timeunit, electrodes, transpose, precision);

if serror==1
        msgboxText = 'Something went wrong...\n';
        etitle = 'ERPLAB: appenderpGUI inputs';
        errorfound(sprintf(msgboxText), etitle);
        return
end

%
% History
%
skipfields = {'ERP', 'filename', 'binArray','History'};
fn     = fieldnames(p.Results);
erpcom = sprintf( 'pop_export2text( %s, ''%s'', %s', inputname(1), filename, vect2colon(binArray)  );
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
