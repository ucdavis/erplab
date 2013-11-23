% PURPOSE Get the -3dB cutoff frequency value using filtfilt.m
%
% b,a = filter coefficients.
% fs  = data sample rate
% fc_user  = user's frequency cutoff
%
% WARNING: For working with filtfilt.m function!
%
% filtfilt result has the following characteristics:
%       a) Zero-phase distortion
%       b) A filter transfer function, which equals the squared magnitude of the original filter transfer function
%           WARNING by JLC: THIS IMPLIES THAT THE CUTOFF FREQUENCY IS NOT AT -3dB ANYMORE, IT IS AT -6dB INSTEAD!!!
%       c) A filter order that is double the order of the filter specified by b and a
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

function [frec_at_3dB xdB_at_fc_user ] = halfpower(b, a, fs, fc_user)

if nargin<4
      fc_user  =-1;
      nfc_user = 1;
else
      nfc_user = length(fc_user); % 1 or 2 frequency cutoff?
end

if length(b)<101  % order 200
      if nnz(fc_user<0.1)>0
            fresol = abs(min(fc_user)); % adjust resolution to very lower frecs.
      else
            fresol = 0.1; % Hz
      end
else
      fresol = 0.01; % Hz
end

nfilters = size(b,1); % 1 means 1 filter (e.g. lowpass), 2 means 2 filters (e.g. highpass+lowpass)
fnyq  = fs/2;
N     = round(fnyq/fresol);  %number of points for frequency response at 0.1 Hz resolution.
warning off all

try
      for k = 1:nfilters
            
            [hf,f1] = freqz(b(k,:),a(k,:),N,fs);
            hf2     = abs(hf).^2; % filtfilt has a transfer function, which equals the squared magnitude of the original filter transfer function.
                       
            if (nfc_user==1 && nfilters==1) || (nfc_user==2 && nfilters==2) % for butter and FIR
                  
                  [v loc] = min(abs(hf2 - 0.707)); % frequency at 70.7%
                  frec_at_3dB(k) = f1(loc);
                  
                  if fc_user(k)<0
                        xdB_at_fc_user = [];
                  else
                        [xx indxx] = min(abs(f1-fc_user(k)));
                        
                        if hf2(indxx)>0
                              xdb = single(20*log10(hf2(indxx)));% true attentuation at frequency cutoff
                              xdB_at_fc_user(k) = round(xdb);
                        else
                              xdB_at_fc_user = [];
                              break
                        end
                  end
                  
            elseif (nfc_user==2 && nfilters==1)  % for FIR only
                                    
                  hf2easy = abs(hf2 - 0.707);
                  hf2easy(hf2easy>0.02) = 1;
                  %[vlocalpf, vabspf, poslocalpfx] = localpeak(hf2easy, 1, 0, 1)                  
                  [pks,poslocalpf]=findpeaks(-hf2easy,'minpeakdistance',3);
                  
                  
                  if length(poslocalpf)~=2
                        frec_at_3dB = [];
                        xdB_at_fc_user = [];
                        return
                  end                  
                  if fc_user(1)>fc_user(2) % band-pass
                        
                        frec_at_3dB    = circshift(round(f1(poslocalpf)),1)';  % [lowpass  highpass]
                        
                        if fc_user(1)<=frec_at_3dB(1) || fc_user(2)>=frec_at_3dB(2)
                              frec_at_3dB = [];
                              xdB_at_fc_user = [];
                              return
                        end
                  else           % notch
                        
                        frec_at_3dB    = round(f1(poslocalpf))' ; % [highpass lowpass]
                        
                        if fc_user(1)<=frec_at_3dB(1) || fc_user(2)>=frec_at_3dB(2) || (frec_at_3dB(1)>frec_at_3dB(2))
                              frec_at_3dB = [];
                              xdB_at_fc_user = [];
                              return
                        end
                  end                  
                  if ismember_bc2(-1,sign(fc_user))
                        xdB_at_fc_user = [];
                  else
                        [xx ifreal1] = min(abs(f1-fc_user(1)));
                        [xx ifreal2] = min(abs(f1-fc_user(2)));
                        xdB_at_fc_user(1) = round(single(20*log10(hf2(ifreal1)))); % true attentuation at frequency cutoff
                        xdB_at_fc_user(2) = round(single(20*log10(hf2(ifreal2)))); % true attentuation at frequency cutoff
                  end
            else
                  frec_at_3dB   = [];
                  xdB_at_fc_user = [];
            end
      end
catch
      disp('Oops! attenuation at frequency cutoff could not be assessed...')
      frec_at_3dB   = [];
      xdB_at_fc_user = [];
end
