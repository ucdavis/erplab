% function [G,H] = GetGH (M, m)
% 
% Modification of GetCSD.m to obtain the G- and H-matrices, which are 
% invariant for a given EEG montage, which are then used as input with
% the EEG/ERP data to the CSD.m routine
%
% Usage: [G,H] = GetGH (M, m)
% 
% Input parameter:
%         M = a MatLab structure for an EEG montage consisting of <n> sites
%             as returned by the function ExtractEEGMontage.m;
%             M consists of:  <n> cell string array 'lab'
%                             <n> double 'theta'
%                             <n> double 'phi'
%                             <n * 2> double matrix 'xy'
%                             ('xy' values are not used in this function)
%         m = positive integer constant that affects spherical spline flexibility
%             values of m can be:    2 - most flexible interpolation
%                                    3 - medium flexibility
%                                    4 - more rigid splines (default)
%                                5..10 - increasingly rigid splines  
%
% Output parameters:
%         G = G electrodes-by-electrodes matrix (SP spline)
%         H = H electrodes-by-electrodes matrix (CSD spline)
%
% Notes: 1) GetGH.m differs from GetCSD.m by removing the first three lines
%           in the GetCSD.m code because spherical angles are defined through
%           <M>, and by removing the last line handling the EEG/ERP data
%        2) In contrast to GetCSD.m, the <m> constant may be optionally
%           specified as an input parameter (default: m = 4)
%        3) Using the G and H matrices with data not conforming to the original
%           EEG montage will not produce valid CSDs
%        4) The orientation of Theta and Phi is defined in the appendix of
%           Kayser J, Tenke CE, Clin Neurophysiol 2006;117(2):348-368), and
%           is not identical to other spherical notifications using the
%           same spherical angle names (e.g., as in EEGlab)
%
% -----------------------------------------------------------------------
% GetCSD - Compute Current Source Density (CSD) estimates using the spherical spline
%          surface Laplacian algorithm suggested by Perrin et al. (1989, 1990)
%
% (published in appendix of Kayser J, Tenke CE, Clin Neurophysiol 2006;117(2):348-368)
%
% Usage: [CE] = GetCSD(EEGmont, ERPdata);
%
% Implementation of algorithms described by Perrin, Pernier, Bertrand, and
% Echallier in Electroenceph Clin Neurophysiol 1989;72(2):184-187, and 
% Corrigenda EEG 02274 in Electroenceph Clin Neurophysiol 1990;76:565.
% 
% Input parameters:
%   EEGmont = name of EEG montage spherical coordinates file in ASCII format,
%             with rows consisting of six columns: electrode label, two 
%             spherical angles (theta, phi), and Cartesian coordinates x,y,z
%   ERPdata = name of ERP data file in ASCII format stored as 
%             electrodes-by-samples (rows-by-columns) matrix
%
% Output parameter:
%        CE = CSD estimates as electrodes-by-samples matrix
%
% Copyright (C) 2003 by Jürgen Kayser (Email: kayserj@pi.cpmc.columbia.edu)
% GNU General Public License (http://www.gnu.org/licenses/gpl.txt)
% Updated: $Date: 2005/02/11 14:00:00 $ $Author: jk $
% -----------------------------------------------------------------------
% Modified: $Date: 2009/05/12 19:12:00 $ $Author: jk $
%        - eliminate <ERPdata> input argument and direct use of CSD.m
%        - return G and H transformation matrices
%    Added: $Date: 2009/05/14 17:20:00 $ $Author: jk $
%        - input argument <m> to specify constant for spline flexibility
%    Added: $Date: 2009/05/22 11:28:00 $ $Author: jk $
%        - progress bar to indicate status of iteration 
%  Changed: $Date: 2010/04/11 19:46:00 $ $Author: jk $
%        - allow more rigid values for spline constant m [2..10] 
%
function [G,H] = GetGH (M, m)
ThetaRad = (2 * pi * M.theta) / 360;     % convert Theta and Phi to radians ...
PhiRad = (2 * pi * M.phi) / 360;         % ... and Cartesian coordinates ...
[X,Y,Z] = sph2cart(ThetaRad,PhiRad,1.0); % ... for optimal resolution
nElec = length(M.lab);                   % determine size of EEG montage
EF(nElec,nElec) = 0;                     % initialize interelectrode matrix ...
for i = 1:nElec; for j = 1:nElec;        % ... and compute all cosine distances
  EF(i,j) = 1 - ( ( (X(i) - X(j))^2 + ...
    (Y(i) - Y(j))^2 + (Z(i) - Z(j))^2 ) / 2 );
end; end;

% axs edit, via Johnathan Folstein, rescaling if outside range -1:1
if max(EF(:)) > 1
    EF = EF ./ max(EF(:));
    disp('Warning - EF is outside -1:1. Rescaling to fix.');
end
if min(EF(:)) < -1
    EF = EF ./ abs(min(EF(:)));
    disp('Warning - EF is outside -1:1. Rescaling to fix.');
end


if nargin < 2
   m = 4;                                % set m constant default
end
if ~ismember(m,[2:10])                    % verify m constant
%   disp(sprintf('Error: Invalid m = %d [use 2, 3, or 4]',[m]));
   disp(sprintf('Error: Invalid m = %d [use an integer between 2 and 10]',[m]));
   G = NaN;
   H = NaN;
   return
end
disp(sprintf('Spline flexibility:  m = %d',[m])); 
N = 50;                                  % set N iterations
G(nElec,nElec) = 0; H(nElec,nElec) = 0;  % claim memory for G- and H-matrices
fprintf('%d iterations for %d sites [',N,nElec); % intialize progress bar
for i = 1:nElec; for j = 1:nElec;
  P = zeros(N);                          % compute Legendre polynomial
  for n = 1:N;
    p = legendre(n,EF(i,j));
    P(n) = p(1);
  end;
  g = 0.0; h = 0.0;                      % compute h- and g-functions
  if j == 1; fprintf('*'); end;          % show progress
  for n = 1:N;
    g = g + ( (( 2.0*n+1.0) * P(n)) / ((n*n+n)^m    ) );
    h = h + ( ((-2.0*n-1.0) * P(n)) / ((n*n+n)^(m-1)) );
  end;
  G(i,j) =  g / 4.0 / pi;                % finalize cell of G-matrix
  H(i,j) = -h / 4.0 / pi;                % finalize cell of H-matrix
end; end;
disp(']');                               % finalize progress bar
