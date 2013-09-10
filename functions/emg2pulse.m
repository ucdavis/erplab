% UNDER CONSTRUCTION...
%
%
% Author: Javier Lopez-Calderon

function  d = emg2pulse(ch1, fs)

d=[];

if nargin<1
        help emg2pulse
        return
end
if nargin>3
        error('ERPLAB says: emg2pulse() works until 3 inputs')
end
if size(ch1,1)>1 && size(ch1,2)>1
        error('ERPLAB says: emg2pulse() works with vector inputs')
end

d = abs(ch1);
[b,a] = butter(2,30/fs);

for t=1:size(d,3)
        d(d(1,:,t)<6) = 0;
        d(1,:,t) = filtfilt(b,a, d(1,:,t));
        d(1,:,t) = 100*d(1,:,t);
        m = mean(d(1,:,t));
        sdd = std(d(1,:,t));
        th = m+2*sdd;
        d(d(1,:,t)<th) = 0;
        d(d(1,:,t)>=th) = 100;
end