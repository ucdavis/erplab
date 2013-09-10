% UNDER CONSTRUCTION
%
% subroutine for pop_summarizebins.m
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

function [Summary detect] = summarizebins(elfilename )
if nargin~=1
        help summarizebins
        return
end

fid_bl     = fopen( elfilename );

%
% Reads Header
%
isbin  = 1;
detect = 0;
nada   = 0;
j      = 1;
Summary.ntrial = 0;
Summary.description = {};

while isbin        
        tdatas = textscan(fid_bl, '%[^\n]',1);
        char(tdatas{1})
        [lmatch ltoken] = regexpi(char(tdatas{1}), 'bin\s*(\d+),\s*#\s*(\d+),\s*(.+)','match', 'tokens');
        firstitem = regexpi(char(tdatas{1}), '^1', 'match');
        
        if ~isempty(ltoken)
                
                Summary(j).ntrial       = str2num(char(ltoken{1}{2}));    % first check. Counter of captured eventcodes per bin
                Summary(j).description  =  strtrim(char(ltoken{1}{3}));
                j = j+1;
                detect = 1;
        elseif isempty(ltoken) && detect
                isbin=0;
        else
                if isempty(firstitem)
                        nada = nada + 1;
                        if nada>100
                                fprintf('\nWARNING: summarizebins() did not find any bin summary.\n');
                                fprintf('END\n\n');
                                position = p0;
                                isbin=0;
                        end
                else
                        position = p0;
                        isbin=0;
                end
        end
end
fclose(fid_bl);




