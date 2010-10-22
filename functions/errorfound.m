function button = errorfound(message, title, bkgrncolor, showfig)

if nargin<4
        showfig = 1; % 1 = yes, show fig on error message
end
if nargin<3
        bkgrncolor = [1 0 0];
end
[IconData IconCMap]= loadrandimage('logoerplaberror1.jpg','logoerplaberror2.jpg',...
        'logoerplaberror3.jpg', 'logoerplaberror4.jpg', 'logoerplaberror5.jpg');
button = errorGUI(message, title, IconData, IconCMap, bkgrncolor, showfig);
return


