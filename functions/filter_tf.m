% PURPOSE: subroutine for filterp.m, basicrap.m, basicfilter.m, and basicfilterGUI.m
%          sets ERPLAB filter coefficients and other filter parameters
%
% FORMAT
%
% [b, a, labelf, v, frec3dB_final, xdB_at_fx, orderx] = filter_tf(typef, order, valuel, valueh, fs)
%
% INPUTS
%
% typef           - 0  means IIR Butterworth
%                   1  means FIR
%                   2  means notch
%
% order           - filter order (N). (recommended 1 to 8 for Butterworth, 1 to 4096 for FIR). Notch is set internally to order 180.
% valuel          - low-pass filter cutoff  (same as highest bandpass cuttoff)
% valueh          - high-pass filter cutoff (same as lowest bandpass cuttoff)
%
% OUTPUTS
%
% b, a            - filter coefficients in length N+1 vectors 'b' (numerator) and 'a' (denominator). 
%                   The coefficients are listed in descending powers of z.
% labelf          - label for filter type ('Low-pass', 'High-pass', 'Band-pass', 'Stop-band')
% v               - error flag. 1 means no error; 0 means error found
% frec3dB_final   - cutoff frec at -3db
% xdB_at_fx       - true attentuation at frequency cutoff
% orderx          - filter order (twice the order used internally due to filtfilt)
%
%
% See also basicfilter.m basicfilterGUI.m filterp.m basicrap.m
%
% Author: Javier Lopez-Calderon & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% ERPLAB Toolbox
% Copyright © 2007 The Regents of the University of California
% Created by Javier Lopez-Calderon and Steven Luck
% Center for Mind and Brain, University of California, Davis,
% javlopez@ucdavis.edu, sjluck@ucdavis.edu
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

function [b, a, labelf, v, frec3dB_final, xdB_at_fx, orderx] = filter_tf(typef, order, valuel, valueh, fs)

v = 1; % 1 means everything is ok
[b a labelf frec3dB_final xdB_at_fx orderx] = deal([]);
if mod(order,2)~=0
      error('ERPLAB says: filter order must be an even number because of the forward-reverse filtering.')
end
fnyq  = fs/2;
if valuel/fnyq >=1 || valueh/fnyq >=1 || valueh<0 || valuel<0
      error('ERPLAB says: The cutoff frequencies must be within the interval: 0 < fc < fs/2')
end
order = order/2; % Because of filtfilt performs a forward-reverse filtering, it doubles the filter order

% try
if valuel>0 && valueh==0  % Low Pass      
      if typef==1
            % Hamming-window based, linear-phase FIR filter
            [b a]  = fir1n(order, valuel/fnyq);
            frec3dB_aux = halfpower(b, a, fs, valuel); % get the -3db cutoff of filtfilt.            
            deltaf = valuel - frec3dB_aux;
            % Evaluate a -48db to get -6db
            frec_at_6dB = ( 0.003981071705535 - ((0.707*valuel - 0.25*frec3dB_aux) / deltaf)) / ((0.25-0.707)/deltaf);            
            if frec_at_6dB>fnyq
                  frec_at_6dB = fnyq;
            elseif frec_at_6dB<0
                  frec_at_6dB = 0;
            end            
            [b a orderx]  = fir1n(order, frec_at_6dB/fnyq);            
      elseif typef==0
            % Butterworth filter
            [b,a]   = butter(order,valuel/fnyq); % low pass filter
      else
            v = 0; % means something wrong
            return
      end      
      labelf = 'Low-pass';
      fx = valuel;      
elseif valuel==0 && valueh>0   % High Pass
     
      if typef==1
            % Hamming-window based, linear-phase FIR filter
            [b a]  = fir1n(order, valueh/fnyq, 'high');
            frec3dB_aux = halfpower(b, a, fs, valueh); % get the -3db cutoff of filtfilt.
            
            if ~isempty(frec3dB_aux)                  
                  deltaf = valueh - frec3dB_aux;
                  % Evaluate a -48db to get -6db
                  frec_at_6dB = ( 0.003981071705535 - ((0.707*valueh - 0.25*frec3dB_aux) / deltaf)) / ((0.25-0.707)/deltaf);
                  
                  if frec_at_6dB>fnyq
                        frec_at_6dB = fnyq;
                  elseif frec_at_6dB<0
                        frec_at_6dB = 0;
                  end                  
                  [b a orderx]  = fir1n(order, frec_at_6dB/fnyq, 'high');                  
            end
            
      elseif typef==0
            % Butterworth filter
            [b,a]   = butter(order,valueh/fnyq, 'high'); % high pass filter
      else
            v = 0; % means something wrong
            return
      end      
      labelf = 'High-pass';
      fx = valueh;      
elseif valuel>0 && valueh>0 && (valuel>valueh)   % Band Pass      
      if typef==1            
            % Hamming-window based, linear-phase FIR filter
            [b a]  = fir1n(order, [valueh valuel]/fnyq);
            frec3dB_aux = halfpower(b, a, fs, [valuel valueh]); % get the -3db cutoff of filtfilt.
            
            if ~isempty(frec3dB_aux)
                  deltafl = abs(valuel - frec3dB_aux(1));
                  deltafh = abs(valueh - frec3dB_aux(2));                  
                  % Evaluate a -48db to get -6db
                  frec_at_6dBl = ( 0.003981071705535 - ((0.707*valuel - 0.25*frec3dB_aux(1)) / deltafl)) / ((0.25-0.707)/deltafl);
                  frec_at_6dBh = ( 0.003981071705535 - ((0.707*valueh - 0.25*frec3dB_aux(2)) / deltafh)) / ((0.25-0.707)/deltafh);                  
                  if frec_at_6dBl<0 || frec_at_6dBh<0 || frec_at_6dBl>fnyq || frec_at_6dBh>fnyq
                        v=0;
                        return
                  end                  
                  [b a orderx]  = fir1n(order, [ frec_at_6dBh frec_at_6dBl]/fnyq);
            end
      elseif typef==0
            
            [bl,al]   = butter(order,valuel/fnyq);
            [bh,ah]   = butter(order,valueh/fnyq, 'high');
            b  = [bl; bh];
            a  = [al; ah];
      else
            v = 0; % means something wrong
            return
      end      
      labelf = 'Band-pass';
      fx = [valuel valueh];      
elseif (valuel>0 && valueh>0) && (valuel<valueh)  % Notch      
      if typef==1            
            % Hamming-window based, linear-phase FIR filter
            [b a]  = fir1n(order, [valuel valueh]/fnyq, 'stop');
            frec3dB_aux = halfpower(b, a, fs, [valuel valueh]); % get the -3db cutoff of filtfilt.            
            if ~isempty(frec3dB_aux)
                  deltafl = abs(valuel - frec3dB_aux(1));
                  deltafh = abs(valueh - frec3dB_aux(2));                  
                  % Evaluate a -48db to get -6db
                  frec_at_6dBl = ( 0.003981071705535 - ((0.707*valuel - 0.25*frec3dB_aux(1)) / deltafl)) / ((0.25-0.707)/deltafl);
                  frec_at_6dBh = ( 0.003981071705535 - ((0.707*valueh - 0.25*frec3dB_aux(2)) / deltafh)) / ((0.25-0.707)/deltafh);                  
                  if frec_at_6dBl<0 || frec_at_6dBh<0 || frec_at_6dBl>fnyq || frec_at_6dBh>fnyq || (frec_at_6dBl>frec_at_6dBh)
                        v=0;
                        return
                  end                  
                  [b a orderx]  = fir1n(order, [frec_at_6dBl frec_at_6dBh]/fnyq, 'stop');
            end            
      elseif typef==0
            [bl,al]  = butter(order,valuel/fnyq);
            [bh,ah]  = butter(order,valueh/fnyq, 'high');
            b = [bl; bh];
            a = [al; ah];
      else
            v = 0; % means something wrong
            return
      end      
      labelf = 'Stop-band (Simple Notch)';
      fx = [valuel valueh];      
elseif valuel==valueh && typef==2  % Javier's Notch      
      b  = pmnotch(180, valueh/fnyq);
      a  = 1;      
      labelf = 'Stop-band (Parks-McClellan Notch)';
      fx = valueh; % central frequency
else
      v = 0; % means something wrong
      return
end

% catch
%         v = 0; % means something wrong
%         return
% end

%
% Half power cuttof (-3 dB) ONLY FOR FILTFILT!!!
%
[frec3dB_final xdB_at_fx] = halfpower(b, a, fs, fx); % get the -3db cutoff of filtfilt.
orderx = orderx*2;

%--------------------------------------------------------------------------
function b = pmnotch(n, Wn)
% Parks-McClellan notch FIR filter
% Designed by Javier
% Author: Javier Lopez-Calderon
% Davis, California, 2009

f    = linspace(0,1,512);
L    = length(f);
fcsamp   = round(Wn*L);
nshiftfc =  fcsamp-round(L/2);
a     = 1-gausswin(L,70);
amov  = circshift(a,nshiftfc);
b     = firpm(n,f,amov);
