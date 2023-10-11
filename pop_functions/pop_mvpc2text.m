
% PURPOSE  :	Exports MVPC set to text
%
% FORMAT   :
%
% MVPC = pop_mvpc2text(MVPC, filename, binArray, parameters)  
%
%
% INPUTS     :
%
% MVPC          - MVPCset (ERPLAB structure) 
% filename      - filename of outputted file
%
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
% MVPC = pop_mvpc2text( MVPC, '/Users/amsimmon/Documents/filename.txt',  
% 'time', 'on', 'timeunit',  0.001 )
%
%
% See also mvpc2textGUI.m   mvpc2text.m
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Aaron Matthew Simmons
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2023

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
function [MVPC, mvpccom] = pop_mvpc2text(MVPC, filename, varargin)
mvpccom = '';
if nargin < 1
        help pop_mvpc2text;
        return;
end
if isempty(MVPC)
        msgboxText =  'No MVPCset was found!';
        title_msg  = 'ERPLAB: pop_mvpc2text() error:';
        errorfound(msgboxText, title_msg);
        return
end
if ~isfield(MVPC, 'average_score') %or use if DecodingUnit == 'None'? 
        msgboxText =  'pop_mvpct2text cannot export an empty ERP dataset';
        title = 'ERPLAB: pop_mvpc2text() error:';
        errorfound(msgboxText, title);
        return
end

if nargin==1    
        def  = erpworkingmemory('pop_mvpc2text');
        if isempty(def)
                def = {1,1E-3, 0,''};
                %istime
                %timeunit
                %transpose
                %precision
                %filename 
        end
        
        %
        % Call GUI
        %
        %answer = mvpc2textGUI(MVPC, def); %app designer
        
        app = feval('mvpc2textGUI',MVPC,def);
        waitfor(app,'FinishButton',1); 
        
        try
            answer = app.output; %NO you don't want to output BEST, you want to output the parameters to run decoding
            app.delete; %delete app from view
            pause(0.5); %wait for app to leave
        catch
            disp('User selected Cancel');
            return
        end
        
        istime    = answer{1};
        tunit     = answer{2};
        transpa   = answer{3};
        filename  = answer{4};
        
        erpworkingmemory('pop_mvpc2text', answer);
        
        if istime
                time = 'on';
        else
                time = 'off';
        end
        
        if transpa
                tra = 'on';
        else
                tra = 'off';
        end
        
        
        
        %
        % Somersault
        %
        [MVPC, mvpccom] = pop_mvpc2text(MVPC, filename, 'time', time, 'timeunit', tunit, ...
                'transpose', tra,'History', 'gui');
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('MVPC');
p.addRequired('filename', @ischar);
%p.addRequired('binArray', @isnumeric);
% option(s)
p.addParamValue('time', 'on', @ischar);
p.addParamValue('timeunit', 1E-3, @isnumeric); % milliseconds by default
p.addParamValue('transpose', 'on', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(MVPC, filename, varargin{:});

if strcmpi(p.Results.time, 'on')
        time = 1;
else
        time = 0;
end
timeunit   = p.Results.timeunit;

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
%precision  = p.Results.precision;

%
% subroutine
%
serror = mvpc2text(MVPC, filename,time, timeunit, transpose);

if serror==1
        msgboxText = 'Something went wrong...\n';
        etitle = 'ERPLAB: appenderpGUI inputs';
        errorfound(sprintf(msgboxText), etitle);
        return
end

%
% History
%
skipfields = {'MVPC', 'filename','History'};
fn     = fieldnames(p.Results);
mvpccom = sprintf( 'pop_mvpc2text( %s, ''%s'', %s', inputname(1), filename );
for q=1:length(fn)
        fn2com = fn{q};
        if ~ismember_bc2(fn2com, skipfields)
                fn2res = p.Results.(fn2com);
                if ~isempty(fn2res)
                        if ischar(fn2res)
                                if ~strcmpi(fn2res,'off')
                                        mvpccom = sprintf( '%s ''%s'', ''%s''', mvpccom, fn2com, fn2res);
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
                                                mvpccom = sprintf( ['%s, ''%s'', ' fnformat], mvpccom, fn2com, fn2resstr);
                                        end
                                else
                                        mvpccom = sprintf( ['%s, ''%s'', ' fnformat], mvpccom, fn2com, fn2resstr);
                                end
                        end
                end
        end
end
mvpccom = sprintf( '%s );', mvpccom);
% get history from script. ERP
switch shist
        case 1 % from GUI
                displayEquiComERP(mvpccom);
        case 2 % from script
                %MVPC = erphistory(MVPC, [], mvpccom, 1);
        case 3
                % implicit
                %ERP = erphistory(ERP, [], erpcom, 1);
                %fprintf('%%Equivalent command:\n%s\n\n', erpcom);
        otherwise %off or none
                mvpccom = '';
end

%
% Completion statement
%
msg2end
return





