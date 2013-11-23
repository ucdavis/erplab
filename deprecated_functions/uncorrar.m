% DEPRECATED...
%
%
%
%
% deluncorrar.m (alpha version). Delete uncorrectable artifacts.
%
% ICA analysis is being widely used in EEG research. One of its remarkable applications is the correction 
% of eye movements and eye blink artifacts. These type of tools allow us to recover valuable data that otherwise
% would be thrown out.
% However, there are a couple of instances when correcting an artifact is not a proper thing. For instance,
% when an experimental subject blinks during the presentation of a stimulus, in such a way that s/he does
% not actually see the stimulus. In this case, such artifactual blink should not be corrected. Instead,
% the whole trial should be rejected/excluded from the analysis. Otherwise, it would be analog to include
% zero values, as representing missed button press, in an analysis of mean reaction times.
%
% deluncorrar.m allows you to automatically identify either large peak-to-peak differences or extreme amplitude
% values, within a window around your presentation event codes, across your continuous EEG dataset.
% After performing deluncorrar.m, artifactual segments will be rejected and replaced by a 'boundary' event code.
%
% USAGE
%
% EEG = deluncorrar(EEG, evcode, ampth, mwindowms, chanArray);
%
% Input:
%
% EEG         - continuous EEG dataset (EEGLAB's EEG structure)
% ampth       - 1 single value for peak-to-peak threshold within the moving window
%             - 2 values for extreme thresholds within the moving window, e.g [-200 200] or [-150 220]
% mwindowms   - range of time around your event code(s). e.g. [-300 300]
% chanArray   - channel index(ices) to look for artifacts  (default all channels)
%
%
% Output:
%
% EEG         - continuous EEG dataset without artifact surroundin presentation even codes (EEGLAB's EEG structure)
%
%
%
% Example 1:
% Reject segment of data surrounding an even code 124, from - 200 to 200ms, when the instantaneous amplitude is >= than 70 uV or <= than -70 uV.
% Explore channels 1 to 12.
%
% >> EEG = deluncorrar(EEG, 124, [-70 70], [-200 200], 1:12);
%
% Example 2:
%
% Reject segment of data surrounding even codes 14, 21, and 36, from - 100 to 300ms, where the peak-to-peak amplitude is >= 100 uV.
% Explore only channel 40 and 43
%
% >> EEG = deluncorrar(EEG, [14 21 36], 100, [-100 300], [40 43]);
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
%
%
% Debugging :
% bug at ampth with 2 values was fixed. JLC & J.Kreither
% remove dc option was added
%
function EEG = deluncorrar(EEG, evcode, ampth, mwindowms, chanArray)

if nargin<1
      help deluncorrar
      return
end
if nargin<5
      chanArray = 1:EEG.nbchan; % all channels by default
end
if nargin<4
      error('deluncorrar works with 4 inputs at least.')
end
if length(EEG)>1
      msgboxText =  'Unfortunately, this function does not work with multiple datasets';
      error(msgboxText)
end
if ~isempty(EEG.epoch)
      msgboxText =  'deluncorrar() only works for continuous datasets.';
      error(msgboxText)
end
if numel(ampth)~=1 && numel(ampth)~=2
      error('ERPLAB says: for threshold amplitude you must specify 1 or 2 values only.')
end


%
% for searching boundaries inside EEG.event.type
%
if ischar(EEG.event(1).type)
      codebound = {EEG.event.type}; %strings
else
      codebound = [EEG.event.type]; %numeric code
end

%
% search for boundaries
%
if ischar(evcode) && iscell(codebound)
      indxevcode  = strmatch(evcode, codebound, 'exact');
elseif ~ischar(evcode) && ~iscell(codebound)
      indxevcode  = find(codebound==evcode);
elseif ischar(evcode) && ~iscell(codebound)
      numt = str2num(evcode);
      if ~isempty(numt)
            indxevcode  = find(codebound==numt);
      else
            ferror =1;
            msgboxText = 'You specified a string as event code, but your events are numeric.';
            title = 'ERPLAB: evcode format error';
            errorfound(msgboxText, title);
            return
      end
elseif ~ischar(evcode) && iscell(codebound)
      indxevcode  = strmatch(num2str(evcode), codebound, 'exact');
end

fs = EEG.srate;
mwindowsam  = round((mwindowms*fs)/1000);  % mwindowms in samples
nindx = length(indxevcode);
nchan = length(chanArray);
k=1;
for ch=1:nchan
      for i=1:nindx
            samx = indxevcode(i) - mwindowsam;
            if samx(1)<1
                  samx(1)=1;
            end
            if samx(2)>EEG.pnts
                  samx(2)=EEG.pnts;
            end
            datax = EEG.data(chanArray(ch),samx(1):samx(2));            
            vmin = min(datax); vmax = max(datax);
            if length(ampth)==1
                  vdiff   = abs(vmax - vmin);
                  if vdiff>ampth
                        winrej(k,:) = [samx(1) samx(2)]; % start and end samples for rejection
                        k=k+1;
                  end
            else
                  if vmin<=ampth(1) || vmax>=ampth(2)
                        winrej(k,:) = [samx(1) samx(2)]; % start and end samples for rejection
                        k=k+1;
                  end
            end
      end
end
if isempty(winrej)
      fprintf('\nCriterion was not found. No rejection was performed.\n');
else
      % Selects not overlapping start and end samples
      winrej = sort(winrej,1);
      [aa1 bb1] = unique_bc2( winrej(:,1),'first');
      [aa2 bb2] = unique_bc2( winrej(:,2),'last');
      winrej = [winrej(bb1,1) winrej(bb2,2)];
      a = winrej(1,1); winrej2(1,:) = [a winrej(end,2)]; m=1;
      for j=2:size(winrej,1)
            if abs(winrej(j,2)-winrej(j-1,2))>winpnts
                  b = winrej(j-1,2);
                  winrej2(m,:) = [a b];
                  a = winrej(j,1);
                  m=m+1;
            end
      end
      if winrej2(end,2)~=winrej(end,2)
            winrej2(m,:) = [a winrej(end,2)];
      end
      % rejects
      EEG = eeg_eegrej( EEG, winrej2);
      EEG = eeg_checkset( EEG );
      if length(EEG.event)>=1
            if EEG.event(end).latency>EEG.pnts
                  EEG = pop_editeventvals(EEG,'delete',length(EEG.event));
                  EEG = eeg_checkset( EEG );
            end
      end
      if length(EEG.event)>=1
            if EEG.event(1).latency<1
                  EEG = pop_editeventvals(EEG,'delete',1);
                  EEG = eeg_checkset( EEG );
            end
      end
      EEG = delshortseg(EEG,'boundary',100); % segments shorter than 100 msec will be deleted
      dursam2 = EEG.pnts;
      fprintf([repmat('-',1,60) '\n']);
      fprintf('Cost:\nYour dataset was shortened %.1f percent.\n', 100-100*(dursam2/dursam1))
      fprintf([repmat('-',1,60) '\n\n']);
end
