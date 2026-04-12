% PURPOSE: Creates default Y ticks for EStudio plotting GUI
%
% FORMAT
%
%  def = default_amp_ticks_viewer(yrange)
%
% INPUTS
%
% yrange    - min and max ERP amplitudes [ymin ymax]
%
% OUTPUT
%
% def       - tick values to show in Y axis (string via vect2colon)
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022




function def = default_amp_ticks_viewer(yrange)

def   = [];

if nargin<1
    disp('Please input the y scale with two elements');
    return;
end

if numel(yrange) ==1 || isempty(yrange)
    disp('Please input the y scale with two elements');
    return;
end

if yrange(1)>= yrange(2)
    beep;
    disp('The left edge of y scale should be smaller than the right edge.');
    return;
end

% Choose tick step that gives 4-8 evenly-spaced ticks across the range.
% Prefers steps where both axis endpoints land on a tick (e.g. step=3 for
% [-3,9] rather than step=2, so ticks are -3,0,3,6,9 not -2,0,2,4,6,8).
range_width = yrange(2) - yrange(1);
candidates = [0.001, 0.002, 0.003, 0.004, 0.005, ...
              0.01,  0.02,  0.03,  0.04,  0.05, ...
              0.1,   0.2,   0.3,   0.4,   0.5, ...
              1,     2,     3,     4,     5, ...
              10,    20,    30,    40,    50, ...
              100,   200,   300,   400,   500];
tick_step      = candidates(end);
found_any      = false;
found_endpoint = false;
for k = 1:numel(candidates)
    s = candidates(k);
    n = floor(range_width / s) + 1;
    if n >= 4 && n <= 8
        if ~found_any
            tick_step = s;   % smallest step giving 4-8 ticks (fallback)
            found_any = true;
        end
        % Prefer steps where both endpoints are exact multiples of s
        if ~found_endpoint && ...
                abs(mod(yrange(1), s)) < s*1e-9 && ...
                abs(mod(yrange(2), s)) < s*1e-9
            tick_step      = s;
            found_endpoint = true;
        end
    end
end

% Generate ticks at exact multiples of tick_step covering the range.
% Use a small tolerance before floor/ceil to handle floating-point cases like
% floor(0.3/0.1) = floor(2.9999...) = 2 instead of 3.
start_tick = ceil(yrange(1)  / tick_step - 1e-9) * tick_step;
end_tick   = floor(yrange(2) / tick_step + 1e-9) * tick_step;
ticks = start_tick : tick_step : end_tick;

% Remove duplicates and ticks outside the range
ticks = unique(ticks);
ticks(ticks < yrange(1) - tick_step*1e-9) = [];
ticks(ticks > yrange(2) + tick_step*1e-9) = [];

if isempty(ticks)
    ticks = [yrange(1) yrange(2)];
end

def = vect2colon(ticks, 'Delimiter', 'off');
