% Author: Javier LC
function valogic = isrepeated(array)

valogic = 0;
a = unique(array);

if length(a)~=length(array)
        valogic = 1;
end
