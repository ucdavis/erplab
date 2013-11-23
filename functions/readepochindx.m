% - This function is part of ERPLAB Toolbox -
% PURPOSE: subroutine for pop_averager.m
%          gets epoch indices (per dataset) for selective averaging
%          either from a cell array or a list in a text file
%
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2012

function EPINDX = readepochindx(textarray, option)
if nargin<2
      option = 0; % read from file
end
try
      if option==0
            %
            % open file containing epoch indices
            %
            fid_list = fopen( textarray );
            formcell = textscan(fid_list, '%s');
            eindx  = formcell{:};
            fclose(fid_list);
      elseif option==1 % read from cellstring array
            if ~iscell(textarray)
                  error('ERPLAB says: textarray must be a cellstring array.')
            end
            eindx  = textarray;
      else
            error('ERPLAB says: Option is not valid.')
      end
      
      semcol = find(ismember_bc2(eindx,';'));
      
      if ~isempty(semcol)
            if semcol(end)==length(eindx)
                  semcol = semcol(1:end-1);
            end
            semcol(end+1) = length(eindx)+1; % trick *
            w = 1;
      else
            w=0;
            semcol = length(eindx);
      end
      
      nsc = length(semcol);
      a=1; EPINDX = {[]};
      
      for k=1:nsc
            r   = sprintf('%s  ', eindx{a:semcol(k)-w}); % trick *
            ep  = str2num(r);
            EPINDX{k,:}  = ep;
            a = semcol(k)+1;
      end      
      if isempty([EPINDX{:}]) % just in case
            EPINDX = [];
            return
      end     
catch
      EPINDX = [];
end
