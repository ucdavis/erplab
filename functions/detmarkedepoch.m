% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

function indexmepoch = detmarkedepoch(EEG) 

F = fieldnames(EEG.reject);
sfields1 = regexpi(F, '\w*E$', 'match');
sfields2 = [sfields1{:}];
fields4reject  = regexprep(sfields2,'E','');
index = zeros(1,EEG.trials);
nf = length(fields4reject);
i=1;
while i<=nf
      if ~isempty(EEG.reject.(fields4reject{i}))
            index = EEG.reject.(fields4reject{i}) | index;
      end
      i=i+1;      
end

indexmepoch = find(index); % index of marked epochs