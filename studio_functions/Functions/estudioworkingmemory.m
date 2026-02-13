% PURPOSE  : encodes and retrieves ERPLAB's working memory
%
% FORMAT   :
%
% output = estudioworkingmemory(field, input2store)
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
% estudioworkingmemory('pop_appenderp', { optioni, erpset, prefixlist });
%
%
% EXAMPLE 2: retrieve pop_appenderp's memory (values last used)
%
% def  = estudioworkingmemory('pop_appenderp');
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon &Guanghui Zhang
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009 & 2024

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

function output = estudioworkingmemory(field, input2store);
output = [];
if nargin<1
    help estudioworkingmemory
    return
end
try
    vmemoryestudio = evalin('base', 'vmemoryestudio');
catch
    vmemoryestudio = [];
end


if nargin==1 % read
    if ~isempty(vmemoryestudio)  %  variable at the workspace for storing/reading memory
        if isfield(vmemoryestudio, field)
            output = vmemoryestudio.(field);
        else
            output = [];
        end
    else % file for storing/reading memory
        try
            p = which('o_ERPDAT');
            p = p(1:findstr(p,'o_ERPDAT.m')-1);
            v = load(fullfile(p,'memoryerpstudio.erpm'), '-mat');
        catch
            msgboxText = ['EStudio (memoryerpstudio.m) could not find "memoryerpstudio.erpm" or does not have permission for reading it.\n'...
                'Please, run EStudio again or go to EStudio''s Setting menu and specify/create a new memory file.\n'];
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
    if ~isempty(vmemoryestudio) %  variable at the workspace for storing/reading memory
        try
            vmemoryestudio.(field) = input2store;
            assignin('base','vmemoryestudio', vmemoryestudio);
        catch
            msgboxText = 'EStudio (estudioworkingmemory.m) could not write to the variable called vmemoryestudio, at workspace.';
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
            p = which('o_ERPDAT');
            p = p(1:findstr(p,'o_ERPDAT.m')-1);
            save(fullfile(p,'memoryerpstudio.erpm'), field,'-append');
        catch
            % Try to create the file if it doesn't exist
            msgboxText1 = 'EStudio could not find "memoryerpstudio.erpm" - attempting to create new file...\n';
            try
                cprintf([0.45 0.45 0.45], msgboxText1);
            catch
                fprintf(msgboxText1);
            end

            try
                p1 = which('o_ERPDAT');
                p1 = p1(1:findstr(p1,'o_ERPDAT.m')-1);
                EStudioversion= 16;
                save(fullfile(p1,'memoryerpstudio.erpm'),'EStudioversion');
                msgboxText2 = 'memoryerpstudio.erpm created\n';
                try
                    cprintf([0.45 0.45 0.45], msgboxText2);
                catch
                    fprintf(msgboxText2);
                end
            catch
                % Only show error if we truly can't create/write the file
                msgboxText3 = ['Failed to create memoryerpstudio.erpm. This may be because EStudio does not have permission to write the erplab folder. Please go to EStudio''s Setting menu and specify a different memory file location.\n'];
                try
                    cprintf([0.45 0.45 0.45], msgboxText3);
                catch
                    fprintf(msgboxText3);
                end
            end
            return
        end
    end
else % invalid inputs
    msgboxText = 'Wrong number of inputs for estudioworkingmemory.m\n';
    try
        cprintf([0.45 0.45 0.45], msgboxText');
    catch
        fprintf(msgboxText);
    end
    output = [];
    return
end
