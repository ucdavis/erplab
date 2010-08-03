% Usage
%
% >> EEG = pop_artbarb(EEG, twin, ccovth, chan, flag);
%
% Inputs
%
% EEG       - input dataset
% twin      - time period in ms to apply this tool (start end). Example [-200 800]
% ccovth    - normalized cros-covarianze (ccov). Value between 0 to 1. Higer ccov means higer similarity
% chan      - channel(s) to search artifacts.
% flag      - flag value between 1 to 8 to be marked when an artifact is found. (1 value)
%
% Output
%
% EEG       - output dataset
%
%  TEMPORARY VERSION. ONLY FOR TESTING
%  Calculates the cross-covarianze between each epoch, at the specified channel(s), with this waveform:
%
%        |
%    ___ |\___
%       \|
%        |
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

function [EEG com]= pop_artbarb(EEG, twin, ccovth, chan, flag)

com = '';

if nargin<1
      help pop_artbarb
      return
end

if isempty(EEG.data)
      disp('pop_artbarb() error: cannot read an empty dataset')
      return
end

if isempty(EEG.epoch)
      msgboxText{1} =  'Permission denied:';
      msgboxText{2} =  'pop_artbarb has been tested for epoched data only';
      title = 'ERPLAB: pop_artbarb Permission';
      errorfound(msgboxText, title);
      return
end

%
% Gui is working...
%
nvar = 5;
if nargin<nvar
      
      prompt = {'Test period (start end) [ms]', 'Normalized Cross-Covarianze Threshold:',...
            'Channel(s)'};
      dlg_title = 'Barb Function';
      defx = {[EEG.xmin*1000 EEG.xmax*1000] 0.7 [1:EEG.nbchan] 0};
      def  = erpworkingmemory('pop_artbarb');
      
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
      
      answer = artifactmenuGUI(prompt,dlg_title,def, defx);
      
      if isempty(answer)
            disp('User selected Cancel')
            return
      end
      
      testwindow = answer{1};
      ccovth     = answer{2};
      chanArray  = unique(answer{3});
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
      
      erpworkingmemory('pop_artbarb', {answer{1} answer{2} answer{3} answer{4}});
      
elseif nargin==nvar
      
      testwindow = twin;
      chanArray  = unique(chan); % avoids repeated channels
      
      if size(flag,1)>1 || size(flag,2)>1
            error('Error: pop_artbarb() you have to specify only one flag.')
      end
      if flag==1
            error('Error: pop_artbarb() flag 1 is reserved.')
      end
      if flag<0 || flag>16
            error('Error: pop_artbarb() flag cannot be greater than 16 or lesser than zero')
      end
else
      error('Error: pop_artbarb() works with 5 arguments')
end

chArraystr = vect2colon(chanArray);

fs       = EEG.srate;
nch      = length(chanArray);
ntrial   = EEG.trials;

[p1 p2 checkw] = window2sample(EEG, testwindow, fs);

if checkw==1
      error('pop_artbarb() error: time window cannot be larger than epoch.')
elseif checkw==2
      error('pop_artbarb() error: too narrow time window')
end

epochwidth = p2-p1+1; % choosen epoch width in number of samples

if nch>EEG.nbchan
      error('Error: pop_artbarb() number of tested channels cannot be greater than total.')
end

if isempty(EEG.reject.rejmanual)
      EEG.reject.rejmanual  = zeros(1,ntrial);
      EEG.reject.rejmanualE = zeros(EEG.nbchan, ntrial);
end

interARcounter = zeros(1,ntrial);           % internal counter, for statistics

fnyquist = fs/2;
[b,a]    = butter(1,([12 100]./fnyquist));  % band pass filtering

y0    = zeros(1,epochwidth);
y0(floor(epochwidth/2):end) = 1;            % step function
y0    = filtfilt(b,a, y0);                  % band pass
ymax  = max(y0);
ymin  = min(y0);
ypp   = ymax-ymin;
yat   = 1/ypp;                              % attenuation by fitering
y0    = y0.*yat;                            % unity amplitude recovering

fprintf('channel #\n ');

for ch=1:nch
      
      fprintf('%g ',chanArray(ch));
      
      for i=1:ntrial;
            
            x  = EEG.data(chanArray(ch),p1:p2,i);
            x  = filtfilt(b,a, x);               % band pass
            [cov_trial] = xcov(x,y0,'coeff');
            xv = max(abs(cov_trial));
            
            if xv>ccovth
                  interARcounter(i)      = 1;      % internal counter, for statistics
                  
                  % flaf 1 is obligatory
                  [EEG errorm]= markartifacts(EEG, [1 flag], chanArray, ch, i);
                  if errorm==1
                        error(['ERPLAB: There was not latency at the epoch ' num2str(i)])
                  elseif errorm==2
                        error('ERPLAB: invalid flag (0<=flag<=8)')
                  end
            end
      end
end
fprintf('\n');

% performance
perreject = nnz(interARcounter)/ntrial*100;
fprintf('pop_artbarb() rejected a %.1f %% of total trials.\n', perreject);

EEG.setname = [EEG.setname '_ar'];
EEG = eeg_checkset( EEG );

if ~ischar(testwindow)
      testwindow = ['[' num2str(testwindow) ']'];
end
namefig = 'PENDING...';
if nargin <nvar
      pop_plotepoch4erp(EEG, namefig)
end
com = sprintf( '%s = pop_artbarb( %s, %s, %s, %s, %s);', ...
      inputname(1), inputname(1), testwindow, num2str(ccovth), chArraystr, num2str(flag));
try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
return
