function [ERP conti] = changebinlabel(ERP, b1, label)

conti = 1;

try
        ERP.bindescr{b1} = label;
catch
        conti = 0;
end
