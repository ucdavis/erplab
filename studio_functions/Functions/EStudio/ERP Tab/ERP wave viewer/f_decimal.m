

function [yticksLabel, msgboxText]= f_decimal(yticksLabel,ytick_precision)

msgboxText = '';

if nargin<1
    help f_decimal;
    return;
end

if isnumeric(yticksLabel)
  yticksLabel = num2str(yticksLabel);  
end

if nargin<2
  ytick_precision=0;  
end

yticksLabel = char(yticksLabel);

if isempty(str2num(yticksLabel))
    yticksLabel = '';
else
    if ~isempty(str2num(yticksLabel)) && numel((str2num(yticksLabel)))==1
        yticksnumbel = str2num(yticksLabel);
        yticksLabel = sprintf(['%.',num2str(ytick_precision),'f'],yticksnumbel(1));
    else
        yticksnumbel = str2num(yticksLabel);
        yticksLabel = sprintf(['%.',num2str(ytick_precision),'f'],yticksnumbel(1));
        for Numofnum = 1:numel(yticksnumbel)-1
            yticksLabel = [yticksLabel,32,sprintf(['%.',num2str(ytick_precision),'f'],yticksnumbel(Numofnum+1))];
        end
    end
end


end