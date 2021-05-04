% Write data quality out to Matlab Command Window
% axs June 2019, ERPLAB
function dataquality_measure = print_data_quality(ERP,dq_subfield)

%% Check and populate missing args
if exist('ERP','var') == 0 || isempty(ERP)
    ERP = evalin('base','ERP');
end
if exist('dq_subfield','var') == 0 || isempty(dq_subfield)
    dq_measures = numel(ERP.dataquality);
    if dq_measures == 1
        dq_subfield = 1;
    else
        for i=1:dq_measures
            dq_names{i} = ERP.dataquality(i).type;
        end
        [s,v] = listdlg('Name','Which DQ','PromptString','Pick measure to write:','SelectionMode','single','ListString',dq_names);
        if s>0
            dq_subfield = s;
        else
            disp('User cancelled Data Quality write')
            return
        end
    end
end

dataquality_measure = ERP.dataquality(dq_subfield).data;

if strcmpi('Point-wise SEM', ERP.dataquality(dq_subfield).type)
    dataquality_measure = ERP.binerror;
end


%% Prepare data with labels
try
times = ERP.dataquality(dq_subfield).times
for b = 1:ERP.nbin
    bin_txt = [ERP.dataquality(dq_subfield).type ' Bin ' num2str(b) ':']
    
    dq_bin_data_elecXtw = ERP.dataquality(dq_subfield).data(:,:,1)
end

catch
% To CW
disp(dataquality_measure)
end


out_txt = ['Data Quality measure ' ERP.dataquality(dq_subfield).type ' written to dataquality_measure variable. Size: ' num2str(size(dataquality_measure))];
disp(out_txt)
dataquality_measure = ERP.dataquality(dq_subfield).data;


