function com = pop_erphelp

com = '';

help eegplugin_erplab

if ispc
        dir1 = which('ERPLAB_MANUAL_BETA114.htm');
        winopen(dir1)
else
        dir1 = ['file:///' which('ERPLAB_MANUAL_BETA114.htm')];
        web(dir1)
end
com = 'pop_erphelp';
return