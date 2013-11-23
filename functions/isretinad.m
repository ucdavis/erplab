function v = isretinad
v = 0;
set(0,'Units','pixels') 
thisscreen = get(0, 'ScreenSize');
if thisscreen(3)==1440 && thisscreen(4)>=878 && thisscreen(4)<1000 && ismac
    v = 1;
elseif thisscreen(3)>=1440 && thisscreen(4)>=1000  && ismac
    v = 2;
end