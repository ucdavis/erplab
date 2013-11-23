% PURPOSE: removes any channel without channel location information to avoid upseting EEGLAB's pop_chanedit function
%
% FORMAT:
%
% [ERP serror] = rememptychanloc(ERP);
%
%
% See also borrowchanloc.m
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2013

function [ERP serror] = rememptychanloc(ERP)
serror = 0; % ok
if isfield(ERP.chanlocs, 'theta')
        try
                chanok = {ERP.chanlocs.theta};
                exchanArray = find(cellfun('isempty',chanok));
                
                if ~isempty(exchanArray)                        
                        selchannels = find(~ismember_bc2(1:ERP.nchan,exchanArray)); %selected channels
                        nsch = length(selchannels);
                        auxd = ERP.bindata(selchannels,:,:);
                        ERP.bindata = [];
                        ERP.bindata(1:nsch,:,:) = auxd;
                        ERP.nchan   = nsch;
                        namefields  = fieldnames(ERP.chanlocs);
                        nfn = length(namefields);
                        auxfield = {''};
                        
                        for ff=1:nfn
                                auxfield{ff} = {ERP.chanlocs(selchannels).(namefields{ff})};
                        end
                        
                        ERP.chanlocs=[];
                        
                        for ff=1:nfn
                                [ERP.chanlocs(1:nsch).(namefields{ff})] = auxfield{ff}{:};
                        end
                        if length(exchanArray)==1
                                fprintf('Channel %g was skiped\n', exchanArray)
                        elseif length(exchanArray)>1
                                fprintf('Channels %g were skiped\n', exchanArray)
                        end
                end
        catch
                serror = 1; % error found
        end
else
        serror = 2; % channel location info was not found
end