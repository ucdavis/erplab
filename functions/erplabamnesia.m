% PURPOSE: erases ERPLAB's memory (values are those last used. Default ones are reloaded)
%
% FORMAT
%
% erplabamnesia(warningop)
%
% INPUT:
%
% warningop         - display warning message. 1 yes; 0 no
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Johanna Kreither
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2011

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

function erplabamnesia(warningop)
if nargin<1
        warningop = 0;
end
if warningop>0
        %Warning Message
        question   = ['Resetting ERPLAB''s working memory will\n'...
                'Clear all memory and cannot be recovered\n'...
                'Do you want to continue anyway?'];
        title      =  'ERPLAB: Reset ERPLAB''s working memory Confirmation';
        button     = askquest(sprintf(question), title);
        
        if ~strcmpi(button,'yes')
                disp('User selected Cancel')
                return
        end
end
try
        vmemoryerp = erplab_memory_store('classic', 'reset');
        assignin('base','vmemoryerp',vmemoryerp);
        if isfield(vmemoryerp, 'mshock')
                mshock = vmemoryerp.mshock;
        else
                mshock = 0;
        end
        fprintf('\n*** ERPLAB WARNING: ERPLAB''s working memory was reset. Default values will be used.\n\n')
catch
        fprintf('\n* ERPLAB''s working memory could not be reset in the user settings folder.\n')
        return
end
if mshock>=30 && rand>0.8
        fprintf('\n\nIs it not enough???\n\n')
end
