% unique_bc - unique backward compatible with Matlab versions prior to 2013a

function [C,IA,IB] = unique_bc2(A,varargin)
% errorFlag = error_bc;
v = version;
indp = find(v == '.');
v = str2num(v(1:indp(2)-1));
if v > 7.19
        v = floor(v) + rem(v,1)/10;
end
if nargin > 2
        ind = find(ismember(varargin, 'legacy'));
        if ~isempty(ind)
                varargin(ind) = [];
        end
end
if v >= 7.14
        [C,IA,IB] = unique(A,varargin{:},'legacy');
        %if true
        %        [C2,IA2, IB2] = unique(A,varargin{:});
        %        if ~isequal(C, C2) || ~isequal(IA, IA2') || ~isequal(IB, IB2')
        %                warning('Warn:BckwrdcompTest','backward compatibility issue with call to unique function');
        %        end
        %end
else
        [C,IA,IB] = unique(A,varargin{:});
end