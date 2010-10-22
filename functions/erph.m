% Javier
function erph
try
        ALLERPCOM = evalin('base', 'ALLERPCOM');
catch
        ALLERPCOM = '';
end
disp(char(ALLERPCOM))
return