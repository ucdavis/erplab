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
                %disp('A')
        else
                exchanArray = [];
                chfound = 0;
                %disp('B')
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
                
                %         if isfield(ERP.chanlocs, 'theta')
                %                 chanok = {ERP.chanlocs.theta};
                %                 exchanArray = find(cellfun('isempty',chanok));
                %
                %                 if ~isempty(exchanArray)
                %
                %                         selchannels = find(~ismember(1:ERP.nchan,exchanArray)); %selected channels
                %                         nsch = length(selchannels);
                %                         auxd = ERP.bindata(selchannels,:,:);
                %                         ERP.bindata = [];
                %                         ERP.bindata(1:nsch,:,:) = auxd;
                %                         ERP.nchan   = nsch;
                %                         namefields  = fieldnames(ERP.chanlocs);
                %                         nfn = length(namefields);
                %
                %                         for ff=1:nfn
                %                                 auxfield{ff} = {ERP.chanlocs(selchannels).(namefields{ff})};
                %                         end
                %
                %                         ERP.chanlocs=[];
                %
                %                         for ff=1:nfn
                %                                 [ERP.chanlocs(1:nsch).(namefields{ff})] = auxfield{ff}{:};
                %                         end
                %                         if length(exchanArray)==1
                %                                 fprintf('Channel %g was skiped\n', exchanArray)
                %                         elseif length(exchanArray)>1
                %                                 fprintf('Channels %g were skiped\n', exchanArray)
                %                         end
                %                 end
                %                 fprintf('\nChannel locations were successfuly loaded!\n');
                %         else
                %                 msgboxText = ['Error: pop_scalplot could not find channel locations info.\n\n'...
                %                         'Hint: Identify channel(s) without location looking at '...
                %                         'command window comments (Channel lookup). Try again excluding this(ese) channel(s).'];
                %                 tittle = 'ERPLAB:  error:';
                %                 errorfound(sprintf(msgboxText), tittle);
                %                 return
                %         end
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


