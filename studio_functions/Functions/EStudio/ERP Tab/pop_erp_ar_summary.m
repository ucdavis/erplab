%%This function is to display the summary of trial information
%
% FORMAT   :
%
% pop_erp_ar_summary(ALLERP,ERPArray);
%
% ALLERP        - structure array of EEG structures
% ERPArray      -index of erpsets




% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Apr. 2024



function erpcom = pop_erp_ar_summary(ALLERP,ERPArray,EEGNames)

erpcom = '';
if nargin < 1 || nargin >3
    help pop_erp_ar_summary
    return
end
if nargin < 2
    ERPArray = [1:length(ALLERP)];
end
if isempty(ALLERP)
    msgboxText = ['ALLERP is empty.'];
    title = 'ERPLAB Studio: pop_erp_ar_summary() inputs';
    errorfound(sprintf(msgboxText), title);
    return
end

if isempty(ERPArray) || any(ERPArray(:)>length(ALLERP)) || any(ERPArray(:)<1)
    ERPArray = [1:length(ALLERP)];
end

if nargin < 3
    EEGNames = '';
end


if ~isempty(ERPArray)
    app = feval('dq_trial_rejection',ALLERP,ERPArray,EEGNames);
    waitfor(app,'Finishbutton',1);
end
ERPArraystr= vect2colon(ERPArray);
if ~isempty(EEGNames)
    erpcom = sprintf('erpcom = pop_erp_ar_summary(ALLERP,%s',ERPArraystr);
    
    nn = length(EEGNames);
    erpcom = sprintf( '%s, {''%s'' ', erpcom, EEGNames{1});
    for ff=2:nn
        erpcom = sprintf( '%s, ''%s'' ', erpcom, EEGNames{ff});
    end
    erpcom = sprintf( '%s});', erpcom);
    
else
    erpcom = sprintf('erpcom = pop_erp_ar_summary(ALLERP,%s);',ERPArraystr);
end
end