% Usage
%
% >> EEG = pop_artblink(EEG, twin, bwidth, ccovth, chan, flag);
%
% Inputs
%
% EEG       - input dataset
% twin      - time period in ms to apply this tool (start end). Example [-200 800]
% bwidth    - Width of the simulated blink (Chebyshev window) in ms.
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
%         _
%        / \
%    ___/   \___  w = chebwin(blinkpnts)';
%
%
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

function [EEG com] = pop_artblink(EEG, twin, bwidth, ccovth, chan, flag)

%     EEG = erp_artblink(EEG, [-200 1400], 350, 0.65, 42, 4);

com = '';

if nargin<1
      help pop_artblink
      return
end
if isempty(EEG.data)
      msgboxText{1} =  'Permission denied:';
      msgboxText{2} =  'ERROR: pop_artblink() cannot read an empty dataset!';
      title = 'ERPLAB: pop_artblink';
      errorfound(msgboxText, title);
      return
end
if isempty(EEG.epoch)
      msgboxText{1} =  'Permission denied:';
      msgboxText{2} =  'pop_artblink has been tested for epoched data only';
      title = 'ERPLAB: pop_artblink Permission';
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
nvar = 6;
if nargin<nvar
      
      prompt = {'Test period (start end) [ms]', 'Blink Width [ms]', 'Normalized Cross-Covarianze Threshold:', 'Channel(s)'};
      dlg_title = 'Blink Detection';
      defx = {[EEG.xmin*1000 EEG.xmax*1000] 400 0.7 EEG.nbchan 0};
      def = erpworkingmemory('pop_artblink');
      
      if isempty(def)
            def = defx;
      else
            if def{1}(1)<EEG.xmin*1000
                  def{1}(1) = single(EEG.xmin*1000);
            end
            if def{1}(2)>EEG.xmax*1000
                  def{1}(2) = single(EEG.xmax*1000);
            end
            
            def{4} = def{4}(ismember(def{4},1:EEG.nbchan));
      end
      
      answer = artifactmenuGUI(prompt,dlg_title,def,defx);
      
      if isempty(answer)
            disp('User selected Cancel')
            return
      end
      
      testwindow =  answer{1};
      blinkwidth =  answer{2}; % in msec
      ccovth     =  answer{3};
      chanArray  =  unique(answer{4}); % avoids repeated channels
      flag       =  answer{5};
      
      if ~isempty(find(flag<1 | flag>16, 1))
            msgboxText{1} =  'ERROR, flag cannot be greater than 16 nor lesser than 1';
            title = 'ERPLAB: Flag input';
            errorfound(msgboxText, title);
            return
      end
      
      erpworkingmemory('pop_artblink', {answer{1} answer{2} answer{3} answer{4} answer{5}});
      
elseif nargin==nvar
      testwindow = twin;
      blinkwidth = bwidth;  % in msec
      chanArray  = unique(chan); % avoids repeated channels
      
      if ~isempty(find(flag<1 | flag>16, 1))
            error('ERPLAB says: error at pop_artabsth(). Flag cannot be greater than 16 or lesser than 1')
      end
else
      error('Error: pop_artblink() works with 6 arguments')
end

chArraystr = vect2colon(chanArray);

fs       = EEG.srate;
nch      = length(chanArray);
ntrial   = EEG.trials;

[p1 p2 checkw] = window2sample(EEG, testwindow, fs);

if checkw==1
      error('pop_artblink() error: time window cannot be larger than epoch.')
elseif checkw==2
      error('pop_artblink() error: too narrow time window')
end

epochwidth = p2-p1+1; % choosen epoch width in number of samples

bwidthpntsmax = unique(round(max(blinkwidth*fs/1000)));
bwidthpntsmin = unique(round(min(blinkwidth*fs/1000)));

if nch>EEG.nbchan
      error('Error: pop_artblink() number of tested channels cannot be greater than total.')
end
if bwidthpntsmax>epochwidth
      error('pop_artblink() error: time window cannot be larger than epoch')
elseif bwidthpntsmin<15
      error('pop_artblink() error: too narrow time window')
end

if isempty(EEG.reject.rejmanual)
      EEG.reject.rejmanual  = zeros(1,ntrial);
      EEG.reject.rejmanualE = zeros(EEG.nbchan, ntrial);
end

interARcounter = zeros(1,ntrial); % internal counter, for statistics

fprintf('channel #\n ');
fprintf('%s \n',num2str(chanArray));

nbw = length(blinkwidth);

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

for s =1:nbw
      
      fprintf('Sweep %g: looking for %g msec blinks :\n ', s, blinkwidth(s));
      
      y0    = zeros(1,epochwidth);
      blinkpnts  = round(blinkwidth(s)*fs/1000); % msec to samples
      w    = chebwin(blinkpnts)';
      
      if blinkpnts<epochwidth
            y0 = [w zeros(1,epochwidth-blinkpnts)];
            fp = find(y0==max(y0)); % find y0 peak
            offsetw = round(epochwidth/2)-fp;
            y0 = circshift(y0,offsetw);
      end
      
      for ch=1:nch
            
            fprintf('%g ',chanArray(ch));
            
            for i=1:ntrial;
                  
                  x  = EEG.data(chanArray(ch),p1:p2,i);
                  [cov_trial] = xcov(x,y0,'coeff');
                  xv = max(abs(cov_trial));
                  
                  if xv>ccovth
                        
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
end

% Update EEG.EVENTLIST.bdf structure (for RTs)
% EEG = updatebdfstruct(EEG);

fprintf('\n');

%
% performance
%
perreject = nnz(interARcounter)/ntrial*100;
fprintf('pop_artblink() rejected a %.1f %% of total trials.\n', perreject);

EEG.setname = [EEG.setname '_ar'];
EEG = eeg_checkset( EEG );

if ~ischar(testwindow)
      testwindow = ['[' num2str(testwindow) ']'];
end
namefig = 'Blink rejection (alpha version) view';

if nargin <nvar
      pop_plotepoch4erp(EEG, namefig)
end

flagstr = vect2colon(flag);

com = sprintf( '%s = pop_artblink( %s, [%s], %s, %s, %s, %s);', ...
      inputname(1), inputname(1), testwindow, num2str(blinkwidth), ...
      num2str(ccovth), chArraystr, flagstr);

try cprintf([0 0 1], 'COMPLETE\n\n');catch fprintf('COMPLETE\n\n');end ;
return
