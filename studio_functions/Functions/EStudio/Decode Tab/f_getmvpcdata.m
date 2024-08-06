


function [bindata,bindataerror,timesnew] = f_getmvpcdata(ALLMVPC,MVPCArray,qtimeRange)
bindata = [];
bindataerror = [];
timesnew = [];
if nargin<1
    help f_getmvpcdata
    return
end
if nargin<2
    MVPCArray = [1:length(ALLMVPC)];
end
if nargin<3
    MVPC = ALLMVPC(MVPCArray(1));
    qtimeRange = [MVPC.times(1),MVPC.times(end)];
end

if isempty(MVPCArray) || any(MVPCArray(:)>length(ALLMVPC)) || any(MVPCArray(:)<1)
    MVPCArray  = length(ALLMVPC);
end

[serror, msgwrng] = f_checkmvpc(ALLMVPC,MVPCArray);
if serror==1
    MVPCArray  = length(ALLMVPC);
end

MVPC = ALLMVPC(MVPCArray(1));
if isempty(qtimeRange) || numel(qtimeRange)~=2 || (qtimeRange(1)==qtimeRange(2)) || qtimeRange(1)>MVPC.times(end) || qtimeRange(2)<MVPC.times(1)
    qtimeRange = [MVPC.times(1),MVPC.times(end)];
end

time_bin = 1000/MVPC.srate;
if qtimeRange(1)>=MVPC.times(1) && qtimeRange(2)<=MVPC.times(end)
    [xxx, latsamp, latdiffms] = closest(MVPC.times, qtimeRange);
    timesnew =  MVPC.times(latsamp(1):latsamp(2));
    qtimeRangenew = qtimeRange;
elseif qtimeRange(1)<MVPC.times(1) && qtimeRange(2)<=MVPC.times(end)
    [xxx, latsamp, latdiffms] = closest(MVPC.times, qtimeRange);
    timesnew = MVPC.times(latsamp(1):latsamp(2));
    for ii = 1:1000000
        Xtimerange_first = timesnew(1)-time_bin;
        if qtimeRange(1) <= Xtimerange_first
            timesnew = [Xtimerange_first,timesnew];
        else
            break;
        end
    end
    qtimeRangenew = [MVPC.times(1),qtimeRange(2)];
    
elseif   qtimeRange(1)<MVPC.times(1) && qtimeRange(2)>MVPC.times(end)
    timesnew = MVPC.times;
    for ii = 1:1000000% loop for the left edge
        Xtimerange_first = timesnew(1)-time_bin;
        if qtimeRange(1) <= Xtimerange_first
            timesnew = [Xtimerange_first,timesnew];
        else
            break;
        end
    end
    for ii = 1:1000000%Loop for the right edge
        Xtimerange_last = timesnew(end)+time_bin;
        if qtimeRange(2) >= Xtimerange_last
            timesnew = [timesnew,Xtimerange_last];
        else
            break;
        end
    end
    qtimeRangenew = [MVPC.times(1),MVPC.times(end)];
    
elseif (qtimeRange(1)>= MVPC.times(1)) && (qtimeRange(2)> MVPC.times(end))%% case 3
    
    [xxx, latsamp, latdiffms] = closest(MVPC.times, [qtimeRange(1) MVPC.times(end)]);
    timesnew = MVPC.times(latsamp(1):latsamp(2));
    for ii = 1:1000000%Loop for the right edge
        Xtimerange_last = timesnew(end)+time_bin;
        if qtimeRange(2) >= Xtimerange_last
            timesnew = [timesnew,Xtimerange_last];
        else
            break;
        end
    end
    qtimeRangenew = [qtimeRange(1),MVPC.times(end)];
end

bindata = nan(numel(timesnew),numel(MVPCArray));
bindataerror = nan(numel(timesnew),numel(MVPCArray));

[xxx, latsamp, latdiffms] = closest(timesnew, qtimeRangenew);

for Numofmvpc = 1:numel(MVPCArray)
    MVPC1 = ALLMVPC(MVPCArray(Numofmvpc));
    [xxx, latsamp1, ~] = closest(MVPC1.times, qtimeRangenew);
    if numel(latsamp1)==numel(latsamp)
        bindata(latsamp(1):latsamp(2),Numofmvpc)  = ALLMVPC(MVPCArray(Numofmvpc)).average_score(latsamp1(1):latsamp1(2));
        if ~isempty(MVPC1.stderror)
            try
                bindataerror(latsamp(1):latsamp(2),Numofmvpc) = ALLMVPC(MVPCArray(Numofmvpc)).stderror(latsamp1(1):latsamp1(2));
            catch
                
            end
        end
    end
end

end