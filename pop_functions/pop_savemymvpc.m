% PURPOSE  : Save MVPC (.mvpc) file.
%
% FORMAT   :
%
% >>  [MVPC] = pop_savemymvpc(MVPC, parameters);
%
% INPUTS   :
%
%         MVPC             - Multivariate Pattern Classification (MVPC) structure
%
% The available input parameters are as follows:
%         'mvpcname'       - mvpc name to be saved
%         'filename'       - Output filename string as .best extension
%         'filepath'       - Output file path
%         'gui'            - 'save', 'saveas', 'erplab', or 'none'
%                            - 'save' allows to save file to hard disk 
%                            - 'saveas' allows to change bestname, save to
%                            hard disk
%         'overwriteatmenu' - overwrite bestset at bestset menu 
%                            'on'/'off'
%         'warning'         - warning if overwriting file with same filename: 'on'(default)/off' 
%
%
% Optional INPUTS  : 
%          'modegui'       - If 0 (Default), directly saves the file at filepath (NO GUI)
%                            If 1, save window GUI pops up to confirm save path. 
%                            
%
% EXAMPLE  :
%
% pop_savemymvpc( EEG , 'Channel',  1:16, 'Flag',  1, 'Threshold', 100, 'Twindow', [ -200 798], 'Windowsize', 200, 'Windowstep',  100 );
%
% See also: savemymvpcGUI.m savemvpc
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Aaron Matthew Simmons
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022

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


function [MVPC, issave] = pop_savemymvpc(MVPC,varargin)
issave = 0; 
com = '';

if nargin <1 
    help pop_savemymvpc
    return
end
% parse inputs
p = inputParser; 
p.FunctionName = mfilename;
p.CaseSensitive = false;
p.addRequired('MVPC');


%optional
%optional
p.addParamValue('ALLMVPC',[]); %only for the decoding toolbox gui
p.addParamValue('mvpcname', '', @ischar); 
p.addParamValue('filename', '', @ischar); %EEG.filename
p.addParamValue('filepath', '', @ischar);
p.addParamValue('gui','no',@ischar); % or 'save', or 'saveas', or 'erplab'
p.addParamValue('overwriteatmenu','no',@ischar); 
p.addParamValue('Warning','on',@ischar); % on/off warning for existing file
p.addParamValue('modegui',1,@isnumeric);
p.addParamValue('History','script',@ischar); 


p.parse(MVPC,varargin{:}); 

if isempty(MVPC)
    msgboxText = 'No Multivariate Pattern Classification (MVPC) Data was found!';
    title_msg  = 'ERPLAB: pop_savemymvpc() error:';
    errorfound(msgboxText, title_msg);
    return
end

ALLMVPC = p.Results.ALLMVPC; 
filenamex    = strtrim(p.Results.filename);
filepathx    = strtrim(p.Results.filepath);
fullfilename = fullfile(filepathx, filenamex); % full path
mvpcname = p.Results.mvpcname;
overw = p.Results.overwriteatmenu; 
modegui = p.Results.modegui; 

if isempty(mvpcname)
    mvpcname = MVPC.mvpcname; 
else
    MVPC.mvpcname = mvpcname; 
end

if strcmpi(overw,'yes')||strcmpi(overw,'on')
    overw = 1;
else
    overw = 0;
end

if strcmpi(p.Results.Warning,'on')
    warnop = 1;
else
    warnop = 0;
end

if strcmpi(p.Results.History,'implicit')
    shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
    shist = 2; % script
elseif strcmpi(p.Results.History,'erplab')
    shist = 1; % gui
else
    shist = 0; % off
end


if strcmpi(p.Results.gui,'erplab') % open GUI to save MVPCset 

    if overw == 0 
       %GUI was already opened in pop_decoding
       %MVPC filenames and pathnames already established
       %Use ALLMVPC rather than MVPC since could be multiple saves
       
       filename = {ALLMVPC.filename};
       filepathx = {ALLMVPC.filepath}; 
       
       if ~isempty([ALLMVPC(:).filename]) && ~isempty([ALLMVPC(:).filepath])
            fullfilename = strcat(filepathx(:),filesep,filename(:));
       else
           fullfilename = '';
           shist = 0; %they did not specify to save to harddisk 
       end
       overw = 0; %no option to overwrite mvpcset
    else
        %do not open gui, and overwrite mvpcset at mvpcset menu
        mvpcname = {ALLMVPC.mvpcname};
        fullfilename = ''; 

    end

    for i=1:numel(ALLMVPC)
        ALLMVPC(i).saved    = 'no';
    end
    modegui = 0; 
    warnop = 1; 

elseif strcmpi(p.Results.gui,'averager')


    if ~isempty(mvpcname)
        mvpcname = {mvpcname}
    end

    answer = savemymvpcGUI(mvpcname, fullfilename, 0);

    if isempty(answer)
        disp('User selected Cancel')
        return
    end
    MVPC.mvpcname  = answer{1};
    mvpcname = answer{1}; 
    fullfilename = answer{2};
    if isempty(mvpcname)
        disp('User selected Cancel') % change
        return
    end

    overw = 0; 
    modegui = 1;






elseif strcmpi(p.Results.gui, 'save') %just save, no ask
    if isempty(MVPC.mvpcname)
        modegui = 2; % open a "save as" window to save
        filenamex = strtrim(p.Results.filename);
        filepathx = strtrim(p.Results.filepath);
        fullfilename = fullfile(filepathx, filenamex); % full path. 10-20-11
        %fullfilename = p.Results.filename;
    else
        modegui = 1;
        fullfilename = fullfile(MVPC.filepath,MVPC.filename);
        warnop  = 0;
    end
    overw   = 0; % overwrite on menu

%  "SAVE AS" .
elseif strcmpi(p.Results.gui,'saveas')
    if isempty(fullfilename)
        
        try
            filenamex = MVPC.mvpcname;
            filepathx = pwd;
            fullfilename = fullfile(filepathx, filenamex); % full path       
        catch
         %fullfilename = fullfile(ERP.filepath, ERP.filename);
            msgboxText = 'No file path was found?!';
            title_msg  = 'ERPLAB: pop_savemymvpc() error:';
            errorfound(msgboxText, title_msg);
            return
        end
    end
    overw = 1; 
    modegui = 2;
    shist = 1; % gui
else
    overw = 0;
    modegui = 3; %savefrom script
    if isempty(fullfilename)
        fullfilename = fullfile(BEST.filepath, BEST.filename);
        if isempty(fullfilename)
            error('ERPLAB says: You must specify a filename (path included) to save your BESTset.')
        end
        fprintf('\nNOTE: Since ''filename'' and ''filepath'' were not specified, \nERPLAB used BEST.filename and BEST.filepath to save your ERPset.\n\n');
    end


   

end

if modegui == 0 
    % "save-as" fullfilepath already been gathered from multifilesave erplab GUI
    if ~isempty(fullfilename)
        [MVPC,fullfilename,serror] = savemvpc(ALLMVPC, fullfilename, 0, warnop);
        
        issave = 2; %saved on hard drive
        if serror == 1
            return
        end
    else
        issave =1 ;
    end
        
        

 

elseif modegui == 1 %save directly 

    if ~isempty(fullfilename)
        %disp(['Saving BESTset at ' fullfilename '...'] )
        [MVPC, ~, serror] = savemvpc(MVPC, fullfilename, 0, warnop);
        if serror==1
            return
        end
        issave = 2; %saved on harddrive
    else
        issave = 1; %saved only on workspace
    end

elseif modegui == 2


    %disp(['Saving BESTset at ' fullfilename '...'] )
    [MVPC, fullfilename, serror] = savemvpc(MVPC, fullfilename, 1);
    if serror==1
        return
    end
    issave = 2; %saved on harddrive

elseif modegui == 3  % save from script 
    if ~isempty(fullfilename)

        [MVPC,~, serror] = savemvpc(MVPC, fullfilename, 0, warnop);
        if serror==1
            return
        end
        issave = 2;
    else
        issave = 1;
    end
    %msg2end
    return
    
else
    error('ERPLAB says: Oops! error at pop_savemymvpc'); 


end

%overwriting in MVPCset menu list 
if overw==1
    %this isn't possible if using Decoding GUI toolbox
    ALLMVPC     = evalin('base', 'ALLMVPC');
    CURRENTMVPC = evalin('base', 'CURRENTMVPC');
    ALLMVPC(CURRENTMVPC) = MVPC;
    assignin('base','ALLERP',ALLMVPC);  % save to workspace
    updatemenumvpc(ALLMVPC,1)            % overwrite erpset at erpsetmenu
      
    
else
    if strcmpi(p.Results.gui,'erplab')
        %in case of many mvpc sets through Decoding GUI toolbox
        assignin('base','ALLMVPC2',ALLMVPC)
        pop_loadmvpc('filename', 'decodingtoolbox', 'UpdateMainGui', 'on');

    else
        assignin('base','MVPC',MVPC);
        pop_loadmvpc('filename', 'workspace', 'UpdateMainGui', 'on');
    end

    if issave ~= 2 
        issave = 1;
    end
    
    
end

 
if isempty(fullfilename)
    fname = '';
    pname = '';
else
    [pname, fname, ext] = fileparts(fullfilename);
end
ext = '.mvpc';
fname = [fname ext];
mvpccom = sprintf('%s = pop_savemymvpc(%s', inputname(1), inputname(1));
if ~isempty(mvpcname)
    mvpccom = sprintf('%s, ''mvpcname'', ''%s''', mvpccom, mvpcname);
end
if ~isempty(fname)
    mvpccom = sprintf('%s, ''filename'', ''%s''', mvpccom, fname);
end
if ~isempty(filepathx)
    mvpccom = sprintf('%s, ''filepath'', ''%s''', mvpccom, pname);
    if warnop==1
        mvpccom = sprintf('%s, ''Warning'', ''on''', mvpccom);
    end
end
mvpccom = sprintf('%s);', mvpccom);

%
% Completion statement
%
prefunc = dbstack;
nf = length(unique_bc2({prefunc.name}));
if nf==1
        msg2end
end
% get history from script. ERP
switch shist
        case 1 % from GUI
                displayEquiComERP(mvpccom);
        case 2 % from script
                %ERP = erphistory(ERP, [], erpcom, 1);
        case 3 % implicit
                % just using erpcom
        otherwise %off or none
                mvpccom = '';
                return
end



%only output the last MVPC set
MVPC = MVPC(end); 

return










