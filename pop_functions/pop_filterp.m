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
%     ERP         - output dataset
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

function [ERP erpcom] = pop_filterp(ERP,  chanArray, locutoff, hicutoff, filterorder, typef, remove_dc)

erpcom = '';


if exist('filtfilt','file') ~= 2
      msgboxText =  'Cannot find the signal processing toolbox';
      title = 'ERPLAB: pop_filterp() error';
      errorfound(msgboxText, title);
      return
end
if nargin < 1
      help pop_filterp
      return
end
if isempty(ERP(1).bindata)
      msgboxText =  'Cannot filter an empty erpset';
      title = 'ERPLAB: pop_filterp() error';
      errorfound(msgboxText, title);
      return
end

if nargin==1
      
      nchan = ERP.nchan;    
      defx = {0 30 2 1:nchan 'butter' 0 []};
      def  = erpworkingmemory('pop_filterp');
      
      if isempty(def)
            def = defx;
      else                        
            def{4} = def{4}(ismember(def{4},1:nchan));
      end      
      
      %
      % Opens a GUI
      %
      answer = basicfilterGUI2(ERP, def);
      
      if isempty(answer)
            disp('User selected Cancel')
            return
      end
      
      locutoff    = answer{1}; % for high pass filter
      hicutoff    = answer{2}; % for low pass filter
      filterorder = answer{3};
      chanArray   = answer{4};
      typef       = answer{5};
      remove_dc   = answer{6};
      %boundary    = answer{7};            
      erpworkingmemory('pop_filterp', answer(:)');   
      
else      
      if nargin>1 && nargin<4
            error('ERPLAB says: error at pop_filterp(). You have to specify 4 inputs, at least.')
      end
      if nargin<8
            boundary  = [];
      end
      if nargin<7
            remove_dc = 0;
      end
      if nargin<6
            typef = 'butter'; %butterworth
      end
      if nargin<5
            filterorder = 2;
      end
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

numchan = length(chanArray);
iserrch = 0;

if iserpstruct(ERP) 
      if numchan>ERP.nchan
            iserrch = 1;
      end
else
      msgboxText =  ['Unknow data structure.\n'...
            'pop_filterp() only works with ERP structure.'];
      title = 'ERPLAB: pop_filterp() error:';
      errorfound(sprintf(msgboxText), title);
      return
end

if iserrch
      msgboxText =  'You do not have such amount of channels in your data!';
      title = 'ERPLAB: pop_filterp() error:';
      errorfound(msgboxText, title);
      return
end

[ax tt] = ismember(lower(typef),{'butter' 'fir' 'notch'});

if tt>0
      typefnum = tt-1;
else
      error('ERPLAB says: Unrecognizable filter type. See help pop_filterp')
end
if locutoff == 0 && hicutoff == 0
      disp('I beg your pardon?')
      return
end

options = { chanArray, locutoff, hicutoff, filterorder, typefnum, remove_dc};

% [ERP ferror] = basicfilter( ERP, options{:});

ERP = filterp(ERP, options{:});
ERP.saved  = 'no';

if ~isfield(ERP, 'binerror')
      ERP.binerror = [];
end

chanArraystr = vect2colon(chanArray);

if nargin==1
      [ERP issave]= pop_savemyerp(ERP,'gui','erplab');
      
      if issave
            erpcom = sprintf( '%s = pop_filterp( %s, %s, %s, %s, %s, ''%s'', %s);', inputname(1), inputname(1),...
                  num2str(vect2colon(chanArray)), num2str(locutoff), num2str(hicutoff),...
                  num2str(filterorder), lower(typef), num2str(remove_dc));
            try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
            return
      else
            disp('Warning: Your ERP structure has not yet been saved')
            disp('user canceled')
            return
      end
end