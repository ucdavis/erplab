


function diffStr = f_setdiffstr(StrLarger,StrSmall)


diffStr = '';
S_index = [];
count = 0;
for Numofstr = 1:length(StrSmall)
    [C,IA] = ismember_bc2(StrSmall{Numofstr},StrLarger);
    if C==1 &&  IA<=length(StrLarger)
        count = count+1;
        S_index(count) = IA;
    end
end


diff_index = setdiff([1:length(StrLarger)],S_index);
if ~isempty(diff_index)
    
    for ii = 1:numel(diff_index)
        diffStr{ii} = StrLarger{diff_index(ii)};
    end
end
end