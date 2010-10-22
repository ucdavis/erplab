% Usage
%
% >> EEG = pop_artderiv(EEG, twin, ratech, chan, flag);
%
% Inputs
%
% EEG       - input dataset
% twin      - time period in ms to apply this tool (start end). Example [-200 800]
% ratech    - rate of change threshold in uV/ms.
% chan      - channel(s) to search artifacts.
% flag      - flag value between 1 to 8 to be marked when an artifact is found. (1 value)
%
% Output
%
% EEG       - output dataset
%
%  TEMPORARY VERSION. ONLY FOR TESTING
%  Calculates the time derivative per each epoch, at the specified channel(s), and compares with ratech.
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

function [EEG com] = pop_artderiv(EEG, twin, ratech, chan, flag)

com = '';

if nargin<1
      help pop_artderiv
      return
end
if isempty(EEG.data)
      msgboxText{1} =  'Permission denied:';
      msgboxText{2} =  'ERROR: pop_artderiv() cannot read an empty dataset!';
      title = 'ERPLAB: pop_artderiv';
      errorfound(msgboxText, title);
      return
end
if isempty(EEG.epoch)
      msgboxText{1} =  'Permission denied:';
      msgboxText{2} =  'pop_artderiv has been tested for epoched data only';
      title = 'ERPLAB: pop_artderiv Permission';
      errorfound(msgboxText, title);
      return
end
if isfield(EEG, 'EVENTLIST')
    if isfield(EEG.EVENTLIST, 'eventinfo')
        if isempty(EEG.EVENTLIST.eventinfo)
            msgboxText = ['EVENTLIST.eventinfo structure is empty!\n'...
                'You will not be able to perform ERPLAB''s\n'...
                'artifact detection tools.'];
            title = 'ERPLAB: Error';
            errorfound(sprintf(msgboxText), title);
            return
        end
    else
        msgboxText =  ['EVENTLIST.eventinfo structure was not found!\n'...
            'You will not be able to perform ERPLAB''s\n'...
            'artifact detection tools.'];
        title = 'ERPLAB: Error';
        errorfound(sprintf(msgboxText), title);
        return
    end
else
    msgboxText =  ['EVENTLIST structure was not found!\n'...
        'You will not be able to perform ERPLAB''s\n'...
        'artifact detection tools.'];
    title = 'ERPLAB: Error';
    errorfound(sprintf(msgboxText), title);
    return
end

%
% Gui is working...
%
nvar = 5;
if nargin <nvar
      prompt    = {'Test period (start end) [ms]','Rate of Change [uV/msec]:', 'Channel(s)'};
      dlg_title = 'Rate of Change (Time-Derivative)';
      defx       = {[EEG.xmin*1000 EEG.xmax*1000] 20 [1:EEG.nbchan] 0};
      def = erpworkingmemory('pop_artderiv');
      
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
      
      answer = artifactmenuGUI(prompt, dlg_title, def, defx);
      
      if isempty(answer)
            disp('User selected Cancel')
            return
      end
      
      testwindow =  answer{1};
      ratechange =  answer{2};
      chanArray  =  unique(answer{3}); % avoids repeated channels
      flag       =  answer{4};
      
      if ~isempty(find(flag<1 | flag>16, 1))
            msgboxText{1} =  'ERROR, flag cannot be greater than 16 nor lesser than 1';
            title = 'ERPLAB: Flag input';
            errorfound(msgboxText, title);
            return
      end
      
      erpworkingmemory('pop_artderiv', {answer{1} answer{2} answer{3} answer{4}});
      
elseif nargin==nvar
      testwindow = twin;
      ratechange = ratech;  % sec
      chanArray  = unique(chan); % avoids repeated channels
      
      if ~isempty(find(flag<1 | flag>16, 1))
            error('ERPLAB says: error at pop_artabsth(). Flag cannot be greater than 16 or lesser than 1')
      end
else
      error('Error: pop_artderiv() works with 5 arguments')
end

chArraystr = vect2colon(chanArray);

fs       = EEG.srate;
nch      = length(chanArray);
ntrial   = EEG.trials;
deltat   = 1000/fs; % sample period in msec

[p1 p2 checkw] = window2sample(EEG, testwindow, fs);

if checkw==1
      error('pop_artderiv() error: time window cannot be larger than epoch.')
elseif checkw==2
      error('pop_artderiv() error: too narrow time window')
end

if nch>EEG.nbchan
      error('Error: pop_artderiv() number of tested channels cannot be greater than total.')
end

if isempty(EEG.reject.rejmanual)
      EEG.reject.rejmanual  = zeros(1,ntrial);
      EEG.reject.rejmanualE = zeros(EEG.nbchan, ntrial);
end

interARcounter = zeros(1,ntrial); % internal counter, for statistics

tic
fprintf('channel #\n ');

%
% Tests RT info
%
isRT = 1; % there is RT info by default
if ~isfield(EEG.EVENTLIST.bdf, 'rt')
        isRT = 0;
else
        valid_rt = nnz(~cellfun(@isempty,{EEG.EVENTLIST.bdf.rt}));
        if valid_rt==0
                isRT = 0;
        end
end

for ch=1:nch
      fprintf('%g ',chanArray(ch));
      
      for i=1:ntrial;
            derivEEG = diff(EEG.data(chanArray(ch), p1:p2 ,i))./deltat;
            deripeak = max(abs(derivEEG)); % uV/msec
            
            if deripeak>ratechange
                  
                  interARcounter(i) = 1;      % internal counter, for statistics
                  % flaf 1 is obligatory
                  [EEG errorm]= markartifacts(EEG, flag, chanArray, ch, i, isRT);
                  if errorm==1
                        error(['ERPLAB: There was not latency at the epoch ' num2str(i)])
                  elseif errorm==2
                        error('ERPLAB: invalid flag (0<=flag<=16)')
                  end
            end
      end
end

% Update EEG.EVENTLIST.bdf structure (for RTs)
% EEG = updatebdfstruct(EEG);

fprintf('\n');

% performance
perreject = nnz(interARcounter)/ntrial*100;
fprintf('pop_artderiv() rejected a %.1f %% of total trials.\n', perreject);

toc
EEG.setname = [EEG.setname '_ar'];
EEG = eeg_checkset( EEG );

if ~ischar(testwindow)
      testwindow = ['[' num2str(testwindow) ']'];
end
namefig = 'Rate of change  (time derivative, alpha version view';
if nargin <nvar
      pop_plotepoch4erp(EEG, namefig)
end

flagstr = vect2colon(flag);

com = sprintf( '%s = pop_artderiv( %s, %s, %s, %s, %s);', ...
      inputname(1), inputname(1), testwindow, num2str(ratechange), chArraystr, flagstr);

try cprintf([0 0 1], 'COMPLETE\n\n');catch fprintf('COMPLETE\n\n');end ;
return