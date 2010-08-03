%
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% ERPLAB Toolbox
% Copyright © 2007 The Regents of the University of California
% Created by Javier Lopez-Calderon and Steven Luck
% Center for Mind and Brain, University of California, Davis,
% javlopez@ucdavis.edu, sjluck@ucdavis.edu
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

function [ERP erpcom] = pop_appenderp(ALLERP,indx, prefixes)

erpcom = '';

ERP = preloadERP;
ERPaux = ERP;

if nargin<1
      help pop_appenderp
      return
end

if isempty(ERP)
      msgboxText{1} =  'pop_blcerp() error: cannot work with an empty erpset!';
      title = 'ERPLAB: No data';
      errorfound(msgboxText, title);
      return
end

nloadedset = length(ALLERP);

if nargin==1
      
      answer = appenderpGUI(nloadedset);
      
      if isempty(answer)
            disp('User selected Cancel')
            return
      end
      
      indx      = answer{1};
      prefixes  = answer{2};
else
      
      if nargin<3
            prefixes = [];
      end
      if nargin<2
            indx = 1:length(ALLERP);
      end
end

nerp    = length(indx);
nprefix = length(prefixes);

if ~isempty(prefixes)
      if nerp~=nprefix
            msgboxText{1} =  'Error: prefixes must to be as large as indx';
            title = 'ERPLAB: pop_appenderp() error:';
            errorfound(msgboxText, title);
            ERP = ERPaux;
            return
      end
end

try
      erpname   = [];
      filename  = [];
      filepath  = [];
      workfiles = [];
      subject   = '';
      bindata   = [];
      binerror  = [];
      nbin      = 0;
      accepted  = [];
      rejected  = [];
      invalid   = [];
      arflags   = [];
      bindescr  = [];
      history   = '';
      
      for i=1:nerp
            
            workfiles = [workfiles ALLERP(indx(i)).workfiles];
            subject   = [subject ALLERP(indx(i)).subject];
            
            if i==1
                  nchan      = ALLERP(indx(i)).nchan;
                  pnts       = ALLERP(indx(i)).pnts;
                  srate      = ALLERP(indx(i)).srate;
                  xmin       = ALLERP(indx(i)).xmin;
                  xmax       = ALLERP(indx(i)).xmax;
                  times      = ALLERP(indx(i)).times;
                  chanlocs   = ALLERP(indx(i)).chanlocs;
                  ref        = ALLERP(indx(i)).ref;
                  bindata    = ALLERP(indx(i)).bindata;
                  binerror   = ALLERP(indx(i)).binerror;
            else
                  bindata  = cat(3, bindata, ALLERP(indx(i)).bindata);
                  binerror = cat(3, binerror, ALLERP(indx(i)).binerror);
            end
            
            nbin     = nbin +  ALLERP(indx(i)).nbin;
            accepted = [accepted ALLERP(indx(i)).ntrials.accepted];
            rejected = [rejected ALLERP(indx(i)).ntrials.rejected];
            invalid  = [invalid ALLERP(indx(i)).ntrials.invalid];
            arflags  = cat(1,arflags, ALLERP(indx(i)).ntrials.arflags);
            
            if isempty(prefixes)
                  bindescr = [bindescr ALLERP(indx(i)).bindescr];
            else
                  auxdescr  = char(ALLERP(indx(i)).bindescr');
                  auxprefix = repmat([prefixes{i} ' : '], ALLERP(indx(i)).nbin,1);
                  newdescr  = cellstr(cat(2,auxprefix,auxdescr))';
                  bindescr  = [bindescr newdescr];
            end
      end
      
      ERP.erpname    = erpname;
      ERP.filename   = filename;
      ERP.filepath   = filepath;
      ERP.workfiles  = workfiles;
      ERP.subject    = subject;
      ERP.nchan      = nchan;
      ERP.nbin       = nbin;
      ERP.pnts       = pnts;
      ERP.srate      = srate;
      ERP.xmin       = xmin;
      ERP.xmax       = xmax;
      ERP.times      = times;
      ERP.bindata    = bindata;
      ERP.binerror    = binerror;
      ERP.chanlocs   = chanlocs;
      ERP.ref        = ref;
      ERP.bindescr   = bindescr;
      ERP.ntrials.accepted  = accepted;
      ERP.ntrials.rejected  = rejected;
      ERP.ntrials.invalid   = invalid;
      ERP.ntrials.arflags   = arflags;
      ERP.history    = history;
      ERP.saved      = 'no';
      ERP.isfilt     = 0;   % 1= avg was filtered or smoothed
      ERP.version    = geterplabversion;
      
      [ERP serror] = sorterpstruct(ERP);
      
      if ~serror
            
            if nargin==1
                  [ERP issave] = pop_savemyerp(ERP, 'gui', 'erplab');
            else
                  issave = 1;
            end
            
            if issave
                  erpcom = sprintf('ERP = pop_appenderp( %s, %s, { ', inputname(1), vect2colon(indx));
                  
                  for j=1:length(prefixes)
                        erpcom = sprintf('%s ''%s''  ', erpcom, prefixes{j} );
                  end;
                  
                  erpcom = sprintf('%s });', erpcom);
                  try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end
                  return
            else
                  msgboxText{1} =  'Warning: Your ERP was not saved';
                  title = 'ERPLAB: pop_appenderp() error:';
                  errorfound(msgboxText, title);
                  ERP = ERPaux;
                  return
            end
      else
            msgboxText{1} =  'Error: Your ERPs are not compatibles!';
            title = 'ERPLAB: pop_appenderp() error:';
            errorfound(msgboxText, title);
            ERP = ERPaux;
            return
      end
catch
      msgboxText{1} =  'Error: Your ERPs are not compatibles!';
      title = 'ERPLAB: pop_appenderp() error:';
      errorfound(msgboxText, title);
      ERP = ERPaux;
      return
end
