% decvalue = flag2dec(inputs)
%
% Example. Reset "artifact detection" flags 3 and 7, and also "user" flags 1,2, and 3
%
%  decvalue = flag2dec('ArtifactFlag', [3 7], 'UserFlag', [1 2 3])
%
% See also dec2flag
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2013
%

function decvalue = flag2dec(varargin)

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
% option(s)
p.addParamValue('ArtifactFlag', [], @isnumeric);
p.addParamValue('UserFlag', [], @isnumeric);
p.parse(varargin{:});
artflag  = p.Results.ArtifactFlag;
usflag   = p.Results.UserFlag;
fullflag = repmat('0',1,16);
if ~isempty(artflag)
        fullflag(artflag) = '1';      
end
if ~isempty(usflag)
        fullflag(8 + usflag) = '1';       
end
decvalue = bin2dec(fliplr(fullflag));