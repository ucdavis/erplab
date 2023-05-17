% PURPOSE: Removes the best straight-line  fit  from  epoched-EEG  or  averaged  ERP data.
%          Matlab: detrend() computes the least-squares fit of a straight line to the data
%          (whole epoch or interval) and subtracts the resulting function  from  the  data
%          (whole epoch).  To obtain the  equation  of the straight-line fit, use polyfit.
%
%
% FORMAT:
%
% ERP = lindetrend( ERP, interv);
%
% or
%
% EEG = lindetrend( EEG, interv);
%
%
% INPUTS:
%
% EEG/ERP       - epoched dataset or erpset
% interv        - time interval in ms to compute the least-square fit of a straight line to the data in this interval.
%                 The fitted straight line will be extrapolated until having as many points as that  whole  data, then
%                 this straight line will be substracted from the whole data.
%                 "interval" can also be a string like 'pre', 'post' or 'all'
%
% OUTPUT
%
% EEG/ERP       - epoched dataset or erpset linearly detrended
%
%
% Examples:
%
% EEG = lindetrend( EEG, 'pre');      % detrend each whole epoch accordind the trend at the pre-stimulus interval
% ERP = lindetrend( ERP, 'post');     % detrend each whole epoch accordind the trend at the post-timulus interval
% EEG = lindetrend( EEG, 'all');      % detrend each whole epoch accordind the trend at the whole epoch
% ERP = lindetrend( ERP, '-500 300'); % detrend each whole epoch accordind the trend between -500 and 300 ms
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% January 25th, 2011

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

function ERPLAB = lindetrend( ERPLAB, interv)

if nargin<1
        help lindetrend
end
if iseegstruct(ERPLAB)
        if isempty(ERPLAB.epoch)
                error('ERPLAB says: lindetrend() only works with epoched data!')
        end
        ntrial = ERPLAB.trials;
        pnts   = ERPLAB.pnts;
        datafield = 'data';
elseif iserpstruct(ERPLAB)
        ntrial = ERPLAB.nbin;
        pnts   = ERPLAB.pnts;
        datafield = 'bindata';
else
        error('ERPLAB says: error at lindetrend(). Invalid inputs')
end
if isfield(ERPLAB, 'datatype')
    datatype = ERPLAB.datatype;
else % FFT
    datatype = 'ERP';
end
if strcmpi(datatype, 'ERP')
    kktime = 1000;
else
    kktime = 1;
end

if strcmpi(interv,'pre')
%         bb = find(ERPLAB.times==0);    % zero-time locked
        [xxx, bb, latdiffms] = closest(ERPLAB.times, 0);%%GH 2022
        aa =1;
elseif strcmpi(interv,'post')
%         aa = find(ERPLAB.times==0);    % zero-time locked
        [xxx, aa, latdiffms] = closest(ERPLAB.times, 0);%%GH 2022
        bb = pnts;
elseif strcmpi(interv,'all')
        bb = pnts;  % full epoch
        aa = 1;
else
        toffsa    = abs(round(ERPLAB.xmin*ERPLAB.srate)) + 1;
        
        if ischar(interv)
                inte2num  = str2num(interv); % interv in ms
        else
                inte2num  = interv;
        end
        
        aa = round(inte2num(1)*ERPLAB.srate/kktime) + toffsa   ;   % ms to samples
        bb = round(inte2num(2)*ERPLAB.srate/kktime) + toffsa   ;   % ms to samples
        
        if (bb-aa<5 && bb-aa>pnts) || aa<1 || bb>pnts
                msgboxText = ['Unappropriated time interval: [%g  %g]\n'...
                        'lindetrend() was ended.\n'];
                title = 'ERPLAB: lindetrend() error';
                errorfound(sprintf(msgboxText,a,b), title);
                return
        end
end

fprintf('linear detrending...\n');

if aa==1 && bb==length(ERPLAB.times)
        for i = 1:ntrial
                auxdata = ERPLAB.(datafield)(:,:,i);
                ERPLAB.(datafield)(:,:,i) = detrend(auxdata')';                    % fast full interval detrending
        end
else
        for i = 1:ntrial
                datadet   = detrend(ERPLAB.(datafield)(:,aa:bb,i)', 'linear')';    % data detrended by segments
                difdata   = ERPLAB.(datafield)(:,aa:bb,i) - datadet;               % recovers straight lines
                recutrend = interp1(aa:bb,difdata',1:pnts,'pchip');                % extrapolates from interval-based trending for all channel
                if size(recutrend,1)>1
                        recutrend = recutrend';
                end
                ERPLAB.(datafield)(:,:,i) = ERPLAB.(datafield)(:,:,i)-recutrend;  % detrends full epochs
        end
end
