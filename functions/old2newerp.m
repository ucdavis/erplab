% PURPOSE: upgrades old ERPset to the current version (current ERP structure format)
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

function ERPnew = old2newerp(ERPold, oldver)
if iserpstruct(ERPold)        
        ERPnew = ERPold;
        gcverplab = geterplabversion; % current erplab version        
        if ~strcmpi(gcverplab, ERPold.version)
                fprintf('ERPset''s version number was changed by the current ERPLAB''s version number.\n');
        end
        
        ERPnew.version = gcverplab; % current version
        upderp = 0;
        
        if ~isfield(ERPnew,'EVENTLIST')
                ERPnew.EVENTLIST = [];
                upderp = 1;
        end
        if ~isfield(ERPnew,'binerror')
                ERPnew.binerror = [];
                upderp = 1;
        end        
        if ~isfield(ERPnew,'datatype')
                ERPnew.datatype = 'ERP';
                upderp = 1;
        end
        if ~isfield(ERPnew,'splinefile')
              ERPnew.splinefile = '';
              upderp = 1;
        end
        if isfield(ERPnew,'integrity')
                ERPnew.pexcluded = [];
                vali = ERPnew.integrity;
                ERPnew = rmfield(ERPnew, 'integrity');
                ERPnew.pexcluded = vali;
                upderp = 1;
        elseif isfield(ERPnew,'marate')
                ERPnew.pexcluded = [];
                vali = ERPnew.marate;
                ERPnew = rmfield(ERPnew, 'marate');
                ERPnew.pexcluded = vali;
                upderp = 1;
        elseif isfield(ERPnew,'propexcluded')
                ERPnew.pexcluded = [];
                 if isfield(ERPnew.ntrials,'accepted') && isfield(ERPnew.ntrials,'rejected')
                        vali = round(1000*(sum(ERPnew.ntrials.rejected)/(sum(ERPnew.ntrials.accepted)+sum(ERPnew.ntrials.rejected))))/10;
                else
                        vali = ERPnew.propexcluded;
                end
                ERPnew = rmfield(ERPnew, 'propexcluded');
                ERPnew.pexcluded = vali;
                upderp = 1;
        else
                if ~isfield(ERPnew,'pexcluded')
                        ERPnew.pexcluded = [];   
                        upderp = 1;
                end                
        end
        if upderp ==1
                fprintf('Minor differences at ERP structure were found.\n');
                fprintf('Erpset''s ERP structure was upgraded.\n\n');
        end
        if isempty(ERPnew.pexcluded)                
                if isfield(ERPnew.ntrials,'accepted') && isfield(ERPnew.ntrials,'rejected')
                        pexcluded = round(1000*(sum(ERPnew.ntrials.rejected)/(sum(ERPnew.ntrials.accepted)+sum(ERPnew.ntrials.rejected))))/10; % 1 decimal
                        ERPnew.pexcluded = pexcluded;
                end
        end
        return
end
fprintf('Major differences at ERP structure were found.\n');
if nargin==1
        try
                versionold = ERPold.version; %old version
        catch
                versionold = '???';
        end
else
        versionold = oldver; % old version
end

fprintf('Converting ERP from version %s to version %s...\n', versionold, geterplabversion);
ERPnew = buildERPstruct([]);

if isfield(ERPold,'erpname')
        erpn = ERPold.erpname;
else
        erpn = ERPold.setname;
end
if iscell(erpn)
        ERPnew.erpname   = erpn{1};
        ERPnew.workfiles = erpn;
else
        ERPnew.erpname   = erpn;
        ERPnew.workfiles = {erpn};
end

ERPnew.filename  = ERPold.filename;
ERPnew.filepath  = ERPold.filepath;
ERPnew.subject   = ERPold.subject;
ERPnew.nchan     = ERPold.nchan;
ERPnew.nbin      = ERPold.nbin;
ERPnew.pnts      = ERPold.pnts;
ERPnew.srate     = ERPold.srate;
ERPnew.xmin      = ERPold.xmin;
ERPnew.xmax      = ERPold.xmax;
ERPnew.times     = ERPold.times;
ERPnew.bindata   = ERPold.binavg;

if isfield(ERPold,'binerrs')
        ERPnew.binerror =  ERPold.binerrs;
else
        if isfield(ERPold,'binerror')
                ERPnew.binerror = ERPold.binerror;
        else
                ERPnew.binerror = [];
        end
end
if isfield(ERPold,'numavgbin')
        ERPnew.ntrials.accepted  = ERPold.numavgbin;
        ERPnew.ntrials.rejected  = ERPnew.ntrials.accepted*0;
        ERPnew.ntrials.invalid   = ERPnew.ntrials.accepted*0;
elseif isfield(ERPold,'navgbin')
        ERPnew.ntrials.accepted  = ERPold.navgbin;
        ERPnew.ntrials.rejected  = ERPnew.ntrials.accepted*0;
        ERPnew.ntrials.invalid   = ERPnew.ntrials.accepted*0;
else
        try
                ERPnew.ntrials   = ERPold.ntrial;
        catch
                ERPnew.ntrials   = zeros(1,size(ERPnew.bindata,3));
        end
end
if ~isfield(ERPnew.ntrials,'accepted')
        ERPnew.ntrials.accepted = ERPnew.ntrials*0;
end
if ~isfield(ERPnew.ntrials,'invalid')
        ERPnew.ntrials.invalid = ERPnew.ntrials.accepted*0;
end
if ~isfield(ERPnew.ntrials,'arflags')
        ERPnew.ntrials.arflags = zeros(ERPnew.nbin,8);
else
        if isempty(ERPnew.ntrials.arflags)
                ERPnew.ntrials.arflags = zeros(ERPnew.nbin,8);
        end
end
if isfield(ERPold,'isfilt')
        ERPnew.isfilt   = ERPold.isfilt;
else
        ERPnew.isfilt   = 0;
end

ERPnew.chanlocs = ERPold.chanlocs;
ERPnew.ref      = ERPold.ref;
ERPnew.bindescr = ERPold.bindescr;
ERPnew.history  = ERPold.history;

if isfield(ERPold,'EVENTLIST')        
        EVENTLISTold = ERPold.EVENTLIST;        
        EVENTLISTnew.setname      = EVENTLISTold.setname;
        EVENTLISTnew.report       = EVENTLISTold.report;
        EVENTLISTnew.bdfname      = EVENTLISTold.bdfname;
        EVENTLISTnew.nbin         = EVENTLISTold.nbin;
        EVENTLISTnew.account      = EVENTLISTold.account;
        EVENTLISTnew.username     = EVENTLISTold.username;
        EVENTLISTnew.trialsperbin = EVENTLISTold.trialperbin;
        EVENTLISTnew.bdf          = EVENTLISTold.bdf;
        
        for i=1:EVENTLISTnew.nbin
                EVENTLISTnew.bdf(i).expression   = [EVENTLISTnew.bdf(i).expression{1}...
                        '.' EVENTLISTnew.bdf(i).expression{2} EVENTLISTnew.bdf(i).expression{3}];
        end
        
        EVENTLISTnew.eldate       = EVENTLISTold.eldate;
        EVENTLISTnew.eventinfo    = EVENTLISTold.eventinfo;
        ERPnew.EVENTLIST          = EVENTLISTnew;
else
        ERPnew.EVENTLIST = [];
end

ERPnew.version      = geterplabversion; % current version
fprintf('Erpset''s ERP structure was upgraded.\n\n');
