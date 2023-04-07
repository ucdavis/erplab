% This function is written to check if the string of interest exists in the parent structure
%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA
%Feb. 2022

% ERPLAB Studio


function count = f_findstring(Parent_Structure,String_checked)

if isempty(Parent_Structure)
    msgboxText =  'Parent structure is empty!';
    title = 'EStudio: findstring()';
    errorfound(msgboxText, title);
    return;
end

if isempty(String_checked)
    msgboxText =  'The string that to be checked is empty!';
    title = 'EStudio: findstring()';
    errorfound(msgboxText, title);
    return;
end
field_Names =  fieldnames(Parent_Structure);

if isempty(field_Names)
    msgboxText =  'No field name was found in the parent structure!';
    title = 'EStudio: findstring()';
    errorfound(msgboxText, title);
    return;
end

count = 0;
for Numoffieldname = 1:length(field_Names)
    code1 = strcmp(field_Names{Numoffieldname},String_checked);
    if code1 ==1
        count =count+1;
    end
end

return;