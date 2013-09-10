% PURPOSE: subroutine for pop_eegremovemean.m
%          removes mean value (DC offset) from a dataset
%
% FORMAT
%
% EEG = eegremovemean( EEG, chanArray, boundary)
%
% INPUTS:
%
% EEG         - continuous or epoched dataset
% chanArray   - channel array from where to substract the mean 
% boundary    - event code for boundary events
%
% EXAMPLE: Before applying high-pass filtering is recommended to remove the DC value of the signal.
%          This simple step minimizes the transient artifact rised at the edges of the signal.
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

function EEG = eegremovemean( EEG, chanArray, boundary)
if nargin < 1
      help eegremovemean
      return
end
if isempty(EEG(1).data)
      msgboxText =  'eegremovemean() cannot read an empty dataset!';
      title = 'ERPLAB: pop_lindetrend error';
      errorfound(msgboxText, title);
      return
end
if nargin<3
      boundary = 'boundary';
end
if nargin<2
      chanArray = 1:EEG.nbchan;
end
if isempty(EEG(1).epoch)       % continuous data
      
      %
      % Boundaries
      %
      if ~isempty(boundary)            
            if isfield(EEG, 'EVENTLIST')
                  %
                  % for searching event codes inside EEG.EVENTLIST.eventinfo
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
                  % for searching event codes inside EEG.event.type
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
                        %ferror =1;
                        %msgboxText = 'You specified a string as a boundary code, but your events are numeric.';
                        %title = 'ERPLAB: boundary format error';
                        %errorfound(msgboxText, title);
                        %return
                        msgboxText = 'You specified a string as a boundary code, but your events are numeric.';
                        fprintf('\n%s\n\n', msgboxText);
                        indxbound = [];
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
                  fprintf('WARNING: The full range of data mean will be removed from each channel.\n\n');
            end
      else
            latebound = [0 EEG.pnts];
      end
      nibound   = length(latebound);
else
      latebound = [0 EEG.pnts];      
      
      %       msgboxText =  ['eegremovemean works for continuous data only\n'...
      %                      'For epoched data you may use a baseline correction.\n'];
      %       title = 'ERPLAB: pop_lindetrend error';
      %       errorfound(msgboxText, title);
      %       return
end

%
% Warning off
%
warning off MATLAB:singularMatrix
ntrials = EEG.trials;

% %
% % process multiple datasets April 13, 2011 JLC
% %
% if length(EEG) > 1
%       [ EEG  ] = eeg_eval( 'eegremovemean', EEG, 'warning', 'on', 'params', {chanArray});
%       return;
% end

for j=1:ntrials
      q=1;
      while q<=nibound-1  % segments among boundaries
            bp1 = latebound(q)+1;
            bp2 = latebound(q+1);
            %
            % Removes DC
            %
            fprintf('Removing DC bias from segment %g to %g (in samples) ...\n', bp1, bp2)
            auxdata = EEG.data(chanArray,bp1:bp2,j);
            EEG.data(chanArray,bp1:bp2,j) = detrend(auxdata')';     % fast full trial mean's removing
            q = q + 1;
      end
end
try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
return


