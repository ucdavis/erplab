% PURPOSE  :  Converts dataset from EEG to Current Source Density CSD data
%
% FORMAT  :
%
% EEG = pop_currentsourcedensity( EEG , parameters )
%
% INPUTS  :
%
% EEG       input dataset
%
% OUTPUTS  :
%
% EEG       output dataset (with CSD data in place of EEG data)
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
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

function [EEG, erpcom] = pop_currentsourcedensity(EEG, varargin)
erpcom = '';
savepref = 1;

if isfield(EEG,'bindata')
    isERP = 1;
    EEG.nbchan = EEG.nchan;
else
    isERP = 0;
end

% check input dataset
try 
    elec_num = length(EEG.chanlocs);
    assert(elec_num >= 1)
catch
    msgboxText =  'Can''t generate CSD on empty dataset';
    title      = 'ERPLAB: CSD dataset problems?';
    errorfound(msgboxText, title);
end


% check locations exist for each channel
if isfield(EEG,'nbchan')
    has_loc = zeros(EEG.nbchan,1);
end

try    
    for i = 1:numel(has_loc)
        has_loc(i) = EEG.chanlocs(i).X;
    end
    
catch ME
    msgboxText =  'Current Source Density error: Some electrodes are missing electrode channel locations. Please check channel locations and try again.';
    title      = 'ERPLAB: Missing channel locations';
    errorfound(msgboxText, title);
    return
end


% check CSD tool in path
csd_path = which('MapMontage');
if numel(csd_path) == 0
    msgboxText =  'Current Source Density error: Do you have the Jürgen Kayser CSD toolbox in your path?';
    title      = 'ERPLAB: CSD path problems?';
    errorfound(msgboxText, title);
    return
        
end


% check not already CSD data
if isfield(EEG,'datatype')
    if strcmp(EEG.datatype,'CSD') == 1
        msgboxText =  'This dataset is already CSD data';
        title      = 'ERPLAB: CSD dataset problems?';
        errorfound(msgboxText, title);
        return
    end
end

% write chanlocs to file
EEG=pop_chanedit(EEG, 'eval','','save','loc_eeglab_for_CSD.ced');



% make cell of channel names
elec_n = EEG.nbchan;

chan_label = cell(elec_n,1);
for i = 1:elec_n
    chan_label{i} = EEG.chanlocs(i).labels;
end

% convert this eeglab ced file to a csd location file
ConvertLocations('loc_eeglab_for_CSD.ced', 'loc_csd.csd', chan_label )


% make CSD toolbox montage
M = ExtractMontage('loc_csd.csd',chan_label);

% visually check montage
MapMontage(M)

%%%
% Run CSD GUI to get 3 CSD parameters
[csd_param] = csd_generate;

% check if user cancelled GUI. If so, end here.
if numel(csd_param) == 0
    display('User selected cancel')
    return
end
    

% generate transform matrices
[csd_G, csd_H] = GetGH(M, csd_param(1));
% optionally, set a more flexible m-constant of 2 or 3 with 2nd arg, but
% default of 4 is recommended


% clean up CSD fields from EEG structure
EEG = rmfield(EEG,'chaninfo');

if isERP
    
    % For ERP bindata -> CSD
    csd_data = zeros(size(EEG.bindata));
    for i = 1:EEG.nbin
        csd_data(:,:,i) = current_source_density(EEG.bindata(:,:,i),csd_G, csd_H,csd_param(2),csd_param(3));
    end
    
    EEG = rmfield(EEG,'nbchan');
    EEG = orderfields(EEG);
    
else
    
    % For EEG data -> CSD
    csd_data = zeros(size(EEG.data));
    
    if numel(EEG.epoch) == 0
        len_epoch_dim = 1;
    else
        len_epoch_dim = numel(EEG.epoch);
    end
    
    for i = 1:len_epoch_dim
        csd_data(:,:,i) = current_source_density(EEG.data(:,:,i),csd_G, csd_H,csd_param(2),csd_param(3));
    end
    
end


% Write the history with a SEM note
EEG = erphistory(EEG,[],'% converted dataset to Current Source Density datatype',1);
EEG.datatype = 'CSD';


% save new csd dataset
if savepref == 1
    if isERP
        EEG.bindata = csd_data;
        pop_savemyerp(EEG,'erpname',[EEG.erpname '_CSD'],'filename',[EEG.erpname '_CSD.set'],'gui','erplab','overwriteatmenu','no')
        
        erpcom = 'pop_currentsourcedensity(ERP)';
        
    else
        EEG.data = csd_data;
        % If called from ERPLAB GUI, will save EEG from there
        
        erpcom = 'pop_currentsourcedensity(EEG)';
    end
end



%eeglab redraw

