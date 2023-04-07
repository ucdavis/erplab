% PURPOSE  :  Compute the default number of row and columns when plot ERP
% waves and this function is based on the ERLAB function in ploterpGUI()
%
% FORMAT   :

% f_getrow_columnautowaveplot(plotArray);
%
%
% INPUTS   :
%
% plotArray        -Index of Grid e.g., [1 2 3 4 5 6 7 8]

% OUTPUTS:
%
% pbox            -First element is the number of row and the second one is
%                  the number of columns, e.g., pbox = [3 3];




% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022




function pbox = f_getrow_columnautowaveplot(plotArray)
newnch = numel(plotArray);
% if get(handles.checkbox_MGFP, 'Value')
%         newnch = newnch + 1;
% end
dsqr   = round(sqrt(newnch));
sqrdif = dsqr^2 - newnch;
if sqrdif<0
        pbox(1) = dsqr + 1;
else
        pbox(1) = dsqr;
end
pbox(2) = dsqr;
if pbox(1)<=0  % JLC. 11/05/13
        pbox(1)=1;
end
if pbox(2)<=0  % JLC. 11/05/13
        pbox(2)=1;
end