% PURPOSE: holds the ERP structure in EEGLAB's pop_chanedit function in order to load channel location information.
%
% FORMAT:
%
% ERP = borrowchanloc(ERP)
%
% INPUT:
%
% ERP        - input ERPset
%
%
% OUTPUT:
%
% ERP        - ERPset having channel location information.
%
%
% EXAMPLE: Get the baseline value for a window of -200 to 0 ms, at bin 4, channel 23
%
% blv = blvalue(ERP, 23, 4, [-200 0])
%
%
% See also geterpvalues.m
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

function [ERP, serror] = borrowchanloc(ERP, chanlocfile, option)
serror = 0; % all ok
if nargin<1
        help borrowchanloc
        return
end
if nargin<3
        option = 0; % do not open gui for saving
end
if nargin<2
        chanlocfile = ''; % no chan loc file
end
ERPaux = ERP;
if isempty(chanlocfile)
        if isfield(ERP.chanlocs,'theta') && ~isempty([ERP.chanlocs.theta])
                chanok = {ERP.chanlocs.theta};
                exchanArray = find(cellfun('isempty',chanok));
                chfound = 1;                
        else
                exchanArray = [];
                chfound = 0;
        end
        if isempty(exchanArray) && chfound==1
                fprintf('Channel location info was successfuly found!\n');
                return
        elseif ~isempty(exchanArray) && chfound==1
                if length(exchanArray)>=ERP.nchan
                        [ERP, serror] = erpchanedit(ERP);
                        if ~isempty(serror) && serror~=1
                                [ERP, serror] = rememptychanloc(ERP);
                        end                        
                else
                        [ERP, serror] = rememptychanloc(ERP);
                end
        else                
                [ERP, serror] = erpchanedit(ERP);
                if ~isempty(serror) && serror~=1
                        [ERP, serror] = rememptychanloc(ERP);
                end
        end        
else
        [ERP, serror ] = erpchanedit(ERP, filename);        
end
if serror ==1
        ERP  = ERPaux;
        return
end
if option
        [ERP, issave] = pop_savemyerp(ERP,'gui','erplab', 'History', 'implicit');
        if ~issave
                ERP  = ERPaux;
                return
        end
end


