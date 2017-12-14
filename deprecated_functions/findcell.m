% DEPRECATED...
%
%

function [out] = findcell(cellarray, cellval)

matlab_v = version('-release');
matlab_v = str2double(matlab_v(1:4));

if matlab_v > 2012
    narginchk(2,2)
else
    error(nargchk(2,2,nargin));
end


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