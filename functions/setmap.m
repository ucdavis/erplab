function setmap(hObj,event) %#ok<INUSD>
% Called when user activates popup menu
val = get(hObj,'Value');
if val ==1
        colormap(jet)
elseif val == 2
        colormap(hsv)
elseif val == 3
        colormap(hot)
elseif val == 4
        colormap(cool)
elseif val == 5
        colormap(gray)
end
