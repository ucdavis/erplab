% DEPRECATED...
%
%

function pirata(clavein)

if isnumeric(clavein)
      return
end
switch clavein(1)
      case 'A'
            %clave = 'A12212007';
            a = erpworkingmemory('pop_averager');
            if isempty(a)
                  a = {1 1 1 1 clavein};
            else
                  a{5} = clavein;
            end            
            erpworkingmemory('pop_averager', a);
end
