function [cx, cy] = dotsinacircle(N, xo, yo, r, sep)
cx = NaN(1,N);
cy = NaN(1,N);
d1=1E12;
m=1;
k=1;
while k<1000*N && m<=N
        x = (rand-0.5)*2*r + xo;
        y = (rand-0.5)*2*r + yo;
        
        for j=1:m-1
                d1(j) = ( (x-cx(j))^2 + (y-cy(j))^2 )^0.5;
        end
        
        d2 = ( (x-xo)^2 + (y-yo)^2 )^0.5;
        
        if all(d1>sep) && d2<=r
                cx(m) = x;
                cy(m) = y;
                m     = m+1;
        end
        k = k+1;
end

% 
% figure
% plot(cx, cy, '*')

%
% ang=0:0.01:2*pi; 
% xp=r*cos(ang);
% yp=r*sin(ang);
% plot(x+xp,y+yp);
% end