% PURPOSE  : Displays popup window with error message and picture
%
% FORMAT   :
%
% button = errorfound(message, title, bkgrncolor, showfig)
%
% INPUTS   :
%
%         message          - error message to display
%         title            - title of the error message to display
%         bkgrncolor       - window background color. e.g. [1 0 0]  (red)
%         showfig          - display picture. 1 yes; o no
%
%
% OUTPUTS  :
%
% popup window with error message and pict
%
%
% EXAMPLE 1
%
% msgboxText =  'pop_eventshuffler could not find EEG.event.type field.';
% title = 'ERPLAB: pop_eventshuffler error';
% errorfound(msgboxText, title);
% return
% 
%
% EXAMPLE 2
%
% msgboxText =  ['pop_eventshuffler only works with numeric event codes.\n'...
%                'We recommend to use Create EEG Eventlist first.'];
% title = 'ERPLAB: pop_eventshuffler error';
% errorfound(sprintf(msgboxText), title); % using sprintf
% return
%
%
% See also errorGUI.m
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

function button = errorfound(message, title, bkgrncolor, frgrncolor, showfig)
if nargin<5
        showfig = 1; % 1 = yes, show fig on error message
end
if nargin<4      
        frgrncolor = erpworkingmemory('errorColorF');
        if isempty(frgrncolor)
                frgrncolor = [0 0 0];
        end
end
if nargin<3        
        bkgrncolor = erpworkingmemory('errorColorB');
        if isempty(bkgrncolor)
                %bkgrncolor = [0.7020 0.7647 0.8392];
                bkgrncolor = [1 0 0];
        end
end
if nargin<2
        title = '???';
end
if nargin<1
        message = 'Message???';
end
p = which('eegplugin_erplab');
p = p(1:strfind(p,'eegplugin_erplab.m')-1);
figdir  = fullfile(p,'images');

%
% Get image indices
%
figdir1 = dir(figdir);
ferrorn = regexp({figdir1.name}, 'logoerplaberror\d*.tif','match', 'ignorecase');
fnames  = cellstr(char([ferrorn{:}]));  
%for i=1:7; fnames{i} = sprintf('logoerplaberror%g.jpg',i);end
try
        [IconData, IconCMap] = loadrandimage(fnames);
catch
        [IconData, IconCMap] = imread('logoerplaberror1.tif');
end

button = errorGUI(message, title, IconData, IconCMap, bkgrncolor, frgrncolor, showfig);
return


