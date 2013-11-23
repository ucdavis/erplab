% EXPERIMENTAL FUNCTION. ALPHA VERSION,
%
% PURPOSE: deluncorrar.m deletes uncorrectable artifacts.
%
% ICA analysis is being widely used in EEG research. One of its remarkable applications is the correction 
% of eye movements and eye blink artifacts. These type of tools allow us to recover valuable data that otherwise
% would be thrown out.
% However, there are a couple of instances when correcting an artifact is not a proper thing. For instance,
% when an experimental subject blinks during the presentation of a stimulus, in such a way that s/he does
% not actually see the stimulus. In this case, such artifactual blink should not be corrected. Instead,
% the whole trial should be rejected/excluded from the analysis. Otherwise, it would be analogous to
% representing zero values as missed button presses, in an analysis of mean reaction times.
%
% deluncorrar.m allows you to automatically identify either large peak-to-peak differences or extreme amplitude
% values, within a window around your presentation event codes, across your continuous EEG dataset.
% After performing deluncorrar.m, artifactual segments will be rejected and replaced by a 'boundary' event code.
%
% FORMAT
%
% EEG = deluncorrar(EEG, ampth, evcode, mwindowms, chanArray)
%
% Input:
%
% EEG         - continuous EEG dataset (EEGLAB's EEG structure)
% ampth       - 1 single value for peak-to-peak threshold within the moving window
%             - 2 values for extreme thresholds within the moving window, e.g [-200 200] or [-150 220]
% evcode      - event code(s) to which surrounding data will be explred for artifacts.
% chanArray   - channel index(ices) to look for artifacts
% mwindowms   - range of time around your event code(s). e.g. [-100 100] to be measured (tested)
% cwindowms   - range of time around your event code(s). e.g. [-300 300] to be cutted (rejected)
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
% >> EEG = deluncorrar(EEG, [-70 70], 124, 1:12, [-200 200]);
%
% Example 2:
% Reject segment of data surrounding even codes 14, 21, and 36, from - 100 to 300ms, where the peak-to-peak amplitude is >= 100 uV.
% Explore only channel 40 and 43
%
% >> EEG = deluncorrar(EEG, 100, [14 21 36], [40 43], [-100 300]);
%
% Example 3:
% If a portion of data surrounding even codes 31, from - 100 to 100ms, has a peak-to-peak amplitude >= 100 uV then reject the
% segment located at [-300 300]. Explore only channel 65
%
% >> EEG = deluncorrar(EEG, 100, [14 21 36], 65, [-100 100], [-300 300]);
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Johanna Kreither
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

function EEG = deluncorrar2(EEG, ampth, evcode, chanArray, mwindowms) %, cwindowms )

if nargin<1
      help deluncorrar
      return
end
if nargin<5
      error('deluncorrar works with 5 inputs at least.')
end
% if nargin<6
%       cwindowms = mwindowms; % by default the cutting windows is equal to the testing one.
% end
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

indxevcode = geteventcontlat(EEG, evcode);
neegevent = length(EEG.event);

if isfield(EEG.event,'enable')
      % In case there are empty values at EEG.enable
      enable  = {EEG.event.enable};
      empindx = find(cellfun(@isempty, enable));
      [enable{empindx}] = deal(1);% default value if it is empty
else
      % if EEG.enable does not existe it will be full filled with 1s
      enable = num2cell(ones(1,neegevent));
end
[EEG.event(1:neegevent).enable] = enable{:};
if isfield(EEG.event,'duration')
      % In case there are empty values at EEG.enable
      duration  = {EEG.event.duration};
      empindx = find(cellfun(@isempty, duration));
      [duration{empindx}] = deal(0);% default value if it is empty
      durationbckup = duration;
else
      % if EEG.enable does not existe it will be full filled with 1s
      duration = num2cell(ones(1,neegevent));
      durationbckup = duration;
end

[EEG.event(1:neegevent).duration] = duration{:};
[EEG.event(1:neegevent).durationbckup] = duration{:};

fs      = EEG.srate;
dursam1 = EEG.pnts;
mwindowsam  = round((mwindowms*fs)/1000);  % mwindowms in samples
%cwindowsam  = round((cwindowms*fs)/1000);  % cwindowms in samples
%blwindowsam = round((blwindowms*fs)/1000); % blwindowms in samples
nindx = length(indxevcode);
nchan = length(chanArray);
%winrej = [];
k=1;
for i=1:nindx
      for ch=1:nchan   
            samtest = round(EEG.event(indxevcode(i)).latency + mwindowsam); % samples for [start end] related to the continuous data
            if samtest(1)<1
                  samtest(1)=1;
            end
            if samtest(2)>dursam1
                  samtest(2) = dursam1;
            end
            datax = EEG.data(chanArray(ch),samtest(1):samtest(2));
            vmin = min(datax); vmax = max(datax);
            if length(ampth)==1
                  vdiff   = abs(vmax - vmin);
                  if vdiff>ampth
                        %samcutt = round(EEG.event(indxevcode(i)).latency + cwindowsam); % samples for [start end] related to the continuous data
                        %winrej(k,:) = [samcutt(1) samcutt(2)] ;% start and end samples for rejection
                        k=k+1;
                        EEG.event(indxevcode(i)).enable = -1;
                        EEG.event(indxevcode(i)).duration = 50;
                        break
                  end
            else
                  if vmin<=ampth(1) || vmax>=ampth(2)
                        %samcutt = round(EEG.event(indxevcode(i)).latency + cwindowsam); % samples for [start end] related to the continuous data
                        %winrej(k,:) = [samcutt(1) samcutt(2)]; % start and end samples for rejection
                        k=k+1;
                        EEG.event(indxevcode(i)).enable = -1;
                        EEG.event(indxevcode(i)).duration = 50;
                        break
                  end
            end
      end
end
% if isempty(winrej)
%       fprintf('\nCriterion was not found. No rejection was performed.\n');
% else
%       winrej = sort(winrej,1);
%       winrej = unique_bc2(winrej,'rows','first');
%       a = winrej(1,1); winrejaux(1,:) = [a winrej(end,2)]; m=1;
%       for j=2:size(winrej,1)
%             if abs(winrej(j,2)-winrej(j-1,2))>diff(mwindowsam)
%                   b = winrej(j-1,2);
%                   winrejaux(m,:) = [a b];
%                   a = winrej(j,1);
%                   m=m+1;
%             end
%       end
%       winrej = winrejaux;
%       
%       % rejects
%       EEG = eeg_eegrej( EEG, winrej);
%       EEG = eeg_checkset( EEG );
%       if length(EEG.event)>=1
%             if EEG.event(end).latency>dursam1
%                   EEG = pop_editeventvals(EEG,'delete',length(EEG.event));
%                   EEG = eeg_checkset( EEG );
%             end
%       end
%       if length(EEG.event)>=1
%             if EEG.event(1).latency<1
%                   EEG = pop_editeventvals(EEG,'delete',1);
%                   EEG = eeg_checkset( EEG );
%             end
%       end
%       EEG = delshortseg(EEG,'boundary',100); % segments shorter than 100 msec will be deleted
%       dursam2 = EEG.pnts;
%       fprintf([repmat('-',1,60) '\n']);
%       fprintf('Cost:\nYour dataset was shortened %.1f percent.\n', 100-100*(dursam2/dursam1))
%       fprintf([repmat('-',1,60) '\n\n']);
% end
disp('Complete')