% Author:  Javier Lopez-Calderon
% 2009
%
function m = modeone(A)
if iscell(A)        
        while any(cellfun('isclass',A,'cell'))
                A = cat(2,A{:});
        end
        
        n = length(A);
        h = cellfun(@isnumeric,A);
        g = nnz(h);
        
        if g>0 && g~=n % mixed
                error('Elements have to be of same class')
        elseif g>0 && g==n  % only numbers
                A = cell2mat(A);
        end
end
u = unique_bc2(A);
[tf, ind] = ismember_bc2(A, u);
if ind>0
        k = mode(ind);
        m = u(k);
else
        m = NaN;
end
