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

function def = default_time_ticks(ERP, trange)

def = [];
if nargin<2
      xxs1 = ceil(1000*ERP.xmin);
      xxs2 = floor(1000*ERP.xmax);
else
      xxs1 = trange(1);
      xxs2 = trange(2);
end

xxstick1   = (round(xxs1/100)+ 1)*100;
xxstick2   = (round(xxs2/100)+ 1)*100;
goags = 1; stepx = 100; L1=7; L2=15; w=1;

while goags && w<=100
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
            stepx = round(stepx/2);
      end
      w=w+1;
end