% PURPOSE  : 	Insert new code around existing code or replace old code
%
% FORMAT   :
%
% EEG = pop_insertcodearound(EEG, targetcode, newcode, newlate)
%
% INPUTS   :
%
% EEG          - EEG structure (from EEGLAB)
% targetcode   - array of codes that need neighbor(s) code(s)
% newcode      - new code(s) to insert  (new neighbor(s) code(s))
% newlat       - latency(ies) in msec for the new code(s) to insert (new
%                neighbor(s) code(s) latency(ies))
%
% OUTPUTS  :
%
% EEG          -Updated EEG with new event codes
%
% EXAMPLE  :
%
% Example 1:
% Insert a new code 78, 400ms after each code 14
%
% EEG = pop_insertcodearound(EEG, 14, 78, 400);
%
% Example 2:
% Insert a new code 30, 200ms before each code 120
%
% EEG = pop_insertcodearound(EEG, 120, 30, -200);
%
% Example 3:
% Insert two new codes around each code 102:
%     - a code 254 200msec earlier
%     - and a code 255 300ms later.
%
% EEG = pop_insertcodearound(EEG, [102 102], [254 255], [-200 300]);
%
% Example 4:
%  Insert a new code 'LeftResp'  1000 ms before each code 'L1'
%
% EEG = pop_insertcodearound(EEG, 'L1', 'LeftResp', -1000);
%
% Example 5:
% Insert a new code 'LeftResp'  1000 ms before each code 'L1' and code
% 'RightResp' 1000 after 'R1'
%
% EEG = pop_insertcodearound(EEG, {'L1', 'R1'}, {'LeftResp' 'RightResp'}, [-1000 1000]);
%
% Example 6:
% Replace event code 'Boundary' with event code 'Pause'
%
% EEG = pop_insertcodearound(EEG, 'Boundary', 'Pause', 0);
%
%
% See also insertcodearoundGUI.m insertcodearound.m
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

function [EEG, com] = pop_insertcodearound(EEG, varargin)
com = '';
if nargin<1
        help pop_insertcodearound
        return
end
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if nargin==1
        if isempty(EEG(1).data)
                msgboxText =  'pop_insertcodearound() cannot work with an empty dataset';
                title = 'ERPLAB: pop_insertcodearound() error:';
                errorfound(msgboxText, title);
                return
        end
        if ~isempty(EEG(1).epoch)
                msgboxText =  'pop_insertcodearound() only works with continuous data.';
                title = 'ERPLAB: pop_insertcodearound GUI error';
                errorfound(msgboxText, title);
                return
        end
        
        %
        % Call GUI
        %
        answer  = insertcodearoundGUI;
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        targetcode  = answer{1};
        newcode     = answer{2};
        newlate     = answer{3};
        EEG.setname = [EEG.setname '_inscoa'];
        
        %
        % Somersault
        %
        [EEG, com] = pop_insertcodearound(EEG, 'TargetCode', targetcode, 'NewCode', newcode, ...
                'Latency', newlate, 'History', 'gui');
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
p.addParamValue('TargetCode', []);
p.addParamValue('TargetBin', []);
p.addParamValue('NewCode', []);
p.addParamValue('Latency', [], @isnumeric);
p.addParamValue('Warning', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(EEG, varargin{:});

targetcode = p.Results.TargetCode;
targetbin  = p.Results.TargetBin;
newcode    = p.Results.NewCode;
newlate    = p.Results.Latency;

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
if ~isempty(targetcode) && isempty(targetbin) && ~isempty(newcode)
        if ~iscell(targetcode) && ~iscell(newcode)
                if size(targetcode,1)>1 || size(newcode,1)>1 || size(newlate,1)>1
                        msgboxText =  'pop_insertcodearound() only works with row arrays.';
                        title = 'ERPLAB: pop_insertcodearound GUI error';
                        errorfound(msgboxText, title);
                        return
                end
                if size(targetcode,1)~=size(newcode,1) || size(newcode,1)~=size(newlate,1)
                        msgboxText =  'Seed codes (or bins), new codes, and new latencies array must have the same size.';
                        title = 'ERPLAB: pop_insertcodearound GUI error';
                        errorfound(msgboxText, title);
                        return
                end
        end
elseif isempty(targetcode) && ~isempty(targetbin) && ~isempty(newcode)       
        if ~isfield(EEG.event, 'bini')
                msgboxText = 'You specified "targetbin" but EEG.event.bini field does not exist.\nRun Binlister first.';
                title = 'ERPLAB: pop_insertcodearound GUI error';
                errorfound(sprintf(msgboxText), title);
                return
        end
        if ~iscell(targetbin) && ~iscell(newcode)
                if size(targetbin,1)>1 || size(newcode,1)>1 || size(newlate,1)>1
                        msgboxText =  'pop_insertcodearound() only works with row arrays.';
                        title = 'ERPLAB: pop_insertcodearound GUI error';
                        errorfound(msgboxText, title);
                        return
                end
                if size(targetbin,1)~=size(newcode,1) || size(newcode,1)~=size(newlate,1)
                        msgboxText =  'Seed codes (or bins), new codes, and new latencies array must have the same size.';
                        title = 'ERPLAB: pop_insertcodearound GUI error';
                        errorfound(msgboxText, title);
                        return
                end
        end
elseif ~isempty(targetcode) && ~isempty(targetbin) && ~isempty(newcode)
        msgboxText =  'You can specify either targetcode or targetbin but not both...';
        title = 'ERPLAB: pop_insertcodearound GUI error';
        errorfound(msgboxText, title);
        return
elseif isempty(newcode)
        msgboxText =  'You must specify new code(s) for inserting/replacing.';
        title = 'ERPLAB: pop_insertcodearound GUI error';
        errorfound(msgboxText, title);
        return
else
        msgboxText =  'Missing event code (or bin), or new latency.';
        title = 'ERPLAB: pop_insertcodearound GUI error';
        errorfound(msgboxText, title);
        return
end

%
% process multiple datasets April 13, 2011 JLC
%
if length(EEG) > 1
        [ EEG, com ] = eeg_eval( 'pop_insertcodearound', EEG, 'warning', 'on', 'params', {targetcode, newcode, newlate});
        return;
end

%
% subroutine
%
EEG = insertcodearound(EEG, targetcode, targetbin, newcode, newlate);

%
% History
%
skipfields = {'EEG','History'};
fn     = fieldnames(p.Results);
com = sprintf('%s = pop_insertcodearound( %s ', inputname(1), inputname(1));

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

