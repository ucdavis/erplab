% Usage
%
% >> pop_insertcodeonthefly(EEG, newcode, channel, relop, thresh, refract, absolud, windowms, durapercen)
%
% EEG          - EEG structure (from EEGLAB)
% newcode      - new code to be inserted (1 value)
% channel      - working channel. Channel with the phenomenon of interest (1 value)
% relop        - relational operator. Operator that tests the kind of relation
%                between signal's amplitude and  thresh. (1 string)
%
%               '=='  is equal to (you can also use just '=')
%               '~='  is not equal to
%               '<'   is less than
%               '<='  is less than or equal to
%               '>='  is greater than or equal to
%               '>'   is greater than
%
% thresh       - threshold value(current EEG recording amplitude units. Mostly uV)
% refract      - period of time in msec, following the current detection,
%                which does not allow a new detection.
%
% absolud      - 'absolute': rectified data before detection,  or  'normal': untouched data
%
% windowms     - testing window width in msec. After the treshold is found, checks the duration
%                  of the phenomenon inside this specifies time (ms).
%
% durapercen   - minimum duration of the phenomenon, specified as a percentage of windowms (%).
%
%
% Examples:
%
% 1)Insert a new code 999 when channel 37 is greater or equal to 60 uV.
%   Use a refractory period of 600 ms.
%
% >> EEG = pop_insertcodeonthefly(EEG, 999, 37, '>=', 60, 600);
%
%
% 2)Insert a new code 777 when channel 1 (Fp1) is greater or equal to +/-120 uV.
%   Use a refractory period of 1000 ms. Use a testing window of 300 ms.
%   The duration of the "ativity" should be 150 ms at least (50% of testing window)
%
% >> EEG = pop_insertcodeonthefly(EEG, 777,  1, '>=', 120, 1000, 'absolute', 300, 50);
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

function [EEG com] = pop_insertcodeonthefly(EEG, newcode, channel, relop, thresh, refract, absolud, windowms, durapercen)

com = '';

if nargin<1
      help pop_insertcodeonthefly
      return
end

if nargin>9
      
      msgboxText =  'pop_insertcodeonthefly needs 9 parameters ';
      title = 'ERPLAB: pop_insertcodeonthefly GUI error';
      errorfound(msgboxText, title);
      return
end

if isempty(EEG(1).data)
      msgboxText{1} =  'cannot work with an empty dataset';
      title = 'ERPLAB: pop_insertcodeonthefly() error:';
      errorfound(msgboxText, title);
      return
end

if ~isempty(EEG.epoch)
      
      msgboxText =  'pop_insertcodeonthefly() only works with continuous data.';
      title = 'ERPLAB: pop_insertcodeonthefly GUI error';
      errorfound(msgboxText, title);
      return
end

if nargin==1
      
      answer  = insertcodeonthefly2GUI(EEG);
      
      if isempty(answer)
            disp('User selected Cancel')
            return
      end
      
      newcode = answer{1};
      
      if abs(newcode)>65535
            msgboxText =  'You cannot use codes greater than +/- 65535.';
            title = 'ERPLAB: pop_insertcodeonthefly GUI error';
            errorfound(msgboxText, title);
            return
      end
      
      channel = answer{2};
      
      if size(channel,1)>1 || size(channel,2)>1
            msgboxText =  'pop_insertcodeonthefly() only works with 1 channel per round';
            title = 'ERPLAB: pop_insertcodeonthefly GUI error';
            errorfound(msgboxText, title);
            return
      end
      
      if channel>EEG.nbchan
            msgboxText =  'This channel does not exist!';
            title = 'ERPLAB: pop_insertcodeonthefly GUI error';
            errorfound(msgboxText, title);
            return
      end
      
      relop      = answer{3};
      thresh     = answer{4};
      refract    = answer{5};
      absoludx    = answer{6};
      
      if absoludx==1
            absolud = 'absolute';
      else
            absolud = 'normal';
      end
      
      windowms   = answer{7};
      durapercen = answer{8};
else
      
      if nargin<5
            msgboxText =  'pop_insertcodeonthefly needs 5 inputs, at least. See help.';
            title = 'ERPLAB: pop_insertcodeonthefly GUI error';
            errorfound(msgboxText, title);
            return
      end
      if nargin<9
            durapercen = 100; % 100%
      end
      if nargin<8
            windowms = [];
      end
      if nargin<7
            absolud = 'normal';
      end
      if nargin<6
            refract = 600;
      end
end

if strcmpi(absolud,'absolute')
      absoludn = 1;
elseif strcmpi(absolud,'normal')
      absoludn = 0;
else
      msgboxText =  'pop_insertcodeonthefly you must enter ''absolute'' or ''normal''';
      title = 'ERPLAB: pop_insertcodeonthefly GUI error';
      errorfound(msgboxText, title);
      return
end

if isempty(windowms)
      windowsam   = 1;  % 1 sample
      durapercen  = 100; % 100%
      windowmsstr = '[]';
else
      windowmsstr = num2str(windowms);
      windowsam   = round((windowms*EEG.srate/1000));
end
if isempty(durapercen)
      durapercen = 100; % 100%
end

% identify relational operator
[tf, locrelop] = ismember(relop,{'=' '==' '~=' '<' '<=' '>=' '>'});
if ~tf
      msgboxText{1} =  'Wrong relational operator';
      msgboxText{2} =  'Please, only use ''='', ''~='', ''<'', ''<='', ''>='', or ''>''';
      title = 'ERPLAB: pop_insertcodeonthefly GUI error';
      errorfound(msgboxText, title);
      return
end

EEG = insertcodeonthefly(EEG, newcode, channel, locrelop, thresh, refract, absoludn, windowsam, durapercen);

com = sprintf('%s = pop_insertcodeonthefly(%s, %s, %s, ''%s'', %s, %s, ''%s'', %s, %s);', inputname(1), inputname(1), ...
      num2str(newcode), vect2colon(channel), relop, num2str(thresh), num2str(refract), absolud, ...
      windowmsstr, num2str(durapercen));

try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
return