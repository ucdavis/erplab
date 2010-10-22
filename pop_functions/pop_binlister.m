%
% Usage
%
%   >> EEG = pop_binlister(EEG, bindescriptorfile, inputeventlistfile, outputeventlistfile,...
%                          resetflag, forbiddencodes, updatevents, workspace, reportable)
%
%
%   EEG                       - input data structure. For non-eeg processes
%                               enter EEG=[];
%   bindescriptorfile         - name of the text file containing your bin
%                               descriptions (formulas).
%
%   inputeventlistfile        - name of the text file containing the event
%                               information to process, according to ERPLAB format (see tutorial).
%                               Text version of the EVENTLIST structure.
%
%   outputeventlistfile       - name of the text file containing the upgraded event
%                               information, according to ERPLAB format (see tutorial).
%                               Text version of the EVENTLIST structure.
%
%   resetflag                 - set all flags to zero before start
%                               binlister process.
%                               1=reset   0:keep as it is.
%
%   forbiddencodes            - array of event codes (number) you do not
%                               want to be included during the binlister
%                               processes.
%
%   updatevents               - after binlister process you can move the
%                               upgraded event information to EEG.event field.
%                               1: update    0:keep as it is.
%
%   workspace                 - after binlister process you can copy the
%                               resulting EVENTLIST structure to Matlab workspace.
%
% reportable                  - 1=create report about binlister performance...
%
% See also    binlister.m    menuBinListGui.m   menuBinListGui.fig
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

function [EEG com] = pop_binlister(varargin)

global ALLEEG
global CURRENTSET

com = '';

if nargin < 1
        help pop_binlister
        return
end

if iseegstruct(varargin{1})

        EEG = varargin{1};

        if ~isempty(EEG.data)
                if isfield(EEG, 'EVENTLIST')
                        if isfield(EEG.EVENTLIST, 'eventinfo')
                                if isempty(EEG.EVENTLIST.eventinfo)
                                        msgboxText = ['EVENTLIST.eventinfo structure is empty!\n'...
                                                'Use Create EVENTLIST before BINLISTER'];
                                        title = 'ERPLAB: Error';
                                        errorfound(sprintf(msgboxText), title);
                                        return
                                end
                        else
                                msgboxText =  ['EVENTLIST.eventinfo structure was not found!\n'...
                                        'Use Create EVENTLIST before BINLISTER'];
                                title = 'ERPLAB: Error';
                                errorfound(sprintf(msgboxText), title);
                                return
                        end
                else
                        msgboxText =  ['EVENTLIST structure was not found!\n'...
                                'Use Create EVENTLIST before BINLISTER'];
                        title = 'ERPLAB: Error';
                        errorfound(sprintf(msgboxText), title);
                        return
                end
        else
                EEG = [];
        end
else
        EEG = [];
end

if nargin==1

        % {bdfile, evfile, blfile, flagrst, forbiddencodes, ignorecodes, updateeeg, option2do, reportx};

        def  = erpworkingmemory('pop_binlister');

        if isempty(def)
                def = {'' '' '' 0 [] [] 0 0 0};
        end

        %
        % Call a GUI
        %
        packarray = menuBinListGUI(EEG, def);

        if isempty(packarray)
                disp('User selected Cancel')
                return
        end

        file1      = packarray{1};
        file2      = packarray{2};
        file3      = packarray{3};
        flagrst    = packarray{4};        %1 means reset flags
        forbiddenCodeArray = packarray{5};
        ignoreCodeArray    = packarray{6};

        updevent   = packarray{7};
        option2do  = packarray{8};        % 0 means append EVENTLIST to EEG, 1 means send Eventlist to workspace only; 2 means to both
        reportable = packarray{9};        % 1 means create a report about binlister work.

        if iseegstruct(EEG)
                binaux    = [EEG.EVENTLIST.eventinfo.bini];
                binhunter = binaux(binaux>0); %8/19/2009

                if ~isempty(binhunter) && (option2do==0 || option2do==2)
                        msgboxText =  ['This dataset already has bins assigning.\n'...;
                                      'Would you like to overwrite this bins?'];
                        title = 'ERPLAB: Error';
                        button =askquest(sprintf(msgboxText), title);
                        if strcmpi(button,'no')
                                disp('User canceled')
                                return
                        end
                end
        end

        erpworkingmemory('pop_binlister', {file1, file2, file3, flagrst, forbiddenCodeArray, ignoreCodeArray, updevent, option2do, reportable});

        if isempty(file2)
                logfilename = 'no';
                logpathname = '';
                file2 = [logpathname logfilename];
                disp('For LOGFILE, user selected INTERNAL')
        end
else

        if nargin<2
                error('Few INPUTS')
        end
        if nargin<10
                reportable = 0; % no report
        else
                reportable = varargin{10};
        end
        if nargin<9
                option2do = 0; % 0 means append EVENTLIST to EEG
        else
                option2do = varargin{9};
        end
        if nargin<8
                updevent = 0;
        else
                updevent = varargin{8};
        end
        if nargin<7
                ignoreCodeArray = [];
        else
                ignoreCodeArray = varargin{7};
        end
        if nargin<6
                forbiddenCodeArray = [];
        else
                forbiddenCodeArray = varargin{6};
        end
        if nargin<5
                flagrst = 0;
        else
                flagrst = varargin{5};
        end
        if nargin<4
                file3   = 'no';
        else
                file3   = varargin{4};
        end
        if nargin<3
                file2   = 'no';
        else
                file2   = varargin{3};
        end

        file1    = varargin{2};
end

%
%  Reset Flags?
%
if flagrst==1
        % reset artifact flags
        EEG = resetflag(EEG, 255);
elseif flagrst==2
        % reset user flags
        EEG = resetflag(EEG, 65280);
elseif flagrst==3
        % reset ALL flags
        EEG = resetflag(EEG);
end

%
%  Call BINLISTER
%
modeoption = 0;
if isfield(EEG, 'EVENTLIST')
        ELaux = EEG.EVENTLIST; % store original EVENTLIST
else
        ELaux = [];
end

[EEG EVENTLIST binofbins isparsenum] = binlister(EEG, file1, file2, file3, forbiddenCodeArray, ignoreCodeArray, reportable);

if isparsenum==0
        % parsing was not approved
        msgboxText = ['Bin descriptor file contains errors!\n'...
                'For details, please read command window messages.'];
        title = 'ERPLAB: BDF Parsing Error';
        errorfound(sprintf(msgboxText), title);
        EEG.EVENTLIST = ELaux;
        return
end

if nnz(binofbins)>=1

        if ~isempty(EVENTLIST)

                if iseegstruct(EEG) && (option2do==0 || option2do==2)

                        EEG =  pasteeventlist(EEG, EVENTLIST, 1);
                        EEG.setname = [EEG.setname '_nelist']; %suggest a new name

                        if updevent && nargin==1
                                EEG = pop_overwritevent(EEG);
                        end
                        modeoption=1; % 1 means save using pop_newset (if GUI was used though)
                end

                if option2do==1 || option2do==2
                        assignin('base','EVENTLIST',EVENTLIST);  % send EVENTLIST structure to WORKSPACE, August 22, 2008
                        disp('EVENTLIST structure was sent to WORKSPACE.')
                end

                if option2do==3
                        EEG.EVENTLIST = ELaux;
                end

                % generate text command
                com = sprintf('%s = pop_binlister( %s, ''%s'', ''%s'', ''%s'', %s, %s, %s, %s, %s, %s);', inputname(1), inputname(1),...
                        file1, file2, file3, num2str(flagrst), vect2colon(forbiddenCodeArray,'Delimiter','on'), vect2colon(ignoreCodeArray,'Delimiter','on'), num2str(updevent),num2str(option2do),...
                        num2str(reportable));
        else
                msgboxText = ['Bin descriptor file contains errors!\n'...
                        'For details, please read command window messages.'];
                title = 'ERPLAB: BDF Parsing Error';
                errorfound(sprintf(msgboxText), title);
                EEG.EVENTLIST = ELaux;
                return
        end
else
        msgboxText =  ['Bins were not found!\n'...
                'Try with other BDF or modify the current one.'];
        title = 'ERPLAB: Binlister Error';
        errorfound(sprintf(msgboxText), title);
        disp('binlister process was cancel.')
        EEG.EVENTLIST = ELaux;
        return
end

if modeoption==1 && nargin==1
        [ALLEEG EEG CURRENTSET] = pop_newset( ALLEEG, EEG, CURRENTSET);
end

if ~isfield(ALLEEG,'data')
        [ALLEEG(1:length(ALLEEG)).data] = deal([]);
end

try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
return
