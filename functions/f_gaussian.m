% Author: Guanghui Zhang & Steve J. Luck & Andrew Stewart
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Mar. 2023 




% 'a' specifies the amplitude
% 'b' specifies the x-coordinate of the center
% 'c' specifies the width
% 'x' is a vector of x inputs



function Sig = f_gaussian(x,a,b,c)
if isempty(a) %%Mean amplitude
    a = 1;
end

if isempty(b)
    b= 0;
end
if isempty(c)
    c = 0.5;
end
Sig =[];
Sig = a*exp(-(((x-b).^2)/(2*c.^2)));
end