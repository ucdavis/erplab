% DEPRECATED...
% 
% Usage
% data = derivaeeg(data, fs, order)
%
% Javier Lopez-Calderon

function data = derivaeeg(data, fs, order)

if nargin<1
        help derivaeeg
        return
end
if nargin<3
        order = 1;  % first time-derivative
end
if nargin<2
        msgboxText =  'Error: Sample rate (fs) is undefined';
        tittle = 'ERPLAB: derivaeeg()';
        errorfound(msgboxText, tittle);
        return
end

Ts = (1/fs)*1000; % in msec
ntrials = size(data,3);

for r=1:order
        for i=1:ntrials
                data(1,:,i) = [0 diff(data(1,:,i))/Ts];
        end
end