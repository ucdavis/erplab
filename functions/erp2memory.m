% PURPOSE: saves new ERPset (and its pointer at ERPset menu) in Matlab workspace. Also, redraws and updates the ERPset menu
%          including the new ERPset.
%
% FORMAT
%
% erp2memory(ERP, indx)
%
% INPUTS:
%
% ERP    - new ERPset
% indx   - ERPset's index or pointer (according to the ERPset menu and ALLERP)
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

function erp2memory(ERP, indx)

erpm    = findobj('tag', 'linerp');
nerpset = length(erpm);
for s=1:nerpset      
      if s == nerpset-indx+1 % bottom-up to top-down counting
            set(erpm(s), 'checked', 'on' );
            menutitle   = ['<Html><b>Erpset '...
                  num2str(nerpset-s+1) ': ' ERP.erpname '</b>'];
            set( erpm(s), 'Label', menutitle);
      else
            set(erpm(s), 'checked', 'off' );
            currname = get(erpm(s),'Label');
            menutitle = regexprep(currname,'<b>|</b>','', 'ignorecase');
            menutitle = regexprep(menutitle, '\s+', ' ');
            menutitle = regexprep(menutitle,'Erpset \d+',['Erpset ' num2str(nerpset-s+1)], 'ignorecase');
            set( erpm(s), 'Label', menutitle);
      end
end
CURRENTERP = indx;
assignin('base','CURRENTERP', CURRENTERP);  % save to workspace
assignin('base','ERP', ERP);  % save to workspace

% check ploterps GUI
perpgui    = findobj('Tag', 'ploterp_fig');
if ~isempty(perpgui)
      close(perpgui)
      pause(0.1)
      pop_ploterps(ERP);
else
      fprintf('\n------------------------------------------------------\n');
      fprintf('ERPSET #%g is ACTIVE\n', indx);
      fprintf('------------------------------------------------------\n');
      ERP
end


