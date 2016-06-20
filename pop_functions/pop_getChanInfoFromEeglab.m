function [ERP erpcom] = pop_getChanInfoFromEeglab(ERP)
ERPaux = ERP;
ERP    = pop_clearerpchanloc( ERP, 'Warning', 'off');
ERP    = borrowchanloc(ERP);
erpcom = sprintf('%s = getChanInfoFromEeglab(%s)', inputname(1), inputname(1));
[ERP, issave, erpcom_save] = pop_savemyerp(ERP,'gui','erplab', 'History', 'implicit');
if issave>0
        % generate text command
        if issave==2
                erpcom = sprintf('%s\n%s', erpcom, erpcom_save);
                msgwrng = '*** Your ERPset was saved on your hard drive.***';
        else
                msgwrng = '*** Warning: Your ERPset was only saved on the workspace.***';
        end
        fprintf('\n%s\n\n', msgwrng)
        try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
else
        ERP     = ERPaux;
        msgwrng = 'ERPLAB Warning: Your changes were not saved';
        try cprintf([1 0.52 0.2], '%s\n\n', msgwrng);catch,fprintf('%s\n\n', msgwrng);end ;
end
displayEquiComERP(erpcom);
%
% Completion statement
%
msg2end
return
