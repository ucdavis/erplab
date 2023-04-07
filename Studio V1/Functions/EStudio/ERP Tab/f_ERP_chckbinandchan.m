function [chk, msgboxText] = f_ERP_chckbinandchan(ERP, binArray, chanArray,Bin_Chan_label)
chk=[0 0];
msgboxText = '';

% if numel(Bin_Chan_label)==1
%     Bin_label
%     
% end


if Bin_Chan_label==1
    if isempty(binArray)
        msgboxText =  'You have not specified any bin';
        chk(1) = 1;
        return
    end
    if any(binArray<=0)
        msgboxText =  sprintf('Invalid bin index.\nPlease specify only positive integer values.');
        chk(1) = 1;
        return
    end
    if any(binArray>ERP.nbin)
        msgboxText =  sprintf('Bin index out of range!\nYou only have %g bins in this ERPset',ERP.nbin);
        chk(1) = 1;
        return
    end
    if length(binArray)~=length(unique_bc2(binArray))
        msgboxText = 'You have specified repeated bins.';
        chk(1) = 1;
        return
    end
end
if Bin_Chan_label ==2
    if isempty(chanArray)
        msgboxText =  'You have not specified any channel';
        chk(2) = 1;
        return
    end
    if any(chanArray<=0)
        msgboxText =  sprintf('Invalid channel index.\nPlease specify only positive integer values.');
        chk(2) = 1;
        return
    end
    if any(chanArray>ERP.nchan)
        msgboxText =  sprintf('Channel index out of range!\nYou only have %g channels in this ERPset', ERP.nchan);
        chk(2) = 1;
        return
    end
    if length(chanArray)~=length(unique_bc2(chanArray))
        msgboxText = 'You have specified repeated channels.';
        chk(2) = 1;
        return
    end
    return;
end