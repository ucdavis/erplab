% PURPOSE: subroutine for pop_insertcodeatTTL.m
%
% FORMAT:
%
% EEG = TTL2event(EEG, chanTTL, thresh, ecode, durcond);
%
% Sometimes you do not have event codes in your recordings. Instead, you
% have to deal with square waves (or scaled TTL pulses) to identify when a
% stimulus was presented... I know, and do not look for guilty ones.
% That's just the way it is...
%
% Fortunately, ERPLAB offers you an opportunity to rebuild your event codes
% table based on the TTL's onset detection. We hope this helps.
% 
% Inputs:
% 
% EEG       - EEG structure (continous dataset)
% chanTTL   - index of channel(s) containing TTL-like pulses
% thresh    - Threshold for detecting TTL pulses (50% of maximum is recommended)
% ecode     - new event code to insert at the onset of each TTL pulse.
%             If it is not defined, ERPLAB will insert an event code equal
%             to the duration of the TTL pulse, in samples (default). 
% You can also define 1 event code per TTL channel (NaN means duration of the pulse as event code)
% durcond   - duration condition. You may define a minimum duration of a
%             TTL-like activity to be considered a "true" TTL from your
%             task. If it is not defined, ERPLAB will use a duration of 1
%             sample.
% 
% Output:
% 
% EEG
%
%
% Author: Javier Lopez-Calderon

function EEG = TTL2event(EEG, chanTTL, thresh, ecode, durcond, relop)

if nargin<6
      relop = 3;
end
if nargin<5
      durcond = [];
end
if nargin<4
      ecode = NaN;
end
if isempty(durcond)
      durcond = 1; % sample
end
if isempty(ecode)
      ecode = NaN(1,numel(chanTTL));
else
      if numel(ecode)>1 && numel(ecode)~=numel(chanTTL)
            error('ERPLAB says: number of event codes is different than the number of channels.')
      else
            ecode = repmat(ecode,1,numel(chanTTL));
      end
end

npoints     = EEG.pnts;
nchanTTL    = length(chanTTL);
datax(1:nchanTTL,:) = EEG.data(chanTTL,:);
j=1;

for ch=1:nchanTTL
      k=0;
      z=0;
      for i=1:npoints            
            switch relop % Relational Operators < > <= >=
                  case 1 % <  (less than)
                        cond = datax(ch,i)<thresh;
                  case 2 % <=  ( less than or equal to)
                        cond = datax(ch,i)<=thresh;
                  case 3 % >= (greater than or equal to)
                        cond = datax(ch,i)>=thresh;
                  case 4 % >  (greater than)
                        cond = datax(ch,i)>thresh;
            end            
            if cond
                  k=k+1;
                  if k==1
                        onset = i;
                  end
                  z=0;
            else
                  if z==0 && k>=durcond                        
                        if isnan(ecode(ch))
                              countersamples(j)= k;
                        else
                              countersamples(j)= ecode(ch);
                        end
                        
                        onsetsamples(j)  = onset;
                        k=0;
                        i= [];
                        j=j+1;
                  end
                  z = z+1;
            end
      end
end

nevent = length(countersamples);
countersamples = num2cell(countersamples);
onsetsamples   = num2cell(onsetsamples);
[EEG.event(1:nevent).type] = countersamples{:};
[EEG.event(1:nevent).latency] = onsetsamples{:};