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

function updatemenuerp(ALLERP, overw)

if nargin<2
      overw=0; % overwrite? 0=no
end
%
% Checks erpsets menu status
%
erpmenu  = findobj('tag', 'erpsets');
staterpm = get(erpmenu, 'Enable');

if strcmp(staterpm,'off')
      set(erpmenu, 'Enable', 'on');
end

maxindexerp  = length(ALLERP);
erpm    = findobj('tag', 'linerp');

if isempty(erpm)
      nerpset = 0;
      overw   = 0;
else
      nerpset = length(erpm);
end

if overw==1
      for s=1:nerpset
            strcheck = get(erpm(s), 'checked');
            if strcmp(strcheck,'on')
                  catchindx = nerpset-s+1;
                  erpn = ALLERP(nerpset-s+1).erpname; % top-down counting
                  menutitle   = sprintf('Erpset %d: %s', nerpset-s+1, erpn);
                  set( erpm(s), 'Label', menutitle);
            end
      end

      erp2memory(ALLERP(catchindx), catchindx);

elseif overw==0 || overw==-1

      if overw==0
            indexerp = nerpset + 1;
      else
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
      erp2memory(ALLERP(maxindexerp), maxindexerp);
else
      error('ERPLAB: Wrong input parameter')
end