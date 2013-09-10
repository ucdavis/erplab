% PURPOSE: logs ERPLAB's command history
% 
% FORMAT
% 
% [ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, erpcom)
%
% INPUTS
%
% ERP         - ERPset being processed
% ALLERPCOM   - cell string containing all ERPLAB's commands
% erpcom      - current ERPLAB's command applied over the ERPset being processed
%
% OUTPUT
%
% ERP         - updated ERPset (ERP.history)
% ALLERPCOM   - updated cell string containing all ERPLAB's command
%
%
% Author: Javier Lopez-Calderon & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
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

function [ERPLAB, ALLERPCOM] = erphistory(ERPLAB, ALLERPCOM, erpcom, psource)
if nargin<1
end
if nargin<4
        psource = 0; % from gui
end
if psource==1        
        psrcword = 'Script: '; % get history from script
else
        psrcword = 'GUI: '; % get history from gui
end

%
% Special case: pop_geterpvalues()
%
matchstr = regexp(erpcom, '.*pop_geterpvalues(\s*''loadlist''', 'match');
erpcom   = regexprep(erpcom ,'  ','');
if ~isempty(matchstr) && iserpstruct(ERPLAB) && strcmpi(psrcword, 'GUI: ')
      ALLERPCOM{end+1} = erpcom;
      return
end
if isstruct(ERPLAB)% iserpstruct(ERPLAB)
      
      %
      % Local history
      %
      if ~isempty(erpcom) && ~isempty(ERPLAB.history)
            olderpcom = cellstr(ERPLAB.history);
            newerpcom = [olderpcom; {[erpcom '% ' psrcword datestr(now)]}];
            ERPLAB.history = char(newerpcom);
      elseif ~isempty(erpcom) && isempty(ERPLAB.history)
            ERPLAB.history = [char(erpcom)  '% ' psrcword datestr(now)];
      else
            msgwrng = 'ERPLAB WARNING: ERPLAB could not generate a command history for this operation.\n';
            try cprintf([1 0.5 0.2], '%s\n\n', msgwrng);catch,fprintf('%s\n\n', msgwrng);end ;
            return
      end
end
if iserpstruct(ERPLAB) && strcmpi(psrcword, 'GUI: ')
        %
        % Whole history
        %
        ALLERPCOM{end+1} = char(erpcom);
end
return
