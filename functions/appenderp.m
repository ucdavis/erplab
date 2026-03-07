% PURPOSE: subroutine for pop_appenderp
%          appends ERPsets
%
% FORMAT:
%
% [ERP serror] = appenderp(ALLERP,indx, prefixes)
%
% Inputs:
%
% ALLERP      - structure containing more than 1 erpset (ERP structure)
% indx        - erpset indices to append (from ALLERP)
% prefixes    - prefixes to be added to the appended bin names
%
% Output
% 
% ERP         - New ERP having 2 or more appended ERPsets
% serror      - check for error. 0 means no errors; 1 means error(s) found
%
% See also pop_appenderp
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
% Copyright � 2007 The Regents of the University of California
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

function [ERP, serror] = appenderp(ALLERP,indx, prefixes)
ERP = [];
serror = 0;
if nargin<3
      prefixes=[];
end
if nargin<2
      indx=1:length(ALLERP);
end
if nargin<1
      error('ERPLAB says: appenderp.m needs at least 1 input.')
end

erpname   = [];
filename  = [];
filepath  = [];
workfiles = [];
subject   = '';
bindata   = [];
binerror  = [];
nbin      = 0;
accepted  = [];
rejected  = [];
invalid   = [];
arflags   = [];
bindescr  = [];
history   = '';
nerp      = length(indx);

if ischar(prefixes)
        if strcmpi(prefixes, 'erpname')
                prefixes = {''};
                for i=1:nerp 
                        fname = ALLERP(indx(i)).erpname;
                        %if isempty(fname)
                        %        fname = ALLERP(indx(i)).erpname;
                        %end
                        prefixes{i} = fname;
                end
        end
end

% Validation of sets to append
% We don't want to try to combine binerror info if some is missing
keep_binerror = 0;
binerror_works_here = zeros(1,nerp);
for i=1:nerp
    data_dims = size(ALLERP(indx(i)).bindata);
    error_dims = size(ALLERP(indx(i)).binerror);
    if isequal(data_dims,error_dims)
        binerror_works_here(i) = 1;
    end
end
if any(binerror_works_here == 0)
    keep_binerror = 0;
else
    keep_binerror = 1;
end


for i=1:nerp      
      workfiles = [workfiles ALLERP(indx(i)).workfiles];
      subject   = [subject ALLERP(indx(i)).subject];
      
      if i==1
            nchan      = ALLERP(indx(i)).nchan;
            pnts       = ALLERP(indx(i)).pnts;
            srate      = ALLERP(indx(i)).srate;
            xmin       = ALLERP(indx(i)).xmin;
            xmax       = ALLERP(indx(i)).xmax;
            times      = ALLERP(indx(i)).times;
            chanlocs   = ALLERP(indx(i)).chanlocs;
            ref        = ALLERP(indx(i)).ref;
            bindata    = ALLERP(indx(i)).bindata;
            binerror   = ALLERP(indx(i)).binerror;
            datatype   = ALLERP(indx(i)).datatype;
      else
            sra = size(bindata,1);
            srb = size(ALLERP(indx(i)).bindata,1);
            sca = size(bindata,2);
            scb = size(ALLERP(indx(i)).bindata,2);
            
            if sra~=srb
                  serror=2; % channel size is diff
                  return
            end
            if sca~=scb
                  serror=3; % channel size is diff
                  return
            end
            
            bindata  = cat(3, bindata, ALLERP(indx(i)).bindata);
            
            if keep_binerror
                binerror = cat(3, binerror, ALLERP(indx(i)).binerror);
            end
      end
      
      nbin     = nbin +  ALLERP(indx(i)).nbin;
      accepted = [accepted ALLERP(indx(i)).ntrials.accepted];
      rejected = [rejected ALLERP(indx(i)).ntrials.rejected];
      invalid  = [invalid ALLERP(indx(i)).ntrials.invalid];
      arflags  = cat(1,arflags, ALLERP(indx(i)).ntrials.arflags);
      
      if isempty(prefixes)
            bindescr = [bindescr ALLERP(indx(i)).bindescr];
      else    
            auxdescr  = char(ALLERP(indx(i)).bindescr');
            auxprefix = repmat([prefixes{i} ' : '], ALLERP(indx(i)).nbin,1);
            newdescr  = cellstr(cat(2,auxprefix,auxdescr))';
            bindescr  = [bindescr newdescr];
      end
end

if keep_binerror == 0
    binerror = [];
    disp('Error data in appended datasets not consistent. ERP.binerror will be empty');
end


%% Append Data Quality measures (if present and compatible across all input sets)
% added 3/6/26 -kpw
dq_ok = nerp > 0;

% check all sets have a non-empty dataquality field
for i = 1:nerp
    dq_i = [];
    if isfield(ALLERP(indx(i)), 'dataquality')
        dq_i = ALLERP(indx(i)).dataquality;
    end
    if isempty(dq_i) || strcmpi(dq_i(1).type, 'empty')
        dq_ok = false;
        break;
    end
end

% verify measure types and time windows match across all sets
if dq_ok && nerp > 1
    ref_dq = ALLERP(indx(1)).dataquality;
    n_dqm  = numel(ref_dq);
    for i = 2:nerp
        cur_dq = ALLERP(indx(i)).dataquality;
        if numel(cur_dq) ~= n_dqm
            dq_ok = false; break;
        end
        for k = 1:n_dqm
            if ~strcmpi(cur_dq(k).type, ref_dq(k).type) || ...
               ~isequal(cur_dq(k).times, ref_dq(k).times)
                dq_ok = false; break;
            end
        end
        if ~dq_ok; break; end
    end
end

% concatenate DQ data along the bin dimension (last dim)
if dq_ok
    ref_dq      = ALLERP(indx(1)).dataquality;
    n_dqm       = numel(ref_dq);
    combined_dq = ref_dq;  % copy structure (types, times, labels, comments) from first set
    try
        for k = 1:n_dqm
            cat_data = ALLERP(indx(1)).dataquality(k).data;
            nd = ndims(cat_data);  % bin dimension is always last (2D or 3D measures)
            for i = 2:nerp
                cat_data = cat(nd, cat_data, ALLERP(indx(i)).dataquality(k).data);
            end
            combined_dq(k).data = cat_data;
        end
    catch ME
        fprintf('Note: Data Quality measures not appended (error during concatenation: %s).\n', ME.message);
        dq_ok = false;
    end
end

if ~dq_ok
    % Warn if at least one set had DQ data (incompatible rather than simply absent)
    any_dq = false;
    for i = 1:nerp
        if isfield(ALLERP(indx(i)), 'dataquality') && ...
           ~isempty(ALLERP(indx(i)).dataquality) && ...
           ~strcmpi(ALLERP(indx(i)).dataquality(1).type, 'empty')
            any_dq = true; break;
        end
    end
    if any_dq
        fprintf('Note: Data Quality measures not appended (missing or incompatible DQ data across ERPsets).\n');
    end
    combined_dq = [];
    combined_dq.type             = 'empty';
    combined_dq.times            = [];
    combined_dq.data             = [];
    combined_dq.time_window_labels = {};
    combined_dq.comments         = [];
end


ERP.erpname    = erpname;
ERP.filename   = filename;
ERP.filepath   = filepath;
ERP.workfiles  = workfiles;
ERP.subject    = subject;
ERP.nchan      = nchan;
ERP.nbin       = nbin;
ERP.pnts       = pnts;
ERP.srate      = srate;
ERP.xmin       = xmin;
ERP.xmax       = xmax;
ERP.times      = times;
ERP.bindata    = bindata;
ERP.binerror   = binerror;
ERP.datatype   = datatype;
ERP.chanlocs   = chanlocs;
ERP.ref        = ref;
ERP.bindescr   = bindescr;
ERP.ntrials.accepted  = accepted;
ERP.ntrials.rejected  = rejected;
ERP.ntrials.invalid   = invalid;
ERP.ntrials.arflags   = arflags;
ERP.history    = history;
ERP.saved      = 'no';
ERP.isfilt     = 0;   % 1= avg was filtered or smoothed
ERP.version    = geterplabversion;
ERP.dataquality = combined_dq;

ERP = old2newerp(ERP);
[ERP, serror] = sorterpstruct(ERP);