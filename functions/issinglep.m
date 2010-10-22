% Author: Javier Lopez Calderon
function v = issinglep(x)

try
      if strcmpi(class(x),'single')
            v=1;
      else
            v=0;
      end
catch
      v=0;
end

