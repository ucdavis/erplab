%
%Usage:
%
%>> ERP  = pop_filterp(ERP, chanArray, highpasscutoff, lowpasscutoff, filterorder, typefilter, removemean)
%
%     ERP            - input erpset
%     chanArray      - channel(s) to filter
%     highpasscutoff - lower edge of the frequency pass band (Hz)  {0 -> lowpass} (set highpass filter)
%     lowpasscutoff  - higher edge of the frequency pass band (Hz) {0 -> highpass} (set lowpass filter)
%     filterorder    - length of the filter in points {default 3*fix(srate/locutoff)}
%     typef          - type of filter. 'butter'=IIR Butterworth,  'fir'=windowed linear-phase FIR, 'notch'=PM Notch
%
%     Outputs:
%     EEG         - output dataset
%
% Author: Javier Lopez-Calderon & Steven Luck
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

function [ERP erpcom] = pop_filterp(ERP, chanArray, highpasscutoff, lowpasscutoff, filterorder, typefilter, removemean)

erpcom = '';

if nargin < 1
      help pop_filterp
      return
end

if isempty(ERP) %(ERP.bindata)
      msgboxText{1} =  'cannot filter an empty ERP dataset';
      title        = 'ERPLAB: pop_filterp() error:';
      errorfound(msgboxText, title);
      return
end

if ~isfield(ERP, 'bindata')
      msgboxText{1} =  'cannot filter an empty ERP dataset';
      title = 'ERPLAB: pop_filterp() error:';
      errorfound(msgboxText, title);
      return
end

if isempty(ERP.bindata)
      msgboxText{1} =  'cannot filter an empty ERP dataset';
      title = 'ERPLAB: pop_filterp() error:';
      errorfound(msgboxText, title);
      return
end

if nargin<3  %with GUI
      
      answer = basicfilterGUI2(ERP); % open a GUI
      
      if isempty(answer)
            disp('User selected Cancel')
            return
      end
      
      highpasscutoff = answer{1};
      lowpasscutoff  = answer{2};
      filterorder    = answer{3};
      chanArray      = answer{4};
      typefilter     = answer{5};
      removemean     = answer{6};
end

if mod(filterorder,2)~=0
      error('ERPLAB says: filter order must be an even number because of the forward-reverse filtering.')
end

if ERP.pnts <= 3*filterorder
      msgboxText{1} =  'The length of the data must be more than three times the filter order.';
      title = 'ERPLAB: pop_filterp() & filtfilt constraint';
      errorfound(msgboxText, title);
      return
end

[ax tt] = ismember(lower(typefilter),{'butter' 'fir' 'notch'});

if tt>0
      typefnum = tt-1;
else
      error('ERPLAB says: Unrecognizable filter type. See help pop_filterp')
end

ERP = filterp(ERP, chanArray, highpasscutoff, lowpasscutoff, filterorder, typefnum, removemean);
ERP.saved  = 'no';

if ~isfield(ERP, 'binerror')
      ERP.binerror = [];
end

if nargin==1
      [ERP issave]= pop_savemyerp(ERP,'gui','erplab');
      
      if issave
            erpcom = sprintf( '%s = pop_filterp( %s, %s, %s, %s, %s, ''%s'', %s);', inputname(1), inputname(1),...
                  num2str(vect2colon(chanArray)), num2str(highpasscutoff), num2str(lowpasscutoff),...
                  num2str(filterorder), typefilter, num2str(removemean));
            try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
            return
      else
            disp('Warning: Your ERP structure has not yet been saved')
            disp('user canceled')
            return
      end
end
