%%This function is used to create/save the parameters applied in each step.




function S_OUT = createrplabstudioparameters(S_IN,varargin)
if isempty(varargin)
    S_OUT = [];
    return;
end


S_OUT = S_IN;
current_var = varargin{1};

current_var_field = current_var{1};

for Numoffilename1 = 1:length(current_var)-1
    current_var1{Numoffilename1} = current_var{Numoffilename1+1};
end

for Numoffilename = 1:floor(length(current_var)/2)
    S_field_fir.(current_var1{2*(Numoffilename-1)+1}) = current_var1{2*Numoffilename};
end

S_OUT.(current_var_field) = S_field_fir;

return;