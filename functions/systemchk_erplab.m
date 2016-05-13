% PURPOSE: checks some diagnostics for running ERPLAB
%
% FORMAT
%
% [allok, systemchk_table*] = systemchk_erplab
% 
% * - optional
%
% INPUT
%
% -
%
% OUTPUT
%
% allok == 1 iff all system checks pass
% systemchk_table - optionally gives a table of checked system values
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

function [allok, systemchk_table] = systemchk_erplab

allok = 0;
i=1;
n=2;
checks = cell(n,3);



% check 1
checks{i,1} = 'path_eeglab';

path_eeglab = fileparts(which('eeglab'));

if isempty(path_eeglab)
    checks{i,2} = 1;
end

checks{i,3} = path_eeglab;


%
i=i+1;
checks{i,1} = 'path_erplab';

path_erplab = fileparts(which('erplab'));

if isempty(path_erplab)
    checks{i,2} = 1;
end

checks{i,3} = path_erplab;


%
i=i+1;
checks{i,1} = 'sig_proc_toolbox';

tbxs = ver;
[a tbxs_n] = size(tbxs);
tbx_cell = cell(1,tbxs_n);
tbx_cell = {tbxs.Name};

checks{i,3} = any(ismember(tbx_cell,'Signal Processing Toolbox'));

if checks{i,3} == 0
    checks{i,2} = 1;
end


%
i=i+1;
checks{i,1} = 'OS';

checks{i,3} = computer;

%
i=i+1;
checks{i,1} = 'arch';

arch = computer('arch');
checks{i,3} = arch(end-1:end);

%
i=i+1;
checks{i,1} = 'Totalmem_GB';

checks{i,3} = totalmem;

%
i=i+1;
checks{i,1} = 'Freemem_GB';

checks{i,3} = freemem;


systemchk_table = table(checks(:,1), checks(:,2), checks(:,3), 'VariableNames', {'Test', 'Error', 'Output'});

if sum(cell2mat(checks(:,2))) == 0
    allok = 1;
    disp_txt = 'ERPLAB system check found no problems';
    disp(disp_txt)
end



%
%
%
%


% subfunctions
function [memout] = totalmem

% Returns total system physical memory in GB
% Andrew Stewart, May 2016 v1

%this_pc = computer('arch');

if ispc
    
    % if Windows
    [a1 a2] = memory;
    memout = a2.PhysicalMemory.Total/1024^3; % Get memory in GB
    
    
elseif ismac
    
    [s,m] = system('sysctl hw.memsize');
    spaces = strfind(m,' ');
    memout = str2num(m(spaces(end):end))/1024^3; % Get memory in GB
    
    
    
elseif isunix  % else, try Unix terminal commands to check memory
    
    [r,w] = system('free | grep Mem');
    stats = str2double(regexp(w, '[0-9]*', 'match'));
    memout = stats(1)/1e6;
    %memout = (stats(3)+stats(end))/1e6;   % Mem in GB,
    
end


function [memout] = freemem

% Returns free physical memory in GB
% Andrew Stewart, May 2014 v1

this_pc = computer('arch');

if ispc
    
    % if Windows
    
    [a1 a2] = memory;
    memout = a2.PhysicalMemory.Available/1024^3; % Get memory in GB
    
    
elseif ismac
    
    [s,m] = system('vm_stat | grep free');
    spaces = strfind(m,' ');
    memout = str2num(m(spaces(end):end))*4096/1024^3; % Get memory in GB
    
    
    
elseif isunix  % else, try Unix terminal commands to check memory
    
    [r,w] = system('free | grep Mem');
    stats = str2double(regexp(w, '[0-9]*', 'match'));
    memsize = stats(1)/1e6;
    memout = (stats(3)+stats(end))/1e6;   % Mem in GB,
    
end
