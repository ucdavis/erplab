% clear data quality measures on serious change to dataset, avoiding invalid data
% part of the ERPLAB Toolbox
% axs Apr 2019
%
function [ERP] = clear_dq(ERP)

dq = ERP.dataquality;

dq_n = numel(dq);

for i=1:dq_n
    
    if isfield(dq(i),'keep_data')
        if dq(i).keep_data == 0
            dq(i).data = [];
        end
    else
        dq(i).data = [];
    end
    
    
    %dq(i).valid = 0;
    
    if isfield(dq(i),'comments') == 0
        dq(i).comments = 'Measure cleared - dataset transformation rendered the data no longer valid;';
    else
        dq(i).comments = [dq(i).comments ' Measure cleared - dataset transformation rendered the data no longer valid'];
    end
    
end

disp('Data quality measures cleared - dataset transformation rendered these measures stale')

ERP.dataquality = dq;
