% PURPOSE  : 	Averages across MVPCsets (grand average)
%
% FORMAT   :
%
% MVPC = pop_mvpcaverager( ALLMVPC , Parameters);
%
%
% INPUTS   :
%
% ALLMVPC            - structure array of MVPC structures (MVPCsets)
%
% The available parameters are as follows:
%
% 'mvpcsets'         - index(es) pointing to ERP structures within ALLMVPC (only valid when ALLMVPC is specified)
% 'Weighted'        - 'on' means apply weighted-average, 'off' means classic average.
% 'SEM'             - Get standard error of the mean. 'on' or 'off'
% 'ExcludeNullBin'  - Exclude any null bin from non-weighted averaging (Bin that has zero "epochs" when averaged)
% 'Warning'         - Warning 'on' or 'off'
% 'Criterion'       - Max allowed mean artifact detection proportion
% 'DQ_Flag'         - Data Quality options 'on' or 'off'
% 'DQ_Spec'         - Structure array of Data Quality specifications.
%
% OUTPUTS  :
%
% ERP               - data structure containing the average of all specified datasets.
%
%
% EXAMPLE  :
%
% ERP = pop_gaverager( ALLMVPC , 'mvpcsets',1:4, 'Criterion',100, 'SEM',...
% 'on', 'Warning', 'on', 'Weighted', 'on' );
%
% or
%
% ERP = pop_gaverager('C:\Users\Work\Documents\MATLAB\ERP_List.txt', 'Criterion',100,...
% 'SEM', 'on', 'Warning', 'on', 'Weighted', 'on');
%
%
% See also mvpcaveragerGUI.m mvpcaverager.m pop_mvpcaverager.m 
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Aaron Matthew Simmons, Javier Lopez-Calderon & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2023

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



function [MVPC] = pop_mvpcaverager(ALLMVPC,varargin)
% mvpccom  ''; 
MVPC = preloadMVPC; 

if nargin==1  % GUI
    if ~iscell(ALLMVPC) && ~ischar(ALLMVPC)
        if isstruct(ALLMVPC)
%             iserp = iserpstruct(ALLMVPC(1));
%             if ~iserp
%                 ALLMVPC = [];
%             end
            actualnset = length(ALLMVPC);
        else
            ALLMVPC = [];
            actualnset = 0;
        end
        
        def  = erpworkingmemory('pop_mvpcaverager');
        if isempty(def)
            def = { actualnset 0 '' 1};
        else
            def{1}=actualnset;
        end
        if isnumeric(def{3}) && ~isempty(ALLMVPC) %if ALLMVPC indexs are supplied
            if max(def{3})>length(ALLMVPC)
                def{3} = def{3}(def{3}<=length(ALLMVPC));
            end
            if isempty(def{3})
                def{3} = 1;
            end
        end
        
        def{2} = 0; %aaron: until I fix lists, always load mvpcmenu

        %
        % Open Grand Average GUI
        %
        answer = mvpcaveragerGUI(def);
        
        if isempty(answer)
            disp('User selected Cancel')
            return
        end
        
        optioni    = answer{1}; %1 means from a filelist, 0 means from mvpcsets menu
        mvpcset     = answer{2};
        stderror   = answer{3}; % 0;1
      
        
        if optioni==1 % from files
            filelist    = mvpcset;
            disp(['pop_gaverager(): For file-List, user selected ', filelist])
            ALLMVPC = {ALLMVPC, filelist}; % truco
        else % from mvpcsets menu
            %mvpcset  = mvpcset;
        end
        
        %def = {actualnset, optioni, mvpcset,stderror};
        def = {actualnset, optioni, mvpcset,stderror};
        erpworkingmemory('pop_mvpcaverager', def);
        if stderror==1
            stdsstr = 'on';
        else
            stdsstr = 'off';
        end
            %
            % Somersault
            %
            %[ERP erpcom]  = pop_gaverager(ALLMVPC, 'mvpcsets', mvpcset, 'Loadlist', filelist,'Criterion', artcrite,...
            %        'SEM', stdsstr, 'Weighted', wavgstr, 'Saveas', 'on');
            [MVPC]  = pop_mvpcaverager(ALLMVPC, 'Mvpcsets', mvpcset, 'SEM', stdsstr,...
               'Warning', 'off', 'Saveas','on','History', 'gui');
        pause(0.1)
        return
    else
        fprintf('pop_mvpcaverager() was called using a single (non-struct) input argument.\n\n');
    end
end

p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLMVPC');
% option(s)
p.addParamValue('MVPCindex', []);               % same as Erpsets
p.addParamValue('Mvpcsets', []);
p.addParamValue('SEM', 'off', @ischar);        % 'on', 'off'
p.addParamValue('Saveas', 'off', @ischar);     % 'on', 'off'
p.addParamValue('Warning', 'off', @ischar);    % 'on', 'off'
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ALLMVPC, varargin{:});

mvpcset = p.Results.Mvpcsets;

if ismember_bc2({p.Results.Saveas}, {'on','yes'})
    issaveas = 1;
else
    issaveas = 0;
end

if isempty(mvpcset)
    mvpcset = p.Results.MVPCindex;
end

if isempty(mvpcset)
    error('ERPLAB says: "MVPCsets" parameter was not specified.');
end

lista = ''; 
if isnumeric(mvpcset)
    nfile = length(mvpcset);
    optioni = 0 ;
else
    optioni = 1; %from file 
    filelist = '';
     if iscell(ALLMVPC)             % from the GUI, when ALLMVPC exist and user picks a list up as well
        filelist = ALLMVPC{2};
        ALLMVPC   = ALLMVPC{1};
    elseif ischar(ALLMVPC)         % from script, when user picks a list.
        filelist = ALLMVPC;
    else
        error('ERPLAB says: "Mvpcsets" parameter is not valid.')
    end
    if ~iscell(filelist) && ~isempty(filelist)
        if exist(filelist, 'file')~=2
            error('ERPLAB:error', 'ERPLAB says: File %s does not exist.', filelist)
        end
        disp(['For file-List, user selected ', filelist])
        
        %
        % open file containing the erp list
        %
        fid_list = fopen( filelist );
        formcell = textscan(fid_list, '%[^\n]','CommentStyle','#', 'whitespace', '');
        lista    = formcell{:};
        lista    = strtrim(lista); % this fixes the bag described by Darren Tanner and Katherine Stavropoulos
        nfile    = length(lista);
        fclose(fid_list);
    else
        error('ERPLAB says: error at pop_appenderp(). Unrecognizable input ')
    end
end

if ismember_bc2({p.Results.SEM}, {'on','yes'})
    stderror = 1;
else
    stderror = 0;
end

%
%subroutine
%

MVPCaux = MVPC;
[MVPC, serror, msgboxText] = mvpcaverager(ALLMVPC, lista, optioni, mvpcset, nfile, stderror);


if serror>0
    title = 'ERPLAB: gaverager() Error';
    errorfound(msgboxText, title);
    return
end

% Completion statement
%
msg2end
if issaveas
    

    [MVPC, issave] = pop_savemymvpc(MVPC,'gui','averager');
    if issave>0
        if issave==2
           % erpcom = sprintf('%s\n%s', erpcom, erpcom_save);
            msgwrng = '*** Your ERPset was saved on your hard drive.***';
        else
            msgwrng = '*** Warning: Your ERPset was only saved on the workspace.***';
        end
    else
        msgwrng = 'ERPLAB Warning: Your changes were not saved';
        MVPC = MVPCaux;
    end
    try cprintf([1 0.52 0.2], '%s\n\n', msgwrng); catch,fprintf('%s\n\n', msgwrng);end ;
end


return