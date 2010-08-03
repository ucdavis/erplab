function [n,msg1,msg2] = firchk(n,Fend,a,exception)
%FIRCHK   Check if specified filter order is valid.
%   FIRCHK(N,Fend,A) checks if the specified order N is valid given the
%   final frequency point Fend and the desired magnitude response vector A.
%   Type 2 linear phase FIR filters (symmetric, odd order) must have a
%   desired magnitude response vector that ends in zero if Fend = 1.  This
%   is because type 2 filters necessarily have a zero at w = pi.
%
%   If the order is not valid, a warning is given and the order
%   of the filter is incremented by one.
%
%   If A is a scalar (as when called from fircls1), A = 0 is
%   interpreted as lowpass and A = 1 is interpreted as highpass.
%
%   FIRCHK(N,Fend,A,EXCEPTION) will not warn or increase the order
%   if EXCEPTION = 1.  Examples of EXCEPTIONS are type 4 filters
%   (such as differentiators or hilbert transformers) or non-linear
%   phase filters (such as minimum and maximum phase filters).

%   Author : R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.5 $  $Date: 2007/12/14 15:15:06 $

error(nargchk(3,4,nargin,'struct'));

if nargin == 3,
    exception = false;
end

msg1 = '';
msg2 = '';
oddord = false; % Flag, initially we assume even order

if isempty(n) || length(n) > 1 || ~isnumeric(n) || ~isreal(n) || n~=round(n) || n<=0,
    msg1 = 'Filter order must be a real, positive integer.';
    return
end

if rem(n,2) == 1,
    oddord = true; % Overwrite flag
end
 
if (a(end) ~= 0) && Fend == 1 && oddord && ~exception,
    str = ['Odd order symmetric FIR filters must have a gain of zero \n'...
     'at the Nyquist frequency. The order is being increased by one.'];
    msg2 = sprintf(str);
    n = n+1;
end
    

