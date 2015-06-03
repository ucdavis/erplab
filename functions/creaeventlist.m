% PURPOSE: Creates a text version of the ERPLAB's EVENTLIST structure
%
% FORMAT:
%
% [EEG EVENTLIST] = creaeventlist(EEG, EVENTLIST, lfname, wf)
%
% Inputs:
%
% EEG         - input dataset
% EVENTLIST   - ERPLAB's EVENTLIST structure
% lfname      - full filename of EventList file to save (*.txt)
% wf          - write the file. 1 yes; 0 no
%
% Output
%
% EEG         - updated dataset
% EVENTLIST   - ERPLAB's EVENTLIST structure
%
% Author: Javier Lopez-Calderon & Steven Luck
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

function [EEG, EVENTLIST] = creaeventlist(EEG, EVENTLIST, lfname, wf)
if nargin < 1
        help creaeventlist
        return
end
if nargin==1        
        wf =0;
        evefilepath = '';
        evefilename = '';
        
        if isfield(EEG, 'EVENTLIST')
                if isfield(EEG.EVENTLIST, 'eventinfo')
                        if isempty(EEG.EVENTLIST.eventinfo)
                                EVENTLIST = creaeventinfo(EEG);
                        else
                                EVENTLIST = EEG.EVENTLIST;
                        end
                else
                        EVENTLIST = creaeventinfo(EEG);
                end
                if ~isfield(EEG.EVENTLIST, 'bdf')
                        EVENTLIST.bdf = [];
                end
        else
                EVENTLIST = creaeventinfo(EEG);
                EVENTLIST.bdf = [];
        end        
elseif nargin==2
        wf = 1;
        p = which('eegplugin_erplab');
        path_temp = p(1:findstr(p,'eegplugin_erplab.m')-1);
        evefilepath = fullfile(path_temp, 'erplab_Box');              
        if exist(evefilepath, 'dir')~=7
                mkdir(evefilepath);  % Thanks to Johanna Kreither. Jan 31, 2013
        end               
        evefilename = ['eventlist_backup_' num2str((datenum(datestr(now))*1e10))];        
else
        if nargin>4
                error('ERPLAB says: error at creaeventlist(). Too many arguments!!!!\n')
        end
        if nargin<4
              wf=1;
        end       
        
        [evefilepath, evefilename, ext] = fileparts(lfname);
        
        if ~strcmp(ext,'.txt') && ~strcmp(evefilename,'') && ~strcmp(evefilename,'no') && ~strcmp(evefilename,'none')
              ext = '.txt';
        end        
        if ~strcmp(evefilename,'')
              evefilename = [evefilename ext];
        else
              wf=0;
        end        
        if strcmpi(evefilepath,'')
              evefilepath = cd;
        end
        if isempty(EVENTLIST)
                EVENTLIST = creaeventinfo(EEG);
                
        end
        if ~isfield(EVENTLIST, 'bdf')
                EVENTLIST.bdf = [];
        end
        if isfield(EEG, 'EVENTLIST')
                EEG.EVENTLIST = []; % Warning!                 
        end
end

fprintf('Creating a EventList structure...\n');
fin     = length(EVENTLIST.eventinfo); % total events in dataset
% item = zeros(1,fin);
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
                EVENTLIST.bdf.rtname      = [];
                EVENTLIST.bdf.rtindex     = [];
                EVENTLIST.bdf.rt          = [];
        end
else
        EVENTLIST.bdf.expression  = [];
        EVENTLIST.bdf.description = [];
        EVENTLIST.bdf.prehome     = [];
        EVENTLIST.bdf.athome      = [];
        EVENTLIST.bdf.posthome    = [];
        EVENTLIST.bdf.namebin     = [];
        EVENTLIST.bdf.rtname      = [];
        EVENTLIST.bdf.rtindex     = [];
        EVENTLIST.bdf.rt          = [];
        EVENTLIST.trialsperbin    = [];
end

EVENTLIST.eldate   = datestr(now);
[EVENTLIST, serror] = sorteventliststruct(EVENTLIST);  % organizes EVENTLIST
eegnbchan = 0;
if wf ==1
        fprintf('Creating an EventList text file...\n');
        fid_eventlist   = fopen( fullfile(evefilepath, evefilename) , 'w');
        formatstr = '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s %s\t%s\t[%s]\n';
        
        %
        % Header
        %
        if isfield(EEG, 'setname')
                if strcmp(EEG.setname,'')
                        eegsetname = 'none_specified';
                else
                        eegsetname = EEG.setname;
                end
        else
                eegsetname = 'none_specified';
        end
        if isfield(EEG, 'epoch')
                if isempty(EEG.epoch)
                        dataform = 'continuous';
                else
                        dataform = 'epoched';
                end
        else
                dataform = 'none_specified';
        end
        if isfield(EEG, 'filename')
                if strcmp(EEG.filename,'')
                        eegfilename = 'none_specified';
                else
                        eegfilename = EEG.filename;
                end
        else
                eegfilename = 'none_specified';                
        end
        if isfield(EEG, 'filepath')
                if strcmp(EEG.filepath,'')
                        eegfilepath = 'none_specified';
                else
                        eegfilepath = EEG.filepath;
                end
        else
                eegfilepath = 'none_specified';
        end
        if isfield(EEG, 'nbchan')
                eegnbchan = EEG.nbchan;
        %else
        %        eegnbchan = 0;
        end
        if isfield(EEG, 'pnts')
                eegpnts = EEG.pnts;
        else
                eegpnts = 0;
        end
        if isfield(EEG, 'srate')
                eegsrate = EEG.srate;
        else
                eegsrate = 0;
        end
        
        fprintf( fid_eventlist, ['#  Non-editable header begin ' repmat('-',1,80) '\n']);
        fprintf( fid_eventlist, '# \n');
        fprintf( fid_eventlist, '#  data format...............: %s\n', dataform);
        fprintf( fid_eventlist, '#  setname...................: %s\n', eegsetname);
        fprintf( fid_eventlist, '#  filename..................: %s\n', eegfilename);
        fprintf( fid_eventlist, '#  filepath..................: %s\n', eegfilepath);
        fprintf( fid_eventlist, '#  nchan.....................: %d\n', eegnbchan);
        fprintf( fid_eventlist, '#  pnts......................: %d\n', eegpnts);
        fprintf( fid_eventlist, '#  srate.....................: %d\n', eegsrate);
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
                if isempty([EVENTLIST.bdf.description])
                        des = '""';
                else
                        des = EVENTLIST.bdf(1,h).description;
                end
                
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
        diffe   = [0 diff(xtime)]*1000; % sec to msec
        
        for k=1:fin                
                sitem  = num2str(k);                
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
        flinkname = fullfile(evefilepath, evefilename);
        disp(['A new EventList file was created at <a href="matlab: open(''' flinkname ''')">' flinkname '</a>'])
end
if isfield(EEG, 'chanlocs')
        if ~isfield(EEG.chanlocs,'labels')
                for e=1:eegnbchan
                        EEG.chanlocs(e).labels = ['Ch' num2str(e)];
                end
                disp('Your dataset did not have channel labels.')
                disp('creaeventlist() added basic labels to your channels.')
        end        
end

