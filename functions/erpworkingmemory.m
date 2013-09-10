% PURPOSE  : encodes and retrieves ERPLAB's working memory 
%
% FORMAT   :
%
% output = erpworkingmemory(field, input2store)
%
% INPUTS   :
%
% field          - function name. e.g. 'pop_appenderp'
% input2store    - values to store (cell array)
%
%
% OUTPUTS  :
%
% output         - stored values (cell array)
%
%
% EXAMPLE 1: encode pop_appenderp's memory (values currently being used)
%
% erpworkingmemory('pop_appenderp', { optioni, erpset, prefixlist });
% 
%
% EXAMPLE 2: retrieve pop_appenderp's memory (values last used)
%
% def  = erpworkingmemory('pop_appenderp');
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

function output = erpworkingmemory(field, input2store)
output = [];
if nargin<1
        help erpworkingmemory
        return
end
try
        vmemoryerp = evalin('base', 'vmemoryerp');
catch
        vmemoryerp = [];
end
if nargin==1 % read
        if ~isempty(vmemoryerp)  %  variable at the workspace for storing/reading memory
%                 try
%                         v = memoryerp;
%                 catch
%                         msgboxText = 'ERPLAB could not load the variable, at workspace, called "memoryerp"';
%                         try
%                                 cprintf([0.45 0.45 0.45], sprintf(msgboxText', erplabmemoryfile));
%                         catch
%                                 fprintf(msgboxText);
%                         end
%                         output = [];
%                         return
%                 end
                if isfield(vmemoryerp, field)
                        output = vmemoryerp.(field);
                else
                        output = [];
                end
        else % file for storing/reading memory
                try
                        p = which('eegplugin_erplab');
                        p = p(1:findstr(p,'eegplugin_erplab.m')-1);
                        v = load(fullfile(p,'memoryerp.erpm'), '-mat');
                catch
                        msgboxText = ['ERPLAB (erpworkingmemory.m) could not find "memoryerp.erpm" or does not have permission for reading it.\n'...
                                'Please, run EEGLAB once again or go to ERPLAB''s Setting menu and specify/create a new memory file.\n'];
                        try
                                cprintf([0.45 0.45 0.45], msgboxText');
                        catch
                                fprintf(msgboxText);
                        end
                        output = [];
                        return
                end
                if isfield(v, field)
                        output = v.(field);
                else
                        output = [];
                end
        end
        return
elseif nargin==2 % write
        if ~isempty(vmemoryerp) %  variable at the workspace for storing/reading memory
                try
                        vmemoryerp.(field) = input2store;
                        assignin('base','vmemoryerp', vmemoryerp); 
                catch
                        msgboxText = 'ERPLAB (erpworkingmemory.m) could not write to the variable called vmemoryerp, at workspace.';
                        try
                                cprintf([0.45 0.45 0.45], sprintf(msgboxText', erplabmemoryfile));
                        catch
                                fprintf(msgboxText);
                        end
                        return
                end
        else % file for storing/reading memory
                try
                        eval([field '=input2store;'])
                        p = which('eegplugin_erplab');
                        p = p(1:findstr(p,'eegplugin_erplab.m')-1);
                        save(fullfile(p,'memoryerp.erpm'), field,'-append');                        
                catch
                        msgboxText = ['ERPLAB could not find "memoryerp.erpm" or does not have permission for writting on it.\n'...
                                      'Please, run EEGLAB once again or go to ERPLAB''s Setting menu and specify/create a new memory file.\n'];
                        try
                                cprintf([0.45 0.45 0.45], msgboxText');
                        catch
                                fprintf(msgboxText);
                        end
                        return
                end
        end
else % invalid inputs
        msgboxText = 'Wrong number of inputs for erpworkingmemory.m\n';
        try
                cprintf([0.45 0.45 0.45], msgboxText');
        catch
                fprintf(msgboxText);
        end
        output = [];
        return
end