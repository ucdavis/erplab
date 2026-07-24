function [LabelStrout, LabelColors] = f_MarkLabels_gridlocations_ERP_Waveiwer(Gridata,usedIndex,AllabelArray)
% Builds the plain-text label list and a parallel per-row color (for
% addStyle 'FontColor') shown in ERP_layoutstringGUI's labels table:
%   blue  = unused in the grid
%   red   = used more than once in the grid
%   black = used exactly once in the grid
% '*' prefix marks labels already selected in the main Wave Viewer.

UnusedColor = [0 0 1];
DupColor    = [1 0 0];
UsedColor   = [0 0 0];

LabelStrout = cell(length(AllabelArray),1);
LabelColors = zeros(length(AllabelArray),3);
for ii = 1:length(AllabelArray)
    [C,~] = ismember(Gridata,AllabelArray{ii});
    code1 = nnz(C);

    if usedIndex(ii)==1 %% the item will be marked with * if the labels was selected
        Numstr = strcat('*',num2str(ii));
    else
        Numstr = strcat(num2str(ii));
    end

    LabelStrout{ii,1} = [Numstr,'.',32,AllabelArray{ii}];
    if code1 ==0
        LabelColors(ii,:) = UnusedColor;
    elseif code1 >1
        LabelColors(ii,:) = DupColor;
    else
        LabelColors(ii,:) = UsedColor;
    end
end
