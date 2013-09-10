% - This function is part of ERPLAB Toolbox -
%

function ind = beh_scripts_good_cells(mycell)
% Find good cells

if ~iscell(mycell)
        mycell = {mycell};
end

ind = cellfun('isempty', mycell);

% Good cells
ind = (ind == 0);

% Convert ind to row vector
ind = ind(:)';