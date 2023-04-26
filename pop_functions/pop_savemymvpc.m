% PURPOSE  : Save MVPC (.mvpc) file.
%
% FORMAT   :
%
% >>  [MVPC] = pop_savemybest(MVPC, parameters);
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
% pop_artmwppth( EEG , 'Channel',  1:16, 'Flag',  1, 'Threshold', 100, 'Twindow', [ -200 798], 'Windowsize', 200, 'Windowstep',  100 );
%
% See also;  [pop_artblink]
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


function [MVPC, ALLMVPC, issave] = pop_savemymvpc(MVPC,varargin)
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

if strcmpi(p.Results.gui,'erplab') % open GUI to save MVPCset 

    if overw == 0 
       %GUI was already opened in pop_decoding
       %MVPC filenames and pathnames already established
       %Use ALLMVPC rather than MVPC since could be multiple saves
       
       filename = {ALLMVPC.filename};
       filepath = {ALLMVPC.filepath}; 

       fullfilename = strcat(filepath(:),filesep,filename(:));
       overw = 0; %no option to overwrite mvpcset
    else
        %do not open gui, and overwrite mvpcset at mvpcset menu
        mvpcname = {ALLMVPC.mvpcname};
        fullfilename = ''; 

    end

    modegui = 0; 
    warnop = 1; 

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
    overw = 0; 
    modegui = 2;

else
    %save from script! 



end

if modegui == 0 
    % "save-as" fullfilepath already been gathered from multifilesave erplab GUI

    [MVPC,serror] = savemvpc(ALLMVPC, fullfilename, 0, warnop);
    if serror == 1
        return
    end
    issave = 2; %saved on hard drive

elseif modegui == 1 %save directly 

    if ~isempty(fullfilename)
        %disp(['Saving BESTset at ' fullfilename '...'] )
        [MVPC, serror] = savemvpc(MVPC, fullfilename, 0, warnop);
        if serror==1
            return
        end
        issave = 2; %saved on harddrive
    else
        issave = 1; %saved only on workspace
    end

elseif modegui == 2


    %disp(['Saving BESTset at ' fullfilename '...'] )
    [MVPC, serror] = savemvpc(MVPC, fullfilename, 1);
    if serror==1
        return
    end
    issave = 2; %saved on harddrive


end

%overwriting in MVPCset menu list 
if overw==1
    %this isn't possible if using Decoding GUI toolbox
    ALLBEST     = evalin('base', 'ALLBEST');
    CURRENTBEST = evalin('base', 'CURRENTBEST');
    ALLBEST(CURRENTBEST) = BEST;
    assignin('base','ALLERP',ALLBEST);  % save to workspace
    updatemenubest(ALLBEST,1)            % overwrite erpset at erpsetmenu
    
else
    if strcmpi(p.Results.gui,'erplab')
        %in case of many mvpc sets through Decoding GUI toolbox
        assignin('base','ALLMVPC2',MVPC)
        pop_loadmvpc('filename', 'decodingtoolbox', 'UpdateMainGui', 'on');

    else
        assignin('base','MVPC',MVPC);
        pop_loadmvpc('filename', 'workspace', 'UpdateMainGui', 'on');
    end

    if issave ~= 2 
        issave = 1;
    end
    
    
end

%only output the last MVPC set
MVPC = MVPC(end); 

end










