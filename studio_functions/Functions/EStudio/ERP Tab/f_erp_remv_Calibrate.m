% This function is to remove calibration when importing ERPSS files


%
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022

function ALLERP = f_erp_remv_Calibrate(ALLERP, ERP_index)

if nargin<1
    help f_erp_remv_Calibrate
    return
end
if nargin<2
    nfile = [1:length(ALLERP)];
end
nfile = ERP_index;

for i=1:numel(nfile)
    ERP = ALLERP(nfile(i));
    try%Remove the bin with Caliration GH 2022
        binNum = length(ERP.bindescr);
        count = 0;
        Calib_ind = [];
        for jj = 1:binNum
            if  strcmp(ERP.bindescr{jj},'Calibration')
                count = count+1;
                Calib_ind(count) = jj;
            end
        end
        bin_remd = setdiff([1:binNum],Calib_ind);
        Bindescr =ERP.bindescr;
        for kk = 1:numel(bin_remd)
            Bindescr_keep{kk} = Bindescr{bin_remd(kk)};
        end
        ERP.bindescr = Bindescr_keep;
        ERP.nbin = numel(bin_remd);
        ERP.bindata = ERP.bindata(:,:,bin_remd);
    catch
        ERP =ERP;
    end
    
    ALLERP(nfile(i)) = ERP;
    clear ERP;
    clear Bindescr_keep;
end


return

