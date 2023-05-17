% PURPOSE: subroutine for ploterpGUI.m
%          Creates default X ticks for ERPLAB's plotting GUI
%
% FORMAT
%
% def = default_time_ticks(ERP, trange)
%
% INPUTS
%
% ERP       - ERPset
% trange    - min and max ERP window time in ms
%
% OUTPUT
%
% def       - tick values to show in x axis
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2012

function [def stepx]= default_time_ticks_studio(ERP,trange,kf)
datatype = checkdatatype(ERP);
if nargin<3
    if strcmpi(datatype, 'ERP')
        kf = 100;
    else
        kf = 10;
    end
end

if strcmpi(datatype, 'ERP')
    kktime = 1000;
else
    kktime = 1;
end

% if 100<min(diff(trange))<=200
%     kf = 50;
% elseif 10<min(diff(trange))<=100
%     kf = 10;
% elseif 1<min(diff(trange))<=10
%     kf =1;
% elseif 0.1<min(diff(trange))<=1
%     kf =0.1; 
% end

def = [];
if nargin<2
    xxs1 = ceil(kktime*ERP.xmin);
    xxs2 = floor(kktime*ERP.xmax);
else
    xxs1 = trange(1);
    xxs2 = trange(2);
end


stepx = kf;

xxstick1   = (round(xxs1/kf)+ 1)*kf;
xxstick2   = (round(xxs2/kf)+ 1)*kf;
goags = 1;  L1=7; L2=15; w=1;

while goags && w<=kf
    %stepx
    xtickarray = 1.5*xxstick1:stepx:xxstick2*1.5;
    if length(xtickarray)>=L1 && length(xtickarray)<=L2
        xm = xtickarray(round(length(xtickarray)/2));
        xtickarray = xtickarray-xm;
        xtickarray = xtickarray(xtickarray>=xxs1 & xtickarray<=xxs2 );
        if xxs1<0 && xtickarray(1)>=0
            xtickarray = [ -round((abs(xxs1)/2)) xtickarray];
            xtickarray = unique_bc2(xtickarray);
        end
        def = {vect2colon(xtickarray,'Delimiter','off')};
        goags = 0;
    elseif length(xtickarray)>L2
        stepx = stepx*2;
    elseif length(xtickarray)<L1
        %%
        stepx = round(stepx/2);
        %%
    end
    w=w+1;
end