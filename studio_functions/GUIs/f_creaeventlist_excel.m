% PURPOSE: Creates a .xls version of the ERPLAB's EVENTLIST structure
%
% FORMAT:
%
% [EEG EVENTLIST] = f_creaeventlist_excel(EEG, EVENTLIST, lfname, wf)
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
% Author: Guanghui & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2024

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

function [EEG, EVENTLIST] = f_creaeventlist_excel(EEG, EVENTLIST, lfname, wf)
if nargin < 1
    help f_creaeventlist_excel
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
    wf = 0;  % Don't write backup file
    evefilepath = '';
    evefilename = '';
else
    if nargin>4
        error('ERPLAB says: error at f_creaeventlist_excel(). Too many arguments!!!!\n')
    end
    if nargin<4
        wf=1;
    end

    [evefilepath, evefilename, ext] = fileparts(lfname);

    if (~strcmp(ext,'.xls') || ~strcmp(ext,'.xlsx')) && ~strcmp(evefilename,'') && ~strcmp(evefilename,'no') && ~strcmp(evefilename,'none')
        ext = '.xls';
    end
    if ~strcmp(evefilename,'') && ~strcmp(evefilename,'no') && ~strcmp(evefilename,'none')
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
    fprintf('Creating an EventList .xsl file...\n');

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
    flinkname = fullfile(evefilepath, evefilename);
    columName2 = {'item','bepoch','ecode','label','onset','diff','dura','b_flags','a_flags','enable','bin'};
    sheet_label_T = table(columName2);
    writetable(sheet_label_T,flinkname,'Range','A1','WriteVariableNames',false,"AutoFitWidth",false);

    %
    % Prepares diffe field
    %
    xtime = single([EVENTLIST.eventinfo.time]);
    diffe   = [0 diff(xtime)]*1000; % sec to msec
    data = cell(fin,11);
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
        data{k,1}=sitem;
        data{k,2}=sbepoch;
        data{k,3}=scode;
        data{k,4}=sclab;
        data{k,5}=stime;
        data{k,6}=sdiff;
        data{k,7}=sdura;
        data{k,8}=sflagb;
        data{k,9}=sflaga;
        data{k,10}=senbl;
        data{k,11}=sbini;
    end
    xls_d = table(data);
    writetable(xls_d,flinkname,'Range','A2','WriteVariableNames',false,"AutoFitWidth",false);  % write data



    disp(['A new EventList file was created at <a href="matlab: open(''' flinkname ''')">' flinkname '</a>'])
end
if isfield(EEG, 'chanlocs')
    if ~isfield(EEG.chanlocs,'labels')
        for e=1:eegnbchan
            EEG.chanlocs(e).labels = ['Ch' num2str(e)];
        end
        disp('Your dataset did not have channel labels.')
        disp('f_creaeventlist_excel() added basic labels to your channels.')
    end
end
