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

% check locations exist for each channel
has_loc = zeros(EEG.nbchan,1);
try    
    for i = 1:EEG.nbchan
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

% generate transform matrices
[csd_G, csd_H] = GetGH(M, csd_param(1));
% optionally, set a more flexible m-constant of 2 or 3 with 2nd arg, but
% default of 4 is recommended


csd_data = zeros(size(EEG.data));
for i = 1:numel(EEG.epoch)
    csd_data(:,:,i) = current_source_density(EEG.data(:,:,i),csd_G, csd_H,csd_param(2),csd_param(3));
end

% save new EEG set
EEG2 = EEG;
EEG2.data = csd_data;

EEG2 = pop_saveset( EEG2, 'filename',[EEG.setname '_with_csd.set']);

eeglab redraw

