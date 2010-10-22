% Usage
%
% >> d = mahaleeg(ch1,ch2);
% >> d = mahaleeg(ch)
%
% d = mahaleeg(ch1,ch2) computes the Mahalanobis distance (in squared units) of each sample of the ch1
% from the sample in the ch2.
%
% d = mahaleeg(ch) computes the Mahalanobis distance applied to itself to find outliers.
%
% The Mahalanobis distance is a multivariate measure of the separation of a data set from a point in
% space. It is the criterion minimized in linear discriminant analysis.
%
% This function was made to work with ERPLAB channel operations
%
% See mahal.m
%
%
% Author: Javier Lopez-Calderon

function  d = mahaleeg(ch1,ch2, nsweep)

d=[];

if nargin<1
        help mahaleeg
        return
end
if nargin>3
        error('ERPLAB: error, mahaleeg works until 3 inputs')
end
if nargin<3
        nsweep=1;
end
if nargin<2
        ch2=ch1;
end
if size(ch1,1)>1 && size(ch1,2)>1
        error('ERPLAB: error, mahaleeg works with vector inputs')
end
if size(ch2,1)>1 && size(ch2,2)>1
        error('ERPLAB: error, mahaleeg works with vector inputs')
end

d = zeros(size(ch1));

for t=1:size(ch1,3)
        d(1,:,t) = mahal(ch1(1,:,t)',ch2(1,:,t)');
        for i=2:nsweep
                d(1,:,t) = mahal(d(1,:,t),d(1,:,t));
        end
end

