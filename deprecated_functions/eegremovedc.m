% DEPRECATED...
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

function EEG = eegremovedc(EEG, chanArray, boundary)
if nargin < 1
      help eegremovedc
      return
end
if isempty(EEG.data)
      error('ERPLAB says: error at eegremovedc(). Empty dataset')
end
if ~isempty(EEG.epoch)
      boundary = []; % not allowed for epoched data
end
if nargin<3
      boundary = 'boundary'; % default
end
if nargin<2
      chanArray = 1:EEG.nbchan; % default
end

chanArray = unique_bc2(chanArray); % does not allow repeated channels
pnts      = size(EEG.data,2);
numchan   = length(chanArray);

if numchan>EEG.nbchan
      msgboxText =  'You do not have such amount of channels in your data!';
      title = 'ERPLAB: eegremovedc() error:';
      errorfound(msgboxText, title);
      return
end

ntrials = EEG.trials;

%
% Boundaries
%
if ~isempty(boundary) && isempty(EEG.epoch)
      fprintf('\nWARNING: You set "Apply filter to segments defined by boundary events".\n\n');
      
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
            if ischar(EEG.event(1).type)
                  codebound = {EEG.event.type}; %strings
            else
                  codebound = [EEG.event.type]; %numeric code
            end
      end
      
      %
      % search for boundaries
      %
      if ischar(boundary) && iscell(codebound)
            indxbound  = strmatch(boundary, codebound, 'exact');
      elseif ~ischar(boundary) && ~iscell(codebound)
            indxbound  = find(codebound==boundary);
      elseif ischar(boundary) && ~iscell(codebound)
            numt = str2num(boundary);
            if ~isempty(numt)
                  indxbound  = find(codebound==numt);
            else
                  ferror =1;
                  msgboxText = 'You specified a string as a boundary code, but your events are numeric.';
                  title = 'ERPLAB: boundary format error';
                  errorfound(msgboxText, title);
                  return
            end
      elseif ~ischar(boundary) && iscell(codebound)
            indxbound  = strmatch(num2str(boundary), codebound, 'exact');
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
            fprintf('\nWARNING: boundary events were not found.\n');
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
            
            %
            % Removes DC
            %
            if remove_dc
                  fprintf('Removing DC bias from segment %g to %g (in samples) ...\n', bp1, bp2)
                  auxdata = EEG.data(chanArray,bp1:bp2,j);
                  EEG.data(chanArray,bp1:bp2,j) = detrend(auxdata', 'constant')';     % fast full trial mean's removing
            end           
            q = q + 1;
      end
end

fprintf('\n')
% fprintf('eegremovedc.m : END\n');
