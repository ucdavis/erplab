% Author:  Javier Lopez-Calderon
% 2009
%
function v = vogue(A)

B.x = struct([]);
v   = [];
if iscell(A)
        
        while any(cellfun('isclass',A,'cell'))
                A = cat(2,A{:});
        end
        
        n = length(A);
        h = cellfun(@isnumeric,A);
        g = nnz(h);
        
        if g>0 && g~=n % mixed
                %error('Elements have to be of same class')
                B(1).x = [A{h}];  % cell num
                B(2).x = A(~h); % cell str
        elseif g>0 && g==n  % only cell numbers
                B.x = cell2mat(A);
        else
                B.x = A;
        end
else
        B.x = A;
end

f1 = 0;

for i=1: length(B)
        u = unique(B(i).x);
        [tf ind] = ismember(B(i).x, u);
        
        if ind>0
                [k f2]= mode(ind);
                m = u(k);
        else
                m = NaN;
                f2= 0;
        end
        if f2>=f1
                v = m;
                f1=f2;
        end
end
