% Author: Guanghui Zhang & Steve J. Luck & Andrew Stewart
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Mar. 2023



%%Adpated from:https://www.mathworks.com/matlabcentral/fileexchange/66575-exponentially-modified-gaussian-ex-gaussian-distributions


function pdf = f_exgauss_pdf(x, mu, sigma, tau)
  if license('test', 'Symbolic_Toolbox')
      useVPA = 1; % compute with additional precision
  else
      useVPA = 0;
  end    
  if  tau >0 && sigma > 0 %check for correctness
      % preliminary computations
      if useVPA
        sigmaPerTau = vpa(sigma./tau);         
      else  
        sigmaPerTau = sigma./tau;  
      end  
      muMinusX = mu - x;
      normalPart = 1 - normcdf(muMinusX./sigma + sigmaPerTau);
     
      expPart = muMinusX./tau + (sigmaPerTau.^2)./2;
      if (useVPA)
          pdf = double((1/tau).*normalPart.*exp(expPart));
      else
          if (expPart > 25)
              warning('The combination of the input values may result in numerical instability. Please change your units to make (mu-x)/tau < 25 and sigma/tau < 5. Then please re-run the script')
          end  
          pdf = (1/tau).*normalPart.*exp(expPart);
      end
%       pdf = abs(pdf);
  else
      pdf = zeros(length(x), 1);
  end
  pdf(pdf==Inf) = 0;
end