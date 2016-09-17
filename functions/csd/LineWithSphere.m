% LineWithSphere - Determine intersection(s) of a line defined by
%                  two points in space with a sphere
%
% (published in appendix of Kayser J, Tenke CE, Clin Neurophysiol 2006;117(2):348-368)
%
% Usage: [P] = LineWithSphere ( P1, P2, Os, r );
%
% Implementation of simple linear geometric principles and algorithms
% (e.g., see documentation at http://mathworld.wolfram.com/Plane.html
%                             http://mathworld.wolfram.com/Sphere.html
%                             http://mathworld.wolfram.com/Line.html)
% 
% Input parameters:
%   P1,P2 =  point vectors with Cartesian x,y,z coordinates
%   Os    =  point vector origin of sphere (default = [0 0 0])
%   r     =  sphere radius (default = 1.0)
%
% Output parameter:
%   P     =  point vector/matrix with Cartesian x,y,z intersection(s)
%
% Copyright (C) 2003 by Jürgen Kayser (Email: kayserj@pi.cpmc.columbia.edu)
% GNU General Public License (http://www.gnu.org/licenses/gpl.txt)
% Updated: $Date: 2005/02/09 14:00:00 $ $Author: jk $
%
function [P] = LineWithSphere ( P1, P2, Os, r );
if nargin < 4;  r = 1.0;     end;    % use unit sphere (radius = 1) by default
if nargin < 3; Os = [0 0 0]; end;    % use natural origin by default
x1 = P1(1); y1 = P1(2); z1 = P1(3);  % x,y,z-coordinates for line point 1
x2 = P2(1); y2 = P2(2); z2 = P2(3);  % x,y,z-coordinates for line point 2
x3 = Os(1); y3 = Os(2); z3 = Os(3);  % x,y,z-coordinates for origin of sphere
a = (x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2;
b = 2 * ( (x2-x1)*(x1-x3) + (y2-y1)*(y1-y3) + (z2-z1)*(z1-z3) );
c = x3^2 + y3^2 + z3^2 + x1^2 + y1^2 + z1^2 - 2 * (x3*x1 + y3*y1 + z3*z1) - r^2;
T = b^2 - 4 * a * c;
if T < 0                             % no intersection
   P = [NaN NaN NaN];
   return
end
if T == 0                            % one intersection
   u = -b / (2*a);
   P(1) = x1 + u * (x2 - x1);
   P(2) = y1 + u * (y2 - y1);
   P(3) = z1 + u * (z2 - z1);
   return
end
u = (-b + sqrt(T)) / (2 * a);        % first intersection
P(1,1) = x1 + u * (x2 - x1);
P(1,2) = y1 + u * (y2 - y1);
P(1,3) = z1 + u * (z2 - z1);
u = (-b - sqrt(T)) / (2 * a);        % second intersection
P(2,1) = x1 + u * (x2 - x1);
P(2,2) = y1 + u * (y2 - y1);
P(2,3) = z1 + u * (z2 - z1);