% PURPOSE: Exports EVENTLIST structure from an ERPset to a text file
%
% FORMAT:
%
% exporterpeventlist(ERP, indexel, lfname)
%
% INPUTS:
%
% ERP            - input ERPset
% indexel        - EVENTLIST index (in case multiple EVENTLIST are attached to the ERP structure
% lfname         - full filename for output text file
%
% OUTPUT
%
% Text file
%
% See also sorteventliststruct.m
%
%
% Author: Javier Lopez-Calderon & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% May 2008

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

function EVENTLIST = exporterpeventlist(ERP, indexel, lfname)

EVENTLIST = [];
wf=1;

if nargin < 1
        help exporterpeventlist
        return
end
if nargin < 3
        lfname = '';
end
if nargin < 2
        indexel = 1;
end
if ~iserpstruct(ERP)
        error('ERPLAB says: errot at exporterpeventlist().Incorrect inputs - ERP structure is requiered')
end
if ~isfield(ERP, 'EVENTLIST')
        error('ERPLAB says: errot at exporterpeventlist(). Incorrect inputs - EVENTLIST structure is requiered')
end
if isempty(lfname)
        EVENTLIST = ERP.EVENTLIST(indexel);
        return        
else % write a text file        
        [evefilepath, evefilename, ext] = fileparts(lfname);
        
        if ~strcmp(ext,'.txt')
                ext = '.txt';
        end
        
        evefilename = [evefilename ext];
        
        if strcmpi(evefilepath,'')
                evefilepath = cd;
        end
        
        EVENTLIST = ERP.EVENTLIST(indexel);
        
        fin     = length(EVENTLIST.eventinfo);
        fprintf('Total Events (eventcodes + pauses) = %g \n', fin);
        
        if ~isfield(EVENTLIST, 'setname')
                if isfield(EEG, 'setname')
                        EVENTLIST.setname = EEG.setname;
                else
                        EVENTLIST.setname = 'none_specified';
                end
        end
        if ~isfield(EVENTLIST, 'report')
                EVENTLIST.report = '';
        end
        if ~isfield(EVENTLIST, 'bdfname')
                EVENTLIST.bdfname = '';
        end
        if ~isfield(EVENTLIST, 'nbin')
                EVENTLIST.nbin = [];
        end
        if ~isfield(EVENTLIST, 'version')
                EVENTLIST.version = geterplabversion;
        end
        if ~isfield(EVENTLIST, 'account')
                EVENTLIST.account = '';
        end
        if ~isfield(EVENTLIST, 'username')
                EVENTLIST.username = '';
        end
        if ~isfield(EVENTLIST, 'trialsperbin')
                EVENTLIST.trialsperbin = [];
        end
        
        EVENTLIST.elname  = fullfile(evefilepath, evefilename);
        
        if isfield(EVENTLIST, 'bdf')
                if isempty(EVENTLIST.bdf)
                        EVENTLIST.bdf.expression  = [];
                        EVENTLIST.bdf.description = [];
                        EVENTLIST.bdf.prehome     = [];
                        EVENTLIST.bdf.athome      = [];
                        EVENTLIST.bdf.posthome    = [];
                        EVENTLIST.bdf.namebin     = [];
                        EVENTLIST.trialsperbin    = [];
                end
        else
                EVENTLIST.bdf.expression  = [];
                EVENTLIST.bdf.description = [];
                EVENTLIST.bdf.prehome     = [];
                EVENTLIST.bdf.athome      = [];
                EVENTLIST.bdf.posthome    = [];
                EVENTLIST.bdf.namebin     = [];
                EVENTLIST.trialsperbin    = [];
        end
        
        EVENTLIST.eldate  = datestr(now);
        
        [EVENTLIST, serror] = sorteventliststruct(EVENTLIST);  % organizes EVENTLIST
        
        if wf ==1
                fprintf('Creating an ERP EventList text file...\n');
                fid_eventlist   = fopen( fullfile(evefilepath, evefilename) , 'w');
                formatstr = '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s %s\t%s\t[%s]\n';
                
                %
                % Header
                %
                if isfield(ERP, 'erpname')
                        if strcmp(ERP.erpname,'')
                                ERPerpname = 'none_specified';
                        else
                                ERPerpname = ERP.erpname;
                        end
                else
                        ERPerpname = 'none_specified';
                end
                
                dataform = 'averaged_ERP';
                
                if isfield(ERP, 'filename')
                        if strcmp(ERP.filename,'')
                                ERPfilename = 'none_specified';
                        else
                                ERPfilename = ERP.filename;
                        end
                else
                        ERPfilename = 'none_specified';
                end
                if isfield(ERP, 'filepath')
                        if strcmp(ERP.filepath,'')
                                ERPfilepath = 'none_specified';
                        else
                                ERPfilepath = ERP.filepath;
                        end
                else
                        ERPfilepath = 'none_specified';
                end
                if isfield(ERP, 'nchan')
                        ERPnchan = ERP.nchan;
                else
                        ERPnchan = 0;
                end
                if isfield(ERP, 'pnts')
                        ERPpnts = ERP.pnts;
                else
                        ERPpnts = 0;
                end
                if isfield(ERP, 'srate')
                        ERPsrate = ERP.srate;
                else
                        ERPsrate = 0;
                end
                
                fprintf( fid_eventlist, ['#  Non-editable header begin ' repmat('-',1,80) '\n']);
                fprintf( fid_eventlist, '# \n');
                fprintf( fid_eventlist, '#  data format...............: %s\n', dataform);
                fprintf( fid_eventlist, '#  erpname...................: %s\n', ERPerpname);
                fprintf( fid_eventlist, '#  filename..................: %s\n', ERPfilename);
                fprintf( fid_eventlist, '#  filepath..................: %s\n', ERPfilepath);
                fprintf( fid_eventlist, '#  nchan.....................: %d\n', ERPnchan);
                fprintf( fid_eventlist, '#  pnts......................: %d\n', ERPpnts);
                fprintf( fid_eventlist, '#  srate.....................: %d\n', ERPsrate);
                fprintf( fid_eventlist, '#  nevents...................: %d\n', length(EVENTLIST.eventinfo));
                fprintf( fid_eventlist, '#  generated by (bdf)........: %s\n', EVENTLIST.bdfname );
                fprintf( fid_eventlist, '#  generated by (set)........: %s\n', EVENTLIST.setname  );
                fprintf( fid_eventlist, '#  reported in ..............: %s\n', EVENTLIST.report );
                fprintf( fid_eventlist, '#  prog Version..............: %s\n', EVENTLIST.version );
                fprintf( fid_eventlist, '#  creation date.............: %s\n', EVENTLIST.eldate);
                fprintf( fid_eventlist, '#  user Account..............: %s\n', EVENTLIST.account);
                fprintf( fid_eventlist, '# \n');
                
                fprintf(fid_eventlist,['#  Non-editable header end ' repmat('-',1,80) '\n\n']);
                
                nbin      = EVENTLIST.nbin;
                
                for h=1:nbin
                        nob = EVENTLIST.trialsperbin(h);
                        des = EVENTLIST.bdf(1,h).description;
                        fprintf( fid_eventlist, '\tbin %g,\t# %g,\t%s\n', h, nob, des);
                end
                
                fprintf(fid_eventlist,'\n\n');
                fprintf(fid_eventlist,'\n');
                fprintf(fid_eventlist,'# item\t bepoch\t  ecode\t            label\t      onset\t          diff\t     dura\tb_flags\t   a_flags\t  enable\t    bin\n');
                fprintf(fid_eventlist,'#                                                 (sec)           (msec)     (msec)    (binary)   (binary)\n');
                fprintf(fid_eventlist,'\n\n');
                
                %
                % Prepares diffe field
                %
                xtime = single([EVENTLIST.eventinfo.time]);
                diffe   = [0 diff(xtime)]*1000; %sec to msec
                
                for k=1:fin
                        sitem = num2str(k);
                        if isfield(EVENTLIST.eventinfo, 'bepoch')
                                sbepoch = num2str(EVENTLIST.eventinfo(k).bepoch);
                        else
                                sbepoch = '0';
                        end
                        
                        scode = num2str(EVENTLIST.eventinfo(k).code);
                        sclab = num2str(EVENTLIST.eventinfo(k).codelabel);
                        stime = sprintf('%.4f', EVENTLIST.eventinfo(k).time);
                        sdiff = sprintf('%.2f', diffe(k));
                        sdura = sprintf('%.1f', EVENTLIST.eventinfo(k).dura);
                        sflag = dec2bin(EVENTLIST.eventinfo(k).flag,16);
                        senbl = num2str(EVENTLIST.eventinfo(k).enable);
                        sbini = num2str(EVENTLIST.eventinfo(k).bini);
                        
                        if strcmp(sbini,'-1')
                                sbini = '';
                        end
                        
                        sitem   = [sitem blanks(6-length(sitem))];
                        sbepoch = [sbepoch blanks(6-length(sbepoch))];
                        scode   = [blanks(7-length(scode)) scode];
                        sclab   = [blanks(16-length(sclab)) sclab];
                        stime   = [blanks(12-length(stime)) stime];
                        sdiff   = [blanks(10-length(sdiff)) sdiff];
                        sdura   = [blanks(7-length(sdura)) sdura];
                        sflaga  = [blanks(4) sflag(9:16)];
                        sflagb  = [blanks(4) sflag(1:8)];
                        senbl   = [blanks(4-length(senbl)) senbl];
                        sbini   = [blanks(7-length(sbini)) sbini];
                        
                        fprintf(fid_eventlist,formatstr, sitem, sbepoch, scode, sclab, stime, sdiff, sdura, sflagb,...
                                sflaga, senbl, sbini);
                end
                fclose(fid_eventlist);
        end
        
        flinkname = fullfile(evefilepath, evefilename);
        disp(['A new ERP EventList file was created at <a href="matlab: open(''' flinkname ''')">' flinkname '</a>'])
end
