% PURPOSE: gets current ERPLAB's version
%
% FORMAT:
%
%   version = geterplabversion;
%
% or
%
%
%  [version reldate] = geterplabversion; % reldate=release date
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

function [version reldate] = geterplabversion

erplab_default_values
version = erplabver;
reldate = erplabrel;


% p = which('eegplugin_erplab');
% p = p(1:findstr(p,'eegplugin_erplab.m')-1);
% 
% if exist(fullfile(p,'memoryerp.erpm'), 'file')
%         try
%                 v=load(fullfile(p,'memoryerp.erpm'), '-mat');
%                 version = v.erplabver;
%                 reldate = v.erplabrel;
%         catch
%                 cv = regexp(p, 'erplab_(\d*.\d*.\d*.\d*)', 'tokens');
%                 version = char(cv{:});
%         end
% else
%         cv = regexp(p, 'erplab[-_ ](\d*.\d*.\d*.\d*)', 'tokens');
%         version = char(cv{:});
% end
%
% catch
%       msgboxText = ['geterplabversion() cannot find the erplab version number...\n'...
%             '\tPlease, try running EEGLAB once.'];
%       tittle = 'ERPLAB: geterplabversion() Error';
%       errorfound(sprintf(msgboxText), tittle);
%       return
% end