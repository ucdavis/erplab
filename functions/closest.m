% Returns the closest value from a list
%
% Syntax
%
%  c      = closest(a,b); returns the closest value c in a for each value in b
% [c,i]   = closest(a,b); returns the index i of the closest value in a for each value in b
% [c,i,d] = closest(a,b); returns the difference d of the closest value in a for each value in b
%
% Example
%
% [cvalue, cindex cdiff] = closest([-8 2 5.5 12 45 20 100],[-15 2.3 10 50])
% 
% cvalue =
% 
%     -8     2    12    45
% 
% 
% cindex =
% 
%      1     2     4     5
% 
% 
% cdiff =
% 
%     7.0000   -0.3000    2.0000   -5.0000
%
%
% Author: Javier Lopez-Calderon
% Davis, CA, March, 2011
function [cvalue, cindex, cdiff] = closest(data, target)

error(nargchk(1,2,nargin))
error(nargoutchk(0,3,nargout))
if nargin<2; target = [];end
ntarget = length(target);
[cvalue, cindex, cdiff]   = deal(zeros(1, ntarget));
for i=1:ntarget
      if isnan(target(i)) || isinf(target(i))
            [cvalue(i), cindex(i), cdiff(i)] = deal(NaN);
      else
            [cx, cindex(i)] = min(abs(data-target(i)));
            cvalue(i) = data(cindex(i));
            cdiff(i)  = cvalue(i)-target(i); % data minus target
      end
end