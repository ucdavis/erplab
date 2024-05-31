%%This function is to set the default fontsize for ERP wave viewer on different platforms

%Author: Guanghui ZHANG && Steve Luck
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
% 2023


function FonsizeDefault = f_get_default_fontsize()

if ismac
    % Code to run on Mac platform
    FonsizeDefault = 12;
elseif isunix
    % Code to run on Linux platform
    FonsizeDefault = 8.5;
elseif ispc
    % Code to run on Windows platform
    FonsizeDefault = 9;
else
    FonsizeDefault = 9;
end

end