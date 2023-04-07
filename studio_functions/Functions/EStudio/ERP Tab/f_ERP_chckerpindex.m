function [chk, msgboxText] = f_ERP_chckerpindex(ALLERP, SelectedIndex)
chk=0;
msgboxText = '';

ALLERPinx = [1:length(ALLERP)];

if isempty(SelectedIndex)
    msgboxText =  'You have not specified any ERPset';
    chk = 1;
    return
end

if any(SelectedIndex<=0)
    msgboxText =  sprintf('Invalid ERPset index.\n Please specify only positive integer values.');
    chk= 1;
    return
end



if max(SelectedIndex(:))> numel(ALLERPinx)
    msgboxText =  sprintf('Selected ERPsets'' index out of range of ALLERP!');
    chk= 1;
    return
end
if length(SelectedIndex)~=length(unique_bc2(SelectedIndex))
    msgboxText = 'You have specified repeated ERPsets.';
    chk = 1;
    return
end

