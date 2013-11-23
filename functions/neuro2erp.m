% PURPOSE: subroutine for pop_importerp.m
%          loads averaged ERP (.avg) from Neuroscan
%
% FORMAT
%
% ERP = neuro2erp(filename, pathname)
%
%
% See also pop_importerp.m loadavg2.m
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% January 25th, 2011

function ERP = neuro2erp(filename, pathname)
if nargin<2
            error('ERPLAB says: error, filename and pathname are needed as inputs.')
end

nfile = length(filename);
npath = length(pathname);

if nfile>1 && npath==1
      pathname = cellstr(repmat(char(pathname),nfile,1))';
elseif nfile>1 && npath~=1 && npath~=nfile
      error('filename and pathname do not match')
elseif nfile==1 && npath~=1
      error('filename and pathname do not match')
end

bindata  = [];
binerror = [];
bindescr = cell(1);
accepted = [];
rejected = [];

for i=1:nfile      
      fname    = filename{i};
      pathn    = pathname{i};
      fullname = fullfile(pathn, fname);
      [signal, variance, chan_names, pnts, rate, xmin, xmax, acceptcnt, rejectcnt] = loadavg2( fullname );   
      
      chanlabels = cellstr(char(chan_names))';
      
% % %       %
% % %       % Prepare List of current Channels
% % %       %
% % %       nchan  = ERP.nchan; % Total number of channels
% % %       if ~isfield(ERP.chanlocs,'labels')
% % %             for e=1:nchan
% % %                   ERP.chanlocs(e).labels = ['Ch' num2str(e)];
% % %             end
% % %       end
% % %       listch = {''};
% % %       for ch =1:nchan
% % %             listch{ch} = [num2str(ch) ' = ' ERP.chanlocs(ch).labels ];
% % %       end
% % %       set(handles.popupmenu_chans,'String', listch)
% % %       
% % %       
      
      if i>1
            if ismember_bc2(0, strcmpi(chanlabels, auxchlab))
                  error('chan label error!')
            end
            if rate~=auxsrate
                  error('rate error!')
            end
            if xmin~=auxxmin
                  error('xmin error!!!')
            end
            if xmax~=auxxmax
                  error('xmax error!!!')
            end
      end
      
      auxchlab = chanlabels;
      auxsrate = rate;
      auxxmin  = xmin;
      auxxmax  = xmax;
      
      if i>1
            if (size(signal,1)~=size(bindata,1)) || (size(signal,2)~=size(bindata,2))
                  error('dim data!!!')
            end
            %if (size(variance,1)~=size(binerror,1)) || (size(variance,2)~=size(binerror,2))
            %      error('dim error!!!')
            %end
      end
      
      bindata  = cat(3, bindata, signal) ;
      
      if isempty(variance)
            variance = zeros(size(signal));
      else
            if ischar(variance)
                  variance = zeros(size(signal));
            else
                  variance = sqrt(variance); % var to std
            end
      end
      
      binerror = cat(3, binerror, variance);
      bindescr{i} = strrep(fname, '.avg', ''); 
      accepted = [accepted acceptcnt];
      rejected = [rejected rejectcnt];
end

if nnz(binerror)<numel(bindata)
      binerror = [];
else
      binerror = sqrt(binerror);
end

ERP = buildERPstruct;

% ERP.erpname   =
% ERP.filename  =
% ERP.filepath  =
% ERP.workfiles =
% ERP.subject   =
nchan = size(bindata, 1);
ERP.nchan     = nchan;
nbin = size(bindata, 3);
ERP.nbin      = nbin;
ERP.pnts      = size(bindata, 2);
ERP.srate     = rate;
ERP.xmin      = xmin;
ERP.xmax      = xmax;
xminms        = round(xmin*1000);
xmaxms        = round(xmax*1000);
t = linspace(xminms, xmaxms, pnts);
indx = find(t>0,1);
times = t-t(indx);
ERP.times     =  times;
ERP.bindata   = bindata;
ERP.binerror  = binerror;

if isempty(chanlabels)
      for e=1:nchan
            ERP.chanlocs(e).labels = ['Ch' num2str(e)];
      end
else
      chmin = min(nchan,length(chanlabels));
      [ERP.chanlocs(1:chmin).labels] = chanlabels{1:chmin};
end

ERP.ntrials.accepted = accepted;
ERP.ntrials.rejected = rejected;
ERP.ntrials.invalid  = 0*accepted;
ERP.ntrials.arflags  = zeros(nbin,8);

%     accepted: []
%     rejected: []
%      invalid: []
%      arflags: [0x8 double]

ERP.isfilt    = 0;
%ERP.chanlocs  =
%ERP.ref       =

ERP.bindescr  = bindescr;