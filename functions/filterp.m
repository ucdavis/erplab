% PURPOSE: subroutine for pop_filterp.m
%
% FORMAT
%
% ERP = filterp(ERP, chanArray, locutoff, hicutoff, filterorder, typef, remove_dc);
%
%     ERP         - input ERPset
%     chanArray   - channel(s) to filter
%     locutoff    - lower edge of the frequency pass band (Hz)  {0 -> lowpass}
%     hicutoff    - higher edge of the frequency pass band (Hz) {0 -> highpass}
%     filterorder - length of the filter in points {default 3*fix(srate/locutoff)}
%     typef       - type of filter: 0=means IIR Butterworth;  1 = means FIR
%     remove_dc   - remove dc offset before filtering. 1 yes; 0 no
%
%
%     Outputs:
%     ERP         - filter ERPset
%
%
% See also filter_tf.m filtfilt.m removedc.m pop_filterp.m
%
%
% *** This function is part of ERPLAB Toolbox ***
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

function ERP = filterp(ERP, chanArray, locutoff, hicutoff, filterorder, typef, remove_dc)

if nargin < 1
        help filterp
        return
end
if exist('filtfilt','file') ~= 2
        disp('filterp error: cannot find the Signal Processing Toolbox');
        return
end
if isempty(ERP.bindata)
        disp('filterp error: cannot filter an empty erpset')
        return
end
if nargin < 7
        disp('filterp error: please, enter all arguments!')
        return
end
if ERP.pnts <= 3*filterorder
        msgboxText =  'Error: The length of the data must be more than three times the filter order.';
        title = 'ERPLAB: filterp(), filtfilt constraint';
        errorfound(msgboxText, title);
        return
end
if locutoff == 0 && hicutoff == 0,
        msgboxText =  'Error: What????  low cutoff == 0 && high cutoff == 0?';
        title = 'ERPLAB: filterp(), Cutoff frequency';
        errorfound(msgboxText, title);
        return
end

chanArray = unique_bc2(chanArray);   % does not allow repeated channels
fnyquist  = 0.5*ERP.srate;       % half sample rate
pnts      = size(ERP.bindata,2);
numchan   = length(chanArray);

if numchan>ERP.nchan
        msgboxText =  'Error: You have selected more channels than are contained within your data!';
        title = 'ERPLAB: filterp() error:';
        errorfound(msgboxText, title);
        return
end

nbin = ERP.nbin;
fprintf('Channels to be filtered : %s\n\n', vect2colon(chanArray, 'Delimiter', 'on'));

if locutoff >= fnyquist
        error('ERPLAB says: errot at filterp(). Low cutoff frequency cannot be >= srate/2');
end
if hicutoff >= fnyquist
        error('ERPLAB says: errot at filterp().High cutoff frequency cannot be >= srate/2');
end
if ~typef && filterorder*3 > pnts          % filtfilt restriction
        fprintf('filterp: filter order too high');
        error('ERPLAB says: errot at filterp(). Samples must be at least 3 times the filter order.');
end
if locutoff >0  % option in order to remove dc value is only for high-pass filtering
        if remove_dc
                disp('Removing DC bias from ERPs...')
                for i = 1:nbin
                        auxdata = ERP.bindata(chanArray,:,i);
                        ERP.bindata(chanArray,:,i) = detrend(auxdata', 'constant')';
                end
                fprintf('\n')
        end
end

[b, a, labelf, v] = filter_tf(typef, filterorder, hicutoff, locutoff, ERP.srate);

if ~v  % something is wrong or turned off
        msgboxText =  'filterp() error: Wrong parameters for filtering.';
        title = 'ERPLAB: filterp():';
        errorfound(msgboxText, title);
        return
end

disp([labelf ' filtering input data, please wait...'])

for j=1:nbin        
        if size(b,1)>1                
                if strcmpi(labelf,'Band-Pass')
                        % Butterworth bandpass (cascade)
                        ERP.bindata(chanArray,:,j) = filtfilt(b(1,:),a(1,:), ERP.bindata(chanArray,:,j)')';
                        ERP.bindata(chanArray,:,j) = filtfilt(b(2,:),a(2,:), ERP.bindata(chanArray,:,j)')';
                else
                        %Butterworth Notch (parallel)
                        datalowpass   = filtfilt(b(1,:),a(1,:), ERP.bindata(chanArray,:,j)')';
                        datahighpass  = filtfilt(b(2,:),a(2,:), ERP.bindata(chanArray,:,j)')';                        
                        ERP.bindata(chanArray,:,j) = datalowpass + datahighpass;
                end
        else
                % Butterworth lowpass)
                % Butterworth highpass
                % FIR lowpass
                % FIR highpass
                % FIR bandpass
                % FIR notch
                % Parks-McClellan Notch                
                ERP.bindata(chanArray,:,j) = filtfilt(b,a, ERP.bindata(chanArray,:,j)')';
        end
end

%
% Make zero the standard deviation for filtered channels (temporary solution)
%
ERP = clear_dq(ERP);
if isfield(ERP, 'binerror')
        if ~isempty(ERP.binerror)
                
                if numchan<ERP.nchan
                        ERP.binerror(chanArray,:,:) = zeros(numchan, pnts, nbin);
                else
                        ERP.binerror = []; % if ALL channels were filtered --> ERP.binerror = [];
                end
        end
end

ERP.isfilt = 1;
