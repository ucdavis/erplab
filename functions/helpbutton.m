% PURPOSE: adds an image (erplab_help.jpg) to ERPLAB GUIs' help button
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009
try
      [img,map]    = imread('erplab_help_sm.jpg');
      colormap(map)      
      [row,column] = size(img);      
      p = get(handles.pushbutton_help,'Position');      
      w = p(3); % width
      h = p(4); % hight    
      steprow   = ceil(row/(10*h));
      stecolu   = ceil(column/(16*w));
      
      
      imgbutton = img(1:steprow:end,1:stecolu:end,:);
      
      set(handles.pushbutton_help,'CData',imgbutton);
      set(handles.pushbutton_help,'tooltipString','Get help from the ERPLAB manual');
catch
      set(handles.pushbutton_help,'String','Help');
end
