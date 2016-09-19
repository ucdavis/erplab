% DEPRECATED...
%
%
%
% EEG = lindetrend( EEG, interv);
%
% lindetrend():Removes the best straight-line fit from epoched EEG data.
% Matlab: detrend() computes the least-squares fit of a straight
% line to the data (whole epoch or interval) and subtracts the resulting function
% from the data (whole epoch).
% To obtain the equation of the straight-line fit, use polyfit.
%
% Examples:
%
% >> EEG = lindetrend( EEG, 'pre');
% >> EEG = lindetrend( EEG, 'post');
% >> EEG = lindetrend( EEG, 'all');
% >> EEG = lindetrend( EEG, '-500 300');
%
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

function ERP = lindetrenderp( ERP, interv)

if nargin<1
        help lindetrenderp
end
datatype = checkdatatype(ERP);
if strcmpi(datatype, 'ERP')
    kktime = 1000;
    srate = ERP.srate;
else
    kktime = 1;
    srate = ERP.pnts/ERP.xmax;
end

nbin = ERP.nbin;
pnts   = ERP.pnts;

if strcmpi(interv,'pre')
        bb = find(ERP.times==0);    % zero-time locked
        aa =1;
elseif strcmpi(interv,'post')
        aa = find(ERP.times==0);    % zero-time locked
        bb = pnts;
elseif strcmpi(interv,'all')
        bb = pnts;  % full epoch
        aa = 1;
else        
        toffsa    = abs(round(ERP.xmin*srate)) + 1;
        inte2num  = str2double(interv); % interv in ms
        aa = round(inte2num(1)*srate/kktime) + toffsa   ;   % ms to samples
        bb = round(inte2num(2)*srate/kktime) + toffsa   ;   % ms to samples
        
        if (bb-aa<5 && bb-aa>pnts) || aa<1 || bb>pnts
                fprintf('lindetrenderp error: unappropriated time interval: %s\n', interv);
                fprintf('lindetrenderp ended\n');
                return
        end
end

fprintf('linear detrending ERP...\n');

if aa==1 && bb==length(ERP.times)
        for i = 1:nbin
                auxdata = ERP.bindata(:,:,i);
                ERP.bindata(:,:,i) = detrend(auxdata')';                    % fast full interval detrending
        end
else
        for i = 1:nbin
                datadet   = detrend(ERP.bindata(:,aa:bb,i)', 'linear')';    % data detrended by segments
                difdata   = ERP.bindata(:,aa:bb,i) - datadet;               % recovers straight lines
                recutrend = interp1(aa:bb,difdata',1:pnts,'pchip');         % extrapolates from interval-based trending for all channel
                ERP.bindata(:,:,i) = ERP.bindata(:,:,i)-recutrend';         % detrends full epochs
        end
end