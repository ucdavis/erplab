% Author: Javier Lopez Calderon
function v = isdoublep(x)

try
      if strcmpi(class(x),'double')
            v=1;
      else
            v=0;
      end
catch
      v=0;
end

