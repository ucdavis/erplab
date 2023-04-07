


function [Exist,ExistIndex] = f_existvector(TotalVector,SmallVector)

Exist = 0;%%1.There exists some elements in SmallVector which donot belong to TotalVector.
ExistIndex = [];

if nargin < 1
    help f_existvector
    return;
end


if nargin < 2
    msgboxText = ['There should be two inputs'];
    error('prog:input', ['f_existvector() says: ' msgboxText]);
end

if ~isnumeric(TotalVector)
    msgboxText = ['The first input must be number(s)'];
    error('prog:input', ['f_existvector() says: ' msgboxText]);
end


if ~isnumeric(SmallVector)
    msgboxText = ['The second input must be number(s)'];
    error('prog:input', ['f_existvector() says: ' msgboxText]);
end

if numel(TotalVector) < numel(SmallVector)
    msgboxText = ['Numbers of the second input should be smaller than for the first one.'];
    error('prog:input', ['f_existvector() says: ' msgboxText]);
end


%%----------organize the inputs into column vectors------------------------
TotalVector = reshape(TotalVector,[],1);
SmallVector = reshape(SmallVector,[],1);
count = 0;
for kk = 1:numel(SmallVector)
    [x_check,y_check] = find(SmallVector(kk,1) == TotalVector);
    if isempty(y_check)
        Exist = 1;
        count = count+1;
        ExistIndex(count) =kk;
    end
end
return;

