% PURPOSE: updates ERPset menu
%
% Format
%
% updatemenuerp(ALLERP, overw)
%
% INPUT:
%
% ALLERP     - structure containing multiple ERPsets
% overw      - overwrite erpset menu? 0=no; 1=yes; -1=delete
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

function updatemenuerp(ALLERP, overw)
if nargin<2
      overw=0; % overwrite erpset menu? 0=no; 1=yes; -1=delete
end
%
% Checks ERPpsets menu status
%
erpmenu  = findobj('tag', 'erpsets');
staterpm = get(erpmenu, 'Enable');
if strcmp(staterpm,'off')
      set(erpmenu, 'Enable', 'on'); % activates erpsets menu
end
maxindexerp  = length(ALLERP);
ERPSETMENU   = zeros(1,maxindexerp);
erpsetlist   = findobj('tag', 'linerp'); % size of the list at erpset menu
if isempty(erpsetlist)
      nerpset = 0;
      overw   = 0; % add a new erpset
elseif length(erpsetlist)>maxindexerp  %10-25-11
      nerpset = length(erpsetlist);
      overw=-1; % delete erpset
elseif length(erpsetlist)<maxindexerp
      nerpset = length(erpsetlist);
      overw=0;  % add erpset
else
      nerpset = length(erpsetlist);
end
if overw==1
      % overwrite. Just change the current erpset
      for s=1:nerpset
            strcheck = get(erpsetlist(s), 'checked');
            if strcmp(strcheck,'on')
                  catchindx = nerpset-s+1;
                  erpn = ALLERP(nerpset-s+1).erpname; % top-down counting
                  menutitle   = sprintf('Erpset %d: %s', nerpset-s+1, erpn);
                  set( erpsetlist(s), 'Label', menutitle);
            end
      end
      erp2memory(ALLERP(catchindx), catchindx);
elseif overw==0 || overw==-1
      if overw==0 % add a new erpset to the erpset menu
            indexerp = nerpset + 1;
      else  % delete erpset from the menu
            menux = findobj(0, 'tag', 'erpsets');
            h = get(menux);
            delete(h.Children);
            indexerp = 1;
            if maxindexerp==0
                  assignin('base','CURRENTERP', 0);  % save to workspace
                  set(erpmenu, 'enable', 'off');
                  return
            end
      end
      while indexerp <= maxindexerp
            ERPSETMENU(indexerp) = uimenu( erpmenu, 'tag', 'linerp');
            ferp = [ 'erp2memory(ALLERP(' num2str(indexerp) '),' num2str(indexerp) ');' ];
            erpn = ALLERP(indexerp).erpname;
            if iscell(erpn)
                  erpn = '';
            end
            menutitle   = ['<Html><FONT color="black" >Erpset ' num2str(indexerp) ': ' erpn '</font>'];
            set( ERPSETMENU(indexerp), 'Label', menutitle);
            set( ERPSETMENU(indexerp), 'CallBack', ferp );
            set( ERPSETMENU(indexerp), 'Enable', 'on' );
            indexerp = indexerp + 1;
      end      
      if maxindexerp~=0
            erp2memory(ALLERP(maxindexerp), maxindexerp);
      end
else
      error('ERPLAB says: Wrong input parameter')
end
        eeglab redraw
