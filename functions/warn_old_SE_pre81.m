% Warn Old SEM in ERP
% axs Nov 2020
%
% INPUT
%   shist = 1 when pop_loaderp called from GUI
%   shist = 2 when pop_loaderp called from script
function warn_old_SE_pre81(gui_state)

% Argument checks
if nargin<1
    gui_state = 1;
end

% check working memory
% don't warn if preference not to is already in working memory
mem = erpworkingmemory('supress_SE_warning');

if isempty(mem) == 1
    % no warning pref in memory
    warn_here = 1;
else
    if mem == 1
        % preference not to warn in memory
        warn_here = 0;
    else
        warn_here = 1;
    end
end

erplab_default_values % script
currvers  = ['erplab' erplabver];

old_SEM_txt = ['', ...
    'At least one of these loaded ERPsets was made in an ERPLAB version below v8.1 \n\n', ...
    'This installation of ERPLAB is: ', num2str(erplabver), '\n', ...
    'The Standard Error code **prior to v8.1** had a bug that has been fixed. \n', ...
    'We recommend using the lastest ERPLAB, and, \n', ...
    'if you plan to use the pointwise SEM, we recommend \n', ...
    'remaking this ERPset using v8.1+'];

old_SEM_title = 'ERPLAB: Old ERPSET SEM, pre-v8.1';

buttons = {'See latest release';'Don’t show again';'Continue'};

if warn_here
    if gui_state == 1
        % if from GUI
        buttonpressed = askquestpoly(sprintf(old_SEM_txt), old_SEM_title, buttons);
    elseif gui_state == 2
        % if from script
        disp(sprintf(old_SEM_txt));
        disp('To stop this warning, run:')
        disp('erpworkingmemory(''supress_SE_warning'',1)');
    end
    
    which_buttonpressed = strcmp(buttonpressed,buttons);
    
    if which_buttonpressed(1)
        % See latest release requested
        web('https://github.com/lucklab/erplab/releases', '-browser');
        
    elseif which_buttonpressed(2)
        % Don't show again requested
        
        % Push 1 to erpworking memory, under name supress_SE_warning
        erpworkingmemory('supress_SE_warning',1);
        % clear this with erpworkingmemory('supress_SE_warning',[])
        
        % check it saved correctly
        test_check = erpworkingmemory('supress_SE_warning');
        if test_check == 1
            worked_text = 'This warning for old SE in loaded ERPsets will not be shown again';
            disp(worked_text)
        else
            prob_text = 'Problem saving warning preferences. No write permission to ERPLAB folder??';
            disp(prob_text)
        end
        
        % and no action on 'Continue'
    end
end
    
    
