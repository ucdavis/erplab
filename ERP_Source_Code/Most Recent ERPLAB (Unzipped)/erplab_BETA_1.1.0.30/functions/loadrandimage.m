function [IconData IconCMap]= loadrandimage(varargin)
% Author: Javier
% 2008
%
% Just for fun!

%rand('twister', sum(100*clock));
l = nargin;
nunrand = round((l-1)*rand)+1;
[IconData IconCMap]= imread(varargin{nunrand});
return
