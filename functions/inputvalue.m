function [response] = inputvalue(prompt,dlg_title,num_lines,def)

BackERPLABcolor = erpworkingmemory('ColorB');
ForeERPLABcolor = erpworkingmemory('ColorF');
BKGoldcolor = get(0,'DefaultUicontrolBackgroundColor'); % current background color
FORoldcolor = get(0,'DefaultUicontrolForegroundColor'); % current foreground color
oldimage = get(0,'DefaultImageVisible');
set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor,...
        'DefaultUicontrolForegroundColor',ForeERPLABcolor,...
        'DefaultImageVisible','on')
options.Resize      ='on';
options.WindowStyle ='normal';
options.Interpreter ='tex';

% Response
response = inputdlg(prompt,dlg_title,num_lines,def, options);

% put back colors
set(0,'DefaultUicontrolBackgroundColor',BKGoldcolor,...
        'DefaultUicontrolForegroundColor',FORoldcolor,...
        'DefaultImageVisible',oldimage)