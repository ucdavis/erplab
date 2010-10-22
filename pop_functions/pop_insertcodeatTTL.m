% Usage
%
% >> pop_insertcodeatTTL(EEG, newcode, channel, relop, thresh, refract, absolud, windowms, durapercen)
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
% >> EEG = pop_insertcodeatTTL(EEG, 999, 37, '>=', 60, 600);
%
%
% 2)Insert a new code 777 when channel 1 (Fp1) is greater or equal to +/-120 uV.
%   Use a refractory period of 1000 ms. Use a testing window of 300 ms.
%   The duration of the "ativity" should be 150 ms at least (50% of testing window)
%
% >> EEG = pop_insertcodeatTTL(EEG, 777,  1, '>=', 120, 1000, 'absolute', 300, 50);
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

function [EEG com] = pop_insertcodeatTTL(EEG, channel, relop, thresh, newcode, durcond)

com = '';

if nargin<1
      help pop_insertcodeatTTL
      return
end
if nargin>6
      
      msgboxText =  'pop_insertcodeatTTL needs 6 parameters ';
      title = 'ERPLAB: pop_insertcodeatTTL GUI error';
      errorfound(msgboxText, title);
      return
end
if isempty(EEG(1).data)
      msgboxText{1} =  'cannot work with an empty dataset';
      title = 'ERPLAB: pop_insertcodeatTTL() error:';
      errorfound(msgboxText, title);
      return
end
if ~isempty(EEG.epoch)
      
      msgboxText =  'pop_insertcodeatTTL() only works with continuous data.';
      title = 'ERPLAB: pop_insertcodeatTTL GUI error';
      errorfound(msgboxText, title);
      return
end
if nargin==1
      
      answer  = insertcodeatTTLGUI(EEG);
      
      if isempty(answer)
            disp('User selected Cancel')
            return
      end
      
      channel = answer{1}; % TTL chanel(s)
      thresh  = answer{2}; % threshold to identify TTL-like pulse
      newcode = answer{3}; % new code to insert at the onset of a TTL.
                           % by default is the duration of the TTL in samples.
      durcond = answer{4}; % new code to insert at the onset of a TTL.
      relop   = answer{5}; % relational operator ''<'', ''<='', ''>='', or ''>''';
      
      if ~isempty(find(abs(newcode)>65535, 1))
            msgboxText =  'Event codes greater than +/- 65535 are not allowed.';
            title = 'ERPLAB: pop_insertcodeatTTL GUI error';
            errorfound(msgboxText, title);
            return
      end
      if nnz(~ismember(channel,1:EEG.nbchan))>0
            msgboxText =  'This channel does not exist!';
            title = 'ERPLAB: pop_insertcodeatTTL GUI error';
            errorfound(msgboxText, title);
            return
      end
else      
      if nargin<3
            msgboxText =  'pop_insertcodeatTTL needs 3 inputs, at least. See help.';
            title = 'ERPLAB: pop_insertcodeatTTL GUI error';
            errorfound(msgboxText, title);
            return
      end
      if nargin<6
            durcond = []; % 100%
      end
      if nargin<5
            newcode = [];
      end
end

fs = EEG.srate;
durcondsamp = round(durcond*fs/1000);

% identify relational operator
[tf, locrelop] = ismember(relop,{'<' '<=' '>=' '>'});

if ~tf
      msgboxText{1} =  'Wrong relational operator';
      msgboxText{2} =  'Please, only use ''<'', ''<='', ''>='', or ''>''';
      title = 'ERPLAB: pop_insertcodeatTTL GUI error';
      errorfound(msgboxText, title);
      return
end

% EEG = insertcodeonthefly(EEG, newcode, channel, locrelop, thresh, refract, absoludn, windowsam, durapercen);
EEG = TTL2event(EEG, channel, thresh, newcode, durcondsamp, locrelop);

% [EEG com] = pop_insertcodeatTTL(EEG, channel, relop, threshold, newcode, durcond)

com = sprintf('%s = pop_insertcodeatTTL(%s, %s, ''%s'', %s, %s, %s);', inputname(1), inputname(1), ...
      vect2colon(channel), relop, num2str(thresh), num2str(newcode), num2str(durcond));

try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
return