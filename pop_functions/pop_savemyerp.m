% PURPOSE  :	Saves ERP dataset
%
% FORMAT   :
%
% pop_savemyerp(ERP)    %gui will open
%
% or
%
% pop_savemyerp( ERP, parameters);
%
% INPUTS   :
%
% ERP           - erplab dataset
%
% The available parameters are as follows:
%
%         'erpname'          - ERP name to be saved
%         'filename'         - name of ERP to be saved
%         'filepath'         - name of path ERP is to be saved in
%         'gui'              - 'save', 'saveas', 'erplab' or 'none'
%         'overwriteatmenu'  - overwite erpset at erpsetmenu (no gui). 'on'/'off'
%         'Warning'          - 'on'/'off'
%
%
% OUTPUTS
%
% - saved ERP dataset, titled file_name.erp
%
% EXAMPLE  :
%
% pop_savemyerp( ERP, 'erpname', 'S1_ERPs', 'filename', 'S1_ERPs.erp', 'filepath', 'C:\Users\Work\Documents\MATLAB');
%
%
% See also savemyerpGUI.m saveERP.m
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

function [ERP, issave, erpcom] = pop_savemyerp(ERP, varargin)
issave = 0;
erpcom ='';
if nargin<1
        help pop_savemyerp
        return
end
% try
        % parsing inputs
        p = inputParser;
        p.FunctionName  = mfilename;
        p.CaseSensitive = false;
        p.addRequired('ERP');
        p.addParamValue('erpname', '', @ischar);
        p.addParamValue('filename', '', @ischar);
        p.addParamValue('filepath', '', @ischar); % 10-20-11
        p.addParamValue('gui', 'no', @ischar); % or 'save' or 'saveas' or 'erplab'
        p.addParamValue('overwriteatmenu', 'no', @ischar);
        p.addParamValue('Warning', 'off', @ischar); % on/off  Warning for existing file
        p.addParamValue('History', 'script', @ischar); % history from scripting
        p.parse(ERP, varargin{:});
        
        if isempty(ERP)
                msgboxText = 'No ERPset was found!';
                title_msg  = 'ERPLAB: pop_savemyerp() error:';
                errorfound(msgboxText, title_msg);
                return
        end
        if ~iserpstruct(ERP)
                msgboxText = 'pop_savemyerp only works with a valid ERP structure';
                title = 'ERPLAB: pop_savemyerp() error:';
                errorfound(msgboxText, title);
                return
        end
        if ~isfield(ERP, 'bindata')
                msgboxText =  'pop_savemyerp cannot save an empty ERP dataset';
                title = 'ERPLAB: pop_savemyerp() error:';
                errorfound(msgboxText, title);
                return
        end
        if isempty(ERP.bindata)
                msgboxText =  'pop_savemyerp cannot save an empty ERP dataset';
                title = 'ERPLAB: pop_savemyerp() error:';
                errorfound(msgboxText, title);
                return
        end
        
        filenamex    = strtrim(p.Results.filename);
        filepathx    = strtrim(p.Results.filepath);
        fullfilename = fullfile(filepathx, filenamex); % full path. 10-20-11
        erpname      = p.Results.erpname;
        
        if isempty(erpname)
                erpname = ERP.erpname;
        end
        overw  = p.Results.overwriteatmenu;
        if strcmpi(overw,'yes')||strcmpi(overw,'on')
                overw = 1;   %
        else
                overw = 0;   %
        end
        if strcmpi(p.Results.Warning,'on')
                warnop = 1;   %
        else
                warnop = 0;   %
        end
        if strcmpi(p.Results.History,'implicit')
                shist = 3; % implicit
        elseif strcmpi(p.Results.History,'script')
                shist = 2; % script
        elseif strcmpi(p.Results.History,'gui')
                shist = 1; % gui
        else
                shist = 0; % off
        end
        
        %
        % Setting saving
        %
        if strcmpi(p.Results.gui,'erplab')% open GUI to save erpset
                if overw==0
                        
                        %
                        % Call GUI
                        %
                        answer = savemyerpGUI(erpname, fullfilename, 0); % open GUI to save erpset
                        if isempty(answer)
                                disp('User selected Cancel')
                                return
                        end
                        erpname  = answer{1};
                        if isempty(erpname)
                                disp('User selected Cancel') % change
                                return
                        end
                        fullfilename = answer{2};
                        overw        = answer{3}; % over write in memory? 1=yes
                else
                        % do not open gui, and overwite erpset at erpsetmenu
                        erpname = ERP.erpname;
                        fullfilename = '';
                end
                ERP.erpname = erpname;
                ERP.filename = '';
                ERP.filepath = '';
                ERP.saved    = 'no';
                modegui = 0; % open GUI to save erpset
                warnop  = 1;
        elseif strcmpi(p.Results.gui,'save') % just save, no ask
                if isempty(ERP.filename)
                        modegui = 2; % open a "save as" window to save
                        filenamex = strtrim(p.Results.filename);
                        filepathx = strtrim(p.Results.filepath);
                        fullfilename = fullfile(filepathx, filenamex); % full path. 10-20-11
                        %fullfilename = p.Results.filename;
                else
                        modegui = 1;
                        fullfilename = fullfile(ERP.filepath, ERP.filename);
                        warnop  = 0;
                end
                overw   = 1; % overwrite on menu
        elseif strcmpi(p.Results.gui,'saveas')% open a "save as" window to save
                shist  = 1; % JLC.08/24/13
                modegui = 2; % open a "save as" window to save
                if isempty(fullfilename)
                        fullfilename = fullfile(ERP.filepath, ERP.filename);
                end
                overw  = 1;
                warnop = 0;
        else
                modegui = 3; % save from script
                if isempty(fullfilename)
                        fullfilename = fullfile(ERP.filepath, ERP.filename);
                        if isempty(fullfilename)
                                error('ERPLAB says: You must specify a filename (path included) to save your ERPset.')
                        end
                        fprintf('\nNOTE: Since ''filename'' and ''filepath'' were not specified, \nERPLAB used ERP.filename and ERP.filepath to save your ERPset.\n\n');
                end
                if isempty(erpname)
                        erpname = ERP.erpname;
                else
                        ERP.erpname = erpname;
                end
                if isempty(erpname)
                        error('ERPLAB says: You must specify an erpname to save your ERPset.')
                end
        end
        
        %
        % Saving
        %
        if modegui==0  % save as from erplab gui
                if ~isempty(fullfilename)
                        disp(['Saving ERP at ' fullfilename '...'] )
                        [ERP, serror] = saveERP(ERP, fullfilename, 0);
                        if serror==1
                                return
                        end
                        issave = 2;
                else
                        issave = 1;
                end
                checking = checkERP(ERP);
        elseif modegui==1 % save directly
                disp(['Saving ERP at ' fullfilename '...'] )
                [ERP, serror] = saveERP(ERP, fullfilename, 0, 0);
                if serror==1
                        return
                end
                issave = 2;
                checking = checkERP(ERP);
        elseif modegui==2 % save as (open window)
                disp(['Saving ERP at ' fullfilename '...'] )
                [ERP, serror, fullfilename] = saveERP(ERP, fullfilename, 1);
                if serror==1
                        return
                end
                issave = 2;
                checking = checkERP(ERP);
        elseif modegui==3 % save from script
                if ~isempty(fullfilename)
                        disp(['Saving ERP at ' fullfilename '...'] )
                        [ERP, serror] = saveERP(ERP, fullfilename, 0, warnop);
                        checking = checkERP(ERP);
                        if serror==1 || checking==0
                                error('ERPLAB says: An error occured during saving.')
                        end
                        issave = 2;
                else
                        issave = 1;
                end
                
                %msg2end
                return
        else
                error('ERPLAB says: Oops! error at pop_savemyerp()')
        end       
        if overw==1
                if checking
                        ALLERP     = evalin('base', 'ALLERP');
                        CURRENTERP = evalin('base', 'CURRENTERP');
                        ALLERP(CURRENTERP) = ERP;
                        assignin('base','ALLERP',ALLERP);  % save to workspace
                        updatemenuerp(ALLERP,1)            % overwrite erpset at erpsetmenu
                else
                        issave = 0;
                        return
                end
        else
                if checking
                        pop_loaderp('filename', 'workspace', 'UpdateMainGui', 'on', 'History', 'off');
                else
                        issave = 0;
                        return
                end
        end
        %issave = 1;
        if isempty(fullfilename)
                pname='';
                fname='';
                ext='';
        else
                [pname, fname, ext] = fileparts(fullfilename) ; %10-20-11
        end
        fname = [fname ext];
        erpcom = sprintf('%s = pop_savemyerp(%s', inputname(1), inputname(1));
        if ~isempty(erpname)
                erpcom = sprintf('%s, ''erpname'', ''%s''', erpcom, erpname);
        end
        if ~isempty(fname)
                erpcom = sprintf('%s, ''filename'', ''%s''', erpcom, fname);
        end
        if ~isempty(pname)
                erpcom = sprintf('%s, ''filepath'', ''%s''', erpcom, pname);
                if warnop==1
                        erpcom = sprintf('%s, ''Warning'', ''on''', erpcom);
                end
        end
        erpcom = sprintf('%s);', erpcom);
% catch
%         serr = lasterror;
%         msgboxText= ['ERPLAB found an error at: \n\n'...
%                 serr.message];
%         title = 'ERPLAB: pop_savemyerp() error:';
%         errorfound(sprintf(msgboxText), title);
%         erpcom = '';
%         return
% end

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
                displayEquiComERP(erpcom);
        case 2 % from script
                ERP = erphistory(ERP, [], erpcom, 1);
        case 3 % implicit
                % just using erpcom
        otherwise %off or none
                erpcom = '';
                return
end
return