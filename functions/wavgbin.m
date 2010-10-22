% Usage
% >> waverage = wavgbin(ERP, bop)
%
% For Bin Operations GUI/scripting purposes
%
% Author: Javier
%

function  waverage = wavgbin(ERP, bop)

if nargin<1
        help wavgbin
        return
end
if nargin<2
        error('ERPLAB says: You must specify bin indexes to be averaged!')
end
if ~iserpstruct(ERP)
        error('ERPLAB says: Your data structure is not an ERP structure!')
end
if ischar(bop)
        bop = str2num(char(regexp(bop,'\d+','match')'))';
end

binarray = unique(bop);

if length(binarray)~=length(bop)
        fprintf('\n*** WARNING: Repeated bins were ignored.\n\n')
end
if length(binarray)<2
        error('ERPLAB says: You must specify 2 bin indexes at leat!')
end
if max(binarray)>ERP.nbin
        error('ERPLAB says: Some specified bins do not exist!')
end

wsumerp = 0;

for i=1:length(binarray)
        wsumerp =  wsumerp + ERP.ntrials.accepted(binarray(i))*ERP.bindata(:,:,binarray(i));
end

sumgood = sum(ERP.ntrials.accepted(binarray));

if sumgood>0
        waverage = wsumerp/sumgood;
else
        waverage = wsumerp;
end

