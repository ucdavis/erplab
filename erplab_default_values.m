erplabver = '4.0.2.5';                % current erplab version
erplabrel = '20-Nov-2013';            % DOB
%ColorB = [170 180 195]/255;          % old background color (until version 3)
%ColorB = [0.9216 0.8353 0.6078];     % background color for version 4
%ColorB = [0.7020 0.7647 0.8392];     % background color since version 4.0.0.3
%ColorB = [0.9804 0.8118 0.5529];     % background color since version 4.0.0.11
ColorB       = [0.7020 0.77 0.85];     % background color since version 4.0.0.12
ColorF       = [0.02 0.02 0.02];       % foreground color since version 4.0.2.0
errorColorF  = [0 0 0];                % foreground color for error window
errorColorB  = [0.6824 1 0.6353];      % background color for error window
fontunitsGUI = 'pixels';
if isretinad==1
        fontsizeGUI = 12; % retina display
elseif isretinad==2
        fontsizeGUI = 11; % iMac display
else
        fontsizeGUI = 8.2;
end