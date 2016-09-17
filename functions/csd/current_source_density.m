% CSD - Current Source Density (CSD) transformation based on spherical spline
%       surface Laplacian as suggested by Perrin et al. (1989, 1990)
%
% (published in appendix of Kayser J, Tenke CE, Clin Neurophysiol 2006;117(2):348-368)
%
% Usage: [X, Y] = CSD(Data, G, H, lambda, head);
%
% Implementation of algorithms described by Perrin, Pernier, Bertrand, and
% Echallier in Electroenceph Clin Neurophysiol 1989;72(2):184-187, and 
% Corrigenda EEG 02274 in Electroenceph Clin Neurophysiol 1990;76:565.
% 
% Input parameters:
%   Data = surface potential electrodes-by-samples matrix
%      G = g-function electrodes-by-electrodes matrix
%      H = h-function electrodes-by-electrodes matrix
% lambda = smoothing constant lambda (default = 1.0e-5)
%   head = head radius (default = no value for unit sphere [µV/m²])
%          specify a value [cm] to rescale CSD data to smaller units [µV/cm²]
%          (e.g., use 10.0 to scale to more realistic head size)
%
% Output parameter:
%      X = current source density (CSD) transform electrodes-by-samples matrix
%      Y = spherical spline surface potential (SP) interpolation electrodes-
%          by-samples matrix (only if requested)
%
% Copyright (C) 2003 by Jürgen Kayser (Email: kayserj@pi.cpmc.columbia.edu)
% GNU General Public License (http://www.gnu.org/licenses/gpl.txt)
% Updated: $Date: 2005/02/11 14:00:00 $ $Author: jk $
%        - code compression and comments 
% Updated: $Date: 2007/02/07 11:30:00 $ $Author: jk $
%        - recommented rescaling (unit sphere [µV/m²] to realistic head size [µV/cm²])
%   Fixed: $Date: 2009/05/16 11:55:00 $ $Author: jk $
%        - memory claim for output matrices used inappropriate G and H dimensions
%   Added: $Date: 2009/05/21 10:52:00 $ $Author: jk $
%        - error checking of input matrix dimensions
%
function [X, Y] = current_source_density(Data, G, H, lambda, head)
[nElec,nPnts] = size(Data);            % get data matrix dimensions
if ~(size(G,1) == size(G,2)) | ...     % matrix dimension error checking: 
   ~(size(H,1) == size(H,2)) | ...     % G and H matrix must be nElec-by-nElec
   ~(size(G,1) == nElec) | ...         
   ~(size(H,1) == nElec)
   X = NaN; Y = NaN;                   % default to invalid output 
   help CSD
   disp(sprintf(strcat('*** Error: G (%d-by-%d) and H (%d-by-%d) matrix', ...
                       ' dimensions must match rows (%d) of data matrix'), ...
                       size(G),size(H),nElec));
   return 
end   
mu = mean(Data);                       % get grand mean
Z = (Data - repmat(mu,nElec,1));       % compute average reference
Y = Data;  X = Y;                      % claim memory for output matrices
if nargin < 5; head = 1.0; end;        % initialize scaling variable [µV/m²]
head = head * head;                    % or rescale data to head sphere [µV/cm²]
if nargin < 4; lambda = 1.0e-5; end;   % initialize smoothing constant
for e = 1:size(G,1);                   % add smoothing constant to diagonale
  G(e,e) = G(e,e) + lambda; 
end; 
Gi = inv(G);                           % compute G inverse
for i = 1:size(Gi,1);                  % compute sums for each row
  TC(i) = sum(Gi(i,:));
end;
sgi = sum(TC);                         % compute sum total
for p = 1:nPnts
  Cp = Gi * Z(:,p);                    % compute preliminary C vector
  c0 = sum(Cp) / sgi;                  % common constant across electrodes
  C = Cp - (c0 * TC');                 % compute final C vector
  for e = 1:nElec;                     % compute all CSDs ...
    X(e,p) = sum(C .* H(e,:)') / head; % ... and scale to head size
  end;
  if nargout > 1; for e = 1:nElec;     % if requested ...
    Y(e,p) = c0 + sum(C .* G(e,:)');   % ... compute all SPs
  end; end;
end;