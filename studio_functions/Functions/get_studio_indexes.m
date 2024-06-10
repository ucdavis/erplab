

%Author: Guanghui ZHANG
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Apr. 2024

% ERPLAB Studio





function [EEGsetIndex,EEGchanindex, ERPsetindex, ERPchanindex, ERPbinindex,erpcom]= get_studio_indexes();

erpcom = '';

EEGsetIndex= estudioworkingmemory('EEGArray');
EEGchanindex= estudioworkingmemory('EEG_ChanArray');

ERPsetindex =  estudioworkingmemory('selectederpstudio');
ERPchanindex = estudioworkingmemory('ERP_BinArray');
ERPbinindex = estudioworkingmemory('ERP_ChanArray');

command = sprintf('[EEGsetIndex,EEGchanindex, ERPsetindex, ERPchanindex, ERPbinindex,erpcom]= get_studio_indexes();');

end