%
% Author: Javier Lopez-Calderon
%
function cleanerplab

p = which('eegplugin_erplab');
p = p(1:findstr(p,'eegplugin_erplab.m')-1);
direrp = {'functions', 'pop_functions', 'Guis'};
recycle on;

for i=1:length(direrp)
        tempname1 = fullfile(p,direrp{i},'*.m~');
        tempname2 = fullfile(p,direrp{i},'*.asv');
        delete(tempname1)
        delete(tempname2)
end
recycle off;
disp('Clear!')