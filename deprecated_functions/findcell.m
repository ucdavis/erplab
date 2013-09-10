% DEPRECATED...
%
%

function [out] = findcell(cellarray, cellval)
error(nargchk(2,2,nargin));
if ~iscell(cellarray)
        error('Requires cell array as inputs.');
end
if isnumeric(cellval)
        target = num2str(cellval);
else
        target = char(cellval);
end
idx = strfind(cellarray, target);
out = [];
k   = 1;
for i=1:length(idx)
        if cell2mat(idx(i))
                out(k) = i; %#ok<AGROW>
                k = k + 1;
        end
end