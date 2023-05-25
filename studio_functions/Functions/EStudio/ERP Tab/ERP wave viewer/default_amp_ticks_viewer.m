% PURPOSE: Creates default Y ticks for EStudio plotting GUI
%
% FORMAT
%
%  def = default_amp_ticks(yrange)
%
% INPUTS
%
% ERP       - ERPset
% yrange    - min and max ERP amplitudes
%
% OUTPUT
%
% def       - tick values to show in Y axis
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
    beep;
    disp('Please input the y scale with two elements');
    return;
end

if numel(yrange) ==1 || isempty(yrange)
    beep;
    disp('Please input the y scale with two elements');
    return;
end

if yrange(1)>= yrange(2)
    beep;
    disp('Please the left edge of y scale should be smaller than the righ edge.');
    return;
    
end

minpnts = 40; % minimum amuount of values for selecting ticks.
if sum(sign(yrange))==0 % when yscale goes from - to +
    yrmax = max(abs(yrange));
    yarray = -round(yrmax):0.1:round(yrmax);
    if length(yarray)<40
        yarray = linspace(-yrmax, yrmax, minpnts);
    end
else % when yscale goes from - to - or + to +
    yarray = round(yrange(1)):0.1:round(yrange(2));
    if length(yarray)<40
        yarray = linspace(yrange(1), yrange(2), minpnts);
    end
end

a1 = yarray(yarray>0);
b1 = closest(a1, [ min(a1)+(max(a1)-min(a1))*0.25 min(a1)+(max(a1)-min(a1))*0.5 min(a1)+(max(a1)-min(a1))*0.75 max(a1)]);
a2 = yarray(yarray<0);
if ~isempty(a2) && ~isempty(b1)
    b2 = -1*fliplr(b1);
elseif ~isempty(a2) && isempty(b1)
    b2 = closest(a2, [ min(a2) min(a2)+(max(a2)-min(a2))*0.25 min(a2)+(max(a2)-min(a2))*0.5 min(a2)+(max(a2)-min(a2))*0.75]);
    b1 = -1*fliplr(b2);
else
    b2 = [];
end

%ams: round to more sensible numbers
if 0.05<= yrange(2) - yrange(1) <=0.1
   sensible_ones = [-10000:0.01:10000]; 
elseif 0< yrange(2) - yrange(1) <0.05
     sensible_ones = [-100:0.0001:100];  
elseif yrange(2) - yrange(1)>=1
sensible_ones = [-10000:0.5:10000];
else
    sensible_ones = [-10000:0.05:10000];
end
b1 = closest(sensible_ones,b1);
b2 = closest(sensible_ones,b2);

if ~isempty(b2)
    Ajust_left =[];
    count = 0;
    for ii = 1:numel(b2)
        if b2(ii)< yrange(1)
            count = count+1;
            Ajust_left(count) = ii;
        end
    end
    b2(Ajust_left) = [];
end

if ~isempty(b1)
    Ajust_right =[];
    count = 0;
    for ii = 1:numel(b1)
        if b1(ii)> yrange(2)
            count = count+1;
            Ajust_right(count) = ii;
        end
    end
    b1(Ajust_right) = [];
end
b1 = unique(b1);
b2 = unique(b2);
if ~isempty(b1)&& ~isempty(b2)
    def = vect2colon([b2 0 b1],'Delimiter','off');
elseif isempty(b1)&& ~isempty(b2)
    if yrange(2) >0 && b2(end)<0
        def = vect2colon([b2 0 yrange(2)],'Delimiter','off');
    else
        def = vect2colon([b2 yrange(2)],'Delimiter','off');
    end
elseif ~isempty(b1)&& isempty(b2)
    if yrange(1)<0 && b1(1)>0
        def = vect2colon([yrange(1) 0 b1],'Delimiter','off');
    else
        def = vect2colon([yrange(1) b1],'Delimiter','off');
    end
end
