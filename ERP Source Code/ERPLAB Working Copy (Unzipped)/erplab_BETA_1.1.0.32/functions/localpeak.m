function [vlocalpf, vabspf, poslocalpf, posabspf, errorcode] = localpeak(array, npoints, tlocal, multi)

vlocalpf   = [];
poslocalpf = [];
valmax     = [];
posmax     = [];
errorcode  = 0; % no error by default
nsamples   = length(array);

if nargin>4
        error('ERPLAB says: too many inputs.')
end
if nargin<4
        multi = 0; % 1 means multi peaks
end
if nargin<3
        tlocal = 1; % 1 means maximum  (0 means minimum), polarity
end
if nargin<2
        npoints = 0;
end
if nsamples<=(2*npoints)
        errorcode = 1; % error. few samples.
end

%
% Initial interval
%
a = npoints + 1;
b = nsamples - npoints;

%
% Absolute peaks
%
try
        if tlocal==1 % maximum for positives
                [vabspf posabspf] = max(array(a:b));
        else  % minimum for negatives
                [vabspf posabspf] = min(array(a:b));
        end
        posabspf = posabspf + npoints;
catch
        errorcode = 1;
        return
end

%
% local peaks
%
k = 1;
if npoints>0 % LOCAL
        while a<=b
                avgneighborLeft  = mean(array(a-npoints:a-1));
                avgneighborRight = mean(array(a+1:(a+npoints)));
                prea  = array(a-1);
                posta = array(a+1);

                if tlocal==1 % maximum for positives
                        if array(a)>avgneighborLeft && array(a)>avgneighborRight && array(a)>prea && array(a)>posta
                                valmax(k) = array(a);
                                posmax(k) = a;
                                k=k+1;
                        end
                else  % minimum for negatives
                        if array(a)<avgneighborLeft && array(a)<avgneighborRight&& array(a)<prea && array(a)<posta
                                valmax(k) = array(a);
                                posmax(k) = a;
                                k=k+1;
                        end
                end

                a = a+1;
        end

        if ~isempty(valmax)

                if length(unique(valmax))==1 && length(valmax)>1
                        poslocalpf = round(median(posmax));
                        vlocalpf   = unique(valmax);
                elseif length(unique(valmax))>1

                        if multi
                                vlocalpf = valmax;
                                [tf poslocalpf] = ismember(valmax, array);
                                
                        else
                                [vlocalpf indx] = max(valmax);
                                poslocalpf      = posmax(indx);
                        end
                else
                        vlocalpf   = valmax;
                        poslocalpf = posmax;
                end
        end

else % ABSOLUTE
        if tlocal==1 % maximum for positives
                vlocalpf   = vabspf;
                poslocalpf = posabspf;
        else  % minimum for negatives
                vlocalpf   = vabspf;
                poslocalpf = posabspf;
        end
end