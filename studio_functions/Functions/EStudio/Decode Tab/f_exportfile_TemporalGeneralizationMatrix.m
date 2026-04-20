% PURPOSE  : Plot/export temporal generalization matrix from MVPC data

% See also: pop_plotempgenerMatrix



% *** This function is part of ERPLAB Toolbox ***
% Author: Guanghui Zhang
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2026


function f_exportfile_TemporalGeneralizationMatrix(ALLMVPC,MVPCArray,time_ind,fileNames,tp,decimalNum,time,timeunit)

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

    if ~isfield(MVPC,'TGM') || isempty(MVPC.TGM)%%GH Dec. 2025;
        msgboxText =  'pop_plotempgenerMatrix() error: cannot work an empty dataset for temporal generalization matrix!!!';
        title1      = 'ERPLAB';
        errorfound(msgboxText, title1);
        return
    end
    cf_scores = MVPC.TGM;


    idx = time_ind(1):time_ind(2);
    cf_scores = cf_scores(idx,idx);
    if time==1
        TGM = zeros(size(cf_scores,1) + 1, size(cf_scores,2)+1);
        TGM(2:end,2:end) = cf_scores;
        if strcmpi(timeunit,'milliseconds')
            TGM(1,2:end) = MVPC.times(idx);
            TGM(2:end,1) = MVPC.times(idx);
        else
            TGM(1,2:end) = MVPC.times(idx)/1000;
            TGM(2:end,1) = MVPC.times(idx)/1000;
        end
    else
        TGM = cf_scores;
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
        Cnew = TGM;
        formatSpec2 = '';
        for Numofcolumns = 1:size(Cnew,2)-1
            formatSpec2 =[formatSpec2,'%s\t',32];
        end
        formatSpec2 = [formatSpec2,'%s\n'];
        for Numofrow = 1:size(Cnew,1)
            data = [];
            for Numofcolumn = 1:size(Cnew,2)
                data{1,Numofcolumn} = sprintf(['%.',num2str(decimalNum),'f'],Cnew(Numofrow,Numofcolumn));
            end
            if time==1 && Numofrow==1
                data{1,1} ='Time';
            end
            fprintf(fileID,formatSpec2,data{1,:});
        end
        fprintf(fileID,'%s\n',' ');%%empty
        fprintf(fileID,'%s\n\n\n','');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%---------------Save the confusin matrix to .xls file-----------------
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%xls file
    if ~strcmpi(ext,'.txt')
        TitleNames = ['DecodingUnit:',MVPC.DecodingUnit,'; DecodingMethod:',MVPC.DecodingMethod,'; equalTrials:',MVPC.equalTrials];
        Cnew = TGM;
        % sheet_label_T = table(columName2);
        sheetname = char(MVPC.mvpcname);
        if length(sheetname)>31
            sheetname = sheetname(1:31);
        end
        for rowss = 1:size(Cnew,1)
            for columnss = 1:size(Cnew,2)
                Cnewstr{rowss,columnss} = sprintf(['%.',num2str(decimalNum),'f'],Cnew(rowss,columnss));
            end
        end
        if time==1
            Cnewstr{1,1} = TitleNames;
        end
        xls_d = table(Cnewstr);
        writetable(xls_d,fileNames,'Sheet',Numofmvpc,'Range','A1','WriteVariableNames',false,'Sheet',sheetname,"AutoFitWidth",false);  % write data
    end

end
if strcmpi(ext,'.txt')
    fclose(fileID);
end
try
    disp(['A new file for Temporal Generalization Matrix was created at <a href="matlab: open(''' fileNames ''')">' fileNames '</a>'])
catch
end
