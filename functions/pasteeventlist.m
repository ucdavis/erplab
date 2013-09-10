% PURPOSE: attachs EVENTLIST structure to EEG or ERP structure
%
% Inputs:
%
%   ERPLAB        - input dataset, either EEG or ERP
% BINLIST         - structure from bin detection process (bdf @ log = binlist)
% isattach        - to attach or not to attach...
%                   (0: Add to workspace;   1: Add to current dataset)
%
% Outputs:
%
%   ERPLAB        - updated output dataset, , either EEG or ERP
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

function ERPLAB =  pasteeventlist(ERPLAB, EVENTLIST, isattach, indexel)

if nargin<4
      indexel = 1;
end
if ~isempty(EVENTLIST.bdf)
      nbin = EVENTLIST.nbin;
      
      %
      % Erase extra white space
      %
      if ~isempty([EVENTLIST.bdf.description])
            for n=1:nbin
                  EVENTLIST.bdf(n).description =  regexprep(EVENTLIST.bdf(n).description, '  ', '');
            end
            
            %         else
            %                 error('ERPLAB: Bin descriptions were not found!')
      end
end
if isattach ==0
      assignin('base','EVENTLIST',EVENTLIST);
      disp('pastebinlist(): EVENTLIST structure was sent to WORKSPACE.')
elseif isattach ==1      
      if indexel>1
            ERPLAB.EVENTLIST(indexel) = EVENTLIST;
      else
            ERPLAB.EVENTLIST = EVENTLIST;
      end      
      if iseegstruct(ERPLAB)
            disp('pastebinlist(): EVENTLIST structure was added to the EEG structure successfuly!')
      else
            disp('pastebinlist(): EVENTLIST structure was added to the ERP structure successfuly!')
      end
else
      disp('User selected Cancel')
      return
end