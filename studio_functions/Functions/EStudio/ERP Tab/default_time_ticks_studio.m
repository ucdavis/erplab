% PURPOSE: subroutine for ploterpGUI.m
%          Creates default X ticks for ERPLAB's plotting GUI
%
% FORMAT
%
% [def, stepx] = default_time_ticks_studio(ERP, trange)
%
% INPUTS
%
% ERP       - ERPset (used to determine data type and epoch limits)
% trange    - [tmin tmax] display window in ms (ERP) or Hz (spectrum)
%
% OUTPUT
%
% def       - tick values as a cell string (e.g. {'-200 0 200 400 600 800'})
% stepx     - the chosen tick spacing
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2012

function [def, stepx] = default_time_ticks_studio(ERP, trange, kf) %#ok<INUSD>
datatype = checkdatatype(ERP);

if strcmpi(datatype, 'ERP')
    kktime = 1000;
else
    kktime = 1;
end

def = [];
if nargin < 2
    xxs1 = ceil(kktime * ERP.xmin);
    xxs2 = floor(kktime * ERP.xmax);
else
    xxs1 = trange(1);
    xxs2 = trange(2);
end

range_width = xxs2 - xxs1;
if range_width <= 0
    stepx = 1;
    return;
end

% Candidate step sizes (nice round numbers), smallest to largest.
% The algorithm picks the smallest step that yields 5-12 ticks within the
% range, producing clean multiples rather than the centered-shift approach
% of the prior algorithm (which could yield non-round tick values and
% could get stuck when stepx reached 0 via repeated halving).
if strcmpi(datatype, 'ERP')
    candidates = [1 2 5 10 20 25 50 100 200 250 500 1000 2000];
else
    candidates = [0.001 0.002 0.005 0.01 0.02 0.05 0.1 0.2 0.5 1 2 5 10];
end

L1 = 5;
L2 = 12;

stepx = candidates(end); % fallback if nothing qualifies
for ii = 1:length(candidates)
    s = candidates(ii);
    t1 = ceil(xxs1 / s) * s;
    t2 = floor(xxs2 / s) * s;
    if t2 >= t1
        nticks = round((t2 - t1) / s) + 1;
        if nticks >= L1 && nticks <= L2
            stepx = s;
            break;
        end
    end
end

% Generate ticks at exact multiples of stepx within the range
t1 = ceil(xxs1 / stepx) * stepx;
t2 = floor(xxs2 / stepx) * stepx;
xtickarray = t1 : stepx : t2;
xtickarray = xtickarray(xtickarray >= xxs1 & xtickarray <= xxs2);

if isempty(xtickarray)
    % Fallback: 5 evenly spaced ticks covering the full range
    xtickarray = linspace(xxs1, xxs2, 5);
    stepx = xtickarray(2) - xtickarray(1);
end

def = {vect2colon(xtickarray, 'Delimiter', 'off')};
