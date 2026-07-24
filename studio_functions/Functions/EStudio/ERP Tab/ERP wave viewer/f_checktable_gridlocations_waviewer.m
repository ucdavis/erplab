function [Dataout, EPStr]= f_checktable_gridlocations_waviewer(Data,LabelStr)
countEp = 0;
EPStr = '';
Dataout = cell(size(Data,1),size(Data,2));

Data = string(Data);
for ii = 1:size(Data,1)
    for jj = 1:size(Data,2)
        count = 0;
        try
            [C,IA] =ismember_bc2(strtrim(char(Data(ii,jj))), string(LabelStr));
        catch
            [C,IA] =ismember_bc2(strtrim(char(Data(ii,jj))), LabelStr);
        end
        if C ==1 && IA ~=0
            Dataout{ii,jj} = char(LabelStr{IA});
            count = count +1;
        else
            Dataout{ii,jj} =   char('');
            count=0;
        end
        
        if count==0
            countEp = countEp+1;
            if ~isempty(Data(ii,jj))
                if countEp==1
                    EPStr = char(Data(ii,jj));
                else
                    EPStr = strcat(EPStr,32,char(Data(ii,jj)));
                end
            end
        end
    end
end
