% PURPOSE  :  This experimental function creates a new dataset with
% Standard Error of the Mean data in the place of ERP data, for further
% visualization.
%
% FORMAT  :
%
% ERP = make_SEM_set(ERP)
%
% INPUTS  :
%
% ERP       input ERP dataset (generated with SEM 'on' when averaging)
%
% OUTPUTS  :
%
% ERP       output dataset (with SEM data in place of EEG data)
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Andrew X Stewart
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% ERPLAB Toolbox
% Copyright © 2016 The Regents of the University of California
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
% You should have received a copy of the GNU General Public License along
% with this program.  If not, see <http://www.gnu.org/licenses/>.

function [ERP, ERPCOM] = make_SEM_set(ERP,savefile, gui)

% https://github.com/lucklab/erplab/wiki/Datatype-Transformations


% check input dataset
if isfield(ERP,'binerror') == 0
    msgboxText =  'This ERPSET is missing SEM data. Please run the ERP averager again with SEM option ticked.';
    title      = 'ERPLAB: SEM data problems?';
    errorfound(msgboxText, title);
    return
end


if numel(ERP.binerror) ~= numel(ERP.bindata)
    msgboxText =  'This ERPSET is missing SEM data. Please run the ERP averager again with SEM option ticked';
    title      = 'ERPLAB: SEM data problems?';
    errorfound(msgboxText, title);
    return
end

if strcmp(ERP.datatype,'SEM') == 1
    msgboxText =  'This ERPSET already contains SEM data in data?';
    title      = 'ERPLAB: SEM data problems?';
    errorfound(msgboxText, title);
    return
end

if exist('gui','var') == 0
    gui = 'erplab';
end

if exist('savefile','var') == 0
    savefile = 1;
end


ERP.datatype = 'SEM';
ERP.bindata = ERP.binerror;

% Write the history with a SEM note
ERPCOM = '% converted dataset to Standard Error of Mean datatype';

ERP = erphistory(ERP,[],'% converted dataset to Standard Error of Mean datatype',1);
ERP = erphistory(ERP,[],'ERP = make_SEM_set(ERP)',1);
ERP = orderfields(ERP);


if savefile == 1
    
    fname = [ERP.filename '_SEM_data.erp'];
    
    
    pop_savemyerp(ERP,'erpname',[ERP.erpname '_SEM_data'],'filename',fname,'gui',gui)
end