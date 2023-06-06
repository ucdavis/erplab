% PURPOSE  : 	Loads MVPCset(s)
%
% FORMAT   :
%
% ERP = pop_loadmvpc(parameters);
%
% PARAMETERS     :
%
% 'filename'        - ERPset filename
% 'filepath'        - ERPset's filepath
% 'overwrite'       - overwrite current erpset. 'on'/'off'
% 'Warning'         - 'on'/'off'
% 'multiload'       - load multiple ERPset using a single output variable (see example 2). 'on'/'off'
% 'UpdateMainGui'   - 'on'/'off'
%
%
% OUTPUTS  :
%
% ERP	- output ERPset
%
%
% EXAMPLE 1  : Load a single ERPset
%
% ERP = pop_loaderp('filename','S1_ERPS.erp','filepath','/Users/etfoo/Documents/MATLAB/','overwrite','off','Warning','on');
%
% EXAMPLE 2  : Load multiple ERPsets using a single output variable
%
% ERP = pop_loaderp('filename',{'S1_ERPS.erp' 'S2_ERPS.erp' 'S3_ERPS.erp'},'filepath','/Users/etfoo/Documents/MATLAB/','multiload','on');
%
% EXAMPLE 3  : Load multiple ERPsets using two output variable (ERP ALLERP). ALLERP will store all. ERP will store the last ERPset.
%
% [ERP ALLERP] = pop_loaderp('filename',{'S1_ERPS.erp' 'S2_ERPS.erp' 'S3_ERPS.erp'},'filepath','/Users/etfoo/Documents/MATLAB/');
%
%
% See also olderpscan.m
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


function [MVPC, ALLMVPC] = pop_loadmvpc(varargin)

MVPC = preloadMVPC; 

try 
    ALLMVPC = evalin('base', 'ALLMVPC');
    preindex = length(ALLMVPC); 
    
catch 
    disp('WARNING: ALLMVPC structure was not found. ERPLAB will create an empty one.')
    ALLMVPC = [];
    %ALLERP   = buildERPstruct([]);
    preindex = 0;

end

if nargin <1 
    help pop_loadmvpc
    
    return
    
end

if nargin == 1
        filename = varargin{1};
        if strcmpi(filename,'workspace') || strcmpi(filename,'decodingtoolbox')
                filepath = '';
        else
                if isempty(filename)
                        [filename, filepath] = uigetfile({'*.mvpc','MVPC (*.mvpc)'},...
                                'Load MVPC','MultiSelect', 'on');
                        if isequal(filename,0)
                                disp('User selected Cancel')
                                return
                        end
                        
                        %
                        % test current directory
                        %
                        %changecd(filepath) % Steve does not like this...
                else
                        filepath = cd;
                end
        end
        
        %
        % Somersault
        %
        
        [MVPC, ALLMVPC] = pop_loadmvpc('filename', filename, 'filepath', filepath, 'Warning', 'on', 'UpdateMainGui', 'on', 'multiload', 'off');
        return
    
    
    
end


% parsing inputs
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
% option(s)
p.addParamValue('filename', '');
p.addParamValue('filepath', '', @ischar);
p.addParamValue('overwrite', 'off', @ischar);
p.addParamValue('Warning', 'off', @ischar);
p.addParamValue('multiload', 'off', @ischar); % ERP stores ALLERP's contain (ERP = ...), otherwise [ERP ALLERP] = ... must to be specified.
p.addParamValue('UpdateMainGui', 'off', @ischar);
%p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(varargin{:});

filename = strtrim(p.Results.filename);
filepath = strtrim(p.Results.filepath);

if strcmpi(filename,'workspace')
        filepath = '';
        nfile = 1;
        loadfrom = 0;  % load from workspace
elseif strcmpi(filename,'decodingtoolbox')
        filepath = '';
        ALLMVPC2 = evalin('base', 'ALLMVPC2');
        nfile = length(ALLMVPC2);
        preindex = length(ALLMVPC); 
        loadfrom = 2;  % load from workspace
else
        loadfrom = 1; % load from: 1=hard drive; 0=workspace
end


if strcmpi(p.Results.Warning,'on')
        popupwin = 1;
else
        popupwin = 0;
end
if strcmpi(p.Results.UpdateMainGui,'on')
        updatemaingui = 1;
else
        updatemaingui = 0;
end
if strcmpi(p.Results.multiload,'on')
        multiload = 1;
else
        multiload = 0;
end

if loadfrom==1
        if iscell(filename)
                nfile      = length(filename);
                inputfname = filename;
        else
                nfile = 1;
                inputfname = {filename};
        end
else
    if strcmpi(filename,'workspace')
        inputfname = {'workspace'};
    else
        inputfname = {'workspace'};
    end
end

inputpath = filepath;
errorf    = 0; % no error found, by default
conti     = 1; % continue?  1=yes; 0=no

if loadfrom == 1 || loadfrom == 0
    for i=1:nfile
        if loadfrom==1
            fullname = fullfile(inputpath, inputfname{i});
            fprintf('Loading %s\n', fullname);
            L   = load(fullname, '-mat');
            MVPC = L.MVPC;
            %             if i == 1
            %                 BEST = L.BEST;
            %             else
            %                 BEST(i) = L.BEST;
            %             end
        else
            MVPC = evalin('base', 'MVPC');

        end


        if i == 1 && isempty(ALLMVPC)
            ALLMVPC = MVPC;

        else
            ALLMVPC(i+preindex) = MVPC;

        end

    end
elseif loadfrom == 2
    % if loaded from GUI decoding toolbox

    if isempty(ALLMVPC)
        ALLMVPC = ALLMVPC2;
    else

        for i= 1:nfile
            ALLMVPC(i+preindex) = ALLMVPC2(i);
        end

    end


end

if nargout==1 && multiload==1

        MVPC = ALLMVPC(end);
end

if nfile==1
        outv = 'MVPC';
else
        outv = '[MVPC ALLMVPC]';
end

if exist("ALLMVPC2")
    %clear from base 
    evalin('base', 'clear ALLMVPC2'); 
end



if updatemaingui % update erpset menu at main gui
    assignin('base','ALLMVPC',ALLMVPC);  % save to workspace
    updatemenumvpc(ALLMVPC); % add a new bestset to the bestset menu
end


prefunc = dbstack;
nf = length(unique_bc2({prefunc.name}));
if nf==1
        msg2end
end




return
