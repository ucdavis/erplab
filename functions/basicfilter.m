%     EEG         - input dataset
%     chanArray   - channel(s) to filter
%     locutoff    - lower edge of the frequency pass band (Hz)  {0 -> lowpass}
%     hicutoff    - higher edge of the frequency pass band (Hz) {0 -> highpass}
%     filterorder - length of the filter in points {default 3*fix(srate/locutoff)}
%     typef       - type of filter: 0=means IIR Butterworth;  1 = means FIR
%
%     Outputs:
%     EEG         - output dataset
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

function [EEG ferror] = basicfilter(EEG, chanArray, locutoff, hicutoff, filterorder, typef, remove_dc, boundary)

ferror = 0; % no filter error by default

if nargin < 1
      help basicfilter
      return
end

% fprintf('basicfilter.m : START\n');

if exist('filtfilt','file') ~= 2
      error('ERPLAB says: error at basicfilter(). Cannot find the Signal Processing Toolbox');
end
if isempty(EEG.data)
      error('ERPLAB says: error at basicfilter(). Cannot filter an empty dataset')
end
if nargin < 7
      error('ERPLAB says: error at basicfilter(). Please, enter all arguments!')
end
if EEG.pnts <= 3*filterorder
      msgboxText{1} =  'The length of the data must be more than three times the filter order.';
      title = 'ERPLAB: basicfilter(), filtfilt constraint';
      errorfound(msgboxText, title);
      return
end
if locutoff == 0 && hicutoff == 0,
      error('ERPLAB says: Hey dude, I need both lower and higher cuttof in order to filter your data...');
end
if ~isempty(EEG.epoch)
      boundary = []; % not allowed for epoched data
end

chanArray = unique(chanArray); % does not allow repeated channels
fnyquist  = 0.5*EEG.srate;       % half sample rate
pnts      = size(EEG.data,2);
numchan   = length(chanArray);

if numchan>EEG.nbchan
      msgboxText{1} =  'You do not have such amount of channels in your data!';
      title = 'ERPLAB: basicfilter() error:';
      errorfound(msgboxText, title);
      return
end

ntrials = EEG.trials;

if locutoff >= fnyquist
      error('ERPLAB says: error at basicfilter(). Low cutoff frequency cannot be >= srate/2');
end
if hicutoff >= fnyquist
      error('ERPLAB says: error at basicfilter(). High cutoff frequency cannot be >= srate/2');
      
end
if ~typef && filterorder*3 > pnts          % filtfilt restriction
      fprintf('basicfilter: filter order too high');
      error('ERPLAB says: error at basicfilter(). Number of samples must be, at least, 3 times the filter order.');
end

[b, a, labelf, v] = filter_tf(typef, filterorder, hicutoff, locutoff, EEG.srate);

if ~v  % something is wrong or turned off
      msgboxText{1} =  'Wrong parameters for filtering.';
      title = 'ERPLAB: basicfilter() error';
      errorfound(msgboxText, title);
      return
end

%
% Boundaries
%
if ~isempty(boundary) && isempty(EEG.epoch)
      fprintf('\nWARNING: You set "Apply filter to segments defined by boundary events".\n\n');
      
      if isfield(EEG, 'EVENTLIST')
            if isfield(EEG.EVENTLIST, 'eventinfo')
                  if ischar(boundary)
                        numt = str2num(boundary);
                        if isempty(numt)
                              codebound = {EEG.EVENTLIST.eventinfo.codelabel};
                        else
                              boundary = str2num(boundary);
                              codebound = [EEG.EVENTLIST.eventinfo.code];
                        end
                  else
                        codebound = [EEG.EVENTLIST.eventinfo.code];
                  end
            else
                  if ischar(EEG.event(1).type)
                        codebound = {EEG.event.type}; %stings
                  else
                        codebound = [EEG.event.type]; %numeric code
                  end
            end
      else
            if ischar(EEG.event(1).type)
                  codebound = {EEG.event.type}; %stings
            else
                  codebound = [EEG.event.type]; %numeric code
            end
      end
      
      if ischar(boundary)
            indxbound  = strmatch(boundary, codebound);
      else
            indxbound  = find(codebound==boundary);
      end
      
      if ~isempty(indxbound)
            
            timerange = [ EEG.xmin*1000 EEG.xmax*1000 ];
            
            if timerange(1)/1000~=EEG.xmin || timerange(2)/1000~=EEG.xmax
                  posi = round( (timerange(1)/1000-EEG.xmin)*EEG.srate )+1;
                  posf = min(round( (timerange(2)/1000-EEG.xmin)*EEG.srate )+1, EEG.pnts );
                  pntrange = posi:posf;
            end
            if exist('pntrange')
                  latebound = [ EEG.event(indxbound).latency ] - 0.5 - pntrange(1) + 1;
                  latebound(find(latebound>=pntrange(end) - pntrange(1))) = [];
                  latebound(find(latebound<1)) = [];
                  latebound = [0 latebound pntrange(end) - pntrange(1)];
            else
                  latebound = [0 [ EEG.event(indxbound).latency ] - 0.5 EEG.pnts ];
            end
            latebound = round(latebound);
      else
            latebound = [0 EEG.pnts];
            fprintf('\nWARNING: boundary events were not found.\n\n');
            fprintf('\nWARNING: Filter was applied over the full range of data.\n\n');
      end
else
      latebound = [0 EEG.pnts];
end

nibound   = length(latebound);

%
% Warning off
%
warning off MATLAB:singularMatrix

for j=1:ntrials
      q=1;
      while q<=nibound-1  % segments among boundaries
            
            bp1 = latebound(q)+1;
            bp2 = latebound(q+1);
            
            if length(bp1:bp2)>3*filterorder
                  if locutoff >0 % option to remove dc value is only for high-pass filtering
                        
                        %
                        % Removes DC
                        %
                        if remove_dc
                              fprintf('Removing DC bias from segment %g to %g (in samples) ...\n', bp1, bp2)
                              auxdata = EEG.data(chanArray,bp1:bp2,j);
                              EEG.data(chanArray,bp1:bp2,j) = detrend(auxdata', 'constant')';     % fast full trial mean's removing
                        end
                  end
                  if j==1
                        if nibound>2
                              fprintf('%s filtering input data from segment %g to %g (in samples), please wait...\n\n', labelf, bp1, bp2)
                        else
                              fprintf('%s filtering input data, please wait...\n\n', labelf);
                        end
                  end
                  if size(b,1)>1            
                        if strcmpi(labelf,'Band-Pass')
                              % Butterworth bandpass (cascade)
                              if isdoublep(EEG.data)
                                    EEG.data(chanArray,bp1:bp2,j) = filtfilt(b(1,:),a(1,:), EEG.data(chanArray,bp1:bp2,j)')';
                                    EEG.data(chanArray,bp1:bp2,j) = filtfilt(b(2,:),a(2,:), EEG.data(chanArray,bp1:bp2,j)')';
                              else
                                    EEG.data(chanArray,bp1:bp2,j) = single(filtfilt(b(1,:),a(1,:), double(EEG.data(chanArray,bp1:bp2,j))')');
                                    EEG.data(chanArray,bp1:bp2,j) = single(filtfilt(b(2,:),a(2,:), double(EEG.data(chanArray,bp1:bp2,j))')');                                    
                              end
                        else
                              %Butterworth Notch (parallel)
                              if isdoublep(EEG.data)                                    
                                    datalowpass   = filtfilt(b(1,:),a(1,:), EEG.data(chanArray,bp1:bp2,j)')';
                                    datahighpass  = filtfilt(b(2,:),a(2,:), EEG.data(chanArray,bp1:bp2,j)')';
                              else
                                    datalowpass   = single(filtfilt(b(1,:),a(1,:), double(EEG.data(chanArray,bp1:bp2,j))')');
                                    datahighpass  = single(filtfilt(b(2,:),a(2,:), double(EEG.data(chanArray,bp1:bp2,j))')');                      
                              end
                              
                              EEG.data(chanArray,bp1:bp2,j) = datalowpass + datahighpass;
                        end
                  else
                        % Butterworth lowpass)
                        % Butterworth highpass
                        % FIR lowpass
                        % FIR highpass
                        % FIR bandpass
                        % FIR notch
                        % Parks-McClellan Notch
                        if isdoublep(EEG.data)
                              EEG.data(chanArray,bp1:bp2,j) = filtfilt(b,a, EEG.data(chanArray,bp1:bp2,j)')';
                        else
                              EEG.data(chanArray,bp1:bp2,j) = single(filtfilt(b,a, double(EEG.data(chanArray,bp1:bp2,j))')');
                        end
                  end
            else
                  fprintf('WARNING: EEG segment from sample %d to %d was not filtered.\n', bp1,bp2);
                  fprintf('More than 3*filterorder points are required, at least.\n\n');
            end
                        
            fproblems = nnz(isnan(EEG.data(chanArray,bp1:bp2,j)));
            
            if fproblems>0
                  ferror =1;
                  msgboxText{1} =  'Oops! filter is not working properly. Data have undefined numerical results.';
                  msgboxText{2} =  'We strongly recommend that you change some filter parameters, for instance, decrease filter order.';
                  title = 'ERPLAB: basicfilter() error: undefined numerical results';
                  errorfound(msgboxText, title);
                  return
            end            
            q = q + 1;
      end
end

fprintf('\n')
% fprintf('basicfilter.m : END\n');
