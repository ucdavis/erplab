% PURPOSE: erases ERPLAB Studio's memory (values are those last used. Default ones are reloaded)
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
% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2024



function runindex = etudioamnesia(warningop)
runindex =0;
if nargin<1
        warningop = 0;
end
if warningop>0
        %Warning Message
        question   = ['Resetting ERPLAB Studio''s working memory will\n'...
                'Clear all memory, it cannot be recovered.\n'...
                'Do you want to continue anyway?'];
        title      =  'ERPLAB Studio: Reset ERPLAB Studio''s working memory Confirmation';
        button     = askquest(sprintf(question), title);
        
        if ~strcmpi(button,'yes')
                return
        end
end
try
        vmemoryestudio = erplab_memory_store('studio', 'reset');
        assignin('base','vmemoryestudio',vmemoryestudio);
        if isfield(vmemoryestudio, 'mshock')
                mshock = vmemoryestudio.mshock;
        else
                mshock = 0;
        end
        fprintf('\n*** ERPLAB Studio WARNING: ERPLAB Studio''s working memory was reset. Default values will be used.\n\n')
catch
        fprintf('\n* ERPLAB Studio''s working memory could not be reset in the user settings folder.\n')
        return
end
if mshock>=30 && rand>0.8
        fprintf('\n\nIs it not enough???\n\n')
end
runindex=1;
