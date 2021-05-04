% add/append a Data Quality struct to an ERPset
% part of the ERPLAB Toolbox
% axs May 2019
%
%
function ERP = add_dq_measure(ERP, DQ_struct, name)

% check input
assert(isstruct(ERP));

% If DQ is currently absent
if isfield(ERP,'dataquality') == 0
    
    ERP.dataquality(1).type = 'empty';
    ERP.dataquality(1).times = [];
    ERP.dataquality(1).data = [];
    ERP.dataquality(1).time_window_labels = {};
    ERP.dataquality(1).comments = [];
end

% with no DQ_struct specified, populate with empty
if exist('DQ_struct','var') == 0 || isempty(DQ_struct)
    DQ_struct.type = 'empty';
    DQ_struct.times = [];
    DQ_struct.data = [];
    DQ_struct.time_window_labels = {};
    DQ_struct.comments = [];
end

if exist('name','var') == 0 || isempty(name)
    name = DQ_struct.type;
end


%


n_existing_dq = length(ERP.dataquality);
was_empty = strcmpi(ERP.dataquality(n_existing_dq).type,'empty');

if was_empty
    dq_slot = n_existing_dq;
else
    dq_slot = n_existing_dq + 1;
end


ERP.dataquality(dq_slot) = DQ_struct;

[ERP, serror] = sorterpstruct(ERP);

if serror
    warning('ERP sorting error in making DQ struct')
end
