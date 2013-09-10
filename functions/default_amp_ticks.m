% PURPOSE: subroutine for ploterpGUI.m
%          Creates default Y ticks for ERPLAB's plotting GUI
%
% FORMAT
%
%  [def miny maxy] = default_amp_ticks(ERP, yrange)
%
% INPUTS
%
% ERP       - ERPset
% yrange    - min and max ERP amplitudes
%
% OUTPUT
%
% def       - tick values to show in Y axis
% miny      - minimum ERP amplitude (to be used for auto-Y)
% maxy      - maximum ERP amplitude (to be used for auto-Y)
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2012
function [def miny maxy] = default_amp_ticks(ERP, binArray, yrange)

def   = '-1 1';
miny  = 0;
maxy  = 0;
if nargin<2
        binArray = 1:ERP.nbin;
end
if nargin<3 || nargout>1
        nbin  = length(binArray);
        ymin = zeros(1,nbin);
        ymax = ymin;
        
        for k=1:nbin
                ymin(k) = min(min(ERP.bindata(:,:,binArray(k))'));
                ymax(k) = max(max(ERP.bindata(:,:,binArray(k))'));
        end
        
        miny = min(ymin);
        maxy = max(ymax);
        
        if isempty(miny) || isempty(maxy)
                return
        end
        yrange(1) = miny*1.2;
        yrange(2) = maxy*1.1;
end
if abs(yrange(2)-yrange(1))<3 % Mar 27, 2013
        scfactor = 100;
else
        scfactor = 1;
end

yys1 = yrange(1)*scfactor;
yys2 = yrange(2)*scfactor;

% xxs1       = ceil(1000*ERP.xmin);
% xxs2       = floor(1000*ERP.xmax);
yystick1   = (round(yys1/10)+ 0.1)*10;
yystick2   = (round(yys2/10)+ 0.1)*10;
goags = 1;
stepy = 2;
L1=7;
L2=15;
w=1;
while goags && w<=100
      %stepy
      ytickarray = 1.5*yystick1:stepy:yystick2*1.5;
      if length(ytickarray)>=L1 && length(ytickarray)<=L2
            ym = ytickarray(round(length(ytickarray)/2));
            ytickarray = ytickarray-ym;
            ytickarray = ytickarray(ytickarray>=yys1 & ytickarray<=yys2 );
            if yys1<0 && ytickarray(1)>=0
                  ytickarray = [ -round((abs(yys1)/2)) ytickarray];
                  ytickarray = unique(ytickarray);
            end
            def = {vect2colon(ytickarray/scfactor,'Delimiter','off')};
            goags = 0;
      elseif length(ytickarray)>L2
            stepy = stepy*2;
      elseif length(ytickarray)<L1
            stepy = round(stepy/2);
      end
      w=w+1;
end



