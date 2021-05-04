% PURPOSE  :  Creates the Data Quality ERPset substructure, populates
%
% FORMAT  :
%
% ERP = make_data_quality_ERP( ERP , parameters )
%
% INPUTS  :
%
% ERP       input ERP dataset
%
% OUTPUTS  :
%
% ERP       output ERP dataset (with Data Quality substructure)
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Andrew X Stewart
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% ERPLAB Toolbox
% Copyright © 2018 The Regents of the University of California
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

function [ERP, erpcom] = make_data_quality_ERP(ERP, DQ_spec_struct, silent_overwrite)
erpcom = '';


% check input
assert(isstruct(ERP));
assert(isfield(ERP,'bindata'))

if exist('silent_overwrite','var') == 0
    silent_overwrite = 0;
end

if exist('DQ_spec_struct','var') == 0 || isempty(DQ_spec_struct)
    DQ_spec_struct.type = 'empty';
    DQ_spec_struct.times = [];
    DQ_spec_struct.time_window_labels = {};
    DQ_spec_struct.data = [];
    DQ_spec_struct.comments = [];
end

if isfield(DQ_spec_struct,'time_window_labels') == 0
    DQ_spec_struct.time_window_labels = [];
end

if isfield(DQ_spec_struct,'comments') == 0
    DQ_spec_struct.comments = [];
end

% Check about overwriting DataQuality
if isfield(ERP,'dataquality')
    if silent_overwrite == 0
        disp('Data quality structure already exists')
        ovw = questdlg('Data quality structure already exists. Ok to overwrite?','Data quality structure already exists');
        
        if strcmpi(ovw,'Yes')
            % No prob - can continue
        else
            % If overwrite is not desired, quit func here
            disp('Data quality structure already exists - quitting make DQ')
            return
        end
    end
end
        
if isfield(ERP,'dataquality')
    existing_dq_measures = numel(ERP.dataquality);
else
    existing_dq_measures = 0;
end

% if empty, rewrite that one
if existing_dq_measures == 1
    if strcmpi(ERP.dataquality(existing_dq_measures).type,'empty')
        existing_dq_measures = 0;
    end
end

next_slot = existing_dq_measures + 1;

ERP.dataquality(next_slot).type = DQ_spec_struct.type;
ERP.dataquality(next_slot).times = DQ_spec_struct.times;
ERP.dataquality(next_slot).time_window_labels = DQ_spec_struct.time_window_labels;
ERP.dataquality(next_slot).data = DQ_spec_struct.data;
ERP.dataquality(next_slot).comments = DQ_spec_struct.comments;

[ERP, serror] = sorterpstruct(ERP);

if serror
    warning('ERP sorting error in making DQ struct')
end
