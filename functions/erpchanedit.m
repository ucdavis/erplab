% PURPOSE: loads channel location information into an erpset
%
% FORMAT:
%
% ERP = erpchanedit(ERP, filename);
%
%
% See also borrowchanloc.m
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon && Johanna Kreither
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2013

function [ERP, serror] = erpchanedit(ERP, filename)
serror = 0; % no error
if nargin<1
        help erpchanedit
        return
end
if nargin<2
        filename = '';
end
try
        %
        % Preparing a contraband EEG
        %
        EEGx = eeg_emptyset;
        EEGx.data     = ERP.bindata;
        EEGx.chanlocs = ERP.chanlocs;
        EEGx.nbchan   = ERP.nchan;
        
        %*******************************************************
        % for being compatible with eeglab 11. Nov 20, 2012. JLC
        EEGx.setname    = ERP.erpname;
        EEGx.trials     = ERP.nbin;
        EEGx.pnts   = ERP.pnts;
        EEGx.srate  = ERP.srate;
        EEGx.xmax   = ERP.xmax;
        EEGx.xmin   = ERP.xmin;
        %*******************************************************
        if isempty(filename)
                EEGx = pop_chanedit(EEGx);    % open EEGLAB GUI
        else                
                EEGx = pop_chanedit(EEGx, 'lookup',filename);
        end
                
        valuecmp = structcmp(EEGx.chanlocs, ERP.chanlocs); % confirm changes
        
        if valuecmp==1 % no changes                
                if isfield(EEGx.chanlocs, 'theta') && ~isempty([EEGx.chanlocs.theta])
                        % go back using the current chan loc info
                        return
                else
                        % user cancelled and there is no previous chan loc
                        clear EEGx
                        serror = []; %
                end                
        else
                ERP.chanlocs  = EEGx.chanlocs; % load channel location into ERP structure
                ERP.bindata   = EEGx.data;
                ERP.nchan     = EEGx.nbchan;
        end
catch
        serror = 1; %error found
end