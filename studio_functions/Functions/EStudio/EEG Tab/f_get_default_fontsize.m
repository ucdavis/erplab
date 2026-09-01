%%This function is to set the default fontsize for ERP wave viewer on different platforms

%Author: Guanghui ZHANG && Steve Luck
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
% 2023


function FontSizeDefault = f_get_default_fontsize()

if ismac
    % Code to run on Mac platform
    FontSizeDefault = 12;
elseif isunix
    % Code to run on Linux platform
    FontSizeDefault = 8.5;
elseif ispc
    % Code to run on Windows platform
    FontSizeDefault = 9;
else
    FontSizeDefault = 9;
end

end