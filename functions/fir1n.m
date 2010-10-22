function [b,a,N] = fir1n(N,Wn,varargin)
%FIR1   FIR filter design using the window method.
%   B = FIR1(N,Wn) designs an N'th order lowpass FIR digital filter
%   and returns the filter coefficients in length N+1 vector B.
%   The cut-off frequency Wn must be between 0 < Wn < 1.0, with 1.0 
%   corresponding to half the sample rate.  The filter B is real and
%   has linear phase.  The normalized gain of the filter at Wn is
%   -6 dB.
%
%   B = FIR1(N,Wn,'high') designs an N'th order highpass filter.
%   You can also use B = FIR1(N,Wn,'low') to design a lowpass filter.
%
%   If Wn is a two-element vector, Wn = [W1 W2], FIR1 returns an
%   order N bandpass filter with passband  W1 < W < W2. You can
%   also specify B = FIR1(N,Wn,'bandpass').  If Wn = [W1 W2], 
%   B = FIR1(N,Wn,'stop') will design a bandstop filter.
%
%   If Wn is a multi-element vector, 
%          Wn = [W1 W2 W3 W4 W5 ... WN],
%   FIR1 returns an order N multiband filter with bands
%    0 < W < W1, W1 < W < W2, ..., WN < W < 1.
%   B = FIR1(N,Wn,'DC-1') makes the first band a passband.
%   B = FIR1(N,Wn,'DC-0') makes the first band a stopband.
%
%   B = FIR1(N,Wn,WIN) designs an N-th order FIR filter using 
%   the N+1 length vector WIN to window the impulse response.
%   If empty or omitted, FIR1 uses a Hamming window of length N+1.
%   For a complete list of available windows, see the help for the
%   WINDOW function. KAISER and CHEBWIN can be specified with an 
%   optional trailing argument.  For example, B = FIR1(N,Wn,kaiser(N+1,4)) 
%   uses a Kaiser window with beta=4. B = FIR1(N,Wn,'high',chebwin(N+1,R)) 
%   uses a Chebyshev window with R decibels of relative sidelobe 
%   attenuation.
%
%   For filters with a gain other than zero at Fs/2, e.g., highpass
%   and bandstop filters, N must be even.  Otherwise, N will be
%   incremented by one.  In this case the window length should be
%   specified as N+2.
%   
%   By default, the filter is scaled so the center of the first pass band 
%   has magnitude exactly one after windowing. Use a trailing 'noscale' 
%   argument to prevent this scaling, e.g. B = FIR1(N,Wn,'noscale'), 
%   B = FIR1(N,Wn,'high','noscale'), B = FIR1(N,Wn,wind,'noscale').  You
%   can also specify the scaling explicitly, e.g. FIR1(N,Wn,'scale'), etc.
%
%   See also KAISERORD, FIRCLS1, FIR2, FIRLS, FIRCLS, CFIRPM,
%            FIRPM, FREQZ, FILTER, WINDOW.

%   FIR1 is an M-file implementation of program 5.2 in the IEEE
%   Programs for Digital Signal Processing tape. 

%   Author(s): L. Shure
%              L. Shure, 4-5-90, revised
%              T. Krauss, 3-5-96, revised
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.15.4.5 $  $Date: 2007/12/14 15:04:36 $

%   Reference(s):
%     [1] "Programs for Digital Signal Processing", IEEE Press
%         John Wiley & Sons, 1979, pg. 5.2-1.

error(nargchk(2,6,nargin,'struct'));

if nargin > 2 && strcmpi(varargin{end}, 'h')
    varargin(end) = [];
    hilbert = true;
else
    hilbert = false;
end

% Parse optional input arguments
[Ftype,Wind,SCALING,msg] = parseoptargs(Wn,varargin{:});
if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

% Compute the frequency vector
[nbands,ff,Ftype,msg] = desiredfreq(Wn,Ftype);
if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

% Compute the magnitude vector
[aa,First_Band] = desiredmag(Ftype,nbands);

% Check for appropriate filter order, increase when necessary
[N,msg1,msg2] = firchk(N,ff(end),aa,hilbert);
error(msg1);
%warning(msg2);

% Work with filter length (= order + 1)
L = N + 1;

% Check for valid window, or assign default if empty
[Wind,msg] = chkwindow(Wind,L);
if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

% Compute unwindowed impulse response
if hilbert
    hh = firls(L-1,ff,aa,'h');
else
    hh = firls(L-1,ff,aa);
end

% Window impulse response to get the filter
b = hh.*Wind(:)'; 
a = 1;

if SCALING,   
    % Scale so that passband is approx 1
    b = scalefilter(b,First_Band,ff,L);   
end

%-------------------------------------------------------------------------
function [Ftype,Wind,SCALING,msg] = parseoptargs(Wn,varargin)
%PARSEOPTARGS   Parse optional input arguments.

% Up to 3 optional input arguments, always in this order:
%   1 - Filter type flag, can be 'low','high','bandpass','stop','DC-0','DC-1'
%   2 - Window vector
%   3 - 'noscale' flag

% Initialize output args.
SCALING = [];

[Ftype,Wind,Scale] = assignoptargs(Wn,varargin{:});

[Ftype,Wind,Scale,msg] = validateargs(Wn,Ftype,Wind,Scale);
if ~isempty(msg),
    return
end

switch lower(Scale),
case 'noscale';
    SCALING = 0;
case 'scale';
    SCALING = 1;
end

%--------------------------------------------------------------------------
function [Ftype,Wind,Scale] = assignoptargs(Wn,varargin)
%ASSIGNOPTARGS  Assign optional input arguments to the appropriate variables.

% default optional parameter values:
Wind = [];
Scale = 'scale';
Ftype = defaultftype(Wn);


switch length(varargin)
case 1
    if ischar(varargin{1}) && (length(varargin{1})>0),
        s = upper(varargin{1});
        switch upper(s)
        case {'SCALE','NOSCALE'}
            Scale = s;
        otherwise
            Ftype = s;
        end
    else
        Wind = varargin{1};
    end
case 2
    if ischar(varargin{1})
        Ftype = varargin{1};
    else
        Wind = varargin{1};
    end
    if ischar(varargin{2})
        Scale = varargin{2};
    else
        Wind = varargin{2};
    end
case 3
    Ftype = varargin{1};
    Wind = varargin{2};
    Scale = varargin{3};
end

%--------------------------------------------------------------------------
function [Ftype,Wind,Scale,msg] = validateargs(Wn,Ftype,Wind,Scale)
%VALIDATEARGS  Test if arguments are valid.

msg = '';

% Assign a default Ftype when an empty is given. Backwards compatibility
if isempty(Ftype),
    Ftype = defaultftype(Wn);
end


Ftypeopts = {'LOW','HIGH','BANDPASS','STOP','DC-0','DC-1'};
Scaleopts = {'NOSCALE','SCALE'};


indx = find(strncmpi(Ftype, Ftypeopts, length(Ftype)));
if isempty(indx),
    msg = 'Unrecognized or ambiguous filter type specified.';
    return
else
    Ftype = Ftypeopts{indx};
end

scaleindx = find(strncmpi(Scale, Scaleopts, length(Scale)));
if isempty(scaleindx),
    msg = 'Scaling option must be ''noscale'' or ''scale''.';
    return
else
    Scale = Scaleopts{scaleindx};
end

if ~any(size(Wind) <= 1),
    msg = 'The window specified must be a vector';
    return
else
    Wind = Wind(:).'; % Make it a row vector
end

%--------------------------------------------------------------------------
function [nbands,ff,Ftype,msg] = desiredfreq(Wn,Ftype)
%DESIREDFREQ  Compute the vector of frequencies to pass to FIRLS.
%
%   Inputs:
%           Wn    - vector of cutoff frequencies.
%           Ftype - string with desired response ('low','high',...)
%
%   Outputs:
%           nbands - number of frequency bands.
%           ff     - vector of frequencies to pass to FIRLS.
%           Ftype  - converted filter type (if it's necessary to convert)

% Initialize output args.
nbands = [];
ff     = [];
msg    = '';


if  any( Wn<0 | Wn>1 ),
   msg = 'Frequencies must fall in range between 0 and 1.';
   return
end
if  any(diff(Wn)<0),
   msg = 'Frequencies must be increasing';
   return
end

Wn = Wn(:)';

nbands = length(Wn) + 1;

if (nbands > 2) && strcmpi(Ftype,'bandpass'),
    Ftype = 'DC-0';  % make sure default 3 band filter is bandpass
end

ff = [0,Wn(1:nbands-1); Wn(1:nbands-1),1];

ff = ff(:);

%-------------------------------------------------------------------------
function [aa,First_Band] = desiredmag(Ftype,nbands)
%DESIREDMAG  Compute the magnitude vector to pass to FIRLS.

First_Band = isempty(findstr('DC-0',Ftype)) && isempty(findstr('HIGH',Ftype));
mags = rem( First_Band + (0:nbands-1), 2);
aa = [mags(:)'; mags(:)'];

aa = aa(:);
%--------------------------------------------------------------------------
function [Wind,msg] = chkwindow(Wind,L)
%CHKWINDOW   Check if specified window is valid, assign default if empty.

msg = '';

if isempty(Wind),
   % Replace the following with the default window of your choice.
   Wind = hamming(L);
end
    
if length(Wind) ~= L
   msg = 'The window length must be the same as the filter length.';
end
%
% to use Kaiser window, beta must be supplied
% att = 60; % dB of attenuation desired in sidelobe
% beta = 0.1102*(att-8.7);
% wind = kaiser(L,beta);

%---------------------------------------------------------------------------
function b = scalefilter(b,First_Band,ff,L)
%SCALEFILTER   Scale fitler to have passband approx. equal to one.

if First_Band
    b = b / sum(b);  % unity gain at DC
else
    if ff(4)==1
        % unity gain at Fs/2
        f0 = 1;
    else
        % unity gain at center of first passband
        f0 = mean(ff(3:4));
    end
    b = b / abs( exp(-j*2*pi*(0:L-1)*(f0/2))*(b.') );
end

%----------------------------------------------------------------------------
function Ftype = defaultftype(Wn)
%DEFAULTFTYPE  Assign default filter type depending on number of bands.

if length(Wn) == 1,
    Ftype = 'low';
elseif length(Wn) == 2,
    Ftype = 'bandpass';
elseif length(Wn) >= 3,
    Ftype = 'dc-0';
end
