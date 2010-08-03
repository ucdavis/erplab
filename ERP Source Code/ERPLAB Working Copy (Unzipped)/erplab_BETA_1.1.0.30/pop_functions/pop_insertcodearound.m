% Usage
%
% EEG = pop_insertcodearound(EEG, mastercode, newcode, newlate)
%
% EEG          - EEG structure (from EEGLAB)
% mastercode   - array of codes that need neighbor(s) code(s)
% newcode      - new code(s) to insert  (new neighbor(s) code(s))
% newlat       - latency(ies) in msec for the new code(s) to insert  (new neighbor(s) code(s) latency(ies))
%
% Note:   mastercode, newcode, and newlate must have the same length.
%
% Example 1:
%
% 1)Insert a new code 78  400ms after each code 14
%
% >> EEG = pop_insertcodearound(EEG, 14, 78, 400);
%
%
% Example 2:
%
% 2)Insert a new code 30  200ms before each code 120
%
% >> EEG = pop_insertcodearound(EEG, 120, 30, -200);
%
%
% Example 3:
%
% 3)Insert two new codes around each code 102:
%    - a code 254 200msec earlier
%    - and a code 255 300ms later.
%
% >>EEG = pop_insertcodearound(EEG, [102 102], [254 255], [-200 300]);
%
%
% Example 4:
%
% 3)Insert a new code 'LeftResp'  1000 ms before each code 'L1'
%
% >>EEG = pop_insertcodearound(EEG, 'L1', 'LeftResp', -1000);
%
%
% Example 5:
%
% 3)Insert a new code 'LeftResp'  1000 ms before each code 'L1' and code 'RightResp' 1000 after 'R1'
%
% >>EEG = pop_insertcodearound(EEG, {'L1', 'R1'}, {'LeftResp' 'RightResp'}, [-1000 1000]);
%
%
% Example 6:
%
% 3) Replace event code 'Boundary' with event code 'Pause'
%
% >>EEG = pop_insertcodearound(EEG, 'Boundary', 'Pause', 0);
%
%
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

function [EEG com] = pop_insertcodearound(EEG, mastercode, newcode, newlate)

com = '';

if nargin<1
      help pop_insertcodearound
      return
end

if nargin>4
      msgboxText =  'pop_insertcodearound needs 4 parameters ';
      title = 'ERPLAB: pop_insertcodearound GUI error';
      errorfound(msgboxText, title);
      return
end

if isempty(EEG(1).data)
      msgboxText{1} =  'pop_insertcodearound() cannot work with an empty dataset';
      title = 'ERPLAB: pop_insertcodearound() error:';
      errorfound(msgboxText, title);
      return
end

if ~isempty(EEG.epoch)
      msgboxText =  'pop_insertcodearound() only works with continuous data.';
      title = 'ERPLAB: pop_insertcodearound GUI error';
      errorfound(msgboxText, title);
      return
end

if nargin==1
      answer  = insertcodearoundGUI;
      if isempty(answer)
            disp('User selected Cancel')
            return
      end
      mastercode = answer{1};
      newcode    = answer{2};
      newlate    = answer{3};
end

if ~iscell(mastercode) && ~iscell(newcode)
      if size(mastercode,1)>1 || size(newcode,1)>1 || size(newlate,1)>1
            msgboxText =  'pop_insertcodearound() only works with row arrays.';
            title = 'ERPLAB: pop_insertcodearound GUI error';
            errorfound(msgboxText, title);
            return
      end
      
      if size(mastercode,1)~=size(newcode,1) || size(newcode,1)~=size(newlate,1)
            msgboxText =  'Seed codes, new codes, and new latencies array must have the same size.';
            title = 'ERPLAB: pop_insertcodearound GUI error';
            errorfound(msgboxText, title);
            return
      end
end

EEG = insertcodearound(EEG, mastercode, newcode, newlate);

%
% Master code
%
if iscell(mastercode)
      masterstr = sprintf('{');
      for i=1:length(mastercode)
            
            if ischar(mastercode{i})
                  masterstr = sprintf('%s ''%s''', masterstr, mastercode{i});
            else
                  masterstr = sprintf('%s %s', masterstr, num2str(mastercode{i})) ;
            end
      end
      masterstr = sprintf('%s}', masterstr);
else
      if ischar(mastercode)
            masterstr = ['''' mastercode ''''];
      else
            masterstr = ['[' num2str(mastercode) ']'];
      end
end

%
% Newcode
%
if iscell(newcode)
      newcodstr = sprintf('{');
      for i=1:length(newcode)
            
            if ischar(newcode{i})
                  newcodstr = sprintf('%s ''%s''', newcodstr, newcode{i});
            else
                  newcodstr = sprintf('%s %s', newcodstr, num2str(newcode{i})) ;
            end
      end
      newcodstr = sprintf('%s}', newcodstr);
else
      if ischar(newcode)
            newcodstr = ['''' newcode ''''];
      else
            newcodstr = ['[' num2str(newcode) ']'];
      end
end

%
% New late
%
if iscell(newlate)
      latestr = sprintf('{');
      for i=1:length(newlate)
            if ischar(mastercode{i})
                  latestr = sprintf('%s ''%s''', latestr, newlate{i});
            else
                  latestr = sprintf('%s %s', latestr, num2str(newlate{i})) ;
            end
      end
      latestr = sprintf('%s}', latestr);
else
      if ischar(mastercode)
            latestr = ['''' newlate ''''];
      else
            latestr = ['[' num2str(newlate) ']'];
      end
end

com = sprintf('%s = pop_insertcodearound(%s, %s, %s, %s);', inputname(1), inputname(1), ...
      masterstr, newcodstr, latestr);

try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
return