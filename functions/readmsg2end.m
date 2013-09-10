% PURPOSE: reads message to be displayed at pop functions' completion statement
%
% FORMAT:
%
% [msg2show msgori mcolor] = readmsg2end(textin);
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

function [msg2show msgori mcolor] = readmsg2end(textin)
try
      if nargin<1
            p = which('eegplugin_erplab');
            p = p(1:strfind(p,'eegplugin_erplab.m')-1);
            filename = fullfile(p,'functions','msg2end.txt');
            fid = fopen(filename);
            k=1; msgArray{1,1} = [];
            while ~feof(fid) && k<100
                  msg = textscan(fid, '%[^\n]',1);
                  msgArray{k,1} = char(msg{:});
                  k=k+1;
            end
            fclose(fid);
      else
            if iscell(textin)
                  msgArray = textin;
            else
                  msgArray = cellstr(textin);
            end
      end
      i=1; j=1; findcol=1; msgcell2show{1,1} = []; msgcellori{1,1} = []; mcolorx = [];
      for g=1:length(msgArray)
            msg = msgArray{g};
            auxmsg = msg;
            if isempty(msg)
                  msg = NaN;
            else
                  if findcol==1
                        rexp = '<\s*\[\s*(\d\.*\d*)*\s*(\d\.*\d*)*\s*(\d\.*\d*)*\s*]\s*>';
                        colval = regexp(msg, rexp, 'tokens');
                        if length([colval{:}])==3
                              c1 = str2double(colval{1}{1});
                              c2 = str2double(colval{1}{2});
                              c3 = str2double(colval{1}{3});
                              mcolorx = [c1 c2 c3];
                              if length(mcolorx)==3
                                    msg = Inf;
                                    findcol = 0;
                              else
                                    mcolorx = [];
                              end
                        end
                  end
            end
            if ~isnumeric(msg)
                  evalcom = regexp(msg, '\s*eval\(\''(.)*\''\)', 'tokens');
                  evalcom = strtrim(char(evalcom{:}));
                  if ~isempty(evalcom);
                        eval(evalcom);
                        msg = NaN;
                  end
            end
            if ~isnumeric(msg)
                  msgcellori{j,1} = msg;
                  try
                        msgx = eval(msg) ; % eval the message
                        msg = msgx;
                  catch
                  end
                  msgcell2show{i,1} = sprintf('%s\n', msg); %[msg '\n'];
                  i=i+1;
                  j=j+1;
            elseif isnan(msg)
                  msgcellori{j,1} = auxmsg;
                  j=j+1;
            end
      end
      if isempty([msgcell2show{:}])
            msg2show = 'COMPLETE';% default
      else
            msg2show = char(cellstr(msgcell2show));
      end
      if isempty([msgcellori{:}])
            msgori = 'COMPLETE';% default
      else
            msgori = char(cellstr(msgcellori));
      end
      if isempty(mcolorx)
            mcolor = [0 0 1]; % default blue
      else
            mcolor = mcolorx;
      end
catch
      msg2show = 'COMPLETE'; % default
      msgori   = 'COMPLETE'; % default
      mcolor   = [0 0 1];    % default blue
end

