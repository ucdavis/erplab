% Signal Processing Toolbox check
% axs Nov 2020
function SigProcT_here = SignalProcessingToolboxCheck

% Get Toolbox list from ver
tbxs = ver;
[a, tbxs_n] = size(tbxs);
tbx_cell = cell(1,tbxs_n);
tbx_cell = {tbxs.Name};

SigProcT_here = any(ismember(tbx_cell,'Signal Processing Toolbox'));

if SigProcT_here == 0
    % if the Signal Processing Toolbox is not found
    warning_text = 'ERROR: You currently do not have the Signal Processing Toolbox installed.';
    warning_text2= 'This is required for many ERPLAB functions, especially filters. Please contact your system administration or MATLAB to install "Signal Processing Toolbox" to your MATLAB version';
    warning(warning_text)
    warning(warning_text2)
    disp('<a href="https://github.com/lucklab/erplab/wiki/Signal-Processing-Toolbox-in-ERPLAB">See Signal Processing Toolbox help here</a>')
    
end