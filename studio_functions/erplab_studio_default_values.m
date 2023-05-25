erplabstudiover = '1.00';                  % current erplab studio version
erplabstudiorel = '26-April-2022';             % DOB
erplabstudiodeveloper = 'Simmons&Zhang'; 
% erplabstudiolabel = 1;%0: using ERPLAB; 1:using ERPLAB Studio
%ColorB = [170 180 195]/255;          % old background color (until version 3)
%ColorB = [0.9216 0.8353 0.6078];     % background color for version 4
%ColorB = [0.7020 0.7647 0.8392];     % background color since version 4.0.0.3
%ColorB = [0.9804 0.8118 0.5529];     % background color since version 4.0.0.11
ColorB       = [0.7020 0.77 0.85];     % background color since version 4.0.0.12
ColorBviewer = [0.8 0.8 0.9];%[0.7765,0.7294,0.8627];
% ColorB       = [0.95 0.95 0.95];
ColorF       = [0.02 0.02 0.02];       % foreground color since version 4.0.2.0
errorColorF  = [0 0 0];                % foreground color for error window
errorColorB  = [0.6824 1 0.6353];      % background color for error window
fontunitsGUI = 'pixels';

set(0,'Units','pixels')
thisscreen = get(0, 'ScreenSize');
if thisscreen(4)>=1440
    fontsizeGUI = 12; % high resolution display (eg Retina)
else
    fontsizeGUI = 11;
end
