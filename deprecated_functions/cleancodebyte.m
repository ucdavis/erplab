% DEPRECATED...
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon 
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2012

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


% When you get unexpected codes in EEGLAB, from Biosemi recordings for instance, you will
% be able to use cleancodebyte.m in order to ignore either the less significative
% byte (1rst byte) or the most significative byte (2nd byte) from your datasets.
%
% xxxxxxxx xxxxxxxx
% 2nd byte 1rst byte
%
% Example: ignore (clean) the second byte (most significative byte)
% >> EEG = cleancodebyte(EEG,2);
%
% Author: Javier Lopez-Calderon & Johanna Kreither
% Center for Mind and Brain
% University of California, Davis
% April 2009

function EEG = cleancodebyte(EEG,byte)
if ~ismember_bc2(byte,[1 2])
    disp('Error: "BYTE" HAVE TO BE EITHER 1 OR 2')
    return
end

type_binary = cellstr(dec2bin([EEG.event.type]));
nevents     = length(EEG.event);

for i=1:nevents
    currbin = type_binary{i};
    if length(currbin)==16
        if byte==1
            EEG.event(i).type = bin2dec(currbin(1:8)); % ignore first byte, use the 2nd byte
        elseif byte==2
            EEG.event(i).type = bin2dec(currbin(9:16)); % ignore second byte, use the 1rst byte
        end
    else
        fprintf('Event code %g (%g) is a one byte number', i, EEG.event(i).type);
    end
end

