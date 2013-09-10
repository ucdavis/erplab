% UNDER CONSTRUCTION
%
% PURPOSE: replaces event codes
%
% FORMAT:
%
% EEG = replacecode(EEG, findcode, replacecode, deltatimems);
%
% INPUTS:
%
% findcode     -  codes to find. eg. {'tr1' 'tr3' 'tr6'}
% replacecode  -  codes to be used as a replacement. e.g. 'Target'
%
%
% *** This function is part of ERPLAB Toolbox ***
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



% findcode     -  codes to find. eg. {'tr1' 'tr3' 'tr6'}
% replacecode  -  codes to be used as a replacement. e.g. 'Target'
% deltatimems
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009
function EEG = replacecode(EEG, findcode, replacecode, deltatimems)
if nargin<1
      help replacecode
      return
end
fs = EEG.srate;
if nargin<4
else
      deltatimesam = round((deltatimems*fs)/1000); % delta in samples
end
%
% extracting codes from EEG.event.type
%
if ischar(EEG.event(1).type)
      currentcodes = {EEG.event.type}; %strings
else
      currentcodes = [EEG.event.type]; %numeric code
end
%
% search for findcodes
%
if ~iscell(findcode)
      if isnumeric(findcode)
            findcode = num2cell(findcode);
      else
            findcode = cellstr(findcode);
      end
end
if ischar(findcode{1}) && iscell(currentcodes)
      indxfindcode  = strmatch(findcode(1), currentcodes, 'exact');
elseif ~ischar(findcode{1}) && ~iscell(currentcodes) % numeric
      indxfindcode  = find(currentcodes==findcode{1});
elseif ischar(findcode{1}) && ~iscell(currentcodes)
      numt = str2num(findcode{1});
      if ~isempty(numt)
            indxfindcode  = find(currentcodes==numt);
      else
            msgboxText = 'You specified string(s) as event code, but your current events are numeric.';
            title = 'ERPLAB: input format error';
            errorfound(msgboxText, title);
            return
      end
elseif ~ischar(findcode{1}) && iscell(currentcodes)
      indxfindcode  = strmatch(num2str(findcode{1}), currentcodes, 'exact');
end
nf = length(findcode);
if nf==1
      [EEG.event(indxfindcode).type] = deal(replacecode);
else
      for i=1:length(indxfindcode)
            indx = indxfindcode(i);
            if indx>1 && (indx+nf-1)<=length(EEG.event)
                  if max(diff([EEG.event(indx:indx+nf-1).latency]))<=2 && diff([EEG.event(indx-1:indx).latency])>2
                        [EEG.event(indx).type] = deal(replacecode);
                        EEG.event(indx+1:indx+nf-1) = [];
                  end
            elseif indx==1
                  if max(diff([EEG.event(indx:indx+nf-1).latency]))<=2
                        [EEG.event(indx).type] = deal(replacecode);
                        EEG.event(indx+1:indx+nf-1) = [];
                  end
            end
      end
end
EEG = eeg_checkset( EEG );
