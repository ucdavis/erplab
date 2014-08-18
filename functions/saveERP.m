% PURPOSE: subroutine for pop_savemyerp.m
%
% FORMAT:
%
% [ERP serror]= saveERP(ERP, erpnamex, filenamex)
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Steven Luck
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

function [ERP, serror, filenamex] = saveERP(ERP, filenamex, modegui, warnop)

serror = 0;

if nargin < 1
        help pop_saveERP
        return
end
if isempty(ERP)
        msgboxText{1} =  'Error: pop_saveERP() error: cannot save an empty dataset';
        tittle = 'ERPLAB: pop_saveERP() error:';
        errorfound(msgboxText, tittle);
        return
end
if ~isfield(ERP, 'bindata')
        msgboxText{1} =  'Error: pop_saveERP() error: cannot save an empty dataset';
        tittle = 'ERPLAB: pop_saveERP() error:';
        errorfound(msgboxText, tittle);
        return
end
if isempty(ERP.bindata)
        msgboxText{1} =  'Error: pop_saveERP() error: cannot save an empty dataset';
        tittle = 'ERPLAB: pop_saveERP() error:';
        errorfound(msgboxText, tittle);
        return
end
if nargin<4
        warnop = 0; % no warning for overwriting a file
end
if nargin<3
        modegui = 0; % no uiputfile
end

%
% Save ERP file
%
ERPaux = ERP;

if isempty(filenamex)
        namef = ERP.filename;
        if isempty(namef)
                namef = ERP.erpname;
        end
else
        namef = filenamex;
end

if isempty(namef)
        namef = '*.erp';
end
if modegui==1 % open uiputfile
        [pathstr, namedef, ext] = fileparts(char(namef));
        [erpfilename, erppathname, indxs] = uiputfile({'*.erp','ERP (*.erp)';...
                '*.mat','ERP (*.mat)'}, ...
                'Save ERP structure as',...
                namedef);

        if isequal(erpfilename,0)
                disp('User selected Cancel')
                serror = 1;
                return
        end

        [pathstr, erpfilename, ext] = fileparts(erpfilename) ;

        if indxs==1
                ext = '.erp';
        elseif indxs==2
                ext = '.mat';
        end
else % direct saving
        if isempty(filenamex)
                serror = 1;
                return
        end
        [erppathname, erpfilename, ext] = fileparts(filenamex);
end
if isequal(erpfilename,0)
        disp('User selected Cancel')
        serror=1;
        return
else        
        if isempty(ERP.erpname)
                ERP.erpname = erpfilename; % without extension
        end
        
        ERP.filename = [erpfilename ext];
        ERP.filepath = erppathname;
        ERP.saved ='yes';
        
        checking = checkERP(ERP);
        
        if checking==0
              msgboxText =  'Error: ERP structure has error.';
              tittle = 'ERPLAB: pop_saveERP() error:';
              errorfound(msgboxText, tittle);
              serror = 1;
              ERP = ERPaux;
              return
        end
        
        filenamex = fullfile(erppathname, [erpfilename ext]);
        % poner mensaje en caso de errores en ERP struct
        
        if exist(filenamex, 'file')~=0 && warnop==1
              msgboxText =  ['This ERPset already exist.\n'...;
                    'Would you like to overwrite it?'];
              title  = 'ERPLAB: WARNING!';
              button = askquest(sprintf(msgboxText), title);
              if strcmpi(button,'no')
                    disp('User canceled')
                    ERP = ERPaux;
                    return
              end
        end      
        save(filenamex, 'ERP');
end
return
