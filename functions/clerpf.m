% Clear ERPLAB Figures
% By Jav
function clerpf

findplot = findobj('Tag','Plotting_ERP','-or', 'Tag','Scalp','-or', 'Tag','copiedf');
for i=1:length(findplot)
        close(findplot(i))
end

