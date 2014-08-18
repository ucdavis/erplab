% PURPOSE  :	Calculates the FFT power spectrum of an EEG dataset
%
% FORMAT   :
%
% pop_fourieeg(EEG, chanArray, f1, f2)
%
%
% INPUTS   :
%
% EEG           - eeglab dataset
% chanArray       - channels that need to be analyzed
% f1            - lower frequency range
% f2            - higher frequency range
%
% OUTPUTS
%
% - Plot of power spectrum
%
%
% EXAMPLE  :
%
% pop_fourieeg( EEG, 1:16, 1, 250);
%
%
% See also fourieegGUI fourieeg.m
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

function [EEG, com] = pop_fourieeg(EEG, chanArray, binArray, varargin)

% pop_fourieeg(EEG, chanArray, binArray, f1, f2, np, latwindow, includelege)

com = '';
if nargin < 1
        help pop_fourieeg
        return
end
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if nargin==1
        if length(EEG)>1
                msgboxText =  'Unfortunately, this function does not work with multiple datasets';
                title = 'ERPLAB: multiple inputs';
                errorfound(msgboxText, title);
                return
        end
        if isempty(EEG.data)
                msgboxText =  'cannot work with an empty EEG dataset';
                title      = 'ERPLAB: pop_fourieeg() error:';
                errorfound(msgboxText, title);
                return
        end
        
        defx = {1 1 0 EEG.srate/2 512 [EEG.xmin EEG.xmax]*1000 1};
        def  = erpworkingmemory('pop_fourieeg');
        
        if isempty(def)
                def = defx;
        end
        
        %
        % call GUI
        %
        answer = fourieegGUI(EEG, def);
        
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        
        chanArray   = answer{1};
        binArray    = answer{2};
        f1          = answer{3};
        f2          = answer{4};
        np          = answer{5};
        latwindow   = answer{6};
        includelege = answer{7};
        
        erpworkingmemory('pop_fourieeg', answer(:)');
        
        %
        % Somersault
        %
        [EEG, com] = pop_fourieeg(EEG, chanArray, binArray, 'StartFrequency', f1, 'EndFrequency', f2, 'NumberOfPointsFFT', np,...
                'Window', latwindow, 'IncludeLegend', includelege, 'History', 'gui');
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG');
p.addRequired('chanArray', @isnumeric);
p.addRequired('binArray', @isnumeric);
% option(s)
p.addParamValue('StartFrequency', [], @isnumeric);
p.addParamValue('EndFrequency', [], @isnumeric);
p.addParamValue('NumberOfPointsFFT', [], @isnumeric);
p.addParamValue('Window', [], @isnumeric);
p.addParamValue('IncludeLegend', 'off', @isnumeric);
p.addParamValue('Warning', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(EEG, chanArray, binArray, varargin{:});

if iseegstruct(EEG)
        if length(EEG)>1
                msgboxText =  'ERPLAB says: Unfortunately, this function does not work with multiple datasets';
                error(msgboxText);
        end
end

f1 = p.Results.StartFrequency;      % Event List file
f2 = p.Results.EndFrequency; % current string for boundaries
np = p.Results.NumberOfPointsFFT;    % new numeric code for replacing string boundaries
latwindow = p.Results.Window;

if strcmpi(p.Results.IncludeLegend,'on')
        includelege = 1;
else
        includelege = 0;
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
if isempty(f1)
        f1=0;
end
if isempty(f2)
        f2= round(EEG.srate/2);
end
if isempty(latwindow)
        latwindow = [EEG.xmin EEG.xmax]*1000; % msec
end

%
% subroutine
%
fourieeg(EEG, chanArray, binArray, f1, f2, np, latwindow, includelege)

%
% History
%
skipfields = {'EEG', 'Saveas', 'History'};
fn     = fieldnames(p.Results);
com = sprintf('%s = pop_fourieeg( %s, %s, %s ', inputname(1), inputname(1), vect2colon(chanArray), vect2colon(binArray));

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
                return
end

%
% Completion statement
%
msg2end
return

% com = sprintf( 'pop_fourieeg( %s, %s, %s, %s, %s);', inputname(1), vect2colon(chanArray), vect2colon(binArray), num2str(f1), num2str(f2));
% % get history from script
% if shist
%         EEG = erphistory(EEG, [], com, 1);
% else
%         com = sprintf('%s %% %s', com, datestr(now));
% end
%
% %
% % Completion statement
% %
% msg2end
% return
