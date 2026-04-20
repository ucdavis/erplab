%%We first calculated the mean and SD for each electrode at each time point
% across training trials. The data for training and test were separately
% normalized by subtracting the mean and then dividing the SD

% Author: Guanghui ZHANG && Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2025




function [trnD_nor,tstD_nor] = f_create_train_test_normalization (data_all_singletrials,blockNum,nElectrodes,nBins,Numofblock,time_point)

trnD_nor = [];
tstD_nor =[];
train_nor_mean = [];
train_nor_std = [];
for Numofchan = 1:nElectrodes
    train_nor_data11 = [];
    for Numofbins = 1:nBins
        trian_Data_single = [];
        trian_Index = setdiff(1:blockNum(Numofbins),Numofblock);

        for Numoftrian = 1:numel(trian_Index)
            data_all_singletrials_intst=   data_all_singletrials{Numofbins,trian_Index(Numoftrian)};
            trian_Data_single(Numoftrian,:,:) =  squeeze(data_all_singletrials_intst(:,time_point,:));
            % trian_Data_single(Numoftrian,:,:,:) =  squeeze(data_all_singletrials_intst);
        end
        train_nor_data = squeeze(trian_Data_single(:,Numofchan,:,:));
        train_nor_data11 = [train_nor_data11;reshape(train_nor_data,numel(train_nor_data),1)];
    end
    train_nor_mean(Numofchan,1) = mean(train_nor_data11,1);%%mean across trials at each time point at each electrode site for training data across conditions
    train_nor_std(Numofchan,1) = std(train_nor_data11,0,1);%%SD across trials at each time point at each electrode site across conditions
end


for Numofchan = 1:nElectrodes%%loop for electrodes
    trnD_nor_bin = [];
    for Numofbins = 1:nBins%%loop for bins
        trian_Data_single = [];
        test_Data_single = [];
        trian_Index = setdiff(1:blockNum(Numofbins),Numofblock);
        for Numoftrian = 1:numel(trian_Index)
            data_all_singletrials_intst = data_all_singletrials{Numofbins,trian_Index(Numoftrian)};
            % trian_Data_single(Numoftrian,:,:) =  squeeze(data_all_singletrials_intst(:,t,:));
            trian_Data_single(Numoftrian,:,:,:) =  squeeze(data_all_singletrials_intst);
        end
        data_all_singletrials_intst_test =  data_all_singletrials{Numofbins,Numofblock};%% single trial data for test
        test_Data_single =  squeeze(data_all_singletrials_intst_test(:,time_point,:));


        train_nor_data = squeeze(trian_Data_single(:,Numofchan,:,:));
        train_nor_data12 = squeeze(trian_Data_single(:,Numofchan,time_point,:));

        %%normalization for trainng
        train_nor_data222 = (train_nor_data12-train_nor_mean(Numofchan,1) )./train_nor_std(Numofchan,1);
        index_left = (Numofbins-1)*numel(trian_Index)+1;
        index_right = (Numofbins)*numel(trian_Index);
        trnD_nor_bin = [trnD_nor_bin;mean(train_nor_data222,2)];
        %%normalization for test
        test_nor_data222 = (test_Data_single(Numofchan,:)-train_nor_mean(Numofchan,1))./train_nor_std(Numofchan,1);
        tstD_nor(Numofbins,Numofchan) = mean(test_nor_data222,2);
    end
    trnD_nor(:,Numofchan) = trnD_nor_bin;
end

end



