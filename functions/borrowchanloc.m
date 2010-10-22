% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% ERPLAB Toolbox
% Copyright © 2007 The Regents of the University of California
% Created by Javier Lopez-Calderon and Steven Luck
% Center for Mind and Brain, University of California, Davis,
% javlopez@ucdavis.edu, sjluck@ucdavis.edu
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
function ERP = borrowchanloc(ERP)

if isfield(ERP.chanlocs,'theta')
      chanok = {ERP.chanlocs.theta};
      exchanArray = find(cellfun('isempty',chanok));
      chfound = 1;
else
      exchanArray = [];
      chfound = 0;
end

ERPaux = ERP;

if isempty(exchanArray) && chfound==1
      fprintf('Channel locations were successfuly found!\n');
      
else
      %
      % Preparing a contraband EEG
      %
      EEGx.data     = ERP.bindata;
      EEGx.chanlocs = ERP.chanlocs;
      EEGx.nbchan   = ERP.nchan;
      EEGx = pop_chanedit(EEGx);    % open EEGLAB GUI
      ERP.chanlocs  = EEGx.chanlocs; % load channel location into ERP structure
      ERP.bindata   = EEGx.data;
      ERP.nchan     = EEGx.nbchan;
      
      if isfield(ERP.chanlocs, 'theta')
            
            chanok = {ERP.chanlocs.theta};
            exchanArray = find(cellfun('isempty',chanok));
            
            if ~isempty(exchanArray)
                  
                  selchannels = find(~ismember(1:ERP.nchan,exchanArray)); %selected channels
                  nsch = length(selchannels);
                  auxd = ERP.bindata(selchannels,:,:);
                  ERP.bindata = [];
                  ERP.bindata(1:nsch,:,:) = auxd;
                  ERP.nchan  = nsch;
                  namefields = fieldnames(ERP.chanlocs);
                  nfn = length(namefields);
                  
                  for ff=1:nfn
                        auxfield{ff} = {ERP.chanlocs(selchannels).(namefields{ff})};
                  end
                  
                  ERP.chanlocs=[];
                  
                  for ff=1:nfn
                        [ERP.chanlocs(1:nsch).(namefields{ff})] = auxfield{ff}{:};
                  end
                  if length(exchanArray)==1
                        fprintf('Channel %g was skiped\n', exchanArray)
                  elseif length(exchanArray)>1
                        fprintf('Channels %g were skiped\n', exchanArray)
                  end
            end
            
            [ERP issave] = pop_savemyerp(ERP,'gui','erplab');
            
            if ~issave
                  ERP  = ERPaux;
                  return
            end
            
            fprintf('\nChannel locations were successfuly loaded!\n');
      else
            msgboxText{1} =  'Error: pop_scalplot could not find channel locations info.';
            msgboxText{2} =  'Hint: Identify channel(s) without location looking at';
            msgboxText{3} = 'command window comments (Channel lookup). Try again excluding this(ese) channel(s).';
            tittle = 'ERPLAB:  error:';
            errorfound(msgboxText, tittle);
            return
      end
end