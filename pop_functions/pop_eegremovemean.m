% Pending. Function under progress...
%
%
%
% PURPOSE  :	Remove DC offset from a continuous EEG dataset.
%
% FORMAT   :
%
% EEG = pop_eegremovemean( EEG, interval );
%
% INPUTS   :
%
% EEG          	- epoched EEG dataset
% chanArray	      - channel indices to remove DC offset
%
% OUTPUTS
%
% EEG             - (updated) output dataset
%
%
% EXAMPLE  :
%
% EEG = pop_eegremovemean( EEG, 1:40);
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

function [EEG, com] = pop_eegremovemean( EEG, chanArray, varargin)
com = '';
if nargin < 1
        help pop_eegremovemean
        return
end
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if nargin==1
        if isempty(EEG(1).data)
                msgboxText =  'pop_eegremovemean() cannot read an empty dataset!';
                title = 'ERPLAB: pop_lindetrend error';
                errorfound(msgboxText, title);
                return
        end
        if ~isempty(EEG(1).epoch)
                msgboxText =  ['pop_eegremovemean works for continuous data only\n'...
                        'For epoched data you may use a baseline correction.\n'];
                title = 'ERPLAB: pop_lindetrend error';
                errorfound(msgboxText, title);
                return
        end
        titlegui = 'Linear Detrend';
        answer = blcerpGUI(EEG(1), titlegui );  % open GUI
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        chanArray = answer{1};
        
        [EEG, com] = pop_eegremovemean( EEG, chanArray, 'History', 'gui');
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
% option(s)
p.addParamValue('RangeForMean', 'all');
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(EEG, chanArray, varargin{:});

if isempty(EEG(1).data)
        msgboxText =  'pop_eegremovemean() cannot read an empty dataset!';
        error('prog:input', ['ERPLAB says: ' msgboxText]);
end
if ~isempty(EEG(1).epoch)
        msgboxText =  ['pop_eegremovemean works for continuous data only\n'...
                'For epoched data you may use a baseline correction.\n'];
        error('prog:input', ['ERPLAB says: ' msgboxText]);
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

window = p.Results.RangeForMean;

if ischar(window)
        if strcmpi(window,'all') || strcmpi(window,'whole')
                windowsam = [1 EEG.pnts];
        else
                msgboxText = 'Invalid range for getting the mean value.';
                error('prog:input', ['ERPLAB says: ' msgboxText]);
        end
elseif isnumeric(window)
        if isempty(window)
                msgboxText = 'Invalid range for getting the mean value.';
                error('prog:input', ['ERPLAB says: ' msgboxText]);
        end
        if length(window)~=2
                windowsam = [1 window(1)];
        end        
else
        msgboxText = 'Invalid range for getting the mean value.';
        error('prog:input', ['ERPLAB says: ' msgboxText]);
end

%
% process multiple datasets April 13, 2011 JLC
%
if length(EEG) > 1
        [ EEG, com ] = eeg_eval( 'pop_eegremovemean', EEG, 'warning', 'on', 'params', {chanArray});
        return;
end

%
% subroutine
%
EEG.data = removedc(data, windowsam, chanArray);

EEG.setname = [EEG.setname '_ld']; % suggested name (si queris no mas!)
com = sprintf( '%s = pop_eegremovemean( %s, ''%s'' );', inputname(1), inputname(1), interval);

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
                % fprintf('%%Equivalent command:\n%s\n\n', erpcom);
        otherwise %off or none
                com = '';
end

%
% Completion statement
%
msg2end
return


