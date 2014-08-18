% PURPOSE: subroutine for pop_continuousartdet.m
%          Identifies windows containing commonly recorded artifactual potentials (c.r.a.p.) for rejection
%
% FORMAT
%
% [winrej chanrej] = basicrap(EEG, chanArray, ampth, windowms, stepms, firstdet, fcutoff, forder)
%
% INPUTS
%
% EEG         - continuous EEG dataset (EEGLAB's EEG structure)
% chanArray   - channel index(ices) to look for c.r.a.p.  (default all channels)
% ampth       - 1 single value for peak-to-peak threshold within the moving window.
%               2 values for extreme thresholds within the moving window, e.g [-200 200] or [-150 220]
% windowms    - moving window width in msec (default 2000 ms)
% stepms      - moving window step in msec (default 1000 ms)
% firstdet    - 1 means move the moving-window after detecting the first artifactual channel (faster). 0 means scan all channel
%               then move the window (slower).
% fcutoff     - 2 values for frequency cutoffs. empty means no filtering (default)
% forder      - 1 value indicating the order (number of points) of the FIR filter to be used. Default 26
%
% OUTPUTS
%
% EEG         - continuous crap-free EEG dataset
%
% Example 1:
% Reject segment of data where the amplitude (mean value removed) is >= than 200 uV or <= than -300 uV.
% Use a moving window of 2000 ms, 1000 ms step, exploring channels 1 to 12.
%
% EEG = basicrap(EEG, chanArray, ampth, windowms, stepms, firstdet, fcutoff, forder)

% >> EEG = basicrap(EEG, 1:12, [-300 200], 2000, 1000, );
%
%
% Reference:
% [1] ERP Boot Camp: Data Analysis Tutorials. Emily S. Kappenman, Marissa L. Gamble, and Steven J. Luck. UC Davis
%
%
% See also pop_continuousartdet.m filter_tf.m filtfilt.m
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2010

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

function [winrej chanrej] = basicrap(EEG, chanArray, ampth, windowms, stepms, firstdet, fcutoff, forder)

winrej  = [];
chanrej = [];
if nargin<8
        forder = 26;
end
if nargin<7
        forder  = [];
        fcutoff = [];
end
if nargin<6
        firstdet = 1;
end
if nargin<5
        stepms = 2500;
end
if nargin<4
        windowms = 5000;
end
if length(EEG.event)<1
        fprintf('\nbasicrap.m.m did not found remaining event codes.\n')
        return
end
if ~isempty(EEG.epoch)
        msgboxText =  'basicrap() only works for continuous datasets.';
        error(msgboxText)
end

fs      = EEG.srate;
winpnts = floor(windowms*fs/1000); % to samples
stepnts = floor(stepms*fs/1000);% to samples
dursam1 = EEG.pnts;

%
% for searching boundaries inside EEG.event.type
%
if ischar(EEG.event(1).type)
        codebound = {EEG.event.type}; %strings
        indxbound = strmatch('boundary', codebound, 'exact');
else
        indxbound = [];
end
if ~isempty(indxbound)
        timerange = [ EEG.xmin*1000 EEG.xmax*1000 ];
        if timerange(1)/1000~=EEG.xmin || timerange(2)/1000~=EEG.xmax
                posi = round( (timerange(1)/1000-EEG.xmin)*EEG.srate )+1;
                posf = min(round( (timerange(2)/1000-EEG.xmin)*EEG.srate )+1, EEG.pnts );
                pntrange = posi:posf;
        end
        if exist('pntrange','var')
                latebound = [ EEG.event(indxbound).latency ] - 0.5 - pntrange(1) + 1;
                latebound(latebound>=pntrange(end) - pntrange(1)) = [];
                latebound(latebound<1) = [];
                latebound = [0 latebound pntrange(end) - pntrange(1)];
        else
                latebound = [0 [ EEG.event(indxbound).latency ] - 0.5 EEG.pnts ];
        end
        latebound = round(latebound);
else
        latebound = [0 EEG.pnts];
        fprintf('\nWARNING: boundary events were not found.\n');
        fprintf('\tSo, basicrap.m will be applied over the full range of data.\n\n');
end

nibound  = length(latebound);
q = 1;
k = 1;
nchan = length(chanArray);
meanoption = 0; % do nothing about the mean of data
disp('Please wait. This might take several seconds...')

while q<=nibound-1  % segments among boundaries
        bp1 = latebound(q)+1;
        bp2 = latebound(q+1);
        if ~isempty(fcutoff)
                if fcutoff(1)~=fcutoff(2)
                        if length(bp1:bp2)>3*forder
                                % FIR coefficients
                                [b, a labelf] = filter_tf(1, forder, fcutoff(2), fcutoff(1), EEG.srate); % FIR
                                if q==1
                                        fprintf('\nYour data are temporary being %s filtered at a cutoff = [%.1f %.1f]\nworking...\n\n', lower(labelf), fcutoff(1), fcutoff(2));
                                end
                                if isdoublep(EEG.data)
                                        EEG.data(chanArray,bp1:bp2) = filtfilt(b,a, EEG.data(chanArray,bp1:bp2)')';
                                else
                                        EEG.data(chanArray,bp1:bp2) = single(filtfilt(b,a, double(EEG.data(chanArray,bp1:bp2))')');
                                end
                                fproblems = nnz(isnan(EEG.data(chanArray,bp1:bp2)));
                                if fproblems>0
                                        msgboxText = ['Oops! filter is not working properly. Data have undefined numerical results.\n'...
                                                'We strongly recommend that you change some filter parameters,\n'...
                                                'for instance, decrease filter order.'];
                                        %msgboxText = sprintf(msgboxText);
                                        error(msgboxText);
                                end
                        else
                                fprintf('\nWARNING: EEG segment from sample %d to %d was not filtered\n', bp1,bp2);
                                fprintf('because number of samples must be >= 3 x filter''s order.\n\n');
                        end
                else
                        if fcutoff(1)==0
                                meanoption = 1; % remove mean
                                if q==1
                                        fprintf('\nThe mean of your data is temporary being remove out.\nworking...\n\n');
                                end
                        else
                                meanoption = 2; % get only the mean
                                if q==1
                                        fprintf('\nThe mean of your data is temporary being isolated for assessment.\nworking...\n\n');
                                end
                        end
                end
        end
        
        %
        % Moving window
        %
        j = bp1;
        while j<=bp2-(winpnts-1)
                t1 = j+1;
                t2 = j+winpnts-1;
                chanvec = zeros(1, EEG.nbchan);
                for ch=1:nchan
                        % get the data window
                        datax2 = EEG.data(chanArray(ch), t1:t2);
                        if meanoption==1 % remove the mean from the data
                                datax2 = datax2 - mean(datax2);
                        end
                        vmin = min(datax2); vmax = max(datax2);
                        if length(ampth)==1
                                if meanoption~=2
                                        vdiff = abs(vmax - vmin);
                                else % assess only the mean of the data
                                        vdiff = mean(datax2);
                                end
                                if vdiff>ampth
                                        chanvec(chanArray(ch)) = 1;
                                end
                                if firstdet; break;end
                        else
                                if meanoption==2 % assess only the mean of the data
                                        vmin = mean(datax2);
                                        vmax = vmin;
                                end
                                if vmin<=ampth(1) || vmax>=ampth(2)
                                        chanvec(chanArray(ch)) = 1;
                                end
                                if firstdet; break;end
                        end
                end
                if nnz(chanvec)>0
                        winrej(k,:) = [t1 t2]; % start and end samples for rejection
                        chanrej(k,:)= chanvec;
                        k=k+1;
                end
                j=j+stepnts;
        end
        q = q + 1; % next segment
end
