function [LabelStrout] = f_MarkLabels_gridlocations_ERP_Waveiwer(Gridata,usedIndex,AllabelArray)
% usedIndex = zeros(length(AllabelArray),1);
% for jj = 1:length(AllabelArray)
%     for ii = 1:length(LabelStr)
%         if strcmp(AllabelArray{jj},LabelStr{ii})
%             usedIndex(jj) = 1;
%         end
%     end
% end

LabelsFlag = [0 0 0];
for ii = 1:length(AllabelArray)
    code1 = 0;
    %     for jj = 1:size(Gridata,1)
    %         for kk = 1:size(Gridata,2)
    %             if strcmp(AllabelArray{ii},Gridata{jj,kk})
    %                 code1 = code1+1;
    %             end
    %         end
    %     end
    [C,IA]=ismember(Gridata,AllabelArray{ii});
    C  = reshape(C,size(C,1)*size(C,2),1);
    Xpos =find(C==1);
    if isempty(Xpos)
        code1 = 0;
    else
        code1 = numel(Xpos);
    end
    if usedIndex(ii)==1%% the item will be marked with * if the labels was selected
        Numstr = strcat('*',num2str(ii));
    else
        Numstr = strcat(num2str(ii));
    end
    
    if code1 ==0
        LabelStrout{ii} =  ['<HTML><FONT color="blue">',Numstr,'.',32,AllabelArray{ii},'</Font></html>'];
        LabelsFlag(1) = 1;
    elseif code1 >1
        LabelStrout{ii} =  ['<HTML><FONT color="red">',Numstr,'.',32,AllabelArray{ii},'</Font></html>'];
        LabelsFlag(3) = 1;
    else
        LabelStrout{ii} =  ['<HTML><FONT color="black">',Numstr,'.',32,AllabelArray{ii},'</Font></html>'];
        LabelsFlag(2) = 1;
    end
end
