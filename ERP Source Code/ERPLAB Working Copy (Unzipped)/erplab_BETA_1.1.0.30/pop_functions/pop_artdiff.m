% Usage
%
% >> EEG = pop_artdiff(EEG, twin, ampth, chan, flag);
%
% Inputs
%
% EEG       - input dataset
% twin      - time period in ms to apply this tool (start end). Example [-200 800]
% ampth     - sample-to-sample threshold (in uV)
% chan      - channel(s) to search artifacts.
% flag      - flag value between 1 to 8 to be marked when an artifact is found. (1 value)
%
% Output
%
% EEG       - output dataset
%
%  TEMPORARY VERSION. ONLY FOR TESTING
%  Calculates differences between adjacent samples per each epoch, at the specified channel(s), and compares with ampth.
%
% Author: Javier Lopez-Calderon & Steven Luck
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

function [EEG com] = pop_artdiff(EEG, twin, ampth, chan, flag)

com = '';

if nargin<1
      help pop_artdiff
      return
end

if isempty(EEG.data)
      msgboxText{1} =  'Permission denied:';
      msgboxText{2} =  'ERROR: pop_artdiff() cannot read an empty dataset!';
      title = 'ERPLAB: pop_artdiff';
      errorfound(msgboxText, title);
      return
end

if isempty(EEG.epoch)
      msgboxText{1} =  'Permission denied:';
      msgboxText{2} =  'pop_artdiff has been tested for epoched data only';
      title = 'ERPLAB: pop_artdiff Permission';
      errorfound(msgboxText, title);
      return
end

%
% Gui is working...
%
nvar=5;
if nargin <nvar
      
      prompt = {'Test period (start end) [ms]','Sample-to-Sample Voltage Threshold [uV]:', 'Channel(s)'};
      dlg_title = 'Sample-to-Sample Threshold';
      defx = {[EEG.xmin*1000 EEG.xmax*1000] 30 [1:EEG.nbchan] 0};
      def = erpworkingmemory('pop_artdiff');
      
      if isempty(def)
            def = defx;
      else
            
            if def{1}(1)<EEG.xmin*1000
                  def{1}(1) = single(EEG.xmin*1000);
            end
            if def{1}(2)>EEG.xmax*1000
                  def{1}(2) = single(EEG.xmax*1000);
            end
            
            def{3} = def{3}(ismember(def{3},1:EEG.nbchan));
      end
      
      answer = artifactmenuGUI(prompt,dlg_title,def,defx);
      
      if isempty(answer)
            disp('User selected Cancel')
            return
      end
      
      testwindow = answer{1};
      ampth      = answer{2};
      chanArray  = unique(answer{3}); % avoids repeated channels
      flag       = answer{4};
      
      if size(flag,1)>1 || size(flag,2)>1
            msgboxText{1} =  'ERROR, you have to specify only one flag.';
            title = 'ERPLAB: Flag input';
            errorfound(msgboxText, title);
            return
      end
      
      if flag==1
            msgboxText{1} =  'ERROR, flag 1 is reserved.';
            title = 'ERPLAB: Flag input';
            errorfound(msgboxText, title);
            return
      end
      
      if flag<0 || flag>16
            msgboxText{1} =  'ERROR, flag cannot be greater than 16 nor lesser than 0';
            title = 'ERPLAB: Flag input';
            errorfound(msgboxText, title);
            return
      end
      
      erpworkingmemory('pop_artdiff', {answer{1} answer{2} answer{3} answer{4}});
      
elseif nargin==nvar
      testwindow = twin;
      chanArray = chan;
      
      if size(flag,1)>1 || size(flag,2)>1
            error('Error: pop_artdiff() you have to specify only one flag.')
      end
      if flag==1
            error('Error: pop_artdiff() flag 1 is reserved.')
      end
      if flag<0 || flag>16
            error('Error: pop_artdiff() flag cannot be greater than 16 or lesser than zero')
      end
else
      error('Error: pop_artdiff() works with 5 arguments')
end

if flag<0 || flag>16
      error('Error: pop_artdiff() flag cannot be greater than 16 or lesser than zero')
end

chArraystr = vect2colon(chanArray);

fs       = EEG.srate;
nch      = length(chanArray);
ntrial   = EEG.trials;

[p1 p2 checkw] = window2sample(EEG, testwindow, fs);

if checkw==1
      error('pop_artdiff() error: time window cannot be larger than epoch.')
elseif checkw==2
      error('pop_artdiff() error: too narrow time window')
end

if nch>EEG.nbchan
      error('Error: pop_artdiff() number of tested channels cannot be greater than total.')
end

if isempty(EEG.reject.rejmanual)
      EEG.reject.rejmanual  = zeros(1,ntrial);
      EEG.reject.rejmanualE = zeros(EEG.nbchan, ntrial);
end


interARcounter = zeros(1,ntrial); % internal counter, for statistics

fprintf('channel #\n ');

for ch=1:nch
      
      fprintf('%g ',chanArray(ch));
      
      for i=1:ntrial;
            
            diffEEG = diff(EEG.data(chanArray(ch), p1:p2 ,i));
            diffpeak = max(abs(diffEEG));
            
            if diffpeak>ampth
                  
                  interARcounter(i) = 1;      % internal counter, for statistics
                  % flaf 1 is obligatory
                  [EEG errorm]= markartifacts(EEG, [1 flag], chanArray, ch, i);
                  if errorm==1
                        error(['ERPLAB: There was not latency at the epoch ' num2str(i)])
                  elseif errorm==2
                        error('ERPLAB: invalid flag (0<=flag<=16)')
                  end
            end
      end
end

fprintf('\n');

% performance
perreject = nnz(interARcounter)/ntrial*100;
fprintf('pop_artdiff() rejected a %.1f %% of total trials.\n', perreject);

EEG.setname = [EEG.setname '_ar'];
EEG = eeg_checkset( EEG );

if ~ischar(testwindow)
      testwindow = ['[' num2str(testwindow) ']'];
end
namefig = 'Sample to sample voltage threshold (alpha version) view';
if nargin <nvar
      pop_plotepoch4erp(EEG, namefig)
end
com = sprintf( '%s = pop_artdiff( %s, %s, %s, %s, %s);', ...
      inputname(1), inputname(1), testwindow, num2str(ampth), chArraystr, num2str(flag));
try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
return