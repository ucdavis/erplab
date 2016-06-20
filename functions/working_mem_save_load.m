% PURPOSE: saves or loads the ERPLAB working memory to another location
%
% FORMAT
%
% working_mem_save_load(save_or_load)
%
% INPUT
%
% save_or_load          - 1 for save; 2 for load
%
% OUTPUT
%
% Mat-file .erpm written to disk, or memory structure loaded.
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Andrew Stewart
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2016

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



function [wm_loaded] = working_mem_save_load(save_or_load)

if save_or_load == 1
    
    wm_loaded = [];
    
    % prompt for path with file browser ui
    [wm_fname, wm_pathname] = uiputfile({'*.erpm', 'ERP working memory file (*.erpm)';
        '*.*'  , 'All Files (*.*)'},'Save working memory file as',...
        'custom_memoryerp.erpm');
    
    try
        vmemoryerp = evalin('base', 'vmemoryerp');
        
        % save
        save(fullfile(wm_pathname, wm_fname), 'vmemoryerp');
        
        
    catch
        errordlg('Memory save problem.  Perhaps memory was empty?');
    end
    
    
    
    
    
elseif save_or_load == 2
    
    
    % prompt for path with file browser ui
    [wm_load_fname, wm_load_pathname] = uigetfile({'*.erpm', 'ERP working memory file (*.erpm)';
        '*.*'  , 'All Files (*.*)'},'Pick an existing working memory file to load',...
        'custom_memoryerp.erpm');
    
    % load
    wm_loaded = load(fullfile(wm_load_pathname,wm_load_fname), '-mat');
    
else
    errordlg('WM save function error?');
end

end

