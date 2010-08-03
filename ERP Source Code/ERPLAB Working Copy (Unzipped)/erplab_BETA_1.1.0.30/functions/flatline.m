% data = row array of data (1 epoch at 1 channel)
% th   = threshold. One or 2 values (less one is the left most). 
%        If 1 values then th = [-abs(th)  abs(th)]
% dur  = duration (in samples) of blocking or flat line. It must be <= data length
%
% Author: Javier Lopez-Calderon & Steve J. Luck

function captured = flatline(data, th, dur)

dy       = diff(data);
captured = 0;
n        = length(dy);
counter  = 0;

if numel(th)>2 || numel(th)==0
      error('ERPLAB says: You have 2 define 1 or 2 values for threshold.')
end

if numel(th)==1
      th(1) = -abs(th);
      th(2) = abs(th);
end

for i=1:n
      if dy(i)>=th(1) && dy(i)<=th(2) 
            counter = counter+1;
            if counter>= dur
                  captured = 1;
                  break
            end
      else
            counter = 0; % reset counter
      end
end
