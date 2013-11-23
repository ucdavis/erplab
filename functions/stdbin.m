% UNDER construction...
%
%
%
% Usage
% >> waverage = stdbin(ERP, bop)
%
% For Bin Operations GUI/scripting purposes
%
% Author: Javier
%

function  standard = stdbin(ERP, bop)

if nargin<1
        help stdbin
        return
end
if nargin<2
        error('ERPLAB says: You must specify bin indexes to be processed!')
end
if ~iserpstruct(ERP)
        error('ERPLAB says: Your data structure is not an ERP structure!')
end
if ischar(bop)
        bop = str2num(char(regexp(bop,'\d+','match')'))';
end
binarray = unique_bc2(bop);
if length(binarray)~=length(bop)
        fprintf('\n*** WARNING: Repeated bins were ignored.\n\n')
end
if length(binarray)<2
        error('ERPLAB says: You must specify 2 bin indexes at leat!')
end
if max(binarray)>ERP.nbin
        error('ERPLAB says: Some specified bins do not exist!')
end
datavg   = ERP.bindata(:,:,binarray);
standard = std(datavg, 0, 3);

