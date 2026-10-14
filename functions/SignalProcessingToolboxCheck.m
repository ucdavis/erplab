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
    warning_text = 'ERPLAB: Signal Processing Toolbox not found. Filtering, Hamming-windowed spectral analysis, tapered power-spectrum averaging, and BEST frequency-band extraction will be unavailable.';
    warning_text2= 'Please contact your system administrator or MathWorks to install "Signal Processing Toolbox" for your MATLAB version.';
    bt = warning('off','backtrace');
    warning('ERPLAB:noSignalProcessingToolbox', '%s\n%s\n%s', warning_text, warning_text2, ...
        '<a href="https://github.com/lucklab/erplab/wiki/Signal-Processing-Toolbox-in-ERPLAB">See Signal Processing Toolbox help here</a>');
    warning(bt);
    
end