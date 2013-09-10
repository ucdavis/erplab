% PURPOSE: adds an image (viewer.jpg) viewer button
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

try
      [img,map]    = imread('viewer.tif');
      colormap(map)      
      [row,column] = size(img);      
      p = get(handles.togglebutton_viewer,'Position');      
      w = p(3); % width
      h = p(4); % hight    
      steprow   = ceil(row/(10*h));
      stecolu   = ceil(column/(15*w));
      imgbutton = img(1:steprow:end,1:stecolu:end,:);
      
      set(handles.togglebutton_viewer,'CData',imgbutton);
catch
      set(handles.togglebutton_viewer,'String','VIEWER');
end
