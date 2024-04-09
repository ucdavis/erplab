% PURPOSE: saves or loads the ERPLAB Studio working memory to another location
%
% FORMAT
%
% estudioworking_mem_save_load(save_or_load)
%
% INPUT
%
% save_or_load          - 1 for save; 2 for load
%
% OUTPUT
%
% Mat-file .erpm written to disk, or memory structure loaded.
%
% *** This function is part of ERPLAB StudioToolbox ***
% Author: Guanghui Zhang
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2024





function [wm_loaded] = estudioworking_mem_save_load(save_or_load)

if save_or_load == 1
    
    wm_loaded = [];
    
    % prompt for path with file browser ui
    [wm_fname, wm_pathname] = uiputfile({'*.erpm', 'ERP Studio working memory file (*.erpm)';
        '*.*'  , 'All Files (*.*)'},'Save working memory file as',...
        'custom_memoryerp.erpm');
    
    try
        vmemoryestudio = evalin('base', 'vmemoryestudio');
        
        % save
        save(fullfile(wm_pathname, wm_fname), 'vmemoryestudio');
        
    catch
        errordlg('Memory save problem.  Perhaps memory was empty?');
    end
    
    
elseif save_or_load == 2
    
    
    % prompt for path with file browser ui
    [wm_load_fname, wm_load_pathname] = uigetfile({'*.erpm', 'ERP Studio working memory file (*.erpm)';
        '*.*'  , 'All Files (*.*)'},'Pick an existing working memory file to load',...
        'custom_memoryerp.erpm');
    if isempty(wm_load_pathname) || length(wm_load_pathname)==1
        beep;
        disp('User selected cancel');
        wm_loaded =[];
        return;
    end
    wm_loaded = load(fullfile(wm_load_pathname,wm_load_fname), '-mat');
    
else
    errordlg('WM save function error?');
end

end

