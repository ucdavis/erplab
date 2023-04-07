%%This function is to compute the specific time-range for xth columns for
%%GAP setting




function [bindatadjust,Xtimerangeadjust,Xticksadjust] = f_adjustdata_xyrange_xyticks(bindatatrs,Xtimerange,qXticks,offset,NumColumns,PosIndexs,stepX,fs)

bindatadjust = [];
Xtimerangeadjust = [];
Xticksadjust = [];

if isempty(stepX)
    stepX = ceil(Xtimerange(end)-Xtimerange(1));
end

timebin = 1000/fs;
Timet_step_p = ceil(stepX/(1000/fs));



%%if the number of columns is 1
if NumColumns==1
    bindatadjust = bindatatrs+offset(PosIndexs(1));
    Xtimerangeadjust = Xtimerange;
    Xticksadjust = qXticks;
    return;
end
try
    ColumnNums = PosIndexs(2);
catch
    ColumnNums  =1;
end
RowNums =  PosIndexs(1);
%%if the number of columns is larger than 1.
bindatadjust = bindatatrs+offset(PosIndexs(1));
Xtimerangeadjust = NaN(1,numel(Xtimerange));
TimeAdjust = (ColumnNums-1)*(numel(Xtimerange)+Timet_step_p)*timebin;
Xtimerangeadjust = Xtimerange+TimeAdjust;
Xticksadjust = qXticks+TimeAdjust;
end