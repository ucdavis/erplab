% PURPOSE  :	Inserts new (numeric) event codes
%
% FORMAT   :
%
% EEG = pop_insertcodeonthefly(EEG, newcode, chanArray, relatop, thresh, refract, absolud, windowms, durams, latoffset)
%
%
% INPUTS   :
%
%  EEG          - EEG continuous dataset
%  newcode      - new code to be inserted (1 value)
%  chanArray      - working channel. Channel with the phenomenon of interest (1 value)
%  relop        - relational operator. Operator that tests the kind of relation
%                 between signal's amplitude and threshhold. (1 string)
%
%                '=='  is equal to (you can also use just '=')
%                '~='  is not equal to
%                '<'   is less than
%                '<='  is less than or equal to
%                '>='  is greater than or equal to
%                '>'   is greater than
%
%  thresh       - threshold value(current EEG recording amplitude units. Mostly uV)
%  refract      - period of time in msec, following the current detection,
%                 which does not allow a new detection.
%
%  absolud      - 'absolute': rectified data before detection,  or  'normal':
%                 untouched data
%  windowms     - testing window width in msec. After the treshold is found,
%                 checks the duration of the phenomenon inside this specific time
%                 (ms).
%  durams       - minimum duration of the phenomenon in mseconds. durams<=windowms
%  latoffset    - latency offset (msec). Value to adjust the latency of the new
%                 event code to be inserted.
%
% OUTPUTS
%
% EEG           - updated EEG continuous dataset
%
%
%
% EXAMPLE  :
%
% 1)Insert a new code 999 when channel 37 is greater or equal to 60 uV.
%  Use a refractory period of 600 ms.
%
% EEG = insertcodeonthefly( EEG, 999, 37, '>=', 60, 600 );
%
%
% See also insertcodeonthefly2GUI.m insertcodeonthefly.m
%
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

function [EEG, com] = pop_insertcodeonthefly(EEG, chanArray, varargin)
com = '';
if nargin<1
        help pop_insertcodeonthefly
        return
end
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if nargin==1
        if isempty(EEG(1).data)
                msgboxText =  'cannot work with an empty dataset';
                title = 'ERPLAB: pop_insertcodeonthefly() error:';
                errorfound(msgboxText, title);
                return
        end
        if ~isempty(EEG(1).epoch)
                msgboxText =  'pop_insertcodeonthefly() only works with continuous data.';
                title = 'ERPLAB: pop_insertcodeonthefly GUI error';
                errorfound(msgboxText, title);
                return
        end
        
        %
        % Call GUI
        %
        answer  = insertcodeonthefly2GUI(EEG(1));
        
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        newcode = answer{1};
        if length(newcode)>1
                msgboxText =  'You must specify a single code';
                title = 'ERPLAB: pop_insertcodeonthefly GUI error';
                errorfound(msgboxText, title);
                return
        end
        if newcode>65535
                msgboxText =  'You cannot use a code greater than +/- 65535.';
                title = 'ERPLAB: pop_insertcodeonthefly GUI error';
                errorfound(msgboxText, title);
                return
        end
        chanArray = answer{2};
        if size(chanArray,1)>1 %|| size(chanArray,2)>1
                %msgboxText =  'pop_insertcodeonthefly() only works with 1 channel per round';
                %title = 'ERPLAB: pop_insertcodeonthefly GUI error';
                %errorfound(msgboxText, title);
                %return
                chanArray = chanArray';
        end
        if  nnz(chanArray>EEG(1).nbchan)>0
                msgboxText =  'You have specified non-existing channel(s)!';
                title = 'ERPLAB: pop_insertcodeonthefly GUI error';
                errorfound(msgboxText, title);
                return
        end
        
        relatop   = answer{3};
        thresh    = answer{4};
        refract   = answer{5};
        absoludx  = answer{6};
        if any(~ismember_bc2(relatop,{'=' '==' '~=' '<' '<=' '>=' '>'}))
                msgboxText = ['Wrong relational operator\n'...
                        'Please, only use ''='', ''~='', ''<'', ''<='', ''>='', or ''>'''];
                title = 'ERPLAB: pop_insertcodeonthefly GUI error';
                errorfound(sprintf(msgboxText), title);
                return
        end        
        if absoludx==1
                absolud = 'on';
        else
                absolud = 'off';
        end        
        windowms  = answer{7};
        durams    = answer{8};
        latoffset = answer{9};
        
        EEG.setname = [EEG.setname '_inscofly'];
        
        %
        % Somersault
        %        
        [EEG, com] = pop_insertcodeonthefly(EEG, chanArray, 'RelationalOperation', relatop, 'Threshold', thresh, 'NewCode', newcode,...
                'Refractory', refract, 'Absolute', absolud, 'Window', windowms, 'Duration', durams, 'OffsetLatency', latoffset, 'History', 'gui');
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
p.addParamValue('RelationalOperation', '');
p.addParamValue('NewCode', []);
p.addParamValue('Threshold', [], @isnumeric);
p.addParamValue('Duration', 1, @isnumeric);
p.addParamValue('Refractory', 500, @isnumeric);
p.addParamValue('Absolute', 'off', @ischar);
p.addParamValue('Window', 1, @isnumeric);
p.addParamValue('OffsetLatency', 0, @isnumeric);
p.addParamValue('Warning', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(EEG, chanArray, varargin{:});

% EEG, chanArray, relop, thresh, newcode, TTLdur)
if isempty(EEG(1).data)
        msgboxText =  'ERPLAB says: pop_insertcodeonthefly() cannot work with an empty dataset';
        error('prog:input', msgboxText)
end
if ~isempty(EEG(1).epoch)
        msgboxText =  'ERPLAB says: pop_insertcodeonthefly() only works with continuous data.';
        error('prog:input', msgboxText)
end

relatop   = p.Results.RelationalOperation;
newcode   = p.Results.NewCode;
thresh    = p.Results.Threshold;
durams    = p.Results.Duration;
durasam   = round((durams*EEG(1).srate/1000));
refract   = p.Results.Refractory;
windowms  = p.Results.Window;
windowsam = round((windowms*EEG(1).srate/1000));
latoffset = p.Results.OffsetLatency;

if strcmpi(p.Results.Absolute, 'on')
        absoludn = 1;
else
        absoludn = 0;
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
if ~iscell(newcode)
        if size(newcode,1)>1
                msgboxText =  'pop_insertcodeatTTL() only works with row arrays.';
                title = 'ERPLAB: pop_insertcodearound GUI error';
                errorfound(msgboxText, title);
                return
        end
end

% identify relational operator
[tf, locrelop] = ismember_bc2(relatop,{'=' '==' '~=' '<' '<=' '>=' '>'});
if nnz(tf==0)>0
        msgboxText = ['ERPLAB says: Wrong relational operator\n'...
                'Please, only use ''='', ''~='', ''<'', ''<='', ''>='', or ''>'''];
       error('prog:input', msgboxText)
end

%
% process multiple datasets April 13, 2011 JLC
%
if length(EEG) > 1
        [ EEG, com ] = eeg_eval( 'pop_insertcodeonthefly', EEG, 'warning', 'on', 'params',...
                {newcode, chanArray, relatop, thresh, refract, absoludn, windowms, durams});
        return;
end

%
% subroutine
%
EEG = insertcodeonthefly(EEG, newcode, chanArray, locrelop, thresh, refract, absoludn, windowsam, durasam, latoffset);

%
% History
%
skipfields = {'EEG', 'chanArray','History'};
fn     = fieldnames(p.Results);
com = sprintf('%s = pop_insertcodeonthefly( %s, %s ', inputname(1), inputname(1), vect2colon(chanArray));

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