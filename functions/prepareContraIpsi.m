% UNDER CONSTRUCTION
%
% Author: Javier Lopez-Calderon

function [ERP conti] = prepareContraIpsi(ERP, Lch, Rch, Zch)






% 
% 
% conti = 1;
% 
% nargin
% 
% if nargin~=3 && nargin~=5
%         error('ERPLAB says: missing inputs')
% end
% 
% if nargin==3
%         ch1=1:ERP.nchan;
%         ch2=1:ERP.nchan;
% end
% 
% if isempty(ch1) && isempty(ch2)
%         ch1=1:ERP.nchan;
%         ch2=1:ERP.nchan;
% end
% 
% if length(ch1)~=length(ch2)
%         error('ERPLAB says:  channel arrays to swap do not have the same size.')
% end
% 
% aux = ERP.bindata(ch1,:,b1);
% ERP.bindata(ch1,:,b1) = ERP.bindata(ch2,:,b2);
% ERP.bindata(ch2,:,b2) = aux;
