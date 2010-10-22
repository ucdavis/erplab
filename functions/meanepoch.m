% Get mean value between latencies (in msec) for single epochs.
%
% USAGE
% 
% Example 1
% Get mean values between 200 and 400 ms for channels 3, 5, 7, and 16, at epochs 1, 3, 6, 23, 45, 67, 89, 112, and 214.
% Use as a reference the mean value between -200 to 200 (baseline reference)
% 
% mvalues = meanepoch(EEG,[200 400], [3 5 7 16], [1 3 6 23 45 67 89 112 214],[-200 200])
%
% Example 2
% Get mean values between 100 and 200 ms for all channels 3, 5, 7, and 16, at epochs 1, 3, 6, 23, 45, 67, 89, 112, and 214.
% Use as a reference the mean value between -200 to 200 (baseline reference)
% 
% mvalues = meanepoch(EEG,[200 400], [3 5 7 16], [1 3 6 23 45 67 89 112 214],[-200 200])
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

function mvalues = meanepoch(EEG, latency, chanArray, epochArray, blcorr)

mvalues = [];
if nargin<1
      help meanepoch
      return
end
if nargin<5
      blcorr = [round(EEG.xmin*1000) 0]; % pre stimulus baseline
end
if nargin<4
      epochArray = 1:EEG.trials; % all epochs by default
end
if nargin<3
      chanArray = 1:EEG.nbchan; % all channels by default
end
if nargin<2
      msgboxText =  ['You must specify a range of latencies (2 values in msec)\n'...
            'in order to get a mean value'];
      title = 'ERPLAB: meanepoch error';
      errorfound(sprintf(msgboxText), title);
      return
end
if isempty(EEG.data)
      msgboxText =  'meanepoch() cannot read an empty dataset!';
      title = 'ERPLAB: meanepoch error';
      errorfound(msgboxText, title);
      return
end
if isempty(EEG.epoch)
      msgboxText =  'meanepoch() only works with epoched data.';
      title = 'ERPLAB: meanepoch error';
      errorfound(msgboxText, title);
      return
end
fs      = EEG.srate;
toffsa  = round(EEG.xmin*fs);                    % in samples
latsamp = round(latency*fs/1000) - toffsa + 1;   % msec to samples
nchanm  = length(chanArray);
nepochm = length(epochArray);
mvalues = zeros(nchanm,nepochm); %allocate memory

for ch=1:nchanm
      for ep=1:nepochm
            blv  = blvalue(EEG, chanArray(ch), epochArray(ep), blcorr); % baseline value
            mvalues(ch,ep)  = mean(EEG.data(chanArray(ch),latsamp(1):latsamp(2), epochArray(ep))) - blv;
      end
end
disp('COMPLETE')

%---------------------------------------------------------------------------------------------------
%-----------------base line mean value--------------------------------------------------------------
function blv = blvalue(EEG, chan, bin, blcorr)

%
% Baseline assessment
%
toffsa = abs(round(EEG.xmin*EEG.srate))+1;
blcnum = blcorr/1000;               % from msec to secs  03-28-2009
%
% Check & fix baseline range
%
if blcnum(1)<EEG.xmin
      blcnum(1) = EEG.xmin;
end
if blcnum(2)>EEG.xmax
      blcnum(2) = EEG.xmax;
end
aa     = round(blcnum(1)*EEG.srate) + toffsa;      % in samples 12-16-2008
bb     = round(blcnum(2)*EEG.srate) + toffsa  ;    % in samples
blv = mean(EEG.data(chan,aa:bb, bin));

