function [response] = inputvalue(prompt,dlg_title,num_lines,def)

BackERPLABcolor = [ 0.83 0.82 0.78];    % ERPLAB main window background

oldcolor = get(0,'DefaultUicontrolBackgroundColor');
oldimage = get(0,'DefaultImageVisible');
set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor,...
        'DefaultImageVisible','on')
options.Resize      ='on';
options.WindowStyle ='normal';
options.Interpreter ='tex';
response = inputdlg(prompt,dlg_title,num_lines,def, options);
set(0,'DefaultUicontrolBackgroundColor',oldcolor,...
        'DefaultImageVisible',oldimage)

