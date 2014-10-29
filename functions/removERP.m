% removERP.m removes the averaged ERP from every single epoch of its corresponding epoched EEG dataset
%
% Input:
%
% EEG       - epoched EEG dataset
% ERP       - averaged ERP (ERPset)
%
% Output:
%
% EEG       - epoched EEG dataset
%
% IMPORTANT:
% - epoched EEG dataset must have assigned bins (e.g. processed by ERPLAB).
% - epoched EEG dataset and averaged ERP (ERPset) must have the same amount of channels, samples and sample rate.
% - the time-locked event must be at the same sample location in both epoched EEG dataset and averaged ERP (ERPset).
%
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Johanna Kreither
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% July-August 2014

function EEG = removERP(EEG, ERP)

nepoch   = EEG.trials;
nchaneeg = EEG.nbchan;
npntseeg = EEG.pnts;
srateeeg = EEG.srate;
eegzerolatpos = find(EEG.times == 0,1,'first'); % catch zero-time locked code position,

nchanerp = ERP.nchan;
npntserp = ERP.pnts;
srateerp = ERP.srate;
erpzerolatpos = find(ERP.times == 0,1,'first'); % catch zero-time locked code position,

if nchaneeg~=nchanerp
      error('ERPLAB:error', 'EEG has %g channels and ERP has %g canales!', nchaneeg, nchanerp)
end
if npntseeg~=npntserp
      error('ERPLAB:error', 'EEG has %g points and ERP has %g points!', npntseeg, npntserp)
end
if srateeeg~=srateerp
      error('ERPLAB:error', 'EEG has a srate of %g sps and ERP has a srate of %g sps!', srateeeg, srateerp)
end
if eegzerolatpos~=erpzerolatpos
      error('ERPLAB:error', 'The time-locked event is not located at the same sample for EEG and ERP.')
end
for k=1:nepoch      
      latenarray = EEG.epoch(k).eventlatency;
      biniarray  = EEG.epoch(k).eventbini; 
      
      if iscell(latenarray)
            latenarray = cell2mat(latenarray);
      end
      
      indxtimelock = find(latenarray == 0,1,'first'); % catch zero-time locked code position,
      bini  = biniarray(indxtimelock);
      
      if isempty(bini)
            error('ERPLAB:error', 'Epoch %g does not habe a bin assigned (empty).', k)
      end      
      if iscell(bini)
            bini = cell2mat(bini);
      end      
      if bini<1
            error('ERPLAB:error', 'Epoch %g does not habe a bin assigned (-1).', k)
      end
      if length(bini)>1
            error('ERPLAB:error', 'Epoch %g has more than one bin assigned.', k)
      end
      
      EEG.data(:,:,k) = EEG.data(:,:,k) - ERP.bindata(:,:, bini);      
end