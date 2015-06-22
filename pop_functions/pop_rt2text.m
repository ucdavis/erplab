% PURPOSE  : 	Export reaction time values into text file
%
% FORMAT   :
%
% values = pop_rt2text(ERPLAB, varargin)
%
% or
%
% pop_rt2text(ERPLAB, varargin)
%
%
% INPUTS   :
%
% ERPLAB        - EEG or ERP structure. It must contain the EVENTLIST structure already
%                 filled, plus the reaction time info at rt fields. For instance:
%
%                 >> EEG.EVENTLIST.bdf(1)
%                    ans =
%                       expression: '.{22;11}{9:rt<"Red_Resp">}{21:rt<"Blue_Resp">}'
%                      description: 'Test 1'
%                          prehome: []
%                           athome: [1x1 struct]
%                         posthome: [1x2 struct]
%                          namebin: 'BIN 1'
%                           rtname: {'Red_Resp'  'Blue_Resp'}
%                          rtindex: [1 2]
%                               rt: [48x2 single]
%
%
% The available parameters are as follows:
%
%
%      'filename'     - full name of the exported text file.
%      'header'       - Include header (name of variables). 'on'/'off'. 'on' by default
%      'listformat'   - 'basic'/'itemized'. 'basic' by default
%      'arfilter'     - filter out RTs with marked flags. 'on'/'off'. 'off' by default
%      'eventlist'    - index for eventlist (when multiple EVENTLIST exist)
%
%
% OUTPUTS :
%
% -Text file with reaction time values or output variable.
%
%
% EXAMPLE  :
%
% >> pop_rt2text(EEG, C:\Users\etfoo\Documents\MATLAB\sample_rt.txt)
%
%
% See also saveRTGUI.m
%
% *** This function is part of ERPLAB Toolbox ***
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

function [ERPLAB, values, com] = pop_rt2text(ERPLAB, varargin)
com = '';
values = [];
if nargin<1
        help pop_rt2text
        return
end
if isobject(ERPLAB) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if nargin==1
        if isempty(ERPLAB)
                msgboxText =  ['Empty data structure.\n'...
                        'Please, load a dataset or erpset first...'];
                title     = 'ERPLAB: pop_rt2text()';
                errorfound(sprintf(msgboxText), title);
                return
        end
        if ~iseegstruct(ERPLAB) && ~iserpstruct(ERPLAB)
                msgboxText =  ['Invalid data structure.\n'...
                        'pop_rt2text() only works with EEG and ERP structures.'];
                title     = 'ERPLAB: pop_rt2text()';
                errorfound(sprintf(msgboxText), title);
                return
        else
                if iserpstruct(ERPLAB) % ERP
                        iserp=1;
                else % EEG
                        if length(ERPLAB)>1
                                msgboxText =  'Unfortunately, this function does not work with multiple datasets';
                                title = 'ERPLAB: multiple inputs';
                                errorfound(msgboxText, title);
                                return
                        end
                        iserp = 0;
                end
        end
        if isfield(ERPLAB, 'EVENTLIST')
                if isempty(ERPLAB.EVENTLIST)
                        msgboxText =  'EVENTLIST structure is empty!';
                        title      = 'ERPLAB: pop_rt2text()';
                        errorfound(msgboxText, title);
                        return
                end
        else
                if iserp
                        msgboxText =  'This erpset has not attached an EVENTLIST structure .';
                else
                        msgboxText =  'EVENTLIST structure has not been created yet!';
                end
                
                title     = 'ERPLAB: pop_rt2text()';
                errorfound(msgboxText, title);
                return
        end
        def  = erpworkingmemory('pop_rt2text');
        
        if isempty(def)
                def = {'' 'basic' 'on' 'off' 1};
        end
        
        e2 = length(ERPLAB.EVENTLIST);
        
        %
        % Call Gui
        %
        param  = saveRTGUI(def, e2);
        
        if isempty(param)
                disp('User selected Cancel')
                return
        end
        
        filenamei  = param{1};
        listformat = param{2};
        header     = param{3};  % 1 means include header (name of variables)
        arfilt     = param{4};  % 1 means filter out RTs with marked flags
        indexel    = param{5};  % index for eventlist
        
        [pathx, filename, ext] = fileparts(filenamei);
        
        if ~strcmpi(ext,'.txt') && ~strcmpi(ext,'.xls')  && ~strcmpi(ext,'.dat')
                ext = '.txt';
        end
        
        filename = [filename ext];
        filename = fullfile(pathx, filename);
        
        if header==1
                headstr = 'on';
        else
                headstr = 'off';
        end
        if arfilt==1
                arfilter = 'on';
        else
                arfilter = 'off';
        end
        
        erpworkingmemory('pop_rt2text', {filename, listformat, headstr, arfilter, indexel});
        
        %
        % Somersault
        %
        [ERPLAB,values, com] = pop_rt2text(ERPLAB, 'filename', filename, 'listformat', listformat, 'header', headstr,...
                'arfilter', arfilter, 'eventlist', indexel, 'History', 'gui');
        return
end

%
% Parsing inputs
%
% parsing inputs
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ERPLAB');
p.addParamValue('filename','', @ischar);
p.addParamValue('header', 'on', @ischar);
p.addParamValue('listformat', 'basic', @ischar);
p.addParamValue('arfilter', 'off', @ischar); % on means filter out RTs with marked flags
p.addParamValue('eventlist', [], @isnumeric); % index for eventlist
p.addParamValue('History', 'script', @ischar); % history from scripting
p.parse(ERPLAB, varargin{:});

filename   = p.Results.filename;
listformat = p.Results.listformat;
header     = p.Results.header;
arfilter   = p.Results.arfilter;

if strcmpi(p.Results.History,'implicit')
        shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
        shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
        shist = 1; % gui
else
        shist = 0; % off
end
if isempty(ERPLAB)
        msgboxText =  ['Empty data structure.\n'...
                'Please, load a dataset or erpset first...'];
        if shist==1
                title = 'ERPLAB: pop_rt2text() inputs';
                errorfound(sprintf(msgboxText), title);
                return
        else
                error('prog:input', ['ERPLAB says: ' msgboxText]);
        end
end
if ~iseegstruct(ERPLAB) && ~iserpstruct(ERPLAB)
        msgboxText =  ['Invalid data structure.\n'...
                'pop_rt2text() only works with EEG and ERP structures.'];
        if shist==1
                title = 'ERPLAB: pop_rt2text() inputs';
                errorfound(sprintf(msgboxText), title);
                return
        else
                error('prog:input', ['ERPLAB says: ' msgboxText]);
        end
else
        if iserpstruct(ERPLAB) % ERP
                iserp = 1;
                dtype = 'erpset';
                varin = 'ERP';
        else % EEG
                if length(ERPLAB)>1
                        msgboxText =  'Unfortunately, this function does not work with multiple datasets';
                        if shist==1
                                title = 'ERPLAB: pop_rt2text() inputs';
                                errorfound(sprintf(msgboxText), title);
                                return
                        else
                                error('prog:input', ['ERPLAB says: ' msgboxText]);
                        end
                end
                iserp = 0;
                dtype = 'dataset';
                varin = 'EEG';
        end
end
if isfield(ERPLAB, 'EVENTLIST')
        if isempty(ERPLAB.EVENTLIST)
                msgboxText =  'EVENTLIST structure is empty!';
                if shist==1
                        title = 'ERPLAB: pop_rt2text() inputs';
                        errorfound(sprintf(msgboxText), title);
                        return
                else
                        error('prog:input', ['ERPLAB says: ' msgboxText]);
                end
        end
else
        if iserp
                msgboxText =  'This erpset has not attached an EVENTLIST structure .';
        else
                msgboxText =  'EVENTLIST structure has not been created yet!';
        end
        if shist==1
                title = 'ERPLAB: pop_rt2text() inputs';
                errorfound(sprintf(msgboxText), title);
                return
        else
                error('prog:input', ['ERPLAB says: ' msgboxText]);
        end
end
if isempty(filename)
        msgboxText = 'Output filename is missing!.';
        if shist==1
                title = 'ERPLAB: pop_rt2text() inputs';
                errorfound(sprintf(msgboxText), title);
                return
        else
                error('prog:input', ['ERPLAB says: ' msgboxText]);
        end
end

[pathstr, filenamei, ext] = fileparts(filename);

if ~strcmpi(ext,'.txt') && ~strcmpi(ext,'.xls') && ~strcmpi(ext,'.dat')
        ext = '.txt';
end

filename = [filenamei ext];
filename    = fullfile(pathstr, filename);

if strcmpi(arfilter,'on')
        eliminAR = 1;
else
        eliminAR = 0;
end
indexel = p.Results.eventlist;% index for eventlist
e2 = length(ERPLAB.EVENTLIST);

if e2>1 && isempty(indexel)% JLC Aug 30, 2012
        prompt    = {['Enter EVENTLIST index (1-' num2str(e2) ')']};
        dlg_title = 'EVENTLIST index';
        num_lines = 1;
        def       = {'1'};
        answer    = inputdlg(prompt,dlg_title,num_lines,def);
        
        if isempty(answer)
                disp('User selected Cancel')
                return
        else
                indexel = str2num(answer{1});
                if isempty(indexel) || indexel<1 || indexel>e2
                        msgboxText =  'pop_rt2text() error: not valid EVENTLIST index';
                        if shist==1
                                title = 'ERPLAB: pop_rt2text() inputs';
                                errorfound(sprintf(msgboxText), title);
                                return
                        else
                                error('prog:input', ['ERPLAB says: ' msgboxText]);
                        end
                end
        end
elseif e2==1 && isempty(indexel)
        indexel = 1;
else
        if indexel<1 || indexel>e2
                msgboxText =  'pop_rt2text() error: not valid EVENTLIST index';
                if shist==1
                        title = 'ERPLAB: pop_rt2text() inputs';
                        errorfound(sprintf(msgboxText), title);
                        return
                else
                        error('prog:input', ['ERPLAB says: ' msgboxText]);
                end
        end
end
if isfield(ERPLAB.EVENTLIST(indexel), 'bdf')
        if isempty(ERPLAB.EVENTLIST(indexel).bdf)
                if iserp
                        msgboxText =  'This erpset has an empty EVENTLIST.bdf structure...';
                else
                        msgboxText =  'BINLISTER has not been performed yet!';
                end
                if shist==1
                        title = 'ERPLAB: pop_rt2text() inputs';
                        errorfound(sprintf(msgboxText), title);
                        return
                else
                        error('prog:input', ['ERPLAB says: ' msgboxText]);
                end
        end
        if ~isfield(ERPLAB.EVENTLIST(indexel).bdf, 'rt')
                msgboxText =  'There is not reaction time info in this %s!';
                if shist==1
                        title = 'ERPLAB: pop_rt2text() inputs';
                        errorfound(sprintf(msgboxText, dtype), title);
                        return
                else
                        error('prog:input', ['ERPLAB says: ' msgboxText], dtype);
                end
        else
                valid_rt = nnz(~cellfun(@isempty,{ERPLAB.EVENTLIST(indexel).bdf.rt}));                
                if valid_rt==0
                        msgboxText =  'There is not reaction time info in this %s!';
                        if shist==1
                                title = 'ERPLAB: pop_rt2text() inputs';
                                errorfound(sprintf(msgboxText, dtype), title);
                                return
                        else
                                error('prog:input', ['ERPLAB says: ' msgboxText], dtype);
                        end
                end
        end
else
        msgboxText =  'BINLISTER has not been performed yet!';
        if shist==1
                title = 'ERPLAB: pop_rt2text() inputs';
                errorfound(sprintf(msgboxText), title);
                return
        else
                error('prog:input', ['ERPLAB says: ' msgboxText]);
        end
end

nbin    = ERPLAB.EVENTLIST(indexel).nbin;
ndig    = 3; % decimal places
ndigstr = num2str(ndig);

if strcmp(listformat,'basic')
    %%%%%%%%%% BASIC FORMAT %%%%%%%%%%%
    %%%%%%%%%%              %%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    k      = 1;
    values = cell(1);
    label  = cell(1);
    
    for i=1:nbin
        for j=1:length(ERPLAB.EVENTLIST(indexel).bdf(i).rtname)
            rtnamex = ERPLAB.EVENTLIST(indexel).bdf(i).rtname{j};
            if ~isempty(rtnamex)
                label{k} = strrep(rtnamex, ' ', '_');
                if isempty([ERPLAB.EVENTLIST(indexel).bdf(i).rt])
                    [values{1,k}] = [];
                else
                    % select all the RT values for that bin
                    vrt   = ERPLAB.EVENTLIST(indexel).bdf(i).rt(:,j);
                    
                    if eliminAR  % eliminates RTs with Artifact Rejection (detection) marks.
                        
                        
                        %% CHECK BOTH THE RTHOMEFLAG AND THE RTFLAG
                        numBits     = 16;
                        % select all the rtflags and
                        % convert them to binary
                        % filter out the last 8 bits of the
                        % binary rt-flags to get the
                        % artifact flag (vs, the
                        % user-defined flag)
                        allRTFlags      = dec2bin(ERPLAB.EVENTLIST(indexel).bdf(i).rtflag(:,j), numBits);
                        allRTFlags      = allRTFlags(:,numBits/2+1:end);
                        
                        
                        % Do the same as above for the RT
                        % home flags
                        allRTHomeFlags  = dec2bin(ERPLAB.EVENTLIST(indexel).bdf(i).rthomeflag(:,j), numBits);
                        allRTHomeFlags  = allRTHomeFlags(:,numBits/2+1:end);
                        
                        
                        % Combine the rtflags with the
                        % rthome flags
                        allFlags        = bitor(bin2dec(allRTFlags), bin2dec(allRTHomeFlags));
                        flgrt           = allFlags;
                        
                        
                        % delete all the rts that have a
                        vrt(flgrt>0) = [];
                        
                    end
                    valrt = num2cell(vrt);
                    [values{1:length(vrt),k}] = valrt{:};
                end
                k = k + 1;
            end
        end
    end
    
    %
    % Empty values will be NaN
    %
    aa = find(cellfun(@isempty, values));
    [values{aa}] = deal(NaN);
    
    if strcmp(ext,'.xls')
        xlswrite(filename, [label; values]);
    else
        nsp = 7;
        %txtspace1 = max(cellfun(@length, label));
        %txtspace2 = num2str(txtspace1+ndig+nsp);
        txtspace  = max(cellfun(@length, label));
        if txtspace<2*ndig
            txtspace  = num2str(2*ndig+nsp);
        else
            txtspace  = num2str(txtspace+nsp);
        end
        
        CC        = cell2mat(values);
        fid_rt    = fopen(filename, 'w');
        fseek(fid_rt, 0, 'eof');
        
        %
        % Include Header?
        %
        if strcmp(header,'on')
            %repmat(['%' txtspace 's\t'], 1,length(label))
            fprintf(fid_rt, [repmat(['%' txtspace 's\t'], 1,length(label)) '\n'] , label{:});
        end
        
        %
        % Print values
        %
        %repmat(['%' num2str(txtspace1+nsp-1) '.' ndigstr 'f\t'], 1,size(values,2))
        fprintf(fid_rt, [repmat(['%' txtspace '.' ndigstr 'f\t'], 1,size(values,2)) '\n'] ,CC');
        fclose(fid_rt);
    end
else
    %%%%%%%%%% DETAILED FORMAT (ITEMIZED)%%%%%%%%%%%
    %%%%%%%%%%                           %%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    k         = 1;
    values    = [];
    lenbinlab = [];
    binlabelarray  = cell(1);
    
    for i=1:nbin
        for j=1:length(ERPLAB.EVENTLIST(indexel).bdf(i).rtname)
            rtnamex = ERPLAB.EVENTLIST(indexel).bdf(i).rtname{j};
            if ~isempty(rtnamex)
                if ~isempty([ERPLAB.EVENTLIST(indexel).bdf(i).rt])
                    vrt  = ERPLAB.EVENTLIST(indexel).bdf(i).rt(:,j); % RTs
                    if eliminAR  % changes to NaN RTs with Artifact Rejection (detection) marks.
                        %                                         flgrt = ERPLAB.EVENTLIST(indexel).bdf(i).rthomeflag(:,j);
                        
                        
                        %
                        %                                         numBits     = 16;
                        %                                         allFlags    = dec2bin(ERPLAB.EVENTLIST(indexel).bdf(i).rtflag(:,j), numBits);
                        %                                         flgrt       = bin2dec(allFlags(:,numBits/2+1:end));
                        
                        %% CHECK BOTH THE RTHOMEFLAG AND THE RTFLAG
                        numBits     = 16;
                        % select all the rtflags and
                        % convert them to binary
                        % filter out the last 8 bits of the
                        % binary rt-flags to get the
                        % artifact flag (vs, the
                        % user-defined flag)
                        allRTFlags      = dec2bin(ERPLAB.EVENTLIST(indexel).bdf(i).rtflag(:,j), numBits);
                        allRTFlags      = allRTFlags(:,numBits/2+1:end);
                        
                        
                        % Do the same as above for the RT
                        % home flags
                        allRTHomeFlags  = dec2bin(ERPLAB.EVENTLIST(indexel).bdf(i).rthomeflag(:,j), numBits);
                        allRTHomeFlags  = allRTHomeFlags(:,numBits/2+1:end);
                        
                        
                        % Combine the rtflags with the
                        % rthome flags
                        allFlags        = bitor(bin2dec(allRTFlags), bin2dec(allRTHomeFlags));
                        flgrt           = allFlags;
                        
                        
                        vrt(flgrt>0) = NaN;
                    end
                    irt  = ERPLAB.EVENTLIST(indexel).bdf(i).rtitem(:,j);      % item
                    hrt  = ERPLAB.EVENTLIST(indexel).bdf(i).rthomecode(:,j);  % home code
                    crt  = ERPLAB.EVENTLIST(indexel).bdf(i).rtcode(:,j);      % evaluated event code (about RT)
                    brt  = ERPLAB.EVENTLIST(indexel).bdf(i).rtbini(:,j);      % bin index
                    
                    istart = size(values, 1) + 1;
                    istop  = length(vrt) + istart - 1;
                    
                    values(istart:istop, 1) = irt;  % item
                    values(istart:istop, 2) = vrt;  % RT value
                    values(istart:istop, 3) = hrt;  % home code
                    values(istart:istop, 4) = crt;  % evaluated event code
                    values(istart:istop, 5) = brt;  % bin index
                    
                    [binlabelarray{istart:istop}] = deal(strrep(rtnamex, ' ', '_'));
                    lenbinlab(k) = length(rtnamex);
                    k = k+1;
                end
            end
            %disp('stop')
        end
    end
    
    
    if eliminAR  % deletes RTs with Artifact Rejection (detection) marks.
        idxnan = find(isnan(values(:,2)));
        binlabelarray(idxnan)=[];
        values(idxnan,:)=[];
    end
    
    % Sort "values" matrix according to the item value (column #1)
    [vaux,IX] = sort(values(:,1));
    values    = values(IX,:);
    binlabelarray = binlabelarray(IX);
    values    =  num2cell(values);
    FULLTABLE = [values binlabelarray'];
    %label = {'Item' 'RTime' 'Ecode' 'Bin#' 'BinLab'};
    label = {'Item' 'RTime' 'HomeCode' 'EvalCode' 'Bin#' 'BinLab'};
    % Item RTime HomeCode RespCode Bin# BinLab
    
    if strcmp(ext,'.xls')
        xlswrite(filename, [label; FULLTABLE]);
    else
        fid_rt  = fopen(filename, 'w');
        fseek(fid_rt, 0, 'eof');
        %ndig = 3;
        maxitem = num2str(length(num2str(max([values{:,1}]))));
        maxRT   = num2str(length(num2str(round(max([values{:,2}]))))+ ndig + 5);
        maxhc   = num2str(length(num2str(max([values{:,3}])))+7);
        maxec   = num2str(length(num2str(max([values{:,4}])))+7);
        maxbini = num2str(length(num2str(max([values{:,5}])))+7);
        maxblab = num2str(max(lenbinlab)+7);
        
        %
        % Include Header?
        %
        if strcmp(header,'on')
            %fprintf(fid_rt, [repmat('%s\t', 1,length(label)) '\n'] , label{:});
            fprintf(fid_rt, ['%' maxitem 's\t%' maxRT 's\t%' maxhc 's\t%' maxec 's\t%' ...
                maxbini 's\t%' maxblab 's\n'] , label{:});
        end
        
        %
        % Print values
        %
        for i=1:length(binlabelarray)
            fprintf(fid_rt, ['%' maxitem 'g\t%' maxRT '.' ndigstr 'f\t%' maxhc 'g\t%' maxec 'g\t%' ...
                maxbini 'g\t%' maxblab 's\n'] ,values{i,:}, binlabelarray{i});
        end
        fclose(fid_rt);
    end
end

disp(['A new file containing Reaction Times data was created at <a href="matlab: open(''' filename ''')">' filename '</a>'])

%
% command history
%
fn  = fieldnames(p.Results);
com = sprintf( 'values = pop_rt2text(%s', varin);
skipfields = {'ERPLAB','History'};
for q=1:length(fn)
        fn2com = fn{q};
        if ~ismember_bc2(fn2com, skipfields)
                fn2res = p.Results.(fn2com);
                if ~isempty(fn2res)
                        if ischar(fn2res)
                                if ~strcmpi(fn2res,'off')
                                        com = sprintf( '%s, ''%s'', ''%s''', com, fn2com, fn2res);
                                end
                        else
                                com = sprintf( '%s, ''%s'', %s', com, fn2com, vect2colon(fn2res,'Repeat','on'));
                        end
                end
        end
end

com = sprintf( '%s );', com);
% get history from script
if iseegstruct(ERPLAB)
        % get history from script. EEG
        switch shist
                case 1 % from GUI
                        com = sprintf('%s %% GUI: %s', com, datestr(now));
                        %fprintf('%%Equivalent command:\n%s\n\n', com);
                        displayEquiComERP(com);
                case 2 % from script
                        ERPLAB = erphistory(ERPLAB, [], com, 1);
                case 3
                        %ERPLAB = erphistory(ERPLAB, [], com, 1);
                        %fprintf('%%Equivalent command:\n%s\n\n', com);
                otherwise %off or none
                        com = '';
                        return
        end
else
        % get history from script. ERP
        switch shist
                case 1 % from GUI
                        displayEquiComERP(com);
                case 2 % from script
                        ERPLAB = erphistory(ERPLAB, [], com, 1);
                case 3
                        %ERPLAB = erphistory(ERPLAB, [], com, 1);
                        %fprintf('%%Equivalent command:\n%s\n\n', com);
                otherwise %off or none
                        com = '';
                        return
        end
end
%
% Completion statement
%
msg2end
return