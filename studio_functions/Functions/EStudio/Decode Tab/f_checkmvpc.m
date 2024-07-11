% PURPOSE  : This function is to exmaine if the parameters are the same across different MVPCsets

% FORMAT   :
%
% [serror, msgwrng] = f_checkmvpc(ALLMVPC,MVPCArray)
%


% INPUTS:
%
% ALLMVPC        - structure array of MVPC structures (MVPCsets)
% MVPCArray      - index(es) of MVPCset(s) e.g. 1:5


% Author: Guanghui ZHANG && Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2024

% ERPLAB Studio Toolbox
%


function [serror, msgwrng] = f_checkmvpc(ALLMVPC,MVPCArray)

serror = 0;
msgwrng='';

if nargin<1 || nargin>2
    help f_checkmvpc
    return
end

if isempty(ALLMVPC)
    msgboxText =  'ALLMVPC is empty';
    title = 'ERPLAB: f_checkmvpc() Error';
    errorfound(msgboxText, title);
    return;
end


if nargin<2
    MVPCArray   = [1:length(ALLMVPC)];
end


if isempty(MVPCArray) || any(MVPCArray(:)>length(ALLMVPC)) || any(MVPCArray(:)<1)
    MVPCArray   = [1:length(ALLMVPC)];
end

if numel(MVPCArray)==1
    return;
end

for j = 1:numel(MVPCArray)
    
    MVPCT = ALLMVPC(MVPCArray(j));
    if j>1
        % basic test for number of points
        if pre_pnts  ~= MVPCT.pnts
            msgwrng =  sprintf('MVPCsets #%g and #%g have different number of points!', MVPCArray(j-1), MVPCArray(j));
            %             title = 'ERPLAB: pop_gaverager() Error';
            %             errorfound(msgboxText, title);
            serror = 1;
            break
        end
        
          %%start time of epoch
        if pre_startpnt~=MVPCT.times(1)
            msgwrng =  sprintf('MVPCsets #%g and #%g have different starting time of the epoch', MVPCArray(j-1), MVPCArray(j));
            %                 cprintf([1 0.52 0.2], '%s\n\n', msgwrng);
            %errorfound(msgboxText, title);
            %return
            serror = 1;
            break
        end
        
        %%end time of epoch
        if pre_endpnt~=MVPCT.times(end)
            msgwrng =  sprintf('MVPCsets #%g and #%g have different stop time of the epoch',MVPCArray(j-1), MVPCArray(j));
            %                 cprintf([1 0.52 0.2], '%s\n\n', msgwrng);
            %errorfound(msgboxText, title);
            %return
            serror = 1;
            break
        end
        
        
        
        % basic test for number of channels (for now...)
        if  pre_nchan ~= size(MVPCT.electrodes,2)
            msgwrng =  sprintf('MVPCsets #%g and #%g have different number of channels!', MVPCArray(j-1), MVPCArray(j));
            %                 cprintf([1 0.52 0.2], '%s\n\n', msgwrng);
            %
            %title = 'ERPLAB: pop_gaverager() Error';
            %errorfound(msgboxText, title);
            serror = 2;
            break
        end
        
        % basic test for number of bins (for now...)
        if pre_nClasses  ~= MVPCT.nClasses
            msgwrng =  sprintf('MVPCsets #%g and #%g have different number of classes!', MVPCArray(j-1), MVPCArray(j));
            %                 cprintf([1 0.52 0.2], '%s\n\n', msgwrng);
            %title = 'ERPLAB: pop_gaverager() Error';
            %errorfound(msgboxText, title);
            %return
            serror = 2;
            break
        end
        
        if pre_nIter  ~= MVPCT.nIter
            msgwrng =  sprintf('MVPCsets #%g and #%g have different number of Iterations!',MVPCArray(j-1), MVPCArray(j));
            %                 cprintf([1 0.52 0.2], '%s\n\n', msgwrng);
            %title = 'ERPLAB: pop_gaverager() Error';
            %errorfound(msgboxText, title);
            %return
            serror = 2;
            break
        end
        
        if pre_nCrossfolds  ~= MVPCT.nCrossfolds
            msgwrng =  sprintf('MVPCsets #%g and #%g have different number of Cross folds!', MVPCArray(j-1), MVPCArray(j));
            %                 cprintf([1 0.52 0.2], '%s\n\n', msgwrng);
            %title = 'ERPLAB: pop_gaverager() Error';
            %errorfound(msgboxText, title);
            %return
            serror = 2;
            break
        end
        
        
        %%basic test for data type (for now...)
        if ~strcmpi(pre_dtype, MVPCT.DecodingMethod)
            msgwrng =  sprintf('MVPCsets #%g and #%g have different decoding methods ', MVPCArray(j-1), MVPCArray(j));
            %                 cprintf([1 0.52 0.2], '%s\n\n', msgwrng);
            %errorfound(msgboxText, title);
            %return
            serror = 2;
            break
        end
        
        %%sampling rate
        if pre_srate~=MVPCT.srate
            msgwrng =  sprintf('MVPCsets #%g and #%g have different sampling rates', MVPCArray(j-1), MVPCArray(j));
            %                 cprintf([1 0.52 0.2], '%s\n\n', msgwrng);
            %errorfound(msgboxText, title);
            %return
            serror = 2;
            break
        end
        
      
        
    end
    
    pre_nchan  = size(MVPCT.electrodes,2);
    pre_pnts   = MVPCT.pnts;
    pre_nCrossfolds = MVPCT.nCrossfolds;
    pre_nClasses   = MVPCT.nClasses;
    pre_nIter   = MVPCT.nIter;
    pre_dtype  = MVPCT.DecodingMethod;
    pre_srate = MVPCT.srate;
    pre_startpnt = MVPCT.times(1);
    pre_endpnt = MVPCT.times(end);
end

end