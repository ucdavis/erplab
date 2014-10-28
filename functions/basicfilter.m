% PURPOSE: subroutine for pop_basicfilter.m
%
% FORMAT
%
% [EEG ferror] = basicfilter(EEG, chanArray, locutoff, hicutoff, filterorder, typef, remove_dc, boundary)
%
%     EEG         - input dataset
%     chanArray   - channel(s) to filter
%     locutoff    - lower edge of the frequency pass band (Hz)  {0 -> lowpass}
%     hicutoff    - higher edge of the frequency pass band (Hz) {0 -> highpass}
%     filterorder - length of the filter in points {default 3*fix(srate/locutoff)}
%     typef       - type of filter: 0=means IIR Butterworth;  1 = means FIR
%     remove_dc   - remove dc offset before filtering. 1 yes; 0 no
%     boundary    - event code for boundary events. e.g. 'boundary'
%
%
%     Outputs:
%     EEG         - output dataset
%     ferror      - filter error(s). o means no error found; 1 means error found.
%
% See also filter_tf.m filtfilt.m removedc.m 
%
%
% *** This function is part of ERPLAB Toolbox ***
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
      msgboxText =  'The length of the data must be more than three times the filter order.';
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

chanArray = unique_bc2(chanArray); % does not allow repeated channels
fnyquist  = 0.5*EEG.srate;       % half sample rate
pnts      = size(EEG.data,2);
numchan   = length(chanArray);

if numchan>EEG.nbchan
      msgboxText =  'You do not have such amount of channels in your data!';
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
if typef>0 && filterorder*3 > pnts          % filtfilt restriction
      fprintf('basicfilter: filter order too high');
      error('ERPLAB says: error at basicfilter(). Number of samples must be, at least, 3 times the filter order.');
end

[b, a, labelf, v] = filter_tf(typef, filterorder, hicutoff, locutoff, EEG.srate);

if ~v  % something is wrong or turned off
      msgboxText =  'Wrong parameters for filtering.';
      title = 'ERPLAB: basicfilter() error';
      errorfound(msgboxText, title);
      return
end

fprintf('Channels to be filtered : %s\n\n', vect2colon(chanArray, 'Delimiter', 'on'));

%
% Boundaries
%
if ~isempty(boundary) && isempty(EEG.epoch)
      fprintf('WARNING: You set "Apply filter to segments defined by boundary events".\n\n');
      
      if isfield(EEG, 'EVENTLIST')
            %
            % for searching boundaries inside EEG.EVENTLIST.eventinfo
            %
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
                        codebound = {EEG.event.type}; %strings
                  else
                        codebound = [EEG.event.type]; %numeric code
                  end
            end
      else
            %
            % for searching boundaries inside EEG.event.type
            %
            if isempty(EEG.event) % oct-14-2013
                    codebound = [];
            else
                    if ischar(EEG.event(1).type)
                            codebound = {EEG.event.type}; %strings
                    else
                            codebound = [EEG.event.type]; %numeric code
                    end                    
            end
      end
      
      %
      % search for boundaries
      %
      if isempty(codebound)
              indxbound = [];% oct-14-2013
      else
              if ischar(boundary) && iscell(codebound)
                      %%%indxbound  = strmatch(boundary, codebound,'exact'); % obsolete                    
                      indxbound   = find(strcmp(codebound, boundary));                      
              elseif ~ischar(boundary) && ~iscell(codebound)
                      indxbound  = find(codebound==boundary);
              elseif ischar(boundary) && ~iscell(codebound)
                      numt = str2num(boundary);
                      if ~isempty(numt)
                              indxbound  = find(codebound==numt);
                      else
                              %ferror =1;
                              msgboxText = 'You specified a string as a boundary code, but your events are numeric.';
                              fprintf('WARNING: %s \n\n', msgboxText);
                              %title = 'ERPLAB: boundary format error';
                              %errorfound(msgboxText, title);
                              %return
                              indxbound = [];
                      end
              elseif ~ischar(boundary) && iscell(codebound)
                      %%%indxbound  = strmatch(num2str(boundary), codebound, 'exact'); % obsolete
                      indxbound   = find(strcmp(codebound, cellstr(num2str(boundary'))'));
              end
      end
      if ~isempty(indxbound)   
            pntrange  = [];% April 2014
            timerange = [ EEG.xmin*1000 EEG.xmax*1000 ];            
            if timerange(1)/1000~=EEG.xmin || timerange(2)/1000~=EEG.xmax
                  posi = round( (timerange(1)/1000-EEG.xmin)*EEG.srate )+1;
                  posf = min(round( (timerange(2)/1000-EEG.xmin)*EEG.srate )+1, EEG.pnts );
                  pntrange = posi:posf;
            end
            if ~isempty(pntrange) % April 2014
                  latebound = [ EEG.event(indxbound).latency ] - 0.5 - pntrange(1) + 1;
                  latebound(find(latebound>=pntrange(end) - pntrange(1))) = [];
                  latebound(find(latebound<1)) = [];
                  latebound = [0 latebound pntrange(end) - pntrange(1)];
            else
                  latebound = [0 [ EEG.event(indxbound).latency ] - 0.5 EEG.pnts ];
            end
            latebound = round(latebound);            
            latebound = [0 latebound(latebound>2)]; % April 2014            
      else
            latebound = [0 EEG.pnts];
            fprintf('WARNING: boundary events were not found.\n');
            fprintf('WARNING: Filter will be applied over the full range of data.\n\n');
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
                        % Removes DC from "the first half second" of data
                        %
                        if remove_dc
                              fprintf('Removing DC bias from segment %g to %g (in samples) ...\n', bp1, bp2)                              
                              EEG.data(chanArray,bp1:bp2,j) = removedc(EEG.data(chanArray,bp1:bp2,j), round(EEG.srate/2));
                        end
                  end
                  if j==1
                        if nibound>2
                              fprintf('%s filtering input data (fc = %s Hz) from segment %g to %g (in samples), please wait...\n\n',...
                                      labelf, vect2colon(nonzeros([locutoff hicutoff ])), bp1, bp2)
                        else
                              fprintf('%s filtering input data (fc = %s Hz), please wait...\n\n',...
                                      labelf, vect2colon(nonzeros([locutoff hicutoff ])));
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
                  msgboxText = ['Oops! filter is not working properly.\n Data have undefined numerical results.\n'...
                               'We strongly recommend that you change some filter parameters, for instance, decrease filter order.'];
                  title = 'ERPLAB: basicfilter() error: undefined numerical results';
                  errorfound(sprintf(msgboxText), title);
                  return
            end            
            q = q + 1;
      end
end

fprintf('\n')
