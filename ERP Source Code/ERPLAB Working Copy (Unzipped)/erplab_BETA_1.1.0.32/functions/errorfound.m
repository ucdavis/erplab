function button = errorfound(message, title, bkgrncolor, showfig)

%BackERPLABcolor = [ 0.73 0 0];  % bloody...

%disp(char(message))
if nargin<4
        showfig = 1; % 1 = yes, show fig on error message
end
if nargin<3
        bkgrncolor = [1 0 0];
end
%oldcolorB = get(0,'DefaultUicontrolBackgroundColor');
%oldcolorF = get(0,'DefaultUicontrolForegroundColor');
%set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
%set(0,'DefaultUicontrolForegroundColor', [1 1 1])
[IconData IconCMap]= loadrandimage('logoerplaberror1.jpg','logoerplaberror2.jpg',...
        'logoerplaberror3.jpg', 'logoerplaberror4.jpg', 'logoerplaberror5.jpg');
%f = msgbox(message,title, 'custom',IconData,IconCMap);
%set(0,'DefaultUicontrolBackgroundColor',oldcolorB)
%set(0,'DefaultUicontrolForegroundColor',oldcolorF)
%waitfor( f, 'userdata');

button = errorGUI(message, title, IconData, IconCMap, bkgrncolor, showfig);


