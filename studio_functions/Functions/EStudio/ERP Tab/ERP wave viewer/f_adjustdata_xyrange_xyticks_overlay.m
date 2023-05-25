%%This function is to compute the specific time-range for xth columns for
%%Overlay setting




function [bindatadjust,Xtimerangeadjust,Xticksadjust,TimeAdjustOut,XtimerangeadjustALL] = f_adjustdata_xyrange_xyticks_overlay(bindatatrs,Xtimerange,qXticks,offset,NumColumns,PosIndexs,stepXP)

bindatadjust = [];
Xtimerangeadjust = [];
Xticksadjust = [];
TimeAdjustOut = 0;
XtimerangeadjustALL = [];
if isempty(stepXP)
    stepXP = ceil(numel(Xtimerange)*0.4);
end

timebin = unique(diff(Xtimerange));


try
    ColumnNums = PosIndexs(2);
catch
    ColumnNums  =1;
end

%%if the number of columns is 1
if NumColumns==1 || ColumnNums==1
    bindatadjust = bindatatrs+offset(PosIndexs(1));
    Xtimerangeadjust = Xtimerange;
    Xticksadjust = qXticks;
    TimeAdjustOut = 0;
    XtimerangeadjustALL =Xtimerange ;
    return;
end

Xtimerangeadjust = NaN(1,numel(Xtimerange));
%%if the number of columns is larger than 1.
if ColumnNums>1
    timeRangeAll(1,:) = Xtimerange;
    Xticksadjustall(1,:)=qXticks;
    TimeAdjustALL(1) = 0;
    for ii = 2:NumColumns
        TimeAdjust = (numel(Xtimerange)-stepXP)*timebin;%%need to modify this based on the percentage of Overlay
        Xtimerangeadjust1 = timeRangeAll(ii-1,:)+TimeAdjust;
        timeRangeAll(ii,:) = Xtimerangeadjust1;
        Xticksadjustall(ii,:)=Xticksadjustall(ii-1,:)+TimeAdjust;
        TimeAdjustALL(ii) = Xticksadjustall(ii,1)-Xticksadjustall(1,1);
    end
    bindatadjust = bindatatrs+offset(PosIndexs(1));
    Xtimerangeadjust = timeRangeAll(ColumnNums,:);
    Xticksadjust = Xticksadjustall(ColumnNums,:);
    TimeAdjustOut = TimeAdjustALL(ColumnNums);
    XtimerangeadjustALL = timeRangeAll;
end
end