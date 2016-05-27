% ismember_bc2 - ismember backward compatible with Matlab versions prior to 2013a

function [C,IA] = ismember_bc2(A,B,varargin)
% errorFlag = false;
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
        %disp('legacy')
        [C,IA] = ismember(A,B,varargin{:},'legacy');
        %if true
        %        [C2,IA2] = ismember(A,B,varargin{:});
        %        if (~isequal(C, C2) || ~isequal(IA, IA2))
        %                warning('Warn:BckwrdcompTest','ismember_bc2: Backward compatibility issue with call to ismember function');
        %        end
        %end
else
        %disp('old')
        [C,IA] = ismember(A,B,varargin{:});
end