function [Dataout, EPStr]= f_checktable_gridlocations_waviewer(Data,LabelStr)
countEp = 0;
EPStr = '';
Dataout = cell(size(Data,1),size(Data,2));

Data = string(Data);
Data=  strrep(Data,'<html><table border=0 width=400 bgcolor=#FFFF00><TR><TD>','');
Data = strrep(Data,'</TD></TR> </table>','');
for ii = 1:size(Data,1)
    for jj = 1:size(Data,2)
        count = 0;
        %         for kk = 1:length(LabelStr)
        %             Data1=  strrep(Data{ii,jj},'<html><table border=0 width=400 bgcolor=#FFFF00><TR><TD>','');
        %             Data1 = strrep(Data1,'</TD></TR> </table>','');
        %             Data{ii,jj} = char(Data1);
        %             if strcmp(strrep(char(LabelStr{kk}),' ',''),strtrim(char(Data{ii,jj})))
        %                 Data{ii,jj} = char(LabelStr{kk});
        %                 count = count +1;
        %             end
        %         end
        
        %         [C,IA] =ismember_bc2(strtrim(char(Data(ii,jj))), strrep(string(LabelStr),' ',''));
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
            if countEp==1
                if isstring(Data(ii,jj))
                    if ~isempty(Data(ii,jj))
                        EPStr = char(Data(ii,jj));
                    end
                elseif isnumeric(Data(ii,jj))
                    if ~isempty(Data(ii,jj))
                        EPStr = num2str(Data(ii,jj));
                    end
                end
            else
                if isstring(Data(ii,jj))
                    if ~isempty(Data(ii,jj))
                        EPStr = strcat(EPStr,32,char(Data(ii,jj)));
                    end
                elseif isnumeric(Data(ii,jj))
                    if ~isempty(Data(ii,jj))
                        EPStr = strcat(EPStr,32,num2str(Data(ii,jj)));
                    end
                end
            end
%             Data{ii,jj} = char('');
        end
    end
end
