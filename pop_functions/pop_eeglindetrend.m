% PURPOSE  :	Remove linear trends from each epoch of an epoched EEG dataset.
%
% FORMAT   :
%
% >> EEG = pop_eeglindetrend( EEG, detwindow );
%
%
% INPUTS   :
%
% EEG            - epoched EEG dataset
% Interval       - time window to estimate the trend. This trend will be
%                  subtracted from the whole epoch.
%
% OUTPUTS
%
% EEG            - (updated) output dataset
%
% EXAMPLE  :
%
% EEG = pop_eeglindetrend( EEG, 'pre');
% EEG = pop_eeglindetrend( EEG, [-300 100]);
%
%
% See also blcerpGUI.m lindetrend.m
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

function [EEG, com] = pop_eeglindetrend( EEG, detwindow, varargin)
com = '';
if nargin < 1
        help pop_lindetrend
        return
end
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if nargin==1
        if isempty(EEG(1).data)
                msgboxText =  'pop_lindetrend() cannot read an empty dataset!';
                title = 'ERPLAB: pop_lindetrend error';
                errorfound(msgboxText, title);
                return
        end
        if isempty(EEG(1).epoch)
                msgboxText =  'pop_lindetrend has been tested for epoched data only';
                title = 'ERPLAB: pop_lindetrend error';
                errorfound(msgboxText, title);
                return
        end
        
        def  = erpworkingmemory('pop_eeglindetrend');
        if isempty(def)
                def = 'pre';
        end 
        
        %
        % Call GUI
        %
        titlegui = 'Linear Detrend';
        answer = blcerpGUI(EEG(1), titlegui, def);  % open GUI
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        detwindow = answer{1};        
        if ischar(detwindow) && strcmpi(detwindow, 'none')
                disp('User selected Cancel')
                return
        end
        if isempty(detwindow) 
                disp('User selected Cancel')
                return
        end
        
        erpworkingmemory('pop_eeglindetrend', detwindow);
        
        if length(EEG)==1
                EEG.setname = [EEG.setname '_ld']; % suggested name (si queris no mas!)
        end
        %
        % Somersault
        %
        wchmsgonstr ='off'; %temporary
        [EEG, com] = pop_eeglindetrend( EEG, detwindow, 'Warning', wchmsgonstr, 'History', 'gui');
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG');
p.addRequired('detwindow');
% option(s)
p.addParamValue('Warning', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(EEG, detwindow, varargin{:});

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

% in case of an error
if ischar(detwindow) && ~strcmpi(detwindow,'all') && ~strcmpi(detwindow,'pre') && ~strcmpi(detwindow,'post')
        internum = str2num(detwindow);
        if length(internum)~=2
                msgboxText = ['Unappropriated time range for detrending\n'...
                        'lindetrend() was ended.\n'];
                if shist == 1; % gui
                        title = 'ERPLAB: pop_eeglindetrend() error';
                        errorfound(sprintf(msgboxText), title);
                        return
                else
                        error('prog:input', msgboxText)
                end
        end
end

%
% process multiple datasets. Updated August 23, 2013 JLC
%
options1 = {detwindow, 'Warning', p.Results.Warning, 'History', 'gui'};
if length(EEG) > 1
        [ EEG, com ] = eeg_eval( 'pop_eeglindetrend', EEG, 'warning', 'on', 'params', options1);       
        return;
end;

%
% subroutine
%
EEG = lindetrend( EEG, detwindow);
% com = sprintf( '%s = pop_eeglindetrend( %s, ''%s'' );', inputname(1), inputname(1), detwindow);
%
% History
%
skipfields = {'EEG', 'detwindow','Saveas','History'};
fn     = fieldnames(p.Results);
if isnumeric(detwindow)
        dtwin = vect2colon(detwindow);
else
        dtwin = ['''' detwindow ''''];
end
com = sprintf('%s = pop_eeglindetrend( %s, %s', inputname(1), inputname(1), dtwin);
        
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

