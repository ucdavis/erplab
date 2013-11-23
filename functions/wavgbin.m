% PURPOSE: For Bin Operations GUI/scripting purposes
%          weight-averages bins
%
% FORMAT
%
% waverage = wavgbin(ERP, bop)
% However, at syntax is as follows:  bin = wavgbin(bop)
% where bop are the bin indices to average.
%
% Example:  b4 = wavgbin( 5:12) label weighted bin
%
%
% *** This function is part of ERPLAB Toolbox ***
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

% Usage
% >> waverage = wavgbin(ERP, bop)
%
% For Bin Operations GUI/scripting purposes
%
% Author: Javier
%

function  waverage = wavgbin(ERP, bop)

if nargin<1
        help wavgbin
        return
end
if nargin<2
        error('ERPLAB says: You must specify bin indexes to be averaged!')
end
if ~iserpstruct(ERP)
        error('ERPLAB says: Your data structure is not an ERP structure!')
end
if ischar(bop)
        bop = str2num(char(regexp(bop,'\d+','match')'))';
end

binarray = unique_bc2(bop);

if length(binarray)~=length(bop)
        fprintf('\n*** WARNING: Repeated bins were ignored.\n\n')
end
if length(binarray)<2
        error('ERPLAB says: You must specify 2 bin indexes at leat!')
end
if max(binarray)>ERP.nbin
        error('ERPLAB says: Some specified bins do not exist!')
end

wsumerp = 0;

for i=1:length(binarray)
        wsumerp =  wsumerp + ERP.ntrials.accepted(binarray(i))*ERP.bindata(:,:,binarray(i));
end

sumgood = sum(ERP.ntrials.accepted(binarray));

if sumgood>0
        waverage = wsumerp/sumgood;
else
        waverage = wsumerp;
end

