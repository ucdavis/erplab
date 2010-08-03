%---------------------------------------------------------------------------------------------------
%-----------------base line mean value--------------------------------------------------------------
function ERP = borrowchanloc(ERP)

if isfield(ERP.chanlocs,'theta')
        chanok = {ERP.chanlocs.theta};
        exchanArray = find(cellfun('isempty',chanok));
        
        chfound = 1;
else
        exchanArray = [];
        chfound = 0;
end

ERPaux = ERP;

if isempty(exchanArray) && chfound==1
        fprintf('Channel locations were successfuly found!\n');
        
else
        %
        % Preparing a contraband EEG
        %
        EEGx.data     = ERP.bindata;
        EEGx.chanlocs = ERP.chanlocs;
        EEGx.nbchan   = ERP.nchan;
        EEGx = pop_chanedit(EEGx);    % open EEGLAB GUI
        ERP.chanlocs = EEGx.chanlocs; % load channel location into ERP structure
        ERP.bindata  = EEGx.data;
        ERP.nchan    = EEGx.nbchan;
        
        if isfield(ERP.chanlocs, 'theta')
                
                chanok = {ERP.chanlocs.theta};
                exchanArray = find(cellfun('isempty',chanok));
                
                if ~isempty(exchanArray)
                        
                        selchannels = find(~ismember(1:ERP.nchan,exchanArray)); %selected channels
                        nsch = length(selchannels);
                        auxd = ERP.bindata(selchannels,:,:);
                        ERP.bindata = [];
                        ERP.bindata(1:nsch,:,:) = auxd;
                        ERP.nchan  = nsch;
                        namefields = fieldnames(ERP.chanlocs);
                        nfn = length(namefields);
                        
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
                
                [ERP issave] = pop_savemyerp(ERP,'gui','erplab');
                
                if ~issave
                        ERP  = ERPaux;
                        return
                end
                
                fprintf('\nChannel locations were successfuly loaded!\n');
                
        else
                
                msgboxText{1} =  'Error: pop_scalplot could not find channel locations info.';
                msgboxText{2} =  'Hint: Identify channel(s) without location looking at';
                msgboxText{3} = 'command window comments (Channel lookup). Try again excluding this(ese) channel(s).';
                tittle = 'ERPLAB:  error:';
                errorfound(msgboxText, tittle)
                return
        end
end