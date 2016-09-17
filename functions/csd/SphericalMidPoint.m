% SphericalMidPoint - Determine a point on a unit sphere by assuming
%                     equal distance to two spherical points
%
% (published in appendix of Kayser J, Tenke CE, Clin Neurophysiol 2006;117(2):348-368)
%
% Usage: [P] = SphericalPoint( Pl, Pr, Pm, P1, P2, lab);
%
% Implementation of simple linear geometric principles and algorithms
% (e.g., see documentation at http://mathworld.wolfram.com/Plane.html
%                             http://mathworld.wolfram.com/Sphere.html
%                             http://mathworld.wolfram.com/Line.html)
% 
% Input parameters:
%   Pl,Pr,Pm =  point vectors with Cartesian x,y,z coordinates defining
%               a small circle on a unit sphere, with Pl and Pr located  
%               on the x-y plane, and Pm on the y-z plane
%   P1,P2    =  point vectors indicating two locations on the small circle
%   lab      =  electrode label string
%
% Output parameter:
%   P     =  point vector/matrix with Cartesian x,y,z intersection(s)
%
% Copyright (C) 2003 by Jürgen Kayser (Email: kayserj@pi.cpmc.columbia.edu)
% GNU General Public License (http://www.gnu.org/licenses/gpl.txt)
% Updated: $Date: 2005/02/09 14:00:00 $ $Author: jk $
%
function [P] = SphericalPoint( Pl, Pr, Pm, P1, P2, lab);
M = Pl-(Pl-Pr)/2';          % use lateral points to determine their midpoint
d = abs(Pr(1)-Pl(1))/2;     % ...  in x-y plane on y-axis and its distance
V = Pm - M;                 % get vector from midline point Pm and midpoint M
m = sqrt(V(2)^2 + V(3)^2);  % ... (V(1)=0) and determine the vector length m
q = (d^2 - m^2) / 2*m;      % get extension q of vector V towards origin of
r = m + q;                  % ... small circle and compute its radius r
V = V * (m+q)/m;            % extend vector V
O = Pm - V;                 % determine origin O of small circle
M1 = P1 - O;                % translate first point vector to small circle 
M2 = P2 - O;                % translate second point vector to small circle
N = O + (M1-(M1-M2)/2);     % determine mean vector and translate to unit sphere
P = LineWithSphere(N,O);    % get intersection of vector O-N with unit sphere
R = 1.0;                    % set unit sphere radius
for i = 1:size(P,1)         % test whether point P is really on the surface
    s = P(i,1).^2 + ...     % ... of the sphere (s must be zero)
        P(i,2).^2 + ...
        P(i,3).^2 - R.^2;
    disp(sprintf('%5s %8.5f %8.5f %8.5f  (off surface: %20.17f)', ...
         char(lab(:)),P(i,1),P(i,2),P(i,3),s));
end;