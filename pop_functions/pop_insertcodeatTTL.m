% PURPOSE  : 	Insert new event code(s) at TTL onsets
%
% FORMAT   :
%
% pop_insertcodeatTTL(EEG, chanArray, relop, thresh, newcode, TTLdur)
%
%
% INPUTS   :
%
% EEG          - EEG structure (from EEGLAB)
% chanArray      - working channel. Channel with the phenomenon of interest (1 value)
% relop        - relational operator. Operator that tests the kind of relation
%                between signal's amplitude and  thresh. (1 string)
%               '=='  is equal to (you can also use just '=')
%               '~='  is not equal to
%               '<'   is less than
%               '<='  is less than or equal to
%               '>='  is greater than or equal to
%               '>'   is greater than
% thresh       - threshold value(current EEG recording amplitude units. Mostly uV)
% newcode      - new code to be inserted (1 value)
% TTLdur      - minimum duration of the TTL
%
% OUTPUTS  :
%
% -	Outputted dataset with new eventcodes
%
%
% EXAMPLE  :
%
% 1)Insert a new code 999 when channel 37 is greater or equal to 60 uV.
% Use a refractory period of 600 ms.
%
% EEG = pop_insertcodeatTTL(EEG, 999, 37, '>=', 60, 600);
%
% 2)Insert a new code 777 when channel 1 (Fp1) is greater or equal to +/-120 uV.
% Use a refractory period of 1000 ms. Use a testing window of 300 ms.
% The duration of the "activity" should be 150 ms at least (50% of testing window)
%
% EEG = pop_insertcodeatTTL(EEG, 777,  1, '>=', 120, 1000, 'absolute',
% 300, 50);
%
%
% See also insertcodeatTTLGUI.m TTL2event.m
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

function [EEG, com] = pop_insertcodeatTTL(EEG, chanArray, varargin)
com = '';
if nargin<1
        help pop_insertcodeatTTL
        return
end
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if nargin==1
        if isempty(EEG(1).data)
                msgboxText =  'cannot work with an empty dataset';
                title = 'ERPLAB: pop_insertcodeatTTL() error:';
                errorfound(msgboxText, title);
                return
        end
        if ~isempty(EEG(1).epoch)
                msgboxText =  'pop_insertcodeatTTL() only works with continuous data.';
                title = 'ERPLAB: pop_insertcodeatTTL GUI error';
                errorfound(msgboxText, title);
                return
        end
        
        %
        % Call GUI
        %
        answer  = insertcodeatTTLGUI(EEG(1));
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        
        chanArray = answer{1}; % TTL chanel(s)
        thresh  = answer{2}; % threshold to identify TTL-like pulse
        newcode = answer{3}; % new code to insert at the onset of a TTL.
        
        TTLdur = answer{4}; % duration of the TTL in samples.
        relop   = answer{5}; % relational operator ''<'', ''<='', ''>='', or ''>''';
        % relop = 1 % <  (less than)
        % relop = 2 % <=  ( less than or equal to)
        % relop = 3 % >= (greater than or equal to)
        % relop = 4 % >  (greater than)
        
        
        if ~isempty(find(abs(newcode)>65535, 1))
                msgboxText =  'Event codes greater than +/- 65535 are not allowed.';
                title = 'ERPLAB: pop_insertcodeatTTL GUI error';
                errorfound(msgboxText, title);
                return
        end
        if nnz(~ismember_bc2(chanArray,1:EEG(1).nbchan))>0
                msgboxText =  'This channel does not exist!';
                title = 'ERPLAB: pop_insertcodeatTTL GUI error';
                errorfound(msgboxText, title);
                return
        end
        if ~ismember_bc2(relop,{'<' '<=' '>=' '>'});
                msgboxText =  ['Wrong relational operator\n\n'...
                        'Please, only use ''<'', ''<='', ''>='', or ''>'''];
                title = 'ERPLAB: pop_insertcodeatTTL GUI error';
                errorfound(sprintf(msgboxText), title);
                return
        end
        
        %         switch relop % Relational Operators < > <= >=
        %                 case 1 % <  (less than)
        %                         relopstr = '<';
        %                 case 2 % <=  ( less than or equal to)
        %                         relopstr =  '<=';
        %                 case 3 % >= (greater than or equal to)
        %                         relopstr = '>=';
        %                 case 4 % >  (greater than)
        %                         relopstr = '>';
        %         end

        EEG.setname = [EEG.setname '_inscottl'];        
        
        %
        % Somersault
        %
        %         [EEG, com] = pop_insertcodeatTTL(EEG, chanArray, relop, thresh, newcode, TTLdur)
        
        [EEG, com] = pop_insertcodeatTTL(EEG, chanArray, 'RelationalOperation', relop, 'Threshold', thresh, 'NewCode', newcode,...
                'TTLDuration', TTLdur, 'History', 'gui');
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG');
% option(s)
p.addRequired('chanArray', @isnumeric);
p.addParamValue('RelationalOperation', '', @ischar);
p.addParamValue('NewCode', []);
p.addParamValue('Threshold', [], @isnumeric);
p.addParamValue('TTLDuration', [], @isnumeric);
p.addParamValue('Warning', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(EEG, chanArray, varargin{:});

% EEG, chanArray, relop, thresh, newcode, TTLdur)

relop     = p.Results.RelationalOperation;
newcode   = p.Results.NewCode;
thresh    = p.Results.Threshold;
TTLdur    = p.Results.TTLDuration;

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
[tf, locrelop] = ismember_bc2(relop,{'<' '<=' '>=' '>'});

if ~tf
        msgboxText =  ['ERPLAB says: Wrong relational operator\n'...
                'Please, only use ''<'', ''<='', ''>='', or ''>'''];
        error('prog:input', msgboxText)
end

%         if nargin<3
%                 msgboxText =  'pop_insertcodeatTTL needs 3 inputs, at least. See help.';
%                 title = 'ERPLAB: pop_insertcodeatTTL GUI error';
%                 errorfound(msgboxText, title);
%                 return
%         end
%         if nargin<6
%                 TTLdur = []; % 100%
%         end
%         if nargin<5
%                 newcode = [];
%         end

fs = EEG(1).srate;
TTLdursamp = round(TTLdur*fs/1000);

%
% process multiple datasets April 13, 2011 JLC
%
if length(EEG) > 1
        [ EEG, com ] = eeg_eval( 'pop_insertcodeatTTL', EEG, 'warning', 'on', 'params', {chanArray, relop, thresh, newcode, TTLdur});
        return;
end

%
% subroutine
%
EEG = TTL2event(EEG, chanArray, thresh, newcode, TTLdursamp, locrelop);

%
% History
%
skipfields = {'EEG', 'chanArray','History'};
fn     = fieldnames(p.Results);
com = sprintf('%s = pop_insertcodeatTTL( %s, %s ', inputname(1), inputname(1), vect2colon(chanArray));

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





% com = sprintf('%s = pop_insertcodeatTTL(%s, %s, ''%s'', %s, %s, %s);', inputname(1), inputname(1), ...
%         vect2colon(chanArray), relop, num2str(thresh), num2str(newcode), num2str(TTLdur));
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