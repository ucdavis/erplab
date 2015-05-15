% PURPOSE: closes all ERPLAB's figure
%
% FORMAT:
%
% clerpf
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2012

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

function clerpf
findplot = findobj('Tag','ERP_figure','-or', 'Tag','Scalp_figure',...
                   '-or', 'Tag','copiedf','-or', 'Tag','ERP_figure_copy',...
                   '-or', 'Tag','Scalp_figure_copy',...
                   '-or', 'Tag','Viewer_figure');
if isempty(findplot)
        fprintf('*** no ERPLAB figure found ***\n');
        return
end
for i=1:length(findplot)
        close(findplot(i))
end
w1 = {'' 's'};
w2 = {'was' 'were'};
k = round(2-exp(-i/2));
fprintf('*** %g ERPLAB figure%s %s closed ***\n', i, w1{k}, w2{k});
