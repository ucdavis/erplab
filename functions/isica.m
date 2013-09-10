% PURPOSE: detects ICA process in a dataset
%
% FORMAT
%
% value = isica(EEG);
%
% if value = 1 then the EEG dataset is ICA-ed. Otherwise, value = 0
%
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% July 7, 2011

function value = isica(EEG)
value     = 0; % no ica-ed file by default
if nargin<1
        help isica
        return
end
icafields = {'icaact','icawinv','icasphere','icaweights','icachansind','specicaact','icasplinefile'};
nif       = length(icafields);
for k=1:nif
        if isfield(EEG, icafields{k}) && ~isempty(EEG.(icafields{k}))
                value = 1; % ica-ed file detected
                break
        end
end
return