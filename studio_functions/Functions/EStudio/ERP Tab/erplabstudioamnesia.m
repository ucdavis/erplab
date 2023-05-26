% PURPOSE: erases EStudio's memory (values are those last used. Default ones are reloaded)
%
% FORMAT
%
% erplabstudioamnesia(warningop)
%
% INPUT:
%
% warningop         - display warning message. 1 yes; 0 no
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon,Guanghui Zhang & Johanna Kreither
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2011 & 2022

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% EStudio Toolbox
% Copyright © 2007 The Regents of the University of California
% Created by Javier Lopez-Calderon,Guanghui Zhang, and Steven Luck
% Center for Mind and Brain, University of California, Davis,
% javlopez@ucdavis.edu, ghzhang@ucdavis.edu,  sjluck@ucdavis.edu
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

function erplabstudioamnesia(warningop)
if nargin<1
        warningop = 0;
end
if warningop>0
        %Warning Message
        question   = ['Resetting EStudio''s working memory will\n'...
                'Clear all memory and cannot be recovered\n'...
                'Do you want to continue anyway?'];
        title      =  'EStudio: Reset EStudio''s working memory Confirmation';
        button     = askquest(sprintf(question), title);
        
        if ~strcmpi(button,'yes')
                disp('User selected Cancel')
                return
        end
end
erplab_studio_default_values % script
% check variable at workspace
try
        vmemoryerp = evalin('base', 'vmemoryerp');
catch
        vmemoryerp = [];
end
if isempty(vmemoryerp)
        fprintf('\n* FYI: EStudio''s working memory variable does not exist at workspace.\n')
else
        if isfield(vmemoryerp, 'mshock')
                mshock = vmemoryerp.mshock;
        else
                mshock = 0;
        end
        clear vmemoryerp
        mshock = mshock + 1;
        
        %
        %  IMPORTANT: If this strucure (vmemoryerp) is modified then also must be modified the same line at eegplugin_erplab.m
        % 
        vmemoryerp = struct('erplabstudiorel',erplabstudiorel,'erplabstudiover',erplabstudiover,'ColorB',ColorB,'ColorF',ColorF,'fontsizeGUI',fontsizeGUI,...
                                    'fontunitsGUI',fontunitsGUI,'mshock',mshock, 'errorColorF', errorColorF, 'errorColorB', errorColorB);
        assignin('base','vmemoryerp',vmemoryerp);
        fprintf('\n* EStudio''s working memory was reset (variable "vmemoryerp", at workspace, was rebuild with default values).\n');
end

% check file for memory
p = which('EStudio');
p = p(1:findstr(p,'EStudio.m')-1);
mfile = fullfile(p,'memoryerpstudio.erpm');

if exist(mfile, 'file')==2
        v = load(fullfile(p,'memoryerpstudio.erpm'), '-mat');
        if isfield(v, 'mshock')
                mshock = v.mshock;
        else
                mshock = 0;
        end
        
        recycle on;
        delete(mfile)
        pause(0.1)
        recycle off
        mshock = mshock + 1;
        fprintf('\n*** EStudio WARNING: EStudio''s working memory was wiped out. Default values will be used.\n\n')
        
        %
        %  IMPORTANT: If this file (saved variables inside memoryerp.erpm) is modified then also must be modified the same line at eegplugin_erplab.m
        %
        save(fullfile(p,'memoryerpstudio.erpm'),'erplabstudiorel','erplabstudiover','ColorB','ColorF','errorColorB', 'errorColorF','fontsizeGUI','fontunitsGUI','mshock');
else
        fprintf('\n* FYI: EStudio''s working memory file does not exist.\n')
        return
end
if mshock>=30 && rand>0.8
        fprintf('\n\nIs it not enough???\n\n')
end