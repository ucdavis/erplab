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

function [p1 p2 checkw] = window2sample(ERPLAB, testwindow, fs)

toffsa   = abs(round(ERPLAB.xmin*fs))+1;
pnts     = ERPLAB.pnts;
checkw   = 0; % no error by default

if ischar(testwindow)
        if ~strcmpi(testwindow,'all') && ~strcmpi(testwindow,'pre') && ~strcmpi(testwindow,'post')
                
                internum = str2double(testwindow)/1000;  %ms to sec
                
                if length(internum)~=2
                        disp('Error:  erp_artmwppth will not be performed. Check your parameters.')
                        checkw = 1;
                        return
                end
                p1 = round(internum(1)*fs)+ toffsa;      %sec to samples
                p2 = round(internum(2)*fs) + toffsa;     %sec to samples
        end
        
        if strcmpi(testwindow,'pre')
                p2 = find(ERPLAB.times==0);    % zero-time locked
                p1 = 1;
        elseif strcmpi(testwindow,'post')
                p1 = find(ERPLAB.times==0);    % zero-time locked
                p2 = pnts;
        elseif strcmpi(testwindow,'all')
                p2 = pnts;  % full epoch
                p1 = 1;
        end
        
else
        if length(testwindow)~=2
                disp('Error:  erp_artmwppth will not be performed. Check your parameters.')
                checkw = 1;
                return
        end
        
        testwindow = testwindow/1000;  %ms to sec
        p1 = round(testwindow(1)*fs) + toffsa;     %sec to samples
        p2 = round(testwindow(2)*fs) + toffsa;    %sec to samples
end

if p1<-1
        msgboxText{1} =  'ERROR: The onset of your Test Period is more than 2 samples of difference with the real onset';
        tittle = 'ERPLAB: erp_artmwppth()';
        errorfound(msgboxText, tittle);
        return
end
if p2>pnts+2
        msgboxText{1} =  'ERROR: The offset of your Test Period is more than 2 samples of difference with the real offset';
        tittle = 'ERPLAB: erp_artmwppth()';
        errorfound(msgboxText, tittle);
        return
end

if p1<1
        p1 = 1;
end

if p2>pnts
        p2 = pnts;
end

epochwidth = p2-p1+1; % choosen epoch width in number of samples

if epochwidth>pnts
        checkw = 1; %error found
        return
elseif epochwidth<2
        checkw = 2; %error found
        return
end