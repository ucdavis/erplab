% PURPOSE  : Save BEST (.mat) file.
%
% FORMAT   :
%
% >>  [BEST] = pop_savemybest(BEST, parameters);
%
% INPUTS   :
%
%         BEST             - Bin-Epoched Single Trial (BEST) structure
%
% The available input parameters are as follows:
%         'bestname'       - BESTname to be saved
%         'filename'       - Output filename string as .best extension
%         'filepath'       - Output file path
%         'gui'            - 'save', 'saveas', 'erplab', or 'none'
%                            - 'save' allows to save file to hard disk 
%                            - 'saveas' allows to save file disk, user
%                            choose desination with GUI and/or with new
%                            specified filename. 
%                             - 'none': for used with scriping; specify
%                             file name and path; no GUI popup
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
%
%
% See also: savemybestGUI.m savebest.m
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


function [BEST, issave] = pop_savemybest(BEST, varargin)
issave = 0 ;
com = ''; 


if nargin<1
    help pop_savemybest
    return
end

% parse inputs
p = inputParser; 
p.FunctionName = mfilename;
p.CaseSensitive = false;
p.addRequired('BEST');

%optional
p.addParamValue('bestname', '', @ischar); 
p.addParamValue('filename', '', @ischar); %EEG.filename
p.addParamValue('filepath', '', @ischar);
p.addParamValue('gui','no',@ischar); % or 'save', or 'saveas', or 'erplab'
p.addParamValue('overwriteatmenu','no',@ischar); 
p.addParamValue('Warning','off',@ischar); % on/off warning for existing file
p.addParamValue('History','script',@ischar); 

p.parse(BEST, varargin{:}); 

if isempty(BEST)
    msgboxText = 'No Bin-Epoched Single-Trial (BEST) Data was found!';
    title_msg  = 'ERPLAB: pop_savemybest() error:';
    errorfound(msgboxText, title_msg);
    return
end

%extract vars

filenamex    = strtrim(p.Results.filename);
filepathx    = strtrim(p.Results.filepath);
fullfilename = fullfile(filepathx, filenamex); % full path
bestname = p.Results.bestname;
overw = p.Results.overwriteatmenu;


if isempty(bestname)
    bestname = BEST.bestname; 
else
    BEST.bestname = bestname; 
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
elseif strcmpi(p.Results.History,'gui') || strcmpi(p.Results.History,'erplab') 
    shist = 1; % gui
    
else
    shist = 0; % off
end


%
%Setting saving
% 

if strcmpi(p.Results.gui,'erplab') % open GUI to save BESTset 
    if overw == 0 
        
        %
        % Call GUI
        %
%         

        if ~isempty(bestname)
            bestname = {bestname}; 
            
        end

        answer = savemybestGUI(bestname, fullfilename,0); 
        
        if isempty(answer)
            disp('User selected Cancel')
            return
        end
        bestname  = answer{1};
        if isempty(bestname)
            disp('User selected Cancel') % change
            return
        end
        
        fullfilename = answer{2};
        overw        = answer{3}; % over write in memory? 1=yes
        
    else
        %do not open gui, and overwrite bestset at bestset menu
        bestname = BEST.bestname; 
        fullfilename = ''; 
    end
    
    BEST.bestname = bestname; 
    BEST.filename = ''; 
    BEST.filepath = ''; 
    BEST.saved = 'no'; 
    modegui = 0; % do not open GUI to save
    warnop = 1;
    shist = 1; %change history to implicit beacuse called from pop_extractbest()
        
elseif strcmpi(p.Results.gui, 'save') %just save, no ask
    if isempty(BEST.bestname)
        modegui = 2; % open a "save as" window to save
        filenamex = strtrim(p.Results.filename);
        filepathx = strtrim(p.Results.filepath);
        fullfilename = fullfile(filepathx, filenamex); % full path. 10-20-11
        %fullfilename = p.Results.filename;
    else
        modegui = 1;
        fullfilename = fullfile(BEST.filepath,BEST.filename);
        warnop  = 0;
    end
    overw   = 1; % overwrite on menu

%  "SAVE AS" .
elseif strcmpi(p.Results.gui,'saveas')
    if isempty(fullfilename)
        
        try
            filenamex = BEST.bestname;
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
%     if isempty(erpname)
%         erpname = ERP.erpname;
%     else
%         ERP.erpname = erpname;
%     end
%     if isempty(erpname)
%         error('ERPLAB says: You must specify an erpname to save your ERPset.')
%     end
%     
    
end


%
% Saving
% 
if modegui == 0 
    % "save-as" filepath has already been gathered from erplab GUI
    % so NO extra gui will show (modegui =0) 
   
    if ~isempty(fullfilename)
        %disp(['Saving BESTset at ' fullfilename '...'] )
        [BEST, serror] = saveBEST(BEST, fullfilename, 0, warnop); %modegui = 0
        if serror==1
            return
        end
        issave = 2;
    else % or the is no fullfilename (so no saving, just update menu)
        issave = 1;
    end
    
elseif modegui == 1 %"save" filepath has not been gathered yet, open new GUI
    
    if ~isempty(fullfilename)
        %disp(['Saving BESTset at ' fullfilename '...'] )
        [BEST, serror] = saveBEST(BEST, fullfilename, 0, warnop);
        if serror==1
            return
        end
        issave = 2; %saved on harddrive
    else
        issave = 1; %saved only on workspace 
    end

elseif modegui==2  
    % save as (open window)
    %disp(['Saving BEST at ' fullfilename '...'] )
    [BEST, serror,fullfilename] = saveBEST(BEST, fullfilename, 1, warnop);
    if serror==1

        return
    end
    issave = 2;
    
elseif modegui==3 %save by script
    overw = 2; %skip loading it into the menu
    if ~isempty(fullfilename)
        %disp(['Saving BESTset at ' fullfilename '...'] )
        [BEST, serror] = saveBEST(BEST, fullfilename, 0, warnop);
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
    error('ERPLAB says: Oops! error at pop_savemybest()'); 
    
end


%overwriting in BESTset menu list 
if overw==1
    
    ALLBEST     = evalin('base', 'ALLBEST');
    CURRENTBEST = evalin('base', 'CURRENTBEST');
    ALLBEST(CURRENTBEST) = BEST;
    assignin('base','ALLBEST',ALLBEST);  % save to workspace
    updatemenubest(ALLBEST,1)            % overwrite erpset at erpsetmenu
    
elseif overw == 0
    assignin('base','BEST',BEST);
    pop_loadbest('filename', 'workspace', 'UpdateMainGui', 'on');
    if issave ~= 2 
        issave = 1;
    end
       
    
end


%
%history
%
if isempty(fullfilename)
    pname='';
    fname='';
    ext='';
else
    [pname, fname, ext] = fileparts(fullfilename) ; %10-20-11
end
fname = [fname ext];
bestcom = sprintf('%s = pop_savemybest(%s', inputname(1), inputname(1));
if ~isempty(bestname)
    bestcom = sprintf('%s, ''bestname'', ''%s''', bestcom, bestname);
end
if ~isempty(fname)
    bestcom = sprintf('%s, ''filename'', ''%s''', bestcom, fname);
end
if ~isempty(pname)
    bestcom = sprintf('%s, ''filepath'', ''%s''', bestcom, pname);
    if warnop==1
        bestcom = sprintf('%s, ''Warning'', ''on''', bestcom);
    end
end
bestcom = sprintf('%s);', bestcom);


switch shist
        case 1 % from GUI
                displayEquiComERP(bestcom);
        case 2 % from script
                %ERP = erphistory(ERP, [], erpcom, 1);
        case 3 % implicit
                % just using erpcom
        otherwise %off or none
                bestcom = '';
                return
end

end
