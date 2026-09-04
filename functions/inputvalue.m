function [response] = inputvalue(prompt,dlg_title,num_lines,def)

BackERPLABcolor = erpworkingmemory('ColorB');
if isempty(BackERPLABcolor) || numel(BackERPLABcolor)~=3 || any(BackERPLABcolor(:)>1) || any(BackERPLABcolor(:)<0) 
  BackERPLABcolor = [0.7020 0.77 0.85];    
end
ForeERPLABcolor = erpworkingmemory('ColorF');
if isempty(ForeERPLABcolor) || numel(ForeERPLABcolor)~=3 || any(ForeERPLABcolor(:)>1) || any(ForeERPLABcolor(:)<0) 
    ForeERPLABcolor = [0 0 0];
end
oldimage = get(0,'DefaultImageVisible');
erplab_dialogcolors(BackERPLABcolor, ForeERPLABcolor);
set(0,'DefaultImageVisible','on')
options.Resize      ='on';
options.WindowStyle ='normal';
options.Interpreter ='tex';

% Response
response = inputdlg(prompt,dlg_title,num_lines,def, options);

% put back colors
erplab_dialogcolors();
set(0,'DefaultImageVisible',oldimage)