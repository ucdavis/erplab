



function FonsizeDefault = f_get_default_fontsize()

if ismac
    % Code to run on Mac platform
    FonsizeDefault = 12;
elseif isunix
    % Code to run on Linux platform
    FonsizeDefault = 9;
elseif ispc
    % Code to run on Windows platform
    FonsizeDefault = 9;
else
    FonsizeDefault = 9;
end

end