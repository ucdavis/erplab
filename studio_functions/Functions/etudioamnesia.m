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
                'Clear all memory and cannot be recovered\n'...
                'Do you want to continue anyway?'];
        title      =  'ERPLAB Studio: Reset ERPLAB Studio''s working memory Confirmation';
        button     = askquest(sprintf(question), title);
        
        if ~strcmpi(button,'yes')
                return
        end
end

erplab_default_values % script
% check variable at workspace
try
        vmemoryestudio = evalin('base', 'vmemoryestudio');
catch
        vmemoryestudio = [];
end
if isempty(vmemoryestudio)
        fprintf('\n* FYI: ERPLAB Studio''s working memory variable does not exist at workspace.\n')
else
        if isfield(vmemoryestudio, 'mshock')
                mshock = vmemoryestudio.mshock;
        else
                mshock = 0;
        end
        clear vmemoryestudio
        mshock = mshock + 1;
        
        %
        %  IMPORTANT: If this strucure (vmemoryestudio) is modified then also must be modified the same line at o_ERPDAT.m
        % 
        vmemoryestudio = struct('erplabrel',erplabrel,'erplabver',erplabver,'ColorB',ColorB,'ColorF',ColorF,'fontsizeGUI',fontsizeGUI,...
                                    'fontunitsGUI',fontunitsGUI,'mshock',mshock, 'errorColorF', errorColorF, 'errorColorB', errorColorB);
        assignin('base','vmemoryestudio',vmemoryestudio);
        fprintf('\n* ERPLAB Studio''s working memory was reset (variable "vmemoryestudio", at workspace, was rebuild with default values).\n');
end

% check file for memory
p = which('o_ERPDAT');
p = p(1:findstr(p,'o_ERPDAT.m')-1);
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
        fprintf('\n*** ERPLAB Studio WARNING: ERPLAB Studio''s working memory was wiped out. Default values will be used.\n\n')
        
        %
        %  IMPORTANT: If this file (saved variables inside memoryerpstudio.erpm) is modified then also must be modified the same line at o_ERPDAT.m
        %
        save(fullfile(p,'memoryerpstudio.erpm'),'erplabrel','erplabver','ColorB','ColorF','errorColorB', 'errorColorF','fontsizeGUI','fontunitsGUI','mshock');
else
        fprintf('\n* FYI: ERPLAB Studio''s working memory file does not exist.\n')
        return
end
if mshock>=30 && rand>0.8
        fprintf('\n\nIs it not enough???\n\n')
end
runindex=1;