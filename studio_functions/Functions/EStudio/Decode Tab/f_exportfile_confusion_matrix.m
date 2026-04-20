
function f_exportfile_confusion_matrix(ALLMVPC,MVPCArray,meas,time_ind,fileNames,avg_win,tp,decimalNum)

[~, ~, ext] = fileparts(fileNames) ;

if strcmpi(ext,'.xls')
    ext = '.xls';
elseif strcmpi(ext,'.xlsx')
    ext = '.xlsx';
else
    ext = '.txt';
end


for Numofmvpc = 1:numel(MVPCArray)
    %% plot
    MVPC = ALLMVPC(MVPCArray(Numofmvpc));
    cf_scores = MVPC.confusions.scores;
    cf_labels = MVPC.confusions.labels;
    cf_strings = convertCharsToStrings(cf_labels);
    if strcmpi(meas,'timepoint')
        if numel(time_ind) == 1
            cf_scores = cf_scores(:,:,time_ind);
            Npts = 1;
        else
            %multiple plots at 1 time point
            cf_scores = cf_scores(:,:,time_ind);
            Npts = numel(time_ind);
        end
    elseif strcmpi(meas,'average')
        idx = time_ind(1):time_ind(2);
        cf_scores = cf_scores(:,:,idx);
        cf_scores = squeeze(mean(cf_scores,3));
        Npts = 1;
        avg_win = 1;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%---------------Save the confusin matrix to .txt file-----------------
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if strcmpi(ext,'.txt')
        if Numofmvpc==1
            fileID = fopen(fileNames,'w+');
        end
        fprintf(fileID,'%s\n','*');
        fprintf(fileID,'%s\n','**');
        if strcmpi(MVPC.DecodingMethod,'SVM') ||  strcmpi(MVPC.DecodingMethod,'LDA')
            columName1{1,1} = ['MVPC Name:',32,MVPC.mvpcname,'; DecodingUnit:',MVPC.DecodingUnit,'; DecodingMethod:',MVPC.DecodingMethod,'; equalTrials:',MVPC.equalTrials];
        else
            columName1{1,1} = ['MVPC Name:',32,MVPC.mvpcname,'; DecodingMethod:',MVPC.DecodingMethod,'; equalTrials:',MVPC.equalTrials];
        end
        fprintf(fileID,'%s\n\n',columName1{1,:});

        for pnt = 1:Npts%%
            if strcmpi(MVPC.DecodingMethod,'SVM') ||  strcmpi(MVPC.DecodingMethod,'LDA')
                if avg_win == 1
                    TitleNames = [ num2str(tp(1)),'ms-',num2str(tp(2)), 'ms (Average Decoding Accuracy)'];
                else
                    TitleNames = ['@ ', num2str(tp(pnt)), ' ms (Average Decoding Accuracy)'];
                end
            else
                if avg_win == 1
                    TitleNames = [ num2str(tp(1)),'ms-',num2str(tp(2)), 'ms (Average Distance)'];
                else
                    TitleNames = ['@ ', num2str(tp(pnt)), ' ms (Average Distance)'];
                end
            end

            C = cf_scores(:,:,pnt);
            %swap rows and columns of matrix as per
            Cnew = permute(C,[2 1]);
            Cnew = flipud(Cnew);
            cf_string2 = fliplr(cf_strings); % flips row labels
            columName2{1,1} = TitleNames;
            formatSpec2 = '';
            for Numofcolumns = 1:size(Cnew,2)
                columName2{1,Numofcolumns+1} = cf_strings{Numofcolumns};
                formatSpec2 =[formatSpec2,'%s\t',32];
            end
            formatSpec2 = [formatSpec2,'%s\n'];
            fprintf(fileID,formatSpec2,columName2{1,:});
            for Numofrow = 1:size(Cnew,1)
                data = [];
                data{1,1} = cf_string2{Numofrow};
                for Numofcolumn = 1:size(Cnew,2)
                    data{1,Numofcolumn+1} = sprintf(['%.',num2str(decimalNum),'f'],Cnew(Numofrow,Numofcolumn));
                end
                fprintf(fileID,formatSpec2,data{1,:});
            end
            fprintf(fileID,'%s\n',' ');%%empty
        end
        fprintf(fileID,'%s\n\n\n','');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%---------------Save the confusin matrix to .xls file-----------------
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%xls file
    if ~strcmpi(ext,'.txt')
        for pnt = 1:Npts%%
            data = [];
            binname =  '';
            if strcmpi(MVPC.DecodingMethod,'SVM') ||  strcmpi(MVPC.DecodingMethod,'LDA')
                if avg_win == 1
                    TitleNames = [ num2str(tp(1)),'ms-',num2str(tp(2)), 'ms (Average Decoding Accuracy)','; DecodingUnit:',MVPC.DecodingUnit,'; DecodingMethod:',MVPC.DecodingMethod,'; equalTrials:',MVPC.equalTrials];
                else
                    TitleNames = ['@ ', num2str(tp(pnt)), ' ms (Average Decoding Accuracy)','; DecodingUnit:',MVPC.DecodingUnit,'; DecodingMethod:',MVPC.DecodingMethod,'; equalTrials:',MVPC.equalTrials];
                end
            else
                if avg_win == 1
                    TitleNames = [ num2str(tp(1)),'ms-',num2str(tp(2)), 'ms (Average Distance)','; DecodingMethod:',MVPC.DecodingMethod,'; equalTrials:',MVPC.equalTrials];
                else
                    TitleNames = ['@ ', num2str(tp(pnt)), ' ms (Average Distance)','; DecodingMethod:',MVPC.DecodingMethod,'; equalTrials:',MVPC.equalTrials];
                end
            end

            C = cf_scores(:,:,pnt);
            %swap rows and columns of matrix as per
            Cnew = permute(C,[2 1]);
            Cnew = flipud(Cnew);
            cf_string2 = fliplr(cf_strings); % flips row labels
            columName2{1,1} = TitleNames;

            for Numofcolumns = 1:size(Cnew,2)
                columName2{1,Numofcolumns+1} = cf_strings{Numofcolumns};
            end

            sheet_label_T = table(columName2);
            sheetname = char(MVPC.mvpcname);
            if length(sheetname)>31
                sheetname = sheetname(1:31);
            end
            rowNum = size(Cnew,1);
            for rowss = 1:size(Cnew,1)
                for columnss = 1:size(Cnew,2)
                    Cnewstr{rowss,columnss} = sprintf(['%.',num2str(decimalNum),'f'],Cnew(rowss,columnss));
                end
            end

            startrows = 1+rowNum*(pnt-1)+(pnt-1)*2;
            writetable(sheet_label_T,fileNames,'Sheet',Numofmvpc,'Range',['A',num2str(startrows)],'WriteVariableNames',false,'Sheet',sheetname,"AutoFitWidth",false);
            xls_d = table(cf_string2',Cnewstr);
            writetable(xls_d,fileNames,'Sheet',Numofmvpc,'Range',['A',num2str(startrows+1)],'WriteVariableNames',false,'Sheet',sheetname,"AutoFitWidth",false);  % write data
        end
    end



end
if strcmpi(ext,'.txt')
    fclose(fileID);
end
try
    disp(['A new file for confusion matrix was created at <a href="matlab: open(''' fileNames ''')">' fileNames '</a>'])
catch
end
